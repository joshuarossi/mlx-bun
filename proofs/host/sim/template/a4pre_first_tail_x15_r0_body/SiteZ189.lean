import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS189
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK189
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF189
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 189 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1827`, the merged
state `PRE_first_tail_x15_r0_body.s1828`, the canonical state `PRE_first_tail_x15_r0_body.s1829`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl189 : PRE_first_tail_x15_r0_body.pl189.all (Nat.ble PRE_first_tail_x15_r0_body.s1827.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd189 : nodupT PRE_first_tail_x15_r0_body.pl189 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1189 : Nat.ble PRE_first_tail_x15_r0_body.s1827.next 2824133 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst189 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1827.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn189 : PRE_first_tail_x15_r0_body.s1829.next = PRE_first_tail_x15_r0_body.s1827.next + PRE_first_tail_x15_r0_body.pl189.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn189 : PRE_first_tail_x15_r0_body.s1828.next = 2824133
kernel_rfl PRE_first_tail_x15_r0_body.zgrow189 : Nat.ble PRE_first_tail_x15_r0_body.s1829.next PRE_first_tail_x15_r0_body.s1828.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh189 : PRE_first_tail_x15_r0_body.S1827.tab.all (fun e => PRE_first_tail_x15_r0_body.cws189.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd189 : nodupT PRE_first_tail_x15_r0_body.cws189 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi189 : PRE_first_tail_x15_r0_body.nr189.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1828.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt189 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1827.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg189_2665 : PRE_first_tail_x15_r0_body.s1829.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1829 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk189_2665 : (objOf PRE_first_tail_x15_r0_body.s1829 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm189_2665 : PRE_first_tail_x15_r0_body.s1828.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa189.obj (objOf PRE_first_tail_x15_r0_body.s1829 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1828 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg189_2673467 : PRE_first_tail_x15_r0_body.s1829.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1829 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk189_2673467 : (objOf PRE_first_tail_x15_r0_body.s1829 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm189_2673467 : PRE_first_tail_x15_r0_body.s1828.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa189.obj (objOf PRE_first_tail_x15_r0_body.s1829 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1828 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw189_4910 : (PRE_first_tail_x15_r0_body.s1829.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw189_2673472 : (PRE_first_tail_x15_r0_body.s1829.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw189_2673473 : (PRE_first_tail_x15_r0_body.s1829.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd189 : PRE_first_tail_x15_r0_body.cl189.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr189 : PRE_first_tail_x15_r0_body.st189.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1827.next || PRE_first_tail_x15_r0_body.cl189.contains b) = true
def PRE_first_tail_x15_r0_body.zl189 : List Nat := PRE_first_tail_x15_r0_body.cl189.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE189 : PRE_first_tail_x15_r0_body.zl189.map (fun a => PRE_first_tail_x15_r0_body.s1828.heap.get (PRE_first_tail_x15_r0_body.kappa189.a a)) = PRE_first_tail_x15_r0_body.zl189.map (fun a => (PRE_first_tail_x15_r0_body.s1829.heap.get a).map PRE_first_tail_x15_r0_body.kappa189.hobj)
theorem PRE_first_tail_x15_r0_body.zimg189 : HeapImg PRE_first_tail_x15_r0_body.kappa189 PRE_first_tail_x15_r0_body.s1829 PRE_first_tail_x15_r0_body.s1828 PRE_first_tail_x15_r0_body.zl189 := PRE_first_tail_x15_r0_body.zimgE189
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl189 : PRE_first_tail_x15_r0_body.s1828.ctl = PRE_first_tail_x15_r0_body.kappa189.ctl PRE_first_tail_x15_r0_body.s1829.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack189 : PRE_first_tail_x15_r0_body.s1828.stack = PRE_first_tail_x15_r0_body.s1829.stack.map PRE_first_tail_x15_r0_body.kappa189.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs189 : PRE_first_tail_x15_r0_body.s1828.jobs = PRE_first_tail_x15_r0_body.s1829.jobs.map PRE_first_tail_x15_r0_body.kappa189.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores189 : PRE_first_tail_x15_r0_body.s1828.stores = PRE_first_tail_x15_r0_body.kappa189.stores PRE_first_tail_x15_r0_body.s1829.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots189 : checkRootsSupp PRE_first_tail_x15_r0_body.s1829 8178 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC189 : PRE_first_tail_x15_r0_body.S1827.tab.length + PRE_first_tail_x15_r0_body.cws189.length = 8178
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap189 : PRE_first_tail_x15_r0_body.kappa189 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1827.next 2824133 PRE_first_tail_x15_r0_body.S1827.tab.length PRE_first_tail_x15_r0_body.pl189 (PRE_first_tail_x15_r0_body.nr189.map NumV.ref) PRE_first_tail_x15_r0_body.kd189.big
  PRE_first_tail_x15_r0_body.kd189.region PRE_first_tail_x15_r0_body.kd189.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin189 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1829.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc189 : Conv.jcleanListB (⟨21937, 19037, 2823783, 8178⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1829 PRE_first_tail_x15_r0_body.cl189 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB189 : noBigRootsP (fun i => !Conv.oldBigB (⟨21937, 19037, 2823783, 8178⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1829.trace PRE_first_tail_x15_r0_body.s1829 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm189 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 19031 = true
theorem PRE_first_tail_x15_r0_body.cjcl189 (h : Conv.JClean (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1827) : Conv.JClean (⟨21937, 19037, 2823783, 8178⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1829 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle189)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap189 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd189 a ha)) PRE_first_tail_x15_r0_body.zjc189

end Host.Load.Run.Tpl

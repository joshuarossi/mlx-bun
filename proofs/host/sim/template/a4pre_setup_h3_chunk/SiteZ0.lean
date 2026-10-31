import host.sim.template.a4pre_setup_h3_chunk.SiteS0
import host.sim.template.a4pre_setup_h3_chunk.SiteK0
import host.sim.template.a4pre_setup_h3_chunk.SiteF0
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 0 of chain `PRE_setup_h3_chunk` (`Conv.compact_shift`): the call `PRE_setup_h3_chunk.s0`, the merged
state `PRE_setup_h3_chunk.s1`, the canonical state `PRE_setup_h3_chunk.s2`; its frames [2665] (kept arrays [2665]). -/

-- the map's places and counters
kernel_rfl PRE_setup_h3_chunk.zpl0 : PRE_setup_h3_chunk.pl0.all (Nat.ble PRE_setup_h3_chunk.s0.next) = true
kernel_rfl PRE_setup_h3_chunk.zplnd0 : nodupT PRE_setup_h3_chunk.pl0 PTrie.nil = true
kernel_rfl PRE_setup_h3_chunk.zn10 : Nat.ble PRE_setup_h3_chunk.s0.next 2675688 = true
kernel_rfl PRE_setup_h3_chunk.zfirst0 : Nat.ble aFirst PRE_setup_h3_chunk.s0.next = true
kernel_rfl PRE_setup_h3_chunk.zscn0 : PRE_setup_h3_chunk.s2.next = PRE_setup_h3_chunk.s0.next + PRE_setup_h3_chunk.pl0.length
kernel_rfl PRE_setup_h3_chunk.zsmn0 : PRE_setup_h3_chunk.s1.next = 2675688
kernel_rfl PRE_setup_h3_chunk.zgrow0 : Nat.ble PRE_setup_h3_chunk.s2.next PRE_setup_h3_chunk.s1.next = true
-- the tables
kernel_rfl PRE_setup_h3_chunk.zfresh0 : PRE_setup_h3_chunk.S0.tab.all (fun e => PRE_setup_h3_chunk.cws0.all fun v => e.noVar v) = true
kernel_rfl PRE_setup_h3_chunk.zcnd0 : nodupT PRE_setup_h3_chunk.cws0 PTrie.nil = true
kernel_rfl PRE_setup_h3_chunk.znrHi0 : PRE_setup_h3_chunk.nr0.all (fun r => Nat.blt r PRE_setup_h3_chunk.S1.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_setup_h3_chunk.zfrlt0 : [2665].all (fun a => Nat.blt a PRE_setup_h3_chunk.s0.next) = true
kernel_rfl PRE_setup_h3_chunk.zg0_2665 : PRE_setup_h3_chunk.s2.heap.get 2665 = some (.obj (objOf PRE_setup_h3_chunk.s2 2665))
kernel_rfl PRE_setup_h3_chunk.zk0_2665 : (objOf PRE_setup_h3_chunk.s2 2665).kind = .array (arrOf PRE_setup_h3_chunk.s0 2665)
kernel_rfl PRE_setup_h3_chunk.zm0_2665 : PRE_setup_h3_chunk.s1.heap.get 2665 = some (.obj { PRE_setup_h3_chunk.kappa0.obj (objOf PRE_setup_h3_chunk.s2 2665) with
  kind := .array (arrOf PRE_setup_h3_chunk.s0 2665 ++ (arrOf PRE_setup_h3_chunk.s1 2665).drop (arrOf PRE_setup_h3_chunk.s0 2665).length) })
kernel_rfl PRE_setup_h3_chunk.zw0_4910 : (PRE_setup_h3_chunk.s2.heap.get 4910).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_setup_h3_chunk.zclbd0 : PRE_setup_h3_chunk.cl0.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_setup_h3_chunk.zwr0 : PRE_setup_h3_chunk.st0.wr.all (fun b => !Nat.blt b PRE_setup_h3_chunk.s0.next || PRE_setup_h3_chunk.cl0.contains b) = true
def PRE_setup_h3_chunk.zl0 : List Nat := PRE_setup_h3_chunk.cl0.filter fun a => !(List.contains [2665] a)
kernel_rfl PRE_setup_h3_chunk.zimgE0 : PRE_setup_h3_chunk.zl0.map (fun a => PRE_setup_h3_chunk.s1.heap.get (PRE_setup_h3_chunk.kappa0.a a)) = PRE_setup_h3_chunk.zl0.map (fun a => (PRE_setup_h3_chunk.s2.heap.get a).map PRE_setup_h3_chunk.kappa0.hobj)
theorem PRE_setup_h3_chunk.zimg0 : HeapImg PRE_setup_h3_chunk.kappa0 PRE_setup_h3_chunk.s2 PRE_setup_h3_chunk.s1 PRE_setup_h3_chunk.zl0 := PRE_setup_h3_chunk.zimgE0
-- the roots and their supports
kernel_rfl PRE_setup_h3_chunk.zctl0 : PRE_setup_h3_chunk.s1.ctl = PRE_setup_h3_chunk.kappa0.ctl PRE_setup_h3_chunk.s2.ctl
kernel_rfl PRE_setup_h3_chunk.zstack0 : PRE_setup_h3_chunk.s1.stack = PRE_setup_h3_chunk.s2.stack.map PRE_setup_h3_chunk.kappa0.frame
kernel_rfl PRE_setup_h3_chunk.zjobs0 : PRE_setup_h3_chunk.s1.jobs = PRE_setup_h3_chunk.s2.jobs.map PRE_setup_h3_chunk.kappa0.job
kernel_rfl PRE_setup_h3_chunk.zstores0 : PRE_setup_h3_chunk.s1.stores = PRE_setup_h3_chunk.kappa0.stores PRE_setup_h3_chunk.s2.stores
kernel_rfl PRE_setup_h3_chunk.zroots0 : checkRootsSupp PRE_setup_h3_chunk.s2 10 = true
kernel_rfl PRE_setup_h3_chunk.znC0 : PRE_setup_h3_chunk.S0.tab.length + PRE_setup_h3_chunk.cws0.length = 10
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_setup_h3_chunk.zkap0 : PRE_setup_h3_chunk.kappa0 = Conv.Map.compact PRE_setup_h3_chunk.s0.next 2675688 PRE_setup_h3_chunk.S0.tab.length PRE_setup_h3_chunk.pl0 (PRE_setup_h3_chunk.nr0.map NumV.ref) PRE_setup_h3_chunk.kd0.big
  PRE_setup_h3_chunk.kd0.region PRE_setup_h3_chunk.kd0.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_setup_h3_chunk.zbin0 : (Host.Ts.Sim.Full.bridgeOf PRE_setup_h3_chunk.s2.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_setup_h3_chunk.zjc0 : Conv.jcleanListB (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) PRE_setup_h3_chunk.s2 PRE_setup_h3_chunk.cl0 = true
kernel_rfl PRE_setup_h3_chunk.zroots20 : noBigRootsP (fun i => !Conv.oldBigB (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) i) PRE_setup_h3_chunk.s2.trace PRE_setup_h3_chunk.s2 = true
kernel_rfl PRE_setup_h3_chunk.zhm0 : Nat.ble (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.nnext 15235 = true
theorem PRE_setup_h3_chunk.cjcl0 (h : Conv.JClean (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) PRE_setup_h3_chunk.s0) : Conv.JClean (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) PRE_setup_h3_chunk.s2 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_setup_h3_chunk.cle0)
    (Conv.heap_off_setAll PRE_setup_h3_chunk.cheap0 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_setup_h3_chunk.zclbd0 a ha)) PRE_setup_h3_chunk.zjc0

end Host.Load.Run.Tpl

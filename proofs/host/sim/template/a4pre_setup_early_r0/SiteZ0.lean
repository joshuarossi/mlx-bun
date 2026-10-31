import host.sim.template.a4pre_setup_early_r0.SiteS0
import host.sim.template.a4pre_setup_early_r0.SiteK0
import host.sim.template.a4pre_setup_early_r0.SiteF0
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 0 of chain `PRE_setup_early_r0` (`Conv.compact_shift`): the call `PRE_setup_early_r0.s4`, the merged
state `PRE_setup_early_r0.s5`, the canonical state `PRE_setup_early_r0.s6`; its frames [2665] (kept arrays [2665]). -/

-- the map's places and counters
kernel_rfl PRE_setup_early_r0.zpl0 : PRE_setup_early_r0.pl0.all (Nat.ble PRE_setup_early_r0.s4.next) = true
kernel_rfl PRE_setup_early_r0.zplnd0 : nodupT PRE_setup_early_r0.pl0 PTrie.nil = true
kernel_rfl PRE_setup_early_r0.zn10 : Nat.ble PRE_setup_early_r0.s4.next 2673349 = true
kernel_rfl PRE_setup_early_r0.zfirst0 : Nat.ble aFirst PRE_setup_early_r0.s4.next = true
kernel_rfl PRE_setup_early_r0.zscn0 : PRE_setup_early_r0.s6.next = PRE_setup_early_r0.s4.next + PRE_setup_early_r0.pl0.length
kernel_rfl PRE_setup_early_r0.zsmn0 : PRE_setup_early_r0.s5.next = 2673349
kernel_rfl PRE_setup_early_r0.zgrow0 : Nat.ble PRE_setup_early_r0.s6.next PRE_setup_early_r0.s5.next = true
-- the tables
kernel_rfl PRE_setup_early_r0.zfresh0 : PRE_setup_early_r0.S4.tab.all (fun e => PRE_setup_early_r0.cws0.all fun v => e.noVar v) = true
kernel_rfl PRE_setup_early_r0.zcnd0 : nodupT PRE_setup_early_r0.cws0 PTrie.nil = true
kernel_rfl PRE_setup_early_r0.znrHi0 : PRE_setup_early_r0.nr0.all (fun r => Nat.blt r PRE_setup_early_r0.S5.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_setup_early_r0.zfrlt0 : [2665].all (fun a => Nat.blt a PRE_setup_early_r0.s4.next) = true
kernel_rfl PRE_setup_early_r0.zg0_2665 : PRE_setup_early_r0.s6.heap.get 2665 = some (.obj (objOf PRE_setup_early_r0.s6 2665))
kernel_rfl PRE_setup_early_r0.zk0_2665 : (objOf PRE_setup_early_r0.s6 2665).kind = .array (arrOf PRE_setup_early_r0.s0 2665)
kernel_rfl PRE_setup_early_r0.zm0_2665 : PRE_setup_early_r0.s5.heap.get 2665 = some (.obj { PRE_setup_early_r0.kappa0.obj (objOf PRE_setup_early_r0.s6 2665) with
  kind := .array (arrOf PRE_setup_early_r0.s0 2665 ++ (arrOf PRE_setup_early_r0.s5 2665).drop (arrOf PRE_setup_early_r0.s0 2665).length) })
kernel_rfl PRE_setup_early_r0.zw0_4910 : (PRE_setup_early_r0.s6.heap.get 4910).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_setup_early_r0.zclbd0 : PRE_setup_early_r0.cl0.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_setup_early_r0.zwr0 : PRE_setup_early_r0.st0.wr.all (fun b => !Nat.blt b PRE_setup_early_r0.s4.next || PRE_setup_early_r0.cl0.contains b) = true
def PRE_setup_early_r0.zl0 : List Nat := PRE_setup_early_r0.cl0.filter fun a => !(List.contains [2665] a)
kernel_rfl PRE_setup_early_r0.zimgE0 : PRE_setup_early_r0.zl0.map (fun a => PRE_setup_early_r0.s5.heap.get (PRE_setup_early_r0.kappa0.a a)) = PRE_setup_early_r0.zl0.map (fun a => (PRE_setup_early_r0.s6.heap.get a).map PRE_setup_early_r0.kappa0.hobj)
theorem PRE_setup_early_r0.zimg0 : HeapImg PRE_setup_early_r0.kappa0 PRE_setup_early_r0.s6 PRE_setup_early_r0.s5 PRE_setup_early_r0.zl0 := PRE_setup_early_r0.zimgE0
-- the roots and their supports
kernel_rfl PRE_setup_early_r0.zctl0 : PRE_setup_early_r0.s5.ctl = PRE_setup_early_r0.kappa0.ctl PRE_setup_early_r0.s6.ctl
kernel_rfl PRE_setup_early_r0.zstack0 : PRE_setup_early_r0.s5.stack = PRE_setup_early_r0.s6.stack.map PRE_setup_early_r0.kappa0.frame
kernel_rfl PRE_setup_early_r0.zjobs0 : PRE_setup_early_r0.s5.jobs = PRE_setup_early_r0.s6.jobs.map PRE_setup_early_r0.kappa0.job
kernel_rfl PRE_setup_early_r0.zstores0 : PRE_setup_early_r0.s5.stores = PRE_setup_early_r0.kappa0.stores PRE_setup_early_r0.s6.stores
kernel_rfl PRE_setup_early_r0.zroots0 : checkRootsSupp PRE_setup_early_r0.s6 10 = true
kernel_rfl PRE_setup_early_r0.znC0 : PRE_setup_early_r0.S4.tab.length + PRE_setup_early_r0.cws0.length = 10
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_setup_early_r0.zkap0 : PRE_setup_early_r0.kappa0 = Conv.Map.compact PRE_setup_early_r0.s4.next 2673349 PRE_setup_early_r0.S4.tab.length PRE_setup_early_r0.pl0 (PRE_setup_early_r0.nr0.map NumV.ref) PRE_setup_early_r0.kd0.big
  PRE_setup_early_r0.kd0.region PRE_setup_early_r0.kd0.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_setup_early_r0.zbin0 : (Host.Ts.Sim.Full.bridgeOf PRE_setup_early_r0.s6.ffi).active = false := by
  change (Host.Load.Boot.replay Host.Load.Run.Prompt.P.oblog2818).active = false
  exact Host.Load.Boot.replay_active _
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_setup_early_r0.zjc0 : Conv.jcleanListB (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) PRE_setup_early_r0.s6 PRE_setup_early_r0.cl0 = true
kernel_rfl PRE_setup_early_r0.zroots20 : noBigRootsP (fun i => !Conv.oldBigB (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) i) PRE_setup_early_r0.s6.trace PRE_setup_early_r0.s6 = true
kernel_rfl PRE_setup_early_r0.zhm0 : Nat.ble (Host.Load.Layers.toLoad PRE_setup_early_r0.s0.ffi).mlx.nnext 15235 = true
theorem PRE_setup_early_r0.cjcl0 (h : Conv.JClean (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) PRE_setup_early_r0.s4) : Conv.JClean (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) PRE_setup_early_r0.s6 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_setup_early_r0.cle0)
    (Conv.heap_off_setAll PRE_setup_early_r0.cheap0 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_setup_early_r0.zclbd0 a ha)) PRE_setup_early_r0.zjc0

end Host.Load.Run.Tpl

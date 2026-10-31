import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS48
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK48
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF48
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 48 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s434`, the merged
state `PRE_first_tail_x15_r0_body.s435`, the canonical state `PRE_first_tail_x15_r0_body.s436`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl48 : PRE_first_tail_x15_r0_body.pl48.all (Nat.ble PRE_first_tail_x15_r0_body.s434.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd48 : nodupT PRE_first_tail_x15_r0_body.pl48 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn148 : Nat.ble PRE_first_tail_x15_r0_body.s434.next 2714278 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst48 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s434.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn48 : PRE_first_tail_x15_r0_body.s436.next = PRE_first_tail_x15_r0_body.s434.next + PRE_first_tail_x15_r0_body.pl48.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn48 : PRE_first_tail_x15_r0_body.s435.next = 2714278
kernel_rfl PRE_first_tail_x15_r0_body.zgrow48 : Nat.ble PRE_first_tail_x15_r0_body.s436.next PRE_first_tail_x15_r0_body.s435.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh48 : PRE_first_tail_x15_r0_body.S434.tab.all (fun e => PRE_first_tail_x15_r0_body.cws48.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd48 : nodupT PRE_first_tail_x15_r0_body.cws48 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi48 : PRE_first_tail_x15_r0_body.nr48.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S435.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt48 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s434.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg48_2665 : PRE_first_tail_x15_r0_body.s436.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s436 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk48_2665 : (objOf PRE_first_tail_x15_r0_body.s436 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm48_2665 : PRE_first_tail_x15_r0_body.s435.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa48.obj (objOf PRE_first_tail_x15_r0_body.s436 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s435 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg48_2673467 : PRE_first_tail_x15_r0_body.s436.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s436 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk48_2673467 : (objOf PRE_first_tail_x15_r0_body.s436 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm48_2673467 : PRE_first_tail_x15_r0_body.s435.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa48.obj (objOf PRE_first_tail_x15_r0_body.s436 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s435 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw48_4910 : (PRE_first_tail_x15_r0_body.s436.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw48_2673472 : (PRE_first_tail_x15_r0_body.s436.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw48_2673473 : (PRE_first_tail_x15_r0_body.s436.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd48 : PRE_first_tail_x15_r0_body.cl48.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr48 : PRE_first_tail_x15_r0_body.st48.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s434.next || PRE_first_tail_x15_r0_body.cl48.contains b) = true
def PRE_first_tail_x15_r0_body.zl48 : List Nat := PRE_first_tail_x15_r0_body.cl48.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE48 : PRE_first_tail_x15_r0_body.zl48.map (fun a => PRE_first_tail_x15_r0_body.s435.heap.get (PRE_first_tail_x15_r0_body.kappa48.a a)) = PRE_first_tail_x15_r0_body.zl48.map (fun a => (PRE_first_tail_x15_r0_body.s436.heap.get a).map PRE_first_tail_x15_r0_body.kappa48.hobj)
theorem PRE_first_tail_x15_r0_body.zimg48 : HeapImg PRE_first_tail_x15_r0_body.kappa48 PRE_first_tail_x15_r0_body.s436 PRE_first_tail_x15_r0_body.s435 PRE_first_tail_x15_r0_body.zl48 := PRE_first_tail_x15_r0_body.zimgE48
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl48 : PRE_first_tail_x15_r0_body.s435.ctl = PRE_first_tail_x15_r0_body.kappa48.ctl PRE_first_tail_x15_r0_body.s436.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack48 : PRE_first_tail_x15_r0_body.s435.stack = PRE_first_tail_x15_r0_body.s436.stack.map PRE_first_tail_x15_r0_body.kappa48.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs48 : PRE_first_tail_x15_r0_body.s435.jobs = PRE_first_tail_x15_r0_body.s436.jobs.map PRE_first_tail_x15_r0_body.kappa48.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores48 : PRE_first_tail_x15_r0_body.s435.stores = PRE_first_tail_x15_r0_body.kappa48.stores PRE_first_tail_x15_r0_body.s436.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots48 : checkRootsSupp PRE_first_tail_x15_r0_body.s436 2153 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC48 : PRE_first_tail_x15_r0_body.S434.tab.length + PRE_first_tail_x15_r0_body.cws48.length = 2153
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap48 : PRE_first_tail_x15_r0_body.kappa48 = Conv.Map.compact PRE_first_tail_x15_r0_body.s434.next 2714278 PRE_first_tail_x15_r0_body.S434.tab.length PRE_first_tail_x15_r0_body.pl48 (PRE_first_tail_x15_r0_body.nr48.map NumV.ref) PRE_first_tail_x15_r0_body.kd48.big
  PRE_first_tail_x15_r0_body.kd48.region PRE_first_tail_x15_r0_body.kd48.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin48 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s436.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc48 : Conv.jcleanListB (⟨19163, 16253, 2713129, 2153⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s436 PRE_first_tail_x15_r0_body.cl48 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots248 : noBigRootsP (fun i => !Conv.oldBigB (⟨19163, 16253, 2713129, 2153⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s436.trace PRE_first_tail_x15_r0_body.s436 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm48 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16226 = true
theorem PRE_first_tail_x15_r0_body.cjcl48 (h : Conv.JClean (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s434) : Conv.JClean (⟨19163, 16253, 2713129, 2153⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s436 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle48)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap48 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd48 a ha)) PRE_first_tail_x15_r0_body.zjc48

end Host.Load.Run.Tpl

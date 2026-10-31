import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS75
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK75
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF75
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 75 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s735`, the merged
state `PRE_first_tail_x15_r0_body.s736`, the canonical state `PRE_first_tail_x15_r0_body.s737`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl75 : PRE_first_tail_x15_r0_body.pl75.all (Nat.ble PRE_first_tail_x15_r0_body.s735.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd75 : nodupT PRE_first_tail_x15_r0_body.pl75 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn175 : Nat.ble PRE_first_tail_x15_r0_body.s735.next 2735370 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst75 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s735.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn75 : PRE_first_tail_x15_r0_body.s737.next = PRE_first_tail_x15_r0_body.s735.next + PRE_first_tail_x15_r0_body.pl75.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn75 : PRE_first_tail_x15_r0_body.s736.next = 2735370
kernel_rfl PRE_first_tail_x15_r0_body.zgrow75 : Nat.ble PRE_first_tail_x15_r0_body.s737.next PRE_first_tail_x15_r0_body.s736.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh75 : PRE_first_tail_x15_r0_body.S735.tab.all (fun e => PRE_first_tail_x15_r0_body.cws75.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd75 : nodupT PRE_first_tail_x15_r0_body.cws75 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi75 : PRE_first_tail_x15_r0_body.nr75.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S736.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt75 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s735.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg75_2665 : PRE_first_tail_x15_r0_body.s737.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s737 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk75_2665 : (objOf PRE_first_tail_x15_r0_body.s737 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm75_2665 : PRE_first_tail_x15_r0_body.s736.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa75.obj (objOf PRE_first_tail_x15_r0_body.s737 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s736 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg75_2673467 : PRE_first_tail_x15_r0_body.s737.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s737 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk75_2673467 : (objOf PRE_first_tail_x15_r0_body.s737 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm75_2673467 : PRE_first_tail_x15_r0_body.s736.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa75.obj (objOf PRE_first_tail_x15_r0_body.s737 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s736 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw75_4910 : (PRE_first_tail_x15_r0_body.s737.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw75_2673472 : (PRE_first_tail_x15_r0_body.s737.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw75_2673473 : (PRE_first_tail_x15_r0_body.s737.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd75 : PRE_first_tail_x15_r0_body.cl75.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr75 : PRE_first_tail_x15_r0_body.st75.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s735.next || PRE_first_tail_x15_r0_body.cl75.contains b) = true
def PRE_first_tail_x15_r0_body.zl75 : List Nat := PRE_first_tail_x15_r0_body.cl75.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE75 : PRE_first_tail_x15_r0_body.zl75.map (fun a => PRE_first_tail_x15_r0_body.s736.heap.get (PRE_first_tail_x15_r0_body.kappa75.a a)) = PRE_first_tail_x15_r0_body.zl75.map (fun a => (PRE_first_tail_x15_r0_body.s737.heap.get a).map PRE_first_tail_x15_r0_body.kappa75.hobj)
theorem PRE_first_tail_x15_r0_body.zimg75 : HeapImg PRE_first_tail_x15_r0_body.kappa75 PRE_first_tail_x15_r0_body.s737 PRE_first_tail_x15_r0_body.s736 PRE_first_tail_x15_r0_body.zl75 := PRE_first_tail_x15_r0_body.zimgE75
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl75 : PRE_first_tail_x15_r0_body.s736.ctl = PRE_first_tail_x15_r0_body.kappa75.ctl PRE_first_tail_x15_r0_body.s737.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack75 : PRE_first_tail_x15_r0_body.s736.stack = PRE_first_tail_x15_r0_body.s737.stack.map PRE_first_tail_x15_r0_body.kappa75.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs75 : PRE_first_tail_x15_r0_body.s736.jobs = PRE_first_tail_x15_r0_body.s737.jobs.map PRE_first_tail_x15_r0_body.kappa75.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores75 : PRE_first_tail_x15_r0_body.s736.stores = PRE_first_tail_x15_r0_body.kappa75.stores PRE_first_tail_x15_r0_body.s737.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots75 : checkRootsSupp PRE_first_tail_x15_r0_body.s737 3308 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC75 : PRE_first_tail_x15_r0_body.S735.tab.length + PRE_first_tail_x15_r0_body.cws75.length = 3308
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap75 : PRE_first_tail_x15_r0_body.kappa75 = Conv.Map.compact PRE_first_tail_x15_r0_body.s735.next 2735370 PRE_first_tail_x15_r0_body.S735.tab.length PRE_first_tail_x15_r0_body.pl75 (PRE_first_tail_x15_r0_body.nr75.map NumV.ref) PRE_first_tail_x15_r0_body.kd75.big
  PRE_first_tail_x15_r0_body.kd75.region PRE_first_tail_x15_r0_body.kd75.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin75 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s737.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc75 : Conv.jcleanListB (⟨19692, 16790, 2734221, 3308⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s737 PRE_first_tail_x15_r0_body.cl75 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB75 : noBigRootsP (fun i => !Conv.oldBigB (⟨19692, 16790, 2734221, 3308⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s737.trace PRE_first_tail_x15_r0_body.s737 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm75 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16763 = true
theorem PRE_first_tail_x15_r0_body.cjcl75 (h : Conv.JClean (⟨19689, 16763, 2734215, 3290⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s735) : Conv.JClean (⟨19692, 16790, 2734221, 3308⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s737 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle75)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap75 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd75 a ha)) PRE_first_tail_x15_r0_body.zjc75

end Host.Load.Run.Tpl

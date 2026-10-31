import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS64
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK64
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF64
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 64 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s628`, the merged
state `PRE_first_tail_x15_r0_body.s629`, the canonical state `PRE_first_tail_x15_r0_body.s630`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl64 : PRE_first_tail_x15_r0_body.pl64.all (Nat.ble PRE_first_tail_x15_r0_body.s628.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd64 : nodupT PRE_first_tail_x15_r0_body.pl64 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn164 : Nat.ble PRE_first_tail_x15_r0_body.s628.next 2725301 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst64 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s628.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn64 : PRE_first_tail_x15_r0_body.s630.next = PRE_first_tail_x15_r0_body.s628.next + PRE_first_tail_x15_r0_body.pl64.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn64 : PRE_first_tail_x15_r0_body.s629.next = 2725301
kernel_rfl PRE_first_tail_x15_r0_body.zgrow64 : Nat.ble PRE_first_tail_x15_r0_body.s630.next PRE_first_tail_x15_r0_body.s629.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh64 : PRE_first_tail_x15_r0_body.S628.tab.all (fun e => PRE_first_tail_x15_r0_body.cws64.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd64 : nodupT PRE_first_tail_x15_r0_body.cws64 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi64 : PRE_first_tail_x15_r0_body.nr64.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S629.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt64 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s628.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg64_2665 : PRE_first_tail_x15_r0_body.s630.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s630 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk64_2665 : (objOf PRE_first_tail_x15_r0_body.s630 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm64_2665 : PRE_first_tail_x15_r0_body.s629.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa64.obj (objOf PRE_first_tail_x15_r0_body.s630 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s629 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg64_2673467 : PRE_first_tail_x15_r0_body.s630.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s630 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk64_2673467 : (objOf PRE_first_tail_x15_r0_body.s630 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm64_2673467 : PRE_first_tail_x15_r0_body.s629.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa64.obj (objOf PRE_first_tail_x15_r0_body.s630 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s629 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw64_4910 : (PRE_first_tail_x15_r0_body.s630.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw64_2673472 : (PRE_first_tail_x15_r0_body.s630.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw64_2673473 : (PRE_first_tail_x15_r0_body.s630.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd64 : PRE_first_tail_x15_r0_body.cl64.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr64 : PRE_first_tail_x15_r0_body.st64.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s628.next || PRE_first_tail_x15_r0_body.cl64.contains b) = true
def PRE_first_tail_x15_r0_body.zl64 : List Nat := PRE_first_tail_x15_r0_body.cl64.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE64 : PRE_first_tail_x15_r0_body.zl64.map (fun a => PRE_first_tail_x15_r0_body.s629.heap.get (PRE_first_tail_x15_r0_body.kappa64.a a)) = PRE_first_tail_x15_r0_body.zl64.map (fun a => (PRE_first_tail_x15_r0_body.s630.heap.get a).map PRE_first_tail_x15_r0_body.kappa64.hobj)
theorem PRE_first_tail_x15_r0_body.zimg64 : HeapImg PRE_first_tail_x15_r0_body.kappa64 PRE_first_tail_x15_r0_body.s630 PRE_first_tail_x15_r0_body.s629 PRE_first_tail_x15_r0_body.zl64 := PRE_first_tail_x15_r0_body.zimgE64
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl64 : PRE_first_tail_x15_r0_body.s629.ctl = PRE_first_tail_x15_r0_body.kappa64.ctl PRE_first_tail_x15_r0_body.s630.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack64 : PRE_first_tail_x15_r0_body.s629.stack = PRE_first_tail_x15_r0_body.s630.stack.map PRE_first_tail_x15_r0_body.kappa64.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs64 : PRE_first_tail_x15_r0_body.s629.jobs = PRE_first_tail_x15_r0_body.s630.jobs.map PRE_first_tail_x15_r0_body.kappa64.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores64 : PRE_first_tail_x15_r0_body.s629.stores = PRE_first_tail_x15_r0_body.kappa64.stores PRE_first_tail_x15_r0_body.s630.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots64 : checkRootsSupp PRE_first_tail_x15_r0_body.s630 2816 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC64 : PRE_first_tail_x15_r0_body.S628.tab.length + PRE_first_tail_x15_r0_body.cws64.length = 2816
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap64 : PRE_first_tail_x15_r0_body.kappa64 = Conv.Map.compact PRE_first_tail_x15_r0_body.s628.next 2725301 PRE_first_tail_x15_r0_body.S628.tab.length PRE_first_tail_x15_r0_body.pl64 (PRE_first_tail_x15_r0_body.nr64.map NumV.ref) PRE_first_tail_x15_r0_body.kd64.big
  PRE_first_tail_x15_r0_body.kd64.region PRE_first_tail_x15_r0_body.kd64.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin64 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s630.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc64 : Conv.jcleanListB (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s630 PRE_first_tail_x15_r0_body.cl64 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB64 : noBigRootsP (fun i => !Conv.oldBigB (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s630.trace PRE_first_tail_x15_r0_body.s630 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm64 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16566 = true
theorem PRE_first_tail_x15_r0_body.cjcl64 (h : Conv.JClean (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s628) : Conv.JClean (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s630 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle64)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap64 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd64 a ha)) PRE_first_tail_x15_r0_body.zjc64

end Host.Load.Run.Tpl

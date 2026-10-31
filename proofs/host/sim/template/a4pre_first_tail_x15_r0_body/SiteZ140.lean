import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS140
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK140
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF140
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 140 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1351`, the merged
state `PRE_first_tail_x15_r0_body.s1352`, the canonical state `PRE_first_tail_x15_r0_body.s1353`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl140 : PRE_first_tail_x15_r0_body.pl140.all (Nat.ble PRE_first_tail_x15_r0_body.s1351.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd140 : nodupT PRE_first_tail_x15_r0_body.pl140 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1140 : Nat.ble PRE_first_tail_x15_r0_body.s1351.next 2784355 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst140 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1351.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn140 : PRE_first_tail_x15_r0_body.s1353.next = PRE_first_tail_x15_r0_body.s1351.next + PRE_first_tail_x15_r0_body.pl140.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn140 : PRE_first_tail_x15_r0_body.s1352.next = 2784355
kernel_rfl PRE_first_tail_x15_r0_body.zgrow140 : Nat.ble PRE_first_tail_x15_r0_body.s1353.next PRE_first_tail_x15_r0_body.s1352.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh140 : PRE_first_tail_x15_r0_body.S1351.tab.all (fun e => PRE_first_tail_x15_r0_body.cws140.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd140 : nodupT PRE_first_tail_x15_r0_body.cws140 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi140 : PRE_first_tail_x15_r0_body.nr140.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1352.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt140 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1351.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg140_2665 : PRE_first_tail_x15_r0_body.s1353.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1353 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk140_2665 : (objOf PRE_first_tail_x15_r0_body.s1353 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm140_2665 : PRE_first_tail_x15_r0_body.s1352.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa140.obj (objOf PRE_first_tail_x15_r0_body.s1353 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1352 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg140_2673467 : PRE_first_tail_x15_r0_body.s1353.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1353 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk140_2673467 : (objOf PRE_first_tail_x15_r0_body.s1353 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm140_2673467 : PRE_first_tail_x15_r0_body.s1352.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa140.obj (objOf PRE_first_tail_x15_r0_body.s1353 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1352 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw140_4910 : (PRE_first_tail_x15_r0_body.s1353.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw140_2673472 : (PRE_first_tail_x15_r0_body.s1353.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw140_2673473 : (PRE_first_tail_x15_r0_body.s1353.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd140 : PRE_first_tail_x15_r0_body.cl140.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr140 : PRE_first_tail_x15_r0_body.st140.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1351.next || PRE_first_tail_x15_r0_body.cl140.contains b) = true
def PRE_first_tail_x15_r0_body.zl140 : List Nat := PRE_first_tail_x15_r0_body.cl140.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE140 : PRE_first_tail_x15_r0_body.zl140.map (fun a => PRE_first_tail_x15_r0_body.s1352.heap.get (PRE_first_tail_x15_r0_body.kappa140.a a)) = PRE_first_tail_x15_r0_body.zl140.map (fun a => (PRE_first_tail_x15_r0_body.s1353.heap.get a).map PRE_first_tail_x15_r0_body.kappa140.hobj)
theorem PRE_first_tail_x15_r0_body.zimg140 : HeapImg PRE_first_tail_x15_r0_body.kappa140 PRE_first_tail_x15_r0_body.s1353 PRE_first_tail_x15_r0_body.s1352 PRE_first_tail_x15_r0_body.zl140 := PRE_first_tail_x15_r0_body.zimgE140
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl140 : PRE_first_tail_x15_r0_body.s1352.ctl = PRE_first_tail_x15_r0_body.kappa140.ctl PRE_first_tail_x15_r0_body.s1353.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack140 : PRE_first_tail_x15_r0_body.s1352.stack = PRE_first_tail_x15_r0_body.s1353.stack.map PRE_first_tail_x15_r0_body.kappa140.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs140 : PRE_first_tail_x15_r0_body.s1352.jobs = PRE_first_tail_x15_r0_body.s1353.jobs.map PRE_first_tail_x15_r0_body.kappa140.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores140 : PRE_first_tail_x15_r0_body.s1352.stores = PRE_first_tail_x15_r0_body.kappa140.stores PRE_first_tail_x15_r0_body.s1353.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots140 : checkRootsSupp PRE_first_tail_x15_r0_body.s1353 6040 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC140 : PRE_first_tail_x15_r0_body.S1351.tab.length + PRE_first_tail_x15_r0_body.cws140.length = 6040
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap140 : PRE_first_tail_x15_r0_body.kappa140 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1351.next 2784355 PRE_first_tail_x15_r0_body.S1351.tab.length PRE_first_tail_x15_r0_body.pl140 (PRE_first_tail_x15_r0_body.nr140.map NumV.ref) PRE_first_tail_x15_r0_body.kd140.big
  PRE_first_tail_x15_r0_body.kd140.region PRE_first_tail_x15_r0_body.kd140.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin140 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1353.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc140 : Conv.jcleanListB (⟨20949, 18055, 2784336, 6040⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1353 PRE_first_tail_x15_r0_body.cl140 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB140 : noBigRootsP (fun i => !Conv.oldBigB (⟨20949, 18055, 2784336, 6040⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1353.trace PRE_first_tail_x15_r0_body.s1353 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm140 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18055 = true
theorem PRE_first_tail_x15_r0_body.cjcl140 (h : Conv.JClean (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1351) : Conv.JClean (⟨20949, 18055, 2784336, 6040⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1353 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle140)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap140 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd140 a ha)) PRE_first_tail_x15_r0_body.zjc140

end Host.Load.Run.Tpl

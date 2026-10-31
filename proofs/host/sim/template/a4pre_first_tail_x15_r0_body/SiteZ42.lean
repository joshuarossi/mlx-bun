import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS42
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK42
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF42
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 42 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s419`, the merged
state `PRE_first_tail_x15_r0_body.s420`, the canonical state `PRE_first_tail_x15_r0_body.s421`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl42 : PRE_first_tail_x15_r0_body.pl42.all (Nat.ble PRE_first_tail_x15_r0_body.s419.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd42 : nodupT PRE_first_tail_x15_r0_body.pl42 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn142 : Nat.ble PRE_first_tail_x15_r0_body.s419.next 2709374 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst42 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s419.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn42 : PRE_first_tail_x15_r0_body.s421.next = PRE_first_tail_x15_r0_body.s419.next + PRE_first_tail_x15_r0_body.pl42.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn42 : PRE_first_tail_x15_r0_body.s420.next = 2709374
kernel_rfl PRE_first_tail_x15_r0_body.zgrow42 : Nat.ble PRE_first_tail_x15_r0_body.s421.next PRE_first_tail_x15_r0_body.s420.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh42 : PRE_first_tail_x15_r0_body.S419.tab.all (fun e => PRE_first_tail_x15_r0_body.cws42.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd42 : nodupT PRE_first_tail_x15_r0_body.cws42 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi42 : PRE_first_tail_x15_r0_body.nr42.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S420.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt42 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s419.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg42_2665 : PRE_first_tail_x15_r0_body.s421.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s421 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk42_2665 : (objOf PRE_first_tail_x15_r0_body.s421 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm42_2665 : PRE_first_tail_x15_r0_body.s420.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa42.obj (objOf PRE_first_tail_x15_r0_body.s421 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s420 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg42_2673467 : PRE_first_tail_x15_r0_body.s421.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s421 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk42_2673467 : (objOf PRE_first_tail_x15_r0_body.s421 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm42_2673467 : PRE_first_tail_x15_r0_body.s420.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa42.obj (objOf PRE_first_tail_x15_r0_body.s421 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s420 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw42_4910 : (PRE_first_tail_x15_r0_body.s421.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw42_2673472 : (PRE_first_tail_x15_r0_body.s421.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw42_2673473 : (PRE_first_tail_x15_r0_body.s421.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd42 : PRE_first_tail_x15_r0_body.cl42.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr42 : PRE_first_tail_x15_r0_body.st42.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s419.next || PRE_first_tail_x15_r0_body.cl42.contains b) = true
def PRE_first_tail_x15_r0_body.zl42 : List Nat := PRE_first_tail_x15_r0_body.cl42.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE42 : PRE_first_tail_x15_r0_body.zl42.map (fun a => PRE_first_tail_x15_r0_body.s420.heap.get (PRE_first_tail_x15_r0_body.kappa42.a a)) = PRE_first_tail_x15_r0_body.zl42.map (fun a => (PRE_first_tail_x15_r0_body.s421.heap.get a).map PRE_first_tail_x15_r0_body.kappa42.hobj)
theorem PRE_first_tail_x15_r0_body.zimg42 : HeapImg PRE_first_tail_x15_r0_body.kappa42 PRE_first_tail_x15_r0_body.s421 PRE_first_tail_x15_r0_body.s420 PRE_first_tail_x15_r0_body.zl42 := PRE_first_tail_x15_r0_body.zimgE42
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl42 : PRE_first_tail_x15_r0_body.s420.ctl = PRE_first_tail_x15_r0_body.kappa42.ctl PRE_first_tail_x15_r0_body.s421.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack42 : PRE_first_tail_x15_r0_body.s420.stack = PRE_first_tail_x15_r0_body.s421.stack.map PRE_first_tail_x15_r0_body.kappa42.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs42 : PRE_first_tail_x15_r0_body.s420.jobs = PRE_first_tail_x15_r0_body.s421.jobs.map PRE_first_tail_x15_r0_body.kappa42.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores42 : PRE_first_tail_x15_r0_body.s420.stores = PRE_first_tail_x15_r0_body.kappa42.stores PRE_first_tail_x15_r0_body.s421.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots42 : checkRootsSupp PRE_first_tail_x15_r0_body.s421 1898 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC42 : PRE_first_tail_x15_r0_body.S419.tab.length + PRE_first_tail_x15_r0_body.cws42.length = 1898
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap42 : PRE_first_tail_x15_r0_body.kappa42 = Conv.Map.compact PRE_first_tail_x15_r0_body.s419.next 2709374 PRE_first_tail_x15_r0_body.S419.tab.length PRE_first_tail_x15_r0_body.pl42 (PRE_first_tail_x15_r0_body.nr42.map NumV.ref) PRE_first_tail_x15_r0_body.kd42.big
  PRE_first_tail_x15_r0_body.kd42.region PRE_first_tail_x15_r0_body.kd42.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin42 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s421.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc42 : Conv.jcleanListB (⟨19041, 16142, 2708225, 1898⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s421 PRE_first_tail_x15_r0_body.cl42 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB42 : noBigRootsP (fun i => !Conv.oldBigB (⟨19041, 16142, 2708225, 1898⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s421.trace PRE_first_tail_x15_r0_body.s421 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm42 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16115 = true
theorem PRE_first_tail_x15_r0_body.cjcl42 (h : Conv.JClean (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s419) : Conv.JClean (⟨19041, 16142, 2708225, 1898⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s421 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle42)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap42 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd42 a ha)) PRE_first_tail_x15_r0_body.zjc42

end Host.Load.Run.Tpl

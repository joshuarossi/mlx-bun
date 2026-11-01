import host.sim.template.a4pre_first_tail_x6_r0_body.m.B30
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
import host.sim.template.BootEq
import host.sim.StageRel
import host.sim.compose.a4b.VWFramesDefs
import host.sim.template.FullOk
import host.sim.template.FastOk
import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x6_r0_body.m.B00
import host.sim.conv.Compact
import host.sim.native.RebigR
import host.sim.template.Sigma
import host.sim.template.NShiftGen
import host.sim.stage.Mlx
import host.sim.conv.Closed
import host.sim.conv.NClean
import host.sim.conv.CompactFull
import host.sim.template.FootGen
import host.sim.template.a4pre_first_tail_x6_r0_body.States
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
import host.sim.conv.CallPieces
import host.sim.template.NShiftOf
import host.sim.template.FullShiftGen
import host.sim.template.EndGen

section -- SiteZ164
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 164 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s1581`, the merged
state `PRE_first_tail_x6_r0_body.s1582`, the canonical state `PRE_first_tail_x6_r0_body.s1583`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl164 : PRE_first_tail_x6_r0_body.pl164.all (Nat.ble PRE_first_tail_x6_r0_body.s1581.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd164 : nodupT PRE_first_tail_x6_r0_body.pl164 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn1164 : Nat.ble PRE_first_tail_x6_r0_body.s1581.next 2803195 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst164 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s1581.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn164 : PRE_first_tail_x6_r0_body.s1583.next = PRE_first_tail_x6_r0_body.s1581.next + PRE_first_tail_x6_r0_body.pl164.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn164 : PRE_first_tail_x6_r0_body.s1582.next = 2803195
kernel_rfl PRE_first_tail_x6_r0_body.zgrow164 : Nat.ble PRE_first_tail_x6_r0_body.s1583.next PRE_first_tail_x6_r0_body.s1582.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh164 : PRE_first_tail_x6_r0_body.S1581.tab.all (fun e => PRE_first_tail_x6_r0_body.cws164.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd164 : nodupT PRE_first_tail_x6_r0_body.cws164 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi164 : PRE_first_tail_x6_r0_body.nr164.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S1582.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt164 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s1581.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg164_2665 : PRE_first_tail_x6_r0_body.s1583.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1583 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk164_2665 : (objOf PRE_first_tail_x6_r0_body.s1583 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm164_2665 : PRE_first_tail_x6_r0_body.s1582.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa164.obj (objOf PRE_first_tail_x6_r0_body.s1583 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s1582 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg164_2673467 : PRE_first_tail_x6_r0_body.s1583.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1583 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk164_2673467 : (objOf PRE_first_tail_x6_r0_body.s1583 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm164_2673467 : PRE_first_tail_x6_r0_body.s1582.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa164.obj (objOf PRE_first_tail_x6_r0_body.s1583 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s1582 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw164_4910 : (PRE_first_tail_x6_r0_body.s1583.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw164_2673472 : (PRE_first_tail_x6_r0_body.s1583.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw164_2673473 : (PRE_first_tail_x6_r0_body.s1583.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd164 : PRE_first_tail_x6_r0_body.cl164.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr164 : PRE_first_tail_x6_r0_body.st164.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s1581.next || PRE_first_tail_x6_r0_body.cl164.contains b) = true
def PRE_first_tail_x6_r0_body.zl164 : List Nat := PRE_first_tail_x6_r0_body.cl164.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE164 : PRE_first_tail_x6_r0_body.zl164.map (fun a => PRE_first_tail_x6_r0_body.s1582.heap.get (PRE_first_tail_x6_r0_body.kappa164.a a)) = PRE_first_tail_x6_r0_body.zl164.map (fun a => (PRE_first_tail_x6_r0_body.s1583.heap.get a).map PRE_first_tail_x6_r0_body.kappa164.hobj)
theorem PRE_first_tail_x6_r0_body.zimg164 : HeapImg PRE_first_tail_x6_r0_body.kappa164 PRE_first_tail_x6_r0_body.s1583 PRE_first_tail_x6_r0_body.s1582 PRE_first_tail_x6_r0_body.zl164 := PRE_first_tail_x6_r0_body.zimgE164
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl164 : PRE_first_tail_x6_r0_body.s1582.ctl = PRE_first_tail_x6_r0_body.kappa164.ctl PRE_first_tail_x6_r0_body.s1583.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack164 : PRE_first_tail_x6_r0_body.s1582.stack = PRE_first_tail_x6_r0_body.s1583.stack.map PRE_first_tail_x6_r0_body.kappa164.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs164 : PRE_first_tail_x6_r0_body.s1582.jobs = PRE_first_tail_x6_r0_body.s1583.jobs.map PRE_first_tail_x6_r0_body.kappa164.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores164 : PRE_first_tail_x6_r0_body.s1582.stores = PRE_first_tail_x6_r0_body.kappa164.stores PRE_first_tail_x6_r0_body.s1583.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots164 : checkRootsSupp PRE_first_tail_x6_r0_body.s1583 7066 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC164 : PRE_first_tail_x6_r0_body.S1581.tab.length + PRE_first_tail_x6_r0_body.cws164.length = 7066
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap164 : PRE_first_tail_x6_r0_body.kappa164 = Conv.Map.compact PRE_first_tail_x6_r0_body.s1581.next 2803195 PRE_first_tail_x6_r0_body.S1581.tab.length PRE_first_tail_x6_r0_body.pl164 (PRE_first_tail_x6_r0_body.nr164.map NumV.ref) PRE_first_tail_x6_r0_body.kd164.big
  PRE_first_tail_x6_r0_body.kd164.region PRE_first_tail_x6_r0_body.kd164.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin164 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1583.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc164 : Conv.jcleanListB (⟨21421, 18529, 2803176, 7066⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1583 PRE_first_tail_x6_r0_body.cl164 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB164 : noBigRootsP (fun i => !Conv.oldBigB (⟨21421, 18529, 2803176, 7066⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s1583.trace PRE_first_tail_x6_r0_body.s1583 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm164 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 18529 = true
theorem PRE_first_tail_x6_r0_body.cjcl164 (h : Conv.JClean (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1581) : Conv.JClean (⟨21421, 18529, 2803176, 7066⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1583 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle164)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap164 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd164 a ha)) PRE_first_tail_x6_r0_body.zjc164

end Host.Load.Run.Tpl
end

section -- st164/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st164.bodyLast from PRE_first_tail_x6_r0_body.st164.s1 to PRE_first_tail_x6_r0_body.st164.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st164.F PRE_first_tail_x6_r0_body.st164.s1).run PRE_first_tail_x6_r0_body.st164.S1 = some (PRE_first_tail_x6_r0_body.st164.s2, PRE_first_tail_x6_r0_body.st164.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st164.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st164.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st164.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st164.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st164/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st164.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st164.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st164.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st164.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st164.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st164.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st164.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st164.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st164.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st164.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st164.s0 PRE_first_tail_x6_r0_body.st164.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st164.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st164.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st164.s1 PRE_first_tail_x6_r0_body.st164.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st164/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st164.bodyK0F from PRE_first_tail_x6_r0_body.st164.s0 to PRE_first_tail_x6_r0_body.st164.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st164.F (PRE_first_tail_x6_r0_body.st164.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st164.ks 0).getD 0) PRE_first_tail_x6_r0_body.st164.s0 PRE_first_tail_x6_r0_body.st164.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st164.s1, PRE_first_tail_x6_r0_body.st164.S1)
theorem PRE_first_tail_x6_r0_body.st164.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st164.F (PRE_first_tail_x6_r0_body.st164.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st164.ks 0).getD 0) PRE_first_tail_x6_r0_body.st164.s0 PRE_first_tail_x6_r0_body.st164.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st164.s1, PRE_first_tail_x6_r0_body.st164.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st164.bodyOkLN_ok PRE_first_tail_x6_r0_body.st164.bodyK0F
end Host.Load.Run.Tpl
end

section -- st164/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st164.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st164.F (PRE_first_tail_x6_r0_body.st164.bodyOkL bytes rows) 206 PRE_first_tail_x6_r0_body.st164.s0 PRE_first_tail_x6_r0_body.st164.S0 = some (PRE_first_tail_x6_r0_body.st164.s1, PRE_first_tail_x6_r0_body.st164.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st164.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st164.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st164.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st164.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st164.F (PRE_first_tail_x6_r0_body.st164.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st164.s0
  S0 := PRE_first_tail_x6_r0_body.st164.S0
  s1 := PRE_first_tail_x6_r0_body.st164.s1
  S1 := PRE_first_tail_x6_r0_body.st164.S1
  s2 := PRE_first_tail_x6_r0_body.st164.s2
  S2 := PRE_first_tail_x6_r0_body.st164.S2
  n := 206
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st164.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st164.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st164.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st164.bodyHalt
  last := PRE_first_tail_x6_r0_body.st164.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st164.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC165
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 165 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s1599` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa165` into the merged state
`PRE_first_tail_x6_r0_body.s1598`. -/

def PRE_first_tail_x6_r0_body.pl165 : List Nat := [2805278, 2805114, 2805166, 2805279, 2805280, 2805116, 2805168, 2805277, 2805276, 2805275, 2805274, 2805268, 2805219, 2805270, 2805221]
def PRE_first_tail_x6_r0_body.nr165 : List Nat := [7151, 7152, 7148, 7154, 7150, 7158, 7159, 7156, 7157]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd165 : RData :=
  ⟨2804931, 2805281, Stage.setAll PTrie.nil [(2804916, 2805278), (2804917, 2805114), (2804918, 2805166), (2804919, 2805279), (2804920, 2805280), (2804921, 2805116), (2804922, 2805168), (2804923, 2805277), (2804924, 2805276), (2804925, 2805275), (2804926, 2805274), (2804927, 2805268), (2804928, 2805219), (2804929, 2805270), (2804930, 2805221)], Stage.setAll PTrie.nil [(21461, 21463), (21462, 21464), (21463, 21466), (21464, 21465)],
   21465, 21467, 18563, 18563, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(7143, .ref 7151), (7144, .ref 7152), (7145, .ref 7148), (7146, .ref 7154), (7147, .ref 7150), (7148, .ref 7158), (7149, .ref 7159), (7150, .ref 7156), (7151, .ref 7157)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa165 : Map :=
  Conv.Map.compact 2804916 2805281 7143 PRE_first_tail_x6_r0_body.pl165 (PRE_first_tail_x6_r0_body.nr165.map NumV.ref) PRE_first_tail_x6_r0_body.kd165.big
    PRE_first_tail_x6_r0_body.kd165.region PRE_first_tail_x6_r0_body.kd165.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws165 : List Nat := [3790, 3791, 3792, 3793, 3794, 3795, 3796, 3797, 3798]
noncomputable def PRE_first_tail_x6_r0_body.crs165 : List SymE := PRE_first_tail_x6_r0_body.nr165.map fun r => (nth? PRE_first_tail_x6_r0_body.S1598.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta165 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws165 PRE_first_tail_x6_r0_body.crs165
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB165 : List Nat := [2665, 2672725, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab165 : PRE_first_tail_x6_r0_body.S1599.tab = PRE_first_tail_x6_r0_body.S1597.tab ++ PRE_first_tail_x6_r0_body.cws165.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace165 : PRE_first_tail_x6_r0_body.s1599.trace = PRE_first_tail_x6_r0_body.s1597.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext165 : PRE_first_tail_x6_r0_body.s1599.next = 2804931
kernel_rfl PRE_first_tail_x6_r0_body.ccounters165 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1599.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1599.ffi).mlx.nnext) = (21465, 18563)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue165 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1598.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1599.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa165.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp165 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1599.ffi).mlx.tokens.all (bSN 7152) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean165 : Conv.cleanListB 21465 131072 (fun r => Nat.ble 85860 r) PRE_first_tail_x6_r0_body.s1599
    (PRE_first_tail_x6_r0_body.wrB165 ++ (List.range 15).map (2804916 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs165 : bigsOutB 21465 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1599.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK165
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl165`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl165 : List Nat := [2665, 2672725, 2673467, 2804916, 2804917, 2804918, 2804919, 2804920, 2804921, 2804922, 2804923, 2804924, 2804925, 2804926, 2804927, 2804928, 2804929, 2804930]
def PRE_first_tail_x6_r0_body.clo165 : List Nat := [21461, 21462, 21463, 21464]
def PRE_first_tail_x6_r0_body.cln165 : List Nat := [18557, 18558, 18559, 18560, 18561, 18562]
def PRE_first_tail_x6_r0_body.cli165 : List Nat := [18557, 18558, 18559, 18560, 18561, 18562]
kernel_rfl PRE_first_tail_x6_r0_body.cheap165 : PRE_first_tail_x6_r0_body.s1599.heap = Stage.setAll PRE_first_tail_x6_r0_body.s1597.heap (PRE_first_tail_x6_r0_body.cl165.filterMap fun a => (PRE_first_tail_x6_r0_body.s1599.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe165 : Nat.ble PRE_first_tail_x6_r0_body.s1597.next PRE_first_tail_x6_r0_body.s1599.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP165 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s1597 PRE_first_tail_x6_r0_body.s1599 PRE_first_tail_x6_r0_body.cl165 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp165 : Conv.suppListB PRE_first_tail_x6_r0_body.s1599 7152 PRE_first_tail_x6_r0_body.cl165 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound165 : Conv.boundListB PRE_first_tail_x6_r0_body.s1599 PRE_first_tail_x6_r0_body.cl165 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK165 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1599.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln165.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1599.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK165 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1599.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo165.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1599.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK165 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1599.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli165.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1599.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst165 : Conv.sstListB 7152 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1599.ffi).mlx PRE_first_tail_x6_r0_body.cln165 PRE_first_tail_x6_r0_body.clo165 PRE_first_tail_x6_r0_body.cli165 = true

end Host.Load.Run.Tpl
end

section -- SiteCl165
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA165 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1599.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo165.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1599.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd165 : (PRE_first_tail_x6_r0_body.clo165 ++ PRE_first_tail_x6_r0_body.cln165 ++ PRE_first_tail_x6_r0_body.cli165).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle165 : Conv.Cnt.leB (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt) (⟨21465, 18563, 2804931, 7152⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck165 : Conv.ncleanListB (⟨21465, 18563, 2804931, 7152⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1599.ffi).mlx PRE_first_tail_x6_r0_body.clo165 PRE_first_tail_x6_r0_body.cln165 PRE_first_tail_x6_r0_body.cli165 = true
theorem PRE_first_tail_x6_r0_body.cncl165 (h : Conv.NClean (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx) : Conv.NClean (⟨21465, 18563, 2804931, 7152⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1599.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle165 PRE_first_tail_x6_r0_body.ckA165 PRE_first_tail_x6_r0_body.cobjsK165 PRE_first_tail_x6_r0_body.cnodesK165 PRE_first_tail_x6_r0_body.citemsK165 PRE_first_tail_x6_r0_body.cbd165 PRE_first_tail_x6_r0_body.cck165

end Host.Load.Run.Tpl
end

section -- SiteS165
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 165 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc165 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P165 : LoadP := PRE_first_tail_x6_r0_body.Pc165.raise 18563
kernel_rfl PRE_first_tail_x6_r0_body.craise165 : Nat.ble PRE_first_tail_x6_r0_body.Pc165.N0 18563 = true
theorem PRE_first_tail_x6_r0_body.raised165 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc165 PRE_first_tail_x6_r0_body.P165 :=
  .inr ⟨18563, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise165, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_165 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1599.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_165 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1598.ffi)
def PRE_first_tail_x6_r0_body.khinv165 : PTrie Nat := Stage.setAll PTrie.nil [(21463, 21461), (21464, 21462), (21466, 21463), (21465, 21464)]
def PRE_first_tail_x6_r0_body.kninv165 : PTrie Nat := Stage.setAll PTrie.nil [(18557, 18557), (18558, 18558), (18559, 18559), (18560, 18560), (18561, 18561), (18562, 18562)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS165 : List Nat := [21461, 21462, 21463, 21464, 21465, 21466]
def PRE_first_tail_x6_r0_body.cnS165 : List Nat := List.range' 18557 6
def PRE_first_tail_x6_r0_body.ciS165 : List Nat := [] ++ List.range' 18557 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh0165 : PRE_first_tail_x6_r0_body.kd165.nh0 = PRE_first_tail_x6_r0_body.cx0_165.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh1165 : PRE_first_tail_x6_r0_body.kd165.nh1 = PRE_first_tail_x6_r0_body.cx1_165.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn0165 : PRE_first_tail_x6_r0_body.kd165.nn0 = PRE_first_tail_x6_r0_body.cx0_165.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn1165 : PRE_first_tail_x6_r0_body.kd165.nn1 = PRE_first_tail_x6_r0_body.cx1_165.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo165 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P165.lo && Nat.ble PRE_first_tail_x6_r0_body.P165.lo PRE_first_tail_x6_r0_body.cx0_165.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P165.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P165.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt165 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_165.mlx.next PRE_first_tail_x6_r0_body.cx1_165.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_165.mlx.nnext PRE_first_tail_x6_r0_body.cx1_165.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband165 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P165.NL && Nat.ble PRE_first_tail_x6_r0_body.P165.NL PRE_first_tail_x6_r0_body.P165.N0 && Nat.ble PRE_first_tail_x6_r0_body.P165.N0 PRE_first_tail_x6_r0_body.cx0_165.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow165 : PRE_first_tail_x6_r0_body.kd165.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren165 : checkRenG PRE_first_tail_x6_r0_body.kd165.hnd PRE_first_tail_x6_r0_body.khinv165 (phB PRE_first_tail_x6_r0_body.cx0_165.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband165 : PRE_first_tail_x6_r0_body.kd165.checkBand PRE_first_tail_x6_r0_body.P165.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos165 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd165.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren165 : checkRenG PRE_first_tail_x6_r0_body.kd165.node PRE_first_tail_x6_r0_body.kninv165 (pnB PRE_first_tail_x6_r0_body.cx0_165.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow165 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd165.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P165.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd165.nodeF j) PRE_first_tail_x6_r0_body.cx1_165.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a165 : PRE_first_tail_x6_r0_body.cx0_165.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b165 : PRE_first_tail_x6_r0_body.cx0_165.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok1165 : PRE_first_tail_x6_r0_body.cx1_165.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend165 : PRE_first_tail_x6_r0_body.cx1_165.mlx.pending = PRE_first_tail_x6_r0_body.cx0_165.mlx.pending.map PRE_first_tail_x6_r0_body.kappa165.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh165 : PRE_first_tail_x6_r0_body.cx1_165.mlx.errh = PRE_first_tail_x6_r0_body.cx0_165.mlx.errh.map PRE_first_tail_x6_r0_body.kappa165.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles165 : PRE_first_tail_x6_r0_body.cx1_165.mlx.files = PRE_first_tail_x6_r0_body.cx0_165.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch165 : PRE_first_tail_x6_r0_body.cx1_165.mlx.arch = PRE_first_tail_x6_r0_body.cx0_165.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes165 : PRE_first_tail_x6_r0_body.cx1_165.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_165.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired165 : PRE_first_tail_x6_r0_body.cx1_165.mlx.wired = PRE_first_tail_x6_r0_body.cx0_165.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost165 : PRE_first_tail_x6_r0_body.cx1_165.host = PRE_first_tail_x6_r0_body.cx0_165.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd165`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn0165 : PRE_first_tail_x6_r0_body.kd165.n0 = 2804931
kernel_rfl PRE_first_tail_x6_r0_body.ckn1165 : PRE_first_tail_x6_r0_body.kd165.n1 = 2805281
kernel_rfl PRE_first_tail_x6_r0_body.ckheap165 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd165.heap).all (fun x => Nat.ble 2804916 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl165 : (List.range 15).all (fun j => decide (PRE_first_tail_x6_r0_body.kd165.heap.get (2804916 + j) = nth? PRE_first_tail_x6_r0_body.pl165 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja165 : Nat.ble 2804916 2804916 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn165 : Nat.ble 7143 7143 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD165 : Nat.ble 2804916 PRE_first_tail_x6_r0_body.kd165.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn165 : Nat.ble 21461 PRE_first_tail_x6_r0_body.kd165.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn165 : Nat.ble 18557 PRE_first_tail_x6_r0_body.kd165.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb165 : Nat.ble 21461 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap165 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd165.heap).all (Nat.ble (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd165 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd165.hnd).all (Nat.ble (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode165 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd165.node).all (Nat.ble (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix165 : Conv.FixOld (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa165 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja165) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn165) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD165) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn165) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn165) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb165) PRE_first_tail_x6_r0_body.fheap165 PRE_first_tail_x6_r0_body.fhnd165 PRE_first_tail_x6_r0_body.fnode165
kernel_rfl PRE_first_tail_x6_r0_body.fcxn165 : (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn165 : (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle0165 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_165.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_165.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk165 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd165.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A165 : PRE_first_tail_x6_r0_body.cx1_165.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS165.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_165.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O165 : PRE_first_tail_x6_r0_body.cx1_165.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS165.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_165.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N165 : PRE_first_tail_x6_r0_body.cx1_165.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS165.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_165.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I165 : PRE_first_tail_x6_r0_body.cx1_165.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS165.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_165.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd165 : (PRE_first_tail_x6_r0_body.clo165 ++ PRE_first_tail_x6_r0_body.cln165 ++ PRE_first_tail_x6_r0_body.cli165 ++ PRE_first_tail_x6_r0_body.cwS165 ++ PRE_first_tail_x6_r0_body.cnS165 ++ PRE_first_tail_x6_r0_body.ciS165).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW165 : PRE_first_tail_x6_r0_body.cwS165.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo165.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI165 : PRE_first_tail_x6_r0_body.ciS165.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli165.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN165 : PRE_first_tail_x6_r0_body.cnS165.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF165 : PRE_first_tail_x6_r0_body.cln165.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh165 : PRE_first_tail_x6_r0_body.clo165.all (handleOK PRE_first_tail_x6_r0_body.kappa165 PRE_first_tail_x6_r0_body.P165.lo PRE_first_tail_x6_r0_body.cx0_165.mlx PRE_first_tail_x6_r0_body.cx1_165.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo165 : PRE_first_tail_x6_r0_body.clo165.map (fun h => PRE_first_tail_x6_r0_body.cx1_165.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa165.handle h)) = PRE_first_tail_x6_r0_body.clo165.map (fun h => (PRE_first_tail_x6_r0_body.cx0_165.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa165.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok165 : PRE_first_tail_x6_r0_body.clo165.all (objOK PRE_first_tail_x6_r0_body.kappa165 PRE_first_tail_x6_r0_body.P165.NL PRE_first_tail_x6_r0_body.cx0_165.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd165 : PRE_first_tail_x6_r0_body.cln165.all (nodeOKF PRE_first_tail_x6_r0_body.kappa165 PRE_first_tail_x6_r0_body.P165 PRE_first_tail_x6_r0_body.cx0_165.mlx PRE_first_tail_x6_r0_body.cx1_165.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp165 : ((PRE_first_tail_x6_r0_body.cln165.filter (fullB PRE_first_tail_x6_r0_body.P165))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_165.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa165.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln165.filter (fullB PRE_first_tail_x6_r0_body.P165))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_165.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa165.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI165 : incrB PRE_first_tail_x6_r0_body.kd165.nodeF (List.range' 18557 6) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK165 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd165.node).all (fun k => Nat.ble 18557 k && Nat.blt k 18563) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL165 : (PRE_first_tail_x6_r0_body.cln165.filter (Nat.ble PRE_first_tail_x6_r0_body.P165.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd165.nodeF i) && (Nat.blt i 18563 || Nat.ble PRE_first_tail_x6_r0_body.kd165.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord165 : (PRE_first_tail_x6_r0_body.cln165.filter (Nat.ble PRE_first_tail_x6_r0_body.P165.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd165.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd165.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd165.nodeF j) (PRE_first_tail_x6_r0_body.kd165.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow165 PRE_first_tail_x6_r0_body.cnn1165 PRE_first_tail_x6_r0_body.fnordI165 PRE_first_tail_x6_r0_body.fnordK165 PRE_first_tail_x6_r0_body.fnordL165
kernel_rfl PRE_first_tail_x6_r0_body.fi165 : PRE_first_tail_x6_r0_body.cli165.all (pnB PRE_first_tail_x6_r0_body.cx0_165.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii165 : PRE_first_tail_x6_r0_body.cli165.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_165.mlx.items.get (PRE_first_tail_x6_r0_body.kappa165.node k) = (PRE_first_tail_x6_r0_body.cx0_165.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa165.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot165 (clean : Conv.NClean (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P165.NL) (cl : SSt (· < 7152) PRE_first_tail_x6_r0_body.cx0_165.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P165 7152 PRE_first_tail_x6_r0_body.kappa165 PRE_first_tail_x6_r0_body.kd165 PRE_first_tail_x6_r0_body.khinv165 PRE_first_tail_x6_r0_body.kninv165 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx PRE_first_tail_x6_r0_body.cx0_165.mlx PRE_first_tail_x6_r0_body.cx1_165.mlx (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo165 PRE_first_tail_x6_r0_body.cln165 PRE_first_tail_x6_r0_body.cli165 PRE_first_tail_x6_r0_body.cwS165 PRE_first_tail_x6_r0_body.cnS165 PRE_first_tail_x6_r0_body.ciS165 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh0165, PRE_first_tail_x6_r0_body.cnh1165, PRE_first_tail_x6_r0_body.cnn0165, PRE_first_tail_x6_r0_body.cnn1165, PRE_first_tail_x6_r0_body.cplo165, PRE_first_tail_x6_r0_body.ccnt165, PRE_first_tail_x6_r0_body.cnband165, PRE_first_tail_x6_r0_body.chbelow165, PRE_first_tail_x6_r0_body.chren165, PRE_first_tail_x6_r0_body.cband165, PRE_first_tail_x6_r0_body.cnh1pos165, PRE_first_tail_x6_r0_body.cnren165, PRE_first_tail_x6_r0_body.cnlow165, PRE_first_tail_x6_r0_body.cabs0a165, PRE_first_tail_x6_r0_body.cabs0b165, PRE_first_tail_x6_r0_body.ctok1165, PRE_first_tail_x6_r0_body.cpend165, PRE_first_tail_x6_r0_body.cerrh165, PRE_first_tail_x6_r0_body.cfiles165, PRE_first_tail_x6_r0_body.carch165, PRE_first_tail_x6_r0_body.csizes165, PRE_first_tail_x6_r0_body.cwired165, PRE_first_tail_x6_r0_body.cfix165, clean, PRE_first_tail_x6_r0_body.fcxn165, PRE_first_tail_x6_r0_body.fcnn165, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle0165, PRE_first_tail_x6_r0_body.fnk165, PRE_first_tail_x6_r0_body.ckA165, PRE_first_tail_x6_r0_body.cobjsK165, PRE_first_tail_x6_r0_body.cnodesK165, PRE_first_tail_x6_r0_body.citemsK165, PRE_first_tail_x6_r0_body.f1A165, PRE_first_tail_x6_r0_body.f1O165, PRE_first_tail_x6_r0_body.f1N165, PRE_first_tail_x6_r0_body.f1I165, PRE_first_tail_x6_r0_body.fbd165, PRE_first_tail_x6_r0_body.fincW165, PRE_first_tail_x6_r0_body.fincI165, PRE_first_tail_x6_r0_body.fincN165, PRE_first_tail_x6_r0_body.flnF165, PRE_first_tail_x6_r0_body.fh165, PRE_first_tail_x6_r0_body.fo165, PRE_first_tail_x6_r0_body.fok165, PRE_first_tail_x6_r0_body.fnd165, PRE_first_tail_x6_r0_body.fp165, PRE_first_tail_x6_r0_body.fnord165, PRE_first_tail_x6_r0_body.fi165, PRE_first_tail_x6_r0_body.fii165⟩
theorem PRE_first_tail_x6_r0_body.cnshift165 (clean : Conv.NClean (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P165.NL) (cl : SSt (· < 7152) PRE_first_tail_x6_r0_body.cx0_165.mlx) : NShift PRE_first_tail_x6_r0_body.P165 7152 PRE_first_tail_x6_r0_body.kappa165 PRE_first_tail_x6_r0_body.cx0_165 PRE_first_tail_x6_r0_body.cx1_165 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot165 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost165 (compact_a_eq PRE_first_tail_x6_r0_body.ckn0165 PRE_first_tail_x6_r0_body.ckn1165 PRE_first_tail_x6_r0_body.ckheap165 PRE_first_tail_x6_r0_body.ckpl165)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_165 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1597.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_165 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1597.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_165 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1597.ffi) = some PRE_first_tail_x6_r0_body.fxC_165
kernel_rfl PRE_first_tail_x6_r0_body.okrC_165 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1597.ffi) = some PRE_first_tail_x6_r0_body.krC_165
noncomputable def PRE_first_tail_x6_r0_body.fx0_165 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1599.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_165 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1599.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_165 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1599.ffi) = some PRE_first_tail_x6_r0_body.fx0_165
kernel_rfl PRE_first_tail_x6_r0_body.okr0_165 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1599.ffi) = some PRE_first_tail_x6_r0_body.kr0_165
noncomputable def PRE_first_tail_x6_r0_body.fx1_165 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1598.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_165 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1598.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_165 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1598.ffi) = some PRE_first_tail_x6_r0_body.fx1_165
kernel_rfl PRE_first_tail_x6_r0_body.okr1_165 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1598.ffi) = some PRE_first_tail_x6_r0_body.kr1_165
kernel_rfl PRE_first_tail_x6_r0_body.ff0165 : PRE_first_tail_x6_r0_body.fx0_165 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_165 (PRE_first_tail_x6_r0_body.clo165.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_165.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff1165 : PRE_first_tail_x6_r0_body.fx1_165 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_165 (PRE_first_tail_x6_r0_body.cwS165.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_165.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck165 : freedLB PRE_first_tail_x6_r0_body.kappa165 PRE_first_tail_x6_r0_body.cx0_165.mlx PRE_first_tail_x6_r0_body.fx0_165 PRE_first_tail_x6_r0_body.fx1_165 PRE_first_tail_x6_r0_body.clo165 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf0165 : PRE_first_tail_x6_r0_body.kr0_165.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_165.flags (PRE_first_tail_x6_r0_body.clo165.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_165.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt0165 : PRE_first_tail_x6_r0_body.kr0_165.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_165.targs (PRE_first_tail_x6_r0_body.clo165.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_165.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf1165 : PRE_first_tail_x6_r0_body.kr1_165.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_165.flags (PRE_first_tail_x6_r0_body.cwS165.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_165.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt1165 : PRE_first_tail_x6_r0_body.kr1_165.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_165.targs (PRE_first_tail_x6_r0_body.cwS165.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_165.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck165 : krecLB PRE_first_tail_x6_r0_body.kappa165 7152 PRE_first_tail_x6_r0_body.cx0_165.mlx PRE_first_tail_x6_r0_body.kr0_165 PRE_first_tail_x6_r0_body.kr1_165 PRE_first_tail_x6_r0_body.clo165 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn165 : Nat.ble 7143 7152 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge165 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1598.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1599.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR165 : pendRegB PRE_first_tail_x6_r0_body.kappa165 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1599.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe165 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1599.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1598.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift165 (clean : Conv.NClean (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P165.NL) (cl : SSt (· < 7152) PRE_first_tail_x6_r0_body.cx0_165.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_165.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_165.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_165.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1597.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_165.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P165 7152 PRE_first_tail_x6_r0_body.kappa165 PRE_first_tail_x6_r0_body.s1599.ffi PRE_first_tail_x6_r0_body.s1598.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift165 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue165, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp165 t ht),
    PRE_first_tail_x6_r0_body.cbridge165,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1599.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1598.ffi) (PRE_first_tail_x6_r0_body.cfoot165 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_165 PRE_first_tail_x6_r0_body.ofx1_165 hobjC PRE_first_tail_x6_r0_body.ff0165 PRE_first_tail_x6_r0_body.ff1165 PRE_first_tail_x6_r0_body.ffck165,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1599.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1598.ffi) (PRE_first_tail_x6_r0_body.cfoot165 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_165 PRE_first_tail_x6_r0_body.okr1_165 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn165) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf0165 PRE_first_tail_x6_r0_body.fkt0165 PRE_first_tail_x6_r0_body.fkf1165 PRE_first_tail_x6_r0_body.fkt1165 PRE_first_tail_x6_r0_body.fkck165,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh0165 PRE_first_tail_x6_r0_body.cnh1165 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe165) PRE_first_tail_x6_r0_body.cpendR165⟩

end Host.Load.Run.Tpl
end

section -- st165/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st165 0
host_stream_state PRE_first_tail_x6_r0_body.st165 1
host_stream_state PRE_first_tail_x6_r0_body.st165 2
host_stream_state PRE_first_tail_x6_r0_body.st165 3
end Host.Load.Run.Tpl
end

section -- Site165
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 165 of chain `PRE_first_tail_x6_r0_body`: `kvW__g165__g166` (`appendWindow`), the call state `PRE_first_tail_x6_r0_body.s1597`, the merged state `PRE_first_tail_x6_r0_body.s1598`,
the site template `PRE_first_tail_x6_r0_body.st165` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s1599`: the merge.
The footprint's facts are in `SiteF165`, the compaction's in `SiteC165`, `SiteK165`, `SiteNa165`, `SiteNb165`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso165 : PRE_first_tail_x6_r0_body.st165.s0 = { PRE_first_tail_x6_r0_body.s1597 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs165 : List Frame := PRE_first_tail_x6_r0_body.s1597.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_165 : PRE_first_tail_x6_r0_body.S1597.tab.length = 7143
kernel_rfl PRE_first_tail_x6_r0_body.tab0_165 : PRE_first_tail_x6_r0_body.st165.S0.tab = PRE_first_tail_x6_r0_body.S1597.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws165 : List Nat := [3773, 3774, 3775, 3776, 3777, 3778, 3779, 3780, 3781, 3782, 3783, 3784, 3785, 3786, 3787, 3788, 3789]
kernel_rfl PRE_first_tail_x6_r0_body.fresh165 : (PRE_first_tail_x6_r0_body.S1597.tab.all fun e => PRE_first_tail_x6_r0_body.ws165.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S1597.oracle.all fun q => PRE_first_tail_x6_r0_body.ws165.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab165 : PRE_first_tail_x6_r0_body.S1598.tab = PRE_first_tail_x6_r0_body.S1597.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws165
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen165 : PRE_first_tail_x6_r0_body.st165.S3.tab.length - PRE_first_tail_x6_r0_body.st165.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged165`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap165 : PRE_first_tail_x6_r0_body.s1598.heap = PRE_first_tail_x6_r0_body.st165.s3.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext165 : PRE_first_tail_x6_r0_body.s1598.next = PRE_first_tail_x6_r0_body.st165.s3.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl165 : PRE_first_tail_x6_r0_body.s1598.ctl = PRE_first_tail_x6_r0_body.st165.s3.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack165 : PRE_first_tail_x6_r0_body.s1598.stack = PRE_first_tail_x6_r0_body.st165.s3.stack ++ PRE_first_tail_x6_r0_body.s1597.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs165 : PRE_first_tail_x6_r0_body.s1598.jobs = PRE_first_tail_x6_r0_body.st165.s3.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi165 : PRE_first_tail_x6_r0_body.s1598.ffi = PRE_first_tail_x6_r0_body.st165.s3.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace165 : PRE_first_tail_x6_r0_body.s1598.trace = PRE_first_tail_x6_r0_body.st165.s3.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores165 : PRE_first_tail_x6_r0_body.s1598.stores = PRE_first_tail_x6_r0_body.st165.s3.stores

end Host.Load.Run.Tpl
end

section -- SiteD165
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 165 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived165 : PRE_first_tail_x6_r0_body.nr165.map (fun r => nth? PRE_first_tail_x6_r0_body.st165.S3.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false)))]
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo165 : PRE_first_tail_x6_r0_body.nr165.all (Nat.ble 7143) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj165 : PRE_first_tail_x6_r0_body.cws165.all (fun c => !PRE_first_tail_x6_r0_body.ws165.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ165 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws165 PRE_first_tail_x6_r0_body.crs165 PRE_first_tail_x6_r0_body.ws165

end Host.Load.Run.Tpl
end

section -- st165/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st165`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st165.wrR : List (Nat × Nat) := [(2672725, 2672726)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st165.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st165.s3.heap PRE_first_tail_x6_r0_body.st165.wrR ++ freshOf PRE_first_tail_x6_r0_body.st165.s3.heap PRE_first_tail_x6_r0_body.st165.s0.next PRE_first_tail_x6_r0_body.st165.s3.next
noncomputable def PRE_first_tail_x6_r0_body.st165.wr : List Nat := PRE_first_tail_x6_r0_body.st165.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st165.heapFoot : PRE_first_tail_x6_r0_body.st165.s3.heap = setAll PRE_first_tail_x6_r0_body.st165.s0.heap PRE_first_tail_x6_r0_body.st165.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st165.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st165.s0.next PRE_first_tail_x6_r0_body.st165.s3.next = true
theorem PRE_first_tail_x6_r0_body.st165.grows : PRE_first_tail_x6_r0_body.st165.s0.next ≤ PRE_first_tail_x6_r0_body.st165.s3.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st165.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st165.wh : List Nat := [21461, 21462, 21463, 21464, 21465, 21466]
def PRE_first_tail_x6_r0_body.st165.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st165.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st165.s3.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st165.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st165.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st165.s3.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st165.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st165.s3.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st165.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st165.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st165.s3.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st165.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st165.s3.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st165.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st165.s3.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st165.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st165.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st165.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st165.s3.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st165.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st165.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st165.s3.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st165.s3.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st165.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st165.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st165.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st165.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st165.s3.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st165.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st165.s3.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF165
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 165 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB165 : nodupT PRE_first_tail_x6_r0_body.st165.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup165 : PRE_first_tail_x6_r0_body.st165.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB165).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB165 : PRE_first_tail_x6_r0_body.st165.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound165 : ∀ b ∈ PRE_first_tail_x6_r0_body.st165.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB165 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr165 := PRE_first_tail_x6_r0_body.st165.s3.trace.take 26
kernel_rfl PRE_first_tail_x6_r0_body.traceEq165 : PRE_first_tail_x6_r0_body.st165.s3.trace = PRE_first_tail_x6_r0_body.trFr165 ++ PRE_first_tail_x6_r0_body.st165.s0.trace
theorem PRE_first_tail_x6_r0_body.trace165 : ∃ fr, PRE_first_tail_x6_r0_body.st165.s3.trace = fr ++ PRE_first_tail_x6_r0_body.st165.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq165⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide165 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB165 : (PRE_first_tail_x6_r0_body.wide165.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st165.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix165 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide165, WFix Map.id (Present PRE_first_tail_x6_r0_body.st165.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB165 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL165
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 165 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s1598`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO165 : PRE_first_tail_x6_r0_body.st165.S0.oracle = PRE_first_tail_x6_r0_body.st165.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B165 : PRE_first_tail_x6_r0_body.st165.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st165.s0.next || (PRE_first_tail_x6_r0_body.st165.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot165 : Conv.StageFoot PRE_first_tail_x6_r0_body.st165.wr PRE_first_tail_x6_r0_body.st165.s0 PRE_first_tail_x6_r0_body.st165.s3 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st165.heapFoot PRE_first_tail_x6_r0_body.wrNodup165 PRE_first_tail_x6_r0_body.wrBound165 PRE_first_tail_x6_r0_body.wr0B165 PRE_first_tail_x6_r0_body.st165.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged165 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st165.F.S → PRE_first_tail_x6_r0_body.st165.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st165.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st165.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs165 PRE_first_tail_x6_r0_body.st165.wr PRE_first_tail_x6_r0_body.s1597 PRE_first_tail_x6_r0_body.st165.s3 PRE_first_tail_x6_r0_body.st165.s0
      PRE_first_tail_x6_r0_body.st165.s3.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st165.F FR W stk M ν K PRE_first_tail_x6_r0_body.s1598 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso165 PRE_first_tail_x6_r0_body.stFoot165 PRE_first_tail_x6_r0_body.wrNodup165 PRE_first_tail_x6_r0_body.wrBound165 PRE_first_tail_x6_r0_body.trace165 PRE_first_tail_x6_r0_body.mheap165
    PRE_first_tail_x6_r0_body.mnext165 PRE_first_tail_x6_r0_body.mctl165 PRE_first_tail_x6_r0_body.mstack165 PRE_first_tail_x6_r0_body.mjobs165 PRE_first_tail_x6_r0_body.mffi165 PRE_first_tail_x6_r0_body.mtrace165 PRE_first_tail_x6_r0_body.mstores165 h

def PRE_first_tail_x6_r0_body.arrEl165_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE165_2665 : arrOf PRE_first_tail_x6_r0_body.s1598 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl165_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA165_2665 : isArrB PRE_first_tail_x6_r0_body.s1598 2665 = true
theorem PRE_first_tail_x6_r0_body.arr165_2665 : ∃ o, PRE_first_tail_x6_r0_body.s1598.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl165_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE165_2665 PRE_first_tail_x6_r0_body.arrA165_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN165_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl165_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR165_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl165_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN165_2665

def PRE_first_tail_x6_r0_body.arrEl165_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE165_2673467 : arrOf PRE_first_tail_x6_r0_body.s1598 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl165_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA165_2673467 : isArrB PRE_first_tail_x6_r0_body.s1598 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr165_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s1598.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl165_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE165_2673467 PRE_first_tail_x6_r0_body.arrA165_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN165_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl165_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR165_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl165_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN165_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k165 : isArrB PRE_first_tail_x6_r0_body.s1598 4910 = false
theorem PRE_first_tail_x6_r0_body.keep165 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s1598 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k165 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr165_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl165_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ165
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 165 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s1597`, the merged
state `PRE_first_tail_x6_r0_body.s1598`, the canonical state `PRE_first_tail_x6_r0_body.s1599`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl165 : PRE_first_tail_x6_r0_body.pl165.all (Nat.ble PRE_first_tail_x6_r0_body.s1597.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd165 : nodupT PRE_first_tail_x6_r0_body.pl165 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn1165 : Nat.ble PRE_first_tail_x6_r0_body.s1597.next 2805281 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst165 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s1597.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn165 : PRE_first_tail_x6_r0_body.s1599.next = PRE_first_tail_x6_r0_body.s1597.next + PRE_first_tail_x6_r0_body.pl165.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn165 : PRE_first_tail_x6_r0_body.s1598.next = 2805281
kernel_rfl PRE_first_tail_x6_r0_body.zgrow165 : Nat.ble PRE_first_tail_x6_r0_body.s1599.next PRE_first_tail_x6_r0_body.s1598.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh165 : PRE_first_tail_x6_r0_body.S1597.tab.all (fun e => PRE_first_tail_x6_r0_body.cws165.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd165 : nodupT PRE_first_tail_x6_r0_body.cws165 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi165 : PRE_first_tail_x6_r0_body.nr165.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S1598.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt165 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s1597.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg165_2665 : PRE_first_tail_x6_r0_body.s1599.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1599 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk165_2665 : (objOf PRE_first_tail_x6_r0_body.s1599 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm165_2665 : PRE_first_tail_x6_r0_body.s1598.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa165.obj (objOf PRE_first_tail_x6_r0_body.s1599 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s1598 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg165_2673467 : PRE_first_tail_x6_r0_body.s1599.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1599 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk165_2673467 : (objOf PRE_first_tail_x6_r0_body.s1599 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm165_2673467 : PRE_first_tail_x6_r0_body.s1598.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa165.obj (objOf PRE_first_tail_x6_r0_body.s1599 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s1598 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw165_4910 : (PRE_first_tail_x6_r0_body.s1599.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw165_2673472 : (PRE_first_tail_x6_r0_body.s1599.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw165_2673473 : (PRE_first_tail_x6_r0_body.s1599.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd165 : PRE_first_tail_x6_r0_body.cl165.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr165 : PRE_first_tail_x6_r0_body.st165.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s1597.next || PRE_first_tail_x6_r0_body.cl165.contains b) = true
def PRE_first_tail_x6_r0_body.zl165 : List Nat := PRE_first_tail_x6_r0_body.cl165.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE165 : PRE_first_tail_x6_r0_body.zl165.map (fun a => PRE_first_tail_x6_r0_body.s1598.heap.get (PRE_first_tail_x6_r0_body.kappa165.a a)) = PRE_first_tail_x6_r0_body.zl165.map (fun a => (PRE_first_tail_x6_r0_body.s1599.heap.get a).map PRE_first_tail_x6_r0_body.kappa165.hobj)
theorem PRE_first_tail_x6_r0_body.zimg165 : HeapImg PRE_first_tail_x6_r0_body.kappa165 PRE_first_tail_x6_r0_body.s1599 PRE_first_tail_x6_r0_body.s1598 PRE_first_tail_x6_r0_body.zl165 := PRE_first_tail_x6_r0_body.zimgE165
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl165 : PRE_first_tail_x6_r0_body.s1598.ctl = PRE_first_tail_x6_r0_body.kappa165.ctl PRE_first_tail_x6_r0_body.s1599.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack165 : PRE_first_tail_x6_r0_body.s1598.stack = PRE_first_tail_x6_r0_body.s1599.stack.map PRE_first_tail_x6_r0_body.kappa165.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs165 : PRE_first_tail_x6_r0_body.s1598.jobs = PRE_first_tail_x6_r0_body.s1599.jobs.map PRE_first_tail_x6_r0_body.kappa165.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores165 : PRE_first_tail_x6_r0_body.s1598.stores = PRE_first_tail_x6_r0_body.kappa165.stores PRE_first_tail_x6_r0_body.s1599.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots165 : checkRootsSupp PRE_first_tail_x6_r0_body.s1599 7152 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC165 : PRE_first_tail_x6_r0_body.S1597.tab.length + PRE_first_tail_x6_r0_body.cws165.length = 7152
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap165 : PRE_first_tail_x6_r0_body.kappa165 = Conv.Map.compact PRE_first_tail_x6_r0_body.s1597.next 2805281 PRE_first_tail_x6_r0_body.S1597.tab.length PRE_first_tail_x6_r0_body.pl165 (PRE_first_tail_x6_r0_body.nr165.map NumV.ref) PRE_first_tail_x6_r0_body.kd165.big
  PRE_first_tail_x6_r0_body.kd165.region PRE_first_tail_x6_r0_body.kd165.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin165 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1599.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc165 : Conv.jcleanListB (⟨21465, 18563, 2804931, 7152⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1599 PRE_first_tail_x6_r0_body.cl165 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB165 : noBigRootsP (fun i => !Conv.oldBigB (⟨21465, 18563, 2804931, 7152⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s1599.trace PRE_first_tail_x6_r0_body.s1599 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm165 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 18557 = true
theorem PRE_first_tail_x6_r0_body.cjcl165 (h : Conv.JClean (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1597) : Conv.JClean (⟨21465, 18563, 2804931, 7152⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1599 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle165)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap165 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd165 a ha)) PRE_first_tail_x6_r0_body.zjc165

end Host.Load.Run.Tpl
end

section -- st165/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st165.bodyLast from PRE_first_tail_x6_r0_body.st165.s2 to PRE_first_tail_x6_r0_body.st165.s3 :
  interpS (step PRE_first_tail_x6_r0_body.st165.F PRE_first_tail_x6_r0_body.st165.s2).run PRE_first_tail_x6_r0_body.st165.S2 = some (PRE_first_tail_x6_r0_body.st165.s3, PRE_first_tail_x6_r0_body.st165.S3)
kernel_rfl PRE_first_tail_x6_r0_body.st165.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st165.s2.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st165.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st165.s3.stack = true

end Host.Load.Run.Tpl
end

section -- st165/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st165.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st165.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st165.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st165.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st165.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st165.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st165.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st165.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st165.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st165.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st165.s0 PRE_first_tail_x6_r0_body.st165.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st165.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st165.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st165.s2 PRE_first_tail_x6_r0_body.st165.S2) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st165/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st165.bodyK0F from PRE_first_tail_x6_r0_body.st165.s0 to PRE_first_tail_x6_r0_body.st165.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st165.F (PRE_first_tail_x6_r0_body.st165.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st165.ks 0).getD 0) PRE_first_tail_x6_r0_body.st165.s0 PRE_first_tail_x6_r0_body.st165.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st165.s1, PRE_first_tail_x6_r0_body.st165.S1)
theorem PRE_first_tail_x6_r0_body.st165.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st165.F (PRE_first_tail_x6_r0_body.st165.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st165.ks 0).getD 0) PRE_first_tail_x6_r0_body.st165.s0 PRE_first_tail_x6_r0_body.st165.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st165.s1, PRE_first_tail_x6_r0_body.st165.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st165.bodyOkLN_ok PRE_first_tail_x6_r0_body.st165.bodyK0F
end Host.Load.Run.Tpl
end

section -- st165/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st165.bodyK1F from PRE_first_tail_x6_r0_body.st165.s1 to PRE_first_tail_x6_r0_body.st165.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st165.F (PRE_first_tail_x6_r0_body.st165.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st165.ks 1).getD 0) PRE_first_tail_x6_r0_body.st165.s1 PRE_first_tail_x6_r0_body.st165.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st165.s2, PRE_first_tail_x6_r0_body.st165.S2)
theorem PRE_first_tail_x6_r0_body.st165.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st165.F (PRE_first_tail_x6_r0_body.st165.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st165.ks 1).getD 0) PRE_first_tail_x6_r0_body.st165.s1 PRE_first_tail_x6_r0_body.st165.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st165.s2, PRE_first_tail_x6_r0_body.st165.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st165.bodyOkLN_ok PRE_first_tail_x6_r0_body.st165.bodyK1F
end Host.Load.Run.Tpl
end

section -- st165/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st165.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st165.F (PRE_first_tail_x6_r0_body.st165.bodyOkL bytes rows) 3452 PRE_first_tail_x6_r0_body.st165.s0 PRE_first_tail_x6_r0_body.st165.S0 = some (PRE_first_tail_x6_r0_body.st165.s2, PRE_first_tail_x6_r0_body.st165.S2) :=
  runOk_trans PRE_first_tail_x6_r0_body.st165.F (PRE_first_tail_x6_r0_body.st165.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st165.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st165.ks 1).getD 0) PRE_first_tail_x6_r0_body.st165.s0 PRE_first_tail_x6_r0_body.st165.s1 PRE_first_tail_x6_r0_body.st165.s2 PRE_first_tail_x6_r0_body.st165.S0 PRE_first_tail_x6_r0_body.st165.S1 PRE_first_tail_x6_r0_body.st165.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st165.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st165.bodyK1 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st165.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st165.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st165.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st165.F (PRE_first_tail_x6_r0_body.st165.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st165.s0
  S0 := PRE_first_tail_x6_r0_body.st165.S0
  s1 := PRE_first_tail_x6_r0_body.st165.s2
  S1 := PRE_first_tail_x6_r0_body.st165.S2
  s2 := PRE_first_tail_x6_r0_body.st165.s3
  S2 := PRE_first_tail_x6_r0_body.st165.S3
  n := 3452
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st165.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st165.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st165.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st165.bodyHalt
  last := PRE_first_tail_x6_r0_body.st165.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st165.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC166
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 166 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s1607` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa166` into the merged state
`PRE_first_tail_x6_r0_body.s1606`. -/

def PRE_first_tail_x6_r0_body.pl166 : List Nat := []
def PRE_first_tail_x6_r0_body.nr166 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd166 : RData :=
  ⟨2805513, 2805515, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21478, 21478, 18573, 18573, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa166 : Map :=
  Conv.Map.compact 2805513 2805515 7175 PRE_first_tail_x6_r0_body.pl166 (PRE_first_tail_x6_r0_body.nr166.map NumV.ref) PRE_first_tail_x6_r0_body.kd166.big
    PRE_first_tail_x6_r0_body.kd166.region PRE_first_tail_x6_r0_body.kd166.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws166 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs166 : List SymE := PRE_first_tail_x6_r0_body.nr166.map fun r => (nth? PRE_first_tail_x6_r0_body.S1606.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta166 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws166 PRE_first_tail_x6_r0_body.crs166
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB166 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab166 : PRE_first_tail_x6_r0_body.S1607.tab = PRE_first_tail_x6_r0_body.S1605.tab ++ PRE_first_tail_x6_r0_body.cws166.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace166 : PRE_first_tail_x6_r0_body.s1607.trace = PRE_first_tail_x6_r0_body.s1605.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext166 : PRE_first_tail_x6_r0_body.s1607.next = 2805513
kernel_rfl PRE_first_tail_x6_r0_body.ccounters166 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1607.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1607.ffi).mlx.nnext) = (21478, 18573)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue166 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1606.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1607.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa166.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp166 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1607.ffi).mlx.tokens.all (bSN 7175) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean166 : Conv.cleanListB 21478 131072 (fun r => Nat.ble 85912 r) PRE_first_tail_x6_r0_body.s1607
    (PRE_first_tail_x6_r0_body.wrB166 ++ (List.range 0).map (2805513 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs166 : bigsOutB 21478 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1607.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK166
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl166`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl166 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo166 : List Nat := []
def PRE_first_tail_x6_r0_body.cln166 : List Nat := []
def PRE_first_tail_x6_r0_body.cli166 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap166 : PRE_first_tail_x6_r0_body.s1607.heap = Stage.setAll PRE_first_tail_x6_r0_body.s1605.heap (PRE_first_tail_x6_r0_body.cl166.filterMap fun a => (PRE_first_tail_x6_r0_body.s1607.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe166 : Nat.ble PRE_first_tail_x6_r0_body.s1605.next PRE_first_tail_x6_r0_body.s1607.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP166 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s1605 PRE_first_tail_x6_r0_body.s1607 PRE_first_tail_x6_r0_body.cl166 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp166 : Conv.suppListB PRE_first_tail_x6_r0_body.s1607 7175 PRE_first_tail_x6_r0_body.cl166 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound166 : Conv.boundListB PRE_first_tail_x6_r0_body.s1607 PRE_first_tail_x6_r0_body.cl166 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK166 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1607.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln166.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1607.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK166 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1607.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo166.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1607.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK166 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1607.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli166.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1607.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst166 : Conv.sstListB 7175 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1607.ffi).mlx PRE_first_tail_x6_r0_body.cln166 PRE_first_tail_x6_r0_body.clo166 PRE_first_tail_x6_r0_body.cli166 = true

end Host.Load.Run.Tpl
end

section -- SiteCl166
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA166 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1607.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo166.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1607.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd166 : (PRE_first_tail_x6_r0_body.clo166 ++ PRE_first_tail_x6_r0_body.cln166 ++ PRE_first_tail_x6_r0_body.cli166).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle166 : Conv.Cnt.leB (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck166 : Conv.ncleanListB (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1607.ffi).mlx PRE_first_tail_x6_r0_body.clo166 PRE_first_tail_x6_r0_body.cln166 PRE_first_tail_x6_r0_body.cli166 = true
theorem PRE_first_tail_x6_r0_body.cncl166 (h : Conv.NClean (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx) : Conv.NClean (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1607.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle166 PRE_first_tail_x6_r0_body.ckA166 PRE_first_tail_x6_r0_body.cobjsK166 PRE_first_tail_x6_r0_body.cnodesK166 PRE_first_tail_x6_r0_body.citemsK166 PRE_first_tail_x6_r0_body.cbd166 PRE_first_tail_x6_r0_body.cck166

end Host.Load.Run.Tpl
end

section -- SiteS166
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 166 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc166 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P166 : LoadP := PRE_first_tail_x6_r0_body.Pc166.raise 18573
kernel_rfl PRE_first_tail_x6_r0_body.craise166 : Nat.ble PRE_first_tail_x6_r0_body.Pc166.N0 18573 = true
theorem PRE_first_tail_x6_r0_body.raised166 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc166 PRE_first_tail_x6_r0_body.P166 :=
  .inr ⟨18573, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise166, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_166 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1607.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_166 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1606.ffi)
def PRE_first_tail_x6_r0_body.khinv166 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv166 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS166 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS166 : List Nat := List.range' 18573 0
def PRE_first_tail_x6_r0_body.ciS166 : List Nat := [] ++ List.range' 18573 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh0166 : PRE_first_tail_x6_r0_body.kd166.nh0 = PRE_first_tail_x6_r0_body.cx0_166.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh1166 : PRE_first_tail_x6_r0_body.kd166.nh1 = PRE_first_tail_x6_r0_body.cx1_166.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn0166 : PRE_first_tail_x6_r0_body.kd166.nn0 = PRE_first_tail_x6_r0_body.cx0_166.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn1166 : PRE_first_tail_x6_r0_body.kd166.nn1 = PRE_first_tail_x6_r0_body.cx1_166.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo166 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P166.lo && Nat.ble PRE_first_tail_x6_r0_body.P166.lo PRE_first_tail_x6_r0_body.cx0_166.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P166.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P166.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt166 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_166.mlx.next PRE_first_tail_x6_r0_body.cx1_166.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_166.mlx.nnext PRE_first_tail_x6_r0_body.cx1_166.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband166 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P166.NL && Nat.ble PRE_first_tail_x6_r0_body.P166.NL PRE_first_tail_x6_r0_body.P166.N0 && Nat.ble PRE_first_tail_x6_r0_body.P166.N0 PRE_first_tail_x6_r0_body.cx0_166.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow166 : PRE_first_tail_x6_r0_body.kd166.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren166 : checkRenG PRE_first_tail_x6_r0_body.kd166.hnd PRE_first_tail_x6_r0_body.khinv166 (phB PRE_first_tail_x6_r0_body.cx0_166.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband166 : PRE_first_tail_x6_r0_body.kd166.checkBand PRE_first_tail_x6_r0_body.P166.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos166 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd166.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren166 : checkRenG PRE_first_tail_x6_r0_body.kd166.node PRE_first_tail_x6_r0_body.kninv166 (pnB PRE_first_tail_x6_r0_body.cx0_166.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow166 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd166.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P166.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd166.nodeF j) PRE_first_tail_x6_r0_body.cx1_166.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a166 : PRE_first_tail_x6_r0_body.cx0_166.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b166 : PRE_first_tail_x6_r0_body.cx0_166.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok1166 : PRE_first_tail_x6_r0_body.cx1_166.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend166 : PRE_first_tail_x6_r0_body.cx1_166.mlx.pending = PRE_first_tail_x6_r0_body.cx0_166.mlx.pending.map PRE_first_tail_x6_r0_body.kappa166.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh166 : PRE_first_tail_x6_r0_body.cx1_166.mlx.errh = PRE_first_tail_x6_r0_body.cx0_166.mlx.errh.map PRE_first_tail_x6_r0_body.kappa166.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles166 : PRE_first_tail_x6_r0_body.cx1_166.mlx.files = PRE_first_tail_x6_r0_body.cx0_166.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch166 : PRE_first_tail_x6_r0_body.cx1_166.mlx.arch = PRE_first_tail_x6_r0_body.cx0_166.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes166 : PRE_first_tail_x6_r0_body.cx1_166.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_166.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired166 : PRE_first_tail_x6_r0_body.cx1_166.mlx.wired = PRE_first_tail_x6_r0_body.cx0_166.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost166 : PRE_first_tail_x6_r0_body.cx1_166.host = PRE_first_tail_x6_r0_body.cx0_166.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd166`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn0166 : PRE_first_tail_x6_r0_body.kd166.n0 = 2805513
kernel_rfl PRE_first_tail_x6_r0_body.ckn1166 : PRE_first_tail_x6_r0_body.kd166.n1 = 2805515
kernel_rfl PRE_first_tail_x6_r0_body.ckheap166 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd166.heap).all (fun x => Nat.ble 2805513 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl166 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_body.kd166.heap.get (2805513 + j) = nth? PRE_first_tail_x6_r0_body.pl166 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja166 : Nat.ble 2805513 2805513 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn166 : Nat.ble 7175 7175 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD166 : Nat.ble 2805513 PRE_first_tail_x6_r0_body.kd166.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn166 : Nat.ble 21478 PRE_first_tail_x6_r0_body.kd166.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn166 : Nat.ble 18573 PRE_first_tail_x6_r0_body.kd166.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb166 : Nat.ble 21478 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap166 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd166.heap).all (Nat.ble (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd166 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd166.hnd).all (Nat.ble (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode166 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd166.node).all (Nat.ble (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix166 : Conv.FixOld (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa166 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja166) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn166) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD166) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn166) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn166) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb166) PRE_first_tail_x6_r0_body.fheap166 PRE_first_tail_x6_r0_body.fhnd166 PRE_first_tail_x6_r0_body.fnode166
kernel_rfl PRE_first_tail_x6_r0_body.fcxn166 : (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn166 : (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle0166 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_166.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_166.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk166 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd166.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A166 : PRE_first_tail_x6_r0_body.cx1_166.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS166.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_166.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O166 : PRE_first_tail_x6_r0_body.cx1_166.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS166.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_166.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N166 : PRE_first_tail_x6_r0_body.cx1_166.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS166.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_166.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I166 : PRE_first_tail_x6_r0_body.cx1_166.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS166.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_166.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd166 : (PRE_first_tail_x6_r0_body.clo166 ++ PRE_first_tail_x6_r0_body.cln166 ++ PRE_first_tail_x6_r0_body.cli166 ++ PRE_first_tail_x6_r0_body.cwS166 ++ PRE_first_tail_x6_r0_body.cnS166 ++ PRE_first_tail_x6_r0_body.ciS166).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW166 : PRE_first_tail_x6_r0_body.cwS166.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo166.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI166 : PRE_first_tail_x6_r0_body.ciS166.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli166.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN166 : PRE_first_tail_x6_r0_body.cnS166.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF166 : PRE_first_tail_x6_r0_body.cln166.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh166 : PRE_first_tail_x6_r0_body.clo166.all (handleOK PRE_first_tail_x6_r0_body.kappa166 PRE_first_tail_x6_r0_body.P166.lo PRE_first_tail_x6_r0_body.cx0_166.mlx PRE_first_tail_x6_r0_body.cx1_166.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo166 : PRE_first_tail_x6_r0_body.clo166.map (fun h => PRE_first_tail_x6_r0_body.cx1_166.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa166.handle h)) = PRE_first_tail_x6_r0_body.clo166.map (fun h => (PRE_first_tail_x6_r0_body.cx0_166.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa166.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok166 : PRE_first_tail_x6_r0_body.clo166.all (objOK PRE_first_tail_x6_r0_body.kappa166 PRE_first_tail_x6_r0_body.P166.NL PRE_first_tail_x6_r0_body.cx0_166.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd166 : PRE_first_tail_x6_r0_body.cln166.all (nodeOKF PRE_first_tail_x6_r0_body.kappa166 PRE_first_tail_x6_r0_body.P166 PRE_first_tail_x6_r0_body.cx0_166.mlx PRE_first_tail_x6_r0_body.cx1_166.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp166 : ((PRE_first_tail_x6_r0_body.cln166.filter (fullB PRE_first_tail_x6_r0_body.P166))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_166.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa166.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln166.filter (fullB PRE_first_tail_x6_r0_body.P166))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_166.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa166.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI166 : incrB PRE_first_tail_x6_r0_body.kd166.nodeF (List.range' 18573 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK166 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd166.node).all (fun k => Nat.ble 18573 k && Nat.blt k 18573) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL166 : (PRE_first_tail_x6_r0_body.cln166.filter (Nat.ble PRE_first_tail_x6_r0_body.P166.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd166.nodeF i) && (Nat.blt i 18573 || Nat.ble PRE_first_tail_x6_r0_body.kd166.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord166 : (PRE_first_tail_x6_r0_body.cln166.filter (Nat.ble PRE_first_tail_x6_r0_body.P166.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd166.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd166.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd166.nodeF j) (PRE_first_tail_x6_r0_body.kd166.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow166 PRE_first_tail_x6_r0_body.cnn1166 PRE_first_tail_x6_r0_body.fnordI166 PRE_first_tail_x6_r0_body.fnordK166 PRE_first_tail_x6_r0_body.fnordL166
kernel_rfl PRE_first_tail_x6_r0_body.fi166 : PRE_first_tail_x6_r0_body.cli166.all (pnB PRE_first_tail_x6_r0_body.cx0_166.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii166 : PRE_first_tail_x6_r0_body.cli166.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_166.mlx.items.get (PRE_first_tail_x6_r0_body.kappa166.node k) = (PRE_first_tail_x6_r0_body.cx0_166.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa166.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot166 (clean : Conv.NClean (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P166.NL) (cl : SSt (· < 7175) PRE_first_tail_x6_r0_body.cx0_166.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P166 7175 PRE_first_tail_x6_r0_body.kappa166 PRE_first_tail_x6_r0_body.kd166 PRE_first_tail_x6_r0_body.khinv166 PRE_first_tail_x6_r0_body.kninv166 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx PRE_first_tail_x6_r0_body.cx0_166.mlx PRE_first_tail_x6_r0_body.cx1_166.mlx (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo166 PRE_first_tail_x6_r0_body.cln166 PRE_first_tail_x6_r0_body.cli166 PRE_first_tail_x6_r0_body.cwS166 PRE_first_tail_x6_r0_body.cnS166 PRE_first_tail_x6_r0_body.ciS166 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh0166, PRE_first_tail_x6_r0_body.cnh1166, PRE_first_tail_x6_r0_body.cnn0166, PRE_first_tail_x6_r0_body.cnn1166, PRE_first_tail_x6_r0_body.cplo166, PRE_first_tail_x6_r0_body.ccnt166, PRE_first_tail_x6_r0_body.cnband166, PRE_first_tail_x6_r0_body.chbelow166, PRE_first_tail_x6_r0_body.chren166, PRE_first_tail_x6_r0_body.cband166, PRE_first_tail_x6_r0_body.cnh1pos166, PRE_first_tail_x6_r0_body.cnren166, PRE_first_tail_x6_r0_body.cnlow166, PRE_first_tail_x6_r0_body.cabs0a166, PRE_first_tail_x6_r0_body.cabs0b166, PRE_first_tail_x6_r0_body.ctok1166, PRE_first_tail_x6_r0_body.cpend166, PRE_first_tail_x6_r0_body.cerrh166, PRE_first_tail_x6_r0_body.cfiles166, PRE_first_tail_x6_r0_body.carch166, PRE_first_tail_x6_r0_body.csizes166, PRE_first_tail_x6_r0_body.cwired166, PRE_first_tail_x6_r0_body.cfix166, clean, PRE_first_tail_x6_r0_body.fcxn166, PRE_first_tail_x6_r0_body.fcnn166, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle0166, PRE_first_tail_x6_r0_body.fnk166, PRE_first_tail_x6_r0_body.ckA166, PRE_first_tail_x6_r0_body.cobjsK166, PRE_first_tail_x6_r0_body.cnodesK166, PRE_first_tail_x6_r0_body.citemsK166, PRE_first_tail_x6_r0_body.f1A166, PRE_first_tail_x6_r0_body.f1O166, PRE_first_tail_x6_r0_body.f1N166, PRE_first_tail_x6_r0_body.f1I166, PRE_first_tail_x6_r0_body.fbd166, PRE_first_tail_x6_r0_body.fincW166, PRE_first_tail_x6_r0_body.fincI166, PRE_first_tail_x6_r0_body.fincN166, PRE_first_tail_x6_r0_body.flnF166, PRE_first_tail_x6_r0_body.fh166, PRE_first_tail_x6_r0_body.fo166, PRE_first_tail_x6_r0_body.fok166, PRE_first_tail_x6_r0_body.fnd166, PRE_first_tail_x6_r0_body.fp166, PRE_first_tail_x6_r0_body.fnord166, PRE_first_tail_x6_r0_body.fi166, PRE_first_tail_x6_r0_body.fii166⟩
theorem PRE_first_tail_x6_r0_body.cnshift166 (clean : Conv.NClean (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P166.NL) (cl : SSt (· < 7175) PRE_first_tail_x6_r0_body.cx0_166.mlx) : NShift PRE_first_tail_x6_r0_body.P166 7175 PRE_first_tail_x6_r0_body.kappa166 PRE_first_tail_x6_r0_body.cx0_166 PRE_first_tail_x6_r0_body.cx1_166 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot166 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost166 (compact_a_eq PRE_first_tail_x6_r0_body.ckn0166 PRE_first_tail_x6_r0_body.ckn1166 PRE_first_tail_x6_r0_body.ckheap166 PRE_first_tail_x6_r0_body.ckpl166)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_166 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1605.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_166 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1605.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_166 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1605.ffi) = some PRE_first_tail_x6_r0_body.fxC_166
kernel_rfl PRE_first_tail_x6_r0_body.okrC_166 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1605.ffi) = some PRE_first_tail_x6_r0_body.krC_166
noncomputable def PRE_first_tail_x6_r0_body.fx0_166 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1607.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_166 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1607.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_166 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1607.ffi) = some PRE_first_tail_x6_r0_body.fx0_166
kernel_rfl PRE_first_tail_x6_r0_body.okr0_166 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1607.ffi) = some PRE_first_tail_x6_r0_body.kr0_166
noncomputable def PRE_first_tail_x6_r0_body.fx1_166 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1606.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_166 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1606.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_166 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1606.ffi) = some PRE_first_tail_x6_r0_body.fx1_166
kernel_rfl PRE_first_tail_x6_r0_body.okr1_166 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1606.ffi) = some PRE_first_tail_x6_r0_body.kr1_166
kernel_rfl PRE_first_tail_x6_r0_body.ff0166 : PRE_first_tail_x6_r0_body.fx0_166 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_166 (PRE_first_tail_x6_r0_body.clo166.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_166.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff1166 : PRE_first_tail_x6_r0_body.fx1_166 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_166 (PRE_first_tail_x6_r0_body.cwS166.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_166.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck166 : freedLB PRE_first_tail_x6_r0_body.kappa166 PRE_first_tail_x6_r0_body.cx0_166.mlx PRE_first_tail_x6_r0_body.fx0_166 PRE_first_tail_x6_r0_body.fx1_166 PRE_first_tail_x6_r0_body.clo166 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf0166 : PRE_first_tail_x6_r0_body.kr0_166.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_166.flags (PRE_first_tail_x6_r0_body.clo166.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_166.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt0166 : PRE_first_tail_x6_r0_body.kr0_166.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_166.targs (PRE_first_tail_x6_r0_body.clo166.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_166.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf1166 : PRE_first_tail_x6_r0_body.kr1_166.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_166.flags (PRE_first_tail_x6_r0_body.cwS166.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_166.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt1166 : PRE_first_tail_x6_r0_body.kr1_166.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_166.targs (PRE_first_tail_x6_r0_body.cwS166.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_166.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck166 : krecLB PRE_first_tail_x6_r0_body.kappa166 7175 PRE_first_tail_x6_r0_body.cx0_166.mlx PRE_first_tail_x6_r0_body.kr0_166 PRE_first_tail_x6_r0_body.kr1_166 PRE_first_tail_x6_r0_body.clo166 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn166 : Nat.ble 7175 7175 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge166 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1606.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1607.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR166 : pendRegB PRE_first_tail_x6_r0_body.kappa166 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1607.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe166 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1607.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1606.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift166 (clean : Conv.NClean (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P166.NL) (cl : SSt (· < 7175) PRE_first_tail_x6_r0_body.cx0_166.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_166.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_166.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_166.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1605.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_166.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P166 7175 PRE_first_tail_x6_r0_body.kappa166 PRE_first_tail_x6_r0_body.s1607.ffi PRE_first_tail_x6_r0_body.s1606.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift166 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue166, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp166 t ht),
    PRE_first_tail_x6_r0_body.cbridge166,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1607.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1606.ffi) (PRE_first_tail_x6_r0_body.cfoot166 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_166 PRE_first_tail_x6_r0_body.ofx1_166 hobjC PRE_first_tail_x6_r0_body.ff0166 PRE_first_tail_x6_r0_body.ff1166 PRE_first_tail_x6_r0_body.ffck166,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1607.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1606.ffi) (PRE_first_tail_x6_r0_body.cfoot166 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_166 PRE_first_tail_x6_r0_body.okr1_166 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn166) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf0166 PRE_first_tail_x6_r0_body.fkt0166 PRE_first_tail_x6_r0_body.fkf1166 PRE_first_tail_x6_r0_body.fkt1166 PRE_first_tail_x6_r0_body.fkck166,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh0166 PRE_first_tail_x6_r0_body.cnh1166 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe166) PRE_first_tail_x6_r0_body.cpendR166⟩

end Host.Load.Run.Tpl
end

section -- st166/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st166 0
host_stream_state PRE_first_tail_x6_r0_body.st166 1
host_stream_state PRE_first_tail_x6_r0_body.st166 2
end Host.Load.Run.Tpl
end

section -- Site166
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 166 of chain `PRE_first_tail_x6_r0_body`: `rowBlocks__g166__g167` (`rowBlocks`), the call state `PRE_first_tail_x6_r0_body.s1605`, the merged state `PRE_first_tail_x6_r0_body.s1606`,
the site template `PRE_first_tail_x6_r0_body.st166` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s1607`: the merge.
The footprint's facts are in `SiteF166`, the compaction's in `SiteC166`, `SiteK166`, `SiteNa166`, `SiteNb166`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso166 : PRE_first_tail_x6_r0_body.st166.s0 = { PRE_first_tail_x6_r0_body.s1605 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs166 : List Frame := PRE_first_tail_x6_r0_body.s1605.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_166 : PRE_first_tail_x6_r0_body.S1605.tab.length = 7175
kernel_rfl PRE_first_tail_x6_r0_body.tab0_166 : PRE_first_tail_x6_r0_body.st166.S0.tab = PRE_first_tail_x6_r0_body.S1605.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws166 : List Nat := [3799, 3800]
kernel_rfl PRE_first_tail_x6_r0_body.fresh166 : (PRE_first_tail_x6_r0_body.S1605.tab.all fun e => PRE_first_tail_x6_r0_body.ws166.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S1605.oracle.all fun q => PRE_first_tail_x6_r0_body.ws166.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab166 : PRE_first_tail_x6_r0_body.S1606.tab = PRE_first_tail_x6_r0_body.S1605.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws166
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen166 : PRE_first_tail_x6_r0_body.st166.S2.tab.length - PRE_first_tail_x6_r0_body.st166.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged166`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap166 : PRE_first_tail_x6_r0_body.s1606.heap = PRE_first_tail_x6_r0_body.st166.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext166 : PRE_first_tail_x6_r0_body.s1606.next = PRE_first_tail_x6_r0_body.st166.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl166 : PRE_first_tail_x6_r0_body.s1606.ctl = PRE_first_tail_x6_r0_body.st166.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack166 : PRE_first_tail_x6_r0_body.s1606.stack = PRE_first_tail_x6_r0_body.st166.s2.stack ++ PRE_first_tail_x6_r0_body.s1605.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs166 : PRE_first_tail_x6_r0_body.s1606.jobs = PRE_first_tail_x6_r0_body.st166.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi166 : PRE_first_tail_x6_r0_body.s1606.ffi = PRE_first_tail_x6_r0_body.st166.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace166 : PRE_first_tail_x6_r0_body.s1606.trace = PRE_first_tail_x6_r0_body.st166.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores166 : PRE_first_tail_x6_r0_body.s1606.stores = PRE_first_tail_x6_r0_body.st166.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD166
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 166 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived166 : PRE_first_tail_x6_r0_body.nr166.map (fun r => nth? PRE_first_tail_x6_r0_body.st166.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo166 : PRE_first_tail_x6_r0_body.nr166.all (Nat.ble 7175) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj166 : PRE_first_tail_x6_r0_body.cws166.all (fun c => !PRE_first_tail_x6_r0_body.ws166.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ166 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws166 PRE_first_tail_x6_r0_body.crs166 PRE_first_tail_x6_r0_body.ws166

end Host.Load.Run.Tpl
end

section -- st166/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st166`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st166.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st166.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st166.s2.heap PRE_first_tail_x6_r0_body.st166.wrR ++ freshOf PRE_first_tail_x6_r0_body.st166.s2.heap PRE_first_tail_x6_r0_body.st166.s0.next PRE_first_tail_x6_r0_body.st166.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st166.wr : List Nat := PRE_first_tail_x6_r0_body.st166.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st166.heapFoot : PRE_first_tail_x6_r0_body.st166.s2.heap = setAll PRE_first_tail_x6_r0_body.st166.s0.heap PRE_first_tail_x6_r0_body.st166.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st166.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st166.s0.next PRE_first_tail_x6_r0_body.st166.s2.next = true
theorem PRE_first_tail_x6_r0_body.st166.grows : PRE_first_tail_x6_r0_body.st166.s0.next ≤ PRE_first_tail_x6_r0_body.st166.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st166.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st166.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st166.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st166.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st166.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st166.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st166.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st166.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st166.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st166.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st166.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st166.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st166.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st166.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st166.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st166.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st166.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st166.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st166.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st166.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st166.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st166.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st166.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st166.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st166.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st166.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st166.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st166.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st166.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st166.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st166.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st166.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF166
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 166 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB166 : nodupT PRE_first_tail_x6_r0_body.st166.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup166 : PRE_first_tail_x6_r0_body.st166.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB166).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB166 : PRE_first_tail_x6_r0_body.st166.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound166 : ∀ b ∈ PRE_first_tail_x6_r0_body.st166.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB166 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr166 := PRE_first_tail_x6_r0_body.st166.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq166 : PRE_first_tail_x6_r0_body.st166.s2.trace = PRE_first_tail_x6_r0_body.trFr166 ++ PRE_first_tail_x6_r0_body.st166.s0.trace
theorem PRE_first_tail_x6_r0_body.trace166 : ∃ fr, PRE_first_tail_x6_r0_body.st166.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st166.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq166⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide166 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB166 : (PRE_first_tail_x6_r0_body.wide166.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st166.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix166 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide166, WFix Map.id (Present PRE_first_tail_x6_r0_body.st166.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB166 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL166
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 166 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s1606`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO166 : PRE_first_tail_x6_r0_body.st166.S0.oracle = PRE_first_tail_x6_r0_body.st166.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B166 : PRE_first_tail_x6_r0_body.st166.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st166.s0.next || (PRE_first_tail_x6_r0_body.st166.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot166 : Conv.StageFoot PRE_first_tail_x6_r0_body.st166.wr PRE_first_tail_x6_r0_body.st166.s0 PRE_first_tail_x6_r0_body.st166.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st166.heapFoot PRE_first_tail_x6_r0_body.wrNodup166 PRE_first_tail_x6_r0_body.wrBound166 PRE_first_tail_x6_r0_body.wr0B166 PRE_first_tail_x6_r0_body.st166.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged166 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st166.F.S → PRE_first_tail_x6_r0_body.st166.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st166.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st166.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs166 PRE_first_tail_x6_r0_body.st166.wr PRE_first_tail_x6_r0_body.s1605 PRE_first_tail_x6_r0_body.st166.s2 PRE_first_tail_x6_r0_body.st166.s0
      PRE_first_tail_x6_r0_body.st166.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st166.F FR W stk M ν K PRE_first_tail_x6_r0_body.s1606 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso166 PRE_first_tail_x6_r0_body.stFoot166 PRE_first_tail_x6_r0_body.wrNodup166 PRE_first_tail_x6_r0_body.wrBound166 PRE_first_tail_x6_r0_body.trace166 PRE_first_tail_x6_r0_body.mheap166
    PRE_first_tail_x6_r0_body.mnext166 PRE_first_tail_x6_r0_body.mctl166 PRE_first_tail_x6_r0_body.mstack166 PRE_first_tail_x6_r0_body.mjobs166 PRE_first_tail_x6_r0_body.mffi166 PRE_first_tail_x6_r0_body.mtrace166 PRE_first_tail_x6_r0_body.mstores166 h

def PRE_first_tail_x6_r0_body.arrEl166_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE166_2665 : arrOf PRE_first_tail_x6_r0_body.s1606 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl166_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA166_2665 : isArrB PRE_first_tail_x6_r0_body.s1606 2665 = true
theorem PRE_first_tail_x6_r0_body.arr166_2665 : ∃ o, PRE_first_tail_x6_r0_body.s1606.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl166_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE166_2665 PRE_first_tail_x6_r0_body.arrA166_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN166_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl166_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR166_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl166_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN166_2665

def PRE_first_tail_x6_r0_body.arrEl166_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE166_2673467 : arrOf PRE_first_tail_x6_r0_body.s1606 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl166_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA166_2673467 : isArrB PRE_first_tail_x6_r0_body.s1606 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr166_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s1606.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl166_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE166_2673467 PRE_first_tail_x6_r0_body.arrA166_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN166_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl166_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR166_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl166_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN166_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k166 : isArrB PRE_first_tail_x6_r0_body.s1606 4910 = false
theorem PRE_first_tail_x6_r0_body.keep166 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s1606 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k166 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr166_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl166_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ166
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 166 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s1605`, the merged
state `PRE_first_tail_x6_r0_body.s1606`, the canonical state `PRE_first_tail_x6_r0_body.s1607`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl166 : PRE_first_tail_x6_r0_body.pl166.all (Nat.ble PRE_first_tail_x6_r0_body.s1605.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd166 : nodupT PRE_first_tail_x6_r0_body.pl166 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn1166 : Nat.ble PRE_first_tail_x6_r0_body.s1605.next 2805515 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst166 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s1605.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn166 : PRE_first_tail_x6_r0_body.s1607.next = PRE_first_tail_x6_r0_body.s1605.next + PRE_first_tail_x6_r0_body.pl166.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn166 : PRE_first_tail_x6_r0_body.s1606.next = 2805515
kernel_rfl PRE_first_tail_x6_r0_body.zgrow166 : Nat.ble PRE_first_tail_x6_r0_body.s1607.next PRE_first_tail_x6_r0_body.s1606.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh166 : PRE_first_tail_x6_r0_body.S1605.tab.all (fun e => PRE_first_tail_x6_r0_body.cws166.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd166 : nodupT PRE_first_tail_x6_r0_body.cws166 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi166 : PRE_first_tail_x6_r0_body.nr166.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S1606.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt166 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s1605.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg166_2665 : PRE_first_tail_x6_r0_body.s1607.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1607 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk166_2665 : (objOf PRE_first_tail_x6_r0_body.s1607 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm166_2665 : PRE_first_tail_x6_r0_body.s1606.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa166.obj (objOf PRE_first_tail_x6_r0_body.s1607 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s1606 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg166_2673467 : PRE_first_tail_x6_r0_body.s1607.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1607 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk166_2673467 : (objOf PRE_first_tail_x6_r0_body.s1607 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm166_2673467 : PRE_first_tail_x6_r0_body.s1606.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa166.obj (objOf PRE_first_tail_x6_r0_body.s1607 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s1606 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw166_4910 : (PRE_first_tail_x6_r0_body.s1607.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw166_2673472 : (PRE_first_tail_x6_r0_body.s1607.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw166_2673473 : (PRE_first_tail_x6_r0_body.s1607.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd166 : PRE_first_tail_x6_r0_body.cl166.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr166 : PRE_first_tail_x6_r0_body.st166.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s1605.next || PRE_first_tail_x6_r0_body.cl166.contains b) = true
def PRE_first_tail_x6_r0_body.zl166 : List Nat := PRE_first_tail_x6_r0_body.cl166.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE166 : PRE_first_tail_x6_r0_body.zl166.map (fun a => PRE_first_tail_x6_r0_body.s1606.heap.get (PRE_first_tail_x6_r0_body.kappa166.a a)) = PRE_first_tail_x6_r0_body.zl166.map (fun a => (PRE_first_tail_x6_r0_body.s1607.heap.get a).map PRE_first_tail_x6_r0_body.kappa166.hobj)
theorem PRE_first_tail_x6_r0_body.zimg166 : HeapImg PRE_first_tail_x6_r0_body.kappa166 PRE_first_tail_x6_r0_body.s1607 PRE_first_tail_x6_r0_body.s1606 PRE_first_tail_x6_r0_body.zl166 := PRE_first_tail_x6_r0_body.zimgE166
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl166 : PRE_first_tail_x6_r0_body.s1606.ctl = PRE_first_tail_x6_r0_body.kappa166.ctl PRE_first_tail_x6_r0_body.s1607.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack166 : PRE_first_tail_x6_r0_body.s1606.stack = PRE_first_tail_x6_r0_body.s1607.stack.map PRE_first_tail_x6_r0_body.kappa166.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs166 : PRE_first_tail_x6_r0_body.s1606.jobs = PRE_first_tail_x6_r0_body.s1607.jobs.map PRE_first_tail_x6_r0_body.kappa166.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores166 : PRE_first_tail_x6_r0_body.s1606.stores = PRE_first_tail_x6_r0_body.kappa166.stores PRE_first_tail_x6_r0_body.s1607.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots166 : checkRootsSupp PRE_first_tail_x6_r0_body.s1607 7175 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC166 : PRE_first_tail_x6_r0_body.S1605.tab.length + PRE_first_tail_x6_r0_body.cws166.length = 7175
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap166 : PRE_first_tail_x6_r0_body.kappa166 = Conv.Map.compact PRE_first_tail_x6_r0_body.s1605.next 2805515 PRE_first_tail_x6_r0_body.S1605.tab.length PRE_first_tail_x6_r0_body.pl166 (PRE_first_tail_x6_r0_body.nr166.map NumV.ref) PRE_first_tail_x6_r0_body.kd166.big
  PRE_first_tail_x6_r0_body.kd166.region PRE_first_tail_x6_r0_body.kd166.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin166 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1607.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc166 : Conv.jcleanListB (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1607 PRE_first_tail_x6_r0_body.cl166 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB166 : noBigRootsP (fun i => !Conv.oldBigB (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s1607.trace PRE_first_tail_x6_r0_body.s1607 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm166 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 18573 = true
theorem PRE_first_tail_x6_r0_body.cjcl166 (h : Conv.JClean (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1605) : Conv.JClean (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1607 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle166)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap166 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd166 a ha)) PRE_first_tail_x6_r0_body.zjc166

end Host.Load.Run.Tpl
end

section -- st166/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st166.bodyLast from PRE_first_tail_x6_r0_body.st166.s1 to PRE_first_tail_x6_r0_body.st166.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st166.F PRE_first_tail_x6_r0_body.st166.s1).run PRE_first_tail_x6_r0_body.st166.S1 = some (PRE_first_tail_x6_r0_body.st166.s2, PRE_first_tail_x6_r0_body.st166.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st166.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st166.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st166.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st166.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st166/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st166.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st166.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st166.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st166.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st166.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st166.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st166.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st166.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st166.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st166.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st166.s0 PRE_first_tail_x6_r0_body.st166.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st166.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st166.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st166.s1 PRE_first_tail_x6_r0_body.st166.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st166/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st166.bodyK0F from PRE_first_tail_x6_r0_body.st166.s0 to PRE_first_tail_x6_r0_body.st166.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st166.F (PRE_first_tail_x6_r0_body.st166.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st166.ks 0).getD 0) PRE_first_tail_x6_r0_body.st166.s0 PRE_first_tail_x6_r0_body.st166.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st166.s1, PRE_first_tail_x6_r0_body.st166.S1)
theorem PRE_first_tail_x6_r0_body.st166.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st166.F (PRE_first_tail_x6_r0_body.st166.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st166.ks 0).getD 0) PRE_first_tail_x6_r0_body.st166.s0 PRE_first_tail_x6_r0_body.st166.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st166.s1, PRE_first_tail_x6_r0_body.st166.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st166.bodyOkLN_ok PRE_first_tail_x6_r0_body.st166.bodyK0F
end Host.Load.Run.Tpl
end

section -- st166/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st166.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st166.F (PRE_first_tail_x6_r0_body.st166.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st166.s0 PRE_first_tail_x6_r0_body.st166.S0 = some (PRE_first_tail_x6_r0_body.st166.s1, PRE_first_tail_x6_r0_body.st166.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st166.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st166.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st166.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st166.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st166.F (PRE_first_tail_x6_r0_body.st166.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st166.s0
  S0 := PRE_first_tail_x6_r0_body.st166.S0
  s1 := PRE_first_tail_x6_r0_body.st166.s1
  S1 := PRE_first_tail_x6_r0_body.st166.S1
  s2 := PRE_first_tail_x6_r0_body.st166.s2
  S2 := PRE_first_tail_x6_r0_body.st166.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st166.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st166.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st166.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st166.bodyHalt
  last := PRE_first_tail_x6_r0_body.st166.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st166.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC167
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 167 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s1611` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa167` into the merged state
`PRE_first_tail_x6_r0_body.s1610`. -/

def PRE_first_tail_x6_r0_body.pl167 : List Nat := [2805820]
def PRE_first_tail_x6_r0_body.nr167 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd167 : RData :=
  ⟨2805802, 2805821, Stage.setAll PTrie.nil [(2805801, 2805820)], Stage.setAll PTrie.nil [],
   21485, 21485, 18577, 18577, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa167 : Map :=
  Conv.Map.compact 2805801 2805821 7192 PRE_first_tail_x6_r0_body.pl167 (PRE_first_tail_x6_r0_body.nr167.map NumV.ref) PRE_first_tail_x6_r0_body.kd167.big
    PRE_first_tail_x6_r0_body.kd167.region PRE_first_tail_x6_r0_body.kd167.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws167 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs167 : List SymE := PRE_first_tail_x6_r0_body.nr167.map fun r => (nth? PRE_first_tail_x6_r0_body.S1610.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta167 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws167 PRE_first_tail_x6_r0_body.crs167
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB167 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab167 : PRE_first_tail_x6_r0_body.S1611.tab = PRE_first_tail_x6_r0_body.S1609.tab ++ PRE_first_tail_x6_r0_body.cws167.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace167 : PRE_first_tail_x6_r0_body.s1611.trace = PRE_first_tail_x6_r0_body.s1609.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext167 : PRE_first_tail_x6_r0_body.s1611.next = 2805802
kernel_rfl PRE_first_tail_x6_r0_body.ccounters167 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1611.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1611.ffi).mlx.nnext) = (21485, 18577)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue167 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1610.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1611.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa167.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp167 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1611.ffi).mlx.tokens.all (bSN 7192) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean167 : Conv.cleanListB 21485 131072 (fun r => Nat.ble 85940 r) PRE_first_tail_x6_r0_body.s1611
    (PRE_first_tail_x6_r0_body.wrB167 ++ (List.range 1).map (2805801 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs167 : bigsOutB 21485 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1611.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK167
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl167`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl167 : List Nat := [2665, 2673467, 2805801]
def PRE_first_tail_x6_r0_body.clo167 : List Nat := []
def PRE_first_tail_x6_r0_body.cln167 : List Nat := []
def PRE_first_tail_x6_r0_body.cli167 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap167 : PRE_first_tail_x6_r0_body.s1611.heap = Stage.setAll PRE_first_tail_x6_r0_body.s1609.heap (PRE_first_tail_x6_r0_body.cl167.filterMap fun a => (PRE_first_tail_x6_r0_body.s1611.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe167 : Nat.ble PRE_first_tail_x6_r0_body.s1609.next PRE_first_tail_x6_r0_body.s1611.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP167 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s1609 PRE_first_tail_x6_r0_body.s1611 PRE_first_tail_x6_r0_body.cl167 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp167 : Conv.suppListB PRE_first_tail_x6_r0_body.s1611 7192 PRE_first_tail_x6_r0_body.cl167 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound167 : Conv.boundListB PRE_first_tail_x6_r0_body.s1611 PRE_first_tail_x6_r0_body.cl167 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK167 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1611.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln167.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1611.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK167 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1611.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo167.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1611.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK167 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1611.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli167.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1611.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst167 : Conv.sstListB 7192 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1611.ffi).mlx PRE_first_tail_x6_r0_body.cln167 PRE_first_tail_x6_r0_body.clo167 PRE_first_tail_x6_r0_body.cli167 = true

end Host.Load.Run.Tpl
end

section -- SiteCl167
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA167 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1611.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo167.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1611.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd167 : (PRE_first_tail_x6_r0_body.clo167 ++ PRE_first_tail_x6_r0_body.cln167 ++ PRE_first_tail_x6_r0_body.cli167).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle167 : Conv.Cnt.leB (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt) (⟨21485, 18577, 2805802, 7192⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck167 : Conv.ncleanListB (⟨21485, 18577, 2805802, 7192⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1611.ffi).mlx PRE_first_tail_x6_r0_body.clo167 PRE_first_tail_x6_r0_body.cln167 PRE_first_tail_x6_r0_body.cli167 = true
theorem PRE_first_tail_x6_r0_body.cncl167 (h : Conv.NClean (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx) : Conv.NClean (⟨21485, 18577, 2805802, 7192⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1611.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle167 PRE_first_tail_x6_r0_body.ckA167 PRE_first_tail_x6_r0_body.cobjsK167 PRE_first_tail_x6_r0_body.cnodesK167 PRE_first_tail_x6_r0_body.citemsK167 PRE_first_tail_x6_r0_body.cbd167 PRE_first_tail_x6_r0_body.cck167

end Host.Load.Run.Tpl
end

section -- SiteS167
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 167 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc167 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P167 : LoadP := PRE_first_tail_x6_r0_body.Pc167.raise 18577
kernel_rfl PRE_first_tail_x6_r0_body.craise167 : Nat.ble PRE_first_tail_x6_r0_body.Pc167.N0 18577 = true
theorem PRE_first_tail_x6_r0_body.raised167 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc167 PRE_first_tail_x6_r0_body.P167 :=
  .inr ⟨18577, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise167, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_167 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1611.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_167 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1610.ffi)
def PRE_first_tail_x6_r0_body.khinv167 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv167 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS167 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS167 : List Nat := List.range' 18577 0
def PRE_first_tail_x6_r0_body.ciS167 : List Nat := [] ++ List.range' 18577 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh0167 : PRE_first_tail_x6_r0_body.kd167.nh0 = PRE_first_tail_x6_r0_body.cx0_167.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh1167 : PRE_first_tail_x6_r0_body.kd167.nh1 = PRE_first_tail_x6_r0_body.cx1_167.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn0167 : PRE_first_tail_x6_r0_body.kd167.nn0 = PRE_first_tail_x6_r0_body.cx0_167.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn1167 : PRE_first_tail_x6_r0_body.kd167.nn1 = PRE_first_tail_x6_r0_body.cx1_167.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo167 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P167.lo && Nat.ble PRE_first_tail_x6_r0_body.P167.lo PRE_first_tail_x6_r0_body.cx0_167.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P167.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P167.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt167 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_167.mlx.next PRE_first_tail_x6_r0_body.cx1_167.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_167.mlx.nnext PRE_first_tail_x6_r0_body.cx1_167.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband167 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P167.NL && Nat.ble PRE_first_tail_x6_r0_body.P167.NL PRE_first_tail_x6_r0_body.P167.N0 && Nat.ble PRE_first_tail_x6_r0_body.P167.N0 PRE_first_tail_x6_r0_body.cx0_167.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow167 : PRE_first_tail_x6_r0_body.kd167.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren167 : checkRenG PRE_first_tail_x6_r0_body.kd167.hnd PRE_first_tail_x6_r0_body.khinv167 (phB PRE_first_tail_x6_r0_body.cx0_167.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband167 : PRE_first_tail_x6_r0_body.kd167.checkBand PRE_first_tail_x6_r0_body.P167.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos167 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd167.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren167 : checkRenG PRE_first_tail_x6_r0_body.kd167.node PRE_first_tail_x6_r0_body.kninv167 (pnB PRE_first_tail_x6_r0_body.cx0_167.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow167 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd167.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P167.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd167.nodeF j) PRE_first_tail_x6_r0_body.cx1_167.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a167 : PRE_first_tail_x6_r0_body.cx0_167.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b167 : PRE_first_tail_x6_r0_body.cx0_167.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok1167 : PRE_first_tail_x6_r0_body.cx1_167.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend167 : PRE_first_tail_x6_r0_body.cx1_167.mlx.pending = PRE_first_tail_x6_r0_body.cx0_167.mlx.pending.map PRE_first_tail_x6_r0_body.kappa167.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh167 : PRE_first_tail_x6_r0_body.cx1_167.mlx.errh = PRE_first_tail_x6_r0_body.cx0_167.mlx.errh.map PRE_first_tail_x6_r0_body.kappa167.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles167 : PRE_first_tail_x6_r0_body.cx1_167.mlx.files = PRE_first_tail_x6_r0_body.cx0_167.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch167 : PRE_first_tail_x6_r0_body.cx1_167.mlx.arch = PRE_first_tail_x6_r0_body.cx0_167.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes167 : PRE_first_tail_x6_r0_body.cx1_167.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_167.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired167 : PRE_first_tail_x6_r0_body.cx1_167.mlx.wired = PRE_first_tail_x6_r0_body.cx0_167.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost167 : PRE_first_tail_x6_r0_body.cx1_167.host = PRE_first_tail_x6_r0_body.cx0_167.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd167`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn0167 : PRE_first_tail_x6_r0_body.kd167.n0 = 2805802
kernel_rfl PRE_first_tail_x6_r0_body.ckn1167 : PRE_first_tail_x6_r0_body.kd167.n1 = 2805821
kernel_rfl PRE_first_tail_x6_r0_body.ckheap167 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd167.heap).all (fun x => Nat.ble 2805801 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl167 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd167.heap.get (2805801 + j) = nth? PRE_first_tail_x6_r0_body.pl167 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja167 : Nat.ble 2805801 2805801 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn167 : Nat.ble 7192 7192 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD167 : Nat.ble 2805801 PRE_first_tail_x6_r0_body.kd167.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn167 : Nat.ble 21485 PRE_first_tail_x6_r0_body.kd167.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn167 : Nat.ble 18577 PRE_first_tail_x6_r0_body.kd167.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb167 : Nat.ble 21485 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap167 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd167.heap).all (Nat.ble (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd167 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd167.hnd).all (Nat.ble (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode167 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd167.node).all (Nat.ble (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix167 : Conv.FixOld (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa167 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja167) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn167) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD167) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn167) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn167) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb167) PRE_first_tail_x6_r0_body.fheap167 PRE_first_tail_x6_r0_body.fhnd167 PRE_first_tail_x6_r0_body.fnode167
kernel_rfl PRE_first_tail_x6_r0_body.fcxn167 : (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn167 : (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle0167 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_167.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_167.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk167 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd167.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A167 : PRE_first_tail_x6_r0_body.cx1_167.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS167.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_167.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O167 : PRE_first_tail_x6_r0_body.cx1_167.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS167.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_167.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N167 : PRE_first_tail_x6_r0_body.cx1_167.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS167.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_167.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I167 : PRE_first_tail_x6_r0_body.cx1_167.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS167.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_167.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd167 : (PRE_first_tail_x6_r0_body.clo167 ++ PRE_first_tail_x6_r0_body.cln167 ++ PRE_first_tail_x6_r0_body.cli167 ++ PRE_first_tail_x6_r0_body.cwS167 ++ PRE_first_tail_x6_r0_body.cnS167 ++ PRE_first_tail_x6_r0_body.ciS167).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW167 : PRE_first_tail_x6_r0_body.cwS167.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo167.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI167 : PRE_first_tail_x6_r0_body.ciS167.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli167.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN167 : PRE_first_tail_x6_r0_body.cnS167.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF167 : PRE_first_tail_x6_r0_body.cln167.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh167 : PRE_first_tail_x6_r0_body.clo167.all (handleOK PRE_first_tail_x6_r0_body.kappa167 PRE_first_tail_x6_r0_body.P167.lo PRE_first_tail_x6_r0_body.cx0_167.mlx PRE_first_tail_x6_r0_body.cx1_167.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo167 : PRE_first_tail_x6_r0_body.clo167.map (fun h => PRE_first_tail_x6_r0_body.cx1_167.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa167.handle h)) = PRE_first_tail_x6_r0_body.clo167.map (fun h => (PRE_first_tail_x6_r0_body.cx0_167.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa167.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok167 : PRE_first_tail_x6_r0_body.clo167.all (objOK PRE_first_tail_x6_r0_body.kappa167 PRE_first_tail_x6_r0_body.P167.NL PRE_first_tail_x6_r0_body.cx0_167.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd167 : PRE_first_tail_x6_r0_body.cln167.all (nodeOKF PRE_first_tail_x6_r0_body.kappa167 PRE_first_tail_x6_r0_body.P167 PRE_first_tail_x6_r0_body.cx0_167.mlx PRE_first_tail_x6_r0_body.cx1_167.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp167 : ((PRE_first_tail_x6_r0_body.cln167.filter (fullB PRE_first_tail_x6_r0_body.P167))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_167.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa167.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln167.filter (fullB PRE_first_tail_x6_r0_body.P167))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_167.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa167.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI167 : incrB PRE_first_tail_x6_r0_body.kd167.nodeF (List.range' 18577 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK167 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd167.node).all (fun k => Nat.ble 18577 k && Nat.blt k 18577) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL167 : (PRE_first_tail_x6_r0_body.cln167.filter (Nat.ble PRE_first_tail_x6_r0_body.P167.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd167.nodeF i) && (Nat.blt i 18577 || Nat.ble PRE_first_tail_x6_r0_body.kd167.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord167 : (PRE_first_tail_x6_r0_body.cln167.filter (Nat.ble PRE_first_tail_x6_r0_body.P167.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd167.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd167.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd167.nodeF j) (PRE_first_tail_x6_r0_body.kd167.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow167 PRE_first_tail_x6_r0_body.cnn1167 PRE_first_tail_x6_r0_body.fnordI167 PRE_first_tail_x6_r0_body.fnordK167 PRE_first_tail_x6_r0_body.fnordL167
kernel_rfl PRE_first_tail_x6_r0_body.fi167 : PRE_first_tail_x6_r0_body.cli167.all (pnB PRE_first_tail_x6_r0_body.cx0_167.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii167 : PRE_first_tail_x6_r0_body.cli167.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_167.mlx.items.get (PRE_first_tail_x6_r0_body.kappa167.node k) = (PRE_first_tail_x6_r0_body.cx0_167.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa167.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot167 (clean : Conv.NClean (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P167.NL) (cl : SSt (· < 7192) PRE_first_tail_x6_r0_body.cx0_167.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P167 7192 PRE_first_tail_x6_r0_body.kappa167 PRE_first_tail_x6_r0_body.kd167 PRE_first_tail_x6_r0_body.khinv167 PRE_first_tail_x6_r0_body.kninv167 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx PRE_first_tail_x6_r0_body.cx0_167.mlx PRE_first_tail_x6_r0_body.cx1_167.mlx (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo167 PRE_first_tail_x6_r0_body.cln167 PRE_first_tail_x6_r0_body.cli167 PRE_first_tail_x6_r0_body.cwS167 PRE_first_tail_x6_r0_body.cnS167 PRE_first_tail_x6_r0_body.ciS167 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh0167, PRE_first_tail_x6_r0_body.cnh1167, PRE_first_tail_x6_r0_body.cnn0167, PRE_first_tail_x6_r0_body.cnn1167, PRE_first_tail_x6_r0_body.cplo167, PRE_first_tail_x6_r0_body.ccnt167, PRE_first_tail_x6_r0_body.cnband167, PRE_first_tail_x6_r0_body.chbelow167, PRE_first_tail_x6_r0_body.chren167, PRE_first_tail_x6_r0_body.cband167, PRE_first_tail_x6_r0_body.cnh1pos167, PRE_first_tail_x6_r0_body.cnren167, PRE_first_tail_x6_r0_body.cnlow167, PRE_first_tail_x6_r0_body.cabs0a167, PRE_first_tail_x6_r0_body.cabs0b167, PRE_first_tail_x6_r0_body.ctok1167, PRE_first_tail_x6_r0_body.cpend167, PRE_first_tail_x6_r0_body.cerrh167, PRE_first_tail_x6_r0_body.cfiles167, PRE_first_tail_x6_r0_body.carch167, PRE_first_tail_x6_r0_body.csizes167, PRE_first_tail_x6_r0_body.cwired167, PRE_first_tail_x6_r0_body.cfix167, clean, PRE_first_tail_x6_r0_body.fcxn167, PRE_first_tail_x6_r0_body.fcnn167, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle0167, PRE_first_tail_x6_r0_body.fnk167, PRE_first_tail_x6_r0_body.ckA167, PRE_first_tail_x6_r0_body.cobjsK167, PRE_first_tail_x6_r0_body.cnodesK167, PRE_first_tail_x6_r0_body.citemsK167, PRE_first_tail_x6_r0_body.f1A167, PRE_first_tail_x6_r0_body.f1O167, PRE_first_tail_x6_r0_body.f1N167, PRE_first_tail_x6_r0_body.f1I167, PRE_first_tail_x6_r0_body.fbd167, PRE_first_tail_x6_r0_body.fincW167, PRE_first_tail_x6_r0_body.fincI167, PRE_first_tail_x6_r0_body.fincN167, PRE_first_tail_x6_r0_body.flnF167, PRE_first_tail_x6_r0_body.fh167, PRE_first_tail_x6_r0_body.fo167, PRE_first_tail_x6_r0_body.fok167, PRE_first_tail_x6_r0_body.fnd167, PRE_first_tail_x6_r0_body.fp167, PRE_first_tail_x6_r0_body.fnord167, PRE_first_tail_x6_r0_body.fi167, PRE_first_tail_x6_r0_body.fii167⟩
theorem PRE_first_tail_x6_r0_body.cnshift167 (clean : Conv.NClean (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P167.NL) (cl : SSt (· < 7192) PRE_first_tail_x6_r0_body.cx0_167.mlx) : NShift PRE_first_tail_x6_r0_body.P167 7192 PRE_first_tail_x6_r0_body.kappa167 PRE_first_tail_x6_r0_body.cx0_167 PRE_first_tail_x6_r0_body.cx1_167 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot167 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost167 (compact_a_eq PRE_first_tail_x6_r0_body.ckn0167 PRE_first_tail_x6_r0_body.ckn1167 PRE_first_tail_x6_r0_body.ckheap167 PRE_first_tail_x6_r0_body.ckpl167)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_167 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1609.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_167 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1609.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_167 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1609.ffi) = some PRE_first_tail_x6_r0_body.fxC_167
kernel_rfl PRE_first_tail_x6_r0_body.okrC_167 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1609.ffi) = some PRE_first_tail_x6_r0_body.krC_167
noncomputable def PRE_first_tail_x6_r0_body.fx0_167 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1611.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_167 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1611.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_167 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1611.ffi) = some PRE_first_tail_x6_r0_body.fx0_167
kernel_rfl PRE_first_tail_x6_r0_body.okr0_167 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1611.ffi) = some PRE_first_tail_x6_r0_body.kr0_167
noncomputable def PRE_first_tail_x6_r0_body.fx1_167 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1610.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_167 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1610.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_167 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1610.ffi) = some PRE_first_tail_x6_r0_body.fx1_167
kernel_rfl PRE_first_tail_x6_r0_body.okr1_167 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1610.ffi) = some PRE_first_tail_x6_r0_body.kr1_167
kernel_rfl PRE_first_tail_x6_r0_body.ff0167 : PRE_first_tail_x6_r0_body.fx0_167 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_167 (PRE_first_tail_x6_r0_body.clo167.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_167.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff1167 : PRE_first_tail_x6_r0_body.fx1_167 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_167 (PRE_first_tail_x6_r0_body.cwS167.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_167.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck167 : freedLB PRE_first_tail_x6_r0_body.kappa167 PRE_first_tail_x6_r0_body.cx0_167.mlx PRE_first_tail_x6_r0_body.fx0_167 PRE_first_tail_x6_r0_body.fx1_167 PRE_first_tail_x6_r0_body.clo167 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf0167 : PRE_first_tail_x6_r0_body.kr0_167.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_167.flags (PRE_first_tail_x6_r0_body.clo167.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_167.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt0167 : PRE_first_tail_x6_r0_body.kr0_167.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_167.targs (PRE_first_tail_x6_r0_body.clo167.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_167.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf1167 : PRE_first_tail_x6_r0_body.kr1_167.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_167.flags (PRE_first_tail_x6_r0_body.cwS167.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_167.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt1167 : PRE_first_tail_x6_r0_body.kr1_167.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_167.targs (PRE_first_tail_x6_r0_body.cwS167.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_167.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck167 : krecLB PRE_first_tail_x6_r0_body.kappa167 7192 PRE_first_tail_x6_r0_body.cx0_167.mlx PRE_first_tail_x6_r0_body.kr0_167 PRE_first_tail_x6_r0_body.kr1_167 PRE_first_tail_x6_r0_body.clo167 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn167 : Nat.ble 7192 7192 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge167 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1610.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1611.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR167 : pendRegB PRE_first_tail_x6_r0_body.kappa167 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1611.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe167 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1611.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1610.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift167 (clean : Conv.NClean (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P167.NL) (cl : SSt (· < 7192) PRE_first_tail_x6_r0_body.cx0_167.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_167.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_167.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_167.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1609.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_167.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P167 7192 PRE_first_tail_x6_r0_body.kappa167 PRE_first_tail_x6_r0_body.s1611.ffi PRE_first_tail_x6_r0_body.s1610.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift167 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue167, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp167 t ht),
    PRE_first_tail_x6_r0_body.cbridge167,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1611.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1610.ffi) (PRE_first_tail_x6_r0_body.cfoot167 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_167 PRE_first_tail_x6_r0_body.ofx1_167 hobjC PRE_first_tail_x6_r0_body.ff0167 PRE_first_tail_x6_r0_body.ff1167 PRE_first_tail_x6_r0_body.ffck167,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1611.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1610.ffi) (PRE_first_tail_x6_r0_body.cfoot167 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_167 PRE_first_tail_x6_r0_body.okr1_167 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn167) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf0167 PRE_first_tail_x6_r0_body.fkt0167 PRE_first_tail_x6_r0_body.fkf1167 PRE_first_tail_x6_r0_body.fkt1167 PRE_first_tail_x6_r0_body.fkck167,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh0167 PRE_first_tail_x6_r0_body.cnh1167 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe167) PRE_first_tail_x6_r0_body.cpendR167⟩

end Host.Load.Run.Tpl
end

section -- st167/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st167 0
host_stream_state PRE_first_tail_x6_r0_body.st167 1
host_stream_state PRE_first_tail_x6_r0_body.st167 2
end Host.Load.Run.Tpl
end

section -- Site167
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 167 of chain `PRE_first_tail_x6_r0_body`: `plan__g167__g168` (`plan`), the call state `PRE_first_tail_x6_r0_body.s1609`, the merged state `PRE_first_tail_x6_r0_body.s1610`,
the site template `PRE_first_tail_x6_r0_body.st167` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s1611`: the merge.
The footprint's facts are in `SiteF167`, the compaction's in `SiteC167`, `SiteK167`, `SiteNa167`, `SiteNb167`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso167 : PRE_first_tail_x6_r0_body.st167.s0 = { PRE_first_tail_x6_r0_body.s1609 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs167 : List Frame := PRE_first_tail_x6_r0_body.s1609.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_167 : PRE_first_tail_x6_r0_body.S1609.tab.length = 7192
kernel_rfl PRE_first_tail_x6_r0_body.tab0_167 : PRE_first_tail_x6_r0_body.st167.S0.tab = PRE_first_tail_x6_r0_body.S1609.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws167 : List Nat := [3801, 3802, 3803, 3804, 3805, 3806, 3807, 3808, 3809]
kernel_rfl PRE_first_tail_x6_r0_body.fresh167 : (PRE_first_tail_x6_r0_body.S1609.tab.all fun e => PRE_first_tail_x6_r0_body.ws167.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S1609.oracle.all fun q => PRE_first_tail_x6_r0_body.ws167.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab167 : PRE_first_tail_x6_r0_body.S1610.tab = PRE_first_tail_x6_r0_body.S1609.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws167
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen167 : PRE_first_tail_x6_r0_body.st167.S2.tab.length - PRE_first_tail_x6_r0_body.st167.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged167`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap167 : PRE_first_tail_x6_r0_body.s1610.heap = PRE_first_tail_x6_r0_body.st167.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext167 : PRE_first_tail_x6_r0_body.s1610.next = PRE_first_tail_x6_r0_body.st167.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl167 : PRE_first_tail_x6_r0_body.s1610.ctl = PRE_first_tail_x6_r0_body.st167.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack167 : PRE_first_tail_x6_r0_body.s1610.stack = PRE_first_tail_x6_r0_body.st167.s2.stack ++ PRE_first_tail_x6_r0_body.s1609.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs167 : PRE_first_tail_x6_r0_body.s1610.jobs = PRE_first_tail_x6_r0_body.st167.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi167 : PRE_first_tail_x6_r0_body.s1610.ffi = PRE_first_tail_x6_r0_body.st167.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace167 : PRE_first_tail_x6_r0_body.s1610.trace = PRE_first_tail_x6_r0_body.st167.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores167 : PRE_first_tail_x6_r0_body.s1610.stores = PRE_first_tail_x6_r0_body.st167.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD167
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 167 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived167 : PRE_first_tail_x6_r0_body.nr167.map (fun r => nth? PRE_first_tail_x6_r0_body.st167.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo167 : PRE_first_tail_x6_r0_body.nr167.all (Nat.ble 7192) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj167 : PRE_first_tail_x6_r0_body.cws167.all (fun c => !PRE_first_tail_x6_r0_body.ws167.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ167 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws167 PRE_first_tail_x6_r0_body.crs167 PRE_first_tail_x6_r0_body.ws167

end Host.Load.Run.Tpl
end

section -- st167/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st167`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st167.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st167.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st167.s2.heap PRE_first_tail_x6_r0_body.st167.wrR ++ freshOf PRE_first_tail_x6_r0_body.st167.s2.heap PRE_first_tail_x6_r0_body.st167.s0.next PRE_first_tail_x6_r0_body.st167.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st167.wr : List Nat := PRE_first_tail_x6_r0_body.st167.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st167.heapFoot : PRE_first_tail_x6_r0_body.st167.s2.heap = setAll PRE_first_tail_x6_r0_body.st167.s0.heap PRE_first_tail_x6_r0_body.st167.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st167.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st167.s0.next PRE_first_tail_x6_r0_body.st167.s2.next = true
theorem PRE_first_tail_x6_r0_body.st167.grows : PRE_first_tail_x6_r0_body.st167.s0.next ≤ PRE_first_tail_x6_r0_body.st167.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st167.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st167.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st167.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st167.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st167.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st167.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st167.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st167.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st167.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st167.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st167.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st167.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st167.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st167.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st167.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st167.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st167.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st167.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st167.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st167.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st167.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st167.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st167.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st167.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st167.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st167.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st167.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st167.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st167.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st167.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st167.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st167.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF167
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 167 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB167 : nodupT PRE_first_tail_x6_r0_body.st167.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup167 : PRE_first_tail_x6_r0_body.st167.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB167).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB167 : PRE_first_tail_x6_r0_body.st167.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound167 : ∀ b ∈ PRE_first_tail_x6_r0_body.st167.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB167 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr167 := PRE_first_tail_x6_r0_body.st167.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq167 : PRE_first_tail_x6_r0_body.st167.s2.trace = PRE_first_tail_x6_r0_body.trFr167 ++ PRE_first_tail_x6_r0_body.st167.s0.trace
theorem PRE_first_tail_x6_r0_body.trace167 : ∃ fr, PRE_first_tail_x6_r0_body.st167.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st167.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq167⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide167 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB167 : (PRE_first_tail_x6_r0_body.wide167.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st167.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix167 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide167, WFix Map.id (Present PRE_first_tail_x6_r0_body.st167.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB167 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL167
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 167 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s1610`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO167 : PRE_first_tail_x6_r0_body.st167.S0.oracle = PRE_first_tail_x6_r0_body.st167.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B167 : PRE_first_tail_x6_r0_body.st167.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st167.s0.next || (PRE_first_tail_x6_r0_body.st167.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot167 : Conv.StageFoot PRE_first_tail_x6_r0_body.st167.wr PRE_first_tail_x6_r0_body.st167.s0 PRE_first_tail_x6_r0_body.st167.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st167.heapFoot PRE_first_tail_x6_r0_body.wrNodup167 PRE_first_tail_x6_r0_body.wrBound167 PRE_first_tail_x6_r0_body.wr0B167 PRE_first_tail_x6_r0_body.st167.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged167 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st167.F.S → PRE_first_tail_x6_r0_body.st167.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st167.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st167.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs167 PRE_first_tail_x6_r0_body.st167.wr PRE_first_tail_x6_r0_body.s1609 PRE_first_tail_x6_r0_body.st167.s2 PRE_first_tail_x6_r0_body.st167.s0
      PRE_first_tail_x6_r0_body.st167.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st167.F FR W stk M ν K PRE_first_tail_x6_r0_body.s1610 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso167 PRE_first_tail_x6_r0_body.stFoot167 PRE_first_tail_x6_r0_body.wrNodup167 PRE_first_tail_x6_r0_body.wrBound167 PRE_first_tail_x6_r0_body.trace167 PRE_first_tail_x6_r0_body.mheap167
    PRE_first_tail_x6_r0_body.mnext167 PRE_first_tail_x6_r0_body.mctl167 PRE_first_tail_x6_r0_body.mstack167 PRE_first_tail_x6_r0_body.mjobs167 PRE_first_tail_x6_r0_body.mffi167 PRE_first_tail_x6_r0_body.mtrace167 PRE_first_tail_x6_r0_body.mstores167 h

def PRE_first_tail_x6_r0_body.arrEl167_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE167_2665 : arrOf PRE_first_tail_x6_r0_body.s1610 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl167_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA167_2665 : isArrB PRE_first_tail_x6_r0_body.s1610 2665 = true
theorem PRE_first_tail_x6_r0_body.arr167_2665 : ∃ o, PRE_first_tail_x6_r0_body.s1610.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl167_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE167_2665 PRE_first_tail_x6_r0_body.arrA167_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN167_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl167_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR167_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl167_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN167_2665

def PRE_first_tail_x6_r0_body.arrEl167_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE167_2673467 : arrOf PRE_first_tail_x6_r0_body.s1610 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl167_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA167_2673467 : isArrB PRE_first_tail_x6_r0_body.s1610 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr167_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s1610.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl167_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE167_2673467 PRE_first_tail_x6_r0_body.arrA167_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN167_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl167_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR167_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl167_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN167_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k167 : isArrB PRE_first_tail_x6_r0_body.s1610 4910 = false
theorem PRE_first_tail_x6_r0_body.keep167 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s1610 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k167 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr167_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl167_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ167
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 167 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s1609`, the merged
state `PRE_first_tail_x6_r0_body.s1610`, the canonical state `PRE_first_tail_x6_r0_body.s1611`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl167 : PRE_first_tail_x6_r0_body.pl167.all (Nat.ble PRE_first_tail_x6_r0_body.s1609.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd167 : nodupT PRE_first_tail_x6_r0_body.pl167 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn1167 : Nat.ble PRE_first_tail_x6_r0_body.s1609.next 2805821 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst167 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s1609.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn167 : PRE_first_tail_x6_r0_body.s1611.next = PRE_first_tail_x6_r0_body.s1609.next + PRE_first_tail_x6_r0_body.pl167.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn167 : PRE_first_tail_x6_r0_body.s1610.next = 2805821
kernel_rfl PRE_first_tail_x6_r0_body.zgrow167 : Nat.ble PRE_first_tail_x6_r0_body.s1611.next PRE_first_tail_x6_r0_body.s1610.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh167 : PRE_first_tail_x6_r0_body.S1609.tab.all (fun e => PRE_first_tail_x6_r0_body.cws167.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd167 : nodupT PRE_first_tail_x6_r0_body.cws167 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi167 : PRE_first_tail_x6_r0_body.nr167.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S1610.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt167 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s1609.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg167_2665 : PRE_first_tail_x6_r0_body.s1611.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1611 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk167_2665 : (objOf PRE_first_tail_x6_r0_body.s1611 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm167_2665 : PRE_first_tail_x6_r0_body.s1610.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa167.obj (objOf PRE_first_tail_x6_r0_body.s1611 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s1610 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg167_2673467 : PRE_first_tail_x6_r0_body.s1611.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1611 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk167_2673467 : (objOf PRE_first_tail_x6_r0_body.s1611 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm167_2673467 : PRE_first_tail_x6_r0_body.s1610.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa167.obj (objOf PRE_first_tail_x6_r0_body.s1611 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s1610 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw167_4910 : (PRE_first_tail_x6_r0_body.s1611.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw167_2673472 : (PRE_first_tail_x6_r0_body.s1611.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw167_2673473 : (PRE_first_tail_x6_r0_body.s1611.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd167 : PRE_first_tail_x6_r0_body.cl167.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr167 : PRE_first_tail_x6_r0_body.st167.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s1609.next || PRE_first_tail_x6_r0_body.cl167.contains b) = true
def PRE_first_tail_x6_r0_body.zl167 : List Nat := PRE_first_tail_x6_r0_body.cl167.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE167 : PRE_first_tail_x6_r0_body.zl167.map (fun a => PRE_first_tail_x6_r0_body.s1610.heap.get (PRE_first_tail_x6_r0_body.kappa167.a a)) = PRE_first_tail_x6_r0_body.zl167.map (fun a => (PRE_first_tail_x6_r0_body.s1611.heap.get a).map PRE_first_tail_x6_r0_body.kappa167.hobj)
theorem PRE_first_tail_x6_r0_body.zimg167 : HeapImg PRE_first_tail_x6_r0_body.kappa167 PRE_first_tail_x6_r0_body.s1611 PRE_first_tail_x6_r0_body.s1610 PRE_first_tail_x6_r0_body.zl167 := PRE_first_tail_x6_r0_body.zimgE167
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl167 : PRE_first_tail_x6_r0_body.s1610.ctl = PRE_first_tail_x6_r0_body.kappa167.ctl PRE_first_tail_x6_r0_body.s1611.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack167 : PRE_first_tail_x6_r0_body.s1610.stack = PRE_first_tail_x6_r0_body.s1611.stack.map PRE_first_tail_x6_r0_body.kappa167.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs167 : PRE_first_tail_x6_r0_body.s1610.jobs = PRE_first_tail_x6_r0_body.s1611.jobs.map PRE_first_tail_x6_r0_body.kappa167.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores167 : PRE_first_tail_x6_r0_body.s1610.stores = PRE_first_tail_x6_r0_body.kappa167.stores PRE_first_tail_x6_r0_body.s1611.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots167 : checkRootsSupp PRE_first_tail_x6_r0_body.s1611 7192 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC167 : PRE_first_tail_x6_r0_body.S1609.tab.length + PRE_first_tail_x6_r0_body.cws167.length = 7192
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap167 : PRE_first_tail_x6_r0_body.kappa167 = Conv.Map.compact PRE_first_tail_x6_r0_body.s1609.next 2805821 PRE_first_tail_x6_r0_body.S1609.tab.length PRE_first_tail_x6_r0_body.pl167 (PRE_first_tail_x6_r0_body.nr167.map NumV.ref) PRE_first_tail_x6_r0_body.kd167.big
  PRE_first_tail_x6_r0_body.kd167.region PRE_first_tail_x6_r0_body.kd167.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin167 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1611.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc167 : Conv.jcleanListB (⟨21485, 18577, 2805802, 7192⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1611 PRE_first_tail_x6_r0_body.cl167 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB167 : noBigRootsP (fun i => !Conv.oldBigB (⟨21485, 18577, 2805802, 7192⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s1611.trace PRE_first_tail_x6_r0_body.s1611 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm167 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 18577 = true
theorem PRE_first_tail_x6_r0_body.cjcl167 (h : Conv.JClean (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1609) : Conv.JClean (⟨21485, 18577, 2805802, 7192⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1611 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle167)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap167 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd167 a ha)) PRE_first_tail_x6_r0_body.zjc167

end Host.Load.Run.Tpl
end

section -- st167/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st167.bodyLast from PRE_first_tail_x6_r0_body.st167.s1 to PRE_first_tail_x6_r0_body.st167.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st167.F PRE_first_tail_x6_r0_body.st167.s1).run PRE_first_tail_x6_r0_body.st167.S1 = some (PRE_first_tail_x6_r0_body.st167.s2, PRE_first_tail_x6_r0_body.st167.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st167.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st167.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st167.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st167.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st167/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st167.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st167.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st167.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st167.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st167.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st167.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st167.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st167.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st167.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st167.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st167.s0 PRE_first_tail_x6_r0_body.st167.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st167.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st167.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st167.s1 PRE_first_tail_x6_r0_body.st167.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st167/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st167.bodyK0F from PRE_first_tail_x6_r0_body.st167.s0 to PRE_first_tail_x6_r0_body.st167.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st167.F (PRE_first_tail_x6_r0_body.st167.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st167.ks 0).getD 0) PRE_first_tail_x6_r0_body.st167.s0 PRE_first_tail_x6_r0_body.st167.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st167.s1, PRE_first_tail_x6_r0_body.st167.S1)
theorem PRE_first_tail_x6_r0_body.st167.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st167.F (PRE_first_tail_x6_r0_body.st167.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st167.ks 0).getD 0) PRE_first_tail_x6_r0_body.st167.s0 PRE_first_tail_x6_r0_body.st167.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st167.s1, PRE_first_tail_x6_r0_body.st167.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st167.bodyOkLN_ok PRE_first_tail_x6_r0_body.st167.bodyK0F
end Host.Load.Run.Tpl
end

section -- st167/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st167.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st167.F (PRE_first_tail_x6_r0_body.st167.bodyOkL bytes rows) 206 PRE_first_tail_x6_r0_body.st167.s0 PRE_first_tail_x6_r0_body.st167.S0 = some (PRE_first_tail_x6_r0_body.st167.s1, PRE_first_tail_x6_r0_body.st167.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st167.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st167.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st167.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st167.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st167.F (PRE_first_tail_x6_r0_body.st167.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st167.s0
  S0 := PRE_first_tail_x6_r0_body.st167.S0
  s1 := PRE_first_tail_x6_r0_body.st167.s1
  S1 := PRE_first_tail_x6_r0_body.st167.S1
  s2 := PRE_first_tail_x6_r0_body.st167.s2
  S2 := PRE_first_tail_x6_r0_body.st167.S2
  n := 206
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st167.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st167.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st167.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st167.bodyHalt
  last := PRE_first_tail_x6_r0_body.st167.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st167.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC168
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 168 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s1628` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa168` into the merged state
`PRE_first_tail_x6_r0_body.s1627`. -/

def PRE_first_tail_x6_r0_body.pl168 : List Nat := [2808411, 2807586, 2808417, 2808413, 2807588, 2808419]
def PRE_first_tail_x6_r0_body.nr168 : List Nat := [7295, 7294, 7270, 7278, 7283, 7288, 7293, 7267, 7268, 7269, 7276, 7277, 7265, 7272, 7273, 7274, 7275, 7271]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd168 : RData :=
  ⟨2807305, 2808454, Stage.setAll PTrie.nil [(2807299, 2808411), (2807300, 2807586), (2807301, 2808417), (2807302, 2808413), (2807303, 2807588), (2807304, 2808419)], Stage.setAll PTrie.nil [(21520, 21546), (21521, 21524), (21522, 21547)],
   21523, 21548, 18623, 18623, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(7265, .ref 7295), (7266, .ref 7294), (7267, .ref 7270), (7268, .ref 7278), (7269, .ref 7283), (7270, .ref 7288), (7271, .ref 7293), (7272, .ref 7267), (7273, .ref 7268), (7274, .ref 7269), (7275, .ref 7276), (7276, .ref 7277), (7277, .ref 7265), (7278, .ref 7272), (7279, .ref 7273), (7280, .ref 7274), (7281, .ref 7275), (7282, .ref 7271)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa168 : Map :=
  Conv.Map.compact 2807299 2808454 7265 PRE_first_tail_x6_r0_body.pl168 (PRE_first_tail_x6_r0_body.nr168.map NumV.ref) PRE_first_tail_x6_r0_body.kd168.big
    PRE_first_tail_x6_r0_body.kd168.region PRE_first_tail_x6_r0_body.kd168.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws168 : List Nat := [3841, 3842, 3843, 3844, 3845, 3846, 3847, 3848, 3849, 3850, 3851, 3852, 3853, 3854, 3855, 3856, 3857, 3858]
noncomputable def PRE_first_tail_x6_r0_body.crs168 : List SymE := PRE_first_tail_x6_r0_body.nr168.map fun r => (nth? PRE_first_tail_x6_r0_body.S1627.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta168 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws168 PRE_first_tail_x6_r0_body.crs168
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB168 : List Nat := [2665, 2672734, 2673467, 2806473, 2807018, 2807274]

kernel_rfl PRE_first_tail_x6_r0_body.ctab168 : PRE_first_tail_x6_r0_body.S1628.tab = PRE_first_tail_x6_r0_body.S1626.tab ++ PRE_first_tail_x6_r0_body.cws168.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace168 : PRE_first_tail_x6_r0_body.s1628.trace = PRE_first_tail_x6_r0_body.s1626.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext168 : PRE_first_tail_x6_r0_body.s1628.next = 2807305
kernel_rfl PRE_first_tail_x6_r0_body.ccounters168 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1628.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1628.ffi).mlx.nnext) = (21523, 18623)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue168 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1627.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1628.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa168.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp168 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1628.ffi).mlx.tokens.all (bSN 7283) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean168 : Conv.cleanListB 21523 131072 (fun r => Nat.ble 86092 r) PRE_first_tail_x6_r0_body.s1628
    (PRE_first_tail_x6_r0_body.wrB168 ++ (List.range 6).map (2807299 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs168 : bigsOutB 21523 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1628.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK168
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl168`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl168 : List Nat := [2665, 2672734, 2673467, 2806473, 2807018, 2807274, 2807299, 2807300, 2807301, 2807302, 2807303, 2807304]
def PRE_first_tail_x6_r0_body.clo168 : List Nat := [21500, 21513, 21519, 21520, 21521, 21522]
def PRE_first_tail_x6_r0_body.cln168 : List Nat := [18596, 18597, 18598, 18599, 18600, 18601, 18602, 18603, 18604, 18605, 18606, 18607, 18608, 18609, 18610, 18611, 18612, 18613, 18614, 18615, 18616, 18617, 18618, 18619, 18620, 18621, 18622]
def PRE_first_tail_x6_r0_body.cli168 : List Nat := [18596, 18597, 18598, 18599, 18600, 18601, 18602, 18603, 18604, 18605, 18606, 18607, 18608, 18609, 18610, 18611, 18612, 18613, 18614, 18615, 18616, 18617, 18618, 18619, 18620, 18621, 18622]
kernel_rfl PRE_first_tail_x6_r0_body.cheap168 : PRE_first_tail_x6_r0_body.s1628.heap = Stage.setAll PRE_first_tail_x6_r0_body.s1626.heap (PRE_first_tail_x6_r0_body.cl168.filterMap fun a => (PRE_first_tail_x6_r0_body.s1628.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe168 : Nat.ble PRE_first_tail_x6_r0_body.s1626.next PRE_first_tail_x6_r0_body.s1628.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP168 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s1626 PRE_first_tail_x6_r0_body.s1628 PRE_first_tail_x6_r0_body.cl168 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp168 : Conv.suppListB PRE_first_tail_x6_r0_body.s1628 7283 PRE_first_tail_x6_r0_body.cl168 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound168 : Conv.boundListB PRE_first_tail_x6_r0_body.s1628 PRE_first_tail_x6_r0_body.cl168 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK168 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1628.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln168.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1628.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK168 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1628.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo168.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1628.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK168 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1628.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli168.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1628.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst168 : Conv.sstListB 7283 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1628.ffi).mlx PRE_first_tail_x6_r0_body.cln168 PRE_first_tail_x6_r0_body.clo168 PRE_first_tail_x6_r0_body.cli168 = true

end Host.Load.Run.Tpl
end

section -- SiteCl168
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA168 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1628.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo168.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1628.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd168 : (PRE_first_tail_x6_r0_body.clo168 ++ PRE_first_tail_x6_r0_body.cln168 ++ PRE_first_tail_x6_r0_body.cli168).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle168 : Conv.Cnt.leB (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt) (⟨21523, 18623, 2807305, 7283⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck168 : Conv.ncleanListB (⟨21523, 18623, 2807305, 7283⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1628.ffi).mlx PRE_first_tail_x6_r0_body.clo168 PRE_first_tail_x6_r0_body.cln168 PRE_first_tail_x6_r0_body.cli168 = true
theorem PRE_first_tail_x6_r0_body.cncl168 (h : Conv.NClean (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx) : Conv.NClean (⟨21523, 18623, 2807305, 7283⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1628.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle168 PRE_first_tail_x6_r0_body.ckA168 PRE_first_tail_x6_r0_body.cobjsK168 PRE_first_tail_x6_r0_body.cnodesK168 PRE_first_tail_x6_r0_body.citemsK168 PRE_first_tail_x6_r0_body.cbd168 PRE_first_tail_x6_r0_body.cck168

end Host.Load.Run.Tpl
end

section -- SiteS168
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 168 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc168 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P168 : LoadP := PRE_first_tail_x6_r0_body.Pc168.raise 18623
kernel_rfl PRE_first_tail_x6_r0_body.craise168 : Nat.ble PRE_first_tail_x6_r0_body.Pc168.N0 18623 = true
theorem PRE_first_tail_x6_r0_body.raised168 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc168 PRE_first_tail_x6_r0_body.P168 :=
  .inr ⟨18623, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise168, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_168 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1628.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_168 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1627.ffi)
def PRE_first_tail_x6_r0_body.khinv168 : PTrie Nat := Stage.setAll PTrie.nil [(21546, 21520), (21524, 21521), (21547, 21522)]
def PRE_first_tail_x6_r0_body.kninv168 : PTrie Nat := Stage.setAll PTrie.nil [(18596, 18596), (18597, 18597), (18598, 18598), (18599, 18599), (18600, 18600), (18601, 18601), (18602, 18602), (18603, 18603), (18604, 18604), (18605, 18605), (18606, 18606), (18607, 18607), (18608, 18608), (18609, 18609), (18610, 18610), (18611, 18611), (18612, 18612), (18613, 18613), (18614, 18614), (18615, 18615), (18616, 18616), (18617, 18617), (18618, 18618), (18619, 18619), (18620, 18620), (18621, 18621), (18622, 18622)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS168 : List Nat := [21500, 21513, 21519, 21520, 21521, 21522, 21523, 21524, 21525, 21526, 21527, 21528, 21529, 21530, 21531, 21532, 21533, 21534, 21535, 21536, 21537, 21538, 21539, 21540, 21541, 21542, 21543, 21544, 21545, 21546, 21547]
def PRE_first_tail_x6_r0_body.cnS168 : List Nat := List.range' 18596 27
def PRE_first_tail_x6_r0_body.ciS168 : List Nat := [] ++ List.range' 18596 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh0168 : PRE_first_tail_x6_r0_body.kd168.nh0 = PRE_first_tail_x6_r0_body.cx0_168.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh1168 : PRE_first_tail_x6_r0_body.kd168.nh1 = PRE_first_tail_x6_r0_body.cx1_168.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn0168 : PRE_first_tail_x6_r0_body.kd168.nn0 = PRE_first_tail_x6_r0_body.cx0_168.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn1168 : PRE_first_tail_x6_r0_body.kd168.nn1 = PRE_first_tail_x6_r0_body.cx1_168.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo168 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P168.lo && Nat.ble PRE_first_tail_x6_r0_body.P168.lo PRE_first_tail_x6_r0_body.cx0_168.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P168.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P168.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt168 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_168.mlx.next PRE_first_tail_x6_r0_body.cx1_168.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_168.mlx.nnext PRE_first_tail_x6_r0_body.cx1_168.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband168 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P168.NL && Nat.ble PRE_first_tail_x6_r0_body.P168.NL PRE_first_tail_x6_r0_body.P168.N0 && Nat.ble PRE_first_tail_x6_r0_body.P168.N0 PRE_first_tail_x6_r0_body.cx0_168.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow168 : PRE_first_tail_x6_r0_body.kd168.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren168 : checkRenG PRE_first_tail_x6_r0_body.kd168.hnd PRE_first_tail_x6_r0_body.khinv168 (phB PRE_first_tail_x6_r0_body.cx0_168.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband168 : PRE_first_tail_x6_r0_body.kd168.checkBand PRE_first_tail_x6_r0_body.P168.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos168 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd168.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren168 : checkRenG PRE_first_tail_x6_r0_body.kd168.node PRE_first_tail_x6_r0_body.kninv168 (pnB PRE_first_tail_x6_r0_body.cx0_168.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow168 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd168.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P168.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd168.nodeF j) PRE_first_tail_x6_r0_body.cx1_168.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a168 : PRE_first_tail_x6_r0_body.cx0_168.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b168 : PRE_first_tail_x6_r0_body.cx0_168.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok1168 : PRE_first_tail_x6_r0_body.cx1_168.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend168 : PRE_first_tail_x6_r0_body.cx1_168.mlx.pending = PRE_first_tail_x6_r0_body.cx0_168.mlx.pending.map PRE_first_tail_x6_r0_body.kappa168.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh168 : PRE_first_tail_x6_r0_body.cx1_168.mlx.errh = PRE_first_tail_x6_r0_body.cx0_168.mlx.errh.map PRE_first_tail_x6_r0_body.kappa168.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles168 : PRE_first_tail_x6_r0_body.cx1_168.mlx.files = PRE_first_tail_x6_r0_body.cx0_168.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch168 : PRE_first_tail_x6_r0_body.cx1_168.mlx.arch = PRE_first_tail_x6_r0_body.cx0_168.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes168 : PRE_first_tail_x6_r0_body.cx1_168.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_168.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired168 : PRE_first_tail_x6_r0_body.cx1_168.mlx.wired = PRE_first_tail_x6_r0_body.cx0_168.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost168 : PRE_first_tail_x6_r0_body.cx1_168.host = PRE_first_tail_x6_r0_body.cx0_168.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd168`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn0168 : PRE_first_tail_x6_r0_body.kd168.n0 = 2807305
kernel_rfl PRE_first_tail_x6_r0_body.ckn1168 : PRE_first_tail_x6_r0_body.kd168.n1 = 2808454
kernel_rfl PRE_first_tail_x6_r0_body.ckheap168 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd168.heap).all (fun x => Nat.ble 2807299 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl168 : (List.range 6).all (fun j => decide (PRE_first_tail_x6_r0_body.kd168.heap.get (2807299 + j) = nth? PRE_first_tail_x6_r0_body.pl168 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja168 : Nat.ble 2807299 2807299 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn168 : Nat.ble 7265 7265 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD168 : Nat.ble 2807299 PRE_first_tail_x6_r0_body.kd168.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn168 : Nat.ble 21520 PRE_first_tail_x6_r0_body.kd168.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn168 : Nat.ble 18596 PRE_first_tail_x6_r0_body.kd168.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb168 : Nat.ble 21520 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap168 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd168.heap).all (Nat.ble (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd168 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd168.hnd).all (Nat.ble (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode168 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd168.node).all (Nat.ble (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix168 : Conv.FixOld (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa168 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja168) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn168) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD168) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn168) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn168) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb168) PRE_first_tail_x6_r0_body.fheap168 PRE_first_tail_x6_r0_body.fhnd168 PRE_first_tail_x6_r0_body.fnode168
kernel_rfl PRE_first_tail_x6_r0_body.fcxn168 : (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn168 : (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle0168 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_168.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_168.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk168 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd168.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A168 : PRE_first_tail_x6_r0_body.cx1_168.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS168.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_168.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O168 : PRE_first_tail_x6_r0_body.cx1_168.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS168.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_168.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N168 : PRE_first_tail_x6_r0_body.cx1_168.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS168.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_168.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I168 : PRE_first_tail_x6_r0_body.cx1_168.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS168.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_168.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd168 : (PRE_first_tail_x6_r0_body.clo168 ++ PRE_first_tail_x6_r0_body.cln168 ++ PRE_first_tail_x6_r0_body.cli168 ++ PRE_first_tail_x6_r0_body.cwS168 ++ PRE_first_tail_x6_r0_body.cnS168 ++ PRE_first_tail_x6_r0_body.ciS168).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW168 : PRE_first_tail_x6_r0_body.cwS168.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo168.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI168 : PRE_first_tail_x6_r0_body.ciS168.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli168.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN168 : PRE_first_tail_x6_r0_body.cnS168.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF168 : PRE_first_tail_x6_r0_body.cln168.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh168 : PRE_first_tail_x6_r0_body.clo168.all (handleOK PRE_first_tail_x6_r0_body.kappa168 PRE_first_tail_x6_r0_body.P168.lo PRE_first_tail_x6_r0_body.cx0_168.mlx PRE_first_tail_x6_r0_body.cx1_168.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo168 : PRE_first_tail_x6_r0_body.clo168.map (fun h => PRE_first_tail_x6_r0_body.cx1_168.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa168.handle h)) = PRE_first_tail_x6_r0_body.clo168.map (fun h => (PRE_first_tail_x6_r0_body.cx0_168.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa168.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok168 : PRE_first_tail_x6_r0_body.clo168.all (objOK PRE_first_tail_x6_r0_body.kappa168 PRE_first_tail_x6_r0_body.P168.NL PRE_first_tail_x6_r0_body.cx0_168.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd168 : PRE_first_tail_x6_r0_body.cln168.all (nodeOKF PRE_first_tail_x6_r0_body.kappa168 PRE_first_tail_x6_r0_body.P168 PRE_first_tail_x6_r0_body.cx0_168.mlx PRE_first_tail_x6_r0_body.cx1_168.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp168 : ((PRE_first_tail_x6_r0_body.cln168.filter (fullB PRE_first_tail_x6_r0_body.P168))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_168.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa168.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln168.filter (fullB PRE_first_tail_x6_r0_body.P168))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_168.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa168.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI168 : incrB PRE_first_tail_x6_r0_body.kd168.nodeF (List.range' 18596 27) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK168 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd168.node).all (fun k => Nat.ble 18596 k && Nat.blt k 18623) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL168 : (PRE_first_tail_x6_r0_body.cln168.filter (Nat.ble PRE_first_tail_x6_r0_body.P168.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd168.nodeF i) && (Nat.blt i 18623 || Nat.ble PRE_first_tail_x6_r0_body.kd168.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord168 : (PRE_first_tail_x6_r0_body.cln168.filter (Nat.ble PRE_first_tail_x6_r0_body.P168.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd168.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd168.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd168.nodeF j) (PRE_first_tail_x6_r0_body.kd168.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow168 PRE_first_tail_x6_r0_body.cnn1168 PRE_first_tail_x6_r0_body.fnordI168 PRE_first_tail_x6_r0_body.fnordK168 PRE_first_tail_x6_r0_body.fnordL168
kernel_rfl PRE_first_tail_x6_r0_body.fi168 : PRE_first_tail_x6_r0_body.cli168.all (pnB PRE_first_tail_x6_r0_body.cx0_168.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii168 : PRE_first_tail_x6_r0_body.cli168.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_168.mlx.items.get (PRE_first_tail_x6_r0_body.kappa168.node k) = (PRE_first_tail_x6_r0_body.cx0_168.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa168.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot168 (clean : Conv.NClean (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P168.NL) (cl : SSt (· < 7283) PRE_first_tail_x6_r0_body.cx0_168.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P168 7283 PRE_first_tail_x6_r0_body.kappa168 PRE_first_tail_x6_r0_body.kd168 PRE_first_tail_x6_r0_body.khinv168 PRE_first_tail_x6_r0_body.kninv168 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx PRE_first_tail_x6_r0_body.cx0_168.mlx PRE_first_tail_x6_r0_body.cx1_168.mlx (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo168 PRE_first_tail_x6_r0_body.cln168 PRE_first_tail_x6_r0_body.cli168 PRE_first_tail_x6_r0_body.cwS168 PRE_first_tail_x6_r0_body.cnS168 PRE_first_tail_x6_r0_body.ciS168 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh0168, PRE_first_tail_x6_r0_body.cnh1168, PRE_first_tail_x6_r0_body.cnn0168, PRE_first_tail_x6_r0_body.cnn1168, PRE_first_tail_x6_r0_body.cplo168, PRE_first_tail_x6_r0_body.ccnt168, PRE_first_tail_x6_r0_body.cnband168, PRE_first_tail_x6_r0_body.chbelow168, PRE_first_tail_x6_r0_body.chren168, PRE_first_tail_x6_r0_body.cband168, PRE_first_tail_x6_r0_body.cnh1pos168, PRE_first_tail_x6_r0_body.cnren168, PRE_first_tail_x6_r0_body.cnlow168, PRE_first_tail_x6_r0_body.cabs0a168, PRE_first_tail_x6_r0_body.cabs0b168, PRE_first_tail_x6_r0_body.ctok1168, PRE_first_tail_x6_r0_body.cpend168, PRE_first_tail_x6_r0_body.cerrh168, PRE_first_tail_x6_r0_body.cfiles168, PRE_first_tail_x6_r0_body.carch168, PRE_first_tail_x6_r0_body.csizes168, PRE_first_tail_x6_r0_body.cwired168, PRE_first_tail_x6_r0_body.cfix168, clean, PRE_first_tail_x6_r0_body.fcxn168, PRE_first_tail_x6_r0_body.fcnn168, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle0168, PRE_first_tail_x6_r0_body.fnk168, PRE_first_tail_x6_r0_body.ckA168, PRE_first_tail_x6_r0_body.cobjsK168, PRE_first_tail_x6_r0_body.cnodesK168, PRE_first_tail_x6_r0_body.citemsK168, PRE_first_tail_x6_r0_body.f1A168, PRE_first_tail_x6_r0_body.f1O168, PRE_first_tail_x6_r0_body.f1N168, PRE_first_tail_x6_r0_body.f1I168, PRE_first_tail_x6_r0_body.fbd168, PRE_first_tail_x6_r0_body.fincW168, PRE_first_tail_x6_r0_body.fincI168, PRE_first_tail_x6_r0_body.fincN168, PRE_first_tail_x6_r0_body.flnF168, PRE_first_tail_x6_r0_body.fh168, PRE_first_tail_x6_r0_body.fo168, PRE_first_tail_x6_r0_body.fok168, PRE_first_tail_x6_r0_body.fnd168, PRE_first_tail_x6_r0_body.fp168, PRE_first_tail_x6_r0_body.fnord168, PRE_first_tail_x6_r0_body.fi168, PRE_first_tail_x6_r0_body.fii168⟩
theorem PRE_first_tail_x6_r0_body.cnshift168 (clean : Conv.NClean (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P168.NL) (cl : SSt (· < 7283) PRE_first_tail_x6_r0_body.cx0_168.mlx) : NShift PRE_first_tail_x6_r0_body.P168 7283 PRE_first_tail_x6_r0_body.kappa168 PRE_first_tail_x6_r0_body.cx0_168 PRE_first_tail_x6_r0_body.cx1_168 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot168 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost168 (compact_a_eq PRE_first_tail_x6_r0_body.ckn0168 PRE_first_tail_x6_r0_body.ckn1168 PRE_first_tail_x6_r0_body.ckheap168 PRE_first_tail_x6_r0_body.ckpl168)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_168 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1626.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_168 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1626.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_168 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1626.ffi) = some PRE_first_tail_x6_r0_body.fxC_168
kernel_rfl PRE_first_tail_x6_r0_body.okrC_168 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1626.ffi) = some PRE_first_tail_x6_r0_body.krC_168
noncomputable def PRE_first_tail_x6_r0_body.fx0_168 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1628.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_168 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1628.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_168 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1628.ffi) = some PRE_first_tail_x6_r0_body.fx0_168
kernel_rfl PRE_first_tail_x6_r0_body.okr0_168 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1628.ffi) = some PRE_first_tail_x6_r0_body.kr0_168
noncomputable def PRE_first_tail_x6_r0_body.fx1_168 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1627.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_168 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1627.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_168 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1627.ffi) = some PRE_first_tail_x6_r0_body.fx1_168
kernel_rfl PRE_first_tail_x6_r0_body.okr1_168 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1627.ffi) = some PRE_first_tail_x6_r0_body.kr1_168
kernel_rfl PRE_first_tail_x6_r0_body.ff0168 : PRE_first_tail_x6_r0_body.fx0_168 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_168 (PRE_first_tail_x6_r0_body.clo168.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_168.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff1168 : PRE_first_tail_x6_r0_body.fx1_168 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_168 (PRE_first_tail_x6_r0_body.cwS168.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_168.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck168 : freedLB PRE_first_tail_x6_r0_body.kappa168 PRE_first_tail_x6_r0_body.cx0_168.mlx PRE_first_tail_x6_r0_body.fx0_168 PRE_first_tail_x6_r0_body.fx1_168 PRE_first_tail_x6_r0_body.clo168 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf0168 : PRE_first_tail_x6_r0_body.kr0_168.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_168.flags (PRE_first_tail_x6_r0_body.clo168.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_168.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt0168 : PRE_first_tail_x6_r0_body.kr0_168.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_168.targs (PRE_first_tail_x6_r0_body.clo168.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_168.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf1168 : PRE_first_tail_x6_r0_body.kr1_168.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_168.flags (PRE_first_tail_x6_r0_body.cwS168.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_168.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt1168 : PRE_first_tail_x6_r0_body.kr1_168.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_168.targs (PRE_first_tail_x6_r0_body.cwS168.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_168.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck168 : krecLB PRE_first_tail_x6_r0_body.kappa168 7283 PRE_first_tail_x6_r0_body.cx0_168.mlx PRE_first_tail_x6_r0_body.kr0_168 PRE_first_tail_x6_r0_body.kr1_168 PRE_first_tail_x6_r0_body.clo168 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn168 : Nat.ble 7265 7283 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge168 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1627.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1628.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR168 : pendRegB PRE_first_tail_x6_r0_body.kappa168 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1628.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe168 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1628.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1627.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift168 (clean : Conv.NClean (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P168.NL) (cl : SSt (· < 7283) PRE_first_tail_x6_r0_body.cx0_168.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_168.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_168.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_168.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1626.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_168.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P168 7283 PRE_first_tail_x6_r0_body.kappa168 PRE_first_tail_x6_r0_body.s1628.ffi PRE_first_tail_x6_r0_body.s1627.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift168 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue168, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp168 t ht),
    PRE_first_tail_x6_r0_body.cbridge168,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1628.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1627.ffi) (PRE_first_tail_x6_r0_body.cfoot168 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_168 PRE_first_tail_x6_r0_body.ofx1_168 hobjC PRE_first_tail_x6_r0_body.ff0168 PRE_first_tail_x6_r0_body.ff1168 PRE_first_tail_x6_r0_body.ffck168,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1628.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1627.ffi) (PRE_first_tail_x6_r0_body.cfoot168 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_168 PRE_first_tail_x6_r0_body.okr1_168 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn168) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf0168 PRE_first_tail_x6_r0_body.fkt0168 PRE_first_tail_x6_r0_body.fkf1168 PRE_first_tail_x6_r0_body.fkt1168 PRE_first_tail_x6_r0_body.fkck168,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh0168 PRE_first_tail_x6_r0_body.cnh1168 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe168) PRE_first_tail_x6_r0_body.cpendR168⟩

end Host.Load.Run.Tpl
end

section -- st168/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st168 0
host_stream_state PRE_first_tail_x6_r0_body.st168 1
host_stream_state PRE_first_tail_x6_r0_body.st168 2
host_stream_state PRE_first_tail_x6_r0_body.st168 3
host_stream_state PRE_first_tail_x6_r0_body.st168 4
host_stream_state PRE_first_tail_x6_r0_body.st168 5
end Host.Load.Run.Tpl
end

section -- Site168
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 168 of chain `PRE_first_tail_x6_r0_body`: `ssmW__g168__g169` (`recurWindow`), the call state `PRE_first_tail_x6_r0_body.s1626`, the merged state `PRE_first_tail_x6_r0_body.s1627`,
the site template `PRE_first_tail_x6_r0_body.st168` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s1628`: the merge.
The footprint's facts are in `SiteF168`, the compaction's in `SiteC168`, `SiteK168`, `SiteNa168`, `SiteNb168`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso168 : PRE_first_tail_x6_r0_body.st168.s0 = { PRE_first_tail_x6_r0_body.s1626 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs168 : List Frame := PRE_first_tail_x6_r0_body.s1626.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_168 : PRE_first_tail_x6_r0_body.S1626.tab.length = 7265
kernel_rfl PRE_first_tail_x6_r0_body.tab0_168 : PRE_first_tail_x6_r0_body.st168.S0.tab = PRE_first_tail_x6_r0_body.S1626.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws168 : List Nat := [3810, 3811, 3812, 3813, 3814, 3815, 3816, 3817, 3818, 3819, 3820, 3821, 3822, 3823, 3824, 3825, 3826, 3827, 3828, 3829, 3830, 3831, 3832, 3833, 3834, 3835, 3836, 3837, 3838, 3839, 3840]
kernel_rfl PRE_first_tail_x6_r0_body.fresh168 : (PRE_first_tail_x6_r0_body.S1626.tab.all fun e => PRE_first_tail_x6_r0_body.ws168.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S1626.oracle.all fun q => PRE_first_tail_x6_r0_body.ws168.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab168 : PRE_first_tail_x6_r0_body.S1627.tab = PRE_first_tail_x6_r0_body.S1626.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws168
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen168 : PRE_first_tail_x6_r0_body.st168.S5.tab.length - PRE_first_tail_x6_r0_body.st168.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged168`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap168 : PRE_first_tail_x6_r0_body.s1627.heap = PRE_first_tail_x6_r0_body.st168.s5.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext168 : PRE_first_tail_x6_r0_body.s1627.next = PRE_first_tail_x6_r0_body.st168.s5.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl168 : PRE_first_tail_x6_r0_body.s1627.ctl = PRE_first_tail_x6_r0_body.st168.s5.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack168 : PRE_first_tail_x6_r0_body.s1627.stack = PRE_first_tail_x6_r0_body.st168.s5.stack ++ PRE_first_tail_x6_r0_body.s1626.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs168 : PRE_first_tail_x6_r0_body.s1627.jobs = PRE_first_tail_x6_r0_body.st168.s5.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi168 : PRE_first_tail_x6_r0_body.s1627.ffi = PRE_first_tail_x6_r0_body.st168.s5.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace168 : PRE_first_tail_x6_r0_body.s1627.trace = PRE_first_tail_x6_r0_body.st168.s5.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores168 : PRE_first_tail_x6_r0_body.s1627.stores = PRE_first_tail_x6_r0_body.st168.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD168
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 168 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived168 : PRE_first_tail_x6_r0_body.nr168.map (fun r => nth? PRE_first_tail_x6_r0_body.st168.S5.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.un .int32 (SymE.un .int32 (SymE.var 10))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))]
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo168 : PRE_first_tail_x6_r0_body.nr168.all (Nat.ble 7265) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj168 : PRE_first_tail_x6_r0_body.cws168.all (fun c => !PRE_first_tail_x6_r0_body.ws168.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ168 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws168 PRE_first_tail_x6_r0_body.crs168 PRE_first_tail_x6_r0_body.ws168

end Host.Load.Run.Tpl
end

section -- st168/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st168`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st168.wrR : List (Nat × Nat) := [(2672734, 2672735), (2806473, 2806474), (2807018, 2807019), (2807274, 2807275)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st168.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st168.s5.heap PRE_first_tail_x6_r0_body.st168.wrR ++ freshOf PRE_first_tail_x6_r0_body.st168.s5.heap PRE_first_tail_x6_r0_body.st168.s0.next PRE_first_tail_x6_r0_body.st168.s5.next
noncomputable def PRE_first_tail_x6_r0_body.st168.wr : List Nat := PRE_first_tail_x6_r0_body.st168.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st168.heapFoot : PRE_first_tail_x6_r0_body.st168.s5.heap = setAll PRE_first_tail_x6_r0_body.st168.s0.heap PRE_first_tail_x6_r0_body.st168.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st168.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st168.s0.next PRE_first_tail_x6_r0_body.st168.s5.next = true
theorem PRE_first_tail_x6_r0_body.st168.grows : PRE_first_tail_x6_r0_body.st168.s0.next ≤ PRE_first_tail_x6_r0_body.st168.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st168.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st168.wh : List Nat := [21500, 21513, 21519, 21520, 21521, 21522, 21523, 21524, 21525, 21526, 21527, 21528, 21529, 21530, 21531, 21532, 21533, 21534, 21535, 21536, 21537, 21538, 21539, 21540, 21541, 21542, 21543, 21544, 21545, 21546, 21547]
def PRE_first_tail_x6_r0_body.st168.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st168.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st168.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st168.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st168.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st168.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st168.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st168.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st168.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st168.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st168.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st168.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st168.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st168.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st168.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st168.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st168.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st168.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st168.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st168.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st168.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st168.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st168.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st168.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st168.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st168.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st168.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st168.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st168.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st168.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF168
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 168 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB168 : nodupT PRE_first_tail_x6_r0_body.st168.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup168 : PRE_first_tail_x6_r0_body.st168.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB168).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB168 : PRE_first_tail_x6_r0_body.st168.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound168 : ∀ b ∈ PRE_first_tail_x6_r0_body.st168.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB168 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr168 := PRE_first_tail_x6_r0_body.st168.s5.trace.take 120
kernel_rfl PRE_first_tail_x6_r0_body.traceEq168 : PRE_first_tail_x6_r0_body.st168.s5.trace = PRE_first_tail_x6_r0_body.trFr168 ++ PRE_first_tail_x6_r0_body.st168.s0.trace
theorem PRE_first_tail_x6_r0_body.trace168 : ∃ fr, PRE_first_tail_x6_r0_body.st168.s5.trace = fr ++ PRE_first_tail_x6_r0_body.st168.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq168⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide168 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB168 : (PRE_first_tail_x6_r0_body.wide168.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st168.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix168 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide168, WFix Map.id (Present PRE_first_tail_x6_r0_body.st168.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB168 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL168
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 168 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s1627`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO168 : PRE_first_tail_x6_r0_body.st168.S0.oracle = PRE_first_tail_x6_r0_body.st168.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B168 : PRE_first_tail_x6_r0_body.st168.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st168.s0.next || (PRE_first_tail_x6_r0_body.st168.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot168 : Conv.StageFoot PRE_first_tail_x6_r0_body.st168.wr PRE_first_tail_x6_r0_body.st168.s0 PRE_first_tail_x6_r0_body.st168.s5 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st168.heapFoot PRE_first_tail_x6_r0_body.wrNodup168 PRE_first_tail_x6_r0_body.wrBound168 PRE_first_tail_x6_r0_body.wr0B168 PRE_first_tail_x6_r0_body.st168.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged168 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st168.F.S → PRE_first_tail_x6_r0_body.st168.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st168.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st168.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs168 PRE_first_tail_x6_r0_body.st168.wr PRE_first_tail_x6_r0_body.s1626 PRE_first_tail_x6_r0_body.st168.s5 PRE_first_tail_x6_r0_body.st168.s0
      PRE_first_tail_x6_r0_body.st168.s5.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st168.F FR W stk M ν K PRE_first_tail_x6_r0_body.s1627 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso168 PRE_first_tail_x6_r0_body.stFoot168 PRE_first_tail_x6_r0_body.wrNodup168 PRE_first_tail_x6_r0_body.wrBound168 PRE_first_tail_x6_r0_body.trace168 PRE_first_tail_x6_r0_body.mheap168
    PRE_first_tail_x6_r0_body.mnext168 PRE_first_tail_x6_r0_body.mctl168 PRE_first_tail_x6_r0_body.mstack168 PRE_first_tail_x6_r0_body.mjobs168 PRE_first_tail_x6_r0_body.mffi168 PRE_first_tail_x6_r0_body.mtrace168 PRE_first_tail_x6_r0_body.mstores168 h

def PRE_first_tail_x6_r0_body.arrEl168_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE168_2665 : arrOf PRE_first_tail_x6_r0_body.s1627 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl168_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA168_2665 : isArrB PRE_first_tail_x6_r0_body.s1627 2665 = true
theorem PRE_first_tail_x6_r0_body.arr168_2665 : ∃ o, PRE_first_tail_x6_r0_body.s1627.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl168_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE168_2665 PRE_first_tail_x6_r0_body.arrA168_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN168_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl168_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR168_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl168_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN168_2665

def PRE_first_tail_x6_r0_body.arrEl168_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE168_2673467 : arrOf PRE_first_tail_x6_r0_body.s1627 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl168_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA168_2673467 : isArrB PRE_first_tail_x6_r0_body.s1627 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr168_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s1627.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl168_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE168_2673467 PRE_first_tail_x6_r0_body.arrA168_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN168_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl168_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR168_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl168_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN168_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k168 : isArrB PRE_first_tail_x6_r0_body.s1627 4910 = false
theorem PRE_first_tail_x6_r0_body.keep168 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s1627 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k168 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr168_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl168_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ168
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 168 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s1626`, the merged
state `PRE_first_tail_x6_r0_body.s1627`, the canonical state `PRE_first_tail_x6_r0_body.s1628`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl168 : PRE_first_tail_x6_r0_body.pl168.all (Nat.ble PRE_first_tail_x6_r0_body.s1626.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd168 : nodupT PRE_first_tail_x6_r0_body.pl168 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn1168 : Nat.ble PRE_first_tail_x6_r0_body.s1626.next 2808454 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst168 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s1626.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn168 : PRE_first_tail_x6_r0_body.s1628.next = PRE_first_tail_x6_r0_body.s1626.next + PRE_first_tail_x6_r0_body.pl168.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn168 : PRE_first_tail_x6_r0_body.s1627.next = 2808454
kernel_rfl PRE_first_tail_x6_r0_body.zgrow168 : Nat.ble PRE_first_tail_x6_r0_body.s1628.next PRE_first_tail_x6_r0_body.s1627.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh168 : PRE_first_tail_x6_r0_body.S1626.tab.all (fun e => PRE_first_tail_x6_r0_body.cws168.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd168 : nodupT PRE_first_tail_x6_r0_body.cws168 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi168 : PRE_first_tail_x6_r0_body.nr168.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S1627.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt168 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s1626.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg168_2665 : PRE_first_tail_x6_r0_body.s1628.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1628 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk168_2665 : (objOf PRE_first_tail_x6_r0_body.s1628 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm168_2665 : PRE_first_tail_x6_r0_body.s1627.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa168.obj (objOf PRE_first_tail_x6_r0_body.s1628 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s1627 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg168_2673467 : PRE_first_tail_x6_r0_body.s1628.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1628 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk168_2673467 : (objOf PRE_first_tail_x6_r0_body.s1628 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm168_2673467 : PRE_first_tail_x6_r0_body.s1627.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa168.obj (objOf PRE_first_tail_x6_r0_body.s1628 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s1627 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw168_4910 : (PRE_first_tail_x6_r0_body.s1628.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw168_2673472 : (PRE_first_tail_x6_r0_body.s1628.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw168_2673473 : (PRE_first_tail_x6_r0_body.s1628.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd168 : PRE_first_tail_x6_r0_body.cl168.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr168 : PRE_first_tail_x6_r0_body.st168.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s1626.next || PRE_first_tail_x6_r0_body.cl168.contains b) = true
def PRE_first_tail_x6_r0_body.zl168 : List Nat := PRE_first_tail_x6_r0_body.cl168.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE168 : PRE_first_tail_x6_r0_body.zl168.map (fun a => PRE_first_tail_x6_r0_body.s1627.heap.get (PRE_first_tail_x6_r0_body.kappa168.a a)) = PRE_first_tail_x6_r0_body.zl168.map (fun a => (PRE_first_tail_x6_r0_body.s1628.heap.get a).map PRE_first_tail_x6_r0_body.kappa168.hobj)
theorem PRE_first_tail_x6_r0_body.zimg168 : HeapImg PRE_first_tail_x6_r0_body.kappa168 PRE_first_tail_x6_r0_body.s1628 PRE_first_tail_x6_r0_body.s1627 PRE_first_tail_x6_r0_body.zl168 := PRE_first_tail_x6_r0_body.zimgE168
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl168 : PRE_first_tail_x6_r0_body.s1627.ctl = PRE_first_tail_x6_r0_body.kappa168.ctl PRE_first_tail_x6_r0_body.s1628.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack168 : PRE_first_tail_x6_r0_body.s1627.stack = PRE_first_tail_x6_r0_body.s1628.stack.map PRE_first_tail_x6_r0_body.kappa168.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs168 : PRE_first_tail_x6_r0_body.s1627.jobs = PRE_first_tail_x6_r0_body.s1628.jobs.map PRE_first_tail_x6_r0_body.kappa168.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores168 : PRE_first_tail_x6_r0_body.s1627.stores = PRE_first_tail_x6_r0_body.kappa168.stores PRE_first_tail_x6_r0_body.s1628.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots168 : checkRootsSupp PRE_first_tail_x6_r0_body.s1628 7283 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC168 : PRE_first_tail_x6_r0_body.S1626.tab.length + PRE_first_tail_x6_r0_body.cws168.length = 7283
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap168 : PRE_first_tail_x6_r0_body.kappa168 = Conv.Map.compact PRE_first_tail_x6_r0_body.s1626.next 2808454 PRE_first_tail_x6_r0_body.S1626.tab.length PRE_first_tail_x6_r0_body.pl168 (PRE_first_tail_x6_r0_body.nr168.map NumV.ref) PRE_first_tail_x6_r0_body.kd168.big
  PRE_first_tail_x6_r0_body.kd168.region PRE_first_tail_x6_r0_body.kd168.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin168 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1628.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc168 : Conv.jcleanListB (⟨21523, 18623, 2807305, 7283⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1628 PRE_first_tail_x6_r0_body.cl168 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB168 : noBigRootsP (fun i => !Conv.oldBigB (⟨21523, 18623, 2807305, 7283⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s1628.trace PRE_first_tail_x6_r0_body.s1628 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm168 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 18596 = true
theorem PRE_first_tail_x6_r0_body.cjcl168 (h : Conv.JClean (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1626) : Conv.JClean (⟨21523, 18623, 2807305, 7283⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1628 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle168)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap168 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd168 a ha)) PRE_first_tail_x6_r0_body.zjc168

end Host.Load.Run.Tpl
end

section -- st168/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st168.bodyLast from PRE_first_tail_x6_r0_body.st168.s4 to PRE_first_tail_x6_r0_body.st168.s5 :
  interpS (step PRE_first_tail_x6_r0_body.st168.F PRE_first_tail_x6_r0_body.st168.s4).run PRE_first_tail_x6_r0_body.st168.S4 = some (PRE_first_tail_x6_r0_body.st168.s5, PRE_first_tail_x6_r0_body.st168.S5)
kernel_rfl PRE_first_tail_x6_r0_body.st168.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st168.s4.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st168.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st168.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st168/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st168.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st168.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st168.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st168.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st168.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st168.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st168.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st168.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st168.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st168.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st168.s0 PRE_first_tail_x6_r0_body.st168.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st168.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st168.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st168.s4 PRE_first_tail_x6_r0_body.st168.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st168/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st168.bodyK0F from PRE_first_tail_x6_r0_body.st168.s0 to PRE_first_tail_x6_r0_body.st168.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st168.F (PRE_first_tail_x6_r0_body.st168.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st168.ks 0).getD 0) PRE_first_tail_x6_r0_body.st168.s0 PRE_first_tail_x6_r0_body.st168.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st168.s1, PRE_first_tail_x6_r0_body.st168.S1)
theorem PRE_first_tail_x6_r0_body.st168.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st168.F (PRE_first_tail_x6_r0_body.st168.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st168.ks 0).getD 0) PRE_first_tail_x6_r0_body.st168.s0 PRE_first_tail_x6_r0_body.st168.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st168.s1, PRE_first_tail_x6_r0_body.st168.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st168.bodyOkLN_ok PRE_first_tail_x6_r0_body.st168.bodyK0F
end Host.Load.Run.Tpl
end

section -- st168/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st168.bodyK1F from PRE_first_tail_x6_r0_body.st168.s1 to PRE_first_tail_x6_r0_body.st168.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st168.F (PRE_first_tail_x6_r0_body.st168.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st168.ks 1).getD 0) PRE_first_tail_x6_r0_body.st168.s1 PRE_first_tail_x6_r0_body.st168.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st168.s2, PRE_first_tail_x6_r0_body.st168.S2)
theorem PRE_first_tail_x6_r0_body.st168.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st168.F (PRE_first_tail_x6_r0_body.st168.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st168.ks 1).getD 0) PRE_first_tail_x6_r0_body.st168.s1 PRE_first_tail_x6_r0_body.st168.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st168.s2, PRE_first_tail_x6_r0_body.st168.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st168.bodyOkLN_ok PRE_first_tail_x6_r0_body.st168.bodyK1F
end Host.Load.Run.Tpl
end

section -- st168/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st168.bodyK2F from PRE_first_tail_x6_r0_body.st168.s2 to PRE_first_tail_x6_r0_body.st168.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st168.F (PRE_first_tail_x6_r0_body.st168.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st168.ks 2).getD 0) PRE_first_tail_x6_r0_body.st168.s2 PRE_first_tail_x6_r0_body.st168.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st168.s3, PRE_first_tail_x6_r0_body.st168.S3)
theorem PRE_first_tail_x6_r0_body.st168.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st168.F (PRE_first_tail_x6_r0_body.st168.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st168.ks 2).getD 0) PRE_first_tail_x6_r0_body.st168.s2 PRE_first_tail_x6_r0_body.st168.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st168.s3, PRE_first_tail_x6_r0_body.st168.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st168.bodyOkLN_ok PRE_first_tail_x6_r0_body.st168.bodyK2F
end Host.Load.Run.Tpl
end

section -- st168/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st168.bodyK3F from PRE_first_tail_x6_r0_body.st168.s3 to PRE_first_tail_x6_r0_body.st168.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st168.F (PRE_first_tail_x6_r0_body.st168.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st168.ks 3).getD 0) PRE_first_tail_x6_r0_body.st168.s3 PRE_first_tail_x6_r0_body.st168.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st168.s4, PRE_first_tail_x6_r0_body.st168.S4)
theorem PRE_first_tail_x6_r0_body.st168.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st168.F (PRE_first_tail_x6_r0_body.st168.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st168.ks 3).getD 0) PRE_first_tail_x6_r0_body.st168.s3 PRE_first_tail_x6_r0_body.st168.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st168.s4, PRE_first_tail_x6_r0_body.st168.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st168.bodyOkLN_ok PRE_first_tail_x6_r0_body.st168.bodyK3F
end Host.Load.Run.Tpl
end

section -- st168/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st168.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st168.F (PRE_first_tail_x6_r0_body.st168.bodyOkL bytes rows) 11334 PRE_first_tail_x6_r0_body.st168.s0 PRE_first_tail_x6_r0_body.st168.S0 = some (PRE_first_tail_x6_r0_body.st168.s4, PRE_first_tail_x6_r0_body.st168.S4) :=
  runOk_trans PRE_first_tail_x6_r0_body.st168.F (PRE_first_tail_x6_r0_body.st168.bodyOkL bytes rows) ((((nth? PRE_first_tail_x6_r0_body.st168.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st168.ks 1).getD 0)) + ((nth? PRE_first_tail_x6_r0_body.st168.ks 2).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st168.ks 3).getD 0) PRE_first_tail_x6_r0_body.st168.s0 PRE_first_tail_x6_r0_body.st168.s3 PRE_first_tail_x6_r0_body.st168.s4 PRE_first_tail_x6_r0_body.st168.S0 PRE_first_tail_x6_r0_body.st168.S3 PRE_first_tail_x6_r0_body.st168.S4 (runOk_trans PRE_first_tail_x6_r0_body.st168.F (PRE_first_tail_x6_r0_body.st168.bodyOkL bytes rows) (((nth? PRE_first_tail_x6_r0_body.st168.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st168.ks 1).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st168.ks 2).getD 0) PRE_first_tail_x6_r0_body.st168.s0 PRE_first_tail_x6_r0_body.st168.s2 PRE_first_tail_x6_r0_body.st168.s3 PRE_first_tail_x6_r0_body.st168.S0 PRE_first_tail_x6_r0_body.st168.S2 PRE_first_tail_x6_r0_body.st168.S3 (runOk_trans PRE_first_tail_x6_r0_body.st168.F (PRE_first_tail_x6_r0_body.st168.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st168.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st168.ks 1).getD 0) PRE_first_tail_x6_r0_body.st168.s0 PRE_first_tail_x6_r0_body.st168.s1 PRE_first_tail_x6_r0_body.st168.s2 PRE_first_tail_x6_r0_body.st168.S0 PRE_first_tail_x6_r0_body.st168.S1 PRE_first_tail_x6_r0_body.st168.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st168.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st168.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st168.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st168.bodyK3 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st168.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st168.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st168.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st168.F (PRE_first_tail_x6_r0_body.st168.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st168.s0
  S0 := PRE_first_tail_x6_r0_body.st168.S0
  s1 := PRE_first_tail_x6_r0_body.st168.s4
  S1 := PRE_first_tail_x6_r0_body.st168.S4
  s2 := PRE_first_tail_x6_r0_body.st168.s5
  S2 := PRE_first_tail_x6_r0_body.st168.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st168.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st168.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st168.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st168.bodyHalt
  last := PRE_first_tail_x6_r0_body.st168.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st168.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC169
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 169 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s1636` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa169` into the merged state
`PRE_first_tail_x6_r0_body.s1635`. -/

def PRE_first_tail_x6_r0_body.pl169 : List Nat := []
def PRE_first_tail_x6_r0_body.nr169 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd169 : RData :=
  ⟨2807795, 2807797, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21536, 21536, 18636, 18636, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa169 : Map :=
  Conv.Map.compact 2807795 2807797 7304 PRE_first_tail_x6_r0_body.pl169 (PRE_first_tail_x6_r0_body.nr169.map NumV.ref) PRE_first_tail_x6_r0_body.kd169.big
    PRE_first_tail_x6_r0_body.kd169.region PRE_first_tail_x6_r0_body.kd169.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws169 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs169 : List SymE := PRE_first_tail_x6_r0_body.nr169.map fun r => (nth? PRE_first_tail_x6_r0_body.S1635.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta169 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws169 PRE_first_tail_x6_r0_body.crs169
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB169 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab169 : PRE_first_tail_x6_r0_body.S1636.tab = PRE_first_tail_x6_r0_body.S1634.tab ++ PRE_first_tail_x6_r0_body.cws169.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace169 : PRE_first_tail_x6_r0_body.s1636.trace = PRE_first_tail_x6_r0_body.s1634.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext169 : PRE_first_tail_x6_r0_body.s1636.next = 2807795
kernel_rfl PRE_first_tail_x6_r0_body.ccounters169 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1636.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1636.ffi).mlx.nnext) = (21536, 18636)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue169 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1635.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1636.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa169.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp169 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1636.ffi).mlx.tokens.all (bSN 7304) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean169 : Conv.cleanListB 21536 131072 (fun r => Nat.ble 86144 r) PRE_first_tail_x6_r0_body.s1636
    (PRE_first_tail_x6_r0_body.wrB169 ++ (List.range 0).map (2807795 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs169 : bigsOutB 21536 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1636.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK169
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl169`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl169 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo169 : List Nat := []
def PRE_first_tail_x6_r0_body.cln169 : List Nat := []
def PRE_first_tail_x6_r0_body.cli169 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap169 : PRE_first_tail_x6_r0_body.s1636.heap = Stage.setAll PRE_first_tail_x6_r0_body.s1634.heap (PRE_first_tail_x6_r0_body.cl169.filterMap fun a => (PRE_first_tail_x6_r0_body.s1636.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe169 : Nat.ble PRE_first_tail_x6_r0_body.s1634.next PRE_first_tail_x6_r0_body.s1636.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP169 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s1634 PRE_first_tail_x6_r0_body.s1636 PRE_first_tail_x6_r0_body.cl169 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp169 : Conv.suppListB PRE_first_tail_x6_r0_body.s1636 7304 PRE_first_tail_x6_r0_body.cl169 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound169 : Conv.boundListB PRE_first_tail_x6_r0_body.s1636 PRE_first_tail_x6_r0_body.cl169 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK169 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1636.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln169.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1636.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK169 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1636.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo169.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1636.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK169 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1636.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli169.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1636.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst169 : Conv.sstListB 7304 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1636.ffi).mlx PRE_first_tail_x6_r0_body.cln169 PRE_first_tail_x6_r0_body.clo169 PRE_first_tail_x6_r0_body.cli169 = true

end Host.Load.Run.Tpl
end

section -- SiteCl169
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA169 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1636.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo169.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1636.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd169 : (PRE_first_tail_x6_r0_body.clo169 ++ PRE_first_tail_x6_r0_body.cln169 ++ PRE_first_tail_x6_r0_body.cli169).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle169 : Conv.Cnt.leB (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck169 : Conv.ncleanListB (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1636.ffi).mlx PRE_first_tail_x6_r0_body.clo169 PRE_first_tail_x6_r0_body.cln169 PRE_first_tail_x6_r0_body.cli169 = true
theorem PRE_first_tail_x6_r0_body.cncl169 (h : Conv.NClean (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx) : Conv.NClean (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1636.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle169 PRE_first_tail_x6_r0_body.ckA169 PRE_first_tail_x6_r0_body.cobjsK169 PRE_first_tail_x6_r0_body.cnodesK169 PRE_first_tail_x6_r0_body.citemsK169 PRE_first_tail_x6_r0_body.cbd169 PRE_first_tail_x6_r0_body.cck169

end Host.Load.Run.Tpl
end

section -- SiteS169
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 169 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc169 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P169 : LoadP := PRE_first_tail_x6_r0_body.Pc169.raise 18636
kernel_rfl PRE_first_tail_x6_r0_body.craise169 : Nat.ble PRE_first_tail_x6_r0_body.Pc169.N0 18636 = true
theorem PRE_first_tail_x6_r0_body.raised169 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc169 PRE_first_tail_x6_r0_body.P169 :=
  .inr ⟨18636, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise169, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_169 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1636.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_169 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1635.ffi)
def PRE_first_tail_x6_r0_body.khinv169 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv169 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS169 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS169 : List Nat := List.range' 18636 0
def PRE_first_tail_x6_r0_body.ciS169 : List Nat := [] ++ List.range' 18636 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh0169 : PRE_first_tail_x6_r0_body.kd169.nh0 = PRE_first_tail_x6_r0_body.cx0_169.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh1169 : PRE_first_tail_x6_r0_body.kd169.nh1 = PRE_first_tail_x6_r0_body.cx1_169.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn0169 : PRE_first_tail_x6_r0_body.kd169.nn0 = PRE_first_tail_x6_r0_body.cx0_169.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn1169 : PRE_first_tail_x6_r0_body.kd169.nn1 = PRE_first_tail_x6_r0_body.cx1_169.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo169 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P169.lo && Nat.ble PRE_first_tail_x6_r0_body.P169.lo PRE_first_tail_x6_r0_body.cx0_169.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P169.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P169.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt169 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_169.mlx.next PRE_first_tail_x6_r0_body.cx1_169.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_169.mlx.nnext PRE_first_tail_x6_r0_body.cx1_169.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband169 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P169.NL && Nat.ble PRE_first_tail_x6_r0_body.P169.NL PRE_first_tail_x6_r0_body.P169.N0 && Nat.ble PRE_first_tail_x6_r0_body.P169.N0 PRE_first_tail_x6_r0_body.cx0_169.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow169 : PRE_first_tail_x6_r0_body.kd169.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren169 : checkRenG PRE_first_tail_x6_r0_body.kd169.hnd PRE_first_tail_x6_r0_body.khinv169 (phB PRE_first_tail_x6_r0_body.cx0_169.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband169 : PRE_first_tail_x6_r0_body.kd169.checkBand PRE_first_tail_x6_r0_body.P169.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos169 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd169.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren169 : checkRenG PRE_first_tail_x6_r0_body.kd169.node PRE_first_tail_x6_r0_body.kninv169 (pnB PRE_first_tail_x6_r0_body.cx0_169.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow169 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd169.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P169.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd169.nodeF j) PRE_first_tail_x6_r0_body.cx1_169.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a169 : PRE_first_tail_x6_r0_body.cx0_169.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b169 : PRE_first_tail_x6_r0_body.cx0_169.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok1169 : PRE_first_tail_x6_r0_body.cx1_169.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend169 : PRE_first_tail_x6_r0_body.cx1_169.mlx.pending = PRE_first_tail_x6_r0_body.cx0_169.mlx.pending.map PRE_first_tail_x6_r0_body.kappa169.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh169 : PRE_first_tail_x6_r0_body.cx1_169.mlx.errh = PRE_first_tail_x6_r0_body.cx0_169.mlx.errh.map PRE_first_tail_x6_r0_body.kappa169.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles169 : PRE_first_tail_x6_r0_body.cx1_169.mlx.files = PRE_first_tail_x6_r0_body.cx0_169.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch169 : PRE_first_tail_x6_r0_body.cx1_169.mlx.arch = PRE_first_tail_x6_r0_body.cx0_169.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes169 : PRE_first_tail_x6_r0_body.cx1_169.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_169.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired169 : PRE_first_tail_x6_r0_body.cx1_169.mlx.wired = PRE_first_tail_x6_r0_body.cx0_169.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost169 : PRE_first_tail_x6_r0_body.cx1_169.host = PRE_first_tail_x6_r0_body.cx0_169.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd169`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn0169 : PRE_first_tail_x6_r0_body.kd169.n0 = 2807795
kernel_rfl PRE_first_tail_x6_r0_body.ckn1169 : PRE_first_tail_x6_r0_body.kd169.n1 = 2807797
kernel_rfl PRE_first_tail_x6_r0_body.ckheap169 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd169.heap).all (fun x => Nat.ble 2807795 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl169 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_body.kd169.heap.get (2807795 + j) = nth? PRE_first_tail_x6_r0_body.pl169 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja169 : Nat.ble 2807795 2807795 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn169 : Nat.ble 7304 7304 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD169 : Nat.ble 2807795 PRE_first_tail_x6_r0_body.kd169.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn169 : Nat.ble 21536 PRE_first_tail_x6_r0_body.kd169.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn169 : Nat.ble 18636 PRE_first_tail_x6_r0_body.kd169.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb169 : Nat.ble 21536 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap169 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd169.heap).all (Nat.ble (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd169 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd169.hnd).all (Nat.ble (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode169 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd169.node).all (Nat.ble (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix169 : Conv.FixOld (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa169 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja169) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn169) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD169) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn169) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn169) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb169) PRE_first_tail_x6_r0_body.fheap169 PRE_first_tail_x6_r0_body.fhnd169 PRE_first_tail_x6_r0_body.fnode169
kernel_rfl PRE_first_tail_x6_r0_body.fcxn169 : (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn169 : (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle0169 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_169.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_169.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk169 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd169.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A169 : PRE_first_tail_x6_r0_body.cx1_169.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS169.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_169.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O169 : PRE_first_tail_x6_r0_body.cx1_169.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS169.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_169.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N169 : PRE_first_tail_x6_r0_body.cx1_169.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS169.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_169.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I169 : PRE_first_tail_x6_r0_body.cx1_169.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS169.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_169.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd169 : (PRE_first_tail_x6_r0_body.clo169 ++ PRE_first_tail_x6_r0_body.cln169 ++ PRE_first_tail_x6_r0_body.cli169 ++ PRE_first_tail_x6_r0_body.cwS169 ++ PRE_first_tail_x6_r0_body.cnS169 ++ PRE_first_tail_x6_r0_body.ciS169).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW169 : PRE_first_tail_x6_r0_body.cwS169.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo169.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI169 : PRE_first_tail_x6_r0_body.ciS169.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli169.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN169 : PRE_first_tail_x6_r0_body.cnS169.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF169 : PRE_first_tail_x6_r0_body.cln169.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh169 : PRE_first_tail_x6_r0_body.clo169.all (handleOK PRE_first_tail_x6_r0_body.kappa169 PRE_first_tail_x6_r0_body.P169.lo PRE_first_tail_x6_r0_body.cx0_169.mlx PRE_first_tail_x6_r0_body.cx1_169.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo169 : PRE_first_tail_x6_r0_body.clo169.map (fun h => PRE_first_tail_x6_r0_body.cx1_169.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa169.handle h)) = PRE_first_tail_x6_r0_body.clo169.map (fun h => (PRE_first_tail_x6_r0_body.cx0_169.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa169.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok169 : PRE_first_tail_x6_r0_body.clo169.all (objOK PRE_first_tail_x6_r0_body.kappa169 PRE_first_tail_x6_r0_body.P169.NL PRE_first_tail_x6_r0_body.cx0_169.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd169 : PRE_first_tail_x6_r0_body.cln169.all (nodeOKF PRE_first_tail_x6_r0_body.kappa169 PRE_first_tail_x6_r0_body.P169 PRE_first_tail_x6_r0_body.cx0_169.mlx PRE_first_tail_x6_r0_body.cx1_169.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp169 : ((PRE_first_tail_x6_r0_body.cln169.filter (fullB PRE_first_tail_x6_r0_body.P169))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_169.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa169.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln169.filter (fullB PRE_first_tail_x6_r0_body.P169))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_169.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa169.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI169 : incrB PRE_first_tail_x6_r0_body.kd169.nodeF (List.range' 18636 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK169 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd169.node).all (fun k => Nat.ble 18636 k && Nat.blt k 18636) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL169 : (PRE_first_tail_x6_r0_body.cln169.filter (Nat.ble PRE_first_tail_x6_r0_body.P169.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd169.nodeF i) && (Nat.blt i 18636 || Nat.ble PRE_first_tail_x6_r0_body.kd169.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord169 : (PRE_first_tail_x6_r0_body.cln169.filter (Nat.ble PRE_first_tail_x6_r0_body.P169.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd169.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd169.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd169.nodeF j) (PRE_first_tail_x6_r0_body.kd169.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow169 PRE_first_tail_x6_r0_body.cnn1169 PRE_first_tail_x6_r0_body.fnordI169 PRE_first_tail_x6_r0_body.fnordK169 PRE_first_tail_x6_r0_body.fnordL169
kernel_rfl PRE_first_tail_x6_r0_body.fi169 : PRE_first_tail_x6_r0_body.cli169.all (pnB PRE_first_tail_x6_r0_body.cx0_169.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii169 : PRE_first_tail_x6_r0_body.cli169.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_169.mlx.items.get (PRE_first_tail_x6_r0_body.kappa169.node k) = (PRE_first_tail_x6_r0_body.cx0_169.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa169.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot169 (clean : Conv.NClean (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P169.NL) (cl : SSt (· < 7304) PRE_first_tail_x6_r0_body.cx0_169.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P169 7304 PRE_first_tail_x6_r0_body.kappa169 PRE_first_tail_x6_r0_body.kd169 PRE_first_tail_x6_r0_body.khinv169 PRE_first_tail_x6_r0_body.kninv169 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx PRE_first_tail_x6_r0_body.cx0_169.mlx PRE_first_tail_x6_r0_body.cx1_169.mlx (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo169 PRE_first_tail_x6_r0_body.cln169 PRE_first_tail_x6_r0_body.cli169 PRE_first_tail_x6_r0_body.cwS169 PRE_first_tail_x6_r0_body.cnS169 PRE_first_tail_x6_r0_body.ciS169 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh0169, PRE_first_tail_x6_r0_body.cnh1169, PRE_first_tail_x6_r0_body.cnn0169, PRE_first_tail_x6_r0_body.cnn1169, PRE_first_tail_x6_r0_body.cplo169, PRE_first_tail_x6_r0_body.ccnt169, PRE_first_tail_x6_r0_body.cnband169, PRE_first_tail_x6_r0_body.chbelow169, PRE_first_tail_x6_r0_body.chren169, PRE_first_tail_x6_r0_body.cband169, PRE_first_tail_x6_r0_body.cnh1pos169, PRE_first_tail_x6_r0_body.cnren169, PRE_first_tail_x6_r0_body.cnlow169, PRE_first_tail_x6_r0_body.cabs0a169, PRE_first_tail_x6_r0_body.cabs0b169, PRE_first_tail_x6_r0_body.ctok1169, PRE_first_tail_x6_r0_body.cpend169, PRE_first_tail_x6_r0_body.cerrh169, PRE_first_tail_x6_r0_body.cfiles169, PRE_first_tail_x6_r0_body.carch169, PRE_first_tail_x6_r0_body.csizes169, PRE_first_tail_x6_r0_body.cwired169, PRE_first_tail_x6_r0_body.cfix169, clean, PRE_first_tail_x6_r0_body.fcxn169, PRE_first_tail_x6_r0_body.fcnn169, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle0169, PRE_first_tail_x6_r0_body.fnk169, PRE_first_tail_x6_r0_body.ckA169, PRE_first_tail_x6_r0_body.cobjsK169, PRE_first_tail_x6_r0_body.cnodesK169, PRE_first_tail_x6_r0_body.citemsK169, PRE_first_tail_x6_r0_body.f1A169, PRE_first_tail_x6_r0_body.f1O169, PRE_first_tail_x6_r0_body.f1N169, PRE_first_tail_x6_r0_body.f1I169, PRE_first_tail_x6_r0_body.fbd169, PRE_first_tail_x6_r0_body.fincW169, PRE_first_tail_x6_r0_body.fincI169, PRE_first_tail_x6_r0_body.fincN169, PRE_first_tail_x6_r0_body.flnF169, PRE_first_tail_x6_r0_body.fh169, PRE_first_tail_x6_r0_body.fo169, PRE_first_tail_x6_r0_body.fok169, PRE_first_tail_x6_r0_body.fnd169, PRE_first_tail_x6_r0_body.fp169, PRE_first_tail_x6_r0_body.fnord169, PRE_first_tail_x6_r0_body.fi169, PRE_first_tail_x6_r0_body.fii169⟩
theorem PRE_first_tail_x6_r0_body.cnshift169 (clean : Conv.NClean (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P169.NL) (cl : SSt (· < 7304) PRE_first_tail_x6_r0_body.cx0_169.mlx) : NShift PRE_first_tail_x6_r0_body.P169 7304 PRE_first_tail_x6_r0_body.kappa169 PRE_first_tail_x6_r0_body.cx0_169 PRE_first_tail_x6_r0_body.cx1_169 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot169 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost169 (compact_a_eq PRE_first_tail_x6_r0_body.ckn0169 PRE_first_tail_x6_r0_body.ckn1169 PRE_first_tail_x6_r0_body.ckheap169 PRE_first_tail_x6_r0_body.ckpl169)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_169 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1634.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_169 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1634.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_169 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1634.ffi) = some PRE_first_tail_x6_r0_body.fxC_169
kernel_rfl PRE_first_tail_x6_r0_body.okrC_169 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1634.ffi) = some PRE_first_tail_x6_r0_body.krC_169
noncomputable def PRE_first_tail_x6_r0_body.fx0_169 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1636.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_169 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1636.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_169 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1636.ffi) = some PRE_first_tail_x6_r0_body.fx0_169
kernel_rfl PRE_first_tail_x6_r0_body.okr0_169 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1636.ffi) = some PRE_first_tail_x6_r0_body.kr0_169
noncomputable def PRE_first_tail_x6_r0_body.fx1_169 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1635.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_169 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1635.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_169 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1635.ffi) = some PRE_first_tail_x6_r0_body.fx1_169
kernel_rfl PRE_first_tail_x6_r0_body.okr1_169 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1635.ffi) = some PRE_first_tail_x6_r0_body.kr1_169
kernel_rfl PRE_first_tail_x6_r0_body.ff0169 : PRE_first_tail_x6_r0_body.fx0_169 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_169 (PRE_first_tail_x6_r0_body.clo169.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_169.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff1169 : PRE_first_tail_x6_r0_body.fx1_169 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_169 (PRE_first_tail_x6_r0_body.cwS169.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_169.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck169 : freedLB PRE_first_tail_x6_r0_body.kappa169 PRE_first_tail_x6_r0_body.cx0_169.mlx PRE_first_tail_x6_r0_body.fx0_169 PRE_first_tail_x6_r0_body.fx1_169 PRE_first_tail_x6_r0_body.clo169 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf0169 : PRE_first_tail_x6_r0_body.kr0_169.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_169.flags (PRE_first_tail_x6_r0_body.clo169.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_169.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt0169 : PRE_first_tail_x6_r0_body.kr0_169.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_169.targs (PRE_first_tail_x6_r0_body.clo169.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_169.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf1169 : PRE_first_tail_x6_r0_body.kr1_169.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_169.flags (PRE_first_tail_x6_r0_body.cwS169.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_169.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt1169 : PRE_first_tail_x6_r0_body.kr1_169.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_169.targs (PRE_first_tail_x6_r0_body.cwS169.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_169.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck169 : krecLB PRE_first_tail_x6_r0_body.kappa169 7304 PRE_first_tail_x6_r0_body.cx0_169.mlx PRE_first_tail_x6_r0_body.kr0_169 PRE_first_tail_x6_r0_body.kr1_169 PRE_first_tail_x6_r0_body.clo169 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn169 : Nat.ble 7304 7304 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge169 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1635.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1636.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR169 : pendRegB PRE_first_tail_x6_r0_body.kappa169 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1636.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe169 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1636.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1635.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift169 (clean : Conv.NClean (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P169.NL) (cl : SSt (· < 7304) PRE_first_tail_x6_r0_body.cx0_169.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_169.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_169.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_169.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1634.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_169.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P169 7304 PRE_first_tail_x6_r0_body.kappa169 PRE_first_tail_x6_r0_body.s1636.ffi PRE_first_tail_x6_r0_body.s1635.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift169 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue169, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp169 t ht),
    PRE_first_tail_x6_r0_body.cbridge169,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1636.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1635.ffi) (PRE_first_tail_x6_r0_body.cfoot169 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_169 PRE_first_tail_x6_r0_body.ofx1_169 hobjC PRE_first_tail_x6_r0_body.ff0169 PRE_first_tail_x6_r0_body.ff1169 PRE_first_tail_x6_r0_body.ffck169,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1636.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1635.ffi) (PRE_first_tail_x6_r0_body.cfoot169 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_169 PRE_first_tail_x6_r0_body.okr1_169 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn169) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf0169 PRE_first_tail_x6_r0_body.fkt0169 PRE_first_tail_x6_r0_body.fkf1169 PRE_first_tail_x6_r0_body.fkt1169 PRE_first_tail_x6_r0_body.fkck169,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh0169 PRE_first_tail_x6_r0_body.cnh1169 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe169) PRE_first_tail_x6_r0_body.cpendR169⟩

end Host.Load.Run.Tpl
end

section -- st169/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st169 0
host_stream_state PRE_first_tail_x6_r0_body.st169 1
host_stream_state PRE_first_tail_x6_r0_body.st169 2
end Host.Load.Run.Tpl
end

section -- Site169
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 169 of chain `PRE_first_tail_x6_r0_body`: `rowBlocks__g169__g170` (`rowBlocks`), the call state `PRE_first_tail_x6_r0_body.s1634`, the merged state `PRE_first_tail_x6_r0_body.s1635`,
the site template `PRE_first_tail_x6_r0_body.st169` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s1636`: the merge.
The footprint's facts are in `SiteF169`, the compaction's in `SiteC169`, `SiteK169`, `SiteNa169`, `SiteNb169`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso169 : PRE_first_tail_x6_r0_body.st169.s0 = { PRE_first_tail_x6_r0_body.s1634 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs169 : List Frame := PRE_first_tail_x6_r0_body.s1634.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_169 : PRE_first_tail_x6_r0_body.S1634.tab.length = 7304
kernel_rfl PRE_first_tail_x6_r0_body.tab0_169 : PRE_first_tail_x6_r0_body.st169.S0.tab = PRE_first_tail_x6_r0_body.S1634.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws169 : List Nat := [3859, 3860]
kernel_rfl PRE_first_tail_x6_r0_body.fresh169 : (PRE_first_tail_x6_r0_body.S1634.tab.all fun e => PRE_first_tail_x6_r0_body.ws169.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S1634.oracle.all fun q => PRE_first_tail_x6_r0_body.ws169.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab169 : PRE_first_tail_x6_r0_body.S1635.tab = PRE_first_tail_x6_r0_body.S1634.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws169
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen169 : PRE_first_tail_x6_r0_body.st169.S2.tab.length - PRE_first_tail_x6_r0_body.st169.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged169`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap169 : PRE_first_tail_x6_r0_body.s1635.heap = PRE_first_tail_x6_r0_body.st169.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext169 : PRE_first_tail_x6_r0_body.s1635.next = PRE_first_tail_x6_r0_body.st169.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl169 : PRE_first_tail_x6_r0_body.s1635.ctl = PRE_first_tail_x6_r0_body.st169.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack169 : PRE_first_tail_x6_r0_body.s1635.stack = PRE_first_tail_x6_r0_body.st169.s2.stack ++ PRE_first_tail_x6_r0_body.s1634.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs169 : PRE_first_tail_x6_r0_body.s1635.jobs = PRE_first_tail_x6_r0_body.st169.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi169 : PRE_first_tail_x6_r0_body.s1635.ffi = PRE_first_tail_x6_r0_body.st169.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace169 : PRE_first_tail_x6_r0_body.s1635.trace = PRE_first_tail_x6_r0_body.st169.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores169 : PRE_first_tail_x6_r0_body.s1635.stores = PRE_first_tail_x6_r0_body.st169.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD169
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 169 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived169 : PRE_first_tail_x6_r0_body.nr169.map (fun r => nth? PRE_first_tail_x6_r0_body.st169.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo169 : PRE_first_tail_x6_r0_body.nr169.all (Nat.ble 7304) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj169 : PRE_first_tail_x6_r0_body.cws169.all (fun c => !PRE_first_tail_x6_r0_body.ws169.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ169 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws169 PRE_first_tail_x6_r0_body.crs169 PRE_first_tail_x6_r0_body.ws169

end Host.Load.Run.Tpl
end

section -- st169/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st169`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st169.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st169.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st169.s2.heap PRE_first_tail_x6_r0_body.st169.wrR ++ freshOf PRE_first_tail_x6_r0_body.st169.s2.heap PRE_first_tail_x6_r0_body.st169.s0.next PRE_first_tail_x6_r0_body.st169.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st169.wr : List Nat := PRE_first_tail_x6_r0_body.st169.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st169.heapFoot : PRE_first_tail_x6_r0_body.st169.s2.heap = setAll PRE_first_tail_x6_r0_body.st169.s0.heap PRE_first_tail_x6_r0_body.st169.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st169.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st169.s0.next PRE_first_tail_x6_r0_body.st169.s2.next = true
theorem PRE_first_tail_x6_r0_body.st169.grows : PRE_first_tail_x6_r0_body.st169.s0.next ≤ PRE_first_tail_x6_r0_body.st169.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st169.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st169.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st169.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st169.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st169.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st169.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st169.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st169.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st169.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st169.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st169.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st169.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st169.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st169.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st169.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st169.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st169.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st169.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st169.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st169.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st169.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st169.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st169.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st169.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st169.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st169.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st169.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st169.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st169.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st169.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st169.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st169.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF169
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 169 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB169 : nodupT PRE_first_tail_x6_r0_body.st169.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup169 : PRE_first_tail_x6_r0_body.st169.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB169).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB169 : PRE_first_tail_x6_r0_body.st169.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound169 : ∀ b ∈ PRE_first_tail_x6_r0_body.st169.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB169 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr169 := PRE_first_tail_x6_r0_body.st169.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq169 : PRE_first_tail_x6_r0_body.st169.s2.trace = PRE_first_tail_x6_r0_body.trFr169 ++ PRE_first_tail_x6_r0_body.st169.s0.trace
theorem PRE_first_tail_x6_r0_body.trace169 : ∃ fr, PRE_first_tail_x6_r0_body.st169.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st169.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq169⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide169 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB169 : (PRE_first_tail_x6_r0_body.wide169.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st169.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix169 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide169, WFix Map.id (Present PRE_first_tail_x6_r0_body.st169.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB169 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL169
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 169 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s1635`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO169 : PRE_first_tail_x6_r0_body.st169.S0.oracle = PRE_first_tail_x6_r0_body.st169.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B169 : PRE_first_tail_x6_r0_body.st169.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st169.s0.next || (PRE_first_tail_x6_r0_body.st169.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot169 : Conv.StageFoot PRE_first_tail_x6_r0_body.st169.wr PRE_first_tail_x6_r0_body.st169.s0 PRE_first_tail_x6_r0_body.st169.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st169.heapFoot PRE_first_tail_x6_r0_body.wrNodup169 PRE_first_tail_x6_r0_body.wrBound169 PRE_first_tail_x6_r0_body.wr0B169 PRE_first_tail_x6_r0_body.st169.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged169 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st169.F.S → PRE_first_tail_x6_r0_body.st169.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st169.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st169.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs169 PRE_first_tail_x6_r0_body.st169.wr PRE_first_tail_x6_r0_body.s1634 PRE_first_tail_x6_r0_body.st169.s2 PRE_first_tail_x6_r0_body.st169.s0
      PRE_first_tail_x6_r0_body.st169.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st169.F FR W stk M ν K PRE_first_tail_x6_r0_body.s1635 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso169 PRE_first_tail_x6_r0_body.stFoot169 PRE_first_tail_x6_r0_body.wrNodup169 PRE_first_tail_x6_r0_body.wrBound169 PRE_first_tail_x6_r0_body.trace169 PRE_first_tail_x6_r0_body.mheap169
    PRE_first_tail_x6_r0_body.mnext169 PRE_first_tail_x6_r0_body.mctl169 PRE_first_tail_x6_r0_body.mstack169 PRE_first_tail_x6_r0_body.mjobs169 PRE_first_tail_x6_r0_body.mffi169 PRE_first_tail_x6_r0_body.mtrace169 PRE_first_tail_x6_r0_body.mstores169 h

def PRE_first_tail_x6_r0_body.arrEl169_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE169_2665 : arrOf PRE_first_tail_x6_r0_body.s1635 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl169_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA169_2665 : isArrB PRE_first_tail_x6_r0_body.s1635 2665 = true
theorem PRE_first_tail_x6_r0_body.arr169_2665 : ∃ o, PRE_first_tail_x6_r0_body.s1635.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl169_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE169_2665 PRE_first_tail_x6_r0_body.arrA169_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN169_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl169_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR169_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl169_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN169_2665

def PRE_first_tail_x6_r0_body.arrEl169_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE169_2673467 : arrOf PRE_first_tail_x6_r0_body.s1635 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl169_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA169_2673467 : isArrB PRE_first_tail_x6_r0_body.s1635 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr169_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s1635.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl169_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE169_2673467 PRE_first_tail_x6_r0_body.arrA169_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN169_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl169_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR169_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl169_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN169_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k169 : isArrB PRE_first_tail_x6_r0_body.s1635 4910 = false
theorem PRE_first_tail_x6_r0_body.keep169 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s1635 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k169 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr169_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl169_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ169
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 169 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s1634`, the merged
state `PRE_first_tail_x6_r0_body.s1635`, the canonical state `PRE_first_tail_x6_r0_body.s1636`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl169 : PRE_first_tail_x6_r0_body.pl169.all (Nat.ble PRE_first_tail_x6_r0_body.s1634.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd169 : nodupT PRE_first_tail_x6_r0_body.pl169 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn1169 : Nat.ble PRE_first_tail_x6_r0_body.s1634.next 2807797 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst169 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s1634.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn169 : PRE_first_tail_x6_r0_body.s1636.next = PRE_first_tail_x6_r0_body.s1634.next + PRE_first_tail_x6_r0_body.pl169.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn169 : PRE_first_tail_x6_r0_body.s1635.next = 2807797
kernel_rfl PRE_first_tail_x6_r0_body.zgrow169 : Nat.ble PRE_first_tail_x6_r0_body.s1636.next PRE_first_tail_x6_r0_body.s1635.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh169 : PRE_first_tail_x6_r0_body.S1634.tab.all (fun e => PRE_first_tail_x6_r0_body.cws169.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd169 : nodupT PRE_first_tail_x6_r0_body.cws169 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi169 : PRE_first_tail_x6_r0_body.nr169.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S1635.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt169 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s1634.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg169_2665 : PRE_first_tail_x6_r0_body.s1636.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1636 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk169_2665 : (objOf PRE_first_tail_x6_r0_body.s1636 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm169_2665 : PRE_first_tail_x6_r0_body.s1635.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa169.obj (objOf PRE_first_tail_x6_r0_body.s1636 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s1635 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg169_2673467 : PRE_first_tail_x6_r0_body.s1636.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1636 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk169_2673467 : (objOf PRE_first_tail_x6_r0_body.s1636 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm169_2673467 : PRE_first_tail_x6_r0_body.s1635.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa169.obj (objOf PRE_first_tail_x6_r0_body.s1636 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s1635 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw169_4910 : (PRE_first_tail_x6_r0_body.s1636.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw169_2673472 : (PRE_first_tail_x6_r0_body.s1636.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw169_2673473 : (PRE_first_tail_x6_r0_body.s1636.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd169 : PRE_first_tail_x6_r0_body.cl169.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr169 : PRE_first_tail_x6_r0_body.st169.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s1634.next || PRE_first_tail_x6_r0_body.cl169.contains b) = true
def PRE_first_tail_x6_r0_body.zl169 : List Nat := PRE_first_tail_x6_r0_body.cl169.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE169 : PRE_first_tail_x6_r0_body.zl169.map (fun a => PRE_first_tail_x6_r0_body.s1635.heap.get (PRE_first_tail_x6_r0_body.kappa169.a a)) = PRE_first_tail_x6_r0_body.zl169.map (fun a => (PRE_first_tail_x6_r0_body.s1636.heap.get a).map PRE_first_tail_x6_r0_body.kappa169.hobj)
theorem PRE_first_tail_x6_r0_body.zimg169 : HeapImg PRE_first_tail_x6_r0_body.kappa169 PRE_first_tail_x6_r0_body.s1636 PRE_first_tail_x6_r0_body.s1635 PRE_first_tail_x6_r0_body.zl169 := PRE_first_tail_x6_r0_body.zimgE169
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl169 : PRE_first_tail_x6_r0_body.s1635.ctl = PRE_first_tail_x6_r0_body.kappa169.ctl PRE_first_tail_x6_r0_body.s1636.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack169 : PRE_first_tail_x6_r0_body.s1635.stack = PRE_first_tail_x6_r0_body.s1636.stack.map PRE_first_tail_x6_r0_body.kappa169.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs169 : PRE_first_tail_x6_r0_body.s1635.jobs = PRE_first_tail_x6_r0_body.s1636.jobs.map PRE_first_tail_x6_r0_body.kappa169.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores169 : PRE_first_tail_x6_r0_body.s1635.stores = PRE_first_tail_x6_r0_body.kappa169.stores PRE_first_tail_x6_r0_body.s1636.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots169 : checkRootsSupp PRE_first_tail_x6_r0_body.s1636 7304 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC169 : PRE_first_tail_x6_r0_body.S1634.tab.length + PRE_first_tail_x6_r0_body.cws169.length = 7304
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap169 : PRE_first_tail_x6_r0_body.kappa169 = Conv.Map.compact PRE_first_tail_x6_r0_body.s1634.next 2807797 PRE_first_tail_x6_r0_body.S1634.tab.length PRE_first_tail_x6_r0_body.pl169 (PRE_first_tail_x6_r0_body.nr169.map NumV.ref) PRE_first_tail_x6_r0_body.kd169.big
  PRE_first_tail_x6_r0_body.kd169.region PRE_first_tail_x6_r0_body.kd169.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin169 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1636.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc169 : Conv.jcleanListB (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1636 PRE_first_tail_x6_r0_body.cl169 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB169 : noBigRootsP (fun i => !Conv.oldBigB (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s1636.trace PRE_first_tail_x6_r0_body.s1636 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm169 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 18636 = true
theorem PRE_first_tail_x6_r0_body.cjcl169 (h : Conv.JClean (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1634) : Conv.JClean (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1636 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle169)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap169 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd169 a ha)) PRE_first_tail_x6_r0_body.zjc169

end Host.Load.Run.Tpl
end

section -- st169/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st169.bodyLast from PRE_first_tail_x6_r0_body.st169.s1 to PRE_first_tail_x6_r0_body.st169.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st169.F PRE_first_tail_x6_r0_body.st169.s1).run PRE_first_tail_x6_r0_body.st169.S1 = some (PRE_first_tail_x6_r0_body.st169.s2, PRE_first_tail_x6_r0_body.st169.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st169.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st169.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st169.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st169.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st169/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st169.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st169.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st169.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st169.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st169.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st169.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st169.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st169.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st169.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st169.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st169.s0 PRE_first_tail_x6_r0_body.st169.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st169.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st169.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st169.s1 PRE_first_tail_x6_r0_body.st169.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st169/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st169.bodyK0F from PRE_first_tail_x6_r0_body.st169.s0 to PRE_first_tail_x6_r0_body.st169.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st169.F (PRE_first_tail_x6_r0_body.st169.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st169.ks 0).getD 0) PRE_first_tail_x6_r0_body.st169.s0 PRE_first_tail_x6_r0_body.st169.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st169.s1, PRE_first_tail_x6_r0_body.st169.S1)
theorem PRE_first_tail_x6_r0_body.st169.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st169.F (PRE_first_tail_x6_r0_body.st169.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st169.ks 0).getD 0) PRE_first_tail_x6_r0_body.st169.s0 PRE_first_tail_x6_r0_body.st169.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st169.s1, PRE_first_tail_x6_r0_body.st169.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st169.bodyOkLN_ok PRE_first_tail_x6_r0_body.st169.bodyK0F
end Host.Load.Run.Tpl
end

section -- st169/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st169.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st169.F (PRE_first_tail_x6_r0_body.st169.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st169.s0 PRE_first_tail_x6_r0_body.st169.S0 = some (PRE_first_tail_x6_r0_body.st169.s1, PRE_first_tail_x6_r0_body.st169.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st169.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st169.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st169.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st169.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st169.F (PRE_first_tail_x6_r0_body.st169.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st169.s0
  S0 := PRE_first_tail_x6_r0_body.st169.S0
  s1 := PRE_first_tail_x6_r0_body.st169.s1
  S1 := PRE_first_tail_x6_r0_body.st169.S1
  s2 := PRE_first_tail_x6_r0_body.st169.s2
  S2 := PRE_first_tail_x6_r0_body.st169.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st169.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st169.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st169.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st169.bodyHalt
  last := PRE_first_tail_x6_r0_body.st169.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st169.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC170
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 170 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s1640` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa170` into the merged state
`PRE_first_tail_x6_r0_body.s1639`. -/

def PRE_first_tail_x6_r0_body.pl170 : List Nat := [2808102]
def PRE_first_tail_x6_r0_body.nr170 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd170 : RData :=
  ⟨2808084, 2808103, Stage.setAll PTrie.nil [(2808083, 2808102)], Stage.setAll PTrie.nil [],
   21543, 21543, 18640, 18640, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa170 : Map :=
  Conv.Map.compact 2808083 2808103 7321 PRE_first_tail_x6_r0_body.pl170 (PRE_first_tail_x6_r0_body.nr170.map NumV.ref) PRE_first_tail_x6_r0_body.kd170.big
    PRE_first_tail_x6_r0_body.kd170.region PRE_first_tail_x6_r0_body.kd170.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws170 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs170 : List SymE := PRE_first_tail_x6_r0_body.nr170.map fun r => (nth? PRE_first_tail_x6_r0_body.S1639.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta170 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws170 PRE_first_tail_x6_r0_body.crs170
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB170 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab170 : PRE_first_tail_x6_r0_body.S1640.tab = PRE_first_tail_x6_r0_body.S1638.tab ++ PRE_first_tail_x6_r0_body.cws170.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace170 : PRE_first_tail_x6_r0_body.s1640.trace = PRE_first_tail_x6_r0_body.s1638.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext170 : PRE_first_tail_x6_r0_body.s1640.next = 2808084
kernel_rfl PRE_first_tail_x6_r0_body.ccounters170 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1640.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1640.ffi).mlx.nnext) = (21543, 18640)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue170 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1639.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1640.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa170.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp170 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1640.ffi).mlx.tokens.all (bSN 7321) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean170 : Conv.cleanListB 21543 131072 (fun r => Nat.ble 86172 r) PRE_first_tail_x6_r0_body.s1640
    (PRE_first_tail_x6_r0_body.wrB170 ++ (List.range 1).map (2808083 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs170 : bigsOutB 21543 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1640.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK170
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl170`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl170 : List Nat := [2665, 2673467, 2808083]
def PRE_first_tail_x6_r0_body.clo170 : List Nat := []
def PRE_first_tail_x6_r0_body.cln170 : List Nat := []
def PRE_first_tail_x6_r0_body.cli170 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap170 : PRE_first_tail_x6_r0_body.s1640.heap = Stage.setAll PRE_first_tail_x6_r0_body.s1638.heap (PRE_first_tail_x6_r0_body.cl170.filterMap fun a => (PRE_first_tail_x6_r0_body.s1640.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe170 : Nat.ble PRE_first_tail_x6_r0_body.s1638.next PRE_first_tail_x6_r0_body.s1640.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP170 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s1638 PRE_first_tail_x6_r0_body.s1640 PRE_first_tail_x6_r0_body.cl170 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp170 : Conv.suppListB PRE_first_tail_x6_r0_body.s1640 7321 PRE_first_tail_x6_r0_body.cl170 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound170 : Conv.boundListB PRE_first_tail_x6_r0_body.s1640 PRE_first_tail_x6_r0_body.cl170 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK170 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1640.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln170.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1640.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK170 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1640.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo170.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1640.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK170 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1640.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli170.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1640.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst170 : Conv.sstListB 7321 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1640.ffi).mlx PRE_first_tail_x6_r0_body.cln170 PRE_first_tail_x6_r0_body.clo170 PRE_first_tail_x6_r0_body.cli170 = true

end Host.Load.Run.Tpl
end

section -- SiteCl170
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA170 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1640.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo170.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1640.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd170 : (PRE_first_tail_x6_r0_body.clo170 ++ PRE_first_tail_x6_r0_body.cln170 ++ PRE_first_tail_x6_r0_body.cli170).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle170 : Conv.Cnt.leB (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt) (⟨21543, 18640, 2808084, 7321⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck170 : Conv.ncleanListB (⟨21543, 18640, 2808084, 7321⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1640.ffi).mlx PRE_first_tail_x6_r0_body.clo170 PRE_first_tail_x6_r0_body.cln170 PRE_first_tail_x6_r0_body.cli170 = true
theorem PRE_first_tail_x6_r0_body.cncl170 (h : Conv.NClean (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx) : Conv.NClean (⟨21543, 18640, 2808084, 7321⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1640.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle170 PRE_first_tail_x6_r0_body.ckA170 PRE_first_tail_x6_r0_body.cobjsK170 PRE_first_tail_x6_r0_body.cnodesK170 PRE_first_tail_x6_r0_body.citemsK170 PRE_first_tail_x6_r0_body.cbd170 PRE_first_tail_x6_r0_body.cck170

end Host.Load.Run.Tpl
end

section -- SiteS170
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 170 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc170 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P170 : LoadP := PRE_first_tail_x6_r0_body.Pc170.raise 18640
kernel_rfl PRE_first_tail_x6_r0_body.craise170 : Nat.ble PRE_first_tail_x6_r0_body.Pc170.N0 18640 = true
theorem PRE_first_tail_x6_r0_body.raised170 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc170 PRE_first_tail_x6_r0_body.P170 :=
  .inr ⟨18640, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise170, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_170 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1640.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_170 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1639.ffi)
def PRE_first_tail_x6_r0_body.khinv170 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv170 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS170 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS170 : List Nat := List.range' 18640 0
def PRE_first_tail_x6_r0_body.ciS170 : List Nat := [] ++ List.range' 18640 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh0170 : PRE_first_tail_x6_r0_body.kd170.nh0 = PRE_first_tail_x6_r0_body.cx0_170.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh1170 : PRE_first_tail_x6_r0_body.kd170.nh1 = PRE_first_tail_x6_r0_body.cx1_170.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn0170 : PRE_first_tail_x6_r0_body.kd170.nn0 = PRE_first_tail_x6_r0_body.cx0_170.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn1170 : PRE_first_tail_x6_r0_body.kd170.nn1 = PRE_first_tail_x6_r0_body.cx1_170.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo170 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P170.lo && Nat.ble PRE_first_tail_x6_r0_body.P170.lo PRE_first_tail_x6_r0_body.cx0_170.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P170.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P170.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt170 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_170.mlx.next PRE_first_tail_x6_r0_body.cx1_170.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_170.mlx.nnext PRE_first_tail_x6_r0_body.cx1_170.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband170 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P170.NL && Nat.ble PRE_first_tail_x6_r0_body.P170.NL PRE_first_tail_x6_r0_body.P170.N0 && Nat.ble PRE_first_tail_x6_r0_body.P170.N0 PRE_first_tail_x6_r0_body.cx0_170.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow170 : PRE_first_tail_x6_r0_body.kd170.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren170 : checkRenG PRE_first_tail_x6_r0_body.kd170.hnd PRE_first_tail_x6_r0_body.khinv170 (phB PRE_first_tail_x6_r0_body.cx0_170.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband170 : PRE_first_tail_x6_r0_body.kd170.checkBand PRE_first_tail_x6_r0_body.P170.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos170 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd170.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren170 : checkRenG PRE_first_tail_x6_r0_body.kd170.node PRE_first_tail_x6_r0_body.kninv170 (pnB PRE_first_tail_x6_r0_body.cx0_170.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow170 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd170.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P170.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd170.nodeF j) PRE_first_tail_x6_r0_body.cx1_170.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a170 : PRE_first_tail_x6_r0_body.cx0_170.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b170 : PRE_first_tail_x6_r0_body.cx0_170.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok1170 : PRE_first_tail_x6_r0_body.cx1_170.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend170 : PRE_first_tail_x6_r0_body.cx1_170.mlx.pending = PRE_first_tail_x6_r0_body.cx0_170.mlx.pending.map PRE_first_tail_x6_r0_body.kappa170.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh170 : PRE_first_tail_x6_r0_body.cx1_170.mlx.errh = PRE_first_tail_x6_r0_body.cx0_170.mlx.errh.map PRE_first_tail_x6_r0_body.kappa170.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles170 : PRE_first_tail_x6_r0_body.cx1_170.mlx.files = PRE_first_tail_x6_r0_body.cx0_170.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch170 : PRE_first_tail_x6_r0_body.cx1_170.mlx.arch = PRE_first_tail_x6_r0_body.cx0_170.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes170 : PRE_first_tail_x6_r0_body.cx1_170.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_170.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired170 : PRE_first_tail_x6_r0_body.cx1_170.mlx.wired = PRE_first_tail_x6_r0_body.cx0_170.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost170 : PRE_first_tail_x6_r0_body.cx1_170.host = PRE_first_tail_x6_r0_body.cx0_170.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd170`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn0170 : PRE_first_tail_x6_r0_body.kd170.n0 = 2808084
kernel_rfl PRE_first_tail_x6_r0_body.ckn1170 : PRE_first_tail_x6_r0_body.kd170.n1 = 2808103
kernel_rfl PRE_first_tail_x6_r0_body.ckheap170 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd170.heap).all (fun x => Nat.ble 2808083 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl170 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd170.heap.get (2808083 + j) = nth? PRE_first_tail_x6_r0_body.pl170 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja170 : Nat.ble 2808083 2808083 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn170 : Nat.ble 7321 7321 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD170 : Nat.ble 2808083 PRE_first_tail_x6_r0_body.kd170.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn170 : Nat.ble 21543 PRE_first_tail_x6_r0_body.kd170.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn170 : Nat.ble 18640 PRE_first_tail_x6_r0_body.kd170.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb170 : Nat.ble 21543 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap170 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd170.heap).all (Nat.ble (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd170 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd170.hnd).all (Nat.ble (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode170 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd170.node).all (Nat.ble (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix170 : Conv.FixOld (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa170 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja170) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn170) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD170) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn170) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn170) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb170) PRE_first_tail_x6_r0_body.fheap170 PRE_first_tail_x6_r0_body.fhnd170 PRE_first_tail_x6_r0_body.fnode170
kernel_rfl PRE_first_tail_x6_r0_body.fcxn170 : (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn170 : (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle0170 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_170.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_170.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk170 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd170.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A170 : PRE_first_tail_x6_r0_body.cx1_170.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS170.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_170.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O170 : PRE_first_tail_x6_r0_body.cx1_170.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS170.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_170.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N170 : PRE_first_tail_x6_r0_body.cx1_170.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS170.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_170.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I170 : PRE_first_tail_x6_r0_body.cx1_170.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS170.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_170.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd170 : (PRE_first_tail_x6_r0_body.clo170 ++ PRE_first_tail_x6_r0_body.cln170 ++ PRE_first_tail_x6_r0_body.cli170 ++ PRE_first_tail_x6_r0_body.cwS170 ++ PRE_first_tail_x6_r0_body.cnS170 ++ PRE_first_tail_x6_r0_body.ciS170).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW170 : PRE_first_tail_x6_r0_body.cwS170.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo170.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI170 : PRE_first_tail_x6_r0_body.ciS170.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli170.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN170 : PRE_first_tail_x6_r0_body.cnS170.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF170 : PRE_first_tail_x6_r0_body.cln170.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh170 : PRE_first_tail_x6_r0_body.clo170.all (handleOK PRE_first_tail_x6_r0_body.kappa170 PRE_first_tail_x6_r0_body.P170.lo PRE_first_tail_x6_r0_body.cx0_170.mlx PRE_first_tail_x6_r0_body.cx1_170.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo170 : PRE_first_tail_x6_r0_body.clo170.map (fun h => PRE_first_tail_x6_r0_body.cx1_170.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa170.handle h)) = PRE_first_tail_x6_r0_body.clo170.map (fun h => (PRE_first_tail_x6_r0_body.cx0_170.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa170.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok170 : PRE_first_tail_x6_r0_body.clo170.all (objOK PRE_first_tail_x6_r0_body.kappa170 PRE_first_tail_x6_r0_body.P170.NL PRE_first_tail_x6_r0_body.cx0_170.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd170 : PRE_first_tail_x6_r0_body.cln170.all (nodeOKF PRE_first_tail_x6_r0_body.kappa170 PRE_first_tail_x6_r0_body.P170 PRE_first_tail_x6_r0_body.cx0_170.mlx PRE_first_tail_x6_r0_body.cx1_170.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp170 : ((PRE_first_tail_x6_r0_body.cln170.filter (fullB PRE_first_tail_x6_r0_body.P170))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_170.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa170.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln170.filter (fullB PRE_first_tail_x6_r0_body.P170))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_170.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa170.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI170 : incrB PRE_first_tail_x6_r0_body.kd170.nodeF (List.range' 18640 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK170 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd170.node).all (fun k => Nat.ble 18640 k && Nat.blt k 18640) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL170 : (PRE_first_tail_x6_r0_body.cln170.filter (Nat.ble PRE_first_tail_x6_r0_body.P170.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd170.nodeF i) && (Nat.blt i 18640 || Nat.ble PRE_first_tail_x6_r0_body.kd170.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord170 : (PRE_first_tail_x6_r0_body.cln170.filter (Nat.ble PRE_first_tail_x6_r0_body.P170.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd170.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd170.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd170.nodeF j) (PRE_first_tail_x6_r0_body.kd170.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow170 PRE_first_tail_x6_r0_body.cnn1170 PRE_first_tail_x6_r0_body.fnordI170 PRE_first_tail_x6_r0_body.fnordK170 PRE_first_tail_x6_r0_body.fnordL170
kernel_rfl PRE_first_tail_x6_r0_body.fi170 : PRE_first_tail_x6_r0_body.cli170.all (pnB PRE_first_tail_x6_r0_body.cx0_170.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii170 : PRE_first_tail_x6_r0_body.cli170.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_170.mlx.items.get (PRE_first_tail_x6_r0_body.kappa170.node k) = (PRE_first_tail_x6_r0_body.cx0_170.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa170.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot170 (clean : Conv.NClean (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P170.NL) (cl : SSt (· < 7321) PRE_first_tail_x6_r0_body.cx0_170.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P170 7321 PRE_first_tail_x6_r0_body.kappa170 PRE_first_tail_x6_r0_body.kd170 PRE_first_tail_x6_r0_body.khinv170 PRE_first_tail_x6_r0_body.kninv170 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx PRE_first_tail_x6_r0_body.cx0_170.mlx PRE_first_tail_x6_r0_body.cx1_170.mlx (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo170 PRE_first_tail_x6_r0_body.cln170 PRE_first_tail_x6_r0_body.cli170 PRE_first_tail_x6_r0_body.cwS170 PRE_first_tail_x6_r0_body.cnS170 PRE_first_tail_x6_r0_body.ciS170 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh0170, PRE_first_tail_x6_r0_body.cnh1170, PRE_first_tail_x6_r0_body.cnn0170, PRE_first_tail_x6_r0_body.cnn1170, PRE_first_tail_x6_r0_body.cplo170, PRE_first_tail_x6_r0_body.ccnt170, PRE_first_tail_x6_r0_body.cnband170, PRE_first_tail_x6_r0_body.chbelow170, PRE_first_tail_x6_r0_body.chren170, PRE_first_tail_x6_r0_body.cband170, PRE_first_tail_x6_r0_body.cnh1pos170, PRE_first_tail_x6_r0_body.cnren170, PRE_first_tail_x6_r0_body.cnlow170, PRE_first_tail_x6_r0_body.cabs0a170, PRE_first_tail_x6_r0_body.cabs0b170, PRE_first_tail_x6_r0_body.ctok1170, PRE_first_tail_x6_r0_body.cpend170, PRE_first_tail_x6_r0_body.cerrh170, PRE_first_tail_x6_r0_body.cfiles170, PRE_first_tail_x6_r0_body.carch170, PRE_first_tail_x6_r0_body.csizes170, PRE_first_tail_x6_r0_body.cwired170, PRE_first_tail_x6_r0_body.cfix170, clean, PRE_first_tail_x6_r0_body.fcxn170, PRE_first_tail_x6_r0_body.fcnn170, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle0170, PRE_first_tail_x6_r0_body.fnk170, PRE_first_tail_x6_r0_body.ckA170, PRE_first_tail_x6_r0_body.cobjsK170, PRE_first_tail_x6_r0_body.cnodesK170, PRE_first_tail_x6_r0_body.citemsK170, PRE_first_tail_x6_r0_body.f1A170, PRE_first_tail_x6_r0_body.f1O170, PRE_first_tail_x6_r0_body.f1N170, PRE_first_tail_x6_r0_body.f1I170, PRE_first_tail_x6_r0_body.fbd170, PRE_first_tail_x6_r0_body.fincW170, PRE_first_tail_x6_r0_body.fincI170, PRE_first_tail_x6_r0_body.fincN170, PRE_first_tail_x6_r0_body.flnF170, PRE_first_tail_x6_r0_body.fh170, PRE_first_tail_x6_r0_body.fo170, PRE_first_tail_x6_r0_body.fok170, PRE_first_tail_x6_r0_body.fnd170, PRE_first_tail_x6_r0_body.fp170, PRE_first_tail_x6_r0_body.fnord170, PRE_first_tail_x6_r0_body.fi170, PRE_first_tail_x6_r0_body.fii170⟩
theorem PRE_first_tail_x6_r0_body.cnshift170 (clean : Conv.NClean (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P170.NL) (cl : SSt (· < 7321) PRE_first_tail_x6_r0_body.cx0_170.mlx) : NShift PRE_first_tail_x6_r0_body.P170 7321 PRE_first_tail_x6_r0_body.kappa170 PRE_first_tail_x6_r0_body.cx0_170 PRE_first_tail_x6_r0_body.cx1_170 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot170 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost170 (compact_a_eq PRE_first_tail_x6_r0_body.ckn0170 PRE_first_tail_x6_r0_body.ckn1170 PRE_first_tail_x6_r0_body.ckheap170 PRE_first_tail_x6_r0_body.ckpl170)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_170 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1638.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_170 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1638.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_170 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1638.ffi) = some PRE_first_tail_x6_r0_body.fxC_170
kernel_rfl PRE_first_tail_x6_r0_body.okrC_170 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1638.ffi) = some PRE_first_tail_x6_r0_body.krC_170
noncomputable def PRE_first_tail_x6_r0_body.fx0_170 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1640.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_170 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1640.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_170 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1640.ffi) = some PRE_first_tail_x6_r0_body.fx0_170
kernel_rfl PRE_first_tail_x6_r0_body.okr0_170 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1640.ffi) = some PRE_first_tail_x6_r0_body.kr0_170
noncomputable def PRE_first_tail_x6_r0_body.fx1_170 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1639.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_170 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1639.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_170 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1639.ffi) = some PRE_first_tail_x6_r0_body.fx1_170
kernel_rfl PRE_first_tail_x6_r0_body.okr1_170 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1639.ffi) = some PRE_first_tail_x6_r0_body.kr1_170
kernel_rfl PRE_first_tail_x6_r0_body.ff0170 : PRE_first_tail_x6_r0_body.fx0_170 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_170 (PRE_first_tail_x6_r0_body.clo170.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_170.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff1170 : PRE_first_tail_x6_r0_body.fx1_170 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_170 (PRE_first_tail_x6_r0_body.cwS170.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_170.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck170 : freedLB PRE_first_tail_x6_r0_body.kappa170 PRE_first_tail_x6_r0_body.cx0_170.mlx PRE_first_tail_x6_r0_body.fx0_170 PRE_first_tail_x6_r0_body.fx1_170 PRE_first_tail_x6_r0_body.clo170 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf0170 : PRE_first_tail_x6_r0_body.kr0_170.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_170.flags (PRE_first_tail_x6_r0_body.clo170.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_170.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt0170 : PRE_first_tail_x6_r0_body.kr0_170.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_170.targs (PRE_first_tail_x6_r0_body.clo170.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_170.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf1170 : PRE_first_tail_x6_r0_body.kr1_170.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_170.flags (PRE_first_tail_x6_r0_body.cwS170.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_170.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt1170 : PRE_first_tail_x6_r0_body.kr1_170.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_170.targs (PRE_first_tail_x6_r0_body.cwS170.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_170.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck170 : krecLB PRE_first_tail_x6_r0_body.kappa170 7321 PRE_first_tail_x6_r0_body.cx0_170.mlx PRE_first_tail_x6_r0_body.kr0_170 PRE_first_tail_x6_r0_body.kr1_170 PRE_first_tail_x6_r0_body.clo170 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn170 : Nat.ble 7321 7321 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge170 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1639.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1640.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR170 : pendRegB PRE_first_tail_x6_r0_body.kappa170 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1640.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe170 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1640.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1639.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift170 (clean : Conv.NClean (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P170.NL) (cl : SSt (· < 7321) PRE_first_tail_x6_r0_body.cx0_170.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_170.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_170.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_170.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1638.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_170.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P170 7321 PRE_first_tail_x6_r0_body.kappa170 PRE_first_tail_x6_r0_body.s1640.ffi PRE_first_tail_x6_r0_body.s1639.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift170 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue170, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp170 t ht),
    PRE_first_tail_x6_r0_body.cbridge170,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1640.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1639.ffi) (PRE_first_tail_x6_r0_body.cfoot170 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_170 PRE_first_tail_x6_r0_body.ofx1_170 hobjC PRE_first_tail_x6_r0_body.ff0170 PRE_first_tail_x6_r0_body.ff1170 PRE_first_tail_x6_r0_body.ffck170,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1640.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1639.ffi) (PRE_first_tail_x6_r0_body.cfoot170 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_170 PRE_first_tail_x6_r0_body.okr1_170 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn170) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf0170 PRE_first_tail_x6_r0_body.fkt0170 PRE_first_tail_x6_r0_body.fkf1170 PRE_first_tail_x6_r0_body.fkt1170 PRE_first_tail_x6_r0_body.fkck170,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh0170 PRE_first_tail_x6_r0_body.cnh1170 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe170) PRE_first_tail_x6_r0_body.cpendR170⟩

end Host.Load.Run.Tpl
end

section -- st170/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st170 0
host_stream_state PRE_first_tail_x6_r0_body.st170 1
host_stream_state PRE_first_tail_x6_r0_body.st170 2
end Host.Load.Run.Tpl
end

section -- Site170
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 170 of chain `PRE_first_tail_x6_r0_body`: `plan__g170__g171` (`plan`), the call state `PRE_first_tail_x6_r0_body.s1638`, the merged state `PRE_first_tail_x6_r0_body.s1639`,
the site template `PRE_first_tail_x6_r0_body.st170` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s1640`: the merge.
The footprint's facts are in `SiteF170`, the compaction's in `SiteC170`, `SiteK170`, `SiteNa170`, `SiteNb170`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso170 : PRE_first_tail_x6_r0_body.st170.s0 = { PRE_first_tail_x6_r0_body.s1638 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs170 : List Frame := PRE_first_tail_x6_r0_body.s1638.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_170 : PRE_first_tail_x6_r0_body.S1638.tab.length = 7321
kernel_rfl PRE_first_tail_x6_r0_body.tab0_170 : PRE_first_tail_x6_r0_body.st170.S0.tab = PRE_first_tail_x6_r0_body.S1638.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws170 : List Nat := [3861, 3862, 3863, 3864, 3865, 3866, 3867, 3868, 3869]
kernel_rfl PRE_first_tail_x6_r0_body.fresh170 : (PRE_first_tail_x6_r0_body.S1638.tab.all fun e => PRE_first_tail_x6_r0_body.ws170.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S1638.oracle.all fun q => PRE_first_tail_x6_r0_body.ws170.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab170 : PRE_first_tail_x6_r0_body.S1639.tab = PRE_first_tail_x6_r0_body.S1638.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws170
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen170 : PRE_first_tail_x6_r0_body.st170.S2.tab.length - PRE_first_tail_x6_r0_body.st170.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged170`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap170 : PRE_first_tail_x6_r0_body.s1639.heap = PRE_first_tail_x6_r0_body.st170.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext170 : PRE_first_tail_x6_r0_body.s1639.next = PRE_first_tail_x6_r0_body.st170.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl170 : PRE_first_tail_x6_r0_body.s1639.ctl = PRE_first_tail_x6_r0_body.st170.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack170 : PRE_first_tail_x6_r0_body.s1639.stack = PRE_first_tail_x6_r0_body.st170.s2.stack ++ PRE_first_tail_x6_r0_body.s1638.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs170 : PRE_first_tail_x6_r0_body.s1639.jobs = PRE_first_tail_x6_r0_body.st170.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi170 : PRE_first_tail_x6_r0_body.s1639.ffi = PRE_first_tail_x6_r0_body.st170.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace170 : PRE_first_tail_x6_r0_body.s1639.trace = PRE_first_tail_x6_r0_body.st170.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores170 : PRE_first_tail_x6_r0_body.s1639.stores = PRE_first_tail_x6_r0_body.st170.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD170
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 170 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived170 : PRE_first_tail_x6_r0_body.nr170.map (fun r => nth? PRE_first_tail_x6_r0_body.st170.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo170 : PRE_first_tail_x6_r0_body.nr170.all (Nat.ble 7321) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj170 : PRE_first_tail_x6_r0_body.cws170.all (fun c => !PRE_first_tail_x6_r0_body.ws170.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ170 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws170 PRE_first_tail_x6_r0_body.crs170 PRE_first_tail_x6_r0_body.ws170

end Host.Load.Run.Tpl
end

section -- st170/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st170`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st170.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st170.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st170.s2.heap PRE_first_tail_x6_r0_body.st170.wrR ++ freshOf PRE_first_tail_x6_r0_body.st170.s2.heap PRE_first_tail_x6_r0_body.st170.s0.next PRE_first_tail_x6_r0_body.st170.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st170.wr : List Nat := PRE_first_tail_x6_r0_body.st170.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st170.heapFoot : PRE_first_tail_x6_r0_body.st170.s2.heap = setAll PRE_first_tail_x6_r0_body.st170.s0.heap PRE_first_tail_x6_r0_body.st170.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st170.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st170.s0.next PRE_first_tail_x6_r0_body.st170.s2.next = true
theorem PRE_first_tail_x6_r0_body.st170.grows : PRE_first_tail_x6_r0_body.st170.s0.next ≤ PRE_first_tail_x6_r0_body.st170.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st170.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st170.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st170.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st170.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st170.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st170.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st170.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st170.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st170.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st170.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st170.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st170.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st170.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st170.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st170.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st170.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st170.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st170.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st170.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st170.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st170.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st170.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st170.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st170.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st170.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st170.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st170.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st170.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st170.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st170.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st170.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st170.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF170
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 170 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB170 : nodupT PRE_first_tail_x6_r0_body.st170.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup170 : PRE_first_tail_x6_r0_body.st170.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB170).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB170 : PRE_first_tail_x6_r0_body.st170.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound170 : ∀ b ∈ PRE_first_tail_x6_r0_body.st170.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB170 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr170 := PRE_first_tail_x6_r0_body.st170.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq170 : PRE_first_tail_x6_r0_body.st170.s2.trace = PRE_first_tail_x6_r0_body.trFr170 ++ PRE_first_tail_x6_r0_body.st170.s0.trace
theorem PRE_first_tail_x6_r0_body.trace170 : ∃ fr, PRE_first_tail_x6_r0_body.st170.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st170.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq170⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide170 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB170 : (PRE_first_tail_x6_r0_body.wide170.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st170.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix170 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide170, WFix Map.id (Present PRE_first_tail_x6_r0_body.st170.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB170 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL170
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 170 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s1639`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO170 : PRE_first_tail_x6_r0_body.st170.S0.oracle = PRE_first_tail_x6_r0_body.st170.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B170 : PRE_first_tail_x6_r0_body.st170.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st170.s0.next || (PRE_first_tail_x6_r0_body.st170.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot170 : Conv.StageFoot PRE_first_tail_x6_r0_body.st170.wr PRE_first_tail_x6_r0_body.st170.s0 PRE_first_tail_x6_r0_body.st170.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st170.heapFoot PRE_first_tail_x6_r0_body.wrNodup170 PRE_first_tail_x6_r0_body.wrBound170 PRE_first_tail_x6_r0_body.wr0B170 PRE_first_tail_x6_r0_body.st170.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged170 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st170.F.S → PRE_first_tail_x6_r0_body.st170.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st170.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st170.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs170 PRE_first_tail_x6_r0_body.st170.wr PRE_first_tail_x6_r0_body.s1638 PRE_first_tail_x6_r0_body.st170.s2 PRE_first_tail_x6_r0_body.st170.s0
      PRE_first_tail_x6_r0_body.st170.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st170.F FR W stk M ν K PRE_first_tail_x6_r0_body.s1639 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso170 PRE_first_tail_x6_r0_body.stFoot170 PRE_first_tail_x6_r0_body.wrNodup170 PRE_first_tail_x6_r0_body.wrBound170 PRE_first_tail_x6_r0_body.trace170 PRE_first_tail_x6_r0_body.mheap170
    PRE_first_tail_x6_r0_body.mnext170 PRE_first_tail_x6_r0_body.mctl170 PRE_first_tail_x6_r0_body.mstack170 PRE_first_tail_x6_r0_body.mjobs170 PRE_first_tail_x6_r0_body.mffi170 PRE_first_tail_x6_r0_body.mtrace170 PRE_first_tail_x6_r0_body.mstores170 h

def PRE_first_tail_x6_r0_body.arrEl170_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE170_2665 : arrOf PRE_first_tail_x6_r0_body.s1639 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl170_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA170_2665 : isArrB PRE_first_tail_x6_r0_body.s1639 2665 = true
theorem PRE_first_tail_x6_r0_body.arr170_2665 : ∃ o, PRE_first_tail_x6_r0_body.s1639.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl170_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE170_2665 PRE_first_tail_x6_r0_body.arrA170_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN170_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl170_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR170_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl170_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN170_2665

def PRE_first_tail_x6_r0_body.arrEl170_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE170_2673467 : arrOf PRE_first_tail_x6_r0_body.s1639 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl170_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA170_2673467 : isArrB PRE_first_tail_x6_r0_body.s1639 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr170_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s1639.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl170_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE170_2673467 PRE_first_tail_x6_r0_body.arrA170_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN170_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl170_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR170_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl170_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN170_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k170 : isArrB PRE_first_tail_x6_r0_body.s1639 4910 = false
theorem PRE_first_tail_x6_r0_body.keep170 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s1639 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k170 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr170_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl170_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ170
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 170 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s1638`, the merged
state `PRE_first_tail_x6_r0_body.s1639`, the canonical state `PRE_first_tail_x6_r0_body.s1640`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl170 : PRE_first_tail_x6_r0_body.pl170.all (Nat.ble PRE_first_tail_x6_r0_body.s1638.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd170 : nodupT PRE_first_tail_x6_r0_body.pl170 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn1170 : Nat.ble PRE_first_tail_x6_r0_body.s1638.next 2808103 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst170 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s1638.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn170 : PRE_first_tail_x6_r0_body.s1640.next = PRE_first_tail_x6_r0_body.s1638.next + PRE_first_tail_x6_r0_body.pl170.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn170 : PRE_first_tail_x6_r0_body.s1639.next = 2808103
kernel_rfl PRE_first_tail_x6_r0_body.zgrow170 : Nat.ble PRE_first_tail_x6_r0_body.s1640.next PRE_first_tail_x6_r0_body.s1639.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh170 : PRE_first_tail_x6_r0_body.S1638.tab.all (fun e => PRE_first_tail_x6_r0_body.cws170.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd170 : nodupT PRE_first_tail_x6_r0_body.cws170 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi170 : PRE_first_tail_x6_r0_body.nr170.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S1639.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt170 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s1638.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg170_2665 : PRE_first_tail_x6_r0_body.s1640.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1640 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk170_2665 : (objOf PRE_first_tail_x6_r0_body.s1640 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm170_2665 : PRE_first_tail_x6_r0_body.s1639.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa170.obj (objOf PRE_first_tail_x6_r0_body.s1640 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s1639 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg170_2673467 : PRE_first_tail_x6_r0_body.s1640.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1640 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk170_2673467 : (objOf PRE_first_tail_x6_r0_body.s1640 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm170_2673467 : PRE_first_tail_x6_r0_body.s1639.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa170.obj (objOf PRE_first_tail_x6_r0_body.s1640 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s1639 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw170_4910 : (PRE_first_tail_x6_r0_body.s1640.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw170_2673472 : (PRE_first_tail_x6_r0_body.s1640.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw170_2673473 : (PRE_first_tail_x6_r0_body.s1640.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd170 : PRE_first_tail_x6_r0_body.cl170.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr170 : PRE_first_tail_x6_r0_body.st170.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s1638.next || PRE_first_tail_x6_r0_body.cl170.contains b) = true
def PRE_first_tail_x6_r0_body.zl170 : List Nat := PRE_first_tail_x6_r0_body.cl170.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE170 : PRE_first_tail_x6_r0_body.zl170.map (fun a => PRE_first_tail_x6_r0_body.s1639.heap.get (PRE_first_tail_x6_r0_body.kappa170.a a)) = PRE_first_tail_x6_r0_body.zl170.map (fun a => (PRE_first_tail_x6_r0_body.s1640.heap.get a).map PRE_first_tail_x6_r0_body.kappa170.hobj)
theorem PRE_first_tail_x6_r0_body.zimg170 : HeapImg PRE_first_tail_x6_r0_body.kappa170 PRE_first_tail_x6_r0_body.s1640 PRE_first_tail_x6_r0_body.s1639 PRE_first_tail_x6_r0_body.zl170 := PRE_first_tail_x6_r0_body.zimgE170
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl170 : PRE_first_tail_x6_r0_body.s1639.ctl = PRE_first_tail_x6_r0_body.kappa170.ctl PRE_first_tail_x6_r0_body.s1640.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack170 : PRE_first_tail_x6_r0_body.s1639.stack = PRE_first_tail_x6_r0_body.s1640.stack.map PRE_first_tail_x6_r0_body.kappa170.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs170 : PRE_first_tail_x6_r0_body.s1639.jobs = PRE_first_tail_x6_r0_body.s1640.jobs.map PRE_first_tail_x6_r0_body.kappa170.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores170 : PRE_first_tail_x6_r0_body.s1639.stores = PRE_first_tail_x6_r0_body.kappa170.stores PRE_first_tail_x6_r0_body.s1640.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots170 : checkRootsSupp PRE_first_tail_x6_r0_body.s1640 7321 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC170 : PRE_first_tail_x6_r0_body.S1638.tab.length + PRE_first_tail_x6_r0_body.cws170.length = 7321
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap170 : PRE_first_tail_x6_r0_body.kappa170 = Conv.Map.compact PRE_first_tail_x6_r0_body.s1638.next 2808103 PRE_first_tail_x6_r0_body.S1638.tab.length PRE_first_tail_x6_r0_body.pl170 (PRE_first_tail_x6_r0_body.nr170.map NumV.ref) PRE_first_tail_x6_r0_body.kd170.big
  PRE_first_tail_x6_r0_body.kd170.region PRE_first_tail_x6_r0_body.kd170.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin170 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1640.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc170 : Conv.jcleanListB (⟨21543, 18640, 2808084, 7321⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1640 PRE_first_tail_x6_r0_body.cl170 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB170 : noBigRootsP (fun i => !Conv.oldBigB (⟨21543, 18640, 2808084, 7321⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s1640.trace PRE_first_tail_x6_r0_body.s1640 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm170 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 18640 = true
theorem PRE_first_tail_x6_r0_body.cjcl170 (h : Conv.JClean (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1638) : Conv.JClean (⟨21543, 18640, 2808084, 7321⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1640 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle170)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap170 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd170 a ha)) PRE_first_tail_x6_r0_body.zjc170

end Host.Load.Run.Tpl
end

section -- st170/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st170.bodyLast from PRE_first_tail_x6_r0_body.st170.s1 to PRE_first_tail_x6_r0_body.st170.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st170.F PRE_first_tail_x6_r0_body.st170.s1).run PRE_first_tail_x6_r0_body.st170.S1 = some (PRE_first_tail_x6_r0_body.st170.s2, PRE_first_tail_x6_r0_body.st170.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st170.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st170.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st170.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st170.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st170/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st170.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st170.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st170.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st170.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st170.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st170.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st170.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st170.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st170.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st170.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st170.s0 PRE_first_tail_x6_r0_body.st170.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st170.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st170.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st170.s1 PRE_first_tail_x6_r0_body.st170.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st170/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st170.bodyK0F from PRE_first_tail_x6_r0_body.st170.s0 to PRE_first_tail_x6_r0_body.st170.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st170.F (PRE_first_tail_x6_r0_body.st170.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st170.ks 0).getD 0) PRE_first_tail_x6_r0_body.st170.s0 PRE_first_tail_x6_r0_body.st170.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st170.s1, PRE_first_tail_x6_r0_body.st170.S1)
theorem PRE_first_tail_x6_r0_body.st170.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st170.F (PRE_first_tail_x6_r0_body.st170.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st170.ks 0).getD 0) PRE_first_tail_x6_r0_body.st170.s0 PRE_first_tail_x6_r0_body.st170.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st170.s1, PRE_first_tail_x6_r0_body.st170.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st170.bodyOkLN_ok PRE_first_tail_x6_r0_body.st170.bodyK0F
end Host.Load.Run.Tpl
end

section -- st170/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st170.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st170.F (PRE_first_tail_x6_r0_body.st170.bodyOkL bytes rows) 206 PRE_first_tail_x6_r0_body.st170.s0 PRE_first_tail_x6_r0_body.st170.S0 = some (PRE_first_tail_x6_r0_body.st170.s1, PRE_first_tail_x6_r0_body.st170.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st170.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st170.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st170.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st170.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st170.F (PRE_first_tail_x6_r0_body.st170.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st170.s0
  S0 := PRE_first_tail_x6_r0_body.st170.S0
  s1 := PRE_first_tail_x6_r0_body.st170.s1
  S1 := PRE_first_tail_x6_r0_body.st170.S1
  s2 := PRE_first_tail_x6_r0_body.st170.s2
  S2 := PRE_first_tail_x6_r0_body.st170.S2
  n := 206
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st170.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st170.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st170.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st170.bodyHalt
  last := PRE_first_tail_x6_r0_body.st170.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st170.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC171
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 171 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s1657` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa171` into the merged state
`PRE_first_tail_x6_r0_body.s1656`. -/

def PRE_first_tail_x6_r0_body.pl171 : List Nat := [2810671, 2809846, 2810677, 2810673, 2809848, 2810679]
def PRE_first_tail_x6_r0_body.nr171 : List Nat := [7424, 7423, 7399, 7407, 7412, 7417, 7422, 7396, 7397, 7398, 7405, 7406, 7394, 7401, 7402, 7403, 7404, 7400]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd171 : RData :=
  ⟨2809565, 2810714, Stage.setAll PTrie.nil [(2809559, 2810671), (2809560, 2809846), (2809561, 2810677), (2809562, 2810673), (2809563, 2809848), (2809564, 2810679)], Stage.setAll PTrie.nil [(21577, 21603), (21578, 21581), (21579, 21604)],
   21580, 21605, 18686, 18686, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(7394, .ref 7424), (7395, .ref 7423), (7396, .ref 7399), (7397, .ref 7407), (7398, .ref 7412), (7399, .ref 7417), (7400, .ref 7422), (7401, .ref 7396), (7402, .ref 7397), (7403, .ref 7398), (7404, .ref 7405), (7405, .ref 7406), (7406, .ref 7394), (7407, .ref 7401), (7408, .ref 7402), (7409, .ref 7403), (7410, .ref 7404), (7411, .ref 7400)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa171 : Map :=
  Conv.Map.compact 2809559 2810714 7394 PRE_first_tail_x6_r0_body.pl171 (PRE_first_tail_x6_r0_body.nr171.map NumV.ref) PRE_first_tail_x6_r0_body.kd171.big
    PRE_first_tail_x6_r0_body.kd171.region PRE_first_tail_x6_r0_body.kd171.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws171 : List Nat := [3901, 3902, 3903, 3904, 3905, 3906, 3907, 3908, 3909, 3910, 3911, 3912, 3913, 3914, 3915, 3916, 3917, 3918]
noncomputable def PRE_first_tail_x6_r0_body.crs171 : List SymE := PRE_first_tail_x6_r0_body.nr171.map fun r => (nth? PRE_first_tail_x6_r0_body.S1656.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta171 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws171 PRE_first_tail_x6_r0_body.crs171
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB171 : List Nat := [2665, 2672739, 2673467, 2808733, 2809278, 2809534]

kernel_rfl PRE_first_tail_x6_r0_body.ctab171 : PRE_first_tail_x6_r0_body.S1657.tab = PRE_first_tail_x6_r0_body.S1655.tab ++ PRE_first_tail_x6_r0_body.cws171.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace171 : PRE_first_tail_x6_r0_body.s1657.trace = PRE_first_tail_x6_r0_body.s1655.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext171 : PRE_first_tail_x6_r0_body.s1657.next = 2809565
kernel_rfl PRE_first_tail_x6_r0_body.ccounters171 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1657.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1657.ffi).mlx.nnext) = (21580, 18686)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue171 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1656.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1657.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa171.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp171 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1657.ffi).mlx.tokens.all (bSN 7412) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean171 : Conv.cleanListB 21580 131072 (fun r => Nat.ble 86320 r) PRE_first_tail_x6_r0_body.s1657
    (PRE_first_tail_x6_r0_body.wrB171 ++ (List.range 6).map (2809559 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs171 : bigsOutB 21580 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1657.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK171
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl171`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl171 : List Nat := [2665, 2672739, 2673467, 2808733, 2809278, 2809534, 2809559, 2809560, 2809561, 2809562, 2809563, 2809564]
def PRE_first_tail_x6_r0_body.clo171 : List Nat := [21557, 21570, 21576, 21577, 21578, 21579]
def PRE_first_tail_x6_r0_body.cln171 : List Nat := [18659, 18660, 18661, 18662, 18663, 18664, 18665, 18666, 18667, 18668, 18669, 18670, 18671, 18672, 18673, 18674, 18675, 18676, 18677, 18678, 18679, 18680, 18681, 18682, 18683, 18684, 18685]
def PRE_first_tail_x6_r0_body.cli171 : List Nat := [18659, 18660, 18661, 18662, 18663, 18664, 18665, 18666, 18667, 18668, 18669, 18670, 18671, 18672, 18673, 18674, 18675, 18676, 18677, 18678, 18679, 18680, 18681, 18682, 18683, 18684, 18685]
kernel_rfl PRE_first_tail_x6_r0_body.cheap171 : PRE_first_tail_x6_r0_body.s1657.heap = Stage.setAll PRE_first_tail_x6_r0_body.s1655.heap (PRE_first_tail_x6_r0_body.cl171.filterMap fun a => (PRE_first_tail_x6_r0_body.s1657.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe171 : Nat.ble PRE_first_tail_x6_r0_body.s1655.next PRE_first_tail_x6_r0_body.s1657.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP171 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s1655 PRE_first_tail_x6_r0_body.s1657 PRE_first_tail_x6_r0_body.cl171 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp171 : Conv.suppListB PRE_first_tail_x6_r0_body.s1657 7412 PRE_first_tail_x6_r0_body.cl171 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound171 : Conv.boundListB PRE_first_tail_x6_r0_body.s1657 PRE_first_tail_x6_r0_body.cl171 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK171 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1657.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln171.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1657.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK171 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1657.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo171.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1657.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK171 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1657.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli171.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1657.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst171 : Conv.sstListB 7412 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1657.ffi).mlx PRE_first_tail_x6_r0_body.cln171 PRE_first_tail_x6_r0_body.clo171 PRE_first_tail_x6_r0_body.cli171 = true

end Host.Load.Run.Tpl
end

section -- SiteCl171
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA171 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1657.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo171.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1657.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd171 : (PRE_first_tail_x6_r0_body.clo171 ++ PRE_first_tail_x6_r0_body.cln171 ++ PRE_first_tail_x6_r0_body.cli171).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle171 : Conv.Cnt.leB (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt) (⟨21580, 18686, 2809565, 7412⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck171 : Conv.ncleanListB (⟨21580, 18686, 2809565, 7412⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1657.ffi).mlx PRE_first_tail_x6_r0_body.clo171 PRE_first_tail_x6_r0_body.cln171 PRE_first_tail_x6_r0_body.cli171 = true
theorem PRE_first_tail_x6_r0_body.cncl171 (h : Conv.NClean (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx) : Conv.NClean (⟨21580, 18686, 2809565, 7412⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1657.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle171 PRE_first_tail_x6_r0_body.ckA171 PRE_first_tail_x6_r0_body.cobjsK171 PRE_first_tail_x6_r0_body.cnodesK171 PRE_first_tail_x6_r0_body.citemsK171 PRE_first_tail_x6_r0_body.cbd171 PRE_first_tail_x6_r0_body.cck171

end Host.Load.Run.Tpl
end

section -- SiteS171
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 171 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc171 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P171 : LoadP := PRE_first_tail_x6_r0_body.Pc171.raise 18686
kernel_rfl PRE_first_tail_x6_r0_body.craise171 : Nat.ble PRE_first_tail_x6_r0_body.Pc171.N0 18686 = true
theorem PRE_first_tail_x6_r0_body.raised171 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc171 PRE_first_tail_x6_r0_body.P171 :=
  .inr ⟨18686, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise171, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_171 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1657.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_171 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1656.ffi)
def PRE_first_tail_x6_r0_body.khinv171 : PTrie Nat := Stage.setAll PTrie.nil [(21603, 21577), (21581, 21578), (21604, 21579)]
def PRE_first_tail_x6_r0_body.kninv171 : PTrie Nat := Stage.setAll PTrie.nil [(18659, 18659), (18660, 18660), (18661, 18661), (18662, 18662), (18663, 18663), (18664, 18664), (18665, 18665), (18666, 18666), (18667, 18667), (18668, 18668), (18669, 18669), (18670, 18670), (18671, 18671), (18672, 18672), (18673, 18673), (18674, 18674), (18675, 18675), (18676, 18676), (18677, 18677), (18678, 18678), (18679, 18679), (18680, 18680), (18681, 18681), (18682, 18682), (18683, 18683), (18684, 18684), (18685, 18685)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS171 : List Nat := [21557, 21570, 21576, 21577, 21578, 21579, 21580, 21581, 21582, 21583, 21584, 21585, 21586, 21587, 21588, 21589, 21590, 21591, 21592, 21593, 21594, 21595, 21596, 21597, 21598, 21599, 21600, 21601, 21602, 21603, 21604]
def PRE_first_tail_x6_r0_body.cnS171 : List Nat := List.range' 18659 27
def PRE_first_tail_x6_r0_body.ciS171 : List Nat := [] ++ List.range' 18659 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh0171 : PRE_first_tail_x6_r0_body.kd171.nh0 = PRE_first_tail_x6_r0_body.cx0_171.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh1171 : PRE_first_tail_x6_r0_body.kd171.nh1 = PRE_first_tail_x6_r0_body.cx1_171.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn0171 : PRE_first_tail_x6_r0_body.kd171.nn0 = PRE_first_tail_x6_r0_body.cx0_171.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn1171 : PRE_first_tail_x6_r0_body.kd171.nn1 = PRE_first_tail_x6_r0_body.cx1_171.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo171 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P171.lo && Nat.ble PRE_first_tail_x6_r0_body.P171.lo PRE_first_tail_x6_r0_body.cx0_171.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P171.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P171.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt171 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_171.mlx.next PRE_first_tail_x6_r0_body.cx1_171.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_171.mlx.nnext PRE_first_tail_x6_r0_body.cx1_171.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband171 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P171.NL && Nat.ble PRE_first_tail_x6_r0_body.P171.NL PRE_first_tail_x6_r0_body.P171.N0 && Nat.ble PRE_first_tail_x6_r0_body.P171.N0 PRE_first_tail_x6_r0_body.cx0_171.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow171 : PRE_first_tail_x6_r0_body.kd171.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren171 : checkRenG PRE_first_tail_x6_r0_body.kd171.hnd PRE_first_tail_x6_r0_body.khinv171 (phB PRE_first_tail_x6_r0_body.cx0_171.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband171 : PRE_first_tail_x6_r0_body.kd171.checkBand PRE_first_tail_x6_r0_body.P171.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos171 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd171.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren171 : checkRenG PRE_first_tail_x6_r0_body.kd171.node PRE_first_tail_x6_r0_body.kninv171 (pnB PRE_first_tail_x6_r0_body.cx0_171.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow171 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd171.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P171.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd171.nodeF j) PRE_first_tail_x6_r0_body.cx1_171.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a171 : PRE_first_tail_x6_r0_body.cx0_171.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b171 : PRE_first_tail_x6_r0_body.cx0_171.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok1171 : PRE_first_tail_x6_r0_body.cx1_171.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend171 : PRE_first_tail_x6_r0_body.cx1_171.mlx.pending = PRE_first_tail_x6_r0_body.cx0_171.mlx.pending.map PRE_first_tail_x6_r0_body.kappa171.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh171 : PRE_first_tail_x6_r0_body.cx1_171.mlx.errh = PRE_first_tail_x6_r0_body.cx0_171.mlx.errh.map PRE_first_tail_x6_r0_body.kappa171.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles171 : PRE_first_tail_x6_r0_body.cx1_171.mlx.files = PRE_first_tail_x6_r0_body.cx0_171.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch171 : PRE_first_tail_x6_r0_body.cx1_171.mlx.arch = PRE_first_tail_x6_r0_body.cx0_171.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes171 : PRE_first_tail_x6_r0_body.cx1_171.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_171.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired171 : PRE_first_tail_x6_r0_body.cx1_171.mlx.wired = PRE_first_tail_x6_r0_body.cx0_171.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost171 : PRE_first_tail_x6_r0_body.cx1_171.host = PRE_first_tail_x6_r0_body.cx0_171.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd171`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn0171 : PRE_first_tail_x6_r0_body.kd171.n0 = 2809565
kernel_rfl PRE_first_tail_x6_r0_body.ckn1171 : PRE_first_tail_x6_r0_body.kd171.n1 = 2810714
kernel_rfl PRE_first_tail_x6_r0_body.ckheap171 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd171.heap).all (fun x => Nat.ble 2809559 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl171 : (List.range 6).all (fun j => decide (PRE_first_tail_x6_r0_body.kd171.heap.get (2809559 + j) = nth? PRE_first_tail_x6_r0_body.pl171 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja171 : Nat.ble 2809559 2809559 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn171 : Nat.ble 7394 7394 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD171 : Nat.ble 2809559 PRE_first_tail_x6_r0_body.kd171.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn171 : Nat.ble 21577 PRE_first_tail_x6_r0_body.kd171.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn171 : Nat.ble 18659 PRE_first_tail_x6_r0_body.kd171.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb171 : Nat.ble 21577 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap171 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd171.heap).all (Nat.ble (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd171 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd171.hnd).all (Nat.ble (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode171 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd171.node).all (Nat.ble (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix171 : Conv.FixOld (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa171 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja171) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn171) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD171) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn171) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn171) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb171) PRE_first_tail_x6_r0_body.fheap171 PRE_first_tail_x6_r0_body.fhnd171 PRE_first_tail_x6_r0_body.fnode171
kernel_rfl PRE_first_tail_x6_r0_body.fcxn171 : (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn171 : (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle0171 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_171.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_171.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk171 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd171.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A171 : PRE_first_tail_x6_r0_body.cx1_171.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS171.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_171.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O171 : PRE_first_tail_x6_r0_body.cx1_171.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS171.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_171.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N171 : PRE_first_tail_x6_r0_body.cx1_171.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS171.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_171.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I171 : PRE_first_tail_x6_r0_body.cx1_171.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS171.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_171.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd171 : (PRE_first_tail_x6_r0_body.clo171 ++ PRE_first_tail_x6_r0_body.cln171 ++ PRE_first_tail_x6_r0_body.cli171 ++ PRE_first_tail_x6_r0_body.cwS171 ++ PRE_first_tail_x6_r0_body.cnS171 ++ PRE_first_tail_x6_r0_body.ciS171).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW171 : PRE_first_tail_x6_r0_body.cwS171.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo171.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI171 : PRE_first_tail_x6_r0_body.ciS171.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli171.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN171 : PRE_first_tail_x6_r0_body.cnS171.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF171 : PRE_first_tail_x6_r0_body.cln171.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh171 : PRE_first_tail_x6_r0_body.clo171.all (handleOK PRE_first_tail_x6_r0_body.kappa171 PRE_first_tail_x6_r0_body.P171.lo PRE_first_tail_x6_r0_body.cx0_171.mlx PRE_first_tail_x6_r0_body.cx1_171.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo171 : PRE_first_tail_x6_r0_body.clo171.map (fun h => PRE_first_tail_x6_r0_body.cx1_171.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa171.handle h)) = PRE_first_tail_x6_r0_body.clo171.map (fun h => (PRE_first_tail_x6_r0_body.cx0_171.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa171.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok171 : PRE_first_tail_x6_r0_body.clo171.all (objOK PRE_first_tail_x6_r0_body.kappa171 PRE_first_tail_x6_r0_body.P171.NL PRE_first_tail_x6_r0_body.cx0_171.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd171 : PRE_first_tail_x6_r0_body.cln171.all (nodeOKF PRE_first_tail_x6_r0_body.kappa171 PRE_first_tail_x6_r0_body.P171 PRE_first_tail_x6_r0_body.cx0_171.mlx PRE_first_tail_x6_r0_body.cx1_171.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp171 : ((PRE_first_tail_x6_r0_body.cln171.filter (fullB PRE_first_tail_x6_r0_body.P171))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_171.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa171.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln171.filter (fullB PRE_first_tail_x6_r0_body.P171))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_171.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa171.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI171 : incrB PRE_first_tail_x6_r0_body.kd171.nodeF (List.range' 18659 27) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK171 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd171.node).all (fun k => Nat.ble 18659 k && Nat.blt k 18686) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL171 : (PRE_first_tail_x6_r0_body.cln171.filter (Nat.ble PRE_first_tail_x6_r0_body.P171.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd171.nodeF i) && (Nat.blt i 18686 || Nat.ble PRE_first_tail_x6_r0_body.kd171.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord171 : (PRE_first_tail_x6_r0_body.cln171.filter (Nat.ble PRE_first_tail_x6_r0_body.P171.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd171.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd171.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd171.nodeF j) (PRE_first_tail_x6_r0_body.kd171.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow171 PRE_first_tail_x6_r0_body.cnn1171 PRE_first_tail_x6_r0_body.fnordI171 PRE_first_tail_x6_r0_body.fnordK171 PRE_first_tail_x6_r0_body.fnordL171
kernel_rfl PRE_first_tail_x6_r0_body.fi171 : PRE_first_tail_x6_r0_body.cli171.all (pnB PRE_first_tail_x6_r0_body.cx0_171.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii171 : PRE_first_tail_x6_r0_body.cli171.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_171.mlx.items.get (PRE_first_tail_x6_r0_body.kappa171.node k) = (PRE_first_tail_x6_r0_body.cx0_171.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa171.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot171 (clean : Conv.NClean (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P171.NL) (cl : SSt (· < 7412) PRE_first_tail_x6_r0_body.cx0_171.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P171 7412 PRE_first_tail_x6_r0_body.kappa171 PRE_first_tail_x6_r0_body.kd171 PRE_first_tail_x6_r0_body.khinv171 PRE_first_tail_x6_r0_body.kninv171 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx PRE_first_tail_x6_r0_body.cx0_171.mlx PRE_first_tail_x6_r0_body.cx1_171.mlx (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo171 PRE_first_tail_x6_r0_body.cln171 PRE_first_tail_x6_r0_body.cli171 PRE_first_tail_x6_r0_body.cwS171 PRE_first_tail_x6_r0_body.cnS171 PRE_first_tail_x6_r0_body.ciS171 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh0171, PRE_first_tail_x6_r0_body.cnh1171, PRE_first_tail_x6_r0_body.cnn0171, PRE_first_tail_x6_r0_body.cnn1171, PRE_first_tail_x6_r0_body.cplo171, PRE_first_tail_x6_r0_body.ccnt171, PRE_first_tail_x6_r0_body.cnband171, PRE_first_tail_x6_r0_body.chbelow171, PRE_first_tail_x6_r0_body.chren171, PRE_first_tail_x6_r0_body.cband171, PRE_first_tail_x6_r0_body.cnh1pos171, PRE_first_tail_x6_r0_body.cnren171, PRE_first_tail_x6_r0_body.cnlow171, PRE_first_tail_x6_r0_body.cabs0a171, PRE_first_tail_x6_r0_body.cabs0b171, PRE_first_tail_x6_r0_body.ctok1171, PRE_first_tail_x6_r0_body.cpend171, PRE_first_tail_x6_r0_body.cerrh171, PRE_first_tail_x6_r0_body.cfiles171, PRE_first_tail_x6_r0_body.carch171, PRE_first_tail_x6_r0_body.csizes171, PRE_first_tail_x6_r0_body.cwired171, PRE_first_tail_x6_r0_body.cfix171, clean, PRE_first_tail_x6_r0_body.fcxn171, PRE_first_tail_x6_r0_body.fcnn171, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle0171, PRE_first_tail_x6_r0_body.fnk171, PRE_first_tail_x6_r0_body.ckA171, PRE_first_tail_x6_r0_body.cobjsK171, PRE_first_tail_x6_r0_body.cnodesK171, PRE_first_tail_x6_r0_body.citemsK171, PRE_first_tail_x6_r0_body.f1A171, PRE_first_tail_x6_r0_body.f1O171, PRE_first_tail_x6_r0_body.f1N171, PRE_first_tail_x6_r0_body.f1I171, PRE_first_tail_x6_r0_body.fbd171, PRE_first_tail_x6_r0_body.fincW171, PRE_first_tail_x6_r0_body.fincI171, PRE_first_tail_x6_r0_body.fincN171, PRE_first_tail_x6_r0_body.flnF171, PRE_first_tail_x6_r0_body.fh171, PRE_first_tail_x6_r0_body.fo171, PRE_first_tail_x6_r0_body.fok171, PRE_first_tail_x6_r0_body.fnd171, PRE_first_tail_x6_r0_body.fp171, PRE_first_tail_x6_r0_body.fnord171, PRE_first_tail_x6_r0_body.fi171, PRE_first_tail_x6_r0_body.fii171⟩
theorem PRE_first_tail_x6_r0_body.cnshift171 (clean : Conv.NClean (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P171.NL) (cl : SSt (· < 7412) PRE_first_tail_x6_r0_body.cx0_171.mlx) : NShift PRE_first_tail_x6_r0_body.P171 7412 PRE_first_tail_x6_r0_body.kappa171 PRE_first_tail_x6_r0_body.cx0_171 PRE_first_tail_x6_r0_body.cx1_171 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot171 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost171 (compact_a_eq PRE_first_tail_x6_r0_body.ckn0171 PRE_first_tail_x6_r0_body.ckn1171 PRE_first_tail_x6_r0_body.ckheap171 PRE_first_tail_x6_r0_body.ckpl171)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_171 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1655.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_171 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1655.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_171 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1655.ffi) = some PRE_first_tail_x6_r0_body.fxC_171
kernel_rfl PRE_first_tail_x6_r0_body.okrC_171 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1655.ffi) = some PRE_first_tail_x6_r0_body.krC_171
noncomputable def PRE_first_tail_x6_r0_body.fx0_171 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1657.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_171 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1657.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_171 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1657.ffi) = some PRE_first_tail_x6_r0_body.fx0_171
kernel_rfl PRE_first_tail_x6_r0_body.okr0_171 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1657.ffi) = some PRE_first_tail_x6_r0_body.kr0_171
noncomputable def PRE_first_tail_x6_r0_body.fx1_171 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1656.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_171 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1656.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_171 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1656.ffi) = some PRE_first_tail_x6_r0_body.fx1_171
kernel_rfl PRE_first_tail_x6_r0_body.okr1_171 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1656.ffi) = some PRE_first_tail_x6_r0_body.kr1_171
kernel_rfl PRE_first_tail_x6_r0_body.ff0171 : PRE_first_tail_x6_r0_body.fx0_171 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_171 (PRE_first_tail_x6_r0_body.clo171.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_171.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff1171 : PRE_first_tail_x6_r0_body.fx1_171 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_171 (PRE_first_tail_x6_r0_body.cwS171.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_171.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck171 : freedLB PRE_first_tail_x6_r0_body.kappa171 PRE_first_tail_x6_r0_body.cx0_171.mlx PRE_first_tail_x6_r0_body.fx0_171 PRE_first_tail_x6_r0_body.fx1_171 PRE_first_tail_x6_r0_body.clo171 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf0171 : PRE_first_tail_x6_r0_body.kr0_171.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_171.flags (PRE_first_tail_x6_r0_body.clo171.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_171.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt0171 : PRE_first_tail_x6_r0_body.kr0_171.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_171.targs (PRE_first_tail_x6_r0_body.clo171.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_171.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf1171 : PRE_first_tail_x6_r0_body.kr1_171.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_171.flags (PRE_first_tail_x6_r0_body.cwS171.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_171.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt1171 : PRE_first_tail_x6_r0_body.kr1_171.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_171.targs (PRE_first_tail_x6_r0_body.cwS171.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_171.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck171 : krecLB PRE_first_tail_x6_r0_body.kappa171 7412 PRE_first_tail_x6_r0_body.cx0_171.mlx PRE_first_tail_x6_r0_body.kr0_171 PRE_first_tail_x6_r0_body.kr1_171 PRE_first_tail_x6_r0_body.clo171 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn171 : Nat.ble 7394 7412 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge171 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1656.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1657.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR171 : pendRegB PRE_first_tail_x6_r0_body.kappa171 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1657.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe171 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1657.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1656.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift171 (clean : Conv.NClean (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P171.NL) (cl : SSt (· < 7412) PRE_first_tail_x6_r0_body.cx0_171.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_171.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_171.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_171.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1655.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_171.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P171 7412 PRE_first_tail_x6_r0_body.kappa171 PRE_first_tail_x6_r0_body.s1657.ffi PRE_first_tail_x6_r0_body.s1656.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift171 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue171, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp171 t ht),
    PRE_first_tail_x6_r0_body.cbridge171,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1657.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1656.ffi) (PRE_first_tail_x6_r0_body.cfoot171 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_171 PRE_first_tail_x6_r0_body.ofx1_171 hobjC PRE_first_tail_x6_r0_body.ff0171 PRE_first_tail_x6_r0_body.ff1171 PRE_first_tail_x6_r0_body.ffck171,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1657.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1656.ffi) (PRE_first_tail_x6_r0_body.cfoot171 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_171 PRE_first_tail_x6_r0_body.okr1_171 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn171) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf0171 PRE_first_tail_x6_r0_body.fkt0171 PRE_first_tail_x6_r0_body.fkf1171 PRE_first_tail_x6_r0_body.fkt1171 PRE_first_tail_x6_r0_body.fkck171,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh0171 PRE_first_tail_x6_r0_body.cnh1171 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe171) PRE_first_tail_x6_r0_body.cpendR171⟩

end Host.Load.Run.Tpl
end

section -- st171/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st171 0
host_stream_state PRE_first_tail_x6_r0_body.st171 1
host_stream_state PRE_first_tail_x6_r0_body.st171 2
host_stream_state PRE_first_tail_x6_r0_body.st171 3
host_stream_state PRE_first_tail_x6_r0_body.st171 4
host_stream_state PRE_first_tail_x6_r0_body.st171 5
end Host.Load.Run.Tpl
end

section -- Site171
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 171 of chain `PRE_first_tail_x6_r0_body`: `ssmW__g171__g172` (`recurWindow`), the call state `PRE_first_tail_x6_r0_body.s1655`, the merged state `PRE_first_tail_x6_r0_body.s1656`,
the site template `PRE_first_tail_x6_r0_body.st171` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s1657`: the merge.
The footprint's facts are in `SiteF171`, the compaction's in `SiteC171`, `SiteK171`, `SiteNa171`, `SiteNb171`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso171 : PRE_first_tail_x6_r0_body.st171.s0 = { PRE_first_tail_x6_r0_body.s1655 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs171 : List Frame := PRE_first_tail_x6_r0_body.s1655.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_171 : PRE_first_tail_x6_r0_body.S1655.tab.length = 7394
kernel_rfl PRE_first_tail_x6_r0_body.tab0_171 : PRE_first_tail_x6_r0_body.st171.S0.tab = PRE_first_tail_x6_r0_body.S1655.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws171 : List Nat := [3870, 3871, 3872, 3873, 3874, 3875, 3876, 3877, 3878, 3879, 3880, 3881, 3882, 3883, 3884, 3885, 3886, 3887, 3888, 3889, 3890, 3891, 3892, 3893, 3894, 3895, 3896, 3897, 3898, 3899, 3900]
kernel_rfl PRE_first_tail_x6_r0_body.fresh171 : (PRE_first_tail_x6_r0_body.S1655.tab.all fun e => PRE_first_tail_x6_r0_body.ws171.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S1655.oracle.all fun q => PRE_first_tail_x6_r0_body.ws171.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab171 : PRE_first_tail_x6_r0_body.S1656.tab = PRE_first_tail_x6_r0_body.S1655.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws171
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen171 : PRE_first_tail_x6_r0_body.st171.S5.tab.length - PRE_first_tail_x6_r0_body.st171.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged171`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap171 : PRE_first_tail_x6_r0_body.s1656.heap = PRE_first_tail_x6_r0_body.st171.s5.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext171 : PRE_first_tail_x6_r0_body.s1656.next = PRE_first_tail_x6_r0_body.st171.s5.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl171 : PRE_first_tail_x6_r0_body.s1656.ctl = PRE_first_tail_x6_r0_body.st171.s5.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack171 : PRE_first_tail_x6_r0_body.s1656.stack = PRE_first_tail_x6_r0_body.st171.s5.stack ++ PRE_first_tail_x6_r0_body.s1655.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs171 : PRE_first_tail_x6_r0_body.s1656.jobs = PRE_first_tail_x6_r0_body.st171.s5.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi171 : PRE_first_tail_x6_r0_body.s1656.ffi = PRE_first_tail_x6_r0_body.st171.s5.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace171 : PRE_first_tail_x6_r0_body.s1656.trace = PRE_first_tail_x6_r0_body.st171.s5.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores171 : PRE_first_tail_x6_r0_body.s1656.stores = PRE_first_tail_x6_r0_body.st171.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD171
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 171 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived171 : PRE_first_tail_x6_r0_body.nr171.map (fun r => nth? PRE_first_tail_x6_r0_body.st171.S5.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.un .int32 (SymE.un .int32 (SymE.var 10))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))]
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo171 : PRE_first_tail_x6_r0_body.nr171.all (Nat.ble 7394) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj171 : PRE_first_tail_x6_r0_body.cws171.all (fun c => !PRE_first_tail_x6_r0_body.ws171.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ171 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws171 PRE_first_tail_x6_r0_body.crs171 PRE_first_tail_x6_r0_body.ws171

end Host.Load.Run.Tpl
end

section -- st171/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st171`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st171.wrR : List (Nat × Nat) := [(2672739, 2672740), (2808733, 2808734), (2809278, 2809279), (2809534, 2809535)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st171.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st171.s5.heap PRE_first_tail_x6_r0_body.st171.wrR ++ freshOf PRE_first_tail_x6_r0_body.st171.s5.heap PRE_first_tail_x6_r0_body.st171.s0.next PRE_first_tail_x6_r0_body.st171.s5.next
noncomputable def PRE_first_tail_x6_r0_body.st171.wr : List Nat := PRE_first_tail_x6_r0_body.st171.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st171.heapFoot : PRE_first_tail_x6_r0_body.st171.s5.heap = setAll PRE_first_tail_x6_r0_body.st171.s0.heap PRE_first_tail_x6_r0_body.st171.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st171.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st171.s0.next PRE_first_tail_x6_r0_body.st171.s5.next = true
theorem PRE_first_tail_x6_r0_body.st171.grows : PRE_first_tail_x6_r0_body.st171.s0.next ≤ PRE_first_tail_x6_r0_body.st171.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st171.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st171.wh : List Nat := [21557, 21570, 21576, 21577, 21578, 21579, 21580, 21581, 21582, 21583, 21584, 21585, 21586, 21587, 21588, 21589, 21590, 21591, 21592, 21593, 21594, 21595, 21596, 21597, 21598, 21599, 21600, 21601, 21602, 21603, 21604]
def PRE_first_tail_x6_r0_body.st171.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st171.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st171.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st171.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st171.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st171.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st171.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st171.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st171.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st171.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st171.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st171.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st171.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st171.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st171.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st171.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st171.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st171.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st171.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st171.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st171.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st171.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st171.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st171.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st171.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st171.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st171.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st171.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st171.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st171.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF171
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 171 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB171 : nodupT PRE_first_tail_x6_r0_body.st171.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup171 : PRE_first_tail_x6_r0_body.st171.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB171).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB171 : PRE_first_tail_x6_r0_body.st171.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound171 : ∀ b ∈ PRE_first_tail_x6_r0_body.st171.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB171 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr171 := PRE_first_tail_x6_r0_body.st171.s5.trace.take 120
kernel_rfl PRE_first_tail_x6_r0_body.traceEq171 : PRE_first_tail_x6_r0_body.st171.s5.trace = PRE_first_tail_x6_r0_body.trFr171 ++ PRE_first_tail_x6_r0_body.st171.s0.trace
theorem PRE_first_tail_x6_r0_body.trace171 : ∃ fr, PRE_first_tail_x6_r0_body.st171.s5.trace = fr ++ PRE_first_tail_x6_r0_body.st171.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq171⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide171 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB171 : (PRE_first_tail_x6_r0_body.wide171.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st171.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix171 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide171, WFix Map.id (Present PRE_first_tail_x6_r0_body.st171.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB171 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL171
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 171 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s1656`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO171 : PRE_first_tail_x6_r0_body.st171.S0.oracle = PRE_first_tail_x6_r0_body.st171.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B171 : PRE_first_tail_x6_r0_body.st171.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st171.s0.next || (PRE_first_tail_x6_r0_body.st171.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot171 : Conv.StageFoot PRE_first_tail_x6_r0_body.st171.wr PRE_first_tail_x6_r0_body.st171.s0 PRE_first_tail_x6_r0_body.st171.s5 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st171.heapFoot PRE_first_tail_x6_r0_body.wrNodup171 PRE_first_tail_x6_r0_body.wrBound171 PRE_first_tail_x6_r0_body.wr0B171 PRE_first_tail_x6_r0_body.st171.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged171 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st171.F.S → PRE_first_tail_x6_r0_body.st171.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st171.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st171.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs171 PRE_first_tail_x6_r0_body.st171.wr PRE_first_tail_x6_r0_body.s1655 PRE_first_tail_x6_r0_body.st171.s5 PRE_first_tail_x6_r0_body.st171.s0
      PRE_first_tail_x6_r0_body.st171.s5.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st171.F FR W stk M ν K PRE_first_tail_x6_r0_body.s1656 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso171 PRE_first_tail_x6_r0_body.stFoot171 PRE_first_tail_x6_r0_body.wrNodup171 PRE_first_tail_x6_r0_body.wrBound171 PRE_first_tail_x6_r0_body.trace171 PRE_first_tail_x6_r0_body.mheap171
    PRE_first_tail_x6_r0_body.mnext171 PRE_first_tail_x6_r0_body.mctl171 PRE_first_tail_x6_r0_body.mstack171 PRE_first_tail_x6_r0_body.mjobs171 PRE_first_tail_x6_r0_body.mffi171 PRE_first_tail_x6_r0_body.mtrace171 PRE_first_tail_x6_r0_body.mstores171 h

def PRE_first_tail_x6_r0_body.arrEl171_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE171_2665 : arrOf PRE_first_tail_x6_r0_body.s1656 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl171_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA171_2665 : isArrB PRE_first_tail_x6_r0_body.s1656 2665 = true
theorem PRE_first_tail_x6_r0_body.arr171_2665 : ∃ o, PRE_first_tail_x6_r0_body.s1656.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl171_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE171_2665 PRE_first_tail_x6_r0_body.arrA171_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN171_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl171_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR171_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl171_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN171_2665

def PRE_first_tail_x6_r0_body.arrEl171_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE171_2673467 : arrOf PRE_first_tail_x6_r0_body.s1656 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl171_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA171_2673467 : isArrB PRE_first_tail_x6_r0_body.s1656 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr171_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s1656.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl171_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE171_2673467 PRE_first_tail_x6_r0_body.arrA171_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN171_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl171_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR171_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl171_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN171_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k171 : isArrB PRE_first_tail_x6_r0_body.s1656 4910 = false
theorem PRE_first_tail_x6_r0_body.keep171 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s1656 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k171 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr171_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl171_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ171
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 171 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s1655`, the merged
state `PRE_first_tail_x6_r0_body.s1656`, the canonical state `PRE_first_tail_x6_r0_body.s1657`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl171 : PRE_first_tail_x6_r0_body.pl171.all (Nat.ble PRE_first_tail_x6_r0_body.s1655.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd171 : nodupT PRE_first_tail_x6_r0_body.pl171 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn1171 : Nat.ble PRE_first_tail_x6_r0_body.s1655.next 2810714 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst171 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s1655.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn171 : PRE_first_tail_x6_r0_body.s1657.next = PRE_first_tail_x6_r0_body.s1655.next + PRE_first_tail_x6_r0_body.pl171.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn171 : PRE_first_tail_x6_r0_body.s1656.next = 2810714
kernel_rfl PRE_first_tail_x6_r0_body.zgrow171 : Nat.ble PRE_first_tail_x6_r0_body.s1657.next PRE_first_tail_x6_r0_body.s1656.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh171 : PRE_first_tail_x6_r0_body.S1655.tab.all (fun e => PRE_first_tail_x6_r0_body.cws171.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd171 : nodupT PRE_first_tail_x6_r0_body.cws171 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi171 : PRE_first_tail_x6_r0_body.nr171.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S1656.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt171 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s1655.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg171_2665 : PRE_first_tail_x6_r0_body.s1657.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1657 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk171_2665 : (objOf PRE_first_tail_x6_r0_body.s1657 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm171_2665 : PRE_first_tail_x6_r0_body.s1656.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa171.obj (objOf PRE_first_tail_x6_r0_body.s1657 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s1656 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg171_2673467 : PRE_first_tail_x6_r0_body.s1657.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1657 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk171_2673467 : (objOf PRE_first_tail_x6_r0_body.s1657 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm171_2673467 : PRE_first_tail_x6_r0_body.s1656.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa171.obj (objOf PRE_first_tail_x6_r0_body.s1657 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s1656 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw171_4910 : (PRE_first_tail_x6_r0_body.s1657.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw171_2673472 : (PRE_first_tail_x6_r0_body.s1657.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw171_2673473 : (PRE_first_tail_x6_r0_body.s1657.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd171 : PRE_first_tail_x6_r0_body.cl171.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr171 : PRE_first_tail_x6_r0_body.st171.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s1655.next || PRE_first_tail_x6_r0_body.cl171.contains b) = true
def PRE_first_tail_x6_r0_body.zl171 : List Nat := PRE_first_tail_x6_r0_body.cl171.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE171 : PRE_first_tail_x6_r0_body.zl171.map (fun a => PRE_first_tail_x6_r0_body.s1656.heap.get (PRE_first_tail_x6_r0_body.kappa171.a a)) = PRE_first_tail_x6_r0_body.zl171.map (fun a => (PRE_first_tail_x6_r0_body.s1657.heap.get a).map PRE_first_tail_x6_r0_body.kappa171.hobj)
theorem PRE_first_tail_x6_r0_body.zimg171 : HeapImg PRE_first_tail_x6_r0_body.kappa171 PRE_first_tail_x6_r0_body.s1657 PRE_first_tail_x6_r0_body.s1656 PRE_first_tail_x6_r0_body.zl171 := PRE_first_tail_x6_r0_body.zimgE171
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl171 : PRE_first_tail_x6_r0_body.s1656.ctl = PRE_first_tail_x6_r0_body.kappa171.ctl PRE_first_tail_x6_r0_body.s1657.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack171 : PRE_first_tail_x6_r0_body.s1656.stack = PRE_first_tail_x6_r0_body.s1657.stack.map PRE_first_tail_x6_r0_body.kappa171.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs171 : PRE_first_tail_x6_r0_body.s1656.jobs = PRE_first_tail_x6_r0_body.s1657.jobs.map PRE_first_tail_x6_r0_body.kappa171.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores171 : PRE_first_tail_x6_r0_body.s1656.stores = PRE_first_tail_x6_r0_body.kappa171.stores PRE_first_tail_x6_r0_body.s1657.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots171 : checkRootsSupp PRE_first_tail_x6_r0_body.s1657 7412 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC171 : PRE_first_tail_x6_r0_body.S1655.tab.length + PRE_first_tail_x6_r0_body.cws171.length = 7412
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap171 : PRE_first_tail_x6_r0_body.kappa171 = Conv.Map.compact PRE_first_tail_x6_r0_body.s1655.next 2810714 PRE_first_tail_x6_r0_body.S1655.tab.length PRE_first_tail_x6_r0_body.pl171 (PRE_first_tail_x6_r0_body.nr171.map NumV.ref) PRE_first_tail_x6_r0_body.kd171.big
  PRE_first_tail_x6_r0_body.kd171.region PRE_first_tail_x6_r0_body.kd171.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin171 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1657.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc171 : Conv.jcleanListB (⟨21580, 18686, 2809565, 7412⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1657 PRE_first_tail_x6_r0_body.cl171 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB171 : noBigRootsP (fun i => !Conv.oldBigB (⟨21580, 18686, 2809565, 7412⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s1657.trace PRE_first_tail_x6_r0_body.s1657 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm171 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 18659 = true
theorem PRE_first_tail_x6_r0_body.cjcl171 (h : Conv.JClean (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1655) : Conv.JClean (⟨21580, 18686, 2809565, 7412⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1657 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle171)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap171 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd171 a ha)) PRE_first_tail_x6_r0_body.zjc171

end Host.Load.Run.Tpl
end

section -- st171/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st171.bodyLast from PRE_first_tail_x6_r0_body.st171.s4 to PRE_first_tail_x6_r0_body.st171.s5 :
  interpS (step PRE_first_tail_x6_r0_body.st171.F PRE_first_tail_x6_r0_body.st171.s4).run PRE_first_tail_x6_r0_body.st171.S4 = some (PRE_first_tail_x6_r0_body.st171.s5, PRE_first_tail_x6_r0_body.st171.S5)
kernel_rfl PRE_first_tail_x6_r0_body.st171.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st171.s4.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st171.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st171.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st171/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st171.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st171.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st171.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st171.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st171.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st171.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st171.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st171.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st171.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st171.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st171.s0 PRE_first_tail_x6_r0_body.st171.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st171.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st171.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st171.s4 PRE_first_tail_x6_r0_body.st171.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st171/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st171.bodyK0F from PRE_first_tail_x6_r0_body.st171.s0 to PRE_first_tail_x6_r0_body.st171.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st171.F (PRE_first_tail_x6_r0_body.st171.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st171.ks 0).getD 0) PRE_first_tail_x6_r0_body.st171.s0 PRE_first_tail_x6_r0_body.st171.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st171.s1, PRE_first_tail_x6_r0_body.st171.S1)
theorem PRE_first_tail_x6_r0_body.st171.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st171.F (PRE_first_tail_x6_r0_body.st171.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st171.ks 0).getD 0) PRE_first_tail_x6_r0_body.st171.s0 PRE_first_tail_x6_r0_body.st171.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st171.s1, PRE_first_tail_x6_r0_body.st171.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st171.bodyOkLN_ok PRE_first_tail_x6_r0_body.st171.bodyK0F
end Host.Load.Run.Tpl
end

section -- st171/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st171.bodyK1F from PRE_first_tail_x6_r0_body.st171.s1 to PRE_first_tail_x6_r0_body.st171.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st171.F (PRE_first_tail_x6_r0_body.st171.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st171.ks 1).getD 0) PRE_first_tail_x6_r0_body.st171.s1 PRE_first_tail_x6_r0_body.st171.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st171.s2, PRE_first_tail_x6_r0_body.st171.S2)
theorem PRE_first_tail_x6_r0_body.st171.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st171.F (PRE_first_tail_x6_r0_body.st171.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st171.ks 1).getD 0) PRE_first_tail_x6_r0_body.st171.s1 PRE_first_tail_x6_r0_body.st171.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st171.s2, PRE_first_tail_x6_r0_body.st171.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st171.bodyOkLN_ok PRE_first_tail_x6_r0_body.st171.bodyK1F
end Host.Load.Run.Tpl
end

section -- st171/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st171.bodyK2F from PRE_first_tail_x6_r0_body.st171.s2 to PRE_first_tail_x6_r0_body.st171.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st171.F (PRE_first_tail_x6_r0_body.st171.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st171.ks 2).getD 0) PRE_first_tail_x6_r0_body.st171.s2 PRE_first_tail_x6_r0_body.st171.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st171.s3, PRE_first_tail_x6_r0_body.st171.S3)
theorem PRE_first_tail_x6_r0_body.st171.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st171.F (PRE_first_tail_x6_r0_body.st171.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st171.ks 2).getD 0) PRE_first_tail_x6_r0_body.st171.s2 PRE_first_tail_x6_r0_body.st171.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st171.s3, PRE_first_tail_x6_r0_body.st171.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st171.bodyOkLN_ok PRE_first_tail_x6_r0_body.st171.bodyK2F
end Host.Load.Run.Tpl
end

section -- st171/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st171.bodyK3F from PRE_first_tail_x6_r0_body.st171.s3 to PRE_first_tail_x6_r0_body.st171.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st171.F (PRE_first_tail_x6_r0_body.st171.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st171.ks 3).getD 0) PRE_first_tail_x6_r0_body.st171.s3 PRE_first_tail_x6_r0_body.st171.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st171.s4, PRE_first_tail_x6_r0_body.st171.S4)
theorem PRE_first_tail_x6_r0_body.st171.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st171.F (PRE_first_tail_x6_r0_body.st171.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st171.ks 3).getD 0) PRE_first_tail_x6_r0_body.st171.s3 PRE_first_tail_x6_r0_body.st171.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st171.s4, PRE_first_tail_x6_r0_body.st171.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st171.bodyOkLN_ok PRE_first_tail_x6_r0_body.st171.bodyK3F
end Host.Load.Run.Tpl
end

section -- st171/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st171.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st171.F (PRE_first_tail_x6_r0_body.st171.bodyOkL bytes rows) 11334 PRE_first_tail_x6_r0_body.st171.s0 PRE_first_tail_x6_r0_body.st171.S0 = some (PRE_first_tail_x6_r0_body.st171.s4, PRE_first_tail_x6_r0_body.st171.S4) :=
  runOk_trans PRE_first_tail_x6_r0_body.st171.F (PRE_first_tail_x6_r0_body.st171.bodyOkL bytes rows) ((((nth? PRE_first_tail_x6_r0_body.st171.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st171.ks 1).getD 0)) + ((nth? PRE_first_tail_x6_r0_body.st171.ks 2).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st171.ks 3).getD 0) PRE_first_tail_x6_r0_body.st171.s0 PRE_first_tail_x6_r0_body.st171.s3 PRE_first_tail_x6_r0_body.st171.s4 PRE_first_tail_x6_r0_body.st171.S0 PRE_first_tail_x6_r0_body.st171.S3 PRE_first_tail_x6_r0_body.st171.S4 (runOk_trans PRE_first_tail_x6_r0_body.st171.F (PRE_first_tail_x6_r0_body.st171.bodyOkL bytes rows) (((nth? PRE_first_tail_x6_r0_body.st171.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st171.ks 1).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st171.ks 2).getD 0) PRE_first_tail_x6_r0_body.st171.s0 PRE_first_tail_x6_r0_body.st171.s2 PRE_first_tail_x6_r0_body.st171.s3 PRE_first_tail_x6_r0_body.st171.S0 PRE_first_tail_x6_r0_body.st171.S2 PRE_first_tail_x6_r0_body.st171.S3 (runOk_trans PRE_first_tail_x6_r0_body.st171.F (PRE_first_tail_x6_r0_body.st171.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st171.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st171.ks 1).getD 0) PRE_first_tail_x6_r0_body.st171.s0 PRE_first_tail_x6_r0_body.st171.s1 PRE_first_tail_x6_r0_body.st171.s2 PRE_first_tail_x6_r0_body.st171.S0 PRE_first_tail_x6_r0_body.st171.S1 PRE_first_tail_x6_r0_body.st171.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st171.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st171.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st171.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st171.bodyK3 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st171.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st171.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st171.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st171.F (PRE_first_tail_x6_r0_body.st171.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st171.s0
  S0 := PRE_first_tail_x6_r0_body.st171.S0
  s1 := PRE_first_tail_x6_r0_body.st171.s4
  S1 := PRE_first_tail_x6_r0_body.st171.S4
  s2 := PRE_first_tail_x6_r0_body.st171.s5
  S2 := PRE_first_tail_x6_r0_body.st171.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st171.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st171.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st171.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st171.bodyHalt
  last := PRE_first_tail_x6_r0_body.st171.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st171.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC172
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 172 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s1665` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa172` into the merged state
`PRE_first_tail_x6_r0_body.s1664`. -/

def PRE_first_tail_x6_r0_body.pl172 : List Nat := []
def PRE_first_tail_x6_r0_body.nr172 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd172 : RData :=
  ⟨2810055, 2810057, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21593, 21593, 18699, 18699, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa172 : Map :=
  Conv.Map.compact 2810055 2810057 7433 PRE_first_tail_x6_r0_body.pl172 (PRE_first_tail_x6_r0_body.nr172.map NumV.ref) PRE_first_tail_x6_r0_body.kd172.big
    PRE_first_tail_x6_r0_body.kd172.region PRE_first_tail_x6_r0_body.kd172.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws172 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs172 : List SymE := PRE_first_tail_x6_r0_body.nr172.map fun r => (nth? PRE_first_tail_x6_r0_body.S1664.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta172 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws172 PRE_first_tail_x6_r0_body.crs172
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB172 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab172 : PRE_first_tail_x6_r0_body.S1665.tab = PRE_first_tail_x6_r0_body.S1663.tab ++ PRE_first_tail_x6_r0_body.cws172.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace172 : PRE_first_tail_x6_r0_body.s1665.trace = PRE_first_tail_x6_r0_body.s1663.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext172 : PRE_first_tail_x6_r0_body.s1665.next = 2810055
kernel_rfl PRE_first_tail_x6_r0_body.ccounters172 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1665.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1665.ffi).mlx.nnext) = (21593, 18699)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue172 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1664.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1665.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa172.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp172 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1665.ffi).mlx.tokens.all (bSN 7433) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean172 : Conv.cleanListB 21593 131072 (fun r => Nat.ble 86372 r) PRE_first_tail_x6_r0_body.s1665
    (PRE_first_tail_x6_r0_body.wrB172 ++ (List.range 0).map (2810055 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs172 : bigsOutB 21593 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1665.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK172
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl172`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl172 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo172 : List Nat := []
def PRE_first_tail_x6_r0_body.cln172 : List Nat := []
def PRE_first_tail_x6_r0_body.cli172 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap172 : PRE_first_tail_x6_r0_body.s1665.heap = Stage.setAll PRE_first_tail_x6_r0_body.s1663.heap (PRE_first_tail_x6_r0_body.cl172.filterMap fun a => (PRE_first_tail_x6_r0_body.s1665.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe172 : Nat.ble PRE_first_tail_x6_r0_body.s1663.next PRE_first_tail_x6_r0_body.s1665.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP172 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s1663 PRE_first_tail_x6_r0_body.s1665 PRE_first_tail_x6_r0_body.cl172 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp172 : Conv.suppListB PRE_first_tail_x6_r0_body.s1665 7433 PRE_first_tail_x6_r0_body.cl172 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound172 : Conv.boundListB PRE_first_tail_x6_r0_body.s1665 PRE_first_tail_x6_r0_body.cl172 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK172 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1665.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln172.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1665.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK172 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1665.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo172.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1665.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK172 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1665.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli172.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1665.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst172 : Conv.sstListB 7433 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1665.ffi).mlx PRE_first_tail_x6_r0_body.cln172 PRE_first_tail_x6_r0_body.clo172 PRE_first_tail_x6_r0_body.cli172 = true

end Host.Load.Run.Tpl
end

section -- SiteCl172
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA172 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1665.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo172.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1665.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd172 : (PRE_first_tail_x6_r0_body.clo172 ++ PRE_first_tail_x6_r0_body.cln172 ++ PRE_first_tail_x6_r0_body.cli172).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle172 : Conv.Cnt.leB (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck172 : Conv.ncleanListB (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1665.ffi).mlx PRE_first_tail_x6_r0_body.clo172 PRE_first_tail_x6_r0_body.cln172 PRE_first_tail_x6_r0_body.cli172 = true
theorem PRE_first_tail_x6_r0_body.cncl172 (h : Conv.NClean (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx) : Conv.NClean (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1665.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle172 PRE_first_tail_x6_r0_body.ckA172 PRE_first_tail_x6_r0_body.cobjsK172 PRE_first_tail_x6_r0_body.cnodesK172 PRE_first_tail_x6_r0_body.citemsK172 PRE_first_tail_x6_r0_body.cbd172 PRE_first_tail_x6_r0_body.cck172

end Host.Load.Run.Tpl
end

section -- SiteS172
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 172 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc172 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P172 : LoadP := PRE_first_tail_x6_r0_body.Pc172.raise 18699
kernel_rfl PRE_first_tail_x6_r0_body.craise172 : Nat.ble PRE_first_tail_x6_r0_body.Pc172.N0 18699 = true
theorem PRE_first_tail_x6_r0_body.raised172 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc172 PRE_first_tail_x6_r0_body.P172 :=
  .inr ⟨18699, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise172, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_172 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1665.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_172 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1664.ffi)
def PRE_first_tail_x6_r0_body.khinv172 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv172 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS172 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS172 : List Nat := List.range' 18699 0
def PRE_first_tail_x6_r0_body.ciS172 : List Nat := [] ++ List.range' 18699 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh0172 : PRE_first_tail_x6_r0_body.kd172.nh0 = PRE_first_tail_x6_r0_body.cx0_172.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh1172 : PRE_first_tail_x6_r0_body.kd172.nh1 = PRE_first_tail_x6_r0_body.cx1_172.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn0172 : PRE_first_tail_x6_r0_body.kd172.nn0 = PRE_first_tail_x6_r0_body.cx0_172.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn1172 : PRE_first_tail_x6_r0_body.kd172.nn1 = PRE_first_tail_x6_r0_body.cx1_172.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo172 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P172.lo && Nat.ble PRE_first_tail_x6_r0_body.P172.lo PRE_first_tail_x6_r0_body.cx0_172.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P172.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P172.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt172 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_172.mlx.next PRE_first_tail_x6_r0_body.cx1_172.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_172.mlx.nnext PRE_first_tail_x6_r0_body.cx1_172.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband172 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P172.NL && Nat.ble PRE_first_tail_x6_r0_body.P172.NL PRE_first_tail_x6_r0_body.P172.N0 && Nat.ble PRE_first_tail_x6_r0_body.P172.N0 PRE_first_tail_x6_r0_body.cx0_172.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow172 : PRE_first_tail_x6_r0_body.kd172.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren172 : checkRenG PRE_first_tail_x6_r0_body.kd172.hnd PRE_first_tail_x6_r0_body.khinv172 (phB PRE_first_tail_x6_r0_body.cx0_172.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband172 : PRE_first_tail_x6_r0_body.kd172.checkBand PRE_first_tail_x6_r0_body.P172.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos172 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd172.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren172 : checkRenG PRE_first_tail_x6_r0_body.kd172.node PRE_first_tail_x6_r0_body.kninv172 (pnB PRE_first_tail_x6_r0_body.cx0_172.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow172 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd172.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P172.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd172.nodeF j) PRE_first_tail_x6_r0_body.cx1_172.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a172 : PRE_first_tail_x6_r0_body.cx0_172.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b172 : PRE_first_tail_x6_r0_body.cx0_172.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok1172 : PRE_first_tail_x6_r0_body.cx1_172.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend172 : PRE_first_tail_x6_r0_body.cx1_172.mlx.pending = PRE_first_tail_x6_r0_body.cx0_172.mlx.pending.map PRE_first_tail_x6_r0_body.kappa172.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh172 : PRE_first_tail_x6_r0_body.cx1_172.mlx.errh = PRE_first_tail_x6_r0_body.cx0_172.mlx.errh.map PRE_first_tail_x6_r0_body.kappa172.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles172 : PRE_first_tail_x6_r0_body.cx1_172.mlx.files = PRE_first_tail_x6_r0_body.cx0_172.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch172 : PRE_first_tail_x6_r0_body.cx1_172.mlx.arch = PRE_first_tail_x6_r0_body.cx0_172.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes172 : PRE_first_tail_x6_r0_body.cx1_172.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_172.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired172 : PRE_first_tail_x6_r0_body.cx1_172.mlx.wired = PRE_first_tail_x6_r0_body.cx0_172.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost172 : PRE_first_tail_x6_r0_body.cx1_172.host = PRE_first_tail_x6_r0_body.cx0_172.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd172`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn0172 : PRE_first_tail_x6_r0_body.kd172.n0 = 2810055
kernel_rfl PRE_first_tail_x6_r0_body.ckn1172 : PRE_first_tail_x6_r0_body.kd172.n1 = 2810057
kernel_rfl PRE_first_tail_x6_r0_body.ckheap172 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd172.heap).all (fun x => Nat.ble 2810055 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl172 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_body.kd172.heap.get (2810055 + j) = nth? PRE_first_tail_x6_r0_body.pl172 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja172 : Nat.ble 2810055 2810055 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn172 : Nat.ble 7433 7433 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD172 : Nat.ble 2810055 PRE_first_tail_x6_r0_body.kd172.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn172 : Nat.ble 21593 PRE_first_tail_x6_r0_body.kd172.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn172 : Nat.ble 18699 PRE_first_tail_x6_r0_body.kd172.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb172 : Nat.ble 21593 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap172 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd172.heap).all (Nat.ble (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd172 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd172.hnd).all (Nat.ble (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode172 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd172.node).all (Nat.ble (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix172 : Conv.FixOld (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa172 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja172) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn172) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD172) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn172) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn172) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb172) PRE_first_tail_x6_r0_body.fheap172 PRE_first_tail_x6_r0_body.fhnd172 PRE_first_tail_x6_r0_body.fnode172
kernel_rfl PRE_first_tail_x6_r0_body.fcxn172 : (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn172 : (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle0172 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_172.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_172.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk172 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd172.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A172 : PRE_first_tail_x6_r0_body.cx1_172.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS172.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_172.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O172 : PRE_first_tail_x6_r0_body.cx1_172.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS172.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_172.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N172 : PRE_first_tail_x6_r0_body.cx1_172.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS172.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_172.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I172 : PRE_first_tail_x6_r0_body.cx1_172.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS172.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_172.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd172 : (PRE_first_tail_x6_r0_body.clo172 ++ PRE_first_tail_x6_r0_body.cln172 ++ PRE_first_tail_x6_r0_body.cli172 ++ PRE_first_tail_x6_r0_body.cwS172 ++ PRE_first_tail_x6_r0_body.cnS172 ++ PRE_first_tail_x6_r0_body.ciS172).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW172 : PRE_first_tail_x6_r0_body.cwS172.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo172.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI172 : PRE_first_tail_x6_r0_body.ciS172.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli172.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN172 : PRE_first_tail_x6_r0_body.cnS172.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF172 : PRE_first_tail_x6_r0_body.cln172.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh172 : PRE_first_tail_x6_r0_body.clo172.all (handleOK PRE_first_tail_x6_r0_body.kappa172 PRE_first_tail_x6_r0_body.P172.lo PRE_first_tail_x6_r0_body.cx0_172.mlx PRE_first_tail_x6_r0_body.cx1_172.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo172 : PRE_first_tail_x6_r0_body.clo172.map (fun h => PRE_first_tail_x6_r0_body.cx1_172.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa172.handle h)) = PRE_first_tail_x6_r0_body.clo172.map (fun h => (PRE_first_tail_x6_r0_body.cx0_172.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa172.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok172 : PRE_first_tail_x6_r0_body.clo172.all (objOK PRE_first_tail_x6_r0_body.kappa172 PRE_first_tail_x6_r0_body.P172.NL PRE_first_tail_x6_r0_body.cx0_172.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd172 : PRE_first_tail_x6_r0_body.cln172.all (nodeOKF PRE_first_tail_x6_r0_body.kappa172 PRE_first_tail_x6_r0_body.P172 PRE_first_tail_x6_r0_body.cx0_172.mlx PRE_first_tail_x6_r0_body.cx1_172.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp172 : ((PRE_first_tail_x6_r0_body.cln172.filter (fullB PRE_first_tail_x6_r0_body.P172))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_172.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa172.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln172.filter (fullB PRE_first_tail_x6_r0_body.P172))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_172.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa172.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI172 : incrB PRE_first_tail_x6_r0_body.kd172.nodeF (List.range' 18699 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK172 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd172.node).all (fun k => Nat.ble 18699 k && Nat.blt k 18699) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL172 : (PRE_first_tail_x6_r0_body.cln172.filter (Nat.ble PRE_first_tail_x6_r0_body.P172.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd172.nodeF i) && (Nat.blt i 18699 || Nat.ble PRE_first_tail_x6_r0_body.kd172.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord172 : (PRE_first_tail_x6_r0_body.cln172.filter (Nat.ble PRE_first_tail_x6_r0_body.P172.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd172.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd172.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd172.nodeF j) (PRE_first_tail_x6_r0_body.kd172.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow172 PRE_first_tail_x6_r0_body.cnn1172 PRE_first_tail_x6_r0_body.fnordI172 PRE_first_tail_x6_r0_body.fnordK172 PRE_first_tail_x6_r0_body.fnordL172
kernel_rfl PRE_first_tail_x6_r0_body.fi172 : PRE_first_tail_x6_r0_body.cli172.all (pnB PRE_first_tail_x6_r0_body.cx0_172.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii172 : PRE_first_tail_x6_r0_body.cli172.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_172.mlx.items.get (PRE_first_tail_x6_r0_body.kappa172.node k) = (PRE_first_tail_x6_r0_body.cx0_172.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa172.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot172 (clean : Conv.NClean (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P172.NL) (cl : SSt (· < 7433) PRE_first_tail_x6_r0_body.cx0_172.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P172 7433 PRE_first_tail_x6_r0_body.kappa172 PRE_first_tail_x6_r0_body.kd172 PRE_first_tail_x6_r0_body.khinv172 PRE_first_tail_x6_r0_body.kninv172 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx PRE_first_tail_x6_r0_body.cx0_172.mlx PRE_first_tail_x6_r0_body.cx1_172.mlx (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo172 PRE_first_tail_x6_r0_body.cln172 PRE_first_tail_x6_r0_body.cli172 PRE_first_tail_x6_r0_body.cwS172 PRE_first_tail_x6_r0_body.cnS172 PRE_first_tail_x6_r0_body.ciS172 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh0172, PRE_first_tail_x6_r0_body.cnh1172, PRE_first_tail_x6_r0_body.cnn0172, PRE_first_tail_x6_r0_body.cnn1172, PRE_first_tail_x6_r0_body.cplo172, PRE_first_tail_x6_r0_body.ccnt172, PRE_first_tail_x6_r0_body.cnband172, PRE_first_tail_x6_r0_body.chbelow172, PRE_first_tail_x6_r0_body.chren172, PRE_first_tail_x6_r0_body.cband172, PRE_first_tail_x6_r0_body.cnh1pos172, PRE_first_tail_x6_r0_body.cnren172, PRE_first_tail_x6_r0_body.cnlow172, PRE_first_tail_x6_r0_body.cabs0a172, PRE_first_tail_x6_r0_body.cabs0b172, PRE_first_tail_x6_r0_body.ctok1172, PRE_first_tail_x6_r0_body.cpend172, PRE_first_tail_x6_r0_body.cerrh172, PRE_first_tail_x6_r0_body.cfiles172, PRE_first_tail_x6_r0_body.carch172, PRE_first_tail_x6_r0_body.csizes172, PRE_first_tail_x6_r0_body.cwired172, PRE_first_tail_x6_r0_body.cfix172, clean, PRE_first_tail_x6_r0_body.fcxn172, PRE_first_tail_x6_r0_body.fcnn172, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle0172, PRE_first_tail_x6_r0_body.fnk172, PRE_first_tail_x6_r0_body.ckA172, PRE_first_tail_x6_r0_body.cobjsK172, PRE_first_tail_x6_r0_body.cnodesK172, PRE_first_tail_x6_r0_body.citemsK172, PRE_first_tail_x6_r0_body.f1A172, PRE_first_tail_x6_r0_body.f1O172, PRE_first_tail_x6_r0_body.f1N172, PRE_first_tail_x6_r0_body.f1I172, PRE_first_tail_x6_r0_body.fbd172, PRE_first_tail_x6_r0_body.fincW172, PRE_first_tail_x6_r0_body.fincI172, PRE_first_tail_x6_r0_body.fincN172, PRE_first_tail_x6_r0_body.flnF172, PRE_first_tail_x6_r0_body.fh172, PRE_first_tail_x6_r0_body.fo172, PRE_first_tail_x6_r0_body.fok172, PRE_first_tail_x6_r0_body.fnd172, PRE_first_tail_x6_r0_body.fp172, PRE_first_tail_x6_r0_body.fnord172, PRE_first_tail_x6_r0_body.fi172, PRE_first_tail_x6_r0_body.fii172⟩
theorem PRE_first_tail_x6_r0_body.cnshift172 (clean : Conv.NClean (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P172.NL) (cl : SSt (· < 7433) PRE_first_tail_x6_r0_body.cx0_172.mlx) : NShift PRE_first_tail_x6_r0_body.P172 7433 PRE_first_tail_x6_r0_body.kappa172 PRE_first_tail_x6_r0_body.cx0_172 PRE_first_tail_x6_r0_body.cx1_172 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot172 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost172 (compact_a_eq PRE_first_tail_x6_r0_body.ckn0172 PRE_first_tail_x6_r0_body.ckn1172 PRE_first_tail_x6_r0_body.ckheap172 PRE_first_tail_x6_r0_body.ckpl172)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_172 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1663.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_172 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1663.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_172 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1663.ffi) = some PRE_first_tail_x6_r0_body.fxC_172
kernel_rfl PRE_first_tail_x6_r0_body.okrC_172 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1663.ffi) = some PRE_first_tail_x6_r0_body.krC_172
noncomputable def PRE_first_tail_x6_r0_body.fx0_172 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1665.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_172 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1665.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_172 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1665.ffi) = some PRE_first_tail_x6_r0_body.fx0_172
kernel_rfl PRE_first_tail_x6_r0_body.okr0_172 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1665.ffi) = some PRE_first_tail_x6_r0_body.kr0_172
noncomputable def PRE_first_tail_x6_r0_body.fx1_172 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1664.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_172 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1664.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_172 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1664.ffi) = some PRE_first_tail_x6_r0_body.fx1_172
kernel_rfl PRE_first_tail_x6_r0_body.okr1_172 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1664.ffi) = some PRE_first_tail_x6_r0_body.kr1_172
kernel_rfl PRE_first_tail_x6_r0_body.ff0172 : PRE_first_tail_x6_r0_body.fx0_172 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_172 (PRE_first_tail_x6_r0_body.clo172.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_172.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff1172 : PRE_first_tail_x6_r0_body.fx1_172 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_172 (PRE_first_tail_x6_r0_body.cwS172.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_172.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck172 : freedLB PRE_first_tail_x6_r0_body.kappa172 PRE_first_tail_x6_r0_body.cx0_172.mlx PRE_first_tail_x6_r0_body.fx0_172 PRE_first_tail_x6_r0_body.fx1_172 PRE_first_tail_x6_r0_body.clo172 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf0172 : PRE_first_tail_x6_r0_body.kr0_172.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_172.flags (PRE_first_tail_x6_r0_body.clo172.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_172.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt0172 : PRE_first_tail_x6_r0_body.kr0_172.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_172.targs (PRE_first_tail_x6_r0_body.clo172.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_172.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf1172 : PRE_first_tail_x6_r0_body.kr1_172.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_172.flags (PRE_first_tail_x6_r0_body.cwS172.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_172.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt1172 : PRE_first_tail_x6_r0_body.kr1_172.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_172.targs (PRE_first_tail_x6_r0_body.cwS172.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_172.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck172 : krecLB PRE_first_tail_x6_r0_body.kappa172 7433 PRE_first_tail_x6_r0_body.cx0_172.mlx PRE_first_tail_x6_r0_body.kr0_172 PRE_first_tail_x6_r0_body.kr1_172 PRE_first_tail_x6_r0_body.clo172 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn172 : Nat.ble 7433 7433 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge172 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1664.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1665.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR172 : pendRegB PRE_first_tail_x6_r0_body.kappa172 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1665.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe172 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1665.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1664.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift172 (clean : Conv.NClean (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P172.NL) (cl : SSt (· < 7433) PRE_first_tail_x6_r0_body.cx0_172.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_172.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_172.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_172.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1663.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_172.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P172 7433 PRE_first_tail_x6_r0_body.kappa172 PRE_first_tail_x6_r0_body.s1665.ffi PRE_first_tail_x6_r0_body.s1664.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift172 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue172, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp172 t ht),
    PRE_first_tail_x6_r0_body.cbridge172,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1665.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1664.ffi) (PRE_first_tail_x6_r0_body.cfoot172 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_172 PRE_first_tail_x6_r0_body.ofx1_172 hobjC PRE_first_tail_x6_r0_body.ff0172 PRE_first_tail_x6_r0_body.ff1172 PRE_first_tail_x6_r0_body.ffck172,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1665.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1664.ffi) (PRE_first_tail_x6_r0_body.cfoot172 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_172 PRE_first_tail_x6_r0_body.okr1_172 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn172) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf0172 PRE_first_tail_x6_r0_body.fkt0172 PRE_first_tail_x6_r0_body.fkf1172 PRE_first_tail_x6_r0_body.fkt1172 PRE_first_tail_x6_r0_body.fkck172,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh0172 PRE_first_tail_x6_r0_body.cnh1172 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe172) PRE_first_tail_x6_r0_body.cpendR172⟩

end Host.Load.Run.Tpl
end

section -- st172/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st172 0
host_stream_state PRE_first_tail_x6_r0_body.st172 1
host_stream_state PRE_first_tail_x6_r0_body.st172 2
end Host.Load.Run.Tpl
end

section -- Site172
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 172 of chain `PRE_first_tail_x6_r0_body`: `rowBlocks__g172__g173` (`rowBlocks`), the call state `PRE_first_tail_x6_r0_body.s1663`, the merged state `PRE_first_tail_x6_r0_body.s1664`,
the site template `PRE_first_tail_x6_r0_body.st172` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s1665`: the merge.
The footprint's facts are in `SiteF172`, the compaction's in `SiteC172`, `SiteK172`, `SiteNa172`, `SiteNb172`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso172 : PRE_first_tail_x6_r0_body.st172.s0 = { PRE_first_tail_x6_r0_body.s1663 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs172 : List Frame := PRE_first_tail_x6_r0_body.s1663.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_172 : PRE_first_tail_x6_r0_body.S1663.tab.length = 7433
kernel_rfl PRE_first_tail_x6_r0_body.tab0_172 : PRE_first_tail_x6_r0_body.st172.S0.tab = PRE_first_tail_x6_r0_body.S1663.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws172 : List Nat := [3919, 3920]
kernel_rfl PRE_first_tail_x6_r0_body.fresh172 : (PRE_first_tail_x6_r0_body.S1663.tab.all fun e => PRE_first_tail_x6_r0_body.ws172.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S1663.oracle.all fun q => PRE_first_tail_x6_r0_body.ws172.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab172 : PRE_first_tail_x6_r0_body.S1664.tab = PRE_first_tail_x6_r0_body.S1663.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws172
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen172 : PRE_first_tail_x6_r0_body.st172.S2.tab.length - PRE_first_tail_x6_r0_body.st172.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged172`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap172 : PRE_first_tail_x6_r0_body.s1664.heap = PRE_first_tail_x6_r0_body.st172.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext172 : PRE_first_tail_x6_r0_body.s1664.next = PRE_first_tail_x6_r0_body.st172.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl172 : PRE_first_tail_x6_r0_body.s1664.ctl = PRE_first_tail_x6_r0_body.st172.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack172 : PRE_first_tail_x6_r0_body.s1664.stack = PRE_first_tail_x6_r0_body.st172.s2.stack ++ PRE_first_tail_x6_r0_body.s1663.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs172 : PRE_first_tail_x6_r0_body.s1664.jobs = PRE_first_tail_x6_r0_body.st172.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi172 : PRE_first_tail_x6_r0_body.s1664.ffi = PRE_first_tail_x6_r0_body.st172.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace172 : PRE_first_tail_x6_r0_body.s1664.trace = PRE_first_tail_x6_r0_body.st172.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores172 : PRE_first_tail_x6_r0_body.s1664.stores = PRE_first_tail_x6_r0_body.st172.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD172
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 172 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived172 : PRE_first_tail_x6_r0_body.nr172.map (fun r => nth? PRE_first_tail_x6_r0_body.st172.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo172 : PRE_first_tail_x6_r0_body.nr172.all (Nat.ble 7433) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj172 : PRE_first_tail_x6_r0_body.cws172.all (fun c => !PRE_first_tail_x6_r0_body.ws172.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ172 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws172 PRE_first_tail_x6_r0_body.crs172 PRE_first_tail_x6_r0_body.ws172

end Host.Load.Run.Tpl
end

section -- st172/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st172`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st172.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st172.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st172.s2.heap PRE_first_tail_x6_r0_body.st172.wrR ++ freshOf PRE_first_tail_x6_r0_body.st172.s2.heap PRE_first_tail_x6_r0_body.st172.s0.next PRE_first_tail_x6_r0_body.st172.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st172.wr : List Nat := PRE_first_tail_x6_r0_body.st172.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st172.heapFoot : PRE_first_tail_x6_r0_body.st172.s2.heap = setAll PRE_first_tail_x6_r0_body.st172.s0.heap PRE_first_tail_x6_r0_body.st172.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st172.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st172.s0.next PRE_first_tail_x6_r0_body.st172.s2.next = true
theorem PRE_first_tail_x6_r0_body.st172.grows : PRE_first_tail_x6_r0_body.st172.s0.next ≤ PRE_first_tail_x6_r0_body.st172.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st172.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st172.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st172.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st172.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st172.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st172.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st172.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st172.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st172.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st172.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st172.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st172.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st172.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st172.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st172.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st172.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st172.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st172.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st172.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st172.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st172.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st172.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st172.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st172.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st172.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st172.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st172.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st172.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st172.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st172.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st172.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st172.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF172
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 172 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB172 : nodupT PRE_first_tail_x6_r0_body.st172.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup172 : PRE_first_tail_x6_r0_body.st172.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB172).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB172 : PRE_first_tail_x6_r0_body.st172.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound172 : ∀ b ∈ PRE_first_tail_x6_r0_body.st172.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB172 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr172 := PRE_first_tail_x6_r0_body.st172.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq172 : PRE_first_tail_x6_r0_body.st172.s2.trace = PRE_first_tail_x6_r0_body.trFr172 ++ PRE_first_tail_x6_r0_body.st172.s0.trace
theorem PRE_first_tail_x6_r0_body.trace172 : ∃ fr, PRE_first_tail_x6_r0_body.st172.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st172.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq172⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide172 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB172 : (PRE_first_tail_x6_r0_body.wide172.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st172.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix172 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide172, WFix Map.id (Present PRE_first_tail_x6_r0_body.st172.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB172 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL172
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 172 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s1664`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO172 : PRE_first_tail_x6_r0_body.st172.S0.oracle = PRE_first_tail_x6_r0_body.st172.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B172 : PRE_first_tail_x6_r0_body.st172.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st172.s0.next || (PRE_first_tail_x6_r0_body.st172.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot172 : Conv.StageFoot PRE_first_tail_x6_r0_body.st172.wr PRE_first_tail_x6_r0_body.st172.s0 PRE_first_tail_x6_r0_body.st172.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st172.heapFoot PRE_first_tail_x6_r0_body.wrNodup172 PRE_first_tail_x6_r0_body.wrBound172 PRE_first_tail_x6_r0_body.wr0B172 PRE_first_tail_x6_r0_body.st172.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged172 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st172.F.S → PRE_first_tail_x6_r0_body.st172.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st172.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st172.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs172 PRE_first_tail_x6_r0_body.st172.wr PRE_first_tail_x6_r0_body.s1663 PRE_first_tail_x6_r0_body.st172.s2 PRE_first_tail_x6_r0_body.st172.s0
      PRE_first_tail_x6_r0_body.st172.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st172.F FR W stk M ν K PRE_first_tail_x6_r0_body.s1664 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso172 PRE_first_tail_x6_r0_body.stFoot172 PRE_first_tail_x6_r0_body.wrNodup172 PRE_first_tail_x6_r0_body.wrBound172 PRE_first_tail_x6_r0_body.trace172 PRE_first_tail_x6_r0_body.mheap172
    PRE_first_tail_x6_r0_body.mnext172 PRE_first_tail_x6_r0_body.mctl172 PRE_first_tail_x6_r0_body.mstack172 PRE_first_tail_x6_r0_body.mjobs172 PRE_first_tail_x6_r0_body.mffi172 PRE_first_tail_x6_r0_body.mtrace172 PRE_first_tail_x6_r0_body.mstores172 h

def PRE_first_tail_x6_r0_body.arrEl172_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE172_2665 : arrOf PRE_first_tail_x6_r0_body.s1664 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl172_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA172_2665 : isArrB PRE_first_tail_x6_r0_body.s1664 2665 = true
theorem PRE_first_tail_x6_r0_body.arr172_2665 : ∃ o, PRE_first_tail_x6_r0_body.s1664.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl172_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE172_2665 PRE_first_tail_x6_r0_body.arrA172_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN172_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl172_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR172_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl172_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN172_2665

def PRE_first_tail_x6_r0_body.arrEl172_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE172_2673467 : arrOf PRE_first_tail_x6_r0_body.s1664 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl172_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA172_2673467 : isArrB PRE_first_tail_x6_r0_body.s1664 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr172_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s1664.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl172_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE172_2673467 PRE_first_tail_x6_r0_body.arrA172_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN172_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl172_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR172_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl172_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN172_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k172 : isArrB PRE_first_tail_x6_r0_body.s1664 4910 = false
theorem PRE_first_tail_x6_r0_body.keep172 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s1664 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k172 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr172_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl172_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ172
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 172 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s1663`, the merged
state `PRE_first_tail_x6_r0_body.s1664`, the canonical state `PRE_first_tail_x6_r0_body.s1665`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl172 : PRE_first_tail_x6_r0_body.pl172.all (Nat.ble PRE_first_tail_x6_r0_body.s1663.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd172 : nodupT PRE_first_tail_x6_r0_body.pl172 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn1172 : Nat.ble PRE_first_tail_x6_r0_body.s1663.next 2810057 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst172 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s1663.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn172 : PRE_first_tail_x6_r0_body.s1665.next = PRE_first_tail_x6_r0_body.s1663.next + PRE_first_tail_x6_r0_body.pl172.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn172 : PRE_first_tail_x6_r0_body.s1664.next = 2810057
kernel_rfl PRE_first_tail_x6_r0_body.zgrow172 : Nat.ble PRE_first_tail_x6_r0_body.s1665.next PRE_first_tail_x6_r0_body.s1664.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh172 : PRE_first_tail_x6_r0_body.S1663.tab.all (fun e => PRE_first_tail_x6_r0_body.cws172.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd172 : nodupT PRE_first_tail_x6_r0_body.cws172 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi172 : PRE_first_tail_x6_r0_body.nr172.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S1664.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt172 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s1663.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg172_2665 : PRE_first_tail_x6_r0_body.s1665.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1665 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk172_2665 : (objOf PRE_first_tail_x6_r0_body.s1665 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm172_2665 : PRE_first_tail_x6_r0_body.s1664.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa172.obj (objOf PRE_first_tail_x6_r0_body.s1665 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s1664 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg172_2673467 : PRE_first_tail_x6_r0_body.s1665.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1665 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk172_2673467 : (objOf PRE_first_tail_x6_r0_body.s1665 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm172_2673467 : PRE_first_tail_x6_r0_body.s1664.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa172.obj (objOf PRE_first_tail_x6_r0_body.s1665 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s1664 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw172_4910 : (PRE_first_tail_x6_r0_body.s1665.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw172_2673472 : (PRE_first_tail_x6_r0_body.s1665.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw172_2673473 : (PRE_first_tail_x6_r0_body.s1665.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd172 : PRE_first_tail_x6_r0_body.cl172.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr172 : PRE_first_tail_x6_r0_body.st172.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s1663.next || PRE_first_tail_x6_r0_body.cl172.contains b) = true
def PRE_first_tail_x6_r0_body.zl172 : List Nat := PRE_first_tail_x6_r0_body.cl172.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE172 : PRE_first_tail_x6_r0_body.zl172.map (fun a => PRE_first_tail_x6_r0_body.s1664.heap.get (PRE_first_tail_x6_r0_body.kappa172.a a)) = PRE_first_tail_x6_r0_body.zl172.map (fun a => (PRE_first_tail_x6_r0_body.s1665.heap.get a).map PRE_first_tail_x6_r0_body.kappa172.hobj)
theorem PRE_first_tail_x6_r0_body.zimg172 : HeapImg PRE_first_tail_x6_r0_body.kappa172 PRE_first_tail_x6_r0_body.s1665 PRE_first_tail_x6_r0_body.s1664 PRE_first_tail_x6_r0_body.zl172 := PRE_first_tail_x6_r0_body.zimgE172
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl172 : PRE_first_tail_x6_r0_body.s1664.ctl = PRE_first_tail_x6_r0_body.kappa172.ctl PRE_first_tail_x6_r0_body.s1665.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack172 : PRE_first_tail_x6_r0_body.s1664.stack = PRE_first_tail_x6_r0_body.s1665.stack.map PRE_first_tail_x6_r0_body.kappa172.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs172 : PRE_first_tail_x6_r0_body.s1664.jobs = PRE_first_tail_x6_r0_body.s1665.jobs.map PRE_first_tail_x6_r0_body.kappa172.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores172 : PRE_first_tail_x6_r0_body.s1664.stores = PRE_first_tail_x6_r0_body.kappa172.stores PRE_first_tail_x6_r0_body.s1665.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots172 : checkRootsSupp PRE_first_tail_x6_r0_body.s1665 7433 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC172 : PRE_first_tail_x6_r0_body.S1663.tab.length + PRE_first_tail_x6_r0_body.cws172.length = 7433
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap172 : PRE_first_tail_x6_r0_body.kappa172 = Conv.Map.compact PRE_first_tail_x6_r0_body.s1663.next 2810057 PRE_first_tail_x6_r0_body.S1663.tab.length PRE_first_tail_x6_r0_body.pl172 (PRE_first_tail_x6_r0_body.nr172.map NumV.ref) PRE_first_tail_x6_r0_body.kd172.big
  PRE_first_tail_x6_r0_body.kd172.region PRE_first_tail_x6_r0_body.kd172.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin172 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1665.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc172 : Conv.jcleanListB (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1665 PRE_first_tail_x6_r0_body.cl172 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB172 : noBigRootsP (fun i => !Conv.oldBigB (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s1665.trace PRE_first_tail_x6_r0_body.s1665 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm172 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 18699 = true
theorem PRE_first_tail_x6_r0_body.cjcl172 (h : Conv.JClean (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1663) : Conv.JClean (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1665 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle172)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap172 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd172 a ha)) PRE_first_tail_x6_r0_body.zjc172

end Host.Load.Run.Tpl
end

section -- st172/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st172.bodyLast from PRE_first_tail_x6_r0_body.st172.s1 to PRE_first_tail_x6_r0_body.st172.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st172.F PRE_first_tail_x6_r0_body.st172.s1).run PRE_first_tail_x6_r0_body.st172.S1 = some (PRE_first_tail_x6_r0_body.st172.s2, PRE_first_tail_x6_r0_body.st172.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st172.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st172.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st172.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st172.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st172/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st172.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st172.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st172.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st172.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st172.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st172.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st172.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st172.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st172.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st172.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st172.s0 PRE_first_tail_x6_r0_body.st172.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st172.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st172.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st172.s1 PRE_first_tail_x6_r0_body.st172.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st172/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st172.bodyK0F from PRE_first_tail_x6_r0_body.st172.s0 to PRE_first_tail_x6_r0_body.st172.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st172.F (PRE_first_tail_x6_r0_body.st172.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st172.ks 0).getD 0) PRE_first_tail_x6_r0_body.st172.s0 PRE_first_tail_x6_r0_body.st172.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st172.s1, PRE_first_tail_x6_r0_body.st172.S1)
theorem PRE_first_tail_x6_r0_body.st172.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st172.F (PRE_first_tail_x6_r0_body.st172.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st172.ks 0).getD 0) PRE_first_tail_x6_r0_body.st172.s0 PRE_first_tail_x6_r0_body.st172.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st172.s1, PRE_first_tail_x6_r0_body.st172.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st172.bodyOkLN_ok PRE_first_tail_x6_r0_body.st172.bodyK0F
end Host.Load.Run.Tpl
end

section -- st172/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st172.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st172.F (PRE_first_tail_x6_r0_body.st172.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st172.s0 PRE_first_tail_x6_r0_body.st172.S0 = some (PRE_first_tail_x6_r0_body.st172.s1, PRE_first_tail_x6_r0_body.st172.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st172.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st172.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st172.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st172.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st172.F (PRE_first_tail_x6_r0_body.st172.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st172.s0
  S0 := PRE_first_tail_x6_r0_body.st172.S0
  s1 := PRE_first_tail_x6_r0_body.st172.s1
  S1 := PRE_first_tail_x6_r0_body.st172.S1
  s2 := PRE_first_tail_x6_r0_body.st172.s2
  S2 := PRE_first_tail_x6_r0_body.st172.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st172.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st172.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st172.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st172.bodyHalt
  last := PRE_first_tail_x6_r0_body.st172.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st172.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC173
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 173 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s1669` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa173` into the merged state
`PRE_first_tail_x6_r0_body.s1668`. -/

def PRE_first_tail_x6_r0_body.pl173 : List Nat := [2810362]
def PRE_first_tail_x6_r0_body.nr173 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd173 : RData :=
  ⟨2810344, 2810363, Stage.setAll PTrie.nil [(2810343, 2810362)], Stage.setAll PTrie.nil [],
   21600, 21600, 18703, 18703, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa173 : Map :=
  Conv.Map.compact 2810343 2810363 7450 PRE_first_tail_x6_r0_body.pl173 (PRE_first_tail_x6_r0_body.nr173.map NumV.ref) PRE_first_tail_x6_r0_body.kd173.big
    PRE_first_tail_x6_r0_body.kd173.region PRE_first_tail_x6_r0_body.kd173.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws173 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs173 : List SymE := PRE_first_tail_x6_r0_body.nr173.map fun r => (nth? PRE_first_tail_x6_r0_body.S1668.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta173 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws173 PRE_first_tail_x6_r0_body.crs173
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB173 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab173 : PRE_first_tail_x6_r0_body.S1669.tab = PRE_first_tail_x6_r0_body.S1667.tab ++ PRE_first_tail_x6_r0_body.cws173.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace173 : PRE_first_tail_x6_r0_body.s1669.trace = PRE_first_tail_x6_r0_body.s1667.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext173 : PRE_first_tail_x6_r0_body.s1669.next = 2810344
kernel_rfl PRE_first_tail_x6_r0_body.ccounters173 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1669.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1669.ffi).mlx.nnext) = (21600, 18703)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue173 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1668.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1669.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa173.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp173 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1669.ffi).mlx.tokens.all (bSN 7450) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean173 : Conv.cleanListB 21600 131072 (fun r => Nat.ble 86400 r) PRE_first_tail_x6_r0_body.s1669
    (PRE_first_tail_x6_r0_body.wrB173 ++ (List.range 1).map (2810343 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs173 : bigsOutB 21600 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1669.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK173
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl173`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl173 : List Nat := [2665, 2673467, 2810343]
def PRE_first_tail_x6_r0_body.clo173 : List Nat := []
def PRE_first_tail_x6_r0_body.cln173 : List Nat := []
def PRE_first_tail_x6_r0_body.cli173 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap173 : PRE_first_tail_x6_r0_body.s1669.heap = Stage.setAll PRE_first_tail_x6_r0_body.s1667.heap (PRE_first_tail_x6_r0_body.cl173.filterMap fun a => (PRE_first_tail_x6_r0_body.s1669.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe173 : Nat.ble PRE_first_tail_x6_r0_body.s1667.next PRE_first_tail_x6_r0_body.s1669.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP173 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s1667 PRE_first_tail_x6_r0_body.s1669 PRE_first_tail_x6_r0_body.cl173 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp173 : Conv.suppListB PRE_first_tail_x6_r0_body.s1669 7450 PRE_first_tail_x6_r0_body.cl173 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound173 : Conv.boundListB PRE_first_tail_x6_r0_body.s1669 PRE_first_tail_x6_r0_body.cl173 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK173 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1669.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln173.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1669.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK173 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1669.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo173.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1669.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK173 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1669.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli173.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1669.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst173 : Conv.sstListB 7450 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1669.ffi).mlx PRE_first_tail_x6_r0_body.cln173 PRE_first_tail_x6_r0_body.clo173 PRE_first_tail_x6_r0_body.cli173 = true

end Host.Load.Run.Tpl
end

section -- SiteCl173
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA173 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1669.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo173.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1669.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd173 : (PRE_first_tail_x6_r0_body.clo173 ++ PRE_first_tail_x6_r0_body.cln173 ++ PRE_first_tail_x6_r0_body.cli173).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle173 : Conv.Cnt.leB (⟨21600, 18703, 2810343, 7450⟩ : Conv.Cnt) (⟨21600, 18703, 2810344, 7450⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck173 : Conv.ncleanListB (⟨21600, 18703, 2810344, 7450⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1669.ffi).mlx PRE_first_tail_x6_r0_body.clo173 PRE_first_tail_x6_r0_body.cln173 PRE_first_tail_x6_r0_body.cli173 = true
theorem PRE_first_tail_x6_r0_body.cncl173 (h : Conv.NClean (⟨21600, 18703, 2810343, 7450⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx) : Conv.NClean (⟨21600, 18703, 2810344, 7450⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1669.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle173 PRE_first_tail_x6_r0_body.ckA173 PRE_first_tail_x6_r0_body.cobjsK173 PRE_first_tail_x6_r0_body.cnodesK173 PRE_first_tail_x6_r0_body.citemsK173 PRE_first_tail_x6_r0_body.cbd173 PRE_first_tail_x6_r0_body.cck173

end Host.Load.Run.Tpl
end

section -- SiteS173
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 173 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc173 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P173 : LoadP := PRE_first_tail_x6_r0_body.Pc173.raise 18703
kernel_rfl PRE_first_tail_x6_r0_body.craise173 : Nat.ble PRE_first_tail_x6_r0_body.Pc173.N0 18703 = true
theorem PRE_first_tail_x6_r0_body.raised173 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc173 PRE_first_tail_x6_r0_body.P173 :=
  .inr ⟨18703, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise173, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_173 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1669.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_173 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1668.ffi)
def PRE_first_tail_x6_r0_body.khinv173 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv173 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS173 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS173 : List Nat := List.range' 18703 0
def PRE_first_tail_x6_r0_body.ciS173 : List Nat := [] ++ List.range' 18703 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh0173 : PRE_first_tail_x6_r0_body.kd173.nh0 = PRE_first_tail_x6_r0_body.cx0_173.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh1173 : PRE_first_tail_x6_r0_body.kd173.nh1 = PRE_first_tail_x6_r0_body.cx1_173.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn0173 : PRE_first_tail_x6_r0_body.kd173.nn0 = PRE_first_tail_x6_r0_body.cx0_173.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn1173 : PRE_first_tail_x6_r0_body.kd173.nn1 = PRE_first_tail_x6_r0_body.cx1_173.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo173 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P173.lo && Nat.ble PRE_first_tail_x6_r0_body.P173.lo PRE_first_tail_x6_r0_body.cx0_173.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P173.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P173.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt173 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_173.mlx.next PRE_first_tail_x6_r0_body.cx1_173.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_173.mlx.nnext PRE_first_tail_x6_r0_body.cx1_173.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband173 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P173.NL && Nat.ble PRE_first_tail_x6_r0_body.P173.NL PRE_first_tail_x6_r0_body.P173.N0 && Nat.ble PRE_first_tail_x6_r0_body.P173.N0 PRE_first_tail_x6_r0_body.cx0_173.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow173 : PRE_first_tail_x6_r0_body.kd173.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren173 : checkRenG PRE_first_tail_x6_r0_body.kd173.hnd PRE_first_tail_x6_r0_body.khinv173 (phB PRE_first_tail_x6_r0_body.cx0_173.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband173 : PRE_first_tail_x6_r0_body.kd173.checkBand PRE_first_tail_x6_r0_body.P173.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos173 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd173.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren173 : checkRenG PRE_first_tail_x6_r0_body.kd173.node PRE_first_tail_x6_r0_body.kninv173 (pnB PRE_first_tail_x6_r0_body.cx0_173.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow173 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd173.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P173.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd173.nodeF j) PRE_first_tail_x6_r0_body.cx1_173.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a173 : PRE_first_tail_x6_r0_body.cx0_173.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b173 : PRE_first_tail_x6_r0_body.cx0_173.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok1173 : PRE_first_tail_x6_r0_body.cx1_173.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend173 : PRE_first_tail_x6_r0_body.cx1_173.mlx.pending = PRE_first_tail_x6_r0_body.cx0_173.mlx.pending.map PRE_first_tail_x6_r0_body.kappa173.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh173 : PRE_first_tail_x6_r0_body.cx1_173.mlx.errh = PRE_first_tail_x6_r0_body.cx0_173.mlx.errh.map PRE_first_tail_x6_r0_body.kappa173.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles173 : PRE_first_tail_x6_r0_body.cx1_173.mlx.files = PRE_first_tail_x6_r0_body.cx0_173.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch173 : PRE_first_tail_x6_r0_body.cx1_173.mlx.arch = PRE_first_tail_x6_r0_body.cx0_173.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes173 : PRE_first_tail_x6_r0_body.cx1_173.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_173.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired173 : PRE_first_tail_x6_r0_body.cx1_173.mlx.wired = PRE_first_tail_x6_r0_body.cx0_173.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost173 : PRE_first_tail_x6_r0_body.cx1_173.host = PRE_first_tail_x6_r0_body.cx0_173.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd173`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn0173 : PRE_first_tail_x6_r0_body.kd173.n0 = 2810344
kernel_rfl PRE_first_tail_x6_r0_body.ckn1173 : PRE_first_tail_x6_r0_body.kd173.n1 = 2810363
kernel_rfl PRE_first_tail_x6_r0_body.ckheap173 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd173.heap).all (fun x => Nat.ble 2810343 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl173 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd173.heap.get (2810343 + j) = nth? PRE_first_tail_x6_r0_body.pl173 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja173 : Nat.ble 2810343 2810343 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn173 : Nat.ble 7450 7450 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD173 : Nat.ble 2810343 PRE_first_tail_x6_r0_body.kd173.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn173 : Nat.ble 21600 PRE_first_tail_x6_r0_body.kd173.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn173 : Nat.ble 18703 PRE_first_tail_x6_r0_body.kd173.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb173 : Nat.ble 21600 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap173 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd173.heap).all (Nat.ble (⟨21600, 18703, 2810343, 7450⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd173 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd173.hnd).all (Nat.ble (⟨21600, 18703, 2810343, 7450⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode173 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd173.node).all (Nat.ble (⟨21600, 18703, 2810343, 7450⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix173 : Conv.FixOld (⟨21600, 18703, 2810343, 7450⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa173 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja173) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn173) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD173) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn173) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn173) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb173) PRE_first_tail_x6_r0_body.fheap173 PRE_first_tail_x6_r0_body.fhnd173 PRE_first_tail_x6_r0_body.fnode173
kernel_rfl PRE_first_tail_x6_r0_body.fcxn173 : (⟨21600, 18703, 2810343, 7450⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn173 : (⟨21600, 18703, 2810343, 7450⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle0173 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_173.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_173.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk173 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd173.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A173 : PRE_first_tail_x6_r0_body.cx1_173.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS173.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_173.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O173 : PRE_first_tail_x6_r0_body.cx1_173.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS173.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_173.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N173 : PRE_first_tail_x6_r0_body.cx1_173.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS173.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_173.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I173 : PRE_first_tail_x6_r0_body.cx1_173.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS173.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_173.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd173 : (PRE_first_tail_x6_r0_body.clo173 ++ PRE_first_tail_x6_r0_body.cln173 ++ PRE_first_tail_x6_r0_body.cli173 ++ PRE_first_tail_x6_r0_body.cwS173 ++ PRE_first_tail_x6_r0_body.cnS173 ++ PRE_first_tail_x6_r0_body.ciS173).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW173 : PRE_first_tail_x6_r0_body.cwS173.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo173.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI173 : PRE_first_tail_x6_r0_body.ciS173.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli173.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN173 : PRE_first_tail_x6_r0_body.cnS173.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF173 : PRE_first_tail_x6_r0_body.cln173.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh173 : PRE_first_tail_x6_r0_body.clo173.all (handleOK PRE_first_tail_x6_r0_body.kappa173 PRE_first_tail_x6_r0_body.P173.lo PRE_first_tail_x6_r0_body.cx0_173.mlx PRE_first_tail_x6_r0_body.cx1_173.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo173 : PRE_first_tail_x6_r0_body.clo173.map (fun h => PRE_first_tail_x6_r0_body.cx1_173.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa173.handle h)) = PRE_first_tail_x6_r0_body.clo173.map (fun h => (PRE_first_tail_x6_r0_body.cx0_173.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa173.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok173 : PRE_first_tail_x6_r0_body.clo173.all (objOK PRE_first_tail_x6_r0_body.kappa173 PRE_first_tail_x6_r0_body.P173.NL PRE_first_tail_x6_r0_body.cx0_173.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd173 : PRE_first_tail_x6_r0_body.cln173.all (nodeOKF PRE_first_tail_x6_r0_body.kappa173 PRE_first_tail_x6_r0_body.P173 PRE_first_tail_x6_r0_body.cx0_173.mlx PRE_first_tail_x6_r0_body.cx1_173.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp173 : ((PRE_first_tail_x6_r0_body.cln173.filter (fullB PRE_first_tail_x6_r0_body.P173))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_173.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa173.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln173.filter (fullB PRE_first_tail_x6_r0_body.P173))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_173.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa173.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI173 : incrB PRE_first_tail_x6_r0_body.kd173.nodeF (List.range' 18703 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK173 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd173.node).all (fun k => Nat.ble 18703 k && Nat.blt k 18703) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL173 : (PRE_first_tail_x6_r0_body.cln173.filter (Nat.ble PRE_first_tail_x6_r0_body.P173.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd173.nodeF i) && (Nat.blt i 18703 || Nat.ble PRE_first_tail_x6_r0_body.kd173.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord173 : (PRE_first_tail_x6_r0_body.cln173.filter (Nat.ble PRE_first_tail_x6_r0_body.P173.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd173.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd173.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd173.nodeF j) (PRE_first_tail_x6_r0_body.kd173.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow173 PRE_first_tail_x6_r0_body.cnn1173 PRE_first_tail_x6_r0_body.fnordI173 PRE_first_tail_x6_r0_body.fnordK173 PRE_first_tail_x6_r0_body.fnordL173
kernel_rfl PRE_first_tail_x6_r0_body.fi173 : PRE_first_tail_x6_r0_body.cli173.all (pnB PRE_first_tail_x6_r0_body.cx0_173.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii173 : PRE_first_tail_x6_r0_body.cli173.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_173.mlx.items.get (PRE_first_tail_x6_r0_body.kappa173.node k) = (PRE_first_tail_x6_r0_body.cx0_173.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa173.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot173 (clean : Conv.NClean (⟨21600, 18703, 2810343, 7450⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P173.NL) (cl : SSt (· < 7450) PRE_first_tail_x6_r0_body.cx0_173.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P173 7450 PRE_first_tail_x6_r0_body.kappa173 PRE_first_tail_x6_r0_body.kd173 PRE_first_tail_x6_r0_body.khinv173 PRE_first_tail_x6_r0_body.kninv173 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx PRE_first_tail_x6_r0_body.cx0_173.mlx PRE_first_tail_x6_r0_body.cx1_173.mlx (⟨21600, 18703, 2810343, 7450⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo173 PRE_first_tail_x6_r0_body.cln173 PRE_first_tail_x6_r0_body.cli173 PRE_first_tail_x6_r0_body.cwS173 PRE_first_tail_x6_r0_body.cnS173 PRE_first_tail_x6_r0_body.ciS173 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh0173, PRE_first_tail_x6_r0_body.cnh1173, PRE_first_tail_x6_r0_body.cnn0173, PRE_first_tail_x6_r0_body.cnn1173, PRE_first_tail_x6_r0_body.cplo173, PRE_first_tail_x6_r0_body.ccnt173, PRE_first_tail_x6_r0_body.cnband173, PRE_first_tail_x6_r0_body.chbelow173, PRE_first_tail_x6_r0_body.chren173, PRE_first_tail_x6_r0_body.cband173, PRE_first_tail_x6_r0_body.cnh1pos173, PRE_first_tail_x6_r0_body.cnren173, PRE_first_tail_x6_r0_body.cnlow173, PRE_first_tail_x6_r0_body.cabs0a173, PRE_first_tail_x6_r0_body.cabs0b173, PRE_first_tail_x6_r0_body.ctok1173, PRE_first_tail_x6_r0_body.cpend173, PRE_first_tail_x6_r0_body.cerrh173, PRE_first_tail_x6_r0_body.cfiles173, PRE_first_tail_x6_r0_body.carch173, PRE_first_tail_x6_r0_body.csizes173, PRE_first_tail_x6_r0_body.cwired173, PRE_first_tail_x6_r0_body.cfix173, clean, PRE_first_tail_x6_r0_body.fcxn173, PRE_first_tail_x6_r0_body.fcnn173, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle0173, PRE_first_tail_x6_r0_body.fnk173, PRE_first_tail_x6_r0_body.ckA173, PRE_first_tail_x6_r0_body.cobjsK173, PRE_first_tail_x6_r0_body.cnodesK173, PRE_first_tail_x6_r0_body.citemsK173, PRE_first_tail_x6_r0_body.f1A173, PRE_first_tail_x6_r0_body.f1O173, PRE_first_tail_x6_r0_body.f1N173, PRE_first_tail_x6_r0_body.f1I173, PRE_first_tail_x6_r0_body.fbd173, PRE_first_tail_x6_r0_body.fincW173, PRE_first_tail_x6_r0_body.fincI173, PRE_first_tail_x6_r0_body.fincN173, PRE_first_tail_x6_r0_body.flnF173, PRE_first_tail_x6_r0_body.fh173, PRE_first_tail_x6_r0_body.fo173, PRE_first_tail_x6_r0_body.fok173, PRE_first_tail_x6_r0_body.fnd173, PRE_first_tail_x6_r0_body.fp173, PRE_first_tail_x6_r0_body.fnord173, PRE_first_tail_x6_r0_body.fi173, PRE_first_tail_x6_r0_body.fii173⟩
theorem PRE_first_tail_x6_r0_body.cnshift173 (clean : Conv.NClean (⟨21600, 18703, 2810343, 7450⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P173.NL) (cl : SSt (· < 7450) PRE_first_tail_x6_r0_body.cx0_173.mlx) : NShift PRE_first_tail_x6_r0_body.P173 7450 PRE_first_tail_x6_r0_body.kappa173 PRE_first_tail_x6_r0_body.cx0_173 PRE_first_tail_x6_r0_body.cx1_173 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot173 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost173 (compact_a_eq PRE_first_tail_x6_r0_body.ckn0173 PRE_first_tail_x6_r0_body.ckn1173 PRE_first_tail_x6_r0_body.ckheap173 PRE_first_tail_x6_r0_body.ckpl173)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_173 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1667.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_173 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1667.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_173 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1667.ffi) = some PRE_first_tail_x6_r0_body.fxC_173
kernel_rfl PRE_first_tail_x6_r0_body.okrC_173 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1667.ffi) = some PRE_first_tail_x6_r0_body.krC_173
noncomputable def PRE_first_tail_x6_r0_body.fx0_173 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1669.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_173 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1669.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_173 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1669.ffi) = some PRE_first_tail_x6_r0_body.fx0_173
kernel_rfl PRE_first_tail_x6_r0_body.okr0_173 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1669.ffi) = some PRE_first_tail_x6_r0_body.kr0_173
noncomputable def PRE_first_tail_x6_r0_body.fx1_173 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1668.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_173 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1668.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_173 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1668.ffi) = some PRE_first_tail_x6_r0_body.fx1_173
kernel_rfl PRE_first_tail_x6_r0_body.okr1_173 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1668.ffi) = some PRE_first_tail_x6_r0_body.kr1_173
kernel_rfl PRE_first_tail_x6_r0_body.ff0173 : PRE_first_tail_x6_r0_body.fx0_173 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_173 (PRE_first_tail_x6_r0_body.clo173.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_173.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff1173 : PRE_first_tail_x6_r0_body.fx1_173 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_173 (PRE_first_tail_x6_r0_body.cwS173.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_173.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck173 : freedLB PRE_first_tail_x6_r0_body.kappa173 PRE_first_tail_x6_r0_body.cx0_173.mlx PRE_first_tail_x6_r0_body.fx0_173 PRE_first_tail_x6_r0_body.fx1_173 PRE_first_tail_x6_r0_body.clo173 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf0173 : PRE_first_tail_x6_r0_body.kr0_173.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_173.flags (PRE_first_tail_x6_r0_body.clo173.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_173.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt0173 : PRE_first_tail_x6_r0_body.kr0_173.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_173.targs (PRE_first_tail_x6_r0_body.clo173.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_173.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf1173 : PRE_first_tail_x6_r0_body.kr1_173.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_173.flags (PRE_first_tail_x6_r0_body.cwS173.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_173.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt1173 : PRE_first_tail_x6_r0_body.kr1_173.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_173.targs (PRE_first_tail_x6_r0_body.cwS173.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_173.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck173 : krecLB PRE_first_tail_x6_r0_body.kappa173 7450 PRE_first_tail_x6_r0_body.cx0_173.mlx PRE_first_tail_x6_r0_body.kr0_173 PRE_first_tail_x6_r0_body.kr1_173 PRE_first_tail_x6_r0_body.clo173 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn173 : Nat.ble 7450 7450 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge173 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1668.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1669.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR173 : pendRegB PRE_first_tail_x6_r0_body.kappa173 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1669.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe173 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1669.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1668.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift173 (clean : Conv.NClean (⟨21600, 18703, 2810343, 7450⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P173.NL) (cl : SSt (· < 7450) PRE_first_tail_x6_r0_body.cx0_173.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_173.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_173.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_173.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1667.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_173.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21600, 18703, 2810343, 7450⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P173 7450 PRE_first_tail_x6_r0_body.kappa173 PRE_first_tail_x6_r0_body.s1669.ffi PRE_first_tail_x6_r0_body.s1668.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift173 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue173, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp173 t ht),
    PRE_first_tail_x6_r0_body.cbridge173,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1669.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1668.ffi) (PRE_first_tail_x6_r0_body.cfoot173 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_173 PRE_first_tail_x6_r0_body.ofx1_173 hobjC PRE_first_tail_x6_r0_body.ff0173 PRE_first_tail_x6_r0_body.ff1173 PRE_first_tail_x6_r0_body.ffck173,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1669.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1668.ffi) (PRE_first_tail_x6_r0_body.cfoot173 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_173 PRE_first_tail_x6_r0_body.okr1_173 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn173) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf0173 PRE_first_tail_x6_r0_body.fkt0173 PRE_first_tail_x6_r0_body.fkf1173 PRE_first_tail_x6_r0_body.fkt1173 PRE_first_tail_x6_r0_body.fkck173,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh0173 PRE_first_tail_x6_r0_body.cnh1173 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe173) PRE_first_tail_x6_r0_body.cpendR173⟩

end Host.Load.Run.Tpl
end

section -- st173/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st173 0
host_stream_state PRE_first_tail_x6_r0_body.st173 1
host_stream_state PRE_first_tail_x6_r0_body.st173 2
end Host.Load.Run.Tpl
end

section -- Site173
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 173 of chain `PRE_first_tail_x6_r0_body`: `plan__g173__g174` (`plan`), the call state `PRE_first_tail_x6_r0_body.s1667`, the merged state `PRE_first_tail_x6_r0_body.s1668`,
the site template `PRE_first_tail_x6_r0_body.st173` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s1669`: the merge.
The footprint's facts are in `SiteF173`, the compaction's in `SiteC173`, `SiteK173`, `SiteNa173`, `SiteNb173`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso173 : PRE_first_tail_x6_r0_body.st173.s0 = { PRE_first_tail_x6_r0_body.s1667 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs173 : List Frame := PRE_first_tail_x6_r0_body.s1667.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_173 : PRE_first_tail_x6_r0_body.S1667.tab.length = 7450
kernel_rfl PRE_first_tail_x6_r0_body.tab0_173 : PRE_first_tail_x6_r0_body.st173.S0.tab = PRE_first_tail_x6_r0_body.S1667.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws173 : List Nat := [3921, 3922, 3923, 3924, 3925, 3926, 3927, 3928, 3929]
kernel_rfl PRE_first_tail_x6_r0_body.fresh173 : (PRE_first_tail_x6_r0_body.S1667.tab.all fun e => PRE_first_tail_x6_r0_body.ws173.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S1667.oracle.all fun q => PRE_first_tail_x6_r0_body.ws173.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab173 : PRE_first_tail_x6_r0_body.S1668.tab = PRE_first_tail_x6_r0_body.S1667.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws173
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen173 : PRE_first_tail_x6_r0_body.st173.S2.tab.length - PRE_first_tail_x6_r0_body.st173.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged173`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap173 : PRE_first_tail_x6_r0_body.s1668.heap = PRE_first_tail_x6_r0_body.st173.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext173 : PRE_first_tail_x6_r0_body.s1668.next = PRE_first_tail_x6_r0_body.st173.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl173 : PRE_first_tail_x6_r0_body.s1668.ctl = PRE_first_tail_x6_r0_body.st173.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack173 : PRE_first_tail_x6_r0_body.s1668.stack = PRE_first_tail_x6_r0_body.st173.s2.stack ++ PRE_first_tail_x6_r0_body.s1667.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs173 : PRE_first_tail_x6_r0_body.s1668.jobs = PRE_first_tail_x6_r0_body.st173.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi173 : PRE_first_tail_x6_r0_body.s1668.ffi = PRE_first_tail_x6_r0_body.st173.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace173 : PRE_first_tail_x6_r0_body.s1668.trace = PRE_first_tail_x6_r0_body.st173.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores173 : PRE_first_tail_x6_r0_body.s1668.stores = PRE_first_tail_x6_r0_body.st173.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD173
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 173 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived173 : PRE_first_tail_x6_r0_body.nr173.map (fun r => nth? PRE_first_tail_x6_r0_body.st173.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo173 : PRE_first_tail_x6_r0_body.nr173.all (Nat.ble 7450) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj173 : PRE_first_tail_x6_r0_body.cws173.all (fun c => !PRE_first_tail_x6_r0_body.ws173.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ173 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws173 PRE_first_tail_x6_r0_body.crs173 PRE_first_tail_x6_r0_body.ws173

end Host.Load.Run.Tpl
end

section -- st173/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st173`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st173.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st173.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st173.s2.heap PRE_first_tail_x6_r0_body.st173.wrR ++ freshOf PRE_first_tail_x6_r0_body.st173.s2.heap PRE_first_tail_x6_r0_body.st173.s0.next PRE_first_tail_x6_r0_body.st173.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st173.wr : List Nat := PRE_first_tail_x6_r0_body.st173.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st173.heapFoot : PRE_first_tail_x6_r0_body.st173.s2.heap = setAll PRE_first_tail_x6_r0_body.st173.s0.heap PRE_first_tail_x6_r0_body.st173.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st173.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st173.s0.next PRE_first_tail_x6_r0_body.st173.s2.next = true
theorem PRE_first_tail_x6_r0_body.st173.grows : PRE_first_tail_x6_r0_body.st173.s0.next ≤ PRE_first_tail_x6_r0_body.st173.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st173.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st173.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st173.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st173.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st173.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st173.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st173.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st173.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st173.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st173.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st173.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st173.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st173.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st173.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st173.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st173.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st173.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st173.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st173.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st173.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st173.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st173.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st173.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st173.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st173.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st173.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st173.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st173.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st173.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st173.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st173.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st173.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF173
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 173 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB173 : nodupT PRE_first_tail_x6_r0_body.st173.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup173 : PRE_first_tail_x6_r0_body.st173.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB173).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB173 : PRE_first_tail_x6_r0_body.st173.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound173 : ∀ b ∈ PRE_first_tail_x6_r0_body.st173.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB173 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr173 := PRE_first_tail_x6_r0_body.st173.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq173 : PRE_first_tail_x6_r0_body.st173.s2.trace = PRE_first_tail_x6_r0_body.trFr173 ++ PRE_first_tail_x6_r0_body.st173.s0.trace
theorem PRE_first_tail_x6_r0_body.trace173 : ∃ fr, PRE_first_tail_x6_r0_body.st173.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st173.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq173⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide173 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB173 : (PRE_first_tail_x6_r0_body.wide173.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st173.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix173 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide173, WFix Map.id (Present PRE_first_tail_x6_r0_body.st173.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB173 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL173
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 173 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s1668`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO173 : PRE_first_tail_x6_r0_body.st173.S0.oracle = PRE_first_tail_x6_r0_body.st173.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B173 : PRE_first_tail_x6_r0_body.st173.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st173.s0.next || (PRE_first_tail_x6_r0_body.st173.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot173 : Conv.StageFoot PRE_first_tail_x6_r0_body.st173.wr PRE_first_tail_x6_r0_body.st173.s0 PRE_first_tail_x6_r0_body.st173.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st173.heapFoot PRE_first_tail_x6_r0_body.wrNodup173 PRE_first_tail_x6_r0_body.wrBound173 PRE_first_tail_x6_r0_body.wr0B173 PRE_first_tail_x6_r0_body.st173.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged173 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st173.F.S → PRE_first_tail_x6_r0_body.st173.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st173.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st173.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs173 PRE_first_tail_x6_r0_body.st173.wr PRE_first_tail_x6_r0_body.s1667 PRE_first_tail_x6_r0_body.st173.s2 PRE_first_tail_x6_r0_body.st173.s0
      PRE_first_tail_x6_r0_body.st173.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st173.F FR W stk M ν K PRE_first_tail_x6_r0_body.s1668 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso173 PRE_first_tail_x6_r0_body.stFoot173 PRE_first_tail_x6_r0_body.wrNodup173 PRE_first_tail_x6_r0_body.wrBound173 PRE_first_tail_x6_r0_body.trace173 PRE_first_tail_x6_r0_body.mheap173
    PRE_first_tail_x6_r0_body.mnext173 PRE_first_tail_x6_r0_body.mctl173 PRE_first_tail_x6_r0_body.mstack173 PRE_first_tail_x6_r0_body.mjobs173 PRE_first_tail_x6_r0_body.mffi173 PRE_first_tail_x6_r0_body.mtrace173 PRE_first_tail_x6_r0_body.mstores173 h

def PRE_first_tail_x6_r0_body.arrEl173_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE173_2665 : arrOf PRE_first_tail_x6_r0_body.s1668 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl173_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA173_2665 : isArrB PRE_first_tail_x6_r0_body.s1668 2665 = true
theorem PRE_first_tail_x6_r0_body.arr173_2665 : ∃ o, PRE_first_tail_x6_r0_body.s1668.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl173_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE173_2665 PRE_first_tail_x6_r0_body.arrA173_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN173_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl173_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR173_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl173_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN173_2665

def PRE_first_tail_x6_r0_body.arrEl173_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE173_2673467 : arrOf PRE_first_tail_x6_r0_body.s1668 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl173_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA173_2673467 : isArrB PRE_first_tail_x6_r0_body.s1668 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr173_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s1668.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl173_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE173_2673467 PRE_first_tail_x6_r0_body.arrA173_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN173_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl173_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR173_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl173_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN173_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k173 : isArrB PRE_first_tail_x6_r0_body.s1668 4910 = false
theorem PRE_first_tail_x6_r0_body.keep173 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s1668 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k173 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr173_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl173_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ173
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 173 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s1667`, the merged
state `PRE_first_tail_x6_r0_body.s1668`, the canonical state `PRE_first_tail_x6_r0_body.s1669`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl173 : PRE_first_tail_x6_r0_body.pl173.all (Nat.ble PRE_first_tail_x6_r0_body.s1667.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd173 : nodupT PRE_first_tail_x6_r0_body.pl173 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn1173 : Nat.ble PRE_first_tail_x6_r0_body.s1667.next 2810363 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst173 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s1667.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn173 : PRE_first_tail_x6_r0_body.s1669.next = PRE_first_tail_x6_r0_body.s1667.next + PRE_first_tail_x6_r0_body.pl173.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn173 : PRE_first_tail_x6_r0_body.s1668.next = 2810363
kernel_rfl PRE_first_tail_x6_r0_body.zgrow173 : Nat.ble PRE_first_tail_x6_r0_body.s1669.next PRE_first_tail_x6_r0_body.s1668.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh173 : PRE_first_tail_x6_r0_body.S1667.tab.all (fun e => PRE_first_tail_x6_r0_body.cws173.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd173 : nodupT PRE_first_tail_x6_r0_body.cws173 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi173 : PRE_first_tail_x6_r0_body.nr173.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S1668.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt173 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s1667.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg173_2665 : PRE_first_tail_x6_r0_body.s1669.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1669 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk173_2665 : (objOf PRE_first_tail_x6_r0_body.s1669 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm173_2665 : PRE_first_tail_x6_r0_body.s1668.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa173.obj (objOf PRE_first_tail_x6_r0_body.s1669 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s1668 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg173_2673467 : PRE_first_tail_x6_r0_body.s1669.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1669 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk173_2673467 : (objOf PRE_first_tail_x6_r0_body.s1669 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm173_2673467 : PRE_first_tail_x6_r0_body.s1668.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa173.obj (objOf PRE_first_tail_x6_r0_body.s1669 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s1668 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw173_4910 : (PRE_first_tail_x6_r0_body.s1669.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw173_2673472 : (PRE_first_tail_x6_r0_body.s1669.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw173_2673473 : (PRE_first_tail_x6_r0_body.s1669.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd173 : PRE_first_tail_x6_r0_body.cl173.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr173 : PRE_first_tail_x6_r0_body.st173.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s1667.next || PRE_first_tail_x6_r0_body.cl173.contains b) = true
def PRE_first_tail_x6_r0_body.zl173 : List Nat := PRE_first_tail_x6_r0_body.cl173.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE173 : PRE_first_tail_x6_r0_body.zl173.map (fun a => PRE_first_tail_x6_r0_body.s1668.heap.get (PRE_first_tail_x6_r0_body.kappa173.a a)) = PRE_first_tail_x6_r0_body.zl173.map (fun a => (PRE_first_tail_x6_r0_body.s1669.heap.get a).map PRE_first_tail_x6_r0_body.kappa173.hobj)
theorem PRE_first_tail_x6_r0_body.zimg173 : HeapImg PRE_first_tail_x6_r0_body.kappa173 PRE_first_tail_x6_r0_body.s1669 PRE_first_tail_x6_r0_body.s1668 PRE_first_tail_x6_r0_body.zl173 := PRE_first_tail_x6_r0_body.zimgE173
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl173 : PRE_first_tail_x6_r0_body.s1668.ctl = PRE_first_tail_x6_r0_body.kappa173.ctl PRE_first_tail_x6_r0_body.s1669.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack173 : PRE_first_tail_x6_r0_body.s1668.stack = PRE_first_tail_x6_r0_body.s1669.stack.map PRE_first_tail_x6_r0_body.kappa173.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs173 : PRE_first_tail_x6_r0_body.s1668.jobs = PRE_first_tail_x6_r0_body.s1669.jobs.map PRE_first_tail_x6_r0_body.kappa173.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores173 : PRE_first_tail_x6_r0_body.s1668.stores = PRE_first_tail_x6_r0_body.kappa173.stores PRE_first_tail_x6_r0_body.s1669.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots173 : checkRootsSupp PRE_first_tail_x6_r0_body.s1669 7450 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC173 : PRE_first_tail_x6_r0_body.S1667.tab.length + PRE_first_tail_x6_r0_body.cws173.length = 7450
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap173 : PRE_first_tail_x6_r0_body.kappa173 = Conv.Map.compact PRE_first_tail_x6_r0_body.s1667.next 2810363 PRE_first_tail_x6_r0_body.S1667.tab.length PRE_first_tail_x6_r0_body.pl173 (PRE_first_tail_x6_r0_body.nr173.map NumV.ref) PRE_first_tail_x6_r0_body.kd173.big
  PRE_first_tail_x6_r0_body.kd173.region PRE_first_tail_x6_r0_body.kd173.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin173 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1669.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc173 : Conv.jcleanListB (⟨21600, 18703, 2810344, 7450⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1669 PRE_first_tail_x6_r0_body.cl173 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB173 : noBigRootsP (fun i => !Conv.oldBigB (⟨21600, 18703, 2810344, 7450⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s1669.trace PRE_first_tail_x6_r0_body.s1669 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm173 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 18703 = true
theorem PRE_first_tail_x6_r0_body.cjcl173 (h : Conv.JClean (⟨21600, 18703, 2810343, 7450⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1667) : Conv.JClean (⟨21600, 18703, 2810344, 7450⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1669 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle173)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap173 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd173 a ha)) PRE_first_tail_x6_r0_body.zjc173

end Host.Load.Run.Tpl
end

section -- st173/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st173.bodyLast from PRE_first_tail_x6_r0_body.st173.s1 to PRE_first_tail_x6_r0_body.st173.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st173.F PRE_first_tail_x6_r0_body.st173.s1).run PRE_first_tail_x6_r0_body.st173.S1 = some (PRE_first_tail_x6_r0_body.st173.s2, PRE_first_tail_x6_r0_body.st173.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st173.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st173.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st173.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st173.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st173/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st173.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st173.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st173.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st173.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st173.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st173.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st173.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st173.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st173.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st173.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st173.s0 PRE_first_tail_x6_r0_body.st173.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st173.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st173.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st173.s1 PRE_first_tail_x6_r0_body.st173.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st173/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st173.bodyK0F from PRE_first_tail_x6_r0_body.st173.s0 to PRE_first_tail_x6_r0_body.st173.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st173.F (PRE_first_tail_x6_r0_body.st173.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st173.ks 0).getD 0) PRE_first_tail_x6_r0_body.st173.s0 PRE_first_tail_x6_r0_body.st173.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st173.s1, PRE_first_tail_x6_r0_body.st173.S1)
theorem PRE_first_tail_x6_r0_body.st173.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st173.F (PRE_first_tail_x6_r0_body.st173.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st173.ks 0).getD 0) PRE_first_tail_x6_r0_body.st173.s0 PRE_first_tail_x6_r0_body.st173.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st173.s1, PRE_first_tail_x6_r0_body.st173.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st173.bodyOkLN_ok PRE_first_tail_x6_r0_body.st173.bodyK0F
end Host.Load.Run.Tpl
end

section -- st173/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st173.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st173.F (PRE_first_tail_x6_r0_body.st173.bodyOkL bytes rows) 206 PRE_first_tail_x6_r0_body.st173.s0 PRE_first_tail_x6_r0_body.st173.S0 = some (PRE_first_tail_x6_r0_body.st173.s1, PRE_first_tail_x6_r0_body.st173.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st173.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st173.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st173.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st173.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st173.F (PRE_first_tail_x6_r0_body.st173.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st173.s0
  S0 := PRE_first_tail_x6_r0_body.st173.S0
  s1 := PRE_first_tail_x6_r0_body.st173.s1
  S1 := PRE_first_tail_x6_r0_body.st173.S1
  s2 := PRE_first_tail_x6_r0_body.st173.s2
  S2 := PRE_first_tail_x6_r0_body.st173.S2
  n := 206
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st173.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st173.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st173.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st173.bodyHalt
  last := PRE_first_tail_x6_r0_body.st173.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st173.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC174
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 174 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s1686` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa174` into the merged state
`PRE_first_tail_x6_r0_body.s1685`. -/

def PRE_first_tail_x6_r0_body.pl174 : List Nat := [2812931, 2812106, 2812937, 2812933, 2812108, 2812939]
def PRE_first_tail_x6_r0_body.nr174 : List Nat := [7553, 7552, 7528, 7536, 7541, 7546, 7551, 7525, 7526, 7527, 7534, 7535, 7523, 7530, 7531, 7532, 7533, 7529]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd174 : RData :=
  ⟨2811825, 2812974, Stage.setAll PTrie.nil [(2811819, 2812931), (2811820, 2812106), (2811821, 2812937), (2811822, 2812933), (2811823, 2812108), (2811824, 2812939)], Stage.setAll PTrie.nil [(21634, 21660), (21635, 21638), (21636, 21661)],
   21637, 21662, 18749, 18749, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(7523, .ref 7553), (7524, .ref 7552), (7525, .ref 7528), (7526, .ref 7536), (7527, .ref 7541), (7528, .ref 7546), (7529, .ref 7551), (7530, .ref 7525), (7531, .ref 7526), (7532, .ref 7527), (7533, .ref 7534), (7534, .ref 7535), (7535, .ref 7523), (7536, .ref 7530), (7537, .ref 7531), (7538, .ref 7532), (7539, .ref 7533), (7540, .ref 7529)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa174 : Map :=
  Conv.Map.compact 2811819 2812974 7523 PRE_first_tail_x6_r0_body.pl174 (PRE_first_tail_x6_r0_body.nr174.map NumV.ref) PRE_first_tail_x6_r0_body.kd174.big
    PRE_first_tail_x6_r0_body.kd174.region PRE_first_tail_x6_r0_body.kd174.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws174 : List Nat := [3961, 3962, 3963, 3964, 3965, 3966, 3967, 3968, 3969, 3970, 3971, 3972, 3973, 3974, 3975, 3976, 3977, 3978]
noncomputable def PRE_first_tail_x6_r0_body.crs174 : List SymE := PRE_first_tail_x6_r0_body.nr174.map fun r => (nth? PRE_first_tail_x6_r0_body.S1685.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta174 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws174 PRE_first_tail_x6_r0_body.crs174
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB174 : List Nat := [2665, 2672744, 2673467, 2810993, 2811538, 2811794]

kernel_rfl PRE_first_tail_x6_r0_body.ctab174 : PRE_first_tail_x6_r0_body.S1686.tab = PRE_first_tail_x6_r0_body.S1684.tab ++ PRE_first_tail_x6_r0_body.cws174.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace174 : PRE_first_tail_x6_r0_body.s1686.trace = PRE_first_tail_x6_r0_body.s1684.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext174 : PRE_first_tail_x6_r0_body.s1686.next = 2811825
kernel_rfl PRE_first_tail_x6_r0_body.ccounters174 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1686.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1686.ffi).mlx.nnext) = (21637, 18749)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue174 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1685.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1686.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa174.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp174 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1686.ffi).mlx.tokens.all (bSN 7541) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean174 : Conv.cleanListB 21637 131072 (fun r => Nat.ble 86548 r) PRE_first_tail_x6_r0_body.s1686
    (PRE_first_tail_x6_r0_body.wrB174 ++ (List.range 6).map (2811819 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs174 : bigsOutB 21637 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1686.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK174
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl174`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl174 : List Nat := [2665, 2672744, 2673467, 2810993, 2811538, 2811794, 2811819, 2811820, 2811821, 2811822, 2811823, 2811824]
def PRE_first_tail_x6_r0_body.clo174 : List Nat := [21614, 21627, 21633, 21634, 21635, 21636]
def PRE_first_tail_x6_r0_body.cln174 : List Nat := [18722, 18723, 18724, 18725, 18726, 18727, 18728, 18729, 18730, 18731, 18732, 18733, 18734, 18735, 18736, 18737, 18738, 18739, 18740, 18741, 18742, 18743, 18744, 18745, 18746, 18747, 18748]
def PRE_first_tail_x6_r0_body.cli174 : List Nat := [18722, 18723, 18724, 18725, 18726, 18727, 18728, 18729, 18730, 18731, 18732, 18733, 18734, 18735, 18736, 18737, 18738, 18739, 18740, 18741, 18742, 18743, 18744, 18745, 18746, 18747, 18748]
kernel_rfl PRE_first_tail_x6_r0_body.cheap174 : PRE_first_tail_x6_r0_body.s1686.heap = Stage.setAll PRE_first_tail_x6_r0_body.s1684.heap (PRE_first_tail_x6_r0_body.cl174.filterMap fun a => (PRE_first_tail_x6_r0_body.s1686.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe174 : Nat.ble PRE_first_tail_x6_r0_body.s1684.next PRE_first_tail_x6_r0_body.s1686.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP174 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s1684 PRE_first_tail_x6_r0_body.s1686 PRE_first_tail_x6_r0_body.cl174 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp174 : Conv.suppListB PRE_first_tail_x6_r0_body.s1686 7541 PRE_first_tail_x6_r0_body.cl174 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound174 : Conv.boundListB PRE_first_tail_x6_r0_body.s1686 PRE_first_tail_x6_r0_body.cl174 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK174 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1686.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln174.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1686.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK174 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1686.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo174.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1686.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK174 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1686.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli174.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1686.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst174 : Conv.sstListB 7541 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1686.ffi).mlx PRE_first_tail_x6_r0_body.cln174 PRE_first_tail_x6_r0_body.clo174 PRE_first_tail_x6_r0_body.cli174 = true

end Host.Load.Run.Tpl
end

section -- SiteCl174
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA174 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1686.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo174.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1686.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd174 : (PRE_first_tail_x6_r0_body.clo174 ++ PRE_first_tail_x6_r0_body.cln174 ++ PRE_first_tail_x6_r0_body.cli174).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle174 : Conv.Cnt.leB (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt) (⟨21637, 18749, 2811825, 7541⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck174 : Conv.ncleanListB (⟨21637, 18749, 2811825, 7541⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1686.ffi).mlx PRE_first_tail_x6_r0_body.clo174 PRE_first_tail_x6_r0_body.cln174 PRE_first_tail_x6_r0_body.cli174 = true
theorem PRE_first_tail_x6_r0_body.cncl174 (h : Conv.NClean (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx) : Conv.NClean (⟨21637, 18749, 2811825, 7541⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1686.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle174 PRE_first_tail_x6_r0_body.ckA174 PRE_first_tail_x6_r0_body.cobjsK174 PRE_first_tail_x6_r0_body.cnodesK174 PRE_first_tail_x6_r0_body.citemsK174 PRE_first_tail_x6_r0_body.cbd174 PRE_first_tail_x6_r0_body.cck174

end Host.Load.Run.Tpl
end

section -- SiteS174
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 174 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc174 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P174 : LoadP := PRE_first_tail_x6_r0_body.Pc174.raise 18749
kernel_rfl PRE_first_tail_x6_r0_body.craise174 : Nat.ble PRE_first_tail_x6_r0_body.Pc174.N0 18749 = true
theorem PRE_first_tail_x6_r0_body.raised174 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc174 PRE_first_tail_x6_r0_body.P174 :=
  .inr ⟨18749, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise174, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_174 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1686.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_174 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1685.ffi)
def PRE_first_tail_x6_r0_body.khinv174 : PTrie Nat := Stage.setAll PTrie.nil [(21660, 21634), (21638, 21635), (21661, 21636)]
def PRE_first_tail_x6_r0_body.kninv174 : PTrie Nat := Stage.setAll PTrie.nil [(18722, 18722), (18723, 18723), (18724, 18724), (18725, 18725), (18726, 18726), (18727, 18727), (18728, 18728), (18729, 18729), (18730, 18730), (18731, 18731), (18732, 18732), (18733, 18733), (18734, 18734), (18735, 18735), (18736, 18736), (18737, 18737), (18738, 18738), (18739, 18739), (18740, 18740), (18741, 18741), (18742, 18742), (18743, 18743), (18744, 18744), (18745, 18745), (18746, 18746), (18747, 18747), (18748, 18748)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS174 : List Nat := [21614, 21627, 21633, 21634, 21635, 21636, 21637, 21638, 21639, 21640, 21641, 21642, 21643, 21644, 21645, 21646, 21647, 21648, 21649, 21650, 21651, 21652, 21653, 21654, 21655, 21656, 21657, 21658, 21659, 21660, 21661]
def PRE_first_tail_x6_r0_body.cnS174 : List Nat := List.range' 18722 27
def PRE_first_tail_x6_r0_body.ciS174 : List Nat := [] ++ List.range' 18722 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh0174 : PRE_first_tail_x6_r0_body.kd174.nh0 = PRE_first_tail_x6_r0_body.cx0_174.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh1174 : PRE_first_tail_x6_r0_body.kd174.nh1 = PRE_first_tail_x6_r0_body.cx1_174.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn0174 : PRE_first_tail_x6_r0_body.kd174.nn0 = PRE_first_tail_x6_r0_body.cx0_174.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn1174 : PRE_first_tail_x6_r0_body.kd174.nn1 = PRE_first_tail_x6_r0_body.cx1_174.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo174 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P174.lo && Nat.ble PRE_first_tail_x6_r0_body.P174.lo PRE_first_tail_x6_r0_body.cx0_174.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P174.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P174.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt174 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_174.mlx.next PRE_first_tail_x6_r0_body.cx1_174.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_174.mlx.nnext PRE_first_tail_x6_r0_body.cx1_174.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband174 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P174.NL && Nat.ble PRE_first_tail_x6_r0_body.P174.NL PRE_first_tail_x6_r0_body.P174.N0 && Nat.ble PRE_first_tail_x6_r0_body.P174.N0 PRE_first_tail_x6_r0_body.cx0_174.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow174 : PRE_first_tail_x6_r0_body.kd174.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren174 : checkRenG PRE_first_tail_x6_r0_body.kd174.hnd PRE_first_tail_x6_r0_body.khinv174 (phB PRE_first_tail_x6_r0_body.cx0_174.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband174 : PRE_first_tail_x6_r0_body.kd174.checkBand PRE_first_tail_x6_r0_body.P174.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos174 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd174.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren174 : checkRenG PRE_first_tail_x6_r0_body.kd174.node PRE_first_tail_x6_r0_body.kninv174 (pnB PRE_first_tail_x6_r0_body.cx0_174.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow174 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd174.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P174.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd174.nodeF j) PRE_first_tail_x6_r0_body.cx1_174.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a174 : PRE_first_tail_x6_r0_body.cx0_174.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b174 : PRE_first_tail_x6_r0_body.cx0_174.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok1174 : PRE_first_tail_x6_r0_body.cx1_174.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend174 : PRE_first_tail_x6_r0_body.cx1_174.mlx.pending = PRE_first_tail_x6_r0_body.cx0_174.mlx.pending.map PRE_first_tail_x6_r0_body.kappa174.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh174 : PRE_first_tail_x6_r0_body.cx1_174.mlx.errh = PRE_first_tail_x6_r0_body.cx0_174.mlx.errh.map PRE_first_tail_x6_r0_body.kappa174.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles174 : PRE_first_tail_x6_r0_body.cx1_174.mlx.files = PRE_first_tail_x6_r0_body.cx0_174.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch174 : PRE_first_tail_x6_r0_body.cx1_174.mlx.arch = PRE_first_tail_x6_r0_body.cx0_174.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes174 : PRE_first_tail_x6_r0_body.cx1_174.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_174.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired174 : PRE_first_tail_x6_r0_body.cx1_174.mlx.wired = PRE_first_tail_x6_r0_body.cx0_174.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost174 : PRE_first_tail_x6_r0_body.cx1_174.host = PRE_first_tail_x6_r0_body.cx0_174.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd174`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn0174 : PRE_first_tail_x6_r0_body.kd174.n0 = 2811825
kernel_rfl PRE_first_tail_x6_r0_body.ckn1174 : PRE_first_tail_x6_r0_body.kd174.n1 = 2812974
kernel_rfl PRE_first_tail_x6_r0_body.ckheap174 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd174.heap).all (fun x => Nat.ble 2811819 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl174 : (List.range 6).all (fun j => decide (PRE_first_tail_x6_r0_body.kd174.heap.get (2811819 + j) = nth? PRE_first_tail_x6_r0_body.pl174 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja174 : Nat.ble 2811819 2811819 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn174 : Nat.ble 7523 7523 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD174 : Nat.ble 2811819 PRE_first_tail_x6_r0_body.kd174.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn174 : Nat.ble 21634 PRE_first_tail_x6_r0_body.kd174.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn174 : Nat.ble 18722 PRE_first_tail_x6_r0_body.kd174.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb174 : Nat.ble 21634 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap174 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd174.heap).all (Nat.ble (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd174 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd174.hnd).all (Nat.ble (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode174 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd174.node).all (Nat.ble (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix174 : Conv.FixOld (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa174 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja174) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn174) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD174) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn174) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn174) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb174) PRE_first_tail_x6_r0_body.fheap174 PRE_first_tail_x6_r0_body.fhnd174 PRE_first_tail_x6_r0_body.fnode174
kernel_rfl PRE_first_tail_x6_r0_body.fcxn174 : (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn174 : (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle0174 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_174.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_174.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk174 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd174.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A174 : PRE_first_tail_x6_r0_body.cx1_174.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS174.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_174.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O174 : PRE_first_tail_x6_r0_body.cx1_174.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS174.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_174.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N174 : PRE_first_tail_x6_r0_body.cx1_174.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS174.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_174.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I174 : PRE_first_tail_x6_r0_body.cx1_174.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS174.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_174.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd174 : (PRE_first_tail_x6_r0_body.clo174 ++ PRE_first_tail_x6_r0_body.cln174 ++ PRE_first_tail_x6_r0_body.cli174 ++ PRE_first_tail_x6_r0_body.cwS174 ++ PRE_first_tail_x6_r0_body.cnS174 ++ PRE_first_tail_x6_r0_body.ciS174).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW174 : PRE_first_tail_x6_r0_body.cwS174.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo174.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI174 : PRE_first_tail_x6_r0_body.ciS174.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli174.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN174 : PRE_first_tail_x6_r0_body.cnS174.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF174 : PRE_first_tail_x6_r0_body.cln174.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh174 : PRE_first_tail_x6_r0_body.clo174.all (handleOK PRE_first_tail_x6_r0_body.kappa174 PRE_first_tail_x6_r0_body.P174.lo PRE_first_tail_x6_r0_body.cx0_174.mlx PRE_first_tail_x6_r0_body.cx1_174.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo174 : PRE_first_tail_x6_r0_body.clo174.map (fun h => PRE_first_tail_x6_r0_body.cx1_174.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa174.handle h)) = PRE_first_tail_x6_r0_body.clo174.map (fun h => (PRE_first_tail_x6_r0_body.cx0_174.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa174.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok174 : PRE_first_tail_x6_r0_body.clo174.all (objOK PRE_first_tail_x6_r0_body.kappa174 PRE_first_tail_x6_r0_body.P174.NL PRE_first_tail_x6_r0_body.cx0_174.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd174 : PRE_first_tail_x6_r0_body.cln174.all (nodeOKF PRE_first_tail_x6_r0_body.kappa174 PRE_first_tail_x6_r0_body.P174 PRE_first_tail_x6_r0_body.cx0_174.mlx PRE_first_tail_x6_r0_body.cx1_174.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp174 : ((PRE_first_tail_x6_r0_body.cln174.filter (fullB PRE_first_tail_x6_r0_body.P174))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_174.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa174.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln174.filter (fullB PRE_first_tail_x6_r0_body.P174))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_174.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa174.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI174 : incrB PRE_first_tail_x6_r0_body.kd174.nodeF (List.range' 18722 27) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK174 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd174.node).all (fun k => Nat.ble 18722 k && Nat.blt k 18749) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL174 : (PRE_first_tail_x6_r0_body.cln174.filter (Nat.ble PRE_first_tail_x6_r0_body.P174.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd174.nodeF i) && (Nat.blt i 18749 || Nat.ble PRE_first_tail_x6_r0_body.kd174.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord174 : (PRE_first_tail_x6_r0_body.cln174.filter (Nat.ble PRE_first_tail_x6_r0_body.P174.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd174.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd174.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd174.nodeF j) (PRE_first_tail_x6_r0_body.kd174.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow174 PRE_first_tail_x6_r0_body.cnn1174 PRE_first_tail_x6_r0_body.fnordI174 PRE_first_tail_x6_r0_body.fnordK174 PRE_first_tail_x6_r0_body.fnordL174
kernel_rfl PRE_first_tail_x6_r0_body.fi174 : PRE_first_tail_x6_r0_body.cli174.all (pnB PRE_first_tail_x6_r0_body.cx0_174.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii174 : PRE_first_tail_x6_r0_body.cli174.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_174.mlx.items.get (PRE_first_tail_x6_r0_body.kappa174.node k) = (PRE_first_tail_x6_r0_body.cx0_174.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa174.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot174 (clean : Conv.NClean (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P174.NL) (cl : SSt (· < 7541) PRE_first_tail_x6_r0_body.cx0_174.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P174 7541 PRE_first_tail_x6_r0_body.kappa174 PRE_first_tail_x6_r0_body.kd174 PRE_first_tail_x6_r0_body.khinv174 PRE_first_tail_x6_r0_body.kninv174 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx PRE_first_tail_x6_r0_body.cx0_174.mlx PRE_first_tail_x6_r0_body.cx1_174.mlx (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo174 PRE_first_tail_x6_r0_body.cln174 PRE_first_tail_x6_r0_body.cli174 PRE_first_tail_x6_r0_body.cwS174 PRE_first_tail_x6_r0_body.cnS174 PRE_first_tail_x6_r0_body.ciS174 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh0174, PRE_first_tail_x6_r0_body.cnh1174, PRE_first_tail_x6_r0_body.cnn0174, PRE_first_tail_x6_r0_body.cnn1174, PRE_first_tail_x6_r0_body.cplo174, PRE_first_tail_x6_r0_body.ccnt174, PRE_first_tail_x6_r0_body.cnband174, PRE_first_tail_x6_r0_body.chbelow174, PRE_first_tail_x6_r0_body.chren174, PRE_first_tail_x6_r0_body.cband174, PRE_first_tail_x6_r0_body.cnh1pos174, PRE_first_tail_x6_r0_body.cnren174, PRE_first_tail_x6_r0_body.cnlow174, PRE_first_tail_x6_r0_body.cabs0a174, PRE_first_tail_x6_r0_body.cabs0b174, PRE_first_tail_x6_r0_body.ctok1174, PRE_first_tail_x6_r0_body.cpend174, PRE_first_tail_x6_r0_body.cerrh174, PRE_first_tail_x6_r0_body.cfiles174, PRE_first_tail_x6_r0_body.carch174, PRE_first_tail_x6_r0_body.csizes174, PRE_first_tail_x6_r0_body.cwired174, PRE_first_tail_x6_r0_body.cfix174, clean, PRE_first_tail_x6_r0_body.fcxn174, PRE_first_tail_x6_r0_body.fcnn174, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle0174, PRE_first_tail_x6_r0_body.fnk174, PRE_first_tail_x6_r0_body.ckA174, PRE_first_tail_x6_r0_body.cobjsK174, PRE_first_tail_x6_r0_body.cnodesK174, PRE_first_tail_x6_r0_body.citemsK174, PRE_first_tail_x6_r0_body.f1A174, PRE_first_tail_x6_r0_body.f1O174, PRE_first_tail_x6_r0_body.f1N174, PRE_first_tail_x6_r0_body.f1I174, PRE_first_tail_x6_r0_body.fbd174, PRE_first_tail_x6_r0_body.fincW174, PRE_first_tail_x6_r0_body.fincI174, PRE_first_tail_x6_r0_body.fincN174, PRE_first_tail_x6_r0_body.flnF174, PRE_first_tail_x6_r0_body.fh174, PRE_first_tail_x6_r0_body.fo174, PRE_first_tail_x6_r0_body.fok174, PRE_first_tail_x6_r0_body.fnd174, PRE_first_tail_x6_r0_body.fp174, PRE_first_tail_x6_r0_body.fnord174, PRE_first_tail_x6_r0_body.fi174, PRE_first_tail_x6_r0_body.fii174⟩
theorem PRE_first_tail_x6_r0_body.cnshift174 (clean : Conv.NClean (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P174.NL) (cl : SSt (· < 7541) PRE_first_tail_x6_r0_body.cx0_174.mlx) : NShift PRE_first_tail_x6_r0_body.P174 7541 PRE_first_tail_x6_r0_body.kappa174 PRE_first_tail_x6_r0_body.cx0_174 PRE_first_tail_x6_r0_body.cx1_174 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot174 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost174 (compact_a_eq PRE_first_tail_x6_r0_body.ckn0174 PRE_first_tail_x6_r0_body.ckn1174 PRE_first_tail_x6_r0_body.ckheap174 PRE_first_tail_x6_r0_body.ckpl174)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_174 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1684.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_174 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1684.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_174 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1684.ffi) = some PRE_first_tail_x6_r0_body.fxC_174
kernel_rfl PRE_first_tail_x6_r0_body.okrC_174 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1684.ffi) = some PRE_first_tail_x6_r0_body.krC_174
noncomputable def PRE_first_tail_x6_r0_body.fx0_174 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1686.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_174 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1686.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_174 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1686.ffi) = some PRE_first_tail_x6_r0_body.fx0_174
kernel_rfl PRE_first_tail_x6_r0_body.okr0_174 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1686.ffi) = some PRE_first_tail_x6_r0_body.kr0_174
noncomputable def PRE_first_tail_x6_r0_body.fx1_174 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1685.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_174 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1685.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_174 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1685.ffi) = some PRE_first_tail_x6_r0_body.fx1_174
kernel_rfl PRE_first_tail_x6_r0_body.okr1_174 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1685.ffi) = some PRE_first_tail_x6_r0_body.kr1_174
kernel_rfl PRE_first_tail_x6_r0_body.ff0174 : PRE_first_tail_x6_r0_body.fx0_174 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_174 (PRE_first_tail_x6_r0_body.clo174.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_174.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff1174 : PRE_first_tail_x6_r0_body.fx1_174 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_174 (PRE_first_tail_x6_r0_body.cwS174.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_174.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck174 : freedLB PRE_first_tail_x6_r0_body.kappa174 PRE_first_tail_x6_r0_body.cx0_174.mlx PRE_first_tail_x6_r0_body.fx0_174 PRE_first_tail_x6_r0_body.fx1_174 PRE_first_tail_x6_r0_body.clo174 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf0174 : PRE_first_tail_x6_r0_body.kr0_174.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_174.flags (PRE_first_tail_x6_r0_body.clo174.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_174.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt0174 : PRE_first_tail_x6_r0_body.kr0_174.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_174.targs (PRE_first_tail_x6_r0_body.clo174.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_174.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf1174 : PRE_first_tail_x6_r0_body.kr1_174.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_174.flags (PRE_first_tail_x6_r0_body.cwS174.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_174.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt1174 : PRE_first_tail_x6_r0_body.kr1_174.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_174.targs (PRE_first_tail_x6_r0_body.cwS174.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_174.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck174 : krecLB PRE_first_tail_x6_r0_body.kappa174 7541 PRE_first_tail_x6_r0_body.cx0_174.mlx PRE_first_tail_x6_r0_body.kr0_174 PRE_first_tail_x6_r0_body.kr1_174 PRE_first_tail_x6_r0_body.clo174 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn174 : Nat.ble 7523 7541 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge174 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1685.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1686.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR174 : pendRegB PRE_first_tail_x6_r0_body.kappa174 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1686.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe174 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1686.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1685.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift174 (clean : Conv.NClean (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P174.NL) (cl : SSt (· < 7541) PRE_first_tail_x6_r0_body.cx0_174.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_174.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_174.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_174.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1684.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_174.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P174 7541 PRE_first_tail_x6_r0_body.kappa174 PRE_first_tail_x6_r0_body.s1686.ffi PRE_first_tail_x6_r0_body.s1685.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift174 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue174, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp174 t ht),
    PRE_first_tail_x6_r0_body.cbridge174,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1686.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1685.ffi) (PRE_first_tail_x6_r0_body.cfoot174 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_174 PRE_first_tail_x6_r0_body.ofx1_174 hobjC PRE_first_tail_x6_r0_body.ff0174 PRE_first_tail_x6_r0_body.ff1174 PRE_first_tail_x6_r0_body.ffck174,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1686.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1685.ffi) (PRE_first_tail_x6_r0_body.cfoot174 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_174 PRE_first_tail_x6_r0_body.okr1_174 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn174) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf0174 PRE_first_tail_x6_r0_body.fkt0174 PRE_first_tail_x6_r0_body.fkf1174 PRE_first_tail_x6_r0_body.fkt1174 PRE_first_tail_x6_r0_body.fkck174,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh0174 PRE_first_tail_x6_r0_body.cnh1174 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe174) PRE_first_tail_x6_r0_body.cpendR174⟩

end Host.Load.Run.Tpl
end

section -- st174/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st174 0
host_stream_state PRE_first_tail_x6_r0_body.st174 1
host_stream_state PRE_first_tail_x6_r0_body.st174 2
host_stream_state PRE_first_tail_x6_r0_body.st174 3
host_stream_state PRE_first_tail_x6_r0_body.st174 4
host_stream_state PRE_first_tail_x6_r0_body.st174 5
end Host.Load.Run.Tpl
end

section -- Site174
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 174 of chain `PRE_first_tail_x6_r0_body`: `ssmW__g174__g175` (`recurWindow`), the call state `PRE_first_tail_x6_r0_body.s1684`, the merged state `PRE_first_tail_x6_r0_body.s1685`,
the site template `PRE_first_tail_x6_r0_body.st174` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s1686`: the merge.
The footprint's facts are in `SiteF174`, the compaction's in `SiteC174`, `SiteK174`, `SiteNa174`, `SiteNb174`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso174 : PRE_first_tail_x6_r0_body.st174.s0 = { PRE_first_tail_x6_r0_body.s1684 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs174 : List Frame := PRE_first_tail_x6_r0_body.s1684.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_174 : PRE_first_tail_x6_r0_body.S1684.tab.length = 7523
kernel_rfl PRE_first_tail_x6_r0_body.tab0_174 : PRE_first_tail_x6_r0_body.st174.S0.tab = PRE_first_tail_x6_r0_body.S1684.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws174 : List Nat := [3930, 3931, 3932, 3933, 3934, 3935, 3936, 3937, 3938, 3939, 3940, 3941, 3942, 3943, 3944, 3945, 3946, 3947, 3948, 3949, 3950, 3951, 3952, 3953, 3954, 3955, 3956, 3957, 3958, 3959, 3960]
kernel_rfl PRE_first_tail_x6_r0_body.fresh174 : (PRE_first_tail_x6_r0_body.S1684.tab.all fun e => PRE_first_tail_x6_r0_body.ws174.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S1684.oracle.all fun q => PRE_first_tail_x6_r0_body.ws174.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab174 : PRE_first_tail_x6_r0_body.S1685.tab = PRE_first_tail_x6_r0_body.S1684.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws174
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen174 : PRE_first_tail_x6_r0_body.st174.S5.tab.length - PRE_first_tail_x6_r0_body.st174.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged174`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap174 : PRE_first_tail_x6_r0_body.s1685.heap = PRE_first_tail_x6_r0_body.st174.s5.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext174 : PRE_first_tail_x6_r0_body.s1685.next = PRE_first_tail_x6_r0_body.st174.s5.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl174 : PRE_first_tail_x6_r0_body.s1685.ctl = PRE_first_tail_x6_r0_body.st174.s5.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack174 : PRE_first_tail_x6_r0_body.s1685.stack = PRE_first_tail_x6_r0_body.st174.s5.stack ++ PRE_first_tail_x6_r0_body.s1684.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs174 : PRE_first_tail_x6_r0_body.s1685.jobs = PRE_first_tail_x6_r0_body.st174.s5.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi174 : PRE_first_tail_x6_r0_body.s1685.ffi = PRE_first_tail_x6_r0_body.st174.s5.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace174 : PRE_first_tail_x6_r0_body.s1685.trace = PRE_first_tail_x6_r0_body.st174.s5.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores174 : PRE_first_tail_x6_r0_body.s1685.stores = PRE_first_tail_x6_r0_body.st174.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD174
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 174 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived174 : PRE_first_tail_x6_r0_body.nr174.map (fun r => nth? PRE_first_tail_x6_r0_body.st174.S5.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.un .int32 (SymE.un .int32 (SymE.var 10))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))]
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo174 : PRE_first_tail_x6_r0_body.nr174.all (Nat.ble 7523) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj174 : PRE_first_tail_x6_r0_body.cws174.all (fun c => !PRE_first_tail_x6_r0_body.ws174.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ174 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws174 PRE_first_tail_x6_r0_body.crs174 PRE_first_tail_x6_r0_body.ws174

end Host.Load.Run.Tpl
end

section -- st174/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st174`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st174.wrR : List (Nat × Nat) := [(2672744, 2672745), (2810993, 2810994), (2811538, 2811539), (2811794, 2811795)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st174.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st174.s5.heap PRE_first_tail_x6_r0_body.st174.wrR ++ freshOf PRE_first_tail_x6_r0_body.st174.s5.heap PRE_first_tail_x6_r0_body.st174.s0.next PRE_first_tail_x6_r0_body.st174.s5.next
noncomputable def PRE_first_tail_x6_r0_body.st174.wr : List Nat := PRE_first_tail_x6_r0_body.st174.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st174.heapFoot : PRE_first_tail_x6_r0_body.st174.s5.heap = setAll PRE_first_tail_x6_r0_body.st174.s0.heap PRE_first_tail_x6_r0_body.st174.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st174.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st174.s0.next PRE_first_tail_x6_r0_body.st174.s5.next = true
theorem PRE_first_tail_x6_r0_body.st174.grows : PRE_first_tail_x6_r0_body.st174.s0.next ≤ PRE_first_tail_x6_r0_body.st174.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st174.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st174.wh : List Nat := [21614, 21627, 21633, 21634, 21635, 21636, 21637, 21638, 21639, 21640, 21641, 21642, 21643, 21644, 21645, 21646, 21647, 21648, 21649, 21650, 21651, 21652, 21653, 21654, 21655, 21656, 21657, 21658, 21659, 21660, 21661]
def PRE_first_tail_x6_r0_body.st174.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st174.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st174.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st174.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st174.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st174.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st174.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st174.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st174.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st174.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st174.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st174.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st174.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st174.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st174.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st174.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st174.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st174.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st174.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st174.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st174.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st174.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st174.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st174.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st174.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st174.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st174.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st174.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st174.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st174.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF174
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 174 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB174 : nodupT PRE_first_tail_x6_r0_body.st174.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup174 : PRE_first_tail_x6_r0_body.st174.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB174).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB174 : PRE_first_tail_x6_r0_body.st174.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound174 : ∀ b ∈ PRE_first_tail_x6_r0_body.st174.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB174 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr174 := PRE_first_tail_x6_r0_body.st174.s5.trace.take 120
kernel_rfl PRE_first_tail_x6_r0_body.traceEq174 : PRE_first_tail_x6_r0_body.st174.s5.trace = PRE_first_tail_x6_r0_body.trFr174 ++ PRE_first_tail_x6_r0_body.st174.s0.trace
theorem PRE_first_tail_x6_r0_body.trace174 : ∃ fr, PRE_first_tail_x6_r0_body.st174.s5.trace = fr ++ PRE_first_tail_x6_r0_body.st174.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq174⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide174 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB174 : (PRE_first_tail_x6_r0_body.wide174.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st174.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix174 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide174, WFix Map.id (Present PRE_first_tail_x6_r0_body.st174.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB174 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL174
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 174 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s1685`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO174 : PRE_first_tail_x6_r0_body.st174.S0.oracle = PRE_first_tail_x6_r0_body.st174.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B174 : PRE_first_tail_x6_r0_body.st174.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st174.s0.next || (PRE_first_tail_x6_r0_body.st174.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot174 : Conv.StageFoot PRE_first_tail_x6_r0_body.st174.wr PRE_first_tail_x6_r0_body.st174.s0 PRE_first_tail_x6_r0_body.st174.s5 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st174.heapFoot PRE_first_tail_x6_r0_body.wrNodup174 PRE_first_tail_x6_r0_body.wrBound174 PRE_first_tail_x6_r0_body.wr0B174 PRE_first_tail_x6_r0_body.st174.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged174 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st174.F.S → PRE_first_tail_x6_r0_body.st174.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st174.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st174.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs174 PRE_first_tail_x6_r0_body.st174.wr PRE_first_tail_x6_r0_body.s1684 PRE_first_tail_x6_r0_body.st174.s5 PRE_first_tail_x6_r0_body.st174.s0
      PRE_first_tail_x6_r0_body.st174.s5.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st174.F FR W stk M ν K PRE_first_tail_x6_r0_body.s1685 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso174 PRE_first_tail_x6_r0_body.stFoot174 PRE_first_tail_x6_r0_body.wrNodup174 PRE_first_tail_x6_r0_body.wrBound174 PRE_first_tail_x6_r0_body.trace174 PRE_first_tail_x6_r0_body.mheap174
    PRE_first_tail_x6_r0_body.mnext174 PRE_first_tail_x6_r0_body.mctl174 PRE_first_tail_x6_r0_body.mstack174 PRE_first_tail_x6_r0_body.mjobs174 PRE_first_tail_x6_r0_body.mffi174 PRE_first_tail_x6_r0_body.mtrace174 PRE_first_tail_x6_r0_body.mstores174 h

def PRE_first_tail_x6_r0_body.arrEl174_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE174_2665 : arrOf PRE_first_tail_x6_r0_body.s1685 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl174_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA174_2665 : isArrB PRE_first_tail_x6_r0_body.s1685 2665 = true
theorem PRE_first_tail_x6_r0_body.arr174_2665 : ∃ o, PRE_first_tail_x6_r0_body.s1685.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl174_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE174_2665 PRE_first_tail_x6_r0_body.arrA174_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN174_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl174_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR174_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl174_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN174_2665

def PRE_first_tail_x6_r0_body.arrEl174_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE174_2673467 : arrOf PRE_first_tail_x6_r0_body.s1685 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl174_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA174_2673467 : isArrB PRE_first_tail_x6_r0_body.s1685 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr174_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s1685.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl174_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE174_2673467 PRE_first_tail_x6_r0_body.arrA174_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN174_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl174_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR174_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl174_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN174_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k174 : isArrB PRE_first_tail_x6_r0_body.s1685 4910 = false
theorem PRE_first_tail_x6_r0_body.keep174 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s1685 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k174 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr174_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl174_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ174
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 174 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s1684`, the merged
state `PRE_first_tail_x6_r0_body.s1685`, the canonical state `PRE_first_tail_x6_r0_body.s1686`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl174 : PRE_first_tail_x6_r0_body.pl174.all (Nat.ble PRE_first_tail_x6_r0_body.s1684.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd174 : nodupT PRE_first_tail_x6_r0_body.pl174 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn1174 : Nat.ble PRE_first_tail_x6_r0_body.s1684.next 2812974 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst174 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s1684.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn174 : PRE_first_tail_x6_r0_body.s1686.next = PRE_first_tail_x6_r0_body.s1684.next + PRE_first_tail_x6_r0_body.pl174.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn174 : PRE_first_tail_x6_r0_body.s1685.next = 2812974
kernel_rfl PRE_first_tail_x6_r0_body.zgrow174 : Nat.ble PRE_first_tail_x6_r0_body.s1686.next PRE_first_tail_x6_r0_body.s1685.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh174 : PRE_first_tail_x6_r0_body.S1684.tab.all (fun e => PRE_first_tail_x6_r0_body.cws174.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd174 : nodupT PRE_first_tail_x6_r0_body.cws174 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi174 : PRE_first_tail_x6_r0_body.nr174.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S1685.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt174 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s1684.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg174_2665 : PRE_first_tail_x6_r0_body.s1686.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1686 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk174_2665 : (objOf PRE_first_tail_x6_r0_body.s1686 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm174_2665 : PRE_first_tail_x6_r0_body.s1685.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa174.obj (objOf PRE_first_tail_x6_r0_body.s1686 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s1685 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg174_2673467 : PRE_first_tail_x6_r0_body.s1686.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1686 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk174_2673467 : (objOf PRE_first_tail_x6_r0_body.s1686 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm174_2673467 : PRE_first_tail_x6_r0_body.s1685.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa174.obj (objOf PRE_first_tail_x6_r0_body.s1686 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s1685 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw174_4910 : (PRE_first_tail_x6_r0_body.s1686.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw174_2673472 : (PRE_first_tail_x6_r0_body.s1686.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw174_2673473 : (PRE_first_tail_x6_r0_body.s1686.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd174 : PRE_first_tail_x6_r0_body.cl174.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr174 : PRE_first_tail_x6_r0_body.st174.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s1684.next || PRE_first_tail_x6_r0_body.cl174.contains b) = true
def PRE_first_tail_x6_r0_body.zl174 : List Nat := PRE_first_tail_x6_r0_body.cl174.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE174 : PRE_first_tail_x6_r0_body.zl174.map (fun a => PRE_first_tail_x6_r0_body.s1685.heap.get (PRE_first_tail_x6_r0_body.kappa174.a a)) = PRE_first_tail_x6_r0_body.zl174.map (fun a => (PRE_first_tail_x6_r0_body.s1686.heap.get a).map PRE_first_tail_x6_r0_body.kappa174.hobj)
theorem PRE_first_tail_x6_r0_body.zimg174 : HeapImg PRE_first_tail_x6_r0_body.kappa174 PRE_first_tail_x6_r0_body.s1686 PRE_first_tail_x6_r0_body.s1685 PRE_first_tail_x6_r0_body.zl174 := PRE_first_tail_x6_r0_body.zimgE174
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl174 : PRE_first_tail_x6_r0_body.s1685.ctl = PRE_first_tail_x6_r0_body.kappa174.ctl PRE_first_tail_x6_r0_body.s1686.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack174 : PRE_first_tail_x6_r0_body.s1685.stack = PRE_first_tail_x6_r0_body.s1686.stack.map PRE_first_tail_x6_r0_body.kappa174.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs174 : PRE_first_tail_x6_r0_body.s1685.jobs = PRE_first_tail_x6_r0_body.s1686.jobs.map PRE_first_tail_x6_r0_body.kappa174.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores174 : PRE_first_tail_x6_r0_body.s1685.stores = PRE_first_tail_x6_r0_body.kappa174.stores PRE_first_tail_x6_r0_body.s1686.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots174 : checkRootsSupp PRE_first_tail_x6_r0_body.s1686 7541 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC174 : PRE_first_tail_x6_r0_body.S1684.tab.length + PRE_first_tail_x6_r0_body.cws174.length = 7541
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap174 : PRE_first_tail_x6_r0_body.kappa174 = Conv.Map.compact PRE_first_tail_x6_r0_body.s1684.next 2812974 PRE_first_tail_x6_r0_body.S1684.tab.length PRE_first_tail_x6_r0_body.pl174 (PRE_first_tail_x6_r0_body.nr174.map NumV.ref) PRE_first_tail_x6_r0_body.kd174.big
  PRE_first_tail_x6_r0_body.kd174.region PRE_first_tail_x6_r0_body.kd174.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin174 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1686.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc174 : Conv.jcleanListB (⟨21637, 18749, 2811825, 7541⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1686 PRE_first_tail_x6_r0_body.cl174 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB174 : noBigRootsP (fun i => !Conv.oldBigB (⟨21637, 18749, 2811825, 7541⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s1686.trace PRE_first_tail_x6_r0_body.s1686 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm174 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 18722 = true
theorem PRE_first_tail_x6_r0_body.cjcl174 (h : Conv.JClean (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1684) : Conv.JClean (⟨21637, 18749, 2811825, 7541⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1686 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle174)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap174 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd174 a ha)) PRE_first_tail_x6_r0_body.zjc174

end Host.Load.Run.Tpl
end

section -- st174/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st174.bodyLast from PRE_first_tail_x6_r0_body.st174.s4 to PRE_first_tail_x6_r0_body.st174.s5 :
  interpS (step PRE_first_tail_x6_r0_body.st174.F PRE_first_tail_x6_r0_body.st174.s4).run PRE_first_tail_x6_r0_body.st174.S4 = some (PRE_first_tail_x6_r0_body.st174.s5, PRE_first_tail_x6_r0_body.st174.S5)
kernel_rfl PRE_first_tail_x6_r0_body.st174.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st174.s4.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st174.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st174.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st174/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st174.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st174.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st174.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st174.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st174.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st174.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st174.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st174.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st174.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st174.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st174.s0 PRE_first_tail_x6_r0_body.st174.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st174.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st174.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st174.s4 PRE_first_tail_x6_r0_body.st174.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st174/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st174.bodyK0F from PRE_first_tail_x6_r0_body.st174.s0 to PRE_first_tail_x6_r0_body.st174.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st174.F (PRE_first_tail_x6_r0_body.st174.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st174.ks 0).getD 0) PRE_first_tail_x6_r0_body.st174.s0 PRE_first_tail_x6_r0_body.st174.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st174.s1, PRE_first_tail_x6_r0_body.st174.S1)
theorem PRE_first_tail_x6_r0_body.st174.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st174.F (PRE_first_tail_x6_r0_body.st174.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st174.ks 0).getD 0) PRE_first_tail_x6_r0_body.st174.s0 PRE_first_tail_x6_r0_body.st174.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st174.s1, PRE_first_tail_x6_r0_body.st174.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st174.bodyOkLN_ok PRE_first_tail_x6_r0_body.st174.bodyK0F
end Host.Load.Run.Tpl
end

section -- st174/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st174.bodyK1F from PRE_first_tail_x6_r0_body.st174.s1 to PRE_first_tail_x6_r0_body.st174.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st174.F (PRE_first_tail_x6_r0_body.st174.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st174.ks 1).getD 0) PRE_first_tail_x6_r0_body.st174.s1 PRE_first_tail_x6_r0_body.st174.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st174.s2, PRE_first_tail_x6_r0_body.st174.S2)
theorem PRE_first_tail_x6_r0_body.st174.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st174.F (PRE_first_tail_x6_r0_body.st174.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st174.ks 1).getD 0) PRE_first_tail_x6_r0_body.st174.s1 PRE_first_tail_x6_r0_body.st174.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st174.s2, PRE_first_tail_x6_r0_body.st174.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st174.bodyOkLN_ok PRE_first_tail_x6_r0_body.st174.bodyK1F
end Host.Load.Run.Tpl
end

section -- st174/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st174.bodyK2F from PRE_first_tail_x6_r0_body.st174.s2 to PRE_first_tail_x6_r0_body.st174.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st174.F (PRE_first_tail_x6_r0_body.st174.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st174.ks 2).getD 0) PRE_first_tail_x6_r0_body.st174.s2 PRE_first_tail_x6_r0_body.st174.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st174.s3, PRE_first_tail_x6_r0_body.st174.S3)
theorem PRE_first_tail_x6_r0_body.st174.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st174.F (PRE_first_tail_x6_r0_body.st174.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st174.ks 2).getD 0) PRE_first_tail_x6_r0_body.st174.s2 PRE_first_tail_x6_r0_body.st174.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st174.s3, PRE_first_tail_x6_r0_body.st174.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st174.bodyOkLN_ok PRE_first_tail_x6_r0_body.st174.bodyK2F
end Host.Load.Run.Tpl
end

section -- st174/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st174.bodyK3F from PRE_first_tail_x6_r0_body.st174.s3 to PRE_first_tail_x6_r0_body.st174.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st174.F (PRE_first_tail_x6_r0_body.st174.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st174.ks 3).getD 0) PRE_first_tail_x6_r0_body.st174.s3 PRE_first_tail_x6_r0_body.st174.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st174.s4, PRE_first_tail_x6_r0_body.st174.S4)
theorem PRE_first_tail_x6_r0_body.st174.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st174.F (PRE_first_tail_x6_r0_body.st174.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st174.ks 3).getD 0) PRE_first_tail_x6_r0_body.st174.s3 PRE_first_tail_x6_r0_body.st174.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st174.s4, PRE_first_tail_x6_r0_body.st174.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st174.bodyOkLN_ok PRE_first_tail_x6_r0_body.st174.bodyK3F
end Host.Load.Run.Tpl
end

section -- st174/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st174.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st174.F (PRE_first_tail_x6_r0_body.st174.bodyOkL bytes rows) 11334 PRE_first_tail_x6_r0_body.st174.s0 PRE_first_tail_x6_r0_body.st174.S0 = some (PRE_first_tail_x6_r0_body.st174.s4, PRE_first_tail_x6_r0_body.st174.S4) :=
  runOk_trans PRE_first_tail_x6_r0_body.st174.F (PRE_first_tail_x6_r0_body.st174.bodyOkL bytes rows) ((((nth? PRE_first_tail_x6_r0_body.st174.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st174.ks 1).getD 0)) + ((nth? PRE_first_tail_x6_r0_body.st174.ks 2).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st174.ks 3).getD 0) PRE_first_tail_x6_r0_body.st174.s0 PRE_first_tail_x6_r0_body.st174.s3 PRE_first_tail_x6_r0_body.st174.s4 PRE_first_tail_x6_r0_body.st174.S0 PRE_first_tail_x6_r0_body.st174.S3 PRE_first_tail_x6_r0_body.st174.S4 (runOk_trans PRE_first_tail_x6_r0_body.st174.F (PRE_first_tail_x6_r0_body.st174.bodyOkL bytes rows) (((nth? PRE_first_tail_x6_r0_body.st174.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st174.ks 1).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st174.ks 2).getD 0) PRE_first_tail_x6_r0_body.st174.s0 PRE_first_tail_x6_r0_body.st174.s2 PRE_first_tail_x6_r0_body.st174.s3 PRE_first_tail_x6_r0_body.st174.S0 PRE_first_tail_x6_r0_body.st174.S2 PRE_first_tail_x6_r0_body.st174.S3 (runOk_trans PRE_first_tail_x6_r0_body.st174.F (PRE_first_tail_x6_r0_body.st174.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st174.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st174.ks 1).getD 0) PRE_first_tail_x6_r0_body.st174.s0 PRE_first_tail_x6_r0_body.st174.s1 PRE_first_tail_x6_r0_body.st174.s2 PRE_first_tail_x6_r0_body.st174.S0 PRE_first_tail_x6_r0_body.st174.S1 PRE_first_tail_x6_r0_body.st174.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st174.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st174.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st174.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st174.bodyK3 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st174.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st174.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st174.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st174.F (PRE_first_tail_x6_r0_body.st174.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st174.s0
  S0 := PRE_first_tail_x6_r0_body.st174.S0
  s1 := PRE_first_tail_x6_r0_body.st174.s4
  S1 := PRE_first_tail_x6_r0_body.st174.S4
  s2 := PRE_first_tail_x6_r0_body.st174.s5
  S2 := PRE_first_tail_x6_r0_body.st174.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st174.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st174.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st174.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st174.bodyHalt
  last := PRE_first_tail_x6_r0_body.st174.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st174.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC175
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 175 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s1694` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa175` into the merged state
`PRE_first_tail_x6_r0_body.s1693`. -/

def PRE_first_tail_x6_r0_body.pl175 : List Nat := []
def PRE_first_tail_x6_r0_body.nr175 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd175 : RData :=
  ⟨2812315, 2812317, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21650, 21650, 18762, 18762, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa175 : Map :=
  Conv.Map.compact 2812315 2812317 7562 PRE_first_tail_x6_r0_body.pl175 (PRE_first_tail_x6_r0_body.nr175.map NumV.ref) PRE_first_tail_x6_r0_body.kd175.big
    PRE_first_tail_x6_r0_body.kd175.region PRE_first_tail_x6_r0_body.kd175.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws175 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs175 : List SymE := PRE_first_tail_x6_r0_body.nr175.map fun r => (nth? PRE_first_tail_x6_r0_body.S1693.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta175 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws175 PRE_first_tail_x6_r0_body.crs175
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB175 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab175 : PRE_first_tail_x6_r0_body.S1694.tab = PRE_first_tail_x6_r0_body.S1692.tab ++ PRE_first_tail_x6_r0_body.cws175.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace175 : PRE_first_tail_x6_r0_body.s1694.trace = PRE_first_tail_x6_r0_body.s1692.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext175 : PRE_first_tail_x6_r0_body.s1694.next = 2812315
kernel_rfl PRE_first_tail_x6_r0_body.ccounters175 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1694.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1694.ffi).mlx.nnext) = (21650, 18762)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue175 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1693.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1694.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa175.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp175 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1694.ffi).mlx.tokens.all (bSN 7562) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean175 : Conv.cleanListB 21650 131072 (fun r => Nat.ble 86600 r) PRE_first_tail_x6_r0_body.s1694
    (PRE_first_tail_x6_r0_body.wrB175 ++ (List.range 0).map (2812315 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs175 : bigsOutB 21650 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1694.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK175
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl175`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl175 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo175 : List Nat := []
def PRE_first_tail_x6_r0_body.cln175 : List Nat := []
def PRE_first_tail_x6_r0_body.cli175 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap175 : PRE_first_tail_x6_r0_body.s1694.heap = Stage.setAll PRE_first_tail_x6_r0_body.s1692.heap (PRE_first_tail_x6_r0_body.cl175.filterMap fun a => (PRE_first_tail_x6_r0_body.s1694.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe175 : Nat.ble PRE_first_tail_x6_r0_body.s1692.next PRE_first_tail_x6_r0_body.s1694.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP175 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s1692 PRE_first_tail_x6_r0_body.s1694 PRE_first_tail_x6_r0_body.cl175 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp175 : Conv.suppListB PRE_first_tail_x6_r0_body.s1694 7562 PRE_first_tail_x6_r0_body.cl175 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound175 : Conv.boundListB PRE_first_tail_x6_r0_body.s1694 PRE_first_tail_x6_r0_body.cl175 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK175 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1694.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln175.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1694.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK175 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1694.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo175.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1694.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK175 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1694.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli175.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1694.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst175 : Conv.sstListB 7562 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1694.ffi).mlx PRE_first_tail_x6_r0_body.cln175 PRE_first_tail_x6_r0_body.clo175 PRE_first_tail_x6_r0_body.cli175 = true

end Host.Load.Run.Tpl
end

section -- SiteCl175
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA175 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1694.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo175.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1694.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd175 : (PRE_first_tail_x6_r0_body.clo175 ++ PRE_first_tail_x6_r0_body.cln175 ++ PRE_first_tail_x6_r0_body.cli175).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle175 : Conv.Cnt.leB (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt) (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck175 : Conv.ncleanListB (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1694.ffi).mlx PRE_first_tail_x6_r0_body.clo175 PRE_first_tail_x6_r0_body.cln175 PRE_first_tail_x6_r0_body.cli175 = true
theorem PRE_first_tail_x6_r0_body.cncl175 (h : Conv.NClean (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx) : Conv.NClean (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1694.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle175 PRE_first_tail_x6_r0_body.ckA175 PRE_first_tail_x6_r0_body.cobjsK175 PRE_first_tail_x6_r0_body.cnodesK175 PRE_first_tail_x6_r0_body.citemsK175 PRE_first_tail_x6_r0_body.cbd175 PRE_first_tail_x6_r0_body.cck175

end Host.Load.Run.Tpl
end

section -- SiteS175
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 175 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc175 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P175 : LoadP := PRE_first_tail_x6_r0_body.Pc175.raise 18762
kernel_rfl PRE_first_tail_x6_r0_body.craise175 : Nat.ble PRE_first_tail_x6_r0_body.Pc175.N0 18762 = true
theorem PRE_first_tail_x6_r0_body.raised175 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc175 PRE_first_tail_x6_r0_body.P175 :=
  .inr ⟨18762, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise175, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_175 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1694.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_175 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1693.ffi)
def PRE_first_tail_x6_r0_body.khinv175 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv175 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS175 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS175 : List Nat := List.range' 18762 0
def PRE_first_tail_x6_r0_body.ciS175 : List Nat := [] ++ List.range' 18762 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh0175 : PRE_first_tail_x6_r0_body.kd175.nh0 = PRE_first_tail_x6_r0_body.cx0_175.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh1175 : PRE_first_tail_x6_r0_body.kd175.nh1 = PRE_first_tail_x6_r0_body.cx1_175.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn0175 : PRE_first_tail_x6_r0_body.kd175.nn0 = PRE_first_tail_x6_r0_body.cx0_175.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn1175 : PRE_first_tail_x6_r0_body.kd175.nn1 = PRE_first_tail_x6_r0_body.cx1_175.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo175 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P175.lo && Nat.ble PRE_first_tail_x6_r0_body.P175.lo PRE_first_tail_x6_r0_body.cx0_175.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P175.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P175.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt175 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_175.mlx.next PRE_first_tail_x6_r0_body.cx1_175.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_175.mlx.nnext PRE_first_tail_x6_r0_body.cx1_175.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband175 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P175.NL && Nat.ble PRE_first_tail_x6_r0_body.P175.NL PRE_first_tail_x6_r0_body.P175.N0 && Nat.ble PRE_first_tail_x6_r0_body.P175.N0 PRE_first_tail_x6_r0_body.cx0_175.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow175 : PRE_first_tail_x6_r0_body.kd175.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren175 : checkRenG PRE_first_tail_x6_r0_body.kd175.hnd PRE_first_tail_x6_r0_body.khinv175 (phB PRE_first_tail_x6_r0_body.cx0_175.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband175 : PRE_first_tail_x6_r0_body.kd175.checkBand PRE_first_tail_x6_r0_body.P175.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos175 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd175.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren175 : checkRenG PRE_first_tail_x6_r0_body.kd175.node PRE_first_tail_x6_r0_body.kninv175 (pnB PRE_first_tail_x6_r0_body.cx0_175.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow175 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd175.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P175.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd175.nodeF j) PRE_first_tail_x6_r0_body.cx1_175.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a175 : PRE_first_tail_x6_r0_body.cx0_175.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b175 : PRE_first_tail_x6_r0_body.cx0_175.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok1175 : PRE_first_tail_x6_r0_body.cx1_175.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend175 : PRE_first_tail_x6_r0_body.cx1_175.mlx.pending = PRE_first_tail_x6_r0_body.cx0_175.mlx.pending.map PRE_first_tail_x6_r0_body.kappa175.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh175 : PRE_first_tail_x6_r0_body.cx1_175.mlx.errh = PRE_first_tail_x6_r0_body.cx0_175.mlx.errh.map PRE_first_tail_x6_r0_body.kappa175.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles175 : PRE_first_tail_x6_r0_body.cx1_175.mlx.files = PRE_first_tail_x6_r0_body.cx0_175.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch175 : PRE_first_tail_x6_r0_body.cx1_175.mlx.arch = PRE_first_tail_x6_r0_body.cx0_175.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes175 : PRE_first_tail_x6_r0_body.cx1_175.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_175.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired175 : PRE_first_tail_x6_r0_body.cx1_175.mlx.wired = PRE_first_tail_x6_r0_body.cx0_175.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost175 : PRE_first_tail_x6_r0_body.cx1_175.host = PRE_first_tail_x6_r0_body.cx0_175.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd175`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn0175 : PRE_first_tail_x6_r0_body.kd175.n0 = 2812315
kernel_rfl PRE_first_tail_x6_r0_body.ckn1175 : PRE_first_tail_x6_r0_body.kd175.n1 = 2812317
kernel_rfl PRE_first_tail_x6_r0_body.ckheap175 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd175.heap).all (fun x => Nat.ble 2812315 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl175 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_body.kd175.heap.get (2812315 + j) = nth? PRE_first_tail_x6_r0_body.pl175 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja175 : Nat.ble 2812315 2812315 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn175 : Nat.ble 7562 7562 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD175 : Nat.ble 2812315 PRE_first_tail_x6_r0_body.kd175.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn175 : Nat.ble 21650 PRE_first_tail_x6_r0_body.kd175.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn175 : Nat.ble 18762 PRE_first_tail_x6_r0_body.kd175.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb175 : Nat.ble 21650 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap175 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd175.heap).all (Nat.ble (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd175 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd175.hnd).all (Nat.ble (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode175 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd175.node).all (Nat.ble (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix175 : Conv.FixOld (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa175 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja175) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn175) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD175) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn175) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn175) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb175) PRE_first_tail_x6_r0_body.fheap175 PRE_first_tail_x6_r0_body.fhnd175 PRE_first_tail_x6_r0_body.fnode175
kernel_rfl PRE_first_tail_x6_r0_body.fcxn175 : (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn175 : (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle0175 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_175.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_175.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk175 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd175.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A175 : PRE_first_tail_x6_r0_body.cx1_175.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS175.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_175.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O175 : PRE_first_tail_x6_r0_body.cx1_175.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS175.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_175.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N175 : PRE_first_tail_x6_r0_body.cx1_175.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS175.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_175.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I175 : PRE_first_tail_x6_r0_body.cx1_175.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS175.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_175.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd175 : (PRE_first_tail_x6_r0_body.clo175 ++ PRE_first_tail_x6_r0_body.cln175 ++ PRE_first_tail_x6_r0_body.cli175 ++ PRE_first_tail_x6_r0_body.cwS175 ++ PRE_first_tail_x6_r0_body.cnS175 ++ PRE_first_tail_x6_r0_body.ciS175).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW175 : PRE_first_tail_x6_r0_body.cwS175.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo175.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI175 : PRE_first_tail_x6_r0_body.ciS175.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli175.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN175 : PRE_first_tail_x6_r0_body.cnS175.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF175 : PRE_first_tail_x6_r0_body.cln175.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh175 : PRE_first_tail_x6_r0_body.clo175.all (handleOK PRE_first_tail_x6_r0_body.kappa175 PRE_first_tail_x6_r0_body.P175.lo PRE_first_tail_x6_r0_body.cx0_175.mlx PRE_first_tail_x6_r0_body.cx1_175.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo175 : PRE_first_tail_x6_r0_body.clo175.map (fun h => PRE_first_tail_x6_r0_body.cx1_175.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa175.handle h)) = PRE_first_tail_x6_r0_body.clo175.map (fun h => (PRE_first_tail_x6_r0_body.cx0_175.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa175.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok175 : PRE_first_tail_x6_r0_body.clo175.all (objOK PRE_first_tail_x6_r0_body.kappa175 PRE_first_tail_x6_r0_body.P175.NL PRE_first_tail_x6_r0_body.cx0_175.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd175 : PRE_first_tail_x6_r0_body.cln175.all (nodeOKF PRE_first_tail_x6_r0_body.kappa175 PRE_first_tail_x6_r0_body.P175 PRE_first_tail_x6_r0_body.cx0_175.mlx PRE_first_tail_x6_r0_body.cx1_175.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp175 : ((PRE_first_tail_x6_r0_body.cln175.filter (fullB PRE_first_tail_x6_r0_body.P175))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_175.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa175.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln175.filter (fullB PRE_first_tail_x6_r0_body.P175))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_175.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa175.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI175 : incrB PRE_first_tail_x6_r0_body.kd175.nodeF (List.range' 18762 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK175 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd175.node).all (fun k => Nat.ble 18762 k && Nat.blt k 18762) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL175 : (PRE_first_tail_x6_r0_body.cln175.filter (Nat.ble PRE_first_tail_x6_r0_body.P175.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd175.nodeF i) && (Nat.blt i 18762 || Nat.ble PRE_first_tail_x6_r0_body.kd175.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord175 : (PRE_first_tail_x6_r0_body.cln175.filter (Nat.ble PRE_first_tail_x6_r0_body.P175.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd175.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd175.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd175.nodeF j) (PRE_first_tail_x6_r0_body.kd175.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow175 PRE_first_tail_x6_r0_body.cnn1175 PRE_first_tail_x6_r0_body.fnordI175 PRE_first_tail_x6_r0_body.fnordK175 PRE_first_tail_x6_r0_body.fnordL175
kernel_rfl PRE_first_tail_x6_r0_body.fi175 : PRE_first_tail_x6_r0_body.cli175.all (pnB PRE_first_tail_x6_r0_body.cx0_175.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii175 : PRE_first_tail_x6_r0_body.cli175.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_175.mlx.items.get (PRE_first_tail_x6_r0_body.kappa175.node k) = (PRE_first_tail_x6_r0_body.cx0_175.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa175.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot175 (clean : Conv.NClean (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P175.NL) (cl : SSt (· < 7562) PRE_first_tail_x6_r0_body.cx0_175.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P175 7562 PRE_first_tail_x6_r0_body.kappa175 PRE_first_tail_x6_r0_body.kd175 PRE_first_tail_x6_r0_body.khinv175 PRE_first_tail_x6_r0_body.kninv175 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx PRE_first_tail_x6_r0_body.cx0_175.mlx PRE_first_tail_x6_r0_body.cx1_175.mlx (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo175 PRE_first_tail_x6_r0_body.cln175 PRE_first_tail_x6_r0_body.cli175 PRE_first_tail_x6_r0_body.cwS175 PRE_first_tail_x6_r0_body.cnS175 PRE_first_tail_x6_r0_body.ciS175 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh0175, PRE_first_tail_x6_r0_body.cnh1175, PRE_first_tail_x6_r0_body.cnn0175, PRE_first_tail_x6_r0_body.cnn1175, PRE_first_tail_x6_r0_body.cplo175, PRE_first_tail_x6_r0_body.ccnt175, PRE_first_tail_x6_r0_body.cnband175, PRE_first_tail_x6_r0_body.chbelow175, PRE_first_tail_x6_r0_body.chren175, PRE_first_tail_x6_r0_body.cband175, PRE_first_tail_x6_r0_body.cnh1pos175, PRE_first_tail_x6_r0_body.cnren175, PRE_first_tail_x6_r0_body.cnlow175, PRE_first_tail_x6_r0_body.cabs0a175, PRE_first_tail_x6_r0_body.cabs0b175, PRE_first_tail_x6_r0_body.ctok1175, PRE_first_tail_x6_r0_body.cpend175, PRE_first_tail_x6_r0_body.cerrh175, PRE_first_tail_x6_r0_body.cfiles175, PRE_first_tail_x6_r0_body.carch175, PRE_first_tail_x6_r0_body.csizes175, PRE_first_tail_x6_r0_body.cwired175, PRE_first_tail_x6_r0_body.cfix175, clean, PRE_first_tail_x6_r0_body.fcxn175, PRE_first_tail_x6_r0_body.fcnn175, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle0175, PRE_first_tail_x6_r0_body.fnk175, PRE_first_tail_x6_r0_body.ckA175, PRE_first_tail_x6_r0_body.cobjsK175, PRE_first_tail_x6_r0_body.cnodesK175, PRE_first_tail_x6_r0_body.citemsK175, PRE_first_tail_x6_r0_body.f1A175, PRE_first_tail_x6_r0_body.f1O175, PRE_first_tail_x6_r0_body.f1N175, PRE_first_tail_x6_r0_body.f1I175, PRE_first_tail_x6_r0_body.fbd175, PRE_first_tail_x6_r0_body.fincW175, PRE_first_tail_x6_r0_body.fincI175, PRE_first_tail_x6_r0_body.fincN175, PRE_first_tail_x6_r0_body.flnF175, PRE_first_tail_x6_r0_body.fh175, PRE_first_tail_x6_r0_body.fo175, PRE_first_tail_x6_r0_body.fok175, PRE_first_tail_x6_r0_body.fnd175, PRE_first_tail_x6_r0_body.fp175, PRE_first_tail_x6_r0_body.fnord175, PRE_first_tail_x6_r0_body.fi175, PRE_first_tail_x6_r0_body.fii175⟩
theorem PRE_first_tail_x6_r0_body.cnshift175 (clean : Conv.NClean (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P175.NL) (cl : SSt (· < 7562) PRE_first_tail_x6_r0_body.cx0_175.mlx) : NShift PRE_first_tail_x6_r0_body.P175 7562 PRE_first_tail_x6_r0_body.kappa175 PRE_first_tail_x6_r0_body.cx0_175 PRE_first_tail_x6_r0_body.cx1_175 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot175 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost175 (compact_a_eq PRE_first_tail_x6_r0_body.ckn0175 PRE_first_tail_x6_r0_body.ckn1175 PRE_first_tail_x6_r0_body.ckheap175 PRE_first_tail_x6_r0_body.ckpl175)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_175 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1692.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_175 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1692.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_175 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1692.ffi) = some PRE_first_tail_x6_r0_body.fxC_175
kernel_rfl PRE_first_tail_x6_r0_body.okrC_175 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1692.ffi) = some PRE_first_tail_x6_r0_body.krC_175
noncomputable def PRE_first_tail_x6_r0_body.fx0_175 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1694.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_175 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1694.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_175 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1694.ffi) = some PRE_first_tail_x6_r0_body.fx0_175
kernel_rfl PRE_first_tail_x6_r0_body.okr0_175 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1694.ffi) = some PRE_first_tail_x6_r0_body.kr0_175
noncomputable def PRE_first_tail_x6_r0_body.fx1_175 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1693.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_175 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1693.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_175 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1693.ffi) = some PRE_first_tail_x6_r0_body.fx1_175
kernel_rfl PRE_first_tail_x6_r0_body.okr1_175 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1693.ffi) = some PRE_first_tail_x6_r0_body.kr1_175
kernel_rfl PRE_first_tail_x6_r0_body.ff0175 : PRE_first_tail_x6_r0_body.fx0_175 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_175 (PRE_first_tail_x6_r0_body.clo175.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_175.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff1175 : PRE_first_tail_x6_r0_body.fx1_175 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_175 (PRE_first_tail_x6_r0_body.cwS175.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_175.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck175 : freedLB PRE_first_tail_x6_r0_body.kappa175 PRE_first_tail_x6_r0_body.cx0_175.mlx PRE_first_tail_x6_r0_body.fx0_175 PRE_first_tail_x6_r0_body.fx1_175 PRE_first_tail_x6_r0_body.clo175 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf0175 : PRE_first_tail_x6_r0_body.kr0_175.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_175.flags (PRE_first_tail_x6_r0_body.clo175.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_175.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt0175 : PRE_first_tail_x6_r0_body.kr0_175.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_175.targs (PRE_first_tail_x6_r0_body.clo175.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_175.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf1175 : PRE_first_tail_x6_r0_body.kr1_175.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_175.flags (PRE_first_tail_x6_r0_body.cwS175.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_175.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt1175 : PRE_first_tail_x6_r0_body.kr1_175.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_175.targs (PRE_first_tail_x6_r0_body.cwS175.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_175.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck175 : krecLB PRE_first_tail_x6_r0_body.kappa175 7562 PRE_first_tail_x6_r0_body.cx0_175.mlx PRE_first_tail_x6_r0_body.kr0_175 PRE_first_tail_x6_r0_body.kr1_175 PRE_first_tail_x6_r0_body.clo175 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn175 : Nat.ble 7562 7562 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge175 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1693.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1694.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR175 : pendRegB PRE_first_tail_x6_r0_body.kappa175 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1694.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe175 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1694.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1693.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift175 (clean : Conv.NClean (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P175.NL) (cl : SSt (· < 7562) PRE_first_tail_x6_r0_body.cx0_175.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_175.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_175.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_175.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1692.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_175.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P175 7562 PRE_first_tail_x6_r0_body.kappa175 PRE_first_tail_x6_r0_body.s1694.ffi PRE_first_tail_x6_r0_body.s1693.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift175 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue175, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp175 t ht),
    PRE_first_tail_x6_r0_body.cbridge175,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1694.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1693.ffi) (PRE_first_tail_x6_r0_body.cfoot175 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_175 PRE_first_tail_x6_r0_body.ofx1_175 hobjC PRE_first_tail_x6_r0_body.ff0175 PRE_first_tail_x6_r0_body.ff1175 PRE_first_tail_x6_r0_body.ffck175,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1694.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1693.ffi) (PRE_first_tail_x6_r0_body.cfoot175 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_175 PRE_first_tail_x6_r0_body.okr1_175 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn175) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf0175 PRE_first_tail_x6_r0_body.fkt0175 PRE_first_tail_x6_r0_body.fkf1175 PRE_first_tail_x6_r0_body.fkt1175 PRE_first_tail_x6_r0_body.fkck175,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh0175 PRE_first_tail_x6_r0_body.cnh1175 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe175) PRE_first_tail_x6_r0_body.cpendR175⟩

end Host.Load.Run.Tpl
end

section -- st175/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st175 0
host_stream_state PRE_first_tail_x6_r0_body.st175 1
host_stream_state PRE_first_tail_x6_r0_body.st175 2
end Host.Load.Run.Tpl
end

section -- Site175
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 175 of chain `PRE_first_tail_x6_r0_body`: `rowBlocks__g175__g176` (`rowBlocks`), the call state `PRE_first_tail_x6_r0_body.s1692`, the merged state `PRE_first_tail_x6_r0_body.s1693`,
the site template `PRE_first_tail_x6_r0_body.st175` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s1694`: the merge.
The footprint's facts are in `SiteF175`, the compaction's in `SiteC175`, `SiteK175`, `SiteNa175`, `SiteNb175`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso175 : PRE_first_tail_x6_r0_body.st175.s0 = { PRE_first_tail_x6_r0_body.s1692 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs175 : List Frame := PRE_first_tail_x6_r0_body.s1692.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_175 : PRE_first_tail_x6_r0_body.S1692.tab.length = 7562
kernel_rfl PRE_first_tail_x6_r0_body.tab0_175 : PRE_first_tail_x6_r0_body.st175.S0.tab = PRE_first_tail_x6_r0_body.S1692.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws175 : List Nat := [3979, 3980]
kernel_rfl PRE_first_tail_x6_r0_body.fresh175 : (PRE_first_tail_x6_r0_body.S1692.tab.all fun e => PRE_first_tail_x6_r0_body.ws175.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S1692.oracle.all fun q => PRE_first_tail_x6_r0_body.ws175.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab175 : PRE_first_tail_x6_r0_body.S1693.tab = PRE_first_tail_x6_r0_body.S1692.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws175
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen175 : PRE_first_tail_x6_r0_body.st175.S2.tab.length - PRE_first_tail_x6_r0_body.st175.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged175`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap175 : PRE_first_tail_x6_r0_body.s1693.heap = PRE_first_tail_x6_r0_body.st175.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext175 : PRE_first_tail_x6_r0_body.s1693.next = PRE_first_tail_x6_r0_body.st175.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl175 : PRE_first_tail_x6_r0_body.s1693.ctl = PRE_first_tail_x6_r0_body.st175.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack175 : PRE_first_tail_x6_r0_body.s1693.stack = PRE_first_tail_x6_r0_body.st175.s2.stack ++ PRE_first_tail_x6_r0_body.s1692.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs175 : PRE_first_tail_x6_r0_body.s1693.jobs = PRE_first_tail_x6_r0_body.st175.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi175 : PRE_first_tail_x6_r0_body.s1693.ffi = PRE_first_tail_x6_r0_body.st175.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace175 : PRE_first_tail_x6_r0_body.s1693.trace = PRE_first_tail_x6_r0_body.st175.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores175 : PRE_first_tail_x6_r0_body.s1693.stores = PRE_first_tail_x6_r0_body.st175.s2.stores

end Host.Load.Run.Tpl
end

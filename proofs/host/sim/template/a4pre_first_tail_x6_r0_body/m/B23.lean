import host.sim.template.a4pre_first_tail_x6_r0_body.m.B22
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

section -- SiteZ76
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 76 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s743`, the merged
state `PRE_first_tail_x6_r0_body.s744`, the canonical state `PRE_first_tail_x6_r0_body.s745`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl76 : PRE_first_tail_x6_r0_body.pl76.all (Nat.ble PRE_first_tail_x6_r0_body.s743.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd76 : nodupT PRE_first_tail_x6_r0_body.pl76 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn176 : Nat.ble PRE_first_tail_x6_r0_body.s743.next 2734713 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst76 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s743.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn76 : PRE_first_tail_x6_r0_body.s745.next = PRE_first_tail_x6_r0_body.s743.next + PRE_first_tail_x6_r0_body.pl76.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn76 : PRE_first_tail_x6_r0_body.s744.next = 2734713
kernel_rfl PRE_first_tail_x6_r0_body.zgrow76 : Nat.ble PRE_first_tail_x6_r0_body.s745.next PRE_first_tail_x6_r0_body.s744.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh76 : PRE_first_tail_x6_r0_body.S743.tab.all (fun e => PRE_first_tail_x6_r0_body.cws76.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd76 : nodupT PRE_first_tail_x6_r0_body.cws76 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi76 : PRE_first_tail_x6_r0_body.nr76.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S744.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt76 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s743.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg76_2665 : PRE_first_tail_x6_r0_body.s745.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s745 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk76_2665 : (objOf PRE_first_tail_x6_r0_body.s745 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm76_2665 : PRE_first_tail_x6_r0_body.s744.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa76.obj (objOf PRE_first_tail_x6_r0_body.s745 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s744 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg76_2673467 : PRE_first_tail_x6_r0_body.s745.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s745 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk76_2673467 : (objOf PRE_first_tail_x6_r0_body.s745 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm76_2673467 : PRE_first_tail_x6_r0_body.s744.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa76.obj (objOf PRE_first_tail_x6_r0_body.s745 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s744 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw76_4910 : (PRE_first_tail_x6_r0_body.s745.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw76_2673472 : (PRE_first_tail_x6_r0_body.s745.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw76_2673473 : (PRE_first_tail_x6_r0_body.s745.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd76 : PRE_first_tail_x6_r0_body.cl76.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr76 : PRE_first_tail_x6_r0_body.st76.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s743.next || PRE_first_tail_x6_r0_body.cl76.contains b) = true
def PRE_first_tail_x6_r0_body.zl76 : List Nat := PRE_first_tail_x6_r0_body.cl76.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE76 : PRE_first_tail_x6_r0_body.zl76.map (fun a => PRE_first_tail_x6_r0_body.s744.heap.get (PRE_first_tail_x6_r0_body.kappa76.a a)) = PRE_first_tail_x6_r0_body.zl76.map (fun a => (PRE_first_tail_x6_r0_body.s745.heap.get a).map PRE_first_tail_x6_r0_body.kappa76.hobj)
theorem PRE_first_tail_x6_r0_body.zimg76 : HeapImg PRE_first_tail_x6_r0_body.kappa76 PRE_first_tail_x6_r0_body.s745 PRE_first_tail_x6_r0_body.s744 PRE_first_tail_x6_r0_body.zl76 := PRE_first_tail_x6_r0_body.zimgE76
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl76 : PRE_first_tail_x6_r0_body.s744.ctl = PRE_first_tail_x6_r0_body.kappa76.ctl PRE_first_tail_x6_r0_body.s745.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack76 : PRE_first_tail_x6_r0_body.s744.stack = PRE_first_tail_x6_r0_body.s745.stack.map PRE_first_tail_x6_r0_body.kappa76.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs76 : PRE_first_tail_x6_r0_body.s744.jobs = PRE_first_tail_x6_r0_body.s745.jobs.map PRE_first_tail_x6_r0_body.kappa76.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores76 : PRE_first_tail_x6_r0_body.s744.stores = PRE_first_tail_x6_r0_body.kappa76.stores PRE_first_tail_x6_r0_body.s745.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots76 : checkRootsSupp PRE_first_tail_x6_r0_body.s745 3329 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC76 : PRE_first_tail_x6_r0_body.S743.tab.length + PRE_first_tail_x6_r0_body.cws76.length = 3329
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap76 : PRE_first_tail_x6_r0_body.kappa76 = Conv.Map.compact PRE_first_tail_x6_r0_body.s743.next 2734713 PRE_first_tail_x6_r0_body.S743.tab.length PRE_first_tail_x6_r0_body.pl76 (PRE_first_tail_x6_r0_body.nr76.map NumV.ref) PRE_first_tail_x6_r0_body.kd76.big
  PRE_first_tail_x6_r0_body.kd76.region PRE_first_tail_x6_r0_body.kd76.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin76 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s745.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc76 : Conv.jcleanListB (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s745 PRE_first_tail_x6_r0_body.cl76 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB76 : noBigRootsP (fun i => !Conv.oldBigB (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s745.trace PRE_first_tail_x6_r0_body.s745 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm76 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 16803 = true
theorem PRE_first_tail_x6_r0_body.cjcl76 (h : Conv.JClean (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s743) : Conv.JClean (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s745 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle76)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap76 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd76 a ha)) PRE_first_tail_x6_r0_body.zjc76

end Host.Load.Run.Tpl
end

section -- st76/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st76.bodyLast from PRE_first_tail_x6_r0_body.st76.s1 to PRE_first_tail_x6_r0_body.st76.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st76.F PRE_first_tail_x6_r0_body.st76.s1).run PRE_first_tail_x6_r0_body.st76.S1 = some (PRE_first_tail_x6_r0_body.st76.s2, PRE_first_tail_x6_r0_body.st76.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st76.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st76.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st76.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st76.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st76/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st76.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st76.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st76.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st76.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st76.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st76.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st76.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st76.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st76.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st76.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st76.s0 PRE_first_tail_x6_r0_body.st76.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st76.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st76.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st76.s1 PRE_first_tail_x6_r0_body.st76.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st76/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st76.bodyK0F from PRE_first_tail_x6_r0_body.st76.s0 to PRE_first_tail_x6_r0_body.st76.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st76.F (PRE_first_tail_x6_r0_body.st76.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st76.ks 0).getD 0) PRE_first_tail_x6_r0_body.st76.s0 PRE_first_tail_x6_r0_body.st76.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st76.s1, PRE_first_tail_x6_r0_body.st76.S1)
theorem PRE_first_tail_x6_r0_body.st76.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st76.F (PRE_first_tail_x6_r0_body.st76.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st76.ks 0).getD 0) PRE_first_tail_x6_r0_body.st76.s0 PRE_first_tail_x6_r0_body.st76.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st76.s1, PRE_first_tail_x6_r0_body.st76.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st76.bodyOkLN_ok PRE_first_tail_x6_r0_body.st76.bodyK0F
end Host.Load.Run.Tpl
end

section -- st76/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st76.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st76.F (PRE_first_tail_x6_r0_body.st76.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st76.s0 PRE_first_tail_x6_r0_body.st76.S0 = some (PRE_first_tail_x6_r0_body.st76.s1, PRE_first_tail_x6_r0_body.st76.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st76.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st76.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st76.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st76.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st76.F (PRE_first_tail_x6_r0_body.st76.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st76.s0
  S0 := PRE_first_tail_x6_r0_body.st76.S0
  s1 := PRE_first_tail_x6_r0_body.st76.s1
  S1 := PRE_first_tail_x6_r0_body.st76.S1
  s2 := PRE_first_tail_x6_r0_body.st76.s2
  S2 := PRE_first_tail_x6_r0_body.st76.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st76.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st76.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st76.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st76.bodyHalt
  last := PRE_first_tail_x6_r0_body.st76.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st76.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC77
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 77 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s749` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa77` into the merged state
`PRE_first_tail_x6_r0_body.s748`. -/

def PRE_first_tail_x6_r0_body.pl77 : List Nat := [2735009]
def PRE_first_tail_x6_r0_body.nr77 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd77 : RData :=
  ⟨2735000, 2735010, Stage.setAll PTrie.nil [(2734999, 2735009)], Stage.setAll PTrie.nil [],
   19712, 19712, 16807, 16807, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa77 : Map :=
  Conv.Map.compact 2734999 2735010 3346 PRE_first_tail_x6_r0_body.pl77 (PRE_first_tail_x6_r0_body.nr77.map NumV.ref) PRE_first_tail_x6_r0_body.kd77.big
    PRE_first_tail_x6_r0_body.kd77.region PRE_first_tail_x6_r0_body.kd77.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws77 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs77 : List SymE := PRE_first_tail_x6_r0_body.nr77.map fun r => (nth? PRE_first_tail_x6_r0_body.S748.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta77 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws77 PRE_first_tail_x6_r0_body.crs77
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB77 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab77 : PRE_first_tail_x6_r0_body.S749.tab = PRE_first_tail_x6_r0_body.S747.tab ++ PRE_first_tail_x6_r0_body.cws77.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace77 : PRE_first_tail_x6_r0_body.s749.trace = PRE_first_tail_x6_r0_body.s747.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext77 : PRE_first_tail_x6_r0_body.s749.next = 2735000
kernel_rfl PRE_first_tail_x6_r0_body.ccounters77 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s749.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s749.ffi).mlx.nnext) = (19712, 16807)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue77 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s748.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s749.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa77.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp77 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s749.ffi).mlx.tokens.all (bSN 3346) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean77 : Conv.cleanListB 19712 131072 (fun r => Nat.ble 78848 r) PRE_first_tail_x6_r0_body.s749
    (PRE_first_tail_x6_r0_body.wrB77 ++ (List.range 1).map (2734999 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs77 : bigsOutB 19712 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s749.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK77
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl77`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl77 : List Nat := [2665, 2673467, 2734999]
def PRE_first_tail_x6_r0_body.clo77 : List Nat := []
def PRE_first_tail_x6_r0_body.cln77 : List Nat := []
def PRE_first_tail_x6_r0_body.cli77 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap77 : PRE_first_tail_x6_r0_body.s749.heap = Stage.setAll PRE_first_tail_x6_r0_body.s747.heap (PRE_first_tail_x6_r0_body.cl77.filterMap fun a => (PRE_first_tail_x6_r0_body.s749.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe77 : Nat.ble PRE_first_tail_x6_r0_body.s747.next PRE_first_tail_x6_r0_body.s749.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP77 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s747 PRE_first_tail_x6_r0_body.s749 PRE_first_tail_x6_r0_body.cl77 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp77 : Conv.suppListB PRE_first_tail_x6_r0_body.s749 3346 PRE_first_tail_x6_r0_body.cl77 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound77 : Conv.boundListB PRE_first_tail_x6_r0_body.s749 PRE_first_tail_x6_r0_body.cl77 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK77 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s749.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln77.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s749.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK77 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s749.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo77.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s749.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK77 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s749.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli77.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s749.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst77 : Conv.sstListB 3346 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s749.ffi).mlx PRE_first_tail_x6_r0_body.cln77 PRE_first_tail_x6_r0_body.clo77 PRE_first_tail_x6_r0_body.cli77 = true

end Host.Load.Run.Tpl
end

section -- SiteCl77
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA77 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s749.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo77.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s749.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd77 : (PRE_first_tail_x6_r0_body.clo77 ++ PRE_first_tail_x6_r0_body.cln77 ++ PRE_first_tail_x6_r0_body.cli77).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle77 : Conv.Cnt.leB (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt) (⟨19712, 16807, 2735000, 3346⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck77 : Conv.ncleanListB (⟨19712, 16807, 2735000, 3346⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s749.ffi).mlx PRE_first_tail_x6_r0_body.clo77 PRE_first_tail_x6_r0_body.cln77 PRE_first_tail_x6_r0_body.cli77 = true
theorem PRE_first_tail_x6_r0_body.cncl77 (h : Conv.NClean (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx) : Conv.NClean (⟨19712, 16807, 2735000, 3346⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s749.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle77 PRE_first_tail_x6_r0_body.ckA77 PRE_first_tail_x6_r0_body.cobjsK77 PRE_first_tail_x6_r0_body.cnodesK77 PRE_first_tail_x6_r0_body.citemsK77 PRE_first_tail_x6_r0_body.cbd77 PRE_first_tail_x6_r0_body.cck77

end Host.Load.Run.Tpl
end

section -- SiteS77
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 77 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc77 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P77 : LoadP := PRE_first_tail_x6_r0_body.Pc77.raise 16807
kernel_rfl PRE_first_tail_x6_r0_body.craise77 : Nat.ble PRE_first_tail_x6_r0_body.Pc77.N0 16807 = true
theorem PRE_first_tail_x6_r0_body.raised77 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc77 PRE_first_tail_x6_r0_body.P77 :=
  .inr ⟨16807, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise77, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_77 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s749.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_77 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s748.ffi)
def PRE_first_tail_x6_r0_body.khinv77 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv77 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS77 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS77 : List Nat := List.range' 16807 0
def PRE_first_tail_x6_r0_body.ciS77 : List Nat := [] ++ List.range' 16807 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh077 : PRE_first_tail_x6_r0_body.kd77.nh0 = PRE_first_tail_x6_r0_body.cx0_77.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh177 : PRE_first_tail_x6_r0_body.kd77.nh1 = PRE_first_tail_x6_r0_body.cx1_77.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn077 : PRE_first_tail_x6_r0_body.kd77.nn0 = PRE_first_tail_x6_r0_body.cx0_77.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn177 : PRE_first_tail_x6_r0_body.kd77.nn1 = PRE_first_tail_x6_r0_body.cx1_77.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo77 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P77.lo && Nat.ble PRE_first_tail_x6_r0_body.P77.lo PRE_first_tail_x6_r0_body.cx0_77.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P77.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P77.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt77 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_77.mlx.next PRE_first_tail_x6_r0_body.cx1_77.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_77.mlx.nnext PRE_first_tail_x6_r0_body.cx1_77.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband77 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P77.NL && Nat.ble PRE_first_tail_x6_r0_body.P77.NL PRE_first_tail_x6_r0_body.P77.N0 && Nat.ble PRE_first_tail_x6_r0_body.P77.N0 PRE_first_tail_x6_r0_body.cx0_77.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow77 : PRE_first_tail_x6_r0_body.kd77.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren77 : checkRenG PRE_first_tail_x6_r0_body.kd77.hnd PRE_first_tail_x6_r0_body.khinv77 (phB PRE_first_tail_x6_r0_body.cx0_77.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband77 : PRE_first_tail_x6_r0_body.kd77.checkBand PRE_first_tail_x6_r0_body.P77.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos77 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd77.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren77 : checkRenG PRE_first_tail_x6_r0_body.kd77.node PRE_first_tail_x6_r0_body.kninv77 (pnB PRE_first_tail_x6_r0_body.cx0_77.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow77 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd77.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P77.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd77.nodeF j) PRE_first_tail_x6_r0_body.cx1_77.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a77 : PRE_first_tail_x6_r0_body.cx0_77.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b77 : PRE_first_tail_x6_r0_body.cx0_77.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok177 : PRE_first_tail_x6_r0_body.cx1_77.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend77 : PRE_first_tail_x6_r0_body.cx1_77.mlx.pending = PRE_first_tail_x6_r0_body.cx0_77.mlx.pending.map PRE_first_tail_x6_r0_body.kappa77.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh77 : PRE_first_tail_x6_r0_body.cx1_77.mlx.errh = PRE_first_tail_x6_r0_body.cx0_77.mlx.errh.map PRE_first_tail_x6_r0_body.kappa77.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles77 : PRE_first_tail_x6_r0_body.cx1_77.mlx.files = PRE_first_tail_x6_r0_body.cx0_77.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch77 : PRE_first_tail_x6_r0_body.cx1_77.mlx.arch = PRE_first_tail_x6_r0_body.cx0_77.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes77 : PRE_first_tail_x6_r0_body.cx1_77.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_77.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired77 : PRE_first_tail_x6_r0_body.cx1_77.mlx.wired = PRE_first_tail_x6_r0_body.cx0_77.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost77 : PRE_first_tail_x6_r0_body.cx1_77.host = PRE_first_tail_x6_r0_body.cx0_77.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd77`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn077 : PRE_first_tail_x6_r0_body.kd77.n0 = 2735000
kernel_rfl PRE_first_tail_x6_r0_body.ckn177 : PRE_first_tail_x6_r0_body.kd77.n1 = 2735010
kernel_rfl PRE_first_tail_x6_r0_body.ckheap77 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd77.heap).all (fun x => Nat.ble 2734999 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl77 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd77.heap.get (2734999 + j) = nth? PRE_first_tail_x6_r0_body.pl77 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja77 : Nat.ble 2734999 2734999 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn77 : Nat.ble 3346 3346 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD77 : Nat.ble 2734999 PRE_first_tail_x6_r0_body.kd77.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn77 : Nat.ble 19712 PRE_first_tail_x6_r0_body.kd77.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn77 : Nat.ble 16807 PRE_first_tail_x6_r0_body.kd77.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb77 : Nat.ble 19712 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap77 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd77.heap).all (Nat.ble (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd77 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd77.hnd).all (Nat.ble (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode77 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd77.node).all (Nat.ble (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix77 : Conv.FixOld (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa77 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja77) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn77) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD77) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn77) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn77) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb77) PRE_first_tail_x6_r0_body.fheap77 PRE_first_tail_x6_r0_body.fhnd77 PRE_first_tail_x6_r0_body.fnode77
kernel_rfl PRE_first_tail_x6_r0_body.fcxn77 : (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn77 : (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle077 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_77.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_77.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk77 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd77.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A77 : PRE_first_tail_x6_r0_body.cx1_77.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS77.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_77.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O77 : PRE_first_tail_x6_r0_body.cx1_77.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS77.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_77.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N77 : PRE_first_tail_x6_r0_body.cx1_77.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS77.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_77.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I77 : PRE_first_tail_x6_r0_body.cx1_77.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS77.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_77.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd77 : (PRE_first_tail_x6_r0_body.clo77 ++ PRE_first_tail_x6_r0_body.cln77 ++ PRE_first_tail_x6_r0_body.cli77 ++ PRE_first_tail_x6_r0_body.cwS77 ++ PRE_first_tail_x6_r0_body.cnS77 ++ PRE_first_tail_x6_r0_body.ciS77).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW77 : PRE_first_tail_x6_r0_body.cwS77.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo77.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI77 : PRE_first_tail_x6_r0_body.ciS77.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli77.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN77 : PRE_first_tail_x6_r0_body.cnS77.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF77 : PRE_first_tail_x6_r0_body.cln77.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh77 : PRE_first_tail_x6_r0_body.clo77.all (handleOK PRE_first_tail_x6_r0_body.kappa77 PRE_first_tail_x6_r0_body.P77.lo PRE_first_tail_x6_r0_body.cx0_77.mlx PRE_first_tail_x6_r0_body.cx1_77.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo77 : PRE_first_tail_x6_r0_body.clo77.map (fun h => PRE_first_tail_x6_r0_body.cx1_77.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa77.handle h)) = PRE_first_tail_x6_r0_body.clo77.map (fun h => (PRE_first_tail_x6_r0_body.cx0_77.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa77.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok77 : PRE_first_tail_x6_r0_body.clo77.all (objOK PRE_first_tail_x6_r0_body.kappa77 PRE_first_tail_x6_r0_body.P77.NL PRE_first_tail_x6_r0_body.cx0_77.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd77 : PRE_first_tail_x6_r0_body.cln77.all (nodeOKF PRE_first_tail_x6_r0_body.kappa77 PRE_first_tail_x6_r0_body.P77 PRE_first_tail_x6_r0_body.cx0_77.mlx PRE_first_tail_x6_r0_body.cx1_77.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp77 : ((PRE_first_tail_x6_r0_body.cln77.filter (fullB PRE_first_tail_x6_r0_body.P77))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_77.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa77.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln77.filter (fullB PRE_first_tail_x6_r0_body.P77))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_77.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa77.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI77 : incrB PRE_first_tail_x6_r0_body.kd77.nodeF (List.range' 16807 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK77 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd77.node).all (fun k => Nat.ble 16807 k && Nat.blt k 16807) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL77 : (PRE_first_tail_x6_r0_body.cln77.filter (Nat.ble PRE_first_tail_x6_r0_body.P77.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd77.nodeF i) && (Nat.blt i 16807 || Nat.ble PRE_first_tail_x6_r0_body.kd77.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord77 : (PRE_first_tail_x6_r0_body.cln77.filter (Nat.ble PRE_first_tail_x6_r0_body.P77.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd77.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd77.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd77.nodeF j) (PRE_first_tail_x6_r0_body.kd77.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow77 PRE_first_tail_x6_r0_body.cnn177 PRE_first_tail_x6_r0_body.fnordI77 PRE_first_tail_x6_r0_body.fnordK77 PRE_first_tail_x6_r0_body.fnordL77
kernel_rfl PRE_first_tail_x6_r0_body.fi77 : PRE_first_tail_x6_r0_body.cli77.all (pnB PRE_first_tail_x6_r0_body.cx0_77.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii77 : PRE_first_tail_x6_r0_body.cli77.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_77.mlx.items.get (PRE_first_tail_x6_r0_body.kappa77.node k) = (PRE_first_tail_x6_r0_body.cx0_77.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa77.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot77 (clean : Conv.NClean (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P77.NL) (cl : SSt (· < 3346) PRE_first_tail_x6_r0_body.cx0_77.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P77 3346 PRE_first_tail_x6_r0_body.kappa77 PRE_first_tail_x6_r0_body.kd77 PRE_first_tail_x6_r0_body.khinv77 PRE_first_tail_x6_r0_body.kninv77 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx PRE_first_tail_x6_r0_body.cx0_77.mlx PRE_first_tail_x6_r0_body.cx1_77.mlx (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo77 PRE_first_tail_x6_r0_body.cln77 PRE_first_tail_x6_r0_body.cli77 PRE_first_tail_x6_r0_body.cwS77 PRE_first_tail_x6_r0_body.cnS77 PRE_first_tail_x6_r0_body.ciS77 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh077, PRE_first_tail_x6_r0_body.cnh177, PRE_first_tail_x6_r0_body.cnn077, PRE_first_tail_x6_r0_body.cnn177, PRE_first_tail_x6_r0_body.cplo77, PRE_first_tail_x6_r0_body.ccnt77, PRE_first_tail_x6_r0_body.cnband77, PRE_first_tail_x6_r0_body.chbelow77, PRE_first_tail_x6_r0_body.chren77, PRE_first_tail_x6_r0_body.cband77, PRE_first_tail_x6_r0_body.cnh1pos77, PRE_first_tail_x6_r0_body.cnren77, PRE_first_tail_x6_r0_body.cnlow77, PRE_first_tail_x6_r0_body.cabs0a77, PRE_first_tail_x6_r0_body.cabs0b77, PRE_first_tail_x6_r0_body.ctok177, PRE_first_tail_x6_r0_body.cpend77, PRE_first_tail_x6_r0_body.cerrh77, PRE_first_tail_x6_r0_body.cfiles77, PRE_first_tail_x6_r0_body.carch77, PRE_first_tail_x6_r0_body.csizes77, PRE_first_tail_x6_r0_body.cwired77, PRE_first_tail_x6_r0_body.cfix77, clean, PRE_first_tail_x6_r0_body.fcxn77, PRE_first_tail_x6_r0_body.fcnn77, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle077, PRE_first_tail_x6_r0_body.fnk77, PRE_first_tail_x6_r0_body.ckA77, PRE_first_tail_x6_r0_body.cobjsK77, PRE_first_tail_x6_r0_body.cnodesK77, PRE_first_tail_x6_r0_body.citemsK77, PRE_first_tail_x6_r0_body.f1A77, PRE_first_tail_x6_r0_body.f1O77, PRE_first_tail_x6_r0_body.f1N77, PRE_first_tail_x6_r0_body.f1I77, PRE_first_tail_x6_r0_body.fbd77, PRE_first_tail_x6_r0_body.fincW77, PRE_first_tail_x6_r0_body.fincI77, PRE_first_tail_x6_r0_body.fincN77, PRE_first_tail_x6_r0_body.flnF77, PRE_first_tail_x6_r0_body.fh77, PRE_first_tail_x6_r0_body.fo77, PRE_first_tail_x6_r0_body.fok77, PRE_first_tail_x6_r0_body.fnd77, PRE_first_tail_x6_r0_body.fp77, PRE_first_tail_x6_r0_body.fnord77, PRE_first_tail_x6_r0_body.fi77, PRE_first_tail_x6_r0_body.fii77⟩
theorem PRE_first_tail_x6_r0_body.cnshift77 (clean : Conv.NClean (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P77.NL) (cl : SSt (· < 3346) PRE_first_tail_x6_r0_body.cx0_77.mlx) : NShift PRE_first_tail_x6_r0_body.P77 3346 PRE_first_tail_x6_r0_body.kappa77 PRE_first_tail_x6_r0_body.cx0_77 PRE_first_tail_x6_r0_body.cx1_77 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot77 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost77 (compact_a_eq PRE_first_tail_x6_r0_body.ckn077 PRE_first_tail_x6_r0_body.ckn177 PRE_first_tail_x6_r0_body.ckheap77 PRE_first_tail_x6_r0_body.ckpl77)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_77 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s747.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_77 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s747.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_77 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s747.ffi) = some PRE_first_tail_x6_r0_body.fxC_77
kernel_rfl PRE_first_tail_x6_r0_body.okrC_77 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s747.ffi) = some PRE_first_tail_x6_r0_body.krC_77
noncomputable def PRE_first_tail_x6_r0_body.fx0_77 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s749.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_77 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s749.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_77 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s749.ffi) = some PRE_first_tail_x6_r0_body.fx0_77
kernel_rfl PRE_first_tail_x6_r0_body.okr0_77 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s749.ffi) = some PRE_first_tail_x6_r0_body.kr0_77
noncomputable def PRE_first_tail_x6_r0_body.fx1_77 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s748.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_77 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s748.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_77 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s748.ffi) = some PRE_first_tail_x6_r0_body.fx1_77
kernel_rfl PRE_first_tail_x6_r0_body.okr1_77 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s748.ffi) = some PRE_first_tail_x6_r0_body.kr1_77
kernel_rfl PRE_first_tail_x6_r0_body.ff077 : PRE_first_tail_x6_r0_body.fx0_77 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_77 (PRE_first_tail_x6_r0_body.clo77.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_77.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff177 : PRE_first_tail_x6_r0_body.fx1_77 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_77 (PRE_first_tail_x6_r0_body.cwS77.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_77.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck77 : freedLB PRE_first_tail_x6_r0_body.kappa77 PRE_first_tail_x6_r0_body.cx0_77.mlx PRE_first_tail_x6_r0_body.fx0_77 PRE_first_tail_x6_r0_body.fx1_77 PRE_first_tail_x6_r0_body.clo77 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf077 : PRE_first_tail_x6_r0_body.kr0_77.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_77.flags (PRE_first_tail_x6_r0_body.clo77.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_77.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt077 : PRE_first_tail_x6_r0_body.kr0_77.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_77.targs (PRE_first_tail_x6_r0_body.clo77.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_77.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf177 : PRE_first_tail_x6_r0_body.kr1_77.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_77.flags (PRE_first_tail_x6_r0_body.cwS77.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_77.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt177 : PRE_first_tail_x6_r0_body.kr1_77.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_77.targs (PRE_first_tail_x6_r0_body.cwS77.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_77.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck77 : krecLB PRE_first_tail_x6_r0_body.kappa77 3346 PRE_first_tail_x6_r0_body.cx0_77.mlx PRE_first_tail_x6_r0_body.kr0_77 PRE_first_tail_x6_r0_body.kr1_77 PRE_first_tail_x6_r0_body.clo77 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn77 : Nat.ble 3346 3346 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge77 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s748.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s749.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR77 : pendRegB PRE_first_tail_x6_r0_body.kappa77 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s749.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe77 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s749.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s748.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift77 (clean : Conv.NClean (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P77.NL) (cl : SSt (· < 3346) PRE_first_tail_x6_r0_body.cx0_77.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_77.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_77.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_77.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s747.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_77.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P77 3346 PRE_first_tail_x6_r0_body.kappa77 PRE_first_tail_x6_r0_body.s749.ffi PRE_first_tail_x6_r0_body.s748.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift77 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue77, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp77 t ht),
    PRE_first_tail_x6_r0_body.cbridge77,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s749.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s748.ffi) (PRE_first_tail_x6_r0_body.cfoot77 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_77 PRE_first_tail_x6_r0_body.ofx1_77 hobjC PRE_first_tail_x6_r0_body.ff077 PRE_first_tail_x6_r0_body.ff177 PRE_first_tail_x6_r0_body.ffck77,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s749.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s748.ffi) (PRE_first_tail_x6_r0_body.cfoot77 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_77 PRE_first_tail_x6_r0_body.okr1_77 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn77) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf077 PRE_first_tail_x6_r0_body.fkt077 PRE_first_tail_x6_r0_body.fkf177 PRE_first_tail_x6_r0_body.fkt177 PRE_first_tail_x6_r0_body.fkck77,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh077 PRE_first_tail_x6_r0_body.cnh177 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe77) PRE_first_tail_x6_r0_body.cpendR77⟩

end Host.Load.Run.Tpl
end

section -- st77/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st77 0
host_stream_state PRE_first_tail_x6_r0_body.st77 1
host_stream_state PRE_first_tail_x6_r0_body.st77 2
end Host.Load.Run.Tpl
end

section -- Site77
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 77 of chain `PRE_first_tail_x6_r0_body`: `plan__g77__g78` (`plan`), the call state `PRE_first_tail_x6_r0_body.s747`, the merged state `PRE_first_tail_x6_r0_body.s748`,
the site template `PRE_first_tail_x6_r0_body.st77` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s749`: the merge.
The footprint's facts are in `SiteF77`, the compaction's in `SiteC77`, `SiteK77`, `SiteNa77`, `SiteNb77`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso77 : PRE_first_tail_x6_r0_body.st77.s0 = { PRE_first_tail_x6_r0_body.s747 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs77 : List Frame := PRE_first_tail_x6_r0_body.s747.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_77 : PRE_first_tail_x6_r0_body.S747.tab.length = 3346
kernel_rfl PRE_first_tail_x6_r0_body.tab0_77 : PRE_first_tail_x6_r0_body.st77.S0.tab = PRE_first_tail_x6_r0_body.S747.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws77 : List Nat := [2305, 2306, 2307]
kernel_rfl PRE_first_tail_x6_r0_body.fresh77 : (PRE_first_tail_x6_r0_body.S747.tab.all fun e => PRE_first_tail_x6_r0_body.ws77.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S747.oracle.all fun q => PRE_first_tail_x6_r0_body.ws77.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab77 : PRE_first_tail_x6_r0_body.S748.tab = PRE_first_tail_x6_r0_body.S747.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws77
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen77 : PRE_first_tail_x6_r0_body.st77.S2.tab.length - PRE_first_tail_x6_r0_body.st77.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged77`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap77 : PRE_first_tail_x6_r0_body.s748.heap = PRE_first_tail_x6_r0_body.st77.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext77 : PRE_first_tail_x6_r0_body.s748.next = PRE_first_tail_x6_r0_body.st77.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl77 : PRE_first_tail_x6_r0_body.s748.ctl = PRE_first_tail_x6_r0_body.st77.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack77 : PRE_first_tail_x6_r0_body.s748.stack = PRE_first_tail_x6_r0_body.st77.s2.stack ++ PRE_first_tail_x6_r0_body.s747.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs77 : PRE_first_tail_x6_r0_body.s748.jobs = PRE_first_tail_x6_r0_body.st77.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi77 : PRE_first_tail_x6_r0_body.s748.ffi = PRE_first_tail_x6_r0_body.st77.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace77 : PRE_first_tail_x6_r0_body.s748.trace = PRE_first_tail_x6_r0_body.st77.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores77 : PRE_first_tail_x6_r0_body.s748.stores = PRE_first_tail_x6_r0_body.st77.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD77
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 77 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived77 : PRE_first_tail_x6_r0_body.nr77.map (fun r => nth? PRE_first_tail_x6_r0_body.st77.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo77 : PRE_first_tail_x6_r0_body.nr77.all (Nat.ble 3346) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj77 : PRE_first_tail_x6_r0_body.cws77.all (fun c => !PRE_first_tail_x6_r0_body.ws77.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ77 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws77 PRE_first_tail_x6_r0_body.crs77 PRE_first_tail_x6_r0_body.ws77

end Host.Load.Run.Tpl
end

section -- st77/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st77`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st77.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st77.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st77.s2.heap PRE_first_tail_x6_r0_body.st77.wrR ++ freshOf PRE_first_tail_x6_r0_body.st77.s2.heap PRE_first_tail_x6_r0_body.st77.s0.next PRE_first_tail_x6_r0_body.st77.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st77.wr : List Nat := PRE_first_tail_x6_r0_body.st77.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st77.heapFoot : PRE_first_tail_x6_r0_body.st77.s2.heap = setAll PRE_first_tail_x6_r0_body.st77.s0.heap PRE_first_tail_x6_r0_body.st77.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st77.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st77.s0.next PRE_first_tail_x6_r0_body.st77.s2.next = true
theorem PRE_first_tail_x6_r0_body.st77.grows : PRE_first_tail_x6_r0_body.st77.s0.next ≤ PRE_first_tail_x6_r0_body.st77.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st77.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st77.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st77.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st77.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st77.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st77.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st77.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st77.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st77.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st77.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st77.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st77.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st77.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st77.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st77.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st77.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st77.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st77.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st77.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st77.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st77.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st77.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st77.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st77.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st77.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st77.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st77.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st77.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st77.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st77.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st77.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st77.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF77
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 77 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB77 : nodupT PRE_first_tail_x6_r0_body.st77.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup77 : PRE_first_tail_x6_r0_body.st77.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB77).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB77 : PRE_first_tail_x6_r0_body.st77.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound77 : ∀ b ∈ PRE_first_tail_x6_r0_body.st77.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB77 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr77 := PRE_first_tail_x6_r0_body.st77.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq77 : PRE_first_tail_x6_r0_body.st77.s2.trace = PRE_first_tail_x6_r0_body.trFr77 ++ PRE_first_tail_x6_r0_body.st77.s0.trace
theorem PRE_first_tail_x6_r0_body.trace77 : ∃ fr, PRE_first_tail_x6_r0_body.st77.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st77.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq77⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide77 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB77 : (PRE_first_tail_x6_r0_body.wide77.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st77.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix77 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide77, WFix Map.id (Present PRE_first_tail_x6_r0_body.st77.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB77 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL77
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 77 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s748`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO77 : PRE_first_tail_x6_r0_body.st77.S0.oracle = PRE_first_tail_x6_r0_body.st77.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B77 : PRE_first_tail_x6_r0_body.st77.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st77.s0.next || (PRE_first_tail_x6_r0_body.st77.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot77 : Conv.StageFoot PRE_first_tail_x6_r0_body.st77.wr PRE_first_tail_x6_r0_body.st77.s0 PRE_first_tail_x6_r0_body.st77.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st77.heapFoot PRE_first_tail_x6_r0_body.wrNodup77 PRE_first_tail_x6_r0_body.wrBound77 PRE_first_tail_x6_r0_body.wr0B77 PRE_first_tail_x6_r0_body.st77.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged77 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st77.F.S → PRE_first_tail_x6_r0_body.st77.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st77.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st77.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs77 PRE_first_tail_x6_r0_body.st77.wr PRE_first_tail_x6_r0_body.s747 PRE_first_tail_x6_r0_body.st77.s2 PRE_first_tail_x6_r0_body.st77.s0
      PRE_first_tail_x6_r0_body.st77.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st77.F FR W stk M ν K PRE_first_tail_x6_r0_body.s748 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso77 PRE_first_tail_x6_r0_body.stFoot77 PRE_first_tail_x6_r0_body.wrNodup77 PRE_first_tail_x6_r0_body.wrBound77 PRE_first_tail_x6_r0_body.trace77 PRE_first_tail_x6_r0_body.mheap77
    PRE_first_tail_x6_r0_body.mnext77 PRE_first_tail_x6_r0_body.mctl77 PRE_first_tail_x6_r0_body.mstack77 PRE_first_tail_x6_r0_body.mjobs77 PRE_first_tail_x6_r0_body.mffi77 PRE_first_tail_x6_r0_body.mtrace77 PRE_first_tail_x6_r0_body.mstores77 h

def PRE_first_tail_x6_r0_body.arrEl77_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE77_2665 : arrOf PRE_first_tail_x6_r0_body.s748 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl77_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA77_2665 : isArrB PRE_first_tail_x6_r0_body.s748 2665 = true
theorem PRE_first_tail_x6_r0_body.arr77_2665 : ∃ o, PRE_first_tail_x6_r0_body.s748.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl77_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE77_2665 PRE_first_tail_x6_r0_body.arrA77_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN77_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl77_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR77_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl77_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN77_2665

def PRE_first_tail_x6_r0_body.arrEl77_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE77_2673467 : arrOf PRE_first_tail_x6_r0_body.s748 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl77_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA77_2673467 : isArrB PRE_first_tail_x6_r0_body.s748 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr77_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s748.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl77_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE77_2673467 PRE_first_tail_x6_r0_body.arrA77_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN77_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl77_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR77_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl77_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN77_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k77 : isArrB PRE_first_tail_x6_r0_body.s748 4910 = false
theorem PRE_first_tail_x6_r0_body.keep77 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s748 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k77 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr77_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl77_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ77
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 77 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s747`, the merged
state `PRE_first_tail_x6_r0_body.s748`, the canonical state `PRE_first_tail_x6_r0_body.s749`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl77 : PRE_first_tail_x6_r0_body.pl77.all (Nat.ble PRE_first_tail_x6_r0_body.s747.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd77 : nodupT PRE_first_tail_x6_r0_body.pl77 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn177 : Nat.ble PRE_first_tail_x6_r0_body.s747.next 2735010 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst77 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s747.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn77 : PRE_first_tail_x6_r0_body.s749.next = PRE_first_tail_x6_r0_body.s747.next + PRE_first_tail_x6_r0_body.pl77.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn77 : PRE_first_tail_x6_r0_body.s748.next = 2735010
kernel_rfl PRE_first_tail_x6_r0_body.zgrow77 : Nat.ble PRE_first_tail_x6_r0_body.s749.next PRE_first_tail_x6_r0_body.s748.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh77 : PRE_first_tail_x6_r0_body.S747.tab.all (fun e => PRE_first_tail_x6_r0_body.cws77.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd77 : nodupT PRE_first_tail_x6_r0_body.cws77 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi77 : PRE_first_tail_x6_r0_body.nr77.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S748.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt77 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s747.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg77_2665 : PRE_first_tail_x6_r0_body.s749.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s749 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk77_2665 : (objOf PRE_first_tail_x6_r0_body.s749 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm77_2665 : PRE_first_tail_x6_r0_body.s748.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa77.obj (objOf PRE_first_tail_x6_r0_body.s749 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s748 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg77_2673467 : PRE_first_tail_x6_r0_body.s749.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s749 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk77_2673467 : (objOf PRE_first_tail_x6_r0_body.s749 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm77_2673467 : PRE_first_tail_x6_r0_body.s748.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa77.obj (objOf PRE_first_tail_x6_r0_body.s749 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s748 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw77_4910 : (PRE_first_tail_x6_r0_body.s749.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw77_2673472 : (PRE_first_tail_x6_r0_body.s749.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw77_2673473 : (PRE_first_tail_x6_r0_body.s749.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd77 : PRE_first_tail_x6_r0_body.cl77.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr77 : PRE_first_tail_x6_r0_body.st77.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s747.next || PRE_first_tail_x6_r0_body.cl77.contains b) = true
def PRE_first_tail_x6_r0_body.zl77 : List Nat := PRE_first_tail_x6_r0_body.cl77.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE77 : PRE_first_tail_x6_r0_body.zl77.map (fun a => PRE_first_tail_x6_r0_body.s748.heap.get (PRE_first_tail_x6_r0_body.kappa77.a a)) = PRE_first_tail_x6_r0_body.zl77.map (fun a => (PRE_first_tail_x6_r0_body.s749.heap.get a).map PRE_first_tail_x6_r0_body.kappa77.hobj)
theorem PRE_first_tail_x6_r0_body.zimg77 : HeapImg PRE_first_tail_x6_r0_body.kappa77 PRE_first_tail_x6_r0_body.s749 PRE_first_tail_x6_r0_body.s748 PRE_first_tail_x6_r0_body.zl77 := PRE_first_tail_x6_r0_body.zimgE77
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl77 : PRE_first_tail_x6_r0_body.s748.ctl = PRE_first_tail_x6_r0_body.kappa77.ctl PRE_first_tail_x6_r0_body.s749.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack77 : PRE_first_tail_x6_r0_body.s748.stack = PRE_first_tail_x6_r0_body.s749.stack.map PRE_first_tail_x6_r0_body.kappa77.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs77 : PRE_first_tail_x6_r0_body.s748.jobs = PRE_first_tail_x6_r0_body.s749.jobs.map PRE_first_tail_x6_r0_body.kappa77.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores77 : PRE_first_tail_x6_r0_body.s748.stores = PRE_first_tail_x6_r0_body.kappa77.stores PRE_first_tail_x6_r0_body.s749.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots77 : checkRootsSupp PRE_first_tail_x6_r0_body.s749 3346 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC77 : PRE_first_tail_x6_r0_body.S747.tab.length + PRE_first_tail_x6_r0_body.cws77.length = 3346
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap77 : PRE_first_tail_x6_r0_body.kappa77 = Conv.Map.compact PRE_first_tail_x6_r0_body.s747.next 2735010 PRE_first_tail_x6_r0_body.S747.tab.length PRE_first_tail_x6_r0_body.pl77 (PRE_first_tail_x6_r0_body.nr77.map NumV.ref) PRE_first_tail_x6_r0_body.kd77.big
  PRE_first_tail_x6_r0_body.kd77.region PRE_first_tail_x6_r0_body.kd77.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin77 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s749.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc77 : Conv.jcleanListB (⟨19712, 16807, 2735000, 3346⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s749 PRE_first_tail_x6_r0_body.cl77 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB77 : noBigRootsP (fun i => !Conv.oldBigB (⟨19712, 16807, 2735000, 3346⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s749.trace PRE_first_tail_x6_r0_body.s749 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm77 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 16807 = true
theorem PRE_first_tail_x6_r0_body.cjcl77 (h : Conv.JClean (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s747) : Conv.JClean (⟨19712, 16807, 2735000, 3346⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s749 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle77)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap77 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd77 a ha)) PRE_first_tail_x6_r0_body.zjc77

end Host.Load.Run.Tpl
end

section -- st77/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st77.bodyLast from PRE_first_tail_x6_r0_body.st77.s1 to PRE_first_tail_x6_r0_body.st77.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st77.F PRE_first_tail_x6_r0_body.st77.s1).run PRE_first_tail_x6_r0_body.st77.S1 = some (PRE_first_tail_x6_r0_body.st77.s2, PRE_first_tail_x6_r0_body.st77.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st77.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st77.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st77.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st77.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st77/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st77.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st77.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st77.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st77.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st77.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st77.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st77.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st77.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st77.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st77.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st77.s0 PRE_first_tail_x6_r0_body.st77.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st77.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st77.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st77.s1 PRE_first_tail_x6_r0_body.st77.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st77/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st77.bodyK0F from PRE_first_tail_x6_r0_body.st77.s0 to PRE_first_tail_x6_r0_body.st77.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st77.F (PRE_first_tail_x6_r0_body.st77.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st77.ks 0).getD 0) PRE_first_tail_x6_r0_body.st77.s0 PRE_first_tail_x6_r0_body.st77.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st77.s1, PRE_first_tail_x6_r0_body.st77.S1)
theorem PRE_first_tail_x6_r0_body.st77.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st77.F (PRE_first_tail_x6_r0_body.st77.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st77.ks 0).getD 0) PRE_first_tail_x6_r0_body.st77.s0 PRE_first_tail_x6_r0_body.st77.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st77.s1, PRE_first_tail_x6_r0_body.st77.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st77.bodyOkLN_ok PRE_first_tail_x6_r0_body.st77.bodyK0F
end Host.Load.Run.Tpl
end

section -- st77/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st77.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st77.F (PRE_first_tail_x6_r0_body.st77.bodyOkL bytes rows) 98 PRE_first_tail_x6_r0_body.st77.s0 PRE_first_tail_x6_r0_body.st77.S0 = some (PRE_first_tail_x6_r0_body.st77.s1, PRE_first_tail_x6_r0_body.st77.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st77.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st77.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st77.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st77.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st77.F (PRE_first_tail_x6_r0_body.st77.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st77.s0
  S0 := PRE_first_tail_x6_r0_body.st77.S0
  s1 := PRE_first_tail_x6_r0_body.st77.s1
  S1 := PRE_first_tail_x6_r0_body.st77.S1
  s2 := PRE_first_tail_x6_r0_body.st77.s2
  S2 := PRE_first_tail_x6_r0_body.st77.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st77.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st77.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st77.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st77.bodyHalt
  last := PRE_first_tail_x6_r0_body.st77.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st77.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC78
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 78 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s766` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa78` into the merged state
`PRE_first_tail_x6_r0_body.s765`. -/

def PRE_first_tail_x6_r0_body.pl78 : List Nat := [2737583, 2736758, 2737589, 2737585, 2736760, 2737591]
def PRE_first_tail_x6_r0_body.nr78 : List Nat := [3449, 3448, 3424, 3432, 3437, 3442, 3447, 3421, 3422, 3423, 3430, 3431, 3419, 3426, 3427, 3428, 3429, 3425]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd78 : RData :=
  ⟨2736477, 2737626, Stage.setAll PTrie.nil [(2736471, 2737583), (2736472, 2736758), (2736473, 2737589), (2736474, 2737585), (2736475, 2736760), (2736476, 2737591)], Stage.setAll PTrie.nil [(19746, 19772), (19747, 19750), (19748, 19773)],
   19749, 19774, 16853, 16853, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(3419, .ref 3449), (3420, .ref 3448), (3421, .ref 3424), (3422, .ref 3432), (3423, .ref 3437), (3424, .ref 3442), (3425, .ref 3447), (3426, .ref 3421), (3427, .ref 3422), (3428, .ref 3423), (3429, .ref 3430), (3430, .ref 3431), (3431, .ref 3419), (3432, .ref 3426), (3433, .ref 3427), (3434, .ref 3428), (3435, .ref 3429), (3436, .ref 3425)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa78 : Map :=
  Conv.Map.compact 2736471 2737626 3419 PRE_first_tail_x6_r0_body.pl78 (PRE_first_tail_x6_r0_body.nr78.map NumV.ref) PRE_first_tail_x6_r0_body.kd78.big
    PRE_first_tail_x6_r0_body.kd78.region PRE_first_tail_x6_r0_body.kd78.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws78 : List Nat := [2339, 2340, 2341, 2342, 2343, 2344, 2345, 2346, 2347, 2348, 2349, 2350, 2351, 2352, 2353, 2354, 2355, 2356]
noncomputable def PRE_first_tail_x6_r0_body.crs78 : List SymE := PRE_first_tail_x6_r0_body.nr78.map fun r => (nth? PRE_first_tail_x6_r0_body.S765.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta78 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws78 PRE_first_tail_x6_r0_body.crs78
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB78 : List Nat := [2665, 2672496, 2673467, 2735645, 2736190, 2736446]

kernel_rfl PRE_first_tail_x6_r0_body.ctab78 : PRE_first_tail_x6_r0_body.S766.tab = PRE_first_tail_x6_r0_body.S764.tab ++ PRE_first_tail_x6_r0_body.cws78.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace78 : PRE_first_tail_x6_r0_body.s766.trace = PRE_first_tail_x6_r0_body.s764.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext78 : PRE_first_tail_x6_r0_body.s766.next = 2736477
kernel_rfl PRE_first_tail_x6_r0_body.ccounters78 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s766.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s766.ffi).mlx.nnext) = (19749, 16853)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue78 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s765.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s766.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa78.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp78 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s766.ffi).mlx.tokens.all (bSN 3437) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean78 : Conv.cleanListB 19749 131072 (fun r => Nat.ble 78996 r) PRE_first_tail_x6_r0_body.s766
    (PRE_first_tail_x6_r0_body.wrB78 ++ (List.range 6).map (2736471 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs78 : bigsOutB 19749 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s766.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK78
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl78`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl78 : List Nat := [2665, 2672496, 2673467, 2735645, 2736190, 2736446, 2736471, 2736472, 2736473, 2736474, 2736475, 2736476]
def PRE_first_tail_x6_r0_body.clo78 : List Nat := [19726, 19739, 19745, 19746, 19747, 19748]
def PRE_first_tail_x6_r0_body.cln78 : List Nat := [16826, 16827, 16828, 16829, 16830, 16831, 16832, 16833, 16834, 16835, 16836, 16837, 16838, 16839, 16840, 16841, 16842, 16843, 16844, 16845, 16846, 16847, 16848, 16849, 16850, 16851, 16852]
def PRE_first_tail_x6_r0_body.cli78 : List Nat := [16826, 16827, 16828, 16829, 16830, 16831, 16832, 16833, 16834, 16835, 16836, 16837, 16838, 16839, 16840, 16841, 16842, 16843, 16844, 16845, 16846, 16847, 16848, 16849, 16850, 16851, 16852]
kernel_rfl PRE_first_tail_x6_r0_body.cheap78 : PRE_first_tail_x6_r0_body.s766.heap = Stage.setAll PRE_first_tail_x6_r0_body.s764.heap (PRE_first_tail_x6_r0_body.cl78.filterMap fun a => (PRE_first_tail_x6_r0_body.s766.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe78 : Nat.ble PRE_first_tail_x6_r0_body.s764.next PRE_first_tail_x6_r0_body.s766.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP78 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s764 PRE_first_tail_x6_r0_body.s766 PRE_first_tail_x6_r0_body.cl78 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp78 : Conv.suppListB PRE_first_tail_x6_r0_body.s766 3437 PRE_first_tail_x6_r0_body.cl78 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound78 : Conv.boundListB PRE_first_tail_x6_r0_body.s766 PRE_first_tail_x6_r0_body.cl78 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK78 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s766.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln78.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s766.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK78 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s766.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo78.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s766.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK78 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s766.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli78.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s766.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst78 : Conv.sstListB 3437 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s766.ffi).mlx PRE_first_tail_x6_r0_body.cln78 PRE_first_tail_x6_r0_body.clo78 PRE_first_tail_x6_r0_body.cli78 = true

end Host.Load.Run.Tpl
end

section -- SiteCl78
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA78 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s766.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo78.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s766.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd78 : (PRE_first_tail_x6_r0_body.clo78 ++ PRE_first_tail_x6_r0_body.cln78 ++ PRE_first_tail_x6_r0_body.cli78).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle78 : Conv.Cnt.leB (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt) (⟨19749, 16853, 2736477, 3437⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck78 : Conv.ncleanListB (⟨19749, 16853, 2736477, 3437⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s766.ffi).mlx PRE_first_tail_x6_r0_body.clo78 PRE_first_tail_x6_r0_body.cln78 PRE_first_tail_x6_r0_body.cli78 = true
theorem PRE_first_tail_x6_r0_body.cncl78 (h : Conv.NClean (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx) : Conv.NClean (⟨19749, 16853, 2736477, 3437⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s766.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle78 PRE_first_tail_x6_r0_body.ckA78 PRE_first_tail_x6_r0_body.cobjsK78 PRE_first_tail_x6_r0_body.cnodesK78 PRE_first_tail_x6_r0_body.citemsK78 PRE_first_tail_x6_r0_body.cbd78 PRE_first_tail_x6_r0_body.cck78

end Host.Load.Run.Tpl
end

section -- SiteS78
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 78 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc78 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P78 : LoadP := PRE_first_tail_x6_r0_body.Pc78.raise 16853
kernel_rfl PRE_first_tail_x6_r0_body.craise78 : Nat.ble PRE_first_tail_x6_r0_body.Pc78.N0 16853 = true
theorem PRE_first_tail_x6_r0_body.raised78 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc78 PRE_first_tail_x6_r0_body.P78 :=
  .inr ⟨16853, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise78, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_78 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s766.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_78 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s765.ffi)
def PRE_first_tail_x6_r0_body.khinv78 : PTrie Nat := Stage.setAll PTrie.nil [(19772, 19746), (19750, 19747), (19773, 19748)]
def PRE_first_tail_x6_r0_body.kninv78 : PTrie Nat := Stage.setAll PTrie.nil [(16826, 16826), (16827, 16827), (16828, 16828), (16829, 16829), (16830, 16830), (16831, 16831), (16832, 16832), (16833, 16833), (16834, 16834), (16835, 16835), (16836, 16836), (16837, 16837), (16838, 16838), (16839, 16839), (16840, 16840), (16841, 16841), (16842, 16842), (16843, 16843), (16844, 16844), (16845, 16845), (16846, 16846), (16847, 16847), (16848, 16848), (16849, 16849), (16850, 16850), (16851, 16851), (16852, 16852)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS78 : List Nat := [19726, 19739, 19745, 19746, 19747, 19748, 19749, 19750, 19751, 19752, 19753, 19754, 19755, 19756, 19757, 19758, 19759, 19760, 19761, 19762, 19763, 19764, 19765, 19766, 19767, 19768, 19769, 19770, 19771, 19772, 19773]
def PRE_first_tail_x6_r0_body.cnS78 : List Nat := List.range' 16826 27
def PRE_first_tail_x6_r0_body.ciS78 : List Nat := [] ++ List.range' 16826 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh078 : PRE_first_tail_x6_r0_body.kd78.nh0 = PRE_first_tail_x6_r0_body.cx0_78.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh178 : PRE_first_tail_x6_r0_body.kd78.nh1 = PRE_first_tail_x6_r0_body.cx1_78.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn078 : PRE_first_tail_x6_r0_body.kd78.nn0 = PRE_first_tail_x6_r0_body.cx0_78.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn178 : PRE_first_tail_x6_r0_body.kd78.nn1 = PRE_first_tail_x6_r0_body.cx1_78.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo78 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P78.lo && Nat.ble PRE_first_tail_x6_r0_body.P78.lo PRE_first_tail_x6_r0_body.cx0_78.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P78.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P78.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt78 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_78.mlx.next PRE_first_tail_x6_r0_body.cx1_78.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_78.mlx.nnext PRE_first_tail_x6_r0_body.cx1_78.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband78 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P78.NL && Nat.ble PRE_first_tail_x6_r0_body.P78.NL PRE_first_tail_x6_r0_body.P78.N0 && Nat.ble PRE_first_tail_x6_r0_body.P78.N0 PRE_first_tail_x6_r0_body.cx0_78.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow78 : PRE_first_tail_x6_r0_body.kd78.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren78 : checkRenG PRE_first_tail_x6_r0_body.kd78.hnd PRE_first_tail_x6_r0_body.khinv78 (phB PRE_first_tail_x6_r0_body.cx0_78.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband78 : PRE_first_tail_x6_r0_body.kd78.checkBand PRE_first_tail_x6_r0_body.P78.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos78 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd78.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren78 : checkRenG PRE_first_tail_x6_r0_body.kd78.node PRE_first_tail_x6_r0_body.kninv78 (pnB PRE_first_tail_x6_r0_body.cx0_78.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow78 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd78.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P78.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd78.nodeF j) PRE_first_tail_x6_r0_body.cx1_78.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a78 : PRE_first_tail_x6_r0_body.cx0_78.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b78 : PRE_first_tail_x6_r0_body.cx0_78.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok178 : PRE_first_tail_x6_r0_body.cx1_78.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend78 : PRE_first_tail_x6_r0_body.cx1_78.mlx.pending = PRE_first_tail_x6_r0_body.cx0_78.mlx.pending.map PRE_first_tail_x6_r0_body.kappa78.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh78 : PRE_first_tail_x6_r0_body.cx1_78.mlx.errh = PRE_first_tail_x6_r0_body.cx0_78.mlx.errh.map PRE_first_tail_x6_r0_body.kappa78.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles78 : PRE_first_tail_x6_r0_body.cx1_78.mlx.files = PRE_first_tail_x6_r0_body.cx0_78.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch78 : PRE_first_tail_x6_r0_body.cx1_78.mlx.arch = PRE_first_tail_x6_r0_body.cx0_78.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes78 : PRE_first_tail_x6_r0_body.cx1_78.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_78.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired78 : PRE_first_tail_x6_r0_body.cx1_78.mlx.wired = PRE_first_tail_x6_r0_body.cx0_78.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost78 : PRE_first_tail_x6_r0_body.cx1_78.host = PRE_first_tail_x6_r0_body.cx0_78.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd78`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn078 : PRE_first_tail_x6_r0_body.kd78.n0 = 2736477
kernel_rfl PRE_first_tail_x6_r0_body.ckn178 : PRE_first_tail_x6_r0_body.kd78.n1 = 2737626
kernel_rfl PRE_first_tail_x6_r0_body.ckheap78 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd78.heap).all (fun x => Nat.ble 2736471 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl78 : (List.range 6).all (fun j => decide (PRE_first_tail_x6_r0_body.kd78.heap.get (2736471 + j) = nth? PRE_first_tail_x6_r0_body.pl78 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja78 : Nat.ble 2736471 2736471 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn78 : Nat.ble 3419 3419 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD78 : Nat.ble 2736471 PRE_first_tail_x6_r0_body.kd78.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn78 : Nat.ble 19746 PRE_first_tail_x6_r0_body.kd78.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn78 : Nat.ble 16826 PRE_first_tail_x6_r0_body.kd78.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb78 : Nat.ble 19746 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap78 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd78.heap).all (Nat.ble (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd78 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd78.hnd).all (Nat.ble (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode78 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd78.node).all (Nat.ble (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix78 : Conv.FixOld (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa78 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja78) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn78) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD78) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn78) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn78) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb78) PRE_first_tail_x6_r0_body.fheap78 PRE_first_tail_x6_r0_body.fhnd78 PRE_first_tail_x6_r0_body.fnode78
kernel_rfl PRE_first_tail_x6_r0_body.fcxn78 : (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn78 : (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle078 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_78.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_78.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk78 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd78.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A78 : PRE_first_tail_x6_r0_body.cx1_78.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS78.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_78.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O78 : PRE_first_tail_x6_r0_body.cx1_78.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS78.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_78.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N78 : PRE_first_tail_x6_r0_body.cx1_78.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS78.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_78.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I78 : PRE_first_tail_x6_r0_body.cx1_78.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS78.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_78.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd78 : (PRE_first_tail_x6_r0_body.clo78 ++ PRE_first_tail_x6_r0_body.cln78 ++ PRE_first_tail_x6_r0_body.cli78 ++ PRE_first_tail_x6_r0_body.cwS78 ++ PRE_first_tail_x6_r0_body.cnS78 ++ PRE_first_tail_x6_r0_body.ciS78).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW78 : PRE_first_tail_x6_r0_body.cwS78.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo78.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI78 : PRE_first_tail_x6_r0_body.ciS78.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli78.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN78 : PRE_first_tail_x6_r0_body.cnS78.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF78 : PRE_first_tail_x6_r0_body.cln78.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh78 : PRE_first_tail_x6_r0_body.clo78.all (handleOK PRE_first_tail_x6_r0_body.kappa78 PRE_first_tail_x6_r0_body.P78.lo PRE_first_tail_x6_r0_body.cx0_78.mlx PRE_first_tail_x6_r0_body.cx1_78.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo78 : PRE_first_tail_x6_r0_body.clo78.map (fun h => PRE_first_tail_x6_r0_body.cx1_78.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa78.handle h)) = PRE_first_tail_x6_r0_body.clo78.map (fun h => (PRE_first_tail_x6_r0_body.cx0_78.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa78.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok78 : PRE_first_tail_x6_r0_body.clo78.all (objOK PRE_first_tail_x6_r0_body.kappa78 PRE_first_tail_x6_r0_body.P78.NL PRE_first_tail_x6_r0_body.cx0_78.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd78 : PRE_first_tail_x6_r0_body.cln78.all (nodeOKF PRE_first_tail_x6_r0_body.kappa78 PRE_first_tail_x6_r0_body.P78 PRE_first_tail_x6_r0_body.cx0_78.mlx PRE_first_tail_x6_r0_body.cx1_78.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp78 : ((PRE_first_tail_x6_r0_body.cln78.filter (fullB PRE_first_tail_x6_r0_body.P78))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_78.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa78.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln78.filter (fullB PRE_first_tail_x6_r0_body.P78))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_78.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa78.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI78 : incrB PRE_first_tail_x6_r0_body.kd78.nodeF (List.range' 16826 27) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK78 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd78.node).all (fun k => Nat.ble 16826 k && Nat.blt k 16853) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL78 : (PRE_first_tail_x6_r0_body.cln78.filter (Nat.ble PRE_first_tail_x6_r0_body.P78.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd78.nodeF i) && (Nat.blt i 16853 || Nat.ble PRE_first_tail_x6_r0_body.kd78.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord78 : (PRE_first_tail_x6_r0_body.cln78.filter (Nat.ble PRE_first_tail_x6_r0_body.P78.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd78.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd78.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd78.nodeF j) (PRE_first_tail_x6_r0_body.kd78.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow78 PRE_first_tail_x6_r0_body.cnn178 PRE_first_tail_x6_r0_body.fnordI78 PRE_first_tail_x6_r0_body.fnordK78 PRE_first_tail_x6_r0_body.fnordL78
kernel_rfl PRE_first_tail_x6_r0_body.fi78 : PRE_first_tail_x6_r0_body.cli78.all (pnB PRE_first_tail_x6_r0_body.cx0_78.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii78 : PRE_first_tail_x6_r0_body.cli78.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_78.mlx.items.get (PRE_first_tail_x6_r0_body.kappa78.node k) = (PRE_first_tail_x6_r0_body.cx0_78.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa78.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot78 (clean : Conv.NClean (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P78.NL) (cl : SSt (· < 3437) PRE_first_tail_x6_r0_body.cx0_78.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P78 3437 PRE_first_tail_x6_r0_body.kappa78 PRE_first_tail_x6_r0_body.kd78 PRE_first_tail_x6_r0_body.khinv78 PRE_first_tail_x6_r0_body.kninv78 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx PRE_first_tail_x6_r0_body.cx0_78.mlx PRE_first_tail_x6_r0_body.cx1_78.mlx (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo78 PRE_first_tail_x6_r0_body.cln78 PRE_first_tail_x6_r0_body.cli78 PRE_first_tail_x6_r0_body.cwS78 PRE_first_tail_x6_r0_body.cnS78 PRE_first_tail_x6_r0_body.ciS78 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh078, PRE_first_tail_x6_r0_body.cnh178, PRE_first_tail_x6_r0_body.cnn078, PRE_first_tail_x6_r0_body.cnn178, PRE_first_tail_x6_r0_body.cplo78, PRE_first_tail_x6_r0_body.ccnt78, PRE_first_tail_x6_r0_body.cnband78, PRE_first_tail_x6_r0_body.chbelow78, PRE_first_tail_x6_r0_body.chren78, PRE_first_tail_x6_r0_body.cband78, PRE_first_tail_x6_r0_body.cnh1pos78, PRE_first_tail_x6_r0_body.cnren78, PRE_first_tail_x6_r0_body.cnlow78, PRE_first_tail_x6_r0_body.cabs0a78, PRE_first_tail_x6_r0_body.cabs0b78, PRE_first_tail_x6_r0_body.ctok178, PRE_first_tail_x6_r0_body.cpend78, PRE_first_tail_x6_r0_body.cerrh78, PRE_first_tail_x6_r0_body.cfiles78, PRE_first_tail_x6_r0_body.carch78, PRE_first_tail_x6_r0_body.csizes78, PRE_first_tail_x6_r0_body.cwired78, PRE_first_tail_x6_r0_body.cfix78, clean, PRE_first_tail_x6_r0_body.fcxn78, PRE_first_tail_x6_r0_body.fcnn78, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle078, PRE_first_tail_x6_r0_body.fnk78, PRE_first_tail_x6_r0_body.ckA78, PRE_first_tail_x6_r0_body.cobjsK78, PRE_first_tail_x6_r0_body.cnodesK78, PRE_first_tail_x6_r0_body.citemsK78, PRE_first_tail_x6_r0_body.f1A78, PRE_first_tail_x6_r0_body.f1O78, PRE_first_tail_x6_r0_body.f1N78, PRE_first_tail_x6_r0_body.f1I78, PRE_first_tail_x6_r0_body.fbd78, PRE_first_tail_x6_r0_body.fincW78, PRE_first_tail_x6_r0_body.fincI78, PRE_first_tail_x6_r0_body.fincN78, PRE_first_tail_x6_r0_body.flnF78, PRE_first_tail_x6_r0_body.fh78, PRE_first_tail_x6_r0_body.fo78, PRE_first_tail_x6_r0_body.fok78, PRE_first_tail_x6_r0_body.fnd78, PRE_first_tail_x6_r0_body.fp78, PRE_first_tail_x6_r0_body.fnord78, PRE_first_tail_x6_r0_body.fi78, PRE_first_tail_x6_r0_body.fii78⟩
theorem PRE_first_tail_x6_r0_body.cnshift78 (clean : Conv.NClean (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P78.NL) (cl : SSt (· < 3437) PRE_first_tail_x6_r0_body.cx0_78.mlx) : NShift PRE_first_tail_x6_r0_body.P78 3437 PRE_first_tail_x6_r0_body.kappa78 PRE_first_tail_x6_r0_body.cx0_78 PRE_first_tail_x6_r0_body.cx1_78 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot78 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost78 (compact_a_eq PRE_first_tail_x6_r0_body.ckn078 PRE_first_tail_x6_r0_body.ckn178 PRE_first_tail_x6_r0_body.ckheap78 PRE_first_tail_x6_r0_body.ckpl78)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_78 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s764.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_78 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s764.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_78 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s764.ffi) = some PRE_first_tail_x6_r0_body.fxC_78
kernel_rfl PRE_first_tail_x6_r0_body.okrC_78 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s764.ffi) = some PRE_first_tail_x6_r0_body.krC_78
noncomputable def PRE_first_tail_x6_r0_body.fx0_78 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s766.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_78 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s766.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_78 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s766.ffi) = some PRE_first_tail_x6_r0_body.fx0_78
kernel_rfl PRE_first_tail_x6_r0_body.okr0_78 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s766.ffi) = some PRE_first_tail_x6_r0_body.kr0_78
noncomputable def PRE_first_tail_x6_r0_body.fx1_78 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s765.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_78 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s765.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_78 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s765.ffi) = some PRE_first_tail_x6_r0_body.fx1_78
kernel_rfl PRE_first_tail_x6_r0_body.okr1_78 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s765.ffi) = some PRE_first_tail_x6_r0_body.kr1_78
kernel_rfl PRE_first_tail_x6_r0_body.ff078 : PRE_first_tail_x6_r0_body.fx0_78 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_78 (PRE_first_tail_x6_r0_body.clo78.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_78.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff178 : PRE_first_tail_x6_r0_body.fx1_78 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_78 (PRE_first_tail_x6_r0_body.cwS78.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_78.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck78 : freedLB PRE_first_tail_x6_r0_body.kappa78 PRE_first_tail_x6_r0_body.cx0_78.mlx PRE_first_tail_x6_r0_body.fx0_78 PRE_first_tail_x6_r0_body.fx1_78 PRE_first_tail_x6_r0_body.clo78 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf078 : PRE_first_tail_x6_r0_body.kr0_78.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_78.flags (PRE_first_tail_x6_r0_body.clo78.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_78.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt078 : PRE_first_tail_x6_r0_body.kr0_78.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_78.targs (PRE_first_tail_x6_r0_body.clo78.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_78.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf178 : PRE_first_tail_x6_r0_body.kr1_78.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_78.flags (PRE_first_tail_x6_r0_body.cwS78.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_78.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt178 : PRE_first_tail_x6_r0_body.kr1_78.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_78.targs (PRE_first_tail_x6_r0_body.cwS78.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_78.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck78 : krecLB PRE_first_tail_x6_r0_body.kappa78 3437 PRE_first_tail_x6_r0_body.cx0_78.mlx PRE_first_tail_x6_r0_body.kr0_78 PRE_first_tail_x6_r0_body.kr1_78 PRE_first_tail_x6_r0_body.clo78 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn78 : Nat.ble 3419 3437 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge78 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s765.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s766.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR78 : pendRegB PRE_first_tail_x6_r0_body.kappa78 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s766.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe78 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s766.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s765.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift78 (clean : Conv.NClean (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P78.NL) (cl : SSt (· < 3437) PRE_first_tail_x6_r0_body.cx0_78.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_78.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_78.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_78.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s764.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_78.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P78 3437 PRE_first_tail_x6_r0_body.kappa78 PRE_first_tail_x6_r0_body.s766.ffi PRE_first_tail_x6_r0_body.s765.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift78 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue78, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp78 t ht),
    PRE_first_tail_x6_r0_body.cbridge78,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s766.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s765.ffi) (PRE_first_tail_x6_r0_body.cfoot78 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_78 PRE_first_tail_x6_r0_body.ofx1_78 hobjC PRE_first_tail_x6_r0_body.ff078 PRE_first_tail_x6_r0_body.ff178 PRE_first_tail_x6_r0_body.ffck78,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s766.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s765.ffi) (PRE_first_tail_x6_r0_body.cfoot78 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_78 PRE_first_tail_x6_r0_body.okr1_78 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn78) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf078 PRE_first_tail_x6_r0_body.fkt078 PRE_first_tail_x6_r0_body.fkf178 PRE_first_tail_x6_r0_body.fkt178 PRE_first_tail_x6_r0_body.fkck78,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh078 PRE_first_tail_x6_r0_body.cnh178 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe78) PRE_first_tail_x6_r0_body.cpendR78⟩

end Host.Load.Run.Tpl
end

section -- st78/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st78 0
host_stream_state PRE_first_tail_x6_r0_body.st78 1
host_stream_state PRE_first_tail_x6_r0_body.st78 2
host_stream_state PRE_first_tail_x6_r0_body.st78 3
host_stream_state PRE_first_tail_x6_r0_body.st78 4
host_stream_state PRE_first_tail_x6_r0_body.st78 5
end Host.Load.Run.Tpl
end

section -- Site78
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 78 of chain `PRE_first_tail_x6_r0_body`: `ssmW__g78__g79` (`recurWindow`), the call state `PRE_first_tail_x6_r0_body.s764`, the merged state `PRE_first_tail_x6_r0_body.s765`,
the site template `PRE_first_tail_x6_r0_body.st78` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s766`: the merge.
The footprint's facts are in `SiteF78`, the compaction's in `SiteC78`, `SiteK78`, `SiteNa78`, `SiteNb78`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso78 : PRE_first_tail_x6_r0_body.st78.s0 = { PRE_first_tail_x6_r0_body.s764 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs78 : List Frame := PRE_first_tail_x6_r0_body.s764.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_78 : PRE_first_tail_x6_r0_body.S764.tab.length = 3419
kernel_rfl PRE_first_tail_x6_r0_body.tab0_78 : PRE_first_tail_x6_r0_body.st78.S0.tab = PRE_first_tail_x6_r0_body.S764.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws78 : List Nat := [2308, 2309, 2310, 2311, 2312, 2313, 2314, 2315, 2316, 2317, 2318, 2319, 2320, 2321, 2322, 2323, 2324, 2325, 2326, 2327, 2328, 2329, 2330, 2331, 2332, 2333, 2334, 2335, 2336, 2337, 2338]
kernel_rfl PRE_first_tail_x6_r0_body.fresh78 : (PRE_first_tail_x6_r0_body.S764.tab.all fun e => PRE_first_tail_x6_r0_body.ws78.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S764.oracle.all fun q => PRE_first_tail_x6_r0_body.ws78.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab78 : PRE_first_tail_x6_r0_body.S765.tab = PRE_first_tail_x6_r0_body.S764.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws78
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen78 : PRE_first_tail_x6_r0_body.st78.S5.tab.length - PRE_first_tail_x6_r0_body.st78.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged78`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap78 : PRE_first_tail_x6_r0_body.s765.heap = PRE_first_tail_x6_r0_body.st78.s5.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext78 : PRE_first_tail_x6_r0_body.s765.next = PRE_first_tail_x6_r0_body.st78.s5.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl78 : PRE_first_tail_x6_r0_body.s765.ctl = PRE_first_tail_x6_r0_body.st78.s5.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack78 : PRE_first_tail_x6_r0_body.s765.stack = PRE_first_tail_x6_r0_body.st78.s5.stack ++ PRE_first_tail_x6_r0_body.s764.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs78 : PRE_first_tail_x6_r0_body.s765.jobs = PRE_first_tail_x6_r0_body.st78.s5.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi78 : PRE_first_tail_x6_r0_body.s765.ffi = PRE_first_tail_x6_r0_body.st78.s5.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace78 : PRE_first_tail_x6_r0_body.s765.trace = PRE_first_tail_x6_r0_body.st78.s5.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores78 : PRE_first_tail_x6_r0_body.s765.stores = PRE_first_tail_x6_r0_body.st78.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD78
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 78 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived78 : PRE_first_tail_x6_r0_body.nr78.map (fun r => nth? PRE_first_tail_x6_r0_body.st78.S5.tab r) =
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
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo78 : PRE_first_tail_x6_r0_body.nr78.all (Nat.ble 3419) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj78 : PRE_first_tail_x6_r0_body.cws78.all (fun c => !PRE_first_tail_x6_r0_body.ws78.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ78 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws78 PRE_first_tail_x6_r0_body.crs78 PRE_first_tail_x6_r0_body.ws78

end Host.Load.Run.Tpl
end

section -- st78/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st78`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st78.wrR : List (Nat × Nat) := [(2672496, 2672497), (2735645, 2735646), (2736190, 2736191), (2736446, 2736447)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st78.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st78.s5.heap PRE_first_tail_x6_r0_body.st78.wrR ++ freshOf PRE_first_tail_x6_r0_body.st78.s5.heap PRE_first_tail_x6_r0_body.st78.s0.next PRE_first_tail_x6_r0_body.st78.s5.next
noncomputable def PRE_first_tail_x6_r0_body.st78.wr : List Nat := PRE_first_tail_x6_r0_body.st78.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st78.heapFoot : PRE_first_tail_x6_r0_body.st78.s5.heap = setAll PRE_first_tail_x6_r0_body.st78.s0.heap PRE_first_tail_x6_r0_body.st78.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st78.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st78.s0.next PRE_first_tail_x6_r0_body.st78.s5.next = true
theorem PRE_first_tail_x6_r0_body.st78.grows : PRE_first_tail_x6_r0_body.st78.s0.next ≤ PRE_first_tail_x6_r0_body.st78.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st78.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st78.wh : List Nat := [19726, 19739, 19745, 19746, 19747, 19748, 19749, 19750, 19751, 19752, 19753, 19754, 19755, 19756, 19757, 19758, 19759, 19760, 19761, 19762, 19763, 19764, 19765, 19766, 19767, 19768, 19769, 19770, 19771, 19772, 19773]
def PRE_first_tail_x6_r0_body.st78.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st78.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st78.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st78.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st78.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st78.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st78.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st78.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st78.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st78.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st78.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st78.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st78.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st78.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st78.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st78.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st78.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st78.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st78.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st78.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st78.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st78.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st78.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st78.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st78.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st78.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st78.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st78.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st78.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st78.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF78
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 78 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB78 : nodupT PRE_first_tail_x6_r0_body.st78.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup78 : PRE_first_tail_x6_r0_body.st78.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB78).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB78 : PRE_first_tail_x6_r0_body.st78.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound78 : ∀ b ∈ PRE_first_tail_x6_r0_body.st78.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB78 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr78 := PRE_first_tail_x6_r0_body.st78.s5.trace.take 120
kernel_rfl PRE_first_tail_x6_r0_body.traceEq78 : PRE_first_tail_x6_r0_body.st78.s5.trace = PRE_first_tail_x6_r0_body.trFr78 ++ PRE_first_tail_x6_r0_body.st78.s0.trace
theorem PRE_first_tail_x6_r0_body.trace78 : ∃ fr, PRE_first_tail_x6_r0_body.st78.s5.trace = fr ++ PRE_first_tail_x6_r0_body.st78.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq78⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide78 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB78 : (PRE_first_tail_x6_r0_body.wide78.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st78.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix78 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide78, WFix Map.id (Present PRE_first_tail_x6_r0_body.st78.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB78 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL78
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 78 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s765`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO78 : PRE_first_tail_x6_r0_body.st78.S0.oracle = PRE_first_tail_x6_r0_body.st78.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B78 : PRE_first_tail_x6_r0_body.st78.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st78.s0.next || (PRE_first_tail_x6_r0_body.st78.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot78 : Conv.StageFoot PRE_first_tail_x6_r0_body.st78.wr PRE_first_tail_x6_r0_body.st78.s0 PRE_first_tail_x6_r0_body.st78.s5 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st78.heapFoot PRE_first_tail_x6_r0_body.wrNodup78 PRE_first_tail_x6_r0_body.wrBound78 PRE_first_tail_x6_r0_body.wr0B78 PRE_first_tail_x6_r0_body.st78.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged78 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st78.F.S → PRE_first_tail_x6_r0_body.st78.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st78.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st78.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs78 PRE_first_tail_x6_r0_body.st78.wr PRE_first_tail_x6_r0_body.s764 PRE_first_tail_x6_r0_body.st78.s5 PRE_first_tail_x6_r0_body.st78.s0
      PRE_first_tail_x6_r0_body.st78.s5.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st78.F FR W stk M ν K PRE_first_tail_x6_r0_body.s765 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso78 PRE_first_tail_x6_r0_body.stFoot78 PRE_first_tail_x6_r0_body.wrNodup78 PRE_first_tail_x6_r0_body.wrBound78 PRE_first_tail_x6_r0_body.trace78 PRE_first_tail_x6_r0_body.mheap78
    PRE_first_tail_x6_r0_body.mnext78 PRE_first_tail_x6_r0_body.mctl78 PRE_first_tail_x6_r0_body.mstack78 PRE_first_tail_x6_r0_body.mjobs78 PRE_first_tail_x6_r0_body.mffi78 PRE_first_tail_x6_r0_body.mtrace78 PRE_first_tail_x6_r0_body.mstores78 h

def PRE_first_tail_x6_r0_body.arrEl78_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE78_2665 : arrOf PRE_first_tail_x6_r0_body.s765 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl78_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA78_2665 : isArrB PRE_first_tail_x6_r0_body.s765 2665 = true
theorem PRE_first_tail_x6_r0_body.arr78_2665 : ∃ o, PRE_first_tail_x6_r0_body.s765.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl78_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE78_2665 PRE_first_tail_x6_r0_body.arrA78_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN78_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl78_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR78_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl78_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN78_2665

def PRE_first_tail_x6_r0_body.arrEl78_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE78_2673467 : arrOf PRE_first_tail_x6_r0_body.s765 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl78_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA78_2673467 : isArrB PRE_first_tail_x6_r0_body.s765 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr78_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s765.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl78_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE78_2673467 PRE_first_tail_x6_r0_body.arrA78_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN78_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl78_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR78_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl78_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN78_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k78 : isArrB PRE_first_tail_x6_r0_body.s765 4910 = false
theorem PRE_first_tail_x6_r0_body.keep78 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s765 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k78 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr78_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl78_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ78
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 78 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s764`, the merged
state `PRE_first_tail_x6_r0_body.s765`, the canonical state `PRE_first_tail_x6_r0_body.s766`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl78 : PRE_first_tail_x6_r0_body.pl78.all (Nat.ble PRE_first_tail_x6_r0_body.s764.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd78 : nodupT PRE_first_tail_x6_r0_body.pl78 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn178 : Nat.ble PRE_first_tail_x6_r0_body.s764.next 2737626 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst78 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s764.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn78 : PRE_first_tail_x6_r0_body.s766.next = PRE_first_tail_x6_r0_body.s764.next + PRE_first_tail_x6_r0_body.pl78.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn78 : PRE_first_tail_x6_r0_body.s765.next = 2737626
kernel_rfl PRE_first_tail_x6_r0_body.zgrow78 : Nat.ble PRE_first_tail_x6_r0_body.s766.next PRE_first_tail_x6_r0_body.s765.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh78 : PRE_first_tail_x6_r0_body.S764.tab.all (fun e => PRE_first_tail_x6_r0_body.cws78.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd78 : nodupT PRE_first_tail_x6_r0_body.cws78 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi78 : PRE_first_tail_x6_r0_body.nr78.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S765.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt78 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s764.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg78_2665 : PRE_first_tail_x6_r0_body.s766.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s766 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk78_2665 : (objOf PRE_first_tail_x6_r0_body.s766 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm78_2665 : PRE_first_tail_x6_r0_body.s765.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa78.obj (objOf PRE_first_tail_x6_r0_body.s766 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s765 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg78_2673467 : PRE_first_tail_x6_r0_body.s766.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s766 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk78_2673467 : (objOf PRE_first_tail_x6_r0_body.s766 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm78_2673467 : PRE_first_tail_x6_r0_body.s765.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa78.obj (objOf PRE_first_tail_x6_r0_body.s766 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s765 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw78_4910 : (PRE_first_tail_x6_r0_body.s766.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw78_2673472 : (PRE_first_tail_x6_r0_body.s766.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw78_2673473 : (PRE_first_tail_x6_r0_body.s766.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd78 : PRE_first_tail_x6_r0_body.cl78.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr78 : PRE_first_tail_x6_r0_body.st78.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s764.next || PRE_first_tail_x6_r0_body.cl78.contains b) = true
def PRE_first_tail_x6_r0_body.zl78 : List Nat := PRE_first_tail_x6_r0_body.cl78.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE78 : PRE_first_tail_x6_r0_body.zl78.map (fun a => PRE_first_tail_x6_r0_body.s765.heap.get (PRE_first_tail_x6_r0_body.kappa78.a a)) = PRE_first_tail_x6_r0_body.zl78.map (fun a => (PRE_first_tail_x6_r0_body.s766.heap.get a).map PRE_first_tail_x6_r0_body.kappa78.hobj)
theorem PRE_first_tail_x6_r0_body.zimg78 : HeapImg PRE_first_tail_x6_r0_body.kappa78 PRE_first_tail_x6_r0_body.s766 PRE_first_tail_x6_r0_body.s765 PRE_first_tail_x6_r0_body.zl78 := PRE_first_tail_x6_r0_body.zimgE78
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl78 : PRE_first_tail_x6_r0_body.s765.ctl = PRE_first_tail_x6_r0_body.kappa78.ctl PRE_first_tail_x6_r0_body.s766.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack78 : PRE_first_tail_x6_r0_body.s765.stack = PRE_first_tail_x6_r0_body.s766.stack.map PRE_first_tail_x6_r0_body.kappa78.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs78 : PRE_first_tail_x6_r0_body.s765.jobs = PRE_first_tail_x6_r0_body.s766.jobs.map PRE_first_tail_x6_r0_body.kappa78.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores78 : PRE_first_tail_x6_r0_body.s765.stores = PRE_first_tail_x6_r0_body.kappa78.stores PRE_first_tail_x6_r0_body.s766.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots78 : checkRootsSupp PRE_first_tail_x6_r0_body.s766 3437 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC78 : PRE_first_tail_x6_r0_body.S764.tab.length + PRE_first_tail_x6_r0_body.cws78.length = 3437
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap78 : PRE_first_tail_x6_r0_body.kappa78 = Conv.Map.compact PRE_first_tail_x6_r0_body.s764.next 2737626 PRE_first_tail_x6_r0_body.S764.tab.length PRE_first_tail_x6_r0_body.pl78 (PRE_first_tail_x6_r0_body.nr78.map NumV.ref) PRE_first_tail_x6_r0_body.kd78.big
  PRE_first_tail_x6_r0_body.kd78.region PRE_first_tail_x6_r0_body.kd78.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin78 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s766.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc78 : Conv.jcleanListB (⟨19749, 16853, 2736477, 3437⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s766 PRE_first_tail_x6_r0_body.cl78 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB78 : noBigRootsP (fun i => !Conv.oldBigB (⟨19749, 16853, 2736477, 3437⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s766.trace PRE_first_tail_x6_r0_body.s766 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm78 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 16826 = true
theorem PRE_first_tail_x6_r0_body.cjcl78 (h : Conv.JClean (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s764) : Conv.JClean (⟨19749, 16853, 2736477, 3437⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s766 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle78)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap78 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd78 a ha)) PRE_first_tail_x6_r0_body.zjc78

end Host.Load.Run.Tpl
end

section -- st78/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st78.bodyLast from PRE_first_tail_x6_r0_body.st78.s4 to PRE_first_tail_x6_r0_body.st78.s5 :
  interpS (step PRE_first_tail_x6_r0_body.st78.F PRE_first_tail_x6_r0_body.st78.s4).run PRE_first_tail_x6_r0_body.st78.S4 = some (PRE_first_tail_x6_r0_body.st78.s5, PRE_first_tail_x6_r0_body.st78.S5)
kernel_rfl PRE_first_tail_x6_r0_body.st78.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st78.s4.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st78.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st78.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st78/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st78.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st78.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st78.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st78.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st78.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st78.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st78.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st78.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st78.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st78.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st78.s0 PRE_first_tail_x6_r0_body.st78.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st78.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st78.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st78.s4 PRE_first_tail_x6_r0_body.st78.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st78/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st78.bodyK0F from PRE_first_tail_x6_r0_body.st78.s0 to PRE_first_tail_x6_r0_body.st78.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st78.F (PRE_first_tail_x6_r0_body.st78.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st78.ks 0).getD 0) PRE_first_tail_x6_r0_body.st78.s0 PRE_first_tail_x6_r0_body.st78.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st78.s1, PRE_first_tail_x6_r0_body.st78.S1)
theorem PRE_first_tail_x6_r0_body.st78.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st78.F (PRE_first_tail_x6_r0_body.st78.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st78.ks 0).getD 0) PRE_first_tail_x6_r0_body.st78.s0 PRE_first_tail_x6_r0_body.st78.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st78.s1, PRE_first_tail_x6_r0_body.st78.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st78.bodyOkLN_ok PRE_first_tail_x6_r0_body.st78.bodyK0F
end Host.Load.Run.Tpl
end

section -- st78/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st78.bodyK1F from PRE_first_tail_x6_r0_body.st78.s1 to PRE_first_tail_x6_r0_body.st78.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st78.F (PRE_first_tail_x6_r0_body.st78.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st78.ks 1).getD 0) PRE_first_tail_x6_r0_body.st78.s1 PRE_first_tail_x6_r0_body.st78.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st78.s2, PRE_first_tail_x6_r0_body.st78.S2)
theorem PRE_first_tail_x6_r0_body.st78.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st78.F (PRE_first_tail_x6_r0_body.st78.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st78.ks 1).getD 0) PRE_first_tail_x6_r0_body.st78.s1 PRE_first_tail_x6_r0_body.st78.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st78.s2, PRE_first_tail_x6_r0_body.st78.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st78.bodyOkLN_ok PRE_first_tail_x6_r0_body.st78.bodyK1F
end Host.Load.Run.Tpl
end

section -- st78/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st78.bodyK2F from PRE_first_tail_x6_r0_body.st78.s2 to PRE_first_tail_x6_r0_body.st78.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st78.F (PRE_first_tail_x6_r0_body.st78.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st78.ks 2).getD 0) PRE_first_tail_x6_r0_body.st78.s2 PRE_first_tail_x6_r0_body.st78.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st78.s3, PRE_first_tail_x6_r0_body.st78.S3)
theorem PRE_first_tail_x6_r0_body.st78.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st78.F (PRE_first_tail_x6_r0_body.st78.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st78.ks 2).getD 0) PRE_first_tail_x6_r0_body.st78.s2 PRE_first_tail_x6_r0_body.st78.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st78.s3, PRE_first_tail_x6_r0_body.st78.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st78.bodyOkLN_ok PRE_first_tail_x6_r0_body.st78.bodyK2F
end Host.Load.Run.Tpl
end

section -- st78/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st78.bodyK3F from PRE_first_tail_x6_r0_body.st78.s3 to PRE_first_tail_x6_r0_body.st78.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st78.F (PRE_first_tail_x6_r0_body.st78.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st78.ks 3).getD 0) PRE_first_tail_x6_r0_body.st78.s3 PRE_first_tail_x6_r0_body.st78.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st78.s4, PRE_first_tail_x6_r0_body.st78.S4)
theorem PRE_first_tail_x6_r0_body.st78.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st78.F (PRE_first_tail_x6_r0_body.st78.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st78.ks 3).getD 0) PRE_first_tail_x6_r0_body.st78.s3 PRE_first_tail_x6_r0_body.st78.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st78.s4, PRE_first_tail_x6_r0_body.st78.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st78.bodyOkLN_ok PRE_first_tail_x6_r0_body.st78.bodyK3F
end Host.Load.Run.Tpl
end

section -- st78/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st78.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st78.F (PRE_first_tail_x6_r0_body.st78.bodyOkL bytes rows) 11334 PRE_first_tail_x6_r0_body.st78.s0 PRE_first_tail_x6_r0_body.st78.S0 = some (PRE_first_tail_x6_r0_body.st78.s4, PRE_first_tail_x6_r0_body.st78.S4) :=
  runOk_trans PRE_first_tail_x6_r0_body.st78.F (PRE_first_tail_x6_r0_body.st78.bodyOkL bytes rows) ((((nth? PRE_first_tail_x6_r0_body.st78.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st78.ks 1).getD 0)) + ((nth? PRE_first_tail_x6_r0_body.st78.ks 2).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st78.ks 3).getD 0) PRE_first_tail_x6_r0_body.st78.s0 PRE_first_tail_x6_r0_body.st78.s3 PRE_first_tail_x6_r0_body.st78.s4 PRE_first_tail_x6_r0_body.st78.S0 PRE_first_tail_x6_r0_body.st78.S3 PRE_first_tail_x6_r0_body.st78.S4 (runOk_trans PRE_first_tail_x6_r0_body.st78.F (PRE_first_tail_x6_r0_body.st78.bodyOkL bytes rows) (((nth? PRE_first_tail_x6_r0_body.st78.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st78.ks 1).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st78.ks 2).getD 0) PRE_first_tail_x6_r0_body.st78.s0 PRE_first_tail_x6_r0_body.st78.s2 PRE_first_tail_x6_r0_body.st78.s3 PRE_first_tail_x6_r0_body.st78.S0 PRE_first_tail_x6_r0_body.st78.S2 PRE_first_tail_x6_r0_body.st78.S3 (runOk_trans PRE_first_tail_x6_r0_body.st78.F (PRE_first_tail_x6_r0_body.st78.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st78.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st78.ks 1).getD 0) PRE_first_tail_x6_r0_body.st78.s0 PRE_first_tail_x6_r0_body.st78.s1 PRE_first_tail_x6_r0_body.st78.s2 PRE_first_tail_x6_r0_body.st78.S0 PRE_first_tail_x6_r0_body.st78.S1 PRE_first_tail_x6_r0_body.st78.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st78.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st78.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st78.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st78.bodyK3 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st78.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st78.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st78.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st78.F (PRE_first_tail_x6_r0_body.st78.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st78.s0
  S0 := PRE_first_tail_x6_r0_body.st78.S0
  s1 := PRE_first_tail_x6_r0_body.st78.s4
  S1 := PRE_first_tail_x6_r0_body.st78.S4
  s2 := PRE_first_tail_x6_r0_body.st78.s5
  S2 := PRE_first_tail_x6_r0_body.st78.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st78.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st78.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st78.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st78.bodyHalt
  last := PRE_first_tail_x6_r0_body.st78.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st78.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC79
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 79 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s774` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa79` into the merged state
`PRE_first_tail_x6_r0_body.s773`. -/

def PRE_first_tail_x6_r0_body.pl79 : List Nat := []
def PRE_first_tail_x6_r0_body.nr79 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd79 : RData :=
  ⟨2736967, 2736969, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19762, 19762, 16866, 16866, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa79 : Map :=
  Conv.Map.compact 2736967 2736969 3458 PRE_first_tail_x6_r0_body.pl79 (PRE_first_tail_x6_r0_body.nr79.map NumV.ref) PRE_first_tail_x6_r0_body.kd79.big
    PRE_first_tail_x6_r0_body.kd79.region PRE_first_tail_x6_r0_body.kd79.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws79 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs79 : List SymE := PRE_first_tail_x6_r0_body.nr79.map fun r => (nth? PRE_first_tail_x6_r0_body.S773.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta79 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws79 PRE_first_tail_x6_r0_body.crs79
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB79 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab79 : PRE_first_tail_x6_r0_body.S774.tab = PRE_first_tail_x6_r0_body.S772.tab ++ PRE_first_tail_x6_r0_body.cws79.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace79 : PRE_first_tail_x6_r0_body.s774.trace = PRE_first_tail_x6_r0_body.s772.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext79 : PRE_first_tail_x6_r0_body.s774.next = 2736967
kernel_rfl PRE_first_tail_x6_r0_body.ccounters79 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s774.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s774.ffi).mlx.nnext) = (19762, 16866)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue79 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s773.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s774.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa79.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp79 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s774.ffi).mlx.tokens.all (bSN 3458) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean79 : Conv.cleanListB 19762 131072 (fun r => Nat.ble 79048 r) PRE_first_tail_x6_r0_body.s774
    (PRE_first_tail_x6_r0_body.wrB79 ++ (List.range 0).map (2736967 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs79 : bigsOutB 19762 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s774.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK79
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl79`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl79 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo79 : List Nat := []
def PRE_first_tail_x6_r0_body.cln79 : List Nat := []
def PRE_first_tail_x6_r0_body.cli79 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap79 : PRE_first_tail_x6_r0_body.s774.heap = Stage.setAll PRE_first_tail_x6_r0_body.s772.heap (PRE_first_tail_x6_r0_body.cl79.filterMap fun a => (PRE_first_tail_x6_r0_body.s774.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe79 : Nat.ble PRE_first_tail_x6_r0_body.s772.next PRE_first_tail_x6_r0_body.s774.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP79 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s772 PRE_first_tail_x6_r0_body.s774 PRE_first_tail_x6_r0_body.cl79 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp79 : Conv.suppListB PRE_first_tail_x6_r0_body.s774 3458 PRE_first_tail_x6_r0_body.cl79 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound79 : Conv.boundListB PRE_first_tail_x6_r0_body.s774 PRE_first_tail_x6_r0_body.cl79 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK79 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s774.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln79.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s774.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK79 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s774.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo79.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s774.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK79 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s774.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli79.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s774.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst79 : Conv.sstListB 3458 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s774.ffi).mlx PRE_first_tail_x6_r0_body.cln79 PRE_first_tail_x6_r0_body.clo79 PRE_first_tail_x6_r0_body.cli79 = true

end Host.Load.Run.Tpl
end

section -- SiteCl79
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA79 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s774.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo79.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s774.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd79 : (PRE_first_tail_x6_r0_body.clo79 ++ PRE_first_tail_x6_r0_body.cln79 ++ PRE_first_tail_x6_r0_body.cli79).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle79 : Conv.Cnt.leB (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck79 : Conv.ncleanListB (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s774.ffi).mlx PRE_first_tail_x6_r0_body.clo79 PRE_first_tail_x6_r0_body.cln79 PRE_first_tail_x6_r0_body.cli79 = true
theorem PRE_first_tail_x6_r0_body.cncl79 (h : Conv.NClean (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx) : Conv.NClean (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s774.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle79 PRE_first_tail_x6_r0_body.ckA79 PRE_first_tail_x6_r0_body.cobjsK79 PRE_first_tail_x6_r0_body.cnodesK79 PRE_first_tail_x6_r0_body.citemsK79 PRE_first_tail_x6_r0_body.cbd79 PRE_first_tail_x6_r0_body.cck79

end Host.Load.Run.Tpl
end

section -- SiteS79
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 79 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc79 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P79 : LoadP := PRE_first_tail_x6_r0_body.Pc79.raise 16866
kernel_rfl PRE_first_tail_x6_r0_body.craise79 : Nat.ble PRE_first_tail_x6_r0_body.Pc79.N0 16866 = true
theorem PRE_first_tail_x6_r0_body.raised79 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc79 PRE_first_tail_x6_r0_body.P79 :=
  .inr ⟨16866, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise79, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_79 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s774.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_79 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s773.ffi)
def PRE_first_tail_x6_r0_body.khinv79 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv79 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS79 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS79 : List Nat := List.range' 16866 0
def PRE_first_tail_x6_r0_body.ciS79 : List Nat := [] ++ List.range' 16866 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh079 : PRE_first_tail_x6_r0_body.kd79.nh0 = PRE_first_tail_x6_r0_body.cx0_79.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh179 : PRE_first_tail_x6_r0_body.kd79.nh1 = PRE_first_tail_x6_r0_body.cx1_79.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn079 : PRE_first_tail_x6_r0_body.kd79.nn0 = PRE_first_tail_x6_r0_body.cx0_79.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn179 : PRE_first_tail_x6_r0_body.kd79.nn1 = PRE_first_tail_x6_r0_body.cx1_79.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo79 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P79.lo && Nat.ble PRE_first_tail_x6_r0_body.P79.lo PRE_first_tail_x6_r0_body.cx0_79.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P79.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P79.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt79 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_79.mlx.next PRE_first_tail_x6_r0_body.cx1_79.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_79.mlx.nnext PRE_first_tail_x6_r0_body.cx1_79.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband79 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P79.NL && Nat.ble PRE_first_tail_x6_r0_body.P79.NL PRE_first_tail_x6_r0_body.P79.N0 && Nat.ble PRE_first_tail_x6_r0_body.P79.N0 PRE_first_tail_x6_r0_body.cx0_79.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow79 : PRE_first_tail_x6_r0_body.kd79.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren79 : checkRenG PRE_first_tail_x6_r0_body.kd79.hnd PRE_first_tail_x6_r0_body.khinv79 (phB PRE_first_tail_x6_r0_body.cx0_79.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband79 : PRE_first_tail_x6_r0_body.kd79.checkBand PRE_first_tail_x6_r0_body.P79.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos79 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd79.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren79 : checkRenG PRE_first_tail_x6_r0_body.kd79.node PRE_first_tail_x6_r0_body.kninv79 (pnB PRE_first_tail_x6_r0_body.cx0_79.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow79 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd79.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P79.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd79.nodeF j) PRE_first_tail_x6_r0_body.cx1_79.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a79 : PRE_first_tail_x6_r0_body.cx0_79.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b79 : PRE_first_tail_x6_r0_body.cx0_79.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok179 : PRE_first_tail_x6_r0_body.cx1_79.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend79 : PRE_first_tail_x6_r0_body.cx1_79.mlx.pending = PRE_first_tail_x6_r0_body.cx0_79.mlx.pending.map PRE_first_tail_x6_r0_body.kappa79.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh79 : PRE_first_tail_x6_r0_body.cx1_79.mlx.errh = PRE_first_tail_x6_r0_body.cx0_79.mlx.errh.map PRE_first_tail_x6_r0_body.kappa79.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles79 : PRE_first_tail_x6_r0_body.cx1_79.mlx.files = PRE_first_tail_x6_r0_body.cx0_79.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch79 : PRE_first_tail_x6_r0_body.cx1_79.mlx.arch = PRE_first_tail_x6_r0_body.cx0_79.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes79 : PRE_first_tail_x6_r0_body.cx1_79.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_79.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired79 : PRE_first_tail_x6_r0_body.cx1_79.mlx.wired = PRE_first_tail_x6_r0_body.cx0_79.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost79 : PRE_first_tail_x6_r0_body.cx1_79.host = PRE_first_tail_x6_r0_body.cx0_79.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd79`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn079 : PRE_first_tail_x6_r0_body.kd79.n0 = 2736967
kernel_rfl PRE_first_tail_x6_r0_body.ckn179 : PRE_first_tail_x6_r0_body.kd79.n1 = 2736969
kernel_rfl PRE_first_tail_x6_r0_body.ckheap79 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd79.heap).all (fun x => Nat.ble 2736967 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl79 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_body.kd79.heap.get (2736967 + j) = nth? PRE_first_tail_x6_r0_body.pl79 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja79 : Nat.ble 2736967 2736967 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn79 : Nat.ble 3458 3458 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD79 : Nat.ble 2736967 PRE_first_tail_x6_r0_body.kd79.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn79 : Nat.ble 19762 PRE_first_tail_x6_r0_body.kd79.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn79 : Nat.ble 16866 PRE_first_tail_x6_r0_body.kd79.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb79 : Nat.ble 19762 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap79 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd79.heap).all (Nat.ble (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd79 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd79.hnd).all (Nat.ble (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode79 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd79.node).all (Nat.ble (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix79 : Conv.FixOld (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa79 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja79) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn79) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD79) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn79) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn79) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb79) PRE_first_tail_x6_r0_body.fheap79 PRE_first_tail_x6_r0_body.fhnd79 PRE_first_tail_x6_r0_body.fnode79
kernel_rfl PRE_first_tail_x6_r0_body.fcxn79 : (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn79 : (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle079 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_79.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_79.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk79 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd79.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A79 : PRE_first_tail_x6_r0_body.cx1_79.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS79.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_79.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O79 : PRE_first_tail_x6_r0_body.cx1_79.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS79.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_79.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N79 : PRE_first_tail_x6_r0_body.cx1_79.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS79.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_79.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I79 : PRE_first_tail_x6_r0_body.cx1_79.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS79.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_79.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd79 : (PRE_first_tail_x6_r0_body.clo79 ++ PRE_first_tail_x6_r0_body.cln79 ++ PRE_first_tail_x6_r0_body.cli79 ++ PRE_first_tail_x6_r0_body.cwS79 ++ PRE_first_tail_x6_r0_body.cnS79 ++ PRE_first_tail_x6_r0_body.ciS79).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW79 : PRE_first_tail_x6_r0_body.cwS79.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo79.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI79 : PRE_first_tail_x6_r0_body.ciS79.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli79.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN79 : PRE_first_tail_x6_r0_body.cnS79.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF79 : PRE_first_tail_x6_r0_body.cln79.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh79 : PRE_first_tail_x6_r0_body.clo79.all (handleOK PRE_first_tail_x6_r0_body.kappa79 PRE_first_tail_x6_r0_body.P79.lo PRE_first_tail_x6_r0_body.cx0_79.mlx PRE_first_tail_x6_r0_body.cx1_79.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo79 : PRE_first_tail_x6_r0_body.clo79.map (fun h => PRE_first_tail_x6_r0_body.cx1_79.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa79.handle h)) = PRE_first_tail_x6_r0_body.clo79.map (fun h => (PRE_first_tail_x6_r0_body.cx0_79.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa79.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok79 : PRE_first_tail_x6_r0_body.clo79.all (objOK PRE_first_tail_x6_r0_body.kappa79 PRE_first_tail_x6_r0_body.P79.NL PRE_first_tail_x6_r0_body.cx0_79.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd79 : PRE_first_tail_x6_r0_body.cln79.all (nodeOKF PRE_first_tail_x6_r0_body.kappa79 PRE_first_tail_x6_r0_body.P79 PRE_first_tail_x6_r0_body.cx0_79.mlx PRE_first_tail_x6_r0_body.cx1_79.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp79 : ((PRE_first_tail_x6_r0_body.cln79.filter (fullB PRE_first_tail_x6_r0_body.P79))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_79.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa79.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln79.filter (fullB PRE_first_tail_x6_r0_body.P79))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_79.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa79.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI79 : incrB PRE_first_tail_x6_r0_body.kd79.nodeF (List.range' 16866 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK79 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd79.node).all (fun k => Nat.ble 16866 k && Nat.blt k 16866) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL79 : (PRE_first_tail_x6_r0_body.cln79.filter (Nat.ble PRE_first_tail_x6_r0_body.P79.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd79.nodeF i) && (Nat.blt i 16866 || Nat.ble PRE_first_tail_x6_r0_body.kd79.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord79 : (PRE_first_tail_x6_r0_body.cln79.filter (Nat.ble PRE_first_tail_x6_r0_body.P79.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd79.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd79.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd79.nodeF j) (PRE_first_tail_x6_r0_body.kd79.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow79 PRE_first_tail_x6_r0_body.cnn179 PRE_first_tail_x6_r0_body.fnordI79 PRE_first_tail_x6_r0_body.fnordK79 PRE_first_tail_x6_r0_body.fnordL79
kernel_rfl PRE_first_tail_x6_r0_body.fi79 : PRE_first_tail_x6_r0_body.cli79.all (pnB PRE_first_tail_x6_r0_body.cx0_79.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii79 : PRE_first_tail_x6_r0_body.cli79.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_79.mlx.items.get (PRE_first_tail_x6_r0_body.kappa79.node k) = (PRE_first_tail_x6_r0_body.cx0_79.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa79.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot79 (clean : Conv.NClean (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P79.NL) (cl : SSt (· < 3458) PRE_first_tail_x6_r0_body.cx0_79.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P79 3458 PRE_first_tail_x6_r0_body.kappa79 PRE_first_tail_x6_r0_body.kd79 PRE_first_tail_x6_r0_body.khinv79 PRE_first_tail_x6_r0_body.kninv79 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx PRE_first_tail_x6_r0_body.cx0_79.mlx PRE_first_tail_x6_r0_body.cx1_79.mlx (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo79 PRE_first_tail_x6_r0_body.cln79 PRE_first_tail_x6_r0_body.cli79 PRE_first_tail_x6_r0_body.cwS79 PRE_first_tail_x6_r0_body.cnS79 PRE_first_tail_x6_r0_body.ciS79 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh079, PRE_first_tail_x6_r0_body.cnh179, PRE_first_tail_x6_r0_body.cnn079, PRE_first_tail_x6_r0_body.cnn179, PRE_first_tail_x6_r0_body.cplo79, PRE_first_tail_x6_r0_body.ccnt79, PRE_first_tail_x6_r0_body.cnband79, PRE_first_tail_x6_r0_body.chbelow79, PRE_first_tail_x6_r0_body.chren79, PRE_first_tail_x6_r0_body.cband79, PRE_first_tail_x6_r0_body.cnh1pos79, PRE_first_tail_x6_r0_body.cnren79, PRE_first_tail_x6_r0_body.cnlow79, PRE_first_tail_x6_r0_body.cabs0a79, PRE_first_tail_x6_r0_body.cabs0b79, PRE_first_tail_x6_r0_body.ctok179, PRE_first_tail_x6_r0_body.cpend79, PRE_first_tail_x6_r0_body.cerrh79, PRE_first_tail_x6_r0_body.cfiles79, PRE_first_tail_x6_r0_body.carch79, PRE_first_tail_x6_r0_body.csizes79, PRE_first_tail_x6_r0_body.cwired79, PRE_first_tail_x6_r0_body.cfix79, clean, PRE_first_tail_x6_r0_body.fcxn79, PRE_first_tail_x6_r0_body.fcnn79, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle079, PRE_first_tail_x6_r0_body.fnk79, PRE_first_tail_x6_r0_body.ckA79, PRE_first_tail_x6_r0_body.cobjsK79, PRE_first_tail_x6_r0_body.cnodesK79, PRE_first_tail_x6_r0_body.citemsK79, PRE_first_tail_x6_r0_body.f1A79, PRE_first_tail_x6_r0_body.f1O79, PRE_first_tail_x6_r0_body.f1N79, PRE_first_tail_x6_r0_body.f1I79, PRE_first_tail_x6_r0_body.fbd79, PRE_first_tail_x6_r0_body.fincW79, PRE_first_tail_x6_r0_body.fincI79, PRE_first_tail_x6_r0_body.fincN79, PRE_first_tail_x6_r0_body.flnF79, PRE_first_tail_x6_r0_body.fh79, PRE_first_tail_x6_r0_body.fo79, PRE_first_tail_x6_r0_body.fok79, PRE_first_tail_x6_r0_body.fnd79, PRE_first_tail_x6_r0_body.fp79, PRE_first_tail_x6_r0_body.fnord79, PRE_first_tail_x6_r0_body.fi79, PRE_first_tail_x6_r0_body.fii79⟩
theorem PRE_first_tail_x6_r0_body.cnshift79 (clean : Conv.NClean (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P79.NL) (cl : SSt (· < 3458) PRE_first_tail_x6_r0_body.cx0_79.mlx) : NShift PRE_first_tail_x6_r0_body.P79 3458 PRE_first_tail_x6_r0_body.kappa79 PRE_first_tail_x6_r0_body.cx0_79 PRE_first_tail_x6_r0_body.cx1_79 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot79 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost79 (compact_a_eq PRE_first_tail_x6_r0_body.ckn079 PRE_first_tail_x6_r0_body.ckn179 PRE_first_tail_x6_r0_body.ckheap79 PRE_first_tail_x6_r0_body.ckpl79)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_79 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s772.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_79 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s772.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_79 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s772.ffi) = some PRE_first_tail_x6_r0_body.fxC_79
kernel_rfl PRE_first_tail_x6_r0_body.okrC_79 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s772.ffi) = some PRE_first_tail_x6_r0_body.krC_79
noncomputable def PRE_first_tail_x6_r0_body.fx0_79 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s774.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_79 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s774.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_79 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s774.ffi) = some PRE_first_tail_x6_r0_body.fx0_79
kernel_rfl PRE_first_tail_x6_r0_body.okr0_79 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s774.ffi) = some PRE_first_tail_x6_r0_body.kr0_79
noncomputable def PRE_first_tail_x6_r0_body.fx1_79 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s773.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_79 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s773.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_79 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s773.ffi) = some PRE_first_tail_x6_r0_body.fx1_79
kernel_rfl PRE_first_tail_x6_r0_body.okr1_79 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s773.ffi) = some PRE_first_tail_x6_r0_body.kr1_79
kernel_rfl PRE_first_tail_x6_r0_body.ff079 : PRE_first_tail_x6_r0_body.fx0_79 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_79 (PRE_first_tail_x6_r0_body.clo79.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_79.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff179 : PRE_first_tail_x6_r0_body.fx1_79 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_79 (PRE_first_tail_x6_r0_body.cwS79.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_79.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck79 : freedLB PRE_first_tail_x6_r0_body.kappa79 PRE_first_tail_x6_r0_body.cx0_79.mlx PRE_first_tail_x6_r0_body.fx0_79 PRE_first_tail_x6_r0_body.fx1_79 PRE_first_tail_x6_r0_body.clo79 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf079 : PRE_first_tail_x6_r0_body.kr0_79.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_79.flags (PRE_first_tail_x6_r0_body.clo79.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_79.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt079 : PRE_first_tail_x6_r0_body.kr0_79.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_79.targs (PRE_first_tail_x6_r0_body.clo79.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_79.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf179 : PRE_first_tail_x6_r0_body.kr1_79.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_79.flags (PRE_first_tail_x6_r0_body.cwS79.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_79.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt179 : PRE_first_tail_x6_r0_body.kr1_79.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_79.targs (PRE_first_tail_x6_r0_body.cwS79.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_79.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck79 : krecLB PRE_first_tail_x6_r0_body.kappa79 3458 PRE_first_tail_x6_r0_body.cx0_79.mlx PRE_first_tail_x6_r0_body.kr0_79 PRE_first_tail_x6_r0_body.kr1_79 PRE_first_tail_x6_r0_body.clo79 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn79 : Nat.ble 3458 3458 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge79 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s773.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s774.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR79 : pendRegB PRE_first_tail_x6_r0_body.kappa79 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s774.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe79 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s774.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s773.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift79 (clean : Conv.NClean (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P79.NL) (cl : SSt (· < 3458) PRE_first_tail_x6_r0_body.cx0_79.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_79.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_79.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_79.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s772.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_79.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P79 3458 PRE_first_tail_x6_r0_body.kappa79 PRE_first_tail_x6_r0_body.s774.ffi PRE_first_tail_x6_r0_body.s773.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift79 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue79, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp79 t ht),
    PRE_first_tail_x6_r0_body.cbridge79,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s774.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s773.ffi) (PRE_first_tail_x6_r0_body.cfoot79 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_79 PRE_first_tail_x6_r0_body.ofx1_79 hobjC PRE_first_tail_x6_r0_body.ff079 PRE_first_tail_x6_r0_body.ff179 PRE_first_tail_x6_r0_body.ffck79,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s774.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s773.ffi) (PRE_first_tail_x6_r0_body.cfoot79 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_79 PRE_first_tail_x6_r0_body.okr1_79 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn79) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf079 PRE_first_tail_x6_r0_body.fkt079 PRE_first_tail_x6_r0_body.fkf179 PRE_first_tail_x6_r0_body.fkt179 PRE_first_tail_x6_r0_body.fkck79,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh079 PRE_first_tail_x6_r0_body.cnh179 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe79) PRE_first_tail_x6_r0_body.cpendR79⟩

end Host.Load.Run.Tpl
end

section -- st79/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st79 0
host_stream_state PRE_first_tail_x6_r0_body.st79 1
host_stream_state PRE_first_tail_x6_r0_body.st79 2
end Host.Load.Run.Tpl
end

section -- Site79
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 79 of chain `PRE_first_tail_x6_r0_body`: `rowBlocks__g79__g80` (`rowBlocks`), the call state `PRE_first_tail_x6_r0_body.s772`, the merged state `PRE_first_tail_x6_r0_body.s773`,
the site template `PRE_first_tail_x6_r0_body.st79` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s774`: the merge.
The footprint's facts are in `SiteF79`, the compaction's in `SiteC79`, `SiteK79`, `SiteNa79`, `SiteNb79`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso79 : PRE_first_tail_x6_r0_body.st79.s0 = { PRE_first_tail_x6_r0_body.s772 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs79 : List Frame := PRE_first_tail_x6_r0_body.s772.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_79 : PRE_first_tail_x6_r0_body.S772.tab.length = 3458
kernel_rfl PRE_first_tail_x6_r0_body.tab0_79 : PRE_first_tail_x6_r0_body.st79.S0.tab = PRE_first_tail_x6_r0_body.S772.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws79 : List Nat := [2357, 2358]
kernel_rfl PRE_first_tail_x6_r0_body.fresh79 : (PRE_first_tail_x6_r0_body.S772.tab.all fun e => PRE_first_tail_x6_r0_body.ws79.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S772.oracle.all fun q => PRE_first_tail_x6_r0_body.ws79.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab79 : PRE_first_tail_x6_r0_body.S773.tab = PRE_first_tail_x6_r0_body.S772.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws79
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen79 : PRE_first_tail_x6_r0_body.st79.S2.tab.length - PRE_first_tail_x6_r0_body.st79.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged79`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap79 : PRE_first_tail_x6_r0_body.s773.heap = PRE_first_tail_x6_r0_body.st79.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext79 : PRE_first_tail_x6_r0_body.s773.next = PRE_first_tail_x6_r0_body.st79.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl79 : PRE_first_tail_x6_r0_body.s773.ctl = PRE_first_tail_x6_r0_body.st79.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack79 : PRE_first_tail_x6_r0_body.s773.stack = PRE_first_tail_x6_r0_body.st79.s2.stack ++ PRE_first_tail_x6_r0_body.s772.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs79 : PRE_first_tail_x6_r0_body.s773.jobs = PRE_first_tail_x6_r0_body.st79.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi79 : PRE_first_tail_x6_r0_body.s773.ffi = PRE_first_tail_x6_r0_body.st79.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace79 : PRE_first_tail_x6_r0_body.s773.trace = PRE_first_tail_x6_r0_body.st79.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores79 : PRE_first_tail_x6_r0_body.s773.stores = PRE_first_tail_x6_r0_body.st79.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD79
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 79 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived79 : PRE_first_tail_x6_r0_body.nr79.map (fun r => nth? PRE_first_tail_x6_r0_body.st79.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo79 : PRE_first_tail_x6_r0_body.nr79.all (Nat.ble 3458) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj79 : PRE_first_tail_x6_r0_body.cws79.all (fun c => !PRE_first_tail_x6_r0_body.ws79.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ79 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws79 PRE_first_tail_x6_r0_body.crs79 PRE_first_tail_x6_r0_body.ws79

end Host.Load.Run.Tpl
end

section -- st79/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st79`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st79.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st79.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st79.s2.heap PRE_first_tail_x6_r0_body.st79.wrR ++ freshOf PRE_first_tail_x6_r0_body.st79.s2.heap PRE_first_tail_x6_r0_body.st79.s0.next PRE_first_tail_x6_r0_body.st79.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st79.wr : List Nat := PRE_first_tail_x6_r0_body.st79.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st79.heapFoot : PRE_first_tail_x6_r0_body.st79.s2.heap = setAll PRE_first_tail_x6_r0_body.st79.s0.heap PRE_first_tail_x6_r0_body.st79.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st79.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st79.s0.next PRE_first_tail_x6_r0_body.st79.s2.next = true
theorem PRE_first_tail_x6_r0_body.st79.grows : PRE_first_tail_x6_r0_body.st79.s0.next ≤ PRE_first_tail_x6_r0_body.st79.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st79.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st79.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st79.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st79.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st79.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st79.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st79.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st79.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st79.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st79.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st79.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st79.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st79.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st79.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st79.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st79.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st79.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st79.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st79.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st79.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st79.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st79.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st79.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st79.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st79.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st79.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st79.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st79.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st79.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st79.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st79.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st79.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF79
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 79 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB79 : nodupT PRE_first_tail_x6_r0_body.st79.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup79 : PRE_first_tail_x6_r0_body.st79.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB79).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB79 : PRE_first_tail_x6_r0_body.st79.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound79 : ∀ b ∈ PRE_first_tail_x6_r0_body.st79.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB79 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr79 := PRE_first_tail_x6_r0_body.st79.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq79 : PRE_first_tail_x6_r0_body.st79.s2.trace = PRE_first_tail_x6_r0_body.trFr79 ++ PRE_first_tail_x6_r0_body.st79.s0.trace
theorem PRE_first_tail_x6_r0_body.trace79 : ∃ fr, PRE_first_tail_x6_r0_body.st79.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st79.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq79⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide79 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB79 : (PRE_first_tail_x6_r0_body.wide79.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st79.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix79 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide79, WFix Map.id (Present PRE_first_tail_x6_r0_body.st79.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB79 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL79
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 79 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s773`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO79 : PRE_first_tail_x6_r0_body.st79.S0.oracle = PRE_first_tail_x6_r0_body.st79.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B79 : PRE_first_tail_x6_r0_body.st79.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st79.s0.next || (PRE_first_tail_x6_r0_body.st79.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot79 : Conv.StageFoot PRE_first_tail_x6_r0_body.st79.wr PRE_first_tail_x6_r0_body.st79.s0 PRE_first_tail_x6_r0_body.st79.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st79.heapFoot PRE_first_tail_x6_r0_body.wrNodup79 PRE_first_tail_x6_r0_body.wrBound79 PRE_first_tail_x6_r0_body.wr0B79 PRE_first_tail_x6_r0_body.st79.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged79 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st79.F.S → PRE_first_tail_x6_r0_body.st79.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st79.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st79.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs79 PRE_first_tail_x6_r0_body.st79.wr PRE_first_tail_x6_r0_body.s772 PRE_first_tail_x6_r0_body.st79.s2 PRE_first_tail_x6_r0_body.st79.s0
      PRE_first_tail_x6_r0_body.st79.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st79.F FR W stk M ν K PRE_first_tail_x6_r0_body.s773 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso79 PRE_first_tail_x6_r0_body.stFoot79 PRE_first_tail_x6_r0_body.wrNodup79 PRE_first_tail_x6_r0_body.wrBound79 PRE_first_tail_x6_r0_body.trace79 PRE_first_tail_x6_r0_body.mheap79
    PRE_first_tail_x6_r0_body.mnext79 PRE_first_tail_x6_r0_body.mctl79 PRE_first_tail_x6_r0_body.mstack79 PRE_first_tail_x6_r0_body.mjobs79 PRE_first_tail_x6_r0_body.mffi79 PRE_first_tail_x6_r0_body.mtrace79 PRE_first_tail_x6_r0_body.mstores79 h

def PRE_first_tail_x6_r0_body.arrEl79_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE79_2665 : arrOf PRE_first_tail_x6_r0_body.s773 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl79_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA79_2665 : isArrB PRE_first_tail_x6_r0_body.s773 2665 = true
theorem PRE_first_tail_x6_r0_body.arr79_2665 : ∃ o, PRE_first_tail_x6_r0_body.s773.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl79_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE79_2665 PRE_first_tail_x6_r0_body.arrA79_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN79_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl79_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR79_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl79_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN79_2665

def PRE_first_tail_x6_r0_body.arrEl79_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE79_2673467 : arrOf PRE_first_tail_x6_r0_body.s773 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl79_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA79_2673467 : isArrB PRE_first_tail_x6_r0_body.s773 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr79_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s773.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl79_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE79_2673467 PRE_first_tail_x6_r0_body.arrA79_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN79_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl79_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR79_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl79_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN79_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k79 : isArrB PRE_first_tail_x6_r0_body.s773 4910 = false
theorem PRE_first_tail_x6_r0_body.keep79 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s773 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k79 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr79_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl79_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ79
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 79 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s772`, the merged
state `PRE_first_tail_x6_r0_body.s773`, the canonical state `PRE_first_tail_x6_r0_body.s774`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl79 : PRE_first_tail_x6_r0_body.pl79.all (Nat.ble PRE_first_tail_x6_r0_body.s772.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd79 : nodupT PRE_first_tail_x6_r0_body.pl79 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn179 : Nat.ble PRE_first_tail_x6_r0_body.s772.next 2736969 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst79 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s772.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn79 : PRE_first_tail_x6_r0_body.s774.next = PRE_first_tail_x6_r0_body.s772.next + PRE_first_tail_x6_r0_body.pl79.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn79 : PRE_first_tail_x6_r0_body.s773.next = 2736969
kernel_rfl PRE_first_tail_x6_r0_body.zgrow79 : Nat.ble PRE_first_tail_x6_r0_body.s774.next PRE_first_tail_x6_r0_body.s773.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh79 : PRE_first_tail_x6_r0_body.S772.tab.all (fun e => PRE_first_tail_x6_r0_body.cws79.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd79 : nodupT PRE_first_tail_x6_r0_body.cws79 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi79 : PRE_first_tail_x6_r0_body.nr79.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S773.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt79 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s772.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg79_2665 : PRE_first_tail_x6_r0_body.s774.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s774 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk79_2665 : (objOf PRE_first_tail_x6_r0_body.s774 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm79_2665 : PRE_first_tail_x6_r0_body.s773.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa79.obj (objOf PRE_first_tail_x6_r0_body.s774 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s773 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg79_2673467 : PRE_first_tail_x6_r0_body.s774.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s774 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk79_2673467 : (objOf PRE_first_tail_x6_r0_body.s774 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm79_2673467 : PRE_first_tail_x6_r0_body.s773.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa79.obj (objOf PRE_first_tail_x6_r0_body.s774 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s773 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw79_4910 : (PRE_first_tail_x6_r0_body.s774.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw79_2673472 : (PRE_first_tail_x6_r0_body.s774.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw79_2673473 : (PRE_first_tail_x6_r0_body.s774.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd79 : PRE_first_tail_x6_r0_body.cl79.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr79 : PRE_first_tail_x6_r0_body.st79.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s772.next || PRE_first_tail_x6_r0_body.cl79.contains b) = true
def PRE_first_tail_x6_r0_body.zl79 : List Nat := PRE_first_tail_x6_r0_body.cl79.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE79 : PRE_first_tail_x6_r0_body.zl79.map (fun a => PRE_first_tail_x6_r0_body.s773.heap.get (PRE_first_tail_x6_r0_body.kappa79.a a)) = PRE_first_tail_x6_r0_body.zl79.map (fun a => (PRE_first_tail_x6_r0_body.s774.heap.get a).map PRE_first_tail_x6_r0_body.kappa79.hobj)
theorem PRE_first_tail_x6_r0_body.zimg79 : HeapImg PRE_first_tail_x6_r0_body.kappa79 PRE_first_tail_x6_r0_body.s774 PRE_first_tail_x6_r0_body.s773 PRE_first_tail_x6_r0_body.zl79 := PRE_first_tail_x6_r0_body.zimgE79
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl79 : PRE_first_tail_x6_r0_body.s773.ctl = PRE_first_tail_x6_r0_body.kappa79.ctl PRE_first_tail_x6_r0_body.s774.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack79 : PRE_first_tail_x6_r0_body.s773.stack = PRE_first_tail_x6_r0_body.s774.stack.map PRE_first_tail_x6_r0_body.kappa79.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs79 : PRE_first_tail_x6_r0_body.s773.jobs = PRE_first_tail_x6_r0_body.s774.jobs.map PRE_first_tail_x6_r0_body.kappa79.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores79 : PRE_first_tail_x6_r0_body.s773.stores = PRE_first_tail_x6_r0_body.kappa79.stores PRE_first_tail_x6_r0_body.s774.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots79 : checkRootsSupp PRE_first_tail_x6_r0_body.s774 3458 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC79 : PRE_first_tail_x6_r0_body.S772.tab.length + PRE_first_tail_x6_r0_body.cws79.length = 3458
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap79 : PRE_first_tail_x6_r0_body.kappa79 = Conv.Map.compact PRE_first_tail_x6_r0_body.s772.next 2736969 PRE_first_tail_x6_r0_body.S772.tab.length PRE_first_tail_x6_r0_body.pl79 (PRE_first_tail_x6_r0_body.nr79.map NumV.ref) PRE_first_tail_x6_r0_body.kd79.big
  PRE_first_tail_x6_r0_body.kd79.region PRE_first_tail_x6_r0_body.kd79.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin79 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s774.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc79 : Conv.jcleanListB (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s774 PRE_first_tail_x6_r0_body.cl79 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB79 : noBigRootsP (fun i => !Conv.oldBigB (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s774.trace PRE_first_tail_x6_r0_body.s774 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm79 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 16866 = true
theorem PRE_first_tail_x6_r0_body.cjcl79 (h : Conv.JClean (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s772) : Conv.JClean (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s774 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle79)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap79 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd79 a ha)) PRE_first_tail_x6_r0_body.zjc79

end Host.Load.Run.Tpl
end

section -- st79/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st79.bodyLast from PRE_first_tail_x6_r0_body.st79.s1 to PRE_first_tail_x6_r0_body.st79.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st79.F PRE_first_tail_x6_r0_body.st79.s1).run PRE_first_tail_x6_r0_body.st79.S1 = some (PRE_first_tail_x6_r0_body.st79.s2, PRE_first_tail_x6_r0_body.st79.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st79.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st79.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st79.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st79.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st79/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st79.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st79.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st79.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st79.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st79.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st79.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st79.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st79.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st79.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st79.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st79.s0 PRE_first_tail_x6_r0_body.st79.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st79.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st79.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st79.s1 PRE_first_tail_x6_r0_body.st79.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st79/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st79.bodyK0F from PRE_first_tail_x6_r0_body.st79.s0 to PRE_first_tail_x6_r0_body.st79.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st79.F (PRE_first_tail_x6_r0_body.st79.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st79.ks 0).getD 0) PRE_first_tail_x6_r0_body.st79.s0 PRE_first_tail_x6_r0_body.st79.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st79.s1, PRE_first_tail_x6_r0_body.st79.S1)
theorem PRE_first_tail_x6_r0_body.st79.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st79.F (PRE_first_tail_x6_r0_body.st79.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st79.ks 0).getD 0) PRE_first_tail_x6_r0_body.st79.s0 PRE_first_tail_x6_r0_body.st79.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st79.s1, PRE_first_tail_x6_r0_body.st79.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st79.bodyOkLN_ok PRE_first_tail_x6_r0_body.st79.bodyK0F
end Host.Load.Run.Tpl
end

section -- st79/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st79.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st79.F (PRE_first_tail_x6_r0_body.st79.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st79.s0 PRE_first_tail_x6_r0_body.st79.S0 = some (PRE_first_tail_x6_r0_body.st79.s1, PRE_first_tail_x6_r0_body.st79.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st79.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st79.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st79.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st79.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st79.F (PRE_first_tail_x6_r0_body.st79.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st79.s0
  S0 := PRE_first_tail_x6_r0_body.st79.S0
  s1 := PRE_first_tail_x6_r0_body.st79.s1
  S1 := PRE_first_tail_x6_r0_body.st79.S1
  s2 := PRE_first_tail_x6_r0_body.st79.s2
  S2 := PRE_first_tail_x6_r0_body.st79.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st79.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st79.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st79.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st79.bodyHalt
  last := PRE_first_tail_x6_r0_body.st79.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st79.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC80
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 80 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s778` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa80` into the merged state
`PRE_first_tail_x6_r0_body.s777`. -/

def PRE_first_tail_x6_r0_body.pl80 : List Nat := [2737265]
def PRE_first_tail_x6_r0_body.nr80 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd80 : RData :=
  ⟨2737256, 2737266, Stage.setAll PTrie.nil [(2737255, 2737265)], Stage.setAll PTrie.nil [],
   19769, 19769, 16870, 16870, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa80 : Map :=
  Conv.Map.compact 2737255 2737266 3475 PRE_first_tail_x6_r0_body.pl80 (PRE_first_tail_x6_r0_body.nr80.map NumV.ref) PRE_first_tail_x6_r0_body.kd80.big
    PRE_first_tail_x6_r0_body.kd80.region PRE_first_tail_x6_r0_body.kd80.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws80 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs80 : List SymE := PRE_first_tail_x6_r0_body.nr80.map fun r => (nth? PRE_first_tail_x6_r0_body.S777.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta80 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws80 PRE_first_tail_x6_r0_body.crs80
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB80 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab80 : PRE_first_tail_x6_r0_body.S778.tab = PRE_first_tail_x6_r0_body.S776.tab ++ PRE_first_tail_x6_r0_body.cws80.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace80 : PRE_first_tail_x6_r0_body.s778.trace = PRE_first_tail_x6_r0_body.s776.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext80 : PRE_first_tail_x6_r0_body.s778.next = 2737256
kernel_rfl PRE_first_tail_x6_r0_body.ccounters80 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s778.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s778.ffi).mlx.nnext) = (19769, 16870)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue80 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s777.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s778.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa80.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp80 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s778.ffi).mlx.tokens.all (bSN 3475) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean80 : Conv.cleanListB 19769 131072 (fun r => Nat.ble 79076 r) PRE_first_tail_x6_r0_body.s778
    (PRE_first_tail_x6_r0_body.wrB80 ++ (List.range 1).map (2737255 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs80 : bigsOutB 19769 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s778.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK80
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl80`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl80 : List Nat := [2665, 2673467, 2737255]
def PRE_first_tail_x6_r0_body.clo80 : List Nat := []
def PRE_first_tail_x6_r0_body.cln80 : List Nat := []
def PRE_first_tail_x6_r0_body.cli80 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap80 : PRE_first_tail_x6_r0_body.s778.heap = Stage.setAll PRE_first_tail_x6_r0_body.s776.heap (PRE_first_tail_x6_r0_body.cl80.filterMap fun a => (PRE_first_tail_x6_r0_body.s778.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe80 : Nat.ble PRE_first_tail_x6_r0_body.s776.next PRE_first_tail_x6_r0_body.s778.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP80 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s776 PRE_first_tail_x6_r0_body.s778 PRE_first_tail_x6_r0_body.cl80 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp80 : Conv.suppListB PRE_first_tail_x6_r0_body.s778 3475 PRE_first_tail_x6_r0_body.cl80 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound80 : Conv.boundListB PRE_first_tail_x6_r0_body.s778 PRE_first_tail_x6_r0_body.cl80 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK80 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s778.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln80.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s778.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK80 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s778.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo80.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s778.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK80 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s778.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli80.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s778.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst80 : Conv.sstListB 3475 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s778.ffi).mlx PRE_first_tail_x6_r0_body.cln80 PRE_first_tail_x6_r0_body.clo80 PRE_first_tail_x6_r0_body.cli80 = true

end Host.Load.Run.Tpl
end

section -- SiteCl80
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA80 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s778.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo80.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s778.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd80 : (PRE_first_tail_x6_r0_body.clo80 ++ PRE_first_tail_x6_r0_body.cln80 ++ PRE_first_tail_x6_r0_body.cli80).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle80 : Conv.Cnt.leB (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt) (⟨19769, 16870, 2737256, 3475⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck80 : Conv.ncleanListB (⟨19769, 16870, 2737256, 3475⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s778.ffi).mlx PRE_first_tail_x6_r0_body.clo80 PRE_first_tail_x6_r0_body.cln80 PRE_first_tail_x6_r0_body.cli80 = true
theorem PRE_first_tail_x6_r0_body.cncl80 (h : Conv.NClean (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx) : Conv.NClean (⟨19769, 16870, 2737256, 3475⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s778.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle80 PRE_first_tail_x6_r0_body.ckA80 PRE_first_tail_x6_r0_body.cobjsK80 PRE_first_tail_x6_r0_body.cnodesK80 PRE_first_tail_x6_r0_body.citemsK80 PRE_first_tail_x6_r0_body.cbd80 PRE_first_tail_x6_r0_body.cck80

end Host.Load.Run.Tpl
end

section -- SiteS80
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 80 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc80 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P80 : LoadP := PRE_first_tail_x6_r0_body.Pc80.raise 16870
kernel_rfl PRE_first_tail_x6_r0_body.craise80 : Nat.ble PRE_first_tail_x6_r0_body.Pc80.N0 16870 = true
theorem PRE_first_tail_x6_r0_body.raised80 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc80 PRE_first_tail_x6_r0_body.P80 :=
  .inr ⟨16870, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise80, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_80 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s778.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_80 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s777.ffi)
def PRE_first_tail_x6_r0_body.khinv80 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv80 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS80 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS80 : List Nat := List.range' 16870 0
def PRE_first_tail_x6_r0_body.ciS80 : List Nat := [] ++ List.range' 16870 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh080 : PRE_first_tail_x6_r0_body.kd80.nh0 = PRE_first_tail_x6_r0_body.cx0_80.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh180 : PRE_first_tail_x6_r0_body.kd80.nh1 = PRE_first_tail_x6_r0_body.cx1_80.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn080 : PRE_first_tail_x6_r0_body.kd80.nn0 = PRE_first_tail_x6_r0_body.cx0_80.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn180 : PRE_first_tail_x6_r0_body.kd80.nn1 = PRE_first_tail_x6_r0_body.cx1_80.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo80 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P80.lo && Nat.ble PRE_first_tail_x6_r0_body.P80.lo PRE_first_tail_x6_r0_body.cx0_80.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P80.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P80.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt80 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_80.mlx.next PRE_first_tail_x6_r0_body.cx1_80.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_80.mlx.nnext PRE_first_tail_x6_r0_body.cx1_80.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband80 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P80.NL && Nat.ble PRE_first_tail_x6_r0_body.P80.NL PRE_first_tail_x6_r0_body.P80.N0 && Nat.ble PRE_first_tail_x6_r0_body.P80.N0 PRE_first_tail_x6_r0_body.cx0_80.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow80 : PRE_first_tail_x6_r0_body.kd80.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren80 : checkRenG PRE_first_tail_x6_r0_body.kd80.hnd PRE_first_tail_x6_r0_body.khinv80 (phB PRE_first_tail_x6_r0_body.cx0_80.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband80 : PRE_first_tail_x6_r0_body.kd80.checkBand PRE_first_tail_x6_r0_body.P80.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos80 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd80.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren80 : checkRenG PRE_first_tail_x6_r0_body.kd80.node PRE_first_tail_x6_r0_body.kninv80 (pnB PRE_first_tail_x6_r0_body.cx0_80.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow80 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd80.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P80.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd80.nodeF j) PRE_first_tail_x6_r0_body.cx1_80.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a80 : PRE_first_tail_x6_r0_body.cx0_80.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b80 : PRE_first_tail_x6_r0_body.cx0_80.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok180 : PRE_first_tail_x6_r0_body.cx1_80.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend80 : PRE_first_tail_x6_r0_body.cx1_80.mlx.pending = PRE_first_tail_x6_r0_body.cx0_80.mlx.pending.map PRE_first_tail_x6_r0_body.kappa80.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh80 : PRE_first_tail_x6_r0_body.cx1_80.mlx.errh = PRE_first_tail_x6_r0_body.cx0_80.mlx.errh.map PRE_first_tail_x6_r0_body.kappa80.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles80 : PRE_first_tail_x6_r0_body.cx1_80.mlx.files = PRE_first_tail_x6_r0_body.cx0_80.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch80 : PRE_first_tail_x6_r0_body.cx1_80.mlx.arch = PRE_first_tail_x6_r0_body.cx0_80.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes80 : PRE_first_tail_x6_r0_body.cx1_80.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_80.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired80 : PRE_first_tail_x6_r0_body.cx1_80.mlx.wired = PRE_first_tail_x6_r0_body.cx0_80.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost80 : PRE_first_tail_x6_r0_body.cx1_80.host = PRE_first_tail_x6_r0_body.cx0_80.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd80`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn080 : PRE_first_tail_x6_r0_body.kd80.n0 = 2737256
kernel_rfl PRE_first_tail_x6_r0_body.ckn180 : PRE_first_tail_x6_r0_body.kd80.n1 = 2737266
kernel_rfl PRE_first_tail_x6_r0_body.ckheap80 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd80.heap).all (fun x => Nat.ble 2737255 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl80 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd80.heap.get (2737255 + j) = nth? PRE_first_tail_x6_r0_body.pl80 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja80 : Nat.ble 2737255 2737255 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn80 : Nat.ble 3475 3475 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD80 : Nat.ble 2737255 PRE_first_tail_x6_r0_body.kd80.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn80 : Nat.ble 19769 PRE_first_tail_x6_r0_body.kd80.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn80 : Nat.ble 16870 PRE_first_tail_x6_r0_body.kd80.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb80 : Nat.ble 19769 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap80 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd80.heap).all (Nat.ble (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd80 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd80.hnd).all (Nat.ble (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode80 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd80.node).all (Nat.ble (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix80 : Conv.FixOld (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa80 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja80) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn80) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD80) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn80) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn80) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb80) PRE_first_tail_x6_r0_body.fheap80 PRE_first_tail_x6_r0_body.fhnd80 PRE_first_tail_x6_r0_body.fnode80
kernel_rfl PRE_first_tail_x6_r0_body.fcxn80 : (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn80 : (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle080 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_80.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_80.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk80 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd80.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A80 : PRE_first_tail_x6_r0_body.cx1_80.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS80.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_80.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O80 : PRE_first_tail_x6_r0_body.cx1_80.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS80.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_80.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N80 : PRE_first_tail_x6_r0_body.cx1_80.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS80.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_80.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I80 : PRE_first_tail_x6_r0_body.cx1_80.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS80.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_80.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd80 : (PRE_first_tail_x6_r0_body.clo80 ++ PRE_first_tail_x6_r0_body.cln80 ++ PRE_first_tail_x6_r0_body.cli80 ++ PRE_first_tail_x6_r0_body.cwS80 ++ PRE_first_tail_x6_r0_body.cnS80 ++ PRE_first_tail_x6_r0_body.ciS80).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW80 : PRE_first_tail_x6_r0_body.cwS80.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo80.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI80 : PRE_first_tail_x6_r0_body.ciS80.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli80.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN80 : PRE_first_tail_x6_r0_body.cnS80.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF80 : PRE_first_tail_x6_r0_body.cln80.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh80 : PRE_first_tail_x6_r0_body.clo80.all (handleOK PRE_first_tail_x6_r0_body.kappa80 PRE_first_tail_x6_r0_body.P80.lo PRE_first_tail_x6_r0_body.cx0_80.mlx PRE_first_tail_x6_r0_body.cx1_80.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo80 : PRE_first_tail_x6_r0_body.clo80.map (fun h => PRE_first_tail_x6_r0_body.cx1_80.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa80.handle h)) = PRE_first_tail_x6_r0_body.clo80.map (fun h => (PRE_first_tail_x6_r0_body.cx0_80.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa80.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok80 : PRE_first_tail_x6_r0_body.clo80.all (objOK PRE_first_tail_x6_r0_body.kappa80 PRE_first_tail_x6_r0_body.P80.NL PRE_first_tail_x6_r0_body.cx0_80.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd80 : PRE_first_tail_x6_r0_body.cln80.all (nodeOKF PRE_first_tail_x6_r0_body.kappa80 PRE_first_tail_x6_r0_body.P80 PRE_first_tail_x6_r0_body.cx0_80.mlx PRE_first_tail_x6_r0_body.cx1_80.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp80 : ((PRE_first_tail_x6_r0_body.cln80.filter (fullB PRE_first_tail_x6_r0_body.P80))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_80.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa80.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln80.filter (fullB PRE_first_tail_x6_r0_body.P80))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_80.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa80.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI80 : incrB PRE_first_tail_x6_r0_body.kd80.nodeF (List.range' 16870 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK80 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd80.node).all (fun k => Nat.ble 16870 k && Nat.blt k 16870) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL80 : (PRE_first_tail_x6_r0_body.cln80.filter (Nat.ble PRE_first_tail_x6_r0_body.P80.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd80.nodeF i) && (Nat.blt i 16870 || Nat.ble PRE_first_tail_x6_r0_body.kd80.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord80 : (PRE_first_tail_x6_r0_body.cln80.filter (Nat.ble PRE_first_tail_x6_r0_body.P80.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd80.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd80.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd80.nodeF j) (PRE_first_tail_x6_r0_body.kd80.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow80 PRE_first_tail_x6_r0_body.cnn180 PRE_first_tail_x6_r0_body.fnordI80 PRE_first_tail_x6_r0_body.fnordK80 PRE_first_tail_x6_r0_body.fnordL80
kernel_rfl PRE_first_tail_x6_r0_body.fi80 : PRE_first_tail_x6_r0_body.cli80.all (pnB PRE_first_tail_x6_r0_body.cx0_80.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii80 : PRE_first_tail_x6_r0_body.cli80.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_80.mlx.items.get (PRE_first_tail_x6_r0_body.kappa80.node k) = (PRE_first_tail_x6_r0_body.cx0_80.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa80.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot80 (clean : Conv.NClean (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P80.NL) (cl : SSt (· < 3475) PRE_first_tail_x6_r0_body.cx0_80.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P80 3475 PRE_first_tail_x6_r0_body.kappa80 PRE_first_tail_x6_r0_body.kd80 PRE_first_tail_x6_r0_body.khinv80 PRE_first_tail_x6_r0_body.kninv80 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx PRE_first_tail_x6_r0_body.cx0_80.mlx PRE_first_tail_x6_r0_body.cx1_80.mlx (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo80 PRE_first_tail_x6_r0_body.cln80 PRE_first_tail_x6_r0_body.cli80 PRE_first_tail_x6_r0_body.cwS80 PRE_first_tail_x6_r0_body.cnS80 PRE_first_tail_x6_r0_body.ciS80 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh080, PRE_first_tail_x6_r0_body.cnh180, PRE_first_tail_x6_r0_body.cnn080, PRE_first_tail_x6_r0_body.cnn180, PRE_first_tail_x6_r0_body.cplo80, PRE_first_tail_x6_r0_body.ccnt80, PRE_first_tail_x6_r0_body.cnband80, PRE_first_tail_x6_r0_body.chbelow80, PRE_first_tail_x6_r0_body.chren80, PRE_first_tail_x6_r0_body.cband80, PRE_first_tail_x6_r0_body.cnh1pos80, PRE_first_tail_x6_r0_body.cnren80, PRE_first_tail_x6_r0_body.cnlow80, PRE_first_tail_x6_r0_body.cabs0a80, PRE_first_tail_x6_r0_body.cabs0b80, PRE_first_tail_x6_r0_body.ctok180, PRE_first_tail_x6_r0_body.cpend80, PRE_first_tail_x6_r0_body.cerrh80, PRE_first_tail_x6_r0_body.cfiles80, PRE_first_tail_x6_r0_body.carch80, PRE_first_tail_x6_r0_body.csizes80, PRE_first_tail_x6_r0_body.cwired80, PRE_first_tail_x6_r0_body.cfix80, clean, PRE_first_tail_x6_r0_body.fcxn80, PRE_first_tail_x6_r0_body.fcnn80, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle080, PRE_first_tail_x6_r0_body.fnk80, PRE_first_tail_x6_r0_body.ckA80, PRE_first_tail_x6_r0_body.cobjsK80, PRE_first_tail_x6_r0_body.cnodesK80, PRE_first_tail_x6_r0_body.citemsK80, PRE_first_tail_x6_r0_body.f1A80, PRE_first_tail_x6_r0_body.f1O80, PRE_first_tail_x6_r0_body.f1N80, PRE_first_tail_x6_r0_body.f1I80, PRE_first_tail_x6_r0_body.fbd80, PRE_first_tail_x6_r0_body.fincW80, PRE_first_tail_x6_r0_body.fincI80, PRE_first_tail_x6_r0_body.fincN80, PRE_first_tail_x6_r0_body.flnF80, PRE_first_tail_x6_r0_body.fh80, PRE_first_tail_x6_r0_body.fo80, PRE_first_tail_x6_r0_body.fok80, PRE_first_tail_x6_r0_body.fnd80, PRE_first_tail_x6_r0_body.fp80, PRE_first_tail_x6_r0_body.fnord80, PRE_first_tail_x6_r0_body.fi80, PRE_first_tail_x6_r0_body.fii80⟩
theorem PRE_first_tail_x6_r0_body.cnshift80 (clean : Conv.NClean (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P80.NL) (cl : SSt (· < 3475) PRE_first_tail_x6_r0_body.cx0_80.mlx) : NShift PRE_first_tail_x6_r0_body.P80 3475 PRE_first_tail_x6_r0_body.kappa80 PRE_first_tail_x6_r0_body.cx0_80 PRE_first_tail_x6_r0_body.cx1_80 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot80 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost80 (compact_a_eq PRE_first_tail_x6_r0_body.ckn080 PRE_first_tail_x6_r0_body.ckn180 PRE_first_tail_x6_r0_body.ckheap80 PRE_first_tail_x6_r0_body.ckpl80)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_80 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s776.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_80 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s776.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_80 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s776.ffi) = some PRE_first_tail_x6_r0_body.fxC_80
kernel_rfl PRE_first_tail_x6_r0_body.okrC_80 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s776.ffi) = some PRE_first_tail_x6_r0_body.krC_80
noncomputable def PRE_first_tail_x6_r0_body.fx0_80 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s778.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_80 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s778.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_80 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s778.ffi) = some PRE_first_tail_x6_r0_body.fx0_80
kernel_rfl PRE_first_tail_x6_r0_body.okr0_80 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s778.ffi) = some PRE_first_tail_x6_r0_body.kr0_80
noncomputable def PRE_first_tail_x6_r0_body.fx1_80 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s777.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_80 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s777.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_80 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s777.ffi) = some PRE_first_tail_x6_r0_body.fx1_80
kernel_rfl PRE_first_tail_x6_r0_body.okr1_80 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s777.ffi) = some PRE_first_tail_x6_r0_body.kr1_80
kernel_rfl PRE_first_tail_x6_r0_body.ff080 : PRE_first_tail_x6_r0_body.fx0_80 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_80 (PRE_first_tail_x6_r0_body.clo80.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_80.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff180 : PRE_first_tail_x6_r0_body.fx1_80 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_80 (PRE_first_tail_x6_r0_body.cwS80.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_80.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck80 : freedLB PRE_first_tail_x6_r0_body.kappa80 PRE_first_tail_x6_r0_body.cx0_80.mlx PRE_first_tail_x6_r0_body.fx0_80 PRE_first_tail_x6_r0_body.fx1_80 PRE_first_tail_x6_r0_body.clo80 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf080 : PRE_first_tail_x6_r0_body.kr0_80.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_80.flags (PRE_first_tail_x6_r0_body.clo80.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_80.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt080 : PRE_first_tail_x6_r0_body.kr0_80.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_80.targs (PRE_first_tail_x6_r0_body.clo80.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_80.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf180 : PRE_first_tail_x6_r0_body.kr1_80.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_80.flags (PRE_first_tail_x6_r0_body.cwS80.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_80.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt180 : PRE_first_tail_x6_r0_body.kr1_80.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_80.targs (PRE_first_tail_x6_r0_body.cwS80.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_80.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck80 : krecLB PRE_first_tail_x6_r0_body.kappa80 3475 PRE_first_tail_x6_r0_body.cx0_80.mlx PRE_first_tail_x6_r0_body.kr0_80 PRE_first_tail_x6_r0_body.kr1_80 PRE_first_tail_x6_r0_body.clo80 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn80 : Nat.ble 3475 3475 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge80 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s777.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s778.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR80 : pendRegB PRE_first_tail_x6_r0_body.kappa80 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s778.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe80 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s778.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s777.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift80 (clean : Conv.NClean (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P80.NL) (cl : SSt (· < 3475) PRE_first_tail_x6_r0_body.cx0_80.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_80.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_80.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_80.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s776.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_80.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P80 3475 PRE_first_tail_x6_r0_body.kappa80 PRE_first_tail_x6_r0_body.s778.ffi PRE_first_tail_x6_r0_body.s777.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift80 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue80, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp80 t ht),
    PRE_first_tail_x6_r0_body.cbridge80,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s778.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s777.ffi) (PRE_first_tail_x6_r0_body.cfoot80 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_80 PRE_first_tail_x6_r0_body.ofx1_80 hobjC PRE_first_tail_x6_r0_body.ff080 PRE_first_tail_x6_r0_body.ff180 PRE_first_tail_x6_r0_body.ffck80,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s778.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s777.ffi) (PRE_first_tail_x6_r0_body.cfoot80 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_80 PRE_first_tail_x6_r0_body.okr1_80 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn80) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf080 PRE_first_tail_x6_r0_body.fkt080 PRE_first_tail_x6_r0_body.fkf180 PRE_first_tail_x6_r0_body.fkt180 PRE_first_tail_x6_r0_body.fkck80,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh080 PRE_first_tail_x6_r0_body.cnh180 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe80) PRE_first_tail_x6_r0_body.cpendR80⟩

end Host.Load.Run.Tpl
end

section -- st80/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st80 0
host_stream_state PRE_first_tail_x6_r0_body.st80 1
host_stream_state PRE_first_tail_x6_r0_body.st80 2
end Host.Load.Run.Tpl
end

section -- Site80
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 80 of chain `PRE_first_tail_x6_r0_body`: `plan__g80__g81` (`plan`), the call state `PRE_first_tail_x6_r0_body.s776`, the merged state `PRE_first_tail_x6_r0_body.s777`,
the site template `PRE_first_tail_x6_r0_body.st80` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s778`: the merge.
The footprint's facts are in `SiteF80`, the compaction's in `SiteC80`, `SiteK80`, `SiteNa80`, `SiteNb80`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso80 : PRE_first_tail_x6_r0_body.st80.s0 = { PRE_first_tail_x6_r0_body.s776 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs80 : List Frame := PRE_first_tail_x6_r0_body.s776.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_80 : PRE_first_tail_x6_r0_body.S776.tab.length = 3475
kernel_rfl PRE_first_tail_x6_r0_body.tab0_80 : PRE_first_tail_x6_r0_body.st80.S0.tab = PRE_first_tail_x6_r0_body.S776.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws80 : List Nat := [2359, 2360, 2361]
kernel_rfl PRE_first_tail_x6_r0_body.fresh80 : (PRE_first_tail_x6_r0_body.S776.tab.all fun e => PRE_first_tail_x6_r0_body.ws80.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S776.oracle.all fun q => PRE_first_tail_x6_r0_body.ws80.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab80 : PRE_first_tail_x6_r0_body.S777.tab = PRE_first_tail_x6_r0_body.S776.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws80
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen80 : PRE_first_tail_x6_r0_body.st80.S2.tab.length - PRE_first_tail_x6_r0_body.st80.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged80`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap80 : PRE_first_tail_x6_r0_body.s777.heap = PRE_first_tail_x6_r0_body.st80.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext80 : PRE_first_tail_x6_r0_body.s777.next = PRE_first_tail_x6_r0_body.st80.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl80 : PRE_first_tail_x6_r0_body.s777.ctl = PRE_first_tail_x6_r0_body.st80.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack80 : PRE_first_tail_x6_r0_body.s777.stack = PRE_first_tail_x6_r0_body.st80.s2.stack ++ PRE_first_tail_x6_r0_body.s776.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs80 : PRE_first_tail_x6_r0_body.s777.jobs = PRE_first_tail_x6_r0_body.st80.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi80 : PRE_first_tail_x6_r0_body.s777.ffi = PRE_first_tail_x6_r0_body.st80.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace80 : PRE_first_tail_x6_r0_body.s777.trace = PRE_first_tail_x6_r0_body.st80.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores80 : PRE_first_tail_x6_r0_body.s777.stores = PRE_first_tail_x6_r0_body.st80.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD80
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 80 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived80 : PRE_first_tail_x6_r0_body.nr80.map (fun r => nth? PRE_first_tail_x6_r0_body.st80.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo80 : PRE_first_tail_x6_r0_body.nr80.all (Nat.ble 3475) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj80 : PRE_first_tail_x6_r0_body.cws80.all (fun c => !PRE_first_tail_x6_r0_body.ws80.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ80 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws80 PRE_first_tail_x6_r0_body.crs80 PRE_first_tail_x6_r0_body.ws80

end Host.Load.Run.Tpl
end

section -- st80/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st80`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st80.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st80.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st80.s2.heap PRE_first_tail_x6_r0_body.st80.wrR ++ freshOf PRE_first_tail_x6_r0_body.st80.s2.heap PRE_first_tail_x6_r0_body.st80.s0.next PRE_first_tail_x6_r0_body.st80.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st80.wr : List Nat := PRE_first_tail_x6_r0_body.st80.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st80.heapFoot : PRE_first_tail_x6_r0_body.st80.s2.heap = setAll PRE_first_tail_x6_r0_body.st80.s0.heap PRE_first_tail_x6_r0_body.st80.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st80.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st80.s0.next PRE_first_tail_x6_r0_body.st80.s2.next = true
theorem PRE_first_tail_x6_r0_body.st80.grows : PRE_first_tail_x6_r0_body.st80.s0.next ≤ PRE_first_tail_x6_r0_body.st80.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st80.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st80.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st80.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st80.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st80.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st80.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st80.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st80.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st80.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st80.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st80.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st80.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st80.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st80.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st80.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st80.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st80.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st80.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st80.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st80.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st80.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st80.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st80.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st80.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st80.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st80.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st80.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st80.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st80.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st80.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st80.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st80.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF80
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 80 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB80 : nodupT PRE_first_tail_x6_r0_body.st80.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup80 : PRE_first_tail_x6_r0_body.st80.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB80).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB80 : PRE_first_tail_x6_r0_body.st80.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound80 : ∀ b ∈ PRE_first_tail_x6_r0_body.st80.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB80 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr80 := PRE_first_tail_x6_r0_body.st80.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq80 : PRE_first_tail_x6_r0_body.st80.s2.trace = PRE_first_tail_x6_r0_body.trFr80 ++ PRE_first_tail_x6_r0_body.st80.s0.trace
theorem PRE_first_tail_x6_r0_body.trace80 : ∃ fr, PRE_first_tail_x6_r0_body.st80.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st80.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq80⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide80 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB80 : (PRE_first_tail_x6_r0_body.wide80.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st80.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix80 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide80, WFix Map.id (Present PRE_first_tail_x6_r0_body.st80.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB80 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL80
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 80 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s777`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO80 : PRE_first_tail_x6_r0_body.st80.S0.oracle = PRE_first_tail_x6_r0_body.st80.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B80 : PRE_first_tail_x6_r0_body.st80.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st80.s0.next || (PRE_first_tail_x6_r0_body.st80.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot80 : Conv.StageFoot PRE_first_tail_x6_r0_body.st80.wr PRE_first_tail_x6_r0_body.st80.s0 PRE_first_tail_x6_r0_body.st80.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st80.heapFoot PRE_first_tail_x6_r0_body.wrNodup80 PRE_first_tail_x6_r0_body.wrBound80 PRE_first_tail_x6_r0_body.wr0B80 PRE_first_tail_x6_r0_body.st80.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged80 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st80.F.S → PRE_first_tail_x6_r0_body.st80.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st80.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st80.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs80 PRE_first_tail_x6_r0_body.st80.wr PRE_first_tail_x6_r0_body.s776 PRE_first_tail_x6_r0_body.st80.s2 PRE_first_tail_x6_r0_body.st80.s0
      PRE_first_tail_x6_r0_body.st80.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st80.F FR W stk M ν K PRE_first_tail_x6_r0_body.s777 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso80 PRE_first_tail_x6_r0_body.stFoot80 PRE_first_tail_x6_r0_body.wrNodup80 PRE_first_tail_x6_r0_body.wrBound80 PRE_first_tail_x6_r0_body.trace80 PRE_first_tail_x6_r0_body.mheap80
    PRE_first_tail_x6_r0_body.mnext80 PRE_first_tail_x6_r0_body.mctl80 PRE_first_tail_x6_r0_body.mstack80 PRE_first_tail_x6_r0_body.mjobs80 PRE_first_tail_x6_r0_body.mffi80 PRE_first_tail_x6_r0_body.mtrace80 PRE_first_tail_x6_r0_body.mstores80 h

def PRE_first_tail_x6_r0_body.arrEl80_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE80_2665 : arrOf PRE_first_tail_x6_r0_body.s777 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl80_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA80_2665 : isArrB PRE_first_tail_x6_r0_body.s777 2665 = true
theorem PRE_first_tail_x6_r0_body.arr80_2665 : ∃ o, PRE_first_tail_x6_r0_body.s777.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl80_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE80_2665 PRE_first_tail_x6_r0_body.arrA80_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN80_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl80_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR80_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl80_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN80_2665

def PRE_first_tail_x6_r0_body.arrEl80_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE80_2673467 : arrOf PRE_first_tail_x6_r0_body.s777 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl80_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA80_2673467 : isArrB PRE_first_tail_x6_r0_body.s777 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr80_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s777.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl80_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE80_2673467 PRE_first_tail_x6_r0_body.arrA80_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN80_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl80_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR80_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl80_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN80_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k80 : isArrB PRE_first_tail_x6_r0_body.s777 4910 = false
theorem PRE_first_tail_x6_r0_body.keep80 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s777 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k80 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr80_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl80_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ80
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 80 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s776`, the merged
state `PRE_first_tail_x6_r0_body.s777`, the canonical state `PRE_first_tail_x6_r0_body.s778`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl80 : PRE_first_tail_x6_r0_body.pl80.all (Nat.ble PRE_first_tail_x6_r0_body.s776.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd80 : nodupT PRE_first_tail_x6_r0_body.pl80 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn180 : Nat.ble PRE_first_tail_x6_r0_body.s776.next 2737266 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst80 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s776.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn80 : PRE_first_tail_x6_r0_body.s778.next = PRE_first_tail_x6_r0_body.s776.next + PRE_first_tail_x6_r0_body.pl80.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn80 : PRE_first_tail_x6_r0_body.s777.next = 2737266
kernel_rfl PRE_first_tail_x6_r0_body.zgrow80 : Nat.ble PRE_first_tail_x6_r0_body.s778.next PRE_first_tail_x6_r0_body.s777.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh80 : PRE_first_tail_x6_r0_body.S776.tab.all (fun e => PRE_first_tail_x6_r0_body.cws80.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd80 : nodupT PRE_first_tail_x6_r0_body.cws80 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi80 : PRE_first_tail_x6_r0_body.nr80.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S777.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt80 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s776.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg80_2665 : PRE_first_tail_x6_r0_body.s778.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s778 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk80_2665 : (objOf PRE_first_tail_x6_r0_body.s778 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm80_2665 : PRE_first_tail_x6_r0_body.s777.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa80.obj (objOf PRE_first_tail_x6_r0_body.s778 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s777 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg80_2673467 : PRE_first_tail_x6_r0_body.s778.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s778 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk80_2673467 : (objOf PRE_first_tail_x6_r0_body.s778 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm80_2673467 : PRE_first_tail_x6_r0_body.s777.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa80.obj (objOf PRE_first_tail_x6_r0_body.s778 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s777 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw80_4910 : (PRE_first_tail_x6_r0_body.s778.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw80_2673472 : (PRE_first_tail_x6_r0_body.s778.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw80_2673473 : (PRE_first_tail_x6_r0_body.s778.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd80 : PRE_first_tail_x6_r0_body.cl80.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr80 : PRE_first_tail_x6_r0_body.st80.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s776.next || PRE_first_tail_x6_r0_body.cl80.contains b) = true
def PRE_first_tail_x6_r0_body.zl80 : List Nat := PRE_first_tail_x6_r0_body.cl80.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE80 : PRE_first_tail_x6_r0_body.zl80.map (fun a => PRE_first_tail_x6_r0_body.s777.heap.get (PRE_first_tail_x6_r0_body.kappa80.a a)) = PRE_first_tail_x6_r0_body.zl80.map (fun a => (PRE_first_tail_x6_r0_body.s778.heap.get a).map PRE_first_tail_x6_r0_body.kappa80.hobj)
theorem PRE_first_tail_x6_r0_body.zimg80 : HeapImg PRE_first_tail_x6_r0_body.kappa80 PRE_first_tail_x6_r0_body.s778 PRE_first_tail_x6_r0_body.s777 PRE_first_tail_x6_r0_body.zl80 := PRE_first_tail_x6_r0_body.zimgE80
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl80 : PRE_first_tail_x6_r0_body.s777.ctl = PRE_first_tail_x6_r0_body.kappa80.ctl PRE_first_tail_x6_r0_body.s778.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack80 : PRE_first_tail_x6_r0_body.s777.stack = PRE_first_tail_x6_r0_body.s778.stack.map PRE_first_tail_x6_r0_body.kappa80.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs80 : PRE_first_tail_x6_r0_body.s777.jobs = PRE_first_tail_x6_r0_body.s778.jobs.map PRE_first_tail_x6_r0_body.kappa80.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores80 : PRE_first_tail_x6_r0_body.s777.stores = PRE_first_tail_x6_r0_body.kappa80.stores PRE_first_tail_x6_r0_body.s778.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots80 : checkRootsSupp PRE_first_tail_x6_r0_body.s778 3475 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC80 : PRE_first_tail_x6_r0_body.S776.tab.length + PRE_first_tail_x6_r0_body.cws80.length = 3475
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap80 : PRE_first_tail_x6_r0_body.kappa80 = Conv.Map.compact PRE_first_tail_x6_r0_body.s776.next 2737266 PRE_first_tail_x6_r0_body.S776.tab.length PRE_first_tail_x6_r0_body.pl80 (PRE_first_tail_x6_r0_body.nr80.map NumV.ref) PRE_first_tail_x6_r0_body.kd80.big
  PRE_first_tail_x6_r0_body.kd80.region PRE_first_tail_x6_r0_body.kd80.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin80 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s778.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc80 : Conv.jcleanListB (⟨19769, 16870, 2737256, 3475⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s778 PRE_first_tail_x6_r0_body.cl80 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB80 : noBigRootsP (fun i => !Conv.oldBigB (⟨19769, 16870, 2737256, 3475⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s778.trace PRE_first_tail_x6_r0_body.s778 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm80 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 16870 = true
theorem PRE_first_tail_x6_r0_body.cjcl80 (h : Conv.JClean (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s776) : Conv.JClean (⟨19769, 16870, 2737256, 3475⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s778 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle80)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap80 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd80 a ha)) PRE_first_tail_x6_r0_body.zjc80

end Host.Load.Run.Tpl
end

section -- st80/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st80.bodyLast from PRE_first_tail_x6_r0_body.st80.s1 to PRE_first_tail_x6_r0_body.st80.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st80.F PRE_first_tail_x6_r0_body.st80.s1).run PRE_first_tail_x6_r0_body.st80.S1 = some (PRE_first_tail_x6_r0_body.st80.s2, PRE_first_tail_x6_r0_body.st80.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st80.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st80.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st80.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st80.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st80/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st80.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st80.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st80.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st80.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st80.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st80.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st80.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st80.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st80.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st80.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st80.s0 PRE_first_tail_x6_r0_body.st80.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st80.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st80.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st80.s1 PRE_first_tail_x6_r0_body.st80.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st80/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st80.bodyK0F from PRE_first_tail_x6_r0_body.st80.s0 to PRE_first_tail_x6_r0_body.st80.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st80.F (PRE_first_tail_x6_r0_body.st80.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st80.ks 0).getD 0) PRE_first_tail_x6_r0_body.st80.s0 PRE_first_tail_x6_r0_body.st80.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st80.s1, PRE_first_tail_x6_r0_body.st80.S1)
theorem PRE_first_tail_x6_r0_body.st80.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st80.F (PRE_first_tail_x6_r0_body.st80.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st80.ks 0).getD 0) PRE_first_tail_x6_r0_body.st80.s0 PRE_first_tail_x6_r0_body.st80.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st80.s1, PRE_first_tail_x6_r0_body.st80.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st80.bodyOkLN_ok PRE_first_tail_x6_r0_body.st80.bodyK0F
end Host.Load.Run.Tpl
end

section -- st80/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st80.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st80.F (PRE_first_tail_x6_r0_body.st80.bodyOkL bytes rows) 98 PRE_first_tail_x6_r0_body.st80.s0 PRE_first_tail_x6_r0_body.st80.S0 = some (PRE_first_tail_x6_r0_body.st80.s1, PRE_first_tail_x6_r0_body.st80.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st80.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st80.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st80.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st80.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st80.F (PRE_first_tail_x6_r0_body.st80.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st80.s0
  S0 := PRE_first_tail_x6_r0_body.st80.S0
  s1 := PRE_first_tail_x6_r0_body.st80.s1
  S1 := PRE_first_tail_x6_r0_body.st80.S1
  s2 := PRE_first_tail_x6_r0_body.st80.s2
  S2 := PRE_first_tail_x6_r0_body.st80.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st80.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st80.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st80.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st80.bodyHalt
  last := PRE_first_tail_x6_r0_body.st80.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st80.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC81
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 81 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s794` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa81` into the merged state
`PRE_first_tail_x6_r0_body.s793`. -/

def PRE_first_tail_x6_r0_body.pl81 : List Nat := [2739354, 2739190, 2739242, 2739355, 2739356, 2739192, 2739244, 2739353, 2739352, 2739351, 2739350, 2739344, 2739295, 2739346, 2739297]
def PRE_first_tail_x6_r0_body.nr81 : List Nat := [3560, 3561, 3557, 3563, 3559, 3567, 3568, 3565, 3566]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd81 : RData :=
  ⟨2739007, 2739357, Stage.setAll PTrie.nil [(2738992, 2739354), (2738993, 2739190), (2738994, 2739242), (2738995, 2739355), (2738996, 2739356), (2738997, 2739192), (2738998, 2739244), (2738999, 2739353), (2739000, 2739352), (2739001, 2739351), (2739002, 2739350), (2739003, 2739344), (2739004, 2739295), (2739005, 2739346), (2739006, 2739297)], Stage.setAll PTrie.nil [(19809, 19811), (19810, 19812), (19811, 19814), (19812, 19813)],
   19813, 19815, 16904, 16904, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(3552, .ref 3560), (3553, .ref 3561), (3554, .ref 3557), (3555, .ref 3563), (3556, .ref 3559), (3557, .ref 3567), (3558, .ref 3568), (3559, .ref 3565), (3560, .ref 3566)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa81 : Map :=
  Conv.Map.compact 2738992 2739357 3552 PRE_first_tail_x6_r0_body.pl81 (PRE_first_tail_x6_r0_body.nr81.map NumV.ref) PRE_first_tail_x6_r0_body.kd81.big
    PRE_first_tail_x6_r0_body.kd81.region PRE_first_tail_x6_r0_body.kd81.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws81 : List Nat := [2379, 2380, 2381, 2382, 2383, 2384, 2385, 2386, 2387]
noncomputable def PRE_first_tail_x6_r0_body.crs81 : List SymE := PRE_first_tail_x6_r0_body.nr81.map fun r => (nth? PRE_first_tail_x6_r0_body.S793.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta81 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws81 PRE_first_tail_x6_r0_body.crs81
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB81 : List Nat := [2665, 2672508, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab81 : PRE_first_tail_x6_r0_body.S794.tab = PRE_first_tail_x6_r0_body.S792.tab ++ PRE_first_tail_x6_r0_body.cws81.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace81 : PRE_first_tail_x6_r0_body.s794.trace = PRE_first_tail_x6_r0_body.s792.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext81 : PRE_first_tail_x6_r0_body.s794.next = 2739007
kernel_rfl PRE_first_tail_x6_r0_body.ccounters81 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s794.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s794.ffi).mlx.nnext) = (19813, 16904)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue81 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s793.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s794.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa81.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp81 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s794.ffi).mlx.tokens.all (bSN 3561) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean81 : Conv.cleanListB 19813 131072 (fun r => Nat.ble 79252 r) PRE_first_tail_x6_r0_body.s794
    (PRE_first_tail_x6_r0_body.wrB81 ++ (List.range 15).map (2738992 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs81 : bigsOutB 19813 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s794.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK81
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl81`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl81 : List Nat := [2665, 2672508, 2673467, 2738992, 2738993, 2738994, 2738995, 2738996, 2738997, 2738998, 2738999, 2739000, 2739001, 2739002, 2739003, 2739004, 2739005, 2739006]
def PRE_first_tail_x6_r0_body.clo81 : List Nat := [19809, 19810, 19811, 19812]
def PRE_first_tail_x6_r0_body.cln81 : List Nat := [16898, 16899, 16900, 16901, 16902, 16903]
def PRE_first_tail_x6_r0_body.cli81 : List Nat := [16898, 16899, 16900, 16901, 16902, 16903]
kernel_rfl PRE_first_tail_x6_r0_body.cheap81 : PRE_first_tail_x6_r0_body.s794.heap = Stage.setAll PRE_first_tail_x6_r0_body.s792.heap (PRE_first_tail_x6_r0_body.cl81.filterMap fun a => (PRE_first_tail_x6_r0_body.s794.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe81 : Nat.ble PRE_first_tail_x6_r0_body.s792.next PRE_first_tail_x6_r0_body.s794.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP81 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s792 PRE_first_tail_x6_r0_body.s794 PRE_first_tail_x6_r0_body.cl81 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp81 : Conv.suppListB PRE_first_tail_x6_r0_body.s794 3561 PRE_first_tail_x6_r0_body.cl81 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound81 : Conv.boundListB PRE_first_tail_x6_r0_body.s794 PRE_first_tail_x6_r0_body.cl81 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK81 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s794.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln81.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s794.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK81 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s794.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo81.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s794.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK81 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s794.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli81.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s794.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst81 : Conv.sstListB 3561 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s794.ffi).mlx PRE_first_tail_x6_r0_body.cln81 PRE_first_tail_x6_r0_body.clo81 PRE_first_tail_x6_r0_body.cli81 = true

end Host.Load.Run.Tpl
end

section -- SiteCl81
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA81 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s794.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo81.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s794.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd81 : (PRE_first_tail_x6_r0_body.clo81 ++ PRE_first_tail_x6_r0_body.cln81 ++ PRE_first_tail_x6_r0_body.cli81).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle81 : Conv.Cnt.leB (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt) (⟨19813, 16904, 2739007, 3561⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck81 : Conv.ncleanListB (⟨19813, 16904, 2739007, 3561⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s794.ffi).mlx PRE_first_tail_x6_r0_body.clo81 PRE_first_tail_x6_r0_body.cln81 PRE_first_tail_x6_r0_body.cli81 = true
theorem PRE_first_tail_x6_r0_body.cncl81 (h : Conv.NClean (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx) : Conv.NClean (⟨19813, 16904, 2739007, 3561⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s794.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle81 PRE_first_tail_x6_r0_body.ckA81 PRE_first_tail_x6_r0_body.cobjsK81 PRE_first_tail_x6_r0_body.cnodesK81 PRE_first_tail_x6_r0_body.citemsK81 PRE_first_tail_x6_r0_body.cbd81 PRE_first_tail_x6_r0_body.cck81

end Host.Load.Run.Tpl
end

section -- SiteS81
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 81 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc81 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P81 : LoadP := PRE_first_tail_x6_r0_body.Pc81.raise 16904
kernel_rfl PRE_first_tail_x6_r0_body.craise81 : Nat.ble PRE_first_tail_x6_r0_body.Pc81.N0 16904 = true
theorem PRE_first_tail_x6_r0_body.raised81 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc81 PRE_first_tail_x6_r0_body.P81 :=
  .inr ⟨16904, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise81, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_81 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s794.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_81 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s793.ffi)
def PRE_first_tail_x6_r0_body.khinv81 : PTrie Nat := Stage.setAll PTrie.nil [(19811, 19809), (19812, 19810), (19814, 19811), (19813, 19812)]
def PRE_first_tail_x6_r0_body.kninv81 : PTrie Nat := Stage.setAll PTrie.nil [(16898, 16898), (16899, 16899), (16900, 16900), (16901, 16901), (16902, 16902), (16903, 16903)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS81 : List Nat := [19809, 19810, 19811, 19812, 19813, 19814]
def PRE_first_tail_x6_r0_body.cnS81 : List Nat := List.range' 16898 6
def PRE_first_tail_x6_r0_body.ciS81 : List Nat := [] ++ List.range' 16898 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh081 : PRE_first_tail_x6_r0_body.kd81.nh0 = PRE_first_tail_x6_r0_body.cx0_81.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh181 : PRE_first_tail_x6_r0_body.kd81.nh1 = PRE_first_tail_x6_r0_body.cx1_81.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn081 : PRE_first_tail_x6_r0_body.kd81.nn0 = PRE_first_tail_x6_r0_body.cx0_81.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn181 : PRE_first_tail_x6_r0_body.kd81.nn1 = PRE_first_tail_x6_r0_body.cx1_81.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo81 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P81.lo && Nat.ble PRE_first_tail_x6_r0_body.P81.lo PRE_first_tail_x6_r0_body.cx0_81.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P81.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P81.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt81 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_81.mlx.next PRE_first_tail_x6_r0_body.cx1_81.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_81.mlx.nnext PRE_first_tail_x6_r0_body.cx1_81.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband81 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P81.NL && Nat.ble PRE_first_tail_x6_r0_body.P81.NL PRE_first_tail_x6_r0_body.P81.N0 && Nat.ble PRE_first_tail_x6_r0_body.P81.N0 PRE_first_tail_x6_r0_body.cx0_81.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow81 : PRE_first_tail_x6_r0_body.kd81.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren81 : checkRenG PRE_first_tail_x6_r0_body.kd81.hnd PRE_first_tail_x6_r0_body.khinv81 (phB PRE_first_tail_x6_r0_body.cx0_81.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband81 : PRE_first_tail_x6_r0_body.kd81.checkBand PRE_first_tail_x6_r0_body.P81.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos81 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd81.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren81 : checkRenG PRE_first_tail_x6_r0_body.kd81.node PRE_first_tail_x6_r0_body.kninv81 (pnB PRE_first_tail_x6_r0_body.cx0_81.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow81 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd81.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P81.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd81.nodeF j) PRE_first_tail_x6_r0_body.cx1_81.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a81 : PRE_first_tail_x6_r0_body.cx0_81.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b81 : PRE_first_tail_x6_r0_body.cx0_81.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok181 : PRE_first_tail_x6_r0_body.cx1_81.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend81 : PRE_first_tail_x6_r0_body.cx1_81.mlx.pending = PRE_first_tail_x6_r0_body.cx0_81.mlx.pending.map PRE_first_tail_x6_r0_body.kappa81.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh81 : PRE_first_tail_x6_r0_body.cx1_81.mlx.errh = PRE_first_tail_x6_r0_body.cx0_81.mlx.errh.map PRE_first_tail_x6_r0_body.kappa81.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles81 : PRE_first_tail_x6_r0_body.cx1_81.mlx.files = PRE_first_tail_x6_r0_body.cx0_81.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch81 : PRE_first_tail_x6_r0_body.cx1_81.mlx.arch = PRE_first_tail_x6_r0_body.cx0_81.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes81 : PRE_first_tail_x6_r0_body.cx1_81.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_81.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired81 : PRE_first_tail_x6_r0_body.cx1_81.mlx.wired = PRE_first_tail_x6_r0_body.cx0_81.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost81 : PRE_first_tail_x6_r0_body.cx1_81.host = PRE_first_tail_x6_r0_body.cx0_81.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd81`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn081 : PRE_first_tail_x6_r0_body.kd81.n0 = 2739007
kernel_rfl PRE_first_tail_x6_r0_body.ckn181 : PRE_first_tail_x6_r0_body.kd81.n1 = 2739357
kernel_rfl PRE_first_tail_x6_r0_body.ckheap81 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd81.heap).all (fun x => Nat.ble 2738992 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl81 : (List.range 15).all (fun j => decide (PRE_first_tail_x6_r0_body.kd81.heap.get (2738992 + j) = nth? PRE_first_tail_x6_r0_body.pl81 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja81 : Nat.ble 2738992 2738992 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn81 : Nat.ble 3552 3552 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD81 : Nat.ble 2738992 PRE_first_tail_x6_r0_body.kd81.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn81 : Nat.ble 19809 PRE_first_tail_x6_r0_body.kd81.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn81 : Nat.ble 16898 PRE_first_tail_x6_r0_body.kd81.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb81 : Nat.ble 19809 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap81 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd81.heap).all (Nat.ble (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd81 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd81.hnd).all (Nat.ble (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode81 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd81.node).all (Nat.ble (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix81 : Conv.FixOld (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa81 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja81) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn81) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD81) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn81) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn81) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb81) PRE_first_tail_x6_r0_body.fheap81 PRE_first_tail_x6_r0_body.fhnd81 PRE_first_tail_x6_r0_body.fnode81
kernel_rfl PRE_first_tail_x6_r0_body.fcxn81 : (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn81 : (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle081 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_81.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_81.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk81 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd81.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A81 : PRE_first_tail_x6_r0_body.cx1_81.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS81.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_81.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O81 : PRE_first_tail_x6_r0_body.cx1_81.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS81.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_81.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N81 : PRE_first_tail_x6_r0_body.cx1_81.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS81.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_81.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I81 : PRE_first_tail_x6_r0_body.cx1_81.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS81.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_81.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd81 : (PRE_first_tail_x6_r0_body.clo81 ++ PRE_first_tail_x6_r0_body.cln81 ++ PRE_first_tail_x6_r0_body.cli81 ++ PRE_first_tail_x6_r0_body.cwS81 ++ PRE_first_tail_x6_r0_body.cnS81 ++ PRE_first_tail_x6_r0_body.ciS81).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW81 : PRE_first_tail_x6_r0_body.cwS81.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo81.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI81 : PRE_first_tail_x6_r0_body.ciS81.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli81.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN81 : PRE_first_tail_x6_r0_body.cnS81.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF81 : PRE_first_tail_x6_r0_body.cln81.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh81 : PRE_first_tail_x6_r0_body.clo81.all (handleOK PRE_first_tail_x6_r0_body.kappa81 PRE_first_tail_x6_r0_body.P81.lo PRE_first_tail_x6_r0_body.cx0_81.mlx PRE_first_tail_x6_r0_body.cx1_81.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo81 : PRE_first_tail_x6_r0_body.clo81.map (fun h => PRE_first_tail_x6_r0_body.cx1_81.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa81.handle h)) = PRE_first_tail_x6_r0_body.clo81.map (fun h => (PRE_first_tail_x6_r0_body.cx0_81.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa81.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok81 : PRE_first_tail_x6_r0_body.clo81.all (objOK PRE_first_tail_x6_r0_body.kappa81 PRE_first_tail_x6_r0_body.P81.NL PRE_first_tail_x6_r0_body.cx0_81.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd81 : PRE_first_tail_x6_r0_body.cln81.all (nodeOKF PRE_first_tail_x6_r0_body.kappa81 PRE_first_tail_x6_r0_body.P81 PRE_first_tail_x6_r0_body.cx0_81.mlx PRE_first_tail_x6_r0_body.cx1_81.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp81 : ((PRE_first_tail_x6_r0_body.cln81.filter (fullB PRE_first_tail_x6_r0_body.P81))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_81.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa81.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln81.filter (fullB PRE_first_tail_x6_r0_body.P81))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_81.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa81.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI81 : incrB PRE_first_tail_x6_r0_body.kd81.nodeF (List.range' 16898 6) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK81 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd81.node).all (fun k => Nat.ble 16898 k && Nat.blt k 16904) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL81 : (PRE_first_tail_x6_r0_body.cln81.filter (Nat.ble PRE_first_tail_x6_r0_body.P81.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd81.nodeF i) && (Nat.blt i 16904 || Nat.ble PRE_first_tail_x6_r0_body.kd81.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord81 : (PRE_first_tail_x6_r0_body.cln81.filter (Nat.ble PRE_first_tail_x6_r0_body.P81.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd81.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd81.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd81.nodeF j) (PRE_first_tail_x6_r0_body.kd81.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow81 PRE_first_tail_x6_r0_body.cnn181 PRE_first_tail_x6_r0_body.fnordI81 PRE_first_tail_x6_r0_body.fnordK81 PRE_first_tail_x6_r0_body.fnordL81
kernel_rfl PRE_first_tail_x6_r0_body.fi81 : PRE_first_tail_x6_r0_body.cli81.all (pnB PRE_first_tail_x6_r0_body.cx0_81.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii81 : PRE_first_tail_x6_r0_body.cli81.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_81.mlx.items.get (PRE_first_tail_x6_r0_body.kappa81.node k) = (PRE_first_tail_x6_r0_body.cx0_81.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa81.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot81 (clean : Conv.NClean (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P81.NL) (cl : SSt (· < 3561) PRE_first_tail_x6_r0_body.cx0_81.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P81 3561 PRE_first_tail_x6_r0_body.kappa81 PRE_first_tail_x6_r0_body.kd81 PRE_first_tail_x6_r0_body.khinv81 PRE_first_tail_x6_r0_body.kninv81 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx PRE_first_tail_x6_r0_body.cx0_81.mlx PRE_first_tail_x6_r0_body.cx1_81.mlx (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo81 PRE_first_tail_x6_r0_body.cln81 PRE_first_tail_x6_r0_body.cli81 PRE_first_tail_x6_r0_body.cwS81 PRE_first_tail_x6_r0_body.cnS81 PRE_first_tail_x6_r0_body.ciS81 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh081, PRE_first_tail_x6_r0_body.cnh181, PRE_first_tail_x6_r0_body.cnn081, PRE_first_tail_x6_r0_body.cnn181, PRE_first_tail_x6_r0_body.cplo81, PRE_first_tail_x6_r0_body.ccnt81, PRE_first_tail_x6_r0_body.cnband81, PRE_first_tail_x6_r0_body.chbelow81, PRE_first_tail_x6_r0_body.chren81, PRE_first_tail_x6_r0_body.cband81, PRE_first_tail_x6_r0_body.cnh1pos81, PRE_first_tail_x6_r0_body.cnren81, PRE_first_tail_x6_r0_body.cnlow81, PRE_first_tail_x6_r0_body.cabs0a81, PRE_first_tail_x6_r0_body.cabs0b81, PRE_first_tail_x6_r0_body.ctok181, PRE_first_tail_x6_r0_body.cpend81, PRE_first_tail_x6_r0_body.cerrh81, PRE_first_tail_x6_r0_body.cfiles81, PRE_first_tail_x6_r0_body.carch81, PRE_first_tail_x6_r0_body.csizes81, PRE_first_tail_x6_r0_body.cwired81, PRE_first_tail_x6_r0_body.cfix81, clean, PRE_first_tail_x6_r0_body.fcxn81, PRE_first_tail_x6_r0_body.fcnn81, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle081, PRE_first_tail_x6_r0_body.fnk81, PRE_first_tail_x6_r0_body.ckA81, PRE_first_tail_x6_r0_body.cobjsK81, PRE_first_tail_x6_r0_body.cnodesK81, PRE_first_tail_x6_r0_body.citemsK81, PRE_first_tail_x6_r0_body.f1A81, PRE_first_tail_x6_r0_body.f1O81, PRE_first_tail_x6_r0_body.f1N81, PRE_first_tail_x6_r0_body.f1I81, PRE_first_tail_x6_r0_body.fbd81, PRE_first_tail_x6_r0_body.fincW81, PRE_first_tail_x6_r0_body.fincI81, PRE_first_tail_x6_r0_body.fincN81, PRE_first_tail_x6_r0_body.flnF81, PRE_first_tail_x6_r0_body.fh81, PRE_first_tail_x6_r0_body.fo81, PRE_first_tail_x6_r0_body.fok81, PRE_first_tail_x6_r0_body.fnd81, PRE_first_tail_x6_r0_body.fp81, PRE_first_tail_x6_r0_body.fnord81, PRE_first_tail_x6_r0_body.fi81, PRE_first_tail_x6_r0_body.fii81⟩
theorem PRE_first_tail_x6_r0_body.cnshift81 (clean : Conv.NClean (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P81.NL) (cl : SSt (· < 3561) PRE_first_tail_x6_r0_body.cx0_81.mlx) : NShift PRE_first_tail_x6_r0_body.P81 3561 PRE_first_tail_x6_r0_body.kappa81 PRE_first_tail_x6_r0_body.cx0_81 PRE_first_tail_x6_r0_body.cx1_81 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot81 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost81 (compact_a_eq PRE_first_tail_x6_r0_body.ckn081 PRE_first_tail_x6_r0_body.ckn181 PRE_first_tail_x6_r0_body.ckheap81 PRE_first_tail_x6_r0_body.ckpl81)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_81 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s792.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_81 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s792.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_81 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s792.ffi) = some PRE_first_tail_x6_r0_body.fxC_81
kernel_rfl PRE_first_tail_x6_r0_body.okrC_81 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s792.ffi) = some PRE_first_tail_x6_r0_body.krC_81
noncomputable def PRE_first_tail_x6_r0_body.fx0_81 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s794.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_81 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s794.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_81 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s794.ffi) = some PRE_first_tail_x6_r0_body.fx0_81
kernel_rfl PRE_first_tail_x6_r0_body.okr0_81 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s794.ffi) = some PRE_first_tail_x6_r0_body.kr0_81
noncomputable def PRE_first_tail_x6_r0_body.fx1_81 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s793.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_81 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s793.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_81 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s793.ffi) = some PRE_first_tail_x6_r0_body.fx1_81
kernel_rfl PRE_first_tail_x6_r0_body.okr1_81 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s793.ffi) = some PRE_first_tail_x6_r0_body.kr1_81
kernel_rfl PRE_first_tail_x6_r0_body.ff081 : PRE_first_tail_x6_r0_body.fx0_81 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_81 (PRE_first_tail_x6_r0_body.clo81.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_81.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff181 : PRE_first_tail_x6_r0_body.fx1_81 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_81 (PRE_first_tail_x6_r0_body.cwS81.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_81.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck81 : freedLB PRE_first_tail_x6_r0_body.kappa81 PRE_first_tail_x6_r0_body.cx0_81.mlx PRE_first_tail_x6_r0_body.fx0_81 PRE_first_tail_x6_r0_body.fx1_81 PRE_first_tail_x6_r0_body.clo81 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf081 : PRE_first_tail_x6_r0_body.kr0_81.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_81.flags (PRE_first_tail_x6_r0_body.clo81.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_81.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt081 : PRE_first_tail_x6_r0_body.kr0_81.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_81.targs (PRE_first_tail_x6_r0_body.clo81.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_81.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf181 : PRE_first_tail_x6_r0_body.kr1_81.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_81.flags (PRE_first_tail_x6_r0_body.cwS81.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_81.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt181 : PRE_first_tail_x6_r0_body.kr1_81.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_81.targs (PRE_first_tail_x6_r0_body.cwS81.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_81.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck81 : krecLB PRE_first_tail_x6_r0_body.kappa81 3561 PRE_first_tail_x6_r0_body.cx0_81.mlx PRE_first_tail_x6_r0_body.kr0_81 PRE_first_tail_x6_r0_body.kr1_81 PRE_first_tail_x6_r0_body.clo81 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn81 : Nat.ble 3552 3561 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge81 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s793.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s794.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR81 : pendRegB PRE_first_tail_x6_r0_body.kappa81 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s794.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe81 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s794.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s793.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift81 (clean : Conv.NClean (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P81.NL) (cl : SSt (· < 3561) PRE_first_tail_x6_r0_body.cx0_81.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_81.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_81.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_81.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s792.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_81.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P81 3561 PRE_first_tail_x6_r0_body.kappa81 PRE_first_tail_x6_r0_body.s794.ffi PRE_first_tail_x6_r0_body.s793.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift81 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue81, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp81 t ht),
    PRE_first_tail_x6_r0_body.cbridge81,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s794.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s793.ffi) (PRE_first_tail_x6_r0_body.cfoot81 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_81 PRE_first_tail_x6_r0_body.ofx1_81 hobjC PRE_first_tail_x6_r0_body.ff081 PRE_first_tail_x6_r0_body.ff181 PRE_first_tail_x6_r0_body.ffck81,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s794.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s793.ffi) (PRE_first_tail_x6_r0_body.cfoot81 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_81 PRE_first_tail_x6_r0_body.okr1_81 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn81) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf081 PRE_first_tail_x6_r0_body.fkt081 PRE_first_tail_x6_r0_body.fkf181 PRE_first_tail_x6_r0_body.fkt181 PRE_first_tail_x6_r0_body.fkck81,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh081 PRE_first_tail_x6_r0_body.cnh181 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe81) PRE_first_tail_x6_r0_body.cpendR81⟩

end Host.Load.Run.Tpl
end

section -- st81/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st81 0
host_stream_state PRE_first_tail_x6_r0_body.st81 1
host_stream_state PRE_first_tail_x6_r0_body.st81 2
host_stream_state PRE_first_tail_x6_r0_body.st81 3
end Host.Load.Run.Tpl
end

section -- Site81
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 81 of chain `PRE_first_tail_x6_r0_body`: `kvW__g81__g82` (`appendWindow`), the call state `PRE_first_tail_x6_r0_body.s792`, the merged state `PRE_first_tail_x6_r0_body.s793`,
the site template `PRE_first_tail_x6_r0_body.st81` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s794`: the merge.
The footprint's facts are in `SiteF81`, the compaction's in `SiteC81`, `SiteK81`, `SiteNa81`, `SiteNb81`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso81 : PRE_first_tail_x6_r0_body.st81.s0 = { PRE_first_tail_x6_r0_body.s792 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs81 : List Frame := PRE_first_tail_x6_r0_body.s792.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_81 : PRE_first_tail_x6_r0_body.S792.tab.length = 3552
kernel_rfl PRE_first_tail_x6_r0_body.tab0_81 : PRE_first_tail_x6_r0_body.st81.S0.tab = PRE_first_tail_x6_r0_body.S792.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws81 : List Nat := [2362, 2363, 2364, 2365, 2366, 2367, 2368, 2369, 2370, 2371, 2372, 2373, 2374, 2375, 2376, 2377, 2378]
kernel_rfl PRE_first_tail_x6_r0_body.fresh81 : (PRE_first_tail_x6_r0_body.S792.tab.all fun e => PRE_first_tail_x6_r0_body.ws81.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S792.oracle.all fun q => PRE_first_tail_x6_r0_body.ws81.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab81 : PRE_first_tail_x6_r0_body.S793.tab = PRE_first_tail_x6_r0_body.S792.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws81
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen81 : PRE_first_tail_x6_r0_body.st81.S3.tab.length - PRE_first_tail_x6_r0_body.st81.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged81`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap81 : PRE_first_tail_x6_r0_body.s793.heap = PRE_first_tail_x6_r0_body.st81.s3.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext81 : PRE_first_tail_x6_r0_body.s793.next = PRE_first_tail_x6_r0_body.st81.s3.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl81 : PRE_first_tail_x6_r0_body.s793.ctl = PRE_first_tail_x6_r0_body.st81.s3.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack81 : PRE_first_tail_x6_r0_body.s793.stack = PRE_first_tail_x6_r0_body.st81.s3.stack ++ PRE_first_tail_x6_r0_body.s792.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs81 : PRE_first_tail_x6_r0_body.s793.jobs = PRE_first_tail_x6_r0_body.st81.s3.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi81 : PRE_first_tail_x6_r0_body.s793.ffi = PRE_first_tail_x6_r0_body.st81.s3.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace81 : PRE_first_tail_x6_r0_body.s793.trace = PRE_first_tail_x6_r0_body.st81.s3.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores81 : PRE_first_tail_x6_r0_body.s793.stores = PRE_first_tail_x6_r0_body.st81.s3.stores

end Host.Load.Run.Tpl
end

section -- SiteD81
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 81 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived81 : PRE_first_tail_x6_r0_body.nr81.map (fun r => nth? PRE_first_tail_x6_r0_body.st81.S3.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false)))]
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo81 : PRE_first_tail_x6_r0_body.nr81.all (Nat.ble 3552) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj81 : PRE_first_tail_x6_r0_body.cws81.all (fun c => !PRE_first_tail_x6_r0_body.ws81.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ81 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws81 PRE_first_tail_x6_r0_body.crs81 PRE_first_tail_x6_r0_body.ws81

end Host.Load.Run.Tpl
end

section -- st81/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st81`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st81.wrR : List (Nat × Nat) := [(2672508, 2672509)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st81.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st81.s3.heap PRE_first_tail_x6_r0_body.st81.wrR ++ freshOf PRE_first_tail_x6_r0_body.st81.s3.heap PRE_first_tail_x6_r0_body.st81.s0.next PRE_first_tail_x6_r0_body.st81.s3.next
noncomputable def PRE_first_tail_x6_r0_body.st81.wr : List Nat := PRE_first_tail_x6_r0_body.st81.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st81.heapFoot : PRE_first_tail_x6_r0_body.st81.s3.heap = setAll PRE_first_tail_x6_r0_body.st81.s0.heap PRE_first_tail_x6_r0_body.st81.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st81.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st81.s0.next PRE_first_tail_x6_r0_body.st81.s3.next = true
theorem PRE_first_tail_x6_r0_body.st81.grows : PRE_first_tail_x6_r0_body.st81.s0.next ≤ PRE_first_tail_x6_r0_body.st81.s3.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st81.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st81.wh : List Nat := [19809, 19810, 19811, 19812, 19813, 19814]
def PRE_first_tail_x6_r0_body.st81.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st81.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st81.s3.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st81.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st81.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st81.s3.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st81.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st81.s3.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st81.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st81.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st81.s3.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st81.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st81.s3.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st81.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st81.s3.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st81.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st81.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st81.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st81.s3.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st81.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st81.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st81.s3.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st81.s3.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st81.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st81.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st81.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st81.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st81.s3.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st81.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st81.s3.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF81
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 81 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB81 : nodupT PRE_first_tail_x6_r0_body.st81.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup81 : PRE_first_tail_x6_r0_body.st81.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB81).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB81 : PRE_first_tail_x6_r0_body.st81.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound81 : ∀ b ∈ PRE_first_tail_x6_r0_body.st81.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB81 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr81 := PRE_first_tail_x6_r0_body.st81.s3.trace.take 26
kernel_rfl PRE_first_tail_x6_r0_body.traceEq81 : PRE_first_tail_x6_r0_body.st81.s3.trace = PRE_first_tail_x6_r0_body.trFr81 ++ PRE_first_tail_x6_r0_body.st81.s0.trace
theorem PRE_first_tail_x6_r0_body.trace81 : ∃ fr, PRE_first_tail_x6_r0_body.st81.s3.trace = fr ++ PRE_first_tail_x6_r0_body.st81.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq81⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide81 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB81 : (PRE_first_tail_x6_r0_body.wide81.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st81.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix81 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide81, WFix Map.id (Present PRE_first_tail_x6_r0_body.st81.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB81 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL81
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 81 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s793`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO81 : PRE_first_tail_x6_r0_body.st81.S0.oracle = PRE_first_tail_x6_r0_body.st81.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B81 : PRE_first_tail_x6_r0_body.st81.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st81.s0.next || (PRE_first_tail_x6_r0_body.st81.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot81 : Conv.StageFoot PRE_first_tail_x6_r0_body.st81.wr PRE_first_tail_x6_r0_body.st81.s0 PRE_first_tail_x6_r0_body.st81.s3 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st81.heapFoot PRE_first_tail_x6_r0_body.wrNodup81 PRE_first_tail_x6_r0_body.wrBound81 PRE_first_tail_x6_r0_body.wr0B81 PRE_first_tail_x6_r0_body.st81.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged81 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st81.F.S → PRE_first_tail_x6_r0_body.st81.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st81.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st81.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs81 PRE_first_tail_x6_r0_body.st81.wr PRE_first_tail_x6_r0_body.s792 PRE_first_tail_x6_r0_body.st81.s3 PRE_first_tail_x6_r0_body.st81.s0
      PRE_first_tail_x6_r0_body.st81.s3.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st81.F FR W stk M ν K PRE_first_tail_x6_r0_body.s793 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso81 PRE_first_tail_x6_r0_body.stFoot81 PRE_first_tail_x6_r0_body.wrNodup81 PRE_first_tail_x6_r0_body.wrBound81 PRE_first_tail_x6_r0_body.trace81 PRE_first_tail_x6_r0_body.mheap81
    PRE_first_tail_x6_r0_body.mnext81 PRE_first_tail_x6_r0_body.mctl81 PRE_first_tail_x6_r0_body.mstack81 PRE_first_tail_x6_r0_body.mjobs81 PRE_first_tail_x6_r0_body.mffi81 PRE_first_tail_x6_r0_body.mtrace81 PRE_first_tail_x6_r0_body.mstores81 h

def PRE_first_tail_x6_r0_body.arrEl81_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE81_2665 : arrOf PRE_first_tail_x6_r0_body.s793 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl81_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA81_2665 : isArrB PRE_first_tail_x6_r0_body.s793 2665 = true
theorem PRE_first_tail_x6_r0_body.arr81_2665 : ∃ o, PRE_first_tail_x6_r0_body.s793.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl81_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE81_2665 PRE_first_tail_x6_r0_body.arrA81_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN81_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl81_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR81_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl81_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN81_2665

def PRE_first_tail_x6_r0_body.arrEl81_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE81_2673467 : arrOf PRE_first_tail_x6_r0_body.s793 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl81_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA81_2673467 : isArrB PRE_first_tail_x6_r0_body.s793 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr81_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s793.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl81_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE81_2673467 PRE_first_tail_x6_r0_body.arrA81_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN81_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl81_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR81_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl81_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN81_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k81 : isArrB PRE_first_tail_x6_r0_body.s793 4910 = false
theorem PRE_first_tail_x6_r0_body.keep81 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s793 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k81 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr81_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl81_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ81
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 81 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s792`, the merged
state `PRE_first_tail_x6_r0_body.s793`, the canonical state `PRE_first_tail_x6_r0_body.s794`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl81 : PRE_first_tail_x6_r0_body.pl81.all (Nat.ble PRE_first_tail_x6_r0_body.s792.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd81 : nodupT PRE_first_tail_x6_r0_body.pl81 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn181 : Nat.ble PRE_first_tail_x6_r0_body.s792.next 2739357 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst81 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s792.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn81 : PRE_first_tail_x6_r0_body.s794.next = PRE_first_tail_x6_r0_body.s792.next + PRE_first_tail_x6_r0_body.pl81.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn81 : PRE_first_tail_x6_r0_body.s793.next = 2739357
kernel_rfl PRE_first_tail_x6_r0_body.zgrow81 : Nat.ble PRE_first_tail_x6_r0_body.s794.next PRE_first_tail_x6_r0_body.s793.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh81 : PRE_first_tail_x6_r0_body.S792.tab.all (fun e => PRE_first_tail_x6_r0_body.cws81.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd81 : nodupT PRE_first_tail_x6_r0_body.cws81 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi81 : PRE_first_tail_x6_r0_body.nr81.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S793.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt81 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s792.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg81_2665 : PRE_first_tail_x6_r0_body.s794.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s794 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk81_2665 : (objOf PRE_first_tail_x6_r0_body.s794 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm81_2665 : PRE_first_tail_x6_r0_body.s793.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa81.obj (objOf PRE_first_tail_x6_r0_body.s794 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s793 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg81_2673467 : PRE_first_tail_x6_r0_body.s794.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s794 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk81_2673467 : (objOf PRE_first_tail_x6_r0_body.s794 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm81_2673467 : PRE_first_tail_x6_r0_body.s793.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa81.obj (objOf PRE_first_tail_x6_r0_body.s794 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s793 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw81_4910 : (PRE_first_tail_x6_r0_body.s794.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw81_2673472 : (PRE_first_tail_x6_r0_body.s794.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw81_2673473 : (PRE_first_tail_x6_r0_body.s794.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd81 : PRE_first_tail_x6_r0_body.cl81.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr81 : PRE_first_tail_x6_r0_body.st81.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s792.next || PRE_first_tail_x6_r0_body.cl81.contains b) = true
def PRE_first_tail_x6_r0_body.zl81 : List Nat := PRE_first_tail_x6_r0_body.cl81.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE81 : PRE_first_tail_x6_r0_body.zl81.map (fun a => PRE_first_tail_x6_r0_body.s793.heap.get (PRE_first_tail_x6_r0_body.kappa81.a a)) = PRE_first_tail_x6_r0_body.zl81.map (fun a => (PRE_first_tail_x6_r0_body.s794.heap.get a).map PRE_first_tail_x6_r0_body.kappa81.hobj)
theorem PRE_first_tail_x6_r0_body.zimg81 : HeapImg PRE_first_tail_x6_r0_body.kappa81 PRE_first_tail_x6_r0_body.s794 PRE_first_tail_x6_r0_body.s793 PRE_first_tail_x6_r0_body.zl81 := PRE_first_tail_x6_r0_body.zimgE81
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl81 : PRE_first_tail_x6_r0_body.s793.ctl = PRE_first_tail_x6_r0_body.kappa81.ctl PRE_first_tail_x6_r0_body.s794.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack81 : PRE_first_tail_x6_r0_body.s793.stack = PRE_first_tail_x6_r0_body.s794.stack.map PRE_first_tail_x6_r0_body.kappa81.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs81 : PRE_first_tail_x6_r0_body.s793.jobs = PRE_first_tail_x6_r0_body.s794.jobs.map PRE_first_tail_x6_r0_body.kappa81.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores81 : PRE_first_tail_x6_r0_body.s793.stores = PRE_first_tail_x6_r0_body.kappa81.stores PRE_first_tail_x6_r0_body.s794.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots81 : checkRootsSupp PRE_first_tail_x6_r0_body.s794 3561 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC81 : PRE_first_tail_x6_r0_body.S792.tab.length + PRE_first_tail_x6_r0_body.cws81.length = 3561
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap81 : PRE_first_tail_x6_r0_body.kappa81 = Conv.Map.compact PRE_first_tail_x6_r0_body.s792.next 2739357 PRE_first_tail_x6_r0_body.S792.tab.length PRE_first_tail_x6_r0_body.pl81 (PRE_first_tail_x6_r0_body.nr81.map NumV.ref) PRE_first_tail_x6_r0_body.kd81.big
  PRE_first_tail_x6_r0_body.kd81.region PRE_first_tail_x6_r0_body.kd81.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin81 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s794.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc81 : Conv.jcleanListB (⟨19813, 16904, 2739007, 3561⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s794 PRE_first_tail_x6_r0_body.cl81 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB81 : noBigRootsP (fun i => !Conv.oldBigB (⟨19813, 16904, 2739007, 3561⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s794.trace PRE_first_tail_x6_r0_body.s794 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm81 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 16898 = true
theorem PRE_first_tail_x6_r0_body.cjcl81 (h : Conv.JClean (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s792) : Conv.JClean (⟨19813, 16904, 2739007, 3561⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s794 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle81)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap81 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd81 a ha)) PRE_first_tail_x6_r0_body.zjc81

end Host.Load.Run.Tpl
end

section -- st81/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st81.bodyLast from PRE_first_tail_x6_r0_body.st81.s2 to PRE_first_tail_x6_r0_body.st81.s3 :
  interpS (step PRE_first_tail_x6_r0_body.st81.F PRE_first_tail_x6_r0_body.st81.s2).run PRE_first_tail_x6_r0_body.st81.S2 = some (PRE_first_tail_x6_r0_body.st81.s3, PRE_first_tail_x6_r0_body.st81.S3)
kernel_rfl PRE_first_tail_x6_r0_body.st81.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st81.s2.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st81.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st81.s3.stack = true

end Host.Load.Run.Tpl
end

section -- st81/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st81.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st81.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st81.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st81.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st81.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st81.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st81.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st81.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st81.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st81.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st81.s0 PRE_first_tail_x6_r0_body.st81.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st81.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st81.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st81.s2 PRE_first_tail_x6_r0_body.st81.S2) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st81/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st81.bodyK0F from PRE_first_tail_x6_r0_body.st81.s0 to PRE_first_tail_x6_r0_body.st81.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st81.F (PRE_first_tail_x6_r0_body.st81.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st81.ks 0).getD 0) PRE_first_tail_x6_r0_body.st81.s0 PRE_first_tail_x6_r0_body.st81.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st81.s1, PRE_first_tail_x6_r0_body.st81.S1)
theorem PRE_first_tail_x6_r0_body.st81.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st81.F (PRE_first_tail_x6_r0_body.st81.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st81.ks 0).getD 0) PRE_first_tail_x6_r0_body.st81.s0 PRE_first_tail_x6_r0_body.st81.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st81.s1, PRE_first_tail_x6_r0_body.st81.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st81.bodyOkLN_ok PRE_first_tail_x6_r0_body.st81.bodyK0F
end Host.Load.Run.Tpl
end

section -- st81/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st81.bodyK1F from PRE_first_tail_x6_r0_body.st81.s1 to PRE_first_tail_x6_r0_body.st81.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st81.F (PRE_first_tail_x6_r0_body.st81.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st81.ks 1).getD 0) PRE_first_tail_x6_r0_body.st81.s1 PRE_first_tail_x6_r0_body.st81.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st81.s2, PRE_first_tail_x6_r0_body.st81.S2)
theorem PRE_first_tail_x6_r0_body.st81.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st81.F (PRE_first_tail_x6_r0_body.st81.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st81.ks 1).getD 0) PRE_first_tail_x6_r0_body.st81.s1 PRE_first_tail_x6_r0_body.st81.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st81.s2, PRE_first_tail_x6_r0_body.st81.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st81.bodyOkLN_ok PRE_first_tail_x6_r0_body.st81.bodyK1F
end Host.Load.Run.Tpl
end

section -- st81/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st81.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st81.F (PRE_first_tail_x6_r0_body.st81.bodyOkL bytes rows) 3452 PRE_first_tail_x6_r0_body.st81.s0 PRE_first_tail_x6_r0_body.st81.S0 = some (PRE_first_tail_x6_r0_body.st81.s2, PRE_first_tail_x6_r0_body.st81.S2) :=
  runOk_trans PRE_first_tail_x6_r0_body.st81.F (PRE_first_tail_x6_r0_body.st81.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st81.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st81.ks 1).getD 0) PRE_first_tail_x6_r0_body.st81.s0 PRE_first_tail_x6_r0_body.st81.s1 PRE_first_tail_x6_r0_body.st81.s2 PRE_first_tail_x6_r0_body.st81.S0 PRE_first_tail_x6_r0_body.st81.S1 PRE_first_tail_x6_r0_body.st81.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st81.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st81.bodyK1 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st81.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st81.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st81.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st81.F (PRE_first_tail_x6_r0_body.st81.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st81.s0
  S0 := PRE_first_tail_x6_r0_body.st81.S0
  s1 := PRE_first_tail_x6_r0_body.st81.s2
  S1 := PRE_first_tail_x6_r0_body.st81.S2
  s2 := PRE_first_tail_x6_r0_body.st81.s3
  S2 := PRE_first_tail_x6_r0_body.st81.S3
  n := 3452
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st81.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st81.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st81.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st81.bodyHalt
  last := PRE_first_tail_x6_r0_body.st81.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st81.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC82
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 82 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s802` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa82` into the merged state
`PRE_first_tail_x6_r0_body.s801`. -/

def PRE_first_tail_x6_r0_body.pl82 : List Nat := []
def PRE_first_tail_x6_r0_body.nr82 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd82 : RData :=
  ⟨2739589, 2739591, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19826, 19826, 16914, 16914, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa82 : Map :=
  Conv.Map.compact 2739589 2739591 3584 PRE_first_tail_x6_r0_body.pl82 (PRE_first_tail_x6_r0_body.nr82.map NumV.ref) PRE_first_tail_x6_r0_body.kd82.big
    PRE_first_tail_x6_r0_body.kd82.region PRE_first_tail_x6_r0_body.kd82.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws82 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs82 : List SymE := PRE_first_tail_x6_r0_body.nr82.map fun r => (nth? PRE_first_tail_x6_r0_body.S801.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta82 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws82 PRE_first_tail_x6_r0_body.crs82
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB82 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab82 : PRE_first_tail_x6_r0_body.S802.tab = PRE_first_tail_x6_r0_body.S800.tab ++ PRE_first_tail_x6_r0_body.cws82.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace82 : PRE_first_tail_x6_r0_body.s802.trace = PRE_first_tail_x6_r0_body.s800.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext82 : PRE_first_tail_x6_r0_body.s802.next = 2739589
kernel_rfl PRE_first_tail_x6_r0_body.ccounters82 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s802.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s802.ffi).mlx.nnext) = (19826, 16914)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue82 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s801.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s802.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa82.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp82 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s802.ffi).mlx.tokens.all (bSN 3584) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean82 : Conv.cleanListB 19826 131072 (fun r => Nat.ble 79304 r) PRE_first_tail_x6_r0_body.s802
    (PRE_first_tail_x6_r0_body.wrB82 ++ (List.range 0).map (2739589 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs82 : bigsOutB 19826 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s802.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK82
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl82`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl82 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo82 : List Nat := []
def PRE_first_tail_x6_r0_body.cln82 : List Nat := []
def PRE_first_tail_x6_r0_body.cli82 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap82 : PRE_first_tail_x6_r0_body.s802.heap = Stage.setAll PRE_first_tail_x6_r0_body.s800.heap (PRE_first_tail_x6_r0_body.cl82.filterMap fun a => (PRE_first_tail_x6_r0_body.s802.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe82 : Nat.ble PRE_first_tail_x6_r0_body.s800.next PRE_first_tail_x6_r0_body.s802.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP82 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s800 PRE_first_tail_x6_r0_body.s802 PRE_first_tail_x6_r0_body.cl82 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp82 : Conv.suppListB PRE_first_tail_x6_r0_body.s802 3584 PRE_first_tail_x6_r0_body.cl82 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound82 : Conv.boundListB PRE_first_tail_x6_r0_body.s802 PRE_first_tail_x6_r0_body.cl82 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK82 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s802.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln82.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s802.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK82 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s802.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo82.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s802.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK82 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s802.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli82.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s802.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst82 : Conv.sstListB 3584 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s802.ffi).mlx PRE_first_tail_x6_r0_body.cln82 PRE_first_tail_x6_r0_body.clo82 PRE_first_tail_x6_r0_body.cli82 = true

end Host.Load.Run.Tpl
end

section -- SiteCl82
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA82 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s802.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo82.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s802.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd82 : (PRE_first_tail_x6_r0_body.clo82 ++ PRE_first_tail_x6_r0_body.cln82 ++ PRE_first_tail_x6_r0_body.cli82).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle82 : Conv.Cnt.leB (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck82 : Conv.ncleanListB (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s802.ffi).mlx PRE_first_tail_x6_r0_body.clo82 PRE_first_tail_x6_r0_body.cln82 PRE_first_tail_x6_r0_body.cli82 = true
theorem PRE_first_tail_x6_r0_body.cncl82 (h : Conv.NClean (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx) : Conv.NClean (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s802.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle82 PRE_first_tail_x6_r0_body.ckA82 PRE_first_tail_x6_r0_body.cobjsK82 PRE_first_tail_x6_r0_body.cnodesK82 PRE_first_tail_x6_r0_body.citemsK82 PRE_first_tail_x6_r0_body.cbd82 PRE_first_tail_x6_r0_body.cck82

end Host.Load.Run.Tpl
end

section -- SiteS82
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 82 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc82 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P82 : LoadP := PRE_first_tail_x6_r0_body.Pc82.raise 16914
kernel_rfl PRE_first_tail_x6_r0_body.craise82 : Nat.ble PRE_first_tail_x6_r0_body.Pc82.N0 16914 = true
theorem PRE_first_tail_x6_r0_body.raised82 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc82 PRE_first_tail_x6_r0_body.P82 :=
  .inr ⟨16914, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise82, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_82 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s802.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_82 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s801.ffi)
def PRE_first_tail_x6_r0_body.khinv82 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv82 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS82 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS82 : List Nat := List.range' 16914 0
def PRE_first_tail_x6_r0_body.ciS82 : List Nat := [] ++ List.range' 16914 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh082 : PRE_first_tail_x6_r0_body.kd82.nh0 = PRE_first_tail_x6_r0_body.cx0_82.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh182 : PRE_first_tail_x6_r0_body.kd82.nh1 = PRE_first_tail_x6_r0_body.cx1_82.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn082 : PRE_first_tail_x6_r0_body.kd82.nn0 = PRE_first_tail_x6_r0_body.cx0_82.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn182 : PRE_first_tail_x6_r0_body.kd82.nn1 = PRE_first_tail_x6_r0_body.cx1_82.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo82 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P82.lo && Nat.ble PRE_first_tail_x6_r0_body.P82.lo PRE_first_tail_x6_r0_body.cx0_82.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P82.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P82.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt82 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_82.mlx.next PRE_first_tail_x6_r0_body.cx1_82.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_82.mlx.nnext PRE_first_tail_x6_r0_body.cx1_82.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband82 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P82.NL && Nat.ble PRE_first_tail_x6_r0_body.P82.NL PRE_first_tail_x6_r0_body.P82.N0 && Nat.ble PRE_first_tail_x6_r0_body.P82.N0 PRE_first_tail_x6_r0_body.cx0_82.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow82 : PRE_first_tail_x6_r0_body.kd82.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren82 : checkRenG PRE_first_tail_x6_r0_body.kd82.hnd PRE_first_tail_x6_r0_body.khinv82 (phB PRE_first_tail_x6_r0_body.cx0_82.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband82 : PRE_first_tail_x6_r0_body.kd82.checkBand PRE_first_tail_x6_r0_body.P82.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos82 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd82.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren82 : checkRenG PRE_first_tail_x6_r0_body.kd82.node PRE_first_tail_x6_r0_body.kninv82 (pnB PRE_first_tail_x6_r0_body.cx0_82.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow82 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd82.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P82.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd82.nodeF j) PRE_first_tail_x6_r0_body.cx1_82.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a82 : PRE_first_tail_x6_r0_body.cx0_82.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b82 : PRE_first_tail_x6_r0_body.cx0_82.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok182 : PRE_first_tail_x6_r0_body.cx1_82.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend82 : PRE_first_tail_x6_r0_body.cx1_82.mlx.pending = PRE_first_tail_x6_r0_body.cx0_82.mlx.pending.map PRE_first_tail_x6_r0_body.kappa82.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh82 : PRE_first_tail_x6_r0_body.cx1_82.mlx.errh = PRE_first_tail_x6_r0_body.cx0_82.mlx.errh.map PRE_first_tail_x6_r0_body.kappa82.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles82 : PRE_first_tail_x6_r0_body.cx1_82.mlx.files = PRE_first_tail_x6_r0_body.cx0_82.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch82 : PRE_first_tail_x6_r0_body.cx1_82.mlx.arch = PRE_first_tail_x6_r0_body.cx0_82.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes82 : PRE_first_tail_x6_r0_body.cx1_82.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_82.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired82 : PRE_first_tail_x6_r0_body.cx1_82.mlx.wired = PRE_first_tail_x6_r0_body.cx0_82.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost82 : PRE_first_tail_x6_r0_body.cx1_82.host = PRE_first_tail_x6_r0_body.cx0_82.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd82`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn082 : PRE_first_tail_x6_r0_body.kd82.n0 = 2739589
kernel_rfl PRE_first_tail_x6_r0_body.ckn182 : PRE_first_tail_x6_r0_body.kd82.n1 = 2739591
kernel_rfl PRE_first_tail_x6_r0_body.ckheap82 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd82.heap).all (fun x => Nat.ble 2739589 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl82 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_body.kd82.heap.get (2739589 + j) = nth? PRE_first_tail_x6_r0_body.pl82 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja82 : Nat.ble 2739589 2739589 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn82 : Nat.ble 3584 3584 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD82 : Nat.ble 2739589 PRE_first_tail_x6_r0_body.kd82.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn82 : Nat.ble 19826 PRE_first_tail_x6_r0_body.kd82.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn82 : Nat.ble 16914 PRE_first_tail_x6_r0_body.kd82.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb82 : Nat.ble 19826 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap82 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd82.heap).all (Nat.ble (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd82 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd82.hnd).all (Nat.ble (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode82 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd82.node).all (Nat.ble (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix82 : Conv.FixOld (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa82 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja82) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn82) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD82) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn82) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn82) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb82) PRE_first_tail_x6_r0_body.fheap82 PRE_first_tail_x6_r0_body.fhnd82 PRE_first_tail_x6_r0_body.fnode82
kernel_rfl PRE_first_tail_x6_r0_body.fcxn82 : (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn82 : (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle082 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_82.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_82.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk82 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd82.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A82 : PRE_first_tail_x6_r0_body.cx1_82.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS82.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_82.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O82 : PRE_first_tail_x6_r0_body.cx1_82.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS82.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_82.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N82 : PRE_first_tail_x6_r0_body.cx1_82.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS82.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_82.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I82 : PRE_first_tail_x6_r0_body.cx1_82.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS82.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_82.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd82 : (PRE_first_tail_x6_r0_body.clo82 ++ PRE_first_tail_x6_r0_body.cln82 ++ PRE_first_tail_x6_r0_body.cli82 ++ PRE_first_tail_x6_r0_body.cwS82 ++ PRE_first_tail_x6_r0_body.cnS82 ++ PRE_first_tail_x6_r0_body.ciS82).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW82 : PRE_first_tail_x6_r0_body.cwS82.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo82.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI82 : PRE_first_tail_x6_r0_body.ciS82.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli82.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN82 : PRE_first_tail_x6_r0_body.cnS82.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF82 : PRE_first_tail_x6_r0_body.cln82.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh82 : PRE_first_tail_x6_r0_body.clo82.all (handleOK PRE_first_tail_x6_r0_body.kappa82 PRE_first_tail_x6_r0_body.P82.lo PRE_first_tail_x6_r0_body.cx0_82.mlx PRE_first_tail_x6_r0_body.cx1_82.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo82 : PRE_first_tail_x6_r0_body.clo82.map (fun h => PRE_first_tail_x6_r0_body.cx1_82.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa82.handle h)) = PRE_first_tail_x6_r0_body.clo82.map (fun h => (PRE_first_tail_x6_r0_body.cx0_82.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa82.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok82 : PRE_first_tail_x6_r0_body.clo82.all (objOK PRE_first_tail_x6_r0_body.kappa82 PRE_first_tail_x6_r0_body.P82.NL PRE_first_tail_x6_r0_body.cx0_82.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd82 : PRE_first_tail_x6_r0_body.cln82.all (nodeOKF PRE_first_tail_x6_r0_body.kappa82 PRE_first_tail_x6_r0_body.P82 PRE_first_tail_x6_r0_body.cx0_82.mlx PRE_first_tail_x6_r0_body.cx1_82.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp82 : ((PRE_first_tail_x6_r0_body.cln82.filter (fullB PRE_first_tail_x6_r0_body.P82))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_82.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa82.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln82.filter (fullB PRE_first_tail_x6_r0_body.P82))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_82.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa82.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI82 : incrB PRE_first_tail_x6_r0_body.kd82.nodeF (List.range' 16914 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK82 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd82.node).all (fun k => Nat.ble 16914 k && Nat.blt k 16914) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL82 : (PRE_first_tail_x6_r0_body.cln82.filter (Nat.ble PRE_first_tail_x6_r0_body.P82.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd82.nodeF i) && (Nat.blt i 16914 || Nat.ble PRE_first_tail_x6_r0_body.kd82.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord82 : (PRE_first_tail_x6_r0_body.cln82.filter (Nat.ble PRE_first_tail_x6_r0_body.P82.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd82.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd82.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd82.nodeF j) (PRE_first_tail_x6_r0_body.kd82.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow82 PRE_first_tail_x6_r0_body.cnn182 PRE_first_tail_x6_r0_body.fnordI82 PRE_first_tail_x6_r0_body.fnordK82 PRE_first_tail_x6_r0_body.fnordL82
kernel_rfl PRE_first_tail_x6_r0_body.fi82 : PRE_first_tail_x6_r0_body.cli82.all (pnB PRE_first_tail_x6_r0_body.cx0_82.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii82 : PRE_first_tail_x6_r0_body.cli82.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_82.mlx.items.get (PRE_first_tail_x6_r0_body.kappa82.node k) = (PRE_first_tail_x6_r0_body.cx0_82.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa82.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot82 (clean : Conv.NClean (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P82.NL) (cl : SSt (· < 3584) PRE_first_tail_x6_r0_body.cx0_82.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P82 3584 PRE_first_tail_x6_r0_body.kappa82 PRE_first_tail_x6_r0_body.kd82 PRE_first_tail_x6_r0_body.khinv82 PRE_first_tail_x6_r0_body.kninv82 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx PRE_first_tail_x6_r0_body.cx0_82.mlx PRE_first_tail_x6_r0_body.cx1_82.mlx (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo82 PRE_first_tail_x6_r0_body.cln82 PRE_first_tail_x6_r0_body.cli82 PRE_first_tail_x6_r0_body.cwS82 PRE_first_tail_x6_r0_body.cnS82 PRE_first_tail_x6_r0_body.ciS82 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh082, PRE_first_tail_x6_r0_body.cnh182, PRE_first_tail_x6_r0_body.cnn082, PRE_first_tail_x6_r0_body.cnn182, PRE_first_tail_x6_r0_body.cplo82, PRE_first_tail_x6_r0_body.ccnt82, PRE_first_tail_x6_r0_body.cnband82, PRE_first_tail_x6_r0_body.chbelow82, PRE_first_tail_x6_r0_body.chren82, PRE_first_tail_x6_r0_body.cband82, PRE_first_tail_x6_r0_body.cnh1pos82, PRE_first_tail_x6_r0_body.cnren82, PRE_first_tail_x6_r0_body.cnlow82, PRE_first_tail_x6_r0_body.cabs0a82, PRE_first_tail_x6_r0_body.cabs0b82, PRE_first_tail_x6_r0_body.ctok182, PRE_first_tail_x6_r0_body.cpend82, PRE_first_tail_x6_r0_body.cerrh82, PRE_first_tail_x6_r0_body.cfiles82, PRE_first_tail_x6_r0_body.carch82, PRE_first_tail_x6_r0_body.csizes82, PRE_first_tail_x6_r0_body.cwired82, PRE_first_tail_x6_r0_body.cfix82, clean, PRE_first_tail_x6_r0_body.fcxn82, PRE_first_tail_x6_r0_body.fcnn82, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle082, PRE_first_tail_x6_r0_body.fnk82, PRE_first_tail_x6_r0_body.ckA82, PRE_first_tail_x6_r0_body.cobjsK82, PRE_first_tail_x6_r0_body.cnodesK82, PRE_first_tail_x6_r0_body.citemsK82, PRE_first_tail_x6_r0_body.f1A82, PRE_first_tail_x6_r0_body.f1O82, PRE_first_tail_x6_r0_body.f1N82, PRE_first_tail_x6_r0_body.f1I82, PRE_first_tail_x6_r0_body.fbd82, PRE_first_tail_x6_r0_body.fincW82, PRE_first_tail_x6_r0_body.fincI82, PRE_first_tail_x6_r0_body.fincN82, PRE_first_tail_x6_r0_body.flnF82, PRE_first_tail_x6_r0_body.fh82, PRE_first_tail_x6_r0_body.fo82, PRE_first_tail_x6_r0_body.fok82, PRE_first_tail_x6_r0_body.fnd82, PRE_first_tail_x6_r0_body.fp82, PRE_first_tail_x6_r0_body.fnord82, PRE_first_tail_x6_r0_body.fi82, PRE_first_tail_x6_r0_body.fii82⟩
theorem PRE_first_tail_x6_r0_body.cnshift82 (clean : Conv.NClean (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P82.NL) (cl : SSt (· < 3584) PRE_first_tail_x6_r0_body.cx0_82.mlx) : NShift PRE_first_tail_x6_r0_body.P82 3584 PRE_first_tail_x6_r0_body.kappa82 PRE_first_tail_x6_r0_body.cx0_82 PRE_first_tail_x6_r0_body.cx1_82 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot82 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost82 (compact_a_eq PRE_first_tail_x6_r0_body.ckn082 PRE_first_tail_x6_r0_body.ckn182 PRE_first_tail_x6_r0_body.ckheap82 PRE_first_tail_x6_r0_body.ckpl82)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_82 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s800.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_82 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s800.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_82 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s800.ffi) = some PRE_first_tail_x6_r0_body.fxC_82
kernel_rfl PRE_first_tail_x6_r0_body.okrC_82 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s800.ffi) = some PRE_first_tail_x6_r0_body.krC_82
noncomputable def PRE_first_tail_x6_r0_body.fx0_82 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s802.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_82 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s802.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_82 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s802.ffi) = some PRE_first_tail_x6_r0_body.fx0_82
kernel_rfl PRE_first_tail_x6_r0_body.okr0_82 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s802.ffi) = some PRE_first_tail_x6_r0_body.kr0_82
noncomputable def PRE_first_tail_x6_r0_body.fx1_82 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s801.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_82 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s801.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_82 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s801.ffi) = some PRE_first_tail_x6_r0_body.fx1_82
kernel_rfl PRE_first_tail_x6_r0_body.okr1_82 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s801.ffi) = some PRE_first_tail_x6_r0_body.kr1_82
kernel_rfl PRE_first_tail_x6_r0_body.ff082 : PRE_first_tail_x6_r0_body.fx0_82 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_82 (PRE_first_tail_x6_r0_body.clo82.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_82.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff182 : PRE_first_tail_x6_r0_body.fx1_82 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_82 (PRE_first_tail_x6_r0_body.cwS82.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_82.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck82 : freedLB PRE_first_tail_x6_r0_body.kappa82 PRE_first_tail_x6_r0_body.cx0_82.mlx PRE_first_tail_x6_r0_body.fx0_82 PRE_first_tail_x6_r0_body.fx1_82 PRE_first_tail_x6_r0_body.clo82 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf082 : PRE_first_tail_x6_r0_body.kr0_82.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_82.flags (PRE_first_tail_x6_r0_body.clo82.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_82.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt082 : PRE_first_tail_x6_r0_body.kr0_82.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_82.targs (PRE_first_tail_x6_r0_body.clo82.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_82.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf182 : PRE_first_tail_x6_r0_body.kr1_82.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_82.flags (PRE_first_tail_x6_r0_body.cwS82.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_82.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt182 : PRE_first_tail_x6_r0_body.kr1_82.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_82.targs (PRE_first_tail_x6_r0_body.cwS82.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_82.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck82 : krecLB PRE_first_tail_x6_r0_body.kappa82 3584 PRE_first_tail_x6_r0_body.cx0_82.mlx PRE_first_tail_x6_r0_body.kr0_82 PRE_first_tail_x6_r0_body.kr1_82 PRE_first_tail_x6_r0_body.clo82 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn82 : Nat.ble 3584 3584 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge82 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s801.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s802.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR82 : pendRegB PRE_first_tail_x6_r0_body.kappa82 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s802.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe82 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s802.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s801.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift82 (clean : Conv.NClean (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P82.NL) (cl : SSt (· < 3584) PRE_first_tail_x6_r0_body.cx0_82.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_82.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_82.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_82.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s800.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_82.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P82 3584 PRE_first_tail_x6_r0_body.kappa82 PRE_first_tail_x6_r0_body.s802.ffi PRE_first_tail_x6_r0_body.s801.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift82 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue82, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp82 t ht),
    PRE_first_tail_x6_r0_body.cbridge82,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s802.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s801.ffi) (PRE_first_tail_x6_r0_body.cfoot82 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_82 PRE_first_tail_x6_r0_body.ofx1_82 hobjC PRE_first_tail_x6_r0_body.ff082 PRE_first_tail_x6_r0_body.ff182 PRE_first_tail_x6_r0_body.ffck82,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s802.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s801.ffi) (PRE_first_tail_x6_r0_body.cfoot82 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_82 PRE_first_tail_x6_r0_body.okr1_82 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn82) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf082 PRE_first_tail_x6_r0_body.fkt082 PRE_first_tail_x6_r0_body.fkf182 PRE_first_tail_x6_r0_body.fkt182 PRE_first_tail_x6_r0_body.fkck82,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh082 PRE_first_tail_x6_r0_body.cnh182 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe82) PRE_first_tail_x6_r0_body.cpendR82⟩

end Host.Load.Run.Tpl
end

section -- st82/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st82 0
host_stream_state PRE_first_tail_x6_r0_body.st82 1
host_stream_state PRE_first_tail_x6_r0_body.st82 2
end Host.Load.Run.Tpl
end

section -- Site82
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 82 of chain `PRE_first_tail_x6_r0_body`: `rowBlocks__g82__g83` (`rowBlocks`), the call state `PRE_first_tail_x6_r0_body.s800`, the merged state `PRE_first_tail_x6_r0_body.s801`,
the site template `PRE_first_tail_x6_r0_body.st82` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s802`: the merge.
The footprint's facts are in `SiteF82`, the compaction's in `SiteC82`, `SiteK82`, `SiteNa82`, `SiteNb82`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso82 : PRE_first_tail_x6_r0_body.st82.s0 = { PRE_first_tail_x6_r0_body.s800 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs82 : List Frame := PRE_first_tail_x6_r0_body.s800.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_82 : PRE_first_tail_x6_r0_body.S800.tab.length = 3584
kernel_rfl PRE_first_tail_x6_r0_body.tab0_82 : PRE_first_tail_x6_r0_body.st82.S0.tab = PRE_first_tail_x6_r0_body.S800.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws82 : List Nat := [2388, 2389]
kernel_rfl PRE_first_tail_x6_r0_body.fresh82 : (PRE_first_tail_x6_r0_body.S800.tab.all fun e => PRE_first_tail_x6_r0_body.ws82.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S800.oracle.all fun q => PRE_first_tail_x6_r0_body.ws82.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab82 : PRE_first_tail_x6_r0_body.S801.tab = PRE_first_tail_x6_r0_body.S800.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws82
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen82 : PRE_first_tail_x6_r0_body.st82.S2.tab.length - PRE_first_tail_x6_r0_body.st82.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged82`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap82 : PRE_first_tail_x6_r0_body.s801.heap = PRE_first_tail_x6_r0_body.st82.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext82 : PRE_first_tail_x6_r0_body.s801.next = PRE_first_tail_x6_r0_body.st82.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl82 : PRE_first_tail_x6_r0_body.s801.ctl = PRE_first_tail_x6_r0_body.st82.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack82 : PRE_first_tail_x6_r0_body.s801.stack = PRE_first_tail_x6_r0_body.st82.s2.stack ++ PRE_first_tail_x6_r0_body.s800.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs82 : PRE_first_tail_x6_r0_body.s801.jobs = PRE_first_tail_x6_r0_body.st82.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi82 : PRE_first_tail_x6_r0_body.s801.ffi = PRE_first_tail_x6_r0_body.st82.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace82 : PRE_first_tail_x6_r0_body.s801.trace = PRE_first_tail_x6_r0_body.st82.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores82 : PRE_first_tail_x6_r0_body.s801.stores = PRE_first_tail_x6_r0_body.st82.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD82
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 82 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived82 : PRE_first_tail_x6_r0_body.nr82.map (fun r => nth? PRE_first_tail_x6_r0_body.st82.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo82 : PRE_first_tail_x6_r0_body.nr82.all (Nat.ble 3584) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj82 : PRE_first_tail_x6_r0_body.cws82.all (fun c => !PRE_first_tail_x6_r0_body.ws82.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ82 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws82 PRE_first_tail_x6_r0_body.crs82 PRE_first_tail_x6_r0_body.ws82

end Host.Load.Run.Tpl
end

section -- st82/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st82`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st82.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st82.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st82.s2.heap PRE_first_tail_x6_r0_body.st82.wrR ++ freshOf PRE_first_tail_x6_r0_body.st82.s2.heap PRE_first_tail_x6_r0_body.st82.s0.next PRE_first_tail_x6_r0_body.st82.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st82.wr : List Nat := PRE_first_tail_x6_r0_body.st82.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st82.heapFoot : PRE_first_tail_x6_r0_body.st82.s2.heap = setAll PRE_first_tail_x6_r0_body.st82.s0.heap PRE_first_tail_x6_r0_body.st82.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st82.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st82.s0.next PRE_first_tail_x6_r0_body.st82.s2.next = true
theorem PRE_first_tail_x6_r0_body.st82.grows : PRE_first_tail_x6_r0_body.st82.s0.next ≤ PRE_first_tail_x6_r0_body.st82.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st82.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st82.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st82.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st82.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st82.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st82.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st82.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st82.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st82.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st82.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st82.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st82.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st82.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st82.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st82.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st82.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st82.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st82.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st82.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st82.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st82.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st82.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st82.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st82.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st82.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st82.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st82.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st82.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st82.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st82.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st82.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st82.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF82
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 82 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB82 : nodupT PRE_first_tail_x6_r0_body.st82.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup82 : PRE_first_tail_x6_r0_body.st82.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB82).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB82 : PRE_first_tail_x6_r0_body.st82.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound82 : ∀ b ∈ PRE_first_tail_x6_r0_body.st82.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB82 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr82 := PRE_first_tail_x6_r0_body.st82.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq82 : PRE_first_tail_x6_r0_body.st82.s2.trace = PRE_first_tail_x6_r0_body.trFr82 ++ PRE_first_tail_x6_r0_body.st82.s0.trace
theorem PRE_first_tail_x6_r0_body.trace82 : ∃ fr, PRE_first_tail_x6_r0_body.st82.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st82.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq82⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide82 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB82 : (PRE_first_tail_x6_r0_body.wide82.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st82.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix82 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide82, WFix Map.id (Present PRE_first_tail_x6_r0_body.st82.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB82 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL82
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 82 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s801`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO82 : PRE_first_tail_x6_r0_body.st82.S0.oracle = PRE_first_tail_x6_r0_body.st82.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B82 : PRE_first_tail_x6_r0_body.st82.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st82.s0.next || (PRE_first_tail_x6_r0_body.st82.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot82 : Conv.StageFoot PRE_first_tail_x6_r0_body.st82.wr PRE_first_tail_x6_r0_body.st82.s0 PRE_first_tail_x6_r0_body.st82.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st82.heapFoot PRE_first_tail_x6_r0_body.wrNodup82 PRE_first_tail_x6_r0_body.wrBound82 PRE_first_tail_x6_r0_body.wr0B82 PRE_first_tail_x6_r0_body.st82.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged82 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st82.F.S → PRE_first_tail_x6_r0_body.st82.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st82.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st82.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs82 PRE_first_tail_x6_r0_body.st82.wr PRE_first_tail_x6_r0_body.s800 PRE_first_tail_x6_r0_body.st82.s2 PRE_first_tail_x6_r0_body.st82.s0
      PRE_first_tail_x6_r0_body.st82.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st82.F FR W stk M ν K PRE_first_tail_x6_r0_body.s801 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso82 PRE_first_tail_x6_r0_body.stFoot82 PRE_first_tail_x6_r0_body.wrNodup82 PRE_first_tail_x6_r0_body.wrBound82 PRE_first_tail_x6_r0_body.trace82 PRE_first_tail_x6_r0_body.mheap82
    PRE_first_tail_x6_r0_body.mnext82 PRE_first_tail_x6_r0_body.mctl82 PRE_first_tail_x6_r0_body.mstack82 PRE_first_tail_x6_r0_body.mjobs82 PRE_first_tail_x6_r0_body.mffi82 PRE_first_tail_x6_r0_body.mtrace82 PRE_first_tail_x6_r0_body.mstores82 h

def PRE_first_tail_x6_r0_body.arrEl82_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE82_2665 : arrOf PRE_first_tail_x6_r0_body.s801 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl82_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA82_2665 : isArrB PRE_first_tail_x6_r0_body.s801 2665 = true
theorem PRE_first_tail_x6_r0_body.arr82_2665 : ∃ o, PRE_first_tail_x6_r0_body.s801.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl82_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE82_2665 PRE_first_tail_x6_r0_body.arrA82_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN82_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl82_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR82_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl82_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN82_2665

def PRE_first_tail_x6_r0_body.arrEl82_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE82_2673467 : arrOf PRE_first_tail_x6_r0_body.s801 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl82_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA82_2673467 : isArrB PRE_first_tail_x6_r0_body.s801 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr82_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s801.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl82_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE82_2673467 PRE_first_tail_x6_r0_body.arrA82_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN82_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl82_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR82_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl82_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN82_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k82 : isArrB PRE_first_tail_x6_r0_body.s801 4910 = false
theorem PRE_first_tail_x6_r0_body.keep82 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s801 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k82 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr82_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl82_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ82
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 82 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s800`, the merged
state `PRE_first_tail_x6_r0_body.s801`, the canonical state `PRE_first_tail_x6_r0_body.s802`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl82 : PRE_first_tail_x6_r0_body.pl82.all (Nat.ble PRE_first_tail_x6_r0_body.s800.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd82 : nodupT PRE_first_tail_x6_r0_body.pl82 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn182 : Nat.ble PRE_first_tail_x6_r0_body.s800.next 2739591 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst82 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s800.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn82 : PRE_first_tail_x6_r0_body.s802.next = PRE_first_tail_x6_r0_body.s800.next + PRE_first_tail_x6_r0_body.pl82.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn82 : PRE_first_tail_x6_r0_body.s801.next = 2739591
kernel_rfl PRE_first_tail_x6_r0_body.zgrow82 : Nat.ble PRE_first_tail_x6_r0_body.s802.next PRE_first_tail_x6_r0_body.s801.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh82 : PRE_first_tail_x6_r0_body.S800.tab.all (fun e => PRE_first_tail_x6_r0_body.cws82.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd82 : nodupT PRE_first_tail_x6_r0_body.cws82 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi82 : PRE_first_tail_x6_r0_body.nr82.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S801.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt82 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s800.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg82_2665 : PRE_first_tail_x6_r0_body.s802.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s802 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk82_2665 : (objOf PRE_first_tail_x6_r0_body.s802 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm82_2665 : PRE_first_tail_x6_r0_body.s801.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa82.obj (objOf PRE_first_tail_x6_r0_body.s802 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s801 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg82_2673467 : PRE_first_tail_x6_r0_body.s802.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s802 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk82_2673467 : (objOf PRE_first_tail_x6_r0_body.s802 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm82_2673467 : PRE_first_tail_x6_r0_body.s801.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa82.obj (objOf PRE_first_tail_x6_r0_body.s802 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s801 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw82_4910 : (PRE_first_tail_x6_r0_body.s802.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw82_2673472 : (PRE_first_tail_x6_r0_body.s802.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw82_2673473 : (PRE_first_tail_x6_r0_body.s802.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd82 : PRE_first_tail_x6_r0_body.cl82.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr82 : PRE_first_tail_x6_r0_body.st82.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s800.next || PRE_first_tail_x6_r0_body.cl82.contains b) = true
def PRE_first_tail_x6_r0_body.zl82 : List Nat := PRE_first_tail_x6_r0_body.cl82.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE82 : PRE_first_tail_x6_r0_body.zl82.map (fun a => PRE_first_tail_x6_r0_body.s801.heap.get (PRE_first_tail_x6_r0_body.kappa82.a a)) = PRE_first_tail_x6_r0_body.zl82.map (fun a => (PRE_first_tail_x6_r0_body.s802.heap.get a).map PRE_first_tail_x6_r0_body.kappa82.hobj)
theorem PRE_first_tail_x6_r0_body.zimg82 : HeapImg PRE_first_tail_x6_r0_body.kappa82 PRE_first_tail_x6_r0_body.s802 PRE_first_tail_x6_r0_body.s801 PRE_first_tail_x6_r0_body.zl82 := PRE_first_tail_x6_r0_body.zimgE82
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl82 : PRE_first_tail_x6_r0_body.s801.ctl = PRE_first_tail_x6_r0_body.kappa82.ctl PRE_first_tail_x6_r0_body.s802.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack82 : PRE_first_tail_x6_r0_body.s801.stack = PRE_first_tail_x6_r0_body.s802.stack.map PRE_first_tail_x6_r0_body.kappa82.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs82 : PRE_first_tail_x6_r0_body.s801.jobs = PRE_first_tail_x6_r0_body.s802.jobs.map PRE_first_tail_x6_r0_body.kappa82.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores82 : PRE_first_tail_x6_r0_body.s801.stores = PRE_first_tail_x6_r0_body.kappa82.stores PRE_first_tail_x6_r0_body.s802.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots82 : checkRootsSupp PRE_first_tail_x6_r0_body.s802 3584 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC82 : PRE_first_tail_x6_r0_body.S800.tab.length + PRE_first_tail_x6_r0_body.cws82.length = 3584
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap82 : PRE_first_tail_x6_r0_body.kappa82 = Conv.Map.compact PRE_first_tail_x6_r0_body.s800.next 2739591 PRE_first_tail_x6_r0_body.S800.tab.length PRE_first_tail_x6_r0_body.pl82 (PRE_first_tail_x6_r0_body.nr82.map NumV.ref) PRE_first_tail_x6_r0_body.kd82.big
  PRE_first_tail_x6_r0_body.kd82.region PRE_first_tail_x6_r0_body.kd82.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin82 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s802.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc82 : Conv.jcleanListB (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s802 PRE_first_tail_x6_r0_body.cl82 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB82 : noBigRootsP (fun i => !Conv.oldBigB (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s802.trace PRE_first_tail_x6_r0_body.s802 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm82 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 16914 = true
theorem PRE_first_tail_x6_r0_body.cjcl82 (h : Conv.JClean (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s800) : Conv.JClean (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s802 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle82)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap82 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd82 a ha)) PRE_first_tail_x6_r0_body.zjc82

end Host.Load.Run.Tpl
end

section -- st82/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st82.bodyLast from PRE_first_tail_x6_r0_body.st82.s1 to PRE_first_tail_x6_r0_body.st82.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st82.F PRE_first_tail_x6_r0_body.st82.s1).run PRE_first_tail_x6_r0_body.st82.S1 = some (PRE_first_tail_x6_r0_body.st82.s2, PRE_first_tail_x6_r0_body.st82.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st82.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st82.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st82.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st82.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st82/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st82.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st82.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st82.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st82.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st82.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st82.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st82.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st82.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st82.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st82.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st82.s0 PRE_first_tail_x6_r0_body.st82.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st82.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st82.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st82.s1 PRE_first_tail_x6_r0_body.st82.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st82/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st82.bodyK0F from PRE_first_tail_x6_r0_body.st82.s0 to PRE_first_tail_x6_r0_body.st82.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st82.F (PRE_first_tail_x6_r0_body.st82.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st82.ks 0).getD 0) PRE_first_tail_x6_r0_body.st82.s0 PRE_first_tail_x6_r0_body.st82.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st82.s1, PRE_first_tail_x6_r0_body.st82.S1)
theorem PRE_first_tail_x6_r0_body.st82.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st82.F (PRE_first_tail_x6_r0_body.st82.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st82.ks 0).getD 0) PRE_first_tail_x6_r0_body.st82.s0 PRE_first_tail_x6_r0_body.st82.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st82.s1, PRE_first_tail_x6_r0_body.st82.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st82.bodyOkLN_ok PRE_first_tail_x6_r0_body.st82.bodyK0F
end Host.Load.Run.Tpl
end

section -- st82/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st82.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st82.F (PRE_first_tail_x6_r0_body.st82.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st82.s0 PRE_first_tail_x6_r0_body.st82.S0 = some (PRE_first_tail_x6_r0_body.st82.s1, PRE_first_tail_x6_r0_body.st82.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st82.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st82.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st82.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st82.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st82.F (PRE_first_tail_x6_r0_body.st82.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st82.s0
  S0 := PRE_first_tail_x6_r0_body.st82.S0
  s1 := PRE_first_tail_x6_r0_body.st82.s1
  S1 := PRE_first_tail_x6_r0_body.st82.S1
  s2 := PRE_first_tail_x6_r0_body.st82.s2
  S2 := PRE_first_tail_x6_r0_body.st82.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st82.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st82.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st82.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st82.bodyHalt
  last := PRE_first_tail_x6_r0_body.st82.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st82.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC83
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 83 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s806` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa83` into the merged state
`PRE_first_tail_x6_r0_body.s805`. -/

def PRE_first_tail_x6_r0_body.pl83 : List Nat := [2739887]
def PRE_first_tail_x6_r0_body.nr83 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd83 : RData :=
  ⟨2739878, 2739888, Stage.setAll PTrie.nil [(2739877, 2739887)], Stage.setAll PTrie.nil [],
   19833, 19833, 16918, 16918, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa83 : Map :=
  Conv.Map.compact 2739877 2739888 3601 PRE_first_tail_x6_r0_body.pl83 (PRE_first_tail_x6_r0_body.nr83.map NumV.ref) PRE_first_tail_x6_r0_body.kd83.big
    PRE_first_tail_x6_r0_body.kd83.region PRE_first_tail_x6_r0_body.kd83.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws83 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs83 : List SymE := PRE_first_tail_x6_r0_body.nr83.map fun r => (nth? PRE_first_tail_x6_r0_body.S805.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta83 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws83 PRE_first_tail_x6_r0_body.crs83
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB83 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab83 : PRE_first_tail_x6_r0_body.S806.tab = PRE_first_tail_x6_r0_body.S804.tab ++ PRE_first_tail_x6_r0_body.cws83.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace83 : PRE_first_tail_x6_r0_body.s806.trace = PRE_first_tail_x6_r0_body.s804.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext83 : PRE_first_tail_x6_r0_body.s806.next = 2739878
kernel_rfl PRE_first_tail_x6_r0_body.ccounters83 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s806.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s806.ffi).mlx.nnext) = (19833, 16918)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue83 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s805.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s806.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa83.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp83 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s806.ffi).mlx.tokens.all (bSN 3601) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean83 : Conv.cleanListB 19833 131072 (fun r => Nat.ble 79332 r) PRE_first_tail_x6_r0_body.s806
    (PRE_first_tail_x6_r0_body.wrB83 ++ (List.range 1).map (2739877 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs83 : bigsOutB 19833 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s806.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK83
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl83`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl83 : List Nat := [2665, 2673467, 2739877]
def PRE_first_tail_x6_r0_body.clo83 : List Nat := []
def PRE_first_tail_x6_r0_body.cln83 : List Nat := []
def PRE_first_tail_x6_r0_body.cli83 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap83 : PRE_first_tail_x6_r0_body.s806.heap = Stage.setAll PRE_first_tail_x6_r0_body.s804.heap (PRE_first_tail_x6_r0_body.cl83.filterMap fun a => (PRE_first_tail_x6_r0_body.s806.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe83 : Nat.ble PRE_first_tail_x6_r0_body.s804.next PRE_first_tail_x6_r0_body.s806.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP83 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s804 PRE_first_tail_x6_r0_body.s806 PRE_first_tail_x6_r0_body.cl83 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp83 : Conv.suppListB PRE_first_tail_x6_r0_body.s806 3601 PRE_first_tail_x6_r0_body.cl83 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound83 : Conv.boundListB PRE_first_tail_x6_r0_body.s806 PRE_first_tail_x6_r0_body.cl83 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK83 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s806.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln83.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s806.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK83 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s806.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo83.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s806.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK83 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s806.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli83.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s806.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst83 : Conv.sstListB 3601 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s806.ffi).mlx PRE_first_tail_x6_r0_body.cln83 PRE_first_tail_x6_r0_body.clo83 PRE_first_tail_x6_r0_body.cli83 = true

end Host.Load.Run.Tpl
end

section -- SiteCl83
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA83 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s806.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo83.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s806.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd83 : (PRE_first_tail_x6_r0_body.clo83 ++ PRE_first_tail_x6_r0_body.cln83 ++ PRE_first_tail_x6_r0_body.cli83).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle83 : Conv.Cnt.leB (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt) (⟨19833, 16918, 2739878, 3601⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck83 : Conv.ncleanListB (⟨19833, 16918, 2739878, 3601⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s806.ffi).mlx PRE_first_tail_x6_r0_body.clo83 PRE_first_tail_x6_r0_body.cln83 PRE_first_tail_x6_r0_body.cli83 = true
theorem PRE_first_tail_x6_r0_body.cncl83 (h : Conv.NClean (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx) : Conv.NClean (⟨19833, 16918, 2739878, 3601⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s806.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle83 PRE_first_tail_x6_r0_body.ckA83 PRE_first_tail_x6_r0_body.cobjsK83 PRE_first_tail_x6_r0_body.cnodesK83 PRE_first_tail_x6_r0_body.citemsK83 PRE_first_tail_x6_r0_body.cbd83 PRE_first_tail_x6_r0_body.cck83

end Host.Load.Run.Tpl
end

section -- SiteS83
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 83 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc83 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P83 : LoadP := PRE_first_tail_x6_r0_body.Pc83.raise 16918
kernel_rfl PRE_first_tail_x6_r0_body.craise83 : Nat.ble PRE_first_tail_x6_r0_body.Pc83.N0 16918 = true
theorem PRE_first_tail_x6_r0_body.raised83 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc83 PRE_first_tail_x6_r0_body.P83 :=
  .inr ⟨16918, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise83, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_83 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s806.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_83 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s805.ffi)
def PRE_first_tail_x6_r0_body.khinv83 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv83 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS83 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS83 : List Nat := List.range' 16918 0
def PRE_first_tail_x6_r0_body.ciS83 : List Nat := [] ++ List.range' 16918 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh083 : PRE_first_tail_x6_r0_body.kd83.nh0 = PRE_first_tail_x6_r0_body.cx0_83.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh183 : PRE_first_tail_x6_r0_body.kd83.nh1 = PRE_first_tail_x6_r0_body.cx1_83.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn083 : PRE_first_tail_x6_r0_body.kd83.nn0 = PRE_first_tail_x6_r0_body.cx0_83.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn183 : PRE_first_tail_x6_r0_body.kd83.nn1 = PRE_first_tail_x6_r0_body.cx1_83.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo83 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P83.lo && Nat.ble PRE_first_tail_x6_r0_body.P83.lo PRE_first_tail_x6_r0_body.cx0_83.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P83.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P83.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt83 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_83.mlx.next PRE_first_tail_x6_r0_body.cx1_83.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_83.mlx.nnext PRE_first_tail_x6_r0_body.cx1_83.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband83 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P83.NL && Nat.ble PRE_first_tail_x6_r0_body.P83.NL PRE_first_tail_x6_r0_body.P83.N0 && Nat.ble PRE_first_tail_x6_r0_body.P83.N0 PRE_first_tail_x6_r0_body.cx0_83.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow83 : PRE_first_tail_x6_r0_body.kd83.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren83 : checkRenG PRE_first_tail_x6_r0_body.kd83.hnd PRE_first_tail_x6_r0_body.khinv83 (phB PRE_first_tail_x6_r0_body.cx0_83.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband83 : PRE_first_tail_x6_r0_body.kd83.checkBand PRE_first_tail_x6_r0_body.P83.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos83 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd83.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren83 : checkRenG PRE_first_tail_x6_r0_body.kd83.node PRE_first_tail_x6_r0_body.kninv83 (pnB PRE_first_tail_x6_r0_body.cx0_83.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow83 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd83.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P83.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd83.nodeF j) PRE_first_tail_x6_r0_body.cx1_83.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a83 : PRE_first_tail_x6_r0_body.cx0_83.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b83 : PRE_first_tail_x6_r0_body.cx0_83.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok183 : PRE_first_tail_x6_r0_body.cx1_83.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend83 : PRE_first_tail_x6_r0_body.cx1_83.mlx.pending = PRE_first_tail_x6_r0_body.cx0_83.mlx.pending.map PRE_first_tail_x6_r0_body.kappa83.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh83 : PRE_first_tail_x6_r0_body.cx1_83.mlx.errh = PRE_first_tail_x6_r0_body.cx0_83.mlx.errh.map PRE_first_tail_x6_r0_body.kappa83.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles83 : PRE_first_tail_x6_r0_body.cx1_83.mlx.files = PRE_first_tail_x6_r0_body.cx0_83.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch83 : PRE_first_tail_x6_r0_body.cx1_83.mlx.arch = PRE_first_tail_x6_r0_body.cx0_83.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes83 : PRE_first_tail_x6_r0_body.cx1_83.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_83.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired83 : PRE_first_tail_x6_r0_body.cx1_83.mlx.wired = PRE_first_tail_x6_r0_body.cx0_83.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost83 : PRE_first_tail_x6_r0_body.cx1_83.host = PRE_first_tail_x6_r0_body.cx0_83.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd83`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn083 : PRE_first_tail_x6_r0_body.kd83.n0 = 2739878
kernel_rfl PRE_first_tail_x6_r0_body.ckn183 : PRE_first_tail_x6_r0_body.kd83.n1 = 2739888
kernel_rfl PRE_first_tail_x6_r0_body.ckheap83 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd83.heap).all (fun x => Nat.ble 2739877 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl83 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd83.heap.get (2739877 + j) = nth? PRE_first_tail_x6_r0_body.pl83 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja83 : Nat.ble 2739877 2739877 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn83 : Nat.ble 3601 3601 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD83 : Nat.ble 2739877 PRE_first_tail_x6_r0_body.kd83.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn83 : Nat.ble 19833 PRE_first_tail_x6_r0_body.kd83.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn83 : Nat.ble 16918 PRE_first_tail_x6_r0_body.kd83.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb83 : Nat.ble 19833 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap83 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd83.heap).all (Nat.ble (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd83 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd83.hnd).all (Nat.ble (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode83 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd83.node).all (Nat.ble (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix83 : Conv.FixOld (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa83 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja83) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn83) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD83) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn83) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn83) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb83) PRE_first_tail_x6_r0_body.fheap83 PRE_first_tail_x6_r0_body.fhnd83 PRE_first_tail_x6_r0_body.fnode83
kernel_rfl PRE_first_tail_x6_r0_body.fcxn83 : (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn83 : (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle083 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_83.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_83.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk83 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd83.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A83 : PRE_first_tail_x6_r0_body.cx1_83.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS83.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_83.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O83 : PRE_first_tail_x6_r0_body.cx1_83.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS83.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_83.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N83 : PRE_first_tail_x6_r0_body.cx1_83.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS83.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_83.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I83 : PRE_first_tail_x6_r0_body.cx1_83.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS83.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_83.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd83 : (PRE_first_tail_x6_r0_body.clo83 ++ PRE_first_tail_x6_r0_body.cln83 ++ PRE_first_tail_x6_r0_body.cli83 ++ PRE_first_tail_x6_r0_body.cwS83 ++ PRE_first_tail_x6_r0_body.cnS83 ++ PRE_first_tail_x6_r0_body.ciS83).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW83 : PRE_first_tail_x6_r0_body.cwS83.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo83.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI83 : PRE_first_tail_x6_r0_body.ciS83.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli83.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN83 : PRE_first_tail_x6_r0_body.cnS83.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF83 : PRE_first_tail_x6_r0_body.cln83.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh83 : PRE_first_tail_x6_r0_body.clo83.all (handleOK PRE_first_tail_x6_r0_body.kappa83 PRE_first_tail_x6_r0_body.P83.lo PRE_first_tail_x6_r0_body.cx0_83.mlx PRE_first_tail_x6_r0_body.cx1_83.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo83 : PRE_first_tail_x6_r0_body.clo83.map (fun h => PRE_first_tail_x6_r0_body.cx1_83.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa83.handle h)) = PRE_first_tail_x6_r0_body.clo83.map (fun h => (PRE_first_tail_x6_r0_body.cx0_83.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa83.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok83 : PRE_first_tail_x6_r0_body.clo83.all (objOK PRE_first_tail_x6_r0_body.kappa83 PRE_first_tail_x6_r0_body.P83.NL PRE_first_tail_x6_r0_body.cx0_83.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd83 : PRE_first_tail_x6_r0_body.cln83.all (nodeOKF PRE_first_tail_x6_r0_body.kappa83 PRE_first_tail_x6_r0_body.P83 PRE_first_tail_x6_r0_body.cx0_83.mlx PRE_first_tail_x6_r0_body.cx1_83.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp83 : ((PRE_first_tail_x6_r0_body.cln83.filter (fullB PRE_first_tail_x6_r0_body.P83))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_83.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa83.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln83.filter (fullB PRE_first_tail_x6_r0_body.P83))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_83.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa83.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI83 : incrB PRE_first_tail_x6_r0_body.kd83.nodeF (List.range' 16918 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK83 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd83.node).all (fun k => Nat.ble 16918 k && Nat.blt k 16918) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL83 : (PRE_first_tail_x6_r0_body.cln83.filter (Nat.ble PRE_first_tail_x6_r0_body.P83.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd83.nodeF i) && (Nat.blt i 16918 || Nat.ble PRE_first_tail_x6_r0_body.kd83.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord83 : (PRE_first_tail_x6_r0_body.cln83.filter (Nat.ble PRE_first_tail_x6_r0_body.P83.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd83.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd83.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd83.nodeF j) (PRE_first_tail_x6_r0_body.kd83.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow83 PRE_first_tail_x6_r0_body.cnn183 PRE_first_tail_x6_r0_body.fnordI83 PRE_first_tail_x6_r0_body.fnordK83 PRE_first_tail_x6_r0_body.fnordL83
kernel_rfl PRE_first_tail_x6_r0_body.fi83 : PRE_first_tail_x6_r0_body.cli83.all (pnB PRE_first_tail_x6_r0_body.cx0_83.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii83 : PRE_first_tail_x6_r0_body.cli83.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_83.mlx.items.get (PRE_first_tail_x6_r0_body.kappa83.node k) = (PRE_first_tail_x6_r0_body.cx0_83.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa83.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot83 (clean : Conv.NClean (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P83.NL) (cl : SSt (· < 3601) PRE_first_tail_x6_r0_body.cx0_83.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P83 3601 PRE_first_tail_x6_r0_body.kappa83 PRE_first_tail_x6_r0_body.kd83 PRE_first_tail_x6_r0_body.khinv83 PRE_first_tail_x6_r0_body.kninv83 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx PRE_first_tail_x6_r0_body.cx0_83.mlx PRE_first_tail_x6_r0_body.cx1_83.mlx (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo83 PRE_first_tail_x6_r0_body.cln83 PRE_first_tail_x6_r0_body.cli83 PRE_first_tail_x6_r0_body.cwS83 PRE_first_tail_x6_r0_body.cnS83 PRE_first_tail_x6_r0_body.ciS83 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh083, PRE_first_tail_x6_r0_body.cnh183, PRE_first_tail_x6_r0_body.cnn083, PRE_first_tail_x6_r0_body.cnn183, PRE_first_tail_x6_r0_body.cplo83, PRE_first_tail_x6_r0_body.ccnt83, PRE_first_tail_x6_r0_body.cnband83, PRE_first_tail_x6_r0_body.chbelow83, PRE_first_tail_x6_r0_body.chren83, PRE_first_tail_x6_r0_body.cband83, PRE_first_tail_x6_r0_body.cnh1pos83, PRE_first_tail_x6_r0_body.cnren83, PRE_first_tail_x6_r0_body.cnlow83, PRE_first_tail_x6_r0_body.cabs0a83, PRE_first_tail_x6_r0_body.cabs0b83, PRE_first_tail_x6_r0_body.ctok183, PRE_first_tail_x6_r0_body.cpend83, PRE_first_tail_x6_r0_body.cerrh83, PRE_first_tail_x6_r0_body.cfiles83, PRE_first_tail_x6_r0_body.carch83, PRE_first_tail_x6_r0_body.csizes83, PRE_first_tail_x6_r0_body.cwired83, PRE_first_tail_x6_r0_body.cfix83, clean, PRE_first_tail_x6_r0_body.fcxn83, PRE_first_tail_x6_r0_body.fcnn83, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle083, PRE_first_tail_x6_r0_body.fnk83, PRE_first_tail_x6_r0_body.ckA83, PRE_first_tail_x6_r0_body.cobjsK83, PRE_first_tail_x6_r0_body.cnodesK83, PRE_first_tail_x6_r0_body.citemsK83, PRE_first_tail_x6_r0_body.f1A83, PRE_first_tail_x6_r0_body.f1O83, PRE_first_tail_x6_r0_body.f1N83, PRE_first_tail_x6_r0_body.f1I83, PRE_first_tail_x6_r0_body.fbd83, PRE_first_tail_x6_r0_body.fincW83, PRE_first_tail_x6_r0_body.fincI83, PRE_first_tail_x6_r0_body.fincN83, PRE_first_tail_x6_r0_body.flnF83, PRE_first_tail_x6_r0_body.fh83, PRE_first_tail_x6_r0_body.fo83, PRE_first_tail_x6_r0_body.fok83, PRE_first_tail_x6_r0_body.fnd83, PRE_first_tail_x6_r0_body.fp83, PRE_first_tail_x6_r0_body.fnord83, PRE_first_tail_x6_r0_body.fi83, PRE_first_tail_x6_r0_body.fii83⟩
theorem PRE_first_tail_x6_r0_body.cnshift83 (clean : Conv.NClean (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P83.NL) (cl : SSt (· < 3601) PRE_first_tail_x6_r0_body.cx0_83.mlx) : NShift PRE_first_tail_x6_r0_body.P83 3601 PRE_first_tail_x6_r0_body.kappa83 PRE_first_tail_x6_r0_body.cx0_83 PRE_first_tail_x6_r0_body.cx1_83 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot83 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost83 (compact_a_eq PRE_first_tail_x6_r0_body.ckn083 PRE_first_tail_x6_r0_body.ckn183 PRE_first_tail_x6_r0_body.ckheap83 PRE_first_tail_x6_r0_body.ckpl83)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_83 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s804.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_83 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s804.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_83 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s804.ffi) = some PRE_first_tail_x6_r0_body.fxC_83
kernel_rfl PRE_first_tail_x6_r0_body.okrC_83 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s804.ffi) = some PRE_first_tail_x6_r0_body.krC_83
noncomputable def PRE_first_tail_x6_r0_body.fx0_83 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s806.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_83 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s806.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_83 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s806.ffi) = some PRE_first_tail_x6_r0_body.fx0_83
kernel_rfl PRE_first_tail_x6_r0_body.okr0_83 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s806.ffi) = some PRE_first_tail_x6_r0_body.kr0_83
noncomputable def PRE_first_tail_x6_r0_body.fx1_83 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s805.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_83 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s805.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_83 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s805.ffi) = some PRE_first_tail_x6_r0_body.fx1_83
kernel_rfl PRE_first_tail_x6_r0_body.okr1_83 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s805.ffi) = some PRE_first_tail_x6_r0_body.kr1_83
kernel_rfl PRE_first_tail_x6_r0_body.ff083 : PRE_first_tail_x6_r0_body.fx0_83 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_83 (PRE_first_tail_x6_r0_body.clo83.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_83.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff183 : PRE_first_tail_x6_r0_body.fx1_83 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_83 (PRE_first_tail_x6_r0_body.cwS83.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_83.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck83 : freedLB PRE_first_tail_x6_r0_body.kappa83 PRE_first_tail_x6_r0_body.cx0_83.mlx PRE_first_tail_x6_r0_body.fx0_83 PRE_first_tail_x6_r0_body.fx1_83 PRE_first_tail_x6_r0_body.clo83 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf083 : PRE_first_tail_x6_r0_body.kr0_83.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_83.flags (PRE_first_tail_x6_r0_body.clo83.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_83.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt083 : PRE_first_tail_x6_r0_body.kr0_83.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_83.targs (PRE_first_tail_x6_r0_body.clo83.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_83.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf183 : PRE_first_tail_x6_r0_body.kr1_83.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_83.flags (PRE_first_tail_x6_r0_body.cwS83.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_83.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt183 : PRE_first_tail_x6_r0_body.kr1_83.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_83.targs (PRE_first_tail_x6_r0_body.cwS83.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_83.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck83 : krecLB PRE_first_tail_x6_r0_body.kappa83 3601 PRE_first_tail_x6_r0_body.cx0_83.mlx PRE_first_tail_x6_r0_body.kr0_83 PRE_first_tail_x6_r0_body.kr1_83 PRE_first_tail_x6_r0_body.clo83 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn83 : Nat.ble 3601 3601 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge83 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s805.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s806.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR83 : pendRegB PRE_first_tail_x6_r0_body.kappa83 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s806.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe83 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s806.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s805.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift83 (clean : Conv.NClean (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P83.NL) (cl : SSt (· < 3601) PRE_first_tail_x6_r0_body.cx0_83.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_83.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_83.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_83.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s804.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_83.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P83 3601 PRE_first_tail_x6_r0_body.kappa83 PRE_first_tail_x6_r0_body.s806.ffi PRE_first_tail_x6_r0_body.s805.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift83 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue83, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp83 t ht),
    PRE_first_tail_x6_r0_body.cbridge83,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s806.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s805.ffi) (PRE_first_tail_x6_r0_body.cfoot83 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_83 PRE_first_tail_x6_r0_body.ofx1_83 hobjC PRE_first_tail_x6_r0_body.ff083 PRE_first_tail_x6_r0_body.ff183 PRE_first_tail_x6_r0_body.ffck83,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s806.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s805.ffi) (PRE_first_tail_x6_r0_body.cfoot83 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_83 PRE_first_tail_x6_r0_body.okr1_83 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn83) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf083 PRE_first_tail_x6_r0_body.fkt083 PRE_first_tail_x6_r0_body.fkf183 PRE_first_tail_x6_r0_body.fkt183 PRE_first_tail_x6_r0_body.fkck83,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh083 PRE_first_tail_x6_r0_body.cnh183 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe83) PRE_first_tail_x6_r0_body.cpendR83⟩

end Host.Load.Run.Tpl
end

section -- st83/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st83 0
host_stream_state PRE_first_tail_x6_r0_body.st83 1
host_stream_state PRE_first_tail_x6_r0_body.st83 2
end Host.Load.Run.Tpl
end

section -- Site83
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 83 of chain `PRE_first_tail_x6_r0_body`: `plan__g83__g84` (`plan`), the call state `PRE_first_tail_x6_r0_body.s804`, the merged state `PRE_first_tail_x6_r0_body.s805`,
the site template `PRE_first_tail_x6_r0_body.st83` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s806`: the merge.
The footprint's facts are in `SiteF83`, the compaction's in `SiteC83`, `SiteK83`, `SiteNa83`, `SiteNb83`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso83 : PRE_first_tail_x6_r0_body.st83.s0 = { PRE_first_tail_x6_r0_body.s804 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs83 : List Frame := PRE_first_tail_x6_r0_body.s804.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_83 : PRE_first_tail_x6_r0_body.S804.tab.length = 3601
kernel_rfl PRE_first_tail_x6_r0_body.tab0_83 : PRE_first_tail_x6_r0_body.st83.S0.tab = PRE_first_tail_x6_r0_body.S804.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws83 : List Nat := [2390, 2391, 2392]
kernel_rfl PRE_first_tail_x6_r0_body.fresh83 : (PRE_first_tail_x6_r0_body.S804.tab.all fun e => PRE_first_tail_x6_r0_body.ws83.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S804.oracle.all fun q => PRE_first_tail_x6_r0_body.ws83.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab83 : PRE_first_tail_x6_r0_body.S805.tab = PRE_first_tail_x6_r0_body.S804.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws83
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen83 : PRE_first_tail_x6_r0_body.st83.S2.tab.length - PRE_first_tail_x6_r0_body.st83.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged83`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap83 : PRE_first_tail_x6_r0_body.s805.heap = PRE_first_tail_x6_r0_body.st83.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext83 : PRE_first_tail_x6_r0_body.s805.next = PRE_first_tail_x6_r0_body.st83.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl83 : PRE_first_tail_x6_r0_body.s805.ctl = PRE_first_tail_x6_r0_body.st83.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack83 : PRE_first_tail_x6_r0_body.s805.stack = PRE_first_tail_x6_r0_body.st83.s2.stack ++ PRE_first_tail_x6_r0_body.s804.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs83 : PRE_first_tail_x6_r0_body.s805.jobs = PRE_first_tail_x6_r0_body.st83.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi83 : PRE_first_tail_x6_r0_body.s805.ffi = PRE_first_tail_x6_r0_body.st83.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace83 : PRE_first_tail_x6_r0_body.s805.trace = PRE_first_tail_x6_r0_body.st83.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores83 : PRE_first_tail_x6_r0_body.s805.stores = PRE_first_tail_x6_r0_body.st83.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD83
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 83 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived83 : PRE_first_tail_x6_r0_body.nr83.map (fun r => nth? PRE_first_tail_x6_r0_body.st83.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo83 : PRE_first_tail_x6_r0_body.nr83.all (Nat.ble 3601) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj83 : PRE_first_tail_x6_r0_body.cws83.all (fun c => !PRE_first_tail_x6_r0_body.ws83.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ83 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws83 PRE_first_tail_x6_r0_body.crs83 PRE_first_tail_x6_r0_body.ws83

end Host.Load.Run.Tpl
end

section -- st83/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st83`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st83.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st83.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st83.s2.heap PRE_first_tail_x6_r0_body.st83.wrR ++ freshOf PRE_first_tail_x6_r0_body.st83.s2.heap PRE_first_tail_x6_r0_body.st83.s0.next PRE_first_tail_x6_r0_body.st83.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st83.wr : List Nat := PRE_first_tail_x6_r0_body.st83.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st83.heapFoot : PRE_first_tail_x6_r0_body.st83.s2.heap = setAll PRE_first_tail_x6_r0_body.st83.s0.heap PRE_first_tail_x6_r0_body.st83.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st83.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st83.s0.next PRE_first_tail_x6_r0_body.st83.s2.next = true
theorem PRE_first_tail_x6_r0_body.st83.grows : PRE_first_tail_x6_r0_body.st83.s0.next ≤ PRE_first_tail_x6_r0_body.st83.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st83.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st83.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st83.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st83.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st83.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st83.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st83.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st83.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st83.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st83.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st83.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st83.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st83.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st83.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st83.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st83.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st83.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st83.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st83.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st83.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st83.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st83.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st83.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st83.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st83.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st83.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st83.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st83.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st83.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st83.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st83.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st83.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF83
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 83 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB83 : nodupT PRE_first_tail_x6_r0_body.st83.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup83 : PRE_first_tail_x6_r0_body.st83.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB83).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB83 : PRE_first_tail_x6_r0_body.st83.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound83 : ∀ b ∈ PRE_first_tail_x6_r0_body.st83.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB83 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr83 := PRE_first_tail_x6_r0_body.st83.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq83 : PRE_first_tail_x6_r0_body.st83.s2.trace = PRE_first_tail_x6_r0_body.trFr83 ++ PRE_first_tail_x6_r0_body.st83.s0.trace
theorem PRE_first_tail_x6_r0_body.trace83 : ∃ fr, PRE_first_tail_x6_r0_body.st83.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st83.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq83⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide83 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB83 : (PRE_first_tail_x6_r0_body.wide83.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st83.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix83 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide83, WFix Map.id (Present PRE_first_tail_x6_r0_body.st83.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB83 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL83
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 83 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s805`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO83 : PRE_first_tail_x6_r0_body.st83.S0.oracle = PRE_first_tail_x6_r0_body.st83.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B83 : PRE_first_tail_x6_r0_body.st83.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st83.s0.next || (PRE_first_tail_x6_r0_body.st83.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot83 : Conv.StageFoot PRE_first_tail_x6_r0_body.st83.wr PRE_first_tail_x6_r0_body.st83.s0 PRE_first_tail_x6_r0_body.st83.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st83.heapFoot PRE_first_tail_x6_r0_body.wrNodup83 PRE_first_tail_x6_r0_body.wrBound83 PRE_first_tail_x6_r0_body.wr0B83 PRE_first_tail_x6_r0_body.st83.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged83 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st83.F.S → PRE_first_tail_x6_r0_body.st83.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st83.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st83.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs83 PRE_first_tail_x6_r0_body.st83.wr PRE_first_tail_x6_r0_body.s804 PRE_first_tail_x6_r0_body.st83.s2 PRE_first_tail_x6_r0_body.st83.s0
      PRE_first_tail_x6_r0_body.st83.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st83.F FR W stk M ν K PRE_first_tail_x6_r0_body.s805 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso83 PRE_first_tail_x6_r0_body.stFoot83 PRE_first_tail_x6_r0_body.wrNodup83 PRE_first_tail_x6_r0_body.wrBound83 PRE_first_tail_x6_r0_body.trace83 PRE_first_tail_x6_r0_body.mheap83
    PRE_first_tail_x6_r0_body.mnext83 PRE_first_tail_x6_r0_body.mctl83 PRE_first_tail_x6_r0_body.mstack83 PRE_first_tail_x6_r0_body.mjobs83 PRE_first_tail_x6_r0_body.mffi83 PRE_first_tail_x6_r0_body.mtrace83 PRE_first_tail_x6_r0_body.mstores83 h

def PRE_first_tail_x6_r0_body.arrEl83_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE83_2665 : arrOf PRE_first_tail_x6_r0_body.s805 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl83_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA83_2665 : isArrB PRE_first_tail_x6_r0_body.s805 2665 = true
theorem PRE_first_tail_x6_r0_body.arr83_2665 : ∃ o, PRE_first_tail_x6_r0_body.s805.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl83_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE83_2665 PRE_first_tail_x6_r0_body.arrA83_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN83_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl83_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR83_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl83_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN83_2665

def PRE_first_tail_x6_r0_body.arrEl83_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE83_2673467 : arrOf PRE_first_tail_x6_r0_body.s805 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl83_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA83_2673467 : isArrB PRE_first_tail_x6_r0_body.s805 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr83_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s805.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl83_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE83_2673467 PRE_first_tail_x6_r0_body.arrA83_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN83_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl83_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR83_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl83_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN83_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k83 : isArrB PRE_first_tail_x6_r0_body.s805 4910 = false
theorem PRE_first_tail_x6_r0_body.keep83 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s805 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k83 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr83_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl83_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ83
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 83 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s804`, the merged
state `PRE_first_tail_x6_r0_body.s805`, the canonical state `PRE_first_tail_x6_r0_body.s806`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl83 : PRE_first_tail_x6_r0_body.pl83.all (Nat.ble PRE_first_tail_x6_r0_body.s804.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd83 : nodupT PRE_first_tail_x6_r0_body.pl83 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn183 : Nat.ble PRE_first_tail_x6_r0_body.s804.next 2739888 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst83 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s804.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn83 : PRE_first_tail_x6_r0_body.s806.next = PRE_first_tail_x6_r0_body.s804.next + PRE_first_tail_x6_r0_body.pl83.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn83 : PRE_first_tail_x6_r0_body.s805.next = 2739888
kernel_rfl PRE_first_tail_x6_r0_body.zgrow83 : Nat.ble PRE_first_tail_x6_r0_body.s806.next PRE_first_tail_x6_r0_body.s805.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh83 : PRE_first_tail_x6_r0_body.S804.tab.all (fun e => PRE_first_tail_x6_r0_body.cws83.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd83 : nodupT PRE_first_tail_x6_r0_body.cws83 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi83 : PRE_first_tail_x6_r0_body.nr83.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S805.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt83 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s804.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg83_2665 : PRE_first_tail_x6_r0_body.s806.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s806 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk83_2665 : (objOf PRE_first_tail_x6_r0_body.s806 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm83_2665 : PRE_first_tail_x6_r0_body.s805.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa83.obj (objOf PRE_first_tail_x6_r0_body.s806 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s805 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg83_2673467 : PRE_first_tail_x6_r0_body.s806.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s806 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk83_2673467 : (objOf PRE_first_tail_x6_r0_body.s806 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm83_2673467 : PRE_first_tail_x6_r0_body.s805.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa83.obj (objOf PRE_first_tail_x6_r0_body.s806 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s805 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw83_4910 : (PRE_first_tail_x6_r0_body.s806.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw83_2673472 : (PRE_first_tail_x6_r0_body.s806.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw83_2673473 : (PRE_first_tail_x6_r0_body.s806.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd83 : PRE_first_tail_x6_r0_body.cl83.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr83 : PRE_first_tail_x6_r0_body.st83.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s804.next || PRE_first_tail_x6_r0_body.cl83.contains b) = true
def PRE_first_tail_x6_r0_body.zl83 : List Nat := PRE_first_tail_x6_r0_body.cl83.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE83 : PRE_first_tail_x6_r0_body.zl83.map (fun a => PRE_first_tail_x6_r0_body.s805.heap.get (PRE_first_tail_x6_r0_body.kappa83.a a)) = PRE_first_tail_x6_r0_body.zl83.map (fun a => (PRE_first_tail_x6_r0_body.s806.heap.get a).map PRE_first_tail_x6_r0_body.kappa83.hobj)
theorem PRE_first_tail_x6_r0_body.zimg83 : HeapImg PRE_first_tail_x6_r0_body.kappa83 PRE_first_tail_x6_r0_body.s806 PRE_first_tail_x6_r0_body.s805 PRE_first_tail_x6_r0_body.zl83 := PRE_first_tail_x6_r0_body.zimgE83
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl83 : PRE_first_tail_x6_r0_body.s805.ctl = PRE_first_tail_x6_r0_body.kappa83.ctl PRE_first_tail_x6_r0_body.s806.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack83 : PRE_first_tail_x6_r0_body.s805.stack = PRE_first_tail_x6_r0_body.s806.stack.map PRE_first_tail_x6_r0_body.kappa83.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs83 : PRE_first_tail_x6_r0_body.s805.jobs = PRE_first_tail_x6_r0_body.s806.jobs.map PRE_first_tail_x6_r0_body.kappa83.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores83 : PRE_first_tail_x6_r0_body.s805.stores = PRE_first_tail_x6_r0_body.kappa83.stores PRE_first_tail_x6_r0_body.s806.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots83 : checkRootsSupp PRE_first_tail_x6_r0_body.s806 3601 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC83 : PRE_first_tail_x6_r0_body.S804.tab.length + PRE_first_tail_x6_r0_body.cws83.length = 3601
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap83 : PRE_first_tail_x6_r0_body.kappa83 = Conv.Map.compact PRE_first_tail_x6_r0_body.s804.next 2739888 PRE_first_tail_x6_r0_body.S804.tab.length PRE_first_tail_x6_r0_body.pl83 (PRE_first_tail_x6_r0_body.nr83.map NumV.ref) PRE_first_tail_x6_r0_body.kd83.big
  PRE_first_tail_x6_r0_body.kd83.region PRE_first_tail_x6_r0_body.kd83.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin83 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s806.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc83 : Conv.jcleanListB (⟨19833, 16918, 2739878, 3601⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s806 PRE_first_tail_x6_r0_body.cl83 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB83 : noBigRootsP (fun i => !Conv.oldBigB (⟨19833, 16918, 2739878, 3601⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s806.trace PRE_first_tail_x6_r0_body.s806 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm83 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 16918 = true
theorem PRE_first_tail_x6_r0_body.cjcl83 (h : Conv.JClean (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s804) : Conv.JClean (⟨19833, 16918, 2739878, 3601⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s806 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle83)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap83 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd83 a ha)) PRE_first_tail_x6_r0_body.zjc83

end Host.Load.Run.Tpl
end

section -- st83/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st83.bodyLast from PRE_first_tail_x6_r0_body.st83.s1 to PRE_first_tail_x6_r0_body.st83.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st83.F PRE_first_tail_x6_r0_body.st83.s1).run PRE_first_tail_x6_r0_body.st83.S1 = some (PRE_first_tail_x6_r0_body.st83.s2, PRE_first_tail_x6_r0_body.st83.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st83.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st83.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st83.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st83.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st83/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st83.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st83.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st83.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st83.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st83.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st83.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st83.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st83.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st83.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st83.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st83.s0 PRE_first_tail_x6_r0_body.st83.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st83.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st83.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st83.s1 PRE_first_tail_x6_r0_body.st83.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st83/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st83.bodyK0F from PRE_first_tail_x6_r0_body.st83.s0 to PRE_first_tail_x6_r0_body.st83.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st83.F (PRE_first_tail_x6_r0_body.st83.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st83.ks 0).getD 0) PRE_first_tail_x6_r0_body.st83.s0 PRE_first_tail_x6_r0_body.st83.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st83.s1, PRE_first_tail_x6_r0_body.st83.S1)
theorem PRE_first_tail_x6_r0_body.st83.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st83.F (PRE_first_tail_x6_r0_body.st83.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st83.ks 0).getD 0) PRE_first_tail_x6_r0_body.st83.s0 PRE_first_tail_x6_r0_body.st83.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st83.s1, PRE_first_tail_x6_r0_body.st83.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st83.bodyOkLN_ok PRE_first_tail_x6_r0_body.st83.bodyK0F
end Host.Load.Run.Tpl
end

section -- st83/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st83.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st83.F (PRE_first_tail_x6_r0_body.st83.bodyOkL bytes rows) 98 PRE_first_tail_x6_r0_body.st83.s0 PRE_first_tail_x6_r0_body.st83.S0 = some (PRE_first_tail_x6_r0_body.st83.s1, PRE_first_tail_x6_r0_body.st83.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st83.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st83.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st83.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st83.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st83.F (PRE_first_tail_x6_r0_body.st83.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st83.s0
  S0 := PRE_first_tail_x6_r0_body.st83.S0
  s1 := PRE_first_tail_x6_r0_body.st83.s1
  S1 := PRE_first_tail_x6_r0_body.st83.S1
  s2 := PRE_first_tail_x6_r0_body.st83.s2
  S2 := PRE_first_tail_x6_r0_body.st83.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st83.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st83.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st83.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st83.bodyHalt
  last := PRE_first_tail_x6_r0_body.st83.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st83.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC84
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 84 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s823` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa84` into the merged state
`PRE_first_tail_x6_r0_body.s822`. -/

def PRE_first_tail_x6_r0_body.pl84 : List Nat := [2742483, 2741658, 2742489, 2742485, 2741660, 2742491]
def PRE_first_tail_x6_r0_body.nr84 : List Nat := [3704, 3703, 3679, 3687, 3692, 3697, 3702, 3676, 3677, 3678, 3685, 3686, 3674, 3681, 3682, 3683, 3684, 3680]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd84 : RData :=
  ⟨2741377, 2742526, Stage.setAll PTrie.nil [(2741371, 2742483), (2741372, 2741658), (2741373, 2742489), (2741374, 2742485), (2741375, 2741660), (2741376, 2742491)], Stage.setAll PTrie.nil [(19868, 19894), (19869, 19872), (19870, 19895)],
   19871, 19896, 16964, 16964, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(3674, .ref 3704), (3675, .ref 3703), (3676, .ref 3679), (3677, .ref 3687), (3678, .ref 3692), (3679, .ref 3697), (3680, .ref 3702), (3681, .ref 3676), (3682, .ref 3677), (3683, .ref 3678), (3684, .ref 3685), (3685, .ref 3686), (3686, .ref 3674), (3687, .ref 3681), (3688, .ref 3682), (3689, .ref 3683), (3690, .ref 3684), (3691, .ref 3680)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa84 : Map :=
  Conv.Map.compact 2741371 2742526 3674 PRE_first_tail_x6_r0_body.pl84 (PRE_first_tail_x6_r0_body.nr84.map NumV.ref) PRE_first_tail_x6_r0_body.kd84.big
    PRE_first_tail_x6_r0_body.kd84.region PRE_first_tail_x6_r0_body.kd84.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws84 : List Nat := [2424, 2425, 2426, 2427, 2428, 2429, 2430, 2431, 2432, 2433, 2434, 2435, 2436, 2437, 2438, 2439, 2440, 2441]
noncomputable def PRE_first_tail_x6_r0_body.crs84 : List SymE := PRE_first_tail_x6_r0_body.nr84.map fun r => (nth? PRE_first_tail_x6_r0_body.S822.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta84 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws84 PRE_first_tail_x6_r0_body.crs84
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB84 : List Nat := [2665, 2672517, 2673467, 2740545, 2741090, 2741346]

kernel_rfl PRE_first_tail_x6_r0_body.ctab84 : PRE_first_tail_x6_r0_body.S823.tab = PRE_first_tail_x6_r0_body.S821.tab ++ PRE_first_tail_x6_r0_body.cws84.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace84 : PRE_first_tail_x6_r0_body.s823.trace = PRE_first_tail_x6_r0_body.s821.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext84 : PRE_first_tail_x6_r0_body.s823.next = 2741377
kernel_rfl PRE_first_tail_x6_r0_body.ccounters84 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s823.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s823.ffi).mlx.nnext) = (19871, 16964)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue84 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s822.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s823.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa84.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp84 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s823.ffi).mlx.tokens.all (bSN 3692) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean84 : Conv.cleanListB 19871 131072 (fun r => Nat.ble 79484 r) PRE_first_tail_x6_r0_body.s823
    (PRE_first_tail_x6_r0_body.wrB84 ++ (List.range 6).map (2741371 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs84 : bigsOutB 19871 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s823.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK84
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl84`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl84 : List Nat := [2665, 2672517, 2673467, 2740545, 2741090, 2741346, 2741371, 2741372, 2741373, 2741374, 2741375, 2741376]
def PRE_first_tail_x6_r0_body.clo84 : List Nat := [19848, 19861, 19867, 19868, 19869, 19870]
def PRE_first_tail_x6_r0_body.cln84 : List Nat := [16937, 16938, 16939, 16940, 16941, 16942, 16943, 16944, 16945, 16946, 16947, 16948, 16949, 16950, 16951, 16952, 16953, 16954, 16955, 16956, 16957, 16958, 16959, 16960, 16961, 16962, 16963]
def PRE_first_tail_x6_r0_body.cli84 : List Nat := [16937, 16938, 16939, 16940, 16941, 16942, 16943, 16944, 16945, 16946, 16947, 16948, 16949, 16950, 16951, 16952, 16953, 16954, 16955, 16956, 16957, 16958, 16959, 16960, 16961, 16962, 16963]
kernel_rfl PRE_first_tail_x6_r0_body.cheap84 : PRE_first_tail_x6_r0_body.s823.heap = Stage.setAll PRE_first_tail_x6_r0_body.s821.heap (PRE_first_tail_x6_r0_body.cl84.filterMap fun a => (PRE_first_tail_x6_r0_body.s823.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe84 : Nat.ble PRE_first_tail_x6_r0_body.s821.next PRE_first_tail_x6_r0_body.s823.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP84 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s821 PRE_first_tail_x6_r0_body.s823 PRE_first_tail_x6_r0_body.cl84 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp84 : Conv.suppListB PRE_first_tail_x6_r0_body.s823 3692 PRE_first_tail_x6_r0_body.cl84 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound84 : Conv.boundListB PRE_first_tail_x6_r0_body.s823 PRE_first_tail_x6_r0_body.cl84 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK84 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s823.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln84.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s823.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK84 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s823.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo84.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s823.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK84 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s823.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli84.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s823.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst84 : Conv.sstListB 3692 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s823.ffi).mlx PRE_first_tail_x6_r0_body.cln84 PRE_first_tail_x6_r0_body.clo84 PRE_first_tail_x6_r0_body.cli84 = true

end Host.Load.Run.Tpl
end

section -- SiteCl84
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA84 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s823.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo84.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s823.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd84 : (PRE_first_tail_x6_r0_body.clo84 ++ PRE_first_tail_x6_r0_body.cln84 ++ PRE_first_tail_x6_r0_body.cli84).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle84 : Conv.Cnt.leB (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt) (⟨19871, 16964, 2741377, 3692⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck84 : Conv.ncleanListB (⟨19871, 16964, 2741377, 3692⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s823.ffi).mlx PRE_first_tail_x6_r0_body.clo84 PRE_first_tail_x6_r0_body.cln84 PRE_first_tail_x6_r0_body.cli84 = true
theorem PRE_first_tail_x6_r0_body.cncl84 (h : Conv.NClean (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx) : Conv.NClean (⟨19871, 16964, 2741377, 3692⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s823.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle84 PRE_first_tail_x6_r0_body.ckA84 PRE_first_tail_x6_r0_body.cobjsK84 PRE_first_tail_x6_r0_body.cnodesK84 PRE_first_tail_x6_r0_body.citemsK84 PRE_first_tail_x6_r0_body.cbd84 PRE_first_tail_x6_r0_body.cck84

end Host.Load.Run.Tpl
end

section -- SiteS84
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 84 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc84 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P84 : LoadP := PRE_first_tail_x6_r0_body.Pc84.raise 16964
kernel_rfl PRE_first_tail_x6_r0_body.craise84 : Nat.ble PRE_first_tail_x6_r0_body.Pc84.N0 16964 = true
theorem PRE_first_tail_x6_r0_body.raised84 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc84 PRE_first_tail_x6_r0_body.P84 :=
  .inr ⟨16964, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise84, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_84 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s823.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_84 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s822.ffi)
def PRE_first_tail_x6_r0_body.khinv84 : PTrie Nat := Stage.setAll PTrie.nil [(19894, 19868), (19872, 19869), (19895, 19870)]
def PRE_first_tail_x6_r0_body.kninv84 : PTrie Nat := Stage.setAll PTrie.nil [(16937, 16937), (16938, 16938), (16939, 16939), (16940, 16940), (16941, 16941), (16942, 16942), (16943, 16943), (16944, 16944), (16945, 16945), (16946, 16946), (16947, 16947), (16948, 16948), (16949, 16949), (16950, 16950), (16951, 16951), (16952, 16952), (16953, 16953), (16954, 16954), (16955, 16955), (16956, 16956), (16957, 16957), (16958, 16958), (16959, 16959), (16960, 16960), (16961, 16961), (16962, 16962), (16963, 16963)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS84 : List Nat := [19848, 19861, 19867, 19868, 19869, 19870, 19871, 19872, 19873, 19874, 19875, 19876, 19877, 19878, 19879, 19880, 19881, 19882, 19883, 19884, 19885, 19886, 19887, 19888, 19889, 19890, 19891, 19892, 19893, 19894, 19895]
def PRE_first_tail_x6_r0_body.cnS84 : List Nat := List.range' 16937 27
def PRE_first_tail_x6_r0_body.ciS84 : List Nat := [] ++ List.range' 16937 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh084 : PRE_first_tail_x6_r0_body.kd84.nh0 = PRE_first_tail_x6_r0_body.cx0_84.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh184 : PRE_first_tail_x6_r0_body.kd84.nh1 = PRE_first_tail_x6_r0_body.cx1_84.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn084 : PRE_first_tail_x6_r0_body.kd84.nn0 = PRE_first_tail_x6_r0_body.cx0_84.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn184 : PRE_first_tail_x6_r0_body.kd84.nn1 = PRE_first_tail_x6_r0_body.cx1_84.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo84 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P84.lo && Nat.ble PRE_first_tail_x6_r0_body.P84.lo PRE_first_tail_x6_r0_body.cx0_84.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P84.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P84.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt84 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_84.mlx.next PRE_first_tail_x6_r0_body.cx1_84.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_84.mlx.nnext PRE_first_tail_x6_r0_body.cx1_84.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband84 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P84.NL && Nat.ble PRE_first_tail_x6_r0_body.P84.NL PRE_first_tail_x6_r0_body.P84.N0 && Nat.ble PRE_first_tail_x6_r0_body.P84.N0 PRE_first_tail_x6_r0_body.cx0_84.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow84 : PRE_first_tail_x6_r0_body.kd84.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren84 : checkRenG PRE_first_tail_x6_r0_body.kd84.hnd PRE_first_tail_x6_r0_body.khinv84 (phB PRE_first_tail_x6_r0_body.cx0_84.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband84 : PRE_first_tail_x6_r0_body.kd84.checkBand PRE_first_tail_x6_r0_body.P84.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos84 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd84.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren84 : checkRenG PRE_first_tail_x6_r0_body.kd84.node PRE_first_tail_x6_r0_body.kninv84 (pnB PRE_first_tail_x6_r0_body.cx0_84.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow84 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd84.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P84.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd84.nodeF j) PRE_first_tail_x6_r0_body.cx1_84.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a84 : PRE_first_tail_x6_r0_body.cx0_84.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b84 : PRE_first_tail_x6_r0_body.cx0_84.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok184 : PRE_first_tail_x6_r0_body.cx1_84.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend84 : PRE_first_tail_x6_r0_body.cx1_84.mlx.pending = PRE_first_tail_x6_r0_body.cx0_84.mlx.pending.map PRE_first_tail_x6_r0_body.kappa84.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh84 : PRE_first_tail_x6_r0_body.cx1_84.mlx.errh = PRE_first_tail_x6_r0_body.cx0_84.mlx.errh.map PRE_first_tail_x6_r0_body.kappa84.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles84 : PRE_first_tail_x6_r0_body.cx1_84.mlx.files = PRE_first_tail_x6_r0_body.cx0_84.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch84 : PRE_first_tail_x6_r0_body.cx1_84.mlx.arch = PRE_first_tail_x6_r0_body.cx0_84.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes84 : PRE_first_tail_x6_r0_body.cx1_84.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_84.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired84 : PRE_first_tail_x6_r0_body.cx1_84.mlx.wired = PRE_first_tail_x6_r0_body.cx0_84.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost84 : PRE_first_tail_x6_r0_body.cx1_84.host = PRE_first_tail_x6_r0_body.cx0_84.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd84`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn084 : PRE_first_tail_x6_r0_body.kd84.n0 = 2741377
kernel_rfl PRE_first_tail_x6_r0_body.ckn184 : PRE_first_tail_x6_r0_body.kd84.n1 = 2742526
kernel_rfl PRE_first_tail_x6_r0_body.ckheap84 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd84.heap).all (fun x => Nat.ble 2741371 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl84 : (List.range 6).all (fun j => decide (PRE_first_tail_x6_r0_body.kd84.heap.get (2741371 + j) = nth? PRE_first_tail_x6_r0_body.pl84 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja84 : Nat.ble 2741371 2741371 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn84 : Nat.ble 3674 3674 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD84 : Nat.ble 2741371 PRE_first_tail_x6_r0_body.kd84.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn84 : Nat.ble 19868 PRE_first_tail_x6_r0_body.kd84.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn84 : Nat.ble 16937 PRE_first_tail_x6_r0_body.kd84.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb84 : Nat.ble 19868 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap84 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd84.heap).all (Nat.ble (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd84 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd84.hnd).all (Nat.ble (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode84 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd84.node).all (Nat.ble (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix84 : Conv.FixOld (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa84 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja84) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn84) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD84) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn84) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn84) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb84) PRE_first_tail_x6_r0_body.fheap84 PRE_first_tail_x6_r0_body.fhnd84 PRE_first_tail_x6_r0_body.fnode84
kernel_rfl PRE_first_tail_x6_r0_body.fcxn84 : (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn84 : (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle084 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_84.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_84.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk84 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd84.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A84 : PRE_first_tail_x6_r0_body.cx1_84.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS84.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_84.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O84 : PRE_first_tail_x6_r0_body.cx1_84.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS84.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_84.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N84 : PRE_first_tail_x6_r0_body.cx1_84.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS84.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_84.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I84 : PRE_first_tail_x6_r0_body.cx1_84.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS84.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_84.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd84 : (PRE_first_tail_x6_r0_body.clo84 ++ PRE_first_tail_x6_r0_body.cln84 ++ PRE_first_tail_x6_r0_body.cli84 ++ PRE_first_tail_x6_r0_body.cwS84 ++ PRE_first_tail_x6_r0_body.cnS84 ++ PRE_first_tail_x6_r0_body.ciS84).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW84 : PRE_first_tail_x6_r0_body.cwS84.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo84.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI84 : PRE_first_tail_x6_r0_body.ciS84.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli84.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN84 : PRE_first_tail_x6_r0_body.cnS84.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF84 : PRE_first_tail_x6_r0_body.cln84.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh84 : PRE_first_tail_x6_r0_body.clo84.all (handleOK PRE_first_tail_x6_r0_body.kappa84 PRE_first_tail_x6_r0_body.P84.lo PRE_first_tail_x6_r0_body.cx0_84.mlx PRE_first_tail_x6_r0_body.cx1_84.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo84 : PRE_first_tail_x6_r0_body.clo84.map (fun h => PRE_first_tail_x6_r0_body.cx1_84.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa84.handle h)) = PRE_first_tail_x6_r0_body.clo84.map (fun h => (PRE_first_tail_x6_r0_body.cx0_84.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa84.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok84 : PRE_first_tail_x6_r0_body.clo84.all (objOK PRE_first_tail_x6_r0_body.kappa84 PRE_first_tail_x6_r0_body.P84.NL PRE_first_tail_x6_r0_body.cx0_84.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd84 : PRE_first_tail_x6_r0_body.cln84.all (nodeOKF PRE_first_tail_x6_r0_body.kappa84 PRE_first_tail_x6_r0_body.P84 PRE_first_tail_x6_r0_body.cx0_84.mlx PRE_first_tail_x6_r0_body.cx1_84.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp84 : ((PRE_first_tail_x6_r0_body.cln84.filter (fullB PRE_first_tail_x6_r0_body.P84))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_84.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa84.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln84.filter (fullB PRE_first_tail_x6_r0_body.P84))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_84.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa84.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI84 : incrB PRE_first_tail_x6_r0_body.kd84.nodeF (List.range' 16937 27) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK84 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd84.node).all (fun k => Nat.ble 16937 k && Nat.blt k 16964) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL84 : (PRE_first_tail_x6_r0_body.cln84.filter (Nat.ble PRE_first_tail_x6_r0_body.P84.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd84.nodeF i) && (Nat.blt i 16964 || Nat.ble PRE_first_tail_x6_r0_body.kd84.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord84 : (PRE_first_tail_x6_r0_body.cln84.filter (Nat.ble PRE_first_tail_x6_r0_body.P84.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd84.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd84.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd84.nodeF j) (PRE_first_tail_x6_r0_body.kd84.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow84 PRE_first_tail_x6_r0_body.cnn184 PRE_first_tail_x6_r0_body.fnordI84 PRE_first_tail_x6_r0_body.fnordK84 PRE_first_tail_x6_r0_body.fnordL84
kernel_rfl PRE_first_tail_x6_r0_body.fi84 : PRE_first_tail_x6_r0_body.cli84.all (pnB PRE_first_tail_x6_r0_body.cx0_84.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii84 : PRE_first_tail_x6_r0_body.cli84.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_84.mlx.items.get (PRE_first_tail_x6_r0_body.kappa84.node k) = (PRE_first_tail_x6_r0_body.cx0_84.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa84.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot84 (clean : Conv.NClean (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P84.NL) (cl : SSt (· < 3692) PRE_first_tail_x6_r0_body.cx0_84.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P84 3692 PRE_first_tail_x6_r0_body.kappa84 PRE_first_tail_x6_r0_body.kd84 PRE_first_tail_x6_r0_body.khinv84 PRE_first_tail_x6_r0_body.kninv84 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx PRE_first_tail_x6_r0_body.cx0_84.mlx PRE_first_tail_x6_r0_body.cx1_84.mlx (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo84 PRE_first_tail_x6_r0_body.cln84 PRE_first_tail_x6_r0_body.cli84 PRE_first_tail_x6_r0_body.cwS84 PRE_first_tail_x6_r0_body.cnS84 PRE_first_tail_x6_r0_body.ciS84 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh084, PRE_first_tail_x6_r0_body.cnh184, PRE_first_tail_x6_r0_body.cnn084, PRE_first_tail_x6_r0_body.cnn184, PRE_first_tail_x6_r0_body.cplo84, PRE_first_tail_x6_r0_body.ccnt84, PRE_first_tail_x6_r0_body.cnband84, PRE_first_tail_x6_r0_body.chbelow84, PRE_first_tail_x6_r0_body.chren84, PRE_first_tail_x6_r0_body.cband84, PRE_first_tail_x6_r0_body.cnh1pos84, PRE_first_tail_x6_r0_body.cnren84, PRE_first_tail_x6_r0_body.cnlow84, PRE_first_tail_x6_r0_body.cabs0a84, PRE_first_tail_x6_r0_body.cabs0b84, PRE_first_tail_x6_r0_body.ctok184, PRE_first_tail_x6_r0_body.cpend84, PRE_first_tail_x6_r0_body.cerrh84, PRE_first_tail_x6_r0_body.cfiles84, PRE_first_tail_x6_r0_body.carch84, PRE_first_tail_x6_r0_body.csizes84, PRE_first_tail_x6_r0_body.cwired84, PRE_first_tail_x6_r0_body.cfix84, clean, PRE_first_tail_x6_r0_body.fcxn84, PRE_first_tail_x6_r0_body.fcnn84, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle084, PRE_first_tail_x6_r0_body.fnk84, PRE_first_tail_x6_r0_body.ckA84, PRE_first_tail_x6_r0_body.cobjsK84, PRE_first_tail_x6_r0_body.cnodesK84, PRE_first_tail_x6_r0_body.citemsK84, PRE_first_tail_x6_r0_body.f1A84, PRE_first_tail_x6_r0_body.f1O84, PRE_first_tail_x6_r0_body.f1N84, PRE_first_tail_x6_r0_body.f1I84, PRE_first_tail_x6_r0_body.fbd84, PRE_first_tail_x6_r0_body.fincW84, PRE_first_tail_x6_r0_body.fincI84, PRE_first_tail_x6_r0_body.fincN84, PRE_first_tail_x6_r0_body.flnF84, PRE_first_tail_x6_r0_body.fh84, PRE_first_tail_x6_r0_body.fo84, PRE_first_tail_x6_r0_body.fok84, PRE_first_tail_x6_r0_body.fnd84, PRE_first_tail_x6_r0_body.fp84, PRE_first_tail_x6_r0_body.fnord84, PRE_first_tail_x6_r0_body.fi84, PRE_first_tail_x6_r0_body.fii84⟩
theorem PRE_first_tail_x6_r0_body.cnshift84 (clean : Conv.NClean (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P84.NL) (cl : SSt (· < 3692) PRE_first_tail_x6_r0_body.cx0_84.mlx) : NShift PRE_first_tail_x6_r0_body.P84 3692 PRE_first_tail_x6_r0_body.kappa84 PRE_first_tail_x6_r0_body.cx0_84 PRE_first_tail_x6_r0_body.cx1_84 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot84 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost84 (compact_a_eq PRE_first_tail_x6_r0_body.ckn084 PRE_first_tail_x6_r0_body.ckn184 PRE_first_tail_x6_r0_body.ckheap84 PRE_first_tail_x6_r0_body.ckpl84)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_84 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s821.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_84 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s821.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_84 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s821.ffi) = some PRE_first_tail_x6_r0_body.fxC_84
kernel_rfl PRE_first_tail_x6_r0_body.okrC_84 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s821.ffi) = some PRE_first_tail_x6_r0_body.krC_84
noncomputable def PRE_first_tail_x6_r0_body.fx0_84 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s823.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_84 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s823.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_84 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s823.ffi) = some PRE_first_tail_x6_r0_body.fx0_84
kernel_rfl PRE_first_tail_x6_r0_body.okr0_84 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s823.ffi) = some PRE_first_tail_x6_r0_body.kr0_84
noncomputable def PRE_first_tail_x6_r0_body.fx1_84 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s822.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_84 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s822.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_84 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s822.ffi) = some PRE_first_tail_x6_r0_body.fx1_84
kernel_rfl PRE_first_tail_x6_r0_body.okr1_84 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s822.ffi) = some PRE_first_tail_x6_r0_body.kr1_84
kernel_rfl PRE_first_tail_x6_r0_body.ff084 : PRE_first_tail_x6_r0_body.fx0_84 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_84 (PRE_first_tail_x6_r0_body.clo84.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_84.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff184 : PRE_first_tail_x6_r0_body.fx1_84 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_84 (PRE_first_tail_x6_r0_body.cwS84.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_84.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck84 : freedLB PRE_first_tail_x6_r0_body.kappa84 PRE_first_tail_x6_r0_body.cx0_84.mlx PRE_first_tail_x6_r0_body.fx0_84 PRE_first_tail_x6_r0_body.fx1_84 PRE_first_tail_x6_r0_body.clo84 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf084 : PRE_first_tail_x6_r0_body.kr0_84.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_84.flags (PRE_first_tail_x6_r0_body.clo84.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_84.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt084 : PRE_first_tail_x6_r0_body.kr0_84.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_84.targs (PRE_first_tail_x6_r0_body.clo84.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_84.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf184 : PRE_first_tail_x6_r0_body.kr1_84.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_84.flags (PRE_first_tail_x6_r0_body.cwS84.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_84.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt184 : PRE_first_tail_x6_r0_body.kr1_84.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_84.targs (PRE_first_tail_x6_r0_body.cwS84.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_84.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck84 : krecLB PRE_first_tail_x6_r0_body.kappa84 3692 PRE_first_tail_x6_r0_body.cx0_84.mlx PRE_first_tail_x6_r0_body.kr0_84 PRE_first_tail_x6_r0_body.kr1_84 PRE_first_tail_x6_r0_body.clo84 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn84 : Nat.ble 3674 3692 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge84 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s822.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s823.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR84 : pendRegB PRE_first_tail_x6_r0_body.kappa84 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s823.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe84 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s823.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s822.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift84 (clean : Conv.NClean (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P84.NL) (cl : SSt (· < 3692) PRE_first_tail_x6_r0_body.cx0_84.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_84.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_84.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_84.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s821.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_84.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P84 3692 PRE_first_tail_x6_r0_body.kappa84 PRE_first_tail_x6_r0_body.s823.ffi PRE_first_tail_x6_r0_body.s822.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift84 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue84, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp84 t ht),
    PRE_first_tail_x6_r0_body.cbridge84,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s823.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s822.ffi) (PRE_first_tail_x6_r0_body.cfoot84 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_84 PRE_first_tail_x6_r0_body.ofx1_84 hobjC PRE_first_tail_x6_r0_body.ff084 PRE_first_tail_x6_r0_body.ff184 PRE_first_tail_x6_r0_body.ffck84,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s823.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s822.ffi) (PRE_first_tail_x6_r0_body.cfoot84 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_84 PRE_first_tail_x6_r0_body.okr1_84 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn84) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf084 PRE_first_tail_x6_r0_body.fkt084 PRE_first_tail_x6_r0_body.fkf184 PRE_first_tail_x6_r0_body.fkt184 PRE_first_tail_x6_r0_body.fkck84,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh084 PRE_first_tail_x6_r0_body.cnh184 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe84) PRE_first_tail_x6_r0_body.cpendR84⟩

end Host.Load.Run.Tpl
end

section -- st84/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st84 0
host_stream_state PRE_first_tail_x6_r0_body.st84 1
host_stream_state PRE_first_tail_x6_r0_body.st84 2
host_stream_state PRE_first_tail_x6_r0_body.st84 3
host_stream_state PRE_first_tail_x6_r0_body.st84 4
host_stream_state PRE_first_tail_x6_r0_body.st84 5
end Host.Load.Run.Tpl
end

section -- Site84
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 84 of chain `PRE_first_tail_x6_r0_body`: `ssmW__g84__g85` (`recurWindow`), the call state `PRE_first_tail_x6_r0_body.s821`, the merged state `PRE_first_tail_x6_r0_body.s822`,
the site template `PRE_first_tail_x6_r0_body.st84` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s823`: the merge.
The footprint's facts are in `SiteF84`, the compaction's in `SiteC84`, `SiteK84`, `SiteNa84`, `SiteNb84`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso84 : PRE_first_tail_x6_r0_body.st84.s0 = { PRE_first_tail_x6_r0_body.s821 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs84 : List Frame := PRE_first_tail_x6_r0_body.s821.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_84 : PRE_first_tail_x6_r0_body.S821.tab.length = 3674
kernel_rfl PRE_first_tail_x6_r0_body.tab0_84 : PRE_first_tail_x6_r0_body.st84.S0.tab = PRE_first_tail_x6_r0_body.S821.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws84 : List Nat := [2393, 2394, 2395, 2396, 2397, 2398, 2399, 2400, 2401, 2402, 2403, 2404, 2405, 2406, 2407, 2408, 2409, 2410, 2411, 2412, 2413, 2414, 2415, 2416, 2417, 2418, 2419, 2420, 2421, 2422, 2423]
kernel_rfl PRE_first_tail_x6_r0_body.fresh84 : (PRE_first_tail_x6_r0_body.S821.tab.all fun e => PRE_first_tail_x6_r0_body.ws84.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S821.oracle.all fun q => PRE_first_tail_x6_r0_body.ws84.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab84 : PRE_first_tail_x6_r0_body.S822.tab = PRE_first_tail_x6_r0_body.S821.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws84
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen84 : PRE_first_tail_x6_r0_body.st84.S5.tab.length - PRE_first_tail_x6_r0_body.st84.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged84`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap84 : PRE_first_tail_x6_r0_body.s822.heap = PRE_first_tail_x6_r0_body.st84.s5.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext84 : PRE_first_tail_x6_r0_body.s822.next = PRE_first_tail_x6_r0_body.st84.s5.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl84 : PRE_first_tail_x6_r0_body.s822.ctl = PRE_first_tail_x6_r0_body.st84.s5.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack84 : PRE_first_tail_x6_r0_body.s822.stack = PRE_first_tail_x6_r0_body.st84.s5.stack ++ PRE_first_tail_x6_r0_body.s821.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs84 : PRE_first_tail_x6_r0_body.s822.jobs = PRE_first_tail_x6_r0_body.st84.s5.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi84 : PRE_first_tail_x6_r0_body.s822.ffi = PRE_first_tail_x6_r0_body.st84.s5.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace84 : PRE_first_tail_x6_r0_body.s822.trace = PRE_first_tail_x6_r0_body.st84.s5.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores84 : PRE_first_tail_x6_r0_body.s822.stores = PRE_first_tail_x6_r0_body.st84.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD84
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 84 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived84 : PRE_first_tail_x6_r0_body.nr84.map (fun r => nth? PRE_first_tail_x6_r0_body.st84.S5.tab r) =
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
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo84 : PRE_first_tail_x6_r0_body.nr84.all (Nat.ble 3674) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj84 : PRE_first_tail_x6_r0_body.cws84.all (fun c => !PRE_first_tail_x6_r0_body.ws84.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ84 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws84 PRE_first_tail_x6_r0_body.crs84 PRE_first_tail_x6_r0_body.ws84

end Host.Load.Run.Tpl
end

section -- st84/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st84`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st84.wrR : List (Nat × Nat) := [(2672517, 2672518), (2740545, 2740546), (2741090, 2741091), (2741346, 2741347)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st84.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st84.s5.heap PRE_first_tail_x6_r0_body.st84.wrR ++ freshOf PRE_first_tail_x6_r0_body.st84.s5.heap PRE_first_tail_x6_r0_body.st84.s0.next PRE_first_tail_x6_r0_body.st84.s5.next
noncomputable def PRE_first_tail_x6_r0_body.st84.wr : List Nat := PRE_first_tail_x6_r0_body.st84.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st84.heapFoot : PRE_first_tail_x6_r0_body.st84.s5.heap = setAll PRE_first_tail_x6_r0_body.st84.s0.heap PRE_first_tail_x6_r0_body.st84.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st84.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st84.s0.next PRE_first_tail_x6_r0_body.st84.s5.next = true
theorem PRE_first_tail_x6_r0_body.st84.grows : PRE_first_tail_x6_r0_body.st84.s0.next ≤ PRE_first_tail_x6_r0_body.st84.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st84.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st84.wh : List Nat := [19848, 19861, 19867, 19868, 19869, 19870, 19871, 19872, 19873, 19874, 19875, 19876, 19877, 19878, 19879, 19880, 19881, 19882, 19883, 19884, 19885, 19886, 19887, 19888, 19889, 19890, 19891, 19892, 19893, 19894, 19895]
def PRE_first_tail_x6_r0_body.st84.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st84.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st84.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st84.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st84.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st84.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st84.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st84.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st84.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st84.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st84.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st84.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st84.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st84.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st84.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st84.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st84.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st84.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st84.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st84.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st84.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st84.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st84.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st84.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st84.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st84.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st84.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st84.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st84.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st84.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF84
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 84 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB84 : nodupT PRE_first_tail_x6_r0_body.st84.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup84 : PRE_first_tail_x6_r0_body.st84.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB84).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB84 : PRE_first_tail_x6_r0_body.st84.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound84 : ∀ b ∈ PRE_first_tail_x6_r0_body.st84.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB84 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr84 := PRE_first_tail_x6_r0_body.st84.s5.trace.take 120
kernel_rfl PRE_first_tail_x6_r0_body.traceEq84 : PRE_first_tail_x6_r0_body.st84.s5.trace = PRE_first_tail_x6_r0_body.trFr84 ++ PRE_first_tail_x6_r0_body.st84.s0.trace
theorem PRE_first_tail_x6_r0_body.trace84 : ∃ fr, PRE_first_tail_x6_r0_body.st84.s5.trace = fr ++ PRE_first_tail_x6_r0_body.st84.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq84⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide84 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB84 : (PRE_first_tail_x6_r0_body.wide84.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st84.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix84 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide84, WFix Map.id (Present PRE_first_tail_x6_r0_body.st84.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB84 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL84
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 84 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s822`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO84 : PRE_first_tail_x6_r0_body.st84.S0.oracle = PRE_first_tail_x6_r0_body.st84.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B84 : PRE_first_tail_x6_r0_body.st84.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st84.s0.next || (PRE_first_tail_x6_r0_body.st84.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot84 : Conv.StageFoot PRE_first_tail_x6_r0_body.st84.wr PRE_first_tail_x6_r0_body.st84.s0 PRE_first_tail_x6_r0_body.st84.s5 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st84.heapFoot PRE_first_tail_x6_r0_body.wrNodup84 PRE_first_tail_x6_r0_body.wrBound84 PRE_first_tail_x6_r0_body.wr0B84 PRE_first_tail_x6_r0_body.st84.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged84 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st84.F.S → PRE_first_tail_x6_r0_body.st84.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st84.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st84.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs84 PRE_first_tail_x6_r0_body.st84.wr PRE_first_tail_x6_r0_body.s821 PRE_first_tail_x6_r0_body.st84.s5 PRE_first_tail_x6_r0_body.st84.s0
      PRE_first_tail_x6_r0_body.st84.s5.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st84.F FR W stk M ν K PRE_first_tail_x6_r0_body.s822 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso84 PRE_first_tail_x6_r0_body.stFoot84 PRE_first_tail_x6_r0_body.wrNodup84 PRE_first_tail_x6_r0_body.wrBound84 PRE_first_tail_x6_r0_body.trace84 PRE_first_tail_x6_r0_body.mheap84
    PRE_first_tail_x6_r0_body.mnext84 PRE_first_tail_x6_r0_body.mctl84 PRE_first_tail_x6_r0_body.mstack84 PRE_first_tail_x6_r0_body.mjobs84 PRE_first_tail_x6_r0_body.mffi84 PRE_first_tail_x6_r0_body.mtrace84 PRE_first_tail_x6_r0_body.mstores84 h

def PRE_first_tail_x6_r0_body.arrEl84_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE84_2665 : arrOf PRE_first_tail_x6_r0_body.s822 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl84_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA84_2665 : isArrB PRE_first_tail_x6_r0_body.s822 2665 = true
theorem PRE_first_tail_x6_r0_body.arr84_2665 : ∃ o, PRE_first_tail_x6_r0_body.s822.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl84_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE84_2665 PRE_first_tail_x6_r0_body.arrA84_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN84_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl84_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR84_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl84_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN84_2665

def PRE_first_tail_x6_r0_body.arrEl84_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE84_2673467 : arrOf PRE_first_tail_x6_r0_body.s822 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl84_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA84_2673467 : isArrB PRE_first_tail_x6_r0_body.s822 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr84_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s822.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl84_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE84_2673467 PRE_first_tail_x6_r0_body.arrA84_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN84_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl84_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR84_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl84_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN84_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k84 : isArrB PRE_first_tail_x6_r0_body.s822 4910 = false
theorem PRE_first_tail_x6_r0_body.keep84 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s822 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k84 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr84_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl84_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ84
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 84 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s821`, the merged
state `PRE_first_tail_x6_r0_body.s822`, the canonical state `PRE_first_tail_x6_r0_body.s823`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl84 : PRE_first_tail_x6_r0_body.pl84.all (Nat.ble PRE_first_tail_x6_r0_body.s821.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd84 : nodupT PRE_first_tail_x6_r0_body.pl84 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn184 : Nat.ble PRE_first_tail_x6_r0_body.s821.next 2742526 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst84 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s821.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn84 : PRE_first_tail_x6_r0_body.s823.next = PRE_first_tail_x6_r0_body.s821.next + PRE_first_tail_x6_r0_body.pl84.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn84 : PRE_first_tail_x6_r0_body.s822.next = 2742526
kernel_rfl PRE_first_tail_x6_r0_body.zgrow84 : Nat.ble PRE_first_tail_x6_r0_body.s823.next PRE_first_tail_x6_r0_body.s822.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh84 : PRE_first_tail_x6_r0_body.S821.tab.all (fun e => PRE_first_tail_x6_r0_body.cws84.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd84 : nodupT PRE_first_tail_x6_r0_body.cws84 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi84 : PRE_first_tail_x6_r0_body.nr84.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S822.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt84 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s821.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg84_2665 : PRE_first_tail_x6_r0_body.s823.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s823 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk84_2665 : (objOf PRE_first_tail_x6_r0_body.s823 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm84_2665 : PRE_first_tail_x6_r0_body.s822.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa84.obj (objOf PRE_first_tail_x6_r0_body.s823 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s822 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg84_2673467 : PRE_first_tail_x6_r0_body.s823.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s823 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk84_2673467 : (objOf PRE_first_tail_x6_r0_body.s823 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm84_2673467 : PRE_first_tail_x6_r0_body.s822.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa84.obj (objOf PRE_first_tail_x6_r0_body.s823 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s822 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw84_4910 : (PRE_first_tail_x6_r0_body.s823.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw84_2673472 : (PRE_first_tail_x6_r0_body.s823.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw84_2673473 : (PRE_first_tail_x6_r0_body.s823.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd84 : PRE_first_tail_x6_r0_body.cl84.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr84 : PRE_first_tail_x6_r0_body.st84.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s821.next || PRE_first_tail_x6_r0_body.cl84.contains b) = true
def PRE_first_tail_x6_r0_body.zl84 : List Nat := PRE_first_tail_x6_r0_body.cl84.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE84 : PRE_first_tail_x6_r0_body.zl84.map (fun a => PRE_first_tail_x6_r0_body.s822.heap.get (PRE_first_tail_x6_r0_body.kappa84.a a)) = PRE_first_tail_x6_r0_body.zl84.map (fun a => (PRE_first_tail_x6_r0_body.s823.heap.get a).map PRE_first_tail_x6_r0_body.kappa84.hobj)
theorem PRE_first_tail_x6_r0_body.zimg84 : HeapImg PRE_first_tail_x6_r0_body.kappa84 PRE_first_tail_x6_r0_body.s823 PRE_first_tail_x6_r0_body.s822 PRE_first_tail_x6_r0_body.zl84 := PRE_first_tail_x6_r0_body.zimgE84
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl84 : PRE_first_tail_x6_r0_body.s822.ctl = PRE_first_tail_x6_r0_body.kappa84.ctl PRE_first_tail_x6_r0_body.s823.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack84 : PRE_first_tail_x6_r0_body.s822.stack = PRE_first_tail_x6_r0_body.s823.stack.map PRE_first_tail_x6_r0_body.kappa84.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs84 : PRE_first_tail_x6_r0_body.s822.jobs = PRE_first_tail_x6_r0_body.s823.jobs.map PRE_first_tail_x6_r0_body.kappa84.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores84 : PRE_first_tail_x6_r0_body.s822.stores = PRE_first_tail_x6_r0_body.kappa84.stores PRE_first_tail_x6_r0_body.s823.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots84 : checkRootsSupp PRE_first_tail_x6_r0_body.s823 3692 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC84 : PRE_first_tail_x6_r0_body.S821.tab.length + PRE_first_tail_x6_r0_body.cws84.length = 3692
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap84 : PRE_first_tail_x6_r0_body.kappa84 = Conv.Map.compact PRE_first_tail_x6_r0_body.s821.next 2742526 PRE_first_tail_x6_r0_body.S821.tab.length PRE_first_tail_x6_r0_body.pl84 (PRE_first_tail_x6_r0_body.nr84.map NumV.ref) PRE_first_tail_x6_r0_body.kd84.big
  PRE_first_tail_x6_r0_body.kd84.region PRE_first_tail_x6_r0_body.kd84.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin84 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s823.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc84 : Conv.jcleanListB (⟨19871, 16964, 2741377, 3692⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s823 PRE_first_tail_x6_r0_body.cl84 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB84 : noBigRootsP (fun i => !Conv.oldBigB (⟨19871, 16964, 2741377, 3692⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s823.trace PRE_first_tail_x6_r0_body.s823 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm84 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 16937 = true
theorem PRE_first_tail_x6_r0_body.cjcl84 (h : Conv.JClean (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s821) : Conv.JClean (⟨19871, 16964, 2741377, 3692⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s823 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle84)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap84 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd84 a ha)) PRE_first_tail_x6_r0_body.zjc84

end Host.Load.Run.Tpl
end

section -- st84/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st84.bodyLast from PRE_first_tail_x6_r0_body.st84.s4 to PRE_first_tail_x6_r0_body.st84.s5 :
  interpS (step PRE_first_tail_x6_r0_body.st84.F PRE_first_tail_x6_r0_body.st84.s4).run PRE_first_tail_x6_r0_body.st84.S4 = some (PRE_first_tail_x6_r0_body.st84.s5, PRE_first_tail_x6_r0_body.st84.S5)
kernel_rfl PRE_first_tail_x6_r0_body.st84.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st84.s4.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st84.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st84.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st84/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st84.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st84.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st84.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st84.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st84.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st84.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st84.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st84.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st84.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st84.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st84.s0 PRE_first_tail_x6_r0_body.st84.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st84.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st84.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st84.s4 PRE_first_tail_x6_r0_body.st84.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st84/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st84.bodyK0F from PRE_first_tail_x6_r0_body.st84.s0 to PRE_first_tail_x6_r0_body.st84.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st84.F (PRE_first_tail_x6_r0_body.st84.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st84.ks 0).getD 0) PRE_first_tail_x6_r0_body.st84.s0 PRE_first_tail_x6_r0_body.st84.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st84.s1, PRE_first_tail_x6_r0_body.st84.S1)
theorem PRE_first_tail_x6_r0_body.st84.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st84.F (PRE_first_tail_x6_r0_body.st84.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st84.ks 0).getD 0) PRE_first_tail_x6_r0_body.st84.s0 PRE_first_tail_x6_r0_body.st84.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st84.s1, PRE_first_tail_x6_r0_body.st84.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st84.bodyOkLN_ok PRE_first_tail_x6_r0_body.st84.bodyK0F
end Host.Load.Run.Tpl
end

section -- st84/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st84.bodyK1F from PRE_first_tail_x6_r0_body.st84.s1 to PRE_first_tail_x6_r0_body.st84.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st84.F (PRE_first_tail_x6_r0_body.st84.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st84.ks 1).getD 0) PRE_first_tail_x6_r0_body.st84.s1 PRE_first_tail_x6_r0_body.st84.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st84.s2, PRE_first_tail_x6_r0_body.st84.S2)
theorem PRE_first_tail_x6_r0_body.st84.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st84.F (PRE_first_tail_x6_r0_body.st84.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st84.ks 1).getD 0) PRE_first_tail_x6_r0_body.st84.s1 PRE_first_tail_x6_r0_body.st84.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st84.s2, PRE_first_tail_x6_r0_body.st84.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st84.bodyOkLN_ok PRE_first_tail_x6_r0_body.st84.bodyK1F
end Host.Load.Run.Tpl
end

section -- st84/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st84.bodyK2F from PRE_first_tail_x6_r0_body.st84.s2 to PRE_first_tail_x6_r0_body.st84.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st84.F (PRE_first_tail_x6_r0_body.st84.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st84.ks 2).getD 0) PRE_first_tail_x6_r0_body.st84.s2 PRE_first_tail_x6_r0_body.st84.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st84.s3, PRE_first_tail_x6_r0_body.st84.S3)
theorem PRE_first_tail_x6_r0_body.st84.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st84.F (PRE_first_tail_x6_r0_body.st84.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st84.ks 2).getD 0) PRE_first_tail_x6_r0_body.st84.s2 PRE_first_tail_x6_r0_body.st84.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st84.s3, PRE_first_tail_x6_r0_body.st84.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st84.bodyOkLN_ok PRE_first_tail_x6_r0_body.st84.bodyK2F
end Host.Load.Run.Tpl
end

section -- st84/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st84.bodyK3F from PRE_first_tail_x6_r0_body.st84.s3 to PRE_first_tail_x6_r0_body.st84.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st84.F (PRE_first_tail_x6_r0_body.st84.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st84.ks 3).getD 0) PRE_first_tail_x6_r0_body.st84.s3 PRE_first_tail_x6_r0_body.st84.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st84.s4, PRE_first_tail_x6_r0_body.st84.S4)
theorem PRE_first_tail_x6_r0_body.st84.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st84.F (PRE_first_tail_x6_r0_body.st84.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st84.ks 3).getD 0) PRE_first_tail_x6_r0_body.st84.s3 PRE_first_tail_x6_r0_body.st84.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st84.s4, PRE_first_tail_x6_r0_body.st84.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st84.bodyOkLN_ok PRE_first_tail_x6_r0_body.st84.bodyK3F
end Host.Load.Run.Tpl
end

section -- st84/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st84.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st84.F (PRE_first_tail_x6_r0_body.st84.bodyOkL bytes rows) 11334 PRE_first_tail_x6_r0_body.st84.s0 PRE_first_tail_x6_r0_body.st84.S0 = some (PRE_first_tail_x6_r0_body.st84.s4, PRE_first_tail_x6_r0_body.st84.S4) :=
  runOk_trans PRE_first_tail_x6_r0_body.st84.F (PRE_first_tail_x6_r0_body.st84.bodyOkL bytes rows) ((((nth? PRE_first_tail_x6_r0_body.st84.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st84.ks 1).getD 0)) + ((nth? PRE_first_tail_x6_r0_body.st84.ks 2).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st84.ks 3).getD 0) PRE_first_tail_x6_r0_body.st84.s0 PRE_first_tail_x6_r0_body.st84.s3 PRE_first_tail_x6_r0_body.st84.s4 PRE_first_tail_x6_r0_body.st84.S0 PRE_first_tail_x6_r0_body.st84.S3 PRE_first_tail_x6_r0_body.st84.S4 (runOk_trans PRE_first_tail_x6_r0_body.st84.F (PRE_first_tail_x6_r0_body.st84.bodyOkL bytes rows) (((nth? PRE_first_tail_x6_r0_body.st84.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st84.ks 1).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st84.ks 2).getD 0) PRE_first_tail_x6_r0_body.st84.s0 PRE_first_tail_x6_r0_body.st84.s2 PRE_first_tail_x6_r0_body.st84.s3 PRE_first_tail_x6_r0_body.st84.S0 PRE_first_tail_x6_r0_body.st84.S2 PRE_first_tail_x6_r0_body.st84.S3 (runOk_trans PRE_first_tail_x6_r0_body.st84.F (PRE_first_tail_x6_r0_body.st84.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st84.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st84.ks 1).getD 0) PRE_first_tail_x6_r0_body.st84.s0 PRE_first_tail_x6_r0_body.st84.s1 PRE_first_tail_x6_r0_body.st84.s2 PRE_first_tail_x6_r0_body.st84.S0 PRE_first_tail_x6_r0_body.st84.S1 PRE_first_tail_x6_r0_body.st84.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st84.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st84.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st84.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st84.bodyK3 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st84.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st84.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st84.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st84.F (PRE_first_tail_x6_r0_body.st84.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st84.s0
  S0 := PRE_first_tail_x6_r0_body.st84.S0
  s1 := PRE_first_tail_x6_r0_body.st84.s4
  S1 := PRE_first_tail_x6_r0_body.st84.S4
  s2 := PRE_first_tail_x6_r0_body.st84.s5
  S2 := PRE_first_tail_x6_r0_body.st84.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st84.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st84.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st84.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st84.bodyHalt
  last := PRE_first_tail_x6_r0_body.st84.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st84.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC85
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 85 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s831` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa85` into the merged state
`PRE_first_tail_x6_r0_body.s830`. -/

def PRE_first_tail_x6_r0_body.pl85 : List Nat := []
def PRE_first_tail_x6_r0_body.nr85 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd85 : RData :=
  ⟨2741867, 2741869, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19884, 19884, 16977, 16977, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa85 : Map :=
  Conv.Map.compact 2741867 2741869 3713 PRE_first_tail_x6_r0_body.pl85 (PRE_first_tail_x6_r0_body.nr85.map NumV.ref) PRE_first_tail_x6_r0_body.kd85.big
    PRE_first_tail_x6_r0_body.kd85.region PRE_first_tail_x6_r0_body.kd85.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws85 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs85 : List SymE := PRE_first_tail_x6_r0_body.nr85.map fun r => (nth? PRE_first_tail_x6_r0_body.S830.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta85 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws85 PRE_first_tail_x6_r0_body.crs85
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB85 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab85 : PRE_first_tail_x6_r0_body.S831.tab = PRE_first_tail_x6_r0_body.S829.tab ++ PRE_first_tail_x6_r0_body.cws85.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace85 : PRE_first_tail_x6_r0_body.s831.trace = PRE_first_tail_x6_r0_body.s829.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext85 : PRE_first_tail_x6_r0_body.s831.next = 2741867
kernel_rfl PRE_first_tail_x6_r0_body.ccounters85 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s831.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s831.ffi).mlx.nnext) = (19884, 16977)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue85 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s830.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s831.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa85.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp85 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s831.ffi).mlx.tokens.all (bSN 3713) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean85 : Conv.cleanListB 19884 131072 (fun r => Nat.ble 79536 r) PRE_first_tail_x6_r0_body.s831
    (PRE_first_tail_x6_r0_body.wrB85 ++ (List.range 0).map (2741867 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs85 : bigsOutB 19884 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s831.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK85
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl85`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl85 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo85 : List Nat := []
def PRE_first_tail_x6_r0_body.cln85 : List Nat := []
def PRE_first_tail_x6_r0_body.cli85 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap85 : PRE_first_tail_x6_r0_body.s831.heap = Stage.setAll PRE_first_tail_x6_r0_body.s829.heap (PRE_first_tail_x6_r0_body.cl85.filterMap fun a => (PRE_first_tail_x6_r0_body.s831.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe85 : Nat.ble PRE_first_tail_x6_r0_body.s829.next PRE_first_tail_x6_r0_body.s831.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP85 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s829 PRE_first_tail_x6_r0_body.s831 PRE_first_tail_x6_r0_body.cl85 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp85 : Conv.suppListB PRE_first_tail_x6_r0_body.s831 3713 PRE_first_tail_x6_r0_body.cl85 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound85 : Conv.boundListB PRE_first_tail_x6_r0_body.s831 PRE_first_tail_x6_r0_body.cl85 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK85 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s831.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln85.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s831.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK85 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s831.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo85.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s831.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK85 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s831.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli85.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s831.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst85 : Conv.sstListB 3713 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s831.ffi).mlx PRE_first_tail_x6_r0_body.cln85 PRE_first_tail_x6_r0_body.clo85 PRE_first_tail_x6_r0_body.cli85 = true

end Host.Load.Run.Tpl
end

section -- SiteCl85
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA85 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s831.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo85.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s831.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd85 : (PRE_first_tail_x6_r0_body.clo85 ++ PRE_first_tail_x6_r0_body.cln85 ++ PRE_first_tail_x6_r0_body.cli85).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle85 : Conv.Cnt.leB (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck85 : Conv.ncleanListB (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s831.ffi).mlx PRE_first_tail_x6_r0_body.clo85 PRE_first_tail_x6_r0_body.cln85 PRE_first_tail_x6_r0_body.cli85 = true
theorem PRE_first_tail_x6_r0_body.cncl85 (h : Conv.NClean (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx) : Conv.NClean (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s831.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle85 PRE_first_tail_x6_r0_body.ckA85 PRE_first_tail_x6_r0_body.cobjsK85 PRE_first_tail_x6_r0_body.cnodesK85 PRE_first_tail_x6_r0_body.citemsK85 PRE_first_tail_x6_r0_body.cbd85 PRE_first_tail_x6_r0_body.cck85

end Host.Load.Run.Tpl
end

section -- SiteS85
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 85 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc85 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P85 : LoadP := PRE_first_tail_x6_r0_body.Pc85.raise 16977
kernel_rfl PRE_first_tail_x6_r0_body.craise85 : Nat.ble PRE_first_tail_x6_r0_body.Pc85.N0 16977 = true
theorem PRE_first_tail_x6_r0_body.raised85 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc85 PRE_first_tail_x6_r0_body.P85 :=
  .inr ⟨16977, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise85, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_85 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s831.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_85 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s830.ffi)
def PRE_first_tail_x6_r0_body.khinv85 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv85 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS85 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS85 : List Nat := List.range' 16977 0
def PRE_first_tail_x6_r0_body.ciS85 : List Nat := [] ++ List.range' 16977 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh085 : PRE_first_tail_x6_r0_body.kd85.nh0 = PRE_first_tail_x6_r0_body.cx0_85.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh185 : PRE_first_tail_x6_r0_body.kd85.nh1 = PRE_first_tail_x6_r0_body.cx1_85.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn085 : PRE_first_tail_x6_r0_body.kd85.nn0 = PRE_first_tail_x6_r0_body.cx0_85.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn185 : PRE_first_tail_x6_r0_body.kd85.nn1 = PRE_first_tail_x6_r0_body.cx1_85.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo85 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P85.lo && Nat.ble PRE_first_tail_x6_r0_body.P85.lo PRE_first_tail_x6_r0_body.cx0_85.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P85.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P85.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt85 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_85.mlx.next PRE_first_tail_x6_r0_body.cx1_85.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_85.mlx.nnext PRE_first_tail_x6_r0_body.cx1_85.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband85 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P85.NL && Nat.ble PRE_first_tail_x6_r0_body.P85.NL PRE_first_tail_x6_r0_body.P85.N0 && Nat.ble PRE_first_tail_x6_r0_body.P85.N0 PRE_first_tail_x6_r0_body.cx0_85.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow85 : PRE_first_tail_x6_r0_body.kd85.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren85 : checkRenG PRE_first_tail_x6_r0_body.kd85.hnd PRE_first_tail_x6_r0_body.khinv85 (phB PRE_first_tail_x6_r0_body.cx0_85.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband85 : PRE_first_tail_x6_r0_body.kd85.checkBand PRE_first_tail_x6_r0_body.P85.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos85 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd85.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren85 : checkRenG PRE_first_tail_x6_r0_body.kd85.node PRE_first_tail_x6_r0_body.kninv85 (pnB PRE_first_tail_x6_r0_body.cx0_85.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow85 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd85.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P85.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd85.nodeF j) PRE_first_tail_x6_r0_body.cx1_85.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a85 : PRE_first_tail_x6_r0_body.cx0_85.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b85 : PRE_first_tail_x6_r0_body.cx0_85.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok185 : PRE_first_tail_x6_r0_body.cx1_85.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend85 : PRE_first_tail_x6_r0_body.cx1_85.mlx.pending = PRE_first_tail_x6_r0_body.cx0_85.mlx.pending.map PRE_first_tail_x6_r0_body.kappa85.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh85 : PRE_first_tail_x6_r0_body.cx1_85.mlx.errh = PRE_first_tail_x6_r0_body.cx0_85.mlx.errh.map PRE_first_tail_x6_r0_body.kappa85.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles85 : PRE_first_tail_x6_r0_body.cx1_85.mlx.files = PRE_first_tail_x6_r0_body.cx0_85.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch85 : PRE_first_tail_x6_r0_body.cx1_85.mlx.arch = PRE_first_tail_x6_r0_body.cx0_85.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes85 : PRE_first_tail_x6_r0_body.cx1_85.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_85.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired85 : PRE_first_tail_x6_r0_body.cx1_85.mlx.wired = PRE_first_tail_x6_r0_body.cx0_85.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost85 : PRE_first_tail_x6_r0_body.cx1_85.host = PRE_first_tail_x6_r0_body.cx0_85.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd85`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn085 : PRE_first_tail_x6_r0_body.kd85.n0 = 2741867
kernel_rfl PRE_first_tail_x6_r0_body.ckn185 : PRE_first_tail_x6_r0_body.kd85.n1 = 2741869
kernel_rfl PRE_first_tail_x6_r0_body.ckheap85 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd85.heap).all (fun x => Nat.ble 2741867 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl85 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_body.kd85.heap.get (2741867 + j) = nth? PRE_first_tail_x6_r0_body.pl85 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja85 : Nat.ble 2741867 2741867 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn85 : Nat.ble 3713 3713 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD85 : Nat.ble 2741867 PRE_first_tail_x6_r0_body.kd85.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn85 : Nat.ble 19884 PRE_first_tail_x6_r0_body.kd85.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn85 : Nat.ble 16977 PRE_first_tail_x6_r0_body.kd85.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb85 : Nat.ble 19884 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap85 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd85.heap).all (Nat.ble (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd85 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd85.hnd).all (Nat.ble (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode85 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd85.node).all (Nat.ble (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix85 : Conv.FixOld (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa85 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja85) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn85) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD85) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn85) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn85) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb85) PRE_first_tail_x6_r0_body.fheap85 PRE_first_tail_x6_r0_body.fhnd85 PRE_first_tail_x6_r0_body.fnode85
kernel_rfl PRE_first_tail_x6_r0_body.fcxn85 : (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn85 : (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle085 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_85.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_85.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk85 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd85.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A85 : PRE_first_tail_x6_r0_body.cx1_85.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS85.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_85.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O85 : PRE_first_tail_x6_r0_body.cx1_85.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS85.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_85.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N85 : PRE_first_tail_x6_r0_body.cx1_85.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS85.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_85.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I85 : PRE_first_tail_x6_r0_body.cx1_85.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS85.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_85.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd85 : (PRE_first_tail_x6_r0_body.clo85 ++ PRE_first_tail_x6_r0_body.cln85 ++ PRE_first_tail_x6_r0_body.cli85 ++ PRE_first_tail_x6_r0_body.cwS85 ++ PRE_first_tail_x6_r0_body.cnS85 ++ PRE_first_tail_x6_r0_body.ciS85).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW85 : PRE_first_tail_x6_r0_body.cwS85.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo85.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI85 : PRE_first_tail_x6_r0_body.ciS85.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli85.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN85 : PRE_first_tail_x6_r0_body.cnS85.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF85 : PRE_first_tail_x6_r0_body.cln85.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh85 : PRE_first_tail_x6_r0_body.clo85.all (handleOK PRE_first_tail_x6_r0_body.kappa85 PRE_first_tail_x6_r0_body.P85.lo PRE_first_tail_x6_r0_body.cx0_85.mlx PRE_first_tail_x6_r0_body.cx1_85.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo85 : PRE_first_tail_x6_r0_body.clo85.map (fun h => PRE_first_tail_x6_r0_body.cx1_85.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa85.handle h)) = PRE_first_tail_x6_r0_body.clo85.map (fun h => (PRE_first_tail_x6_r0_body.cx0_85.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa85.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok85 : PRE_first_tail_x6_r0_body.clo85.all (objOK PRE_first_tail_x6_r0_body.kappa85 PRE_first_tail_x6_r0_body.P85.NL PRE_first_tail_x6_r0_body.cx0_85.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd85 : PRE_first_tail_x6_r0_body.cln85.all (nodeOKF PRE_first_tail_x6_r0_body.kappa85 PRE_first_tail_x6_r0_body.P85 PRE_first_tail_x6_r0_body.cx0_85.mlx PRE_first_tail_x6_r0_body.cx1_85.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp85 : ((PRE_first_tail_x6_r0_body.cln85.filter (fullB PRE_first_tail_x6_r0_body.P85))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_85.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa85.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln85.filter (fullB PRE_first_tail_x6_r0_body.P85))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_85.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa85.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI85 : incrB PRE_first_tail_x6_r0_body.kd85.nodeF (List.range' 16977 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK85 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd85.node).all (fun k => Nat.ble 16977 k && Nat.blt k 16977) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL85 : (PRE_first_tail_x6_r0_body.cln85.filter (Nat.ble PRE_first_tail_x6_r0_body.P85.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd85.nodeF i) && (Nat.blt i 16977 || Nat.ble PRE_first_tail_x6_r0_body.kd85.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord85 : (PRE_first_tail_x6_r0_body.cln85.filter (Nat.ble PRE_first_tail_x6_r0_body.P85.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd85.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd85.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd85.nodeF j) (PRE_first_tail_x6_r0_body.kd85.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow85 PRE_first_tail_x6_r0_body.cnn185 PRE_first_tail_x6_r0_body.fnordI85 PRE_first_tail_x6_r0_body.fnordK85 PRE_first_tail_x6_r0_body.fnordL85
kernel_rfl PRE_first_tail_x6_r0_body.fi85 : PRE_first_tail_x6_r0_body.cli85.all (pnB PRE_first_tail_x6_r0_body.cx0_85.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii85 : PRE_first_tail_x6_r0_body.cli85.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_85.mlx.items.get (PRE_first_tail_x6_r0_body.kappa85.node k) = (PRE_first_tail_x6_r0_body.cx0_85.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa85.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot85 (clean : Conv.NClean (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P85.NL) (cl : SSt (· < 3713) PRE_first_tail_x6_r0_body.cx0_85.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P85 3713 PRE_first_tail_x6_r0_body.kappa85 PRE_first_tail_x6_r0_body.kd85 PRE_first_tail_x6_r0_body.khinv85 PRE_first_tail_x6_r0_body.kninv85 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx PRE_first_tail_x6_r0_body.cx0_85.mlx PRE_first_tail_x6_r0_body.cx1_85.mlx (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo85 PRE_first_tail_x6_r0_body.cln85 PRE_first_tail_x6_r0_body.cli85 PRE_first_tail_x6_r0_body.cwS85 PRE_first_tail_x6_r0_body.cnS85 PRE_first_tail_x6_r0_body.ciS85 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh085, PRE_first_tail_x6_r0_body.cnh185, PRE_first_tail_x6_r0_body.cnn085, PRE_first_tail_x6_r0_body.cnn185, PRE_first_tail_x6_r0_body.cplo85, PRE_first_tail_x6_r0_body.ccnt85, PRE_first_tail_x6_r0_body.cnband85, PRE_first_tail_x6_r0_body.chbelow85, PRE_first_tail_x6_r0_body.chren85, PRE_first_tail_x6_r0_body.cband85, PRE_first_tail_x6_r0_body.cnh1pos85, PRE_first_tail_x6_r0_body.cnren85, PRE_first_tail_x6_r0_body.cnlow85, PRE_first_tail_x6_r0_body.cabs0a85, PRE_first_tail_x6_r0_body.cabs0b85, PRE_first_tail_x6_r0_body.ctok185, PRE_first_tail_x6_r0_body.cpend85, PRE_first_tail_x6_r0_body.cerrh85, PRE_first_tail_x6_r0_body.cfiles85, PRE_first_tail_x6_r0_body.carch85, PRE_first_tail_x6_r0_body.csizes85, PRE_first_tail_x6_r0_body.cwired85, PRE_first_tail_x6_r0_body.cfix85, clean, PRE_first_tail_x6_r0_body.fcxn85, PRE_first_tail_x6_r0_body.fcnn85, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle085, PRE_first_tail_x6_r0_body.fnk85, PRE_first_tail_x6_r0_body.ckA85, PRE_first_tail_x6_r0_body.cobjsK85, PRE_first_tail_x6_r0_body.cnodesK85, PRE_first_tail_x6_r0_body.citemsK85, PRE_first_tail_x6_r0_body.f1A85, PRE_first_tail_x6_r0_body.f1O85, PRE_first_tail_x6_r0_body.f1N85, PRE_first_tail_x6_r0_body.f1I85, PRE_first_tail_x6_r0_body.fbd85, PRE_first_tail_x6_r0_body.fincW85, PRE_first_tail_x6_r0_body.fincI85, PRE_first_tail_x6_r0_body.fincN85, PRE_first_tail_x6_r0_body.flnF85, PRE_first_tail_x6_r0_body.fh85, PRE_first_tail_x6_r0_body.fo85, PRE_first_tail_x6_r0_body.fok85, PRE_first_tail_x6_r0_body.fnd85, PRE_first_tail_x6_r0_body.fp85, PRE_first_tail_x6_r0_body.fnord85, PRE_first_tail_x6_r0_body.fi85, PRE_first_tail_x6_r0_body.fii85⟩
theorem PRE_first_tail_x6_r0_body.cnshift85 (clean : Conv.NClean (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P85.NL) (cl : SSt (· < 3713) PRE_first_tail_x6_r0_body.cx0_85.mlx) : NShift PRE_first_tail_x6_r0_body.P85 3713 PRE_first_tail_x6_r0_body.kappa85 PRE_first_tail_x6_r0_body.cx0_85 PRE_first_tail_x6_r0_body.cx1_85 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot85 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost85 (compact_a_eq PRE_first_tail_x6_r0_body.ckn085 PRE_first_tail_x6_r0_body.ckn185 PRE_first_tail_x6_r0_body.ckheap85 PRE_first_tail_x6_r0_body.ckpl85)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_85 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s829.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_85 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s829.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_85 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s829.ffi) = some PRE_first_tail_x6_r0_body.fxC_85
kernel_rfl PRE_first_tail_x6_r0_body.okrC_85 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s829.ffi) = some PRE_first_tail_x6_r0_body.krC_85
noncomputable def PRE_first_tail_x6_r0_body.fx0_85 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s831.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_85 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s831.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_85 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s831.ffi) = some PRE_first_tail_x6_r0_body.fx0_85
kernel_rfl PRE_first_tail_x6_r0_body.okr0_85 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s831.ffi) = some PRE_first_tail_x6_r0_body.kr0_85
noncomputable def PRE_first_tail_x6_r0_body.fx1_85 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s830.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_85 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s830.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_85 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s830.ffi) = some PRE_first_tail_x6_r0_body.fx1_85
kernel_rfl PRE_first_tail_x6_r0_body.okr1_85 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s830.ffi) = some PRE_first_tail_x6_r0_body.kr1_85
kernel_rfl PRE_first_tail_x6_r0_body.ff085 : PRE_first_tail_x6_r0_body.fx0_85 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_85 (PRE_first_tail_x6_r0_body.clo85.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_85.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff185 : PRE_first_tail_x6_r0_body.fx1_85 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_85 (PRE_first_tail_x6_r0_body.cwS85.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_85.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck85 : freedLB PRE_first_tail_x6_r0_body.kappa85 PRE_first_tail_x6_r0_body.cx0_85.mlx PRE_first_tail_x6_r0_body.fx0_85 PRE_first_tail_x6_r0_body.fx1_85 PRE_first_tail_x6_r0_body.clo85 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf085 : PRE_first_tail_x6_r0_body.kr0_85.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_85.flags (PRE_first_tail_x6_r0_body.clo85.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_85.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt085 : PRE_first_tail_x6_r0_body.kr0_85.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_85.targs (PRE_first_tail_x6_r0_body.clo85.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_85.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf185 : PRE_first_tail_x6_r0_body.kr1_85.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_85.flags (PRE_first_tail_x6_r0_body.cwS85.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_85.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt185 : PRE_first_tail_x6_r0_body.kr1_85.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_85.targs (PRE_first_tail_x6_r0_body.cwS85.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_85.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck85 : krecLB PRE_first_tail_x6_r0_body.kappa85 3713 PRE_first_tail_x6_r0_body.cx0_85.mlx PRE_first_tail_x6_r0_body.kr0_85 PRE_first_tail_x6_r0_body.kr1_85 PRE_first_tail_x6_r0_body.clo85 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn85 : Nat.ble 3713 3713 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge85 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s830.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s831.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR85 : pendRegB PRE_first_tail_x6_r0_body.kappa85 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s831.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe85 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s831.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s830.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift85 (clean : Conv.NClean (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P85.NL) (cl : SSt (· < 3713) PRE_first_tail_x6_r0_body.cx0_85.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_85.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_85.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_85.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s829.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_85.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P85 3713 PRE_first_tail_x6_r0_body.kappa85 PRE_first_tail_x6_r0_body.s831.ffi PRE_first_tail_x6_r0_body.s830.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift85 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue85, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp85 t ht),
    PRE_first_tail_x6_r0_body.cbridge85,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s831.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s830.ffi) (PRE_first_tail_x6_r0_body.cfoot85 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_85 PRE_first_tail_x6_r0_body.ofx1_85 hobjC PRE_first_tail_x6_r0_body.ff085 PRE_first_tail_x6_r0_body.ff185 PRE_first_tail_x6_r0_body.ffck85,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s831.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s830.ffi) (PRE_first_tail_x6_r0_body.cfoot85 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_85 PRE_first_tail_x6_r0_body.okr1_85 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn85) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf085 PRE_first_tail_x6_r0_body.fkt085 PRE_first_tail_x6_r0_body.fkf185 PRE_first_tail_x6_r0_body.fkt185 PRE_first_tail_x6_r0_body.fkck85,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh085 PRE_first_tail_x6_r0_body.cnh185 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe85) PRE_first_tail_x6_r0_body.cpendR85⟩

end Host.Load.Run.Tpl
end

section -- st85/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st85 0
host_stream_state PRE_first_tail_x6_r0_body.st85 1
host_stream_state PRE_first_tail_x6_r0_body.st85 2
end Host.Load.Run.Tpl
end

section -- Site85
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 85 of chain `PRE_first_tail_x6_r0_body`: `rowBlocks__g85__g86` (`rowBlocks`), the call state `PRE_first_tail_x6_r0_body.s829`, the merged state `PRE_first_tail_x6_r0_body.s830`,
the site template `PRE_first_tail_x6_r0_body.st85` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s831`: the merge.
The footprint's facts are in `SiteF85`, the compaction's in `SiteC85`, `SiteK85`, `SiteNa85`, `SiteNb85`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso85 : PRE_first_tail_x6_r0_body.st85.s0 = { PRE_first_tail_x6_r0_body.s829 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs85 : List Frame := PRE_first_tail_x6_r0_body.s829.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_85 : PRE_first_tail_x6_r0_body.S829.tab.length = 3713
kernel_rfl PRE_first_tail_x6_r0_body.tab0_85 : PRE_first_tail_x6_r0_body.st85.S0.tab = PRE_first_tail_x6_r0_body.S829.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws85 : List Nat := [2442, 2443]
kernel_rfl PRE_first_tail_x6_r0_body.fresh85 : (PRE_first_tail_x6_r0_body.S829.tab.all fun e => PRE_first_tail_x6_r0_body.ws85.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S829.oracle.all fun q => PRE_first_tail_x6_r0_body.ws85.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab85 : PRE_first_tail_x6_r0_body.S830.tab = PRE_first_tail_x6_r0_body.S829.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws85
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen85 : PRE_first_tail_x6_r0_body.st85.S2.tab.length - PRE_first_tail_x6_r0_body.st85.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged85`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap85 : PRE_first_tail_x6_r0_body.s830.heap = PRE_first_tail_x6_r0_body.st85.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext85 : PRE_first_tail_x6_r0_body.s830.next = PRE_first_tail_x6_r0_body.st85.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl85 : PRE_first_tail_x6_r0_body.s830.ctl = PRE_first_tail_x6_r0_body.st85.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack85 : PRE_first_tail_x6_r0_body.s830.stack = PRE_first_tail_x6_r0_body.st85.s2.stack ++ PRE_first_tail_x6_r0_body.s829.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs85 : PRE_first_tail_x6_r0_body.s830.jobs = PRE_first_tail_x6_r0_body.st85.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi85 : PRE_first_tail_x6_r0_body.s830.ffi = PRE_first_tail_x6_r0_body.st85.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace85 : PRE_first_tail_x6_r0_body.s830.trace = PRE_first_tail_x6_r0_body.st85.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores85 : PRE_first_tail_x6_r0_body.s830.stores = PRE_first_tail_x6_r0_body.st85.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD85
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 85 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived85 : PRE_first_tail_x6_r0_body.nr85.map (fun r => nth? PRE_first_tail_x6_r0_body.st85.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo85 : PRE_first_tail_x6_r0_body.nr85.all (Nat.ble 3713) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj85 : PRE_first_tail_x6_r0_body.cws85.all (fun c => !PRE_first_tail_x6_r0_body.ws85.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ85 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws85 PRE_first_tail_x6_r0_body.crs85 PRE_first_tail_x6_r0_body.ws85

end Host.Load.Run.Tpl
end

section -- st85/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st85`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st85.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st85.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st85.s2.heap PRE_first_tail_x6_r0_body.st85.wrR ++ freshOf PRE_first_tail_x6_r0_body.st85.s2.heap PRE_first_tail_x6_r0_body.st85.s0.next PRE_first_tail_x6_r0_body.st85.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st85.wr : List Nat := PRE_first_tail_x6_r0_body.st85.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st85.heapFoot : PRE_first_tail_x6_r0_body.st85.s2.heap = setAll PRE_first_tail_x6_r0_body.st85.s0.heap PRE_first_tail_x6_r0_body.st85.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st85.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st85.s0.next PRE_first_tail_x6_r0_body.st85.s2.next = true
theorem PRE_first_tail_x6_r0_body.st85.grows : PRE_first_tail_x6_r0_body.st85.s0.next ≤ PRE_first_tail_x6_r0_body.st85.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st85.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st85.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st85.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st85.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st85.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st85.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st85.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st85.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st85.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st85.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st85.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st85.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st85.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st85.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st85.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st85.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st85.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st85.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st85.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st85.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st85.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st85.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st85.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st85.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st85.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st85.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st85.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st85.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st85.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st85.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st85.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st85.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF85
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 85 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB85 : nodupT PRE_first_tail_x6_r0_body.st85.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup85 : PRE_first_tail_x6_r0_body.st85.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB85).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB85 : PRE_first_tail_x6_r0_body.st85.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound85 : ∀ b ∈ PRE_first_tail_x6_r0_body.st85.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB85 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr85 := PRE_first_tail_x6_r0_body.st85.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq85 : PRE_first_tail_x6_r0_body.st85.s2.trace = PRE_first_tail_x6_r0_body.trFr85 ++ PRE_first_tail_x6_r0_body.st85.s0.trace
theorem PRE_first_tail_x6_r0_body.trace85 : ∃ fr, PRE_first_tail_x6_r0_body.st85.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st85.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq85⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide85 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB85 : (PRE_first_tail_x6_r0_body.wide85.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st85.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix85 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide85, WFix Map.id (Present PRE_first_tail_x6_r0_body.st85.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB85 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL85
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 85 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s830`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO85 : PRE_first_tail_x6_r0_body.st85.S0.oracle = PRE_first_tail_x6_r0_body.st85.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B85 : PRE_first_tail_x6_r0_body.st85.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st85.s0.next || (PRE_first_tail_x6_r0_body.st85.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot85 : Conv.StageFoot PRE_first_tail_x6_r0_body.st85.wr PRE_first_tail_x6_r0_body.st85.s0 PRE_first_tail_x6_r0_body.st85.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st85.heapFoot PRE_first_tail_x6_r0_body.wrNodup85 PRE_first_tail_x6_r0_body.wrBound85 PRE_first_tail_x6_r0_body.wr0B85 PRE_first_tail_x6_r0_body.st85.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged85 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st85.F.S → PRE_first_tail_x6_r0_body.st85.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st85.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st85.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs85 PRE_first_tail_x6_r0_body.st85.wr PRE_first_tail_x6_r0_body.s829 PRE_first_tail_x6_r0_body.st85.s2 PRE_first_tail_x6_r0_body.st85.s0
      PRE_first_tail_x6_r0_body.st85.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st85.F FR W stk M ν K PRE_first_tail_x6_r0_body.s830 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso85 PRE_first_tail_x6_r0_body.stFoot85 PRE_first_tail_x6_r0_body.wrNodup85 PRE_first_tail_x6_r0_body.wrBound85 PRE_first_tail_x6_r0_body.trace85 PRE_first_tail_x6_r0_body.mheap85
    PRE_first_tail_x6_r0_body.mnext85 PRE_first_tail_x6_r0_body.mctl85 PRE_first_tail_x6_r0_body.mstack85 PRE_first_tail_x6_r0_body.mjobs85 PRE_first_tail_x6_r0_body.mffi85 PRE_first_tail_x6_r0_body.mtrace85 PRE_first_tail_x6_r0_body.mstores85 h

def PRE_first_tail_x6_r0_body.arrEl85_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE85_2665 : arrOf PRE_first_tail_x6_r0_body.s830 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl85_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA85_2665 : isArrB PRE_first_tail_x6_r0_body.s830 2665 = true
theorem PRE_first_tail_x6_r0_body.arr85_2665 : ∃ o, PRE_first_tail_x6_r0_body.s830.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl85_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE85_2665 PRE_first_tail_x6_r0_body.arrA85_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN85_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl85_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR85_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl85_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN85_2665

def PRE_first_tail_x6_r0_body.arrEl85_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE85_2673467 : arrOf PRE_first_tail_x6_r0_body.s830 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl85_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA85_2673467 : isArrB PRE_first_tail_x6_r0_body.s830 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr85_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s830.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl85_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE85_2673467 PRE_first_tail_x6_r0_body.arrA85_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN85_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl85_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR85_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl85_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN85_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k85 : isArrB PRE_first_tail_x6_r0_body.s830 4910 = false
theorem PRE_first_tail_x6_r0_body.keep85 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s830 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k85 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr85_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl85_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ85
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 85 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s829`, the merged
state `PRE_first_tail_x6_r0_body.s830`, the canonical state `PRE_first_tail_x6_r0_body.s831`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl85 : PRE_first_tail_x6_r0_body.pl85.all (Nat.ble PRE_first_tail_x6_r0_body.s829.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd85 : nodupT PRE_first_tail_x6_r0_body.pl85 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn185 : Nat.ble PRE_first_tail_x6_r0_body.s829.next 2741869 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst85 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s829.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn85 : PRE_first_tail_x6_r0_body.s831.next = PRE_first_tail_x6_r0_body.s829.next + PRE_first_tail_x6_r0_body.pl85.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn85 : PRE_first_tail_x6_r0_body.s830.next = 2741869
kernel_rfl PRE_first_tail_x6_r0_body.zgrow85 : Nat.ble PRE_first_tail_x6_r0_body.s831.next PRE_first_tail_x6_r0_body.s830.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh85 : PRE_first_tail_x6_r0_body.S829.tab.all (fun e => PRE_first_tail_x6_r0_body.cws85.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd85 : nodupT PRE_first_tail_x6_r0_body.cws85 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi85 : PRE_first_tail_x6_r0_body.nr85.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S830.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt85 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s829.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg85_2665 : PRE_first_tail_x6_r0_body.s831.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s831 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk85_2665 : (objOf PRE_first_tail_x6_r0_body.s831 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm85_2665 : PRE_first_tail_x6_r0_body.s830.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa85.obj (objOf PRE_first_tail_x6_r0_body.s831 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s830 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg85_2673467 : PRE_first_tail_x6_r0_body.s831.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s831 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk85_2673467 : (objOf PRE_first_tail_x6_r0_body.s831 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm85_2673467 : PRE_first_tail_x6_r0_body.s830.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa85.obj (objOf PRE_first_tail_x6_r0_body.s831 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s830 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw85_4910 : (PRE_first_tail_x6_r0_body.s831.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw85_2673472 : (PRE_first_tail_x6_r0_body.s831.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw85_2673473 : (PRE_first_tail_x6_r0_body.s831.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd85 : PRE_first_tail_x6_r0_body.cl85.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr85 : PRE_first_tail_x6_r0_body.st85.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s829.next || PRE_first_tail_x6_r0_body.cl85.contains b) = true
def PRE_first_tail_x6_r0_body.zl85 : List Nat := PRE_first_tail_x6_r0_body.cl85.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE85 : PRE_first_tail_x6_r0_body.zl85.map (fun a => PRE_first_tail_x6_r0_body.s830.heap.get (PRE_first_tail_x6_r0_body.kappa85.a a)) = PRE_first_tail_x6_r0_body.zl85.map (fun a => (PRE_first_tail_x6_r0_body.s831.heap.get a).map PRE_first_tail_x6_r0_body.kappa85.hobj)
theorem PRE_first_tail_x6_r0_body.zimg85 : HeapImg PRE_first_tail_x6_r0_body.kappa85 PRE_first_tail_x6_r0_body.s831 PRE_first_tail_x6_r0_body.s830 PRE_first_tail_x6_r0_body.zl85 := PRE_first_tail_x6_r0_body.zimgE85
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl85 : PRE_first_tail_x6_r0_body.s830.ctl = PRE_first_tail_x6_r0_body.kappa85.ctl PRE_first_tail_x6_r0_body.s831.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack85 : PRE_first_tail_x6_r0_body.s830.stack = PRE_first_tail_x6_r0_body.s831.stack.map PRE_first_tail_x6_r0_body.kappa85.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs85 : PRE_first_tail_x6_r0_body.s830.jobs = PRE_first_tail_x6_r0_body.s831.jobs.map PRE_first_tail_x6_r0_body.kappa85.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores85 : PRE_first_tail_x6_r0_body.s830.stores = PRE_first_tail_x6_r0_body.kappa85.stores PRE_first_tail_x6_r0_body.s831.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots85 : checkRootsSupp PRE_first_tail_x6_r0_body.s831 3713 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC85 : PRE_first_tail_x6_r0_body.S829.tab.length + PRE_first_tail_x6_r0_body.cws85.length = 3713
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap85 : PRE_first_tail_x6_r0_body.kappa85 = Conv.Map.compact PRE_first_tail_x6_r0_body.s829.next 2741869 PRE_first_tail_x6_r0_body.S829.tab.length PRE_first_tail_x6_r0_body.pl85 (PRE_first_tail_x6_r0_body.nr85.map NumV.ref) PRE_first_tail_x6_r0_body.kd85.big
  PRE_first_tail_x6_r0_body.kd85.region PRE_first_tail_x6_r0_body.kd85.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin85 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s831.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc85 : Conv.jcleanListB (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s831 PRE_first_tail_x6_r0_body.cl85 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB85 : noBigRootsP (fun i => !Conv.oldBigB (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s831.trace PRE_first_tail_x6_r0_body.s831 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm85 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 16977 = true
theorem PRE_first_tail_x6_r0_body.cjcl85 (h : Conv.JClean (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s829) : Conv.JClean (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s831 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle85)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap85 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd85 a ha)) PRE_first_tail_x6_r0_body.zjc85

end Host.Load.Run.Tpl
end

section -- st85/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st85.bodyLast from PRE_first_tail_x6_r0_body.st85.s1 to PRE_first_tail_x6_r0_body.st85.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st85.F PRE_first_tail_x6_r0_body.st85.s1).run PRE_first_tail_x6_r0_body.st85.S1 = some (PRE_first_tail_x6_r0_body.st85.s2, PRE_first_tail_x6_r0_body.st85.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st85.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st85.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st85.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st85.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st85/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st85.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st85.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st85.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st85.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st85.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st85.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st85.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st85.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st85.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st85.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st85.s0 PRE_first_tail_x6_r0_body.st85.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st85.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st85.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st85.s1 PRE_first_tail_x6_r0_body.st85.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st85/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st85.bodyK0F from PRE_first_tail_x6_r0_body.st85.s0 to PRE_first_tail_x6_r0_body.st85.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st85.F (PRE_first_tail_x6_r0_body.st85.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st85.ks 0).getD 0) PRE_first_tail_x6_r0_body.st85.s0 PRE_first_tail_x6_r0_body.st85.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st85.s1, PRE_first_tail_x6_r0_body.st85.S1)
theorem PRE_first_tail_x6_r0_body.st85.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st85.F (PRE_first_tail_x6_r0_body.st85.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st85.ks 0).getD 0) PRE_first_tail_x6_r0_body.st85.s0 PRE_first_tail_x6_r0_body.st85.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st85.s1, PRE_first_tail_x6_r0_body.st85.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st85.bodyOkLN_ok PRE_first_tail_x6_r0_body.st85.bodyK0F
end Host.Load.Run.Tpl
end

section -- st85/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st85.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st85.F (PRE_first_tail_x6_r0_body.st85.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st85.s0 PRE_first_tail_x6_r0_body.st85.S0 = some (PRE_first_tail_x6_r0_body.st85.s1, PRE_first_tail_x6_r0_body.st85.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st85.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st85.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st85.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st85.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st85.F (PRE_first_tail_x6_r0_body.st85.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st85.s0
  S0 := PRE_first_tail_x6_r0_body.st85.S0
  s1 := PRE_first_tail_x6_r0_body.st85.s1
  S1 := PRE_first_tail_x6_r0_body.st85.S1
  s2 := PRE_first_tail_x6_r0_body.st85.s2
  S2 := PRE_first_tail_x6_r0_body.st85.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st85.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st85.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st85.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st85.bodyHalt
  last := PRE_first_tail_x6_r0_body.st85.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st85.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC86
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 86 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s835` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa86` into the merged state
`PRE_first_tail_x6_r0_body.s834`. -/

def PRE_first_tail_x6_r0_body.pl86 : List Nat := [2742165]
def PRE_first_tail_x6_r0_body.nr86 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd86 : RData :=
  ⟨2742156, 2742166, Stage.setAll PTrie.nil [(2742155, 2742165)], Stage.setAll PTrie.nil [],
   19891, 19891, 16981, 16981, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa86 : Map :=
  Conv.Map.compact 2742155 2742166 3730 PRE_first_tail_x6_r0_body.pl86 (PRE_first_tail_x6_r0_body.nr86.map NumV.ref) PRE_first_tail_x6_r0_body.kd86.big
    PRE_first_tail_x6_r0_body.kd86.region PRE_first_tail_x6_r0_body.kd86.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws86 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs86 : List SymE := PRE_first_tail_x6_r0_body.nr86.map fun r => (nth? PRE_first_tail_x6_r0_body.S834.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta86 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws86 PRE_first_tail_x6_r0_body.crs86
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB86 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab86 : PRE_first_tail_x6_r0_body.S835.tab = PRE_first_tail_x6_r0_body.S833.tab ++ PRE_first_tail_x6_r0_body.cws86.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace86 : PRE_first_tail_x6_r0_body.s835.trace = PRE_first_tail_x6_r0_body.s833.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext86 : PRE_first_tail_x6_r0_body.s835.next = 2742156
kernel_rfl PRE_first_tail_x6_r0_body.ccounters86 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s835.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s835.ffi).mlx.nnext) = (19891, 16981)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue86 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s834.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s835.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa86.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp86 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s835.ffi).mlx.tokens.all (bSN 3730) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean86 : Conv.cleanListB 19891 131072 (fun r => Nat.ble 79564 r) PRE_first_tail_x6_r0_body.s835
    (PRE_first_tail_x6_r0_body.wrB86 ++ (List.range 1).map (2742155 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs86 : bigsOutB 19891 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s835.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK86
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl86`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl86 : List Nat := [2665, 2673467, 2742155]
def PRE_first_tail_x6_r0_body.clo86 : List Nat := []
def PRE_first_tail_x6_r0_body.cln86 : List Nat := []
def PRE_first_tail_x6_r0_body.cli86 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap86 : PRE_first_tail_x6_r0_body.s835.heap = Stage.setAll PRE_first_tail_x6_r0_body.s833.heap (PRE_first_tail_x6_r0_body.cl86.filterMap fun a => (PRE_first_tail_x6_r0_body.s835.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe86 : Nat.ble PRE_first_tail_x6_r0_body.s833.next PRE_first_tail_x6_r0_body.s835.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP86 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s833 PRE_first_tail_x6_r0_body.s835 PRE_first_tail_x6_r0_body.cl86 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp86 : Conv.suppListB PRE_first_tail_x6_r0_body.s835 3730 PRE_first_tail_x6_r0_body.cl86 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound86 : Conv.boundListB PRE_first_tail_x6_r0_body.s835 PRE_first_tail_x6_r0_body.cl86 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK86 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s835.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln86.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s835.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK86 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s835.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo86.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s835.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK86 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s835.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli86.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s835.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst86 : Conv.sstListB 3730 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s835.ffi).mlx PRE_first_tail_x6_r0_body.cln86 PRE_first_tail_x6_r0_body.clo86 PRE_first_tail_x6_r0_body.cli86 = true

end Host.Load.Run.Tpl
end

section -- SiteCl86
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA86 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s835.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo86.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s835.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd86 : (PRE_first_tail_x6_r0_body.clo86 ++ PRE_first_tail_x6_r0_body.cln86 ++ PRE_first_tail_x6_r0_body.cli86).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle86 : Conv.Cnt.leB (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt) (⟨19891, 16981, 2742156, 3730⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck86 : Conv.ncleanListB (⟨19891, 16981, 2742156, 3730⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s835.ffi).mlx PRE_first_tail_x6_r0_body.clo86 PRE_first_tail_x6_r0_body.cln86 PRE_first_tail_x6_r0_body.cli86 = true
theorem PRE_first_tail_x6_r0_body.cncl86 (h : Conv.NClean (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx) : Conv.NClean (⟨19891, 16981, 2742156, 3730⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s835.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle86 PRE_first_tail_x6_r0_body.ckA86 PRE_first_tail_x6_r0_body.cobjsK86 PRE_first_tail_x6_r0_body.cnodesK86 PRE_first_tail_x6_r0_body.citemsK86 PRE_first_tail_x6_r0_body.cbd86 PRE_first_tail_x6_r0_body.cck86

end Host.Load.Run.Tpl
end

section -- SiteS86
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 86 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc86 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P86 : LoadP := PRE_first_tail_x6_r0_body.Pc86.raise 16981
kernel_rfl PRE_first_tail_x6_r0_body.craise86 : Nat.ble PRE_first_tail_x6_r0_body.Pc86.N0 16981 = true
theorem PRE_first_tail_x6_r0_body.raised86 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc86 PRE_first_tail_x6_r0_body.P86 :=
  .inr ⟨16981, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise86, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_86 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s835.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_86 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s834.ffi)
def PRE_first_tail_x6_r0_body.khinv86 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv86 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS86 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS86 : List Nat := List.range' 16981 0
def PRE_first_tail_x6_r0_body.ciS86 : List Nat := [] ++ List.range' 16981 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh086 : PRE_first_tail_x6_r0_body.kd86.nh0 = PRE_first_tail_x6_r0_body.cx0_86.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh186 : PRE_first_tail_x6_r0_body.kd86.nh1 = PRE_first_tail_x6_r0_body.cx1_86.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn086 : PRE_first_tail_x6_r0_body.kd86.nn0 = PRE_first_tail_x6_r0_body.cx0_86.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn186 : PRE_first_tail_x6_r0_body.kd86.nn1 = PRE_first_tail_x6_r0_body.cx1_86.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo86 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P86.lo && Nat.ble PRE_first_tail_x6_r0_body.P86.lo PRE_first_tail_x6_r0_body.cx0_86.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P86.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P86.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt86 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_86.mlx.next PRE_first_tail_x6_r0_body.cx1_86.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_86.mlx.nnext PRE_first_tail_x6_r0_body.cx1_86.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband86 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P86.NL && Nat.ble PRE_first_tail_x6_r0_body.P86.NL PRE_first_tail_x6_r0_body.P86.N0 && Nat.ble PRE_first_tail_x6_r0_body.P86.N0 PRE_first_tail_x6_r0_body.cx0_86.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow86 : PRE_first_tail_x6_r0_body.kd86.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren86 : checkRenG PRE_first_tail_x6_r0_body.kd86.hnd PRE_first_tail_x6_r0_body.khinv86 (phB PRE_first_tail_x6_r0_body.cx0_86.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband86 : PRE_first_tail_x6_r0_body.kd86.checkBand PRE_first_tail_x6_r0_body.P86.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos86 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd86.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren86 : checkRenG PRE_first_tail_x6_r0_body.kd86.node PRE_first_tail_x6_r0_body.kninv86 (pnB PRE_first_tail_x6_r0_body.cx0_86.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow86 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd86.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P86.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd86.nodeF j) PRE_first_tail_x6_r0_body.cx1_86.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a86 : PRE_first_tail_x6_r0_body.cx0_86.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b86 : PRE_first_tail_x6_r0_body.cx0_86.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok186 : PRE_first_tail_x6_r0_body.cx1_86.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend86 : PRE_first_tail_x6_r0_body.cx1_86.mlx.pending = PRE_first_tail_x6_r0_body.cx0_86.mlx.pending.map PRE_first_tail_x6_r0_body.kappa86.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh86 : PRE_first_tail_x6_r0_body.cx1_86.mlx.errh = PRE_first_tail_x6_r0_body.cx0_86.mlx.errh.map PRE_first_tail_x6_r0_body.kappa86.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles86 : PRE_first_tail_x6_r0_body.cx1_86.mlx.files = PRE_first_tail_x6_r0_body.cx0_86.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch86 : PRE_first_tail_x6_r0_body.cx1_86.mlx.arch = PRE_first_tail_x6_r0_body.cx0_86.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes86 : PRE_first_tail_x6_r0_body.cx1_86.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_86.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired86 : PRE_first_tail_x6_r0_body.cx1_86.mlx.wired = PRE_first_tail_x6_r0_body.cx0_86.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost86 : PRE_first_tail_x6_r0_body.cx1_86.host = PRE_first_tail_x6_r0_body.cx0_86.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd86`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn086 : PRE_first_tail_x6_r0_body.kd86.n0 = 2742156
kernel_rfl PRE_first_tail_x6_r0_body.ckn186 : PRE_first_tail_x6_r0_body.kd86.n1 = 2742166
kernel_rfl PRE_first_tail_x6_r0_body.ckheap86 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd86.heap).all (fun x => Nat.ble 2742155 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl86 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd86.heap.get (2742155 + j) = nth? PRE_first_tail_x6_r0_body.pl86 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja86 : Nat.ble 2742155 2742155 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn86 : Nat.ble 3730 3730 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD86 : Nat.ble 2742155 PRE_first_tail_x6_r0_body.kd86.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn86 : Nat.ble 19891 PRE_first_tail_x6_r0_body.kd86.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn86 : Nat.ble 16981 PRE_first_tail_x6_r0_body.kd86.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb86 : Nat.ble 19891 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap86 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd86.heap).all (Nat.ble (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd86 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd86.hnd).all (Nat.ble (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode86 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd86.node).all (Nat.ble (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix86 : Conv.FixOld (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa86 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja86) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn86) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD86) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn86) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn86) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb86) PRE_first_tail_x6_r0_body.fheap86 PRE_first_tail_x6_r0_body.fhnd86 PRE_first_tail_x6_r0_body.fnode86
kernel_rfl PRE_first_tail_x6_r0_body.fcxn86 : (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn86 : (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle086 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_86.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_86.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk86 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd86.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A86 : PRE_first_tail_x6_r0_body.cx1_86.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS86.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_86.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O86 : PRE_first_tail_x6_r0_body.cx1_86.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS86.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_86.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N86 : PRE_first_tail_x6_r0_body.cx1_86.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS86.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_86.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I86 : PRE_first_tail_x6_r0_body.cx1_86.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS86.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_86.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd86 : (PRE_first_tail_x6_r0_body.clo86 ++ PRE_first_tail_x6_r0_body.cln86 ++ PRE_first_tail_x6_r0_body.cli86 ++ PRE_first_tail_x6_r0_body.cwS86 ++ PRE_first_tail_x6_r0_body.cnS86 ++ PRE_first_tail_x6_r0_body.ciS86).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW86 : PRE_first_tail_x6_r0_body.cwS86.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo86.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI86 : PRE_first_tail_x6_r0_body.ciS86.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli86.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN86 : PRE_first_tail_x6_r0_body.cnS86.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF86 : PRE_first_tail_x6_r0_body.cln86.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh86 : PRE_first_tail_x6_r0_body.clo86.all (handleOK PRE_first_tail_x6_r0_body.kappa86 PRE_first_tail_x6_r0_body.P86.lo PRE_first_tail_x6_r0_body.cx0_86.mlx PRE_first_tail_x6_r0_body.cx1_86.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo86 : PRE_first_tail_x6_r0_body.clo86.map (fun h => PRE_first_tail_x6_r0_body.cx1_86.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa86.handle h)) = PRE_first_tail_x6_r0_body.clo86.map (fun h => (PRE_first_tail_x6_r0_body.cx0_86.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa86.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok86 : PRE_first_tail_x6_r0_body.clo86.all (objOK PRE_first_tail_x6_r0_body.kappa86 PRE_first_tail_x6_r0_body.P86.NL PRE_first_tail_x6_r0_body.cx0_86.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd86 : PRE_first_tail_x6_r0_body.cln86.all (nodeOKF PRE_first_tail_x6_r0_body.kappa86 PRE_first_tail_x6_r0_body.P86 PRE_first_tail_x6_r0_body.cx0_86.mlx PRE_first_tail_x6_r0_body.cx1_86.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp86 : ((PRE_first_tail_x6_r0_body.cln86.filter (fullB PRE_first_tail_x6_r0_body.P86))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_86.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa86.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln86.filter (fullB PRE_first_tail_x6_r0_body.P86))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_86.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa86.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI86 : incrB PRE_first_tail_x6_r0_body.kd86.nodeF (List.range' 16981 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK86 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd86.node).all (fun k => Nat.ble 16981 k && Nat.blt k 16981) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL86 : (PRE_first_tail_x6_r0_body.cln86.filter (Nat.ble PRE_first_tail_x6_r0_body.P86.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd86.nodeF i) && (Nat.blt i 16981 || Nat.ble PRE_first_tail_x6_r0_body.kd86.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord86 : (PRE_first_tail_x6_r0_body.cln86.filter (Nat.ble PRE_first_tail_x6_r0_body.P86.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd86.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd86.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd86.nodeF j) (PRE_first_tail_x6_r0_body.kd86.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow86 PRE_first_tail_x6_r0_body.cnn186 PRE_first_tail_x6_r0_body.fnordI86 PRE_first_tail_x6_r0_body.fnordK86 PRE_first_tail_x6_r0_body.fnordL86
kernel_rfl PRE_first_tail_x6_r0_body.fi86 : PRE_first_tail_x6_r0_body.cli86.all (pnB PRE_first_tail_x6_r0_body.cx0_86.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii86 : PRE_first_tail_x6_r0_body.cli86.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_86.mlx.items.get (PRE_first_tail_x6_r0_body.kappa86.node k) = (PRE_first_tail_x6_r0_body.cx0_86.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa86.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot86 (clean : Conv.NClean (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P86.NL) (cl : SSt (· < 3730) PRE_first_tail_x6_r0_body.cx0_86.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P86 3730 PRE_first_tail_x6_r0_body.kappa86 PRE_first_tail_x6_r0_body.kd86 PRE_first_tail_x6_r0_body.khinv86 PRE_first_tail_x6_r0_body.kninv86 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx PRE_first_tail_x6_r0_body.cx0_86.mlx PRE_first_tail_x6_r0_body.cx1_86.mlx (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo86 PRE_first_tail_x6_r0_body.cln86 PRE_first_tail_x6_r0_body.cli86 PRE_first_tail_x6_r0_body.cwS86 PRE_first_tail_x6_r0_body.cnS86 PRE_first_tail_x6_r0_body.ciS86 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh086, PRE_first_tail_x6_r0_body.cnh186, PRE_first_tail_x6_r0_body.cnn086, PRE_first_tail_x6_r0_body.cnn186, PRE_first_tail_x6_r0_body.cplo86, PRE_first_tail_x6_r0_body.ccnt86, PRE_first_tail_x6_r0_body.cnband86, PRE_first_tail_x6_r0_body.chbelow86, PRE_first_tail_x6_r0_body.chren86, PRE_first_tail_x6_r0_body.cband86, PRE_first_tail_x6_r0_body.cnh1pos86, PRE_first_tail_x6_r0_body.cnren86, PRE_first_tail_x6_r0_body.cnlow86, PRE_first_tail_x6_r0_body.cabs0a86, PRE_first_tail_x6_r0_body.cabs0b86, PRE_first_tail_x6_r0_body.ctok186, PRE_first_tail_x6_r0_body.cpend86, PRE_first_tail_x6_r0_body.cerrh86, PRE_first_tail_x6_r0_body.cfiles86, PRE_first_tail_x6_r0_body.carch86, PRE_first_tail_x6_r0_body.csizes86, PRE_first_tail_x6_r0_body.cwired86, PRE_first_tail_x6_r0_body.cfix86, clean, PRE_first_tail_x6_r0_body.fcxn86, PRE_first_tail_x6_r0_body.fcnn86, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle086, PRE_first_tail_x6_r0_body.fnk86, PRE_first_tail_x6_r0_body.ckA86, PRE_first_tail_x6_r0_body.cobjsK86, PRE_first_tail_x6_r0_body.cnodesK86, PRE_first_tail_x6_r0_body.citemsK86, PRE_first_tail_x6_r0_body.f1A86, PRE_first_tail_x6_r0_body.f1O86, PRE_first_tail_x6_r0_body.f1N86, PRE_first_tail_x6_r0_body.f1I86, PRE_first_tail_x6_r0_body.fbd86, PRE_first_tail_x6_r0_body.fincW86, PRE_first_tail_x6_r0_body.fincI86, PRE_first_tail_x6_r0_body.fincN86, PRE_first_tail_x6_r0_body.flnF86, PRE_first_tail_x6_r0_body.fh86, PRE_first_tail_x6_r0_body.fo86, PRE_first_tail_x6_r0_body.fok86, PRE_first_tail_x6_r0_body.fnd86, PRE_first_tail_x6_r0_body.fp86, PRE_first_tail_x6_r0_body.fnord86, PRE_first_tail_x6_r0_body.fi86, PRE_first_tail_x6_r0_body.fii86⟩
theorem PRE_first_tail_x6_r0_body.cnshift86 (clean : Conv.NClean (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P86.NL) (cl : SSt (· < 3730) PRE_first_tail_x6_r0_body.cx0_86.mlx) : NShift PRE_first_tail_x6_r0_body.P86 3730 PRE_first_tail_x6_r0_body.kappa86 PRE_first_tail_x6_r0_body.cx0_86 PRE_first_tail_x6_r0_body.cx1_86 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot86 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost86 (compact_a_eq PRE_first_tail_x6_r0_body.ckn086 PRE_first_tail_x6_r0_body.ckn186 PRE_first_tail_x6_r0_body.ckheap86 PRE_first_tail_x6_r0_body.ckpl86)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_86 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s833.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_86 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s833.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_86 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s833.ffi) = some PRE_first_tail_x6_r0_body.fxC_86
kernel_rfl PRE_first_tail_x6_r0_body.okrC_86 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s833.ffi) = some PRE_first_tail_x6_r0_body.krC_86
noncomputable def PRE_first_tail_x6_r0_body.fx0_86 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s835.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_86 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s835.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_86 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s835.ffi) = some PRE_first_tail_x6_r0_body.fx0_86
kernel_rfl PRE_first_tail_x6_r0_body.okr0_86 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s835.ffi) = some PRE_first_tail_x6_r0_body.kr0_86
noncomputable def PRE_first_tail_x6_r0_body.fx1_86 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s834.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_86 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s834.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_86 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s834.ffi) = some PRE_first_tail_x6_r0_body.fx1_86
kernel_rfl PRE_first_tail_x6_r0_body.okr1_86 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s834.ffi) = some PRE_first_tail_x6_r0_body.kr1_86
kernel_rfl PRE_first_tail_x6_r0_body.ff086 : PRE_first_tail_x6_r0_body.fx0_86 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_86 (PRE_first_tail_x6_r0_body.clo86.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_86.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff186 : PRE_first_tail_x6_r0_body.fx1_86 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_86 (PRE_first_tail_x6_r0_body.cwS86.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_86.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck86 : freedLB PRE_first_tail_x6_r0_body.kappa86 PRE_first_tail_x6_r0_body.cx0_86.mlx PRE_first_tail_x6_r0_body.fx0_86 PRE_first_tail_x6_r0_body.fx1_86 PRE_first_tail_x6_r0_body.clo86 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf086 : PRE_first_tail_x6_r0_body.kr0_86.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_86.flags (PRE_first_tail_x6_r0_body.clo86.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_86.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt086 : PRE_first_tail_x6_r0_body.kr0_86.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_86.targs (PRE_first_tail_x6_r0_body.clo86.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_86.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf186 : PRE_first_tail_x6_r0_body.kr1_86.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_86.flags (PRE_first_tail_x6_r0_body.cwS86.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_86.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt186 : PRE_first_tail_x6_r0_body.kr1_86.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_86.targs (PRE_first_tail_x6_r0_body.cwS86.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_86.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck86 : krecLB PRE_first_tail_x6_r0_body.kappa86 3730 PRE_first_tail_x6_r0_body.cx0_86.mlx PRE_first_tail_x6_r0_body.kr0_86 PRE_first_tail_x6_r0_body.kr1_86 PRE_first_tail_x6_r0_body.clo86 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn86 : Nat.ble 3730 3730 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge86 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s834.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s835.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR86 : pendRegB PRE_first_tail_x6_r0_body.kappa86 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s835.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe86 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s835.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s834.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift86 (clean : Conv.NClean (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P86.NL) (cl : SSt (· < 3730) PRE_first_tail_x6_r0_body.cx0_86.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_86.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_86.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_86.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s833.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_86.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P86 3730 PRE_first_tail_x6_r0_body.kappa86 PRE_first_tail_x6_r0_body.s835.ffi PRE_first_tail_x6_r0_body.s834.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift86 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue86, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp86 t ht),
    PRE_first_tail_x6_r0_body.cbridge86,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s835.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s834.ffi) (PRE_first_tail_x6_r0_body.cfoot86 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_86 PRE_first_tail_x6_r0_body.ofx1_86 hobjC PRE_first_tail_x6_r0_body.ff086 PRE_first_tail_x6_r0_body.ff186 PRE_first_tail_x6_r0_body.ffck86,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s835.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s834.ffi) (PRE_first_tail_x6_r0_body.cfoot86 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_86 PRE_first_tail_x6_r0_body.okr1_86 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn86) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf086 PRE_first_tail_x6_r0_body.fkt086 PRE_first_tail_x6_r0_body.fkf186 PRE_first_tail_x6_r0_body.fkt186 PRE_first_tail_x6_r0_body.fkck86,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh086 PRE_first_tail_x6_r0_body.cnh186 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe86) PRE_first_tail_x6_r0_body.cpendR86⟩

end Host.Load.Run.Tpl
end

section -- st86/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st86 0
host_stream_state PRE_first_tail_x6_r0_body.st86 1
host_stream_state PRE_first_tail_x6_r0_body.st86 2
end Host.Load.Run.Tpl
end

section -- Site86
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 86 of chain `PRE_first_tail_x6_r0_body`: `plan__g86__g87` (`plan`), the call state `PRE_first_tail_x6_r0_body.s833`, the merged state `PRE_first_tail_x6_r0_body.s834`,
the site template `PRE_first_tail_x6_r0_body.st86` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s835`: the merge.
The footprint's facts are in `SiteF86`, the compaction's in `SiteC86`, `SiteK86`, `SiteNa86`, `SiteNb86`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso86 : PRE_first_tail_x6_r0_body.st86.s0 = { PRE_first_tail_x6_r0_body.s833 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs86 : List Frame := PRE_first_tail_x6_r0_body.s833.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_86 : PRE_first_tail_x6_r0_body.S833.tab.length = 3730
kernel_rfl PRE_first_tail_x6_r0_body.tab0_86 : PRE_first_tail_x6_r0_body.st86.S0.tab = PRE_first_tail_x6_r0_body.S833.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws86 : List Nat := [2444, 2445, 2446]
kernel_rfl PRE_first_tail_x6_r0_body.fresh86 : (PRE_first_tail_x6_r0_body.S833.tab.all fun e => PRE_first_tail_x6_r0_body.ws86.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S833.oracle.all fun q => PRE_first_tail_x6_r0_body.ws86.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab86 : PRE_first_tail_x6_r0_body.S834.tab = PRE_first_tail_x6_r0_body.S833.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws86
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen86 : PRE_first_tail_x6_r0_body.st86.S2.tab.length - PRE_first_tail_x6_r0_body.st86.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged86`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap86 : PRE_first_tail_x6_r0_body.s834.heap = PRE_first_tail_x6_r0_body.st86.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext86 : PRE_first_tail_x6_r0_body.s834.next = PRE_first_tail_x6_r0_body.st86.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl86 : PRE_first_tail_x6_r0_body.s834.ctl = PRE_first_tail_x6_r0_body.st86.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack86 : PRE_first_tail_x6_r0_body.s834.stack = PRE_first_tail_x6_r0_body.st86.s2.stack ++ PRE_first_tail_x6_r0_body.s833.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs86 : PRE_first_tail_x6_r0_body.s834.jobs = PRE_first_tail_x6_r0_body.st86.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi86 : PRE_first_tail_x6_r0_body.s834.ffi = PRE_first_tail_x6_r0_body.st86.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace86 : PRE_first_tail_x6_r0_body.s834.trace = PRE_first_tail_x6_r0_body.st86.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores86 : PRE_first_tail_x6_r0_body.s834.stores = PRE_first_tail_x6_r0_body.st86.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD86
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 86 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived86 : PRE_first_tail_x6_r0_body.nr86.map (fun r => nth? PRE_first_tail_x6_r0_body.st86.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo86 : PRE_first_tail_x6_r0_body.nr86.all (Nat.ble 3730) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj86 : PRE_first_tail_x6_r0_body.cws86.all (fun c => !PRE_first_tail_x6_r0_body.ws86.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ86 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws86 PRE_first_tail_x6_r0_body.crs86 PRE_first_tail_x6_r0_body.ws86

end Host.Load.Run.Tpl
end

section -- st86/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st86`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st86.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st86.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st86.s2.heap PRE_first_tail_x6_r0_body.st86.wrR ++ freshOf PRE_first_tail_x6_r0_body.st86.s2.heap PRE_first_tail_x6_r0_body.st86.s0.next PRE_first_tail_x6_r0_body.st86.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st86.wr : List Nat := PRE_first_tail_x6_r0_body.st86.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st86.heapFoot : PRE_first_tail_x6_r0_body.st86.s2.heap = setAll PRE_first_tail_x6_r0_body.st86.s0.heap PRE_first_tail_x6_r0_body.st86.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st86.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st86.s0.next PRE_first_tail_x6_r0_body.st86.s2.next = true
theorem PRE_first_tail_x6_r0_body.st86.grows : PRE_first_tail_x6_r0_body.st86.s0.next ≤ PRE_first_tail_x6_r0_body.st86.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st86.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st86.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st86.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st86.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st86.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st86.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st86.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st86.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st86.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st86.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st86.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st86.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st86.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st86.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st86.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st86.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st86.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st86.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st86.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st86.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st86.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st86.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st86.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st86.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st86.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st86.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st86.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st86.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st86.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st86.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st86.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st86.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF86
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 86 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB86 : nodupT PRE_first_tail_x6_r0_body.st86.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup86 : PRE_first_tail_x6_r0_body.st86.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB86).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB86 : PRE_first_tail_x6_r0_body.st86.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound86 : ∀ b ∈ PRE_first_tail_x6_r0_body.st86.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB86 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr86 := PRE_first_tail_x6_r0_body.st86.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq86 : PRE_first_tail_x6_r0_body.st86.s2.trace = PRE_first_tail_x6_r0_body.trFr86 ++ PRE_first_tail_x6_r0_body.st86.s0.trace
theorem PRE_first_tail_x6_r0_body.trace86 : ∃ fr, PRE_first_tail_x6_r0_body.st86.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st86.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq86⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide86 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB86 : (PRE_first_tail_x6_r0_body.wide86.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st86.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix86 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide86, WFix Map.id (Present PRE_first_tail_x6_r0_body.st86.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB86 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL86
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 86 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s834`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO86 : PRE_first_tail_x6_r0_body.st86.S0.oracle = PRE_first_tail_x6_r0_body.st86.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B86 : PRE_first_tail_x6_r0_body.st86.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st86.s0.next || (PRE_first_tail_x6_r0_body.st86.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot86 : Conv.StageFoot PRE_first_tail_x6_r0_body.st86.wr PRE_first_tail_x6_r0_body.st86.s0 PRE_first_tail_x6_r0_body.st86.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st86.heapFoot PRE_first_tail_x6_r0_body.wrNodup86 PRE_first_tail_x6_r0_body.wrBound86 PRE_first_tail_x6_r0_body.wr0B86 PRE_first_tail_x6_r0_body.st86.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged86 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st86.F.S → PRE_first_tail_x6_r0_body.st86.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st86.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st86.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs86 PRE_first_tail_x6_r0_body.st86.wr PRE_first_tail_x6_r0_body.s833 PRE_first_tail_x6_r0_body.st86.s2 PRE_first_tail_x6_r0_body.st86.s0
      PRE_first_tail_x6_r0_body.st86.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st86.F FR W stk M ν K PRE_first_tail_x6_r0_body.s834 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso86 PRE_first_tail_x6_r0_body.stFoot86 PRE_first_tail_x6_r0_body.wrNodup86 PRE_first_tail_x6_r0_body.wrBound86 PRE_first_tail_x6_r0_body.trace86 PRE_first_tail_x6_r0_body.mheap86
    PRE_first_tail_x6_r0_body.mnext86 PRE_first_tail_x6_r0_body.mctl86 PRE_first_tail_x6_r0_body.mstack86 PRE_first_tail_x6_r0_body.mjobs86 PRE_first_tail_x6_r0_body.mffi86 PRE_first_tail_x6_r0_body.mtrace86 PRE_first_tail_x6_r0_body.mstores86 h

def PRE_first_tail_x6_r0_body.arrEl86_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE86_2665 : arrOf PRE_first_tail_x6_r0_body.s834 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl86_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA86_2665 : isArrB PRE_first_tail_x6_r0_body.s834 2665 = true
theorem PRE_first_tail_x6_r0_body.arr86_2665 : ∃ o, PRE_first_tail_x6_r0_body.s834.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl86_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE86_2665 PRE_first_tail_x6_r0_body.arrA86_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN86_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl86_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR86_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl86_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN86_2665

def PRE_first_tail_x6_r0_body.arrEl86_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE86_2673467 : arrOf PRE_first_tail_x6_r0_body.s834 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl86_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA86_2673467 : isArrB PRE_first_tail_x6_r0_body.s834 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr86_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s834.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl86_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE86_2673467 PRE_first_tail_x6_r0_body.arrA86_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN86_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl86_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR86_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl86_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN86_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k86 : isArrB PRE_first_tail_x6_r0_body.s834 4910 = false
theorem PRE_first_tail_x6_r0_body.keep86 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s834 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k86 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr86_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl86_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ86
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 86 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s833`, the merged
state `PRE_first_tail_x6_r0_body.s834`, the canonical state `PRE_first_tail_x6_r0_body.s835`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl86 : PRE_first_tail_x6_r0_body.pl86.all (Nat.ble PRE_first_tail_x6_r0_body.s833.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd86 : nodupT PRE_first_tail_x6_r0_body.pl86 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn186 : Nat.ble PRE_first_tail_x6_r0_body.s833.next 2742166 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst86 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s833.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn86 : PRE_first_tail_x6_r0_body.s835.next = PRE_first_tail_x6_r0_body.s833.next + PRE_first_tail_x6_r0_body.pl86.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn86 : PRE_first_tail_x6_r0_body.s834.next = 2742166
kernel_rfl PRE_first_tail_x6_r0_body.zgrow86 : Nat.ble PRE_first_tail_x6_r0_body.s835.next PRE_first_tail_x6_r0_body.s834.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh86 : PRE_first_tail_x6_r0_body.S833.tab.all (fun e => PRE_first_tail_x6_r0_body.cws86.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd86 : nodupT PRE_first_tail_x6_r0_body.cws86 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi86 : PRE_first_tail_x6_r0_body.nr86.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S834.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt86 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s833.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg86_2665 : PRE_first_tail_x6_r0_body.s835.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s835 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk86_2665 : (objOf PRE_first_tail_x6_r0_body.s835 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm86_2665 : PRE_first_tail_x6_r0_body.s834.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa86.obj (objOf PRE_first_tail_x6_r0_body.s835 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s834 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg86_2673467 : PRE_first_tail_x6_r0_body.s835.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s835 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk86_2673467 : (objOf PRE_first_tail_x6_r0_body.s835 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm86_2673467 : PRE_first_tail_x6_r0_body.s834.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa86.obj (objOf PRE_first_tail_x6_r0_body.s835 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s834 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw86_4910 : (PRE_first_tail_x6_r0_body.s835.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw86_2673472 : (PRE_first_tail_x6_r0_body.s835.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw86_2673473 : (PRE_first_tail_x6_r0_body.s835.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd86 : PRE_first_tail_x6_r0_body.cl86.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr86 : PRE_first_tail_x6_r0_body.st86.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s833.next || PRE_first_tail_x6_r0_body.cl86.contains b) = true
def PRE_first_tail_x6_r0_body.zl86 : List Nat := PRE_first_tail_x6_r0_body.cl86.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE86 : PRE_first_tail_x6_r0_body.zl86.map (fun a => PRE_first_tail_x6_r0_body.s834.heap.get (PRE_first_tail_x6_r0_body.kappa86.a a)) = PRE_first_tail_x6_r0_body.zl86.map (fun a => (PRE_first_tail_x6_r0_body.s835.heap.get a).map PRE_first_tail_x6_r0_body.kappa86.hobj)
theorem PRE_first_tail_x6_r0_body.zimg86 : HeapImg PRE_first_tail_x6_r0_body.kappa86 PRE_first_tail_x6_r0_body.s835 PRE_first_tail_x6_r0_body.s834 PRE_first_tail_x6_r0_body.zl86 := PRE_first_tail_x6_r0_body.zimgE86
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl86 : PRE_first_tail_x6_r0_body.s834.ctl = PRE_first_tail_x6_r0_body.kappa86.ctl PRE_first_tail_x6_r0_body.s835.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack86 : PRE_first_tail_x6_r0_body.s834.stack = PRE_first_tail_x6_r0_body.s835.stack.map PRE_first_tail_x6_r0_body.kappa86.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs86 : PRE_first_tail_x6_r0_body.s834.jobs = PRE_first_tail_x6_r0_body.s835.jobs.map PRE_first_tail_x6_r0_body.kappa86.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores86 : PRE_first_tail_x6_r0_body.s834.stores = PRE_first_tail_x6_r0_body.kappa86.stores PRE_first_tail_x6_r0_body.s835.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots86 : checkRootsSupp PRE_first_tail_x6_r0_body.s835 3730 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC86 : PRE_first_tail_x6_r0_body.S833.tab.length + PRE_first_tail_x6_r0_body.cws86.length = 3730
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap86 : PRE_first_tail_x6_r0_body.kappa86 = Conv.Map.compact PRE_first_tail_x6_r0_body.s833.next 2742166 PRE_first_tail_x6_r0_body.S833.tab.length PRE_first_tail_x6_r0_body.pl86 (PRE_first_tail_x6_r0_body.nr86.map NumV.ref) PRE_first_tail_x6_r0_body.kd86.big
  PRE_first_tail_x6_r0_body.kd86.region PRE_first_tail_x6_r0_body.kd86.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin86 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s835.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc86 : Conv.jcleanListB (⟨19891, 16981, 2742156, 3730⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s835 PRE_first_tail_x6_r0_body.cl86 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB86 : noBigRootsP (fun i => !Conv.oldBigB (⟨19891, 16981, 2742156, 3730⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s835.trace PRE_first_tail_x6_r0_body.s835 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm86 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 16981 = true
theorem PRE_first_tail_x6_r0_body.cjcl86 (h : Conv.JClean (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s833) : Conv.JClean (⟨19891, 16981, 2742156, 3730⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s835 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle86)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap86 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd86 a ha)) PRE_first_tail_x6_r0_body.zjc86

end Host.Load.Run.Tpl
end

section -- st86/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st86.bodyLast from PRE_first_tail_x6_r0_body.st86.s1 to PRE_first_tail_x6_r0_body.st86.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st86.F PRE_first_tail_x6_r0_body.st86.s1).run PRE_first_tail_x6_r0_body.st86.S1 = some (PRE_first_tail_x6_r0_body.st86.s2, PRE_first_tail_x6_r0_body.st86.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st86.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st86.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st86.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st86.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st86/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st86.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st86.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st86.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st86.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st86.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st86.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st86.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st86.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st86.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st86.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st86.s0 PRE_first_tail_x6_r0_body.st86.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st86.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st86.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st86.s1 PRE_first_tail_x6_r0_body.st86.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st86/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st86.bodyK0F from PRE_first_tail_x6_r0_body.st86.s0 to PRE_first_tail_x6_r0_body.st86.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st86.F (PRE_first_tail_x6_r0_body.st86.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st86.ks 0).getD 0) PRE_first_tail_x6_r0_body.st86.s0 PRE_first_tail_x6_r0_body.st86.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st86.s1, PRE_first_tail_x6_r0_body.st86.S1)
theorem PRE_first_tail_x6_r0_body.st86.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st86.F (PRE_first_tail_x6_r0_body.st86.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st86.ks 0).getD 0) PRE_first_tail_x6_r0_body.st86.s0 PRE_first_tail_x6_r0_body.st86.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st86.s1, PRE_first_tail_x6_r0_body.st86.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st86.bodyOkLN_ok PRE_first_tail_x6_r0_body.st86.bodyK0F
end Host.Load.Run.Tpl
end

section -- st86/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st86.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st86.F (PRE_first_tail_x6_r0_body.st86.bodyOkL bytes rows) 98 PRE_first_tail_x6_r0_body.st86.s0 PRE_first_tail_x6_r0_body.st86.S0 = some (PRE_first_tail_x6_r0_body.st86.s1, PRE_first_tail_x6_r0_body.st86.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st86.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st86.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st86.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st86.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st86.F (PRE_first_tail_x6_r0_body.st86.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st86.s0
  S0 := PRE_first_tail_x6_r0_body.st86.S0
  s1 := PRE_first_tail_x6_r0_body.st86.s1
  S1 := PRE_first_tail_x6_r0_body.st86.S1
  s2 := PRE_first_tail_x6_r0_body.st86.s2
  S2 := PRE_first_tail_x6_r0_body.st86.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st86.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st86.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st86.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st86.bodyHalt
  last := PRE_first_tail_x6_r0_body.st86.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st86.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC87
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 87 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s852` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa87` into the merged state
`PRE_first_tail_x6_r0_body.s851`. -/

def PRE_first_tail_x6_r0_body.pl87 : List Nat := [2744739, 2743914, 2744745, 2744741, 2743916, 2744747]
def PRE_first_tail_x6_r0_body.nr87 : List Nat := [3833, 3832, 3808, 3816, 3821, 3826, 3831, 3805, 3806, 3807, 3814, 3815, 3803, 3810, 3811, 3812, 3813, 3809]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd87 : RData :=
  ⟨2743633, 2744782, Stage.setAll PTrie.nil [(2743627, 2744739), (2743628, 2743914), (2743629, 2744745), (2743630, 2744741), (2743631, 2743916), (2743632, 2744747)], Stage.setAll PTrie.nil [(19925, 19951), (19926, 19929), (19927, 19952)],
   19928, 19953, 17027, 17027, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(3803, .ref 3833), (3804, .ref 3832), (3805, .ref 3808), (3806, .ref 3816), (3807, .ref 3821), (3808, .ref 3826), (3809, .ref 3831), (3810, .ref 3805), (3811, .ref 3806), (3812, .ref 3807), (3813, .ref 3814), (3814, .ref 3815), (3815, .ref 3803), (3816, .ref 3810), (3817, .ref 3811), (3818, .ref 3812), (3819, .ref 3813), (3820, .ref 3809)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa87 : Map :=
  Conv.Map.compact 2743627 2744782 3803 PRE_first_tail_x6_r0_body.pl87 (PRE_first_tail_x6_r0_body.nr87.map NumV.ref) PRE_first_tail_x6_r0_body.kd87.big
    PRE_first_tail_x6_r0_body.kd87.region PRE_first_tail_x6_r0_body.kd87.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws87 : List Nat := [2478, 2479, 2480, 2481, 2482, 2483, 2484, 2485, 2486, 2487, 2488, 2489, 2490, 2491, 2492, 2493, 2494, 2495]
noncomputable def PRE_first_tail_x6_r0_body.crs87 : List SymE := PRE_first_tail_x6_r0_body.nr87.map fun r => (nth? PRE_first_tail_x6_r0_body.S851.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta87 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws87 PRE_first_tail_x6_r0_body.crs87
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB87 : List Nat := [2665, 2672522, 2673467, 2742801, 2743346, 2743602]

kernel_rfl PRE_first_tail_x6_r0_body.ctab87 : PRE_first_tail_x6_r0_body.S852.tab = PRE_first_tail_x6_r0_body.S850.tab ++ PRE_first_tail_x6_r0_body.cws87.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace87 : PRE_first_tail_x6_r0_body.s852.trace = PRE_first_tail_x6_r0_body.s850.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext87 : PRE_first_tail_x6_r0_body.s852.next = 2743633
kernel_rfl PRE_first_tail_x6_r0_body.ccounters87 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s852.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s852.ffi).mlx.nnext) = (19928, 17027)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue87 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s851.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s852.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa87.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp87 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s852.ffi).mlx.tokens.all (bSN 3821) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean87 : Conv.cleanListB 19928 131072 (fun r => Nat.ble 79712 r) PRE_first_tail_x6_r0_body.s852
    (PRE_first_tail_x6_r0_body.wrB87 ++ (List.range 6).map (2743627 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs87 : bigsOutB 19928 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s852.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK87
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl87`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl87 : List Nat := [2665, 2672522, 2673467, 2742801, 2743346, 2743602, 2743627, 2743628, 2743629, 2743630, 2743631, 2743632]
def PRE_first_tail_x6_r0_body.clo87 : List Nat := [19905, 19918, 19924, 19925, 19926, 19927]
def PRE_first_tail_x6_r0_body.cln87 : List Nat := [17000, 17001, 17002, 17003, 17004, 17005, 17006, 17007, 17008, 17009, 17010, 17011, 17012, 17013, 17014, 17015, 17016, 17017, 17018, 17019, 17020, 17021, 17022, 17023, 17024, 17025, 17026]
def PRE_first_tail_x6_r0_body.cli87 : List Nat := [17000, 17001, 17002, 17003, 17004, 17005, 17006, 17007, 17008, 17009, 17010, 17011, 17012, 17013, 17014, 17015, 17016, 17017, 17018, 17019, 17020, 17021, 17022, 17023, 17024, 17025, 17026]
kernel_rfl PRE_first_tail_x6_r0_body.cheap87 : PRE_first_tail_x6_r0_body.s852.heap = Stage.setAll PRE_first_tail_x6_r0_body.s850.heap (PRE_first_tail_x6_r0_body.cl87.filterMap fun a => (PRE_first_tail_x6_r0_body.s852.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe87 : Nat.ble PRE_first_tail_x6_r0_body.s850.next PRE_first_tail_x6_r0_body.s852.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP87 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s850 PRE_first_tail_x6_r0_body.s852 PRE_first_tail_x6_r0_body.cl87 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp87 : Conv.suppListB PRE_first_tail_x6_r0_body.s852 3821 PRE_first_tail_x6_r0_body.cl87 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound87 : Conv.boundListB PRE_first_tail_x6_r0_body.s852 PRE_first_tail_x6_r0_body.cl87 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK87 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s852.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln87.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s852.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK87 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s852.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo87.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s852.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK87 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s852.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli87.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s852.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst87 : Conv.sstListB 3821 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s852.ffi).mlx PRE_first_tail_x6_r0_body.cln87 PRE_first_tail_x6_r0_body.clo87 PRE_first_tail_x6_r0_body.cli87 = true

end Host.Load.Run.Tpl
end

section -- SiteCl87
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA87 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s852.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo87.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s852.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd87 : (PRE_first_tail_x6_r0_body.clo87 ++ PRE_first_tail_x6_r0_body.cln87 ++ PRE_first_tail_x6_r0_body.cli87).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle87 : Conv.Cnt.leB (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt) (⟨19928, 17027, 2743633, 3821⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck87 : Conv.ncleanListB (⟨19928, 17027, 2743633, 3821⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s852.ffi).mlx PRE_first_tail_x6_r0_body.clo87 PRE_first_tail_x6_r0_body.cln87 PRE_first_tail_x6_r0_body.cli87 = true
theorem PRE_first_tail_x6_r0_body.cncl87 (h : Conv.NClean (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx) : Conv.NClean (⟨19928, 17027, 2743633, 3821⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s852.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle87 PRE_first_tail_x6_r0_body.ckA87 PRE_first_tail_x6_r0_body.cobjsK87 PRE_first_tail_x6_r0_body.cnodesK87 PRE_first_tail_x6_r0_body.citemsK87 PRE_first_tail_x6_r0_body.cbd87 PRE_first_tail_x6_r0_body.cck87

end Host.Load.Run.Tpl
end

section -- SiteS87
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 87 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc87 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P87 : LoadP := PRE_first_tail_x6_r0_body.Pc87.raise 17027
kernel_rfl PRE_first_tail_x6_r0_body.craise87 : Nat.ble PRE_first_tail_x6_r0_body.Pc87.N0 17027 = true
theorem PRE_first_tail_x6_r0_body.raised87 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc87 PRE_first_tail_x6_r0_body.P87 :=
  .inr ⟨17027, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise87, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_87 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s852.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_87 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s851.ffi)
def PRE_first_tail_x6_r0_body.khinv87 : PTrie Nat := Stage.setAll PTrie.nil [(19951, 19925), (19929, 19926), (19952, 19927)]
def PRE_first_tail_x6_r0_body.kninv87 : PTrie Nat := Stage.setAll PTrie.nil [(17000, 17000), (17001, 17001), (17002, 17002), (17003, 17003), (17004, 17004), (17005, 17005), (17006, 17006), (17007, 17007), (17008, 17008), (17009, 17009), (17010, 17010), (17011, 17011), (17012, 17012), (17013, 17013), (17014, 17014), (17015, 17015), (17016, 17016), (17017, 17017), (17018, 17018), (17019, 17019), (17020, 17020), (17021, 17021), (17022, 17022), (17023, 17023), (17024, 17024), (17025, 17025), (17026, 17026)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS87 : List Nat := [19905, 19918, 19924, 19925, 19926, 19927, 19928, 19929, 19930, 19931, 19932, 19933, 19934, 19935, 19936, 19937, 19938, 19939, 19940, 19941, 19942, 19943, 19944, 19945, 19946, 19947, 19948, 19949, 19950, 19951, 19952]
def PRE_first_tail_x6_r0_body.cnS87 : List Nat := List.range' 17000 27
def PRE_first_tail_x6_r0_body.ciS87 : List Nat := [] ++ List.range' 17000 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh087 : PRE_first_tail_x6_r0_body.kd87.nh0 = PRE_first_tail_x6_r0_body.cx0_87.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh187 : PRE_first_tail_x6_r0_body.kd87.nh1 = PRE_first_tail_x6_r0_body.cx1_87.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn087 : PRE_first_tail_x6_r0_body.kd87.nn0 = PRE_first_tail_x6_r0_body.cx0_87.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn187 : PRE_first_tail_x6_r0_body.kd87.nn1 = PRE_first_tail_x6_r0_body.cx1_87.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo87 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P87.lo && Nat.ble PRE_first_tail_x6_r0_body.P87.lo PRE_first_tail_x6_r0_body.cx0_87.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P87.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P87.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt87 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_87.mlx.next PRE_first_tail_x6_r0_body.cx1_87.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_87.mlx.nnext PRE_first_tail_x6_r0_body.cx1_87.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband87 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P87.NL && Nat.ble PRE_first_tail_x6_r0_body.P87.NL PRE_first_tail_x6_r0_body.P87.N0 && Nat.ble PRE_first_tail_x6_r0_body.P87.N0 PRE_first_tail_x6_r0_body.cx0_87.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow87 : PRE_first_tail_x6_r0_body.kd87.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren87 : checkRenG PRE_first_tail_x6_r0_body.kd87.hnd PRE_first_tail_x6_r0_body.khinv87 (phB PRE_first_tail_x6_r0_body.cx0_87.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband87 : PRE_first_tail_x6_r0_body.kd87.checkBand PRE_first_tail_x6_r0_body.P87.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos87 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd87.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren87 : checkRenG PRE_first_tail_x6_r0_body.kd87.node PRE_first_tail_x6_r0_body.kninv87 (pnB PRE_first_tail_x6_r0_body.cx0_87.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow87 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd87.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P87.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd87.nodeF j) PRE_first_tail_x6_r0_body.cx1_87.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a87 : PRE_first_tail_x6_r0_body.cx0_87.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b87 : PRE_first_tail_x6_r0_body.cx0_87.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok187 : PRE_first_tail_x6_r0_body.cx1_87.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend87 : PRE_first_tail_x6_r0_body.cx1_87.mlx.pending = PRE_first_tail_x6_r0_body.cx0_87.mlx.pending.map PRE_first_tail_x6_r0_body.kappa87.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh87 : PRE_first_tail_x6_r0_body.cx1_87.mlx.errh = PRE_first_tail_x6_r0_body.cx0_87.mlx.errh.map PRE_first_tail_x6_r0_body.kappa87.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles87 : PRE_first_tail_x6_r0_body.cx1_87.mlx.files = PRE_first_tail_x6_r0_body.cx0_87.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch87 : PRE_first_tail_x6_r0_body.cx1_87.mlx.arch = PRE_first_tail_x6_r0_body.cx0_87.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes87 : PRE_first_tail_x6_r0_body.cx1_87.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_87.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired87 : PRE_first_tail_x6_r0_body.cx1_87.mlx.wired = PRE_first_tail_x6_r0_body.cx0_87.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost87 : PRE_first_tail_x6_r0_body.cx1_87.host = PRE_first_tail_x6_r0_body.cx0_87.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd87`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn087 : PRE_first_tail_x6_r0_body.kd87.n0 = 2743633
kernel_rfl PRE_first_tail_x6_r0_body.ckn187 : PRE_first_tail_x6_r0_body.kd87.n1 = 2744782
kernel_rfl PRE_first_tail_x6_r0_body.ckheap87 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd87.heap).all (fun x => Nat.ble 2743627 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl87 : (List.range 6).all (fun j => decide (PRE_first_tail_x6_r0_body.kd87.heap.get (2743627 + j) = nth? PRE_first_tail_x6_r0_body.pl87 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja87 : Nat.ble 2743627 2743627 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn87 : Nat.ble 3803 3803 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD87 : Nat.ble 2743627 PRE_first_tail_x6_r0_body.kd87.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn87 : Nat.ble 19925 PRE_first_tail_x6_r0_body.kd87.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn87 : Nat.ble 17000 PRE_first_tail_x6_r0_body.kd87.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb87 : Nat.ble 19925 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap87 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd87.heap).all (Nat.ble (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd87 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd87.hnd).all (Nat.ble (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode87 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd87.node).all (Nat.ble (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix87 : Conv.FixOld (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa87 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja87) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn87) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD87) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn87) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn87) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb87) PRE_first_tail_x6_r0_body.fheap87 PRE_first_tail_x6_r0_body.fhnd87 PRE_first_tail_x6_r0_body.fnode87
kernel_rfl PRE_first_tail_x6_r0_body.fcxn87 : (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn87 : (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle087 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_87.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_87.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk87 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd87.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A87 : PRE_first_tail_x6_r0_body.cx1_87.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS87.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_87.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O87 : PRE_first_tail_x6_r0_body.cx1_87.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS87.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_87.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N87 : PRE_first_tail_x6_r0_body.cx1_87.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS87.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_87.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I87 : PRE_first_tail_x6_r0_body.cx1_87.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS87.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_87.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd87 : (PRE_first_tail_x6_r0_body.clo87 ++ PRE_first_tail_x6_r0_body.cln87 ++ PRE_first_tail_x6_r0_body.cli87 ++ PRE_first_tail_x6_r0_body.cwS87 ++ PRE_first_tail_x6_r0_body.cnS87 ++ PRE_first_tail_x6_r0_body.ciS87).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW87 : PRE_first_tail_x6_r0_body.cwS87.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo87.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI87 : PRE_first_tail_x6_r0_body.ciS87.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli87.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN87 : PRE_first_tail_x6_r0_body.cnS87.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF87 : PRE_first_tail_x6_r0_body.cln87.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh87 : PRE_first_tail_x6_r0_body.clo87.all (handleOK PRE_first_tail_x6_r0_body.kappa87 PRE_first_tail_x6_r0_body.P87.lo PRE_first_tail_x6_r0_body.cx0_87.mlx PRE_first_tail_x6_r0_body.cx1_87.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo87 : PRE_first_tail_x6_r0_body.clo87.map (fun h => PRE_first_tail_x6_r0_body.cx1_87.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa87.handle h)) = PRE_first_tail_x6_r0_body.clo87.map (fun h => (PRE_first_tail_x6_r0_body.cx0_87.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa87.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok87 : PRE_first_tail_x6_r0_body.clo87.all (objOK PRE_first_tail_x6_r0_body.kappa87 PRE_first_tail_x6_r0_body.P87.NL PRE_first_tail_x6_r0_body.cx0_87.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd87 : PRE_first_tail_x6_r0_body.cln87.all (nodeOKF PRE_first_tail_x6_r0_body.kappa87 PRE_first_tail_x6_r0_body.P87 PRE_first_tail_x6_r0_body.cx0_87.mlx PRE_first_tail_x6_r0_body.cx1_87.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp87 : ((PRE_first_tail_x6_r0_body.cln87.filter (fullB PRE_first_tail_x6_r0_body.P87))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_87.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa87.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln87.filter (fullB PRE_first_tail_x6_r0_body.P87))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_87.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa87.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI87 : incrB PRE_first_tail_x6_r0_body.kd87.nodeF (List.range' 17000 27) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK87 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd87.node).all (fun k => Nat.ble 17000 k && Nat.blt k 17027) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL87 : (PRE_first_tail_x6_r0_body.cln87.filter (Nat.ble PRE_first_tail_x6_r0_body.P87.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd87.nodeF i) && (Nat.blt i 17027 || Nat.ble PRE_first_tail_x6_r0_body.kd87.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord87 : (PRE_first_tail_x6_r0_body.cln87.filter (Nat.ble PRE_first_tail_x6_r0_body.P87.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd87.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd87.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd87.nodeF j) (PRE_first_tail_x6_r0_body.kd87.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow87 PRE_first_tail_x6_r0_body.cnn187 PRE_first_tail_x6_r0_body.fnordI87 PRE_first_tail_x6_r0_body.fnordK87 PRE_first_tail_x6_r0_body.fnordL87
kernel_rfl PRE_first_tail_x6_r0_body.fi87 : PRE_first_tail_x6_r0_body.cli87.all (pnB PRE_first_tail_x6_r0_body.cx0_87.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii87 : PRE_first_tail_x6_r0_body.cli87.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_87.mlx.items.get (PRE_first_tail_x6_r0_body.kappa87.node k) = (PRE_first_tail_x6_r0_body.cx0_87.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa87.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot87 (clean : Conv.NClean (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P87.NL) (cl : SSt (· < 3821) PRE_first_tail_x6_r0_body.cx0_87.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P87 3821 PRE_first_tail_x6_r0_body.kappa87 PRE_first_tail_x6_r0_body.kd87 PRE_first_tail_x6_r0_body.khinv87 PRE_first_tail_x6_r0_body.kninv87 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx PRE_first_tail_x6_r0_body.cx0_87.mlx PRE_first_tail_x6_r0_body.cx1_87.mlx (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo87 PRE_first_tail_x6_r0_body.cln87 PRE_first_tail_x6_r0_body.cli87 PRE_first_tail_x6_r0_body.cwS87 PRE_first_tail_x6_r0_body.cnS87 PRE_first_tail_x6_r0_body.ciS87 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh087, PRE_first_tail_x6_r0_body.cnh187, PRE_first_tail_x6_r0_body.cnn087, PRE_first_tail_x6_r0_body.cnn187, PRE_first_tail_x6_r0_body.cplo87, PRE_first_tail_x6_r0_body.ccnt87, PRE_first_tail_x6_r0_body.cnband87, PRE_first_tail_x6_r0_body.chbelow87, PRE_first_tail_x6_r0_body.chren87, PRE_first_tail_x6_r0_body.cband87, PRE_first_tail_x6_r0_body.cnh1pos87, PRE_first_tail_x6_r0_body.cnren87, PRE_first_tail_x6_r0_body.cnlow87, PRE_first_tail_x6_r0_body.cabs0a87, PRE_first_tail_x6_r0_body.cabs0b87, PRE_first_tail_x6_r0_body.ctok187, PRE_first_tail_x6_r0_body.cpend87, PRE_first_tail_x6_r0_body.cerrh87, PRE_first_tail_x6_r0_body.cfiles87, PRE_first_tail_x6_r0_body.carch87, PRE_first_tail_x6_r0_body.csizes87, PRE_first_tail_x6_r0_body.cwired87, PRE_first_tail_x6_r0_body.cfix87, clean, PRE_first_tail_x6_r0_body.fcxn87, PRE_first_tail_x6_r0_body.fcnn87, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle087, PRE_first_tail_x6_r0_body.fnk87, PRE_first_tail_x6_r0_body.ckA87, PRE_first_tail_x6_r0_body.cobjsK87, PRE_first_tail_x6_r0_body.cnodesK87, PRE_first_tail_x6_r0_body.citemsK87, PRE_first_tail_x6_r0_body.f1A87, PRE_first_tail_x6_r0_body.f1O87, PRE_first_tail_x6_r0_body.f1N87, PRE_first_tail_x6_r0_body.f1I87, PRE_first_tail_x6_r0_body.fbd87, PRE_first_tail_x6_r0_body.fincW87, PRE_first_tail_x6_r0_body.fincI87, PRE_first_tail_x6_r0_body.fincN87, PRE_first_tail_x6_r0_body.flnF87, PRE_first_tail_x6_r0_body.fh87, PRE_first_tail_x6_r0_body.fo87, PRE_first_tail_x6_r0_body.fok87, PRE_first_tail_x6_r0_body.fnd87, PRE_first_tail_x6_r0_body.fp87, PRE_first_tail_x6_r0_body.fnord87, PRE_first_tail_x6_r0_body.fi87, PRE_first_tail_x6_r0_body.fii87⟩
theorem PRE_first_tail_x6_r0_body.cnshift87 (clean : Conv.NClean (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P87.NL) (cl : SSt (· < 3821) PRE_first_tail_x6_r0_body.cx0_87.mlx) : NShift PRE_first_tail_x6_r0_body.P87 3821 PRE_first_tail_x6_r0_body.kappa87 PRE_first_tail_x6_r0_body.cx0_87 PRE_first_tail_x6_r0_body.cx1_87 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot87 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost87 (compact_a_eq PRE_first_tail_x6_r0_body.ckn087 PRE_first_tail_x6_r0_body.ckn187 PRE_first_tail_x6_r0_body.ckheap87 PRE_first_tail_x6_r0_body.ckpl87)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_87 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s850.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_87 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s850.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_87 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s850.ffi) = some PRE_first_tail_x6_r0_body.fxC_87
kernel_rfl PRE_first_tail_x6_r0_body.okrC_87 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s850.ffi) = some PRE_first_tail_x6_r0_body.krC_87
noncomputable def PRE_first_tail_x6_r0_body.fx0_87 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s852.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_87 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s852.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_87 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s852.ffi) = some PRE_first_tail_x6_r0_body.fx0_87
kernel_rfl PRE_first_tail_x6_r0_body.okr0_87 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s852.ffi) = some PRE_first_tail_x6_r0_body.kr0_87
noncomputable def PRE_first_tail_x6_r0_body.fx1_87 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s851.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_87 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s851.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_87 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s851.ffi) = some PRE_first_tail_x6_r0_body.fx1_87
kernel_rfl PRE_first_tail_x6_r0_body.okr1_87 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s851.ffi) = some PRE_first_tail_x6_r0_body.kr1_87
kernel_rfl PRE_first_tail_x6_r0_body.ff087 : PRE_first_tail_x6_r0_body.fx0_87 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_87 (PRE_first_tail_x6_r0_body.clo87.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_87.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff187 : PRE_first_tail_x6_r0_body.fx1_87 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_87 (PRE_first_tail_x6_r0_body.cwS87.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_87.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck87 : freedLB PRE_first_tail_x6_r0_body.kappa87 PRE_first_tail_x6_r0_body.cx0_87.mlx PRE_first_tail_x6_r0_body.fx0_87 PRE_first_tail_x6_r0_body.fx1_87 PRE_first_tail_x6_r0_body.clo87 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf087 : PRE_first_tail_x6_r0_body.kr0_87.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_87.flags (PRE_first_tail_x6_r0_body.clo87.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_87.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt087 : PRE_first_tail_x6_r0_body.kr0_87.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_87.targs (PRE_first_tail_x6_r0_body.clo87.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_87.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf187 : PRE_first_tail_x6_r0_body.kr1_87.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_87.flags (PRE_first_tail_x6_r0_body.cwS87.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_87.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt187 : PRE_first_tail_x6_r0_body.kr1_87.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_87.targs (PRE_first_tail_x6_r0_body.cwS87.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_87.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck87 : krecLB PRE_first_tail_x6_r0_body.kappa87 3821 PRE_first_tail_x6_r0_body.cx0_87.mlx PRE_first_tail_x6_r0_body.kr0_87 PRE_first_tail_x6_r0_body.kr1_87 PRE_first_tail_x6_r0_body.clo87 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn87 : Nat.ble 3803 3821 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge87 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s851.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s852.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR87 : pendRegB PRE_first_tail_x6_r0_body.kappa87 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s852.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe87 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s852.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s851.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift87 (clean : Conv.NClean (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P87.NL) (cl : SSt (· < 3821) PRE_first_tail_x6_r0_body.cx0_87.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_87.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_87.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_87.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s850.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_87.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P87 3821 PRE_first_tail_x6_r0_body.kappa87 PRE_first_tail_x6_r0_body.s852.ffi PRE_first_tail_x6_r0_body.s851.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift87 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue87, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp87 t ht),
    PRE_first_tail_x6_r0_body.cbridge87,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s852.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s851.ffi) (PRE_first_tail_x6_r0_body.cfoot87 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_87 PRE_first_tail_x6_r0_body.ofx1_87 hobjC PRE_first_tail_x6_r0_body.ff087 PRE_first_tail_x6_r0_body.ff187 PRE_first_tail_x6_r0_body.ffck87,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s852.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s851.ffi) (PRE_first_tail_x6_r0_body.cfoot87 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_87 PRE_first_tail_x6_r0_body.okr1_87 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn87) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf087 PRE_first_tail_x6_r0_body.fkt087 PRE_first_tail_x6_r0_body.fkf187 PRE_first_tail_x6_r0_body.fkt187 PRE_first_tail_x6_r0_body.fkck87,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh087 PRE_first_tail_x6_r0_body.cnh187 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe87) PRE_first_tail_x6_r0_body.cpendR87⟩

end Host.Load.Run.Tpl
end

section -- st87/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st87 0
host_stream_state PRE_first_tail_x6_r0_body.st87 1
host_stream_state PRE_first_tail_x6_r0_body.st87 2
host_stream_state PRE_first_tail_x6_r0_body.st87 3
host_stream_state PRE_first_tail_x6_r0_body.st87 4
host_stream_state PRE_first_tail_x6_r0_body.st87 5
end Host.Load.Run.Tpl
end

section -- Site87
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 87 of chain `PRE_first_tail_x6_r0_body`: `ssmW__g87__g88` (`recurWindow`), the call state `PRE_first_tail_x6_r0_body.s850`, the merged state `PRE_first_tail_x6_r0_body.s851`,
the site template `PRE_first_tail_x6_r0_body.st87` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s852`: the merge.
The footprint's facts are in `SiteF87`, the compaction's in `SiteC87`, `SiteK87`, `SiteNa87`, `SiteNb87`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso87 : PRE_first_tail_x6_r0_body.st87.s0 = { PRE_first_tail_x6_r0_body.s850 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs87 : List Frame := PRE_first_tail_x6_r0_body.s850.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_87 : PRE_first_tail_x6_r0_body.S850.tab.length = 3803
kernel_rfl PRE_first_tail_x6_r0_body.tab0_87 : PRE_first_tail_x6_r0_body.st87.S0.tab = PRE_first_tail_x6_r0_body.S850.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws87 : List Nat := [2447, 2448, 2449, 2450, 2451, 2452, 2453, 2454, 2455, 2456, 2457, 2458, 2459, 2460, 2461, 2462, 2463, 2464, 2465, 2466, 2467, 2468, 2469, 2470, 2471, 2472, 2473, 2474, 2475, 2476, 2477]
kernel_rfl PRE_first_tail_x6_r0_body.fresh87 : (PRE_first_tail_x6_r0_body.S850.tab.all fun e => PRE_first_tail_x6_r0_body.ws87.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S850.oracle.all fun q => PRE_first_tail_x6_r0_body.ws87.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab87 : PRE_first_tail_x6_r0_body.S851.tab = PRE_first_tail_x6_r0_body.S850.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws87
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen87 : PRE_first_tail_x6_r0_body.st87.S5.tab.length - PRE_first_tail_x6_r0_body.st87.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged87`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap87 : PRE_first_tail_x6_r0_body.s851.heap = PRE_first_tail_x6_r0_body.st87.s5.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext87 : PRE_first_tail_x6_r0_body.s851.next = PRE_first_tail_x6_r0_body.st87.s5.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl87 : PRE_first_tail_x6_r0_body.s851.ctl = PRE_first_tail_x6_r0_body.st87.s5.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack87 : PRE_first_tail_x6_r0_body.s851.stack = PRE_first_tail_x6_r0_body.st87.s5.stack ++ PRE_first_tail_x6_r0_body.s850.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs87 : PRE_first_tail_x6_r0_body.s851.jobs = PRE_first_tail_x6_r0_body.st87.s5.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi87 : PRE_first_tail_x6_r0_body.s851.ffi = PRE_first_tail_x6_r0_body.st87.s5.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace87 : PRE_first_tail_x6_r0_body.s851.trace = PRE_first_tail_x6_r0_body.st87.s5.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores87 : PRE_first_tail_x6_r0_body.s851.stores = PRE_first_tail_x6_r0_body.st87.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD87
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 87 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived87 : PRE_first_tail_x6_r0_body.nr87.map (fun r => nth? PRE_first_tail_x6_r0_body.st87.S5.tab r) =
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
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo87 : PRE_first_tail_x6_r0_body.nr87.all (Nat.ble 3803) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj87 : PRE_first_tail_x6_r0_body.cws87.all (fun c => !PRE_first_tail_x6_r0_body.ws87.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ87 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws87 PRE_first_tail_x6_r0_body.crs87 PRE_first_tail_x6_r0_body.ws87

end Host.Load.Run.Tpl
end

section -- st87/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st87`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st87.wrR : List (Nat × Nat) := [(2672522, 2672523), (2742801, 2742802), (2743346, 2743347), (2743602, 2743603)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st87.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st87.s5.heap PRE_first_tail_x6_r0_body.st87.wrR ++ freshOf PRE_first_tail_x6_r0_body.st87.s5.heap PRE_first_tail_x6_r0_body.st87.s0.next PRE_first_tail_x6_r0_body.st87.s5.next
noncomputable def PRE_first_tail_x6_r0_body.st87.wr : List Nat := PRE_first_tail_x6_r0_body.st87.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st87.heapFoot : PRE_first_tail_x6_r0_body.st87.s5.heap = setAll PRE_first_tail_x6_r0_body.st87.s0.heap PRE_first_tail_x6_r0_body.st87.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st87.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st87.s0.next PRE_first_tail_x6_r0_body.st87.s5.next = true
theorem PRE_first_tail_x6_r0_body.st87.grows : PRE_first_tail_x6_r0_body.st87.s0.next ≤ PRE_first_tail_x6_r0_body.st87.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st87.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st87.wh : List Nat := [19905, 19918, 19924, 19925, 19926, 19927, 19928, 19929, 19930, 19931, 19932, 19933, 19934, 19935, 19936, 19937, 19938, 19939, 19940, 19941, 19942, 19943, 19944, 19945, 19946, 19947, 19948, 19949, 19950, 19951, 19952]
def PRE_first_tail_x6_r0_body.st87.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st87.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st87.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st87.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st87.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st87.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st87.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st87.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st87.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st87.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st87.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st87.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st87.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st87.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st87.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st87.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st87.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st87.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st87.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st87.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st87.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st87.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st87.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st87.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st87.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st87.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st87.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st87.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st87.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st87.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF87
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 87 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB87 : nodupT PRE_first_tail_x6_r0_body.st87.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup87 : PRE_first_tail_x6_r0_body.st87.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB87).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB87 : PRE_first_tail_x6_r0_body.st87.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound87 : ∀ b ∈ PRE_first_tail_x6_r0_body.st87.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB87 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr87 := PRE_first_tail_x6_r0_body.st87.s5.trace.take 120
kernel_rfl PRE_first_tail_x6_r0_body.traceEq87 : PRE_first_tail_x6_r0_body.st87.s5.trace = PRE_first_tail_x6_r0_body.trFr87 ++ PRE_first_tail_x6_r0_body.st87.s0.trace
theorem PRE_first_tail_x6_r0_body.trace87 : ∃ fr, PRE_first_tail_x6_r0_body.st87.s5.trace = fr ++ PRE_first_tail_x6_r0_body.st87.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq87⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide87 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB87 : (PRE_first_tail_x6_r0_body.wide87.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st87.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix87 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide87, WFix Map.id (Present PRE_first_tail_x6_r0_body.st87.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB87 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL87
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 87 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s851`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO87 : PRE_first_tail_x6_r0_body.st87.S0.oracle = PRE_first_tail_x6_r0_body.st87.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B87 : PRE_first_tail_x6_r0_body.st87.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st87.s0.next || (PRE_first_tail_x6_r0_body.st87.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot87 : Conv.StageFoot PRE_first_tail_x6_r0_body.st87.wr PRE_first_tail_x6_r0_body.st87.s0 PRE_first_tail_x6_r0_body.st87.s5 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st87.heapFoot PRE_first_tail_x6_r0_body.wrNodup87 PRE_first_tail_x6_r0_body.wrBound87 PRE_first_tail_x6_r0_body.wr0B87 PRE_first_tail_x6_r0_body.st87.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged87 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st87.F.S → PRE_first_tail_x6_r0_body.st87.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st87.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st87.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs87 PRE_first_tail_x6_r0_body.st87.wr PRE_first_tail_x6_r0_body.s850 PRE_first_tail_x6_r0_body.st87.s5 PRE_first_tail_x6_r0_body.st87.s0
      PRE_first_tail_x6_r0_body.st87.s5.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st87.F FR W stk M ν K PRE_first_tail_x6_r0_body.s851 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso87 PRE_first_tail_x6_r0_body.stFoot87 PRE_first_tail_x6_r0_body.wrNodup87 PRE_first_tail_x6_r0_body.wrBound87 PRE_first_tail_x6_r0_body.trace87 PRE_first_tail_x6_r0_body.mheap87
    PRE_first_tail_x6_r0_body.mnext87 PRE_first_tail_x6_r0_body.mctl87 PRE_first_tail_x6_r0_body.mstack87 PRE_first_tail_x6_r0_body.mjobs87 PRE_first_tail_x6_r0_body.mffi87 PRE_first_tail_x6_r0_body.mtrace87 PRE_first_tail_x6_r0_body.mstores87 h

def PRE_first_tail_x6_r0_body.arrEl87_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE87_2665 : arrOf PRE_first_tail_x6_r0_body.s851 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl87_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA87_2665 : isArrB PRE_first_tail_x6_r0_body.s851 2665 = true
theorem PRE_first_tail_x6_r0_body.arr87_2665 : ∃ o, PRE_first_tail_x6_r0_body.s851.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl87_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE87_2665 PRE_first_tail_x6_r0_body.arrA87_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN87_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl87_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR87_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl87_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN87_2665

def PRE_first_tail_x6_r0_body.arrEl87_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE87_2673467 : arrOf PRE_first_tail_x6_r0_body.s851 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl87_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA87_2673467 : isArrB PRE_first_tail_x6_r0_body.s851 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr87_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s851.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl87_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE87_2673467 PRE_first_tail_x6_r0_body.arrA87_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN87_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl87_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR87_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl87_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN87_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k87 : isArrB PRE_first_tail_x6_r0_body.s851 4910 = false
theorem PRE_first_tail_x6_r0_body.keep87 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s851 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k87 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr87_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl87_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ87
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 87 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s850`, the merged
state `PRE_first_tail_x6_r0_body.s851`, the canonical state `PRE_first_tail_x6_r0_body.s852`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl87 : PRE_first_tail_x6_r0_body.pl87.all (Nat.ble PRE_first_tail_x6_r0_body.s850.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd87 : nodupT PRE_first_tail_x6_r0_body.pl87 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn187 : Nat.ble PRE_first_tail_x6_r0_body.s850.next 2744782 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst87 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s850.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn87 : PRE_first_tail_x6_r0_body.s852.next = PRE_first_tail_x6_r0_body.s850.next + PRE_first_tail_x6_r0_body.pl87.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn87 : PRE_first_tail_x6_r0_body.s851.next = 2744782
kernel_rfl PRE_first_tail_x6_r0_body.zgrow87 : Nat.ble PRE_first_tail_x6_r0_body.s852.next PRE_first_tail_x6_r0_body.s851.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh87 : PRE_first_tail_x6_r0_body.S850.tab.all (fun e => PRE_first_tail_x6_r0_body.cws87.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd87 : nodupT PRE_first_tail_x6_r0_body.cws87 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi87 : PRE_first_tail_x6_r0_body.nr87.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S851.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt87 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s850.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg87_2665 : PRE_first_tail_x6_r0_body.s852.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s852 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk87_2665 : (objOf PRE_first_tail_x6_r0_body.s852 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm87_2665 : PRE_first_tail_x6_r0_body.s851.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa87.obj (objOf PRE_first_tail_x6_r0_body.s852 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s851 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg87_2673467 : PRE_first_tail_x6_r0_body.s852.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s852 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk87_2673467 : (objOf PRE_first_tail_x6_r0_body.s852 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm87_2673467 : PRE_first_tail_x6_r0_body.s851.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa87.obj (objOf PRE_first_tail_x6_r0_body.s852 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s851 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw87_4910 : (PRE_first_tail_x6_r0_body.s852.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw87_2673472 : (PRE_first_tail_x6_r0_body.s852.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw87_2673473 : (PRE_first_tail_x6_r0_body.s852.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd87 : PRE_first_tail_x6_r0_body.cl87.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr87 : PRE_first_tail_x6_r0_body.st87.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s850.next || PRE_first_tail_x6_r0_body.cl87.contains b) = true
def PRE_first_tail_x6_r0_body.zl87 : List Nat := PRE_first_tail_x6_r0_body.cl87.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE87 : PRE_first_tail_x6_r0_body.zl87.map (fun a => PRE_first_tail_x6_r0_body.s851.heap.get (PRE_first_tail_x6_r0_body.kappa87.a a)) = PRE_first_tail_x6_r0_body.zl87.map (fun a => (PRE_first_tail_x6_r0_body.s852.heap.get a).map PRE_first_tail_x6_r0_body.kappa87.hobj)
theorem PRE_first_tail_x6_r0_body.zimg87 : HeapImg PRE_first_tail_x6_r0_body.kappa87 PRE_first_tail_x6_r0_body.s852 PRE_first_tail_x6_r0_body.s851 PRE_first_tail_x6_r0_body.zl87 := PRE_first_tail_x6_r0_body.zimgE87
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl87 : PRE_first_tail_x6_r0_body.s851.ctl = PRE_first_tail_x6_r0_body.kappa87.ctl PRE_first_tail_x6_r0_body.s852.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack87 : PRE_first_tail_x6_r0_body.s851.stack = PRE_first_tail_x6_r0_body.s852.stack.map PRE_first_tail_x6_r0_body.kappa87.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs87 : PRE_first_tail_x6_r0_body.s851.jobs = PRE_first_tail_x6_r0_body.s852.jobs.map PRE_first_tail_x6_r0_body.kappa87.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores87 : PRE_first_tail_x6_r0_body.s851.stores = PRE_first_tail_x6_r0_body.kappa87.stores PRE_first_tail_x6_r0_body.s852.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots87 : checkRootsSupp PRE_first_tail_x6_r0_body.s852 3821 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC87 : PRE_first_tail_x6_r0_body.S850.tab.length + PRE_first_tail_x6_r0_body.cws87.length = 3821
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap87 : PRE_first_tail_x6_r0_body.kappa87 = Conv.Map.compact PRE_first_tail_x6_r0_body.s850.next 2744782 PRE_first_tail_x6_r0_body.S850.tab.length PRE_first_tail_x6_r0_body.pl87 (PRE_first_tail_x6_r0_body.nr87.map NumV.ref) PRE_first_tail_x6_r0_body.kd87.big
  PRE_first_tail_x6_r0_body.kd87.region PRE_first_tail_x6_r0_body.kd87.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin87 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s852.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc87 : Conv.jcleanListB (⟨19928, 17027, 2743633, 3821⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s852 PRE_first_tail_x6_r0_body.cl87 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB87 : noBigRootsP (fun i => !Conv.oldBigB (⟨19928, 17027, 2743633, 3821⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s852.trace PRE_first_tail_x6_r0_body.s852 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm87 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 17000 = true
theorem PRE_first_tail_x6_r0_body.cjcl87 (h : Conv.JClean (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s850) : Conv.JClean (⟨19928, 17027, 2743633, 3821⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s852 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle87)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap87 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd87 a ha)) PRE_first_tail_x6_r0_body.zjc87

end Host.Load.Run.Tpl
end

section -- st87/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st87.bodyLast from PRE_first_tail_x6_r0_body.st87.s4 to PRE_first_tail_x6_r0_body.st87.s5 :
  interpS (step PRE_first_tail_x6_r0_body.st87.F PRE_first_tail_x6_r0_body.st87.s4).run PRE_first_tail_x6_r0_body.st87.S4 = some (PRE_first_tail_x6_r0_body.st87.s5, PRE_first_tail_x6_r0_body.st87.S5)
kernel_rfl PRE_first_tail_x6_r0_body.st87.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st87.s4.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st87.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st87.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st87/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st87.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st87.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st87.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st87.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st87.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st87.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st87.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st87.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st87.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st87.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st87.s0 PRE_first_tail_x6_r0_body.st87.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st87.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st87.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st87.s4 PRE_first_tail_x6_r0_body.st87.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st87/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st87.bodyK0F from PRE_first_tail_x6_r0_body.st87.s0 to PRE_first_tail_x6_r0_body.st87.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st87.F (PRE_first_tail_x6_r0_body.st87.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st87.ks 0).getD 0) PRE_first_tail_x6_r0_body.st87.s0 PRE_first_tail_x6_r0_body.st87.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st87.s1, PRE_first_tail_x6_r0_body.st87.S1)
theorem PRE_first_tail_x6_r0_body.st87.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st87.F (PRE_first_tail_x6_r0_body.st87.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st87.ks 0).getD 0) PRE_first_tail_x6_r0_body.st87.s0 PRE_first_tail_x6_r0_body.st87.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st87.s1, PRE_first_tail_x6_r0_body.st87.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st87.bodyOkLN_ok PRE_first_tail_x6_r0_body.st87.bodyK0F
end Host.Load.Run.Tpl
end

section -- st87/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st87.bodyK1F from PRE_first_tail_x6_r0_body.st87.s1 to PRE_first_tail_x6_r0_body.st87.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st87.F (PRE_first_tail_x6_r0_body.st87.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st87.ks 1).getD 0) PRE_first_tail_x6_r0_body.st87.s1 PRE_first_tail_x6_r0_body.st87.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st87.s2, PRE_first_tail_x6_r0_body.st87.S2)
theorem PRE_first_tail_x6_r0_body.st87.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st87.F (PRE_first_tail_x6_r0_body.st87.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st87.ks 1).getD 0) PRE_first_tail_x6_r0_body.st87.s1 PRE_first_tail_x6_r0_body.st87.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st87.s2, PRE_first_tail_x6_r0_body.st87.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st87.bodyOkLN_ok PRE_first_tail_x6_r0_body.st87.bodyK1F
end Host.Load.Run.Tpl
end

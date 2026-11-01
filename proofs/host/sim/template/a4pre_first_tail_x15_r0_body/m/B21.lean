import host.sim.template.a4pre_first_tail_x15_r0_body.m.B20
import host.sim.template.BootEq
import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B00
import host.sim.conv.Compact
import host.sim.native.RebigR
import host.sim.template.Sigma
import host.sim.template.NShiftGen
import host.sim.stage.Mlx
import host.sim.conv.Closed
import host.sim.conv.NClean
import host.sim.conv.CompactFull
import host.sim.template.FootGen
import host.sim.template.a4pre_first_tail_x15_r0_body.States
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
import host.sim.conv.CallPieces
import host.sim.template.NShiftOf
import host.sim.template.FullShiftGen
import host.sim.template.CallGen
import host.sim.template.EndGen
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.StageRel
import host.sim.compose.a4b.VWFramesDefs
import host.sim.template.FullOk
import host.sim.template.FastOk

section -- st54/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st54.bodyK1F from PRE_first_tail_x15_r0_body.st54.s1 to PRE_first_tail_x15_r0_body.st54.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st54.F (PRE_first_tail_x15_r0_body.st54.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st54.ks 1).getD 0) PRE_first_tail_x15_r0_body.st54.s1 PRE_first_tail_x15_r0_body.st54.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st54.s2, PRE_first_tail_x15_r0_body.st54.S2)
theorem PRE_first_tail_x15_r0_body.st54.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st54.F (PRE_first_tail_x15_r0_body.st54.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st54.ks 1).getD 0) PRE_first_tail_x15_r0_body.st54.s1 PRE_first_tail_x15_r0_body.st54.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st54.s2, PRE_first_tail_x15_r0_body.st54.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st54.bodyOkLN_ok PRE_first_tail_x15_r0_body.st54.bodyK1F
end Host.Load.Run.Tpl
end

section -- st54/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st54.bodyK2F from PRE_first_tail_x15_r0_body.st54.s2 to PRE_first_tail_x15_r0_body.st54.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st54.F (PRE_first_tail_x15_r0_body.st54.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st54.ks 2).getD 0) PRE_first_tail_x15_r0_body.st54.s2 PRE_first_tail_x15_r0_body.st54.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st54.s3, PRE_first_tail_x15_r0_body.st54.S3)
theorem PRE_first_tail_x15_r0_body.st54.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st54.F (PRE_first_tail_x15_r0_body.st54.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st54.ks 2).getD 0) PRE_first_tail_x15_r0_body.st54.s2 PRE_first_tail_x15_r0_body.st54.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st54.s3, PRE_first_tail_x15_r0_body.st54.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st54.bodyOkLN_ok PRE_first_tail_x15_r0_body.st54.bodyK2F
end Host.Load.Run.Tpl
end

section -- st54/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st54.bodyK3F from PRE_first_tail_x15_r0_body.st54.s3 to PRE_first_tail_x15_r0_body.st54.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st54.F (PRE_first_tail_x15_r0_body.st54.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st54.ks 3).getD 0) PRE_first_tail_x15_r0_body.st54.s3 PRE_first_tail_x15_r0_body.st54.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st54.s4, PRE_first_tail_x15_r0_body.st54.S4)
theorem PRE_first_tail_x15_r0_body.st54.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st54.F (PRE_first_tail_x15_r0_body.st54.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st54.ks 3).getD 0) PRE_first_tail_x15_r0_body.st54.s3 PRE_first_tail_x15_r0_body.st54.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st54.s4, PRE_first_tail_x15_r0_body.st54.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st54.bodyOkLN_ok PRE_first_tail_x15_r0_body.st54.bodyK3F
end Host.Load.Run.Tpl
end

section -- st54/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st54.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st54.F (PRE_first_tail_x15_r0_body.st54.bodyOkL bytes rows) 11334 PRE_first_tail_x15_r0_body.st54.s0 PRE_first_tail_x15_r0_body.st54.S0 = some (PRE_first_tail_x15_r0_body.st54.s4, PRE_first_tail_x15_r0_body.st54.S4) :=
  runOk_trans PRE_first_tail_x15_r0_body.st54.F (PRE_first_tail_x15_r0_body.st54.bodyOkL bytes rows) ((((nth? PRE_first_tail_x15_r0_body.st54.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st54.ks 1).getD 0)) + ((nth? PRE_first_tail_x15_r0_body.st54.ks 2).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st54.ks 3).getD 0) PRE_first_tail_x15_r0_body.st54.s0 PRE_first_tail_x15_r0_body.st54.s3 PRE_first_tail_x15_r0_body.st54.s4 PRE_first_tail_x15_r0_body.st54.S0 PRE_first_tail_x15_r0_body.st54.S3 PRE_first_tail_x15_r0_body.st54.S4 (runOk_trans PRE_first_tail_x15_r0_body.st54.F (PRE_first_tail_x15_r0_body.st54.bodyOkL bytes rows) (((nth? PRE_first_tail_x15_r0_body.st54.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st54.ks 1).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st54.ks 2).getD 0) PRE_first_tail_x15_r0_body.st54.s0 PRE_first_tail_x15_r0_body.st54.s2 PRE_first_tail_x15_r0_body.st54.s3 PRE_first_tail_x15_r0_body.st54.S0 PRE_first_tail_x15_r0_body.st54.S2 PRE_first_tail_x15_r0_body.st54.S3 (runOk_trans PRE_first_tail_x15_r0_body.st54.F (PRE_first_tail_x15_r0_body.st54.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st54.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st54.ks 1).getD 0) PRE_first_tail_x15_r0_body.st54.s0 PRE_first_tail_x15_r0_body.st54.s1 PRE_first_tail_x15_r0_body.st54.s2 PRE_first_tail_x15_r0_body.st54.S0 PRE_first_tail_x15_r0_body.st54.S1 PRE_first_tail_x15_r0_body.st54.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st54.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st54.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st54.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st54.bodyK3 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st54.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st54.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st54.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st54.F (PRE_first_tail_x15_r0_body.st54.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st54.s0
  S0 := PRE_first_tail_x15_r0_body.st54.S0
  s1 := PRE_first_tail_x15_r0_body.st54.s4
  S1 := PRE_first_tail_x15_r0_body.st54.S4
  s2 := PRE_first_tail_x15_r0_body.st54.s5
  S2 := PRE_first_tail_x15_r0_body.st54.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st54.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st54.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st54.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st54.bodyHalt
  last := PRE_first_tail_x15_r0_body.st54.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st54.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC55
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 55 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s544` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa55` into the merged state
`PRE_first_tail_x15_r0_body.s543`. -/

def PRE_first_tail_x15_r0_body.pl55 : List Nat := []
def PRE_first_tail_x15_r0_body.nr55 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd55 : RData :=
  ⟨2718139, 2718141, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19290, 19290, 16392, 16392, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa55 : Map :=
  Conv.Map.compact 2718139 2718141 2432 PRE_first_tail_x15_r0_body.pl55 (PRE_first_tail_x15_r0_body.nr55.map NumV.ref) PRE_first_tail_x15_r0_body.kd55.big
    PRE_first_tail_x15_r0_body.kd55.region PRE_first_tail_x15_r0_body.kd55.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws55 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs55 : List SymE := PRE_first_tail_x15_r0_body.nr55.map fun r => (nth? PRE_first_tail_x15_r0_body.S543.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta55 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws55 PRE_first_tail_x15_r0_body.crs55
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB55 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab55 : PRE_first_tail_x15_r0_body.S544.tab = PRE_first_tail_x15_r0_body.S542.tab ++ PRE_first_tail_x15_r0_body.cws55.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace55 : PRE_first_tail_x15_r0_body.s544.trace = PRE_first_tail_x15_r0_body.s542.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext55 : PRE_first_tail_x15_r0_body.s544.next = 2718139
kernel_rfl PRE_first_tail_x15_r0_body.ccounters55 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi).mlx.nnext) = (19290, 16392)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue55 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s543.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa55.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp55 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi).mlx.tokens.all (bSN 2432) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean55 : Conv.cleanListB 19290 131072 (fun r => Nat.ble 77160 r) PRE_first_tail_x15_r0_body.s544
    (PRE_first_tail_x15_r0_body.wrB55 ++ (List.range 0).map (2718139 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs55 : bigsOutB 19290 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK55
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl55`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl55 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo55 : List Nat := []
def PRE_first_tail_x15_r0_body.cln55 : List Nat := []
def PRE_first_tail_x15_r0_body.cli55 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap55 : PRE_first_tail_x15_r0_body.s544.heap = Stage.setAll PRE_first_tail_x15_r0_body.s542.heap (PRE_first_tail_x15_r0_body.cl55.filterMap fun a => (PRE_first_tail_x15_r0_body.s544.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe55 : Nat.ble PRE_first_tail_x15_r0_body.s542.next PRE_first_tail_x15_r0_body.s544.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP55 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s542 PRE_first_tail_x15_r0_body.s544 PRE_first_tail_x15_r0_body.cl55 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp55 : Conv.suppListB PRE_first_tail_x15_r0_body.s544 2432 PRE_first_tail_x15_r0_body.cl55 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound55 : Conv.boundListB PRE_first_tail_x15_r0_body.s544 PRE_first_tail_x15_r0_body.cl55 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK55 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln55.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK55 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo55.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK55 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli55.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst55 : Conv.sstListB 2432 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi).mlx PRE_first_tail_x15_r0_body.cln55 PRE_first_tail_x15_r0_body.clo55 PRE_first_tail_x15_r0_body.cli55 = true

end Host.Load.Run.Tpl
end

section -- SiteCl55
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA55 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo55.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd55 : (PRE_first_tail_x15_r0_body.clo55 ++ PRE_first_tail_x15_r0_body.cln55 ++ PRE_first_tail_x15_r0_body.cli55).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle55 : Conv.Cnt.leB (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck55 : Conv.ncleanListB (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi).mlx PRE_first_tail_x15_r0_body.clo55 PRE_first_tail_x15_r0_body.cln55 PRE_first_tail_x15_r0_body.cli55 = true
theorem PRE_first_tail_x15_r0_body.cncl55 (h : Conv.NClean (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx) : Conv.NClean (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle55 PRE_first_tail_x15_r0_body.ckA55 PRE_first_tail_x15_r0_body.cobjsK55 PRE_first_tail_x15_r0_body.cnodesK55 PRE_first_tail_x15_r0_body.citemsK55 PRE_first_tail_x15_r0_body.cbd55 PRE_first_tail_x15_r0_body.cck55

end Host.Load.Run.Tpl
end

section -- SiteS55
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 55 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc55 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P55 : LoadP := PRE_first_tail_x15_r0_body.Pc55.raise 16392
kernel_rfl PRE_first_tail_x15_r0_body.craise55 : Nat.ble PRE_first_tail_x15_r0_body.Pc55.N0 16392 = true
theorem PRE_first_tail_x15_r0_body.raised55 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc55 PRE_first_tail_x15_r0_body.P55 :=
  .inr ⟨16392, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise55, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_55 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_55 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s543.ffi)
def PRE_first_tail_x15_r0_body.khinv55 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv55 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS55 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS55 : List Nat := List.range' 16392 0
def PRE_first_tail_x15_r0_body.ciS55 : List Nat := [] ++ List.range' 16392 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh055 : PRE_first_tail_x15_r0_body.kd55.nh0 = PRE_first_tail_x15_r0_body.cx0_55.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh155 : PRE_first_tail_x15_r0_body.kd55.nh1 = PRE_first_tail_x15_r0_body.cx1_55.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn055 : PRE_first_tail_x15_r0_body.kd55.nn0 = PRE_first_tail_x15_r0_body.cx0_55.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn155 : PRE_first_tail_x15_r0_body.kd55.nn1 = PRE_first_tail_x15_r0_body.cx1_55.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo55 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P55.lo && Nat.ble PRE_first_tail_x15_r0_body.P55.lo PRE_first_tail_x15_r0_body.cx0_55.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P55.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P55.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt55 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_55.mlx.next PRE_first_tail_x15_r0_body.cx1_55.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_55.mlx.nnext PRE_first_tail_x15_r0_body.cx1_55.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband55 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P55.NL && Nat.ble PRE_first_tail_x15_r0_body.P55.NL PRE_first_tail_x15_r0_body.P55.N0 && Nat.ble PRE_first_tail_x15_r0_body.P55.N0 PRE_first_tail_x15_r0_body.cx0_55.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow55 : PRE_first_tail_x15_r0_body.kd55.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren55 : checkRenG PRE_first_tail_x15_r0_body.kd55.hnd PRE_first_tail_x15_r0_body.khinv55 (phB PRE_first_tail_x15_r0_body.cx0_55.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband55 : PRE_first_tail_x15_r0_body.kd55.checkBand PRE_first_tail_x15_r0_body.P55.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos55 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd55.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren55 : checkRenG PRE_first_tail_x15_r0_body.kd55.node PRE_first_tail_x15_r0_body.kninv55 (pnB PRE_first_tail_x15_r0_body.cx0_55.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow55 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd55.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P55.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd55.nodeF j) PRE_first_tail_x15_r0_body.cx1_55.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a55 : PRE_first_tail_x15_r0_body.cx0_55.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b55 : PRE_first_tail_x15_r0_body.cx0_55.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok155 : PRE_first_tail_x15_r0_body.cx1_55.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend55 : PRE_first_tail_x15_r0_body.cx1_55.mlx.pending = PRE_first_tail_x15_r0_body.cx0_55.mlx.pending.map PRE_first_tail_x15_r0_body.kappa55.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh55 : PRE_first_tail_x15_r0_body.cx1_55.mlx.errh = PRE_first_tail_x15_r0_body.cx0_55.mlx.errh.map PRE_first_tail_x15_r0_body.kappa55.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles55 : PRE_first_tail_x15_r0_body.cx1_55.mlx.files = PRE_first_tail_x15_r0_body.cx0_55.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch55 : PRE_first_tail_x15_r0_body.cx1_55.mlx.arch = PRE_first_tail_x15_r0_body.cx0_55.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes55 : PRE_first_tail_x15_r0_body.cx1_55.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_55.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired55 : PRE_first_tail_x15_r0_body.cx1_55.mlx.wired = PRE_first_tail_x15_r0_body.cx0_55.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost55 : PRE_first_tail_x15_r0_body.cx1_55.host = PRE_first_tail_x15_r0_body.cx0_55.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd55`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn055 : PRE_first_tail_x15_r0_body.kd55.n0 = 2718139
kernel_rfl PRE_first_tail_x15_r0_body.ckn155 : PRE_first_tail_x15_r0_body.kd55.n1 = 2718141
kernel_rfl PRE_first_tail_x15_r0_body.ckheap55 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd55.heap).all (fun x => Nat.ble 2718139 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl55 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd55.heap.get (2718139 + j) = nth? PRE_first_tail_x15_r0_body.pl55 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja55 : Nat.ble 2718139 2718139 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn55 : Nat.ble 2432 2432 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD55 : Nat.ble 2718139 PRE_first_tail_x15_r0_body.kd55.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn55 : Nat.ble 19290 PRE_first_tail_x15_r0_body.kd55.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn55 : Nat.ble 16392 PRE_first_tail_x15_r0_body.kd55.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb55 : Nat.ble 19290 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap55 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd55.heap).all (Nat.ble (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd55 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd55.hnd).all (Nat.ble (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode55 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd55.node).all (Nat.ble (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix55 : Conv.FixOld (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa55 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja55) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn55) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD55) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn55) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn55) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb55) PRE_first_tail_x15_r0_body.fheap55 PRE_first_tail_x15_r0_body.fhnd55 PRE_first_tail_x15_r0_body.fnode55
kernel_rfl PRE_first_tail_x15_r0_body.fcxn55 : (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn55 : (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle055 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_55.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_55.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk55 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd55.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A55 : PRE_first_tail_x15_r0_body.cx1_55.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS55.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_55.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O55 : PRE_first_tail_x15_r0_body.cx1_55.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS55.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_55.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N55 : PRE_first_tail_x15_r0_body.cx1_55.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS55.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_55.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I55 : PRE_first_tail_x15_r0_body.cx1_55.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS55.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_55.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd55 : (PRE_first_tail_x15_r0_body.clo55 ++ PRE_first_tail_x15_r0_body.cln55 ++ PRE_first_tail_x15_r0_body.cli55 ++ PRE_first_tail_x15_r0_body.cwS55 ++ PRE_first_tail_x15_r0_body.cnS55 ++ PRE_first_tail_x15_r0_body.ciS55).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW55 : PRE_first_tail_x15_r0_body.cwS55.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo55.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI55 : PRE_first_tail_x15_r0_body.ciS55.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli55.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN55 : PRE_first_tail_x15_r0_body.cnS55.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF55 : PRE_first_tail_x15_r0_body.cln55.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh55 : PRE_first_tail_x15_r0_body.clo55.all (handleOK PRE_first_tail_x15_r0_body.kappa55 PRE_first_tail_x15_r0_body.P55.lo PRE_first_tail_x15_r0_body.cx0_55.mlx PRE_first_tail_x15_r0_body.cx1_55.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo55 : PRE_first_tail_x15_r0_body.clo55.map (fun h => PRE_first_tail_x15_r0_body.cx1_55.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa55.handle h)) = PRE_first_tail_x15_r0_body.clo55.map (fun h => (PRE_first_tail_x15_r0_body.cx0_55.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa55.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok55 : PRE_first_tail_x15_r0_body.clo55.all (objOK PRE_first_tail_x15_r0_body.kappa55 PRE_first_tail_x15_r0_body.P55.NL PRE_first_tail_x15_r0_body.cx0_55.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd55 : PRE_first_tail_x15_r0_body.cln55.all (nodeOKF PRE_first_tail_x15_r0_body.kappa55 PRE_first_tail_x15_r0_body.P55 PRE_first_tail_x15_r0_body.cx0_55.mlx PRE_first_tail_x15_r0_body.cx1_55.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp55 : ((PRE_first_tail_x15_r0_body.cln55.filter (fullB PRE_first_tail_x15_r0_body.P55))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_55.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa55.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln55.filter (fullB PRE_first_tail_x15_r0_body.P55))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_55.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa55.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI55 : incrB PRE_first_tail_x15_r0_body.kd55.nodeF (List.range' 16392 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK55 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd55.node).all (fun k => Nat.ble 16392 k && Nat.blt k 16392) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL55 : (PRE_first_tail_x15_r0_body.cln55.filter (Nat.ble PRE_first_tail_x15_r0_body.P55.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd55.nodeF i) && (Nat.blt i 16392 || Nat.ble PRE_first_tail_x15_r0_body.kd55.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord55 : (PRE_first_tail_x15_r0_body.cln55.filter (Nat.ble PRE_first_tail_x15_r0_body.P55.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd55.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd55.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd55.nodeF j) (PRE_first_tail_x15_r0_body.kd55.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow55 PRE_first_tail_x15_r0_body.cnn155 PRE_first_tail_x15_r0_body.fnordI55 PRE_first_tail_x15_r0_body.fnordK55 PRE_first_tail_x15_r0_body.fnordL55
kernel_rfl PRE_first_tail_x15_r0_body.fi55 : PRE_first_tail_x15_r0_body.cli55.all (pnB PRE_first_tail_x15_r0_body.cx0_55.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii55 : PRE_first_tail_x15_r0_body.cli55.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_55.mlx.items.get (PRE_first_tail_x15_r0_body.kappa55.node k) = (PRE_first_tail_x15_r0_body.cx0_55.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa55.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot55 (clean : Conv.NClean (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P55.NL) (cl : SSt (· < 2432) PRE_first_tail_x15_r0_body.cx0_55.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P55 2432 PRE_first_tail_x15_r0_body.kappa55 PRE_first_tail_x15_r0_body.kd55 PRE_first_tail_x15_r0_body.khinv55 PRE_first_tail_x15_r0_body.kninv55 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx PRE_first_tail_x15_r0_body.cx0_55.mlx PRE_first_tail_x15_r0_body.cx1_55.mlx (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo55 PRE_first_tail_x15_r0_body.cln55 PRE_first_tail_x15_r0_body.cli55 PRE_first_tail_x15_r0_body.cwS55 PRE_first_tail_x15_r0_body.cnS55 PRE_first_tail_x15_r0_body.ciS55 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh055, PRE_first_tail_x15_r0_body.cnh155, PRE_first_tail_x15_r0_body.cnn055, PRE_first_tail_x15_r0_body.cnn155, PRE_first_tail_x15_r0_body.cplo55, PRE_first_tail_x15_r0_body.ccnt55, PRE_first_tail_x15_r0_body.cnband55, PRE_first_tail_x15_r0_body.chbelow55, PRE_first_tail_x15_r0_body.chren55, PRE_first_tail_x15_r0_body.cband55, PRE_first_tail_x15_r0_body.cnh1pos55, PRE_first_tail_x15_r0_body.cnren55, PRE_first_tail_x15_r0_body.cnlow55, PRE_first_tail_x15_r0_body.cabs0a55, PRE_first_tail_x15_r0_body.cabs0b55, PRE_first_tail_x15_r0_body.ctok155, PRE_first_tail_x15_r0_body.cpend55, PRE_first_tail_x15_r0_body.cerrh55, PRE_first_tail_x15_r0_body.cfiles55, PRE_first_tail_x15_r0_body.carch55, PRE_first_tail_x15_r0_body.csizes55, PRE_first_tail_x15_r0_body.cwired55, PRE_first_tail_x15_r0_body.cfix55, clean, PRE_first_tail_x15_r0_body.fcxn55, PRE_first_tail_x15_r0_body.fcnn55, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle055, PRE_first_tail_x15_r0_body.fnk55, PRE_first_tail_x15_r0_body.ckA55, PRE_first_tail_x15_r0_body.cobjsK55, PRE_first_tail_x15_r0_body.cnodesK55, PRE_first_tail_x15_r0_body.citemsK55, PRE_first_tail_x15_r0_body.f1A55, PRE_first_tail_x15_r0_body.f1O55, PRE_first_tail_x15_r0_body.f1N55, PRE_first_tail_x15_r0_body.f1I55, PRE_first_tail_x15_r0_body.fbd55, PRE_first_tail_x15_r0_body.fincW55, PRE_first_tail_x15_r0_body.fincI55, PRE_first_tail_x15_r0_body.fincN55, PRE_first_tail_x15_r0_body.flnF55, PRE_first_tail_x15_r0_body.fh55, PRE_first_tail_x15_r0_body.fo55, PRE_first_tail_x15_r0_body.fok55, PRE_first_tail_x15_r0_body.fnd55, PRE_first_tail_x15_r0_body.fp55, PRE_first_tail_x15_r0_body.fnord55, PRE_first_tail_x15_r0_body.fi55, PRE_first_tail_x15_r0_body.fii55⟩
theorem PRE_first_tail_x15_r0_body.cnshift55 (clean : Conv.NClean (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P55.NL) (cl : SSt (· < 2432) PRE_first_tail_x15_r0_body.cx0_55.mlx) : NShift PRE_first_tail_x15_r0_body.P55 2432 PRE_first_tail_x15_r0_body.kappa55 PRE_first_tail_x15_r0_body.cx0_55 PRE_first_tail_x15_r0_body.cx1_55 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot55 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost55 (compact_a_eq PRE_first_tail_x15_r0_body.ckn055 PRE_first_tail_x15_r0_body.ckn155 PRE_first_tail_x15_r0_body.ckheap55 PRE_first_tail_x15_r0_body.ckpl55)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_55 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s542.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_55 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s542.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_55 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s542.ffi) = some PRE_first_tail_x15_r0_body.fxC_55
kernel_rfl PRE_first_tail_x15_r0_body.okrC_55 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s542.ffi) = some PRE_first_tail_x15_r0_body.krC_55
noncomputable def PRE_first_tail_x15_r0_body.fx0_55 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s544.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_55 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s544.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_55 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s544.ffi) = some PRE_first_tail_x15_r0_body.fx0_55
kernel_rfl PRE_first_tail_x15_r0_body.okr0_55 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s544.ffi) = some PRE_first_tail_x15_r0_body.kr0_55
noncomputable def PRE_first_tail_x15_r0_body.fx1_55 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s543.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_55 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s543.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_55 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s543.ffi) = some PRE_first_tail_x15_r0_body.fx1_55
kernel_rfl PRE_first_tail_x15_r0_body.okr1_55 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s543.ffi) = some PRE_first_tail_x15_r0_body.kr1_55
kernel_rfl PRE_first_tail_x15_r0_body.ff055 : PRE_first_tail_x15_r0_body.fx0_55 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_55 (PRE_first_tail_x15_r0_body.clo55.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_55.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff155 : PRE_first_tail_x15_r0_body.fx1_55 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_55 (PRE_first_tail_x15_r0_body.cwS55.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_55.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck55 : freedLB PRE_first_tail_x15_r0_body.kappa55 PRE_first_tail_x15_r0_body.cx0_55.mlx PRE_first_tail_x15_r0_body.fx0_55 PRE_first_tail_x15_r0_body.fx1_55 PRE_first_tail_x15_r0_body.clo55 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf055 : PRE_first_tail_x15_r0_body.kr0_55.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_55.flags (PRE_first_tail_x15_r0_body.clo55.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_55.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt055 : PRE_first_tail_x15_r0_body.kr0_55.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_55.targs (PRE_first_tail_x15_r0_body.clo55.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_55.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf155 : PRE_first_tail_x15_r0_body.kr1_55.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_55.flags (PRE_first_tail_x15_r0_body.cwS55.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_55.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt155 : PRE_first_tail_x15_r0_body.kr1_55.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_55.targs (PRE_first_tail_x15_r0_body.cwS55.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_55.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck55 : krecLB PRE_first_tail_x15_r0_body.kappa55 2432 PRE_first_tail_x15_r0_body.cx0_55.mlx PRE_first_tail_x15_r0_body.kr0_55 PRE_first_tail_x15_r0_body.kr1_55 PRE_first_tail_x15_r0_body.clo55 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn55 : Nat.ble 2432 2432 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge55 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s543.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s544.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR55 : pendRegB PRE_first_tail_x15_r0_body.kappa55 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe55 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s543.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift55 (clean : Conv.NClean (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P55.NL) (cl : SSt (· < 2432) PRE_first_tail_x15_r0_body.cx0_55.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_55.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_55.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_55.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_55.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P55 2432 PRE_first_tail_x15_r0_body.kappa55 PRE_first_tail_x15_r0_body.s544.ffi PRE_first_tail_x15_r0_body.s543.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift55 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue55, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp55 t ht),
    PRE_first_tail_x15_r0_body.cbridge55,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s544.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s543.ffi) (PRE_first_tail_x15_r0_body.cfoot55 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_55 PRE_first_tail_x15_r0_body.ofx1_55 hobjC PRE_first_tail_x15_r0_body.ff055 PRE_first_tail_x15_r0_body.ff155 PRE_first_tail_x15_r0_body.ffck55,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s544.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s543.ffi) (PRE_first_tail_x15_r0_body.cfoot55 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_55 PRE_first_tail_x15_r0_body.okr1_55 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn55) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf055 PRE_first_tail_x15_r0_body.fkt055 PRE_first_tail_x15_r0_body.fkf155 PRE_first_tail_x15_r0_body.fkt155 PRE_first_tail_x15_r0_body.fkck55,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh055 PRE_first_tail_x15_r0_body.cnh155 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe55) PRE_first_tail_x15_r0_body.cpendR55⟩

end Host.Load.Run.Tpl
end

section -- st55/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st55 0
host_stream_state PRE_first_tail_x15_r0_body.st55 1
host_stream_state PRE_first_tail_x15_r0_body.st55 2
end Host.Load.Run.Tpl
end

section -- Site55
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 55 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g55__g56` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s542`, the merged state `PRE_first_tail_x15_r0_body.s543`,
the site template `PRE_first_tail_x15_r0_body.st55` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s544`: the merge.
The footprint's facts are in `SiteF55`, the compaction's in `SiteC55`, `SiteK55`, `SiteNa55`, `SiteNb55`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso55 : PRE_first_tail_x15_r0_body.st55.s0 = { PRE_first_tail_x15_r0_body.s542 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs55 : List Frame := PRE_first_tail_x15_r0_body.s542.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_55 : PRE_first_tail_x15_r0_body.S542.tab.length = 2432
kernel_rfl PRE_first_tail_x15_r0_body.tab0_55 : PRE_first_tail_x15_r0_body.st55.S0.tab = PRE_first_tail_x15_r0_body.S542.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws55 : List Nat := [1965, 1966]
kernel_rfl PRE_first_tail_x15_r0_body.fresh55 : (PRE_first_tail_x15_r0_body.S542.tab.all fun e => PRE_first_tail_x15_r0_body.ws55.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S542.oracle.all fun q => PRE_first_tail_x15_r0_body.ws55.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab55 : PRE_first_tail_x15_r0_body.S543.tab = PRE_first_tail_x15_r0_body.S542.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws55
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen55 : PRE_first_tail_x15_r0_body.st55.S2.tab.length - PRE_first_tail_x15_r0_body.st55.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged55`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap55 : PRE_first_tail_x15_r0_body.s543.heap = PRE_first_tail_x15_r0_body.st55.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext55 : PRE_first_tail_x15_r0_body.s543.next = PRE_first_tail_x15_r0_body.st55.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl55 : PRE_first_tail_x15_r0_body.s543.ctl = PRE_first_tail_x15_r0_body.st55.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack55 : PRE_first_tail_x15_r0_body.s543.stack = PRE_first_tail_x15_r0_body.st55.s2.stack ++ PRE_first_tail_x15_r0_body.s542.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs55 : PRE_first_tail_x15_r0_body.s543.jobs = PRE_first_tail_x15_r0_body.st55.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi55 : PRE_first_tail_x15_r0_body.s543.ffi = PRE_first_tail_x15_r0_body.st55.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace55 : PRE_first_tail_x15_r0_body.s543.trace = PRE_first_tail_x15_r0_body.st55.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores55 : PRE_first_tail_x15_r0_body.s543.stores = PRE_first_tail_x15_r0_body.st55.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD55
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 55 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived55 : PRE_first_tail_x15_r0_body.nr55.map (fun r => nth? PRE_first_tail_x15_r0_body.st55.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo55 : PRE_first_tail_x15_r0_body.nr55.all (Nat.ble 2432) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj55 : PRE_first_tail_x15_r0_body.cws55.all (fun c => !PRE_first_tail_x15_r0_body.ws55.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ55 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws55 PRE_first_tail_x15_r0_body.crs55 PRE_first_tail_x15_r0_body.ws55

end Host.Load.Run.Tpl
end

section -- st55/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st55`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st55.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st55.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st55.s2.heap PRE_first_tail_x15_r0_body.st55.wrR ++ freshOf PRE_first_tail_x15_r0_body.st55.s2.heap PRE_first_tail_x15_r0_body.st55.s0.next PRE_first_tail_x15_r0_body.st55.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st55.wr : List Nat := PRE_first_tail_x15_r0_body.st55.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st55.heapFoot : PRE_first_tail_x15_r0_body.st55.s2.heap = setAll PRE_first_tail_x15_r0_body.st55.s0.heap PRE_first_tail_x15_r0_body.st55.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st55.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st55.s0.next PRE_first_tail_x15_r0_body.st55.s2.next = true
theorem PRE_first_tail_x15_r0_body.st55.grows : PRE_first_tail_x15_r0_body.st55.s0.next ≤ PRE_first_tail_x15_r0_body.st55.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st55.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st55.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st55.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st55.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st55.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st55.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st55.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st55.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st55.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st55.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st55.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st55.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st55.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st55.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st55.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st55.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st55.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st55.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st55.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st55.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st55.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st55.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st55.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st55.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st55.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st55.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st55.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st55.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st55.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st55.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st55.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st55.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF55
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 55 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB55 : nodupT PRE_first_tail_x15_r0_body.st55.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup55 : PRE_first_tail_x15_r0_body.st55.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB55).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB55 : PRE_first_tail_x15_r0_body.st55.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound55 : ∀ b ∈ PRE_first_tail_x15_r0_body.st55.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB55 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr55 := PRE_first_tail_x15_r0_body.st55.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq55 : PRE_first_tail_x15_r0_body.st55.s2.trace = PRE_first_tail_x15_r0_body.trFr55 ++ PRE_first_tail_x15_r0_body.st55.s0.trace
theorem PRE_first_tail_x15_r0_body.trace55 : ∃ fr, PRE_first_tail_x15_r0_body.st55.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st55.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq55⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide55 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB55 : (PRE_first_tail_x15_r0_body.wide55.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st55.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix55 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide55, WFix Map.id (Present PRE_first_tail_x15_r0_body.st55.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB55 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL55
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 55 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s543`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO55 : PRE_first_tail_x15_r0_body.st55.S0.oracle = PRE_first_tail_x15_r0_body.st55.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B55 : PRE_first_tail_x15_r0_body.st55.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st55.s0.next || (PRE_first_tail_x15_r0_body.st55.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot55 : Conv.StageFoot PRE_first_tail_x15_r0_body.st55.wr PRE_first_tail_x15_r0_body.st55.s0 PRE_first_tail_x15_r0_body.st55.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st55.heapFoot PRE_first_tail_x15_r0_body.wrNodup55 PRE_first_tail_x15_r0_body.wrBound55 PRE_first_tail_x15_r0_body.wr0B55 PRE_first_tail_x15_r0_body.st55.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged55 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st55.F.S → PRE_first_tail_x15_r0_body.st55.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st55.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st55.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs55 PRE_first_tail_x15_r0_body.st55.wr PRE_first_tail_x15_r0_body.s542 PRE_first_tail_x15_r0_body.st55.s2 PRE_first_tail_x15_r0_body.st55.s0
      PRE_first_tail_x15_r0_body.st55.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st55.F FR W stk M ν K PRE_first_tail_x15_r0_body.s543 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso55 PRE_first_tail_x15_r0_body.stFoot55 PRE_first_tail_x15_r0_body.wrNodup55 PRE_first_tail_x15_r0_body.wrBound55 PRE_first_tail_x15_r0_body.trace55 PRE_first_tail_x15_r0_body.mheap55
    PRE_first_tail_x15_r0_body.mnext55 PRE_first_tail_x15_r0_body.mctl55 PRE_first_tail_x15_r0_body.mstack55 PRE_first_tail_x15_r0_body.mjobs55 PRE_first_tail_x15_r0_body.mffi55 PRE_first_tail_x15_r0_body.mtrace55 PRE_first_tail_x15_r0_body.mstores55 h

def PRE_first_tail_x15_r0_body.arrEl55_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE55_2665 : arrOf PRE_first_tail_x15_r0_body.s543 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl55_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA55_2665 : isArrB PRE_first_tail_x15_r0_body.s543 2665 = true
theorem PRE_first_tail_x15_r0_body.arr55_2665 : ∃ o, PRE_first_tail_x15_r0_body.s543.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl55_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE55_2665 PRE_first_tail_x15_r0_body.arrA55_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN55_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl55_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR55_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl55_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN55_2665

def PRE_first_tail_x15_r0_body.arrEl55_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE55_2673467 : arrOf PRE_first_tail_x15_r0_body.s543 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl55_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA55_2673467 : isArrB PRE_first_tail_x15_r0_body.s543 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr55_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s543.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl55_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE55_2673467 PRE_first_tail_x15_r0_body.arrA55_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN55_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl55_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR55_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl55_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN55_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k55 : isArrB PRE_first_tail_x15_r0_body.s543 4910 = false
theorem PRE_first_tail_x15_r0_body.keep55 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s543 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k55 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr55_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl55_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ55
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 55 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s542`, the merged
state `PRE_first_tail_x15_r0_body.s543`, the canonical state `PRE_first_tail_x15_r0_body.s544`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl55 : PRE_first_tail_x15_r0_body.pl55.all (Nat.ble PRE_first_tail_x15_r0_body.s542.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd55 : nodupT PRE_first_tail_x15_r0_body.pl55 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn155 : Nat.ble PRE_first_tail_x15_r0_body.s542.next 2718141 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst55 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s542.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn55 : PRE_first_tail_x15_r0_body.s544.next = PRE_first_tail_x15_r0_body.s542.next + PRE_first_tail_x15_r0_body.pl55.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn55 : PRE_first_tail_x15_r0_body.s543.next = 2718141
kernel_rfl PRE_first_tail_x15_r0_body.zgrow55 : Nat.ble PRE_first_tail_x15_r0_body.s544.next PRE_first_tail_x15_r0_body.s543.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh55 : PRE_first_tail_x15_r0_body.S542.tab.all (fun e => PRE_first_tail_x15_r0_body.cws55.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd55 : nodupT PRE_first_tail_x15_r0_body.cws55 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi55 : PRE_first_tail_x15_r0_body.nr55.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S543.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt55 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s542.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg55_2665 : PRE_first_tail_x15_r0_body.s544.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s544 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk55_2665 : (objOf PRE_first_tail_x15_r0_body.s544 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm55_2665 : PRE_first_tail_x15_r0_body.s543.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa55.obj (objOf PRE_first_tail_x15_r0_body.s544 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s543 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg55_2673467 : PRE_first_tail_x15_r0_body.s544.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s544 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk55_2673467 : (objOf PRE_first_tail_x15_r0_body.s544 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm55_2673467 : PRE_first_tail_x15_r0_body.s543.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa55.obj (objOf PRE_first_tail_x15_r0_body.s544 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s543 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw55_4910 : (PRE_first_tail_x15_r0_body.s544.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw55_2673472 : (PRE_first_tail_x15_r0_body.s544.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw55_2673473 : (PRE_first_tail_x15_r0_body.s544.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd55 : PRE_first_tail_x15_r0_body.cl55.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr55 : PRE_first_tail_x15_r0_body.st55.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s542.next || PRE_first_tail_x15_r0_body.cl55.contains b) = true
def PRE_first_tail_x15_r0_body.zl55 : List Nat := PRE_first_tail_x15_r0_body.cl55.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE55 : PRE_first_tail_x15_r0_body.zl55.map (fun a => PRE_first_tail_x15_r0_body.s543.heap.get (PRE_first_tail_x15_r0_body.kappa55.a a)) = PRE_first_tail_x15_r0_body.zl55.map (fun a => (PRE_first_tail_x15_r0_body.s544.heap.get a).map PRE_first_tail_x15_r0_body.kappa55.hobj)
theorem PRE_first_tail_x15_r0_body.zimg55 : HeapImg PRE_first_tail_x15_r0_body.kappa55 PRE_first_tail_x15_r0_body.s544 PRE_first_tail_x15_r0_body.s543 PRE_first_tail_x15_r0_body.zl55 := PRE_first_tail_x15_r0_body.zimgE55
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl55 : PRE_first_tail_x15_r0_body.s543.ctl = PRE_first_tail_x15_r0_body.kappa55.ctl PRE_first_tail_x15_r0_body.s544.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack55 : PRE_first_tail_x15_r0_body.s543.stack = PRE_first_tail_x15_r0_body.s544.stack.map PRE_first_tail_x15_r0_body.kappa55.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs55 : PRE_first_tail_x15_r0_body.s543.jobs = PRE_first_tail_x15_r0_body.s544.jobs.map PRE_first_tail_x15_r0_body.kappa55.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores55 : PRE_first_tail_x15_r0_body.s543.stores = PRE_first_tail_x15_r0_body.kappa55.stores PRE_first_tail_x15_r0_body.s544.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots55 : checkRootsSupp PRE_first_tail_x15_r0_body.s544 2432 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC55 : PRE_first_tail_x15_r0_body.S542.tab.length + PRE_first_tail_x15_r0_body.cws55.length = 2432
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap55 : PRE_first_tail_x15_r0_body.kappa55 = Conv.Map.compact PRE_first_tail_x15_r0_body.s542.next 2718141 PRE_first_tail_x15_r0_body.S542.tab.length PRE_first_tail_x15_r0_body.pl55 (PRE_first_tail_x15_r0_body.nr55.map NumV.ref) PRE_first_tail_x15_r0_body.kd55.big
  PRE_first_tail_x15_r0_body.kd55.region PRE_first_tail_x15_r0_body.kd55.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin55 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s544.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc55 : Conv.jcleanListB (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s544 PRE_first_tail_x15_r0_body.cl55 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB55 : noBigRootsP (fun i => !Conv.oldBigB (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s544.trace PRE_first_tail_x15_r0_body.s544 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm55 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16392 = true
theorem PRE_first_tail_x15_r0_body.cjcl55 (h : Conv.JClean (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s542) : Conv.JClean (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s544 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle55)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap55 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd55 a ha)) PRE_first_tail_x15_r0_body.zjc55

end Host.Load.Run.Tpl
end

section -- st55/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st55.bodyLast from PRE_first_tail_x15_r0_body.st55.s1 to PRE_first_tail_x15_r0_body.st55.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st55.F PRE_first_tail_x15_r0_body.st55.s1).run PRE_first_tail_x15_r0_body.st55.S1 = some (PRE_first_tail_x15_r0_body.st55.s2, PRE_first_tail_x15_r0_body.st55.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st55.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st55.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st55.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st55.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st55/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st55.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st55.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st55.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st55.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st55.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st55.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st55.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st55.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st55.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st55.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st55.s0 PRE_first_tail_x15_r0_body.st55.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st55.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st55.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st55.s1 PRE_first_tail_x15_r0_body.st55.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st55/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st55.bodyK0F from PRE_first_tail_x15_r0_body.st55.s0 to PRE_first_tail_x15_r0_body.st55.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st55.F (PRE_first_tail_x15_r0_body.st55.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st55.ks 0).getD 0) PRE_first_tail_x15_r0_body.st55.s0 PRE_first_tail_x15_r0_body.st55.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st55.s1, PRE_first_tail_x15_r0_body.st55.S1)
theorem PRE_first_tail_x15_r0_body.st55.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st55.F (PRE_first_tail_x15_r0_body.st55.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st55.ks 0).getD 0) PRE_first_tail_x15_r0_body.st55.s0 PRE_first_tail_x15_r0_body.st55.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st55.s1, PRE_first_tail_x15_r0_body.st55.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st55.bodyOkLN_ok PRE_first_tail_x15_r0_body.st55.bodyK0F
end Host.Load.Run.Tpl
end

section -- st55/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st55.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st55.F (PRE_first_tail_x15_r0_body.st55.bodyOkL bytes rows) 27 PRE_first_tail_x15_r0_body.st55.s0 PRE_first_tail_x15_r0_body.st55.S0 = some (PRE_first_tail_x15_r0_body.st55.s1, PRE_first_tail_x15_r0_body.st55.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st55.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st55.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st55.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st55.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st55.F (PRE_first_tail_x15_r0_body.st55.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st55.s0
  S0 := PRE_first_tail_x15_r0_body.st55.S0
  s1 := PRE_first_tail_x15_r0_body.st55.s1
  S1 := PRE_first_tail_x15_r0_body.st55.S1
  s2 := PRE_first_tail_x15_r0_body.st55.s2
  S2 := PRE_first_tail_x15_r0_body.st55.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st55.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st55.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st55.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st55.bodyHalt
  last := PRE_first_tail_x15_r0_body.st55.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st55.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC56
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 56 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s548` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa56` into the merged state
`PRE_first_tail_x15_r0_body.s547`. -/

def PRE_first_tail_x15_r0_body.pl56 : List Nat := [2718446]
def PRE_first_tail_x15_r0_body.nr56 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd56 : RData :=
  ⟨2718428, 2718447, Stage.setAll PTrie.nil [(2718427, 2718446)], Stage.setAll PTrie.nil [],
   19297, 19297, 16396, 16396, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa56 : Map :=
  Conv.Map.compact 2718427 2718447 2449 PRE_first_tail_x15_r0_body.pl56 (PRE_first_tail_x15_r0_body.nr56.map NumV.ref) PRE_first_tail_x15_r0_body.kd56.big
    PRE_first_tail_x15_r0_body.kd56.region PRE_first_tail_x15_r0_body.kd56.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws56 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs56 : List SymE := PRE_first_tail_x15_r0_body.nr56.map fun r => (nth? PRE_first_tail_x15_r0_body.S547.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta56 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws56 PRE_first_tail_x15_r0_body.crs56
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB56 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab56 : PRE_first_tail_x15_r0_body.S548.tab = PRE_first_tail_x15_r0_body.S546.tab ++ PRE_first_tail_x15_r0_body.cws56.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace56 : PRE_first_tail_x15_r0_body.s548.trace = PRE_first_tail_x15_r0_body.s546.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext56 : PRE_first_tail_x15_r0_body.s548.next = 2718428
kernel_rfl PRE_first_tail_x15_r0_body.ccounters56 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx.nnext) = (19297, 16396)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue56 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s547.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa56.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp56 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx.tokens.all (bSN 2449) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean56 : Conv.cleanListB 19297 131072 (fun r => Nat.ble 77188 r) PRE_first_tail_x15_r0_body.s548
    (PRE_first_tail_x15_r0_body.wrB56 ++ (List.range 1).map (2718427 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs56 : bigsOutB 19297 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK56
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl56`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl56 : List Nat := [2665, 2673467, 2718427]
def PRE_first_tail_x15_r0_body.clo56 : List Nat := []
def PRE_first_tail_x15_r0_body.cln56 : List Nat := []
def PRE_first_tail_x15_r0_body.cli56 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap56 : PRE_first_tail_x15_r0_body.s548.heap = Stage.setAll PRE_first_tail_x15_r0_body.s546.heap (PRE_first_tail_x15_r0_body.cl56.filterMap fun a => (PRE_first_tail_x15_r0_body.s548.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe56 : Nat.ble PRE_first_tail_x15_r0_body.s546.next PRE_first_tail_x15_r0_body.s548.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP56 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s546 PRE_first_tail_x15_r0_body.s548 PRE_first_tail_x15_r0_body.cl56 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp56 : Conv.suppListB PRE_first_tail_x15_r0_body.s548 2449 PRE_first_tail_x15_r0_body.cl56 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound56 : Conv.boundListB PRE_first_tail_x15_r0_body.s548 PRE_first_tail_x15_r0_body.cl56 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK56 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln56.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK56 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo56.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK56 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli56.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst56 : Conv.sstListB 2449 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx PRE_first_tail_x15_r0_body.cln56 PRE_first_tail_x15_r0_body.clo56 PRE_first_tail_x15_r0_body.cli56 = true

end Host.Load.Run.Tpl
end

section -- SiteCl56
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA56 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo56.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd56 : (PRE_first_tail_x15_r0_body.clo56 ++ PRE_first_tail_x15_r0_body.cln56 ++ PRE_first_tail_x15_r0_body.cli56).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle56 : Conv.Cnt.leB (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt) (⟨19297, 16396, 2718428, 2449⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck56 : Conv.ncleanListB (⟨19297, 16396, 2718428, 2449⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx PRE_first_tail_x15_r0_body.clo56 PRE_first_tail_x15_r0_body.cln56 PRE_first_tail_x15_r0_body.cli56 = true
theorem PRE_first_tail_x15_r0_body.cncl56 (h : Conv.NClean (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx) : Conv.NClean (⟨19297, 16396, 2718428, 2449⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle56 PRE_first_tail_x15_r0_body.ckA56 PRE_first_tail_x15_r0_body.cobjsK56 PRE_first_tail_x15_r0_body.cnodesK56 PRE_first_tail_x15_r0_body.citemsK56 PRE_first_tail_x15_r0_body.cbd56 PRE_first_tail_x15_r0_body.cck56

end Host.Load.Run.Tpl
end

section -- SiteS56
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 56 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc56 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P56 : LoadP := PRE_first_tail_x15_r0_body.Pc56.raise 16396
kernel_rfl PRE_first_tail_x15_r0_body.craise56 : Nat.ble PRE_first_tail_x15_r0_body.Pc56.N0 16396 = true
theorem PRE_first_tail_x15_r0_body.raised56 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc56 PRE_first_tail_x15_r0_body.P56 :=
  .inr ⟨16396, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise56, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_56 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_56 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s547.ffi)
def PRE_first_tail_x15_r0_body.khinv56 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv56 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS56 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS56 : List Nat := List.range' 16396 0
def PRE_first_tail_x15_r0_body.ciS56 : List Nat := [] ++ List.range' 16396 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh056 : PRE_first_tail_x15_r0_body.kd56.nh0 = PRE_first_tail_x15_r0_body.cx0_56.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh156 : PRE_first_tail_x15_r0_body.kd56.nh1 = PRE_first_tail_x15_r0_body.cx1_56.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn056 : PRE_first_tail_x15_r0_body.kd56.nn0 = PRE_first_tail_x15_r0_body.cx0_56.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn156 : PRE_first_tail_x15_r0_body.kd56.nn1 = PRE_first_tail_x15_r0_body.cx1_56.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo56 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P56.lo && Nat.ble PRE_first_tail_x15_r0_body.P56.lo PRE_first_tail_x15_r0_body.cx0_56.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P56.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P56.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt56 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_56.mlx.next PRE_first_tail_x15_r0_body.cx1_56.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_56.mlx.nnext PRE_first_tail_x15_r0_body.cx1_56.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband56 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P56.NL && Nat.ble PRE_first_tail_x15_r0_body.P56.NL PRE_first_tail_x15_r0_body.P56.N0 && Nat.ble PRE_first_tail_x15_r0_body.P56.N0 PRE_first_tail_x15_r0_body.cx0_56.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow56 : PRE_first_tail_x15_r0_body.kd56.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren56 : checkRenG PRE_first_tail_x15_r0_body.kd56.hnd PRE_first_tail_x15_r0_body.khinv56 (phB PRE_first_tail_x15_r0_body.cx0_56.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband56 : PRE_first_tail_x15_r0_body.kd56.checkBand PRE_first_tail_x15_r0_body.P56.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos56 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd56.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren56 : checkRenG PRE_first_tail_x15_r0_body.kd56.node PRE_first_tail_x15_r0_body.kninv56 (pnB PRE_first_tail_x15_r0_body.cx0_56.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow56 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd56.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P56.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd56.nodeF j) PRE_first_tail_x15_r0_body.cx1_56.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a56 : PRE_first_tail_x15_r0_body.cx0_56.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b56 : PRE_first_tail_x15_r0_body.cx0_56.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok156 : PRE_first_tail_x15_r0_body.cx1_56.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend56 : PRE_first_tail_x15_r0_body.cx1_56.mlx.pending = PRE_first_tail_x15_r0_body.cx0_56.mlx.pending.map PRE_first_tail_x15_r0_body.kappa56.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh56 : PRE_first_tail_x15_r0_body.cx1_56.mlx.errh = PRE_first_tail_x15_r0_body.cx0_56.mlx.errh.map PRE_first_tail_x15_r0_body.kappa56.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles56 : PRE_first_tail_x15_r0_body.cx1_56.mlx.files = PRE_first_tail_x15_r0_body.cx0_56.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch56 : PRE_first_tail_x15_r0_body.cx1_56.mlx.arch = PRE_first_tail_x15_r0_body.cx0_56.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes56 : PRE_first_tail_x15_r0_body.cx1_56.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_56.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired56 : PRE_first_tail_x15_r0_body.cx1_56.mlx.wired = PRE_first_tail_x15_r0_body.cx0_56.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost56 : PRE_first_tail_x15_r0_body.cx1_56.host = PRE_first_tail_x15_r0_body.cx0_56.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd56`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn056 : PRE_first_tail_x15_r0_body.kd56.n0 = 2718428
kernel_rfl PRE_first_tail_x15_r0_body.ckn156 : PRE_first_tail_x15_r0_body.kd56.n1 = 2718447
kernel_rfl PRE_first_tail_x15_r0_body.ckheap56 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd56.heap).all (fun x => Nat.ble 2718427 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl56 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd56.heap.get (2718427 + j) = nth? PRE_first_tail_x15_r0_body.pl56 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja56 : Nat.ble 2718427 2718427 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn56 : Nat.ble 2449 2449 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD56 : Nat.ble 2718427 PRE_first_tail_x15_r0_body.kd56.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn56 : Nat.ble 19297 PRE_first_tail_x15_r0_body.kd56.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn56 : Nat.ble 16396 PRE_first_tail_x15_r0_body.kd56.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb56 : Nat.ble 19297 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap56 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd56.heap).all (Nat.ble (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd56 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd56.hnd).all (Nat.ble (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode56 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd56.node).all (Nat.ble (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix56 : Conv.FixOld (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa56 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja56) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn56) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD56) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn56) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn56) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb56) PRE_first_tail_x15_r0_body.fheap56 PRE_first_tail_x15_r0_body.fhnd56 PRE_first_tail_x15_r0_body.fnode56
kernel_rfl PRE_first_tail_x15_r0_body.fcxn56 : (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn56 : (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle056 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_56.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_56.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk56 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd56.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A56 : PRE_first_tail_x15_r0_body.cx1_56.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS56.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_56.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O56 : PRE_first_tail_x15_r0_body.cx1_56.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS56.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_56.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N56 : PRE_first_tail_x15_r0_body.cx1_56.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS56.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_56.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I56 : PRE_first_tail_x15_r0_body.cx1_56.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS56.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_56.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd56 : (PRE_first_tail_x15_r0_body.clo56 ++ PRE_first_tail_x15_r0_body.cln56 ++ PRE_first_tail_x15_r0_body.cli56 ++ PRE_first_tail_x15_r0_body.cwS56 ++ PRE_first_tail_x15_r0_body.cnS56 ++ PRE_first_tail_x15_r0_body.ciS56).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW56 : PRE_first_tail_x15_r0_body.cwS56.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo56.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI56 : PRE_first_tail_x15_r0_body.ciS56.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli56.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN56 : PRE_first_tail_x15_r0_body.cnS56.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF56 : PRE_first_tail_x15_r0_body.cln56.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh56 : PRE_first_tail_x15_r0_body.clo56.all (handleOK PRE_first_tail_x15_r0_body.kappa56 PRE_first_tail_x15_r0_body.P56.lo PRE_first_tail_x15_r0_body.cx0_56.mlx PRE_first_tail_x15_r0_body.cx1_56.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo56 : PRE_first_tail_x15_r0_body.clo56.map (fun h => PRE_first_tail_x15_r0_body.cx1_56.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa56.handle h)) = PRE_first_tail_x15_r0_body.clo56.map (fun h => (PRE_first_tail_x15_r0_body.cx0_56.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa56.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok56 : PRE_first_tail_x15_r0_body.clo56.all (objOK PRE_first_tail_x15_r0_body.kappa56 PRE_first_tail_x15_r0_body.P56.NL PRE_first_tail_x15_r0_body.cx0_56.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd56 : PRE_first_tail_x15_r0_body.cln56.all (nodeOKF PRE_first_tail_x15_r0_body.kappa56 PRE_first_tail_x15_r0_body.P56 PRE_first_tail_x15_r0_body.cx0_56.mlx PRE_first_tail_x15_r0_body.cx1_56.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp56 : ((PRE_first_tail_x15_r0_body.cln56.filter (fullB PRE_first_tail_x15_r0_body.P56))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_56.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa56.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln56.filter (fullB PRE_first_tail_x15_r0_body.P56))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_56.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa56.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI56 : incrB PRE_first_tail_x15_r0_body.kd56.nodeF (List.range' 16396 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK56 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd56.node).all (fun k => Nat.ble 16396 k && Nat.blt k 16396) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL56 : (PRE_first_tail_x15_r0_body.cln56.filter (Nat.ble PRE_first_tail_x15_r0_body.P56.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd56.nodeF i) && (Nat.blt i 16396 || Nat.ble PRE_first_tail_x15_r0_body.kd56.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord56 : (PRE_first_tail_x15_r0_body.cln56.filter (Nat.ble PRE_first_tail_x15_r0_body.P56.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd56.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd56.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd56.nodeF j) (PRE_first_tail_x15_r0_body.kd56.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow56 PRE_first_tail_x15_r0_body.cnn156 PRE_first_tail_x15_r0_body.fnordI56 PRE_first_tail_x15_r0_body.fnordK56 PRE_first_tail_x15_r0_body.fnordL56
kernel_rfl PRE_first_tail_x15_r0_body.fi56 : PRE_first_tail_x15_r0_body.cli56.all (pnB PRE_first_tail_x15_r0_body.cx0_56.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii56 : PRE_first_tail_x15_r0_body.cli56.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_56.mlx.items.get (PRE_first_tail_x15_r0_body.kappa56.node k) = (PRE_first_tail_x15_r0_body.cx0_56.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa56.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot56 (clean : Conv.NClean (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P56.NL) (cl : SSt (· < 2449) PRE_first_tail_x15_r0_body.cx0_56.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P56 2449 PRE_first_tail_x15_r0_body.kappa56 PRE_first_tail_x15_r0_body.kd56 PRE_first_tail_x15_r0_body.khinv56 PRE_first_tail_x15_r0_body.kninv56 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx PRE_first_tail_x15_r0_body.cx0_56.mlx PRE_first_tail_x15_r0_body.cx1_56.mlx (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo56 PRE_first_tail_x15_r0_body.cln56 PRE_first_tail_x15_r0_body.cli56 PRE_first_tail_x15_r0_body.cwS56 PRE_first_tail_x15_r0_body.cnS56 PRE_first_tail_x15_r0_body.ciS56 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh056, PRE_first_tail_x15_r0_body.cnh156, PRE_first_tail_x15_r0_body.cnn056, PRE_first_tail_x15_r0_body.cnn156, PRE_first_tail_x15_r0_body.cplo56, PRE_first_tail_x15_r0_body.ccnt56, PRE_first_tail_x15_r0_body.cnband56, PRE_first_tail_x15_r0_body.chbelow56, PRE_first_tail_x15_r0_body.chren56, PRE_first_tail_x15_r0_body.cband56, PRE_first_tail_x15_r0_body.cnh1pos56, PRE_first_tail_x15_r0_body.cnren56, PRE_first_tail_x15_r0_body.cnlow56, PRE_first_tail_x15_r0_body.cabs0a56, PRE_first_tail_x15_r0_body.cabs0b56, PRE_first_tail_x15_r0_body.ctok156, PRE_first_tail_x15_r0_body.cpend56, PRE_first_tail_x15_r0_body.cerrh56, PRE_first_tail_x15_r0_body.cfiles56, PRE_first_tail_x15_r0_body.carch56, PRE_first_tail_x15_r0_body.csizes56, PRE_first_tail_x15_r0_body.cwired56, PRE_first_tail_x15_r0_body.cfix56, clean, PRE_first_tail_x15_r0_body.fcxn56, PRE_first_tail_x15_r0_body.fcnn56, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle056, PRE_first_tail_x15_r0_body.fnk56, PRE_first_tail_x15_r0_body.ckA56, PRE_first_tail_x15_r0_body.cobjsK56, PRE_first_tail_x15_r0_body.cnodesK56, PRE_first_tail_x15_r0_body.citemsK56, PRE_first_tail_x15_r0_body.f1A56, PRE_first_tail_x15_r0_body.f1O56, PRE_first_tail_x15_r0_body.f1N56, PRE_first_tail_x15_r0_body.f1I56, PRE_first_tail_x15_r0_body.fbd56, PRE_first_tail_x15_r0_body.fincW56, PRE_first_tail_x15_r0_body.fincI56, PRE_first_tail_x15_r0_body.fincN56, PRE_first_tail_x15_r0_body.flnF56, PRE_first_tail_x15_r0_body.fh56, PRE_first_tail_x15_r0_body.fo56, PRE_first_tail_x15_r0_body.fok56, PRE_first_tail_x15_r0_body.fnd56, PRE_first_tail_x15_r0_body.fp56, PRE_first_tail_x15_r0_body.fnord56, PRE_first_tail_x15_r0_body.fi56, PRE_first_tail_x15_r0_body.fii56⟩
theorem PRE_first_tail_x15_r0_body.cnshift56 (clean : Conv.NClean (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P56.NL) (cl : SSt (· < 2449) PRE_first_tail_x15_r0_body.cx0_56.mlx) : NShift PRE_first_tail_x15_r0_body.P56 2449 PRE_first_tail_x15_r0_body.kappa56 PRE_first_tail_x15_r0_body.cx0_56 PRE_first_tail_x15_r0_body.cx1_56 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot56 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost56 (compact_a_eq PRE_first_tail_x15_r0_body.ckn056 PRE_first_tail_x15_r0_body.ckn156 PRE_first_tail_x15_r0_body.ckheap56 PRE_first_tail_x15_r0_body.ckpl56)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_56 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s546.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_56 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s546.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_56 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s546.ffi) = some PRE_first_tail_x15_r0_body.fxC_56
kernel_rfl PRE_first_tail_x15_r0_body.okrC_56 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s546.ffi) = some PRE_first_tail_x15_r0_body.krC_56
noncomputable def PRE_first_tail_x15_r0_body.fx0_56 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s548.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_56 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s548.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_56 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s548.ffi) = some PRE_first_tail_x15_r0_body.fx0_56
kernel_rfl PRE_first_tail_x15_r0_body.okr0_56 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s548.ffi) = some PRE_first_tail_x15_r0_body.kr0_56
noncomputable def PRE_first_tail_x15_r0_body.fx1_56 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s547.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_56 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s547.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_56 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s547.ffi) = some PRE_first_tail_x15_r0_body.fx1_56
kernel_rfl PRE_first_tail_x15_r0_body.okr1_56 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s547.ffi) = some PRE_first_tail_x15_r0_body.kr1_56
kernel_rfl PRE_first_tail_x15_r0_body.ff056 : PRE_first_tail_x15_r0_body.fx0_56 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_56 (PRE_first_tail_x15_r0_body.clo56.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_56.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff156 : PRE_first_tail_x15_r0_body.fx1_56 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_56 (PRE_first_tail_x15_r0_body.cwS56.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_56.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck56 : freedLB PRE_first_tail_x15_r0_body.kappa56 PRE_first_tail_x15_r0_body.cx0_56.mlx PRE_first_tail_x15_r0_body.fx0_56 PRE_first_tail_x15_r0_body.fx1_56 PRE_first_tail_x15_r0_body.clo56 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf056 : PRE_first_tail_x15_r0_body.kr0_56.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_56.flags (PRE_first_tail_x15_r0_body.clo56.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_56.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt056 : PRE_first_tail_x15_r0_body.kr0_56.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_56.targs (PRE_first_tail_x15_r0_body.clo56.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_56.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf156 : PRE_first_tail_x15_r0_body.kr1_56.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_56.flags (PRE_first_tail_x15_r0_body.cwS56.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_56.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt156 : PRE_first_tail_x15_r0_body.kr1_56.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_56.targs (PRE_first_tail_x15_r0_body.cwS56.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_56.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck56 : krecLB PRE_first_tail_x15_r0_body.kappa56 2449 PRE_first_tail_x15_r0_body.cx0_56.mlx PRE_first_tail_x15_r0_body.kr0_56 PRE_first_tail_x15_r0_body.kr1_56 PRE_first_tail_x15_r0_body.clo56 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn56 : Nat.ble 2449 2449 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge56 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s547.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s548.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR56 : pendRegB PRE_first_tail_x15_r0_body.kappa56 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe56 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s547.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift56 (clean : Conv.NClean (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P56.NL) (cl : SSt (· < 2449) PRE_first_tail_x15_r0_body.cx0_56.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_56.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_56.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_56.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_56.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P56 2449 PRE_first_tail_x15_r0_body.kappa56 PRE_first_tail_x15_r0_body.s548.ffi PRE_first_tail_x15_r0_body.s547.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift56 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue56, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp56 t ht),
    PRE_first_tail_x15_r0_body.cbridge56,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s548.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s547.ffi) (PRE_first_tail_x15_r0_body.cfoot56 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_56 PRE_first_tail_x15_r0_body.ofx1_56 hobjC PRE_first_tail_x15_r0_body.ff056 PRE_first_tail_x15_r0_body.ff156 PRE_first_tail_x15_r0_body.ffck56,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s548.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s547.ffi) (PRE_first_tail_x15_r0_body.cfoot56 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_56 PRE_first_tail_x15_r0_body.okr1_56 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn56) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf056 PRE_first_tail_x15_r0_body.fkt056 PRE_first_tail_x15_r0_body.fkf156 PRE_first_tail_x15_r0_body.fkt156 PRE_first_tail_x15_r0_body.fkck56,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh056 PRE_first_tail_x15_r0_body.cnh156 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe56) PRE_first_tail_x15_r0_body.cpendR56⟩

end Host.Load.Run.Tpl
end

section -- st56/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st56 0
host_stream_state PRE_first_tail_x15_r0_body.st56 1
host_stream_state PRE_first_tail_x15_r0_body.st56 2
end Host.Load.Run.Tpl
end

section -- Site56
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 56 of chain `PRE_first_tail_x15_r0_body`: `plan__g56__g57` (`plan`), the call state `PRE_first_tail_x15_r0_body.s546`, the merged state `PRE_first_tail_x15_r0_body.s547`,
the site template `PRE_first_tail_x15_r0_body.st56` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s548`: the merge.
The footprint's facts are in `SiteF56`, the compaction's in `SiteC56`, `SiteK56`, `SiteNa56`, `SiteNb56`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso56 : PRE_first_tail_x15_r0_body.st56.s0 = { PRE_first_tail_x15_r0_body.s546 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs56 : List Frame := PRE_first_tail_x15_r0_body.s546.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_56 : PRE_first_tail_x15_r0_body.S546.tab.length = 2449
kernel_rfl PRE_first_tail_x15_r0_body.tab0_56 : PRE_first_tail_x15_r0_body.st56.S0.tab = PRE_first_tail_x15_r0_body.S546.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws56 : List Nat := [1967, 1968, 1969, 1970, 1971, 1972, 1973, 1974, 1975]
kernel_rfl PRE_first_tail_x15_r0_body.fresh56 : (PRE_first_tail_x15_r0_body.S546.tab.all fun e => PRE_first_tail_x15_r0_body.ws56.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S546.oracle.all fun q => PRE_first_tail_x15_r0_body.ws56.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab56 : PRE_first_tail_x15_r0_body.S547.tab = PRE_first_tail_x15_r0_body.S546.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws56
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen56 : PRE_first_tail_x15_r0_body.st56.S2.tab.length - PRE_first_tail_x15_r0_body.st56.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged56`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap56 : PRE_first_tail_x15_r0_body.s547.heap = PRE_first_tail_x15_r0_body.st56.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext56 : PRE_first_tail_x15_r0_body.s547.next = PRE_first_tail_x15_r0_body.st56.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl56 : PRE_first_tail_x15_r0_body.s547.ctl = PRE_first_tail_x15_r0_body.st56.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack56 : PRE_first_tail_x15_r0_body.s547.stack = PRE_first_tail_x15_r0_body.st56.s2.stack ++ PRE_first_tail_x15_r0_body.s546.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs56 : PRE_first_tail_x15_r0_body.s547.jobs = PRE_first_tail_x15_r0_body.st56.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi56 : PRE_first_tail_x15_r0_body.s547.ffi = PRE_first_tail_x15_r0_body.st56.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace56 : PRE_first_tail_x15_r0_body.s547.trace = PRE_first_tail_x15_r0_body.st56.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores56 : PRE_first_tail_x15_r0_body.s547.stores = PRE_first_tail_x15_r0_body.st56.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD56
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 56 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived56 : PRE_first_tail_x15_r0_body.nr56.map (fun r => nth? PRE_first_tail_x15_r0_body.st56.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo56 : PRE_first_tail_x15_r0_body.nr56.all (Nat.ble 2449) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj56 : PRE_first_tail_x15_r0_body.cws56.all (fun c => !PRE_first_tail_x15_r0_body.ws56.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ56 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws56 PRE_first_tail_x15_r0_body.crs56 PRE_first_tail_x15_r0_body.ws56

end Host.Load.Run.Tpl
end

section -- st56/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st56`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st56.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st56.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st56.s2.heap PRE_first_tail_x15_r0_body.st56.wrR ++ freshOf PRE_first_tail_x15_r0_body.st56.s2.heap PRE_first_tail_x15_r0_body.st56.s0.next PRE_first_tail_x15_r0_body.st56.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st56.wr : List Nat := PRE_first_tail_x15_r0_body.st56.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st56.heapFoot : PRE_first_tail_x15_r0_body.st56.s2.heap = setAll PRE_first_tail_x15_r0_body.st56.s0.heap PRE_first_tail_x15_r0_body.st56.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st56.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st56.s0.next PRE_first_tail_x15_r0_body.st56.s2.next = true
theorem PRE_first_tail_x15_r0_body.st56.grows : PRE_first_tail_x15_r0_body.st56.s0.next ≤ PRE_first_tail_x15_r0_body.st56.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st56.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st56.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st56.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st56.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st56.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st56.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st56.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st56.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st56.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st56.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st56.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st56.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st56.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st56.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st56.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st56.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st56.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st56.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st56.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st56.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st56.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st56.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st56.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st56.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st56.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st56.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st56.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st56.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st56.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st56.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st56.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st56.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF56
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 56 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB56 : nodupT PRE_first_tail_x15_r0_body.st56.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup56 : PRE_first_tail_x15_r0_body.st56.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB56).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB56 : PRE_first_tail_x15_r0_body.st56.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound56 : ∀ b ∈ PRE_first_tail_x15_r0_body.st56.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB56 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr56 := PRE_first_tail_x15_r0_body.st56.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq56 : PRE_first_tail_x15_r0_body.st56.s2.trace = PRE_first_tail_x15_r0_body.trFr56 ++ PRE_first_tail_x15_r0_body.st56.s0.trace
theorem PRE_first_tail_x15_r0_body.trace56 : ∃ fr, PRE_first_tail_x15_r0_body.st56.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st56.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq56⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide56 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB56 : (PRE_first_tail_x15_r0_body.wide56.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st56.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix56 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide56, WFix Map.id (Present PRE_first_tail_x15_r0_body.st56.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB56 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL56
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 56 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s547`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO56 : PRE_first_tail_x15_r0_body.st56.S0.oracle = PRE_first_tail_x15_r0_body.st56.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B56 : PRE_first_tail_x15_r0_body.st56.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st56.s0.next || (PRE_first_tail_x15_r0_body.st56.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot56 : Conv.StageFoot PRE_first_tail_x15_r0_body.st56.wr PRE_first_tail_x15_r0_body.st56.s0 PRE_first_tail_x15_r0_body.st56.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st56.heapFoot PRE_first_tail_x15_r0_body.wrNodup56 PRE_first_tail_x15_r0_body.wrBound56 PRE_first_tail_x15_r0_body.wr0B56 PRE_first_tail_x15_r0_body.st56.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged56 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st56.F.S → PRE_first_tail_x15_r0_body.st56.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st56.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st56.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs56 PRE_first_tail_x15_r0_body.st56.wr PRE_first_tail_x15_r0_body.s546 PRE_first_tail_x15_r0_body.st56.s2 PRE_first_tail_x15_r0_body.st56.s0
      PRE_first_tail_x15_r0_body.st56.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st56.F FR W stk M ν K PRE_first_tail_x15_r0_body.s547 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso56 PRE_first_tail_x15_r0_body.stFoot56 PRE_first_tail_x15_r0_body.wrNodup56 PRE_first_tail_x15_r0_body.wrBound56 PRE_first_tail_x15_r0_body.trace56 PRE_first_tail_x15_r0_body.mheap56
    PRE_first_tail_x15_r0_body.mnext56 PRE_first_tail_x15_r0_body.mctl56 PRE_first_tail_x15_r0_body.mstack56 PRE_first_tail_x15_r0_body.mjobs56 PRE_first_tail_x15_r0_body.mffi56 PRE_first_tail_x15_r0_body.mtrace56 PRE_first_tail_x15_r0_body.mstores56 h

def PRE_first_tail_x15_r0_body.arrEl56_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE56_2665 : arrOf PRE_first_tail_x15_r0_body.s547 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl56_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA56_2665 : isArrB PRE_first_tail_x15_r0_body.s547 2665 = true
theorem PRE_first_tail_x15_r0_body.arr56_2665 : ∃ o, PRE_first_tail_x15_r0_body.s547.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl56_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE56_2665 PRE_first_tail_x15_r0_body.arrA56_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN56_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl56_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR56_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl56_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN56_2665

def PRE_first_tail_x15_r0_body.arrEl56_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE56_2673467 : arrOf PRE_first_tail_x15_r0_body.s547 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl56_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA56_2673467 : isArrB PRE_first_tail_x15_r0_body.s547 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr56_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s547.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl56_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE56_2673467 PRE_first_tail_x15_r0_body.arrA56_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN56_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl56_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR56_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl56_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN56_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k56 : isArrB PRE_first_tail_x15_r0_body.s547 4910 = false
theorem PRE_first_tail_x15_r0_body.keep56 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s547 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k56 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr56_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl56_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ56
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 56 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s546`, the merged
state `PRE_first_tail_x15_r0_body.s547`, the canonical state `PRE_first_tail_x15_r0_body.s548`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl56 : PRE_first_tail_x15_r0_body.pl56.all (Nat.ble PRE_first_tail_x15_r0_body.s546.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd56 : nodupT PRE_first_tail_x15_r0_body.pl56 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn156 : Nat.ble PRE_first_tail_x15_r0_body.s546.next 2718447 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst56 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s546.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn56 : PRE_first_tail_x15_r0_body.s548.next = PRE_first_tail_x15_r0_body.s546.next + PRE_first_tail_x15_r0_body.pl56.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn56 : PRE_first_tail_x15_r0_body.s547.next = 2718447
kernel_rfl PRE_first_tail_x15_r0_body.zgrow56 : Nat.ble PRE_first_tail_x15_r0_body.s548.next PRE_first_tail_x15_r0_body.s547.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh56 : PRE_first_tail_x15_r0_body.S546.tab.all (fun e => PRE_first_tail_x15_r0_body.cws56.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd56 : nodupT PRE_first_tail_x15_r0_body.cws56 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi56 : PRE_first_tail_x15_r0_body.nr56.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S547.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt56 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s546.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg56_2665 : PRE_first_tail_x15_r0_body.s548.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s548 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk56_2665 : (objOf PRE_first_tail_x15_r0_body.s548 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm56_2665 : PRE_first_tail_x15_r0_body.s547.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa56.obj (objOf PRE_first_tail_x15_r0_body.s548 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s547 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg56_2673467 : PRE_first_tail_x15_r0_body.s548.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s548 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk56_2673467 : (objOf PRE_first_tail_x15_r0_body.s548 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm56_2673467 : PRE_first_tail_x15_r0_body.s547.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa56.obj (objOf PRE_first_tail_x15_r0_body.s548 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s547 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw56_4910 : (PRE_first_tail_x15_r0_body.s548.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw56_2673472 : (PRE_first_tail_x15_r0_body.s548.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw56_2673473 : (PRE_first_tail_x15_r0_body.s548.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd56 : PRE_first_tail_x15_r0_body.cl56.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr56 : PRE_first_tail_x15_r0_body.st56.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s546.next || PRE_first_tail_x15_r0_body.cl56.contains b) = true
def PRE_first_tail_x15_r0_body.zl56 : List Nat := PRE_first_tail_x15_r0_body.cl56.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE56 : PRE_first_tail_x15_r0_body.zl56.map (fun a => PRE_first_tail_x15_r0_body.s547.heap.get (PRE_first_tail_x15_r0_body.kappa56.a a)) = PRE_first_tail_x15_r0_body.zl56.map (fun a => (PRE_first_tail_x15_r0_body.s548.heap.get a).map PRE_first_tail_x15_r0_body.kappa56.hobj)
theorem PRE_first_tail_x15_r0_body.zimg56 : HeapImg PRE_first_tail_x15_r0_body.kappa56 PRE_first_tail_x15_r0_body.s548 PRE_first_tail_x15_r0_body.s547 PRE_first_tail_x15_r0_body.zl56 := PRE_first_tail_x15_r0_body.zimgE56
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl56 : PRE_first_tail_x15_r0_body.s547.ctl = PRE_first_tail_x15_r0_body.kappa56.ctl PRE_first_tail_x15_r0_body.s548.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack56 : PRE_first_tail_x15_r0_body.s547.stack = PRE_first_tail_x15_r0_body.s548.stack.map PRE_first_tail_x15_r0_body.kappa56.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs56 : PRE_first_tail_x15_r0_body.s547.jobs = PRE_first_tail_x15_r0_body.s548.jobs.map PRE_first_tail_x15_r0_body.kappa56.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores56 : PRE_first_tail_x15_r0_body.s547.stores = PRE_first_tail_x15_r0_body.kappa56.stores PRE_first_tail_x15_r0_body.s548.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots56 : checkRootsSupp PRE_first_tail_x15_r0_body.s548 2449 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC56 : PRE_first_tail_x15_r0_body.S546.tab.length + PRE_first_tail_x15_r0_body.cws56.length = 2449
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap56 : PRE_first_tail_x15_r0_body.kappa56 = Conv.Map.compact PRE_first_tail_x15_r0_body.s546.next 2718447 PRE_first_tail_x15_r0_body.S546.tab.length PRE_first_tail_x15_r0_body.pl56 (PRE_first_tail_x15_r0_body.nr56.map NumV.ref) PRE_first_tail_x15_r0_body.kd56.big
  PRE_first_tail_x15_r0_body.kd56.region PRE_first_tail_x15_r0_body.kd56.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin56 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s548.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc56 : Conv.jcleanListB (⟨19297, 16396, 2718428, 2449⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s548 PRE_first_tail_x15_r0_body.cl56 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB56 : noBigRootsP (fun i => !Conv.oldBigB (⟨19297, 16396, 2718428, 2449⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s548.trace PRE_first_tail_x15_r0_body.s548 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm56 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16396 = true
theorem PRE_first_tail_x15_r0_body.cjcl56 (h : Conv.JClean (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s546) : Conv.JClean (⟨19297, 16396, 2718428, 2449⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s548 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle56)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap56 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd56 a ha)) PRE_first_tail_x15_r0_body.zjc56

end Host.Load.Run.Tpl
end

section -- st56/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st56.bodyLast from PRE_first_tail_x15_r0_body.st56.s1 to PRE_first_tail_x15_r0_body.st56.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st56.F PRE_first_tail_x15_r0_body.st56.s1).run PRE_first_tail_x15_r0_body.st56.S1 = some (PRE_first_tail_x15_r0_body.st56.s2, PRE_first_tail_x15_r0_body.st56.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st56.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st56.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st56.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st56.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st56/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st56.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st56.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st56.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st56.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st56.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st56.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st56.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st56.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st56.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st56.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st56.s0 PRE_first_tail_x15_r0_body.st56.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st56.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st56.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st56.s1 PRE_first_tail_x15_r0_body.st56.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st56/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st56.bodyK0F from PRE_first_tail_x15_r0_body.st56.s0 to PRE_first_tail_x15_r0_body.st56.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st56.F (PRE_first_tail_x15_r0_body.st56.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st56.ks 0).getD 0) PRE_first_tail_x15_r0_body.st56.s0 PRE_first_tail_x15_r0_body.st56.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st56.s1, PRE_first_tail_x15_r0_body.st56.S1)
theorem PRE_first_tail_x15_r0_body.st56.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st56.F (PRE_first_tail_x15_r0_body.st56.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st56.ks 0).getD 0) PRE_first_tail_x15_r0_body.st56.s0 PRE_first_tail_x15_r0_body.st56.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st56.s1, PRE_first_tail_x15_r0_body.st56.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st56.bodyOkLN_ok PRE_first_tail_x15_r0_body.st56.bodyK0F
end Host.Load.Run.Tpl
end

section -- st56/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st56.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st56.F (PRE_first_tail_x15_r0_body.st56.bodyOkL bytes rows) 206 PRE_first_tail_x15_r0_body.st56.s0 PRE_first_tail_x15_r0_body.st56.S0 = some (PRE_first_tail_x15_r0_body.st56.s1, PRE_first_tail_x15_r0_body.st56.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st56.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st56.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st56.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st56.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st56.F (PRE_first_tail_x15_r0_body.st56.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st56.s0
  S0 := PRE_first_tail_x15_r0_body.st56.S0
  s1 := PRE_first_tail_x15_r0_body.st56.s1
  S1 := PRE_first_tail_x15_r0_body.st56.S1
  s2 := PRE_first_tail_x15_r0_body.st56.s2
  S2 := PRE_first_tail_x15_r0_body.st56.S2
  n := 206
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st56.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st56.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st56.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st56.bodyHalt
  last := PRE_first_tail_x15_r0_body.st56.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st56.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC57
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 57 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s564` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa57` into the merged state
`PRE_first_tail_x15_r0_body.s563`. -/

def PRE_first_tail_x15_r0_body.pl57 : List Nat := [2720530, 2720366, 2720418, 2720531, 2720532, 2720368, 2720420, 2720529, 2720528, 2720527, 2720526, 2720520, 2720471, 2720522, 2720473]
def PRE_first_tail_x15_r0_body.nr57 : List Nat := [2534, 2535, 2531, 2537, 2533, 2541, 2542, 2539, 2540]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd57 : RData :=
  ⟨2720183, 2720533, Stage.setAll PTrie.nil [(2720168, 2720530), (2720169, 2720366), (2720170, 2720418), (2720171, 2720531), (2720172, 2720532), (2720173, 2720368), (2720174, 2720420), (2720175, 2720529), (2720176, 2720528), (2720177, 2720527), (2720178, 2720526), (2720179, 2720520), (2720180, 2720471), (2720181, 2720522), (2720182, 2720473)], Stage.setAll PTrie.nil [(19337, 19339), (19338, 19340), (19339, 19342), (19340, 19341)],
   19341, 19343, 16430, 16430, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(2526, .ref 2534), (2527, .ref 2535), (2528, .ref 2531), (2529, .ref 2537), (2530, .ref 2533), (2531, .ref 2541), (2532, .ref 2542), (2533, .ref 2539), (2534, .ref 2540)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa57 : Map :=
  Conv.Map.compact 2720168 2720533 2526 PRE_first_tail_x15_r0_body.pl57 (PRE_first_tail_x15_r0_body.nr57.map NumV.ref) PRE_first_tail_x15_r0_body.kd57.big
    PRE_first_tail_x15_r0_body.kd57.region PRE_first_tail_x15_r0_body.kd57.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws57 : List Nat := [1993, 1994, 1995, 1996, 1997, 1998, 1999, 2000, 2001]
noncomputable def PRE_first_tail_x15_r0_body.crs57 : List SymE := PRE_first_tail_x15_r0_body.nr57.map fun r => (nth? PRE_first_tail_x15_r0_body.S563.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta57 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws57 PRE_first_tail_x15_r0_body.crs57
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB57 : List Nat := [2665, 2672446, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab57 : PRE_first_tail_x15_r0_body.S564.tab = PRE_first_tail_x15_r0_body.S562.tab ++ PRE_first_tail_x15_r0_body.cws57.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace57 : PRE_first_tail_x15_r0_body.s564.trace = PRE_first_tail_x15_r0_body.s562.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext57 : PRE_first_tail_x15_r0_body.s564.next = 2720183
kernel_rfl PRE_first_tail_x15_r0_body.ccounters57 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx.nnext) = (19341, 16430)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue57 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s563.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa57.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp57 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx.tokens.all (bSN 2535) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean57 : Conv.cleanListB 19341 131072 (fun r => Nat.ble 77364 r) PRE_first_tail_x15_r0_body.s564
    (PRE_first_tail_x15_r0_body.wrB57 ++ (List.range 15).map (2720168 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs57 : bigsOutB 19341 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK57
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl57`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl57 : List Nat := [2665, 2672446, 2673467, 2720168, 2720169, 2720170, 2720171, 2720172, 2720173, 2720174, 2720175, 2720176, 2720177, 2720178, 2720179, 2720180, 2720181, 2720182]
def PRE_first_tail_x15_r0_body.clo57 : List Nat := [19337, 19338, 19339, 19340]
def PRE_first_tail_x15_r0_body.cln57 : List Nat := [16424, 16425, 16426, 16427, 16428, 16429]
def PRE_first_tail_x15_r0_body.cli57 : List Nat := [16424, 16425, 16426, 16427, 16428, 16429]
kernel_rfl PRE_first_tail_x15_r0_body.cheap57 : PRE_first_tail_x15_r0_body.s564.heap = Stage.setAll PRE_first_tail_x15_r0_body.s562.heap (PRE_first_tail_x15_r0_body.cl57.filterMap fun a => (PRE_first_tail_x15_r0_body.s564.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe57 : Nat.ble PRE_first_tail_x15_r0_body.s562.next PRE_first_tail_x15_r0_body.s564.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP57 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s562 PRE_first_tail_x15_r0_body.s564 PRE_first_tail_x15_r0_body.cl57 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp57 : Conv.suppListB PRE_first_tail_x15_r0_body.s564 2535 PRE_first_tail_x15_r0_body.cl57 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound57 : Conv.boundListB PRE_first_tail_x15_r0_body.s564 PRE_first_tail_x15_r0_body.cl57 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK57 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln57.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK57 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo57.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK57 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli57.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst57 : Conv.sstListB 2535 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx PRE_first_tail_x15_r0_body.cln57 PRE_first_tail_x15_r0_body.clo57 PRE_first_tail_x15_r0_body.cli57 = true

end Host.Load.Run.Tpl
end

section -- SiteCl57
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA57 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo57.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd57 : (PRE_first_tail_x15_r0_body.clo57 ++ PRE_first_tail_x15_r0_body.cln57 ++ PRE_first_tail_x15_r0_body.cli57).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle57 : Conv.Cnt.leB (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt) (⟨19341, 16430, 2720183, 2535⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck57 : Conv.ncleanListB (⟨19341, 16430, 2720183, 2535⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx PRE_first_tail_x15_r0_body.clo57 PRE_first_tail_x15_r0_body.cln57 PRE_first_tail_x15_r0_body.cli57 = true
theorem PRE_first_tail_x15_r0_body.cncl57 (h : Conv.NClean (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx) : Conv.NClean (⟨19341, 16430, 2720183, 2535⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle57 PRE_first_tail_x15_r0_body.ckA57 PRE_first_tail_x15_r0_body.cobjsK57 PRE_first_tail_x15_r0_body.cnodesK57 PRE_first_tail_x15_r0_body.citemsK57 PRE_first_tail_x15_r0_body.cbd57 PRE_first_tail_x15_r0_body.cck57

end Host.Load.Run.Tpl
end

section -- SiteS57
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 57 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc57 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P57 : LoadP := PRE_first_tail_x15_r0_body.Pc57.raise 16430
kernel_rfl PRE_first_tail_x15_r0_body.craise57 : Nat.ble PRE_first_tail_x15_r0_body.Pc57.N0 16430 = true
theorem PRE_first_tail_x15_r0_body.raised57 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc57 PRE_first_tail_x15_r0_body.P57 :=
  .inr ⟨16430, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise57, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_57 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_57 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s563.ffi)
def PRE_first_tail_x15_r0_body.khinv57 : PTrie Nat := Stage.setAll PTrie.nil [(19339, 19337), (19340, 19338), (19342, 19339), (19341, 19340)]
def PRE_first_tail_x15_r0_body.kninv57 : PTrie Nat := Stage.setAll PTrie.nil [(16424, 16424), (16425, 16425), (16426, 16426), (16427, 16427), (16428, 16428), (16429, 16429)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS57 : List Nat := [19337, 19338, 19339, 19340, 19341, 19342]
def PRE_first_tail_x15_r0_body.cnS57 : List Nat := List.range' 16424 6
def PRE_first_tail_x15_r0_body.ciS57 : List Nat := [] ++ List.range' 16424 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh057 : PRE_first_tail_x15_r0_body.kd57.nh0 = PRE_first_tail_x15_r0_body.cx0_57.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh157 : PRE_first_tail_x15_r0_body.kd57.nh1 = PRE_first_tail_x15_r0_body.cx1_57.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn057 : PRE_first_tail_x15_r0_body.kd57.nn0 = PRE_first_tail_x15_r0_body.cx0_57.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn157 : PRE_first_tail_x15_r0_body.kd57.nn1 = PRE_first_tail_x15_r0_body.cx1_57.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo57 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P57.lo && Nat.ble PRE_first_tail_x15_r0_body.P57.lo PRE_first_tail_x15_r0_body.cx0_57.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P57.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P57.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt57 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_57.mlx.next PRE_first_tail_x15_r0_body.cx1_57.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_57.mlx.nnext PRE_first_tail_x15_r0_body.cx1_57.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband57 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P57.NL && Nat.ble PRE_first_tail_x15_r0_body.P57.NL PRE_first_tail_x15_r0_body.P57.N0 && Nat.ble PRE_first_tail_x15_r0_body.P57.N0 PRE_first_tail_x15_r0_body.cx0_57.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow57 : PRE_first_tail_x15_r0_body.kd57.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren57 : checkRenG PRE_first_tail_x15_r0_body.kd57.hnd PRE_first_tail_x15_r0_body.khinv57 (phB PRE_first_tail_x15_r0_body.cx0_57.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband57 : PRE_first_tail_x15_r0_body.kd57.checkBand PRE_first_tail_x15_r0_body.P57.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos57 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd57.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren57 : checkRenG PRE_first_tail_x15_r0_body.kd57.node PRE_first_tail_x15_r0_body.kninv57 (pnB PRE_first_tail_x15_r0_body.cx0_57.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow57 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd57.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P57.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd57.nodeF j) PRE_first_tail_x15_r0_body.cx1_57.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a57 : PRE_first_tail_x15_r0_body.cx0_57.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b57 : PRE_first_tail_x15_r0_body.cx0_57.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok157 : PRE_first_tail_x15_r0_body.cx1_57.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend57 : PRE_first_tail_x15_r0_body.cx1_57.mlx.pending = PRE_first_tail_x15_r0_body.cx0_57.mlx.pending.map PRE_first_tail_x15_r0_body.kappa57.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh57 : PRE_first_tail_x15_r0_body.cx1_57.mlx.errh = PRE_first_tail_x15_r0_body.cx0_57.mlx.errh.map PRE_first_tail_x15_r0_body.kappa57.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles57 : PRE_first_tail_x15_r0_body.cx1_57.mlx.files = PRE_first_tail_x15_r0_body.cx0_57.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch57 : PRE_first_tail_x15_r0_body.cx1_57.mlx.arch = PRE_first_tail_x15_r0_body.cx0_57.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes57 : PRE_first_tail_x15_r0_body.cx1_57.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_57.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired57 : PRE_first_tail_x15_r0_body.cx1_57.mlx.wired = PRE_first_tail_x15_r0_body.cx0_57.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost57 : PRE_first_tail_x15_r0_body.cx1_57.host = PRE_first_tail_x15_r0_body.cx0_57.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd57`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn057 : PRE_first_tail_x15_r0_body.kd57.n0 = 2720183
kernel_rfl PRE_first_tail_x15_r0_body.ckn157 : PRE_first_tail_x15_r0_body.kd57.n1 = 2720533
kernel_rfl PRE_first_tail_x15_r0_body.ckheap57 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd57.heap).all (fun x => Nat.ble 2720168 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl57 : (List.range 15).all (fun j => decide (PRE_first_tail_x15_r0_body.kd57.heap.get (2720168 + j) = nth? PRE_first_tail_x15_r0_body.pl57 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja57 : Nat.ble 2720168 2720168 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn57 : Nat.ble 2526 2526 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD57 : Nat.ble 2720168 PRE_first_tail_x15_r0_body.kd57.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn57 : Nat.ble 19337 PRE_first_tail_x15_r0_body.kd57.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn57 : Nat.ble 16424 PRE_first_tail_x15_r0_body.kd57.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb57 : Nat.ble 19337 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap57 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd57.heap).all (Nat.ble (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd57 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd57.hnd).all (Nat.ble (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode57 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd57.node).all (Nat.ble (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix57 : Conv.FixOld (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa57 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja57) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn57) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD57) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn57) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn57) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb57) PRE_first_tail_x15_r0_body.fheap57 PRE_first_tail_x15_r0_body.fhnd57 PRE_first_tail_x15_r0_body.fnode57
kernel_rfl PRE_first_tail_x15_r0_body.fcxn57 : (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn57 : (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle057 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_57.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_57.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk57 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd57.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A57 : PRE_first_tail_x15_r0_body.cx1_57.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS57.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_57.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O57 : PRE_first_tail_x15_r0_body.cx1_57.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS57.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_57.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N57 : PRE_first_tail_x15_r0_body.cx1_57.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS57.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_57.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I57 : PRE_first_tail_x15_r0_body.cx1_57.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS57.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_57.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd57 : (PRE_first_tail_x15_r0_body.clo57 ++ PRE_first_tail_x15_r0_body.cln57 ++ PRE_first_tail_x15_r0_body.cli57 ++ PRE_first_tail_x15_r0_body.cwS57 ++ PRE_first_tail_x15_r0_body.cnS57 ++ PRE_first_tail_x15_r0_body.ciS57).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW57 : PRE_first_tail_x15_r0_body.cwS57.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo57.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI57 : PRE_first_tail_x15_r0_body.ciS57.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli57.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN57 : PRE_first_tail_x15_r0_body.cnS57.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF57 : PRE_first_tail_x15_r0_body.cln57.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh57 : PRE_first_tail_x15_r0_body.clo57.all (handleOK PRE_first_tail_x15_r0_body.kappa57 PRE_first_tail_x15_r0_body.P57.lo PRE_first_tail_x15_r0_body.cx0_57.mlx PRE_first_tail_x15_r0_body.cx1_57.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo57 : PRE_first_tail_x15_r0_body.clo57.map (fun h => PRE_first_tail_x15_r0_body.cx1_57.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa57.handle h)) = PRE_first_tail_x15_r0_body.clo57.map (fun h => (PRE_first_tail_x15_r0_body.cx0_57.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa57.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok57 : PRE_first_tail_x15_r0_body.clo57.all (objOK PRE_first_tail_x15_r0_body.kappa57 PRE_first_tail_x15_r0_body.P57.NL PRE_first_tail_x15_r0_body.cx0_57.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd57 : PRE_first_tail_x15_r0_body.cln57.all (nodeOKF PRE_first_tail_x15_r0_body.kappa57 PRE_first_tail_x15_r0_body.P57 PRE_first_tail_x15_r0_body.cx0_57.mlx PRE_first_tail_x15_r0_body.cx1_57.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp57 : ((PRE_first_tail_x15_r0_body.cln57.filter (fullB PRE_first_tail_x15_r0_body.P57))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_57.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa57.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln57.filter (fullB PRE_first_tail_x15_r0_body.P57))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_57.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa57.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI57 : incrB PRE_first_tail_x15_r0_body.kd57.nodeF (List.range' 16424 6) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK57 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd57.node).all (fun k => Nat.ble 16424 k && Nat.blt k 16430) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL57 : (PRE_first_tail_x15_r0_body.cln57.filter (Nat.ble PRE_first_tail_x15_r0_body.P57.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd57.nodeF i) && (Nat.blt i 16430 || Nat.ble PRE_first_tail_x15_r0_body.kd57.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord57 : (PRE_first_tail_x15_r0_body.cln57.filter (Nat.ble PRE_first_tail_x15_r0_body.P57.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd57.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd57.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd57.nodeF j) (PRE_first_tail_x15_r0_body.kd57.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow57 PRE_first_tail_x15_r0_body.cnn157 PRE_first_tail_x15_r0_body.fnordI57 PRE_first_tail_x15_r0_body.fnordK57 PRE_first_tail_x15_r0_body.fnordL57
kernel_rfl PRE_first_tail_x15_r0_body.fi57 : PRE_first_tail_x15_r0_body.cli57.all (pnB PRE_first_tail_x15_r0_body.cx0_57.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii57 : PRE_first_tail_x15_r0_body.cli57.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_57.mlx.items.get (PRE_first_tail_x15_r0_body.kappa57.node k) = (PRE_first_tail_x15_r0_body.cx0_57.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa57.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot57 (clean : Conv.NClean (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P57.NL) (cl : SSt (· < 2535) PRE_first_tail_x15_r0_body.cx0_57.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P57 2535 PRE_first_tail_x15_r0_body.kappa57 PRE_first_tail_x15_r0_body.kd57 PRE_first_tail_x15_r0_body.khinv57 PRE_first_tail_x15_r0_body.kninv57 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx PRE_first_tail_x15_r0_body.cx0_57.mlx PRE_first_tail_x15_r0_body.cx1_57.mlx (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo57 PRE_first_tail_x15_r0_body.cln57 PRE_first_tail_x15_r0_body.cli57 PRE_first_tail_x15_r0_body.cwS57 PRE_first_tail_x15_r0_body.cnS57 PRE_first_tail_x15_r0_body.ciS57 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh057, PRE_first_tail_x15_r0_body.cnh157, PRE_first_tail_x15_r0_body.cnn057, PRE_first_tail_x15_r0_body.cnn157, PRE_first_tail_x15_r0_body.cplo57, PRE_first_tail_x15_r0_body.ccnt57, PRE_first_tail_x15_r0_body.cnband57, PRE_first_tail_x15_r0_body.chbelow57, PRE_first_tail_x15_r0_body.chren57, PRE_first_tail_x15_r0_body.cband57, PRE_first_tail_x15_r0_body.cnh1pos57, PRE_first_tail_x15_r0_body.cnren57, PRE_first_tail_x15_r0_body.cnlow57, PRE_first_tail_x15_r0_body.cabs0a57, PRE_first_tail_x15_r0_body.cabs0b57, PRE_first_tail_x15_r0_body.ctok157, PRE_first_tail_x15_r0_body.cpend57, PRE_first_tail_x15_r0_body.cerrh57, PRE_first_tail_x15_r0_body.cfiles57, PRE_first_tail_x15_r0_body.carch57, PRE_first_tail_x15_r0_body.csizes57, PRE_first_tail_x15_r0_body.cwired57, PRE_first_tail_x15_r0_body.cfix57, clean, PRE_first_tail_x15_r0_body.fcxn57, PRE_first_tail_x15_r0_body.fcnn57, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle057, PRE_first_tail_x15_r0_body.fnk57, PRE_first_tail_x15_r0_body.ckA57, PRE_first_tail_x15_r0_body.cobjsK57, PRE_first_tail_x15_r0_body.cnodesK57, PRE_first_tail_x15_r0_body.citemsK57, PRE_first_tail_x15_r0_body.f1A57, PRE_first_tail_x15_r0_body.f1O57, PRE_first_tail_x15_r0_body.f1N57, PRE_first_tail_x15_r0_body.f1I57, PRE_first_tail_x15_r0_body.fbd57, PRE_first_tail_x15_r0_body.fincW57, PRE_first_tail_x15_r0_body.fincI57, PRE_first_tail_x15_r0_body.fincN57, PRE_first_tail_x15_r0_body.flnF57, PRE_first_tail_x15_r0_body.fh57, PRE_first_tail_x15_r0_body.fo57, PRE_first_tail_x15_r0_body.fok57, PRE_first_tail_x15_r0_body.fnd57, PRE_first_tail_x15_r0_body.fp57, PRE_first_tail_x15_r0_body.fnord57, PRE_first_tail_x15_r0_body.fi57, PRE_first_tail_x15_r0_body.fii57⟩
theorem PRE_first_tail_x15_r0_body.cnshift57 (clean : Conv.NClean (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P57.NL) (cl : SSt (· < 2535) PRE_first_tail_x15_r0_body.cx0_57.mlx) : NShift PRE_first_tail_x15_r0_body.P57 2535 PRE_first_tail_x15_r0_body.kappa57 PRE_first_tail_x15_r0_body.cx0_57 PRE_first_tail_x15_r0_body.cx1_57 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot57 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost57 (compact_a_eq PRE_first_tail_x15_r0_body.ckn057 PRE_first_tail_x15_r0_body.ckn157 PRE_first_tail_x15_r0_body.ckheap57 PRE_first_tail_x15_r0_body.ckpl57)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_57 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s562.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_57 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s562.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_57 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s562.ffi) = some PRE_first_tail_x15_r0_body.fxC_57
kernel_rfl PRE_first_tail_x15_r0_body.okrC_57 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s562.ffi) = some PRE_first_tail_x15_r0_body.krC_57
noncomputable def PRE_first_tail_x15_r0_body.fx0_57 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s564.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_57 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s564.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_57 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s564.ffi) = some PRE_first_tail_x15_r0_body.fx0_57
kernel_rfl PRE_first_tail_x15_r0_body.okr0_57 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s564.ffi) = some PRE_first_tail_x15_r0_body.kr0_57
noncomputable def PRE_first_tail_x15_r0_body.fx1_57 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s563.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_57 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s563.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_57 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s563.ffi) = some PRE_first_tail_x15_r0_body.fx1_57
kernel_rfl PRE_first_tail_x15_r0_body.okr1_57 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s563.ffi) = some PRE_first_tail_x15_r0_body.kr1_57
kernel_rfl PRE_first_tail_x15_r0_body.ff057 : PRE_first_tail_x15_r0_body.fx0_57 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_57 (PRE_first_tail_x15_r0_body.clo57.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_57.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff157 : PRE_first_tail_x15_r0_body.fx1_57 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_57 (PRE_first_tail_x15_r0_body.cwS57.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_57.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck57 : freedLB PRE_first_tail_x15_r0_body.kappa57 PRE_first_tail_x15_r0_body.cx0_57.mlx PRE_first_tail_x15_r0_body.fx0_57 PRE_first_tail_x15_r0_body.fx1_57 PRE_first_tail_x15_r0_body.clo57 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf057 : PRE_first_tail_x15_r0_body.kr0_57.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_57.flags (PRE_first_tail_x15_r0_body.clo57.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_57.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt057 : PRE_first_tail_x15_r0_body.kr0_57.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_57.targs (PRE_first_tail_x15_r0_body.clo57.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_57.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf157 : PRE_first_tail_x15_r0_body.kr1_57.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_57.flags (PRE_first_tail_x15_r0_body.cwS57.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_57.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt157 : PRE_first_tail_x15_r0_body.kr1_57.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_57.targs (PRE_first_tail_x15_r0_body.cwS57.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_57.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck57 : krecLB PRE_first_tail_x15_r0_body.kappa57 2535 PRE_first_tail_x15_r0_body.cx0_57.mlx PRE_first_tail_x15_r0_body.kr0_57 PRE_first_tail_x15_r0_body.kr1_57 PRE_first_tail_x15_r0_body.clo57 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn57 : Nat.ble 2526 2535 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge57 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s563.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s564.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR57 : pendRegB PRE_first_tail_x15_r0_body.kappa57 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe57 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s563.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift57 (clean : Conv.NClean (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P57.NL) (cl : SSt (· < 2535) PRE_first_tail_x15_r0_body.cx0_57.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_57.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_57.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_57.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_57.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P57 2535 PRE_first_tail_x15_r0_body.kappa57 PRE_first_tail_x15_r0_body.s564.ffi PRE_first_tail_x15_r0_body.s563.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift57 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue57, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp57 t ht),
    PRE_first_tail_x15_r0_body.cbridge57,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s564.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s563.ffi) (PRE_first_tail_x15_r0_body.cfoot57 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_57 PRE_first_tail_x15_r0_body.ofx1_57 hobjC PRE_first_tail_x15_r0_body.ff057 PRE_first_tail_x15_r0_body.ff157 PRE_first_tail_x15_r0_body.ffck57,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s564.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s563.ffi) (PRE_first_tail_x15_r0_body.cfoot57 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_57 PRE_first_tail_x15_r0_body.okr1_57 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn57) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf057 PRE_first_tail_x15_r0_body.fkt057 PRE_first_tail_x15_r0_body.fkf157 PRE_first_tail_x15_r0_body.fkt157 PRE_first_tail_x15_r0_body.fkck57,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh057 PRE_first_tail_x15_r0_body.cnh157 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe57) PRE_first_tail_x15_r0_body.cpendR57⟩

end Host.Load.Run.Tpl
end

section -- st57/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st57 0
host_stream_state PRE_first_tail_x15_r0_body.st57 1
host_stream_state PRE_first_tail_x15_r0_body.st57 2
host_stream_state PRE_first_tail_x15_r0_body.st57 3
end Host.Load.Run.Tpl
end

section -- Site57
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 57 of chain `PRE_first_tail_x15_r0_body`: `kvW__g57__g58` (`appendWindow`), the call state `PRE_first_tail_x15_r0_body.s562`, the merged state `PRE_first_tail_x15_r0_body.s563`,
the site template `PRE_first_tail_x15_r0_body.st57` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s564`: the merge.
The footprint's facts are in `SiteF57`, the compaction's in `SiteC57`, `SiteK57`, `SiteNa57`, `SiteNb57`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso57 : PRE_first_tail_x15_r0_body.st57.s0 = { PRE_first_tail_x15_r0_body.s562 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs57 : List Frame := PRE_first_tail_x15_r0_body.s562.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_57 : PRE_first_tail_x15_r0_body.S562.tab.length = 2526
kernel_rfl PRE_first_tail_x15_r0_body.tab0_57 : PRE_first_tail_x15_r0_body.st57.S0.tab = PRE_first_tail_x15_r0_body.S562.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws57 : List Nat := [1976, 1977, 1978, 1979, 1980, 1981, 1982, 1983, 1984, 1985, 1986, 1987, 1988, 1989, 1990, 1991, 1992]
kernel_rfl PRE_first_tail_x15_r0_body.fresh57 : (PRE_first_tail_x15_r0_body.S562.tab.all fun e => PRE_first_tail_x15_r0_body.ws57.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S562.oracle.all fun q => PRE_first_tail_x15_r0_body.ws57.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab57 : PRE_first_tail_x15_r0_body.S563.tab = PRE_first_tail_x15_r0_body.S562.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws57
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen57 : PRE_first_tail_x15_r0_body.st57.S3.tab.length - PRE_first_tail_x15_r0_body.st57.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged57`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap57 : PRE_first_tail_x15_r0_body.s563.heap = PRE_first_tail_x15_r0_body.st57.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext57 : PRE_first_tail_x15_r0_body.s563.next = PRE_first_tail_x15_r0_body.st57.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl57 : PRE_first_tail_x15_r0_body.s563.ctl = PRE_first_tail_x15_r0_body.st57.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack57 : PRE_first_tail_x15_r0_body.s563.stack = PRE_first_tail_x15_r0_body.st57.s3.stack ++ PRE_first_tail_x15_r0_body.s562.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs57 : PRE_first_tail_x15_r0_body.s563.jobs = PRE_first_tail_x15_r0_body.st57.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi57 : PRE_first_tail_x15_r0_body.s563.ffi = PRE_first_tail_x15_r0_body.st57.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace57 : PRE_first_tail_x15_r0_body.s563.trace = PRE_first_tail_x15_r0_body.st57.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores57 : PRE_first_tail_x15_r0_body.s563.stores = PRE_first_tail_x15_r0_body.st57.s3.stores

end Host.Load.Run.Tpl
end

section -- SiteD57
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 57 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived57 : PRE_first_tail_x15_r0_body.nr57.map (fun r => nth? PRE_first_tail_x15_r0_body.st57.S3.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false)))]
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo57 : PRE_first_tail_x15_r0_body.nr57.all (Nat.ble 2526) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj57 : PRE_first_tail_x15_r0_body.cws57.all (fun c => !PRE_first_tail_x15_r0_body.ws57.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ57 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws57 PRE_first_tail_x15_r0_body.crs57 PRE_first_tail_x15_r0_body.ws57

end Host.Load.Run.Tpl
end

section -- st57/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st57`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st57.wrR : List (Nat × Nat) := [(2672446, 2672447)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st57.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st57.s3.heap PRE_first_tail_x15_r0_body.st57.wrR ++ freshOf PRE_first_tail_x15_r0_body.st57.s3.heap PRE_first_tail_x15_r0_body.st57.s0.next PRE_first_tail_x15_r0_body.st57.s3.next
noncomputable def PRE_first_tail_x15_r0_body.st57.wr : List Nat := PRE_first_tail_x15_r0_body.st57.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st57.heapFoot : PRE_first_tail_x15_r0_body.st57.s3.heap = setAll PRE_first_tail_x15_r0_body.st57.s0.heap PRE_first_tail_x15_r0_body.st57.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st57.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st57.s0.next PRE_first_tail_x15_r0_body.st57.s3.next = true
theorem PRE_first_tail_x15_r0_body.st57.grows : PRE_first_tail_x15_r0_body.st57.s0.next ≤ PRE_first_tail_x15_r0_body.st57.s3.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st57.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st57.wh : List Nat := [19337, 19338, 19339, 19340, 19341, 19342]
def PRE_first_tail_x15_r0_body.st57.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st57.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st57.s3.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st57.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st57.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st57.s3.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st57.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st57.s3.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st57.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st57.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st57.s3.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st57.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st57.s3.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st57.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st57.s3.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st57.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st57.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st57.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st57.s3.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st57.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st57.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st57.s3.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st57.s3.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st57.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st57.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st57.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st57.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st57.s3.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st57.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st57.s3.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF57
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 57 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB57 : nodupT PRE_first_tail_x15_r0_body.st57.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup57 : PRE_first_tail_x15_r0_body.st57.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB57).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB57 : PRE_first_tail_x15_r0_body.st57.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound57 : ∀ b ∈ PRE_first_tail_x15_r0_body.st57.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB57 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr57 := PRE_first_tail_x15_r0_body.st57.s3.trace.take 26
kernel_rfl PRE_first_tail_x15_r0_body.traceEq57 : PRE_first_tail_x15_r0_body.st57.s3.trace = PRE_first_tail_x15_r0_body.trFr57 ++ PRE_first_tail_x15_r0_body.st57.s0.trace
theorem PRE_first_tail_x15_r0_body.trace57 : ∃ fr, PRE_first_tail_x15_r0_body.st57.s3.trace = fr ++ PRE_first_tail_x15_r0_body.st57.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq57⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide57 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB57 : (PRE_first_tail_x15_r0_body.wide57.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st57.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix57 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide57, WFix Map.id (Present PRE_first_tail_x15_r0_body.st57.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB57 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL57
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 57 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s563`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO57 : PRE_first_tail_x15_r0_body.st57.S0.oracle = PRE_first_tail_x15_r0_body.st57.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B57 : PRE_first_tail_x15_r0_body.st57.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st57.s0.next || (PRE_first_tail_x15_r0_body.st57.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot57 : Conv.StageFoot PRE_first_tail_x15_r0_body.st57.wr PRE_first_tail_x15_r0_body.st57.s0 PRE_first_tail_x15_r0_body.st57.s3 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st57.heapFoot PRE_first_tail_x15_r0_body.wrNodup57 PRE_first_tail_x15_r0_body.wrBound57 PRE_first_tail_x15_r0_body.wr0B57 PRE_first_tail_x15_r0_body.st57.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged57 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st57.F.S → PRE_first_tail_x15_r0_body.st57.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st57.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st57.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs57 PRE_first_tail_x15_r0_body.st57.wr PRE_first_tail_x15_r0_body.s562 PRE_first_tail_x15_r0_body.st57.s3 PRE_first_tail_x15_r0_body.st57.s0
      PRE_first_tail_x15_r0_body.st57.s3.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st57.F FR W stk M ν K PRE_first_tail_x15_r0_body.s563 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso57 PRE_first_tail_x15_r0_body.stFoot57 PRE_first_tail_x15_r0_body.wrNodup57 PRE_first_tail_x15_r0_body.wrBound57 PRE_first_tail_x15_r0_body.trace57 PRE_first_tail_x15_r0_body.mheap57
    PRE_first_tail_x15_r0_body.mnext57 PRE_first_tail_x15_r0_body.mctl57 PRE_first_tail_x15_r0_body.mstack57 PRE_first_tail_x15_r0_body.mjobs57 PRE_first_tail_x15_r0_body.mffi57 PRE_first_tail_x15_r0_body.mtrace57 PRE_first_tail_x15_r0_body.mstores57 h

def PRE_first_tail_x15_r0_body.arrEl57_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE57_2665 : arrOf PRE_first_tail_x15_r0_body.s563 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl57_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA57_2665 : isArrB PRE_first_tail_x15_r0_body.s563 2665 = true
theorem PRE_first_tail_x15_r0_body.arr57_2665 : ∃ o, PRE_first_tail_x15_r0_body.s563.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl57_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE57_2665 PRE_first_tail_x15_r0_body.arrA57_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN57_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl57_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR57_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl57_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN57_2665

def PRE_first_tail_x15_r0_body.arrEl57_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE57_2673467 : arrOf PRE_first_tail_x15_r0_body.s563 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl57_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA57_2673467 : isArrB PRE_first_tail_x15_r0_body.s563 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr57_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s563.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl57_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE57_2673467 PRE_first_tail_x15_r0_body.arrA57_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN57_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl57_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR57_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl57_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN57_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k57 : isArrB PRE_first_tail_x15_r0_body.s563 4910 = false
theorem PRE_first_tail_x15_r0_body.keep57 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s563 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k57 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr57_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl57_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ57
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 57 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s562`, the merged
state `PRE_first_tail_x15_r0_body.s563`, the canonical state `PRE_first_tail_x15_r0_body.s564`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl57 : PRE_first_tail_x15_r0_body.pl57.all (Nat.ble PRE_first_tail_x15_r0_body.s562.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd57 : nodupT PRE_first_tail_x15_r0_body.pl57 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn157 : Nat.ble PRE_first_tail_x15_r0_body.s562.next 2720533 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst57 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s562.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn57 : PRE_first_tail_x15_r0_body.s564.next = PRE_first_tail_x15_r0_body.s562.next + PRE_first_tail_x15_r0_body.pl57.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn57 : PRE_first_tail_x15_r0_body.s563.next = 2720533
kernel_rfl PRE_first_tail_x15_r0_body.zgrow57 : Nat.ble PRE_first_tail_x15_r0_body.s564.next PRE_first_tail_x15_r0_body.s563.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh57 : PRE_first_tail_x15_r0_body.S562.tab.all (fun e => PRE_first_tail_x15_r0_body.cws57.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd57 : nodupT PRE_first_tail_x15_r0_body.cws57 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi57 : PRE_first_tail_x15_r0_body.nr57.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S563.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt57 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s562.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg57_2665 : PRE_first_tail_x15_r0_body.s564.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s564 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk57_2665 : (objOf PRE_first_tail_x15_r0_body.s564 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm57_2665 : PRE_first_tail_x15_r0_body.s563.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa57.obj (objOf PRE_first_tail_x15_r0_body.s564 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s563 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg57_2673467 : PRE_first_tail_x15_r0_body.s564.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s564 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk57_2673467 : (objOf PRE_first_tail_x15_r0_body.s564 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm57_2673467 : PRE_first_tail_x15_r0_body.s563.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa57.obj (objOf PRE_first_tail_x15_r0_body.s564 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s563 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw57_4910 : (PRE_first_tail_x15_r0_body.s564.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw57_2673472 : (PRE_first_tail_x15_r0_body.s564.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw57_2673473 : (PRE_first_tail_x15_r0_body.s564.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd57 : PRE_first_tail_x15_r0_body.cl57.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr57 : PRE_first_tail_x15_r0_body.st57.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s562.next || PRE_first_tail_x15_r0_body.cl57.contains b) = true
def PRE_first_tail_x15_r0_body.zl57 : List Nat := PRE_first_tail_x15_r0_body.cl57.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE57 : PRE_first_tail_x15_r0_body.zl57.map (fun a => PRE_first_tail_x15_r0_body.s563.heap.get (PRE_first_tail_x15_r0_body.kappa57.a a)) = PRE_first_tail_x15_r0_body.zl57.map (fun a => (PRE_first_tail_x15_r0_body.s564.heap.get a).map PRE_first_tail_x15_r0_body.kappa57.hobj)
theorem PRE_first_tail_x15_r0_body.zimg57 : HeapImg PRE_first_tail_x15_r0_body.kappa57 PRE_first_tail_x15_r0_body.s564 PRE_first_tail_x15_r0_body.s563 PRE_first_tail_x15_r0_body.zl57 := PRE_first_tail_x15_r0_body.zimgE57
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl57 : PRE_first_tail_x15_r0_body.s563.ctl = PRE_first_tail_x15_r0_body.kappa57.ctl PRE_first_tail_x15_r0_body.s564.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack57 : PRE_first_tail_x15_r0_body.s563.stack = PRE_first_tail_x15_r0_body.s564.stack.map PRE_first_tail_x15_r0_body.kappa57.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs57 : PRE_first_tail_x15_r0_body.s563.jobs = PRE_first_tail_x15_r0_body.s564.jobs.map PRE_first_tail_x15_r0_body.kappa57.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores57 : PRE_first_tail_x15_r0_body.s563.stores = PRE_first_tail_x15_r0_body.kappa57.stores PRE_first_tail_x15_r0_body.s564.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots57 : checkRootsSupp PRE_first_tail_x15_r0_body.s564 2535 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC57 : PRE_first_tail_x15_r0_body.S562.tab.length + PRE_first_tail_x15_r0_body.cws57.length = 2535
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap57 : PRE_first_tail_x15_r0_body.kappa57 = Conv.Map.compact PRE_first_tail_x15_r0_body.s562.next 2720533 PRE_first_tail_x15_r0_body.S562.tab.length PRE_first_tail_x15_r0_body.pl57 (PRE_first_tail_x15_r0_body.nr57.map NumV.ref) PRE_first_tail_x15_r0_body.kd57.big
  PRE_first_tail_x15_r0_body.kd57.region PRE_first_tail_x15_r0_body.kd57.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin57 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s564.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc57 : Conv.jcleanListB (⟨19341, 16430, 2720183, 2535⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s564 PRE_first_tail_x15_r0_body.cl57 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB57 : noBigRootsP (fun i => !Conv.oldBigB (⟨19341, 16430, 2720183, 2535⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s564.trace PRE_first_tail_x15_r0_body.s564 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm57 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16424 = true
theorem PRE_first_tail_x15_r0_body.cjcl57 (h : Conv.JClean (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s562) : Conv.JClean (⟨19341, 16430, 2720183, 2535⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s564 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle57)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap57 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd57 a ha)) PRE_first_tail_x15_r0_body.zjc57

end Host.Load.Run.Tpl
end

section -- st57/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st57.bodyLast from PRE_first_tail_x15_r0_body.st57.s2 to PRE_first_tail_x15_r0_body.st57.s3 :
  interpS (step PRE_first_tail_x15_r0_body.st57.F PRE_first_tail_x15_r0_body.st57.s2).run PRE_first_tail_x15_r0_body.st57.S2 = some (PRE_first_tail_x15_r0_body.st57.s3, PRE_first_tail_x15_r0_body.st57.S3)
kernel_rfl PRE_first_tail_x15_r0_body.st57.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st57.s2.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st57.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st57.s3.stack = true

end Host.Load.Run.Tpl
end

section -- st57/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st57.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st57.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st57.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st57.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st57.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st57.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st57.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st57.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st57.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st57.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st57.s0 PRE_first_tail_x15_r0_body.st57.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st57.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st57.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st57.s2 PRE_first_tail_x15_r0_body.st57.S2) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st57/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st57.bodyK0F from PRE_first_tail_x15_r0_body.st57.s0 to PRE_first_tail_x15_r0_body.st57.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st57.F (PRE_first_tail_x15_r0_body.st57.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st57.ks 0).getD 0) PRE_first_tail_x15_r0_body.st57.s0 PRE_first_tail_x15_r0_body.st57.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st57.s1, PRE_first_tail_x15_r0_body.st57.S1)
theorem PRE_first_tail_x15_r0_body.st57.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st57.F (PRE_first_tail_x15_r0_body.st57.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st57.ks 0).getD 0) PRE_first_tail_x15_r0_body.st57.s0 PRE_first_tail_x15_r0_body.st57.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st57.s1, PRE_first_tail_x15_r0_body.st57.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st57.bodyOkLN_ok PRE_first_tail_x15_r0_body.st57.bodyK0F
end Host.Load.Run.Tpl
end

section -- st57/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st57.bodyK1F from PRE_first_tail_x15_r0_body.st57.s1 to PRE_first_tail_x15_r0_body.st57.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st57.F (PRE_first_tail_x15_r0_body.st57.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st57.ks 1).getD 0) PRE_first_tail_x15_r0_body.st57.s1 PRE_first_tail_x15_r0_body.st57.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st57.s2, PRE_first_tail_x15_r0_body.st57.S2)
theorem PRE_first_tail_x15_r0_body.st57.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st57.F (PRE_first_tail_x15_r0_body.st57.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st57.ks 1).getD 0) PRE_first_tail_x15_r0_body.st57.s1 PRE_first_tail_x15_r0_body.st57.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st57.s2, PRE_first_tail_x15_r0_body.st57.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st57.bodyOkLN_ok PRE_first_tail_x15_r0_body.st57.bodyK1F
end Host.Load.Run.Tpl
end

section -- st57/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st57.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st57.F (PRE_first_tail_x15_r0_body.st57.bodyOkL bytes rows) 3452 PRE_first_tail_x15_r0_body.st57.s0 PRE_first_tail_x15_r0_body.st57.S0 = some (PRE_first_tail_x15_r0_body.st57.s2, PRE_first_tail_x15_r0_body.st57.S2) :=
  runOk_trans PRE_first_tail_x15_r0_body.st57.F (PRE_first_tail_x15_r0_body.st57.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st57.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st57.ks 1).getD 0) PRE_first_tail_x15_r0_body.st57.s0 PRE_first_tail_x15_r0_body.st57.s1 PRE_first_tail_x15_r0_body.st57.s2 PRE_first_tail_x15_r0_body.st57.S0 PRE_first_tail_x15_r0_body.st57.S1 PRE_first_tail_x15_r0_body.st57.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st57.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st57.bodyK1 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st57.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st57.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st57.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st57.F (PRE_first_tail_x15_r0_body.st57.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st57.s0
  S0 := PRE_first_tail_x15_r0_body.st57.S0
  s1 := PRE_first_tail_x15_r0_body.st57.s2
  S1 := PRE_first_tail_x15_r0_body.st57.S2
  s2 := PRE_first_tail_x15_r0_body.st57.s3
  S2 := PRE_first_tail_x15_r0_body.st57.S3
  n := 3452
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st57.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st57.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st57.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st57.bodyHalt
  last := PRE_first_tail_x15_r0_body.st57.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st57.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC58
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 58 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s572` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa58` into the merged state
`PRE_first_tail_x15_r0_body.s571`. -/

def PRE_first_tail_x15_r0_body.pl58 : List Nat := []
def PRE_first_tail_x15_r0_body.nr58 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd58 : RData :=
  ⟨2720765, 2720767, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19354, 19354, 16440, 16440, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa58 : Map :=
  Conv.Map.compact 2720765 2720767 2558 PRE_first_tail_x15_r0_body.pl58 (PRE_first_tail_x15_r0_body.nr58.map NumV.ref) PRE_first_tail_x15_r0_body.kd58.big
    PRE_first_tail_x15_r0_body.kd58.region PRE_first_tail_x15_r0_body.kd58.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws58 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs58 : List SymE := PRE_first_tail_x15_r0_body.nr58.map fun r => (nth? PRE_first_tail_x15_r0_body.S571.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta58 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws58 PRE_first_tail_x15_r0_body.crs58
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB58 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab58 : PRE_first_tail_x15_r0_body.S572.tab = PRE_first_tail_x15_r0_body.S570.tab ++ PRE_first_tail_x15_r0_body.cws58.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace58 : PRE_first_tail_x15_r0_body.s572.trace = PRE_first_tail_x15_r0_body.s570.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext58 : PRE_first_tail_x15_r0_body.s572.next = 2720765
kernel_rfl PRE_first_tail_x15_r0_body.ccounters58 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi).mlx.nnext) = (19354, 16440)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue58 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s571.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa58.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp58 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi).mlx.tokens.all (bSN 2558) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean58 : Conv.cleanListB 19354 131072 (fun r => Nat.ble 77416 r) PRE_first_tail_x15_r0_body.s572
    (PRE_first_tail_x15_r0_body.wrB58 ++ (List.range 0).map (2720765 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs58 : bigsOutB 19354 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK58
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl58`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl58 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo58 : List Nat := []
def PRE_first_tail_x15_r0_body.cln58 : List Nat := []
def PRE_first_tail_x15_r0_body.cli58 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap58 : PRE_first_tail_x15_r0_body.s572.heap = Stage.setAll PRE_first_tail_x15_r0_body.s570.heap (PRE_first_tail_x15_r0_body.cl58.filterMap fun a => (PRE_first_tail_x15_r0_body.s572.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe58 : Nat.ble PRE_first_tail_x15_r0_body.s570.next PRE_first_tail_x15_r0_body.s572.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP58 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s570 PRE_first_tail_x15_r0_body.s572 PRE_first_tail_x15_r0_body.cl58 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp58 : Conv.suppListB PRE_first_tail_x15_r0_body.s572 2558 PRE_first_tail_x15_r0_body.cl58 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound58 : Conv.boundListB PRE_first_tail_x15_r0_body.s572 PRE_first_tail_x15_r0_body.cl58 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK58 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln58.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK58 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo58.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK58 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli58.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst58 : Conv.sstListB 2558 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi).mlx PRE_first_tail_x15_r0_body.cln58 PRE_first_tail_x15_r0_body.clo58 PRE_first_tail_x15_r0_body.cli58 = true

end Host.Load.Run.Tpl
end

section -- SiteCl58
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA58 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo58.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd58 : (PRE_first_tail_x15_r0_body.clo58 ++ PRE_first_tail_x15_r0_body.cln58 ++ PRE_first_tail_x15_r0_body.cli58).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle58 : Conv.Cnt.leB (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck58 : Conv.ncleanListB (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi).mlx PRE_first_tail_x15_r0_body.clo58 PRE_first_tail_x15_r0_body.cln58 PRE_first_tail_x15_r0_body.cli58 = true
theorem PRE_first_tail_x15_r0_body.cncl58 (h : Conv.NClean (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx) : Conv.NClean (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle58 PRE_first_tail_x15_r0_body.ckA58 PRE_first_tail_x15_r0_body.cobjsK58 PRE_first_tail_x15_r0_body.cnodesK58 PRE_first_tail_x15_r0_body.citemsK58 PRE_first_tail_x15_r0_body.cbd58 PRE_first_tail_x15_r0_body.cck58

end Host.Load.Run.Tpl
end

section -- SiteS58
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 58 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc58 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P58 : LoadP := PRE_first_tail_x15_r0_body.Pc58.raise 16440
kernel_rfl PRE_first_tail_x15_r0_body.craise58 : Nat.ble PRE_first_tail_x15_r0_body.Pc58.N0 16440 = true
theorem PRE_first_tail_x15_r0_body.raised58 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc58 PRE_first_tail_x15_r0_body.P58 :=
  .inr ⟨16440, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise58, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_58 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_58 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s571.ffi)
def PRE_first_tail_x15_r0_body.khinv58 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv58 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS58 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS58 : List Nat := List.range' 16440 0
def PRE_first_tail_x15_r0_body.ciS58 : List Nat := [] ++ List.range' 16440 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh058 : PRE_first_tail_x15_r0_body.kd58.nh0 = PRE_first_tail_x15_r0_body.cx0_58.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh158 : PRE_first_tail_x15_r0_body.kd58.nh1 = PRE_first_tail_x15_r0_body.cx1_58.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn058 : PRE_first_tail_x15_r0_body.kd58.nn0 = PRE_first_tail_x15_r0_body.cx0_58.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn158 : PRE_first_tail_x15_r0_body.kd58.nn1 = PRE_first_tail_x15_r0_body.cx1_58.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo58 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P58.lo && Nat.ble PRE_first_tail_x15_r0_body.P58.lo PRE_first_tail_x15_r0_body.cx0_58.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P58.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P58.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt58 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_58.mlx.next PRE_first_tail_x15_r0_body.cx1_58.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_58.mlx.nnext PRE_first_tail_x15_r0_body.cx1_58.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband58 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P58.NL && Nat.ble PRE_first_tail_x15_r0_body.P58.NL PRE_first_tail_x15_r0_body.P58.N0 && Nat.ble PRE_first_tail_x15_r0_body.P58.N0 PRE_first_tail_x15_r0_body.cx0_58.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow58 : PRE_first_tail_x15_r0_body.kd58.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren58 : checkRenG PRE_first_tail_x15_r0_body.kd58.hnd PRE_first_tail_x15_r0_body.khinv58 (phB PRE_first_tail_x15_r0_body.cx0_58.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband58 : PRE_first_tail_x15_r0_body.kd58.checkBand PRE_first_tail_x15_r0_body.P58.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos58 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd58.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren58 : checkRenG PRE_first_tail_x15_r0_body.kd58.node PRE_first_tail_x15_r0_body.kninv58 (pnB PRE_first_tail_x15_r0_body.cx0_58.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow58 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd58.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P58.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd58.nodeF j) PRE_first_tail_x15_r0_body.cx1_58.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a58 : PRE_first_tail_x15_r0_body.cx0_58.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b58 : PRE_first_tail_x15_r0_body.cx0_58.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok158 : PRE_first_tail_x15_r0_body.cx1_58.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend58 : PRE_first_tail_x15_r0_body.cx1_58.mlx.pending = PRE_first_tail_x15_r0_body.cx0_58.mlx.pending.map PRE_first_tail_x15_r0_body.kappa58.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh58 : PRE_first_tail_x15_r0_body.cx1_58.mlx.errh = PRE_first_tail_x15_r0_body.cx0_58.mlx.errh.map PRE_first_tail_x15_r0_body.kappa58.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles58 : PRE_first_tail_x15_r0_body.cx1_58.mlx.files = PRE_first_tail_x15_r0_body.cx0_58.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch58 : PRE_first_tail_x15_r0_body.cx1_58.mlx.arch = PRE_first_tail_x15_r0_body.cx0_58.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes58 : PRE_first_tail_x15_r0_body.cx1_58.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_58.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired58 : PRE_first_tail_x15_r0_body.cx1_58.mlx.wired = PRE_first_tail_x15_r0_body.cx0_58.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost58 : PRE_first_tail_x15_r0_body.cx1_58.host = PRE_first_tail_x15_r0_body.cx0_58.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd58`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn058 : PRE_first_tail_x15_r0_body.kd58.n0 = 2720765
kernel_rfl PRE_first_tail_x15_r0_body.ckn158 : PRE_first_tail_x15_r0_body.kd58.n1 = 2720767
kernel_rfl PRE_first_tail_x15_r0_body.ckheap58 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd58.heap).all (fun x => Nat.ble 2720765 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl58 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd58.heap.get (2720765 + j) = nth? PRE_first_tail_x15_r0_body.pl58 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja58 : Nat.ble 2720765 2720765 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn58 : Nat.ble 2558 2558 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD58 : Nat.ble 2720765 PRE_first_tail_x15_r0_body.kd58.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn58 : Nat.ble 19354 PRE_first_tail_x15_r0_body.kd58.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn58 : Nat.ble 16440 PRE_first_tail_x15_r0_body.kd58.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb58 : Nat.ble 19354 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap58 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd58.heap).all (Nat.ble (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd58 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd58.hnd).all (Nat.ble (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode58 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd58.node).all (Nat.ble (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix58 : Conv.FixOld (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa58 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja58) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn58) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD58) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn58) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn58) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb58) PRE_first_tail_x15_r0_body.fheap58 PRE_first_tail_x15_r0_body.fhnd58 PRE_first_tail_x15_r0_body.fnode58
kernel_rfl PRE_first_tail_x15_r0_body.fcxn58 : (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn58 : (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle058 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_58.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_58.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk58 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd58.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A58 : PRE_first_tail_x15_r0_body.cx1_58.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS58.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_58.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O58 : PRE_first_tail_x15_r0_body.cx1_58.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS58.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_58.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N58 : PRE_first_tail_x15_r0_body.cx1_58.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS58.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_58.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I58 : PRE_first_tail_x15_r0_body.cx1_58.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS58.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_58.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd58 : (PRE_first_tail_x15_r0_body.clo58 ++ PRE_first_tail_x15_r0_body.cln58 ++ PRE_first_tail_x15_r0_body.cli58 ++ PRE_first_tail_x15_r0_body.cwS58 ++ PRE_first_tail_x15_r0_body.cnS58 ++ PRE_first_tail_x15_r0_body.ciS58).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW58 : PRE_first_tail_x15_r0_body.cwS58.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo58.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI58 : PRE_first_tail_x15_r0_body.ciS58.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli58.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN58 : PRE_first_tail_x15_r0_body.cnS58.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF58 : PRE_first_tail_x15_r0_body.cln58.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh58 : PRE_first_tail_x15_r0_body.clo58.all (handleOK PRE_first_tail_x15_r0_body.kappa58 PRE_first_tail_x15_r0_body.P58.lo PRE_first_tail_x15_r0_body.cx0_58.mlx PRE_first_tail_x15_r0_body.cx1_58.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo58 : PRE_first_tail_x15_r0_body.clo58.map (fun h => PRE_first_tail_x15_r0_body.cx1_58.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa58.handle h)) = PRE_first_tail_x15_r0_body.clo58.map (fun h => (PRE_first_tail_x15_r0_body.cx0_58.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa58.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok58 : PRE_first_tail_x15_r0_body.clo58.all (objOK PRE_first_tail_x15_r0_body.kappa58 PRE_first_tail_x15_r0_body.P58.NL PRE_first_tail_x15_r0_body.cx0_58.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd58 : PRE_first_tail_x15_r0_body.cln58.all (nodeOKF PRE_first_tail_x15_r0_body.kappa58 PRE_first_tail_x15_r0_body.P58 PRE_first_tail_x15_r0_body.cx0_58.mlx PRE_first_tail_x15_r0_body.cx1_58.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp58 : ((PRE_first_tail_x15_r0_body.cln58.filter (fullB PRE_first_tail_x15_r0_body.P58))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_58.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa58.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln58.filter (fullB PRE_first_tail_x15_r0_body.P58))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_58.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa58.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI58 : incrB PRE_first_tail_x15_r0_body.kd58.nodeF (List.range' 16440 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK58 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd58.node).all (fun k => Nat.ble 16440 k && Nat.blt k 16440) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL58 : (PRE_first_tail_x15_r0_body.cln58.filter (Nat.ble PRE_first_tail_x15_r0_body.P58.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd58.nodeF i) && (Nat.blt i 16440 || Nat.ble PRE_first_tail_x15_r0_body.kd58.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord58 : (PRE_first_tail_x15_r0_body.cln58.filter (Nat.ble PRE_first_tail_x15_r0_body.P58.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd58.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd58.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd58.nodeF j) (PRE_first_tail_x15_r0_body.kd58.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow58 PRE_first_tail_x15_r0_body.cnn158 PRE_first_tail_x15_r0_body.fnordI58 PRE_first_tail_x15_r0_body.fnordK58 PRE_first_tail_x15_r0_body.fnordL58
kernel_rfl PRE_first_tail_x15_r0_body.fi58 : PRE_first_tail_x15_r0_body.cli58.all (pnB PRE_first_tail_x15_r0_body.cx0_58.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii58 : PRE_first_tail_x15_r0_body.cli58.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_58.mlx.items.get (PRE_first_tail_x15_r0_body.kappa58.node k) = (PRE_first_tail_x15_r0_body.cx0_58.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa58.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot58 (clean : Conv.NClean (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P58.NL) (cl : SSt (· < 2558) PRE_first_tail_x15_r0_body.cx0_58.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P58 2558 PRE_first_tail_x15_r0_body.kappa58 PRE_first_tail_x15_r0_body.kd58 PRE_first_tail_x15_r0_body.khinv58 PRE_first_tail_x15_r0_body.kninv58 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx PRE_first_tail_x15_r0_body.cx0_58.mlx PRE_first_tail_x15_r0_body.cx1_58.mlx (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo58 PRE_first_tail_x15_r0_body.cln58 PRE_first_tail_x15_r0_body.cli58 PRE_first_tail_x15_r0_body.cwS58 PRE_first_tail_x15_r0_body.cnS58 PRE_first_tail_x15_r0_body.ciS58 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh058, PRE_first_tail_x15_r0_body.cnh158, PRE_first_tail_x15_r0_body.cnn058, PRE_first_tail_x15_r0_body.cnn158, PRE_first_tail_x15_r0_body.cplo58, PRE_first_tail_x15_r0_body.ccnt58, PRE_first_tail_x15_r0_body.cnband58, PRE_first_tail_x15_r0_body.chbelow58, PRE_first_tail_x15_r0_body.chren58, PRE_first_tail_x15_r0_body.cband58, PRE_first_tail_x15_r0_body.cnh1pos58, PRE_first_tail_x15_r0_body.cnren58, PRE_first_tail_x15_r0_body.cnlow58, PRE_first_tail_x15_r0_body.cabs0a58, PRE_first_tail_x15_r0_body.cabs0b58, PRE_first_tail_x15_r0_body.ctok158, PRE_first_tail_x15_r0_body.cpend58, PRE_first_tail_x15_r0_body.cerrh58, PRE_first_tail_x15_r0_body.cfiles58, PRE_first_tail_x15_r0_body.carch58, PRE_first_tail_x15_r0_body.csizes58, PRE_first_tail_x15_r0_body.cwired58, PRE_first_tail_x15_r0_body.cfix58, clean, PRE_first_tail_x15_r0_body.fcxn58, PRE_first_tail_x15_r0_body.fcnn58, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle058, PRE_first_tail_x15_r0_body.fnk58, PRE_first_tail_x15_r0_body.ckA58, PRE_first_tail_x15_r0_body.cobjsK58, PRE_first_tail_x15_r0_body.cnodesK58, PRE_first_tail_x15_r0_body.citemsK58, PRE_first_tail_x15_r0_body.f1A58, PRE_first_tail_x15_r0_body.f1O58, PRE_first_tail_x15_r0_body.f1N58, PRE_first_tail_x15_r0_body.f1I58, PRE_first_tail_x15_r0_body.fbd58, PRE_first_tail_x15_r0_body.fincW58, PRE_first_tail_x15_r0_body.fincI58, PRE_first_tail_x15_r0_body.fincN58, PRE_first_tail_x15_r0_body.flnF58, PRE_first_tail_x15_r0_body.fh58, PRE_first_tail_x15_r0_body.fo58, PRE_first_tail_x15_r0_body.fok58, PRE_first_tail_x15_r0_body.fnd58, PRE_first_tail_x15_r0_body.fp58, PRE_first_tail_x15_r0_body.fnord58, PRE_first_tail_x15_r0_body.fi58, PRE_first_tail_x15_r0_body.fii58⟩
theorem PRE_first_tail_x15_r0_body.cnshift58 (clean : Conv.NClean (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P58.NL) (cl : SSt (· < 2558) PRE_first_tail_x15_r0_body.cx0_58.mlx) : NShift PRE_first_tail_x15_r0_body.P58 2558 PRE_first_tail_x15_r0_body.kappa58 PRE_first_tail_x15_r0_body.cx0_58 PRE_first_tail_x15_r0_body.cx1_58 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot58 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost58 (compact_a_eq PRE_first_tail_x15_r0_body.ckn058 PRE_first_tail_x15_r0_body.ckn158 PRE_first_tail_x15_r0_body.ckheap58 PRE_first_tail_x15_r0_body.ckpl58)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_58 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s570.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_58 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s570.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_58 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s570.ffi) = some PRE_first_tail_x15_r0_body.fxC_58
kernel_rfl PRE_first_tail_x15_r0_body.okrC_58 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s570.ffi) = some PRE_first_tail_x15_r0_body.krC_58
noncomputable def PRE_first_tail_x15_r0_body.fx0_58 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s572.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_58 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s572.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_58 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s572.ffi) = some PRE_first_tail_x15_r0_body.fx0_58
kernel_rfl PRE_first_tail_x15_r0_body.okr0_58 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s572.ffi) = some PRE_first_tail_x15_r0_body.kr0_58
noncomputable def PRE_first_tail_x15_r0_body.fx1_58 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s571.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_58 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s571.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_58 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s571.ffi) = some PRE_first_tail_x15_r0_body.fx1_58
kernel_rfl PRE_first_tail_x15_r0_body.okr1_58 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s571.ffi) = some PRE_first_tail_x15_r0_body.kr1_58
kernel_rfl PRE_first_tail_x15_r0_body.ff058 : PRE_first_tail_x15_r0_body.fx0_58 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_58 (PRE_first_tail_x15_r0_body.clo58.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_58.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff158 : PRE_first_tail_x15_r0_body.fx1_58 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_58 (PRE_first_tail_x15_r0_body.cwS58.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_58.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck58 : freedLB PRE_first_tail_x15_r0_body.kappa58 PRE_first_tail_x15_r0_body.cx0_58.mlx PRE_first_tail_x15_r0_body.fx0_58 PRE_first_tail_x15_r0_body.fx1_58 PRE_first_tail_x15_r0_body.clo58 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf058 : PRE_first_tail_x15_r0_body.kr0_58.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_58.flags (PRE_first_tail_x15_r0_body.clo58.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_58.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt058 : PRE_first_tail_x15_r0_body.kr0_58.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_58.targs (PRE_first_tail_x15_r0_body.clo58.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_58.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf158 : PRE_first_tail_x15_r0_body.kr1_58.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_58.flags (PRE_first_tail_x15_r0_body.cwS58.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_58.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt158 : PRE_first_tail_x15_r0_body.kr1_58.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_58.targs (PRE_first_tail_x15_r0_body.cwS58.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_58.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck58 : krecLB PRE_first_tail_x15_r0_body.kappa58 2558 PRE_first_tail_x15_r0_body.cx0_58.mlx PRE_first_tail_x15_r0_body.kr0_58 PRE_first_tail_x15_r0_body.kr1_58 PRE_first_tail_x15_r0_body.clo58 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn58 : Nat.ble 2558 2558 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge58 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s571.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s572.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR58 : pendRegB PRE_first_tail_x15_r0_body.kappa58 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe58 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s571.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift58 (clean : Conv.NClean (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P58.NL) (cl : SSt (· < 2558) PRE_first_tail_x15_r0_body.cx0_58.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_58.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_58.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_58.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_58.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P58 2558 PRE_first_tail_x15_r0_body.kappa58 PRE_first_tail_x15_r0_body.s572.ffi PRE_first_tail_x15_r0_body.s571.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift58 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue58, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp58 t ht),
    PRE_first_tail_x15_r0_body.cbridge58,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s572.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s571.ffi) (PRE_first_tail_x15_r0_body.cfoot58 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_58 PRE_first_tail_x15_r0_body.ofx1_58 hobjC PRE_first_tail_x15_r0_body.ff058 PRE_first_tail_x15_r0_body.ff158 PRE_first_tail_x15_r0_body.ffck58,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s572.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s571.ffi) (PRE_first_tail_x15_r0_body.cfoot58 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_58 PRE_first_tail_x15_r0_body.okr1_58 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn58) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf058 PRE_first_tail_x15_r0_body.fkt058 PRE_first_tail_x15_r0_body.fkf158 PRE_first_tail_x15_r0_body.fkt158 PRE_first_tail_x15_r0_body.fkck58,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh058 PRE_first_tail_x15_r0_body.cnh158 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe58) PRE_first_tail_x15_r0_body.cpendR58⟩

end Host.Load.Run.Tpl
end

section -- st58/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st58 0
host_stream_state PRE_first_tail_x15_r0_body.st58 1
host_stream_state PRE_first_tail_x15_r0_body.st58 2
end Host.Load.Run.Tpl
end

section -- Site58
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 58 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g58__g59` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s570`, the merged state `PRE_first_tail_x15_r0_body.s571`,
the site template `PRE_first_tail_x15_r0_body.st58` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s572`: the merge.
The footprint's facts are in `SiteF58`, the compaction's in `SiteC58`, `SiteK58`, `SiteNa58`, `SiteNb58`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso58 : PRE_first_tail_x15_r0_body.st58.s0 = { PRE_first_tail_x15_r0_body.s570 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs58 : List Frame := PRE_first_tail_x15_r0_body.s570.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_58 : PRE_first_tail_x15_r0_body.S570.tab.length = 2558
kernel_rfl PRE_first_tail_x15_r0_body.tab0_58 : PRE_first_tail_x15_r0_body.st58.S0.tab = PRE_first_tail_x15_r0_body.S570.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws58 : List Nat := [2002, 2003]
kernel_rfl PRE_first_tail_x15_r0_body.fresh58 : (PRE_first_tail_x15_r0_body.S570.tab.all fun e => PRE_first_tail_x15_r0_body.ws58.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S570.oracle.all fun q => PRE_first_tail_x15_r0_body.ws58.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab58 : PRE_first_tail_x15_r0_body.S571.tab = PRE_first_tail_x15_r0_body.S570.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws58
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen58 : PRE_first_tail_x15_r0_body.st58.S2.tab.length - PRE_first_tail_x15_r0_body.st58.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged58`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap58 : PRE_first_tail_x15_r0_body.s571.heap = PRE_first_tail_x15_r0_body.st58.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext58 : PRE_first_tail_x15_r0_body.s571.next = PRE_first_tail_x15_r0_body.st58.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl58 : PRE_first_tail_x15_r0_body.s571.ctl = PRE_first_tail_x15_r0_body.st58.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack58 : PRE_first_tail_x15_r0_body.s571.stack = PRE_first_tail_x15_r0_body.st58.s2.stack ++ PRE_first_tail_x15_r0_body.s570.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs58 : PRE_first_tail_x15_r0_body.s571.jobs = PRE_first_tail_x15_r0_body.st58.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi58 : PRE_first_tail_x15_r0_body.s571.ffi = PRE_first_tail_x15_r0_body.st58.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace58 : PRE_first_tail_x15_r0_body.s571.trace = PRE_first_tail_x15_r0_body.st58.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores58 : PRE_first_tail_x15_r0_body.s571.stores = PRE_first_tail_x15_r0_body.st58.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD58
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 58 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived58 : PRE_first_tail_x15_r0_body.nr58.map (fun r => nth? PRE_first_tail_x15_r0_body.st58.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo58 : PRE_first_tail_x15_r0_body.nr58.all (Nat.ble 2558) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj58 : PRE_first_tail_x15_r0_body.cws58.all (fun c => !PRE_first_tail_x15_r0_body.ws58.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ58 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws58 PRE_first_tail_x15_r0_body.crs58 PRE_first_tail_x15_r0_body.ws58

end Host.Load.Run.Tpl
end

section -- st58/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st58`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st58.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st58.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st58.s2.heap PRE_first_tail_x15_r0_body.st58.wrR ++ freshOf PRE_first_tail_x15_r0_body.st58.s2.heap PRE_first_tail_x15_r0_body.st58.s0.next PRE_first_tail_x15_r0_body.st58.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st58.wr : List Nat := PRE_first_tail_x15_r0_body.st58.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st58.heapFoot : PRE_first_tail_x15_r0_body.st58.s2.heap = setAll PRE_first_tail_x15_r0_body.st58.s0.heap PRE_first_tail_x15_r0_body.st58.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st58.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st58.s0.next PRE_first_tail_x15_r0_body.st58.s2.next = true
theorem PRE_first_tail_x15_r0_body.st58.grows : PRE_first_tail_x15_r0_body.st58.s0.next ≤ PRE_first_tail_x15_r0_body.st58.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st58.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st58.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st58.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st58.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st58.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st58.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st58.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st58.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st58.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st58.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st58.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st58.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st58.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st58.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st58.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st58.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st58.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st58.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st58.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st58.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st58.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st58.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st58.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st58.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st58.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st58.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st58.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st58.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st58.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st58.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st58.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st58.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF58
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 58 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB58 : nodupT PRE_first_tail_x15_r0_body.st58.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup58 : PRE_first_tail_x15_r0_body.st58.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB58).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB58 : PRE_first_tail_x15_r0_body.st58.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound58 : ∀ b ∈ PRE_first_tail_x15_r0_body.st58.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB58 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr58 := PRE_first_tail_x15_r0_body.st58.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq58 : PRE_first_tail_x15_r0_body.st58.s2.trace = PRE_first_tail_x15_r0_body.trFr58 ++ PRE_first_tail_x15_r0_body.st58.s0.trace
theorem PRE_first_tail_x15_r0_body.trace58 : ∃ fr, PRE_first_tail_x15_r0_body.st58.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st58.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq58⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide58 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB58 : (PRE_first_tail_x15_r0_body.wide58.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st58.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix58 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide58, WFix Map.id (Present PRE_first_tail_x15_r0_body.st58.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB58 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL58
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 58 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s571`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO58 : PRE_first_tail_x15_r0_body.st58.S0.oracle = PRE_first_tail_x15_r0_body.st58.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B58 : PRE_first_tail_x15_r0_body.st58.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st58.s0.next || (PRE_first_tail_x15_r0_body.st58.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot58 : Conv.StageFoot PRE_first_tail_x15_r0_body.st58.wr PRE_first_tail_x15_r0_body.st58.s0 PRE_first_tail_x15_r0_body.st58.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st58.heapFoot PRE_first_tail_x15_r0_body.wrNodup58 PRE_first_tail_x15_r0_body.wrBound58 PRE_first_tail_x15_r0_body.wr0B58 PRE_first_tail_x15_r0_body.st58.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged58 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st58.F.S → PRE_first_tail_x15_r0_body.st58.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st58.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st58.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs58 PRE_first_tail_x15_r0_body.st58.wr PRE_first_tail_x15_r0_body.s570 PRE_first_tail_x15_r0_body.st58.s2 PRE_first_tail_x15_r0_body.st58.s0
      PRE_first_tail_x15_r0_body.st58.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st58.F FR W stk M ν K PRE_first_tail_x15_r0_body.s571 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso58 PRE_first_tail_x15_r0_body.stFoot58 PRE_first_tail_x15_r0_body.wrNodup58 PRE_first_tail_x15_r0_body.wrBound58 PRE_first_tail_x15_r0_body.trace58 PRE_first_tail_x15_r0_body.mheap58
    PRE_first_tail_x15_r0_body.mnext58 PRE_first_tail_x15_r0_body.mctl58 PRE_first_tail_x15_r0_body.mstack58 PRE_first_tail_x15_r0_body.mjobs58 PRE_first_tail_x15_r0_body.mffi58 PRE_first_tail_x15_r0_body.mtrace58 PRE_first_tail_x15_r0_body.mstores58 h

def PRE_first_tail_x15_r0_body.arrEl58_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE58_2665 : arrOf PRE_first_tail_x15_r0_body.s571 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl58_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA58_2665 : isArrB PRE_first_tail_x15_r0_body.s571 2665 = true
theorem PRE_first_tail_x15_r0_body.arr58_2665 : ∃ o, PRE_first_tail_x15_r0_body.s571.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl58_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE58_2665 PRE_first_tail_x15_r0_body.arrA58_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN58_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl58_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR58_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl58_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN58_2665

def PRE_first_tail_x15_r0_body.arrEl58_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE58_2673467 : arrOf PRE_first_tail_x15_r0_body.s571 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl58_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA58_2673467 : isArrB PRE_first_tail_x15_r0_body.s571 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr58_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s571.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl58_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE58_2673467 PRE_first_tail_x15_r0_body.arrA58_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN58_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl58_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR58_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl58_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN58_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k58 : isArrB PRE_first_tail_x15_r0_body.s571 4910 = false
theorem PRE_first_tail_x15_r0_body.keep58 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s571 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k58 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr58_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl58_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ58
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 58 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s570`, the merged
state `PRE_first_tail_x15_r0_body.s571`, the canonical state `PRE_first_tail_x15_r0_body.s572`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl58 : PRE_first_tail_x15_r0_body.pl58.all (Nat.ble PRE_first_tail_x15_r0_body.s570.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd58 : nodupT PRE_first_tail_x15_r0_body.pl58 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn158 : Nat.ble PRE_first_tail_x15_r0_body.s570.next 2720767 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst58 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s570.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn58 : PRE_first_tail_x15_r0_body.s572.next = PRE_first_tail_x15_r0_body.s570.next + PRE_first_tail_x15_r0_body.pl58.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn58 : PRE_first_tail_x15_r0_body.s571.next = 2720767
kernel_rfl PRE_first_tail_x15_r0_body.zgrow58 : Nat.ble PRE_first_tail_x15_r0_body.s572.next PRE_first_tail_x15_r0_body.s571.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh58 : PRE_first_tail_x15_r0_body.S570.tab.all (fun e => PRE_first_tail_x15_r0_body.cws58.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd58 : nodupT PRE_first_tail_x15_r0_body.cws58 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi58 : PRE_first_tail_x15_r0_body.nr58.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S571.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt58 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s570.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg58_2665 : PRE_first_tail_x15_r0_body.s572.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s572 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk58_2665 : (objOf PRE_first_tail_x15_r0_body.s572 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm58_2665 : PRE_first_tail_x15_r0_body.s571.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa58.obj (objOf PRE_first_tail_x15_r0_body.s572 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s571 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg58_2673467 : PRE_first_tail_x15_r0_body.s572.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s572 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk58_2673467 : (objOf PRE_first_tail_x15_r0_body.s572 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm58_2673467 : PRE_first_tail_x15_r0_body.s571.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa58.obj (objOf PRE_first_tail_x15_r0_body.s572 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s571 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw58_4910 : (PRE_first_tail_x15_r0_body.s572.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw58_2673472 : (PRE_first_tail_x15_r0_body.s572.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw58_2673473 : (PRE_first_tail_x15_r0_body.s572.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd58 : PRE_first_tail_x15_r0_body.cl58.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr58 : PRE_first_tail_x15_r0_body.st58.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s570.next || PRE_first_tail_x15_r0_body.cl58.contains b) = true
def PRE_first_tail_x15_r0_body.zl58 : List Nat := PRE_first_tail_x15_r0_body.cl58.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE58 : PRE_first_tail_x15_r0_body.zl58.map (fun a => PRE_first_tail_x15_r0_body.s571.heap.get (PRE_first_tail_x15_r0_body.kappa58.a a)) = PRE_first_tail_x15_r0_body.zl58.map (fun a => (PRE_first_tail_x15_r0_body.s572.heap.get a).map PRE_first_tail_x15_r0_body.kappa58.hobj)
theorem PRE_first_tail_x15_r0_body.zimg58 : HeapImg PRE_first_tail_x15_r0_body.kappa58 PRE_first_tail_x15_r0_body.s572 PRE_first_tail_x15_r0_body.s571 PRE_first_tail_x15_r0_body.zl58 := PRE_first_tail_x15_r0_body.zimgE58
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl58 : PRE_first_tail_x15_r0_body.s571.ctl = PRE_first_tail_x15_r0_body.kappa58.ctl PRE_first_tail_x15_r0_body.s572.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack58 : PRE_first_tail_x15_r0_body.s571.stack = PRE_first_tail_x15_r0_body.s572.stack.map PRE_first_tail_x15_r0_body.kappa58.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs58 : PRE_first_tail_x15_r0_body.s571.jobs = PRE_first_tail_x15_r0_body.s572.jobs.map PRE_first_tail_x15_r0_body.kappa58.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores58 : PRE_first_tail_x15_r0_body.s571.stores = PRE_first_tail_x15_r0_body.kappa58.stores PRE_first_tail_x15_r0_body.s572.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots58 : checkRootsSupp PRE_first_tail_x15_r0_body.s572 2558 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC58 : PRE_first_tail_x15_r0_body.S570.tab.length + PRE_first_tail_x15_r0_body.cws58.length = 2558
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap58 : PRE_first_tail_x15_r0_body.kappa58 = Conv.Map.compact PRE_first_tail_x15_r0_body.s570.next 2720767 PRE_first_tail_x15_r0_body.S570.tab.length PRE_first_tail_x15_r0_body.pl58 (PRE_first_tail_x15_r0_body.nr58.map NumV.ref) PRE_first_tail_x15_r0_body.kd58.big
  PRE_first_tail_x15_r0_body.kd58.region PRE_first_tail_x15_r0_body.kd58.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin58 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s572.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc58 : Conv.jcleanListB (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s572 PRE_first_tail_x15_r0_body.cl58 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB58 : noBigRootsP (fun i => !Conv.oldBigB (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s572.trace PRE_first_tail_x15_r0_body.s572 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm58 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16440 = true
theorem PRE_first_tail_x15_r0_body.cjcl58 (h : Conv.JClean (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s570) : Conv.JClean (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s572 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle58)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap58 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd58 a ha)) PRE_first_tail_x15_r0_body.zjc58

end Host.Load.Run.Tpl
end

section -- st58/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st58.bodyLast from PRE_first_tail_x15_r0_body.st58.s1 to PRE_first_tail_x15_r0_body.st58.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st58.F PRE_first_tail_x15_r0_body.st58.s1).run PRE_first_tail_x15_r0_body.st58.S1 = some (PRE_first_tail_x15_r0_body.st58.s2, PRE_first_tail_x15_r0_body.st58.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st58.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st58.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st58.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st58.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st58/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st58.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st58.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st58.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st58.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st58.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st58.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st58.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st58.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st58.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st58.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st58.s0 PRE_first_tail_x15_r0_body.st58.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st58.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st58.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st58.s1 PRE_first_tail_x15_r0_body.st58.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st58/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st58.bodyK0F from PRE_first_tail_x15_r0_body.st58.s0 to PRE_first_tail_x15_r0_body.st58.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st58.F (PRE_first_tail_x15_r0_body.st58.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st58.ks 0).getD 0) PRE_first_tail_x15_r0_body.st58.s0 PRE_first_tail_x15_r0_body.st58.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st58.s1, PRE_first_tail_x15_r0_body.st58.S1)
theorem PRE_first_tail_x15_r0_body.st58.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st58.F (PRE_first_tail_x15_r0_body.st58.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st58.ks 0).getD 0) PRE_first_tail_x15_r0_body.st58.s0 PRE_first_tail_x15_r0_body.st58.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st58.s1, PRE_first_tail_x15_r0_body.st58.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st58.bodyOkLN_ok PRE_first_tail_x15_r0_body.st58.bodyK0F
end Host.Load.Run.Tpl
end

section -- st58/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st58.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st58.F (PRE_first_tail_x15_r0_body.st58.bodyOkL bytes rows) 27 PRE_first_tail_x15_r0_body.st58.s0 PRE_first_tail_x15_r0_body.st58.S0 = some (PRE_first_tail_x15_r0_body.st58.s1, PRE_first_tail_x15_r0_body.st58.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st58.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st58.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st58.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st58.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st58.F (PRE_first_tail_x15_r0_body.st58.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st58.s0
  S0 := PRE_first_tail_x15_r0_body.st58.S0
  s1 := PRE_first_tail_x15_r0_body.st58.s1
  S1 := PRE_first_tail_x15_r0_body.st58.S1
  s2 := PRE_first_tail_x15_r0_body.st58.s2
  S2 := PRE_first_tail_x15_r0_body.st58.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st58.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st58.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st58.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st58.bodyHalt
  last := PRE_first_tail_x15_r0_body.st58.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st58.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC59
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 59 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s576` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa59` into the merged state
`PRE_first_tail_x15_r0_body.s575`. -/

def PRE_first_tail_x15_r0_body.pl59 : List Nat := [2721063]
def PRE_first_tail_x15_r0_body.nr59 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd59 : RData :=
  ⟨2721054, 2721064, Stage.setAll PTrie.nil [(2721053, 2721063)], Stage.setAll PTrie.nil [],
   19361, 19361, 16444, 16444, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa59 : Map :=
  Conv.Map.compact 2721053 2721064 2575 PRE_first_tail_x15_r0_body.pl59 (PRE_first_tail_x15_r0_body.nr59.map NumV.ref) PRE_first_tail_x15_r0_body.kd59.big
    PRE_first_tail_x15_r0_body.kd59.region PRE_first_tail_x15_r0_body.kd59.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws59 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs59 : List SymE := PRE_first_tail_x15_r0_body.nr59.map fun r => (nth? PRE_first_tail_x15_r0_body.S575.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta59 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws59 PRE_first_tail_x15_r0_body.crs59
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB59 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab59 : PRE_first_tail_x15_r0_body.S576.tab = PRE_first_tail_x15_r0_body.S574.tab ++ PRE_first_tail_x15_r0_body.cws59.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace59 : PRE_first_tail_x15_r0_body.s576.trace = PRE_first_tail_x15_r0_body.s574.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext59 : PRE_first_tail_x15_r0_body.s576.next = 2721054
kernel_rfl PRE_first_tail_x15_r0_body.ccounters59 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx.nnext) = (19361, 16444)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue59 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s575.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa59.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp59 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx.tokens.all (bSN 2575) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean59 : Conv.cleanListB 19361 131072 (fun r => Nat.ble 77444 r) PRE_first_tail_x15_r0_body.s576
    (PRE_first_tail_x15_r0_body.wrB59 ++ (List.range 1).map (2721053 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs59 : bigsOutB 19361 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK59
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl59`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl59 : List Nat := [2665, 2673467, 2721053]
def PRE_first_tail_x15_r0_body.clo59 : List Nat := []
def PRE_first_tail_x15_r0_body.cln59 : List Nat := []
def PRE_first_tail_x15_r0_body.cli59 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap59 : PRE_first_tail_x15_r0_body.s576.heap = Stage.setAll PRE_first_tail_x15_r0_body.s574.heap (PRE_first_tail_x15_r0_body.cl59.filterMap fun a => (PRE_first_tail_x15_r0_body.s576.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe59 : Nat.ble PRE_first_tail_x15_r0_body.s574.next PRE_first_tail_x15_r0_body.s576.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP59 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s574 PRE_first_tail_x15_r0_body.s576 PRE_first_tail_x15_r0_body.cl59 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp59 : Conv.suppListB PRE_first_tail_x15_r0_body.s576 2575 PRE_first_tail_x15_r0_body.cl59 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound59 : Conv.boundListB PRE_first_tail_x15_r0_body.s576 PRE_first_tail_x15_r0_body.cl59 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK59 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln59.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK59 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo59.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK59 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli59.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst59 : Conv.sstListB 2575 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx PRE_first_tail_x15_r0_body.cln59 PRE_first_tail_x15_r0_body.clo59 PRE_first_tail_x15_r0_body.cli59 = true

end Host.Load.Run.Tpl
end

section -- SiteCl59
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA59 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo59.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd59 : (PRE_first_tail_x15_r0_body.clo59 ++ PRE_first_tail_x15_r0_body.cln59 ++ PRE_first_tail_x15_r0_body.cli59).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle59 : Conv.Cnt.leB (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt) (⟨19361, 16444, 2721054, 2575⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck59 : Conv.ncleanListB (⟨19361, 16444, 2721054, 2575⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx PRE_first_tail_x15_r0_body.clo59 PRE_first_tail_x15_r0_body.cln59 PRE_first_tail_x15_r0_body.cli59 = true
theorem PRE_first_tail_x15_r0_body.cncl59 (h : Conv.NClean (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx) : Conv.NClean (⟨19361, 16444, 2721054, 2575⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle59 PRE_first_tail_x15_r0_body.ckA59 PRE_first_tail_x15_r0_body.cobjsK59 PRE_first_tail_x15_r0_body.cnodesK59 PRE_first_tail_x15_r0_body.citemsK59 PRE_first_tail_x15_r0_body.cbd59 PRE_first_tail_x15_r0_body.cck59

end Host.Load.Run.Tpl
end

section -- SiteS59
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 59 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc59 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P59 : LoadP := PRE_first_tail_x15_r0_body.Pc59.raise 16444
kernel_rfl PRE_first_tail_x15_r0_body.craise59 : Nat.ble PRE_first_tail_x15_r0_body.Pc59.N0 16444 = true
theorem PRE_first_tail_x15_r0_body.raised59 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc59 PRE_first_tail_x15_r0_body.P59 :=
  .inr ⟨16444, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise59, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_59 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_59 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s575.ffi)
def PRE_first_tail_x15_r0_body.khinv59 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv59 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS59 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS59 : List Nat := List.range' 16444 0
def PRE_first_tail_x15_r0_body.ciS59 : List Nat := [] ++ List.range' 16444 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh059 : PRE_first_tail_x15_r0_body.kd59.nh0 = PRE_first_tail_x15_r0_body.cx0_59.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh159 : PRE_first_tail_x15_r0_body.kd59.nh1 = PRE_first_tail_x15_r0_body.cx1_59.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn059 : PRE_first_tail_x15_r0_body.kd59.nn0 = PRE_first_tail_x15_r0_body.cx0_59.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn159 : PRE_first_tail_x15_r0_body.kd59.nn1 = PRE_first_tail_x15_r0_body.cx1_59.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo59 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P59.lo && Nat.ble PRE_first_tail_x15_r0_body.P59.lo PRE_first_tail_x15_r0_body.cx0_59.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P59.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P59.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt59 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_59.mlx.next PRE_first_tail_x15_r0_body.cx1_59.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_59.mlx.nnext PRE_first_tail_x15_r0_body.cx1_59.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband59 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P59.NL && Nat.ble PRE_first_tail_x15_r0_body.P59.NL PRE_first_tail_x15_r0_body.P59.N0 && Nat.ble PRE_first_tail_x15_r0_body.P59.N0 PRE_first_tail_x15_r0_body.cx0_59.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow59 : PRE_first_tail_x15_r0_body.kd59.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren59 : checkRenG PRE_first_tail_x15_r0_body.kd59.hnd PRE_first_tail_x15_r0_body.khinv59 (phB PRE_first_tail_x15_r0_body.cx0_59.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband59 : PRE_first_tail_x15_r0_body.kd59.checkBand PRE_first_tail_x15_r0_body.P59.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos59 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd59.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren59 : checkRenG PRE_first_tail_x15_r0_body.kd59.node PRE_first_tail_x15_r0_body.kninv59 (pnB PRE_first_tail_x15_r0_body.cx0_59.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow59 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd59.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P59.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd59.nodeF j) PRE_first_tail_x15_r0_body.cx1_59.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a59 : PRE_first_tail_x15_r0_body.cx0_59.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b59 : PRE_first_tail_x15_r0_body.cx0_59.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok159 : PRE_first_tail_x15_r0_body.cx1_59.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend59 : PRE_first_tail_x15_r0_body.cx1_59.mlx.pending = PRE_first_tail_x15_r0_body.cx0_59.mlx.pending.map PRE_first_tail_x15_r0_body.kappa59.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh59 : PRE_first_tail_x15_r0_body.cx1_59.mlx.errh = PRE_first_tail_x15_r0_body.cx0_59.mlx.errh.map PRE_first_tail_x15_r0_body.kappa59.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles59 : PRE_first_tail_x15_r0_body.cx1_59.mlx.files = PRE_first_tail_x15_r0_body.cx0_59.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch59 : PRE_first_tail_x15_r0_body.cx1_59.mlx.arch = PRE_first_tail_x15_r0_body.cx0_59.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes59 : PRE_first_tail_x15_r0_body.cx1_59.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_59.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired59 : PRE_first_tail_x15_r0_body.cx1_59.mlx.wired = PRE_first_tail_x15_r0_body.cx0_59.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost59 : PRE_first_tail_x15_r0_body.cx1_59.host = PRE_first_tail_x15_r0_body.cx0_59.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd59`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn059 : PRE_first_tail_x15_r0_body.kd59.n0 = 2721054
kernel_rfl PRE_first_tail_x15_r0_body.ckn159 : PRE_first_tail_x15_r0_body.kd59.n1 = 2721064
kernel_rfl PRE_first_tail_x15_r0_body.ckheap59 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd59.heap).all (fun x => Nat.ble 2721053 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl59 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd59.heap.get (2721053 + j) = nth? PRE_first_tail_x15_r0_body.pl59 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja59 : Nat.ble 2721053 2721053 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn59 : Nat.ble 2575 2575 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD59 : Nat.ble 2721053 PRE_first_tail_x15_r0_body.kd59.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn59 : Nat.ble 19361 PRE_first_tail_x15_r0_body.kd59.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn59 : Nat.ble 16444 PRE_first_tail_x15_r0_body.kd59.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb59 : Nat.ble 19361 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap59 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd59.heap).all (Nat.ble (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd59 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd59.hnd).all (Nat.ble (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode59 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd59.node).all (Nat.ble (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix59 : Conv.FixOld (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa59 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja59) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn59) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD59) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn59) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn59) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb59) PRE_first_tail_x15_r0_body.fheap59 PRE_first_tail_x15_r0_body.fhnd59 PRE_first_tail_x15_r0_body.fnode59
kernel_rfl PRE_first_tail_x15_r0_body.fcxn59 : (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn59 : (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle059 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_59.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_59.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk59 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd59.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A59 : PRE_first_tail_x15_r0_body.cx1_59.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS59.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_59.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O59 : PRE_first_tail_x15_r0_body.cx1_59.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS59.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_59.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N59 : PRE_first_tail_x15_r0_body.cx1_59.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS59.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_59.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I59 : PRE_first_tail_x15_r0_body.cx1_59.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS59.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_59.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd59 : (PRE_first_tail_x15_r0_body.clo59 ++ PRE_first_tail_x15_r0_body.cln59 ++ PRE_first_tail_x15_r0_body.cli59 ++ PRE_first_tail_x15_r0_body.cwS59 ++ PRE_first_tail_x15_r0_body.cnS59 ++ PRE_first_tail_x15_r0_body.ciS59).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW59 : PRE_first_tail_x15_r0_body.cwS59.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo59.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI59 : PRE_first_tail_x15_r0_body.ciS59.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli59.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN59 : PRE_first_tail_x15_r0_body.cnS59.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF59 : PRE_first_tail_x15_r0_body.cln59.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh59 : PRE_first_tail_x15_r0_body.clo59.all (handleOK PRE_first_tail_x15_r0_body.kappa59 PRE_first_tail_x15_r0_body.P59.lo PRE_first_tail_x15_r0_body.cx0_59.mlx PRE_first_tail_x15_r0_body.cx1_59.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo59 : PRE_first_tail_x15_r0_body.clo59.map (fun h => PRE_first_tail_x15_r0_body.cx1_59.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa59.handle h)) = PRE_first_tail_x15_r0_body.clo59.map (fun h => (PRE_first_tail_x15_r0_body.cx0_59.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa59.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok59 : PRE_first_tail_x15_r0_body.clo59.all (objOK PRE_first_tail_x15_r0_body.kappa59 PRE_first_tail_x15_r0_body.P59.NL PRE_first_tail_x15_r0_body.cx0_59.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd59 : PRE_first_tail_x15_r0_body.cln59.all (nodeOKF PRE_first_tail_x15_r0_body.kappa59 PRE_first_tail_x15_r0_body.P59 PRE_first_tail_x15_r0_body.cx0_59.mlx PRE_first_tail_x15_r0_body.cx1_59.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp59 : ((PRE_first_tail_x15_r0_body.cln59.filter (fullB PRE_first_tail_x15_r0_body.P59))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_59.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa59.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln59.filter (fullB PRE_first_tail_x15_r0_body.P59))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_59.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa59.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI59 : incrB PRE_first_tail_x15_r0_body.kd59.nodeF (List.range' 16444 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK59 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd59.node).all (fun k => Nat.ble 16444 k && Nat.blt k 16444) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL59 : (PRE_first_tail_x15_r0_body.cln59.filter (Nat.ble PRE_first_tail_x15_r0_body.P59.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd59.nodeF i) && (Nat.blt i 16444 || Nat.ble PRE_first_tail_x15_r0_body.kd59.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord59 : (PRE_first_tail_x15_r0_body.cln59.filter (Nat.ble PRE_first_tail_x15_r0_body.P59.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd59.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd59.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd59.nodeF j) (PRE_first_tail_x15_r0_body.kd59.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow59 PRE_first_tail_x15_r0_body.cnn159 PRE_first_tail_x15_r0_body.fnordI59 PRE_first_tail_x15_r0_body.fnordK59 PRE_first_tail_x15_r0_body.fnordL59
kernel_rfl PRE_first_tail_x15_r0_body.fi59 : PRE_first_tail_x15_r0_body.cli59.all (pnB PRE_first_tail_x15_r0_body.cx0_59.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii59 : PRE_first_tail_x15_r0_body.cli59.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_59.mlx.items.get (PRE_first_tail_x15_r0_body.kappa59.node k) = (PRE_first_tail_x15_r0_body.cx0_59.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa59.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot59 (clean : Conv.NClean (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P59.NL) (cl : SSt (· < 2575) PRE_first_tail_x15_r0_body.cx0_59.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P59 2575 PRE_first_tail_x15_r0_body.kappa59 PRE_first_tail_x15_r0_body.kd59 PRE_first_tail_x15_r0_body.khinv59 PRE_first_tail_x15_r0_body.kninv59 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx PRE_first_tail_x15_r0_body.cx0_59.mlx PRE_first_tail_x15_r0_body.cx1_59.mlx (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo59 PRE_first_tail_x15_r0_body.cln59 PRE_first_tail_x15_r0_body.cli59 PRE_first_tail_x15_r0_body.cwS59 PRE_first_tail_x15_r0_body.cnS59 PRE_first_tail_x15_r0_body.ciS59 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh059, PRE_first_tail_x15_r0_body.cnh159, PRE_first_tail_x15_r0_body.cnn059, PRE_first_tail_x15_r0_body.cnn159, PRE_first_tail_x15_r0_body.cplo59, PRE_first_tail_x15_r0_body.ccnt59, PRE_first_tail_x15_r0_body.cnband59, PRE_first_tail_x15_r0_body.chbelow59, PRE_first_tail_x15_r0_body.chren59, PRE_first_tail_x15_r0_body.cband59, PRE_first_tail_x15_r0_body.cnh1pos59, PRE_first_tail_x15_r0_body.cnren59, PRE_first_tail_x15_r0_body.cnlow59, PRE_first_tail_x15_r0_body.cabs0a59, PRE_first_tail_x15_r0_body.cabs0b59, PRE_first_tail_x15_r0_body.ctok159, PRE_first_tail_x15_r0_body.cpend59, PRE_first_tail_x15_r0_body.cerrh59, PRE_first_tail_x15_r0_body.cfiles59, PRE_first_tail_x15_r0_body.carch59, PRE_first_tail_x15_r0_body.csizes59, PRE_first_tail_x15_r0_body.cwired59, PRE_first_tail_x15_r0_body.cfix59, clean, PRE_first_tail_x15_r0_body.fcxn59, PRE_first_tail_x15_r0_body.fcnn59, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle059, PRE_first_tail_x15_r0_body.fnk59, PRE_first_tail_x15_r0_body.ckA59, PRE_first_tail_x15_r0_body.cobjsK59, PRE_first_tail_x15_r0_body.cnodesK59, PRE_first_tail_x15_r0_body.citemsK59, PRE_first_tail_x15_r0_body.f1A59, PRE_first_tail_x15_r0_body.f1O59, PRE_first_tail_x15_r0_body.f1N59, PRE_first_tail_x15_r0_body.f1I59, PRE_first_tail_x15_r0_body.fbd59, PRE_first_tail_x15_r0_body.fincW59, PRE_first_tail_x15_r0_body.fincI59, PRE_first_tail_x15_r0_body.fincN59, PRE_first_tail_x15_r0_body.flnF59, PRE_first_tail_x15_r0_body.fh59, PRE_first_tail_x15_r0_body.fo59, PRE_first_tail_x15_r0_body.fok59, PRE_first_tail_x15_r0_body.fnd59, PRE_first_tail_x15_r0_body.fp59, PRE_first_tail_x15_r0_body.fnord59, PRE_first_tail_x15_r0_body.fi59, PRE_first_tail_x15_r0_body.fii59⟩
theorem PRE_first_tail_x15_r0_body.cnshift59 (clean : Conv.NClean (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P59.NL) (cl : SSt (· < 2575) PRE_first_tail_x15_r0_body.cx0_59.mlx) : NShift PRE_first_tail_x15_r0_body.P59 2575 PRE_first_tail_x15_r0_body.kappa59 PRE_first_tail_x15_r0_body.cx0_59 PRE_first_tail_x15_r0_body.cx1_59 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot59 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost59 (compact_a_eq PRE_first_tail_x15_r0_body.ckn059 PRE_first_tail_x15_r0_body.ckn159 PRE_first_tail_x15_r0_body.ckheap59 PRE_first_tail_x15_r0_body.ckpl59)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_59 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s574.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_59 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s574.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_59 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s574.ffi) = some PRE_first_tail_x15_r0_body.fxC_59
kernel_rfl PRE_first_tail_x15_r0_body.okrC_59 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s574.ffi) = some PRE_first_tail_x15_r0_body.krC_59
noncomputable def PRE_first_tail_x15_r0_body.fx0_59 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s576.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_59 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s576.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_59 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s576.ffi) = some PRE_first_tail_x15_r0_body.fx0_59
kernel_rfl PRE_first_tail_x15_r0_body.okr0_59 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s576.ffi) = some PRE_first_tail_x15_r0_body.kr0_59
noncomputable def PRE_first_tail_x15_r0_body.fx1_59 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s575.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_59 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s575.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_59 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s575.ffi) = some PRE_first_tail_x15_r0_body.fx1_59
kernel_rfl PRE_first_tail_x15_r0_body.okr1_59 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s575.ffi) = some PRE_first_tail_x15_r0_body.kr1_59
kernel_rfl PRE_first_tail_x15_r0_body.ff059 : PRE_first_tail_x15_r0_body.fx0_59 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_59 (PRE_first_tail_x15_r0_body.clo59.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_59.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff159 : PRE_first_tail_x15_r0_body.fx1_59 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_59 (PRE_first_tail_x15_r0_body.cwS59.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_59.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck59 : freedLB PRE_first_tail_x15_r0_body.kappa59 PRE_first_tail_x15_r0_body.cx0_59.mlx PRE_first_tail_x15_r0_body.fx0_59 PRE_first_tail_x15_r0_body.fx1_59 PRE_first_tail_x15_r0_body.clo59 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf059 : PRE_first_tail_x15_r0_body.kr0_59.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_59.flags (PRE_first_tail_x15_r0_body.clo59.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_59.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt059 : PRE_first_tail_x15_r0_body.kr0_59.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_59.targs (PRE_first_tail_x15_r0_body.clo59.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_59.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf159 : PRE_first_tail_x15_r0_body.kr1_59.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_59.flags (PRE_first_tail_x15_r0_body.cwS59.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_59.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt159 : PRE_first_tail_x15_r0_body.kr1_59.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_59.targs (PRE_first_tail_x15_r0_body.cwS59.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_59.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck59 : krecLB PRE_first_tail_x15_r0_body.kappa59 2575 PRE_first_tail_x15_r0_body.cx0_59.mlx PRE_first_tail_x15_r0_body.kr0_59 PRE_first_tail_x15_r0_body.kr1_59 PRE_first_tail_x15_r0_body.clo59 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn59 : Nat.ble 2575 2575 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge59 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s575.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s576.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR59 : pendRegB PRE_first_tail_x15_r0_body.kappa59 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe59 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s575.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift59 (clean : Conv.NClean (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P59.NL) (cl : SSt (· < 2575) PRE_first_tail_x15_r0_body.cx0_59.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_59.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_59.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_59.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_59.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P59 2575 PRE_first_tail_x15_r0_body.kappa59 PRE_first_tail_x15_r0_body.s576.ffi PRE_first_tail_x15_r0_body.s575.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift59 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue59, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp59 t ht),
    PRE_first_tail_x15_r0_body.cbridge59,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s576.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s575.ffi) (PRE_first_tail_x15_r0_body.cfoot59 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_59 PRE_first_tail_x15_r0_body.ofx1_59 hobjC PRE_first_tail_x15_r0_body.ff059 PRE_first_tail_x15_r0_body.ff159 PRE_first_tail_x15_r0_body.ffck59,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s576.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s575.ffi) (PRE_first_tail_x15_r0_body.cfoot59 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_59 PRE_first_tail_x15_r0_body.okr1_59 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn59) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf059 PRE_first_tail_x15_r0_body.fkt059 PRE_first_tail_x15_r0_body.fkf159 PRE_first_tail_x15_r0_body.fkt159 PRE_first_tail_x15_r0_body.fkck59,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh059 PRE_first_tail_x15_r0_body.cnh159 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe59) PRE_first_tail_x15_r0_body.cpendR59⟩

end Host.Load.Run.Tpl
end

section -- st59/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st59 0
host_stream_state PRE_first_tail_x15_r0_body.st59 1
host_stream_state PRE_first_tail_x15_r0_body.st59 2
end Host.Load.Run.Tpl
end

section -- Site59
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 59 of chain `PRE_first_tail_x15_r0_body`: `plan__g59__g60` (`plan`), the call state `PRE_first_tail_x15_r0_body.s574`, the merged state `PRE_first_tail_x15_r0_body.s575`,
the site template `PRE_first_tail_x15_r0_body.st59` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s576`: the merge.
The footprint's facts are in `SiteF59`, the compaction's in `SiteC59`, `SiteK59`, `SiteNa59`, `SiteNb59`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso59 : PRE_first_tail_x15_r0_body.st59.s0 = { PRE_first_tail_x15_r0_body.s574 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs59 : List Frame := PRE_first_tail_x15_r0_body.s574.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_59 : PRE_first_tail_x15_r0_body.S574.tab.length = 2575
kernel_rfl PRE_first_tail_x15_r0_body.tab0_59 : PRE_first_tail_x15_r0_body.st59.S0.tab = PRE_first_tail_x15_r0_body.S574.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws59 : List Nat := [2004, 2005, 2006]
kernel_rfl PRE_first_tail_x15_r0_body.fresh59 : (PRE_first_tail_x15_r0_body.S574.tab.all fun e => PRE_first_tail_x15_r0_body.ws59.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S574.oracle.all fun q => PRE_first_tail_x15_r0_body.ws59.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab59 : PRE_first_tail_x15_r0_body.S575.tab = PRE_first_tail_x15_r0_body.S574.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws59
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen59 : PRE_first_tail_x15_r0_body.st59.S2.tab.length - PRE_first_tail_x15_r0_body.st59.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged59`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap59 : PRE_first_tail_x15_r0_body.s575.heap = PRE_first_tail_x15_r0_body.st59.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext59 : PRE_first_tail_x15_r0_body.s575.next = PRE_first_tail_x15_r0_body.st59.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl59 : PRE_first_tail_x15_r0_body.s575.ctl = PRE_first_tail_x15_r0_body.st59.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack59 : PRE_first_tail_x15_r0_body.s575.stack = PRE_first_tail_x15_r0_body.st59.s2.stack ++ PRE_first_tail_x15_r0_body.s574.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs59 : PRE_first_tail_x15_r0_body.s575.jobs = PRE_first_tail_x15_r0_body.st59.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi59 : PRE_first_tail_x15_r0_body.s575.ffi = PRE_first_tail_x15_r0_body.st59.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace59 : PRE_first_tail_x15_r0_body.s575.trace = PRE_first_tail_x15_r0_body.st59.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores59 : PRE_first_tail_x15_r0_body.s575.stores = PRE_first_tail_x15_r0_body.st59.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD59
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 59 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived59 : PRE_first_tail_x15_r0_body.nr59.map (fun r => nth? PRE_first_tail_x15_r0_body.st59.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo59 : PRE_first_tail_x15_r0_body.nr59.all (Nat.ble 2575) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj59 : PRE_first_tail_x15_r0_body.cws59.all (fun c => !PRE_first_tail_x15_r0_body.ws59.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ59 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws59 PRE_first_tail_x15_r0_body.crs59 PRE_first_tail_x15_r0_body.ws59

end Host.Load.Run.Tpl
end

section -- st59/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st59`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st59.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st59.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st59.s2.heap PRE_first_tail_x15_r0_body.st59.wrR ++ freshOf PRE_first_tail_x15_r0_body.st59.s2.heap PRE_first_tail_x15_r0_body.st59.s0.next PRE_first_tail_x15_r0_body.st59.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st59.wr : List Nat := PRE_first_tail_x15_r0_body.st59.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st59.heapFoot : PRE_first_tail_x15_r0_body.st59.s2.heap = setAll PRE_first_tail_x15_r0_body.st59.s0.heap PRE_first_tail_x15_r0_body.st59.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st59.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st59.s0.next PRE_first_tail_x15_r0_body.st59.s2.next = true
theorem PRE_first_tail_x15_r0_body.st59.grows : PRE_first_tail_x15_r0_body.st59.s0.next ≤ PRE_first_tail_x15_r0_body.st59.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st59.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st59.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st59.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st59.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st59.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st59.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st59.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st59.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st59.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st59.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st59.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st59.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st59.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st59.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st59.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st59.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st59.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st59.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st59.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st59.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st59.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st59.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st59.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st59.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st59.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st59.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st59.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st59.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st59.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st59.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st59.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st59.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF59
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 59 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB59 : nodupT PRE_first_tail_x15_r0_body.st59.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup59 : PRE_first_tail_x15_r0_body.st59.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB59).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB59 : PRE_first_tail_x15_r0_body.st59.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound59 : ∀ b ∈ PRE_first_tail_x15_r0_body.st59.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB59 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr59 := PRE_first_tail_x15_r0_body.st59.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq59 : PRE_first_tail_x15_r0_body.st59.s2.trace = PRE_first_tail_x15_r0_body.trFr59 ++ PRE_first_tail_x15_r0_body.st59.s0.trace
theorem PRE_first_tail_x15_r0_body.trace59 : ∃ fr, PRE_first_tail_x15_r0_body.st59.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st59.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq59⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide59 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB59 : (PRE_first_tail_x15_r0_body.wide59.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st59.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix59 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide59, WFix Map.id (Present PRE_first_tail_x15_r0_body.st59.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB59 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL59
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 59 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s575`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO59 : PRE_first_tail_x15_r0_body.st59.S0.oracle = PRE_first_tail_x15_r0_body.st59.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B59 : PRE_first_tail_x15_r0_body.st59.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st59.s0.next || (PRE_first_tail_x15_r0_body.st59.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot59 : Conv.StageFoot PRE_first_tail_x15_r0_body.st59.wr PRE_first_tail_x15_r0_body.st59.s0 PRE_first_tail_x15_r0_body.st59.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st59.heapFoot PRE_first_tail_x15_r0_body.wrNodup59 PRE_first_tail_x15_r0_body.wrBound59 PRE_first_tail_x15_r0_body.wr0B59 PRE_first_tail_x15_r0_body.st59.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged59 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st59.F.S → PRE_first_tail_x15_r0_body.st59.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st59.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st59.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs59 PRE_first_tail_x15_r0_body.st59.wr PRE_first_tail_x15_r0_body.s574 PRE_first_tail_x15_r0_body.st59.s2 PRE_first_tail_x15_r0_body.st59.s0
      PRE_first_tail_x15_r0_body.st59.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st59.F FR W stk M ν K PRE_first_tail_x15_r0_body.s575 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso59 PRE_first_tail_x15_r0_body.stFoot59 PRE_first_tail_x15_r0_body.wrNodup59 PRE_first_tail_x15_r0_body.wrBound59 PRE_first_tail_x15_r0_body.trace59 PRE_first_tail_x15_r0_body.mheap59
    PRE_first_tail_x15_r0_body.mnext59 PRE_first_tail_x15_r0_body.mctl59 PRE_first_tail_x15_r0_body.mstack59 PRE_first_tail_x15_r0_body.mjobs59 PRE_first_tail_x15_r0_body.mffi59 PRE_first_tail_x15_r0_body.mtrace59 PRE_first_tail_x15_r0_body.mstores59 h

def PRE_first_tail_x15_r0_body.arrEl59_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE59_2665 : arrOf PRE_first_tail_x15_r0_body.s575 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl59_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA59_2665 : isArrB PRE_first_tail_x15_r0_body.s575 2665 = true
theorem PRE_first_tail_x15_r0_body.arr59_2665 : ∃ o, PRE_first_tail_x15_r0_body.s575.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl59_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE59_2665 PRE_first_tail_x15_r0_body.arrA59_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN59_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl59_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR59_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl59_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN59_2665

def PRE_first_tail_x15_r0_body.arrEl59_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE59_2673467 : arrOf PRE_first_tail_x15_r0_body.s575 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl59_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA59_2673467 : isArrB PRE_first_tail_x15_r0_body.s575 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr59_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s575.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl59_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE59_2673467 PRE_first_tail_x15_r0_body.arrA59_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN59_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl59_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR59_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl59_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN59_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k59 : isArrB PRE_first_tail_x15_r0_body.s575 4910 = false
theorem PRE_first_tail_x15_r0_body.keep59 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s575 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k59 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr59_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl59_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ59
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 59 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s574`, the merged
state `PRE_first_tail_x15_r0_body.s575`, the canonical state `PRE_first_tail_x15_r0_body.s576`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl59 : PRE_first_tail_x15_r0_body.pl59.all (Nat.ble PRE_first_tail_x15_r0_body.s574.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd59 : nodupT PRE_first_tail_x15_r0_body.pl59 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn159 : Nat.ble PRE_first_tail_x15_r0_body.s574.next 2721064 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst59 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s574.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn59 : PRE_first_tail_x15_r0_body.s576.next = PRE_first_tail_x15_r0_body.s574.next + PRE_first_tail_x15_r0_body.pl59.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn59 : PRE_first_tail_x15_r0_body.s575.next = 2721064
kernel_rfl PRE_first_tail_x15_r0_body.zgrow59 : Nat.ble PRE_first_tail_x15_r0_body.s576.next PRE_first_tail_x15_r0_body.s575.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh59 : PRE_first_tail_x15_r0_body.S574.tab.all (fun e => PRE_first_tail_x15_r0_body.cws59.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd59 : nodupT PRE_first_tail_x15_r0_body.cws59 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi59 : PRE_first_tail_x15_r0_body.nr59.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S575.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt59 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s574.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg59_2665 : PRE_first_tail_x15_r0_body.s576.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s576 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk59_2665 : (objOf PRE_first_tail_x15_r0_body.s576 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm59_2665 : PRE_first_tail_x15_r0_body.s575.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa59.obj (objOf PRE_first_tail_x15_r0_body.s576 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s575 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg59_2673467 : PRE_first_tail_x15_r0_body.s576.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s576 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk59_2673467 : (objOf PRE_first_tail_x15_r0_body.s576 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm59_2673467 : PRE_first_tail_x15_r0_body.s575.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa59.obj (objOf PRE_first_tail_x15_r0_body.s576 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s575 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw59_4910 : (PRE_first_tail_x15_r0_body.s576.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw59_2673472 : (PRE_first_tail_x15_r0_body.s576.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw59_2673473 : (PRE_first_tail_x15_r0_body.s576.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd59 : PRE_first_tail_x15_r0_body.cl59.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr59 : PRE_first_tail_x15_r0_body.st59.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s574.next || PRE_first_tail_x15_r0_body.cl59.contains b) = true
def PRE_first_tail_x15_r0_body.zl59 : List Nat := PRE_first_tail_x15_r0_body.cl59.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE59 : PRE_first_tail_x15_r0_body.zl59.map (fun a => PRE_first_tail_x15_r0_body.s575.heap.get (PRE_first_tail_x15_r0_body.kappa59.a a)) = PRE_first_tail_x15_r0_body.zl59.map (fun a => (PRE_first_tail_x15_r0_body.s576.heap.get a).map PRE_first_tail_x15_r0_body.kappa59.hobj)
theorem PRE_first_tail_x15_r0_body.zimg59 : HeapImg PRE_first_tail_x15_r0_body.kappa59 PRE_first_tail_x15_r0_body.s576 PRE_first_tail_x15_r0_body.s575 PRE_first_tail_x15_r0_body.zl59 := PRE_first_tail_x15_r0_body.zimgE59
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl59 : PRE_first_tail_x15_r0_body.s575.ctl = PRE_first_tail_x15_r0_body.kappa59.ctl PRE_first_tail_x15_r0_body.s576.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack59 : PRE_first_tail_x15_r0_body.s575.stack = PRE_first_tail_x15_r0_body.s576.stack.map PRE_first_tail_x15_r0_body.kappa59.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs59 : PRE_first_tail_x15_r0_body.s575.jobs = PRE_first_tail_x15_r0_body.s576.jobs.map PRE_first_tail_x15_r0_body.kappa59.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores59 : PRE_first_tail_x15_r0_body.s575.stores = PRE_first_tail_x15_r0_body.kappa59.stores PRE_first_tail_x15_r0_body.s576.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots59 : checkRootsSupp PRE_first_tail_x15_r0_body.s576 2575 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC59 : PRE_first_tail_x15_r0_body.S574.tab.length + PRE_first_tail_x15_r0_body.cws59.length = 2575
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap59 : PRE_first_tail_x15_r0_body.kappa59 = Conv.Map.compact PRE_first_tail_x15_r0_body.s574.next 2721064 PRE_first_tail_x15_r0_body.S574.tab.length PRE_first_tail_x15_r0_body.pl59 (PRE_first_tail_x15_r0_body.nr59.map NumV.ref) PRE_first_tail_x15_r0_body.kd59.big
  PRE_first_tail_x15_r0_body.kd59.region PRE_first_tail_x15_r0_body.kd59.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin59 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s576.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc59 : Conv.jcleanListB (⟨19361, 16444, 2721054, 2575⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s576 PRE_first_tail_x15_r0_body.cl59 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB59 : noBigRootsP (fun i => !Conv.oldBigB (⟨19361, 16444, 2721054, 2575⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s576.trace PRE_first_tail_x15_r0_body.s576 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm59 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16444 = true
theorem PRE_first_tail_x15_r0_body.cjcl59 (h : Conv.JClean (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s574) : Conv.JClean (⟨19361, 16444, 2721054, 2575⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s576 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle59)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap59 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd59 a ha)) PRE_first_tail_x15_r0_body.zjc59

end Host.Load.Run.Tpl
end

section -- st59/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st59.bodyLast from PRE_first_tail_x15_r0_body.st59.s1 to PRE_first_tail_x15_r0_body.st59.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st59.F PRE_first_tail_x15_r0_body.st59.s1).run PRE_first_tail_x15_r0_body.st59.S1 = some (PRE_first_tail_x15_r0_body.st59.s2, PRE_first_tail_x15_r0_body.st59.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st59.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st59.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st59.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st59.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st59/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st59.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st59.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st59.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st59.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st59.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st59.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st59.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st59.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st59.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st59.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st59.s0 PRE_first_tail_x15_r0_body.st59.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st59.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st59.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st59.s1 PRE_first_tail_x15_r0_body.st59.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st59/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st59.bodyK0F from PRE_first_tail_x15_r0_body.st59.s0 to PRE_first_tail_x15_r0_body.st59.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st59.F (PRE_first_tail_x15_r0_body.st59.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st59.ks 0).getD 0) PRE_first_tail_x15_r0_body.st59.s0 PRE_first_tail_x15_r0_body.st59.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st59.s1, PRE_first_tail_x15_r0_body.st59.S1)
theorem PRE_first_tail_x15_r0_body.st59.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st59.F (PRE_first_tail_x15_r0_body.st59.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st59.ks 0).getD 0) PRE_first_tail_x15_r0_body.st59.s0 PRE_first_tail_x15_r0_body.st59.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st59.s1, PRE_first_tail_x15_r0_body.st59.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st59.bodyOkLN_ok PRE_first_tail_x15_r0_body.st59.bodyK0F
end Host.Load.Run.Tpl
end

section -- st59/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st59.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st59.F (PRE_first_tail_x15_r0_body.st59.bodyOkL bytes rows) 98 PRE_first_tail_x15_r0_body.st59.s0 PRE_first_tail_x15_r0_body.st59.S0 = some (PRE_first_tail_x15_r0_body.st59.s1, PRE_first_tail_x15_r0_body.st59.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st59.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st59.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st59.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st59.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st59.F (PRE_first_tail_x15_r0_body.st59.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st59.s0
  S0 := PRE_first_tail_x15_r0_body.st59.S0
  s1 := PRE_first_tail_x15_r0_body.st59.s1
  S1 := PRE_first_tail_x15_r0_body.st59.S1
  s2 := PRE_first_tail_x15_r0_body.st59.s2
  S2 := PRE_first_tail_x15_r0_body.st59.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st59.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st59.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st59.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st59.bodyHalt
  last := PRE_first_tail_x15_r0_body.st59.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st59.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC60
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 60 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s593` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa60` into the merged state
`PRE_first_tail_x15_r0_body.s592`. -/

def PRE_first_tail_x15_r0_body.pl60 : List Nat := [2723659, 2722834, 2723665, 2723661, 2722836, 2723667]
def PRE_first_tail_x15_r0_body.nr60 : List Nat := [2678, 2677, 2653, 2661, 2666, 2671, 2676, 2650, 2651, 2652, 2659, 2660, 2648, 2655, 2656, 2657, 2658, 2654]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd60 : RData :=
  ⟨2722553, 2723702, Stage.setAll PTrie.nil [(2722547, 2723659), (2722548, 2722834), (2722549, 2723665), (2722550, 2723661), (2722551, 2722836), (2722552, 2723667)], Stage.setAll PTrie.nil [(19396, 19422), (19397, 19400), (19398, 19423)],
   19399, 19424, 16490, 16490, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(2648, .ref 2678), (2649, .ref 2677), (2650, .ref 2653), (2651, .ref 2661), (2652, .ref 2666), (2653, .ref 2671), (2654, .ref 2676), (2655, .ref 2650), (2656, .ref 2651), (2657, .ref 2652), (2658, .ref 2659), (2659, .ref 2660), (2660, .ref 2648), (2661, .ref 2655), (2662, .ref 2656), (2663, .ref 2657), (2664, .ref 2658), (2665, .ref 2654)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa60 : Map :=
  Conv.Map.compact 2722547 2723702 2648 PRE_first_tail_x15_r0_body.pl60 (PRE_first_tail_x15_r0_body.nr60.map NumV.ref) PRE_first_tail_x15_r0_body.kd60.big
    PRE_first_tail_x15_r0_body.kd60.region PRE_first_tail_x15_r0_body.kd60.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws60 : List Nat := [2038, 2039, 2040, 2041, 2042, 2043, 2044, 2045, 2046, 2047, 2048, 2049, 2050, 2051, 2052, 2053, 2054, 2055]
noncomputable def PRE_first_tail_x15_r0_body.crs60 : List SymE := PRE_first_tail_x15_r0_body.nr60.map fun r => (nth? PRE_first_tail_x15_r0_body.S592.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta60 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws60 PRE_first_tail_x15_r0_body.crs60
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB60 : List Nat := [2665, 2672455, 2673467, 2721721, 2722266, 2722522]

kernel_rfl PRE_first_tail_x15_r0_body.ctab60 : PRE_first_tail_x15_r0_body.S593.tab = PRE_first_tail_x15_r0_body.S591.tab ++ PRE_first_tail_x15_r0_body.cws60.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace60 : PRE_first_tail_x15_r0_body.s593.trace = PRE_first_tail_x15_r0_body.s591.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext60 : PRE_first_tail_x15_r0_body.s593.next = 2722553
kernel_rfl PRE_first_tail_x15_r0_body.ccounters60 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx.nnext) = (19399, 16490)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue60 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s592.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa60.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp60 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx.tokens.all (bSN 2666) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean60 : Conv.cleanListB 19399 131072 (fun r => Nat.ble 77596 r) PRE_first_tail_x15_r0_body.s593
    (PRE_first_tail_x15_r0_body.wrB60 ++ (List.range 6).map (2722547 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs60 : bigsOutB 19399 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK60
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl60`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl60 : List Nat := [2665, 2672455, 2673467, 2721721, 2722266, 2722522, 2722547, 2722548, 2722549, 2722550, 2722551, 2722552]
def PRE_first_tail_x15_r0_body.clo60 : List Nat := [19376, 19389, 19395, 19396, 19397, 19398]
def PRE_first_tail_x15_r0_body.cln60 : List Nat := [16463, 16464, 16465, 16466, 16467, 16468, 16469, 16470, 16471, 16472, 16473, 16474, 16475, 16476, 16477, 16478, 16479, 16480, 16481, 16482, 16483, 16484, 16485, 16486, 16487, 16488, 16489]
def PRE_first_tail_x15_r0_body.cli60 : List Nat := [16463, 16464, 16465, 16466, 16467, 16468, 16469, 16470, 16471, 16472, 16473, 16474, 16475, 16476, 16477, 16478, 16479, 16480, 16481, 16482, 16483, 16484, 16485, 16486, 16487, 16488, 16489]
kernel_rfl PRE_first_tail_x15_r0_body.cheap60 : PRE_first_tail_x15_r0_body.s593.heap = Stage.setAll PRE_first_tail_x15_r0_body.s591.heap (PRE_first_tail_x15_r0_body.cl60.filterMap fun a => (PRE_first_tail_x15_r0_body.s593.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe60 : Nat.ble PRE_first_tail_x15_r0_body.s591.next PRE_first_tail_x15_r0_body.s593.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP60 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s591 PRE_first_tail_x15_r0_body.s593 PRE_first_tail_x15_r0_body.cl60 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp60 : Conv.suppListB PRE_first_tail_x15_r0_body.s593 2666 PRE_first_tail_x15_r0_body.cl60 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound60 : Conv.boundListB PRE_first_tail_x15_r0_body.s593 PRE_first_tail_x15_r0_body.cl60 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK60 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln60.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK60 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo60.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK60 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli60.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst60 : Conv.sstListB 2666 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx PRE_first_tail_x15_r0_body.cln60 PRE_first_tail_x15_r0_body.clo60 PRE_first_tail_x15_r0_body.cli60 = true

end Host.Load.Run.Tpl
end

section -- SiteCl60
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA60 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo60.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd60 : (PRE_first_tail_x15_r0_body.clo60 ++ PRE_first_tail_x15_r0_body.cln60 ++ PRE_first_tail_x15_r0_body.cli60).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle60 : Conv.Cnt.leB (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt) (⟨19399, 16490, 2722553, 2666⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck60 : Conv.ncleanListB (⟨19399, 16490, 2722553, 2666⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx PRE_first_tail_x15_r0_body.clo60 PRE_first_tail_x15_r0_body.cln60 PRE_first_tail_x15_r0_body.cli60 = true
theorem PRE_first_tail_x15_r0_body.cncl60 (h : Conv.NClean (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx) : Conv.NClean (⟨19399, 16490, 2722553, 2666⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle60 PRE_first_tail_x15_r0_body.ckA60 PRE_first_tail_x15_r0_body.cobjsK60 PRE_first_tail_x15_r0_body.cnodesK60 PRE_first_tail_x15_r0_body.citemsK60 PRE_first_tail_x15_r0_body.cbd60 PRE_first_tail_x15_r0_body.cck60

end Host.Load.Run.Tpl
end

section -- SiteS60
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 60 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc60 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P60 : LoadP := PRE_first_tail_x15_r0_body.Pc60.raise 16490
kernel_rfl PRE_first_tail_x15_r0_body.craise60 : Nat.ble PRE_first_tail_x15_r0_body.Pc60.N0 16490 = true
theorem PRE_first_tail_x15_r0_body.raised60 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc60 PRE_first_tail_x15_r0_body.P60 :=
  .inr ⟨16490, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise60, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_60 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_60 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s592.ffi)
def PRE_first_tail_x15_r0_body.khinv60 : PTrie Nat := Stage.setAll PTrie.nil [(19422, 19396), (19400, 19397), (19423, 19398)]
def PRE_first_tail_x15_r0_body.kninv60 : PTrie Nat := Stage.setAll PTrie.nil [(16463, 16463), (16464, 16464), (16465, 16465), (16466, 16466), (16467, 16467), (16468, 16468), (16469, 16469), (16470, 16470), (16471, 16471), (16472, 16472), (16473, 16473), (16474, 16474), (16475, 16475), (16476, 16476), (16477, 16477), (16478, 16478), (16479, 16479), (16480, 16480), (16481, 16481), (16482, 16482), (16483, 16483), (16484, 16484), (16485, 16485), (16486, 16486), (16487, 16487), (16488, 16488), (16489, 16489)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS60 : List Nat := [19376, 19389, 19395, 19396, 19397, 19398, 19399, 19400, 19401, 19402, 19403, 19404, 19405, 19406, 19407, 19408, 19409, 19410, 19411, 19412, 19413, 19414, 19415, 19416, 19417, 19418, 19419, 19420, 19421, 19422, 19423]
def PRE_first_tail_x15_r0_body.cnS60 : List Nat := List.range' 16463 27
def PRE_first_tail_x15_r0_body.ciS60 : List Nat := [] ++ List.range' 16463 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh060 : PRE_first_tail_x15_r0_body.kd60.nh0 = PRE_first_tail_x15_r0_body.cx0_60.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh160 : PRE_first_tail_x15_r0_body.kd60.nh1 = PRE_first_tail_x15_r0_body.cx1_60.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn060 : PRE_first_tail_x15_r0_body.kd60.nn0 = PRE_first_tail_x15_r0_body.cx0_60.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn160 : PRE_first_tail_x15_r0_body.kd60.nn1 = PRE_first_tail_x15_r0_body.cx1_60.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo60 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P60.lo && Nat.ble PRE_first_tail_x15_r0_body.P60.lo PRE_first_tail_x15_r0_body.cx0_60.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P60.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P60.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt60 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_60.mlx.next PRE_first_tail_x15_r0_body.cx1_60.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_60.mlx.nnext PRE_first_tail_x15_r0_body.cx1_60.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband60 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P60.NL && Nat.ble PRE_first_tail_x15_r0_body.P60.NL PRE_first_tail_x15_r0_body.P60.N0 && Nat.ble PRE_first_tail_x15_r0_body.P60.N0 PRE_first_tail_x15_r0_body.cx0_60.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow60 : PRE_first_tail_x15_r0_body.kd60.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren60 : checkRenG PRE_first_tail_x15_r0_body.kd60.hnd PRE_first_tail_x15_r0_body.khinv60 (phB PRE_first_tail_x15_r0_body.cx0_60.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband60 : PRE_first_tail_x15_r0_body.kd60.checkBand PRE_first_tail_x15_r0_body.P60.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos60 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd60.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren60 : checkRenG PRE_first_tail_x15_r0_body.kd60.node PRE_first_tail_x15_r0_body.kninv60 (pnB PRE_first_tail_x15_r0_body.cx0_60.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow60 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd60.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P60.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd60.nodeF j) PRE_first_tail_x15_r0_body.cx1_60.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a60 : PRE_first_tail_x15_r0_body.cx0_60.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b60 : PRE_first_tail_x15_r0_body.cx0_60.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok160 : PRE_first_tail_x15_r0_body.cx1_60.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend60 : PRE_first_tail_x15_r0_body.cx1_60.mlx.pending = PRE_first_tail_x15_r0_body.cx0_60.mlx.pending.map PRE_first_tail_x15_r0_body.kappa60.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh60 : PRE_first_tail_x15_r0_body.cx1_60.mlx.errh = PRE_first_tail_x15_r0_body.cx0_60.mlx.errh.map PRE_first_tail_x15_r0_body.kappa60.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles60 : PRE_first_tail_x15_r0_body.cx1_60.mlx.files = PRE_first_tail_x15_r0_body.cx0_60.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch60 : PRE_first_tail_x15_r0_body.cx1_60.mlx.arch = PRE_first_tail_x15_r0_body.cx0_60.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes60 : PRE_first_tail_x15_r0_body.cx1_60.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_60.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired60 : PRE_first_tail_x15_r0_body.cx1_60.mlx.wired = PRE_first_tail_x15_r0_body.cx0_60.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost60 : PRE_first_tail_x15_r0_body.cx1_60.host = PRE_first_tail_x15_r0_body.cx0_60.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd60`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn060 : PRE_first_tail_x15_r0_body.kd60.n0 = 2722553
kernel_rfl PRE_first_tail_x15_r0_body.ckn160 : PRE_first_tail_x15_r0_body.kd60.n1 = 2723702
kernel_rfl PRE_first_tail_x15_r0_body.ckheap60 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd60.heap).all (fun x => Nat.ble 2722547 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl60 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd60.heap.get (2722547 + j) = nth? PRE_first_tail_x15_r0_body.pl60 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja60 : Nat.ble 2722547 2722547 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn60 : Nat.ble 2648 2648 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD60 : Nat.ble 2722547 PRE_first_tail_x15_r0_body.kd60.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn60 : Nat.ble 19396 PRE_first_tail_x15_r0_body.kd60.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn60 : Nat.ble 16463 PRE_first_tail_x15_r0_body.kd60.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb60 : Nat.ble 19396 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap60 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd60.heap).all (Nat.ble (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd60 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd60.hnd).all (Nat.ble (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode60 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd60.node).all (Nat.ble (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix60 : Conv.FixOld (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa60 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja60) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn60) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD60) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn60) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn60) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb60) PRE_first_tail_x15_r0_body.fheap60 PRE_first_tail_x15_r0_body.fhnd60 PRE_first_tail_x15_r0_body.fnode60
kernel_rfl PRE_first_tail_x15_r0_body.fcxn60 : (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn60 : (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle060 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_60.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_60.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk60 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd60.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A60 : PRE_first_tail_x15_r0_body.cx1_60.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS60.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_60.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O60 : PRE_first_tail_x15_r0_body.cx1_60.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS60.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_60.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N60 : PRE_first_tail_x15_r0_body.cx1_60.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS60.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_60.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I60 : PRE_first_tail_x15_r0_body.cx1_60.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS60.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_60.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd60 : (PRE_first_tail_x15_r0_body.clo60 ++ PRE_first_tail_x15_r0_body.cln60 ++ PRE_first_tail_x15_r0_body.cli60 ++ PRE_first_tail_x15_r0_body.cwS60 ++ PRE_first_tail_x15_r0_body.cnS60 ++ PRE_first_tail_x15_r0_body.ciS60).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW60 : PRE_first_tail_x15_r0_body.cwS60.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo60.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI60 : PRE_first_tail_x15_r0_body.ciS60.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli60.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN60 : PRE_first_tail_x15_r0_body.cnS60.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF60 : PRE_first_tail_x15_r0_body.cln60.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh60 : PRE_first_tail_x15_r0_body.clo60.all (handleOK PRE_first_tail_x15_r0_body.kappa60 PRE_first_tail_x15_r0_body.P60.lo PRE_first_tail_x15_r0_body.cx0_60.mlx PRE_first_tail_x15_r0_body.cx1_60.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo60 : PRE_first_tail_x15_r0_body.clo60.map (fun h => PRE_first_tail_x15_r0_body.cx1_60.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa60.handle h)) = PRE_first_tail_x15_r0_body.clo60.map (fun h => (PRE_first_tail_x15_r0_body.cx0_60.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa60.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok60 : PRE_first_tail_x15_r0_body.clo60.all (objOK PRE_first_tail_x15_r0_body.kappa60 PRE_first_tail_x15_r0_body.P60.NL PRE_first_tail_x15_r0_body.cx0_60.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd60 : PRE_first_tail_x15_r0_body.cln60.all (nodeOKF PRE_first_tail_x15_r0_body.kappa60 PRE_first_tail_x15_r0_body.P60 PRE_first_tail_x15_r0_body.cx0_60.mlx PRE_first_tail_x15_r0_body.cx1_60.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp60 : ((PRE_first_tail_x15_r0_body.cln60.filter (fullB PRE_first_tail_x15_r0_body.P60))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_60.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa60.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln60.filter (fullB PRE_first_tail_x15_r0_body.P60))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_60.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa60.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI60 : incrB PRE_first_tail_x15_r0_body.kd60.nodeF (List.range' 16463 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK60 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd60.node).all (fun k => Nat.ble 16463 k && Nat.blt k 16490) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL60 : (PRE_first_tail_x15_r0_body.cln60.filter (Nat.ble PRE_first_tail_x15_r0_body.P60.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd60.nodeF i) && (Nat.blt i 16490 || Nat.ble PRE_first_tail_x15_r0_body.kd60.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord60 : (PRE_first_tail_x15_r0_body.cln60.filter (Nat.ble PRE_first_tail_x15_r0_body.P60.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd60.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd60.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd60.nodeF j) (PRE_first_tail_x15_r0_body.kd60.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow60 PRE_first_tail_x15_r0_body.cnn160 PRE_first_tail_x15_r0_body.fnordI60 PRE_first_tail_x15_r0_body.fnordK60 PRE_first_tail_x15_r0_body.fnordL60
kernel_rfl PRE_first_tail_x15_r0_body.fi60 : PRE_first_tail_x15_r0_body.cli60.all (pnB PRE_first_tail_x15_r0_body.cx0_60.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii60 : PRE_first_tail_x15_r0_body.cli60.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_60.mlx.items.get (PRE_first_tail_x15_r0_body.kappa60.node k) = (PRE_first_tail_x15_r0_body.cx0_60.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa60.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot60 (clean : Conv.NClean (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P60.NL) (cl : SSt (· < 2666) PRE_first_tail_x15_r0_body.cx0_60.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P60 2666 PRE_first_tail_x15_r0_body.kappa60 PRE_first_tail_x15_r0_body.kd60 PRE_first_tail_x15_r0_body.khinv60 PRE_first_tail_x15_r0_body.kninv60 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx PRE_first_tail_x15_r0_body.cx0_60.mlx PRE_first_tail_x15_r0_body.cx1_60.mlx (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo60 PRE_first_tail_x15_r0_body.cln60 PRE_first_tail_x15_r0_body.cli60 PRE_first_tail_x15_r0_body.cwS60 PRE_first_tail_x15_r0_body.cnS60 PRE_first_tail_x15_r0_body.ciS60 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh060, PRE_first_tail_x15_r0_body.cnh160, PRE_first_tail_x15_r0_body.cnn060, PRE_first_tail_x15_r0_body.cnn160, PRE_first_tail_x15_r0_body.cplo60, PRE_first_tail_x15_r0_body.ccnt60, PRE_first_tail_x15_r0_body.cnband60, PRE_first_tail_x15_r0_body.chbelow60, PRE_first_tail_x15_r0_body.chren60, PRE_first_tail_x15_r0_body.cband60, PRE_first_tail_x15_r0_body.cnh1pos60, PRE_first_tail_x15_r0_body.cnren60, PRE_first_tail_x15_r0_body.cnlow60, PRE_first_tail_x15_r0_body.cabs0a60, PRE_first_tail_x15_r0_body.cabs0b60, PRE_first_tail_x15_r0_body.ctok160, PRE_first_tail_x15_r0_body.cpend60, PRE_first_tail_x15_r0_body.cerrh60, PRE_first_tail_x15_r0_body.cfiles60, PRE_first_tail_x15_r0_body.carch60, PRE_first_tail_x15_r0_body.csizes60, PRE_first_tail_x15_r0_body.cwired60, PRE_first_tail_x15_r0_body.cfix60, clean, PRE_first_tail_x15_r0_body.fcxn60, PRE_first_tail_x15_r0_body.fcnn60, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle060, PRE_first_tail_x15_r0_body.fnk60, PRE_first_tail_x15_r0_body.ckA60, PRE_first_tail_x15_r0_body.cobjsK60, PRE_first_tail_x15_r0_body.cnodesK60, PRE_first_tail_x15_r0_body.citemsK60, PRE_first_tail_x15_r0_body.f1A60, PRE_first_tail_x15_r0_body.f1O60, PRE_first_tail_x15_r0_body.f1N60, PRE_first_tail_x15_r0_body.f1I60, PRE_first_tail_x15_r0_body.fbd60, PRE_first_tail_x15_r0_body.fincW60, PRE_first_tail_x15_r0_body.fincI60, PRE_first_tail_x15_r0_body.fincN60, PRE_first_tail_x15_r0_body.flnF60, PRE_first_tail_x15_r0_body.fh60, PRE_first_tail_x15_r0_body.fo60, PRE_first_tail_x15_r0_body.fok60, PRE_first_tail_x15_r0_body.fnd60, PRE_first_tail_x15_r0_body.fp60, PRE_first_tail_x15_r0_body.fnord60, PRE_first_tail_x15_r0_body.fi60, PRE_first_tail_x15_r0_body.fii60⟩
theorem PRE_first_tail_x15_r0_body.cnshift60 (clean : Conv.NClean (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P60.NL) (cl : SSt (· < 2666) PRE_first_tail_x15_r0_body.cx0_60.mlx) : NShift PRE_first_tail_x15_r0_body.P60 2666 PRE_first_tail_x15_r0_body.kappa60 PRE_first_tail_x15_r0_body.cx0_60 PRE_first_tail_x15_r0_body.cx1_60 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot60 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost60 (compact_a_eq PRE_first_tail_x15_r0_body.ckn060 PRE_first_tail_x15_r0_body.ckn160 PRE_first_tail_x15_r0_body.ckheap60 PRE_first_tail_x15_r0_body.ckpl60)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_60 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s591.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_60 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s591.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_60 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s591.ffi) = some PRE_first_tail_x15_r0_body.fxC_60
kernel_rfl PRE_first_tail_x15_r0_body.okrC_60 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s591.ffi) = some PRE_first_tail_x15_r0_body.krC_60
noncomputable def PRE_first_tail_x15_r0_body.fx0_60 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s593.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_60 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s593.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_60 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s593.ffi) = some PRE_first_tail_x15_r0_body.fx0_60
kernel_rfl PRE_first_tail_x15_r0_body.okr0_60 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s593.ffi) = some PRE_first_tail_x15_r0_body.kr0_60
noncomputable def PRE_first_tail_x15_r0_body.fx1_60 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s592.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_60 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s592.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_60 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s592.ffi) = some PRE_first_tail_x15_r0_body.fx1_60
kernel_rfl PRE_first_tail_x15_r0_body.okr1_60 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s592.ffi) = some PRE_first_tail_x15_r0_body.kr1_60
kernel_rfl PRE_first_tail_x15_r0_body.ff060 : PRE_first_tail_x15_r0_body.fx0_60 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_60 (PRE_first_tail_x15_r0_body.clo60.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_60.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff160 : PRE_first_tail_x15_r0_body.fx1_60 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_60 (PRE_first_tail_x15_r0_body.cwS60.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_60.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck60 : freedLB PRE_first_tail_x15_r0_body.kappa60 PRE_first_tail_x15_r0_body.cx0_60.mlx PRE_first_tail_x15_r0_body.fx0_60 PRE_first_tail_x15_r0_body.fx1_60 PRE_first_tail_x15_r0_body.clo60 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf060 : PRE_first_tail_x15_r0_body.kr0_60.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_60.flags (PRE_first_tail_x15_r0_body.clo60.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_60.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt060 : PRE_first_tail_x15_r0_body.kr0_60.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_60.targs (PRE_first_tail_x15_r0_body.clo60.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_60.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf160 : PRE_first_tail_x15_r0_body.kr1_60.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_60.flags (PRE_first_tail_x15_r0_body.cwS60.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_60.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt160 : PRE_first_tail_x15_r0_body.kr1_60.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_60.targs (PRE_first_tail_x15_r0_body.cwS60.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_60.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck60 : krecLB PRE_first_tail_x15_r0_body.kappa60 2666 PRE_first_tail_x15_r0_body.cx0_60.mlx PRE_first_tail_x15_r0_body.kr0_60 PRE_first_tail_x15_r0_body.kr1_60 PRE_first_tail_x15_r0_body.clo60 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn60 : Nat.ble 2648 2666 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge60 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s592.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s593.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR60 : pendRegB PRE_first_tail_x15_r0_body.kappa60 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe60 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s592.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift60 (clean : Conv.NClean (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P60.NL) (cl : SSt (· < 2666) PRE_first_tail_x15_r0_body.cx0_60.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_60.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_60.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_60.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_60.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P60 2666 PRE_first_tail_x15_r0_body.kappa60 PRE_first_tail_x15_r0_body.s593.ffi PRE_first_tail_x15_r0_body.s592.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift60 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue60, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp60 t ht),
    PRE_first_tail_x15_r0_body.cbridge60,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s593.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s592.ffi) (PRE_first_tail_x15_r0_body.cfoot60 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_60 PRE_first_tail_x15_r0_body.ofx1_60 hobjC PRE_first_tail_x15_r0_body.ff060 PRE_first_tail_x15_r0_body.ff160 PRE_first_tail_x15_r0_body.ffck60,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s593.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s592.ffi) (PRE_first_tail_x15_r0_body.cfoot60 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_60 PRE_first_tail_x15_r0_body.okr1_60 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn60) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf060 PRE_first_tail_x15_r0_body.fkt060 PRE_first_tail_x15_r0_body.fkf160 PRE_first_tail_x15_r0_body.fkt160 PRE_first_tail_x15_r0_body.fkck60,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh060 PRE_first_tail_x15_r0_body.cnh160 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe60) PRE_first_tail_x15_r0_body.cpendR60⟩

end Host.Load.Run.Tpl
end

section -- st60/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st60 0
host_stream_state PRE_first_tail_x15_r0_body.st60 1
host_stream_state PRE_first_tail_x15_r0_body.st60 2
host_stream_state PRE_first_tail_x15_r0_body.st60 3
host_stream_state PRE_first_tail_x15_r0_body.st60 4
host_stream_state PRE_first_tail_x15_r0_body.st60 5
end Host.Load.Run.Tpl
end

section -- Site60
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 60 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g60__g61` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s591`, the merged state `PRE_first_tail_x15_r0_body.s592`,
the site template `PRE_first_tail_x15_r0_body.st60` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s593`: the merge.
The footprint's facts are in `SiteF60`, the compaction's in `SiteC60`, `SiteK60`, `SiteNa60`, `SiteNb60`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso60 : PRE_first_tail_x15_r0_body.st60.s0 = { PRE_first_tail_x15_r0_body.s591 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs60 : List Frame := PRE_first_tail_x15_r0_body.s591.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_60 : PRE_first_tail_x15_r0_body.S591.tab.length = 2648
kernel_rfl PRE_first_tail_x15_r0_body.tab0_60 : PRE_first_tail_x15_r0_body.st60.S0.tab = PRE_first_tail_x15_r0_body.S591.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws60 : List Nat := [2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026, 2027, 2028, 2029, 2030, 2031, 2032, 2033, 2034, 2035, 2036, 2037]
kernel_rfl PRE_first_tail_x15_r0_body.fresh60 : (PRE_first_tail_x15_r0_body.S591.tab.all fun e => PRE_first_tail_x15_r0_body.ws60.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S591.oracle.all fun q => PRE_first_tail_x15_r0_body.ws60.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab60 : PRE_first_tail_x15_r0_body.S592.tab = PRE_first_tail_x15_r0_body.S591.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws60
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen60 : PRE_first_tail_x15_r0_body.st60.S5.tab.length - PRE_first_tail_x15_r0_body.st60.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged60`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap60 : PRE_first_tail_x15_r0_body.s592.heap = PRE_first_tail_x15_r0_body.st60.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext60 : PRE_first_tail_x15_r0_body.s592.next = PRE_first_tail_x15_r0_body.st60.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl60 : PRE_first_tail_x15_r0_body.s592.ctl = PRE_first_tail_x15_r0_body.st60.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack60 : PRE_first_tail_x15_r0_body.s592.stack = PRE_first_tail_x15_r0_body.st60.s5.stack ++ PRE_first_tail_x15_r0_body.s591.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs60 : PRE_first_tail_x15_r0_body.s592.jobs = PRE_first_tail_x15_r0_body.st60.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi60 : PRE_first_tail_x15_r0_body.s592.ffi = PRE_first_tail_x15_r0_body.st60.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace60 : PRE_first_tail_x15_r0_body.s592.trace = PRE_first_tail_x15_r0_body.st60.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores60 : PRE_first_tail_x15_r0_body.s592.stores = PRE_first_tail_x15_r0_body.st60.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD60
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 60 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived60 : PRE_first_tail_x15_r0_body.nr60.map (fun r => nth? PRE_first_tail_x15_r0_body.st60.S5.tab r) =
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
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo60 : PRE_first_tail_x15_r0_body.nr60.all (Nat.ble 2648) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj60 : PRE_first_tail_x15_r0_body.cws60.all (fun c => !PRE_first_tail_x15_r0_body.ws60.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ60 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws60 PRE_first_tail_x15_r0_body.crs60 PRE_first_tail_x15_r0_body.ws60

end Host.Load.Run.Tpl
end

section -- st60/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st60`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st60.wrR : List (Nat × Nat) := [(2672455, 2672456), (2721721, 2721722), (2722266, 2722267), (2722522, 2722523)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st60.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st60.s5.heap PRE_first_tail_x15_r0_body.st60.wrR ++ freshOf PRE_first_tail_x15_r0_body.st60.s5.heap PRE_first_tail_x15_r0_body.st60.s0.next PRE_first_tail_x15_r0_body.st60.s5.next
noncomputable def PRE_first_tail_x15_r0_body.st60.wr : List Nat := PRE_first_tail_x15_r0_body.st60.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st60.heapFoot : PRE_first_tail_x15_r0_body.st60.s5.heap = setAll PRE_first_tail_x15_r0_body.st60.s0.heap PRE_first_tail_x15_r0_body.st60.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st60.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st60.s0.next PRE_first_tail_x15_r0_body.st60.s5.next = true
theorem PRE_first_tail_x15_r0_body.st60.grows : PRE_first_tail_x15_r0_body.st60.s0.next ≤ PRE_first_tail_x15_r0_body.st60.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st60.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st60.wh : List Nat := [19376, 19389, 19395, 19396, 19397, 19398, 19399, 19400, 19401, 19402, 19403, 19404, 19405, 19406, 19407, 19408, 19409, 19410, 19411, 19412, 19413, 19414, 19415, 19416, 19417, 19418, 19419, 19420, 19421, 19422, 19423]
def PRE_first_tail_x15_r0_body.st60.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st60.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st60.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st60.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st60.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st60.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st60.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st60.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st60.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF60
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 60 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB60 : nodupT PRE_first_tail_x15_r0_body.st60.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup60 : PRE_first_tail_x15_r0_body.st60.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB60).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB60 : PRE_first_tail_x15_r0_body.st60.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound60 : ∀ b ∈ PRE_first_tail_x15_r0_body.st60.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB60 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr60 := PRE_first_tail_x15_r0_body.st60.s5.trace.take 120
kernel_rfl PRE_first_tail_x15_r0_body.traceEq60 : PRE_first_tail_x15_r0_body.st60.s5.trace = PRE_first_tail_x15_r0_body.trFr60 ++ PRE_first_tail_x15_r0_body.st60.s0.trace
theorem PRE_first_tail_x15_r0_body.trace60 : ∃ fr, PRE_first_tail_x15_r0_body.st60.s5.trace = fr ++ PRE_first_tail_x15_r0_body.st60.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq60⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide60 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB60 : (PRE_first_tail_x15_r0_body.wide60.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st60.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix60 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide60, WFix Map.id (Present PRE_first_tail_x15_r0_body.st60.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB60 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL60
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 60 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s592`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO60 : PRE_first_tail_x15_r0_body.st60.S0.oracle = PRE_first_tail_x15_r0_body.st60.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B60 : PRE_first_tail_x15_r0_body.st60.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st60.s0.next || (PRE_first_tail_x15_r0_body.st60.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot60 : Conv.StageFoot PRE_first_tail_x15_r0_body.st60.wr PRE_first_tail_x15_r0_body.st60.s0 PRE_first_tail_x15_r0_body.st60.s5 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st60.heapFoot PRE_first_tail_x15_r0_body.wrNodup60 PRE_first_tail_x15_r0_body.wrBound60 PRE_first_tail_x15_r0_body.wr0B60 PRE_first_tail_x15_r0_body.st60.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged60 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st60.F.S → PRE_first_tail_x15_r0_body.st60.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st60.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st60.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs60 PRE_first_tail_x15_r0_body.st60.wr PRE_first_tail_x15_r0_body.s591 PRE_first_tail_x15_r0_body.st60.s5 PRE_first_tail_x15_r0_body.st60.s0
      PRE_first_tail_x15_r0_body.st60.s5.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st60.F FR W stk M ν K PRE_first_tail_x15_r0_body.s592 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso60 PRE_first_tail_x15_r0_body.stFoot60 PRE_first_tail_x15_r0_body.wrNodup60 PRE_first_tail_x15_r0_body.wrBound60 PRE_first_tail_x15_r0_body.trace60 PRE_first_tail_x15_r0_body.mheap60
    PRE_first_tail_x15_r0_body.mnext60 PRE_first_tail_x15_r0_body.mctl60 PRE_first_tail_x15_r0_body.mstack60 PRE_first_tail_x15_r0_body.mjobs60 PRE_first_tail_x15_r0_body.mffi60 PRE_first_tail_x15_r0_body.mtrace60 PRE_first_tail_x15_r0_body.mstores60 h

def PRE_first_tail_x15_r0_body.arrEl60_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE60_2665 : arrOf PRE_first_tail_x15_r0_body.s592 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl60_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA60_2665 : isArrB PRE_first_tail_x15_r0_body.s592 2665 = true
theorem PRE_first_tail_x15_r0_body.arr60_2665 : ∃ o, PRE_first_tail_x15_r0_body.s592.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl60_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE60_2665 PRE_first_tail_x15_r0_body.arrA60_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN60_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl60_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR60_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl60_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN60_2665

def PRE_first_tail_x15_r0_body.arrEl60_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE60_2673467 : arrOf PRE_first_tail_x15_r0_body.s592 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl60_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA60_2673467 : isArrB PRE_first_tail_x15_r0_body.s592 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr60_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s592.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl60_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE60_2673467 PRE_first_tail_x15_r0_body.arrA60_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN60_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl60_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR60_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl60_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN60_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k60 : isArrB PRE_first_tail_x15_r0_body.s592 4910 = false
theorem PRE_first_tail_x15_r0_body.keep60 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s592 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k60 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr60_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl60_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ60
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 60 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s591`, the merged
state `PRE_first_tail_x15_r0_body.s592`, the canonical state `PRE_first_tail_x15_r0_body.s593`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl60 : PRE_first_tail_x15_r0_body.pl60.all (Nat.ble PRE_first_tail_x15_r0_body.s591.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd60 : nodupT PRE_first_tail_x15_r0_body.pl60 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn160 : Nat.ble PRE_first_tail_x15_r0_body.s591.next 2723702 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst60 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s591.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn60 : PRE_first_tail_x15_r0_body.s593.next = PRE_first_tail_x15_r0_body.s591.next + PRE_first_tail_x15_r0_body.pl60.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn60 : PRE_first_tail_x15_r0_body.s592.next = 2723702
kernel_rfl PRE_first_tail_x15_r0_body.zgrow60 : Nat.ble PRE_first_tail_x15_r0_body.s593.next PRE_first_tail_x15_r0_body.s592.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh60 : PRE_first_tail_x15_r0_body.S591.tab.all (fun e => PRE_first_tail_x15_r0_body.cws60.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd60 : nodupT PRE_first_tail_x15_r0_body.cws60 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi60 : PRE_first_tail_x15_r0_body.nr60.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S592.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt60 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s591.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg60_2665 : PRE_first_tail_x15_r0_body.s593.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s593 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk60_2665 : (objOf PRE_first_tail_x15_r0_body.s593 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm60_2665 : PRE_first_tail_x15_r0_body.s592.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa60.obj (objOf PRE_first_tail_x15_r0_body.s593 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s592 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg60_2673467 : PRE_first_tail_x15_r0_body.s593.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s593 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk60_2673467 : (objOf PRE_first_tail_x15_r0_body.s593 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm60_2673467 : PRE_first_tail_x15_r0_body.s592.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa60.obj (objOf PRE_first_tail_x15_r0_body.s593 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s592 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw60_4910 : (PRE_first_tail_x15_r0_body.s593.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw60_2673472 : (PRE_first_tail_x15_r0_body.s593.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw60_2673473 : (PRE_first_tail_x15_r0_body.s593.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd60 : PRE_first_tail_x15_r0_body.cl60.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr60 : PRE_first_tail_x15_r0_body.st60.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s591.next || PRE_first_tail_x15_r0_body.cl60.contains b) = true
def PRE_first_tail_x15_r0_body.zl60 : List Nat := PRE_first_tail_x15_r0_body.cl60.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE60 : PRE_first_tail_x15_r0_body.zl60.map (fun a => PRE_first_tail_x15_r0_body.s592.heap.get (PRE_first_tail_x15_r0_body.kappa60.a a)) = PRE_first_tail_x15_r0_body.zl60.map (fun a => (PRE_first_tail_x15_r0_body.s593.heap.get a).map PRE_first_tail_x15_r0_body.kappa60.hobj)
theorem PRE_first_tail_x15_r0_body.zimg60 : HeapImg PRE_first_tail_x15_r0_body.kappa60 PRE_first_tail_x15_r0_body.s593 PRE_first_tail_x15_r0_body.s592 PRE_first_tail_x15_r0_body.zl60 := PRE_first_tail_x15_r0_body.zimgE60
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl60 : PRE_first_tail_x15_r0_body.s592.ctl = PRE_first_tail_x15_r0_body.kappa60.ctl PRE_first_tail_x15_r0_body.s593.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack60 : PRE_first_tail_x15_r0_body.s592.stack = PRE_first_tail_x15_r0_body.s593.stack.map PRE_first_tail_x15_r0_body.kappa60.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs60 : PRE_first_tail_x15_r0_body.s592.jobs = PRE_first_tail_x15_r0_body.s593.jobs.map PRE_first_tail_x15_r0_body.kappa60.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores60 : PRE_first_tail_x15_r0_body.s592.stores = PRE_first_tail_x15_r0_body.kappa60.stores PRE_first_tail_x15_r0_body.s593.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots60 : checkRootsSupp PRE_first_tail_x15_r0_body.s593 2666 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC60 : PRE_first_tail_x15_r0_body.S591.tab.length + PRE_first_tail_x15_r0_body.cws60.length = 2666
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap60 : PRE_first_tail_x15_r0_body.kappa60 = Conv.Map.compact PRE_first_tail_x15_r0_body.s591.next 2723702 PRE_first_tail_x15_r0_body.S591.tab.length PRE_first_tail_x15_r0_body.pl60 (PRE_first_tail_x15_r0_body.nr60.map NumV.ref) PRE_first_tail_x15_r0_body.kd60.big
  PRE_first_tail_x15_r0_body.kd60.region PRE_first_tail_x15_r0_body.kd60.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin60 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s593.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc60 : Conv.jcleanListB (⟨19399, 16490, 2722553, 2666⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s593 PRE_first_tail_x15_r0_body.cl60 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB60 : noBigRootsP (fun i => !Conv.oldBigB (⟨19399, 16490, 2722553, 2666⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s593.trace PRE_first_tail_x15_r0_body.s593 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm60 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16463 = true
theorem PRE_first_tail_x15_r0_body.cjcl60 (h : Conv.JClean (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s591) : Conv.JClean (⟨19399, 16490, 2722553, 2666⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s593 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle60)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap60 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd60 a ha)) PRE_first_tail_x15_r0_body.zjc60

end Host.Load.Run.Tpl
end

section -- st60/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st60.bodyLast from PRE_first_tail_x15_r0_body.st60.s4 to PRE_first_tail_x15_r0_body.st60.s5 :
  interpS (step PRE_first_tail_x15_r0_body.st60.F PRE_first_tail_x15_r0_body.st60.s4).run PRE_first_tail_x15_r0_body.st60.S4 = some (PRE_first_tail_x15_r0_body.st60.s5, PRE_first_tail_x15_r0_body.st60.S5)
kernel_rfl PRE_first_tail_x15_r0_body.st60.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st60.s4.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st60.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st60.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st60/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st60.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st60.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st60.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st60.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st60.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st60.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st60.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st60.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st60.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st60.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st60.s0 PRE_first_tail_x15_r0_body.st60.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st60.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st60.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st60.s4 PRE_first_tail_x15_r0_body.st60.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st60/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st60.bodyK0F from PRE_first_tail_x15_r0_body.st60.s0 to PRE_first_tail_x15_r0_body.st60.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st60.F (PRE_first_tail_x15_r0_body.st60.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st60.ks 0).getD 0) PRE_first_tail_x15_r0_body.st60.s0 PRE_first_tail_x15_r0_body.st60.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st60.s1, PRE_first_tail_x15_r0_body.st60.S1)
theorem PRE_first_tail_x15_r0_body.st60.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st60.F (PRE_first_tail_x15_r0_body.st60.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st60.ks 0).getD 0) PRE_first_tail_x15_r0_body.st60.s0 PRE_first_tail_x15_r0_body.st60.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st60.s1, PRE_first_tail_x15_r0_body.st60.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st60.bodyOkLN_ok PRE_first_tail_x15_r0_body.st60.bodyK0F
end Host.Load.Run.Tpl
end

section -- st60/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st60.bodyK1F from PRE_first_tail_x15_r0_body.st60.s1 to PRE_first_tail_x15_r0_body.st60.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st60.F (PRE_first_tail_x15_r0_body.st60.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st60.ks 1).getD 0) PRE_first_tail_x15_r0_body.st60.s1 PRE_first_tail_x15_r0_body.st60.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st60.s2, PRE_first_tail_x15_r0_body.st60.S2)
theorem PRE_first_tail_x15_r0_body.st60.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st60.F (PRE_first_tail_x15_r0_body.st60.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st60.ks 1).getD 0) PRE_first_tail_x15_r0_body.st60.s1 PRE_first_tail_x15_r0_body.st60.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st60.s2, PRE_first_tail_x15_r0_body.st60.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st60.bodyOkLN_ok PRE_first_tail_x15_r0_body.st60.bodyK1F
end Host.Load.Run.Tpl
end

section -- st60/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st60.bodyK2F from PRE_first_tail_x15_r0_body.st60.s2 to PRE_first_tail_x15_r0_body.st60.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st60.F (PRE_first_tail_x15_r0_body.st60.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st60.ks 2).getD 0) PRE_first_tail_x15_r0_body.st60.s2 PRE_first_tail_x15_r0_body.st60.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st60.s3, PRE_first_tail_x15_r0_body.st60.S3)
theorem PRE_first_tail_x15_r0_body.st60.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st60.F (PRE_first_tail_x15_r0_body.st60.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st60.ks 2).getD 0) PRE_first_tail_x15_r0_body.st60.s2 PRE_first_tail_x15_r0_body.st60.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st60.s3, PRE_first_tail_x15_r0_body.st60.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st60.bodyOkLN_ok PRE_first_tail_x15_r0_body.st60.bodyK2F
end Host.Load.Run.Tpl
end

section -- st60/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st60.bodyK3F from PRE_first_tail_x15_r0_body.st60.s3 to PRE_first_tail_x15_r0_body.st60.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st60.F (PRE_first_tail_x15_r0_body.st60.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st60.ks 3).getD 0) PRE_first_tail_x15_r0_body.st60.s3 PRE_first_tail_x15_r0_body.st60.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st60.s4, PRE_first_tail_x15_r0_body.st60.S4)
theorem PRE_first_tail_x15_r0_body.st60.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st60.F (PRE_first_tail_x15_r0_body.st60.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st60.ks 3).getD 0) PRE_first_tail_x15_r0_body.st60.s3 PRE_first_tail_x15_r0_body.st60.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st60.s4, PRE_first_tail_x15_r0_body.st60.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st60.bodyOkLN_ok PRE_first_tail_x15_r0_body.st60.bodyK3F
end Host.Load.Run.Tpl
end

section -- st60/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st60.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st60.F (PRE_first_tail_x15_r0_body.st60.bodyOkL bytes rows) 11334 PRE_first_tail_x15_r0_body.st60.s0 PRE_first_tail_x15_r0_body.st60.S0 = some (PRE_first_tail_x15_r0_body.st60.s4, PRE_first_tail_x15_r0_body.st60.S4) :=
  runOk_trans PRE_first_tail_x15_r0_body.st60.F (PRE_first_tail_x15_r0_body.st60.bodyOkL bytes rows) ((((nth? PRE_first_tail_x15_r0_body.st60.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st60.ks 1).getD 0)) + ((nth? PRE_first_tail_x15_r0_body.st60.ks 2).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st60.ks 3).getD 0) PRE_first_tail_x15_r0_body.st60.s0 PRE_first_tail_x15_r0_body.st60.s3 PRE_first_tail_x15_r0_body.st60.s4 PRE_first_tail_x15_r0_body.st60.S0 PRE_first_tail_x15_r0_body.st60.S3 PRE_first_tail_x15_r0_body.st60.S4 (runOk_trans PRE_first_tail_x15_r0_body.st60.F (PRE_first_tail_x15_r0_body.st60.bodyOkL bytes rows) (((nth? PRE_first_tail_x15_r0_body.st60.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st60.ks 1).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st60.ks 2).getD 0) PRE_first_tail_x15_r0_body.st60.s0 PRE_first_tail_x15_r0_body.st60.s2 PRE_first_tail_x15_r0_body.st60.s3 PRE_first_tail_x15_r0_body.st60.S0 PRE_first_tail_x15_r0_body.st60.S2 PRE_first_tail_x15_r0_body.st60.S3 (runOk_trans PRE_first_tail_x15_r0_body.st60.F (PRE_first_tail_x15_r0_body.st60.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st60.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st60.ks 1).getD 0) PRE_first_tail_x15_r0_body.st60.s0 PRE_first_tail_x15_r0_body.st60.s1 PRE_first_tail_x15_r0_body.st60.s2 PRE_first_tail_x15_r0_body.st60.S0 PRE_first_tail_x15_r0_body.st60.S1 PRE_first_tail_x15_r0_body.st60.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st60.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st60.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st60.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st60.bodyK3 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st60.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st60.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st60.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st60.F (PRE_first_tail_x15_r0_body.st60.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st60.s0
  S0 := PRE_first_tail_x15_r0_body.st60.S0
  s1 := PRE_first_tail_x15_r0_body.st60.s4
  S1 := PRE_first_tail_x15_r0_body.st60.S4
  s2 := PRE_first_tail_x15_r0_body.st60.s5
  S2 := PRE_first_tail_x15_r0_body.st60.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st60.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st60.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st60.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st60.bodyHalt
  last := PRE_first_tail_x15_r0_body.st60.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st60.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC61
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 61 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s601` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa61` into the merged state
`PRE_first_tail_x15_r0_body.s600`. -/

def PRE_first_tail_x15_r0_body.pl61 : List Nat := []
def PRE_first_tail_x15_r0_body.nr61 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd61 : RData :=
  ⟨2723043, 2723045, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19412, 19412, 16503, 16503, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa61 : Map :=
  Conv.Map.compact 2723043 2723045 2687 PRE_first_tail_x15_r0_body.pl61 (PRE_first_tail_x15_r0_body.nr61.map NumV.ref) PRE_first_tail_x15_r0_body.kd61.big
    PRE_first_tail_x15_r0_body.kd61.region PRE_first_tail_x15_r0_body.kd61.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws61 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs61 : List SymE := PRE_first_tail_x15_r0_body.nr61.map fun r => (nth? PRE_first_tail_x15_r0_body.S600.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta61 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws61 PRE_first_tail_x15_r0_body.crs61
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB61 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab61 : PRE_first_tail_x15_r0_body.S601.tab = PRE_first_tail_x15_r0_body.S599.tab ++ PRE_first_tail_x15_r0_body.cws61.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace61 : PRE_first_tail_x15_r0_body.s601.trace = PRE_first_tail_x15_r0_body.s599.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext61 : PRE_first_tail_x15_r0_body.s601.next = 2723043
kernel_rfl PRE_first_tail_x15_r0_body.ccounters61 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s601.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s601.ffi).mlx.nnext) = (19412, 16503)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue61 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s601.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa61.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp61 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s601.ffi).mlx.tokens.all (bSN 2687) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean61 : Conv.cleanListB 19412 131072 (fun r => Nat.ble 77648 r) PRE_first_tail_x15_r0_body.s601
    (PRE_first_tail_x15_r0_body.wrB61 ++ (List.range 0).map (2723043 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs61 : bigsOutB 19412 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s601.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK61
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl61`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl61 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo61 : List Nat := []
def PRE_first_tail_x15_r0_body.cln61 : List Nat := []
def PRE_first_tail_x15_r0_body.cli61 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap61 : PRE_first_tail_x15_r0_body.s601.heap = Stage.setAll PRE_first_tail_x15_r0_body.s599.heap (PRE_first_tail_x15_r0_body.cl61.filterMap fun a => (PRE_first_tail_x15_r0_body.s601.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe61 : Nat.ble PRE_first_tail_x15_r0_body.s599.next PRE_first_tail_x15_r0_body.s601.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP61 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s599 PRE_first_tail_x15_r0_body.s601 PRE_first_tail_x15_r0_body.cl61 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp61 : Conv.suppListB PRE_first_tail_x15_r0_body.s601 2687 PRE_first_tail_x15_r0_body.cl61 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound61 : Conv.boundListB PRE_first_tail_x15_r0_body.s601 PRE_first_tail_x15_r0_body.cl61 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK61 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s601.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln61.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s601.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK61 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s601.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo61.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s601.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK61 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s601.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli61.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s601.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst61 : Conv.sstListB 2687 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s601.ffi).mlx PRE_first_tail_x15_r0_body.cln61 PRE_first_tail_x15_r0_body.clo61 PRE_first_tail_x15_r0_body.cli61 = true

end Host.Load.Run.Tpl
end

section -- SiteCl61
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA61 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s601.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo61.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s601.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd61 : (PRE_first_tail_x15_r0_body.clo61 ++ PRE_first_tail_x15_r0_body.cln61 ++ PRE_first_tail_x15_r0_body.cli61).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle61 : Conv.Cnt.leB (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt) (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck61 : Conv.ncleanListB (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s601.ffi).mlx PRE_first_tail_x15_r0_body.clo61 PRE_first_tail_x15_r0_body.cln61 PRE_first_tail_x15_r0_body.cli61 = true
theorem PRE_first_tail_x15_r0_body.cncl61 (h : Conv.NClean (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx) : Conv.NClean (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s601.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle61 PRE_first_tail_x15_r0_body.ckA61 PRE_first_tail_x15_r0_body.cobjsK61 PRE_first_tail_x15_r0_body.cnodesK61 PRE_first_tail_x15_r0_body.citemsK61 PRE_first_tail_x15_r0_body.cbd61 PRE_first_tail_x15_r0_body.cck61

end Host.Load.Run.Tpl
end

section -- SiteS61
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 61 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc61 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P61 : LoadP := PRE_first_tail_x15_r0_body.Pc61.raise 16503
kernel_rfl PRE_first_tail_x15_r0_body.craise61 : Nat.ble PRE_first_tail_x15_r0_body.Pc61.N0 16503 = true
theorem PRE_first_tail_x15_r0_body.raised61 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc61 PRE_first_tail_x15_r0_body.P61 :=
  .inr ⟨16503, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise61, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_61 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s601.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_61 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi)
def PRE_first_tail_x15_r0_body.khinv61 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv61 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS61 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS61 : List Nat := List.range' 16503 0
def PRE_first_tail_x15_r0_body.ciS61 : List Nat := [] ++ List.range' 16503 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh061 : PRE_first_tail_x15_r0_body.kd61.nh0 = PRE_first_tail_x15_r0_body.cx0_61.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh161 : PRE_first_tail_x15_r0_body.kd61.nh1 = PRE_first_tail_x15_r0_body.cx1_61.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn061 : PRE_first_tail_x15_r0_body.kd61.nn0 = PRE_first_tail_x15_r0_body.cx0_61.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn161 : PRE_first_tail_x15_r0_body.kd61.nn1 = PRE_first_tail_x15_r0_body.cx1_61.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo61 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P61.lo && Nat.ble PRE_first_tail_x15_r0_body.P61.lo PRE_first_tail_x15_r0_body.cx0_61.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P61.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P61.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt61 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_61.mlx.next PRE_first_tail_x15_r0_body.cx1_61.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_61.mlx.nnext PRE_first_tail_x15_r0_body.cx1_61.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband61 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P61.NL && Nat.ble PRE_first_tail_x15_r0_body.P61.NL PRE_first_tail_x15_r0_body.P61.N0 && Nat.ble PRE_first_tail_x15_r0_body.P61.N0 PRE_first_tail_x15_r0_body.cx0_61.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow61 : PRE_first_tail_x15_r0_body.kd61.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren61 : checkRenG PRE_first_tail_x15_r0_body.kd61.hnd PRE_first_tail_x15_r0_body.khinv61 (phB PRE_first_tail_x15_r0_body.cx0_61.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband61 : PRE_first_tail_x15_r0_body.kd61.checkBand PRE_first_tail_x15_r0_body.P61.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos61 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd61.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren61 : checkRenG PRE_first_tail_x15_r0_body.kd61.node PRE_first_tail_x15_r0_body.kninv61 (pnB PRE_first_tail_x15_r0_body.cx0_61.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow61 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd61.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P61.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd61.nodeF j) PRE_first_tail_x15_r0_body.cx1_61.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a61 : PRE_first_tail_x15_r0_body.cx0_61.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b61 : PRE_first_tail_x15_r0_body.cx0_61.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok161 : PRE_first_tail_x15_r0_body.cx1_61.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend61 : PRE_first_tail_x15_r0_body.cx1_61.mlx.pending = PRE_first_tail_x15_r0_body.cx0_61.mlx.pending.map PRE_first_tail_x15_r0_body.kappa61.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh61 : PRE_first_tail_x15_r0_body.cx1_61.mlx.errh = PRE_first_tail_x15_r0_body.cx0_61.mlx.errh.map PRE_first_tail_x15_r0_body.kappa61.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles61 : PRE_first_tail_x15_r0_body.cx1_61.mlx.files = PRE_first_tail_x15_r0_body.cx0_61.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch61 : PRE_first_tail_x15_r0_body.cx1_61.mlx.arch = PRE_first_tail_x15_r0_body.cx0_61.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes61 : PRE_first_tail_x15_r0_body.cx1_61.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_61.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired61 : PRE_first_tail_x15_r0_body.cx1_61.mlx.wired = PRE_first_tail_x15_r0_body.cx0_61.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost61 : PRE_first_tail_x15_r0_body.cx1_61.host = PRE_first_tail_x15_r0_body.cx0_61.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd61`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn061 : PRE_first_tail_x15_r0_body.kd61.n0 = 2723043
kernel_rfl PRE_first_tail_x15_r0_body.ckn161 : PRE_first_tail_x15_r0_body.kd61.n1 = 2723045
kernel_rfl PRE_first_tail_x15_r0_body.ckheap61 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd61.heap).all (fun x => Nat.ble 2723043 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl61 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd61.heap.get (2723043 + j) = nth? PRE_first_tail_x15_r0_body.pl61 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja61 : Nat.ble 2723043 2723043 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn61 : Nat.ble 2687 2687 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD61 : Nat.ble 2723043 PRE_first_tail_x15_r0_body.kd61.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn61 : Nat.ble 19412 PRE_first_tail_x15_r0_body.kd61.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn61 : Nat.ble 16503 PRE_first_tail_x15_r0_body.kd61.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb61 : Nat.ble 19412 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap61 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd61.heap).all (Nat.ble (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd61 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd61.hnd).all (Nat.ble (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode61 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd61.node).all (Nat.ble (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix61 : Conv.FixOld (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa61 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja61) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn61) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD61) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn61) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn61) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb61) PRE_first_tail_x15_r0_body.fheap61 PRE_first_tail_x15_r0_body.fhnd61 PRE_first_tail_x15_r0_body.fnode61
kernel_rfl PRE_first_tail_x15_r0_body.fcxn61 : (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn61 : (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle061 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_61.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_61.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk61 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd61.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A61 : PRE_first_tail_x15_r0_body.cx1_61.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS61.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_61.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O61 : PRE_first_tail_x15_r0_body.cx1_61.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS61.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_61.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N61 : PRE_first_tail_x15_r0_body.cx1_61.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS61.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_61.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I61 : PRE_first_tail_x15_r0_body.cx1_61.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS61.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_61.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd61 : (PRE_first_tail_x15_r0_body.clo61 ++ PRE_first_tail_x15_r0_body.cln61 ++ PRE_first_tail_x15_r0_body.cli61 ++ PRE_first_tail_x15_r0_body.cwS61 ++ PRE_first_tail_x15_r0_body.cnS61 ++ PRE_first_tail_x15_r0_body.ciS61).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW61 : PRE_first_tail_x15_r0_body.cwS61.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo61.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI61 : PRE_first_tail_x15_r0_body.ciS61.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli61.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN61 : PRE_first_tail_x15_r0_body.cnS61.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF61 : PRE_first_tail_x15_r0_body.cln61.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh61 : PRE_first_tail_x15_r0_body.clo61.all (handleOK PRE_first_tail_x15_r0_body.kappa61 PRE_first_tail_x15_r0_body.P61.lo PRE_first_tail_x15_r0_body.cx0_61.mlx PRE_first_tail_x15_r0_body.cx1_61.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo61 : PRE_first_tail_x15_r0_body.clo61.map (fun h => PRE_first_tail_x15_r0_body.cx1_61.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa61.handle h)) = PRE_first_tail_x15_r0_body.clo61.map (fun h => (PRE_first_tail_x15_r0_body.cx0_61.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa61.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok61 : PRE_first_tail_x15_r0_body.clo61.all (objOK PRE_first_tail_x15_r0_body.kappa61 PRE_first_tail_x15_r0_body.P61.NL PRE_first_tail_x15_r0_body.cx0_61.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd61 : PRE_first_tail_x15_r0_body.cln61.all (nodeOKF PRE_first_tail_x15_r0_body.kappa61 PRE_first_tail_x15_r0_body.P61 PRE_first_tail_x15_r0_body.cx0_61.mlx PRE_first_tail_x15_r0_body.cx1_61.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp61 : ((PRE_first_tail_x15_r0_body.cln61.filter (fullB PRE_first_tail_x15_r0_body.P61))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_61.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa61.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln61.filter (fullB PRE_first_tail_x15_r0_body.P61))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_61.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa61.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI61 : incrB PRE_first_tail_x15_r0_body.kd61.nodeF (List.range' 16503 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK61 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd61.node).all (fun k => Nat.ble 16503 k && Nat.blt k 16503) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL61 : (PRE_first_tail_x15_r0_body.cln61.filter (Nat.ble PRE_first_tail_x15_r0_body.P61.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd61.nodeF i) && (Nat.blt i 16503 || Nat.ble PRE_first_tail_x15_r0_body.kd61.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord61 : (PRE_first_tail_x15_r0_body.cln61.filter (Nat.ble PRE_first_tail_x15_r0_body.P61.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd61.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd61.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd61.nodeF j) (PRE_first_tail_x15_r0_body.kd61.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow61 PRE_first_tail_x15_r0_body.cnn161 PRE_first_tail_x15_r0_body.fnordI61 PRE_first_tail_x15_r0_body.fnordK61 PRE_first_tail_x15_r0_body.fnordL61
kernel_rfl PRE_first_tail_x15_r0_body.fi61 : PRE_first_tail_x15_r0_body.cli61.all (pnB PRE_first_tail_x15_r0_body.cx0_61.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii61 : PRE_first_tail_x15_r0_body.cli61.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_61.mlx.items.get (PRE_first_tail_x15_r0_body.kappa61.node k) = (PRE_first_tail_x15_r0_body.cx0_61.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa61.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot61 (clean : Conv.NClean (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P61.NL) (cl : SSt (· < 2687) PRE_first_tail_x15_r0_body.cx0_61.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P61 2687 PRE_first_tail_x15_r0_body.kappa61 PRE_first_tail_x15_r0_body.kd61 PRE_first_tail_x15_r0_body.khinv61 PRE_first_tail_x15_r0_body.kninv61 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx PRE_first_tail_x15_r0_body.cx0_61.mlx PRE_first_tail_x15_r0_body.cx1_61.mlx (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo61 PRE_first_tail_x15_r0_body.cln61 PRE_first_tail_x15_r0_body.cli61 PRE_first_tail_x15_r0_body.cwS61 PRE_first_tail_x15_r0_body.cnS61 PRE_first_tail_x15_r0_body.ciS61 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh061, PRE_first_tail_x15_r0_body.cnh161, PRE_first_tail_x15_r0_body.cnn061, PRE_first_tail_x15_r0_body.cnn161, PRE_first_tail_x15_r0_body.cplo61, PRE_first_tail_x15_r0_body.ccnt61, PRE_first_tail_x15_r0_body.cnband61, PRE_first_tail_x15_r0_body.chbelow61, PRE_first_tail_x15_r0_body.chren61, PRE_first_tail_x15_r0_body.cband61, PRE_first_tail_x15_r0_body.cnh1pos61, PRE_first_tail_x15_r0_body.cnren61, PRE_first_tail_x15_r0_body.cnlow61, PRE_first_tail_x15_r0_body.cabs0a61, PRE_first_tail_x15_r0_body.cabs0b61, PRE_first_tail_x15_r0_body.ctok161, PRE_first_tail_x15_r0_body.cpend61, PRE_first_tail_x15_r0_body.cerrh61, PRE_first_tail_x15_r0_body.cfiles61, PRE_first_tail_x15_r0_body.carch61, PRE_first_tail_x15_r0_body.csizes61, PRE_first_tail_x15_r0_body.cwired61, PRE_first_tail_x15_r0_body.cfix61, clean, PRE_first_tail_x15_r0_body.fcxn61, PRE_first_tail_x15_r0_body.fcnn61, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle061, PRE_first_tail_x15_r0_body.fnk61, PRE_first_tail_x15_r0_body.ckA61, PRE_first_tail_x15_r0_body.cobjsK61, PRE_first_tail_x15_r0_body.cnodesK61, PRE_first_tail_x15_r0_body.citemsK61, PRE_first_tail_x15_r0_body.f1A61, PRE_first_tail_x15_r0_body.f1O61, PRE_first_tail_x15_r0_body.f1N61, PRE_first_tail_x15_r0_body.f1I61, PRE_first_tail_x15_r0_body.fbd61, PRE_first_tail_x15_r0_body.fincW61, PRE_first_tail_x15_r0_body.fincI61, PRE_first_tail_x15_r0_body.fincN61, PRE_first_tail_x15_r0_body.flnF61, PRE_first_tail_x15_r0_body.fh61, PRE_first_tail_x15_r0_body.fo61, PRE_first_tail_x15_r0_body.fok61, PRE_first_tail_x15_r0_body.fnd61, PRE_first_tail_x15_r0_body.fp61, PRE_first_tail_x15_r0_body.fnord61, PRE_first_tail_x15_r0_body.fi61, PRE_first_tail_x15_r0_body.fii61⟩
theorem PRE_first_tail_x15_r0_body.cnshift61 (clean : Conv.NClean (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P61.NL) (cl : SSt (· < 2687) PRE_first_tail_x15_r0_body.cx0_61.mlx) : NShift PRE_first_tail_x15_r0_body.P61 2687 PRE_first_tail_x15_r0_body.kappa61 PRE_first_tail_x15_r0_body.cx0_61 PRE_first_tail_x15_r0_body.cx1_61 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot61 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost61 (compact_a_eq PRE_first_tail_x15_r0_body.ckn061 PRE_first_tail_x15_r0_body.ckn161 PRE_first_tail_x15_r0_body.ckheap61 PRE_first_tail_x15_r0_body.ckpl61)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_61 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s599.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_61 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s599.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_61 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s599.ffi) = some PRE_first_tail_x15_r0_body.fxC_61
kernel_rfl PRE_first_tail_x15_r0_body.okrC_61 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s599.ffi) = some PRE_first_tail_x15_r0_body.krC_61
noncomputable def PRE_first_tail_x15_r0_body.fx0_61 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s601.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_61 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s601.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_61 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s601.ffi) = some PRE_first_tail_x15_r0_body.fx0_61
kernel_rfl PRE_first_tail_x15_r0_body.okr0_61 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s601.ffi) = some PRE_first_tail_x15_r0_body.kr0_61
noncomputable def PRE_first_tail_x15_r0_body.fx1_61 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s600.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_61 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s600.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_61 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s600.ffi) = some PRE_first_tail_x15_r0_body.fx1_61
kernel_rfl PRE_first_tail_x15_r0_body.okr1_61 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s600.ffi) = some PRE_first_tail_x15_r0_body.kr1_61
kernel_rfl PRE_first_tail_x15_r0_body.ff061 : PRE_first_tail_x15_r0_body.fx0_61 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_61 (PRE_first_tail_x15_r0_body.clo61.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_61.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff161 : PRE_first_tail_x15_r0_body.fx1_61 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_61 (PRE_first_tail_x15_r0_body.cwS61.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_61.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck61 : freedLB PRE_first_tail_x15_r0_body.kappa61 PRE_first_tail_x15_r0_body.cx0_61.mlx PRE_first_tail_x15_r0_body.fx0_61 PRE_first_tail_x15_r0_body.fx1_61 PRE_first_tail_x15_r0_body.clo61 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf061 : PRE_first_tail_x15_r0_body.kr0_61.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_61.flags (PRE_first_tail_x15_r0_body.clo61.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_61.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt061 : PRE_first_tail_x15_r0_body.kr0_61.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_61.targs (PRE_first_tail_x15_r0_body.clo61.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_61.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf161 : PRE_first_tail_x15_r0_body.kr1_61.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_61.flags (PRE_first_tail_x15_r0_body.cwS61.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_61.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt161 : PRE_first_tail_x15_r0_body.kr1_61.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_61.targs (PRE_first_tail_x15_r0_body.cwS61.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_61.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck61 : krecLB PRE_first_tail_x15_r0_body.kappa61 2687 PRE_first_tail_x15_r0_body.cx0_61.mlx PRE_first_tail_x15_r0_body.kr0_61 PRE_first_tail_x15_r0_body.kr1_61 PRE_first_tail_x15_r0_body.clo61 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn61 : Nat.ble 2687 2687 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge61 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s600.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s601.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR61 : pendRegB PRE_first_tail_x15_r0_body.kappa61 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s601.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe61 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s601.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift61 (clean : Conv.NClean (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P61.NL) (cl : SSt (· < 2687) PRE_first_tail_x15_r0_body.cx0_61.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_61.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_61.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_61.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_61.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P61 2687 PRE_first_tail_x15_r0_body.kappa61 PRE_first_tail_x15_r0_body.s601.ffi PRE_first_tail_x15_r0_body.s600.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift61 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue61, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp61 t ht),
    PRE_first_tail_x15_r0_body.cbridge61,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s601.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s600.ffi) (PRE_first_tail_x15_r0_body.cfoot61 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_61 PRE_first_tail_x15_r0_body.ofx1_61 hobjC PRE_first_tail_x15_r0_body.ff061 PRE_first_tail_x15_r0_body.ff161 PRE_first_tail_x15_r0_body.ffck61,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s601.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s600.ffi) (PRE_first_tail_x15_r0_body.cfoot61 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_61 PRE_first_tail_x15_r0_body.okr1_61 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn61) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf061 PRE_first_tail_x15_r0_body.fkt061 PRE_first_tail_x15_r0_body.fkf161 PRE_first_tail_x15_r0_body.fkt161 PRE_first_tail_x15_r0_body.fkck61,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh061 PRE_first_tail_x15_r0_body.cnh161 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe61) PRE_first_tail_x15_r0_body.cpendR61⟩

end Host.Load.Run.Tpl
end

section -- st61/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st61 0
host_stream_state PRE_first_tail_x15_r0_body.st61 1
host_stream_state PRE_first_tail_x15_r0_body.st61 2
end Host.Load.Run.Tpl
end

section -- Site61
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 61 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g61__g62` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s599`, the merged state `PRE_first_tail_x15_r0_body.s600`,
the site template `PRE_first_tail_x15_r0_body.st61` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s601`: the merge.
The footprint's facts are in `SiteF61`, the compaction's in `SiteC61`, `SiteK61`, `SiteNa61`, `SiteNb61`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso61 : PRE_first_tail_x15_r0_body.st61.s0 = { PRE_first_tail_x15_r0_body.s599 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs61 : List Frame := PRE_first_tail_x15_r0_body.s599.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_61 : PRE_first_tail_x15_r0_body.S599.tab.length = 2687
kernel_rfl PRE_first_tail_x15_r0_body.tab0_61 : PRE_first_tail_x15_r0_body.st61.S0.tab = PRE_first_tail_x15_r0_body.S599.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws61 : List Nat := [2056, 2057]
kernel_rfl PRE_first_tail_x15_r0_body.fresh61 : (PRE_first_tail_x15_r0_body.S599.tab.all fun e => PRE_first_tail_x15_r0_body.ws61.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S599.oracle.all fun q => PRE_first_tail_x15_r0_body.ws61.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab61 : PRE_first_tail_x15_r0_body.S600.tab = PRE_first_tail_x15_r0_body.S599.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws61
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen61 : PRE_first_tail_x15_r0_body.st61.S2.tab.length - PRE_first_tail_x15_r0_body.st61.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged61`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap61 : PRE_first_tail_x15_r0_body.s600.heap = PRE_first_tail_x15_r0_body.st61.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext61 : PRE_first_tail_x15_r0_body.s600.next = PRE_first_tail_x15_r0_body.st61.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl61 : PRE_first_tail_x15_r0_body.s600.ctl = PRE_first_tail_x15_r0_body.st61.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack61 : PRE_first_tail_x15_r0_body.s600.stack = PRE_first_tail_x15_r0_body.st61.s2.stack ++ PRE_first_tail_x15_r0_body.s599.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs61 : PRE_first_tail_x15_r0_body.s600.jobs = PRE_first_tail_x15_r0_body.st61.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi61 : PRE_first_tail_x15_r0_body.s600.ffi = PRE_first_tail_x15_r0_body.st61.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace61 : PRE_first_tail_x15_r0_body.s600.trace = PRE_first_tail_x15_r0_body.st61.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores61 : PRE_first_tail_x15_r0_body.s600.stores = PRE_first_tail_x15_r0_body.st61.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD61
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 61 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived61 : PRE_first_tail_x15_r0_body.nr61.map (fun r => nth? PRE_first_tail_x15_r0_body.st61.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo61 : PRE_first_tail_x15_r0_body.nr61.all (Nat.ble 2687) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj61 : PRE_first_tail_x15_r0_body.cws61.all (fun c => !PRE_first_tail_x15_r0_body.ws61.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ61 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws61 PRE_first_tail_x15_r0_body.crs61 PRE_first_tail_x15_r0_body.ws61

end Host.Load.Run.Tpl
end

section -- st61/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st61`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st61.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st61.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st61.s2.heap PRE_first_tail_x15_r0_body.st61.wrR ++ freshOf PRE_first_tail_x15_r0_body.st61.s2.heap PRE_first_tail_x15_r0_body.st61.s0.next PRE_first_tail_x15_r0_body.st61.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st61.wr : List Nat := PRE_first_tail_x15_r0_body.st61.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st61.heapFoot : PRE_first_tail_x15_r0_body.st61.s2.heap = setAll PRE_first_tail_x15_r0_body.st61.s0.heap PRE_first_tail_x15_r0_body.st61.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st61.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st61.s0.next PRE_first_tail_x15_r0_body.st61.s2.next = true
theorem PRE_first_tail_x15_r0_body.st61.grows : PRE_first_tail_x15_r0_body.st61.s0.next ≤ PRE_first_tail_x15_r0_body.st61.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st61.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st61.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st61.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st61.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st61.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st61.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st61.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st61.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st61.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st61.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st61.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st61.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st61.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st61.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st61.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st61.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st61.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st61.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st61.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st61.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st61.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st61.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st61.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st61.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st61.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st61.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st61.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st61.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st61.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st61.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st61.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st61.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF61
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 61 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB61 : nodupT PRE_first_tail_x15_r0_body.st61.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup61 : PRE_first_tail_x15_r0_body.st61.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB61).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB61 : PRE_first_tail_x15_r0_body.st61.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound61 : ∀ b ∈ PRE_first_tail_x15_r0_body.st61.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB61 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr61 := PRE_first_tail_x15_r0_body.st61.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq61 : PRE_first_tail_x15_r0_body.st61.s2.trace = PRE_first_tail_x15_r0_body.trFr61 ++ PRE_first_tail_x15_r0_body.st61.s0.trace
theorem PRE_first_tail_x15_r0_body.trace61 : ∃ fr, PRE_first_tail_x15_r0_body.st61.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st61.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq61⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide61 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB61 : (PRE_first_tail_x15_r0_body.wide61.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st61.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix61 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide61, WFix Map.id (Present PRE_first_tail_x15_r0_body.st61.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB61 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL61
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 61 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s600`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO61 : PRE_first_tail_x15_r0_body.st61.S0.oracle = PRE_first_tail_x15_r0_body.st61.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B61 : PRE_first_tail_x15_r0_body.st61.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st61.s0.next || (PRE_first_tail_x15_r0_body.st61.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot61 : Conv.StageFoot PRE_first_tail_x15_r0_body.st61.wr PRE_first_tail_x15_r0_body.st61.s0 PRE_first_tail_x15_r0_body.st61.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st61.heapFoot PRE_first_tail_x15_r0_body.wrNodup61 PRE_first_tail_x15_r0_body.wrBound61 PRE_first_tail_x15_r0_body.wr0B61 PRE_first_tail_x15_r0_body.st61.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged61 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st61.F.S → PRE_first_tail_x15_r0_body.st61.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st61.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st61.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs61 PRE_first_tail_x15_r0_body.st61.wr PRE_first_tail_x15_r0_body.s599 PRE_first_tail_x15_r0_body.st61.s2 PRE_first_tail_x15_r0_body.st61.s0
      PRE_first_tail_x15_r0_body.st61.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st61.F FR W stk M ν K PRE_first_tail_x15_r0_body.s600 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso61 PRE_first_tail_x15_r0_body.stFoot61 PRE_first_tail_x15_r0_body.wrNodup61 PRE_first_tail_x15_r0_body.wrBound61 PRE_first_tail_x15_r0_body.trace61 PRE_first_tail_x15_r0_body.mheap61
    PRE_first_tail_x15_r0_body.mnext61 PRE_first_tail_x15_r0_body.mctl61 PRE_first_tail_x15_r0_body.mstack61 PRE_first_tail_x15_r0_body.mjobs61 PRE_first_tail_x15_r0_body.mffi61 PRE_first_tail_x15_r0_body.mtrace61 PRE_first_tail_x15_r0_body.mstores61 h

def PRE_first_tail_x15_r0_body.arrEl61_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE61_2665 : arrOf PRE_first_tail_x15_r0_body.s600 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl61_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA61_2665 : isArrB PRE_first_tail_x15_r0_body.s600 2665 = true
theorem PRE_first_tail_x15_r0_body.arr61_2665 : ∃ o, PRE_first_tail_x15_r0_body.s600.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl61_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE61_2665 PRE_first_tail_x15_r0_body.arrA61_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN61_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl61_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR61_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl61_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN61_2665

def PRE_first_tail_x15_r0_body.arrEl61_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE61_2673467 : arrOf PRE_first_tail_x15_r0_body.s600 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl61_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA61_2673467 : isArrB PRE_first_tail_x15_r0_body.s600 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr61_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s600.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl61_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE61_2673467 PRE_first_tail_x15_r0_body.arrA61_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN61_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl61_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR61_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl61_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN61_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k61 : isArrB PRE_first_tail_x15_r0_body.s600 4910 = false
theorem PRE_first_tail_x15_r0_body.keep61 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s600 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k61 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr61_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl61_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ61
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 61 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s599`, the merged
state `PRE_first_tail_x15_r0_body.s600`, the canonical state `PRE_first_tail_x15_r0_body.s601`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl61 : PRE_first_tail_x15_r0_body.pl61.all (Nat.ble PRE_first_tail_x15_r0_body.s599.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd61 : nodupT PRE_first_tail_x15_r0_body.pl61 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn161 : Nat.ble PRE_first_tail_x15_r0_body.s599.next 2723045 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst61 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s599.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn61 : PRE_first_tail_x15_r0_body.s601.next = PRE_first_tail_x15_r0_body.s599.next + PRE_first_tail_x15_r0_body.pl61.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn61 : PRE_first_tail_x15_r0_body.s600.next = 2723045
kernel_rfl PRE_first_tail_x15_r0_body.zgrow61 : Nat.ble PRE_first_tail_x15_r0_body.s601.next PRE_first_tail_x15_r0_body.s600.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh61 : PRE_first_tail_x15_r0_body.S599.tab.all (fun e => PRE_first_tail_x15_r0_body.cws61.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd61 : nodupT PRE_first_tail_x15_r0_body.cws61 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi61 : PRE_first_tail_x15_r0_body.nr61.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S600.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt61 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s599.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg61_2665 : PRE_first_tail_x15_r0_body.s601.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s601 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk61_2665 : (objOf PRE_first_tail_x15_r0_body.s601 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm61_2665 : PRE_first_tail_x15_r0_body.s600.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa61.obj (objOf PRE_first_tail_x15_r0_body.s601 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s600 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg61_2673467 : PRE_first_tail_x15_r0_body.s601.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s601 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk61_2673467 : (objOf PRE_first_tail_x15_r0_body.s601 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm61_2673467 : PRE_first_tail_x15_r0_body.s600.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa61.obj (objOf PRE_first_tail_x15_r0_body.s601 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s600 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw61_4910 : (PRE_first_tail_x15_r0_body.s601.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw61_2673472 : (PRE_first_tail_x15_r0_body.s601.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw61_2673473 : (PRE_first_tail_x15_r0_body.s601.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd61 : PRE_first_tail_x15_r0_body.cl61.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr61 : PRE_first_tail_x15_r0_body.st61.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s599.next || PRE_first_tail_x15_r0_body.cl61.contains b) = true
def PRE_first_tail_x15_r0_body.zl61 : List Nat := PRE_first_tail_x15_r0_body.cl61.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE61 : PRE_first_tail_x15_r0_body.zl61.map (fun a => PRE_first_tail_x15_r0_body.s600.heap.get (PRE_first_tail_x15_r0_body.kappa61.a a)) = PRE_first_tail_x15_r0_body.zl61.map (fun a => (PRE_first_tail_x15_r0_body.s601.heap.get a).map PRE_first_tail_x15_r0_body.kappa61.hobj)
theorem PRE_first_tail_x15_r0_body.zimg61 : HeapImg PRE_first_tail_x15_r0_body.kappa61 PRE_first_tail_x15_r0_body.s601 PRE_first_tail_x15_r0_body.s600 PRE_first_tail_x15_r0_body.zl61 := PRE_first_tail_x15_r0_body.zimgE61
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl61 : PRE_first_tail_x15_r0_body.s600.ctl = PRE_first_tail_x15_r0_body.kappa61.ctl PRE_first_tail_x15_r0_body.s601.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack61 : PRE_first_tail_x15_r0_body.s600.stack = PRE_first_tail_x15_r0_body.s601.stack.map PRE_first_tail_x15_r0_body.kappa61.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs61 : PRE_first_tail_x15_r0_body.s600.jobs = PRE_first_tail_x15_r0_body.s601.jobs.map PRE_first_tail_x15_r0_body.kappa61.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores61 : PRE_first_tail_x15_r0_body.s600.stores = PRE_first_tail_x15_r0_body.kappa61.stores PRE_first_tail_x15_r0_body.s601.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots61 : checkRootsSupp PRE_first_tail_x15_r0_body.s601 2687 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC61 : PRE_first_tail_x15_r0_body.S599.tab.length + PRE_first_tail_x15_r0_body.cws61.length = 2687
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap61 : PRE_first_tail_x15_r0_body.kappa61 = Conv.Map.compact PRE_first_tail_x15_r0_body.s599.next 2723045 PRE_first_tail_x15_r0_body.S599.tab.length PRE_first_tail_x15_r0_body.pl61 (PRE_first_tail_x15_r0_body.nr61.map NumV.ref) PRE_first_tail_x15_r0_body.kd61.big
  PRE_first_tail_x15_r0_body.kd61.region PRE_first_tail_x15_r0_body.kd61.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin61 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s601.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc61 : Conv.jcleanListB (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s601 PRE_first_tail_x15_r0_body.cl61 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB61 : noBigRootsP (fun i => !Conv.oldBigB (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s601.trace PRE_first_tail_x15_r0_body.s601 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm61 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16503 = true
theorem PRE_first_tail_x15_r0_body.cjcl61 (h : Conv.JClean (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s599) : Conv.JClean (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s601 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle61)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap61 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd61 a ha)) PRE_first_tail_x15_r0_body.zjc61

end Host.Load.Run.Tpl
end

section -- st61/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st61.bodyLast from PRE_first_tail_x15_r0_body.st61.s1 to PRE_first_tail_x15_r0_body.st61.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st61.F PRE_first_tail_x15_r0_body.st61.s1).run PRE_first_tail_x15_r0_body.st61.S1 = some (PRE_first_tail_x15_r0_body.st61.s2, PRE_first_tail_x15_r0_body.st61.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st61.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st61.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st61.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st61.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st61/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st61.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st61.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st61.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st61.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st61.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st61.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st61.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st61.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st61.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st61.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st61.s0 PRE_first_tail_x15_r0_body.st61.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st61.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st61.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st61.s1 PRE_first_tail_x15_r0_body.st61.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st61/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st61.bodyK0F from PRE_first_tail_x15_r0_body.st61.s0 to PRE_first_tail_x15_r0_body.st61.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st61.F (PRE_first_tail_x15_r0_body.st61.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st61.ks 0).getD 0) PRE_first_tail_x15_r0_body.st61.s0 PRE_first_tail_x15_r0_body.st61.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st61.s1, PRE_first_tail_x15_r0_body.st61.S1)
theorem PRE_first_tail_x15_r0_body.st61.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st61.F (PRE_first_tail_x15_r0_body.st61.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st61.ks 0).getD 0) PRE_first_tail_x15_r0_body.st61.s0 PRE_first_tail_x15_r0_body.st61.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st61.s1, PRE_first_tail_x15_r0_body.st61.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st61.bodyOkLN_ok PRE_first_tail_x15_r0_body.st61.bodyK0F
end Host.Load.Run.Tpl
end

section -- st61/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st61.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st61.F (PRE_first_tail_x15_r0_body.st61.bodyOkL bytes rows) 27 PRE_first_tail_x15_r0_body.st61.s0 PRE_first_tail_x15_r0_body.st61.S0 = some (PRE_first_tail_x15_r0_body.st61.s1, PRE_first_tail_x15_r0_body.st61.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st61.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st61.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st61.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st61.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st61.F (PRE_first_tail_x15_r0_body.st61.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st61.s0
  S0 := PRE_first_tail_x15_r0_body.st61.S0
  s1 := PRE_first_tail_x15_r0_body.st61.s1
  S1 := PRE_first_tail_x15_r0_body.st61.S1
  s2 := PRE_first_tail_x15_r0_body.st61.s2
  S2 := PRE_first_tail_x15_r0_body.st61.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st61.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st61.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st61.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st61.bodyHalt
  last := PRE_first_tail_x15_r0_body.st61.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st61.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC62
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 62 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s605` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa62` into the merged state
`PRE_first_tail_x15_r0_body.s604`. -/

def PRE_first_tail_x15_r0_body.pl62 : List Nat := [2723341]
def PRE_first_tail_x15_r0_body.nr62 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd62 : RData :=
  ⟨2723332, 2723342, Stage.setAll PTrie.nil [(2723331, 2723341)], Stage.setAll PTrie.nil [],
   19419, 19419, 16507, 16507, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa62 : Map :=
  Conv.Map.compact 2723331 2723342 2704 PRE_first_tail_x15_r0_body.pl62 (PRE_first_tail_x15_r0_body.nr62.map NumV.ref) PRE_first_tail_x15_r0_body.kd62.big
    PRE_first_tail_x15_r0_body.kd62.region PRE_first_tail_x15_r0_body.kd62.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws62 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs62 : List SymE := PRE_first_tail_x15_r0_body.nr62.map fun r => (nth? PRE_first_tail_x15_r0_body.S604.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta62 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws62 PRE_first_tail_x15_r0_body.crs62
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB62 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab62 : PRE_first_tail_x15_r0_body.S605.tab = PRE_first_tail_x15_r0_body.S603.tab ++ PRE_first_tail_x15_r0_body.cws62.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace62 : PRE_first_tail_x15_r0_body.s605.trace = PRE_first_tail_x15_r0_body.s603.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext62 : PRE_first_tail_x15_r0_body.s605.next = 2723332
kernel_rfl PRE_first_tail_x15_r0_body.ccounters62 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s605.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s605.ffi).mlx.nnext) = (19419, 16507)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue62 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s604.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s605.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa62.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp62 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s605.ffi).mlx.tokens.all (bSN 2704) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean62 : Conv.cleanListB 19419 131072 (fun r => Nat.ble 77676 r) PRE_first_tail_x15_r0_body.s605
    (PRE_first_tail_x15_r0_body.wrB62 ++ (List.range 1).map (2723331 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs62 : bigsOutB 19419 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s605.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK62
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl62`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl62 : List Nat := [2665, 2673467, 2723331]
def PRE_first_tail_x15_r0_body.clo62 : List Nat := []
def PRE_first_tail_x15_r0_body.cln62 : List Nat := []
def PRE_first_tail_x15_r0_body.cli62 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap62 : PRE_first_tail_x15_r0_body.s605.heap = Stage.setAll PRE_first_tail_x15_r0_body.s603.heap (PRE_first_tail_x15_r0_body.cl62.filterMap fun a => (PRE_first_tail_x15_r0_body.s605.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe62 : Nat.ble PRE_first_tail_x15_r0_body.s603.next PRE_first_tail_x15_r0_body.s605.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP62 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s603 PRE_first_tail_x15_r0_body.s605 PRE_first_tail_x15_r0_body.cl62 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp62 : Conv.suppListB PRE_first_tail_x15_r0_body.s605 2704 PRE_first_tail_x15_r0_body.cl62 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound62 : Conv.boundListB PRE_first_tail_x15_r0_body.s605 PRE_first_tail_x15_r0_body.cl62 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK62 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s605.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln62.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s605.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK62 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s605.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo62.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s605.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK62 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s605.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli62.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s605.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst62 : Conv.sstListB 2704 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s605.ffi).mlx PRE_first_tail_x15_r0_body.cln62 PRE_first_tail_x15_r0_body.clo62 PRE_first_tail_x15_r0_body.cli62 = true

end Host.Load.Run.Tpl
end

section -- SiteCl62
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA62 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s605.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo62.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s605.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd62 : (PRE_first_tail_x15_r0_body.clo62 ++ PRE_first_tail_x15_r0_body.cln62 ++ PRE_first_tail_x15_r0_body.cli62).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle62 : Conv.Cnt.leB (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt) (⟨19419, 16507, 2723332, 2704⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck62 : Conv.ncleanListB (⟨19419, 16507, 2723332, 2704⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s605.ffi).mlx PRE_first_tail_x15_r0_body.clo62 PRE_first_tail_x15_r0_body.cln62 PRE_first_tail_x15_r0_body.cli62 = true
theorem PRE_first_tail_x15_r0_body.cncl62 (h : Conv.NClean (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx) : Conv.NClean (⟨19419, 16507, 2723332, 2704⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s605.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle62 PRE_first_tail_x15_r0_body.ckA62 PRE_first_tail_x15_r0_body.cobjsK62 PRE_first_tail_x15_r0_body.cnodesK62 PRE_first_tail_x15_r0_body.citemsK62 PRE_first_tail_x15_r0_body.cbd62 PRE_first_tail_x15_r0_body.cck62

end Host.Load.Run.Tpl
end

section -- SiteS62
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 62 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc62 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P62 : LoadP := PRE_first_tail_x15_r0_body.Pc62.raise 16507
kernel_rfl PRE_first_tail_x15_r0_body.craise62 : Nat.ble PRE_first_tail_x15_r0_body.Pc62.N0 16507 = true
theorem PRE_first_tail_x15_r0_body.raised62 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc62 PRE_first_tail_x15_r0_body.P62 :=
  .inr ⟨16507, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise62, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_62 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s605.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_62 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s604.ffi)
def PRE_first_tail_x15_r0_body.khinv62 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv62 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS62 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS62 : List Nat := List.range' 16507 0
def PRE_first_tail_x15_r0_body.ciS62 : List Nat := [] ++ List.range' 16507 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh062 : PRE_first_tail_x15_r0_body.kd62.nh0 = PRE_first_tail_x15_r0_body.cx0_62.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh162 : PRE_first_tail_x15_r0_body.kd62.nh1 = PRE_first_tail_x15_r0_body.cx1_62.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn062 : PRE_first_tail_x15_r0_body.kd62.nn0 = PRE_first_tail_x15_r0_body.cx0_62.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn162 : PRE_first_tail_x15_r0_body.kd62.nn1 = PRE_first_tail_x15_r0_body.cx1_62.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo62 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P62.lo && Nat.ble PRE_first_tail_x15_r0_body.P62.lo PRE_first_tail_x15_r0_body.cx0_62.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P62.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P62.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt62 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_62.mlx.next PRE_first_tail_x15_r0_body.cx1_62.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_62.mlx.nnext PRE_first_tail_x15_r0_body.cx1_62.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband62 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P62.NL && Nat.ble PRE_first_tail_x15_r0_body.P62.NL PRE_first_tail_x15_r0_body.P62.N0 && Nat.ble PRE_first_tail_x15_r0_body.P62.N0 PRE_first_tail_x15_r0_body.cx0_62.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow62 : PRE_first_tail_x15_r0_body.kd62.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren62 : checkRenG PRE_first_tail_x15_r0_body.kd62.hnd PRE_first_tail_x15_r0_body.khinv62 (phB PRE_first_tail_x15_r0_body.cx0_62.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband62 : PRE_first_tail_x15_r0_body.kd62.checkBand PRE_first_tail_x15_r0_body.P62.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos62 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd62.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren62 : checkRenG PRE_first_tail_x15_r0_body.kd62.node PRE_first_tail_x15_r0_body.kninv62 (pnB PRE_first_tail_x15_r0_body.cx0_62.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow62 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd62.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P62.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd62.nodeF j) PRE_first_tail_x15_r0_body.cx1_62.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a62 : PRE_first_tail_x15_r0_body.cx0_62.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b62 : PRE_first_tail_x15_r0_body.cx0_62.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok162 : PRE_first_tail_x15_r0_body.cx1_62.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend62 : PRE_first_tail_x15_r0_body.cx1_62.mlx.pending = PRE_first_tail_x15_r0_body.cx0_62.mlx.pending.map PRE_first_tail_x15_r0_body.kappa62.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh62 : PRE_first_tail_x15_r0_body.cx1_62.mlx.errh = PRE_first_tail_x15_r0_body.cx0_62.mlx.errh.map PRE_first_tail_x15_r0_body.kappa62.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles62 : PRE_first_tail_x15_r0_body.cx1_62.mlx.files = PRE_first_tail_x15_r0_body.cx0_62.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch62 : PRE_first_tail_x15_r0_body.cx1_62.mlx.arch = PRE_first_tail_x15_r0_body.cx0_62.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes62 : PRE_first_tail_x15_r0_body.cx1_62.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_62.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired62 : PRE_first_tail_x15_r0_body.cx1_62.mlx.wired = PRE_first_tail_x15_r0_body.cx0_62.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost62 : PRE_first_tail_x15_r0_body.cx1_62.host = PRE_first_tail_x15_r0_body.cx0_62.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd62`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn062 : PRE_first_tail_x15_r0_body.kd62.n0 = 2723332
kernel_rfl PRE_first_tail_x15_r0_body.ckn162 : PRE_first_tail_x15_r0_body.kd62.n1 = 2723342
kernel_rfl PRE_first_tail_x15_r0_body.ckheap62 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd62.heap).all (fun x => Nat.ble 2723331 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl62 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd62.heap.get (2723331 + j) = nth? PRE_first_tail_x15_r0_body.pl62 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja62 : Nat.ble 2723331 2723331 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn62 : Nat.ble 2704 2704 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD62 : Nat.ble 2723331 PRE_first_tail_x15_r0_body.kd62.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn62 : Nat.ble 19419 PRE_first_tail_x15_r0_body.kd62.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn62 : Nat.ble 16507 PRE_first_tail_x15_r0_body.kd62.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb62 : Nat.ble 19419 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap62 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd62.heap).all (Nat.ble (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd62 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd62.hnd).all (Nat.ble (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode62 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd62.node).all (Nat.ble (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix62 : Conv.FixOld (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa62 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja62) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn62) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD62) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn62) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn62) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb62) PRE_first_tail_x15_r0_body.fheap62 PRE_first_tail_x15_r0_body.fhnd62 PRE_first_tail_x15_r0_body.fnode62
kernel_rfl PRE_first_tail_x15_r0_body.fcxn62 : (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn62 : (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle062 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_62.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_62.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk62 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd62.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A62 : PRE_first_tail_x15_r0_body.cx1_62.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS62.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_62.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O62 : PRE_first_tail_x15_r0_body.cx1_62.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS62.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_62.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N62 : PRE_first_tail_x15_r0_body.cx1_62.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS62.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_62.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I62 : PRE_first_tail_x15_r0_body.cx1_62.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS62.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_62.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd62 : (PRE_first_tail_x15_r0_body.clo62 ++ PRE_first_tail_x15_r0_body.cln62 ++ PRE_first_tail_x15_r0_body.cli62 ++ PRE_first_tail_x15_r0_body.cwS62 ++ PRE_first_tail_x15_r0_body.cnS62 ++ PRE_first_tail_x15_r0_body.ciS62).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW62 : PRE_first_tail_x15_r0_body.cwS62.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo62.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI62 : PRE_first_tail_x15_r0_body.ciS62.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli62.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN62 : PRE_first_tail_x15_r0_body.cnS62.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF62 : PRE_first_tail_x15_r0_body.cln62.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh62 : PRE_first_tail_x15_r0_body.clo62.all (handleOK PRE_first_tail_x15_r0_body.kappa62 PRE_first_tail_x15_r0_body.P62.lo PRE_first_tail_x15_r0_body.cx0_62.mlx PRE_first_tail_x15_r0_body.cx1_62.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo62 : PRE_first_tail_x15_r0_body.clo62.map (fun h => PRE_first_tail_x15_r0_body.cx1_62.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa62.handle h)) = PRE_first_tail_x15_r0_body.clo62.map (fun h => (PRE_first_tail_x15_r0_body.cx0_62.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa62.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok62 : PRE_first_tail_x15_r0_body.clo62.all (objOK PRE_first_tail_x15_r0_body.kappa62 PRE_first_tail_x15_r0_body.P62.NL PRE_first_tail_x15_r0_body.cx0_62.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd62 : PRE_first_tail_x15_r0_body.cln62.all (nodeOKF PRE_first_tail_x15_r0_body.kappa62 PRE_first_tail_x15_r0_body.P62 PRE_first_tail_x15_r0_body.cx0_62.mlx PRE_first_tail_x15_r0_body.cx1_62.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp62 : ((PRE_first_tail_x15_r0_body.cln62.filter (fullB PRE_first_tail_x15_r0_body.P62))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_62.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa62.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln62.filter (fullB PRE_first_tail_x15_r0_body.P62))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_62.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa62.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI62 : incrB PRE_first_tail_x15_r0_body.kd62.nodeF (List.range' 16507 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK62 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd62.node).all (fun k => Nat.ble 16507 k && Nat.blt k 16507) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL62 : (PRE_first_tail_x15_r0_body.cln62.filter (Nat.ble PRE_first_tail_x15_r0_body.P62.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd62.nodeF i) && (Nat.blt i 16507 || Nat.ble PRE_first_tail_x15_r0_body.kd62.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord62 : (PRE_first_tail_x15_r0_body.cln62.filter (Nat.ble PRE_first_tail_x15_r0_body.P62.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd62.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd62.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd62.nodeF j) (PRE_first_tail_x15_r0_body.kd62.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow62 PRE_first_tail_x15_r0_body.cnn162 PRE_first_tail_x15_r0_body.fnordI62 PRE_first_tail_x15_r0_body.fnordK62 PRE_first_tail_x15_r0_body.fnordL62
kernel_rfl PRE_first_tail_x15_r0_body.fi62 : PRE_first_tail_x15_r0_body.cli62.all (pnB PRE_first_tail_x15_r0_body.cx0_62.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii62 : PRE_first_tail_x15_r0_body.cli62.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_62.mlx.items.get (PRE_first_tail_x15_r0_body.kappa62.node k) = (PRE_first_tail_x15_r0_body.cx0_62.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa62.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot62 (clean : Conv.NClean (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P62.NL) (cl : SSt (· < 2704) PRE_first_tail_x15_r0_body.cx0_62.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P62 2704 PRE_first_tail_x15_r0_body.kappa62 PRE_first_tail_x15_r0_body.kd62 PRE_first_tail_x15_r0_body.khinv62 PRE_first_tail_x15_r0_body.kninv62 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx PRE_first_tail_x15_r0_body.cx0_62.mlx PRE_first_tail_x15_r0_body.cx1_62.mlx (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo62 PRE_first_tail_x15_r0_body.cln62 PRE_first_tail_x15_r0_body.cli62 PRE_first_tail_x15_r0_body.cwS62 PRE_first_tail_x15_r0_body.cnS62 PRE_first_tail_x15_r0_body.ciS62 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh062, PRE_first_tail_x15_r0_body.cnh162, PRE_first_tail_x15_r0_body.cnn062, PRE_first_tail_x15_r0_body.cnn162, PRE_first_tail_x15_r0_body.cplo62, PRE_first_tail_x15_r0_body.ccnt62, PRE_first_tail_x15_r0_body.cnband62, PRE_first_tail_x15_r0_body.chbelow62, PRE_first_tail_x15_r0_body.chren62, PRE_first_tail_x15_r0_body.cband62, PRE_first_tail_x15_r0_body.cnh1pos62, PRE_first_tail_x15_r0_body.cnren62, PRE_first_tail_x15_r0_body.cnlow62, PRE_first_tail_x15_r0_body.cabs0a62, PRE_first_tail_x15_r0_body.cabs0b62, PRE_first_tail_x15_r0_body.ctok162, PRE_first_tail_x15_r0_body.cpend62, PRE_first_tail_x15_r0_body.cerrh62, PRE_first_tail_x15_r0_body.cfiles62, PRE_first_tail_x15_r0_body.carch62, PRE_first_tail_x15_r0_body.csizes62, PRE_first_tail_x15_r0_body.cwired62, PRE_first_tail_x15_r0_body.cfix62, clean, PRE_first_tail_x15_r0_body.fcxn62, PRE_first_tail_x15_r0_body.fcnn62, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle062, PRE_first_tail_x15_r0_body.fnk62, PRE_first_tail_x15_r0_body.ckA62, PRE_first_tail_x15_r0_body.cobjsK62, PRE_first_tail_x15_r0_body.cnodesK62, PRE_first_tail_x15_r0_body.citemsK62, PRE_first_tail_x15_r0_body.f1A62, PRE_first_tail_x15_r0_body.f1O62, PRE_first_tail_x15_r0_body.f1N62, PRE_first_tail_x15_r0_body.f1I62, PRE_first_tail_x15_r0_body.fbd62, PRE_first_tail_x15_r0_body.fincW62, PRE_first_tail_x15_r0_body.fincI62, PRE_first_tail_x15_r0_body.fincN62, PRE_first_tail_x15_r0_body.flnF62, PRE_first_tail_x15_r0_body.fh62, PRE_first_tail_x15_r0_body.fo62, PRE_first_tail_x15_r0_body.fok62, PRE_first_tail_x15_r0_body.fnd62, PRE_first_tail_x15_r0_body.fp62, PRE_first_tail_x15_r0_body.fnord62, PRE_first_tail_x15_r0_body.fi62, PRE_first_tail_x15_r0_body.fii62⟩
theorem PRE_first_tail_x15_r0_body.cnshift62 (clean : Conv.NClean (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P62.NL) (cl : SSt (· < 2704) PRE_first_tail_x15_r0_body.cx0_62.mlx) : NShift PRE_first_tail_x15_r0_body.P62 2704 PRE_first_tail_x15_r0_body.kappa62 PRE_first_tail_x15_r0_body.cx0_62 PRE_first_tail_x15_r0_body.cx1_62 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot62 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost62 (compact_a_eq PRE_first_tail_x15_r0_body.ckn062 PRE_first_tail_x15_r0_body.ckn162 PRE_first_tail_x15_r0_body.ckheap62 PRE_first_tail_x15_r0_body.ckpl62)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_62 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s603.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_62 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s603.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_62 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s603.ffi) = some PRE_first_tail_x15_r0_body.fxC_62
kernel_rfl PRE_first_tail_x15_r0_body.okrC_62 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s603.ffi) = some PRE_first_tail_x15_r0_body.krC_62
noncomputable def PRE_first_tail_x15_r0_body.fx0_62 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s605.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_62 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s605.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_62 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s605.ffi) = some PRE_first_tail_x15_r0_body.fx0_62
kernel_rfl PRE_first_tail_x15_r0_body.okr0_62 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s605.ffi) = some PRE_first_tail_x15_r0_body.kr0_62
noncomputable def PRE_first_tail_x15_r0_body.fx1_62 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s604.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_62 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s604.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_62 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s604.ffi) = some PRE_first_tail_x15_r0_body.fx1_62
kernel_rfl PRE_first_tail_x15_r0_body.okr1_62 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s604.ffi) = some PRE_first_tail_x15_r0_body.kr1_62
kernel_rfl PRE_first_tail_x15_r0_body.ff062 : PRE_first_tail_x15_r0_body.fx0_62 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_62 (PRE_first_tail_x15_r0_body.clo62.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_62.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff162 : PRE_first_tail_x15_r0_body.fx1_62 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_62 (PRE_first_tail_x15_r0_body.cwS62.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_62.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck62 : freedLB PRE_first_tail_x15_r0_body.kappa62 PRE_first_tail_x15_r0_body.cx0_62.mlx PRE_first_tail_x15_r0_body.fx0_62 PRE_first_tail_x15_r0_body.fx1_62 PRE_first_tail_x15_r0_body.clo62 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf062 : PRE_first_tail_x15_r0_body.kr0_62.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_62.flags (PRE_first_tail_x15_r0_body.clo62.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_62.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt062 : PRE_first_tail_x15_r0_body.kr0_62.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_62.targs (PRE_first_tail_x15_r0_body.clo62.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_62.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf162 : PRE_first_tail_x15_r0_body.kr1_62.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_62.flags (PRE_first_tail_x15_r0_body.cwS62.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_62.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt162 : PRE_first_tail_x15_r0_body.kr1_62.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_62.targs (PRE_first_tail_x15_r0_body.cwS62.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_62.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck62 : krecLB PRE_first_tail_x15_r0_body.kappa62 2704 PRE_first_tail_x15_r0_body.cx0_62.mlx PRE_first_tail_x15_r0_body.kr0_62 PRE_first_tail_x15_r0_body.kr1_62 PRE_first_tail_x15_r0_body.clo62 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn62 : Nat.ble 2704 2704 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge62 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s604.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s605.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR62 : pendRegB PRE_first_tail_x15_r0_body.kappa62 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s605.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe62 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s605.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s604.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift62 (clean : Conv.NClean (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P62.NL) (cl : SSt (· < 2704) PRE_first_tail_x15_r0_body.cx0_62.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_62.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_62.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_62.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_62.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P62 2704 PRE_first_tail_x15_r0_body.kappa62 PRE_first_tail_x15_r0_body.s605.ffi PRE_first_tail_x15_r0_body.s604.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift62 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue62, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp62 t ht),
    PRE_first_tail_x15_r0_body.cbridge62,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s605.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s604.ffi) (PRE_first_tail_x15_r0_body.cfoot62 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_62 PRE_first_tail_x15_r0_body.ofx1_62 hobjC PRE_first_tail_x15_r0_body.ff062 PRE_first_tail_x15_r0_body.ff162 PRE_first_tail_x15_r0_body.ffck62,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s605.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s604.ffi) (PRE_first_tail_x15_r0_body.cfoot62 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_62 PRE_first_tail_x15_r0_body.okr1_62 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn62) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf062 PRE_first_tail_x15_r0_body.fkt062 PRE_first_tail_x15_r0_body.fkf162 PRE_first_tail_x15_r0_body.fkt162 PRE_first_tail_x15_r0_body.fkck62,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh062 PRE_first_tail_x15_r0_body.cnh162 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe62) PRE_first_tail_x15_r0_body.cpendR62⟩

end Host.Load.Run.Tpl
end

section -- st62/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st62 0
host_stream_state PRE_first_tail_x15_r0_body.st62 1
host_stream_state PRE_first_tail_x15_r0_body.st62 2
end Host.Load.Run.Tpl
end

section -- Site62
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 62 of chain `PRE_first_tail_x15_r0_body`: `plan__g62__g63` (`plan`), the call state `PRE_first_tail_x15_r0_body.s603`, the merged state `PRE_first_tail_x15_r0_body.s604`,
the site template `PRE_first_tail_x15_r0_body.st62` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s605`: the merge.
The footprint's facts are in `SiteF62`, the compaction's in `SiteC62`, `SiteK62`, `SiteNa62`, `SiteNb62`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso62 : PRE_first_tail_x15_r0_body.st62.s0 = { PRE_first_tail_x15_r0_body.s603 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs62 : List Frame := PRE_first_tail_x15_r0_body.s603.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_62 : PRE_first_tail_x15_r0_body.S603.tab.length = 2704
kernel_rfl PRE_first_tail_x15_r0_body.tab0_62 : PRE_first_tail_x15_r0_body.st62.S0.tab = PRE_first_tail_x15_r0_body.S603.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws62 : List Nat := [2058, 2059, 2060]
kernel_rfl PRE_first_tail_x15_r0_body.fresh62 : (PRE_first_tail_x15_r0_body.S603.tab.all fun e => PRE_first_tail_x15_r0_body.ws62.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S603.oracle.all fun q => PRE_first_tail_x15_r0_body.ws62.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab62 : PRE_first_tail_x15_r0_body.S604.tab = PRE_first_tail_x15_r0_body.S603.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws62
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen62 : PRE_first_tail_x15_r0_body.st62.S2.tab.length - PRE_first_tail_x15_r0_body.st62.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged62`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap62 : PRE_first_tail_x15_r0_body.s604.heap = PRE_first_tail_x15_r0_body.st62.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext62 : PRE_first_tail_x15_r0_body.s604.next = PRE_first_tail_x15_r0_body.st62.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl62 : PRE_first_tail_x15_r0_body.s604.ctl = PRE_first_tail_x15_r0_body.st62.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack62 : PRE_first_tail_x15_r0_body.s604.stack = PRE_first_tail_x15_r0_body.st62.s2.stack ++ PRE_first_tail_x15_r0_body.s603.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs62 : PRE_first_tail_x15_r0_body.s604.jobs = PRE_first_tail_x15_r0_body.st62.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi62 : PRE_first_tail_x15_r0_body.s604.ffi = PRE_first_tail_x15_r0_body.st62.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace62 : PRE_first_tail_x15_r0_body.s604.trace = PRE_first_tail_x15_r0_body.st62.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores62 : PRE_first_tail_x15_r0_body.s604.stores = PRE_first_tail_x15_r0_body.st62.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD62
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 62 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived62 : PRE_first_tail_x15_r0_body.nr62.map (fun r => nth? PRE_first_tail_x15_r0_body.st62.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo62 : PRE_first_tail_x15_r0_body.nr62.all (Nat.ble 2704) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj62 : PRE_first_tail_x15_r0_body.cws62.all (fun c => !PRE_first_tail_x15_r0_body.ws62.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ62 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws62 PRE_first_tail_x15_r0_body.crs62 PRE_first_tail_x15_r0_body.ws62

end Host.Load.Run.Tpl
end

section -- st62/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st62`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st62.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st62.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st62.s2.heap PRE_first_tail_x15_r0_body.st62.wrR ++ freshOf PRE_first_tail_x15_r0_body.st62.s2.heap PRE_first_tail_x15_r0_body.st62.s0.next PRE_first_tail_x15_r0_body.st62.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st62.wr : List Nat := PRE_first_tail_x15_r0_body.st62.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st62.heapFoot : PRE_first_tail_x15_r0_body.st62.s2.heap = setAll PRE_first_tail_x15_r0_body.st62.s0.heap PRE_first_tail_x15_r0_body.st62.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st62.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st62.s0.next PRE_first_tail_x15_r0_body.st62.s2.next = true
theorem PRE_first_tail_x15_r0_body.st62.grows : PRE_first_tail_x15_r0_body.st62.s0.next ≤ PRE_first_tail_x15_r0_body.st62.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st62.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st62.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st62.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st62.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st62.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st62.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st62.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st62.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st62.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st62.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st62.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st62.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st62.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st62.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st62.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st62.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st62.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st62.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st62.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st62.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st62.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st62.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st62.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st62.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st62.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st62.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st62.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st62.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st62.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st62.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st62.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st62.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF62
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 62 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB62 : nodupT PRE_first_tail_x15_r0_body.st62.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup62 : PRE_first_tail_x15_r0_body.st62.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB62).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB62 : PRE_first_tail_x15_r0_body.st62.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound62 : ∀ b ∈ PRE_first_tail_x15_r0_body.st62.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB62 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr62 := PRE_first_tail_x15_r0_body.st62.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq62 : PRE_first_tail_x15_r0_body.st62.s2.trace = PRE_first_tail_x15_r0_body.trFr62 ++ PRE_first_tail_x15_r0_body.st62.s0.trace
theorem PRE_first_tail_x15_r0_body.trace62 : ∃ fr, PRE_first_tail_x15_r0_body.st62.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st62.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq62⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide62 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB62 : (PRE_first_tail_x15_r0_body.wide62.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st62.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix62 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide62, WFix Map.id (Present PRE_first_tail_x15_r0_body.st62.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB62 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL62
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 62 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s604`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO62 : PRE_first_tail_x15_r0_body.st62.S0.oracle = PRE_first_tail_x15_r0_body.st62.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B62 : PRE_first_tail_x15_r0_body.st62.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st62.s0.next || (PRE_first_tail_x15_r0_body.st62.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot62 : Conv.StageFoot PRE_first_tail_x15_r0_body.st62.wr PRE_first_tail_x15_r0_body.st62.s0 PRE_first_tail_x15_r0_body.st62.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st62.heapFoot PRE_first_tail_x15_r0_body.wrNodup62 PRE_first_tail_x15_r0_body.wrBound62 PRE_first_tail_x15_r0_body.wr0B62 PRE_first_tail_x15_r0_body.st62.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged62 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st62.F.S → PRE_first_tail_x15_r0_body.st62.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st62.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st62.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs62 PRE_first_tail_x15_r0_body.st62.wr PRE_first_tail_x15_r0_body.s603 PRE_first_tail_x15_r0_body.st62.s2 PRE_first_tail_x15_r0_body.st62.s0
      PRE_first_tail_x15_r0_body.st62.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st62.F FR W stk M ν K PRE_first_tail_x15_r0_body.s604 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso62 PRE_first_tail_x15_r0_body.stFoot62 PRE_first_tail_x15_r0_body.wrNodup62 PRE_first_tail_x15_r0_body.wrBound62 PRE_first_tail_x15_r0_body.trace62 PRE_first_tail_x15_r0_body.mheap62
    PRE_first_tail_x15_r0_body.mnext62 PRE_first_tail_x15_r0_body.mctl62 PRE_first_tail_x15_r0_body.mstack62 PRE_first_tail_x15_r0_body.mjobs62 PRE_first_tail_x15_r0_body.mffi62 PRE_first_tail_x15_r0_body.mtrace62 PRE_first_tail_x15_r0_body.mstores62 h

def PRE_first_tail_x15_r0_body.arrEl62_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE62_2665 : arrOf PRE_first_tail_x15_r0_body.s604 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl62_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA62_2665 : isArrB PRE_first_tail_x15_r0_body.s604 2665 = true
theorem PRE_first_tail_x15_r0_body.arr62_2665 : ∃ o, PRE_first_tail_x15_r0_body.s604.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl62_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE62_2665 PRE_first_tail_x15_r0_body.arrA62_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN62_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl62_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR62_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl62_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN62_2665

def PRE_first_tail_x15_r0_body.arrEl62_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE62_2673467 : arrOf PRE_first_tail_x15_r0_body.s604 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl62_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA62_2673467 : isArrB PRE_first_tail_x15_r0_body.s604 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr62_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s604.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl62_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE62_2673467 PRE_first_tail_x15_r0_body.arrA62_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN62_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl62_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR62_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl62_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN62_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k62 : isArrB PRE_first_tail_x15_r0_body.s604 4910 = false
theorem PRE_first_tail_x15_r0_body.keep62 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s604 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k62 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr62_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl62_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ62
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 62 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s603`, the merged
state `PRE_first_tail_x15_r0_body.s604`, the canonical state `PRE_first_tail_x15_r0_body.s605`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl62 : PRE_first_tail_x15_r0_body.pl62.all (Nat.ble PRE_first_tail_x15_r0_body.s603.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd62 : nodupT PRE_first_tail_x15_r0_body.pl62 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn162 : Nat.ble PRE_first_tail_x15_r0_body.s603.next 2723342 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst62 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s603.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn62 : PRE_first_tail_x15_r0_body.s605.next = PRE_first_tail_x15_r0_body.s603.next + PRE_first_tail_x15_r0_body.pl62.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn62 : PRE_first_tail_x15_r0_body.s604.next = 2723342
kernel_rfl PRE_first_tail_x15_r0_body.zgrow62 : Nat.ble PRE_first_tail_x15_r0_body.s605.next PRE_first_tail_x15_r0_body.s604.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh62 : PRE_first_tail_x15_r0_body.S603.tab.all (fun e => PRE_first_tail_x15_r0_body.cws62.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd62 : nodupT PRE_first_tail_x15_r0_body.cws62 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi62 : PRE_first_tail_x15_r0_body.nr62.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S604.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt62 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s603.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg62_2665 : PRE_first_tail_x15_r0_body.s605.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s605 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk62_2665 : (objOf PRE_first_tail_x15_r0_body.s605 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm62_2665 : PRE_first_tail_x15_r0_body.s604.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa62.obj (objOf PRE_first_tail_x15_r0_body.s605 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s604 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg62_2673467 : PRE_first_tail_x15_r0_body.s605.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s605 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk62_2673467 : (objOf PRE_first_tail_x15_r0_body.s605 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm62_2673467 : PRE_first_tail_x15_r0_body.s604.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa62.obj (objOf PRE_first_tail_x15_r0_body.s605 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s604 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw62_4910 : (PRE_first_tail_x15_r0_body.s605.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw62_2673472 : (PRE_first_tail_x15_r0_body.s605.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw62_2673473 : (PRE_first_tail_x15_r0_body.s605.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd62 : PRE_first_tail_x15_r0_body.cl62.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr62 : PRE_first_tail_x15_r0_body.st62.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s603.next || PRE_first_tail_x15_r0_body.cl62.contains b) = true
def PRE_first_tail_x15_r0_body.zl62 : List Nat := PRE_first_tail_x15_r0_body.cl62.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE62 : PRE_first_tail_x15_r0_body.zl62.map (fun a => PRE_first_tail_x15_r0_body.s604.heap.get (PRE_first_tail_x15_r0_body.kappa62.a a)) = PRE_first_tail_x15_r0_body.zl62.map (fun a => (PRE_first_tail_x15_r0_body.s605.heap.get a).map PRE_first_tail_x15_r0_body.kappa62.hobj)
theorem PRE_first_tail_x15_r0_body.zimg62 : HeapImg PRE_first_tail_x15_r0_body.kappa62 PRE_first_tail_x15_r0_body.s605 PRE_first_tail_x15_r0_body.s604 PRE_first_tail_x15_r0_body.zl62 := PRE_first_tail_x15_r0_body.zimgE62
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl62 : PRE_first_tail_x15_r0_body.s604.ctl = PRE_first_tail_x15_r0_body.kappa62.ctl PRE_first_tail_x15_r0_body.s605.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack62 : PRE_first_tail_x15_r0_body.s604.stack = PRE_first_tail_x15_r0_body.s605.stack.map PRE_first_tail_x15_r0_body.kappa62.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs62 : PRE_first_tail_x15_r0_body.s604.jobs = PRE_first_tail_x15_r0_body.s605.jobs.map PRE_first_tail_x15_r0_body.kappa62.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores62 : PRE_first_tail_x15_r0_body.s604.stores = PRE_first_tail_x15_r0_body.kappa62.stores PRE_first_tail_x15_r0_body.s605.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots62 : checkRootsSupp PRE_first_tail_x15_r0_body.s605 2704 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC62 : PRE_first_tail_x15_r0_body.S603.tab.length + PRE_first_tail_x15_r0_body.cws62.length = 2704
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap62 : PRE_first_tail_x15_r0_body.kappa62 = Conv.Map.compact PRE_first_tail_x15_r0_body.s603.next 2723342 PRE_first_tail_x15_r0_body.S603.tab.length PRE_first_tail_x15_r0_body.pl62 (PRE_first_tail_x15_r0_body.nr62.map NumV.ref) PRE_first_tail_x15_r0_body.kd62.big
  PRE_first_tail_x15_r0_body.kd62.region PRE_first_tail_x15_r0_body.kd62.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin62 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s605.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc62 : Conv.jcleanListB (⟨19419, 16507, 2723332, 2704⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s605 PRE_first_tail_x15_r0_body.cl62 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB62 : noBigRootsP (fun i => !Conv.oldBigB (⟨19419, 16507, 2723332, 2704⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s605.trace PRE_first_tail_x15_r0_body.s605 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm62 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16507 = true
theorem PRE_first_tail_x15_r0_body.cjcl62 (h : Conv.JClean (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s603) : Conv.JClean (⟨19419, 16507, 2723332, 2704⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s605 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle62)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap62 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd62 a ha)) PRE_first_tail_x15_r0_body.zjc62

end Host.Load.Run.Tpl
end

section -- st62/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st62.bodyLast from PRE_first_tail_x15_r0_body.st62.s1 to PRE_first_tail_x15_r0_body.st62.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st62.F PRE_first_tail_x15_r0_body.st62.s1).run PRE_first_tail_x15_r0_body.st62.S1 = some (PRE_first_tail_x15_r0_body.st62.s2, PRE_first_tail_x15_r0_body.st62.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st62.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st62.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st62.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st62.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st62/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st62.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st62.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st62.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st62.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st62.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st62.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st62.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st62.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st62.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st62.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st62.s0 PRE_first_tail_x15_r0_body.st62.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st62.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st62.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st62.s1 PRE_first_tail_x15_r0_body.st62.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st62/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st62.bodyK0F from PRE_first_tail_x15_r0_body.st62.s0 to PRE_first_tail_x15_r0_body.st62.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st62.F (PRE_first_tail_x15_r0_body.st62.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st62.ks 0).getD 0) PRE_first_tail_x15_r0_body.st62.s0 PRE_first_tail_x15_r0_body.st62.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st62.s1, PRE_first_tail_x15_r0_body.st62.S1)
theorem PRE_first_tail_x15_r0_body.st62.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st62.F (PRE_first_tail_x15_r0_body.st62.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st62.ks 0).getD 0) PRE_first_tail_x15_r0_body.st62.s0 PRE_first_tail_x15_r0_body.st62.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st62.s1, PRE_first_tail_x15_r0_body.st62.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st62.bodyOkLN_ok PRE_first_tail_x15_r0_body.st62.bodyK0F
end Host.Load.Run.Tpl
end

section -- st62/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st62.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st62.F (PRE_first_tail_x15_r0_body.st62.bodyOkL bytes rows) 98 PRE_first_tail_x15_r0_body.st62.s0 PRE_first_tail_x15_r0_body.st62.S0 = some (PRE_first_tail_x15_r0_body.st62.s1, PRE_first_tail_x15_r0_body.st62.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st62.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st62.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st62.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st62.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st62.F (PRE_first_tail_x15_r0_body.st62.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st62.s0
  S0 := PRE_first_tail_x15_r0_body.st62.S0
  s1 := PRE_first_tail_x15_r0_body.st62.s1
  S1 := PRE_first_tail_x15_r0_body.st62.S1
  s2 := PRE_first_tail_x15_r0_body.st62.s2
  S2 := PRE_first_tail_x15_r0_body.st62.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st62.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st62.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st62.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st62.bodyHalt
  last := PRE_first_tail_x15_r0_body.st62.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st62.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC63
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 63 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s622` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa63` into the merged state
`PRE_first_tail_x15_r0_body.s621`. -/

def PRE_first_tail_x15_r0_body.pl63 : List Nat := [2725915, 2725090, 2725921, 2725917, 2725092, 2725923]
def PRE_first_tail_x15_r0_body.nr63 : List Nat := [2807, 2806, 2782, 2790, 2795, 2800, 2805, 2779, 2780, 2781, 2788, 2789, 2777, 2784, 2785, 2786, 2787, 2783]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd63 : RData :=
  ⟨2724809, 2725958, Stage.setAll PTrie.nil [(2724803, 2725915), (2724804, 2725090), (2724805, 2725921), (2724806, 2725917), (2724807, 2725092), (2724808, 2725923)], Stage.setAll PTrie.nil [(19453, 19479), (19454, 19457), (19455, 19480)],
   19456, 19481, 16553, 16553, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(2777, .ref 2807), (2778, .ref 2806), (2779, .ref 2782), (2780, .ref 2790), (2781, .ref 2795), (2782, .ref 2800), (2783, .ref 2805), (2784, .ref 2779), (2785, .ref 2780), (2786, .ref 2781), (2787, .ref 2788), (2788, .ref 2789), (2789, .ref 2777), (2790, .ref 2784), (2791, .ref 2785), (2792, .ref 2786), (2793, .ref 2787), (2794, .ref 2783)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa63 : Map :=
  Conv.Map.compact 2724803 2725958 2777 PRE_first_tail_x15_r0_body.pl63 (PRE_first_tail_x15_r0_body.nr63.map NumV.ref) PRE_first_tail_x15_r0_body.kd63.big
    PRE_first_tail_x15_r0_body.kd63.region PRE_first_tail_x15_r0_body.kd63.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws63 : List Nat := [2092, 2093, 2094, 2095, 2096, 2097, 2098, 2099, 2100, 2101, 2102, 2103, 2104, 2105, 2106, 2107, 2108, 2109]
noncomputable def PRE_first_tail_x15_r0_body.crs63 : List SymE := PRE_first_tail_x15_r0_body.nr63.map fun r => (nth? PRE_first_tail_x15_r0_body.S621.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta63 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws63 PRE_first_tail_x15_r0_body.crs63
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB63 : List Nat := [2665, 2672460, 2673467, 2723977, 2724522, 2724778]

kernel_rfl PRE_first_tail_x15_r0_body.ctab63 : PRE_first_tail_x15_r0_body.S622.tab = PRE_first_tail_x15_r0_body.S620.tab ++ PRE_first_tail_x15_r0_body.cws63.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace63 : PRE_first_tail_x15_r0_body.s622.trace = PRE_first_tail_x15_r0_body.s620.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext63 : PRE_first_tail_x15_r0_body.s622.next = 2724809
kernel_rfl PRE_first_tail_x15_r0_body.ccounters63 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s622.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s622.ffi).mlx.nnext) = (19456, 16553)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue63 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s621.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s622.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa63.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp63 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s622.ffi).mlx.tokens.all (bSN 2795) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean63 : Conv.cleanListB 19456 131072 (fun r => Nat.ble 77824 r) PRE_first_tail_x15_r0_body.s622
    (PRE_first_tail_x15_r0_body.wrB63 ++ (List.range 6).map (2724803 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs63 : bigsOutB 19456 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s622.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK63
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl63`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl63 : List Nat := [2665, 2672460, 2673467, 2723977, 2724522, 2724778, 2724803, 2724804, 2724805, 2724806, 2724807, 2724808]
def PRE_first_tail_x15_r0_body.clo63 : List Nat := [19433, 19446, 19452, 19453, 19454, 19455]
def PRE_first_tail_x15_r0_body.cln63 : List Nat := [16526, 16527, 16528, 16529, 16530, 16531, 16532, 16533, 16534, 16535, 16536, 16537, 16538, 16539, 16540, 16541, 16542, 16543, 16544, 16545, 16546, 16547, 16548, 16549, 16550, 16551, 16552]
def PRE_first_tail_x15_r0_body.cli63 : List Nat := [16526, 16527, 16528, 16529, 16530, 16531, 16532, 16533, 16534, 16535, 16536, 16537, 16538, 16539, 16540, 16541, 16542, 16543, 16544, 16545, 16546, 16547, 16548, 16549, 16550, 16551, 16552]
kernel_rfl PRE_first_tail_x15_r0_body.cheap63 : PRE_first_tail_x15_r0_body.s622.heap = Stage.setAll PRE_first_tail_x15_r0_body.s620.heap (PRE_first_tail_x15_r0_body.cl63.filterMap fun a => (PRE_first_tail_x15_r0_body.s622.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe63 : Nat.ble PRE_first_tail_x15_r0_body.s620.next PRE_first_tail_x15_r0_body.s622.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP63 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s620 PRE_first_tail_x15_r0_body.s622 PRE_first_tail_x15_r0_body.cl63 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp63 : Conv.suppListB PRE_first_tail_x15_r0_body.s622 2795 PRE_first_tail_x15_r0_body.cl63 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound63 : Conv.boundListB PRE_first_tail_x15_r0_body.s622 PRE_first_tail_x15_r0_body.cl63 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK63 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s622.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln63.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s622.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK63 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s622.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo63.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s622.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK63 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s622.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli63.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s622.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst63 : Conv.sstListB 2795 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s622.ffi).mlx PRE_first_tail_x15_r0_body.cln63 PRE_first_tail_x15_r0_body.clo63 PRE_first_tail_x15_r0_body.cli63 = true

end Host.Load.Run.Tpl
end

section -- SiteCl63
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA63 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s622.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo63.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s622.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd63 : (PRE_first_tail_x15_r0_body.clo63 ++ PRE_first_tail_x15_r0_body.cln63 ++ PRE_first_tail_x15_r0_body.cli63).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle63 : Conv.Cnt.leB (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt) (⟨19456, 16553, 2724809, 2795⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck63 : Conv.ncleanListB (⟨19456, 16553, 2724809, 2795⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s622.ffi).mlx PRE_first_tail_x15_r0_body.clo63 PRE_first_tail_x15_r0_body.cln63 PRE_first_tail_x15_r0_body.cli63 = true
theorem PRE_first_tail_x15_r0_body.cncl63 (h : Conv.NClean (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx) : Conv.NClean (⟨19456, 16553, 2724809, 2795⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s622.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle63 PRE_first_tail_x15_r0_body.ckA63 PRE_first_tail_x15_r0_body.cobjsK63 PRE_first_tail_x15_r0_body.cnodesK63 PRE_first_tail_x15_r0_body.citemsK63 PRE_first_tail_x15_r0_body.cbd63 PRE_first_tail_x15_r0_body.cck63

end Host.Load.Run.Tpl
end

section -- SiteS63
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 63 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc63 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P63 : LoadP := PRE_first_tail_x15_r0_body.Pc63.raise 16553
kernel_rfl PRE_first_tail_x15_r0_body.craise63 : Nat.ble PRE_first_tail_x15_r0_body.Pc63.N0 16553 = true
theorem PRE_first_tail_x15_r0_body.raised63 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc63 PRE_first_tail_x15_r0_body.P63 :=
  .inr ⟨16553, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise63, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_63 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s622.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_63 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s621.ffi)
def PRE_first_tail_x15_r0_body.khinv63 : PTrie Nat := Stage.setAll PTrie.nil [(19479, 19453), (19457, 19454), (19480, 19455)]
def PRE_first_tail_x15_r0_body.kninv63 : PTrie Nat := Stage.setAll PTrie.nil [(16526, 16526), (16527, 16527), (16528, 16528), (16529, 16529), (16530, 16530), (16531, 16531), (16532, 16532), (16533, 16533), (16534, 16534), (16535, 16535), (16536, 16536), (16537, 16537), (16538, 16538), (16539, 16539), (16540, 16540), (16541, 16541), (16542, 16542), (16543, 16543), (16544, 16544), (16545, 16545), (16546, 16546), (16547, 16547), (16548, 16548), (16549, 16549), (16550, 16550), (16551, 16551), (16552, 16552)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS63 : List Nat := [19433, 19446, 19452, 19453, 19454, 19455, 19456, 19457, 19458, 19459, 19460, 19461, 19462, 19463, 19464, 19465, 19466, 19467, 19468, 19469, 19470, 19471, 19472, 19473, 19474, 19475, 19476, 19477, 19478, 19479, 19480]
def PRE_first_tail_x15_r0_body.cnS63 : List Nat := List.range' 16526 27
def PRE_first_tail_x15_r0_body.ciS63 : List Nat := [] ++ List.range' 16526 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh063 : PRE_first_tail_x15_r0_body.kd63.nh0 = PRE_first_tail_x15_r0_body.cx0_63.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh163 : PRE_first_tail_x15_r0_body.kd63.nh1 = PRE_first_tail_x15_r0_body.cx1_63.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn063 : PRE_first_tail_x15_r0_body.kd63.nn0 = PRE_first_tail_x15_r0_body.cx0_63.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn163 : PRE_first_tail_x15_r0_body.kd63.nn1 = PRE_first_tail_x15_r0_body.cx1_63.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo63 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P63.lo && Nat.ble PRE_first_tail_x15_r0_body.P63.lo PRE_first_tail_x15_r0_body.cx0_63.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P63.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P63.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt63 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_63.mlx.next PRE_first_tail_x15_r0_body.cx1_63.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_63.mlx.nnext PRE_first_tail_x15_r0_body.cx1_63.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband63 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P63.NL && Nat.ble PRE_first_tail_x15_r0_body.P63.NL PRE_first_tail_x15_r0_body.P63.N0 && Nat.ble PRE_first_tail_x15_r0_body.P63.N0 PRE_first_tail_x15_r0_body.cx0_63.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow63 : PRE_first_tail_x15_r0_body.kd63.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren63 : checkRenG PRE_first_tail_x15_r0_body.kd63.hnd PRE_first_tail_x15_r0_body.khinv63 (phB PRE_first_tail_x15_r0_body.cx0_63.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband63 : PRE_first_tail_x15_r0_body.kd63.checkBand PRE_first_tail_x15_r0_body.P63.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos63 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd63.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren63 : checkRenG PRE_first_tail_x15_r0_body.kd63.node PRE_first_tail_x15_r0_body.kninv63 (pnB PRE_first_tail_x15_r0_body.cx0_63.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow63 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd63.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P63.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd63.nodeF j) PRE_first_tail_x15_r0_body.cx1_63.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a63 : PRE_first_tail_x15_r0_body.cx0_63.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b63 : PRE_first_tail_x15_r0_body.cx0_63.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok163 : PRE_first_tail_x15_r0_body.cx1_63.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend63 : PRE_first_tail_x15_r0_body.cx1_63.mlx.pending = PRE_first_tail_x15_r0_body.cx0_63.mlx.pending.map PRE_first_tail_x15_r0_body.kappa63.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh63 : PRE_first_tail_x15_r0_body.cx1_63.mlx.errh = PRE_first_tail_x15_r0_body.cx0_63.mlx.errh.map PRE_first_tail_x15_r0_body.kappa63.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles63 : PRE_first_tail_x15_r0_body.cx1_63.mlx.files = PRE_first_tail_x15_r0_body.cx0_63.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch63 : PRE_first_tail_x15_r0_body.cx1_63.mlx.arch = PRE_first_tail_x15_r0_body.cx0_63.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes63 : PRE_first_tail_x15_r0_body.cx1_63.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_63.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired63 : PRE_first_tail_x15_r0_body.cx1_63.mlx.wired = PRE_first_tail_x15_r0_body.cx0_63.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost63 : PRE_first_tail_x15_r0_body.cx1_63.host = PRE_first_tail_x15_r0_body.cx0_63.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd63`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn063 : PRE_first_tail_x15_r0_body.kd63.n0 = 2724809
kernel_rfl PRE_first_tail_x15_r0_body.ckn163 : PRE_first_tail_x15_r0_body.kd63.n1 = 2725958
kernel_rfl PRE_first_tail_x15_r0_body.ckheap63 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd63.heap).all (fun x => Nat.ble 2724803 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl63 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd63.heap.get (2724803 + j) = nth? PRE_first_tail_x15_r0_body.pl63 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja63 : Nat.ble 2724803 2724803 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn63 : Nat.ble 2777 2777 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD63 : Nat.ble 2724803 PRE_first_tail_x15_r0_body.kd63.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn63 : Nat.ble 19453 PRE_first_tail_x15_r0_body.kd63.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn63 : Nat.ble 16526 PRE_first_tail_x15_r0_body.kd63.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb63 : Nat.ble 19453 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap63 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd63.heap).all (Nat.ble (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd63 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd63.hnd).all (Nat.ble (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode63 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd63.node).all (Nat.ble (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix63 : Conv.FixOld (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa63 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja63) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn63) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD63) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn63) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn63) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb63) PRE_first_tail_x15_r0_body.fheap63 PRE_first_tail_x15_r0_body.fhnd63 PRE_first_tail_x15_r0_body.fnode63
kernel_rfl PRE_first_tail_x15_r0_body.fcxn63 : (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn63 : (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle063 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_63.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_63.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk63 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd63.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A63 : PRE_first_tail_x15_r0_body.cx1_63.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS63.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_63.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O63 : PRE_first_tail_x15_r0_body.cx1_63.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS63.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_63.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N63 : PRE_first_tail_x15_r0_body.cx1_63.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS63.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_63.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I63 : PRE_first_tail_x15_r0_body.cx1_63.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS63.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_63.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd63 : (PRE_first_tail_x15_r0_body.clo63 ++ PRE_first_tail_x15_r0_body.cln63 ++ PRE_first_tail_x15_r0_body.cli63 ++ PRE_first_tail_x15_r0_body.cwS63 ++ PRE_first_tail_x15_r0_body.cnS63 ++ PRE_first_tail_x15_r0_body.ciS63).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW63 : PRE_first_tail_x15_r0_body.cwS63.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo63.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI63 : PRE_first_tail_x15_r0_body.ciS63.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli63.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN63 : PRE_first_tail_x15_r0_body.cnS63.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF63 : PRE_first_tail_x15_r0_body.cln63.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh63 : PRE_first_tail_x15_r0_body.clo63.all (handleOK PRE_first_tail_x15_r0_body.kappa63 PRE_first_tail_x15_r0_body.P63.lo PRE_first_tail_x15_r0_body.cx0_63.mlx PRE_first_tail_x15_r0_body.cx1_63.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo63 : PRE_first_tail_x15_r0_body.clo63.map (fun h => PRE_first_tail_x15_r0_body.cx1_63.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa63.handle h)) = PRE_first_tail_x15_r0_body.clo63.map (fun h => (PRE_first_tail_x15_r0_body.cx0_63.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa63.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok63 : PRE_first_tail_x15_r0_body.clo63.all (objOK PRE_first_tail_x15_r0_body.kappa63 PRE_first_tail_x15_r0_body.P63.NL PRE_first_tail_x15_r0_body.cx0_63.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd63 : PRE_first_tail_x15_r0_body.cln63.all (nodeOKF PRE_first_tail_x15_r0_body.kappa63 PRE_first_tail_x15_r0_body.P63 PRE_first_tail_x15_r0_body.cx0_63.mlx PRE_first_tail_x15_r0_body.cx1_63.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp63 : ((PRE_first_tail_x15_r0_body.cln63.filter (fullB PRE_first_tail_x15_r0_body.P63))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_63.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa63.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln63.filter (fullB PRE_first_tail_x15_r0_body.P63))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_63.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa63.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI63 : incrB PRE_first_tail_x15_r0_body.kd63.nodeF (List.range' 16526 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK63 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd63.node).all (fun k => Nat.ble 16526 k && Nat.blt k 16553) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL63 : (PRE_first_tail_x15_r0_body.cln63.filter (Nat.ble PRE_first_tail_x15_r0_body.P63.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd63.nodeF i) && (Nat.blt i 16553 || Nat.ble PRE_first_tail_x15_r0_body.kd63.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord63 : (PRE_first_tail_x15_r0_body.cln63.filter (Nat.ble PRE_first_tail_x15_r0_body.P63.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd63.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd63.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd63.nodeF j) (PRE_first_tail_x15_r0_body.kd63.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow63 PRE_first_tail_x15_r0_body.cnn163 PRE_first_tail_x15_r0_body.fnordI63 PRE_first_tail_x15_r0_body.fnordK63 PRE_first_tail_x15_r0_body.fnordL63
kernel_rfl PRE_first_tail_x15_r0_body.fi63 : PRE_first_tail_x15_r0_body.cli63.all (pnB PRE_first_tail_x15_r0_body.cx0_63.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii63 : PRE_first_tail_x15_r0_body.cli63.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_63.mlx.items.get (PRE_first_tail_x15_r0_body.kappa63.node k) = (PRE_first_tail_x15_r0_body.cx0_63.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa63.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot63 (clean : Conv.NClean (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P63.NL) (cl : SSt (· < 2795) PRE_first_tail_x15_r0_body.cx0_63.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P63 2795 PRE_first_tail_x15_r0_body.kappa63 PRE_first_tail_x15_r0_body.kd63 PRE_first_tail_x15_r0_body.khinv63 PRE_first_tail_x15_r0_body.kninv63 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx PRE_first_tail_x15_r0_body.cx0_63.mlx PRE_first_tail_x15_r0_body.cx1_63.mlx (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo63 PRE_first_tail_x15_r0_body.cln63 PRE_first_tail_x15_r0_body.cli63 PRE_first_tail_x15_r0_body.cwS63 PRE_first_tail_x15_r0_body.cnS63 PRE_first_tail_x15_r0_body.ciS63 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh063, PRE_first_tail_x15_r0_body.cnh163, PRE_first_tail_x15_r0_body.cnn063, PRE_first_tail_x15_r0_body.cnn163, PRE_first_tail_x15_r0_body.cplo63, PRE_first_tail_x15_r0_body.ccnt63, PRE_first_tail_x15_r0_body.cnband63, PRE_first_tail_x15_r0_body.chbelow63, PRE_first_tail_x15_r0_body.chren63, PRE_first_tail_x15_r0_body.cband63, PRE_first_tail_x15_r0_body.cnh1pos63, PRE_first_tail_x15_r0_body.cnren63, PRE_first_tail_x15_r0_body.cnlow63, PRE_first_tail_x15_r0_body.cabs0a63, PRE_first_tail_x15_r0_body.cabs0b63, PRE_first_tail_x15_r0_body.ctok163, PRE_first_tail_x15_r0_body.cpend63, PRE_first_tail_x15_r0_body.cerrh63, PRE_first_tail_x15_r0_body.cfiles63, PRE_first_tail_x15_r0_body.carch63, PRE_first_tail_x15_r0_body.csizes63, PRE_first_tail_x15_r0_body.cwired63, PRE_first_tail_x15_r0_body.cfix63, clean, PRE_first_tail_x15_r0_body.fcxn63, PRE_first_tail_x15_r0_body.fcnn63, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle063, PRE_first_tail_x15_r0_body.fnk63, PRE_first_tail_x15_r0_body.ckA63, PRE_first_tail_x15_r0_body.cobjsK63, PRE_first_tail_x15_r0_body.cnodesK63, PRE_first_tail_x15_r0_body.citemsK63, PRE_first_tail_x15_r0_body.f1A63, PRE_first_tail_x15_r0_body.f1O63, PRE_first_tail_x15_r0_body.f1N63, PRE_first_tail_x15_r0_body.f1I63, PRE_first_tail_x15_r0_body.fbd63, PRE_first_tail_x15_r0_body.fincW63, PRE_first_tail_x15_r0_body.fincI63, PRE_first_tail_x15_r0_body.fincN63, PRE_first_tail_x15_r0_body.flnF63, PRE_first_tail_x15_r0_body.fh63, PRE_first_tail_x15_r0_body.fo63, PRE_first_tail_x15_r0_body.fok63, PRE_first_tail_x15_r0_body.fnd63, PRE_first_tail_x15_r0_body.fp63, PRE_first_tail_x15_r0_body.fnord63, PRE_first_tail_x15_r0_body.fi63, PRE_first_tail_x15_r0_body.fii63⟩
theorem PRE_first_tail_x15_r0_body.cnshift63 (clean : Conv.NClean (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P63.NL) (cl : SSt (· < 2795) PRE_first_tail_x15_r0_body.cx0_63.mlx) : NShift PRE_first_tail_x15_r0_body.P63 2795 PRE_first_tail_x15_r0_body.kappa63 PRE_first_tail_x15_r0_body.cx0_63 PRE_first_tail_x15_r0_body.cx1_63 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot63 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost63 (compact_a_eq PRE_first_tail_x15_r0_body.ckn063 PRE_first_tail_x15_r0_body.ckn163 PRE_first_tail_x15_r0_body.ckheap63 PRE_first_tail_x15_r0_body.ckpl63)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_63 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s620.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_63 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s620.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_63 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s620.ffi) = some PRE_first_tail_x15_r0_body.fxC_63
kernel_rfl PRE_first_tail_x15_r0_body.okrC_63 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s620.ffi) = some PRE_first_tail_x15_r0_body.krC_63
noncomputable def PRE_first_tail_x15_r0_body.fx0_63 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s622.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_63 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s622.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_63 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s622.ffi) = some PRE_first_tail_x15_r0_body.fx0_63
kernel_rfl PRE_first_tail_x15_r0_body.okr0_63 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s622.ffi) = some PRE_first_tail_x15_r0_body.kr0_63
noncomputable def PRE_first_tail_x15_r0_body.fx1_63 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s621.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_63 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s621.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_63 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s621.ffi) = some PRE_first_tail_x15_r0_body.fx1_63
kernel_rfl PRE_first_tail_x15_r0_body.okr1_63 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s621.ffi) = some PRE_first_tail_x15_r0_body.kr1_63
kernel_rfl PRE_first_tail_x15_r0_body.ff063 : PRE_first_tail_x15_r0_body.fx0_63 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_63 (PRE_first_tail_x15_r0_body.clo63.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_63.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff163 : PRE_first_tail_x15_r0_body.fx1_63 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_63 (PRE_first_tail_x15_r0_body.cwS63.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_63.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck63 : freedLB PRE_first_tail_x15_r0_body.kappa63 PRE_first_tail_x15_r0_body.cx0_63.mlx PRE_first_tail_x15_r0_body.fx0_63 PRE_first_tail_x15_r0_body.fx1_63 PRE_first_tail_x15_r0_body.clo63 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf063 : PRE_first_tail_x15_r0_body.kr0_63.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_63.flags (PRE_first_tail_x15_r0_body.clo63.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_63.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt063 : PRE_first_tail_x15_r0_body.kr0_63.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_63.targs (PRE_first_tail_x15_r0_body.clo63.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_63.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf163 : PRE_first_tail_x15_r0_body.kr1_63.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_63.flags (PRE_first_tail_x15_r0_body.cwS63.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_63.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt163 : PRE_first_tail_x15_r0_body.kr1_63.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_63.targs (PRE_first_tail_x15_r0_body.cwS63.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_63.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck63 : krecLB PRE_first_tail_x15_r0_body.kappa63 2795 PRE_first_tail_x15_r0_body.cx0_63.mlx PRE_first_tail_x15_r0_body.kr0_63 PRE_first_tail_x15_r0_body.kr1_63 PRE_first_tail_x15_r0_body.clo63 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn63 : Nat.ble 2777 2795 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge63 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s621.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s622.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR63 : pendRegB PRE_first_tail_x15_r0_body.kappa63 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s622.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe63 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s622.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s621.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift63 (clean : Conv.NClean (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P63.NL) (cl : SSt (· < 2795) PRE_first_tail_x15_r0_body.cx0_63.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_63.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_63.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_63.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_63.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P63 2795 PRE_first_tail_x15_r0_body.kappa63 PRE_first_tail_x15_r0_body.s622.ffi PRE_first_tail_x15_r0_body.s621.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift63 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue63, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp63 t ht),
    PRE_first_tail_x15_r0_body.cbridge63,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s622.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s621.ffi) (PRE_first_tail_x15_r0_body.cfoot63 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_63 PRE_first_tail_x15_r0_body.ofx1_63 hobjC PRE_first_tail_x15_r0_body.ff063 PRE_first_tail_x15_r0_body.ff163 PRE_first_tail_x15_r0_body.ffck63,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s622.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s621.ffi) (PRE_first_tail_x15_r0_body.cfoot63 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_63 PRE_first_tail_x15_r0_body.okr1_63 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn63) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf063 PRE_first_tail_x15_r0_body.fkt063 PRE_first_tail_x15_r0_body.fkf163 PRE_first_tail_x15_r0_body.fkt163 PRE_first_tail_x15_r0_body.fkck63,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh063 PRE_first_tail_x15_r0_body.cnh163 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe63) PRE_first_tail_x15_r0_body.cpendR63⟩

end Host.Load.Run.Tpl
end

section -- st63/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st63 0
host_stream_state PRE_first_tail_x15_r0_body.st63 1
host_stream_state PRE_first_tail_x15_r0_body.st63 2
host_stream_state PRE_first_tail_x15_r0_body.st63 3
host_stream_state PRE_first_tail_x15_r0_body.st63 4
host_stream_state PRE_first_tail_x15_r0_body.st63 5
end Host.Load.Run.Tpl
end

section -- Site63
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 63 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g63__g64` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s620`, the merged state `PRE_first_tail_x15_r0_body.s621`,
the site template `PRE_first_tail_x15_r0_body.st63` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s622`: the merge.
The footprint's facts are in `SiteF63`, the compaction's in `SiteC63`, `SiteK63`, `SiteNa63`, `SiteNb63`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso63 : PRE_first_tail_x15_r0_body.st63.s0 = { PRE_first_tail_x15_r0_body.s620 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs63 : List Frame := PRE_first_tail_x15_r0_body.s620.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_63 : PRE_first_tail_x15_r0_body.S620.tab.length = 2777
kernel_rfl PRE_first_tail_x15_r0_body.tab0_63 : PRE_first_tail_x15_r0_body.st63.S0.tab = PRE_first_tail_x15_r0_body.S620.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws63 : List Nat := [2061, 2062, 2063, 2064, 2065, 2066, 2067, 2068, 2069, 2070, 2071, 2072, 2073, 2074, 2075, 2076, 2077, 2078, 2079, 2080, 2081, 2082, 2083, 2084, 2085, 2086, 2087, 2088, 2089, 2090, 2091]
kernel_rfl PRE_first_tail_x15_r0_body.fresh63 : (PRE_first_tail_x15_r0_body.S620.tab.all fun e => PRE_first_tail_x15_r0_body.ws63.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S620.oracle.all fun q => PRE_first_tail_x15_r0_body.ws63.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab63 : PRE_first_tail_x15_r0_body.S621.tab = PRE_first_tail_x15_r0_body.S620.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws63
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen63 : PRE_first_tail_x15_r0_body.st63.S5.tab.length - PRE_first_tail_x15_r0_body.st63.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged63`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap63 : PRE_first_tail_x15_r0_body.s621.heap = PRE_first_tail_x15_r0_body.st63.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext63 : PRE_first_tail_x15_r0_body.s621.next = PRE_first_tail_x15_r0_body.st63.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl63 : PRE_first_tail_x15_r0_body.s621.ctl = PRE_first_tail_x15_r0_body.st63.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack63 : PRE_first_tail_x15_r0_body.s621.stack = PRE_first_tail_x15_r0_body.st63.s5.stack ++ PRE_first_tail_x15_r0_body.s620.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs63 : PRE_first_tail_x15_r0_body.s621.jobs = PRE_first_tail_x15_r0_body.st63.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi63 : PRE_first_tail_x15_r0_body.s621.ffi = PRE_first_tail_x15_r0_body.st63.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace63 : PRE_first_tail_x15_r0_body.s621.trace = PRE_first_tail_x15_r0_body.st63.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores63 : PRE_first_tail_x15_r0_body.s621.stores = PRE_first_tail_x15_r0_body.st63.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD63
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 63 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived63 : PRE_first_tail_x15_r0_body.nr63.map (fun r => nth? PRE_first_tail_x15_r0_body.st63.S5.tab r) =
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
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo63 : PRE_first_tail_x15_r0_body.nr63.all (Nat.ble 2777) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj63 : PRE_first_tail_x15_r0_body.cws63.all (fun c => !PRE_first_tail_x15_r0_body.ws63.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ63 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws63 PRE_first_tail_x15_r0_body.crs63 PRE_first_tail_x15_r0_body.ws63

end Host.Load.Run.Tpl
end

section -- st63/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st63`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st63.wrR : List (Nat × Nat) := [(2672460, 2672461), (2723977, 2723978), (2724522, 2724523), (2724778, 2724779)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st63.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st63.s5.heap PRE_first_tail_x15_r0_body.st63.wrR ++ freshOf PRE_first_tail_x15_r0_body.st63.s5.heap PRE_first_tail_x15_r0_body.st63.s0.next PRE_first_tail_x15_r0_body.st63.s5.next
noncomputable def PRE_first_tail_x15_r0_body.st63.wr : List Nat := PRE_first_tail_x15_r0_body.st63.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st63.heapFoot : PRE_first_tail_x15_r0_body.st63.s5.heap = setAll PRE_first_tail_x15_r0_body.st63.s0.heap PRE_first_tail_x15_r0_body.st63.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st63.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st63.s0.next PRE_first_tail_x15_r0_body.st63.s5.next = true
theorem PRE_first_tail_x15_r0_body.st63.grows : PRE_first_tail_x15_r0_body.st63.s0.next ≤ PRE_first_tail_x15_r0_body.st63.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st63.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st63.wh : List Nat := [19433, 19446, 19452, 19453, 19454, 19455, 19456, 19457, 19458, 19459, 19460, 19461, 19462, 19463, 19464, 19465, 19466, 19467, 19468, 19469, 19470, 19471, 19472, 19473, 19474, 19475, 19476, 19477, 19478, 19479, 19480]
def PRE_first_tail_x15_r0_body.st63.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st63.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st63.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st63.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st63.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st63.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st63.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st63.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st63.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st63.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st63.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st63.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st63.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st63.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st63.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st63.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st63.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st63.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st63.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st63.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st63.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st63.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st63.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st63.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st63.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st63.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st63.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st63.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st63.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st63.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF63
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 63 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB63 : nodupT PRE_first_tail_x15_r0_body.st63.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup63 : PRE_first_tail_x15_r0_body.st63.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB63).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB63 : PRE_first_tail_x15_r0_body.st63.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound63 : ∀ b ∈ PRE_first_tail_x15_r0_body.st63.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB63 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr63 := PRE_first_tail_x15_r0_body.st63.s5.trace.take 120
kernel_rfl PRE_first_tail_x15_r0_body.traceEq63 : PRE_first_tail_x15_r0_body.st63.s5.trace = PRE_first_tail_x15_r0_body.trFr63 ++ PRE_first_tail_x15_r0_body.st63.s0.trace
theorem PRE_first_tail_x15_r0_body.trace63 : ∃ fr, PRE_first_tail_x15_r0_body.st63.s5.trace = fr ++ PRE_first_tail_x15_r0_body.st63.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq63⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide63 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB63 : (PRE_first_tail_x15_r0_body.wide63.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st63.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix63 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide63, WFix Map.id (Present PRE_first_tail_x15_r0_body.st63.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB63 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL63
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 63 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s621`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO63 : PRE_first_tail_x15_r0_body.st63.S0.oracle = PRE_first_tail_x15_r0_body.st63.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B63 : PRE_first_tail_x15_r0_body.st63.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st63.s0.next || (PRE_first_tail_x15_r0_body.st63.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot63 : Conv.StageFoot PRE_first_tail_x15_r0_body.st63.wr PRE_first_tail_x15_r0_body.st63.s0 PRE_first_tail_x15_r0_body.st63.s5 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st63.heapFoot PRE_first_tail_x15_r0_body.wrNodup63 PRE_first_tail_x15_r0_body.wrBound63 PRE_first_tail_x15_r0_body.wr0B63 PRE_first_tail_x15_r0_body.st63.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged63 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st63.F.S → PRE_first_tail_x15_r0_body.st63.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st63.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st63.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs63 PRE_first_tail_x15_r0_body.st63.wr PRE_first_tail_x15_r0_body.s620 PRE_first_tail_x15_r0_body.st63.s5 PRE_first_tail_x15_r0_body.st63.s0
      PRE_first_tail_x15_r0_body.st63.s5.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st63.F FR W stk M ν K PRE_first_tail_x15_r0_body.s621 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso63 PRE_first_tail_x15_r0_body.stFoot63 PRE_first_tail_x15_r0_body.wrNodup63 PRE_first_tail_x15_r0_body.wrBound63 PRE_first_tail_x15_r0_body.trace63 PRE_first_tail_x15_r0_body.mheap63
    PRE_first_tail_x15_r0_body.mnext63 PRE_first_tail_x15_r0_body.mctl63 PRE_first_tail_x15_r0_body.mstack63 PRE_first_tail_x15_r0_body.mjobs63 PRE_first_tail_x15_r0_body.mffi63 PRE_first_tail_x15_r0_body.mtrace63 PRE_first_tail_x15_r0_body.mstores63 h

def PRE_first_tail_x15_r0_body.arrEl63_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE63_2665 : arrOf PRE_first_tail_x15_r0_body.s621 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl63_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA63_2665 : isArrB PRE_first_tail_x15_r0_body.s621 2665 = true
theorem PRE_first_tail_x15_r0_body.arr63_2665 : ∃ o, PRE_first_tail_x15_r0_body.s621.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl63_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE63_2665 PRE_first_tail_x15_r0_body.arrA63_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN63_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl63_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR63_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl63_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN63_2665

def PRE_first_tail_x15_r0_body.arrEl63_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE63_2673467 : arrOf PRE_first_tail_x15_r0_body.s621 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl63_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA63_2673467 : isArrB PRE_first_tail_x15_r0_body.s621 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr63_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s621.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl63_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE63_2673467 PRE_first_tail_x15_r0_body.arrA63_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN63_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl63_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR63_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl63_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN63_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k63 : isArrB PRE_first_tail_x15_r0_body.s621 4910 = false
theorem PRE_first_tail_x15_r0_body.keep63 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s621 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k63 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr63_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl63_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ63
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 63 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s620`, the merged
state `PRE_first_tail_x15_r0_body.s621`, the canonical state `PRE_first_tail_x15_r0_body.s622`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl63 : PRE_first_tail_x15_r0_body.pl63.all (Nat.ble PRE_first_tail_x15_r0_body.s620.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd63 : nodupT PRE_first_tail_x15_r0_body.pl63 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn163 : Nat.ble PRE_first_tail_x15_r0_body.s620.next 2725958 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst63 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s620.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn63 : PRE_first_tail_x15_r0_body.s622.next = PRE_first_tail_x15_r0_body.s620.next + PRE_first_tail_x15_r0_body.pl63.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn63 : PRE_first_tail_x15_r0_body.s621.next = 2725958
kernel_rfl PRE_first_tail_x15_r0_body.zgrow63 : Nat.ble PRE_first_tail_x15_r0_body.s622.next PRE_first_tail_x15_r0_body.s621.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh63 : PRE_first_tail_x15_r0_body.S620.tab.all (fun e => PRE_first_tail_x15_r0_body.cws63.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd63 : nodupT PRE_first_tail_x15_r0_body.cws63 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi63 : PRE_first_tail_x15_r0_body.nr63.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S621.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt63 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s620.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg63_2665 : PRE_first_tail_x15_r0_body.s622.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s622 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk63_2665 : (objOf PRE_first_tail_x15_r0_body.s622 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm63_2665 : PRE_first_tail_x15_r0_body.s621.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa63.obj (objOf PRE_first_tail_x15_r0_body.s622 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s621 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg63_2673467 : PRE_first_tail_x15_r0_body.s622.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s622 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk63_2673467 : (objOf PRE_first_tail_x15_r0_body.s622 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm63_2673467 : PRE_first_tail_x15_r0_body.s621.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa63.obj (objOf PRE_first_tail_x15_r0_body.s622 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s621 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw63_4910 : (PRE_first_tail_x15_r0_body.s622.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw63_2673472 : (PRE_first_tail_x15_r0_body.s622.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw63_2673473 : (PRE_first_tail_x15_r0_body.s622.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd63 : PRE_first_tail_x15_r0_body.cl63.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr63 : PRE_first_tail_x15_r0_body.st63.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s620.next || PRE_first_tail_x15_r0_body.cl63.contains b) = true
def PRE_first_tail_x15_r0_body.zl63 : List Nat := PRE_first_tail_x15_r0_body.cl63.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE63 : PRE_first_tail_x15_r0_body.zl63.map (fun a => PRE_first_tail_x15_r0_body.s621.heap.get (PRE_first_tail_x15_r0_body.kappa63.a a)) = PRE_first_tail_x15_r0_body.zl63.map (fun a => (PRE_first_tail_x15_r0_body.s622.heap.get a).map PRE_first_tail_x15_r0_body.kappa63.hobj)
theorem PRE_first_tail_x15_r0_body.zimg63 : HeapImg PRE_first_tail_x15_r0_body.kappa63 PRE_first_tail_x15_r0_body.s622 PRE_first_tail_x15_r0_body.s621 PRE_first_tail_x15_r0_body.zl63 := PRE_first_tail_x15_r0_body.zimgE63
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl63 : PRE_first_tail_x15_r0_body.s621.ctl = PRE_first_tail_x15_r0_body.kappa63.ctl PRE_first_tail_x15_r0_body.s622.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack63 : PRE_first_tail_x15_r0_body.s621.stack = PRE_first_tail_x15_r0_body.s622.stack.map PRE_first_tail_x15_r0_body.kappa63.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs63 : PRE_first_tail_x15_r0_body.s621.jobs = PRE_first_tail_x15_r0_body.s622.jobs.map PRE_first_tail_x15_r0_body.kappa63.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores63 : PRE_first_tail_x15_r0_body.s621.stores = PRE_first_tail_x15_r0_body.kappa63.stores PRE_first_tail_x15_r0_body.s622.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots63 : checkRootsSupp PRE_first_tail_x15_r0_body.s622 2795 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC63 : PRE_first_tail_x15_r0_body.S620.tab.length + PRE_first_tail_x15_r0_body.cws63.length = 2795
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap63 : PRE_first_tail_x15_r0_body.kappa63 = Conv.Map.compact PRE_first_tail_x15_r0_body.s620.next 2725958 PRE_first_tail_x15_r0_body.S620.tab.length PRE_first_tail_x15_r0_body.pl63 (PRE_first_tail_x15_r0_body.nr63.map NumV.ref) PRE_first_tail_x15_r0_body.kd63.big
  PRE_first_tail_x15_r0_body.kd63.region PRE_first_tail_x15_r0_body.kd63.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin63 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s622.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc63 : Conv.jcleanListB (⟨19456, 16553, 2724809, 2795⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s622 PRE_first_tail_x15_r0_body.cl63 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB63 : noBigRootsP (fun i => !Conv.oldBigB (⟨19456, 16553, 2724809, 2795⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s622.trace PRE_first_tail_x15_r0_body.s622 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm63 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16526 = true
theorem PRE_first_tail_x15_r0_body.cjcl63 (h : Conv.JClean (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s620) : Conv.JClean (⟨19456, 16553, 2724809, 2795⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s622 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle63)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap63 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd63 a ha)) PRE_first_tail_x15_r0_body.zjc63

end Host.Load.Run.Tpl
end

section -- st63/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st63.bodyLast from PRE_first_tail_x15_r0_body.st63.s4 to PRE_first_tail_x15_r0_body.st63.s5 :
  interpS (step PRE_first_tail_x15_r0_body.st63.F PRE_first_tail_x15_r0_body.st63.s4).run PRE_first_tail_x15_r0_body.st63.S4 = some (PRE_first_tail_x15_r0_body.st63.s5, PRE_first_tail_x15_r0_body.st63.S5)
kernel_rfl PRE_first_tail_x15_r0_body.st63.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st63.s4.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st63.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st63.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st63/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st63.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st63.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st63.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st63.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st63.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st63.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st63.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st63.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st63.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st63.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st63.s0 PRE_first_tail_x15_r0_body.st63.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st63.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st63.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st63.s4 PRE_first_tail_x15_r0_body.st63.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st63/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st63.bodyK0F from PRE_first_tail_x15_r0_body.st63.s0 to PRE_first_tail_x15_r0_body.st63.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st63.F (PRE_first_tail_x15_r0_body.st63.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st63.ks 0).getD 0) PRE_first_tail_x15_r0_body.st63.s0 PRE_first_tail_x15_r0_body.st63.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st63.s1, PRE_first_tail_x15_r0_body.st63.S1)
theorem PRE_first_tail_x15_r0_body.st63.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st63.F (PRE_first_tail_x15_r0_body.st63.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st63.ks 0).getD 0) PRE_first_tail_x15_r0_body.st63.s0 PRE_first_tail_x15_r0_body.st63.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st63.s1, PRE_first_tail_x15_r0_body.st63.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st63.bodyOkLN_ok PRE_first_tail_x15_r0_body.st63.bodyK0F
end Host.Load.Run.Tpl
end

section -- st63/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st63.bodyK1F from PRE_first_tail_x15_r0_body.st63.s1 to PRE_first_tail_x15_r0_body.st63.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st63.F (PRE_first_tail_x15_r0_body.st63.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st63.ks 1).getD 0) PRE_first_tail_x15_r0_body.st63.s1 PRE_first_tail_x15_r0_body.st63.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st63.s2, PRE_first_tail_x15_r0_body.st63.S2)
theorem PRE_first_tail_x15_r0_body.st63.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st63.F (PRE_first_tail_x15_r0_body.st63.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st63.ks 1).getD 0) PRE_first_tail_x15_r0_body.st63.s1 PRE_first_tail_x15_r0_body.st63.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st63.s2, PRE_first_tail_x15_r0_body.st63.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st63.bodyOkLN_ok PRE_first_tail_x15_r0_body.st63.bodyK1F
end Host.Load.Run.Tpl
end

section -- st63/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st63.bodyK2F from PRE_first_tail_x15_r0_body.st63.s2 to PRE_first_tail_x15_r0_body.st63.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st63.F (PRE_first_tail_x15_r0_body.st63.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st63.ks 2).getD 0) PRE_first_tail_x15_r0_body.st63.s2 PRE_first_tail_x15_r0_body.st63.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st63.s3, PRE_first_tail_x15_r0_body.st63.S3)
theorem PRE_first_tail_x15_r0_body.st63.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st63.F (PRE_first_tail_x15_r0_body.st63.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st63.ks 2).getD 0) PRE_first_tail_x15_r0_body.st63.s2 PRE_first_tail_x15_r0_body.st63.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st63.s3, PRE_first_tail_x15_r0_body.st63.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st63.bodyOkLN_ok PRE_first_tail_x15_r0_body.st63.bodyK2F
end Host.Load.Run.Tpl
end

section -- st63/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st63.bodyK3F from PRE_first_tail_x15_r0_body.st63.s3 to PRE_first_tail_x15_r0_body.st63.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st63.F (PRE_first_tail_x15_r0_body.st63.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st63.ks 3).getD 0) PRE_first_tail_x15_r0_body.st63.s3 PRE_first_tail_x15_r0_body.st63.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st63.s4, PRE_first_tail_x15_r0_body.st63.S4)
theorem PRE_first_tail_x15_r0_body.st63.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st63.F (PRE_first_tail_x15_r0_body.st63.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st63.ks 3).getD 0) PRE_first_tail_x15_r0_body.st63.s3 PRE_first_tail_x15_r0_body.st63.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st63.s4, PRE_first_tail_x15_r0_body.st63.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st63.bodyOkLN_ok PRE_first_tail_x15_r0_body.st63.bodyK3F
end Host.Load.Run.Tpl
end

section -- st63/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st63.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st63.F (PRE_first_tail_x15_r0_body.st63.bodyOkL bytes rows) 11334 PRE_first_tail_x15_r0_body.st63.s0 PRE_first_tail_x15_r0_body.st63.S0 = some (PRE_first_tail_x15_r0_body.st63.s4, PRE_first_tail_x15_r0_body.st63.S4) :=
  runOk_trans PRE_first_tail_x15_r0_body.st63.F (PRE_first_tail_x15_r0_body.st63.bodyOkL bytes rows) ((((nth? PRE_first_tail_x15_r0_body.st63.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st63.ks 1).getD 0)) + ((nth? PRE_first_tail_x15_r0_body.st63.ks 2).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st63.ks 3).getD 0) PRE_first_tail_x15_r0_body.st63.s0 PRE_first_tail_x15_r0_body.st63.s3 PRE_first_tail_x15_r0_body.st63.s4 PRE_first_tail_x15_r0_body.st63.S0 PRE_first_tail_x15_r0_body.st63.S3 PRE_first_tail_x15_r0_body.st63.S4 (runOk_trans PRE_first_tail_x15_r0_body.st63.F (PRE_first_tail_x15_r0_body.st63.bodyOkL bytes rows) (((nth? PRE_first_tail_x15_r0_body.st63.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st63.ks 1).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st63.ks 2).getD 0) PRE_first_tail_x15_r0_body.st63.s0 PRE_first_tail_x15_r0_body.st63.s2 PRE_first_tail_x15_r0_body.st63.s3 PRE_first_tail_x15_r0_body.st63.S0 PRE_first_tail_x15_r0_body.st63.S2 PRE_first_tail_x15_r0_body.st63.S3 (runOk_trans PRE_first_tail_x15_r0_body.st63.F (PRE_first_tail_x15_r0_body.st63.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st63.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st63.ks 1).getD 0) PRE_first_tail_x15_r0_body.st63.s0 PRE_first_tail_x15_r0_body.st63.s1 PRE_first_tail_x15_r0_body.st63.s2 PRE_first_tail_x15_r0_body.st63.S0 PRE_first_tail_x15_r0_body.st63.S1 PRE_first_tail_x15_r0_body.st63.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st63.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st63.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st63.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st63.bodyK3 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st63.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st63.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st63.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st63.F (PRE_first_tail_x15_r0_body.st63.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st63.s0
  S0 := PRE_first_tail_x15_r0_body.st63.S0
  s1 := PRE_first_tail_x15_r0_body.st63.s4
  S1 := PRE_first_tail_x15_r0_body.st63.S4
  s2 := PRE_first_tail_x15_r0_body.st63.s5
  S2 := PRE_first_tail_x15_r0_body.st63.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st63.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st63.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st63.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st63.bodyHalt
  last := PRE_first_tail_x15_r0_body.st63.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st63.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC64
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 64 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s630` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa64` into the merged state
`PRE_first_tail_x15_r0_body.s629`. -/

def PRE_first_tail_x15_r0_body.pl64 : List Nat := []
def PRE_first_tail_x15_r0_body.nr64 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd64 : RData :=
  ⟨2725299, 2725301, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19469, 19469, 16566, 16566, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa64 : Map :=
  Conv.Map.compact 2725299 2725301 2816 PRE_first_tail_x15_r0_body.pl64 (PRE_first_tail_x15_r0_body.nr64.map NumV.ref) PRE_first_tail_x15_r0_body.kd64.big
    PRE_first_tail_x15_r0_body.kd64.region PRE_first_tail_x15_r0_body.kd64.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws64 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs64 : List SymE := PRE_first_tail_x15_r0_body.nr64.map fun r => (nth? PRE_first_tail_x15_r0_body.S629.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta64 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws64 PRE_first_tail_x15_r0_body.crs64
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB64 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab64 : PRE_first_tail_x15_r0_body.S630.tab = PRE_first_tail_x15_r0_body.S628.tab ++ PRE_first_tail_x15_r0_body.cws64.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace64 : PRE_first_tail_x15_r0_body.s630.trace = PRE_first_tail_x15_r0_body.s628.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext64 : PRE_first_tail_x15_r0_body.s630.next = 2725299
kernel_rfl PRE_first_tail_x15_r0_body.ccounters64 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx.nnext) = (19469, 16566)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue64 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s629.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa64.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp64 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx.tokens.all (bSN 2816) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean64 : Conv.cleanListB 19469 131072 (fun r => Nat.ble 77876 r) PRE_first_tail_x15_r0_body.s630
    (PRE_first_tail_x15_r0_body.wrB64 ++ (List.range 0).map (2725299 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs64 : bigsOutB 19469 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK64
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl64`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl64 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo64 : List Nat := []
def PRE_first_tail_x15_r0_body.cln64 : List Nat := []
def PRE_first_tail_x15_r0_body.cli64 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap64 : PRE_first_tail_x15_r0_body.s630.heap = Stage.setAll PRE_first_tail_x15_r0_body.s628.heap (PRE_first_tail_x15_r0_body.cl64.filterMap fun a => (PRE_first_tail_x15_r0_body.s630.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe64 : Nat.ble PRE_first_tail_x15_r0_body.s628.next PRE_first_tail_x15_r0_body.s630.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP64 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s628 PRE_first_tail_x15_r0_body.s630 PRE_first_tail_x15_r0_body.cl64 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp64 : Conv.suppListB PRE_first_tail_x15_r0_body.s630 2816 PRE_first_tail_x15_r0_body.cl64 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound64 : Conv.boundListB PRE_first_tail_x15_r0_body.s630 PRE_first_tail_x15_r0_body.cl64 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK64 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln64.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK64 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo64.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK64 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli64.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst64 : Conv.sstListB 2816 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx PRE_first_tail_x15_r0_body.cln64 PRE_first_tail_x15_r0_body.clo64 PRE_first_tail_x15_r0_body.cli64 = true

end Host.Load.Run.Tpl
end

section -- SiteCl64
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA64 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo64.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd64 : (PRE_first_tail_x15_r0_body.clo64 ++ PRE_first_tail_x15_r0_body.cln64 ++ PRE_first_tail_x15_r0_body.cli64).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle64 : Conv.Cnt.leB (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt) (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck64 : Conv.ncleanListB (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx PRE_first_tail_x15_r0_body.clo64 PRE_first_tail_x15_r0_body.cln64 PRE_first_tail_x15_r0_body.cli64 = true
theorem PRE_first_tail_x15_r0_body.cncl64 (h : Conv.NClean (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx) : Conv.NClean (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle64 PRE_first_tail_x15_r0_body.ckA64 PRE_first_tail_x15_r0_body.cobjsK64 PRE_first_tail_x15_r0_body.cnodesK64 PRE_first_tail_x15_r0_body.citemsK64 PRE_first_tail_x15_r0_body.cbd64 PRE_first_tail_x15_r0_body.cck64

end Host.Load.Run.Tpl
end

section -- SiteS64
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 64 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc64 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P64 : LoadP := PRE_first_tail_x15_r0_body.Pc64.raise 16566
kernel_rfl PRE_first_tail_x15_r0_body.craise64 : Nat.ble PRE_first_tail_x15_r0_body.Pc64.N0 16566 = true
theorem PRE_first_tail_x15_r0_body.raised64 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc64 PRE_first_tail_x15_r0_body.P64 :=
  .inr ⟨16566, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise64, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_64 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_64 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s629.ffi)
def PRE_first_tail_x15_r0_body.khinv64 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv64 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS64 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS64 : List Nat := List.range' 16566 0
def PRE_first_tail_x15_r0_body.ciS64 : List Nat := [] ++ List.range' 16566 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh064 : PRE_first_tail_x15_r0_body.kd64.nh0 = PRE_first_tail_x15_r0_body.cx0_64.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh164 : PRE_first_tail_x15_r0_body.kd64.nh1 = PRE_first_tail_x15_r0_body.cx1_64.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn064 : PRE_first_tail_x15_r0_body.kd64.nn0 = PRE_first_tail_x15_r0_body.cx0_64.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn164 : PRE_first_tail_x15_r0_body.kd64.nn1 = PRE_first_tail_x15_r0_body.cx1_64.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo64 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P64.lo && Nat.ble PRE_first_tail_x15_r0_body.P64.lo PRE_first_tail_x15_r0_body.cx0_64.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P64.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P64.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt64 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_64.mlx.next PRE_first_tail_x15_r0_body.cx1_64.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_64.mlx.nnext PRE_first_tail_x15_r0_body.cx1_64.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband64 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P64.NL && Nat.ble PRE_first_tail_x15_r0_body.P64.NL PRE_first_tail_x15_r0_body.P64.N0 && Nat.ble PRE_first_tail_x15_r0_body.P64.N0 PRE_first_tail_x15_r0_body.cx0_64.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow64 : PRE_first_tail_x15_r0_body.kd64.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren64 : checkRenG PRE_first_tail_x15_r0_body.kd64.hnd PRE_first_tail_x15_r0_body.khinv64 (phB PRE_first_tail_x15_r0_body.cx0_64.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband64 : PRE_first_tail_x15_r0_body.kd64.checkBand PRE_first_tail_x15_r0_body.P64.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos64 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd64.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren64 : checkRenG PRE_first_tail_x15_r0_body.kd64.node PRE_first_tail_x15_r0_body.kninv64 (pnB PRE_first_tail_x15_r0_body.cx0_64.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow64 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd64.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P64.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd64.nodeF j) PRE_first_tail_x15_r0_body.cx1_64.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a64 : PRE_first_tail_x15_r0_body.cx0_64.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b64 : PRE_first_tail_x15_r0_body.cx0_64.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok164 : PRE_first_tail_x15_r0_body.cx1_64.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend64 : PRE_first_tail_x15_r0_body.cx1_64.mlx.pending = PRE_first_tail_x15_r0_body.cx0_64.mlx.pending.map PRE_first_tail_x15_r0_body.kappa64.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh64 : PRE_first_tail_x15_r0_body.cx1_64.mlx.errh = PRE_first_tail_x15_r0_body.cx0_64.mlx.errh.map PRE_first_tail_x15_r0_body.kappa64.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles64 : PRE_first_tail_x15_r0_body.cx1_64.mlx.files = PRE_first_tail_x15_r0_body.cx0_64.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch64 : PRE_first_tail_x15_r0_body.cx1_64.mlx.arch = PRE_first_tail_x15_r0_body.cx0_64.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes64 : PRE_first_tail_x15_r0_body.cx1_64.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_64.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired64 : PRE_first_tail_x15_r0_body.cx1_64.mlx.wired = PRE_first_tail_x15_r0_body.cx0_64.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost64 : PRE_first_tail_x15_r0_body.cx1_64.host = PRE_first_tail_x15_r0_body.cx0_64.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd64`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn064 : PRE_first_tail_x15_r0_body.kd64.n0 = 2725299
kernel_rfl PRE_first_tail_x15_r0_body.ckn164 : PRE_first_tail_x15_r0_body.kd64.n1 = 2725301
kernel_rfl PRE_first_tail_x15_r0_body.ckheap64 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd64.heap).all (fun x => Nat.ble 2725299 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl64 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd64.heap.get (2725299 + j) = nth? PRE_first_tail_x15_r0_body.pl64 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja64 : Nat.ble 2725299 2725299 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn64 : Nat.ble 2816 2816 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD64 : Nat.ble 2725299 PRE_first_tail_x15_r0_body.kd64.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn64 : Nat.ble 19469 PRE_first_tail_x15_r0_body.kd64.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn64 : Nat.ble 16566 PRE_first_tail_x15_r0_body.kd64.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb64 : Nat.ble 19469 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap64 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd64.heap).all (Nat.ble (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd64 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd64.hnd).all (Nat.ble (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode64 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd64.node).all (Nat.ble (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix64 : Conv.FixOld (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa64 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja64) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn64) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD64) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn64) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn64) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb64) PRE_first_tail_x15_r0_body.fheap64 PRE_first_tail_x15_r0_body.fhnd64 PRE_first_tail_x15_r0_body.fnode64
kernel_rfl PRE_first_tail_x15_r0_body.fcxn64 : (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn64 : (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle064 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_64.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_64.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk64 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd64.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A64 : PRE_first_tail_x15_r0_body.cx1_64.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS64.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_64.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O64 : PRE_first_tail_x15_r0_body.cx1_64.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS64.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_64.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N64 : PRE_first_tail_x15_r0_body.cx1_64.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS64.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_64.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I64 : PRE_first_tail_x15_r0_body.cx1_64.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS64.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_64.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd64 : (PRE_first_tail_x15_r0_body.clo64 ++ PRE_first_tail_x15_r0_body.cln64 ++ PRE_first_tail_x15_r0_body.cli64 ++ PRE_first_tail_x15_r0_body.cwS64 ++ PRE_first_tail_x15_r0_body.cnS64 ++ PRE_first_tail_x15_r0_body.ciS64).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW64 : PRE_first_tail_x15_r0_body.cwS64.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo64.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI64 : PRE_first_tail_x15_r0_body.ciS64.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli64.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN64 : PRE_first_tail_x15_r0_body.cnS64.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF64 : PRE_first_tail_x15_r0_body.cln64.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh64 : PRE_first_tail_x15_r0_body.clo64.all (handleOK PRE_first_tail_x15_r0_body.kappa64 PRE_first_tail_x15_r0_body.P64.lo PRE_first_tail_x15_r0_body.cx0_64.mlx PRE_first_tail_x15_r0_body.cx1_64.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo64 : PRE_first_tail_x15_r0_body.clo64.map (fun h => PRE_first_tail_x15_r0_body.cx1_64.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa64.handle h)) = PRE_first_tail_x15_r0_body.clo64.map (fun h => (PRE_first_tail_x15_r0_body.cx0_64.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa64.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok64 : PRE_first_tail_x15_r0_body.clo64.all (objOK PRE_first_tail_x15_r0_body.kappa64 PRE_first_tail_x15_r0_body.P64.NL PRE_first_tail_x15_r0_body.cx0_64.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd64 : PRE_first_tail_x15_r0_body.cln64.all (nodeOKF PRE_first_tail_x15_r0_body.kappa64 PRE_first_tail_x15_r0_body.P64 PRE_first_tail_x15_r0_body.cx0_64.mlx PRE_first_tail_x15_r0_body.cx1_64.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp64 : ((PRE_first_tail_x15_r0_body.cln64.filter (fullB PRE_first_tail_x15_r0_body.P64))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_64.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa64.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln64.filter (fullB PRE_first_tail_x15_r0_body.P64))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_64.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa64.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI64 : incrB PRE_first_tail_x15_r0_body.kd64.nodeF (List.range' 16566 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK64 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd64.node).all (fun k => Nat.ble 16566 k && Nat.blt k 16566) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL64 : (PRE_first_tail_x15_r0_body.cln64.filter (Nat.ble PRE_first_tail_x15_r0_body.P64.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd64.nodeF i) && (Nat.blt i 16566 || Nat.ble PRE_first_tail_x15_r0_body.kd64.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord64 : (PRE_first_tail_x15_r0_body.cln64.filter (Nat.ble PRE_first_tail_x15_r0_body.P64.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd64.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd64.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd64.nodeF j) (PRE_first_tail_x15_r0_body.kd64.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow64 PRE_first_tail_x15_r0_body.cnn164 PRE_first_tail_x15_r0_body.fnordI64 PRE_first_tail_x15_r0_body.fnordK64 PRE_first_tail_x15_r0_body.fnordL64
kernel_rfl PRE_first_tail_x15_r0_body.fi64 : PRE_first_tail_x15_r0_body.cli64.all (pnB PRE_first_tail_x15_r0_body.cx0_64.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii64 : PRE_first_tail_x15_r0_body.cli64.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_64.mlx.items.get (PRE_first_tail_x15_r0_body.kappa64.node k) = (PRE_first_tail_x15_r0_body.cx0_64.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa64.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot64 (clean : Conv.NClean (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P64.NL) (cl : SSt (· < 2816) PRE_first_tail_x15_r0_body.cx0_64.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P64 2816 PRE_first_tail_x15_r0_body.kappa64 PRE_first_tail_x15_r0_body.kd64 PRE_first_tail_x15_r0_body.khinv64 PRE_first_tail_x15_r0_body.kninv64 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx PRE_first_tail_x15_r0_body.cx0_64.mlx PRE_first_tail_x15_r0_body.cx1_64.mlx (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo64 PRE_first_tail_x15_r0_body.cln64 PRE_first_tail_x15_r0_body.cli64 PRE_first_tail_x15_r0_body.cwS64 PRE_first_tail_x15_r0_body.cnS64 PRE_first_tail_x15_r0_body.ciS64 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh064, PRE_first_tail_x15_r0_body.cnh164, PRE_first_tail_x15_r0_body.cnn064, PRE_first_tail_x15_r0_body.cnn164, PRE_first_tail_x15_r0_body.cplo64, PRE_first_tail_x15_r0_body.ccnt64, PRE_first_tail_x15_r0_body.cnband64, PRE_first_tail_x15_r0_body.chbelow64, PRE_first_tail_x15_r0_body.chren64, PRE_first_tail_x15_r0_body.cband64, PRE_first_tail_x15_r0_body.cnh1pos64, PRE_first_tail_x15_r0_body.cnren64, PRE_first_tail_x15_r0_body.cnlow64, PRE_first_tail_x15_r0_body.cabs0a64, PRE_first_tail_x15_r0_body.cabs0b64, PRE_first_tail_x15_r0_body.ctok164, PRE_first_tail_x15_r0_body.cpend64, PRE_first_tail_x15_r0_body.cerrh64, PRE_first_tail_x15_r0_body.cfiles64, PRE_first_tail_x15_r0_body.carch64, PRE_first_tail_x15_r0_body.csizes64, PRE_first_tail_x15_r0_body.cwired64, PRE_first_tail_x15_r0_body.cfix64, clean, PRE_first_tail_x15_r0_body.fcxn64, PRE_first_tail_x15_r0_body.fcnn64, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle064, PRE_first_tail_x15_r0_body.fnk64, PRE_first_tail_x15_r0_body.ckA64, PRE_first_tail_x15_r0_body.cobjsK64, PRE_first_tail_x15_r0_body.cnodesK64, PRE_first_tail_x15_r0_body.citemsK64, PRE_first_tail_x15_r0_body.f1A64, PRE_first_tail_x15_r0_body.f1O64, PRE_first_tail_x15_r0_body.f1N64, PRE_first_tail_x15_r0_body.f1I64, PRE_first_tail_x15_r0_body.fbd64, PRE_first_tail_x15_r0_body.fincW64, PRE_first_tail_x15_r0_body.fincI64, PRE_first_tail_x15_r0_body.fincN64, PRE_first_tail_x15_r0_body.flnF64, PRE_first_tail_x15_r0_body.fh64, PRE_first_tail_x15_r0_body.fo64, PRE_first_tail_x15_r0_body.fok64, PRE_first_tail_x15_r0_body.fnd64, PRE_first_tail_x15_r0_body.fp64, PRE_first_tail_x15_r0_body.fnord64, PRE_first_tail_x15_r0_body.fi64, PRE_first_tail_x15_r0_body.fii64⟩
theorem PRE_first_tail_x15_r0_body.cnshift64 (clean : Conv.NClean (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P64.NL) (cl : SSt (· < 2816) PRE_first_tail_x15_r0_body.cx0_64.mlx) : NShift PRE_first_tail_x15_r0_body.P64 2816 PRE_first_tail_x15_r0_body.kappa64 PRE_first_tail_x15_r0_body.cx0_64 PRE_first_tail_x15_r0_body.cx1_64 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot64 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost64 (compact_a_eq PRE_first_tail_x15_r0_body.ckn064 PRE_first_tail_x15_r0_body.ckn164 PRE_first_tail_x15_r0_body.ckheap64 PRE_first_tail_x15_r0_body.ckpl64)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_64 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s628.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_64 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s628.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_64 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s628.ffi) = some PRE_first_tail_x15_r0_body.fxC_64
kernel_rfl PRE_first_tail_x15_r0_body.okrC_64 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s628.ffi) = some PRE_first_tail_x15_r0_body.krC_64
noncomputable def PRE_first_tail_x15_r0_body.fx0_64 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s630.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_64 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s630.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_64 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s630.ffi) = some PRE_first_tail_x15_r0_body.fx0_64
kernel_rfl PRE_first_tail_x15_r0_body.okr0_64 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s630.ffi) = some PRE_first_tail_x15_r0_body.kr0_64
noncomputable def PRE_first_tail_x15_r0_body.fx1_64 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s629.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_64 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s629.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_64 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s629.ffi) = some PRE_first_tail_x15_r0_body.fx1_64
kernel_rfl PRE_first_tail_x15_r0_body.okr1_64 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s629.ffi) = some PRE_first_tail_x15_r0_body.kr1_64
kernel_rfl PRE_first_tail_x15_r0_body.ff064 : PRE_first_tail_x15_r0_body.fx0_64 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_64 (PRE_first_tail_x15_r0_body.clo64.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_64.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff164 : PRE_first_tail_x15_r0_body.fx1_64 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_64 (PRE_first_tail_x15_r0_body.cwS64.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_64.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck64 : freedLB PRE_first_tail_x15_r0_body.kappa64 PRE_first_tail_x15_r0_body.cx0_64.mlx PRE_first_tail_x15_r0_body.fx0_64 PRE_first_tail_x15_r0_body.fx1_64 PRE_first_tail_x15_r0_body.clo64 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf064 : PRE_first_tail_x15_r0_body.kr0_64.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_64.flags (PRE_first_tail_x15_r0_body.clo64.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_64.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt064 : PRE_first_tail_x15_r0_body.kr0_64.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_64.targs (PRE_first_tail_x15_r0_body.clo64.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_64.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf164 : PRE_first_tail_x15_r0_body.kr1_64.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_64.flags (PRE_first_tail_x15_r0_body.cwS64.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_64.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt164 : PRE_first_tail_x15_r0_body.kr1_64.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_64.targs (PRE_first_tail_x15_r0_body.cwS64.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_64.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck64 : krecLB PRE_first_tail_x15_r0_body.kappa64 2816 PRE_first_tail_x15_r0_body.cx0_64.mlx PRE_first_tail_x15_r0_body.kr0_64 PRE_first_tail_x15_r0_body.kr1_64 PRE_first_tail_x15_r0_body.clo64 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn64 : Nat.ble 2816 2816 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge64 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s629.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s630.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR64 : pendRegB PRE_first_tail_x15_r0_body.kappa64 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe64 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s629.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift64 (clean : Conv.NClean (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P64.NL) (cl : SSt (· < 2816) PRE_first_tail_x15_r0_body.cx0_64.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_64.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_64.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_64.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_64.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P64 2816 PRE_first_tail_x15_r0_body.kappa64 PRE_first_tail_x15_r0_body.s630.ffi PRE_first_tail_x15_r0_body.s629.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift64 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue64, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp64 t ht),
    PRE_first_tail_x15_r0_body.cbridge64,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s630.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s629.ffi) (PRE_first_tail_x15_r0_body.cfoot64 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_64 PRE_first_tail_x15_r0_body.ofx1_64 hobjC PRE_first_tail_x15_r0_body.ff064 PRE_first_tail_x15_r0_body.ff164 PRE_first_tail_x15_r0_body.ffck64,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s630.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s629.ffi) (PRE_first_tail_x15_r0_body.cfoot64 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_64 PRE_first_tail_x15_r0_body.okr1_64 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn64) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf064 PRE_first_tail_x15_r0_body.fkt064 PRE_first_tail_x15_r0_body.fkf164 PRE_first_tail_x15_r0_body.fkt164 PRE_first_tail_x15_r0_body.fkck64,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh064 PRE_first_tail_x15_r0_body.cnh164 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe64) PRE_first_tail_x15_r0_body.cpendR64⟩

end Host.Load.Run.Tpl
end

section -- st64/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st64 0
host_stream_state PRE_first_tail_x15_r0_body.st64 1
host_stream_state PRE_first_tail_x15_r0_body.st64 2
end Host.Load.Run.Tpl
end

section -- Site64
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 64 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g64__g65` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s628`, the merged state `PRE_first_tail_x15_r0_body.s629`,
the site template `PRE_first_tail_x15_r0_body.st64` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s630`: the merge.
The footprint's facts are in `SiteF64`, the compaction's in `SiteC64`, `SiteK64`, `SiteNa64`, `SiteNb64`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso64 : PRE_first_tail_x15_r0_body.st64.s0 = { PRE_first_tail_x15_r0_body.s628 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs64 : List Frame := PRE_first_tail_x15_r0_body.s628.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_64 : PRE_first_tail_x15_r0_body.S628.tab.length = 2816
kernel_rfl PRE_first_tail_x15_r0_body.tab0_64 : PRE_first_tail_x15_r0_body.st64.S0.tab = PRE_first_tail_x15_r0_body.S628.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws64 : List Nat := [2110, 2111]
kernel_rfl PRE_first_tail_x15_r0_body.fresh64 : (PRE_first_tail_x15_r0_body.S628.tab.all fun e => PRE_first_tail_x15_r0_body.ws64.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S628.oracle.all fun q => PRE_first_tail_x15_r0_body.ws64.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab64 : PRE_first_tail_x15_r0_body.S629.tab = PRE_first_tail_x15_r0_body.S628.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws64
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen64 : PRE_first_tail_x15_r0_body.st64.S2.tab.length - PRE_first_tail_x15_r0_body.st64.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged64`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap64 : PRE_first_tail_x15_r0_body.s629.heap = PRE_first_tail_x15_r0_body.st64.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext64 : PRE_first_tail_x15_r0_body.s629.next = PRE_first_tail_x15_r0_body.st64.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl64 : PRE_first_tail_x15_r0_body.s629.ctl = PRE_first_tail_x15_r0_body.st64.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack64 : PRE_first_tail_x15_r0_body.s629.stack = PRE_first_tail_x15_r0_body.st64.s2.stack ++ PRE_first_tail_x15_r0_body.s628.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs64 : PRE_first_tail_x15_r0_body.s629.jobs = PRE_first_tail_x15_r0_body.st64.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi64 : PRE_first_tail_x15_r0_body.s629.ffi = PRE_first_tail_x15_r0_body.st64.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace64 : PRE_first_tail_x15_r0_body.s629.trace = PRE_first_tail_x15_r0_body.st64.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores64 : PRE_first_tail_x15_r0_body.s629.stores = PRE_first_tail_x15_r0_body.st64.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD64
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 64 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived64 : PRE_first_tail_x15_r0_body.nr64.map (fun r => nth? PRE_first_tail_x15_r0_body.st64.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo64 : PRE_first_tail_x15_r0_body.nr64.all (Nat.ble 2816) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj64 : PRE_first_tail_x15_r0_body.cws64.all (fun c => !PRE_first_tail_x15_r0_body.ws64.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ64 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws64 PRE_first_tail_x15_r0_body.crs64 PRE_first_tail_x15_r0_body.ws64

end Host.Load.Run.Tpl
end

section -- st64/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st64`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st64.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st64.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st64.s2.heap PRE_first_tail_x15_r0_body.st64.wrR ++ freshOf PRE_first_tail_x15_r0_body.st64.s2.heap PRE_first_tail_x15_r0_body.st64.s0.next PRE_first_tail_x15_r0_body.st64.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st64.wr : List Nat := PRE_first_tail_x15_r0_body.st64.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st64.heapFoot : PRE_first_tail_x15_r0_body.st64.s2.heap = setAll PRE_first_tail_x15_r0_body.st64.s0.heap PRE_first_tail_x15_r0_body.st64.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st64.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st64.s0.next PRE_first_tail_x15_r0_body.st64.s2.next = true
theorem PRE_first_tail_x15_r0_body.st64.grows : PRE_first_tail_x15_r0_body.st64.s0.next ≤ PRE_first_tail_x15_r0_body.st64.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st64.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st64.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st64.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st64.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st64.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st64.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st64.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st64.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st64.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st64.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st64.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st64.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st64.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st64.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st64.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st64.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st64.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st64.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st64.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st64.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st64.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st64.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st64.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st64.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st64.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st64.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st64.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st64.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st64.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st64.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st64.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st64.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF64
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 64 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB64 : nodupT PRE_first_tail_x15_r0_body.st64.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup64 : PRE_first_tail_x15_r0_body.st64.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB64).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB64 : PRE_first_tail_x15_r0_body.st64.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound64 : ∀ b ∈ PRE_first_tail_x15_r0_body.st64.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB64 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr64 := PRE_first_tail_x15_r0_body.st64.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq64 : PRE_first_tail_x15_r0_body.st64.s2.trace = PRE_first_tail_x15_r0_body.trFr64 ++ PRE_first_tail_x15_r0_body.st64.s0.trace
theorem PRE_first_tail_x15_r0_body.trace64 : ∃ fr, PRE_first_tail_x15_r0_body.st64.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st64.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq64⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide64 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB64 : (PRE_first_tail_x15_r0_body.wide64.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st64.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix64 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide64, WFix Map.id (Present PRE_first_tail_x15_r0_body.st64.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB64 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL64
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 64 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s629`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO64 : PRE_first_tail_x15_r0_body.st64.S0.oracle = PRE_first_tail_x15_r0_body.st64.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B64 : PRE_first_tail_x15_r0_body.st64.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st64.s0.next || (PRE_first_tail_x15_r0_body.st64.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot64 : Conv.StageFoot PRE_first_tail_x15_r0_body.st64.wr PRE_first_tail_x15_r0_body.st64.s0 PRE_first_tail_x15_r0_body.st64.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st64.heapFoot PRE_first_tail_x15_r0_body.wrNodup64 PRE_first_tail_x15_r0_body.wrBound64 PRE_first_tail_x15_r0_body.wr0B64 PRE_first_tail_x15_r0_body.st64.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged64 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st64.F.S → PRE_first_tail_x15_r0_body.st64.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st64.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st64.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs64 PRE_first_tail_x15_r0_body.st64.wr PRE_first_tail_x15_r0_body.s628 PRE_first_tail_x15_r0_body.st64.s2 PRE_first_tail_x15_r0_body.st64.s0
      PRE_first_tail_x15_r0_body.st64.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st64.F FR W stk M ν K PRE_first_tail_x15_r0_body.s629 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso64 PRE_first_tail_x15_r0_body.stFoot64 PRE_first_tail_x15_r0_body.wrNodup64 PRE_first_tail_x15_r0_body.wrBound64 PRE_first_tail_x15_r0_body.trace64 PRE_first_tail_x15_r0_body.mheap64
    PRE_first_tail_x15_r0_body.mnext64 PRE_first_tail_x15_r0_body.mctl64 PRE_first_tail_x15_r0_body.mstack64 PRE_first_tail_x15_r0_body.mjobs64 PRE_first_tail_x15_r0_body.mffi64 PRE_first_tail_x15_r0_body.mtrace64 PRE_first_tail_x15_r0_body.mstores64 h

def PRE_first_tail_x15_r0_body.arrEl64_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE64_2665 : arrOf PRE_first_tail_x15_r0_body.s629 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl64_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA64_2665 : isArrB PRE_first_tail_x15_r0_body.s629 2665 = true
theorem PRE_first_tail_x15_r0_body.arr64_2665 : ∃ o, PRE_first_tail_x15_r0_body.s629.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl64_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE64_2665 PRE_first_tail_x15_r0_body.arrA64_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN64_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl64_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR64_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl64_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN64_2665

def PRE_first_tail_x15_r0_body.arrEl64_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE64_2673467 : arrOf PRE_first_tail_x15_r0_body.s629 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl64_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA64_2673467 : isArrB PRE_first_tail_x15_r0_body.s629 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr64_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s629.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl64_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE64_2673467 PRE_first_tail_x15_r0_body.arrA64_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN64_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl64_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR64_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl64_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN64_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k64 : isArrB PRE_first_tail_x15_r0_body.s629 4910 = false
theorem PRE_first_tail_x15_r0_body.keep64 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s629 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k64 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr64_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl64_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ64
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
end

section -- st64/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st64.bodyLast from PRE_first_tail_x15_r0_body.st64.s1 to PRE_first_tail_x15_r0_body.st64.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st64.F PRE_first_tail_x15_r0_body.st64.s1).run PRE_first_tail_x15_r0_body.st64.S1 = some (PRE_first_tail_x15_r0_body.st64.s2, PRE_first_tail_x15_r0_body.st64.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st64.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st64.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st64.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st64.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st64/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st64.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st64.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st64.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st64.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st64.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st64.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st64.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st64.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st64.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st64.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st64.s0 PRE_first_tail_x15_r0_body.st64.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st64.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st64.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st64.s1 PRE_first_tail_x15_r0_body.st64.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st64/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st64.bodyK0F from PRE_first_tail_x15_r0_body.st64.s0 to PRE_first_tail_x15_r0_body.st64.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st64.F (PRE_first_tail_x15_r0_body.st64.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st64.ks 0).getD 0) PRE_first_tail_x15_r0_body.st64.s0 PRE_first_tail_x15_r0_body.st64.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st64.s1, PRE_first_tail_x15_r0_body.st64.S1)
theorem PRE_first_tail_x15_r0_body.st64.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st64.F (PRE_first_tail_x15_r0_body.st64.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st64.ks 0).getD 0) PRE_first_tail_x15_r0_body.st64.s0 PRE_first_tail_x15_r0_body.st64.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st64.s1, PRE_first_tail_x15_r0_body.st64.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st64.bodyOkLN_ok PRE_first_tail_x15_r0_body.st64.bodyK0F
end Host.Load.Run.Tpl
end

section -- st64/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st64.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st64.F (PRE_first_tail_x15_r0_body.st64.bodyOkL bytes rows) 27 PRE_first_tail_x15_r0_body.st64.s0 PRE_first_tail_x15_r0_body.st64.S0 = some (PRE_first_tail_x15_r0_body.st64.s1, PRE_first_tail_x15_r0_body.st64.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st64.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st64.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st64.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st64.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st64.F (PRE_first_tail_x15_r0_body.st64.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st64.s0
  S0 := PRE_first_tail_x15_r0_body.st64.S0
  s1 := PRE_first_tail_x15_r0_body.st64.s1
  S1 := PRE_first_tail_x15_r0_body.st64.S1
  s2 := PRE_first_tail_x15_r0_body.st64.s2
  S2 := PRE_first_tail_x15_r0_body.st64.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st64.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st64.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st64.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st64.bodyHalt
  last := PRE_first_tail_x15_r0_body.st64.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st64.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC65
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 65 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s634` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa65` into the merged state
`PRE_first_tail_x15_r0_body.s633`. -/

def PRE_first_tail_x15_r0_body.pl65 : List Nat := [2725597]
def PRE_first_tail_x15_r0_body.nr65 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd65 : RData :=
  ⟨2725588, 2725598, Stage.setAll PTrie.nil [(2725587, 2725597)], Stage.setAll PTrie.nil [],
   19476, 19476, 16570, 16570, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa65 : Map :=
  Conv.Map.compact 2725587 2725598 2833 PRE_first_tail_x15_r0_body.pl65 (PRE_first_tail_x15_r0_body.nr65.map NumV.ref) PRE_first_tail_x15_r0_body.kd65.big
    PRE_first_tail_x15_r0_body.kd65.region PRE_first_tail_x15_r0_body.kd65.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws65 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs65 : List SymE := PRE_first_tail_x15_r0_body.nr65.map fun r => (nth? PRE_first_tail_x15_r0_body.S633.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta65 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws65 PRE_first_tail_x15_r0_body.crs65
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB65 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab65 : PRE_first_tail_x15_r0_body.S634.tab = PRE_first_tail_x15_r0_body.S632.tab ++ PRE_first_tail_x15_r0_body.cws65.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace65 : PRE_first_tail_x15_r0_body.s634.trace = PRE_first_tail_x15_r0_body.s632.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext65 : PRE_first_tail_x15_r0_body.s634.next = 2725588
kernel_rfl PRE_first_tail_x15_r0_body.ccounters65 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s634.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s634.ffi).mlx.nnext) = (19476, 16570)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue65 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s633.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s634.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa65.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp65 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s634.ffi).mlx.tokens.all (bSN 2833) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean65 : Conv.cleanListB 19476 131072 (fun r => Nat.ble 77904 r) PRE_first_tail_x15_r0_body.s634
    (PRE_first_tail_x15_r0_body.wrB65 ++ (List.range 1).map (2725587 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs65 : bigsOutB 19476 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s634.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK65
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl65`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl65 : List Nat := [2665, 2673467, 2725587]
def PRE_first_tail_x15_r0_body.clo65 : List Nat := []
def PRE_first_tail_x15_r0_body.cln65 : List Nat := []
def PRE_first_tail_x15_r0_body.cli65 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap65 : PRE_first_tail_x15_r0_body.s634.heap = Stage.setAll PRE_first_tail_x15_r0_body.s632.heap (PRE_first_tail_x15_r0_body.cl65.filterMap fun a => (PRE_first_tail_x15_r0_body.s634.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe65 : Nat.ble PRE_first_tail_x15_r0_body.s632.next PRE_first_tail_x15_r0_body.s634.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP65 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s632 PRE_first_tail_x15_r0_body.s634 PRE_first_tail_x15_r0_body.cl65 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp65 : Conv.suppListB PRE_first_tail_x15_r0_body.s634 2833 PRE_first_tail_x15_r0_body.cl65 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound65 : Conv.boundListB PRE_first_tail_x15_r0_body.s634 PRE_first_tail_x15_r0_body.cl65 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK65 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s634.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln65.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s634.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK65 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s634.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo65.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s634.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK65 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s634.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli65.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s634.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst65 : Conv.sstListB 2833 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s634.ffi).mlx PRE_first_tail_x15_r0_body.cln65 PRE_first_tail_x15_r0_body.clo65 PRE_first_tail_x15_r0_body.cli65 = true

end Host.Load.Run.Tpl
end

section -- SiteCl65
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA65 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s634.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo65.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s634.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd65 : (PRE_first_tail_x15_r0_body.clo65 ++ PRE_first_tail_x15_r0_body.cln65 ++ PRE_first_tail_x15_r0_body.cli65).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle65 : Conv.Cnt.leB (⟨19476, 16570, 2725587, 2833⟩ : Conv.Cnt) (⟨19476, 16570, 2725588, 2833⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck65 : Conv.ncleanListB (⟨19476, 16570, 2725588, 2833⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s634.ffi).mlx PRE_first_tail_x15_r0_body.clo65 PRE_first_tail_x15_r0_body.cln65 PRE_first_tail_x15_r0_body.cli65 = true
theorem PRE_first_tail_x15_r0_body.cncl65 (h : Conv.NClean (⟨19476, 16570, 2725587, 2833⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx) : Conv.NClean (⟨19476, 16570, 2725588, 2833⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s634.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle65 PRE_first_tail_x15_r0_body.ckA65 PRE_first_tail_x15_r0_body.cobjsK65 PRE_first_tail_x15_r0_body.cnodesK65 PRE_first_tail_x15_r0_body.citemsK65 PRE_first_tail_x15_r0_body.cbd65 PRE_first_tail_x15_r0_body.cck65

end Host.Load.Run.Tpl
end

section -- SiteS65
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 65 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc65 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P65 : LoadP := PRE_first_tail_x15_r0_body.Pc65.raise 16570
kernel_rfl PRE_first_tail_x15_r0_body.craise65 : Nat.ble PRE_first_tail_x15_r0_body.Pc65.N0 16570 = true
theorem PRE_first_tail_x15_r0_body.raised65 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc65 PRE_first_tail_x15_r0_body.P65 :=
  .inr ⟨16570, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise65, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_65 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s634.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_65 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s633.ffi)
def PRE_first_tail_x15_r0_body.khinv65 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv65 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS65 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS65 : List Nat := List.range' 16570 0
def PRE_first_tail_x15_r0_body.ciS65 : List Nat := [] ++ List.range' 16570 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh065 : PRE_first_tail_x15_r0_body.kd65.nh0 = PRE_first_tail_x15_r0_body.cx0_65.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh165 : PRE_first_tail_x15_r0_body.kd65.nh1 = PRE_first_tail_x15_r0_body.cx1_65.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn065 : PRE_first_tail_x15_r0_body.kd65.nn0 = PRE_first_tail_x15_r0_body.cx0_65.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn165 : PRE_first_tail_x15_r0_body.kd65.nn1 = PRE_first_tail_x15_r0_body.cx1_65.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo65 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P65.lo && Nat.ble PRE_first_tail_x15_r0_body.P65.lo PRE_first_tail_x15_r0_body.cx0_65.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P65.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P65.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt65 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_65.mlx.next PRE_first_tail_x15_r0_body.cx1_65.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_65.mlx.nnext PRE_first_tail_x15_r0_body.cx1_65.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband65 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P65.NL && Nat.ble PRE_first_tail_x15_r0_body.P65.NL PRE_first_tail_x15_r0_body.P65.N0 && Nat.ble PRE_first_tail_x15_r0_body.P65.N0 PRE_first_tail_x15_r0_body.cx0_65.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow65 : PRE_first_tail_x15_r0_body.kd65.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren65 : checkRenG PRE_first_tail_x15_r0_body.kd65.hnd PRE_first_tail_x15_r0_body.khinv65 (phB PRE_first_tail_x15_r0_body.cx0_65.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband65 : PRE_first_tail_x15_r0_body.kd65.checkBand PRE_first_tail_x15_r0_body.P65.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos65 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd65.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren65 : checkRenG PRE_first_tail_x15_r0_body.kd65.node PRE_first_tail_x15_r0_body.kninv65 (pnB PRE_first_tail_x15_r0_body.cx0_65.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow65 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd65.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P65.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd65.nodeF j) PRE_first_tail_x15_r0_body.cx1_65.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a65 : PRE_first_tail_x15_r0_body.cx0_65.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b65 : PRE_first_tail_x15_r0_body.cx0_65.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok165 : PRE_first_tail_x15_r0_body.cx1_65.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend65 : PRE_first_tail_x15_r0_body.cx1_65.mlx.pending = PRE_first_tail_x15_r0_body.cx0_65.mlx.pending.map PRE_first_tail_x15_r0_body.kappa65.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh65 : PRE_first_tail_x15_r0_body.cx1_65.mlx.errh = PRE_first_tail_x15_r0_body.cx0_65.mlx.errh.map PRE_first_tail_x15_r0_body.kappa65.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles65 : PRE_first_tail_x15_r0_body.cx1_65.mlx.files = PRE_first_tail_x15_r0_body.cx0_65.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch65 : PRE_first_tail_x15_r0_body.cx1_65.mlx.arch = PRE_first_tail_x15_r0_body.cx0_65.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes65 : PRE_first_tail_x15_r0_body.cx1_65.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_65.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired65 : PRE_first_tail_x15_r0_body.cx1_65.mlx.wired = PRE_first_tail_x15_r0_body.cx0_65.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost65 : PRE_first_tail_x15_r0_body.cx1_65.host = PRE_first_tail_x15_r0_body.cx0_65.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd65`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn065 : PRE_first_tail_x15_r0_body.kd65.n0 = 2725588
kernel_rfl PRE_first_tail_x15_r0_body.ckn165 : PRE_first_tail_x15_r0_body.kd65.n1 = 2725598
kernel_rfl PRE_first_tail_x15_r0_body.ckheap65 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd65.heap).all (fun x => Nat.ble 2725587 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl65 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd65.heap.get (2725587 + j) = nth? PRE_first_tail_x15_r0_body.pl65 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja65 : Nat.ble 2725587 2725587 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn65 : Nat.ble 2833 2833 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD65 : Nat.ble 2725587 PRE_first_tail_x15_r0_body.kd65.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn65 : Nat.ble 19476 PRE_first_tail_x15_r0_body.kd65.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn65 : Nat.ble 16570 PRE_first_tail_x15_r0_body.kd65.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb65 : Nat.ble 19476 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap65 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd65.heap).all (Nat.ble (⟨19476, 16570, 2725587, 2833⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd65 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd65.hnd).all (Nat.ble (⟨19476, 16570, 2725587, 2833⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode65 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd65.node).all (Nat.ble (⟨19476, 16570, 2725587, 2833⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix65 : Conv.FixOld (⟨19476, 16570, 2725587, 2833⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa65 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja65) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn65) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD65) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn65) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn65) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb65) PRE_first_tail_x15_r0_body.fheap65 PRE_first_tail_x15_r0_body.fhnd65 PRE_first_tail_x15_r0_body.fnode65
kernel_rfl PRE_first_tail_x15_r0_body.fcxn65 : (⟨19476, 16570, 2725587, 2833⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn65 : (⟨19476, 16570, 2725587, 2833⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle065 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_65.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_65.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk65 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd65.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A65 : PRE_first_tail_x15_r0_body.cx1_65.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS65.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_65.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O65 : PRE_first_tail_x15_r0_body.cx1_65.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS65.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_65.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N65 : PRE_first_tail_x15_r0_body.cx1_65.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS65.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_65.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I65 : PRE_first_tail_x15_r0_body.cx1_65.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS65.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_65.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd65 : (PRE_first_tail_x15_r0_body.clo65 ++ PRE_first_tail_x15_r0_body.cln65 ++ PRE_first_tail_x15_r0_body.cli65 ++ PRE_first_tail_x15_r0_body.cwS65 ++ PRE_first_tail_x15_r0_body.cnS65 ++ PRE_first_tail_x15_r0_body.ciS65).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW65 : PRE_first_tail_x15_r0_body.cwS65.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo65.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI65 : PRE_first_tail_x15_r0_body.ciS65.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli65.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN65 : PRE_first_tail_x15_r0_body.cnS65.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF65 : PRE_first_tail_x15_r0_body.cln65.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh65 : PRE_first_tail_x15_r0_body.clo65.all (handleOK PRE_first_tail_x15_r0_body.kappa65 PRE_first_tail_x15_r0_body.P65.lo PRE_first_tail_x15_r0_body.cx0_65.mlx PRE_first_tail_x15_r0_body.cx1_65.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo65 : PRE_first_tail_x15_r0_body.clo65.map (fun h => PRE_first_tail_x15_r0_body.cx1_65.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa65.handle h)) = PRE_first_tail_x15_r0_body.clo65.map (fun h => (PRE_first_tail_x15_r0_body.cx0_65.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa65.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok65 : PRE_first_tail_x15_r0_body.clo65.all (objOK PRE_first_tail_x15_r0_body.kappa65 PRE_first_tail_x15_r0_body.P65.NL PRE_first_tail_x15_r0_body.cx0_65.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd65 : PRE_first_tail_x15_r0_body.cln65.all (nodeOKF PRE_first_tail_x15_r0_body.kappa65 PRE_first_tail_x15_r0_body.P65 PRE_first_tail_x15_r0_body.cx0_65.mlx PRE_first_tail_x15_r0_body.cx1_65.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp65 : ((PRE_first_tail_x15_r0_body.cln65.filter (fullB PRE_first_tail_x15_r0_body.P65))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_65.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa65.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln65.filter (fullB PRE_first_tail_x15_r0_body.P65))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_65.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa65.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI65 : incrB PRE_first_tail_x15_r0_body.kd65.nodeF (List.range' 16570 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK65 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd65.node).all (fun k => Nat.ble 16570 k && Nat.blt k 16570) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL65 : (PRE_first_tail_x15_r0_body.cln65.filter (Nat.ble PRE_first_tail_x15_r0_body.P65.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd65.nodeF i) && (Nat.blt i 16570 || Nat.ble PRE_first_tail_x15_r0_body.kd65.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord65 : (PRE_first_tail_x15_r0_body.cln65.filter (Nat.ble PRE_first_tail_x15_r0_body.P65.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd65.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd65.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd65.nodeF j) (PRE_first_tail_x15_r0_body.kd65.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow65 PRE_first_tail_x15_r0_body.cnn165 PRE_first_tail_x15_r0_body.fnordI65 PRE_first_tail_x15_r0_body.fnordK65 PRE_first_tail_x15_r0_body.fnordL65
kernel_rfl PRE_first_tail_x15_r0_body.fi65 : PRE_first_tail_x15_r0_body.cli65.all (pnB PRE_first_tail_x15_r0_body.cx0_65.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii65 : PRE_first_tail_x15_r0_body.cli65.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_65.mlx.items.get (PRE_first_tail_x15_r0_body.kappa65.node k) = (PRE_first_tail_x15_r0_body.cx0_65.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa65.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot65 (clean : Conv.NClean (⟨19476, 16570, 2725587, 2833⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P65.NL) (cl : SSt (· < 2833) PRE_first_tail_x15_r0_body.cx0_65.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P65 2833 PRE_first_tail_x15_r0_body.kappa65 PRE_first_tail_x15_r0_body.kd65 PRE_first_tail_x15_r0_body.khinv65 PRE_first_tail_x15_r0_body.kninv65 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx PRE_first_tail_x15_r0_body.cx0_65.mlx PRE_first_tail_x15_r0_body.cx1_65.mlx (⟨19476, 16570, 2725587, 2833⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo65 PRE_first_tail_x15_r0_body.cln65 PRE_first_tail_x15_r0_body.cli65 PRE_first_tail_x15_r0_body.cwS65 PRE_first_tail_x15_r0_body.cnS65 PRE_first_tail_x15_r0_body.ciS65 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh065, PRE_first_tail_x15_r0_body.cnh165, PRE_first_tail_x15_r0_body.cnn065, PRE_first_tail_x15_r0_body.cnn165, PRE_first_tail_x15_r0_body.cplo65, PRE_first_tail_x15_r0_body.ccnt65, PRE_first_tail_x15_r0_body.cnband65, PRE_first_tail_x15_r0_body.chbelow65, PRE_first_tail_x15_r0_body.chren65, PRE_first_tail_x15_r0_body.cband65, PRE_first_tail_x15_r0_body.cnh1pos65, PRE_first_tail_x15_r0_body.cnren65, PRE_first_tail_x15_r0_body.cnlow65, PRE_first_tail_x15_r0_body.cabs0a65, PRE_first_tail_x15_r0_body.cabs0b65, PRE_first_tail_x15_r0_body.ctok165, PRE_first_tail_x15_r0_body.cpend65, PRE_first_tail_x15_r0_body.cerrh65, PRE_first_tail_x15_r0_body.cfiles65, PRE_first_tail_x15_r0_body.carch65, PRE_first_tail_x15_r0_body.csizes65, PRE_first_tail_x15_r0_body.cwired65, PRE_first_tail_x15_r0_body.cfix65, clean, PRE_first_tail_x15_r0_body.fcxn65, PRE_first_tail_x15_r0_body.fcnn65, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle065, PRE_first_tail_x15_r0_body.fnk65, PRE_first_tail_x15_r0_body.ckA65, PRE_first_tail_x15_r0_body.cobjsK65, PRE_first_tail_x15_r0_body.cnodesK65, PRE_first_tail_x15_r0_body.citemsK65, PRE_first_tail_x15_r0_body.f1A65, PRE_first_tail_x15_r0_body.f1O65, PRE_first_tail_x15_r0_body.f1N65, PRE_first_tail_x15_r0_body.f1I65, PRE_first_tail_x15_r0_body.fbd65, PRE_first_tail_x15_r0_body.fincW65, PRE_first_tail_x15_r0_body.fincI65, PRE_first_tail_x15_r0_body.fincN65, PRE_first_tail_x15_r0_body.flnF65, PRE_first_tail_x15_r0_body.fh65, PRE_first_tail_x15_r0_body.fo65, PRE_first_tail_x15_r0_body.fok65, PRE_first_tail_x15_r0_body.fnd65, PRE_first_tail_x15_r0_body.fp65, PRE_first_tail_x15_r0_body.fnord65, PRE_first_tail_x15_r0_body.fi65, PRE_first_tail_x15_r0_body.fii65⟩
theorem PRE_first_tail_x15_r0_body.cnshift65 (clean : Conv.NClean (⟨19476, 16570, 2725587, 2833⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P65.NL) (cl : SSt (· < 2833) PRE_first_tail_x15_r0_body.cx0_65.mlx) : NShift PRE_first_tail_x15_r0_body.P65 2833 PRE_first_tail_x15_r0_body.kappa65 PRE_first_tail_x15_r0_body.cx0_65 PRE_first_tail_x15_r0_body.cx1_65 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot65 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost65 (compact_a_eq PRE_first_tail_x15_r0_body.ckn065 PRE_first_tail_x15_r0_body.ckn165 PRE_first_tail_x15_r0_body.ckheap65 PRE_first_tail_x15_r0_body.ckpl65)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_65 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s632.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_65 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s632.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_65 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s632.ffi) = some PRE_first_tail_x15_r0_body.fxC_65
kernel_rfl PRE_first_tail_x15_r0_body.okrC_65 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s632.ffi) = some PRE_first_tail_x15_r0_body.krC_65
noncomputable def PRE_first_tail_x15_r0_body.fx0_65 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s634.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_65 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s634.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_65 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s634.ffi) = some PRE_first_tail_x15_r0_body.fx0_65
kernel_rfl PRE_first_tail_x15_r0_body.okr0_65 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s634.ffi) = some PRE_first_tail_x15_r0_body.kr0_65
noncomputable def PRE_first_tail_x15_r0_body.fx1_65 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s633.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_65 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s633.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_65 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s633.ffi) = some PRE_first_tail_x15_r0_body.fx1_65
kernel_rfl PRE_first_tail_x15_r0_body.okr1_65 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s633.ffi) = some PRE_first_tail_x15_r0_body.kr1_65
kernel_rfl PRE_first_tail_x15_r0_body.ff065 : PRE_first_tail_x15_r0_body.fx0_65 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_65 (PRE_first_tail_x15_r0_body.clo65.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_65.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff165 : PRE_first_tail_x15_r0_body.fx1_65 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_65 (PRE_first_tail_x15_r0_body.cwS65.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_65.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck65 : freedLB PRE_first_tail_x15_r0_body.kappa65 PRE_first_tail_x15_r0_body.cx0_65.mlx PRE_first_tail_x15_r0_body.fx0_65 PRE_first_tail_x15_r0_body.fx1_65 PRE_first_tail_x15_r0_body.clo65 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf065 : PRE_first_tail_x15_r0_body.kr0_65.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_65.flags (PRE_first_tail_x15_r0_body.clo65.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_65.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt065 : PRE_first_tail_x15_r0_body.kr0_65.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_65.targs (PRE_first_tail_x15_r0_body.clo65.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_65.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf165 : PRE_first_tail_x15_r0_body.kr1_65.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_65.flags (PRE_first_tail_x15_r0_body.cwS65.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_65.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt165 : PRE_first_tail_x15_r0_body.kr1_65.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_65.targs (PRE_first_tail_x15_r0_body.cwS65.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_65.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck65 : krecLB PRE_first_tail_x15_r0_body.kappa65 2833 PRE_first_tail_x15_r0_body.cx0_65.mlx PRE_first_tail_x15_r0_body.kr0_65 PRE_first_tail_x15_r0_body.kr1_65 PRE_first_tail_x15_r0_body.clo65 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn65 : Nat.ble 2833 2833 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge65 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s633.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s634.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR65 : pendRegB PRE_first_tail_x15_r0_body.kappa65 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s634.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe65 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s634.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s633.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift65 (clean : Conv.NClean (⟨19476, 16570, 2725587, 2833⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P65.NL) (cl : SSt (· < 2833) PRE_first_tail_x15_r0_body.cx0_65.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_65.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_65.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_65.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_65.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19476, 16570, 2725587, 2833⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P65 2833 PRE_first_tail_x15_r0_body.kappa65 PRE_first_tail_x15_r0_body.s634.ffi PRE_first_tail_x15_r0_body.s633.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift65 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue65, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp65 t ht),
    PRE_first_tail_x15_r0_body.cbridge65,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s634.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s633.ffi) (PRE_first_tail_x15_r0_body.cfoot65 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_65 PRE_first_tail_x15_r0_body.ofx1_65 hobjC PRE_first_tail_x15_r0_body.ff065 PRE_first_tail_x15_r0_body.ff165 PRE_first_tail_x15_r0_body.ffck65,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s634.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s633.ffi) (PRE_first_tail_x15_r0_body.cfoot65 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_65 PRE_first_tail_x15_r0_body.okr1_65 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn65) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf065 PRE_first_tail_x15_r0_body.fkt065 PRE_first_tail_x15_r0_body.fkf165 PRE_first_tail_x15_r0_body.fkt165 PRE_first_tail_x15_r0_body.fkck65,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh065 PRE_first_tail_x15_r0_body.cnh165 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe65) PRE_first_tail_x15_r0_body.cpendR65⟩

end Host.Load.Run.Tpl
end

section -- st65/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st65 0
host_stream_state PRE_first_tail_x15_r0_body.st65 1
host_stream_state PRE_first_tail_x15_r0_body.st65 2
end Host.Load.Run.Tpl
end

section -- Site65
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 65 of chain `PRE_first_tail_x15_r0_body`: `plan__g65__g66` (`plan`), the call state `PRE_first_tail_x15_r0_body.s632`, the merged state `PRE_first_tail_x15_r0_body.s633`,
the site template `PRE_first_tail_x15_r0_body.st65` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s634`: the merge.
The footprint's facts are in `SiteF65`, the compaction's in `SiteC65`, `SiteK65`, `SiteNa65`, `SiteNb65`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso65 : PRE_first_tail_x15_r0_body.st65.s0 = { PRE_first_tail_x15_r0_body.s632 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs65 : List Frame := PRE_first_tail_x15_r0_body.s632.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_65 : PRE_first_tail_x15_r0_body.S632.tab.length = 2833
kernel_rfl PRE_first_tail_x15_r0_body.tab0_65 : PRE_first_tail_x15_r0_body.st65.S0.tab = PRE_first_tail_x15_r0_body.S632.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws65 : List Nat := [2112, 2113, 2114]
kernel_rfl PRE_first_tail_x15_r0_body.fresh65 : (PRE_first_tail_x15_r0_body.S632.tab.all fun e => PRE_first_tail_x15_r0_body.ws65.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S632.oracle.all fun q => PRE_first_tail_x15_r0_body.ws65.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab65 : PRE_first_tail_x15_r0_body.S633.tab = PRE_first_tail_x15_r0_body.S632.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws65
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen65 : PRE_first_tail_x15_r0_body.st65.S2.tab.length - PRE_first_tail_x15_r0_body.st65.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged65`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap65 : PRE_first_tail_x15_r0_body.s633.heap = PRE_first_tail_x15_r0_body.st65.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext65 : PRE_first_tail_x15_r0_body.s633.next = PRE_first_tail_x15_r0_body.st65.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl65 : PRE_first_tail_x15_r0_body.s633.ctl = PRE_first_tail_x15_r0_body.st65.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack65 : PRE_first_tail_x15_r0_body.s633.stack = PRE_first_tail_x15_r0_body.st65.s2.stack ++ PRE_first_tail_x15_r0_body.s632.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs65 : PRE_first_tail_x15_r0_body.s633.jobs = PRE_first_tail_x15_r0_body.st65.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi65 : PRE_first_tail_x15_r0_body.s633.ffi = PRE_first_tail_x15_r0_body.st65.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace65 : PRE_first_tail_x15_r0_body.s633.trace = PRE_first_tail_x15_r0_body.st65.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores65 : PRE_first_tail_x15_r0_body.s633.stores = PRE_first_tail_x15_r0_body.st65.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD65
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 65 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived65 : PRE_first_tail_x15_r0_body.nr65.map (fun r => nth? PRE_first_tail_x15_r0_body.st65.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo65 : PRE_first_tail_x15_r0_body.nr65.all (Nat.ble 2833) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj65 : PRE_first_tail_x15_r0_body.cws65.all (fun c => !PRE_first_tail_x15_r0_body.ws65.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ65 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws65 PRE_first_tail_x15_r0_body.crs65 PRE_first_tail_x15_r0_body.ws65

end Host.Load.Run.Tpl
end

section -- st65/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st65`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st65.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st65.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st65.s2.heap PRE_first_tail_x15_r0_body.st65.wrR ++ freshOf PRE_first_tail_x15_r0_body.st65.s2.heap PRE_first_tail_x15_r0_body.st65.s0.next PRE_first_tail_x15_r0_body.st65.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st65.wr : List Nat := PRE_first_tail_x15_r0_body.st65.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st65.heapFoot : PRE_first_tail_x15_r0_body.st65.s2.heap = setAll PRE_first_tail_x15_r0_body.st65.s0.heap PRE_first_tail_x15_r0_body.st65.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st65.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st65.s0.next PRE_first_tail_x15_r0_body.st65.s2.next = true
theorem PRE_first_tail_x15_r0_body.st65.grows : PRE_first_tail_x15_r0_body.st65.s0.next ≤ PRE_first_tail_x15_r0_body.st65.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st65.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st65.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st65.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st65.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st65.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st65.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st65.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st65.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st65.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st65.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st65.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st65.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st65.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st65.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st65.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st65.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st65.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st65.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st65.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st65.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st65.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st65.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st65.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st65.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st65.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st65.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st65.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st65.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st65.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st65.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st65.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st65.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF65
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 65 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB65 : nodupT PRE_first_tail_x15_r0_body.st65.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup65 : PRE_first_tail_x15_r0_body.st65.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB65).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB65 : PRE_first_tail_x15_r0_body.st65.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound65 : ∀ b ∈ PRE_first_tail_x15_r0_body.st65.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB65 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr65 := PRE_first_tail_x15_r0_body.st65.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq65 : PRE_first_tail_x15_r0_body.st65.s2.trace = PRE_first_tail_x15_r0_body.trFr65 ++ PRE_first_tail_x15_r0_body.st65.s0.trace
theorem PRE_first_tail_x15_r0_body.trace65 : ∃ fr, PRE_first_tail_x15_r0_body.st65.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st65.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq65⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide65 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB65 : (PRE_first_tail_x15_r0_body.wide65.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st65.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix65 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide65, WFix Map.id (Present PRE_first_tail_x15_r0_body.st65.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB65 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL65
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 65 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s633`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO65 : PRE_first_tail_x15_r0_body.st65.S0.oracle = PRE_first_tail_x15_r0_body.st65.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B65 : PRE_first_tail_x15_r0_body.st65.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st65.s0.next || (PRE_first_tail_x15_r0_body.st65.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot65 : Conv.StageFoot PRE_first_tail_x15_r0_body.st65.wr PRE_first_tail_x15_r0_body.st65.s0 PRE_first_tail_x15_r0_body.st65.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st65.heapFoot PRE_first_tail_x15_r0_body.wrNodup65 PRE_first_tail_x15_r0_body.wrBound65 PRE_first_tail_x15_r0_body.wr0B65 PRE_first_tail_x15_r0_body.st65.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged65 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st65.F.S → PRE_first_tail_x15_r0_body.st65.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st65.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st65.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs65 PRE_first_tail_x15_r0_body.st65.wr PRE_first_tail_x15_r0_body.s632 PRE_first_tail_x15_r0_body.st65.s2 PRE_first_tail_x15_r0_body.st65.s0
      PRE_first_tail_x15_r0_body.st65.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st65.F FR W stk M ν K PRE_first_tail_x15_r0_body.s633 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso65 PRE_first_tail_x15_r0_body.stFoot65 PRE_first_tail_x15_r0_body.wrNodup65 PRE_first_tail_x15_r0_body.wrBound65 PRE_first_tail_x15_r0_body.trace65 PRE_first_tail_x15_r0_body.mheap65
    PRE_first_tail_x15_r0_body.mnext65 PRE_first_tail_x15_r0_body.mctl65 PRE_first_tail_x15_r0_body.mstack65 PRE_first_tail_x15_r0_body.mjobs65 PRE_first_tail_x15_r0_body.mffi65 PRE_first_tail_x15_r0_body.mtrace65 PRE_first_tail_x15_r0_body.mstores65 h

def PRE_first_tail_x15_r0_body.arrEl65_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE65_2665 : arrOf PRE_first_tail_x15_r0_body.s633 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl65_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA65_2665 : isArrB PRE_first_tail_x15_r0_body.s633 2665 = true
theorem PRE_first_tail_x15_r0_body.arr65_2665 : ∃ o, PRE_first_tail_x15_r0_body.s633.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl65_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE65_2665 PRE_first_tail_x15_r0_body.arrA65_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN65_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl65_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR65_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl65_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN65_2665

def PRE_first_tail_x15_r0_body.arrEl65_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE65_2673467 : arrOf PRE_first_tail_x15_r0_body.s633 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl65_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA65_2673467 : isArrB PRE_first_tail_x15_r0_body.s633 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr65_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s633.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl65_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE65_2673467 PRE_first_tail_x15_r0_body.arrA65_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN65_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl65_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR65_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl65_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN65_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k65 : isArrB PRE_first_tail_x15_r0_body.s633 4910 = false
theorem PRE_first_tail_x15_r0_body.keep65 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s633 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k65 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr65_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl65_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ65
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 65 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s632`, the merged
state `PRE_first_tail_x15_r0_body.s633`, the canonical state `PRE_first_tail_x15_r0_body.s634`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl65 : PRE_first_tail_x15_r0_body.pl65.all (Nat.ble PRE_first_tail_x15_r0_body.s632.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd65 : nodupT PRE_first_tail_x15_r0_body.pl65 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn165 : Nat.ble PRE_first_tail_x15_r0_body.s632.next 2725598 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst65 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s632.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn65 : PRE_first_tail_x15_r0_body.s634.next = PRE_first_tail_x15_r0_body.s632.next + PRE_first_tail_x15_r0_body.pl65.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn65 : PRE_first_tail_x15_r0_body.s633.next = 2725598
kernel_rfl PRE_first_tail_x15_r0_body.zgrow65 : Nat.ble PRE_first_tail_x15_r0_body.s634.next PRE_first_tail_x15_r0_body.s633.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh65 : PRE_first_tail_x15_r0_body.S632.tab.all (fun e => PRE_first_tail_x15_r0_body.cws65.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd65 : nodupT PRE_first_tail_x15_r0_body.cws65 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi65 : PRE_first_tail_x15_r0_body.nr65.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S633.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt65 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s632.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg65_2665 : PRE_first_tail_x15_r0_body.s634.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s634 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk65_2665 : (objOf PRE_first_tail_x15_r0_body.s634 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm65_2665 : PRE_first_tail_x15_r0_body.s633.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa65.obj (objOf PRE_first_tail_x15_r0_body.s634 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s633 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg65_2673467 : PRE_first_tail_x15_r0_body.s634.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s634 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk65_2673467 : (objOf PRE_first_tail_x15_r0_body.s634 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm65_2673467 : PRE_first_tail_x15_r0_body.s633.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa65.obj (objOf PRE_first_tail_x15_r0_body.s634 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s633 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw65_4910 : (PRE_first_tail_x15_r0_body.s634.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw65_2673472 : (PRE_first_tail_x15_r0_body.s634.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw65_2673473 : (PRE_first_tail_x15_r0_body.s634.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd65 : PRE_first_tail_x15_r0_body.cl65.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr65 : PRE_first_tail_x15_r0_body.st65.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s632.next || PRE_first_tail_x15_r0_body.cl65.contains b) = true
def PRE_first_tail_x15_r0_body.zl65 : List Nat := PRE_first_tail_x15_r0_body.cl65.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE65 : PRE_first_tail_x15_r0_body.zl65.map (fun a => PRE_first_tail_x15_r0_body.s633.heap.get (PRE_first_tail_x15_r0_body.kappa65.a a)) = PRE_first_tail_x15_r0_body.zl65.map (fun a => (PRE_first_tail_x15_r0_body.s634.heap.get a).map PRE_first_tail_x15_r0_body.kappa65.hobj)
theorem PRE_first_tail_x15_r0_body.zimg65 : HeapImg PRE_first_tail_x15_r0_body.kappa65 PRE_first_tail_x15_r0_body.s634 PRE_first_tail_x15_r0_body.s633 PRE_first_tail_x15_r0_body.zl65 := PRE_first_tail_x15_r0_body.zimgE65
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl65 : PRE_first_tail_x15_r0_body.s633.ctl = PRE_first_tail_x15_r0_body.kappa65.ctl PRE_first_tail_x15_r0_body.s634.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack65 : PRE_first_tail_x15_r0_body.s633.stack = PRE_first_tail_x15_r0_body.s634.stack.map PRE_first_tail_x15_r0_body.kappa65.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs65 : PRE_first_tail_x15_r0_body.s633.jobs = PRE_first_tail_x15_r0_body.s634.jobs.map PRE_first_tail_x15_r0_body.kappa65.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores65 : PRE_first_tail_x15_r0_body.s633.stores = PRE_first_tail_x15_r0_body.kappa65.stores PRE_first_tail_x15_r0_body.s634.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots65 : checkRootsSupp PRE_first_tail_x15_r0_body.s634 2833 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC65 : PRE_first_tail_x15_r0_body.S632.tab.length + PRE_first_tail_x15_r0_body.cws65.length = 2833
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap65 : PRE_first_tail_x15_r0_body.kappa65 = Conv.Map.compact PRE_first_tail_x15_r0_body.s632.next 2725598 PRE_first_tail_x15_r0_body.S632.tab.length PRE_first_tail_x15_r0_body.pl65 (PRE_first_tail_x15_r0_body.nr65.map NumV.ref) PRE_first_tail_x15_r0_body.kd65.big
  PRE_first_tail_x15_r0_body.kd65.region PRE_first_tail_x15_r0_body.kd65.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin65 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s634.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc65 : Conv.jcleanListB (⟨19476, 16570, 2725588, 2833⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s634 PRE_first_tail_x15_r0_body.cl65 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB65 : noBigRootsP (fun i => !Conv.oldBigB (⟨19476, 16570, 2725588, 2833⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s634.trace PRE_first_tail_x15_r0_body.s634 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm65 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16570 = true
theorem PRE_first_tail_x15_r0_body.cjcl65 (h : Conv.JClean (⟨19476, 16570, 2725587, 2833⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s632) : Conv.JClean (⟨19476, 16570, 2725588, 2833⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s634 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle65)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap65 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd65 a ha)) PRE_first_tail_x15_r0_body.zjc65

end Host.Load.Run.Tpl
end

section -- st65/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st65.bodyLast from PRE_first_tail_x15_r0_body.st65.s1 to PRE_first_tail_x15_r0_body.st65.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st65.F PRE_first_tail_x15_r0_body.st65.s1).run PRE_first_tail_x15_r0_body.st65.S1 = some (PRE_first_tail_x15_r0_body.st65.s2, PRE_first_tail_x15_r0_body.st65.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st65.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st65.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st65.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st65.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st65/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st65.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st65.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st65.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st65.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st65.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st65.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st65.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st65.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st65.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st65.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st65.s0 PRE_first_tail_x15_r0_body.st65.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st65.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st65.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st65.s1 PRE_first_tail_x15_r0_body.st65.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

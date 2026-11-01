import host.sim.template.a4pre_first_tail_x15_r0_body.m.B26
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

section -- st120/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st120.bodyK2F from PRE_first_tail_x15_r0_body.st120.s2 to PRE_first_tail_x15_r0_body.st120.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st120.F (PRE_first_tail_x15_r0_body.st120.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st120.ks 2).getD 0) PRE_first_tail_x15_r0_body.st120.s2 PRE_first_tail_x15_r0_body.st120.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st120.s3, PRE_first_tail_x15_r0_body.st120.S3)
theorem PRE_first_tail_x15_r0_body.st120.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st120.F (PRE_first_tail_x15_r0_body.st120.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st120.ks 2).getD 0) PRE_first_tail_x15_r0_body.st120.s2 PRE_first_tail_x15_r0_body.st120.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st120.s3, PRE_first_tail_x15_r0_body.st120.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st120.bodyOkLN_ok PRE_first_tail_x15_r0_body.st120.bodyK2F
end Host.Load.Run.Tpl
end

section -- st120/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st120.bodyK3F from PRE_first_tail_x15_r0_body.st120.s3 to PRE_first_tail_x15_r0_body.st120.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st120.F (PRE_first_tail_x15_r0_body.st120.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st120.ks 3).getD 0) PRE_first_tail_x15_r0_body.st120.s3 PRE_first_tail_x15_r0_body.st120.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st120.s4, PRE_first_tail_x15_r0_body.st120.S4)
theorem PRE_first_tail_x15_r0_body.st120.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st120.F (PRE_first_tail_x15_r0_body.st120.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st120.ks 3).getD 0) PRE_first_tail_x15_r0_body.st120.s3 PRE_first_tail_x15_r0_body.st120.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st120.s4, PRE_first_tail_x15_r0_body.st120.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st120.bodyOkLN_ok PRE_first_tail_x15_r0_body.st120.bodyK3F
end Host.Load.Run.Tpl
end

section -- st120/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st120.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st120.F (PRE_first_tail_x15_r0_body.st120.bodyOkL bytes rows) 11334 PRE_first_tail_x15_r0_body.st120.s0 PRE_first_tail_x15_r0_body.st120.S0 = some (PRE_first_tail_x15_r0_body.st120.s4, PRE_first_tail_x15_r0_body.st120.S4) :=
  runOk_trans PRE_first_tail_x15_r0_body.st120.F (PRE_first_tail_x15_r0_body.st120.bodyOkL bytes rows) ((((nth? PRE_first_tail_x15_r0_body.st120.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st120.ks 1).getD 0)) + ((nth? PRE_first_tail_x15_r0_body.st120.ks 2).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st120.ks 3).getD 0) PRE_first_tail_x15_r0_body.st120.s0 PRE_first_tail_x15_r0_body.st120.s3 PRE_first_tail_x15_r0_body.st120.s4 PRE_first_tail_x15_r0_body.st120.S0 PRE_first_tail_x15_r0_body.st120.S3 PRE_first_tail_x15_r0_body.st120.S4 (runOk_trans PRE_first_tail_x15_r0_body.st120.F (PRE_first_tail_x15_r0_body.st120.bodyOkL bytes rows) (((nth? PRE_first_tail_x15_r0_body.st120.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st120.ks 1).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st120.ks 2).getD 0) PRE_first_tail_x15_r0_body.st120.s0 PRE_first_tail_x15_r0_body.st120.s2 PRE_first_tail_x15_r0_body.st120.s3 PRE_first_tail_x15_r0_body.st120.S0 PRE_first_tail_x15_r0_body.st120.S2 PRE_first_tail_x15_r0_body.st120.S3 (runOk_trans PRE_first_tail_x15_r0_body.st120.F (PRE_first_tail_x15_r0_body.st120.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st120.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st120.ks 1).getD 0) PRE_first_tail_x15_r0_body.st120.s0 PRE_first_tail_x15_r0_body.st120.s1 PRE_first_tail_x15_r0_body.st120.s2 PRE_first_tail_x15_r0_body.st120.S0 PRE_first_tail_x15_r0_body.st120.S1 PRE_first_tail_x15_r0_body.st120.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st120.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st120.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st120.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st120.bodyK3 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st120.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st120.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st120.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st120.F (PRE_first_tail_x15_r0_body.st120.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st120.s0
  S0 := PRE_first_tail_x15_r0_body.st120.S0
  s1 := PRE_first_tail_x15_r0_body.st120.s4
  S1 := PRE_first_tail_x15_r0_body.st120.S4
  s2 := PRE_first_tail_x15_r0_body.st120.s5
  S2 := PRE_first_tail_x15_r0_body.st120.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st120.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st120.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st120.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st120.bodyHalt
  last := PRE_first_tail_x15_r0_body.st120.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st120.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC121
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 121 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1176` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa121` into the merged state
`PRE_first_tail_x15_r0_body.s1175`. -/

def PRE_first_tail_x15_r0_body.pl121 : List Nat := []
def PRE_first_tail_x15_r0_body.nr121 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd121 : RData :=
  ⟨2770119, 2770121, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20592, 20592, 17688, 17688, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa121 : Map :=
  Conv.Map.compact 2770119 2770121 5252 PRE_first_tail_x15_r0_body.pl121 (PRE_first_tail_x15_r0_body.nr121.map NumV.ref) PRE_first_tail_x15_r0_body.kd121.big
    PRE_first_tail_x15_r0_body.kd121.region PRE_first_tail_x15_r0_body.kd121.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws121 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs121 : List SymE := PRE_first_tail_x15_r0_body.nr121.map fun r => (nth? PRE_first_tail_x15_r0_body.S1175.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta121 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws121 PRE_first_tail_x15_r0_body.crs121
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB121 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab121 : PRE_first_tail_x15_r0_body.S1176.tab = PRE_first_tail_x15_r0_body.S1174.tab ++ PRE_first_tail_x15_r0_body.cws121.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace121 : PRE_first_tail_x15_r0_body.s1176.trace = PRE_first_tail_x15_r0_body.s1174.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext121 : PRE_first_tail_x15_r0_body.s1176.next = 2770119
kernel_rfl PRE_first_tail_x15_r0_body.ccounters121 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1176.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1176.ffi).mlx.nnext) = (20592, 17688)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue121 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1175.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1176.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa121.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp121 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1176.ffi).mlx.tokens.all (bSN 5252) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean121 : Conv.cleanListB 20592 131072 (fun r => Nat.ble 82368 r) PRE_first_tail_x15_r0_body.s1176
    (PRE_first_tail_x15_r0_body.wrB121 ++ (List.range 0).map (2770119 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs121 : bigsOutB 20592 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1176.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK121
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl121`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl121 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo121 : List Nat := []
def PRE_first_tail_x15_r0_body.cln121 : List Nat := []
def PRE_first_tail_x15_r0_body.cli121 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap121 : PRE_first_tail_x15_r0_body.s1176.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1174.heap (PRE_first_tail_x15_r0_body.cl121.filterMap fun a => (PRE_first_tail_x15_r0_body.s1176.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe121 : Nat.ble PRE_first_tail_x15_r0_body.s1174.next PRE_first_tail_x15_r0_body.s1176.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP121 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1174 PRE_first_tail_x15_r0_body.s1176 PRE_first_tail_x15_r0_body.cl121 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp121 : Conv.suppListB PRE_first_tail_x15_r0_body.s1176 5252 PRE_first_tail_x15_r0_body.cl121 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound121 : Conv.boundListB PRE_first_tail_x15_r0_body.s1176 PRE_first_tail_x15_r0_body.cl121 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK121 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1176.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln121.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1176.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK121 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1176.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo121.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1176.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK121 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1176.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli121.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1176.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst121 : Conv.sstListB 5252 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1176.ffi).mlx PRE_first_tail_x15_r0_body.cln121 PRE_first_tail_x15_r0_body.clo121 PRE_first_tail_x15_r0_body.cli121 = true

end Host.Load.Run.Tpl
end

section -- SiteCl121
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA121 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1176.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo121.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1176.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd121 : (PRE_first_tail_x15_r0_body.clo121 ++ PRE_first_tail_x15_r0_body.cln121 ++ PRE_first_tail_x15_r0_body.cli121).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle121 : Conv.Cnt.leB (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck121 : Conv.ncleanListB (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1176.ffi).mlx PRE_first_tail_x15_r0_body.clo121 PRE_first_tail_x15_r0_body.cln121 PRE_first_tail_x15_r0_body.cli121 = true
theorem PRE_first_tail_x15_r0_body.cncl121 (h : Conv.NClean (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx) : Conv.NClean (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1176.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle121 PRE_first_tail_x15_r0_body.ckA121 PRE_first_tail_x15_r0_body.cobjsK121 PRE_first_tail_x15_r0_body.cnodesK121 PRE_first_tail_x15_r0_body.citemsK121 PRE_first_tail_x15_r0_body.cbd121 PRE_first_tail_x15_r0_body.cck121

end Host.Load.Run.Tpl
end

section -- SiteS121
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 121 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc121 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P121 : LoadP := PRE_first_tail_x15_r0_body.Pc121.raise 17688
kernel_rfl PRE_first_tail_x15_r0_body.craise121 : Nat.ble PRE_first_tail_x15_r0_body.Pc121.N0 17688 = true
theorem PRE_first_tail_x15_r0_body.raised121 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc121 PRE_first_tail_x15_r0_body.P121 :=
  .inr ⟨17688, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise121, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_121 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1176.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_121 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1175.ffi)
def PRE_first_tail_x15_r0_body.khinv121 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv121 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS121 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS121 : List Nat := List.range' 17688 0
def PRE_first_tail_x15_r0_body.ciS121 : List Nat := [] ++ List.range' 17688 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0121 : PRE_first_tail_x15_r0_body.kd121.nh0 = PRE_first_tail_x15_r0_body.cx0_121.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1121 : PRE_first_tail_x15_r0_body.kd121.nh1 = PRE_first_tail_x15_r0_body.cx1_121.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0121 : PRE_first_tail_x15_r0_body.kd121.nn0 = PRE_first_tail_x15_r0_body.cx0_121.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1121 : PRE_first_tail_x15_r0_body.kd121.nn1 = PRE_first_tail_x15_r0_body.cx1_121.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo121 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P121.lo && Nat.ble PRE_first_tail_x15_r0_body.P121.lo PRE_first_tail_x15_r0_body.cx0_121.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P121.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P121.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt121 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_121.mlx.next PRE_first_tail_x15_r0_body.cx1_121.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_121.mlx.nnext PRE_first_tail_x15_r0_body.cx1_121.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband121 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P121.NL && Nat.ble PRE_first_tail_x15_r0_body.P121.NL PRE_first_tail_x15_r0_body.P121.N0 && Nat.ble PRE_first_tail_x15_r0_body.P121.N0 PRE_first_tail_x15_r0_body.cx0_121.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow121 : PRE_first_tail_x15_r0_body.kd121.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren121 : checkRenG PRE_first_tail_x15_r0_body.kd121.hnd PRE_first_tail_x15_r0_body.khinv121 (phB PRE_first_tail_x15_r0_body.cx0_121.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband121 : PRE_first_tail_x15_r0_body.kd121.checkBand PRE_first_tail_x15_r0_body.P121.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos121 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd121.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren121 : checkRenG PRE_first_tail_x15_r0_body.kd121.node PRE_first_tail_x15_r0_body.kninv121 (pnB PRE_first_tail_x15_r0_body.cx0_121.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow121 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd121.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P121.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd121.nodeF j) PRE_first_tail_x15_r0_body.cx1_121.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a121 : PRE_first_tail_x15_r0_body.cx0_121.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b121 : PRE_first_tail_x15_r0_body.cx0_121.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1121 : PRE_first_tail_x15_r0_body.cx1_121.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend121 : PRE_first_tail_x15_r0_body.cx1_121.mlx.pending = PRE_first_tail_x15_r0_body.cx0_121.mlx.pending.map PRE_first_tail_x15_r0_body.kappa121.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh121 : PRE_first_tail_x15_r0_body.cx1_121.mlx.errh = PRE_first_tail_x15_r0_body.cx0_121.mlx.errh.map PRE_first_tail_x15_r0_body.kappa121.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles121 : PRE_first_tail_x15_r0_body.cx1_121.mlx.files = PRE_first_tail_x15_r0_body.cx0_121.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch121 : PRE_first_tail_x15_r0_body.cx1_121.mlx.arch = PRE_first_tail_x15_r0_body.cx0_121.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes121 : PRE_first_tail_x15_r0_body.cx1_121.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_121.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired121 : PRE_first_tail_x15_r0_body.cx1_121.mlx.wired = PRE_first_tail_x15_r0_body.cx0_121.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost121 : PRE_first_tail_x15_r0_body.cx1_121.host = PRE_first_tail_x15_r0_body.cx0_121.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd121`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0121 : PRE_first_tail_x15_r0_body.kd121.n0 = 2770119
kernel_rfl PRE_first_tail_x15_r0_body.ckn1121 : PRE_first_tail_x15_r0_body.kd121.n1 = 2770121
kernel_rfl PRE_first_tail_x15_r0_body.ckheap121 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd121.heap).all (fun x => Nat.ble 2770119 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl121 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd121.heap.get (2770119 + j) = nth? PRE_first_tail_x15_r0_body.pl121 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja121 : Nat.ble 2770119 2770119 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn121 : Nat.ble 5252 5252 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD121 : Nat.ble 2770119 PRE_first_tail_x15_r0_body.kd121.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn121 : Nat.ble 20592 PRE_first_tail_x15_r0_body.kd121.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn121 : Nat.ble 17688 PRE_first_tail_x15_r0_body.kd121.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb121 : Nat.ble 20592 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap121 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd121.heap).all (Nat.ble (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd121 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd121.hnd).all (Nat.ble (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode121 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd121.node).all (Nat.ble (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix121 : Conv.FixOld (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa121 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja121) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn121) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD121) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn121) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn121) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb121) PRE_first_tail_x15_r0_body.fheap121 PRE_first_tail_x15_r0_body.fhnd121 PRE_first_tail_x15_r0_body.fnode121
kernel_rfl PRE_first_tail_x15_r0_body.fcxn121 : (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn121 : (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0121 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_121.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_121.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk121 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd121.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A121 : PRE_first_tail_x15_r0_body.cx1_121.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS121.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_121.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O121 : PRE_first_tail_x15_r0_body.cx1_121.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS121.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_121.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N121 : PRE_first_tail_x15_r0_body.cx1_121.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS121.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_121.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I121 : PRE_first_tail_x15_r0_body.cx1_121.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS121.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_121.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd121 : (PRE_first_tail_x15_r0_body.clo121 ++ PRE_first_tail_x15_r0_body.cln121 ++ PRE_first_tail_x15_r0_body.cli121 ++ PRE_first_tail_x15_r0_body.cwS121 ++ PRE_first_tail_x15_r0_body.cnS121 ++ PRE_first_tail_x15_r0_body.ciS121).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW121 : PRE_first_tail_x15_r0_body.cwS121.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo121.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI121 : PRE_first_tail_x15_r0_body.ciS121.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli121.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN121 : PRE_first_tail_x15_r0_body.cnS121.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF121 : PRE_first_tail_x15_r0_body.cln121.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh121 : PRE_first_tail_x15_r0_body.clo121.all (handleOK PRE_first_tail_x15_r0_body.kappa121 PRE_first_tail_x15_r0_body.P121.lo PRE_first_tail_x15_r0_body.cx0_121.mlx PRE_first_tail_x15_r0_body.cx1_121.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo121 : PRE_first_tail_x15_r0_body.clo121.map (fun h => PRE_first_tail_x15_r0_body.cx1_121.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa121.handle h)) = PRE_first_tail_x15_r0_body.clo121.map (fun h => (PRE_first_tail_x15_r0_body.cx0_121.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa121.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok121 : PRE_first_tail_x15_r0_body.clo121.all (objOK PRE_first_tail_x15_r0_body.kappa121 PRE_first_tail_x15_r0_body.P121.NL PRE_first_tail_x15_r0_body.cx0_121.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd121 : PRE_first_tail_x15_r0_body.cln121.all (nodeOKF PRE_first_tail_x15_r0_body.kappa121 PRE_first_tail_x15_r0_body.P121 PRE_first_tail_x15_r0_body.cx0_121.mlx PRE_first_tail_x15_r0_body.cx1_121.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp121 : ((PRE_first_tail_x15_r0_body.cln121.filter (fullB PRE_first_tail_x15_r0_body.P121))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_121.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa121.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln121.filter (fullB PRE_first_tail_x15_r0_body.P121))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_121.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa121.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI121 : incrB PRE_first_tail_x15_r0_body.kd121.nodeF (List.range' 17688 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK121 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd121.node).all (fun k => Nat.ble 17688 k && Nat.blt k 17688) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL121 : (PRE_first_tail_x15_r0_body.cln121.filter (Nat.ble PRE_first_tail_x15_r0_body.P121.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd121.nodeF i) && (Nat.blt i 17688 || Nat.ble PRE_first_tail_x15_r0_body.kd121.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord121 : (PRE_first_tail_x15_r0_body.cln121.filter (Nat.ble PRE_first_tail_x15_r0_body.P121.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd121.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd121.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd121.nodeF j) (PRE_first_tail_x15_r0_body.kd121.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow121 PRE_first_tail_x15_r0_body.cnn1121 PRE_first_tail_x15_r0_body.fnordI121 PRE_first_tail_x15_r0_body.fnordK121 PRE_first_tail_x15_r0_body.fnordL121
kernel_rfl PRE_first_tail_x15_r0_body.fi121 : PRE_first_tail_x15_r0_body.cli121.all (pnB PRE_first_tail_x15_r0_body.cx0_121.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii121 : PRE_first_tail_x15_r0_body.cli121.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_121.mlx.items.get (PRE_first_tail_x15_r0_body.kappa121.node k) = (PRE_first_tail_x15_r0_body.cx0_121.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa121.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot121 (clean : Conv.NClean (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P121.NL) (cl : SSt (· < 5252) PRE_first_tail_x15_r0_body.cx0_121.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P121 5252 PRE_first_tail_x15_r0_body.kappa121 PRE_first_tail_x15_r0_body.kd121 PRE_first_tail_x15_r0_body.khinv121 PRE_first_tail_x15_r0_body.kninv121 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx PRE_first_tail_x15_r0_body.cx0_121.mlx PRE_first_tail_x15_r0_body.cx1_121.mlx (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo121 PRE_first_tail_x15_r0_body.cln121 PRE_first_tail_x15_r0_body.cli121 PRE_first_tail_x15_r0_body.cwS121 PRE_first_tail_x15_r0_body.cnS121 PRE_first_tail_x15_r0_body.ciS121 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0121, PRE_first_tail_x15_r0_body.cnh1121, PRE_first_tail_x15_r0_body.cnn0121, PRE_first_tail_x15_r0_body.cnn1121, PRE_first_tail_x15_r0_body.cplo121, PRE_first_tail_x15_r0_body.ccnt121, PRE_first_tail_x15_r0_body.cnband121, PRE_first_tail_x15_r0_body.chbelow121, PRE_first_tail_x15_r0_body.chren121, PRE_first_tail_x15_r0_body.cband121, PRE_first_tail_x15_r0_body.cnh1pos121, PRE_first_tail_x15_r0_body.cnren121, PRE_first_tail_x15_r0_body.cnlow121, PRE_first_tail_x15_r0_body.cabs0a121, PRE_first_tail_x15_r0_body.cabs0b121, PRE_first_tail_x15_r0_body.ctok1121, PRE_first_tail_x15_r0_body.cpend121, PRE_first_tail_x15_r0_body.cerrh121, PRE_first_tail_x15_r0_body.cfiles121, PRE_first_tail_x15_r0_body.carch121, PRE_first_tail_x15_r0_body.csizes121, PRE_first_tail_x15_r0_body.cwired121, PRE_first_tail_x15_r0_body.cfix121, clean, PRE_first_tail_x15_r0_body.fcxn121, PRE_first_tail_x15_r0_body.fcnn121, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0121, PRE_first_tail_x15_r0_body.fnk121, PRE_first_tail_x15_r0_body.ckA121, PRE_first_tail_x15_r0_body.cobjsK121, PRE_first_tail_x15_r0_body.cnodesK121, PRE_first_tail_x15_r0_body.citemsK121, PRE_first_tail_x15_r0_body.f1A121, PRE_first_tail_x15_r0_body.f1O121, PRE_first_tail_x15_r0_body.f1N121, PRE_first_tail_x15_r0_body.f1I121, PRE_first_tail_x15_r0_body.fbd121, PRE_first_tail_x15_r0_body.fincW121, PRE_first_tail_x15_r0_body.fincI121, PRE_first_tail_x15_r0_body.fincN121, PRE_first_tail_x15_r0_body.flnF121, PRE_first_tail_x15_r0_body.fh121, PRE_first_tail_x15_r0_body.fo121, PRE_first_tail_x15_r0_body.fok121, PRE_first_tail_x15_r0_body.fnd121, PRE_first_tail_x15_r0_body.fp121, PRE_first_tail_x15_r0_body.fnord121, PRE_first_tail_x15_r0_body.fi121, PRE_first_tail_x15_r0_body.fii121⟩
theorem PRE_first_tail_x15_r0_body.cnshift121 (clean : Conv.NClean (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P121.NL) (cl : SSt (· < 5252) PRE_first_tail_x15_r0_body.cx0_121.mlx) : NShift PRE_first_tail_x15_r0_body.P121 5252 PRE_first_tail_x15_r0_body.kappa121 PRE_first_tail_x15_r0_body.cx0_121 PRE_first_tail_x15_r0_body.cx1_121 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot121 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost121 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0121 PRE_first_tail_x15_r0_body.ckn1121 PRE_first_tail_x15_r0_body.ckheap121 PRE_first_tail_x15_r0_body.ckpl121)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_121 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1174.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_121 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1174.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_121 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1174.ffi) = some PRE_first_tail_x15_r0_body.fxC_121
kernel_rfl PRE_first_tail_x15_r0_body.okrC_121 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1174.ffi) = some PRE_first_tail_x15_r0_body.krC_121
noncomputable def PRE_first_tail_x15_r0_body.fx0_121 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1176.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_121 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1176.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_121 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1176.ffi) = some PRE_first_tail_x15_r0_body.fx0_121
kernel_rfl PRE_first_tail_x15_r0_body.okr0_121 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1176.ffi) = some PRE_first_tail_x15_r0_body.kr0_121
noncomputable def PRE_first_tail_x15_r0_body.fx1_121 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1175.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_121 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1175.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_121 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1175.ffi) = some PRE_first_tail_x15_r0_body.fx1_121
kernel_rfl PRE_first_tail_x15_r0_body.okr1_121 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1175.ffi) = some PRE_first_tail_x15_r0_body.kr1_121
kernel_rfl PRE_first_tail_x15_r0_body.ff0121 : PRE_first_tail_x15_r0_body.fx0_121 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_121 (PRE_first_tail_x15_r0_body.clo121.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_121.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1121 : PRE_first_tail_x15_r0_body.fx1_121 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_121 (PRE_first_tail_x15_r0_body.cwS121.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_121.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck121 : freedLB PRE_first_tail_x15_r0_body.kappa121 PRE_first_tail_x15_r0_body.cx0_121.mlx PRE_first_tail_x15_r0_body.fx0_121 PRE_first_tail_x15_r0_body.fx1_121 PRE_first_tail_x15_r0_body.clo121 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0121 : PRE_first_tail_x15_r0_body.kr0_121.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_121.flags (PRE_first_tail_x15_r0_body.clo121.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_121.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0121 : PRE_first_tail_x15_r0_body.kr0_121.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_121.targs (PRE_first_tail_x15_r0_body.clo121.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_121.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1121 : PRE_first_tail_x15_r0_body.kr1_121.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_121.flags (PRE_first_tail_x15_r0_body.cwS121.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_121.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1121 : PRE_first_tail_x15_r0_body.kr1_121.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_121.targs (PRE_first_tail_x15_r0_body.cwS121.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_121.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck121 : krecLB PRE_first_tail_x15_r0_body.kappa121 5252 PRE_first_tail_x15_r0_body.cx0_121.mlx PRE_first_tail_x15_r0_body.kr0_121 PRE_first_tail_x15_r0_body.kr1_121 PRE_first_tail_x15_r0_body.clo121 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn121 : Nat.ble 5252 5252 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge121 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1175.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1176.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR121 : pendRegB PRE_first_tail_x15_r0_body.kappa121 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1176.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe121 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1176.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1175.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift121 (clean : Conv.NClean (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P121.NL) (cl : SSt (· < 5252) PRE_first_tail_x15_r0_body.cx0_121.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_121.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_121.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_121.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_121.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P121 5252 PRE_first_tail_x15_r0_body.kappa121 PRE_first_tail_x15_r0_body.s1176.ffi PRE_first_tail_x15_r0_body.s1175.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift121 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue121, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp121 t ht),
    PRE_first_tail_x15_r0_body.cbridge121,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1176.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1175.ffi) (PRE_first_tail_x15_r0_body.cfoot121 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_121 PRE_first_tail_x15_r0_body.ofx1_121 hobjC PRE_first_tail_x15_r0_body.ff0121 PRE_first_tail_x15_r0_body.ff1121 PRE_first_tail_x15_r0_body.ffck121,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1176.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1175.ffi) (PRE_first_tail_x15_r0_body.cfoot121 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_121 PRE_first_tail_x15_r0_body.okr1_121 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn121) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0121 PRE_first_tail_x15_r0_body.fkt0121 PRE_first_tail_x15_r0_body.fkf1121 PRE_first_tail_x15_r0_body.fkt1121 PRE_first_tail_x15_r0_body.fkck121,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0121 PRE_first_tail_x15_r0_body.cnh1121 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe121) PRE_first_tail_x15_r0_body.cpendR121⟩

end Host.Load.Run.Tpl
end

section -- st121/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st121 0
host_stream_state PRE_first_tail_x15_r0_body.st121 1
host_stream_state PRE_first_tail_x15_r0_body.st121 2
end Host.Load.Run.Tpl
end

section -- Site121
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 121 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g121__g122` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1174`, the merged state `PRE_first_tail_x15_r0_body.s1175`,
the site template `PRE_first_tail_x15_r0_body.st121` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1176`: the merge.
The footprint's facts are in `SiteF121`, the compaction's in `SiteC121`, `SiteK121`, `SiteNa121`, `SiteNb121`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso121 : PRE_first_tail_x15_r0_body.st121.s0 = { PRE_first_tail_x15_r0_body.s1174 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs121 : List Frame := PRE_first_tail_x15_r0_body.s1174.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_121 : PRE_first_tail_x15_r0_body.S1174.tab.length = 5252
kernel_rfl PRE_first_tail_x15_r0_body.tab0_121 : PRE_first_tail_x15_r0_body.st121.S0.tab = PRE_first_tail_x15_r0_body.S1174.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws121 : List Nat := [3045, 3046]
kernel_rfl PRE_first_tail_x15_r0_body.fresh121 : (PRE_first_tail_x15_r0_body.S1174.tab.all fun e => PRE_first_tail_x15_r0_body.ws121.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1174.oracle.all fun q => PRE_first_tail_x15_r0_body.ws121.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab121 : PRE_first_tail_x15_r0_body.S1175.tab = PRE_first_tail_x15_r0_body.S1174.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws121
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen121 : PRE_first_tail_x15_r0_body.st121.S2.tab.length - PRE_first_tail_x15_r0_body.st121.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged121`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap121 : PRE_first_tail_x15_r0_body.s1175.heap = PRE_first_tail_x15_r0_body.st121.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext121 : PRE_first_tail_x15_r0_body.s1175.next = PRE_first_tail_x15_r0_body.st121.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl121 : PRE_first_tail_x15_r0_body.s1175.ctl = PRE_first_tail_x15_r0_body.st121.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack121 : PRE_first_tail_x15_r0_body.s1175.stack = PRE_first_tail_x15_r0_body.st121.s2.stack ++ PRE_first_tail_x15_r0_body.s1174.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs121 : PRE_first_tail_x15_r0_body.s1175.jobs = PRE_first_tail_x15_r0_body.st121.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi121 : PRE_first_tail_x15_r0_body.s1175.ffi = PRE_first_tail_x15_r0_body.st121.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace121 : PRE_first_tail_x15_r0_body.s1175.trace = PRE_first_tail_x15_r0_body.st121.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores121 : PRE_first_tail_x15_r0_body.s1175.stores = PRE_first_tail_x15_r0_body.st121.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD121
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 121 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived121 : PRE_first_tail_x15_r0_body.nr121.map (fun r => nth? PRE_first_tail_x15_r0_body.st121.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo121 : PRE_first_tail_x15_r0_body.nr121.all (Nat.ble 5252) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj121 : PRE_first_tail_x15_r0_body.cws121.all (fun c => !PRE_first_tail_x15_r0_body.ws121.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ121 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws121 PRE_first_tail_x15_r0_body.crs121 PRE_first_tail_x15_r0_body.ws121

end Host.Load.Run.Tpl
end

section -- st121/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st121`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st121.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st121.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st121.s2.heap PRE_first_tail_x15_r0_body.st121.wrR ++ freshOf PRE_first_tail_x15_r0_body.st121.s2.heap PRE_first_tail_x15_r0_body.st121.s0.next PRE_first_tail_x15_r0_body.st121.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st121.wr : List Nat := PRE_first_tail_x15_r0_body.st121.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st121.heapFoot : PRE_first_tail_x15_r0_body.st121.s2.heap = setAll PRE_first_tail_x15_r0_body.st121.s0.heap PRE_first_tail_x15_r0_body.st121.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st121.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st121.s0.next PRE_first_tail_x15_r0_body.st121.s2.next = true
theorem PRE_first_tail_x15_r0_body.st121.grows : PRE_first_tail_x15_r0_body.st121.s0.next ≤ PRE_first_tail_x15_r0_body.st121.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st121.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st121.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st121.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st121.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st121.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st121.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st121.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st121.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st121.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st121.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st121.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st121.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st121.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st121.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st121.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st121.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st121.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st121.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st121.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st121.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st121.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st121.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st121.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st121.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st121.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st121.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st121.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st121.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st121.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st121.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st121.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st121.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF121
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 121 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB121 : nodupT PRE_first_tail_x15_r0_body.st121.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup121 : PRE_first_tail_x15_r0_body.st121.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB121).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB121 : PRE_first_tail_x15_r0_body.st121.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound121 : ∀ b ∈ PRE_first_tail_x15_r0_body.st121.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB121 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr121 := PRE_first_tail_x15_r0_body.st121.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq121 : PRE_first_tail_x15_r0_body.st121.s2.trace = PRE_first_tail_x15_r0_body.trFr121 ++ PRE_first_tail_x15_r0_body.st121.s0.trace
theorem PRE_first_tail_x15_r0_body.trace121 : ∃ fr, PRE_first_tail_x15_r0_body.st121.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st121.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq121⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide121 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB121 : (PRE_first_tail_x15_r0_body.wide121.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st121.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix121 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide121, WFix Map.id (Present PRE_first_tail_x15_r0_body.st121.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB121 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL121
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 121 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1175`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO121 : PRE_first_tail_x15_r0_body.st121.S0.oracle = PRE_first_tail_x15_r0_body.st121.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B121 : PRE_first_tail_x15_r0_body.st121.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st121.s0.next || (PRE_first_tail_x15_r0_body.st121.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot121 : Conv.StageFoot PRE_first_tail_x15_r0_body.st121.wr PRE_first_tail_x15_r0_body.st121.s0 PRE_first_tail_x15_r0_body.st121.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st121.heapFoot PRE_first_tail_x15_r0_body.wrNodup121 PRE_first_tail_x15_r0_body.wrBound121 PRE_first_tail_x15_r0_body.wr0B121 PRE_first_tail_x15_r0_body.st121.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged121 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st121.F.S → PRE_first_tail_x15_r0_body.st121.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st121.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st121.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs121 PRE_first_tail_x15_r0_body.st121.wr PRE_first_tail_x15_r0_body.s1174 PRE_first_tail_x15_r0_body.st121.s2 PRE_first_tail_x15_r0_body.st121.s0
      PRE_first_tail_x15_r0_body.st121.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st121.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1175 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso121 PRE_first_tail_x15_r0_body.stFoot121 PRE_first_tail_x15_r0_body.wrNodup121 PRE_first_tail_x15_r0_body.wrBound121 PRE_first_tail_x15_r0_body.trace121 PRE_first_tail_x15_r0_body.mheap121
    PRE_first_tail_x15_r0_body.mnext121 PRE_first_tail_x15_r0_body.mctl121 PRE_first_tail_x15_r0_body.mstack121 PRE_first_tail_x15_r0_body.mjobs121 PRE_first_tail_x15_r0_body.mffi121 PRE_first_tail_x15_r0_body.mtrace121 PRE_first_tail_x15_r0_body.mstores121 h

def PRE_first_tail_x15_r0_body.arrEl121_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE121_2665 : arrOf PRE_first_tail_x15_r0_body.s1175 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl121_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA121_2665 : isArrB PRE_first_tail_x15_r0_body.s1175 2665 = true
theorem PRE_first_tail_x15_r0_body.arr121_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1175.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl121_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE121_2665 PRE_first_tail_x15_r0_body.arrA121_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN121_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl121_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR121_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl121_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN121_2665

def PRE_first_tail_x15_r0_body.arrEl121_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE121_2673467 : arrOf PRE_first_tail_x15_r0_body.s1175 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl121_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA121_2673467 : isArrB PRE_first_tail_x15_r0_body.s1175 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr121_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1175.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl121_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE121_2673467 PRE_first_tail_x15_r0_body.arrA121_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN121_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl121_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR121_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl121_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN121_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k121 : isArrB PRE_first_tail_x15_r0_body.s1175 4910 = false
theorem PRE_first_tail_x15_r0_body.keep121 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1175 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k121 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr121_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl121_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ121
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 121 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1174`, the merged
state `PRE_first_tail_x15_r0_body.s1175`, the canonical state `PRE_first_tail_x15_r0_body.s1176`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl121 : PRE_first_tail_x15_r0_body.pl121.all (Nat.ble PRE_first_tail_x15_r0_body.s1174.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd121 : nodupT PRE_first_tail_x15_r0_body.pl121 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1121 : Nat.ble PRE_first_tail_x15_r0_body.s1174.next 2770121 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst121 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1174.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn121 : PRE_first_tail_x15_r0_body.s1176.next = PRE_first_tail_x15_r0_body.s1174.next + PRE_first_tail_x15_r0_body.pl121.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn121 : PRE_first_tail_x15_r0_body.s1175.next = 2770121
kernel_rfl PRE_first_tail_x15_r0_body.zgrow121 : Nat.ble PRE_first_tail_x15_r0_body.s1176.next PRE_first_tail_x15_r0_body.s1175.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh121 : PRE_first_tail_x15_r0_body.S1174.tab.all (fun e => PRE_first_tail_x15_r0_body.cws121.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd121 : nodupT PRE_first_tail_x15_r0_body.cws121 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi121 : PRE_first_tail_x15_r0_body.nr121.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1175.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt121 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1174.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg121_2665 : PRE_first_tail_x15_r0_body.s1176.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1176 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk121_2665 : (objOf PRE_first_tail_x15_r0_body.s1176 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm121_2665 : PRE_first_tail_x15_r0_body.s1175.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa121.obj (objOf PRE_first_tail_x15_r0_body.s1176 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1175 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg121_2673467 : PRE_first_tail_x15_r0_body.s1176.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1176 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk121_2673467 : (objOf PRE_first_tail_x15_r0_body.s1176 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm121_2673467 : PRE_first_tail_x15_r0_body.s1175.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa121.obj (objOf PRE_first_tail_x15_r0_body.s1176 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1175 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw121_4910 : (PRE_first_tail_x15_r0_body.s1176.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw121_2673472 : (PRE_first_tail_x15_r0_body.s1176.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw121_2673473 : (PRE_first_tail_x15_r0_body.s1176.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd121 : PRE_first_tail_x15_r0_body.cl121.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr121 : PRE_first_tail_x15_r0_body.st121.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1174.next || PRE_first_tail_x15_r0_body.cl121.contains b) = true
def PRE_first_tail_x15_r0_body.zl121 : List Nat := PRE_first_tail_x15_r0_body.cl121.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE121 : PRE_first_tail_x15_r0_body.zl121.map (fun a => PRE_first_tail_x15_r0_body.s1175.heap.get (PRE_first_tail_x15_r0_body.kappa121.a a)) = PRE_first_tail_x15_r0_body.zl121.map (fun a => (PRE_first_tail_x15_r0_body.s1176.heap.get a).map PRE_first_tail_x15_r0_body.kappa121.hobj)
theorem PRE_first_tail_x15_r0_body.zimg121 : HeapImg PRE_first_tail_x15_r0_body.kappa121 PRE_first_tail_x15_r0_body.s1176 PRE_first_tail_x15_r0_body.s1175 PRE_first_tail_x15_r0_body.zl121 := PRE_first_tail_x15_r0_body.zimgE121
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl121 : PRE_first_tail_x15_r0_body.s1175.ctl = PRE_first_tail_x15_r0_body.kappa121.ctl PRE_first_tail_x15_r0_body.s1176.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack121 : PRE_first_tail_x15_r0_body.s1175.stack = PRE_first_tail_x15_r0_body.s1176.stack.map PRE_first_tail_x15_r0_body.kappa121.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs121 : PRE_first_tail_x15_r0_body.s1175.jobs = PRE_first_tail_x15_r0_body.s1176.jobs.map PRE_first_tail_x15_r0_body.kappa121.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores121 : PRE_first_tail_x15_r0_body.s1175.stores = PRE_first_tail_x15_r0_body.kappa121.stores PRE_first_tail_x15_r0_body.s1176.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots121 : checkRootsSupp PRE_first_tail_x15_r0_body.s1176 5252 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC121 : PRE_first_tail_x15_r0_body.S1174.tab.length + PRE_first_tail_x15_r0_body.cws121.length = 5252
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap121 : PRE_first_tail_x15_r0_body.kappa121 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1174.next 2770121 PRE_first_tail_x15_r0_body.S1174.tab.length PRE_first_tail_x15_r0_body.pl121 (PRE_first_tail_x15_r0_body.nr121.map NumV.ref) PRE_first_tail_x15_r0_body.kd121.big
  PRE_first_tail_x15_r0_body.kd121.region PRE_first_tail_x15_r0_body.kd121.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin121 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1176.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc121 : Conv.jcleanListB (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1176 PRE_first_tail_x15_r0_body.cl121 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB121 : noBigRootsP (fun i => !Conv.oldBigB (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1176.trace PRE_first_tail_x15_r0_body.s1176 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm121 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17688 = true
theorem PRE_first_tail_x15_r0_body.cjcl121 (h : Conv.JClean (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1174) : Conv.JClean (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1176 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle121)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap121 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd121 a ha)) PRE_first_tail_x15_r0_body.zjc121

end Host.Load.Run.Tpl
end

section -- st121/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st121.bodyLast from PRE_first_tail_x15_r0_body.st121.s1 to PRE_first_tail_x15_r0_body.st121.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st121.F PRE_first_tail_x15_r0_body.st121.s1).run PRE_first_tail_x15_r0_body.st121.S1 = some (PRE_first_tail_x15_r0_body.st121.s2, PRE_first_tail_x15_r0_body.st121.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st121.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st121.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st121.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st121.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st121/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st121.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st121.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st121.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st121.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st121.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st121.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st121.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st121.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st121.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st121.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st121.s0 PRE_first_tail_x15_r0_body.st121.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st121.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st121.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st121.s1 PRE_first_tail_x15_r0_body.st121.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st121/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st121.bodyK0F from PRE_first_tail_x15_r0_body.st121.s0 to PRE_first_tail_x15_r0_body.st121.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st121.F (PRE_first_tail_x15_r0_body.st121.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st121.ks 0).getD 0) PRE_first_tail_x15_r0_body.st121.s0 PRE_first_tail_x15_r0_body.st121.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st121.s1, PRE_first_tail_x15_r0_body.st121.S1)
theorem PRE_first_tail_x15_r0_body.st121.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st121.F (PRE_first_tail_x15_r0_body.st121.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st121.ks 0).getD 0) PRE_first_tail_x15_r0_body.st121.s0 PRE_first_tail_x15_r0_body.st121.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st121.s1, PRE_first_tail_x15_r0_body.st121.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st121.bodyOkLN_ok PRE_first_tail_x15_r0_body.st121.bodyK0F
end Host.Load.Run.Tpl
end

section -- st121/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st121.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st121.F (PRE_first_tail_x15_r0_body.st121.bodyOkL bytes rows) 27 PRE_first_tail_x15_r0_body.st121.s0 PRE_first_tail_x15_r0_body.st121.S0 = some (PRE_first_tail_x15_r0_body.st121.s1, PRE_first_tail_x15_r0_body.st121.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st121.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st121.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st121.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st121.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st121.F (PRE_first_tail_x15_r0_body.st121.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st121.s0
  S0 := PRE_first_tail_x15_r0_body.st121.S0
  s1 := PRE_first_tail_x15_r0_body.st121.s1
  S1 := PRE_first_tail_x15_r0_body.st121.S1
  s2 := PRE_first_tail_x15_r0_body.st121.s2
  S2 := PRE_first_tail_x15_r0_body.st121.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st121.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st121.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st121.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st121.bodyHalt
  last := PRE_first_tail_x15_r0_body.st121.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st121.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC122
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 122 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1180` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa122` into the merged state
`PRE_first_tail_x15_r0_body.s1179`. -/

def PRE_first_tail_x15_r0_body.pl122 : List Nat := [2770417]
def PRE_first_tail_x15_r0_body.nr122 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd122 : RData :=
  ⟨2770408, 2770418, Stage.setAll PTrie.nil [(2770407, 2770417)], Stage.setAll PTrie.nil [],
   20599, 20599, 17692, 17692, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa122 : Map :=
  Conv.Map.compact 2770407 2770418 5269 PRE_first_tail_x15_r0_body.pl122 (PRE_first_tail_x15_r0_body.nr122.map NumV.ref) PRE_first_tail_x15_r0_body.kd122.big
    PRE_first_tail_x15_r0_body.kd122.region PRE_first_tail_x15_r0_body.kd122.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws122 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs122 : List SymE := PRE_first_tail_x15_r0_body.nr122.map fun r => (nth? PRE_first_tail_x15_r0_body.S1179.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta122 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws122 PRE_first_tail_x15_r0_body.crs122
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB122 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab122 : PRE_first_tail_x15_r0_body.S1180.tab = PRE_first_tail_x15_r0_body.S1178.tab ++ PRE_first_tail_x15_r0_body.cws122.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace122 : PRE_first_tail_x15_r0_body.s1180.trace = PRE_first_tail_x15_r0_body.s1178.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext122 : PRE_first_tail_x15_r0_body.s1180.next = 2770408
kernel_rfl PRE_first_tail_x15_r0_body.ccounters122 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1180.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1180.ffi).mlx.nnext) = (20599, 17692)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue122 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1179.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1180.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa122.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp122 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1180.ffi).mlx.tokens.all (bSN 5269) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean122 : Conv.cleanListB 20599 131072 (fun r => Nat.ble 82396 r) PRE_first_tail_x15_r0_body.s1180
    (PRE_first_tail_x15_r0_body.wrB122 ++ (List.range 1).map (2770407 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs122 : bigsOutB 20599 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1180.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK122
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl122`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl122 : List Nat := [2665, 2673467, 2770407]
def PRE_first_tail_x15_r0_body.clo122 : List Nat := []
def PRE_first_tail_x15_r0_body.cln122 : List Nat := []
def PRE_first_tail_x15_r0_body.cli122 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap122 : PRE_first_tail_x15_r0_body.s1180.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1178.heap (PRE_first_tail_x15_r0_body.cl122.filterMap fun a => (PRE_first_tail_x15_r0_body.s1180.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe122 : Nat.ble PRE_first_tail_x15_r0_body.s1178.next PRE_first_tail_x15_r0_body.s1180.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP122 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1178 PRE_first_tail_x15_r0_body.s1180 PRE_first_tail_x15_r0_body.cl122 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp122 : Conv.suppListB PRE_first_tail_x15_r0_body.s1180 5269 PRE_first_tail_x15_r0_body.cl122 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound122 : Conv.boundListB PRE_first_tail_x15_r0_body.s1180 PRE_first_tail_x15_r0_body.cl122 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK122 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1180.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln122.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1180.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK122 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1180.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo122.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1180.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK122 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1180.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli122.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1180.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst122 : Conv.sstListB 5269 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1180.ffi).mlx PRE_first_tail_x15_r0_body.cln122 PRE_first_tail_x15_r0_body.clo122 PRE_first_tail_x15_r0_body.cli122 = true

end Host.Load.Run.Tpl
end

section -- SiteCl122
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA122 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1180.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo122.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1180.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd122 : (PRE_first_tail_x15_r0_body.clo122 ++ PRE_first_tail_x15_r0_body.cln122 ++ PRE_first_tail_x15_r0_body.cli122).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle122 : Conv.Cnt.leB (⟨20599, 17692, 2770407, 5269⟩ : Conv.Cnt) (⟨20599, 17692, 2770408, 5269⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck122 : Conv.ncleanListB (⟨20599, 17692, 2770408, 5269⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1180.ffi).mlx PRE_first_tail_x15_r0_body.clo122 PRE_first_tail_x15_r0_body.cln122 PRE_first_tail_x15_r0_body.cli122 = true
theorem PRE_first_tail_x15_r0_body.cncl122 (h : Conv.NClean (⟨20599, 17692, 2770407, 5269⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx) : Conv.NClean (⟨20599, 17692, 2770408, 5269⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1180.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle122 PRE_first_tail_x15_r0_body.ckA122 PRE_first_tail_x15_r0_body.cobjsK122 PRE_first_tail_x15_r0_body.cnodesK122 PRE_first_tail_x15_r0_body.citemsK122 PRE_first_tail_x15_r0_body.cbd122 PRE_first_tail_x15_r0_body.cck122

end Host.Load.Run.Tpl
end

section -- SiteS122
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 122 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc122 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P122 : LoadP := PRE_first_tail_x15_r0_body.Pc122.raise 17692
kernel_rfl PRE_first_tail_x15_r0_body.craise122 : Nat.ble PRE_first_tail_x15_r0_body.Pc122.N0 17692 = true
theorem PRE_first_tail_x15_r0_body.raised122 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc122 PRE_first_tail_x15_r0_body.P122 :=
  .inr ⟨17692, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise122, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_122 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1180.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_122 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1179.ffi)
def PRE_first_tail_x15_r0_body.khinv122 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv122 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS122 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS122 : List Nat := List.range' 17692 0
def PRE_first_tail_x15_r0_body.ciS122 : List Nat := [] ++ List.range' 17692 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0122 : PRE_first_tail_x15_r0_body.kd122.nh0 = PRE_first_tail_x15_r0_body.cx0_122.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1122 : PRE_first_tail_x15_r0_body.kd122.nh1 = PRE_first_tail_x15_r0_body.cx1_122.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0122 : PRE_first_tail_x15_r0_body.kd122.nn0 = PRE_first_tail_x15_r0_body.cx0_122.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1122 : PRE_first_tail_x15_r0_body.kd122.nn1 = PRE_first_tail_x15_r0_body.cx1_122.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo122 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P122.lo && Nat.ble PRE_first_tail_x15_r0_body.P122.lo PRE_first_tail_x15_r0_body.cx0_122.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P122.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P122.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt122 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_122.mlx.next PRE_first_tail_x15_r0_body.cx1_122.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_122.mlx.nnext PRE_first_tail_x15_r0_body.cx1_122.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband122 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P122.NL && Nat.ble PRE_first_tail_x15_r0_body.P122.NL PRE_first_tail_x15_r0_body.P122.N0 && Nat.ble PRE_first_tail_x15_r0_body.P122.N0 PRE_first_tail_x15_r0_body.cx0_122.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow122 : PRE_first_tail_x15_r0_body.kd122.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren122 : checkRenG PRE_first_tail_x15_r0_body.kd122.hnd PRE_first_tail_x15_r0_body.khinv122 (phB PRE_first_tail_x15_r0_body.cx0_122.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband122 : PRE_first_tail_x15_r0_body.kd122.checkBand PRE_first_tail_x15_r0_body.P122.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos122 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd122.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren122 : checkRenG PRE_first_tail_x15_r0_body.kd122.node PRE_first_tail_x15_r0_body.kninv122 (pnB PRE_first_tail_x15_r0_body.cx0_122.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow122 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd122.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P122.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd122.nodeF j) PRE_first_tail_x15_r0_body.cx1_122.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a122 : PRE_first_tail_x15_r0_body.cx0_122.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b122 : PRE_first_tail_x15_r0_body.cx0_122.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1122 : PRE_first_tail_x15_r0_body.cx1_122.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend122 : PRE_first_tail_x15_r0_body.cx1_122.mlx.pending = PRE_first_tail_x15_r0_body.cx0_122.mlx.pending.map PRE_first_tail_x15_r0_body.kappa122.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh122 : PRE_first_tail_x15_r0_body.cx1_122.mlx.errh = PRE_first_tail_x15_r0_body.cx0_122.mlx.errh.map PRE_first_tail_x15_r0_body.kappa122.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles122 : PRE_first_tail_x15_r0_body.cx1_122.mlx.files = PRE_first_tail_x15_r0_body.cx0_122.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch122 : PRE_first_tail_x15_r0_body.cx1_122.mlx.arch = PRE_first_tail_x15_r0_body.cx0_122.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes122 : PRE_first_tail_x15_r0_body.cx1_122.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_122.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired122 : PRE_first_tail_x15_r0_body.cx1_122.mlx.wired = PRE_first_tail_x15_r0_body.cx0_122.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost122 : PRE_first_tail_x15_r0_body.cx1_122.host = PRE_first_tail_x15_r0_body.cx0_122.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd122`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0122 : PRE_first_tail_x15_r0_body.kd122.n0 = 2770408
kernel_rfl PRE_first_tail_x15_r0_body.ckn1122 : PRE_first_tail_x15_r0_body.kd122.n1 = 2770418
kernel_rfl PRE_first_tail_x15_r0_body.ckheap122 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd122.heap).all (fun x => Nat.ble 2770407 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl122 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd122.heap.get (2770407 + j) = nth? PRE_first_tail_x15_r0_body.pl122 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja122 : Nat.ble 2770407 2770407 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn122 : Nat.ble 5269 5269 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD122 : Nat.ble 2770407 PRE_first_tail_x15_r0_body.kd122.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn122 : Nat.ble 20599 PRE_first_tail_x15_r0_body.kd122.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn122 : Nat.ble 17692 PRE_first_tail_x15_r0_body.kd122.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb122 : Nat.ble 20599 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap122 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd122.heap).all (Nat.ble (⟨20599, 17692, 2770407, 5269⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd122 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd122.hnd).all (Nat.ble (⟨20599, 17692, 2770407, 5269⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode122 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd122.node).all (Nat.ble (⟨20599, 17692, 2770407, 5269⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix122 : Conv.FixOld (⟨20599, 17692, 2770407, 5269⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa122 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja122) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn122) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD122) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn122) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn122) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb122) PRE_first_tail_x15_r0_body.fheap122 PRE_first_tail_x15_r0_body.fhnd122 PRE_first_tail_x15_r0_body.fnode122
kernel_rfl PRE_first_tail_x15_r0_body.fcxn122 : (⟨20599, 17692, 2770407, 5269⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn122 : (⟨20599, 17692, 2770407, 5269⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0122 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_122.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_122.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk122 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd122.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A122 : PRE_first_tail_x15_r0_body.cx1_122.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS122.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_122.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O122 : PRE_first_tail_x15_r0_body.cx1_122.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS122.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_122.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N122 : PRE_first_tail_x15_r0_body.cx1_122.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS122.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_122.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I122 : PRE_first_tail_x15_r0_body.cx1_122.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS122.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_122.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd122 : (PRE_first_tail_x15_r0_body.clo122 ++ PRE_first_tail_x15_r0_body.cln122 ++ PRE_first_tail_x15_r0_body.cli122 ++ PRE_first_tail_x15_r0_body.cwS122 ++ PRE_first_tail_x15_r0_body.cnS122 ++ PRE_first_tail_x15_r0_body.ciS122).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW122 : PRE_first_tail_x15_r0_body.cwS122.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo122.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI122 : PRE_first_tail_x15_r0_body.ciS122.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli122.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN122 : PRE_first_tail_x15_r0_body.cnS122.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF122 : PRE_first_tail_x15_r0_body.cln122.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh122 : PRE_first_tail_x15_r0_body.clo122.all (handleOK PRE_first_tail_x15_r0_body.kappa122 PRE_first_tail_x15_r0_body.P122.lo PRE_first_tail_x15_r0_body.cx0_122.mlx PRE_first_tail_x15_r0_body.cx1_122.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo122 : PRE_first_tail_x15_r0_body.clo122.map (fun h => PRE_first_tail_x15_r0_body.cx1_122.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa122.handle h)) = PRE_first_tail_x15_r0_body.clo122.map (fun h => (PRE_first_tail_x15_r0_body.cx0_122.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa122.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok122 : PRE_first_tail_x15_r0_body.clo122.all (objOK PRE_first_tail_x15_r0_body.kappa122 PRE_first_tail_x15_r0_body.P122.NL PRE_first_tail_x15_r0_body.cx0_122.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd122 : PRE_first_tail_x15_r0_body.cln122.all (nodeOKF PRE_first_tail_x15_r0_body.kappa122 PRE_first_tail_x15_r0_body.P122 PRE_first_tail_x15_r0_body.cx0_122.mlx PRE_first_tail_x15_r0_body.cx1_122.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp122 : ((PRE_first_tail_x15_r0_body.cln122.filter (fullB PRE_first_tail_x15_r0_body.P122))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_122.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa122.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln122.filter (fullB PRE_first_tail_x15_r0_body.P122))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_122.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa122.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI122 : incrB PRE_first_tail_x15_r0_body.kd122.nodeF (List.range' 17692 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK122 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd122.node).all (fun k => Nat.ble 17692 k && Nat.blt k 17692) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL122 : (PRE_first_tail_x15_r0_body.cln122.filter (Nat.ble PRE_first_tail_x15_r0_body.P122.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd122.nodeF i) && (Nat.blt i 17692 || Nat.ble PRE_first_tail_x15_r0_body.kd122.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord122 : (PRE_first_tail_x15_r0_body.cln122.filter (Nat.ble PRE_first_tail_x15_r0_body.P122.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd122.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd122.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd122.nodeF j) (PRE_first_tail_x15_r0_body.kd122.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow122 PRE_first_tail_x15_r0_body.cnn1122 PRE_first_tail_x15_r0_body.fnordI122 PRE_first_tail_x15_r0_body.fnordK122 PRE_first_tail_x15_r0_body.fnordL122
kernel_rfl PRE_first_tail_x15_r0_body.fi122 : PRE_first_tail_x15_r0_body.cli122.all (pnB PRE_first_tail_x15_r0_body.cx0_122.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii122 : PRE_first_tail_x15_r0_body.cli122.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_122.mlx.items.get (PRE_first_tail_x15_r0_body.kappa122.node k) = (PRE_first_tail_x15_r0_body.cx0_122.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa122.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot122 (clean : Conv.NClean (⟨20599, 17692, 2770407, 5269⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P122.NL) (cl : SSt (· < 5269) PRE_first_tail_x15_r0_body.cx0_122.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P122 5269 PRE_first_tail_x15_r0_body.kappa122 PRE_first_tail_x15_r0_body.kd122 PRE_first_tail_x15_r0_body.khinv122 PRE_first_tail_x15_r0_body.kninv122 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx PRE_first_tail_x15_r0_body.cx0_122.mlx PRE_first_tail_x15_r0_body.cx1_122.mlx (⟨20599, 17692, 2770407, 5269⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo122 PRE_first_tail_x15_r0_body.cln122 PRE_first_tail_x15_r0_body.cli122 PRE_first_tail_x15_r0_body.cwS122 PRE_first_tail_x15_r0_body.cnS122 PRE_first_tail_x15_r0_body.ciS122 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0122, PRE_first_tail_x15_r0_body.cnh1122, PRE_first_tail_x15_r0_body.cnn0122, PRE_first_tail_x15_r0_body.cnn1122, PRE_first_tail_x15_r0_body.cplo122, PRE_first_tail_x15_r0_body.ccnt122, PRE_first_tail_x15_r0_body.cnband122, PRE_first_tail_x15_r0_body.chbelow122, PRE_first_tail_x15_r0_body.chren122, PRE_first_tail_x15_r0_body.cband122, PRE_first_tail_x15_r0_body.cnh1pos122, PRE_first_tail_x15_r0_body.cnren122, PRE_first_tail_x15_r0_body.cnlow122, PRE_first_tail_x15_r0_body.cabs0a122, PRE_first_tail_x15_r0_body.cabs0b122, PRE_first_tail_x15_r0_body.ctok1122, PRE_first_tail_x15_r0_body.cpend122, PRE_first_tail_x15_r0_body.cerrh122, PRE_first_tail_x15_r0_body.cfiles122, PRE_first_tail_x15_r0_body.carch122, PRE_first_tail_x15_r0_body.csizes122, PRE_first_tail_x15_r0_body.cwired122, PRE_first_tail_x15_r0_body.cfix122, clean, PRE_first_tail_x15_r0_body.fcxn122, PRE_first_tail_x15_r0_body.fcnn122, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0122, PRE_first_tail_x15_r0_body.fnk122, PRE_first_tail_x15_r0_body.ckA122, PRE_first_tail_x15_r0_body.cobjsK122, PRE_first_tail_x15_r0_body.cnodesK122, PRE_first_tail_x15_r0_body.citemsK122, PRE_first_tail_x15_r0_body.f1A122, PRE_first_tail_x15_r0_body.f1O122, PRE_first_tail_x15_r0_body.f1N122, PRE_first_tail_x15_r0_body.f1I122, PRE_first_tail_x15_r0_body.fbd122, PRE_first_tail_x15_r0_body.fincW122, PRE_first_tail_x15_r0_body.fincI122, PRE_first_tail_x15_r0_body.fincN122, PRE_first_tail_x15_r0_body.flnF122, PRE_first_tail_x15_r0_body.fh122, PRE_first_tail_x15_r0_body.fo122, PRE_first_tail_x15_r0_body.fok122, PRE_first_tail_x15_r0_body.fnd122, PRE_first_tail_x15_r0_body.fp122, PRE_first_tail_x15_r0_body.fnord122, PRE_first_tail_x15_r0_body.fi122, PRE_first_tail_x15_r0_body.fii122⟩
theorem PRE_first_tail_x15_r0_body.cnshift122 (clean : Conv.NClean (⟨20599, 17692, 2770407, 5269⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P122.NL) (cl : SSt (· < 5269) PRE_first_tail_x15_r0_body.cx0_122.mlx) : NShift PRE_first_tail_x15_r0_body.P122 5269 PRE_first_tail_x15_r0_body.kappa122 PRE_first_tail_x15_r0_body.cx0_122 PRE_first_tail_x15_r0_body.cx1_122 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot122 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost122 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0122 PRE_first_tail_x15_r0_body.ckn1122 PRE_first_tail_x15_r0_body.ckheap122 PRE_first_tail_x15_r0_body.ckpl122)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_122 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1178.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_122 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1178.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_122 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1178.ffi) = some PRE_first_tail_x15_r0_body.fxC_122
kernel_rfl PRE_first_tail_x15_r0_body.okrC_122 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1178.ffi) = some PRE_first_tail_x15_r0_body.krC_122
noncomputable def PRE_first_tail_x15_r0_body.fx0_122 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1180.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_122 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1180.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_122 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1180.ffi) = some PRE_first_tail_x15_r0_body.fx0_122
kernel_rfl PRE_first_tail_x15_r0_body.okr0_122 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1180.ffi) = some PRE_first_tail_x15_r0_body.kr0_122
noncomputable def PRE_first_tail_x15_r0_body.fx1_122 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1179.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_122 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1179.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_122 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1179.ffi) = some PRE_first_tail_x15_r0_body.fx1_122
kernel_rfl PRE_first_tail_x15_r0_body.okr1_122 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1179.ffi) = some PRE_first_tail_x15_r0_body.kr1_122
kernel_rfl PRE_first_tail_x15_r0_body.ff0122 : PRE_first_tail_x15_r0_body.fx0_122 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_122 (PRE_first_tail_x15_r0_body.clo122.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_122.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1122 : PRE_first_tail_x15_r0_body.fx1_122 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_122 (PRE_first_tail_x15_r0_body.cwS122.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_122.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck122 : freedLB PRE_first_tail_x15_r0_body.kappa122 PRE_first_tail_x15_r0_body.cx0_122.mlx PRE_first_tail_x15_r0_body.fx0_122 PRE_first_tail_x15_r0_body.fx1_122 PRE_first_tail_x15_r0_body.clo122 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0122 : PRE_first_tail_x15_r0_body.kr0_122.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_122.flags (PRE_first_tail_x15_r0_body.clo122.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_122.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0122 : PRE_first_tail_x15_r0_body.kr0_122.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_122.targs (PRE_first_tail_x15_r0_body.clo122.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_122.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1122 : PRE_first_tail_x15_r0_body.kr1_122.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_122.flags (PRE_first_tail_x15_r0_body.cwS122.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_122.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1122 : PRE_first_tail_x15_r0_body.kr1_122.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_122.targs (PRE_first_tail_x15_r0_body.cwS122.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_122.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck122 : krecLB PRE_first_tail_x15_r0_body.kappa122 5269 PRE_first_tail_x15_r0_body.cx0_122.mlx PRE_first_tail_x15_r0_body.kr0_122 PRE_first_tail_x15_r0_body.kr1_122 PRE_first_tail_x15_r0_body.clo122 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn122 : Nat.ble 5269 5269 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge122 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1179.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1180.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR122 : pendRegB PRE_first_tail_x15_r0_body.kappa122 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1180.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe122 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1180.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1179.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift122 (clean : Conv.NClean (⟨20599, 17692, 2770407, 5269⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P122.NL) (cl : SSt (· < 5269) PRE_first_tail_x15_r0_body.cx0_122.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_122.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_122.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_122.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_122.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20599, 17692, 2770407, 5269⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P122 5269 PRE_first_tail_x15_r0_body.kappa122 PRE_first_tail_x15_r0_body.s1180.ffi PRE_first_tail_x15_r0_body.s1179.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift122 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue122, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp122 t ht),
    PRE_first_tail_x15_r0_body.cbridge122,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1180.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1179.ffi) (PRE_first_tail_x15_r0_body.cfoot122 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_122 PRE_first_tail_x15_r0_body.ofx1_122 hobjC PRE_first_tail_x15_r0_body.ff0122 PRE_first_tail_x15_r0_body.ff1122 PRE_first_tail_x15_r0_body.ffck122,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1180.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1179.ffi) (PRE_first_tail_x15_r0_body.cfoot122 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_122 PRE_first_tail_x15_r0_body.okr1_122 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn122) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0122 PRE_first_tail_x15_r0_body.fkt0122 PRE_first_tail_x15_r0_body.fkf1122 PRE_first_tail_x15_r0_body.fkt1122 PRE_first_tail_x15_r0_body.fkck122,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0122 PRE_first_tail_x15_r0_body.cnh1122 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe122) PRE_first_tail_x15_r0_body.cpendR122⟩

end Host.Load.Run.Tpl
end

section -- st122/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st122 0
host_stream_state PRE_first_tail_x15_r0_body.st122 1
host_stream_state PRE_first_tail_x15_r0_body.st122 2
end Host.Load.Run.Tpl
end

section -- Site122
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 122 of chain `PRE_first_tail_x15_r0_body`: `plan__g122__g123` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1178`, the merged state `PRE_first_tail_x15_r0_body.s1179`,
the site template `PRE_first_tail_x15_r0_body.st122` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1180`: the merge.
The footprint's facts are in `SiteF122`, the compaction's in `SiteC122`, `SiteK122`, `SiteNa122`, `SiteNb122`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso122 : PRE_first_tail_x15_r0_body.st122.s0 = { PRE_first_tail_x15_r0_body.s1178 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs122 : List Frame := PRE_first_tail_x15_r0_body.s1178.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_122 : PRE_first_tail_x15_r0_body.S1178.tab.length = 5269
kernel_rfl PRE_first_tail_x15_r0_body.tab0_122 : PRE_first_tail_x15_r0_body.st122.S0.tab = PRE_first_tail_x15_r0_body.S1178.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws122 : List Nat := [3047, 3048, 3049]
kernel_rfl PRE_first_tail_x15_r0_body.fresh122 : (PRE_first_tail_x15_r0_body.S1178.tab.all fun e => PRE_first_tail_x15_r0_body.ws122.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1178.oracle.all fun q => PRE_first_tail_x15_r0_body.ws122.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab122 : PRE_first_tail_x15_r0_body.S1179.tab = PRE_first_tail_x15_r0_body.S1178.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws122
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen122 : PRE_first_tail_x15_r0_body.st122.S2.tab.length - PRE_first_tail_x15_r0_body.st122.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged122`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap122 : PRE_first_tail_x15_r0_body.s1179.heap = PRE_first_tail_x15_r0_body.st122.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext122 : PRE_first_tail_x15_r0_body.s1179.next = PRE_first_tail_x15_r0_body.st122.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl122 : PRE_first_tail_x15_r0_body.s1179.ctl = PRE_first_tail_x15_r0_body.st122.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack122 : PRE_first_tail_x15_r0_body.s1179.stack = PRE_first_tail_x15_r0_body.st122.s2.stack ++ PRE_first_tail_x15_r0_body.s1178.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs122 : PRE_first_tail_x15_r0_body.s1179.jobs = PRE_first_tail_x15_r0_body.st122.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi122 : PRE_first_tail_x15_r0_body.s1179.ffi = PRE_first_tail_x15_r0_body.st122.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace122 : PRE_first_tail_x15_r0_body.s1179.trace = PRE_first_tail_x15_r0_body.st122.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores122 : PRE_first_tail_x15_r0_body.s1179.stores = PRE_first_tail_x15_r0_body.st122.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD122
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 122 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived122 : PRE_first_tail_x15_r0_body.nr122.map (fun r => nth? PRE_first_tail_x15_r0_body.st122.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo122 : PRE_first_tail_x15_r0_body.nr122.all (Nat.ble 5269) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj122 : PRE_first_tail_x15_r0_body.cws122.all (fun c => !PRE_first_tail_x15_r0_body.ws122.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ122 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws122 PRE_first_tail_x15_r0_body.crs122 PRE_first_tail_x15_r0_body.ws122

end Host.Load.Run.Tpl
end

section -- st122/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st122`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st122.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st122.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st122.s2.heap PRE_first_tail_x15_r0_body.st122.wrR ++ freshOf PRE_first_tail_x15_r0_body.st122.s2.heap PRE_first_tail_x15_r0_body.st122.s0.next PRE_first_tail_x15_r0_body.st122.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st122.wr : List Nat := PRE_first_tail_x15_r0_body.st122.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st122.heapFoot : PRE_first_tail_x15_r0_body.st122.s2.heap = setAll PRE_first_tail_x15_r0_body.st122.s0.heap PRE_first_tail_x15_r0_body.st122.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st122.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st122.s0.next PRE_first_tail_x15_r0_body.st122.s2.next = true
theorem PRE_first_tail_x15_r0_body.st122.grows : PRE_first_tail_x15_r0_body.st122.s0.next ≤ PRE_first_tail_x15_r0_body.st122.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st122.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st122.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st122.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st122.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st122.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st122.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st122.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st122.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st122.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st122.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st122.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st122.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st122.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st122.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st122.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st122.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st122.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st122.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st122.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st122.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st122.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st122.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st122.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st122.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st122.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st122.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st122.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st122.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st122.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st122.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st122.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st122.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF122
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 122 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB122 : nodupT PRE_first_tail_x15_r0_body.st122.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup122 : PRE_first_tail_x15_r0_body.st122.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB122).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB122 : PRE_first_tail_x15_r0_body.st122.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound122 : ∀ b ∈ PRE_first_tail_x15_r0_body.st122.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB122 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr122 := PRE_first_tail_x15_r0_body.st122.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq122 : PRE_first_tail_x15_r0_body.st122.s2.trace = PRE_first_tail_x15_r0_body.trFr122 ++ PRE_first_tail_x15_r0_body.st122.s0.trace
theorem PRE_first_tail_x15_r0_body.trace122 : ∃ fr, PRE_first_tail_x15_r0_body.st122.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st122.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq122⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide122 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB122 : (PRE_first_tail_x15_r0_body.wide122.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st122.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix122 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide122, WFix Map.id (Present PRE_first_tail_x15_r0_body.st122.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB122 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL122
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 122 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1179`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO122 : PRE_first_tail_x15_r0_body.st122.S0.oracle = PRE_first_tail_x15_r0_body.st122.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B122 : PRE_first_tail_x15_r0_body.st122.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st122.s0.next || (PRE_first_tail_x15_r0_body.st122.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot122 : Conv.StageFoot PRE_first_tail_x15_r0_body.st122.wr PRE_first_tail_x15_r0_body.st122.s0 PRE_first_tail_x15_r0_body.st122.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st122.heapFoot PRE_first_tail_x15_r0_body.wrNodup122 PRE_first_tail_x15_r0_body.wrBound122 PRE_first_tail_x15_r0_body.wr0B122 PRE_first_tail_x15_r0_body.st122.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged122 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st122.F.S → PRE_first_tail_x15_r0_body.st122.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st122.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st122.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs122 PRE_first_tail_x15_r0_body.st122.wr PRE_first_tail_x15_r0_body.s1178 PRE_first_tail_x15_r0_body.st122.s2 PRE_first_tail_x15_r0_body.st122.s0
      PRE_first_tail_x15_r0_body.st122.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st122.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1179 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso122 PRE_first_tail_x15_r0_body.stFoot122 PRE_first_tail_x15_r0_body.wrNodup122 PRE_first_tail_x15_r0_body.wrBound122 PRE_first_tail_x15_r0_body.trace122 PRE_first_tail_x15_r0_body.mheap122
    PRE_first_tail_x15_r0_body.mnext122 PRE_first_tail_x15_r0_body.mctl122 PRE_first_tail_x15_r0_body.mstack122 PRE_first_tail_x15_r0_body.mjobs122 PRE_first_tail_x15_r0_body.mffi122 PRE_first_tail_x15_r0_body.mtrace122 PRE_first_tail_x15_r0_body.mstores122 h

def PRE_first_tail_x15_r0_body.arrEl122_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE122_2665 : arrOf PRE_first_tail_x15_r0_body.s1179 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl122_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA122_2665 : isArrB PRE_first_tail_x15_r0_body.s1179 2665 = true
theorem PRE_first_tail_x15_r0_body.arr122_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1179.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl122_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE122_2665 PRE_first_tail_x15_r0_body.arrA122_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN122_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl122_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR122_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl122_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN122_2665

def PRE_first_tail_x15_r0_body.arrEl122_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE122_2673467 : arrOf PRE_first_tail_x15_r0_body.s1179 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl122_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA122_2673467 : isArrB PRE_first_tail_x15_r0_body.s1179 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr122_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1179.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl122_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE122_2673467 PRE_first_tail_x15_r0_body.arrA122_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN122_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl122_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR122_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl122_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN122_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k122 : isArrB PRE_first_tail_x15_r0_body.s1179 4910 = false
theorem PRE_first_tail_x15_r0_body.keep122 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1179 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k122 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr122_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl122_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ122
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 122 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1178`, the merged
state `PRE_first_tail_x15_r0_body.s1179`, the canonical state `PRE_first_tail_x15_r0_body.s1180`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl122 : PRE_first_tail_x15_r0_body.pl122.all (Nat.ble PRE_first_tail_x15_r0_body.s1178.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd122 : nodupT PRE_first_tail_x15_r0_body.pl122 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1122 : Nat.ble PRE_first_tail_x15_r0_body.s1178.next 2770418 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst122 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1178.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn122 : PRE_first_tail_x15_r0_body.s1180.next = PRE_first_tail_x15_r0_body.s1178.next + PRE_first_tail_x15_r0_body.pl122.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn122 : PRE_first_tail_x15_r0_body.s1179.next = 2770418
kernel_rfl PRE_first_tail_x15_r0_body.zgrow122 : Nat.ble PRE_first_tail_x15_r0_body.s1180.next PRE_first_tail_x15_r0_body.s1179.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh122 : PRE_first_tail_x15_r0_body.S1178.tab.all (fun e => PRE_first_tail_x15_r0_body.cws122.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd122 : nodupT PRE_first_tail_x15_r0_body.cws122 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi122 : PRE_first_tail_x15_r0_body.nr122.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1179.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt122 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1178.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg122_2665 : PRE_first_tail_x15_r0_body.s1180.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1180 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk122_2665 : (objOf PRE_first_tail_x15_r0_body.s1180 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm122_2665 : PRE_first_tail_x15_r0_body.s1179.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa122.obj (objOf PRE_first_tail_x15_r0_body.s1180 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1179 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg122_2673467 : PRE_first_tail_x15_r0_body.s1180.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1180 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk122_2673467 : (objOf PRE_first_tail_x15_r0_body.s1180 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm122_2673467 : PRE_first_tail_x15_r0_body.s1179.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa122.obj (objOf PRE_first_tail_x15_r0_body.s1180 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1179 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw122_4910 : (PRE_first_tail_x15_r0_body.s1180.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw122_2673472 : (PRE_first_tail_x15_r0_body.s1180.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw122_2673473 : (PRE_first_tail_x15_r0_body.s1180.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd122 : PRE_first_tail_x15_r0_body.cl122.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr122 : PRE_first_tail_x15_r0_body.st122.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1178.next || PRE_first_tail_x15_r0_body.cl122.contains b) = true
def PRE_first_tail_x15_r0_body.zl122 : List Nat := PRE_first_tail_x15_r0_body.cl122.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE122 : PRE_first_tail_x15_r0_body.zl122.map (fun a => PRE_first_tail_x15_r0_body.s1179.heap.get (PRE_first_tail_x15_r0_body.kappa122.a a)) = PRE_first_tail_x15_r0_body.zl122.map (fun a => (PRE_first_tail_x15_r0_body.s1180.heap.get a).map PRE_first_tail_x15_r0_body.kappa122.hobj)
theorem PRE_first_tail_x15_r0_body.zimg122 : HeapImg PRE_first_tail_x15_r0_body.kappa122 PRE_first_tail_x15_r0_body.s1180 PRE_first_tail_x15_r0_body.s1179 PRE_first_tail_x15_r0_body.zl122 := PRE_first_tail_x15_r0_body.zimgE122
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl122 : PRE_first_tail_x15_r0_body.s1179.ctl = PRE_first_tail_x15_r0_body.kappa122.ctl PRE_first_tail_x15_r0_body.s1180.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack122 : PRE_first_tail_x15_r0_body.s1179.stack = PRE_first_tail_x15_r0_body.s1180.stack.map PRE_first_tail_x15_r0_body.kappa122.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs122 : PRE_first_tail_x15_r0_body.s1179.jobs = PRE_first_tail_x15_r0_body.s1180.jobs.map PRE_first_tail_x15_r0_body.kappa122.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores122 : PRE_first_tail_x15_r0_body.s1179.stores = PRE_first_tail_x15_r0_body.kappa122.stores PRE_first_tail_x15_r0_body.s1180.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots122 : checkRootsSupp PRE_first_tail_x15_r0_body.s1180 5269 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC122 : PRE_first_tail_x15_r0_body.S1178.tab.length + PRE_first_tail_x15_r0_body.cws122.length = 5269
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap122 : PRE_first_tail_x15_r0_body.kappa122 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1178.next 2770418 PRE_first_tail_x15_r0_body.S1178.tab.length PRE_first_tail_x15_r0_body.pl122 (PRE_first_tail_x15_r0_body.nr122.map NumV.ref) PRE_first_tail_x15_r0_body.kd122.big
  PRE_first_tail_x15_r0_body.kd122.region PRE_first_tail_x15_r0_body.kd122.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin122 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1180.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc122 : Conv.jcleanListB (⟨20599, 17692, 2770408, 5269⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1180 PRE_first_tail_x15_r0_body.cl122 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB122 : noBigRootsP (fun i => !Conv.oldBigB (⟨20599, 17692, 2770408, 5269⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1180.trace PRE_first_tail_x15_r0_body.s1180 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm122 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17692 = true
theorem PRE_first_tail_x15_r0_body.cjcl122 (h : Conv.JClean (⟨20599, 17692, 2770407, 5269⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1178) : Conv.JClean (⟨20599, 17692, 2770408, 5269⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1180 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle122)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap122 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd122 a ha)) PRE_first_tail_x15_r0_body.zjc122

end Host.Load.Run.Tpl
end

section -- st122/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st122.bodyLast from PRE_first_tail_x15_r0_body.st122.s1 to PRE_first_tail_x15_r0_body.st122.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st122.F PRE_first_tail_x15_r0_body.st122.s1).run PRE_first_tail_x15_r0_body.st122.S1 = some (PRE_first_tail_x15_r0_body.st122.s2, PRE_first_tail_x15_r0_body.st122.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st122.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st122.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st122.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st122.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st122/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st122.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st122.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st122.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st122.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st122.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st122.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st122.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st122.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st122.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st122.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st122.s0 PRE_first_tail_x15_r0_body.st122.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st122.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st122.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st122.s1 PRE_first_tail_x15_r0_body.st122.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st122/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st122.bodyK0F from PRE_first_tail_x15_r0_body.st122.s0 to PRE_first_tail_x15_r0_body.st122.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st122.F (PRE_first_tail_x15_r0_body.st122.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st122.ks 0).getD 0) PRE_first_tail_x15_r0_body.st122.s0 PRE_first_tail_x15_r0_body.st122.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st122.s1, PRE_first_tail_x15_r0_body.st122.S1)
theorem PRE_first_tail_x15_r0_body.st122.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st122.F (PRE_first_tail_x15_r0_body.st122.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st122.ks 0).getD 0) PRE_first_tail_x15_r0_body.st122.s0 PRE_first_tail_x15_r0_body.st122.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st122.s1, PRE_first_tail_x15_r0_body.st122.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st122.bodyOkLN_ok PRE_first_tail_x15_r0_body.st122.bodyK0F
end Host.Load.Run.Tpl
end

section -- st122/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st122.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st122.F (PRE_first_tail_x15_r0_body.st122.bodyOkL bytes rows) 98 PRE_first_tail_x15_r0_body.st122.s0 PRE_first_tail_x15_r0_body.st122.S0 = some (PRE_first_tail_x15_r0_body.st122.s1, PRE_first_tail_x15_r0_body.st122.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st122.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st122.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st122.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st122.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st122.F (PRE_first_tail_x15_r0_body.st122.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st122.s0
  S0 := PRE_first_tail_x15_r0_body.st122.S0
  s1 := PRE_first_tail_x15_r0_body.st122.s1
  S1 := PRE_first_tail_x15_r0_body.st122.S1
  s2 := PRE_first_tail_x15_r0_body.st122.s2
  S2 := PRE_first_tail_x15_r0_body.st122.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st122.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st122.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st122.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st122.bodyHalt
  last := PRE_first_tail_x15_r0_body.st122.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st122.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC123
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 123 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1197` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa123` into the merged state
`PRE_first_tail_x15_r0_body.s1196`. -/

def PRE_first_tail_x15_r0_body.pl123 : List Nat := [2772991, 2772166, 2772997, 2772993, 2772168, 2772999]
def PRE_first_tail_x15_r0_body.nr123 : List Nat := [5372, 5371, 5347, 5355, 5360, 5365, 5370, 5344, 5345, 5346, 5353, 5354, 5342, 5349, 5350, 5351, 5352, 5348]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd123 : RData :=
  ⟨2771885, 2773034, Stage.setAll PTrie.nil [(2771879, 2772991), (2771880, 2772166), (2771881, 2772997), (2771882, 2772993), (2771883, 2772168), (2771884, 2772999)], Stage.setAll PTrie.nil [(20633, 20659), (20634, 20637), (20635, 20660)],
   20636, 20661, 17738, 17738, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(5342, .ref 5372), (5343, .ref 5371), (5344, .ref 5347), (5345, .ref 5355), (5346, .ref 5360), (5347, .ref 5365), (5348, .ref 5370), (5349, .ref 5344), (5350, .ref 5345), (5351, .ref 5346), (5352, .ref 5353), (5353, .ref 5354), (5354, .ref 5342), (5355, .ref 5349), (5356, .ref 5350), (5357, .ref 5351), (5358, .ref 5352), (5359, .ref 5348)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa123 : Map :=
  Conv.Map.compact 2771879 2773034 5342 PRE_first_tail_x15_r0_body.pl123 (PRE_first_tail_x15_r0_body.nr123.map NumV.ref) PRE_first_tail_x15_r0_body.kd123.big
    PRE_first_tail_x15_r0_body.kd123.region PRE_first_tail_x15_r0_body.kd123.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws123 : List Nat := [3081, 3082, 3083, 3084, 3085, 3086, 3087, 3088, 3089, 3090, 3091, 3092, 3093, 3094, 3095, 3096, 3097, 3098]
noncomputable def PRE_first_tail_x15_r0_body.crs123 : List SymE := PRE_first_tail_x15_r0_body.nr123.map fun r => (nth? PRE_first_tail_x15_r0_body.S1196.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta123 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws123 PRE_first_tail_x15_r0_body.crs123
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB123 : List Nat := [2665, 2672615, 2673467, 2771053, 2771598, 2771854]

kernel_rfl PRE_first_tail_x15_r0_body.ctab123 : PRE_first_tail_x15_r0_body.S1197.tab = PRE_first_tail_x15_r0_body.S1195.tab ++ PRE_first_tail_x15_r0_body.cws123.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace123 : PRE_first_tail_x15_r0_body.s1197.trace = PRE_first_tail_x15_r0_body.s1195.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext123 : PRE_first_tail_x15_r0_body.s1197.next = 2771885
kernel_rfl PRE_first_tail_x15_r0_body.ccounters123 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi).mlx.nnext) = (20636, 17738)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue123 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1196.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa123.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp123 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi).mlx.tokens.all (bSN 5360) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean123 : Conv.cleanListB 20636 131072 (fun r => Nat.ble 82544 r) PRE_first_tail_x15_r0_body.s1197
    (PRE_first_tail_x15_r0_body.wrB123 ++ (List.range 6).map (2771879 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs123 : bigsOutB 20636 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK123
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl123`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl123 : List Nat := [2665, 2672615, 2673467, 2771053, 2771598, 2771854, 2771879, 2771880, 2771881, 2771882, 2771883, 2771884]
def PRE_first_tail_x15_r0_body.clo123 : List Nat := [20613, 20626, 20632, 20633, 20634, 20635]
def PRE_first_tail_x15_r0_body.cln123 : List Nat := [17711, 17712, 17713, 17714, 17715, 17716, 17717, 17718, 17719, 17720, 17721, 17722, 17723, 17724, 17725, 17726, 17727, 17728, 17729, 17730, 17731, 17732, 17733, 17734, 17735, 17736, 17737]
def PRE_first_tail_x15_r0_body.cli123 : List Nat := [17711, 17712, 17713, 17714, 17715, 17716, 17717, 17718, 17719, 17720, 17721, 17722, 17723, 17724, 17725, 17726, 17727, 17728, 17729, 17730, 17731, 17732, 17733, 17734, 17735, 17736, 17737]
kernel_rfl PRE_first_tail_x15_r0_body.cheap123 : PRE_first_tail_x15_r0_body.s1197.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1195.heap (PRE_first_tail_x15_r0_body.cl123.filterMap fun a => (PRE_first_tail_x15_r0_body.s1197.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe123 : Nat.ble PRE_first_tail_x15_r0_body.s1195.next PRE_first_tail_x15_r0_body.s1197.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP123 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1195 PRE_first_tail_x15_r0_body.s1197 PRE_first_tail_x15_r0_body.cl123 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp123 : Conv.suppListB PRE_first_tail_x15_r0_body.s1197 5360 PRE_first_tail_x15_r0_body.cl123 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound123 : Conv.boundListB PRE_first_tail_x15_r0_body.s1197 PRE_first_tail_x15_r0_body.cl123 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK123 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln123.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK123 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo123.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK123 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli123.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst123 : Conv.sstListB 5360 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi).mlx PRE_first_tail_x15_r0_body.cln123 PRE_first_tail_x15_r0_body.clo123 PRE_first_tail_x15_r0_body.cli123 = true

end Host.Load.Run.Tpl
end

section -- SiteCl123
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA123 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo123.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd123 : (PRE_first_tail_x15_r0_body.clo123 ++ PRE_first_tail_x15_r0_body.cln123 ++ PRE_first_tail_x15_r0_body.cli123).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle123 : Conv.Cnt.leB (⟨20633, 17711, 2771879, 5342⟩ : Conv.Cnt) (⟨20636, 17738, 2771885, 5360⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck123 : Conv.ncleanListB (⟨20636, 17738, 2771885, 5360⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi).mlx PRE_first_tail_x15_r0_body.clo123 PRE_first_tail_x15_r0_body.cln123 PRE_first_tail_x15_r0_body.cli123 = true
theorem PRE_first_tail_x15_r0_body.cncl123 (h : Conv.NClean (⟨20633, 17711, 2771879, 5342⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx) : Conv.NClean (⟨20636, 17738, 2771885, 5360⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle123 PRE_first_tail_x15_r0_body.ckA123 PRE_first_tail_x15_r0_body.cobjsK123 PRE_first_tail_x15_r0_body.cnodesK123 PRE_first_tail_x15_r0_body.citemsK123 PRE_first_tail_x15_r0_body.cbd123 PRE_first_tail_x15_r0_body.cck123

end Host.Load.Run.Tpl
end

section -- SiteS123
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 123 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc123 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P123 : LoadP := PRE_first_tail_x15_r0_body.Pc123.raise 17738
kernel_rfl PRE_first_tail_x15_r0_body.craise123 : Nat.ble PRE_first_tail_x15_r0_body.Pc123.N0 17738 = true
theorem PRE_first_tail_x15_r0_body.raised123 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc123 PRE_first_tail_x15_r0_body.P123 :=
  .inr ⟨17738, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise123, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_123 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_123 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1196.ffi)
def PRE_first_tail_x15_r0_body.khinv123 : PTrie Nat := Stage.setAll PTrie.nil [(20659, 20633), (20637, 20634), (20660, 20635)]
def PRE_first_tail_x15_r0_body.kninv123 : PTrie Nat := Stage.setAll PTrie.nil [(17711, 17711), (17712, 17712), (17713, 17713), (17714, 17714), (17715, 17715), (17716, 17716), (17717, 17717), (17718, 17718), (17719, 17719), (17720, 17720), (17721, 17721), (17722, 17722), (17723, 17723), (17724, 17724), (17725, 17725), (17726, 17726), (17727, 17727), (17728, 17728), (17729, 17729), (17730, 17730), (17731, 17731), (17732, 17732), (17733, 17733), (17734, 17734), (17735, 17735), (17736, 17736), (17737, 17737)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS123 : List Nat := [20613, 20626, 20632, 20633, 20634, 20635, 20636, 20637, 20638, 20639, 20640, 20641, 20642, 20643, 20644, 20645, 20646, 20647, 20648, 20649, 20650, 20651, 20652, 20653, 20654, 20655, 20656, 20657, 20658, 20659, 20660]
def PRE_first_tail_x15_r0_body.cnS123 : List Nat := List.range' 17711 27
def PRE_first_tail_x15_r0_body.ciS123 : List Nat := [] ++ List.range' 17711 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0123 : PRE_first_tail_x15_r0_body.kd123.nh0 = PRE_first_tail_x15_r0_body.cx0_123.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1123 : PRE_first_tail_x15_r0_body.kd123.nh1 = PRE_first_tail_x15_r0_body.cx1_123.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0123 : PRE_first_tail_x15_r0_body.kd123.nn0 = PRE_first_tail_x15_r0_body.cx0_123.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1123 : PRE_first_tail_x15_r0_body.kd123.nn1 = PRE_first_tail_x15_r0_body.cx1_123.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo123 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P123.lo && Nat.ble PRE_first_tail_x15_r0_body.P123.lo PRE_first_tail_x15_r0_body.cx0_123.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P123.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P123.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt123 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_123.mlx.next PRE_first_tail_x15_r0_body.cx1_123.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_123.mlx.nnext PRE_first_tail_x15_r0_body.cx1_123.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband123 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P123.NL && Nat.ble PRE_first_tail_x15_r0_body.P123.NL PRE_first_tail_x15_r0_body.P123.N0 && Nat.ble PRE_first_tail_x15_r0_body.P123.N0 PRE_first_tail_x15_r0_body.cx0_123.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow123 : PRE_first_tail_x15_r0_body.kd123.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren123 : checkRenG PRE_first_tail_x15_r0_body.kd123.hnd PRE_first_tail_x15_r0_body.khinv123 (phB PRE_first_tail_x15_r0_body.cx0_123.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband123 : PRE_first_tail_x15_r0_body.kd123.checkBand PRE_first_tail_x15_r0_body.P123.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos123 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd123.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren123 : checkRenG PRE_first_tail_x15_r0_body.kd123.node PRE_first_tail_x15_r0_body.kninv123 (pnB PRE_first_tail_x15_r0_body.cx0_123.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow123 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd123.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P123.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd123.nodeF j) PRE_first_tail_x15_r0_body.cx1_123.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a123 : PRE_first_tail_x15_r0_body.cx0_123.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b123 : PRE_first_tail_x15_r0_body.cx0_123.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1123 : PRE_first_tail_x15_r0_body.cx1_123.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend123 : PRE_first_tail_x15_r0_body.cx1_123.mlx.pending = PRE_first_tail_x15_r0_body.cx0_123.mlx.pending.map PRE_first_tail_x15_r0_body.kappa123.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh123 : PRE_first_tail_x15_r0_body.cx1_123.mlx.errh = PRE_first_tail_x15_r0_body.cx0_123.mlx.errh.map PRE_first_tail_x15_r0_body.kappa123.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles123 : PRE_first_tail_x15_r0_body.cx1_123.mlx.files = PRE_first_tail_x15_r0_body.cx0_123.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch123 : PRE_first_tail_x15_r0_body.cx1_123.mlx.arch = PRE_first_tail_x15_r0_body.cx0_123.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes123 : PRE_first_tail_x15_r0_body.cx1_123.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_123.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired123 : PRE_first_tail_x15_r0_body.cx1_123.mlx.wired = PRE_first_tail_x15_r0_body.cx0_123.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost123 : PRE_first_tail_x15_r0_body.cx1_123.host = PRE_first_tail_x15_r0_body.cx0_123.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd123`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0123 : PRE_first_tail_x15_r0_body.kd123.n0 = 2771885
kernel_rfl PRE_first_tail_x15_r0_body.ckn1123 : PRE_first_tail_x15_r0_body.kd123.n1 = 2773034
kernel_rfl PRE_first_tail_x15_r0_body.ckheap123 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd123.heap).all (fun x => Nat.ble 2771879 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl123 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd123.heap.get (2771879 + j) = nth? PRE_first_tail_x15_r0_body.pl123 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja123 : Nat.ble 2771879 2771879 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn123 : Nat.ble 5342 5342 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD123 : Nat.ble 2771879 PRE_first_tail_x15_r0_body.kd123.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn123 : Nat.ble 20633 PRE_first_tail_x15_r0_body.kd123.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn123 : Nat.ble 17711 PRE_first_tail_x15_r0_body.kd123.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb123 : Nat.ble 20633 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap123 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd123.heap).all (Nat.ble (⟨20633, 17711, 2771879, 5342⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd123 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd123.hnd).all (Nat.ble (⟨20633, 17711, 2771879, 5342⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode123 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd123.node).all (Nat.ble (⟨20633, 17711, 2771879, 5342⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix123 : Conv.FixOld (⟨20633, 17711, 2771879, 5342⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa123 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja123) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn123) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD123) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn123) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn123) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb123) PRE_first_tail_x15_r0_body.fheap123 PRE_first_tail_x15_r0_body.fhnd123 PRE_first_tail_x15_r0_body.fnode123
kernel_rfl PRE_first_tail_x15_r0_body.fcxn123 : (⟨20633, 17711, 2771879, 5342⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn123 : (⟨20633, 17711, 2771879, 5342⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0123 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_123.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_123.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk123 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd123.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A123 : PRE_first_tail_x15_r0_body.cx1_123.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS123.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_123.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O123 : PRE_first_tail_x15_r0_body.cx1_123.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS123.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_123.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N123 : PRE_first_tail_x15_r0_body.cx1_123.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS123.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_123.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I123 : PRE_first_tail_x15_r0_body.cx1_123.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS123.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_123.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd123 : (PRE_first_tail_x15_r0_body.clo123 ++ PRE_first_tail_x15_r0_body.cln123 ++ PRE_first_tail_x15_r0_body.cli123 ++ PRE_first_tail_x15_r0_body.cwS123 ++ PRE_first_tail_x15_r0_body.cnS123 ++ PRE_first_tail_x15_r0_body.ciS123).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW123 : PRE_first_tail_x15_r0_body.cwS123.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo123.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI123 : PRE_first_tail_x15_r0_body.ciS123.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli123.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN123 : PRE_first_tail_x15_r0_body.cnS123.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF123 : PRE_first_tail_x15_r0_body.cln123.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh123 : PRE_first_tail_x15_r0_body.clo123.all (handleOK PRE_first_tail_x15_r0_body.kappa123 PRE_first_tail_x15_r0_body.P123.lo PRE_first_tail_x15_r0_body.cx0_123.mlx PRE_first_tail_x15_r0_body.cx1_123.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo123 : PRE_first_tail_x15_r0_body.clo123.map (fun h => PRE_first_tail_x15_r0_body.cx1_123.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa123.handle h)) = PRE_first_tail_x15_r0_body.clo123.map (fun h => (PRE_first_tail_x15_r0_body.cx0_123.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa123.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok123 : PRE_first_tail_x15_r0_body.clo123.all (objOK PRE_first_tail_x15_r0_body.kappa123 PRE_first_tail_x15_r0_body.P123.NL PRE_first_tail_x15_r0_body.cx0_123.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd123 : PRE_first_tail_x15_r0_body.cln123.all (nodeOKF PRE_first_tail_x15_r0_body.kappa123 PRE_first_tail_x15_r0_body.P123 PRE_first_tail_x15_r0_body.cx0_123.mlx PRE_first_tail_x15_r0_body.cx1_123.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp123 : ((PRE_first_tail_x15_r0_body.cln123.filter (fullB PRE_first_tail_x15_r0_body.P123))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_123.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa123.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln123.filter (fullB PRE_first_tail_x15_r0_body.P123))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_123.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa123.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI123 : incrB PRE_first_tail_x15_r0_body.kd123.nodeF (List.range' 17711 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK123 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd123.node).all (fun k => Nat.ble 17711 k && Nat.blt k 17738) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL123 : (PRE_first_tail_x15_r0_body.cln123.filter (Nat.ble PRE_first_tail_x15_r0_body.P123.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd123.nodeF i) && (Nat.blt i 17738 || Nat.ble PRE_first_tail_x15_r0_body.kd123.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord123 : (PRE_first_tail_x15_r0_body.cln123.filter (Nat.ble PRE_first_tail_x15_r0_body.P123.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd123.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd123.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd123.nodeF j) (PRE_first_tail_x15_r0_body.kd123.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow123 PRE_first_tail_x15_r0_body.cnn1123 PRE_first_tail_x15_r0_body.fnordI123 PRE_first_tail_x15_r0_body.fnordK123 PRE_first_tail_x15_r0_body.fnordL123
kernel_rfl PRE_first_tail_x15_r0_body.fi123 : PRE_first_tail_x15_r0_body.cli123.all (pnB PRE_first_tail_x15_r0_body.cx0_123.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii123 : PRE_first_tail_x15_r0_body.cli123.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_123.mlx.items.get (PRE_first_tail_x15_r0_body.kappa123.node k) = (PRE_first_tail_x15_r0_body.cx0_123.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa123.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot123 (clean : Conv.NClean (⟨20633, 17711, 2771879, 5342⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P123.NL) (cl : SSt (· < 5360) PRE_first_tail_x15_r0_body.cx0_123.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P123 5360 PRE_first_tail_x15_r0_body.kappa123 PRE_first_tail_x15_r0_body.kd123 PRE_first_tail_x15_r0_body.khinv123 PRE_first_tail_x15_r0_body.kninv123 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx PRE_first_tail_x15_r0_body.cx0_123.mlx PRE_first_tail_x15_r0_body.cx1_123.mlx (⟨20633, 17711, 2771879, 5342⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo123 PRE_first_tail_x15_r0_body.cln123 PRE_first_tail_x15_r0_body.cli123 PRE_first_tail_x15_r0_body.cwS123 PRE_first_tail_x15_r0_body.cnS123 PRE_first_tail_x15_r0_body.ciS123 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0123, PRE_first_tail_x15_r0_body.cnh1123, PRE_first_tail_x15_r0_body.cnn0123, PRE_first_tail_x15_r0_body.cnn1123, PRE_first_tail_x15_r0_body.cplo123, PRE_first_tail_x15_r0_body.ccnt123, PRE_first_tail_x15_r0_body.cnband123, PRE_first_tail_x15_r0_body.chbelow123, PRE_first_tail_x15_r0_body.chren123, PRE_first_tail_x15_r0_body.cband123, PRE_first_tail_x15_r0_body.cnh1pos123, PRE_first_tail_x15_r0_body.cnren123, PRE_first_tail_x15_r0_body.cnlow123, PRE_first_tail_x15_r0_body.cabs0a123, PRE_first_tail_x15_r0_body.cabs0b123, PRE_first_tail_x15_r0_body.ctok1123, PRE_first_tail_x15_r0_body.cpend123, PRE_first_tail_x15_r0_body.cerrh123, PRE_first_tail_x15_r0_body.cfiles123, PRE_first_tail_x15_r0_body.carch123, PRE_first_tail_x15_r0_body.csizes123, PRE_first_tail_x15_r0_body.cwired123, PRE_first_tail_x15_r0_body.cfix123, clean, PRE_first_tail_x15_r0_body.fcxn123, PRE_first_tail_x15_r0_body.fcnn123, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0123, PRE_first_tail_x15_r0_body.fnk123, PRE_first_tail_x15_r0_body.ckA123, PRE_first_tail_x15_r0_body.cobjsK123, PRE_first_tail_x15_r0_body.cnodesK123, PRE_first_tail_x15_r0_body.citemsK123, PRE_first_tail_x15_r0_body.f1A123, PRE_first_tail_x15_r0_body.f1O123, PRE_first_tail_x15_r0_body.f1N123, PRE_first_tail_x15_r0_body.f1I123, PRE_first_tail_x15_r0_body.fbd123, PRE_first_tail_x15_r0_body.fincW123, PRE_first_tail_x15_r0_body.fincI123, PRE_first_tail_x15_r0_body.fincN123, PRE_first_tail_x15_r0_body.flnF123, PRE_first_tail_x15_r0_body.fh123, PRE_first_tail_x15_r0_body.fo123, PRE_first_tail_x15_r0_body.fok123, PRE_first_tail_x15_r0_body.fnd123, PRE_first_tail_x15_r0_body.fp123, PRE_first_tail_x15_r0_body.fnord123, PRE_first_tail_x15_r0_body.fi123, PRE_first_tail_x15_r0_body.fii123⟩
theorem PRE_first_tail_x15_r0_body.cnshift123 (clean : Conv.NClean (⟨20633, 17711, 2771879, 5342⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P123.NL) (cl : SSt (· < 5360) PRE_first_tail_x15_r0_body.cx0_123.mlx) : NShift PRE_first_tail_x15_r0_body.P123 5360 PRE_first_tail_x15_r0_body.kappa123 PRE_first_tail_x15_r0_body.cx0_123 PRE_first_tail_x15_r0_body.cx1_123 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot123 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost123 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0123 PRE_first_tail_x15_r0_body.ckn1123 PRE_first_tail_x15_r0_body.ckheap123 PRE_first_tail_x15_r0_body.ckpl123)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_123 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1195.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_123 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1195.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_123 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1195.ffi) = some PRE_first_tail_x15_r0_body.fxC_123
kernel_rfl PRE_first_tail_x15_r0_body.okrC_123 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1195.ffi) = some PRE_first_tail_x15_r0_body.krC_123
noncomputable def PRE_first_tail_x15_r0_body.fx0_123 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1197.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_123 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1197.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_123 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1197.ffi) = some PRE_first_tail_x15_r0_body.fx0_123
kernel_rfl PRE_first_tail_x15_r0_body.okr0_123 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1197.ffi) = some PRE_first_tail_x15_r0_body.kr0_123
noncomputable def PRE_first_tail_x15_r0_body.fx1_123 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1196.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_123 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1196.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_123 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1196.ffi) = some PRE_first_tail_x15_r0_body.fx1_123
kernel_rfl PRE_first_tail_x15_r0_body.okr1_123 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1196.ffi) = some PRE_first_tail_x15_r0_body.kr1_123
kernel_rfl PRE_first_tail_x15_r0_body.ff0123 : PRE_first_tail_x15_r0_body.fx0_123 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_123 (PRE_first_tail_x15_r0_body.clo123.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_123.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1123 : PRE_first_tail_x15_r0_body.fx1_123 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_123 (PRE_first_tail_x15_r0_body.cwS123.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_123.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck123 : freedLB PRE_first_tail_x15_r0_body.kappa123 PRE_first_tail_x15_r0_body.cx0_123.mlx PRE_first_tail_x15_r0_body.fx0_123 PRE_first_tail_x15_r0_body.fx1_123 PRE_first_tail_x15_r0_body.clo123 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0123 : PRE_first_tail_x15_r0_body.kr0_123.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_123.flags (PRE_first_tail_x15_r0_body.clo123.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_123.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0123 : PRE_first_tail_x15_r0_body.kr0_123.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_123.targs (PRE_first_tail_x15_r0_body.clo123.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_123.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1123 : PRE_first_tail_x15_r0_body.kr1_123.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_123.flags (PRE_first_tail_x15_r0_body.cwS123.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_123.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1123 : PRE_first_tail_x15_r0_body.kr1_123.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_123.targs (PRE_first_tail_x15_r0_body.cwS123.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_123.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck123 : krecLB PRE_first_tail_x15_r0_body.kappa123 5360 PRE_first_tail_x15_r0_body.cx0_123.mlx PRE_first_tail_x15_r0_body.kr0_123 PRE_first_tail_x15_r0_body.kr1_123 PRE_first_tail_x15_r0_body.clo123 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn123 : Nat.ble 5342 5360 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge123 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1196.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1197.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR123 : pendRegB PRE_first_tail_x15_r0_body.kappa123 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe123 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1196.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift123 (clean : Conv.NClean (⟨20633, 17711, 2771879, 5342⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P123.NL) (cl : SSt (· < 5360) PRE_first_tail_x15_r0_body.cx0_123.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_123.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_123.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_123.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_123.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20633, 17711, 2771879, 5342⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P123 5360 PRE_first_tail_x15_r0_body.kappa123 PRE_first_tail_x15_r0_body.s1197.ffi PRE_first_tail_x15_r0_body.s1196.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift123 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue123, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp123 t ht),
    PRE_first_tail_x15_r0_body.cbridge123,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1197.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1196.ffi) (PRE_first_tail_x15_r0_body.cfoot123 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_123 PRE_first_tail_x15_r0_body.ofx1_123 hobjC PRE_first_tail_x15_r0_body.ff0123 PRE_first_tail_x15_r0_body.ff1123 PRE_first_tail_x15_r0_body.ffck123,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1197.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1196.ffi) (PRE_first_tail_x15_r0_body.cfoot123 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_123 PRE_first_tail_x15_r0_body.okr1_123 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn123) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0123 PRE_first_tail_x15_r0_body.fkt0123 PRE_first_tail_x15_r0_body.fkf1123 PRE_first_tail_x15_r0_body.fkt1123 PRE_first_tail_x15_r0_body.fkck123,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0123 PRE_first_tail_x15_r0_body.cnh1123 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe123) PRE_first_tail_x15_r0_body.cpendR123⟩

end Host.Load.Run.Tpl
end

section -- st123/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st123 0
host_stream_state PRE_first_tail_x15_r0_body.st123 1
host_stream_state PRE_first_tail_x15_r0_body.st123 2
host_stream_state PRE_first_tail_x15_r0_body.st123 3
host_stream_state PRE_first_tail_x15_r0_body.st123 4
host_stream_state PRE_first_tail_x15_r0_body.st123 5
end Host.Load.Run.Tpl
end

section -- Site123
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 123 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g123__g124` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s1195`, the merged state `PRE_first_tail_x15_r0_body.s1196`,
the site template `PRE_first_tail_x15_r0_body.st123` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1197`: the merge.
The footprint's facts are in `SiteF123`, the compaction's in `SiteC123`, `SiteK123`, `SiteNa123`, `SiteNb123`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso123 : PRE_first_tail_x15_r0_body.st123.s0 = { PRE_first_tail_x15_r0_body.s1195 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs123 : List Frame := PRE_first_tail_x15_r0_body.s1195.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_123 : PRE_first_tail_x15_r0_body.S1195.tab.length = 5342
kernel_rfl PRE_first_tail_x15_r0_body.tab0_123 : PRE_first_tail_x15_r0_body.st123.S0.tab = PRE_first_tail_x15_r0_body.S1195.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws123 : List Nat := [3050, 3051, 3052, 3053, 3054, 3055, 3056, 3057, 3058, 3059, 3060, 3061, 3062, 3063, 3064, 3065, 3066, 3067, 3068, 3069, 3070, 3071, 3072, 3073, 3074, 3075, 3076, 3077, 3078, 3079, 3080]
kernel_rfl PRE_first_tail_x15_r0_body.fresh123 : (PRE_first_tail_x15_r0_body.S1195.tab.all fun e => PRE_first_tail_x15_r0_body.ws123.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1195.oracle.all fun q => PRE_first_tail_x15_r0_body.ws123.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab123 : PRE_first_tail_x15_r0_body.S1196.tab = PRE_first_tail_x15_r0_body.S1195.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws123
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen123 : PRE_first_tail_x15_r0_body.st123.S5.tab.length - PRE_first_tail_x15_r0_body.st123.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged123`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap123 : PRE_first_tail_x15_r0_body.s1196.heap = PRE_first_tail_x15_r0_body.st123.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext123 : PRE_first_tail_x15_r0_body.s1196.next = PRE_first_tail_x15_r0_body.st123.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl123 : PRE_first_tail_x15_r0_body.s1196.ctl = PRE_first_tail_x15_r0_body.st123.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack123 : PRE_first_tail_x15_r0_body.s1196.stack = PRE_first_tail_x15_r0_body.st123.s5.stack ++ PRE_first_tail_x15_r0_body.s1195.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs123 : PRE_first_tail_x15_r0_body.s1196.jobs = PRE_first_tail_x15_r0_body.st123.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi123 : PRE_first_tail_x15_r0_body.s1196.ffi = PRE_first_tail_x15_r0_body.st123.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace123 : PRE_first_tail_x15_r0_body.s1196.trace = PRE_first_tail_x15_r0_body.st123.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores123 : PRE_first_tail_x15_r0_body.s1196.stores = PRE_first_tail_x15_r0_body.st123.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD123
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 123 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived123 : PRE_first_tail_x15_r0_body.nr123.map (fun r => nth? PRE_first_tail_x15_r0_body.st123.S5.tab r) =
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
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo123 : PRE_first_tail_x15_r0_body.nr123.all (Nat.ble 5342) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj123 : PRE_first_tail_x15_r0_body.cws123.all (fun c => !PRE_first_tail_x15_r0_body.ws123.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ123 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws123 PRE_first_tail_x15_r0_body.crs123 PRE_first_tail_x15_r0_body.ws123

end Host.Load.Run.Tpl
end

section -- st123/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st123`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st123.wrR : List (Nat × Nat) := [(2672615, 2672616), (2771053, 2771054), (2771598, 2771599), (2771854, 2771855)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st123.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st123.s5.heap PRE_first_tail_x15_r0_body.st123.wrR ++ freshOf PRE_first_tail_x15_r0_body.st123.s5.heap PRE_first_tail_x15_r0_body.st123.s0.next PRE_first_tail_x15_r0_body.st123.s5.next
noncomputable def PRE_first_tail_x15_r0_body.st123.wr : List Nat := PRE_first_tail_x15_r0_body.st123.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st123.heapFoot : PRE_first_tail_x15_r0_body.st123.s5.heap = setAll PRE_first_tail_x15_r0_body.st123.s0.heap PRE_first_tail_x15_r0_body.st123.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st123.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st123.s0.next PRE_first_tail_x15_r0_body.st123.s5.next = true
theorem PRE_first_tail_x15_r0_body.st123.grows : PRE_first_tail_x15_r0_body.st123.s0.next ≤ PRE_first_tail_x15_r0_body.st123.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st123.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st123.wh : List Nat := [20613, 20626, 20632, 20633, 20634, 20635, 20636, 20637, 20638, 20639, 20640, 20641, 20642, 20643, 20644, 20645, 20646, 20647, 20648, 20649, 20650, 20651, 20652, 20653, 20654, 20655, 20656, 20657, 20658, 20659, 20660]
def PRE_first_tail_x15_r0_body.st123.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st123.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st123.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st123.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st123.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st123.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st123.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st123.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st123.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st123.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st123.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st123.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st123.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st123.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st123.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st123.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st123.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st123.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st123.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st123.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st123.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st123.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st123.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st123.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st123.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st123.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st123.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st123.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st123.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st123.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF123
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 123 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB123 : nodupT PRE_first_tail_x15_r0_body.st123.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup123 : PRE_first_tail_x15_r0_body.st123.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB123).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB123 : PRE_first_tail_x15_r0_body.st123.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound123 : ∀ b ∈ PRE_first_tail_x15_r0_body.st123.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB123 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr123 := PRE_first_tail_x15_r0_body.st123.s5.trace.take 120
kernel_rfl PRE_first_tail_x15_r0_body.traceEq123 : PRE_first_tail_x15_r0_body.st123.s5.trace = PRE_first_tail_x15_r0_body.trFr123 ++ PRE_first_tail_x15_r0_body.st123.s0.trace
theorem PRE_first_tail_x15_r0_body.trace123 : ∃ fr, PRE_first_tail_x15_r0_body.st123.s5.trace = fr ++ PRE_first_tail_x15_r0_body.st123.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq123⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide123 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB123 : (PRE_first_tail_x15_r0_body.wide123.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st123.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix123 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide123, WFix Map.id (Present PRE_first_tail_x15_r0_body.st123.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB123 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL123
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 123 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1196`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO123 : PRE_first_tail_x15_r0_body.st123.S0.oracle = PRE_first_tail_x15_r0_body.st123.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B123 : PRE_first_tail_x15_r0_body.st123.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st123.s0.next || (PRE_first_tail_x15_r0_body.st123.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot123 : Conv.StageFoot PRE_first_tail_x15_r0_body.st123.wr PRE_first_tail_x15_r0_body.st123.s0 PRE_first_tail_x15_r0_body.st123.s5 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st123.heapFoot PRE_first_tail_x15_r0_body.wrNodup123 PRE_first_tail_x15_r0_body.wrBound123 PRE_first_tail_x15_r0_body.wr0B123 PRE_first_tail_x15_r0_body.st123.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged123 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st123.F.S → PRE_first_tail_x15_r0_body.st123.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st123.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st123.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs123 PRE_first_tail_x15_r0_body.st123.wr PRE_first_tail_x15_r0_body.s1195 PRE_first_tail_x15_r0_body.st123.s5 PRE_first_tail_x15_r0_body.st123.s0
      PRE_first_tail_x15_r0_body.st123.s5.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st123.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1196 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso123 PRE_first_tail_x15_r0_body.stFoot123 PRE_first_tail_x15_r0_body.wrNodup123 PRE_first_tail_x15_r0_body.wrBound123 PRE_first_tail_x15_r0_body.trace123 PRE_first_tail_x15_r0_body.mheap123
    PRE_first_tail_x15_r0_body.mnext123 PRE_first_tail_x15_r0_body.mctl123 PRE_first_tail_x15_r0_body.mstack123 PRE_first_tail_x15_r0_body.mjobs123 PRE_first_tail_x15_r0_body.mffi123 PRE_first_tail_x15_r0_body.mtrace123 PRE_first_tail_x15_r0_body.mstores123 h

def PRE_first_tail_x15_r0_body.arrEl123_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE123_2665 : arrOf PRE_first_tail_x15_r0_body.s1196 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl123_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA123_2665 : isArrB PRE_first_tail_x15_r0_body.s1196 2665 = true
theorem PRE_first_tail_x15_r0_body.arr123_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1196.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl123_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE123_2665 PRE_first_tail_x15_r0_body.arrA123_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN123_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl123_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR123_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl123_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN123_2665

def PRE_first_tail_x15_r0_body.arrEl123_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE123_2673467 : arrOf PRE_first_tail_x15_r0_body.s1196 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl123_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA123_2673467 : isArrB PRE_first_tail_x15_r0_body.s1196 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr123_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1196.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl123_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE123_2673467 PRE_first_tail_x15_r0_body.arrA123_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN123_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl123_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR123_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl123_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN123_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k123 : isArrB PRE_first_tail_x15_r0_body.s1196 4910 = false
theorem PRE_first_tail_x15_r0_body.keep123 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1196 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k123 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr123_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl123_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ123
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 123 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1195`, the merged
state `PRE_first_tail_x15_r0_body.s1196`, the canonical state `PRE_first_tail_x15_r0_body.s1197`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl123 : PRE_first_tail_x15_r0_body.pl123.all (Nat.ble PRE_first_tail_x15_r0_body.s1195.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd123 : nodupT PRE_first_tail_x15_r0_body.pl123 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1123 : Nat.ble PRE_first_tail_x15_r0_body.s1195.next 2773034 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst123 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1195.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn123 : PRE_first_tail_x15_r0_body.s1197.next = PRE_first_tail_x15_r0_body.s1195.next + PRE_first_tail_x15_r0_body.pl123.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn123 : PRE_first_tail_x15_r0_body.s1196.next = 2773034
kernel_rfl PRE_first_tail_x15_r0_body.zgrow123 : Nat.ble PRE_first_tail_x15_r0_body.s1197.next PRE_first_tail_x15_r0_body.s1196.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh123 : PRE_first_tail_x15_r0_body.S1195.tab.all (fun e => PRE_first_tail_x15_r0_body.cws123.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd123 : nodupT PRE_first_tail_x15_r0_body.cws123 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi123 : PRE_first_tail_x15_r0_body.nr123.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1196.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt123 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1195.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg123_2665 : PRE_first_tail_x15_r0_body.s1197.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1197 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk123_2665 : (objOf PRE_first_tail_x15_r0_body.s1197 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm123_2665 : PRE_first_tail_x15_r0_body.s1196.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa123.obj (objOf PRE_first_tail_x15_r0_body.s1197 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1196 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg123_2673467 : PRE_first_tail_x15_r0_body.s1197.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1197 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk123_2673467 : (objOf PRE_first_tail_x15_r0_body.s1197 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm123_2673467 : PRE_first_tail_x15_r0_body.s1196.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa123.obj (objOf PRE_first_tail_x15_r0_body.s1197 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1196 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw123_4910 : (PRE_first_tail_x15_r0_body.s1197.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw123_2673472 : (PRE_first_tail_x15_r0_body.s1197.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw123_2673473 : (PRE_first_tail_x15_r0_body.s1197.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd123 : PRE_first_tail_x15_r0_body.cl123.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr123 : PRE_first_tail_x15_r0_body.st123.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1195.next || PRE_first_tail_x15_r0_body.cl123.contains b) = true
def PRE_first_tail_x15_r0_body.zl123 : List Nat := PRE_first_tail_x15_r0_body.cl123.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE123 : PRE_first_tail_x15_r0_body.zl123.map (fun a => PRE_first_tail_x15_r0_body.s1196.heap.get (PRE_first_tail_x15_r0_body.kappa123.a a)) = PRE_first_tail_x15_r0_body.zl123.map (fun a => (PRE_first_tail_x15_r0_body.s1197.heap.get a).map PRE_first_tail_x15_r0_body.kappa123.hobj)
theorem PRE_first_tail_x15_r0_body.zimg123 : HeapImg PRE_first_tail_x15_r0_body.kappa123 PRE_first_tail_x15_r0_body.s1197 PRE_first_tail_x15_r0_body.s1196 PRE_first_tail_x15_r0_body.zl123 := PRE_first_tail_x15_r0_body.zimgE123
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl123 : PRE_first_tail_x15_r0_body.s1196.ctl = PRE_first_tail_x15_r0_body.kappa123.ctl PRE_first_tail_x15_r0_body.s1197.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack123 : PRE_first_tail_x15_r0_body.s1196.stack = PRE_first_tail_x15_r0_body.s1197.stack.map PRE_first_tail_x15_r0_body.kappa123.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs123 : PRE_first_tail_x15_r0_body.s1196.jobs = PRE_first_tail_x15_r0_body.s1197.jobs.map PRE_first_tail_x15_r0_body.kappa123.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores123 : PRE_first_tail_x15_r0_body.s1196.stores = PRE_first_tail_x15_r0_body.kappa123.stores PRE_first_tail_x15_r0_body.s1197.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots123 : checkRootsSupp PRE_first_tail_x15_r0_body.s1197 5360 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC123 : PRE_first_tail_x15_r0_body.S1195.tab.length + PRE_first_tail_x15_r0_body.cws123.length = 5360
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap123 : PRE_first_tail_x15_r0_body.kappa123 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1195.next 2773034 PRE_first_tail_x15_r0_body.S1195.tab.length PRE_first_tail_x15_r0_body.pl123 (PRE_first_tail_x15_r0_body.nr123.map NumV.ref) PRE_first_tail_x15_r0_body.kd123.big
  PRE_first_tail_x15_r0_body.kd123.region PRE_first_tail_x15_r0_body.kd123.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin123 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1197.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc123 : Conv.jcleanListB (⟨20636, 17738, 2771885, 5360⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1197 PRE_first_tail_x15_r0_body.cl123 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB123 : noBigRootsP (fun i => !Conv.oldBigB (⟨20636, 17738, 2771885, 5360⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1197.trace PRE_first_tail_x15_r0_body.s1197 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm123 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17711 = true
theorem PRE_first_tail_x15_r0_body.cjcl123 (h : Conv.JClean (⟨20633, 17711, 2771879, 5342⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1195) : Conv.JClean (⟨20636, 17738, 2771885, 5360⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1197 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle123)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap123 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd123 a ha)) PRE_first_tail_x15_r0_body.zjc123

end Host.Load.Run.Tpl
end

section -- st123/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st123.bodyLast from PRE_first_tail_x15_r0_body.st123.s4 to PRE_first_tail_x15_r0_body.st123.s5 :
  interpS (step PRE_first_tail_x15_r0_body.st123.F PRE_first_tail_x15_r0_body.st123.s4).run PRE_first_tail_x15_r0_body.st123.S4 = some (PRE_first_tail_x15_r0_body.st123.s5, PRE_first_tail_x15_r0_body.st123.S5)
kernel_rfl PRE_first_tail_x15_r0_body.st123.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st123.s4.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st123.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st123.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st123/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st123.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st123.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st123.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st123.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st123.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st123.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st123.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st123.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st123.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st123.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st123.s0 PRE_first_tail_x15_r0_body.st123.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st123.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st123.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st123.s4 PRE_first_tail_x15_r0_body.st123.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st123/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st123.bodyK0F from PRE_first_tail_x15_r0_body.st123.s0 to PRE_first_tail_x15_r0_body.st123.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st123.F (PRE_first_tail_x15_r0_body.st123.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st123.ks 0).getD 0) PRE_first_tail_x15_r0_body.st123.s0 PRE_first_tail_x15_r0_body.st123.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st123.s1, PRE_first_tail_x15_r0_body.st123.S1)
theorem PRE_first_tail_x15_r0_body.st123.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st123.F (PRE_first_tail_x15_r0_body.st123.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st123.ks 0).getD 0) PRE_first_tail_x15_r0_body.st123.s0 PRE_first_tail_x15_r0_body.st123.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st123.s1, PRE_first_tail_x15_r0_body.st123.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st123.bodyOkLN_ok PRE_first_tail_x15_r0_body.st123.bodyK0F
end Host.Load.Run.Tpl
end

section -- st123/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st123.bodyK1F from PRE_first_tail_x15_r0_body.st123.s1 to PRE_first_tail_x15_r0_body.st123.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st123.F (PRE_first_tail_x15_r0_body.st123.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st123.ks 1).getD 0) PRE_first_tail_x15_r0_body.st123.s1 PRE_first_tail_x15_r0_body.st123.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st123.s2, PRE_first_tail_x15_r0_body.st123.S2)
theorem PRE_first_tail_x15_r0_body.st123.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st123.F (PRE_first_tail_x15_r0_body.st123.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st123.ks 1).getD 0) PRE_first_tail_x15_r0_body.st123.s1 PRE_first_tail_x15_r0_body.st123.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st123.s2, PRE_first_tail_x15_r0_body.st123.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st123.bodyOkLN_ok PRE_first_tail_x15_r0_body.st123.bodyK1F
end Host.Load.Run.Tpl
end

section -- st123/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st123.bodyK2F from PRE_first_tail_x15_r0_body.st123.s2 to PRE_first_tail_x15_r0_body.st123.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st123.F (PRE_first_tail_x15_r0_body.st123.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st123.ks 2).getD 0) PRE_first_tail_x15_r0_body.st123.s2 PRE_first_tail_x15_r0_body.st123.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st123.s3, PRE_first_tail_x15_r0_body.st123.S3)
theorem PRE_first_tail_x15_r0_body.st123.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st123.F (PRE_first_tail_x15_r0_body.st123.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st123.ks 2).getD 0) PRE_first_tail_x15_r0_body.st123.s2 PRE_first_tail_x15_r0_body.st123.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st123.s3, PRE_first_tail_x15_r0_body.st123.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st123.bodyOkLN_ok PRE_first_tail_x15_r0_body.st123.bodyK2F
end Host.Load.Run.Tpl
end

section -- st123/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st123.bodyK3F from PRE_first_tail_x15_r0_body.st123.s3 to PRE_first_tail_x15_r0_body.st123.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st123.F (PRE_first_tail_x15_r0_body.st123.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st123.ks 3).getD 0) PRE_first_tail_x15_r0_body.st123.s3 PRE_first_tail_x15_r0_body.st123.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st123.s4, PRE_first_tail_x15_r0_body.st123.S4)
theorem PRE_first_tail_x15_r0_body.st123.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st123.F (PRE_first_tail_x15_r0_body.st123.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st123.ks 3).getD 0) PRE_first_tail_x15_r0_body.st123.s3 PRE_first_tail_x15_r0_body.st123.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st123.s4, PRE_first_tail_x15_r0_body.st123.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st123.bodyOkLN_ok PRE_first_tail_x15_r0_body.st123.bodyK3F
end Host.Load.Run.Tpl
end

section -- st123/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st123.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st123.F (PRE_first_tail_x15_r0_body.st123.bodyOkL bytes rows) 11334 PRE_first_tail_x15_r0_body.st123.s0 PRE_first_tail_x15_r0_body.st123.S0 = some (PRE_first_tail_x15_r0_body.st123.s4, PRE_first_tail_x15_r0_body.st123.S4) :=
  runOk_trans PRE_first_tail_x15_r0_body.st123.F (PRE_first_tail_x15_r0_body.st123.bodyOkL bytes rows) ((((nth? PRE_first_tail_x15_r0_body.st123.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st123.ks 1).getD 0)) + ((nth? PRE_first_tail_x15_r0_body.st123.ks 2).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st123.ks 3).getD 0) PRE_first_tail_x15_r0_body.st123.s0 PRE_first_tail_x15_r0_body.st123.s3 PRE_first_tail_x15_r0_body.st123.s4 PRE_first_tail_x15_r0_body.st123.S0 PRE_first_tail_x15_r0_body.st123.S3 PRE_first_tail_x15_r0_body.st123.S4 (runOk_trans PRE_first_tail_x15_r0_body.st123.F (PRE_first_tail_x15_r0_body.st123.bodyOkL bytes rows) (((nth? PRE_first_tail_x15_r0_body.st123.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st123.ks 1).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st123.ks 2).getD 0) PRE_first_tail_x15_r0_body.st123.s0 PRE_first_tail_x15_r0_body.st123.s2 PRE_first_tail_x15_r0_body.st123.s3 PRE_first_tail_x15_r0_body.st123.S0 PRE_first_tail_x15_r0_body.st123.S2 PRE_first_tail_x15_r0_body.st123.S3 (runOk_trans PRE_first_tail_x15_r0_body.st123.F (PRE_first_tail_x15_r0_body.st123.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st123.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st123.ks 1).getD 0) PRE_first_tail_x15_r0_body.st123.s0 PRE_first_tail_x15_r0_body.st123.s1 PRE_first_tail_x15_r0_body.st123.s2 PRE_first_tail_x15_r0_body.st123.S0 PRE_first_tail_x15_r0_body.st123.S1 PRE_first_tail_x15_r0_body.st123.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st123.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st123.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st123.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st123.bodyK3 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st123.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st123.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st123.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st123.F (PRE_first_tail_x15_r0_body.st123.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st123.s0
  S0 := PRE_first_tail_x15_r0_body.st123.S0
  s1 := PRE_first_tail_x15_r0_body.st123.s4
  S1 := PRE_first_tail_x15_r0_body.st123.S4
  s2 := PRE_first_tail_x15_r0_body.st123.s5
  S2 := PRE_first_tail_x15_r0_body.st123.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st123.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st123.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st123.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st123.bodyHalt
  last := PRE_first_tail_x15_r0_body.st123.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st123.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC124
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 124 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1205` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa124` into the merged state
`PRE_first_tail_x15_r0_body.s1204`. -/

def PRE_first_tail_x15_r0_body.pl124 : List Nat := []
def PRE_first_tail_x15_r0_body.nr124 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd124 : RData :=
  ⟨2772375, 2772377, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20649, 20649, 17751, 17751, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa124 : Map :=
  Conv.Map.compact 2772375 2772377 5381 PRE_first_tail_x15_r0_body.pl124 (PRE_first_tail_x15_r0_body.nr124.map NumV.ref) PRE_first_tail_x15_r0_body.kd124.big
    PRE_first_tail_x15_r0_body.kd124.region PRE_first_tail_x15_r0_body.kd124.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws124 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs124 : List SymE := PRE_first_tail_x15_r0_body.nr124.map fun r => (nth? PRE_first_tail_x15_r0_body.S1204.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta124 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws124 PRE_first_tail_x15_r0_body.crs124
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB124 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab124 : PRE_first_tail_x15_r0_body.S1205.tab = PRE_first_tail_x15_r0_body.S1203.tab ++ PRE_first_tail_x15_r0_body.cws124.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace124 : PRE_first_tail_x15_r0_body.s1205.trace = PRE_first_tail_x15_r0_body.s1203.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext124 : PRE_first_tail_x15_r0_body.s1205.next = 2772375
kernel_rfl PRE_first_tail_x15_r0_body.ccounters124 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1205.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1205.ffi).mlx.nnext) = (20649, 17751)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue124 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1204.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1205.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa124.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp124 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1205.ffi).mlx.tokens.all (bSN 5381) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean124 : Conv.cleanListB 20649 131072 (fun r => Nat.ble 82596 r) PRE_first_tail_x15_r0_body.s1205
    (PRE_first_tail_x15_r0_body.wrB124 ++ (List.range 0).map (2772375 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs124 : bigsOutB 20649 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1205.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK124
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl124`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl124 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo124 : List Nat := []
def PRE_first_tail_x15_r0_body.cln124 : List Nat := []
def PRE_first_tail_x15_r0_body.cli124 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap124 : PRE_first_tail_x15_r0_body.s1205.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1203.heap (PRE_first_tail_x15_r0_body.cl124.filterMap fun a => (PRE_first_tail_x15_r0_body.s1205.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe124 : Nat.ble PRE_first_tail_x15_r0_body.s1203.next PRE_first_tail_x15_r0_body.s1205.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP124 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1203 PRE_first_tail_x15_r0_body.s1205 PRE_first_tail_x15_r0_body.cl124 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp124 : Conv.suppListB PRE_first_tail_x15_r0_body.s1205 5381 PRE_first_tail_x15_r0_body.cl124 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound124 : Conv.boundListB PRE_first_tail_x15_r0_body.s1205 PRE_first_tail_x15_r0_body.cl124 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK124 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1205.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln124.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1205.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK124 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1205.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo124.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1205.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK124 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1205.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli124.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1205.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst124 : Conv.sstListB 5381 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1205.ffi).mlx PRE_first_tail_x15_r0_body.cln124 PRE_first_tail_x15_r0_body.clo124 PRE_first_tail_x15_r0_body.cli124 = true

end Host.Load.Run.Tpl
end

section -- SiteCl124
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA124 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1205.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo124.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1205.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd124 : (PRE_first_tail_x15_r0_body.clo124 ++ PRE_first_tail_x15_r0_body.cln124 ++ PRE_first_tail_x15_r0_body.cli124).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle124 : Conv.Cnt.leB (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt) (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck124 : Conv.ncleanListB (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1205.ffi).mlx PRE_first_tail_x15_r0_body.clo124 PRE_first_tail_x15_r0_body.cln124 PRE_first_tail_x15_r0_body.cli124 = true
theorem PRE_first_tail_x15_r0_body.cncl124 (h : Conv.NClean (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx) : Conv.NClean (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1205.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle124 PRE_first_tail_x15_r0_body.ckA124 PRE_first_tail_x15_r0_body.cobjsK124 PRE_first_tail_x15_r0_body.cnodesK124 PRE_first_tail_x15_r0_body.citemsK124 PRE_first_tail_x15_r0_body.cbd124 PRE_first_tail_x15_r0_body.cck124

end Host.Load.Run.Tpl
end

section -- SiteS124
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 124 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc124 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P124 : LoadP := PRE_first_tail_x15_r0_body.Pc124.raise 17751
kernel_rfl PRE_first_tail_x15_r0_body.craise124 : Nat.ble PRE_first_tail_x15_r0_body.Pc124.N0 17751 = true
theorem PRE_first_tail_x15_r0_body.raised124 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc124 PRE_first_tail_x15_r0_body.P124 :=
  .inr ⟨17751, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise124, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_124 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1205.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_124 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1204.ffi)
def PRE_first_tail_x15_r0_body.khinv124 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv124 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS124 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS124 : List Nat := List.range' 17751 0
def PRE_first_tail_x15_r0_body.ciS124 : List Nat := [] ++ List.range' 17751 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0124 : PRE_first_tail_x15_r0_body.kd124.nh0 = PRE_first_tail_x15_r0_body.cx0_124.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1124 : PRE_first_tail_x15_r0_body.kd124.nh1 = PRE_first_tail_x15_r0_body.cx1_124.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0124 : PRE_first_tail_x15_r0_body.kd124.nn0 = PRE_first_tail_x15_r0_body.cx0_124.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1124 : PRE_first_tail_x15_r0_body.kd124.nn1 = PRE_first_tail_x15_r0_body.cx1_124.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo124 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P124.lo && Nat.ble PRE_first_tail_x15_r0_body.P124.lo PRE_first_tail_x15_r0_body.cx0_124.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P124.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P124.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt124 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_124.mlx.next PRE_first_tail_x15_r0_body.cx1_124.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_124.mlx.nnext PRE_first_tail_x15_r0_body.cx1_124.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband124 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P124.NL && Nat.ble PRE_first_tail_x15_r0_body.P124.NL PRE_first_tail_x15_r0_body.P124.N0 && Nat.ble PRE_first_tail_x15_r0_body.P124.N0 PRE_first_tail_x15_r0_body.cx0_124.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow124 : PRE_first_tail_x15_r0_body.kd124.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren124 : checkRenG PRE_first_tail_x15_r0_body.kd124.hnd PRE_first_tail_x15_r0_body.khinv124 (phB PRE_first_tail_x15_r0_body.cx0_124.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband124 : PRE_first_tail_x15_r0_body.kd124.checkBand PRE_first_tail_x15_r0_body.P124.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos124 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd124.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren124 : checkRenG PRE_first_tail_x15_r0_body.kd124.node PRE_first_tail_x15_r0_body.kninv124 (pnB PRE_first_tail_x15_r0_body.cx0_124.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow124 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd124.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P124.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd124.nodeF j) PRE_first_tail_x15_r0_body.cx1_124.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a124 : PRE_first_tail_x15_r0_body.cx0_124.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b124 : PRE_first_tail_x15_r0_body.cx0_124.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1124 : PRE_first_tail_x15_r0_body.cx1_124.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend124 : PRE_first_tail_x15_r0_body.cx1_124.mlx.pending = PRE_first_tail_x15_r0_body.cx0_124.mlx.pending.map PRE_first_tail_x15_r0_body.kappa124.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh124 : PRE_first_tail_x15_r0_body.cx1_124.mlx.errh = PRE_first_tail_x15_r0_body.cx0_124.mlx.errh.map PRE_first_tail_x15_r0_body.kappa124.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles124 : PRE_first_tail_x15_r0_body.cx1_124.mlx.files = PRE_first_tail_x15_r0_body.cx0_124.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch124 : PRE_first_tail_x15_r0_body.cx1_124.mlx.arch = PRE_first_tail_x15_r0_body.cx0_124.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes124 : PRE_first_tail_x15_r0_body.cx1_124.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_124.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired124 : PRE_first_tail_x15_r0_body.cx1_124.mlx.wired = PRE_first_tail_x15_r0_body.cx0_124.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost124 : PRE_first_tail_x15_r0_body.cx1_124.host = PRE_first_tail_x15_r0_body.cx0_124.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd124`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0124 : PRE_first_tail_x15_r0_body.kd124.n0 = 2772375
kernel_rfl PRE_first_tail_x15_r0_body.ckn1124 : PRE_first_tail_x15_r0_body.kd124.n1 = 2772377
kernel_rfl PRE_first_tail_x15_r0_body.ckheap124 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd124.heap).all (fun x => Nat.ble 2772375 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl124 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd124.heap.get (2772375 + j) = nth? PRE_first_tail_x15_r0_body.pl124 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja124 : Nat.ble 2772375 2772375 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn124 : Nat.ble 5381 5381 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD124 : Nat.ble 2772375 PRE_first_tail_x15_r0_body.kd124.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn124 : Nat.ble 20649 PRE_first_tail_x15_r0_body.kd124.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn124 : Nat.ble 17751 PRE_first_tail_x15_r0_body.kd124.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb124 : Nat.ble 20649 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap124 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd124.heap).all (Nat.ble (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd124 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd124.hnd).all (Nat.ble (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode124 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd124.node).all (Nat.ble (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix124 : Conv.FixOld (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa124 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja124) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn124) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD124) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn124) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn124) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb124) PRE_first_tail_x15_r0_body.fheap124 PRE_first_tail_x15_r0_body.fhnd124 PRE_first_tail_x15_r0_body.fnode124
kernel_rfl PRE_first_tail_x15_r0_body.fcxn124 : (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn124 : (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0124 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_124.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_124.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk124 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd124.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A124 : PRE_first_tail_x15_r0_body.cx1_124.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS124.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_124.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O124 : PRE_first_tail_x15_r0_body.cx1_124.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS124.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_124.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N124 : PRE_first_tail_x15_r0_body.cx1_124.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS124.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_124.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I124 : PRE_first_tail_x15_r0_body.cx1_124.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS124.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_124.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd124 : (PRE_first_tail_x15_r0_body.clo124 ++ PRE_first_tail_x15_r0_body.cln124 ++ PRE_first_tail_x15_r0_body.cli124 ++ PRE_first_tail_x15_r0_body.cwS124 ++ PRE_first_tail_x15_r0_body.cnS124 ++ PRE_first_tail_x15_r0_body.ciS124).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW124 : PRE_first_tail_x15_r0_body.cwS124.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo124.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI124 : PRE_first_tail_x15_r0_body.ciS124.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli124.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN124 : PRE_first_tail_x15_r0_body.cnS124.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF124 : PRE_first_tail_x15_r0_body.cln124.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh124 : PRE_first_tail_x15_r0_body.clo124.all (handleOK PRE_first_tail_x15_r0_body.kappa124 PRE_first_tail_x15_r0_body.P124.lo PRE_first_tail_x15_r0_body.cx0_124.mlx PRE_first_tail_x15_r0_body.cx1_124.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo124 : PRE_first_tail_x15_r0_body.clo124.map (fun h => PRE_first_tail_x15_r0_body.cx1_124.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa124.handle h)) = PRE_first_tail_x15_r0_body.clo124.map (fun h => (PRE_first_tail_x15_r0_body.cx0_124.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa124.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok124 : PRE_first_tail_x15_r0_body.clo124.all (objOK PRE_first_tail_x15_r0_body.kappa124 PRE_first_tail_x15_r0_body.P124.NL PRE_first_tail_x15_r0_body.cx0_124.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd124 : PRE_first_tail_x15_r0_body.cln124.all (nodeOKF PRE_first_tail_x15_r0_body.kappa124 PRE_first_tail_x15_r0_body.P124 PRE_first_tail_x15_r0_body.cx0_124.mlx PRE_first_tail_x15_r0_body.cx1_124.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp124 : ((PRE_first_tail_x15_r0_body.cln124.filter (fullB PRE_first_tail_x15_r0_body.P124))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_124.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa124.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln124.filter (fullB PRE_first_tail_x15_r0_body.P124))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_124.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa124.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI124 : incrB PRE_first_tail_x15_r0_body.kd124.nodeF (List.range' 17751 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK124 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd124.node).all (fun k => Nat.ble 17751 k && Nat.blt k 17751) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL124 : (PRE_first_tail_x15_r0_body.cln124.filter (Nat.ble PRE_first_tail_x15_r0_body.P124.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd124.nodeF i) && (Nat.blt i 17751 || Nat.ble PRE_first_tail_x15_r0_body.kd124.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord124 : (PRE_first_tail_x15_r0_body.cln124.filter (Nat.ble PRE_first_tail_x15_r0_body.P124.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd124.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd124.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd124.nodeF j) (PRE_first_tail_x15_r0_body.kd124.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow124 PRE_first_tail_x15_r0_body.cnn1124 PRE_first_tail_x15_r0_body.fnordI124 PRE_first_tail_x15_r0_body.fnordK124 PRE_first_tail_x15_r0_body.fnordL124
kernel_rfl PRE_first_tail_x15_r0_body.fi124 : PRE_first_tail_x15_r0_body.cli124.all (pnB PRE_first_tail_x15_r0_body.cx0_124.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii124 : PRE_first_tail_x15_r0_body.cli124.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_124.mlx.items.get (PRE_first_tail_x15_r0_body.kappa124.node k) = (PRE_first_tail_x15_r0_body.cx0_124.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa124.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot124 (clean : Conv.NClean (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P124.NL) (cl : SSt (· < 5381) PRE_first_tail_x15_r0_body.cx0_124.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P124 5381 PRE_first_tail_x15_r0_body.kappa124 PRE_first_tail_x15_r0_body.kd124 PRE_first_tail_x15_r0_body.khinv124 PRE_first_tail_x15_r0_body.kninv124 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx PRE_first_tail_x15_r0_body.cx0_124.mlx PRE_first_tail_x15_r0_body.cx1_124.mlx (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo124 PRE_first_tail_x15_r0_body.cln124 PRE_first_tail_x15_r0_body.cli124 PRE_first_tail_x15_r0_body.cwS124 PRE_first_tail_x15_r0_body.cnS124 PRE_first_tail_x15_r0_body.ciS124 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0124, PRE_first_tail_x15_r0_body.cnh1124, PRE_first_tail_x15_r0_body.cnn0124, PRE_first_tail_x15_r0_body.cnn1124, PRE_first_tail_x15_r0_body.cplo124, PRE_first_tail_x15_r0_body.ccnt124, PRE_first_tail_x15_r0_body.cnband124, PRE_first_tail_x15_r0_body.chbelow124, PRE_first_tail_x15_r0_body.chren124, PRE_first_tail_x15_r0_body.cband124, PRE_first_tail_x15_r0_body.cnh1pos124, PRE_first_tail_x15_r0_body.cnren124, PRE_first_tail_x15_r0_body.cnlow124, PRE_first_tail_x15_r0_body.cabs0a124, PRE_first_tail_x15_r0_body.cabs0b124, PRE_first_tail_x15_r0_body.ctok1124, PRE_first_tail_x15_r0_body.cpend124, PRE_first_tail_x15_r0_body.cerrh124, PRE_first_tail_x15_r0_body.cfiles124, PRE_first_tail_x15_r0_body.carch124, PRE_first_tail_x15_r0_body.csizes124, PRE_first_tail_x15_r0_body.cwired124, PRE_first_tail_x15_r0_body.cfix124, clean, PRE_first_tail_x15_r0_body.fcxn124, PRE_first_tail_x15_r0_body.fcnn124, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0124, PRE_first_tail_x15_r0_body.fnk124, PRE_first_tail_x15_r0_body.ckA124, PRE_first_tail_x15_r0_body.cobjsK124, PRE_first_tail_x15_r0_body.cnodesK124, PRE_first_tail_x15_r0_body.citemsK124, PRE_first_tail_x15_r0_body.f1A124, PRE_first_tail_x15_r0_body.f1O124, PRE_first_tail_x15_r0_body.f1N124, PRE_first_tail_x15_r0_body.f1I124, PRE_first_tail_x15_r0_body.fbd124, PRE_first_tail_x15_r0_body.fincW124, PRE_first_tail_x15_r0_body.fincI124, PRE_first_tail_x15_r0_body.fincN124, PRE_first_tail_x15_r0_body.flnF124, PRE_first_tail_x15_r0_body.fh124, PRE_first_tail_x15_r0_body.fo124, PRE_first_tail_x15_r0_body.fok124, PRE_first_tail_x15_r0_body.fnd124, PRE_first_tail_x15_r0_body.fp124, PRE_first_tail_x15_r0_body.fnord124, PRE_first_tail_x15_r0_body.fi124, PRE_first_tail_x15_r0_body.fii124⟩
theorem PRE_first_tail_x15_r0_body.cnshift124 (clean : Conv.NClean (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P124.NL) (cl : SSt (· < 5381) PRE_first_tail_x15_r0_body.cx0_124.mlx) : NShift PRE_first_tail_x15_r0_body.P124 5381 PRE_first_tail_x15_r0_body.kappa124 PRE_first_tail_x15_r0_body.cx0_124 PRE_first_tail_x15_r0_body.cx1_124 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot124 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost124 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0124 PRE_first_tail_x15_r0_body.ckn1124 PRE_first_tail_x15_r0_body.ckheap124 PRE_first_tail_x15_r0_body.ckpl124)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_124 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1203.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_124 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1203.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_124 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1203.ffi) = some PRE_first_tail_x15_r0_body.fxC_124
kernel_rfl PRE_first_tail_x15_r0_body.okrC_124 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1203.ffi) = some PRE_first_tail_x15_r0_body.krC_124
noncomputable def PRE_first_tail_x15_r0_body.fx0_124 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1205.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_124 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1205.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_124 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1205.ffi) = some PRE_first_tail_x15_r0_body.fx0_124
kernel_rfl PRE_first_tail_x15_r0_body.okr0_124 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1205.ffi) = some PRE_first_tail_x15_r0_body.kr0_124
noncomputable def PRE_first_tail_x15_r0_body.fx1_124 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1204.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_124 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1204.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_124 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1204.ffi) = some PRE_first_tail_x15_r0_body.fx1_124
kernel_rfl PRE_first_tail_x15_r0_body.okr1_124 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1204.ffi) = some PRE_first_tail_x15_r0_body.kr1_124
kernel_rfl PRE_first_tail_x15_r0_body.ff0124 : PRE_first_tail_x15_r0_body.fx0_124 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_124 (PRE_first_tail_x15_r0_body.clo124.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_124.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1124 : PRE_first_tail_x15_r0_body.fx1_124 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_124 (PRE_first_tail_x15_r0_body.cwS124.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_124.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck124 : freedLB PRE_first_tail_x15_r0_body.kappa124 PRE_first_tail_x15_r0_body.cx0_124.mlx PRE_first_tail_x15_r0_body.fx0_124 PRE_first_tail_x15_r0_body.fx1_124 PRE_first_tail_x15_r0_body.clo124 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0124 : PRE_first_tail_x15_r0_body.kr0_124.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_124.flags (PRE_first_tail_x15_r0_body.clo124.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_124.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0124 : PRE_first_tail_x15_r0_body.kr0_124.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_124.targs (PRE_first_tail_x15_r0_body.clo124.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_124.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1124 : PRE_first_tail_x15_r0_body.kr1_124.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_124.flags (PRE_first_tail_x15_r0_body.cwS124.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_124.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1124 : PRE_first_tail_x15_r0_body.kr1_124.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_124.targs (PRE_first_tail_x15_r0_body.cwS124.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_124.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck124 : krecLB PRE_first_tail_x15_r0_body.kappa124 5381 PRE_first_tail_x15_r0_body.cx0_124.mlx PRE_first_tail_x15_r0_body.kr0_124 PRE_first_tail_x15_r0_body.kr1_124 PRE_first_tail_x15_r0_body.clo124 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn124 : Nat.ble 5381 5381 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge124 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1204.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1205.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR124 : pendRegB PRE_first_tail_x15_r0_body.kappa124 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1205.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe124 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1205.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1204.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift124 (clean : Conv.NClean (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P124.NL) (cl : SSt (· < 5381) PRE_first_tail_x15_r0_body.cx0_124.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_124.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_124.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_124.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_124.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P124 5381 PRE_first_tail_x15_r0_body.kappa124 PRE_first_tail_x15_r0_body.s1205.ffi PRE_first_tail_x15_r0_body.s1204.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift124 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue124, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp124 t ht),
    PRE_first_tail_x15_r0_body.cbridge124,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1205.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1204.ffi) (PRE_first_tail_x15_r0_body.cfoot124 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_124 PRE_first_tail_x15_r0_body.ofx1_124 hobjC PRE_first_tail_x15_r0_body.ff0124 PRE_first_tail_x15_r0_body.ff1124 PRE_first_tail_x15_r0_body.ffck124,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1205.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1204.ffi) (PRE_first_tail_x15_r0_body.cfoot124 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_124 PRE_first_tail_x15_r0_body.okr1_124 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn124) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0124 PRE_first_tail_x15_r0_body.fkt0124 PRE_first_tail_x15_r0_body.fkf1124 PRE_first_tail_x15_r0_body.fkt1124 PRE_first_tail_x15_r0_body.fkck124,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0124 PRE_first_tail_x15_r0_body.cnh1124 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe124) PRE_first_tail_x15_r0_body.cpendR124⟩

end Host.Load.Run.Tpl
end

section -- st124/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st124 0
host_stream_state PRE_first_tail_x15_r0_body.st124 1
host_stream_state PRE_first_tail_x15_r0_body.st124 2
end Host.Load.Run.Tpl
end

section -- Site124
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 124 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g124__g125` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1203`, the merged state `PRE_first_tail_x15_r0_body.s1204`,
the site template `PRE_first_tail_x15_r0_body.st124` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1205`: the merge.
The footprint's facts are in `SiteF124`, the compaction's in `SiteC124`, `SiteK124`, `SiteNa124`, `SiteNb124`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso124 : PRE_first_tail_x15_r0_body.st124.s0 = { PRE_first_tail_x15_r0_body.s1203 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs124 : List Frame := PRE_first_tail_x15_r0_body.s1203.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_124 : PRE_first_tail_x15_r0_body.S1203.tab.length = 5381
kernel_rfl PRE_first_tail_x15_r0_body.tab0_124 : PRE_first_tail_x15_r0_body.st124.S0.tab = PRE_first_tail_x15_r0_body.S1203.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws124 : List Nat := [3099, 3100]
kernel_rfl PRE_first_tail_x15_r0_body.fresh124 : (PRE_first_tail_x15_r0_body.S1203.tab.all fun e => PRE_first_tail_x15_r0_body.ws124.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1203.oracle.all fun q => PRE_first_tail_x15_r0_body.ws124.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab124 : PRE_first_tail_x15_r0_body.S1204.tab = PRE_first_tail_x15_r0_body.S1203.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws124
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen124 : PRE_first_tail_x15_r0_body.st124.S2.tab.length - PRE_first_tail_x15_r0_body.st124.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged124`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap124 : PRE_first_tail_x15_r0_body.s1204.heap = PRE_first_tail_x15_r0_body.st124.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext124 : PRE_first_tail_x15_r0_body.s1204.next = PRE_first_tail_x15_r0_body.st124.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl124 : PRE_first_tail_x15_r0_body.s1204.ctl = PRE_first_tail_x15_r0_body.st124.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack124 : PRE_first_tail_x15_r0_body.s1204.stack = PRE_first_tail_x15_r0_body.st124.s2.stack ++ PRE_first_tail_x15_r0_body.s1203.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs124 : PRE_first_tail_x15_r0_body.s1204.jobs = PRE_first_tail_x15_r0_body.st124.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi124 : PRE_first_tail_x15_r0_body.s1204.ffi = PRE_first_tail_x15_r0_body.st124.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace124 : PRE_first_tail_x15_r0_body.s1204.trace = PRE_first_tail_x15_r0_body.st124.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores124 : PRE_first_tail_x15_r0_body.s1204.stores = PRE_first_tail_x15_r0_body.st124.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD124
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 124 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived124 : PRE_first_tail_x15_r0_body.nr124.map (fun r => nth? PRE_first_tail_x15_r0_body.st124.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo124 : PRE_first_tail_x15_r0_body.nr124.all (Nat.ble 5381) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj124 : PRE_first_tail_x15_r0_body.cws124.all (fun c => !PRE_first_tail_x15_r0_body.ws124.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ124 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws124 PRE_first_tail_x15_r0_body.crs124 PRE_first_tail_x15_r0_body.ws124

end Host.Load.Run.Tpl
end

section -- st124/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st124`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st124.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st124.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st124.s2.heap PRE_first_tail_x15_r0_body.st124.wrR ++ freshOf PRE_first_tail_x15_r0_body.st124.s2.heap PRE_first_tail_x15_r0_body.st124.s0.next PRE_first_tail_x15_r0_body.st124.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st124.wr : List Nat := PRE_first_tail_x15_r0_body.st124.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st124.heapFoot : PRE_first_tail_x15_r0_body.st124.s2.heap = setAll PRE_first_tail_x15_r0_body.st124.s0.heap PRE_first_tail_x15_r0_body.st124.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st124.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st124.s0.next PRE_first_tail_x15_r0_body.st124.s2.next = true
theorem PRE_first_tail_x15_r0_body.st124.grows : PRE_first_tail_x15_r0_body.st124.s0.next ≤ PRE_first_tail_x15_r0_body.st124.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st124.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st124.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st124.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st124.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st124.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st124.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st124.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st124.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st124.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st124.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st124.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st124.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st124.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st124.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st124.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st124.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st124.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st124.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st124.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st124.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st124.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st124.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st124.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st124.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st124.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st124.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st124.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st124.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st124.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st124.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st124.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st124.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF124
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 124 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB124 : nodupT PRE_first_tail_x15_r0_body.st124.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup124 : PRE_first_tail_x15_r0_body.st124.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB124).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB124 : PRE_first_tail_x15_r0_body.st124.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound124 : ∀ b ∈ PRE_first_tail_x15_r0_body.st124.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB124 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr124 := PRE_first_tail_x15_r0_body.st124.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq124 : PRE_first_tail_x15_r0_body.st124.s2.trace = PRE_first_tail_x15_r0_body.trFr124 ++ PRE_first_tail_x15_r0_body.st124.s0.trace
theorem PRE_first_tail_x15_r0_body.trace124 : ∃ fr, PRE_first_tail_x15_r0_body.st124.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st124.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq124⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide124 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB124 : (PRE_first_tail_x15_r0_body.wide124.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st124.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix124 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide124, WFix Map.id (Present PRE_first_tail_x15_r0_body.st124.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB124 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL124
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 124 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1204`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO124 : PRE_first_tail_x15_r0_body.st124.S0.oracle = PRE_first_tail_x15_r0_body.st124.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B124 : PRE_first_tail_x15_r0_body.st124.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st124.s0.next || (PRE_first_tail_x15_r0_body.st124.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot124 : Conv.StageFoot PRE_first_tail_x15_r0_body.st124.wr PRE_first_tail_x15_r0_body.st124.s0 PRE_first_tail_x15_r0_body.st124.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st124.heapFoot PRE_first_tail_x15_r0_body.wrNodup124 PRE_first_tail_x15_r0_body.wrBound124 PRE_first_tail_x15_r0_body.wr0B124 PRE_first_tail_x15_r0_body.st124.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged124 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st124.F.S → PRE_first_tail_x15_r0_body.st124.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st124.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st124.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs124 PRE_first_tail_x15_r0_body.st124.wr PRE_first_tail_x15_r0_body.s1203 PRE_first_tail_x15_r0_body.st124.s2 PRE_first_tail_x15_r0_body.st124.s0
      PRE_first_tail_x15_r0_body.st124.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st124.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1204 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso124 PRE_first_tail_x15_r0_body.stFoot124 PRE_first_tail_x15_r0_body.wrNodup124 PRE_first_tail_x15_r0_body.wrBound124 PRE_first_tail_x15_r0_body.trace124 PRE_first_tail_x15_r0_body.mheap124
    PRE_first_tail_x15_r0_body.mnext124 PRE_first_tail_x15_r0_body.mctl124 PRE_first_tail_x15_r0_body.mstack124 PRE_first_tail_x15_r0_body.mjobs124 PRE_first_tail_x15_r0_body.mffi124 PRE_first_tail_x15_r0_body.mtrace124 PRE_first_tail_x15_r0_body.mstores124 h

def PRE_first_tail_x15_r0_body.arrEl124_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE124_2665 : arrOf PRE_first_tail_x15_r0_body.s1204 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl124_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA124_2665 : isArrB PRE_first_tail_x15_r0_body.s1204 2665 = true
theorem PRE_first_tail_x15_r0_body.arr124_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1204.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl124_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE124_2665 PRE_first_tail_x15_r0_body.arrA124_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN124_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl124_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR124_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl124_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN124_2665

def PRE_first_tail_x15_r0_body.arrEl124_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE124_2673467 : arrOf PRE_first_tail_x15_r0_body.s1204 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl124_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA124_2673467 : isArrB PRE_first_tail_x15_r0_body.s1204 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr124_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1204.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl124_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE124_2673467 PRE_first_tail_x15_r0_body.arrA124_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN124_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl124_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR124_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl124_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN124_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k124 : isArrB PRE_first_tail_x15_r0_body.s1204 4910 = false
theorem PRE_first_tail_x15_r0_body.keep124 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1204 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k124 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr124_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl124_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ124
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 124 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1203`, the merged
state `PRE_first_tail_x15_r0_body.s1204`, the canonical state `PRE_first_tail_x15_r0_body.s1205`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl124 : PRE_first_tail_x15_r0_body.pl124.all (Nat.ble PRE_first_tail_x15_r0_body.s1203.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd124 : nodupT PRE_first_tail_x15_r0_body.pl124 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1124 : Nat.ble PRE_first_tail_x15_r0_body.s1203.next 2772377 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst124 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1203.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn124 : PRE_first_tail_x15_r0_body.s1205.next = PRE_first_tail_x15_r0_body.s1203.next + PRE_first_tail_x15_r0_body.pl124.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn124 : PRE_first_tail_x15_r0_body.s1204.next = 2772377
kernel_rfl PRE_first_tail_x15_r0_body.zgrow124 : Nat.ble PRE_first_tail_x15_r0_body.s1205.next PRE_first_tail_x15_r0_body.s1204.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh124 : PRE_first_tail_x15_r0_body.S1203.tab.all (fun e => PRE_first_tail_x15_r0_body.cws124.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd124 : nodupT PRE_first_tail_x15_r0_body.cws124 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi124 : PRE_first_tail_x15_r0_body.nr124.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1204.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt124 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1203.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg124_2665 : PRE_first_tail_x15_r0_body.s1205.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1205 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk124_2665 : (objOf PRE_first_tail_x15_r0_body.s1205 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm124_2665 : PRE_first_tail_x15_r0_body.s1204.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa124.obj (objOf PRE_first_tail_x15_r0_body.s1205 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1204 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg124_2673467 : PRE_first_tail_x15_r0_body.s1205.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1205 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk124_2673467 : (objOf PRE_first_tail_x15_r0_body.s1205 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm124_2673467 : PRE_first_tail_x15_r0_body.s1204.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa124.obj (objOf PRE_first_tail_x15_r0_body.s1205 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1204 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw124_4910 : (PRE_first_tail_x15_r0_body.s1205.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw124_2673472 : (PRE_first_tail_x15_r0_body.s1205.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw124_2673473 : (PRE_first_tail_x15_r0_body.s1205.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd124 : PRE_first_tail_x15_r0_body.cl124.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr124 : PRE_first_tail_x15_r0_body.st124.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1203.next || PRE_first_tail_x15_r0_body.cl124.contains b) = true
def PRE_first_tail_x15_r0_body.zl124 : List Nat := PRE_first_tail_x15_r0_body.cl124.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE124 : PRE_first_tail_x15_r0_body.zl124.map (fun a => PRE_first_tail_x15_r0_body.s1204.heap.get (PRE_first_tail_x15_r0_body.kappa124.a a)) = PRE_first_tail_x15_r0_body.zl124.map (fun a => (PRE_first_tail_x15_r0_body.s1205.heap.get a).map PRE_first_tail_x15_r0_body.kappa124.hobj)
theorem PRE_first_tail_x15_r0_body.zimg124 : HeapImg PRE_first_tail_x15_r0_body.kappa124 PRE_first_tail_x15_r0_body.s1205 PRE_first_tail_x15_r0_body.s1204 PRE_first_tail_x15_r0_body.zl124 := PRE_first_tail_x15_r0_body.zimgE124
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl124 : PRE_first_tail_x15_r0_body.s1204.ctl = PRE_first_tail_x15_r0_body.kappa124.ctl PRE_first_tail_x15_r0_body.s1205.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack124 : PRE_first_tail_x15_r0_body.s1204.stack = PRE_first_tail_x15_r0_body.s1205.stack.map PRE_first_tail_x15_r0_body.kappa124.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs124 : PRE_first_tail_x15_r0_body.s1204.jobs = PRE_first_tail_x15_r0_body.s1205.jobs.map PRE_first_tail_x15_r0_body.kappa124.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores124 : PRE_first_tail_x15_r0_body.s1204.stores = PRE_first_tail_x15_r0_body.kappa124.stores PRE_first_tail_x15_r0_body.s1205.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots124 : checkRootsSupp PRE_first_tail_x15_r0_body.s1205 5381 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC124 : PRE_first_tail_x15_r0_body.S1203.tab.length + PRE_first_tail_x15_r0_body.cws124.length = 5381
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap124 : PRE_first_tail_x15_r0_body.kappa124 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1203.next 2772377 PRE_first_tail_x15_r0_body.S1203.tab.length PRE_first_tail_x15_r0_body.pl124 (PRE_first_tail_x15_r0_body.nr124.map NumV.ref) PRE_first_tail_x15_r0_body.kd124.big
  PRE_first_tail_x15_r0_body.kd124.region PRE_first_tail_x15_r0_body.kd124.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin124 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1205.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc124 : Conv.jcleanListB (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1205 PRE_first_tail_x15_r0_body.cl124 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB124 : noBigRootsP (fun i => !Conv.oldBigB (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1205.trace PRE_first_tail_x15_r0_body.s1205 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm124 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17751 = true
theorem PRE_first_tail_x15_r0_body.cjcl124 (h : Conv.JClean (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1203) : Conv.JClean (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1205 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle124)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap124 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd124 a ha)) PRE_first_tail_x15_r0_body.zjc124

end Host.Load.Run.Tpl
end

section -- st124/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st124.bodyLast from PRE_first_tail_x15_r0_body.st124.s1 to PRE_first_tail_x15_r0_body.st124.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st124.F PRE_first_tail_x15_r0_body.st124.s1).run PRE_first_tail_x15_r0_body.st124.S1 = some (PRE_first_tail_x15_r0_body.st124.s2, PRE_first_tail_x15_r0_body.st124.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st124.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st124.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st124.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st124.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st124/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st124.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st124.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st124.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st124.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st124.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st124.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st124.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st124.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st124.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st124.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st124.s0 PRE_first_tail_x15_r0_body.st124.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st124.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st124.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st124.s1 PRE_first_tail_x15_r0_body.st124.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st124/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st124.bodyK0F from PRE_first_tail_x15_r0_body.st124.s0 to PRE_first_tail_x15_r0_body.st124.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st124.F (PRE_first_tail_x15_r0_body.st124.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st124.ks 0).getD 0) PRE_first_tail_x15_r0_body.st124.s0 PRE_first_tail_x15_r0_body.st124.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st124.s1, PRE_first_tail_x15_r0_body.st124.S1)
theorem PRE_first_tail_x15_r0_body.st124.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st124.F (PRE_first_tail_x15_r0_body.st124.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st124.ks 0).getD 0) PRE_first_tail_x15_r0_body.st124.s0 PRE_first_tail_x15_r0_body.st124.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st124.s1, PRE_first_tail_x15_r0_body.st124.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st124.bodyOkLN_ok PRE_first_tail_x15_r0_body.st124.bodyK0F
end Host.Load.Run.Tpl
end

section -- st124/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st124.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st124.F (PRE_first_tail_x15_r0_body.st124.bodyOkL bytes rows) 27 PRE_first_tail_x15_r0_body.st124.s0 PRE_first_tail_x15_r0_body.st124.S0 = some (PRE_first_tail_x15_r0_body.st124.s1, PRE_first_tail_x15_r0_body.st124.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st124.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st124.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st124.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st124.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st124.F (PRE_first_tail_x15_r0_body.st124.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st124.s0
  S0 := PRE_first_tail_x15_r0_body.st124.S0
  s1 := PRE_first_tail_x15_r0_body.st124.s1
  S1 := PRE_first_tail_x15_r0_body.st124.S1
  s2 := PRE_first_tail_x15_r0_body.st124.s2
  S2 := PRE_first_tail_x15_r0_body.st124.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st124.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st124.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st124.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st124.bodyHalt
  last := PRE_first_tail_x15_r0_body.st124.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st124.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC125
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 125 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1209` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa125` into the merged state
`PRE_first_tail_x15_r0_body.s1208`. -/

def PRE_first_tail_x15_r0_body.pl125 : List Nat := [2772673]
def PRE_first_tail_x15_r0_body.nr125 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd125 : RData :=
  ⟨2772664, 2772674, Stage.setAll PTrie.nil [(2772663, 2772673)], Stage.setAll PTrie.nil [],
   20656, 20656, 17755, 17755, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa125 : Map :=
  Conv.Map.compact 2772663 2772674 5398 PRE_first_tail_x15_r0_body.pl125 (PRE_first_tail_x15_r0_body.nr125.map NumV.ref) PRE_first_tail_x15_r0_body.kd125.big
    PRE_first_tail_x15_r0_body.kd125.region PRE_first_tail_x15_r0_body.kd125.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws125 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs125 : List SymE := PRE_first_tail_x15_r0_body.nr125.map fun r => (nth? PRE_first_tail_x15_r0_body.S1208.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta125 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws125 PRE_first_tail_x15_r0_body.crs125
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB125 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab125 : PRE_first_tail_x15_r0_body.S1209.tab = PRE_first_tail_x15_r0_body.S1207.tab ++ PRE_first_tail_x15_r0_body.cws125.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace125 : PRE_first_tail_x15_r0_body.s1209.trace = PRE_first_tail_x15_r0_body.s1207.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext125 : PRE_first_tail_x15_r0_body.s1209.next = 2772664
kernel_rfl PRE_first_tail_x15_r0_body.ccounters125 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx.nnext) = (20656, 17755)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue125 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1208.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa125.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp125 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx.tokens.all (bSN 5398) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean125 : Conv.cleanListB 20656 131072 (fun r => Nat.ble 82624 r) PRE_first_tail_x15_r0_body.s1209
    (PRE_first_tail_x15_r0_body.wrB125 ++ (List.range 1).map (2772663 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs125 : bigsOutB 20656 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK125
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl125`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl125 : List Nat := [2665, 2673467, 2772663]
def PRE_first_tail_x15_r0_body.clo125 : List Nat := []
def PRE_first_tail_x15_r0_body.cln125 : List Nat := []
def PRE_first_tail_x15_r0_body.cli125 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap125 : PRE_first_tail_x15_r0_body.s1209.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1207.heap (PRE_first_tail_x15_r0_body.cl125.filterMap fun a => (PRE_first_tail_x15_r0_body.s1209.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe125 : Nat.ble PRE_first_tail_x15_r0_body.s1207.next PRE_first_tail_x15_r0_body.s1209.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP125 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1207 PRE_first_tail_x15_r0_body.s1209 PRE_first_tail_x15_r0_body.cl125 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp125 : Conv.suppListB PRE_first_tail_x15_r0_body.s1209 5398 PRE_first_tail_x15_r0_body.cl125 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound125 : Conv.boundListB PRE_first_tail_x15_r0_body.s1209 PRE_first_tail_x15_r0_body.cl125 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK125 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln125.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK125 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo125.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK125 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli125.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst125 : Conv.sstListB 5398 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx PRE_first_tail_x15_r0_body.cln125 PRE_first_tail_x15_r0_body.clo125 PRE_first_tail_x15_r0_body.cli125 = true

end Host.Load.Run.Tpl
end

section -- SiteCl125
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA125 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo125.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd125 : (PRE_first_tail_x15_r0_body.clo125 ++ PRE_first_tail_x15_r0_body.cln125 ++ PRE_first_tail_x15_r0_body.cli125).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle125 : Conv.Cnt.leB (⟨20656, 17755, 2772663, 5398⟩ : Conv.Cnt) (⟨20656, 17755, 2772664, 5398⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck125 : Conv.ncleanListB (⟨20656, 17755, 2772664, 5398⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx PRE_first_tail_x15_r0_body.clo125 PRE_first_tail_x15_r0_body.cln125 PRE_first_tail_x15_r0_body.cli125 = true
theorem PRE_first_tail_x15_r0_body.cncl125 (h : Conv.NClean (⟨20656, 17755, 2772663, 5398⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx) : Conv.NClean (⟨20656, 17755, 2772664, 5398⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle125 PRE_first_tail_x15_r0_body.ckA125 PRE_first_tail_x15_r0_body.cobjsK125 PRE_first_tail_x15_r0_body.cnodesK125 PRE_first_tail_x15_r0_body.citemsK125 PRE_first_tail_x15_r0_body.cbd125 PRE_first_tail_x15_r0_body.cck125

end Host.Load.Run.Tpl
end

section -- SiteS125
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 125 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc125 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P125 : LoadP := PRE_first_tail_x15_r0_body.Pc125.raise 17755
kernel_rfl PRE_first_tail_x15_r0_body.craise125 : Nat.ble PRE_first_tail_x15_r0_body.Pc125.N0 17755 = true
theorem PRE_first_tail_x15_r0_body.raised125 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc125 PRE_first_tail_x15_r0_body.P125 :=
  .inr ⟨17755, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise125, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_125 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_125 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1208.ffi)
def PRE_first_tail_x15_r0_body.khinv125 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv125 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS125 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS125 : List Nat := List.range' 17755 0
def PRE_first_tail_x15_r0_body.ciS125 : List Nat := [] ++ List.range' 17755 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0125 : PRE_first_tail_x15_r0_body.kd125.nh0 = PRE_first_tail_x15_r0_body.cx0_125.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1125 : PRE_first_tail_x15_r0_body.kd125.nh1 = PRE_first_tail_x15_r0_body.cx1_125.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0125 : PRE_first_tail_x15_r0_body.kd125.nn0 = PRE_first_tail_x15_r0_body.cx0_125.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1125 : PRE_first_tail_x15_r0_body.kd125.nn1 = PRE_first_tail_x15_r0_body.cx1_125.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo125 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P125.lo && Nat.ble PRE_first_tail_x15_r0_body.P125.lo PRE_first_tail_x15_r0_body.cx0_125.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P125.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P125.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt125 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_125.mlx.next PRE_first_tail_x15_r0_body.cx1_125.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_125.mlx.nnext PRE_first_tail_x15_r0_body.cx1_125.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband125 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P125.NL && Nat.ble PRE_first_tail_x15_r0_body.P125.NL PRE_first_tail_x15_r0_body.P125.N0 && Nat.ble PRE_first_tail_x15_r0_body.P125.N0 PRE_first_tail_x15_r0_body.cx0_125.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow125 : PRE_first_tail_x15_r0_body.kd125.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren125 : checkRenG PRE_first_tail_x15_r0_body.kd125.hnd PRE_first_tail_x15_r0_body.khinv125 (phB PRE_first_tail_x15_r0_body.cx0_125.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband125 : PRE_first_tail_x15_r0_body.kd125.checkBand PRE_first_tail_x15_r0_body.P125.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos125 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd125.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren125 : checkRenG PRE_first_tail_x15_r0_body.kd125.node PRE_first_tail_x15_r0_body.kninv125 (pnB PRE_first_tail_x15_r0_body.cx0_125.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow125 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd125.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P125.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd125.nodeF j) PRE_first_tail_x15_r0_body.cx1_125.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a125 : PRE_first_tail_x15_r0_body.cx0_125.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b125 : PRE_first_tail_x15_r0_body.cx0_125.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1125 : PRE_first_tail_x15_r0_body.cx1_125.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend125 : PRE_first_tail_x15_r0_body.cx1_125.mlx.pending = PRE_first_tail_x15_r0_body.cx0_125.mlx.pending.map PRE_first_tail_x15_r0_body.kappa125.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh125 : PRE_first_tail_x15_r0_body.cx1_125.mlx.errh = PRE_first_tail_x15_r0_body.cx0_125.mlx.errh.map PRE_first_tail_x15_r0_body.kappa125.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles125 : PRE_first_tail_x15_r0_body.cx1_125.mlx.files = PRE_first_tail_x15_r0_body.cx0_125.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch125 : PRE_first_tail_x15_r0_body.cx1_125.mlx.arch = PRE_first_tail_x15_r0_body.cx0_125.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes125 : PRE_first_tail_x15_r0_body.cx1_125.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_125.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired125 : PRE_first_tail_x15_r0_body.cx1_125.mlx.wired = PRE_first_tail_x15_r0_body.cx0_125.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost125 : PRE_first_tail_x15_r0_body.cx1_125.host = PRE_first_tail_x15_r0_body.cx0_125.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd125`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0125 : PRE_first_tail_x15_r0_body.kd125.n0 = 2772664
kernel_rfl PRE_first_tail_x15_r0_body.ckn1125 : PRE_first_tail_x15_r0_body.kd125.n1 = 2772674
kernel_rfl PRE_first_tail_x15_r0_body.ckheap125 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd125.heap).all (fun x => Nat.ble 2772663 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl125 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd125.heap.get (2772663 + j) = nth? PRE_first_tail_x15_r0_body.pl125 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja125 : Nat.ble 2772663 2772663 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn125 : Nat.ble 5398 5398 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD125 : Nat.ble 2772663 PRE_first_tail_x15_r0_body.kd125.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn125 : Nat.ble 20656 PRE_first_tail_x15_r0_body.kd125.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn125 : Nat.ble 17755 PRE_first_tail_x15_r0_body.kd125.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb125 : Nat.ble 20656 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap125 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd125.heap).all (Nat.ble (⟨20656, 17755, 2772663, 5398⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd125 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd125.hnd).all (Nat.ble (⟨20656, 17755, 2772663, 5398⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode125 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd125.node).all (Nat.ble (⟨20656, 17755, 2772663, 5398⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix125 : Conv.FixOld (⟨20656, 17755, 2772663, 5398⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa125 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja125) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn125) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD125) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn125) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn125) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb125) PRE_first_tail_x15_r0_body.fheap125 PRE_first_tail_x15_r0_body.fhnd125 PRE_first_tail_x15_r0_body.fnode125
kernel_rfl PRE_first_tail_x15_r0_body.fcxn125 : (⟨20656, 17755, 2772663, 5398⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn125 : (⟨20656, 17755, 2772663, 5398⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0125 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_125.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_125.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk125 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd125.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A125 : PRE_first_tail_x15_r0_body.cx1_125.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS125.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_125.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O125 : PRE_first_tail_x15_r0_body.cx1_125.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS125.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_125.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N125 : PRE_first_tail_x15_r0_body.cx1_125.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS125.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_125.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I125 : PRE_first_tail_x15_r0_body.cx1_125.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS125.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_125.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd125 : (PRE_first_tail_x15_r0_body.clo125 ++ PRE_first_tail_x15_r0_body.cln125 ++ PRE_first_tail_x15_r0_body.cli125 ++ PRE_first_tail_x15_r0_body.cwS125 ++ PRE_first_tail_x15_r0_body.cnS125 ++ PRE_first_tail_x15_r0_body.ciS125).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW125 : PRE_first_tail_x15_r0_body.cwS125.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo125.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI125 : PRE_first_tail_x15_r0_body.ciS125.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli125.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN125 : PRE_first_tail_x15_r0_body.cnS125.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF125 : PRE_first_tail_x15_r0_body.cln125.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh125 : PRE_first_tail_x15_r0_body.clo125.all (handleOK PRE_first_tail_x15_r0_body.kappa125 PRE_first_tail_x15_r0_body.P125.lo PRE_first_tail_x15_r0_body.cx0_125.mlx PRE_first_tail_x15_r0_body.cx1_125.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo125 : PRE_first_tail_x15_r0_body.clo125.map (fun h => PRE_first_tail_x15_r0_body.cx1_125.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa125.handle h)) = PRE_first_tail_x15_r0_body.clo125.map (fun h => (PRE_first_tail_x15_r0_body.cx0_125.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa125.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok125 : PRE_first_tail_x15_r0_body.clo125.all (objOK PRE_first_tail_x15_r0_body.kappa125 PRE_first_tail_x15_r0_body.P125.NL PRE_first_tail_x15_r0_body.cx0_125.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd125 : PRE_first_tail_x15_r0_body.cln125.all (nodeOKF PRE_first_tail_x15_r0_body.kappa125 PRE_first_tail_x15_r0_body.P125 PRE_first_tail_x15_r0_body.cx0_125.mlx PRE_first_tail_x15_r0_body.cx1_125.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp125 : ((PRE_first_tail_x15_r0_body.cln125.filter (fullB PRE_first_tail_x15_r0_body.P125))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_125.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa125.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln125.filter (fullB PRE_first_tail_x15_r0_body.P125))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_125.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa125.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI125 : incrB PRE_first_tail_x15_r0_body.kd125.nodeF (List.range' 17755 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK125 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd125.node).all (fun k => Nat.ble 17755 k && Nat.blt k 17755) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL125 : (PRE_first_tail_x15_r0_body.cln125.filter (Nat.ble PRE_first_tail_x15_r0_body.P125.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd125.nodeF i) && (Nat.blt i 17755 || Nat.ble PRE_first_tail_x15_r0_body.kd125.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord125 : (PRE_first_tail_x15_r0_body.cln125.filter (Nat.ble PRE_first_tail_x15_r0_body.P125.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd125.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd125.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd125.nodeF j) (PRE_first_tail_x15_r0_body.kd125.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow125 PRE_first_tail_x15_r0_body.cnn1125 PRE_first_tail_x15_r0_body.fnordI125 PRE_first_tail_x15_r0_body.fnordK125 PRE_first_tail_x15_r0_body.fnordL125
kernel_rfl PRE_first_tail_x15_r0_body.fi125 : PRE_first_tail_x15_r0_body.cli125.all (pnB PRE_first_tail_x15_r0_body.cx0_125.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii125 : PRE_first_tail_x15_r0_body.cli125.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_125.mlx.items.get (PRE_first_tail_x15_r0_body.kappa125.node k) = (PRE_first_tail_x15_r0_body.cx0_125.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa125.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot125 (clean : Conv.NClean (⟨20656, 17755, 2772663, 5398⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P125.NL) (cl : SSt (· < 5398) PRE_first_tail_x15_r0_body.cx0_125.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P125 5398 PRE_first_tail_x15_r0_body.kappa125 PRE_first_tail_x15_r0_body.kd125 PRE_first_tail_x15_r0_body.khinv125 PRE_first_tail_x15_r0_body.kninv125 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx PRE_first_tail_x15_r0_body.cx0_125.mlx PRE_first_tail_x15_r0_body.cx1_125.mlx (⟨20656, 17755, 2772663, 5398⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo125 PRE_first_tail_x15_r0_body.cln125 PRE_first_tail_x15_r0_body.cli125 PRE_first_tail_x15_r0_body.cwS125 PRE_first_tail_x15_r0_body.cnS125 PRE_first_tail_x15_r0_body.ciS125 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0125, PRE_first_tail_x15_r0_body.cnh1125, PRE_first_tail_x15_r0_body.cnn0125, PRE_first_tail_x15_r0_body.cnn1125, PRE_first_tail_x15_r0_body.cplo125, PRE_first_tail_x15_r0_body.ccnt125, PRE_first_tail_x15_r0_body.cnband125, PRE_first_tail_x15_r0_body.chbelow125, PRE_first_tail_x15_r0_body.chren125, PRE_first_tail_x15_r0_body.cband125, PRE_first_tail_x15_r0_body.cnh1pos125, PRE_first_tail_x15_r0_body.cnren125, PRE_first_tail_x15_r0_body.cnlow125, PRE_first_tail_x15_r0_body.cabs0a125, PRE_first_tail_x15_r0_body.cabs0b125, PRE_first_tail_x15_r0_body.ctok1125, PRE_first_tail_x15_r0_body.cpend125, PRE_first_tail_x15_r0_body.cerrh125, PRE_first_tail_x15_r0_body.cfiles125, PRE_first_tail_x15_r0_body.carch125, PRE_first_tail_x15_r0_body.csizes125, PRE_first_tail_x15_r0_body.cwired125, PRE_first_tail_x15_r0_body.cfix125, clean, PRE_first_tail_x15_r0_body.fcxn125, PRE_first_tail_x15_r0_body.fcnn125, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0125, PRE_first_tail_x15_r0_body.fnk125, PRE_first_tail_x15_r0_body.ckA125, PRE_first_tail_x15_r0_body.cobjsK125, PRE_first_tail_x15_r0_body.cnodesK125, PRE_first_tail_x15_r0_body.citemsK125, PRE_first_tail_x15_r0_body.f1A125, PRE_first_tail_x15_r0_body.f1O125, PRE_first_tail_x15_r0_body.f1N125, PRE_first_tail_x15_r0_body.f1I125, PRE_first_tail_x15_r0_body.fbd125, PRE_first_tail_x15_r0_body.fincW125, PRE_first_tail_x15_r0_body.fincI125, PRE_first_tail_x15_r0_body.fincN125, PRE_first_tail_x15_r0_body.flnF125, PRE_first_tail_x15_r0_body.fh125, PRE_first_tail_x15_r0_body.fo125, PRE_first_tail_x15_r0_body.fok125, PRE_first_tail_x15_r0_body.fnd125, PRE_first_tail_x15_r0_body.fp125, PRE_first_tail_x15_r0_body.fnord125, PRE_first_tail_x15_r0_body.fi125, PRE_first_tail_x15_r0_body.fii125⟩
theorem PRE_first_tail_x15_r0_body.cnshift125 (clean : Conv.NClean (⟨20656, 17755, 2772663, 5398⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P125.NL) (cl : SSt (· < 5398) PRE_first_tail_x15_r0_body.cx0_125.mlx) : NShift PRE_first_tail_x15_r0_body.P125 5398 PRE_first_tail_x15_r0_body.kappa125 PRE_first_tail_x15_r0_body.cx0_125 PRE_first_tail_x15_r0_body.cx1_125 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot125 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost125 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0125 PRE_first_tail_x15_r0_body.ckn1125 PRE_first_tail_x15_r0_body.ckheap125 PRE_first_tail_x15_r0_body.ckpl125)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_125 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1207.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_125 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1207.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_125 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1207.ffi) = some PRE_first_tail_x15_r0_body.fxC_125
kernel_rfl PRE_first_tail_x15_r0_body.okrC_125 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1207.ffi) = some PRE_first_tail_x15_r0_body.krC_125
noncomputable def PRE_first_tail_x15_r0_body.fx0_125 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1209.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_125 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1209.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_125 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1209.ffi) = some PRE_first_tail_x15_r0_body.fx0_125
kernel_rfl PRE_first_tail_x15_r0_body.okr0_125 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1209.ffi) = some PRE_first_tail_x15_r0_body.kr0_125
noncomputable def PRE_first_tail_x15_r0_body.fx1_125 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1208.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_125 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1208.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_125 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1208.ffi) = some PRE_first_tail_x15_r0_body.fx1_125
kernel_rfl PRE_first_tail_x15_r0_body.okr1_125 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1208.ffi) = some PRE_first_tail_x15_r0_body.kr1_125
kernel_rfl PRE_first_tail_x15_r0_body.ff0125 : PRE_first_tail_x15_r0_body.fx0_125 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_125 (PRE_first_tail_x15_r0_body.clo125.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_125.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1125 : PRE_first_tail_x15_r0_body.fx1_125 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_125 (PRE_first_tail_x15_r0_body.cwS125.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_125.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck125 : freedLB PRE_first_tail_x15_r0_body.kappa125 PRE_first_tail_x15_r0_body.cx0_125.mlx PRE_first_tail_x15_r0_body.fx0_125 PRE_first_tail_x15_r0_body.fx1_125 PRE_first_tail_x15_r0_body.clo125 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0125 : PRE_first_tail_x15_r0_body.kr0_125.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_125.flags (PRE_first_tail_x15_r0_body.clo125.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_125.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0125 : PRE_first_tail_x15_r0_body.kr0_125.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_125.targs (PRE_first_tail_x15_r0_body.clo125.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_125.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1125 : PRE_first_tail_x15_r0_body.kr1_125.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_125.flags (PRE_first_tail_x15_r0_body.cwS125.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_125.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1125 : PRE_first_tail_x15_r0_body.kr1_125.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_125.targs (PRE_first_tail_x15_r0_body.cwS125.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_125.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck125 : krecLB PRE_first_tail_x15_r0_body.kappa125 5398 PRE_first_tail_x15_r0_body.cx0_125.mlx PRE_first_tail_x15_r0_body.kr0_125 PRE_first_tail_x15_r0_body.kr1_125 PRE_first_tail_x15_r0_body.clo125 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn125 : Nat.ble 5398 5398 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge125 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1208.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1209.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR125 : pendRegB PRE_first_tail_x15_r0_body.kappa125 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe125 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1208.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift125 (clean : Conv.NClean (⟨20656, 17755, 2772663, 5398⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P125.NL) (cl : SSt (· < 5398) PRE_first_tail_x15_r0_body.cx0_125.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_125.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_125.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_125.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_125.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20656, 17755, 2772663, 5398⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P125 5398 PRE_first_tail_x15_r0_body.kappa125 PRE_first_tail_x15_r0_body.s1209.ffi PRE_first_tail_x15_r0_body.s1208.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift125 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue125, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp125 t ht),
    PRE_first_tail_x15_r0_body.cbridge125,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1209.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1208.ffi) (PRE_first_tail_x15_r0_body.cfoot125 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_125 PRE_first_tail_x15_r0_body.ofx1_125 hobjC PRE_first_tail_x15_r0_body.ff0125 PRE_first_tail_x15_r0_body.ff1125 PRE_first_tail_x15_r0_body.ffck125,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1209.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1208.ffi) (PRE_first_tail_x15_r0_body.cfoot125 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_125 PRE_first_tail_x15_r0_body.okr1_125 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn125) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0125 PRE_first_tail_x15_r0_body.fkt0125 PRE_first_tail_x15_r0_body.fkf1125 PRE_first_tail_x15_r0_body.fkt1125 PRE_first_tail_x15_r0_body.fkck125,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0125 PRE_first_tail_x15_r0_body.cnh1125 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe125) PRE_first_tail_x15_r0_body.cpendR125⟩

end Host.Load.Run.Tpl
end

section -- st125/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st125 0
host_stream_state PRE_first_tail_x15_r0_body.st125 1
host_stream_state PRE_first_tail_x15_r0_body.st125 2
end Host.Load.Run.Tpl
end

section -- Site125
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 125 of chain `PRE_first_tail_x15_r0_body`: `plan__g125__g126` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1207`, the merged state `PRE_first_tail_x15_r0_body.s1208`,
the site template `PRE_first_tail_x15_r0_body.st125` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1209`: the merge.
The footprint's facts are in `SiteF125`, the compaction's in `SiteC125`, `SiteK125`, `SiteNa125`, `SiteNb125`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso125 : PRE_first_tail_x15_r0_body.st125.s0 = { PRE_first_tail_x15_r0_body.s1207 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs125 : List Frame := PRE_first_tail_x15_r0_body.s1207.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_125 : PRE_first_tail_x15_r0_body.S1207.tab.length = 5398
kernel_rfl PRE_first_tail_x15_r0_body.tab0_125 : PRE_first_tail_x15_r0_body.st125.S0.tab = PRE_first_tail_x15_r0_body.S1207.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws125 : List Nat := [3101, 3102, 3103]
kernel_rfl PRE_first_tail_x15_r0_body.fresh125 : (PRE_first_tail_x15_r0_body.S1207.tab.all fun e => PRE_first_tail_x15_r0_body.ws125.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1207.oracle.all fun q => PRE_first_tail_x15_r0_body.ws125.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab125 : PRE_first_tail_x15_r0_body.S1208.tab = PRE_first_tail_x15_r0_body.S1207.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws125
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen125 : PRE_first_tail_x15_r0_body.st125.S2.tab.length - PRE_first_tail_x15_r0_body.st125.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged125`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap125 : PRE_first_tail_x15_r0_body.s1208.heap = PRE_first_tail_x15_r0_body.st125.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext125 : PRE_first_tail_x15_r0_body.s1208.next = PRE_first_tail_x15_r0_body.st125.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl125 : PRE_first_tail_x15_r0_body.s1208.ctl = PRE_first_tail_x15_r0_body.st125.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack125 : PRE_first_tail_x15_r0_body.s1208.stack = PRE_first_tail_x15_r0_body.st125.s2.stack ++ PRE_first_tail_x15_r0_body.s1207.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs125 : PRE_first_tail_x15_r0_body.s1208.jobs = PRE_first_tail_x15_r0_body.st125.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi125 : PRE_first_tail_x15_r0_body.s1208.ffi = PRE_first_tail_x15_r0_body.st125.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace125 : PRE_first_tail_x15_r0_body.s1208.trace = PRE_first_tail_x15_r0_body.st125.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores125 : PRE_first_tail_x15_r0_body.s1208.stores = PRE_first_tail_x15_r0_body.st125.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD125
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 125 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived125 : PRE_first_tail_x15_r0_body.nr125.map (fun r => nth? PRE_first_tail_x15_r0_body.st125.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo125 : PRE_first_tail_x15_r0_body.nr125.all (Nat.ble 5398) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj125 : PRE_first_tail_x15_r0_body.cws125.all (fun c => !PRE_first_tail_x15_r0_body.ws125.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ125 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws125 PRE_first_tail_x15_r0_body.crs125 PRE_first_tail_x15_r0_body.ws125

end Host.Load.Run.Tpl
end

section -- st125/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st125`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st125.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st125.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st125.s2.heap PRE_first_tail_x15_r0_body.st125.wrR ++ freshOf PRE_first_tail_x15_r0_body.st125.s2.heap PRE_first_tail_x15_r0_body.st125.s0.next PRE_first_tail_x15_r0_body.st125.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st125.wr : List Nat := PRE_first_tail_x15_r0_body.st125.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st125.heapFoot : PRE_first_tail_x15_r0_body.st125.s2.heap = setAll PRE_first_tail_x15_r0_body.st125.s0.heap PRE_first_tail_x15_r0_body.st125.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st125.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st125.s0.next PRE_first_tail_x15_r0_body.st125.s2.next = true
theorem PRE_first_tail_x15_r0_body.st125.grows : PRE_first_tail_x15_r0_body.st125.s0.next ≤ PRE_first_tail_x15_r0_body.st125.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st125.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st125.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st125.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st125.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st125.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st125.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st125.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st125.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st125.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st125.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st125.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st125.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st125.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st125.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st125.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st125.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st125.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st125.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st125.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st125.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st125.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st125.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st125.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st125.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st125.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st125.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st125.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st125.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st125.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st125.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st125.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st125.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF125
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 125 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB125 : nodupT PRE_first_tail_x15_r0_body.st125.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup125 : PRE_first_tail_x15_r0_body.st125.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB125).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB125 : PRE_first_tail_x15_r0_body.st125.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound125 : ∀ b ∈ PRE_first_tail_x15_r0_body.st125.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB125 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr125 := PRE_first_tail_x15_r0_body.st125.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq125 : PRE_first_tail_x15_r0_body.st125.s2.trace = PRE_first_tail_x15_r0_body.trFr125 ++ PRE_first_tail_x15_r0_body.st125.s0.trace
theorem PRE_first_tail_x15_r0_body.trace125 : ∃ fr, PRE_first_tail_x15_r0_body.st125.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st125.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq125⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide125 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB125 : (PRE_first_tail_x15_r0_body.wide125.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st125.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix125 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide125, WFix Map.id (Present PRE_first_tail_x15_r0_body.st125.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB125 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL125
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 125 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1208`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO125 : PRE_first_tail_x15_r0_body.st125.S0.oracle = PRE_first_tail_x15_r0_body.st125.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B125 : PRE_first_tail_x15_r0_body.st125.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st125.s0.next || (PRE_first_tail_x15_r0_body.st125.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot125 : Conv.StageFoot PRE_first_tail_x15_r0_body.st125.wr PRE_first_tail_x15_r0_body.st125.s0 PRE_first_tail_x15_r0_body.st125.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st125.heapFoot PRE_first_tail_x15_r0_body.wrNodup125 PRE_first_tail_x15_r0_body.wrBound125 PRE_first_tail_x15_r0_body.wr0B125 PRE_first_tail_x15_r0_body.st125.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged125 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st125.F.S → PRE_first_tail_x15_r0_body.st125.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st125.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st125.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs125 PRE_first_tail_x15_r0_body.st125.wr PRE_first_tail_x15_r0_body.s1207 PRE_first_tail_x15_r0_body.st125.s2 PRE_first_tail_x15_r0_body.st125.s0
      PRE_first_tail_x15_r0_body.st125.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st125.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1208 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso125 PRE_first_tail_x15_r0_body.stFoot125 PRE_first_tail_x15_r0_body.wrNodup125 PRE_first_tail_x15_r0_body.wrBound125 PRE_first_tail_x15_r0_body.trace125 PRE_first_tail_x15_r0_body.mheap125
    PRE_first_tail_x15_r0_body.mnext125 PRE_first_tail_x15_r0_body.mctl125 PRE_first_tail_x15_r0_body.mstack125 PRE_first_tail_x15_r0_body.mjobs125 PRE_first_tail_x15_r0_body.mffi125 PRE_first_tail_x15_r0_body.mtrace125 PRE_first_tail_x15_r0_body.mstores125 h

def PRE_first_tail_x15_r0_body.arrEl125_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE125_2665 : arrOf PRE_first_tail_x15_r0_body.s1208 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl125_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA125_2665 : isArrB PRE_first_tail_x15_r0_body.s1208 2665 = true
theorem PRE_first_tail_x15_r0_body.arr125_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1208.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl125_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE125_2665 PRE_first_tail_x15_r0_body.arrA125_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN125_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl125_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR125_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl125_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN125_2665

def PRE_first_tail_x15_r0_body.arrEl125_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE125_2673467 : arrOf PRE_first_tail_x15_r0_body.s1208 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl125_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA125_2673467 : isArrB PRE_first_tail_x15_r0_body.s1208 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr125_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1208.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl125_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE125_2673467 PRE_first_tail_x15_r0_body.arrA125_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN125_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl125_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR125_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl125_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN125_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k125 : isArrB PRE_first_tail_x15_r0_body.s1208 4910 = false
theorem PRE_first_tail_x15_r0_body.keep125 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1208 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k125 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr125_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl125_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ125
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 125 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1207`, the merged
state `PRE_first_tail_x15_r0_body.s1208`, the canonical state `PRE_first_tail_x15_r0_body.s1209`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl125 : PRE_first_tail_x15_r0_body.pl125.all (Nat.ble PRE_first_tail_x15_r0_body.s1207.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd125 : nodupT PRE_first_tail_x15_r0_body.pl125 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1125 : Nat.ble PRE_first_tail_x15_r0_body.s1207.next 2772674 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst125 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1207.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn125 : PRE_first_tail_x15_r0_body.s1209.next = PRE_first_tail_x15_r0_body.s1207.next + PRE_first_tail_x15_r0_body.pl125.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn125 : PRE_first_tail_x15_r0_body.s1208.next = 2772674
kernel_rfl PRE_first_tail_x15_r0_body.zgrow125 : Nat.ble PRE_first_tail_x15_r0_body.s1209.next PRE_first_tail_x15_r0_body.s1208.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh125 : PRE_first_tail_x15_r0_body.S1207.tab.all (fun e => PRE_first_tail_x15_r0_body.cws125.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd125 : nodupT PRE_first_tail_x15_r0_body.cws125 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi125 : PRE_first_tail_x15_r0_body.nr125.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1208.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt125 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1207.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg125_2665 : PRE_first_tail_x15_r0_body.s1209.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1209 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk125_2665 : (objOf PRE_first_tail_x15_r0_body.s1209 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm125_2665 : PRE_first_tail_x15_r0_body.s1208.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa125.obj (objOf PRE_first_tail_x15_r0_body.s1209 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1208 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg125_2673467 : PRE_first_tail_x15_r0_body.s1209.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1209 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk125_2673467 : (objOf PRE_first_tail_x15_r0_body.s1209 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm125_2673467 : PRE_first_tail_x15_r0_body.s1208.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa125.obj (objOf PRE_first_tail_x15_r0_body.s1209 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1208 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw125_4910 : (PRE_first_tail_x15_r0_body.s1209.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw125_2673472 : (PRE_first_tail_x15_r0_body.s1209.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw125_2673473 : (PRE_first_tail_x15_r0_body.s1209.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd125 : PRE_first_tail_x15_r0_body.cl125.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr125 : PRE_first_tail_x15_r0_body.st125.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1207.next || PRE_first_tail_x15_r0_body.cl125.contains b) = true
def PRE_first_tail_x15_r0_body.zl125 : List Nat := PRE_first_tail_x15_r0_body.cl125.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE125 : PRE_first_tail_x15_r0_body.zl125.map (fun a => PRE_first_tail_x15_r0_body.s1208.heap.get (PRE_first_tail_x15_r0_body.kappa125.a a)) = PRE_first_tail_x15_r0_body.zl125.map (fun a => (PRE_first_tail_x15_r0_body.s1209.heap.get a).map PRE_first_tail_x15_r0_body.kappa125.hobj)
theorem PRE_first_tail_x15_r0_body.zimg125 : HeapImg PRE_first_tail_x15_r0_body.kappa125 PRE_first_tail_x15_r0_body.s1209 PRE_first_tail_x15_r0_body.s1208 PRE_first_tail_x15_r0_body.zl125 := PRE_first_tail_x15_r0_body.zimgE125
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl125 : PRE_first_tail_x15_r0_body.s1208.ctl = PRE_first_tail_x15_r0_body.kappa125.ctl PRE_first_tail_x15_r0_body.s1209.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack125 : PRE_first_tail_x15_r0_body.s1208.stack = PRE_first_tail_x15_r0_body.s1209.stack.map PRE_first_tail_x15_r0_body.kappa125.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs125 : PRE_first_tail_x15_r0_body.s1208.jobs = PRE_first_tail_x15_r0_body.s1209.jobs.map PRE_first_tail_x15_r0_body.kappa125.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores125 : PRE_first_tail_x15_r0_body.s1208.stores = PRE_first_tail_x15_r0_body.kappa125.stores PRE_first_tail_x15_r0_body.s1209.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots125 : checkRootsSupp PRE_first_tail_x15_r0_body.s1209 5398 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC125 : PRE_first_tail_x15_r0_body.S1207.tab.length + PRE_first_tail_x15_r0_body.cws125.length = 5398
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap125 : PRE_first_tail_x15_r0_body.kappa125 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1207.next 2772674 PRE_first_tail_x15_r0_body.S1207.tab.length PRE_first_tail_x15_r0_body.pl125 (PRE_first_tail_x15_r0_body.nr125.map NumV.ref) PRE_first_tail_x15_r0_body.kd125.big
  PRE_first_tail_x15_r0_body.kd125.region PRE_first_tail_x15_r0_body.kd125.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin125 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1209.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc125 : Conv.jcleanListB (⟨20656, 17755, 2772664, 5398⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1209 PRE_first_tail_x15_r0_body.cl125 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB125 : noBigRootsP (fun i => !Conv.oldBigB (⟨20656, 17755, 2772664, 5398⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1209.trace PRE_first_tail_x15_r0_body.s1209 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm125 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17755 = true
theorem PRE_first_tail_x15_r0_body.cjcl125 (h : Conv.JClean (⟨20656, 17755, 2772663, 5398⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1207) : Conv.JClean (⟨20656, 17755, 2772664, 5398⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1209 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle125)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap125 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd125 a ha)) PRE_first_tail_x15_r0_body.zjc125

end Host.Load.Run.Tpl
end

section -- st125/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st125.bodyLast from PRE_first_tail_x15_r0_body.st125.s1 to PRE_first_tail_x15_r0_body.st125.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st125.F PRE_first_tail_x15_r0_body.st125.s1).run PRE_first_tail_x15_r0_body.st125.S1 = some (PRE_first_tail_x15_r0_body.st125.s2, PRE_first_tail_x15_r0_body.st125.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st125.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st125.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st125.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st125.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st125/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st125.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st125.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st125.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st125.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st125.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st125.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st125.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st125.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st125.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st125.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st125.s0 PRE_first_tail_x15_r0_body.st125.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st125.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st125.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st125.s1 PRE_first_tail_x15_r0_body.st125.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st125/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st125.bodyK0F from PRE_first_tail_x15_r0_body.st125.s0 to PRE_first_tail_x15_r0_body.st125.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st125.F (PRE_first_tail_x15_r0_body.st125.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st125.ks 0).getD 0) PRE_first_tail_x15_r0_body.st125.s0 PRE_first_tail_x15_r0_body.st125.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st125.s1, PRE_first_tail_x15_r0_body.st125.S1)
theorem PRE_first_tail_x15_r0_body.st125.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st125.F (PRE_first_tail_x15_r0_body.st125.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st125.ks 0).getD 0) PRE_first_tail_x15_r0_body.st125.s0 PRE_first_tail_x15_r0_body.st125.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st125.s1, PRE_first_tail_x15_r0_body.st125.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st125.bodyOkLN_ok PRE_first_tail_x15_r0_body.st125.bodyK0F
end Host.Load.Run.Tpl
end

section -- st125/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st125.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st125.F (PRE_first_tail_x15_r0_body.st125.bodyOkL bytes rows) 98 PRE_first_tail_x15_r0_body.st125.s0 PRE_first_tail_x15_r0_body.st125.S0 = some (PRE_first_tail_x15_r0_body.st125.s1, PRE_first_tail_x15_r0_body.st125.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st125.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st125.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st125.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st125.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st125.F (PRE_first_tail_x15_r0_body.st125.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st125.s0
  S0 := PRE_first_tail_x15_r0_body.st125.S0
  s1 := PRE_first_tail_x15_r0_body.st125.s1
  S1 := PRE_first_tail_x15_r0_body.st125.S1
  s2 := PRE_first_tail_x15_r0_body.st125.s2
  S2 := PRE_first_tail_x15_r0_body.st125.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st125.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st125.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st125.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st125.bodyHalt
  last := PRE_first_tail_x15_r0_body.st125.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st125.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC126
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 126 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1226` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa126` into the merged state
`PRE_first_tail_x15_r0_body.s1225`. -/

def PRE_first_tail_x15_r0_body.pl126 : List Nat := [2775247, 2774422, 2775253, 2775249, 2774424, 2775255]
def PRE_first_tail_x15_r0_body.nr126 : List Nat := [5501, 5500, 5476, 5484, 5489, 5494, 5499, 5473, 5474, 5475, 5482, 5483, 5471, 5478, 5479, 5480, 5481, 5477]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd126 : RData :=
  ⟨2774141, 2775290, Stage.setAll PTrie.nil [(2774135, 2775247), (2774136, 2774422), (2774137, 2775253), (2774138, 2775249), (2774139, 2774424), (2774140, 2775255)], Stage.setAll PTrie.nil [(20690, 20716), (20691, 20694), (20692, 20717)],
   20693, 20718, 17801, 17801, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(5471, .ref 5501), (5472, .ref 5500), (5473, .ref 5476), (5474, .ref 5484), (5475, .ref 5489), (5476, .ref 5494), (5477, .ref 5499), (5478, .ref 5473), (5479, .ref 5474), (5480, .ref 5475), (5481, .ref 5482), (5482, .ref 5483), (5483, .ref 5471), (5484, .ref 5478), (5485, .ref 5479), (5486, .ref 5480), (5487, .ref 5481), (5488, .ref 5477)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa126 : Map :=
  Conv.Map.compact 2774135 2775290 5471 PRE_first_tail_x15_r0_body.pl126 (PRE_first_tail_x15_r0_body.nr126.map NumV.ref) PRE_first_tail_x15_r0_body.kd126.big
    PRE_first_tail_x15_r0_body.kd126.region PRE_first_tail_x15_r0_body.kd126.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws126 : List Nat := [3135, 3136, 3137, 3138, 3139, 3140, 3141, 3142, 3143, 3144, 3145, 3146, 3147, 3148, 3149, 3150, 3151, 3152]
noncomputable def PRE_first_tail_x15_r0_body.crs126 : List SymE := PRE_first_tail_x15_r0_body.nr126.map fun r => (nth? PRE_first_tail_x15_r0_body.S1225.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta126 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws126 PRE_first_tail_x15_r0_body.crs126
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB126 : List Nat := [2665, 2672620, 2673467, 2773309, 2773854, 2774110]

kernel_rfl PRE_first_tail_x15_r0_body.ctab126 : PRE_first_tail_x15_r0_body.S1226.tab = PRE_first_tail_x15_r0_body.S1224.tab ++ PRE_first_tail_x15_r0_body.cws126.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace126 : PRE_first_tail_x15_r0_body.s1226.trace = PRE_first_tail_x15_r0_body.s1224.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext126 : PRE_first_tail_x15_r0_body.s1226.next = 2774141
kernel_rfl PRE_first_tail_x15_r0_body.ccounters126 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx.nnext) = (20693, 17801)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue126 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1225.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa126.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp126 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx.tokens.all (bSN 5489) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean126 : Conv.cleanListB 20693 131072 (fun r => Nat.ble 82772 r) PRE_first_tail_x15_r0_body.s1226
    (PRE_first_tail_x15_r0_body.wrB126 ++ (List.range 6).map (2774135 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs126 : bigsOutB 20693 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK126
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl126`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl126 : List Nat := [2665, 2672620, 2673467, 2773309, 2773854, 2774110, 2774135, 2774136, 2774137, 2774138, 2774139, 2774140]
def PRE_first_tail_x15_r0_body.clo126 : List Nat := [20670, 20683, 20689, 20690, 20691, 20692]
def PRE_first_tail_x15_r0_body.cln126 : List Nat := [17774, 17775, 17776, 17777, 17778, 17779, 17780, 17781, 17782, 17783, 17784, 17785, 17786, 17787, 17788, 17789, 17790, 17791, 17792, 17793, 17794, 17795, 17796, 17797, 17798, 17799, 17800]
def PRE_first_tail_x15_r0_body.cli126 : List Nat := [17774, 17775, 17776, 17777, 17778, 17779, 17780, 17781, 17782, 17783, 17784, 17785, 17786, 17787, 17788, 17789, 17790, 17791, 17792, 17793, 17794, 17795, 17796, 17797, 17798, 17799, 17800]
kernel_rfl PRE_first_tail_x15_r0_body.cheap126 : PRE_first_tail_x15_r0_body.s1226.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1224.heap (PRE_first_tail_x15_r0_body.cl126.filterMap fun a => (PRE_first_tail_x15_r0_body.s1226.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe126 : Nat.ble PRE_first_tail_x15_r0_body.s1224.next PRE_first_tail_x15_r0_body.s1226.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP126 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1224 PRE_first_tail_x15_r0_body.s1226 PRE_first_tail_x15_r0_body.cl126 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp126 : Conv.suppListB PRE_first_tail_x15_r0_body.s1226 5489 PRE_first_tail_x15_r0_body.cl126 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound126 : Conv.boundListB PRE_first_tail_x15_r0_body.s1226 PRE_first_tail_x15_r0_body.cl126 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK126 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln126.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK126 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo126.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK126 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli126.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst126 : Conv.sstListB 5489 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx PRE_first_tail_x15_r0_body.cln126 PRE_first_tail_x15_r0_body.clo126 PRE_first_tail_x15_r0_body.cli126 = true

end Host.Load.Run.Tpl
end

section -- SiteCl126
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA126 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo126.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd126 : (PRE_first_tail_x15_r0_body.clo126 ++ PRE_first_tail_x15_r0_body.cln126 ++ PRE_first_tail_x15_r0_body.cli126).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle126 : Conv.Cnt.leB (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt) (⟨20693, 17801, 2774141, 5489⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck126 : Conv.ncleanListB (⟨20693, 17801, 2774141, 5489⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx PRE_first_tail_x15_r0_body.clo126 PRE_first_tail_x15_r0_body.cln126 PRE_first_tail_x15_r0_body.cli126 = true
theorem PRE_first_tail_x15_r0_body.cncl126 (h : Conv.NClean (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx) : Conv.NClean (⟨20693, 17801, 2774141, 5489⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle126 PRE_first_tail_x15_r0_body.ckA126 PRE_first_tail_x15_r0_body.cobjsK126 PRE_first_tail_x15_r0_body.cnodesK126 PRE_first_tail_x15_r0_body.citemsK126 PRE_first_tail_x15_r0_body.cbd126 PRE_first_tail_x15_r0_body.cck126

end Host.Load.Run.Tpl
end

section -- SiteS126
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 126 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc126 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P126 : LoadP := PRE_first_tail_x15_r0_body.Pc126.raise 17801
kernel_rfl PRE_first_tail_x15_r0_body.craise126 : Nat.ble PRE_first_tail_x15_r0_body.Pc126.N0 17801 = true
theorem PRE_first_tail_x15_r0_body.raised126 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc126 PRE_first_tail_x15_r0_body.P126 :=
  .inr ⟨17801, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise126, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_126 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_126 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1225.ffi)
def PRE_first_tail_x15_r0_body.khinv126 : PTrie Nat := Stage.setAll PTrie.nil [(20716, 20690), (20694, 20691), (20717, 20692)]
def PRE_first_tail_x15_r0_body.kninv126 : PTrie Nat := Stage.setAll PTrie.nil [(17774, 17774), (17775, 17775), (17776, 17776), (17777, 17777), (17778, 17778), (17779, 17779), (17780, 17780), (17781, 17781), (17782, 17782), (17783, 17783), (17784, 17784), (17785, 17785), (17786, 17786), (17787, 17787), (17788, 17788), (17789, 17789), (17790, 17790), (17791, 17791), (17792, 17792), (17793, 17793), (17794, 17794), (17795, 17795), (17796, 17796), (17797, 17797), (17798, 17798), (17799, 17799), (17800, 17800)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS126 : List Nat := [20670, 20683, 20689, 20690, 20691, 20692, 20693, 20694, 20695, 20696, 20697, 20698, 20699, 20700, 20701, 20702, 20703, 20704, 20705, 20706, 20707, 20708, 20709, 20710, 20711, 20712, 20713, 20714, 20715, 20716, 20717]
def PRE_first_tail_x15_r0_body.cnS126 : List Nat := List.range' 17774 27
def PRE_first_tail_x15_r0_body.ciS126 : List Nat := [] ++ List.range' 17774 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0126 : PRE_first_tail_x15_r0_body.kd126.nh0 = PRE_first_tail_x15_r0_body.cx0_126.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1126 : PRE_first_tail_x15_r0_body.kd126.nh1 = PRE_first_tail_x15_r0_body.cx1_126.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0126 : PRE_first_tail_x15_r0_body.kd126.nn0 = PRE_first_tail_x15_r0_body.cx0_126.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1126 : PRE_first_tail_x15_r0_body.kd126.nn1 = PRE_first_tail_x15_r0_body.cx1_126.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo126 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P126.lo && Nat.ble PRE_first_tail_x15_r0_body.P126.lo PRE_first_tail_x15_r0_body.cx0_126.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P126.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P126.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt126 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_126.mlx.next PRE_first_tail_x15_r0_body.cx1_126.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_126.mlx.nnext PRE_first_tail_x15_r0_body.cx1_126.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband126 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P126.NL && Nat.ble PRE_first_tail_x15_r0_body.P126.NL PRE_first_tail_x15_r0_body.P126.N0 && Nat.ble PRE_first_tail_x15_r0_body.P126.N0 PRE_first_tail_x15_r0_body.cx0_126.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow126 : PRE_first_tail_x15_r0_body.kd126.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren126 : checkRenG PRE_first_tail_x15_r0_body.kd126.hnd PRE_first_tail_x15_r0_body.khinv126 (phB PRE_first_tail_x15_r0_body.cx0_126.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband126 : PRE_first_tail_x15_r0_body.kd126.checkBand PRE_first_tail_x15_r0_body.P126.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos126 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd126.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren126 : checkRenG PRE_first_tail_x15_r0_body.kd126.node PRE_first_tail_x15_r0_body.kninv126 (pnB PRE_first_tail_x15_r0_body.cx0_126.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow126 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd126.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P126.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd126.nodeF j) PRE_first_tail_x15_r0_body.cx1_126.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a126 : PRE_first_tail_x15_r0_body.cx0_126.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b126 : PRE_first_tail_x15_r0_body.cx0_126.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1126 : PRE_first_tail_x15_r0_body.cx1_126.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend126 : PRE_first_tail_x15_r0_body.cx1_126.mlx.pending = PRE_first_tail_x15_r0_body.cx0_126.mlx.pending.map PRE_first_tail_x15_r0_body.kappa126.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh126 : PRE_first_tail_x15_r0_body.cx1_126.mlx.errh = PRE_first_tail_x15_r0_body.cx0_126.mlx.errh.map PRE_first_tail_x15_r0_body.kappa126.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles126 : PRE_first_tail_x15_r0_body.cx1_126.mlx.files = PRE_first_tail_x15_r0_body.cx0_126.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch126 : PRE_first_tail_x15_r0_body.cx1_126.mlx.arch = PRE_first_tail_x15_r0_body.cx0_126.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes126 : PRE_first_tail_x15_r0_body.cx1_126.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_126.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired126 : PRE_first_tail_x15_r0_body.cx1_126.mlx.wired = PRE_first_tail_x15_r0_body.cx0_126.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost126 : PRE_first_tail_x15_r0_body.cx1_126.host = PRE_first_tail_x15_r0_body.cx0_126.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd126`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0126 : PRE_first_tail_x15_r0_body.kd126.n0 = 2774141
kernel_rfl PRE_first_tail_x15_r0_body.ckn1126 : PRE_first_tail_x15_r0_body.kd126.n1 = 2775290
kernel_rfl PRE_first_tail_x15_r0_body.ckheap126 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd126.heap).all (fun x => Nat.ble 2774135 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl126 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd126.heap.get (2774135 + j) = nth? PRE_first_tail_x15_r0_body.pl126 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja126 : Nat.ble 2774135 2774135 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn126 : Nat.ble 5471 5471 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD126 : Nat.ble 2774135 PRE_first_tail_x15_r0_body.kd126.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn126 : Nat.ble 20690 PRE_first_tail_x15_r0_body.kd126.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn126 : Nat.ble 17774 PRE_first_tail_x15_r0_body.kd126.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb126 : Nat.ble 20690 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap126 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd126.heap).all (Nat.ble (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd126 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd126.hnd).all (Nat.ble (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode126 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd126.node).all (Nat.ble (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix126 : Conv.FixOld (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa126 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja126) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn126) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD126) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn126) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn126) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb126) PRE_first_tail_x15_r0_body.fheap126 PRE_first_tail_x15_r0_body.fhnd126 PRE_first_tail_x15_r0_body.fnode126
kernel_rfl PRE_first_tail_x15_r0_body.fcxn126 : (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn126 : (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0126 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_126.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_126.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk126 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd126.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A126 : PRE_first_tail_x15_r0_body.cx1_126.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS126.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_126.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O126 : PRE_first_tail_x15_r0_body.cx1_126.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS126.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_126.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N126 : PRE_first_tail_x15_r0_body.cx1_126.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS126.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_126.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I126 : PRE_first_tail_x15_r0_body.cx1_126.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS126.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_126.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd126 : (PRE_first_tail_x15_r0_body.clo126 ++ PRE_first_tail_x15_r0_body.cln126 ++ PRE_first_tail_x15_r0_body.cli126 ++ PRE_first_tail_x15_r0_body.cwS126 ++ PRE_first_tail_x15_r0_body.cnS126 ++ PRE_first_tail_x15_r0_body.ciS126).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW126 : PRE_first_tail_x15_r0_body.cwS126.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo126.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI126 : PRE_first_tail_x15_r0_body.ciS126.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli126.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN126 : PRE_first_tail_x15_r0_body.cnS126.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF126 : PRE_first_tail_x15_r0_body.cln126.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh126 : PRE_first_tail_x15_r0_body.clo126.all (handleOK PRE_first_tail_x15_r0_body.kappa126 PRE_first_tail_x15_r0_body.P126.lo PRE_first_tail_x15_r0_body.cx0_126.mlx PRE_first_tail_x15_r0_body.cx1_126.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo126 : PRE_first_tail_x15_r0_body.clo126.map (fun h => PRE_first_tail_x15_r0_body.cx1_126.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa126.handle h)) = PRE_first_tail_x15_r0_body.clo126.map (fun h => (PRE_first_tail_x15_r0_body.cx0_126.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa126.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok126 : PRE_first_tail_x15_r0_body.clo126.all (objOK PRE_first_tail_x15_r0_body.kappa126 PRE_first_tail_x15_r0_body.P126.NL PRE_first_tail_x15_r0_body.cx0_126.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd126 : PRE_first_tail_x15_r0_body.cln126.all (nodeOKF PRE_first_tail_x15_r0_body.kappa126 PRE_first_tail_x15_r0_body.P126 PRE_first_tail_x15_r0_body.cx0_126.mlx PRE_first_tail_x15_r0_body.cx1_126.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp126 : ((PRE_first_tail_x15_r0_body.cln126.filter (fullB PRE_first_tail_x15_r0_body.P126))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_126.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa126.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln126.filter (fullB PRE_first_tail_x15_r0_body.P126))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_126.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa126.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI126 : incrB PRE_first_tail_x15_r0_body.kd126.nodeF (List.range' 17774 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK126 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd126.node).all (fun k => Nat.ble 17774 k && Nat.blt k 17801) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL126 : (PRE_first_tail_x15_r0_body.cln126.filter (Nat.ble PRE_first_tail_x15_r0_body.P126.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd126.nodeF i) && (Nat.blt i 17801 || Nat.ble PRE_first_tail_x15_r0_body.kd126.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord126 : (PRE_first_tail_x15_r0_body.cln126.filter (Nat.ble PRE_first_tail_x15_r0_body.P126.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd126.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd126.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd126.nodeF j) (PRE_first_tail_x15_r0_body.kd126.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow126 PRE_first_tail_x15_r0_body.cnn1126 PRE_first_tail_x15_r0_body.fnordI126 PRE_first_tail_x15_r0_body.fnordK126 PRE_first_tail_x15_r0_body.fnordL126
kernel_rfl PRE_first_tail_x15_r0_body.fi126 : PRE_first_tail_x15_r0_body.cli126.all (pnB PRE_first_tail_x15_r0_body.cx0_126.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii126 : PRE_first_tail_x15_r0_body.cli126.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_126.mlx.items.get (PRE_first_tail_x15_r0_body.kappa126.node k) = (PRE_first_tail_x15_r0_body.cx0_126.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa126.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot126 (clean : Conv.NClean (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P126.NL) (cl : SSt (· < 5489) PRE_first_tail_x15_r0_body.cx0_126.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P126 5489 PRE_first_tail_x15_r0_body.kappa126 PRE_first_tail_x15_r0_body.kd126 PRE_first_tail_x15_r0_body.khinv126 PRE_first_tail_x15_r0_body.kninv126 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx PRE_first_tail_x15_r0_body.cx0_126.mlx PRE_first_tail_x15_r0_body.cx1_126.mlx (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo126 PRE_first_tail_x15_r0_body.cln126 PRE_first_tail_x15_r0_body.cli126 PRE_first_tail_x15_r0_body.cwS126 PRE_first_tail_x15_r0_body.cnS126 PRE_first_tail_x15_r0_body.ciS126 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0126, PRE_first_tail_x15_r0_body.cnh1126, PRE_first_tail_x15_r0_body.cnn0126, PRE_first_tail_x15_r0_body.cnn1126, PRE_first_tail_x15_r0_body.cplo126, PRE_first_tail_x15_r0_body.ccnt126, PRE_first_tail_x15_r0_body.cnband126, PRE_first_tail_x15_r0_body.chbelow126, PRE_first_tail_x15_r0_body.chren126, PRE_first_tail_x15_r0_body.cband126, PRE_first_tail_x15_r0_body.cnh1pos126, PRE_first_tail_x15_r0_body.cnren126, PRE_first_tail_x15_r0_body.cnlow126, PRE_first_tail_x15_r0_body.cabs0a126, PRE_first_tail_x15_r0_body.cabs0b126, PRE_first_tail_x15_r0_body.ctok1126, PRE_first_tail_x15_r0_body.cpend126, PRE_first_tail_x15_r0_body.cerrh126, PRE_first_tail_x15_r0_body.cfiles126, PRE_first_tail_x15_r0_body.carch126, PRE_first_tail_x15_r0_body.csizes126, PRE_first_tail_x15_r0_body.cwired126, PRE_first_tail_x15_r0_body.cfix126, clean, PRE_first_tail_x15_r0_body.fcxn126, PRE_first_tail_x15_r0_body.fcnn126, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0126, PRE_first_tail_x15_r0_body.fnk126, PRE_first_tail_x15_r0_body.ckA126, PRE_first_tail_x15_r0_body.cobjsK126, PRE_first_tail_x15_r0_body.cnodesK126, PRE_first_tail_x15_r0_body.citemsK126, PRE_first_tail_x15_r0_body.f1A126, PRE_first_tail_x15_r0_body.f1O126, PRE_first_tail_x15_r0_body.f1N126, PRE_first_tail_x15_r0_body.f1I126, PRE_first_tail_x15_r0_body.fbd126, PRE_first_tail_x15_r0_body.fincW126, PRE_first_tail_x15_r0_body.fincI126, PRE_first_tail_x15_r0_body.fincN126, PRE_first_tail_x15_r0_body.flnF126, PRE_first_tail_x15_r0_body.fh126, PRE_first_tail_x15_r0_body.fo126, PRE_first_tail_x15_r0_body.fok126, PRE_first_tail_x15_r0_body.fnd126, PRE_first_tail_x15_r0_body.fp126, PRE_first_tail_x15_r0_body.fnord126, PRE_first_tail_x15_r0_body.fi126, PRE_first_tail_x15_r0_body.fii126⟩
theorem PRE_first_tail_x15_r0_body.cnshift126 (clean : Conv.NClean (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P126.NL) (cl : SSt (· < 5489) PRE_first_tail_x15_r0_body.cx0_126.mlx) : NShift PRE_first_tail_x15_r0_body.P126 5489 PRE_first_tail_x15_r0_body.kappa126 PRE_first_tail_x15_r0_body.cx0_126 PRE_first_tail_x15_r0_body.cx1_126 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot126 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost126 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0126 PRE_first_tail_x15_r0_body.ckn1126 PRE_first_tail_x15_r0_body.ckheap126 PRE_first_tail_x15_r0_body.ckpl126)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_126 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1224.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_126 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1224.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_126 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1224.ffi) = some PRE_first_tail_x15_r0_body.fxC_126
kernel_rfl PRE_first_tail_x15_r0_body.okrC_126 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1224.ffi) = some PRE_first_tail_x15_r0_body.krC_126
noncomputable def PRE_first_tail_x15_r0_body.fx0_126 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1226.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_126 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1226.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_126 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1226.ffi) = some PRE_first_tail_x15_r0_body.fx0_126
kernel_rfl PRE_first_tail_x15_r0_body.okr0_126 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1226.ffi) = some PRE_first_tail_x15_r0_body.kr0_126
noncomputable def PRE_first_tail_x15_r0_body.fx1_126 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1225.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_126 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1225.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_126 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1225.ffi) = some PRE_first_tail_x15_r0_body.fx1_126
kernel_rfl PRE_first_tail_x15_r0_body.okr1_126 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1225.ffi) = some PRE_first_tail_x15_r0_body.kr1_126
kernel_rfl PRE_first_tail_x15_r0_body.ff0126 : PRE_first_tail_x15_r0_body.fx0_126 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_126 (PRE_first_tail_x15_r0_body.clo126.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_126.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1126 : PRE_first_tail_x15_r0_body.fx1_126 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_126 (PRE_first_tail_x15_r0_body.cwS126.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_126.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck126 : freedLB PRE_first_tail_x15_r0_body.kappa126 PRE_first_tail_x15_r0_body.cx0_126.mlx PRE_first_tail_x15_r0_body.fx0_126 PRE_first_tail_x15_r0_body.fx1_126 PRE_first_tail_x15_r0_body.clo126 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0126 : PRE_first_tail_x15_r0_body.kr0_126.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_126.flags (PRE_first_tail_x15_r0_body.clo126.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_126.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0126 : PRE_first_tail_x15_r0_body.kr0_126.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_126.targs (PRE_first_tail_x15_r0_body.clo126.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_126.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1126 : PRE_first_tail_x15_r0_body.kr1_126.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_126.flags (PRE_first_tail_x15_r0_body.cwS126.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_126.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1126 : PRE_first_tail_x15_r0_body.kr1_126.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_126.targs (PRE_first_tail_x15_r0_body.cwS126.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_126.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck126 : krecLB PRE_first_tail_x15_r0_body.kappa126 5489 PRE_first_tail_x15_r0_body.cx0_126.mlx PRE_first_tail_x15_r0_body.kr0_126 PRE_first_tail_x15_r0_body.kr1_126 PRE_first_tail_x15_r0_body.clo126 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn126 : Nat.ble 5471 5489 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge126 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1225.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1226.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR126 : pendRegB PRE_first_tail_x15_r0_body.kappa126 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe126 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1225.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift126 (clean : Conv.NClean (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P126.NL) (cl : SSt (· < 5489) PRE_first_tail_x15_r0_body.cx0_126.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_126.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_126.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_126.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_126.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P126 5489 PRE_first_tail_x15_r0_body.kappa126 PRE_first_tail_x15_r0_body.s1226.ffi PRE_first_tail_x15_r0_body.s1225.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift126 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue126, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp126 t ht),
    PRE_first_tail_x15_r0_body.cbridge126,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1226.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1225.ffi) (PRE_first_tail_x15_r0_body.cfoot126 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_126 PRE_first_tail_x15_r0_body.ofx1_126 hobjC PRE_first_tail_x15_r0_body.ff0126 PRE_first_tail_x15_r0_body.ff1126 PRE_first_tail_x15_r0_body.ffck126,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1226.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1225.ffi) (PRE_first_tail_x15_r0_body.cfoot126 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_126 PRE_first_tail_x15_r0_body.okr1_126 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn126) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0126 PRE_first_tail_x15_r0_body.fkt0126 PRE_first_tail_x15_r0_body.fkf1126 PRE_first_tail_x15_r0_body.fkt1126 PRE_first_tail_x15_r0_body.fkck126,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0126 PRE_first_tail_x15_r0_body.cnh1126 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe126) PRE_first_tail_x15_r0_body.cpendR126⟩

end Host.Load.Run.Tpl
end

section -- st126/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st126 0
host_stream_state PRE_first_tail_x15_r0_body.st126 1
host_stream_state PRE_first_tail_x15_r0_body.st126 2
host_stream_state PRE_first_tail_x15_r0_body.st126 3
host_stream_state PRE_first_tail_x15_r0_body.st126 4
host_stream_state PRE_first_tail_x15_r0_body.st126 5
end Host.Load.Run.Tpl
end

section -- Site126
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 126 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g126__g127` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s1224`, the merged state `PRE_first_tail_x15_r0_body.s1225`,
the site template `PRE_first_tail_x15_r0_body.st126` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1226`: the merge.
The footprint's facts are in `SiteF126`, the compaction's in `SiteC126`, `SiteK126`, `SiteNa126`, `SiteNb126`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso126 : PRE_first_tail_x15_r0_body.st126.s0 = { PRE_first_tail_x15_r0_body.s1224 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs126 : List Frame := PRE_first_tail_x15_r0_body.s1224.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_126 : PRE_first_tail_x15_r0_body.S1224.tab.length = 5471
kernel_rfl PRE_first_tail_x15_r0_body.tab0_126 : PRE_first_tail_x15_r0_body.st126.S0.tab = PRE_first_tail_x15_r0_body.S1224.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws126 : List Nat := [3104, 3105, 3106, 3107, 3108, 3109, 3110, 3111, 3112, 3113, 3114, 3115, 3116, 3117, 3118, 3119, 3120, 3121, 3122, 3123, 3124, 3125, 3126, 3127, 3128, 3129, 3130, 3131, 3132, 3133, 3134]
kernel_rfl PRE_first_tail_x15_r0_body.fresh126 : (PRE_first_tail_x15_r0_body.S1224.tab.all fun e => PRE_first_tail_x15_r0_body.ws126.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1224.oracle.all fun q => PRE_first_tail_x15_r0_body.ws126.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab126 : PRE_first_tail_x15_r0_body.S1225.tab = PRE_first_tail_x15_r0_body.S1224.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws126
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen126 : PRE_first_tail_x15_r0_body.st126.S5.tab.length - PRE_first_tail_x15_r0_body.st126.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged126`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap126 : PRE_first_tail_x15_r0_body.s1225.heap = PRE_first_tail_x15_r0_body.st126.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext126 : PRE_first_tail_x15_r0_body.s1225.next = PRE_first_tail_x15_r0_body.st126.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl126 : PRE_first_tail_x15_r0_body.s1225.ctl = PRE_first_tail_x15_r0_body.st126.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack126 : PRE_first_tail_x15_r0_body.s1225.stack = PRE_first_tail_x15_r0_body.st126.s5.stack ++ PRE_first_tail_x15_r0_body.s1224.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs126 : PRE_first_tail_x15_r0_body.s1225.jobs = PRE_first_tail_x15_r0_body.st126.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi126 : PRE_first_tail_x15_r0_body.s1225.ffi = PRE_first_tail_x15_r0_body.st126.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace126 : PRE_first_tail_x15_r0_body.s1225.trace = PRE_first_tail_x15_r0_body.st126.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores126 : PRE_first_tail_x15_r0_body.s1225.stores = PRE_first_tail_x15_r0_body.st126.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD126
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 126 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived126 : PRE_first_tail_x15_r0_body.nr126.map (fun r => nth? PRE_first_tail_x15_r0_body.st126.S5.tab r) =
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
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo126 : PRE_first_tail_x15_r0_body.nr126.all (Nat.ble 5471) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj126 : PRE_first_tail_x15_r0_body.cws126.all (fun c => !PRE_first_tail_x15_r0_body.ws126.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ126 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws126 PRE_first_tail_x15_r0_body.crs126 PRE_first_tail_x15_r0_body.ws126

end Host.Load.Run.Tpl
end

section -- st126/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st126`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st126.wrR : List (Nat × Nat) := [(2672620, 2672621), (2773309, 2773310), (2773854, 2773855), (2774110, 2774111)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st126.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st126.s5.heap PRE_first_tail_x15_r0_body.st126.wrR ++ freshOf PRE_first_tail_x15_r0_body.st126.s5.heap PRE_first_tail_x15_r0_body.st126.s0.next PRE_first_tail_x15_r0_body.st126.s5.next
noncomputable def PRE_first_tail_x15_r0_body.st126.wr : List Nat := PRE_first_tail_x15_r0_body.st126.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st126.heapFoot : PRE_first_tail_x15_r0_body.st126.s5.heap = setAll PRE_first_tail_x15_r0_body.st126.s0.heap PRE_first_tail_x15_r0_body.st126.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st126.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st126.s0.next PRE_first_tail_x15_r0_body.st126.s5.next = true
theorem PRE_first_tail_x15_r0_body.st126.grows : PRE_first_tail_x15_r0_body.st126.s0.next ≤ PRE_first_tail_x15_r0_body.st126.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st126.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st126.wh : List Nat := [20670, 20683, 20689, 20690, 20691, 20692, 20693, 20694, 20695, 20696, 20697, 20698, 20699, 20700, 20701, 20702, 20703, 20704, 20705, 20706, 20707, 20708, 20709, 20710, 20711, 20712, 20713, 20714, 20715, 20716, 20717]
def PRE_first_tail_x15_r0_body.st126.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st126.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st126.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st126.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st126.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st126.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st126.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st126.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st126.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st126.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st126.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st126.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st126.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st126.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st126.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st126.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st126.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st126.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st126.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st126.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st126.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st126.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st126.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st126.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st126.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st126.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st126.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st126.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st126.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st126.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF126
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 126 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB126 : nodupT PRE_first_tail_x15_r0_body.st126.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup126 : PRE_first_tail_x15_r0_body.st126.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB126).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB126 : PRE_first_tail_x15_r0_body.st126.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound126 : ∀ b ∈ PRE_first_tail_x15_r0_body.st126.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB126 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr126 := PRE_first_tail_x15_r0_body.st126.s5.trace.take 120
kernel_rfl PRE_first_tail_x15_r0_body.traceEq126 : PRE_first_tail_x15_r0_body.st126.s5.trace = PRE_first_tail_x15_r0_body.trFr126 ++ PRE_first_tail_x15_r0_body.st126.s0.trace
theorem PRE_first_tail_x15_r0_body.trace126 : ∃ fr, PRE_first_tail_x15_r0_body.st126.s5.trace = fr ++ PRE_first_tail_x15_r0_body.st126.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq126⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide126 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB126 : (PRE_first_tail_x15_r0_body.wide126.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st126.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix126 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide126, WFix Map.id (Present PRE_first_tail_x15_r0_body.st126.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB126 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL126
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 126 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1225`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO126 : PRE_first_tail_x15_r0_body.st126.S0.oracle = PRE_first_tail_x15_r0_body.st126.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B126 : PRE_first_tail_x15_r0_body.st126.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st126.s0.next || (PRE_first_tail_x15_r0_body.st126.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot126 : Conv.StageFoot PRE_first_tail_x15_r0_body.st126.wr PRE_first_tail_x15_r0_body.st126.s0 PRE_first_tail_x15_r0_body.st126.s5 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st126.heapFoot PRE_first_tail_x15_r0_body.wrNodup126 PRE_first_tail_x15_r0_body.wrBound126 PRE_first_tail_x15_r0_body.wr0B126 PRE_first_tail_x15_r0_body.st126.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged126 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st126.F.S → PRE_first_tail_x15_r0_body.st126.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st126.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st126.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs126 PRE_first_tail_x15_r0_body.st126.wr PRE_first_tail_x15_r0_body.s1224 PRE_first_tail_x15_r0_body.st126.s5 PRE_first_tail_x15_r0_body.st126.s0
      PRE_first_tail_x15_r0_body.st126.s5.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st126.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1225 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso126 PRE_first_tail_x15_r0_body.stFoot126 PRE_first_tail_x15_r0_body.wrNodup126 PRE_first_tail_x15_r0_body.wrBound126 PRE_first_tail_x15_r0_body.trace126 PRE_first_tail_x15_r0_body.mheap126
    PRE_first_tail_x15_r0_body.mnext126 PRE_first_tail_x15_r0_body.mctl126 PRE_first_tail_x15_r0_body.mstack126 PRE_first_tail_x15_r0_body.mjobs126 PRE_first_tail_x15_r0_body.mffi126 PRE_first_tail_x15_r0_body.mtrace126 PRE_first_tail_x15_r0_body.mstores126 h

def PRE_first_tail_x15_r0_body.arrEl126_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE126_2665 : arrOf PRE_first_tail_x15_r0_body.s1225 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl126_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA126_2665 : isArrB PRE_first_tail_x15_r0_body.s1225 2665 = true
theorem PRE_first_tail_x15_r0_body.arr126_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1225.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl126_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE126_2665 PRE_first_tail_x15_r0_body.arrA126_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN126_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl126_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR126_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl126_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN126_2665

def PRE_first_tail_x15_r0_body.arrEl126_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE126_2673467 : arrOf PRE_first_tail_x15_r0_body.s1225 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl126_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA126_2673467 : isArrB PRE_first_tail_x15_r0_body.s1225 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr126_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1225.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl126_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE126_2673467 PRE_first_tail_x15_r0_body.arrA126_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN126_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl126_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR126_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl126_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN126_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k126 : isArrB PRE_first_tail_x15_r0_body.s1225 4910 = false
theorem PRE_first_tail_x15_r0_body.keep126 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1225 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k126 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr126_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl126_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ126
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 126 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1224`, the merged
state `PRE_first_tail_x15_r0_body.s1225`, the canonical state `PRE_first_tail_x15_r0_body.s1226`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl126 : PRE_first_tail_x15_r0_body.pl126.all (Nat.ble PRE_first_tail_x15_r0_body.s1224.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd126 : nodupT PRE_first_tail_x15_r0_body.pl126 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1126 : Nat.ble PRE_first_tail_x15_r0_body.s1224.next 2775290 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst126 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1224.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn126 : PRE_first_tail_x15_r0_body.s1226.next = PRE_first_tail_x15_r0_body.s1224.next + PRE_first_tail_x15_r0_body.pl126.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn126 : PRE_first_tail_x15_r0_body.s1225.next = 2775290
kernel_rfl PRE_first_tail_x15_r0_body.zgrow126 : Nat.ble PRE_first_tail_x15_r0_body.s1226.next PRE_first_tail_x15_r0_body.s1225.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh126 : PRE_first_tail_x15_r0_body.S1224.tab.all (fun e => PRE_first_tail_x15_r0_body.cws126.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd126 : nodupT PRE_first_tail_x15_r0_body.cws126 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi126 : PRE_first_tail_x15_r0_body.nr126.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1225.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt126 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1224.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg126_2665 : PRE_first_tail_x15_r0_body.s1226.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1226 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk126_2665 : (objOf PRE_first_tail_x15_r0_body.s1226 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm126_2665 : PRE_first_tail_x15_r0_body.s1225.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa126.obj (objOf PRE_first_tail_x15_r0_body.s1226 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1225 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg126_2673467 : PRE_first_tail_x15_r0_body.s1226.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1226 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk126_2673467 : (objOf PRE_first_tail_x15_r0_body.s1226 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm126_2673467 : PRE_first_tail_x15_r0_body.s1225.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa126.obj (objOf PRE_first_tail_x15_r0_body.s1226 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1225 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw126_4910 : (PRE_first_tail_x15_r0_body.s1226.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw126_2673472 : (PRE_first_tail_x15_r0_body.s1226.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw126_2673473 : (PRE_first_tail_x15_r0_body.s1226.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd126 : PRE_first_tail_x15_r0_body.cl126.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr126 : PRE_first_tail_x15_r0_body.st126.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1224.next || PRE_first_tail_x15_r0_body.cl126.contains b) = true
def PRE_first_tail_x15_r0_body.zl126 : List Nat := PRE_first_tail_x15_r0_body.cl126.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE126 : PRE_first_tail_x15_r0_body.zl126.map (fun a => PRE_first_tail_x15_r0_body.s1225.heap.get (PRE_first_tail_x15_r0_body.kappa126.a a)) = PRE_first_tail_x15_r0_body.zl126.map (fun a => (PRE_first_tail_x15_r0_body.s1226.heap.get a).map PRE_first_tail_x15_r0_body.kappa126.hobj)
theorem PRE_first_tail_x15_r0_body.zimg126 : HeapImg PRE_first_tail_x15_r0_body.kappa126 PRE_first_tail_x15_r0_body.s1226 PRE_first_tail_x15_r0_body.s1225 PRE_first_tail_x15_r0_body.zl126 := PRE_first_tail_x15_r0_body.zimgE126
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl126 : PRE_first_tail_x15_r0_body.s1225.ctl = PRE_first_tail_x15_r0_body.kappa126.ctl PRE_first_tail_x15_r0_body.s1226.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack126 : PRE_first_tail_x15_r0_body.s1225.stack = PRE_first_tail_x15_r0_body.s1226.stack.map PRE_first_tail_x15_r0_body.kappa126.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs126 : PRE_first_tail_x15_r0_body.s1225.jobs = PRE_first_tail_x15_r0_body.s1226.jobs.map PRE_first_tail_x15_r0_body.kappa126.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores126 : PRE_first_tail_x15_r0_body.s1225.stores = PRE_first_tail_x15_r0_body.kappa126.stores PRE_first_tail_x15_r0_body.s1226.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots126 : checkRootsSupp PRE_first_tail_x15_r0_body.s1226 5489 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC126 : PRE_first_tail_x15_r0_body.S1224.tab.length + PRE_first_tail_x15_r0_body.cws126.length = 5489
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap126 : PRE_first_tail_x15_r0_body.kappa126 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1224.next 2775290 PRE_first_tail_x15_r0_body.S1224.tab.length PRE_first_tail_x15_r0_body.pl126 (PRE_first_tail_x15_r0_body.nr126.map NumV.ref) PRE_first_tail_x15_r0_body.kd126.big
  PRE_first_tail_x15_r0_body.kd126.region PRE_first_tail_x15_r0_body.kd126.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin126 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1226.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc126 : Conv.jcleanListB (⟨20693, 17801, 2774141, 5489⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1226 PRE_first_tail_x15_r0_body.cl126 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB126 : noBigRootsP (fun i => !Conv.oldBigB (⟨20693, 17801, 2774141, 5489⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1226.trace PRE_first_tail_x15_r0_body.s1226 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm126 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17774 = true
theorem PRE_first_tail_x15_r0_body.cjcl126 (h : Conv.JClean (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1224) : Conv.JClean (⟨20693, 17801, 2774141, 5489⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1226 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle126)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap126 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd126 a ha)) PRE_first_tail_x15_r0_body.zjc126

end Host.Load.Run.Tpl
end

section -- st126/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st126.bodyLast from PRE_first_tail_x15_r0_body.st126.s4 to PRE_first_tail_x15_r0_body.st126.s5 :
  interpS (step PRE_first_tail_x15_r0_body.st126.F PRE_first_tail_x15_r0_body.st126.s4).run PRE_first_tail_x15_r0_body.st126.S4 = some (PRE_first_tail_x15_r0_body.st126.s5, PRE_first_tail_x15_r0_body.st126.S5)
kernel_rfl PRE_first_tail_x15_r0_body.st126.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st126.s4.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st126.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st126.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st126/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st126.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st126.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st126.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st126.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st126.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st126.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st126.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st126.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st126.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st126.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st126.s0 PRE_first_tail_x15_r0_body.st126.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st126.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st126.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st126.s4 PRE_first_tail_x15_r0_body.st126.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st126/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st126.bodyK0F from PRE_first_tail_x15_r0_body.st126.s0 to PRE_first_tail_x15_r0_body.st126.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st126.F (PRE_first_tail_x15_r0_body.st126.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st126.ks 0).getD 0) PRE_first_tail_x15_r0_body.st126.s0 PRE_first_tail_x15_r0_body.st126.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st126.s1, PRE_first_tail_x15_r0_body.st126.S1)
theorem PRE_first_tail_x15_r0_body.st126.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st126.F (PRE_first_tail_x15_r0_body.st126.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st126.ks 0).getD 0) PRE_first_tail_x15_r0_body.st126.s0 PRE_first_tail_x15_r0_body.st126.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st126.s1, PRE_first_tail_x15_r0_body.st126.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st126.bodyOkLN_ok PRE_first_tail_x15_r0_body.st126.bodyK0F
end Host.Load.Run.Tpl
end

section -- st126/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st126.bodyK1F from PRE_first_tail_x15_r0_body.st126.s1 to PRE_first_tail_x15_r0_body.st126.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st126.F (PRE_first_tail_x15_r0_body.st126.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st126.ks 1).getD 0) PRE_first_tail_x15_r0_body.st126.s1 PRE_first_tail_x15_r0_body.st126.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st126.s2, PRE_first_tail_x15_r0_body.st126.S2)
theorem PRE_first_tail_x15_r0_body.st126.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st126.F (PRE_first_tail_x15_r0_body.st126.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st126.ks 1).getD 0) PRE_first_tail_x15_r0_body.st126.s1 PRE_first_tail_x15_r0_body.st126.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st126.s2, PRE_first_tail_x15_r0_body.st126.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st126.bodyOkLN_ok PRE_first_tail_x15_r0_body.st126.bodyK1F
end Host.Load.Run.Tpl
end

section -- st126/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st126.bodyK2F from PRE_first_tail_x15_r0_body.st126.s2 to PRE_first_tail_x15_r0_body.st126.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st126.F (PRE_first_tail_x15_r0_body.st126.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st126.ks 2).getD 0) PRE_first_tail_x15_r0_body.st126.s2 PRE_first_tail_x15_r0_body.st126.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st126.s3, PRE_first_tail_x15_r0_body.st126.S3)
theorem PRE_first_tail_x15_r0_body.st126.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st126.F (PRE_first_tail_x15_r0_body.st126.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st126.ks 2).getD 0) PRE_first_tail_x15_r0_body.st126.s2 PRE_first_tail_x15_r0_body.st126.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st126.s3, PRE_first_tail_x15_r0_body.st126.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st126.bodyOkLN_ok PRE_first_tail_x15_r0_body.st126.bodyK2F
end Host.Load.Run.Tpl
end

section -- st126/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st126.bodyK3F from PRE_first_tail_x15_r0_body.st126.s3 to PRE_first_tail_x15_r0_body.st126.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st126.F (PRE_first_tail_x15_r0_body.st126.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st126.ks 3).getD 0) PRE_first_tail_x15_r0_body.st126.s3 PRE_first_tail_x15_r0_body.st126.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st126.s4, PRE_first_tail_x15_r0_body.st126.S4)
theorem PRE_first_tail_x15_r0_body.st126.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st126.F (PRE_first_tail_x15_r0_body.st126.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st126.ks 3).getD 0) PRE_first_tail_x15_r0_body.st126.s3 PRE_first_tail_x15_r0_body.st126.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st126.s4, PRE_first_tail_x15_r0_body.st126.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st126.bodyOkLN_ok PRE_first_tail_x15_r0_body.st126.bodyK3F
end Host.Load.Run.Tpl
end

section -- st126/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st126.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st126.F (PRE_first_tail_x15_r0_body.st126.bodyOkL bytes rows) 11334 PRE_first_tail_x15_r0_body.st126.s0 PRE_first_tail_x15_r0_body.st126.S0 = some (PRE_first_tail_x15_r0_body.st126.s4, PRE_first_tail_x15_r0_body.st126.S4) :=
  runOk_trans PRE_first_tail_x15_r0_body.st126.F (PRE_first_tail_x15_r0_body.st126.bodyOkL bytes rows) ((((nth? PRE_first_tail_x15_r0_body.st126.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st126.ks 1).getD 0)) + ((nth? PRE_first_tail_x15_r0_body.st126.ks 2).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st126.ks 3).getD 0) PRE_first_tail_x15_r0_body.st126.s0 PRE_first_tail_x15_r0_body.st126.s3 PRE_first_tail_x15_r0_body.st126.s4 PRE_first_tail_x15_r0_body.st126.S0 PRE_first_tail_x15_r0_body.st126.S3 PRE_first_tail_x15_r0_body.st126.S4 (runOk_trans PRE_first_tail_x15_r0_body.st126.F (PRE_first_tail_x15_r0_body.st126.bodyOkL bytes rows) (((nth? PRE_first_tail_x15_r0_body.st126.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st126.ks 1).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st126.ks 2).getD 0) PRE_first_tail_x15_r0_body.st126.s0 PRE_first_tail_x15_r0_body.st126.s2 PRE_first_tail_x15_r0_body.st126.s3 PRE_first_tail_x15_r0_body.st126.S0 PRE_first_tail_x15_r0_body.st126.S2 PRE_first_tail_x15_r0_body.st126.S3 (runOk_trans PRE_first_tail_x15_r0_body.st126.F (PRE_first_tail_x15_r0_body.st126.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st126.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st126.ks 1).getD 0) PRE_first_tail_x15_r0_body.st126.s0 PRE_first_tail_x15_r0_body.st126.s1 PRE_first_tail_x15_r0_body.st126.s2 PRE_first_tail_x15_r0_body.st126.S0 PRE_first_tail_x15_r0_body.st126.S1 PRE_first_tail_x15_r0_body.st126.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st126.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st126.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st126.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st126.bodyK3 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st126.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st126.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st126.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st126.F (PRE_first_tail_x15_r0_body.st126.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st126.s0
  S0 := PRE_first_tail_x15_r0_body.st126.S0
  s1 := PRE_first_tail_x15_r0_body.st126.s4
  S1 := PRE_first_tail_x15_r0_body.st126.S4
  s2 := PRE_first_tail_x15_r0_body.st126.s5
  S2 := PRE_first_tail_x15_r0_body.st126.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st126.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st126.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st126.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st126.bodyHalt
  last := PRE_first_tail_x15_r0_body.st126.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st126.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC127
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 127 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1234` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa127` into the merged state
`PRE_first_tail_x15_r0_body.s1233`. -/

def PRE_first_tail_x15_r0_body.pl127 : List Nat := []
def PRE_first_tail_x15_r0_body.nr127 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd127 : RData :=
  ⟨2774631, 2774633, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20706, 20706, 17814, 17814, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa127 : Map :=
  Conv.Map.compact 2774631 2774633 5510 PRE_first_tail_x15_r0_body.pl127 (PRE_first_tail_x15_r0_body.nr127.map NumV.ref) PRE_first_tail_x15_r0_body.kd127.big
    PRE_first_tail_x15_r0_body.kd127.region PRE_first_tail_x15_r0_body.kd127.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws127 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs127 : List SymE := PRE_first_tail_x15_r0_body.nr127.map fun r => (nth? PRE_first_tail_x15_r0_body.S1233.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta127 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws127 PRE_first_tail_x15_r0_body.crs127
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB127 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab127 : PRE_first_tail_x15_r0_body.S1234.tab = PRE_first_tail_x15_r0_body.S1232.tab ++ PRE_first_tail_x15_r0_body.cws127.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace127 : PRE_first_tail_x15_r0_body.s1234.trace = PRE_first_tail_x15_r0_body.s1232.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext127 : PRE_first_tail_x15_r0_body.s1234.next = 2774631
kernel_rfl PRE_first_tail_x15_r0_body.ccounters127 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.nnext) = (20706, 17814)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue127 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1233.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa127.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp127 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.tokens.all (bSN 5510) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean127 : Conv.cleanListB 20706 131072 (fun r => Nat.ble 82824 r) PRE_first_tail_x15_r0_body.s1234
    (PRE_first_tail_x15_r0_body.wrB127 ++ (List.range 0).map (2774631 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs127 : bigsOutB 20706 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK127
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl127`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl127 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo127 : List Nat := []
def PRE_first_tail_x15_r0_body.cln127 : List Nat := []
def PRE_first_tail_x15_r0_body.cli127 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap127 : PRE_first_tail_x15_r0_body.s1234.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1232.heap (PRE_first_tail_x15_r0_body.cl127.filterMap fun a => (PRE_first_tail_x15_r0_body.s1234.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe127 : Nat.ble PRE_first_tail_x15_r0_body.s1232.next PRE_first_tail_x15_r0_body.s1234.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP127 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1232 PRE_first_tail_x15_r0_body.s1234 PRE_first_tail_x15_r0_body.cl127 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp127 : Conv.suppListB PRE_first_tail_x15_r0_body.s1234 5510 PRE_first_tail_x15_r0_body.cl127 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound127 : Conv.boundListB PRE_first_tail_x15_r0_body.s1234 PRE_first_tail_x15_r0_body.cl127 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK127 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln127.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK127 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo127.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK127 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli127.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst127 : Conv.sstListB 5510 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx PRE_first_tail_x15_r0_body.cln127 PRE_first_tail_x15_r0_body.clo127 PRE_first_tail_x15_r0_body.cli127 = true

end Host.Load.Run.Tpl
end

section -- SiteCl127
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA127 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo127.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd127 : (PRE_first_tail_x15_r0_body.clo127 ++ PRE_first_tail_x15_r0_body.cln127 ++ PRE_first_tail_x15_r0_body.cli127).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle127 : Conv.Cnt.leB (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck127 : Conv.ncleanListB (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx PRE_first_tail_x15_r0_body.clo127 PRE_first_tail_x15_r0_body.cln127 PRE_first_tail_x15_r0_body.cli127 = true
theorem PRE_first_tail_x15_r0_body.cncl127 (h : Conv.NClean (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx) : Conv.NClean (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle127 PRE_first_tail_x15_r0_body.ckA127 PRE_first_tail_x15_r0_body.cobjsK127 PRE_first_tail_x15_r0_body.cnodesK127 PRE_first_tail_x15_r0_body.citemsK127 PRE_first_tail_x15_r0_body.cbd127 PRE_first_tail_x15_r0_body.cck127

end Host.Load.Run.Tpl
end

section -- SiteS127
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 127 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc127 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P127 : LoadP := PRE_first_tail_x15_r0_body.Pc127.raise 17814
kernel_rfl PRE_first_tail_x15_r0_body.craise127 : Nat.ble PRE_first_tail_x15_r0_body.Pc127.N0 17814 = true
theorem PRE_first_tail_x15_r0_body.raised127 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc127 PRE_first_tail_x15_r0_body.P127 :=
  .inr ⟨17814, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise127, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_127 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_127 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1233.ffi)
def PRE_first_tail_x15_r0_body.khinv127 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv127 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS127 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS127 : List Nat := List.range' 17814 0
def PRE_first_tail_x15_r0_body.ciS127 : List Nat := [] ++ List.range' 17814 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0127 : PRE_first_tail_x15_r0_body.kd127.nh0 = PRE_first_tail_x15_r0_body.cx0_127.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1127 : PRE_first_tail_x15_r0_body.kd127.nh1 = PRE_first_tail_x15_r0_body.cx1_127.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0127 : PRE_first_tail_x15_r0_body.kd127.nn0 = PRE_first_tail_x15_r0_body.cx0_127.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1127 : PRE_first_tail_x15_r0_body.kd127.nn1 = PRE_first_tail_x15_r0_body.cx1_127.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo127 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P127.lo && Nat.ble PRE_first_tail_x15_r0_body.P127.lo PRE_first_tail_x15_r0_body.cx0_127.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P127.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P127.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt127 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_127.mlx.next PRE_first_tail_x15_r0_body.cx1_127.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_127.mlx.nnext PRE_first_tail_x15_r0_body.cx1_127.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband127 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P127.NL && Nat.ble PRE_first_tail_x15_r0_body.P127.NL PRE_first_tail_x15_r0_body.P127.N0 && Nat.ble PRE_first_tail_x15_r0_body.P127.N0 PRE_first_tail_x15_r0_body.cx0_127.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow127 : PRE_first_tail_x15_r0_body.kd127.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren127 : checkRenG PRE_first_tail_x15_r0_body.kd127.hnd PRE_first_tail_x15_r0_body.khinv127 (phB PRE_first_tail_x15_r0_body.cx0_127.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband127 : PRE_first_tail_x15_r0_body.kd127.checkBand PRE_first_tail_x15_r0_body.P127.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos127 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd127.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren127 : checkRenG PRE_first_tail_x15_r0_body.kd127.node PRE_first_tail_x15_r0_body.kninv127 (pnB PRE_first_tail_x15_r0_body.cx0_127.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow127 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd127.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P127.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd127.nodeF j) PRE_first_tail_x15_r0_body.cx1_127.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a127 : PRE_first_tail_x15_r0_body.cx0_127.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b127 : PRE_first_tail_x15_r0_body.cx0_127.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1127 : PRE_first_tail_x15_r0_body.cx1_127.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend127 : PRE_first_tail_x15_r0_body.cx1_127.mlx.pending = PRE_first_tail_x15_r0_body.cx0_127.mlx.pending.map PRE_first_tail_x15_r0_body.kappa127.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh127 : PRE_first_tail_x15_r0_body.cx1_127.mlx.errh = PRE_first_tail_x15_r0_body.cx0_127.mlx.errh.map PRE_first_tail_x15_r0_body.kappa127.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles127 : PRE_first_tail_x15_r0_body.cx1_127.mlx.files = PRE_first_tail_x15_r0_body.cx0_127.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch127 : PRE_first_tail_x15_r0_body.cx1_127.mlx.arch = PRE_first_tail_x15_r0_body.cx0_127.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes127 : PRE_first_tail_x15_r0_body.cx1_127.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_127.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired127 : PRE_first_tail_x15_r0_body.cx1_127.mlx.wired = PRE_first_tail_x15_r0_body.cx0_127.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost127 : PRE_first_tail_x15_r0_body.cx1_127.host = PRE_first_tail_x15_r0_body.cx0_127.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd127`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0127 : PRE_first_tail_x15_r0_body.kd127.n0 = 2774631
kernel_rfl PRE_first_tail_x15_r0_body.ckn1127 : PRE_first_tail_x15_r0_body.kd127.n1 = 2774633
kernel_rfl PRE_first_tail_x15_r0_body.ckheap127 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd127.heap).all (fun x => Nat.ble 2774631 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl127 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd127.heap.get (2774631 + j) = nth? PRE_first_tail_x15_r0_body.pl127 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja127 : Nat.ble 2774631 2774631 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn127 : Nat.ble 5510 5510 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD127 : Nat.ble 2774631 PRE_first_tail_x15_r0_body.kd127.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn127 : Nat.ble 20706 PRE_first_tail_x15_r0_body.kd127.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn127 : Nat.ble 17814 PRE_first_tail_x15_r0_body.kd127.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb127 : Nat.ble 20706 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap127 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd127.heap).all (Nat.ble (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd127 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd127.hnd).all (Nat.ble (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode127 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd127.node).all (Nat.ble (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix127 : Conv.FixOld (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa127 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja127) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn127) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD127) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn127) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn127) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb127) PRE_first_tail_x15_r0_body.fheap127 PRE_first_tail_x15_r0_body.fhnd127 PRE_first_tail_x15_r0_body.fnode127
kernel_rfl PRE_first_tail_x15_r0_body.fcxn127 : (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn127 : (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0127 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_127.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_127.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk127 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd127.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A127 : PRE_first_tail_x15_r0_body.cx1_127.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS127.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_127.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O127 : PRE_first_tail_x15_r0_body.cx1_127.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS127.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_127.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N127 : PRE_first_tail_x15_r0_body.cx1_127.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS127.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_127.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I127 : PRE_first_tail_x15_r0_body.cx1_127.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS127.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_127.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd127 : (PRE_first_tail_x15_r0_body.clo127 ++ PRE_first_tail_x15_r0_body.cln127 ++ PRE_first_tail_x15_r0_body.cli127 ++ PRE_first_tail_x15_r0_body.cwS127 ++ PRE_first_tail_x15_r0_body.cnS127 ++ PRE_first_tail_x15_r0_body.ciS127).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW127 : PRE_first_tail_x15_r0_body.cwS127.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo127.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI127 : PRE_first_tail_x15_r0_body.ciS127.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli127.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN127 : PRE_first_tail_x15_r0_body.cnS127.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF127 : PRE_first_tail_x15_r0_body.cln127.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh127 : PRE_first_tail_x15_r0_body.clo127.all (handleOK PRE_first_tail_x15_r0_body.kappa127 PRE_first_tail_x15_r0_body.P127.lo PRE_first_tail_x15_r0_body.cx0_127.mlx PRE_first_tail_x15_r0_body.cx1_127.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo127 : PRE_first_tail_x15_r0_body.clo127.map (fun h => PRE_first_tail_x15_r0_body.cx1_127.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa127.handle h)) = PRE_first_tail_x15_r0_body.clo127.map (fun h => (PRE_first_tail_x15_r0_body.cx0_127.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa127.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok127 : PRE_first_tail_x15_r0_body.clo127.all (objOK PRE_first_tail_x15_r0_body.kappa127 PRE_first_tail_x15_r0_body.P127.NL PRE_first_tail_x15_r0_body.cx0_127.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd127 : PRE_first_tail_x15_r0_body.cln127.all (nodeOKF PRE_first_tail_x15_r0_body.kappa127 PRE_first_tail_x15_r0_body.P127 PRE_first_tail_x15_r0_body.cx0_127.mlx PRE_first_tail_x15_r0_body.cx1_127.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp127 : ((PRE_first_tail_x15_r0_body.cln127.filter (fullB PRE_first_tail_x15_r0_body.P127))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_127.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa127.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln127.filter (fullB PRE_first_tail_x15_r0_body.P127))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_127.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa127.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI127 : incrB PRE_first_tail_x15_r0_body.kd127.nodeF (List.range' 17814 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK127 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd127.node).all (fun k => Nat.ble 17814 k && Nat.blt k 17814) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL127 : (PRE_first_tail_x15_r0_body.cln127.filter (Nat.ble PRE_first_tail_x15_r0_body.P127.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd127.nodeF i) && (Nat.blt i 17814 || Nat.ble PRE_first_tail_x15_r0_body.kd127.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord127 : (PRE_first_tail_x15_r0_body.cln127.filter (Nat.ble PRE_first_tail_x15_r0_body.P127.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd127.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd127.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd127.nodeF j) (PRE_first_tail_x15_r0_body.kd127.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow127 PRE_first_tail_x15_r0_body.cnn1127 PRE_first_tail_x15_r0_body.fnordI127 PRE_first_tail_x15_r0_body.fnordK127 PRE_first_tail_x15_r0_body.fnordL127
kernel_rfl PRE_first_tail_x15_r0_body.fi127 : PRE_first_tail_x15_r0_body.cli127.all (pnB PRE_first_tail_x15_r0_body.cx0_127.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii127 : PRE_first_tail_x15_r0_body.cli127.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_127.mlx.items.get (PRE_first_tail_x15_r0_body.kappa127.node k) = (PRE_first_tail_x15_r0_body.cx0_127.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa127.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot127 (clean : Conv.NClean (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P127.NL) (cl : SSt (· < 5510) PRE_first_tail_x15_r0_body.cx0_127.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P127 5510 PRE_first_tail_x15_r0_body.kappa127 PRE_first_tail_x15_r0_body.kd127 PRE_first_tail_x15_r0_body.khinv127 PRE_first_tail_x15_r0_body.kninv127 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx PRE_first_tail_x15_r0_body.cx0_127.mlx PRE_first_tail_x15_r0_body.cx1_127.mlx (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo127 PRE_first_tail_x15_r0_body.cln127 PRE_first_tail_x15_r0_body.cli127 PRE_first_tail_x15_r0_body.cwS127 PRE_first_tail_x15_r0_body.cnS127 PRE_first_tail_x15_r0_body.ciS127 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0127, PRE_first_tail_x15_r0_body.cnh1127, PRE_first_tail_x15_r0_body.cnn0127, PRE_first_tail_x15_r0_body.cnn1127, PRE_first_tail_x15_r0_body.cplo127, PRE_first_tail_x15_r0_body.ccnt127, PRE_first_tail_x15_r0_body.cnband127, PRE_first_tail_x15_r0_body.chbelow127, PRE_first_tail_x15_r0_body.chren127, PRE_first_tail_x15_r0_body.cband127, PRE_first_tail_x15_r0_body.cnh1pos127, PRE_first_tail_x15_r0_body.cnren127, PRE_first_tail_x15_r0_body.cnlow127, PRE_first_tail_x15_r0_body.cabs0a127, PRE_first_tail_x15_r0_body.cabs0b127, PRE_first_tail_x15_r0_body.ctok1127, PRE_first_tail_x15_r0_body.cpend127, PRE_first_tail_x15_r0_body.cerrh127, PRE_first_tail_x15_r0_body.cfiles127, PRE_first_tail_x15_r0_body.carch127, PRE_first_tail_x15_r0_body.csizes127, PRE_first_tail_x15_r0_body.cwired127, PRE_first_tail_x15_r0_body.cfix127, clean, PRE_first_tail_x15_r0_body.fcxn127, PRE_first_tail_x15_r0_body.fcnn127, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0127, PRE_first_tail_x15_r0_body.fnk127, PRE_first_tail_x15_r0_body.ckA127, PRE_first_tail_x15_r0_body.cobjsK127, PRE_first_tail_x15_r0_body.cnodesK127, PRE_first_tail_x15_r0_body.citemsK127, PRE_first_tail_x15_r0_body.f1A127, PRE_first_tail_x15_r0_body.f1O127, PRE_first_tail_x15_r0_body.f1N127, PRE_first_tail_x15_r0_body.f1I127, PRE_first_tail_x15_r0_body.fbd127, PRE_first_tail_x15_r0_body.fincW127, PRE_first_tail_x15_r0_body.fincI127, PRE_first_tail_x15_r0_body.fincN127, PRE_first_tail_x15_r0_body.flnF127, PRE_first_tail_x15_r0_body.fh127, PRE_first_tail_x15_r0_body.fo127, PRE_first_tail_x15_r0_body.fok127, PRE_first_tail_x15_r0_body.fnd127, PRE_first_tail_x15_r0_body.fp127, PRE_first_tail_x15_r0_body.fnord127, PRE_first_tail_x15_r0_body.fi127, PRE_first_tail_x15_r0_body.fii127⟩
theorem PRE_first_tail_x15_r0_body.cnshift127 (clean : Conv.NClean (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P127.NL) (cl : SSt (· < 5510) PRE_first_tail_x15_r0_body.cx0_127.mlx) : NShift PRE_first_tail_x15_r0_body.P127 5510 PRE_first_tail_x15_r0_body.kappa127 PRE_first_tail_x15_r0_body.cx0_127 PRE_first_tail_x15_r0_body.cx1_127 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot127 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost127 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0127 PRE_first_tail_x15_r0_body.ckn1127 PRE_first_tail_x15_r0_body.ckheap127 PRE_first_tail_x15_r0_body.ckpl127)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_127 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1232.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_127 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1232.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_127 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1232.ffi) = some PRE_first_tail_x15_r0_body.fxC_127
kernel_rfl PRE_first_tail_x15_r0_body.okrC_127 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1232.ffi) = some PRE_first_tail_x15_r0_body.krC_127
noncomputable def PRE_first_tail_x15_r0_body.fx0_127 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1234.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_127 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1234.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_127 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1234.ffi) = some PRE_first_tail_x15_r0_body.fx0_127
kernel_rfl PRE_first_tail_x15_r0_body.okr0_127 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1234.ffi) = some PRE_first_tail_x15_r0_body.kr0_127
noncomputable def PRE_first_tail_x15_r0_body.fx1_127 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1233.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_127 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1233.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_127 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1233.ffi) = some PRE_first_tail_x15_r0_body.fx1_127
kernel_rfl PRE_first_tail_x15_r0_body.okr1_127 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1233.ffi) = some PRE_first_tail_x15_r0_body.kr1_127
kernel_rfl PRE_first_tail_x15_r0_body.ff0127 : PRE_first_tail_x15_r0_body.fx0_127 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_127 (PRE_first_tail_x15_r0_body.clo127.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_127.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1127 : PRE_first_tail_x15_r0_body.fx1_127 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_127 (PRE_first_tail_x15_r0_body.cwS127.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_127.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck127 : freedLB PRE_first_tail_x15_r0_body.kappa127 PRE_first_tail_x15_r0_body.cx0_127.mlx PRE_first_tail_x15_r0_body.fx0_127 PRE_first_tail_x15_r0_body.fx1_127 PRE_first_tail_x15_r0_body.clo127 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0127 : PRE_first_tail_x15_r0_body.kr0_127.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_127.flags (PRE_first_tail_x15_r0_body.clo127.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_127.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0127 : PRE_first_tail_x15_r0_body.kr0_127.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_127.targs (PRE_first_tail_x15_r0_body.clo127.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_127.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1127 : PRE_first_tail_x15_r0_body.kr1_127.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_127.flags (PRE_first_tail_x15_r0_body.cwS127.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_127.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1127 : PRE_first_tail_x15_r0_body.kr1_127.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_127.targs (PRE_first_tail_x15_r0_body.cwS127.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_127.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck127 : krecLB PRE_first_tail_x15_r0_body.kappa127 5510 PRE_first_tail_x15_r0_body.cx0_127.mlx PRE_first_tail_x15_r0_body.kr0_127 PRE_first_tail_x15_r0_body.kr1_127 PRE_first_tail_x15_r0_body.clo127 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn127 : Nat.ble 5510 5510 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge127 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1233.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1234.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR127 : pendRegB PRE_first_tail_x15_r0_body.kappa127 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe127 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1233.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift127 (clean : Conv.NClean (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P127.NL) (cl : SSt (· < 5510) PRE_first_tail_x15_r0_body.cx0_127.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_127.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_127.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_127.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_127.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P127 5510 PRE_first_tail_x15_r0_body.kappa127 PRE_first_tail_x15_r0_body.s1234.ffi PRE_first_tail_x15_r0_body.s1233.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift127 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue127, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp127 t ht),
    PRE_first_tail_x15_r0_body.cbridge127,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1234.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1233.ffi) (PRE_first_tail_x15_r0_body.cfoot127 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_127 PRE_first_tail_x15_r0_body.ofx1_127 hobjC PRE_first_tail_x15_r0_body.ff0127 PRE_first_tail_x15_r0_body.ff1127 PRE_first_tail_x15_r0_body.ffck127,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1234.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1233.ffi) (PRE_first_tail_x15_r0_body.cfoot127 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_127 PRE_first_tail_x15_r0_body.okr1_127 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn127) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0127 PRE_first_tail_x15_r0_body.fkt0127 PRE_first_tail_x15_r0_body.fkf1127 PRE_first_tail_x15_r0_body.fkt1127 PRE_first_tail_x15_r0_body.fkck127,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0127 PRE_first_tail_x15_r0_body.cnh1127 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe127) PRE_first_tail_x15_r0_body.cpendR127⟩

end Host.Load.Run.Tpl
end

section -- st127/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st127 0
host_stream_state PRE_first_tail_x15_r0_body.st127 1
host_stream_state PRE_first_tail_x15_r0_body.st127 2
end Host.Load.Run.Tpl
end

section -- Site127
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 127 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g127__g128` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1232`, the merged state `PRE_first_tail_x15_r0_body.s1233`,
the site template `PRE_first_tail_x15_r0_body.st127` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1234`: the merge.
The footprint's facts are in `SiteF127`, the compaction's in `SiteC127`, `SiteK127`, `SiteNa127`, `SiteNb127`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso127 : PRE_first_tail_x15_r0_body.st127.s0 = { PRE_first_tail_x15_r0_body.s1232 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs127 : List Frame := PRE_first_tail_x15_r0_body.s1232.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_127 : PRE_first_tail_x15_r0_body.S1232.tab.length = 5510
kernel_rfl PRE_first_tail_x15_r0_body.tab0_127 : PRE_first_tail_x15_r0_body.st127.S0.tab = PRE_first_tail_x15_r0_body.S1232.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws127 : List Nat := [3153, 3154]
kernel_rfl PRE_first_tail_x15_r0_body.fresh127 : (PRE_first_tail_x15_r0_body.S1232.tab.all fun e => PRE_first_tail_x15_r0_body.ws127.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1232.oracle.all fun q => PRE_first_tail_x15_r0_body.ws127.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab127 : PRE_first_tail_x15_r0_body.S1233.tab = PRE_first_tail_x15_r0_body.S1232.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws127
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen127 : PRE_first_tail_x15_r0_body.st127.S2.tab.length - PRE_first_tail_x15_r0_body.st127.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged127`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap127 : PRE_first_tail_x15_r0_body.s1233.heap = PRE_first_tail_x15_r0_body.st127.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext127 : PRE_first_tail_x15_r0_body.s1233.next = PRE_first_tail_x15_r0_body.st127.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl127 : PRE_first_tail_x15_r0_body.s1233.ctl = PRE_first_tail_x15_r0_body.st127.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack127 : PRE_first_tail_x15_r0_body.s1233.stack = PRE_first_tail_x15_r0_body.st127.s2.stack ++ PRE_first_tail_x15_r0_body.s1232.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs127 : PRE_first_tail_x15_r0_body.s1233.jobs = PRE_first_tail_x15_r0_body.st127.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi127 : PRE_first_tail_x15_r0_body.s1233.ffi = PRE_first_tail_x15_r0_body.st127.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace127 : PRE_first_tail_x15_r0_body.s1233.trace = PRE_first_tail_x15_r0_body.st127.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores127 : PRE_first_tail_x15_r0_body.s1233.stores = PRE_first_tail_x15_r0_body.st127.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD127
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 127 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived127 : PRE_first_tail_x15_r0_body.nr127.map (fun r => nth? PRE_first_tail_x15_r0_body.st127.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo127 : PRE_first_tail_x15_r0_body.nr127.all (Nat.ble 5510) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj127 : PRE_first_tail_x15_r0_body.cws127.all (fun c => !PRE_first_tail_x15_r0_body.ws127.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ127 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws127 PRE_first_tail_x15_r0_body.crs127 PRE_first_tail_x15_r0_body.ws127

end Host.Load.Run.Tpl
end

section -- st127/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st127`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st127.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st127.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st127.s2.heap PRE_first_tail_x15_r0_body.st127.wrR ++ freshOf PRE_first_tail_x15_r0_body.st127.s2.heap PRE_first_tail_x15_r0_body.st127.s0.next PRE_first_tail_x15_r0_body.st127.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st127.wr : List Nat := PRE_first_tail_x15_r0_body.st127.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st127.heapFoot : PRE_first_tail_x15_r0_body.st127.s2.heap = setAll PRE_first_tail_x15_r0_body.st127.s0.heap PRE_first_tail_x15_r0_body.st127.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st127.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st127.s0.next PRE_first_tail_x15_r0_body.st127.s2.next = true
theorem PRE_first_tail_x15_r0_body.st127.grows : PRE_first_tail_x15_r0_body.st127.s0.next ≤ PRE_first_tail_x15_r0_body.st127.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st127.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st127.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st127.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st127.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st127.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st127.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st127.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st127.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st127.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st127.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st127.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st127.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st127.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st127.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st127.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st127.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st127.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st127.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st127.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st127.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st127.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st127.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st127.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st127.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st127.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st127.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st127.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st127.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st127.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st127.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st127.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st127.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF127
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 127 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB127 : nodupT PRE_first_tail_x15_r0_body.st127.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup127 : PRE_first_tail_x15_r0_body.st127.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB127).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB127 : PRE_first_tail_x15_r0_body.st127.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound127 : ∀ b ∈ PRE_first_tail_x15_r0_body.st127.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB127 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr127 := PRE_first_tail_x15_r0_body.st127.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq127 : PRE_first_tail_x15_r0_body.st127.s2.trace = PRE_first_tail_x15_r0_body.trFr127 ++ PRE_first_tail_x15_r0_body.st127.s0.trace
theorem PRE_first_tail_x15_r0_body.trace127 : ∃ fr, PRE_first_tail_x15_r0_body.st127.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st127.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq127⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide127 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB127 : (PRE_first_tail_x15_r0_body.wide127.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st127.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix127 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide127, WFix Map.id (Present PRE_first_tail_x15_r0_body.st127.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB127 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL127
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 127 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1233`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO127 : PRE_first_tail_x15_r0_body.st127.S0.oracle = PRE_first_tail_x15_r0_body.st127.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B127 : PRE_first_tail_x15_r0_body.st127.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st127.s0.next || (PRE_first_tail_x15_r0_body.st127.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot127 : Conv.StageFoot PRE_first_tail_x15_r0_body.st127.wr PRE_first_tail_x15_r0_body.st127.s0 PRE_first_tail_x15_r0_body.st127.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st127.heapFoot PRE_first_tail_x15_r0_body.wrNodup127 PRE_first_tail_x15_r0_body.wrBound127 PRE_first_tail_x15_r0_body.wr0B127 PRE_first_tail_x15_r0_body.st127.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged127 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st127.F.S → PRE_first_tail_x15_r0_body.st127.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st127.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st127.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs127 PRE_first_tail_x15_r0_body.st127.wr PRE_first_tail_x15_r0_body.s1232 PRE_first_tail_x15_r0_body.st127.s2 PRE_first_tail_x15_r0_body.st127.s0
      PRE_first_tail_x15_r0_body.st127.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st127.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1233 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso127 PRE_first_tail_x15_r0_body.stFoot127 PRE_first_tail_x15_r0_body.wrNodup127 PRE_first_tail_x15_r0_body.wrBound127 PRE_first_tail_x15_r0_body.trace127 PRE_first_tail_x15_r0_body.mheap127
    PRE_first_tail_x15_r0_body.mnext127 PRE_first_tail_x15_r0_body.mctl127 PRE_first_tail_x15_r0_body.mstack127 PRE_first_tail_x15_r0_body.mjobs127 PRE_first_tail_x15_r0_body.mffi127 PRE_first_tail_x15_r0_body.mtrace127 PRE_first_tail_x15_r0_body.mstores127 h

def PRE_first_tail_x15_r0_body.arrEl127_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE127_2665 : arrOf PRE_first_tail_x15_r0_body.s1233 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl127_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA127_2665 : isArrB PRE_first_tail_x15_r0_body.s1233 2665 = true
theorem PRE_first_tail_x15_r0_body.arr127_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1233.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl127_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE127_2665 PRE_first_tail_x15_r0_body.arrA127_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN127_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl127_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR127_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl127_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN127_2665

def PRE_first_tail_x15_r0_body.arrEl127_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE127_2673467 : arrOf PRE_first_tail_x15_r0_body.s1233 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl127_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA127_2673467 : isArrB PRE_first_tail_x15_r0_body.s1233 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr127_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1233.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl127_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE127_2673467 PRE_first_tail_x15_r0_body.arrA127_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN127_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl127_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR127_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl127_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN127_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k127 : isArrB PRE_first_tail_x15_r0_body.s1233 4910 = false
theorem PRE_first_tail_x15_r0_body.keep127 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1233 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k127 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr127_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl127_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ127
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 127 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1232`, the merged
state `PRE_first_tail_x15_r0_body.s1233`, the canonical state `PRE_first_tail_x15_r0_body.s1234`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl127 : PRE_first_tail_x15_r0_body.pl127.all (Nat.ble PRE_first_tail_x15_r0_body.s1232.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd127 : nodupT PRE_first_tail_x15_r0_body.pl127 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1127 : Nat.ble PRE_first_tail_x15_r0_body.s1232.next 2774633 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst127 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1232.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn127 : PRE_first_tail_x15_r0_body.s1234.next = PRE_first_tail_x15_r0_body.s1232.next + PRE_first_tail_x15_r0_body.pl127.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn127 : PRE_first_tail_x15_r0_body.s1233.next = 2774633
kernel_rfl PRE_first_tail_x15_r0_body.zgrow127 : Nat.ble PRE_first_tail_x15_r0_body.s1234.next PRE_first_tail_x15_r0_body.s1233.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh127 : PRE_first_tail_x15_r0_body.S1232.tab.all (fun e => PRE_first_tail_x15_r0_body.cws127.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd127 : nodupT PRE_first_tail_x15_r0_body.cws127 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi127 : PRE_first_tail_x15_r0_body.nr127.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1233.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt127 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1232.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg127_2665 : PRE_first_tail_x15_r0_body.s1234.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1234 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk127_2665 : (objOf PRE_first_tail_x15_r0_body.s1234 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm127_2665 : PRE_first_tail_x15_r0_body.s1233.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa127.obj (objOf PRE_first_tail_x15_r0_body.s1234 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1233 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg127_2673467 : PRE_first_tail_x15_r0_body.s1234.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1234 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk127_2673467 : (objOf PRE_first_tail_x15_r0_body.s1234 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm127_2673467 : PRE_first_tail_x15_r0_body.s1233.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa127.obj (objOf PRE_first_tail_x15_r0_body.s1234 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1233 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw127_4910 : (PRE_first_tail_x15_r0_body.s1234.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw127_2673472 : (PRE_first_tail_x15_r0_body.s1234.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw127_2673473 : (PRE_first_tail_x15_r0_body.s1234.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd127 : PRE_first_tail_x15_r0_body.cl127.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr127 : PRE_first_tail_x15_r0_body.st127.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1232.next || PRE_first_tail_x15_r0_body.cl127.contains b) = true
def PRE_first_tail_x15_r0_body.zl127 : List Nat := PRE_first_tail_x15_r0_body.cl127.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE127 : PRE_first_tail_x15_r0_body.zl127.map (fun a => PRE_first_tail_x15_r0_body.s1233.heap.get (PRE_first_tail_x15_r0_body.kappa127.a a)) = PRE_first_tail_x15_r0_body.zl127.map (fun a => (PRE_first_tail_x15_r0_body.s1234.heap.get a).map PRE_first_tail_x15_r0_body.kappa127.hobj)
theorem PRE_first_tail_x15_r0_body.zimg127 : HeapImg PRE_first_tail_x15_r0_body.kappa127 PRE_first_tail_x15_r0_body.s1234 PRE_first_tail_x15_r0_body.s1233 PRE_first_tail_x15_r0_body.zl127 := PRE_first_tail_x15_r0_body.zimgE127
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl127 : PRE_first_tail_x15_r0_body.s1233.ctl = PRE_first_tail_x15_r0_body.kappa127.ctl PRE_first_tail_x15_r0_body.s1234.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack127 : PRE_first_tail_x15_r0_body.s1233.stack = PRE_first_tail_x15_r0_body.s1234.stack.map PRE_first_tail_x15_r0_body.kappa127.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs127 : PRE_first_tail_x15_r0_body.s1233.jobs = PRE_first_tail_x15_r0_body.s1234.jobs.map PRE_first_tail_x15_r0_body.kappa127.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores127 : PRE_first_tail_x15_r0_body.s1233.stores = PRE_first_tail_x15_r0_body.kappa127.stores PRE_first_tail_x15_r0_body.s1234.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots127 : checkRootsSupp PRE_first_tail_x15_r0_body.s1234 5510 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC127 : PRE_first_tail_x15_r0_body.S1232.tab.length + PRE_first_tail_x15_r0_body.cws127.length = 5510
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap127 : PRE_first_tail_x15_r0_body.kappa127 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1232.next 2774633 PRE_first_tail_x15_r0_body.S1232.tab.length PRE_first_tail_x15_r0_body.pl127 (PRE_first_tail_x15_r0_body.nr127.map NumV.ref) PRE_first_tail_x15_r0_body.kd127.big
  PRE_first_tail_x15_r0_body.kd127.region PRE_first_tail_x15_r0_body.kd127.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin127 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1234.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc127 : Conv.jcleanListB (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1234 PRE_first_tail_x15_r0_body.cl127 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB127 : noBigRootsP (fun i => !Conv.oldBigB (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1234.trace PRE_first_tail_x15_r0_body.s1234 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm127 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17814 = true
theorem PRE_first_tail_x15_r0_body.cjcl127 (h : Conv.JClean (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1232) : Conv.JClean (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1234 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle127)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap127 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd127 a ha)) PRE_first_tail_x15_r0_body.zjc127

end Host.Load.Run.Tpl
end

section -- st127/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st127.bodyLast from PRE_first_tail_x15_r0_body.st127.s1 to PRE_first_tail_x15_r0_body.st127.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st127.F PRE_first_tail_x15_r0_body.st127.s1).run PRE_first_tail_x15_r0_body.st127.S1 = some (PRE_first_tail_x15_r0_body.st127.s2, PRE_first_tail_x15_r0_body.st127.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st127.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st127.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st127.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st127.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st127/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st127.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st127.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st127.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st127.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st127.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st127.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st127.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st127.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st127.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st127.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st127.s0 PRE_first_tail_x15_r0_body.st127.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st127.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st127.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st127.s1 PRE_first_tail_x15_r0_body.st127.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st127/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st127.bodyK0F from PRE_first_tail_x15_r0_body.st127.s0 to PRE_first_tail_x15_r0_body.st127.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st127.F (PRE_first_tail_x15_r0_body.st127.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st127.ks 0).getD 0) PRE_first_tail_x15_r0_body.st127.s0 PRE_first_tail_x15_r0_body.st127.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st127.s1, PRE_first_tail_x15_r0_body.st127.S1)
theorem PRE_first_tail_x15_r0_body.st127.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st127.F (PRE_first_tail_x15_r0_body.st127.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st127.ks 0).getD 0) PRE_first_tail_x15_r0_body.st127.s0 PRE_first_tail_x15_r0_body.st127.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st127.s1, PRE_first_tail_x15_r0_body.st127.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st127.bodyOkLN_ok PRE_first_tail_x15_r0_body.st127.bodyK0F
end Host.Load.Run.Tpl
end

section -- st127/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st127.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st127.F (PRE_first_tail_x15_r0_body.st127.bodyOkL bytes rows) 27 PRE_first_tail_x15_r0_body.st127.s0 PRE_first_tail_x15_r0_body.st127.S0 = some (PRE_first_tail_x15_r0_body.st127.s1, PRE_first_tail_x15_r0_body.st127.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st127.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st127.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st127.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st127.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st127.F (PRE_first_tail_x15_r0_body.st127.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st127.s0
  S0 := PRE_first_tail_x15_r0_body.st127.S0
  s1 := PRE_first_tail_x15_r0_body.st127.s1
  S1 := PRE_first_tail_x15_r0_body.st127.S1
  s2 := PRE_first_tail_x15_r0_body.st127.s2
  S2 := PRE_first_tail_x15_r0_body.st127.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st127.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st127.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st127.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st127.bodyHalt
  last := PRE_first_tail_x15_r0_body.st127.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st127.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC128
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 128 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1238` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa128` into the merged state
`PRE_first_tail_x15_r0_body.s1237`. -/

def PRE_first_tail_x15_r0_body.pl128 : List Nat := [2774929]
def PRE_first_tail_x15_r0_body.nr128 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd128 : RData :=
  ⟨2774920, 2774930, Stage.setAll PTrie.nil [(2774919, 2774929)], Stage.setAll PTrie.nil [],
   20713, 20713, 17818, 17818, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa128 : Map :=
  Conv.Map.compact 2774919 2774930 5527 PRE_first_tail_x15_r0_body.pl128 (PRE_first_tail_x15_r0_body.nr128.map NumV.ref) PRE_first_tail_x15_r0_body.kd128.big
    PRE_first_tail_x15_r0_body.kd128.region PRE_first_tail_x15_r0_body.kd128.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws128 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs128 : List SymE := PRE_first_tail_x15_r0_body.nr128.map fun r => (nth? PRE_first_tail_x15_r0_body.S1237.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta128 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws128 PRE_first_tail_x15_r0_body.crs128
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB128 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab128 : PRE_first_tail_x15_r0_body.S1238.tab = PRE_first_tail_x15_r0_body.S1236.tab ++ PRE_first_tail_x15_r0_body.cws128.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace128 : PRE_first_tail_x15_r0_body.s1238.trace = PRE_first_tail_x15_r0_body.s1236.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext128 : PRE_first_tail_x15_r0_body.s1238.next = 2774920
kernel_rfl PRE_first_tail_x15_r0_body.ccounters128 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1238.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1238.ffi).mlx.nnext) = (20713, 17818)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue128 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1237.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1238.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa128.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp128 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1238.ffi).mlx.tokens.all (bSN 5527) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean128 : Conv.cleanListB 20713 131072 (fun r => Nat.ble 82852 r) PRE_first_tail_x15_r0_body.s1238
    (PRE_first_tail_x15_r0_body.wrB128 ++ (List.range 1).map (2774919 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs128 : bigsOutB 20713 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1238.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK128
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl128`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl128 : List Nat := [2665, 2673467, 2774919]
def PRE_first_tail_x15_r0_body.clo128 : List Nat := []
def PRE_first_tail_x15_r0_body.cln128 : List Nat := []
def PRE_first_tail_x15_r0_body.cli128 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap128 : PRE_first_tail_x15_r0_body.s1238.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1236.heap (PRE_first_tail_x15_r0_body.cl128.filterMap fun a => (PRE_first_tail_x15_r0_body.s1238.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe128 : Nat.ble PRE_first_tail_x15_r0_body.s1236.next PRE_first_tail_x15_r0_body.s1238.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP128 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1236 PRE_first_tail_x15_r0_body.s1238 PRE_first_tail_x15_r0_body.cl128 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp128 : Conv.suppListB PRE_first_tail_x15_r0_body.s1238 5527 PRE_first_tail_x15_r0_body.cl128 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound128 : Conv.boundListB PRE_first_tail_x15_r0_body.s1238 PRE_first_tail_x15_r0_body.cl128 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK128 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1238.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln128.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1238.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK128 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1238.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo128.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1238.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK128 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1238.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli128.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1238.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst128 : Conv.sstListB 5527 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1238.ffi).mlx PRE_first_tail_x15_r0_body.cln128 PRE_first_tail_x15_r0_body.clo128 PRE_first_tail_x15_r0_body.cli128 = true

end Host.Load.Run.Tpl
end

section -- SiteCl128
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA128 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1238.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo128.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1238.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd128 : (PRE_first_tail_x15_r0_body.clo128 ++ PRE_first_tail_x15_r0_body.cln128 ++ PRE_first_tail_x15_r0_body.cli128).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle128 : Conv.Cnt.leB (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt) (⟨20713, 17818, 2774920, 5527⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck128 : Conv.ncleanListB (⟨20713, 17818, 2774920, 5527⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1238.ffi).mlx PRE_first_tail_x15_r0_body.clo128 PRE_first_tail_x15_r0_body.cln128 PRE_first_tail_x15_r0_body.cli128 = true
theorem PRE_first_tail_x15_r0_body.cncl128 (h : Conv.NClean (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx) : Conv.NClean (⟨20713, 17818, 2774920, 5527⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1238.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle128 PRE_first_tail_x15_r0_body.ckA128 PRE_first_tail_x15_r0_body.cobjsK128 PRE_first_tail_x15_r0_body.cnodesK128 PRE_first_tail_x15_r0_body.citemsK128 PRE_first_tail_x15_r0_body.cbd128 PRE_first_tail_x15_r0_body.cck128

end Host.Load.Run.Tpl
end

section -- SiteS128
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 128 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc128 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P128 : LoadP := PRE_first_tail_x15_r0_body.Pc128.raise 17818
kernel_rfl PRE_first_tail_x15_r0_body.craise128 : Nat.ble PRE_first_tail_x15_r0_body.Pc128.N0 17818 = true
theorem PRE_first_tail_x15_r0_body.raised128 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc128 PRE_first_tail_x15_r0_body.P128 :=
  .inr ⟨17818, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise128, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_128 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1238.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_128 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1237.ffi)
def PRE_first_tail_x15_r0_body.khinv128 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv128 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS128 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS128 : List Nat := List.range' 17818 0
def PRE_first_tail_x15_r0_body.ciS128 : List Nat := [] ++ List.range' 17818 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0128 : PRE_first_tail_x15_r0_body.kd128.nh0 = PRE_first_tail_x15_r0_body.cx0_128.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1128 : PRE_first_tail_x15_r0_body.kd128.nh1 = PRE_first_tail_x15_r0_body.cx1_128.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0128 : PRE_first_tail_x15_r0_body.kd128.nn0 = PRE_first_tail_x15_r0_body.cx0_128.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1128 : PRE_first_tail_x15_r0_body.kd128.nn1 = PRE_first_tail_x15_r0_body.cx1_128.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo128 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P128.lo && Nat.ble PRE_first_tail_x15_r0_body.P128.lo PRE_first_tail_x15_r0_body.cx0_128.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P128.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P128.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt128 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_128.mlx.next PRE_first_tail_x15_r0_body.cx1_128.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_128.mlx.nnext PRE_first_tail_x15_r0_body.cx1_128.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband128 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P128.NL && Nat.ble PRE_first_tail_x15_r0_body.P128.NL PRE_first_tail_x15_r0_body.P128.N0 && Nat.ble PRE_first_tail_x15_r0_body.P128.N0 PRE_first_tail_x15_r0_body.cx0_128.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow128 : PRE_first_tail_x15_r0_body.kd128.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren128 : checkRenG PRE_first_tail_x15_r0_body.kd128.hnd PRE_first_tail_x15_r0_body.khinv128 (phB PRE_first_tail_x15_r0_body.cx0_128.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband128 : PRE_first_tail_x15_r0_body.kd128.checkBand PRE_first_tail_x15_r0_body.P128.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos128 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd128.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren128 : checkRenG PRE_first_tail_x15_r0_body.kd128.node PRE_first_tail_x15_r0_body.kninv128 (pnB PRE_first_tail_x15_r0_body.cx0_128.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow128 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd128.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P128.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd128.nodeF j) PRE_first_tail_x15_r0_body.cx1_128.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a128 : PRE_first_tail_x15_r0_body.cx0_128.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b128 : PRE_first_tail_x15_r0_body.cx0_128.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1128 : PRE_first_tail_x15_r0_body.cx1_128.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend128 : PRE_first_tail_x15_r0_body.cx1_128.mlx.pending = PRE_first_tail_x15_r0_body.cx0_128.mlx.pending.map PRE_first_tail_x15_r0_body.kappa128.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh128 : PRE_first_tail_x15_r0_body.cx1_128.mlx.errh = PRE_first_tail_x15_r0_body.cx0_128.mlx.errh.map PRE_first_tail_x15_r0_body.kappa128.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles128 : PRE_first_tail_x15_r0_body.cx1_128.mlx.files = PRE_first_tail_x15_r0_body.cx0_128.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch128 : PRE_first_tail_x15_r0_body.cx1_128.mlx.arch = PRE_first_tail_x15_r0_body.cx0_128.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes128 : PRE_first_tail_x15_r0_body.cx1_128.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_128.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired128 : PRE_first_tail_x15_r0_body.cx1_128.mlx.wired = PRE_first_tail_x15_r0_body.cx0_128.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost128 : PRE_first_tail_x15_r0_body.cx1_128.host = PRE_first_tail_x15_r0_body.cx0_128.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd128`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0128 : PRE_first_tail_x15_r0_body.kd128.n0 = 2774920
kernel_rfl PRE_first_tail_x15_r0_body.ckn1128 : PRE_first_tail_x15_r0_body.kd128.n1 = 2774930
kernel_rfl PRE_first_tail_x15_r0_body.ckheap128 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd128.heap).all (fun x => Nat.ble 2774919 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl128 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd128.heap.get (2774919 + j) = nth? PRE_first_tail_x15_r0_body.pl128 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja128 : Nat.ble 2774919 2774919 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn128 : Nat.ble 5527 5527 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD128 : Nat.ble 2774919 PRE_first_tail_x15_r0_body.kd128.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn128 : Nat.ble 20713 PRE_first_tail_x15_r0_body.kd128.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn128 : Nat.ble 17818 PRE_first_tail_x15_r0_body.kd128.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb128 : Nat.ble 20713 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap128 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd128.heap).all (Nat.ble (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd128 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd128.hnd).all (Nat.ble (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode128 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd128.node).all (Nat.ble (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix128 : Conv.FixOld (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa128 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja128) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn128) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD128) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn128) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn128) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb128) PRE_first_tail_x15_r0_body.fheap128 PRE_first_tail_x15_r0_body.fhnd128 PRE_first_tail_x15_r0_body.fnode128
kernel_rfl PRE_first_tail_x15_r0_body.fcxn128 : (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn128 : (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0128 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_128.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_128.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk128 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd128.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A128 : PRE_first_tail_x15_r0_body.cx1_128.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS128.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_128.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O128 : PRE_first_tail_x15_r0_body.cx1_128.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS128.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_128.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N128 : PRE_first_tail_x15_r0_body.cx1_128.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS128.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_128.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I128 : PRE_first_tail_x15_r0_body.cx1_128.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS128.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_128.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd128 : (PRE_first_tail_x15_r0_body.clo128 ++ PRE_first_tail_x15_r0_body.cln128 ++ PRE_first_tail_x15_r0_body.cli128 ++ PRE_first_tail_x15_r0_body.cwS128 ++ PRE_first_tail_x15_r0_body.cnS128 ++ PRE_first_tail_x15_r0_body.ciS128).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW128 : PRE_first_tail_x15_r0_body.cwS128.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo128.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI128 : PRE_first_tail_x15_r0_body.ciS128.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli128.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN128 : PRE_first_tail_x15_r0_body.cnS128.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF128 : PRE_first_tail_x15_r0_body.cln128.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh128 : PRE_first_tail_x15_r0_body.clo128.all (handleOK PRE_first_tail_x15_r0_body.kappa128 PRE_first_tail_x15_r0_body.P128.lo PRE_first_tail_x15_r0_body.cx0_128.mlx PRE_first_tail_x15_r0_body.cx1_128.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo128 : PRE_first_tail_x15_r0_body.clo128.map (fun h => PRE_first_tail_x15_r0_body.cx1_128.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa128.handle h)) = PRE_first_tail_x15_r0_body.clo128.map (fun h => (PRE_first_tail_x15_r0_body.cx0_128.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa128.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok128 : PRE_first_tail_x15_r0_body.clo128.all (objOK PRE_first_tail_x15_r0_body.kappa128 PRE_first_tail_x15_r0_body.P128.NL PRE_first_tail_x15_r0_body.cx0_128.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd128 : PRE_first_tail_x15_r0_body.cln128.all (nodeOKF PRE_first_tail_x15_r0_body.kappa128 PRE_first_tail_x15_r0_body.P128 PRE_first_tail_x15_r0_body.cx0_128.mlx PRE_first_tail_x15_r0_body.cx1_128.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp128 : ((PRE_first_tail_x15_r0_body.cln128.filter (fullB PRE_first_tail_x15_r0_body.P128))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_128.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa128.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln128.filter (fullB PRE_first_tail_x15_r0_body.P128))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_128.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa128.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI128 : incrB PRE_first_tail_x15_r0_body.kd128.nodeF (List.range' 17818 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK128 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd128.node).all (fun k => Nat.ble 17818 k && Nat.blt k 17818) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL128 : (PRE_first_tail_x15_r0_body.cln128.filter (Nat.ble PRE_first_tail_x15_r0_body.P128.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd128.nodeF i) && (Nat.blt i 17818 || Nat.ble PRE_first_tail_x15_r0_body.kd128.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord128 : (PRE_first_tail_x15_r0_body.cln128.filter (Nat.ble PRE_first_tail_x15_r0_body.P128.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd128.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd128.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd128.nodeF j) (PRE_first_tail_x15_r0_body.kd128.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow128 PRE_first_tail_x15_r0_body.cnn1128 PRE_first_tail_x15_r0_body.fnordI128 PRE_first_tail_x15_r0_body.fnordK128 PRE_first_tail_x15_r0_body.fnordL128
kernel_rfl PRE_first_tail_x15_r0_body.fi128 : PRE_first_tail_x15_r0_body.cli128.all (pnB PRE_first_tail_x15_r0_body.cx0_128.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii128 : PRE_first_tail_x15_r0_body.cli128.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_128.mlx.items.get (PRE_first_tail_x15_r0_body.kappa128.node k) = (PRE_first_tail_x15_r0_body.cx0_128.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa128.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot128 (clean : Conv.NClean (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P128.NL) (cl : SSt (· < 5527) PRE_first_tail_x15_r0_body.cx0_128.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P128 5527 PRE_first_tail_x15_r0_body.kappa128 PRE_first_tail_x15_r0_body.kd128 PRE_first_tail_x15_r0_body.khinv128 PRE_first_tail_x15_r0_body.kninv128 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx PRE_first_tail_x15_r0_body.cx0_128.mlx PRE_first_tail_x15_r0_body.cx1_128.mlx (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo128 PRE_first_tail_x15_r0_body.cln128 PRE_first_tail_x15_r0_body.cli128 PRE_first_tail_x15_r0_body.cwS128 PRE_first_tail_x15_r0_body.cnS128 PRE_first_tail_x15_r0_body.ciS128 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0128, PRE_first_tail_x15_r0_body.cnh1128, PRE_first_tail_x15_r0_body.cnn0128, PRE_first_tail_x15_r0_body.cnn1128, PRE_first_tail_x15_r0_body.cplo128, PRE_first_tail_x15_r0_body.ccnt128, PRE_first_tail_x15_r0_body.cnband128, PRE_first_tail_x15_r0_body.chbelow128, PRE_first_tail_x15_r0_body.chren128, PRE_first_tail_x15_r0_body.cband128, PRE_first_tail_x15_r0_body.cnh1pos128, PRE_first_tail_x15_r0_body.cnren128, PRE_first_tail_x15_r0_body.cnlow128, PRE_first_tail_x15_r0_body.cabs0a128, PRE_first_tail_x15_r0_body.cabs0b128, PRE_first_tail_x15_r0_body.ctok1128, PRE_first_tail_x15_r0_body.cpend128, PRE_first_tail_x15_r0_body.cerrh128, PRE_first_tail_x15_r0_body.cfiles128, PRE_first_tail_x15_r0_body.carch128, PRE_first_tail_x15_r0_body.csizes128, PRE_first_tail_x15_r0_body.cwired128, PRE_first_tail_x15_r0_body.cfix128, clean, PRE_first_tail_x15_r0_body.fcxn128, PRE_first_tail_x15_r0_body.fcnn128, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0128, PRE_first_tail_x15_r0_body.fnk128, PRE_first_tail_x15_r0_body.ckA128, PRE_first_tail_x15_r0_body.cobjsK128, PRE_first_tail_x15_r0_body.cnodesK128, PRE_first_tail_x15_r0_body.citemsK128, PRE_first_tail_x15_r0_body.f1A128, PRE_first_tail_x15_r0_body.f1O128, PRE_first_tail_x15_r0_body.f1N128, PRE_first_tail_x15_r0_body.f1I128, PRE_first_tail_x15_r0_body.fbd128, PRE_first_tail_x15_r0_body.fincW128, PRE_first_tail_x15_r0_body.fincI128, PRE_first_tail_x15_r0_body.fincN128, PRE_first_tail_x15_r0_body.flnF128, PRE_first_tail_x15_r0_body.fh128, PRE_first_tail_x15_r0_body.fo128, PRE_first_tail_x15_r0_body.fok128, PRE_first_tail_x15_r0_body.fnd128, PRE_first_tail_x15_r0_body.fp128, PRE_first_tail_x15_r0_body.fnord128, PRE_first_tail_x15_r0_body.fi128, PRE_first_tail_x15_r0_body.fii128⟩
theorem PRE_first_tail_x15_r0_body.cnshift128 (clean : Conv.NClean (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P128.NL) (cl : SSt (· < 5527) PRE_first_tail_x15_r0_body.cx0_128.mlx) : NShift PRE_first_tail_x15_r0_body.P128 5527 PRE_first_tail_x15_r0_body.kappa128 PRE_first_tail_x15_r0_body.cx0_128 PRE_first_tail_x15_r0_body.cx1_128 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot128 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost128 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0128 PRE_first_tail_x15_r0_body.ckn1128 PRE_first_tail_x15_r0_body.ckheap128 PRE_first_tail_x15_r0_body.ckpl128)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_128 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1236.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_128 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1236.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_128 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1236.ffi) = some PRE_first_tail_x15_r0_body.fxC_128
kernel_rfl PRE_first_tail_x15_r0_body.okrC_128 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1236.ffi) = some PRE_first_tail_x15_r0_body.krC_128
noncomputable def PRE_first_tail_x15_r0_body.fx0_128 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1238.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_128 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1238.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_128 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1238.ffi) = some PRE_first_tail_x15_r0_body.fx0_128
kernel_rfl PRE_first_tail_x15_r0_body.okr0_128 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1238.ffi) = some PRE_first_tail_x15_r0_body.kr0_128
noncomputable def PRE_first_tail_x15_r0_body.fx1_128 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1237.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_128 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1237.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_128 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1237.ffi) = some PRE_first_tail_x15_r0_body.fx1_128
kernel_rfl PRE_first_tail_x15_r0_body.okr1_128 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1237.ffi) = some PRE_first_tail_x15_r0_body.kr1_128
kernel_rfl PRE_first_tail_x15_r0_body.ff0128 : PRE_first_tail_x15_r0_body.fx0_128 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_128 (PRE_first_tail_x15_r0_body.clo128.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_128.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1128 : PRE_first_tail_x15_r0_body.fx1_128 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_128 (PRE_first_tail_x15_r0_body.cwS128.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_128.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck128 : freedLB PRE_first_tail_x15_r0_body.kappa128 PRE_first_tail_x15_r0_body.cx0_128.mlx PRE_first_tail_x15_r0_body.fx0_128 PRE_first_tail_x15_r0_body.fx1_128 PRE_first_tail_x15_r0_body.clo128 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0128 : PRE_first_tail_x15_r0_body.kr0_128.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_128.flags (PRE_first_tail_x15_r0_body.clo128.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_128.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0128 : PRE_first_tail_x15_r0_body.kr0_128.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_128.targs (PRE_first_tail_x15_r0_body.clo128.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_128.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1128 : PRE_first_tail_x15_r0_body.kr1_128.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_128.flags (PRE_first_tail_x15_r0_body.cwS128.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_128.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1128 : PRE_first_tail_x15_r0_body.kr1_128.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_128.targs (PRE_first_tail_x15_r0_body.cwS128.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_128.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck128 : krecLB PRE_first_tail_x15_r0_body.kappa128 5527 PRE_first_tail_x15_r0_body.cx0_128.mlx PRE_first_tail_x15_r0_body.kr0_128 PRE_first_tail_x15_r0_body.kr1_128 PRE_first_tail_x15_r0_body.clo128 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn128 : Nat.ble 5527 5527 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge128 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1237.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1238.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR128 : pendRegB PRE_first_tail_x15_r0_body.kappa128 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1238.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe128 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1238.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1237.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift128 (clean : Conv.NClean (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P128.NL) (cl : SSt (· < 5527) PRE_first_tail_x15_r0_body.cx0_128.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_128.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_128.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_128.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_128.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P128 5527 PRE_first_tail_x15_r0_body.kappa128 PRE_first_tail_x15_r0_body.s1238.ffi PRE_first_tail_x15_r0_body.s1237.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift128 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue128, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp128 t ht),
    PRE_first_tail_x15_r0_body.cbridge128,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1238.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1237.ffi) (PRE_first_tail_x15_r0_body.cfoot128 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_128 PRE_first_tail_x15_r0_body.ofx1_128 hobjC PRE_first_tail_x15_r0_body.ff0128 PRE_first_tail_x15_r0_body.ff1128 PRE_first_tail_x15_r0_body.ffck128,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1238.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1237.ffi) (PRE_first_tail_x15_r0_body.cfoot128 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_128 PRE_first_tail_x15_r0_body.okr1_128 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn128) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0128 PRE_first_tail_x15_r0_body.fkt0128 PRE_first_tail_x15_r0_body.fkf1128 PRE_first_tail_x15_r0_body.fkt1128 PRE_first_tail_x15_r0_body.fkck128,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0128 PRE_first_tail_x15_r0_body.cnh1128 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe128) PRE_first_tail_x15_r0_body.cpendR128⟩

end Host.Load.Run.Tpl
end

section -- st128/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st128 0
host_stream_state PRE_first_tail_x15_r0_body.st128 1
host_stream_state PRE_first_tail_x15_r0_body.st128 2
end Host.Load.Run.Tpl
end

section -- Site128
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 128 of chain `PRE_first_tail_x15_r0_body`: `plan__g128__g129` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1236`, the merged state `PRE_first_tail_x15_r0_body.s1237`,
the site template `PRE_first_tail_x15_r0_body.st128` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1238`: the merge.
The footprint's facts are in `SiteF128`, the compaction's in `SiteC128`, `SiteK128`, `SiteNa128`, `SiteNb128`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso128 : PRE_first_tail_x15_r0_body.st128.s0 = { PRE_first_tail_x15_r0_body.s1236 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs128 : List Frame := PRE_first_tail_x15_r0_body.s1236.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_128 : PRE_first_tail_x15_r0_body.S1236.tab.length = 5527
kernel_rfl PRE_first_tail_x15_r0_body.tab0_128 : PRE_first_tail_x15_r0_body.st128.S0.tab = PRE_first_tail_x15_r0_body.S1236.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws128 : List Nat := [3155, 3156, 3157]
kernel_rfl PRE_first_tail_x15_r0_body.fresh128 : (PRE_first_tail_x15_r0_body.S1236.tab.all fun e => PRE_first_tail_x15_r0_body.ws128.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1236.oracle.all fun q => PRE_first_tail_x15_r0_body.ws128.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab128 : PRE_first_tail_x15_r0_body.S1237.tab = PRE_first_tail_x15_r0_body.S1236.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws128
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen128 : PRE_first_tail_x15_r0_body.st128.S2.tab.length - PRE_first_tail_x15_r0_body.st128.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged128`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap128 : PRE_first_tail_x15_r0_body.s1237.heap = PRE_first_tail_x15_r0_body.st128.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext128 : PRE_first_tail_x15_r0_body.s1237.next = PRE_first_tail_x15_r0_body.st128.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl128 : PRE_first_tail_x15_r0_body.s1237.ctl = PRE_first_tail_x15_r0_body.st128.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack128 : PRE_first_tail_x15_r0_body.s1237.stack = PRE_first_tail_x15_r0_body.st128.s2.stack ++ PRE_first_tail_x15_r0_body.s1236.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs128 : PRE_first_tail_x15_r0_body.s1237.jobs = PRE_first_tail_x15_r0_body.st128.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi128 : PRE_first_tail_x15_r0_body.s1237.ffi = PRE_first_tail_x15_r0_body.st128.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace128 : PRE_first_tail_x15_r0_body.s1237.trace = PRE_first_tail_x15_r0_body.st128.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores128 : PRE_first_tail_x15_r0_body.s1237.stores = PRE_first_tail_x15_r0_body.st128.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD128
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 128 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived128 : PRE_first_tail_x15_r0_body.nr128.map (fun r => nth? PRE_first_tail_x15_r0_body.st128.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo128 : PRE_first_tail_x15_r0_body.nr128.all (Nat.ble 5527) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj128 : PRE_first_tail_x15_r0_body.cws128.all (fun c => !PRE_first_tail_x15_r0_body.ws128.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ128 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws128 PRE_first_tail_x15_r0_body.crs128 PRE_first_tail_x15_r0_body.ws128

end Host.Load.Run.Tpl
end

section -- st128/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st128`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st128.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st128.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st128.s2.heap PRE_first_tail_x15_r0_body.st128.wrR ++ freshOf PRE_first_tail_x15_r0_body.st128.s2.heap PRE_first_tail_x15_r0_body.st128.s0.next PRE_first_tail_x15_r0_body.st128.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st128.wr : List Nat := PRE_first_tail_x15_r0_body.st128.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st128.heapFoot : PRE_first_tail_x15_r0_body.st128.s2.heap = setAll PRE_first_tail_x15_r0_body.st128.s0.heap PRE_first_tail_x15_r0_body.st128.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st128.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st128.s0.next PRE_first_tail_x15_r0_body.st128.s2.next = true
theorem PRE_first_tail_x15_r0_body.st128.grows : PRE_first_tail_x15_r0_body.st128.s0.next ≤ PRE_first_tail_x15_r0_body.st128.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st128.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st128.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st128.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st128.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st128.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st128.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st128.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st128.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st128.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st128.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st128.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st128.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st128.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st128.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st128.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st128.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st128.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st128.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st128.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st128.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st128.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st128.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st128.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st128.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st128.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st128.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st128.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st128.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st128.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st128.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st128.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st128.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF128
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 128 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB128 : nodupT PRE_first_tail_x15_r0_body.st128.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup128 : PRE_first_tail_x15_r0_body.st128.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB128).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB128 : PRE_first_tail_x15_r0_body.st128.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound128 : ∀ b ∈ PRE_first_tail_x15_r0_body.st128.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB128 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr128 := PRE_first_tail_x15_r0_body.st128.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq128 : PRE_first_tail_x15_r0_body.st128.s2.trace = PRE_first_tail_x15_r0_body.trFr128 ++ PRE_first_tail_x15_r0_body.st128.s0.trace
theorem PRE_first_tail_x15_r0_body.trace128 : ∃ fr, PRE_first_tail_x15_r0_body.st128.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st128.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq128⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide128 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB128 : (PRE_first_tail_x15_r0_body.wide128.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st128.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix128 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide128, WFix Map.id (Present PRE_first_tail_x15_r0_body.st128.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB128 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL128
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 128 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1237`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO128 : PRE_first_tail_x15_r0_body.st128.S0.oracle = PRE_first_tail_x15_r0_body.st128.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B128 : PRE_first_tail_x15_r0_body.st128.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st128.s0.next || (PRE_first_tail_x15_r0_body.st128.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot128 : Conv.StageFoot PRE_first_tail_x15_r0_body.st128.wr PRE_first_tail_x15_r0_body.st128.s0 PRE_first_tail_x15_r0_body.st128.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st128.heapFoot PRE_first_tail_x15_r0_body.wrNodup128 PRE_first_tail_x15_r0_body.wrBound128 PRE_first_tail_x15_r0_body.wr0B128 PRE_first_tail_x15_r0_body.st128.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged128 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st128.F.S → PRE_first_tail_x15_r0_body.st128.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st128.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st128.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs128 PRE_first_tail_x15_r0_body.st128.wr PRE_first_tail_x15_r0_body.s1236 PRE_first_tail_x15_r0_body.st128.s2 PRE_first_tail_x15_r0_body.st128.s0
      PRE_first_tail_x15_r0_body.st128.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st128.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1237 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso128 PRE_first_tail_x15_r0_body.stFoot128 PRE_first_tail_x15_r0_body.wrNodup128 PRE_first_tail_x15_r0_body.wrBound128 PRE_first_tail_x15_r0_body.trace128 PRE_first_tail_x15_r0_body.mheap128
    PRE_first_tail_x15_r0_body.mnext128 PRE_first_tail_x15_r0_body.mctl128 PRE_first_tail_x15_r0_body.mstack128 PRE_first_tail_x15_r0_body.mjobs128 PRE_first_tail_x15_r0_body.mffi128 PRE_first_tail_x15_r0_body.mtrace128 PRE_first_tail_x15_r0_body.mstores128 h

def PRE_first_tail_x15_r0_body.arrEl128_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE128_2665 : arrOf PRE_first_tail_x15_r0_body.s1237 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl128_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA128_2665 : isArrB PRE_first_tail_x15_r0_body.s1237 2665 = true
theorem PRE_first_tail_x15_r0_body.arr128_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1237.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl128_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE128_2665 PRE_first_tail_x15_r0_body.arrA128_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN128_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl128_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR128_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl128_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN128_2665

def PRE_first_tail_x15_r0_body.arrEl128_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE128_2673467 : arrOf PRE_first_tail_x15_r0_body.s1237 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl128_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA128_2673467 : isArrB PRE_first_tail_x15_r0_body.s1237 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr128_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1237.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl128_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE128_2673467 PRE_first_tail_x15_r0_body.arrA128_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN128_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl128_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR128_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl128_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN128_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k128 : isArrB PRE_first_tail_x15_r0_body.s1237 4910 = false
theorem PRE_first_tail_x15_r0_body.keep128 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1237 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k128 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr128_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl128_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ128
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 128 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1236`, the merged
state `PRE_first_tail_x15_r0_body.s1237`, the canonical state `PRE_first_tail_x15_r0_body.s1238`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl128 : PRE_first_tail_x15_r0_body.pl128.all (Nat.ble PRE_first_tail_x15_r0_body.s1236.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd128 : nodupT PRE_first_tail_x15_r0_body.pl128 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1128 : Nat.ble PRE_first_tail_x15_r0_body.s1236.next 2774930 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst128 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1236.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn128 : PRE_first_tail_x15_r0_body.s1238.next = PRE_first_tail_x15_r0_body.s1236.next + PRE_first_tail_x15_r0_body.pl128.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn128 : PRE_first_tail_x15_r0_body.s1237.next = 2774930
kernel_rfl PRE_first_tail_x15_r0_body.zgrow128 : Nat.ble PRE_first_tail_x15_r0_body.s1238.next PRE_first_tail_x15_r0_body.s1237.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh128 : PRE_first_tail_x15_r0_body.S1236.tab.all (fun e => PRE_first_tail_x15_r0_body.cws128.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd128 : nodupT PRE_first_tail_x15_r0_body.cws128 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi128 : PRE_first_tail_x15_r0_body.nr128.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1237.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt128 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1236.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg128_2665 : PRE_first_tail_x15_r0_body.s1238.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1238 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk128_2665 : (objOf PRE_first_tail_x15_r0_body.s1238 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm128_2665 : PRE_first_tail_x15_r0_body.s1237.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa128.obj (objOf PRE_first_tail_x15_r0_body.s1238 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1237 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg128_2673467 : PRE_first_tail_x15_r0_body.s1238.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1238 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk128_2673467 : (objOf PRE_first_tail_x15_r0_body.s1238 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm128_2673467 : PRE_first_tail_x15_r0_body.s1237.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa128.obj (objOf PRE_first_tail_x15_r0_body.s1238 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1237 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw128_4910 : (PRE_first_tail_x15_r0_body.s1238.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw128_2673472 : (PRE_first_tail_x15_r0_body.s1238.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw128_2673473 : (PRE_first_tail_x15_r0_body.s1238.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd128 : PRE_first_tail_x15_r0_body.cl128.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr128 : PRE_first_tail_x15_r0_body.st128.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1236.next || PRE_first_tail_x15_r0_body.cl128.contains b) = true
def PRE_first_tail_x15_r0_body.zl128 : List Nat := PRE_first_tail_x15_r0_body.cl128.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE128 : PRE_first_tail_x15_r0_body.zl128.map (fun a => PRE_first_tail_x15_r0_body.s1237.heap.get (PRE_first_tail_x15_r0_body.kappa128.a a)) = PRE_first_tail_x15_r0_body.zl128.map (fun a => (PRE_first_tail_x15_r0_body.s1238.heap.get a).map PRE_first_tail_x15_r0_body.kappa128.hobj)
theorem PRE_first_tail_x15_r0_body.zimg128 : HeapImg PRE_first_tail_x15_r0_body.kappa128 PRE_first_tail_x15_r0_body.s1238 PRE_first_tail_x15_r0_body.s1237 PRE_first_tail_x15_r0_body.zl128 := PRE_first_tail_x15_r0_body.zimgE128
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl128 : PRE_first_tail_x15_r0_body.s1237.ctl = PRE_first_tail_x15_r0_body.kappa128.ctl PRE_first_tail_x15_r0_body.s1238.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack128 : PRE_first_tail_x15_r0_body.s1237.stack = PRE_first_tail_x15_r0_body.s1238.stack.map PRE_first_tail_x15_r0_body.kappa128.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs128 : PRE_first_tail_x15_r0_body.s1237.jobs = PRE_first_tail_x15_r0_body.s1238.jobs.map PRE_first_tail_x15_r0_body.kappa128.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores128 : PRE_first_tail_x15_r0_body.s1237.stores = PRE_first_tail_x15_r0_body.kappa128.stores PRE_first_tail_x15_r0_body.s1238.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots128 : checkRootsSupp PRE_first_tail_x15_r0_body.s1238 5527 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC128 : PRE_first_tail_x15_r0_body.S1236.tab.length + PRE_first_tail_x15_r0_body.cws128.length = 5527
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap128 : PRE_first_tail_x15_r0_body.kappa128 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1236.next 2774930 PRE_first_tail_x15_r0_body.S1236.tab.length PRE_first_tail_x15_r0_body.pl128 (PRE_first_tail_x15_r0_body.nr128.map NumV.ref) PRE_first_tail_x15_r0_body.kd128.big
  PRE_first_tail_x15_r0_body.kd128.region PRE_first_tail_x15_r0_body.kd128.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin128 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1238.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc128 : Conv.jcleanListB (⟨20713, 17818, 2774920, 5527⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1238 PRE_first_tail_x15_r0_body.cl128 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB128 : noBigRootsP (fun i => !Conv.oldBigB (⟨20713, 17818, 2774920, 5527⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1238.trace PRE_first_tail_x15_r0_body.s1238 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm128 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17818 = true
theorem PRE_first_tail_x15_r0_body.cjcl128 (h : Conv.JClean (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1236) : Conv.JClean (⟨20713, 17818, 2774920, 5527⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1238 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle128)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap128 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd128 a ha)) PRE_first_tail_x15_r0_body.zjc128

end Host.Load.Run.Tpl
end

section -- st128/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st128.bodyLast from PRE_first_tail_x15_r0_body.st128.s1 to PRE_first_tail_x15_r0_body.st128.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st128.F PRE_first_tail_x15_r0_body.st128.s1).run PRE_first_tail_x15_r0_body.st128.S1 = some (PRE_first_tail_x15_r0_body.st128.s2, PRE_first_tail_x15_r0_body.st128.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st128.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st128.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st128.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st128.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st128/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st128.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st128.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st128.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st128.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st128.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st128.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st128.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st128.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st128.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st128.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st128.s0 PRE_first_tail_x15_r0_body.st128.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st128.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st128.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st128.s1 PRE_first_tail_x15_r0_body.st128.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st128/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st128.bodyK0F from PRE_first_tail_x15_r0_body.st128.s0 to PRE_first_tail_x15_r0_body.st128.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st128.F (PRE_first_tail_x15_r0_body.st128.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st128.ks 0).getD 0) PRE_first_tail_x15_r0_body.st128.s0 PRE_first_tail_x15_r0_body.st128.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st128.s1, PRE_first_tail_x15_r0_body.st128.S1)
theorem PRE_first_tail_x15_r0_body.st128.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st128.F (PRE_first_tail_x15_r0_body.st128.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st128.ks 0).getD 0) PRE_first_tail_x15_r0_body.st128.s0 PRE_first_tail_x15_r0_body.st128.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st128.s1, PRE_first_tail_x15_r0_body.st128.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st128.bodyOkLN_ok PRE_first_tail_x15_r0_body.st128.bodyK0F
end Host.Load.Run.Tpl
end

section -- st128/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st128.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st128.F (PRE_first_tail_x15_r0_body.st128.bodyOkL bytes rows) 98 PRE_first_tail_x15_r0_body.st128.s0 PRE_first_tail_x15_r0_body.st128.S0 = some (PRE_first_tail_x15_r0_body.st128.s1, PRE_first_tail_x15_r0_body.st128.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st128.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st128.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st128.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st128.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st128.F (PRE_first_tail_x15_r0_body.st128.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st128.s0
  S0 := PRE_first_tail_x15_r0_body.st128.S0
  s1 := PRE_first_tail_x15_r0_body.st128.s1
  S1 := PRE_first_tail_x15_r0_body.st128.S1
  s2 := PRE_first_tail_x15_r0_body.st128.s2
  S2 := PRE_first_tail_x15_r0_body.st128.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st128.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st128.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st128.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st128.bodyHalt
  last := PRE_first_tail_x15_r0_body.st128.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st128.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC129
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 129 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1254` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa129` into the merged state
`PRE_first_tail_x15_r0_body.s1253`. -/

def PRE_first_tail_x15_r0_body.pl129 : List Nat := [2777018, 2776854, 2776906, 2777019, 2777020, 2776856, 2776908, 2777017, 2777016, 2777015, 2777014, 2777008, 2776959, 2777010, 2776961]
def PRE_first_tail_x15_r0_body.nr129 : List Nat := [5612, 5613, 5609, 5615, 5611, 5619, 5620, 5617, 5618]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd129 : RData :=
  ⟨2776671, 2777021, Stage.setAll PTrie.nil [(2776656, 2777018), (2776657, 2776854), (2776658, 2776906), (2776659, 2777019), (2776660, 2777020), (2776661, 2776856), (2776662, 2776908), (2776663, 2777017), (2776664, 2777016), (2776665, 2777015), (2776666, 2777014), (2776667, 2777008), (2776668, 2776959), (2776669, 2777010), (2776670, 2776961)], Stage.setAll PTrie.nil [(20753, 20755), (20754, 20756), (20755, 20758), (20756, 20757)],
   20757, 20759, 17852, 17852, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(5604, .ref 5612), (5605, .ref 5613), (5606, .ref 5609), (5607, .ref 5615), (5608, .ref 5611), (5609, .ref 5619), (5610, .ref 5620), (5611, .ref 5617), (5612, .ref 5618)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa129 : Map :=
  Conv.Map.compact 2776656 2777021 5604 PRE_first_tail_x15_r0_body.pl129 (PRE_first_tail_x15_r0_body.nr129.map NumV.ref) PRE_first_tail_x15_r0_body.kd129.big
    PRE_first_tail_x15_r0_body.kd129.region PRE_first_tail_x15_r0_body.kd129.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws129 : List Nat := [3175, 3176, 3177, 3178, 3179, 3180, 3181, 3182, 3183]
noncomputable def PRE_first_tail_x15_r0_body.crs129 : List SymE := PRE_first_tail_x15_r0_body.nr129.map fun r => (nth? PRE_first_tail_x15_r0_body.S1253.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta129 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws129 PRE_first_tail_x15_r0_body.crs129
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB129 : List Nat := [2665, 2672632, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab129 : PRE_first_tail_x15_r0_body.S1254.tab = PRE_first_tail_x15_r0_body.S1252.tab ++ PRE_first_tail_x15_r0_body.cws129.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace129 : PRE_first_tail_x15_r0_body.s1254.trace = PRE_first_tail_x15_r0_body.s1252.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext129 : PRE_first_tail_x15_r0_body.s1254.next = 2776671
kernel_rfl PRE_first_tail_x15_r0_body.ccounters129 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.nnext) = (20757, 17852)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue129 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1253.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa129.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp129 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.tokens.all (bSN 5613) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean129 : Conv.cleanListB 20757 131072 (fun r => Nat.ble 83028 r) PRE_first_tail_x15_r0_body.s1254
    (PRE_first_tail_x15_r0_body.wrB129 ++ (List.range 15).map (2776656 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs129 : bigsOutB 20757 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK129
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl129`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl129 : List Nat := [2665, 2672632, 2673467, 2776656, 2776657, 2776658, 2776659, 2776660, 2776661, 2776662, 2776663, 2776664, 2776665, 2776666, 2776667, 2776668, 2776669, 2776670]
def PRE_first_tail_x15_r0_body.clo129 : List Nat := [20753, 20754, 20755, 20756]
def PRE_first_tail_x15_r0_body.cln129 : List Nat := [17846, 17847, 17848, 17849, 17850, 17851]
def PRE_first_tail_x15_r0_body.cli129 : List Nat := [17846, 17847, 17848, 17849, 17850, 17851]
kernel_rfl PRE_first_tail_x15_r0_body.cheap129 : PRE_first_tail_x15_r0_body.s1254.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1252.heap (PRE_first_tail_x15_r0_body.cl129.filterMap fun a => (PRE_first_tail_x15_r0_body.s1254.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe129 : Nat.ble PRE_first_tail_x15_r0_body.s1252.next PRE_first_tail_x15_r0_body.s1254.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP129 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1252 PRE_first_tail_x15_r0_body.s1254 PRE_first_tail_x15_r0_body.cl129 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp129 : Conv.suppListB PRE_first_tail_x15_r0_body.s1254 5613 PRE_first_tail_x15_r0_body.cl129 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound129 : Conv.boundListB PRE_first_tail_x15_r0_body.s1254 PRE_first_tail_x15_r0_body.cl129 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK129 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln129.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK129 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo129.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK129 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli129.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst129 : Conv.sstListB 5613 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx PRE_first_tail_x15_r0_body.cln129 PRE_first_tail_x15_r0_body.clo129 PRE_first_tail_x15_r0_body.cli129 = true

end Host.Load.Run.Tpl
end

section -- SiteCl129
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA129 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo129.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd129 : (PRE_first_tail_x15_r0_body.clo129 ++ PRE_first_tail_x15_r0_body.cln129 ++ PRE_first_tail_x15_r0_body.cli129).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle129 : Conv.Cnt.leB (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt) (⟨20757, 17852, 2776671, 5613⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck129 : Conv.ncleanListB (⟨20757, 17852, 2776671, 5613⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx PRE_first_tail_x15_r0_body.clo129 PRE_first_tail_x15_r0_body.cln129 PRE_first_tail_x15_r0_body.cli129 = true
theorem PRE_first_tail_x15_r0_body.cncl129 (h : Conv.NClean (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx) : Conv.NClean (⟨20757, 17852, 2776671, 5613⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle129 PRE_first_tail_x15_r0_body.ckA129 PRE_first_tail_x15_r0_body.cobjsK129 PRE_first_tail_x15_r0_body.cnodesK129 PRE_first_tail_x15_r0_body.citemsK129 PRE_first_tail_x15_r0_body.cbd129 PRE_first_tail_x15_r0_body.cck129

end Host.Load.Run.Tpl
end

section -- SiteS129
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 129 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc129 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P129 : LoadP := PRE_first_tail_x15_r0_body.Pc129.raise 17852
kernel_rfl PRE_first_tail_x15_r0_body.craise129 : Nat.ble PRE_first_tail_x15_r0_body.Pc129.N0 17852 = true
theorem PRE_first_tail_x15_r0_body.raised129 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc129 PRE_first_tail_x15_r0_body.P129 :=
  .inr ⟨17852, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise129, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_129 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_129 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1253.ffi)
def PRE_first_tail_x15_r0_body.khinv129 : PTrie Nat := Stage.setAll PTrie.nil [(20755, 20753), (20756, 20754), (20758, 20755), (20757, 20756)]
def PRE_first_tail_x15_r0_body.kninv129 : PTrie Nat := Stage.setAll PTrie.nil [(17846, 17846), (17847, 17847), (17848, 17848), (17849, 17849), (17850, 17850), (17851, 17851)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS129 : List Nat := [20753, 20754, 20755, 20756, 20757, 20758]
def PRE_first_tail_x15_r0_body.cnS129 : List Nat := List.range' 17846 6
def PRE_first_tail_x15_r0_body.ciS129 : List Nat := [] ++ List.range' 17846 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0129 : PRE_first_tail_x15_r0_body.kd129.nh0 = PRE_first_tail_x15_r0_body.cx0_129.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1129 : PRE_first_tail_x15_r0_body.kd129.nh1 = PRE_first_tail_x15_r0_body.cx1_129.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0129 : PRE_first_tail_x15_r0_body.kd129.nn0 = PRE_first_tail_x15_r0_body.cx0_129.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1129 : PRE_first_tail_x15_r0_body.kd129.nn1 = PRE_first_tail_x15_r0_body.cx1_129.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo129 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P129.lo && Nat.ble PRE_first_tail_x15_r0_body.P129.lo PRE_first_tail_x15_r0_body.cx0_129.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P129.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P129.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt129 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_129.mlx.next PRE_first_tail_x15_r0_body.cx1_129.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_129.mlx.nnext PRE_first_tail_x15_r0_body.cx1_129.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband129 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P129.NL && Nat.ble PRE_first_tail_x15_r0_body.P129.NL PRE_first_tail_x15_r0_body.P129.N0 && Nat.ble PRE_first_tail_x15_r0_body.P129.N0 PRE_first_tail_x15_r0_body.cx0_129.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow129 : PRE_first_tail_x15_r0_body.kd129.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren129 : checkRenG PRE_first_tail_x15_r0_body.kd129.hnd PRE_first_tail_x15_r0_body.khinv129 (phB PRE_first_tail_x15_r0_body.cx0_129.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband129 : PRE_first_tail_x15_r0_body.kd129.checkBand PRE_first_tail_x15_r0_body.P129.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos129 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd129.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren129 : checkRenG PRE_first_tail_x15_r0_body.kd129.node PRE_first_tail_x15_r0_body.kninv129 (pnB PRE_first_tail_x15_r0_body.cx0_129.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow129 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd129.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P129.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd129.nodeF j) PRE_first_tail_x15_r0_body.cx1_129.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a129 : PRE_first_tail_x15_r0_body.cx0_129.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b129 : PRE_first_tail_x15_r0_body.cx0_129.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1129 : PRE_first_tail_x15_r0_body.cx1_129.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend129 : PRE_first_tail_x15_r0_body.cx1_129.mlx.pending = PRE_first_tail_x15_r0_body.cx0_129.mlx.pending.map PRE_first_tail_x15_r0_body.kappa129.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh129 : PRE_first_tail_x15_r0_body.cx1_129.mlx.errh = PRE_first_tail_x15_r0_body.cx0_129.mlx.errh.map PRE_first_tail_x15_r0_body.kappa129.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles129 : PRE_first_tail_x15_r0_body.cx1_129.mlx.files = PRE_first_tail_x15_r0_body.cx0_129.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch129 : PRE_first_tail_x15_r0_body.cx1_129.mlx.arch = PRE_first_tail_x15_r0_body.cx0_129.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes129 : PRE_first_tail_x15_r0_body.cx1_129.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_129.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired129 : PRE_first_tail_x15_r0_body.cx1_129.mlx.wired = PRE_first_tail_x15_r0_body.cx0_129.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost129 : PRE_first_tail_x15_r0_body.cx1_129.host = PRE_first_tail_x15_r0_body.cx0_129.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd129`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0129 : PRE_first_tail_x15_r0_body.kd129.n0 = 2776671
kernel_rfl PRE_first_tail_x15_r0_body.ckn1129 : PRE_first_tail_x15_r0_body.kd129.n1 = 2777021
kernel_rfl PRE_first_tail_x15_r0_body.ckheap129 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd129.heap).all (fun x => Nat.ble 2776656 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl129 : (List.range 15).all (fun j => decide (PRE_first_tail_x15_r0_body.kd129.heap.get (2776656 + j) = nth? PRE_first_tail_x15_r0_body.pl129 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja129 : Nat.ble 2776656 2776656 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn129 : Nat.ble 5604 5604 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD129 : Nat.ble 2776656 PRE_first_tail_x15_r0_body.kd129.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn129 : Nat.ble 20753 PRE_first_tail_x15_r0_body.kd129.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn129 : Nat.ble 17846 PRE_first_tail_x15_r0_body.kd129.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb129 : Nat.ble 20753 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap129 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd129.heap).all (Nat.ble (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd129 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd129.hnd).all (Nat.ble (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode129 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd129.node).all (Nat.ble (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix129 : Conv.FixOld (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa129 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja129) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn129) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD129) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn129) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn129) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb129) PRE_first_tail_x15_r0_body.fheap129 PRE_first_tail_x15_r0_body.fhnd129 PRE_first_tail_x15_r0_body.fnode129
kernel_rfl PRE_first_tail_x15_r0_body.fcxn129 : (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn129 : (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0129 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_129.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_129.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk129 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd129.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A129 : PRE_first_tail_x15_r0_body.cx1_129.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS129.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_129.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O129 : PRE_first_tail_x15_r0_body.cx1_129.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS129.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_129.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N129 : PRE_first_tail_x15_r0_body.cx1_129.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS129.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_129.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I129 : PRE_first_tail_x15_r0_body.cx1_129.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS129.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_129.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd129 : (PRE_first_tail_x15_r0_body.clo129 ++ PRE_first_tail_x15_r0_body.cln129 ++ PRE_first_tail_x15_r0_body.cli129 ++ PRE_first_tail_x15_r0_body.cwS129 ++ PRE_first_tail_x15_r0_body.cnS129 ++ PRE_first_tail_x15_r0_body.ciS129).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW129 : PRE_first_tail_x15_r0_body.cwS129.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo129.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI129 : PRE_first_tail_x15_r0_body.ciS129.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli129.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN129 : PRE_first_tail_x15_r0_body.cnS129.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF129 : PRE_first_tail_x15_r0_body.cln129.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh129 : PRE_first_tail_x15_r0_body.clo129.all (handleOK PRE_first_tail_x15_r0_body.kappa129 PRE_first_tail_x15_r0_body.P129.lo PRE_first_tail_x15_r0_body.cx0_129.mlx PRE_first_tail_x15_r0_body.cx1_129.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo129 : PRE_first_tail_x15_r0_body.clo129.map (fun h => PRE_first_tail_x15_r0_body.cx1_129.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa129.handle h)) = PRE_first_tail_x15_r0_body.clo129.map (fun h => (PRE_first_tail_x15_r0_body.cx0_129.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa129.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok129 : PRE_first_tail_x15_r0_body.clo129.all (objOK PRE_first_tail_x15_r0_body.kappa129 PRE_first_tail_x15_r0_body.P129.NL PRE_first_tail_x15_r0_body.cx0_129.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd129 : PRE_first_tail_x15_r0_body.cln129.all (nodeOKF PRE_first_tail_x15_r0_body.kappa129 PRE_first_tail_x15_r0_body.P129 PRE_first_tail_x15_r0_body.cx0_129.mlx PRE_first_tail_x15_r0_body.cx1_129.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp129 : ((PRE_first_tail_x15_r0_body.cln129.filter (fullB PRE_first_tail_x15_r0_body.P129))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_129.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa129.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln129.filter (fullB PRE_first_tail_x15_r0_body.P129))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_129.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa129.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI129 : incrB PRE_first_tail_x15_r0_body.kd129.nodeF (List.range' 17846 6) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK129 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd129.node).all (fun k => Nat.ble 17846 k && Nat.blt k 17852) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL129 : (PRE_first_tail_x15_r0_body.cln129.filter (Nat.ble PRE_first_tail_x15_r0_body.P129.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd129.nodeF i) && (Nat.blt i 17852 || Nat.ble PRE_first_tail_x15_r0_body.kd129.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord129 : (PRE_first_tail_x15_r0_body.cln129.filter (Nat.ble PRE_first_tail_x15_r0_body.P129.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd129.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd129.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd129.nodeF j) (PRE_first_tail_x15_r0_body.kd129.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow129 PRE_first_tail_x15_r0_body.cnn1129 PRE_first_tail_x15_r0_body.fnordI129 PRE_first_tail_x15_r0_body.fnordK129 PRE_first_tail_x15_r0_body.fnordL129
kernel_rfl PRE_first_tail_x15_r0_body.fi129 : PRE_first_tail_x15_r0_body.cli129.all (pnB PRE_first_tail_x15_r0_body.cx0_129.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii129 : PRE_first_tail_x15_r0_body.cli129.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_129.mlx.items.get (PRE_first_tail_x15_r0_body.kappa129.node k) = (PRE_first_tail_x15_r0_body.cx0_129.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa129.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot129 (clean : Conv.NClean (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P129.NL) (cl : SSt (· < 5613) PRE_first_tail_x15_r0_body.cx0_129.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P129 5613 PRE_first_tail_x15_r0_body.kappa129 PRE_first_tail_x15_r0_body.kd129 PRE_first_tail_x15_r0_body.khinv129 PRE_first_tail_x15_r0_body.kninv129 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx PRE_first_tail_x15_r0_body.cx0_129.mlx PRE_first_tail_x15_r0_body.cx1_129.mlx (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo129 PRE_first_tail_x15_r0_body.cln129 PRE_first_tail_x15_r0_body.cli129 PRE_first_tail_x15_r0_body.cwS129 PRE_first_tail_x15_r0_body.cnS129 PRE_first_tail_x15_r0_body.ciS129 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0129, PRE_first_tail_x15_r0_body.cnh1129, PRE_first_tail_x15_r0_body.cnn0129, PRE_first_tail_x15_r0_body.cnn1129, PRE_first_tail_x15_r0_body.cplo129, PRE_first_tail_x15_r0_body.ccnt129, PRE_first_tail_x15_r0_body.cnband129, PRE_first_tail_x15_r0_body.chbelow129, PRE_first_tail_x15_r0_body.chren129, PRE_first_tail_x15_r0_body.cband129, PRE_first_tail_x15_r0_body.cnh1pos129, PRE_first_tail_x15_r0_body.cnren129, PRE_first_tail_x15_r0_body.cnlow129, PRE_first_tail_x15_r0_body.cabs0a129, PRE_first_tail_x15_r0_body.cabs0b129, PRE_first_tail_x15_r0_body.ctok1129, PRE_first_tail_x15_r0_body.cpend129, PRE_first_tail_x15_r0_body.cerrh129, PRE_first_tail_x15_r0_body.cfiles129, PRE_first_tail_x15_r0_body.carch129, PRE_first_tail_x15_r0_body.csizes129, PRE_first_tail_x15_r0_body.cwired129, PRE_first_tail_x15_r0_body.cfix129, clean, PRE_first_tail_x15_r0_body.fcxn129, PRE_first_tail_x15_r0_body.fcnn129, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0129, PRE_first_tail_x15_r0_body.fnk129, PRE_first_tail_x15_r0_body.ckA129, PRE_first_tail_x15_r0_body.cobjsK129, PRE_first_tail_x15_r0_body.cnodesK129, PRE_first_tail_x15_r0_body.citemsK129, PRE_first_tail_x15_r0_body.f1A129, PRE_first_tail_x15_r0_body.f1O129, PRE_first_tail_x15_r0_body.f1N129, PRE_first_tail_x15_r0_body.f1I129, PRE_first_tail_x15_r0_body.fbd129, PRE_first_tail_x15_r0_body.fincW129, PRE_first_tail_x15_r0_body.fincI129, PRE_first_tail_x15_r0_body.fincN129, PRE_first_tail_x15_r0_body.flnF129, PRE_first_tail_x15_r0_body.fh129, PRE_first_tail_x15_r0_body.fo129, PRE_first_tail_x15_r0_body.fok129, PRE_first_tail_x15_r0_body.fnd129, PRE_first_tail_x15_r0_body.fp129, PRE_first_tail_x15_r0_body.fnord129, PRE_first_tail_x15_r0_body.fi129, PRE_first_tail_x15_r0_body.fii129⟩
theorem PRE_first_tail_x15_r0_body.cnshift129 (clean : Conv.NClean (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P129.NL) (cl : SSt (· < 5613) PRE_first_tail_x15_r0_body.cx0_129.mlx) : NShift PRE_first_tail_x15_r0_body.P129 5613 PRE_first_tail_x15_r0_body.kappa129 PRE_first_tail_x15_r0_body.cx0_129 PRE_first_tail_x15_r0_body.cx1_129 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot129 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost129 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0129 PRE_first_tail_x15_r0_body.ckn1129 PRE_first_tail_x15_r0_body.ckheap129 PRE_first_tail_x15_r0_body.ckpl129)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_129 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1252.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_129 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1252.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_129 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1252.ffi) = some PRE_first_tail_x15_r0_body.fxC_129
kernel_rfl PRE_first_tail_x15_r0_body.okrC_129 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1252.ffi) = some PRE_first_tail_x15_r0_body.krC_129
noncomputable def PRE_first_tail_x15_r0_body.fx0_129 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1254.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_129 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1254.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_129 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1254.ffi) = some PRE_first_tail_x15_r0_body.fx0_129
kernel_rfl PRE_first_tail_x15_r0_body.okr0_129 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1254.ffi) = some PRE_first_tail_x15_r0_body.kr0_129
noncomputable def PRE_first_tail_x15_r0_body.fx1_129 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1253.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_129 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1253.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_129 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1253.ffi) = some PRE_first_tail_x15_r0_body.fx1_129
kernel_rfl PRE_first_tail_x15_r0_body.okr1_129 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1253.ffi) = some PRE_first_tail_x15_r0_body.kr1_129
kernel_rfl PRE_first_tail_x15_r0_body.ff0129 : PRE_first_tail_x15_r0_body.fx0_129 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_129 (PRE_first_tail_x15_r0_body.clo129.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_129.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1129 : PRE_first_tail_x15_r0_body.fx1_129 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_129 (PRE_first_tail_x15_r0_body.cwS129.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_129.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck129 : freedLB PRE_first_tail_x15_r0_body.kappa129 PRE_first_tail_x15_r0_body.cx0_129.mlx PRE_first_tail_x15_r0_body.fx0_129 PRE_first_tail_x15_r0_body.fx1_129 PRE_first_tail_x15_r0_body.clo129 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0129 : PRE_first_tail_x15_r0_body.kr0_129.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_129.flags (PRE_first_tail_x15_r0_body.clo129.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_129.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0129 : PRE_first_tail_x15_r0_body.kr0_129.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_129.targs (PRE_first_tail_x15_r0_body.clo129.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_129.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1129 : PRE_first_tail_x15_r0_body.kr1_129.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_129.flags (PRE_first_tail_x15_r0_body.cwS129.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_129.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1129 : PRE_first_tail_x15_r0_body.kr1_129.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_129.targs (PRE_first_tail_x15_r0_body.cwS129.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_129.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck129 : krecLB PRE_first_tail_x15_r0_body.kappa129 5613 PRE_first_tail_x15_r0_body.cx0_129.mlx PRE_first_tail_x15_r0_body.kr0_129 PRE_first_tail_x15_r0_body.kr1_129 PRE_first_tail_x15_r0_body.clo129 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn129 : Nat.ble 5604 5613 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge129 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1253.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1254.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR129 : pendRegB PRE_first_tail_x15_r0_body.kappa129 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe129 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1253.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift129 (clean : Conv.NClean (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P129.NL) (cl : SSt (· < 5613) PRE_first_tail_x15_r0_body.cx0_129.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_129.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_129.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_129.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_129.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P129 5613 PRE_first_tail_x15_r0_body.kappa129 PRE_first_tail_x15_r0_body.s1254.ffi PRE_first_tail_x15_r0_body.s1253.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift129 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue129, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp129 t ht),
    PRE_first_tail_x15_r0_body.cbridge129,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1254.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1253.ffi) (PRE_first_tail_x15_r0_body.cfoot129 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_129 PRE_first_tail_x15_r0_body.ofx1_129 hobjC PRE_first_tail_x15_r0_body.ff0129 PRE_first_tail_x15_r0_body.ff1129 PRE_first_tail_x15_r0_body.ffck129,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1254.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1253.ffi) (PRE_first_tail_x15_r0_body.cfoot129 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_129 PRE_first_tail_x15_r0_body.okr1_129 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn129) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0129 PRE_first_tail_x15_r0_body.fkt0129 PRE_first_tail_x15_r0_body.fkf1129 PRE_first_tail_x15_r0_body.fkt1129 PRE_first_tail_x15_r0_body.fkck129,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0129 PRE_first_tail_x15_r0_body.cnh1129 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe129) PRE_first_tail_x15_r0_body.cpendR129⟩

end Host.Load.Run.Tpl
end

section -- st129/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st129 0
host_stream_state PRE_first_tail_x15_r0_body.st129 1
host_stream_state PRE_first_tail_x15_r0_body.st129 2
host_stream_state PRE_first_tail_x15_r0_body.st129 3
end Host.Load.Run.Tpl
end

section -- Site129
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 129 of chain `PRE_first_tail_x15_r0_body`: `kvW__g129__g130` (`appendWindow`), the call state `PRE_first_tail_x15_r0_body.s1252`, the merged state `PRE_first_tail_x15_r0_body.s1253`,
the site template `PRE_first_tail_x15_r0_body.st129` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1254`: the merge.
The footprint's facts are in `SiteF129`, the compaction's in `SiteC129`, `SiteK129`, `SiteNa129`, `SiteNb129`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso129 : PRE_first_tail_x15_r0_body.st129.s0 = { PRE_first_tail_x15_r0_body.s1252 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs129 : List Frame := PRE_first_tail_x15_r0_body.s1252.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_129 : PRE_first_tail_x15_r0_body.S1252.tab.length = 5604
kernel_rfl PRE_first_tail_x15_r0_body.tab0_129 : PRE_first_tail_x15_r0_body.st129.S0.tab = PRE_first_tail_x15_r0_body.S1252.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws129 : List Nat := [3158, 3159, 3160, 3161, 3162, 3163, 3164, 3165, 3166, 3167, 3168, 3169, 3170, 3171, 3172, 3173, 3174]
kernel_rfl PRE_first_tail_x15_r0_body.fresh129 : (PRE_first_tail_x15_r0_body.S1252.tab.all fun e => PRE_first_tail_x15_r0_body.ws129.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1252.oracle.all fun q => PRE_first_tail_x15_r0_body.ws129.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab129 : PRE_first_tail_x15_r0_body.S1253.tab = PRE_first_tail_x15_r0_body.S1252.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws129
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen129 : PRE_first_tail_x15_r0_body.st129.S3.tab.length - PRE_first_tail_x15_r0_body.st129.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged129`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap129 : PRE_first_tail_x15_r0_body.s1253.heap = PRE_first_tail_x15_r0_body.st129.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext129 : PRE_first_tail_x15_r0_body.s1253.next = PRE_first_tail_x15_r0_body.st129.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl129 : PRE_first_tail_x15_r0_body.s1253.ctl = PRE_first_tail_x15_r0_body.st129.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack129 : PRE_first_tail_x15_r0_body.s1253.stack = PRE_first_tail_x15_r0_body.st129.s3.stack ++ PRE_first_tail_x15_r0_body.s1252.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs129 : PRE_first_tail_x15_r0_body.s1253.jobs = PRE_first_tail_x15_r0_body.st129.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi129 : PRE_first_tail_x15_r0_body.s1253.ffi = PRE_first_tail_x15_r0_body.st129.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace129 : PRE_first_tail_x15_r0_body.s1253.trace = PRE_first_tail_x15_r0_body.st129.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores129 : PRE_first_tail_x15_r0_body.s1253.stores = PRE_first_tail_x15_r0_body.st129.s3.stores

end Host.Load.Run.Tpl
end

section -- SiteD129
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 129 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived129 : PRE_first_tail_x15_r0_body.nr129.map (fun r => nth? PRE_first_tail_x15_r0_body.st129.S3.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false)))]
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo129 : PRE_first_tail_x15_r0_body.nr129.all (Nat.ble 5604) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj129 : PRE_first_tail_x15_r0_body.cws129.all (fun c => !PRE_first_tail_x15_r0_body.ws129.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ129 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws129 PRE_first_tail_x15_r0_body.crs129 PRE_first_tail_x15_r0_body.ws129

end Host.Load.Run.Tpl
end

section -- st129/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st129`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st129.wrR : List (Nat × Nat) := [(2672632, 2672633)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st129.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st129.s3.heap PRE_first_tail_x15_r0_body.st129.wrR ++ freshOf PRE_first_tail_x15_r0_body.st129.s3.heap PRE_first_tail_x15_r0_body.st129.s0.next PRE_first_tail_x15_r0_body.st129.s3.next
noncomputable def PRE_first_tail_x15_r0_body.st129.wr : List Nat := PRE_first_tail_x15_r0_body.st129.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st129.heapFoot : PRE_first_tail_x15_r0_body.st129.s3.heap = setAll PRE_first_tail_x15_r0_body.st129.s0.heap PRE_first_tail_x15_r0_body.st129.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st129.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st129.s0.next PRE_first_tail_x15_r0_body.st129.s3.next = true
theorem PRE_first_tail_x15_r0_body.st129.grows : PRE_first_tail_x15_r0_body.st129.s0.next ≤ PRE_first_tail_x15_r0_body.st129.s3.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st129.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st129.wh : List Nat := [20753, 20754, 20755, 20756, 20757, 20758]
def PRE_first_tail_x15_r0_body.st129.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st129.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st129.s3.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st129.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st129.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st129.s3.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st129.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st129.s3.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st129.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st129.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st129.s3.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st129.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st129.s3.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st129.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st129.s3.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st129.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st129.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st129.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st129.s3.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st129.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st129.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st129.s3.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st129.s3.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st129.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st129.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st129.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st129.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st129.s3.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st129.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st129.s3.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF129
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 129 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB129 : nodupT PRE_first_tail_x15_r0_body.st129.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup129 : PRE_first_tail_x15_r0_body.st129.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB129).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB129 : PRE_first_tail_x15_r0_body.st129.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound129 : ∀ b ∈ PRE_first_tail_x15_r0_body.st129.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB129 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr129 := PRE_first_tail_x15_r0_body.st129.s3.trace.take 26
kernel_rfl PRE_first_tail_x15_r0_body.traceEq129 : PRE_first_tail_x15_r0_body.st129.s3.trace = PRE_first_tail_x15_r0_body.trFr129 ++ PRE_first_tail_x15_r0_body.st129.s0.trace
theorem PRE_first_tail_x15_r0_body.trace129 : ∃ fr, PRE_first_tail_x15_r0_body.st129.s3.trace = fr ++ PRE_first_tail_x15_r0_body.st129.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq129⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide129 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB129 : (PRE_first_tail_x15_r0_body.wide129.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st129.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix129 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide129, WFix Map.id (Present PRE_first_tail_x15_r0_body.st129.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB129 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL129
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 129 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1253`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO129 : PRE_first_tail_x15_r0_body.st129.S0.oracle = PRE_first_tail_x15_r0_body.st129.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B129 : PRE_first_tail_x15_r0_body.st129.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st129.s0.next || (PRE_first_tail_x15_r0_body.st129.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot129 : Conv.StageFoot PRE_first_tail_x15_r0_body.st129.wr PRE_first_tail_x15_r0_body.st129.s0 PRE_first_tail_x15_r0_body.st129.s3 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st129.heapFoot PRE_first_tail_x15_r0_body.wrNodup129 PRE_first_tail_x15_r0_body.wrBound129 PRE_first_tail_x15_r0_body.wr0B129 PRE_first_tail_x15_r0_body.st129.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged129 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st129.F.S → PRE_first_tail_x15_r0_body.st129.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st129.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st129.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs129 PRE_first_tail_x15_r0_body.st129.wr PRE_first_tail_x15_r0_body.s1252 PRE_first_tail_x15_r0_body.st129.s3 PRE_first_tail_x15_r0_body.st129.s0
      PRE_first_tail_x15_r0_body.st129.s3.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st129.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1253 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso129 PRE_first_tail_x15_r0_body.stFoot129 PRE_first_tail_x15_r0_body.wrNodup129 PRE_first_tail_x15_r0_body.wrBound129 PRE_first_tail_x15_r0_body.trace129 PRE_first_tail_x15_r0_body.mheap129
    PRE_first_tail_x15_r0_body.mnext129 PRE_first_tail_x15_r0_body.mctl129 PRE_first_tail_x15_r0_body.mstack129 PRE_first_tail_x15_r0_body.mjobs129 PRE_first_tail_x15_r0_body.mffi129 PRE_first_tail_x15_r0_body.mtrace129 PRE_first_tail_x15_r0_body.mstores129 h

def PRE_first_tail_x15_r0_body.arrEl129_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE129_2665 : arrOf PRE_first_tail_x15_r0_body.s1253 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl129_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA129_2665 : isArrB PRE_first_tail_x15_r0_body.s1253 2665 = true
theorem PRE_first_tail_x15_r0_body.arr129_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1253.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl129_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE129_2665 PRE_first_tail_x15_r0_body.arrA129_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN129_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl129_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR129_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl129_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN129_2665

def PRE_first_tail_x15_r0_body.arrEl129_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE129_2673467 : arrOf PRE_first_tail_x15_r0_body.s1253 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl129_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA129_2673467 : isArrB PRE_first_tail_x15_r0_body.s1253 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr129_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1253.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl129_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE129_2673467 PRE_first_tail_x15_r0_body.arrA129_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN129_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl129_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR129_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl129_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN129_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k129 : isArrB PRE_first_tail_x15_r0_body.s1253 4910 = false
theorem PRE_first_tail_x15_r0_body.keep129 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1253 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k129 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr129_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl129_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ129
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 129 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1252`, the merged
state `PRE_first_tail_x15_r0_body.s1253`, the canonical state `PRE_first_tail_x15_r0_body.s1254`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl129 : PRE_first_tail_x15_r0_body.pl129.all (Nat.ble PRE_first_tail_x15_r0_body.s1252.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd129 : nodupT PRE_first_tail_x15_r0_body.pl129 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1129 : Nat.ble PRE_first_tail_x15_r0_body.s1252.next 2777021 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst129 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1252.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn129 : PRE_first_tail_x15_r0_body.s1254.next = PRE_first_tail_x15_r0_body.s1252.next + PRE_first_tail_x15_r0_body.pl129.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn129 : PRE_first_tail_x15_r0_body.s1253.next = 2777021
kernel_rfl PRE_first_tail_x15_r0_body.zgrow129 : Nat.ble PRE_first_tail_x15_r0_body.s1254.next PRE_first_tail_x15_r0_body.s1253.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh129 : PRE_first_tail_x15_r0_body.S1252.tab.all (fun e => PRE_first_tail_x15_r0_body.cws129.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd129 : nodupT PRE_first_tail_x15_r0_body.cws129 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi129 : PRE_first_tail_x15_r0_body.nr129.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1253.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt129 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1252.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg129_2665 : PRE_first_tail_x15_r0_body.s1254.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1254 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk129_2665 : (objOf PRE_first_tail_x15_r0_body.s1254 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm129_2665 : PRE_first_tail_x15_r0_body.s1253.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa129.obj (objOf PRE_first_tail_x15_r0_body.s1254 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1253 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg129_2673467 : PRE_first_tail_x15_r0_body.s1254.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1254 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk129_2673467 : (objOf PRE_first_tail_x15_r0_body.s1254 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm129_2673467 : PRE_first_tail_x15_r0_body.s1253.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa129.obj (objOf PRE_first_tail_x15_r0_body.s1254 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1253 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw129_4910 : (PRE_first_tail_x15_r0_body.s1254.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw129_2673472 : (PRE_first_tail_x15_r0_body.s1254.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw129_2673473 : (PRE_first_tail_x15_r0_body.s1254.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd129 : PRE_first_tail_x15_r0_body.cl129.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr129 : PRE_first_tail_x15_r0_body.st129.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1252.next || PRE_first_tail_x15_r0_body.cl129.contains b) = true
def PRE_first_tail_x15_r0_body.zl129 : List Nat := PRE_first_tail_x15_r0_body.cl129.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE129 : PRE_first_tail_x15_r0_body.zl129.map (fun a => PRE_first_tail_x15_r0_body.s1253.heap.get (PRE_first_tail_x15_r0_body.kappa129.a a)) = PRE_first_tail_x15_r0_body.zl129.map (fun a => (PRE_first_tail_x15_r0_body.s1254.heap.get a).map PRE_first_tail_x15_r0_body.kappa129.hobj)
theorem PRE_first_tail_x15_r0_body.zimg129 : HeapImg PRE_first_tail_x15_r0_body.kappa129 PRE_first_tail_x15_r0_body.s1254 PRE_first_tail_x15_r0_body.s1253 PRE_first_tail_x15_r0_body.zl129 := PRE_first_tail_x15_r0_body.zimgE129
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl129 : PRE_first_tail_x15_r0_body.s1253.ctl = PRE_first_tail_x15_r0_body.kappa129.ctl PRE_first_tail_x15_r0_body.s1254.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack129 : PRE_first_tail_x15_r0_body.s1253.stack = PRE_first_tail_x15_r0_body.s1254.stack.map PRE_first_tail_x15_r0_body.kappa129.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs129 : PRE_first_tail_x15_r0_body.s1253.jobs = PRE_first_tail_x15_r0_body.s1254.jobs.map PRE_first_tail_x15_r0_body.kappa129.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores129 : PRE_first_tail_x15_r0_body.s1253.stores = PRE_first_tail_x15_r0_body.kappa129.stores PRE_first_tail_x15_r0_body.s1254.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots129 : checkRootsSupp PRE_first_tail_x15_r0_body.s1254 5613 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC129 : PRE_first_tail_x15_r0_body.S1252.tab.length + PRE_first_tail_x15_r0_body.cws129.length = 5613
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap129 : PRE_first_tail_x15_r0_body.kappa129 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1252.next 2777021 PRE_first_tail_x15_r0_body.S1252.tab.length PRE_first_tail_x15_r0_body.pl129 (PRE_first_tail_x15_r0_body.nr129.map NumV.ref) PRE_first_tail_x15_r0_body.kd129.big
  PRE_first_tail_x15_r0_body.kd129.region PRE_first_tail_x15_r0_body.kd129.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin129 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1254.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc129 : Conv.jcleanListB (⟨20757, 17852, 2776671, 5613⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1254 PRE_first_tail_x15_r0_body.cl129 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB129 : noBigRootsP (fun i => !Conv.oldBigB (⟨20757, 17852, 2776671, 5613⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1254.trace PRE_first_tail_x15_r0_body.s1254 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm129 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17846 = true
theorem PRE_first_tail_x15_r0_body.cjcl129 (h : Conv.JClean (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1252) : Conv.JClean (⟨20757, 17852, 2776671, 5613⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1254 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle129)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap129 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd129 a ha)) PRE_first_tail_x15_r0_body.zjc129

end Host.Load.Run.Tpl
end

section -- st129/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st129.bodyLast from PRE_first_tail_x15_r0_body.st129.s2 to PRE_first_tail_x15_r0_body.st129.s3 :
  interpS (step PRE_first_tail_x15_r0_body.st129.F PRE_first_tail_x15_r0_body.st129.s2).run PRE_first_tail_x15_r0_body.st129.S2 = some (PRE_first_tail_x15_r0_body.st129.s3, PRE_first_tail_x15_r0_body.st129.S3)
kernel_rfl PRE_first_tail_x15_r0_body.st129.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st129.s2.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st129.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st129.s3.stack = true

end Host.Load.Run.Tpl
end

section -- st129/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st129.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st129.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st129.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st129.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st129.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st129.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st129.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st129.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st129.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st129.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st129.s0 PRE_first_tail_x15_r0_body.st129.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st129.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st129.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st129.s2 PRE_first_tail_x15_r0_body.st129.S2) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st129/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st129.bodyK0F from PRE_first_tail_x15_r0_body.st129.s0 to PRE_first_tail_x15_r0_body.st129.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st129.F (PRE_first_tail_x15_r0_body.st129.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st129.ks 0).getD 0) PRE_first_tail_x15_r0_body.st129.s0 PRE_first_tail_x15_r0_body.st129.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st129.s1, PRE_first_tail_x15_r0_body.st129.S1)
theorem PRE_first_tail_x15_r0_body.st129.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st129.F (PRE_first_tail_x15_r0_body.st129.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st129.ks 0).getD 0) PRE_first_tail_x15_r0_body.st129.s0 PRE_first_tail_x15_r0_body.st129.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st129.s1, PRE_first_tail_x15_r0_body.st129.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st129.bodyOkLN_ok PRE_first_tail_x15_r0_body.st129.bodyK0F
end Host.Load.Run.Tpl
end

section -- st129/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st129.bodyK1F from PRE_first_tail_x15_r0_body.st129.s1 to PRE_first_tail_x15_r0_body.st129.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st129.F (PRE_first_tail_x15_r0_body.st129.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st129.ks 1).getD 0) PRE_first_tail_x15_r0_body.st129.s1 PRE_first_tail_x15_r0_body.st129.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st129.s2, PRE_first_tail_x15_r0_body.st129.S2)
theorem PRE_first_tail_x15_r0_body.st129.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st129.F (PRE_first_tail_x15_r0_body.st129.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st129.ks 1).getD 0) PRE_first_tail_x15_r0_body.st129.s1 PRE_first_tail_x15_r0_body.st129.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st129.s2, PRE_first_tail_x15_r0_body.st129.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st129.bodyOkLN_ok PRE_first_tail_x15_r0_body.st129.bodyK1F
end Host.Load.Run.Tpl
end

section -- st129/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st129.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st129.F (PRE_first_tail_x15_r0_body.st129.bodyOkL bytes rows) 3452 PRE_first_tail_x15_r0_body.st129.s0 PRE_first_tail_x15_r0_body.st129.S0 = some (PRE_first_tail_x15_r0_body.st129.s2, PRE_first_tail_x15_r0_body.st129.S2) :=
  runOk_trans PRE_first_tail_x15_r0_body.st129.F (PRE_first_tail_x15_r0_body.st129.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st129.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st129.ks 1).getD 0) PRE_first_tail_x15_r0_body.st129.s0 PRE_first_tail_x15_r0_body.st129.s1 PRE_first_tail_x15_r0_body.st129.s2 PRE_first_tail_x15_r0_body.st129.S0 PRE_first_tail_x15_r0_body.st129.S1 PRE_first_tail_x15_r0_body.st129.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st129.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st129.bodyK1 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st129.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st129.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st129.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st129.F (PRE_first_tail_x15_r0_body.st129.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st129.s0
  S0 := PRE_first_tail_x15_r0_body.st129.S0
  s1 := PRE_first_tail_x15_r0_body.st129.s2
  S1 := PRE_first_tail_x15_r0_body.st129.S2
  s2 := PRE_first_tail_x15_r0_body.st129.s3
  S2 := PRE_first_tail_x15_r0_body.st129.S3
  n := 3452
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st129.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st129.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st129.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st129.bodyHalt
  last := PRE_first_tail_x15_r0_body.st129.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st129.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC130
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 130 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1262` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa130` into the merged state
`PRE_first_tail_x15_r0_body.s1261`. -/

def PRE_first_tail_x15_r0_body.pl130 : List Nat := []
def PRE_first_tail_x15_r0_body.nr130 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd130 : RData :=
  ⟨2777253, 2777255, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20770, 20770, 17862, 17862, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa130 : Map :=
  Conv.Map.compact 2777253 2777255 5636 PRE_first_tail_x15_r0_body.pl130 (PRE_first_tail_x15_r0_body.nr130.map NumV.ref) PRE_first_tail_x15_r0_body.kd130.big
    PRE_first_tail_x15_r0_body.kd130.region PRE_first_tail_x15_r0_body.kd130.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws130 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs130 : List SymE := PRE_first_tail_x15_r0_body.nr130.map fun r => (nth? PRE_first_tail_x15_r0_body.S1261.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta130 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws130 PRE_first_tail_x15_r0_body.crs130
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB130 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab130 : PRE_first_tail_x15_r0_body.S1262.tab = PRE_first_tail_x15_r0_body.S1260.tab ++ PRE_first_tail_x15_r0_body.cws130.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace130 : PRE_first_tail_x15_r0_body.s1262.trace = PRE_first_tail_x15_r0_body.s1260.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext130 : PRE_first_tail_x15_r0_body.s1262.next = 2777253
kernel_rfl PRE_first_tail_x15_r0_body.ccounters130 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi).mlx.nnext) = (20770, 17862)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue130 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1261.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa130.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp130 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi).mlx.tokens.all (bSN 5636) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean130 : Conv.cleanListB 20770 131072 (fun r => Nat.ble 83080 r) PRE_first_tail_x15_r0_body.s1262
    (PRE_first_tail_x15_r0_body.wrB130 ++ (List.range 0).map (2777253 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs130 : bigsOutB 20770 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK130
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl130`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl130 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo130 : List Nat := []
def PRE_first_tail_x15_r0_body.cln130 : List Nat := []
def PRE_first_tail_x15_r0_body.cli130 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap130 : PRE_first_tail_x15_r0_body.s1262.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1260.heap (PRE_first_tail_x15_r0_body.cl130.filterMap fun a => (PRE_first_tail_x15_r0_body.s1262.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe130 : Nat.ble PRE_first_tail_x15_r0_body.s1260.next PRE_first_tail_x15_r0_body.s1262.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP130 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1260 PRE_first_tail_x15_r0_body.s1262 PRE_first_tail_x15_r0_body.cl130 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp130 : Conv.suppListB PRE_first_tail_x15_r0_body.s1262 5636 PRE_first_tail_x15_r0_body.cl130 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound130 : Conv.boundListB PRE_first_tail_x15_r0_body.s1262 PRE_first_tail_x15_r0_body.cl130 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK130 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln130.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK130 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo130.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK130 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli130.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst130 : Conv.sstListB 5636 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi).mlx PRE_first_tail_x15_r0_body.cln130 PRE_first_tail_x15_r0_body.clo130 PRE_first_tail_x15_r0_body.cli130 = true

end Host.Load.Run.Tpl
end

section -- SiteCl130
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA130 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo130.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd130 : (PRE_first_tail_x15_r0_body.clo130 ++ PRE_first_tail_x15_r0_body.cln130 ++ PRE_first_tail_x15_r0_body.cli130).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle130 : Conv.Cnt.leB (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt) (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck130 : Conv.ncleanListB (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi).mlx PRE_first_tail_x15_r0_body.clo130 PRE_first_tail_x15_r0_body.cln130 PRE_first_tail_x15_r0_body.cli130 = true
theorem PRE_first_tail_x15_r0_body.cncl130 (h : Conv.NClean (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx) : Conv.NClean (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle130 PRE_first_tail_x15_r0_body.ckA130 PRE_first_tail_x15_r0_body.cobjsK130 PRE_first_tail_x15_r0_body.cnodesK130 PRE_first_tail_x15_r0_body.citemsK130 PRE_first_tail_x15_r0_body.cbd130 PRE_first_tail_x15_r0_body.cck130

end Host.Load.Run.Tpl
end

section -- SiteS130
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 130 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc130 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P130 : LoadP := PRE_first_tail_x15_r0_body.Pc130.raise 17862
kernel_rfl PRE_first_tail_x15_r0_body.craise130 : Nat.ble PRE_first_tail_x15_r0_body.Pc130.N0 17862 = true
theorem PRE_first_tail_x15_r0_body.raised130 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc130 PRE_first_tail_x15_r0_body.P130 :=
  .inr ⟨17862, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise130, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_130 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_130 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1261.ffi)
def PRE_first_tail_x15_r0_body.khinv130 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv130 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS130 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS130 : List Nat := List.range' 17862 0
def PRE_first_tail_x15_r0_body.ciS130 : List Nat := [] ++ List.range' 17862 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0130 : PRE_first_tail_x15_r0_body.kd130.nh0 = PRE_first_tail_x15_r0_body.cx0_130.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1130 : PRE_first_tail_x15_r0_body.kd130.nh1 = PRE_first_tail_x15_r0_body.cx1_130.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0130 : PRE_first_tail_x15_r0_body.kd130.nn0 = PRE_first_tail_x15_r0_body.cx0_130.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1130 : PRE_first_tail_x15_r0_body.kd130.nn1 = PRE_first_tail_x15_r0_body.cx1_130.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo130 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P130.lo && Nat.ble PRE_first_tail_x15_r0_body.P130.lo PRE_first_tail_x15_r0_body.cx0_130.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P130.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P130.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt130 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_130.mlx.next PRE_first_tail_x15_r0_body.cx1_130.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_130.mlx.nnext PRE_first_tail_x15_r0_body.cx1_130.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband130 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P130.NL && Nat.ble PRE_first_tail_x15_r0_body.P130.NL PRE_first_tail_x15_r0_body.P130.N0 && Nat.ble PRE_first_tail_x15_r0_body.P130.N0 PRE_first_tail_x15_r0_body.cx0_130.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow130 : PRE_first_tail_x15_r0_body.kd130.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren130 : checkRenG PRE_first_tail_x15_r0_body.kd130.hnd PRE_first_tail_x15_r0_body.khinv130 (phB PRE_first_tail_x15_r0_body.cx0_130.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband130 : PRE_first_tail_x15_r0_body.kd130.checkBand PRE_first_tail_x15_r0_body.P130.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos130 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd130.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren130 : checkRenG PRE_first_tail_x15_r0_body.kd130.node PRE_first_tail_x15_r0_body.kninv130 (pnB PRE_first_tail_x15_r0_body.cx0_130.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow130 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd130.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P130.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd130.nodeF j) PRE_first_tail_x15_r0_body.cx1_130.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a130 : PRE_first_tail_x15_r0_body.cx0_130.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b130 : PRE_first_tail_x15_r0_body.cx0_130.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1130 : PRE_first_tail_x15_r0_body.cx1_130.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend130 : PRE_first_tail_x15_r0_body.cx1_130.mlx.pending = PRE_first_tail_x15_r0_body.cx0_130.mlx.pending.map PRE_first_tail_x15_r0_body.kappa130.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh130 : PRE_first_tail_x15_r0_body.cx1_130.mlx.errh = PRE_first_tail_x15_r0_body.cx0_130.mlx.errh.map PRE_first_tail_x15_r0_body.kappa130.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles130 : PRE_first_tail_x15_r0_body.cx1_130.mlx.files = PRE_first_tail_x15_r0_body.cx0_130.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch130 : PRE_first_tail_x15_r0_body.cx1_130.mlx.arch = PRE_first_tail_x15_r0_body.cx0_130.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes130 : PRE_first_tail_x15_r0_body.cx1_130.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_130.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired130 : PRE_first_tail_x15_r0_body.cx1_130.mlx.wired = PRE_first_tail_x15_r0_body.cx0_130.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost130 : PRE_first_tail_x15_r0_body.cx1_130.host = PRE_first_tail_x15_r0_body.cx0_130.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd130`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0130 : PRE_first_tail_x15_r0_body.kd130.n0 = 2777253
kernel_rfl PRE_first_tail_x15_r0_body.ckn1130 : PRE_first_tail_x15_r0_body.kd130.n1 = 2777255
kernel_rfl PRE_first_tail_x15_r0_body.ckheap130 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd130.heap).all (fun x => Nat.ble 2777253 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl130 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd130.heap.get (2777253 + j) = nth? PRE_first_tail_x15_r0_body.pl130 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja130 : Nat.ble 2777253 2777253 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn130 : Nat.ble 5636 5636 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD130 : Nat.ble 2777253 PRE_first_tail_x15_r0_body.kd130.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn130 : Nat.ble 20770 PRE_first_tail_x15_r0_body.kd130.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn130 : Nat.ble 17862 PRE_first_tail_x15_r0_body.kd130.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb130 : Nat.ble 20770 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap130 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd130.heap).all (Nat.ble (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd130 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd130.hnd).all (Nat.ble (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode130 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd130.node).all (Nat.ble (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix130 : Conv.FixOld (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa130 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja130) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn130) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD130) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn130) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn130) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb130) PRE_first_tail_x15_r0_body.fheap130 PRE_first_tail_x15_r0_body.fhnd130 PRE_first_tail_x15_r0_body.fnode130
kernel_rfl PRE_first_tail_x15_r0_body.fcxn130 : (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn130 : (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0130 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_130.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_130.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk130 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd130.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A130 : PRE_first_tail_x15_r0_body.cx1_130.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS130.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_130.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O130 : PRE_first_tail_x15_r0_body.cx1_130.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS130.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_130.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N130 : PRE_first_tail_x15_r0_body.cx1_130.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS130.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_130.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I130 : PRE_first_tail_x15_r0_body.cx1_130.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS130.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_130.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd130 : (PRE_first_tail_x15_r0_body.clo130 ++ PRE_first_tail_x15_r0_body.cln130 ++ PRE_first_tail_x15_r0_body.cli130 ++ PRE_first_tail_x15_r0_body.cwS130 ++ PRE_first_tail_x15_r0_body.cnS130 ++ PRE_first_tail_x15_r0_body.ciS130).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW130 : PRE_first_tail_x15_r0_body.cwS130.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo130.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI130 : PRE_first_tail_x15_r0_body.ciS130.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli130.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN130 : PRE_first_tail_x15_r0_body.cnS130.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF130 : PRE_first_tail_x15_r0_body.cln130.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh130 : PRE_first_tail_x15_r0_body.clo130.all (handleOK PRE_first_tail_x15_r0_body.kappa130 PRE_first_tail_x15_r0_body.P130.lo PRE_first_tail_x15_r0_body.cx0_130.mlx PRE_first_tail_x15_r0_body.cx1_130.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo130 : PRE_first_tail_x15_r0_body.clo130.map (fun h => PRE_first_tail_x15_r0_body.cx1_130.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa130.handle h)) = PRE_first_tail_x15_r0_body.clo130.map (fun h => (PRE_first_tail_x15_r0_body.cx0_130.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa130.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok130 : PRE_first_tail_x15_r0_body.clo130.all (objOK PRE_first_tail_x15_r0_body.kappa130 PRE_first_tail_x15_r0_body.P130.NL PRE_first_tail_x15_r0_body.cx0_130.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd130 : PRE_first_tail_x15_r0_body.cln130.all (nodeOKF PRE_first_tail_x15_r0_body.kappa130 PRE_first_tail_x15_r0_body.P130 PRE_first_tail_x15_r0_body.cx0_130.mlx PRE_first_tail_x15_r0_body.cx1_130.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp130 : ((PRE_first_tail_x15_r0_body.cln130.filter (fullB PRE_first_tail_x15_r0_body.P130))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_130.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa130.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln130.filter (fullB PRE_first_tail_x15_r0_body.P130))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_130.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa130.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI130 : incrB PRE_first_tail_x15_r0_body.kd130.nodeF (List.range' 17862 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK130 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd130.node).all (fun k => Nat.ble 17862 k && Nat.blt k 17862) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL130 : (PRE_first_tail_x15_r0_body.cln130.filter (Nat.ble PRE_first_tail_x15_r0_body.P130.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd130.nodeF i) && (Nat.blt i 17862 || Nat.ble PRE_first_tail_x15_r0_body.kd130.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord130 : (PRE_first_tail_x15_r0_body.cln130.filter (Nat.ble PRE_first_tail_x15_r0_body.P130.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd130.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd130.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd130.nodeF j) (PRE_first_tail_x15_r0_body.kd130.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow130 PRE_first_tail_x15_r0_body.cnn1130 PRE_first_tail_x15_r0_body.fnordI130 PRE_first_tail_x15_r0_body.fnordK130 PRE_first_tail_x15_r0_body.fnordL130
kernel_rfl PRE_first_tail_x15_r0_body.fi130 : PRE_first_tail_x15_r0_body.cli130.all (pnB PRE_first_tail_x15_r0_body.cx0_130.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii130 : PRE_first_tail_x15_r0_body.cli130.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_130.mlx.items.get (PRE_first_tail_x15_r0_body.kappa130.node k) = (PRE_first_tail_x15_r0_body.cx0_130.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa130.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot130 (clean : Conv.NClean (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P130.NL) (cl : SSt (· < 5636) PRE_first_tail_x15_r0_body.cx0_130.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P130 5636 PRE_first_tail_x15_r0_body.kappa130 PRE_first_tail_x15_r0_body.kd130 PRE_first_tail_x15_r0_body.khinv130 PRE_first_tail_x15_r0_body.kninv130 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx PRE_first_tail_x15_r0_body.cx0_130.mlx PRE_first_tail_x15_r0_body.cx1_130.mlx (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo130 PRE_first_tail_x15_r0_body.cln130 PRE_first_tail_x15_r0_body.cli130 PRE_first_tail_x15_r0_body.cwS130 PRE_first_tail_x15_r0_body.cnS130 PRE_first_tail_x15_r0_body.ciS130 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0130, PRE_first_tail_x15_r0_body.cnh1130, PRE_first_tail_x15_r0_body.cnn0130, PRE_first_tail_x15_r0_body.cnn1130, PRE_first_tail_x15_r0_body.cplo130, PRE_first_tail_x15_r0_body.ccnt130, PRE_first_tail_x15_r0_body.cnband130, PRE_first_tail_x15_r0_body.chbelow130, PRE_first_tail_x15_r0_body.chren130, PRE_first_tail_x15_r0_body.cband130, PRE_first_tail_x15_r0_body.cnh1pos130, PRE_first_tail_x15_r0_body.cnren130, PRE_first_tail_x15_r0_body.cnlow130, PRE_first_tail_x15_r0_body.cabs0a130, PRE_first_tail_x15_r0_body.cabs0b130, PRE_first_tail_x15_r0_body.ctok1130, PRE_first_tail_x15_r0_body.cpend130, PRE_first_tail_x15_r0_body.cerrh130, PRE_first_tail_x15_r0_body.cfiles130, PRE_first_tail_x15_r0_body.carch130, PRE_first_tail_x15_r0_body.csizes130, PRE_first_tail_x15_r0_body.cwired130, PRE_first_tail_x15_r0_body.cfix130, clean, PRE_first_tail_x15_r0_body.fcxn130, PRE_first_tail_x15_r0_body.fcnn130, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0130, PRE_first_tail_x15_r0_body.fnk130, PRE_first_tail_x15_r0_body.ckA130, PRE_first_tail_x15_r0_body.cobjsK130, PRE_first_tail_x15_r0_body.cnodesK130, PRE_first_tail_x15_r0_body.citemsK130, PRE_first_tail_x15_r0_body.f1A130, PRE_first_tail_x15_r0_body.f1O130, PRE_first_tail_x15_r0_body.f1N130, PRE_first_tail_x15_r0_body.f1I130, PRE_first_tail_x15_r0_body.fbd130, PRE_first_tail_x15_r0_body.fincW130, PRE_first_tail_x15_r0_body.fincI130, PRE_first_tail_x15_r0_body.fincN130, PRE_first_tail_x15_r0_body.flnF130, PRE_first_tail_x15_r0_body.fh130, PRE_first_tail_x15_r0_body.fo130, PRE_first_tail_x15_r0_body.fok130, PRE_first_tail_x15_r0_body.fnd130, PRE_first_tail_x15_r0_body.fp130, PRE_first_tail_x15_r0_body.fnord130, PRE_first_tail_x15_r0_body.fi130, PRE_first_tail_x15_r0_body.fii130⟩
theorem PRE_first_tail_x15_r0_body.cnshift130 (clean : Conv.NClean (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P130.NL) (cl : SSt (· < 5636) PRE_first_tail_x15_r0_body.cx0_130.mlx) : NShift PRE_first_tail_x15_r0_body.P130 5636 PRE_first_tail_x15_r0_body.kappa130 PRE_first_tail_x15_r0_body.cx0_130 PRE_first_tail_x15_r0_body.cx1_130 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot130 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost130 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0130 PRE_first_tail_x15_r0_body.ckn1130 PRE_first_tail_x15_r0_body.ckheap130 PRE_first_tail_x15_r0_body.ckpl130)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_130 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1260.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_130 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1260.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_130 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1260.ffi) = some PRE_first_tail_x15_r0_body.fxC_130
kernel_rfl PRE_first_tail_x15_r0_body.okrC_130 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1260.ffi) = some PRE_first_tail_x15_r0_body.krC_130
noncomputable def PRE_first_tail_x15_r0_body.fx0_130 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1262.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_130 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1262.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_130 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1262.ffi) = some PRE_first_tail_x15_r0_body.fx0_130
kernel_rfl PRE_first_tail_x15_r0_body.okr0_130 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1262.ffi) = some PRE_first_tail_x15_r0_body.kr0_130
noncomputable def PRE_first_tail_x15_r0_body.fx1_130 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1261.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_130 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1261.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_130 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1261.ffi) = some PRE_first_tail_x15_r0_body.fx1_130
kernel_rfl PRE_first_tail_x15_r0_body.okr1_130 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1261.ffi) = some PRE_first_tail_x15_r0_body.kr1_130
kernel_rfl PRE_first_tail_x15_r0_body.ff0130 : PRE_first_tail_x15_r0_body.fx0_130 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_130 (PRE_first_tail_x15_r0_body.clo130.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_130.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1130 : PRE_first_tail_x15_r0_body.fx1_130 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_130 (PRE_first_tail_x15_r0_body.cwS130.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_130.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck130 : freedLB PRE_first_tail_x15_r0_body.kappa130 PRE_first_tail_x15_r0_body.cx0_130.mlx PRE_first_tail_x15_r0_body.fx0_130 PRE_first_tail_x15_r0_body.fx1_130 PRE_first_tail_x15_r0_body.clo130 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0130 : PRE_first_tail_x15_r0_body.kr0_130.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_130.flags (PRE_first_tail_x15_r0_body.clo130.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_130.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0130 : PRE_first_tail_x15_r0_body.kr0_130.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_130.targs (PRE_first_tail_x15_r0_body.clo130.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_130.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1130 : PRE_first_tail_x15_r0_body.kr1_130.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_130.flags (PRE_first_tail_x15_r0_body.cwS130.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_130.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1130 : PRE_first_tail_x15_r0_body.kr1_130.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_130.targs (PRE_first_tail_x15_r0_body.cwS130.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_130.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck130 : krecLB PRE_first_tail_x15_r0_body.kappa130 5636 PRE_first_tail_x15_r0_body.cx0_130.mlx PRE_first_tail_x15_r0_body.kr0_130 PRE_first_tail_x15_r0_body.kr1_130 PRE_first_tail_x15_r0_body.clo130 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn130 : Nat.ble 5636 5636 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge130 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1261.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1262.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR130 : pendRegB PRE_first_tail_x15_r0_body.kappa130 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe130 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1261.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift130 (clean : Conv.NClean (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P130.NL) (cl : SSt (· < 5636) PRE_first_tail_x15_r0_body.cx0_130.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_130.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_130.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_130.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_130.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P130 5636 PRE_first_tail_x15_r0_body.kappa130 PRE_first_tail_x15_r0_body.s1262.ffi PRE_first_tail_x15_r0_body.s1261.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift130 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue130, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp130 t ht),
    PRE_first_tail_x15_r0_body.cbridge130,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1262.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1261.ffi) (PRE_first_tail_x15_r0_body.cfoot130 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_130 PRE_first_tail_x15_r0_body.ofx1_130 hobjC PRE_first_tail_x15_r0_body.ff0130 PRE_first_tail_x15_r0_body.ff1130 PRE_first_tail_x15_r0_body.ffck130,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1262.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1261.ffi) (PRE_first_tail_x15_r0_body.cfoot130 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_130 PRE_first_tail_x15_r0_body.okr1_130 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn130) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0130 PRE_first_tail_x15_r0_body.fkt0130 PRE_first_tail_x15_r0_body.fkf1130 PRE_first_tail_x15_r0_body.fkt1130 PRE_first_tail_x15_r0_body.fkck130,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0130 PRE_first_tail_x15_r0_body.cnh1130 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe130) PRE_first_tail_x15_r0_body.cpendR130⟩

end Host.Load.Run.Tpl
end

section -- st130/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st130 0
host_stream_state PRE_first_tail_x15_r0_body.st130 1
host_stream_state PRE_first_tail_x15_r0_body.st130 2
end Host.Load.Run.Tpl
end

section -- Site130
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 130 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g130__g131` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1260`, the merged state `PRE_first_tail_x15_r0_body.s1261`,
the site template `PRE_first_tail_x15_r0_body.st130` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1262`: the merge.
The footprint's facts are in `SiteF130`, the compaction's in `SiteC130`, `SiteK130`, `SiteNa130`, `SiteNb130`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso130 : PRE_first_tail_x15_r0_body.st130.s0 = { PRE_first_tail_x15_r0_body.s1260 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs130 : List Frame := PRE_first_tail_x15_r0_body.s1260.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_130 : PRE_first_tail_x15_r0_body.S1260.tab.length = 5636
kernel_rfl PRE_first_tail_x15_r0_body.tab0_130 : PRE_first_tail_x15_r0_body.st130.S0.tab = PRE_first_tail_x15_r0_body.S1260.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws130 : List Nat := [3184, 3185]
kernel_rfl PRE_first_tail_x15_r0_body.fresh130 : (PRE_first_tail_x15_r0_body.S1260.tab.all fun e => PRE_first_tail_x15_r0_body.ws130.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1260.oracle.all fun q => PRE_first_tail_x15_r0_body.ws130.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab130 : PRE_first_tail_x15_r0_body.S1261.tab = PRE_first_tail_x15_r0_body.S1260.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws130
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen130 : PRE_first_tail_x15_r0_body.st130.S2.tab.length - PRE_first_tail_x15_r0_body.st130.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged130`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap130 : PRE_first_tail_x15_r0_body.s1261.heap = PRE_first_tail_x15_r0_body.st130.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext130 : PRE_first_tail_x15_r0_body.s1261.next = PRE_first_tail_x15_r0_body.st130.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl130 : PRE_first_tail_x15_r0_body.s1261.ctl = PRE_first_tail_x15_r0_body.st130.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack130 : PRE_first_tail_x15_r0_body.s1261.stack = PRE_first_tail_x15_r0_body.st130.s2.stack ++ PRE_first_tail_x15_r0_body.s1260.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs130 : PRE_first_tail_x15_r0_body.s1261.jobs = PRE_first_tail_x15_r0_body.st130.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi130 : PRE_first_tail_x15_r0_body.s1261.ffi = PRE_first_tail_x15_r0_body.st130.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace130 : PRE_first_tail_x15_r0_body.s1261.trace = PRE_first_tail_x15_r0_body.st130.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores130 : PRE_first_tail_x15_r0_body.s1261.stores = PRE_first_tail_x15_r0_body.st130.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD130
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 130 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived130 : PRE_first_tail_x15_r0_body.nr130.map (fun r => nth? PRE_first_tail_x15_r0_body.st130.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo130 : PRE_first_tail_x15_r0_body.nr130.all (Nat.ble 5636) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj130 : PRE_first_tail_x15_r0_body.cws130.all (fun c => !PRE_first_tail_x15_r0_body.ws130.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ130 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws130 PRE_first_tail_x15_r0_body.crs130 PRE_first_tail_x15_r0_body.ws130

end Host.Load.Run.Tpl
end

section -- st130/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st130`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st130.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st130.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st130.s2.heap PRE_first_tail_x15_r0_body.st130.wrR ++ freshOf PRE_first_tail_x15_r0_body.st130.s2.heap PRE_first_tail_x15_r0_body.st130.s0.next PRE_first_tail_x15_r0_body.st130.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st130.wr : List Nat := PRE_first_tail_x15_r0_body.st130.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st130.heapFoot : PRE_first_tail_x15_r0_body.st130.s2.heap = setAll PRE_first_tail_x15_r0_body.st130.s0.heap PRE_first_tail_x15_r0_body.st130.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st130.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st130.s0.next PRE_first_tail_x15_r0_body.st130.s2.next = true
theorem PRE_first_tail_x15_r0_body.st130.grows : PRE_first_tail_x15_r0_body.st130.s0.next ≤ PRE_first_tail_x15_r0_body.st130.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st130.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st130.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st130.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st130.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st130.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st130.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st130.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st130.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st130.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st130.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st130.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st130.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st130.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st130.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st130.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st130.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st130.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st130.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st130.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st130.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st130.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st130.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st130.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st130.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st130.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st130.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st130.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st130.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st130.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st130.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st130.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st130.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF130
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 130 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB130 : nodupT PRE_first_tail_x15_r0_body.st130.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup130 : PRE_first_tail_x15_r0_body.st130.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB130).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB130 : PRE_first_tail_x15_r0_body.st130.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound130 : ∀ b ∈ PRE_first_tail_x15_r0_body.st130.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB130 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr130 := PRE_first_tail_x15_r0_body.st130.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq130 : PRE_first_tail_x15_r0_body.st130.s2.trace = PRE_first_tail_x15_r0_body.trFr130 ++ PRE_first_tail_x15_r0_body.st130.s0.trace
theorem PRE_first_tail_x15_r0_body.trace130 : ∃ fr, PRE_first_tail_x15_r0_body.st130.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st130.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq130⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide130 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB130 : (PRE_first_tail_x15_r0_body.wide130.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st130.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix130 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide130, WFix Map.id (Present PRE_first_tail_x15_r0_body.st130.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB130 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL130
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 130 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1261`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO130 : PRE_first_tail_x15_r0_body.st130.S0.oracle = PRE_first_tail_x15_r0_body.st130.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B130 : PRE_first_tail_x15_r0_body.st130.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st130.s0.next || (PRE_first_tail_x15_r0_body.st130.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot130 : Conv.StageFoot PRE_first_tail_x15_r0_body.st130.wr PRE_first_tail_x15_r0_body.st130.s0 PRE_first_tail_x15_r0_body.st130.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st130.heapFoot PRE_first_tail_x15_r0_body.wrNodup130 PRE_first_tail_x15_r0_body.wrBound130 PRE_first_tail_x15_r0_body.wr0B130 PRE_first_tail_x15_r0_body.st130.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged130 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st130.F.S → PRE_first_tail_x15_r0_body.st130.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st130.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st130.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs130 PRE_first_tail_x15_r0_body.st130.wr PRE_first_tail_x15_r0_body.s1260 PRE_first_tail_x15_r0_body.st130.s2 PRE_first_tail_x15_r0_body.st130.s0
      PRE_first_tail_x15_r0_body.st130.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st130.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1261 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso130 PRE_first_tail_x15_r0_body.stFoot130 PRE_first_tail_x15_r0_body.wrNodup130 PRE_first_tail_x15_r0_body.wrBound130 PRE_first_tail_x15_r0_body.trace130 PRE_first_tail_x15_r0_body.mheap130
    PRE_first_tail_x15_r0_body.mnext130 PRE_first_tail_x15_r0_body.mctl130 PRE_first_tail_x15_r0_body.mstack130 PRE_first_tail_x15_r0_body.mjobs130 PRE_first_tail_x15_r0_body.mffi130 PRE_first_tail_x15_r0_body.mtrace130 PRE_first_tail_x15_r0_body.mstores130 h

def PRE_first_tail_x15_r0_body.arrEl130_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE130_2665 : arrOf PRE_first_tail_x15_r0_body.s1261 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl130_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA130_2665 : isArrB PRE_first_tail_x15_r0_body.s1261 2665 = true
theorem PRE_first_tail_x15_r0_body.arr130_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1261.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl130_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE130_2665 PRE_first_tail_x15_r0_body.arrA130_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN130_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl130_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR130_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl130_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN130_2665

def PRE_first_tail_x15_r0_body.arrEl130_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE130_2673467 : arrOf PRE_first_tail_x15_r0_body.s1261 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl130_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA130_2673467 : isArrB PRE_first_tail_x15_r0_body.s1261 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr130_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1261.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl130_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE130_2673467 PRE_first_tail_x15_r0_body.arrA130_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN130_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl130_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR130_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl130_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN130_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k130 : isArrB PRE_first_tail_x15_r0_body.s1261 4910 = false
theorem PRE_first_tail_x15_r0_body.keep130 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1261 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k130 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr130_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl130_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ130
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 130 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1260`, the merged
state `PRE_first_tail_x15_r0_body.s1261`, the canonical state `PRE_first_tail_x15_r0_body.s1262`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl130 : PRE_first_tail_x15_r0_body.pl130.all (Nat.ble PRE_first_tail_x15_r0_body.s1260.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd130 : nodupT PRE_first_tail_x15_r0_body.pl130 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1130 : Nat.ble PRE_first_tail_x15_r0_body.s1260.next 2777255 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst130 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1260.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn130 : PRE_first_tail_x15_r0_body.s1262.next = PRE_first_tail_x15_r0_body.s1260.next + PRE_first_tail_x15_r0_body.pl130.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn130 : PRE_first_tail_x15_r0_body.s1261.next = 2777255
kernel_rfl PRE_first_tail_x15_r0_body.zgrow130 : Nat.ble PRE_first_tail_x15_r0_body.s1262.next PRE_first_tail_x15_r0_body.s1261.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh130 : PRE_first_tail_x15_r0_body.S1260.tab.all (fun e => PRE_first_tail_x15_r0_body.cws130.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd130 : nodupT PRE_first_tail_x15_r0_body.cws130 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi130 : PRE_first_tail_x15_r0_body.nr130.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1261.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt130 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1260.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg130_2665 : PRE_first_tail_x15_r0_body.s1262.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1262 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk130_2665 : (objOf PRE_first_tail_x15_r0_body.s1262 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm130_2665 : PRE_first_tail_x15_r0_body.s1261.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa130.obj (objOf PRE_first_tail_x15_r0_body.s1262 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1261 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg130_2673467 : PRE_first_tail_x15_r0_body.s1262.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1262 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk130_2673467 : (objOf PRE_first_tail_x15_r0_body.s1262 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm130_2673467 : PRE_first_tail_x15_r0_body.s1261.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa130.obj (objOf PRE_first_tail_x15_r0_body.s1262 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1261 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw130_4910 : (PRE_first_tail_x15_r0_body.s1262.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw130_2673472 : (PRE_first_tail_x15_r0_body.s1262.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw130_2673473 : (PRE_first_tail_x15_r0_body.s1262.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd130 : PRE_first_tail_x15_r0_body.cl130.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr130 : PRE_first_tail_x15_r0_body.st130.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1260.next || PRE_first_tail_x15_r0_body.cl130.contains b) = true
def PRE_first_tail_x15_r0_body.zl130 : List Nat := PRE_first_tail_x15_r0_body.cl130.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE130 : PRE_first_tail_x15_r0_body.zl130.map (fun a => PRE_first_tail_x15_r0_body.s1261.heap.get (PRE_first_tail_x15_r0_body.kappa130.a a)) = PRE_first_tail_x15_r0_body.zl130.map (fun a => (PRE_first_tail_x15_r0_body.s1262.heap.get a).map PRE_first_tail_x15_r0_body.kappa130.hobj)
theorem PRE_first_tail_x15_r0_body.zimg130 : HeapImg PRE_first_tail_x15_r0_body.kappa130 PRE_first_tail_x15_r0_body.s1262 PRE_first_tail_x15_r0_body.s1261 PRE_first_tail_x15_r0_body.zl130 := PRE_first_tail_x15_r0_body.zimgE130
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl130 : PRE_first_tail_x15_r0_body.s1261.ctl = PRE_first_tail_x15_r0_body.kappa130.ctl PRE_first_tail_x15_r0_body.s1262.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack130 : PRE_first_tail_x15_r0_body.s1261.stack = PRE_first_tail_x15_r0_body.s1262.stack.map PRE_first_tail_x15_r0_body.kappa130.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs130 : PRE_first_tail_x15_r0_body.s1261.jobs = PRE_first_tail_x15_r0_body.s1262.jobs.map PRE_first_tail_x15_r0_body.kappa130.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores130 : PRE_first_tail_x15_r0_body.s1261.stores = PRE_first_tail_x15_r0_body.kappa130.stores PRE_first_tail_x15_r0_body.s1262.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots130 : checkRootsSupp PRE_first_tail_x15_r0_body.s1262 5636 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC130 : PRE_first_tail_x15_r0_body.S1260.tab.length + PRE_first_tail_x15_r0_body.cws130.length = 5636
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap130 : PRE_first_tail_x15_r0_body.kappa130 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1260.next 2777255 PRE_first_tail_x15_r0_body.S1260.tab.length PRE_first_tail_x15_r0_body.pl130 (PRE_first_tail_x15_r0_body.nr130.map NumV.ref) PRE_first_tail_x15_r0_body.kd130.big
  PRE_first_tail_x15_r0_body.kd130.region PRE_first_tail_x15_r0_body.kd130.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin130 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1262.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc130 : Conv.jcleanListB (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1262 PRE_first_tail_x15_r0_body.cl130 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB130 : noBigRootsP (fun i => !Conv.oldBigB (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1262.trace PRE_first_tail_x15_r0_body.s1262 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm130 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17862 = true
theorem PRE_first_tail_x15_r0_body.cjcl130 (h : Conv.JClean (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1260) : Conv.JClean (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1262 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle130)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap130 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd130 a ha)) PRE_first_tail_x15_r0_body.zjc130

end Host.Load.Run.Tpl
end

section -- st130/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st130.bodyLast from PRE_first_tail_x15_r0_body.st130.s1 to PRE_first_tail_x15_r0_body.st130.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st130.F PRE_first_tail_x15_r0_body.st130.s1).run PRE_first_tail_x15_r0_body.st130.S1 = some (PRE_first_tail_x15_r0_body.st130.s2, PRE_first_tail_x15_r0_body.st130.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st130.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st130.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st130.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st130.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st130/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st130.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st130.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st130.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st130.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st130.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st130.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st130.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st130.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st130.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st130.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st130.s0 PRE_first_tail_x15_r0_body.st130.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st130.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st130.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st130.s1 PRE_first_tail_x15_r0_body.st130.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st130/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st130.bodyK0F from PRE_first_tail_x15_r0_body.st130.s0 to PRE_first_tail_x15_r0_body.st130.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st130.F (PRE_first_tail_x15_r0_body.st130.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st130.ks 0).getD 0) PRE_first_tail_x15_r0_body.st130.s0 PRE_first_tail_x15_r0_body.st130.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st130.s1, PRE_first_tail_x15_r0_body.st130.S1)
theorem PRE_first_tail_x15_r0_body.st130.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st130.F (PRE_first_tail_x15_r0_body.st130.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st130.ks 0).getD 0) PRE_first_tail_x15_r0_body.st130.s0 PRE_first_tail_x15_r0_body.st130.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st130.s1, PRE_first_tail_x15_r0_body.st130.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st130.bodyOkLN_ok PRE_first_tail_x15_r0_body.st130.bodyK0F
end Host.Load.Run.Tpl
end

section -- st130/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st130.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st130.F (PRE_first_tail_x15_r0_body.st130.bodyOkL bytes rows) 27 PRE_first_tail_x15_r0_body.st130.s0 PRE_first_tail_x15_r0_body.st130.S0 = some (PRE_first_tail_x15_r0_body.st130.s1, PRE_first_tail_x15_r0_body.st130.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st130.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st130.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st130.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st130.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st130.F (PRE_first_tail_x15_r0_body.st130.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st130.s0
  S0 := PRE_first_tail_x15_r0_body.st130.S0
  s1 := PRE_first_tail_x15_r0_body.st130.s1
  S1 := PRE_first_tail_x15_r0_body.st130.S1
  s2 := PRE_first_tail_x15_r0_body.st130.s2
  S2 := PRE_first_tail_x15_r0_body.st130.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st130.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st130.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st130.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st130.bodyHalt
  last := PRE_first_tail_x15_r0_body.st130.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st130.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC131
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 131 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1266` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa131` into the merged state
`PRE_first_tail_x15_r0_body.s1265`. -/

def PRE_first_tail_x15_r0_body.pl131 : List Nat := [2777551]
def PRE_first_tail_x15_r0_body.nr131 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd131 : RData :=
  ⟨2777542, 2777552, Stage.setAll PTrie.nil [(2777541, 2777551)], Stage.setAll PTrie.nil [],
   20777, 20777, 17866, 17866, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa131 : Map :=
  Conv.Map.compact 2777541 2777552 5653 PRE_first_tail_x15_r0_body.pl131 (PRE_first_tail_x15_r0_body.nr131.map NumV.ref) PRE_first_tail_x15_r0_body.kd131.big
    PRE_first_tail_x15_r0_body.kd131.region PRE_first_tail_x15_r0_body.kd131.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws131 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs131 : List SymE := PRE_first_tail_x15_r0_body.nr131.map fun r => (nth? PRE_first_tail_x15_r0_body.S1265.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta131 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws131 PRE_first_tail_x15_r0_body.crs131
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB131 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab131 : PRE_first_tail_x15_r0_body.S1266.tab = PRE_first_tail_x15_r0_body.S1264.tab ++ PRE_first_tail_x15_r0_body.cws131.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace131 : PRE_first_tail_x15_r0_body.s1266.trace = PRE_first_tail_x15_r0_body.s1264.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext131 : PRE_first_tail_x15_r0_body.s1266.next = 2777542
kernel_rfl PRE_first_tail_x15_r0_body.ccounters131 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1266.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1266.ffi).mlx.nnext) = (20777, 17866)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue131 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1265.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1266.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa131.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp131 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1266.ffi).mlx.tokens.all (bSN 5653) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean131 : Conv.cleanListB 20777 131072 (fun r => Nat.ble 83108 r) PRE_first_tail_x15_r0_body.s1266
    (PRE_first_tail_x15_r0_body.wrB131 ++ (List.range 1).map (2777541 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs131 : bigsOutB 20777 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1266.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK131
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl131`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl131 : List Nat := [2665, 2673467, 2777541]
def PRE_first_tail_x15_r0_body.clo131 : List Nat := []
def PRE_first_tail_x15_r0_body.cln131 : List Nat := []
def PRE_first_tail_x15_r0_body.cli131 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap131 : PRE_first_tail_x15_r0_body.s1266.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1264.heap (PRE_first_tail_x15_r0_body.cl131.filterMap fun a => (PRE_first_tail_x15_r0_body.s1266.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe131 : Nat.ble PRE_first_tail_x15_r0_body.s1264.next PRE_first_tail_x15_r0_body.s1266.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP131 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1264 PRE_first_tail_x15_r0_body.s1266 PRE_first_tail_x15_r0_body.cl131 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp131 : Conv.suppListB PRE_first_tail_x15_r0_body.s1266 5653 PRE_first_tail_x15_r0_body.cl131 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound131 : Conv.boundListB PRE_first_tail_x15_r0_body.s1266 PRE_first_tail_x15_r0_body.cl131 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK131 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1266.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln131.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1266.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK131 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1266.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo131.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1266.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK131 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1266.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli131.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1266.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst131 : Conv.sstListB 5653 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1266.ffi).mlx PRE_first_tail_x15_r0_body.cln131 PRE_first_tail_x15_r0_body.clo131 PRE_first_tail_x15_r0_body.cli131 = true

end Host.Load.Run.Tpl
end

section -- SiteCl131
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA131 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1266.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo131.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1266.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd131 : (PRE_first_tail_x15_r0_body.clo131 ++ PRE_first_tail_x15_r0_body.cln131 ++ PRE_first_tail_x15_r0_body.cli131).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle131 : Conv.Cnt.leB (⟨20777, 17866, 2777541, 5653⟩ : Conv.Cnt) (⟨20777, 17866, 2777542, 5653⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck131 : Conv.ncleanListB (⟨20777, 17866, 2777542, 5653⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1266.ffi).mlx PRE_first_tail_x15_r0_body.clo131 PRE_first_tail_x15_r0_body.cln131 PRE_first_tail_x15_r0_body.cli131 = true
theorem PRE_first_tail_x15_r0_body.cncl131 (h : Conv.NClean (⟨20777, 17866, 2777541, 5653⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx) : Conv.NClean (⟨20777, 17866, 2777542, 5653⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1266.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle131 PRE_first_tail_x15_r0_body.ckA131 PRE_first_tail_x15_r0_body.cobjsK131 PRE_first_tail_x15_r0_body.cnodesK131 PRE_first_tail_x15_r0_body.citemsK131 PRE_first_tail_x15_r0_body.cbd131 PRE_first_tail_x15_r0_body.cck131

end Host.Load.Run.Tpl
end

section -- SiteS131
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 131 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc131 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P131 : LoadP := PRE_first_tail_x15_r0_body.Pc131.raise 17866
kernel_rfl PRE_first_tail_x15_r0_body.craise131 : Nat.ble PRE_first_tail_x15_r0_body.Pc131.N0 17866 = true
theorem PRE_first_tail_x15_r0_body.raised131 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc131 PRE_first_tail_x15_r0_body.P131 :=
  .inr ⟨17866, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise131, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_131 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1266.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_131 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1265.ffi)
def PRE_first_tail_x15_r0_body.khinv131 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv131 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS131 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS131 : List Nat := List.range' 17866 0
def PRE_first_tail_x15_r0_body.ciS131 : List Nat := [] ++ List.range' 17866 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0131 : PRE_first_tail_x15_r0_body.kd131.nh0 = PRE_first_tail_x15_r0_body.cx0_131.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1131 : PRE_first_tail_x15_r0_body.kd131.nh1 = PRE_first_tail_x15_r0_body.cx1_131.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0131 : PRE_first_tail_x15_r0_body.kd131.nn0 = PRE_first_tail_x15_r0_body.cx0_131.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1131 : PRE_first_tail_x15_r0_body.kd131.nn1 = PRE_first_tail_x15_r0_body.cx1_131.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo131 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P131.lo && Nat.ble PRE_first_tail_x15_r0_body.P131.lo PRE_first_tail_x15_r0_body.cx0_131.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P131.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P131.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt131 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_131.mlx.next PRE_first_tail_x15_r0_body.cx1_131.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_131.mlx.nnext PRE_first_tail_x15_r0_body.cx1_131.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband131 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P131.NL && Nat.ble PRE_first_tail_x15_r0_body.P131.NL PRE_first_tail_x15_r0_body.P131.N0 && Nat.ble PRE_first_tail_x15_r0_body.P131.N0 PRE_first_tail_x15_r0_body.cx0_131.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow131 : PRE_first_tail_x15_r0_body.kd131.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren131 : checkRenG PRE_first_tail_x15_r0_body.kd131.hnd PRE_first_tail_x15_r0_body.khinv131 (phB PRE_first_tail_x15_r0_body.cx0_131.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband131 : PRE_first_tail_x15_r0_body.kd131.checkBand PRE_first_tail_x15_r0_body.P131.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos131 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd131.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren131 : checkRenG PRE_first_tail_x15_r0_body.kd131.node PRE_first_tail_x15_r0_body.kninv131 (pnB PRE_first_tail_x15_r0_body.cx0_131.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow131 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd131.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P131.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd131.nodeF j) PRE_first_tail_x15_r0_body.cx1_131.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a131 : PRE_first_tail_x15_r0_body.cx0_131.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b131 : PRE_first_tail_x15_r0_body.cx0_131.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1131 : PRE_first_tail_x15_r0_body.cx1_131.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend131 : PRE_first_tail_x15_r0_body.cx1_131.mlx.pending = PRE_first_tail_x15_r0_body.cx0_131.mlx.pending.map PRE_first_tail_x15_r0_body.kappa131.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh131 : PRE_first_tail_x15_r0_body.cx1_131.mlx.errh = PRE_first_tail_x15_r0_body.cx0_131.mlx.errh.map PRE_first_tail_x15_r0_body.kappa131.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles131 : PRE_first_tail_x15_r0_body.cx1_131.mlx.files = PRE_first_tail_x15_r0_body.cx0_131.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch131 : PRE_first_tail_x15_r0_body.cx1_131.mlx.arch = PRE_first_tail_x15_r0_body.cx0_131.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes131 : PRE_first_tail_x15_r0_body.cx1_131.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_131.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired131 : PRE_first_tail_x15_r0_body.cx1_131.mlx.wired = PRE_first_tail_x15_r0_body.cx0_131.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost131 : PRE_first_tail_x15_r0_body.cx1_131.host = PRE_first_tail_x15_r0_body.cx0_131.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd131`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0131 : PRE_first_tail_x15_r0_body.kd131.n0 = 2777542
kernel_rfl PRE_first_tail_x15_r0_body.ckn1131 : PRE_first_tail_x15_r0_body.kd131.n1 = 2777552
kernel_rfl PRE_first_tail_x15_r0_body.ckheap131 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd131.heap).all (fun x => Nat.ble 2777541 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl131 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd131.heap.get (2777541 + j) = nth? PRE_first_tail_x15_r0_body.pl131 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja131 : Nat.ble 2777541 2777541 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn131 : Nat.ble 5653 5653 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD131 : Nat.ble 2777541 PRE_first_tail_x15_r0_body.kd131.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn131 : Nat.ble 20777 PRE_first_tail_x15_r0_body.kd131.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn131 : Nat.ble 17866 PRE_first_tail_x15_r0_body.kd131.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb131 : Nat.ble 20777 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap131 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd131.heap).all (Nat.ble (⟨20777, 17866, 2777541, 5653⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd131 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd131.hnd).all (Nat.ble (⟨20777, 17866, 2777541, 5653⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode131 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd131.node).all (Nat.ble (⟨20777, 17866, 2777541, 5653⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix131 : Conv.FixOld (⟨20777, 17866, 2777541, 5653⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa131 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja131) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn131) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD131) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn131) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn131) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb131) PRE_first_tail_x15_r0_body.fheap131 PRE_first_tail_x15_r0_body.fhnd131 PRE_first_tail_x15_r0_body.fnode131
kernel_rfl PRE_first_tail_x15_r0_body.fcxn131 : (⟨20777, 17866, 2777541, 5653⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn131 : (⟨20777, 17866, 2777541, 5653⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0131 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_131.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_131.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk131 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd131.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A131 : PRE_first_tail_x15_r0_body.cx1_131.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS131.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_131.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O131 : PRE_first_tail_x15_r0_body.cx1_131.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS131.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_131.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N131 : PRE_first_tail_x15_r0_body.cx1_131.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS131.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_131.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I131 : PRE_first_tail_x15_r0_body.cx1_131.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS131.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_131.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd131 : (PRE_first_tail_x15_r0_body.clo131 ++ PRE_first_tail_x15_r0_body.cln131 ++ PRE_first_tail_x15_r0_body.cli131 ++ PRE_first_tail_x15_r0_body.cwS131 ++ PRE_first_tail_x15_r0_body.cnS131 ++ PRE_first_tail_x15_r0_body.ciS131).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW131 : PRE_first_tail_x15_r0_body.cwS131.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo131.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI131 : PRE_first_tail_x15_r0_body.ciS131.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli131.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN131 : PRE_first_tail_x15_r0_body.cnS131.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF131 : PRE_first_tail_x15_r0_body.cln131.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh131 : PRE_first_tail_x15_r0_body.clo131.all (handleOK PRE_first_tail_x15_r0_body.kappa131 PRE_first_tail_x15_r0_body.P131.lo PRE_first_tail_x15_r0_body.cx0_131.mlx PRE_first_tail_x15_r0_body.cx1_131.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo131 : PRE_first_tail_x15_r0_body.clo131.map (fun h => PRE_first_tail_x15_r0_body.cx1_131.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa131.handle h)) = PRE_first_tail_x15_r0_body.clo131.map (fun h => (PRE_first_tail_x15_r0_body.cx0_131.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa131.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok131 : PRE_first_tail_x15_r0_body.clo131.all (objOK PRE_first_tail_x15_r0_body.kappa131 PRE_first_tail_x15_r0_body.P131.NL PRE_first_tail_x15_r0_body.cx0_131.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd131 : PRE_first_tail_x15_r0_body.cln131.all (nodeOKF PRE_first_tail_x15_r0_body.kappa131 PRE_first_tail_x15_r0_body.P131 PRE_first_tail_x15_r0_body.cx0_131.mlx PRE_first_tail_x15_r0_body.cx1_131.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp131 : ((PRE_first_tail_x15_r0_body.cln131.filter (fullB PRE_first_tail_x15_r0_body.P131))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_131.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa131.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln131.filter (fullB PRE_first_tail_x15_r0_body.P131))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_131.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa131.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI131 : incrB PRE_first_tail_x15_r0_body.kd131.nodeF (List.range' 17866 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK131 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd131.node).all (fun k => Nat.ble 17866 k && Nat.blt k 17866) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL131 : (PRE_first_tail_x15_r0_body.cln131.filter (Nat.ble PRE_first_tail_x15_r0_body.P131.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd131.nodeF i) && (Nat.blt i 17866 || Nat.ble PRE_first_tail_x15_r0_body.kd131.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord131 : (PRE_first_tail_x15_r0_body.cln131.filter (Nat.ble PRE_first_tail_x15_r0_body.P131.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd131.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd131.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd131.nodeF j) (PRE_first_tail_x15_r0_body.kd131.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow131 PRE_first_tail_x15_r0_body.cnn1131 PRE_first_tail_x15_r0_body.fnordI131 PRE_first_tail_x15_r0_body.fnordK131 PRE_first_tail_x15_r0_body.fnordL131
kernel_rfl PRE_first_tail_x15_r0_body.fi131 : PRE_first_tail_x15_r0_body.cli131.all (pnB PRE_first_tail_x15_r0_body.cx0_131.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii131 : PRE_first_tail_x15_r0_body.cli131.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_131.mlx.items.get (PRE_first_tail_x15_r0_body.kappa131.node k) = (PRE_first_tail_x15_r0_body.cx0_131.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa131.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot131 (clean : Conv.NClean (⟨20777, 17866, 2777541, 5653⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P131.NL) (cl : SSt (· < 5653) PRE_first_tail_x15_r0_body.cx0_131.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P131 5653 PRE_first_tail_x15_r0_body.kappa131 PRE_first_tail_x15_r0_body.kd131 PRE_first_tail_x15_r0_body.khinv131 PRE_first_tail_x15_r0_body.kninv131 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx PRE_first_tail_x15_r0_body.cx0_131.mlx PRE_first_tail_x15_r0_body.cx1_131.mlx (⟨20777, 17866, 2777541, 5653⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo131 PRE_first_tail_x15_r0_body.cln131 PRE_first_tail_x15_r0_body.cli131 PRE_first_tail_x15_r0_body.cwS131 PRE_first_tail_x15_r0_body.cnS131 PRE_first_tail_x15_r0_body.ciS131 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0131, PRE_first_tail_x15_r0_body.cnh1131, PRE_first_tail_x15_r0_body.cnn0131, PRE_first_tail_x15_r0_body.cnn1131, PRE_first_tail_x15_r0_body.cplo131, PRE_first_tail_x15_r0_body.ccnt131, PRE_first_tail_x15_r0_body.cnband131, PRE_first_tail_x15_r0_body.chbelow131, PRE_first_tail_x15_r0_body.chren131, PRE_first_tail_x15_r0_body.cband131, PRE_first_tail_x15_r0_body.cnh1pos131, PRE_first_tail_x15_r0_body.cnren131, PRE_first_tail_x15_r0_body.cnlow131, PRE_first_tail_x15_r0_body.cabs0a131, PRE_first_tail_x15_r0_body.cabs0b131, PRE_first_tail_x15_r0_body.ctok1131, PRE_first_tail_x15_r0_body.cpend131, PRE_first_tail_x15_r0_body.cerrh131, PRE_first_tail_x15_r0_body.cfiles131, PRE_first_tail_x15_r0_body.carch131, PRE_first_tail_x15_r0_body.csizes131, PRE_first_tail_x15_r0_body.cwired131, PRE_first_tail_x15_r0_body.cfix131, clean, PRE_first_tail_x15_r0_body.fcxn131, PRE_first_tail_x15_r0_body.fcnn131, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0131, PRE_first_tail_x15_r0_body.fnk131, PRE_first_tail_x15_r0_body.ckA131, PRE_first_tail_x15_r0_body.cobjsK131, PRE_first_tail_x15_r0_body.cnodesK131, PRE_first_tail_x15_r0_body.citemsK131, PRE_first_tail_x15_r0_body.f1A131, PRE_first_tail_x15_r0_body.f1O131, PRE_first_tail_x15_r0_body.f1N131, PRE_first_tail_x15_r0_body.f1I131, PRE_first_tail_x15_r0_body.fbd131, PRE_first_tail_x15_r0_body.fincW131, PRE_first_tail_x15_r0_body.fincI131, PRE_first_tail_x15_r0_body.fincN131, PRE_first_tail_x15_r0_body.flnF131, PRE_first_tail_x15_r0_body.fh131, PRE_first_tail_x15_r0_body.fo131, PRE_first_tail_x15_r0_body.fok131, PRE_first_tail_x15_r0_body.fnd131, PRE_first_tail_x15_r0_body.fp131, PRE_first_tail_x15_r0_body.fnord131, PRE_first_tail_x15_r0_body.fi131, PRE_first_tail_x15_r0_body.fii131⟩
theorem PRE_first_tail_x15_r0_body.cnshift131 (clean : Conv.NClean (⟨20777, 17866, 2777541, 5653⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P131.NL) (cl : SSt (· < 5653) PRE_first_tail_x15_r0_body.cx0_131.mlx) : NShift PRE_first_tail_x15_r0_body.P131 5653 PRE_first_tail_x15_r0_body.kappa131 PRE_first_tail_x15_r0_body.cx0_131 PRE_first_tail_x15_r0_body.cx1_131 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot131 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost131 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0131 PRE_first_tail_x15_r0_body.ckn1131 PRE_first_tail_x15_r0_body.ckheap131 PRE_first_tail_x15_r0_body.ckpl131)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_131 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1264.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_131 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1264.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_131 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1264.ffi) = some PRE_first_tail_x15_r0_body.fxC_131
kernel_rfl PRE_first_tail_x15_r0_body.okrC_131 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1264.ffi) = some PRE_first_tail_x15_r0_body.krC_131
noncomputable def PRE_first_tail_x15_r0_body.fx0_131 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1266.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_131 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1266.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_131 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1266.ffi) = some PRE_first_tail_x15_r0_body.fx0_131
kernel_rfl PRE_first_tail_x15_r0_body.okr0_131 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1266.ffi) = some PRE_first_tail_x15_r0_body.kr0_131
noncomputable def PRE_first_tail_x15_r0_body.fx1_131 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1265.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_131 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1265.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_131 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1265.ffi) = some PRE_first_tail_x15_r0_body.fx1_131
kernel_rfl PRE_first_tail_x15_r0_body.okr1_131 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1265.ffi) = some PRE_first_tail_x15_r0_body.kr1_131
kernel_rfl PRE_first_tail_x15_r0_body.ff0131 : PRE_first_tail_x15_r0_body.fx0_131 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_131 (PRE_first_tail_x15_r0_body.clo131.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_131.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1131 : PRE_first_tail_x15_r0_body.fx1_131 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_131 (PRE_first_tail_x15_r0_body.cwS131.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_131.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck131 : freedLB PRE_first_tail_x15_r0_body.kappa131 PRE_first_tail_x15_r0_body.cx0_131.mlx PRE_first_tail_x15_r0_body.fx0_131 PRE_first_tail_x15_r0_body.fx1_131 PRE_first_tail_x15_r0_body.clo131 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0131 : PRE_first_tail_x15_r0_body.kr0_131.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_131.flags (PRE_first_tail_x15_r0_body.clo131.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_131.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0131 : PRE_first_tail_x15_r0_body.kr0_131.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_131.targs (PRE_first_tail_x15_r0_body.clo131.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_131.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1131 : PRE_first_tail_x15_r0_body.kr1_131.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_131.flags (PRE_first_tail_x15_r0_body.cwS131.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_131.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1131 : PRE_first_tail_x15_r0_body.kr1_131.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_131.targs (PRE_first_tail_x15_r0_body.cwS131.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_131.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck131 : krecLB PRE_first_tail_x15_r0_body.kappa131 5653 PRE_first_tail_x15_r0_body.cx0_131.mlx PRE_first_tail_x15_r0_body.kr0_131 PRE_first_tail_x15_r0_body.kr1_131 PRE_first_tail_x15_r0_body.clo131 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn131 : Nat.ble 5653 5653 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge131 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1265.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1266.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR131 : pendRegB PRE_first_tail_x15_r0_body.kappa131 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1266.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe131 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1266.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1265.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift131 (clean : Conv.NClean (⟨20777, 17866, 2777541, 5653⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P131.NL) (cl : SSt (· < 5653) PRE_first_tail_x15_r0_body.cx0_131.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_131.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_131.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_131.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_131.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20777, 17866, 2777541, 5653⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P131 5653 PRE_first_tail_x15_r0_body.kappa131 PRE_first_tail_x15_r0_body.s1266.ffi PRE_first_tail_x15_r0_body.s1265.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift131 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue131, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp131 t ht),
    PRE_first_tail_x15_r0_body.cbridge131,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1266.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1265.ffi) (PRE_first_tail_x15_r0_body.cfoot131 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_131 PRE_first_tail_x15_r0_body.ofx1_131 hobjC PRE_first_tail_x15_r0_body.ff0131 PRE_first_tail_x15_r0_body.ff1131 PRE_first_tail_x15_r0_body.ffck131,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1266.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1265.ffi) (PRE_first_tail_x15_r0_body.cfoot131 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_131 PRE_first_tail_x15_r0_body.okr1_131 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn131) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0131 PRE_first_tail_x15_r0_body.fkt0131 PRE_first_tail_x15_r0_body.fkf1131 PRE_first_tail_x15_r0_body.fkt1131 PRE_first_tail_x15_r0_body.fkck131,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0131 PRE_first_tail_x15_r0_body.cnh1131 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe131) PRE_first_tail_x15_r0_body.cpendR131⟩

end Host.Load.Run.Tpl
end

section -- st131/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st131 0
host_stream_state PRE_first_tail_x15_r0_body.st131 1
host_stream_state PRE_first_tail_x15_r0_body.st131 2
end Host.Load.Run.Tpl
end

section -- Site131
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 131 of chain `PRE_first_tail_x15_r0_body`: `plan__g131__g132` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1264`, the merged state `PRE_first_tail_x15_r0_body.s1265`,
the site template `PRE_first_tail_x15_r0_body.st131` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1266`: the merge.
The footprint's facts are in `SiteF131`, the compaction's in `SiteC131`, `SiteK131`, `SiteNa131`, `SiteNb131`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso131 : PRE_first_tail_x15_r0_body.st131.s0 = { PRE_first_tail_x15_r0_body.s1264 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs131 : List Frame := PRE_first_tail_x15_r0_body.s1264.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_131 : PRE_first_tail_x15_r0_body.S1264.tab.length = 5653
kernel_rfl PRE_first_tail_x15_r0_body.tab0_131 : PRE_first_tail_x15_r0_body.st131.S0.tab = PRE_first_tail_x15_r0_body.S1264.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws131 : List Nat := [3186, 3187, 3188]
kernel_rfl PRE_first_tail_x15_r0_body.fresh131 : (PRE_first_tail_x15_r0_body.S1264.tab.all fun e => PRE_first_tail_x15_r0_body.ws131.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1264.oracle.all fun q => PRE_first_tail_x15_r0_body.ws131.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab131 : PRE_first_tail_x15_r0_body.S1265.tab = PRE_first_tail_x15_r0_body.S1264.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws131
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen131 : PRE_first_tail_x15_r0_body.st131.S2.tab.length - PRE_first_tail_x15_r0_body.st131.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged131`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap131 : PRE_first_tail_x15_r0_body.s1265.heap = PRE_first_tail_x15_r0_body.st131.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext131 : PRE_first_tail_x15_r0_body.s1265.next = PRE_first_tail_x15_r0_body.st131.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl131 : PRE_first_tail_x15_r0_body.s1265.ctl = PRE_first_tail_x15_r0_body.st131.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack131 : PRE_first_tail_x15_r0_body.s1265.stack = PRE_first_tail_x15_r0_body.st131.s2.stack ++ PRE_first_tail_x15_r0_body.s1264.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs131 : PRE_first_tail_x15_r0_body.s1265.jobs = PRE_first_tail_x15_r0_body.st131.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi131 : PRE_first_tail_x15_r0_body.s1265.ffi = PRE_first_tail_x15_r0_body.st131.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace131 : PRE_first_tail_x15_r0_body.s1265.trace = PRE_first_tail_x15_r0_body.st131.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores131 : PRE_first_tail_x15_r0_body.s1265.stores = PRE_first_tail_x15_r0_body.st131.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD131
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 131 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived131 : PRE_first_tail_x15_r0_body.nr131.map (fun r => nth? PRE_first_tail_x15_r0_body.st131.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo131 : PRE_first_tail_x15_r0_body.nr131.all (Nat.ble 5653) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj131 : PRE_first_tail_x15_r0_body.cws131.all (fun c => !PRE_first_tail_x15_r0_body.ws131.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ131 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws131 PRE_first_tail_x15_r0_body.crs131 PRE_first_tail_x15_r0_body.ws131

end Host.Load.Run.Tpl
end

section -- st131/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st131`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st131.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st131.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st131.s2.heap PRE_first_tail_x15_r0_body.st131.wrR ++ freshOf PRE_first_tail_x15_r0_body.st131.s2.heap PRE_first_tail_x15_r0_body.st131.s0.next PRE_first_tail_x15_r0_body.st131.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st131.wr : List Nat := PRE_first_tail_x15_r0_body.st131.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st131.heapFoot : PRE_first_tail_x15_r0_body.st131.s2.heap = setAll PRE_first_tail_x15_r0_body.st131.s0.heap PRE_first_tail_x15_r0_body.st131.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st131.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st131.s0.next PRE_first_tail_x15_r0_body.st131.s2.next = true
theorem PRE_first_tail_x15_r0_body.st131.grows : PRE_first_tail_x15_r0_body.st131.s0.next ≤ PRE_first_tail_x15_r0_body.st131.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st131.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st131.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st131.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st131.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st131.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st131.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st131.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st131.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st131.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st131.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st131.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st131.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st131.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st131.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st131.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st131.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st131.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st131.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st131.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st131.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st131.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st131.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st131.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st131.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st131.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st131.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st131.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st131.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st131.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st131.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st131.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st131.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF131
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 131 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB131 : nodupT PRE_first_tail_x15_r0_body.st131.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup131 : PRE_first_tail_x15_r0_body.st131.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB131).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB131 : PRE_first_tail_x15_r0_body.st131.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound131 : ∀ b ∈ PRE_first_tail_x15_r0_body.st131.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB131 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr131 := PRE_first_tail_x15_r0_body.st131.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq131 : PRE_first_tail_x15_r0_body.st131.s2.trace = PRE_first_tail_x15_r0_body.trFr131 ++ PRE_first_tail_x15_r0_body.st131.s0.trace
theorem PRE_first_tail_x15_r0_body.trace131 : ∃ fr, PRE_first_tail_x15_r0_body.st131.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st131.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq131⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide131 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB131 : (PRE_first_tail_x15_r0_body.wide131.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st131.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix131 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide131, WFix Map.id (Present PRE_first_tail_x15_r0_body.st131.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB131 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL131
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 131 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1265`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO131 : PRE_first_tail_x15_r0_body.st131.S0.oracle = PRE_first_tail_x15_r0_body.st131.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B131 : PRE_first_tail_x15_r0_body.st131.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st131.s0.next || (PRE_first_tail_x15_r0_body.st131.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot131 : Conv.StageFoot PRE_first_tail_x15_r0_body.st131.wr PRE_first_tail_x15_r0_body.st131.s0 PRE_first_tail_x15_r0_body.st131.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st131.heapFoot PRE_first_tail_x15_r0_body.wrNodup131 PRE_first_tail_x15_r0_body.wrBound131 PRE_first_tail_x15_r0_body.wr0B131 PRE_first_tail_x15_r0_body.st131.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged131 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st131.F.S → PRE_first_tail_x15_r0_body.st131.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st131.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st131.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs131 PRE_first_tail_x15_r0_body.st131.wr PRE_first_tail_x15_r0_body.s1264 PRE_first_tail_x15_r0_body.st131.s2 PRE_first_tail_x15_r0_body.st131.s0
      PRE_first_tail_x15_r0_body.st131.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st131.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1265 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso131 PRE_first_tail_x15_r0_body.stFoot131 PRE_first_tail_x15_r0_body.wrNodup131 PRE_first_tail_x15_r0_body.wrBound131 PRE_first_tail_x15_r0_body.trace131 PRE_first_tail_x15_r0_body.mheap131
    PRE_first_tail_x15_r0_body.mnext131 PRE_first_tail_x15_r0_body.mctl131 PRE_first_tail_x15_r0_body.mstack131 PRE_first_tail_x15_r0_body.mjobs131 PRE_first_tail_x15_r0_body.mffi131 PRE_first_tail_x15_r0_body.mtrace131 PRE_first_tail_x15_r0_body.mstores131 h

def PRE_first_tail_x15_r0_body.arrEl131_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE131_2665 : arrOf PRE_first_tail_x15_r0_body.s1265 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl131_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA131_2665 : isArrB PRE_first_tail_x15_r0_body.s1265 2665 = true
theorem PRE_first_tail_x15_r0_body.arr131_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1265.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl131_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE131_2665 PRE_first_tail_x15_r0_body.arrA131_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN131_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl131_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR131_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl131_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN131_2665

def PRE_first_tail_x15_r0_body.arrEl131_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE131_2673467 : arrOf PRE_first_tail_x15_r0_body.s1265 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl131_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA131_2673467 : isArrB PRE_first_tail_x15_r0_body.s1265 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr131_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1265.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl131_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE131_2673467 PRE_first_tail_x15_r0_body.arrA131_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN131_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl131_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR131_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl131_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN131_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k131 : isArrB PRE_first_tail_x15_r0_body.s1265 4910 = false
theorem PRE_first_tail_x15_r0_body.keep131 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1265 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k131 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr131_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl131_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ131
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 131 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1264`, the merged
state `PRE_first_tail_x15_r0_body.s1265`, the canonical state `PRE_first_tail_x15_r0_body.s1266`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl131 : PRE_first_tail_x15_r0_body.pl131.all (Nat.ble PRE_first_tail_x15_r0_body.s1264.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd131 : nodupT PRE_first_tail_x15_r0_body.pl131 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1131 : Nat.ble PRE_first_tail_x15_r0_body.s1264.next 2777552 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst131 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1264.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn131 : PRE_first_tail_x15_r0_body.s1266.next = PRE_first_tail_x15_r0_body.s1264.next + PRE_first_tail_x15_r0_body.pl131.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn131 : PRE_first_tail_x15_r0_body.s1265.next = 2777552
kernel_rfl PRE_first_tail_x15_r0_body.zgrow131 : Nat.ble PRE_first_tail_x15_r0_body.s1266.next PRE_first_tail_x15_r0_body.s1265.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh131 : PRE_first_tail_x15_r0_body.S1264.tab.all (fun e => PRE_first_tail_x15_r0_body.cws131.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd131 : nodupT PRE_first_tail_x15_r0_body.cws131 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi131 : PRE_first_tail_x15_r0_body.nr131.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1265.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt131 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1264.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg131_2665 : PRE_first_tail_x15_r0_body.s1266.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1266 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk131_2665 : (objOf PRE_first_tail_x15_r0_body.s1266 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm131_2665 : PRE_first_tail_x15_r0_body.s1265.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa131.obj (objOf PRE_first_tail_x15_r0_body.s1266 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1265 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg131_2673467 : PRE_first_tail_x15_r0_body.s1266.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1266 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk131_2673467 : (objOf PRE_first_tail_x15_r0_body.s1266 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm131_2673467 : PRE_first_tail_x15_r0_body.s1265.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa131.obj (objOf PRE_first_tail_x15_r0_body.s1266 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1265 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw131_4910 : (PRE_first_tail_x15_r0_body.s1266.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw131_2673472 : (PRE_first_tail_x15_r0_body.s1266.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw131_2673473 : (PRE_first_tail_x15_r0_body.s1266.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd131 : PRE_first_tail_x15_r0_body.cl131.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr131 : PRE_first_tail_x15_r0_body.st131.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1264.next || PRE_first_tail_x15_r0_body.cl131.contains b) = true
def PRE_first_tail_x15_r0_body.zl131 : List Nat := PRE_first_tail_x15_r0_body.cl131.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE131 : PRE_first_tail_x15_r0_body.zl131.map (fun a => PRE_first_tail_x15_r0_body.s1265.heap.get (PRE_first_tail_x15_r0_body.kappa131.a a)) = PRE_first_tail_x15_r0_body.zl131.map (fun a => (PRE_first_tail_x15_r0_body.s1266.heap.get a).map PRE_first_tail_x15_r0_body.kappa131.hobj)
theorem PRE_first_tail_x15_r0_body.zimg131 : HeapImg PRE_first_tail_x15_r0_body.kappa131 PRE_first_tail_x15_r0_body.s1266 PRE_first_tail_x15_r0_body.s1265 PRE_first_tail_x15_r0_body.zl131 := PRE_first_tail_x15_r0_body.zimgE131
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl131 : PRE_first_tail_x15_r0_body.s1265.ctl = PRE_first_tail_x15_r0_body.kappa131.ctl PRE_first_tail_x15_r0_body.s1266.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack131 : PRE_first_tail_x15_r0_body.s1265.stack = PRE_first_tail_x15_r0_body.s1266.stack.map PRE_first_tail_x15_r0_body.kappa131.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs131 : PRE_first_tail_x15_r0_body.s1265.jobs = PRE_first_tail_x15_r0_body.s1266.jobs.map PRE_first_tail_x15_r0_body.kappa131.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores131 : PRE_first_tail_x15_r0_body.s1265.stores = PRE_first_tail_x15_r0_body.kappa131.stores PRE_first_tail_x15_r0_body.s1266.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots131 : checkRootsSupp PRE_first_tail_x15_r0_body.s1266 5653 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC131 : PRE_first_tail_x15_r0_body.S1264.tab.length + PRE_first_tail_x15_r0_body.cws131.length = 5653
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap131 : PRE_first_tail_x15_r0_body.kappa131 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1264.next 2777552 PRE_first_tail_x15_r0_body.S1264.tab.length PRE_first_tail_x15_r0_body.pl131 (PRE_first_tail_x15_r0_body.nr131.map NumV.ref) PRE_first_tail_x15_r0_body.kd131.big
  PRE_first_tail_x15_r0_body.kd131.region PRE_first_tail_x15_r0_body.kd131.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin131 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1266.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc131 : Conv.jcleanListB (⟨20777, 17866, 2777542, 5653⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1266 PRE_first_tail_x15_r0_body.cl131 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB131 : noBigRootsP (fun i => !Conv.oldBigB (⟨20777, 17866, 2777542, 5653⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1266.trace PRE_first_tail_x15_r0_body.s1266 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm131 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17866 = true
theorem PRE_first_tail_x15_r0_body.cjcl131 (h : Conv.JClean (⟨20777, 17866, 2777541, 5653⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1264) : Conv.JClean (⟨20777, 17866, 2777542, 5653⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1266 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle131)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap131 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd131 a ha)) PRE_first_tail_x15_r0_body.zjc131

end Host.Load.Run.Tpl
end

section -- st131/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st131.bodyLast from PRE_first_tail_x15_r0_body.st131.s1 to PRE_first_tail_x15_r0_body.st131.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st131.F PRE_first_tail_x15_r0_body.st131.s1).run PRE_first_tail_x15_r0_body.st131.S1 = some (PRE_first_tail_x15_r0_body.st131.s2, PRE_first_tail_x15_r0_body.st131.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st131.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st131.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st131.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st131.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st131/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st131.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st131.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st131.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st131.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st131.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st131.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st131.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st131.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st131.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st131.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st131.s0 PRE_first_tail_x15_r0_body.st131.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st131.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st131.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st131.s1 PRE_first_tail_x15_r0_body.st131.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st131/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st131.bodyK0F from PRE_first_tail_x15_r0_body.st131.s0 to PRE_first_tail_x15_r0_body.st131.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st131.F (PRE_first_tail_x15_r0_body.st131.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st131.ks 0).getD 0) PRE_first_tail_x15_r0_body.st131.s0 PRE_first_tail_x15_r0_body.st131.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st131.s1, PRE_first_tail_x15_r0_body.st131.S1)
theorem PRE_first_tail_x15_r0_body.st131.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st131.F (PRE_first_tail_x15_r0_body.st131.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st131.ks 0).getD 0) PRE_first_tail_x15_r0_body.st131.s0 PRE_first_tail_x15_r0_body.st131.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st131.s1, PRE_first_tail_x15_r0_body.st131.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st131.bodyOkLN_ok PRE_first_tail_x15_r0_body.st131.bodyK0F
end Host.Load.Run.Tpl
end

section -- st131/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st131.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st131.F (PRE_first_tail_x15_r0_body.st131.bodyOkL bytes rows) 98 PRE_first_tail_x15_r0_body.st131.s0 PRE_first_tail_x15_r0_body.st131.S0 = some (PRE_first_tail_x15_r0_body.st131.s1, PRE_first_tail_x15_r0_body.st131.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st131.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st131.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st131.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st131.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st131.F (PRE_first_tail_x15_r0_body.st131.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st131.s0
  S0 := PRE_first_tail_x15_r0_body.st131.S0
  s1 := PRE_first_tail_x15_r0_body.st131.s1
  S1 := PRE_first_tail_x15_r0_body.st131.S1
  s2 := PRE_first_tail_x15_r0_body.st131.s2
  S2 := PRE_first_tail_x15_r0_body.st131.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st131.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st131.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st131.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st131.bodyHalt
  last := PRE_first_tail_x15_r0_body.st131.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st131.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC132
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 132 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1283` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa132` into the merged state
`PRE_first_tail_x15_r0_body.s1282`. -/

def PRE_first_tail_x15_r0_body.pl132 : List Nat := [2780147, 2779322, 2780153, 2780149, 2779324, 2780155]
def PRE_first_tail_x15_r0_body.nr132 : List Nat := [5756, 5755, 5731, 5739, 5744, 5749, 5754, 5728, 5729, 5730, 5737, 5738, 5726, 5733, 5734, 5735, 5736, 5732]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd132 : RData :=
  ⟨2779041, 2780190, Stage.setAll PTrie.nil [(2779035, 2780147), (2779036, 2779322), (2779037, 2780153), (2779038, 2780149), (2779039, 2779324), (2779040, 2780155)], Stage.setAll PTrie.nil [(20812, 20838), (20813, 20816), (20814, 20839)],
   20815, 20840, 17912, 17912, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(5726, .ref 5756), (5727, .ref 5755), (5728, .ref 5731), (5729, .ref 5739), (5730, .ref 5744), (5731, .ref 5749), (5732, .ref 5754), (5733, .ref 5728), (5734, .ref 5729), (5735, .ref 5730), (5736, .ref 5737), (5737, .ref 5738), (5738, .ref 5726), (5739, .ref 5733), (5740, .ref 5734), (5741, .ref 5735), (5742, .ref 5736), (5743, .ref 5732)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa132 : Map :=
  Conv.Map.compact 2779035 2780190 5726 PRE_first_tail_x15_r0_body.pl132 (PRE_first_tail_x15_r0_body.nr132.map NumV.ref) PRE_first_tail_x15_r0_body.kd132.big
    PRE_first_tail_x15_r0_body.kd132.region PRE_first_tail_x15_r0_body.kd132.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws132 : List Nat := [3220, 3221, 3222, 3223, 3224, 3225, 3226, 3227, 3228, 3229, 3230, 3231, 3232, 3233, 3234, 3235, 3236, 3237]
noncomputable def PRE_first_tail_x15_r0_body.crs132 : List SymE := PRE_first_tail_x15_r0_body.nr132.map fun r => (nth? PRE_first_tail_x15_r0_body.S1282.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta132 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws132 PRE_first_tail_x15_r0_body.crs132
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB132 : List Nat := [2665, 2672641, 2673467, 2778209, 2778754, 2779010]

kernel_rfl PRE_first_tail_x15_r0_body.ctab132 : PRE_first_tail_x15_r0_body.S1283.tab = PRE_first_tail_x15_r0_body.S1281.tab ++ PRE_first_tail_x15_r0_body.cws132.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace132 : PRE_first_tail_x15_r0_body.s1283.trace = PRE_first_tail_x15_r0_body.s1281.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext132 : PRE_first_tail_x15_r0_body.s1283.next = 2779041
kernel_rfl PRE_first_tail_x15_r0_body.ccounters132 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx.nnext) = (20815, 17912)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue132 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1282.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa132.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp132 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx.tokens.all (bSN 5744) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean132 : Conv.cleanListB 20815 131072 (fun r => Nat.ble 83260 r) PRE_first_tail_x15_r0_body.s1283
    (PRE_first_tail_x15_r0_body.wrB132 ++ (List.range 6).map (2779035 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs132 : bigsOutB 20815 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx = true

end Host.Load.Run.Tpl
end

import host.sim.template.a4pre_first_tail_x8_r0_body.m.B29
import host.sim.template.BootEq
import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x8_r0_body.m.B00
import host.sim.conv.Compact
import host.sim.native.RebigR
import host.sim.template.Sigma
import host.sim.template.NShiftGen
import host.sim.stage.Mlx
import host.sim.conv.Closed
import host.sim.conv.NClean
import host.sim.conv.CompactFull
import host.sim.template.FootGen
import host.sim.template.a4pre_first_tail_x8_r0_body.States
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

section -- st153/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st153.bodyK0F from PRE_first_tail_x8_r0_body.st153.s0 to PRE_first_tail_x8_r0_body.st153.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st153.F (PRE_first_tail_x8_r0_body.st153.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st153.ks 0).getD 0) PRE_first_tail_x8_r0_body.st153.s0 PRE_first_tail_x8_r0_body.st153.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st153.s1, PRE_first_tail_x8_r0_body.st153.S1)
theorem PRE_first_tail_x8_r0_body.st153.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st153.F (PRE_first_tail_x8_r0_body.st153.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st153.ks 0).getD 0) PRE_first_tail_x8_r0_body.st153.s0 PRE_first_tail_x8_r0_body.st153.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st153.s1, PRE_first_tail_x8_r0_body.st153.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st153.bodyOkLN_ok PRE_first_tail_x8_r0_body.st153.bodyK0F
end Host.Load.Run.Tpl
end

section -- st153/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st153.bodyK1F from PRE_first_tail_x8_r0_body.st153.s1 to PRE_first_tail_x8_r0_body.st153.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st153.F (PRE_first_tail_x8_r0_body.st153.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st153.ks 1).getD 0) PRE_first_tail_x8_r0_body.st153.s1 PRE_first_tail_x8_r0_body.st153.S1) = fun _ _ => some (PRE_first_tail_x8_r0_body.st153.s2, PRE_first_tail_x8_r0_body.st153.S2)
theorem PRE_first_tail_x8_r0_body.st153.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st153.F (PRE_first_tail_x8_r0_body.st153.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st153.ks 1).getD 0) PRE_first_tail_x8_r0_body.st153.s1 PRE_first_tail_x8_r0_body.st153.S1) = fun _ _ => some (PRE_first_tail_x8_r0_body.st153.s2, PRE_first_tail_x8_r0_body.st153.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st153.bodyOkLN_ok PRE_first_tail_x8_r0_body.st153.bodyK1F
end Host.Load.Run.Tpl
end

section -- st153/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st153.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st153.F (PRE_first_tail_x8_r0_body.st153.bodyOkL bytes rows) 3452 PRE_first_tail_x8_r0_body.st153.s0 PRE_first_tail_x8_r0_body.st153.S0 = some (PRE_first_tail_x8_r0_body.st153.s2, PRE_first_tail_x8_r0_body.st153.S2) :=
  runOk_trans PRE_first_tail_x8_r0_body.st153.F (PRE_first_tail_x8_r0_body.st153.bodyOkL bytes rows) ((nth? PRE_first_tail_x8_r0_body.st153.ks 0).getD 0) ((nth? PRE_first_tail_x8_r0_body.st153.ks 1).getD 0) PRE_first_tail_x8_r0_body.st153.s0 PRE_first_tail_x8_r0_body.st153.s1 PRE_first_tail_x8_r0_body.st153.s2 PRE_first_tail_x8_r0_body.st153.S0 PRE_first_tail_x8_r0_body.st153.S1 PRE_first_tail_x8_r0_body.st153.S2 ((congrFun (congrFun PRE_first_tail_x8_r0_body.st153.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x8_r0_body.st153.bodyK1 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st153.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st153.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st153.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st153.F (PRE_first_tail_x8_r0_body.st153.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st153.s0
  S0 := PRE_first_tail_x8_r0_body.st153.S0
  s1 := PRE_first_tail_x8_r0_body.st153.s2
  S1 := PRE_first_tail_x8_r0_body.st153.S2
  s2 := PRE_first_tail_x8_r0_body.st153.s3
  S2 := PRE_first_tail_x8_r0_body.st153.S3
  n := 3452
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st153.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st153.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st153.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st153.bodyHalt
  last := PRE_first_tail_x8_r0_body.st153.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st153.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC154
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 154 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1492` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa154` into the merged state
`PRE_first_tail_x8_r0_body.s1491`. -/

def PRE_first_tail_x8_r0_body.pl154 : List Nat := []
def PRE_first_tail_x8_r0_body.nr154 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd154 : RData :=
  ⟨2796097, 2796099, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21242, 21242, 18336, 18336, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa154 : Map :=
  Conv.Map.compact 2796097 2796099 6662 PRE_first_tail_x8_r0_body.pl154 (PRE_first_tail_x8_r0_body.nr154.map NumV.ref) PRE_first_tail_x8_r0_body.kd154.big
    PRE_first_tail_x8_r0_body.kd154.region PRE_first_tail_x8_r0_body.kd154.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws154 : List Nat := []
noncomputable def PRE_first_tail_x8_r0_body.crs154 : List SymE := PRE_first_tail_x8_r0_body.nr154.map fun r => (nth? PRE_first_tail_x8_r0_body.S1491.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta154 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws154 PRE_first_tail_x8_r0_body.crs154
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB154 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x8_r0_body.ctab154 : PRE_first_tail_x8_r0_body.S1492.tab = PRE_first_tail_x8_r0_body.S1490.tab ++ PRE_first_tail_x8_r0_body.cws154.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace154 : PRE_first_tail_x8_r0_body.s1492.trace = PRE_first_tail_x8_r0_body.s1490.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext154 : PRE_first_tail_x8_r0_body.s1492.next = 2796097
kernel_rfl PRE_first_tail_x8_r0_body.ccounters154 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1492.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1492.ffi).mlx.nnext) = (21242, 18336)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue154 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1491.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1492.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa154.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp154 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1492.ffi).mlx.tokens.all (bSN 6662) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean154 : Conv.cleanListB 21242 131072 (fun r => Nat.ble 84968 r) PRE_first_tail_x8_r0_body.s1492
    (PRE_first_tail_x8_r0_body.wrB154 ++ (List.range 0).map (2796097 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs154 : bigsOutB 21242 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1492.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK154
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl154`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl154 : List Nat := [2665, 2673467]
def PRE_first_tail_x8_r0_body.clo154 : List Nat := []
def PRE_first_tail_x8_r0_body.cln154 : List Nat := []
def PRE_first_tail_x8_r0_body.cli154 : List Nat := []
kernel_rfl PRE_first_tail_x8_r0_body.cheap154 : PRE_first_tail_x8_r0_body.s1492.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1490.heap (PRE_first_tail_x8_r0_body.cl154.filterMap fun a => (PRE_first_tail_x8_r0_body.s1492.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe154 : Nat.ble PRE_first_tail_x8_r0_body.s1490.next PRE_first_tail_x8_r0_body.s1492.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP154 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1490 PRE_first_tail_x8_r0_body.s1492 PRE_first_tail_x8_r0_body.cl154 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp154 : Conv.suppListB PRE_first_tail_x8_r0_body.s1492 6662 PRE_first_tail_x8_r0_body.cl154 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound154 : Conv.boundListB PRE_first_tail_x8_r0_body.s1492 PRE_first_tail_x8_r0_body.cl154 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK154 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1492.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln154.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1492.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK154 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1492.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo154.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1492.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK154 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1492.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli154.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1492.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst154 : Conv.sstListB 6662 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1492.ffi).mlx PRE_first_tail_x8_r0_body.cln154 PRE_first_tail_x8_r0_body.clo154 PRE_first_tail_x8_r0_body.cli154 = true

end Host.Load.Run.Tpl
end

section -- SiteCl154
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA154 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1492.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo154.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1492.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd154 : (PRE_first_tail_x8_r0_body.clo154 ++ PRE_first_tail_x8_r0_body.cln154 ++ PRE_first_tail_x8_r0_body.cli154).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle154 : Conv.Cnt.leB (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck154 : Conv.ncleanListB (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1492.ffi).mlx PRE_first_tail_x8_r0_body.clo154 PRE_first_tail_x8_r0_body.cln154 PRE_first_tail_x8_r0_body.cli154 = true
theorem PRE_first_tail_x8_r0_body.cncl154 (h : Conv.NClean (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx) : Conv.NClean (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1492.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle154 PRE_first_tail_x8_r0_body.ckA154 PRE_first_tail_x8_r0_body.cobjsK154 PRE_first_tail_x8_r0_body.cnodesK154 PRE_first_tail_x8_r0_body.citemsK154 PRE_first_tail_x8_r0_body.cbd154 PRE_first_tail_x8_r0_body.cck154

end Host.Load.Run.Tpl
end

section -- SiteS154
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 154 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc154 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P154 : LoadP := PRE_first_tail_x8_r0_body.Pc154.raise 18336
kernel_rfl PRE_first_tail_x8_r0_body.craise154 : Nat.ble PRE_first_tail_x8_r0_body.Pc154.N0 18336 = true
theorem PRE_first_tail_x8_r0_body.raised154 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc154 PRE_first_tail_x8_r0_body.P154 :=
  .inr ⟨18336, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise154, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_154 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1492.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_154 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1491.ffi)
def PRE_first_tail_x8_r0_body.khinv154 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x8_r0_body.kninv154 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS154 : List Nat := []
def PRE_first_tail_x8_r0_body.cnS154 : List Nat := List.range' 18336 0
def PRE_first_tail_x8_r0_body.ciS154 : List Nat := [] ++ List.range' 18336 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0154 : PRE_first_tail_x8_r0_body.kd154.nh0 = PRE_first_tail_x8_r0_body.cx0_154.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1154 : PRE_first_tail_x8_r0_body.kd154.nh1 = PRE_first_tail_x8_r0_body.cx1_154.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0154 : PRE_first_tail_x8_r0_body.kd154.nn0 = PRE_first_tail_x8_r0_body.cx0_154.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1154 : PRE_first_tail_x8_r0_body.kd154.nn1 = PRE_first_tail_x8_r0_body.cx1_154.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo154 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P154.lo && Nat.ble PRE_first_tail_x8_r0_body.P154.lo PRE_first_tail_x8_r0_body.cx0_154.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P154.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P154.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt154 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_154.mlx.next PRE_first_tail_x8_r0_body.cx1_154.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_154.mlx.nnext PRE_first_tail_x8_r0_body.cx1_154.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband154 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P154.NL && Nat.ble PRE_first_tail_x8_r0_body.P154.NL PRE_first_tail_x8_r0_body.P154.N0 && Nat.ble PRE_first_tail_x8_r0_body.P154.N0 PRE_first_tail_x8_r0_body.cx0_154.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow154 : PRE_first_tail_x8_r0_body.kd154.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren154 : checkRenG PRE_first_tail_x8_r0_body.kd154.hnd PRE_first_tail_x8_r0_body.khinv154 (phB PRE_first_tail_x8_r0_body.cx0_154.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband154 : PRE_first_tail_x8_r0_body.kd154.checkBand PRE_first_tail_x8_r0_body.P154.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos154 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd154.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren154 : checkRenG PRE_first_tail_x8_r0_body.kd154.node PRE_first_tail_x8_r0_body.kninv154 (pnB PRE_first_tail_x8_r0_body.cx0_154.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow154 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd154.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P154.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd154.nodeF j) PRE_first_tail_x8_r0_body.cx1_154.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a154 : PRE_first_tail_x8_r0_body.cx0_154.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b154 : PRE_first_tail_x8_r0_body.cx0_154.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1154 : PRE_first_tail_x8_r0_body.cx1_154.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend154 : PRE_first_tail_x8_r0_body.cx1_154.mlx.pending = PRE_first_tail_x8_r0_body.cx0_154.mlx.pending.map PRE_first_tail_x8_r0_body.kappa154.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh154 : PRE_first_tail_x8_r0_body.cx1_154.mlx.errh = PRE_first_tail_x8_r0_body.cx0_154.mlx.errh.map PRE_first_tail_x8_r0_body.kappa154.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles154 : PRE_first_tail_x8_r0_body.cx1_154.mlx.files = PRE_first_tail_x8_r0_body.cx0_154.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch154 : PRE_first_tail_x8_r0_body.cx1_154.mlx.arch = PRE_first_tail_x8_r0_body.cx0_154.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes154 : PRE_first_tail_x8_r0_body.cx1_154.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_154.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired154 : PRE_first_tail_x8_r0_body.cx1_154.mlx.wired = PRE_first_tail_x8_r0_body.cx0_154.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost154 : PRE_first_tail_x8_r0_body.cx1_154.host = PRE_first_tail_x8_r0_body.cx0_154.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd154`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0154 : PRE_first_tail_x8_r0_body.kd154.n0 = 2796097
kernel_rfl PRE_first_tail_x8_r0_body.ckn1154 : PRE_first_tail_x8_r0_body.kd154.n1 = 2796099
kernel_rfl PRE_first_tail_x8_r0_body.ckheap154 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd154.heap).all (fun x => Nat.ble 2796097 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl154 : (List.range 0).all (fun j => decide (PRE_first_tail_x8_r0_body.kd154.heap.get (2796097 + j) = nth? PRE_first_tail_x8_r0_body.pl154 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja154 : Nat.ble 2796097 2796097 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn154 : Nat.ble 6662 6662 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD154 : Nat.ble 2796097 PRE_first_tail_x8_r0_body.kd154.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn154 : Nat.ble 21242 PRE_first_tail_x8_r0_body.kd154.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn154 : Nat.ble 18336 PRE_first_tail_x8_r0_body.kd154.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb154 : Nat.ble 21242 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap154 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd154.heap).all (Nat.ble (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd154 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd154.hnd).all (Nat.ble (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode154 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd154.node).all (Nat.ble (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix154 : Conv.FixOld (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa154 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja154) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn154) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD154) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn154) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn154) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb154) PRE_first_tail_x8_r0_body.fheap154 PRE_first_tail_x8_r0_body.fhnd154 PRE_first_tail_x8_r0_body.fnode154
kernel_rfl PRE_first_tail_x8_r0_body.fcxn154 : (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn154 : (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0154 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_154.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_154.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk154 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd154.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A154 : PRE_first_tail_x8_r0_body.cx1_154.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS154.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_154.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O154 : PRE_first_tail_x8_r0_body.cx1_154.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS154.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_154.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N154 : PRE_first_tail_x8_r0_body.cx1_154.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS154.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_154.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I154 : PRE_first_tail_x8_r0_body.cx1_154.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS154.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_154.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd154 : (PRE_first_tail_x8_r0_body.clo154 ++ PRE_first_tail_x8_r0_body.cln154 ++ PRE_first_tail_x8_r0_body.cli154 ++ PRE_first_tail_x8_r0_body.cwS154 ++ PRE_first_tail_x8_r0_body.cnS154 ++ PRE_first_tail_x8_r0_body.ciS154).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW154 : PRE_first_tail_x8_r0_body.cwS154.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo154.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI154 : PRE_first_tail_x8_r0_body.ciS154.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli154.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN154 : PRE_first_tail_x8_r0_body.cnS154.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF154 : PRE_first_tail_x8_r0_body.cln154.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh154 : PRE_first_tail_x8_r0_body.clo154.all (handleOK PRE_first_tail_x8_r0_body.kappa154 PRE_first_tail_x8_r0_body.P154.lo PRE_first_tail_x8_r0_body.cx0_154.mlx PRE_first_tail_x8_r0_body.cx1_154.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo154 : PRE_first_tail_x8_r0_body.clo154.map (fun h => PRE_first_tail_x8_r0_body.cx1_154.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa154.handle h)) = PRE_first_tail_x8_r0_body.clo154.map (fun h => (PRE_first_tail_x8_r0_body.cx0_154.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa154.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok154 : PRE_first_tail_x8_r0_body.clo154.all (objOK PRE_first_tail_x8_r0_body.kappa154 PRE_first_tail_x8_r0_body.P154.NL PRE_first_tail_x8_r0_body.cx0_154.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd154 : PRE_first_tail_x8_r0_body.cln154.all (nodeOKF PRE_first_tail_x8_r0_body.kappa154 PRE_first_tail_x8_r0_body.P154 PRE_first_tail_x8_r0_body.cx0_154.mlx PRE_first_tail_x8_r0_body.cx1_154.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp154 : ((PRE_first_tail_x8_r0_body.cln154.filter (fullB PRE_first_tail_x8_r0_body.P154))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_154.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa154.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln154.filter (fullB PRE_first_tail_x8_r0_body.P154))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_154.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa154.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI154 : incrB PRE_first_tail_x8_r0_body.kd154.nodeF (List.range' 18336 0) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK154 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd154.node).all (fun k => Nat.ble 18336 k && Nat.blt k 18336) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL154 : (PRE_first_tail_x8_r0_body.cln154.filter (Nat.ble PRE_first_tail_x8_r0_body.P154.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd154.nodeF i) && (Nat.blt i 18336 || Nat.ble PRE_first_tail_x8_r0_body.kd154.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord154 : (PRE_first_tail_x8_r0_body.cln154.filter (Nat.ble PRE_first_tail_x8_r0_body.P154.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd154.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd154.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd154.nodeF j) (PRE_first_tail_x8_r0_body.kd154.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow154 PRE_first_tail_x8_r0_body.cnn1154 PRE_first_tail_x8_r0_body.fnordI154 PRE_first_tail_x8_r0_body.fnordK154 PRE_first_tail_x8_r0_body.fnordL154
kernel_rfl PRE_first_tail_x8_r0_body.fi154 : PRE_first_tail_x8_r0_body.cli154.all (pnB PRE_first_tail_x8_r0_body.cx0_154.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii154 : PRE_first_tail_x8_r0_body.cli154.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_154.mlx.items.get (PRE_first_tail_x8_r0_body.kappa154.node k) = (PRE_first_tail_x8_r0_body.cx0_154.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa154.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot154 (clean : Conv.NClean (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P154.NL) (cl : SSt (· < 6662) PRE_first_tail_x8_r0_body.cx0_154.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P154 6662 PRE_first_tail_x8_r0_body.kappa154 PRE_first_tail_x8_r0_body.kd154 PRE_first_tail_x8_r0_body.khinv154 PRE_first_tail_x8_r0_body.kninv154 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx PRE_first_tail_x8_r0_body.cx0_154.mlx PRE_first_tail_x8_r0_body.cx1_154.mlx (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo154 PRE_first_tail_x8_r0_body.cln154 PRE_first_tail_x8_r0_body.cli154 PRE_first_tail_x8_r0_body.cwS154 PRE_first_tail_x8_r0_body.cnS154 PRE_first_tail_x8_r0_body.ciS154 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0154, PRE_first_tail_x8_r0_body.cnh1154, PRE_first_tail_x8_r0_body.cnn0154, PRE_first_tail_x8_r0_body.cnn1154, PRE_first_tail_x8_r0_body.cplo154, PRE_first_tail_x8_r0_body.ccnt154, PRE_first_tail_x8_r0_body.cnband154, PRE_first_tail_x8_r0_body.chbelow154, PRE_first_tail_x8_r0_body.chren154, PRE_first_tail_x8_r0_body.cband154, PRE_first_tail_x8_r0_body.cnh1pos154, PRE_first_tail_x8_r0_body.cnren154, PRE_first_tail_x8_r0_body.cnlow154, PRE_first_tail_x8_r0_body.cabs0a154, PRE_first_tail_x8_r0_body.cabs0b154, PRE_first_tail_x8_r0_body.ctok1154, PRE_first_tail_x8_r0_body.cpend154, PRE_first_tail_x8_r0_body.cerrh154, PRE_first_tail_x8_r0_body.cfiles154, PRE_first_tail_x8_r0_body.carch154, PRE_first_tail_x8_r0_body.csizes154, PRE_first_tail_x8_r0_body.cwired154, PRE_first_tail_x8_r0_body.cfix154, clean, PRE_first_tail_x8_r0_body.fcxn154, PRE_first_tail_x8_r0_body.fcnn154, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0154, PRE_first_tail_x8_r0_body.fnk154, PRE_first_tail_x8_r0_body.ckA154, PRE_first_tail_x8_r0_body.cobjsK154, PRE_first_tail_x8_r0_body.cnodesK154, PRE_first_tail_x8_r0_body.citemsK154, PRE_first_tail_x8_r0_body.f1A154, PRE_first_tail_x8_r0_body.f1O154, PRE_first_tail_x8_r0_body.f1N154, PRE_first_tail_x8_r0_body.f1I154, PRE_first_tail_x8_r0_body.fbd154, PRE_first_tail_x8_r0_body.fincW154, PRE_first_tail_x8_r0_body.fincI154, PRE_first_tail_x8_r0_body.fincN154, PRE_first_tail_x8_r0_body.flnF154, PRE_first_tail_x8_r0_body.fh154, PRE_first_tail_x8_r0_body.fo154, PRE_first_tail_x8_r0_body.fok154, PRE_first_tail_x8_r0_body.fnd154, PRE_first_tail_x8_r0_body.fp154, PRE_first_tail_x8_r0_body.fnord154, PRE_first_tail_x8_r0_body.fi154, PRE_first_tail_x8_r0_body.fii154⟩
theorem PRE_first_tail_x8_r0_body.cnshift154 (clean : Conv.NClean (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P154.NL) (cl : SSt (· < 6662) PRE_first_tail_x8_r0_body.cx0_154.mlx) : NShift PRE_first_tail_x8_r0_body.P154 6662 PRE_first_tail_x8_r0_body.kappa154 PRE_first_tail_x8_r0_body.cx0_154 PRE_first_tail_x8_r0_body.cx1_154 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot154 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost154 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0154 PRE_first_tail_x8_r0_body.ckn1154 PRE_first_tail_x8_r0_body.ckheap154 PRE_first_tail_x8_r0_body.ckpl154)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_154 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1490.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_154 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1490.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_154 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1490.ffi) = some PRE_first_tail_x8_r0_body.fxC_154
kernel_rfl PRE_first_tail_x8_r0_body.okrC_154 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1490.ffi) = some PRE_first_tail_x8_r0_body.krC_154
noncomputable def PRE_first_tail_x8_r0_body.fx0_154 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1492.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_154 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1492.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_154 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1492.ffi) = some PRE_first_tail_x8_r0_body.fx0_154
kernel_rfl PRE_first_tail_x8_r0_body.okr0_154 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1492.ffi) = some PRE_first_tail_x8_r0_body.kr0_154
noncomputable def PRE_first_tail_x8_r0_body.fx1_154 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1491.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_154 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1491.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_154 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1491.ffi) = some PRE_first_tail_x8_r0_body.fx1_154
kernel_rfl PRE_first_tail_x8_r0_body.okr1_154 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1491.ffi) = some PRE_first_tail_x8_r0_body.kr1_154
kernel_rfl PRE_first_tail_x8_r0_body.ff0154 : PRE_first_tail_x8_r0_body.fx0_154 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_154 (PRE_first_tail_x8_r0_body.clo154.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_154.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1154 : PRE_first_tail_x8_r0_body.fx1_154 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_154 (PRE_first_tail_x8_r0_body.cwS154.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_154.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck154 : freedLB PRE_first_tail_x8_r0_body.kappa154 PRE_first_tail_x8_r0_body.cx0_154.mlx PRE_first_tail_x8_r0_body.fx0_154 PRE_first_tail_x8_r0_body.fx1_154 PRE_first_tail_x8_r0_body.clo154 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0154 : PRE_first_tail_x8_r0_body.kr0_154.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_154.flags (PRE_first_tail_x8_r0_body.clo154.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_154.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0154 : PRE_first_tail_x8_r0_body.kr0_154.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_154.targs (PRE_first_tail_x8_r0_body.clo154.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_154.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1154 : PRE_first_tail_x8_r0_body.kr1_154.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_154.flags (PRE_first_tail_x8_r0_body.cwS154.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_154.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1154 : PRE_first_tail_x8_r0_body.kr1_154.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_154.targs (PRE_first_tail_x8_r0_body.cwS154.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_154.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck154 : krecLB PRE_first_tail_x8_r0_body.kappa154 6662 PRE_first_tail_x8_r0_body.cx0_154.mlx PRE_first_tail_x8_r0_body.kr0_154 PRE_first_tail_x8_r0_body.kr1_154 PRE_first_tail_x8_r0_body.clo154 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn154 : Nat.ble 6662 6662 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge154 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1491.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1492.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR154 : pendRegB PRE_first_tail_x8_r0_body.kappa154 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1492.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe154 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1492.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1491.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift154 (clean : Conv.NClean (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P154.NL) (cl : SSt (· < 6662) PRE_first_tail_x8_r0_body.cx0_154.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_154.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_154.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_154.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1490.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_154.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P154 6662 PRE_first_tail_x8_r0_body.kappa154 PRE_first_tail_x8_r0_body.s1492.ffi PRE_first_tail_x8_r0_body.s1491.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift154 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue154, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp154 t ht),
    PRE_first_tail_x8_r0_body.cbridge154,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1492.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1491.ffi) (PRE_first_tail_x8_r0_body.cfoot154 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_154 PRE_first_tail_x8_r0_body.ofx1_154 hobjC PRE_first_tail_x8_r0_body.ff0154 PRE_first_tail_x8_r0_body.ff1154 PRE_first_tail_x8_r0_body.ffck154,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1492.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1491.ffi) (PRE_first_tail_x8_r0_body.cfoot154 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_154 PRE_first_tail_x8_r0_body.okr1_154 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn154) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0154 PRE_first_tail_x8_r0_body.fkt0154 PRE_first_tail_x8_r0_body.fkf1154 PRE_first_tail_x8_r0_body.fkt1154 PRE_first_tail_x8_r0_body.fkck154,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0154 PRE_first_tail_x8_r0_body.cnh1154 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe154) PRE_first_tail_x8_r0_body.cpendR154⟩

end Host.Load.Run.Tpl
end

section -- st154/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st154 0
host_stream_state PRE_first_tail_x8_r0_body.st154 1
host_stream_state PRE_first_tail_x8_r0_body.st154 2
end Host.Load.Run.Tpl
end

section -- Site154
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 154 of chain `PRE_first_tail_x8_r0_body`: `rowBlocks__g154__g155` (`rowBlocks`), the call state `PRE_first_tail_x8_r0_body.s1490`, the merged state `PRE_first_tail_x8_r0_body.s1491`,
the site template `PRE_first_tail_x8_r0_body.st154` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1492`: the merge.
The footprint's facts are in `SiteF154`, the compaction's in `SiteC154`, `SiteK154`, `SiteNa154`, `SiteNb154`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso154 : PRE_first_tail_x8_r0_body.st154.s0 = { PRE_first_tail_x8_r0_body.s1490 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs154 : List Frame := PRE_first_tail_x8_r0_body.s1490.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_154 : PRE_first_tail_x8_r0_body.S1490.tab.length = 6662
kernel_rfl PRE_first_tail_x8_r0_body.tab0_154 : PRE_first_tail_x8_r0_body.st154.S0.tab = PRE_first_tail_x8_r0_body.S1490.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws154 : List Nat := [3600, 3601]
kernel_rfl PRE_first_tail_x8_r0_body.fresh154 : (PRE_first_tail_x8_r0_body.S1490.tab.all fun e => PRE_first_tail_x8_r0_body.ws154.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1490.oracle.all fun q => PRE_first_tail_x8_r0_body.ws154.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab154 : PRE_first_tail_x8_r0_body.S1491.tab = PRE_first_tail_x8_r0_body.S1490.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws154
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen154 : PRE_first_tail_x8_r0_body.st154.S2.tab.length - PRE_first_tail_x8_r0_body.st154.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged154`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap154 : PRE_first_tail_x8_r0_body.s1491.heap = PRE_first_tail_x8_r0_body.st154.s2.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext154 : PRE_first_tail_x8_r0_body.s1491.next = PRE_first_tail_x8_r0_body.st154.s2.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl154 : PRE_first_tail_x8_r0_body.s1491.ctl = PRE_first_tail_x8_r0_body.st154.s2.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack154 : PRE_first_tail_x8_r0_body.s1491.stack = PRE_first_tail_x8_r0_body.st154.s2.stack ++ PRE_first_tail_x8_r0_body.s1490.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs154 : PRE_first_tail_x8_r0_body.s1491.jobs = PRE_first_tail_x8_r0_body.st154.s2.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi154 : PRE_first_tail_x8_r0_body.s1491.ffi = PRE_first_tail_x8_r0_body.st154.s2.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace154 : PRE_first_tail_x8_r0_body.s1491.trace = PRE_first_tail_x8_r0_body.st154.s2.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores154 : PRE_first_tail_x8_r0_body.s1491.stores = PRE_first_tail_x8_r0_body.st154.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD154
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 154 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived154 : PRE_first_tail_x8_r0_body.nr154.map (fun r => nth? PRE_first_tail_x8_r0_body.st154.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo154 : PRE_first_tail_x8_r0_body.nr154.all (Nat.ble 6662) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj154 : PRE_first_tail_x8_r0_body.cws154.all (fun c => !PRE_first_tail_x8_r0_body.ws154.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ154 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws154 PRE_first_tail_x8_r0_body.crs154 PRE_first_tail_x8_r0_body.ws154

end Host.Load.Run.Tpl
end

section -- st154/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st154`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st154.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st154.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st154.s2.heap PRE_first_tail_x8_r0_body.st154.wrR ++ freshOf PRE_first_tail_x8_r0_body.st154.s2.heap PRE_first_tail_x8_r0_body.st154.s0.next PRE_first_tail_x8_r0_body.st154.s2.next
noncomputable def PRE_first_tail_x8_r0_body.st154.wr : List Nat := PRE_first_tail_x8_r0_body.st154.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st154.heapFoot : PRE_first_tail_x8_r0_body.st154.s2.heap = setAll PRE_first_tail_x8_r0_body.st154.s0.heap PRE_first_tail_x8_r0_body.st154.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st154.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st154.s0.next PRE_first_tail_x8_r0_body.st154.s2.next = true
theorem PRE_first_tail_x8_r0_body.st154.grows : PRE_first_tail_x8_r0_body.st154.s0.next ≤ PRE_first_tail_x8_r0_body.st154.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st154.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st154.wh : List Nat := []
def PRE_first_tail_x8_r0_body.st154.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st154.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st154.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st154.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st154.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st154.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st154.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st154.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st154.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st154.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st154.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st154.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st154.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st154.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st154.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st154.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st154.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st154.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st154.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st154.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st154.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st154.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st154.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st154.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st154.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st154.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st154.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st154.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st154.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st154.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF154
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 154 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB154 : nodupT PRE_first_tail_x8_r0_body.st154.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup154 : PRE_first_tail_x8_r0_body.st154.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB154).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB154 : PRE_first_tail_x8_r0_body.st154.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound154 : ∀ b ∈ PRE_first_tail_x8_r0_body.st154.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB154 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr154 := PRE_first_tail_x8_r0_body.st154.s2.trace.take 0
kernel_rfl PRE_first_tail_x8_r0_body.traceEq154 : PRE_first_tail_x8_r0_body.st154.s2.trace = PRE_first_tail_x8_r0_body.trFr154 ++ PRE_first_tail_x8_r0_body.st154.s0.trace
theorem PRE_first_tail_x8_r0_body.trace154 : ∃ fr, PRE_first_tail_x8_r0_body.st154.s2.trace = fr ++ PRE_first_tail_x8_r0_body.st154.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq154⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide154 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB154 : (PRE_first_tail_x8_r0_body.wide154.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st154.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix154 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide154, WFix Map.id (Present PRE_first_tail_x8_r0_body.st154.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB154 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL154
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 154 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1491`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO154 : PRE_first_tail_x8_r0_body.st154.S0.oracle = PRE_first_tail_x8_r0_body.st154.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B154 : PRE_first_tail_x8_r0_body.st154.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st154.s0.next || (PRE_first_tail_x8_r0_body.st154.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot154 : Conv.StageFoot PRE_first_tail_x8_r0_body.st154.wr PRE_first_tail_x8_r0_body.st154.s0 PRE_first_tail_x8_r0_body.st154.s2 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st154.heapFoot PRE_first_tail_x8_r0_body.wrNodup154 PRE_first_tail_x8_r0_body.wrBound154 PRE_first_tail_x8_r0_body.wr0B154 PRE_first_tail_x8_r0_body.st154.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged154 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st154.F.S → PRE_first_tail_x8_r0_body.st154.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st154.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st154.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs154 PRE_first_tail_x8_r0_body.st154.wr PRE_first_tail_x8_r0_body.s1490 PRE_first_tail_x8_r0_body.st154.s2 PRE_first_tail_x8_r0_body.st154.s0
      PRE_first_tail_x8_r0_body.st154.s2.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st154.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1491 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso154 PRE_first_tail_x8_r0_body.stFoot154 PRE_first_tail_x8_r0_body.wrNodup154 PRE_first_tail_x8_r0_body.wrBound154 PRE_first_tail_x8_r0_body.trace154 PRE_first_tail_x8_r0_body.mheap154
    PRE_first_tail_x8_r0_body.mnext154 PRE_first_tail_x8_r0_body.mctl154 PRE_first_tail_x8_r0_body.mstack154 PRE_first_tail_x8_r0_body.mjobs154 PRE_first_tail_x8_r0_body.mffi154 PRE_first_tail_x8_r0_body.mtrace154 PRE_first_tail_x8_r0_body.mstores154 h

def PRE_first_tail_x8_r0_body.arrEl154_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE154_2665 : arrOf PRE_first_tail_x8_r0_body.s1491 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl154_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA154_2665 : isArrB PRE_first_tail_x8_r0_body.s1491 2665 = true
theorem PRE_first_tail_x8_r0_body.arr154_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1491.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl154_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE154_2665 PRE_first_tail_x8_r0_body.arrA154_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN154_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl154_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR154_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl154_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN154_2665

def PRE_first_tail_x8_r0_body.arrEl154_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE154_2673467 : arrOf PRE_first_tail_x8_r0_body.s1491 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl154_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA154_2673467 : isArrB PRE_first_tail_x8_r0_body.s1491 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr154_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1491.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl154_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE154_2673467 PRE_first_tail_x8_r0_body.arrA154_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN154_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl154_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR154_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl154_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN154_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k154 : isArrB PRE_first_tail_x8_r0_body.s1491 4910 = false
theorem PRE_first_tail_x8_r0_body.keep154 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1491 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k154 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr154_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl154_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ154
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 154 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1490`, the merged
state `PRE_first_tail_x8_r0_body.s1491`, the canonical state `PRE_first_tail_x8_r0_body.s1492`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl154 : PRE_first_tail_x8_r0_body.pl154.all (Nat.ble PRE_first_tail_x8_r0_body.s1490.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd154 : nodupT PRE_first_tail_x8_r0_body.pl154 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1154 : Nat.ble PRE_first_tail_x8_r0_body.s1490.next 2796099 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst154 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1490.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn154 : PRE_first_tail_x8_r0_body.s1492.next = PRE_first_tail_x8_r0_body.s1490.next + PRE_first_tail_x8_r0_body.pl154.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn154 : PRE_first_tail_x8_r0_body.s1491.next = 2796099
kernel_rfl PRE_first_tail_x8_r0_body.zgrow154 : Nat.ble PRE_first_tail_x8_r0_body.s1492.next PRE_first_tail_x8_r0_body.s1491.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh154 : PRE_first_tail_x8_r0_body.S1490.tab.all (fun e => PRE_first_tail_x8_r0_body.cws154.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd154 : nodupT PRE_first_tail_x8_r0_body.cws154 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi154 : PRE_first_tail_x8_r0_body.nr154.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1491.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt154 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1490.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg154_2665 : PRE_first_tail_x8_r0_body.s1492.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1492 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk154_2665 : (objOf PRE_first_tail_x8_r0_body.s1492 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm154_2665 : PRE_first_tail_x8_r0_body.s1491.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa154.obj (objOf PRE_first_tail_x8_r0_body.s1492 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1491 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg154_2673467 : PRE_first_tail_x8_r0_body.s1492.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1492 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk154_2673467 : (objOf PRE_first_tail_x8_r0_body.s1492 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm154_2673467 : PRE_first_tail_x8_r0_body.s1491.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa154.obj (objOf PRE_first_tail_x8_r0_body.s1492 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1491 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw154_4910 : (PRE_first_tail_x8_r0_body.s1492.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw154_2673472 : (PRE_first_tail_x8_r0_body.s1492.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw154_2673473 : (PRE_first_tail_x8_r0_body.s1492.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd154 : PRE_first_tail_x8_r0_body.cl154.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr154 : PRE_first_tail_x8_r0_body.st154.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1490.next || PRE_first_tail_x8_r0_body.cl154.contains b) = true
def PRE_first_tail_x8_r0_body.zl154 : List Nat := PRE_first_tail_x8_r0_body.cl154.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE154 : PRE_first_tail_x8_r0_body.zl154.map (fun a => PRE_first_tail_x8_r0_body.s1491.heap.get (PRE_first_tail_x8_r0_body.kappa154.a a)) = PRE_first_tail_x8_r0_body.zl154.map (fun a => (PRE_first_tail_x8_r0_body.s1492.heap.get a).map PRE_first_tail_x8_r0_body.kappa154.hobj)
theorem PRE_first_tail_x8_r0_body.zimg154 : HeapImg PRE_first_tail_x8_r0_body.kappa154 PRE_first_tail_x8_r0_body.s1492 PRE_first_tail_x8_r0_body.s1491 PRE_first_tail_x8_r0_body.zl154 := PRE_first_tail_x8_r0_body.zimgE154
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl154 : PRE_first_tail_x8_r0_body.s1491.ctl = PRE_first_tail_x8_r0_body.kappa154.ctl PRE_first_tail_x8_r0_body.s1492.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack154 : PRE_first_tail_x8_r0_body.s1491.stack = PRE_first_tail_x8_r0_body.s1492.stack.map PRE_first_tail_x8_r0_body.kappa154.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs154 : PRE_first_tail_x8_r0_body.s1491.jobs = PRE_first_tail_x8_r0_body.s1492.jobs.map PRE_first_tail_x8_r0_body.kappa154.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores154 : PRE_first_tail_x8_r0_body.s1491.stores = PRE_first_tail_x8_r0_body.kappa154.stores PRE_first_tail_x8_r0_body.s1492.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots154 : checkRootsSupp PRE_first_tail_x8_r0_body.s1492 6662 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC154 : PRE_first_tail_x8_r0_body.S1490.tab.length + PRE_first_tail_x8_r0_body.cws154.length = 6662
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap154 : PRE_first_tail_x8_r0_body.kappa154 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1490.next 2796099 PRE_first_tail_x8_r0_body.S1490.tab.length PRE_first_tail_x8_r0_body.pl154 (PRE_first_tail_x8_r0_body.nr154.map NumV.ref) PRE_first_tail_x8_r0_body.kd154.big
  PRE_first_tail_x8_r0_body.kd154.region PRE_first_tail_x8_r0_body.kd154.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin154 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1492.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc154 : Conv.jcleanListB (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1492 PRE_first_tail_x8_r0_body.cl154 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB154 : noBigRootsP (fun i => !Conv.oldBigB (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1492.trace PRE_first_tail_x8_r0_body.s1492 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm154 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 18336 = true
theorem PRE_first_tail_x8_r0_body.cjcl154 (h : Conv.JClean (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1490) : Conv.JClean (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1492 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle154)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap154 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd154 a ha)) PRE_first_tail_x8_r0_body.zjc154

end Host.Load.Run.Tpl
end

section -- st154/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st154.bodyLast from PRE_first_tail_x8_r0_body.st154.s1 to PRE_first_tail_x8_r0_body.st154.s2 :
  interpS (step PRE_first_tail_x8_r0_body.st154.F PRE_first_tail_x8_r0_body.st154.s1).run PRE_first_tail_x8_r0_body.st154.S1 = some (PRE_first_tail_x8_r0_body.st154.s2, PRE_first_tail_x8_r0_body.st154.S2)
kernel_rfl PRE_first_tail_x8_r0_body.st154.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st154.s1.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st154.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st154.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st154/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st154.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st154.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st154.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st154.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st154.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st154.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st154.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st154.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st154.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st154.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st154.s0 PRE_first_tail_x8_r0_body.st154.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st154.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st154.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st154.s1 PRE_first_tail_x8_r0_body.st154.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st154/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st154.bodyK0F from PRE_first_tail_x8_r0_body.st154.s0 to PRE_first_tail_x8_r0_body.st154.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st154.F (PRE_first_tail_x8_r0_body.st154.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st154.ks 0).getD 0) PRE_first_tail_x8_r0_body.st154.s0 PRE_first_tail_x8_r0_body.st154.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st154.s1, PRE_first_tail_x8_r0_body.st154.S1)
theorem PRE_first_tail_x8_r0_body.st154.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st154.F (PRE_first_tail_x8_r0_body.st154.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st154.ks 0).getD 0) PRE_first_tail_x8_r0_body.st154.s0 PRE_first_tail_x8_r0_body.st154.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st154.s1, PRE_first_tail_x8_r0_body.st154.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st154.bodyOkLN_ok PRE_first_tail_x8_r0_body.st154.bodyK0F
end Host.Load.Run.Tpl
end

section -- st154/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st154.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st154.F (PRE_first_tail_x8_r0_body.st154.bodyOkL bytes rows) 27 PRE_first_tail_x8_r0_body.st154.s0 PRE_first_tail_x8_r0_body.st154.S0 = some (PRE_first_tail_x8_r0_body.st154.s1, PRE_first_tail_x8_r0_body.st154.S1) :=
  (congrFun (congrFun PRE_first_tail_x8_r0_body.st154.bodyK0 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st154.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st154.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st154.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st154.F (PRE_first_tail_x8_r0_body.st154.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st154.s0
  S0 := PRE_first_tail_x8_r0_body.st154.S0
  s1 := PRE_first_tail_x8_r0_body.st154.s1
  S1 := PRE_first_tail_x8_r0_body.st154.S1
  s2 := PRE_first_tail_x8_r0_body.st154.s2
  S2 := PRE_first_tail_x8_r0_body.st154.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st154.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st154.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st154.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st154.bodyHalt
  last := PRE_first_tail_x8_r0_body.st154.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st154.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC155
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 155 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1496` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa155` into the merged state
`PRE_first_tail_x8_r0_body.s1495`. -/

def PRE_first_tail_x8_r0_body.pl155 : List Nat := [2796395]
def PRE_first_tail_x8_r0_body.nr155 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd155 : RData :=
  ⟨2796386, 2796396, Stage.setAll PTrie.nil [(2796385, 2796395)], Stage.setAll PTrie.nil [],
   21249, 21249, 18340, 18340, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa155 : Map :=
  Conv.Map.compact 2796385 2796396 6679 PRE_first_tail_x8_r0_body.pl155 (PRE_first_tail_x8_r0_body.nr155.map NumV.ref) PRE_first_tail_x8_r0_body.kd155.big
    PRE_first_tail_x8_r0_body.kd155.region PRE_first_tail_x8_r0_body.kd155.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws155 : List Nat := []
noncomputable def PRE_first_tail_x8_r0_body.crs155 : List SymE := PRE_first_tail_x8_r0_body.nr155.map fun r => (nth? PRE_first_tail_x8_r0_body.S1495.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta155 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws155 PRE_first_tail_x8_r0_body.crs155
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB155 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x8_r0_body.ctab155 : PRE_first_tail_x8_r0_body.S1496.tab = PRE_first_tail_x8_r0_body.S1494.tab ++ PRE_first_tail_x8_r0_body.cws155.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace155 : PRE_first_tail_x8_r0_body.s1496.trace = PRE_first_tail_x8_r0_body.s1494.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext155 : PRE_first_tail_x8_r0_body.s1496.next = 2796386
kernel_rfl PRE_first_tail_x8_r0_body.ccounters155 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1496.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1496.ffi).mlx.nnext) = (21249, 18340)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue155 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1495.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1496.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa155.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp155 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1496.ffi).mlx.tokens.all (bSN 6679) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean155 : Conv.cleanListB 21249 131072 (fun r => Nat.ble 84996 r) PRE_first_tail_x8_r0_body.s1496
    (PRE_first_tail_x8_r0_body.wrB155 ++ (List.range 1).map (2796385 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs155 : bigsOutB 21249 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1496.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK155
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl155`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl155 : List Nat := [2665, 2673467, 2796385]
def PRE_first_tail_x8_r0_body.clo155 : List Nat := []
def PRE_first_tail_x8_r0_body.cln155 : List Nat := []
def PRE_first_tail_x8_r0_body.cli155 : List Nat := []
kernel_rfl PRE_first_tail_x8_r0_body.cheap155 : PRE_first_tail_x8_r0_body.s1496.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1494.heap (PRE_first_tail_x8_r0_body.cl155.filterMap fun a => (PRE_first_tail_x8_r0_body.s1496.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe155 : Nat.ble PRE_first_tail_x8_r0_body.s1494.next PRE_first_tail_x8_r0_body.s1496.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP155 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1494 PRE_first_tail_x8_r0_body.s1496 PRE_first_tail_x8_r0_body.cl155 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp155 : Conv.suppListB PRE_first_tail_x8_r0_body.s1496 6679 PRE_first_tail_x8_r0_body.cl155 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound155 : Conv.boundListB PRE_first_tail_x8_r0_body.s1496 PRE_first_tail_x8_r0_body.cl155 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK155 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1496.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln155.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1496.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK155 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1496.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo155.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1496.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK155 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1496.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli155.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1496.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst155 : Conv.sstListB 6679 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1496.ffi).mlx PRE_first_tail_x8_r0_body.cln155 PRE_first_tail_x8_r0_body.clo155 PRE_first_tail_x8_r0_body.cli155 = true

end Host.Load.Run.Tpl
end

section -- SiteCl155
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA155 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1496.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo155.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1496.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd155 : (PRE_first_tail_x8_r0_body.clo155 ++ PRE_first_tail_x8_r0_body.cln155 ++ PRE_first_tail_x8_r0_body.cli155).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle155 : Conv.Cnt.leB (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt) (⟨21249, 18340, 2796386, 6679⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck155 : Conv.ncleanListB (⟨21249, 18340, 2796386, 6679⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1496.ffi).mlx PRE_first_tail_x8_r0_body.clo155 PRE_first_tail_x8_r0_body.cln155 PRE_first_tail_x8_r0_body.cli155 = true
theorem PRE_first_tail_x8_r0_body.cncl155 (h : Conv.NClean (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx) : Conv.NClean (⟨21249, 18340, 2796386, 6679⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1496.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle155 PRE_first_tail_x8_r0_body.ckA155 PRE_first_tail_x8_r0_body.cobjsK155 PRE_first_tail_x8_r0_body.cnodesK155 PRE_first_tail_x8_r0_body.citemsK155 PRE_first_tail_x8_r0_body.cbd155 PRE_first_tail_x8_r0_body.cck155

end Host.Load.Run.Tpl
end

section -- SiteS155
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 155 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc155 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P155 : LoadP := PRE_first_tail_x8_r0_body.Pc155.raise 18340
kernel_rfl PRE_first_tail_x8_r0_body.craise155 : Nat.ble PRE_first_tail_x8_r0_body.Pc155.N0 18340 = true
theorem PRE_first_tail_x8_r0_body.raised155 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc155 PRE_first_tail_x8_r0_body.P155 :=
  .inr ⟨18340, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise155, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_155 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1496.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_155 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1495.ffi)
def PRE_first_tail_x8_r0_body.khinv155 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x8_r0_body.kninv155 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS155 : List Nat := []
def PRE_first_tail_x8_r0_body.cnS155 : List Nat := List.range' 18340 0
def PRE_first_tail_x8_r0_body.ciS155 : List Nat := [] ++ List.range' 18340 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0155 : PRE_first_tail_x8_r0_body.kd155.nh0 = PRE_first_tail_x8_r0_body.cx0_155.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1155 : PRE_first_tail_x8_r0_body.kd155.nh1 = PRE_first_tail_x8_r0_body.cx1_155.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0155 : PRE_first_tail_x8_r0_body.kd155.nn0 = PRE_first_tail_x8_r0_body.cx0_155.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1155 : PRE_first_tail_x8_r0_body.kd155.nn1 = PRE_first_tail_x8_r0_body.cx1_155.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo155 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P155.lo && Nat.ble PRE_first_tail_x8_r0_body.P155.lo PRE_first_tail_x8_r0_body.cx0_155.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P155.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P155.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt155 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_155.mlx.next PRE_first_tail_x8_r0_body.cx1_155.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_155.mlx.nnext PRE_first_tail_x8_r0_body.cx1_155.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband155 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P155.NL && Nat.ble PRE_first_tail_x8_r0_body.P155.NL PRE_first_tail_x8_r0_body.P155.N0 && Nat.ble PRE_first_tail_x8_r0_body.P155.N0 PRE_first_tail_x8_r0_body.cx0_155.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow155 : PRE_first_tail_x8_r0_body.kd155.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren155 : checkRenG PRE_first_tail_x8_r0_body.kd155.hnd PRE_first_tail_x8_r0_body.khinv155 (phB PRE_first_tail_x8_r0_body.cx0_155.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband155 : PRE_first_tail_x8_r0_body.kd155.checkBand PRE_first_tail_x8_r0_body.P155.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos155 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd155.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren155 : checkRenG PRE_first_tail_x8_r0_body.kd155.node PRE_first_tail_x8_r0_body.kninv155 (pnB PRE_first_tail_x8_r0_body.cx0_155.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow155 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd155.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P155.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd155.nodeF j) PRE_first_tail_x8_r0_body.cx1_155.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a155 : PRE_first_tail_x8_r0_body.cx0_155.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b155 : PRE_first_tail_x8_r0_body.cx0_155.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1155 : PRE_first_tail_x8_r0_body.cx1_155.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend155 : PRE_first_tail_x8_r0_body.cx1_155.mlx.pending = PRE_first_tail_x8_r0_body.cx0_155.mlx.pending.map PRE_first_tail_x8_r0_body.kappa155.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh155 : PRE_first_tail_x8_r0_body.cx1_155.mlx.errh = PRE_first_tail_x8_r0_body.cx0_155.mlx.errh.map PRE_first_tail_x8_r0_body.kappa155.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles155 : PRE_first_tail_x8_r0_body.cx1_155.mlx.files = PRE_first_tail_x8_r0_body.cx0_155.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch155 : PRE_first_tail_x8_r0_body.cx1_155.mlx.arch = PRE_first_tail_x8_r0_body.cx0_155.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes155 : PRE_first_tail_x8_r0_body.cx1_155.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_155.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired155 : PRE_first_tail_x8_r0_body.cx1_155.mlx.wired = PRE_first_tail_x8_r0_body.cx0_155.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost155 : PRE_first_tail_x8_r0_body.cx1_155.host = PRE_first_tail_x8_r0_body.cx0_155.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd155`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0155 : PRE_first_tail_x8_r0_body.kd155.n0 = 2796386
kernel_rfl PRE_first_tail_x8_r0_body.ckn1155 : PRE_first_tail_x8_r0_body.kd155.n1 = 2796396
kernel_rfl PRE_first_tail_x8_r0_body.ckheap155 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd155.heap).all (fun x => Nat.ble 2796385 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl155 : (List.range 1).all (fun j => decide (PRE_first_tail_x8_r0_body.kd155.heap.get (2796385 + j) = nth? PRE_first_tail_x8_r0_body.pl155 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja155 : Nat.ble 2796385 2796385 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn155 : Nat.ble 6679 6679 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD155 : Nat.ble 2796385 PRE_first_tail_x8_r0_body.kd155.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn155 : Nat.ble 21249 PRE_first_tail_x8_r0_body.kd155.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn155 : Nat.ble 18340 PRE_first_tail_x8_r0_body.kd155.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb155 : Nat.ble 21249 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap155 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd155.heap).all (Nat.ble (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd155 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd155.hnd).all (Nat.ble (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode155 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd155.node).all (Nat.ble (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix155 : Conv.FixOld (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa155 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja155) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn155) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD155) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn155) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn155) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb155) PRE_first_tail_x8_r0_body.fheap155 PRE_first_tail_x8_r0_body.fhnd155 PRE_first_tail_x8_r0_body.fnode155
kernel_rfl PRE_first_tail_x8_r0_body.fcxn155 : (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn155 : (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0155 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_155.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_155.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk155 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd155.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A155 : PRE_first_tail_x8_r0_body.cx1_155.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS155.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_155.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O155 : PRE_first_tail_x8_r0_body.cx1_155.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS155.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_155.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N155 : PRE_first_tail_x8_r0_body.cx1_155.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS155.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_155.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I155 : PRE_first_tail_x8_r0_body.cx1_155.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS155.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_155.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd155 : (PRE_first_tail_x8_r0_body.clo155 ++ PRE_first_tail_x8_r0_body.cln155 ++ PRE_first_tail_x8_r0_body.cli155 ++ PRE_first_tail_x8_r0_body.cwS155 ++ PRE_first_tail_x8_r0_body.cnS155 ++ PRE_first_tail_x8_r0_body.ciS155).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW155 : PRE_first_tail_x8_r0_body.cwS155.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo155.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI155 : PRE_first_tail_x8_r0_body.ciS155.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli155.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN155 : PRE_first_tail_x8_r0_body.cnS155.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF155 : PRE_first_tail_x8_r0_body.cln155.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh155 : PRE_first_tail_x8_r0_body.clo155.all (handleOK PRE_first_tail_x8_r0_body.kappa155 PRE_first_tail_x8_r0_body.P155.lo PRE_first_tail_x8_r0_body.cx0_155.mlx PRE_first_tail_x8_r0_body.cx1_155.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo155 : PRE_first_tail_x8_r0_body.clo155.map (fun h => PRE_first_tail_x8_r0_body.cx1_155.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa155.handle h)) = PRE_first_tail_x8_r0_body.clo155.map (fun h => (PRE_first_tail_x8_r0_body.cx0_155.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa155.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok155 : PRE_first_tail_x8_r0_body.clo155.all (objOK PRE_first_tail_x8_r0_body.kappa155 PRE_first_tail_x8_r0_body.P155.NL PRE_first_tail_x8_r0_body.cx0_155.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd155 : PRE_first_tail_x8_r0_body.cln155.all (nodeOKF PRE_first_tail_x8_r0_body.kappa155 PRE_first_tail_x8_r0_body.P155 PRE_first_tail_x8_r0_body.cx0_155.mlx PRE_first_tail_x8_r0_body.cx1_155.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp155 : ((PRE_first_tail_x8_r0_body.cln155.filter (fullB PRE_first_tail_x8_r0_body.P155))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_155.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa155.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln155.filter (fullB PRE_first_tail_x8_r0_body.P155))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_155.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa155.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI155 : incrB PRE_first_tail_x8_r0_body.kd155.nodeF (List.range' 18340 0) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK155 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd155.node).all (fun k => Nat.ble 18340 k && Nat.blt k 18340) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL155 : (PRE_first_tail_x8_r0_body.cln155.filter (Nat.ble PRE_first_tail_x8_r0_body.P155.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd155.nodeF i) && (Nat.blt i 18340 || Nat.ble PRE_first_tail_x8_r0_body.kd155.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord155 : (PRE_first_tail_x8_r0_body.cln155.filter (Nat.ble PRE_first_tail_x8_r0_body.P155.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd155.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd155.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd155.nodeF j) (PRE_first_tail_x8_r0_body.kd155.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow155 PRE_first_tail_x8_r0_body.cnn1155 PRE_first_tail_x8_r0_body.fnordI155 PRE_first_tail_x8_r0_body.fnordK155 PRE_first_tail_x8_r0_body.fnordL155
kernel_rfl PRE_first_tail_x8_r0_body.fi155 : PRE_first_tail_x8_r0_body.cli155.all (pnB PRE_first_tail_x8_r0_body.cx0_155.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii155 : PRE_first_tail_x8_r0_body.cli155.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_155.mlx.items.get (PRE_first_tail_x8_r0_body.kappa155.node k) = (PRE_first_tail_x8_r0_body.cx0_155.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa155.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot155 (clean : Conv.NClean (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P155.NL) (cl : SSt (· < 6679) PRE_first_tail_x8_r0_body.cx0_155.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P155 6679 PRE_first_tail_x8_r0_body.kappa155 PRE_first_tail_x8_r0_body.kd155 PRE_first_tail_x8_r0_body.khinv155 PRE_first_tail_x8_r0_body.kninv155 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx PRE_first_tail_x8_r0_body.cx0_155.mlx PRE_first_tail_x8_r0_body.cx1_155.mlx (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo155 PRE_first_tail_x8_r0_body.cln155 PRE_first_tail_x8_r0_body.cli155 PRE_first_tail_x8_r0_body.cwS155 PRE_first_tail_x8_r0_body.cnS155 PRE_first_tail_x8_r0_body.ciS155 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0155, PRE_first_tail_x8_r0_body.cnh1155, PRE_first_tail_x8_r0_body.cnn0155, PRE_first_tail_x8_r0_body.cnn1155, PRE_first_tail_x8_r0_body.cplo155, PRE_first_tail_x8_r0_body.ccnt155, PRE_first_tail_x8_r0_body.cnband155, PRE_first_tail_x8_r0_body.chbelow155, PRE_first_tail_x8_r0_body.chren155, PRE_first_tail_x8_r0_body.cband155, PRE_first_tail_x8_r0_body.cnh1pos155, PRE_first_tail_x8_r0_body.cnren155, PRE_first_tail_x8_r0_body.cnlow155, PRE_first_tail_x8_r0_body.cabs0a155, PRE_first_tail_x8_r0_body.cabs0b155, PRE_first_tail_x8_r0_body.ctok1155, PRE_first_tail_x8_r0_body.cpend155, PRE_first_tail_x8_r0_body.cerrh155, PRE_first_tail_x8_r0_body.cfiles155, PRE_first_tail_x8_r0_body.carch155, PRE_first_tail_x8_r0_body.csizes155, PRE_first_tail_x8_r0_body.cwired155, PRE_first_tail_x8_r0_body.cfix155, clean, PRE_first_tail_x8_r0_body.fcxn155, PRE_first_tail_x8_r0_body.fcnn155, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0155, PRE_first_tail_x8_r0_body.fnk155, PRE_first_tail_x8_r0_body.ckA155, PRE_first_tail_x8_r0_body.cobjsK155, PRE_first_tail_x8_r0_body.cnodesK155, PRE_first_tail_x8_r0_body.citemsK155, PRE_first_tail_x8_r0_body.f1A155, PRE_first_tail_x8_r0_body.f1O155, PRE_first_tail_x8_r0_body.f1N155, PRE_first_tail_x8_r0_body.f1I155, PRE_first_tail_x8_r0_body.fbd155, PRE_first_tail_x8_r0_body.fincW155, PRE_first_tail_x8_r0_body.fincI155, PRE_first_tail_x8_r0_body.fincN155, PRE_first_tail_x8_r0_body.flnF155, PRE_first_tail_x8_r0_body.fh155, PRE_first_tail_x8_r0_body.fo155, PRE_first_tail_x8_r0_body.fok155, PRE_first_tail_x8_r0_body.fnd155, PRE_first_tail_x8_r0_body.fp155, PRE_first_tail_x8_r0_body.fnord155, PRE_first_tail_x8_r0_body.fi155, PRE_first_tail_x8_r0_body.fii155⟩
theorem PRE_first_tail_x8_r0_body.cnshift155 (clean : Conv.NClean (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P155.NL) (cl : SSt (· < 6679) PRE_first_tail_x8_r0_body.cx0_155.mlx) : NShift PRE_first_tail_x8_r0_body.P155 6679 PRE_first_tail_x8_r0_body.kappa155 PRE_first_tail_x8_r0_body.cx0_155 PRE_first_tail_x8_r0_body.cx1_155 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot155 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost155 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0155 PRE_first_tail_x8_r0_body.ckn1155 PRE_first_tail_x8_r0_body.ckheap155 PRE_first_tail_x8_r0_body.ckpl155)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_155 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1494.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_155 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1494.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_155 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1494.ffi) = some PRE_first_tail_x8_r0_body.fxC_155
kernel_rfl PRE_first_tail_x8_r0_body.okrC_155 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1494.ffi) = some PRE_first_tail_x8_r0_body.krC_155
noncomputable def PRE_first_tail_x8_r0_body.fx0_155 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1496.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_155 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1496.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_155 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1496.ffi) = some PRE_first_tail_x8_r0_body.fx0_155
kernel_rfl PRE_first_tail_x8_r0_body.okr0_155 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1496.ffi) = some PRE_first_tail_x8_r0_body.kr0_155
noncomputable def PRE_first_tail_x8_r0_body.fx1_155 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1495.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_155 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1495.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_155 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1495.ffi) = some PRE_first_tail_x8_r0_body.fx1_155
kernel_rfl PRE_first_tail_x8_r0_body.okr1_155 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1495.ffi) = some PRE_first_tail_x8_r0_body.kr1_155
kernel_rfl PRE_first_tail_x8_r0_body.ff0155 : PRE_first_tail_x8_r0_body.fx0_155 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_155 (PRE_first_tail_x8_r0_body.clo155.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_155.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1155 : PRE_first_tail_x8_r0_body.fx1_155 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_155 (PRE_first_tail_x8_r0_body.cwS155.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_155.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck155 : freedLB PRE_first_tail_x8_r0_body.kappa155 PRE_first_tail_x8_r0_body.cx0_155.mlx PRE_first_tail_x8_r0_body.fx0_155 PRE_first_tail_x8_r0_body.fx1_155 PRE_first_tail_x8_r0_body.clo155 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0155 : PRE_first_tail_x8_r0_body.kr0_155.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_155.flags (PRE_first_tail_x8_r0_body.clo155.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_155.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0155 : PRE_first_tail_x8_r0_body.kr0_155.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_155.targs (PRE_first_tail_x8_r0_body.clo155.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_155.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1155 : PRE_first_tail_x8_r0_body.kr1_155.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_155.flags (PRE_first_tail_x8_r0_body.cwS155.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_155.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1155 : PRE_first_tail_x8_r0_body.kr1_155.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_155.targs (PRE_first_tail_x8_r0_body.cwS155.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_155.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck155 : krecLB PRE_first_tail_x8_r0_body.kappa155 6679 PRE_first_tail_x8_r0_body.cx0_155.mlx PRE_first_tail_x8_r0_body.kr0_155 PRE_first_tail_x8_r0_body.kr1_155 PRE_first_tail_x8_r0_body.clo155 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn155 : Nat.ble 6679 6679 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge155 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1495.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1496.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR155 : pendRegB PRE_first_tail_x8_r0_body.kappa155 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1496.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe155 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1496.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1495.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift155 (clean : Conv.NClean (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P155.NL) (cl : SSt (· < 6679) PRE_first_tail_x8_r0_body.cx0_155.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_155.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_155.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_155.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1494.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_155.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P155 6679 PRE_first_tail_x8_r0_body.kappa155 PRE_first_tail_x8_r0_body.s1496.ffi PRE_first_tail_x8_r0_body.s1495.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift155 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue155, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp155 t ht),
    PRE_first_tail_x8_r0_body.cbridge155,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1496.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1495.ffi) (PRE_first_tail_x8_r0_body.cfoot155 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_155 PRE_first_tail_x8_r0_body.ofx1_155 hobjC PRE_first_tail_x8_r0_body.ff0155 PRE_first_tail_x8_r0_body.ff1155 PRE_first_tail_x8_r0_body.ffck155,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1496.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1495.ffi) (PRE_first_tail_x8_r0_body.cfoot155 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_155 PRE_first_tail_x8_r0_body.okr1_155 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn155) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0155 PRE_first_tail_x8_r0_body.fkt0155 PRE_first_tail_x8_r0_body.fkf1155 PRE_first_tail_x8_r0_body.fkt1155 PRE_first_tail_x8_r0_body.fkck155,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0155 PRE_first_tail_x8_r0_body.cnh1155 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe155) PRE_first_tail_x8_r0_body.cpendR155⟩

end Host.Load.Run.Tpl
end

section -- st155/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st155 0
host_stream_state PRE_first_tail_x8_r0_body.st155 1
host_stream_state PRE_first_tail_x8_r0_body.st155 2
end Host.Load.Run.Tpl
end

section -- Site155
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 155 of chain `PRE_first_tail_x8_r0_body`: `plan__g155__g156` (`plan`), the call state `PRE_first_tail_x8_r0_body.s1494`, the merged state `PRE_first_tail_x8_r0_body.s1495`,
the site template `PRE_first_tail_x8_r0_body.st155` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1496`: the merge.
The footprint's facts are in `SiteF155`, the compaction's in `SiteC155`, `SiteK155`, `SiteNa155`, `SiteNb155`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso155 : PRE_first_tail_x8_r0_body.st155.s0 = { PRE_first_tail_x8_r0_body.s1494 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs155 : List Frame := PRE_first_tail_x8_r0_body.s1494.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_155 : PRE_first_tail_x8_r0_body.S1494.tab.length = 6679
kernel_rfl PRE_first_tail_x8_r0_body.tab0_155 : PRE_first_tail_x8_r0_body.st155.S0.tab = PRE_first_tail_x8_r0_body.S1494.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws155 : List Nat := [3602, 3603, 3604]
kernel_rfl PRE_first_tail_x8_r0_body.fresh155 : (PRE_first_tail_x8_r0_body.S1494.tab.all fun e => PRE_first_tail_x8_r0_body.ws155.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1494.oracle.all fun q => PRE_first_tail_x8_r0_body.ws155.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab155 : PRE_first_tail_x8_r0_body.S1495.tab = PRE_first_tail_x8_r0_body.S1494.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws155
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen155 : PRE_first_tail_x8_r0_body.st155.S2.tab.length - PRE_first_tail_x8_r0_body.st155.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged155`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap155 : PRE_first_tail_x8_r0_body.s1495.heap = PRE_first_tail_x8_r0_body.st155.s2.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext155 : PRE_first_tail_x8_r0_body.s1495.next = PRE_first_tail_x8_r0_body.st155.s2.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl155 : PRE_first_tail_x8_r0_body.s1495.ctl = PRE_first_tail_x8_r0_body.st155.s2.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack155 : PRE_first_tail_x8_r0_body.s1495.stack = PRE_first_tail_x8_r0_body.st155.s2.stack ++ PRE_first_tail_x8_r0_body.s1494.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs155 : PRE_first_tail_x8_r0_body.s1495.jobs = PRE_first_tail_x8_r0_body.st155.s2.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi155 : PRE_first_tail_x8_r0_body.s1495.ffi = PRE_first_tail_x8_r0_body.st155.s2.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace155 : PRE_first_tail_x8_r0_body.s1495.trace = PRE_first_tail_x8_r0_body.st155.s2.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores155 : PRE_first_tail_x8_r0_body.s1495.stores = PRE_first_tail_x8_r0_body.st155.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD155
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 155 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived155 : PRE_first_tail_x8_r0_body.nr155.map (fun r => nth? PRE_first_tail_x8_r0_body.st155.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo155 : PRE_first_tail_x8_r0_body.nr155.all (Nat.ble 6679) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj155 : PRE_first_tail_x8_r0_body.cws155.all (fun c => !PRE_first_tail_x8_r0_body.ws155.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ155 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws155 PRE_first_tail_x8_r0_body.crs155 PRE_first_tail_x8_r0_body.ws155

end Host.Load.Run.Tpl
end

section -- st155/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st155`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st155.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st155.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st155.s2.heap PRE_first_tail_x8_r0_body.st155.wrR ++ freshOf PRE_first_tail_x8_r0_body.st155.s2.heap PRE_first_tail_x8_r0_body.st155.s0.next PRE_first_tail_x8_r0_body.st155.s2.next
noncomputable def PRE_first_tail_x8_r0_body.st155.wr : List Nat := PRE_first_tail_x8_r0_body.st155.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st155.heapFoot : PRE_first_tail_x8_r0_body.st155.s2.heap = setAll PRE_first_tail_x8_r0_body.st155.s0.heap PRE_first_tail_x8_r0_body.st155.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st155.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st155.s0.next PRE_first_tail_x8_r0_body.st155.s2.next = true
theorem PRE_first_tail_x8_r0_body.st155.grows : PRE_first_tail_x8_r0_body.st155.s0.next ≤ PRE_first_tail_x8_r0_body.st155.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st155.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st155.wh : List Nat := []
def PRE_first_tail_x8_r0_body.st155.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st155.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st155.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st155.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st155.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st155.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st155.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st155.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st155.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st155.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st155.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st155.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st155.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st155.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st155.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st155.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st155.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st155.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st155.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st155.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st155.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st155.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st155.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st155.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st155.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st155.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st155.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st155.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st155.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st155.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF155
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 155 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB155 : nodupT PRE_first_tail_x8_r0_body.st155.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup155 : PRE_first_tail_x8_r0_body.st155.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB155).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB155 : PRE_first_tail_x8_r0_body.st155.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound155 : ∀ b ∈ PRE_first_tail_x8_r0_body.st155.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB155 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr155 := PRE_first_tail_x8_r0_body.st155.s2.trace.take 0
kernel_rfl PRE_first_tail_x8_r0_body.traceEq155 : PRE_first_tail_x8_r0_body.st155.s2.trace = PRE_first_tail_x8_r0_body.trFr155 ++ PRE_first_tail_x8_r0_body.st155.s0.trace
theorem PRE_first_tail_x8_r0_body.trace155 : ∃ fr, PRE_first_tail_x8_r0_body.st155.s2.trace = fr ++ PRE_first_tail_x8_r0_body.st155.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq155⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide155 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB155 : (PRE_first_tail_x8_r0_body.wide155.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st155.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix155 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide155, WFix Map.id (Present PRE_first_tail_x8_r0_body.st155.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB155 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL155
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 155 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1495`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO155 : PRE_first_tail_x8_r0_body.st155.S0.oracle = PRE_first_tail_x8_r0_body.st155.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B155 : PRE_first_tail_x8_r0_body.st155.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st155.s0.next || (PRE_first_tail_x8_r0_body.st155.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot155 : Conv.StageFoot PRE_first_tail_x8_r0_body.st155.wr PRE_first_tail_x8_r0_body.st155.s0 PRE_first_tail_x8_r0_body.st155.s2 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st155.heapFoot PRE_first_tail_x8_r0_body.wrNodup155 PRE_first_tail_x8_r0_body.wrBound155 PRE_first_tail_x8_r0_body.wr0B155 PRE_first_tail_x8_r0_body.st155.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged155 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st155.F.S → PRE_first_tail_x8_r0_body.st155.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st155.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st155.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs155 PRE_first_tail_x8_r0_body.st155.wr PRE_first_tail_x8_r0_body.s1494 PRE_first_tail_x8_r0_body.st155.s2 PRE_first_tail_x8_r0_body.st155.s0
      PRE_first_tail_x8_r0_body.st155.s2.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st155.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1495 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso155 PRE_first_tail_x8_r0_body.stFoot155 PRE_first_tail_x8_r0_body.wrNodup155 PRE_first_tail_x8_r0_body.wrBound155 PRE_first_tail_x8_r0_body.trace155 PRE_first_tail_x8_r0_body.mheap155
    PRE_first_tail_x8_r0_body.mnext155 PRE_first_tail_x8_r0_body.mctl155 PRE_first_tail_x8_r0_body.mstack155 PRE_first_tail_x8_r0_body.mjobs155 PRE_first_tail_x8_r0_body.mffi155 PRE_first_tail_x8_r0_body.mtrace155 PRE_first_tail_x8_r0_body.mstores155 h

def PRE_first_tail_x8_r0_body.arrEl155_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE155_2665 : arrOf PRE_first_tail_x8_r0_body.s1495 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl155_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA155_2665 : isArrB PRE_first_tail_x8_r0_body.s1495 2665 = true
theorem PRE_first_tail_x8_r0_body.arr155_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1495.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl155_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE155_2665 PRE_first_tail_x8_r0_body.arrA155_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN155_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl155_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR155_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl155_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN155_2665

def PRE_first_tail_x8_r0_body.arrEl155_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE155_2673467 : arrOf PRE_first_tail_x8_r0_body.s1495 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl155_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA155_2673467 : isArrB PRE_first_tail_x8_r0_body.s1495 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr155_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1495.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl155_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE155_2673467 PRE_first_tail_x8_r0_body.arrA155_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN155_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl155_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR155_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl155_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN155_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k155 : isArrB PRE_first_tail_x8_r0_body.s1495 4910 = false
theorem PRE_first_tail_x8_r0_body.keep155 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1495 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k155 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr155_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl155_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ155
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 155 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1494`, the merged
state `PRE_first_tail_x8_r0_body.s1495`, the canonical state `PRE_first_tail_x8_r0_body.s1496`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl155 : PRE_first_tail_x8_r0_body.pl155.all (Nat.ble PRE_first_tail_x8_r0_body.s1494.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd155 : nodupT PRE_first_tail_x8_r0_body.pl155 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1155 : Nat.ble PRE_first_tail_x8_r0_body.s1494.next 2796396 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst155 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1494.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn155 : PRE_first_tail_x8_r0_body.s1496.next = PRE_first_tail_x8_r0_body.s1494.next + PRE_first_tail_x8_r0_body.pl155.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn155 : PRE_first_tail_x8_r0_body.s1495.next = 2796396
kernel_rfl PRE_first_tail_x8_r0_body.zgrow155 : Nat.ble PRE_first_tail_x8_r0_body.s1496.next PRE_first_tail_x8_r0_body.s1495.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh155 : PRE_first_tail_x8_r0_body.S1494.tab.all (fun e => PRE_first_tail_x8_r0_body.cws155.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd155 : nodupT PRE_first_tail_x8_r0_body.cws155 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi155 : PRE_first_tail_x8_r0_body.nr155.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1495.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt155 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1494.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg155_2665 : PRE_first_tail_x8_r0_body.s1496.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1496 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk155_2665 : (objOf PRE_first_tail_x8_r0_body.s1496 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm155_2665 : PRE_first_tail_x8_r0_body.s1495.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa155.obj (objOf PRE_first_tail_x8_r0_body.s1496 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1495 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg155_2673467 : PRE_first_tail_x8_r0_body.s1496.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1496 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk155_2673467 : (objOf PRE_first_tail_x8_r0_body.s1496 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm155_2673467 : PRE_first_tail_x8_r0_body.s1495.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa155.obj (objOf PRE_first_tail_x8_r0_body.s1496 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1495 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw155_4910 : (PRE_first_tail_x8_r0_body.s1496.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw155_2673472 : (PRE_first_tail_x8_r0_body.s1496.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw155_2673473 : (PRE_first_tail_x8_r0_body.s1496.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd155 : PRE_first_tail_x8_r0_body.cl155.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr155 : PRE_first_tail_x8_r0_body.st155.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1494.next || PRE_first_tail_x8_r0_body.cl155.contains b) = true
def PRE_first_tail_x8_r0_body.zl155 : List Nat := PRE_first_tail_x8_r0_body.cl155.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE155 : PRE_first_tail_x8_r0_body.zl155.map (fun a => PRE_first_tail_x8_r0_body.s1495.heap.get (PRE_first_tail_x8_r0_body.kappa155.a a)) = PRE_first_tail_x8_r0_body.zl155.map (fun a => (PRE_first_tail_x8_r0_body.s1496.heap.get a).map PRE_first_tail_x8_r0_body.kappa155.hobj)
theorem PRE_first_tail_x8_r0_body.zimg155 : HeapImg PRE_first_tail_x8_r0_body.kappa155 PRE_first_tail_x8_r0_body.s1496 PRE_first_tail_x8_r0_body.s1495 PRE_first_tail_x8_r0_body.zl155 := PRE_first_tail_x8_r0_body.zimgE155
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl155 : PRE_first_tail_x8_r0_body.s1495.ctl = PRE_first_tail_x8_r0_body.kappa155.ctl PRE_first_tail_x8_r0_body.s1496.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack155 : PRE_first_tail_x8_r0_body.s1495.stack = PRE_first_tail_x8_r0_body.s1496.stack.map PRE_first_tail_x8_r0_body.kappa155.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs155 : PRE_first_tail_x8_r0_body.s1495.jobs = PRE_first_tail_x8_r0_body.s1496.jobs.map PRE_first_tail_x8_r0_body.kappa155.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores155 : PRE_first_tail_x8_r0_body.s1495.stores = PRE_first_tail_x8_r0_body.kappa155.stores PRE_first_tail_x8_r0_body.s1496.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots155 : checkRootsSupp PRE_first_tail_x8_r0_body.s1496 6679 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC155 : PRE_first_tail_x8_r0_body.S1494.tab.length + PRE_first_tail_x8_r0_body.cws155.length = 6679
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap155 : PRE_first_tail_x8_r0_body.kappa155 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1494.next 2796396 PRE_first_tail_x8_r0_body.S1494.tab.length PRE_first_tail_x8_r0_body.pl155 (PRE_first_tail_x8_r0_body.nr155.map NumV.ref) PRE_first_tail_x8_r0_body.kd155.big
  PRE_first_tail_x8_r0_body.kd155.region PRE_first_tail_x8_r0_body.kd155.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin155 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1496.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc155 : Conv.jcleanListB (⟨21249, 18340, 2796386, 6679⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1496 PRE_first_tail_x8_r0_body.cl155 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB155 : noBigRootsP (fun i => !Conv.oldBigB (⟨21249, 18340, 2796386, 6679⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1496.trace PRE_first_tail_x8_r0_body.s1496 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm155 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 18340 = true
theorem PRE_first_tail_x8_r0_body.cjcl155 (h : Conv.JClean (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1494) : Conv.JClean (⟨21249, 18340, 2796386, 6679⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1496 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle155)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap155 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd155 a ha)) PRE_first_tail_x8_r0_body.zjc155

end Host.Load.Run.Tpl
end

section -- st155/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st155.bodyLast from PRE_first_tail_x8_r0_body.st155.s1 to PRE_first_tail_x8_r0_body.st155.s2 :
  interpS (step PRE_first_tail_x8_r0_body.st155.F PRE_first_tail_x8_r0_body.st155.s1).run PRE_first_tail_x8_r0_body.st155.S1 = some (PRE_first_tail_x8_r0_body.st155.s2, PRE_first_tail_x8_r0_body.st155.S2)
kernel_rfl PRE_first_tail_x8_r0_body.st155.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st155.s1.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st155.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st155.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st155/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st155.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st155.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st155.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st155.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st155.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st155.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st155.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st155.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st155.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st155.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st155.s0 PRE_first_tail_x8_r0_body.st155.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st155.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st155.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st155.s1 PRE_first_tail_x8_r0_body.st155.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st155/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st155.bodyK0F from PRE_first_tail_x8_r0_body.st155.s0 to PRE_first_tail_x8_r0_body.st155.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st155.F (PRE_first_tail_x8_r0_body.st155.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st155.ks 0).getD 0) PRE_first_tail_x8_r0_body.st155.s0 PRE_first_tail_x8_r0_body.st155.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st155.s1, PRE_first_tail_x8_r0_body.st155.S1)
theorem PRE_first_tail_x8_r0_body.st155.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st155.F (PRE_first_tail_x8_r0_body.st155.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st155.ks 0).getD 0) PRE_first_tail_x8_r0_body.st155.s0 PRE_first_tail_x8_r0_body.st155.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st155.s1, PRE_first_tail_x8_r0_body.st155.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st155.bodyOkLN_ok PRE_first_tail_x8_r0_body.st155.bodyK0F
end Host.Load.Run.Tpl
end

section -- st155/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st155.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st155.F (PRE_first_tail_x8_r0_body.st155.bodyOkL bytes rows) 98 PRE_first_tail_x8_r0_body.st155.s0 PRE_first_tail_x8_r0_body.st155.S0 = some (PRE_first_tail_x8_r0_body.st155.s1, PRE_first_tail_x8_r0_body.st155.S1) :=
  (congrFun (congrFun PRE_first_tail_x8_r0_body.st155.bodyK0 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st155.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st155.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st155.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st155.F (PRE_first_tail_x8_r0_body.st155.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st155.s0
  S0 := PRE_first_tail_x8_r0_body.st155.S0
  s1 := PRE_first_tail_x8_r0_body.st155.s1
  S1 := PRE_first_tail_x8_r0_body.st155.S1
  s2 := PRE_first_tail_x8_r0_body.st155.s2
  S2 := PRE_first_tail_x8_r0_body.st155.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st155.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st155.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st155.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st155.bodyHalt
  last := PRE_first_tail_x8_r0_body.st155.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st155.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC156
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 156 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1513` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa156` into the merged state
`PRE_first_tail_x8_r0_body.s1512`. -/

def PRE_first_tail_x8_r0_body.pl156 : List Nat := [2798991, 2798166, 2798997, 2798993, 2798168, 2798999]
def PRE_first_tail_x8_r0_body.nr156 : List Nat := [6782, 6781, 6757, 6765, 6770, 6775, 6780, 6754, 6755, 6756, 6763, 6764, 6752, 6759, 6760, 6761, 6762, 6758]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd156 : RData :=
  ⟨2797885, 2799034, Stage.setAll PTrie.nil [(2797879, 2798991), (2797880, 2798166), (2797881, 2798997), (2797882, 2798993), (2797883, 2798168), (2797884, 2798999)], Stage.setAll PTrie.nil [(21284, 21310), (21285, 21288), (21286, 21311)],
   21287, 21312, 18386, 18386, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(6752, .ref 6782), (6753, .ref 6781), (6754, .ref 6757), (6755, .ref 6765), (6756, .ref 6770), (6757, .ref 6775), (6758, .ref 6780), (6759, .ref 6754), (6760, .ref 6755), (6761, .ref 6756), (6762, .ref 6763), (6763, .ref 6764), (6764, .ref 6752), (6765, .ref 6759), (6766, .ref 6760), (6767, .ref 6761), (6768, .ref 6762), (6769, .ref 6758)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa156 : Map :=
  Conv.Map.compact 2797879 2799034 6752 PRE_first_tail_x8_r0_body.pl156 (PRE_first_tail_x8_r0_body.nr156.map NumV.ref) PRE_first_tail_x8_r0_body.kd156.big
    PRE_first_tail_x8_r0_body.kd156.region PRE_first_tail_x8_r0_body.kd156.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws156 : List Nat := [3636, 3637, 3638, 3639, 3640, 3641, 3642, 3643, 3644, 3645, 3646, 3647, 3648, 3649, 3650, 3651, 3652, 3653]
noncomputable def PRE_first_tail_x8_r0_body.crs156 : List SymE := PRE_first_tail_x8_r0_body.nr156.map fun r => (nth? PRE_first_tail_x8_r0_body.S1512.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta156 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws156 PRE_first_tail_x8_r0_body.crs156
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB156 : List Nat := [2665, 2672703, 2673467, 2797053, 2797598, 2797854]

kernel_rfl PRE_first_tail_x8_r0_body.ctab156 : PRE_first_tail_x8_r0_body.S1513.tab = PRE_first_tail_x8_r0_body.S1511.tab ++ PRE_first_tail_x8_r0_body.cws156.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace156 : PRE_first_tail_x8_r0_body.s1513.trace = PRE_first_tail_x8_r0_body.s1511.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext156 : PRE_first_tail_x8_r0_body.s1513.next = 2797885
kernel_rfl PRE_first_tail_x8_r0_body.ccounters156 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1513.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1513.ffi).mlx.nnext) = (21287, 18386)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue156 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1512.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1513.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa156.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp156 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1513.ffi).mlx.tokens.all (bSN 6770) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean156 : Conv.cleanListB 21287 131072 (fun r => Nat.ble 85148 r) PRE_first_tail_x8_r0_body.s1513
    (PRE_first_tail_x8_r0_body.wrB156 ++ (List.range 6).map (2797879 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs156 : bigsOutB 21287 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1513.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK156
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl156`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl156 : List Nat := [2665, 2672703, 2673467, 2797053, 2797598, 2797854, 2797879, 2797880, 2797881, 2797882, 2797883, 2797884]
def PRE_first_tail_x8_r0_body.clo156 : List Nat := [21264, 21277, 21283, 21284, 21285, 21286]
def PRE_first_tail_x8_r0_body.cln156 : List Nat := [18359, 18360, 18361, 18362, 18363, 18364, 18365, 18366, 18367, 18368, 18369, 18370, 18371, 18372, 18373, 18374, 18375, 18376, 18377, 18378, 18379, 18380, 18381, 18382, 18383, 18384, 18385]
def PRE_first_tail_x8_r0_body.cli156 : List Nat := [18359, 18360, 18361, 18362, 18363, 18364, 18365, 18366, 18367, 18368, 18369, 18370, 18371, 18372, 18373, 18374, 18375, 18376, 18377, 18378, 18379, 18380, 18381, 18382, 18383, 18384, 18385]
kernel_rfl PRE_first_tail_x8_r0_body.cheap156 : PRE_first_tail_x8_r0_body.s1513.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1511.heap (PRE_first_tail_x8_r0_body.cl156.filterMap fun a => (PRE_first_tail_x8_r0_body.s1513.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe156 : Nat.ble PRE_first_tail_x8_r0_body.s1511.next PRE_first_tail_x8_r0_body.s1513.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP156 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1511 PRE_first_tail_x8_r0_body.s1513 PRE_first_tail_x8_r0_body.cl156 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp156 : Conv.suppListB PRE_first_tail_x8_r0_body.s1513 6770 PRE_first_tail_x8_r0_body.cl156 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound156 : Conv.boundListB PRE_first_tail_x8_r0_body.s1513 PRE_first_tail_x8_r0_body.cl156 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK156 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1513.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln156.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1513.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK156 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1513.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo156.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1513.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK156 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1513.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli156.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1513.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst156 : Conv.sstListB 6770 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1513.ffi).mlx PRE_first_tail_x8_r0_body.cln156 PRE_first_tail_x8_r0_body.clo156 PRE_first_tail_x8_r0_body.cli156 = true

end Host.Load.Run.Tpl
end

section -- SiteCl156
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA156 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1513.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo156.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1513.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd156 : (PRE_first_tail_x8_r0_body.clo156 ++ PRE_first_tail_x8_r0_body.cln156 ++ PRE_first_tail_x8_r0_body.cli156).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle156 : Conv.Cnt.leB (⟨21284, 18359, 2797879, 6752⟩ : Conv.Cnt) (⟨21287, 18386, 2797885, 6770⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck156 : Conv.ncleanListB (⟨21287, 18386, 2797885, 6770⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1513.ffi).mlx PRE_first_tail_x8_r0_body.clo156 PRE_first_tail_x8_r0_body.cln156 PRE_first_tail_x8_r0_body.cli156 = true
theorem PRE_first_tail_x8_r0_body.cncl156 (h : Conv.NClean (⟨21284, 18359, 2797879, 6752⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx) : Conv.NClean (⟨21287, 18386, 2797885, 6770⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1513.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle156 PRE_first_tail_x8_r0_body.ckA156 PRE_first_tail_x8_r0_body.cobjsK156 PRE_first_tail_x8_r0_body.cnodesK156 PRE_first_tail_x8_r0_body.citemsK156 PRE_first_tail_x8_r0_body.cbd156 PRE_first_tail_x8_r0_body.cck156

end Host.Load.Run.Tpl
end

section -- SiteS156
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 156 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc156 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P156 : LoadP := PRE_first_tail_x8_r0_body.Pc156.raise 18386
kernel_rfl PRE_first_tail_x8_r0_body.craise156 : Nat.ble PRE_first_tail_x8_r0_body.Pc156.N0 18386 = true
theorem PRE_first_tail_x8_r0_body.raised156 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc156 PRE_first_tail_x8_r0_body.P156 :=
  .inr ⟨18386, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise156, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_156 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1513.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_156 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1512.ffi)
def PRE_first_tail_x8_r0_body.khinv156 : PTrie Nat := Stage.setAll PTrie.nil [(21310, 21284), (21288, 21285), (21311, 21286)]
def PRE_first_tail_x8_r0_body.kninv156 : PTrie Nat := Stage.setAll PTrie.nil [(18359, 18359), (18360, 18360), (18361, 18361), (18362, 18362), (18363, 18363), (18364, 18364), (18365, 18365), (18366, 18366), (18367, 18367), (18368, 18368), (18369, 18369), (18370, 18370), (18371, 18371), (18372, 18372), (18373, 18373), (18374, 18374), (18375, 18375), (18376, 18376), (18377, 18377), (18378, 18378), (18379, 18379), (18380, 18380), (18381, 18381), (18382, 18382), (18383, 18383), (18384, 18384), (18385, 18385)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS156 : List Nat := [21264, 21277, 21283, 21284, 21285, 21286, 21287, 21288, 21289, 21290, 21291, 21292, 21293, 21294, 21295, 21296, 21297, 21298, 21299, 21300, 21301, 21302, 21303, 21304, 21305, 21306, 21307, 21308, 21309, 21310, 21311]
def PRE_first_tail_x8_r0_body.cnS156 : List Nat := List.range' 18359 27
def PRE_first_tail_x8_r0_body.ciS156 : List Nat := [] ++ List.range' 18359 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0156 : PRE_first_tail_x8_r0_body.kd156.nh0 = PRE_first_tail_x8_r0_body.cx0_156.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1156 : PRE_first_tail_x8_r0_body.kd156.nh1 = PRE_first_tail_x8_r0_body.cx1_156.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0156 : PRE_first_tail_x8_r0_body.kd156.nn0 = PRE_first_tail_x8_r0_body.cx0_156.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1156 : PRE_first_tail_x8_r0_body.kd156.nn1 = PRE_first_tail_x8_r0_body.cx1_156.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo156 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P156.lo && Nat.ble PRE_first_tail_x8_r0_body.P156.lo PRE_first_tail_x8_r0_body.cx0_156.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P156.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P156.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt156 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_156.mlx.next PRE_first_tail_x8_r0_body.cx1_156.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_156.mlx.nnext PRE_first_tail_x8_r0_body.cx1_156.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband156 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P156.NL && Nat.ble PRE_first_tail_x8_r0_body.P156.NL PRE_first_tail_x8_r0_body.P156.N0 && Nat.ble PRE_first_tail_x8_r0_body.P156.N0 PRE_first_tail_x8_r0_body.cx0_156.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow156 : PRE_first_tail_x8_r0_body.kd156.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren156 : checkRenG PRE_first_tail_x8_r0_body.kd156.hnd PRE_first_tail_x8_r0_body.khinv156 (phB PRE_first_tail_x8_r0_body.cx0_156.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband156 : PRE_first_tail_x8_r0_body.kd156.checkBand PRE_first_tail_x8_r0_body.P156.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos156 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd156.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren156 : checkRenG PRE_first_tail_x8_r0_body.kd156.node PRE_first_tail_x8_r0_body.kninv156 (pnB PRE_first_tail_x8_r0_body.cx0_156.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow156 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd156.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P156.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd156.nodeF j) PRE_first_tail_x8_r0_body.cx1_156.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a156 : PRE_first_tail_x8_r0_body.cx0_156.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b156 : PRE_first_tail_x8_r0_body.cx0_156.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1156 : PRE_first_tail_x8_r0_body.cx1_156.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend156 : PRE_first_tail_x8_r0_body.cx1_156.mlx.pending = PRE_first_tail_x8_r0_body.cx0_156.mlx.pending.map PRE_first_tail_x8_r0_body.kappa156.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh156 : PRE_first_tail_x8_r0_body.cx1_156.mlx.errh = PRE_first_tail_x8_r0_body.cx0_156.mlx.errh.map PRE_first_tail_x8_r0_body.kappa156.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles156 : PRE_first_tail_x8_r0_body.cx1_156.mlx.files = PRE_first_tail_x8_r0_body.cx0_156.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch156 : PRE_first_tail_x8_r0_body.cx1_156.mlx.arch = PRE_first_tail_x8_r0_body.cx0_156.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes156 : PRE_first_tail_x8_r0_body.cx1_156.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_156.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired156 : PRE_first_tail_x8_r0_body.cx1_156.mlx.wired = PRE_first_tail_x8_r0_body.cx0_156.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost156 : PRE_first_tail_x8_r0_body.cx1_156.host = PRE_first_tail_x8_r0_body.cx0_156.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd156`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0156 : PRE_first_tail_x8_r0_body.kd156.n0 = 2797885
kernel_rfl PRE_first_tail_x8_r0_body.ckn1156 : PRE_first_tail_x8_r0_body.kd156.n1 = 2799034
kernel_rfl PRE_first_tail_x8_r0_body.ckheap156 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd156.heap).all (fun x => Nat.ble 2797879 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl156 : (List.range 6).all (fun j => decide (PRE_first_tail_x8_r0_body.kd156.heap.get (2797879 + j) = nth? PRE_first_tail_x8_r0_body.pl156 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja156 : Nat.ble 2797879 2797879 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn156 : Nat.ble 6752 6752 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD156 : Nat.ble 2797879 PRE_first_tail_x8_r0_body.kd156.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn156 : Nat.ble 21284 PRE_first_tail_x8_r0_body.kd156.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn156 : Nat.ble 18359 PRE_first_tail_x8_r0_body.kd156.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb156 : Nat.ble 21284 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap156 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd156.heap).all (Nat.ble (⟨21284, 18359, 2797879, 6752⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd156 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd156.hnd).all (Nat.ble (⟨21284, 18359, 2797879, 6752⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode156 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd156.node).all (Nat.ble (⟨21284, 18359, 2797879, 6752⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix156 : Conv.FixOld (⟨21284, 18359, 2797879, 6752⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa156 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja156) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn156) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD156) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn156) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn156) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb156) PRE_first_tail_x8_r0_body.fheap156 PRE_first_tail_x8_r0_body.fhnd156 PRE_first_tail_x8_r0_body.fnode156
kernel_rfl PRE_first_tail_x8_r0_body.fcxn156 : (⟨21284, 18359, 2797879, 6752⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn156 : (⟨21284, 18359, 2797879, 6752⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0156 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_156.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_156.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk156 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd156.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A156 : PRE_first_tail_x8_r0_body.cx1_156.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS156.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_156.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O156 : PRE_first_tail_x8_r0_body.cx1_156.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS156.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_156.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N156 : PRE_first_tail_x8_r0_body.cx1_156.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS156.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_156.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I156 : PRE_first_tail_x8_r0_body.cx1_156.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS156.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_156.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd156 : (PRE_first_tail_x8_r0_body.clo156 ++ PRE_first_tail_x8_r0_body.cln156 ++ PRE_first_tail_x8_r0_body.cli156 ++ PRE_first_tail_x8_r0_body.cwS156 ++ PRE_first_tail_x8_r0_body.cnS156 ++ PRE_first_tail_x8_r0_body.ciS156).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW156 : PRE_first_tail_x8_r0_body.cwS156.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo156.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI156 : PRE_first_tail_x8_r0_body.ciS156.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli156.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN156 : PRE_first_tail_x8_r0_body.cnS156.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF156 : PRE_first_tail_x8_r0_body.cln156.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh156 : PRE_first_tail_x8_r0_body.clo156.all (handleOK PRE_first_tail_x8_r0_body.kappa156 PRE_first_tail_x8_r0_body.P156.lo PRE_first_tail_x8_r0_body.cx0_156.mlx PRE_first_tail_x8_r0_body.cx1_156.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo156 : PRE_first_tail_x8_r0_body.clo156.map (fun h => PRE_first_tail_x8_r0_body.cx1_156.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa156.handle h)) = PRE_first_tail_x8_r0_body.clo156.map (fun h => (PRE_first_tail_x8_r0_body.cx0_156.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa156.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok156 : PRE_first_tail_x8_r0_body.clo156.all (objOK PRE_first_tail_x8_r0_body.kappa156 PRE_first_tail_x8_r0_body.P156.NL PRE_first_tail_x8_r0_body.cx0_156.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd156 : PRE_first_tail_x8_r0_body.cln156.all (nodeOKF PRE_first_tail_x8_r0_body.kappa156 PRE_first_tail_x8_r0_body.P156 PRE_first_tail_x8_r0_body.cx0_156.mlx PRE_first_tail_x8_r0_body.cx1_156.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp156 : ((PRE_first_tail_x8_r0_body.cln156.filter (fullB PRE_first_tail_x8_r0_body.P156))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_156.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa156.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln156.filter (fullB PRE_first_tail_x8_r0_body.P156))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_156.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa156.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI156 : incrB PRE_first_tail_x8_r0_body.kd156.nodeF (List.range' 18359 27) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK156 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd156.node).all (fun k => Nat.ble 18359 k && Nat.blt k 18386) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL156 : (PRE_first_tail_x8_r0_body.cln156.filter (Nat.ble PRE_first_tail_x8_r0_body.P156.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd156.nodeF i) && (Nat.blt i 18386 || Nat.ble PRE_first_tail_x8_r0_body.kd156.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord156 : (PRE_first_tail_x8_r0_body.cln156.filter (Nat.ble PRE_first_tail_x8_r0_body.P156.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd156.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd156.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd156.nodeF j) (PRE_first_tail_x8_r0_body.kd156.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow156 PRE_first_tail_x8_r0_body.cnn1156 PRE_first_tail_x8_r0_body.fnordI156 PRE_first_tail_x8_r0_body.fnordK156 PRE_first_tail_x8_r0_body.fnordL156
kernel_rfl PRE_first_tail_x8_r0_body.fi156 : PRE_first_tail_x8_r0_body.cli156.all (pnB PRE_first_tail_x8_r0_body.cx0_156.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii156 : PRE_first_tail_x8_r0_body.cli156.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_156.mlx.items.get (PRE_first_tail_x8_r0_body.kappa156.node k) = (PRE_first_tail_x8_r0_body.cx0_156.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa156.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot156 (clean : Conv.NClean (⟨21284, 18359, 2797879, 6752⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P156.NL) (cl : SSt (· < 6770) PRE_first_tail_x8_r0_body.cx0_156.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P156 6770 PRE_first_tail_x8_r0_body.kappa156 PRE_first_tail_x8_r0_body.kd156 PRE_first_tail_x8_r0_body.khinv156 PRE_first_tail_x8_r0_body.kninv156 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx PRE_first_tail_x8_r0_body.cx0_156.mlx PRE_first_tail_x8_r0_body.cx1_156.mlx (⟨21284, 18359, 2797879, 6752⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo156 PRE_first_tail_x8_r0_body.cln156 PRE_first_tail_x8_r0_body.cli156 PRE_first_tail_x8_r0_body.cwS156 PRE_first_tail_x8_r0_body.cnS156 PRE_first_tail_x8_r0_body.ciS156 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0156, PRE_first_tail_x8_r0_body.cnh1156, PRE_first_tail_x8_r0_body.cnn0156, PRE_first_tail_x8_r0_body.cnn1156, PRE_first_tail_x8_r0_body.cplo156, PRE_first_tail_x8_r0_body.ccnt156, PRE_first_tail_x8_r0_body.cnband156, PRE_first_tail_x8_r0_body.chbelow156, PRE_first_tail_x8_r0_body.chren156, PRE_first_tail_x8_r0_body.cband156, PRE_first_tail_x8_r0_body.cnh1pos156, PRE_first_tail_x8_r0_body.cnren156, PRE_first_tail_x8_r0_body.cnlow156, PRE_first_tail_x8_r0_body.cabs0a156, PRE_first_tail_x8_r0_body.cabs0b156, PRE_first_tail_x8_r0_body.ctok1156, PRE_first_tail_x8_r0_body.cpend156, PRE_first_tail_x8_r0_body.cerrh156, PRE_first_tail_x8_r0_body.cfiles156, PRE_first_tail_x8_r0_body.carch156, PRE_first_tail_x8_r0_body.csizes156, PRE_first_tail_x8_r0_body.cwired156, PRE_first_tail_x8_r0_body.cfix156, clean, PRE_first_tail_x8_r0_body.fcxn156, PRE_first_tail_x8_r0_body.fcnn156, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0156, PRE_first_tail_x8_r0_body.fnk156, PRE_first_tail_x8_r0_body.ckA156, PRE_first_tail_x8_r0_body.cobjsK156, PRE_first_tail_x8_r0_body.cnodesK156, PRE_first_tail_x8_r0_body.citemsK156, PRE_first_tail_x8_r0_body.f1A156, PRE_first_tail_x8_r0_body.f1O156, PRE_first_tail_x8_r0_body.f1N156, PRE_first_tail_x8_r0_body.f1I156, PRE_first_tail_x8_r0_body.fbd156, PRE_first_tail_x8_r0_body.fincW156, PRE_first_tail_x8_r0_body.fincI156, PRE_first_tail_x8_r0_body.fincN156, PRE_first_tail_x8_r0_body.flnF156, PRE_first_tail_x8_r0_body.fh156, PRE_first_tail_x8_r0_body.fo156, PRE_first_tail_x8_r0_body.fok156, PRE_first_tail_x8_r0_body.fnd156, PRE_first_tail_x8_r0_body.fp156, PRE_first_tail_x8_r0_body.fnord156, PRE_first_tail_x8_r0_body.fi156, PRE_first_tail_x8_r0_body.fii156⟩
theorem PRE_first_tail_x8_r0_body.cnshift156 (clean : Conv.NClean (⟨21284, 18359, 2797879, 6752⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P156.NL) (cl : SSt (· < 6770) PRE_first_tail_x8_r0_body.cx0_156.mlx) : NShift PRE_first_tail_x8_r0_body.P156 6770 PRE_first_tail_x8_r0_body.kappa156 PRE_first_tail_x8_r0_body.cx0_156 PRE_first_tail_x8_r0_body.cx1_156 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot156 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost156 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0156 PRE_first_tail_x8_r0_body.ckn1156 PRE_first_tail_x8_r0_body.ckheap156 PRE_first_tail_x8_r0_body.ckpl156)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_156 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1511.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_156 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1511.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_156 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1511.ffi) = some PRE_first_tail_x8_r0_body.fxC_156
kernel_rfl PRE_first_tail_x8_r0_body.okrC_156 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1511.ffi) = some PRE_first_tail_x8_r0_body.krC_156
noncomputable def PRE_first_tail_x8_r0_body.fx0_156 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1513.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_156 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1513.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_156 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1513.ffi) = some PRE_first_tail_x8_r0_body.fx0_156
kernel_rfl PRE_first_tail_x8_r0_body.okr0_156 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1513.ffi) = some PRE_first_tail_x8_r0_body.kr0_156
noncomputable def PRE_first_tail_x8_r0_body.fx1_156 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1512.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_156 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1512.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_156 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1512.ffi) = some PRE_first_tail_x8_r0_body.fx1_156
kernel_rfl PRE_first_tail_x8_r0_body.okr1_156 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1512.ffi) = some PRE_first_tail_x8_r0_body.kr1_156
kernel_rfl PRE_first_tail_x8_r0_body.ff0156 : PRE_first_tail_x8_r0_body.fx0_156 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_156 (PRE_first_tail_x8_r0_body.clo156.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_156.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1156 : PRE_first_tail_x8_r0_body.fx1_156 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_156 (PRE_first_tail_x8_r0_body.cwS156.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_156.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck156 : freedLB PRE_first_tail_x8_r0_body.kappa156 PRE_first_tail_x8_r0_body.cx0_156.mlx PRE_first_tail_x8_r0_body.fx0_156 PRE_first_tail_x8_r0_body.fx1_156 PRE_first_tail_x8_r0_body.clo156 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0156 : PRE_first_tail_x8_r0_body.kr0_156.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_156.flags (PRE_first_tail_x8_r0_body.clo156.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_156.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0156 : PRE_first_tail_x8_r0_body.kr0_156.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_156.targs (PRE_first_tail_x8_r0_body.clo156.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_156.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1156 : PRE_first_tail_x8_r0_body.kr1_156.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_156.flags (PRE_first_tail_x8_r0_body.cwS156.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_156.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1156 : PRE_first_tail_x8_r0_body.kr1_156.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_156.targs (PRE_first_tail_x8_r0_body.cwS156.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_156.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck156 : krecLB PRE_first_tail_x8_r0_body.kappa156 6770 PRE_first_tail_x8_r0_body.cx0_156.mlx PRE_first_tail_x8_r0_body.kr0_156 PRE_first_tail_x8_r0_body.kr1_156 PRE_first_tail_x8_r0_body.clo156 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn156 : Nat.ble 6752 6770 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge156 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1512.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1513.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR156 : pendRegB PRE_first_tail_x8_r0_body.kappa156 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1513.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe156 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1513.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1512.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift156 (clean : Conv.NClean (⟨21284, 18359, 2797879, 6752⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P156.NL) (cl : SSt (· < 6770) PRE_first_tail_x8_r0_body.cx0_156.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_156.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_156.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_156.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1511.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_156.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21284, 18359, 2797879, 6752⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P156 6770 PRE_first_tail_x8_r0_body.kappa156 PRE_first_tail_x8_r0_body.s1513.ffi PRE_first_tail_x8_r0_body.s1512.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift156 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue156, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp156 t ht),
    PRE_first_tail_x8_r0_body.cbridge156,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1513.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1512.ffi) (PRE_first_tail_x8_r0_body.cfoot156 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_156 PRE_first_tail_x8_r0_body.ofx1_156 hobjC PRE_first_tail_x8_r0_body.ff0156 PRE_first_tail_x8_r0_body.ff1156 PRE_first_tail_x8_r0_body.ffck156,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1513.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1512.ffi) (PRE_first_tail_x8_r0_body.cfoot156 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_156 PRE_first_tail_x8_r0_body.okr1_156 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn156) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0156 PRE_first_tail_x8_r0_body.fkt0156 PRE_first_tail_x8_r0_body.fkf1156 PRE_first_tail_x8_r0_body.fkt1156 PRE_first_tail_x8_r0_body.fkck156,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0156 PRE_first_tail_x8_r0_body.cnh1156 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe156) PRE_first_tail_x8_r0_body.cpendR156⟩

end Host.Load.Run.Tpl
end

section -- st156/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st156 0
host_stream_state PRE_first_tail_x8_r0_body.st156 1
host_stream_state PRE_first_tail_x8_r0_body.st156 2
host_stream_state PRE_first_tail_x8_r0_body.st156 3
host_stream_state PRE_first_tail_x8_r0_body.st156 4
host_stream_state PRE_first_tail_x8_r0_body.st156 5
end Host.Load.Run.Tpl
end

section -- Site156
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 156 of chain `PRE_first_tail_x8_r0_body`: `ssmW__g156__g157` (`recurWindow`), the call state `PRE_first_tail_x8_r0_body.s1511`, the merged state `PRE_first_tail_x8_r0_body.s1512`,
the site template `PRE_first_tail_x8_r0_body.st156` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1513`: the merge.
The footprint's facts are in `SiteF156`, the compaction's in `SiteC156`, `SiteK156`, `SiteNa156`, `SiteNb156`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso156 : PRE_first_tail_x8_r0_body.st156.s0 = { PRE_first_tail_x8_r0_body.s1511 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs156 : List Frame := PRE_first_tail_x8_r0_body.s1511.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_156 : PRE_first_tail_x8_r0_body.S1511.tab.length = 6752
kernel_rfl PRE_first_tail_x8_r0_body.tab0_156 : PRE_first_tail_x8_r0_body.st156.S0.tab = PRE_first_tail_x8_r0_body.S1511.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws156 : List Nat := [3605, 3606, 3607, 3608, 3609, 3610, 3611, 3612, 3613, 3614, 3615, 3616, 3617, 3618, 3619, 3620, 3621, 3622, 3623, 3624, 3625, 3626, 3627, 3628, 3629, 3630, 3631, 3632, 3633, 3634, 3635]
kernel_rfl PRE_first_tail_x8_r0_body.fresh156 : (PRE_first_tail_x8_r0_body.S1511.tab.all fun e => PRE_first_tail_x8_r0_body.ws156.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1511.oracle.all fun q => PRE_first_tail_x8_r0_body.ws156.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab156 : PRE_first_tail_x8_r0_body.S1512.tab = PRE_first_tail_x8_r0_body.S1511.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws156
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen156 : PRE_first_tail_x8_r0_body.st156.S5.tab.length - PRE_first_tail_x8_r0_body.st156.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged156`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap156 : PRE_first_tail_x8_r0_body.s1512.heap = PRE_first_tail_x8_r0_body.st156.s5.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext156 : PRE_first_tail_x8_r0_body.s1512.next = PRE_first_tail_x8_r0_body.st156.s5.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl156 : PRE_first_tail_x8_r0_body.s1512.ctl = PRE_first_tail_x8_r0_body.st156.s5.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack156 : PRE_first_tail_x8_r0_body.s1512.stack = PRE_first_tail_x8_r0_body.st156.s5.stack ++ PRE_first_tail_x8_r0_body.s1511.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs156 : PRE_first_tail_x8_r0_body.s1512.jobs = PRE_first_tail_x8_r0_body.st156.s5.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi156 : PRE_first_tail_x8_r0_body.s1512.ffi = PRE_first_tail_x8_r0_body.st156.s5.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace156 : PRE_first_tail_x8_r0_body.s1512.trace = PRE_first_tail_x8_r0_body.st156.s5.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores156 : PRE_first_tail_x8_r0_body.s1512.stores = PRE_first_tail_x8_r0_body.st156.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD156
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 156 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived156 : PRE_first_tail_x8_r0_body.nr156.map (fun r => nth? PRE_first_tail_x8_r0_body.st156.S5.tab r) =
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
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo156 : PRE_first_tail_x8_r0_body.nr156.all (Nat.ble 6752) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj156 : PRE_first_tail_x8_r0_body.cws156.all (fun c => !PRE_first_tail_x8_r0_body.ws156.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ156 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws156 PRE_first_tail_x8_r0_body.crs156 PRE_first_tail_x8_r0_body.ws156

end Host.Load.Run.Tpl
end

section -- st156/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st156`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st156.wrR : List (Nat × Nat) := [(2672703, 2672704), (2797053, 2797054), (2797598, 2797599), (2797854, 2797855)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st156.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st156.s5.heap PRE_first_tail_x8_r0_body.st156.wrR ++ freshOf PRE_first_tail_x8_r0_body.st156.s5.heap PRE_first_tail_x8_r0_body.st156.s0.next PRE_first_tail_x8_r0_body.st156.s5.next
noncomputable def PRE_first_tail_x8_r0_body.st156.wr : List Nat := PRE_first_tail_x8_r0_body.st156.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st156.heapFoot : PRE_first_tail_x8_r0_body.st156.s5.heap = setAll PRE_first_tail_x8_r0_body.st156.s0.heap PRE_first_tail_x8_r0_body.st156.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st156.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st156.s0.next PRE_first_tail_x8_r0_body.st156.s5.next = true
theorem PRE_first_tail_x8_r0_body.st156.grows : PRE_first_tail_x8_r0_body.st156.s0.next ≤ PRE_first_tail_x8_r0_body.st156.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st156.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st156.wh : List Nat := [21264, 21277, 21283, 21284, 21285, 21286, 21287, 21288, 21289, 21290, 21291, 21292, 21293, 21294, 21295, 21296, 21297, 21298, 21299, 21300, 21301, 21302, 21303, 21304, 21305, 21306, 21307, 21308, 21309, 21310, 21311]
def PRE_first_tail_x8_r0_body.st156.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st156.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st156.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st156.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st156.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st156.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st156.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st156.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st156.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st156.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st156.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st156.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st156.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st156.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st156.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st156.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st156.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st156.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st156.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st156.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st156.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st156.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st156.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st156.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st156.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st156.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st156.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st156.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st156.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st156.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF156
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 156 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB156 : nodupT PRE_first_tail_x8_r0_body.st156.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup156 : PRE_first_tail_x8_r0_body.st156.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB156).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB156 : PRE_first_tail_x8_r0_body.st156.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound156 : ∀ b ∈ PRE_first_tail_x8_r0_body.st156.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB156 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr156 := PRE_first_tail_x8_r0_body.st156.s5.trace.take 120
kernel_rfl PRE_first_tail_x8_r0_body.traceEq156 : PRE_first_tail_x8_r0_body.st156.s5.trace = PRE_first_tail_x8_r0_body.trFr156 ++ PRE_first_tail_x8_r0_body.st156.s0.trace
theorem PRE_first_tail_x8_r0_body.trace156 : ∃ fr, PRE_first_tail_x8_r0_body.st156.s5.trace = fr ++ PRE_first_tail_x8_r0_body.st156.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq156⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide156 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB156 : (PRE_first_tail_x8_r0_body.wide156.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st156.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix156 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide156, WFix Map.id (Present PRE_first_tail_x8_r0_body.st156.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB156 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL156
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 156 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1512`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO156 : PRE_first_tail_x8_r0_body.st156.S0.oracle = PRE_first_tail_x8_r0_body.st156.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B156 : PRE_first_tail_x8_r0_body.st156.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st156.s0.next || (PRE_first_tail_x8_r0_body.st156.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot156 : Conv.StageFoot PRE_first_tail_x8_r0_body.st156.wr PRE_first_tail_x8_r0_body.st156.s0 PRE_first_tail_x8_r0_body.st156.s5 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st156.heapFoot PRE_first_tail_x8_r0_body.wrNodup156 PRE_first_tail_x8_r0_body.wrBound156 PRE_first_tail_x8_r0_body.wr0B156 PRE_first_tail_x8_r0_body.st156.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged156 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st156.F.S → PRE_first_tail_x8_r0_body.st156.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st156.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st156.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs156 PRE_first_tail_x8_r0_body.st156.wr PRE_first_tail_x8_r0_body.s1511 PRE_first_tail_x8_r0_body.st156.s5 PRE_first_tail_x8_r0_body.st156.s0
      PRE_first_tail_x8_r0_body.st156.s5.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st156.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1512 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso156 PRE_first_tail_x8_r0_body.stFoot156 PRE_first_tail_x8_r0_body.wrNodup156 PRE_first_tail_x8_r0_body.wrBound156 PRE_first_tail_x8_r0_body.trace156 PRE_first_tail_x8_r0_body.mheap156
    PRE_first_tail_x8_r0_body.mnext156 PRE_first_tail_x8_r0_body.mctl156 PRE_first_tail_x8_r0_body.mstack156 PRE_first_tail_x8_r0_body.mjobs156 PRE_first_tail_x8_r0_body.mffi156 PRE_first_tail_x8_r0_body.mtrace156 PRE_first_tail_x8_r0_body.mstores156 h

def PRE_first_tail_x8_r0_body.arrEl156_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE156_2665 : arrOf PRE_first_tail_x8_r0_body.s1512 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl156_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA156_2665 : isArrB PRE_first_tail_x8_r0_body.s1512 2665 = true
theorem PRE_first_tail_x8_r0_body.arr156_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1512.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl156_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE156_2665 PRE_first_tail_x8_r0_body.arrA156_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN156_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl156_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR156_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl156_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN156_2665

def PRE_first_tail_x8_r0_body.arrEl156_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE156_2673467 : arrOf PRE_first_tail_x8_r0_body.s1512 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl156_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA156_2673467 : isArrB PRE_first_tail_x8_r0_body.s1512 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr156_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1512.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl156_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE156_2673467 PRE_first_tail_x8_r0_body.arrA156_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN156_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl156_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR156_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl156_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN156_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k156 : isArrB PRE_first_tail_x8_r0_body.s1512 4910 = false
theorem PRE_first_tail_x8_r0_body.keep156 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1512 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k156 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr156_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl156_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ156
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 156 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1511`, the merged
state `PRE_first_tail_x8_r0_body.s1512`, the canonical state `PRE_first_tail_x8_r0_body.s1513`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl156 : PRE_first_tail_x8_r0_body.pl156.all (Nat.ble PRE_first_tail_x8_r0_body.s1511.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd156 : nodupT PRE_first_tail_x8_r0_body.pl156 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1156 : Nat.ble PRE_first_tail_x8_r0_body.s1511.next 2799034 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst156 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1511.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn156 : PRE_first_tail_x8_r0_body.s1513.next = PRE_first_tail_x8_r0_body.s1511.next + PRE_first_tail_x8_r0_body.pl156.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn156 : PRE_first_tail_x8_r0_body.s1512.next = 2799034
kernel_rfl PRE_first_tail_x8_r0_body.zgrow156 : Nat.ble PRE_first_tail_x8_r0_body.s1513.next PRE_first_tail_x8_r0_body.s1512.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh156 : PRE_first_tail_x8_r0_body.S1511.tab.all (fun e => PRE_first_tail_x8_r0_body.cws156.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd156 : nodupT PRE_first_tail_x8_r0_body.cws156 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi156 : PRE_first_tail_x8_r0_body.nr156.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1512.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt156 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1511.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg156_2665 : PRE_first_tail_x8_r0_body.s1513.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1513 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk156_2665 : (objOf PRE_first_tail_x8_r0_body.s1513 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm156_2665 : PRE_first_tail_x8_r0_body.s1512.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa156.obj (objOf PRE_first_tail_x8_r0_body.s1513 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1512 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg156_2673467 : PRE_first_tail_x8_r0_body.s1513.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1513 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk156_2673467 : (objOf PRE_first_tail_x8_r0_body.s1513 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm156_2673467 : PRE_first_tail_x8_r0_body.s1512.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa156.obj (objOf PRE_first_tail_x8_r0_body.s1513 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1512 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw156_4910 : (PRE_first_tail_x8_r0_body.s1513.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw156_2673472 : (PRE_first_tail_x8_r0_body.s1513.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw156_2673473 : (PRE_first_tail_x8_r0_body.s1513.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd156 : PRE_first_tail_x8_r0_body.cl156.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr156 : PRE_first_tail_x8_r0_body.st156.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1511.next || PRE_first_tail_x8_r0_body.cl156.contains b) = true
def PRE_first_tail_x8_r0_body.zl156 : List Nat := PRE_first_tail_x8_r0_body.cl156.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE156 : PRE_first_tail_x8_r0_body.zl156.map (fun a => PRE_first_tail_x8_r0_body.s1512.heap.get (PRE_first_tail_x8_r0_body.kappa156.a a)) = PRE_first_tail_x8_r0_body.zl156.map (fun a => (PRE_first_tail_x8_r0_body.s1513.heap.get a).map PRE_first_tail_x8_r0_body.kappa156.hobj)
theorem PRE_first_tail_x8_r0_body.zimg156 : HeapImg PRE_first_tail_x8_r0_body.kappa156 PRE_first_tail_x8_r0_body.s1513 PRE_first_tail_x8_r0_body.s1512 PRE_first_tail_x8_r0_body.zl156 := PRE_first_tail_x8_r0_body.zimgE156
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl156 : PRE_first_tail_x8_r0_body.s1512.ctl = PRE_first_tail_x8_r0_body.kappa156.ctl PRE_first_tail_x8_r0_body.s1513.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack156 : PRE_first_tail_x8_r0_body.s1512.stack = PRE_first_tail_x8_r0_body.s1513.stack.map PRE_first_tail_x8_r0_body.kappa156.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs156 : PRE_first_tail_x8_r0_body.s1512.jobs = PRE_first_tail_x8_r0_body.s1513.jobs.map PRE_first_tail_x8_r0_body.kappa156.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores156 : PRE_first_tail_x8_r0_body.s1512.stores = PRE_first_tail_x8_r0_body.kappa156.stores PRE_first_tail_x8_r0_body.s1513.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots156 : checkRootsSupp PRE_first_tail_x8_r0_body.s1513 6770 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC156 : PRE_first_tail_x8_r0_body.S1511.tab.length + PRE_first_tail_x8_r0_body.cws156.length = 6770
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap156 : PRE_first_tail_x8_r0_body.kappa156 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1511.next 2799034 PRE_first_tail_x8_r0_body.S1511.tab.length PRE_first_tail_x8_r0_body.pl156 (PRE_first_tail_x8_r0_body.nr156.map NumV.ref) PRE_first_tail_x8_r0_body.kd156.big
  PRE_first_tail_x8_r0_body.kd156.region PRE_first_tail_x8_r0_body.kd156.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin156 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1513.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc156 : Conv.jcleanListB (⟨21287, 18386, 2797885, 6770⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1513 PRE_first_tail_x8_r0_body.cl156 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB156 : noBigRootsP (fun i => !Conv.oldBigB (⟨21287, 18386, 2797885, 6770⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1513.trace PRE_first_tail_x8_r0_body.s1513 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm156 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 18359 = true
theorem PRE_first_tail_x8_r0_body.cjcl156 (h : Conv.JClean (⟨21284, 18359, 2797879, 6752⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1511) : Conv.JClean (⟨21287, 18386, 2797885, 6770⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1513 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle156)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap156 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd156 a ha)) PRE_first_tail_x8_r0_body.zjc156

end Host.Load.Run.Tpl
end

section -- st156/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st156.bodyLast from PRE_first_tail_x8_r0_body.st156.s4 to PRE_first_tail_x8_r0_body.st156.s5 :
  interpS (step PRE_first_tail_x8_r0_body.st156.F PRE_first_tail_x8_r0_body.st156.s4).run PRE_first_tail_x8_r0_body.st156.S4 = some (PRE_first_tail_x8_r0_body.st156.s5, PRE_first_tail_x8_r0_body.st156.S5)
kernel_rfl PRE_first_tail_x8_r0_body.st156.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st156.s4.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st156.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st156.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st156/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st156.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st156.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st156.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st156.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st156.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st156.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st156.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st156.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st156.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st156.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st156.s0 PRE_first_tail_x8_r0_body.st156.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st156.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st156.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st156.s4 PRE_first_tail_x8_r0_body.st156.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st156/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st156.bodyK0F from PRE_first_tail_x8_r0_body.st156.s0 to PRE_first_tail_x8_r0_body.st156.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st156.F (PRE_first_tail_x8_r0_body.st156.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st156.ks 0).getD 0) PRE_first_tail_x8_r0_body.st156.s0 PRE_first_tail_x8_r0_body.st156.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st156.s1, PRE_first_tail_x8_r0_body.st156.S1)
theorem PRE_first_tail_x8_r0_body.st156.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st156.F (PRE_first_tail_x8_r0_body.st156.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st156.ks 0).getD 0) PRE_first_tail_x8_r0_body.st156.s0 PRE_first_tail_x8_r0_body.st156.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st156.s1, PRE_first_tail_x8_r0_body.st156.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st156.bodyOkLN_ok PRE_first_tail_x8_r0_body.st156.bodyK0F
end Host.Load.Run.Tpl
end

section -- st156/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st156.bodyK1F from PRE_first_tail_x8_r0_body.st156.s1 to PRE_first_tail_x8_r0_body.st156.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st156.F (PRE_first_tail_x8_r0_body.st156.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st156.ks 1).getD 0) PRE_first_tail_x8_r0_body.st156.s1 PRE_first_tail_x8_r0_body.st156.S1) = fun _ _ => some (PRE_first_tail_x8_r0_body.st156.s2, PRE_first_tail_x8_r0_body.st156.S2)
theorem PRE_first_tail_x8_r0_body.st156.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st156.F (PRE_first_tail_x8_r0_body.st156.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st156.ks 1).getD 0) PRE_first_tail_x8_r0_body.st156.s1 PRE_first_tail_x8_r0_body.st156.S1) = fun _ _ => some (PRE_first_tail_x8_r0_body.st156.s2, PRE_first_tail_x8_r0_body.st156.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st156.bodyOkLN_ok PRE_first_tail_x8_r0_body.st156.bodyK1F
end Host.Load.Run.Tpl
end

section -- st156/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st156.bodyK2F from PRE_first_tail_x8_r0_body.st156.s2 to PRE_first_tail_x8_r0_body.st156.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st156.F (PRE_first_tail_x8_r0_body.st156.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st156.ks 2).getD 0) PRE_first_tail_x8_r0_body.st156.s2 PRE_first_tail_x8_r0_body.st156.S2) = fun _ _ => some (PRE_first_tail_x8_r0_body.st156.s3, PRE_first_tail_x8_r0_body.st156.S3)
theorem PRE_first_tail_x8_r0_body.st156.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st156.F (PRE_first_tail_x8_r0_body.st156.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st156.ks 2).getD 0) PRE_first_tail_x8_r0_body.st156.s2 PRE_first_tail_x8_r0_body.st156.S2) = fun _ _ => some (PRE_first_tail_x8_r0_body.st156.s3, PRE_first_tail_x8_r0_body.st156.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st156.bodyOkLN_ok PRE_first_tail_x8_r0_body.st156.bodyK2F
end Host.Load.Run.Tpl
end

section -- st156/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st156.bodyK3F from PRE_first_tail_x8_r0_body.st156.s3 to PRE_first_tail_x8_r0_body.st156.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st156.F (PRE_first_tail_x8_r0_body.st156.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st156.ks 3).getD 0) PRE_first_tail_x8_r0_body.st156.s3 PRE_first_tail_x8_r0_body.st156.S3) = fun _ _ => some (PRE_first_tail_x8_r0_body.st156.s4, PRE_first_tail_x8_r0_body.st156.S4)
theorem PRE_first_tail_x8_r0_body.st156.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st156.F (PRE_first_tail_x8_r0_body.st156.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st156.ks 3).getD 0) PRE_first_tail_x8_r0_body.st156.s3 PRE_first_tail_x8_r0_body.st156.S3) = fun _ _ => some (PRE_first_tail_x8_r0_body.st156.s4, PRE_first_tail_x8_r0_body.st156.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st156.bodyOkLN_ok PRE_first_tail_x8_r0_body.st156.bodyK3F
end Host.Load.Run.Tpl
end

section -- st156/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st156.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st156.F (PRE_first_tail_x8_r0_body.st156.bodyOkL bytes rows) 11334 PRE_first_tail_x8_r0_body.st156.s0 PRE_first_tail_x8_r0_body.st156.S0 = some (PRE_first_tail_x8_r0_body.st156.s4, PRE_first_tail_x8_r0_body.st156.S4) :=
  runOk_trans PRE_first_tail_x8_r0_body.st156.F (PRE_first_tail_x8_r0_body.st156.bodyOkL bytes rows) ((((nth? PRE_first_tail_x8_r0_body.st156.ks 0).getD 0) + ((nth? PRE_first_tail_x8_r0_body.st156.ks 1).getD 0)) + ((nth? PRE_first_tail_x8_r0_body.st156.ks 2).getD 0)) ((nth? PRE_first_tail_x8_r0_body.st156.ks 3).getD 0) PRE_first_tail_x8_r0_body.st156.s0 PRE_first_tail_x8_r0_body.st156.s3 PRE_first_tail_x8_r0_body.st156.s4 PRE_first_tail_x8_r0_body.st156.S0 PRE_first_tail_x8_r0_body.st156.S3 PRE_first_tail_x8_r0_body.st156.S4 (runOk_trans PRE_first_tail_x8_r0_body.st156.F (PRE_first_tail_x8_r0_body.st156.bodyOkL bytes rows) (((nth? PRE_first_tail_x8_r0_body.st156.ks 0).getD 0) + ((nth? PRE_first_tail_x8_r0_body.st156.ks 1).getD 0)) ((nth? PRE_first_tail_x8_r0_body.st156.ks 2).getD 0) PRE_first_tail_x8_r0_body.st156.s0 PRE_first_tail_x8_r0_body.st156.s2 PRE_first_tail_x8_r0_body.st156.s3 PRE_first_tail_x8_r0_body.st156.S0 PRE_first_tail_x8_r0_body.st156.S2 PRE_first_tail_x8_r0_body.st156.S3 (runOk_trans PRE_first_tail_x8_r0_body.st156.F (PRE_first_tail_x8_r0_body.st156.bodyOkL bytes rows) ((nth? PRE_first_tail_x8_r0_body.st156.ks 0).getD 0) ((nth? PRE_first_tail_x8_r0_body.st156.ks 1).getD 0) PRE_first_tail_x8_r0_body.st156.s0 PRE_first_tail_x8_r0_body.st156.s1 PRE_first_tail_x8_r0_body.st156.s2 PRE_first_tail_x8_r0_body.st156.S0 PRE_first_tail_x8_r0_body.st156.S1 PRE_first_tail_x8_r0_body.st156.S2 ((congrFun (congrFun PRE_first_tail_x8_r0_body.st156.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x8_r0_body.st156.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x8_r0_body.st156.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x8_r0_body.st156.bodyK3 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st156.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st156.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st156.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st156.F (PRE_first_tail_x8_r0_body.st156.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st156.s0
  S0 := PRE_first_tail_x8_r0_body.st156.S0
  s1 := PRE_first_tail_x8_r0_body.st156.s4
  S1 := PRE_first_tail_x8_r0_body.st156.S4
  s2 := PRE_first_tail_x8_r0_body.st156.s5
  S2 := PRE_first_tail_x8_r0_body.st156.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st156.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st156.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st156.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st156.bodyHalt
  last := PRE_first_tail_x8_r0_body.st156.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st156.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC157
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 157 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1521` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa157` into the merged state
`PRE_first_tail_x8_r0_body.s1520`. -/

def PRE_first_tail_x8_r0_body.pl157 : List Nat := []
def PRE_first_tail_x8_r0_body.nr157 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd157 : RData :=
  ⟨2798375, 2798377, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21300, 21300, 18399, 18399, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa157 : Map :=
  Conv.Map.compact 2798375 2798377 6791 PRE_first_tail_x8_r0_body.pl157 (PRE_first_tail_x8_r0_body.nr157.map NumV.ref) PRE_first_tail_x8_r0_body.kd157.big
    PRE_first_tail_x8_r0_body.kd157.region PRE_first_tail_x8_r0_body.kd157.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws157 : List Nat := []
noncomputable def PRE_first_tail_x8_r0_body.crs157 : List SymE := PRE_first_tail_x8_r0_body.nr157.map fun r => (nth? PRE_first_tail_x8_r0_body.S1520.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta157 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws157 PRE_first_tail_x8_r0_body.crs157
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB157 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x8_r0_body.ctab157 : PRE_first_tail_x8_r0_body.S1521.tab = PRE_first_tail_x8_r0_body.S1519.tab ++ PRE_first_tail_x8_r0_body.cws157.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace157 : PRE_first_tail_x8_r0_body.s1521.trace = PRE_first_tail_x8_r0_body.s1519.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext157 : PRE_first_tail_x8_r0_body.s1521.next = 2798375
kernel_rfl PRE_first_tail_x8_r0_body.ccounters157 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1521.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1521.ffi).mlx.nnext) = (21300, 18399)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue157 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1520.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1521.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa157.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp157 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1521.ffi).mlx.tokens.all (bSN 6791) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean157 : Conv.cleanListB 21300 131072 (fun r => Nat.ble 85200 r) PRE_first_tail_x8_r0_body.s1521
    (PRE_first_tail_x8_r0_body.wrB157 ++ (List.range 0).map (2798375 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs157 : bigsOutB 21300 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1521.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK157
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl157`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl157 : List Nat := [2665, 2673467]
def PRE_first_tail_x8_r0_body.clo157 : List Nat := []
def PRE_first_tail_x8_r0_body.cln157 : List Nat := []
def PRE_first_tail_x8_r0_body.cli157 : List Nat := []
kernel_rfl PRE_first_tail_x8_r0_body.cheap157 : PRE_first_tail_x8_r0_body.s1521.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1519.heap (PRE_first_tail_x8_r0_body.cl157.filterMap fun a => (PRE_first_tail_x8_r0_body.s1521.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe157 : Nat.ble PRE_first_tail_x8_r0_body.s1519.next PRE_first_tail_x8_r0_body.s1521.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP157 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1519 PRE_first_tail_x8_r0_body.s1521 PRE_first_tail_x8_r0_body.cl157 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp157 : Conv.suppListB PRE_first_tail_x8_r0_body.s1521 6791 PRE_first_tail_x8_r0_body.cl157 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound157 : Conv.boundListB PRE_first_tail_x8_r0_body.s1521 PRE_first_tail_x8_r0_body.cl157 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK157 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1521.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln157.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1521.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK157 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1521.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo157.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1521.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK157 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1521.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli157.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1521.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst157 : Conv.sstListB 6791 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1521.ffi).mlx PRE_first_tail_x8_r0_body.cln157 PRE_first_tail_x8_r0_body.clo157 PRE_first_tail_x8_r0_body.cli157 = true

end Host.Load.Run.Tpl
end

section -- SiteCl157
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA157 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1521.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo157.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1521.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd157 : (PRE_first_tail_x8_r0_body.clo157 ++ PRE_first_tail_x8_r0_body.cln157 ++ PRE_first_tail_x8_r0_body.cli157).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle157 : Conv.Cnt.leB (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck157 : Conv.ncleanListB (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1521.ffi).mlx PRE_first_tail_x8_r0_body.clo157 PRE_first_tail_x8_r0_body.cln157 PRE_first_tail_x8_r0_body.cli157 = true
theorem PRE_first_tail_x8_r0_body.cncl157 (h : Conv.NClean (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx) : Conv.NClean (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1521.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle157 PRE_first_tail_x8_r0_body.ckA157 PRE_first_tail_x8_r0_body.cobjsK157 PRE_first_tail_x8_r0_body.cnodesK157 PRE_first_tail_x8_r0_body.citemsK157 PRE_first_tail_x8_r0_body.cbd157 PRE_first_tail_x8_r0_body.cck157

end Host.Load.Run.Tpl
end

section -- SiteS157
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 157 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc157 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P157 : LoadP := PRE_first_tail_x8_r0_body.Pc157.raise 18399
kernel_rfl PRE_first_tail_x8_r0_body.craise157 : Nat.ble PRE_first_tail_x8_r0_body.Pc157.N0 18399 = true
theorem PRE_first_tail_x8_r0_body.raised157 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc157 PRE_first_tail_x8_r0_body.P157 :=
  .inr ⟨18399, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise157, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_157 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1521.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_157 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1520.ffi)
def PRE_first_tail_x8_r0_body.khinv157 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x8_r0_body.kninv157 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS157 : List Nat := []
def PRE_first_tail_x8_r0_body.cnS157 : List Nat := List.range' 18399 0
def PRE_first_tail_x8_r0_body.ciS157 : List Nat := [] ++ List.range' 18399 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0157 : PRE_first_tail_x8_r0_body.kd157.nh0 = PRE_first_tail_x8_r0_body.cx0_157.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1157 : PRE_first_tail_x8_r0_body.kd157.nh1 = PRE_first_tail_x8_r0_body.cx1_157.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0157 : PRE_first_tail_x8_r0_body.kd157.nn0 = PRE_first_tail_x8_r0_body.cx0_157.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1157 : PRE_first_tail_x8_r0_body.kd157.nn1 = PRE_first_tail_x8_r0_body.cx1_157.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo157 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P157.lo && Nat.ble PRE_first_tail_x8_r0_body.P157.lo PRE_first_tail_x8_r0_body.cx0_157.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P157.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P157.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt157 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_157.mlx.next PRE_first_tail_x8_r0_body.cx1_157.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_157.mlx.nnext PRE_first_tail_x8_r0_body.cx1_157.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband157 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P157.NL && Nat.ble PRE_first_tail_x8_r0_body.P157.NL PRE_first_tail_x8_r0_body.P157.N0 && Nat.ble PRE_first_tail_x8_r0_body.P157.N0 PRE_first_tail_x8_r0_body.cx0_157.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow157 : PRE_first_tail_x8_r0_body.kd157.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren157 : checkRenG PRE_first_tail_x8_r0_body.kd157.hnd PRE_first_tail_x8_r0_body.khinv157 (phB PRE_first_tail_x8_r0_body.cx0_157.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband157 : PRE_first_tail_x8_r0_body.kd157.checkBand PRE_first_tail_x8_r0_body.P157.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos157 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd157.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren157 : checkRenG PRE_first_tail_x8_r0_body.kd157.node PRE_first_tail_x8_r0_body.kninv157 (pnB PRE_first_tail_x8_r0_body.cx0_157.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow157 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd157.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P157.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd157.nodeF j) PRE_first_tail_x8_r0_body.cx1_157.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a157 : PRE_first_tail_x8_r0_body.cx0_157.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b157 : PRE_first_tail_x8_r0_body.cx0_157.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1157 : PRE_first_tail_x8_r0_body.cx1_157.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend157 : PRE_first_tail_x8_r0_body.cx1_157.mlx.pending = PRE_first_tail_x8_r0_body.cx0_157.mlx.pending.map PRE_first_tail_x8_r0_body.kappa157.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh157 : PRE_first_tail_x8_r0_body.cx1_157.mlx.errh = PRE_first_tail_x8_r0_body.cx0_157.mlx.errh.map PRE_first_tail_x8_r0_body.kappa157.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles157 : PRE_first_tail_x8_r0_body.cx1_157.mlx.files = PRE_first_tail_x8_r0_body.cx0_157.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch157 : PRE_first_tail_x8_r0_body.cx1_157.mlx.arch = PRE_first_tail_x8_r0_body.cx0_157.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes157 : PRE_first_tail_x8_r0_body.cx1_157.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_157.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired157 : PRE_first_tail_x8_r0_body.cx1_157.mlx.wired = PRE_first_tail_x8_r0_body.cx0_157.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost157 : PRE_first_tail_x8_r0_body.cx1_157.host = PRE_first_tail_x8_r0_body.cx0_157.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd157`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0157 : PRE_first_tail_x8_r0_body.kd157.n0 = 2798375
kernel_rfl PRE_first_tail_x8_r0_body.ckn1157 : PRE_first_tail_x8_r0_body.kd157.n1 = 2798377
kernel_rfl PRE_first_tail_x8_r0_body.ckheap157 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd157.heap).all (fun x => Nat.ble 2798375 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl157 : (List.range 0).all (fun j => decide (PRE_first_tail_x8_r0_body.kd157.heap.get (2798375 + j) = nth? PRE_first_tail_x8_r0_body.pl157 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja157 : Nat.ble 2798375 2798375 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn157 : Nat.ble 6791 6791 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD157 : Nat.ble 2798375 PRE_first_tail_x8_r0_body.kd157.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn157 : Nat.ble 21300 PRE_first_tail_x8_r0_body.kd157.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn157 : Nat.ble 18399 PRE_first_tail_x8_r0_body.kd157.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb157 : Nat.ble 21300 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap157 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd157.heap).all (Nat.ble (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd157 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd157.hnd).all (Nat.ble (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode157 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd157.node).all (Nat.ble (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix157 : Conv.FixOld (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa157 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja157) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn157) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD157) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn157) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn157) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb157) PRE_first_tail_x8_r0_body.fheap157 PRE_first_tail_x8_r0_body.fhnd157 PRE_first_tail_x8_r0_body.fnode157
kernel_rfl PRE_first_tail_x8_r0_body.fcxn157 : (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn157 : (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0157 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_157.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_157.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk157 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd157.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A157 : PRE_first_tail_x8_r0_body.cx1_157.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS157.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_157.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O157 : PRE_first_tail_x8_r0_body.cx1_157.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS157.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_157.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N157 : PRE_first_tail_x8_r0_body.cx1_157.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS157.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_157.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I157 : PRE_first_tail_x8_r0_body.cx1_157.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS157.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_157.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd157 : (PRE_first_tail_x8_r0_body.clo157 ++ PRE_first_tail_x8_r0_body.cln157 ++ PRE_first_tail_x8_r0_body.cli157 ++ PRE_first_tail_x8_r0_body.cwS157 ++ PRE_first_tail_x8_r0_body.cnS157 ++ PRE_first_tail_x8_r0_body.ciS157).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW157 : PRE_first_tail_x8_r0_body.cwS157.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo157.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI157 : PRE_first_tail_x8_r0_body.ciS157.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli157.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN157 : PRE_first_tail_x8_r0_body.cnS157.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF157 : PRE_first_tail_x8_r0_body.cln157.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh157 : PRE_first_tail_x8_r0_body.clo157.all (handleOK PRE_first_tail_x8_r0_body.kappa157 PRE_first_tail_x8_r0_body.P157.lo PRE_first_tail_x8_r0_body.cx0_157.mlx PRE_first_tail_x8_r0_body.cx1_157.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo157 : PRE_first_tail_x8_r0_body.clo157.map (fun h => PRE_first_tail_x8_r0_body.cx1_157.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa157.handle h)) = PRE_first_tail_x8_r0_body.clo157.map (fun h => (PRE_first_tail_x8_r0_body.cx0_157.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa157.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok157 : PRE_first_tail_x8_r0_body.clo157.all (objOK PRE_first_tail_x8_r0_body.kappa157 PRE_first_tail_x8_r0_body.P157.NL PRE_first_tail_x8_r0_body.cx0_157.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd157 : PRE_first_tail_x8_r0_body.cln157.all (nodeOKF PRE_first_tail_x8_r0_body.kappa157 PRE_first_tail_x8_r0_body.P157 PRE_first_tail_x8_r0_body.cx0_157.mlx PRE_first_tail_x8_r0_body.cx1_157.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp157 : ((PRE_first_tail_x8_r0_body.cln157.filter (fullB PRE_first_tail_x8_r0_body.P157))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_157.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa157.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln157.filter (fullB PRE_first_tail_x8_r0_body.P157))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_157.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa157.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI157 : incrB PRE_first_tail_x8_r0_body.kd157.nodeF (List.range' 18399 0) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK157 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd157.node).all (fun k => Nat.ble 18399 k && Nat.blt k 18399) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL157 : (PRE_first_tail_x8_r0_body.cln157.filter (Nat.ble PRE_first_tail_x8_r0_body.P157.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd157.nodeF i) && (Nat.blt i 18399 || Nat.ble PRE_first_tail_x8_r0_body.kd157.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord157 : (PRE_first_tail_x8_r0_body.cln157.filter (Nat.ble PRE_first_tail_x8_r0_body.P157.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd157.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd157.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd157.nodeF j) (PRE_first_tail_x8_r0_body.kd157.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow157 PRE_first_tail_x8_r0_body.cnn1157 PRE_first_tail_x8_r0_body.fnordI157 PRE_first_tail_x8_r0_body.fnordK157 PRE_first_tail_x8_r0_body.fnordL157
kernel_rfl PRE_first_tail_x8_r0_body.fi157 : PRE_first_tail_x8_r0_body.cli157.all (pnB PRE_first_tail_x8_r0_body.cx0_157.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii157 : PRE_first_tail_x8_r0_body.cli157.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_157.mlx.items.get (PRE_first_tail_x8_r0_body.kappa157.node k) = (PRE_first_tail_x8_r0_body.cx0_157.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa157.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot157 (clean : Conv.NClean (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P157.NL) (cl : SSt (· < 6791) PRE_first_tail_x8_r0_body.cx0_157.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P157 6791 PRE_first_tail_x8_r0_body.kappa157 PRE_first_tail_x8_r0_body.kd157 PRE_first_tail_x8_r0_body.khinv157 PRE_first_tail_x8_r0_body.kninv157 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx PRE_first_tail_x8_r0_body.cx0_157.mlx PRE_first_tail_x8_r0_body.cx1_157.mlx (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo157 PRE_first_tail_x8_r0_body.cln157 PRE_first_tail_x8_r0_body.cli157 PRE_first_tail_x8_r0_body.cwS157 PRE_first_tail_x8_r0_body.cnS157 PRE_first_tail_x8_r0_body.ciS157 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0157, PRE_first_tail_x8_r0_body.cnh1157, PRE_first_tail_x8_r0_body.cnn0157, PRE_first_tail_x8_r0_body.cnn1157, PRE_first_tail_x8_r0_body.cplo157, PRE_first_tail_x8_r0_body.ccnt157, PRE_first_tail_x8_r0_body.cnband157, PRE_first_tail_x8_r0_body.chbelow157, PRE_first_tail_x8_r0_body.chren157, PRE_first_tail_x8_r0_body.cband157, PRE_first_tail_x8_r0_body.cnh1pos157, PRE_first_tail_x8_r0_body.cnren157, PRE_first_tail_x8_r0_body.cnlow157, PRE_first_tail_x8_r0_body.cabs0a157, PRE_first_tail_x8_r0_body.cabs0b157, PRE_first_tail_x8_r0_body.ctok1157, PRE_first_tail_x8_r0_body.cpend157, PRE_first_tail_x8_r0_body.cerrh157, PRE_first_tail_x8_r0_body.cfiles157, PRE_first_tail_x8_r0_body.carch157, PRE_first_tail_x8_r0_body.csizes157, PRE_first_tail_x8_r0_body.cwired157, PRE_first_tail_x8_r0_body.cfix157, clean, PRE_first_tail_x8_r0_body.fcxn157, PRE_first_tail_x8_r0_body.fcnn157, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0157, PRE_first_tail_x8_r0_body.fnk157, PRE_first_tail_x8_r0_body.ckA157, PRE_first_tail_x8_r0_body.cobjsK157, PRE_first_tail_x8_r0_body.cnodesK157, PRE_first_tail_x8_r0_body.citemsK157, PRE_first_tail_x8_r0_body.f1A157, PRE_first_tail_x8_r0_body.f1O157, PRE_first_tail_x8_r0_body.f1N157, PRE_first_tail_x8_r0_body.f1I157, PRE_first_tail_x8_r0_body.fbd157, PRE_first_tail_x8_r0_body.fincW157, PRE_first_tail_x8_r0_body.fincI157, PRE_first_tail_x8_r0_body.fincN157, PRE_first_tail_x8_r0_body.flnF157, PRE_first_tail_x8_r0_body.fh157, PRE_first_tail_x8_r0_body.fo157, PRE_first_tail_x8_r0_body.fok157, PRE_first_tail_x8_r0_body.fnd157, PRE_first_tail_x8_r0_body.fp157, PRE_first_tail_x8_r0_body.fnord157, PRE_first_tail_x8_r0_body.fi157, PRE_first_tail_x8_r0_body.fii157⟩
theorem PRE_first_tail_x8_r0_body.cnshift157 (clean : Conv.NClean (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P157.NL) (cl : SSt (· < 6791) PRE_first_tail_x8_r0_body.cx0_157.mlx) : NShift PRE_first_tail_x8_r0_body.P157 6791 PRE_first_tail_x8_r0_body.kappa157 PRE_first_tail_x8_r0_body.cx0_157 PRE_first_tail_x8_r0_body.cx1_157 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot157 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost157 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0157 PRE_first_tail_x8_r0_body.ckn1157 PRE_first_tail_x8_r0_body.ckheap157 PRE_first_tail_x8_r0_body.ckpl157)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_157 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1519.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_157 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1519.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_157 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1519.ffi) = some PRE_first_tail_x8_r0_body.fxC_157
kernel_rfl PRE_first_tail_x8_r0_body.okrC_157 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1519.ffi) = some PRE_first_tail_x8_r0_body.krC_157
noncomputable def PRE_first_tail_x8_r0_body.fx0_157 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1521.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_157 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1521.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_157 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1521.ffi) = some PRE_first_tail_x8_r0_body.fx0_157
kernel_rfl PRE_first_tail_x8_r0_body.okr0_157 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1521.ffi) = some PRE_first_tail_x8_r0_body.kr0_157
noncomputable def PRE_first_tail_x8_r0_body.fx1_157 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1520.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_157 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1520.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_157 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1520.ffi) = some PRE_first_tail_x8_r0_body.fx1_157
kernel_rfl PRE_first_tail_x8_r0_body.okr1_157 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1520.ffi) = some PRE_first_tail_x8_r0_body.kr1_157
kernel_rfl PRE_first_tail_x8_r0_body.ff0157 : PRE_first_tail_x8_r0_body.fx0_157 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_157 (PRE_first_tail_x8_r0_body.clo157.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_157.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1157 : PRE_first_tail_x8_r0_body.fx1_157 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_157 (PRE_first_tail_x8_r0_body.cwS157.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_157.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck157 : freedLB PRE_first_tail_x8_r0_body.kappa157 PRE_first_tail_x8_r0_body.cx0_157.mlx PRE_first_tail_x8_r0_body.fx0_157 PRE_first_tail_x8_r0_body.fx1_157 PRE_first_tail_x8_r0_body.clo157 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0157 : PRE_first_tail_x8_r0_body.kr0_157.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_157.flags (PRE_first_tail_x8_r0_body.clo157.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_157.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0157 : PRE_first_tail_x8_r0_body.kr0_157.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_157.targs (PRE_first_tail_x8_r0_body.clo157.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_157.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1157 : PRE_first_tail_x8_r0_body.kr1_157.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_157.flags (PRE_first_tail_x8_r0_body.cwS157.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_157.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1157 : PRE_first_tail_x8_r0_body.kr1_157.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_157.targs (PRE_first_tail_x8_r0_body.cwS157.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_157.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck157 : krecLB PRE_first_tail_x8_r0_body.kappa157 6791 PRE_first_tail_x8_r0_body.cx0_157.mlx PRE_first_tail_x8_r0_body.kr0_157 PRE_first_tail_x8_r0_body.kr1_157 PRE_first_tail_x8_r0_body.clo157 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn157 : Nat.ble 6791 6791 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge157 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1520.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1521.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR157 : pendRegB PRE_first_tail_x8_r0_body.kappa157 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1521.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe157 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1521.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1520.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift157 (clean : Conv.NClean (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P157.NL) (cl : SSt (· < 6791) PRE_first_tail_x8_r0_body.cx0_157.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_157.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_157.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_157.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1519.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_157.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P157 6791 PRE_first_tail_x8_r0_body.kappa157 PRE_first_tail_x8_r0_body.s1521.ffi PRE_first_tail_x8_r0_body.s1520.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift157 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue157, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp157 t ht),
    PRE_first_tail_x8_r0_body.cbridge157,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1521.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1520.ffi) (PRE_first_tail_x8_r0_body.cfoot157 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_157 PRE_first_tail_x8_r0_body.ofx1_157 hobjC PRE_first_tail_x8_r0_body.ff0157 PRE_first_tail_x8_r0_body.ff1157 PRE_first_tail_x8_r0_body.ffck157,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1521.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1520.ffi) (PRE_first_tail_x8_r0_body.cfoot157 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_157 PRE_first_tail_x8_r0_body.okr1_157 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn157) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0157 PRE_first_tail_x8_r0_body.fkt0157 PRE_first_tail_x8_r0_body.fkf1157 PRE_first_tail_x8_r0_body.fkt1157 PRE_first_tail_x8_r0_body.fkck157,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0157 PRE_first_tail_x8_r0_body.cnh1157 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe157) PRE_first_tail_x8_r0_body.cpendR157⟩

end Host.Load.Run.Tpl
end

section -- st157/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st157 0
host_stream_state PRE_first_tail_x8_r0_body.st157 1
host_stream_state PRE_first_tail_x8_r0_body.st157 2
end Host.Load.Run.Tpl
end

section -- Site157
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 157 of chain `PRE_first_tail_x8_r0_body`: `rowBlocks__g157__g158` (`rowBlocks`), the call state `PRE_first_tail_x8_r0_body.s1519`, the merged state `PRE_first_tail_x8_r0_body.s1520`,
the site template `PRE_first_tail_x8_r0_body.st157` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1521`: the merge.
The footprint's facts are in `SiteF157`, the compaction's in `SiteC157`, `SiteK157`, `SiteNa157`, `SiteNb157`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso157 : PRE_first_tail_x8_r0_body.st157.s0 = { PRE_first_tail_x8_r0_body.s1519 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs157 : List Frame := PRE_first_tail_x8_r0_body.s1519.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_157 : PRE_first_tail_x8_r0_body.S1519.tab.length = 6791
kernel_rfl PRE_first_tail_x8_r0_body.tab0_157 : PRE_first_tail_x8_r0_body.st157.S0.tab = PRE_first_tail_x8_r0_body.S1519.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws157 : List Nat := [3654, 3655]
kernel_rfl PRE_first_tail_x8_r0_body.fresh157 : (PRE_first_tail_x8_r0_body.S1519.tab.all fun e => PRE_first_tail_x8_r0_body.ws157.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1519.oracle.all fun q => PRE_first_tail_x8_r0_body.ws157.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab157 : PRE_first_tail_x8_r0_body.S1520.tab = PRE_first_tail_x8_r0_body.S1519.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws157
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen157 : PRE_first_tail_x8_r0_body.st157.S2.tab.length - PRE_first_tail_x8_r0_body.st157.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged157`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap157 : PRE_first_tail_x8_r0_body.s1520.heap = PRE_first_tail_x8_r0_body.st157.s2.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext157 : PRE_first_tail_x8_r0_body.s1520.next = PRE_first_tail_x8_r0_body.st157.s2.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl157 : PRE_first_tail_x8_r0_body.s1520.ctl = PRE_first_tail_x8_r0_body.st157.s2.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack157 : PRE_first_tail_x8_r0_body.s1520.stack = PRE_first_tail_x8_r0_body.st157.s2.stack ++ PRE_first_tail_x8_r0_body.s1519.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs157 : PRE_first_tail_x8_r0_body.s1520.jobs = PRE_first_tail_x8_r0_body.st157.s2.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi157 : PRE_first_tail_x8_r0_body.s1520.ffi = PRE_first_tail_x8_r0_body.st157.s2.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace157 : PRE_first_tail_x8_r0_body.s1520.trace = PRE_first_tail_x8_r0_body.st157.s2.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores157 : PRE_first_tail_x8_r0_body.s1520.stores = PRE_first_tail_x8_r0_body.st157.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD157
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 157 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived157 : PRE_first_tail_x8_r0_body.nr157.map (fun r => nth? PRE_first_tail_x8_r0_body.st157.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo157 : PRE_first_tail_x8_r0_body.nr157.all (Nat.ble 6791) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj157 : PRE_first_tail_x8_r0_body.cws157.all (fun c => !PRE_first_tail_x8_r0_body.ws157.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ157 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws157 PRE_first_tail_x8_r0_body.crs157 PRE_first_tail_x8_r0_body.ws157

end Host.Load.Run.Tpl
end

section -- st157/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st157`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st157.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st157.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st157.s2.heap PRE_first_tail_x8_r0_body.st157.wrR ++ freshOf PRE_first_tail_x8_r0_body.st157.s2.heap PRE_first_tail_x8_r0_body.st157.s0.next PRE_first_tail_x8_r0_body.st157.s2.next
noncomputable def PRE_first_tail_x8_r0_body.st157.wr : List Nat := PRE_first_tail_x8_r0_body.st157.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st157.heapFoot : PRE_first_tail_x8_r0_body.st157.s2.heap = setAll PRE_first_tail_x8_r0_body.st157.s0.heap PRE_first_tail_x8_r0_body.st157.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st157.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st157.s0.next PRE_first_tail_x8_r0_body.st157.s2.next = true
theorem PRE_first_tail_x8_r0_body.st157.grows : PRE_first_tail_x8_r0_body.st157.s0.next ≤ PRE_first_tail_x8_r0_body.st157.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st157.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st157.wh : List Nat := []
def PRE_first_tail_x8_r0_body.st157.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st157.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st157.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st157.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st157.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st157.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st157.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st157.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st157.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st157.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st157.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st157.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st157.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st157.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st157.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st157.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st157.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st157.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st157.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st157.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st157.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st157.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st157.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st157.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st157.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st157.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st157.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st157.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st157.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st157.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF157
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 157 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB157 : nodupT PRE_first_tail_x8_r0_body.st157.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup157 : PRE_first_tail_x8_r0_body.st157.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB157).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB157 : PRE_first_tail_x8_r0_body.st157.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound157 : ∀ b ∈ PRE_first_tail_x8_r0_body.st157.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB157 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr157 := PRE_first_tail_x8_r0_body.st157.s2.trace.take 0
kernel_rfl PRE_first_tail_x8_r0_body.traceEq157 : PRE_first_tail_x8_r0_body.st157.s2.trace = PRE_first_tail_x8_r0_body.trFr157 ++ PRE_first_tail_x8_r0_body.st157.s0.trace
theorem PRE_first_tail_x8_r0_body.trace157 : ∃ fr, PRE_first_tail_x8_r0_body.st157.s2.trace = fr ++ PRE_first_tail_x8_r0_body.st157.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq157⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide157 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB157 : (PRE_first_tail_x8_r0_body.wide157.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st157.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix157 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide157, WFix Map.id (Present PRE_first_tail_x8_r0_body.st157.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB157 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL157
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 157 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1520`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO157 : PRE_first_tail_x8_r0_body.st157.S0.oracle = PRE_first_tail_x8_r0_body.st157.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B157 : PRE_first_tail_x8_r0_body.st157.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st157.s0.next || (PRE_first_tail_x8_r0_body.st157.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot157 : Conv.StageFoot PRE_first_tail_x8_r0_body.st157.wr PRE_first_tail_x8_r0_body.st157.s0 PRE_first_tail_x8_r0_body.st157.s2 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st157.heapFoot PRE_first_tail_x8_r0_body.wrNodup157 PRE_first_tail_x8_r0_body.wrBound157 PRE_first_tail_x8_r0_body.wr0B157 PRE_first_tail_x8_r0_body.st157.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged157 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st157.F.S → PRE_first_tail_x8_r0_body.st157.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st157.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st157.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs157 PRE_first_tail_x8_r0_body.st157.wr PRE_first_tail_x8_r0_body.s1519 PRE_first_tail_x8_r0_body.st157.s2 PRE_first_tail_x8_r0_body.st157.s0
      PRE_first_tail_x8_r0_body.st157.s2.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st157.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1520 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso157 PRE_first_tail_x8_r0_body.stFoot157 PRE_first_tail_x8_r0_body.wrNodup157 PRE_first_tail_x8_r0_body.wrBound157 PRE_first_tail_x8_r0_body.trace157 PRE_first_tail_x8_r0_body.mheap157
    PRE_first_tail_x8_r0_body.mnext157 PRE_first_tail_x8_r0_body.mctl157 PRE_first_tail_x8_r0_body.mstack157 PRE_first_tail_x8_r0_body.mjobs157 PRE_first_tail_x8_r0_body.mffi157 PRE_first_tail_x8_r0_body.mtrace157 PRE_first_tail_x8_r0_body.mstores157 h

def PRE_first_tail_x8_r0_body.arrEl157_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE157_2665 : arrOf PRE_first_tail_x8_r0_body.s1520 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl157_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA157_2665 : isArrB PRE_first_tail_x8_r0_body.s1520 2665 = true
theorem PRE_first_tail_x8_r0_body.arr157_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1520.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl157_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE157_2665 PRE_first_tail_x8_r0_body.arrA157_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN157_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl157_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR157_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl157_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN157_2665

def PRE_first_tail_x8_r0_body.arrEl157_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE157_2673467 : arrOf PRE_first_tail_x8_r0_body.s1520 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl157_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA157_2673467 : isArrB PRE_first_tail_x8_r0_body.s1520 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr157_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1520.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl157_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE157_2673467 PRE_first_tail_x8_r0_body.arrA157_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN157_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl157_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR157_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl157_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN157_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k157 : isArrB PRE_first_tail_x8_r0_body.s1520 4910 = false
theorem PRE_first_tail_x8_r0_body.keep157 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1520 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k157 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr157_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl157_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ157
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 157 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1519`, the merged
state `PRE_first_tail_x8_r0_body.s1520`, the canonical state `PRE_first_tail_x8_r0_body.s1521`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl157 : PRE_first_tail_x8_r0_body.pl157.all (Nat.ble PRE_first_tail_x8_r0_body.s1519.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd157 : nodupT PRE_first_tail_x8_r0_body.pl157 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1157 : Nat.ble PRE_first_tail_x8_r0_body.s1519.next 2798377 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst157 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1519.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn157 : PRE_first_tail_x8_r0_body.s1521.next = PRE_first_tail_x8_r0_body.s1519.next + PRE_first_tail_x8_r0_body.pl157.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn157 : PRE_first_tail_x8_r0_body.s1520.next = 2798377
kernel_rfl PRE_first_tail_x8_r0_body.zgrow157 : Nat.ble PRE_first_tail_x8_r0_body.s1521.next PRE_first_tail_x8_r0_body.s1520.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh157 : PRE_first_tail_x8_r0_body.S1519.tab.all (fun e => PRE_first_tail_x8_r0_body.cws157.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd157 : nodupT PRE_first_tail_x8_r0_body.cws157 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi157 : PRE_first_tail_x8_r0_body.nr157.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1520.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt157 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1519.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg157_2665 : PRE_first_tail_x8_r0_body.s1521.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1521 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk157_2665 : (objOf PRE_first_tail_x8_r0_body.s1521 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm157_2665 : PRE_first_tail_x8_r0_body.s1520.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa157.obj (objOf PRE_first_tail_x8_r0_body.s1521 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1520 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg157_2673467 : PRE_first_tail_x8_r0_body.s1521.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1521 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk157_2673467 : (objOf PRE_first_tail_x8_r0_body.s1521 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm157_2673467 : PRE_first_tail_x8_r0_body.s1520.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa157.obj (objOf PRE_first_tail_x8_r0_body.s1521 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1520 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw157_4910 : (PRE_first_tail_x8_r0_body.s1521.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw157_2673472 : (PRE_first_tail_x8_r0_body.s1521.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw157_2673473 : (PRE_first_tail_x8_r0_body.s1521.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd157 : PRE_first_tail_x8_r0_body.cl157.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr157 : PRE_first_tail_x8_r0_body.st157.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1519.next || PRE_first_tail_x8_r0_body.cl157.contains b) = true
def PRE_first_tail_x8_r0_body.zl157 : List Nat := PRE_first_tail_x8_r0_body.cl157.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE157 : PRE_first_tail_x8_r0_body.zl157.map (fun a => PRE_first_tail_x8_r0_body.s1520.heap.get (PRE_first_tail_x8_r0_body.kappa157.a a)) = PRE_first_tail_x8_r0_body.zl157.map (fun a => (PRE_first_tail_x8_r0_body.s1521.heap.get a).map PRE_first_tail_x8_r0_body.kappa157.hobj)
theorem PRE_first_tail_x8_r0_body.zimg157 : HeapImg PRE_first_tail_x8_r0_body.kappa157 PRE_first_tail_x8_r0_body.s1521 PRE_first_tail_x8_r0_body.s1520 PRE_first_tail_x8_r0_body.zl157 := PRE_first_tail_x8_r0_body.zimgE157
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl157 : PRE_first_tail_x8_r0_body.s1520.ctl = PRE_first_tail_x8_r0_body.kappa157.ctl PRE_first_tail_x8_r0_body.s1521.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack157 : PRE_first_tail_x8_r0_body.s1520.stack = PRE_first_tail_x8_r0_body.s1521.stack.map PRE_first_tail_x8_r0_body.kappa157.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs157 : PRE_first_tail_x8_r0_body.s1520.jobs = PRE_first_tail_x8_r0_body.s1521.jobs.map PRE_first_tail_x8_r0_body.kappa157.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores157 : PRE_first_tail_x8_r0_body.s1520.stores = PRE_first_tail_x8_r0_body.kappa157.stores PRE_first_tail_x8_r0_body.s1521.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots157 : checkRootsSupp PRE_first_tail_x8_r0_body.s1521 6791 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC157 : PRE_first_tail_x8_r0_body.S1519.tab.length + PRE_first_tail_x8_r0_body.cws157.length = 6791
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap157 : PRE_first_tail_x8_r0_body.kappa157 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1519.next 2798377 PRE_first_tail_x8_r0_body.S1519.tab.length PRE_first_tail_x8_r0_body.pl157 (PRE_first_tail_x8_r0_body.nr157.map NumV.ref) PRE_first_tail_x8_r0_body.kd157.big
  PRE_first_tail_x8_r0_body.kd157.region PRE_first_tail_x8_r0_body.kd157.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin157 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1521.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc157 : Conv.jcleanListB (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1521 PRE_first_tail_x8_r0_body.cl157 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB157 : noBigRootsP (fun i => !Conv.oldBigB (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1521.trace PRE_first_tail_x8_r0_body.s1521 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm157 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 18399 = true
theorem PRE_first_tail_x8_r0_body.cjcl157 (h : Conv.JClean (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1519) : Conv.JClean (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1521 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle157)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap157 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd157 a ha)) PRE_first_tail_x8_r0_body.zjc157

end Host.Load.Run.Tpl
end

section -- st157/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st157.bodyLast from PRE_first_tail_x8_r0_body.st157.s1 to PRE_first_tail_x8_r0_body.st157.s2 :
  interpS (step PRE_first_tail_x8_r0_body.st157.F PRE_first_tail_x8_r0_body.st157.s1).run PRE_first_tail_x8_r0_body.st157.S1 = some (PRE_first_tail_x8_r0_body.st157.s2, PRE_first_tail_x8_r0_body.st157.S2)
kernel_rfl PRE_first_tail_x8_r0_body.st157.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st157.s1.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st157.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st157.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st157/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st157.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st157.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st157.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st157.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st157.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st157.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st157.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st157.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st157.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st157.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st157.s0 PRE_first_tail_x8_r0_body.st157.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st157.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st157.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st157.s1 PRE_first_tail_x8_r0_body.st157.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st157/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st157.bodyK0F from PRE_first_tail_x8_r0_body.st157.s0 to PRE_first_tail_x8_r0_body.st157.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st157.F (PRE_first_tail_x8_r0_body.st157.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st157.ks 0).getD 0) PRE_first_tail_x8_r0_body.st157.s0 PRE_first_tail_x8_r0_body.st157.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st157.s1, PRE_first_tail_x8_r0_body.st157.S1)
theorem PRE_first_tail_x8_r0_body.st157.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st157.F (PRE_first_tail_x8_r0_body.st157.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st157.ks 0).getD 0) PRE_first_tail_x8_r0_body.st157.s0 PRE_first_tail_x8_r0_body.st157.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st157.s1, PRE_first_tail_x8_r0_body.st157.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st157.bodyOkLN_ok PRE_first_tail_x8_r0_body.st157.bodyK0F
end Host.Load.Run.Tpl
end

section -- st157/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st157.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st157.F (PRE_first_tail_x8_r0_body.st157.bodyOkL bytes rows) 27 PRE_first_tail_x8_r0_body.st157.s0 PRE_first_tail_x8_r0_body.st157.S0 = some (PRE_first_tail_x8_r0_body.st157.s1, PRE_first_tail_x8_r0_body.st157.S1) :=
  (congrFun (congrFun PRE_first_tail_x8_r0_body.st157.bodyK0 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st157.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st157.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st157.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st157.F (PRE_first_tail_x8_r0_body.st157.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st157.s0
  S0 := PRE_first_tail_x8_r0_body.st157.S0
  s1 := PRE_first_tail_x8_r0_body.st157.s1
  S1 := PRE_first_tail_x8_r0_body.st157.S1
  s2 := PRE_first_tail_x8_r0_body.st157.s2
  S2 := PRE_first_tail_x8_r0_body.st157.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st157.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st157.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st157.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st157.bodyHalt
  last := PRE_first_tail_x8_r0_body.st157.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st157.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC158
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 158 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1525` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa158` into the merged state
`PRE_first_tail_x8_r0_body.s1524`. -/

def PRE_first_tail_x8_r0_body.pl158 : List Nat := [2798673]
def PRE_first_tail_x8_r0_body.nr158 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd158 : RData :=
  ⟨2798664, 2798674, Stage.setAll PTrie.nil [(2798663, 2798673)], Stage.setAll PTrie.nil [],
   21307, 21307, 18403, 18403, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa158 : Map :=
  Conv.Map.compact 2798663 2798674 6808 PRE_first_tail_x8_r0_body.pl158 (PRE_first_tail_x8_r0_body.nr158.map NumV.ref) PRE_first_tail_x8_r0_body.kd158.big
    PRE_first_tail_x8_r0_body.kd158.region PRE_first_tail_x8_r0_body.kd158.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws158 : List Nat := []
noncomputable def PRE_first_tail_x8_r0_body.crs158 : List SymE := PRE_first_tail_x8_r0_body.nr158.map fun r => (nth? PRE_first_tail_x8_r0_body.S1524.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta158 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws158 PRE_first_tail_x8_r0_body.crs158
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB158 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x8_r0_body.ctab158 : PRE_first_tail_x8_r0_body.S1525.tab = PRE_first_tail_x8_r0_body.S1523.tab ++ PRE_first_tail_x8_r0_body.cws158.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace158 : PRE_first_tail_x8_r0_body.s1525.trace = PRE_first_tail_x8_r0_body.s1523.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext158 : PRE_first_tail_x8_r0_body.s1525.next = 2798664
kernel_rfl PRE_first_tail_x8_r0_body.ccounters158 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1525.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1525.ffi).mlx.nnext) = (21307, 18403)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue158 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1524.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1525.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa158.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp158 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1525.ffi).mlx.tokens.all (bSN 6808) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean158 : Conv.cleanListB 21307 131072 (fun r => Nat.ble 85228 r) PRE_first_tail_x8_r0_body.s1525
    (PRE_first_tail_x8_r0_body.wrB158 ++ (List.range 1).map (2798663 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs158 : bigsOutB 21307 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1525.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK158
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl158`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl158 : List Nat := [2665, 2673467, 2798663]
def PRE_first_tail_x8_r0_body.clo158 : List Nat := []
def PRE_first_tail_x8_r0_body.cln158 : List Nat := []
def PRE_first_tail_x8_r0_body.cli158 : List Nat := []
kernel_rfl PRE_first_tail_x8_r0_body.cheap158 : PRE_first_tail_x8_r0_body.s1525.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1523.heap (PRE_first_tail_x8_r0_body.cl158.filterMap fun a => (PRE_first_tail_x8_r0_body.s1525.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe158 : Nat.ble PRE_first_tail_x8_r0_body.s1523.next PRE_first_tail_x8_r0_body.s1525.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP158 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1523 PRE_first_tail_x8_r0_body.s1525 PRE_first_tail_x8_r0_body.cl158 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp158 : Conv.suppListB PRE_first_tail_x8_r0_body.s1525 6808 PRE_first_tail_x8_r0_body.cl158 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound158 : Conv.boundListB PRE_first_tail_x8_r0_body.s1525 PRE_first_tail_x8_r0_body.cl158 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK158 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1525.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln158.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1525.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK158 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1525.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo158.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1525.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK158 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1525.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli158.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1525.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst158 : Conv.sstListB 6808 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1525.ffi).mlx PRE_first_tail_x8_r0_body.cln158 PRE_first_tail_x8_r0_body.clo158 PRE_first_tail_x8_r0_body.cli158 = true

end Host.Load.Run.Tpl
end

section -- SiteCl158
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA158 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1525.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo158.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1525.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd158 : (PRE_first_tail_x8_r0_body.clo158 ++ PRE_first_tail_x8_r0_body.cln158 ++ PRE_first_tail_x8_r0_body.cli158).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle158 : Conv.Cnt.leB (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt) (⟨21307, 18403, 2798664, 6808⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck158 : Conv.ncleanListB (⟨21307, 18403, 2798664, 6808⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1525.ffi).mlx PRE_first_tail_x8_r0_body.clo158 PRE_first_tail_x8_r0_body.cln158 PRE_first_tail_x8_r0_body.cli158 = true
theorem PRE_first_tail_x8_r0_body.cncl158 (h : Conv.NClean (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx) : Conv.NClean (⟨21307, 18403, 2798664, 6808⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1525.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle158 PRE_first_tail_x8_r0_body.ckA158 PRE_first_tail_x8_r0_body.cobjsK158 PRE_first_tail_x8_r0_body.cnodesK158 PRE_first_tail_x8_r0_body.citemsK158 PRE_first_tail_x8_r0_body.cbd158 PRE_first_tail_x8_r0_body.cck158

end Host.Load.Run.Tpl
end

section -- SiteS158
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 158 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc158 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P158 : LoadP := PRE_first_tail_x8_r0_body.Pc158.raise 18403
kernel_rfl PRE_first_tail_x8_r0_body.craise158 : Nat.ble PRE_first_tail_x8_r0_body.Pc158.N0 18403 = true
theorem PRE_first_tail_x8_r0_body.raised158 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc158 PRE_first_tail_x8_r0_body.P158 :=
  .inr ⟨18403, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise158, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_158 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1525.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_158 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1524.ffi)
def PRE_first_tail_x8_r0_body.khinv158 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x8_r0_body.kninv158 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS158 : List Nat := []
def PRE_first_tail_x8_r0_body.cnS158 : List Nat := List.range' 18403 0
def PRE_first_tail_x8_r0_body.ciS158 : List Nat := [] ++ List.range' 18403 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0158 : PRE_first_tail_x8_r0_body.kd158.nh0 = PRE_first_tail_x8_r0_body.cx0_158.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1158 : PRE_first_tail_x8_r0_body.kd158.nh1 = PRE_first_tail_x8_r0_body.cx1_158.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0158 : PRE_first_tail_x8_r0_body.kd158.nn0 = PRE_first_tail_x8_r0_body.cx0_158.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1158 : PRE_first_tail_x8_r0_body.kd158.nn1 = PRE_first_tail_x8_r0_body.cx1_158.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo158 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P158.lo && Nat.ble PRE_first_tail_x8_r0_body.P158.lo PRE_first_tail_x8_r0_body.cx0_158.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P158.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P158.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt158 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_158.mlx.next PRE_first_tail_x8_r0_body.cx1_158.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_158.mlx.nnext PRE_first_tail_x8_r0_body.cx1_158.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband158 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P158.NL && Nat.ble PRE_first_tail_x8_r0_body.P158.NL PRE_first_tail_x8_r0_body.P158.N0 && Nat.ble PRE_first_tail_x8_r0_body.P158.N0 PRE_first_tail_x8_r0_body.cx0_158.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow158 : PRE_first_tail_x8_r0_body.kd158.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren158 : checkRenG PRE_first_tail_x8_r0_body.kd158.hnd PRE_first_tail_x8_r0_body.khinv158 (phB PRE_first_tail_x8_r0_body.cx0_158.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband158 : PRE_first_tail_x8_r0_body.kd158.checkBand PRE_first_tail_x8_r0_body.P158.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos158 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd158.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren158 : checkRenG PRE_first_tail_x8_r0_body.kd158.node PRE_first_tail_x8_r0_body.kninv158 (pnB PRE_first_tail_x8_r0_body.cx0_158.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow158 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd158.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P158.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd158.nodeF j) PRE_first_tail_x8_r0_body.cx1_158.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a158 : PRE_first_tail_x8_r0_body.cx0_158.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b158 : PRE_first_tail_x8_r0_body.cx0_158.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1158 : PRE_first_tail_x8_r0_body.cx1_158.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend158 : PRE_first_tail_x8_r0_body.cx1_158.mlx.pending = PRE_first_tail_x8_r0_body.cx0_158.mlx.pending.map PRE_first_tail_x8_r0_body.kappa158.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh158 : PRE_first_tail_x8_r0_body.cx1_158.mlx.errh = PRE_first_tail_x8_r0_body.cx0_158.mlx.errh.map PRE_first_tail_x8_r0_body.kappa158.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles158 : PRE_first_tail_x8_r0_body.cx1_158.mlx.files = PRE_first_tail_x8_r0_body.cx0_158.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch158 : PRE_first_tail_x8_r0_body.cx1_158.mlx.arch = PRE_first_tail_x8_r0_body.cx0_158.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes158 : PRE_first_tail_x8_r0_body.cx1_158.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_158.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired158 : PRE_first_tail_x8_r0_body.cx1_158.mlx.wired = PRE_first_tail_x8_r0_body.cx0_158.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost158 : PRE_first_tail_x8_r0_body.cx1_158.host = PRE_first_tail_x8_r0_body.cx0_158.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd158`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0158 : PRE_first_tail_x8_r0_body.kd158.n0 = 2798664
kernel_rfl PRE_first_tail_x8_r0_body.ckn1158 : PRE_first_tail_x8_r0_body.kd158.n1 = 2798674
kernel_rfl PRE_first_tail_x8_r0_body.ckheap158 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd158.heap).all (fun x => Nat.ble 2798663 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl158 : (List.range 1).all (fun j => decide (PRE_first_tail_x8_r0_body.kd158.heap.get (2798663 + j) = nth? PRE_first_tail_x8_r0_body.pl158 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja158 : Nat.ble 2798663 2798663 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn158 : Nat.ble 6808 6808 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD158 : Nat.ble 2798663 PRE_first_tail_x8_r0_body.kd158.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn158 : Nat.ble 21307 PRE_first_tail_x8_r0_body.kd158.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn158 : Nat.ble 18403 PRE_first_tail_x8_r0_body.kd158.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb158 : Nat.ble 21307 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap158 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd158.heap).all (Nat.ble (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd158 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd158.hnd).all (Nat.ble (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode158 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd158.node).all (Nat.ble (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix158 : Conv.FixOld (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa158 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja158) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn158) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD158) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn158) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn158) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb158) PRE_first_tail_x8_r0_body.fheap158 PRE_first_tail_x8_r0_body.fhnd158 PRE_first_tail_x8_r0_body.fnode158
kernel_rfl PRE_first_tail_x8_r0_body.fcxn158 : (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn158 : (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0158 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_158.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_158.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk158 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd158.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A158 : PRE_first_tail_x8_r0_body.cx1_158.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS158.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_158.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O158 : PRE_first_tail_x8_r0_body.cx1_158.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS158.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_158.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N158 : PRE_first_tail_x8_r0_body.cx1_158.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS158.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_158.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I158 : PRE_first_tail_x8_r0_body.cx1_158.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS158.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_158.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd158 : (PRE_first_tail_x8_r0_body.clo158 ++ PRE_first_tail_x8_r0_body.cln158 ++ PRE_first_tail_x8_r0_body.cli158 ++ PRE_first_tail_x8_r0_body.cwS158 ++ PRE_first_tail_x8_r0_body.cnS158 ++ PRE_first_tail_x8_r0_body.ciS158).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW158 : PRE_first_tail_x8_r0_body.cwS158.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo158.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI158 : PRE_first_tail_x8_r0_body.ciS158.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli158.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN158 : PRE_first_tail_x8_r0_body.cnS158.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF158 : PRE_first_tail_x8_r0_body.cln158.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh158 : PRE_first_tail_x8_r0_body.clo158.all (handleOK PRE_first_tail_x8_r0_body.kappa158 PRE_first_tail_x8_r0_body.P158.lo PRE_first_tail_x8_r0_body.cx0_158.mlx PRE_first_tail_x8_r0_body.cx1_158.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo158 : PRE_first_tail_x8_r0_body.clo158.map (fun h => PRE_first_tail_x8_r0_body.cx1_158.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa158.handle h)) = PRE_first_tail_x8_r0_body.clo158.map (fun h => (PRE_first_tail_x8_r0_body.cx0_158.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa158.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok158 : PRE_first_tail_x8_r0_body.clo158.all (objOK PRE_first_tail_x8_r0_body.kappa158 PRE_first_tail_x8_r0_body.P158.NL PRE_first_tail_x8_r0_body.cx0_158.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd158 : PRE_first_tail_x8_r0_body.cln158.all (nodeOKF PRE_first_tail_x8_r0_body.kappa158 PRE_first_tail_x8_r0_body.P158 PRE_first_tail_x8_r0_body.cx0_158.mlx PRE_first_tail_x8_r0_body.cx1_158.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp158 : ((PRE_first_tail_x8_r0_body.cln158.filter (fullB PRE_first_tail_x8_r0_body.P158))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_158.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa158.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln158.filter (fullB PRE_first_tail_x8_r0_body.P158))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_158.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa158.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI158 : incrB PRE_first_tail_x8_r0_body.kd158.nodeF (List.range' 18403 0) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK158 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd158.node).all (fun k => Nat.ble 18403 k && Nat.blt k 18403) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL158 : (PRE_first_tail_x8_r0_body.cln158.filter (Nat.ble PRE_first_tail_x8_r0_body.P158.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd158.nodeF i) && (Nat.blt i 18403 || Nat.ble PRE_first_tail_x8_r0_body.kd158.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord158 : (PRE_first_tail_x8_r0_body.cln158.filter (Nat.ble PRE_first_tail_x8_r0_body.P158.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd158.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd158.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd158.nodeF j) (PRE_first_tail_x8_r0_body.kd158.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow158 PRE_first_tail_x8_r0_body.cnn1158 PRE_first_tail_x8_r0_body.fnordI158 PRE_first_tail_x8_r0_body.fnordK158 PRE_first_tail_x8_r0_body.fnordL158
kernel_rfl PRE_first_tail_x8_r0_body.fi158 : PRE_first_tail_x8_r0_body.cli158.all (pnB PRE_first_tail_x8_r0_body.cx0_158.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii158 : PRE_first_tail_x8_r0_body.cli158.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_158.mlx.items.get (PRE_first_tail_x8_r0_body.kappa158.node k) = (PRE_first_tail_x8_r0_body.cx0_158.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa158.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot158 (clean : Conv.NClean (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P158.NL) (cl : SSt (· < 6808) PRE_first_tail_x8_r0_body.cx0_158.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P158 6808 PRE_first_tail_x8_r0_body.kappa158 PRE_first_tail_x8_r0_body.kd158 PRE_first_tail_x8_r0_body.khinv158 PRE_first_tail_x8_r0_body.kninv158 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx PRE_first_tail_x8_r0_body.cx0_158.mlx PRE_first_tail_x8_r0_body.cx1_158.mlx (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo158 PRE_first_tail_x8_r0_body.cln158 PRE_first_tail_x8_r0_body.cli158 PRE_first_tail_x8_r0_body.cwS158 PRE_first_tail_x8_r0_body.cnS158 PRE_first_tail_x8_r0_body.ciS158 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0158, PRE_first_tail_x8_r0_body.cnh1158, PRE_first_tail_x8_r0_body.cnn0158, PRE_first_tail_x8_r0_body.cnn1158, PRE_first_tail_x8_r0_body.cplo158, PRE_first_tail_x8_r0_body.ccnt158, PRE_first_tail_x8_r0_body.cnband158, PRE_first_tail_x8_r0_body.chbelow158, PRE_first_tail_x8_r0_body.chren158, PRE_first_tail_x8_r0_body.cband158, PRE_first_tail_x8_r0_body.cnh1pos158, PRE_first_tail_x8_r0_body.cnren158, PRE_first_tail_x8_r0_body.cnlow158, PRE_first_tail_x8_r0_body.cabs0a158, PRE_first_tail_x8_r0_body.cabs0b158, PRE_first_tail_x8_r0_body.ctok1158, PRE_first_tail_x8_r0_body.cpend158, PRE_first_tail_x8_r0_body.cerrh158, PRE_first_tail_x8_r0_body.cfiles158, PRE_first_tail_x8_r0_body.carch158, PRE_first_tail_x8_r0_body.csizes158, PRE_first_tail_x8_r0_body.cwired158, PRE_first_tail_x8_r0_body.cfix158, clean, PRE_first_tail_x8_r0_body.fcxn158, PRE_first_tail_x8_r0_body.fcnn158, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0158, PRE_first_tail_x8_r0_body.fnk158, PRE_first_tail_x8_r0_body.ckA158, PRE_first_tail_x8_r0_body.cobjsK158, PRE_first_tail_x8_r0_body.cnodesK158, PRE_first_tail_x8_r0_body.citemsK158, PRE_first_tail_x8_r0_body.f1A158, PRE_first_tail_x8_r0_body.f1O158, PRE_first_tail_x8_r0_body.f1N158, PRE_first_tail_x8_r0_body.f1I158, PRE_first_tail_x8_r0_body.fbd158, PRE_first_tail_x8_r0_body.fincW158, PRE_first_tail_x8_r0_body.fincI158, PRE_first_tail_x8_r0_body.fincN158, PRE_first_tail_x8_r0_body.flnF158, PRE_first_tail_x8_r0_body.fh158, PRE_first_tail_x8_r0_body.fo158, PRE_first_tail_x8_r0_body.fok158, PRE_first_tail_x8_r0_body.fnd158, PRE_first_tail_x8_r0_body.fp158, PRE_first_tail_x8_r0_body.fnord158, PRE_first_tail_x8_r0_body.fi158, PRE_first_tail_x8_r0_body.fii158⟩
theorem PRE_first_tail_x8_r0_body.cnshift158 (clean : Conv.NClean (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P158.NL) (cl : SSt (· < 6808) PRE_first_tail_x8_r0_body.cx0_158.mlx) : NShift PRE_first_tail_x8_r0_body.P158 6808 PRE_first_tail_x8_r0_body.kappa158 PRE_first_tail_x8_r0_body.cx0_158 PRE_first_tail_x8_r0_body.cx1_158 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot158 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost158 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0158 PRE_first_tail_x8_r0_body.ckn1158 PRE_first_tail_x8_r0_body.ckheap158 PRE_first_tail_x8_r0_body.ckpl158)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_158 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1523.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_158 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1523.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_158 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1523.ffi) = some PRE_first_tail_x8_r0_body.fxC_158
kernel_rfl PRE_first_tail_x8_r0_body.okrC_158 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1523.ffi) = some PRE_first_tail_x8_r0_body.krC_158
noncomputable def PRE_first_tail_x8_r0_body.fx0_158 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1525.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_158 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1525.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_158 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1525.ffi) = some PRE_first_tail_x8_r0_body.fx0_158
kernel_rfl PRE_first_tail_x8_r0_body.okr0_158 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1525.ffi) = some PRE_first_tail_x8_r0_body.kr0_158
noncomputable def PRE_first_tail_x8_r0_body.fx1_158 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1524.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_158 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1524.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_158 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1524.ffi) = some PRE_first_tail_x8_r0_body.fx1_158
kernel_rfl PRE_first_tail_x8_r0_body.okr1_158 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1524.ffi) = some PRE_first_tail_x8_r0_body.kr1_158
kernel_rfl PRE_first_tail_x8_r0_body.ff0158 : PRE_first_tail_x8_r0_body.fx0_158 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_158 (PRE_first_tail_x8_r0_body.clo158.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_158.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1158 : PRE_first_tail_x8_r0_body.fx1_158 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_158 (PRE_first_tail_x8_r0_body.cwS158.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_158.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck158 : freedLB PRE_first_tail_x8_r0_body.kappa158 PRE_first_tail_x8_r0_body.cx0_158.mlx PRE_first_tail_x8_r0_body.fx0_158 PRE_first_tail_x8_r0_body.fx1_158 PRE_first_tail_x8_r0_body.clo158 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0158 : PRE_first_tail_x8_r0_body.kr0_158.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_158.flags (PRE_first_tail_x8_r0_body.clo158.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_158.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0158 : PRE_first_tail_x8_r0_body.kr0_158.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_158.targs (PRE_first_tail_x8_r0_body.clo158.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_158.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1158 : PRE_first_tail_x8_r0_body.kr1_158.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_158.flags (PRE_first_tail_x8_r0_body.cwS158.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_158.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1158 : PRE_first_tail_x8_r0_body.kr1_158.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_158.targs (PRE_first_tail_x8_r0_body.cwS158.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_158.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck158 : krecLB PRE_first_tail_x8_r0_body.kappa158 6808 PRE_first_tail_x8_r0_body.cx0_158.mlx PRE_first_tail_x8_r0_body.kr0_158 PRE_first_tail_x8_r0_body.kr1_158 PRE_first_tail_x8_r0_body.clo158 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn158 : Nat.ble 6808 6808 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge158 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1524.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1525.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR158 : pendRegB PRE_first_tail_x8_r0_body.kappa158 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1525.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe158 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1525.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1524.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift158 (clean : Conv.NClean (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P158.NL) (cl : SSt (· < 6808) PRE_first_tail_x8_r0_body.cx0_158.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_158.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_158.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_158.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1523.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_158.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P158 6808 PRE_first_tail_x8_r0_body.kappa158 PRE_first_tail_x8_r0_body.s1525.ffi PRE_first_tail_x8_r0_body.s1524.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift158 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue158, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp158 t ht),
    PRE_first_tail_x8_r0_body.cbridge158,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1525.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1524.ffi) (PRE_first_tail_x8_r0_body.cfoot158 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_158 PRE_first_tail_x8_r0_body.ofx1_158 hobjC PRE_first_tail_x8_r0_body.ff0158 PRE_first_tail_x8_r0_body.ff1158 PRE_first_tail_x8_r0_body.ffck158,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1525.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1524.ffi) (PRE_first_tail_x8_r0_body.cfoot158 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_158 PRE_first_tail_x8_r0_body.okr1_158 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn158) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0158 PRE_first_tail_x8_r0_body.fkt0158 PRE_first_tail_x8_r0_body.fkf1158 PRE_first_tail_x8_r0_body.fkt1158 PRE_first_tail_x8_r0_body.fkck158,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0158 PRE_first_tail_x8_r0_body.cnh1158 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe158) PRE_first_tail_x8_r0_body.cpendR158⟩

end Host.Load.Run.Tpl
end

section -- st158/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st158 0
host_stream_state PRE_first_tail_x8_r0_body.st158 1
host_stream_state PRE_first_tail_x8_r0_body.st158 2
end Host.Load.Run.Tpl
end

section -- Site158
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 158 of chain `PRE_first_tail_x8_r0_body`: `plan__g158__g159` (`plan`), the call state `PRE_first_tail_x8_r0_body.s1523`, the merged state `PRE_first_tail_x8_r0_body.s1524`,
the site template `PRE_first_tail_x8_r0_body.st158` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1525`: the merge.
The footprint's facts are in `SiteF158`, the compaction's in `SiteC158`, `SiteK158`, `SiteNa158`, `SiteNb158`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso158 : PRE_first_tail_x8_r0_body.st158.s0 = { PRE_first_tail_x8_r0_body.s1523 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs158 : List Frame := PRE_first_tail_x8_r0_body.s1523.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_158 : PRE_first_tail_x8_r0_body.S1523.tab.length = 6808
kernel_rfl PRE_first_tail_x8_r0_body.tab0_158 : PRE_first_tail_x8_r0_body.st158.S0.tab = PRE_first_tail_x8_r0_body.S1523.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws158 : List Nat := [3656, 3657, 3658]
kernel_rfl PRE_first_tail_x8_r0_body.fresh158 : (PRE_first_tail_x8_r0_body.S1523.tab.all fun e => PRE_first_tail_x8_r0_body.ws158.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1523.oracle.all fun q => PRE_first_tail_x8_r0_body.ws158.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab158 : PRE_first_tail_x8_r0_body.S1524.tab = PRE_first_tail_x8_r0_body.S1523.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws158
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen158 : PRE_first_tail_x8_r0_body.st158.S2.tab.length - PRE_first_tail_x8_r0_body.st158.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged158`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap158 : PRE_first_tail_x8_r0_body.s1524.heap = PRE_first_tail_x8_r0_body.st158.s2.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext158 : PRE_first_tail_x8_r0_body.s1524.next = PRE_first_tail_x8_r0_body.st158.s2.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl158 : PRE_first_tail_x8_r0_body.s1524.ctl = PRE_first_tail_x8_r0_body.st158.s2.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack158 : PRE_first_tail_x8_r0_body.s1524.stack = PRE_first_tail_x8_r0_body.st158.s2.stack ++ PRE_first_tail_x8_r0_body.s1523.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs158 : PRE_first_tail_x8_r0_body.s1524.jobs = PRE_first_tail_x8_r0_body.st158.s2.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi158 : PRE_first_tail_x8_r0_body.s1524.ffi = PRE_first_tail_x8_r0_body.st158.s2.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace158 : PRE_first_tail_x8_r0_body.s1524.trace = PRE_first_tail_x8_r0_body.st158.s2.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores158 : PRE_first_tail_x8_r0_body.s1524.stores = PRE_first_tail_x8_r0_body.st158.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD158
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 158 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived158 : PRE_first_tail_x8_r0_body.nr158.map (fun r => nth? PRE_first_tail_x8_r0_body.st158.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo158 : PRE_first_tail_x8_r0_body.nr158.all (Nat.ble 6808) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj158 : PRE_first_tail_x8_r0_body.cws158.all (fun c => !PRE_first_tail_x8_r0_body.ws158.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ158 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws158 PRE_first_tail_x8_r0_body.crs158 PRE_first_tail_x8_r0_body.ws158

end Host.Load.Run.Tpl
end

section -- st158/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st158`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st158.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st158.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st158.s2.heap PRE_first_tail_x8_r0_body.st158.wrR ++ freshOf PRE_first_tail_x8_r0_body.st158.s2.heap PRE_first_tail_x8_r0_body.st158.s0.next PRE_first_tail_x8_r0_body.st158.s2.next
noncomputable def PRE_first_tail_x8_r0_body.st158.wr : List Nat := PRE_first_tail_x8_r0_body.st158.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st158.heapFoot : PRE_first_tail_x8_r0_body.st158.s2.heap = setAll PRE_first_tail_x8_r0_body.st158.s0.heap PRE_first_tail_x8_r0_body.st158.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st158.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st158.s0.next PRE_first_tail_x8_r0_body.st158.s2.next = true
theorem PRE_first_tail_x8_r0_body.st158.grows : PRE_first_tail_x8_r0_body.st158.s0.next ≤ PRE_first_tail_x8_r0_body.st158.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st158.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st158.wh : List Nat := []
def PRE_first_tail_x8_r0_body.st158.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st158.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st158.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st158.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st158.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st158.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st158.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st158.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st158.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st158.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st158.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st158.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st158.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st158.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st158.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st158.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st158.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st158.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st158.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st158.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st158.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st158.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st158.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st158.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st158.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st158.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st158.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st158.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st158.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st158.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF158
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 158 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB158 : nodupT PRE_first_tail_x8_r0_body.st158.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup158 : PRE_first_tail_x8_r0_body.st158.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB158).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB158 : PRE_first_tail_x8_r0_body.st158.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound158 : ∀ b ∈ PRE_first_tail_x8_r0_body.st158.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB158 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr158 := PRE_first_tail_x8_r0_body.st158.s2.trace.take 0
kernel_rfl PRE_first_tail_x8_r0_body.traceEq158 : PRE_first_tail_x8_r0_body.st158.s2.trace = PRE_first_tail_x8_r0_body.trFr158 ++ PRE_first_tail_x8_r0_body.st158.s0.trace
theorem PRE_first_tail_x8_r0_body.trace158 : ∃ fr, PRE_first_tail_x8_r0_body.st158.s2.trace = fr ++ PRE_first_tail_x8_r0_body.st158.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq158⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide158 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB158 : (PRE_first_tail_x8_r0_body.wide158.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st158.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix158 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide158, WFix Map.id (Present PRE_first_tail_x8_r0_body.st158.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB158 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL158
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 158 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1524`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO158 : PRE_first_tail_x8_r0_body.st158.S0.oracle = PRE_first_tail_x8_r0_body.st158.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B158 : PRE_first_tail_x8_r0_body.st158.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st158.s0.next || (PRE_first_tail_x8_r0_body.st158.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot158 : Conv.StageFoot PRE_first_tail_x8_r0_body.st158.wr PRE_first_tail_x8_r0_body.st158.s0 PRE_first_tail_x8_r0_body.st158.s2 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st158.heapFoot PRE_first_tail_x8_r0_body.wrNodup158 PRE_first_tail_x8_r0_body.wrBound158 PRE_first_tail_x8_r0_body.wr0B158 PRE_first_tail_x8_r0_body.st158.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged158 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st158.F.S → PRE_first_tail_x8_r0_body.st158.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st158.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st158.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs158 PRE_first_tail_x8_r0_body.st158.wr PRE_first_tail_x8_r0_body.s1523 PRE_first_tail_x8_r0_body.st158.s2 PRE_first_tail_x8_r0_body.st158.s0
      PRE_first_tail_x8_r0_body.st158.s2.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st158.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1524 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso158 PRE_first_tail_x8_r0_body.stFoot158 PRE_first_tail_x8_r0_body.wrNodup158 PRE_first_tail_x8_r0_body.wrBound158 PRE_first_tail_x8_r0_body.trace158 PRE_first_tail_x8_r0_body.mheap158
    PRE_first_tail_x8_r0_body.mnext158 PRE_first_tail_x8_r0_body.mctl158 PRE_first_tail_x8_r0_body.mstack158 PRE_first_tail_x8_r0_body.mjobs158 PRE_first_tail_x8_r0_body.mffi158 PRE_first_tail_x8_r0_body.mtrace158 PRE_first_tail_x8_r0_body.mstores158 h

def PRE_first_tail_x8_r0_body.arrEl158_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE158_2665 : arrOf PRE_first_tail_x8_r0_body.s1524 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl158_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA158_2665 : isArrB PRE_first_tail_x8_r0_body.s1524 2665 = true
theorem PRE_first_tail_x8_r0_body.arr158_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1524.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl158_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE158_2665 PRE_first_tail_x8_r0_body.arrA158_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN158_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl158_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR158_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl158_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN158_2665

def PRE_first_tail_x8_r0_body.arrEl158_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE158_2673467 : arrOf PRE_first_tail_x8_r0_body.s1524 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl158_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA158_2673467 : isArrB PRE_first_tail_x8_r0_body.s1524 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr158_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1524.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl158_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE158_2673467 PRE_first_tail_x8_r0_body.arrA158_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN158_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl158_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR158_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl158_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN158_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k158 : isArrB PRE_first_tail_x8_r0_body.s1524 4910 = false
theorem PRE_first_tail_x8_r0_body.keep158 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1524 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k158 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr158_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl158_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ158
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 158 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1523`, the merged
state `PRE_first_tail_x8_r0_body.s1524`, the canonical state `PRE_first_tail_x8_r0_body.s1525`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl158 : PRE_first_tail_x8_r0_body.pl158.all (Nat.ble PRE_first_tail_x8_r0_body.s1523.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd158 : nodupT PRE_first_tail_x8_r0_body.pl158 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1158 : Nat.ble PRE_first_tail_x8_r0_body.s1523.next 2798674 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst158 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1523.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn158 : PRE_first_tail_x8_r0_body.s1525.next = PRE_first_tail_x8_r0_body.s1523.next + PRE_first_tail_x8_r0_body.pl158.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn158 : PRE_first_tail_x8_r0_body.s1524.next = 2798674
kernel_rfl PRE_first_tail_x8_r0_body.zgrow158 : Nat.ble PRE_first_tail_x8_r0_body.s1525.next PRE_first_tail_x8_r0_body.s1524.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh158 : PRE_first_tail_x8_r0_body.S1523.tab.all (fun e => PRE_first_tail_x8_r0_body.cws158.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd158 : nodupT PRE_first_tail_x8_r0_body.cws158 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi158 : PRE_first_tail_x8_r0_body.nr158.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1524.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt158 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1523.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg158_2665 : PRE_first_tail_x8_r0_body.s1525.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1525 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk158_2665 : (objOf PRE_first_tail_x8_r0_body.s1525 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm158_2665 : PRE_first_tail_x8_r0_body.s1524.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa158.obj (objOf PRE_first_tail_x8_r0_body.s1525 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1524 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg158_2673467 : PRE_first_tail_x8_r0_body.s1525.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1525 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk158_2673467 : (objOf PRE_first_tail_x8_r0_body.s1525 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm158_2673467 : PRE_first_tail_x8_r0_body.s1524.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa158.obj (objOf PRE_first_tail_x8_r0_body.s1525 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1524 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw158_4910 : (PRE_first_tail_x8_r0_body.s1525.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw158_2673472 : (PRE_first_tail_x8_r0_body.s1525.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw158_2673473 : (PRE_first_tail_x8_r0_body.s1525.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd158 : PRE_first_tail_x8_r0_body.cl158.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr158 : PRE_first_tail_x8_r0_body.st158.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1523.next || PRE_first_tail_x8_r0_body.cl158.contains b) = true
def PRE_first_tail_x8_r0_body.zl158 : List Nat := PRE_first_tail_x8_r0_body.cl158.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE158 : PRE_first_tail_x8_r0_body.zl158.map (fun a => PRE_first_tail_x8_r0_body.s1524.heap.get (PRE_first_tail_x8_r0_body.kappa158.a a)) = PRE_first_tail_x8_r0_body.zl158.map (fun a => (PRE_first_tail_x8_r0_body.s1525.heap.get a).map PRE_first_tail_x8_r0_body.kappa158.hobj)
theorem PRE_first_tail_x8_r0_body.zimg158 : HeapImg PRE_first_tail_x8_r0_body.kappa158 PRE_first_tail_x8_r0_body.s1525 PRE_first_tail_x8_r0_body.s1524 PRE_first_tail_x8_r0_body.zl158 := PRE_first_tail_x8_r0_body.zimgE158
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl158 : PRE_first_tail_x8_r0_body.s1524.ctl = PRE_first_tail_x8_r0_body.kappa158.ctl PRE_first_tail_x8_r0_body.s1525.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack158 : PRE_first_tail_x8_r0_body.s1524.stack = PRE_first_tail_x8_r0_body.s1525.stack.map PRE_first_tail_x8_r0_body.kappa158.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs158 : PRE_first_tail_x8_r0_body.s1524.jobs = PRE_first_tail_x8_r0_body.s1525.jobs.map PRE_first_tail_x8_r0_body.kappa158.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores158 : PRE_first_tail_x8_r0_body.s1524.stores = PRE_first_tail_x8_r0_body.kappa158.stores PRE_first_tail_x8_r0_body.s1525.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots158 : checkRootsSupp PRE_first_tail_x8_r0_body.s1525 6808 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC158 : PRE_first_tail_x8_r0_body.S1523.tab.length + PRE_first_tail_x8_r0_body.cws158.length = 6808
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap158 : PRE_first_tail_x8_r0_body.kappa158 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1523.next 2798674 PRE_first_tail_x8_r0_body.S1523.tab.length PRE_first_tail_x8_r0_body.pl158 (PRE_first_tail_x8_r0_body.nr158.map NumV.ref) PRE_first_tail_x8_r0_body.kd158.big
  PRE_first_tail_x8_r0_body.kd158.region PRE_first_tail_x8_r0_body.kd158.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin158 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1525.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc158 : Conv.jcleanListB (⟨21307, 18403, 2798664, 6808⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1525 PRE_first_tail_x8_r0_body.cl158 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB158 : noBigRootsP (fun i => !Conv.oldBigB (⟨21307, 18403, 2798664, 6808⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1525.trace PRE_first_tail_x8_r0_body.s1525 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm158 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 18403 = true
theorem PRE_first_tail_x8_r0_body.cjcl158 (h : Conv.JClean (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1523) : Conv.JClean (⟨21307, 18403, 2798664, 6808⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1525 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle158)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap158 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd158 a ha)) PRE_first_tail_x8_r0_body.zjc158

end Host.Load.Run.Tpl
end

section -- st158/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st158.bodyLast from PRE_first_tail_x8_r0_body.st158.s1 to PRE_first_tail_x8_r0_body.st158.s2 :
  interpS (step PRE_first_tail_x8_r0_body.st158.F PRE_first_tail_x8_r0_body.st158.s1).run PRE_first_tail_x8_r0_body.st158.S1 = some (PRE_first_tail_x8_r0_body.st158.s2, PRE_first_tail_x8_r0_body.st158.S2)
kernel_rfl PRE_first_tail_x8_r0_body.st158.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st158.s1.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st158.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st158.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st158/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st158.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st158.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st158.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st158.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st158.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st158.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st158.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st158.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st158.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st158.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st158.s0 PRE_first_tail_x8_r0_body.st158.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st158.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st158.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st158.s1 PRE_first_tail_x8_r0_body.st158.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st158/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st158.bodyK0F from PRE_first_tail_x8_r0_body.st158.s0 to PRE_first_tail_x8_r0_body.st158.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st158.F (PRE_first_tail_x8_r0_body.st158.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st158.ks 0).getD 0) PRE_first_tail_x8_r0_body.st158.s0 PRE_first_tail_x8_r0_body.st158.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st158.s1, PRE_first_tail_x8_r0_body.st158.S1)
theorem PRE_first_tail_x8_r0_body.st158.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st158.F (PRE_first_tail_x8_r0_body.st158.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st158.ks 0).getD 0) PRE_first_tail_x8_r0_body.st158.s0 PRE_first_tail_x8_r0_body.st158.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st158.s1, PRE_first_tail_x8_r0_body.st158.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st158.bodyOkLN_ok PRE_first_tail_x8_r0_body.st158.bodyK0F
end Host.Load.Run.Tpl
end

section -- st158/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st158.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st158.F (PRE_first_tail_x8_r0_body.st158.bodyOkL bytes rows) 98 PRE_first_tail_x8_r0_body.st158.s0 PRE_first_tail_x8_r0_body.st158.S0 = some (PRE_first_tail_x8_r0_body.st158.s1, PRE_first_tail_x8_r0_body.st158.S1) :=
  (congrFun (congrFun PRE_first_tail_x8_r0_body.st158.bodyK0 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st158.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st158.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st158.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st158.F (PRE_first_tail_x8_r0_body.st158.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st158.s0
  S0 := PRE_first_tail_x8_r0_body.st158.S0
  s1 := PRE_first_tail_x8_r0_body.st158.s1
  S1 := PRE_first_tail_x8_r0_body.st158.S1
  s2 := PRE_first_tail_x8_r0_body.st158.s2
  S2 := PRE_first_tail_x8_r0_body.st158.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st158.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st158.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st158.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st158.bodyHalt
  last := PRE_first_tail_x8_r0_body.st158.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st158.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC159
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 159 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1542` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa159` into the merged state
`PRE_first_tail_x8_r0_body.s1541`. -/

def PRE_first_tail_x8_r0_body.pl159 : List Nat := [2801247, 2800422, 2801253, 2801249, 2800424, 2801255]
def PRE_first_tail_x8_r0_body.nr159 : List Nat := [6911, 6910, 6886, 6894, 6899, 6904, 6909, 6883, 6884, 6885, 6892, 6893, 6881, 6888, 6889, 6890, 6891, 6887]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd159 : RData :=
  ⟨2800141, 2801290, Stage.setAll PTrie.nil [(2800135, 2801247), (2800136, 2800422), (2800137, 2801253), (2800138, 2801249), (2800139, 2800424), (2800140, 2801255)], Stage.setAll PTrie.nil [(21341, 21367), (21342, 21345), (21343, 21368)],
   21344, 21369, 18449, 18449, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(6881, .ref 6911), (6882, .ref 6910), (6883, .ref 6886), (6884, .ref 6894), (6885, .ref 6899), (6886, .ref 6904), (6887, .ref 6909), (6888, .ref 6883), (6889, .ref 6884), (6890, .ref 6885), (6891, .ref 6892), (6892, .ref 6893), (6893, .ref 6881), (6894, .ref 6888), (6895, .ref 6889), (6896, .ref 6890), (6897, .ref 6891), (6898, .ref 6887)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa159 : Map :=
  Conv.Map.compact 2800135 2801290 6881 PRE_first_tail_x8_r0_body.pl159 (PRE_first_tail_x8_r0_body.nr159.map NumV.ref) PRE_first_tail_x8_r0_body.kd159.big
    PRE_first_tail_x8_r0_body.kd159.region PRE_first_tail_x8_r0_body.kd159.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws159 : List Nat := [3690, 3691, 3692, 3693, 3694, 3695, 3696, 3697, 3698, 3699, 3700, 3701, 3702, 3703, 3704, 3705, 3706, 3707]
noncomputable def PRE_first_tail_x8_r0_body.crs159 : List SymE := PRE_first_tail_x8_r0_body.nr159.map fun r => (nth? PRE_first_tail_x8_r0_body.S1541.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta159 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws159 PRE_first_tail_x8_r0_body.crs159
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB159 : List Nat := [2665, 2672708, 2673467, 2799309, 2799854, 2800110]

kernel_rfl PRE_first_tail_x8_r0_body.ctab159 : PRE_first_tail_x8_r0_body.S1542.tab = PRE_first_tail_x8_r0_body.S1540.tab ++ PRE_first_tail_x8_r0_body.cws159.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace159 : PRE_first_tail_x8_r0_body.s1542.trace = PRE_first_tail_x8_r0_body.s1540.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext159 : PRE_first_tail_x8_r0_body.s1542.next = 2800141
kernel_rfl PRE_first_tail_x8_r0_body.ccounters159 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1542.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1542.ffi).mlx.nnext) = (21344, 18449)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue159 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1541.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1542.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa159.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp159 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1542.ffi).mlx.tokens.all (bSN 6899) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean159 : Conv.cleanListB 21344 131072 (fun r => Nat.ble 85376 r) PRE_first_tail_x8_r0_body.s1542
    (PRE_first_tail_x8_r0_body.wrB159 ++ (List.range 6).map (2800135 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs159 : bigsOutB 21344 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1542.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK159
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl159`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl159 : List Nat := [2665, 2672708, 2673467, 2799309, 2799854, 2800110, 2800135, 2800136, 2800137, 2800138, 2800139, 2800140]
def PRE_first_tail_x8_r0_body.clo159 : List Nat := [21321, 21334, 21340, 21341, 21342, 21343]
def PRE_first_tail_x8_r0_body.cln159 : List Nat := [18422, 18423, 18424, 18425, 18426, 18427, 18428, 18429, 18430, 18431, 18432, 18433, 18434, 18435, 18436, 18437, 18438, 18439, 18440, 18441, 18442, 18443, 18444, 18445, 18446, 18447, 18448]
def PRE_first_tail_x8_r0_body.cli159 : List Nat := [18422, 18423, 18424, 18425, 18426, 18427, 18428, 18429, 18430, 18431, 18432, 18433, 18434, 18435, 18436, 18437, 18438, 18439, 18440, 18441, 18442, 18443, 18444, 18445, 18446, 18447, 18448]
kernel_rfl PRE_first_tail_x8_r0_body.cheap159 : PRE_first_tail_x8_r0_body.s1542.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1540.heap (PRE_first_tail_x8_r0_body.cl159.filterMap fun a => (PRE_first_tail_x8_r0_body.s1542.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe159 : Nat.ble PRE_first_tail_x8_r0_body.s1540.next PRE_first_tail_x8_r0_body.s1542.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP159 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1540 PRE_first_tail_x8_r0_body.s1542 PRE_first_tail_x8_r0_body.cl159 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp159 : Conv.suppListB PRE_first_tail_x8_r0_body.s1542 6899 PRE_first_tail_x8_r0_body.cl159 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound159 : Conv.boundListB PRE_first_tail_x8_r0_body.s1542 PRE_first_tail_x8_r0_body.cl159 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK159 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1542.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln159.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1542.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK159 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1542.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo159.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1542.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK159 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1542.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli159.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1542.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst159 : Conv.sstListB 6899 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1542.ffi).mlx PRE_first_tail_x8_r0_body.cln159 PRE_first_tail_x8_r0_body.clo159 PRE_first_tail_x8_r0_body.cli159 = true

end Host.Load.Run.Tpl
end

section -- SiteCl159
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA159 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1542.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo159.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1542.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd159 : (PRE_first_tail_x8_r0_body.clo159 ++ PRE_first_tail_x8_r0_body.cln159 ++ PRE_first_tail_x8_r0_body.cli159).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle159 : Conv.Cnt.leB (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt) (⟨21344, 18449, 2800141, 6899⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck159 : Conv.ncleanListB (⟨21344, 18449, 2800141, 6899⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1542.ffi).mlx PRE_first_tail_x8_r0_body.clo159 PRE_first_tail_x8_r0_body.cln159 PRE_first_tail_x8_r0_body.cli159 = true
theorem PRE_first_tail_x8_r0_body.cncl159 (h : Conv.NClean (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx) : Conv.NClean (⟨21344, 18449, 2800141, 6899⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1542.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle159 PRE_first_tail_x8_r0_body.ckA159 PRE_first_tail_x8_r0_body.cobjsK159 PRE_first_tail_x8_r0_body.cnodesK159 PRE_first_tail_x8_r0_body.citemsK159 PRE_first_tail_x8_r0_body.cbd159 PRE_first_tail_x8_r0_body.cck159

end Host.Load.Run.Tpl
end

section -- SiteS159
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 159 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc159 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P159 : LoadP := PRE_first_tail_x8_r0_body.Pc159.raise 18449
kernel_rfl PRE_first_tail_x8_r0_body.craise159 : Nat.ble PRE_first_tail_x8_r0_body.Pc159.N0 18449 = true
theorem PRE_first_tail_x8_r0_body.raised159 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc159 PRE_first_tail_x8_r0_body.P159 :=
  .inr ⟨18449, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise159, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_159 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1542.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_159 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1541.ffi)
def PRE_first_tail_x8_r0_body.khinv159 : PTrie Nat := Stage.setAll PTrie.nil [(21367, 21341), (21345, 21342), (21368, 21343)]
def PRE_first_tail_x8_r0_body.kninv159 : PTrie Nat := Stage.setAll PTrie.nil [(18422, 18422), (18423, 18423), (18424, 18424), (18425, 18425), (18426, 18426), (18427, 18427), (18428, 18428), (18429, 18429), (18430, 18430), (18431, 18431), (18432, 18432), (18433, 18433), (18434, 18434), (18435, 18435), (18436, 18436), (18437, 18437), (18438, 18438), (18439, 18439), (18440, 18440), (18441, 18441), (18442, 18442), (18443, 18443), (18444, 18444), (18445, 18445), (18446, 18446), (18447, 18447), (18448, 18448)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS159 : List Nat := [21321, 21334, 21340, 21341, 21342, 21343, 21344, 21345, 21346, 21347, 21348, 21349, 21350, 21351, 21352, 21353, 21354, 21355, 21356, 21357, 21358, 21359, 21360, 21361, 21362, 21363, 21364, 21365, 21366, 21367, 21368]
def PRE_first_tail_x8_r0_body.cnS159 : List Nat := List.range' 18422 27
def PRE_first_tail_x8_r0_body.ciS159 : List Nat := [] ++ List.range' 18422 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0159 : PRE_first_tail_x8_r0_body.kd159.nh0 = PRE_first_tail_x8_r0_body.cx0_159.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1159 : PRE_first_tail_x8_r0_body.kd159.nh1 = PRE_first_tail_x8_r0_body.cx1_159.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0159 : PRE_first_tail_x8_r0_body.kd159.nn0 = PRE_first_tail_x8_r0_body.cx0_159.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1159 : PRE_first_tail_x8_r0_body.kd159.nn1 = PRE_first_tail_x8_r0_body.cx1_159.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo159 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P159.lo && Nat.ble PRE_first_tail_x8_r0_body.P159.lo PRE_first_tail_x8_r0_body.cx0_159.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P159.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P159.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt159 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_159.mlx.next PRE_first_tail_x8_r0_body.cx1_159.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_159.mlx.nnext PRE_first_tail_x8_r0_body.cx1_159.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband159 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P159.NL && Nat.ble PRE_first_tail_x8_r0_body.P159.NL PRE_first_tail_x8_r0_body.P159.N0 && Nat.ble PRE_first_tail_x8_r0_body.P159.N0 PRE_first_tail_x8_r0_body.cx0_159.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow159 : PRE_first_tail_x8_r0_body.kd159.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren159 : checkRenG PRE_first_tail_x8_r0_body.kd159.hnd PRE_first_tail_x8_r0_body.khinv159 (phB PRE_first_tail_x8_r0_body.cx0_159.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband159 : PRE_first_tail_x8_r0_body.kd159.checkBand PRE_first_tail_x8_r0_body.P159.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos159 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd159.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren159 : checkRenG PRE_first_tail_x8_r0_body.kd159.node PRE_first_tail_x8_r0_body.kninv159 (pnB PRE_first_tail_x8_r0_body.cx0_159.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow159 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd159.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P159.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd159.nodeF j) PRE_first_tail_x8_r0_body.cx1_159.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a159 : PRE_first_tail_x8_r0_body.cx0_159.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b159 : PRE_first_tail_x8_r0_body.cx0_159.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1159 : PRE_first_tail_x8_r0_body.cx1_159.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend159 : PRE_first_tail_x8_r0_body.cx1_159.mlx.pending = PRE_first_tail_x8_r0_body.cx0_159.mlx.pending.map PRE_first_tail_x8_r0_body.kappa159.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh159 : PRE_first_tail_x8_r0_body.cx1_159.mlx.errh = PRE_first_tail_x8_r0_body.cx0_159.mlx.errh.map PRE_first_tail_x8_r0_body.kappa159.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles159 : PRE_first_tail_x8_r0_body.cx1_159.mlx.files = PRE_first_tail_x8_r0_body.cx0_159.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch159 : PRE_first_tail_x8_r0_body.cx1_159.mlx.arch = PRE_first_tail_x8_r0_body.cx0_159.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes159 : PRE_first_tail_x8_r0_body.cx1_159.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_159.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired159 : PRE_first_tail_x8_r0_body.cx1_159.mlx.wired = PRE_first_tail_x8_r0_body.cx0_159.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost159 : PRE_first_tail_x8_r0_body.cx1_159.host = PRE_first_tail_x8_r0_body.cx0_159.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd159`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0159 : PRE_first_tail_x8_r0_body.kd159.n0 = 2800141
kernel_rfl PRE_first_tail_x8_r0_body.ckn1159 : PRE_first_tail_x8_r0_body.kd159.n1 = 2801290
kernel_rfl PRE_first_tail_x8_r0_body.ckheap159 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd159.heap).all (fun x => Nat.ble 2800135 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl159 : (List.range 6).all (fun j => decide (PRE_first_tail_x8_r0_body.kd159.heap.get (2800135 + j) = nth? PRE_first_tail_x8_r0_body.pl159 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja159 : Nat.ble 2800135 2800135 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn159 : Nat.ble 6881 6881 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD159 : Nat.ble 2800135 PRE_first_tail_x8_r0_body.kd159.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn159 : Nat.ble 21341 PRE_first_tail_x8_r0_body.kd159.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn159 : Nat.ble 18422 PRE_first_tail_x8_r0_body.kd159.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb159 : Nat.ble 21341 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap159 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd159.heap).all (Nat.ble (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd159 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd159.hnd).all (Nat.ble (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode159 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd159.node).all (Nat.ble (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix159 : Conv.FixOld (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa159 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja159) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn159) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD159) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn159) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn159) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb159) PRE_first_tail_x8_r0_body.fheap159 PRE_first_tail_x8_r0_body.fhnd159 PRE_first_tail_x8_r0_body.fnode159
kernel_rfl PRE_first_tail_x8_r0_body.fcxn159 : (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn159 : (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0159 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_159.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_159.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk159 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd159.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A159 : PRE_first_tail_x8_r0_body.cx1_159.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS159.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_159.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O159 : PRE_first_tail_x8_r0_body.cx1_159.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS159.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_159.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N159 : PRE_first_tail_x8_r0_body.cx1_159.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS159.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_159.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I159 : PRE_first_tail_x8_r0_body.cx1_159.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS159.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_159.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd159 : (PRE_first_tail_x8_r0_body.clo159 ++ PRE_first_tail_x8_r0_body.cln159 ++ PRE_first_tail_x8_r0_body.cli159 ++ PRE_first_tail_x8_r0_body.cwS159 ++ PRE_first_tail_x8_r0_body.cnS159 ++ PRE_first_tail_x8_r0_body.ciS159).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW159 : PRE_first_tail_x8_r0_body.cwS159.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo159.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI159 : PRE_first_tail_x8_r0_body.ciS159.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli159.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN159 : PRE_first_tail_x8_r0_body.cnS159.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF159 : PRE_first_tail_x8_r0_body.cln159.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh159 : PRE_first_tail_x8_r0_body.clo159.all (handleOK PRE_first_tail_x8_r0_body.kappa159 PRE_first_tail_x8_r0_body.P159.lo PRE_first_tail_x8_r0_body.cx0_159.mlx PRE_first_tail_x8_r0_body.cx1_159.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo159 : PRE_first_tail_x8_r0_body.clo159.map (fun h => PRE_first_tail_x8_r0_body.cx1_159.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa159.handle h)) = PRE_first_tail_x8_r0_body.clo159.map (fun h => (PRE_first_tail_x8_r0_body.cx0_159.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa159.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok159 : PRE_first_tail_x8_r0_body.clo159.all (objOK PRE_first_tail_x8_r0_body.kappa159 PRE_first_tail_x8_r0_body.P159.NL PRE_first_tail_x8_r0_body.cx0_159.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd159 : PRE_first_tail_x8_r0_body.cln159.all (nodeOKF PRE_first_tail_x8_r0_body.kappa159 PRE_first_tail_x8_r0_body.P159 PRE_first_tail_x8_r0_body.cx0_159.mlx PRE_first_tail_x8_r0_body.cx1_159.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp159 : ((PRE_first_tail_x8_r0_body.cln159.filter (fullB PRE_first_tail_x8_r0_body.P159))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_159.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa159.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln159.filter (fullB PRE_first_tail_x8_r0_body.P159))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_159.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa159.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI159 : incrB PRE_first_tail_x8_r0_body.kd159.nodeF (List.range' 18422 27) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK159 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd159.node).all (fun k => Nat.ble 18422 k && Nat.blt k 18449) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL159 : (PRE_first_tail_x8_r0_body.cln159.filter (Nat.ble PRE_first_tail_x8_r0_body.P159.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd159.nodeF i) && (Nat.blt i 18449 || Nat.ble PRE_first_tail_x8_r0_body.kd159.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord159 : (PRE_first_tail_x8_r0_body.cln159.filter (Nat.ble PRE_first_tail_x8_r0_body.P159.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd159.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd159.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd159.nodeF j) (PRE_first_tail_x8_r0_body.kd159.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow159 PRE_first_tail_x8_r0_body.cnn1159 PRE_first_tail_x8_r0_body.fnordI159 PRE_first_tail_x8_r0_body.fnordK159 PRE_first_tail_x8_r0_body.fnordL159
kernel_rfl PRE_first_tail_x8_r0_body.fi159 : PRE_first_tail_x8_r0_body.cli159.all (pnB PRE_first_tail_x8_r0_body.cx0_159.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii159 : PRE_first_tail_x8_r0_body.cli159.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_159.mlx.items.get (PRE_first_tail_x8_r0_body.kappa159.node k) = (PRE_first_tail_x8_r0_body.cx0_159.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa159.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot159 (clean : Conv.NClean (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P159.NL) (cl : SSt (· < 6899) PRE_first_tail_x8_r0_body.cx0_159.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P159 6899 PRE_first_tail_x8_r0_body.kappa159 PRE_first_tail_x8_r0_body.kd159 PRE_first_tail_x8_r0_body.khinv159 PRE_first_tail_x8_r0_body.kninv159 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx PRE_first_tail_x8_r0_body.cx0_159.mlx PRE_first_tail_x8_r0_body.cx1_159.mlx (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo159 PRE_first_tail_x8_r0_body.cln159 PRE_first_tail_x8_r0_body.cli159 PRE_first_tail_x8_r0_body.cwS159 PRE_first_tail_x8_r0_body.cnS159 PRE_first_tail_x8_r0_body.ciS159 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0159, PRE_first_tail_x8_r0_body.cnh1159, PRE_first_tail_x8_r0_body.cnn0159, PRE_first_tail_x8_r0_body.cnn1159, PRE_first_tail_x8_r0_body.cplo159, PRE_first_tail_x8_r0_body.ccnt159, PRE_first_tail_x8_r0_body.cnband159, PRE_first_tail_x8_r0_body.chbelow159, PRE_first_tail_x8_r0_body.chren159, PRE_first_tail_x8_r0_body.cband159, PRE_first_tail_x8_r0_body.cnh1pos159, PRE_first_tail_x8_r0_body.cnren159, PRE_first_tail_x8_r0_body.cnlow159, PRE_first_tail_x8_r0_body.cabs0a159, PRE_first_tail_x8_r0_body.cabs0b159, PRE_first_tail_x8_r0_body.ctok1159, PRE_first_tail_x8_r0_body.cpend159, PRE_first_tail_x8_r0_body.cerrh159, PRE_first_tail_x8_r0_body.cfiles159, PRE_first_tail_x8_r0_body.carch159, PRE_first_tail_x8_r0_body.csizes159, PRE_first_tail_x8_r0_body.cwired159, PRE_first_tail_x8_r0_body.cfix159, clean, PRE_first_tail_x8_r0_body.fcxn159, PRE_first_tail_x8_r0_body.fcnn159, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0159, PRE_first_tail_x8_r0_body.fnk159, PRE_first_tail_x8_r0_body.ckA159, PRE_first_tail_x8_r0_body.cobjsK159, PRE_first_tail_x8_r0_body.cnodesK159, PRE_first_tail_x8_r0_body.citemsK159, PRE_first_tail_x8_r0_body.f1A159, PRE_first_tail_x8_r0_body.f1O159, PRE_first_tail_x8_r0_body.f1N159, PRE_first_tail_x8_r0_body.f1I159, PRE_first_tail_x8_r0_body.fbd159, PRE_first_tail_x8_r0_body.fincW159, PRE_first_tail_x8_r0_body.fincI159, PRE_first_tail_x8_r0_body.fincN159, PRE_first_tail_x8_r0_body.flnF159, PRE_first_tail_x8_r0_body.fh159, PRE_first_tail_x8_r0_body.fo159, PRE_first_tail_x8_r0_body.fok159, PRE_first_tail_x8_r0_body.fnd159, PRE_first_tail_x8_r0_body.fp159, PRE_first_tail_x8_r0_body.fnord159, PRE_first_tail_x8_r0_body.fi159, PRE_first_tail_x8_r0_body.fii159⟩
theorem PRE_first_tail_x8_r0_body.cnshift159 (clean : Conv.NClean (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P159.NL) (cl : SSt (· < 6899) PRE_first_tail_x8_r0_body.cx0_159.mlx) : NShift PRE_first_tail_x8_r0_body.P159 6899 PRE_first_tail_x8_r0_body.kappa159 PRE_first_tail_x8_r0_body.cx0_159 PRE_first_tail_x8_r0_body.cx1_159 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot159 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost159 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0159 PRE_first_tail_x8_r0_body.ckn1159 PRE_first_tail_x8_r0_body.ckheap159 PRE_first_tail_x8_r0_body.ckpl159)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_159 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1540.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_159 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1540.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_159 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1540.ffi) = some PRE_first_tail_x8_r0_body.fxC_159
kernel_rfl PRE_first_tail_x8_r0_body.okrC_159 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1540.ffi) = some PRE_first_tail_x8_r0_body.krC_159
noncomputable def PRE_first_tail_x8_r0_body.fx0_159 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1542.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_159 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1542.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_159 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1542.ffi) = some PRE_first_tail_x8_r0_body.fx0_159
kernel_rfl PRE_first_tail_x8_r0_body.okr0_159 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1542.ffi) = some PRE_first_tail_x8_r0_body.kr0_159
noncomputable def PRE_first_tail_x8_r0_body.fx1_159 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1541.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_159 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1541.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_159 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1541.ffi) = some PRE_first_tail_x8_r0_body.fx1_159
kernel_rfl PRE_first_tail_x8_r0_body.okr1_159 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1541.ffi) = some PRE_first_tail_x8_r0_body.kr1_159
kernel_rfl PRE_first_tail_x8_r0_body.ff0159 : PRE_first_tail_x8_r0_body.fx0_159 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_159 (PRE_first_tail_x8_r0_body.clo159.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_159.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1159 : PRE_first_tail_x8_r0_body.fx1_159 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_159 (PRE_first_tail_x8_r0_body.cwS159.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_159.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck159 : freedLB PRE_first_tail_x8_r0_body.kappa159 PRE_first_tail_x8_r0_body.cx0_159.mlx PRE_first_tail_x8_r0_body.fx0_159 PRE_first_tail_x8_r0_body.fx1_159 PRE_first_tail_x8_r0_body.clo159 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0159 : PRE_first_tail_x8_r0_body.kr0_159.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_159.flags (PRE_first_tail_x8_r0_body.clo159.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_159.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0159 : PRE_first_tail_x8_r0_body.kr0_159.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_159.targs (PRE_first_tail_x8_r0_body.clo159.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_159.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1159 : PRE_first_tail_x8_r0_body.kr1_159.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_159.flags (PRE_first_tail_x8_r0_body.cwS159.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_159.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1159 : PRE_first_tail_x8_r0_body.kr1_159.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_159.targs (PRE_first_tail_x8_r0_body.cwS159.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_159.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck159 : krecLB PRE_first_tail_x8_r0_body.kappa159 6899 PRE_first_tail_x8_r0_body.cx0_159.mlx PRE_first_tail_x8_r0_body.kr0_159 PRE_first_tail_x8_r0_body.kr1_159 PRE_first_tail_x8_r0_body.clo159 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn159 : Nat.ble 6881 6899 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge159 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1541.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1542.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR159 : pendRegB PRE_first_tail_x8_r0_body.kappa159 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1542.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe159 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1542.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1541.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift159 (clean : Conv.NClean (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P159.NL) (cl : SSt (· < 6899) PRE_first_tail_x8_r0_body.cx0_159.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_159.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_159.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_159.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1540.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_159.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P159 6899 PRE_first_tail_x8_r0_body.kappa159 PRE_first_tail_x8_r0_body.s1542.ffi PRE_first_tail_x8_r0_body.s1541.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift159 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue159, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp159 t ht),
    PRE_first_tail_x8_r0_body.cbridge159,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1542.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1541.ffi) (PRE_first_tail_x8_r0_body.cfoot159 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_159 PRE_first_tail_x8_r0_body.ofx1_159 hobjC PRE_first_tail_x8_r0_body.ff0159 PRE_first_tail_x8_r0_body.ff1159 PRE_first_tail_x8_r0_body.ffck159,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1542.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1541.ffi) (PRE_first_tail_x8_r0_body.cfoot159 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_159 PRE_first_tail_x8_r0_body.okr1_159 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn159) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0159 PRE_first_tail_x8_r0_body.fkt0159 PRE_first_tail_x8_r0_body.fkf1159 PRE_first_tail_x8_r0_body.fkt1159 PRE_first_tail_x8_r0_body.fkck159,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0159 PRE_first_tail_x8_r0_body.cnh1159 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe159) PRE_first_tail_x8_r0_body.cpendR159⟩

end Host.Load.Run.Tpl
end

section -- st159/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st159 0
host_stream_state PRE_first_tail_x8_r0_body.st159 1
host_stream_state PRE_first_tail_x8_r0_body.st159 2
host_stream_state PRE_first_tail_x8_r0_body.st159 3
host_stream_state PRE_first_tail_x8_r0_body.st159 4
host_stream_state PRE_first_tail_x8_r0_body.st159 5
end Host.Load.Run.Tpl
end

section -- Site159
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 159 of chain `PRE_first_tail_x8_r0_body`: `ssmW__g159__g160` (`recurWindow`), the call state `PRE_first_tail_x8_r0_body.s1540`, the merged state `PRE_first_tail_x8_r0_body.s1541`,
the site template `PRE_first_tail_x8_r0_body.st159` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1542`: the merge.
The footprint's facts are in `SiteF159`, the compaction's in `SiteC159`, `SiteK159`, `SiteNa159`, `SiteNb159`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso159 : PRE_first_tail_x8_r0_body.st159.s0 = { PRE_first_tail_x8_r0_body.s1540 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs159 : List Frame := PRE_first_tail_x8_r0_body.s1540.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_159 : PRE_first_tail_x8_r0_body.S1540.tab.length = 6881
kernel_rfl PRE_first_tail_x8_r0_body.tab0_159 : PRE_first_tail_x8_r0_body.st159.S0.tab = PRE_first_tail_x8_r0_body.S1540.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws159 : List Nat := [3659, 3660, 3661, 3662, 3663, 3664, 3665, 3666, 3667, 3668, 3669, 3670, 3671, 3672, 3673, 3674, 3675, 3676, 3677, 3678, 3679, 3680, 3681, 3682, 3683, 3684, 3685, 3686, 3687, 3688, 3689]
kernel_rfl PRE_first_tail_x8_r0_body.fresh159 : (PRE_first_tail_x8_r0_body.S1540.tab.all fun e => PRE_first_tail_x8_r0_body.ws159.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1540.oracle.all fun q => PRE_first_tail_x8_r0_body.ws159.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab159 : PRE_first_tail_x8_r0_body.S1541.tab = PRE_first_tail_x8_r0_body.S1540.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws159
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen159 : PRE_first_tail_x8_r0_body.st159.S5.tab.length - PRE_first_tail_x8_r0_body.st159.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged159`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap159 : PRE_first_tail_x8_r0_body.s1541.heap = PRE_first_tail_x8_r0_body.st159.s5.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext159 : PRE_first_tail_x8_r0_body.s1541.next = PRE_first_tail_x8_r0_body.st159.s5.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl159 : PRE_first_tail_x8_r0_body.s1541.ctl = PRE_first_tail_x8_r0_body.st159.s5.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack159 : PRE_first_tail_x8_r0_body.s1541.stack = PRE_first_tail_x8_r0_body.st159.s5.stack ++ PRE_first_tail_x8_r0_body.s1540.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs159 : PRE_first_tail_x8_r0_body.s1541.jobs = PRE_first_tail_x8_r0_body.st159.s5.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi159 : PRE_first_tail_x8_r0_body.s1541.ffi = PRE_first_tail_x8_r0_body.st159.s5.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace159 : PRE_first_tail_x8_r0_body.s1541.trace = PRE_first_tail_x8_r0_body.st159.s5.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores159 : PRE_first_tail_x8_r0_body.s1541.stores = PRE_first_tail_x8_r0_body.st159.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD159
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 159 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived159 : PRE_first_tail_x8_r0_body.nr159.map (fun r => nth? PRE_first_tail_x8_r0_body.st159.S5.tab r) =
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
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo159 : PRE_first_tail_x8_r0_body.nr159.all (Nat.ble 6881) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj159 : PRE_first_tail_x8_r0_body.cws159.all (fun c => !PRE_first_tail_x8_r0_body.ws159.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ159 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws159 PRE_first_tail_x8_r0_body.crs159 PRE_first_tail_x8_r0_body.ws159

end Host.Load.Run.Tpl
end

section -- st159/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st159`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st159.wrR : List (Nat × Nat) := [(2672708, 2672709), (2799309, 2799310), (2799854, 2799855), (2800110, 2800111)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st159.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st159.s5.heap PRE_first_tail_x8_r0_body.st159.wrR ++ freshOf PRE_first_tail_x8_r0_body.st159.s5.heap PRE_first_tail_x8_r0_body.st159.s0.next PRE_first_tail_x8_r0_body.st159.s5.next
noncomputable def PRE_first_tail_x8_r0_body.st159.wr : List Nat := PRE_first_tail_x8_r0_body.st159.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st159.heapFoot : PRE_first_tail_x8_r0_body.st159.s5.heap = setAll PRE_first_tail_x8_r0_body.st159.s0.heap PRE_first_tail_x8_r0_body.st159.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st159.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st159.s0.next PRE_first_tail_x8_r0_body.st159.s5.next = true
theorem PRE_first_tail_x8_r0_body.st159.grows : PRE_first_tail_x8_r0_body.st159.s0.next ≤ PRE_first_tail_x8_r0_body.st159.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st159.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st159.wh : List Nat := [21321, 21334, 21340, 21341, 21342, 21343, 21344, 21345, 21346, 21347, 21348, 21349, 21350, 21351, 21352, 21353, 21354, 21355, 21356, 21357, 21358, 21359, 21360, 21361, 21362, 21363, 21364, 21365, 21366, 21367, 21368]
def PRE_first_tail_x8_r0_body.st159.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st159.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st159.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st159.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st159.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st159.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st159.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st159.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st159.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st159.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st159.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st159.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st159.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st159.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st159.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st159.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st159.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st159.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st159.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st159.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st159.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st159.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st159.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st159.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st159.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st159.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st159.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st159.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st159.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st159.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF159
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 159 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB159 : nodupT PRE_first_tail_x8_r0_body.st159.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup159 : PRE_first_tail_x8_r0_body.st159.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB159).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB159 : PRE_first_tail_x8_r0_body.st159.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound159 : ∀ b ∈ PRE_first_tail_x8_r0_body.st159.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB159 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr159 := PRE_first_tail_x8_r0_body.st159.s5.trace.take 120
kernel_rfl PRE_first_tail_x8_r0_body.traceEq159 : PRE_first_tail_x8_r0_body.st159.s5.trace = PRE_first_tail_x8_r0_body.trFr159 ++ PRE_first_tail_x8_r0_body.st159.s0.trace
theorem PRE_first_tail_x8_r0_body.trace159 : ∃ fr, PRE_first_tail_x8_r0_body.st159.s5.trace = fr ++ PRE_first_tail_x8_r0_body.st159.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq159⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide159 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB159 : (PRE_first_tail_x8_r0_body.wide159.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st159.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix159 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide159, WFix Map.id (Present PRE_first_tail_x8_r0_body.st159.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB159 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL159
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 159 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1541`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO159 : PRE_first_tail_x8_r0_body.st159.S0.oracle = PRE_first_tail_x8_r0_body.st159.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B159 : PRE_first_tail_x8_r0_body.st159.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st159.s0.next || (PRE_first_tail_x8_r0_body.st159.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot159 : Conv.StageFoot PRE_first_tail_x8_r0_body.st159.wr PRE_first_tail_x8_r0_body.st159.s0 PRE_first_tail_x8_r0_body.st159.s5 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st159.heapFoot PRE_first_tail_x8_r0_body.wrNodup159 PRE_first_tail_x8_r0_body.wrBound159 PRE_first_tail_x8_r0_body.wr0B159 PRE_first_tail_x8_r0_body.st159.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged159 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st159.F.S → PRE_first_tail_x8_r0_body.st159.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st159.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st159.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs159 PRE_first_tail_x8_r0_body.st159.wr PRE_first_tail_x8_r0_body.s1540 PRE_first_tail_x8_r0_body.st159.s5 PRE_first_tail_x8_r0_body.st159.s0
      PRE_first_tail_x8_r0_body.st159.s5.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st159.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1541 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso159 PRE_first_tail_x8_r0_body.stFoot159 PRE_first_tail_x8_r0_body.wrNodup159 PRE_first_tail_x8_r0_body.wrBound159 PRE_first_tail_x8_r0_body.trace159 PRE_first_tail_x8_r0_body.mheap159
    PRE_first_tail_x8_r0_body.mnext159 PRE_first_tail_x8_r0_body.mctl159 PRE_first_tail_x8_r0_body.mstack159 PRE_first_tail_x8_r0_body.mjobs159 PRE_first_tail_x8_r0_body.mffi159 PRE_first_tail_x8_r0_body.mtrace159 PRE_first_tail_x8_r0_body.mstores159 h

def PRE_first_tail_x8_r0_body.arrEl159_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE159_2665 : arrOf PRE_first_tail_x8_r0_body.s1541 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl159_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA159_2665 : isArrB PRE_first_tail_x8_r0_body.s1541 2665 = true
theorem PRE_first_tail_x8_r0_body.arr159_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1541.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl159_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE159_2665 PRE_first_tail_x8_r0_body.arrA159_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN159_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl159_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR159_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl159_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN159_2665

def PRE_first_tail_x8_r0_body.arrEl159_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE159_2673467 : arrOf PRE_first_tail_x8_r0_body.s1541 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl159_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA159_2673467 : isArrB PRE_first_tail_x8_r0_body.s1541 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr159_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1541.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl159_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE159_2673467 PRE_first_tail_x8_r0_body.arrA159_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN159_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl159_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR159_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl159_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN159_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k159 : isArrB PRE_first_tail_x8_r0_body.s1541 4910 = false
theorem PRE_first_tail_x8_r0_body.keep159 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1541 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k159 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr159_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl159_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ159
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 159 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1540`, the merged
state `PRE_first_tail_x8_r0_body.s1541`, the canonical state `PRE_first_tail_x8_r0_body.s1542`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl159 : PRE_first_tail_x8_r0_body.pl159.all (Nat.ble PRE_first_tail_x8_r0_body.s1540.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd159 : nodupT PRE_first_tail_x8_r0_body.pl159 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1159 : Nat.ble PRE_first_tail_x8_r0_body.s1540.next 2801290 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst159 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1540.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn159 : PRE_first_tail_x8_r0_body.s1542.next = PRE_first_tail_x8_r0_body.s1540.next + PRE_first_tail_x8_r0_body.pl159.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn159 : PRE_first_tail_x8_r0_body.s1541.next = 2801290
kernel_rfl PRE_first_tail_x8_r0_body.zgrow159 : Nat.ble PRE_first_tail_x8_r0_body.s1542.next PRE_first_tail_x8_r0_body.s1541.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh159 : PRE_first_tail_x8_r0_body.S1540.tab.all (fun e => PRE_first_tail_x8_r0_body.cws159.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd159 : nodupT PRE_first_tail_x8_r0_body.cws159 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi159 : PRE_first_tail_x8_r0_body.nr159.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1541.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt159 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1540.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg159_2665 : PRE_first_tail_x8_r0_body.s1542.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1542 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk159_2665 : (objOf PRE_first_tail_x8_r0_body.s1542 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm159_2665 : PRE_first_tail_x8_r0_body.s1541.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa159.obj (objOf PRE_first_tail_x8_r0_body.s1542 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1541 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg159_2673467 : PRE_first_tail_x8_r0_body.s1542.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1542 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk159_2673467 : (objOf PRE_first_tail_x8_r0_body.s1542 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm159_2673467 : PRE_first_tail_x8_r0_body.s1541.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa159.obj (objOf PRE_first_tail_x8_r0_body.s1542 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1541 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw159_4910 : (PRE_first_tail_x8_r0_body.s1542.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw159_2673472 : (PRE_first_tail_x8_r0_body.s1542.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw159_2673473 : (PRE_first_tail_x8_r0_body.s1542.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd159 : PRE_first_tail_x8_r0_body.cl159.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr159 : PRE_first_tail_x8_r0_body.st159.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1540.next || PRE_first_tail_x8_r0_body.cl159.contains b) = true
def PRE_first_tail_x8_r0_body.zl159 : List Nat := PRE_first_tail_x8_r0_body.cl159.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE159 : PRE_first_tail_x8_r0_body.zl159.map (fun a => PRE_first_tail_x8_r0_body.s1541.heap.get (PRE_first_tail_x8_r0_body.kappa159.a a)) = PRE_first_tail_x8_r0_body.zl159.map (fun a => (PRE_first_tail_x8_r0_body.s1542.heap.get a).map PRE_first_tail_x8_r0_body.kappa159.hobj)
theorem PRE_first_tail_x8_r0_body.zimg159 : HeapImg PRE_first_tail_x8_r0_body.kappa159 PRE_first_tail_x8_r0_body.s1542 PRE_first_tail_x8_r0_body.s1541 PRE_first_tail_x8_r0_body.zl159 := PRE_first_tail_x8_r0_body.zimgE159
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl159 : PRE_first_tail_x8_r0_body.s1541.ctl = PRE_first_tail_x8_r0_body.kappa159.ctl PRE_first_tail_x8_r0_body.s1542.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack159 : PRE_first_tail_x8_r0_body.s1541.stack = PRE_first_tail_x8_r0_body.s1542.stack.map PRE_first_tail_x8_r0_body.kappa159.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs159 : PRE_first_tail_x8_r0_body.s1541.jobs = PRE_first_tail_x8_r0_body.s1542.jobs.map PRE_first_tail_x8_r0_body.kappa159.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores159 : PRE_first_tail_x8_r0_body.s1541.stores = PRE_first_tail_x8_r0_body.kappa159.stores PRE_first_tail_x8_r0_body.s1542.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots159 : checkRootsSupp PRE_first_tail_x8_r0_body.s1542 6899 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC159 : PRE_first_tail_x8_r0_body.S1540.tab.length + PRE_first_tail_x8_r0_body.cws159.length = 6899
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap159 : PRE_first_tail_x8_r0_body.kappa159 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1540.next 2801290 PRE_first_tail_x8_r0_body.S1540.tab.length PRE_first_tail_x8_r0_body.pl159 (PRE_first_tail_x8_r0_body.nr159.map NumV.ref) PRE_first_tail_x8_r0_body.kd159.big
  PRE_first_tail_x8_r0_body.kd159.region PRE_first_tail_x8_r0_body.kd159.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin159 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1542.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc159 : Conv.jcleanListB (⟨21344, 18449, 2800141, 6899⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1542 PRE_first_tail_x8_r0_body.cl159 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB159 : noBigRootsP (fun i => !Conv.oldBigB (⟨21344, 18449, 2800141, 6899⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1542.trace PRE_first_tail_x8_r0_body.s1542 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm159 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 18422 = true
theorem PRE_first_tail_x8_r0_body.cjcl159 (h : Conv.JClean (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1540) : Conv.JClean (⟨21344, 18449, 2800141, 6899⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1542 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle159)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap159 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd159 a ha)) PRE_first_tail_x8_r0_body.zjc159

end Host.Load.Run.Tpl
end

section -- st159/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st159.bodyLast from PRE_first_tail_x8_r0_body.st159.s4 to PRE_first_tail_x8_r0_body.st159.s5 :
  interpS (step PRE_first_tail_x8_r0_body.st159.F PRE_first_tail_x8_r0_body.st159.s4).run PRE_first_tail_x8_r0_body.st159.S4 = some (PRE_first_tail_x8_r0_body.st159.s5, PRE_first_tail_x8_r0_body.st159.S5)
kernel_rfl PRE_first_tail_x8_r0_body.st159.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st159.s4.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st159.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st159.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st159/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st159.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st159.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st159.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st159.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st159.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st159.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st159.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st159.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st159.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st159.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st159.s0 PRE_first_tail_x8_r0_body.st159.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st159.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st159.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st159.s4 PRE_first_tail_x8_r0_body.st159.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st159/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st159.bodyK0F from PRE_first_tail_x8_r0_body.st159.s0 to PRE_first_tail_x8_r0_body.st159.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st159.F (PRE_first_tail_x8_r0_body.st159.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st159.ks 0).getD 0) PRE_first_tail_x8_r0_body.st159.s0 PRE_first_tail_x8_r0_body.st159.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st159.s1, PRE_first_tail_x8_r0_body.st159.S1)
theorem PRE_first_tail_x8_r0_body.st159.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st159.F (PRE_first_tail_x8_r0_body.st159.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st159.ks 0).getD 0) PRE_first_tail_x8_r0_body.st159.s0 PRE_first_tail_x8_r0_body.st159.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st159.s1, PRE_first_tail_x8_r0_body.st159.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st159.bodyOkLN_ok PRE_first_tail_x8_r0_body.st159.bodyK0F
end Host.Load.Run.Tpl
end

section -- st159/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st159.bodyK1F from PRE_first_tail_x8_r0_body.st159.s1 to PRE_first_tail_x8_r0_body.st159.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st159.F (PRE_first_tail_x8_r0_body.st159.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st159.ks 1).getD 0) PRE_first_tail_x8_r0_body.st159.s1 PRE_first_tail_x8_r0_body.st159.S1) = fun _ _ => some (PRE_first_tail_x8_r0_body.st159.s2, PRE_first_tail_x8_r0_body.st159.S2)
theorem PRE_first_tail_x8_r0_body.st159.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st159.F (PRE_first_tail_x8_r0_body.st159.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st159.ks 1).getD 0) PRE_first_tail_x8_r0_body.st159.s1 PRE_first_tail_x8_r0_body.st159.S1) = fun _ _ => some (PRE_first_tail_x8_r0_body.st159.s2, PRE_first_tail_x8_r0_body.st159.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st159.bodyOkLN_ok PRE_first_tail_x8_r0_body.st159.bodyK1F
end Host.Load.Run.Tpl
end

section -- st159/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st159.bodyK2F from PRE_first_tail_x8_r0_body.st159.s2 to PRE_first_tail_x8_r0_body.st159.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st159.F (PRE_first_tail_x8_r0_body.st159.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st159.ks 2).getD 0) PRE_first_tail_x8_r0_body.st159.s2 PRE_first_tail_x8_r0_body.st159.S2) = fun _ _ => some (PRE_first_tail_x8_r0_body.st159.s3, PRE_first_tail_x8_r0_body.st159.S3)
theorem PRE_first_tail_x8_r0_body.st159.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st159.F (PRE_first_tail_x8_r0_body.st159.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st159.ks 2).getD 0) PRE_first_tail_x8_r0_body.st159.s2 PRE_first_tail_x8_r0_body.st159.S2) = fun _ _ => some (PRE_first_tail_x8_r0_body.st159.s3, PRE_first_tail_x8_r0_body.st159.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st159.bodyOkLN_ok PRE_first_tail_x8_r0_body.st159.bodyK2F
end Host.Load.Run.Tpl
end

section -- st159/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st159.bodyK3F from PRE_first_tail_x8_r0_body.st159.s3 to PRE_first_tail_x8_r0_body.st159.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st159.F (PRE_first_tail_x8_r0_body.st159.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st159.ks 3).getD 0) PRE_first_tail_x8_r0_body.st159.s3 PRE_first_tail_x8_r0_body.st159.S3) = fun _ _ => some (PRE_first_tail_x8_r0_body.st159.s4, PRE_first_tail_x8_r0_body.st159.S4)
theorem PRE_first_tail_x8_r0_body.st159.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st159.F (PRE_first_tail_x8_r0_body.st159.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st159.ks 3).getD 0) PRE_first_tail_x8_r0_body.st159.s3 PRE_first_tail_x8_r0_body.st159.S3) = fun _ _ => some (PRE_first_tail_x8_r0_body.st159.s4, PRE_first_tail_x8_r0_body.st159.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st159.bodyOkLN_ok PRE_first_tail_x8_r0_body.st159.bodyK3F
end Host.Load.Run.Tpl
end

section -- st159/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st159.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st159.F (PRE_first_tail_x8_r0_body.st159.bodyOkL bytes rows) 11334 PRE_first_tail_x8_r0_body.st159.s0 PRE_first_tail_x8_r0_body.st159.S0 = some (PRE_first_tail_x8_r0_body.st159.s4, PRE_first_tail_x8_r0_body.st159.S4) :=
  runOk_trans PRE_first_tail_x8_r0_body.st159.F (PRE_first_tail_x8_r0_body.st159.bodyOkL bytes rows) ((((nth? PRE_first_tail_x8_r0_body.st159.ks 0).getD 0) + ((nth? PRE_first_tail_x8_r0_body.st159.ks 1).getD 0)) + ((nth? PRE_first_tail_x8_r0_body.st159.ks 2).getD 0)) ((nth? PRE_first_tail_x8_r0_body.st159.ks 3).getD 0) PRE_first_tail_x8_r0_body.st159.s0 PRE_first_tail_x8_r0_body.st159.s3 PRE_first_tail_x8_r0_body.st159.s4 PRE_first_tail_x8_r0_body.st159.S0 PRE_first_tail_x8_r0_body.st159.S3 PRE_first_tail_x8_r0_body.st159.S4 (runOk_trans PRE_first_tail_x8_r0_body.st159.F (PRE_first_tail_x8_r0_body.st159.bodyOkL bytes rows) (((nth? PRE_first_tail_x8_r0_body.st159.ks 0).getD 0) + ((nth? PRE_first_tail_x8_r0_body.st159.ks 1).getD 0)) ((nth? PRE_first_tail_x8_r0_body.st159.ks 2).getD 0) PRE_first_tail_x8_r0_body.st159.s0 PRE_first_tail_x8_r0_body.st159.s2 PRE_first_tail_x8_r0_body.st159.s3 PRE_first_tail_x8_r0_body.st159.S0 PRE_first_tail_x8_r0_body.st159.S2 PRE_first_tail_x8_r0_body.st159.S3 (runOk_trans PRE_first_tail_x8_r0_body.st159.F (PRE_first_tail_x8_r0_body.st159.bodyOkL bytes rows) ((nth? PRE_first_tail_x8_r0_body.st159.ks 0).getD 0) ((nth? PRE_first_tail_x8_r0_body.st159.ks 1).getD 0) PRE_first_tail_x8_r0_body.st159.s0 PRE_first_tail_x8_r0_body.st159.s1 PRE_first_tail_x8_r0_body.st159.s2 PRE_first_tail_x8_r0_body.st159.S0 PRE_first_tail_x8_r0_body.st159.S1 PRE_first_tail_x8_r0_body.st159.S2 ((congrFun (congrFun PRE_first_tail_x8_r0_body.st159.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x8_r0_body.st159.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x8_r0_body.st159.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x8_r0_body.st159.bodyK3 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st159.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st159.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st159.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st159.F (PRE_first_tail_x8_r0_body.st159.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st159.s0
  S0 := PRE_first_tail_x8_r0_body.st159.S0
  s1 := PRE_first_tail_x8_r0_body.st159.s4
  S1 := PRE_first_tail_x8_r0_body.st159.S4
  s2 := PRE_first_tail_x8_r0_body.st159.s5
  S2 := PRE_first_tail_x8_r0_body.st159.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st159.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st159.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st159.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st159.bodyHalt
  last := PRE_first_tail_x8_r0_body.st159.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st159.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC160
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 160 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1550` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa160` into the merged state
`PRE_first_tail_x8_r0_body.s1549`. -/

def PRE_first_tail_x8_r0_body.pl160 : List Nat := []
def PRE_first_tail_x8_r0_body.nr160 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd160 : RData :=
  ⟨2800631, 2800633, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21357, 21357, 18462, 18462, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa160 : Map :=
  Conv.Map.compact 2800631 2800633 6920 PRE_first_tail_x8_r0_body.pl160 (PRE_first_tail_x8_r0_body.nr160.map NumV.ref) PRE_first_tail_x8_r0_body.kd160.big
    PRE_first_tail_x8_r0_body.kd160.region PRE_first_tail_x8_r0_body.kd160.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws160 : List Nat := []
noncomputable def PRE_first_tail_x8_r0_body.crs160 : List SymE := PRE_first_tail_x8_r0_body.nr160.map fun r => (nth? PRE_first_tail_x8_r0_body.S1549.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta160 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws160 PRE_first_tail_x8_r0_body.crs160
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB160 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x8_r0_body.ctab160 : PRE_first_tail_x8_r0_body.S1550.tab = PRE_first_tail_x8_r0_body.S1548.tab ++ PRE_first_tail_x8_r0_body.cws160.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace160 : PRE_first_tail_x8_r0_body.s1550.trace = PRE_first_tail_x8_r0_body.s1548.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext160 : PRE_first_tail_x8_r0_body.s1550.next = 2800631
kernel_rfl PRE_first_tail_x8_r0_body.ccounters160 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1550.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1550.ffi).mlx.nnext) = (21357, 18462)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue160 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1549.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1550.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa160.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp160 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1550.ffi).mlx.tokens.all (bSN 6920) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean160 : Conv.cleanListB 21357 131072 (fun r => Nat.ble 85428 r) PRE_first_tail_x8_r0_body.s1550
    (PRE_first_tail_x8_r0_body.wrB160 ++ (List.range 0).map (2800631 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs160 : bigsOutB 21357 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1550.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK160
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl160`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl160 : List Nat := [2665, 2673467]
def PRE_first_tail_x8_r0_body.clo160 : List Nat := []
def PRE_first_tail_x8_r0_body.cln160 : List Nat := []
def PRE_first_tail_x8_r0_body.cli160 : List Nat := []
kernel_rfl PRE_first_tail_x8_r0_body.cheap160 : PRE_first_tail_x8_r0_body.s1550.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1548.heap (PRE_first_tail_x8_r0_body.cl160.filterMap fun a => (PRE_first_tail_x8_r0_body.s1550.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe160 : Nat.ble PRE_first_tail_x8_r0_body.s1548.next PRE_first_tail_x8_r0_body.s1550.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP160 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1548 PRE_first_tail_x8_r0_body.s1550 PRE_first_tail_x8_r0_body.cl160 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp160 : Conv.suppListB PRE_first_tail_x8_r0_body.s1550 6920 PRE_first_tail_x8_r0_body.cl160 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound160 : Conv.boundListB PRE_first_tail_x8_r0_body.s1550 PRE_first_tail_x8_r0_body.cl160 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK160 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1550.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln160.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1550.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK160 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1550.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo160.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1550.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK160 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1550.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli160.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1550.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst160 : Conv.sstListB 6920 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1550.ffi).mlx PRE_first_tail_x8_r0_body.cln160 PRE_first_tail_x8_r0_body.clo160 PRE_first_tail_x8_r0_body.cli160 = true

end Host.Load.Run.Tpl
end

section -- SiteCl160
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA160 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1550.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo160.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1550.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd160 : (PRE_first_tail_x8_r0_body.clo160 ++ PRE_first_tail_x8_r0_body.cln160 ++ PRE_first_tail_x8_r0_body.cli160).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle160 : Conv.Cnt.leB (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck160 : Conv.ncleanListB (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1550.ffi).mlx PRE_first_tail_x8_r0_body.clo160 PRE_first_tail_x8_r0_body.cln160 PRE_first_tail_x8_r0_body.cli160 = true
theorem PRE_first_tail_x8_r0_body.cncl160 (h : Conv.NClean (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx) : Conv.NClean (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1550.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle160 PRE_first_tail_x8_r0_body.ckA160 PRE_first_tail_x8_r0_body.cobjsK160 PRE_first_tail_x8_r0_body.cnodesK160 PRE_first_tail_x8_r0_body.citemsK160 PRE_first_tail_x8_r0_body.cbd160 PRE_first_tail_x8_r0_body.cck160

end Host.Load.Run.Tpl
end

section -- SiteS160
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 160 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc160 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P160 : LoadP := PRE_first_tail_x8_r0_body.Pc160.raise 18462
kernel_rfl PRE_first_tail_x8_r0_body.craise160 : Nat.ble PRE_first_tail_x8_r0_body.Pc160.N0 18462 = true
theorem PRE_first_tail_x8_r0_body.raised160 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc160 PRE_first_tail_x8_r0_body.P160 :=
  .inr ⟨18462, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise160, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_160 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1550.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_160 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1549.ffi)
def PRE_first_tail_x8_r0_body.khinv160 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x8_r0_body.kninv160 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS160 : List Nat := []
def PRE_first_tail_x8_r0_body.cnS160 : List Nat := List.range' 18462 0
def PRE_first_tail_x8_r0_body.ciS160 : List Nat := [] ++ List.range' 18462 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0160 : PRE_first_tail_x8_r0_body.kd160.nh0 = PRE_first_tail_x8_r0_body.cx0_160.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1160 : PRE_first_tail_x8_r0_body.kd160.nh1 = PRE_first_tail_x8_r0_body.cx1_160.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0160 : PRE_first_tail_x8_r0_body.kd160.nn0 = PRE_first_tail_x8_r0_body.cx0_160.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1160 : PRE_first_tail_x8_r0_body.kd160.nn1 = PRE_first_tail_x8_r0_body.cx1_160.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo160 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P160.lo && Nat.ble PRE_first_tail_x8_r0_body.P160.lo PRE_first_tail_x8_r0_body.cx0_160.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P160.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P160.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt160 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_160.mlx.next PRE_first_tail_x8_r0_body.cx1_160.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_160.mlx.nnext PRE_first_tail_x8_r0_body.cx1_160.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband160 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P160.NL && Nat.ble PRE_first_tail_x8_r0_body.P160.NL PRE_first_tail_x8_r0_body.P160.N0 && Nat.ble PRE_first_tail_x8_r0_body.P160.N0 PRE_first_tail_x8_r0_body.cx0_160.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow160 : PRE_first_tail_x8_r0_body.kd160.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren160 : checkRenG PRE_first_tail_x8_r0_body.kd160.hnd PRE_first_tail_x8_r0_body.khinv160 (phB PRE_first_tail_x8_r0_body.cx0_160.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband160 : PRE_first_tail_x8_r0_body.kd160.checkBand PRE_first_tail_x8_r0_body.P160.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos160 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd160.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren160 : checkRenG PRE_first_tail_x8_r0_body.kd160.node PRE_first_tail_x8_r0_body.kninv160 (pnB PRE_first_tail_x8_r0_body.cx0_160.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow160 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd160.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P160.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd160.nodeF j) PRE_first_tail_x8_r0_body.cx1_160.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a160 : PRE_first_tail_x8_r0_body.cx0_160.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b160 : PRE_first_tail_x8_r0_body.cx0_160.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1160 : PRE_first_tail_x8_r0_body.cx1_160.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend160 : PRE_first_tail_x8_r0_body.cx1_160.mlx.pending = PRE_first_tail_x8_r0_body.cx0_160.mlx.pending.map PRE_first_tail_x8_r0_body.kappa160.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh160 : PRE_first_tail_x8_r0_body.cx1_160.mlx.errh = PRE_first_tail_x8_r0_body.cx0_160.mlx.errh.map PRE_first_tail_x8_r0_body.kappa160.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles160 : PRE_first_tail_x8_r0_body.cx1_160.mlx.files = PRE_first_tail_x8_r0_body.cx0_160.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch160 : PRE_first_tail_x8_r0_body.cx1_160.mlx.arch = PRE_first_tail_x8_r0_body.cx0_160.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes160 : PRE_first_tail_x8_r0_body.cx1_160.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_160.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired160 : PRE_first_tail_x8_r0_body.cx1_160.mlx.wired = PRE_first_tail_x8_r0_body.cx0_160.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost160 : PRE_first_tail_x8_r0_body.cx1_160.host = PRE_first_tail_x8_r0_body.cx0_160.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd160`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0160 : PRE_first_tail_x8_r0_body.kd160.n0 = 2800631
kernel_rfl PRE_first_tail_x8_r0_body.ckn1160 : PRE_first_tail_x8_r0_body.kd160.n1 = 2800633
kernel_rfl PRE_first_tail_x8_r0_body.ckheap160 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd160.heap).all (fun x => Nat.ble 2800631 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl160 : (List.range 0).all (fun j => decide (PRE_first_tail_x8_r0_body.kd160.heap.get (2800631 + j) = nth? PRE_first_tail_x8_r0_body.pl160 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja160 : Nat.ble 2800631 2800631 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn160 : Nat.ble 6920 6920 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD160 : Nat.ble 2800631 PRE_first_tail_x8_r0_body.kd160.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn160 : Nat.ble 21357 PRE_first_tail_x8_r0_body.kd160.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn160 : Nat.ble 18462 PRE_first_tail_x8_r0_body.kd160.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb160 : Nat.ble 21357 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap160 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd160.heap).all (Nat.ble (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd160 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd160.hnd).all (Nat.ble (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode160 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd160.node).all (Nat.ble (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix160 : Conv.FixOld (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa160 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja160) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn160) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD160) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn160) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn160) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb160) PRE_first_tail_x8_r0_body.fheap160 PRE_first_tail_x8_r0_body.fhnd160 PRE_first_tail_x8_r0_body.fnode160
kernel_rfl PRE_first_tail_x8_r0_body.fcxn160 : (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn160 : (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0160 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_160.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_160.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk160 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd160.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A160 : PRE_first_tail_x8_r0_body.cx1_160.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS160.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_160.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O160 : PRE_first_tail_x8_r0_body.cx1_160.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS160.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_160.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N160 : PRE_first_tail_x8_r0_body.cx1_160.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS160.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_160.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I160 : PRE_first_tail_x8_r0_body.cx1_160.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS160.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_160.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd160 : (PRE_first_tail_x8_r0_body.clo160 ++ PRE_first_tail_x8_r0_body.cln160 ++ PRE_first_tail_x8_r0_body.cli160 ++ PRE_first_tail_x8_r0_body.cwS160 ++ PRE_first_tail_x8_r0_body.cnS160 ++ PRE_first_tail_x8_r0_body.ciS160).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW160 : PRE_first_tail_x8_r0_body.cwS160.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo160.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI160 : PRE_first_tail_x8_r0_body.ciS160.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli160.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN160 : PRE_first_tail_x8_r0_body.cnS160.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF160 : PRE_first_tail_x8_r0_body.cln160.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh160 : PRE_first_tail_x8_r0_body.clo160.all (handleOK PRE_first_tail_x8_r0_body.kappa160 PRE_first_tail_x8_r0_body.P160.lo PRE_first_tail_x8_r0_body.cx0_160.mlx PRE_first_tail_x8_r0_body.cx1_160.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo160 : PRE_first_tail_x8_r0_body.clo160.map (fun h => PRE_first_tail_x8_r0_body.cx1_160.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa160.handle h)) = PRE_first_tail_x8_r0_body.clo160.map (fun h => (PRE_first_tail_x8_r0_body.cx0_160.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa160.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok160 : PRE_first_tail_x8_r0_body.clo160.all (objOK PRE_first_tail_x8_r0_body.kappa160 PRE_first_tail_x8_r0_body.P160.NL PRE_first_tail_x8_r0_body.cx0_160.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd160 : PRE_first_tail_x8_r0_body.cln160.all (nodeOKF PRE_first_tail_x8_r0_body.kappa160 PRE_first_tail_x8_r0_body.P160 PRE_first_tail_x8_r0_body.cx0_160.mlx PRE_first_tail_x8_r0_body.cx1_160.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp160 : ((PRE_first_tail_x8_r0_body.cln160.filter (fullB PRE_first_tail_x8_r0_body.P160))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_160.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa160.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln160.filter (fullB PRE_first_tail_x8_r0_body.P160))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_160.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa160.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI160 : incrB PRE_first_tail_x8_r0_body.kd160.nodeF (List.range' 18462 0) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK160 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd160.node).all (fun k => Nat.ble 18462 k && Nat.blt k 18462) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL160 : (PRE_first_tail_x8_r0_body.cln160.filter (Nat.ble PRE_first_tail_x8_r0_body.P160.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd160.nodeF i) && (Nat.blt i 18462 || Nat.ble PRE_first_tail_x8_r0_body.kd160.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord160 : (PRE_first_tail_x8_r0_body.cln160.filter (Nat.ble PRE_first_tail_x8_r0_body.P160.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd160.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd160.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd160.nodeF j) (PRE_first_tail_x8_r0_body.kd160.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow160 PRE_first_tail_x8_r0_body.cnn1160 PRE_first_tail_x8_r0_body.fnordI160 PRE_first_tail_x8_r0_body.fnordK160 PRE_first_tail_x8_r0_body.fnordL160
kernel_rfl PRE_first_tail_x8_r0_body.fi160 : PRE_first_tail_x8_r0_body.cli160.all (pnB PRE_first_tail_x8_r0_body.cx0_160.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii160 : PRE_first_tail_x8_r0_body.cli160.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_160.mlx.items.get (PRE_first_tail_x8_r0_body.kappa160.node k) = (PRE_first_tail_x8_r0_body.cx0_160.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa160.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot160 (clean : Conv.NClean (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P160.NL) (cl : SSt (· < 6920) PRE_first_tail_x8_r0_body.cx0_160.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P160 6920 PRE_first_tail_x8_r0_body.kappa160 PRE_first_tail_x8_r0_body.kd160 PRE_first_tail_x8_r0_body.khinv160 PRE_first_tail_x8_r0_body.kninv160 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx PRE_first_tail_x8_r0_body.cx0_160.mlx PRE_first_tail_x8_r0_body.cx1_160.mlx (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo160 PRE_first_tail_x8_r0_body.cln160 PRE_first_tail_x8_r0_body.cli160 PRE_first_tail_x8_r0_body.cwS160 PRE_first_tail_x8_r0_body.cnS160 PRE_first_tail_x8_r0_body.ciS160 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0160, PRE_first_tail_x8_r0_body.cnh1160, PRE_first_tail_x8_r0_body.cnn0160, PRE_first_tail_x8_r0_body.cnn1160, PRE_first_tail_x8_r0_body.cplo160, PRE_first_tail_x8_r0_body.ccnt160, PRE_first_tail_x8_r0_body.cnband160, PRE_first_tail_x8_r0_body.chbelow160, PRE_first_tail_x8_r0_body.chren160, PRE_first_tail_x8_r0_body.cband160, PRE_first_tail_x8_r0_body.cnh1pos160, PRE_first_tail_x8_r0_body.cnren160, PRE_first_tail_x8_r0_body.cnlow160, PRE_first_tail_x8_r0_body.cabs0a160, PRE_first_tail_x8_r0_body.cabs0b160, PRE_first_tail_x8_r0_body.ctok1160, PRE_first_tail_x8_r0_body.cpend160, PRE_first_tail_x8_r0_body.cerrh160, PRE_first_tail_x8_r0_body.cfiles160, PRE_first_tail_x8_r0_body.carch160, PRE_first_tail_x8_r0_body.csizes160, PRE_first_tail_x8_r0_body.cwired160, PRE_first_tail_x8_r0_body.cfix160, clean, PRE_first_tail_x8_r0_body.fcxn160, PRE_first_tail_x8_r0_body.fcnn160, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0160, PRE_first_tail_x8_r0_body.fnk160, PRE_first_tail_x8_r0_body.ckA160, PRE_first_tail_x8_r0_body.cobjsK160, PRE_first_tail_x8_r0_body.cnodesK160, PRE_first_tail_x8_r0_body.citemsK160, PRE_first_tail_x8_r0_body.f1A160, PRE_first_tail_x8_r0_body.f1O160, PRE_first_tail_x8_r0_body.f1N160, PRE_first_tail_x8_r0_body.f1I160, PRE_first_tail_x8_r0_body.fbd160, PRE_first_tail_x8_r0_body.fincW160, PRE_first_tail_x8_r0_body.fincI160, PRE_first_tail_x8_r0_body.fincN160, PRE_first_tail_x8_r0_body.flnF160, PRE_first_tail_x8_r0_body.fh160, PRE_first_tail_x8_r0_body.fo160, PRE_first_tail_x8_r0_body.fok160, PRE_first_tail_x8_r0_body.fnd160, PRE_first_tail_x8_r0_body.fp160, PRE_first_tail_x8_r0_body.fnord160, PRE_first_tail_x8_r0_body.fi160, PRE_first_tail_x8_r0_body.fii160⟩
theorem PRE_first_tail_x8_r0_body.cnshift160 (clean : Conv.NClean (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P160.NL) (cl : SSt (· < 6920) PRE_first_tail_x8_r0_body.cx0_160.mlx) : NShift PRE_first_tail_x8_r0_body.P160 6920 PRE_first_tail_x8_r0_body.kappa160 PRE_first_tail_x8_r0_body.cx0_160 PRE_first_tail_x8_r0_body.cx1_160 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot160 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost160 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0160 PRE_first_tail_x8_r0_body.ckn1160 PRE_first_tail_x8_r0_body.ckheap160 PRE_first_tail_x8_r0_body.ckpl160)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_160 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1548.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_160 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1548.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_160 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1548.ffi) = some PRE_first_tail_x8_r0_body.fxC_160
kernel_rfl PRE_first_tail_x8_r0_body.okrC_160 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1548.ffi) = some PRE_first_tail_x8_r0_body.krC_160
noncomputable def PRE_first_tail_x8_r0_body.fx0_160 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1550.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_160 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1550.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_160 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1550.ffi) = some PRE_first_tail_x8_r0_body.fx0_160
kernel_rfl PRE_first_tail_x8_r0_body.okr0_160 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1550.ffi) = some PRE_first_tail_x8_r0_body.kr0_160
noncomputable def PRE_first_tail_x8_r0_body.fx1_160 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1549.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_160 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1549.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_160 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1549.ffi) = some PRE_first_tail_x8_r0_body.fx1_160
kernel_rfl PRE_first_tail_x8_r0_body.okr1_160 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1549.ffi) = some PRE_first_tail_x8_r0_body.kr1_160
kernel_rfl PRE_first_tail_x8_r0_body.ff0160 : PRE_first_tail_x8_r0_body.fx0_160 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_160 (PRE_first_tail_x8_r0_body.clo160.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_160.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1160 : PRE_first_tail_x8_r0_body.fx1_160 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_160 (PRE_first_tail_x8_r0_body.cwS160.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_160.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck160 : freedLB PRE_first_tail_x8_r0_body.kappa160 PRE_first_tail_x8_r0_body.cx0_160.mlx PRE_first_tail_x8_r0_body.fx0_160 PRE_first_tail_x8_r0_body.fx1_160 PRE_first_tail_x8_r0_body.clo160 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0160 : PRE_first_tail_x8_r0_body.kr0_160.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_160.flags (PRE_first_tail_x8_r0_body.clo160.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_160.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0160 : PRE_first_tail_x8_r0_body.kr0_160.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_160.targs (PRE_first_tail_x8_r0_body.clo160.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_160.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1160 : PRE_first_tail_x8_r0_body.kr1_160.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_160.flags (PRE_first_tail_x8_r0_body.cwS160.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_160.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1160 : PRE_first_tail_x8_r0_body.kr1_160.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_160.targs (PRE_first_tail_x8_r0_body.cwS160.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_160.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck160 : krecLB PRE_first_tail_x8_r0_body.kappa160 6920 PRE_first_tail_x8_r0_body.cx0_160.mlx PRE_first_tail_x8_r0_body.kr0_160 PRE_first_tail_x8_r0_body.kr1_160 PRE_first_tail_x8_r0_body.clo160 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn160 : Nat.ble 6920 6920 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge160 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1549.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1550.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR160 : pendRegB PRE_first_tail_x8_r0_body.kappa160 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1550.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe160 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1550.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1549.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift160 (clean : Conv.NClean (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P160.NL) (cl : SSt (· < 6920) PRE_first_tail_x8_r0_body.cx0_160.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_160.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_160.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_160.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1548.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_160.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P160 6920 PRE_first_tail_x8_r0_body.kappa160 PRE_first_tail_x8_r0_body.s1550.ffi PRE_first_tail_x8_r0_body.s1549.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift160 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue160, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp160 t ht),
    PRE_first_tail_x8_r0_body.cbridge160,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1550.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1549.ffi) (PRE_first_tail_x8_r0_body.cfoot160 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_160 PRE_first_tail_x8_r0_body.ofx1_160 hobjC PRE_first_tail_x8_r0_body.ff0160 PRE_first_tail_x8_r0_body.ff1160 PRE_first_tail_x8_r0_body.ffck160,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1550.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1549.ffi) (PRE_first_tail_x8_r0_body.cfoot160 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_160 PRE_first_tail_x8_r0_body.okr1_160 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn160) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0160 PRE_first_tail_x8_r0_body.fkt0160 PRE_first_tail_x8_r0_body.fkf1160 PRE_first_tail_x8_r0_body.fkt1160 PRE_first_tail_x8_r0_body.fkck160,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0160 PRE_first_tail_x8_r0_body.cnh1160 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe160) PRE_first_tail_x8_r0_body.cpendR160⟩

end Host.Load.Run.Tpl
end

section -- st160/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st160 0
host_stream_state PRE_first_tail_x8_r0_body.st160 1
host_stream_state PRE_first_tail_x8_r0_body.st160 2
end Host.Load.Run.Tpl
end

section -- Site160
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 160 of chain `PRE_first_tail_x8_r0_body`: `rowBlocks__g160__g161` (`rowBlocks`), the call state `PRE_first_tail_x8_r0_body.s1548`, the merged state `PRE_first_tail_x8_r0_body.s1549`,
the site template `PRE_first_tail_x8_r0_body.st160` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1550`: the merge.
The footprint's facts are in `SiteF160`, the compaction's in `SiteC160`, `SiteK160`, `SiteNa160`, `SiteNb160`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso160 : PRE_first_tail_x8_r0_body.st160.s0 = { PRE_first_tail_x8_r0_body.s1548 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs160 : List Frame := PRE_first_tail_x8_r0_body.s1548.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_160 : PRE_first_tail_x8_r0_body.S1548.tab.length = 6920
kernel_rfl PRE_first_tail_x8_r0_body.tab0_160 : PRE_first_tail_x8_r0_body.st160.S0.tab = PRE_first_tail_x8_r0_body.S1548.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws160 : List Nat := [3708, 3709]
kernel_rfl PRE_first_tail_x8_r0_body.fresh160 : (PRE_first_tail_x8_r0_body.S1548.tab.all fun e => PRE_first_tail_x8_r0_body.ws160.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1548.oracle.all fun q => PRE_first_tail_x8_r0_body.ws160.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab160 : PRE_first_tail_x8_r0_body.S1549.tab = PRE_first_tail_x8_r0_body.S1548.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws160
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen160 : PRE_first_tail_x8_r0_body.st160.S2.tab.length - PRE_first_tail_x8_r0_body.st160.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged160`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap160 : PRE_first_tail_x8_r0_body.s1549.heap = PRE_first_tail_x8_r0_body.st160.s2.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext160 : PRE_first_tail_x8_r0_body.s1549.next = PRE_first_tail_x8_r0_body.st160.s2.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl160 : PRE_first_tail_x8_r0_body.s1549.ctl = PRE_first_tail_x8_r0_body.st160.s2.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack160 : PRE_first_tail_x8_r0_body.s1549.stack = PRE_first_tail_x8_r0_body.st160.s2.stack ++ PRE_first_tail_x8_r0_body.s1548.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs160 : PRE_first_tail_x8_r0_body.s1549.jobs = PRE_first_tail_x8_r0_body.st160.s2.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi160 : PRE_first_tail_x8_r0_body.s1549.ffi = PRE_first_tail_x8_r0_body.st160.s2.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace160 : PRE_first_tail_x8_r0_body.s1549.trace = PRE_first_tail_x8_r0_body.st160.s2.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores160 : PRE_first_tail_x8_r0_body.s1549.stores = PRE_first_tail_x8_r0_body.st160.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD160
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 160 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived160 : PRE_first_tail_x8_r0_body.nr160.map (fun r => nth? PRE_first_tail_x8_r0_body.st160.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo160 : PRE_first_tail_x8_r0_body.nr160.all (Nat.ble 6920) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj160 : PRE_first_tail_x8_r0_body.cws160.all (fun c => !PRE_first_tail_x8_r0_body.ws160.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ160 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws160 PRE_first_tail_x8_r0_body.crs160 PRE_first_tail_x8_r0_body.ws160

end Host.Load.Run.Tpl
end

section -- st160/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st160`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st160.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st160.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st160.s2.heap PRE_first_tail_x8_r0_body.st160.wrR ++ freshOf PRE_first_tail_x8_r0_body.st160.s2.heap PRE_first_tail_x8_r0_body.st160.s0.next PRE_first_tail_x8_r0_body.st160.s2.next
noncomputable def PRE_first_tail_x8_r0_body.st160.wr : List Nat := PRE_first_tail_x8_r0_body.st160.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st160.heapFoot : PRE_first_tail_x8_r0_body.st160.s2.heap = setAll PRE_first_tail_x8_r0_body.st160.s0.heap PRE_first_tail_x8_r0_body.st160.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st160.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st160.s0.next PRE_first_tail_x8_r0_body.st160.s2.next = true
theorem PRE_first_tail_x8_r0_body.st160.grows : PRE_first_tail_x8_r0_body.st160.s0.next ≤ PRE_first_tail_x8_r0_body.st160.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st160.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st160.wh : List Nat := []
def PRE_first_tail_x8_r0_body.st160.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st160.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st160.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st160.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st160.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st160.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st160.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st160.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st160.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st160.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st160.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st160.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st160.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st160.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st160.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st160.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st160.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st160.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st160.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st160.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st160.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st160.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st160.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st160.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st160.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st160.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st160.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st160.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st160.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st160.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF160
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 160 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB160 : nodupT PRE_first_tail_x8_r0_body.st160.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup160 : PRE_first_tail_x8_r0_body.st160.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB160).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB160 : PRE_first_tail_x8_r0_body.st160.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound160 : ∀ b ∈ PRE_first_tail_x8_r0_body.st160.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB160 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr160 := PRE_first_tail_x8_r0_body.st160.s2.trace.take 0
kernel_rfl PRE_first_tail_x8_r0_body.traceEq160 : PRE_first_tail_x8_r0_body.st160.s2.trace = PRE_first_tail_x8_r0_body.trFr160 ++ PRE_first_tail_x8_r0_body.st160.s0.trace
theorem PRE_first_tail_x8_r0_body.trace160 : ∃ fr, PRE_first_tail_x8_r0_body.st160.s2.trace = fr ++ PRE_first_tail_x8_r0_body.st160.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq160⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide160 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB160 : (PRE_first_tail_x8_r0_body.wide160.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st160.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix160 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide160, WFix Map.id (Present PRE_first_tail_x8_r0_body.st160.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB160 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL160
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 160 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1549`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO160 : PRE_first_tail_x8_r0_body.st160.S0.oracle = PRE_first_tail_x8_r0_body.st160.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B160 : PRE_first_tail_x8_r0_body.st160.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st160.s0.next || (PRE_first_tail_x8_r0_body.st160.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot160 : Conv.StageFoot PRE_first_tail_x8_r0_body.st160.wr PRE_first_tail_x8_r0_body.st160.s0 PRE_first_tail_x8_r0_body.st160.s2 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st160.heapFoot PRE_first_tail_x8_r0_body.wrNodup160 PRE_first_tail_x8_r0_body.wrBound160 PRE_first_tail_x8_r0_body.wr0B160 PRE_first_tail_x8_r0_body.st160.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged160 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st160.F.S → PRE_first_tail_x8_r0_body.st160.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st160.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st160.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs160 PRE_first_tail_x8_r0_body.st160.wr PRE_first_tail_x8_r0_body.s1548 PRE_first_tail_x8_r0_body.st160.s2 PRE_first_tail_x8_r0_body.st160.s0
      PRE_first_tail_x8_r0_body.st160.s2.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st160.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1549 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso160 PRE_first_tail_x8_r0_body.stFoot160 PRE_first_tail_x8_r0_body.wrNodup160 PRE_first_tail_x8_r0_body.wrBound160 PRE_first_tail_x8_r0_body.trace160 PRE_first_tail_x8_r0_body.mheap160
    PRE_first_tail_x8_r0_body.mnext160 PRE_first_tail_x8_r0_body.mctl160 PRE_first_tail_x8_r0_body.mstack160 PRE_first_tail_x8_r0_body.mjobs160 PRE_first_tail_x8_r0_body.mffi160 PRE_first_tail_x8_r0_body.mtrace160 PRE_first_tail_x8_r0_body.mstores160 h

def PRE_first_tail_x8_r0_body.arrEl160_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE160_2665 : arrOf PRE_first_tail_x8_r0_body.s1549 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl160_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA160_2665 : isArrB PRE_first_tail_x8_r0_body.s1549 2665 = true
theorem PRE_first_tail_x8_r0_body.arr160_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1549.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl160_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE160_2665 PRE_first_tail_x8_r0_body.arrA160_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN160_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl160_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR160_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl160_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN160_2665

def PRE_first_tail_x8_r0_body.arrEl160_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE160_2673467 : arrOf PRE_first_tail_x8_r0_body.s1549 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl160_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA160_2673467 : isArrB PRE_first_tail_x8_r0_body.s1549 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr160_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1549.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl160_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE160_2673467 PRE_first_tail_x8_r0_body.arrA160_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN160_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl160_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR160_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl160_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN160_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k160 : isArrB PRE_first_tail_x8_r0_body.s1549 4910 = false
theorem PRE_first_tail_x8_r0_body.keep160 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1549 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k160 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr160_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl160_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ160
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 160 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1548`, the merged
state `PRE_first_tail_x8_r0_body.s1549`, the canonical state `PRE_first_tail_x8_r0_body.s1550`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl160 : PRE_first_tail_x8_r0_body.pl160.all (Nat.ble PRE_first_tail_x8_r0_body.s1548.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd160 : nodupT PRE_first_tail_x8_r0_body.pl160 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1160 : Nat.ble PRE_first_tail_x8_r0_body.s1548.next 2800633 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst160 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1548.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn160 : PRE_first_tail_x8_r0_body.s1550.next = PRE_first_tail_x8_r0_body.s1548.next + PRE_first_tail_x8_r0_body.pl160.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn160 : PRE_first_tail_x8_r0_body.s1549.next = 2800633
kernel_rfl PRE_first_tail_x8_r0_body.zgrow160 : Nat.ble PRE_first_tail_x8_r0_body.s1550.next PRE_first_tail_x8_r0_body.s1549.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh160 : PRE_first_tail_x8_r0_body.S1548.tab.all (fun e => PRE_first_tail_x8_r0_body.cws160.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd160 : nodupT PRE_first_tail_x8_r0_body.cws160 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi160 : PRE_first_tail_x8_r0_body.nr160.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1549.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt160 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1548.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg160_2665 : PRE_first_tail_x8_r0_body.s1550.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1550 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk160_2665 : (objOf PRE_first_tail_x8_r0_body.s1550 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm160_2665 : PRE_first_tail_x8_r0_body.s1549.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa160.obj (objOf PRE_first_tail_x8_r0_body.s1550 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1549 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg160_2673467 : PRE_first_tail_x8_r0_body.s1550.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1550 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk160_2673467 : (objOf PRE_first_tail_x8_r0_body.s1550 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm160_2673467 : PRE_first_tail_x8_r0_body.s1549.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa160.obj (objOf PRE_first_tail_x8_r0_body.s1550 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1549 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw160_4910 : (PRE_first_tail_x8_r0_body.s1550.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw160_2673472 : (PRE_first_tail_x8_r0_body.s1550.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw160_2673473 : (PRE_first_tail_x8_r0_body.s1550.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd160 : PRE_first_tail_x8_r0_body.cl160.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr160 : PRE_first_tail_x8_r0_body.st160.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1548.next || PRE_first_tail_x8_r0_body.cl160.contains b) = true
def PRE_first_tail_x8_r0_body.zl160 : List Nat := PRE_first_tail_x8_r0_body.cl160.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE160 : PRE_first_tail_x8_r0_body.zl160.map (fun a => PRE_first_tail_x8_r0_body.s1549.heap.get (PRE_first_tail_x8_r0_body.kappa160.a a)) = PRE_first_tail_x8_r0_body.zl160.map (fun a => (PRE_first_tail_x8_r0_body.s1550.heap.get a).map PRE_first_tail_x8_r0_body.kappa160.hobj)
theorem PRE_first_tail_x8_r0_body.zimg160 : HeapImg PRE_first_tail_x8_r0_body.kappa160 PRE_first_tail_x8_r0_body.s1550 PRE_first_tail_x8_r0_body.s1549 PRE_first_tail_x8_r0_body.zl160 := PRE_first_tail_x8_r0_body.zimgE160
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl160 : PRE_first_tail_x8_r0_body.s1549.ctl = PRE_first_tail_x8_r0_body.kappa160.ctl PRE_first_tail_x8_r0_body.s1550.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack160 : PRE_first_tail_x8_r0_body.s1549.stack = PRE_first_tail_x8_r0_body.s1550.stack.map PRE_first_tail_x8_r0_body.kappa160.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs160 : PRE_first_tail_x8_r0_body.s1549.jobs = PRE_first_tail_x8_r0_body.s1550.jobs.map PRE_first_tail_x8_r0_body.kappa160.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores160 : PRE_first_tail_x8_r0_body.s1549.stores = PRE_first_tail_x8_r0_body.kappa160.stores PRE_first_tail_x8_r0_body.s1550.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots160 : checkRootsSupp PRE_first_tail_x8_r0_body.s1550 6920 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC160 : PRE_first_tail_x8_r0_body.S1548.tab.length + PRE_first_tail_x8_r0_body.cws160.length = 6920
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap160 : PRE_first_tail_x8_r0_body.kappa160 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1548.next 2800633 PRE_first_tail_x8_r0_body.S1548.tab.length PRE_first_tail_x8_r0_body.pl160 (PRE_first_tail_x8_r0_body.nr160.map NumV.ref) PRE_first_tail_x8_r0_body.kd160.big
  PRE_first_tail_x8_r0_body.kd160.region PRE_first_tail_x8_r0_body.kd160.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin160 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1550.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc160 : Conv.jcleanListB (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1550 PRE_first_tail_x8_r0_body.cl160 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB160 : noBigRootsP (fun i => !Conv.oldBigB (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1550.trace PRE_first_tail_x8_r0_body.s1550 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm160 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 18462 = true
theorem PRE_first_tail_x8_r0_body.cjcl160 (h : Conv.JClean (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1548) : Conv.JClean (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1550 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle160)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap160 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd160 a ha)) PRE_first_tail_x8_r0_body.zjc160

end Host.Load.Run.Tpl
end

section -- st160/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st160.bodyLast from PRE_first_tail_x8_r0_body.st160.s1 to PRE_first_tail_x8_r0_body.st160.s2 :
  interpS (step PRE_first_tail_x8_r0_body.st160.F PRE_first_tail_x8_r0_body.st160.s1).run PRE_first_tail_x8_r0_body.st160.S1 = some (PRE_first_tail_x8_r0_body.st160.s2, PRE_first_tail_x8_r0_body.st160.S2)
kernel_rfl PRE_first_tail_x8_r0_body.st160.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st160.s1.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st160.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st160.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st160/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st160.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st160.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st160.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st160.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st160.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st160.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st160.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st160.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st160.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st160.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st160.s0 PRE_first_tail_x8_r0_body.st160.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st160.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st160.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st160.s1 PRE_first_tail_x8_r0_body.st160.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st160/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st160.bodyK0F from PRE_first_tail_x8_r0_body.st160.s0 to PRE_first_tail_x8_r0_body.st160.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st160.F (PRE_first_tail_x8_r0_body.st160.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st160.ks 0).getD 0) PRE_first_tail_x8_r0_body.st160.s0 PRE_first_tail_x8_r0_body.st160.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st160.s1, PRE_first_tail_x8_r0_body.st160.S1)
theorem PRE_first_tail_x8_r0_body.st160.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st160.F (PRE_first_tail_x8_r0_body.st160.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st160.ks 0).getD 0) PRE_first_tail_x8_r0_body.st160.s0 PRE_first_tail_x8_r0_body.st160.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st160.s1, PRE_first_tail_x8_r0_body.st160.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st160.bodyOkLN_ok PRE_first_tail_x8_r0_body.st160.bodyK0F
end Host.Load.Run.Tpl
end

section -- st160/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st160.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st160.F (PRE_first_tail_x8_r0_body.st160.bodyOkL bytes rows) 27 PRE_first_tail_x8_r0_body.st160.s0 PRE_first_tail_x8_r0_body.st160.S0 = some (PRE_first_tail_x8_r0_body.st160.s1, PRE_first_tail_x8_r0_body.st160.S1) :=
  (congrFun (congrFun PRE_first_tail_x8_r0_body.st160.bodyK0 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st160.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st160.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st160.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st160.F (PRE_first_tail_x8_r0_body.st160.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st160.s0
  S0 := PRE_first_tail_x8_r0_body.st160.S0
  s1 := PRE_first_tail_x8_r0_body.st160.s1
  S1 := PRE_first_tail_x8_r0_body.st160.S1
  s2 := PRE_first_tail_x8_r0_body.st160.s2
  S2 := PRE_first_tail_x8_r0_body.st160.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st160.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st160.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st160.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st160.bodyHalt
  last := PRE_first_tail_x8_r0_body.st160.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st160.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC161
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 161 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1554` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa161` into the merged state
`PRE_first_tail_x8_r0_body.s1553`. -/

def PRE_first_tail_x8_r0_body.pl161 : List Nat := [2800929]
def PRE_first_tail_x8_r0_body.nr161 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd161 : RData :=
  ⟨2800920, 2800930, Stage.setAll PTrie.nil [(2800919, 2800929)], Stage.setAll PTrie.nil [],
   21364, 21364, 18466, 18466, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa161 : Map :=
  Conv.Map.compact 2800919 2800930 6937 PRE_first_tail_x8_r0_body.pl161 (PRE_first_tail_x8_r0_body.nr161.map NumV.ref) PRE_first_tail_x8_r0_body.kd161.big
    PRE_first_tail_x8_r0_body.kd161.region PRE_first_tail_x8_r0_body.kd161.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws161 : List Nat := []
noncomputable def PRE_first_tail_x8_r0_body.crs161 : List SymE := PRE_first_tail_x8_r0_body.nr161.map fun r => (nth? PRE_first_tail_x8_r0_body.S1553.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta161 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws161 PRE_first_tail_x8_r0_body.crs161
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB161 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x8_r0_body.ctab161 : PRE_first_tail_x8_r0_body.S1554.tab = PRE_first_tail_x8_r0_body.S1552.tab ++ PRE_first_tail_x8_r0_body.cws161.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace161 : PRE_first_tail_x8_r0_body.s1554.trace = PRE_first_tail_x8_r0_body.s1552.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext161 : PRE_first_tail_x8_r0_body.s1554.next = 2800920
kernel_rfl PRE_first_tail_x8_r0_body.ccounters161 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1554.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1554.ffi).mlx.nnext) = (21364, 18466)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue161 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1553.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1554.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa161.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp161 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1554.ffi).mlx.tokens.all (bSN 6937) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean161 : Conv.cleanListB 21364 131072 (fun r => Nat.ble 85456 r) PRE_first_tail_x8_r0_body.s1554
    (PRE_first_tail_x8_r0_body.wrB161 ++ (List.range 1).map (2800919 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs161 : bigsOutB 21364 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1554.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK161
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl161`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl161 : List Nat := [2665, 2673467, 2800919]
def PRE_first_tail_x8_r0_body.clo161 : List Nat := []
def PRE_first_tail_x8_r0_body.cln161 : List Nat := []
def PRE_first_tail_x8_r0_body.cli161 : List Nat := []
kernel_rfl PRE_first_tail_x8_r0_body.cheap161 : PRE_first_tail_x8_r0_body.s1554.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1552.heap (PRE_first_tail_x8_r0_body.cl161.filterMap fun a => (PRE_first_tail_x8_r0_body.s1554.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe161 : Nat.ble PRE_first_tail_x8_r0_body.s1552.next PRE_first_tail_x8_r0_body.s1554.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP161 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1552 PRE_first_tail_x8_r0_body.s1554 PRE_first_tail_x8_r0_body.cl161 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp161 : Conv.suppListB PRE_first_tail_x8_r0_body.s1554 6937 PRE_first_tail_x8_r0_body.cl161 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound161 : Conv.boundListB PRE_first_tail_x8_r0_body.s1554 PRE_first_tail_x8_r0_body.cl161 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK161 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1554.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln161.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1554.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK161 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1554.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo161.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1554.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK161 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1554.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli161.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1554.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst161 : Conv.sstListB 6937 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1554.ffi).mlx PRE_first_tail_x8_r0_body.cln161 PRE_first_tail_x8_r0_body.clo161 PRE_first_tail_x8_r0_body.cli161 = true

end Host.Load.Run.Tpl
end

section -- SiteCl161
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA161 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1554.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo161.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1554.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd161 : (PRE_first_tail_x8_r0_body.clo161 ++ PRE_first_tail_x8_r0_body.cln161 ++ PRE_first_tail_x8_r0_body.cli161).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle161 : Conv.Cnt.leB (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt) (⟨21364, 18466, 2800920, 6937⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck161 : Conv.ncleanListB (⟨21364, 18466, 2800920, 6937⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1554.ffi).mlx PRE_first_tail_x8_r0_body.clo161 PRE_first_tail_x8_r0_body.cln161 PRE_first_tail_x8_r0_body.cli161 = true
theorem PRE_first_tail_x8_r0_body.cncl161 (h : Conv.NClean (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx) : Conv.NClean (⟨21364, 18466, 2800920, 6937⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1554.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle161 PRE_first_tail_x8_r0_body.ckA161 PRE_first_tail_x8_r0_body.cobjsK161 PRE_first_tail_x8_r0_body.cnodesK161 PRE_first_tail_x8_r0_body.citemsK161 PRE_first_tail_x8_r0_body.cbd161 PRE_first_tail_x8_r0_body.cck161

end Host.Load.Run.Tpl
end

section -- SiteS161
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 161 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc161 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P161 : LoadP := PRE_first_tail_x8_r0_body.Pc161.raise 18466
kernel_rfl PRE_first_tail_x8_r0_body.craise161 : Nat.ble PRE_first_tail_x8_r0_body.Pc161.N0 18466 = true
theorem PRE_first_tail_x8_r0_body.raised161 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc161 PRE_first_tail_x8_r0_body.P161 :=
  .inr ⟨18466, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise161, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_161 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1554.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_161 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1553.ffi)
def PRE_first_tail_x8_r0_body.khinv161 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x8_r0_body.kninv161 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS161 : List Nat := []
def PRE_first_tail_x8_r0_body.cnS161 : List Nat := List.range' 18466 0
def PRE_first_tail_x8_r0_body.ciS161 : List Nat := [] ++ List.range' 18466 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0161 : PRE_first_tail_x8_r0_body.kd161.nh0 = PRE_first_tail_x8_r0_body.cx0_161.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1161 : PRE_first_tail_x8_r0_body.kd161.nh1 = PRE_first_tail_x8_r0_body.cx1_161.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0161 : PRE_first_tail_x8_r0_body.kd161.nn0 = PRE_first_tail_x8_r0_body.cx0_161.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1161 : PRE_first_tail_x8_r0_body.kd161.nn1 = PRE_first_tail_x8_r0_body.cx1_161.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo161 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P161.lo && Nat.ble PRE_first_tail_x8_r0_body.P161.lo PRE_first_tail_x8_r0_body.cx0_161.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P161.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P161.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt161 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_161.mlx.next PRE_first_tail_x8_r0_body.cx1_161.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_161.mlx.nnext PRE_first_tail_x8_r0_body.cx1_161.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband161 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P161.NL && Nat.ble PRE_first_tail_x8_r0_body.P161.NL PRE_first_tail_x8_r0_body.P161.N0 && Nat.ble PRE_first_tail_x8_r0_body.P161.N0 PRE_first_tail_x8_r0_body.cx0_161.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow161 : PRE_first_tail_x8_r0_body.kd161.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren161 : checkRenG PRE_first_tail_x8_r0_body.kd161.hnd PRE_first_tail_x8_r0_body.khinv161 (phB PRE_first_tail_x8_r0_body.cx0_161.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband161 : PRE_first_tail_x8_r0_body.kd161.checkBand PRE_first_tail_x8_r0_body.P161.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos161 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd161.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren161 : checkRenG PRE_first_tail_x8_r0_body.kd161.node PRE_first_tail_x8_r0_body.kninv161 (pnB PRE_first_tail_x8_r0_body.cx0_161.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow161 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd161.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P161.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd161.nodeF j) PRE_first_tail_x8_r0_body.cx1_161.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a161 : PRE_first_tail_x8_r0_body.cx0_161.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b161 : PRE_first_tail_x8_r0_body.cx0_161.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1161 : PRE_first_tail_x8_r0_body.cx1_161.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend161 : PRE_first_tail_x8_r0_body.cx1_161.mlx.pending = PRE_first_tail_x8_r0_body.cx0_161.mlx.pending.map PRE_first_tail_x8_r0_body.kappa161.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh161 : PRE_first_tail_x8_r0_body.cx1_161.mlx.errh = PRE_first_tail_x8_r0_body.cx0_161.mlx.errh.map PRE_first_tail_x8_r0_body.kappa161.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles161 : PRE_first_tail_x8_r0_body.cx1_161.mlx.files = PRE_first_tail_x8_r0_body.cx0_161.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch161 : PRE_first_tail_x8_r0_body.cx1_161.mlx.arch = PRE_first_tail_x8_r0_body.cx0_161.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes161 : PRE_first_tail_x8_r0_body.cx1_161.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_161.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired161 : PRE_first_tail_x8_r0_body.cx1_161.mlx.wired = PRE_first_tail_x8_r0_body.cx0_161.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost161 : PRE_first_tail_x8_r0_body.cx1_161.host = PRE_first_tail_x8_r0_body.cx0_161.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd161`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0161 : PRE_first_tail_x8_r0_body.kd161.n0 = 2800920
kernel_rfl PRE_first_tail_x8_r0_body.ckn1161 : PRE_first_tail_x8_r0_body.kd161.n1 = 2800930
kernel_rfl PRE_first_tail_x8_r0_body.ckheap161 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd161.heap).all (fun x => Nat.ble 2800919 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl161 : (List.range 1).all (fun j => decide (PRE_first_tail_x8_r0_body.kd161.heap.get (2800919 + j) = nth? PRE_first_tail_x8_r0_body.pl161 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja161 : Nat.ble 2800919 2800919 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn161 : Nat.ble 6937 6937 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD161 : Nat.ble 2800919 PRE_first_tail_x8_r0_body.kd161.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn161 : Nat.ble 21364 PRE_first_tail_x8_r0_body.kd161.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn161 : Nat.ble 18466 PRE_first_tail_x8_r0_body.kd161.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb161 : Nat.ble 21364 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap161 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd161.heap).all (Nat.ble (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd161 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd161.hnd).all (Nat.ble (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode161 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd161.node).all (Nat.ble (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix161 : Conv.FixOld (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa161 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja161) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn161) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD161) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn161) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn161) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb161) PRE_first_tail_x8_r0_body.fheap161 PRE_first_tail_x8_r0_body.fhnd161 PRE_first_tail_x8_r0_body.fnode161
kernel_rfl PRE_first_tail_x8_r0_body.fcxn161 : (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn161 : (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0161 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_161.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_161.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk161 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd161.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A161 : PRE_first_tail_x8_r0_body.cx1_161.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS161.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_161.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O161 : PRE_first_tail_x8_r0_body.cx1_161.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS161.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_161.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N161 : PRE_first_tail_x8_r0_body.cx1_161.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS161.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_161.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I161 : PRE_first_tail_x8_r0_body.cx1_161.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS161.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_161.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd161 : (PRE_first_tail_x8_r0_body.clo161 ++ PRE_first_tail_x8_r0_body.cln161 ++ PRE_first_tail_x8_r0_body.cli161 ++ PRE_first_tail_x8_r0_body.cwS161 ++ PRE_first_tail_x8_r0_body.cnS161 ++ PRE_first_tail_x8_r0_body.ciS161).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW161 : PRE_first_tail_x8_r0_body.cwS161.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo161.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI161 : PRE_first_tail_x8_r0_body.ciS161.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli161.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN161 : PRE_first_tail_x8_r0_body.cnS161.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF161 : PRE_first_tail_x8_r0_body.cln161.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh161 : PRE_first_tail_x8_r0_body.clo161.all (handleOK PRE_first_tail_x8_r0_body.kappa161 PRE_first_tail_x8_r0_body.P161.lo PRE_first_tail_x8_r0_body.cx0_161.mlx PRE_first_tail_x8_r0_body.cx1_161.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo161 : PRE_first_tail_x8_r0_body.clo161.map (fun h => PRE_first_tail_x8_r0_body.cx1_161.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa161.handle h)) = PRE_first_tail_x8_r0_body.clo161.map (fun h => (PRE_first_tail_x8_r0_body.cx0_161.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa161.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok161 : PRE_first_tail_x8_r0_body.clo161.all (objOK PRE_first_tail_x8_r0_body.kappa161 PRE_first_tail_x8_r0_body.P161.NL PRE_first_tail_x8_r0_body.cx0_161.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd161 : PRE_first_tail_x8_r0_body.cln161.all (nodeOKF PRE_first_tail_x8_r0_body.kappa161 PRE_first_tail_x8_r0_body.P161 PRE_first_tail_x8_r0_body.cx0_161.mlx PRE_first_tail_x8_r0_body.cx1_161.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp161 : ((PRE_first_tail_x8_r0_body.cln161.filter (fullB PRE_first_tail_x8_r0_body.P161))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_161.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa161.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln161.filter (fullB PRE_first_tail_x8_r0_body.P161))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_161.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa161.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI161 : incrB PRE_first_tail_x8_r0_body.kd161.nodeF (List.range' 18466 0) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK161 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd161.node).all (fun k => Nat.ble 18466 k && Nat.blt k 18466) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL161 : (PRE_first_tail_x8_r0_body.cln161.filter (Nat.ble PRE_first_tail_x8_r0_body.P161.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd161.nodeF i) && (Nat.blt i 18466 || Nat.ble PRE_first_tail_x8_r0_body.kd161.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord161 : (PRE_first_tail_x8_r0_body.cln161.filter (Nat.ble PRE_first_tail_x8_r0_body.P161.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd161.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd161.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd161.nodeF j) (PRE_first_tail_x8_r0_body.kd161.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow161 PRE_first_tail_x8_r0_body.cnn1161 PRE_first_tail_x8_r0_body.fnordI161 PRE_first_tail_x8_r0_body.fnordK161 PRE_first_tail_x8_r0_body.fnordL161
kernel_rfl PRE_first_tail_x8_r0_body.fi161 : PRE_first_tail_x8_r0_body.cli161.all (pnB PRE_first_tail_x8_r0_body.cx0_161.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii161 : PRE_first_tail_x8_r0_body.cli161.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_161.mlx.items.get (PRE_first_tail_x8_r0_body.kappa161.node k) = (PRE_first_tail_x8_r0_body.cx0_161.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa161.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot161 (clean : Conv.NClean (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P161.NL) (cl : SSt (· < 6937) PRE_first_tail_x8_r0_body.cx0_161.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P161 6937 PRE_first_tail_x8_r0_body.kappa161 PRE_first_tail_x8_r0_body.kd161 PRE_first_tail_x8_r0_body.khinv161 PRE_first_tail_x8_r0_body.kninv161 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx PRE_first_tail_x8_r0_body.cx0_161.mlx PRE_first_tail_x8_r0_body.cx1_161.mlx (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo161 PRE_first_tail_x8_r0_body.cln161 PRE_first_tail_x8_r0_body.cli161 PRE_first_tail_x8_r0_body.cwS161 PRE_first_tail_x8_r0_body.cnS161 PRE_first_tail_x8_r0_body.ciS161 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0161, PRE_first_tail_x8_r0_body.cnh1161, PRE_first_tail_x8_r0_body.cnn0161, PRE_first_tail_x8_r0_body.cnn1161, PRE_first_tail_x8_r0_body.cplo161, PRE_first_tail_x8_r0_body.ccnt161, PRE_first_tail_x8_r0_body.cnband161, PRE_first_tail_x8_r0_body.chbelow161, PRE_first_tail_x8_r0_body.chren161, PRE_first_tail_x8_r0_body.cband161, PRE_first_tail_x8_r0_body.cnh1pos161, PRE_first_tail_x8_r0_body.cnren161, PRE_first_tail_x8_r0_body.cnlow161, PRE_first_tail_x8_r0_body.cabs0a161, PRE_first_tail_x8_r0_body.cabs0b161, PRE_first_tail_x8_r0_body.ctok1161, PRE_first_tail_x8_r0_body.cpend161, PRE_first_tail_x8_r0_body.cerrh161, PRE_first_tail_x8_r0_body.cfiles161, PRE_first_tail_x8_r0_body.carch161, PRE_first_tail_x8_r0_body.csizes161, PRE_first_tail_x8_r0_body.cwired161, PRE_first_tail_x8_r0_body.cfix161, clean, PRE_first_tail_x8_r0_body.fcxn161, PRE_first_tail_x8_r0_body.fcnn161, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0161, PRE_first_tail_x8_r0_body.fnk161, PRE_first_tail_x8_r0_body.ckA161, PRE_first_tail_x8_r0_body.cobjsK161, PRE_first_tail_x8_r0_body.cnodesK161, PRE_first_tail_x8_r0_body.citemsK161, PRE_first_tail_x8_r0_body.f1A161, PRE_first_tail_x8_r0_body.f1O161, PRE_first_tail_x8_r0_body.f1N161, PRE_first_tail_x8_r0_body.f1I161, PRE_first_tail_x8_r0_body.fbd161, PRE_first_tail_x8_r0_body.fincW161, PRE_first_tail_x8_r0_body.fincI161, PRE_first_tail_x8_r0_body.fincN161, PRE_first_tail_x8_r0_body.flnF161, PRE_first_tail_x8_r0_body.fh161, PRE_first_tail_x8_r0_body.fo161, PRE_first_tail_x8_r0_body.fok161, PRE_first_tail_x8_r0_body.fnd161, PRE_first_tail_x8_r0_body.fp161, PRE_first_tail_x8_r0_body.fnord161, PRE_first_tail_x8_r0_body.fi161, PRE_first_tail_x8_r0_body.fii161⟩
theorem PRE_first_tail_x8_r0_body.cnshift161 (clean : Conv.NClean (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P161.NL) (cl : SSt (· < 6937) PRE_first_tail_x8_r0_body.cx0_161.mlx) : NShift PRE_first_tail_x8_r0_body.P161 6937 PRE_first_tail_x8_r0_body.kappa161 PRE_first_tail_x8_r0_body.cx0_161 PRE_first_tail_x8_r0_body.cx1_161 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot161 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost161 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0161 PRE_first_tail_x8_r0_body.ckn1161 PRE_first_tail_x8_r0_body.ckheap161 PRE_first_tail_x8_r0_body.ckpl161)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_161 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1552.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_161 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1552.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_161 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1552.ffi) = some PRE_first_tail_x8_r0_body.fxC_161
kernel_rfl PRE_first_tail_x8_r0_body.okrC_161 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1552.ffi) = some PRE_first_tail_x8_r0_body.krC_161
noncomputable def PRE_first_tail_x8_r0_body.fx0_161 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1554.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_161 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1554.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_161 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1554.ffi) = some PRE_first_tail_x8_r0_body.fx0_161
kernel_rfl PRE_first_tail_x8_r0_body.okr0_161 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1554.ffi) = some PRE_first_tail_x8_r0_body.kr0_161
noncomputable def PRE_first_tail_x8_r0_body.fx1_161 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1553.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_161 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1553.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_161 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1553.ffi) = some PRE_first_tail_x8_r0_body.fx1_161
kernel_rfl PRE_first_tail_x8_r0_body.okr1_161 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1553.ffi) = some PRE_first_tail_x8_r0_body.kr1_161
kernel_rfl PRE_first_tail_x8_r0_body.ff0161 : PRE_first_tail_x8_r0_body.fx0_161 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_161 (PRE_first_tail_x8_r0_body.clo161.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_161.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1161 : PRE_first_tail_x8_r0_body.fx1_161 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_161 (PRE_first_tail_x8_r0_body.cwS161.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_161.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck161 : freedLB PRE_first_tail_x8_r0_body.kappa161 PRE_first_tail_x8_r0_body.cx0_161.mlx PRE_first_tail_x8_r0_body.fx0_161 PRE_first_tail_x8_r0_body.fx1_161 PRE_first_tail_x8_r0_body.clo161 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0161 : PRE_first_tail_x8_r0_body.kr0_161.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_161.flags (PRE_first_tail_x8_r0_body.clo161.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_161.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0161 : PRE_first_tail_x8_r0_body.kr0_161.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_161.targs (PRE_first_tail_x8_r0_body.clo161.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_161.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1161 : PRE_first_tail_x8_r0_body.kr1_161.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_161.flags (PRE_first_tail_x8_r0_body.cwS161.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_161.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1161 : PRE_first_tail_x8_r0_body.kr1_161.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_161.targs (PRE_first_tail_x8_r0_body.cwS161.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_161.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck161 : krecLB PRE_first_tail_x8_r0_body.kappa161 6937 PRE_first_tail_x8_r0_body.cx0_161.mlx PRE_first_tail_x8_r0_body.kr0_161 PRE_first_tail_x8_r0_body.kr1_161 PRE_first_tail_x8_r0_body.clo161 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn161 : Nat.ble 6937 6937 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge161 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1553.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1554.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR161 : pendRegB PRE_first_tail_x8_r0_body.kappa161 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1554.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe161 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1554.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1553.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift161 (clean : Conv.NClean (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P161.NL) (cl : SSt (· < 6937) PRE_first_tail_x8_r0_body.cx0_161.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_161.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_161.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_161.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1552.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_161.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P161 6937 PRE_first_tail_x8_r0_body.kappa161 PRE_first_tail_x8_r0_body.s1554.ffi PRE_first_tail_x8_r0_body.s1553.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift161 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue161, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp161 t ht),
    PRE_first_tail_x8_r0_body.cbridge161,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1554.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1553.ffi) (PRE_first_tail_x8_r0_body.cfoot161 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_161 PRE_first_tail_x8_r0_body.ofx1_161 hobjC PRE_first_tail_x8_r0_body.ff0161 PRE_first_tail_x8_r0_body.ff1161 PRE_first_tail_x8_r0_body.ffck161,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1554.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1553.ffi) (PRE_first_tail_x8_r0_body.cfoot161 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_161 PRE_first_tail_x8_r0_body.okr1_161 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn161) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0161 PRE_first_tail_x8_r0_body.fkt0161 PRE_first_tail_x8_r0_body.fkf1161 PRE_first_tail_x8_r0_body.fkt1161 PRE_first_tail_x8_r0_body.fkck161,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0161 PRE_first_tail_x8_r0_body.cnh1161 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe161) PRE_first_tail_x8_r0_body.cpendR161⟩

end Host.Load.Run.Tpl
end

section -- st161/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st161 0
host_stream_state PRE_first_tail_x8_r0_body.st161 1
host_stream_state PRE_first_tail_x8_r0_body.st161 2
end Host.Load.Run.Tpl
end

section -- Site161
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 161 of chain `PRE_first_tail_x8_r0_body`: `plan__g161__g162` (`plan`), the call state `PRE_first_tail_x8_r0_body.s1552`, the merged state `PRE_first_tail_x8_r0_body.s1553`,
the site template `PRE_first_tail_x8_r0_body.st161` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1554`: the merge.
The footprint's facts are in `SiteF161`, the compaction's in `SiteC161`, `SiteK161`, `SiteNa161`, `SiteNb161`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso161 : PRE_first_tail_x8_r0_body.st161.s0 = { PRE_first_tail_x8_r0_body.s1552 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs161 : List Frame := PRE_first_tail_x8_r0_body.s1552.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_161 : PRE_first_tail_x8_r0_body.S1552.tab.length = 6937
kernel_rfl PRE_first_tail_x8_r0_body.tab0_161 : PRE_first_tail_x8_r0_body.st161.S0.tab = PRE_first_tail_x8_r0_body.S1552.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws161 : List Nat := [3710, 3711, 3712]
kernel_rfl PRE_first_tail_x8_r0_body.fresh161 : (PRE_first_tail_x8_r0_body.S1552.tab.all fun e => PRE_first_tail_x8_r0_body.ws161.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1552.oracle.all fun q => PRE_first_tail_x8_r0_body.ws161.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab161 : PRE_first_tail_x8_r0_body.S1553.tab = PRE_first_tail_x8_r0_body.S1552.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws161
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen161 : PRE_first_tail_x8_r0_body.st161.S2.tab.length - PRE_first_tail_x8_r0_body.st161.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged161`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap161 : PRE_first_tail_x8_r0_body.s1553.heap = PRE_first_tail_x8_r0_body.st161.s2.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext161 : PRE_first_tail_x8_r0_body.s1553.next = PRE_first_tail_x8_r0_body.st161.s2.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl161 : PRE_first_tail_x8_r0_body.s1553.ctl = PRE_first_tail_x8_r0_body.st161.s2.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack161 : PRE_first_tail_x8_r0_body.s1553.stack = PRE_first_tail_x8_r0_body.st161.s2.stack ++ PRE_first_tail_x8_r0_body.s1552.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs161 : PRE_first_tail_x8_r0_body.s1553.jobs = PRE_first_tail_x8_r0_body.st161.s2.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi161 : PRE_first_tail_x8_r0_body.s1553.ffi = PRE_first_tail_x8_r0_body.st161.s2.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace161 : PRE_first_tail_x8_r0_body.s1553.trace = PRE_first_tail_x8_r0_body.st161.s2.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores161 : PRE_first_tail_x8_r0_body.s1553.stores = PRE_first_tail_x8_r0_body.st161.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD161
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 161 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived161 : PRE_first_tail_x8_r0_body.nr161.map (fun r => nth? PRE_first_tail_x8_r0_body.st161.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo161 : PRE_first_tail_x8_r0_body.nr161.all (Nat.ble 6937) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj161 : PRE_first_tail_x8_r0_body.cws161.all (fun c => !PRE_first_tail_x8_r0_body.ws161.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ161 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws161 PRE_first_tail_x8_r0_body.crs161 PRE_first_tail_x8_r0_body.ws161

end Host.Load.Run.Tpl
end

section -- st161/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st161`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st161.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st161.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st161.s2.heap PRE_first_tail_x8_r0_body.st161.wrR ++ freshOf PRE_first_tail_x8_r0_body.st161.s2.heap PRE_first_tail_x8_r0_body.st161.s0.next PRE_first_tail_x8_r0_body.st161.s2.next
noncomputable def PRE_first_tail_x8_r0_body.st161.wr : List Nat := PRE_first_tail_x8_r0_body.st161.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st161.heapFoot : PRE_first_tail_x8_r0_body.st161.s2.heap = setAll PRE_first_tail_x8_r0_body.st161.s0.heap PRE_first_tail_x8_r0_body.st161.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st161.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st161.s0.next PRE_first_tail_x8_r0_body.st161.s2.next = true
theorem PRE_first_tail_x8_r0_body.st161.grows : PRE_first_tail_x8_r0_body.st161.s0.next ≤ PRE_first_tail_x8_r0_body.st161.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st161.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st161.wh : List Nat := []
def PRE_first_tail_x8_r0_body.st161.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st161.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st161.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st161.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st161.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st161.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st161.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st161.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st161.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st161.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st161.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st161.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st161.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st161.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st161.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st161.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st161.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st161.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st161.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st161.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st161.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st161.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st161.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st161.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st161.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st161.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st161.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st161.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st161.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st161.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF161
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 161 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB161 : nodupT PRE_first_tail_x8_r0_body.st161.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup161 : PRE_first_tail_x8_r0_body.st161.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB161).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB161 : PRE_first_tail_x8_r0_body.st161.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound161 : ∀ b ∈ PRE_first_tail_x8_r0_body.st161.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB161 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr161 := PRE_first_tail_x8_r0_body.st161.s2.trace.take 0
kernel_rfl PRE_first_tail_x8_r0_body.traceEq161 : PRE_first_tail_x8_r0_body.st161.s2.trace = PRE_first_tail_x8_r0_body.trFr161 ++ PRE_first_tail_x8_r0_body.st161.s0.trace
theorem PRE_first_tail_x8_r0_body.trace161 : ∃ fr, PRE_first_tail_x8_r0_body.st161.s2.trace = fr ++ PRE_first_tail_x8_r0_body.st161.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq161⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide161 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB161 : (PRE_first_tail_x8_r0_body.wide161.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st161.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix161 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide161, WFix Map.id (Present PRE_first_tail_x8_r0_body.st161.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB161 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL161
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 161 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1553`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO161 : PRE_first_tail_x8_r0_body.st161.S0.oracle = PRE_first_tail_x8_r0_body.st161.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B161 : PRE_first_tail_x8_r0_body.st161.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st161.s0.next || (PRE_first_tail_x8_r0_body.st161.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot161 : Conv.StageFoot PRE_first_tail_x8_r0_body.st161.wr PRE_first_tail_x8_r0_body.st161.s0 PRE_first_tail_x8_r0_body.st161.s2 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st161.heapFoot PRE_first_tail_x8_r0_body.wrNodup161 PRE_first_tail_x8_r0_body.wrBound161 PRE_first_tail_x8_r0_body.wr0B161 PRE_first_tail_x8_r0_body.st161.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged161 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st161.F.S → PRE_first_tail_x8_r0_body.st161.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st161.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st161.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs161 PRE_first_tail_x8_r0_body.st161.wr PRE_first_tail_x8_r0_body.s1552 PRE_first_tail_x8_r0_body.st161.s2 PRE_first_tail_x8_r0_body.st161.s0
      PRE_first_tail_x8_r0_body.st161.s2.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st161.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1553 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso161 PRE_first_tail_x8_r0_body.stFoot161 PRE_first_tail_x8_r0_body.wrNodup161 PRE_first_tail_x8_r0_body.wrBound161 PRE_first_tail_x8_r0_body.trace161 PRE_first_tail_x8_r0_body.mheap161
    PRE_first_tail_x8_r0_body.mnext161 PRE_first_tail_x8_r0_body.mctl161 PRE_first_tail_x8_r0_body.mstack161 PRE_first_tail_x8_r0_body.mjobs161 PRE_first_tail_x8_r0_body.mffi161 PRE_first_tail_x8_r0_body.mtrace161 PRE_first_tail_x8_r0_body.mstores161 h

def PRE_first_tail_x8_r0_body.arrEl161_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE161_2665 : arrOf PRE_first_tail_x8_r0_body.s1553 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl161_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA161_2665 : isArrB PRE_first_tail_x8_r0_body.s1553 2665 = true
theorem PRE_first_tail_x8_r0_body.arr161_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1553.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl161_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE161_2665 PRE_first_tail_x8_r0_body.arrA161_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN161_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl161_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR161_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl161_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN161_2665

def PRE_first_tail_x8_r0_body.arrEl161_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE161_2673467 : arrOf PRE_first_tail_x8_r0_body.s1553 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl161_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA161_2673467 : isArrB PRE_first_tail_x8_r0_body.s1553 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr161_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1553.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl161_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE161_2673467 PRE_first_tail_x8_r0_body.arrA161_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN161_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl161_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR161_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl161_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN161_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k161 : isArrB PRE_first_tail_x8_r0_body.s1553 4910 = false
theorem PRE_first_tail_x8_r0_body.keep161 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1553 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k161 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr161_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl161_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ161
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 161 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1552`, the merged
state `PRE_first_tail_x8_r0_body.s1553`, the canonical state `PRE_first_tail_x8_r0_body.s1554`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl161 : PRE_first_tail_x8_r0_body.pl161.all (Nat.ble PRE_first_tail_x8_r0_body.s1552.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd161 : nodupT PRE_first_tail_x8_r0_body.pl161 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1161 : Nat.ble PRE_first_tail_x8_r0_body.s1552.next 2800930 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst161 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1552.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn161 : PRE_first_tail_x8_r0_body.s1554.next = PRE_first_tail_x8_r0_body.s1552.next + PRE_first_tail_x8_r0_body.pl161.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn161 : PRE_first_tail_x8_r0_body.s1553.next = 2800930
kernel_rfl PRE_first_tail_x8_r0_body.zgrow161 : Nat.ble PRE_first_tail_x8_r0_body.s1554.next PRE_first_tail_x8_r0_body.s1553.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh161 : PRE_first_tail_x8_r0_body.S1552.tab.all (fun e => PRE_first_tail_x8_r0_body.cws161.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd161 : nodupT PRE_first_tail_x8_r0_body.cws161 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi161 : PRE_first_tail_x8_r0_body.nr161.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1553.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt161 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1552.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg161_2665 : PRE_first_tail_x8_r0_body.s1554.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1554 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk161_2665 : (objOf PRE_first_tail_x8_r0_body.s1554 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm161_2665 : PRE_first_tail_x8_r0_body.s1553.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa161.obj (objOf PRE_first_tail_x8_r0_body.s1554 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1553 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg161_2673467 : PRE_first_tail_x8_r0_body.s1554.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1554 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk161_2673467 : (objOf PRE_first_tail_x8_r0_body.s1554 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm161_2673467 : PRE_first_tail_x8_r0_body.s1553.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa161.obj (objOf PRE_first_tail_x8_r0_body.s1554 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1553 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw161_4910 : (PRE_first_tail_x8_r0_body.s1554.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw161_2673472 : (PRE_first_tail_x8_r0_body.s1554.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw161_2673473 : (PRE_first_tail_x8_r0_body.s1554.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd161 : PRE_first_tail_x8_r0_body.cl161.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr161 : PRE_first_tail_x8_r0_body.st161.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1552.next || PRE_first_tail_x8_r0_body.cl161.contains b) = true
def PRE_first_tail_x8_r0_body.zl161 : List Nat := PRE_first_tail_x8_r0_body.cl161.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE161 : PRE_first_tail_x8_r0_body.zl161.map (fun a => PRE_first_tail_x8_r0_body.s1553.heap.get (PRE_first_tail_x8_r0_body.kappa161.a a)) = PRE_first_tail_x8_r0_body.zl161.map (fun a => (PRE_first_tail_x8_r0_body.s1554.heap.get a).map PRE_first_tail_x8_r0_body.kappa161.hobj)
theorem PRE_first_tail_x8_r0_body.zimg161 : HeapImg PRE_first_tail_x8_r0_body.kappa161 PRE_first_tail_x8_r0_body.s1554 PRE_first_tail_x8_r0_body.s1553 PRE_first_tail_x8_r0_body.zl161 := PRE_first_tail_x8_r0_body.zimgE161
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl161 : PRE_first_tail_x8_r0_body.s1553.ctl = PRE_first_tail_x8_r0_body.kappa161.ctl PRE_first_tail_x8_r0_body.s1554.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack161 : PRE_first_tail_x8_r0_body.s1553.stack = PRE_first_tail_x8_r0_body.s1554.stack.map PRE_first_tail_x8_r0_body.kappa161.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs161 : PRE_first_tail_x8_r0_body.s1553.jobs = PRE_first_tail_x8_r0_body.s1554.jobs.map PRE_first_tail_x8_r0_body.kappa161.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores161 : PRE_first_tail_x8_r0_body.s1553.stores = PRE_first_tail_x8_r0_body.kappa161.stores PRE_first_tail_x8_r0_body.s1554.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots161 : checkRootsSupp PRE_first_tail_x8_r0_body.s1554 6937 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC161 : PRE_first_tail_x8_r0_body.S1552.tab.length + PRE_first_tail_x8_r0_body.cws161.length = 6937
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap161 : PRE_first_tail_x8_r0_body.kappa161 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1552.next 2800930 PRE_first_tail_x8_r0_body.S1552.tab.length PRE_first_tail_x8_r0_body.pl161 (PRE_first_tail_x8_r0_body.nr161.map NumV.ref) PRE_first_tail_x8_r0_body.kd161.big
  PRE_first_tail_x8_r0_body.kd161.region PRE_first_tail_x8_r0_body.kd161.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin161 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1554.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc161 : Conv.jcleanListB (⟨21364, 18466, 2800920, 6937⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1554 PRE_first_tail_x8_r0_body.cl161 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB161 : noBigRootsP (fun i => !Conv.oldBigB (⟨21364, 18466, 2800920, 6937⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1554.trace PRE_first_tail_x8_r0_body.s1554 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm161 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 18466 = true
theorem PRE_first_tail_x8_r0_body.cjcl161 (h : Conv.JClean (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1552) : Conv.JClean (⟨21364, 18466, 2800920, 6937⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1554 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle161)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap161 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd161 a ha)) PRE_first_tail_x8_r0_body.zjc161

end Host.Load.Run.Tpl
end

section -- st161/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st161.bodyLast from PRE_first_tail_x8_r0_body.st161.s1 to PRE_first_tail_x8_r0_body.st161.s2 :
  interpS (step PRE_first_tail_x8_r0_body.st161.F PRE_first_tail_x8_r0_body.st161.s1).run PRE_first_tail_x8_r0_body.st161.S1 = some (PRE_first_tail_x8_r0_body.st161.s2, PRE_first_tail_x8_r0_body.st161.S2)
kernel_rfl PRE_first_tail_x8_r0_body.st161.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st161.s1.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st161.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st161.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st161/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st161.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st161.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st161.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st161.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st161.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st161.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st161.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st161.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st161.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st161.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st161.s0 PRE_first_tail_x8_r0_body.st161.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st161.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st161.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st161.s1 PRE_first_tail_x8_r0_body.st161.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st161/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st161.bodyK0F from PRE_first_tail_x8_r0_body.st161.s0 to PRE_first_tail_x8_r0_body.st161.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st161.F (PRE_first_tail_x8_r0_body.st161.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st161.ks 0).getD 0) PRE_first_tail_x8_r0_body.st161.s0 PRE_first_tail_x8_r0_body.st161.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st161.s1, PRE_first_tail_x8_r0_body.st161.S1)
theorem PRE_first_tail_x8_r0_body.st161.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st161.F (PRE_first_tail_x8_r0_body.st161.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st161.ks 0).getD 0) PRE_first_tail_x8_r0_body.st161.s0 PRE_first_tail_x8_r0_body.st161.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st161.s1, PRE_first_tail_x8_r0_body.st161.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st161.bodyOkLN_ok PRE_first_tail_x8_r0_body.st161.bodyK0F
end Host.Load.Run.Tpl
end

section -- st161/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st161.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st161.F (PRE_first_tail_x8_r0_body.st161.bodyOkL bytes rows) 98 PRE_first_tail_x8_r0_body.st161.s0 PRE_first_tail_x8_r0_body.st161.S0 = some (PRE_first_tail_x8_r0_body.st161.s1, PRE_first_tail_x8_r0_body.st161.S1) :=
  (congrFun (congrFun PRE_first_tail_x8_r0_body.st161.bodyK0 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st161.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st161.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st161.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st161.F (PRE_first_tail_x8_r0_body.st161.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st161.s0
  S0 := PRE_first_tail_x8_r0_body.st161.S0
  s1 := PRE_first_tail_x8_r0_body.st161.s1
  S1 := PRE_first_tail_x8_r0_body.st161.S1
  s2 := PRE_first_tail_x8_r0_body.st161.s2
  S2 := PRE_first_tail_x8_r0_body.st161.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st161.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st161.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st161.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st161.bodyHalt
  last := PRE_first_tail_x8_r0_body.st161.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st161.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC162
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 162 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1571` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa162` into the merged state
`PRE_first_tail_x8_r0_body.s1570`. -/

def PRE_first_tail_x8_r0_body.pl162 : List Nat := [2803503, 2802678, 2803509, 2803505, 2802680, 2803511]
def PRE_first_tail_x8_r0_body.nr162 : List Nat := [7040, 7039, 7015, 7023, 7028, 7033, 7038, 7012, 7013, 7014, 7021, 7022, 7010, 7017, 7018, 7019, 7020, 7016]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd162 : RData :=
  ⟨2802397, 2803546, Stage.setAll PTrie.nil [(2802391, 2803503), (2802392, 2802678), (2802393, 2803509), (2802394, 2803505), (2802395, 2802680), (2802396, 2803511)], Stage.setAll PTrie.nil [(21398, 21424), (21399, 21402), (21400, 21425)],
   21401, 21426, 18512, 18512, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(7010, .ref 7040), (7011, .ref 7039), (7012, .ref 7015), (7013, .ref 7023), (7014, .ref 7028), (7015, .ref 7033), (7016, .ref 7038), (7017, .ref 7012), (7018, .ref 7013), (7019, .ref 7014), (7020, .ref 7021), (7021, .ref 7022), (7022, .ref 7010), (7023, .ref 7017), (7024, .ref 7018), (7025, .ref 7019), (7026, .ref 7020), (7027, .ref 7016)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa162 : Map :=
  Conv.Map.compact 2802391 2803546 7010 PRE_first_tail_x8_r0_body.pl162 (PRE_first_tail_x8_r0_body.nr162.map NumV.ref) PRE_first_tail_x8_r0_body.kd162.big
    PRE_first_tail_x8_r0_body.kd162.region PRE_first_tail_x8_r0_body.kd162.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws162 : List Nat := [3744, 3745, 3746, 3747, 3748, 3749, 3750, 3751, 3752, 3753, 3754, 3755, 3756, 3757, 3758, 3759, 3760, 3761]
noncomputable def PRE_first_tail_x8_r0_body.crs162 : List SymE := PRE_first_tail_x8_r0_body.nr162.map fun r => (nth? PRE_first_tail_x8_r0_body.S1570.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta162 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws162 PRE_first_tail_x8_r0_body.crs162
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB162 : List Nat := [2665, 2672713, 2673467, 2801565, 2802110, 2802366]

kernel_rfl PRE_first_tail_x8_r0_body.ctab162 : PRE_first_tail_x8_r0_body.S1571.tab = PRE_first_tail_x8_r0_body.S1569.tab ++ PRE_first_tail_x8_r0_body.cws162.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace162 : PRE_first_tail_x8_r0_body.s1571.trace = PRE_first_tail_x8_r0_body.s1569.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext162 : PRE_first_tail_x8_r0_body.s1571.next = 2802397
kernel_rfl PRE_first_tail_x8_r0_body.ccounters162 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1571.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1571.ffi).mlx.nnext) = (21401, 18512)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue162 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1570.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1571.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa162.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp162 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1571.ffi).mlx.tokens.all (bSN 7028) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean162 : Conv.cleanListB 21401 131072 (fun r => Nat.ble 85604 r) PRE_first_tail_x8_r0_body.s1571
    (PRE_first_tail_x8_r0_body.wrB162 ++ (List.range 6).map (2802391 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs162 : bigsOutB 21401 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1571.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK162
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl162`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl162 : List Nat := [2665, 2672713, 2673467, 2801565, 2802110, 2802366, 2802391, 2802392, 2802393, 2802394, 2802395, 2802396]
def PRE_first_tail_x8_r0_body.clo162 : List Nat := [21378, 21391, 21397, 21398, 21399, 21400]
def PRE_first_tail_x8_r0_body.cln162 : List Nat := [18485, 18486, 18487, 18488, 18489, 18490, 18491, 18492, 18493, 18494, 18495, 18496, 18497, 18498, 18499, 18500, 18501, 18502, 18503, 18504, 18505, 18506, 18507, 18508, 18509, 18510, 18511]
def PRE_first_tail_x8_r0_body.cli162 : List Nat := [18485, 18486, 18487, 18488, 18489, 18490, 18491, 18492, 18493, 18494, 18495, 18496, 18497, 18498, 18499, 18500, 18501, 18502, 18503, 18504, 18505, 18506, 18507, 18508, 18509, 18510, 18511]
kernel_rfl PRE_first_tail_x8_r0_body.cheap162 : PRE_first_tail_x8_r0_body.s1571.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1569.heap (PRE_first_tail_x8_r0_body.cl162.filterMap fun a => (PRE_first_tail_x8_r0_body.s1571.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe162 : Nat.ble PRE_first_tail_x8_r0_body.s1569.next PRE_first_tail_x8_r0_body.s1571.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP162 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1569 PRE_first_tail_x8_r0_body.s1571 PRE_first_tail_x8_r0_body.cl162 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp162 : Conv.suppListB PRE_first_tail_x8_r0_body.s1571 7028 PRE_first_tail_x8_r0_body.cl162 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound162 : Conv.boundListB PRE_first_tail_x8_r0_body.s1571 PRE_first_tail_x8_r0_body.cl162 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK162 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1571.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln162.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1571.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK162 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1571.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo162.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1571.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK162 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1571.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli162.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1571.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst162 : Conv.sstListB 7028 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1571.ffi).mlx PRE_first_tail_x8_r0_body.cln162 PRE_first_tail_x8_r0_body.clo162 PRE_first_tail_x8_r0_body.cli162 = true

end Host.Load.Run.Tpl
end

section -- SiteCl162
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA162 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1571.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo162.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1571.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd162 : (PRE_first_tail_x8_r0_body.clo162 ++ PRE_first_tail_x8_r0_body.cln162 ++ PRE_first_tail_x8_r0_body.cli162).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle162 : Conv.Cnt.leB (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt) (⟨21401, 18512, 2802397, 7028⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck162 : Conv.ncleanListB (⟨21401, 18512, 2802397, 7028⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1571.ffi).mlx PRE_first_tail_x8_r0_body.clo162 PRE_first_tail_x8_r0_body.cln162 PRE_first_tail_x8_r0_body.cli162 = true
theorem PRE_first_tail_x8_r0_body.cncl162 (h : Conv.NClean (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx) : Conv.NClean (⟨21401, 18512, 2802397, 7028⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1571.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle162 PRE_first_tail_x8_r0_body.ckA162 PRE_first_tail_x8_r0_body.cobjsK162 PRE_first_tail_x8_r0_body.cnodesK162 PRE_first_tail_x8_r0_body.citemsK162 PRE_first_tail_x8_r0_body.cbd162 PRE_first_tail_x8_r0_body.cck162

end Host.Load.Run.Tpl
end

section -- SiteS162
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 162 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc162 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P162 : LoadP := PRE_first_tail_x8_r0_body.Pc162.raise 18512
kernel_rfl PRE_first_tail_x8_r0_body.craise162 : Nat.ble PRE_first_tail_x8_r0_body.Pc162.N0 18512 = true
theorem PRE_first_tail_x8_r0_body.raised162 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc162 PRE_first_tail_x8_r0_body.P162 :=
  .inr ⟨18512, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise162, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_162 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1571.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_162 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1570.ffi)
def PRE_first_tail_x8_r0_body.khinv162 : PTrie Nat := Stage.setAll PTrie.nil [(21424, 21398), (21402, 21399), (21425, 21400)]
def PRE_first_tail_x8_r0_body.kninv162 : PTrie Nat := Stage.setAll PTrie.nil [(18485, 18485), (18486, 18486), (18487, 18487), (18488, 18488), (18489, 18489), (18490, 18490), (18491, 18491), (18492, 18492), (18493, 18493), (18494, 18494), (18495, 18495), (18496, 18496), (18497, 18497), (18498, 18498), (18499, 18499), (18500, 18500), (18501, 18501), (18502, 18502), (18503, 18503), (18504, 18504), (18505, 18505), (18506, 18506), (18507, 18507), (18508, 18508), (18509, 18509), (18510, 18510), (18511, 18511)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS162 : List Nat := [21378, 21391, 21397, 21398, 21399, 21400, 21401, 21402, 21403, 21404, 21405, 21406, 21407, 21408, 21409, 21410, 21411, 21412, 21413, 21414, 21415, 21416, 21417, 21418, 21419, 21420, 21421, 21422, 21423, 21424, 21425]
def PRE_first_tail_x8_r0_body.cnS162 : List Nat := List.range' 18485 27
def PRE_first_tail_x8_r0_body.ciS162 : List Nat := [] ++ List.range' 18485 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0162 : PRE_first_tail_x8_r0_body.kd162.nh0 = PRE_first_tail_x8_r0_body.cx0_162.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1162 : PRE_first_tail_x8_r0_body.kd162.nh1 = PRE_first_tail_x8_r0_body.cx1_162.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0162 : PRE_first_tail_x8_r0_body.kd162.nn0 = PRE_first_tail_x8_r0_body.cx0_162.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1162 : PRE_first_tail_x8_r0_body.kd162.nn1 = PRE_first_tail_x8_r0_body.cx1_162.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo162 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P162.lo && Nat.ble PRE_first_tail_x8_r0_body.P162.lo PRE_first_tail_x8_r0_body.cx0_162.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P162.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P162.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt162 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_162.mlx.next PRE_first_tail_x8_r0_body.cx1_162.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_162.mlx.nnext PRE_first_tail_x8_r0_body.cx1_162.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband162 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P162.NL && Nat.ble PRE_first_tail_x8_r0_body.P162.NL PRE_first_tail_x8_r0_body.P162.N0 && Nat.ble PRE_first_tail_x8_r0_body.P162.N0 PRE_first_tail_x8_r0_body.cx0_162.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow162 : PRE_first_tail_x8_r0_body.kd162.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren162 : checkRenG PRE_first_tail_x8_r0_body.kd162.hnd PRE_first_tail_x8_r0_body.khinv162 (phB PRE_first_tail_x8_r0_body.cx0_162.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband162 : PRE_first_tail_x8_r0_body.kd162.checkBand PRE_first_tail_x8_r0_body.P162.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos162 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd162.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren162 : checkRenG PRE_first_tail_x8_r0_body.kd162.node PRE_first_tail_x8_r0_body.kninv162 (pnB PRE_first_tail_x8_r0_body.cx0_162.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow162 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd162.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P162.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd162.nodeF j) PRE_first_tail_x8_r0_body.cx1_162.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a162 : PRE_first_tail_x8_r0_body.cx0_162.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b162 : PRE_first_tail_x8_r0_body.cx0_162.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1162 : PRE_first_tail_x8_r0_body.cx1_162.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend162 : PRE_first_tail_x8_r0_body.cx1_162.mlx.pending = PRE_first_tail_x8_r0_body.cx0_162.mlx.pending.map PRE_first_tail_x8_r0_body.kappa162.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh162 : PRE_first_tail_x8_r0_body.cx1_162.mlx.errh = PRE_first_tail_x8_r0_body.cx0_162.mlx.errh.map PRE_first_tail_x8_r0_body.kappa162.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles162 : PRE_first_tail_x8_r0_body.cx1_162.mlx.files = PRE_first_tail_x8_r0_body.cx0_162.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch162 : PRE_first_tail_x8_r0_body.cx1_162.mlx.arch = PRE_first_tail_x8_r0_body.cx0_162.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes162 : PRE_first_tail_x8_r0_body.cx1_162.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_162.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired162 : PRE_first_tail_x8_r0_body.cx1_162.mlx.wired = PRE_first_tail_x8_r0_body.cx0_162.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost162 : PRE_first_tail_x8_r0_body.cx1_162.host = PRE_first_tail_x8_r0_body.cx0_162.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd162`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0162 : PRE_first_tail_x8_r0_body.kd162.n0 = 2802397
kernel_rfl PRE_first_tail_x8_r0_body.ckn1162 : PRE_first_tail_x8_r0_body.kd162.n1 = 2803546
kernel_rfl PRE_first_tail_x8_r0_body.ckheap162 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd162.heap).all (fun x => Nat.ble 2802391 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl162 : (List.range 6).all (fun j => decide (PRE_first_tail_x8_r0_body.kd162.heap.get (2802391 + j) = nth? PRE_first_tail_x8_r0_body.pl162 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja162 : Nat.ble 2802391 2802391 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn162 : Nat.ble 7010 7010 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD162 : Nat.ble 2802391 PRE_first_tail_x8_r0_body.kd162.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn162 : Nat.ble 21398 PRE_first_tail_x8_r0_body.kd162.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn162 : Nat.ble 18485 PRE_first_tail_x8_r0_body.kd162.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb162 : Nat.ble 21398 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap162 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd162.heap).all (Nat.ble (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd162 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd162.hnd).all (Nat.ble (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode162 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd162.node).all (Nat.ble (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix162 : Conv.FixOld (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa162 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja162) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn162) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD162) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn162) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn162) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb162) PRE_first_tail_x8_r0_body.fheap162 PRE_first_tail_x8_r0_body.fhnd162 PRE_first_tail_x8_r0_body.fnode162
kernel_rfl PRE_first_tail_x8_r0_body.fcxn162 : (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn162 : (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0162 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_162.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_162.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk162 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd162.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A162 : PRE_first_tail_x8_r0_body.cx1_162.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS162.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_162.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O162 : PRE_first_tail_x8_r0_body.cx1_162.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS162.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_162.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N162 : PRE_first_tail_x8_r0_body.cx1_162.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS162.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_162.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I162 : PRE_first_tail_x8_r0_body.cx1_162.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS162.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_162.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd162 : (PRE_first_tail_x8_r0_body.clo162 ++ PRE_first_tail_x8_r0_body.cln162 ++ PRE_first_tail_x8_r0_body.cli162 ++ PRE_first_tail_x8_r0_body.cwS162 ++ PRE_first_tail_x8_r0_body.cnS162 ++ PRE_first_tail_x8_r0_body.ciS162).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW162 : PRE_first_tail_x8_r0_body.cwS162.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo162.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI162 : PRE_first_tail_x8_r0_body.ciS162.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli162.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN162 : PRE_first_tail_x8_r0_body.cnS162.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF162 : PRE_first_tail_x8_r0_body.cln162.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh162 : PRE_first_tail_x8_r0_body.clo162.all (handleOK PRE_first_tail_x8_r0_body.kappa162 PRE_first_tail_x8_r0_body.P162.lo PRE_first_tail_x8_r0_body.cx0_162.mlx PRE_first_tail_x8_r0_body.cx1_162.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo162 : PRE_first_tail_x8_r0_body.clo162.map (fun h => PRE_first_tail_x8_r0_body.cx1_162.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa162.handle h)) = PRE_first_tail_x8_r0_body.clo162.map (fun h => (PRE_first_tail_x8_r0_body.cx0_162.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa162.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok162 : PRE_first_tail_x8_r0_body.clo162.all (objOK PRE_first_tail_x8_r0_body.kappa162 PRE_first_tail_x8_r0_body.P162.NL PRE_first_tail_x8_r0_body.cx0_162.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd162 : PRE_first_tail_x8_r0_body.cln162.all (nodeOKF PRE_first_tail_x8_r0_body.kappa162 PRE_first_tail_x8_r0_body.P162 PRE_first_tail_x8_r0_body.cx0_162.mlx PRE_first_tail_x8_r0_body.cx1_162.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp162 : ((PRE_first_tail_x8_r0_body.cln162.filter (fullB PRE_first_tail_x8_r0_body.P162))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_162.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa162.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln162.filter (fullB PRE_first_tail_x8_r0_body.P162))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_162.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa162.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI162 : incrB PRE_first_tail_x8_r0_body.kd162.nodeF (List.range' 18485 27) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK162 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd162.node).all (fun k => Nat.ble 18485 k && Nat.blt k 18512) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL162 : (PRE_first_tail_x8_r0_body.cln162.filter (Nat.ble PRE_first_tail_x8_r0_body.P162.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd162.nodeF i) && (Nat.blt i 18512 || Nat.ble PRE_first_tail_x8_r0_body.kd162.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord162 : (PRE_first_tail_x8_r0_body.cln162.filter (Nat.ble PRE_first_tail_x8_r0_body.P162.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd162.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd162.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd162.nodeF j) (PRE_first_tail_x8_r0_body.kd162.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow162 PRE_first_tail_x8_r0_body.cnn1162 PRE_first_tail_x8_r0_body.fnordI162 PRE_first_tail_x8_r0_body.fnordK162 PRE_first_tail_x8_r0_body.fnordL162
kernel_rfl PRE_first_tail_x8_r0_body.fi162 : PRE_first_tail_x8_r0_body.cli162.all (pnB PRE_first_tail_x8_r0_body.cx0_162.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii162 : PRE_first_tail_x8_r0_body.cli162.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_162.mlx.items.get (PRE_first_tail_x8_r0_body.kappa162.node k) = (PRE_first_tail_x8_r0_body.cx0_162.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa162.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot162 (clean : Conv.NClean (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P162.NL) (cl : SSt (· < 7028) PRE_first_tail_x8_r0_body.cx0_162.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P162 7028 PRE_first_tail_x8_r0_body.kappa162 PRE_first_tail_x8_r0_body.kd162 PRE_first_tail_x8_r0_body.khinv162 PRE_first_tail_x8_r0_body.kninv162 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx PRE_first_tail_x8_r0_body.cx0_162.mlx PRE_first_tail_x8_r0_body.cx1_162.mlx (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo162 PRE_first_tail_x8_r0_body.cln162 PRE_first_tail_x8_r0_body.cli162 PRE_first_tail_x8_r0_body.cwS162 PRE_first_tail_x8_r0_body.cnS162 PRE_first_tail_x8_r0_body.ciS162 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0162, PRE_first_tail_x8_r0_body.cnh1162, PRE_first_tail_x8_r0_body.cnn0162, PRE_first_tail_x8_r0_body.cnn1162, PRE_first_tail_x8_r0_body.cplo162, PRE_first_tail_x8_r0_body.ccnt162, PRE_first_tail_x8_r0_body.cnband162, PRE_first_tail_x8_r0_body.chbelow162, PRE_first_tail_x8_r0_body.chren162, PRE_first_tail_x8_r0_body.cband162, PRE_first_tail_x8_r0_body.cnh1pos162, PRE_first_tail_x8_r0_body.cnren162, PRE_first_tail_x8_r0_body.cnlow162, PRE_first_tail_x8_r0_body.cabs0a162, PRE_first_tail_x8_r0_body.cabs0b162, PRE_first_tail_x8_r0_body.ctok1162, PRE_first_tail_x8_r0_body.cpend162, PRE_first_tail_x8_r0_body.cerrh162, PRE_first_tail_x8_r0_body.cfiles162, PRE_first_tail_x8_r0_body.carch162, PRE_first_tail_x8_r0_body.csizes162, PRE_first_tail_x8_r0_body.cwired162, PRE_first_tail_x8_r0_body.cfix162, clean, PRE_first_tail_x8_r0_body.fcxn162, PRE_first_tail_x8_r0_body.fcnn162, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0162, PRE_first_tail_x8_r0_body.fnk162, PRE_first_tail_x8_r0_body.ckA162, PRE_first_tail_x8_r0_body.cobjsK162, PRE_first_tail_x8_r0_body.cnodesK162, PRE_first_tail_x8_r0_body.citemsK162, PRE_first_tail_x8_r0_body.f1A162, PRE_first_tail_x8_r0_body.f1O162, PRE_first_tail_x8_r0_body.f1N162, PRE_first_tail_x8_r0_body.f1I162, PRE_first_tail_x8_r0_body.fbd162, PRE_first_tail_x8_r0_body.fincW162, PRE_first_tail_x8_r0_body.fincI162, PRE_first_tail_x8_r0_body.fincN162, PRE_first_tail_x8_r0_body.flnF162, PRE_first_tail_x8_r0_body.fh162, PRE_first_tail_x8_r0_body.fo162, PRE_first_tail_x8_r0_body.fok162, PRE_first_tail_x8_r0_body.fnd162, PRE_first_tail_x8_r0_body.fp162, PRE_first_tail_x8_r0_body.fnord162, PRE_first_tail_x8_r0_body.fi162, PRE_first_tail_x8_r0_body.fii162⟩
theorem PRE_first_tail_x8_r0_body.cnshift162 (clean : Conv.NClean (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P162.NL) (cl : SSt (· < 7028) PRE_first_tail_x8_r0_body.cx0_162.mlx) : NShift PRE_first_tail_x8_r0_body.P162 7028 PRE_first_tail_x8_r0_body.kappa162 PRE_first_tail_x8_r0_body.cx0_162 PRE_first_tail_x8_r0_body.cx1_162 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot162 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost162 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0162 PRE_first_tail_x8_r0_body.ckn1162 PRE_first_tail_x8_r0_body.ckheap162 PRE_first_tail_x8_r0_body.ckpl162)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_162 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1569.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_162 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1569.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_162 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1569.ffi) = some PRE_first_tail_x8_r0_body.fxC_162
kernel_rfl PRE_first_tail_x8_r0_body.okrC_162 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1569.ffi) = some PRE_first_tail_x8_r0_body.krC_162
noncomputable def PRE_first_tail_x8_r0_body.fx0_162 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1571.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_162 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1571.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_162 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1571.ffi) = some PRE_first_tail_x8_r0_body.fx0_162
kernel_rfl PRE_first_tail_x8_r0_body.okr0_162 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1571.ffi) = some PRE_first_tail_x8_r0_body.kr0_162
noncomputable def PRE_first_tail_x8_r0_body.fx1_162 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1570.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_162 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1570.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_162 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1570.ffi) = some PRE_first_tail_x8_r0_body.fx1_162
kernel_rfl PRE_first_tail_x8_r0_body.okr1_162 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1570.ffi) = some PRE_first_tail_x8_r0_body.kr1_162
kernel_rfl PRE_first_tail_x8_r0_body.ff0162 : PRE_first_tail_x8_r0_body.fx0_162 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_162 (PRE_first_tail_x8_r0_body.clo162.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_162.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1162 : PRE_first_tail_x8_r0_body.fx1_162 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_162 (PRE_first_tail_x8_r0_body.cwS162.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_162.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck162 : freedLB PRE_first_tail_x8_r0_body.kappa162 PRE_first_tail_x8_r0_body.cx0_162.mlx PRE_first_tail_x8_r0_body.fx0_162 PRE_first_tail_x8_r0_body.fx1_162 PRE_first_tail_x8_r0_body.clo162 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0162 : PRE_first_tail_x8_r0_body.kr0_162.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_162.flags (PRE_first_tail_x8_r0_body.clo162.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_162.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0162 : PRE_first_tail_x8_r0_body.kr0_162.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_162.targs (PRE_first_tail_x8_r0_body.clo162.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_162.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1162 : PRE_first_tail_x8_r0_body.kr1_162.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_162.flags (PRE_first_tail_x8_r0_body.cwS162.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_162.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1162 : PRE_first_tail_x8_r0_body.kr1_162.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_162.targs (PRE_first_tail_x8_r0_body.cwS162.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_162.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck162 : krecLB PRE_first_tail_x8_r0_body.kappa162 7028 PRE_first_tail_x8_r0_body.cx0_162.mlx PRE_first_tail_x8_r0_body.kr0_162 PRE_first_tail_x8_r0_body.kr1_162 PRE_first_tail_x8_r0_body.clo162 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn162 : Nat.ble 7010 7028 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge162 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1570.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1571.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR162 : pendRegB PRE_first_tail_x8_r0_body.kappa162 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1571.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe162 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1571.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1570.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift162 (clean : Conv.NClean (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P162.NL) (cl : SSt (· < 7028) PRE_first_tail_x8_r0_body.cx0_162.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_162.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_162.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_162.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1569.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_162.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P162 7028 PRE_first_tail_x8_r0_body.kappa162 PRE_first_tail_x8_r0_body.s1571.ffi PRE_first_tail_x8_r0_body.s1570.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift162 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue162, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp162 t ht),
    PRE_first_tail_x8_r0_body.cbridge162,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1571.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1570.ffi) (PRE_first_tail_x8_r0_body.cfoot162 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_162 PRE_first_tail_x8_r0_body.ofx1_162 hobjC PRE_first_tail_x8_r0_body.ff0162 PRE_first_tail_x8_r0_body.ff1162 PRE_first_tail_x8_r0_body.ffck162,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1571.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1570.ffi) (PRE_first_tail_x8_r0_body.cfoot162 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_162 PRE_first_tail_x8_r0_body.okr1_162 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn162) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0162 PRE_first_tail_x8_r0_body.fkt0162 PRE_first_tail_x8_r0_body.fkf1162 PRE_first_tail_x8_r0_body.fkt1162 PRE_first_tail_x8_r0_body.fkck162,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0162 PRE_first_tail_x8_r0_body.cnh1162 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe162) PRE_first_tail_x8_r0_body.cpendR162⟩

end Host.Load.Run.Tpl
end

section -- st162/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st162 0
host_stream_state PRE_first_tail_x8_r0_body.st162 1
host_stream_state PRE_first_tail_x8_r0_body.st162 2
host_stream_state PRE_first_tail_x8_r0_body.st162 3
host_stream_state PRE_first_tail_x8_r0_body.st162 4
host_stream_state PRE_first_tail_x8_r0_body.st162 5
end Host.Load.Run.Tpl
end

section -- Site162
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 162 of chain `PRE_first_tail_x8_r0_body`: `ssmW__g162__g163` (`recurWindow`), the call state `PRE_first_tail_x8_r0_body.s1569`, the merged state `PRE_first_tail_x8_r0_body.s1570`,
the site template `PRE_first_tail_x8_r0_body.st162` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1571`: the merge.
The footprint's facts are in `SiteF162`, the compaction's in `SiteC162`, `SiteK162`, `SiteNa162`, `SiteNb162`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso162 : PRE_first_tail_x8_r0_body.st162.s0 = { PRE_first_tail_x8_r0_body.s1569 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs162 : List Frame := PRE_first_tail_x8_r0_body.s1569.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_162 : PRE_first_tail_x8_r0_body.S1569.tab.length = 7010
kernel_rfl PRE_first_tail_x8_r0_body.tab0_162 : PRE_first_tail_x8_r0_body.st162.S0.tab = PRE_first_tail_x8_r0_body.S1569.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws162 : List Nat := [3713, 3714, 3715, 3716, 3717, 3718, 3719, 3720, 3721, 3722, 3723, 3724, 3725, 3726, 3727, 3728, 3729, 3730, 3731, 3732, 3733, 3734, 3735, 3736, 3737, 3738, 3739, 3740, 3741, 3742, 3743]
kernel_rfl PRE_first_tail_x8_r0_body.fresh162 : (PRE_first_tail_x8_r0_body.S1569.tab.all fun e => PRE_first_tail_x8_r0_body.ws162.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1569.oracle.all fun q => PRE_first_tail_x8_r0_body.ws162.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab162 : PRE_first_tail_x8_r0_body.S1570.tab = PRE_first_tail_x8_r0_body.S1569.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws162
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen162 : PRE_first_tail_x8_r0_body.st162.S5.tab.length - PRE_first_tail_x8_r0_body.st162.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged162`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap162 : PRE_first_tail_x8_r0_body.s1570.heap = PRE_first_tail_x8_r0_body.st162.s5.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext162 : PRE_first_tail_x8_r0_body.s1570.next = PRE_first_tail_x8_r0_body.st162.s5.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl162 : PRE_first_tail_x8_r0_body.s1570.ctl = PRE_first_tail_x8_r0_body.st162.s5.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack162 : PRE_first_tail_x8_r0_body.s1570.stack = PRE_first_tail_x8_r0_body.st162.s5.stack ++ PRE_first_tail_x8_r0_body.s1569.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs162 : PRE_first_tail_x8_r0_body.s1570.jobs = PRE_first_tail_x8_r0_body.st162.s5.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi162 : PRE_first_tail_x8_r0_body.s1570.ffi = PRE_first_tail_x8_r0_body.st162.s5.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace162 : PRE_first_tail_x8_r0_body.s1570.trace = PRE_first_tail_x8_r0_body.st162.s5.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores162 : PRE_first_tail_x8_r0_body.s1570.stores = PRE_first_tail_x8_r0_body.st162.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD162
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 162 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived162 : PRE_first_tail_x8_r0_body.nr162.map (fun r => nth? PRE_first_tail_x8_r0_body.st162.S5.tab r) =
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
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo162 : PRE_first_tail_x8_r0_body.nr162.all (Nat.ble 7010) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj162 : PRE_first_tail_x8_r0_body.cws162.all (fun c => !PRE_first_tail_x8_r0_body.ws162.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ162 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws162 PRE_first_tail_x8_r0_body.crs162 PRE_first_tail_x8_r0_body.ws162

end Host.Load.Run.Tpl
end

section -- st162/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st162`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st162.wrR : List (Nat × Nat) := [(2672713, 2672714), (2801565, 2801566), (2802110, 2802111), (2802366, 2802367)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st162.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st162.s5.heap PRE_first_tail_x8_r0_body.st162.wrR ++ freshOf PRE_first_tail_x8_r0_body.st162.s5.heap PRE_first_tail_x8_r0_body.st162.s0.next PRE_first_tail_x8_r0_body.st162.s5.next
noncomputable def PRE_first_tail_x8_r0_body.st162.wr : List Nat := PRE_first_tail_x8_r0_body.st162.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st162.heapFoot : PRE_first_tail_x8_r0_body.st162.s5.heap = setAll PRE_first_tail_x8_r0_body.st162.s0.heap PRE_first_tail_x8_r0_body.st162.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st162.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st162.s0.next PRE_first_tail_x8_r0_body.st162.s5.next = true
theorem PRE_first_tail_x8_r0_body.st162.grows : PRE_first_tail_x8_r0_body.st162.s0.next ≤ PRE_first_tail_x8_r0_body.st162.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st162.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st162.wh : List Nat := [21378, 21391, 21397, 21398, 21399, 21400, 21401, 21402, 21403, 21404, 21405, 21406, 21407, 21408, 21409, 21410, 21411, 21412, 21413, 21414, 21415, 21416, 21417, 21418, 21419, 21420, 21421, 21422, 21423, 21424, 21425]
def PRE_first_tail_x8_r0_body.st162.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st162.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st162.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st162.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st162.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st162.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st162.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st162.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st162.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st162.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st162.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st162.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st162.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st162.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st162.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st162.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st162.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st162.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st162.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st162.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st162.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st162.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st162.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st162.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st162.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st162.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st162.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st162.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st162.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st162.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF162
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 162 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB162 : nodupT PRE_first_tail_x8_r0_body.st162.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup162 : PRE_first_tail_x8_r0_body.st162.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB162).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB162 : PRE_first_tail_x8_r0_body.st162.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound162 : ∀ b ∈ PRE_first_tail_x8_r0_body.st162.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB162 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr162 := PRE_first_tail_x8_r0_body.st162.s5.trace.take 120
kernel_rfl PRE_first_tail_x8_r0_body.traceEq162 : PRE_first_tail_x8_r0_body.st162.s5.trace = PRE_first_tail_x8_r0_body.trFr162 ++ PRE_first_tail_x8_r0_body.st162.s0.trace
theorem PRE_first_tail_x8_r0_body.trace162 : ∃ fr, PRE_first_tail_x8_r0_body.st162.s5.trace = fr ++ PRE_first_tail_x8_r0_body.st162.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq162⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide162 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB162 : (PRE_first_tail_x8_r0_body.wide162.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st162.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix162 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide162, WFix Map.id (Present PRE_first_tail_x8_r0_body.st162.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB162 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL162
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 162 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1570`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO162 : PRE_first_tail_x8_r0_body.st162.S0.oracle = PRE_first_tail_x8_r0_body.st162.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B162 : PRE_first_tail_x8_r0_body.st162.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st162.s0.next || (PRE_first_tail_x8_r0_body.st162.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot162 : Conv.StageFoot PRE_first_tail_x8_r0_body.st162.wr PRE_first_tail_x8_r0_body.st162.s0 PRE_first_tail_x8_r0_body.st162.s5 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st162.heapFoot PRE_first_tail_x8_r0_body.wrNodup162 PRE_first_tail_x8_r0_body.wrBound162 PRE_first_tail_x8_r0_body.wr0B162 PRE_first_tail_x8_r0_body.st162.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged162 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st162.F.S → PRE_first_tail_x8_r0_body.st162.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st162.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st162.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs162 PRE_first_tail_x8_r0_body.st162.wr PRE_first_tail_x8_r0_body.s1569 PRE_first_tail_x8_r0_body.st162.s5 PRE_first_tail_x8_r0_body.st162.s0
      PRE_first_tail_x8_r0_body.st162.s5.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st162.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1570 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso162 PRE_first_tail_x8_r0_body.stFoot162 PRE_first_tail_x8_r0_body.wrNodup162 PRE_first_tail_x8_r0_body.wrBound162 PRE_first_tail_x8_r0_body.trace162 PRE_first_tail_x8_r0_body.mheap162
    PRE_first_tail_x8_r0_body.mnext162 PRE_first_tail_x8_r0_body.mctl162 PRE_first_tail_x8_r0_body.mstack162 PRE_first_tail_x8_r0_body.mjobs162 PRE_first_tail_x8_r0_body.mffi162 PRE_first_tail_x8_r0_body.mtrace162 PRE_first_tail_x8_r0_body.mstores162 h

def PRE_first_tail_x8_r0_body.arrEl162_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE162_2665 : arrOf PRE_first_tail_x8_r0_body.s1570 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl162_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA162_2665 : isArrB PRE_first_tail_x8_r0_body.s1570 2665 = true
theorem PRE_first_tail_x8_r0_body.arr162_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1570.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl162_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE162_2665 PRE_first_tail_x8_r0_body.arrA162_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN162_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl162_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR162_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl162_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN162_2665

def PRE_first_tail_x8_r0_body.arrEl162_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE162_2673467 : arrOf PRE_first_tail_x8_r0_body.s1570 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl162_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA162_2673467 : isArrB PRE_first_tail_x8_r0_body.s1570 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr162_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1570.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl162_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE162_2673467 PRE_first_tail_x8_r0_body.arrA162_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN162_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl162_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR162_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl162_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN162_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k162 : isArrB PRE_first_tail_x8_r0_body.s1570 4910 = false
theorem PRE_first_tail_x8_r0_body.keep162 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1570 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k162 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr162_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl162_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ162
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 162 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1569`, the merged
state `PRE_first_tail_x8_r0_body.s1570`, the canonical state `PRE_first_tail_x8_r0_body.s1571`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl162 : PRE_first_tail_x8_r0_body.pl162.all (Nat.ble PRE_first_tail_x8_r0_body.s1569.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd162 : nodupT PRE_first_tail_x8_r0_body.pl162 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1162 : Nat.ble PRE_first_tail_x8_r0_body.s1569.next 2803546 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst162 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1569.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn162 : PRE_first_tail_x8_r0_body.s1571.next = PRE_first_tail_x8_r0_body.s1569.next + PRE_first_tail_x8_r0_body.pl162.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn162 : PRE_first_tail_x8_r0_body.s1570.next = 2803546
kernel_rfl PRE_first_tail_x8_r0_body.zgrow162 : Nat.ble PRE_first_tail_x8_r0_body.s1571.next PRE_first_tail_x8_r0_body.s1570.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh162 : PRE_first_tail_x8_r0_body.S1569.tab.all (fun e => PRE_first_tail_x8_r0_body.cws162.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd162 : nodupT PRE_first_tail_x8_r0_body.cws162 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi162 : PRE_first_tail_x8_r0_body.nr162.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1570.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt162 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1569.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg162_2665 : PRE_first_tail_x8_r0_body.s1571.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1571 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk162_2665 : (objOf PRE_first_tail_x8_r0_body.s1571 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm162_2665 : PRE_first_tail_x8_r0_body.s1570.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa162.obj (objOf PRE_first_tail_x8_r0_body.s1571 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1570 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg162_2673467 : PRE_first_tail_x8_r0_body.s1571.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1571 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk162_2673467 : (objOf PRE_first_tail_x8_r0_body.s1571 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm162_2673467 : PRE_first_tail_x8_r0_body.s1570.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa162.obj (objOf PRE_first_tail_x8_r0_body.s1571 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1570 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw162_4910 : (PRE_first_tail_x8_r0_body.s1571.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw162_2673472 : (PRE_first_tail_x8_r0_body.s1571.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw162_2673473 : (PRE_first_tail_x8_r0_body.s1571.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd162 : PRE_first_tail_x8_r0_body.cl162.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr162 : PRE_first_tail_x8_r0_body.st162.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1569.next || PRE_first_tail_x8_r0_body.cl162.contains b) = true
def PRE_first_tail_x8_r0_body.zl162 : List Nat := PRE_first_tail_x8_r0_body.cl162.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE162 : PRE_first_tail_x8_r0_body.zl162.map (fun a => PRE_first_tail_x8_r0_body.s1570.heap.get (PRE_first_tail_x8_r0_body.kappa162.a a)) = PRE_first_tail_x8_r0_body.zl162.map (fun a => (PRE_first_tail_x8_r0_body.s1571.heap.get a).map PRE_first_tail_x8_r0_body.kappa162.hobj)
theorem PRE_first_tail_x8_r0_body.zimg162 : HeapImg PRE_first_tail_x8_r0_body.kappa162 PRE_first_tail_x8_r0_body.s1571 PRE_first_tail_x8_r0_body.s1570 PRE_first_tail_x8_r0_body.zl162 := PRE_first_tail_x8_r0_body.zimgE162
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl162 : PRE_first_tail_x8_r0_body.s1570.ctl = PRE_first_tail_x8_r0_body.kappa162.ctl PRE_first_tail_x8_r0_body.s1571.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack162 : PRE_first_tail_x8_r0_body.s1570.stack = PRE_first_tail_x8_r0_body.s1571.stack.map PRE_first_tail_x8_r0_body.kappa162.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs162 : PRE_first_tail_x8_r0_body.s1570.jobs = PRE_first_tail_x8_r0_body.s1571.jobs.map PRE_first_tail_x8_r0_body.kappa162.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores162 : PRE_first_tail_x8_r0_body.s1570.stores = PRE_first_tail_x8_r0_body.kappa162.stores PRE_first_tail_x8_r0_body.s1571.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots162 : checkRootsSupp PRE_first_tail_x8_r0_body.s1571 7028 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC162 : PRE_first_tail_x8_r0_body.S1569.tab.length + PRE_first_tail_x8_r0_body.cws162.length = 7028
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap162 : PRE_first_tail_x8_r0_body.kappa162 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1569.next 2803546 PRE_first_tail_x8_r0_body.S1569.tab.length PRE_first_tail_x8_r0_body.pl162 (PRE_first_tail_x8_r0_body.nr162.map NumV.ref) PRE_first_tail_x8_r0_body.kd162.big
  PRE_first_tail_x8_r0_body.kd162.region PRE_first_tail_x8_r0_body.kd162.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin162 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1571.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc162 : Conv.jcleanListB (⟨21401, 18512, 2802397, 7028⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1571 PRE_first_tail_x8_r0_body.cl162 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB162 : noBigRootsP (fun i => !Conv.oldBigB (⟨21401, 18512, 2802397, 7028⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1571.trace PRE_first_tail_x8_r0_body.s1571 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm162 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 18485 = true
theorem PRE_first_tail_x8_r0_body.cjcl162 (h : Conv.JClean (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1569) : Conv.JClean (⟨21401, 18512, 2802397, 7028⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1571 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle162)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap162 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd162 a ha)) PRE_first_tail_x8_r0_body.zjc162

end Host.Load.Run.Tpl
end

section -- st162/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st162.bodyLast from PRE_first_tail_x8_r0_body.st162.s4 to PRE_first_tail_x8_r0_body.st162.s5 :
  interpS (step PRE_first_tail_x8_r0_body.st162.F PRE_first_tail_x8_r0_body.st162.s4).run PRE_first_tail_x8_r0_body.st162.S4 = some (PRE_first_tail_x8_r0_body.st162.s5, PRE_first_tail_x8_r0_body.st162.S5)
kernel_rfl PRE_first_tail_x8_r0_body.st162.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st162.s4.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st162.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st162.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st162/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st162.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st162.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st162.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st162.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st162.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st162.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st162.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st162.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st162.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st162.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st162.s0 PRE_first_tail_x8_r0_body.st162.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st162.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st162.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st162.s4 PRE_first_tail_x8_r0_body.st162.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st162/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st162.bodyK0F from PRE_first_tail_x8_r0_body.st162.s0 to PRE_first_tail_x8_r0_body.st162.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st162.F (PRE_first_tail_x8_r0_body.st162.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st162.ks 0).getD 0) PRE_first_tail_x8_r0_body.st162.s0 PRE_first_tail_x8_r0_body.st162.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st162.s1, PRE_first_tail_x8_r0_body.st162.S1)
theorem PRE_first_tail_x8_r0_body.st162.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st162.F (PRE_first_tail_x8_r0_body.st162.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st162.ks 0).getD 0) PRE_first_tail_x8_r0_body.st162.s0 PRE_first_tail_x8_r0_body.st162.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st162.s1, PRE_first_tail_x8_r0_body.st162.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st162.bodyOkLN_ok PRE_first_tail_x8_r0_body.st162.bodyK0F
end Host.Load.Run.Tpl
end

section -- st162/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st162.bodyK1F from PRE_first_tail_x8_r0_body.st162.s1 to PRE_first_tail_x8_r0_body.st162.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st162.F (PRE_first_tail_x8_r0_body.st162.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st162.ks 1).getD 0) PRE_first_tail_x8_r0_body.st162.s1 PRE_first_tail_x8_r0_body.st162.S1) = fun _ _ => some (PRE_first_tail_x8_r0_body.st162.s2, PRE_first_tail_x8_r0_body.st162.S2)
theorem PRE_first_tail_x8_r0_body.st162.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st162.F (PRE_first_tail_x8_r0_body.st162.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st162.ks 1).getD 0) PRE_first_tail_x8_r0_body.st162.s1 PRE_first_tail_x8_r0_body.st162.S1) = fun _ _ => some (PRE_first_tail_x8_r0_body.st162.s2, PRE_first_tail_x8_r0_body.st162.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st162.bodyOkLN_ok PRE_first_tail_x8_r0_body.st162.bodyK1F
end Host.Load.Run.Tpl
end

section -- st162/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st162.bodyK2F from PRE_first_tail_x8_r0_body.st162.s2 to PRE_first_tail_x8_r0_body.st162.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st162.F (PRE_first_tail_x8_r0_body.st162.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st162.ks 2).getD 0) PRE_first_tail_x8_r0_body.st162.s2 PRE_first_tail_x8_r0_body.st162.S2) = fun _ _ => some (PRE_first_tail_x8_r0_body.st162.s3, PRE_first_tail_x8_r0_body.st162.S3)
theorem PRE_first_tail_x8_r0_body.st162.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st162.F (PRE_first_tail_x8_r0_body.st162.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st162.ks 2).getD 0) PRE_first_tail_x8_r0_body.st162.s2 PRE_first_tail_x8_r0_body.st162.S2) = fun _ _ => some (PRE_first_tail_x8_r0_body.st162.s3, PRE_first_tail_x8_r0_body.st162.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st162.bodyOkLN_ok PRE_first_tail_x8_r0_body.st162.bodyK2F
end Host.Load.Run.Tpl
end

section -- st162/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st162.bodyK3F from PRE_first_tail_x8_r0_body.st162.s3 to PRE_first_tail_x8_r0_body.st162.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st162.F (PRE_first_tail_x8_r0_body.st162.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st162.ks 3).getD 0) PRE_first_tail_x8_r0_body.st162.s3 PRE_first_tail_x8_r0_body.st162.S3) = fun _ _ => some (PRE_first_tail_x8_r0_body.st162.s4, PRE_first_tail_x8_r0_body.st162.S4)
theorem PRE_first_tail_x8_r0_body.st162.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st162.F (PRE_first_tail_x8_r0_body.st162.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st162.ks 3).getD 0) PRE_first_tail_x8_r0_body.st162.s3 PRE_first_tail_x8_r0_body.st162.S3) = fun _ _ => some (PRE_first_tail_x8_r0_body.st162.s4, PRE_first_tail_x8_r0_body.st162.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st162.bodyOkLN_ok PRE_first_tail_x8_r0_body.st162.bodyK3F
end Host.Load.Run.Tpl
end

section -- st162/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st162.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st162.F (PRE_first_tail_x8_r0_body.st162.bodyOkL bytes rows) 11334 PRE_first_tail_x8_r0_body.st162.s0 PRE_first_tail_x8_r0_body.st162.S0 = some (PRE_first_tail_x8_r0_body.st162.s4, PRE_first_tail_x8_r0_body.st162.S4) :=
  runOk_trans PRE_first_tail_x8_r0_body.st162.F (PRE_first_tail_x8_r0_body.st162.bodyOkL bytes rows) ((((nth? PRE_first_tail_x8_r0_body.st162.ks 0).getD 0) + ((nth? PRE_first_tail_x8_r0_body.st162.ks 1).getD 0)) + ((nth? PRE_first_tail_x8_r0_body.st162.ks 2).getD 0)) ((nth? PRE_first_tail_x8_r0_body.st162.ks 3).getD 0) PRE_first_tail_x8_r0_body.st162.s0 PRE_first_tail_x8_r0_body.st162.s3 PRE_first_tail_x8_r0_body.st162.s4 PRE_first_tail_x8_r0_body.st162.S0 PRE_first_tail_x8_r0_body.st162.S3 PRE_first_tail_x8_r0_body.st162.S4 (runOk_trans PRE_first_tail_x8_r0_body.st162.F (PRE_first_tail_x8_r0_body.st162.bodyOkL bytes rows) (((nth? PRE_first_tail_x8_r0_body.st162.ks 0).getD 0) + ((nth? PRE_first_tail_x8_r0_body.st162.ks 1).getD 0)) ((nth? PRE_first_tail_x8_r0_body.st162.ks 2).getD 0) PRE_first_tail_x8_r0_body.st162.s0 PRE_first_tail_x8_r0_body.st162.s2 PRE_first_tail_x8_r0_body.st162.s3 PRE_first_tail_x8_r0_body.st162.S0 PRE_first_tail_x8_r0_body.st162.S2 PRE_first_tail_x8_r0_body.st162.S3 (runOk_trans PRE_first_tail_x8_r0_body.st162.F (PRE_first_tail_x8_r0_body.st162.bodyOkL bytes rows) ((nth? PRE_first_tail_x8_r0_body.st162.ks 0).getD 0) ((nth? PRE_first_tail_x8_r0_body.st162.ks 1).getD 0) PRE_first_tail_x8_r0_body.st162.s0 PRE_first_tail_x8_r0_body.st162.s1 PRE_first_tail_x8_r0_body.st162.s2 PRE_first_tail_x8_r0_body.st162.S0 PRE_first_tail_x8_r0_body.st162.S1 PRE_first_tail_x8_r0_body.st162.S2 ((congrFun (congrFun PRE_first_tail_x8_r0_body.st162.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x8_r0_body.st162.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x8_r0_body.st162.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x8_r0_body.st162.bodyK3 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st162.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st162.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st162.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st162.F (PRE_first_tail_x8_r0_body.st162.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st162.s0
  S0 := PRE_first_tail_x8_r0_body.st162.S0
  s1 := PRE_first_tail_x8_r0_body.st162.s4
  S1 := PRE_first_tail_x8_r0_body.st162.S4
  s2 := PRE_first_tail_x8_r0_body.st162.s5
  S2 := PRE_first_tail_x8_r0_body.st162.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st162.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st162.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st162.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st162.bodyHalt
  last := PRE_first_tail_x8_r0_body.st162.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st162.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC163
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 163 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1579` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa163` into the merged state
`PRE_first_tail_x8_r0_body.s1578`. -/

def PRE_first_tail_x8_r0_body.pl163 : List Nat := []
def PRE_first_tail_x8_r0_body.nr163 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd163 : RData :=
  ⟨2802887, 2802889, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21414, 21414, 18525, 18525, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa163 : Map :=
  Conv.Map.compact 2802887 2802889 7049 PRE_first_tail_x8_r0_body.pl163 (PRE_first_tail_x8_r0_body.nr163.map NumV.ref) PRE_first_tail_x8_r0_body.kd163.big
    PRE_first_tail_x8_r0_body.kd163.region PRE_first_tail_x8_r0_body.kd163.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws163 : List Nat := []
noncomputable def PRE_first_tail_x8_r0_body.crs163 : List SymE := PRE_first_tail_x8_r0_body.nr163.map fun r => (nth? PRE_first_tail_x8_r0_body.S1578.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta163 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws163 PRE_first_tail_x8_r0_body.crs163
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB163 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x8_r0_body.ctab163 : PRE_first_tail_x8_r0_body.S1579.tab = PRE_first_tail_x8_r0_body.S1577.tab ++ PRE_first_tail_x8_r0_body.cws163.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace163 : PRE_first_tail_x8_r0_body.s1579.trace = PRE_first_tail_x8_r0_body.s1577.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext163 : PRE_first_tail_x8_r0_body.s1579.next = 2802887
kernel_rfl PRE_first_tail_x8_r0_body.ccounters163 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1579.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1579.ffi).mlx.nnext) = (21414, 18525)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue163 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1578.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1579.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa163.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp163 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1579.ffi).mlx.tokens.all (bSN 7049) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean163 : Conv.cleanListB 21414 131072 (fun r => Nat.ble 85656 r) PRE_first_tail_x8_r0_body.s1579
    (PRE_first_tail_x8_r0_body.wrB163 ++ (List.range 0).map (2802887 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs163 : bigsOutB 21414 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1579.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK163
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl163`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl163 : List Nat := [2665, 2673467]
def PRE_first_tail_x8_r0_body.clo163 : List Nat := []
def PRE_first_tail_x8_r0_body.cln163 : List Nat := []
def PRE_first_tail_x8_r0_body.cli163 : List Nat := []
kernel_rfl PRE_first_tail_x8_r0_body.cheap163 : PRE_first_tail_x8_r0_body.s1579.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1577.heap (PRE_first_tail_x8_r0_body.cl163.filterMap fun a => (PRE_first_tail_x8_r0_body.s1579.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe163 : Nat.ble PRE_first_tail_x8_r0_body.s1577.next PRE_first_tail_x8_r0_body.s1579.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP163 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1577 PRE_first_tail_x8_r0_body.s1579 PRE_first_tail_x8_r0_body.cl163 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp163 : Conv.suppListB PRE_first_tail_x8_r0_body.s1579 7049 PRE_first_tail_x8_r0_body.cl163 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound163 : Conv.boundListB PRE_first_tail_x8_r0_body.s1579 PRE_first_tail_x8_r0_body.cl163 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK163 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1579.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln163.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1579.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK163 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1579.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo163.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1579.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK163 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1579.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli163.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1579.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst163 : Conv.sstListB 7049 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1579.ffi).mlx PRE_first_tail_x8_r0_body.cln163 PRE_first_tail_x8_r0_body.clo163 PRE_first_tail_x8_r0_body.cli163 = true

end Host.Load.Run.Tpl
end

section -- SiteCl163
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA163 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1579.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo163.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1579.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd163 : (PRE_first_tail_x8_r0_body.clo163 ++ PRE_first_tail_x8_r0_body.cln163 ++ PRE_first_tail_x8_r0_body.cli163).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle163 : Conv.Cnt.leB (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck163 : Conv.ncleanListB (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1579.ffi).mlx PRE_first_tail_x8_r0_body.clo163 PRE_first_tail_x8_r0_body.cln163 PRE_first_tail_x8_r0_body.cli163 = true
theorem PRE_first_tail_x8_r0_body.cncl163 (h : Conv.NClean (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx) : Conv.NClean (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1579.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle163 PRE_first_tail_x8_r0_body.ckA163 PRE_first_tail_x8_r0_body.cobjsK163 PRE_first_tail_x8_r0_body.cnodesK163 PRE_first_tail_x8_r0_body.citemsK163 PRE_first_tail_x8_r0_body.cbd163 PRE_first_tail_x8_r0_body.cck163

end Host.Load.Run.Tpl
end

section -- SiteS163
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 163 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc163 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P163 : LoadP := PRE_first_tail_x8_r0_body.Pc163.raise 18525
kernel_rfl PRE_first_tail_x8_r0_body.craise163 : Nat.ble PRE_first_tail_x8_r0_body.Pc163.N0 18525 = true
theorem PRE_first_tail_x8_r0_body.raised163 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc163 PRE_first_tail_x8_r0_body.P163 :=
  .inr ⟨18525, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise163, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_163 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1579.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_163 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1578.ffi)
def PRE_first_tail_x8_r0_body.khinv163 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x8_r0_body.kninv163 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS163 : List Nat := []
def PRE_first_tail_x8_r0_body.cnS163 : List Nat := List.range' 18525 0
def PRE_first_tail_x8_r0_body.ciS163 : List Nat := [] ++ List.range' 18525 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0163 : PRE_first_tail_x8_r0_body.kd163.nh0 = PRE_first_tail_x8_r0_body.cx0_163.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1163 : PRE_first_tail_x8_r0_body.kd163.nh1 = PRE_first_tail_x8_r0_body.cx1_163.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0163 : PRE_first_tail_x8_r0_body.kd163.nn0 = PRE_first_tail_x8_r0_body.cx0_163.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1163 : PRE_first_tail_x8_r0_body.kd163.nn1 = PRE_first_tail_x8_r0_body.cx1_163.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo163 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P163.lo && Nat.ble PRE_first_tail_x8_r0_body.P163.lo PRE_first_tail_x8_r0_body.cx0_163.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P163.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P163.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt163 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_163.mlx.next PRE_first_tail_x8_r0_body.cx1_163.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_163.mlx.nnext PRE_first_tail_x8_r0_body.cx1_163.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband163 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P163.NL && Nat.ble PRE_first_tail_x8_r0_body.P163.NL PRE_first_tail_x8_r0_body.P163.N0 && Nat.ble PRE_first_tail_x8_r0_body.P163.N0 PRE_first_tail_x8_r0_body.cx0_163.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow163 : PRE_first_tail_x8_r0_body.kd163.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren163 : checkRenG PRE_first_tail_x8_r0_body.kd163.hnd PRE_first_tail_x8_r0_body.khinv163 (phB PRE_first_tail_x8_r0_body.cx0_163.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband163 : PRE_first_tail_x8_r0_body.kd163.checkBand PRE_first_tail_x8_r0_body.P163.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos163 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd163.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren163 : checkRenG PRE_first_tail_x8_r0_body.kd163.node PRE_first_tail_x8_r0_body.kninv163 (pnB PRE_first_tail_x8_r0_body.cx0_163.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow163 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd163.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P163.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd163.nodeF j) PRE_first_tail_x8_r0_body.cx1_163.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a163 : PRE_first_tail_x8_r0_body.cx0_163.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b163 : PRE_first_tail_x8_r0_body.cx0_163.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1163 : PRE_first_tail_x8_r0_body.cx1_163.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend163 : PRE_first_tail_x8_r0_body.cx1_163.mlx.pending = PRE_first_tail_x8_r0_body.cx0_163.mlx.pending.map PRE_first_tail_x8_r0_body.kappa163.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh163 : PRE_first_tail_x8_r0_body.cx1_163.mlx.errh = PRE_first_tail_x8_r0_body.cx0_163.mlx.errh.map PRE_first_tail_x8_r0_body.kappa163.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles163 : PRE_first_tail_x8_r0_body.cx1_163.mlx.files = PRE_first_tail_x8_r0_body.cx0_163.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch163 : PRE_first_tail_x8_r0_body.cx1_163.mlx.arch = PRE_first_tail_x8_r0_body.cx0_163.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes163 : PRE_first_tail_x8_r0_body.cx1_163.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_163.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired163 : PRE_first_tail_x8_r0_body.cx1_163.mlx.wired = PRE_first_tail_x8_r0_body.cx0_163.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost163 : PRE_first_tail_x8_r0_body.cx1_163.host = PRE_first_tail_x8_r0_body.cx0_163.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd163`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0163 : PRE_first_tail_x8_r0_body.kd163.n0 = 2802887
kernel_rfl PRE_first_tail_x8_r0_body.ckn1163 : PRE_first_tail_x8_r0_body.kd163.n1 = 2802889
kernel_rfl PRE_first_tail_x8_r0_body.ckheap163 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd163.heap).all (fun x => Nat.ble 2802887 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl163 : (List.range 0).all (fun j => decide (PRE_first_tail_x8_r0_body.kd163.heap.get (2802887 + j) = nth? PRE_first_tail_x8_r0_body.pl163 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja163 : Nat.ble 2802887 2802887 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn163 : Nat.ble 7049 7049 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD163 : Nat.ble 2802887 PRE_first_tail_x8_r0_body.kd163.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn163 : Nat.ble 21414 PRE_first_tail_x8_r0_body.kd163.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn163 : Nat.ble 18525 PRE_first_tail_x8_r0_body.kd163.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb163 : Nat.ble 21414 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap163 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd163.heap).all (Nat.ble (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd163 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd163.hnd).all (Nat.ble (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode163 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd163.node).all (Nat.ble (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix163 : Conv.FixOld (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa163 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja163) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn163) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD163) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn163) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn163) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb163) PRE_first_tail_x8_r0_body.fheap163 PRE_first_tail_x8_r0_body.fhnd163 PRE_first_tail_x8_r0_body.fnode163
kernel_rfl PRE_first_tail_x8_r0_body.fcxn163 : (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn163 : (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0163 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_163.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_163.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk163 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd163.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A163 : PRE_first_tail_x8_r0_body.cx1_163.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS163.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_163.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O163 : PRE_first_tail_x8_r0_body.cx1_163.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS163.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_163.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N163 : PRE_first_tail_x8_r0_body.cx1_163.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS163.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_163.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I163 : PRE_first_tail_x8_r0_body.cx1_163.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS163.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_163.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd163 : (PRE_first_tail_x8_r0_body.clo163 ++ PRE_first_tail_x8_r0_body.cln163 ++ PRE_first_tail_x8_r0_body.cli163 ++ PRE_first_tail_x8_r0_body.cwS163 ++ PRE_first_tail_x8_r0_body.cnS163 ++ PRE_first_tail_x8_r0_body.ciS163).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW163 : PRE_first_tail_x8_r0_body.cwS163.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo163.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI163 : PRE_first_tail_x8_r0_body.ciS163.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli163.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN163 : PRE_first_tail_x8_r0_body.cnS163.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF163 : PRE_first_tail_x8_r0_body.cln163.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh163 : PRE_first_tail_x8_r0_body.clo163.all (handleOK PRE_first_tail_x8_r0_body.kappa163 PRE_first_tail_x8_r0_body.P163.lo PRE_first_tail_x8_r0_body.cx0_163.mlx PRE_first_tail_x8_r0_body.cx1_163.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo163 : PRE_first_tail_x8_r0_body.clo163.map (fun h => PRE_first_tail_x8_r0_body.cx1_163.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa163.handle h)) = PRE_first_tail_x8_r0_body.clo163.map (fun h => (PRE_first_tail_x8_r0_body.cx0_163.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa163.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok163 : PRE_first_tail_x8_r0_body.clo163.all (objOK PRE_first_tail_x8_r0_body.kappa163 PRE_first_tail_x8_r0_body.P163.NL PRE_first_tail_x8_r0_body.cx0_163.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd163 : PRE_first_tail_x8_r0_body.cln163.all (nodeOKF PRE_first_tail_x8_r0_body.kappa163 PRE_first_tail_x8_r0_body.P163 PRE_first_tail_x8_r0_body.cx0_163.mlx PRE_first_tail_x8_r0_body.cx1_163.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp163 : ((PRE_first_tail_x8_r0_body.cln163.filter (fullB PRE_first_tail_x8_r0_body.P163))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_163.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa163.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln163.filter (fullB PRE_first_tail_x8_r0_body.P163))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_163.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa163.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI163 : incrB PRE_first_tail_x8_r0_body.kd163.nodeF (List.range' 18525 0) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK163 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd163.node).all (fun k => Nat.ble 18525 k && Nat.blt k 18525) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL163 : (PRE_first_tail_x8_r0_body.cln163.filter (Nat.ble PRE_first_tail_x8_r0_body.P163.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd163.nodeF i) && (Nat.blt i 18525 || Nat.ble PRE_first_tail_x8_r0_body.kd163.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord163 : (PRE_first_tail_x8_r0_body.cln163.filter (Nat.ble PRE_first_tail_x8_r0_body.P163.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd163.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd163.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd163.nodeF j) (PRE_first_tail_x8_r0_body.kd163.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow163 PRE_first_tail_x8_r0_body.cnn1163 PRE_first_tail_x8_r0_body.fnordI163 PRE_first_tail_x8_r0_body.fnordK163 PRE_first_tail_x8_r0_body.fnordL163
kernel_rfl PRE_first_tail_x8_r0_body.fi163 : PRE_first_tail_x8_r0_body.cli163.all (pnB PRE_first_tail_x8_r0_body.cx0_163.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii163 : PRE_first_tail_x8_r0_body.cli163.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_163.mlx.items.get (PRE_first_tail_x8_r0_body.kappa163.node k) = (PRE_first_tail_x8_r0_body.cx0_163.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa163.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot163 (clean : Conv.NClean (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P163.NL) (cl : SSt (· < 7049) PRE_first_tail_x8_r0_body.cx0_163.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P163 7049 PRE_first_tail_x8_r0_body.kappa163 PRE_first_tail_x8_r0_body.kd163 PRE_first_tail_x8_r0_body.khinv163 PRE_first_tail_x8_r0_body.kninv163 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx PRE_first_tail_x8_r0_body.cx0_163.mlx PRE_first_tail_x8_r0_body.cx1_163.mlx (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo163 PRE_first_tail_x8_r0_body.cln163 PRE_first_tail_x8_r0_body.cli163 PRE_first_tail_x8_r0_body.cwS163 PRE_first_tail_x8_r0_body.cnS163 PRE_first_tail_x8_r0_body.ciS163 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0163, PRE_first_tail_x8_r0_body.cnh1163, PRE_first_tail_x8_r0_body.cnn0163, PRE_first_tail_x8_r0_body.cnn1163, PRE_first_tail_x8_r0_body.cplo163, PRE_first_tail_x8_r0_body.ccnt163, PRE_first_tail_x8_r0_body.cnband163, PRE_first_tail_x8_r0_body.chbelow163, PRE_first_tail_x8_r0_body.chren163, PRE_first_tail_x8_r0_body.cband163, PRE_first_tail_x8_r0_body.cnh1pos163, PRE_first_tail_x8_r0_body.cnren163, PRE_first_tail_x8_r0_body.cnlow163, PRE_first_tail_x8_r0_body.cabs0a163, PRE_first_tail_x8_r0_body.cabs0b163, PRE_first_tail_x8_r0_body.ctok1163, PRE_first_tail_x8_r0_body.cpend163, PRE_first_tail_x8_r0_body.cerrh163, PRE_first_tail_x8_r0_body.cfiles163, PRE_first_tail_x8_r0_body.carch163, PRE_first_tail_x8_r0_body.csizes163, PRE_first_tail_x8_r0_body.cwired163, PRE_first_tail_x8_r0_body.cfix163, clean, PRE_first_tail_x8_r0_body.fcxn163, PRE_first_tail_x8_r0_body.fcnn163, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0163, PRE_first_tail_x8_r0_body.fnk163, PRE_first_tail_x8_r0_body.ckA163, PRE_first_tail_x8_r0_body.cobjsK163, PRE_first_tail_x8_r0_body.cnodesK163, PRE_first_tail_x8_r0_body.citemsK163, PRE_first_tail_x8_r0_body.f1A163, PRE_first_tail_x8_r0_body.f1O163, PRE_first_tail_x8_r0_body.f1N163, PRE_first_tail_x8_r0_body.f1I163, PRE_first_tail_x8_r0_body.fbd163, PRE_first_tail_x8_r0_body.fincW163, PRE_first_tail_x8_r0_body.fincI163, PRE_first_tail_x8_r0_body.fincN163, PRE_first_tail_x8_r0_body.flnF163, PRE_first_tail_x8_r0_body.fh163, PRE_first_tail_x8_r0_body.fo163, PRE_first_tail_x8_r0_body.fok163, PRE_first_tail_x8_r0_body.fnd163, PRE_first_tail_x8_r0_body.fp163, PRE_first_tail_x8_r0_body.fnord163, PRE_first_tail_x8_r0_body.fi163, PRE_first_tail_x8_r0_body.fii163⟩
theorem PRE_first_tail_x8_r0_body.cnshift163 (clean : Conv.NClean (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P163.NL) (cl : SSt (· < 7049) PRE_first_tail_x8_r0_body.cx0_163.mlx) : NShift PRE_first_tail_x8_r0_body.P163 7049 PRE_first_tail_x8_r0_body.kappa163 PRE_first_tail_x8_r0_body.cx0_163 PRE_first_tail_x8_r0_body.cx1_163 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot163 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost163 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0163 PRE_first_tail_x8_r0_body.ckn1163 PRE_first_tail_x8_r0_body.ckheap163 PRE_first_tail_x8_r0_body.ckpl163)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_163 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1577.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_163 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1577.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_163 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1577.ffi) = some PRE_first_tail_x8_r0_body.fxC_163
kernel_rfl PRE_first_tail_x8_r0_body.okrC_163 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1577.ffi) = some PRE_first_tail_x8_r0_body.krC_163
noncomputable def PRE_first_tail_x8_r0_body.fx0_163 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1579.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_163 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1579.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_163 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1579.ffi) = some PRE_first_tail_x8_r0_body.fx0_163
kernel_rfl PRE_first_tail_x8_r0_body.okr0_163 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1579.ffi) = some PRE_first_tail_x8_r0_body.kr0_163
noncomputable def PRE_first_tail_x8_r0_body.fx1_163 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1578.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_163 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1578.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_163 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1578.ffi) = some PRE_first_tail_x8_r0_body.fx1_163
kernel_rfl PRE_first_tail_x8_r0_body.okr1_163 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1578.ffi) = some PRE_first_tail_x8_r0_body.kr1_163
kernel_rfl PRE_first_tail_x8_r0_body.ff0163 : PRE_first_tail_x8_r0_body.fx0_163 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_163 (PRE_first_tail_x8_r0_body.clo163.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_163.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1163 : PRE_first_tail_x8_r0_body.fx1_163 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_163 (PRE_first_tail_x8_r0_body.cwS163.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_163.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck163 : freedLB PRE_first_tail_x8_r0_body.kappa163 PRE_first_tail_x8_r0_body.cx0_163.mlx PRE_first_tail_x8_r0_body.fx0_163 PRE_first_tail_x8_r0_body.fx1_163 PRE_first_tail_x8_r0_body.clo163 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0163 : PRE_first_tail_x8_r0_body.kr0_163.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_163.flags (PRE_first_tail_x8_r0_body.clo163.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_163.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0163 : PRE_first_tail_x8_r0_body.kr0_163.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_163.targs (PRE_first_tail_x8_r0_body.clo163.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_163.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1163 : PRE_first_tail_x8_r0_body.kr1_163.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_163.flags (PRE_first_tail_x8_r0_body.cwS163.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_163.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1163 : PRE_first_tail_x8_r0_body.kr1_163.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_163.targs (PRE_first_tail_x8_r0_body.cwS163.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_163.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck163 : krecLB PRE_first_tail_x8_r0_body.kappa163 7049 PRE_first_tail_x8_r0_body.cx0_163.mlx PRE_first_tail_x8_r0_body.kr0_163 PRE_first_tail_x8_r0_body.kr1_163 PRE_first_tail_x8_r0_body.clo163 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn163 : Nat.ble 7049 7049 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge163 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1578.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1579.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR163 : pendRegB PRE_first_tail_x8_r0_body.kappa163 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1579.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe163 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1579.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1578.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift163 (clean : Conv.NClean (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P163.NL) (cl : SSt (· < 7049) PRE_first_tail_x8_r0_body.cx0_163.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_163.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_163.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_163.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1577.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_163.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P163 7049 PRE_first_tail_x8_r0_body.kappa163 PRE_first_tail_x8_r0_body.s1579.ffi PRE_first_tail_x8_r0_body.s1578.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift163 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue163, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp163 t ht),
    PRE_first_tail_x8_r0_body.cbridge163,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1579.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1578.ffi) (PRE_first_tail_x8_r0_body.cfoot163 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_163 PRE_first_tail_x8_r0_body.ofx1_163 hobjC PRE_first_tail_x8_r0_body.ff0163 PRE_first_tail_x8_r0_body.ff1163 PRE_first_tail_x8_r0_body.ffck163,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1579.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1578.ffi) (PRE_first_tail_x8_r0_body.cfoot163 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_163 PRE_first_tail_x8_r0_body.okr1_163 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn163) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0163 PRE_first_tail_x8_r0_body.fkt0163 PRE_first_tail_x8_r0_body.fkf1163 PRE_first_tail_x8_r0_body.fkt1163 PRE_first_tail_x8_r0_body.fkck163,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0163 PRE_first_tail_x8_r0_body.cnh1163 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe163) PRE_first_tail_x8_r0_body.cpendR163⟩

end Host.Load.Run.Tpl
end

section -- st163/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st163 0
host_stream_state PRE_first_tail_x8_r0_body.st163 1
host_stream_state PRE_first_tail_x8_r0_body.st163 2
end Host.Load.Run.Tpl
end

section -- Site163
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 163 of chain `PRE_first_tail_x8_r0_body`: `rowBlocks__g163__g164` (`rowBlocks`), the call state `PRE_first_tail_x8_r0_body.s1577`, the merged state `PRE_first_tail_x8_r0_body.s1578`,
the site template `PRE_first_tail_x8_r0_body.st163` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1579`: the merge.
The footprint's facts are in `SiteF163`, the compaction's in `SiteC163`, `SiteK163`, `SiteNa163`, `SiteNb163`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso163 : PRE_first_tail_x8_r0_body.st163.s0 = { PRE_first_tail_x8_r0_body.s1577 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs163 : List Frame := PRE_first_tail_x8_r0_body.s1577.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_163 : PRE_first_tail_x8_r0_body.S1577.tab.length = 7049
kernel_rfl PRE_first_tail_x8_r0_body.tab0_163 : PRE_first_tail_x8_r0_body.st163.S0.tab = PRE_first_tail_x8_r0_body.S1577.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws163 : List Nat := [3762, 3763]
kernel_rfl PRE_first_tail_x8_r0_body.fresh163 : (PRE_first_tail_x8_r0_body.S1577.tab.all fun e => PRE_first_tail_x8_r0_body.ws163.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1577.oracle.all fun q => PRE_first_tail_x8_r0_body.ws163.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab163 : PRE_first_tail_x8_r0_body.S1578.tab = PRE_first_tail_x8_r0_body.S1577.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws163
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen163 : PRE_first_tail_x8_r0_body.st163.S2.tab.length - PRE_first_tail_x8_r0_body.st163.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged163`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap163 : PRE_first_tail_x8_r0_body.s1578.heap = PRE_first_tail_x8_r0_body.st163.s2.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext163 : PRE_first_tail_x8_r0_body.s1578.next = PRE_first_tail_x8_r0_body.st163.s2.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl163 : PRE_first_tail_x8_r0_body.s1578.ctl = PRE_first_tail_x8_r0_body.st163.s2.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack163 : PRE_first_tail_x8_r0_body.s1578.stack = PRE_first_tail_x8_r0_body.st163.s2.stack ++ PRE_first_tail_x8_r0_body.s1577.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs163 : PRE_first_tail_x8_r0_body.s1578.jobs = PRE_first_tail_x8_r0_body.st163.s2.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi163 : PRE_first_tail_x8_r0_body.s1578.ffi = PRE_first_tail_x8_r0_body.st163.s2.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace163 : PRE_first_tail_x8_r0_body.s1578.trace = PRE_first_tail_x8_r0_body.st163.s2.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores163 : PRE_first_tail_x8_r0_body.s1578.stores = PRE_first_tail_x8_r0_body.st163.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD163
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 163 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived163 : PRE_first_tail_x8_r0_body.nr163.map (fun r => nth? PRE_first_tail_x8_r0_body.st163.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo163 : PRE_first_tail_x8_r0_body.nr163.all (Nat.ble 7049) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj163 : PRE_first_tail_x8_r0_body.cws163.all (fun c => !PRE_first_tail_x8_r0_body.ws163.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ163 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws163 PRE_first_tail_x8_r0_body.crs163 PRE_first_tail_x8_r0_body.ws163

end Host.Load.Run.Tpl
end

section -- st163/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st163`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st163.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st163.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st163.s2.heap PRE_first_tail_x8_r0_body.st163.wrR ++ freshOf PRE_first_tail_x8_r0_body.st163.s2.heap PRE_first_tail_x8_r0_body.st163.s0.next PRE_first_tail_x8_r0_body.st163.s2.next
noncomputable def PRE_first_tail_x8_r0_body.st163.wr : List Nat := PRE_first_tail_x8_r0_body.st163.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st163.heapFoot : PRE_first_tail_x8_r0_body.st163.s2.heap = setAll PRE_first_tail_x8_r0_body.st163.s0.heap PRE_first_tail_x8_r0_body.st163.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st163.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st163.s0.next PRE_first_tail_x8_r0_body.st163.s2.next = true
theorem PRE_first_tail_x8_r0_body.st163.grows : PRE_first_tail_x8_r0_body.st163.s0.next ≤ PRE_first_tail_x8_r0_body.st163.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st163.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st163.wh : List Nat := []
def PRE_first_tail_x8_r0_body.st163.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st163.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st163.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st163.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st163.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st163.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st163.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st163.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st163.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st163.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st163.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st163.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st163.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st163.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st163.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st163.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st163.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st163.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st163.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st163.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st163.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st163.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st163.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st163.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st163.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st163.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st163.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st163.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st163.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st163.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF163
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 163 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB163 : nodupT PRE_first_tail_x8_r0_body.st163.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup163 : PRE_first_tail_x8_r0_body.st163.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB163).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB163 : PRE_first_tail_x8_r0_body.st163.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound163 : ∀ b ∈ PRE_first_tail_x8_r0_body.st163.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB163 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr163 := PRE_first_tail_x8_r0_body.st163.s2.trace.take 0
kernel_rfl PRE_first_tail_x8_r0_body.traceEq163 : PRE_first_tail_x8_r0_body.st163.s2.trace = PRE_first_tail_x8_r0_body.trFr163 ++ PRE_first_tail_x8_r0_body.st163.s0.trace
theorem PRE_first_tail_x8_r0_body.trace163 : ∃ fr, PRE_first_tail_x8_r0_body.st163.s2.trace = fr ++ PRE_first_tail_x8_r0_body.st163.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq163⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide163 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB163 : (PRE_first_tail_x8_r0_body.wide163.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st163.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix163 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide163, WFix Map.id (Present PRE_first_tail_x8_r0_body.st163.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB163 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL163
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 163 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1578`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO163 : PRE_first_tail_x8_r0_body.st163.S0.oracle = PRE_first_tail_x8_r0_body.st163.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B163 : PRE_first_tail_x8_r0_body.st163.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st163.s0.next || (PRE_first_tail_x8_r0_body.st163.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot163 : Conv.StageFoot PRE_first_tail_x8_r0_body.st163.wr PRE_first_tail_x8_r0_body.st163.s0 PRE_first_tail_x8_r0_body.st163.s2 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st163.heapFoot PRE_first_tail_x8_r0_body.wrNodup163 PRE_first_tail_x8_r0_body.wrBound163 PRE_first_tail_x8_r0_body.wr0B163 PRE_first_tail_x8_r0_body.st163.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged163 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st163.F.S → PRE_first_tail_x8_r0_body.st163.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st163.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st163.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs163 PRE_first_tail_x8_r0_body.st163.wr PRE_first_tail_x8_r0_body.s1577 PRE_first_tail_x8_r0_body.st163.s2 PRE_first_tail_x8_r0_body.st163.s0
      PRE_first_tail_x8_r0_body.st163.s2.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st163.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1578 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso163 PRE_first_tail_x8_r0_body.stFoot163 PRE_first_tail_x8_r0_body.wrNodup163 PRE_first_tail_x8_r0_body.wrBound163 PRE_first_tail_x8_r0_body.trace163 PRE_first_tail_x8_r0_body.mheap163
    PRE_first_tail_x8_r0_body.mnext163 PRE_first_tail_x8_r0_body.mctl163 PRE_first_tail_x8_r0_body.mstack163 PRE_first_tail_x8_r0_body.mjobs163 PRE_first_tail_x8_r0_body.mffi163 PRE_first_tail_x8_r0_body.mtrace163 PRE_first_tail_x8_r0_body.mstores163 h

def PRE_first_tail_x8_r0_body.arrEl163_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE163_2665 : arrOf PRE_first_tail_x8_r0_body.s1578 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl163_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA163_2665 : isArrB PRE_first_tail_x8_r0_body.s1578 2665 = true
theorem PRE_first_tail_x8_r0_body.arr163_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1578.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl163_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE163_2665 PRE_first_tail_x8_r0_body.arrA163_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN163_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl163_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR163_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl163_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN163_2665

def PRE_first_tail_x8_r0_body.arrEl163_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE163_2673467 : arrOf PRE_first_tail_x8_r0_body.s1578 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl163_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA163_2673467 : isArrB PRE_first_tail_x8_r0_body.s1578 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr163_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1578.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl163_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE163_2673467 PRE_first_tail_x8_r0_body.arrA163_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN163_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl163_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR163_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl163_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN163_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k163 : isArrB PRE_first_tail_x8_r0_body.s1578 4910 = false
theorem PRE_first_tail_x8_r0_body.keep163 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1578 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k163 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr163_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl163_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ163
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 163 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1577`, the merged
state `PRE_first_tail_x8_r0_body.s1578`, the canonical state `PRE_first_tail_x8_r0_body.s1579`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl163 : PRE_first_tail_x8_r0_body.pl163.all (Nat.ble PRE_first_tail_x8_r0_body.s1577.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd163 : nodupT PRE_first_tail_x8_r0_body.pl163 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1163 : Nat.ble PRE_first_tail_x8_r0_body.s1577.next 2802889 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst163 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1577.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn163 : PRE_first_tail_x8_r0_body.s1579.next = PRE_first_tail_x8_r0_body.s1577.next + PRE_first_tail_x8_r0_body.pl163.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn163 : PRE_first_tail_x8_r0_body.s1578.next = 2802889
kernel_rfl PRE_first_tail_x8_r0_body.zgrow163 : Nat.ble PRE_first_tail_x8_r0_body.s1579.next PRE_first_tail_x8_r0_body.s1578.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh163 : PRE_first_tail_x8_r0_body.S1577.tab.all (fun e => PRE_first_tail_x8_r0_body.cws163.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd163 : nodupT PRE_first_tail_x8_r0_body.cws163 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi163 : PRE_first_tail_x8_r0_body.nr163.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1578.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt163 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1577.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg163_2665 : PRE_first_tail_x8_r0_body.s1579.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1579 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk163_2665 : (objOf PRE_first_tail_x8_r0_body.s1579 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm163_2665 : PRE_first_tail_x8_r0_body.s1578.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa163.obj (objOf PRE_first_tail_x8_r0_body.s1579 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1578 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg163_2673467 : PRE_first_tail_x8_r0_body.s1579.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1579 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk163_2673467 : (objOf PRE_first_tail_x8_r0_body.s1579 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm163_2673467 : PRE_first_tail_x8_r0_body.s1578.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa163.obj (objOf PRE_first_tail_x8_r0_body.s1579 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1578 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw163_4910 : (PRE_first_tail_x8_r0_body.s1579.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw163_2673472 : (PRE_first_tail_x8_r0_body.s1579.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw163_2673473 : (PRE_first_tail_x8_r0_body.s1579.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd163 : PRE_first_tail_x8_r0_body.cl163.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr163 : PRE_first_tail_x8_r0_body.st163.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1577.next || PRE_first_tail_x8_r0_body.cl163.contains b) = true
def PRE_first_tail_x8_r0_body.zl163 : List Nat := PRE_first_tail_x8_r0_body.cl163.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE163 : PRE_first_tail_x8_r0_body.zl163.map (fun a => PRE_first_tail_x8_r0_body.s1578.heap.get (PRE_first_tail_x8_r0_body.kappa163.a a)) = PRE_first_tail_x8_r0_body.zl163.map (fun a => (PRE_first_tail_x8_r0_body.s1579.heap.get a).map PRE_first_tail_x8_r0_body.kappa163.hobj)
theorem PRE_first_tail_x8_r0_body.zimg163 : HeapImg PRE_first_tail_x8_r0_body.kappa163 PRE_first_tail_x8_r0_body.s1579 PRE_first_tail_x8_r0_body.s1578 PRE_first_tail_x8_r0_body.zl163 := PRE_first_tail_x8_r0_body.zimgE163
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl163 : PRE_first_tail_x8_r0_body.s1578.ctl = PRE_first_tail_x8_r0_body.kappa163.ctl PRE_first_tail_x8_r0_body.s1579.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack163 : PRE_first_tail_x8_r0_body.s1578.stack = PRE_first_tail_x8_r0_body.s1579.stack.map PRE_first_tail_x8_r0_body.kappa163.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs163 : PRE_first_tail_x8_r0_body.s1578.jobs = PRE_first_tail_x8_r0_body.s1579.jobs.map PRE_first_tail_x8_r0_body.kappa163.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores163 : PRE_first_tail_x8_r0_body.s1578.stores = PRE_first_tail_x8_r0_body.kappa163.stores PRE_first_tail_x8_r0_body.s1579.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots163 : checkRootsSupp PRE_first_tail_x8_r0_body.s1579 7049 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC163 : PRE_first_tail_x8_r0_body.S1577.tab.length + PRE_first_tail_x8_r0_body.cws163.length = 7049
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap163 : PRE_first_tail_x8_r0_body.kappa163 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1577.next 2802889 PRE_first_tail_x8_r0_body.S1577.tab.length PRE_first_tail_x8_r0_body.pl163 (PRE_first_tail_x8_r0_body.nr163.map NumV.ref) PRE_first_tail_x8_r0_body.kd163.big
  PRE_first_tail_x8_r0_body.kd163.region PRE_first_tail_x8_r0_body.kd163.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin163 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1579.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc163 : Conv.jcleanListB (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1579 PRE_first_tail_x8_r0_body.cl163 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB163 : noBigRootsP (fun i => !Conv.oldBigB (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1579.trace PRE_first_tail_x8_r0_body.s1579 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm163 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 18525 = true
theorem PRE_first_tail_x8_r0_body.cjcl163 (h : Conv.JClean (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1577) : Conv.JClean (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1579 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle163)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap163 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd163 a ha)) PRE_first_tail_x8_r0_body.zjc163

end Host.Load.Run.Tpl
end

section -- st163/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st163.bodyLast from PRE_first_tail_x8_r0_body.st163.s1 to PRE_first_tail_x8_r0_body.st163.s2 :
  interpS (step PRE_first_tail_x8_r0_body.st163.F PRE_first_tail_x8_r0_body.st163.s1).run PRE_first_tail_x8_r0_body.st163.S1 = some (PRE_first_tail_x8_r0_body.st163.s2, PRE_first_tail_x8_r0_body.st163.S2)
kernel_rfl PRE_first_tail_x8_r0_body.st163.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st163.s1.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st163.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st163.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st163/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st163.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st163.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st163.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st163.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st163.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st163.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st163.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st163.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st163.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st163.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st163.s0 PRE_first_tail_x8_r0_body.st163.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st163.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st163.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st163.s1 PRE_first_tail_x8_r0_body.st163.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st163/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st163.bodyK0F from PRE_first_tail_x8_r0_body.st163.s0 to PRE_first_tail_x8_r0_body.st163.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st163.F (PRE_first_tail_x8_r0_body.st163.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st163.ks 0).getD 0) PRE_first_tail_x8_r0_body.st163.s0 PRE_first_tail_x8_r0_body.st163.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st163.s1, PRE_first_tail_x8_r0_body.st163.S1)
theorem PRE_first_tail_x8_r0_body.st163.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st163.F (PRE_first_tail_x8_r0_body.st163.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st163.ks 0).getD 0) PRE_first_tail_x8_r0_body.st163.s0 PRE_first_tail_x8_r0_body.st163.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st163.s1, PRE_first_tail_x8_r0_body.st163.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st163.bodyOkLN_ok PRE_first_tail_x8_r0_body.st163.bodyK0F
end Host.Load.Run.Tpl
end

section -- st163/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st163.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st163.F (PRE_first_tail_x8_r0_body.st163.bodyOkL bytes rows) 27 PRE_first_tail_x8_r0_body.st163.s0 PRE_first_tail_x8_r0_body.st163.S0 = some (PRE_first_tail_x8_r0_body.st163.s1, PRE_first_tail_x8_r0_body.st163.S1) :=
  (congrFun (congrFun PRE_first_tail_x8_r0_body.st163.bodyK0 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st163.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st163.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st163.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st163.F (PRE_first_tail_x8_r0_body.st163.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st163.s0
  S0 := PRE_first_tail_x8_r0_body.st163.S0
  s1 := PRE_first_tail_x8_r0_body.st163.s1
  S1 := PRE_first_tail_x8_r0_body.st163.S1
  s2 := PRE_first_tail_x8_r0_body.st163.s2
  S2 := PRE_first_tail_x8_r0_body.st163.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st163.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st163.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st163.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st163.bodyHalt
  last := PRE_first_tail_x8_r0_body.st163.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st163.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC164
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 164 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1583` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa164` into the merged state
`PRE_first_tail_x8_r0_body.s1582`. -/

def PRE_first_tail_x8_r0_body.pl164 : List Nat := [2803195]
def PRE_first_tail_x8_r0_body.nr164 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd164 : RData :=
  ⟨2803176, 2803196, Stage.setAll PTrie.nil [(2803175, 2803195)], Stage.setAll PTrie.nil [],
   21421, 21421, 18529, 18529, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa164 : Map :=
  Conv.Map.compact 2803175 2803196 7066 PRE_first_tail_x8_r0_body.pl164 (PRE_first_tail_x8_r0_body.nr164.map NumV.ref) PRE_first_tail_x8_r0_body.kd164.big
    PRE_first_tail_x8_r0_body.kd164.region PRE_first_tail_x8_r0_body.kd164.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws164 : List Nat := []
noncomputable def PRE_first_tail_x8_r0_body.crs164 : List SymE := PRE_first_tail_x8_r0_body.nr164.map fun r => (nth? PRE_first_tail_x8_r0_body.S1582.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta164 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws164 PRE_first_tail_x8_r0_body.crs164
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB164 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x8_r0_body.ctab164 : PRE_first_tail_x8_r0_body.S1583.tab = PRE_first_tail_x8_r0_body.S1581.tab ++ PRE_first_tail_x8_r0_body.cws164.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace164 : PRE_first_tail_x8_r0_body.s1583.trace = PRE_first_tail_x8_r0_body.s1581.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext164 : PRE_first_tail_x8_r0_body.s1583.next = 2803176
kernel_rfl PRE_first_tail_x8_r0_body.ccounters164 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1583.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1583.ffi).mlx.nnext) = (21421, 18529)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue164 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1582.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1583.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa164.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp164 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1583.ffi).mlx.tokens.all (bSN 7066) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean164 : Conv.cleanListB 21421 131072 (fun r => Nat.ble 85684 r) PRE_first_tail_x8_r0_body.s1583
    (PRE_first_tail_x8_r0_body.wrB164 ++ (List.range 1).map (2803175 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs164 : bigsOutB 21421 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1583.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK164
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl164`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl164 : List Nat := [2665, 2673467, 2803175]
def PRE_first_tail_x8_r0_body.clo164 : List Nat := []
def PRE_first_tail_x8_r0_body.cln164 : List Nat := []
def PRE_first_tail_x8_r0_body.cli164 : List Nat := []
kernel_rfl PRE_first_tail_x8_r0_body.cheap164 : PRE_first_tail_x8_r0_body.s1583.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1581.heap (PRE_first_tail_x8_r0_body.cl164.filterMap fun a => (PRE_first_tail_x8_r0_body.s1583.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe164 : Nat.ble PRE_first_tail_x8_r0_body.s1581.next PRE_first_tail_x8_r0_body.s1583.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP164 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1581 PRE_first_tail_x8_r0_body.s1583 PRE_first_tail_x8_r0_body.cl164 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp164 : Conv.suppListB PRE_first_tail_x8_r0_body.s1583 7066 PRE_first_tail_x8_r0_body.cl164 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound164 : Conv.boundListB PRE_first_tail_x8_r0_body.s1583 PRE_first_tail_x8_r0_body.cl164 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK164 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1583.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln164.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1583.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK164 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1583.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo164.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1583.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK164 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1583.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli164.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1583.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst164 : Conv.sstListB 7066 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1583.ffi).mlx PRE_first_tail_x8_r0_body.cln164 PRE_first_tail_x8_r0_body.clo164 PRE_first_tail_x8_r0_body.cli164 = true

end Host.Load.Run.Tpl
end

section -- SiteCl164
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA164 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1583.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo164.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1583.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd164 : (PRE_first_tail_x8_r0_body.clo164 ++ PRE_first_tail_x8_r0_body.cln164 ++ PRE_first_tail_x8_r0_body.cli164).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle164 : Conv.Cnt.leB (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt) (⟨21421, 18529, 2803176, 7066⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck164 : Conv.ncleanListB (⟨21421, 18529, 2803176, 7066⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1583.ffi).mlx PRE_first_tail_x8_r0_body.clo164 PRE_first_tail_x8_r0_body.cln164 PRE_first_tail_x8_r0_body.cli164 = true
theorem PRE_first_tail_x8_r0_body.cncl164 (h : Conv.NClean (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx) : Conv.NClean (⟨21421, 18529, 2803176, 7066⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1583.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle164 PRE_first_tail_x8_r0_body.ckA164 PRE_first_tail_x8_r0_body.cobjsK164 PRE_first_tail_x8_r0_body.cnodesK164 PRE_first_tail_x8_r0_body.citemsK164 PRE_first_tail_x8_r0_body.cbd164 PRE_first_tail_x8_r0_body.cck164

end Host.Load.Run.Tpl
end

section -- SiteS164
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 164 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc164 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P164 : LoadP := PRE_first_tail_x8_r0_body.Pc164.raise 18529
kernel_rfl PRE_first_tail_x8_r0_body.craise164 : Nat.ble PRE_first_tail_x8_r0_body.Pc164.N0 18529 = true
theorem PRE_first_tail_x8_r0_body.raised164 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc164 PRE_first_tail_x8_r0_body.P164 :=
  .inr ⟨18529, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise164, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_164 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1583.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_164 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1582.ffi)
def PRE_first_tail_x8_r0_body.khinv164 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x8_r0_body.kninv164 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS164 : List Nat := []
def PRE_first_tail_x8_r0_body.cnS164 : List Nat := List.range' 18529 0
def PRE_first_tail_x8_r0_body.ciS164 : List Nat := [] ++ List.range' 18529 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0164 : PRE_first_tail_x8_r0_body.kd164.nh0 = PRE_first_tail_x8_r0_body.cx0_164.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1164 : PRE_first_tail_x8_r0_body.kd164.nh1 = PRE_first_tail_x8_r0_body.cx1_164.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0164 : PRE_first_tail_x8_r0_body.kd164.nn0 = PRE_first_tail_x8_r0_body.cx0_164.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1164 : PRE_first_tail_x8_r0_body.kd164.nn1 = PRE_first_tail_x8_r0_body.cx1_164.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo164 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P164.lo && Nat.ble PRE_first_tail_x8_r0_body.P164.lo PRE_first_tail_x8_r0_body.cx0_164.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P164.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P164.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt164 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_164.mlx.next PRE_first_tail_x8_r0_body.cx1_164.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_164.mlx.nnext PRE_first_tail_x8_r0_body.cx1_164.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband164 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P164.NL && Nat.ble PRE_first_tail_x8_r0_body.P164.NL PRE_first_tail_x8_r0_body.P164.N0 && Nat.ble PRE_first_tail_x8_r0_body.P164.N0 PRE_first_tail_x8_r0_body.cx0_164.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow164 : PRE_first_tail_x8_r0_body.kd164.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren164 : checkRenG PRE_first_tail_x8_r0_body.kd164.hnd PRE_first_tail_x8_r0_body.khinv164 (phB PRE_first_tail_x8_r0_body.cx0_164.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband164 : PRE_first_tail_x8_r0_body.kd164.checkBand PRE_first_tail_x8_r0_body.P164.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos164 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd164.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren164 : checkRenG PRE_first_tail_x8_r0_body.kd164.node PRE_first_tail_x8_r0_body.kninv164 (pnB PRE_first_tail_x8_r0_body.cx0_164.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow164 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd164.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P164.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd164.nodeF j) PRE_first_tail_x8_r0_body.cx1_164.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a164 : PRE_first_tail_x8_r0_body.cx0_164.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b164 : PRE_first_tail_x8_r0_body.cx0_164.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1164 : PRE_first_tail_x8_r0_body.cx1_164.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend164 : PRE_first_tail_x8_r0_body.cx1_164.mlx.pending = PRE_first_tail_x8_r0_body.cx0_164.mlx.pending.map PRE_first_tail_x8_r0_body.kappa164.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh164 : PRE_first_tail_x8_r0_body.cx1_164.mlx.errh = PRE_first_tail_x8_r0_body.cx0_164.mlx.errh.map PRE_first_tail_x8_r0_body.kappa164.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles164 : PRE_first_tail_x8_r0_body.cx1_164.mlx.files = PRE_first_tail_x8_r0_body.cx0_164.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch164 : PRE_first_tail_x8_r0_body.cx1_164.mlx.arch = PRE_first_tail_x8_r0_body.cx0_164.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes164 : PRE_first_tail_x8_r0_body.cx1_164.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_164.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired164 : PRE_first_tail_x8_r0_body.cx1_164.mlx.wired = PRE_first_tail_x8_r0_body.cx0_164.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost164 : PRE_first_tail_x8_r0_body.cx1_164.host = PRE_first_tail_x8_r0_body.cx0_164.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd164`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0164 : PRE_first_tail_x8_r0_body.kd164.n0 = 2803176
kernel_rfl PRE_first_tail_x8_r0_body.ckn1164 : PRE_first_tail_x8_r0_body.kd164.n1 = 2803196
kernel_rfl PRE_first_tail_x8_r0_body.ckheap164 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd164.heap).all (fun x => Nat.ble 2803175 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl164 : (List.range 1).all (fun j => decide (PRE_first_tail_x8_r0_body.kd164.heap.get (2803175 + j) = nth? PRE_first_tail_x8_r0_body.pl164 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja164 : Nat.ble 2803175 2803175 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn164 : Nat.ble 7066 7066 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD164 : Nat.ble 2803175 PRE_first_tail_x8_r0_body.kd164.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn164 : Nat.ble 21421 PRE_first_tail_x8_r0_body.kd164.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn164 : Nat.ble 18529 PRE_first_tail_x8_r0_body.kd164.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb164 : Nat.ble 21421 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap164 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd164.heap).all (Nat.ble (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd164 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd164.hnd).all (Nat.ble (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode164 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd164.node).all (Nat.ble (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix164 : Conv.FixOld (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa164 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja164) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn164) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD164) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn164) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn164) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb164) PRE_first_tail_x8_r0_body.fheap164 PRE_first_tail_x8_r0_body.fhnd164 PRE_first_tail_x8_r0_body.fnode164
kernel_rfl PRE_first_tail_x8_r0_body.fcxn164 : (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn164 : (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0164 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_164.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_164.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk164 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd164.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A164 : PRE_first_tail_x8_r0_body.cx1_164.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS164.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_164.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O164 : PRE_first_tail_x8_r0_body.cx1_164.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS164.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_164.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N164 : PRE_first_tail_x8_r0_body.cx1_164.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS164.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_164.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I164 : PRE_first_tail_x8_r0_body.cx1_164.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS164.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_164.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd164 : (PRE_first_tail_x8_r0_body.clo164 ++ PRE_first_tail_x8_r0_body.cln164 ++ PRE_first_tail_x8_r0_body.cli164 ++ PRE_first_tail_x8_r0_body.cwS164 ++ PRE_first_tail_x8_r0_body.cnS164 ++ PRE_first_tail_x8_r0_body.ciS164).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW164 : PRE_first_tail_x8_r0_body.cwS164.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo164.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI164 : PRE_first_tail_x8_r0_body.ciS164.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli164.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN164 : PRE_first_tail_x8_r0_body.cnS164.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF164 : PRE_first_tail_x8_r0_body.cln164.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh164 : PRE_first_tail_x8_r0_body.clo164.all (handleOK PRE_first_tail_x8_r0_body.kappa164 PRE_first_tail_x8_r0_body.P164.lo PRE_first_tail_x8_r0_body.cx0_164.mlx PRE_first_tail_x8_r0_body.cx1_164.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo164 : PRE_first_tail_x8_r0_body.clo164.map (fun h => PRE_first_tail_x8_r0_body.cx1_164.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa164.handle h)) = PRE_first_tail_x8_r0_body.clo164.map (fun h => (PRE_first_tail_x8_r0_body.cx0_164.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa164.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok164 : PRE_first_tail_x8_r0_body.clo164.all (objOK PRE_first_tail_x8_r0_body.kappa164 PRE_first_tail_x8_r0_body.P164.NL PRE_first_tail_x8_r0_body.cx0_164.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd164 : PRE_first_tail_x8_r0_body.cln164.all (nodeOKF PRE_first_tail_x8_r0_body.kappa164 PRE_first_tail_x8_r0_body.P164 PRE_first_tail_x8_r0_body.cx0_164.mlx PRE_first_tail_x8_r0_body.cx1_164.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp164 : ((PRE_first_tail_x8_r0_body.cln164.filter (fullB PRE_first_tail_x8_r0_body.P164))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_164.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa164.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln164.filter (fullB PRE_first_tail_x8_r0_body.P164))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_164.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa164.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI164 : incrB PRE_first_tail_x8_r0_body.kd164.nodeF (List.range' 18529 0) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK164 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd164.node).all (fun k => Nat.ble 18529 k && Nat.blt k 18529) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL164 : (PRE_first_tail_x8_r0_body.cln164.filter (Nat.ble PRE_first_tail_x8_r0_body.P164.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd164.nodeF i) && (Nat.blt i 18529 || Nat.ble PRE_first_tail_x8_r0_body.kd164.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord164 : (PRE_first_tail_x8_r0_body.cln164.filter (Nat.ble PRE_first_tail_x8_r0_body.P164.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd164.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd164.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd164.nodeF j) (PRE_first_tail_x8_r0_body.kd164.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow164 PRE_first_tail_x8_r0_body.cnn1164 PRE_first_tail_x8_r0_body.fnordI164 PRE_first_tail_x8_r0_body.fnordK164 PRE_first_tail_x8_r0_body.fnordL164
kernel_rfl PRE_first_tail_x8_r0_body.fi164 : PRE_first_tail_x8_r0_body.cli164.all (pnB PRE_first_tail_x8_r0_body.cx0_164.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii164 : PRE_first_tail_x8_r0_body.cli164.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_164.mlx.items.get (PRE_first_tail_x8_r0_body.kappa164.node k) = (PRE_first_tail_x8_r0_body.cx0_164.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa164.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot164 (clean : Conv.NClean (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P164.NL) (cl : SSt (· < 7066) PRE_first_tail_x8_r0_body.cx0_164.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P164 7066 PRE_first_tail_x8_r0_body.kappa164 PRE_first_tail_x8_r0_body.kd164 PRE_first_tail_x8_r0_body.khinv164 PRE_first_tail_x8_r0_body.kninv164 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx PRE_first_tail_x8_r0_body.cx0_164.mlx PRE_first_tail_x8_r0_body.cx1_164.mlx (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo164 PRE_first_tail_x8_r0_body.cln164 PRE_first_tail_x8_r0_body.cli164 PRE_first_tail_x8_r0_body.cwS164 PRE_first_tail_x8_r0_body.cnS164 PRE_first_tail_x8_r0_body.ciS164 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0164, PRE_first_tail_x8_r0_body.cnh1164, PRE_first_tail_x8_r0_body.cnn0164, PRE_first_tail_x8_r0_body.cnn1164, PRE_first_tail_x8_r0_body.cplo164, PRE_first_tail_x8_r0_body.ccnt164, PRE_first_tail_x8_r0_body.cnband164, PRE_first_tail_x8_r0_body.chbelow164, PRE_first_tail_x8_r0_body.chren164, PRE_first_tail_x8_r0_body.cband164, PRE_first_tail_x8_r0_body.cnh1pos164, PRE_first_tail_x8_r0_body.cnren164, PRE_first_tail_x8_r0_body.cnlow164, PRE_first_tail_x8_r0_body.cabs0a164, PRE_first_tail_x8_r0_body.cabs0b164, PRE_first_tail_x8_r0_body.ctok1164, PRE_first_tail_x8_r0_body.cpend164, PRE_first_tail_x8_r0_body.cerrh164, PRE_first_tail_x8_r0_body.cfiles164, PRE_first_tail_x8_r0_body.carch164, PRE_first_tail_x8_r0_body.csizes164, PRE_first_tail_x8_r0_body.cwired164, PRE_first_tail_x8_r0_body.cfix164, clean, PRE_first_tail_x8_r0_body.fcxn164, PRE_first_tail_x8_r0_body.fcnn164, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0164, PRE_first_tail_x8_r0_body.fnk164, PRE_first_tail_x8_r0_body.ckA164, PRE_first_tail_x8_r0_body.cobjsK164, PRE_first_tail_x8_r0_body.cnodesK164, PRE_first_tail_x8_r0_body.citemsK164, PRE_first_tail_x8_r0_body.f1A164, PRE_first_tail_x8_r0_body.f1O164, PRE_first_tail_x8_r0_body.f1N164, PRE_first_tail_x8_r0_body.f1I164, PRE_first_tail_x8_r0_body.fbd164, PRE_first_tail_x8_r0_body.fincW164, PRE_first_tail_x8_r0_body.fincI164, PRE_first_tail_x8_r0_body.fincN164, PRE_first_tail_x8_r0_body.flnF164, PRE_first_tail_x8_r0_body.fh164, PRE_first_tail_x8_r0_body.fo164, PRE_first_tail_x8_r0_body.fok164, PRE_first_tail_x8_r0_body.fnd164, PRE_first_tail_x8_r0_body.fp164, PRE_first_tail_x8_r0_body.fnord164, PRE_first_tail_x8_r0_body.fi164, PRE_first_tail_x8_r0_body.fii164⟩
theorem PRE_first_tail_x8_r0_body.cnshift164 (clean : Conv.NClean (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P164.NL) (cl : SSt (· < 7066) PRE_first_tail_x8_r0_body.cx0_164.mlx) : NShift PRE_first_tail_x8_r0_body.P164 7066 PRE_first_tail_x8_r0_body.kappa164 PRE_first_tail_x8_r0_body.cx0_164 PRE_first_tail_x8_r0_body.cx1_164 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot164 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost164 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0164 PRE_first_tail_x8_r0_body.ckn1164 PRE_first_tail_x8_r0_body.ckheap164 PRE_first_tail_x8_r0_body.ckpl164)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_164 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1581.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_164 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1581.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_164 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1581.ffi) = some PRE_first_tail_x8_r0_body.fxC_164
kernel_rfl PRE_first_tail_x8_r0_body.okrC_164 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1581.ffi) = some PRE_first_tail_x8_r0_body.krC_164
noncomputable def PRE_first_tail_x8_r0_body.fx0_164 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1583.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_164 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1583.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_164 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1583.ffi) = some PRE_first_tail_x8_r0_body.fx0_164
kernel_rfl PRE_first_tail_x8_r0_body.okr0_164 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1583.ffi) = some PRE_first_tail_x8_r0_body.kr0_164
noncomputable def PRE_first_tail_x8_r0_body.fx1_164 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1582.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_164 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1582.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_164 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1582.ffi) = some PRE_first_tail_x8_r0_body.fx1_164
kernel_rfl PRE_first_tail_x8_r0_body.okr1_164 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1582.ffi) = some PRE_first_tail_x8_r0_body.kr1_164
kernel_rfl PRE_first_tail_x8_r0_body.ff0164 : PRE_first_tail_x8_r0_body.fx0_164 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_164 (PRE_first_tail_x8_r0_body.clo164.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_164.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1164 : PRE_first_tail_x8_r0_body.fx1_164 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_164 (PRE_first_tail_x8_r0_body.cwS164.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_164.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck164 : freedLB PRE_first_tail_x8_r0_body.kappa164 PRE_first_tail_x8_r0_body.cx0_164.mlx PRE_first_tail_x8_r0_body.fx0_164 PRE_first_tail_x8_r0_body.fx1_164 PRE_first_tail_x8_r0_body.clo164 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0164 : PRE_first_tail_x8_r0_body.kr0_164.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_164.flags (PRE_first_tail_x8_r0_body.clo164.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_164.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0164 : PRE_first_tail_x8_r0_body.kr0_164.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_164.targs (PRE_first_tail_x8_r0_body.clo164.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_164.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1164 : PRE_first_tail_x8_r0_body.kr1_164.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_164.flags (PRE_first_tail_x8_r0_body.cwS164.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_164.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1164 : PRE_first_tail_x8_r0_body.kr1_164.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_164.targs (PRE_first_tail_x8_r0_body.cwS164.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_164.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck164 : krecLB PRE_first_tail_x8_r0_body.kappa164 7066 PRE_first_tail_x8_r0_body.cx0_164.mlx PRE_first_tail_x8_r0_body.kr0_164 PRE_first_tail_x8_r0_body.kr1_164 PRE_first_tail_x8_r0_body.clo164 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn164 : Nat.ble 7066 7066 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge164 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1582.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1583.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR164 : pendRegB PRE_first_tail_x8_r0_body.kappa164 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1583.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe164 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1583.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1582.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift164 (clean : Conv.NClean (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P164.NL) (cl : SSt (· < 7066) PRE_first_tail_x8_r0_body.cx0_164.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_164.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_164.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_164.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1581.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_164.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P164 7066 PRE_first_tail_x8_r0_body.kappa164 PRE_first_tail_x8_r0_body.s1583.ffi PRE_first_tail_x8_r0_body.s1582.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift164 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue164, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp164 t ht),
    PRE_first_tail_x8_r0_body.cbridge164,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1583.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1582.ffi) (PRE_first_tail_x8_r0_body.cfoot164 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_164 PRE_first_tail_x8_r0_body.ofx1_164 hobjC PRE_first_tail_x8_r0_body.ff0164 PRE_first_tail_x8_r0_body.ff1164 PRE_first_tail_x8_r0_body.ffck164,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1583.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1582.ffi) (PRE_first_tail_x8_r0_body.cfoot164 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_164 PRE_first_tail_x8_r0_body.okr1_164 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn164) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0164 PRE_first_tail_x8_r0_body.fkt0164 PRE_first_tail_x8_r0_body.fkf1164 PRE_first_tail_x8_r0_body.fkt1164 PRE_first_tail_x8_r0_body.fkck164,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0164 PRE_first_tail_x8_r0_body.cnh1164 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe164) PRE_first_tail_x8_r0_body.cpendR164⟩

end Host.Load.Run.Tpl
end

section -- st164/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st164 0
host_stream_state PRE_first_tail_x8_r0_body.st164 1
host_stream_state PRE_first_tail_x8_r0_body.st164 2
end Host.Load.Run.Tpl
end

section -- Site164
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 164 of chain `PRE_first_tail_x8_r0_body`: `plan__g164__g165` (`plan`), the call state `PRE_first_tail_x8_r0_body.s1581`, the merged state `PRE_first_tail_x8_r0_body.s1582`,
the site template `PRE_first_tail_x8_r0_body.st164` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1583`: the merge.
The footprint's facts are in `SiteF164`, the compaction's in `SiteC164`, `SiteK164`, `SiteNa164`, `SiteNb164`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso164 : PRE_first_tail_x8_r0_body.st164.s0 = { PRE_first_tail_x8_r0_body.s1581 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs164 : List Frame := PRE_first_tail_x8_r0_body.s1581.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_164 : PRE_first_tail_x8_r0_body.S1581.tab.length = 7066
kernel_rfl PRE_first_tail_x8_r0_body.tab0_164 : PRE_first_tail_x8_r0_body.st164.S0.tab = PRE_first_tail_x8_r0_body.S1581.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws164 : List Nat := [3764, 3765, 3766, 3767, 3768, 3769, 3770, 3771, 3772]
kernel_rfl PRE_first_tail_x8_r0_body.fresh164 : (PRE_first_tail_x8_r0_body.S1581.tab.all fun e => PRE_first_tail_x8_r0_body.ws164.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1581.oracle.all fun q => PRE_first_tail_x8_r0_body.ws164.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab164 : PRE_first_tail_x8_r0_body.S1582.tab = PRE_first_tail_x8_r0_body.S1581.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws164
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen164 : PRE_first_tail_x8_r0_body.st164.S2.tab.length - PRE_first_tail_x8_r0_body.st164.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged164`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap164 : PRE_first_tail_x8_r0_body.s1582.heap = PRE_first_tail_x8_r0_body.st164.s2.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext164 : PRE_first_tail_x8_r0_body.s1582.next = PRE_first_tail_x8_r0_body.st164.s2.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl164 : PRE_first_tail_x8_r0_body.s1582.ctl = PRE_first_tail_x8_r0_body.st164.s2.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack164 : PRE_first_tail_x8_r0_body.s1582.stack = PRE_first_tail_x8_r0_body.st164.s2.stack ++ PRE_first_tail_x8_r0_body.s1581.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs164 : PRE_first_tail_x8_r0_body.s1582.jobs = PRE_first_tail_x8_r0_body.st164.s2.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi164 : PRE_first_tail_x8_r0_body.s1582.ffi = PRE_first_tail_x8_r0_body.st164.s2.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace164 : PRE_first_tail_x8_r0_body.s1582.trace = PRE_first_tail_x8_r0_body.st164.s2.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores164 : PRE_first_tail_x8_r0_body.s1582.stores = PRE_first_tail_x8_r0_body.st164.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD164
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 164 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived164 : PRE_first_tail_x8_r0_body.nr164.map (fun r => nth? PRE_first_tail_x8_r0_body.st164.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo164 : PRE_first_tail_x8_r0_body.nr164.all (Nat.ble 7066) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj164 : PRE_first_tail_x8_r0_body.cws164.all (fun c => !PRE_first_tail_x8_r0_body.ws164.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ164 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws164 PRE_first_tail_x8_r0_body.crs164 PRE_first_tail_x8_r0_body.ws164

end Host.Load.Run.Tpl
end

section -- st164/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st164`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st164.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st164.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st164.s2.heap PRE_first_tail_x8_r0_body.st164.wrR ++ freshOf PRE_first_tail_x8_r0_body.st164.s2.heap PRE_first_tail_x8_r0_body.st164.s0.next PRE_first_tail_x8_r0_body.st164.s2.next
noncomputable def PRE_first_tail_x8_r0_body.st164.wr : List Nat := PRE_first_tail_x8_r0_body.st164.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st164.heapFoot : PRE_first_tail_x8_r0_body.st164.s2.heap = setAll PRE_first_tail_x8_r0_body.st164.s0.heap PRE_first_tail_x8_r0_body.st164.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st164.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st164.s0.next PRE_first_tail_x8_r0_body.st164.s2.next = true
theorem PRE_first_tail_x8_r0_body.st164.grows : PRE_first_tail_x8_r0_body.st164.s0.next ≤ PRE_first_tail_x8_r0_body.st164.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st164.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st164.wh : List Nat := []
def PRE_first_tail_x8_r0_body.st164.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st164.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st164.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st164.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st164.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st164.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st164.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st164.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st164.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st164.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st164.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st164.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st164.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st164.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st164.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st164.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st164.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st164.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st164.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st164.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st164.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st164.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st164.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st164.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st164.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st164.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st164.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st164.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st164.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st164.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF164
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 164 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB164 : nodupT PRE_first_tail_x8_r0_body.st164.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup164 : PRE_first_tail_x8_r0_body.st164.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB164).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB164 : PRE_first_tail_x8_r0_body.st164.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound164 : ∀ b ∈ PRE_first_tail_x8_r0_body.st164.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB164 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr164 := PRE_first_tail_x8_r0_body.st164.s2.trace.take 0
kernel_rfl PRE_first_tail_x8_r0_body.traceEq164 : PRE_first_tail_x8_r0_body.st164.s2.trace = PRE_first_tail_x8_r0_body.trFr164 ++ PRE_first_tail_x8_r0_body.st164.s0.trace
theorem PRE_first_tail_x8_r0_body.trace164 : ∃ fr, PRE_first_tail_x8_r0_body.st164.s2.trace = fr ++ PRE_first_tail_x8_r0_body.st164.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq164⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide164 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB164 : (PRE_first_tail_x8_r0_body.wide164.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st164.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix164 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide164, WFix Map.id (Present PRE_first_tail_x8_r0_body.st164.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB164 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL164
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 164 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1582`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO164 : PRE_first_tail_x8_r0_body.st164.S0.oracle = PRE_first_tail_x8_r0_body.st164.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B164 : PRE_first_tail_x8_r0_body.st164.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st164.s0.next || (PRE_first_tail_x8_r0_body.st164.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot164 : Conv.StageFoot PRE_first_tail_x8_r0_body.st164.wr PRE_first_tail_x8_r0_body.st164.s0 PRE_first_tail_x8_r0_body.st164.s2 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st164.heapFoot PRE_first_tail_x8_r0_body.wrNodup164 PRE_first_tail_x8_r0_body.wrBound164 PRE_first_tail_x8_r0_body.wr0B164 PRE_first_tail_x8_r0_body.st164.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged164 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st164.F.S → PRE_first_tail_x8_r0_body.st164.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st164.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st164.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs164 PRE_first_tail_x8_r0_body.st164.wr PRE_first_tail_x8_r0_body.s1581 PRE_first_tail_x8_r0_body.st164.s2 PRE_first_tail_x8_r0_body.st164.s0
      PRE_first_tail_x8_r0_body.st164.s2.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st164.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1582 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso164 PRE_first_tail_x8_r0_body.stFoot164 PRE_first_tail_x8_r0_body.wrNodup164 PRE_first_tail_x8_r0_body.wrBound164 PRE_first_tail_x8_r0_body.trace164 PRE_first_tail_x8_r0_body.mheap164
    PRE_first_tail_x8_r0_body.mnext164 PRE_first_tail_x8_r0_body.mctl164 PRE_first_tail_x8_r0_body.mstack164 PRE_first_tail_x8_r0_body.mjobs164 PRE_first_tail_x8_r0_body.mffi164 PRE_first_tail_x8_r0_body.mtrace164 PRE_first_tail_x8_r0_body.mstores164 h

def PRE_first_tail_x8_r0_body.arrEl164_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE164_2665 : arrOf PRE_first_tail_x8_r0_body.s1582 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl164_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA164_2665 : isArrB PRE_first_tail_x8_r0_body.s1582 2665 = true
theorem PRE_first_tail_x8_r0_body.arr164_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1582.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl164_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE164_2665 PRE_first_tail_x8_r0_body.arrA164_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN164_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl164_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR164_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl164_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN164_2665

def PRE_first_tail_x8_r0_body.arrEl164_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE164_2673467 : arrOf PRE_first_tail_x8_r0_body.s1582 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl164_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA164_2673467 : isArrB PRE_first_tail_x8_r0_body.s1582 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr164_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1582.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl164_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE164_2673467 PRE_first_tail_x8_r0_body.arrA164_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN164_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl164_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR164_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl164_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN164_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k164 : isArrB PRE_first_tail_x8_r0_body.s1582 4910 = false
theorem PRE_first_tail_x8_r0_body.keep164 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1582 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k164 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr164_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl164_2665]

end Host.Load.Run.Tpl
end

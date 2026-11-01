import host.sim.template.a4pre_first_tail_x8_r0_body.m.B25
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

section -- st109/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st109.bodyK0F from PRE_first_tail_x8_r0_body.st109.s0 to PRE_first_tail_x8_r0_body.st109.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st109.F (PRE_first_tail_x8_r0_body.st109.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st109.ks 0).getD 0) PRE_first_tail_x8_r0_body.st109.s0 PRE_first_tail_x8_r0_body.st109.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st109.s1, PRE_first_tail_x8_r0_body.st109.S1)
theorem PRE_first_tail_x8_r0_body.st109.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st109.F (PRE_first_tail_x8_r0_body.st109.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st109.ks 0).getD 0) PRE_first_tail_x8_r0_body.st109.s0 PRE_first_tail_x8_r0_body.st109.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st109.s1, PRE_first_tail_x8_r0_body.st109.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st109.bodyOkLN_ok PRE_first_tail_x8_r0_body.st109.bodyK0F
end Host.Load.Run.Tpl
end

section -- st109/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st109.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st109.F (PRE_first_tail_x8_r0_body.st109.bodyOkL bytes rows) 27 PRE_first_tail_x8_r0_body.st109.s0 PRE_first_tail_x8_r0_body.st109.S0 = some (PRE_first_tail_x8_r0_body.st109.s1, PRE_first_tail_x8_r0_body.st109.S1) :=
  (congrFun (congrFun PRE_first_tail_x8_r0_body.st109.bodyK0 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st109.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st109.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st109.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st109.F (PRE_first_tail_x8_r0_body.st109.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st109.s0
  S0 := PRE_first_tail_x8_r0_body.st109.S0
  s1 := PRE_first_tail_x8_r0_body.st109.s1
  S1 := PRE_first_tail_x8_r0_body.st109.S1
  s2 := PRE_first_tail_x8_r0_body.st109.s2
  S2 := PRE_first_tail_x8_r0_body.st109.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st109.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st109.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st109.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st109.bodyHalt
  last := PRE_first_tail_x8_r0_body.st109.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st109.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC110
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 110 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1065` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa110` into the merged state
`PRE_first_tail_x8_r0_body.s1064`. -/

def PRE_first_tail_x8_r0_body.pl110 : List Nat := [2761005]
def PRE_first_tail_x8_r0_body.nr110 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd110 : RData :=
  ⟨2760996, 2761006, Stage.setAll PTrie.nil [(2760995, 2761005)], Stage.setAll PTrie.nil [],
   20363, 20363, 17455, 17455, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa110 : Map :=
  Conv.Map.compact 2760995 2761006 4756 PRE_first_tail_x8_r0_body.pl110 (PRE_first_tail_x8_r0_body.nr110.map NumV.ref) PRE_first_tail_x8_r0_body.kd110.big
    PRE_first_tail_x8_r0_body.kd110.region PRE_first_tail_x8_r0_body.kd110.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws110 : List Nat := []
noncomputable def PRE_first_tail_x8_r0_body.crs110 : List SymE := PRE_first_tail_x8_r0_body.nr110.map fun r => (nth? PRE_first_tail_x8_r0_body.S1064.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta110 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws110 PRE_first_tail_x8_r0_body.crs110
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB110 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x8_r0_body.ctab110 : PRE_first_tail_x8_r0_body.S1065.tab = PRE_first_tail_x8_r0_body.S1063.tab ++ PRE_first_tail_x8_r0_body.cws110.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace110 : PRE_first_tail_x8_r0_body.s1065.trace = PRE_first_tail_x8_r0_body.s1063.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext110 : PRE_first_tail_x8_r0_body.s1065.next = 2760996
kernel_rfl PRE_first_tail_x8_r0_body.ccounters110 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1065.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1065.ffi).mlx.nnext) = (20363, 17455)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue110 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1064.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1065.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa110.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp110 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1065.ffi).mlx.tokens.all (bSN 4756) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean110 : Conv.cleanListB 20363 131072 (fun r => Nat.ble 81452 r) PRE_first_tail_x8_r0_body.s1065
    (PRE_first_tail_x8_r0_body.wrB110 ++ (List.range 1).map (2760995 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs110 : bigsOutB 20363 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1065.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK110
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl110`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl110 : List Nat := [2665, 2673467, 2760995]
def PRE_first_tail_x8_r0_body.clo110 : List Nat := []
def PRE_first_tail_x8_r0_body.cln110 : List Nat := []
def PRE_first_tail_x8_r0_body.cli110 : List Nat := []
kernel_rfl PRE_first_tail_x8_r0_body.cheap110 : PRE_first_tail_x8_r0_body.s1065.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1063.heap (PRE_first_tail_x8_r0_body.cl110.filterMap fun a => (PRE_first_tail_x8_r0_body.s1065.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe110 : Nat.ble PRE_first_tail_x8_r0_body.s1063.next PRE_first_tail_x8_r0_body.s1065.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP110 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1063 PRE_first_tail_x8_r0_body.s1065 PRE_first_tail_x8_r0_body.cl110 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp110 : Conv.suppListB PRE_first_tail_x8_r0_body.s1065 4756 PRE_first_tail_x8_r0_body.cl110 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound110 : Conv.boundListB PRE_first_tail_x8_r0_body.s1065 PRE_first_tail_x8_r0_body.cl110 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK110 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1065.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln110.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1065.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK110 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1065.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo110.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1065.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK110 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1065.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli110.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1065.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst110 : Conv.sstListB 4756 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1065.ffi).mlx PRE_first_tail_x8_r0_body.cln110 PRE_first_tail_x8_r0_body.clo110 PRE_first_tail_x8_r0_body.cli110 = true

end Host.Load.Run.Tpl
end

section -- SiteCl110
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA110 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1065.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo110.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1065.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd110 : (PRE_first_tail_x8_r0_body.clo110 ++ PRE_first_tail_x8_r0_body.cln110 ++ PRE_first_tail_x8_r0_body.cli110).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle110 : Conv.Cnt.leB (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt) (⟨20363, 17455, 2760996, 4756⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck110 : Conv.ncleanListB (⟨20363, 17455, 2760996, 4756⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1065.ffi).mlx PRE_first_tail_x8_r0_body.clo110 PRE_first_tail_x8_r0_body.cln110 PRE_first_tail_x8_r0_body.cli110 = true
theorem PRE_first_tail_x8_r0_body.cncl110 (h : Conv.NClean (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx) : Conv.NClean (⟨20363, 17455, 2760996, 4756⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1065.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle110 PRE_first_tail_x8_r0_body.ckA110 PRE_first_tail_x8_r0_body.cobjsK110 PRE_first_tail_x8_r0_body.cnodesK110 PRE_first_tail_x8_r0_body.citemsK110 PRE_first_tail_x8_r0_body.cbd110 PRE_first_tail_x8_r0_body.cck110

end Host.Load.Run.Tpl
end

section -- SiteS110
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 110 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc110 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P110 : LoadP := PRE_first_tail_x8_r0_body.Pc110.raise 17455
kernel_rfl PRE_first_tail_x8_r0_body.craise110 : Nat.ble PRE_first_tail_x8_r0_body.Pc110.N0 17455 = true
theorem PRE_first_tail_x8_r0_body.raised110 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc110 PRE_first_tail_x8_r0_body.P110 :=
  .inr ⟨17455, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise110, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_110 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1065.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_110 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1064.ffi)
def PRE_first_tail_x8_r0_body.khinv110 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x8_r0_body.kninv110 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS110 : List Nat := []
def PRE_first_tail_x8_r0_body.cnS110 : List Nat := List.range' 17455 0
def PRE_first_tail_x8_r0_body.ciS110 : List Nat := [] ++ List.range' 17455 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0110 : PRE_first_tail_x8_r0_body.kd110.nh0 = PRE_first_tail_x8_r0_body.cx0_110.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1110 : PRE_first_tail_x8_r0_body.kd110.nh1 = PRE_first_tail_x8_r0_body.cx1_110.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0110 : PRE_first_tail_x8_r0_body.kd110.nn0 = PRE_first_tail_x8_r0_body.cx0_110.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1110 : PRE_first_tail_x8_r0_body.kd110.nn1 = PRE_first_tail_x8_r0_body.cx1_110.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo110 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P110.lo && Nat.ble PRE_first_tail_x8_r0_body.P110.lo PRE_first_tail_x8_r0_body.cx0_110.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P110.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P110.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt110 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_110.mlx.next PRE_first_tail_x8_r0_body.cx1_110.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_110.mlx.nnext PRE_first_tail_x8_r0_body.cx1_110.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband110 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P110.NL && Nat.ble PRE_first_tail_x8_r0_body.P110.NL PRE_first_tail_x8_r0_body.P110.N0 && Nat.ble PRE_first_tail_x8_r0_body.P110.N0 PRE_first_tail_x8_r0_body.cx0_110.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow110 : PRE_first_tail_x8_r0_body.kd110.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren110 : checkRenG PRE_first_tail_x8_r0_body.kd110.hnd PRE_first_tail_x8_r0_body.khinv110 (phB PRE_first_tail_x8_r0_body.cx0_110.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband110 : PRE_first_tail_x8_r0_body.kd110.checkBand PRE_first_tail_x8_r0_body.P110.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos110 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd110.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren110 : checkRenG PRE_first_tail_x8_r0_body.kd110.node PRE_first_tail_x8_r0_body.kninv110 (pnB PRE_first_tail_x8_r0_body.cx0_110.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow110 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd110.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P110.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd110.nodeF j) PRE_first_tail_x8_r0_body.cx1_110.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a110 : PRE_first_tail_x8_r0_body.cx0_110.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b110 : PRE_first_tail_x8_r0_body.cx0_110.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1110 : PRE_first_tail_x8_r0_body.cx1_110.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend110 : PRE_first_tail_x8_r0_body.cx1_110.mlx.pending = PRE_first_tail_x8_r0_body.cx0_110.mlx.pending.map PRE_first_tail_x8_r0_body.kappa110.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh110 : PRE_first_tail_x8_r0_body.cx1_110.mlx.errh = PRE_first_tail_x8_r0_body.cx0_110.mlx.errh.map PRE_first_tail_x8_r0_body.kappa110.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles110 : PRE_first_tail_x8_r0_body.cx1_110.mlx.files = PRE_first_tail_x8_r0_body.cx0_110.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch110 : PRE_first_tail_x8_r0_body.cx1_110.mlx.arch = PRE_first_tail_x8_r0_body.cx0_110.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes110 : PRE_first_tail_x8_r0_body.cx1_110.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_110.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired110 : PRE_first_tail_x8_r0_body.cx1_110.mlx.wired = PRE_first_tail_x8_r0_body.cx0_110.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost110 : PRE_first_tail_x8_r0_body.cx1_110.host = PRE_first_tail_x8_r0_body.cx0_110.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd110`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0110 : PRE_first_tail_x8_r0_body.kd110.n0 = 2760996
kernel_rfl PRE_first_tail_x8_r0_body.ckn1110 : PRE_first_tail_x8_r0_body.kd110.n1 = 2761006
kernel_rfl PRE_first_tail_x8_r0_body.ckheap110 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd110.heap).all (fun x => Nat.ble 2760995 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl110 : (List.range 1).all (fun j => decide (PRE_first_tail_x8_r0_body.kd110.heap.get (2760995 + j) = nth? PRE_first_tail_x8_r0_body.pl110 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja110 : Nat.ble 2760995 2760995 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn110 : Nat.ble 4756 4756 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD110 : Nat.ble 2760995 PRE_first_tail_x8_r0_body.kd110.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn110 : Nat.ble 20363 PRE_first_tail_x8_r0_body.kd110.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn110 : Nat.ble 17455 PRE_first_tail_x8_r0_body.kd110.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb110 : Nat.ble 20363 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap110 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd110.heap).all (Nat.ble (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd110 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd110.hnd).all (Nat.ble (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode110 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd110.node).all (Nat.ble (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix110 : Conv.FixOld (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa110 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja110) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn110) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD110) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn110) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn110) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb110) PRE_first_tail_x8_r0_body.fheap110 PRE_first_tail_x8_r0_body.fhnd110 PRE_first_tail_x8_r0_body.fnode110
kernel_rfl PRE_first_tail_x8_r0_body.fcxn110 : (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn110 : (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0110 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_110.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_110.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk110 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd110.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A110 : PRE_first_tail_x8_r0_body.cx1_110.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS110.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_110.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O110 : PRE_first_tail_x8_r0_body.cx1_110.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS110.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_110.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N110 : PRE_first_tail_x8_r0_body.cx1_110.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS110.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_110.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I110 : PRE_first_tail_x8_r0_body.cx1_110.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS110.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_110.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd110 : (PRE_first_tail_x8_r0_body.clo110 ++ PRE_first_tail_x8_r0_body.cln110 ++ PRE_first_tail_x8_r0_body.cli110 ++ PRE_first_tail_x8_r0_body.cwS110 ++ PRE_first_tail_x8_r0_body.cnS110 ++ PRE_first_tail_x8_r0_body.ciS110).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW110 : PRE_first_tail_x8_r0_body.cwS110.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo110.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI110 : PRE_first_tail_x8_r0_body.ciS110.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli110.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN110 : PRE_first_tail_x8_r0_body.cnS110.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF110 : PRE_first_tail_x8_r0_body.cln110.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh110 : PRE_first_tail_x8_r0_body.clo110.all (handleOK PRE_first_tail_x8_r0_body.kappa110 PRE_first_tail_x8_r0_body.P110.lo PRE_first_tail_x8_r0_body.cx0_110.mlx PRE_first_tail_x8_r0_body.cx1_110.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo110 : PRE_first_tail_x8_r0_body.clo110.map (fun h => PRE_first_tail_x8_r0_body.cx1_110.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa110.handle h)) = PRE_first_tail_x8_r0_body.clo110.map (fun h => (PRE_first_tail_x8_r0_body.cx0_110.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa110.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok110 : PRE_first_tail_x8_r0_body.clo110.all (objOK PRE_first_tail_x8_r0_body.kappa110 PRE_first_tail_x8_r0_body.P110.NL PRE_first_tail_x8_r0_body.cx0_110.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd110 : PRE_first_tail_x8_r0_body.cln110.all (nodeOKF PRE_first_tail_x8_r0_body.kappa110 PRE_first_tail_x8_r0_body.P110 PRE_first_tail_x8_r0_body.cx0_110.mlx PRE_first_tail_x8_r0_body.cx1_110.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp110 : ((PRE_first_tail_x8_r0_body.cln110.filter (fullB PRE_first_tail_x8_r0_body.P110))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_110.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa110.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln110.filter (fullB PRE_first_tail_x8_r0_body.P110))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_110.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa110.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI110 : incrB PRE_first_tail_x8_r0_body.kd110.nodeF (List.range' 17455 0) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK110 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd110.node).all (fun k => Nat.ble 17455 k && Nat.blt k 17455) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL110 : (PRE_first_tail_x8_r0_body.cln110.filter (Nat.ble PRE_first_tail_x8_r0_body.P110.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd110.nodeF i) && (Nat.blt i 17455 || Nat.ble PRE_first_tail_x8_r0_body.kd110.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord110 : (PRE_first_tail_x8_r0_body.cln110.filter (Nat.ble PRE_first_tail_x8_r0_body.P110.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd110.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd110.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd110.nodeF j) (PRE_first_tail_x8_r0_body.kd110.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow110 PRE_first_tail_x8_r0_body.cnn1110 PRE_first_tail_x8_r0_body.fnordI110 PRE_first_tail_x8_r0_body.fnordK110 PRE_first_tail_x8_r0_body.fnordL110
kernel_rfl PRE_first_tail_x8_r0_body.fi110 : PRE_first_tail_x8_r0_body.cli110.all (pnB PRE_first_tail_x8_r0_body.cx0_110.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii110 : PRE_first_tail_x8_r0_body.cli110.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_110.mlx.items.get (PRE_first_tail_x8_r0_body.kappa110.node k) = (PRE_first_tail_x8_r0_body.cx0_110.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa110.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot110 (clean : Conv.NClean (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P110.NL) (cl : SSt (· < 4756) PRE_first_tail_x8_r0_body.cx0_110.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P110 4756 PRE_first_tail_x8_r0_body.kappa110 PRE_first_tail_x8_r0_body.kd110 PRE_first_tail_x8_r0_body.khinv110 PRE_first_tail_x8_r0_body.kninv110 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx PRE_first_tail_x8_r0_body.cx0_110.mlx PRE_first_tail_x8_r0_body.cx1_110.mlx (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo110 PRE_first_tail_x8_r0_body.cln110 PRE_first_tail_x8_r0_body.cli110 PRE_first_tail_x8_r0_body.cwS110 PRE_first_tail_x8_r0_body.cnS110 PRE_first_tail_x8_r0_body.ciS110 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0110, PRE_first_tail_x8_r0_body.cnh1110, PRE_first_tail_x8_r0_body.cnn0110, PRE_first_tail_x8_r0_body.cnn1110, PRE_first_tail_x8_r0_body.cplo110, PRE_first_tail_x8_r0_body.ccnt110, PRE_first_tail_x8_r0_body.cnband110, PRE_first_tail_x8_r0_body.chbelow110, PRE_first_tail_x8_r0_body.chren110, PRE_first_tail_x8_r0_body.cband110, PRE_first_tail_x8_r0_body.cnh1pos110, PRE_first_tail_x8_r0_body.cnren110, PRE_first_tail_x8_r0_body.cnlow110, PRE_first_tail_x8_r0_body.cabs0a110, PRE_first_tail_x8_r0_body.cabs0b110, PRE_first_tail_x8_r0_body.ctok1110, PRE_first_tail_x8_r0_body.cpend110, PRE_first_tail_x8_r0_body.cerrh110, PRE_first_tail_x8_r0_body.cfiles110, PRE_first_tail_x8_r0_body.carch110, PRE_first_tail_x8_r0_body.csizes110, PRE_first_tail_x8_r0_body.cwired110, PRE_first_tail_x8_r0_body.cfix110, clean, PRE_first_tail_x8_r0_body.fcxn110, PRE_first_tail_x8_r0_body.fcnn110, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0110, PRE_first_tail_x8_r0_body.fnk110, PRE_first_tail_x8_r0_body.ckA110, PRE_first_tail_x8_r0_body.cobjsK110, PRE_first_tail_x8_r0_body.cnodesK110, PRE_first_tail_x8_r0_body.citemsK110, PRE_first_tail_x8_r0_body.f1A110, PRE_first_tail_x8_r0_body.f1O110, PRE_first_tail_x8_r0_body.f1N110, PRE_first_tail_x8_r0_body.f1I110, PRE_first_tail_x8_r0_body.fbd110, PRE_first_tail_x8_r0_body.fincW110, PRE_first_tail_x8_r0_body.fincI110, PRE_first_tail_x8_r0_body.fincN110, PRE_first_tail_x8_r0_body.flnF110, PRE_first_tail_x8_r0_body.fh110, PRE_first_tail_x8_r0_body.fo110, PRE_first_tail_x8_r0_body.fok110, PRE_first_tail_x8_r0_body.fnd110, PRE_first_tail_x8_r0_body.fp110, PRE_first_tail_x8_r0_body.fnord110, PRE_first_tail_x8_r0_body.fi110, PRE_first_tail_x8_r0_body.fii110⟩
theorem PRE_first_tail_x8_r0_body.cnshift110 (clean : Conv.NClean (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P110.NL) (cl : SSt (· < 4756) PRE_first_tail_x8_r0_body.cx0_110.mlx) : NShift PRE_first_tail_x8_r0_body.P110 4756 PRE_first_tail_x8_r0_body.kappa110 PRE_first_tail_x8_r0_body.cx0_110 PRE_first_tail_x8_r0_body.cx1_110 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot110 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost110 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0110 PRE_first_tail_x8_r0_body.ckn1110 PRE_first_tail_x8_r0_body.ckheap110 PRE_first_tail_x8_r0_body.ckpl110)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_110 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1063.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_110 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1063.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_110 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1063.ffi) = some PRE_first_tail_x8_r0_body.fxC_110
kernel_rfl PRE_first_tail_x8_r0_body.okrC_110 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1063.ffi) = some PRE_first_tail_x8_r0_body.krC_110
noncomputable def PRE_first_tail_x8_r0_body.fx0_110 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1065.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_110 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1065.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_110 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1065.ffi) = some PRE_first_tail_x8_r0_body.fx0_110
kernel_rfl PRE_first_tail_x8_r0_body.okr0_110 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1065.ffi) = some PRE_first_tail_x8_r0_body.kr0_110
noncomputable def PRE_first_tail_x8_r0_body.fx1_110 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1064.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_110 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1064.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_110 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1064.ffi) = some PRE_first_tail_x8_r0_body.fx1_110
kernel_rfl PRE_first_tail_x8_r0_body.okr1_110 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1064.ffi) = some PRE_first_tail_x8_r0_body.kr1_110
kernel_rfl PRE_first_tail_x8_r0_body.ff0110 : PRE_first_tail_x8_r0_body.fx0_110 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_110 (PRE_first_tail_x8_r0_body.clo110.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_110.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1110 : PRE_first_tail_x8_r0_body.fx1_110 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_110 (PRE_first_tail_x8_r0_body.cwS110.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_110.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck110 : freedLB PRE_first_tail_x8_r0_body.kappa110 PRE_first_tail_x8_r0_body.cx0_110.mlx PRE_first_tail_x8_r0_body.fx0_110 PRE_first_tail_x8_r0_body.fx1_110 PRE_first_tail_x8_r0_body.clo110 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0110 : PRE_first_tail_x8_r0_body.kr0_110.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_110.flags (PRE_first_tail_x8_r0_body.clo110.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_110.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0110 : PRE_first_tail_x8_r0_body.kr0_110.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_110.targs (PRE_first_tail_x8_r0_body.clo110.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_110.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1110 : PRE_first_tail_x8_r0_body.kr1_110.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_110.flags (PRE_first_tail_x8_r0_body.cwS110.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_110.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1110 : PRE_first_tail_x8_r0_body.kr1_110.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_110.targs (PRE_first_tail_x8_r0_body.cwS110.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_110.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck110 : krecLB PRE_first_tail_x8_r0_body.kappa110 4756 PRE_first_tail_x8_r0_body.cx0_110.mlx PRE_first_tail_x8_r0_body.kr0_110 PRE_first_tail_x8_r0_body.kr1_110 PRE_first_tail_x8_r0_body.clo110 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn110 : Nat.ble 4756 4756 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge110 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1064.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1065.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR110 : pendRegB PRE_first_tail_x8_r0_body.kappa110 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1065.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe110 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1065.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1064.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift110 (clean : Conv.NClean (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P110.NL) (cl : SSt (· < 4756) PRE_first_tail_x8_r0_body.cx0_110.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_110.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_110.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_110.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1063.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_110.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P110 4756 PRE_first_tail_x8_r0_body.kappa110 PRE_first_tail_x8_r0_body.s1065.ffi PRE_first_tail_x8_r0_body.s1064.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift110 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue110, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp110 t ht),
    PRE_first_tail_x8_r0_body.cbridge110,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1065.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1064.ffi) (PRE_first_tail_x8_r0_body.cfoot110 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_110 PRE_first_tail_x8_r0_body.ofx1_110 hobjC PRE_first_tail_x8_r0_body.ff0110 PRE_first_tail_x8_r0_body.ff1110 PRE_first_tail_x8_r0_body.ffck110,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1065.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1064.ffi) (PRE_first_tail_x8_r0_body.cfoot110 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_110 PRE_first_tail_x8_r0_body.okr1_110 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn110) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0110 PRE_first_tail_x8_r0_body.fkt0110 PRE_first_tail_x8_r0_body.fkf1110 PRE_first_tail_x8_r0_body.fkt1110 PRE_first_tail_x8_r0_body.fkck110,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0110 PRE_first_tail_x8_r0_body.cnh1110 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe110) PRE_first_tail_x8_r0_body.cpendR110⟩

end Host.Load.Run.Tpl
end

section -- st110/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st110 0
host_stream_state PRE_first_tail_x8_r0_body.st110 1
host_stream_state PRE_first_tail_x8_r0_body.st110 2
end Host.Load.Run.Tpl
end

section -- Site110
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 110 of chain `PRE_first_tail_x8_r0_body`: `plan__g110__g111` (`plan`), the call state `PRE_first_tail_x8_r0_body.s1063`, the merged state `PRE_first_tail_x8_r0_body.s1064`,
the site template `PRE_first_tail_x8_r0_body.st110` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1065`: the merge.
The footprint's facts are in `SiteF110`, the compaction's in `SiteC110`, `SiteK110`, `SiteNa110`, `SiteNb110`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso110 : PRE_first_tail_x8_r0_body.st110.s0 = { PRE_first_tail_x8_r0_body.s1063 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs110 : List Frame := PRE_first_tail_x8_r0_body.s1063.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_110 : PRE_first_tail_x8_r0_body.S1063.tab.length = 4756
kernel_rfl PRE_first_tail_x8_r0_body.tab0_110 : PRE_first_tail_x8_r0_body.st110.S0.tab = PRE_first_tail_x8_r0_body.S1063.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws110 : List Nat := [2854, 2855, 2856]
kernel_rfl PRE_first_tail_x8_r0_body.fresh110 : (PRE_first_tail_x8_r0_body.S1063.tab.all fun e => PRE_first_tail_x8_r0_body.ws110.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1063.oracle.all fun q => PRE_first_tail_x8_r0_body.ws110.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab110 : PRE_first_tail_x8_r0_body.S1064.tab = PRE_first_tail_x8_r0_body.S1063.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws110
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen110 : PRE_first_tail_x8_r0_body.st110.S2.tab.length - PRE_first_tail_x8_r0_body.st110.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged110`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap110 : PRE_first_tail_x8_r0_body.s1064.heap = PRE_first_tail_x8_r0_body.st110.s2.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext110 : PRE_first_tail_x8_r0_body.s1064.next = PRE_first_tail_x8_r0_body.st110.s2.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl110 : PRE_first_tail_x8_r0_body.s1064.ctl = PRE_first_tail_x8_r0_body.st110.s2.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack110 : PRE_first_tail_x8_r0_body.s1064.stack = PRE_first_tail_x8_r0_body.st110.s2.stack ++ PRE_first_tail_x8_r0_body.s1063.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs110 : PRE_first_tail_x8_r0_body.s1064.jobs = PRE_first_tail_x8_r0_body.st110.s2.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi110 : PRE_first_tail_x8_r0_body.s1064.ffi = PRE_first_tail_x8_r0_body.st110.s2.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace110 : PRE_first_tail_x8_r0_body.s1064.trace = PRE_first_tail_x8_r0_body.st110.s2.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores110 : PRE_first_tail_x8_r0_body.s1064.stores = PRE_first_tail_x8_r0_body.st110.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD110
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 110 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived110 : PRE_first_tail_x8_r0_body.nr110.map (fun r => nth? PRE_first_tail_x8_r0_body.st110.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo110 : PRE_first_tail_x8_r0_body.nr110.all (Nat.ble 4756) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj110 : PRE_first_tail_x8_r0_body.cws110.all (fun c => !PRE_first_tail_x8_r0_body.ws110.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ110 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws110 PRE_first_tail_x8_r0_body.crs110 PRE_first_tail_x8_r0_body.ws110

end Host.Load.Run.Tpl
end

section -- st110/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st110`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st110.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st110.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st110.s2.heap PRE_first_tail_x8_r0_body.st110.wrR ++ freshOf PRE_first_tail_x8_r0_body.st110.s2.heap PRE_first_tail_x8_r0_body.st110.s0.next PRE_first_tail_x8_r0_body.st110.s2.next
noncomputable def PRE_first_tail_x8_r0_body.st110.wr : List Nat := PRE_first_tail_x8_r0_body.st110.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st110.heapFoot : PRE_first_tail_x8_r0_body.st110.s2.heap = setAll PRE_first_tail_x8_r0_body.st110.s0.heap PRE_first_tail_x8_r0_body.st110.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st110.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st110.s0.next PRE_first_tail_x8_r0_body.st110.s2.next = true
theorem PRE_first_tail_x8_r0_body.st110.grows : PRE_first_tail_x8_r0_body.st110.s0.next ≤ PRE_first_tail_x8_r0_body.st110.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st110.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st110.wh : List Nat := []
def PRE_first_tail_x8_r0_body.st110.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st110.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st110.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st110.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st110.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st110.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st110.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st110.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st110.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st110.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st110.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st110.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st110.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st110.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st110.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st110.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st110.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st110.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st110.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st110.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st110.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st110.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st110.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st110.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st110.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st110.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st110.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st110.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st110.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st110.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF110
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 110 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB110 : nodupT PRE_first_tail_x8_r0_body.st110.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup110 : PRE_first_tail_x8_r0_body.st110.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB110).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB110 : PRE_first_tail_x8_r0_body.st110.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound110 : ∀ b ∈ PRE_first_tail_x8_r0_body.st110.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB110 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr110 := PRE_first_tail_x8_r0_body.st110.s2.trace.take 0
kernel_rfl PRE_first_tail_x8_r0_body.traceEq110 : PRE_first_tail_x8_r0_body.st110.s2.trace = PRE_first_tail_x8_r0_body.trFr110 ++ PRE_first_tail_x8_r0_body.st110.s0.trace
theorem PRE_first_tail_x8_r0_body.trace110 : ∃ fr, PRE_first_tail_x8_r0_body.st110.s2.trace = fr ++ PRE_first_tail_x8_r0_body.st110.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq110⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide110 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB110 : (PRE_first_tail_x8_r0_body.wide110.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st110.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix110 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide110, WFix Map.id (Present PRE_first_tail_x8_r0_body.st110.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB110 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL110
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 110 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1064`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO110 : PRE_first_tail_x8_r0_body.st110.S0.oracle = PRE_first_tail_x8_r0_body.st110.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B110 : PRE_first_tail_x8_r0_body.st110.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st110.s0.next || (PRE_first_tail_x8_r0_body.st110.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot110 : Conv.StageFoot PRE_first_tail_x8_r0_body.st110.wr PRE_first_tail_x8_r0_body.st110.s0 PRE_first_tail_x8_r0_body.st110.s2 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st110.heapFoot PRE_first_tail_x8_r0_body.wrNodup110 PRE_first_tail_x8_r0_body.wrBound110 PRE_first_tail_x8_r0_body.wr0B110 PRE_first_tail_x8_r0_body.st110.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged110 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st110.F.S → PRE_first_tail_x8_r0_body.st110.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st110.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st110.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs110 PRE_first_tail_x8_r0_body.st110.wr PRE_first_tail_x8_r0_body.s1063 PRE_first_tail_x8_r0_body.st110.s2 PRE_first_tail_x8_r0_body.st110.s0
      PRE_first_tail_x8_r0_body.st110.s2.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st110.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1064 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso110 PRE_first_tail_x8_r0_body.stFoot110 PRE_first_tail_x8_r0_body.wrNodup110 PRE_first_tail_x8_r0_body.wrBound110 PRE_first_tail_x8_r0_body.trace110 PRE_first_tail_x8_r0_body.mheap110
    PRE_first_tail_x8_r0_body.mnext110 PRE_first_tail_x8_r0_body.mctl110 PRE_first_tail_x8_r0_body.mstack110 PRE_first_tail_x8_r0_body.mjobs110 PRE_first_tail_x8_r0_body.mffi110 PRE_first_tail_x8_r0_body.mtrace110 PRE_first_tail_x8_r0_body.mstores110 h

def PRE_first_tail_x8_r0_body.arrEl110_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE110_2665 : arrOf PRE_first_tail_x8_r0_body.s1064 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl110_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA110_2665 : isArrB PRE_first_tail_x8_r0_body.s1064 2665 = true
theorem PRE_first_tail_x8_r0_body.arr110_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1064.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl110_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE110_2665 PRE_first_tail_x8_r0_body.arrA110_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN110_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl110_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR110_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl110_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN110_2665

def PRE_first_tail_x8_r0_body.arrEl110_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE110_2673467 : arrOf PRE_first_tail_x8_r0_body.s1064 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl110_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA110_2673467 : isArrB PRE_first_tail_x8_r0_body.s1064 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr110_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1064.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl110_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE110_2673467 PRE_first_tail_x8_r0_body.arrA110_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN110_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl110_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR110_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl110_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN110_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k110 : isArrB PRE_first_tail_x8_r0_body.s1064 4910 = false
theorem PRE_first_tail_x8_r0_body.keep110 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1064 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k110 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr110_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl110_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ110
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 110 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1063`, the merged
state `PRE_first_tail_x8_r0_body.s1064`, the canonical state `PRE_first_tail_x8_r0_body.s1065`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl110 : PRE_first_tail_x8_r0_body.pl110.all (Nat.ble PRE_first_tail_x8_r0_body.s1063.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd110 : nodupT PRE_first_tail_x8_r0_body.pl110 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1110 : Nat.ble PRE_first_tail_x8_r0_body.s1063.next 2761006 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst110 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1063.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn110 : PRE_first_tail_x8_r0_body.s1065.next = PRE_first_tail_x8_r0_body.s1063.next + PRE_first_tail_x8_r0_body.pl110.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn110 : PRE_first_tail_x8_r0_body.s1064.next = 2761006
kernel_rfl PRE_first_tail_x8_r0_body.zgrow110 : Nat.ble PRE_first_tail_x8_r0_body.s1065.next PRE_first_tail_x8_r0_body.s1064.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh110 : PRE_first_tail_x8_r0_body.S1063.tab.all (fun e => PRE_first_tail_x8_r0_body.cws110.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd110 : nodupT PRE_first_tail_x8_r0_body.cws110 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi110 : PRE_first_tail_x8_r0_body.nr110.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1064.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt110 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1063.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg110_2665 : PRE_first_tail_x8_r0_body.s1065.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1065 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk110_2665 : (objOf PRE_first_tail_x8_r0_body.s1065 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm110_2665 : PRE_first_tail_x8_r0_body.s1064.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa110.obj (objOf PRE_first_tail_x8_r0_body.s1065 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1064 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg110_2673467 : PRE_first_tail_x8_r0_body.s1065.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1065 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk110_2673467 : (objOf PRE_first_tail_x8_r0_body.s1065 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm110_2673467 : PRE_first_tail_x8_r0_body.s1064.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa110.obj (objOf PRE_first_tail_x8_r0_body.s1065 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1064 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw110_4910 : (PRE_first_tail_x8_r0_body.s1065.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw110_2673472 : (PRE_first_tail_x8_r0_body.s1065.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw110_2673473 : (PRE_first_tail_x8_r0_body.s1065.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd110 : PRE_first_tail_x8_r0_body.cl110.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr110 : PRE_first_tail_x8_r0_body.st110.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1063.next || PRE_first_tail_x8_r0_body.cl110.contains b) = true
def PRE_first_tail_x8_r0_body.zl110 : List Nat := PRE_first_tail_x8_r0_body.cl110.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE110 : PRE_first_tail_x8_r0_body.zl110.map (fun a => PRE_first_tail_x8_r0_body.s1064.heap.get (PRE_first_tail_x8_r0_body.kappa110.a a)) = PRE_first_tail_x8_r0_body.zl110.map (fun a => (PRE_first_tail_x8_r0_body.s1065.heap.get a).map PRE_first_tail_x8_r0_body.kappa110.hobj)
theorem PRE_first_tail_x8_r0_body.zimg110 : HeapImg PRE_first_tail_x8_r0_body.kappa110 PRE_first_tail_x8_r0_body.s1065 PRE_first_tail_x8_r0_body.s1064 PRE_first_tail_x8_r0_body.zl110 := PRE_first_tail_x8_r0_body.zimgE110
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl110 : PRE_first_tail_x8_r0_body.s1064.ctl = PRE_first_tail_x8_r0_body.kappa110.ctl PRE_first_tail_x8_r0_body.s1065.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack110 : PRE_first_tail_x8_r0_body.s1064.stack = PRE_first_tail_x8_r0_body.s1065.stack.map PRE_first_tail_x8_r0_body.kappa110.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs110 : PRE_first_tail_x8_r0_body.s1064.jobs = PRE_first_tail_x8_r0_body.s1065.jobs.map PRE_first_tail_x8_r0_body.kappa110.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores110 : PRE_first_tail_x8_r0_body.s1064.stores = PRE_first_tail_x8_r0_body.kappa110.stores PRE_first_tail_x8_r0_body.s1065.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots110 : checkRootsSupp PRE_first_tail_x8_r0_body.s1065 4756 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC110 : PRE_first_tail_x8_r0_body.S1063.tab.length + PRE_first_tail_x8_r0_body.cws110.length = 4756
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap110 : PRE_first_tail_x8_r0_body.kappa110 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1063.next 2761006 PRE_first_tail_x8_r0_body.S1063.tab.length PRE_first_tail_x8_r0_body.pl110 (PRE_first_tail_x8_r0_body.nr110.map NumV.ref) PRE_first_tail_x8_r0_body.kd110.big
  PRE_first_tail_x8_r0_body.kd110.region PRE_first_tail_x8_r0_body.kd110.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin110 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1065.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc110 : Conv.jcleanListB (⟨20363, 17455, 2760996, 4756⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1065 PRE_first_tail_x8_r0_body.cl110 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB110 : noBigRootsP (fun i => !Conv.oldBigB (⟨20363, 17455, 2760996, 4756⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1065.trace PRE_first_tail_x8_r0_body.s1065 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm110 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 17455 = true
theorem PRE_first_tail_x8_r0_body.cjcl110 (h : Conv.JClean (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1063) : Conv.JClean (⟨20363, 17455, 2760996, 4756⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1065 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle110)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap110 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd110 a ha)) PRE_first_tail_x8_r0_body.zjc110

end Host.Load.Run.Tpl
end

section -- st110/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st110.bodyLast from PRE_first_tail_x8_r0_body.st110.s1 to PRE_first_tail_x8_r0_body.st110.s2 :
  interpS (step PRE_first_tail_x8_r0_body.st110.F PRE_first_tail_x8_r0_body.st110.s1).run PRE_first_tail_x8_r0_body.st110.S1 = some (PRE_first_tail_x8_r0_body.st110.s2, PRE_first_tail_x8_r0_body.st110.S2)
kernel_rfl PRE_first_tail_x8_r0_body.st110.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st110.s1.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st110.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st110.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st110/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st110.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st110.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st110.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st110.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st110.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st110.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st110.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st110.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st110.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st110.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st110.s0 PRE_first_tail_x8_r0_body.st110.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st110.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st110.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st110.s1 PRE_first_tail_x8_r0_body.st110.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st110/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st110.bodyK0F from PRE_first_tail_x8_r0_body.st110.s0 to PRE_first_tail_x8_r0_body.st110.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st110.F (PRE_first_tail_x8_r0_body.st110.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st110.ks 0).getD 0) PRE_first_tail_x8_r0_body.st110.s0 PRE_first_tail_x8_r0_body.st110.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st110.s1, PRE_first_tail_x8_r0_body.st110.S1)
theorem PRE_first_tail_x8_r0_body.st110.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st110.F (PRE_first_tail_x8_r0_body.st110.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st110.ks 0).getD 0) PRE_first_tail_x8_r0_body.st110.s0 PRE_first_tail_x8_r0_body.st110.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st110.s1, PRE_first_tail_x8_r0_body.st110.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st110.bodyOkLN_ok PRE_first_tail_x8_r0_body.st110.bodyK0F
end Host.Load.Run.Tpl
end

section -- st110/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st110.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st110.F (PRE_first_tail_x8_r0_body.st110.bodyOkL bytes rows) 98 PRE_first_tail_x8_r0_body.st110.s0 PRE_first_tail_x8_r0_body.st110.S0 = some (PRE_first_tail_x8_r0_body.st110.s1, PRE_first_tail_x8_r0_body.st110.S1) :=
  (congrFun (congrFun PRE_first_tail_x8_r0_body.st110.bodyK0 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st110.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st110.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st110.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st110.F (PRE_first_tail_x8_r0_body.st110.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st110.s0
  S0 := PRE_first_tail_x8_r0_body.st110.S0
  s1 := PRE_first_tail_x8_r0_body.st110.s1
  S1 := PRE_first_tail_x8_r0_body.st110.S1
  s2 := PRE_first_tail_x8_r0_body.st110.s2
  S2 := PRE_first_tail_x8_r0_body.st110.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st110.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st110.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st110.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st110.bodyHalt
  last := PRE_first_tail_x8_r0_body.st110.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st110.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC111
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 111 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1082` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa111` into the merged state
`PRE_first_tail_x8_r0_body.s1081`. -/

def PRE_first_tail_x8_r0_body.pl111 : List Nat := [2763579, 2762754, 2763585, 2763581, 2762756, 2763587]
def PRE_first_tail_x8_r0_body.nr111 : List Nat := [4859, 4858, 4834, 4842, 4847, 4852, 4857, 4831, 4832, 4833, 4840, 4841, 4829, 4836, 4837, 4838, 4839, 4835]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd111 : RData :=
  ⟨2762473, 2763622, Stage.setAll PTrie.nil [(2762467, 2763579), (2762468, 2762754), (2762469, 2763585), (2762470, 2763581), (2762471, 2762756), (2762472, 2763587)], Stage.setAll PTrie.nil [(20397, 20423), (20398, 20401), (20399, 20424)],
   20400, 20425, 17501, 17501, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(4829, .ref 4859), (4830, .ref 4858), (4831, .ref 4834), (4832, .ref 4842), (4833, .ref 4847), (4834, .ref 4852), (4835, .ref 4857), (4836, .ref 4831), (4837, .ref 4832), (4838, .ref 4833), (4839, .ref 4840), (4840, .ref 4841), (4841, .ref 4829), (4842, .ref 4836), (4843, .ref 4837), (4844, .ref 4838), (4845, .ref 4839), (4846, .ref 4835)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa111 : Map :=
  Conv.Map.compact 2762467 2763622 4829 PRE_first_tail_x8_r0_body.pl111 (PRE_first_tail_x8_r0_body.nr111.map NumV.ref) PRE_first_tail_x8_r0_body.kd111.big
    PRE_first_tail_x8_r0_body.kd111.region PRE_first_tail_x8_r0_body.kd111.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws111 : List Nat := [2888, 2889, 2890, 2891, 2892, 2893, 2894, 2895, 2896, 2897, 2898, 2899, 2900, 2901, 2902, 2903, 2904, 2905]
noncomputable def PRE_first_tail_x8_r0_body.crs111 : List SymE := PRE_first_tail_x8_r0_body.nr111.map fun r => (nth? PRE_first_tail_x8_r0_body.S1081.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta111 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws111 PRE_first_tail_x8_r0_body.crs111
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB111 : List Nat := [2665, 2672584, 2673467, 2761641, 2762186, 2762442]

kernel_rfl PRE_first_tail_x8_r0_body.ctab111 : PRE_first_tail_x8_r0_body.S1082.tab = PRE_first_tail_x8_r0_body.S1080.tab ++ PRE_first_tail_x8_r0_body.cws111.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace111 : PRE_first_tail_x8_r0_body.s1082.trace = PRE_first_tail_x8_r0_body.s1080.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext111 : PRE_first_tail_x8_r0_body.s1082.next = 2762473
kernel_rfl PRE_first_tail_x8_r0_body.ccounters111 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1082.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1082.ffi).mlx.nnext) = (20400, 17501)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue111 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1081.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1082.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa111.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp111 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1082.ffi).mlx.tokens.all (bSN 4847) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean111 : Conv.cleanListB 20400 131072 (fun r => Nat.ble 81600 r) PRE_first_tail_x8_r0_body.s1082
    (PRE_first_tail_x8_r0_body.wrB111 ++ (List.range 6).map (2762467 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs111 : bigsOutB 20400 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1082.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK111
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl111`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl111 : List Nat := [2665, 2672584, 2673467, 2761641, 2762186, 2762442, 2762467, 2762468, 2762469, 2762470, 2762471, 2762472]
def PRE_first_tail_x8_r0_body.clo111 : List Nat := [20377, 20390, 20396, 20397, 20398, 20399]
def PRE_first_tail_x8_r0_body.cln111 : List Nat := [17474, 17475, 17476, 17477, 17478, 17479, 17480, 17481, 17482, 17483, 17484, 17485, 17486, 17487, 17488, 17489, 17490, 17491, 17492, 17493, 17494, 17495, 17496, 17497, 17498, 17499, 17500]
def PRE_first_tail_x8_r0_body.cli111 : List Nat := [17474, 17475, 17476, 17477, 17478, 17479, 17480, 17481, 17482, 17483, 17484, 17485, 17486, 17487, 17488, 17489, 17490, 17491, 17492, 17493, 17494, 17495, 17496, 17497, 17498, 17499, 17500]
kernel_rfl PRE_first_tail_x8_r0_body.cheap111 : PRE_first_tail_x8_r0_body.s1082.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1080.heap (PRE_first_tail_x8_r0_body.cl111.filterMap fun a => (PRE_first_tail_x8_r0_body.s1082.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe111 : Nat.ble PRE_first_tail_x8_r0_body.s1080.next PRE_first_tail_x8_r0_body.s1082.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP111 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1080 PRE_first_tail_x8_r0_body.s1082 PRE_first_tail_x8_r0_body.cl111 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp111 : Conv.suppListB PRE_first_tail_x8_r0_body.s1082 4847 PRE_first_tail_x8_r0_body.cl111 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound111 : Conv.boundListB PRE_first_tail_x8_r0_body.s1082 PRE_first_tail_x8_r0_body.cl111 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK111 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1082.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln111.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1082.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK111 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1082.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo111.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1082.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK111 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1082.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli111.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1082.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst111 : Conv.sstListB 4847 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1082.ffi).mlx PRE_first_tail_x8_r0_body.cln111 PRE_first_tail_x8_r0_body.clo111 PRE_first_tail_x8_r0_body.cli111 = true

end Host.Load.Run.Tpl
end

section -- SiteCl111
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA111 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1082.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo111.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1082.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd111 : (PRE_first_tail_x8_r0_body.clo111 ++ PRE_first_tail_x8_r0_body.cln111 ++ PRE_first_tail_x8_r0_body.cli111).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle111 : Conv.Cnt.leB (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt) (⟨20400, 17501, 2762473, 4847⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck111 : Conv.ncleanListB (⟨20400, 17501, 2762473, 4847⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1082.ffi).mlx PRE_first_tail_x8_r0_body.clo111 PRE_first_tail_x8_r0_body.cln111 PRE_first_tail_x8_r0_body.cli111 = true
theorem PRE_first_tail_x8_r0_body.cncl111 (h : Conv.NClean (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx) : Conv.NClean (⟨20400, 17501, 2762473, 4847⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1082.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle111 PRE_first_tail_x8_r0_body.ckA111 PRE_first_tail_x8_r0_body.cobjsK111 PRE_first_tail_x8_r0_body.cnodesK111 PRE_first_tail_x8_r0_body.citemsK111 PRE_first_tail_x8_r0_body.cbd111 PRE_first_tail_x8_r0_body.cck111

end Host.Load.Run.Tpl
end

section -- SiteS111
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 111 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc111 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P111 : LoadP := PRE_first_tail_x8_r0_body.Pc111.raise 17501
kernel_rfl PRE_first_tail_x8_r0_body.craise111 : Nat.ble PRE_first_tail_x8_r0_body.Pc111.N0 17501 = true
theorem PRE_first_tail_x8_r0_body.raised111 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc111 PRE_first_tail_x8_r0_body.P111 :=
  .inr ⟨17501, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise111, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_111 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1082.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_111 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1081.ffi)
def PRE_first_tail_x8_r0_body.khinv111 : PTrie Nat := Stage.setAll PTrie.nil [(20423, 20397), (20401, 20398), (20424, 20399)]
def PRE_first_tail_x8_r0_body.kninv111 : PTrie Nat := Stage.setAll PTrie.nil [(17474, 17474), (17475, 17475), (17476, 17476), (17477, 17477), (17478, 17478), (17479, 17479), (17480, 17480), (17481, 17481), (17482, 17482), (17483, 17483), (17484, 17484), (17485, 17485), (17486, 17486), (17487, 17487), (17488, 17488), (17489, 17489), (17490, 17490), (17491, 17491), (17492, 17492), (17493, 17493), (17494, 17494), (17495, 17495), (17496, 17496), (17497, 17497), (17498, 17498), (17499, 17499), (17500, 17500)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS111 : List Nat := [20377, 20390, 20396, 20397, 20398, 20399, 20400, 20401, 20402, 20403, 20404, 20405, 20406, 20407, 20408, 20409, 20410, 20411, 20412, 20413, 20414, 20415, 20416, 20417, 20418, 20419, 20420, 20421, 20422, 20423, 20424]
def PRE_first_tail_x8_r0_body.cnS111 : List Nat := List.range' 17474 27
def PRE_first_tail_x8_r0_body.ciS111 : List Nat := [] ++ List.range' 17474 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0111 : PRE_first_tail_x8_r0_body.kd111.nh0 = PRE_first_tail_x8_r0_body.cx0_111.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1111 : PRE_first_tail_x8_r0_body.kd111.nh1 = PRE_first_tail_x8_r0_body.cx1_111.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0111 : PRE_first_tail_x8_r0_body.kd111.nn0 = PRE_first_tail_x8_r0_body.cx0_111.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1111 : PRE_first_tail_x8_r0_body.kd111.nn1 = PRE_first_tail_x8_r0_body.cx1_111.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo111 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P111.lo && Nat.ble PRE_first_tail_x8_r0_body.P111.lo PRE_first_tail_x8_r0_body.cx0_111.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P111.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P111.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt111 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_111.mlx.next PRE_first_tail_x8_r0_body.cx1_111.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_111.mlx.nnext PRE_first_tail_x8_r0_body.cx1_111.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband111 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P111.NL && Nat.ble PRE_first_tail_x8_r0_body.P111.NL PRE_first_tail_x8_r0_body.P111.N0 && Nat.ble PRE_first_tail_x8_r0_body.P111.N0 PRE_first_tail_x8_r0_body.cx0_111.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow111 : PRE_first_tail_x8_r0_body.kd111.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren111 : checkRenG PRE_first_tail_x8_r0_body.kd111.hnd PRE_first_tail_x8_r0_body.khinv111 (phB PRE_first_tail_x8_r0_body.cx0_111.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband111 : PRE_first_tail_x8_r0_body.kd111.checkBand PRE_first_tail_x8_r0_body.P111.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos111 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd111.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren111 : checkRenG PRE_first_tail_x8_r0_body.kd111.node PRE_first_tail_x8_r0_body.kninv111 (pnB PRE_first_tail_x8_r0_body.cx0_111.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow111 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd111.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P111.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd111.nodeF j) PRE_first_tail_x8_r0_body.cx1_111.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a111 : PRE_first_tail_x8_r0_body.cx0_111.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b111 : PRE_first_tail_x8_r0_body.cx0_111.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1111 : PRE_first_tail_x8_r0_body.cx1_111.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend111 : PRE_first_tail_x8_r0_body.cx1_111.mlx.pending = PRE_first_tail_x8_r0_body.cx0_111.mlx.pending.map PRE_first_tail_x8_r0_body.kappa111.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh111 : PRE_first_tail_x8_r0_body.cx1_111.mlx.errh = PRE_first_tail_x8_r0_body.cx0_111.mlx.errh.map PRE_first_tail_x8_r0_body.kappa111.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles111 : PRE_first_tail_x8_r0_body.cx1_111.mlx.files = PRE_first_tail_x8_r0_body.cx0_111.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch111 : PRE_first_tail_x8_r0_body.cx1_111.mlx.arch = PRE_first_tail_x8_r0_body.cx0_111.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes111 : PRE_first_tail_x8_r0_body.cx1_111.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_111.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired111 : PRE_first_tail_x8_r0_body.cx1_111.mlx.wired = PRE_first_tail_x8_r0_body.cx0_111.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost111 : PRE_first_tail_x8_r0_body.cx1_111.host = PRE_first_tail_x8_r0_body.cx0_111.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd111`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0111 : PRE_first_tail_x8_r0_body.kd111.n0 = 2762473
kernel_rfl PRE_first_tail_x8_r0_body.ckn1111 : PRE_first_tail_x8_r0_body.kd111.n1 = 2763622
kernel_rfl PRE_first_tail_x8_r0_body.ckheap111 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd111.heap).all (fun x => Nat.ble 2762467 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl111 : (List.range 6).all (fun j => decide (PRE_first_tail_x8_r0_body.kd111.heap.get (2762467 + j) = nth? PRE_first_tail_x8_r0_body.pl111 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja111 : Nat.ble 2762467 2762467 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn111 : Nat.ble 4829 4829 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD111 : Nat.ble 2762467 PRE_first_tail_x8_r0_body.kd111.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn111 : Nat.ble 20397 PRE_first_tail_x8_r0_body.kd111.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn111 : Nat.ble 17474 PRE_first_tail_x8_r0_body.kd111.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb111 : Nat.ble 20397 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap111 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd111.heap).all (Nat.ble (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd111 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd111.hnd).all (Nat.ble (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode111 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd111.node).all (Nat.ble (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix111 : Conv.FixOld (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa111 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja111) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn111) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD111) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn111) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn111) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb111) PRE_first_tail_x8_r0_body.fheap111 PRE_first_tail_x8_r0_body.fhnd111 PRE_first_tail_x8_r0_body.fnode111
kernel_rfl PRE_first_tail_x8_r0_body.fcxn111 : (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn111 : (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0111 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_111.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_111.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk111 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd111.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A111 : PRE_first_tail_x8_r0_body.cx1_111.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS111.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_111.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O111 : PRE_first_tail_x8_r0_body.cx1_111.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS111.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_111.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N111 : PRE_first_tail_x8_r0_body.cx1_111.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS111.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_111.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I111 : PRE_first_tail_x8_r0_body.cx1_111.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS111.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_111.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd111 : (PRE_first_tail_x8_r0_body.clo111 ++ PRE_first_tail_x8_r0_body.cln111 ++ PRE_first_tail_x8_r0_body.cli111 ++ PRE_first_tail_x8_r0_body.cwS111 ++ PRE_first_tail_x8_r0_body.cnS111 ++ PRE_first_tail_x8_r0_body.ciS111).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW111 : PRE_first_tail_x8_r0_body.cwS111.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo111.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI111 : PRE_first_tail_x8_r0_body.ciS111.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli111.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN111 : PRE_first_tail_x8_r0_body.cnS111.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF111 : PRE_first_tail_x8_r0_body.cln111.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh111 : PRE_first_tail_x8_r0_body.clo111.all (handleOK PRE_first_tail_x8_r0_body.kappa111 PRE_first_tail_x8_r0_body.P111.lo PRE_first_tail_x8_r0_body.cx0_111.mlx PRE_first_tail_x8_r0_body.cx1_111.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo111 : PRE_first_tail_x8_r0_body.clo111.map (fun h => PRE_first_tail_x8_r0_body.cx1_111.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa111.handle h)) = PRE_first_tail_x8_r0_body.clo111.map (fun h => (PRE_first_tail_x8_r0_body.cx0_111.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa111.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok111 : PRE_first_tail_x8_r0_body.clo111.all (objOK PRE_first_tail_x8_r0_body.kappa111 PRE_first_tail_x8_r0_body.P111.NL PRE_first_tail_x8_r0_body.cx0_111.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd111 : PRE_first_tail_x8_r0_body.cln111.all (nodeOKF PRE_first_tail_x8_r0_body.kappa111 PRE_first_tail_x8_r0_body.P111 PRE_first_tail_x8_r0_body.cx0_111.mlx PRE_first_tail_x8_r0_body.cx1_111.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp111 : ((PRE_first_tail_x8_r0_body.cln111.filter (fullB PRE_first_tail_x8_r0_body.P111))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_111.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa111.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln111.filter (fullB PRE_first_tail_x8_r0_body.P111))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_111.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa111.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI111 : incrB PRE_first_tail_x8_r0_body.kd111.nodeF (List.range' 17474 27) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK111 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd111.node).all (fun k => Nat.ble 17474 k && Nat.blt k 17501) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL111 : (PRE_first_tail_x8_r0_body.cln111.filter (Nat.ble PRE_first_tail_x8_r0_body.P111.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd111.nodeF i) && (Nat.blt i 17501 || Nat.ble PRE_first_tail_x8_r0_body.kd111.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord111 : (PRE_first_tail_x8_r0_body.cln111.filter (Nat.ble PRE_first_tail_x8_r0_body.P111.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd111.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd111.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd111.nodeF j) (PRE_first_tail_x8_r0_body.kd111.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow111 PRE_first_tail_x8_r0_body.cnn1111 PRE_first_tail_x8_r0_body.fnordI111 PRE_first_tail_x8_r0_body.fnordK111 PRE_first_tail_x8_r0_body.fnordL111
kernel_rfl PRE_first_tail_x8_r0_body.fi111 : PRE_first_tail_x8_r0_body.cli111.all (pnB PRE_first_tail_x8_r0_body.cx0_111.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii111 : PRE_first_tail_x8_r0_body.cli111.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_111.mlx.items.get (PRE_first_tail_x8_r0_body.kappa111.node k) = (PRE_first_tail_x8_r0_body.cx0_111.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa111.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot111 (clean : Conv.NClean (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P111.NL) (cl : SSt (· < 4847) PRE_first_tail_x8_r0_body.cx0_111.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P111 4847 PRE_first_tail_x8_r0_body.kappa111 PRE_first_tail_x8_r0_body.kd111 PRE_first_tail_x8_r0_body.khinv111 PRE_first_tail_x8_r0_body.kninv111 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx PRE_first_tail_x8_r0_body.cx0_111.mlx PRE_first_tail_x8_r0_body.cx1_111.mlx (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo111 PRE_first_tail_x8_r0_body.cln111 PRE_first_tail_x8_r0_body.cli111 PRE_first_tail_x8_r0_body.cwS111 PRE_first_tail_x8_r0_body.cnS111 PRE_first_tail_x8_r0_body.ciS111 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0111, PRE_first_tail_x8_r0_body.cnh1111, PRE_first_tail_x8_r0_body.cnn0111, PRE_first_tail_x8_r0_body.cnn1111, PRE_first_tail_x8_r0_body.cplo111, PRE_first_tail_x8_r0_body.ccnt111, PRE_first_tail_x8_r0_body.cnband111, PRE_first_tail_x8_r0_body.chbelow111, PRE_first_tail_x8_r0_body.chren111, PRE_first_tail_x8_r0_body.cband111, PRE_first_tail_x8_r0_body.cnh1pos111, PRE_first_tail_x8_r0_body.cnren111, PRE_first_tail_x8_r0_body.cnlow111, PRE_first_tail_x8_r0_body.cabs0a111, PRE_first_tail_x8_r0_body.cabs0b111, PRE_first_tail_x8_r0_body.ctok1111, PRE_first_tail_x8_r0_body.cpend111, PRE_first_tail_x8_r0_body.cerrh111, PRE_first_tail_x8_r0_body.cfiles111, PRE_first_tail_x8_r0_body.carch111, PRE_first_tail_x8_r0_body.csizes111, PRE_first_tail_x8_r0_body.cwired111, PRE_first_tail_x8_r0_body.cfix111, clean, PRE_first_tail_x8_r0_body.fcxn111, PRE_first_tail_x8_r0_body.fcnn111, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0111, PRE_first_tail_x8_r0_body.fnk111, PRE_first_tail_x8_r0_body.ckA111, PRE_first_tail_x8_r0_body.cobjsK111, PRE_first_tail_x8_r0_body.cnodesK111, PRE_first_tail_x8_r0_body.citemsK111, PRE_first_tail_x8_r0_body.f1A111, PRE_first_tail_x8_r0_body.f1O111, PRE_first_tail_x8_r0_body.f1N111, PRE_first_tail_x8_r0_body.f1I111, PRE_first_tail_x8_r0_body.fbd111, PRE_first_tail_x8_r0_body.fincW111, PRE_first_tail_x8_r0_body.fincI111, PRE_first_tail_x8_r0_body.fincN111, PRE_first_tail_x8_r0_body.flnF111, PRE_first_tail_x8_r0_body.fh111, PRE_first_tail_x8_r0_body.fo111, PRE_first_tail_x8_r0_body.fok111, PRE_first_tail_x8_r0_body.fnd111, PRE_first_tail_x8_r0_body.fp111, PRE_first_tail_x8_r0_body.fnord111, PRE_first_tail_x8_r0_body.fi111, PRE_first_tail_x8_r0_body.fii111⟩
theorem PRE_first_tail_x8_r0_body.cnshift111 (clean : Conv.NClean (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P111.NL) (cl : SSt (· < 4847) PRE_first_tail_x8_r0_body.cx0_111.mlx) : NShift PRE_first_tail_x8_r0_body.P111 4847 PRE_first_tail_x8_r0_body.kappa111 PRE_first_tail_x8_r0_body.cx0_111 PRE_first_tail_x8_r0_body.cx1_111 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot111 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost111 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0111 PRE_first_tail_x8_r0_body.ckn1111 PRE_first_tail_x8_r0_body.ckheap111 PRE_first_tail_x8_r0_body.ckpl111)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_111 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1080.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_111 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1080.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_111 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1080.ffi) = some PRE_first_tail_x8_r0_body.fxC_111
kernel_rfl PRE_first_tail_x8_r0_body.okrC_111 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1080.ffi) = some PRE_first_tail_x8_r0_body.krC_111
noncomputable def PRE_first_tail_x8_r0_body.fx0_111 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1082.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_111 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1082.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_111 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1082.ffi) = some PRE_first_tail_x8_r0_body.fx0_111
kernel_rfl PRE_first_tail_x8_r0_body.okr0_111 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1082.ffi) = some PRE_first_tail_x8_r0_body.kr0_111
noncomputable def PRE_first_tail_x8_r0_body.fx1_111 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1081.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_111 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1081.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_111 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1081.ffi) = some PRE_first_tail_x8_r0_body.fx1_111
kernel_rfl PRE_first_tail_x8_r0_body.okr1_111 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1081.ffi) = some PRE_first_tail_x8_r0_body.kr1_111
kernel_rfl PRE_first_tail_x8_r0_body.ff0111 : PRE_first_tail_x8_r0_body.fx0_111 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_111 (PRE_first_tail_x8_r0_body.clo111.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_111.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1111 : PRE_first_tail_x8_r0_body.fx1_111 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_111 (PRE_first_tail_x8_r0_body.cwS111.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_111.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck111 : freedLB PRE_first_tail_x8_r0_body.kappa111 PRE_first_tail_x8_r0_body.cx0_111.mlx PRE_first_tail_x8_r0_body.fx0_111 PRE_first_tail_x8_r0_body.fx1_111 PRE_first_tail_x8_r0_body.clo111 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0111 : PRE_first_tail_x8_r0_body.kr0_111.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_111.flags (PRE_first_tail_x8_r0_body.clo111.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_111.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0111 : PRE_first_tail_x8_r0_body.kr0_111.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_111.targs (PRE_first_tail_x8_r0_body.clo111.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_111.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1111 : PRE_first_tail_x8_r0_body.kr1_111.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_111.flags (PRE_first_tail_x8_r0_body.cwS111.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_111.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1111 : PRE_first_tail_x8_r0_body.kr1_111.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_111.targs (PRE_first_tail_x8_r0_body.cwS111.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_111.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck111 : krecLB PRE_first_tail_x8_r0_body.kappa111 4847 PRE_first_tail_x8_r0_body.cx0_111.mlx PRE_first_tail_x8_r0_body.kr0_111 PRE_first_tail_x8_r0_body.kr1_111 PRE_first_tail_x8_r0_body.clo111 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn111 : Nat.ble 4829 4847 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge111 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1081.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1082.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR111 : pendRegB PRE_first_tail_x8_r0_body.kappa111 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1082.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe111 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1082.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1081.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift111 (clean : Conv.NClean (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P111.NL) (cl : SSt (· < 4847) PRE_first_tail_x8_r0_body.cx0_111.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_111.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_111.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_111.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1080.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_111.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P111 4847 PRE_first_tail_x8_r0_body.kappa111 PRE_first_tail_x8_r0_body.s1082.ffi PRE_first_tail_x8_r0_body.s1081.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift111 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue111, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp111 t ht),
    PRE_first_tail_x8_r0_body.cbridge111,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1082.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1081.ffi) (PRE_first_tail_x8_r0_body.cfoot111 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_111 PRE_first_tail_x8_r0_body.ofx1_111 hobjC PRE_first_tail_x8_r0_body.ff0111 PRE_first_tail_x8_r0_body.ff1111 PRE_first_tail_x8_r0_body.ffck111,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1082.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1081.ffi) (PRE_first_tail_x8_r0_body.cfoot111 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_111 PRE_first_tail_x8_r0_body.okr1_111 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn111) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0111 PRE_first_tail_x8_r0_body.fkt0111 PRE_first_tail_x8_r0_body.fkf1111 PRE_first_tail_x8_r0_body.fkt1111 PRE_first_tail_x8_r0_body.fkck111,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0111 PRE_first_tail_x8_r0_body.cnh1111 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe111) PRE_first_tail_x8_r0_body.cpendR111⟩

end Host.Load.Run.Tpl
end

section -- st111/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st111 0
host_stream_state PRE_first_tail_x8_r0_body.st111 1
host_stream_state PRE_first_tail_x8_r0_body.st111 2
host_stream_state PRE_first_tail_x8_r0_body.st111 3
host_stream_state PRE_first_tail_x8_r0_body.st111 4
host_stream_state PRE_first_tail_x8_r0_body.st111 5
end Host.Load.Run.Tpl
end

section -- Site111
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 111 of chain `PRE_first_tail_x8_r0_body`: `ssmW__g111__g112` (`recurWindow`), the call state `PRE_first_tail_x8_r0_body.s1080`, the merged state `PRE_first_tail_x8_r0_body.s1081`,
the site template `PRE_first_tail_x8_r0_body.st111` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1082`: the merge.
The footprint's facts are in `SiteF111`, the compaction's in `SiteC111`, `SiteK111`, `SiteNa111`, `SiteNb111`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso111 : PRE_first_tail_x8_r0_body.st111.s0 = { PRE_first_tail_x8_r0_body.s1080 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs111 : List Frame := PRE_first_tail_x8_r0_body.s1080.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_111 : PRE_first_tail_x8_r0_body.S1080.tab.length = 4829
kernel_rfl PRE_first_tail_x8_r0_body.tab0_111 : PRE_first_tail_x8_r0_body.st111.S0.tab = PRE_first_tail_x8_r0_body.S1080.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws111 : List Nat := [2857, 2858, 2859, 2860, 2861, 2862, 2863, 2864, 2865, 2866, 2867, 2868, 2869, 2870, 2871, 2872, 2873, 2874, 2875, 2876, 2877, 2878, 2879, 2880, 2881, 2882, 2883, 2884, 2885, 2886, 2887]
kernel_rfl PRE_first_tail_x8_r0_body.fresh111 : (PRE_first_tail_x8_r0_body.S1080.tab.all fun e => PRE_first_tail_x8_r0_body.ws111.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1080.oracle.all fun q => PRE_first_tail_x8_r0_body.ws111.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab111 : PRE_first_tail_x8_r0_body.S1081.tab = PRE_first_tail_x8_r0_body.S1080.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws111
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen111 : PRE_first_tail_x8_r0_body.st111.S5.tab.length - PRE_first_tail_x8_r0_body.st111.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged111`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap111 : PRE_first_tail_x8_r0_body.s1081.heap = PRE_first_tail_x8_r0_body.st111.s5.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext111 : PRE_first_tail_x8_r0_body.s1081.next = PRE_first_tail_x8_r0_body.st111.s5.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl111 : PRE_first_tail_x8_r0_body.s1081.ctl = PRE_first_tail_x8_r0_body.st111.s5.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack111 : PRE_first_tail_x8_r0_body.s1081.stack = PRE_first_tail_x8_r0_body.st111.s5.stack ++ PRE_first_tail_x8_r0_body.s1080.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs111 : PRE_first_tail_x8_r0_body.s1081.jobs = PRE_first_tail_x8_r0_body.st111.s5.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi111 : PRE_first_tail_x8_r0_body.s1081.ffi = PRE_first_tail_x8_r0_body.st111.s5.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace111 : PRE_first_tail_x8_r0_body.s1081.trace = PRE_first_tail_x8_r0_body.st111.s5.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores111 : PRE_first_tail_x8_r0_body.s1081.stores = PRE_first_tail_x8_r0_body.st111.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD111
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 111 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived111 : PRE_first_tail_x8_r0_body.nr111.map (fun r => nth? PRE_first_tail_x8_r0_body.st111.S5.tab r) =
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
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo111 : PRE_first_tail_x8_r0_body.nr111.all (Nat.ble 4829) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj111 : PRE_first_tail_x8_r0_body.cws111.all (fun c => !PRE_first_tail_x8_r0_body.ws111.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ111 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws111 PRE_first_tail_x8_r0_body.crs111 PRE_first_tail_x8_r0_body.ws111

end Host.Load.Run.Tpl
end

section -- st111/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st111`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st111.wrR : List (Nat × Nat) := [(2672584, 2672585), (2761641, 2761642), (2762186, 2762187), (2762442, 2762443)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st111.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st111.s5.heap PRE_first_tail_x8_r0_body.st111.wrR ++ freshOf PRE_first_tail_x8_r0_body.st111.s5.heap PRE_first_tail_x8_r0_body.st111.s0.next PRE_first_tail_x8_r0_body.st111.s5.next
noncomputable def PRE_first_tail_x8_r0_body.st111.wr : List Nat := PRE_first_tail_x8_r0_body.st111.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st111.heapFoot : PRE_first_tail_x8_r0_body.st111.s5.heap = setAll PRE_first_tail_x8_r0_body.st111.s0.heap PRE_first_tail_x8_r0_body.st111.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st111.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st111.s0.next PRE_first_tail_x8_r0_body.st111.s5.next = true
theorem PRE_first_tail_x8_r0_body.st111.grows : PRE_first_tail_x8_r0_body.st111.s0.next ≤ PRE_first_tail_x8_r0_body.st111.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st111.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st111.wh : List Nat := [20377, 20390, 20396, 20397, 20398, 20399, 20400, 20401, 20402, 20403, 20404, 20405, 20406, 20407, 20408, 20409, 20410, 20411, 20412, 20413, 20414, 20415, 20416, 20417, 20418, 20419, 20420, 20421, 20422, 20423, 20424]
def PRE_first_tail_x8_r0_body.st111.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st111.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st111.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st111.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st111.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st111.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st111.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st111.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st111.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st111.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st111.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st111.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st111.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st111.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st111.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st111.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st111.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st111.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st111.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st111.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st111.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st111.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st111.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st111.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st111.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st111.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st111.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st111.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st111.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st111.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF111
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 111 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB111 : nodupT PRE_first_tail_x8_r0_body.st111.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup111 : PRE_first_tail_x8_r0_body.st111.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB111).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB111 : PRE_first_tail_x8_r0_body.st111.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound111 : ∀ b ∈ PRE_first_tail_x8_r0_body.st111.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB111 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr111 := PRE_first_tail_x8_r0_body.st111.s5.trace.take 120
kernel_rfl PRE_first_tail_x8_r0_body.traceEq111 : PRE_first_tail_x8_r0_body.st111.s5.trace = PRE_first_tail_x8_r0_body.trFr111 ++ PRE_first_tail_x8_r0_body.st111.s0.trace
theorem PRE_first_tail_x8_r0_body.trace111 : ∃ fr, PRE_first_tail_x8_r0_body.st111.s5.trace = fr ++ PRE_first_tail_x8_r0_body.st111.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq111⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide111 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB111 : (PRE_first_tail_x8_r0_body.wide111.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st111.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix111 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide111, WFix Map.id (Present PRE_first_tail_x8_r0_body.st111.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB111 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL111
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 111 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1081`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO111 : PRE_first_tail_x8_r0_body.st111.S0.oracle = PRE_first_tail_x8_r0_body.st111.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B111 : PRE_first_tail_x8_r0_body.st111.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st111.s0.next || (PRE_first_tail_x8_r0_body.st111.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot111 : Conv.StageFoot PRE_first_tail_x8_r0_body.st111.wr PRE_first_tail_x8_r0_body.st111.s0 PRE_first_tail_x8_r0_body.st111.s5 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st111.heapFoot PRE_first_tail_x8_r0_body.wrNodup111 PRE_first_tail_x8_r0_body.wrBound111 PRE_first_tail_x8_r0_body.wr0B111 PRE_first_tail_x8_r0_body.st111.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged111 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st111.F.S → PRE_first_tail_x8_r0_body.st111.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st111.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st111.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs111 PRE_first_tail_x8_r0_body.st111.wr PRE_first_tail_x8_r0_body.s1080 PRE_first_tail_x8_r0_body.st111.s5 PRE_first_tail_x8_r0_body.st111.s0
      PRE_first_tail_x8_r0_body.st111.s5.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st111.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1081 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso111 PRE_first_tail_x8_r0_body.stFoot111 PRE_first_tail_x8_r0_body.wrNodup111 PRE_first_tail_x8_r0_body.wrBound111 PRE_first_tail_x8_r0_body.trace111 PRE_first_tail_x8_r0_body.mheap111
    PRE_first_tail_x8_r0_body.mnext111 PRE_first_tail_x8_r0_body.mctl111 PRE_first_tail_x8_r0_body.mstack111 PRE_first_tail_x8_r0_body.mjobs111 PRE_first_tail_x8_r0_body.mffi111 PRE_first_tail_x8_r0_body.mtrace111 PRE_first_tail_x8_r0_body.mstores111 h

def PRE_first_tail_x8_r0_body.arrEl111_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE111_2665 : arrOf PRE_first_tail_x8_r0_body.s1081 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl111_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA111_2665 : isArrB PRE_first_tail_x8_r0_body.s1081 2665 = true
theorem PRE_first_tail_x8_r0_body.arr111_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1081.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl111_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE111_2665 PRE_first_tail_x8_r0_body.arrA111_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN111_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl111_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR111_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl111_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN111_2665

def PRE_first_tail_x8_r0_body.arrEl111_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE111_2673467 : arrOf PRE_first_tail_x8_r0_body.s1081 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl111_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA111_2673467 : isArrB PRE_first_tail_x8_r0_body.s1081 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr111_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1081.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl111_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE111_2673467 PRE_first_tail_x8_r0_body.arrA111_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN111_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl111_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR111_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl111_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN111_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k111 : isArrB PRE_first_tail_x8_r0_body.s1081 4910 = false
theorem PRE_first_tail_x8_r0_body.keep111 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1081 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k111 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr111_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl111_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ111
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 111 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1080`, the merged
state `PRE_first_tail_x8_r0_body.s1081`, the canonical state `PRE_first_tail_x8_r0_body.s1082`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl111 : PRE_first_tail_x8_r0_body.pl111.all (Nat.ble PRE_first_tail_x8_r0_body.s1080.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd111 : nodupT PRE_first_tail_x8_r0_body.pl111 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1111 : Nat.ble PRE_first_tail_x8_r0_body.s1080.next 2763622 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst111 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1080.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn111 : PRE_first_tail_x8_r0_body.s1082.next = PRE_first_tail_x8_r0_body.s1080.next + PRE_first_tail_x8_r0_body.pl111.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn111 : PRE_first_tail_x8_r0_body.s1081.next = 2763622
kernel_rfl PRE_first_tail_x8_r0_body.zgrow111 : Nat.ble PRE_first_tail_x8_r0_body.s1082.next PRE_first_tail_x8_r0_body.s1081.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh111 : PRE_first_tail_x8_r0_body.S1080.tab.all (fun e => PRE_first_tail_x8_r0_body.cws111.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd111 : nodupT PRE_first_tail_x8_r0_body.cws111 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi111 : PRE_first_tail_x8_r0_body.nr111.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1081.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt111 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1080.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg111_2665 : PRE_first_tail_x8_r0_body.s1082.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1082 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk111_2665 : (objOf PRE_first_tail_x8_r0_body.s1082 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm111_2665 : PRE_first_tail_x8_r0_body.s1081.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa111.obj (objOf PRE_first_tail_x8_r0_body.s1082 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1081 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg111_2673467 : PRE_first_tail_x8_r0_body.s1082.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1082 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk111_2673467 : (objOf PRE_first_tail_x8_r0_body.s1082 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm111_2673467 : PRE_first_tail_x8_r0_body.s1081.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa111.obj (objOf PRE_first_tail_x8_r0_body.s1082 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1081 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw111_4910 : (PRE_first_tail_x8_r0_body.s1082.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw111_2673472 : (PRE_first_tail_x8_r0_body.s1082.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw111_2673473 : (PRE_first_tail_x8_r0_body.s1082.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd111 : PRE_first_tail_x8_r0_body.cl111.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr111 : PRE_first_tail_x8_r0_body.st111.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1080.next || PRE_first_tail_x8_r0_body.cl111.contains b) = true
def PRE_first_tail_x8_r0_body.zl111 : List Nat := PRE_first_tail_x8_r0_body.cl111.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE111 : PRE_first_tail_x8_r0_body.zl111.map (fun a => PRE_first_tail_x8_r0_body.s1081.heap.get (PRE_first_tail_x8_r0_body.kappa111.a a)) = PRE_first_tail_x8_r0_body.zl111.map (fun a => (PRE_first_tail_x8_r0_body.s1082.heap.get a).map PRE_first_tail_x8_r0_body.kappa111.hobj)
theorem PRE_first_tail_x8_r0_body.zimg111 : HeapImg PRE_first_tail_x8_r0_body.kappa111 PRE_first_tail_x8_r0_body.s1082 PRE_first_tail_x8_r0_body.s1081 PRE_first_tail_x8_r0_body.zl111 := PRE_first_tail_x8_r0_body.zimgE111
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl111 : PRE_first_tail_x8_r0_body.s1081.ctl = PRE_first_tail_x8_r0_body.kappa111.ctl PRE_first_tail_x8_r0_body.s1082.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack111 : PRE_first_tail_x8_r0_body.s1081.stack = PRE_first_tail_x8_r0_body.s1082.stack.map PRE_first_tail_x8_r0_body.kappa111.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs111 : PRE_first_tail_x8_r0_body.s1081.jobs = PRE_first_tail_x8_r0_body.s1082.jobs.map PRE_first_tail_x8_r0_body.kappa111.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores111 : PRE_first_tail_x8_r0_body.s1081.stores = PRE_first_tail_x8_r0_body.kappa111.stores PRE_first_tail_x8_r0_body.s1082.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots111 : checkRootsSupp PRE_first_tail_x8_r0_body.s1082 4847 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC111 : PRE_first_tail_x8_r0_body.S1080.tab.length + PRE_first_tail_x8_r0_body.cws111.length = 4847
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap111 : PRE_first_tail_x8_r0_body.kappa111 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1080.next 2763622 PRE_first_tail_x8_r0_body.S1080.tab.length PRE_first_tail_x8_r0_body.pl111 (PRE_first_tail_x8_r0_body.nr111.map NumV.ref) PRE_first_tail_x8_r0_body.kd111.big
  PRE_first_tail_x8_r0_body.kd111.region PRE_first_tail_x8_r0_body.kd111.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin111 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1082.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc111 : Conv.jcleanListB (⟨20400, 17501, 2762473, 4847⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1082 PRE_first_tail_x8_r0_body.cl111 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB111 : noBigRootsP (fun i => !Conv.oldBigB (⟨20400, 17501, 2762473, 4847⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1082.trace PRE_first_tail_x8_r0_body.s1082 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm111 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 17474 = true
theorem PRE_first_tail_x8_r0_body.cjcl111 (h : Conv.JClean (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1080) : Conv.JClean (⟨20400, 17501, 2762473, 4847⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1082 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle111)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap111 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd111 a ha)) PRE_first_tail_x8_r0_body.zjc111

end Host.Load.Run.Tpl
end

section -- st111/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st111.bodyLast from PRE_first_tail_x8_r0_body.st111.s4 to PRE_first_tail_x8_r0_body.st111.s5 :
  interpS (step PRE_first_tail_x8_r0_body.st111.F PRE_first_tail_x8_r0_body.st111.s4).run PRE_first_tail_x8_r0_body.st111.S4 = some (PRE_first_tail_x8_r0_body.st111.s5, PRE_first_tail_x8_r0_body.st111.S5)
kernel_rfl PRE_first_tail_x8_r0_body.st111.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st111.s4.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st111.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st111.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st111/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st111.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st111.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st111.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st111.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st111.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st111.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st111.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st111.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st111.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st111.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st111.s0 PRE_first_tail_x8_r0_body.st111.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st111.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st111.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st111.s4 PRE_first_tail_x8_r0_body.st111.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st111/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st111.bodyK0F from PRE_first_tail_x8_r0_body.st111.s0 to PRE_first_tail_x8_r0_body.st111.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st111.F (PRE_first_tail_x8_r0_body.st111.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st111.ks 0).getD 0) PRE_first_tail_x8_r0_body.st111.s0 PRE_first_tail_x8_r0_body.st111.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st111.s1, PRE_first_tail_x8_r0_body.st111.S1)
theorem PRE_first_tail_x8_r0_body.st111.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st111.F (PRE_first_tail_x8_r0_body.st111.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st111.ks 0).getD 0) PRE_first_tail_x8_r0_body.st111.s0 PRE_first_tail_x8_r0_body.st111.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st111.s1, PRE_first_tail_x8_r0_body.st111.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st111.bodyOkLN_ok PRE_first_tail_x8_r0_body.st111.bodyK0F
end Host.Load.Run.Tpl
end

section -- st111/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st111.bodyK1F from PRE_first_tail_x8_r0_body.st111.s1 to PRE_first_tail_x8_r0_body.st111.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st111.F (PRE_first_tail_x8_r0_body.st111.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st111.ks 1).getD 0) PRE_first_tail_x8_r0_body.st111.s1 PRE_first_tail_x8_r0_body.st111.S1) = fun _ _ => some (PRE_first_tail_x8_r0_body.st111.s2, PRE_first_tail_x8_r0_body.st111.S2)
theorem PRE_first_tail_x8_r0_body.st111.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st111.F (PRE_first_tail_x8_r0_body.st111.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st111.ks 1).getD 0) PRE_first_tail_x8_r0_body.st111.s1 PRE_first_tail_x8_r0_body.st111.S1) = fun _ _ => some (PRE_first_tail_x8_r0_body.st111.s2, PRE_first_tail_x8_r0_body.st111.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st111.bodyOkLN_ok PRE_first_tail_x8_r0_body.st111.bodyK1F
end Host.Load.Run.Tpl
end

section -- st111/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st111.bodyK2F from PRE_first_tail_x8_r0_body.st111.s2 to PRE_first_tail_x8_r0_body.st111.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st111.F (PRE_first_tail_x8_r0_body.st111.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st111.ks 2).getD 0) PRE_first_tail_x8_r0_body.st111.s2 PRE_first_tail_x8_r0_body.st111.S2) = fun _ _ => some (PRE_first_tail_x8_r0_body.st111.s3, PRE_first_tail_x8_r0_body.st111.S3)
theorem PRE_first_tail_x8_r0_body.st111.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st111.F (PRE_first_tail_x8_r0_body.st111.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st111.ks 2).getD 0) PRE_first_tail_x8_r0_body.st111.s2 PRE_first_tail_x8_r0_body.st111.S2) = fun _ _ => some (PRE_first_tail_x8_r0_body.st111.s3, PRE_first_tail_x8_r0_body.st111.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st111.bodyOkLN_ok PRE_first_tail_x8_r0_body.st111.bodyK2F
end Host.Load.Run.Tpl
end

section -- st111/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st111.bodyK3F from PRE_first_tail_x8_r0_body.st111.s3 to PRE_first_tail_x8_r0_body.st111.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st111.F (PRE_first_tail_x8_r0_body.st111.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st111.ks 3).getD 0) PRE_first_tail_x8_r0_body.st111.s3 PRE_first_tail_x8_r0_body.st111.S3) = fun _ _ => some (PRE_first_tail_x8_r0_body.st111.s4, PRE_first_tail_x8_r0_body.st111.S4)
theorem PRE_first_tail_x8_r0_body.st111.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st111.F (PRE_first_tail_x8_r0_body.st111.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st111.ks 3).getD 0) PRE_first_tail_x8_r0_body.st111.s3 PRE_first_tail_x8_r0_body.st111.S3) = fun _ _ => some (PRE_first_tail_x8_r0_body.st111.s4, PRE_first_tail_x8_r0_body.st111.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st111.bodyOkLN_ok PRE_first_tail_x8_r0_body.st111.bodyK3F
end Host.Load.Run.Tpl
end

section -- st111/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st111.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st111.F (PRE_first_tail_x8_r0_body.st111.bodyOkL bytes rows) 11334 PRE_first_tail_x8_r0_body.st111.s0 PRE_first_tail_x8_r0_body.st111.S0 = some (PRE_first_tail_x8_r0_body.st111.s4, PRE_first_tail_x8_r0_body.st111.S4) :=
  runOk_trans PRE_first_tail_x8_r0_body.st111.F (PRE_first_tail_x8_r0_body.st111.bodyOkL bytes rows) ((((nth? PRE_first_tail_x8_r0_body.st111.ks 0).getD 0) + ((nth? PRE_first_tail_x8_r0_body.st111.ks 1).getD 0)) + ((nth? PRE_first_tail_x8_r0_body.st111.ks 2).getD 0)) ((nth? PRE_first_tail_x8_r0_body.st111.ks 3).getD 0) PRE_first_tail_x8_r0_body.st111.s0 PRE_first_tail_x8_r0_body.st111.s3 PRE_first_tail_x8_r0_body.st111.s4 PRE_first_tail_x8_r0_body.st111.S0 PRE_first_tail_x8_r0_body.st111.S3 PRE_first_tail_x8_r0_body.st111.S4 (runOk_trans PRE_first_tail_x8_r0_body.st111.F (PRE_first_tail_x8_r0_body.st111.bodyOkL bytes rows) (((nth? PRE_first_tail_x8_r0_body.st111.ks 0).getD 0) + ((nth? PRE_first_tail_x8_r0_body.st111.ks 1).getD 0)) ((nth? PRE_first_tail_x8_r0_body.st111.ks 2).getD 0) PRE_first_tail_x8_r0_body.st111.s0 PRE_first_tail_x8_r0_body.st111.s2 PRE_first_tail_x8_r0_body.st111.s3 PRE_first_tail_x8_r0_body.st111.S0 PRE_first_tail_x8_r0_body.st111.S2 PRE_first_tail_x8_r0_body.st111.S3 (runOk_trans PRE_first_tail_x8_r0_body.st111.F (PRE_first_tail_x8_r0_body.st111.bodyOkL bytes rows) ((nth? PRE_first_tail_x8_r0_body.st111.ks 0).getD 0) ((nth? PRE_first_tail_x8_r0_body.st111.ks 1).getD 0) PRE_first_tail_x8_r0_body.st111.s0 PRE_first_tail_x8_r0_body.st111.s1 PRE_first_tail_x8_r0_body.st111.s2 PRE_first_tail_x8_r0_body.st111.S0 PRE_first_tail_x8_r0_body.st111.S1 PRE_first_tail_x8_r0_body.st111.S2 ((congrFun (congrFun PRE_first_tail_x8_r0_body.st111.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x8_r0_body.st111.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x8_r0_body.st111.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x8_r0_body.st111.bodyK3 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st111.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st111.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st111.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st111.F (PRE_first_tail_x8_r0_body.st111.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st111.s0
  S0 := PRE_first_tail_x8_r0_body.st111.S0
  s1 := PRE_first_tail_x8_r0_body.st111.s4
  S1 := PRE_first_tail_x8_r0_body.st111.S4
  s2 := PRE_first_tail_x8_r0_body.st111.s5
  S2 := PRE_first_tail_x8_r0_body.st111.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st111.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st111.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st111.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st111.bodyHalt
  last := PRE_first_tail_x8_r0_body.st111.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st111.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC112
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 112 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1090` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa112` into the merged state
`PRE_first_tail_x8_r0_body.s1089`. -/

def PRE_first_tail_x8_r0_body.pl112 : List Nat := []
def PRE_first_tail_x8_r0_body.nr112 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd112 : RData :=
  ⟨2762963, 2762965, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20413, 20413, 17514, 17514, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa112 : Map :=
  Conv.Map.compact 2762963 2762965 4868 PRE_first_tail_x8_r0_body.pl112 (PRE_first_tail_x8_r0_body.nr112.map NumV.ref) PRE_first_tail_x8_r0_body.kd112.big
    PRE_first_tail_x8_r0_body.kd112.region PRE_first_tail_x8_r0_body.kd112.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws112 : List Nat := []
noncomputable def PRE_first_tail_x8_r0_body.crs112 : List SymE := PRE_first_tail_x8_r0_body.nr112.map fun r => (nth? PRE_first_tail_x8_r0_body.S1089.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta112 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws112 PRE_first_tail_x8_r0_body.crs112
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB112 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x8_r0_body.ctab112 : PRE_first_tail_x8_r0_body.S1090.tab = PRE_first_tail_x8_r0_body.S1088.tab ++ PRE_first_tail_x8_r0_body.cws112.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace112 : PRE_first_tail_x8_r0_body.s1090.trace = PRE_first_tail_x8_r0_body.s1088.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext112 : PRE_first_tail_x8_r0_body.s1090.next = 2762963
kernel_rfl PRE_first_tail_x8_r0_body.ccounters112 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1090.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1090.ffi).mlx.nnext) = (20413, 17514)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue112 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1089.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1090.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa112.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp112 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1090.ffi).mlx.tokens.all (bSN 4868) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean112 : Conv.cleanListB 20413 131072 (fun r => Nat.ble 81652 r) PRE_first_tail_x8_r0_body.s1090
    (PRE_first_tail_x8_r0_body.wrB112 ++ (List.range 0).map (2762963 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs112 : bigsOutB 20413 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1090.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK112
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl112`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl112 : List Nat := [2665, 2673467]
def PRE_first_tail_x8_r0_body.clo112 : List Nat := []
def PRE_first_tail_x8_r0_body.cln112 : List Nat := []
def PRE_first_tail_x8_r0_body.cli112 : List Nat := []
kernel_rfl PRE_first_tail_x8_r0_body.cheap112 : PRE_first_tail_x8_r0_body.s1090.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1088.heap (PRE_first_tail_x8_r0_body.cl112.filterMap fun a => (PRE_first_tail_x8_r0_body.s1090.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe112 : Nat.ble PRE_first_tail_x8_r0_body.s1088.next PRE_first_tail_x8_r0_body.s1090.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP112 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1088 PRE_first_tail_x8_r0_body.s1090 PRE_first_tail_x8_r0_body.cl112 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp112 : Conv.suppListB PRE_first_tail_x8_r0_body.s1090 4868 PRE_first_tail_x8_r0_body.cl112 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound112 : Conv.boundListB PRE_first_tail_x8_r0_body.s1090 PRE_first_tail_x8_r0_body.cl112 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK112 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1090.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln112.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1090.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK112 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1090.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo112.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1090.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK112 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1090.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli112.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1090.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst112 : Conv.sstListB 4868 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1090.ffi).mlx PRE_first_tail_x8_r0_body.cln112 PRE_first_tail_x8_r0_body.clo112 PRE_first_tail_x8_r0_body.cli112 = true

end Host.Load.Run.Tpl
end

section -- SiteCl112
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA112 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1090.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo112.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1090.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd112 : (PRE_first_tail_x8_r0_body.clo112 ++ PRE_first_tail_x8_r0_body.cln112 ++ PRE_first_tail_x8_r0_body.cli112).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle112 : Conv.Cnt.leB (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt) (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck112 : Conv.ncleanListB (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1090.ffi).mlx PRE_first_tail_x8_r0_body.clo112 PRE_first_tail_x8_r0_body.cln112 PRE_first_tail_x8_r0_body.cli112 = true
theorem PRE_first_tail_x8_r0_body.cncl112 (h : Conv.NClean (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx) : Conv.NClean (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1090.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle112 PRE_first_tail_x8_r0_body.ckA112 PRE_first_tail_x8_r0_body.cobjsK112 PRE_first_tail_x8_r0_body.cnodesK112 PRE_first_tail_x8_r0_body.citemsK112 PRE_first_tail_x8_r0_body.cbd112 PRE_first_tail_x8_r0_body.cck112

end Host.Load.Run.Tpl
end

section -- SiteS112
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 112 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc112 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P112 : LoadP := PRE_first_tail_x8_r0_body.Pc112.raise 17514
kernel_rfl PRE_first_tail_x8_r0_body.craise112 : Nat.ble PRE_first_tail_x8_r0_body.Pc112.N0 17514 = true
theorem PRE_first_tail_x8_r0_body.raised112 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc112 PRE_first_tail_x8_r0_body.P112 :=
  .inr ⟨17514, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise112, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_112 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1090.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_112 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1089.ffi)
def PRE_first_tail_x8_r0_body.khinv112 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x8_r0_body.kninv112 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS112 : List Nat := []
def PRE_first_tail_x8_r0_body.cnS112 : List Nat := List.range' 17514 0
def PRE_first_tail_x8_r0_body.ciS112 : List Nat := [] ++ List.range' 17514 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0112 : PRE_first_tail_x8_r0_body.kd112.nh0 = PRE_first_tail_x8_r0_body.cx0_112.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1112 : PRE_first_tail_x8_r0_body.kd112.nh1 = PRE_first_tail_x8_r0_body.cx1_112.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0112 : PRE_first_tail_x8_r0_body.kd112.nn0 = PRE_first_tail_x8_r0_body.cx0_112.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1112 : PRE_first_tail_x8_r0_body.kd112.nn1 = PRE_first_tail_x8_r0_body.cx1_112.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo112 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P112.lo && Nat.ble PRE_first_tail_x8_r0_body.P112.lo PRE_first_tail_x8_r0_body.cx0_112.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P112.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P112.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt112 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_112.mlx.next PRE_first_tail_x8_r0_body.cx1_112.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_112.mlx.nnext PRE_first_tail_x8_r0_body.cx1_112.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband112 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P112.NL && Nat.ble PRE_first_tail_x8_r0_body.P112.NL PRE_first_tail_x8_r0_body.P112.N0 && Nat.ble PRE_first_tail_x8_r0_body.P112.N0 PRE_first_tail_x8_r0_body.cx0_112.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow112 : PRE_first_tail_x8_r0_body.kd112.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren112 : checkRenG PRE_first_tail_x8_r0_body.kd112.hnd PRE_first_tail_x8_r0_body.khinv112 (phB PRE_first_tail_x8_r0_body.cx0_112.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband112 : PRE_first_tail_x8_r0_body.kd112.checkBand PRE_first_tail_x8_r0_body.P112.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos112 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd112.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren112 : checkRenG PRE_first_tail_x8_r0_body.kd112.node PRE_first_tail_x8_r0_body.kninv112 (pnB PRE_first_tail_x8_r0_body.cx0_112.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow112 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd112.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P112.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd112.nodeF j) PRE_first_tail_x8_r0_body.cx1_112.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a112 : PRE_first_tail_x8_r0_body.cx0_112.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b112 : PRE_first_tail_x8_r0_body.cx0_112.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1112 : PRE_first_tail_x8_r0_body.cx1_112.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend112 : PRE_first_tail_x8_r0_body.cx1_112.mlx.pending = PRE_first_tail_x8_r0_body.cx0_112.mlx.pending.map PRE_first_tail_x8_r0_body.kappa112.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh112 : PRE_first_tail_x8_r0_body.cx1_112.mlx.errh = PRE_first_tail_x8_r0_body.cx0_112.mlx.errh.map PRE_first_tail_x8_r0_body.kappa112.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles112 : PRE_first_tail_x8_r0_body.cx1_112.mlx.files = PRE_first_tail_x8_r0_body.cx0_112.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch112 : PRE_first_tail_x8_r0_body.cx1_112.mlx.arch = PRE_first_tail_x8_r0_body.cx0_112.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes112 : PRE_first_tail_x8_r0_body.cx1_112.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_112.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired112 : PRE_first_tail_x8_r0_body.cx1_112.mlx.wired = PRE_first_tail_x8_r0_body.cx0_112.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost112 : PRE_first_tail_x8_r0_body.cx1_112.host = PRE_first_tail_x8_r0_body.cx0_112.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd112`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0112 : PRE_first_tail_x8_r0_body.kd112.n0 = 2762963
kernel_rfl PRE_first_tail_x8_r0_body.ckn1112 : PRE_first_tail_x8_r0_body.kd112.n1 = 2762965
kernel_rfl PRE_first_tail_x8_r0_body.ckheap112 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd112.heap).all (fun x => Nat.ble 2762963 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl112 : (List.range 0).all (fun j => decide (PRE_first_tail_x8_r0_body.kd112.heap.get (2762963 + j) = nth? PRE_first_tail_x8_r0_body.pl112 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja112 : Nat.ble 2762963 2762963 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn112 : Nat.ble 4868 4868 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD112 : Nat.ble 2762963 PRE_first_tail_x8_r0_body.kd112.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn112 : Nat.ble 20413 PRE_first_tail_x8_r0_body.kd112.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn112 : Nat.ble 17514 PRE_first_tail_x8_r0_body.kd112.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb112 : Nat.ble 20413 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap112 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd112.heap).all (Nat.ble (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd112 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd112.hnd).all (Nat.ble (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode112 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd112.node).all (Nat.ble (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix112 : Conv.FixOld (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa112 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja112) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn112) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD112) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn112) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn112) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb112) PRE_first_tail_x8_r0_body.fheap112 PRE_first_tail_x8_r0_body.fhnd112 PRE_first_tail_x8_r0_body.fnode112
kernel_rfl PRE_first_tail_x8_r0_body.fcxn112 : (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn112 : (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0112 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_112.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_112.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk112 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd112.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A112 : PRE_first_tail_x8_r0_body.cx1_112.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS112.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_112.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O112 : PRE_first_tail_x8_r0_body.cx1_112.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS112.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_112.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N112 : PRE_first_tail_x8_r0_body.cx1_112.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS112.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_112.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I112 : PRE_first_tail_x8_r0_body.cx1_112.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS112.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_112.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd112 : (PRE_first_tail_x8_r0_body.clo112 ++ PRE_first_tail_x8_r0_body.cln112 ++ PRE_first_tail_x8_r0_body.cli112 ++ PRE_first_tail_x8_r0_body.cwS112 ++ PRE_first_tail_x8_r0_body.cnS112 ++ PRE_first_tail_x8_r0_body.ciS112).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW112 : PRE_first_tail_x8_r0_body.cwS112.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo112.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI112 : PRE_first_tail_x8_r0_body.ciS112.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli112.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN112 : PRE_first_tail_x8_r0_body.cnS112.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF112 : PRE_first_tail_x8_r0_body.cln112.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh112 : PRE_first_tail_x8_r0_body.clo112.all (handleOK PRE_first_tail_x8_r0_body.kappa112 PRE_first_tail_x8_r0_body.P112.lo PRE_first_tail_x8_r0_body.cx0_112.mlx PRE_first_tail_x8_r0_body.cx1_112.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo112 : PRE_first_tail_x8_r0_body.clo112.map (fun h => PRE_first_tail_x8_r0_body.cx1_112.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa112.handle h)) = PRE_first_tail_x8_r0_body.clo112.map (fun h => (PRE_first_tail_x8_r0_body.cx0_112.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa112.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok112 : PRE_first_tail_x8_r0_body.clo112.all (objOK PRE_first_tail_x8_r0_body.kappa112 PRE_first_tail_x8_r0_body.P112.NL PRE_first_tail_x8_r0_body.cx0_112.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd112 : PRE_first_tail_x8_r0_body.cln112.all (nodeOKF PRE_first_tail_x8_r0_body.kappa112 PRE_first_tail_x8_r0_body.P112 PRE_first_tail_x8_r0_body.cx0_112.mlx PRE_first_tail_x8_r0_body.cx1_112.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp112 : ((PRE_first_tail_x8_r0_body.cln112.filter (fullB PRE_first_tail_x8_r0_body.P112))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_112.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa112.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln112.filter (fullB PRE_first_tail_x8_r0_body.P112))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_112.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa112.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI112 : incrB PRE_first_tail_x8_r0_body.kd112.nodeF (List.range' 17514 0) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK112 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd112.node).all (fun k => Nat.ble 17514 k && Nat.blt k 17514) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL112 : (PRE_first_tail_x8_r0_body.cln112.filter (Nat.ble PRE_first_tail_x8_r0_body.P112.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd112.nodeF i) && (Nat.blt i 17514 || Nat.ble PRE_first_tail_x8_r0_body.kd112.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord112 : (PRE_first_tail_x8_r0_body.cln112.filter (Nat.ble PRE_first_tail_x8_r0_body.P112.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd112.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd112.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd112.nodeF j) (PRE_first_tail_x8_r0_body.kd112.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow112 PRE_first_tail_x8_r0_body.cnn1112 PRE_first_tail_x8_r0_body.fnordI112 PRE_first_tail_x8_r0_body.fnordK112 PRE_first_tail_x8_r0_body.fnordL112
kernel_rfl PRE_first_tail_x8_r0_body.fi112 : PRE_first_tail_x8_r0_body.cli112.all (pnB PRE_first_tail_x8_r0_body.cx0_112.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii112 : PRE_first_tail_x8_r0_body.cli112.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_112.mlx.items.get (PRE_first_tail_x8_r0_body.kappa112.node k) = (PRE_first_tail_x8_r0_body.cx0_112.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa112.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot112 (clean : Conv.NClean (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P112.NL) (cl : SSt (· < 4868) PRE_first_tail_x8_r0_body.cx0_112.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P112 4868 PRE_first_tail_x8_r0_body.kappa112 PRE_first_tail_x8_r0_body.kd112 PRE_first_tail_x8_r0_body.khinv112 PRE_first_tail_x8_r0_body.kninv112 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx PRE_first_tail_x8_r0_body.cx0_112.mlx PRE_first_tail_x8_r0_body.cx1_112.mlx (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo112 PRE_first_tail_x8_r0_body.cln112 PRE_first_tail_x8_r0_body.cli112 PRE_first_tail_x8_r0_body.cwS112 PRE_first_tail_x8_r0_body.cnS112 PRE_first_tail_x8_r0_body.ciS112 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0112, PRE_first_tail_x8_r0_body.cnh1112, PRE_first_tail_x8_r0_body.cnn0112, PRE_first_tail_x8_r0_body.cnn1112, PRE_first_tail_x8_r0_body.cplo112, PRE_first_tail_x8_r0_body.ccnt112, PRE_first_tail_x8_r0_body.cnband112, PRE_first_tail_x8_r0_body.chbelow112, PRE_first_tail_x8_r0_body.chren112, PRE_first_tail_x8_r0_body.cband112, PRE_first_tail_x8_r0_body.cnh1pos112, PRE_first_tail_x8_r0_body.cnren112, PRE_first_tail_x8_r0_body.cnlow112, PRE_first_tail_x8_r0_body.cabs0a112, PRE_first_tail_x8_r0_body.cabs0b112, PRE_first_tail_x8_r0_body.ctok1112, PRE_first_tail_x8_r0_body.cpend112, PRE_first_tail_x8_r0_body.cerrh112, PRE_first_tail_x8_r0_body.cfiles112, PRE_first_tail_x8_r0_body.carch112, PRE_first_tail_x8_r0_body.csizes112, PRE_first_tail_x8_r0_body.cwired112, PRE_first_tail_x8_r0_body.cfix112, clean, PRE_first_tail_x8_r0_body.fcxn112, PRE_first_tail_x8_r0_body.fcnn112, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0112, PRE_first_tail_x8_r0_body.fnk112, PRE_first_tail_x8_r0_body.ckA112, PRE_first_tail_x8_r0_body.cobjsK112, PRE_first_tail_x8_r0_body.cnodesK112, PRE_first_tail_x8_r0_body.citemsK112, PRE_first_tail_x8_r0_body.f1A112, PRE_first_tail_x8_r0_body.f1O112, PRE_first_tail_x8_r0_body.f1N112, PRE_first_tail_x8_r0_body.f1I112, PRE_first_tail_x8_r0_body.fbd112, PRE_first_tail_x8_r0_body.fincW112, PRE_first_tail_x8_r0_body.fincI112, PRE_first_tail_x8_r0_body.fincN112, PRE_first_tail_x8_r0_body.flnF112, PRE_first_tail_x8_r0_body.fh112, PRE_first_tail_x8_r0_body.fo112, PRE_first_tail_x8_r0_body.fok112, PRE_first_tail_x8_r0_body.fnd112, PRE_first_tail_x8_r0_body.fp112, PRE_first_tail_x8_r0_body.fnord112, PRE_first_tail_x8_r0_body.fi112, PRE_first_tail_x8_r0_body.fii112⟩
theorem PRE_first_tail_x8_r0_body.cnshift112 (clean : Conv.NClean (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P112.NL) (cl : SSt (· < 4868) PRE_first_tail_x8_r0_body.cx0_112.mlx) : NShift PRE_first_tail_x8_r0_body.P112 4868 PRE_first_tail_x8_r0_body.kappa112 PRE_first_tail_x8_r0_body.cx0_112 PRE_first_tail_x8_r0_body.cx1_112 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot112 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost112 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0112 PRE_first_tail_x8_r0_body.ckn1112 PRE_first_tail_x8_r0_body.ckheap112 PRE_first_tail_x8_r0_body.ckpl112)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_112 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1088.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_112 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1088.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_112 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1088.ffi) = some PRE_first_tail_x8_r0_body.fxC_112
kernel_rfl PRE_first_tail_x8_r0_body.okrC_112 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1088.ffi) = some PRE_first_tail_x8_r0_body.krC_112
noncomputable def PRE_first_tail_x8_r0_body.fx0_112 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1090.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_112 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1090.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_112 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1090.ffi) = some PRE_first_tail_x8_r0_body.fx0_112
kernel_rfl PRE_first_tail_x8_r0_body.okr0_112 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1090.ffi) = some PRE_first_tail_x8_r0_body.kr0_112
noncomputable def PRE_first_tail_x8_r0_body.fx1_112 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1089.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_112 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1089.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_112 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1089.ffi) = some PRE_first_tail_x8_r0_body.fx1_112
kernel_rfl PRE_first_tail_x8_r0_body.okr1_112 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1089.ffi) = some PRE_first_tail_x8_r0_body.kr1_112
kernel_rfl PRE_first_tail_x8_r0_body.ff0112 : PRE_first_tail_x8_r0_body.fx0_112 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_112 (PRE_first_tail_x8_r0_body.clo112.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_112.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1112 : PRE_first_tail_x8_r0_body.fx1_112 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_112 (PRE_first_tail_x8_r0_body.cwS112.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_112.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck112 : freedLB PRE_first_tail_x8_r0_body.kappa112 PRE_first_tail_x8_r0_body.cx0_112.mlx PRE_first_tail_x8_r0_body.fx0_112 PRE_first_tail_x8_r0_body.fx1_112 PRE_first_tail_x8_r0_body.clo112 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0112 : PRE_first_tail_x8_r0_body.kr0_112.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_112.flags (PRE_first_tail_x8_r0_body.clo112.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_112.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0112 : PRE_first_tail_x8_r0_body.kr0_112.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_112.targs (PRE_first_tail_x8_r0_body.clo112.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_112.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1112 : PRE_first_tail_x8_r0_body.kr1_112.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_112.flags (PRE_first_tail_x8_r0_body.cwS112.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_112.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1112 : PRE_first_tail_x8_r0_body.kr1_112.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_112.targs (PRE_first_tail_x8_r0_body.cwS112.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_112.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck112 : krecLB PRE_first_tail_x8_r0_body.kappa112 4868 PRE_first_tail_x8_r0_body.cx0_112.mlx PRE_first_tail_x8_r0_body.kr0_112 PRE_first_tail_x8_r0_body.kr1_112 PRE_first_tail_x8_r0_body.clo112 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn112 : Nat.ble 4868 4868 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge112 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1089.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1090.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR112 : pendRegB PRE_first_tail_x8_r0_body.kappa112 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1090.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe112 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1090.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1089.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift112 (clean : Conv.NClean (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P112.NL) (cl : SSt (· < 4868) PRE_first_tail_x8_r0_body.cx0_112.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_112.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_112.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_112.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1088.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_112.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P112 4868 PRE_first_tail_x8_r0_body.kappa112 PRE_first_tail_x8_r0_body.s1090.ffi PRE_first_tail_x8_r0_body.s1089.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift112 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue112, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp112 t ht),
    PRE_first_tail_x8_r0_body.cbridge112,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1090.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1089.ffi) (PRE_first_tail_x8_r0_body.cfoot112 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_112 PRE_first_tail_x8_r0_body.ofx1_112 hobjC PRE_first_tail_x8_r0_body.ff0112 PRE_first_tail_x8_r0_body.ff1112 PRE_first_tail_x8_r0_body.ffck112,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1090.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1089.ffi) (PRE_first_tail_x8_r0_body.cfoot112 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_112 PRE_first_tail_x8_r0_body.okr1_112 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn112) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0112 PRE_first_tail_x8_r0_body.fkt0112 PRE_first_tail_x8_r0_body.fkf1112 PRE_first_tail_x8_r0_body.fkt1112 PRE_first_tail_x8_r0_body.fkck112,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0112 PRE_first_tail_x8_r0_body.cnh1112 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe112) PRE_first_tail_x8_r0_body.cpendR112⟩

end Host.Load.Run.Tpl
end

section -- st112/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st112 0
host_stream_state PRE_first_tail_x8_r0_body.st112 1
host_stream_state PRE_first_tail_x8_r0_body.st112 2
end Host.Load.Run.Tpl
end

section -- Site112
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 112 of chain `PRE_first_tail_x8_r0_body`: `rowBlocks__g112__g113` (`rowBlocks`), the call state `PRE_first_tail_x8_r0_body.s1088`, the merged state `PRE_first_tail_x8_r0_body.s1089`,
the site template `PRE_first_tail_x8_r0_body.st112` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1090`: the merge.
The footprint's facts are in `SiteF112`, the compaction's in `SiteC112`, `SiteK112`, `SiteNa112`, `SiteNb112`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso112 : PRE_first_tail_x8_r0_body.st112.s0 = { PRE_first_tail_x8_r0_body.s1088 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs112 : List Frame := PRE_first_tail_x8_r0_body.s1088.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_112 : PRE_first_tail_x8_r0_body.S1088.tab.length = 4868
kernel_rfl PRE_first_tail_x8_r0_body.tab0_112 : PRE_first_tail_x8_r0_body.st112.S0.tab = PRE_first_tail_x8_r0_body.S1088.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws112 : List Nat := [2906, 2907]
kernel_rfl PRE_first_tail_x8_r0_body.fresh112 : (PRE_first_tail_x8_r0_body.S1088.tab.all fun e => PRE_first_tail_x8_r0_body.ws112.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1088.oracle.all fun q => PRE_first_tail_x8_r0_body.ws112.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab112 : PRE_first_tail_x8_r0_body.S1089.tab = PRE_first_tail_x8_r0_body.S1088.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws112
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen112 : PRE_first_tail_x8_r0_body.st112.S2.tab.length - PRE_first_tail_x8_r0_body.st112.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged112`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap112 : PRE_first_tail_x8_r0_body.s1089.heap = PRE_first_tail_x8_r0_body.st112.s2.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext112 : PRE_first_tail_x8_r0_body.s1089.next = PRE_first_tail_x8_r0_body.st112.s2.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl112 : PRE_first_tail_x8_r0_body.s1089.ctl = PRE_first_tail_x8_r0_body.st112.s2.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack112 : PRE_first_tail_x8_r0_body.s1089.stack = PRE_first_tail_x8_r0_body.st112.s2.stack ++ PRE_first_tail_x8_r0_body.s1088.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs112 : PRE_first_tail_x8_r0_body.s1089.jobs = PRE_first_tail_x8_r0_body.st112.s2.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi112 : PRE_first_tail_x8_r0_body.s1089.ffi = PRE_first_tail_x8_r0_body.st112.s2.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace112 : PRE_first_tail_x8_r0_body.s1089.trace = PRE_first_tail_x8_r0_body.st112.s2.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores112 : PRE_first_tail_x8_r0_body.s1089.stores = PRE_first_tail_x8_r0_body.st112.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD112
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 112 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived112 : PRE_first_tail_x8_r0_body.nr112.map (fun r => nth? PRE_first_tail_x8_r0_body.st112.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo112 : PRE_first_tail_x8_r0_body.nr112.all (Nat.ble 4868) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj112 : PRE_first_tail_x8_r0_body.cws112.all (fun c => !PRE_first_tail_x8_r0_body.ws112.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ112 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws112 PRE_first_tail_x8_r0_body.crs112 PRE_first_tail_x8_r0_body.ws112

end Host.Load.Run.Tpl
end

section -- st112/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st112`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st112.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st112.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st112.s2.heap PRE_first_tail_x8_r0_body.st112.wrR ++ freshOf PRE_first_tail_x8_r0_body.st112.s2.heap PRE_first_tail_x8_r0_body.st112.s0.next PRE_first_tail_x8_r0_body.st112.s2.next
noncomputable def PRE_first_tail_x8_r0_body.st112.wr : List Nat := PRE_first_tail_x8_r0_body.st112.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st112.heapFoot : PRE_first_tail_x8_r0_body.st112.s2.heap = setAll PRE_first_tail_x8_r0_body.st112.s0.heap PRE_first_tail_x8_r0_body.st112.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st112.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st112.s0.next PRE_first_tail_x8_r0_body.st112.s2.next = true
theorem PRE_first_tail_x8_r0_body.st112.grows : PRE_first_tail_x8_r0_body.st112.s0.next ≤ PRE_first_tail_x8_r0_body.st112.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st112.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st112.wh : List Nat := []
def PRE_first_tail_x8_r0_body.st112.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st112.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st112.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st112.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st112.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st112.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st112.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st112.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st112.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st112.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st112.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st112.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st112.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st112.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st112.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st112.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st112.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st112.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st112.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st112.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st112.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st112.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st112.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st112.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st112.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st112.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st112.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st112.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st112.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st112.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF112
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 112 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB112 : nodupT PRE_first_tail_x8_r0_body.st112.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup112 : PRE_first_tail_x8_r0_body.st112.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB112).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB112 : PRE_first_tail_x8_r0_body.st112.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound112 : ∀ b ∈ PRE_first_tail_x8_r0_body.st112.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB112 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr112 := PRE_first_tail_x8_r0_body.st112.s2.trace.take 0
kernel_rfl PRE_first_tail_x8_r0_body.traceEq112 : PRE_first_tail_x8_r0_body.st112.s2.trace = PRE_first_tail_x8_r0_body.trFr112 ++ PRE_first_tail_x8_r0_body.st112.s0.trace
theorem PRE_first_tail_x8_r0_body.trace112 : ∃ fr, PRE_first_tail_x8_r0_body.st112.s2.trace = fr ++ PRE_first_tail_x8_r0_body.st112.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq112⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide112 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB112 : (PRE_first_tail_x8_r0_body.wide112.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st112.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix112 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide112, WFix Map.id (Present PRE_first_tail_x8_r0_body.st112.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB112 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL112
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 112 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1089`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO112 : PRE_first_tail_x8_r0_body.st112.S0.oracle = PRE_first_tail_x8_r0_body.st112.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B112 : PRE_first_tail_x8_r0_body.st112.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st112.s0.next || (PRE_first_tail_x8_r0_body.st112.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot112 : Conv.StageFoot PRE_first_tail_x8_r0_body.st112.wr PRE_first_tail_x8_r0_body.st112.s0 PRE_first_tail_x8_r0_body.st112.s2 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st112.heapFoot PRE_first_tail_x8_r0_body.wrNodup112 PRE_first_tail_x8_r0_body.wrBound112 PRE_first_tail_x8_r0_body.wr0B112 PRE_first_tail_x8_r0_body.st112.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged112 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st112.F.S → PRE_first_tail_x8_r0_body.st112.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st112.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st112.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs112 PRE_first_tail_x8_r0_body.st112.wr PRE_first_tail_x8_r0_body.s1088 PRE_first_tail_x8_r0_body.st112.s2 PRE_first_tail_x8_r0_body.st112.s0
      PRE_first_tail_x8_r0_body.st112.s2.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st112.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1089 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso112 PRE_first_tail_x8_r0_body.stFoot112 PRE_first_tail_x8_r0_body.wrNodup112 PRE_first_tail_x8_r0_body.wrBound112 PRE_first_tail_x8_r0_body.trace112 PRE_first_tail_x8_r0_body.mheap112
    PRE_first_tail_x8_r0_body.mnext112 PRE_first_tail_x8_r0_body.mctl112 PRE_first_tail_x8_r0_body.mstack112 PRE_first_tail_x8_r0_body.mjobs112 PRE_first_tail_x8_r0_body.mffi112 PRE_first_tail_x8_r0_body.mtrace112 PRE_first_tail_x8_r0_body.mstores112 h

def PRE_first_tail_x8_r0_body.arrEl112_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE112_2665 : arrOf PRE_first_tail_x8_r0_body.s1089 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl112_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA112_2665 : isArrB PRE_first_tail_x8_r0_body.s1089 2665 = true
theorem PRE_first_tail_x8_r0_body.arr112_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1089.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl112_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE112_2665 PRE_first_tail_x8_r0_body.arrA112_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN112_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl112_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR112_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl112_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN112_2665

def PRE_first_tail_x8_r0_body.arrEl112_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE112_2673467 : arrOf PRE_first_tail_x8_r0_body.s1089 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl112_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA112_2673467 : isArrB PRE_first_tail_x8_r0_body.s1089 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr112_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1089.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl112_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE112_2673467 PRE_first_tail_x8_r0_body.arrA112_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN112_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl112_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR112_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl112_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN112_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k112 : isArrB PRE_first_tail_x8_r0_body.s1089 4910 = false
theorem PRE_first_tail_x8_r0_body.keep112 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1089 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k112 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr112_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl112_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ112
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 112 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1088`, the merged
state `PRE_first_tail_x8_r0_body.s1089`, the canonical state `PRE_first_tail_x8_r0_body.s1090`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl112 : PRE_first_tail_x8_r0_body.pl112.all (Nat.ble PRE_first_tail_x8_r0_body.s1088.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd112 : nodupT PRE_first_tail_x8_r0_body.pl112 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1112 : Nat.ble PRE_first_tail_x8_r0_body.s1088.next 2762965 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst112 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1088.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn112 : PRE_first_tail_x8_r0_body.s1090.next = PRE_first_tail_x8_r0_body.s1088.next + PRE_first_tail_x8_r0_body.pl112.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn112 : PRE_first_tail_x8_r0_body.s1089.next = 2762965
kernel_rfl PRE_first_tail_x8_r0_body.zgrow112 : Nat.ble PRE_first_tail_x8_r0_body.s1090.next PRE_first_tail_x8_r0_body.s1089.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh112 : PRE_first_tail_x8_r0_body.S1088.tab.all (fun e => PRE_first_tail_x8_r0_body.cws112.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd112 : nodupT PRE_first_tail_x8_r0_body.cws112 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi112 : PRE_first_tail_x8_r0_body.nr112.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1089.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt112 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1088.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg112_2665 : PRE_first_tail_x8_r0_body.s1090.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1090 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk112_2665 : (objOf PRE_first_tail_x8_r0_body.s1090 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm112_2665 : PRE_first_tail_x8_r0_body.s1089.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa112.obj (objOf PRE_first_tail_x8_r0_body.s1090 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1089 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg112_2673467 : PRE_first_tail_x8_r0_body.s1090.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1090 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk112_2673467 : (objOf PRE_first_tail_x8_r0_body.s1090 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm112_2673467 : PRE_first_tail_x8_r0_body.s1089.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa112.obj (objOf PRE_first_tail_x8_r0_body.s1090 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1089 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw112_4910 : (PRE_first_tail_x8_r0_body.s1090.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw112_2673472 : (PRE_first_tail_x8_r0_body.s1090.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw112_2673473 : (PRE_first_tail_x8_r0_body.s1090.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd112 : PRE_first_tail_x8_r0_body.cl112.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr112 : PRE_first_tail_x8_r0_body.st112.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1088.next || PRE_first_tail_x8_r0_body.cl112.contains b) = true
def PRE_first_tail_x8_r0_body.zl112 : List Nat := PRE_first_tail_x8_r0_body.cl112.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE112 : PRE_first_tail_x8_r0_body.zl112.map (fun a => PRE_first_tail_x8_r0_body.s1089.heap.get (PRE_first_tail_x8_r0_body.kappa112.a a)) = PRE_first_tail_x8_r0_body.zl112.map (fun a => (PRE_first_tail_x8_r0_body.s1090.heap.get a).map PRE_first_tail_x8_r0_body.kappa112.hobj)
theorem PRE_first_tail_x8_r0_body.zimg112 : HeapImg PRE_first_tail_x8_r0_body.kappa112 PRE_first_tail_x8_r0_body.s1090 PRE_first_tail_x8_r0_body.s1089 PRE_first_tail_x8_r0_body.zl112 := PRE_first_tail_x8_r0_body.zimgE112
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl112 : PRE_first_tail_x8_r0_body.s1089.ctl = PRE_first_tail_x8_r0_body.kappa112.ctl PRE_first_tail_x8_r0_body.s1090.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack112 : PRE_first_tail_x8_r0_body.s1089.stack = PRE_first_tail_x8_r0_body.s1090.stack.map PRE_first_tail_x8_r0_body.kappa112.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs112 : PRE_first_tail_x8_r0_body.s1089.jobs = PRE_first_tail_x8_r0_body.s1090.jobs.map PRE_first_tail_x8_r0_body.kappa112.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores112 : PRE_first_tail_x8_r0_body.s1089.stores = PRE_first_tail_x8_r0_body.kappa112.stores PRE_first_tail_x8_r0_body.s1090.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots112 : checkRootsSupp PRE_first_tail_x8_r0_body.s1090 4868 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC112 : PRE_first_tail_x8_r0_body.S1088.tab.length + PRE_first_tail_x8_r0_body.cws112.length = 4868
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap112 : PRE_first_tail_x8_r0_body.kappa112 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1088.next 2762965 PRE_first_tail_x8_r0_body.S1088.tab.length PRE_first_tail_x8_r0_body.pl112 (PRE_first_tail_x8_r0_body.nr112.map NumV.ref) PRE_first_tail_x8_r0_body.kd112.big
  PRE_first_tail_x8_r0_body.kd112.region PRE_first_tail_x8_r0_body.kd112.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin112 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1090.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc112 : Conv.jcleanListB (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1090 PRE_first_tail_x8_r0_body.cl112 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB112 : noBigRootsP (fun i => !Conv.oldBigB (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1090.trace PRE_first_tail_x8_r0_body.s1090 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm112 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 17514 = true
theorem PRE_first_tail_x8_r0_body.cjcl112 (h : Conv.JClean (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1088) : Conv.JClean (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1090 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle112)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap112 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd112 a ha)) PRE_first_tail_x8_r0_body.zjc112

end Host.Load.Run.Tpl
end

section -- st112/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st112.bodyLast from PRE_first_tail_x8_r0_body.st112.s1 to PRE_first_tail_x8_r0_body.st112.s2 :
  interpS (step PRE_first_tail_x8_r0_body.st112.F PRE_first_tail_x8_r0_body.st112.s1).run PRE_first_tail_x8_r0_body.st112.S1 = some (PRE_first_tail_x8_r0_body.st112.s2, PRE_first_tail_x8_r0_body.st112.S2)
kernel_rfl PRE_first_tail_x8_r0_body.st112.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st112.s1.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st112.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st112.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st112/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st112.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st112.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st112.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st112.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st112.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st112.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st112.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st112.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st112.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st112.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st112.s0 PRE_first_tail_x8_r0_body.st112.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st112.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st112.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st112.s1 PRE_first_tail_x8_r0_body.st112.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st112/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st112.bodyK0F from PRE_first_tail_x8_r0_body.st112.s0 to PRE_first_tail_x8_r0_body.st112.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st112.F (PRE_first_tail_x8_r0_body.st112.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st112.ks 0).getD 0) PRE_first_tail_x8_r0_body.st112.s0 PRE_first_tail_x8_r0_body.st112.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st112.s1, PRE_first_tail_x8_r0_body.st112.S1)
theorem PRE_first_tail_x8_r0_body.st112.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st112.F (PRE_first_tail_x8_r0_body.st112.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st112.ks 0).getD 0) PRE_first_tail_x8_r0_body.st112.s0 PRE_first_tail_x8_r0_body.st112.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st112.s1, PRE_first_tail_x8_r0_body.st112.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st112.bodyOkLN_ok PRE_first_tail_x8_r0_body.st112.bodyK0F
end Host.Load.Run.Tpl
end

section -- st112/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st112.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st112.F (PRE_first_tail_x8_r0_body.st112.bodyOkL bytes rows) 27 PRE_first_tail_x8_r0_body.st112.s0 PRE_first_tail_x8_r0_body.st112.S0 = some (PRE_first_tail_x8_r0_body.st112.s1, PRE_first_tail_x8_r0_body.st112.S1) :=
  (congrFun (congrFun PRE_first_tail_x8_r0_body.st112.bodyK0 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st112.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st112.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st112.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st112.F (PRE_first_tail_x8_r0_body.st112.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st112.s0
  S0 := PRE_first_tail_x8_r0_body.st112.S0
  s1 := PRE_first_tail_x8_r0_body.st112.s1
  S1 := PRE_first_tail_x8_r0_body.st112.S1
  s2 := PRE_first_tail_x8_r0_body.st112.s2
  S2 := PRE_first_tail_x8_r0_body.st112.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st112.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st112.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st112.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st112.bodyHalt
  last := PRE_first_tail_x8_r0_body.st112.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st112.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC113
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 113 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1094` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa113` into the merged state
`PRE_first_tail_x8_r0_body.s1093`. -/

def PRE_first_tail_x8_r0_body.pl113 : List Nat := [2763261]
def PRE_first_tail_x8_r0_body.nr113 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd113 : RData :=
  ⟨2763252, 2763262, Stage.setAll PTrie.nil [(2763251, 2763261)], Stage.setAll PTrie.nil [],
   20420, 20420, 17518, 17518, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa113 : Map :=
  Conv.Map.compact 2763251 2763262 4885 PRE_first_tail_x8_r0_body.pl113 (PRE_first_tail_x8_r0_body.nr113.map NumV.ref) PRE_first_tail_x8_r0_body.kd113.big
    PRE_first_tail_x8_r0_body.kd113.region PRE_first_tail_x8_r0_body.kd113.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws113 : List Nat := []
noncomputable def PRE_first_tail_x8_r0_body.crs113 : List SymE := PRE_first_tail_x8_r0_body.nr113.map fun r => (nth? PRE_first_tail_x8_r0_body.S1093.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta113 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws113 PRE_first_tail_x8_r0_body.crs113
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB113 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x8_r0_body.ctab113 : PRE_first_tail_x8_r0_body.S1094.tab = PRE_first_tail_x8_r0_body.S1092.tab ++ PRE_first_tail_x8_r0_body.cws113.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace113 : PRE_first_tail_x8_r0_body.s1094.trace = PRE_first_tail_x8_r0_body.s1092.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext113 : PRE_first_tail_x8_r0_body.s1094.next = 2763252
kernel_rfl PRE_first_tail_x8_r0_body.ccounters113 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1094.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1094.ffi).mlx.nnext) = (20420, 17518)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue113 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1093.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1094.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa113.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp113 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1094.ffi).mlx.tokens.all (bSN 4885) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean113 : Conv.cleanListB 20420 131072 (fun r => Nat.ble 81680 r) PRE_first_tail_x8_r0_body.s1094
    (PRE_first_tail_x8_r0_body.wrB113 ++ (List.range 1).map (2763251 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs113 : bigsOutB 20420 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1094.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK113
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl113`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl113 : List Nat := [2665, 2673467, 2763251]
def PRE_first_tail_x8_r0_body.clo113 : List Nat := []
def PRE_first_tail_x8_r0_body.cln113 : List Nat := []
def PRE_first_tail_x8_r0_body.cli113 : List Nat := []
kernel_rfl PRE_first_tail_x8_r0_body.cheap113 : PRE_first_tail_x8_r0_body.s1094.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1092.heap (PRE_first_tail_x8_r0_body.cl113.filterMap fun a => (PRE_first_tail_x8_r0_body.s1094.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe113 : Nat.ble PRE_first_tail_x8_r0_body.s1092.next PRE_first_tail_x8_r0_body.s1094.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP113 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1092 PRE_first_tail_x8_r0_body.s1094 PRE_first_tail_x8_r0_body.cl113 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp113 : Conv.suppListB PRE_first_tail_x8_r0_body.s1094 4885 PRE_first_tail_x8_r0_body.cl113 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound113 : Conv.boundListB PRE_first_tail_x8_r0_body.s1094 PRE_first_tail_x8_r0_body.cl113 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK113 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1094.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln113.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1094.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK113 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1094.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo113.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1094.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK113 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1094.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli113.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1094.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst113 : Conv.sstListB 4885 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1094.ffi).mlx PRE_first_tail_x8_r0_body.cln113 PRE_first_tail_x8_r0_body.clo113 PRE_first_tail_x8_r0_body.cli113 = true

end Host.Load.Run.Tpl
end

section -- SiteCl113
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA113 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1094.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo113.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1094.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd113 : (PRE_first_tail_x8_r0_body.clo113 ++ PRE_first_tail_x8_r0_body.cln113 ++ PRE_first_tail_x8_r0_body.cli113).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle113 : Conv.Cnt.leB (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt) (⟨20420, 17518, 2763252, 4885⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck113 : Conv.ncleanListB (⟨20420, 17518, 2763252, 4885⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1094.ffi).mlx PRE_first_tail_x8_r0_body.clo113 PRE_first_tail_x8_r0_body.cln113 PRE_first_tail_x8_r0_body.cli113 = true
theorem PRE_first_tail_x8_r0_body.cncl113 (h : Conv.NClean (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx) : Conv.NClean (⟨20420, 17518, 2763252, 4885⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1094.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle113 PRE_first_tail_x8_r0_body.ckA113 PRE_first_tail_x8_r0_body.cobjsK113 PRE_first_tail_x8_r0_body.cnodesK113 PRE_first_tail_x8_r0_body.citemsK113 PRE_first_tail_x8_r0_body.cbd113 PRE_first_tail_x8_r0_body.cck113

end Host.Load.Run.Tpl
end

section -- SiteS113
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 113 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc113 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P113 : LoadP := PRE_first_tail_x8_r0_body.Pc113.raise 17518
kernel_rfl PRE_first_tail_x8_r0_body.craise113 : Nat.ble PRE_first_tail_x8_r0_body.Pc113.N0 17518 = true
theorem PRE_first_tail_x8_r0_body.raised113 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc113 PRE_first_tail_x8_r0_body.P113 :=
  .inr ⟨17518, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise113, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_113 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1094.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_113 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1093.ffi)
def PRE_first_tail_x8_r0_body.khinv113 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x8_r0_body.kninv113 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS113 : List Nat := []
def PRE_first_tail_x8_r0_body.cnS113 : List Nat := List.range' 17518 0
def PRE_first_tail_x8_r0_body.ciS113 : List Nat := [] ++ List.range' 17518 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0113 : PRE_first_tail_x8_r0_body.kd113.nh0 = PRE_first_tail_x8_r0_body.cx0_113.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1113 : PRE_first_tail_x8_r0_body.kd113.nh1 = PRE_first_tail_x8_r0_body.cx1_113.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0113 : PRE_first_tail_x8_r0_body.kd113.nn0 = PRE_first_tail_x8_r0_body.cx0_113.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1113 : PRE_first_tail_x8_r0_body.kd113.nn1 = PRE_first_tail_x8_r0_body.cx1_113.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo113 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P113.lo && Nat.ble PRE_first_tail_x8_r0_body.P113.lo PRE_first_tail_x8_r0_body.cx0_113.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P113.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P113.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt113 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_113.mlx.next PRE_first_tail_x8_r0_body.cx1_113.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_113.mlx.nnext PRE_first_tail_x8_r0_body.cx1_113.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband113 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P113.NL && Nat.ble PRE_first_tail_x8_r0_body.P113.NL PRE_first_tail_x8_r0_body.P113.N0 && Nat.ble PRE_first_tail_x8_r0_body.P113.N0 PRE_first_tail_x8_r0_body.cx0_113.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow113 : PRE_first_tail_x8_r0_body.kd113.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren113 : checkRenG PRE_first_tail_x8_r0_body.kd113.hnd PRE_first_tail_x8_r0_body.khinv113 (phB PRE_first_tail_x8_r0_body.cx0_113.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband113 : PRE_first_tail_x8_r0_body.kd113.checkBand PRE_first_tail_x8_r0_body.P113.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos113 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd113.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren113 : checkRenG PRE_first_tail_x8_r0_body.kd113.node PRE_first_tail_x8_r0_body.kninv113 (pnB PRE_first_tail_x8_r0_body.cx0_113.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow113 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd113.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P113.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd113.nodeF j) PRE_first_tail_x8_r0_body.cx1_113.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a113 : PRE_first_tail_x8_r0_body.cx0_113.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b113 : PRE_first_tail_x8_r0_body.cx0_113.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1113 : PRE_first_tail_x8_r0_body.cx1_113.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend113 : PRE_first_tail_x8_r0_body.cx1_113.mlx.pending = PRE_first_tail_x8_r0_body.cx0_113.mlx.pending.map PRE_first_tail_x8_r0_body.kappa113.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh113 : PRE_first_tail_x8_r0_body.cx1_113.mlx.errh = PRE_first_tail_x8_r0_body.cx0_113.mlx.errh.map PRE_first_tail_x8_r0_body.kappa113.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles113 : PRE_first_tail_x8_r0_body.cx1_113.mlx.files = PRE_first_tail_x8_r0_body.cx0_113.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch113 : PRE_first_tail_x8_r0_body.cx1_113.mlx.arch = PRE_first_tail_x8_r0_body.cx0_113.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes113 : PRE_first_tail_x8_r0_body.cx1_113.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_113.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired113 : PRE_first_tail_x8_r0_body.cx1_113.mlx.wired = PRE_first_tail_x8_r0_body.cx0_113.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost113 : PRE_first_tail_x8_r0_body.cx1_113.host = PRE_first_tail_x8_r0_body.cx0_113.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd113`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0113 : PRE_first_tail_x8_r0_body.kd113.n0 = 2763252
kernel_rfl PRE_first_tail_x8_r0_body.ckn1113 : PRE_first_tail_x8_r0_body.kd113.n1 = 2763262
kernel_rfl PRE_first_tail_x8_r0_body.ckheap113 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd113.heap).all (fun x => Nat.ble 2763251 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl113 : (List.range 1).all (fun j => decide (PRE_first_tail_x8_r0_body.kd113.heap.get (2763251 + j) = nth? PRE_first_tail_x8_r0_body.pl113 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja113 : Nat.ble 2763251 2763251 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn113 : Nat.ble 4885 4885 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD113 : Nat.ble 2763251 PRE_first_tail_x8_r0_body.kd113.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn113 : Nat.ble 20420 PRE_first_tail_x8_r0_body.kd113.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn113 : Nat.ble 17518 PRE_first_tail_x8_r0_body.kd113.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb113 : Nat.ble 20420 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap113 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd113.heap).all (Nat.ble (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd113 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd113.hnd).all (Nat.ble (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode113 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd113.node).all (Nat.ble (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix113 : Conv.FixOld (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa113 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja113) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn113) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD113) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn113) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn113) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb113) PRE_first_tail_x8_r0_body.fheap113 PRE_first_tail_x8_r0_body.fhnd113 PRE_first_tail_x8_r0_body.fnode113
kernel_rfl PRE_first_tail_x8_r0_body.fcxn113 : (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn113 : (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0113 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_113.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_113.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk113 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd113.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A113 : PRE_first_tail_x8_r0_body.cx1_113.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS113.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_113.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O113 : PRE_first_tail_x8_r0_body.cx1_113.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS113.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_113.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N113 : PRE_first_tail_x8_r0_body.cx1_113.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS113.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_113.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I113 : PRE_first_tail_x8_r0_body.cx1_113.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS113.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_113.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd113 : (PRE_first_tail_x8_r0_body.clo113 ++ PRE_first_tail_x8_r0_body.cln113 ++ PRE_first_tail_x8_r0_body.cli113 ++ PRE_first_tail_x8_r0_body.cwS113 ++ PRE_first_tail_x8_r0_body.cnS113 ++ PRE_first_tail_x8_r0_body.ciS113).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW113 : PRE_first_tail_x8_r0_body.cwS113.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo113.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI113 : PRE_first_tail_x8_r0_body.ciS113.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli113.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN113 : PRE_first_tail_x8_r0_body.cnS113.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF113 : PRE_first_tail_x8_r0_body.cln113.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh113 : PRE_first_tail_x8_r0_body.clo113.all (handleOK PRE_first_tail_x8_r0_body.kappa113 PRE_first_tail_x8_r0_body.P113.lo PRE_first_tail_x8_r0_body.cx0_113.mlx PRE_first_tail_x8_r0_body.cx1_113.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo113 : PRE_first_tail_x8_r0_body.clo113.map (fun h => PRE_first_tail_x8_r0_body.cx1_113.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa113.handle h)) = PRE_first_tail_x8_r0_body.clo113.map (fun h => (PRE_first_tail_x8_r0_body.cx0_113.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa113.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok113 : PRE_first_tail_x8_r0_body.clo113.all (objOK PRE_first_tail_x8_r0_body.kappa113 PRE_first_tail_x8_r0_body.P113.NL PRE_first_tail_x8_r0_body.cx0_113.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd113 : PRE_first_tail_x8_r0_body.cln113.all (nodeOKF PRE_first_tail_x8_r0_body.kappa113 PRE_first_tail_x8_r0_body.P113 PRE_first_tail_x8_r0_body.cx0_113.mlx PRE_first_tail_x8_r0_body.cx1_113.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp113 : ((PRE_first_tail_x8_r0_body.cln113.filter (fullB PRE_first_tail_x8_r0_body.P113))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_113.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa113.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln113.filter (fullB PRE_first_tail_x8_r0_body.P113))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_113.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa113.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI113 : incrB PRE_first_tail_x8_r0_body.kd113.nodeF (List.range' 17518 0) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK113 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd113.node).all (fun k => Nat.ble 17518 k && Nat.blt k 17518) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL113 : (PRE_first_tail_x8_r0_body.cln113.filter (Nat.ble PRE_first_tail_x8_r0_body.P113.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd113.nodeF i) && (Nat.blt i 17518 || Nat.ble PRE_first_tail_x8_r0_body.kd113.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord113 : (PRE_first_tail_x8_r0_body.cln113.filter (Nat.ble PRE_first_tail_x8_r0_body.P113.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd113.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd113.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd113.nodeF j) (PRE_first_tail_x8_r0_body.kd113.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow113 PRE_first_tail_x8_r0_body.cnn1113 PRE_first_tail_x8_r0_body.fnordI113 PRE_first_tail_x8_r0_body.fnordK113 PRE_first_tail_x8_r0_body.fnordL113
kernel_rfl PRE_first_tail_x8_r0_body.fi113 : PRE_first_tail_x8_r0_body.cli113.all (pnB PRE_first_tail_x8_r0_body.cx0_113.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii113 : PRE_first_tail_x8_r0_body.cli113.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_113.mlx.items.get (PRE_first_tail_x8_r0_body.kappa113.node k) = (PRE_first_tail_x8_r0_body.cx0_113.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa113.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot113 (clean : Conv.NClean (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P113.NL) (cl : SSt (· < 4885) PRE_first_tail_x8_r0_body.cx0_113.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P113 4885 PRE_first_tail_x8_r0_body.kappa113 PRE_first_tail_x8_r0_body.kd113 PRE_first_tail_x8_r0_body.khinv113 PRE_first_tail_x8_r0_body.kninv113 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx PRE_first_tail_x8_r0_body.cx0_113.mlx PRE_first_tail_x8_r0_body.cx1_113.mlx (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo113 PRE_first_tail_x8_r0_body.cln113 PRE_first_tail_x8_r0_body.cli113 PRE_first_tail_x8_r0_body.cwS113 PRE_first_tail_x8_r0_body.cnS113 PRE_first_tail_x8_r0_body.ciS113 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0113, PRE_first_tail_x8_r0_body.cnh1113, PRE_first_tail_x8_r0_body.cnn0113, PRE_first_tail_x8_r0_body.cnn1113, PRE_first_tail_x8_r0_body.cplo113, PRE_first_tail_x8_r0_body.ccnt113, PRE_first_tail_x8_r0_body.cnband113, PRE_first_tail_x8_r0_body.chbelow113, PRE_first_tail_x8_r0_body.chren113, PRE_first_tail_x8_r0_body.cband113, PRE_first_tail_x8_r0_body.cnh1pos113, PRE_first_tail_x8_r0_body.cnren113, PRE_first_tail_x8_r0_body.cnlow113, PRE_first_tail_x8_r0_body.cabs0a113, PRE_first_tail_x8_r0_body.cabs0b113, PRE_first_tail_x8_r0_body.ctok1113, PRE_first_tail_x8_r0_body.cpend113, PRE_first_tail_x8_r0_body.cerrh113, PRE_first_tail_x8_r0_body.cfiles113, PRE_first_tail_x8_r0_body.carch113, PRE_first_tail_x8_r0_body.csizes113, PRE_first_tail_x8_r0_body.cwired113, PRE_first_tail_x8_r0_body.cfix113, clean, PRE_first_tail_x8_r0_body.fcxn113, PRE_first_tail_x8_r0_body.fcnn113, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0113, PRE_first_tail_x8_r0_body.fnk113, PRE_first_tail_x8_r0_body.ckA113, PRE_first_tail_x8_r0_body.cobjsK113, PRE_first_tail_x8_r0_body.cnodesK113, PRE_first_tail_x8_r0_body.citemsK113, PRE_first_tail_x8_r0_body.f1A113, PRE_first_tail_x8_r0_body.f1O113, PRE_first_tail_x8_r0_body.f1N113, PRE_first_tail_x8_r0_body.f1I113, PRE_first_tail_x8_r0_body.fbd113, PRE_first_tail_x8_r0_body.fincW113, PRE_first_tail_x8_r0_body.fincI113, PRE_first_tail_x8_r0_body.fincN113, PRE_first_tail_x8_r0_body.flnF113, PRE_first_tail_x8_r0_body.fh113, PRE_first_tail_x8_r0_body.fo113, PRE_first_tail_x8_r0_body.fok113, PRE_first_tail_x8_r0_body.fnd113, PRE_first_tail_x8_r0_body.fp113, PRE_first_tail_x8_r0_body.fnord113, PRE_first_tail_x8_r0_body.fi113, PRE_first_tail_x8_r0_body.fii113⟩
theorem PRE_first_tail_x8_r0_body.cnshift113 (clean : Conv.NClean (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P113.NL) (cl : SSt (· < 4885) PRE_first_tail_x8_r0_body.cx0_113.mlx) : NShift PRE_first_tail_x8_r0_body.P113 4885 PRE_first_tail_x8_r0_body.kappa113 PRE_first_tail_x8_r0_body.cx0_113 PRE_first_tail_x8_r0_body.cx1_113 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot113 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost113 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0113 PRE_first_tail_x8_r0_body.ckn1113 PRE_first_tail_x8_r0_body.ckheap113 PRE_first_tail_x8_r0_body.ckpl113)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_113 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1092.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_113 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1092.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_113 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1092.ffi) = some PRE_first_tail_x8_r0_body.fxC_113
kernel_rfl PRE_first_tail_x8_r0_body.okrC_113 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1092.ffi) = some PRE_first_tail_x8_r0_body.krC_113
noncomputable def PRE_first_tail_x8_r0_body.fx0_113 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1094.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_113 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1094.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_113 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1094.ffi) = some PRE_first_tail_x8_r0_body.fx0_113
kernel_rfl PRE_first_tail_x8_r0_body.okr0_113 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1094.ffi) = some PRE_first_tail_x8_r0_body.kr0_113
noncomputable def PRE_first_tail_x8_r0_body.fx1_113 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1093.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_113 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1093.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_113 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1093.ffi) = some PRE_first_tail_x8_r0_body.fx1_113
kernel_rfl PRE_first_tail_x8_r0_body.okr1_113 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1093.ffi) = some PRE_first_tail_x8_r0_body.kr1_113
kernel_rfl PRE_first_tail_x8_r0_body.ff0113 : PRE_first_tail_x8_r0_body.fx0_113 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_113 (PRE_first_tail_x8_r0_body.clo113.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_113.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1113 : PRE_first_tail_x8_r0_body.fx1_113 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_113 (PRE_first_tail_x8_r0_body.cwS113.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_113.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck113 : freedLB PRE_first_tail_x8_r0_body.kappa113 PRE_first_tail_x8_r0_body.cx0_113.mlx PRE_first_tail_x8_r0_body.fx0_113 PRE_first_tail_x8_r0_body.fx1_113 PRE_first_tail_x8_r0_body.clo113 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0113 : PRE_first_tail_x8_r0_body.kr0_113.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_113.flags (PRE_first_tail_x8_r0_body.clo113.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_113.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0113 : PRE_first_tail_x8_r0_body.kr0_113.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_113.targs (PRE_first_tail_x8_r0_body.clo113.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_113.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1113 : PRE_first_tail_x8_r0_body.kr1_113.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_113.flags (PRE_first_tail_x8_r0_body.cwS113.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_113.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1113 : PRE_first_tail_x8_r0_body.kr1_113.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_113.targs (PRE_first_tail_x8_r0_body.cwS113.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_113.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck113 : krecLB PRE_first_tail_x8_r0_body.kappa113 4885 PRE_first_tail_x8_r0_body.cx0_113.mlx PRE_first_tail_x8_r0_body.kr0_113 PRE_first_tail_x8_r0_body.kr1_113 PRE_first_tail_x8_r0_body.clo113 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn113 : Nat.ble 4885 4885 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge113 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1093.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1094.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR113 : pendRegB PRE_first_tail_x8_r0_body.kappa113 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1094.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe113 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1094.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1093.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift113 (clean : Conv.NClean (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P113.NL) (cl : SSt (· < 4885) PRE_first_tail_x8_r0_body.cx0_113.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_113.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_113.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_113.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1092.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_113.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P113 4885 PRE_first_tail_x8_r0_body.kappa113 PRE_first_tail_x8_r0_body.s1094.ffi PRE_first_tail_x8_r0_body.s1093.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift113 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue113, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp113 t ht),
    PRE_first_tail_x8_r0_body.cbridge113,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1094.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1093.ffi) (PRE_first_tail_x8_r0_body.cfoot113 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_113 PRE_first_tail_x8_r0_body.ofx1_113 hobjC PRE_first_tail_x8_r0_body.ff0113 PRE_first_tail_x8_r0_body.ff1113 PRE_first_tail_x8_r0_body.ffck113,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1094.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1093.ffi) (PRE_first_tail_x8_r0_body.cfoot113 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_113 PRE_first_tail_x8_r0_body.okr1_113 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn113) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0113 PRE_first_tail_x8_r0_body.fkt0113 PRE_first_tail_x8_r0_body.fkf1113 PRE_first_tail_x8_r0_body.fkt1113 PRE_first_tail_x8_r0_body.fkck113,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0113 PRE_first_tail_x8_r0_body.cnh1113 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe113) PRE_first_tail_x8_r0_body.cpendR113⟩

end Host.Load.Run.Tpl
end

section -- st113/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st113 0
host_stream_state PRE_first_tail_x8_r0_body.st113 1
host_stream_state PRE_first_tail_x8_r0_body.st113 2
end Host.Load.Run.Tpl
end

section -- Site113
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 113 of chain `PRE_first_tail_x8_r0_body`: `plan__g113__g114` (`plan`), the call state `PRE_first_tail_x8_r0_body.s1092`, the merged state `PRE_first_tail_x8_r0_body.s1093`,
the site template `PRE_first_tail_x8_r0_body.st113` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1094`: the merge.
The footprint's facts are in `SiteF113`, the compaction's in `SiteC113`, `SiteK113`, `SiteNa113`, `SiteNb113`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso113 : PRE_first_tail_x8_r0_body.st113.s0 = { PRE_first_tail_x8_r0_body.s1092 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs113 : List Frame := PRE_first_tail_x8_r0_body.s1092.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_113 : PRE_first_tail_x8_r0_body.S1092.tab.length = 4885
kernel_rfl PRE_first_tail_x8_r0_body.tab0_113 : PRE_first_tail_x8_r0_body.st113.S0.tab = PRE_first_tail_x8_r0_body.S1092.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws113 : List Nat := [2908, 2909, 2910]
kernel_rfl PRE_first_tail_x8_r0_body.fresh113 : (PRE_first_tail_x8_r0_body.S1092.tab.all fun e => PRE_first_tail_x8_r0_body.ws113.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1092.oracle.all fun q => PRE_first_tail_x8_r0_body.ws113.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab113 : PRE_first_tail_x8_r0_body.S1093.tab = PRE_first_tail_x8_r0_body.S1092.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws113
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen113 : PRE_first_tail_x8_r0_body.st113.S2.tab.length - PRE_first_tail_x8_r0_body.st113.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged113`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap113 : PRE_first_tail_x8_r0_body.s1093.heap = PRE_first_tail_x8_r0_body.st113.s2.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext113 : PRE_first_tail_x8_r0_body.s1093.next = PRE_first_tail_x8_r0_body.st113.s2.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl113 : PRE_first_tail_x8_r0_body.s1093.ctl = PRE_first_tail_x8_r0_body.st113.s2.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack113 : PRE_first_tail_x8_r0_body.s1093.stack = PRE_first_tail_x8_r0_body.st113.s2.stack ++ PRE_first_tail_x8_r0_body.s1092.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs113 : PRE_first_tail_x8_r0_body.s1093.jobs = PRE_first_tail_x8_r0_body.st113.s2.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi113 : PRE_first_tail_x8_r0_body.s1093.ffi = PRE_first_tail_x8_r0_body.st113.s2.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace113 : PRE_first_tail_x8_r0_body.s1093.trace = PRE_first_tail_x8_r0_body.st113.s2.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores113 : PRE_first_tail_x8_r0_body.s1093.stores = PRE_first_tail_x8_r0_body.st113.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD113
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 113 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived113 : PRE_first_tail_x8_r0_body.nr113.map (fun r => nth? PRE_first_tail_x8_r0_body.st113.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo113 : PRE_first_tail_x8_r0_body.nr113.all (Nat.ble 4885) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj113 : PRE_first_tail_x8_r0_body.cws113.all (fun c => !PRE_first_tail_x8_r0_body.ws113.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ113 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws113 PRE_first_tail_x8_r0_body.crs113 PRE_first_tail_x8_r0_body.ws113

end Host.Load.Run.Tpl
end

section -- st113/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st113`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st113.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st113.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st113.s2.heap PRE_first_tail_x8_r0_body.st113.wrR ++ freshOf PRE_first_tail_x8_r0_body.st113.s2.heap PRE_first_tail_x8_r0_body.st113.s0.next PRE_first_tail_x8_r0_body.st113.s2.next
noncomputable def PRE_first_tail_x8_r0_body.st113.wr : List Nat := PRE_first_tail_x8_r0_body.st113.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st113.heapFoot : PRE_first_tail_x8_r0_body.st113.s2.heap = setAll PRE_first_tail_x8_r0_body.st113.s0.heap PRE_first_tail_x8_r0_body.st113.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st113.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st113.s0.next PRE_first_tail_x8_r0_body.st113.s2.next = true
theorem PRE_first_tail_x8_r0_body.st113.grows : PRE_first_tail_x8_r0_body.st113.s0.next ≤ PRE_first_tail_x8_r0_body.st113.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st113.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st113.wh : List Nat := []
def PRE_first_tail_x8_r0_body.st113.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st113.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st113.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st113.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st113.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st113.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st113.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st113.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st113.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st113.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st113.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st113.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st113.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st113.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st113.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st113.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st113.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st113.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st113.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st113.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st113.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st113.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st113.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st113.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st113.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st113.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st113.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st113.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st113.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st113.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF113
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 113 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB113 : nodupT PRE_first_tail_x8_r0_body.st113.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup113 : PRE_first_tail_x8_r0_body.st113.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB113).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB113 : PRE_first_tail_x8_r0_body.st113.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound113 : ∀ b ∈ PRE_first_tail_x8_r0_body.st113.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB113 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr113 := PRE_first_tail_x8_r0_body.st113.s2.trace.take 0
kernel_rfl PRE_first_tail_x8_r0_body.traceEq113 : PRE_first_tail_x8_r0_body.st113.s2.trace = PRE_first_tail_x8_r0_body.trFr113 ++ PRE_first_tail_x8_r0_body.st113.s0.trace
theorem PRE_first_tail_x8_r0_body.trace113 : ∃ fr, PRE_first_tail_x8_r0_body.st113.s2.trace = fr ++ PRE_first_tail_x8_r0_body.st113.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq113⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide113 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB113 : (PRE_first_tail_x8_r0_body.wide113.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st113.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix113 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide113, WFix Map.id (Present PRE_first_tail_x8_r0_body.st113.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB113 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL113
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 113 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1093`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO113 : PRE_first_tail_x8_r0_body.st113.S0.oracle = PRE_first_tail_x8_r0_body.st113.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B113 : PRE_first_tail_x8_r0_body.st113.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st113.s0.next || (PRE_first_tail_x8_r0_body.st113.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot113 : Conv.StageFoot PRE_first_tail_x8_r0_body.st113.wr PRE_first_tail_x8_r0_body.st113.s0 PRE_first_tail_x8_r0_body.st113.s2 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st113.heapFoot PRE_first_tail_x8_r0_body.wrNodup113 PRE_first_tail_x8_r0_body.wrBound113 PRE_first_tail_x8_r0_body.wr0B113 PRE_first_tail_x8_r0_body.st113.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged113 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st113.F.S → PRE_first_tail_x8_r0_body.st113.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st113.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st113.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs113 PRE_first_tail_x8_r0_body.st113.wr PRE_first_tail_x8_r0_body.s1092 PRE_first_tail_x8_r0_body.st113.s2 PRE_first_tail_x8_r0_body.st113.s0
      PRE_first_tail_x8_r0_body.st113.s2.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st113.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1093 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso113 PRE_first_tail_x8_r0_body.stFoot113 PRE_first_tail_x8_r0_body.wrNodup113 PRE_first_tail_x8_r0_body.wrBound113 PRE_first_tail_x8_r0_body.trace113 PRE_first_tail_x8_r0_body.mheap113
    PRE_first_tail_x8_r0_body.mnext113 PRE_first_tail_x8_r0_body.mctl113 PRE_first_tail_x8_r0_body.mstack113 PRE_first_tail_x8_r0_body.mjobs113 PRE_first_tail_x8_r0_body.mffi113 PRE_first_tail_x8_r0_body.mtrace113 PRE_first_tail_x8_r0_body.mstores113 h

def PRE_first_tail_x8_r0_body.arrEl113_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE113_2665 : arrOf PRE_first_tail_x8_r0_body.s1093 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl113_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA113_2665 : isArrB PRE_first_tail_x8_r0_body.s1093 2665 = true
theorem PRE_first_tail_x8_r0_body.arr113_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1093.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl113_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE113_2665 PRE_first_tail_x8_r0_body.arrA113_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN113_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl113_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR113_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl113_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN113_2665

def PRE_first_tail_x8_r0_body.arrEl113_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE113_2673467 : arrOf PRE_first_tail_x8_r0_body.s1093 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl113_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA113_2673467 : isArrB PRE_first_tail_x8_r0_body.s1093 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr113_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1093.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl113_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE113_2673467 PRE_first_tail_x8_r0_body.arrA113_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN113_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl113_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR113_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl113_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN113_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k113 : isArrB PRE_first_tail_x8_r0_body.s1093 4910 = false
theorem PRE_first_tail_x8_r0_body.keep113 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1093 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k113 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr113_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl113_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ113
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 113 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1092`, the merged
state `PRE_first_tail_x8_r0_body.s1093`, the canonical state `PRE_first_tail_x8_r0_body.s1094`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl113 : PRE_first_tail_x8_r0_body.pl113.all (Nat.ble PRE_first_tail_x8_r0_body.s1092.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd113 : nodupT PRE_first_tail_x8_r0_body.pl113 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1113 : Nat.ble PRE_first_tail_x8_r0_body.s1092.next 2763262 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst113 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1092.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn113 : PRE_first_tail_x8_r0_body.s1094.next = PRE_first_tail_x8_r0_body.s1092.next + PRE_first_tail_x8_r0_body.pl113.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn113 : PRE_first_tail_x8_r0_body.s1093.next = 2763262
kernel_rfl PRE_first_tail_x8_r0_body.zgrow113 : Nat.ble PRE_first_tail_x8_r0_body.s1094.next PRE_first_tail_x8_r0_body.s1093.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh113 : PRE_first_tail_x8_r0_body.S1092.tab.all (fun e => PRE_first_tail_x8_r0_body.cws113.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd113 : nodupT PRE_first_tail_x8_r0_body.cws113 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi113 : PRE_first_tail_x8_r0_body.nr113.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1093.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt113 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1092.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg113_2665 : PRE_first_tail_x8_r0_body.s1094.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1094 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk113_2665 : (objOf PRE_first_tail_x8_r0_body.s1094 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm113_2665 : PRE_first_tail_x8_r0_body.s1093.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa113.obj (objOf PRE_first_tail_x8_r0_body.s1094 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1093 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg113_2673467 : PRE_first_tail_x8_r0_body.s1094.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1094 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk113_2673467 : (objOf PRE_first_tail_x8_r0_body.s1094 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm113_2673467 : PRE_first_tail_x8_r0_body.s1093.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa113.obj (objOf PRE_first_tail_x8_r0_body.s1094 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1093 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw113_4910 : (PRE_first_tail_x8_r0_body.s1094.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw113_2673472 : (PRE_first_tail_x8_r0_body.s1094.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw113_2673473 : (PRE_first_tail_x8_r0_body.s1094.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd113 : PRE_first_tail_x8_r0_body.cl113.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr113 : PRE_first_tail_x8_r0_body.st113.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1092.next || PRE_first_tail_x8_r0_body.cl113.contains b) = true
def PRE_first_tail_x8_r0_body.zl113 : List Nat := PRE_first_tail_x8_r0_body.cl113.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE113 : PRE_first_tail_x8_r0_body.zl113.map (fun a => PRE_first_tail_x8_r0_body.s1093.heap.get (PRE_first_tail_x8_r0_body.kappa113.a a)) = PRE_first_tail_x8_r0_body.zl113.map (fun a => (PRE_first_tail_x8_r0_body.s1094.heap.get a).map PRE_first_tail_x8_r0_body.kappa113.hobj)
theorem PRE_first_tail_x8_r0_body.zimg113 : HeapImg PRE_first_tail_x8_r0_body.kappa113 PRE_first_tail_x8_r0_body.s1094 PRE_first_tail_x8_r0_body.s1093 PRE_first_tail_x8_r0_body.zl113 := PRE_first_tail_x8_r0_body.zimgE113
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl113 : PRE_first_tail_x8_r0_body.s1093.ctl = PRE_first_tail_x8_r0_body.kappa113.ctl PRE_first_tail_x8_r0_body.s1094.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack113 : PRE_first_tail_x8_r0_body.s1093.stack = PRE_first_tail_x8_r0_body.s1094.stack.map PRE_first_tail_x8_r0_body.kappa113.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs113 : PRE_first_tail_x8_r0_body.s1093.jobs = PRE_first_tail_x8_r0_body.s1094.jobs.map PRE_first_tail_x8_r0_body.kappa113.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores113 : PRE_first_tail_x8_r0_body.s1093.stores = PRE_first_tail_x8_r0_body.kappa113.stores PRE_first_tail_x8_r0_body.s1094.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots113 : checkRootsSupp PRE_first_tail_x8_r0_body.s1094 4885 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC113 : PRE_first_tail_x8_r0_body.S1092.tab.length + PRE_first_tail_x8_r0_body.cws113.length = 4885
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap113 : PRE_first_tail_x8_r0_body.kappa113 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1092.next 2763262 PRE_first_tail_x8_r0_body.S1092.tab.length PRE_first_tail_x8_r0_body.pl113 (PRE_first_tail_x8_r0_body.nr113.map NumV.ref) PRE_first_tail_x8_r0_body.kd113.big
  PRE_first_tail_x8_r0_body.kd113.region PRE_first_tail_x8_r0_body.kd113.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin113 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1094.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc113 : Conv.jcleanListB (⟨20420, 17518, 2763252, 4885⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1094 PRE_first_tail_x8_r0_body.cl113 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB113 : noBigRootsP (fun i => !Conv.oldBigB (⟨20420, 17518, 2763252, 4885⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1094.trace PRE_first_tail_x8_r0_body.s1094 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm113 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 17518 = true
theorem PRE_first_tail_x8_r0_body.cjcl113 (h : Conv.JClean (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1092) : Conv.JClean (⟨20420, 17518, 2763252, 4885⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1094 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle113)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap113 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd113 a ha)) PRE_first_tail_x8_r0_body.zjc113

end Host.Load.Run.Tpl
end

section -- st113/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st113.bodyLast from PRE_first_tail_x8_r0_body.st113.s1 to PRE_first_tail_x8_r0_body.st113.s2 :
  interpS (step PRE_first_tail_x8_r0_body.st113.F PRE_first_tail_x8_r0_body.st113.s1).run PRE_first_tail_x8_r0_body.st113.S1 = some (PRE_first_tail_x8_r0_body.st113.s2, PRE_first_tail_x8_r0_body.st113.S2)
kernel_rfl PRE_first_tail_x8_r0_body.st113.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st113.s1.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st113.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st113.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st113/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st113.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st113.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st113.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st113.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st113.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st113.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st113.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st113.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st113.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st113.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st113.s0 PRE_first_tail_x8_r0_body.st113.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st113.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st113.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st113.s1 PRE_first_tail_x8_r0_body.st113.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st113/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st113.bodyK0F from PRE_first_tail_x8_r0_body.st113.s0 to PRE_first_tail_x8_r0_body.st113.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st113.F (PRE_first_tail_x8_r0_body.st113.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st113.ks 0).getD 0) PRE_first_tail_x8_r0_body.st113.s0 PRE_first_tail_x8_r0_body.st113.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st113.s1, PRE_first_tail_x8_r0_body.st113.S1)
theorem PRE_first_tail_x8_r0_body.st113.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st113.F (PRE_first_tail_x8_r0_body.st113.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st113.ks 0).getD 0) PRE_first_tail_x8_r0_body.st113.s0 PRE_first_tail_x8_r0_body.st113.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st113.s1, PRE_first_tail_x8_r0_body.st113.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st113.bodyOkLN_ok PRE_first_tail_x8_r0_body.st113.bodyK0F
end Host.Load.Run.Tpl
end

section -- st113/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st113.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st113.F (PRE_first_tail_x8_r0_body.st113.bodyOkL bytes rows) 98 PRE_first_tail_x8_r0_body.st113.s0 PRE_first_tail_x8_r0_body.st113.S0 = some (PRE_first_tail_x8_r0_body.st113.s1, PRE_first_tail_x8_r0_body.st113.S1) :=
  (congrFun (congrFun PRE_first_tail_x8_r0_body.st113.bodyK0 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st113.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st113.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st113.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st113.F (PRE_first_tail_x8_r0_body.st113.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st113.s0
  S0 := PRE_first_tail_x8_r0_body.st113.S0
  s1 := PRE_first_tail_x8_r0_body.st113.s1
  S1 := PRE_first_tail_x8_r0_body.st113.S1
  s2 := PRE_first_tail_x8_r0_body.st113.s2
  S2 := PRE_first_tail_x8_r0_body.st113.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st113.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st113.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st113.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st113.bodyHalt
  last := PRE_first_tail_x8_r0_body.st113.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st113.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC114
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 114 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1111` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa114` into the merged state
`PRE_first_tail_x8_r0_body.s1110`. -/

def PRE_first_tail_x8_r0_body.pl114 : List Nat := [2765835, 2765010, 2765841, 2765837, 2765012, 2765843]
def PRE_first_tail_x8_r0_body.nr114 : List Nat := [4988, 4987, 4963, 4971, 4976, 4981, 4986, 4960, 4961, 4962, 4969, 4970, 4958, 4965, 4966, 4967, 4968, 4964]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd114 : RData :=
  ⟨2764729, 2765878, Stage.setAll PTrie.nil [(2764723, 2765835), (2764724, 2765010), (2764725, 2765841), (2764726, 2765837), (2764727, 2765012), (2764728, 2765843)], Stage.setAll PTrie.nil [(20454, 20480), (20455, 20458), (20456, 20481)],
   20457, 20482, 17564, 17564, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(4958, .ref 4988), (4959, .ref 4987), (4960, .ref 4963), (4961, .ref 4971), (4962, .ref 4976), (4963, .ref 4981), (4964, .ref 4986), (4965, .ref 4960), (4966, .ref 4961), (4967, .ref 4962), (4968, .ref 4969), (4969, .ref 4970), (4970, .ref 4958), (4971, .ref 4965), (4972, .ref 4966), (4973, .ref 4967), (4974, .ref 4968), (4975, .ref 4964)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa114 : Map :=
  Conv.Map.compact 2764723 2765878 4958 PRE_first_tail_x8_r0_body.pl114 (PRE_first_tail_x8_r0_body.nr114.map NumV.ref) PRE_first_tail_x8_r0_body.kd114.big
    PRE_first_tail_x8_r0_body.kd114.region PRE_first_tail_x8_r0_body.kd114.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws114 : List Nat := [2942, 2943, 2944, 2945, 2946, 2947, 2948, 2949, 2950, 2951, 2952, 2953, 2954, 2955, 2956, 2957, 2958, 2959]
noncomputable def PRE_first_tail_x8_r0_body.crs114 : List SymE := PRE_first_tail_x8_r0_body.nr114.map fun r => (nth? PRE_first_tail_x8_r0_body.S1110.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta114 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws114 PRE_first_tail_x8_r0_body.crs114
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB114 : List Nat := [2665, 2672589, 2673467, 2763897, 2764442, 2764698]

kernel_rfl PRE_first_tail_x8_r0_body.ctab114 : PRE_first_tail_x8_r0_body.S1111.tab = PRE_first_tail_x8_r0_body.S1109.tab ++ PRE_first_tail_x8_r0_body.cws114.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace114 : PRE_first_tail_x8_r0_body.s1111.trace = PRE_first_tail_x8_r0_body.s1109.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext114 : PRE_first_tail_x8_r0_body.s1111.next = 2764729
kernel_rfl PRE_first_tail_x8_r0_body.ccounters114 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1111.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1111.ffi).mlx.nnext) = (20457, 17564)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue114 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1110.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1111.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa114.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp114 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1111.ffi).mlx.tokens.all (bSN 4976) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean114 : Conv.cleanListB 20457 131072 (fun r => Nat.ble 81828 r) PRE_first_tail_x8_r0_body.s1111
    (PRE_first_tail_x8_r0_body.wrB114 ++ (List.range 6).map (2764723 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs114 : bigsOutB 20457 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1111.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK114
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl114`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl114 : List Nat := [2665, 2672589, 2673467, 2763897, 2764442, 2764698, 2764723, 2764724, 2764725, 2764726, 2764727, 2764728]
def PRE_first_tail_x8_r0_body.clo114 : List Nat := [20434, 20447, 20453, 20454, 20455, 20456]
def PRE_first_tail_x8_r0_body.cln114 : List Nat := [17537, 17538, 17539, 17540, 17541, 17542, 17543, 17544, 17545, 17546, 17547, 17548, 17549, 17550, 17551, 17552, 17553, 17554, 17555, 17556, 17557, 17558, 17559, 17560, 17561, 17562, 17563]
def PRE_first_tail_x8_r0_body.cli114 : List Nat := [17537, 17538, 17539, 17540, 17541, 17542, 17543, 17544, 17545, 17546, 17547, 17548, 17549, 17550, 17551, 17552, 17553, 17554, 17555, 17556, 17557, 17558, 17559, 17560, 17561, 17562, 17563]
kernel_rfl PRE_first_tail_x8_r0_body.cheap114 : PRE_first_tail_x8_r0_body.s1111.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1109.heap (PRE_first_tail_x8_r0_body.cl114.filterMap fun a => (PRE_first_tail_x8_r0_body.s1111.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe114 : Nat.ble PRE_first_tail_x8_r0_body.s1109.next PRE_first_tail_x8_r0_body.s1111.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP114 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1109 PRE_first_tail_x8_r0_body.s1111 PRE_first_tail_x8_r0_body.cl114 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp114 : Conv.suppListB PRE_first_tail_x8_r0_body.s1111 4976 PRE_first_tail_x8_r0_body.cl114 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound114 : Conv.boundListB PRE_first_tail_x8_r0_body.s1111 PRE_first_tail_x8_r0_body.cl114 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK114 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1111.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln114.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1111.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK114 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1111.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo114.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1111.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK114 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1111.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli114.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1111.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst114 : Conv.sstListB 4976 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1111.ffi).mlx PRE_first_tail_x8_r0_body.cln114 PRE_first_tail_x8_r0_body.clo114 PRE_first_tail_x8_r0_body.cli114 = true

end Host.Load.Run.Tpl
end

section -- SiteCl114
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA114 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1111.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo114.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1111.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd114 : (PRE_first_tail_x8_r0_body.clo114 ++ PRE_first_tail_x8_r0_body.cln114 ++ PRE_first_tail_x8_r0_body.cli114).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle114 : Conv.Cnt.leB (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt) (⟨20457, 17564, 2764729, 4976⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck114 : Conv.ncleanListB (⟨20457, 17564, 2764729, 4976⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1111.ffi).mlx PRE_first_tail_x8_r0_body.clo114 PRE_first_tail_x8_r0_body.cln114 PRE_first_tail_x8_r0_body.cli114 = true
theorem PRE_first_tail_x8_r0_body.cncl114 (h : Conv.NClean (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx) : Conv.NClean (⟨20457, 17564, 2764729, 4976⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1111.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle114 PRE_first_tail_x8_r0_body.ckA114 PRE_first_tail_x8_r0_body.cobjsK114 PRE_first_tail_x8_r0_body.cnodesK114 PRE_first_tail_x8_r0_body.citemsK114 PRE_first_tail_x8_r0_body.cbd114 PRE_first_tail_x8_r0_body.cck114

end Host.Load.Run.Tpl
end

section -- SiteS114
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 114 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc114 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P114 : LoadP := PRE_first_tail_x8_r0_body.Pc114.raise 17564
kernel_rfl PRE_first_tail_x8_r0_body.craise114 : Nat.ble PRE_first_tail_x8_r0_body.Pc114.N0 17564 = true
theorem PRE_first_tail_x8_r0_body.raised114 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc114 PRE_first_tail_x8_r0_body.P114 :=
  .inr ⟨17564, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise114, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_114 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1111.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_114 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1110.ffi)
def PRE_first_tail_x8_r0_body.khinv114 : PTrie Nat := Stage.setAll PTrie.nil [(20480, 20454), (20458, 20455), (20481, 20456)]
def PRE_first_tail_x8_r0_body.kninv114 : PTrie Nat := Stage.setAll PTrie.nil [(17537, 17537), (17538, 17538), (17539, 17539), (17540, 17540), (17541, 17541), (17542, 17542), (17543, 17543), (17544, 17544), (17545, 17545), (17546, 17546), (17547, 17547), (17548, 17548), (17549, 17549), (17550, 17550), (17551, 17551), (17552, 17552), (17553, 17553), (17554, 17554), (17555, 17555), (17556, 17556), (17557, 17557), (17558, 17558), (17559, 17559), (17560, 17560), (17561, 17561), (17562, 17562), (17563, 17563)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS114 : List Nat := [20434, 20447, 20453, 20454, 20455, 20456, 20457, 20458, 20459, 20460, 20461, 20462, 20463, 20464, 20465, 20466, 20467, 20468, 20469, 20470, 20471, 20472, 20473, 20474, 20475, 20476, 20477, 20478, 20479, 20480, 20481]
def PRE_first_tail_x8_r0_body.cnS114 : List Nat := List.range' 17537 27
def PRE_first_tail_x8_r0_body.ciS114 : List Nat := [] ++ List.range' 17537 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0114 : PRE_first_tail_x8_r0_body.kd114.nh0 = PRE_first_tail_x8_r0_body.cx0_114.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1114 : PRE_first_tail_x8_r0_body.kd114.nh1 = PRE_first_tail_x8_r0_body.cx1_114.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0114 : PRE_first_tail_x8_r0_body.kd114.nn0 = PRE_first_tail_x8_r0_body.cx0_114.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1114 : PRE_first_tail_x8_r0_body.kd114.nn1 = PRE_first_tail_x8_r0_body.cx1_114.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo114 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P114.lo && Nat.ble PRE_first_tail_x8_r0_body.P114.lo PRE_first_tail_x8_r0_body.cx0_114.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P114.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P114.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt114 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_114.mlx.next PRE_first_tail_x8_r0_body.cx1_114.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_114.mlx.nnext PRE_first_tail_x8_r0_body.cx1_114.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband114 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P114.NL && Nat.ble PRE_first_tail_x8_r0_body.P114.NL PRE_first_tail_x8_r0_body.P114.N0 && Nat.ble PRE_first_tail_x8_r0_body.P114.N0 PRE_first_tail_x8_r0_body.cx0_114.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow114 : PRE_first_tail_x8_r0_body.kd114.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren114 : checkRenG PRE_first_tail_x8_r0_body.kd114.hnd PRE_first_tail_x8_r0_body.khinv114 (phB PRE_first_tail_x8_r0_body.cx0_114.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband114 : PRE_first_tail_x8_r0_body.kd114.checkBand PRE_first_tail_x8_r0_body.P114.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos114 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd114.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren114 : checkRenG PRE_first_tail_x8_r0_body.kd114.node PRE_first_tail_x8_r0_body.kninv114 (pnB PRE_first_tail_x8_r0_body.cx0_114.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow114 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd114.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P114.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd114.nodeF j) PRE_first_tail_x8_r0_body.cx1_114.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a114 : PRE_first_tail_x8_r0_body.cx0_114.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b114 : PRE_first_tail_x8_r0_body.cx0_114.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1114 : PRE_first_tail_x8_r0_body.cx1_114.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend114 : PRE_first_tail_x8_r0_body.cx1_114.mlx.pending = PRE_first_tail_x8_r0_body.cx0_114.mlx.pending.map PRE_first_tail_x8_r0_body.kappa114.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh114 : PRE_first_tail_x8_r0_body.cx1_114.mlx.errh = PRE_first_tail_x8_r0_body.cx0_114.mlx.errh.map PRE_first_tail_x8_r0_body.kappa114.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles114 : PRE_first_tail_x8_r0_body.cx1_114.mlx.files = PRE_first_tail_x8_r0_body.cx0_114.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch114 : PRE_first_tail_x8_r0_body.cx1_114.mlx.arch = PRE_first_tail_x8_r0_body.cx0_114.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes114 : PRE_first_tail_x8_r0_body.cx1_114.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_114.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired114 : PRE_first_tail_x8_r0_body.cx1_114.mlx.wired = PRE_first_tail_x8_r0_body.cx0_114.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost114 : PRE_first_tail_x8_r0_body.cx1_114.host = PRE_first_tail_x8_r0_body.cx0_114.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd114`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0114 : PRE_first_tail_x8_r0_body.kd114.n0 = 2764729
kernel_rfl PRE_first_tail_x8_r0_body.ckn1114 : PRE_first_tail_x8_r0_body.kd114.n1 = 2765878
kernel_rfl PRE_first_tail_x8_r0_body.ckheap114 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd114.heap).all (fun x => Nat.ble 2764723 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl114 : (List.range 6).all (fun j => decide (PRE_first_tail_x8_r0_body.kd114.heap.get (2764723 + j) = nth? PRE_first_tail_x8_r0_body.pl114 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja114 : Nat.ble 2764723 2764723 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn114 : Nat.ble 4958 4958 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD114 : Nat.ble 2764723 PRE_first_tail_x8_r0_body.kd114.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn114 : Nat.ble 20454 PRE_first_tail_x8_r0_body.kd114.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn114 : Nat.ble 17537 PRE_first_tail_x8_r0_body.kd114.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb114 : Nat.ble 20454 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap114 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd114.heap).all (Nat.ble (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd114 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd114.hnd).all (Nat.ble (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode114 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd114.node).all (Nat.ble (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix114 : Conv.FixOld (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa114 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja114) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn114) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD114) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn114) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn114) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb114) PRE_first_tail_x8_r0_body.fheap114 PRE_first_tail_x8_r0_body.fhnd114 PRE_first_tail_x8_r0_body.fnode114
kernel_rfl PRE_first_tail_x8_r0_body.fcxn114 : (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn114 : (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0114 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_114.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_114.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk114 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd114.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A114 : PRE_first_tail_x8_r0_body.cx1_114.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS114.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_114.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O114 : PRE_first_tail_x8_r0_body.cx1_114.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS114.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_114.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N114 : PRE_first_tail_x8_r0_body.cx1_114.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS114.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_114.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I114 : PRE_first_tail_x8_r0_body.cx1_114.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS114.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_114.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd114 : (PRE_first_tail_x8_r0_body.clo114 ++ PRE_first_tail_x8_r0_body.cln114 ++ PRE_first_tail_x8_r0_body.cli114 ++ PRE_first_tail_x8_r0_body.cwS114 ++ PRE_first_tail_x8_r0_body.cnS114 ++ PRE_first_tail_x8_r0_body.ciS114).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW114 : PRE_first_tail_x8_r0_body.cwS114.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo114.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI114 : PRE_first_tail_x8_r0_body.ciS114.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli114.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN114 : PRE_first_tail_x8_r0_body.cnS114.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF114 : PRE_first_tail_x8_r0_body.cln114.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh114 : PRE_first_tail_x8_r0_body.clo114.all (handleOK PRE_first_tail_x8_r0_body.kappa114 PRE_first_tail_x8_r0_body.P114.lo PRE_first_tail_x8_r0_body.cx0_114.mlx PRE_first_tail_x8_r0_body.cx1_114.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo114 : PRE_first_tail_x8_r0_body.clo114.map (fun h => PRE_first_tail_x8_r0_body.cx1_114.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa114.handle h)) = PRE_first_tail_x8_r0_body.clo114.map (fun h => (PRE_first_tail_x8_r0_body.cx0_114.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa114.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok114 : PRE_first_tail_x8_r0_body.clo114.all (objOK PRE_first_tail_x8_r0_body.kappa114 PRE_first_tail_x8_r0_body.P114.NL PRE_first_tail_x8_r0_body.cx0_114.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd114 : PRE_first_tail_x8_r0_body.cln114.all (nodeOKF PRE_first_tail_x8_r0_body.kappa114 PRE_first_tail_x8_r0_body.P114 PRE_first_tail_x8_r0_body.cx0_114.mlx PRE_first_tail_x8_r0_body.cx1_114.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp114 : ((PRE_first_tail_x8_r0_body.cln114.filter (fullB PRE_first_tail_x8_r0_body.P114))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_114.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa114.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln114.filter (fullB PRE_first_tail_x8_r0_body.P114))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_114.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa114.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI114 : incrB PRE_first_tail_x8_r0_body.kd114.nodeF (List.range' 17537 27) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK114 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd114.node).all (fun k => Nat.ble 17537 k && Nat.blt k 17564) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL114 : (PRE_first_tail_x8_r0_body.cln114.filter (Nat.ble PRE_first_tail_x8_r0_body.P114.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd114.nodeF i) && (Nat.blt i 17564 || Nat.ble PRE_first_tail_x8_r0_body.kd114.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord114 : (PRE_first_tail_x8_r0_body.cln114.filter (Nat.ble PRE_first_tail_x8_r0_body.P114.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd114.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd114.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd114.nodeF j) (PRE_first_tail_x8_r0_body.kd114.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow114 PRE_first_tail_x8_r0_body.cnn1114 PRE_first_tail_x8_r0_body.fnordI114 PRE_first_tail_x8_r0_body.fnordK114 PRE_first_tail_x8_r0_body.fnordL114
kernel_rfl PRE_first_tail_x8_r0_body.fi114 : PRE_first_tail_x8_r0_body.cli114.all (pnB PRE_first_tail_x8_r0_body.cx0_114.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii114 : PRE_first_tail_x8_r0_body.cli114.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_114.mlx.items.get (PRE_first_tail_x8_r0_body.kappa114.node k) = (PRE_first_tail_x8_r0_body.cx0_114.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa114.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot114 (clean : Conv.NClean (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P114.NL) (cl : SSt (· < 4976) PRE_first_tail_x8_r0_body.cx0_114.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P114 4976 PRE_first_tail_x8_r0_body.kappa114 PRE_first_tail_x8_r0_body.kd114 PRE_first_tail_x8_r0_body.khinv114 PRE_first_tail_x8_r0_body.kninv114 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx PRE_first_tail_x8_r0_body.cx0_114.mlx PRE_first_tail_x8_r0_body.cx1_114.mlx (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo114 PRE_first_tail_x8_r0_body.cln114 PRE_first_tail_x8_r0_body.cli114 PRE_first_tail_x8_r0_body.cwS114 PRE_first_tail_x8_r0_body.cnS114 PRE_first_tail_x8_r0_body.ciS114 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0114, PRE_first_tail_x8_r0_body.cnh1114, PRE_first_tail_x8_r0_body.cnn0114, PRE_first_tail_x8_r0_body.cnn1114, PRE_first_tail_x8_r0_body.cplo114, PRE_first_tail_x8_r0_body.ccnt114, PRE_first_tail_x8_r0_body.cnband114, PRE_first_tail_x8_r0_body.chbelow114, PRE_first_tail_x8_r0_body.chren114, PRE_first_tail_x8_r0_body.cband114, PRE_first_tail_x8_r0_body.cnh1pos114, PRE_first_tail_x8_r0_body.cnren114, PRE_first_tail_x8_r0_body.cnlow114, PRE_first_tail_x8_r0_body.cabs0a114, PRE_first_tail_x8_r0_body.cabs0b114, PRE_first_tail_x8_r0_body.ctok1114, PRE_first_tail_x8_r0_body.cpend114, PRE_first_tail_x8_r0_body.cerrh114, PRE_first_tail_x8_r0_body.cfiles114, PRE_first_tail_x8_r0_body.carch114, PRE_first_tail_x8_r0_body.csizes114, PRE_first_tail_x8_r0_body.cwired114, PRE_first_tail_x8_r0_body.cfix114, clean, PRE_first_tail_x8_r0_body.fcxn114, PRE_first_tail_x8_r0_body.fcnn114, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0114, PRE_first_tail_x8_r0_body.fnk114, PRE_first_tail_x8_r0_body.ckA114, PRE_first_tail_x8_r0_body.cobjsK114, PRE_first_tail_x8_r0_body.cnodesK114, PRE_first_tail_x8_r0_body.citemsK114, PRE_first_tail_x8_r0_body.f1A114, PRE_first_tail_x8_r0_body.f1O114, PRE_first_tail_x8_r0_body.f1N114, PRE_first_tail_x8_r0_body.f1I114, PRE_first_tail_x8_r0_body.fbd114, PRE_first_tail_x8_r0_body.fincW114, PRE_first_tail_x8_r0_body.fincI114, PRE_first_tail_x8_r0_body.fincN114, PRE_first_tail_x8_r0_body.flnF114, PRE_first_tail_x8_r0_body.fh114, PRE_first_tail_x8_r0_body.fo114, PRE_first_tail_x8_r0_body.fok114, PRE_first_tail_x8_r0_body.fnd114, PRE_first_tail_x8_r0_body.fp114, PRE_first_tail_x8_r0_body.fnord114, PRE_first_tail_x8_r0_body.fi114, PRE_first_tail_x8_r0_body.fii114⟩
theorem PRE_first_tail_x8_r0_body.cnshift114 (clean : Conv.NClean (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P114.NL) (cl : SSt (· < 4976) PRE_first_tail_x8_r0_body.cx0_114.mlx) : NShift PRE_first_tail_x8_r0_body.P114 4976 PRE_first_tail_x8_r0_body.kappa114 PRE_first_tail_x8_r0_body.cx0_114 PRE_first_tail_x8_r0_body.cx1_114 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot114 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost114 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0114 PRE_first_tail_x8_r0_body.ckn1114 PRE_first_tail_x8_r0_body.ckheap114 PRE_first_tail_x8_r0_body.ckpl114)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_114 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1109.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_114 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1109.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_114 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1109.ffi) = some PRE_first_tail_x8_r0_body.fxC_114
kernel_rfl PRE_first_tail_x8_r0_body.okrC_114 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1109.ffi) = some PRE_first_tail_x8_r0_body.krC_114
noncomputable def PRE_first_tail_x8_r0_body.fx0_114 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1111.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_114 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1111.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_114 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1111.ffi) = some PRE_first_tail_x8_r0_body.fx0_114
kernel_rfl PRE_first_tail_x8_r0_body.okr0_114 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1111.ffi) = some PRE_first_tail_x8_r0_body.kr0_114
noncomputable def PRE_first_tail_x8_r0_body.fx1_114 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1110.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_114 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1110.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_114 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1110.ffi) = some PRE_first_tail_x8_r0_body.fx1_114
kernel_rfl PRE_first_tail_x8_r0_body.okr1_114 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1110.ffi) = some PRE_first_tail_x8_r0_body.kr1_114
kernel_rfl PRE_first_tail_x8_r0_body.ff0114 : PRE_first_tail_x8_r0_body.fx0_114 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_114 (PRE_first_tail_x8_r0_body.clo114.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_114.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1114 : PRE_first_tail_x8_r0_body.fx1_114 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_114 (PRE_first_tail_x8_r0_body.cwS114.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_114.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck114 : freedLB PRE_first_tail_x8_r0_body.kappa114 PRE_first_tail_x8_r0_body.cx0_114.mlx PRE_first_tail_x8_r0_body.fx0_114 PRE_first_tail_x8_r0_body.fx1_114 PRE_first_tail_x8_r0_body.clo114 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0114 : PRE_first_tail_x8_r0_body.kr0_114.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_114.flags (PRE_first_tail_x8_r0_body.clo114.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_114.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0114 : PRE_first_tail_x8_r0_body.kr0_114.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_114.targs (PRE_first_tail_x8_r0_body.clo114.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_114.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1114 : PRE_first_tail_x8_r0_body.kr1_114.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_114.flags (PRE_first_tail_x8_r0_body.cwS114.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_114.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1114 : PRE_first_tail_x8_r0_body.kr1_114.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_114.targs (PRE_first_tail_x8_r0_body.cwS114.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_114.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck114 : krecLB PRE_first_tail_x8_r0_body.kappa114 4976 PRE_first_tail_x8_r0_body.cx0_114.mlx PRE_first_tail_x8_r0_body.kr0_114 PRE_first_tail_x8_r0_body.kr1_114 PRE_first_tail_x8_r0_body.clo114 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn114 : Nat.ble 4958 4976 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge114 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1110.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1111.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR114 : pendRegB PRE_first_tail_x8_r0_body.kappa114 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1111.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe114 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1111.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1110.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift114 (clean : Conv.NClean (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P114.NL) (cl : SSt (· < 4976) PRE_first_tail_x8_r0_body.cx0_114.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_114.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_114.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_114.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1109.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_114.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P114 4976 PRE_first_tail_x8_r0_body.kappa114 PRE_first_tail_x8_r0_body.s1111.ffi PRE_first_tail_x8_r0_body.s1110.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift114 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue114, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp114 t ht),
    PRE_first_tail_x8_r0_body.cbridge114,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1111.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1110.ffi) (PRE_first_tail_x8_r0_body.cfoot114 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_114 PRE_first_tail_x8_r0_body.ofx1_114 hobjC PRE_first_tail_x8_r0_body.ff0114 PRE_first_tail_x8_r0_body.ff1114 PRE_first_tail_x8_r0_body.ffck114,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1111.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1110.ffi) (PRE_first_tail_x8_r0_body.cfoot114 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_114 PRE_first_tail_x8_r0_body.okr1_114 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn114) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0114 PRE_first_tail_x8_r0_body.fkt0114 PRE_first_tail_x8_r0_body.fkf1114 PRE_first_tail_x8_r0_body.fkt1114 PRE_first_tail_x8_r0_body.fkck114,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0114 PRE_first_tail_x8_r0_body.cnh1114 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe114) PRE_first_tail_x8_r0_body.cpendR114⟩

end Host.Load.Run.Tpl
end

section -- st114/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st114 0
host_stream_state PRE_first_tail_x8_r0_body.st114 1
host_stream_state PRE_first_tail_x8_r0_body.st114 2
host_stream_state PRE_first_tail_x8_r0_body.st114 3
host_stream_state PRE_first_tail_x8_r0_body.st114 4
host_stream_state PRE_first_tail_x8_r0_body.st114 5
end Host.Load.Run.Tpl
end

section -- Site114
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 114 of chain `PRE_first_tail_x8_r0_body`: `ssmW__g114__g115` (`recurWindow`), the call state `PRE_first_tail_x8_r0_body.s1109`, the merged state `PRE_first_tail_x8_r0_body.s1110`,
the site template `PRE_first_tail_x8_r0_body.st114` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1111`: the merge.
The footprint's facts are in `SiteF114`, the compaction's in `SiteC114`, `SiteK114`, `SiteNa114`, `SiteNb114`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso114 : PRE_first_tail_x8_r0_body.st114.s0 = { PRE_first_tail_x8_r0_body.s1109 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs114 : List Frame := PRE_first_tail_x8_r0_body.s1109.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_114 : PRE_first_tail_x8_r0_body.S1109.tab.length = 4958
kernel_rfl PRE_first_tail_x8_r0_body.tab0_114 : PRE_first_tail_x8_r0_body.st114.S0.tab = PRE_first_tail_x8_r0_body.S1109.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws114 : List Nat := [2911, 2912, 2913, 2914, 2915, 2916, 2917, 2918, 2919, 2920, 2921, 2922, 2923, 2924, 2925, 2926, 2927, 2928, 2929, 2930, 2931, 2932, 2933, 2934, 2935, 2936, 2937, 2938, 2939, 2940, 2941]
kernel_rfl PRE_first_tail_x8_r0_body.fresh114 : (PRE_first_tail_x8_r0_body.S1109.tab.all fun e => PRE_first_tail_x8_r0_body.ws114.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1109.oracle.all fun q => PRE_first_tail_x8_r0_body.ws114.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab114 : PRE_first_tail_x8_r0_body.S1110.tab = PRE_first_tail_x8_r0_body.S1109.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws114
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen114 : PRE_first_tail_x8_r0_body.st114.S5.tab.length - PRE_first_tail_x8_r0_body.st114.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged114`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap114 : PRE_first_tail_x8_r0_body.s1110.heap = PRE_first_tail_x8_r0_body.st114.s5.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext114 : PRE_first_tail_x8_r0_body.s1110.next = PRE_first_tail_x8_r0_body.st114.s5.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl114 : PRE_first_tail_x8_r0_body.s1110.ctl = PRE_first_tail_x8_r0_body.st114.s5.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack114 : PRE_first_tail_x8_r0_body.s1110.stack = PRE_first_tail_x8_r0_body.st114.s5.stack ++ PRE_first_tail_x8_r0_body.s1109.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs114 : PRE_first_tail_x8_r0_body.s1110.jobs = PRE_first_tail_x8_r0_body.st114.s5.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi114 : PRE_first_tail_x8_r0_body.s1110.ffi = PRE_first_tail_x8_r0_body.st114.s5.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace114 : PRE_first_tail_x8_r0_body.s1110.trace = PRE_first_tail_x8_r0_body.st114.s5.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores114 : PRE_first_tail_x8_r0_body.s1110.stores = PRE_first_tail_x8_r0_body.st114.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD114
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 114 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived114 : PRE_first_tail_x8_r0_body.nr114.map (fun r => nth? PRE_first_tail_x8_r0_body.st114.S5.tab r) =
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
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo114 : PRE_first_tail_x8_r0_body.nr114.all (Nat.ble 4958) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj114 : PRE_first_tail_x8_r0_body.cws114.all (fun c => !PRE_first_tail_x8_r0_body.ws114.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ114 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws114 PRE_first_tail_x8_r0_body.crs114 PRE_first_tail_x8_r0_body.ws114

end Host.Load.Run.Tpl
end

section -- st114/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st114`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st114.wrR : List (Nat × Nat) := [(2672589, 2672590), (2763897, 2763898), (2764442, 2764443), (2764698, 2764699)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st114.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st114.s5.heap PRE_first_tail_x8_r0_body.st114.wrR ++ freshOf PRE_first_tail_x8_r0_body.st114.s5.heap PRE_first_tail_x8_r0_body.st114.s0.next PRE_first_tail_x8_r0_body.st114.s5.next
noncomputable def PRE_first_tail_x8_r0_body.st114.wr : List Nat := PRE_first_tail_x8_r0_body.st114.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st114.heapFoot : PRE_first_tail_x8_r0_body.st114.s5.heap = setAll PRE_first_tail_x8_r0_body.st114.s0.heap PRE_first_tail_x8_r0_body.st114.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st114.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st114.s0.next PRE_first_tail_x8_r0_body.st114.s5.next = true
theorem PRE_first_tail_x8_r0_body.st114.grows : PRE_first_tail_x8_r0_body.st114.s0.next ≤ PRE_first_tail_x8_r0_body.st114.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st114.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st114.wh : List Nat := [20434, 20447, 20453, 20454, 20455, 20456, 20457, 20458, 20459, 20460, 20461, 20462, 20463, 20464, 20465, 20466, 20467, 20468, 20469, 20470, 20471, 20472, 20473, 20474, 20475, 20476, 20477, 20478, 20479, 20480, 20481]
def PRE_first_tail_x8_r0_body.st114.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st114.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st114.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st114.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st114.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st114.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st114.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st114.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st114.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st114.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st114.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st114.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st114.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st114.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st114.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st114.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st114.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st114.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st114.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st114.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st114.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st114.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st114.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st114.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st114.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st114.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st114.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st114.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st114.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st114.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF114
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 114 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB114 : nodupT PRE_first_tail_x8_r0_body.st114.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup114 : PRE_first_tail_x8_r0_body.st114.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB114).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB114 : PRE_first_tail_x8_r0_body.st114.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound114 : ∀ b ∈ PRE_first_tail_x8_r0_body.st114.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB114 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr114 := PRE_first_tail_x8_r0_body.st114.s5.trace.take 120
kernel_rfl PRE_first_tail_x8_r0_body.traceEq114 : PRE_first_tail_x8_r0_body.st114.s5.trace = PRE_first_tail_x8_r0_body.trFr114 ++ PRE_first_tail_x8_r0_body.st114.s0.trace
theorem PRE_first_tail_x8_r0_body.trace114 : ∃ fr, PRE_first_tail_x8_r0_body.st114.s5.trace = fr ++ PRE_first_tail_x8_r0_body.st114.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq114⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide114 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB114 : (PRE_first_tail_x8_r0_body.wide114.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st114.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix114 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide114, WFix Map.id (Present PRE_first_tail_x8_r0_body.st114.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB114 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL114
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 114 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1110`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO114 : PRE_first_tail_x8_r0_body.st114.S0.oracle = PRE_first_tail_x8_r0_body.st114.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B114 : PRE_first_tail_x8_r0_body.st114.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st114.s0.next || (PRE_first_tail_x8_r0_body.st114.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot114 : Conv.StageFoot PRE_first_tail_x8_r0_body.st114.wr PRE_first_tail_x8_r0_body.st114.s0 PRE_first_tail_x8_r0_body.st114.s5 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st114.heapFoot PRE_first_tail_x8_r0_body.wrNodup114 PRE_first_tail_x8_r0_body.wrBound114 PRE_first_tail_x8_r0_body.wr0B114 PRE_first_tail_x8_r0_body.st114.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged114 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st114.F.S → PRE_first_tail_x8_r0_body.st114.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st114.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st114.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs114 PRE_first_tail_x8_r0_body.st114.wr PRE_first_tail_x8_r0_body.s1109 PRE_first_tail_x8_r0_body.st114.s5 PRE_first_tail_x8_r0_body.st114.s0
      PRE_first_tail_x8_r0_body.st114.s5.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st114.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1110 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso114 PRE_first_tail_x8_r0_body.stFoot114 PRE_first_tail_x8_r0_body.wrNodup114 PRE_first_tail_x8_r0_body.wrBound114 PRE_first_tail_x8_r0_body.trace114 PRE_first_tail_x8_r0_body.mheap114
    PRE_first_tail_x8_r0_body.mnext114 PRE_first_tail_x8_r0_body.mctl114 PRE_first_tail_x8_r0_body.mstack114 PRE_first_tail_x8_r0_body.mjobs114 PRE_first_tail_x8_r0_body.mffi114 PRE_first_tail_x8_r0_body.mtrace114 PRE_first_tail_x8_r0_body.mstores114 h

def PRE_first_tail_x8_r0_body.arrEl114_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE114_2665 : arrOf PRE_first_tail_x8_r0_body.s1110 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl114_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA114_2665 : isArrB PRE_first_tail_x8_r0_body.s1110 2665 = true
theorem PRE_first_tail_x8_r0_body.arr114_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1110.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl114_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE114_2665 PRE_first_tail_x8_r0_body.arrA114_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN114_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl114_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR114_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl114_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN114_2665

def PRE_first_tail_x8_r0_body.arrEl114_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE114_2673467 : arrOf PRE_first_tail_x8_r0_body.s1110 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl114_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA114_2673467 : isArrB PRE_first_tail_x8_r0_body.s1110 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr114_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1110.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl114_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE114_2673467 PRE_first_tail_x8_r0_body.arrA114_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN114_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl114_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR114_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl114_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN114_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k114 : isArrB PRE_first_tail_x8_r0_body.s1110 4910 = false
theorem PRE_first_tail_x8_r0_body.keep114 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1110 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k114 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr114_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl114_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ114
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 114 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1109`, the merged
state `PRE_first_tail_x8_r0_body.s1110`, the canonical state `PRE_first_tail_x8_r0_body.s1111`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl114 : PRE_first_tail_x8_r0_body.pl114.all (Nat.ble PRE_first_tail_x8_r0_body.s1109.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd114 : nodupT PRE_first_tail_x8_r0_body.pl114 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1114 : Nat.ble PRE_first_tail_x8_r0_body.s1109.next 2765878 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst114 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1109.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn114 : PRE_first_tail_x8_r0_body.s1111.next = PRE_first_tail_x8_r0_body.s1109.next + PRE_first_tail_x8_r0_body.pl114.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn114 : PRE_first_tail_x8_r0_body.s1110.next = 2765878
kernel_rfl PRE_first_tail_x8_r0_body.zgrow114 : Nat.ble PRE_first_tail_x8_r0_body.s1111.next PRE_first_tail_x8_r0_body.s1110.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh114 : PRE_first_tail_x8_r0_body.S1109.tab.all (fun e => PRE_first_tail_x8_r0_body.cws114.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd114 : nodupT PRE_first_tail_x8_r0_body.cws114 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi114 : PRE_first_tail_x8_r0_body.nr114.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1110.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt114 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1109.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg114_2665 : PRE_first_tail_x8_r0_body.s1111.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1111 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk114_2665 : (objOf PRE_first_tail_x8_r0_body.s1111 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm114_2665 : PRE_first_tail_x8_r0_body.s1110.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa114.obj (objOf PRE_first_tail_x8_r0_body.s1111 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1110 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg114_2673467 : PRE_first_tail_x8_r0_body.s1111.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1111 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk114_2673467 : (objOf PRE_first_tail_x8_r0_body.s1111 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm114_2673467 : PRE_first_tail_x8_r0_body.s1110.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa114.obj (objOf PRE_first_tail_x8_r0_body.s1111 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1110 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw114_4910 : (PRE_first_tail_x8_r0_body.s1111.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw114_2673472 : (PRE_first_tail_x8_r0_body.s1111.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw114_2673473 : (PRE_first_tail_x8_r0_body.s1111.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd114 : PRE_first_tail_x8_r0_body.cl114.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr114 : PRE_first_tail_x8_r0_body.st114.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1109.next || PRE_first_tail_x8_r0_body.cl114.contains b) = true
def PRE_first_tail_x8_r0_body.zl114 : List Nat := PRE_first_tail_x8_r0_body.cl114.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE114 : PRE_first_tail_x8_r0_body.zl114.map (fun a => PRE_first_tail_x8_r0_body.s1110.heap.get (PRE_first_tail_x8_r0_body.kappa114.a a)) = PRE_first_tail_x8_r0_body.zl114.map (fun a => (PRE_first_tail_x8_r0_body.s1111.heap.get a).map PRE_first_tail_x8_r0_body.kappa114.hobj)
theorem PRE_first_tail_x8_r0_body.zimg114 : HeapImg PRE_first_tail_x8_r0_body.kappa114 PRE_first_tail_x8_r0_body.s1111 PRE_first_tail_x8_r0_body.s1110 PRE_first_tail_x8_r0_body.zl114 := PRE_first_tail_x8_r0_body.zimgE114
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl114 : PRE_first_tail_x8_r0_body.s1110.ctl = PRE_first_tail_x8_r0_body.kappa114.ctl PRE_first_tail_x8_r0_body.s1111.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack114 : PRE_first_tail_x8_r0_body.s1110.stack = PRE_first_tail_x8_r0_body.s1111.stack.map PRE_first_tail_x8_r0_body.kappa114.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs114 : PRE_first_tail_x8_r0_body.s1110.jobs = PRE_first_tail_x8_r0_body.s1111.jobs.map PRE_first_tail_x8_r0_body.kappa114.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores114 : PRE_first_tail_x8_r0_body.s1110.stores = PRE_first_tail_x8_r0_body.kappa114.stores PRE_first_tail_x8_r0_body.s1111.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots114 : checkRootsSupp PRE_first_tail_x8_r0_body.s1111 4976 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC114 : PRE_first_tail_x8_r0_body.S1109.tab.length + PRE_first_tail_x8_r0_body.cws114.length = 4976
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap114 : PRE_first_tail_x8_r0_body.kappa114 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1109.next 2765878 PRE_first_tail_x8_r0_body.S1109.tab.length PRE_first_tail_x8_r0_body.pl114 (PRE_first_tail_x8_r0_body.nr114.map NumV.ref) PRE_first_tail_x8_r0_body.kd114.big
  PRE_first_tail_x8_r0_body.kd114.region PRE_first_tail_x8_r0_body.kd114.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin114 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1111.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc114 : Conv.jcleanListB (⟨20457, 17564, 2764729, 4976⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1111 PRE_first_tail_x8_r0_body.cl114 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB114 : noBigRootsP (fun i => !Conv.oldBigB (⟨20457, 17564, 2764729, 4976⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1111.trace PRE_first_tail_x8_r0_body.s1111 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm114 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 17537 = true
theorem PRE_first_tail_x8_r0_body.cjcl114 (h : Conv.JClean (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1109) : Conv.JClean (⟨20457, 17564, 2764729, 4976⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1111 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle114)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap114 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd114 a ha)) PRE_first_tail_x8_r0_body.zjc114

end Host.Load.Run.Tpl
end

section -- st114/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st114.bodyLast from PRE_first_tail_x8_r0_body.st114.s4 to PRE_first_tail_x8_r0_body.st114.s5 :
  interpS (step PRE_first_tail_x8_r0_body.st114.F PRE_first_tail_x8_r0_body.st114.s4).run PRE_first_tail_x8_r0_body.st114.S4 = some (PRE_first_tail_x8_r0_body.st114.s5, PRE_first_tail_x8_r0_body.st114.S5)
kernel_rfl PRE_first_tail_x8_r0_body.st114.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st114.s4.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st114.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st114.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st114/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st114.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st114.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st114.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st114.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st114.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st114.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st114.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st114.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st114.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st114.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st114.s0 PRE_first_tail_x8_r0_body.st114.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st114.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st114.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st114.s4 PRE_first_tail_x8_r0_body.st114.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st114/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st114.bodyK0F from PRE_first_tail_x8_r0_body.st114.s0 to PRE_first_tail_x8_r0_body.st114.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st114.F (PRE_first_tail_x8_r0_body.st114.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st114.ks 0).getD 0) PRE_first_tail_x8_r0_body.st114.s0 PRE_first_tail_x8_r0_body.st114.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st114.s1, PRE_first_tail_x8_r0_body.st114.S1)
theorem PRE_first_tail_x8_r0_body.st114.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st114.F (PRE_first_tail_x8_r0_body.st114.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st114.ks 0).getD 0) PRE_first_tail_x8_r0_body.st114.s0 PRE_first_tail_x8_r0_body.st114.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st114.s1, PRE_first_tail_x8_r0_body.st114.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st114.bodyOkLN_ok PRE_first_tail_x8_r0_body.st114.bodyK0F
end Host.Load.Run.Tpl
end

section -- st114/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st114.bodyK1F from PRE_first_tail_x8_r0_body.st114.s1 to PRE_first_tail_x8_r0_body.st114.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st114.F (PRE_first_tail_x8_r0_body.st114.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st114.ks 1).getD 0) PRE_first_tail_x8_r0_body.st114.s1 PRE_first_tail_x8_r0_body.st114.S1) = fun _ _ => some (PRE_first_tail_x8_r0_body.st114.s2, PRE_first_tail_x8_r0_body.st114.S2)
theorem PRE_first_tail_x8_r0_body.st114.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st114.F (PRE_first_tail_x8_r0_body.st114.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st114.ks 1).getD 0) PRE_first_tail_x8_r0_body.st114.s1 PRE_first_tail_x8_r0_body.st114.S1) = fun _ _ => some (PRE_first_tail_x8_r0_body.st114.s2, PRE_first_tail_x8_r0_body.st114.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st114.bodyOkLN_ok PRE_first_tail_x8_r0_body.st114.bodyK1F
end Host.Load.Run.Tpl
end

section -- st114/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st114.bodyK2F from PRE_first_tail_x8_r0_body.st114.s2 to PRE_first_tail_x8_r0_body.st114.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st114.F (PRE_first_tail_x8_r0_body.st114.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st114.ks 2).getD 0) PRE_first_tail_x8_r0_body.st114.s2 PRE_first_tail_x8_r0_body.st114.S2) = fun _ _ => some (PRE_first_tail_x8_r0_body.st114.s3, PRE_first_tail_x8_r0_body.st114.S3)
theorem PRE_first_tail_x8_r0_body.st114.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st114.F (PRE_first_tail_x8_r0_body.st114.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st114.ks 2).getD 0) PRE_first_tail_x8_r0_body.st114.s2 PRE_first_tail_x8_r0_body.st114.S2) = fun _ _ => some (PRE_first_tail_x8_r0_body.st114.s3, PRE_first_tail_x8_r0_body.st114.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st114.bodyOkLN_ok PRE_first_tail_x8_r0_body.st114.bodyK2F
end Host.Load.Run.Tpl
end

section -- st114/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st114.bodyK3F from PRE_first_tail_x8_r0_body.st114.s3 to PRE_first_tail_x8_r0_body.st114.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st114.F (PRE_first_tail_x8_r0_body.st114.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st114.ks 3).getD 0) PRE_first_tail_x8_r0_body.st114.s3 PRE_first_tail_x8_r0_body.st114.S3) = fun _ _ => some (PRE_first_tail_x8_r0_body.st114.s4, PRE_first_tail_x8_r0_body.st114.S4)
theorem PRE_first_tail_x8_r0_body.st114.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st114.F (PRE_first_tail_x8_r0_body.st114.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st114.ks 3).getD 0) PRE_first_tail_x8_r0_body.st114.s3 PRE_first_tail_x8_r0_body.st114.S3) = fun _ _ => some (PRE_first_tail_x8_r0_body.st114.s4, PRE_first_tail_x8_r0_body.st114.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st114.bodyOkLN_ok PRE_first_tail_x8_r0_body.st114.bodyK3F
end Host.Load.Run.Tpl
end

section -- st114/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st114.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st114.F (PRE_first_tail_x8_r0_body.st114.bodyOkL bytes rows) 11334 PRE_first_tail_x8_r0_body.st114.s0 PRE_first_tail_x8_r0_body.st114.S0 = some (PRE_first_tail_x8_r0_body.st114.s4, PRE_first_tail_x8_r0_body.st114.S4) :=
  runOk_trans PRE_first_tail_x8_r0_body.st114.F (PRE_first_tail_x8_r0_body.st114.bodyOkL bytes rows) ((((nth? PRE_first_tail_x8_r0_body.st114.ks 0).getD 0) + ((nth? PRE_first_tail_x8_r0_body.st114.ks 1).getD 0)) + ((nth? PRE_first_tail_x8_r0_body.st114.ks 2).getD 0)) ((nth? PRE_first_tail_x8_r0_body.st114.ks 3).getD 0) PRE_first_tail_x8_r0_body.st114.s0 PRE_first_tail_x8_r0_body.st114.s3 PRE_first_tail_x8_r0_body.st114.s4 PRE_first_tail_x8_r0_body.st114.S0 PRE_first_tail_x8_r0_body.st114.S3 PRE_first_tail_x8_r0_body.st114.S4 (runOk_trans PRE_first_tail_x8_r0_body.st114.F (PRE_first_tail_x8_r0_body.st114.bodyOkL bytes rows) (((nth? PRE_first_tail_x8_r0_body.st114.ks 0).getD 0) + ((nth? PRE_first_tail_x8_r0_body.st114.ks 1).getD 0)) ((nth? PRE_first_tail_x8_r0_body.st114.ks 2).getD 0) PRE_first_tail_x8_r0_body.st114.s0 PRE_first_tail_x8_r0_body.st114.s2 PRE_first_tail_x8_r0_body.st114.s3 PRE_first_tail_x8_r0_body.st114.S0 PRE_first_tail_x8_r0_body.st114.S2 PRE_first_tail_x8_r0_body.st114.S3 (runOk_trans PRE_first_tail_x8_r0_body.st114.F (PRE_first_tail_x8_r0_body.st114.bodyOkL bytes rows) ((nth? PRE_first_tail_x8_r0_body.st114.ks 0).getD 0) ((nth? PRE_first_tail_x8_r0_body.st114.ks 1).getD 0) PRE_first_tail_x8_r0_body.st114.s0 PRE_first_tail_x8_r0_body.st114.s1 PRE_first_tail_x8_r0_body.st114.s2 PRE_first_tail_x8_r0_body.st114.S0 PRE_first_tail_x8_r0_body.st114.S1 PRE_first_tail_x8_r0_body.st114.S2 ((congrFun (congrFun PRE_first_tail_x8_r0_body.st114.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x8_r0_body.st114.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x8_r0_body.st114.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x8_r0_body.st114.bodyK3 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st114.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st114.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st114.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st114.F (PRE_first_tail_x8_r0_body.st114.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st114.s0
  S0 := PRE_first_tail_x8_r0_body.st114.S0
  s1 := PRE_first_tail_x8_r0_body.st114.s4
  S1 := PRE_first_tail_x8_r0_body.st114.S4
  s2 := PRE_first_tail_x8_r0_body.st114.s5
  S2 := PRE_first_tail_x8_r0_body.st114.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st114.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st114.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st114.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st114.bodyHalt
  last := PRE_first_tail_x8_r0_body.st114.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st114.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC115
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 115 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1119` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa115` into the merged state
`PRE_first_tail_x8_r0_body.s1118`. -/

def PRE_first_tail_x8_r0_body.pl115 : List Nat := []
def PRE_first_tail_x8_r0_body.nr115 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd115 : RData :=
  ⟨2765219, 2765221, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20470, 20470, 17577, 17577, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa115 : Map :=
  Conv.Map.compact 2765219 2765221 4997 PRE_first_tail_x8_r0_body.pl115 (PRE_first_tail_x8_r0_body.nr115.map NumV.ref) PRE_first_tail_x8_r0_body.kd115.big
    PRE_first_tail_x8_r0_body.kd115.region PRE_first_tail_x8_r0_body.kd115.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws115 : List Nat := []
noncomputable def PRE_first_tail_x8_r0_body.crs115 : List SymE := PRE_first_tail_x8_r0_body.nr115.map fun r => (nth? PRE_first_tail_x8_r0_body.S1118.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta115 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws115 PRE_first_tail_x8_r0_body.crs115
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB115 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x8_r0_body.ctab115 : PRE_first_tail_x8_r0_body.S1119.tab = PRE_first_tail_x8_r0_body.S1117.tab ++ PRE_first_tail_x8_r0_body.cws115.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace115 : PRE_first_tail_x8_r0_body.s1119.trace = PRE_first_tail_x8_r0_body.s1117.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext115 : PRE_first_tail_x8_r0_body.s1119.next = 2765219
kernel_rfl PRE_first_tail_x8_r0_body.ccounters115 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1119.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1119.ffi).mlx.nnext) = (20470, 17577)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue115 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1118.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1119.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa115.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp115 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1119.ffi).mlx.tokens.all (bSN 4997) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean115 : Conv.cleanListB 20470 131072 (fun r => Nat.ble 81880 r) PRE_first_tail_x8_r0_body.s1119
    (PRE_first_tail_x8_r0_body.wrB115 ++ (List.range 0).map (2765219 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs115 : bigsOutB 20470 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1119.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK115
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl115`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl115 : List Nat := [2665, 2673467]
def PRE_first_tail_x8_r0_body.clo115 : List Nat := []
def PRE_first_tail_x8_r0_body.cln115 : List Nat := []
def PRE_first_tail_x8_r0_body.cli115 : List Nat := []
kernel_rfl PRE_first_tail_x8_r0_body.cheap115 : PRE_first_tail_x8_r0_body.s1119.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1117.heap (PRE_first_tail_x8_r0_body.cl115.filterMap fun a => (PRE_first_tail_x8_r0_body.s1119.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe115 : Nat.ble PRE_first_tail_x8_r0_body.s1117.next PRE_first_tail_x8_r0_body.s1119.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP115 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1117 PRE_first_tail_x8_r0_body.s1119 PRE_first_tail_x8_r0_body.cl115 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp115 : Conv.suppListB PRE_first_tail_x8_r0_body.s1119 4997 PRE_first_tail_x8_r0_body.cl115 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound115 : Conv.boundListB PRE_first_tail_x8_r0_body.s1119 PRE_first_tail_x8_r0_body.cl115 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK115 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1119.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln115.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1119.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK115 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1119.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo115.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1119.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK115 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1119.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli115.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1119.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst115 : Conv.sstListB 4997 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1119.ffi).mlx PRE_first_tail_x8_r0_body.cln115 PRE_first_tail_x8_r0_body.clo115 PRE_first_tail_x8_r0_body.cli115 = true

end Host.Load.Run.Tpl
end

section -- SiteCl115
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA115 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1119.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo115.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1119.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd115 : (PRE_first_tail_x8_r0_body.clo115 ++ PRE_first_tail_x8_r0_body.cln115 ++ PRE_first_tail_x8_r0_body.cli115).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle115 : Conv.Cnt.leB (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt) (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck115 : Conv.ncleanListB (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1119.ffi).mlx PRE_first_tail_x8_r0_body.clo115 PRE_first_tail_x8_r0_body.cln115 PRE_first_tail_x8_r0_body.cli115 = true
theorem PRE_first_tail_x8_r0_body.cncl115 (h : Conv.NClean (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx) : Conv.NClean (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1119.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle115 PRE_first_tail_x8_r0_body.ckA115 PRE_first_tail_x8_r0_body.cobjsK115 PRE_first_tail_x8_r0_body.cnodesK115 PRE_first_tail_x8_r0_body.citemsK115 PRE_first_tail_x8_r0_body.cbd115 PRE_first_tail_x8_r0_body.cck115

end Host.Load.Run.Tpl
end

section -- SiteS115
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 115 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc115 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P115 : LoadP := PRE_first_tail_x8_r0_body.Pc115.raise 17577
kernel_rfl PRE_first_tail_x8_r0_body.craise115 : Nat.ble PRE_first_tail_x8_r0_body.Pc115.N0 17577 = true
theorem PRE_first_tail_x8_r0_body.raised115 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc115 PRE_first_tail_x8_r0_body.P115 :=
  .inr ⟨17577, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise115, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_115 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1119.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_115 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1118.ffi)
def PRE_first_tail_x8_r0_body.khinv115 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x8_r0_body.kninv115 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS115 : List Nat := []
def PRE_first_tail_x8_r0_body.cnS115 : List Nat := List.range' 17577 0
def PRE_first_tail_x8_r0_body.ciS115 : List Nat := [] ++ List.range' 17577 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0115 : PRE_first_tail_x8_r0_body.kd115.nh0 = PRE_first_tail_x8_r0_body.cx0_115.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1115 : PRE_first_tail_x8_r0_body.kd115.nh1 = PRE_first_tail_x8_r0_body.cx1_115.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0115 : PRE_first_tail_x8_r0_body.kd115.nn0 = PRE_first_tail_x8_r0_body.cx0_115.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1115 : PRE_first_tail_x8_r0_body.kd115.nn1 = PRE_first_tail_x8_r0_body.cx1_115.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo115 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P115.lo && Nat.ble PRE_first_tail_x8_r0_body.P115.lo PRE_first_tail_x8_r0_body.cx0_115.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P115.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P115.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt115 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_115.mlx.next PRE_first_tail_x8_r0_body.cx1_115.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_115.mlx.nnext PRE_first_tail_x8_r0_body.cx1_115.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband115 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P115.NL && Nat.ble PRE_first_tail_x8_r0_body.P115.NL PRE_first_tail_x8_r0_body.P115.N0 && Nat.ble PRE_first_tail_x8_r0_body.P115.N0 PRE_first_tail_x8_r0_body.cx0_115.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow115 : PRE_first_tail_x8_r0_body.kd115.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren115 : checkRenG PRE_first_tail_x8_r0_body.kd115.hnd PRE_first_tail_x8_r0_body.khinv115 (phB PRE_first_tail_x8_r0_body.cx0_115.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband115 : PRE_first_tail_x8_r0_body.kd115.checkBand PRE_first_tail_x8_r0_body.P115.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos115 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd115.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren115 : checkRenG PRE_first_tail_x8_r0_body.kd115.node PRE_first_tail_x8_r0_body.kninv115 (pnB PRE_first_tail_x8_r0_body.cx0_115.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow115 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd115.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P115.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd115.nodeF j) PRE_first_tail_x8_r0_body.cx1_115.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a115 : PRE_first_tail_x8_r0_body.cx0_115.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b115 : PRE_first_tail_x8_r0_body.cx0_115.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1115 : PRE_first_tail_x8_r0_body.cx1_115.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend115 : PRE_first_tail_x8_r0_body.cx1_115.mlx.pending = PRE_first_tail_x8_r0_body.cx0_115.mlx.pending.map PRE_first_tail_x8_r0_body.kappa115.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh115 : PRE_first_tail_x8_r0_body.cx1_115.mlx.errh = PRE_first_tail_x8_r0_body.cx0_115.mlx.errh.map PRE_first_tail_x8_r0_body.kappa115.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles115 : PRE_first_tail_x8_r0_body.cx1_115.mlx.files = PRE_first_tail_x8_r0_body.cx0_115.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch115 : PRE_first_tail_x8_r0_body.cx1_115.mlx.arch = PRE_first_tail_x8_r0_body.cx0_115.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes115 : PRE_first_tail_x8_r0_body.cx1_115.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_115.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired115 : PRE_first_tail_x8_r0_body.cx1_115.mlx.wired = PRE_first_tail_x8_r0_body.cx0_115.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost115 : PRE_first_tail_x8_r0_body.cx1_115.host = PRE_first_tail_x8_r0_body.cx0_115.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd115`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0115 : PRE_first_tail_x8_r0_body.kd115.n0 = 2765219
kernel_rfl PRE_first_tail_x8_r0_body.ckn1115 : PRE_first_tail_x8_r0_body.kd115.n1 = 2765221
kernel_rfl PRE_first_tail_x8_r0_body.ckheap115 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd115.heap).all (fun x => Nat.ble 2765219 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl115 : (List.range 0).all (fun j => decide (PRE_first_tail_x8_r0_body.kd115.heap.get (2765219 + j) = nth? PRE_first_tail_x8_r0_body.pl115 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja115 : Nat.ble 2765219 2765219 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn115 : Nat.ble 4997 4997 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD115 : Nat.ble 2765219 PRE_first_tail_x8_r0_body.kd115.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn115 : Nat.ble 20470 PRE_first_tail_x8_r0_body.kd115.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn115 : Nat.ble 17577 PRE_first_tail_x8_r0_body.kd115.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb115 : Nat.ble 20470 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap115 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd115.heap).all (Nat.ble (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd115 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd115.hnd).all (Nat.ble (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode115 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd115.node).all (Nat.ble (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix115 : Conv.FixOld (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa115 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja115) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn115) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD115) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn115) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn115) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb115) PRE_first_tail_x8_r0_body.fheap115 PRE_first_tail_x8_r0_body.fhnd115 PRE_first_tail_x8_r0_body.fnode115
kernel_rfl PRE_first_tail_x8_r0_body.fcxn115 : (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn115 : (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0115 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_115.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_115.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk115 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd115.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A115 : PRE_first_tail_x8_r0_body.cx1_115.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS115.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_115.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O115 : PRE_first_tail_x8_r0_body.cx1_115.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS115.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_115.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N115 : PRE_first_tail_x8_r0_body.cx1_115.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS115.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_115.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I115 : PRE_first_tail_x8_r0_body.cx1_115.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS115.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_115.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd115 : (PRE_first_tail_x8_r0_body.clo115 ++ PRE_first_tail_x8_r0_body.cln115 ++ PRE_first_tail_x8_r0_body.cli115 ++ PRE_first_tail_x8_r0_body.cwS115 ++ PRE_first_tail_x8_r0_body.cnS115 ++ PRE_first_tail_x8_r0_body.ciS115).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW115 : PRE_first_tail_x8_r0_body.cwS115.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo115.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI115 : PRE_first_tail_x8_r0_body.ciS115.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli115.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN115 : PRE_first_tail_x8_r0_body.cnS115.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF115 : PRE_first_tail_x8_r0_body.cln115.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh115 : PRE_first_tail_x8_r0_body.clo115.all (handleOK PRE_first_tail_x8_r0_body.kappa115 PRE_first_tail_x8_r0_body.P115.lo PRE_first_tail_x8_r0_body.cx0_115.mlx PRE_first_tail_x8_r0_body.cx1_115.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo115 : PRE_first_tail_x8_r0_body.clo115.map (fun h => PRE_first_tail_x8_r0_body.cx1_115.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa115.handle h)) = PRE_first_tail_x8_r0_body.clo115.map (fun h => (PRE_first_tail_x8_r0_body.cx0_115.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa115.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok115 : PRE_first_tail_x8_r0_body.clo115.all (objOK PRE_first_tail_x8_r0_body.kappa115 PRE_first_tail_x8_r0_body.P115.NL PRE_first_tail_x8_r0_body.cx0_115.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd115 : PRE_first_tail_x8_r0_body.cln115.all (nodeOKF PRE_first_tail_x8_r0_body.kappa115 PRE_first_tail_x8_r0_body.P115 PRE_first_tail_x8_r0_body.cx0_115.mlx PRE_first_tail_x8_r0_body.cx1_115.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp115 : ((PRE_first_tail_x8_r0_body.cln115.filter (fullB PRE_first_tail_x8_r0_body.P115))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_115.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa115.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln115.filter (fullB PRE_first_tail_x8_r0_body.P115))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_115.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa115.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI115 : incrB PRE_first_tail_x8_r0_body.kd115.nodeF (List.range' 17577 0) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK115 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd115.node).all (fun k => Nat.ble 17577 k && Nat.blt k 17577) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL115 : (PRE_first_tail_x8_r0_body.cln115.filter (Nat.ble PRE_first_tail_x8_r0_body.P115.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd115.nodeF i) && (Nat.blt i 17577 || Nat.ble PRE_first_tail_x8_r0_body.kd115.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord115 : (PRE_first_tail_x8_r0_body.cln115.filter (Nat.ble PRE_first_tail_x8_r0_body.P115.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd115.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd115.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd115.nodeF j) (PRE_first_tail_x8_r0_body.kd115.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow115 PRE_first_tail_x8_r0_body.cnn1115 PRE_first_tail_x8_r0_body.fnordI115 PRE_first_tail_x8_r0_body.fnordK115 PRE_first_tail_x8_r0_body.fnordL115
kernel_rfl PRE_first_tail_x8_r0_body.fi115 : PRE_first_tail_x8_r0_body.cli115.all (pnB PRE_first_tail_x8_r0_body.cx0_115.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii115 : PRE_first_tail_x8_r0_body.cli115.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_115.mlx.items.get (PRE_first_tail_x8_r0_body.kappa115.node k) = (PRE_first_tail_x8_r0_body.cx0_115.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa115.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot115 (clean : Conv.NClean (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P115.NL) (cl : SSt (· < 4997) PRE_first_tail_x8_r0_body.cx0_115.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P115 4997 PRE_first_tail_x8_r0_body.kappa115 PRE_first_tail_x8_r0_body.kd115 PRE_first_tail_x8_r0_body.khinv115 PRE_first_tail_x8_r0_body.kninv115 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx PRE_first_tail_x8_r0_body.cx0_115.mlx PRE_first_tail_x8_r0_body.cx1_115.mlx (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo115 PRE_first_tail_x8_r0_body.cln115 PRE_first_tail_x8_r0_body.cli115 PRE_first_tail_x8_r0_body.cwS115 PRE_first_tail_x8_r0_body.cnS115 PRE_first_tail_x8_r0_body.ciS115 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0115, PRE_first_tail_x8_r0_body.cnh1115, PRE_first_tail_x8_r0_body.cnn0115, PRE_first_tail_x8_r0_body.cnn1115, PRE_first_tail_x8_r0_body.cplo115, PRE_first_tail_x8_r0_body.ccnt115, PRE_first_tail_x8_r0_body.cnband115, PRE_first_tail_x8_r0_body.chbelow115, PRE_first_tail_x8_r0_body.chren115, PRE_first_tail_x8_r0_body.cband115, PRE_first_tail_x8_r0_body.cnh1pos115, PRE_first_tail_x8_r0_body.cnren115, PRE_first_tail_x8_r0_body.cnlow115, PRE_first_tail_x8_r0_body.cabs0a115, PRE_first_tail_x8_r0_body.cabs0b115, PRE_first_tail_x8_r0_body.ctok1115, PRE_first_tail_x8_r0_body.cpend115, PRE_first_tail_x8_r0_body.cerrh115, PRE_first_tail_x8_r0_body.cfiles115, PRE_first_tail_x8_r0_body.carch115, PRE_first_tail_x8_r0_body.csizes115, PRE_first_tail_x8_r0_body.cwired115, PRE_first_tail_x8_r0_body.cfix115, clean, PRE_first_tail_x8_r0_body.fcxn115, PRE_first_tail_x8_r0_body.fcnn115, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0115, PRE_first_tail_x8_r0_body.fnk115, PRE_first_tail_x8_r0_body.ckA115, PRE_first_tail_x8_r0_body.cobjsK115, PRE_first_tail_x8_r0_body.cnodesK115, PRE_first_tail_x8_r0_body.citemsK115, PRE_first_tail_x8_r0_body.f1A115, PRE_first_tail_x8_r0_body.f1O115, PRE_first_tail_x8_r0_body.f1N115, PRE_first_tail_x8_r0_body.f1I115, PRE_first_tail_x8_r0_body.fbd115, PRE_first_tail_x8_r0_body.fincW115, PRE_first_tail_x8_r0_body.fincI115, PRE_first_tail_x8_r0_body.fincN115, PRE_first_tail_x8_r0_body.flnF115, PRE_first_tail_x8_r0_body.fh115, PRE_first_tail_x8_r0_body.fo115, PRE_first_tail_x8_r0_body.fok115, PRE_first_tail_x8_r0_body.fnd115, PRE_first_tail_x8_r0_body.fp115, PRE_first_tail_x8_r0_body.fnord115, PRE_first_tail_x8_r0_body.fi115, PRE_first_tail_x8_r0_body.fii115⟩
theorem PRE_first_tail_x8_r0_body.cnshift115 (clean : Conv.NClean (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P115.NL) (cl : SSt (· < 4997) PRE_first_tail_x8_r0_body.cx0_115.mlx) : NShift PRE_first_tail_x8_r0_body.P115 4997 PRE_first_tail_x8_r0_body.kappa115 PRE_first_tail_x8_r0_body.cx0_115 PRE_first_tail_x8_r0_body.cx1_115 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot115 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost115 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0115 PRE_first_tail_x8_r0_body.ckn1115 PRE_first_tail_x8_r0_body.ckheap115 PRE_first_tail_x8_r0_body.ckpl115)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_115 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1117.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_115 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1117.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_115 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1117.ffi) = some PRE_first_tail_x8_r0_body.fxC_115
kernel_rfl PRE_first_tail_x8_r0_body.okrC_115 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1117.ffi) = some PRE_first_tail_x8_r0_body.krC_115
noncomputable def PRE_first_tail_x8_r0_body.fx0_115 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1119.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_115 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1119.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_115 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1119.ffi) = some PRE_first_tail_x8_r0_body.fx0_115
kernel_rfl PRE_first_tail_x8_r0_body.okr0_115 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1119.ffi) = some PRE_first_tail_x8_r0_body.kr0_115
noncomputable def PRE_first_tail_x8_r0_body.fx1_115 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1118.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_115 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1118.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_115 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1118.ffi) = some PRE_first_tail_x8_r0_body.fx1_115
kernel_rfl PRE_first_tail_x8_r0_body.okr1_115 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1118.ffi) = some PRE_first_tail_x8_r0_body.kr1_115
kernel_rfl PRE_first_tail_x8_r0_body.ff0115 : PRE_first_tail_x8_r0_body.fx0_115 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_115 (PRE_first_tail_x8_r0_body.clo115.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_115.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1115 : PRE_first_tail_x8_r0_body.fx1_115 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_115 (PRE_first_tail_x8_r0_body.cwS115.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_115.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck115 : freedLB PRE_first_tail_x8_r0_body.kappa115 PRE_first_tail_x8_r0_body.cx0_115.mlx PRE_first_tail_x8_r0_body.fx0_115 PRE_first_tail_x8_r0_body.fx1_115 PRE_first_tail_x8_r0_body.clo115 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0115 : PRE_first_tail_x8_r0_body.kr0_115.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_115.flags (PRE_first_tail_x8_r0_body.clo115.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_115.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0115 : PRE_first_tail_x8_r0_body.kr0_115.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_115.targs (PRE_first_tail_x8_r0_body.clo115.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_115.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1115 : PRE_first_tail_x8_r0_body.kr1_115.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_115.flags (PRE_first_tail_x8_r0_body.cwS115.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_115.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1115 : PRE_first_tail_x8_r0_body.kr1_115.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_115.targs (PRE_first_tail_x8_r0_body.cwS115.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_115.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck115 : krecLB PRE_first_tail_x8_r0_body.kappa115 4997 PRE_first_tail_x8_r0_body.cx0_115.mlx PRE_first_tail_x8_r0_body.kr0_115 PRE_first_tail_x8_r0_body.kr1_115 PRE_first_tail_x8_r0_body.clo115 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn115 : Nat.ble 4997 4997 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge115 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1118.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1119.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR115 : pendRegB PRE_first_tail_x8_r0_body.kappa115 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1119.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe115 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1119.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1118.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift115 (clean : Conv.NClean (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P115.NL) (cl : SSt (· < 4997) PRE_first_tail_x8_r0_body.cx0_115.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_115.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_115.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_115.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1117.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_115.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P115 4997 PRE_first_tail_x8_r0_body.kappa115 PRE_first_tail_x8_r0_body.s1119.ffi PRE_first_tail_x8_r0_body.s1118.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift115 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue115, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp115 t ht),
    PRE_first_tail_x8_r0_body.cbridge115,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1119.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1118.ffi) (PRE_first_tail_x8_r0_body.cfoot115 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_115 PRE_first_tail_x8_r0_body.ofx1_115 hobjC PRE_first_tail_x8_r0_body.ff0115 PRE_first_tail_x8_r0_body.ff1115 PRE_first_tail_x8_r0_body.ffck115,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1119.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1118.ffi) (PRE_first_tail_x8_r0_body.cfoot115 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_115 PRE_first_tail_x8_r0_body.okr1_115 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn115) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0115 PRE_first_tail_x8_r0_body.fkt0115 PRE_first_tail_x8_r0_body.fkf1115 PRE_first_tail_x8_r0_body.fkt1115 PRE_first_tail_x8_r0_body.fkck115,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0115 PRE_first_tail_x8_r0_body.cnh1115 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe115) PRE_first_tail_x8_r0_body.cpendR115⟩

end Host.Load.Run.Tpl
end

section -- st115/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st115 0
host_stream_state PRE_first_tail_x8_r0_body.st115 1
host_stream_state PRE_first_tail_x8_r0_body.st115 2
end Host.Load.Run.Tpl
end

section -- Site115
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 115 of chain `PRE_first_tail_x8_r0_body`: `rowBlocks__g115__g116` (`rowBlocks`), the call state `PRE_first_tail_x8_r0_body.s1117`, the merged state `PRE_first_tail_x8_r0_body.s1118`,
the site template `PRE_first_tail_x8_r0_body.st115` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1119`: the merge.
The footprint's facts are in `SiteF115`, the compaction's in `SiteC115`, `SiteK115`, `SiteNa115`, `SiteNb115`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso115 : PRE_first_tail_x8_r0_body.st115.s0 = { PRE_first_tail_x8_r0_body.s1117 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs115 : List Frame := PRE_first_tail_x8_r0_body.s1117.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_115 : PRE_first_tail_x8_r0_body.S1117.tab.length = 4997
kernel_rfl PRE_first_tail_x8_r0_body.tab0_115 : PRE_first_tail_x8_r0_body.st115.S0.tab = PRE_first_tail_x8_r0_body.S1117.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws115 : List Nat := [2960, 2961]
kernel_rfl PRE_first_tail_x8_r0_body.fresh115 : (PRE_first_tail_x8_r0_body.S1117.tab.all fun e => PRE_first_tail_x8_r0_body.ws115.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1117.oracle.all fun q => PRE_first_tail_x8_r0_body.ws115.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab115 : PRE_first_tail_x8_r0_body.S1118.tab = PRE_first_tail_x8_r0_body.S1117.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws115
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen115 : PRE_first_tail_x8_r0_body.st115.S2.tab.length - PRE_first_tail_x8_r0_body.st115.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged115`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap115 : PRE_first_tail_x8_r0_body.s1118.heap = PRE_first_tail_x8_r0_body.st115.s2.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext115 : PRE_first_tail_x8_r0_body.s1118.next = PRE_first_tail_x8_r0_body.st115.s2.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl115 : PRE_first_tail_x8_r0_body.s1118.ctl = PRE_first_tail_x8_r0_body.st115.s2.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack115 : PRE_first_tail_x8_r0_body.s1118.stack = PRE_first_tail_x8_r0_body.st115.s2.stack ++ PRE_first_tail_x8_r0_body.s1117.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs115 : PRE_first_tail_x8_r0_body.s1118.jobs = PRE_first_tail_x8_r0_body.st115.s2.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi115 : PRE_first_tail_x8_r0_body.s1118.ffi = PRE_first_tail_x8_r0_body.st115.s2.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace115 : PRE_first_tail_x8_r0_body.s1118.trace = PRE_first_tail_x8_r0_body.st115.s2.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores115 : PRE_first_tail_x8_r0_body.s1118.stores = PRE_first_tail_x8_r0_body.st115.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD115
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 115 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived115 : PRE_first_tail_x8_r0_body.nr115.map (fun r => nth? PRE_first_tail_x8_r0_body.st115.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo115 : PRE_first_tail_x8_r0_body.nr115.all (Nat.ble 4997) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj115 : PRE_first_tail_x8_r0_body.cws115.all (fun c => !PRE_first_tail_x8_r0_body.ws115.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ115 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws115 PRE_first_tail_x8_r0_body.crs115 PRE_first_tail_x8_r0_body.ws115

end Host.Load.Run.Tpl
end

section -- st115/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st115`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st115.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st115.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st115.s2.heap PRE_first_tail_x8_r0_body.st115.wrR ++ freshOf PRE_first_tail_x8_r0_body.st115.s2.heap PRE_first_tail_x8_r0_body.st115.s0.next PRE_first_tail_x8_r0_body.st115.s2.next
noncomputable def PRE_first_tail_x8_r0_body.st115.wr : List Nat := PRE_first_tail_x8_r0_body.st115.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st115.heapFoot : PRE_first_tail_x8_r0_body.st115.s2.heap = setAll PRE_first_tail_x8_r0_body.st115.s0.heap PRE_first_tail_x8_r0_body.st115.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st115.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st115.s0.next PRE_first_tail_x8_r0_body.st115.s2.next = true
theorem PRE_first_tail_x8_r0_body.st115.grows : PRE_first_tail_x8_r0_body.st115.s0.next ≤ PRE_first_tail_x8_r0_body.st115.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st115.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st115.wh : List Nat := []
def PRE_first_tail_x8_r0_body.st115.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st115.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st115.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st115.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st115.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st115.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st115.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st115.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st115.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st115.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st115.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st115.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st115.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st115.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st115.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st115.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st115.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st115.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st115.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st115.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st115.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st115.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st115.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st115.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st115.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st115.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st115.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st115.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st115.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st115.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF115
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 115 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB115 : nodupT PRE_first_tail_x8_r0_body.st115.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup115 : PRE_first_tail_x8_r0_body.st115.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB115).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB115 : PRE_first_tail_x8_r0_body.st115.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound115 : ∀ b ∈ PRE_first_tail_x8_r0_body.st115.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB115 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr115 := PRE_first_tail_x8_r0_body.st115.s2.trace.take 0
kernel_rfl PRE_first_tail_x8_r0_body.traceEq115 : PRE_first_tail_x8_r0_body.st115.s2.trace = PRE_first_tail_x8_r0_body.trFr115 ++ PRE_first_tail_x8_r0_body.st115.s0.trace
theorem PRE_first_tail_x8_r0_body.trace115 : ∃ fr, PRE_first_tail_x8_r0_body.st115.s2.trace = fr ++ PRE_first_tail_x8_r0_body.st115.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq115⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide115 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB115 : (PRE_first_tail_x8_r0_body.wide115.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st115.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix115 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide115, WFix Map.id (Present PRE_first_tail_x8_r0_body.st115.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB115 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL115
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 115 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1118`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO115 : PRE_first_tail_x8_r0_body.st115.S0.oracle = PRE_first_tail_x8_r0_body.st115.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B115 : PRE_first_tail_x8_r0_body.st115.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st115.s0.next || (PRE_first_tail_x8_r0_body.st115.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot115 : Conv.StageFoot PRE_first_tail_x8_r0_body.st115.wr PRE_first_tail_x8_r0_body.st115.s0 PRE_first_tail_x8_r0_body.st115.s2 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st115.heapFoot PRE_first_tail_x8_r0_body.wrNodup115 PRE_first_tail_x8_r0_body.wrBound115 PRE_first_tail_x8_r0_body.wr0B115 PRE_first_tail_x8_r0_body.st115.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged115 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st115.F.S → PRE_first_tail_x8_r0_body.st115.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st115.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st115.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs115 PRE_first_tail_x8_r0_body.st115.wr PRE_first_tail_x8_r0_body.s1117 PRE_first_tail_x8_r0_body.st115.s2 PRE_first_tail_x8_r0_body.st115.s0
      PRE_first_tail_x8_r0_body.st115.s2.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st115.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1118 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso115 PRE_first_tail_x8_r0_body.stFoot115 PRE_first_tail_x8_r0_body.wrNodup115 PRE_first_tail_x8_r0_body.wrBound115 PRE_first_tail_x8_r0_body.trace115 PRE_first_tail_x8_r0_body.mheap115
    PRE_first_tail_x8_r0_body.mnext115 PRE_first_tail_x8_r0_body.mctl115 PRE_first_tail_x8_r0_body.mstack115 PRE_first_tail_x8_r0_body.mjobs115 PRE_first_tail_x8_r0_body.mffi115 PRE_first_tail_x8_r0_body.mtrace115 PRE_first_tail_x8_r0_body.mstores115 h

def PRE_first_tail_x8_r0_body.arrEl115_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE115_2665 : arrOf PRE_first_tail_x8_r0_body.s1118 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl115_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA115_2665 : isArrB PRE_first_tail_x8_r0_body.s1118 2665 = true
theorem PRE_first_tail_x8_r0_body.arr115_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1118.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl115_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE115_2665 PRE_first_tail_x8_r0_body.arrA115_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN115_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl115_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR115_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl115_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN115_2665

def PRE_first_tail_x8_r0_body.arrEl115_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE115_2673467 : arrOf PRE_first_tail_x8_r0_body.s1118 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl115_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA115_2673467 : isArrB PRE_first_tail_x8_r0_body.s1118 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr115_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1118.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl115_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE115_2673467 PRE_first_tail_x8_r0_body.arrA115_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN115_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl115_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR115_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl115_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN115_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k115 : isArrB PRE_first_tail_x8_r0_body.s1118 4910 = false
theorem PRE_first_tail_x8_r0_body.keep115 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1118 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k115 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr115_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl115_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ115
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 115 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1117`, the merged
state `PRE_first_tail_x8_r0_body.s1118`, the canonical state `PRE_first_tail_x8_r0_body.s1119`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl115 : PRE_first_tail_x8_r0_body.pl115.all (Nat.ble PRE_first_tail_x8_r0_body.s1117.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd115 : nodupT PRE_first_tail_x8_r0_body.pl115 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1115 : Nat.ble PRE_first_tail_x8_r0_body.s1117.next 2765221 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst115 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1117.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn115 : PRE_first_tail_x8_r0_body.s1119.next = PRE_first_tail_x8_r0_body.s1117.next + PRE_first_tail_x8_r0_body.pl115.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn115 : PRE_first_tail_x8_r0_body.s1118.next = 2765221
kernel_rfl PRE_first_tail_x8_r0_body.zgrow115 : Nat.ble PRE_first_tail_x8_r0_body.s1119.next PRE_first_tail_x8_r0_body.s1118.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh115 : PRE_first_tail_x8_r0_body.S1117.tab.all (fun e => PRE_first_tail_x8_r0_body.cws115.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd115 : nodupT PRE_first_tail_x8_r0_body.cws115 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi115 : PRE_first_tail_x8_r0_body.nr115.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1118.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt115 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1117.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg115_2665 : PRE_first_tail_x8_r0_body.s1119.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1119 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk115_2665 : (objOf PRE_first_tail_x8_r0_body.s1119 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm115_2665 : PRE_first_tail_x8_r0_body.s1118.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa115.obj (objOf PRE_first_tail_x8_r0_body.s1119 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1118 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg115_2673467 : PRE_first_tail_x8_r0_body.s1119.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1119 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk115_2673467 : (objOf PRE_first_tail_x8_r0_body.s1119 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm115_2673467 : PRE_first_tail_x8_r0_body.s1118.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa115.obj (objOf PRE_first_tail_x8_r0_body.s1119 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1118 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw115_4910 : (PRE_first_tail_x8_r0_body.s1119.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw115_2673472 : (PRE_first_tail_x8_r0_body.s1119.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw115_2673473 : (PRE_first_tail_x8_r0_body.s1119.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd115 : PRE_first_tail_x8_r0_body.cl115.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr115 : PRE_first_tail_x8_r0_body.st115.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1117.next || PRE_first_tail_x8_r0_body.cl115.contains b) = true
def PRE_first_tail_x8_r0_body.zl115 : List Nat := PRE_first_tail_x8_r0_body.cl115.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE115 : PRE_first_tail_x8_r0_body.zl115.map (fun a => PRE_first_tail_x8_r0_body.s1118.heap.get (PRE_first_tail_x8_r0_body.kappa115.a a)) = PRE_first_tail_x8_r0_body.zl115.map (fun a => (PRE_first_tail_x8_r0_body.s1119.heap.get a).map PRE_first_tail_x8_r0_body.kappa115.hobj)
theorem PRE_first_tail_x8_r0_body.zimg115 : HeapImg PRE_first_tail_x8_r0_body.kappa115 PRE_first_tail_x8_r0_body.s1119 PRE_first_tail_x8_r0_body.s1118 PRE_first_tail_x8_r0_body.zl115 := PRE_first_tail_x8_r0_body.zimgE115
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl115 : PRE_first_tail_x8_r0_body.s1118.ctl = PRE_first_tail_x8_r0_body.kappa115.ctl PRE_first_tail_x8_r0_body.s1119.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack115 : PRE_first_tail_x8_r0_body.s1118.stack = PRE_first_tail_x8_r0_body.s1119.stack.map PRE_first_tail_x8_r0_body.kappa115.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs115 : PRE_first_tail_x8_r0_body.s1118.jobs = PRE_first_tail_x8_r0_body.s1119.jobs.map PRE_first_tail_x8_r0_body.kappa115.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores115 : PRE_first_tail_x8_r0_body.s1118.stores = PRE_first_tail_x8_r0_body.kappa115.stores PRE_first_tail_x8_r0_body.s1119.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots115 : checkRootsSupp PRE_first_tail_x8_r0_body.s1119 4997 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC115 : PRE_first_tail_x8_r0_body.S1117.tab.length + PRE_first_tail_x8_r0_body.cws115.length = 4997
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap115 : PRE_first_tail_x8_r0_body.kappa115 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1117.next 2765221 PRE_first_tail_x8_r0_body.S1117.tab.length PRE_first_tail_x8_r0_body.pl115 (PRE_first_tail_x8_r0_body.nr115.map NumV.ref) PRE_first_tail_x8_r0_body.kd115.big
  PRE_first_tail_x8_r0_body.kd115.region PRE_first_tail_x8_r0_body.kd115.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin115 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1119.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc115 : Conv.jcleanListB (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1119 PRE_first_tail_x8_r0_body.cl115 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB115 : noBigRootsP (fun i => !Conv.oldBigB (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1119.trace PRE_first_tail_x8_r0_body.s1119 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm115 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 17577 = true
theorem PRE_first_tail_x8_r0_body.cjcl115 (h : Conv.JClean (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1117) : Conv.JClean (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1119 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle115)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap115 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd115 a ha)) PRE_first_tail_x8_r0_body.zjc115

end Host.Load.Run.Tpl
end

section -- st115/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st115.bodyLast from PRE_first_tail_x8_r0_body.st115.s1 to PRE_first_tail_x8_r0_body.st115.s2 :
  interpS (step PRE_first_tail_x8_r0_body.st115.F PRE_first_tail_x8_r0_body.st115.s1).run PRE_first_tail_x8_r0_body.st115.S1 = some (PRE_first_tail_x8_r0_body.st115.s2, PRE_first_tail_x8_r0_body.st115.S2)
kernel_rfl PRE_first_tail_x8_r0_body.st115.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st115.s1.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st115.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st115.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st115/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st115.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st115.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st115.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st115.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st115.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st115.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st115.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st115.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st115.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st115.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st115.s0 PRE_first_tail_x8_r0_body.st115.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st115.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st115.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st115.s1 PRE_first_tail_x8_r0_body.st115.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st115/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st115.bodyK0F from PRE_first_tail_x8_r0_body.st115.s0 to PRE_first_tail_x8_r0_body.st115.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st115.F (PRE_first_tail_x8_r0_body.st115.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st115.ks 0).getD 0) PRE_first_tail_x8_r0_body.st115.s0 PRE_first_tail_x8_r0_body.st115.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st115.s1, PRE_first_tail_x8_r0_body.st115.S1)
theorem PRE_first_tail_x8_r0_body.st115.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st115.F (PRE_first_tail_x8_r0_body.st115.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st115.ks 0).getD 0) PRE_first_tail_x8_r0_body.st115.s0 PRE_first_tail_x8_r0_body.st115.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st115.s1, PRE_first_tail_x8_r0_body.st115.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st115.bodyOkLN_ok PRE_first_tail_x8_r0_body.st115.bodyK0F
end Host.Load.Run.Tpl
end

section -- st115/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st115.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st115.F (PRE_first_tail_x8_r0_body.st115.bodyOkL bytes rows) 27 PRE_first_tail_x8_r0_body.st115.s0 PRE_first_tail_x8_r0_body.st115.S0 = some (PRE_first_tail_x8_r0_body.st115.s1, PRE_first_tail_x8_r0_body.st115.S1) :=
  (congrFun (congrFun PRE_first_tail_x8_r0_body.st115.bodyK0 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st115.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st115.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st115.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st115.F (PRE_first_tail_x8_r0_body.st115.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st115.s0
  S0 := PRE_first_tail_x8_r0_body.st115.S0
  s1 := PRE_first_tail_x8_r0_body.st115.s1
  S1 := PRE_first_tail_x8_r0_body.st115.S1
  s2 := PRE_first_tail_x8_r0_body.st115.s2
  S2 := PRE_first_tail_x8_r0_body.st115.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st115.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st115.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st115.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st115.bodyHalt
  last := PRE_first_tail_x8_r0_body.st115.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st115.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC116
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 116 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1123` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa116` into the merged state
`PRE_first_tail_x8_r0_body.s1122`. -/

def PRE_first_tail_x8_r0_body.pl116 : List Nat := [2765517]
def PRE_first_tail_x8_r0_body.nr116 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd116 : RData :=
  ⟨2765508, 2765518, Stage.setAll PTrie.nil [(2765507, 2765517)], Stage.setAll PTrie.nil [],
   20477, 20477, 17581, 17581, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa116 : Map :=
  Conv.Map.compact 2765507 2765518 5014 PRE_first_tail_x8_r0_body.pl116 (PRE_first_tail_x8_r0_body.nr116.map NumV.ref) PRE_first_tail_x8_r0_body.kd116.big
    PRE_first_tail_x8_r0_body.kd116.region PRE_first_tail_x8_r0_body.kd116.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws116 : List Nat := []
noncomputable def PRE_first_tail_x8_r0_body.crs116 : List SymE := PRE_first_tail_x8_r0_body.nr116.map fun r => (nth? PRE_first_tail_x8_r0_body.S1122.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta116 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws116 PRE_first_tail_x8_r0_body.crs116
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB116 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x8_r0_body.ctab116 : PRE_first_tail_x8_r0_body.S1123.tab = PRE_first_tail_x8_r0_body.S1121.tab ++ PRE_first_tail_x8_r0_body.cws116.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace116 : PRE_first_tail_x8_r0_body.s1123.trace = PRE_first_tail_x8_r0_body.s1121.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext116 : PRE_first_tail_x8_r0_body.s1123.next = 2765508
kernel_rfl PRE_first_tail_x8_r0_body.ccounters116 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1123.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1123.ffi).mlx.nnext) = (20477, 17581)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue116 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1122.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1123.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa116.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp116 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1123.ffi).mlx.tokens.all (bSN 5014) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean116 : Conv.cleanListB 20477 131072 (fun r => Nat.ble 81908 r) PRE_first_tail_x8_r0_body.s1123
    (PRE_first_tail_x8_r0_body.wrB116 ++ (List.range 1).map (2765507 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs116 : bigsOutB 20477 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1123.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK116
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl116`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl116 : List Nat := [2665, 2673467, 2765507]
def PRE_first_tail_x8_r0_body.clo116 : List Nat := []
def PRE_first_tail_x8_r0_body.cln116 : List Nat := []
def PRE_first_tail_x8_r0_body.cli116 : List Nat := []
kernel_rfl PRE_first_tail_x8_r0_body.cheap116 : PRE_first_tail_x8_r0_body.s1123.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1121.heap (PRE_first_tail_x8_r0_body.cl116.filterMap fun a => (PRE_first_tail_x8_r0_body.s1123.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe116 : Nat.ble PRE_first_tail_x8_r0_body.s1121.next PRE_first_tail_x8_r0_body.s1123.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP116 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1121 PRE_first_tail_x8_r0_body.s1123 PRE_first_tail_x8_r0_body.cl116 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp116 : Conv.suppListB PRE_first_tail_x8_r0_body.s1123 5014 PRE_first_tail_x8_r0_body.cl116 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound116 : Conv.boundListB PRE_first_tail_x8_r0_body.s1123 PRE_first_tail_x8_r0_body.cl116 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK116 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1123.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln116.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1123.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK116 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1123.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo116.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1123.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK116 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1123.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli116.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1123.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst116 : Conv.sstListB 5014 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1123.ffi).mlx PRE_first_tail_x8_r0_body.cln116 PRE_first_tail_x8_r0_body.clo116 PRE_first_tail_x8_r0_body.cli116 = true

end Host.Load.Run.Tpl
end

section -- SiteCl116
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA116 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1123.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo116.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1123.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd116 : (PRE_first_tail_x8_r0_body.clo116 ++ PRE_first_tail_x8_r0_body.cln116 ++ PRE_first_tail_x8_r0_body.cli116).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle116 : Conv.Cnt.leB (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt) (⟨20477, 17581, 2765508, 5014⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck116 : Conv.ncleanListB (⟨20477, 17581, 2765508, 5014⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1123.ffi).mlx PRE_first_tail_x8_r0_body.clo116 PRE_first_tail_x8_r0_body.cln116 PRE_first_tail_x8_r0_body.cli116 = true
theorem PRE_first_tail_x8_r0_body.cncl116 (h : Conv.NClean (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx) : Conv.NClean (⟨20477, 17581, 2765508, 5014⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1123.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle116 PRE_first_tail_x8_r0_body.ckA116 PRE_first_tail_x8_r0_body.cobjsK116 PRE_first_tail_x8_r0_body.cnodesK116 PRE_first_tail_x8_r0_body.citemsK116 PRE_first_tail_x8_r0_body.cbd116 PRE_first_tail_x8_r0_body.cck116

end Host.Load.Run.Tpl
end

section -- SiteS116
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 116 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc116 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P116 : LoadP := PRE_first_tail_x8_r0_body.Pc116.raise 17581
kernel_rfl PRE_first_tail_x8_r0_body.craise116 : Nat.ble PRE_first_tail_x8_r0_body.Pc116.N0 17581 = true
theorem PRE_first_tail_x8_r0_body.raised116 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc116 PRE_first_tail_x8_r0_body.P116 :=
  .inr ⟨17581, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise116, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_116 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1123.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_116 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1122.ffi)
def PRE_first_tail_x8_r0_body.khinv116 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x8_r0_body.kninv116 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS116 : List Nat := []
def PRE_first_tail_x8_r0_body.cnS116 : List Nat := List.range' 17581 0
def PRE_first_tail_x8_r0_body.ciS116 : List Nat := [] ++ List.range' 17581 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0116 : PRE_first_tail_x8_r0_body.kd116.nh0 = PRE_first_tail_x8_r0_body.cx0_116.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1116 : PRE_first_tail_x8_r0_body.kd116.nh1 = PRE_first_tail_x8_r0_body.cx1_116.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0116 : PRE_first_tail_x8_r0_body.kd116.nn0 = PRE_first_tail_x8_r0_body.cx0_116.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1116 : PRE_first_tail_x8_r0_body.kd116.nn1 = PRE_first_tail_x8_r0_body.cx1_116.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo116 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P116.lo && Nat.ble PRE_first_tail_x8_r0_body.P116.lo PRE_first_tail_x8_r0_body.cx0_116.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P116.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P116.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt116 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_116.mlx.next PRE_first_tail_x8_r0_body.cx1_116.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_116.mlx.nnext PRE_first_tail_x8_r0_body.cx1_116.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband116 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P116.NL && Nat.ble PRE_first_tail_x8_r0_body.P116.NL PRE_first_tail_x8_r0_body.P116.N0 && Nat.ble PRE_first_tail_x8_r0_body.P116.N0 PRE_first_tail_x8_r0_body.cx0_116.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow116 : PRE_first_tail_x8_r0_body.kd116.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren116 : checkRenG PRE_first_tail_x8_r0_body.kd116.hnd PRE_first_tail_x8_r0_body.khinv116 (phB PRE_first_tail_x8_r0_body.cx0_116.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband116 : PRE_first_tail_x8_r0_body.kd116.checkBand PRE_first_tail_x8_r0_body.P116.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos116 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd116.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren116 : checkRenG PRE_first_tail_x8_r0_body.kd116.node PRE_first_tail_x8_r0_body.kninv116 (pnB PRE_first_tail_x8_r0_body.cx0_116.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow116 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd116.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P116.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd116.nodeF j) PRE_first_tail_x8_r0_body.cx1_116.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a116 : PRE_first_tail_x8_r0_body.cx0_116.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b116 : PRE_first_tail_x8_r0_body.cx0_116.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1116 : PRE_first_tail_x8_r0_body.cx1_116.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend116 : PRE_first_tail_x8_r0_body.cx1_116.mlx.pending = PRE_first_tail_x8_r0_body.cx0_116.mlx.pending.map PRE_first_tail_x8_r0_body.kappa116.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh116 : PRE_first_tail_x8_r0_body.cx1_116.mlx.errh = PRE_first_tail_x8_r0_body.cx0_116.mlx.errh.map PRE_first_tail_x8_r0_body.kappa116.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles116 : PRE_first_tail_x8_r0_body.cx1_116.mlx.files = PRE_first_tail_x8_r0_body.cx0_116.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch116 : PRE_first_tail_x8_r0_body.cx1_116.mlx.arch = PRE_first_tail_x8_r0_body.cx0_116.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes116 : PRE_first_tail_x8_r0_body.cx1_116.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_116.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired116 : PRE_first_tail_x8_r0_body.cx1_116.mlx.wired = PRE_first_tail_x8_r0_body.cx0_116.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost116 : PRE_first_tail_x8_r0_body.cx1_116.host = PRE_first_tail_x8_r0_body.cx0_116.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd116`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0116 : PRE_first_tail_x8_r0_body.kd116.n0 = 2765508
kernel_rfl PRE_first_tail_x8_r0_body.ckn1116 : PRE_first_tail_x8_r0_body.kd116.n1 = 2765518
kernel_rfl PRE_first_tail_x8_r0_body.ckheap116 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd116.heap).all (fun x => Nat.ble 2765507 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl116 : (List.range 1).all (fun j => decide (PRE_first_tail_x8_r0_body.kd116.heap.get (2765507 + j) = nth? PRE_first_tail_x8_r0_body.pl116 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja116 : Nat.ble 2765507 2765507 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn116 : Nat.ble 5014 5014 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD116 : Nat.ble 2765507 PRE_first_tail_x8_r0_body.kd116.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn116 : Nat.ble 20477 PRE_first_tail_x8_r0_body.kd116.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn116 : Nat.ble 17581 PRE_first_tail_x8_r0_body.kd116.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb116 : Nat.ble 20477 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap116 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd116.heap).all (Nat.ble (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd116 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd116.hnd).all (Nat.ble (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode116 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd116.node).all (Nat.ble (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix116 : Conv.FixOld (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa116 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja116) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn116) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD116) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn116) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn116) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb116) PRE_first_tail_x8_r0_body.fheap116 PRE_first_tail_x8_r0_body.fhnd116 PRE_first_tail_x8_r0_body.fnode116
kernel_rfl PRE_first_tail_x8_r0_body.fcxn116 : (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn116 : (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0116 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_116.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_116.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk116 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd116.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A116 : PRE_first_tail_x8_r0_body.cx1_116.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS116.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_116.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O116 : PRE_first_tail_x8_r0_body.cx1_116.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS116.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_116.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N116 : PRE_first_tail_x8_r0_body.cx1_116.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS116.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_116.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I116 : PRE_first_tail_x8_r0_body.cx1_116.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS116.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_116.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd116 : (PRE_first_tail_x8_r0_body.clo116 ++ PRE_first_tail_x8_r0_body.cln116 ++ PRE_first_tail_x8_r0_body.cli116 ++ PRE_first_tail_x8_r0_body.cwS116 ++ PRE_first_tail_x8_r0_body.cnS116 ++ PRE_first_tail_x8_r0_body.ciS116).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW116 : PRE_first_tail_x8_r0_body.cwS116.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo116.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI116 : PRE_first_tail_x8_r0_body.ciS116.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli116.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN116 : PRE_first_tail_x8_r0_body.cnS116.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF116 : PRE_first_tail_x8_r0_body.cln116.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh116 : PRE_first_tail_x8_r0_body.clo116.all (handleOK PRE_first_tail_x8_r0_body.kappa116 PRE_first_tail_x8_r0_body.P116.lo PRE_first_tail_x8_r0_body.cx0_116.mlx PRE_first_tail_x8_r0_body.cx1_116.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo116 : PRE_first_tail_x8_r0_body.clo116.map (fun h => PRE_first_tail_x8_r0_body.cx1_116.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa116.handle h)) = PRE_first_tail_x8_r0_body.clo116.map (fun h => (PRE_first_tail_x8_r0_body.cx0_116.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa116.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok116 : PRE_first_tail_x8_r0_body.clo116.all (objOK PRE_first_tail_x8_r0_body.kappa116 PRE_first_tail_x8_r0_body.P116.NL PRE_first_tail_x8_r0_body.cx0_116.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd116 : PRE_first_tail_x8_r0_body.cln116.all (nodeOKF PRE_first_tail_x8_r0_body.kappa116 PRE_first_tail_x8_r0_body.P116 PRE_first_tail_x8_r0_body.cx0_116.mlx PRE_first_tail_x8_r0_body.cx1_116.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp116 : ((PRE_first_tail_x8_r0_body.cln116.filter (fullB PRE_first_tail_x8_r0_body.P116))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_116.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa116.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln116.filter (fullB PRE_first_tail_x8_r0_body.P116))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_116.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa116.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI116 : incrB PRE_first_tail_x8_r0_body.kd116.nodeF (List.range' 17581 0) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK116 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd116.node).all (fun k => Nat.ble 17581 k && Nat.blt k 17581) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL116 : (PRE_first_tail_x8_r0_body.cln116.filter (Nat.ble PRE_first_tail_x8_r0_body.P116.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd116.nodeF i) && (Nat.blt i 17581 || Nat.ble PRE_first_tail_x8_r0_body.kd116.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord116 : (PRE_first_tail_x8_r0_body.cln116.filter (Nat.ble PRE_first_tail_x8_r0_body.P116.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd116.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd116.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd116.nodeF j) (PRE_first_tail_x8_r0_body.kd116.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow116 PRE_first_tail_x8_r0_body.cnn1116 PRE_first_tail_x8_r0_body.fnordI116 PRE_first_tail_x8_r0_body.fnordK116 PRE_first_tail_x8_r0_body.fnordL116
kernel_rfl PRE_first_tail_x8_r0_body.fi116 : PRE_first_tail_x8_r0_body.cli116.all (pnB PRE_first_tail_x8_r0_body.cx0_116.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii116 : PRE_first_tail_x8_r0_body.cli116.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_116.mlx.items.get (PRE_first_tail_x8_r0_body.kappa116.node k) = (PRE_first_tail_x8_r0_body.cx0_116.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa116.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot116 (clean : Conv.NClean (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P116.NL) (cl : SSt (· < 5014) PRE_first_tail_x8_r0_body.cx0_116.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P116 5014 PRE_first_tail_x8_r0_body.kappa116 PRE_first_tail_x8_r0_body.kd116 PRE_first_tail_x8_r0_body.khinv116 PRE_first_tail_x8_r0_body.kninv116 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx PRE_first_tail_x8_r0_body.cx0_116.mlx PRE_first_tail_x8_r0_body.cx1_116.mlx (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo116 PRE_first_tail_x8_r0_body.cln116 PRE_first_tail_x8_r0_body.cli116 PRE_first_tail_x8_r0_body.cwS116 PRE_first_tail_x8_r0_body.cnS116 PRE_first_tail_x8_r0_body.ciS116 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0116, PRE_first_tail_x8_r0_body.cnh1116, PRE_first_tail_x8_r0_body.cnn0116, PRE_first_tail_x8_r0_body.cnn1116, PRE_first_tail_x8_r0_body.cplo116, PRE_first_tail_x8_r0_body.ccnt116, PRE_first_tail_x8_r0_body.cnband116, PRE_first_tail_x8_r0_body.chbelow116, PRE_first_tail_x8_r0_body.chren116, PRE_first_tail_x8_r0_body.cband116, PRE_first_tail_x8_r0_body.cnh1pos116, PRE_first_tail_x8_r0_body.cnren116, PRE_first_tail_x8_r0_body.cnlow116, PRE_first_tail_x8_r0_body.cabs0a116, PRE_first_tail_x8_r0_body.cabs0b116, PRE_first_tail_x8_r0_body.ctok1116, PRE_first_tail_x8_r0_body.cpend116, PRE_first_tail_x8_r0_body.cerrh116, PRE_first_tail_x8_r0_body.cfiles116, PRE_first_tail_x8_r0_body.carch116, PRE_first_tail_x8_r0_body.csizes116, PRE_first_tail_x8_r0_body.cwired116, PRE_first_tail_x8_r0_body.cfix116, clean, PRE_first_tail_x8_r0_body.fcxn116, PRE_first_tail_x8_r0_body.fcnn116, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0116, PRE_first_tail_x8_r0_body.fnk116, PRE_first_tail_x8_r0_body.ckA116, PRE_first_tail_x8_r0_body.cobjsK116, PRE_first_tail_x8_r0_body.cnodesK116, PRE_first_tail_x8_r0_body.citemsK116, PRE_first_tail_x8_r0_body.f1A116, PRE_first_tail_x8_r0_body.f1O116, PRE_first_tail_x8_r0_body.f1N116, PRE_first_tail_x8_r0_body.f1I116, PRE_first_tail_x8_r0_body.fbd116, PRE_first_tail_x8_r0_body.fincW116, PRE_first_tail_x8_r0_body.fincI116, PRE_first_tail_x8_r0_body.fincN116, PRE_first_tail_x8_r0_body.flnF116, PRE_first_tail_x8_r0_body.fh116, PRE_first_tail_x8_r0_body.fo116, PRE_first_tail_x8_r0_body.fok116, PRE_first_tail_x8_r0_body.fnd116, PRE_first_tail_x8_r0_body.fp116, PRE_first_tail_x8_r0_body.fnord116, PRE_first_tail_x8_r0_body.fi116, PRE_first_tail_x8_r0_body.fii116⟩
theorem PRE_first_tail_x8_r0_body.cnshift116 (clean : Conv.NClean (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P116.NL) (cl : SSt (· < 5014) PRE_first_tail_x8_r0_body.cx0_116.mlx) : NShift PRE_first_tail_x8_r0_body.P116 5014 PRE_first_tail_x8_r0_body.kappa116 PRE_first_tail_x8_r0_body.cx0_116 PRE_first_tail_x8_r0_body.cx1_116 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot116 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost116 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0116 PRE_first_tail_x8_r0_body.ckn1116 PRE_first_tail_x8_r0_body.ckheap116 PRE_first_tail_x8_r0_body.ckpl116)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_116 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1121.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_116 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1121.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_116 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1121.ffi) = some PRE_first_tail_x8_r0_body.fxC_116
kernel_rfl PRE_first_tail_x8_r0_body.okrC_116 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1121.ffi) = some PRE_first_tail_x8_r0_body.krC_116
noncomputable def PRE_first_tail_x8_r0_body.fx0_116 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1123.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_116 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1123.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_116 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1123.ffi) = some PRE_first_tail_x8_r0_body.fx0_116
kernel_rfl PRE_first_tail_x8_r0_body.okr0_116 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1123.ffi) = some PRE_first_tail_x8_r0_body.kr0_116
noncomputable def PRE_first_tail_x8_r0_body.fx1_116 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1122.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_116 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1122.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_116 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1122.ffi) = some PRE_first_tail_x8_r0_body.fx1_116
kernel_rfl PRE_first_tail_x8_r0_body.okr1_116 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1122.ffi) = some PRE_first_tail_x8_r0_body.kr1_116
kernel_rfl PRE_first_tail_x8_r0_body.ff0116 : PRE_first_tail_x8_r0_body.fx0_116 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_116 (PRE_first_tail_x8_r0_body.clo116.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_116.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1116 : PRE_first_tail_x8_r0_body.fx1_116 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_116 (PRE_first_tail_x8_r0_body.cwS116.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_116.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck116 : freedLB PRE_first_tail_x8_r0_body.kappa116 PRE_first_tail_x8_r0_body.cx0_116.mlx PRE_first_tail_x8_r0_body.fx0_116 PRE_first_tail_x8_r0_body.fx1_116 PRE_first_tail_x8_r0_body.clo116 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0116 : PRE_first_tail_x8_r0_body.kr0_116.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_116.flags (PRE_first_tail_x8_r0_body.clo116.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_116.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0116 : PRE_first_tail_x8_r0_body.kr0_116.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_116.targs (PRE_first_tail_x8_r0_body.clo116.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_116.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1116 : PRE_first_tail_x8_r0_body.kr1_116.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_116.flags (PRE_first_tail_x8_r0_body.cwS116.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_116.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1116 : PRE_first_tail_x8_r0_body.kr1_116.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_116.targs (PRE_first_tail_x8_r0_body.cwS116.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_116.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck116 : krecLB PRE_first_tail_x8_r0_body.kappa116 5014 PRE_first_tail_x8_r0_body.cx0_116.mlx PRE_first_tail_x8_r0_body.kr0_116 PRE_first_tail_x8_r0_body.kr1_116 PRE_first_tail_x8_r0_body.clo116 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn116 : Nat.ble 5014 5014 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge116 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1122.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1123.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR116 : pendRegB PRE_first_tail_x8_r0_body.kappa116 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1123.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe116 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1123.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1122.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift116 (clean : Conv.NClean (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P116.NL) (cl : SSt (· < 5014) PRE_first_tail_x8_r0_body.cx0_116.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_116.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_116.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_116.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1121.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_116.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P116 5014 PRE_first_tail_x8_r0_body.kappa116 PRE_first_tail_x8_r0_body.s1123.ffi PRE_first_tail_x8_r0_body.s1122.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift116 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue116, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp116 t ht),
    PRE_first_tail_x8_r0_body.cbridge116,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1123.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1122.ffi) (PRE_first_tail_x8_r0_body.cfoot116 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_116 PRE_first_tail_x8_r0_body.ofx1_116 hobjC PRE_first_tail_x8_r0_body.ff0116 PRE_first_tail_x8_r0_body.ff1116 PRE_first_tail_x8_r0_body.ffck116,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1123.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1122.ffi) (PRE_first_tail_x8_r0_body.cfoot116 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_116 PRE_first_tail_x8_r0_body.okr1_116 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn116) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0116 PRE_first_tail_x8_r0_body.fkt0116 PRE_first_tail_x8_r0_body.fkf1116 PRE_first_tail_x8_r0_body.fkt1116 PRE_first_tail_x8_r0_body.fkck116,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0116 PRE_first_tail_x8_r0_body.cnh1116 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe116) PRE_first_tail_x8_r0_body.cpendR116⟩

end Host.Load.Run.Tpl
end

section -- st116/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st116 0
host_stream_state PRE_first_tail_x8_r0_body.st116 1
host_stream_state PRE_first_tail_x8_r0_body.st116 2
end Host.Load.Run.Tpl
end

section -- Site116
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 116 of chain `PRE_first_tail_x8_r0_body`: `plan__g116__g117` (`plan`), the call state `PRE_first_tail_x8_r0_body.s1121`, the merged state `PRE_first_tail_x8_r0_body.s1122`,
the site template `PRE_first_tail_x8_r0_body.st116` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1123`: the merge.
The footprint's facts are in `SiteF116`, the compaction's in `SiteC116`, `SiteK116`, `SiteNa116`, `SiteNb116`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso116 : PRE_first_tail_x8_r0_body.st116.s0 = { PRE_first_tail_x8_r0_body.s1121 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs116 : List Frame := PRE_first_tail_x8_r0_body.s1121.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_116 : PRE_first_tail_x8_r0_body.S1121.tab.length = 5014
kernel_rfl PRE_first_tail_x8_r0_body.tab0_116 : PRE_first_tail_x8_r0_body.st116.S0.tab = PRE_first_tail_x8_r0_body.S1121.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws116 : List Nat := [2962, 2963, 2964]
kernel_rfl PRE_first_tail_x8_r0_body.fresh116 : (PRE_first_tail_x8_r0_body.S1121.tab.all fun e => PRE_first_tail_x8_r0_body.ws116.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1121.oracle.all fun q => PRE_first_tail_x8_r0_body.ws116.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab116 : PRE_first_tail_x8_r0_body.S1122.tab = PRE_first_tail_x8_r0_body.S1121.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws116
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen116 : PRE_first_tail_x8_r0_body.st116.S2.tab.length - PRE_first_tail_x8_r0_body.st116.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged116`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap116 : PRE_first_tail_x8_r0_body.s1122.heap = PRE_first_tail_x8_r0_body.st116.s2.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext116 : PRE_first_tail_x8_r0_body.s1122.next = PRE_first_tail_x8_r0_body.st116.s2.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl116 : PRE_first_tail_x8_r0_body.s1122.ctl = PRE_first_tail_x8_r0_body.st116.s2.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack116 : PRE_first_tail_x8_r0_body.s1122.stack = PRE_first_tail_x8_r0_body.st116.s2.stack ++ PRE_first_tail_x8_r0_body.s1121.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs116 : PRE_first_tail_x8_r0_body.s1122.jobs = PRE_first_tail_x8_r0_body.st116.s2.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi116 : PRE_first_tail_x8_r0_body.s1122.ffi = PRE_first_tail_x8_r0_body.st116.s2.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace116 : PRE_first_tail_x8_r0_body.s1122.trace = PRE_first_tail_x8_r0_body.st116.s2.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores116 : PRE_first_tail_x8_r0_body.s1122.stores = PRE_first_tail_x8_r0_body.st116.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD116
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 116 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived116 : PRE_first_tail_x8_r0_body.nr116.map (fun r => nth? PRE_first_tail_x8_r0_body.st116.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo116 : PRE_first_tail_x8_r0_body.nr116.all (Nat.ble 5014) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj116 : PRE_first_tail_x8_r0_body.cws116.all (fun c => !PRE_first_tail_x8_r0_body.ws116.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ116 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws116 PRE_first_tail_x8_r0_body.crs116 PRE_first_tail_x8_r0_body.ws116

end Host.Load.Run.Tpl
end

section -- st116/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st116`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st116.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st116.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st116.s2.heap PRE_first_tail_x8_r0_body.st116.wrR ++ freshOf PRE_first_tail_x8_r0_body.st116.s2.heap PRE_first_tail_x8_r0_body.st116.s0.next PRE_first_tail_x8_r0_body.st116.s2.next
noncomputable def PRE_first_tail_x8_r0_body.st116.wr : List Nat := PRE_first_tail_x8_r0_body.st116.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st116.heapFoot : PRE_first_tail_x8_r0_body.st116.s2.heap = setAll PRE_first_tail_x8_r0_body.st116.s0.heap PRE_first_tail_x8_r0_body.st116.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st116.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st116.s0.next PRE_first_tail_x8_r0_body.st116.s2.next = true
theorem PRE_first_tail_x8_r0_body.st116.grows : PRE_first_tail_x8_r0_body.st116.s0.next ≤ PRE_first_tail_x8_r0_body.st116.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st116.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st116.wh : List Nat := []
def PRE_first_tail_x8_r0_body.st116.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st116.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st116.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st116.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st116.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st116.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st116.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st116.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st116.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st116.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st116.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st116.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st116.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st116.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st116.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st116.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st116.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st116.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st116.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st116.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st116.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st116.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st116.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st116.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st116.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st116.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st116.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st116.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st116.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st116.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF116
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 116 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB116 : nodupT PRE_first_tail_x8_r0_body.st116.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup116 : PRE_first_tail_x8_r0_body.st116.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB116).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB116 : PRE_first_tail_x8_r0_body.st116.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound116 : ∀ b ∈ PRE_first_tail_x8_r0_body.st116.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB116 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr116 := PRE_first_tail_x8_r0_body.st116.s2.trace.take 0
kernel_rfl PRE_first_tail_x8_r0_body.traceEq116 : PRE_first_tail_x8_r0_body.st116.s2.trace = PRE_first_tail_x8_r0_body.trFr116 ++ PRE_first_tail_x8_r0_body.st116.s0.trace
theorem PRE_first_tail_x8_r0_body.trace116 : ∃ fr, PRE_first_tail_x8_r0_body.st116.s2.trace = fr ++ PRE_first_tail_x8_r0_body.st116.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq116⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide116 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB116 : (PRE_first_tail_x8_r0_body.wide116.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st116.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix116 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide116, WFix Map.id (Present PRE_first_tail_x8_r0_body.st116.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB116 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL116
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 116 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1122`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO116 : PRE_first_tail_x8_r0_body.st116.S0.oracle = PRE_first_tail_x8_r0_body.st116.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B116 : PRE_first_tail_x8_r0_body.st116.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st116.s0.next || (PRE_first_tail_x8_r0_body.st116.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot116 : Conv.StageFoot PRE_first_tail_x8_r0_body.st116.wr PRE_first_tail_x8_r0_body.st116.s0 PRE_first_tail_x8_r0_body.st116.s2 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st116.heapFoot PRE_first_tail_x8_r0_body.wrNodup116 PRE_first_tail_x8_r0_body.wrBound116 PRE_first_tail_x8_r0_body.wr0B116 PRE_first_tail_x8_r0_body.st116.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged116 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st116.F.S → PRE_first_tail_x8_r0_body.st116.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st116.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st116.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs116 PRE_first_tail_x8_r0_body.st116.wr PRE_first_tail_x8_r0_body.s1121 PRE_first_tail_x8_r0_body.st116.s2 PRE_first_tail_x8_r0_body.st116.s0
      PRE_first_tail_x8_r0_body.st116.s2.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st116.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1122 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso116 PRE_first_tail_x8_r0_body.stFoot116 PRE_first_tail_x8_r0_body.wrNodup116 PRE_first_tail_x8_r0_body.wrBound116 PRE_first_tail_x8_r0_body.trace116 PRE_first_tail_x8_r0_body.mheap116
    PRE_first_tail_x8_r0_body.mnext116 PRE_first_tail_x8_r0_body.mctl116 PRE_first_tail_x8_r0_body.mstack116 PRE_first_tail_x8_r0_body.mjobs116 PRE_first_tail_x8_r0_body.mffi116 PRE_first_tail_x8_r0_body.mtrace116 PRE_first_tail_x8_r0_body.mstores116 h

def PRE_first_tail_x8_r0_body.arrEl116_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE116_2665 : arrOf PRE_first_tail_x8_r0_body.s1122 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl116_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA116_2665 : isArrB PRE_first_tail_x8_r0_body.s1122 2665 = true
theorem PRE_first_tail_x8_r0_body.arr116_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1122.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl116_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE116_2665 PRE_first_tail_x8_r0_body.arrA116_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN116_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl116_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR116_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl116_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN116_2665

def PRE_first_tail_x8_r0_body.arrEl116_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE116_2673467 : arrOf PRE_first_tail_x8_r0_body.s1122 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl116_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA116_2673467 : isArrB PRE_first_tail_x8_r0_body.s1122 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr116_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1122.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl116_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE116_2673467 PRE_first_tail_x8_r0_body.arrA116_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN116_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl116_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR116_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl116_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN116_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k116 : isArrB PRE_first_tail_x8_r0_body.s1122 4910 = false
theorem PRE_first_tail_x8_r0_body.keep116 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1122 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k116 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr116_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl116_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ116
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 116 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1121`, the merged
state `PRE_first_tail_x8_r0_body.s1122`, the canonical state `PRE_first_tail_x8_r0_body.s1123`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl116 : PRE_first_tail_x8_r0_body.pl116.all (Nat.ble PRE_first_tail_x8_r0_body.s1121.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd116 : nodupT PRE_first_tail_x8_r0_body.pl116 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1116 : Nat.ble PRE_first_tail_x8_r0_body.s1121.next 2765518 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst116 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1121.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn116 : PRE_first_tail_x8_r0_body.s1123.next = PRE_first_tail_x8_r0_body.s1121.next + PRE_first_tail_x8_r0_body.pl116.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn116 : PRE_first_tail_x8_r0_body.s1122.next = 2765518
kernel_rfl PRE_first_tail_x8_r0_body.zgrow116 : Nat.ble PRE_first_tail_x8_r0_body.s1123.next PRE_first_tail_x8_r0_body.s1122.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh116 : PRE_first_tail_x8_r0_body.S1121.tab.all (fun e => PRE_first_tail_x8_r0_body.cws116.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd116 : nodupT PRE_first_tail_x8_r0_body.cws116 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi116 : PRE_first_tail_x8_r0_body.nr116.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1122.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt116 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1121.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg116_2665 : PRE_first_tail_x8_r0_body.s1123.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1123 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk116_2665 : (objOf PRE_first_tail_x8_r0_body.s1123 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm116_2665 : PRE_first_tail_x8_r0_body.s1122.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa116.obj (objOf PRE_first_tail_x8_r0_body.s1123 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1122 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg116_2673467 : PRE_first_tail_x8_r0_body.s1123.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1123 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk116_2673467 : (objOf PRE_first_tail_x8_r0_body.s1123 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm116_2673467 : PRE_first_tail_x8_r0_body.s1122.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa116.obj (objOf PRE_first_tail_x8_r0_body.s1123 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1122 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw116_4910 : (PRE_first_tail_x8_r0_body.s1123.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw116_2673472 : (PRE_first_tail_x8_r0_body.s1123.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw116_2673473 : (PRE_first_tail_x8_r0_body.s1123.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd116 : PRE_first_tail_x8_r0_body.cl116.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr116 : PRE_first_tail_x8_r0_body.st116.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1121.next || PRE_first_tail_x8_r0_body.cl116.contains b) = true
def PRE_first_tail_x8_r0_body.zl116 : List Nat := PRE_first_tail_x8_r0_body.cl116.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE116 : PRE_first_tail_x8_r0_body.zl116.map (fun a => PRE_first_tail_x8_r0_body.s1122.heap.get (PRE_first_tail_x8_r0_body.kappa116.a a)) = PRE_first_tail_x8_r0_body.zl116.map (fun a => (PRE_first_tail_x8_r0_body.s1123.heap.get a).map PRE_first_tail_x8_r0_body.kappa116.hobj)
theorem PRE_first_tail_x8_r0_body.zimg116 : HeapImg PRE_first_tail_x8_r0_body.kappa116 PRE_first_tail_x8_r0_body.s1123 PRE_first_tail_x8_r0_body.s1122 PRE_first_tail_x8_r0_body.zl116 := PRE_first_tail_x8_r0_body.zimgE116
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl116 : PRE_first_tail_x8_r0_body.s1122.ctl = PRE_first_tail_x8_r0_body.kappa116.ctl PRE_first_tail_x8_r0_body.s1123.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack116 : PRE_first_tail_x8_r0_body.s1122.stack = PRE_first_tail_x8_r0_body.s1123.stack.map PRE_first_tail_x8_r0_body.kappa116.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs116 : PRE_first_tail_x8_r0_body.s1122.jobs = PRE_first_tail_x8_r0_body.s1123.jobs.map PRE_first_tail_x8_r0_body.kappa116.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores116 : PRE_first_tail_x8_r0_body.s1122.stores = PRE_first_tail_x8_r0_body.kappa116.stores PRE_first_tail_x8_r0_body.s1123.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots116 : checkRootsSupp PRE_first_tail_x8_r0_body.s1123 5014 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC116 : PRE_first_tail_x8_r0_body.S1121.tab.length + PRE_first_tail_x8_r0_body.cws116.length = 5014
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap116 : PRE_first_tail_x8_r0_body.kappa116 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1121.next 2765518 PRE_first_tail_x8_r0_body.S1121.tab.length PRE_first_tail_x8_r0_body.pl116 (PRE_first_tail_x8_r0_body.nr116.map NumV.ref) PRE_first_tail_x8_r0_body.kd116.big
  PRE_first_tail_x8_r0_body.kd116.region PRE_first_tail_x8_r0_body.kd116.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin116 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1123.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc116 : Conv.jcleanListB (⟨20477, 17581, 2765508, 5014⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1123 PRE_first_tail_x8_r0_body.cl116 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB116 : noBigRootsP (fun i => !Conv.oldBigB (⟨20477, 17581, 2765508, 5014⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1123.trace PRE_first_tail_x8_r0_body.s1123 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm116 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 17581 = true
theorem PRE_first_tail_x8_r0_body.cjcl116 (h : Conv.JClean (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1121) : Conv.JClean (⟨20477, 17581, 2765508, 5014⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1123 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle116)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap116 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd116 a ha)) PRE_first_tail_x8_r0_body.zjc116

end Host.Load.Run.Tpl
end

section -- st116/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st116.bodyLast from PRE_first_tail_x8_r0_body.st116.s1 to PRE_first_tail_x8_r0_body.st116.s2 :
  interpS (step PRE_first_tail_x8_r0_body.st116.F PRE_first_tail_x8_r0_body.st116.s1).run PRE_first_tail_x8_r0_body.st116.S1 = some (PRE_first_tail_x8_r0_body.st116.s2, PRE_first_tail_x8_r0_body.st116.S2)
kernel_rfl PRE_first_tail_x8_r0_body.st116.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st116.s1.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st116.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st116.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st116/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st116.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st116.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st116.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st116.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st116.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st116.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st116.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st116.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st116.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st116.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st116.s0 PRE_first_tail_x8_r0_body.st116.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st116.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st116.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st116.s1 PRE_first_tail_x8_r0_body.st116.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st116/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st116.bodyK0F from PRE_first_tail_x8_r0_body.st116.s0 to PRE_first_tail_x8_r0_body.st116.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st116.F (PRE_first_tail_x8_r0_body.st116.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st116.ks 0).getD 0) PRE_first_tail_x8_r0_body.st116.s0 PRE_first_tail_x8_r0_body.st116.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st116.s1, PRE_first_tail_x8_r0_body.st116.S1)
theorem PRE_first_tail_x8_r0_body.st116.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st116.F (PRE_first_tail_x8_r0_body.st116.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st116.ks 0).getD 0) PRE_first_tail_x8_r0_body.st116.s0 PRE_first_tail_x8_r0_body.st116.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st116.s1, PRE_first_tail_x8_r0_body.st116.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st116.bodyOkLN_ok PRE_first_tail_x8_r0_body.st116.bodyK0F
end Host.Load.Run.Tpl
end

section -- st116/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st116.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st116.F (PRE_first_tail_x8_r0_body.st116.bodyOkL bytes rows) 98 PRE_first_tail_x8_r0_body.st116.s0 PRE_first_tail_x8_r0_body.st116.S0 = some (PRE_first_tail_x8_r0_body.st116.s1, PRE_first_tail_x8_r0_body.st116.S1) :=
  (congrFun (congrFun PRE_first_tail_x8_r0_body.st116.bodyK0 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st116.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st116.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st116.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st116.F (PRE_first_tail_x8_r0_body.st116.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st116.s0
  S0 := PRE_first_tail_x8_r0_body.st116.S0
  s1 := PRE_first_tail_x8_r0_body.st116.s1
  S1 := PRE_first_tail_x8_r0_body.st116.S1
  s2 := PRE_first_tail_x8_r0_body.st116.s2
  S2 := PRE_first_tail_x8_r0_body.st116.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st116.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st116.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st116.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st116.bodyHalt
  last := PRE_first_tail_x8_r0_body.st116.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st116.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC117
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 117 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1139` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa117` into the merged state
`PRE_first_tail_x8_r0_body.s1138`. -/

def PRE_first_tail_x8_r0_body.pl117 : List Nat := [2767606, 2767442, 2767494, 2767607, 2767608, 2767444, 2767496, 2767605, 2767604, 2767603, 2767602, 2767596, 2767547, 2767598, 2767549]
def PRE_first_tail_x8_r0_body.nr117 : List Nat := [5099, 5100, 5096, 5102, 5098, 5106, 5107, 5104, 5105]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd117 : RData :=
  ⟨2767259, 2767609, Stage.setAll PTrie.nil [(2767244, 2767606), (2767245, 2767442), (2767246, 2767494), (2767247, 2767607), (2767248, 2767608), (2767249, 2767444), (2767250, 2767496), (2767251, 2767605), (2767252, 2767604), (2767253, 2767603), (2767254, 2767602), (2767255, 2767596), (2767256, 2767547), (2767257, 2767598), (2767258, 2767549)], Stage.setAll PTrie.nil [(20517, 20519), (20518, 20520), (20519, 20522), (20520, 20521)],
   20521, 20523, 17615, 17615, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(5091, .ref 5099), (5092, .ref 5100), (5093, .ref 5096), (5094, .ref 5102), (5095, .ref 5098), (5096, .ref 5106), (5097, .ref 5107), (5098, .ref 5104), (5099, .ref 5105)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa117 : Map :=
  Conv.Map.compact 2767244 2767609 5091 PRE_first_tail_x8_r0_body.pl117 (PRE_first_tail_x8_r0_body.nr117.map NumV.ref) PRE_first_tail_x8_r0_body.kd117.big
    PRE_first_tail_x8_r0_body.kd117.region PRE_first_tail_x8_r0_body.kd117.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws117 : List Nat := [2982, 2983, 2984, 2985, 2986, 2987, 2988, 2989, 2990]
noncomputable def PRE_first_tail_x8_r0_body.crs117 : List SymE := PRE_first_tail_x8_r0_body.nr117.map fun r => (nth? PRE_first_tail_x8_r0_body.S1138.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta117 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws117 PRE_first_tail_x8_r0_body.crs117
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB117 : List Nat := [2665, 2672601, 2673467]

kernel_rfl PRE_first_tail_x8_r0_body.ctab117 : PRE_first_tail_x8_r0_body.S1139.tab = PRE_first_tail_x8_r0_body.S1137.tab ++ PRE_first_tail_x8_r0_body.cws117.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace117 : PRE_first_tail_x8_r0_body.s1139.trace = PRE_first_tail_x8_r0_body.s1137.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext117 : PRE_first_tail_x8_r0_body.s1139.next = 2767259
kernel_rfl PRE_first_tail_x8_r0_body.ccounters117 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1139.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1139.ffi).mlx.nnext) = (20521, 17615)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue117 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1138.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1139.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa117.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp117 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1139.ffi).mlx.tokens.all (bSN 5100) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean117 : Conv.cleanListB 20521 131072 (fun r => Nat.ble 82084 r) PRE_first_tail_x8_r0_body.s1139
    (PRE_first_tail_x8_r0_body.wrB117 ++ (List.range 15).map (2767244 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs117 : bigsOutB 20521 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1139.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK117
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl117`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl117 : List Nat := [2665, 2672601, 2673467, 2767244, 2767245, 2767246, 2767247, 2767248, 2767249, 2767250, 2767251, 2767252, 2767253, 2767254, 2767255, 2767256, 2767257, 2767258]
def PRE_first_tail_x8_r0_body.clo117 : List Nat := [20517, 20518, 20519, 20520]
def PRE_first_tail_x8_r0_body.cln117 : List Nat := [17609, 17610, 17611, 17612, 17613, 17614]
def PRE_first_tail_x8_r0_body.cli117 : List Nat := [17609, 17610, 17611, 17612, 17613, 17614]
kernel_rfl PRE_first_tail_x8_r0_body.cheap117 : PRE_first_tail_x8_r0_body.s1139.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1137.heap (PRE_first_tail_x8_r0_body.cl117.filterMap fun a => (PRE_first_tail_x8_r0_body.s1139.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe117 : Nat.ble PRE_first_tail_x8_r0_body.s1137.next PRE_first_tail_x8_r0_body.s1139.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP117 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1137 PRE_first_tail_x8_r0_body.s1139 PRE_first_tail_x8_r0_body.cl117 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp117 : Conv.suppListB PRE_first_tail_x8_r0_body.s1139 5100 PRE_first_tail_x8_r0_body.cl117 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound117 : Conv.boundListB PRE_first_tail_x8_r0_body.s1139 PRE_first_tail_x8_r0_body.cl117 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK117 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1139.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln117.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1139.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK117 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1139.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo117.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1139.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK117 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1139.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli117.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1139.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst117 : Conv.sstListB 5100 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1139.ffi).mlx PRE_first_tail_x8_r0_body.cln117 PRE_first_tail_x8_r0_body.clo117 PRE_first_tail_x8_r0_body.cli117 = true

end Host.Load.Run.Tpl
end

section -- SiteCl117
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA117 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1139.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo117.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1139.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd117 : (PRE_first_tail_x8_r0_body.clo117 ++ PRE_first_tail_x8_r0_body.cln117 ++ PRE_first_tail_x8_r0_body.cli117).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle117 : Conv.Cnt.leB (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt) (⟨20521, 17615, 2767259, 5100⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck117 : Conv.ncleanListB (⟨20521, 17615, 2767259, 5100⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1139.ffi).mlx PRE_first_tail_x8_r0_body.clo117 PRE_first_tail_x8_r0_body.cln117 PRE_first_tail_x8_r0_body.cli117 = true
theorem PRE_first_tail_x8_r0_body.cncl117 (h : Conv.NClean (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx) : Conv.NClean (⟨20521, 17615, 2767259, 5100⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1139.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle117 PRE_first_tail_x8_r0_body.ckA117 PRE_first_tail_x8_r0_body.cobjsK117 PRE_first_tail_x8_r0_body.cnodesK117 PRE_first_tail_x8_r0_body.citemsK117 PRE_first_tail_x8_r0_body.cbd117 PRE_first_tail_x8_r0_body.cck117

end Host.Load.Run.Tpl
end

section -- SiteS117
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 117 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc117 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P117 : LoadP := PRE_first_tail_x8_r0_body.Pc117.raise 17615
kernel_rfl PRE_first_tail_x8_r0_body.craise117 : Nat.ble PRE_first_tail_x8_r0_body.Pc117.N0 17615 = true
theorem PRE_first_tail_x8_r0_body.raised117 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc117 PRE_first_tail_x8_r0_body.P117 :=
  .inr ⟨17615, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise117, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_117 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1139.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_117 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1138.ffi)
def PRE_first_tail_x8_r0_body.khinv117 : PTrie Nat := Stage.setAll PTrie.nil [(20519, 20517), (20520, 20518), (20522, 20519), (20521, 20520)]
def PRE_first_tail_x8_r0_body.kninv117 : PTrie Nat := Stage.setAll PTrie.nil [(17609, 17609), (17610, 17610), (17611, 17611), (17612, 17612), (17613, 17613), (17614, 17614)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS117 : List Nat := [20517, 20518, 20519, 20520, 20521, 20522]
def PRE_first_tail_x8_r0_body.cnS117 : List Nat := List.range' 17609 6
def PRE_first_tail_x8_r0_body.ciS117 : List Nat := [] ++ List.range' 17609 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0117 : PRE_first_tail_x8_r0_body.kd117.nh0 = PRE_first_tail_x8_r0_body.cx0_117.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1117 : PRE_first_tail_x8_r0_body.kd117.nh1 = PRE_first_tail_x8_r0_body.cx1_117.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0117 : PRE_first_tail_x8_r0_body.kd117.nn0 = PRE_first_tail_x8_r0_body.cx0_117.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1117 : PRE_first_tail_x8_r0_body.kd117.nn1 = PRE_first_tail_x8_r0_body.cx1_117.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo117 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P117.lo && Nat.ble PRE_first_tail_x8_r0_body.P117.lo PRE_first_tail_x8_r0_body.cx0_117.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P117.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P117.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt117 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_117.mlx.next PRE_first_tail_x8_r0_body.cx1_117.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_117.mlx.nnext PRE_first_tail_x8_r0_body.cx1_117.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband117 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P117.NL && Nat.ble PRE_first_tail_x8_r0_body.P117.NL PRE_first_tail_x8_r0_body.P117.N0 && Nat.ble PRE_first_tail_x8_r0_body.P117.N0 PRE_first_tail_x8_r0_body.cx0_117.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow117 : PRE_first_tail_x8_r0_body.kd117.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren117 : checkRenG PRE_first_tail_x8_r0_body.kd117.hnd PRE_first_tail_x8_r0_body.khinv117 (phB PRE_first_tail_x8_r0_body.cx0_117.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband117 : PRE_first_tail_x8_r0_body.kd117.checkBand PRE_first_tail_x8_r0_body.P117.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos117 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd117.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren117 : checkRenG PRE_first_tail_x8_r0_body.kd117.node PRE_first_tail_x8_r0_body.kninv117 (pnB PRE_first_tail_x8_r0_body.cx0_117.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow117 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd117.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P117.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd117.nodeF j) PRE_first_tail_x8_r0_body.cx1_117.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a117 : PRE_first_tail_x8_r0_body.cx0_117.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b117 : PRE_first_tail_x8_r0_body.cx0_117.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1117 : PRE_first_tail_x8_r0_body.cx1_117.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend117 : PRE_first_tail_x8_r0_body.cx1_117.mlx.pending = PRE_first_tail_x8_r0_body.cx0_117.mlx.pending.map PRE_first_tail_x8_r0_body.kappa117.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh117 : PRE_first_tail_x8_r0_body.cx1_117.mlx.errh = PRE_first_tail_x8_r0_body.cx0_117.mlx.errh.map PRE_first_tail_x8_r0_body.kappa117.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles117 : PRE_first_tail_x8_r0_body.cx1_117.mlx.files = PRE_first_tail_x8_r0_body.cx0_117.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch117 : PRE_first_tail_x8_r0_body.cx1_117.mlx.arch = PRE_first_tail_x8_r0_body.cx0_117.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes117 : PRE_first_tail_x8_r0_body.cx1_117.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_117.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired117 : PRE_first_tail_x8_r0_body.cx1_117.mlx.wired = PRE_first_tail_x8_r0_body.cx0_117.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost117 : PRE_first_tail_x8_r0_body.cx1_117.host = PRE_first_tail_x8_r0_body.cx0_117.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd117`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0117 : PRE_first_tail_x8_r0_body.kd117.n0 = 2767259
kernel_rfl PRE_first_tail_x8_r0_body.ckn1117 : PRE_first_tail_x8_r0_body.kd117.n1 = 2767609
kernel_rfl PRE_first_tail_x8_r0_body.ckheap117 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd117.heap).all (fun x => Nat.ble 2767244 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl117 : (List.range 15).all (fun j => decide (PRE_first_tail_x8_r0_body.kd117.heap.get (2767244 + j) = nth? PRE_first_tail_x8_r0_body.pl117 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja117 : Nat.ble 2767244 2767244 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn117 : Nat.ble 5091 5091 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD117 : Nat.ble 2767244 PRE_first_tail_x8_r0_body.kd117.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn117 : Nat.ble 20517 PRE_first_tail_x8_r0_body.kd117.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn117 : Nat.ble 17609 PRE_first_tail_x8_r0_body.kd117.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb117 : Nat.ble 20517 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap117 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd117.heap).all (Nat.ble (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd117 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd117.hnd).all (Nat.ble (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode117 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd117.node).all (Nat.ble (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix117 : Conv.FixOld (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa117 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja117) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn117) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD117) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn117) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn117) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb117) PRE_first_tail_x8_r0_body.fheap117 PRE_first_tail_x8_r0_body.fhnd117 PRE_first_tail_x8_r0_body.fnode117
kernel_rfl PRE_first_tail_x8_r0_body.fcxn117 : (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn117 : (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0117 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_117.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_117.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk117 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd117.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A117 : PRE_first_tail_x8_r0_body.cx1_117.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS117.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_117.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O117 : PRE_first_tail_x8_r0_body.cx1_117.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS117.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_117.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N117 : PRE_first_tail_x8_r0_body.cx1_117.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS117.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_117.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I117 : PRE_first_tail_x8_r0_body.cx1_117.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS117.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_117.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd117 : (PRE_first_tail_x8_r0_body.clo117 ++ PRE_first_tail_x8_r0_body.cln117 ++ PRE_first_tail_x8_r0_body.cli117 ++ PRE_first_tail_x8_r0_body.cwS117 ++ PRE_first_tail_x8_r0_body.cnS117 ++ PRE_first_tail_x8_r0_body.ciS117).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW117 : PRE_first_tail_x8_r0_body.cwS117.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo117.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI117 : PRE_first_tail_x8_r0_body.ciS117.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli117.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN117 : PRE_first_tail_x8_r0_body.cnS117.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF117 : PRE_first_tail_x8_r0_body.cln117.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh117 : PRE_first_tail_x8_r0_body.clo117.all (handleOK PRE_first_tail_x8_r0_body.kappa117 PRE_first_tail_x8_r0_body.P117.lo PRE_first_tail_x8_r0_body.cx0_117.mlx PRE_first_tail_x8_r0_body.cx1_117.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo117 : PRE_first_tail_x8_r0_body.clo117.map (fun h => PRE_first_tail_x8_r0_body.cx1_117.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa117.handle h)) = PRE_first_tail_x8_r0_body.clo117.map (fun h => (PRE_first_tail_x8_r0_body.cx0_117.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa117.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok117 : PRE_first_tail_x8_r0_body.clo117.all (objOK PRE_first_tail_x8_r0_body.kappa117 PRE_first_tail_x8_r0_body.P117.NL PRE_first_tail_x8_r0_body.cx0_117.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd117 : PRE_first_tail_x8_r0_body.cln117.all (nodeOKF PRE_first_tail_x8_r0_body.kappa117 PRE_first_tail_x8_r0_body.P117 PRE_first_tail_x8_r0_body.cx0_117.mlx PRE_first_tail_x8_r0_body.cx1_117.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp117 : ((PRE_first_tail_x8_r0_body.cln117.filter (fullB PRE_first_tail_x8_r0_body.P117))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_117.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa117.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln117.filter (fullB PRE_first_tail_x8_r0_body.P117))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_117.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa117.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI117 : incrB PRE_first_tail_x8_r0_body.kd117.nodeF (List.range' 17609 6) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK117 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd117.node).all (fun k => Nat.ble 17609 k && Nat.blt k 17615) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL117 : (PRE_first_tail_x8_r0_body.cln117.filter (Nat.ble PRE_first_tail_x8_r0_body.P117.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd117.nodeF i) && (Nat.blt i 17615 || Nat.ble PRE_first_tail_x8_r0_body.kd117.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord117 : (PRE_first_tail_x8_r0_body.cln117.filter (Nat.ble PRE_first_tail_x8_r0_body.P117.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd117.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd117.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd117.nodeF j) (PRE_first_tail_x8_r0_body.kd117.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow117 PRE_first_tail_x8_r0_body.cnn1117 PRE_first_tail_x8_r0_body.fnordI117 PRE_first_tail_x8_r0_body.fnordK117 PRE_first_tail_x8_r0_body.fnordL117
kernel_rfl PRE_first_tail_x8_r0_body.fi117 : PRE_first_tail_x8_r0_body.cli117.all (pnB PRE_first_tail_x8_r0_body.cx0_117.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii117 : PRE_first_tail_x8_r0_body.cli117.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_117.mlx.items.get (PRE_first_tail_x8_r0_body.kappa117.node k) = (PRE_first_tail_x8_r0_body.cx0_117.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa117.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot117 (clean : Conv.NClean (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P117.NL) (cl : SSt (· < 5100) PRE_first_tail_x8_r0_body.cx0_117.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P117 5100 PRE_first_tail_x8_r0_body.kappa117 PRE_first_tail_x8_r0_body.kd117 PRE_first_tail_x8_r0_body.khinv117 PRE_first_tail_x8_r0_body.kninv117 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx PRE_first_tail_x8_r0_body.cx0_117.mlx PRE_first_tail_x8_r0_body.cx1_117.mlx (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo117 PRE_first_tail_x8_r0_body.cln117 PRE_first_tail_x8_r0_body.cli117 PRE_first_tail_x8_r0_body.cwS117 PRE_first_tail_x8_r0_body.cnS117 PRE_first_tail_x8_r0_body.ciS117 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0117, PRE_first_tail_x8_r0_body.cnh1117, PRE_first_tail_x8_r0_body.cnn0117, PRE_first_tail_x8_r0_body.cnn1117, PRE_first_tail_x8_r0_body.cplo117, PRE_first_tail_x8_r0_body.ccnt117, PRE_first_tail_x8_r0_body.cnband117, PRE_first_tail_x8_r0_body.chbelow117, PRE_first_tail_x8_r0_body.chren117, PRE_first_tail_x8_r0_body.cband117, PRE_first_tail_x8_r0_body.cnh1pos117, PRE_first_tail_x8_r0_body.cnren117, PRE_first_tail_x8_r0_body.cnlow117, PRE_first_tail_x8_r0_body.cabs0a117, PRE_first_tail_x8_r0_body.cabs0b117, PRE_first_tail_x8_r0_body.ctok1117, PRE_first_tail_x8_r0_body.cpend117, PRE_first_tail_x8_r0_body.cerrh117, PRE_first_tail_x8_r0_body.cfiles117, PRE_first_tail_x8_r0_body.carch117, PRE_first_tail_x8_r0_body.csizes117, PRE_first_tail_x8_r0_body.cwired117, PRE_first_tail_x8_r0_body.cfix117, clean, PRE_first_tail_x8_r0_body.fcxn117, PRE_first_tail_x8_r0_body.fcnn117, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0117, PRE_first_tail_x8_r0_body.fnk117, PRE_first_tail_x8_r0_body.ckA117, PRE_first_tail_x8_r0_body.cobjsK117, PRE_first_tail_x8_r0_body.cnodesK117, PRE_first_tail_x8_r0_body.citemsK117, PRE_first_tail_x8_r0_body.f1A117, PRE_first_tail_x8_r0_body.f1O117, PRE_first_tail_x8_r0_body.f1N117, PRE_first_tail_x8_r0_body.f1I117, PRE_first_tail_x8_r0_body.fbd117, PRE_first_tail_x8_r0_body.fincW117, PRE_first_tail_x8_r0_body.fincI117, PRE_first_tail_x8_r0_body.fincN117, PRE_first_tail_x8_r0_body.flnF117, PRE_first_tail_x8_r0_body.fh117, PRE_first_tail_x8_r0_body.fo117, PRE_first_tail_x8_r0_body.fok117, PRE_first_tail_x8_r0_body.fnd117, PRE_first_tail_x8_r0_body.fp117, PRE_first_tail_x8_r0_body.fnord117, PRE_first_tail_x8_r0_body.fi117, PRE_first_tail_x8_r0_body.fii117⟩
theorem PRE_first_tail_x8_r0_body.cnshift117 (clean : Conv.NClean (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P117.NL) (cl : SSt (· < 5100) PRE_first_tail_x8_r0_body.cx0_117.mlx) : NShift PRE_first_tail_x8_r0_body.P117 5100 PRE_first_tail_x8_r0_body.kappa117 PRE_first_tail_x8_r0_body.cx0_117 PRE_first_tail_x8_r0_body.cx1_117 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot117 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost117 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0117 PRE_first_tail_x8_r0_body.ckn1117 PRE_first_tail_x8_r0_body.ckheap117 PRE_first_tail_x8_r0_body.ckpl117)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_117 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1137.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_117 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1137.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_117 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1137.ffi) = some PRE_first_tail_x8_r0_body.fxC_117
kernel_rfl PRE_first_tail_x8_r0_body.okrC_117 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1137.ffi) = some PRE_first_tail_x8_r0_body.krC_117
noncomputable def PRE_first_tail_x8_r0_body.fx0_117 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1139.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_117 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1139.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_117 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1139.ffi) = some PRE_first_tail_x8_r0_body.fx0_117
kernel_rfl PRE_first_tail_x8_r0_body.okr0_117 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1139.ffi) = some PRE_first_tail_x8_r0_body.kr0_117
noncomputable def PRE_first_tail_x8_r0_body.fx1_117 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1138.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_117 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1138.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_117 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1138.ffi) = some PRE_first_tail_x8_r0_body.fx1_117
kernel_rfl PRE_first_tail_x8_r0_body.okr1_117 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1138.ffi) = some PRE_first_tail_x8_r0_body.kr1_117
kernel_rfl PRE_first_tail_x8_r0_body.ff0117 : PRE_first_tail_x8_r0_body.fx0_117 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_117 (PRE_first_tail_x8_r0_body.clo117.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_117.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1117 : PRE_first_tail_x8_r0_body.fx1_117 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_117 (PRE_first_tail_x8_r0_body.cwS117.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_117.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck117 : freedLB PRE_first_tail_x8_r0_body.kappa117 PRE_first_tail_x8_r0_body.cx0_117.mlx PRE_first_tail_x8_r0_body.fx0_117 PRE_first_tail_x8_r0_body.fx1_117 PRE_first_tail_x8_r0_body.clo117 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0117 : PRE_first_tail_x8_r0_body.kr0_117.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_117.flags (PRE_first_tail_x8_r0_body.clo117.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_117.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0117 : PRE_first_tail_x8_r0_body.kr0_117.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_117.targs (PRE_first_tail_x8_r0_body.clo117.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_117.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1117 : PRE_first_tail_x8_r0_body.kr1_117.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_117.flags (PRE_first_tail_x8_r0_body.cwS117.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_117.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1117 : PRE_first_tail_x8_r0_body.kr1_117.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_117.targs (PRE_first_tail_x8_r0_body.cwS117.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_117.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck117 : krecLB PRE_first_tail_x8_r0_body.kappa117 5100 PRE_first_tail_x8_r0_body.cx0_117.mlx PRE_first_tail_x8_r0_body.kr0_117 PRE_first_tail_x8_r0_body.kr1_117 PRE_first_tail_x8_r0_body.clo117 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn117 : Nat.ble 5091 5100 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge117 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1138.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1139.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR117 : pendRegB PRE_first_tail_x8_r0_body.kappa117 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1139.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe117 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1139.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1138.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift117 (clean : Conv.NClean (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P117.NL) (cl : SSt (· < 5100) PRE_first_tail_x8_r0_body.cx0_117.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_117.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_117.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_117.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1137.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_117.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P117 5100 PRE_first_tail_x8_r0_body.kappa117 PRE_first_tail_x8_r0_body.s1139.ffi PRE_first_tail_x8_r0_body.s1138.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift117 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue117, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp117 t ht),
    PRE_first_tail_x8_r0_body.cbridge117,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1139.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1138.ffi) (PRE_first_tail_x8_r0_body.cfoot117 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_117 PRE_first_tail_x8_r0_body.ofx1_117 hobjC PRE_first_tail_x8_r0_body.ff0117 PRE_first_tail_x8_r0_body.ff1117 PRE_first_tail_x8_r0_body.ffck117,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1139.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1138.ffi) (PRE_first_tail_x8_r0_body.cfoot117 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_117 PRE_first_tail_x8_r0_body.okr1_117 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn117) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0117 PRE_first_tail_x8_r0_body.fkt0117 PRE_first_tail_x8_r0_body.fkf1117 PRE_first_tail_x8_r0_body.fkt1117 PRE_first_tail_x8_r0_body.fkck117,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0117 PRE_first_tail_x8_r0_body.cnh1117 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe117) PRE_first_tail_x8_r0_body.cpendR117⟩

end Host.Load.Run.Tpl
end

section -- st117/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st117 0
host_stream_state PRE_first_tail_x8_r0_body.st117 1
host_stream_state PRE_first_tail_x8_r0_body.st117 2
host_stream_state PRE_first_tail_x8_r0_body.st117 3
end Host.Load.Run.Tpl
end

section -- Site117
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 117 of chain `PRE_first_tail_x8_r0_body`: `kvW__g117__g118` (`appendWindow`), the call state `PRE_first_tail_x8_r0_body.s1137`, the merged state `PRE_first_tail_x8_r0_body.s1138`,
the site template `PRE_first_tail_x8_r0_body.st117` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1139`: the merge.
The footprint's facts are in `SiteF117`, the compaction's in `SiteC117`, `SiteK117`, `SiteNa117`, `SiteNb117`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso117 : PRE_first_tail_x8_r0_body.st117.s0 = { PRE_first_tail_x8_r0_body.s1137 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs117 : List Frame := PRE_first_tail_x8_r0_body.s1137.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_117 : PRE_first_tail_x8_r0_body.S1137.tab.length = 5091
kernel_rfl PRE_first_tail_x8_r0_body.tab0_117 : PRE_first_tail_x8_r0_body.st117.S0.tab = PRE_first_tail_x8_r0_body.S1137.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws117 : List Nat := [2965, 2966, 2967, 2968, 2969, 2970, 2971, 2972, 2973, 2974, 2975, 2976, 2977, 2978, 2979, 2980, 2981]
kernel_rfl PRE_first_tail_x8_r0_body.fresh117 : (PRE_first_tail_x8_r0_body.S1137.tab.all fun e => PRE_first_tail_x8_r0_body.ws117.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1137.oracle.all fun q => PRE_first_tail_x8_r0_body.ws117.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab117 : PRE_first_tail_x8_r0_body.S1138.tab = PRE_first_tail_x8_r0_body.S1137.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws117
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen117 : PRE_first_tail_x8_r0_body.st117.S3.tab.length - PRE_first_tail_x8_r0_body.st117.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged117`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap117 : PRE_first_tail_x8_r0_body.s1138.heap = PRE_first_tail_x8_r0_body.st117.s3.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext117 : PRE_first_tail_x8_r0_body.s1138.next = PRE_first_tail_x8_r0_body.st117.s3.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl117 : PRE_first_tail_x8_r0_body.s1138.ctl = PRE_first_tail_x8_r0_body.st117.s3.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack117 : PRE_first_tail_x8_r0_body.s1138.stack = PRE_first_tail_x8_r0_body.st117.s3.stack ++ PRE_first_tail_x8_r0_body.s1137.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs117 : PRE_first_tail_x8_r0_body.s1138.jobs = PRE_first_tail_x8_r0_body.st117.s3.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi117 : PRE_first_tail_x8_r0_body.s1138.ffi = PRE_first_tail_x8_r0_body.st117.s3.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace117 : PRE_first_tail_x8_r0_body.s1138.trace = PRE_first_tail_x8_r0_body.st117.s3.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores117 : PRE_first_tail_x8_r0_body.s1138.stores = PRE_first_tail_x8_r0_body.st117.s3.stores

end Host.Load.Run.Tpl
end

section -- SiteD117
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 117 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived117 : PRE_first_tail_x8_r0_body.nr117.map (fun r => nth? PRE_first_tail_x8_r0_body.st117.S3.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false)))]
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo117 : PRE_first_tail_x8_r0_body.nr117.all (Nat.ble 5091) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj117 : PRE_first_tail_x8_r0_body.cws117.all (fun c => !PRE_first_tail_x8_r0_body.ws117.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ117 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws117 PRE_first_tail_x8_r0_body.crs117 PRE_first_tail_x8_r0_body.ws117

end Host.Load.Run.Tpl
end

section -- st117/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st117`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st117.wrR : List (Nat × Nat) := [(2672601, 2672602)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st117.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st117.s3.heap PRE_first_tail_x8_r0_body.st117.wrR ++ freshOf PRE_first_tail_x8_r0_body.st117.s3.heap PRE_first_tail_x8_r0_body.st117.s0.next PRE_first_tail_x8_r0_body.st117.s3.next
noncomputable def PRE_first_tail_x8_r0_body.st117.wr : List Nat := PRE_first_tail_x8_r0_body.st117.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st117.heapFoot : PRE_first_tail_x8_r0_body.st117.s3.heap = setAll PRE_first_tail_x8_r0_body.st117.s0.heap PRE_first_tail_x8_r0_body.st117.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st117.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st117.s0.next PRE_first_tail_x8_r0_body.st117.s3.next = true
theorem PRE_first_tail_x8_r0_body.st117.grows : PRE_first_tail_x8_r0_body.st117.s0.next ≤ PRE_first_tail_x8_r0_body.st117.s3.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st117.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st117.wh : List Nat := [20517, 20518, 20519, 20520, 20521, 20522]
def PRE_first_tail_x8_r0_body.st117.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st117.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st117.s3.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st117.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st117.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st117.s3.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st117.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st117.s3.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st117.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st117.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st117.s3.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st117.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st117.s3.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st117.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st117.s3.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st117.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st117.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st117.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st117.s3.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st117.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st117.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st117.s3.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st117.s3.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st117.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st117.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st117.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st117.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st117.s3.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st117.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st117.s3.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF117
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 117 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB117 : nodupT PRE_first_tail_x8_r0_body.st117.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup117 : PRE_first_tail_x8_r0_body.st117.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB117).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB117 : PRE_first_tail_x8_r0_body.st117.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound117 : ∀ b ∈ PRE_first_tail_x8_r0_body.st117.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB117 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr117 := PRE_first_tail_x8_r0_body.st117.s3.trace.take 26
kernel_rfl PRE_first_tail_x8_r0_body.traceEq117 : PRE_first_tail_x8_r0_body.st117.s3.trace = PRE_first_tail_x8_r0_body.trFr117 ++ PRE_first_tail_x8_r0_body.st117.s0.trace
theorem PRE_first_tail_x8_r0_body.trace117 : ∃ fr, PRE_first_tail_x8_r0_body.st117.s3.trace = fr ++ PRE_first_tail_x8_r0_body.st117.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq117⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide117 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB117 : (PRE_first_tail_x8_r0_body.wide117.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st117.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix117 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide117, WFix Map.id (Present PRE_first_tail_x8_r0_body.st117.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB117 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL117
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 117 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1138`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO117 : PRE_first_tail_x8_r0_body.st117.S0.oracle = PRE_first_tail_x8_r0_body.st117.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B117 : PRE_first_tail_x8_r0_body.st117.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st117.s0.next || (PRE_first_tail_x8_r0_body.st117.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot117 : Conv.StageFoot PRE_first_tail_x8_r0_body.st117.wr PRE_first_tail_x8_r0_body.st117.s0 PRE_first_tail_x8_r0_body.st117.s3 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st117.heapFoot PRE_first_tail_x8_r0_body.wrNodup117 PRE_first_tail_x8_r0_body.wrBound117 PRE_first_tail_x8_r0_body.wr0B117 PRE_first_tail_x8_r0_body.st117.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged117 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st117.F.S → PRE_first_tail_x8_r0_body.st117.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st117.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st117.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs117 PRE_first_tail_x8_r0_body.st117.wr PRE_first_tail_x8_r0_body.s1137 PRE_first_tail_x8_r0_body.st117.s3 PRE_first_tail_x8_r0_body.st117.s0
      PRE_first_tail_x8_r0_body.st117.s3.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st117.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1138 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso117 PRE_first_tail_x8_r0_body.stFoot117 PRE_first_tail_x8_r0_body.wrNodup117 PRE_first_tail_x8_r0_body.wrBound117 PRE_first_tail_x8_r0_body.trace117 PRE_first_tail_x8_r0_body.mheap117
    PRE_first_tail_x8_r0_body.mnext117 PRE_first_tail_x8_r0_body.mctl117 PRE_first_tail_x8_r0_body.mstack117 PRE_first_tail_x8_r0_body.mjobs117 PRE_first_tail_x8_r0_body.mffi117 PRE_first_tail_x8_r0_body.mtrace117 PRE_first_tail_x8_r0_body.mstores117 h

def PRE_first_tail_x8_r0_body.arrEl117_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE117_2665 : arrOf PRE_first_tail_x8_r0_body.s1138 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl117_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA117_2665 : isArrB PRE_first_tail_x8_r0_body.s1138 2665 = true
theorem PRE_first_tail_x8_r0_body.arr117_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1138.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl117_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE117_2665 PRE_first_tail_x8_r0_body.arrA117_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN117_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl117_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR117_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl117_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN117_2665

def PRE_first_tail_x8_r0_body.arrEl117_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE117_2673467 : arrOf PRE_first_tail_x8_r0_body.s1138 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl117_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA117_2673467 : isArrB PRE_first_tail_x8_r0_body.s1138 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr117_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1138.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl117_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE117_2673467 PRE_first_tail_x8_r0_body.arrA117_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN117_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl117_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR117_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl117_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN117_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k117 : isArrB PRE_first_tail_x8_r0_body.s1138 4910 = false
theorem PRE_first_tail_x8_r0_body.keep117 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1138 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k117 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr117_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl117_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ117
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 117 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1137`, the merged
state `PRE_first_tail_x8_r0_body.s1138`, the canonical state `PRE_first_tail_x8_r0_body.s1139`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl117 : PRE_first_tail_x8_r0_body.pl117.all (Nat.ble PRE_first_tail_x8_r0_body.s1137.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd117 : nodupT PRE_first_tail_x8_r0_body.pl117 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1117 : Nat.ble PRE_first_tail_x8_r0_body.s1137.next 2767609 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst117 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1137.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn117 : PRE_first_tail_x8_r0_body.s1139.next = PRE_first_tail_x8_r0_body.s1137.next + PRE_first_tail_x8_r0_body.pl117.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn117 : PRE_first_tail_x8_r0_body.s1138.next = 2767609
kernel_rfl PRE_first_tail_x8_r0_body.zgrow117 : Nat.ble PRE_first_tail_x8_r0_body.s1139.next PRE_first_tail_x8_r0_body.s1138.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh117 : PRE_first_tail_x8_r0_body.S1137.tab.all (fun e => PRE_first_tail_x8_r0_body.cws117.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd117 : nodupT PRE_first_tail_x8_r0_body.cws117 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi117 : PRE_first_tail_x8_r0_body.nr117.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1138.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt117 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1137.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg117_2665 : PRE_first_tail_x8_r0_body.s1139.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1139 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk117_2665 : (objOf PRE_first_tail_x8_r0_body.s1139 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm117_2665 : PRE_first_tail_x8_r0_body.s1138.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa117.obj (objOf PRE_first_tail_x8_r0_body.s1139 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1138 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg117_2673467 : PRE_first_tail_x8_r0_body.s1139.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1139 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk117_2673467 : (objOf PRE_first_tail_x8_r0_body.s1139 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm117_2673467 : PRE_first_tail_x8_r0_body.s1138.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa117.obj (objOf PRE_first_tail_x8_r0_body.s1139 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1138 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw117_4910 : (PRE_first_tail_x8_r0_body.s1139.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw117_2673472 : (PRE_first_tail_x8_r0_body.s1139.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw117_2673473 : (PRE_first_tail_x8_r0_body.s1139.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd117 : PRE_first_tail_x8_r0_body.cl117.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr117 : PRE_first_tail_x8_r0_body.st117.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1137.next || PRE_first_tail_x8_r0_body.cl117.contains b) = true
def PRE_first_tail_x8_r0_body.zl117 : List Nat := PRE_first_tail_x8_r0_body.cl117.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE117 : PRE_first_tail_x8_r0_body.zl117.map (fun a => PRE_first_tail_x8_r0_body.s1138.heap.get (PRE_first_tail_x8_r0_body.kappa117.a a)) = PRE_first_tail_x8_r0_body.zl117.map (fun a => (PRE_first_tail_x8_r0_body.s1139.heap.get a).map PRE_first_tail_x8_r0_body.kappa117.hobj)
theorem PRE_first_tail_x8_r0_body.zimg117 : HeapImg PRE_first_tail_x8_r0_body.kappa117 PRE_first_tail_x8_r0_body.s1139 PRE_first_tail_x8_r0_body.s1138 PRE_first_tail_x8_r0_body.zl117 := PRE_first_tail_x8_r0_body.zimgE117
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl117 : PRE_first_tail_x8_r0_body.s1138.ctl = PRE_first_tail_x8_r0_body.kappa117.ctl PRE_first_tail_x8_r0_body.s1139.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack117 : PRE_first_tail_x8_r0_body.s1138.stack = PRE_first_tail_x8_r0_body.s1139.stack.map PRE_first_tail_x8_r0_body.kappa117.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs117 : PRE_first_tail_x8_r0_body.s1138.jobs = PRE_first_tail_x8_r0_body.s1139.jobs.map PRE_first_tail_x8_r0_body.kappa117.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores117 : PRE_first_tail_x8_r0_body.s1138.stores = PRE_first_tail_x8_r0_body.kappa117.stores PRE_first_tail_x8_r0_body.s1139.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots117 : checkRootsSupp PRE_first_tail_x8_r0_body.s1139 5100 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC117 : PRE_first_tail_x8_r0_body.S1137.tab.length + PRE_first_tail_x8_r0_body.cws117.length = 5100
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap117 : PRE_first_tail_x8_r0_body.kappa117 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1137.next 2767609 PRE_first_tail_x8_r0_body.S1137.tab.length PRE_first_tail_x8_r0_body.pl117 (PRE_first_tail_x8_r0_body.nr117.map NumV.ref) PRE_first_tail_x8_r0_body.kd117.big
  PRE_first_tail_x8_r0_body.kd117.region PRE_first_tail_x8_r0_body.kd117.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin117 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1139.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc117 : Conv.jcleanListB (⟨20521, 17615, 2767259, 5100⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1139 PRE_first_tail_x8_r0_body.cl117 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB117 : noBigRootsP (fun i => !Conv.oldBigB (⟨20521, 17615, 2767259, 5100⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1139.trace PRE_first_tail_x8_r0_body.s1139 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm117 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 17609 = true
theorem PRE_first_tail_x8_r0_body.cjcl117 (h : Conv.JClean (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1137) : Conv.JClean (⟨20521, 17615, 2767259, 5100⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1139 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle117)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap117 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd117 a ha)) PRE_first_tail_x8_r0_body.zjc117

end Host.Load.Run.Tpl
end

section -- st117/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st117.bodyLast from PRE_first_tail_x8_r0_body.st117.s2 to PRE_first_tail_x8_r0_body.st117.s3 :
  interpS (step PRE_first_tail_x8_r0_body.st117.F PRE_first_tail_x8_r0_body.st117.s2).run PRE_first_tail_x8_r0_body.st117.S2 = some (PRE_first_tail_x8_r0_body.st117.s3, PRE_first_tail_x8_r0_body.st117.S3)
kernel_rfl PRE_first_tail_x8_r0_body.st117.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st117.s2.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st117.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st117.s3.stack = true

end Host.Load.Run.Tpl
end

section -- st117/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st117.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st117.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st117.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st117.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st117.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st117.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st117.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st117.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st117.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st117.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st117.s0 PRE_first_tail_x8_r0_body.st117.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st117.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st117.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st117.s2 PRE_first_tail_x8_r0_body.st117.S2) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st117/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st117.bodyK0F from PRE_first_tail_x8_r0_body.st117.s0 to PRE_first_tail_x8_r0_body.st117.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st117.F (PRE_first_tail_x8_r0_body.st117.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st117.ks 0).getD 0) PRE_first_tail_x8_r0_body.st117.s0 PRE_first_tail_x8_r0_body.st117.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st117.s1, PRE_first_tail_x8_r0_body.st117.S1)
theorem PRE_first_tail_x8_r0_body.st117.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st117.F (PRE_first_tail_x8_r0_body.st117.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st117.ks 0).getD 0) PRE_first_tail_x8_r0_body.st117.s0 PRE_first_tail_x8_r0_body.st117.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st117.s1, PRE_first_tail_x8_r0_body.st117.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st117.bodyOkLN_ok PRE_first_tail_x8_r0_body.st117.bodyK0F
end Host.Load.Run.Tpl
end

section -- st117/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st117.bodyK1F from PRE_first_tail_x8_r0_body.st117.s1 to PRE_first_tail_x8_r0_body.st117.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st117.F (PRE_first_tail_x8_r0_body.st117.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st117.ks 1).getD 0) PRE_first_tail_x8_r0_body.st117.s1 PRE_first_tail_x8_r0_body.st117.S1) = fun _ _ => some (PRE_first_tail_x8_r0_body.st117.s2, PRE_first_tail_x8_r0_body.st117.S2)
theorem PRE_first_tail_x8_r0_body.st117.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st117.F (PRE_first_tail_x8_r0_body.st117.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st117.ks 1).getD 0) PRE_first_tail_x8_r0_body.st117.s1 PRE_first_tail_x8_r0_body.st117.S1) = fun _ _ => some (PRE_first_tail_x8_r0_body.st117.s2, PRE_first_tail_x8_r0_body.st117.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st117.bodyOkLN_ok PRE_first_tail_x8_r0_body.st117.bodyK1F
end Host.Load.Run.Tpl
end

section -- st117/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st117.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st117.F (PRE_first_tail_x8_r0_body.st117.bodyOkL bytes rows) 3452 PRE_first_tail_x8_r0_body.st117.s0 PRE_first_tail_x8_r0_body.st117.S0 = some (PRE_first_tail_x8_r0_body.st117.s2, PRE_first_tail_x8_r0_body.st117.S2) :=
  runOk_trans PRE_first_tail_x8_r0_body.st117.F (PRE_first_tail_x8_r0_body.st117.bodyOkL bytes rows) ((nth? PRE_first_tail_x8_r0_body.st117.ks 0).getD 0) ((nth? PRE_first_tail_x8_r0_body.st117.ks 1).getD 0) PRE_first_tail_x8_r0_body.st117.s0 PRE_first_tail_x8_r0_body.st117.s1 PRE_first_tail_x8_r0_body.st117.s2 PRE_first_tail_x8_r0_body.st117.S0 PRE_first_tail_x8_r0_body.st117.S1 PRE_first_tail_x8_r0_body.st117.S2 ((congrFun (congrFun PRE_first_tail_x8_r0_body.st117.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x8_r0_body.st117.bodyK1 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st117.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st117.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st117.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st117.F (PRE_first_tail_x8_r0_body.st117.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st117.s0
  S0 := PRE_first_tail_x8_r0_body.st117.S0
  s1 := PRE_first_tail_x8_r0_body.st117.s2
  S1 := PRE_first_tail_x8_r0_body.st117.S2
  s2 := PRE_first_tail_x8_r0_body.st117.s3
  S2 := PRE_first_tail_x8_r0_body.st117.S3
  n := 3452
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st117.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st117.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st117.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st117.bodyHalt
  last := PRE_first_tail_x8_r0_body.st117.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st117.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC118
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 118 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1147` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa118` into the merged state
`PRE_first_tail_x8_r0_body.s1146`. -/

def PRE_first_tail_x8_r0_body.pl118 : List Nat := []
def PRE_first_tail_x8_r0_body.nr118 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd118 : RData :=
  ⟨2767841, 2767843, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20534, 20534, 17625, 17625, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa118 : Map :=
  Conv.Map.compact 2767841 2767843 5123 PRE_first_tail_x8_r0_body.pl118 (PRE_first_tail_x8_r0_body.nr118.map NumV.ref) PRE_first_tail_x8_r0_body.kd118.big
    PRE_first_tail_x8_r0_body.kd118.region PRE_first_tail_x8_r0_body.kd118.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws118 : List Nat := []
noncomputable def PRE_first_tail_x8_r0_body.crs118 : List SymE := PRE_first_tail_x8_r0_body.nr118.map fun r => (nth? PRE_first_tail_x8_r0_body.S1146.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta118 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws118 PRE_first_tail_x8_r0_body.crs118
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB118 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x8_r0_body.ctab118 : PRE_first_tail_x8_r0_body.S1147.tab = PRE_first_tail_x8_r0_body.S1145.tab ++ PRE_first_tail_x8_r0_body.cws118.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace118 : PRE_first_tail_x8_r0_body.s1147.trace = PRE_first_tail_x8_r0_body.s1145.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext118 : PRE_first_tail_x8_r0_body.s1147.next = 2767841
kernel_rfl PRE_first_tail_x8_r0_body.ccounters118 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1147.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1147.ffi).mlx.nnext) = (20534, 17625)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue118 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1146.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1147.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa118.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp118 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1147.ffi).mlx.tokens.all (bSN 5123) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean118 : Conv.cleanListB 20534 131072 (fun r => Nat.ble 82136 r) PRE_first_tail_x8_r0_body.s1147
    (PRE_first_tail_x8_r0_body.wrB118 ++ (List.range 0).map (2767841 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs118 : bigsOutB 20534 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1147.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK118
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl118`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl118 : List Nat := [2665, 2673467]
def PRE_first_tail_x8_r0_body.clo118 : List Nat := []
def PRE_first_tail_x8_r0_body.cln118 : List Nat := []
def PRE_first_tail_x8_r0_body.cli118 : List Nat := []
kernel_rfl PRE_first_tail_x8_r0_body.cheap118 : PRE_first_tail_x8_r0_body.s1147.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1145.heap (PRE_first_tail_x8_r0_body.cl118.filterMap fun a => (PRE_first_tail_x8_r0_body.s1147.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe118 : Nat.ble PRE_first_tail_x8_r0_body.s1145.next PRE_first_tail_x8_r0_body.s1147.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP118 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1145 PRE_first_tail_x8_r0_body.s1147 PRE_first_tail_x8_r0_body.cl118 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp118 : Conv.suppListB PRE_first_tail_x8_r0_body.s1147 5123 PRE_first_tail_x8_r0_body.cl118 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound118 : Conv.boundListB PRE_first_tail_x8_r0_body.s1147 PRE_first_tail_x8_r0_body.cl118 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK118 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1147.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln118.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1147.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK118 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1147.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo118.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1147.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK118 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1147.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli118.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1147.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst118 : Conv.sstListB 5123 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1147.ffi).mlx PRE_first_tail_x8_r0_body.cln118 PRE_first_tail_x8_r0_body.clo118 PRE_first_tail_x8_r0_body.cli118 = true

end Host.Load.Run.Tpl
end

section -- SiteCl118
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA118 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1147.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo118.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1147.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd118 : (PRE_first_tail_x8_r0_body.clo118 ++ PRE_first_tail_x8_r0_body.cln118 ++ PRE_first_tail_x8_r0_body.cli118).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle118 : Conv.Cnt.leB (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt) (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck118 : Conv.ncleanListB (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1147.ffi).mlx PRE_first_tail_x8_r0_body.clo118 PRE_first_tail_x8_r0_body.cln118 PRE_first_tail_x8_r0_body.cli118 = true
theorem PRE_first_tail_x8_r0_body.cncl118 (h : Conv.NClean (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx) : Conv.NClean (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1147.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle118 PRE_first_tail_x8_r0_body.ckA118 PRE_first_tail_x8_r0_body.cobjsK118 PRE_first_tail_x8_r0_body.cnodesK118 PRE_first_tail_x8_r0_body.citemsK118 PRE_first_tail_x8_r0_body.cbd118 PRE_first_tail_x8_r0_body.cck118

end Host.Load.Run.Tpl
end

section -- SiteS118
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 118 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc118 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P118 : LoadP := PRE_first_tail_x8_r0_body.Pc118.raise 17625
kernel_rfl PRE_first_tail_x8_r0_body.craise118 : Nat.ble PRE_first_tail_x8_r0_body.Pc118.N0 17625 = true
theorem PRE_first_tail_x8_r0_body.raised118 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc118 PRE_first_tail_x8_r0_body.P118 :=
  .inr ⟨17625, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise118, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_118 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1147.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_118 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1146.ffi)
def PRE_first_tail_x8_r0_body.khinv118 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x8_r0_body.kninv118 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS118 : List Nat := []
def PRE_first_tail_x8_r0_body.cnS118 : List Nat := List.range' 17625 0
def PRE_first_tail_x8_r0_body.ciS118 : List Nat := [] ++ List.range' 17625 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0118 : PRE_first_tail_x8_r0_body.kd118.nh0 = PRE_first_tail_x8_r0_body.cx0_118.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1118 : PRE_first_tail_x8_r0_body.kd118.nh1 = PRE_first_tail_x8_r0_body.cx1_118.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0118 : PRE_first_tail_x8_r0_body.kd118.nn0 = PRE_first_tail_x8_r0_body.cx0_118.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1118 : PRE_first_tail_x8_r0_body.kd118.nn1 = PRE_first_tail_x8_r0_body.cx1_118.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo118 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P118.lo && Nat.ble PRE_first_tail_x8_r0_body.P118.lo PRE_first_tail_x8_r0_body.cx0_118.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P118.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P118.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt118 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_118.mlx.next PRE_first_tail_x8_r0_body.cx1_118.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_118.mlx.nnext PRE_first_tail_x8_r0_body.cx1_118.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband118 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P118.NL && Nat.ble PRE_first_tail_x8_r0_body.P118.NL PRE_first_tail_x8_r0_body.P118.N0 && Nat.ble PRE_first_tail_x8_r0_body.P118.N0 PRE_first_tail_x8_r0_body.cx0_118.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow118 : PRE_first_tail_x8_r0_body.kd118.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren118 : checkRenG PRE_first_tail_x8_r0_body.kd118.hnd PRE_first_tail_x8_r0_body.khinv118 (phB PRE_first_tail_x8_r0_body.cx0_118.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband118 : PRE_first_tail_x8_r0_body.kd118.checkBand PRE_first_tail_x8_r0_body.P118.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos118 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd118.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren118 : checkRenG PRE_first_tail_x8_r0_body.kd118.node PRE_first_tail_x8_r0_body.kninv118 (pnB PRE_first_tail_x8_r0_body.cx0_118.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow118 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd118.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P118.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd118.nodeF j) PRE_first_tail_x8_r0_body.cx1_118.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a118 : PRE_first_tail_x8_r0_body.cx0_118.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b118 : PRE_first_tail_x8_r0_body.cx0_118.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1118 : PRE_first_tail_x8_r0_body.cx1_118.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend118 : PRE_first_tail_x8_r0_body.cx1_118.mlx.pending = PRE_first_tail_x8_r0_body.cx0_118.mlx.pending.map PRE_first_tail_x8_r0_body.kappa118.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh118 : PRE_first_tail_x8_r0_body.cx1_118.mlx.errh = PRE_first_tail_x8_r0_body.cx0_118.mlx.errh.map PRE_first_tail_x8_r0_body.kappa118.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles118 : PRE_first_tail_x8_r0_body.cx1_118.mlx.files = PRE_first_tail_x8_r0_body.cx0_118.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch118 : PRE_first_tail_x8_r0_body.cx1_118.mlx.arch = PRE_first_tail_x8_r0_body.cx0_118.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes118 : PRE_first_tail_x8_r0_body.cx1_118.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_118.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired118 : PRE_first_tail_x8_r0_body.cx1_118.mlx.wired = PRE_first_tail_x8_r0_body.cx0_118.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost118 : PRE_first_tail_x8_r0_body.cx1_118.host = PRE_first_tail_x8_r0_body.cx0_118.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd118`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0118 : PRE_first_tail_x8_r0_body.kd118.n0 = 2767841
kernel_rfl PRE_first_tail_x8_r0_body.ckn1118 : PRE_first_tail_x8_r0_body.kd118.n1 = 2767843
kernel_rfl PRE_first_tail_x8_r0_body.ckheap118 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd118.heap).all (fun x => Nat.ble 2767841 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl118 : (List.range 0).all (fun j => decide (PRE_first_tail_x8_r0_body.kd118.heap.get (2767841 + j) = nth? PRE_first_tail_x8_r0_body.pl118 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja118 : Nat.ble 2767841 2767841 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn118 : Nat.ble 5123 5123 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD118 : Nat.ble 2767841 PRE_first_tail_x8_r0_body.kd118.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn118 : Nat.ble 20534 PRE_first_tail_x8_r0_body.kd118.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn118 : Nat.ble 17625 PRE_first_tail_x8_r0_body.kd118.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb118 : Nat.ble 20534 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap118 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd118.heap).all (Nat.ble (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd118 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd118.hnd).all (Nat.ble (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode118 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd118.node).all (Nat.ble (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix118 : Conv.FixOld (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa118 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja118) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn118) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD118) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn118) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn118) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb118) PRE_first_tail_x8_r0_body.fheap118 PRE_first_tail_x8_r0_body.fhnd118 PRE_first_tail_x8_r0_body.fnode118
kernel_rfl PRE_first_tail_x8_r0_body.fcxn118 : (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn118 : (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0118 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_118.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_118.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk118 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd118.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A118 : PRE_first_tail_x8_r0_body.cx1_118.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS118.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_118.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O118 : PRE_first_tail_x8_r0_body.cx1_118.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS118.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_118.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N118 : PRE_first_tail_x8_r0_body.cx1_118.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS118.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_118.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I118 : PRE_first_tail_x8_r0_body.cx1_118.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS118.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_118.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd118 : (PRE_first_tail_x8_r0_body.clo118 ++ PRE_first_tail_x8_r0_body.cln118 ++ PRE_first_tail_x8_r0_body.cli118 ++ PRE_first_tail_x8_r0_body.cwS118 ++ PRE_first_tail_x8_r0_body.cnS118 ++ PRE_first_tail_x8_r0_body.ciS118).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW118 : PRE_first_tail_x8_r0_body.cwS118.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo118.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI118 : PRE_first_tail_x8_r0_body.ciS118.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli118.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN118 : PRE_first_tail_x8_r0_body.cnS118.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF118 : PRE_first_tail_x8_r0_body.cln118.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh118 : PRE_first_tail_x8_r0_body.clo118.all (handleOK PRE_first_tail_x8_r0_body.kappa118 PRE_first_tail_x8_r0_body.P118.lo PRE_first_tail_x8_r0_body.cx0_118.mlx PRE_first_tail_x8_r0_body.cx1_118.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo118 : PRE_first_tail_x8_r0_body.clo118.map (fun h => PRE_first_tail_x8_r0_body.cx1_118.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa118.handle h)) = PRE_first_tail_x8_r0_body.clo118.map (fun h => (PRE_first_tail_x8_r0_body.cx0_118.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa118.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok118 : PRE_first_tail_x8_r0_body.clo118.all (objOK PRE_first_tail_x8_r0_body.kappa118 PRE_first_tail_x8_r0_body.P118.NL PRE_first_tail_x8_r0_body.cx0_118.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd118 : PRE_first_tail_x8_r0_body.cln118.all (nodeOKF PRE_first_tail_x8_r0_body.kappa118 PRE_first_tail_x8_r0_body.P118 PRE_first_tail_x8_r0_body.cx0_118.mlx PRE_first_tail_x8_r0_body.cx1_118.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp118 : ((PRE_first_tail_x8_r0_body.cln118.filter (fullB PRE_first_tail_x8_r0_body.P118))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_118.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa118.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln118.filter (fullB PRE_first_tail_x8_r0_body.P118))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_118.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa118.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI118 : incrB PRE_first_tail_x8_r0_body.kd118.nodeF (List.range' 17625 0) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK118 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd118.node).all (fun k => Nat.ble 17625 k && Nat.blt k 17625) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL118 : (PRE_first_tail_x8_r0_body.cln118.filter (Nat.ble PRE_first_tail_x8_r0_body.P118.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd118.nodeF i) && (Nat.blt i 17625 || Nat.ble PRE_first_tail_x8_r0_body.kd118.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord118 : (PRE_first_tail_x8_r0_body.cln118.filter (Nat.ble PRE_first_tail_x8_r0_body.P118.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd118.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd118.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd118.nodeF j) (PRE_first_tail_x8_r0_body.kd118.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow118 PRE_first_tail_x8_r0_body.cnn1118 PRE_first_tail_x8_r0_body.fnordI118 PRE_first_tail_x8_r0_body.fnordK118 PRE_first_tail_x8_r0_body.fnordL118
kernel_rfl PRE_first_tail_x8_r0_body.fi118 : PRE_first_tail_x8_r0_body.cli118.all (pnB PRE_first_tail_x8_r0_body.cx0_118.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii118 : PRE_first_tail_x8_r0_body.cli118.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_118.mlx.items.get (PRE_first_tail_x8_r0_body.kappa118.node k) = (PRE_first_tail_x8_r0_body.cx0_118.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa118.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot118 (clean : Conv.NClean (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P118.NL) (cl : SSt (· < 5123) PRE_first_tail_x8_r0_body.cx0_118.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P118 5123 PRE_first_tail_x8_r0_body.kappa118 PRE_first_tail_x8_r0_body.kd118 PRE_first_tail_x8_r0_body.khinv118 PRE_first_tail_x8_r0_body.kninv118 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx PRE_first_tail_x8_r0_body.cx0_118.mlx PRE_first_tail_x8_r0_body.cx1_118.mlx (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo118 PRE_first_tail_x8_r0_body.cln118 PRE_first_tail_x8_r0_body.cli118 PRE_first_tail_x8_r0_body.cwS118 PRE_first_tail_x8_r0_body.cnS118 PRE_first_tail_x8_r0_body.ciS118 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0118, PRE_first_tail_x8_r0_body.cnh1118, PRE_first_tail_x8_r0_body.cnn0118, PRE_first_tail_x8_r0_body.cnn1118, PRE_first_tail_x8_r0_body.cplo118, PRE_first_tail_x8_r0_body.ccnt118, PRE_first_tail_x8_r0_body.cnband118, PRE_first_tail_x8_r0_body.chbelow118, PRE_first_tail_x8_r0_body.chren118, PRE_first_tail_x8_r0_body.cband118, PRE_first_tail_x8_r0_body.cnh1pos118, PRE_first_tail_x8_r0_body.cnren118, PRE_first_tail_x8_r0_body.cnlow118, PRE_first_tail_x8_r0_body.cabs0a118, PRE_first_tail_x8_r0_body.cabs0b118, PRE_first_tail_x8_r0_body.ctok1118, PRE_first_tail_x8_r0_body.cpend118, PRE_first_tail_x8_r0_body.cerrh118, PRE_first_tail_x8_r0_body.cfiles118, PRE_first_tail_x8_r0_body.carch118, PRE_first_tail_x8_r0_body.csizes118, PRE_first_tail_x8_r0_body.cwired118, PRE_first_tail_x8_r0_body.cfix118, clean, PRE_first_tail_x8_r0_body.fcxn118, PRE_first_tail_x8_r0_body.fcnn118, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0118, PRE_first_tail_x8_r0_body.fnk118, PRE_first_tail_x8_r0_body.ckA118, PRE_first_tail_x8_r0_body.cobjsK118, PRE_first_tail_x8_r0_body.cnodesK118, PRE_first_tail_x8_r0_body.citemsK118, PRE_first_tail_x8_r0_body.f1A118, PRE_first_tail_x8_r0_body.f1O118, PRE_first_tail_x8_r0_body.f1N118, PRE_first_tail_x8_r0_body.f1I118, PRE_first_tail_x8_r0_body.fbd118, PRE_first_tail_x8_r0_body.fincW118, PRE_first_tail_x8_r0_body.fincI118, PRE_first_tail_x8_r0_body.fincN118, PRE_first_tail_x8_r0_body.flnF118, PRE_first_tail_x8_r0_body.fh118, PRE_first_tail_x8_r0_body.fo118, PRE_first_tail_x8_r0_body.fok118, PRE_first_tail_x8_r0_body.fnd118, PRE_first_tail_x8_r0_body.fp118, PRE_first_tail_x8_r0_body.fnord118, PRE_first_tail_x8_r0_body.fi118, PRE_first_tail_x8_r0_body.fii118⟩
theorem PRE_first_tail_x8_r0_body.cnshift118 (clean : Conv.NClean (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P118.NL) (cl : SSt (· < 5123) PRE_first_tail_x8_r0_body.cx0_118.mlx) : NShift PRE_first_tail_x8_r0_body.P118 5123 PRE_first_tail_x8_r0_body.kappa118 PRE_first_tail_x8_r0_body.cx0_118 PRE_first_tail_x8_r0_body.cx1_118 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot118 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost118 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0118 PRE_first_tail_x8_r0_body.ckn1118 PRE_first_tail_x8_r0_body.ckheap118 PRE_first_tail_x8_r0_body.ckpl118)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_118 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1145.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_118 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1145.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_118 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1145.ffi) = some PRE_first_tail_x8_r0_body.fxC_118
kernel_rfl PRE_first_tail_x8_r0_body.okrC_118 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1145.ffi) = some PRE_first_tail_x8_r0_body.krC_118
noncomputable def PRE_first_tail_x8_r0_body.fx0_118 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1147.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_118 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1147.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_118 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1147.ffi) = some PRE_first_tail_x8_r0_body.fx0_118
kernel_rfl PRE_first_tail_x8_r0_body.okr0_118 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1147.ffi) = some PRE_first_tail_x8_r0_body.kr0_118
noncomputable def PRE_first_tail_x8_r0_body.fx1_118 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1146.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_118 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1146.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_118 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1146.ffi) = some PRE_first_tail_x8_r0_body.fx1_118
kernel_rfl PRE_first_tail_x8_r0_body.okr1_118 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1146.ffi) = some PRE_first_tail_x8_r0_body.kr1_118
kernel_rfl PRE_first_tail_x8_r0_body.ff0118 : PRE_first_tail_x8_r0_body.fx0_118 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_118 (PRE_first_tail_x8_r0_body.clo118.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_118.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1118 : PRE_first_tail_x8_r0_body.fx1_118 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_118 (PRE_first_tail_x8_r0_body.cwS118.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_118.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck118 : freedLB PRE_first_tail_x8_r0_body.kappa118 PRE_first_tail_x8_r0_body.cx0_118.mlx PRE_first_tail_x8_r0_body.fx0_118 PRE_first_tail_x8_r0_body.fx1_118 PRE_first_tail_x8_r0_body.clo118 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0118 : PRE_first_tail_x8_r0_body.kr0_118.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_118.flags (PRE_first_tail_x8_r0_body.clo118.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_118.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0118 : PRE_first_tail_x8_r0_body.kr0_118.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_118.targs (PRE_first_tail_x8_r0_body.clo118.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_118.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1118 : PRE_first_tail_x8_r0_body.kr1_118.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_118.flags (PRE_first_tail_x8_r0_body.cwS118.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_118.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1118 : PRE_first_tail_x8_r0_body.kr1_118.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_118.targs (PRE_first_tail_x8_r0_body.cwS118.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_118.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck118 : krecLB PRE_first_tail_x8_r0_body.kappa118 5123 PRE_first_tail_x8_r0_body.cx0_118.mlx PRE_first_tail_x8_r0_body.kr0_118 PRE_first_tail_x8_r0_body.kr1_118 PRE_first_tail_x8_r0_body.clo118 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn118 : Nat.ble 5123 5123 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge118 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1146.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1147.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR118 : pendRegB PRE_first_tail_x8_r0_body.kappa118 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1147.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe118 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1147.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1146.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift118 (clean : Conv.NClean (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P118.NL) (cl : SSt (· < 5123) PRE_first_tail_x8_r0_body.cx0_118.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_118.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_118.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_118.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1145.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_118.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P118 5123 PRE_first_tail_x8_r0_body.kappa118 PRE_first_tail_x8_r0_body.s1147.ffi PRE_first_tail_x8_r0_body.s1146.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift118 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue118, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp118 t ht),
    PRE_first_tail_x8_r0_body.cbridge118,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1147.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1146.ffi) (PRE_first_tail_x8_r0_body.cfoot118 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_118 PRE_first_tail_x8_r0_body.ofx1_118 hobjC PRE_first_tail_x8_r0_body.ff0118 PRE_first_tail_x8_r0_body.ff1118 PRE_first_tail_x8_r0_body.ffck118,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1147.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1146.ffi) (PRE_first_tail_x8_r0_body.cfoot118 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_118 PRE_first_tail_x8_r0_body.okr1_118 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn118) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0118 PRE_first_tail_x8_r0_body.fkt0118 PRE_first_tail_x8_r0_body.fkf1118 PRE_first_tail_x8_r0_body.fkt1118 PRE_first_tail_x8_r0_body.fkck118,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0118 PRE_first_tail_x8_r0_body.cnh1118 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe118) PRE_first_tail_x8_r0_body.cpendR118⟩

end Host.Load.Run.Tpl
end

section -- st118/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st118 0
host_stream_state PRE_first_tail_x8_r0_body.st118 1
host_stream_state PRE_first_tail_x8_r0_body.st118 2
end Host.Load.Run.Tpl
end

section -- Site118
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 118 of chain `PRE_first_tail_x8_r0_body`: `rowBlocks__g118__g119` (`rowBlocks`), the call state `PRE_first_tail_x8_r0_body.s1145`, the merged state `PRE_first_tail_x8_r0_body.s1146`,
the site template `PRE_first_tail_x8_r0_body.st118` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1147`: the merge.
The footprint's facts are in `SiteF118`, the compaction's in `SiteC118`, `SiteK118`, `SiteNa118`, `SiteNb118`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso118 : PRE_first_tail_x8_r0_body.st118.s0 = { PRE_first_tail_x8_r0_body.s1145 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs118 : List Frame := PRE_first_tail_x8_r0_body.s1145.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_118 : PRE_first_tail_x8_r0_body.S1145.tab.length = 5123
kernel_rfl PRE_first_tail_x8_r0_body.tab0_118 : PRE_first_tail_x8_r0_body.st118.S0.tab = PRE_first_tail_x8_r0_body.S1145.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws118 : List Nat := [2991, 2992]
kernel_rfl PRE_first_tail_x8_r0_body.fresh118 : (PRE_first_tail_x8_r0_body.S1145.tab.all fun e => PRE_first_tail_x8_r0_body.ws118.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1145.oracle.all fun q => PRE_first_tail_x8_r0_body.ws118.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab118 : PRE_first_tail_x8_r0_body.S1146.tab = PRE_first_tail_x8_r0_body.S1145.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws118
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen118 : PRE_first_tail_x8_r0_body.st118.S2.tab.length - PRE_first_tail_x8_r0_body.st118.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged118`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap118 : PRE_first_tail_x8_r0_body.s1146.heap = PRE_first_tail_x8_r0_body.st118.s2.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext118 : PRE_first_tail_x8_r0_body.s1146.next = PRE_first_tail_x8_r0_body.st118.s2.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl118 : PRE_first_tail_x8_r0_body.s1146.ctl = PRE_first_tail_x8_r0_body.st118.s2.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack118 : PRE_first_tail_x8_r0_body.s1146.stack = PRE_first_tail_x8_r0_body.st118.s2.stack ++ PRE_first_tail_x8_r0_body.s1145.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs118 : PRE_first_tail_x8_r0_body.s1146.jobs = PRE_first_tail_x8_r0_body.st118.s2.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi118 : PRE_first_tail_x8_r0_body.s1146.ffi = PRE_first_tail_x8_r0_body.st118.s2.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace118 : PRE_first_tail_x8_r0_body.s1146.trace = PRE_first_tail_x8_r0_body.st118.s2.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores118 : PRE_first_tail_x8_r0_body.s1146.stores = PRE_first_tail_x8_r0_body.st118.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD118
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 118 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived118 : PRE_first_tail_x8_r0_body.nr118.map (fun r => nth? PRE_first_tail_x8_r0_body.st118.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo118 : PRE_first_tail_x8_r0_body.nr118.all (Nat.ble 5123) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj118 : PRE_first_tail_x8_r0_body.cws118.all (fun c => !PRE_first_tail_x8_r0_body.ws118.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ118 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws118 PRE_first_tail_x8_r0_body.crs118 PRE_first_tail_x8_r0_body.ws118

end Host.Load.Run.Tpl
end

section -- st118/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st118`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st118.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st118.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st118.s2.heap PRE_first_tail_x8_r0_body.st118.wrR ++ freshOf PRE_first_tail_x8_r0_body.st118.s2.heap PRE_first_tail_x8_r0_body.st118.s0.next PRE_first_tail_x8_r0_body.st118.s2.next
noncomputable def PRE_first_tail_x8_r0_body.st118.wr : List Nat := PRE_first_tail_x8_r0_body.st118.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st118.heapFoot : PRE_first_tail_x8_r0_body.st118.s2.heap = setAll PRE_first_tail_x8_r0_body.st118.s0.heap PRE_first_tail_x8_r0_body.st118.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st118.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st118.s0.next PRE_first_tail_x8_r0_body.st118.s2.next = true
theorem PRE_first_tail_x8_r0_body.st118.grows : PRE_first_tail_x8_r0_body.st118.s0.next ≤ PRE_first_tail_x8_r0_body.st118.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st118.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st118.wh : List Nat := []
def PRE_first_tail_x8_r0_body.st118.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st118.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st118.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st118.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st118.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st118.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st118.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st118.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st118.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st118.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st118.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st118.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st118.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st118.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st118.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st118.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st118.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st118.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st118.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st118.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st118.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st118.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st118.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st118.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st118.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st118.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st118.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st118.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st118.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st118.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF118
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 118 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB118 : nodupT PRE_first_tail_x8_r0_body.st118.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup118 : PRE_first_tail_x8_r0_body.st118.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB118).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB118 : PRE_first_tail_x8_r0_body.st118.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound118 : ∀ b ∈ PRE_first_tail_x8_r0_body.st118.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB118 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr118 := PRE_first_tail_x8_r0_body.st118.s2.trace.take 0
kernel_rfl PRE_first_tail_x8_r0_body.traceEq118 : PRE_first_tail_x8_r0_body.st118.s2.trace = PRE_first_tail_x8_r0_body.trFr118 ++ PRE_first_tail_x8_r0_body.st118.s0.trace
theorem PRE_first_tail_x8_r0_body.trace118 : ∃ fr, PRE_first_tail_x8_r0_body.st118.s2.trace = fr ++ PRE_first_tail_x8_r0_body.st118.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq118⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide118 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB118 : (PRE_first_tail_x8_r0_body.wide118.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st118.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix118 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide118, WFix Map.id (Present PRE_first_tail_x8_r0_body.st118.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB118 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL118
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 118 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1146`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO118 : PRE_first_tail_x8_r0_body.st118.S0.oracle = PRE_first_tail_x8_r0_body.st118.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B118 : PRE_first_tail_x8_r0_body.st118.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st118.s0.next || (PRE_first_tail_x8_r0_body.st118.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot118 : Conv.StageFoot PRE_first_tail_x8_r0_body.st118.wr PRE_first_tail_x8_r0_body.st118.s0 PRE_first_tail_x8_r0_body.st118.s2 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st118.heapFoot PRE_first_tail_x8_r0_body.wrNodup118 PRE_first_tail_x8_r0_body.wrBound118 PRE_first_tail_x8_r0_body.wr0B118 PRE_first_tail_x8_r0_body.st118.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged118 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st118.F.S → PRE_first_tail_x8_r0_body.st118.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st118.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st118.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs118 PRE_first_tail_x8_r0_body.st118.wr PRE_first_tail_x8_r0_body.s1145 PRE_first_tail_x8_r0_body.st118.s2 PRE_first_tail_x8_r0_body.st118.s0
      PRE_first_tail_x8_r0_body.st118.s2.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st118.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1146 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso118 PRE_first_tail_x8_r0_body.stFoot118 PRE_first_tail_x8_r0_body.wrNodup118 PRE_first_tail_x8_r0_body.wrBound118 PRE_first_tail_x8_r0_body.trace118 PRE_first_tail_x8_r0_body.mheap118
    PRE_first_tail_x8_r0_body.mnext118 PRE_first_tail_x8_r0_body.mctl118 PRE_first_tail_x8_r0_body.mstack118 PRE_first_tail_x8_r0_body.mjobs118 PRE_first_tail_x8_r0_body.mffi118 PRE_first_tail_x8_r0_body.mtrace118 PRE_first_tail_x8_r0_body.mstores118 h

def PRE_first_tail_x8_r0_body.arrEl118_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE118_2665 : arrOf PRE_first_tail_x8_r0_body.s1146 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl118_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA118_2665 : isArrB PRE_first_tail_x8_r0_body.s1146 2665 = true
theorem PRE_first_tail_x8_r0_body.arr118_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1146.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl118_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE118_2665 PRE_first_tail_x8_r0_body.arrA118_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN118_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl118_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR118_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl118_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN118_2665

def PRE_first_tail_x8_r0_body.arrEl118_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE118_2673467 : arrOf PRE_first_tail_x8_r0_body.s1146 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl118_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA118_2673467 : isArrB PRE_first_tail_x8_r0_body.s1146 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr118_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1146.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl118_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE118_2673467 PRE_first_tail_x8_r0_body.arrA118_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN118_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl118_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR118_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl118_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN118_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k118 : isArrB PRE_first_tail_x8_r0_body.s1146 4910 = false
theorem PRE_first_tail_x8_r0_body.keep118 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1146 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k118 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr118_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl118_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ118
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 118 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1145`, the merged
state `PRE_first_tail_x8_r0_body.s1146`, the canonical state `PRE_first_tail_x8_r0_body.s1147`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl118 : PRE_first_tail_x8_r0_body.pl118.all (Nat.ble PRE_first_tail_x8_r0_body.s1145.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd118 : nodupT PRE_first_tail_x8_r0_body.pl118 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1118 : Nat.ble PRE_first_tail_x8_r0_body.s1145.next 2767843 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst118 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1145.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn118 : PRE_first_tail_x8_r0_body.s1147.next = PRE_first_tail_x8_r0_body.s1145.next + PRE_first_tail_x8_r0_body.pl118.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn118 : PRE_first_tail_x8_r0_body.s1146.next = 2767843
kernel_rfl PRE_first_tail_x8_r0_body.zgrow118 : Nat.ble PRE_first_tail_x8_r0_body.s1147.next PRE_first_tail_x8_r0_body.s1146.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh118 : PRE_first_tail_x8_r0_body.S1145.tab.all (fun e => PRE_first_tail_x8_r0_body.cws118.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd118 : nodupT PRE_first_tail_x8_r0_body.cws118 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi118 : PRE_first_tail_x8_r0_body.nr118.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1146.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt118 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1145.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg118_2665 : PRE_first_tail_x8_r0_body.s1147.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1147 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk118_2665 : (objOf PRE_first_tail_x8_r0_body.s1147 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm118_2665 : PRE_first_tail_x8_r0_body.s1146.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa118.obj (objOf PRE_first_tail_x8_r0_body.s1147 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1146 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg118_2673467 : PRE_first_tail_x8_r0_body.s1147.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1147 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk118_2673467 : (objOf PRE_first_tail_x8_r0_body.s1147 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm118_2673467 : PRE_first_tail_x8_r0_body.s1146.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa118.obj (objOf PRE_first_tail_x8_r0_body.s1147 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1146 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw118_4910 : (PRE_first_tail_x8_r0_body.s1147.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw118_2673472 : (PRE_first_tail_x8_r0_body.s1147.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw118_2673473 : (PRE_first_tail_x8_r0_body.s1147.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd118 : PRE_first_tail_x8_r0_body.cl118.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr118 : PRE_first_tail_x8_r0_body.st118.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1145.next || PRE_first_tail_x8_r0_body.cl118.contains b) = true
def PRE_first_tail_x8_r0_body.zl118 : List Nat := PRE_first_tail_x8_r0_body.cl118.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE118 : PRE_first_tail_x8_r0_body.zl118.map (fun a => PRE_first_tail_x8_r0_body.s1146.heap.get (PRE_first_tail_x8_r0_body.kappa118.a a)) = PRE_first_tail_x8_r0_body.zl118.map (fun a => (PRE_first_tail_x8_r0_body.s1147.heap.get a).map PRE_first_tail_x8_r0_body.kappa118.hobj)
theorem PRE_first_tail_x8_r0_body.zimg118 : HeapImg PRE_first_tail_x8_r0_body.kappa118 PRE_first_tail_x8_r0_body.s1147 PRE_first_tail_x8_r0_body.s1146 PRE_first_tail_x8_r0_body.zl118 := PRE_first_tail_x8_r0_body.zimgE118
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl118 : PRE_first_tail_x8_r0_body.s1146.ctl = PRE_first_tail_x8_r0_body.kappa118.ctl PRE_first_tail_x8_r0_body.s1147.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack118 : PRE_first_tail_x8_r0_body.s1146.stack = PRE_first_tail_x8_r0_body.s1147.stack.map PRE_first_tail_x8_r0_body.kappa118.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs118 : PRE_first_tail_x8_r0_body.s1146.jobs = PRE_first_tail_x8_r0_body.s1147.jobs.map PRE_first_tail_x8_r0_body.kappa118.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores118 : PRE_first_tail_x8_r0_body.s1146.stores = PRE_first_tail_x8_r0_body.kappa118.stores PRE_first_tail_x8_r0_body.s1147.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots118 : checkRootsSupp PRE_first_tail_x8_r0_body.s1147 5123 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC118 : PRE_first_tail_x8_r0_body.S1145.tab.length + PRE_first_tail_x8_r0_body.cws118.length = 5123
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap118 : PRE_first_tail_x8_r0_body.kappa118 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1145.next 2767843 PRE_first_tail_x8_r0_body.S1145.tab.length PRE_first_tail_x8_r0_body.pl118 (PRE_first_tail_x8_r0_body.nr118.map NumV.ref) PRE_first_tail_x8_r0_body.kd118.big
  PRE_first_tail_x8_r0_body.kd118.region PRE_first_tail_x8_r0_body.kd118.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin118 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1147.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc118 : Conv.jcleanListB (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1147 PRE_first_tail_x8_r0_body.cl118 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB118 : noBigRootsP (fun i => !Conv.oldBigB (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1147.trace PRE_first_tail_x8_r0_body.s1147 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm118 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 17625 = true
theorem PRE_first_tail_x8_r0_body.cjcl118 (h : Conv.JClean (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1145) : Conv.JClean (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1147 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle118)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap118 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd118 a ha)) PRE_first_tail_x8_r0_body.zjc118

end Host.Load.Run.Tpl
end

section -- st118/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st118.bodyLast from PRE_first_tail_x8_r0_body.st118.s1 to PRE_first_tail_x8_r0_body.st118.s2 :
  interpS (step PRE_first_tail_x8_r0_body.st118.F PRE_first_tail_x8_r0_body.st118.s1).run PRE_first_tail_x8_r0_body.st118.S1 = some (PRE_first_tail_x8_r0_body.st118.s2, PRE_first_tail_x8_r0_body.st118.S2)
kernel_rfl PRE_first_tail_x8_r0_body.st118.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st118.s1.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st118.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st118.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st118/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st118.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st118.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st118.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st118.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st118.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st118.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st118.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st118.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st118.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st118.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st118.s0 PRE_first_tail_x8_r0_body.st118.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st118.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st118.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st118.s1 PRE_first_tail_x8_r0_body.st118.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st118/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st118.bodyK0F from PRE_first_tail_x8_r0_body.st118.s0 to PRE_first_tail_x8_r0_body.st118.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st118.F (PRE_first_tail_x8_r0_body.st118.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st118.ks 0).getD 0) PRE_first_tail_x8_r0_body.st118.s0 PRE_first_tail_x8_r0_body.st118.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st118.s1, PRE_first_tail_x8_r0_body.st118.S1)
theorem PRE_first_tail_x8_r0_body.st118.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st118.F (PRE_first_tail_x8_r0_body.st118.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st118.ks 0).getD 0) PRE_first_tail_x8_r0_body.st118.s0 PRE_first_tail_x8_r0_body.st118.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st118.s1, PRE_first_tail_x8_r0_body.st118.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st118.bodyOkLN_ok PRE_first_tail_x8_r0_body.st118.bodyK0F
end Host.Load.Run.Tpl
end

section -- st118/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st118.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st118.F (PRE_first_tail_x8_r0_body.st118.bodyOkL bytes rows) 27 PRE_first_tail_x8_r0_body.st118.s0 PRE_first_tail_x8_r0_body.st118.S0 = some (PRE_first_tail_x8_r0_body.st118.s1, PRE_first_tail_x8_r0_body.st118.S1) :=
  (congrFun (congrFun PRE_first_tail_x8_r0_body.st118.bodyK0 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st118.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st118.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st118.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st118.F (PRE_first_tail_x8_r0_body.st118.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st118.s0
  S0 := PRE_first_tail_x8_r0_body.st118.S0
  s1 := PRE_first_tail_x8_r0_body.st118.s1
  S1 := PRE_first_tail_x8_r0_body.st118.S1
  s2 := PRE_first_tail_x8_r0_body.st118.s2
  S2 := PRE_first_tail_x8_r0_body.st118.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st118.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st118.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st118.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st118.bodyHalt
  last := PRE_first_tail_x8_r0_body.st118.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st118.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC119
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 119 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1151` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa119` into the merged state
`PRE_first_tail_x8_r0_body.s1150`. -/

def PRE_first_tail_x8_r0_body.pl119 : List Nat := [2768139]
def PRE_first_tail_x8_r0_body.nr119 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd119 : RData :=
  ⟨2768130, 2768140, Stage.setAll PTrie.nil [(2768129, 2768139)], Stage.setAll PTrie.nil [],
   20541, 20541, 17629, 17629, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa119 : Map :=
  Conv.Map.compact 2768129 2768140 5140 PRE_first_tail_x8_r0_body.pl119 (PRE_first_tail_x8_r0_body.nr119.map NumV.ref) PRE_first_tail_x8_r0_body.kd119.big
    PRE_first_tail_x8_r0_body.kd119.region PRE_first_tail_x8_r0_body.kd119.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws119 : List Nat := []
noncomputable def PRE_first_tail_x8_r0_body.crs119 : List SymE := PRE_first_tail_x8_r0_body.nr119.map fun r => (nth? PRE_first_tail_x8_r0_body.S1150.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta119 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws119 PRE_first_tail_x8_r0_body.crs119
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB119 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x8_r0_body.ctab119 : PRE_first_tail_x8_r0_body.S1151.tab = PRE_first_tail_x8_r0_body.S1149.tab ++ PRE_first_tail_x8_r0_body.cws119.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace119 : PRE_first_tail_x8_r0_body.s1151.trace = PRE_first_tail_x8_r0_body.s1149.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext119 : PRE_first_tail_x8_r0_body.s1151.next = 2768130
kernel_rfl PRE_first_tail_x8_r0_body.ccounters119 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1151.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1151.ffi).mlx.nnext) = (20541, 17629)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue119 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1150.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1151.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa119.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp119 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1151.ffi).mlx.tokens.all (bSN 5140) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean119 : Conv.cleanListB 20541 131072 (fun r => Nat.ble 82164 r) PRE_first_tail_x8_r0_body.s1151
    (PRE_first_tail_x8_r0_body.wrB119 ++ (List.range 1).map (2768129 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs119 : bigsOutB 20541 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1151.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK119
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl119`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl119 : List Nat := [2665, 2673467, 2768129]
def PRE_first_tail_x8_r0_body.clo119 : List Nat := []
def PRE_first_tail_x8_r0_body.cln119 : List Nat := []
def PRE_first_tail_x8_r0_body.cli119 : List Nat := []
kernel_rfl PRE_first_tail_x8_r0_body.cheap119 : PRE_first_tail_x8_r0_body.s1151.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1149.heap (PRE_first_tail_x8_r0_body.cl119.filterMap fun a => (PRE_first_tail_x8_r0_body.s1151.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe119 : Nat.ble PRE_first_tail_x8_r0_body.s1149.next PRE_first_tail_x8_r0_body.s1151.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP119 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1149 PRE_first_tail_x8_r0_body.s1151 PRE_first_tail_x8_r0_body.cl119 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp119 : Conv.suppListB PRE_first_tail_x8_r0_body.s1151 5140 PRE_first_tail_x8_r0_body.cl119 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound119 : Conv.boundListB PRE_first_tail_x8_r0_body.s1151 PRE_first_tail_x8_r0_body.cl119 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK119 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1151.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln119.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1151.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK119 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1151.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo119.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1151.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK119 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1151.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli119.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1151.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst119 : Conv.sstListB 5140 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1151.ffi).mlx PRE_first_tail_x8_r0_body.cln119 PRE_first_tail_x8_r0_body.clo119 PRE_first_tail_x8_r0_body.cli119 = true

end Host.Load.Run.Tpl
end

section -- SiteCl119
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA119 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1151.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo119.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1151.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd119 : (PRE_first_tail_x8_r0_body.clo119 ++ PRE_first_tail_x8_r0_body.cln119 ++ PRE_first_tail_x8_r0_body.cli119).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle119 : Conv.Cnt.leB (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt) (⟨20541, 17629, 2768130, 5140⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck119 : Conv.ncleanListB (⟨20541, 17629, 2768130, 5140⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1151.ffi).mlx PRE_first_tail_x8_r0_body.clo119 PRE_first_tail_x8_r0_body.cln119 PRE_first_tail_x8_r0_body.cli119 = true
theorem PRE_first_tail_x8_r0_body.cncl119 (h : Conv.NClean (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx) : Conv.NClean (⟨20541, 17629, 2768130, 5140⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1151.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle119 PRE_first_tail_x8_r0_body.ckA119 PRE_first_tail_x8_r0_body.cobjsK119 PRE_first_tail_x8_r0_body.cnodesK119 PRE_first_tail_x8_r0_body.citemsK119 PRE_first_tail_x8_r0_body.cbd119 PRE_first_tail_x8_r0_body.cck119

end Host.Load.Run.Tpl
end

section -- SiteS119
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 119 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc119 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P119 : LoadP := PRE_first_tail_x8_r0_body.Pc119.raise 17629
kernel_rfl PRE_first_tail_x8_r0_body.craise119 : Nat.ble PRE_first_tail_x8_r0_body.Pc119.N0 17629 = true
theorem PRE_first_tail_x8_r0_body.raised119 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc119 PRE_first_tail_x8_r0_body.P119 :=
  .inr ⟨17629, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise119, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_119 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1151.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_119 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1150.ffi)
def PRE_first_tail_x8_r0_body.khinv119 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x8_r0_body.kninv119 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS119 : List Nat := []
def PRE_first_tail_x8_r0_body.cnS119 : List Nat := List.range' 17629 0
def PRE_first_tail_x8_r0_body.ciS119 : List Nat := [] ++ List.range' 17629 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0119 : PRE_first_tail_x8_r0_body.kd119.nh0 = PRE_first_tail_x8_r0_body.cx0_119.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1119 : PRE_first_tail_x8_r0_body.kd119.nh1 = PRE_first_tail_x8_r0_body.cx1_119.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0119 : PRE_first_tail_x8_r0_body.kd119.nn0 = PRE_first_tail_x8_r0_body.cx0_119.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1119 : PRE_first_tail_x8_r0_body.kd119.nn1 = PRE_first_tail_x8_r0_body.cx1_119.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo119 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P119.lo && Nat.ble PRE_first_tail_x8_r0_body.P119.lo PRE_first_tail_x8_r0_body.cx0_119.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P119.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P119.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt119 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_119.mlx.next PRE_first_tail_x8_r0_body.cx1_119.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_119.mlx.nnext PRE_first_tail_x8_r0_body.cx1_119.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband119 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P119.NL && Nat.ble PRE_first_tail_x8_r0_body.P119.NL PRE_first_tail_x8_r0_body.P119.N0 && Nat.ble PRE_first_tail_x8_r0_body.P119.N0 PRE_first_tail_x8_r0_body.cx0_119.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow119 : PRE_first_tail_x8_r0_body.kd119.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren119 : checkRenG PRE_first_tail_x8_r0_body.kd119.hnd PRE_first_tail_x8_r0_body.khinv119 (phB PRE_first_tail_x8_r0_body.cx0_119.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband119 : PRE_first_tail_x8_r0_body.kd119.checkBand PRE_first_tail_x8_r0_body.P119.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos119 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd119.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren119 : checkRenG PRE_first_tail_x8_r0_body.kd119.node PRE_first_tail_x8_r0_body.kninv119 (pnB PRE_first_tail_x8_r0_body.cx0_119.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow119 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd119.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P119.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd119.nodeF j) PRE_first_tail_x8_r0_body.cx1_119.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a119 : PRE_first_tail_x8_r0_body.cx0_119.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b119 : PRE_first_tail_x8_r0_body.cx0_119.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1119 : PRE_first_tail_x8_r0_body.cx1_119.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend119 : PRE_first_tail_x8_r0_body.cx1_119.mlx.pending = PRE_first_tail_x8_r0_body.cx0_119.mlx.pending.map PRE_first_tail_x8_r0_body.kappa119.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh119 : PRE_first_tail_x8_r0_body.cx1_119.mlx.errh = PRE_first_tail_x8_r0_body.cx0_119.mlx.errh.map PRE_first_tail_x8_r0_body.kappa119.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles119 : PRE_first_tail_x8_r0_body.cx1_119.mlx.files = PRE_first_tail_x8_r0_body.cx0_119.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch119 : PRE_first_tail_x8_r0_body.cx1_119.mlx.arch = PRE_first_tail_x8_r0_body.cx0_119.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes119 : PRE_first_tail_x8_r0_body.cx1_119.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_119.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired119 : PRE_first_tail_x8_r0_body.cx1_119.mlx.wired = PRE_first_tail_x8_r0_body.cx0_119.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost119 : PRE_first_tail_x8_r0_body.cx1_119.host = PRE_first_tail_x8_r0_body.cx0_119.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd119`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0119 : PRE_first_tail_x8_r0_body.kd119.n0 = 2768130
kernel_rfl PRE_first_tail_x8_r0_body.ckn1119 : PRE_first_tail_x8_r0_body.kd119.n1 = 2768140
kernel_rfl PRE_first_tail_x8_r0_body.ckheap119 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd119.heap).all (fun x => Nat.ble 2768129 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl119 : (List.range 1).all (fun j => decide (PRE_first_tail_x8_r0_body.kd119.heap.get (2768129 + j) = nth? PRE_first_tail_x8_r0_body.pl119 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja119 : Nat.ble 2768129 2768129 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn119 : Nat.ble 5140 5140 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD119 : Nat.ble 2768129 PRE_first_tail_x8_r0_body.kd119.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn119 : Nat.ble 20541 PRE_first_tail_x8_r0_body.kd119.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn119 : Nat.ble 17629 PRE_first_tail_x8_r0_body.kd119.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb119 : Nat.ble 20541 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap119 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd119.heap).all (Nat.ble (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd119 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd119.hnd).all (Nat.ble (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode119 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd119.node).all (Nat.ble (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix119 : Conv.FixOld (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa119 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja119) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn119) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD119) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn119) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn119) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb119) PRE_first_tail_x8_r0_body.fheap119 PRE_first_tail_x8_r0_body.fhnd119 PRE_first_tail_x8_r0_body.fnode119
kernel_rfl PRE_first_tail_x8_r0_body.fcxn119 : (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn119 : (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0119 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_119.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_119.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk119 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd119.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A119 : PRE_first_tail_x8_r0_body.cx1_119.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS119.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_119.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O119 : PRE_first_tail_x8_r0_body.cx1_119.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS119.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_119.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N119 : PRE_first_tail_x8_r0_body.cx1_119.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS119.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_119.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I119 : PRE_first_tail_x8_r0_body.cx1_119.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS119.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_119.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd119 : (PRE_first_tail_x8_r0_body.clo119 ++ PRE_first_tail_x8_r0_body.cln119 ++ PRE_first_tail_x8_r0_body.cli119 ++ PRE_first_tail_x8_r0_body.cwS119 ++ PRE_first_tail_x8_r0_body.cnS119 ++ PRE_first_tail_x8_r0_body.ciS119).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW119 : PRE_first_tail_x8_r0_body.cwS119.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo119.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI119 : PRE_first_tail_x8_r0_body.ciS119.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli119.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN119 : PRE_first_tail_x8_r0_body.cnS119.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF119 : PRE_first_tail_x8_r0_body.cln119.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh119 : PRE_first_tail_x8_r0_body.clo119.all (handleOK PRE_first_tail_x8_r0_body.kappa119 PRE_first_tail_x8_r0_body.P119.lo PRE_first_tail_x8_r0_body.cx0_119.mlx PRE_first_tail_x8_r0_body.cx1_119.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo119 : PRE_first_tail_x8_r0_body.clo119.map (fun h => PRE_first_tail_x8_r0_body.cx1_119.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa119.handle h)) = PRE_first_tail_x8_r0_body.clo119.map (fun h => (PRE_first_tail_x8_r0_body.cx0_119.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa119.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok119 : PRE_first_tail_x8_r0_body.clo119.all (objOK PRE_first_tail_x8_r0_body.kappa119 PRE_first_tail_x8_r0_body.P119.NL PRE_first_tail_x8_r0_body.cx0_119.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd119 : PRE_first_tail_x8_r0_body.cln119.all (nodeOKF PRE_first_tail_x8_r0_body.kappa119 PRE_first_tail_x8_r0_body.P119 PRE_first_tail_x8_r0_body.cx0_119.mlx PRE_first_tail_x8_r0_body.cx1_119.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp119 : ((PRE_first_tail_x8_r0_body.cln119.filter (fullB PRE_first_tail_x8_r0_body.P119))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_119.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa119.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln119.filter (fullB PRE_first_tail_x8_r0_body.P119))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_119.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa119.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI119 : incrB PRE_first_tail_x8_r0_body.kd119.nodeF (List.range' 17629 0) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK119 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd119.node).all (fun k => Nat.ble 17629 k && Nat.blt k 17629) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL119 : (PRE_first_tail_x8_r0_body.cln119.filter (Nat.ble PRE_first_tail_x8_r0_body.P119.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd119.nodeF i) && (Nat.blt i 17629 || Nat.ble PRE_first_tail_x8_r0_body.kd119.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord119 : (PRE_first_tail_x8_r0_body.cln119.filter (Nat.ble PRE_first_tail_x8_r0_body.P119.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd119.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd119.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd119.nodeF j) (PRE_first_tail_x8_r0_body.kd119.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow119 PRE_first_tail_x8_r0_body.cnn1119 PRE_first_tail_x8_r0_body.fnordI119 PRE_first_tail_x8_r0_body.fnordK119 PRE_first_tail_x8_r0_body.fnordL119
kernel_rfl PRE_first_tail_x8_r0_body.fi119 : PRE_first_tail_x8_r0_body.cli119.all (pnB PRE_first_tail_x8_r0_body.cx0_119.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii119 : PRE_first_tail_x8_r0_body.cli119.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_119.mlx.items.get (PRE_first_tail_x8_r0_body.kappa119.node k) = (PRE_first_tail_x8_r0_body.cx0_119.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa119.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot119 (clean : Conv.NClean (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P119.NL) (cl : SSt (· < 5140) PRE_first_tail_x8_r0_body.cx0_119.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P119 5140 PRE_first_tail_x8_r0_body.kappa119 PRE_first_tail_x8_r0_body.kd119 PRE_first_tail_x8_r0_body.khinv119 PRE_first_tail_x8_r0_body.kninv119 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx PRE_first_tail_x8_r0_body.cx0_119.mlx PRE_first_tail_x8_r0_body.cx1_119.mlx (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo119 PRE_first_tail_x8_r0_body.cln119 PRE_first_tail_x8_r0_body.cli119 PRE_first_tail_x8_r0_body.cwS119 PRE_first_tail_x8_r0_body.cnS119 PRE_first_tail_x8_r0_body.ciS119 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0119, PRE_first_tail_x8_r0_body.cnh1119, PRE_first_tail_x8_r0_body.cnn0119, PRE_first_tail_x8_r0_body.cnn1119, PRE_first_tail_x8_r0_body.cplo119, PRE_first_tail_x8_r0_body.ccnt119, PRE_first_tail_x8_r0_body.cnband119, PRE_first_tail_x8_r0_body.chbelow119, PRE_first_tail_x8_r0_body.chren119, PRE_first_tail_x8_r0_body.cband119, PRE_first_tail_x8_r0_body.cnh1pos119, PRE_first_tail_x8_r0_body.cnren119, PRE_first_tail_x8_r0_body.cnlow119, PRE_first_tail_x8_r0_body.cabs0a119, PRE_first_tail_x8_r0_body.cabs0b119, PRE_first_tail_x8_r0_body.ctok1119, PRE_first_tail_x8_r0_body.cpend119, PRE_first_tail_x8_r0_body.cerrh119, PRE_first_tail_x8_r0_body.cfiles119, PRE_first_tail_x8_r0_body.carch119, PRE_first_tail_x8_r0_body.csizes119, PRE_first_tail_x8_r0_body.cwired119, PRE_first_tail_x8_r0_body.cfix119, clean, PRE_first_tail_x8_r0_body.fcxn119, PRE_first_tail_x8_r0_body.fcnn119, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0119, PRE_first_tail_x8_r0_body.fnk119, PRE_first_tail_x8_r0_body.ckA119, PRE_first_tail_x8_r0_body.cobjsK119, PRE_first_tail_x8_r0_body.cnodesK119, PRE_first_tail_x8_r0_body.citemsK119, PRE_first_tail_x8_r0_body.f1A119, PRE_first_tail_x8_r0_body.f1O119, PRE_first_tail_x8_r0_body.f1N119, PRE_first_tail_x8_r0_body.f1I119, PRE_first_tail_x8_r0_body.fbd119, PRE_first_tail_x8_r0_body.fincW119, PRE_first_tail_x8_r0_body.fincI119, PRE_first_tail_x8_r0_body.fincN119, PRE_first_tail_x8_r0_body.flnF119, PRE_first_tail_x8_r0_body.fh119, PRE_first_tail_x8_r0_body.fo119, PRE_first_tail_x8_r0_body.fok119, PRE_first_tail_x8_r0_body.fnd119, PRE_first_tail_x8_r0_body.fp119, PRE_first_tail_x8_r0_body.fnord119, PRE_first_tail_x8_r0_body.fi119, PRE_first_tail_x8_r0_body.fii119⟩
theorem PRE_first_tail_x8_r0_body.cnshift119 (clean : Conv.NClean (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P119.NL) (cl : SSt (· < 5140) PRE_first_tail_x8_r0_body.cx0_119.mlx) : NShift PRE_first_tail_x8_r0_body.P119 5140 PRE_first_tail_x8_r0_body.kappa119 PRE_first_tail_x8_r0_body.cx0_119 PRE_first_tail_x8_r0_body.cx1_119 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot119 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost119 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0119 PRE_first_tail_x8_r0_body.ckn1119 PRE_first_tail_x8_r0_body.ckheap119 PRE_first_tail_x8_r0_body.ckpl119)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_119 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1149.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_119 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1149.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_119 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1149.ffi) = some PRE_first_tail_x8_r0_body.fxC_119
kernel_rfl PRE_first_tail_x8_r0_body.okrC_119 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1149.ffi) = some PRE_first_tail_x8_r0_body.krC_119
noncomputable def PRE_first_tail_x8_r0_body.fx0_119 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1151.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_119 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1151.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_119 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1151.ffi) = some PRE_first_tail_x8_r0_body.fx0_119
kernel_rfl PRE_first_tail_x8_r0_body.okr0_119 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1151.ffi) = some PRE_first_tail_x8_r0_body.kr0_119
noncomputable def PRE_first_tail_x8_r0_body.fx1_119 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1150.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_119 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1150.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_119 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1150.ffi) = some PRE_first_tail_x8_r0_body.fx1_119
kernel_rfl PRE_first_tail_x8_r0_body.okr1_119 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1150.ffi) = some PRE_first_tail_x8_r0_body.kr1_119
kernel_rfl PRE_first_tail_x8_r0_body.ff0119 : PRE_first_tail_x8_r0_body.fx0_119 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_119 (PRE_first_tail_x8_r0_body.clo119.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_119.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1119 : PRE_first_tail_x8_r0_body.fx1_119 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_119 (PRE_first_tail_x8_r0_body.cwS119.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_119.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck119 : freedLB PRE_first_tail_x8_r0_body.kappa119 PRE_first_tail_x8_r0_body.cx0_119.mlx PRE_first_tail_x8_r0_body.fx0_119 PRE_first_tail_x8_r0_body.fx1_119 PRE_first_tail_x8_r0_body.clo119 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0119 : PRE_first_tail_x8_r0_body.kr0_119.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_119.flags (PRE_first_tail_x8_r0_body.clo119.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_119.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0119 : PRE_first_tail_x8_r0_body.kr0_119.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_119.targs (PRE_first_tail_x8_r0_body.clo119.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_119.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1119 : PRE_first_tail_x8_r0_body.kr1_119.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_119.flags (PRE_first_tail_x8_r0_body.cwS119.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_119.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1119 : PRE_first_tail_x8_r0_body.kr1_119.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_119.targs (PRE_first_tail_x8_r0_body.cwS119.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_119.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck119 : krecLB PRE_first_tail_x8_r0_body.kappa119 5140 PRE_first_tail_x8_r0_body.cx0_119.mlx PRE_first_tail_x8_r0_body.kr0_119 PRE_first_tail_x8_r0_body.kr1_119 PRE_first_tail_x8_r0_body.clo119 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn119 : Nat.ble 5140 5140 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge119 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1150.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1151.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR119 : pendRegB PRE_first_tail_x8_r0_body.kappa119 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1151.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe119 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1151.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1150.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift119 (clean : Conv.NClean (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P119.NL) (cl : SSt (· < 5140) PRE_first_tail_x8_r0_body.cx0_119.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_119.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_119.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_119.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1149.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_119.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P119 5140 PRE_first_tail_x8_r0_body.kappa119 PRE_first_tail_x8_r0_body.s1151.ffi PRE_first_tail_x8_r0_body.s1150.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift119 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue119, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp119 t ht),
    PRE_first_tail_x8_r0_body.cbridge119,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1151.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1150.ffi) (PRE_first_tail_x8_r0_body.cfoot119 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_119 PRE_first_tail_x8_r0_body.ofx1_119 hobjC PRE_first_tail_x8_r0_body.ff0119 PRE_first_tail_x8_r0_body.ff1119 PRE_first_tail_x8_r0_body.ffck119,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1151.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1150.ffi) (PRE_first_tail_x8_r0_body.cfoot119 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_119 PRE_first_tail_x8_r0_body.okr1_119 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn119) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0119 PRE_first_tail_x8_r0_body.fkt0119 PRE_first_tail_x8_r0_body.fkf1119 PRE_first_tail_x8_r0_body.fkt1119 PRE_first_tail_x8_r0_body.fkck119,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0119 PRE_first_tail_x8_r0_body.cnh1119 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe119) PRE_first_tail_x8_r0_body.cpendR119⟩

end Host.Load.Run.Tpl
end

section -- st119/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st119 0
host_stream_state PRE_first_tail_x8_r0_body.st119 1
host_stream_state PRE_first_tail_x8_r0_body.st119 2
end Host.Load.Run.Tpl
end

section -- Site119
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 119 of chain `PRE_first_tail_x8_r0_body`: `plan__g119__g120` (`plan`), the call state `PRE_first_tail_x8_r0_body.s1149`, the merged state `PRE_first_tail_x8_r0_body.s1150`,
the site template `PRE_first_tail_x8_r0_body.st119` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1151`: the merge.
The footprint's facts are in `SiteF119`, the compaction's in `SiteC119`, `SiteK119`, `SiteNa119`, `SiteNb119`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso119 : PRE_first_tail_x8_r0_body.st119.s0 = { PRE_first_tail_x8_r0_body.s1149 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs119 : List Frame := PRE_first_tail_x8_r0_body.s1149.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_119 : PRE_first_tail_x8_r0_body.S1149.tab.length = 5140
kernel_rfl PRE_first_tail_x8_r0_body.tab0_119 : PRE_first_tail_x8_r0_body.st119.S0.tab = PRE_first_tail_x8_r0_body.S1149.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws119 : List Nat := [2993, 2994, 2995]
kernel_rfl PRE_first_tail_x8_r0_body.fresh119 : (PRE_first_tail_x8_r0_body.S1149.tab.all fun e => PRE_first_tail_x8_r0_body.ws119.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1149.oracle.all fun q => PRE_first_tail_x8_r0_body.ws119.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab119 : PRE_first_tail_x8_r0_body.S1150.tab = PRE_first_tail_x8_r0_body.S1149.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws119
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen119 : PRE_first_tail_x8_r0_body.st119.S2.tab.length - PRE_first_tail_x8_r0_body.st119.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged119`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap119 : PRE_first_tail_x8_r0_body.s1150.heap = PRE_first_tail_x8_r0_body.st119.s2.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext119 : PRE_first_tail_x8_r0_body.s1150.next = PRE_first_tail_x8_r0_body.st119.s2.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl119 : PRE_first_tail_x8_r0_body.s1150.ctl = PRE_first_tail_x8_r0_body.st119.s2.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack119 : PRE_first_tail_x8_r0_body.s1150.stack = PRE_first_tail_x8_r0_body.st119.s2.stack ++ PRE_first_tail_x8_r0_body.s1149.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs119 : PRE_first_tail_x8_r0_body.s1150.jobs = PRE_first_tail_x8_r0_body.st119.s2.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi119 : PRE_first_tail_x8_r0_body.s1150.ffi = PRE_first_tail_x8_r0_body.st119.s2.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace119 : PRE_first_tail_x8_r0_body.s1150.trace = PRE_first_tail_x8_r0_body.st119.s2.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores119 : PRE_first_tail_x8_r0_body.s1150.stores = PRE_first_tail_x8_r0_body.st119.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD119
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 119 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived119 : PRE_first_tail_x8_r0_body.nr119.map (fun r => nth? PRE_first_tail_x8_r0_body.st119.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo119 : PRE_first_tail_x8_r0_body.nr119.all (Nat.ble 5140) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj119 : PRE_first_tail_x8_r0_body.cws119.all (fun c => !PRE_first_tail_x8_r0_body.ws119.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ119 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws119 PRE_first_tail_x8_r0_body.crs119 PRE_first_tail_x8_r0_body.ws119

end Host.Load.Run.Tpl
end

section -- st119/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st119`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st119.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st119.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st119.s2.heap PRE_first_tail_x8_r0_body.st119.wrR ++ freshOf PRE_first_tail_x8_r0_body.st119.s2.heap PRE_first_tail_x8_r0_body.st119.s0.next PRE_first_tail_x8_r0_body.st119.s2.next
noncomputable def PRE_first_tail_x8_r0_body.st119.wr : List Nat := PRE_first_tail_x8_r0_body.st119.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st119.heapFoot : PRE_first_tail_x8_r0_body.st119.s2.heap = setAll PRE_first_tail_x8_r0_body.st119.s0.heap PRE_first_tail_x8_r0_body.st119.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st119.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st119.s0.next PRE_first_tail_x8_r0_body.st119.s2.next = true
theorem PRE_first_tail_x8_r0_body.st119.grows : PRE_first_tail_x8_r0_body.st119.s0.next ≤ PRE_first_tail_x8_r0_body.st119.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st119.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st119.wh : List Nat := []
def PRE_first_tail_x8_r0_body.st119.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st119.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st119.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st119.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st119.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st119.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st119.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st119.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st119.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st119.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st119.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st119.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st119.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st119.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st119.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st119.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st119.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st119.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st119.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st119.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st119.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st119.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st119.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st119.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st119.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st119.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st119.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st119.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st119.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st119.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF119
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 119 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB119 : nodupT PRE_first_tail_x8_r0_body.st119.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup119 : PRE_first_tail_x8_r0_body.st119.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB119).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB119 : PRE_first_tail_x8_r0_body.st119.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound119 : ∀ b ∈ PRE_first_tail_x8_r0_body.st119.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB119 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr119 := PRE_first_tail_x8_r0_body.st119.s2.trace.take 0
kernel_rfl PRE_first_tail_x8_r0_body.traceEq119 : PRE_first_tail_x8_r0_body.st119.s2.trace = PRE_first_tail_x8_r0_body.trFr119 ++ PRE_first_tail_x8_r0_body.st119.s0.trace
theorem PRE_first_tail_x8_r0_body.trace119 : ∃ fr, PRE_first_tail_x8_r0_body.st119.s2.trace = fr ++ PRE_first_tail_x8_r0_body.st119.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq119⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide119 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB119 : (PRE_first_tail_x8_r0_body.wide119.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st119.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix119 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide119, WFix Map.id (Present PRE_first_tail_x8_r0_body.st119.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB119 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL119
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 119 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1150`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO119 : PRE_first_tail_x8_r0_body.st119.S0.oracle = PRE_first_tail_x8_r0_body.st119.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B119 : PRE_first_tail_x8_r0_body.st119.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st119.s0.next || (PRE_first_tail_x8_r0_body.st119.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot119 : Conv.StageFoot PRE_first_tail_x8_r0_body.st119.wr PRE_first_tail_x8_r0_body.st119.s0 PRE_first_tail_x8_r0_body.st119.s2 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st119.heapFoot PRE_first_tail_x8_r0_body.wrNodup119 PRE_first_tail_x8_r0_body.wrBound119 PRE_first_tail_x8_r0_body.wr0B119 PRE_first_tail_x8_r0_body.st119.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged119 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st119.F.S → PRE_first_tail_x8_r0_body.st119.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st119.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st119.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs119 PRE_first_tail_x8_r0_body.st119.wr PRE_first_tail_x8_r0_body.s1149 PRE_first_tail_x8_r0_body.st119.s2 PRE_first_tail_x8_r0_body.st119.s0
      PRE_first_tail_x8_r0_body.st119.s2.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st119.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1150 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso119 PRE_first_tail_x8_r0_body.stFoot119 PRE_first_tail_x8_r0_body.wrNodup119 PRE_first_tail_x8_r0_body.wrBound119 PRE_first_tail_x8_r0_body.trace119 PRE_first_tail_x8_r0_body.mheap119
    PRE_first_tail_x8_r0_body.mnext119 PRE_first_tail_x8_r0_body.mctl119 PRE_first_tail_x8_r0_body.mstack119 PRE_first_tail_x8_r0_body.mjobs119 PRE_first_tail_x8_r0_body.mffi119 PRE_first_tail_x8_r0_body.mtrace119 PRE_first_tail_x8_r0_body.mstores119 h

def PRE_first_tail_x8_r0_body.arrEl119_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE119_2665 : arrOf PRE_first_tail_x8_r0_body.s1150 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl119_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA119_2665 : isArrB PRE_first_tail_x8_r0_body.s1150 2665 = true
theorem PRE_first_tail_x8_r0_body.arr119_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1150.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl119_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE119_2665 PRE_first_tail_x8_r0_body.arrA119_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN119_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl119_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR119_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl119_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN119_2665

def PRE_first_tail_x8_r0_body.arrEl119_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE119_2673467 : arrOf PRE_first_tail_x8_r0_body.s1150 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl119_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA119_2673467 : isArrB PRE_first_tail_x8_r0_body.s1150 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr119_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1150.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl119_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE119_2673467 PRE_first_tail_x8_r0_body.arrA119_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN119_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl119_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR119_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl119_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN119_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k119 : isArrB PRE_first_tail_x8_r0_body.s1150 4910 = false
theorem PRE_first_tail_x8_r0_body.keep119 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1150 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k119 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr119_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl119_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ119
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 119 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1149`, the merged
state `PRE_first_tail_x8_r0_body.s1150`, the canonical state `PRE_first_tail_x8_r0_body.s1151`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl119 : PRE_first_tail_x8_r0_body.pl119.all (Nat.ble PRE_first_tail_x8_r0_body.s1149.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd119 : nodupT PRE_first_tail_x8_r0_body.pl119 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1119 : Nat.ble PRE_first_tail_x8_r0_body.s1149.next 2768140 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst119 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1149.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn119 : PRE_first_tail_x8_r0_body.s1151.next = PRE_first_tail_x8_r0_body.s1149.next + PRE_first_tail_x8_r0_body.pl119.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn119 : PRE_first_tail_x8_r0_body.s1150.next = 2768140
kernel_rfl PRE_first_tail_x8_r0_body.zgrow119 : Nat.ble PRE_first_tail_x8_r0_body.s1151.next PRE_first_tail_x8_r0_body.s1150.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh119 : PRE_first_tail_x8_r0_body.S1149.tab.all (fun e => PRE_first_tail_x8_r0_body.cws119.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd119 : nodupT PRE_first_tail_x8_r0_body.cws119 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi119 : PRE_first_tail_x8_r0_body.nr119.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1150.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt119 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1149.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg119_2665 : PRE_first_tail_x8_r0_body.s1151.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1151 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk119_2665 : (objOf PRE_first_tail_x8_r0_body.s1151 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm119_2665 : PRE_first_tail_x8_r0_body.s1150.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa119.obj (objOf PRE_first_tail_x8_r0_body.s1151 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1150 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg119_2673467 : PRE_first_tail_x8_r0_body.s1151.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1151 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk119_2673467 : (objOf PRE_first_tail_x8_r0_body.s1151 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm119_2673467 : PRE_first_tail_x8_r0_body.s1150.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa119.obj (objOf PRE_first_tail_x8_r0_body.s1151 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1150 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw119_4910 : (PRE_first_tail_x8_r0_body.s1151.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw119_2673472 : (PRE_first_tail_x8_r0_body.s1151.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw119_2673473 : (PRE_first_tail_x8_r0_body.s1151.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd119 : PRE_first_tail_x8_r0_body.cl119.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr119 : PRE_first_tail_x8_r0_body.st119.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1149.next || PRE_first_tail_x8_r0_body.cl119.contains b) = true
def PRE_first_tail_x8_r0_body.zl119 : List Nat := PRE_first_tail_x8_r0_body.cl119.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE119 : PRE_first_tail_x8_r0_body.zl119.map (fun a => PRE_first_tail_x8_r0_body.s1150.heap.get (PRE_first_tail_x8_r0_body.kappa119.a a)) = PRE_first_tail_x8_r0_body.zl119.map (fun a => (PRE_first_tail_x8_r0_body.s1151.heap.get a).map PRE_first_tail_x8_r0_body.kappa119.hobj)
theorem PRE_first_tail_x8_r0_body.zimg119 : HeapImg PRE_first_tail_x8_r0_body.kappa119 PRE_first_tail_x8_r0_body.s1151 PRE_first_tail_x8_r0_body.s1150 PRE_first_tail_x8_r0_body.zl119 := PRE_first_tail_x8_r0_body.zimgE119
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl119 : PRE_first_tail_x8_r0_body.s1150.ctl = PRE_first_tail_x8_r0_body.kappa119.ctl PRE_first_tail_x8_r0_body.s1151.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack119 : PRE_first_tail_x8_r0_body.s1150.stack = PRE_first_tail_x8_r0_body.s1151.stack.map PRE_first_tail_x8_r0_body.kappa119.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs119 : PRE_first_tail_x8_r0_body.s1150.jobs = PRE_first_tail_x8_r0_body.s1151.jobs.map PRE_first_tail_x8_r0_body.kappa119.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores119 : PRE_first_tail_x8_r0_body.s1150.stores = PRE_first_tail_x8_r0_body.kappa119.stores PRE_first_tail_x8_r0_body.s1151.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots119 : checkRootsSupp PRE_first_tail_x8_r0_body.s1151 5140 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC119 : PRE_first_tail_x8_r0_body.S1149.tab.length + PRE_first_tail_x8_r0_body.cws119.length = 5140
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap119 : PRE_first_tail_x8_r0_body.kappa119 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1149.next 2768140 PRE_first_tail_x8_r0_body.S1149.tab.length PRE_first_tail_x8_r0_body.pl119 (PRE_first_tail_x8_r0_body.nr119.map NumV.ref) PRE_first_tail_x8_r0_body.kd119.big
  PRE_first_tail_x8_r0_body.kd119.region PRE_first_tail_x8_r0_body.kd119.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin119 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1151.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc119 : Conv.jcleanListB (⟨20541, 17629, 2768130, 5140⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1151 PRE_first_tail_x8_r0_body.cl119 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB119 : noBigRootsP (fun i => !Conv.oldBigB (⟨20541, 17629, 2768130, 5140⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1151.trace PRE_first_tail_x8_r0_body.s1151 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm119 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 17629 = true
theorem PRE_first_tail_x8_r0_body.cjcl119 (h : Conv.JClean (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1149) : Conv.JClean (⟨20541, 17629, 2768130, 5140⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1151 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle119)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap119 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd119 a ha)) PRE_first_tail_x8_r0_body.zjc119

end Host.Load.Run.Tpl
end

section -- st119/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st119.bodyLast from PRE_first_tail_x8_r0_body.st119.s1 to PRE_first_tail_x8_r0_body.st119.s2 :
  interpS (step PRE_first_tail_x8_r0_body.st119.F PRE_first_tail_x8_r0_body.st119.s1).run PRE_first_tail_x8_r0_body.st119.S1 = some (PRE_first_tail_x8_r0_body.st119.s2, PRE_first_tail_x8_r0_body.st119.S2)
kernel_rfl PRE_first_tail_x8_r0_body.st119.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st119.s1.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st119.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st119.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st119/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st119.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st119.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st119.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st119.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st119.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st119.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st119.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st119.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st119.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st119.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st119.s0 PRE_first_tail_x8_r0_body.st119.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st119.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st119.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st119.s1 PRE_first_tail_x8_r0_body.st119.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st119/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st119.bodyK0F from PRE_first_tail_x8_r0_body.st119.s0 to PRE_first_tail_x8_r0_body.st119.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st119.F (PRE_first_tail_x8_r0_body.st119.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st119.ks 0).getD 0) PRE_first_tail_x8_r0_body.st119.s0 PRE_first_tail_x8_r0_body.st119.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st119.s1, PRE_first_tail_x8_r0_body.st119.S1)
theorem PRE_first_tail_x8_r0_body.st119.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st119.F (PRE_first_tail_x8_r0_body.st119.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st119.ks 0).getD 0) PRE_first_tail_x8_r0_body.st119.s0 PRE_first_tail_x8_r0_body.st119.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st119.s1, PRE_first_tail_x8_r0_body.st119.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st119.bodyOkLN_ok PRE_first_tail_x8_r0_body.st119.bodyK0F
end Host.Load.Run.Tpl
end

section -- st119/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x8_r0_body.st119.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x8_r0_body.st119.F (PRE_first_tail_x8_r0_body.st119.bodyOkL bytes rows) 98 PRE_first_tail_x8_r0_body.st119.s0 PRE_first_tail_x8_r0_body.st119.S0 = some (PRE_first_tail_x8_r0_body.st119.s1, PRE_first_tail_x8_r0_body.st119.S1) :=
  (congrFun (congrFun PRE_first_tail_x8_r0_body.st119.bodyK0 bytes) rows)

theorem PRE_first_tail_x8_r0_body.st119.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x8_r0_body.st119.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x8_r0_body.st119.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x8_r0_body.st119.F (PRE_first_tail_x8_r0_body.st119.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x8_r0_body.st119.s0
  S0 := PRE_first_tail_x8_r0_body.st119.S0
  s1 := PRE_first_tail_x8_r0_body.st119.s1
  S1 := PRE_first_tail_x8_r0_body.st119.S1
  s2 := PRE_first_tail_x8_r0_body.st119.s2
  S2 := PRE_first_tail_x8_r0_body.st119.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x8_r0_body.st119.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x8_r0_body.st119.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x8_r0_body.st119.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x8_r0_body.st119.bodyHalt
  last := PRE_first_tail_x8_r0_body.st119.bodyLast
  top := noBlockTop_sound PRE_first_tail_x8_r0_body.st119.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC120
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 120 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x8_r0_body.s1168` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x8_r0_body.kappa120` into the merged state
`PRE_first_tail_x8_r0_body.s1167`. -/

def PRE_first_tail_x8_r0_body.pl120 : List Nat := [2770735, 2769910, 2770741, 2770737, 2769912, 2770743]
def PRE_first_tail_x8_r0_body.nr120 : List Nat := [5243, 5242, 5218, 5226, 5231, 5236, 5241, 5215, 5216, 5217, 5224, 5225, 5213, 5220, 5221, 5222, 5223, 5219]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x8_r0_body.kd120 : RData :=
  ⟨2769629, 2770778, Stage.setAll PTrie.nil [(2769623, 2770735), (2769624, 2769910), (2769625, 2770741), (2769626, 2770737), (2769627, 2769912), (2769628, 2770743)], Stage.setAll PTrie.nil [(20576, 20602), (20577, 20580), (20578, 20603)],
   20579, 20604, 17675, 17675, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(5213, .ref 5243), (5214, .ref 5242), (5215, .ref 5218), (5216, .ref 5226), (5217, .ref 5231), (5218, .ref 5236), (5219, .ref 5241), (5220, .ref 5215), (5221, .ref 5216), (5222, .ref 5217), (5223, .ref 5224), (5224, .ref 5225), (5225, .ref 5213), (5226, .ref 5220), (5227, .ref 5221), (5228, .ref 5222), (5229, .ref 5223), (5230, .ref 5219)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x8_r0_body.kappa120 : Map :=
  Conv.Map.compact 2769623 2770778 5213 PRE_first_tail_x8_r0_body.pl120 (PRE_first_tail_x8_r0_body.nr120.map NumV.ref) PRE_first_tail_x8_r0_body.kd120.big
    PRE_first_tail_x8_r0_body.kd120.region PRE_first_tail_x8_r0_body.kd120.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x8_r0_body.cws120 : List Nat := [3027, 3028, 3029, 3030, 3031, 3032, 3033, 3034, 3035, 3036, 3037, 3038, 3039, 3040, 3041, 3042, 3043, 3044]
noncomputable def PRE_first_tail_x8_r0_body.crs120 : List SymE := PRE_first_tail_x8_r0_body.nr120.map fun r => (nth? PRE_first_tail_x8_r0_body.S1167.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x8_r0_body.ctheta120 : Nat → SymE := Conv.compactθ PRE_first_tail_x8_r0_body.cws120 PRE_first_tail_x8_r0_body.crs120
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x8_r0_body.wrB120 : List Nat := [2665, 2672610, 2673467, 2768797, 2769342, 2769598]

kernel_rfl PRE_first_tail_x8_r0_body.ctab120 : PRE_first_tail_x8_r0_body.S1168.tab = PRE_first_tail_x8_r0_body.S1166.tab ++ PRE_first_tail_x8_r0_body.cws120.map SymE.var
kernel_rfl PRE_first_tail_x8_r0_body.ctrace120 : PRE_first_tail_x8_r0_body.s1168.trace = PRE_first_tail_x8_r0_body.s1166.trace
kernel_rfl PRE_first_tail_x8_r0_body.cnext120 : PRE_first_tail_x8_r0_body.s1168.next = 2769629
kernel_rfl PRE_first_tail_x8_r0_body.ccounters120 : ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1168.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1168.ffi).mlx.nnext) = (20579, 17675)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x8_r0_body.cqueue120 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1167.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1168.ffi).mlx.tokens.map PRE_first_tail_x8_r0_body.kappa120.nv
kernel_rfl PRE_first_tail_x8_r0_body.ctokSupp120 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1168.ffi).mlx.tokens.all (bSN 5231) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x8_r0_body.cclean120 : Conv.cleanListB 20579 131072 (fun r => Nat.ble 82316 r) PRE_first_tail_x8_r0_body.s1168
    (PRE_first_tail_x8_r0_body.wrB120 ++ (List.range 6).map (2769623 + ·)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cbigs120 : bigsOutB 20579 131072 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1168.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK120
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x8_r0_body.cl120`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x8_r0_body.cl120 : List Nat := [2665, 2672610, 2673467, 2768797, 2769342, 2769598, 2769623, 2769624, 2769625, 2769626, 2769627, 2769628]
def PRE_first_tail_x8_r0_body.clo120 : List Nat := [20556, 20569, 20575, 20576, 20577, 20578]
def PRE_first_tail_x8_r0_body.cln120 : List Nat := [17648, 17649, 17650, 17651, 17652, 17653, 17654, 17655, 17656, 17657, 17658, 17659, 17660, 17661, 17662, 17663, 17664, 17665, 17666, 17667, 17668, 17669, 17670, 17671, 17672, 17673, 17674]
def PRE_first_tail_x8_r0_body.cli120 : List Nat := [17648, 17649, 17650, 17651, 17652, 17653, 17654, 17655, 17656, 17657, 17658, 17659, 17660, 17661, 17662, 17663, 17664, 17665, 17666, 17667, 17668, 17669, 17670, 17671, 17672, 17673, 17674]
kernel_rfl PRE_first_tail_x8_r0_body.cheap120 : PRE_first_tail_x8_r0_body.s1168.heap = Stage.setAll PRE_first_tail_x8_r0_body.s1166.heap (PRE_first_tail_x8_r0_body.cl120.filterMap fun a => (PRE_first_tail_x8_r0_body.s1168.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cnextLe120 : Nat.ble PRE_first_tail_x8_r0_body.s1166.next PRE_first_tail_x8_r0_body.s1168.next = true
kernel_rfl PRE_first_tail_x8_r0_body.ckeepP120 : Conv.keptPresentB PRE_first_tail_x8_r0_body.s1166 PRE_first_tail_x8_r0_body.s1168 PRE_first_tail_x8_r0_body.cl120 = true
kernel_rfl PRE_first_tail_x8_r0_body.csupp120 : Conv.suppListB PRE_first_tail_x8_r0_body.s1168 5231 PRE_first_tail_x8_r0_body.cl120 = true
kernel_rfl PRE_first_tail_x8_r0_body.cbound120 : Conv.boundListB PRE_first_tail_x8_r0_body.s1168 PRE_first_tail_x8_r0_body.cl120 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnodesK120 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1168.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cln120.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1168.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cobjsK120 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1168.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.objs (PRE_first_tail_x8_r0_body.clo120.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1168.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.citemsK120 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1168.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.items (PRE_first_tail_x8_r0_body.cli120.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1168.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.csst120 : Conv.sstListB 5231 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1168.ffi).mlx PRE_first_tail_x8_r0_body.cln120 PRE_first_tail_x8_r0_body.clo120 PRE_first_tail_x8_r0_body.cli120 = true

end Host.Load.Run.Tpl
end

section -- SiteCl120
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x8_r0_body.ckA120 : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1168.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.clo120.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1168.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.cbd120 : (PRE_first_tail_x8_r0_body.clo120 ++ PRE_first_tail_x8_r0_body.cln120 ++ PRE_first_tail_x8_r0_body.cli120).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.cle120 : Conv.Cnt.leB (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt) (⟨20579, 17675, 2769629, 5231⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x8_r0_body.cck120 : Conv.ncleanListB (⟨20579, 17675, 2769629, 5231⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1168.ffi).mlx PRE_first_tail_x8_r0_body.clo120 PRE_first_tail_x8_r0_body.cln120 PRE_first_tail_x8_r0_body.cli120 = true
theorem PRE_first_tail_x8_r0_body.cncl120 (h : Conv.NClean (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx) : Conv.NClean (⟨20579, 17675, 2769629, 5231⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1168.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x8_r0_body.cle120 PRE_first_tail_x8_r0_body.ckA120 PRE_first_tail_x8_r0_body.cobjsK120 PRE_first_tail_x8_r0_body.cnodesK120 PRE_first_tail_x8_r0_body.citemsK120 PRE_first_tail_x8_r0_body.cbd120 PRE_first_tail_x8_r0_body.cck120

end Host.Load.Run.Tpl
end

section -- SiteS120
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 120 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x8_r0_body.Pc120 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x8_r0_body.P120 : LoadP := PRE_first_tail_x8_r0_body.Pc120.raise 17675
kernel_rfl PRE_first_tail_x8_r0_body.craise120 : Nat.ble PRE_first_tail_x8_r0_body.Pc120.N0 17675 = true
theorem PRE_first_tail_x8_r0_body.raised120 : Host.Ts.Sim.Full.Raised PRE_first_tail_x8_r0_body.Pc120 PRE_first_tail_x8_r0_body.P120 :=
  .inr ⟨17675, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.craise120, rfl⟩
noncomputable abbrev PRE_first_tail_x8_r0_body.cx0_120 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1168.ffi)
noncomputable abbrev PRE_first_tail_x8_r0_body.cx1_120 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1167.ffi)
def PRE_first_tail_x8_r0_body.khinv120 : PTrie Nat := Stage.setAll PTrie.nil [(20602, 20576), (20580, 20577), (20603, 20578)]
def PRE_first_tail_x8_r0_body.kninv120 : PTrie Nat := Stage.setAll PTrie.nil [(17648, 17648), (17649, 17649), (17650, 17650), (17651, 17651), (17652, 17652), (17653, 17653), (17654, 17654), (17655, 17655), (17656, 17656), (17657, 17657), (17658, 17658), (17659, 17659), (17660, 17660), (17661, 17661), (17662, 17662), (17663, 17663), (17664, 17664), (17665, 17665), (17666, 17666), (17667, 17667), (17668, 17668), (17669, 17669), (17670, 17670), (17671, 17671), (17672, 17672), (17673, 17673), (17674, 17674)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x8_r0_body.cwS120 : List Nat := [20556, 20569, 20575, 20576, 20577, 20578, 20579, 20580, 20581, 20582, 20583, 20584, 20585, 20586, 20587, 20588, 20589, 20590, 20591, 20592, 20593, 20594, 20595, 20596, 20597, 20598, 20599, 20600, 20601, 20602, 20603]
def PRE_first_tail_x8_r0_body.cnS120 : List Nat := List.range' 17648 27
def PRE_first_tail_x8_r0_body.ciS120 : List Nat := [] ++ List.range' 17648 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x8_r0_body.cnh0120 : PRE_first_tail_x8_r0_body.kd120.nh0 = PRE_first_tail_x8_r0_body.cx0_120.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnh1120 : PRE_first_tail_x8_r0_body.kd120.nh1 = PRE_first_tail_x8_r0_body.cx1_120.mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.cnn0120 : PRE_first_tail_x8_r0_body.kd120.nn0 = PRE_first_tail_x8_r0_body.cx0_120.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cnn1120 : PRE_first_tail_x8_r0_body.kd120.nn1 = PRE_first_tail_x8_r0_body.cx1_120.mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.cplo120 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P120.lo && Nat.ble PRE_first_tail_x8_r0_body.P120.lo PRE_first_tail_x8_r0_body.cx0_120.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.P120.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x8_r0_body.P120.E) = true
kernel_rfl PRE_first_tail_x8_r0_body.ccnt120 : (Nat.ble PRE_first_tail_x8_r0_body.cx0_120.mlx.next PRE_first_tail_x8_r0_body.cx1_120.mlx.next && Nat.ble PRE_first_tail_x8_r0_body.cx0_120.mlx.nnext PRE_first_tail_x8_r0_body.cx1_120.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnband120 : (Nat.blt 0 PRE_first_tail_x8_r0_body.P120.NL && Nat.ble PRE_first_tail_x8_r0_body.P120.NL PRE_first_tail_x8_r0_body.P120.N0 && Nat.ble PRE_first_tail_x8_r0_body.P120.N0 PRE_first_tail_x8_r0_body.cx0_120.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.chbelow120 : PRE_first_tail_x8_r0_body.kd120.checkHndBelow = true
kernel_rfl PRE_first_tail_x8_r0_body.chren120 : checkRenG PRE_first_tail_x8_r0_body.kd120.hnd PRE_first_tail_x8_r0_body.khinv120 (phB PRE_first_tail_x8_r0_body.cx0_120.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cband120 : PRE_first_tail_x8_r0_body.kd120.checkBand PRE_first_tail_x8_r0_body.P120.lo = true
kernel_rfl PRE_first_tail_x8_r0_body.cnh1pos120 : Nat.blt 0 PRE_first_tail_x8_r0_body.kd120.nh1 = true
kernel_rfl PRE_first_tail_x8_r0_body.cnren120 : checkRenG PRE_first_tail_x8_r0_body.kd120.node PRE_first_tail_x8_r0_body.kninv120 (pnB PRE_first_tail_x8_r0_body.cx0_120.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.cnlow120 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd120.node).all (fun j => Nat.ble PRE_first_tail_x8_r0_body.P120.NL j && Nat.blt (PRE_first_tail_x8_r0_body.kd120.nodeF j) PRE_first_tail_x8_r0_body.cx1_120.mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.cabs0a120 : PRE_first_tail_x8_r0_body.cx0_120.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.cabs0b120 : PRE_first_tail_x8_r0_body.cx0_120.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x8_r0_body.ctok1120 : PRE_first_tail_x8_r0_body.cx1_120.mlx.tokens = []
kernel_rfl PRE_first_tail_x8_r0_body.cpend120 : PRE_first_tail_x8_r0_body.cx1_120.mlx.pending = PRE_first_tail_x8_r0_body.cx0_120.mlx.pending.map PRE_first_tail_x8_r0_body.kappa120.pend
kernel_rfl PRE_first_tail_x8_r0_body.cerrh120 : PRE_first_tail_x8_r0_body.cx1_120.mlx.errh = PRE_first_tail_x8_r0_body.cx0_120.mlx.errh.map PRE_first_tail_x8_r0_body.kappa120.arg
kernel_rfl PRE_first_tail_x8_r0_body.cfiles120 : PRE_first_tail_x8_r0_body.cx1_120.mlx.files = PRE_first_tail_x8_r0_body.cx0_120.mlx.files
kernel_rfl PRE_first_tail_x8_r0_body.carch120 : PRE_first_tail_x8_r0_body.cx1_120.mlx.arch = PRE_first_tail_x8_r0_body.cx0_120.mlx.arch
kernel_rfl PRE_first_tail_x8_r0_body.csizes120 : PRE_first_tail_x8_r0_body.cx1_120.mlx.deviceSizes = PRE_first_tail_x8_r0_body.cx0_120.mlx.deviceSizes
kernel_rfl PRE_first_tail_x8_r0_body.cwired120 : PRE_first_tail_x8_r0_body.cx1_120.mlx.wired = PRE_first_tail_x8_r0_body.cx0_120.mlx.wired
kernel_rfl PRE_first_tail_x8_r0_body.chost120 : PRE_first_tail_x8_r0_body.cx1_120.host = PRE_first_tail_x8_r0_body.cx0_120.host
-- the compaction map's addresses are `PRE_first_tail_x8_r0_body.kd120`'s
kernel_rfl PRE_first_tail_x8_r0_body.ckn0120 : PRE_first_tail_x8_r0_body.kd120.n0 = 2769629
kernel_rfl PRE_first_tail_x8_r0_body.ckn1120 : PRE_first_tail_x8_r0_body.kd120.n1 = 2770778
kernel_rfl PRE_first_tail_x8_r0_body.ckheap120 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd120.heap).all (fun x => Nat.ble 2769623 x) = true
kernel_rfl PRE_first_tail_x8_r0_body.ckpl120 : (List.range 6).all (fun j => decide (PRE_first_tail_x8_r0_body.kd120.heap.get (2769623 + j) = nth? PRE_first_tail_x8_r0_body.pl120 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x8_r0_body.fja120 : Nat.ble 2769623 2769623 = true
kernel_rfl PRE_first_tail_x8_r0_body.fn120 : Nat.ble 5213 5213 = true
kernel_rfl PRE_first_tail_x8_r0_body.fjaD120 : Nat.ble 2769623 PRE_first_tail_x8_r0_body.kd120.n0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxn120 : Nat.ble 20576 PRE_first_tail_x8_r0_body.kd120.nh0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fnn120 : Nat.ble 17648 PRE_first_tail_x8_r0_body.kd120.nn0 = true
kernel_rfl PRE_first_tail_x8_r0_body.fxb120 : Nat.ble 20576 RData.bigHi = true
kernel_rfl PRE_first_tail_x8_r0_body.fheap120 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd120.heap).all (Nat.ble (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x8_r0_body.fhnd120 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd120.hnd).all (Nat.ble (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnode120 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd120.node).all (Nat.ble (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x8_r0_body.cfix120 : Conv.FixOld (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.kappa120 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fja120) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fn120) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fjaD120) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxn120) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fnn120) (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fxb120) PRE_first_tail_x8_r0_body.fheap120 PRE_first_tail_x8_r0_body.fhnd120 PRE_first_tail_x8_r0_body.fnode120
kernel_rfl PRE_first_tail_x8_r0_body.fcxn120 : (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.next
kernel_rfl PRE_first_tail_x8_r0_body.fcnn120 : (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x8_r0_body.fle0120 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.next PRE_first_tail_x8_r0_body.cx0_120.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.nnext PRE_first_tail_x8_r0_body.cx0_120.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnk120 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd120.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x8_r0_body.f1A120 : PRE_first_tail_x8_r0_body.cx1_120.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.cwS120.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_120.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1O120 : PRE_first_tail_x8_r0_body.cx1_120.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.objs (PRE_first_tail_x8_r0_body.cwS120.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_120.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1N120 : PRE_first_tail_x8_r0_body.cx1_120.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.nodes (PRE_first_tail_x8_r0_body.cnS120.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_120.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.f1I120 : PRE_first_tail_x8_r0_body.cx1_120.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.items (PRE_first_tail_x8_r0_body.ciS120.filterMap fun i => (PRE_first_tail_x8_r0_body.cx1_120.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fbd120 : (PRE_first_tail_x8_r0_body.clo120 ++ PRE_first_tail_x8_r0_body.cln120 ++ PRE_first_tail_x8_r0_body.cli120 ++ PRE_first_tail_x8_r0_body.cwS120 ++ PRE_first_tail_x8_r0_body.cnS120 ++ PRE_first_tail_x8_r0_body.ciS120).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincW120 : PRE_first_tail_x8_r0_body.cwS120.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.next || PRE_first_tail_x8_r0_body.clo120.contains h) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincI120 : PRE_first_tail_x8_r0_body.ciS120.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.nnext || PRE_first_tail_x8_r0_body.cli120.contains k) = true
kernel_rfl PRE_first_tail_x8_r0_body.fincN120 : PRE_first_tail_x8_r0_body.cnS120.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x8_r0_body.flnF120 : PRE_first_tail_x8_r0_body.cln120.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x8_r0_body.fh120 : PRE_first_tail_x8_r0_body.clo120.all (handleOK PRE_first_tail_x8_r0_body.kappa120 PRE_first_tail_x8_r0_body.P120.lo PRE_first_tail_x8_r0_body.cx0_120.mlx PRE_first_tail_x8_r0_body.cx1_120.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fo120 : PRE_first_tail_x8_r0_body.clo120.map (fun h => PRE_first_tail_x8_r0_body.cx1_120.mlx.objs.get (PRE_first_tail_x8_r0_body.kappa120.handle h)) = PRE_first_tail_x8_r0_body.clo120.map (fun h => (PRE_first_tail_x8_r0_body.cx0_120.mlx.objs.get h).map PRE_first_tail_x8_r0_body.kappa120.nobj)
kernel_rfl PRE_first_tail_x8_r0_body.fok120 : PRE_first_tail_x8_r0_body.clo120.all (objOK PRE_first_tail_x8_r0_body.kappa120 PRE_first_tail_x8_r0_body.P120.NL PRE_first_tail_x8_r0_body.cx0_120.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnd120 : PRE_first_tail_x8_r0_body.cln120.all (nodeOKF PRE_first_tail_x8_r0_body.kappa120 PRE_first_tail_x8_r0_body.P120 PRE_first_tail_x8_r0_body.cx0_120.mlx PRE_first_tail_x8_r0_body.cx1_120.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fp120 : ((PRE_first_tail_x8_r0_body.cln120.filter (fullB PRE_first_tail_x8_r0_body.P120))).map (fun i => (PRE_first_tail_x8_r0_body.cx1_120.mlx.nodes.get (PRE_first_tail_x8_r0_body.kappa120.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x8_r0_body.cln120.filter (fullB PRE_first_tail_x8_r0_body.P120))).map (fun i => (PRE_first_tail_x8_r0_body.cx0_120.mlx.nodes.get i).map fun nd => PRE_first_tail_x8_r0_body.kappa120.prim nd.prim)
kernel_rfl PRE_first_tail_x8_r0_body.fnordI120 : incrB PRE_first_tail_x8_r0_body.kd120.nodeF (List.range' 17648 27) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordK120 : (PTrie.keysA PRE_first_tail_x8_r0_body.kd120.node).all (fun k => Nat.ble 17648 k && Nat.blt k 17675) = true
kernel_rfl PRE_first_tail_x8_r0_body.fnordL120 : (PRE_first_tail_x8_r0_body.cln120.filter (Nat.ble PRE_first_tail_x8_r0_body.P120.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd120.nodeF i) && (Nat.blt i 17675 || Nat.ble PRE_first_tail_x8_r0_body.kd120.nn0 i)) = true
theorem PRE_first_tail_x8_r0_body.fnord120 : (PRE_first_tail_x8_r0_body.cln120.filter (Nat.ble PRE_first_tail_x8_r0_body.P120.N0)).all (fun i => Nat.ble i (PRE_first_tail_x8_r0_body.kd120.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x8_r0_body.kd120.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x8_r0_body.kd120.nodeF j) (PRE_first_tail_x8_r0_body.kd120.nodeF i)) = true :=
  cnord_of PRE_first_tail_x8_r0_body.cnlow120 PRE_first_tail_x8_r0_body.cnn1120 PRE_first_tail_x8_r0_body.fnordI120 PRE_first_tail_x8_r0_body.fnordK120 PRE_first_tail_x8_r0_body.fnordL120
kernel_rfl PRE_first_tail_x8_r0_body.fi120 : PRE_first_tail_x8_r0_body.cli120.all (pnB PRE_first_tail_x8_r0_body.cx0_120.mlx) = true
kernel_rfl PRE_first_tail_x8_r0_body.fii120 : PRE_first_tail_x8_r0_body.cli120.all (fun k => decide (PRE_first_tail_x8_r0_body.cx1_120.mlx.items.get (PRE_first_tail_x8_r0_body.kappa120.node k) = (PRE_first_tail_x8_r0_body.cx0_120.mlx.items.get k).map PRE_first_tail_x8_r0_body.kappa120.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x8_r0_body.cfoot120 (clean : Conv.NClean (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P120.NL) (cl : SSt (· < 5231) PRE_first_tail_x8_r0_body.cx0_120.mlx) :
    Conv.MFoot PRE_first_tail_x8_r0_body.P120 5231 PRE_first_tail_x8_r0_body.kappa120 PRE_first_tail_x8_r0_body.kd120 PRE_first_tail_x8_r0_body.khinv120 PRE_first_tail_x8_r0_body.kninv120 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx PRE_first_tail_x8_r0_body.cx0_120.mlx PRE_first_tail_x8_r0_body.cx1_120.mlx (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.clo120 PRE_first_tail_x8_r0_body.cln120 PRE_first_tail_x8_r0_body.cli120 PRE_first_tail_x8_r0_body.cwS120 PRE_first_tail_x8_r0_body.cnS120 PRE_first_tail_x8_r0_body.ciS120 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x8_r0_body.cnh0120, PRE_first_tail_x8_r0_body.cnh1120, PRE_first_tail_x8_r0_body.cnn0120, PRE_first_tail_x8_r0_body.cnn1120, PRE_first_tail_x8_r0_body.cplo120, PRE_first_tail_x8_r0_body.ccnt120, PRE_first_tail_x8_r0_body.cnband120, PRE_first_tail_x8_r0_body.chbelow120, PRE_first_tail_x8_r0_body.chren120, PRE_first_tail_x8_r0_body.cband120, PRE_first_tail_x8_r0_body.cnh1pos120, PRE_first_tail_x8_r0_body.cnren120, PRE_first_tail_x8_r0_body.cnlow120, PRE_first_tail_x8_r0_body.cabs0a120, PRE_first_tail_x8_r0_body.cabs0b120, PRE_first_tail_x8_r0_body.ctok1120, PRE_first_tail_x8_r0_body.cpend120, PRE_first_tail_x8_r0_body.cerrh120, PRE_first_tail_x8_r0_body.cfiles120, PRE_first_tail_x8_r0_body.carch120, PRE_first_tail_x8_r0_body.csizes120, PRE_first_tail_x8_r0_body.cwired120, PRE_first_tail_x8_r0_body.cfix120, clean, PRE_first_tail_x8_r0_body.fcxn120, PRE_first_tail_x8_r0_body.fcnn120, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x8_r0_body.fle0120, PRE_first_tail_x8_r0_body.fnk120, PRE_first_tail_x8_r0_body.ckA120, PRE_first_tail_x8_r0_body.cobjsK120, PRE_first_tail_x8_r0_body.cnodesK120, PRE_first_tail_x8_r0_body.citemsK120, PRE_first_tail_x8_r0_body.f1A120, PRE_first_tail_x8_r0_body.f1O120, PRE_first_tail_x8_r0_body.f1N120, PRE_first_tail_x8_r0_body.f1I120, PRE_first_tail_x8_r0_body.fbd120, PRE_first_tail_x8_r0_body.fincW120, PRE_first_tail_x8_r0_body.fincI120, PRE_first_tail_x8_r0_body.fincN120, PRE_first_tail_x8_r0_body.flnF120, PRE_first_tail_x8_r0_body.fh120, PRE_first_tail_x8_r0_body.fo120, PRE_first_tail_x8_r0_body.fok120, PRE_first_tail_x8_r0_body.fnd120, PRE_first_tail_x8_r0_body.fp120, PRE_first_tail_x8_r0_body.fnord120, PRE_first_tail_x8_r0_body.fi120, PRE_first_tail_x8_r0_body.fii120⟩
theorem PRE_first_tail_x8_r0_body.cnshift120 (clean : Conv.NClean (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P120.NL) (cl : SSt (· < 5231) PRE_first_tail_x8_r0_body.cx0_120.mlx) : NShift PRE_first_tail_x8_r0_body.P120 5231 PRE_first_tail_x8_r0_body.kappa120 PRE_first_tail_x8_r0_body.cx0_120 PRE_first_tail_x8_r0_body.cx1_120 :=
  Conv.nshift_of_foot (PRE_first_tail_x8_r0_body.cfoot120 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x8_r0_body.chost120 (compact_a_eq PRE_first_tail_x8_r0_body.ckn0120 PRE_first_tail_x8_r0_body.ckn1120 PRE_first_tail_x8_r0_body.ckheap120 PRE_first_tail_x8_r0_body.ckpl120)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x8_r0_body.fxC_120 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1166.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.krC_120 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1166.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofxC_120 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1166.ffi) = some PRE_first_tail_x8_r0_body.fxC_120
kernel_rfl PRE_first_tail_x8_r0_body.okrC_120 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1166.ffi) = some PRE_first_tail_x8_r0_body.krC_120
noncomputable def PRE_first_tail_x8_r0_body.fx0_120 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1168.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr0_120 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1168.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx0_120 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1168.ffi) = some PRE_first_tail_x8_r0_body.fx0_120
kernel_rfl PRE_first_tail_x8_r0_body.okr0_120 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1168.ffi) = some PRE_first_tail_x8_r0_body.kr0_120
noncomputable def PRE_first_tail_x8_r0_body.fx1_120 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1167.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x8_r0_body.kr1_120 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1167.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x8_r0_body.ofx1_120 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x8_r0_body.s1167.ffi) = some PRE_first_tail_x8_r0_body.fx1_120
kernel_rfl PRE_first_tail_x8_r0_body.okr1_120 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x8_r0_body.s1167.ffi) = some PRE_first_tail_x8_r0_body.kr1_120
kernel_rfl PRE_first_tail_x8_r0_body.ff0120 : PRE_first_tail_x8_r0_body.fx0_120 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_120 (PRE_first_tail_x8_r0_body.clo120.filterMap fun i => (PRE_first_tail_x8_r0_body.fx0_120.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ff1120 : PRE_first_tail_x8_r0_body.fx1_120 = Stage.setAll PRE_first_tail_x8_r0_body.fxC_120 (PRE_first_tail_x8_r0_body.cwS120.filterMap fun i => (PRE_first_tail_x8_r0_body.fx1_120.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.ffck120 : freedLB PRE_first_tail_x8_r0_body.kappa120 PRE_first_tail_x8_r0_body.cx0_120.mlx PRE_first_tail_x8_r0_body.fx0_120 PRE_first_tail_x8_r0_body.fx1_120 PRE_first_tail_x8_r0_body.clo120 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkf0120 : PRE_first_tail_x8_r0_body.kr0_120.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_120.flags (PRE_first_tail_x8_r0_body.clo120.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_120.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt0120 : PRE_first_tail_x8_r0_body.kr0_120.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_120.targs (PRE_first_tail_x8_r0_body.clo120.filterMap fun i => (PRE_first_tail_x8_r0_body.kr0_120.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkf1120 : PRE_first_tail_x8_r0_body.kr1_120.flags = Stage.setAll PRE_first_tail_x8_r0_body.krC_120.flags (PRE_first_tail_x8_r0_body.cwS120.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_120.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkt1120 : PRE_first_tail_x8_r0_body.kr1_120.targs = Stage.setAll PRE_first_tail_x8_r0_body.krC_120.targs (PRE_first_tail_x8_r0_body.cwS120.filterMap fun i => (PRE_first_tail_x8_r0_body.kr1_120.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x8_r0_body.fkck120 : krecLB PRE_first_tail_x8_r0_body.kappa120 5231 PRE_first_tail_x8_r0_body.cx0_120.mlx PRE_first_tail_x8_r0_body.kr0_120 PRE_first_tail_x8_r0_body.kr1_120 PRE_first_tail_x8_r0_body.clo120 = true
kernel_rfl PRE_first_tail_x8_r0_body.fkn120 : Nat.ble 5213 5231 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x8_r0_body.cbridge120 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1167.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1168.ffi
kernel_rfl PRE_first_tail_x8_r0_body.cpendR120 : pendRegB PRE_first_tail_x8_r0_body.kappa120 (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1168.ffi).mlx = true
kernel_rfl PRE_first_tail_x8_r0_body.cpendLe120 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1168.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1167.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x8_r0_body.cshift120 (clean : Conv.NClean (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x8_r0_body.P120.NL) (cl : SSt (· < 5231) PRE_first_tail_x8_r0_body.cx0_120.mlx)
    (hobjC : ∀ h, PRE_first_tail_x8_r0_body.fxC_120.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x8_r0_body.krC_120.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x8_r0_body.krC_120.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s1166.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x8_r0_body.krC_120.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x8_r0_body.P120 5231 PRE_first_tail_x8_r0_body.kappa120 PRE_first_tail_x8_r0_body.s1168.ffi PRE_first_tail_x8_r0_body.s1167.ffi :=
  ⟨PRE_first_tail_x8_r0_body.cnshift120 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x8_r0_body.cqueue120, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x8_r0_body.ctokSupp120 t ht),
    PRE_first_tail_x8_r0_body.cbridge120,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1168.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1167.ffi) (PRE_first_tail_x8_r0_body.cfoot120 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.ofx0_120 PRE_first_tail_x8_r0_body.ofx1_120 hobjC PRE_first_tail_x8_r0_body.ff0120 PRE_first_tail_x8_r0_body.ff1120 PRE_first_tail_x8_r0_body.ffck120,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1168.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x8_r0_body.s1167.ffi) (PRE_first_tail_x8_r0_body.cfoot120 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x8_r0_body.okr0_120 PRE_first_tail_x8_r0_body.okr1_120 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.fkn120) hfC htC hclC
      PRE_first_tail_x8_r0_body.fkf0120 PRE_first_tail_x8_r0_body.fkt0120 PRE_first_tail_x8_r0_body.fkf1120 PRE_first_tail_x8_r0_body.fkt1120 PRE_first_tail_x8_r0_body.fkck120,
    pendReg_of rfl PRE_first_tail_x8_r0_body.cnh0120 PRE_first_tail_x8_r0_body.cnh1120 (Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.cpendLe120) PRE_first_tail_x8_r0_body.cpendR120⟩

end Host.Load.Run.Tpl
end

section -- st120/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_body.st120 0
host_stream_state PRE_first_tail_x8_r0_body.st120 1
host_stream_state PRE_first_tail_x8_r0_body.st120 2
host_stream_state PRE_first_tail_x8_r0_body.st120 3
host_stream_state PRE_first_tail_x8_r0_body.st120 4
host_stream_state PRE_first_tail_x8_r0_body.st120 5
end Host.Load.Run.Tpl
end

section -- Site120
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 120 of chain `PRE_first_tail_x8_r0_body`: `ssmW__g120__g121` (`recurWindow`), the call state `PRE_first_tail_x8_r0_body.s1166`, the merged state `PRE_first_tail_x8_r0_body.s1167`,
the site template `PRE_first_tail_x8_r0_body.st120` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x8_r0_body.s1168`: the merge.
The footprint's facts are in `SiteF120`, the compaction's in `SiteC120`, `SiteK120`, `SiteNa120`, `SiteNb120`. -/

kernel_rfl PRE_first_tail_x8_r0_body.iso120 : PRE_first_tail_x8_r0_body.st120.s0 = { PRE_first_tail_x8_r0_body.s1166 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x8_r0_body.rs120 : List Frame := PRE_first_tail_x8_r0_body.s1166.stack
kernel_rfl PRE_first_tail_x8_r0_body.n0_120 : PRE_first_tail_x8_r0_body.S1166.tab.length = 5213
kernel_rfl PRE_first_tail_x8_r0_body.tab0_120 : PRE_first_tail_x8_r0_body.st120.S0.tab = PRE_first_tail_x8_r0_body.S1166.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x8_r0_body.ws120 : List Nat := [2996, 2997, 2998, 2999, 3000, 3001, 3002, 3003, 3004, 3005, 3006, 3007, 3008, 3009, 3010, 3011, 3012, 3013, 3014, 3015, 3016, 3017, 3018, 3019, 3020, 3021, 3022, 3023, 3024, 3025, 3026]
kernel_rfl PRE_first_tail_x8_r0_body.fresh120 : (PRE_first_tail_x8_r0_body.S1166.tab.all fun e => PRE_first_tail_x8_r0_body.ws120.all fun v => e.noVar v) &&
    (PRE_first_tail_x8_r0_body.S1166.oracle.all fun q => PRE_first_tail_x8_r0_body.ws120.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.mergeTab120 : PRE_first_tail_x8_r0_body.S1167.tab = PRE_first_tail_x8_r0_body.S1166.tab ++ Conv.resTab PRE_first_tail_x8_r0_body.ws120
kernel_rfl PRE_first_tail_x8_r0_body.mergeLen120 : PRE_first_tail_x8_r0_body.st120.S5.tab.length - PRE_first_tail_x8_r0_body.st120.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x8_r0_body.merged120`, `merged_relB`).
kernel_rfl PRE_first_tail_x8_r0_body.mheap120 : PRE_first_tail_x8_r0_body.s1167.heap = PRE_first_tail_x8_r0_body.st120.s5.heap
kernel_rfl PRE_first_tail_x8_r0_body.mnext120 : PRE_first_tail_x8_r0_body.s1167.next = PRE_first_tail_x8_r0_body.st120.s5.next
kernel_rfl PRE_first_tail_x8_r0_body.mctl120 : PRE_first_tail_x8_r0_body.s1167.ctl = PRE_first_tail_x8_r0_body.st120.s5.ctl
kernel_rfl PRE_first_tail_x8_r0_body.mstack120 : PRE_first_tail_x8_r0_body.s1167.stack = PRE_first_tail_x8_r0_body.st120.s5.stack ++ PRE_first_tail_x8_r0_body.s1166.stack
kernel_rfl PRE_first_tail_x8_r0_body.mjobs120 : PRE_first_tail_x8_r0_body.s1167.jobs = PRE_first_tail_x8_r0_body.st120.s5.jobs
kernel_rfl PRE_first_tail_x8_r0_body.mffi120 : PRE_first_tail_x8_r0_body.s1167.ffi = PRE_first_tail_x8_r0_body.st120.s5.ffi
kernel_rfl PRE_first_tail_x8_r0_body.mtrace120 : PRE_first_tail_x8_r0_body.s1167.trace = PRE_first_tail_x8_r0_body.st120.s5.trace
kernel_rfl PRE_first_tail_x8_r0_body.mstores120 : PRE_first_tail_x8_r0_body.s1167.stores = PRE_first_tail_x8_r0_body.st120.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD120
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 120 of chain `PRE_first_tail_x8_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x8_r0_body.cderived120 : PRE_first_tail_x8_r0_body.nr120.map (fun r => nth? PRE_first_tail_x8_r0_body.st120.S5.tab r) =
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
kernel_rfl PRE_first_tail_x8_r0_body.cnrLo120 : PRE_first_tail_x8_r0_body.nr120.all (Nat.ble 5213) = true
kernel_rfl PRE_first_tail_x8_r0_body.cwsDisj120 : PRE_first_tail_x8_r0_body.cws120.all (fun c => !PRE_first_tail_x8_r0_body.ws120.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x8_r0_body.cthetaZ120 : Nat → SymE := Conv.compactθZ PRE_first_tail_x8_r0_body.cws120 PRE_first_tail_x8_r0_body.crs120 PRE_first_tail_x8_r0_body.ws120

end Host.Load.Run.Tpl
end

section -- st120/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x8_r0_body.st120`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x8_r0_body.st120.wrR : List (Nat × Nat) := [(2672610, 2672611), (2768797, 2768798), (2769342, 2769343), (2769598, 2769599)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x8_r0_body.st120.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x8_r0_body.st120.s5.heap PRE_first_tail_x8_r0_body.st120.wrR ++ freshOf PRE_first_tail_x8_r0_body.st120.s5.heap PRE_first_tail_x8_r0_body.st120.s0.next PRE_first_tail_x8_r0_body.st120.s5.next
noncomputable def PRE_first_tail_x8_r0_body.st120.wr : List Nat := PRE_first_tail_x8_r0_body.st120.wrE.map (·.1)

kernel_rfl PRE_first_tail_x8_r0_body.st120.heapFoot : PRE_first_tail_x8_r0_body.st120.s5.heap = setAll PRE_first_tail_x8_r0_body.st120.s0.heap PRE_first_tail_x8_r0_body.st120.wrE
kernel_rfl PRE_first_tail_x8_r0_body.st120.grows_check : Nat.ble PRE_first_tail_x8_r0_body.st120.s0.next PRE_first_tail_x8_r0_body.st120.s5.next = true
theorem PRE_first_tail_x8_r0_body.st120.grows : PRE_first_tail_x8_r0_body.st120.s0.next ≤ PRE_first_tail_x8_r0_body.st120.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x8_r0_body.st120.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x8_r0_body.st120.wh : List Nat := [20556, 20569, 20575, 20576, 20577, 20578, 20579, 20580, 20581, 20582, 20583, 20584, 20585, 20586, 20587, 20588, 20589, 20590, 20591, 20592, 20593, 20594, 20595, 20596, 20597, 20598, 20599, 20600, 20601, 20602, 20603]
def PRE_first_tail_x8_r0_body.st120.wi : List Nat := []

kernel_rfl PRE_first_tail_x8_r0_body.st120.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st120.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st120.s0.ffi).mlx.arrs (PRE_first_tail_x8_r0_body.st120.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st120.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st120.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st120.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st120.s0.ffi).mlx.objs (PRE_first_tail_x8_r0_body.st120.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st120.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x8_r0_body.st120.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st120.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st120.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st120.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st120.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st120.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st120.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st120.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st120.s0.ffi).mlx.items ((PRE_first_tail_x8_r0_body.st120.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st120.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st120.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st120.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st120.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x8_r0_body.st120.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st120.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st120.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st120.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.st120.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF120
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 120 of chain `PRE_first_tail_x8_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x8_r0_body.wrNodupB120 : nodupT PRE_first_tail_x8_r0_body.st120.wr PTrie.nil = true
theorem PRE_first_tail_x8_r0_body.wrNodup120 : PRE_first_tail_x8_r0_body.st120.wr.Nodup := (nodupT_sound PRE_first_tail_x8_r0_body.wrNodupB120).2
kernel_rfl PRE_first_tail_x8_r0_body.wrBoundB120 : PRE_first_tail_x8_r0_body.st120.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x8_r0_body.wrBound120 : ∀ b ∈ PRE_first_tail_x8_r0_body.st120.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wrBoundB120 b hb)
noncomputable def PRE_first_tail_x8_r0_body.trFr120 := PRE_first_tail_x8_r0_body.st120.s5.trace.take 120
kernel_rfl PRE_first_tail_x8_r0_body.traceEq120 : PRE_first_tail_x8_r0_body.st120.s5.trace = PRE_first_tail_x8_r0_body.trFr120 ++ PRE_first_tail_x8_r0_body.st120.s0.trace
theorem PRE_first_tail_x8_r0_body.trace120 : ∃ fr, PRE_first_tail_x8_r0_body.st120.s5.trace = fr ++ PRE_first_tail_x8_r0_body.st120.s0.trace := ⟨_, PRE_first_tail_x8_r0_body.traceEq120⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x8_r0_body.wide120 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x8_r0_body.wfixB120 : (PRE_first_tail_x8_r0_body.wide120.all fun p => wfixB Map.id (presentB PRE_first_tail_x8_r0_body.st120.s0) p.2) = true
theorem PRE_first_tail_x8_r0_body.wfix120 : ∀ p ∈ PRE_first_tail_x8_r0_body.wide120, WFix Map.id (Present PRE_first_tail_x8_r0_body.st120.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x8_r0_body.wfixB120 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL120
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 120 of chain `PRE_first_tail_x8_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x8_r0_body.s1167`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x8_r0_body.srvO120 : PRE_first_tail_x8_r0_body.st120.S0.oracle = PRE_first_tail_x8_r0_body.st120.OR
kernel_rfl PRE_first_tail_x8_r0_body.wr0B120 : PRE_first_tail_x8_r0_body.st120.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.st120.s0.next || (PRE_first_tail_x8_r0_body.st120.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x8_r0_body.stFoot120 : Conv.StageFoot PRE_first_tail_x8_r0_body.st120.wr PRE_first_tail_x8_r0_body.st120.s0 PRE_first_tail_x8_r0_body.st120.s5 :=
  stageFoot_of PRE_first_tail_x8_r0_body.st120.heapFoot PRE_first_tail_x8_r0_body.wrNodup120 PRE_first_tail_x8_r0_body.wrBound120 PRE_first_tail_x8_r0_body.wr0B120 PRE_first_tail_x8_r0_body.st120.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x8_r0_body.merged120 {FR : Map → Nat → PRE_first_tail_x8_r0_body.st120.F.S → PRE_first_tail_x8_r0_body.st120.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x8_r0_body.st120.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x8_r0_body.st120.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x8_r0_body.rs120 PRE_first_tail_x8_r0_body.st120.wr PRE_first_tail_x8_r0_body.s1166 PRE_first_tail_x8_r0_body.st120.s5 PRE_first_tail_x8_r0_body.st120.s0
      PRE_first_tail_x8_r0_body.st120.s5.ffi) S t C) : RelB PRE_first_tail_x8_r0_body.st120.F FR W stk M ν K PRE_first_tail_x8_r0_body.s1167 S t C :=
  merged_relB PRE_first_tail_x8_r0_body.iso120 PRE_first_tail_x8_r0_body.stFoot120 PRE_first_tail_x8_r0_body.wrNodup120 PRE_first_tail_x8_r0_body.wrBound120 PRE_first_tail_x8_r0_body.trace120 PRE_first_tail_x8_r0_body.mheap120
    PRE_first_tail_x8_r0_body.mnext120 PRE_first_tail_x8_r0_body.mctl120 PRE_first_tail_x8_r0_body.mstack120 PRE_first_tail_x8_r0_body.mjobs120 PRE_first_tail_x8_r0_body.mffi120 PRE_first_tail_x8_r0_body.mtrace120 PRE_first_tail_x8_r0_body.mstores120 h

def PRE_first_tail_x8_r0_body.arrEl120_2665 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE120_2665 : arrOf PRE_first_tail_x8_r0_body.s1167 2665 = arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl120_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrA120_2665 : isArrB PRE_first_tail_x8_r0_body.s1167 2665 = true
theorem PRE_first_tail_x8_r0_body.arr120_2665 : ∃ o, PRE_first_tail_x8_r0_body.s1167.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ PRE_first_tail_x8_r0_body.arrEl120_2665) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE120_2665 PRE_first_tail_x8_r0_body.arrA120_2665
kernel_rfl PRE_first_tail_x8_r0_body.arrN120_2665 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl120_2665 = true
theorem PRE_first_tail_x8_r0_body.arrR120_2665 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl120_2665 := numRefs_of PRE_first_tail_x8_r0_body.arrN120_2665

def PRE_first_tail_x8_r0_body.arrEl120_2673467 : List Val := []
kernel_rfl PRE_first_tail_x8_r0_body.arrE120_2673467 : arrOf PRE_first_tail_x8_r0_body.s1167 2673467 = arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl120_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrA120_2673467 : isArrB PRE_first_tail_x8_r0_body.s1167 2673467 = true
theorem PRE_first_tail_x8_r0_body.arr120_2673467 : ∃ o, PRE_first_tail_x8_r0_body.s1167.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ PRE_first_tail_x8_r0_body.arrEl120_2673467) :=
  arrExt_of PRE_first_tail_x8_r0_body.arrE120_2673467 PRE_first_tail_x8_r0_body.arrA120_2673467
kernel_rfl PRE_first_tail_x8_r0_body.arrN120_2673467 : numRefsB PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl120_2673467 = true
theorem PRE_first_tail_x8_r0_body.arrR120_2673467 : Prefill.NumRefs PRE_first_tail_x8_r0_body.S0.tab.length PRE_first_tail_x8_r0_body.arrEl120_2673467 := numRefs_of PRE_first_tail_x8_r0_body.arrN120_2673467

kernel_rfl PRE_first_tail_x8_r0_body.w4910k120 : isArrB PRE_first_tail_x8_r0_body.s1167 4910 = false
theorem PRE_first_tail_x8_r0_body.keep120 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x8_r0_body.s0 q) PRE_first_tail_x8_r0_body.s1167 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x8_r0_body.w4910k120 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x8_r0_body.arr120_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x8_r0_body.arrEl120_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ120
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 120 of chain `PRE_first_tail_x8_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x8_r0_body.s1166`, the merged
state `PRE_first_tail_x8_r0_body.s1167`, the canonical state `PRE_first_tail_x8_r0_body.s1168`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x8_r0_body.zpl120 : PRE_first_tail_x8_r0_body.pl120.all (Nat.ble PRE_first_tail_x8_r0_body.s1166.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zplnd120 : nodupT PRE_first_tail_x8_r0_body.pl120 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.zn1120 : Nat.ble PRE_first_tail_x8_r0_body.s1166.next 2770778 = true
kernel_rfl PRE_first_tail_x8_r0_body.zfirst120 : Nat.ble aFirst PRE_first_tail_x8_r0_body.s1166.next = true
kernel_rfl PRE_first_tail_x8_r0_body.zscn120 : PRE_first_tail_x8_r0_body.s1168.next = PRE_first_tail_x8_r0_body.s1166.next + PRE_first_tail_x8_r0_body.pl120.length
kernel_rfl PRE_first_tail_x8_r0_body.zsmn120 : PRE_first_tail_x8_r0_body.s1167.next = 2770778
kernel_rfl PRE_first_tail_x8_r0_body.zgrow120 : Nat.ble PRE_first_tail_x8_r0_body.s1168.next PRE_first_tail_x8_r0_body.s1167.next = true
-- the tables
kernel_rfl PRE_first_tail_x8_r0_body.zfresh120 : PRE_first_tail_x8_r0_body.S1166.tab.all (fun e => PRE_first_tail_x8_r0_body.cws120.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x8_r0_body.zcnd120 : nodupT PRE_first_tail_x8_r0_body.cws120 PTrie.nil = true
kernel_rfl PRE_first_tail_x8_r0_body.znrHi120 : PRE_first_tail_x8_r0_body.nr120.all (fun r => Nat.blt r PRE_first_tail_x8_r0_body.S1167.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x8_r0_body.zfrlt120 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x8_r0_body.s1166.next) = true
kernel_rfl PRE_first_tail_x8_r0_body.zg120_2665 : PRE_first_tail_x8_r0_body.s1168.heap.get 2665 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1168 2665))
kernel_rfl PRE_first_tail_x8_r0_body.zk120_2665 : (objOf PRE_first_tail_x8_r0_body.s1168 2665).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x8_r0_body.zm120_2665 : PRE_first_tail_x8_r0_body.s1167.heap.get 2665 = some (.obj { PRE_first_tail_x8_r0_body.kappa120.obj (objOf PRE_first_tail_x8_r0_body.s1168 2665) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x8_r0_body.s1167 2665).drop (arrOf PRE_first_tail_x8_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zg120_2673467 : PRE_first_tail_x8_r0_body.s1168.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x8_r0_body.s1168 2673467))
kernel_rfl PRE_first_tail_x8_r0_body.zk120_2673467 : (objOf PRE_first_tail_x8_r0_body.s1168 2673467).kind = .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x8_r0_body.zm120_2673467 : PRE_first_tail_x8_r0_body.s1167.heap.get 2673467 = some (.obj { PRE_first_tail_x8_r0_body.kappa120.obj (objOf PRE_first_tail_x8_r0_body.s1168 2673467) with
  kind := .array (arrOf PRE_first_tail_x8_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x8_r0_body.s1167 2673467).drop (arrOf PRE_first_tail_x8_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x8_r0_body.zw120_4910 : (PRE_first_tail_x8_r0_body.s1168.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw120_2673472 : (PRE_first_tail_x8_r0_body.s1168.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x8_r0_body.zw120_2673473 : (PRE_first_tail_x8_r0_body.s1168.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x8_r0_body.zclbd120 : PRE_first_tail_x8_r0_body.cl120.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x8_r0_body.zwr120 : PRE_first_tail_x8_r0_body.st120.wr.all (fun b => !Nat.blt b PRE_first_tail_x8_r0_body.s1166.next || PRE_first_tail_x8_r0_body.cl120.contains b) = true
def PRE_first_tail_x8_r0_body.zl120 : List Nat := PRE_first_tail_x8_r0_body.cl120.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x8_r0_body.zimgE120 : PRE_first_tail_x8_r0_body.zl120.map (fun a => PRE_first_tail_x8_r0_body.s1167.heap.get (PRE_first_tail_x8_r0_body.kappa120.a a)) = PRE_first_tail_x8_r0_body.zl120.map (fun a => (PRE_first_tail_x8_r0_body.s1168.heap.get a).map PRE_first_tail_x8_r0_body.kappa120.hobj)
theorem PRE_first_tail_x8_r0_body.zimg120 : HeapImg PRE_first_tail_x8_r0_body.kappa120 PRE_first_tail_x8_r0_body.s1168 PRE_first_tail_x8_r0_body.s1167 PRE_first_tail_x8_r0_body.zl120 := PRE_first_tail_x8_r0_body.zimgE120
-- the roots and their supports
kernel_rfl PRE_first_tail_x8_r0_body.zctl120 : PRE_first_tail_x8_r0_body.s1167.ctl = PRE_first_tail_x8_r0_body.kappa120.ctl PRE_first_tail_x8_r0_body.s1168.ctl
kernel_rfl PRE_first_tail_x8_r0_body.zstack120 : PRE_first_tail_x8_r0_body.s1167.stack = PRE_first_tail_x8_r0_body.s1168.stack.map PRE_first_tail_x8_r0_body.kappa120.frame
kernel_rfl PRE_first_tail_x8_r0_body.zjobs120 : PRE_first_tail_x8_r0_body.s1167.jobs = PRE_first_tail_x8_r0_body.s1168.jobs.map PRE_first_tail_x8_r0_body.kappa120.job
kernel_rfl PRE_first_tail_x8_r0_body.zstores120 : PRE_first_tail_x8_r0_body.s1167.stores = PRE_first_tail_x8_r0_body.kappa120.stores PRE_first_tail_x8_r0_body.s1168.stores
kernel_rfl PRE_first_tail_x8_r0_body.zroots120 : checkRootsSupp PRE_first_tail_x8_r0_body.s1168 5231 = true
kernel_rfl PRE_first_tail_x8_r0_body.znC120 : PRE_first_tail_x8_r0_body.S1166.tab.length + PRE_first_tail_x8_r0_body.cws120.length = 5231
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x8_r0_body.zkap120 : PRE_first_tail_x8_r0_body.kappa120 = Conv.Map.compact PRE_first_tail_x8_r0_body.s1166.next 2770778 PRE_first_tail_x8_r0_body.S1166.tab.length PRE_first_tail_x8_r0_body.pl120 (PRE_first_tail_x8_r0_body.nr120.map NumV.ref) PRE_first_tail_x8_r0_body.kd120.big
  PRE_first_tail_x8_r0_body.kd120.region PRE_first_tail_x8_r0_body.kd120.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x8_r0_body.zbin120 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x8_r0_body.s1168.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x8_r0_body.zjc120 : Conv.jcleanListB (⟨20579, 17675, 2769629, 5231⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1168 PRE_first_tail_x8_r0_body.cl120 = true
kernel_rfl PRE_first_tail_x8_r0_body.zrootsB120 : noBigRootsP (fun i => !Conv.oldBigB (⟨20579, 17675, 2769629, 5231⟩ : Conv.Cnt) i) PRE_first_tail_x8_r0_body.s1168.trace PRE_first_tail_x8_r0_body.s1168 = true
kernel_rfl PRE_first_tail_x8_r0_body.zhm120 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x8_r0_body.s0.ffi).mlx.nnext 17648 = true
theorem PRE_first_tail_x8_r0_body.cjcl120 (h : Conv.JClean (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1166) : Conv.JClean (⟨20579, 17675, 2769629, 5231⟩ : Conv.Cnt) PRE_first_tail_x8_r0_body.s1168 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x8_r0_body.cle120)
    (Conv.heap_off_setAll PRE_first_tail_x8_r0_body.cheap120 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x8_r0_body.zclbd120 a ha)) PRE_first_tail_x8_r0_body.zjc120

end Host.Load.Run.Tpl
end

section -- st120/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st120.bodyLast from PRE_first_tail_x8_r0_body.st120.s4 to PRE_first_tail_x8_r0_body.st120.s5 :
  interpS (step PRE_first_tail_x8_r0_body.st120.F PRE_first_tail_x8_r0_body.st120.s4).run PRE_first_tail_x8_r0_body.st120.S4 = some (PRE_first_tail_x8_r0_body.st120.s5, PRE_first_tail_x8_r0_body.st120.S5)
kernel_rfl PRE_first_tail_x8_r0_body.st120.bodyHalt : isHalt PRE_first_tail_x8_r0_body.st120.s4.ctl = false
kernel_rfl PRE_first_tail_x8_r0_body.st120.bodyTopCheck : noBlockTop PRE_first_tail_x8_r0_body.st120.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st120/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_body.st120.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st120.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x8_r0_body.st120.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x8_r0_body.st120.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x8_r0_body.st120.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x8_r0_body.st120.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x8_r0_body.st120.bodyOkLN bytes rows s c = PRE_first_tail_x8_r0_body.st120.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x8_r0_body.st120.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st120.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st120.s0 PRE_first_tail_x8_r0_body.st120.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x8_r0_body.st120.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x8_r0_body.st120.bodyOkL bytes rows PRE_first_tail_x8_r0_body.st120.s4 PRE_first_tail_x8_r0_body.st120.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st120/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st120.bodyK0F from PRE_first_tail_x8_r0_body.st120.s0 to PRE_first_tail_x8_r0_body.st120.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st120.F (PRE_first_tail_x8_r0_body.st120.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st120.ks 0).getD 0) PRE_first_tail_x8_r0_body.st120.s0 PRE_first_tail_x8_r0_body.st120.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st120.s1, PRE_first_tail_x8_r0_body.st120.S1)
theorem PRE_first_tail_x8_r0_body.st120.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st120.F (PRE_first_tail_x8_r0_body.st120.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st120.ks 0).getD 0) PRE_first_tail_x8_r0_body.st120.s0 PRE_first_tail_x8_r0_body.st120.S0) = fun _ _ => some (PRE_first_tail_x8_r0_body.st120.s1, PRE_first_tail_x8_r0_body.st120.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st120.bodyOkLN_ok PRE_first_tail_x8_r0_body.st120.bodyK0F
end Host.Load.Run.Tpl
end

section -- st120/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x8_r0_body.st120.bodyK1F from PRE_first_tail_x8_r0_body.st120.s1 to PRE_first_tail_x8_r0_body.st120.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x8_r0_body.st120.F (PRE_first_tail_x8_r0_body.st120.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st120.ks 1).getD 0) PRE_first_tail_x8_r0_body.st120.s1 PRE_first_tail_x8_r0_body.st120.S1) = fun _ _ => some (PRE_first_tail_x8_r0_body.st120.s2, PRE_first_tail_x8_r0_body.st120.S2)
theorem PRE_first_tail_x8_r0_body.st120.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x8_r0_body.st120.F (PRE_first_tail_x8_r0_body.st120.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x8_r0_body.st120.ks 1).getD 0) PRE_first_tail_x8_r0_body.st120.s1 PRE_first_tail_x8_r0_body.st120.S1) = fun _ _ => some (PRE_first_tail_x8_r0_body.st120.s2, PRE_first_tail_x8_r0_body.st120.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x8_r0_body.st120.bodyOkLN_ok PRE_first_tail_x8_r0_body.st120.bodyK1F
end Host.Load.Run.Tpl
end

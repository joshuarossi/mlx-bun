import host.sim.template.a4pre_first_tail_x6_r0_body.m.B28
import host.sim.template.BootEq
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
import host.sim.template.CallGen
import host.sim.template.EndGen
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.StageRel
import host.sim.compose.a4b.VWFramesDefs
import host.sim.template.FullOk
import host.sim.template.FastOk

section -- st142/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st142.bodyK0F from PRE_first_tail_x6_r0_body.st142.s0 to PRE_first_tail_x6_r0_body.st142.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st142.F (PRE_first_tail_x6_r0_body.st142.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st142.ks 0).getD 0) PRE_first_tail_x6_r0_body.st142.s0 PRE_first_tail_x6_r0_body.st142.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st142.s1, PRE_first_tail_x6_r0_body.st142.S1)
theorem PRE_first_tail_x6_r0_body.st142.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st142.F (PRE_first_tail_x6_r0_body.st142.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st142.ks 0).getD 0) PRE_first_tail_x6_r0_body.st142.s0 PRE_first_tail_x6_r0_body.st142.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st142.s1, PRE_first_tail_x6_r0_body.st142.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st142.bodyOkLN_ok PRE_first_tail_x6_r0_body.st142.bodyK0F
end Host.Load.Run.Tpl
end

section -- st142/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st142.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st142.F (PRE_first_tail_x6_r0_body.st142.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st142.s0 PRE_first_tail_x6_r0_body.st142.S0 = some (PRE_first_tail_x6_r0_body.st142.s1, PRE_first_tail_x6_r0_body.st142.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st142.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st142.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st142.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st142.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st142.F (PRE_first_tail_x6_r0_body.st142.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st142.s0
  S0 := PRE_first_tail_x6_r0_body.st142.S0
  s1 := PRE_first_tail_x6_r0_body.st142.s1
  S1 := PRE_first_tail_x6_r0_body.st142.S1
  s2 := PRE_first_tail_x6_r0_body.st142.s2
  S2 := PRE_first_tail_x6_r0_body.st142.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st142.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st142.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st142.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st142.bodyHalt
  last := PRE_first_tail_x6_r0_body.st142.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st142.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC143
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 143 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s1381` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa143` into the merged state
`PRE_first_tail_x6_r0_body.s1380`. -/

def PRE_first_tail_x6_r0_body.pl143 : List Nat := [2786980]
def PRE_first_tail_x6_r0_body.nr143 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd143 : RData :=
  ⟨2786962, 2786981, Stage.setAll PTrie.nil [(2786961, 2786980)], Stage.setAll PTrie.nil [],
   21013, 21013, 18103, 18103, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa143 : Map :=
  Conv.Map.compact 2786961 2786981 6166 PRE_first_tail_x6_r0_body.pl143 (PRE_first_tail_x6_r0_body.nr143.map NumV.ref) PRE_first_tail_x6_r0_body.kd143.big
    PRE_first_tail_x6_r0_body.kd143.region PRE_first_tail_x6_r0_body.kd143.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws143 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs143 : List SymE := PRE_first_tail_x6_r0_body.nr143.map fun r => (nth? PRE_first_tail_x6_r0_body.S1380.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta143 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws143 PRE_first_tail_x6_r0_body.crs143
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB143 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab143 : PRE_first_tail_x6_r0_body.S1381.tab = PRE_first_tail_x6_r0_body.S1379.tab ++ PRE_first_tail_x6_r0_body.cws143.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace143 : PRE_first_tail_x6_r0_body.s1381.trace = PRE_first_tail_x6_r0_body.s1379.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext143 : PRE_first_tail_x6_r0_body.s1381.next = 2786962
kernel_rfl PRE_first_tail_x6_r0_body.ccounters143 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1381.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1381.ffi).mlx.nnext) = (21013, 18103)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue143 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1380.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1381.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa143.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp143 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1381.ffi).mlx.tokens.all (bSN 6166) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean143 : Conv.cleanListB 21013 131072 (fun r => Nat.ble 84052 r) PRE_first_tail_x6_r0_body.s1381
    (PRE_first_tail_x6_r0_body.wrB143 ++ (List.range 1).map (2786961 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs143 : bigsOutB 21013 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1381.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK143
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl143`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl143 : List Nat := [2665, 2673467, 2786961]
def PRE_first_tail_x6_r0_body.clo143 : List Nat := []
def PRE_first_tail_x6_r0_body.cln143 : List Nat := []
def PRE_first_tail_x6_r0_body.cli143 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap143 : PRE_first_tail_x6_r0_body.s1381.heap = Stage.setAll PRE_first_tail_x6_r0_body.s1379.heap (PRE_first_tail_x6_r0_body.cl143.filterMap fun a => (PRE_first_tail_x6_r0_body.s1381.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe143 : Nat.ble PRE_first_tail_x6_r0_body.s1379.next PRE_first_tail_x6_r0_body.s1381.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP143 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s1379 PRE_first_tail_x6_r0_body.s1381 PRE_first_tail_x6_r0_body.cl143 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp143 : Conv.suppListB PRE_first_tail_x6_r0_body.s1381 6166 PRE_first_tail_x6_r0_body.cl143 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound143 : Conv.boundListB PRE_first_tail_x6_r0_body.s1381 PRE_first_tail_x6_r0_body.cl143 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK143 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1381.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln143.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1381.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK143 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1381.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo143.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1381.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK143 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1381.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli143.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1381.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst143 : Conv.sstListB 6166 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1381.ffi).mlx PRE_first_tail_x6_r0_body.cln143 PRE_first_tail_x6_r0_body.clo143 PRE_first_tail_x6_r0_body.cli143 = true

end Host.Load.Run.Tpl
end

section -- SiteCl143
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA143 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1381.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo143.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1381.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd143 : (PRE_first_tail_x6_r0_body.clo143 ++ PRE_first_tail_x6_r0_body.cln143 ++ PRE_first_tail_x6_r0_body.cli143).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle143 : Conv.Cnt.leB (⟨21013, 18103, 2786961, 6166⟩ : Conv.Cnt) (⟨21013, 18103, 2786962, 6166⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck143 : Conv.ncleanListB (⟨21013, 18103, 2786962, 6166⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1381.ffi).mlx PRE_first_tail_x6_r0_body.clo143 PRE_first_tail_x6_r0_body.cln143 PRE_first_tail_x6_r0_body.cli143 = true
theorem PRE_first_tail_x6_r0_body.cncl143 (h : Conv.NClean (⟨21013, 18103, 2786961, 6166⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx) : Conv.NClean (⟨21013, 18103, 2786962, 6166⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1381.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle143 PRE_first_tail_x6_r0_body.ckA143 PRE_first_tail_x6_r0_body.cobjsK143 PRE_first_tail_x6_r0_body.cnodesK143 PRE_first_tail_x6_r0_body.citemsK143 PRE_first_tail_x6_r0_body.cbd143 PRE_first_tail_x6_r0_body.cck143

end Host.Load.Run.Tpl
end

section -- SiteS143
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 143 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc143 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P143 : LoadP := PRE_first_tail_x6_r0_body.Pc143.raise 18103
kernel_rfl PRE_first_tail_x6_r0_body.craise143 : Nat.ble PRE_first_tail_x6_r0_body.Pc143.N0 18103 = true
theorem PRE_first_tail_x6_r0_body.raised143 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc143 PRE_first_tail_x6_r0_body.P143 :=
  .inr ⟨18103, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise143, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_143 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1381.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_143 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1380.ffi)
def PRE_first_tail_x6_r0_body.khinv143 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv143 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS143 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS143 : List Nat := List.range' 18103 0
def PRE_first_tail_x6_r0_body.ciS143 : List Nat := [] ++ List.range' 18103 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh0143 : PRE_first_tail_x6_r0_body.kd143.nh0 = PRE_first_tail_x6_r0_body.cx0_143.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh1143 : PRE_first_tail_x6_r0_body.kd143.nh1 = PRE_first_tail_x6_r0_body.cx1_143.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn0143 : PRE_first_tail_x6_r0_body.kd143.nn0 = PRE_first_tail_x6_r0_body.cx0_143.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn1143 : PRE_first_tail_x6_r0_body.kd143.nn1 = PRE_first_tail_x6_r0_body.cx1_143.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo143 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P143.lo && Nat.ble PRE_first_tail_x6_r0_body.P143.lo PRE_first_tail_x6_r0_body.cx0_143.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P143.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P143.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt143 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_143.mlx.next PRE_first_tail_x6_r0_body.cx1_143.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_143.mlx.nnext PRE_first_tail_x6_r0_body.cx1_143.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband143 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P143.NL && Nat.ble PRE_first_tail_x6_r0_body.P143.NL PRE_first_tail_x6_r0_body.P143.N0 && Nat.ble PRE_first_tail_x6_r0_body.P143.N0 PRE_first_tail_x6_r0_body.cx0_143.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow143 : PRE_first_tail_x6_r0_body.kd143.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren143 : checkRenG PRE_first_tail_x6_r0_body.kd143.hnd PRE_first_tail_x6_r0_body.khinv143 (phB PRE_first_tail_x6_r0_body.cx0_143.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband143 : PRE_first_tail_x6_r0_body.kd143.checkBand PRE_first_tail_x6_r0_body.P143.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos143 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd143.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren143 : checkRenG PRE_first_tail_x6_r0_body.kd143.node PRE_first_tail_x6_r0_body.kninv143 (pnB PRE_first_tail_x6_r0_body.cx0_143.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow143 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd143.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P143.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd143.nodeF j) PRE_first_tail_x6_r0_body.cx1_143.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a143 : PRE_first_tail_x6_r0_body.cx0_143.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b143 : PRE_first_tail_x6_r0_body.cx0_143.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok1143 : PRE_first_tail_x6_r0_body.cx1_143.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend143 : PRE_first_tail_x6_r0_body.cx1_143.mlx.pending = PRE_first_tail_x6_r0_body.cx0_143.mlx.pending.map PRE_first_tail_x6_r0_body.kappa143.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh143 : PRE_first_tail_x6_r0_body.cx1_143.mlx.errh = PRE_first_tail_x6_r0_body.cx0_143.mlx.errh.map PRE_first_tail_x6_r0_body.kappa143.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles143 : PRE_first_tail_x6_r0_body.cx1_143.mlx.files = PRE_first_tail_x6_r0_body.cx0_143.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch143 : PRE_first_tail_x6_r0_body.cx1_143.mlx.arch = PRE_first_tail_x6_r0_body.cx0_143.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes143 : PRE_first_tail_x6_r0_body.cx1_143.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_143.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired143 : PRE_first_tail_x6_r0_body.cx1_143.mlx.wired = PRE_first_tail_x6_r0_body.cx0_143.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost143 : PRE_first_tail_x6_r0_body.cx1_143.host = PRE_first_tail_x6_r0_body.cx0_143.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd143`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn0143 : PRE_first_tail_x6_r0_body.kd143.n0 = 2786962
kernel_rfl PRE_first_tail_x6_r0_body.ckn1143 : PRE_first_tail_x6_r0_body.kd143.n1 = 2786981
kernel_rfl PRE_first_tail_x6_r0_body.ckheap143 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd143.heap).all (fun x => Nat.ble 2786961 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl143 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd143.heap.get (2786961 + j) = nth? PRE_first_tail_x6_r0_body.pl143 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja143 : Nat.ble 2786961 2786961 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn143 : Nat.ble 6166 6166 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD143 : Nat.ble 2786961 PRE_first_tail_x6_r0_body.kd143.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn143 : Nat.ble 21013 PRE_first_tail_x6_r0_body.kd143.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn143 : Nat.ble 18103 PRE_first_tail_x6_r0_body.kd143.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb143 : Nat.ble 21013 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap143 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd143.heap).all (Nat.ble (⟨21013, 18103, 2786961, 6166⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd143 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd143.hnd).all (Nat.ble (⟨21013, 18103, 2786961, 6166⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode143 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd143.node).all (Nat.ble (⟨21013, 18103, 2786961, 6166⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix143 : Conv.FixOld (⟨21013, 18103, 2786961, 6166⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa143 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja143) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn143) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD143) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn143) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn143) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb143) PRE_first_tail_x6_r0_body.fheap143 PRE_first_tail_x6_r0_body.fhnd143 PRE_first_tail_x6_r0_body.fnode143
kernel_rfl PRE_first_tail_x6_r0_body.fcxn143 : (⟨21013, 18103, 2786961, 6166⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn143 : (⟨21013, 18103, 2786961, 6166⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle0143 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_143.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_143.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk143 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd143.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A143 : PRE_first_tail_x6_r0_body.cx1_143.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS143.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_143.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O143 : PRE_first_tail_x6_r0_body.cx1_143.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS143.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_143.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N143 : PRE_first_tail_x6_r0_body.cx1_143.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS143.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_143.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I143 : PRE_first_tail_x6_r0_body.cx1_143.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS143.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_143.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd143 : (PRE_first_tail_x6_r0_body.clo143 ++ PRE_first_tail_x6_r0_body.cln143 ++ PRE_first_tail_x6_r0_body.cli143 ++ PRE_first_tail_x6_r0_body.cwS143 ++ PRE_first_tail_x6_r0_body.cnS143 ++ PRE_first_tail_x6_r0_body.ciS143).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW143 : PRE_first_tail_x6_r0_body.cwS143.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo143.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI143 : PRE_first_tail_x6_r0_body.ciS143.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli143.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN143 : PRE_first_tail_x6_r0_body.cnS143.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF143 : PRE_first_tail_x6_r0_body.cln143.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh143 : PRE_first_tail_x6_r0_body.clo143.all (handleOK PRE_first_tail_x6_r0_body.kappa143 PRE_first_tail_x6_r0_body.P143.lo PRE_first_tail_x6_r0_body.cx0_143.mlx PRE_first_tail_x6_r0_body.cx1_143.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo143 : PRE_first_tail_x6_r0_body.clo143.map (fun h => PRE_first_tail_x6_r0_body.cx1_143.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa143.handle h)) = PRE_first_tail_x6_r0_body.clo143.map (fun h => (PRE_first_tail_x6_r0_body.cx0_143.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa143.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok143 : PRE_first_tail_x6_r0_body.clo143.all (objOK PRE_first_tail_x6_r0_body.kappa143 PRE_first_tail_x6_r0_body.P143.NL PRE_first_tail_x6_r0_body.cx0_143.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd143 : PRE_first_tail_x6_r0_body.cln143.all (nodeOKF PRE_first_tail_x6_r0_body.kappa143 PRE_first_tail_x6_r0_body.P143 PRE_first_tail_x6_r0_body.cx0_143.mlx PRE_first_tail_x6_r0_body.cx1_143.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp143 : ((PRE_first_tail_x6_r0_body.cln143.filter (fullB PRE_first_tail_x6_r0_body.P143))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_143.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa143.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln143.filter (fullB PRE_first_tail_x6_r0_body.P143))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_143.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa143.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI143 : incrB PRE_first_tail_x6_r0_body.kd143.nodeF (List.range' 18103 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK143 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd143.node).all (fun k => Nat.ble 18103 k && Nat.blt k 18103) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL143 : (PRE_first_tail_x6_r0_body.cln143.filter (Nat.ble PRE_first_tail_x6_r0_body.P143.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd143.nodeF i) && (Nat.blt i 18103 || Nat.ble PRE_first_tail_x6_r0_body.kd143.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord143 : (PRE_first_tail_x6_r0_body.cln143.filter (Nat.ble PRE_first_tail_x6_r0_body.P143.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd143.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd143.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd143.nodeF j) (PRE_first_tail_x6_r0_body.kd143.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow143 PRE_first_tail_x6_r0_body.cnn1143 PRE_first_tail_x6_r0_body.fnordI143 PRE_first_tail_x6_r0_body.fnordK143 PRE_first_tail_x6_r0_body.fnordL143
kernel_rfl PRE_first_tail_x6_r0_body.fi143 : PRE_first_tail_x6_r0_body.cli143.all (pnB PRE_first_tail_x6_r0_body.cx0_143.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii143 : PRE_first_tail_x6_r0_body.cli143.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_143.mlx.items.get (PRE_first_tail_x6_r0_body.kappa143.node k) = (PRE_first_tail_x6_r0_body.cx0_143.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa143.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot143 (clean : Conv.NClean (⟨21013, 18103, 2786961, 6166⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P143.NL) (cl : SSt (· < 6166) PRE_first_tail_x6_r0_body.cx0_143.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P143 6166 PRE_first_tail_x6_r0_body.kappa143 PRE_first_tail_x6_r0_body.kd143 PRE_first_tail_x6_r0_body.khinv143 PRE_first_tail_x6_r0_body.kninv143 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx PRE_first_tail_x6_r0_body.cx0_143.mlx PRE_first_tail_x6_r0_body.cx1_143.mlx (⟨21013, 18103, 2786961, 6166⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo143 PRE_first_tail_x6_r0_body.cln143 PRE_first_tail_x6_r0_body.cli143 PRE_first_tail_x6_r0_body.cwS143 PRE_first_tail_x6_r0_body.cnS143 PRE_first_tail_x6_r0_body.ciS143 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh0143, PRE_first_tail_x6_r0_body.cnh1143, PRE_first_tail_x6_r0_body.cnn0143, PRE_first_tail_x6_r0_body.cnn1143, PRE_first_tail_x6_r0_body.cplo143, PRE_first_tail_x6_r0_body.ccnt143, PRE_first_tail_x6_r0_body.cnband143, PRE_first_tail_x6_r0_body.chbelow143, PRE_first_tail_x6_r0_body.chren143, PRE_first_tail_x6_r0_body.cband143, PRE_first_tail_x6_r0_body.cnh1pos143, PRE_first_tail_x6_r0_body.cnren143, PRE_first_tail_x6_r0_body.cnlow143, PRE_first_tail_x6_r0_body.cabs0a143, PRE_first_tail_x6_r0_body.cabs0b143, PRE_first_tail_x6_r0_body.ctok1143, PRE_first_tail_x6_r0_body.cpend143, PRE_first_tail_x6_r0_body.cerrh143, PRE_first_tail_x6_r0_body.cfiles143, PRE_first_tail_x6_r0_body.carch143, PRE_first_tail_x6_r0_body.csizes143, PRE_first_tail_x6_r0_body.cwired143, PRE_first_tail_x6_r0_body.cfix143, clean, PRE_first_tail_x6_r0_body.fcxn143, PRE_first_tail_x6_r0_body.fcnn143, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle0143, PRE_first_tail_x6_r0_body.fnk143, PRE_first_tail_x6_r0_body.ckA143, PRE_first_tail_x6_r0_body.cobjsK143, PRE_first_tail_x6_r0_body.cnodesK143, PRE_first_tail_x6_r0_body.citemsK143, PRE_first_tail_x6_r0_body.f1A143, PRE_first_tail_x6_r0_body.f1O143, PRE_first_tail_x6_r0_body.f1N143, PRE_first_tail_x6_r0_body.f1I143, PRE_first_tail_x6_r0_body.fbd143, PRE_first_tail_x6_r0_body.fincW143, PRE_first_tail_x6_r0_body.fincI143, PRE_first_tail_x6_r0_body.fincN143, PRE_first_tail_x6_r0_body.flnF143, PRE_first_tail_x6_r0_body.fh143, PRE_first_tail_x6_r0_body.fo143, PRE_first_tail_x6_r0_body.fok143, PRE_first_tail_x6_r0_body.fnd143, PRE_first_tail_x6_r0_body.fp143, PRE_first_tail_x6_r0_body.fnord143, PRE_first_tail_x6_r0_body.fi143, PRE_first_tail_x6_r0_body.fii143⟩
theorem PRE_first_tail_x6_r0_body.cnshift143 (clean : Conv.NClean (⟨21013, 18103, 2786961, 6166⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P143.NL) (cl : SSt (· < 6166) PRE_first_tail_x6_r0_body.cx0_143.mlx) : NShift PRE_first_tail_x6_r0_body.P143 6166 PRE_first_tail_x6_r0_body.kappa143 PRE_first_tail_x6_r0_body.cx0_143 PRE_first_tail_x6_r0_body.cx1_143 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot143 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost143 (compact_a_eq PRE_first_tail_x6_r0_body.ckn0143 PRE_first_tail_x6_r0_body.ckn1143 PRE_first_tail_x6_r0_body.ckheap143 PRE_first_tail_x6_r0_body.ckpl143)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_143 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1379.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_143 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1379.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_143 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1379.ffi) = some PRE_first_tail_x6_r0_body.fxC_143
kernel_rfl PRE_first_tail_x6_r0_body.okrC_143 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1379.ffi) = some PRE_first_tail_x6_r0_body.krC_143
noncomputable def PRE_first_tail_x6_r0_body.fx0_143 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1381.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_143 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1381.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_143 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1381.ffi) = some PRE_first_tail_x6_r0_body.fx0_143
kernel_rfl PRE_first_tail_x6_r0_body.okr0_143 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1381.ffi) = some PRE_first_tail_x6_r0_body.kr0_143
noncomputable def PRE_first_tail_x6_r0_body.fx1_143 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1380.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_143 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1380.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_143 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1380.ffi) = some PRE_first_tail_x6_r0_body.fx1_143
kernel_rfl PRE_first_tail_x6_r0_body.okr1_143 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1380.ffi) = some PRE_first_tail_x6_r0_body.kr1_143
kernel_rfl PRE_first_tail_x6_r0_body.ff0143 : PRE_first_tail_x6_r0_body.fx0_143 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_143 (PRE_first_tail_x6_r0_body.clo143.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_143.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff1143 : PRE_first_tail_x6_r0_body.fx1_143 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_143 (PRE_first_tail_x6_r0_body.cwS143.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_143.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck143 : freedLB PRE_first_tail_x6_r0_body.kappa143 PRE_first_tail_x6_r0_body.cx0_143.mlx PRE_first_tail_x6_r0_body.fx0_143 PRE_first_tail_x6_r0_body.fx1_143 PRE_first_tail_x6_r0_body.clo143 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf0143 : PRE_first_tail_x6_r0_body.kr0_143.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_143.flags (PRE_first_tail_x6_r0_body.clo143.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_143.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt0143 : PRE_first_tail_x6_r0_body.kr0_143.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_143.targs (PRE_first_tail_x6_r0_body.clo143.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_143.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf1143 : PRE_first_tail_x6_r0_body.kr1_143.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_143.flags (PRE_first_tail_x6_r0_body.cwS143.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_143.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt1143 : PRE_first_tail_x6_r0_body.kr1_143.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_143.targs (PRE_first_tail_x6_r0_body.cwS143.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_143.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck143 : krecLB PRE_first_tail_x6_r0_body.kappa143 6166 PRE_first_tail_x6_r0_body.cx0_143.mlx PRE_first_tail_x6_r0_body.kr0_143 PRE_first_tail_x6_r0_body.kr1_143 PRE_first_tail_x6_r0_body.clo143 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn143 : Nat.ble 6166 6166 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge143 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1380.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1381.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR143 : pendRegB PRE_first_tail_x6_r0_body.kappa143 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1381.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe143 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1381.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1380.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift143 (clean : Conv.NClean (⟨21013, 18103, 2786961, 6166⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P143.NL) (cl : SSt (· < 6166) PRE_first_tail_x6_r0_body.cx0_143.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_143.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_143.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_143.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1379.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_143.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21013, 18103, 2786961, 6166⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P143 6166 PRE_first_tail_x6_r0_body.kappa143 PRE_first_tail_x6_r0_body.s1381.ffi PRE_first_tail_x6_r0_body.s1380.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift143 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue143, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp143 t ht),
    PRE_first_tail_x6_r0_body.cbridge143,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1381.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1380.ffi) (PRE_first_tail_x6_r0_body.cfoot143 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_143 PRE_first_tail_x6_r0_body.ofx1_143 hobjC PRE_first_tail_x6_r0_body.ff0143 PRE_first_tail_x6_r0_body.ff1143 PRE_first_tail_x6_r0_body.ffck143,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1381.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1380.ffi) (PRE_first_tail_x6_r0_body.cfoot143 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_143 PRE_first_tail_x6_r0_body.okr1_143 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn143) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf0143 PRE_first_tail_x6_r0_body.fkt0143 PRE_first_tail_x6_r0_body.fkf1143 PRE_first_tail_x6_r0_body.fkt1143 PRE_first_tail_x6_r0_body.fkck143,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh0143 PRE_first_tail_x6_r0_body.cnh1143 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe143) PRE_first_tail_x6_r0_body.cpendR143⟩

end Host.Load.Run.Tpl
end

section -- st143/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st143 0
host_stream_state PRE_first_tail_x6_r0_body.st143 1
host_stream_state PRE_first_tail_x6_r0_body.st143 2
end Host.Load.Run.Tpl
end

section -- Site143
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 143 of chain `PRE_first_tail_x6_r0_body`: `plan__g143__g144` (`plan`), the call state `PRE_first_tail_x6_r0_body.s1379`, the merged state `PRE_first_tail_x6_r0_body.s1380`,
the site template `PRE_first_tail_x6_r0_body.st143` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s1381`: the merge.
The footprint's facts are in `SiteF143`, the compaction's in `SiteC143`, `SiteK143`, `SiteNa143`, `SiteNb143`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso143 : PRE_first_tail_x6_r0_body.st143.s0 = { PRE_first_tail_x6_r0_body.s1379 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs143 : List Frame := PRE_first_tail_x6_r0_body.s1379.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_143 : PRE_first_tail_x6_r0_body.S1379.tab.length = 6166
kernel_rfl PRE_first_tail_x6_r0_body.tab0_143 : PRE_first_tail_x6_r0_body.st143.S0.tab = PRE_first_tail_x6_r0_body.S1379.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws143 : List Nat := [3391, 3392, 3393, 3394, 3395, 3396, 3397, 3398, 3399]
kernel_rfl PRE_first_tail_x6_r0_body.fresh143 : (PRE_first_tail_x6_r0_body.S1379.tab.all fun e => PRE_first_tail_x6_r0_body.ws143.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S1379.oracle.all fun q => PRE_first_tail_x6_r0_body.ws143.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab143 : PRE_first_tail_x6_r0_body.S1380.tab = PRE_first_tail_x6_r0_body.S1379.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws143
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen143 : PRE_first_tail_x6_r0_body.st143.S2.tab.length - PRE_first_tail_x6_r0_body.st143.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged143`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap143 : PRE_first_tail_x6_r0_body.s1380.heap = PRE_first_tail_x6_r0_body.st143.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext143 : PRE_first_tail_x6_r0_body.s1380.next = PRE_first_tail_x6_r0_body.st143.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl143 : PRE_first_tail_x6_r0_body.s1380.ctl = PRE_first_tail_x6_r0_body.st143.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack143 : PRE_first_tail_x6_r0_body.s1380.stack = PRE_first_tail_x6_r0_body.st143.s2.stack ++ PRE_first_tail_x6_r0_body.s1379.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs143 : PRE_first_tail_x6_r0_body.s1380.jobs = PRE_first_tail_x6_r0_body.st143.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi143 : PRE_first_tail_x6_r0_body.s1380.ffi = PRE_first_tail_x6_r0_body.st143.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace143 : PRE_first_tail_x6_r0_body.s1380.trace = PRE_first_tail_x6_r0_body.st143.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores143 : PRE_first_tail_x6_r0_body.s1380.stores = PRE_first_tail_x6_r0_body.st143.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD143
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 143 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived143 : PRE_first_tail_x6_r0_body.nr143.map (fun r => nth? PRE_first_tail_x6_r0_body.st143.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo143 : PRE_first_tail_x6_r0_body.nr143.all (Nat.ble 6166) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj143 : PRE_first_tail_x6_r0_body.cws143.all (fun c => !PRE_first_tail_x6_r0_body.ws143.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ143 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws143 PRE_first_tail_x6_r0_body.crs143 PRE_first_tail_x6_r0_body.ws143

end Host.Load.Run.Tpl
end

section -- st143/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st143`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st143.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st143.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st143.s2.heap PRE_first_tail_x6_r0_body.st143.wrR ++ freshOf PRE_first_tail_x6_r0_body.st143.s2.heap PRE_first_tail_x6_r0_body.st143.s0.next PRE_first_tail_x6_r0_body.st143.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st143.wr : List Nat := PRE_first_tail_x6_r0_body.st143.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st143.heapFoot : PRE_first_tail_x6_r0_body.st143.s2.heap = setAll PRE_first_tail_x6_r0_body.st143.s0.heap PRE_first_tail_x6_r0_body.st143.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st143.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st143.s0.next PRE_first_tail_x6_r0_body.st143.s2.next = true
theorem PRE_first_tail_x6_r0_body.st143.grows : PRE_first_tail_x6_r0_body.st143.s0.next ≤ PRE_first_tail_x6_r0_body.st143.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st143.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st143.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st143.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st143.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st143.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st143.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st143.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st143.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st143.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st143.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st143.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st143.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st143.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st143.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st143.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st143.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st143.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st143.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st143.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st143.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st143.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st143.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st143.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st143.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st143.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st143.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st143.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st143.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st143.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st143.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st143.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st143.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF143
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 143 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB143 : nodupT PRE_first_tail_x6_r0_body.st143.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup143 : PRE_first_tail_x6_r0_body.st143.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB143).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB143 : PRE_first_tail_x6_r0_body.st143.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound143 : ∀ b ∈ PRE_first_tail_x6_r0_body.st143.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB143 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr143 := PRE_first_tail_x6_r0_body.st143.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq143 : PRE_first_tail_x6_r0_body.st143.s2.trace = PRE_first_tail_x6_r0_body.trFr143 ++ PRE_first_tail_x6_r0_body.st143.s0.trace
theorem PRE_first_tail_x6_r0_body.trace143 : ∃ fr, PRE_first_tail_x6_r0_body.st143.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st143.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq143⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide143 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB143 : (PRE_first_tail_x6_r0_body.wide143.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st143.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix143 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide143, WFix Map.id (Present PRE_first_tail_x6_r0_body.st143.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB143 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL143
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 143 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s1380`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO143 : PRE_first_tail_x6_r0_body.st143.S0.oracle = PRE_first_tail_x6_r0_body.st143.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B143 : PRE_first_tail_x6_r0_body.st143.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st143.s0.next || (PRE_first_tail_x6_r0_body.st143.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot143 : Conv.StageFoot PRE_first_tail_x6_r0_body.st143.wr PRE_first_tail_x6_r0_body.st143.s0 PRE_first_tail_x6_r0_body.st143.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st143.heapFoot PRE_first_tail_x6_r0_body.wrNodup143 PRE_first_tail_x6_r0_body.wrBound143 PRE_first_tail_x6_r0_body.wr0B143 PRE_first_tail_x6_r0_body.st143.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged143 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st143.F.S → PRE_first_tail_x6_r0_body.st143.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st143.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st143.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs143 PRE_first_tail_x6_r0_body.st143.wr PRE_first_tail_x6_r0_body.s1379 PRE_first_tail_x6_r0_body.st143.s2 PRE_first_tail_x6_r0_body.st143.s0
      PRE_first_tail_x6_r0_body.st143.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st143.F FR W stk M ν K PRE_first_tail_x6_r0_body.s1380 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso143 PRE_first_tail_x6_r0_body.stFoot143 PRE_first_tail_x6_r0_body.wrNodup143 PRE_first_tail_x6_r0_body.wrBound143 PRE_first_tail_x6_r0_body.trace143 PRE_first_tail_x6_r0_body.mheap143
    PRE_first_tail_x6_r0_body.mnext143 PRE_first_tail_x6_r0_body.mctl143 PRE_first_tail_x6_r0_body.mstack143 PRE_first_tail_x6_r0_body.mjobs143 PRE_first_tail_x6_r0_body.mffi143 PRE_first_tail_x6_r0_body.mtrace143 PRE_first_tail_x6_r0_body.mstores143 h

def PRE_first_tail_x6_r0_body.arrEl143_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE143_2665 : arrOf PRE_first_tail_x6_r0_body.s1380 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl143_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA143_2665 : isArrB PRE_first_tail_x6_r0_body.s1380 2665 = true
theorem PRE_first_tail_x6_r0_body.arr143_2665 : ∃ o, PRE_first_tail_x6_r0_body.s1380.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl143_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE143_2665 PRE_first_tail_x6_r0_body.arrA143_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN143_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl143_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR143_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl143_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN143_2665

def PRE_first_tail_x6_r0_body.arrEl143_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE143_2673467 : arrOf PRE_first_tail_x6_r0_body.s1380 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl143_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA143_2673467 : isArrB PRE_first_tail_x6_r0_body.s1380 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr143_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s1380.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl143_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE143_2673467 PRE_first_tail_x6_r0_body.arrA143_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN143_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl143_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR143_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl143_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN143_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k143 : isArrB PRE_first_tail_x6_r0_body.s1380 4910 = false
theorem PRE_first_tail_x6_r0_body.keep143 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s1380 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k143 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr143_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl143_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ143
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 143 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s1379`, the merged
state `PRE_first_tail_x6_r0_body.s1380`, the canonical state `PRE_first_tail_x6_r0_body.s1381`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl143 : PRE_first_tail_x6_r0_body.pl143.all (Nat.ble PRE_first_tail_x6_r0_body.s1379.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd143 : nodupT PRE_first_tail_x6_r0_body.pl143 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn1143 : Nat.ble PRE_first_tail_x6_r0_body.s1379.next 2786981 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst143 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s1379.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn143 : PRE_first_tail_x6_r0_body.s1381.next = PRE_first_tail_x6_r0_body.s1379.next + PRE_first_tail_x6_r0_body.pl143.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn143 : PRE_first_tail_x6_r0_body.s1380.next = 2786981
kernel_rfl PRE_first_tail_x6_r0_body.zgrow143 : Nat.ble PRE_first_tail_x6_r0_body.s1381.next PRE_first_tail_x6_r0_body.s1380.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh143 : PRE_first_tail_x6_r0_body.S1379.tab.all (fun e => PRE_first_tail_x6_r0_body.cws143.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd143 : nodupT PRE_first_tail_x6_r0_body.cws143 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi143 : PRE_first_tail_x6_r0_body.nr143.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S1380.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt143 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s1379.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg143_2665 : PRE_first_tail_x6_r0_body.s1381.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1381 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk143_2665 : (objOf PRE_first_tail_x6_r0_body.s1381 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm143_2665 : PRE_first_tail_x6_r0_body.s1380.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa143.obj (objOf PRE_first_tail_x6_r0_body.s1381 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s1380 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg143_2673467 : PRE_first_tail_x6_r0_body.s1381.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1381 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk143_2673467 : (objOf PRE_first_tail_x6_r0_body.s1381 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm143_2673467 : PRE_first_tail_x6_r0_body.s1380.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa143.obj (objOf PRE_first_tail_x6_r0_body.s1381 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s1380 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw143_4910 : (PRE_first_tail_x6_r0_body.s1381.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw143_2673472 : (PRE_first_tail_x6_r0_body.s1381.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw143_2673473 : (PRE_first_tail_x6_r0_body.s1381.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd143 : PRE_first_tail_x6_r0_body.cl143.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr143 : PRE_first_tail_x6_r0_body.st143.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s1379.next || PRE_first_tail_x6_r0_body.cl143.contains b) = true
def PRE_first_tail_x6_r0_body.zl143 : List Nat := PRE_first_tail_x6_r0_body.cl143.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE143 : PRE_first_tail_x6_r0_body.zl143.map (fun a => PRE_first_tail_x6_r0_body.s1380.heap.get (PRE_first_tail_x6_r0_body.kappa143.a a)) = PRE_first_tail_x6_r0_body.zl143.map (fun a => (PRE_first_tail_x6_r0_body.s1381.heap.get a).map PRE_first_tail_x6_r0_body.kappa143.hobj)
theorem PRE_first_tail_x6_r0_body.zimg143 : HeapImg PRE_first_tail_x6_r0_body.kappa143 PRE_first_tail_x6_r0_body.s1381 PRE_first_tail_x6_r0_body.s1380 PRE_first_tail_x6_r0_body.zl143 := PRE_first_tail_x6_r0_body.zimgE143
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl143 : PRE_first_tail_x6_r0_body.s1380.ctl = PRE_first_tail_x6_r0_body.kappa143.ctl PRE_first_tail_x6_r0_body.s1381.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack143 : PRE_first_tail_x6_r0_body.s1380.stack = PRE_first_tail_x6_r0_body.s1381.stack.map PRE_first_tail_x6_r0_body.kappa143.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs143 : PRE_first_tail_x6_r0_body.s1380.jobs = PRE_first_tail_x6_r0_body.s1381.jobs.map PRE_first_tail_x6_r0_body.kappa143.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores143 : PRE_first_tail_x6_r0_body.s1380.stores = PRE_first_tail_x6_r0_body.kappa143.stores PRE_first_tail_x6_r0_body.s1381.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots143 : checkRootsSupp PRE_first_tail_x6_r0_body.s1381 6166 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC143 : PRE_first_tail_x6_r0_body.S1379.tab.length + PRE_first_tail_x6_r0_body.cws143.length = 6166
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap143 : PRE_first_tail_x6_r0_body.kappa143 = Conv.Map.compact PRE_first_tail_x6_r0_body.s1379.next 2786981 PRE_first_tail_x6_r0_body.S1379.tab.length PRE_first_tail_x6_r0_body.pl143 (PRE_first_tail_x6_r0_body.nr143.map NumV.ref) PRE_first_tail_x6_r0_body.kd143.big
  PRE_first_tail_x6_r0_body.kd143.region PRE_first_tail_x6_r0_body.kd143.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin143 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1381.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc143 : Conv.jcleanListB (⟨21013, 18103, 2786962, 6166⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1381 PRE_first_tail_x6_r0_body.cl143 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB143 : noBigRootsP (fun i => !Conv.oldBigB (⟨21013, 18103, 2786962, 6166⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s1381.trace PRE_first_tail_x6_r0_body.s1381 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm143 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 18103 = true
theorem PRE_first_tail_x6_r0_body.cjcl143 (h : Conv.JClean (⟨21013, 18103, 2786961, 6166⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1379) : Conv.JClean (⟨21013, 18103, 2786962, 6166⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1381 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle143)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap143 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd143 a ha)) PRE_first_tail_x6_r0_body.zjc143

end Host.Load.Run.Tpl
end

section -- st143/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st143.bodyLast from PRE_first_tail_x6_r0_body.st143.s1 to PRE_first_tail_x6_r0_body.st143.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st143.F PRE_first_tail_x6_r0_body.st143.s1).run PRE_first_tail_x6_r0_body.st143.S1 = some (PRE_first_tail_x6_r0_body.st143.s2, PRE_first_tail_x6_r0_body.st143.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st143.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st143.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st143.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st143.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st143/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st143.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st143.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st143.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st143.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st143.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st143.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st143.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st143.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st143.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st143.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st143.s0 PRE_first_tail_x6_r0_body.st143.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st143.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st143.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st143.s1 PRE_first_tail_x6_r0_body.st143.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st143/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st143.bodyK0F from PRE_first_tail_x6_r0_body.st143.s0 to PRE_first_tail_x6_r0_body.st143.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st143.F (PRE_first_tail_x6_r0_body.st143.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st143.ks 0).getD 0) PRE_first_tail_x6_r0_body.st143.s0 PRE_first_tail_x6_r0_body.st143.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st143.s1, PRE_first_tail_x6_r0_body.st143.S1)
theorem PRE_first_tail_x6_r0_body.st143.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st143.F (PRE_first_tail_x6_r0_body.st143.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st143.ks 0).getD 0) PRE_first_tail_x6_r0_body.st143.s0 PRE_first_tail_x6_r0_body.st143.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st143.s1, PRE_first_tail_x6_r0_body.st143.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st143.bodyOkLN_ok PRE_first_tail_x6_r0_body.st143.bodyK0F
end Host.Load.Run.Tpl
end

section -- st143/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st143.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st143.F (PRE_first_tail_x6_r0_body.st143.bodyOkL bytes rows) 206 PRE_first_tail_x6_r0_body.st143.s0 PRE_first_tail_x6_r0_body.st143.S0 = some (PRE_first_tail_x6_r0_body.st143.s1, PRE_first_tail_x6_r0_body.st143.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st143.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st143.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st143.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st143.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st143.F (PRE_first_tail_x6_r0_body.st143.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st143.s0
  S0 := PRE_first_tail_x6_r0_body.st143.S0
  s1 := PRE_first_tail_x6_r0_body.st143.s1
  S1 := PRE_first_tail_x6_r0_body.st143.S1
  s2 := PRE_first_tail_x6_r0_body.st143.s2
  S2 := PRE_first_tail_x6_r0_body.st143.S2
  n := 206
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st143.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st143.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st143.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st143.bodyHalt
  last := PRE_first_tail_x6_r0_body.st143.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st143.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC144
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 144 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s1398` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa144` into the merged state
`PRE_first_tail_x6_r0_body.s1397`. -/

def PRE_first_tail_x6_r0_body.pl144 : List Nat := [2789571, 2788746, 2789577, 2789573, 2788748, 2789579]
def PRE_first_tail_x6_r0_body.nr144 : List Nat := [6269, 6268, 6244, 6252, 6257, 6262, 6267, 6241, 6242, 6243, 6250, 6251, 6239, 6246, 6247, 6248, 6249, 6245]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd144 : RData :=
  ⟨2788465, 2789614, Stage.setAll PTrie.nil [(2788459, 2789571), (2788460, 2788746), (2788461, 2789577), (2788462, 2789573), (2788463, 2788748), (2788464, 2789579)], Stage.setAll PTrie.nil [(21048, 21074), (21049, 21052), (21050, 21075)],
   21051, 21076, 18149, 18149, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(6239, .ref 6269), (6240, .ref 6268), (6241, .ref 6244), (6242, .ref 6252), (6243, .ref 6257), (6244, .ref 6262), (6245, .ref 6267), (6246, .ref 6241), (6247, .ref 6242), (6248, .ref 6243), (6249, .ref 6250), (6250, .ref 6251), (6251, .ref 6239), (6252, .ref 6246), (6253, .ref 6247), (6254, .ref 6248), (6255, .ref 6249), (6256, .ref 6245)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa144 : Map :=
  Conv.Map.compact 2788459 2789614 6239 PRE_first_tail_x6_r0_body.pl144 (PRE_first_tail_x6_r0_body.nr144.map NumV.ref) PRE_first_tail_x6_r0_body.kd144.big
    PRE_first_tail_x6_r0_body.kd144.region PRE_first_tail_x6_r0_body.kd144.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws144 : List Nat := [3431, 3432, 3433, 3434, 3435, 3436, 3437, 3438, 3439, 3440, 3441, 3442, 3443, 3444, 3445, 3446, 3447, 3448]
noncomputable def PRE_first_tail_x6_r0_body.crs144 : List SymE := PRE_first_tail_x6_r0_body.nr144.map fun r => (nth? PRE_first_tail_x6_r0_body.S1397.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta144 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws144 PRE_first_tail_x6_r0_body.crs144
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB144 : List Nat := [2665, 2672672, 2673467, 2787633, 2788178, 2788434]

kernel_rfl PRE_first_tail_x6_r0_body.ctab144 : PRE_first_tail_x6_r0_body.S1398.tab = PRE_first_tail_x6_r0_body.S1396.tab ++ PRE_first_tail_x6_r0_body.cws144.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace144 : PRE_first_tail_x6_r0_body.s1398.trace = PRE_first_tail_x6_r0_body.s1396.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext144 : PRE_first_tail_x6_r0_body.s1398.next = 2788465
kernel_rfl PRE_first_tail_x6_r0_body.ccounters144 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1398.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1398.ffi).mlx.nnext) = (21051, 18149)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue144 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1397.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1398.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa144.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp144 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1398.ffi).mlx.tokens.all (bSN 6257) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean144 : Conv.cleanListB 21051 131072 (fun r => Nat.ble 84204 r) PRE_first_tail_x6_r0_body.s1398
    (PRE_first_tail_x6_r0_body.wrB144 ++ (List.range 6).map (2788459 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs144 : bigsOutB 21051 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1398.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK144
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl144`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl144 : List Nat := [2665, 2672672, 2673467, 2787633, 2788178, 2788434, 2788459, 2788460, 2788461, 2788462, 2788463, 2788464]
def PRE_first_tail_x6_r0_body.clo144 : List Nat := [21028, 21041, 21047, 21048, 21049, 21050]
def PRE_first_tail_x6_r0_body.cln144 : List Nat := [18122, 18123, 18124, 18125, 18126, 18127, 18128, 18129, 18130, 18131, 18132, 18133, 18134, 18135, 18136, 18137, 18138, 18139, 18140, 18141, 18142, 18143, 18144, 18145, 18146, 18147, 18148]
def PRE_first_tail_x6_r0_body.cli144 : List Nat := [18122, 18123, 18124, 18125, 18126, 18127, 18128, 18129, 18130, 18131, 18132, 18133, 18134, 18135, 18136, 18137, 18138, 18139, 18140, 18141, 18142, 18143, 18144, 18145, 18146, 18147, 18148]
kernel_rfl PRE_first_tail_x6_r0_body.cheap144 : PRE_first_tail_x6_r0_body.s1398.heap = Stage.setAll PRE_first_tail_x6_r0_body.s1396.heap (PRE_first_tail_x6_r0_body.cl144.filterMap fun a => (PRE_first_tail_x6_r0_body.s1398.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe144 : Nat.ble PRE_first_tail_x6_r0_body.s1396.next PRE_first_tail_x6_r0_body.s1398.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP144 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s1396 PRE_first_tail_x6_r0_body.s1398 PRE_first_tail_x6_r0_body.cl144 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp144 : Conv.suppListB PRE_first_tail_x6_r0_body.s1398 6257 PRE_first_tail_x6_r0_body.cl144 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound144 : Conv.boundListB PRE_first_tail_x6_r0_body.s1398 PRE_first_tail_x6_r0_body.cl144 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK144 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1398.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln144.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1398.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK144 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1398.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo144.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1398.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK144 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1398.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli144.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1398.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst144 : Conv.sstListB 6257 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1398.ffi).mlx PRE_first_tail_x6_r0_body.cln144 PRE_first_tail_x6_r0_body.clo144 PRE_first_tail_x6_r0_body.cli144 = true

end Host.Load.Run.Tpl
end

section -- SiteCl144
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA144 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1398.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo144.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1398.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd144 : (PRE_first_tail_x6_r0_body.clo144 ++ PRE_first_tail_x6_r0_body.cln144 ++ PRE_first_tail_x6_r0_body.cli144).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle144 : Conv.Cnt.leB (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt) (⟨21051, 18149, 2788465, 6257⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck144 : Conv.ncleanListB (⟨21051, 18149, 2788465, 6257⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1398.ffi).mlx PRE_first_tail_x6_r0_body.clo144 PRE_first_tail_x6_r0_body.cln144 PRE_first_tail_x6_r0_body.cli144 = true
theorem PRE_first_tail_x6_r0_body.cncl144 (h : Conv.NClean (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx) : Conv.NClean (⟨21051, 18149, 2788465, 6257⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1398.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle144 PRE_first_tail_x6_r0_body.ckA144 PRE_first_tail_x6_r0_body.cobjsK144 PRE_first_tail_x6_r0_body.cnodesK144 PRE_first_tail_x6_r0_body.citemsK144 PRE_first_tail_x6_r0_body.cbd144 PRE_first_tail_x6_r0_body.cck144

end Host.Load.Run.Tpl
end

section -- SiteS144
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 144 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc144 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P144 : LoadP := PRE_first_tail_x6_r0_body.Pc144.raise 18149
kernel_rfl PRE_first_tail_x6_r0_body.craise144 : Nat.ble PRE_first_tail_x6_r0_body.Pc144.N0 18149 = true
theorem PRE_first_tail_x6_r0_body.raised144 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc144 PRE_first_tail_x6_r0_body.P144 :=
  .inr ⟨18149, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise144, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_144 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1398.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_144 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1397.ffi)
def PRE_first_tail_x6_r0_body.khinv144 : PTrie Nat := Stage.setAll PTrie.nil [(21074, 21048), (21052, 21049), (21075, 21050)]
def PRE_first_tail_x6_r0_body.kninv144 : PTrie Nat := Stage.setAll PTrie.nil [(18122, 18122), (18123, 18123), (18124, 18124), (18125, 18125), (18126, 18126), (18127, 18127), (18128, 18128), (18129, 18129), (18130, 18130), (18131, 18131), (18132, 18132), (18133, 18133), (18134, 18134), (18135, 18135), (18136, 18136), (18137, 18137), (18138, 18138), (18139, 18139), (18140, 18140), (18141, 18141), (18142, 18142), (18143, 18143), (18144, 18144), (18145, 18145), (18146, 18146), (18147, 18147), (18148, 18148)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS144 : List Nat := [21028, 21041, 21047, 21048, 21049, 21050, 21051, 21052, 21053, 21054, 21055, 21056, 21057, 21058, 21059, 21060, 21061, 21062, 21063, 21064, 21065, 21066, 21067, 21068, 21069, 21070, 21071, 21072, 21073, 21074, 21075]
def PRE_first_tail_x6_r0_body.cnS144 : List Nat := List.range' 18122 27
def PRE_first_tail_x6_r0_body.ciS144 : List Nat := [] ++ List.range' 18122 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh0144 : PRE_first_tail_x6_r0_body.kd144.nh0 = PRE_first_tail_x6_r0_body.cx0_144.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh1144 : PRE_first_tail_x6_r0_body.kd144.nh1 = PRE_first_tail_x6_r0_body.cx1_144.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn0144 : PRE_first_tail_x6_r0_body.kd144.nn0 = PRE_first_tail_x6_r0_body.cx0_144.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn1144 : PRE_first_tail_x6_r0_body.kd144.nn1 = PRE_first_tail_x6_r0_body.cx1_144.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo144 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P144.lo && Nat.ble PRE_first_tail_x6_r0_body.P144.lo PRE_first_tail_x6_r0_body.cx0_144.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P144.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P144.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt144 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_144.mlx.next PRE_first_tail_x6_r0_body.cx1_144.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_144.mlx.nnext PRE_first_tail_x6_r0_body.cx1_144.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband144 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P144.NL && Nat.ble PRE_first_tail_x6_r0_body.P144.NL PRE_first_tail_x6_r0_body.P144.N0 && Nat.ble PRE_first_tail_x6_r0_body.P144.N0 PRE_first_tail_x6_r0_body.cx0_144.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow144 : PRE_first_tail_x6_r0_body.kd144.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren144 : checkRenG PRE_first_tail_x6_r0_body.kd144.hnd PRE_first_tail_x6_r0_body.khinv144 (phB PRE_first_tail_x6_r0_body.cx0_144.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband144 : PRE_first_tail_x6_r0_body.kd144.checkBand PRE_first_tail_x6_r0_body.P144.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos144 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd144.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren144 : checkRenG PRE_first_tail_x6_r0_body.kd144.node PRE_first_tail_x6_r0_body.kninv144 (pnB PRE_first_tail_x6_r0_body.cx0_144.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow144 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd144.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P144.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd144.nodeF j) PRE_first_tail_x6_r0_body.cx1_144.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a144 : PRE_first_tail_x6_r0_body.cx0_144.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b144 : PRE_first_tail_x6_r0_body.cx0_144.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok1144 : PRE_first_tail_x6_r0_body.cx1_144.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend144 : PRE_first_tail_x6_r0_body.cx1_144.mlx.pending = PRE_first_tail_x6_r0_body.cx0_144.mlx.pending.map PRE_first_tail_x6_r0_body.kappa144.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh144 : PRE_first_tail_x6_r0_body.cx1_144.mlx.errh = PRE_first_tail_x6_r0_body.cx0_144.mlx.errh.map PRE_first_tail_x6_r0_body.kappa144.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles144 : PRE_first_tail_x6_r0_body.cx1_144.mlx.files = PRE_first_tail_x6_r0_body.cx0_144.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch144 : PRE_first_tail_x6_r0_body.cx1_144.mlx.arch = PRE_first_tail_x6_r0_body.cx0_144.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes144 : PRE_first_tail_x6_r0_body.cx1_144.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_144.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired144 : PRE_first_tail_x6_r0_body.cx1_144.mlx.wired = PRE_first_tail_x6_r0_body.cx0_144.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost144 : PRE_first_tail_x6_r0_body.cx1_144.host = PRE_first_tail_x6_r0_body.cx0_144.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd144`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn0144 : PRE_first_tail_x6_r0_body.kd144.n0 = 2788465
kernel_rfl PRE_first_tail_x6_r0_body.ckn1144 : PRE_first_tail_x6_r0_body.kd144.n1 = 2789614
kernel_rfl PRE_first_tail_x6_r0_body.ckheap144 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd144.heap).all (fun x => Nat.ble 2788459 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl144 : (List.range 6).all (fun j => decide (PRE_first_tail_x6_r0_body.kd144.heap.get (2788459 + j) = nth? PRE_first_tail_x6_r0_body.pl144 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja144 : Nat.ble 2788459 2788459 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn144 : Nat.ble 6239 6239 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD144 : Nat.ble 2788459 PRE_first_tail_x6_r0_body.kd144.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn144 : Nat.ble 21048 PRE_first_tail_x6_r0_body.kd144.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn144 : Nat.ble 18122 PRE_first_tail_x6_r0_body.kd144.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb144 : Nat.ble 21048 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap144 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd144.heap).all (Nat.ble (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd144 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd144.hnd).all (Nat.ble (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode144 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd144.node).all (Nat.ble (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix144 : Conv.FixOld (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa144 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja144) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn144) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD144) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn144) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn144) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb144) PRE_first_tail_x6_r0_body.fheap144 PRE_first_tail_x6_r0_body.fhnd144 PRE_first_tail_x6_r0_body.fnode144
kernel_rfl PRE_first_tail_x6_r0_body.fcxn144 : (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn144 : (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle0144 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_144.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_144.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk144 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd144.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A144 : PRE_first_tail_x6_r0_body.cx1_144.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS144.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_144.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O144 : PRE_first_tail_x6_r0_body.cx1_144.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS144.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_144.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N144 : PRE_first_tail_x6_r0_body.cx1_144.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS144.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_144.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I144 : PRE_first_tail_x6_r0_body.cx1_144.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS144.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_144.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd144 : (PRE_first_tail_x6_r0_body.clo144 ++ PRE_first_tail_x6_r0_body.cln144 ++ PRE_first_tail_x6_r0_body.cli144 ++ PRE_first_tail_x6_r0_body.cwS144 ++ PRE_first_tail_x6_r0_body.cnS144 ++ PRE_first_tail_x6_r0_body.ciS144).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW144 : PRE_first_tail_x6_r0_body.cwS144.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo144.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI144 : PRE_first_tail_x6_r0_body.ciS144.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli144.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN144 : PRE_first_tail_x6_r0_body.cnS144.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF144 : PRE_first_tail_x6_r0_body.cln144.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh144 : PRE_first_tail_x6_r0_body.clo144.all (handleOK PRE_first_tail_x6_r0_body.kappa144 PRE_first_tail_x6_r0_body.P144.lo PRE_first_tail_x6_r0_body.cx0_144.mlx PRE_first_tail_x6_r0_body.cx1_144.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo144 : PRE_first_tail_x6_r0_body.clo144.map (fun h => PRE_first_tail_x6_r0_body.cx1_144.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa144.handle h)) = PRE_first_tail_x6_r0_body.clo144.map (fun h => (PRE_first_tail_x6_r0_body.cx0_144.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa144.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok144 : PRE_first_tail_x6_r0_body.clo144.all (objOK PRE_first_tail_x6_r0_body.kappa144 PRE_first_tail_x6_r0_body.P144.NL PRE_first_tail_x6_r0_body.cx0_144.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd144 : PRE_first_tail_x6_r0_body.cln144.all (nodeOKF PRE_first_tail_x6_r0_body.kappa144 PRE_first_tail_x6_r0_body.P144 PRE_first_tail_x6_r0_body.cx0_144.mlx PRE_first_tail_x6_r0_body.cx1_144.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp144 : ((PRE_first_tail_x6_r0_body.cln144.filter (fullB PRE_first_tail_x6_r0_body.P144))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_144.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa144.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln144.filter (fullB PRE_first_tail_x6_r0_body.P144))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_144.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa144.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI144 : incrB PRE_first_tail_x6_r0_body.kd144.nodeF (List.range' 18122 27) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK144 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd144.node).all (fun k => Nat.ble 18122 k && Nat.blt k 18149) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL144 : (PRE_first_tail_x6_r0_body.cln144.filter (Nat.ble PRE_first_tail_x6_r0_body.P144.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd144.nodeF i) && (Nat.blt i 18149 || Nat.ble PRE_first_tail_x6_r0_body.kd144.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord144 : (PRE_first_tail_x6_r0_body.cln144.filter (Nat.ble PRE_first_tail_x6_r0_body.P144.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd144.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd144.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd144.nodeF j) (PRE_first_tail_x6_r0_body.kd144.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow144 PRE_first_tail_x6_r0_body.cnn1144 PRE_first_tail_x6_r0_body.fnordI144 PRE_first_tail_x6_r0_body.fnordK144 PRE_first_tail_x6_r0_body.fnordL144
kernel_rfl PRE_first_tail_x6_r0_body.fi144 : PRE_first_tail_x6_r0_body.cli144.all (pnB PRE_first_tail_x6_r0_body.cx0_144.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii144 : PRE_first_tail_x6_r0_body.cli144.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_144.mlx.items.get (PRE_first_tail_x6_r0_body.kappa144.node k) = (PRE_first_tail_x6_r0_body.cx0_144.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa144.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot144 (clean : Conv.NClean (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P144.NL) (cl : SSt (· < 6257) PRE_first_tail_x6_r0_body.cx0_144.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P144 6257 PRE_first_tail_x6_r0_body.kappa144 PRE_first_tail_x6_r0_body.kd144 PRE_first_tail_x6_r0_body.khinv144 PRE_first_tail_x6_r0_body.kninv144 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx PRE_first_tail_x6_r0_body.cx0_144.mlx PRE_first_tail_x6_r0_body.cx1_144.mlx (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo144 PRE_first_tail_x6_r0_body.cln144 PRE_first_tail_x6_r0_body.cli144 PRE_first_tail_x6_r0_body.cwS144 PRE_first_tail_x6_r0_body.cnS144 PRE_first_tail_x6_r0_body.ciS144 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh0144, PRE_first_tail_x6_r0_body.cnh1144, PRE_first_tail_x6_r0_body.cnn0144, PRE_first_tail_x6_r0_body.cnn1144, PRE_first_tail_x6_r0_body.cplo144, PRE_first_tail_x6_r0_body.ccnt144, PRE_first_tail_x6_r0_body.cnband144, PRE_first_tail_x6_r0_body.chbelow144, PRE_first_tail_x6_r0_body.chren144, PRE_first_tail_x6_r0_body.cband144, PRE_first_tail_x6_r0_body.cnh1pos144, PRE_first_tail_x6_r0_body.cnren144, PRE_first_tail_x6_r0_body.cnlow144, PRE_first_tail_x6_r0_body.cabs0a144, PRE_first_tail_x6_r0_body.cabs0b144, PRE_first_tail_x6_r0_body.ctok1144, PRE_first_tail_x6_r0_body.cpend144, PRE_first_tail_x6_r0_body.cerrh144, PRE_first_tail_x6_r0_body.cfiles144, PRE_first_tail_x6_r0_body.carch144, PRE_first_tail_x6_r0_body.csizes144, PRE_first_tail_x6_r0_body.cwired144, PRE_first_tail_x6_r0_body.cfix144, clean, PRE_first_tail_x6_r0_body.fcxn144, PRE_first_tail_x6_r0_body.fcnn144, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle0144, PRE_first_tail_x6_r0_body.fnk144, PRE_first_tail_x6_r0_body.ckA144, PRE_first_tail_x6_r0_body.cobjsK144, PRE_first_tail_x6_r0_body.cnodesK144, PRE_first_tail_x6_r0_body.citemsK144, PRE_first_tail_x6_r0_body.f1A144, PRE_first_tail_x6_r0_body.f1O144, PRE_first_tail_x6_r0_body.f1N144, PRE_first_tail_x6_r0_body.f1I144, PRE_first_tail_x6_r0_body.fbd144, PRE_first_tail_x6_r0_body.fincW144, PRE_first_tail_x6_r0_body.fincI144, PRE_first_tail_x6_r0_body.fincN144, PRE_first_tail_x6_r0_body.flnF144, PRE_first_tail_x6_r0_body.fh144, PRE_first_tail_x6_r0_body.fo144, PRE_first_tail_x6_r0_body.fok144, PRE_first_tail_x6_r0_body.fnd144, PRE_first_tail_x6_r0_body.fp144, PRE_first_tail_x6_r0_body.fnord144, PRE_first_tail_x6_r0_body.fi144, PRE_first_tail_x6_r0_body.fii144⟩
theorem PRE_first_tail_x6_r0_body.cnshift144 (clean : Conv.NClean (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P144.NL) (cl : SSt (· < 6257) PRE_first_tail_x6_r0_body.cx0_144.mlx) : NShift PRE_first_tail_x6_r0_body.P144 6257 PRE_first_tail_x6_r0_body.kappa144 PRE_first_tail_x6_r0_body.cx0_144 PRE_first_tail_x6_r0_body.cx1_144 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot144 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost144 (compact_a_eq PRE_first_tail_x6_r0_body.ckn0144 PRE_first_tail_x6_r0_body.ckn1144 PRE_first_tail_x6_r0_body.ckheap144 PRE_first_tail_x6_r0_body.ckpl144)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_144 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1396.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_144 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1396.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_144 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1396.ffi) = some PRE_first_tail_x6_r0_body.fxC_144
kernel_rfl PRE_first_tail_x6_r0_body.okrC_144 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1396.ffi) = some PRE_first_tail_x6_r0_body.krC_144
noncomputable def PRE_first_tail_x6_r0_body.fx0_144 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1398.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_144 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1398.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_144 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1398.ffi) = some PRE_first_tail_x6_r0_body.fx0_144
kernel_rfl PRE_first_tail_x6_r0_body.okr0_144 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1398.ffi) = some PRE_first_tail_x6_r0_body.kr0_144
noncomputable def PRE_first_tail_x6_r0_body.fx1_144 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1397.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_144 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1397.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_144 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1397.ffi) = some PRE_first_tail_x6_r0_body.fx1_144
kernel_rfl PRE_first_tail_x6_r0_body.okr1_144 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1397.ffi) = some PRE_first_tail_x6_r0_body.kr1_144
kernel_rfl PRE_first_tail_x6_r0_body.ff0144 : PRE_first_tail_x6_r0_body.fx0_144 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_144 (PRE_first_tail_x6_r0_body.clo144.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_144.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff1144 : PRE_first_tail_x6_r0_body.fx1_144 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_144 (PRE_first_tail_x6_r0_body.cwS144.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_144.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck144 : freedLB PRE_first_tail_x6_r0_body.kappa144 PRE_first_tail_x6_r0_body.cx0_144.mlx PRE_first_tail_x6_r0_body.fx0_144 PRE_first_tail_x6_r0_body.fx1_144 PRE_first_tail_x6_r0_body.clo144 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf0144 : PRE_first_tail_x6_r0_body.kr0_144.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_144.flags (PRE_first_tail_x6_r0_body.clo144.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_144.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt0144 : PRE_first_tail_x6_r0_body.kr0_144.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_144.targs (PRE_first_tail_x6_r0_body.clo144.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_144.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf1144 : PRE_first_tail_x6_r0_body.kr1_144.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_144.flags (PRE_first_tail_x6_r0_body.cwS144.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_144.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt1144 : PRE_first_tail_x6_r0_body.kr1_144.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_144.targs (PRE_first_tail_x6_r0_body.cwS144.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_144.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck144 : krecLB PRE_first_tail_x6_r0_body.kappa144 6257 PRE_first_tail_x6_r0_body.cx0_144.mlx PRE_first_tail_x6_r0_body.kr0_144 PRE_first_tail_x6_r0_body.kr1_144 PRE_first_tail_x6_r0_body.clo144 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn144 : Nat.ble 6239 6257 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge144 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1397.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1398.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR144 : pendRegB PRE_first_tail_x6_r0_body.kappa144 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1398.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe144 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1398.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1397.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift144 (clean : Conv.NClean (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P144.NL) (cl : SSt (· < 6257) PRE_first_tail_x6_r0_body.cx0_144.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_144.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_144.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_144.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1396.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_144.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P144 6257 PRE_first_tail_x6_r0_body.kappa144 PRE_first_tail_x6_r0_body.s1398.ffi PRE_first_tail_x6_r0_body.s1397.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift144 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue144, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp144 t ht),
    PRE_first_tail_x6_r0_body.cbridge144,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1398.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1397.ffi) (PRE_first_tail_x6_r0_body.cfoot144 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_144 PRE_first_tail_x6_r0_body.ofx1_144 hobjC PRE_first_tail_x6_r0_body.ff0144 PRE_first_tail_x6_r0_body.ff1144 PRE_first_tail_x6_r0_body.ffck144,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1398.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1397.ffi) (PRE_first_tail_x6_r0_body.cfoot144 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_144 PRE_first_tail_x6_r0_body.okr1_144 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn144) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf0144 PRE_first_tail_x6_r0_body.fkt0144 PRE_first_tail_x6_r0_body.fkf1144 PRE_first_tail_x6_r0_body.fkt1144 PRE_first_tail_x6_r0_body.fkck144,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh0144 PRE_first_tail_x6_r0_body.cnh1144 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe144) PRE_first_tail_x6_r0_body.cpendR144⟩

end Host.Load.Run.Tpl
end

section -- st144/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st144 0
host_stream_state PRE_first_tail_x6_r0_body.st144 1
host_stream_state PRE_first_tail_x6_r0_body.st144 2
host_stream_state PRE_first_tail_x6_r0_body.st144 3
host_stream_state PRE_first_tail_x6_r0_body.st144 4
host_stream_state PRE_first_tail_x6_r0_body.st144 5
end Host.Load.Run.Tpl
end

section -- Site144
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 144 of chain `PRE_first_tail_x6_r0_body`: `ssmW__g144__g145` (`recurWindow`), the call state `PRE_first_tail_x6_r0_body.s1396`, the merged state `PRE_first_tail_x6_r0_body.s1397`,
the site template `PRE_first_tail_x6_r0_body.st144` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s1398`: the merge.
The footprint's facts are in `SiteF144`, the compaction's in `SiteC144`, `SiteK144`, `SiteNa144`, `SiteNb144`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso144 : PRE_first_tail_x6_r0_body.st144.s0 = { PRE_first_tail_x6_r0_body.s1396 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs144 : List Frame := PRE_first_tail_x6_r0_body.s1396.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_144 : PRE_first_tail_x6_r0_body.S1396.tab.length = 6239
kernel_rfl PRE_first_tail_x6_r0_body.tab0_144 : PRE_first_tail_x6_r0_body.st144.S0.tab = PRE_first_tail_x6_r0_body.S1396.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws144 : List Nat := [3400, 3401, 3402, 3403, 3404, 3405, 3406, 3407, 3408, 3409, 3410, 3411, 3412, 3413, 3414, 3415, 3416, 3417, 3418, 3419, 3420, 3421, 3422, 3423, 3424, 3425, 3426, 3427, 3428, 3429, 3430]
kernel_rfl PRE_first_tail_x6_r0_body.fresh144 : (PRE_first_tail_x6_r0_body.S1396.tab.all fun e => PRE_first_tail_x6_r0_body.ws144.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S1396.oracle.all fun q => PRE_first_tail_x6_r0_body.ws144.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab144 : PRE_first_tail_x6_r0_body.S1397.tab = PRE_first_tail_x6_r0_body.S1396.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws144
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen144 : PRE_first_tail_x6_r0_body.st144.S5.tab.length - PRE_first_tail_x6_r0_body.st144.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged144`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap144 : PRE_first_tail_x6_r0_body.s1397.heap = PRE_first_tail_x6_r0_body.st144.s5.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext144 : PRE_first_tail_x6_r0_body.s1397.next = PRE_first_tail_x6_r0_body.st144.s5.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl144 : PRE_first_tail_x6_r0_body.s1397.ctl = PRE_first_tail_x6_r0_body.st144.s5.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack144 : PRE_first_tail_x6_r0_body.s1397.stack = PRE_first_tail_x6_r0_body.st144.s5.stack ++ PRE_first_tail_x6_r0_body.s1396.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs144 : PRE_first_tail_x6_r0_body.s1397.jobs = PRE_first_tail_x6_r0_body.st144.s5.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi144 : PRE_first_tail_x6_r0_body.s1397.ffi = PRE_first_tail_x6_r0_body.st144.s5.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace144 : PRE_first_tail_x6_r0_body.s1397.trace = PRE_first_tail_x6_r0_body.st144.s5.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores144 : PRE_first_tail_x6_r0_body.s1397.stores = PRE_first_tail_x6_r0_body.st144.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD144
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 144 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived144 : PRE_first_tail_x6_r0_body.nr144.map (fun r => nth? PRE_first_tail_x6_r0_body.st144.S5.tab r) =
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
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo144 : PRE_first_tail_x6_r0_body.nr144.all (Nat.ble 6239) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj144 : PRE_first_tail_x6_r0_body.cws144.all (fun c => !PRE_first_tail_x6_r0_body.ws144.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ144 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws144 PRE_first_tail_x6_r0_body.crs144 PRE_first_tail_x6_r0_body.ws144

end Host.Load.Run.Tpl
end

section -- st144/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st144`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st144.wrR : List (Nat × Nat) := [(2672672, 2672673), (2787633, 2787634), (2788178, 2788179), (2788434, 2788435)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st144.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st144.s5.heap PRE_first_tail_x6_r0_body.st144.wrR ++ freshOf PRE_first_tail_x6_r0_body.st144.s5.heap PRE_first_tail_x6_r0_body.st144.s0.next PRE_first_tail_x6_r0_body.st144.s5.next
noncomputable def PRE_first_tail_x6_r0_body.st144.wr : List Nat := PRE_first_tail_x6_r0_body.st144.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st144.heapFoot : PRE_first_tail_x6_r0_body.st144.s5.heap = setAll PRE_first_tail_x6_r0_body.st144.s0.heap PRE_first_tail_x6_r0_body.st144.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st144.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st144.s0.next PRE_first_tail_x6_r0_body.st144.s5.next = true
theorem PRE_first_tail_x6_r0_body.st144.grows : PRE_first_tail_x6_r0_body.st144.s0.next ≤ PRE_first_tail_x6_r0_body.st144.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st144.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st144.wh : List Nat := [21028, 21041, 21047, 21048, 21049, 21050, 21051, 21052, 21053, 21054, 21055, 21056, 21057, 21058, 21059, 21060, 21061, 21062, 21063, 21064, 21065, 21066, 21067, 21068, 21069, 21070, 21071, 21072, 21073, 21074, 21075]
def PRE_first_tail_x6_r0_body.st144.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st144.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st144.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st144.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st144.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st144.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st144.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st144.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st144.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st144.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st144.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st144.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st144.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st144.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st144.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st144.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st144.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st144.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st144.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st144.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st144.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st144.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st144.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st144.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st144.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st144.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st144.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st144.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st144.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st144.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF144
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 144 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB144 : nodupT PRE_first_tail_x6_r0_body.st144.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup144 : PRE_first_tail_x6_r0_body.st144.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB144).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB144 : PRE_first_tail_x6_r0_body.st144.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound144 : ∀ b ∈ PRE_first_tail_x6_r0_body.st144.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB144 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr144 := PRE_first_tail_x6_r0_body.st144.s5.trace.take 120
kernel_rfl PRE_first_tail_x6_r0_body.traceEq144 : PRE_first_tail_x6_r0_body.st144.s5.trace = PRE_first_tail_x6_r0_body.trFr144 ++ PRE_first_tail_x6_r0_body.st144.s0.trace
theorem PRE_first_tail_x6_r0_body.trace144 : ∃ fr, PRE_first_tail_x6_r0_body.st144.s5.trace = fr ++ PRE_first_tail_x6_r0_body.st144.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq144⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide144 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB144 : (PRE_first_tail_x6_r0_body.wide144.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st144.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix144 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide144, WFix Map.id (Present PRE_first_tail_x6_r0_body.st144.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB144 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL144
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 144 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s1397`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO144 : PRE_first_tail_x6_r0_body.st144.S0.oracle = PRE_first_tail_x6_r0_body.st144.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B144 : PRE_first_tail_x6_r0_body.st144.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st144.s0.next || (PRE_first_tail_x6_r0_body.st144.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot144 : Conv.StageFoot PRE_first_tail_x6_r0_body.st144.wr PRE_first_tail_x6_r0_body.st144.s0 PRE_first_tail_x6_r0_body.st144.s5 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st144.heapFoot PRE_first_tail_x6_r0_body.wrNodup144 PRE_first_tail_x6_r0_body.wrBound144 PRE_first_tail_x6_r0_body.wr0B144 PRE_first_tail_x6_r0_body.st144.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged144 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st144.F.S → PRE_first_tail_x6_r0_body.st144.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st144.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st144.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs144 PRE_first_tail_x6_r0_body.st144.wr PRE_first_tail_x6_r0_body.s1396 PRE_first_tail_x6_r0_body.st144.s5 PRE_first_tail_x6_r0_body.st144.s0
      PRE_first_tail_x6_r0_body.st144.s5.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st144.F FR W stk M ν K PRE_first_tail_x6_r0_body.s1397 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso144 PRE_first_tail_x6_r0_body.stFoot144 PRE_first_tail_x6_r0_body.wrNodup144 PRE_first_tail_x6_r0_body.wrBound144 PRE_first_tail_x6_r0_body.trace144 PRE_first_tail_x6_r0_body.mheap144
    PRE_first_tail_x6_r0_body.mnext144 PRE_first_tail_x6_r0_body.mctl144 PRE_first_tail_x6_r0_body.mstack144 PRE_first_tail_x6_r0_body.mjobs144 PRE_first_tail_x6_r0_body.mffi144 PRE_first_tail_x6_r0_body.mtrace144 PRE_first_tail_x6_r0_body.mstores144 h

def PRE_first_tail_x6_r0_body.arrEl144_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE144_2665 : arrOf PRE_first_tail_x6_r0_body.s1397 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl144_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA144_2665 : isArrB PRE_first_tail_x6_r0_body.s1397 2665 = true
theorem PRE_first_tail_x6_r0_body.arr144_2665 : ∃ o, PRE_first_tail_x6_r0_body.s1397.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl144_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE144_2665 PRE_first_tail_x6_r0_body.arrA144_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN144_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl144_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR144_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl144_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN144_2665

def PRE_first_tail_x6_r0_body.arrEl144_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE144_2673467 : arrOf PRE_first_tail_x6_r0_body.s1397 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl144_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA144_2673467 : isArrB PRE_first_tail_x6_r0_body.s1397 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr144_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s1397.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl144_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE144_2673467 PRE_first_tail_x6_r0_body.arrA144_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN144_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl144_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR144_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl144_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN144_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k144 : isArrB PRE_first_tail_x6_r0_body.s1397 4910 = false
theorem PRE_first_tail_x6_r0_body.keep144 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s1397 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k144 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr144_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl144_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ144
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 144 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s1396`, the merged
state `PRE_first_tail_x6_r0_body.s1397`, the canonical state `PRE_first_tail_x6_r0_body.s1398`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl144 : PRE_first_tail_x6_r0_body.pl144.all (Nat.ble PRE_first_tail_x6_r0_body.s1396.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd144 : nodupT PRE_first_tail_x6_r0_body.pl144 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn1144 : Nat.ble PRE_first_tail_x6_r0_body.s1396.next 2789614 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst144 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s1396.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn144 : PRE_first_tail_x6_r0_body.s1398.next = PRE_first_tail_x6_r0_body.s1396.next + PRE_first_tail_x6_r0_body.pl144.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn144 : PRE_first_tail_x6_r0_body.s1397.next = 2789614
kernel_rfl PRE_first_tail_x6_r0_body.zgrow144 : Nat.ble PRE_first_tail_x6_r0_body.s1398.next PRE_first_tail_x6_r0_body.s1397.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh144 : PRE_first_tail_x6_r0_body.S1396.tab.all (fun e => PRE_first_tail_x6_r0_body.cws144.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd144 : nodupT PRE_first_tail_x6_r0_body.cws144 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi144 : PRE_first_tail_x6_r0_body.nr144.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S1397.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt144 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s1396.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg144_2665 : PRE_first_tail_x6_r0_body.s1398.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1398 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk144_2665 : (objOf PRE_first_tail_x6_r0_body.s1398 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm144_2665 : PRE_first_tail_x6_r0_body.s1397.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa144.obj (objOf PRE_first_tail_x6_r0_body.s1398 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s1397 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg144_2673467 : PRE_first_tail_x6_r0_body.s1398.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1398 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk144_2673467 : (objOf PRE_first_tail_x6_r0_body.s1398 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm144_2673467 : PRE_first_tail_x6_r0_body.s1397.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa144.obj (objOf PRE_first_tail_x6_r0_body.s1398 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s1397 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw144_4910 : (PRE_first_tail_x6_r0_body.s1398.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw144_2673472 : (PRE_first_tail_x6_r0_body.s1398.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw144_2673473 : (PRE_first_tail_x6_r0_body.s1398.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd144 : PRE_first_tail_x6_r0_body.cl144.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr144 : PRE_first_tail_x6_r0_body.st144.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s1396.next || PRE_first_tail_x6_r0_body.cl144.contains b) = true
def PRE_first_tail_x6_r0_body.zl144 : List Nat := PRE_first_tail_x6_r0_body.cl144.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE144 : PRE_first_tail_x6_r0_body.zl144.map (fun a => PRE_first_tail_x6_r0_body.s1397.heap.get (PRE_first_tail_x6_r0_body.kappa144.a a)) = PRE_first_tail_x6_r0_body.zl144.map (fun a => (PRE_first_tail_x6_r0_body.s1398.heap.get a).map PRE_first_tail_x6_r0_body.kappa144.hobj)
theorem PRE_first_tail_x6_r0_body.zimg144 : HeapImg PRE_first_tail_x6_r0_body.kappa144 PRE_first_tail_x6_r0_body.s1398 PRE_first_tail_x6_r0_body.s1397 PRE_first_tail_x6_r0_body.zl144 := PRE_first_tail_x6_r0_body.zimgE144
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl144 : PRE_first_tail_x6_r0_body.s1397.ctl = PRE_first_tail_x6_r0_body.kappa144.ctl PRE_first_tail_x6_r0_body.s1398.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack144 : PRE_first_tail_x6_r0_body.s1397.stack = PRE_first_tail_x6_r0_body.s1398.stack.map PRE_first_tail_x6_r0_body.kappa144.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs144 : PRE_first_tail_x6_r0_body.s1397.jobs = PRE_first_tail_x6_r0_body.s1398.jobs.map PRE_first_tail_x6_r0_body.kappa144.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores144 : PRE_first_tail_x6_r0_body.s1397.stores = PRE_first_tail_x6_r0_body.kappa144.stores PRE_first_tail_x6_r0_body.s1398.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots144 : checkRootsSupp PRE_first_tail_x6_r0_body.s1398 6257 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC144 : PRE_first_tail_x6_r0_body.S1396.tab.length + PRE_first_tail_x6_r0_body.cws144.length = 6257
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap144 : PRE_first_tail_x6_r0_body.kappa144 = Conv.Map.compact PRE_first_tail_x6_r0_body.s1396.next 2789614 PRE_first_tail_x6_r0_body.S1396.tab.length PRE_first_tail_x6_r0_body.pl144 (PRE_first_tail_x6_r0_body.nr144.map NumV.ref) PRE_first_tail_x6_r0_body.kd144.big
  PRE_first_tail_x6_r0_body.kd144.region PRE_first_tail_x6_r0_body.kd144.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin144 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1398.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc144 : Conv.jcleanListB (⟨21051, 18149, 2788465, 6257⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1398 PRE_first_tail_x6_r0_body.cl144 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB144 : noBigRootsP (fun i => !Conv.oldBigB (⟨21051, 18149, 2788465, 6257⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s1398.trace PRE_first_tail_x6_r0_body.s1398 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm144 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 18122 = true
theorem PRE_first_tail_x6_r0_body.cjcl144 (h : Conv.JClean (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1396) : Conv.JClean (⟨21051, 18149, 2788465, 6257⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1398 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle144)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap144 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd144 a ha)) PRE_first_tail_x6_r0_body.zjc144

end Host.Load.Run.Tpl
end

section -- st144/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st144.bodyLast from PRE_first_tail_x6_r0_body.st144.s4 to PRE_first_tail_x6_r0_body.st144.s5 :
  interpS (step PRE_first_tail_x6_r0_body.st144.F PRE_first_tail_x6_r0_body.st144.s4).run PRE_first_tail_x6_r0_body.st144.S4 = some (PRE_first_tail_x6_r0_body.st144.s5, PRE_first_tail_x6_r0_body.st144.S5)
kernel_rfl PRE_first_tail_x6_r0_body.st144.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st144.s4.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st144.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st144.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st144/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st144.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st144.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st144.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st144.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st144.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st144.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st144.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st144.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st144.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st144.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st144.s0 PRE_first_tail_x6_r0_body.st144.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st144.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st144.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st144.s4 PRE_first_tail_x6_r0_body.st144.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st144/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st144.bodyK0F from PRE_first_tail_x6_r0_body.st144.s0 to PRE_first_tail_x6_r0_body.st144.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st144.F (PRE_first_tail_x6_r0_body.st144.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st144.ks 0).getD 0) PRE_first_tail_x6_r0_body.st144.s0 PRE_first_tail_x6_r0_body.st144.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st144.s1, PRE_first_tail_x6_r0_body.st144.S1)
theorem PRE_first_tail_x6_r0_body.st144.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st144.F (PRE_first_tail_x6_r0_body.st144.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st144.ks 0).getD 0) PRE_first_tail_x6_r0_body.st144.s0 PRE_first_tail_x6_r0_body.st144.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st144.s1, PRE_first_tail_x6_r0_body.st144.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st144.bodyOkLN_ok PRE_first_tail_x6_r0_body.st144.bodyK0F
end Host.Load.Run.Tpl
end

section -- st144/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st144.bodyK1F from PRE_first_tail_x6_r0_body.st144.s1 to PRE_first_tail_x6_r0_body.st144.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st144.F (PRE_first_tail_x6_r0_body.st144.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st144.ks 1).getD 0) PRE_first_tail_x6_r0_body.st144.s1 PRE_first_tail_x6_r0_body.st144.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st144.s2, PRE_first_tail_x6_r0_body.st144.S2)
theorem PRE_first_tail_x6_r0_body.st144.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st144.F (PRE_first_tail_x6_r0_body.st144.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st144.ks 1).getD 0) PRE_first_tail_x6_r0_body.st144.s1 PRE_first_tail_x6_r0_body.st144.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st144.s2, PRE_first_tail_x6_r0_body.st144.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st144.bodyOkLN_ok PRE_first_tail_x6_r0_body.st144.bodyK1F
end Host.Load.Run.Tpl
end

section -- st144/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st144.bodyK2F from PRE_first_tail_x6_r0_body.st144.s2 to PRE_first_tail_x6_r0_body.st144.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st144.F (PRE_first_tail_x6_r0_body.st144.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st144.ks 2).getD 0) PRE_first_tail_x6_r0_body.st144.s2 PRE_first_tail_x6_r0_body.st144.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st144.s3, PRE_first_tail_x6_r0_body.st144.S3)
theorem PRE_first_tail_x6_r0_body.st144.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st144.F (PRE_first_tail_x6_r0_body.st144.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st144.ks 2).getD 0) PRE_first_tail_x6_r0_body.st144.s2 PRE_first_tail_x6_r0_body.st144.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st144.s3, PRE_first_tail_x6_r0_body.st144.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st144.bodyOkLN_ok PRE_first_tail_x6_r0_body.st144.bodyK2F
end Host.Load.Run.Tpl
end

section -- st144/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st144.bodyK3F from PRE_first_tail_x6_r0_body.st144.s3 to PRE_first_tail_x6_r0_body.st144.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st144.F (PRE_first_tail_x6_r0_body.st144.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st144.ks 3).getD 0) PRE_first_tail_x6_r0_body.st144.s3 PRE_first_tail_x6_r0_body.st144.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st144.s4, PRE_first_tail_x6_r0_body.st144.S4)
theorem PRE_first_tail_x6_r0_body.st144.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st144.F (PRE_first_tail_x6_r0_body.st144.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st144.ks 3).getD 0) PRE_first_tail_x6_r0_body.st144.s3 PRE_first_tail_x6_r0_body.st144.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st144.s4, PRE_first_tail_x6_r0_body.st144.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st144.bodyOkLN_ok PRE_first_tail_x6_r0_body.st144.bodyK3F
end Host.Load.Run.Tpl
end

section -- st144/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st144.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st144.F (PRE_first_tail_x6_r0_body.st144.bodyOkL bytes rows) 11334 PRE_first_tail_x6_r0_body.st144.s0 PRE_first_tail_x6_r0_body.st144.S0 = some (PRE_first_tail_x6_r0_body.st144.s4, PRE_first_tail_x6_r0_body.st144.S4) :=
  runOk_trans PRE_first_tail_x6_r0_body.st144.F (PRE_first_tail_x6_r0_body.st144.bodyOkL bytes rows) ((((nth? PRE_first_tail_x6_r0_body.st144.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st144.ks 1).getD 0)) + ((nth? PRE_first_tail_x6_r0_body.st144.ks 2).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st144.ks 3).getD 0) PRE_first_tail_x6_r0_body.st144.s0 PRE_first_tail_x6_r0_body.st144.s3 PRE_first_tail_x6_r0_body.st144.s4 PRE_first_tail_x6_r0_body.st144.S0 PRE_first_tail_x6_r0_body.st144.S3 PRE_first_tail_x6_r0_body.st144.S4 (runOk_trans PRE_first_tail_x6_r0_body.st144.F (PRE_first_tail_x6_r0_body.st144.bodyOkL bytes rows) (((nth? PRE_first_tail_x6_r0_body.st144.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st144.ks 1).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st144.ks 2).getD 0) PRE_first_tail_x6_r0_body.st144.s0 PRE_first_tail_x6_r0_body.st144.s2 PRE_first_tail_x6_r0_body.st144.s3 PRE_first_tail_x6_r0_body.st144.S0 PRE_first_tail_x6_r0_body.st144.S2 PRE_first_tail_x6_r0_body.st144.S3 (runOk_trans PRE_first_tail_x6_r0_body.st144.F (PRE_first_tail_x6_r0_body.st144.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st144.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st144.ks 1).getD 0) PRE_first_tail_x6_r0_body.st144.s0 PRE_first_tail_x6_r0_body.st144.s1 PRE_first_tail_x6_r0_body.st144.s2 PRE_first_tail_x6_r0_body.st144.S0 PRE_first_tail_x6_r0_body.st144.S1 PRE_first_tail_x6_r0_body.st144.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st144.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st144.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st144.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st144.bodyK3 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st144.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st144.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st144.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st144.F (PRE_first_tail_x6_r0_body.st144.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st144.s0
  S0 := PRE_first_tail_x6_r0_body.st144.S0
  s1 := PRE_first_tail_x6_r0_body.st144.s4
  S1 := PRE_first_tail_x6_r0_body.st144.S4
  s2 := PRE_first_tail_x6_r0_body.st144.s5
  S2 := PRE_first_tail_x6_r0_body.st144.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st144.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st144.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st144.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st144.bodyHalt
  last := PRE_first_tail_x6_r0_body.st144.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st144.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC145
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 145 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s1406` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa145` into the merged state
`PRE_first_tail_x6_r0_body.s1405`. -/

def PRE_first_tail_x6_r0_body.pl145 : List Nat := []
def PRE_first_tail_x6_r0_body.nr145 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd145 : RData :=
  ⟨2788955, 2788957, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21064, 21064, 18162, 18162, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa145 : Map :=
  Conv.Map.compact 2788955 2788957 6278 PRE_first_tail_x6_r0_body.pl145 (PRE_first_tail_x6_r0_body.nr145.map NumV.ref) PRE_first_tail_x6_r0_body.kd145.big
    PRE_first_tail_x6_r0_body.kd145.region PRE_first_tail_x6_r0_body.kd145.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws145 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs145 : List SymE := PRE_first_tail_x6_r0_body.nr145.map fun r => (nth? PRE_first_tail_x6_r0_body.S1405.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta145 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws145 PRE_first_tail_x6_r0_body.crs145
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB145 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab145 : PRE_first_tail_x6_r0_body.S1406.tab = PRE_first_tail_x6_r0_body.S1404.tab ++ PRE_first_tail_x6_r0_body.cws145.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace145 : PRE_first_tail_x6_r0_body.s1406.trace = PRE_first_tail_x6_r0_body.s1404.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext145 : PRE_first_tail_x6_r0_body.s1406.next = 2788955
kernel_rfl PRE_first_tail_x6_r0_body.ccounters145 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1406.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1406.ffi).mlx.nnext) = (21064, 18162)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue145 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1405.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1406.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa145.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp145 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1406.ffi).mlx.tokens.all (bSN 6278) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean145 : Conv.cleanListB 21064 131072 (fun r => Nat.ble 84256 r) PRE_first_tail_x6_r0_body.s1406
    (PRE_first_tail_x6_r0_body.wrB145 ++ (List.range 0).map (2788955 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs145 : bigsOutB 21064 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1406.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK145
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl145`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl145 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo145 : List Nat := []
def PRE_first_tail_x6_r0_body.cln145 : List Nat := []
def PRE_first_tail_x6_r0_body.cli145 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap145 : PRE_first_tail_x6_r0_body.s1406.heap = Stage.setAll PRE_first_tail_x6_r0_body.s1404.heap (PRE_first_tail_x6_r0_body.cl145.filterMap fun a => (PRE_first_tail_x6_r0_body.s1406.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe145 : Nat.ble PRE_first_tail_x6_r0_body.s1404.next PRE_first_tail_x6_r0_body.s1406.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP145 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s1404 PRE_first_tail_x6_r0_body.s1406 PRE_first_tail_x6_r0_body.cl145 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp145 : Conv.suppListB PRE_first_tail_x6_r0_body.s1406 6278 PRE_first_tail_x6_r0_body.cl145 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound145 : Conv.boundListB PRE_first_tail_x6_r0_body.s1406 PRE_first_tail_x6_r0_body.cl145 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK145 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1406.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln145.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1406.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK145 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1406.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo145.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1406.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK145 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1406.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli145.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1406.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst145 : Conv.sstListB 6278 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1406.ffi).mlx PRE_first_tail_x6_r0_body.cln145 PRE_first_tail_x6_r0_body.clo145 PRE_first_tail_x6_r0_body.cli145 = true

end Host.Load.Run.Tpl
end

section -- SiteCl145
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA145 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1406.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo145.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1406.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd145 : (PRE_first_tail_x6_r0_body.clo145 ++ PRE_first_tail_x6_r0_body.cln145 ++ PRE_first_tail_x6_r0_body.cli145).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle145 : Conv.Cnt.leB (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck145 : Conv.ncleanListB (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1406.ffi).mlx PRE_first_tail_x6_r0_body.clo145 PRE_first_tail_x6_r0_body.cln145 PRE_first_tail_x6_r0_body.cli145 = true
theorem PRE_first_tail_x6_r0_body.cncl145 (h : Conv.NClean (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx) : Conv.NClean (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1406.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle145 PRE_first_tail_x6_r0_body.ckA145 PRE_first_tail_x6_r0_body.cobjsK145 PRE_first_tail_x6_r0_body.cnodesK145 PRE_first_tail_x6_r0_body.citemsK145 PRE_first_tail_x6_r0_body.cbd145 PRE_first_tail_x6_r0_body.cck145

end Host.Load.Run.Tpl
end

section -- SiteS145
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 145 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc145 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P145 : LoadP := PRE_first_tail_x6_r0_body.Pc145.raise 18162
kernel_rfl PRE_first_tail_x6_r0_body.craise145 : Nat.ble PRE_first_tail_x6_r0_body.Pc145.N0 18162 = true
theorem PRE_first_tail_x6_r0_body.raised145 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc145 PRE_first_tail_x6_r0_body.P145 :=
  .inr ⟨18162, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise145, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_145 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1406.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_145 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1405.ffi)
def PRE_first_tail_x6_r0_body.khinv145 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv145 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS145 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS145 : List Nat := List.range' 18162 0
def PRE_first_tail_x6_r0_body.ciS145 : List Nat := [] ++ List.range' 18162 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh0145 : PRE_first_tail_x6_r0_body.kd145.nh0 = PRE_first_tail_x6_r0_body.cx0_145.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh1145 : PRE_first_tail_x6_r0_body.kd145.nh1 = PRE_first_tail_x6_r0_body.cx1_145.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn0145 : PRE_first_tail_x6_r0_body.kd145.nn0 = PRE_first_tail_x6_r0_body.cx0_145.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn1145 : PRE_first_tail_x6_r0_body.kd145.nn1 = PRE_first_tail_x6_r0_body.cx1_145.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo145 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P145.lo && Nat.ble PRE_first_tail_x6_r0_body.P145.lo PRE_first_tail_x6_r0_body.cx0_145.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P145.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P145.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt145 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_145.mlx.next PRE_first_tail_x6_r0_body.cx1_145.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_145.mlx.nnext PRE_first_tail_x6_r0_body.cx1_145.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband145 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P145.NL && Nat.ble PRE_first_tail_x6_r0_body.P145.NL PRE_first_tail_x6_r0_body.P145.N0 && Nat.ble PRE_first_tail_x6_r0_body.P145.N0 PRE_first_tail_x6_r0_body.cx0_145.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow145 : PRE_first_tail_x6_r0_body.kd145.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren145 : checkRenG PRE_first_tail_x6_r0_body.kd145.hnd PRE_first_tail_x6_r0_body.khinv145 (phB PRE_first_tail_x6_r0_body.cx0_145.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband145 : PRE_first_tail_x6_r0_body.kd145.checkBand PRE_first_tail_x6_r0_body.P145.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos145 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd145.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren145 : checkRenG PRE_first_tail_x6_r0_body.kd145.node PRE_first_tail_x6_r0_body.kninv145 (pnB PRE_first_tail_x6_r0_body.cx0_145.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow145 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd145.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P145.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd145.nodeF j) PRE_first_tail_x6_r0_body.cx1_145.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a145 : PRE_first_tail_x6_r0_body.cx0_145.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b145 : PRE_first_tail_x6_r0_body.cx0_145.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok1145 : PRE_first_tail_x6_r0_body.cx1_145.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend145 : PRE_first_tail_x6_r0_body.cx1_145.mlx.pending = PRE_first_tail_x6_r0_body.cx0_145.mlx.pending.map PRE_first_tail_x6_r0_body.kappa145.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh145 : PRE_first_tail_x6_r0_body.cx1_145.mlx.errh = PRE_first_tail_x6_r0_body.cx0_145.mlx.errh.map PRE_first_tail_x6_r0_body.kappa145.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles145 : PRE_first_tail_x6_r0_body.cx1_145.mlx.files = PRE_first_tail_x6_r0_body.cx0_145.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch145 : PRE_first_tail_x6_r0_body.cx1_145.mlx.arch = PRE_first_tail_x6_r0_body.cx0_145.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes145 : PRE_first_tail_x6_r0_body.cx1_145.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_145.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired145 : PRE_first_tail_x6_r0_body.cx1_145.mlx.wired = PRE_first_tail_x6_r0_body.cx0_145.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost145 : PRE_first_tail_x6_r0_body.cx1_145.host = PRE_first_tail_x6_r0_body.cx0_145.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd145`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn0145 : PRE_first_tail_x6_r0_body.kd145.n0 = 2788955
kernel_rfl PRE_first_tail_x6_r0_body.ckn1145 : PRE_first_tail_x6_r0_body.kd145.n1 = 2788957
kernel_rfl PRE_first_tail_x6_r0_body.ckheap145 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd145.heap).all (fun x => Nat.ble 2788955 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl145 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_body.kd145.heap.get (2788955 + j) = nth? PRE_first_tail_x6_r0_body.pl145 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja145 : Nat.ble 2788955 2788955 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn145 : Nat.ble 6278 6278 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD145 : Nat.ble 2788955 PRE_first_tail_x6_r0_body.kd145.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn145 : Nat.ble 21064 PRE_first_tail_x6_r0_body.kd145.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn145 : Nat.ble 18162 PRE_first_tail_x6_r0_body.kd145.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb145 : Nat.ble 21064 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap145 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd145.heap).all (Nat.ble (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd145 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd145.hnd).all (Nat.ble (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode145 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd145.node).all (Nat.ble (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix145 : Conv.FixOld (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa145 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja145) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn145) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD145) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn145) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn145) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb145) PRE_first_tail_x6_r0_body.fheap145 PRE_first_tail_x6_r0_body.fhnd145 PRE_first_tail_x6_r0_body.fnode145
kernel_rfl PRE_first_tail_x6_r0_body.fcxn145 : (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn145 : (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle0145 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_145.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_145.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk145 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd145.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A145 : PRE_first_tail_x6_r0_body.cx1_145.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS145.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_145.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O145 : PRE_first_tail_x6_r0_body.cx1_145.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS145.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_145.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N145 : PRE_first_tail_x6_r0_body.cx1_145.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS145.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_145.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I145 : PRE_first_tail_x6_r0_body.cx1_145.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS145.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_145.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd145 : (PRE_first_tail_x6_r0_body.clo145 ++ PRE_first_tail_x6_r0_body.cln145 ++ PRE_first_tail_x6_r0_body.cli145 ++ PRE_first_tail_x6_r0_body.cwS145 ++ PRE_first_tail_x6_r0_body.cnS145 ++ PRE_first_tail_x6_r0_body.ciS145).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW145 : PRE_first_tail_x6_r0_body.cwS145.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo145.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI145 : PRE_first_tail_x6_r0_body.ciS145.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli145.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN145 : PRE_first_tail_x6_r0_body.cnS145.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF145 : PRE_first_tail_x6_r0_body.cln145.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh145 : PRE_first_tail_x6_r0_body.clo145.all (handleOK PRE_first_tail_x6_r0_body.kappa145 PRE_first_tail_x6_r0_body.P145.lo PRE_first_tail_x6_r0_body.cx0_145.mlx PRE_first_tail_x6_r0_body.cx1_145.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo145 : PRE_first_tail_x6_r0_body.clo145.map (fun h => PRE_first_tail_x6_r0_body.cx1_145.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa145.handle h)) = PRE_first_tail_x6_r0_body.clo145.map (fun h => (PRE_first_tail_x6_r0_body.cx0_145.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa145.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok145 : PRE_first_tail_x6_r0_body.clo145.all (objOK PRE_first_tail_x6_r0_body.kappa145 PRE_first_tail_x6_r0_body.P145.NL PRE_first_tail_x6_r0_body.cx0_145.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd145 : PRE_first_tail_x6_r0_body.cln145.all (nodeOKF PRE_first_tail_x6_r0_body.kappa145 PRE_first_tail_x6_r0_body.P145 PRE_first_tail_x6_r0_body.cx0_145.mlx PRE_first_tail_x6_r0_body.cx1_145.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp145 : ((PRE_first_tail_x6_r0_body.cln145.filter (fullB PRE_first_tail_x6_r0_body.P145))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_145.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa145.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln145.filter (fullB PRE_first_tail_x6_r0_body.P145))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_145.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa145.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI145 : incrB PRE_first_tail_x6_r0_body.kd145.nodeF (List.range' 18162 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK145 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd145.node).all (fun k => Nat.ble 18162 k && Nat.blt k 18162) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL145 : (PRE_first_tail_x6_r0_body.cln145.filter (Nat.ble PRE_first_tail_x6_r0_body.P145.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd145.nodeF i) && (Nat.blt i 18162 || Nat.ble PRE_first_tail_x6_r0_body.kd145.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord145 : (PRE_first_tail_x6_r0_body.cln145.filter (Nat.ble PRE_first_tail_x6_r0_body.P145.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd145.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd145.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd145.nodeF j) (PRE_first_tail_x6_r0_body.kd145.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow145 PRE_first_tail_x6_r0_body.cnn1145 PRE_first_tail_x6_r0_body.fnordI145 PRE_first_tail_x6_r0_body.fnordK145 PRE_first_tail_x6_r0_body.fnordL145
kernel_rfl PRE_first_tail_x6_r0_body.fi145 : PRE_first_tail_x6_r0_body.cli145.all (pnB PRE_first_tail_x6_r0_body.cx0_145.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii145 : PRE_first_tail_x6_r0_body.cli145.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_145.mlx.items.get (PRE_first_tail_x6_r0_body.kappa145.node k) = (PRE_first_tail_x6_r0_body.cx0_145.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa145.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot145 (clean : Conv.NClean (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P145.NL) (cl : SSt (· < 6278) PRE_first_tail_x6_r0_body.cx0_145.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P145 6278 PRE_first_tail_x6_r0_body.kappa145 PRE_first_tail_x6_r0_body.kd145 PRE_first_tail_x6_r0_body.khinv145 PRE_first_tail_x6_r0_body.kninv145 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx PRE_first_tail_x6_r0_body.cx0_145.mlx PRE_first_tail_x6_r0_body.cx1_145.mlx (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo145 PRE_first_tail_x6_r0_body.cln145 PRE_first_tail_x6_r0_body.cli145 PRE_first_tail_x6_r0_body.cwS145 PRE_first_tail_x6_r0_body.cnS145 PRE_first_tail_x6_r0_body.ciS145 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh0145, PRE_first_tail_x6_r0_body.cnh1145, PRE_first_tail_x6_r0_body.cnn0145, PRE_first_tail_x6_r0_body.cnn1145, PRE_first_tail_x6_r0_body.cplo145, PRE_first_tail_x6_r0_body.ccnt145, PRE_first_tail_x6_r0_body.cnband145, PRE_first_tail_x6_r0_body.chbelow145, PRE_first_tail_x6_r0_body.chren145, PRE_first_tail_x6_r0_body.cband145, PRE_first_tail_x6_r0_body.cnh1pos145, PRE_first_tail_x6_r0_body.cnren145, PRE_first_tail_x6_r0_body.cnlow145, PRE_first_tail_x6_r0_body.cabs0a145, PRE_first_tail_x6_r0_body.cabs0b145, PRE_first_tail_x6_r0_body.ctok1145, PRE_first_tail_x6_r0_body.cpend145, PRE_first_tail_x6_r0_body.cerrh145, PRE_first_tail_x6_r0_body.cfiles145, PRE_first_tail_x6_r0_body.carch145, PRE_first_tail_x6_r0_body.csizes145, PRE_first_tail_x6_r0_body.cwired145, PRE_first_tail_x6_r0_body.cfix145, clean, PRE_first_tail_x6_r0_body.fcxn145, PRE_first_tail_x6_r0_body.fcnn145, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle0145, PRE_first_tail_x6_r0_body.fnk145, PRE_first_tail_x6_r0_body.ckA145, PRE_first_tail_x6_r0_body.cobjsK145, PRE_first_tail_x6_r0_body.cnodesK145, PRE_first_tail_x6_r0_body.citemsK145, PRE_first_tail_x6_r0_body.f1A145, PRE_first_tail_x6_r0_body.f1O145, PRE_first_tail_x6_r0_body.f1N145, PRE_first_tail_x6_r0_body.f1I145, PRE_first_tail_x6_r0_body.fbd145, PRE_first_tail_x6_r0_body.fincW145, PRE_first_tail_x6_r0_body.fincI145, PRE_first_tail_x6_r0_body.fincN145, PRE_first_tail_x6_r0_body.flnF145, PRE_first_tail_x6_r0_body.fh145, PRE_first_tail_x6_r0_body.fo145, PRE_first_tail_x6_r0_body.fok145, PRE_first_tail_x6_r0_body.fnd145, PRE_first_tail_x6_r0_body.fp145, PRE_first_tail_x6_r0_body.fnord145, PRE_first_tail_x6_r0_body.fi145, PRE_first_tail_x6_r0_body.fii145⟩
theorem PRE_first_tail_x6_r0_body.cnshift145 (clean : Conv.NClean (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P145.NL) (cl : SSt (· < 6278) PRE_first_tail_x6_r0_body.cx0_145.mlx) : NShift PRE_first_tail_x6_r0_body.P145 6278 PRE_first_tail_x6_r0_body.kappa145 PRE_first_tail_x6_r0_body.cx0_145 PRE_first_tail_x6_r0_body.cx1_145 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot145 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost145 (compact_a_eq PRE_first_tail_x6_r0_body.ckn0145 PRE_first_tail_x6_r0_body.ckn1145 PRE_first_tail_x6_r0_body.ckheap145 PRE_first_tail_x6_r0_body.ckpl145)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_145 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1404.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_145 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1404.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_145 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1404.ffi) = some PRE_first_tail_x6_r0_body.fxC_145
kernel_rfl PRE_first_tail_x6_r0_body.okrC_145 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1404.ffi) = some PRE_first_tail_x6_r0_body.krC_145
noncomputable def PRE_first_tail_x6_r0_body.fx0_145 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1406.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_145 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1406.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_145 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1406.ffi) = some PRE_first_tail_x6_r0_body.fx0_145
kernel_rfl PRE_first_tail_x6_r0_body.okr0_145 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1406.ffi) = some PRE_first_tail_x6_r0_body.kr0_145
noncomputable def PRE_first_tail_x6_r0_body.fx1_145 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1405.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_145 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1405.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_145 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1405.ffi) = some PRE_first_tail_x6_r0_body.fx1_145
kernel_rfl PRE_first_tail_x6_r0_body.okr1_145 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1405.ffi) = some PRE_first_tail_x6_r0_body.kr1_145
kernel_rfl PRE_first_tail_x6_r0_body.ff0145 : PRE_first_tail_x6_r0_body.fx0_145 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_145 (PRE_first_tail_x6_r0_body.clo145.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_145.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff1145 : PRE_first_tail_x6_r0_body.fx1_145 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_145 (PRE_first_tail_x6_r0_body.cwS145.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_145.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck145 : freedLB PRE_first_tail_x6_r0_body.kappa145 PRE_first_tail_x6_r0_body.cx0_145.mlx PRE_first_tail_x6_r0_body.fx0_145 PRE_first_tail_x6_r0_body.fx1_145 PRE_first_tail_x6_r0_body.clo145 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf0145 : PRE_first_tail_x6_r0_body.kr0_145.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_145.flags (PRE_first_tail_x6_r0_body.clo145.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_145.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt0145 : PRE_first_tail_x6_r0_body.kr0_145.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_145.targs (PRE_first_tail_x6_r0_body.clo145.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_145.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf1145 : PRE_first_tail_x6_r0_body.kr1_145.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_145.flags (PRE_first_tail_x6_r0_body.cwS145.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_145.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt1145 : PRE_first_tail_x6_r0_body.kr1_145.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_145.targs (PRE_first_tail_x6_r0_body.cwS145.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_145.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck145 : krecLB PRE_first_tail_x6_r0_body.kappa145 6278 PRE_first_tail_x6_r0_body.cx0_145.mlx PRE_first_tail_x6_r0_body.kr0_145 PRE_first_tail_x6_r0_body.kr1_145 PRE_first_tail_x6_r0_body.clo145 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn145 : Nat.ble 6278 6278 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge145 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1405.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1406.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR145 : pendRegB PRE_first_tail_x6_r0_body.kappa145 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1406.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe145 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1406.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1405.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift145 (clean : Conv.NClean (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P145.NL) (cl : SSt (· < 6278) PRE_first_tail_x6_r0_body.cx0_145.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_145.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_145.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_145.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1404.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_145.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P145 6278 PRE_first_tail_x6_r0_body.kappa145 PRE_first_tail_x6_r0_body.s1406.ffi PRE_first_tail_x6_r0_body.s1405.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift145 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue145, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp145 t ht),
    PRE_first_tail_x6_r0_body.cbridge145,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1406.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1405.ffi) (PRE_first_tail_x6_r0_body.cfoot145 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_145 PRE_first_tail_x6_r0_body.ofx1_145 hobjC PRE_first_tail_x6_r0_body.ff0145 PRE_first_tail_x6_r0_body.ff1145 PRE_first_tail_x6_r0_body.ffck145,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1406.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1405.ffi) (PRE_first_tail_x6_r0_body.cfoot145 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_145 PRE_first_tail_x6_r0_body.okr1_145 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn145) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf0145 PRE_first_tail_x6_r0_body.fkt0145 PRE_first_tail_x6_r0_body.fkf1145 PRE_first_tail_x6_r0_body.fkt1145 PRE_first_tail_x6_r0_body.fkck145,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh0145 PRE_first_tail_x6_r0_body.cnh1145 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe145) PRE_first_tail_x6_r0_body.cpendR145⟩

end Host.Load.Run.Tpl
end

section -- st145/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st145 0
host_stream_state PRE_first_tail_x6_r0_body.st145 1
host_stream_state PRE_first_tail_x6_r0_body.st145 2
end Host.Load.Run.Tpl
end

section -- Site145
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 145 of chain `PRE_first_tail_x6_r0_body`: `rowBlocks__g145__g146` (`rowBlocks`), the call state `PRE_first_tail_x6_r0_body.s1404`, the merged state `PRE_first_tail_x6_r0_body.s1405`,
the site template `PRE_first_tail_x6_r0_body.st145` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s1406`: the merge.
The footprint's facts are in `SiteF145`, the compaction's in `SiteC145`, `SiteK145`, `SiteNa145`, `SiteNb145`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso145 : PRE_first_tail_x6_r0_body.st145.s0 = { PRE_first_tail_x6_r0_body.s1404 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs145 : List Frame := PRE_first_tail_x6_r0_body.s1404.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_145 : PRE_first_tail_x6_r0_body.S1404.tab.length = 6278
kernel_rfl PRE_first_tail_x6_r0_body.tab0_145 : PRE_first_tail_x6_r0_body.st145.S0.tab = PRE_first_tail_x6_r0_body.S1404.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws145 : List Nat := [3449, 3450]
kernel_rfl PRE_first_tail_x6_r0_body.fresh145 : (PRE_first_tail_x6_r0_body.S1404.tab.all fun e => PRE_first_tail_x6_r0_body.ws145.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S1404.oracle.all fun q => PRE_first_tail_x6_r0_body.ws145.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab145 : PRE_first_tail_x6_r0_body.S1405.tab = PRE_first_tail_x6_r0_body.S1404.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws145
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen145 : PRE_first_tail_x6_r0_body.st145.S2.tab.length - PRE_first_tail_x6_r0_body.st145.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged145`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap145 : PRE_first_tail_x6_r0_body.s1405.heap = PRE_first_tail_x6_r0_body.st145.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext145 : PRE_first_tail_x6_r0_body.s1405.next = PRE_first_tail_x6_r0_body.st145.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl145 : PRE_first_tail_x6_r0_body.s1405.ctl = PRE_first_tail_x6_r0_body.st145.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack145 : PRE_first_tail_x6_r0_body.s1405.stack = PRE_first_tail_x6_r0_body.st145.s2.stack ++ PRE_first_tail_x6_r0_body.s1404.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs145 : PRE_first_tail_x6_r0_body.s1405.jobs = PRE_first_tail_x6_r0_body.st145.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi145 : PRE_first_tail_x6_r0_body.s1405.ffi = PRE_first_tail_x6_r0_body.st145.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace145 : PRE_first_tail_x6_r0_body.s1405.trace = PRE_first_tail_x6_r0_body.st145.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores145 : PRE_first_tail_x6_r0_body.s1405.stores = PRE_first_tail_x6_r0_body.st145.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD145
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 145 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived145 : PRE_first_tail_x6_r0_body.nr145.map (fun r => nth? PRE_first_tail_x6_r0_body.st145.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo145 : PRE_first_tail_x6_r0_body.nr145.all (Nat.ble 6278) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj145 : PRE_first_tail_x6_r0_body.cws145.all (fun c => !PRE_first_tail_x6_r0_body.ws145.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ145 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws145 PRE_first_tail_x6_r0_body.crs145 PRE_first_tail_x6_r0_body.ws145

end Host.Load.Run.Tpl
end

section -- st145/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st145`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st145.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st145.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st145.s2.heap PRE_first_tail_x6_r0_body.st145.wrR ++ freshOf PRE_first_tail_x6_r0_body.st145.s2.heap PRE_first_tail_x6_r0_body.st145.s0.next PRE_first_tail_x6_r0_body.st145.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st145.wr : List Nat := PRE_first_tail_x6_r0_body.st145.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st145.heapFoot : PRE_first_tail_x6_r0_body.st145.s2.heap = setAll PRE_first_tail_x6_r0_body.st145.s0.heap PRE_first_tail_x6_r0_body.st145.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st145.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st145.s0.next PRE_first_tail_x6_r0_body.st145.s2.next = true
theorem PRE_first_tail_x6_r0_body.st145.grows : PRE_first_tail_x6_r0_body.st145.s0.next ≤ PRE_first_tail_x6_r0_body.st145.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st145.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st145.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st145.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st145.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st145.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st145.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st145.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st145.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st145.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st145.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st145.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st145.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st145.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st145.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st145.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st145.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st145.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st145.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st145.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st145.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st145.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st145.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st145.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st145.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st145.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st145.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st145.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st145.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st145.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st145.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st145.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st145.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF145
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 145 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB145 : nodupT PRE_first_tail_x6_r0_body.st145.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup145 : PRE_first_tail_x6_r0_body.st145.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB145).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB145 : PRE_first_tail_x6_r0_body.st145.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound145 : ∀ b ∈ PRE_first_tail_x6_r0_body.st145.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB145 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr145 := PRE_first_tail_x6_r0_body.st145.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq145 : PRE_first_tail_x6_r0_body.st145.s2.trace = PRE_first_tail_x6_r0_body.trFr145 ++ PRE_first_tail_x6_r0_body.st145.s0.trace
theorem PRE_first_tail_x6_r0_body.trace145 : ∃ fr, PRE_first_tail_x6_r0_body.st145.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st145.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq145⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide145 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB145 : (PRE_first_tail_x6_r0_body.wide145.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st145.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix145 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide145, WFix Map.id (Present PRE_first_tail_x6_r0_body.st145.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB145 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL145
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 145 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s1405`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO145 : PRE_first_tail_x6_r0_body.st145.S0.oracle = PRE_first_tail_x6_r0_body.st145.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B145 : PRE_first_tail_x6_r0_body.st145.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st145.s0.next || (PRE_first_tail_x6_r0_body.st145.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot145 : Conv.StageFoot PRE_first_tail_x6_r0_body.st145.wr PRE_first_tail_x6_r0_body.st145.s0 PRE_first_tail_x6_r0_body.st145.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st145.heapFoot PRE_first_tail_x6_r0_body.wrNodup145 PRE_first_tail_x6_r0_body.wrBound145 PRE_first_tail_x6_r0_body.wr0B145 PRE_first_tail_x6_r0_body.st145.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged145 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st145.F.S → PRE_first_tail_x6_r0_body.st145.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st145.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st145.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs145 PRE_first_tail_x6_r0_body.st145.wr PRE_first_tail_x6_r0_body.s1404 PRE_first_tail_x6_r0_body.st145.s2 PRE_first_tail_x6_r0_body.st145.s0
      PRE_first_tail_x6_r0_body.st145.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st145.F FR W stk M ν K PRE_first_tail_x6_r0_body.s1405 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso145 PRE_first_tail_x6_r0_body.stFoot145 PRE_first_tail_x6_r0_body.wrNodup145 PRE_first_tail_x6_r0_body.wrBound145 PRE_first_tail_x6_r0_body.trace145 PRE_first_tail_x6_r0_body.mheap145
    PRE_first_tail_x6_r0_body.mnext145 PRE_first_tail_x6_r0_body.mctl145 PRE_first_tail_x6_r0_body.mstack145 PRE_first_tail_x6_r0_body.mjobs145 PRE_first_tail_x6_r0_body.mffi145 PRE_first_tail_x6_r0_body.mtrace145 PRE_first_tail_x6_r0_body.mstores145 h

def PRE_first_tail_x6_r0_body.arrEl145_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE145_2665 : arrOf PRE_first_tail_x6_r0_body.s1405 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl145_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA145_2665 : isArrB PRE_first_tail_x6_r0_body.s1405 2665 = true
theorem PRE_first_tail_x6_r0_body.arr145_2665 : ∃ o, PRE_first_tail_x6_r0_body.s1405.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl145_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE145_2665 PRE_first_tail_x6_r0_body.arrA145_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN145_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl145_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR145_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl145_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN145_2665

def PRE_first_tail_x6_r0_body.arrEl145_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE145_2673467 : arrOf PRE_first_tail_x6_r0_body.s1405 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl145_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA145_2673467 : isArrB PRE_first_tail_x6_r0_body.s1405 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr145_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s1405.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl145_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE145_2673467 PRE_first_tail_x6_r0_body.arrA145_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN145_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl145_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR145_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl145_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN145_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k145 : isArrB PRE_first_tail_x6_r0_body.s1405 4910 = false
theorem PRE_first_tail_x6_r0_body.keep145 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s1405 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k145 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr145_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl145_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ145
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 145 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s1404`, the merged
state `PRE_first_tail_x6_r0_body.s1405`, the canonical state `PRE_first_tail_x6_r0_body.s1406`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl145 : PRE_first_tail_x6_r0_body.pl145.all (Nat.ble PRE_first_tail_x6_r0_body.s1404.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd145 : nodupT PRE_first_tail_x6_r0_body.pl145 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn1145 : Nat.ble PRE_first_tail_x6_r0_body.s1404.next 2788957 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst145 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s1404.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn145 : PRE_first_tail_x6_r0_body.s1406.next = PRE_first_tail_x6_r0_body.s1404.next + PRE_first_tail_x6_r0_body.pl145.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn145 : PRE_first_tail_x6_r0_body.s1405.next = 2788957
kernel_rfl PRE_first_tail_x6_r0_body.zgrow145 : Nat.ble PRE_first_tail_x6_r0_body.s1406.next PRE_first_tail_x6_r0_body.s1405.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh145 : PRE_first_tail_x6_r0_body.S1404.tab.all (fun e => PRE_first_tail_x6_r0_body.cws145.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd145 : nodupT PRE_first_tail_x6_r0_body.cws145 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi145 : PRE_first_tail_x6_r0_body.nr145.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S1405.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt145 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s1404.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg145_2665 : PRE_first_tail_x6_r0_body.s1406.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1406 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk145_2665 : (objOf PRE_first_tail_x6_r0_body.s1406 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm145_2665 : PRE_first_tail_x6_r0_body.s1405.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa145.obj (objOf PRE_first_tail_x6_r0_body.s1406 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s1405 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg145_2673467 : PRE_first_tail_x6_r0_body.s1406.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1406 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk145_2673467 : (objOf PRE_first_tail_x6_r0_body.s1406 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm145_2673467 : PRE_first_tail_x6_r0_body.s1405.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa145.obj (objOf PRE_first_tail_x6_r0_body.s1406 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s1405 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw145_4910 : (PRE_first_tail_x6_r0_body.s1406.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw145_2673472 : (PRE_first_tail_x6_r0_body.s1406.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw145_2673473 : (PRE_first_tail_x6_r0_body.s1406.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd145 : PRE_first_tail_x6_r0_body.cl145.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr145 : PRE_first_tail_x6_r0_body.st145.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s1404.next || PRE_first_tail_x6_r0_body.cl145.contains b) = true
def PRE_first_tail_x6_r0_body.zl145 : List Nat := PRE_first_tail_x6_r0_body.cl145.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE145 : PRE_first_tail_x6_r0_body.zl145.map (fun a => PRE_first_tail_x6_r0_body.s1405.heap.get (PRE_first_tail_x6_r0_body.kappa145.a a)) = PRE_first_tail_x6_r0_body.zl145.map (fun a => (PRE_first_tail_x6_r0_body.s1406.heap.get a).map PRE_first_tail_x6_r0_body.kappa145.hobj)
theorem PRE_first_tail_x6_r0_body.zimg145 : HeapImg PRE_first_tail_x6_r0_body.kappa145 PRE_first_tail_x6_r0_body.s1406 PRE_first_tail_x6_r0_body.s1405 PRE_first_tail_x6_r0_body.zl145 := PRE_first_tail_x6_r0_body.zimgE145
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl145 : PRE_first_tail_x6_r0_body.s1405.ctl = PRE_first_tail_x6_r0_body.kappa145.ctl PRE_first_tail_x6_r0_body.s1406.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack145 : PRE_first_tail_x6_r0_body.s1405.stack = PRE_first_tail_x6_r0_body.s1406.stack.map PRE_first_tail_x6_r0_body.kappa145.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs145 : PRE_first_tail_x6_r0_body.s1405.jobs = PRE_first_tail_x6_r0_body.s1406.jobs.map PRE_first_tail_x6_r0_body.kappa145.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores145 : PRE_first_tail_x6_r0_body.s1405.stores = PRE_first_tail_x6_r0_body.kappa145.stores PRE_first_tail_x6_r0_body.s1406.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots145 : checkRootsSupp PRE_first_tail_x6_r0_body.s1406 6278 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC145 : PRE_first_tail_x6_r0_body.S1404.tab.length + PRE_first_tail_x6_r0_body.cws145.length = 6278
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap145 : PRE_first_tail_x6_r0_body.kappa145 = Conv.Map.compact PRE_first_tail_x6_r0_body.s1404.next 2788957 PRE_first_tail_x6_r0_body.S1404.tab.length PRE_first_tail_x6_r0_body.pl145 (PRE_first_tail_x6_r0_body.nr145.map NumV.ref) PRE_first_tail_x6_r0_body.kd145.big
  PRE_first_tail_x6_r0_body.kd145.region PRE_first_tail_x6_r0_body.kd145.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin145 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1406.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc145 : Conv.jcleanListB (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1406 PRE_first_tail_x6_r0_body.cl145 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB145 : noBigRootsP (fun i => !Conv.oldBigB (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s1406.trace PRE_first_tail_x6_r0_body.s1406 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm145 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 18162 = true
theorem PRE_first_tail_x6_r0_body.cjcl145 (h : Conv.JClean (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1404) : Conv.JClean (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1406 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle145)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap145 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd145 a ha)) PRE_first_tail_x6_r0_body.zjc145

end Host.Load.Run.Tpl
end

section -- st145/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st145.bodyLast from PRE_first_tail_x6_r0_body.st145.s1 to PRE_first_tail_x6_r0_body.st145.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st145.F PRE_first_tail_x6_r0_body.st145.s1).run PRE_first_tail_x6_r0_body.st145.S1 = some (PRE_first_tail_x6_r0_body.st145.s2, PRE_first_tail_x6_r0_body.st145.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st145.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st145.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st145.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st145.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st145/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st145.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st145.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st145.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st145.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st145.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st145.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st145.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st145.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st145.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st145.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st145.s0 PRE_first_tail_x6_r0_body.st145.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st145.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st145.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st145.s1 PRE_first_tail_x6_r0_body.st145.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st145/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st145.bodyK0F from PRE_first_tail_x6_r0_body.st145.s0 to PRE_first_tail_x6_r0_body.st145.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st145.F (PRE_first_tail_x6_r0_body.st145.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st145.ks 0).getD 0) PRE_first_tail_x6_r0_body.st145.s0 PRE_first_tail_x6_r0_body.st145.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st145.s1, PRE_first_tail_x6_r0_body.st145.S1)
theorem PRE_first_tail_x6_r0_body.st145.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st145.F (PRE_first_tail_x6_r0_body.st145.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st145.ks 0).getD 0) PRE_first_tail_x6_r0_body.st145.s0 PRE_first_tail_x6_r0_body.st145.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st145.s1, PRE_first_tail_x6_r0_body.st145.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st145.bodyOkLN_ok PRE_first_tail_x6_r0_body.st145.bodyK0F
end Host.Load.Run.Tpl
end

section -- st145/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st145.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st145.F (PRE_first_tail_x6_r0_body.st145.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st145.s0 PRE_first_tail_x6_r0_body.st145.S0 = some (PRE_first_tail_x6_r0_body.st145.s1, PRE_first_tail_x6_r0_body.st145.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st145.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st145.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st145.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st145.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st145.F (PRE_first_tail_x6_r0_body.st145.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st145.s0
  S0 := PRE_first_tail_x6_r0_body.st145.S0
  s1 := PRE_first_tail_x6_r0_body.st145.s1
  S1 := PRE_first_tail_x6_r0_body.st145.S1
  s2 := PRE_first_tail_x6_r0_body.st145.s2
  S2 := PRE_first_tail_x6_r0_body.st145.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st145.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st145.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st145.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st145.bodyHalt
  last := PRE_first_tail_x6_r0_body.st145.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st145.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC146
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 146 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s1410` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa146` into the merged state
`PRE_first_tail_x6_r0_body.s1409`. -/

def PRE_first_tail_x6_r0_body.pl146 : List Nat := [2789262]
def PRE_first_tail_x6_r0_body.nr146 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd146 : RData :=
  ⟨2789244, 2789263, Stage.setAll PTrie.nil [(2789243, 2789262)], Stage.setAll PTrie.nil [],
   21071, 21071, 18166, 18166, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa146 : Map :=
  Conv.Map.compact 2789243 2789263 6295 PRE_first_tail_x6_r0_body.pl146 (PRE_first_tail_x6_r0_body.nr146.map NumV.ref) PRE_first_tail_x6_r0_body.kd146.big
    PRE_first_tail_x6_r0_body.kd146.region PRE_first_tail_x6_r0_body.kd146.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws146 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs146 : List SymE := PRE_first_tail_x6_r0_body.nr146.map fun r => (nth? PRE_first_tail_x6_r0_body.S1409.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta146 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws146 PRE_first_tail_x6_r0_body.crs146
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB146 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab146 : PRE_first_tail_x6_r0_body.S1410.tab = PRE_first_tail_x6_r0_body.S1408.tab ++ PRE_first_tail_x6_r0_body.cws146.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace146 : PRE_first_tail_x6_r0_body.s1410.trace = PRE_first_tail_x6_r0_body.s1408.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext146 : PRE_first_tail_x6_r0_body.s1410.next = 2789244
kernel_rfl PRE_first_tail_x6_r0_body.ccounters146 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1410.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1410.ffi).mlx.nnext) = (21071, 18166)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue146 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1409.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1410.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa146.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp146 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1410.ffi).mlx.tokens.all (bSN 6295) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean146 : Conv.cleanListB 21071 131072 (fun r => Nat.ble 84284 r) PRE_first_tail_x6_r0_body.s1410
    (PRE_first_tail_x6_r0_body.wrB146 ++ (List.range 1).map (2789243 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs146 : bigsOutB 21071 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1410.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK146
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl146`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl146 : List Nat := [2665, 2673467, 2789243]
def PRE_first_tail_x6_r0_body.clo146 : List Nat := []
def PRE_first_tail_x6_r0_body.cln146 : List Nat := []
def PRE_first_tail_x6_r0_body.cli146 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap146 : PRE_first_tail_x6_r0_body.s1410.heap = Stage.setAll PRE_first_tail_x6_r0_body.s1408.heap (PRE_first_tail_x6_r0_body.cl146.filterMap fun a => (PRE_first_tail_x6_r0_body.s1410.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe146 : Nat.ble PRE_first_tail_x6_r0_body.s1408.next PRE_first_tail_x6_r0_body.s1410.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP146 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s1408 PRE_first_tail_x6_r0_body.s1410 PRE_first_tail_x6_r0_body.cl146 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp146 : Conv.suppListB PRE_first_tail_x6_r0_body.s1410 6295 PRE_first_tail_x6_r0_body.cl146 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound146 : Conv.boundListB PRE_first_tail_x6_r0_body.s1410 PRE_first_tail_x6_r0_body.cl146 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK146 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1410.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln146.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1410.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK146 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1410.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo146.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1410.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK146 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1410.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli146.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1410.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst146 : Conv.sstListB 6295 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1410.ffi).mlx PRE_first_tail_x6_r0_body.cln146 PRE_first_tail_x6_r0_body.clo146 PRE_first_tail_x6_r0_body.cli146 = true

end Host.Load.Run.Tpl
end

section -- SiteCl146
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA146 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1410.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo146.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1410.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd146 : (PRE_first_tail_x6_r0_body.clo146 ++ PRE_first_tail_x6_r0_body.cln146 ++ PRE_first_tail_x6_r0_body.cli146).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle146 : Conv.Cnt.leB (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt) (⟨21071, 18166, 2789244, 6295⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck146 : Conv.ncleanListB (⟨21071, 18166, 2789244, 6295⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1410.ffi).mlx PRE_first_tail_x6_r0_body.clo146 PRE_first_tail_x6_r0_body.cln146 PRE_first_tail_x6_r0_body.cli146 = true
theorem PRE_first_tail_x6_r0_body.cncl146 (h : Conv.NClean (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx) : Conv.NClean (⟨21071, 18166, 2789244, 6295⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1410.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle146 PRE_first_tail_x6_r0_body.ckA146 PRE_first_tail_x6_r0_body.cobjsK146 PRE_first_tail_x6_r0_body.cnodesK146 PRE_first_tail_x6_r0_body.citemsK146 PRE_first_tail_x6_r0_body.cbd146 PRE_first_tail_x6_r0_body.cck146

end Host.Load.Run.Tpl
end

section -- SiteS146
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 146 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc146 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P146 : LoadP := PRE_first_tail_x6_r0_body.Pc146.raise 18166
kernel_rfl PRE_first_tail_x6_r0_body.craise146 : Nat.ble PRE_first_tail_x6_r0_body.Pc146.N0 18166 = true
theorem PRE_first_tail_x6_r0_body.raised146 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc146 PRE_first_tail_x6_r0_body.P146 :=
  .inr ⟨18166, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise146, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_146 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1410.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_146 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1409.ffi)
def PRE_first_tail_x6_r0_body.khinv146 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv146 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS146 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS146 : List Nat := List.range' 18166 0
def PRE_first_tail_x6_r0_body.ciS146 : List Nat := [] ++ List.range' 18166 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh0146 : PRE_first_tail_x6_r0_body.kd146.nh0 = PRE_first_tail_x6_r0_body.cx0_146.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh1146 : PRE_first_tail_x6_r0_body.kd146.nh1 = PRE_first_tail_x6_r0_body.cx1_146.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn0146 : PRE_first_tail_x6_r0_body.kd146.nn0 = PRE_first_tail_x6_r0_body.cx0_146.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn1146 : PRE_first_tail_x6_r0_body.kd146.nn1 = PRE_first_tail_x6_r0_body.cx1_146.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo146 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P146.lo && Nat.ble PRE_first_tail_x6_r0_body.P146.lo PRE_first_tail_x6_r0_body.cx0_146.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P146.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P146.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt146 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_146.mlx.next PRE_first_tail_x6_r0_body.cx1_146.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_146.mlx.nnext PRE_first_tail_x6_r0_body.cx1_146.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband146 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P146.NL && Nat.ble PRE_first_tail_x6_r0_body.P146.NL PRE_first_tail_x6_r0_body.P146.N0 && Nat.ble PRE_first_tail_x6_r0_body.P146.N0 PRE_first_tail_x6_r0_body.cx0_146.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow146 : PRE_first_tail_x6_r0_body.kd146.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren146 : checkRenG PRE_first_tail_x6_r0_body.kd146.hnd PRE_first_tail_x6_r0_body.khinv146 (phB PRE_first_tail_x6_r0_body.cx0_146.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband146 : PRE_first_tail_x6_r0_body.kd146.checkBand PRE_first_tail_x6_r0_body.P146.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos146 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd146.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren146 : checkRenG PRE_first_tail_x6_r0_body.kd146.node PRE_first_tail_x6_r0_body.kninv146 (pnB PRE_first_tail_x6_r0_body.cx0_146.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow146 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd146.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P146.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd146.nodeF j) PRE_first_tail_x6_r0_body.cx1_146.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a146 : PRE_first_tail_x6_r0_body.cx0_146.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b146 : PRE_first_tail_x6_r0_body.cx0_146.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok1146 : PRE_first_tail_x6_r0_body.cx1_146.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend146 : PRE_first_tail_x6_r0_body.cx1_146.mlx.pending = PRE_first_tail_x6_r0_body.cx0_146.mlx.pending.map PRE_first_tail_x6_r0_body.kappa146.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh146 : PRE_first_tail_x6_r0_body.cx1_146.mlx.errh = PRE_first_tail_x6_r0_body.cx0_146.mlx.errh.map PRE_first_tail_x6_r0_body.kappa146.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles146 : PRE_first_tail_x6_r0_body.cx1_146.mlx.files = PRE_first_tail_x6_r0_body.cx0_146.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch146 : PRE_first_tail_x6_r0_body.cx1_146.mlx.arch = PRE_first_tail_x6_r0_body.cx0_146.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes146 : PRE_first_tail_x6_r0_body.cx1_146.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_146.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired146 : PRE_first_tail_x6_r0_body.cx1_146.mlx.wired = PRE_first_tail_x6_r0_body.cx0_146.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost146 : PRE_first_tail_x6_r0_body.cx1_146.host = PRE_first_tail_x6_r0_body.cx0_146.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd146`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn0146 : PRE_first_tail_x6_r0_body.kd146.n0 = 2789244
kernel_rfl PRE_first_tail_x6_r0_body.ckn1146 : PRE_first_tail_x6_r0_body.kd146.n1 = 2789263
kernel_rfl PRE_first_tail_x6_r0_body.ckheap146 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd146.heap).all (fun x => Nat.ble 2789243 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl146 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd146.heap.get (2789243 + j) = nth? PRE_first_tail_x6_r0_body.pl146 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja146 : Nat.ble 2789243 2789243 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn146 : Nat.ble 6295 6295 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD146 : Nat.ble 2789243 PRE_first_tail_x6_r0_body.kd146.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn146 : Nat.ble 21071 PRE_first_tail_x6_r0_body.kd146.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn146 : Nat.ble 18166 PRE_first_tail_x6_r0_body.kd146.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb146 : Nat.ble 21071 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap146 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd146.heap).all (Nat.ble (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd146 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd146.hnd).all (Nat.ble (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode146 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd146.node).all (Nat.ble (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix146 : Conv.FixOld (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa146 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja146) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn146) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD146) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn146) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn146) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb146) PRE_first_tail_x6_r0_body.fheap146 PRE_first_tail_x6_r0_body.fhnd146 PRE_first_tail_x6_r0_body.fnode146
kernel_rfl PRE_first_tail_x6_r0_body.fcxn146 : (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn146 : (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle0146 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_146.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_146.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk146 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd146.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A146 : PRE_first_tail_x6_r0_body.cx1_146.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS146.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_146.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O146 : PRE_first_tail_x6_r0_body.cx1_146.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS146.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_146.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N146 : PRE_first_tail_x6_r0_body.cx1_146.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS146.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_146.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I146 : PRE_first_tail_x6_r0_body.cx1_146.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS146.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_146.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd146 : (PRE_first_tail_x6_r0_body.clo146 ++ PRE_first_tail_x6_r0_body.cln146 ++ PRE_first_tail_x6_r0_body.cli146 ++ PRE_first_tail_x6_r0_body.cwS146 ++ PRE_first_tail_x6_r0_body.cnS146 ++ PRE_first_tail_x6_r0_body.ciS146).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW146 : PRE_first_tail_x6_r0_body.cwS146.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo146.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI146 : PRE_first_tail_x6_r0_body.ciS146.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli146.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN146 : PRE_first_tail_x6_r0_body.cnS146.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF146 : PRE_first_tail_x6_r0_body.cln146.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh146 : PRE_first_tail_x6_r0_body.clo146.all (handleOK PRE_first_tail_x6_r0_body.kappa146 PRE_first_tail_x6_r0_body.P146.lo PRE_first_tail_x6_r0_body.cx0_146.mlx PRE_first_tail_x6_r0_body.cx1_146.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo146 : PRE_first_tail_x6_r0_body.clo146.map (fun h => PRE_first_tail_x6_r0_body.cx1_146.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa146.handle h)) = PRE_first_tail_x6_r0_body.clo146.map (fun h => (PRE_first_tail_x6_r0_body.cx0_146.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa146.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok146 : PRE_first_tail_x6_r0_body.clo146.all (objOK PRE_first_tail_x6_r0_body.kappa146 PRE_first_tail_x6_r0_body.P146.NL PRE_first_tail_x6_r0_body.cx0_146.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd146 : PRE_first_tail_x6_r0_body.cln146.all (nodeOKF PRE_first_tail_x6_r0_body.kappa146 PRE_first_tail_x6_r0_body.P146 PRE_first_tail_x6_r0_body.cx0_146.mlx PRE_first_tail_x6_r0_body.cx1_146.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp146 : ((PRE_first_tail_x6_r0_body.cln146.filter (fullB PRE_first_tail_x6_r0_body.P146))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_146.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa146.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln146.filter (fullB PRE_first_tail_x6_r0_body.P146))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_146.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa146.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI146 : incrB PRE_first_tail_x6_r0_body.kd146.nodeF (List.range' 18166 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK146 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd146.node).all (fun k => Nat.ble 18166 k && Nat.blt k 18166) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL146 : (PRE_first_tail_x6_r0_body.cln146.filter (Nat.ble PRE_first_tail_x6_r0_body.P146.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd146.nodeF i) && (Nat.blt i 18166 || Nat.ble PRE_first_tail_x6_r0_body.kd146.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord146 : (PRE_first_tail_x6_r0_body.cln146.filter (Nat.ble PRE_first_tail_x6_r0_body.P146.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd146.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd146.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd146.nodeF j) (PRE_first_tail_x6_r0_body.kd146.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow146 PRE_first_tail_x6_r0_body.cnn1146 PRE_first_tail_x6_r0_body.fnordI146 PRE_first_tail_x6_r0_body.fnordK146 PRE_first_tail_x6_r0_body.fnordL146
kernel_rfl PRE_first_tail_x6_r0_body.fi146 : PRE_first_tail_x6_r0_body.cli146.all (pnB PRE_first_tail_x6_r0_body.cx0_146.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii146 : PRE_first_tail_x6_r0_body.cli146.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_146.mlx.items.get (PRE_first_tail_x6_r0_body.kappa146.node k) = (PRE_first_tail_x6_r0_body.cx0_146.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa146.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot146 (clean : Conv.NClean (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P146.NL) (cl : SSt (· < 6295) PRE_first_tail_x6_r0_body.cx0_146.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P146 6295 PRE_first_tail_x6_r0_body.kappa146 PRE_first_tail_x6_r0_body.kd146 PRE_first_tail_x6_r0_body.khinv146 PRE_first_tail_x6_r0_body.kninv146 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx PRE_first_tail_x6_r0_body.cx0_146.mlx PRE_first_tail_x6_r0_body.cx1_146.mlx (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo146 PRE_first_tail_x6_r0_body.cln146 PRE_first_tail_x6_r0_body.cli146 PRE_first_tail_x6_r0_body.cwS146 PRE_first_tail_x6_r0_body.cnS146 PRE_first_tail_x6_r0_body.ciS146 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh0146, PRE_first_tail_x6_r0_body.cnh1146, PRE_first_tail_x6_r0_body.cnn0146, PRE_first_tail_x6_r0_body.cnn1146, PRE_first_tail_x6_r0_body.cplo146, PRE_first_tail_x6_r0_body.ccnt146, PRE_first_tail_x6_r0_body.cnband146, PRE_first_tail_x6_r0_body.chbelow146, PRE_first_tail_x6_r0_body.chren146, PRE_first_tail_x6_r0_body.cband146, PRE_first_tail_x6_r0_body.cnh1pos146, PRE_first_tail_x6_r0_body.cnren146, PRE_first_tail_x6_r0_body.cnlow146, PRE_first_tail_x6_r0_body.cabs0a146, PRE_first_tail_x6_r0_body.cabs0b146, PRE_first_tail_x6_r0_body.ctok1146, PRE_first_tail_x6_r0_body.cpend146, PRE_first_tail_x6_r0_body.cerrh146, PRE_first_tail_x6_r0_body.cfiles146, PRE_first_tail_x6_r0_body.carch146, PRE_first_tail_x6_r0_body.csizes146, PRE_first_tail_x6_r0_body.cwired146, PRE_first_tail_x6_r0_body.cfix146, clean, PRE_first_tail_x6_r0_body.fcxn146, PRE_first_tail_x6_r0_body.fcnn146, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle0146, PRE_first_tail_x6_r0_body.fnk146, PRE_first_tail_x6_r0_body.ckA146, PRE_first_tail_x6_r0_body.cobjsK146, PRE_first_tail_x6_r0_body.cnodesK146, PRE_first_tail_x6_r0_body.citemsK146, PRE_first_tail_x6_r0_body.f1A146, PRE_first_tail_x6_r0_body.f1O146, PRE_first_tail_x6_r0_body.f1N146, PRE_first_tail_x6_r0_body.f1I146, PRE_first_tail_x6_r0_body.fbd146, PRE_first_tail_x6_r0_body.fincW146, PRE_first_tail_x6_r0_body.fincI146, PRE_first_tail_x6_r0_body.fincN146, PRE_first_tail_x6_r0_body.flnF146, PRE_first_tail_x6_r0_body.fh146, PRE_first_tail_x6_r0_body.fo146, PRE_first_tail_x6_r0_body.fok146, PRE_first_tail_x6_r0_body.fnd146, PRE_first_tail_x6_r0_body.fp146, PRE_first_tail_x6_r0_body.fnord146, PRE_first_tail_x6_r0_body.fi146, PRE_first_tail_x6_r0_body.fii146⟩
theorem PRE_first_tail_x6_r0_body.cnshift146 (clean : Conv.NClean (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P146.NL) (cl : SSt (· < 6295) PRE_first_tail_x6_r0_body.cx0_146.mlx) : NShift PRE_first_tail_x6_r0_body.P146 6295 PRE_first_tail_x6_r0_body.kappa146 PRE_first_tail_x6_r0_body.cx0_146 PRE_first_tail_x6_r0_body.cx1_146 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot146 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost146 (compact_a_eq PRE_first_tail_x6_r0_body.ckn0146 PRE_first_tail_x6_r0_body.ckn1146 PRE_first_tail_x6_r0_body.ckheap146 PRE_first_tail_x6_r0_body.ckpl146)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_146 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1408.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_146 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1408.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_146 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1408.ffi) = some PRE_first_tail_x6_r0_body.fxC_146
kernel_rfl PRE_first_tail_x6_r0_body.okrC_146 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1408.ffi) = some PRE_first_tail_x6_r0_body.krC_146
noncomputable def PRE_first_tail_x6_r0_body.fx0_146 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1410.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_146 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1410.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_146 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1410.ffi) = some PRE_first_tail_x6_r0_body.fx0_146
kernel_rfl PRE_first_tail_x6_r0_body.okr0_146 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1410.ffi) = some PRE_first_tail_x6_r0_body.kr0_146
noncomputable def PRE_first_tail_x6_r0_body.fx1_146 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1409.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_146 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1409.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_146 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1409.ffi) = some PRE_first_tail_x6_r0_body.fx1_146
kernel_rfl PRE_first_tail_x6_r0_body.okr1_146 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1409.ffi) = some PRE_first_tail_x6_r0_body.kr1_146
kernel_rfl PRE_first_tail_x6_r0_body.ff0146 : PRE_first_tail_x6_r0_body.fx0_146 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_146 (PRE_first_tail_x6_r0_body.clo146.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_146.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff1146 : PRE_first_tail_x6_r0_body.fx1_146 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_146 (PRE_first_tail_x6_r0_body.cwS146.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_146.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck146 : freedLB PRE_first_tail_x6_r0_body.kappa146 PRE_first_tail_x6_r0_body.cx0_146.mlx PRE_first_tail_x6_r0_body.fx0_146 PRE_first_tail_x6_r0_body.fx1_146 PRE_first_tail_x6_r0_body.clo146 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf0146 : PRE_first_tail_x6_r0_body.kr0_146.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_146.flags (PRE_first_tail_x6_r0_body.clo146.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_146.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt0146 : PRE_first_tail_x6_r0_body.kr0_146.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_146.targs (PRE_first_tail_x6_r0_body.clo146.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_146.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf1146 : PRE_first_tail_x6_r0_body.kr1_146.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_146.flags (PRE_first_tail_x6_r0_body.cwS146.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_146.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt1146 : PRE_first_tail_x6_r0_body.kr1_146.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_146.targs (PRE_first_tail_x6_r0_body.cwS146.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_146.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck146 : krecLB PRE_first_tail_x6_r0_body.kappa146 6295 PRE_first_tail_x6_r0_body.cx0_146.mlx PRE_first_tail_x6_r0_body.kr0_146 PRE_first_tail_x6_r0_body.kr1_146 PRE_first_tail_x6_r0_body.clo146 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn146 : Nat.ble 6295 6295 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge146 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1409.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1410.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR146 : pendRegB PRE_first_tail_x6_r0_body.kappa146 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1410.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe146 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1410.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1409.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift146 (clean : Conv.NClean (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P146.NL) (cl : SSt (· < 6295) PRE_first_tail_x6_r0_body.cx0_146.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_146.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_146.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_146.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1408.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_146.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P146 6295 PRE_first_tail_x6_r0_body.kappa146 PRE_first_tail_x6_r0_body.s1410.ffi PRE_first_tail_x6_r0_body.s1409.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift146 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue146, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp146 t ht),
    PRE_first_tail_x6_r0_body.cbridge146,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1410.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1409.ffi) (PRE_first_tail_x6_r0_body.cfoot146 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_146 PRE_first_tail_x6_r0_body.ofx1_146 hobjC PRE_first_tail_x6_r0_body.ff0146 PRE_first_tail_x6_r0_body.ff1146 PRE_first_tail_x6_r0_body.ffck146,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1410.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1409.ffi) (PRE_first_tail_x6_r0_body.cfoot146 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_146 PRE_first_tail_x6_r0_body.okr1_146 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn146) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf0146 PRE_first_tail_x6_r0_body.fkt0146 PRE_first_tail_x6_r0_body.fkf1146 PRE_first_tail_x6_r0_body.fkt1146 PRE_first_tail_x6_r0_body.fkck146,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh0146 PRE_first_tail_x6_r0_body.cnh1146 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe146) PRE_first_tail_x6_r0_body.cpendR146⟩

end Host.Load.Run.Tpl
end

section -- st146/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st146 0
host_stream_state PRE_first_tail_x6_r0_body.st146 1
host_stream_state PRE_first_tail_x6_r0_body.st146 2
end Host.Load.Run.Tpl
end

section -- Site146
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 146 of chain `PRE_first_tail_x6_r0_body`: `plan__g146__g147` (`plan`), the call state `PRE_first_tail_x6_r0_body.s1408`, the merged state `PRE_first_tail_x6_r0_body.s1409`,
the site template `PRE_first_tail_x6_r0_body.st146` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s1410`: the merge.
The footprint's facts are in `SiteF146`, the compaction's in `SiteC146`, `SiteK146`, `SiteNa146`, `SiteNb146`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso146 : PRE_first_tail_x6_r0_body.st146.s0 = { PRE_first_tail_x6_r0_body.s1408 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs146 : List Frame := PRE_first_tail_x6_r0_body.s1408.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_146 : PRE_first_tail_x6_r0_body.S1408.tab.length = 6295
kernel_rfl PRE_first_tail_x6_r0_body.tab0_146 : PRE_first_tail_x6_r0_body.st146.S0.tab = PRE_first_tail_x6_r0_body.S1408.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws146 : List Nat := [3451, 3452, 3453, 3454, 3455, 3456, 3457, 3458, 3459]
kernel_rfl PRE_first_tail_x6_r0_body.fresh146 : (PRE_first_tail_x6_r0_body.S1408.tab.all fun e => PRE_first_tail_x6_r0_body.ws146.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S1408.oracle.all fun q => PRE_first_tail_x6_r0_body.ws146.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab146 : PRE_first_tail_x6_r0_body.S1409.tab = PRE_first_tail_x6_r0_body.S1408.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws146
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen146 : PRE_first_tail_x6_r0_body.st146.S2.tab.length - PRE_first_tail_x6_r0_body.st146.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged146`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap146 : PRE_first_tail_x6_r0_body.s1409.heap = PRE_first_tail_x6_r0_body.st146.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext146 : PRE_first_tail_x6_r0_body.s1409.next = PRE_first_tail_x6_r0_body.st146.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl146 : PRE_first_tail_x6_r0_body.s1409.ctl = PRE_first_tail_x6_r0_body.st146.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack146 : PRE_first_tail_x6_r0_body.s1409.stack = PRE_first_tail_x6_r0_body.st146.s2.stack ++ PRE_first_tail_x6_r0_body.s1408.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs146 : PRE_first_tail_x6_r0_body.s1409.jobs = PRE_first_tail_x6_r0_body.st146.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi146 : PRE_first_tail_x6_r0_body.s1409.ffi = PRE_first_tail_x6_r0_body.st146.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace146 : PRE_first_tail_x6_r0_body.s1409.trace = PRE_first_tail_x6_r0_body.st146.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores146 : PRE_first_tail_x6_r0_body.s1409.stores = PRE_first_tail_x6_r0_body.st146.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD146
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 146 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived146 : PRE_first_tail_x6_r0_body.nr146.map (fun r => nth? PRE_first_tail_x6_r0_body.st146.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo146 : PRE_first_tail_x6_r0_body.nr146.all (Nat.ble 6295) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj146 : PRE_first_tail_x6_r0_body.cws146.all (fun c => !PRE_first_tail_x6_r0_body.ws146.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ146 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws146 PRE_first_tail_x6_r0_body.crs146 PRE_first_tail_x6_r0_body.ws146

end Host.Load.Run.Tpl
end

section -- st146/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st146`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st146.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st146.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st146.s2.heap PRE_first_tail_x6_r0_body.st146.wrR ++ freshOf PRE_first_tail_x6_r0_body.st146.s2.heap PRE_first_tail_x6_r0_body.st146.s0.next PRE_first_tail_x6_r0_body.st146.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st146.wr : List Nat := PRE_first_tail_x6_r0_body.st146.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st146.heapFoot : PRE_first_tail_x6_r0_body.st146.s2.heap = setAll PRE_first_tail_x6_r0_body.st146.s0.heap PRE_first_tail_x6_r0_body.st146.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st146.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st146.s0.next PRE_first_tail_x6_r0_body.st146.s2.next = true
theorem PRE_first_tail_x6_r0_body.st146.grows : PRE_first_tail_x6_r0_body.st146.s0.next ≤ PRE_first_tail_x6_r0_body.st146.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st146.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st146.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st146.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st146.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st146.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st146.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st146.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st146.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st146.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st146.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st146.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st146.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st146.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st146.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st146.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st146.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st146.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st146.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st146.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st146.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st146.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st146.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st146.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st146.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st146.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st146.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st146.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st146.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st146.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st146.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st146.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st146.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF146
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 146 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB146 : nodupT PRE_first_tail_x6_r0_body.st146.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup146 : PRE_first_tail_x6_r0_body.st146.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB146).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB146 : PRE_first_tail_x6_r0_body.st146.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound146 : ∀ b ∈ PRE_first_tail_x6_r0_body.st146.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB146 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr146 := PRE_first_tail_x6_r0_body.st146.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq146 : PRE_first_tail_x6_r0_body.st146.s2.trace = PRE_first_tail_x6_r0_body.trFr146 ++ PRE_first_tail_x6_r0_body.st146.s0.trace
theorem PRE_first_tail_x6_r0_body.trace146 : ∃ fr, PRE_first_tail_x6_r0_body.st146.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st146.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq146⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide146 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB146 : (PRE_first_tail_x6_r0_body.wide146.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st146.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix146 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide146, WFix Map.id (Present PRE_first_tail_x6_r0_body.st146.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB146 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL146
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 146 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s1409`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO146 : PRE_first_tail_x6_r0_body.st146.S0.oracle = PRE_first_tail_x6_r0_body.st146.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B146 : PRE_first_tail_x6_r0_body.st146.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st146.s0.next || (PRE_first_tail_x6_r0_body.st146.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot146 : Conv.StageFoot PRE_first_tail_x6_r0_body.st146.wr PRE_first_tail_x6_r0_body.st146.s0 PRE_first_tail_x6_r0_body.st146.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st146.heapFoot PRE_first_tail_x6_r0_body.wrNodup146 PRE_first_tail_x6_r0_body.wrBound146 PRE_first_tail_x6_r0_body.wr0B146 PRE_first_tail_x6_r0_body.st146.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged146 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st146.F.S → PRE_first_tail_x6_r0_body.st146.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st146.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st146.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs146 PRE_first_tail_x6_r0_body.st146.wr PRE_first_tail_x6_r0_body.s1408 PRE_first_tail_x6_r0_body.st146.s2 PRE_first_tail_x6_r0_body.st146.s0
      PRE_first_tail_x6_r0_body.st146.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st146.F FR W stk M ν K PRE_first_tail_x6_r0_body.s1409 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso146 PRE_first_tail_x6_r0_body.stFoot146 PRE_first_tail_x6_r0_body.wrNodup146 PRE_first_tail_x6_r0_body.wrBound146 PRE_first_tail_x6_r0_body.trace146 PRE_first_tail_x6_r0_body.mheap146
    PRE_first_tail_x6_r0_body.mnext146 PRE_first_tail_x6_r0_body.mctl146 PRE_first_tail_x6_r0_body.mstack146 PRE_first_tail_x6_r0_body.mjobs146 PRE_first_tail_x6_r0_body.mffi146 PRE_first_tail_x6_r0_body.mtrace146 PRE_first_tail_x6_r0_body.mstores146 h

def PRE_first_tail_x6_r0_body.arrEl146_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE146_2665 : arrOf PRE_first_tail_x6_r0_body.s1409 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl146_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA146_2665 : isArrB PRE_first_tail_x6_r0_body.s1409 2665 = true
theorem PRE_first_tail_x6_r0_body.arr146_2665 : ∃ o, PRE_first_tail_x6_r0_body.s1409.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl146_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE146_2665 PRE_first_tail_x6_r0_body.arrA146_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN146_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl146_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR146_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl146_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN146_2665

def PRE_first_tail_x6_r0_body.arrEl146_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE146_2673467 : arrOf PRE_first_tail_x6_r0_body.s1409 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl146_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA146_2673467 : isArrB PRE_first_tail_x6_r0_body.s1409 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr146_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s1409.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl146_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE146_2673467 PRE_first_tail_x6_r0_body.arrA146_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN146_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl146_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR146_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl146_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN146_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k146 : isArrB PRE_first_tail_x6_r0_body.s1409 4910 = false
theorem PRE_first_tail_x6_r0_body.keep146 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s1409 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k146 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr146_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl146_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ146
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 146 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s1408`, the merged
state `PRE_first_tail_x6_r0_body.s1409`, the canonical state `PRE_first_tail_x6_r0_body.s1410`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl146 : PRE_first_tail_x6_r0_body.pl146.all (Nat.ble PRE_first_tail_x6_r0_body.s1408.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd146 : nodupT PRE_first_tail_x6_r0_body.pl146 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn1146 : Nat.ble PRE_first_tail_x6_r0_body.s1408.next 2789263 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst146 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s1408.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn146 : PRE_first_tail_x6_r0_body.s1410.next = PRE_first_tail_x6_r0_body.s1408.next + PRE_first_tail_x6_r0_body.pl146.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn146 : PRE_first_tail_x6_r0_body.s1409.next = 2789263
kernel_rfl PRE_first_tail_x6_r0_body.zgrow146 : Nat.ble PRE_first_tail_x6_r0_body.s1410.next PRE_first_tail_x6_r0_body.s1409.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh146 : PRE_first_tail_x6_r0_body.S1408.tab.all (fun e => PRE_first_tail_x6_r0_body.cws146.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd146 : nodupT PRE_first_tail_x6_r0_body.cws146 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi146 : PRE_first_tail_x6_r0_body.nr146.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S1409.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt146 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s1408.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg146_2665 : PRE_first_tail_x6_r0_body.s1410.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1410 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk146_2665 : (objOf PRE_first_tail_x6_r0_body.s1410 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm146_2665 : PRE_first_tail_x6_r0_body.s1409.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa146.obj (objOf PRE_first_tail_x6_r0_body.s1410 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s1409 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg146_2673467 : PRE_first_tail_x6_r0_body.s1410.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1410 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk146_2673467 : (objOf PRE_first_tail_x6_r0_body.s1410 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm146_2673467 : PRE_first_tail_x6_r0_body.s1409.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa146.obj (objOf PRE_first_tail_x6_r0_body.s1410 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s1409 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw146_4910 : (PRE_first_tail_x6_r0_body.s1410.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw146_2673472 : (PRE_first_tail_x6_r0_body.s1410.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw146_2673473 : (PRE_first_tail_x6_r0_body.s1410.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd146 : PRE_first_tail_x6_r0_body.cl146.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr146 : PRE_first_tail_x6_r0_body.st146.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s1408.next || PRE_first_tail_x6_r0_body.cl146.contains b) = true
def PRE_first_tail_x6_r0_body.zl146 : List Nat := PRE_first_tail_x6_r0_body.cl146.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE146 : PRE_first_tail_x6_r0_body.zl146.map (fun a => PRE_first_tail_x6_r0_body.s1409.heap.get (PRE_first_tail_x6_r0_body.kappa146.a a)) = PRE_first_tail_x6_r0_body.zl146.map (fun a => (PRE_first_tail_x6_r0_body.s1410.heap.get a).map PRE_first_tail_x6_r0_body.kappa146.hobj)
theorem PRE_first_tail_x6_r0_body.zimg146 : HeapImg PRE_first_tail_x6_r0_body.kappa146 PRE_first_tail_x6_r0_body.s1410 PRE_first_tail_x6_r0_body.s1409 PRE_first_tail_x6_r0_body.zl146 := PRE_first_tail_x6_r0_body.zimgE146
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl146 : PRE_first_tail_x6_r0_body.s1409.ctl = PRE_first_tail_x6_r0_body.kappa146.ctl PRE_first_tail_x6_r0_body.s1410.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack146 : PRE_first_tail_x6_r0_body.s1409.stack = PRE_first_tail_x6_r0_body.s1410.stack.map PRE_first_tail_x6_r0_body.kappa146.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs146 : PRE_first_tail_x6_r0_body.s1409.jobs = PRE_first_tail_x6_r0_body.s1410.jobs.map PRE_first_tail_x6_r0_body.kappa146.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores146 : PRE_first_tail_x6_r0_body.s1409.stores = PRE_first_tail_x6_r0_body.kappa146.stores PRE_first_tail_x6_r0_body.s1410.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots146 : checkRootsSupp PRE_first_tail_x6_r0_body.s1410 6295 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC146 : PRE_first_tail_x6_r0_body.S1408.tab.length + PRE_first_tail_x6_r0_body.cws146.length = 6295
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap146 : PRE_first_tail_x6_r0_body.kappa146 = Conv.Map.compact PRE_first_tail_x6_r0_body.s1408.next 2789263 PRE_first_tail_x6_r0_body.S1408.tab.length PRE_first_tail_x6_r0_body.pl146 (PRE_first_tail_x6_r0_body.nr146.map NumV.ref) PRE_first_tail_x6_r0_body.kd146.big
  PRE_first_tail_x6_r0_body.kd146.region PRE_first_tail_x6_r0_body.kd146.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin146 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1410.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc146 : Conv.jcleanListB (⟨21071, 18166, 2789244, 6295⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1410 PRE_first_tail_x6_r0_body.cl146 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB146 : noBigRootsP (fun i => !Conv.oldBigB (⟨21071, 18166, 2789244, 6295⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s1410.trace PRE_first_tail_x6_r0_body.s1410 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm146 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 18166 = true
theorem PRE_first_tail_x6_r0_body.cjcl146 (h : Conv.JClean (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1408) : Conv.JClean (⟨21071, 18166, 2789244, 6295⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1410 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle146)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap146 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd146 a ha)) PRE_first_tail_x6_r0_body.zjc146

end Host.Load.Run.Tpl
end

section -- st146/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st146.bodyLast from PRE_first_tail_x6_r0_body.st146.s1 to PRE_first_tail_x6_r0_body.st146.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st146.F PRE_first_tail_x6_r0_body.st146.s1).run PRE_first_tail_x6_r0_body.st146.S1 = some (PRE_first_tail_x6_r0_body.st146.s2, PRE_first_tail_x6_r0_body.st146.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st146.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st146.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st146.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st146.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st146/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st146.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st146.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st146.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st146.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st146.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st146.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st146.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st146.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st146.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st146.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st146.s0 PRE_first_tail_x6_r0_body.st146.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st146.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st146.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st146.s1 PRE_first_tail_x6_r0_body.st146.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st146/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st146.bodyK0F from PRE_first_tail_x6_r0_body.st146.s0 to PRE_first_tail_x6_r0_body.st146.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st146.F (PRE_first_tail_x6_r0_body.st146.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st146.ks 0).getD 0) PRE_first_tail_x6_r0_body.st146.s0 PRE_first_tail_x6_r0_body.st146.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st146.s1, PRE_first_tail_x6_r0_body.st146.S1)
theorem PRE_first_tail_x6_r0_body.st146.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st146.F (PRE_first_tail_x6_r0_body.st146.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st146.ks 0).getD 0) PRE_first_tail_x6_r0_body.st146.s0 PRE_first_tail_x6_r0_body.st146.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st146.s1, PRE_first_tail_x6_r0_body.st146.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st146.bodyOkLN_ok PRE_first_tail_x6_r0_body.st146.bodyK0F
end Host.Load.Run.Tpl
end

section -- st146/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st146.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st146.F (PRE_first_tail_x6_r0_body.st146.bodyOkL bytes rows) 206 PRE_first_tail_x6_r0_body.st146.s0 PRE_first_tail_x6_r0_body.st146.S0 = some (PRE_first_tail_x6_r0_body.st146.s1, PRE_first_tail_x6_r0_body.st146.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st146.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st146.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st146.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st146.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st146.F (PRE_first_tail_x6_r0_body.st146.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st146.s0
  S0 := PRE_first_tail_x6_r0_body.st146.S0
  s1 := PRE_first_tail_x6_r0_body.st146.s1
  S1 := PRE_first_tail_x6_r0_body.st146.S1
  s2 := PRE_first_tail_x6_r0_body.st146.s2
  S2 := PRE_first_tail_x6_r0_body.st146.S2
  n := 206
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st146.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st146.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st146.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st146.bodyHalt
  last := PRE_first_tail_x6_r0_body.st146.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st146.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC147
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 147 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s1427` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa147` into the merged state
`PRE_first_tail_x6_r0_body.s1426`. -/

def PRE_first_tail_x6_r0_body.pl147 : List Nat := [2791831, 2791006, 2791837, 2791833, 2791008, 2791839]
def PRE_first_tail_x6_r0_body.nr147 : List Nat := [6398, 6397, 6373, 6381, 6386, 6391, 6396, 6370, 6371, 6372, 6379, 6380, 6368, 6375, 6376, 6377, 6378, 6374]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd147 : RData :=
  ⟨2790725, 2791874, Stage.setAll PTrie.nil [(2790719, 2791831), (2790720, 2791006), (2790721, 2791837), (2790722, 2791833), (2790723, 2791008), (2790724, 2791839)], Stage.setAll PTrie.nil [(21105, 21131), (21106, 21109), (21107, 21132)],
   21108, 21133, 18212, 18212, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(6368, .ref 6398), (6369, .ref 6397), (6370, .ref 6373), (6371, .ref 6381), (6372, .ref 6386), (6373, .ref 6391), (6374, .ref 6396), (6375, .ref 6370), (6376, .ref 6371), (6377, .ref 6372), (6378, .ref 6379), (6379, .ref 6380), (6380, .ref 6368), (6381, .ref 6375), (6382, .ref 6376), (6383, .ref 6377), (6384, .ref 6378), (6385, .ref 6374)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa147 : Map :=
  Conv.Map.compact 2790719 2791874 6368 PRE_first_tail_x6_r0_body.pl147 (PRE_first_tail_x6_r0_body.nr147.map NumV.ref) PRE_first_tail_x6_r0_body.kd147.big
    PRE_first_tail_x6_r0_body.kd147.region PRE_first_tail_x6_r0_body.kd147.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws147 : List Nat := [3491, 3492, 3493, 3494, 3495, 3496, 3497, 3498, 3499, 3500, 3501, 3502, 3503, 3504, 3505, 3506, 3507, 3508]
noncomputable def PRE_first_tail_x6_r0_body.crs147 : List SymE := PRE_first_tail_x6_r0_body.nr147.map fun r => (nth? PRE_first_tail_x6_r0_body.S1426.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta147 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws147 PRE_first_tail_x6_r0_body.crs147
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB147 : List Nat := [2665, 2672677, 2673467, 2789893, 2790438, 2790694]

kernel_rfl PRE_first_tail_x6_r0_body.ctab147 : PRE_first_tail_x6_r0_body.S1427.tab = PRE_first_tail_x6_r0_body.S1425.tab ++ PRE_first_tail_x6_r0_body.cws147.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace147 : PRE_first_tail_x6_r0_body.s1427.trace = PRE_first_tail_x6_r0_body.s1425.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext147 : PRE_first_tail_x6_r0_body.s1427.next = 2790725
kernel_rfl PRE_first_tail_x6_r0_body.ccounters147 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1427.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1427.ffi).mlx.nnext) = (21108, 18212)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue147 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1426.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1427.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa147.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp147 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1427.ffi).mlx.tokens.all (bSN 6386) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean147 : Conv.cleanListB 21108 131072 (fun r => Nat.ble 84432 r) PRE_first_tail_x6_r0_body.s1427
    (PRE_first_tail_x6_r0_body.wrB147 ++ (List.range 6).map (2790719 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs147 : bigsOutB 21108 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1427.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK147
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl147`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl147 : List Nat := [2665, 2672677, 2673467, 2789893, 2790438, 2790694, 2790719, 2790720, 2790721, 2790722, 2790723, 2790724]
def PRE_first_tail_x6_r0_body.clo147 : List Nat := [21085, 21098, 21104, 21105, 21106, 21107]
def PRE_first_tail_x6_r0_body.cln147 : List Nat := [18185, 18186, 18187, 18188, 18189, 18190, 18191, 18192, 18193, 18194, 18195, 18196, 18197, 18198, 18199, 18200, 18201, 18202, 18203, 18204, 18205, 18206, 18207, 18208, 18209, 18210, 18211]
def PRE_first_tail_x6_r0_body.cli147 : List Nat := [18185, 18186, 18187, 18188, 18189, 18190, 18191, 18192, 18193, 18194, 18195, 18196, 18197, 18198, 18199, 18200, 18201, 18202, 18203, 18204, 18205, 18206, 18207, 18208, 18209, 18210, 18211]
kernel_rfl PRE_first_tail_x6_r0_body.cheap147 : PRE_first_tail_x6_r0_body.s1427.heap = Stage.setAll PRE_first_tail_x6_r0_body.s1425.heap (PRE_first_tail_x6_r0_body.cl147.filterMap fun a => (PRE_first_tail_x6_r0_body.s1427.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe147 : Nat.ble PRE_first_tail_x6_r0_body.s1425.next PRE_first_tail_x6_r0_body.s1427.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP147 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s1425 PRE_first_tail_x6_r0_body.s1427 PRE_first_tail_x6_r0_body.cl147 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp147 : Conv.suppListB PRE_first_tail_x6_r0_body.s1427 6386 PRE_first_tail_x6_r0_body.cl147 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound147 : Conv.boundListB PRE_first_tail_x6_r0_body.s1427 PRE_first_tail_x6_r0_body.cl147 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK147 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1427.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln147.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1427.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK147 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1427.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo147.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1427.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK147 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1427.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli147.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1427.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst147 : Conv.sstListB 6386 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1427.ffi).mlx PRE_first_tail_x6_r0_body.cln147 PRE_first_tail_x6_r0_body.clo147 PRE_first_tail_x6_r0_body.cli147 = true

end Host.Load.Run.Tpl
end

section -- SiteCl147
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA147 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1427.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo147.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1427.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd147 : (PRE_first_tail_x6_r0_body.clo147 ++ PRE_first_tail_x6_r0_body.cln147 ++ PRE_first_tail_x6_r0_body.cli147).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle147 : Conv.Cnt.leB (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt) (⟨21108, 18212, 2790725, 6386⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck147 : Conv.ncleanListB (⟨21108, 18212, 2790725, 6386⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1427.ffi).mlx PRE_first_tail_x6_r0_body.clo147 PRE_first_tail_x6_r0_body.cln147 PRE_first_tail_x6_r0_body.cli147 = true
theorem PRE_first_tail_x6_r0_body.cncl147 (h : Conv.NClean (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx) : Conv.NClean (⟨21108, 18212, 2790725, 6386⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1427.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle147 PRE_first_tail_x6_r0_body.ckA147 PRE_first_tail_x6_r0_body.cobjsK147 PRE_first_tail_x6_r0_body.cnodesK147 PRE_first_tail_x6_r0_body.citemsK147 PRE_first_tail_x6_r0_body.cbd147 PRE_first_tail_x6_r0_body.cck147

end Host.Load.Run.Tpl
end

section -- SiteS147
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 147 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc147 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P147 : LoadP := PRE_first_tail_x6_r0_body.Pc147.raise 18212
kernel_rfl PRE_first_tail_x6_r0_body.craise147 : Nat.ble PRE_first_tail_x6_r0_body.Pc147.N0 18212 = true
theorem PRE_first_tail_x6_r0_body.raised147 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc147 PRE_first_tail_x6_r0_body.P147 :=
  .inr ⟨18212, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise147, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_147 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1427.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_147 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1426.ffi)
def PRE_first_tail_x6_r0_body.khinv147 : PTrie Nat := Stage.setAll PTrie.nil [(21131, 21105), (21109, 21106), (21132, 21107)]
def PRE_first_tail_x6_r0_body.kninv147 : PTrie Nat := Stage.setAll PTrie.nil [(18185, 18185), (18186, 18186), (18187, 18187), (18188, 18188), (18189, 18189), (18190, 18190), (18191, 18191), (18192, 18192), (18193, 18193), (18194, 18194), (18195, 18195), (18196, 18196), (18197, 18197), (18198, 18198), (18199, 18199), (18200, 18200), (18201, 18201), (18202, 18202), (18203, 18203), (18204, 18204), (18205, 18205), (18206, 18206), (18207, 18207), (18208, 18208), (18209, 18209), (18210, 18210), (18211, 18211)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS147 : List Nat := [21085, 21098, 21104, 21105, 21106, 21107, 21108, 21109, 21110, 21111, 21112, 21113, 21114, 21115, 21116, 21117, 21118, 21119, 21120, 21121, 21122, 21123, 21124, 21125, 21126, 21127, 21128, 21129, 21130, 21131, 21132]
def PRE_first_tail_x6_r0_body.cnS147 : List Nat := List.range' 18185 27
def PRE_first_tail_x6_r0_body.ciS147 : List Nat := [] ++ List.range' 18185 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh0147 : PRE_first_tail_x6_r0_body.kd147.nh0 = PRE_first_tail_x6_r0_body.cx0_147.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh1147 : PRE_first_tail_x6_r0_body.kd147.nh1 = PRE_first_tail_x6_r0_body.cx1_147.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn0147 : PRE_first_tail_x6_r0_body.kd147.nn0 = PRE_first_tail_x6_r0_body.cx0_147.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn1147 : PRE_first_tail_x6_r0_body.kd147.nn1 = PRE_first_tail_x6_r0_body.cx1_147.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo147 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P147.lo && Nat.ble PRE_first_tail_x6_r0_body.P147.lo PRE_first_tail_x6_r0_body.cx0_147.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P147.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P147.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt147 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_147.mlx.next PRE_first_tail_x6_r0_body.cx1_147.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_147.mlx.nnext PRE_first_tail_x6_r0_body.cx1_147.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband147 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P147.NL && Nat.ble PRE_first_tail_x6_r0_body.P147.NL PRE_first_tail_x6_r0_body.P147.N0 && Nat.ble PRE_first_tail_x6_r0_body.P147.N0 PRE_first_tail_x6_r0_body.cx0_147.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow147 : PRE_first_tail_x6_r0_body.kd147.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren147 : checkRenG PRE_first_tail_x6_r0_body.kd147.hnd PRE_first_tail_x6_r0_body.khinv147 (phB PRE_first_tail_x6_r0_body.cx0_147.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband147 : PRE_first_tail_x6_r0_body.kd147.checkBand PRE_first_tail_x6_r0_body.P147.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos147 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd147.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren147 : checkRenG PRE_first_tail_x6_r0_body.kd147.node PRE_first_tail_x6_r0_body.kninv147 (pnB PRE_first_tail_x6_r0_body.cx0_147.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow147 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd147.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P147.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd147.nodeF j) PRE_first_tail_x6_r0_body.cx1_147.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a147 : PRE_first_tail_x6_r0_body.cx0_147.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b147 : PRE_first_tail_x6_r0_body.cx0_147.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok1147 : PRE_first_tail_x6_r0_body.cx1_147.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend147 : PRE_first_tail_x6_r0_body.cx1_147.mlx.pending = PRE_first_tail_x6_r0_body.cx0_147.mlx.pending.map PRE_first_tail_x6_r0_body.kappa147.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh147 : PRE_first_tail_x6_r0_body.cx1_147.mlx.errh = PRE_first_tail_x6_r0_body.cx0_147.mlx.errh.map PRE_first_tail_x6_r0_body.kappa147.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles147 : PRE_first_tail_x6_r0_body.cx1_147.mlx.files = PRE_first_tail_x6_r0_body.cx0_147.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch147 : PRE_first_tail_x6_r0_body.cx1_147.mlx.arch = PRE_first_tail_x6_r0_body.cx0_147.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes147 : PRE_first_tail_x6_r0_body.cx1_147.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_147.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired147 : PRE_first_tail_x6_r0_body.cx1_147.mlx.wired = PRE_first_tail_x6_r0_body.cx0_147.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost147 : PRE_first_tail_x6_r0_body.cx1_147.host = PRE_first_tail_x6_r0_body.cx0_147.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd147`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn0147 : PRE_first_tail_x6_r0_body.kd147.n0 = 2790725
kernel_rfl PRE_first_tail_x6_r0_body.ckn1147 : PRE_first_tail_x6_r0_body.kd147.n1 = 2791874
kernel_rfl PRE_first_tail_x6_r0_body.ckheap147 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd147.heap).all (fun x => Nat.ble 2790719 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl147 : (List.range 6).all (fun j => decide (PRE_first_tail_x6_r0_body.kd147.heap.get (2790719 + j) = nth? PRE_first_tail_x6_r0_body.pl147 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja147 : Nat.ble 2790719 2790719 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn147 : Nat.ble 6368 6368 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD147 : Nat.ble 2790719 PRE_first_tail_x6_r0_body.kd147.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn147 : Nat.ble 21105 PRE_first_tail_x6_r0_body.kd147.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn147 : Nat.ble 18185 PRE_first_tail_x6_r0_body.kd147.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb147 : Nat.ble 21105 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap147 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd147.heap).all (Nat.ble (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd147 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd147.hnd).all (Nat.ble (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode147 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd147.node).all (Nat.ble (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix147 : Conv.FixOld (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa147 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja147) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn147) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD147) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn147) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn147) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb147) PRE_first_tail_x6_r0_body.fheap147 PRE_first_tail_x6_r0_body.fhnd147 PRE_first_tail_x6_r0_body.fnode147
kernel_rfl PRE_first_tail_x6_r0_body.fcxn147 : (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn147 : (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle0147 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_147.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_147.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk147 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd147.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A147 : PRE_first_tail_x6_r0_body.cx1_147.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS147.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_147.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O147 : PRE_first_tail_x6_r0_body.cx1_147.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS147.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_147.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N147 : PRE_first_tail_x6_r0_body.cx1_147.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS147.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_147.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I147 : PRE_first_tail_x6_r0_body.cx1_147.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS147.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_147.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd147 : (PRE_first_tail_x6_r0_body.clo147 ++ PRE_first_tail_x6_r0_body.cln147 ++ PRE_first_tail_x6_r0_body.cli147 ++ PRE_first_tail_x6_r0_body.cwS147 ++ PRE_first_tail_x6_r0_body.cnS147 ++ PRE_first_tail_x6_r0_body.ciS147).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW147 : PRE_first_tail_x6_r0_body.cwS147.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo147.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI147 : PRE_first_tail_x6_r0_body.ciS147.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli147.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN147 : PRE_first_tail_x6_r0_body.cnS147.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF147 : PRE_first_tail_x6_r0_body.cln147.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh147 : PRE_first_tail_x6_r0_body.clo147.all (handleOK PRE_first_tail_x6_r0_body.kappa147 PRE_first_tail_x6_r0_body.P147.lo PRE_first_tail_x6_r0_body.cx0_147.mlx PRE_first_tail_x6_r0_body.cx1_147.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo147 : PRE_first_tail_x6_r0_body.clo147.map (fun h => PRE_first_tail_x6_r0_body.cx1_147.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa147.handle h)) = PRE_first_tail_x6_r0_body.clo147.map (fun h => (PRE_first_tail_x6_r0_body.cx0_147.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa147.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok147 : PRE_first_tail_x6_r0_body.clo147.all (objOK PRE_first_tail_x6_r0_body.kappa147 PRE_first_tail_x6_r0_body.P147.NL PRE_first_tail_x6_r0_body.cx0_147.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd147 : PRE_first_tail_x6_r0_body.cln147.all (nodeOKF PRE_first_tail_x6_r0_body.kappa147 PRE_first_tail_x6_r0_body.P147 PRE_first_tail_x6_r0_body.cx0_147.mlx PRE_first_tail_x6_r0_body.cx1_147.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp147 : ((PRE_first_tail_x6_r0_body.cln147.filter (fullB PRE_first_tail_x6_r0_body.P147))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_147.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa147.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln147.filter (fullB PRE_first_tail_x6_r0_body.P147))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_147.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa147.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI147 : incrB PRE_first_tail_x6_r0_body.kd147.nodeF (List.range' 18185 27) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK147 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd147.node).all (fun k => Nat.ble 18185 k && Nat.blt k 18212) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL147 : (PRE_first_tail_x6_r0_body.cln147.filter (Nat.ble PRE_first_tail_x6_r0_body.P147.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd147.nodeF i) && (Nat.blt i 18212 || Nat.ble PRE_first_tail_x6_r0_body.kd147.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord147 : (PRE_first_tail_x6_r0_body.cln147.filter (Nat.ble PRE_first_tail_x6_r0_body.P147.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd147.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd147.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd147.nodeF j) (PRE_first_tail_x6_r0_body.kd147.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow147 PRE_first_tail_x6_r0_body.cnn1147 PRE_first_tail_x6_r0_body.fnordI147 PRE_first_tail_x6_r0_body.fnordK147 PRE_first_tail_x6_r0_body.fnordL147
kernel_rfl PRE_first_tail_x6_r0_body.fi147 : PRE_first_tail_x6_r0_body.cli147.all (pnB PRE_first_tail_x6_r0_body.cx0_147.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii147 : PRE_first_tail_x6_r0_body.cli147.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_147.mlx.items.get (PRE_first_tail_x6_r0_body.kappa147.node k) = (PRE_first_tail_x6_r0_body.cx0_147.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa147.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot147 (clean : Conv.NClean (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P147.NL) (cl : SSt (· < 6386) PRE_first_tail_x6_r0_body.cx0_147.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P147 6386 PRE_first_tail_x6_r0_body.kappa147 PRE_first_tail_x6_r0_body.kd147 PRE_first_tail_x6_r0_body.khinv147 PRE_first_tail_x6_r0_body.kninv147 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx PRE_first_tail_x6_r0_body.cx0_147.mlx PRE_first_tail_x6_r0_body.cx1_147.mlx (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo147 PRE_first_tail_x6_r0_body.cln147 PRE_first_tail_x6_r0_body.cli147 PRE_first_tail_x6_r0_body.cwS147 PRE_first_tail_x6_r0_body.cnS147 PRE_first_tail_x6_r0_body.ciS147 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh0147, PRE_first_tail_x6_r0_body.cnh1147, PRE_first_tail_x6_r0_body.cnn0147, PRE_first_tail_x6_r0_body.cnn1147, PRE_first_tail_x6_r0_body.cplo147, PRE_first_tail_x6_r0_body.ccnt147, PRE_first_tail_x6_r0_body.cnband147, PRE_first_tail_x6_r0_body.chbelow147, PRE_first_tail_x6_r0_body.chren147, PRE_first_tail_x6_r0_body.cband147, PRE_first_tail_x6_r0_body.cnh1pos147, PRE_first_tail_x6_r0_body.cnren147, PRE_first_tail_x6_r0_body.cnlow147, PRE_first_tail_x6_r0_body.cabs0a147, PRE_first_tail_x6_r0_body.cabs0b147, PRE_first_tail_x6_r0_body.ctok1147, PRE_first_tail_x6_r0_body.cpend147, PRE_first_tail_x6_r0_body.cerrh147, PRE_first_tail_x6_r0_body.cfiles147, PRE_first_tail_x6_r0_body.carch147, PRE_first_tail_x6_r0_body.csizes147, PRE_first_tail_x6_r0_body.cwired147, PRE_first_tail_x6_r0_body.cfix147, clean, PRE_first_tail_x6_r0_body.fcxn147, PRE_first_tail_x6_r0_body.fcnn147, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle0147, PRE_first_tail_x6_r0_body.fnk147, PRE_first_tail_x6_r0_body.ckA147, PRE_first_tail_x6_r0_body.cobjsK147, PRE_first_tail_x6_r0_body.cnodesK147, PRE_first_tail_x6_r0_body.citemsK147, PRE_first_tail_x6_r0_body.f1A147, PRE_first_tail_x6_r0_body.f1O147, PRE_first_tail_x6_r0_body.f1N147, PRE_first_tail_x6_r0_body.f1I147, PRE_first_tail_x6_r0_body.fbd147, PRE_first_tail_x6_r0_body.fincW147, PRE_first_tail_x6_r0_body.fincI147, PRE_first_tail_x6_r0_body.fincN147, PRE_first_tail_x6_r0_body.flnF147, PRE_first_tail_x6_r0_body.fh147, PRE_first_tail_x6_r0_body.fo147, PRE_first_tail_x6_r0_body.fok147, PRE_first_tail_x6_r0_body.fnd147, PRE_first_tail_x6_r0_body.fp147, PRE_first_tail_x6_r0_body.fnord147, PRE_first_tail_x6_r0_body.fi147, PRE_first_tail_x6_r0_body.fii147⟩
theorem PRE_first_tail_x6_r0_body.cnshift147 (clean : Conv.NClean (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P147.NL) (cl : SSt (· < 6386) PRE_first_tail_x6_r0_body.cx0_147.mlx) : NShift PRE_first_tail_x6_r0_body.P147 6386 PRE_first_tail_x6_r0_body.kappa147 PRE_first_tail_x6_r0_body.cx0_147 PRE_first_tail_x6_r0_body.cx1_147 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot147 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost147 (compact_a_eq PRE_first_tail_x6_r0_body.ckn0147 PRE_first_tail_x6_r0_body.ckn1147 PRE_first_tail_x6_r0_body.ckheap147 PRE_first_tail_x6_r0_body.ckpl147)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_147 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1425.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_147 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1425.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_147 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1425.ffi) = some PRE_first_tail_x6_r0_body.fxC_147
kernel_rfl PRE_first_tail_x6_r0_body.okrC_147 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1425.ffi) = some PRE_first_tail_x6_r0_body.krC_147
noncomputable def PRE_first_tail_x6_r0_body.fx0_147 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1427.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_147 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1427.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_147 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1427.ffi) = some PRE_first_tail_x6_r0_body.fx0_147
kernel_rfl PRE_first_tail_x6_r0_body.okr0_147 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1427.ffi) = some PRE_first_tail_x6_r0_body.kr0_147
noncomputable def PRE_first_tail_x6_r0_body.fx1_147 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1426.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_147 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1426.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_147 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1426.ffi) = some PRE_first_tail_x6_r0_body.fx1_147
kernel_rfl PRE_first_tail_x6_r0_body.okr1_147 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1426.ffi) = some PRE_first_tail_x6_r0_body.kr1_147
kernel_rfl PRE_first_tail_x6_r0_body.ff0147 : PRE_first_tail_x6_r0_body.fx0_147 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_147 (PRE_first_tail_x6_r0_body.clo147.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_147.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff1147 : PRE_first_tail_x6_r0_body.fx1_147 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_147 (PRE_first_tail_x6_r0_body.cwS147.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_147.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck147 : freedLB PRE_first_tail_x6_r0_body.kappa147 PRE_first_tail_x6_r0_body.cx0_147.mlx PRE_first_tail_x6_r0_body.fx0_147 PRE_first_tail_x6_r0_body.fx1_147 PRE_first_tail_x6_r0_body.clo147 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf0147 : PRE_first_tail_x6_r0_body.kr0_147.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_147.flags (PRE_first_tail_x6_r0_body.clo147.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_147.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt0147 : PRE_first_tail_x6_r0_body.kr0_147.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_147.targs (PRE_first_tail_x6_r0_body.clo147.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_147.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf1147 : PRE_first_tail_x6_r0_body.kr1_147.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_147.flags (PRE_first_tail_x6_r0_body.cwS147.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_147.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt1147 : PRE_first_tail_x6_r0_body.kr1_147.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_147.targs (PRE_first_tail_x6_r0_body.cwS147.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_147.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck147 : krecLB PRE_first_tail_x6_r0_body.kappa147 6386 PRE_first_tail_x6_r0_body.cx0_147.mlx PRE_first_tail_x6_r0_body.kr0_147 PRE_first_tail_x6_r0_body.kr1_147 PRE_first_tail_x6_r0_body.clo147 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn147 : Nat.ble 6368 6386 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge147 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1426.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1427.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR147 : pendRegB PRE_first_tail_x6_r0_body.kappa147 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1427.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe147 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1427.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1426.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift147 (clean : Conv.NClean (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P147.NL) (cl : SSt (· < 6386) PRE_first_tail_x6_r0_body.cx0_147.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_147.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_147.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_147.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1425.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_147.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P147 6386 PRE_first_tail_x6_r0_body.kappa147 PRE_first_tail_x6_r0_body.s1427.ffi PRE_first_tail_x6_r0_body.s1426.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift147 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue147, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp147 t ht),
    PRE_first_tail_x6_r0_body.cbridge147,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1427.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1426.ffi) (PRE_first_tail_x6_r0_body.cfoot147 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_147 PRE_first_tail_x6_r0_body.ofx1_147 hobjC PRE_first_tail_x6_r0_body.ff0147 PRE_first_tail_x6_r0_body.ff1147 PRE_first_tail_x6_r0_body.ffck147,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1427.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1426.ffi) (PRE_first_tail_x6_r0_body.cfoot147 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_147 PRE_first_tail_x6_r0_body.okr1_147 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn147) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf0147 PRE_first_tail_x6_r0_body.fkt0147 PRE_first_tail_x6_r0_body.fkf1147 PRE_first_tail_x6_r0_body.fkt1147 PRE_first_tail_x6_r0_body.fkck147,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh0147 PRE_first_tail_x6_r0_body.cnh1147 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe147) PRE_first_tail_x6_r0_body.cpendR147⟩

end Host.Load.Run.Tpl
end

section -- st147/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st147 0
host_stream_state PRE_first_tail_x6_r0_body.st147 1
host_stream_state PRE_first_tail_x6_r0_body.st147 2
host_stream_state PRE_first_tail_x6_r0_body.st147 3
host_stream_state PRE_first_tail_x6_r0_body.st147 4
host_stream_state PRE_first_tail_x6_r0_body.st147 5
end Host.Load.Run.Tpl
end

section -- Site147
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 147 of chain `PRE_first_tail_x6_r0_body`: `ssmW__g147__g148` (`recurWindow`), the call state `PRE_first_tail_x6_r0_body.s1425`, the merged state `PRE_first_tail_x6_r0_body.s1426`,
the site template `PRE_first_tail_x6_r0_body.st147` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s1427`: the merge.
The footprint's facts are in `SiteF147`, the compaction's in `SiteC147`, `SiteK147`, `SiteNa147`, `SiteNb147`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso147 : PRE_first_tail_x6_r0_body.st147.s0 = { PRE_first_tail_x6_r0_body.s1425 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs147 : List Frame := PRE_first_tail_x6_r0_body.s1425.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_147 : PRE_first_tail_x6_r0_body.S1425.tab.length = 6368
kernel_rfl PRE_first_tail_x6_r0_body.tab0_147 : PRE_first_tail_x6_r0_body.st147.S0.tab = PRE_first_tail_x6_r0_body.S1425.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws147 : List Nat := [3460, 3461, 3462, 3463, 3464, 3465, 3466, 3467, 3468, 3469, 3470, 3471, 3472, 3473, 3474, 3475, 3476, 3477, 3478, 3479, 3480, 3481, 3482, 3483, 3484, 3485, 3486, 3487, 3488, 3489, 3490]
kernel_rfl PRE_first_tail_x6_r0_body.fresh147 : (PRE_first_tail_x6_r0_body.S1425.tab.all fun e => PRE_first_tail_x6_r0_body.ws147.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S1425.oracle.all fun q => PRE_first_tail_x6_r0_body.ws147.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab147 : PRE_first_tail_x6_r0_body.S1426.tab = PRE_first_tail_x6_r0_body.S1425.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws147
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen147 : PRE_first_tail_x6_r0_body.st147.S5.tab.length - PRE_first_tail_x6_r0_body.st147.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged147`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap147 : PRE_first_tail_x6_r0_body.s1426.heap = PRE_first_tail_x6_r0_body.st147.s5.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext147 : PRE_first_tail_x6_r0_body.s1426.next = PRE_first_tail_x6_r0_body.st147.s5.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl147 : PRE_first_tail_x6_r0_body.s1426.ctl = PRE_first_tail_x6_r0_body.st147.s5.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack147 : PRE_first_tail_x6_r0_body.s1426.stack = PRE_first_tail_x6_r0_body.st147.s5.stack ++ PRE_first_tail_x6_r0_body.s1425.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs147 : PRE_first_tail_x6_r0_body.s1426.jobs = PRE_first_tail_x6_r0_body.st147.s5.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi147 : PRE_first_tail_x6_r0_body.s1426.ffi = PRE_first_tail_x6_r0_body.st147.s5.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace147 : PRE_first_tail_x6_r0_body.s1426.trace = PRE_first_tail_x6_r0_body.st147.s5.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores147 : PRE_first_tail_x6_r0_body.s1426.stores = PRE_first_tail_x6_r0_body.st147.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD147
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 147 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived147 : PRE_first_tail_x6_r0_body.nr147.map (fun r => nth? PRE_first_tail_x6_r0_body.st147.S5.tab r) =
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
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo147 : PRE_first_tail_x6_r0_body.nr147.all (Nat.ble 6368) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj147 : PRE_first_tail_x6_r0_body.cws147.all (fun c => !PRE_first_tail_x6_r0_body.ws147.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ147 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws147 PRE_first_tail_x6_r0_body.crs147 PRE_first_tail_x6_r0_body.ws147

end Host.Load.Run.Tpl
end

section -- st147/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st147`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st147.wrR : List (Nat × Nat) := [(2672677, 2672678), (2789893, 2789894), (2790438, 2790439), (2790694, 2790695)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st147.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st147.s5.heap PRE_first_tail_x6_r0_body.st147.wrR ++ freshOf PRE_first_tail_x6_r0_body.st147.s5.heap PRE_first_tail_x6_r0_body.st147.s0.next PRE_first_tail_x6_r0_body.st147.s5.next
noncomputable def PRE_first_tail_x6_r0_body.st147.wr : List Nat := PRE_first_tail_x6_r0_body.st147.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st147.heapFoot : PRE_first_tail_x6_r0_body.st147.s5.heap = setAll PRE_first_tail_x6_r0_body.st147.s0.heap PRE_first_tail_x6_r0_body.st147.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st147.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st147.s0.next PRE_first_tail_x6_r0_body.st147.s5.next = true
theorem PRE_first_tail_x6_r0_body.st147.grows : PRE_first_tail_x6_r0_body.st147.s0.next ≤ PRE_first_tail_x6_r0_body.st147.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st147.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st147.wh : List Nat := [21085, 21098, 21104, 21105, 21106, 21107, 21108, 21109, 21110, 21111, 21112, 21113, 21114, 21115, 21116, 21117, 21118, 21119, 21120, 21121, 21122, 21123, 21124, 21125, 21126, 21127, 21128, 21129, 21130, 21131, 21132]
def PRE_first_tail_x6_r0_body.st147.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st147.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st147.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st147.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st147.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st147.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st147.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st147.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st147.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st147.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st147.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st147.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st147.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st147.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st147.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st147.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st147.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st147.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st147.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st147.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st147.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st147.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st147.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st147.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st147.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st147.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st147.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st147.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st147.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st147.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF147
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 147 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB147 : nodupT PRE_first_tail_x6_r0_body.st147.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup147 : PRE_first_tail_x6_r0_body.st147.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB147).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB147 : PRE_first_tail_x6_r0_body.st147.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound147 : ∀ b ∈ PRE_first_tail_x6_r0_body.st147.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB147 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr147 := PRE_first_tail_x6_r0_body.st147.s5.trace.take 120
kernel_rfl PRE_first_tail_x6_r0_body.traceEq147 : PRE_first_tail_x6_r0_body.st147.s5.trace = PRE_first_tail_x6_r0_body.trFr147 ++ PRE_first_tail_x6_r0_body.st147.s0.trace
theorem PRE_first_tail_x6_r0_body.trace147 : ∃ fr, PRE_first_tail_x6_r0_body.st147.s5.trace = fr ++ PRE_first_tail_x6_r0_body.st147.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq147⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide147 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB147 : (PRE_first_tail_x6_r0_body.wide147.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st147.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix147 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide147, WFix Map.id (Present PRE_first_tail_x6_r0_body.st147.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB147 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL147
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 147 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s1426`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO147 : PRE_first_tail_x6_r0_body.st147.S0.oracle = PRE_first_tail_x6_r0_body.st147.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B147 : PRE_first_tail_x6_r0_body.st147.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st147.s0.next || (PRE_first_tail_x6_r0_body.st147.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot147 : Conv.StageFoot PRE_first_tail_x6_r0_body.st147.wr PRE_first_tail_x6_r0_body.st147.s0 PRE_first_tail_x6_r0_body.st147.s5 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st147.heapFoot PRE_first_tail_x6_r0_body.wrNodup147 PRE_first_tail_x6_r0_body.wrBound147 PRE_first_tail_x6_r0_body.wr0B147 PRE_first_tail_x6_r0_body.st147.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged147 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st147.F.S → PRE_first_tail_x6_r0_body.st147.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st147.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st147.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs147 PRE_first_tail_x6_r0_body.st147.wr PRE_first_tail_x6_r0_body.s1425 PRE_first_tail_x6_r0_body.st147.s5 PRE_first_tail_x6_r0_body.st147.s0
      PRE_first_tail_x6_r0_body.st147.s5.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st147.F FR W stk M ν K PRE_first_tail_x6_r0_body.s1426 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso147 PRE_first_tail_x6_r0_body.stFoot147 PRE_first_tail_x6_r0_body.wrNodup147 PRE_first_tail_x6_r0_body.wrBound147 PRE_first_tail_x6_r0_body.trace147 PRE_first_tail_x6_r0_body.mheap147
    PRE_first_tail_x6_r0_body.mnext147 PRE_first_tail_x6_r0_body.mctl147 PRE_first_tail_x6_r0_body.mstack147 PRE_first_tail_x6_r0_body.mjobs147 PRE_first_tail_x6_r0_body.mffi147 PRE_first_tail_x6_r0_body.mtrace147 PRE_first_tail_x6_r0_body.mstores147 h

def PRE_first_tail_x6_r0_body.arrEl147_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE147_2665 : arrOf PRE_first_tail_x6_r0_body.s1426 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl147_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA147_2665 : isArrB PRE_first_tail_x6_r0_body.s1426 2665 = true
theorem PRE_first_tail_x6_r0_body.arr147_2665 : ∃ o, PRE_first_tail_x6_r0_body.s1426.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl147_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE147_2665 PRE_first_tail_x6_r0_body.arrA147_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN147_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl147_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR147_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl147_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN147_2665

def PRE_first_tail_x6_r0_body.arrEl147_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE147_2673467 : arrOf PRE_first_tail_x6_r0_body.s1426 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl147_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA147_2673467 : isArrB PRE_first_tail_x6_r0_body.s1426 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr147_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s1426.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl147_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE147_2673467 PRE_first_tail_x6_r0_body.arrA147_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN147_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl147_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR147_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl147_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN147_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k147 : isArrB PRE_first_tail_x6_r0_body.s1426 4910 = false
theorem PRE_first_tail_x6_r0_body.keep147 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s1426 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k147 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr147_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl147_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ147
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 147 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s1425`, the merged
state `PRE_first_tail_x6_r0_body.s1426`, the canonical state `PRE_first_tail_x6_r0_body.s1427`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl147 : PRE_first_tail_x6_r0_body.pl147.all (Nat.ble PRE_first_tail_x6_r0_body.s1425.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd147 : nodupT PRE_first_tail_x6_r0_body.pl147 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn1147 : Nat.ble PRE_first_tail_x6_r0_body.s1425.next 2791874 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst147 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s1425.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn147 : PRE_first_tail_x6_r0_body.s1427.next = PRE_first_tail_x6_r0_body.s1425.next + PRE_first_tail_x6_r0_body.pl147.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn147 : PRE_first_tail_x6_r0_body.s1426.next = 2791874
kernel_rfl PRE_first_tail_x6_r0_body.zgrow147 : Nat.ble PRE_first_tail_x6_r0_body.s1427.next PRE_first_tail_x6_r0_body.s1426.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh147 : PRE_first_tail_x6_r0_body.S1425.tab.all (fun e => PRE_first_tail_x6_r0_body.cws147.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd147 : nodupT PRE_first_tail_x6_r0_body.cws147 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi147 : PRE_first_tail_x6_r0_body.nr147.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S1426.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt147 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s1425.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg147_2665 : PRE_first_tail_x6_r0_body.s1427.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1427 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk147_2665 : (objOf PRE_first_tail_x6_r0_body.s1427 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm147_2665 : PRE_first_tail_x6_r0_body.s1426.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa147.obj (objOf PRE_first_tail_x6_r0_body.s1427 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s1426 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg147_2673467 : PRE_first_tail_x6_r0_body.s1427.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1427 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk147_2673467 : (objOf PRE_first_tail_x6_r0_body.s1427 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm147_2673467 : PRE_first_tail_x6_r0_body.s1426.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa147.obj (objOf PRE_first_tail_x6_r0_body.s1427 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s1426 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw147_4910 : (PRE_first_tail_x6_r0_body.s1427.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw147_2673472 : (PRE_first_tail_x6_r0_body.s1427.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw147_2673473 : (PRE_first_tail_x6_r0_body.s1427.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd147 : PRE_first_tail_x6_r0_body.cl147.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr147 : PRE_first_tail_x6_r0_body.st147.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s1425.next || PRE_first_tail_x6_r0_body.cl147.contains b) = true
def PRE_first_tail_x6_r0_body.zl147 : List Nat := PRE_first_tail_x6_r0_body.cl147.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE147 : PRE_first_tail_x6_r0_body.zl147.map (fun a => PRE_first_tail_x6_r0_body.s1426.heap.get (PRE_first_tail_x6_r0_body.kappa147.a a)) = PRE_first_tail_x6_r0_body.zl147.map (fun a => (PRE_first_tail_x6_r0_body.s1427.heap.get a).map PRE_first_tail_x6_r0_body.kappa147.hobj)
theorem PRE_first_tail_x6_r0_body.zimg147 : HeapImg PRE_first_tail_x6_r0_body.kappa147 PRE_first_tail_x6_r0_body.s1427 PRE_first_tail_x6_r0_body.s1426 PRE_first_tail_x6_r0_body.zl147 := PRE_first_tail_x6_r0_body.zimgE147
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl147 : PRE_first_tail_x6_r0_body.s1426.ctl = PRE_first_tail_x6_r0_body.kappa147.ctl PRE_first_tail_x6_r0_body.s1427.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack147 : PRE_first_tail_x6_r0_body.s1426.stack = PRE_first_tail_x6_r0_body.s1427.stack.map PRE_first_tail_x6_r0_body.kappa147.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs147 : PRE_first_tail_x6_r0_body.s1426.jobs = PRE_first_tail_x6_r0_body.s1427.jobs.map PRE_first_tail_x6_r0_body.kappa147.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores147 : PRE_first_tail_x6_r0_body.s1426.stores = PRE_first_tail_x6_r0_body.kappa147.stores PRE_first_tail_x6_r0_body.s1427.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots147 : checkRootsSupp PRE_first_tail_x6_r0_body.s1427 6386 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC147 : PRE_first_tail_x6_r0_body.S1425.tab.length + PRE_first_tail_x6_r0_body.cws147.length = 6386
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap147 : PRE_first_tail_x6_r0_body.kappa147 = Conv.Map.compact PRE_first_tail_x6_r0_body.s1425.next 2791874 PRE_first_tail_x6_r0_body.S1425.tab.length PRE_first_tail_x6_r0_body.pl147 (PRE_first_tail_x6_r0_body.nr147.map NumV.ref) PRE_first_tail_x6_r0_body.kd147.big
  PRE_first_tail_x6_r0_body.kd147.region PRE_first_tail_x6_r0_body.kd147.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin147 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1427.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc147 : Conv.jcleanListB (⟨21108, 18212, 2790725, 6386⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1427 PRE_first_tail_x6_r0_body.cl147 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB147 : noBigRootsP (fun i => !Conv.oldBigB (⟨21108, 18212, 2790725, 6386⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s1427.trace PRE_first_tail_x6_r0_body.s1427 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm147 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 18185 = true
theorem PRE_first_tail_x6_r0_body.cjcl147 (h : Conv.JClean (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1425) : Conv.JClean (⟨21108, 18212, 2790725, 6386⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1427 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle147)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap147 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd147 a ha)) PRE_first_tail_x6_r0_body.zjc147

end Host.Load.Run.Tpl
end

section -- st147/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st147.bodyLast from PRE_first_tail_x6_r0_body.st147.s4 to PRE_first_tail_x6_r0_body.st147.s5 :
  interpS (step PRE_first_tail_x6_r0_body.st147.F PRE_first_tail_x6_r0_body.st147.s4).run PRE_first_tail_x6_r0_body.st147.S4 = some (PRE_first_tail_x6_r0_body.st147.s5, PRE_first_tail_x6_r0_body.st147.S5)
kernel_rfl PRE_first_tail_x6_r0_body.st147.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st147.s4.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st147.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st147.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st147/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st147.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st147.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st147.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st147.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st147.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st147.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st147.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st147.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st147.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st147.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st147.s0 PRE_first_tail_x6_r0_body.st147.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st147.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st147.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st147.s4 PRE_first_tail_x6_r0_body.st147.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st147/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st147.bodyK0F from PRE_first_tail_x6_r0_body.st147.s0 to PRE_first_tail_x6_r0_body.st147.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st147.F (PRE_first_tail_x6_r0_body.st147.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st147.ks 0).getD 0) PRE_first_tail_x6_r0_body.st147.s0 PRE_first_tail_x6_r0_body.st147.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st147.s1, PRE_first_tail_x6_r0_body.st147.S1)
theorem PRE_first_tail_x6_r0_body.st147.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st147.F (PRE_first_tail_x6_r0_body.st147.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st147.ks 0).getD 0) PRE_first_tail_x6_r0_body.st147.s0 PRE_first_tail_x6_r0_body.st147.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st147.s1, PRE_first_tail_x6_r0_body.st147.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st147.bodyOkLN_ok PRE_first_tail_x6_r0_body.st147.bodyK0F
end Host.Load.Run.Tpl
end

section -- st147/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st147.bodyK1F from PRE_first_tail_x6_r0_body.st147.s1 to PRE_first_tail_x6_r0_body.st147.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st147.F (PRE_first_tail_x6_r0_body.st147.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st147.ks 1).getD 0) PRE_first_tail_x6_r0_body.st147.s1 PRE_first_tail_x6_r0_body.st147.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st147.s2, PRE_first_tail_x6_r0_body.st147.S2)
theorem PRE_first_tail_x6_r0_body.st147.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st147.F (PRE_first_tail_x6_r0_body.st147.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st147.ks 1).getD 0) PRE_first_tail_x6_r0_body.st147.s1 PRE_first_tail_x6_r0_body.st147.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st147.s2, PRE_first_tail_x6_r0_body.st147.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st147.bodyOkLN_ok PRE_first_tail_x6_r0_body.st147.bodyK1F
end Host.Load.Run.Tpl
end

section -- st147/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st147.bodyK2F from PRE_first_tail_x6_r0_body.st147.s2 to PRE_first_tail_x6_r0_body.st147.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st147.F (PRE_first_tail_x6_r0_body.st147.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st147.ks 2).getD 0) PRE_first_tail_x6_r0_body.st147.s2 PRE_first_tail_x6_r0_body.st147.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st147.s3, PRE_first_tail_x6_r0_body.st147.S3)
theorem PRE_first_tail_x6_r0_body.st147.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st147.F (PRE_first_tail_x6_r0_body.st147.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st147.ks 2).getD 0) PRE_first_tail_x6_r0_body.st147.s2 PRE_first_tail_x6_r0_body.st147.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st147.s3, PRE_first_tail_x6_r0_body.st147.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st147.bodyOkLN_ok PRE_first_tail_x6_r0_body.st147.bodyK2F
end Host.Load.Run.Tpl
end

section -- st147/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st147.bodyK3F from PRE_first_tail_x6_r0_body.st147.s3 to PRE_first_tail_x6_r0_body.st147.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st147.F (PRE_first_tail_x6_r0_body.st147.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st147.ks 3).getD 0) PRE_first_tail_x6_r0_body.st147.s3 PRE_first_tail_x6_r0_body.st147.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st147.s4, PRE_first_tail_x6_r0_body.st147.S4)
theorem PRE_first_tail_x6_r0_body.st147.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st147.F (PRE_first_tail_x6_r0_body.st147.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st147.ks 3).getD 0) PRE_first_tail_x6_r0_body.st147.s3 PRE_first_tail_x6_r0_body.st147.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st147.s4, PRE_first_tail_x6_r0_body.st147.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st147.bodyOkLN_ok PRE_first_tail_x6_r0_body.st147.bodyK3F
end Host.Load.Run.Tpl
end

section -- st147/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st147.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st147.F (PRE_first_tail_x6_r0_body.st147.bodyOkL bytes rows) 11334 PRE_first_tail_x6_r0_body.st147.s0 PRE_first_tail_x6_r0_body.st147.S0 = some (PRE_first_tail_x6_r0_body.st147.s4, PRE_first_tail_x6_r0_body.st147.S4) :=
  runOk_trans PRE_first_tail_x6_r0_body.st147.F (PRE_first_tail_x6_r0_body.st147.bodyOkL bytes rows) ((((nth? PRE_first_tail_x6_r0_body.st147.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st147.ks 1).getD 0)) + ((nth? PRE_first_tail_x6_r0_body.st147.ks 2).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st147.ks 3).getD 0) PRE_first_tail_x6_r0_body.st147.s0 PRE_first_tail_x6_r0_body.st147.s3 PRE_first_tail_x6_r0_body.st147.s4 PRE_first_tail_x6_r0_body.st147.S0 PRE_first_tail_x6_r0_body.st147.S3 PRE_first_tail_x6_r0_body.st147.S4 (runOk_trans PRE_first_tail_x6_r0_body.st147.F (PRE_first_tail_x6_r0_body.st147.bodyOkL bytes rows) (((nth? PRE_first_tail_x6_r0_body.st147.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st147.ks 1).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st147.ks 2).getD 0) PRE_first_tail_x6_r0_body.st147.s0 PRE_first_tail_x6_r0_body.st147.s2 PRE_first_tail_x6_r0_body.st147.s3 PRE_first_tail_x6_r0_body.st147.S0 PRE_first_tail_x6_r0_body.st147.S2 PRE_first_tail_x6_r0_body.st147.S3 (runOk_trans PRE_first_tail_x6_r0_body.st147.F (PRE_first_tail_x6_r0_body.st147.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st147.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st147.ks 1).getD 0) PRE_first_tail_x6_r0_body.st147.s0 PRE_first_tail_x6_r0_body.st147.s1 PRE_first_tail_x6_r0_body.st147.s2 PRE_first_tail_x6_r0_body.st147.S0 PRE_first_tail_x6_r0_body.st147.S1 PRE_first_tail_x6_r0_body.st147.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st147.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st147.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st147.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st147.bodyK3 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st147.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st147.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st147.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st147.F (PRE_first_tail_x6_r0_body.st147.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st147.s0
  S0 := PRE_first_tail_x6_r0_body.st147.S0
  s1 := PRE_first_tail_x6_r0_body.st147.s4
  S1 := PRE_first_tail_x6_r0_body.st147.S4
  s2 := PRE_first_tail_x6_r0_body.st147.s5
  S2 := PRE_first_tail_x6_r0_body.st147.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st147.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st147.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st147.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st147.bodyHalt
  last := PRE_first_tail_x6_r0_body.st147.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st147.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC148
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 148 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s1435` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa148` into the merged state
`PRE_first_tail_x6_r0_body.s1434`. -/

def PRE_first_tail_x6_r0_body.pl148 : List Nat := []
def PRE_first_tail_x6_r0_body.nr148 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd148 : RData :=
  ⟨2791215, 2791217, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21121, 21121, 18225, 18225, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa148 : Map :=
  Conv.Map.compact 2791215 2791217 6407 PRE_first_tail_x6_r0_body.pl148 (PRE_first_tail_x6_r0_body.nr148.map NumV.ref) PRE_first_tail_x6_r0_body.kd148.big
    PRE_first_tail_x6_r0_body.kd148.region PRE_first_tail_x6_r0_body.kd148.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws148 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs148 : List SymE := PRE_first_tail_x6_r0_body.nr148.map fun r => (nth? PRE_first_tail_x6_r0_body.S1434.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta148 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws148 PRE_first_tail_x6_r0_body.crs148
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB148 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab148 : PRE_first_tail_x6_r0_body.S1435.tab = PRE_first_tail_x6_r0_body.S1433.tab ++ PRE_first_tail_x6_r0_body.cws148.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace148 : PRE_first_tail_x6_r0_body.s1435.trace = PRE_first_tail_x6_r0_body.s1433.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext148 : PRE_first_tail_x6_r0_body.s1435.next = 2791215
kernel_rfl PRE_first_tail_x6_r0_body.ccounters148 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1435.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1435.ffi).mlx.nnext) = (21121, 18225)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue148 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1434.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1435.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa148.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp148 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1435.ffi).mlx.tokens.all (bSN 6407) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean148 : Conv.cleanListB 21121 131072 (fun r => Nat.ble 84484 r) PRE_first_tail_x6_r0_body.s1435
    (PRE_first_tail_x6_r0_body.wrB148 ++ (List.range 0).map (2791215 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs148 : bigsOutB 21121 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1435.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK148
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl148`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl148 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo148 : List Nat := []
def PRE_first_tail_x6_r0_body.cln148 : List Nat := []
def PRE_first_tail_x6_r0_body.cli148 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap148 : PRE_first_tail_x6_r0_body.s1435.heap = Stage.setAll PRE_first_tail_x6_r0_body.s1433.heap (PRE_first_tail_x6_r0_body.cl148.filterMap fun a => (PRE_first_tail_x6_r0_body.s1435.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe148 : Nat.ble PRE_first_tail_x6_r0_body.s1433.next PRE_first_tail_x6_r0_body.s1435.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP148 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s1433 PRE_first_tail_x6_r0_body.s1435 PRE_first_tail_x6_r0_body.cl148 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp148 : Conv.suppListB PRE_first_tail_x6_r0_body.s1435 6407 PRE_first_tail_x6_r0_body.cl148 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound148 : Conv.boundListB PRE_first_tail_x6_r0_body.s1435 PRE_first_tail_x6_r0_body.cl148 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK148 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1435.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln148.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1435.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK148 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1435.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo148.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1435.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK148 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1435.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli148.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1435.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst148 : Conv.sstListB 6407 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1435.ffi).mlx PRE_first_tail_x6_r0_body.cln148 PRE_first_tail_x6_r0_body.clo148 PRE_first_tail_x6_r0_body.cli148 = true

end Host.Load.Run.Tpl
end

section -- SiteCl148
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA148 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1435.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo148.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1435.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd148 : (PRE_first_tail_x6_r0_body.clo148 ++ PRE_first_tail_x6_r0_body.cln148 ++ PRE_first_tail_x6_r0_body.cli148).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle148 : Conv.Cnt.leB (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck148 : Conv.ncleanListB (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1435.ffi).mlx PRE_first_tail_x6_r0_body.clo148 PRE_first_tail_x6_r0_body.cln148 PRE_first_tail_x6_r0_body.cli148 = true
theorem PRE_first_tail_x6_r0_body.cncl148 (h : Conv.NClean (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx) : Conv.NClean (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1435.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle148 PRE_first_tail_x6_r0_body.ckA148 PRE_first_tail_x6_r0_body.cobjsK148 PRE_first_tail_x6_r0_body.cnodesK148 PRE_first_tail_x6_r0_body.citemsK148 PRE_first_tail_x6_r0_body.cbd148 PRE_first_tail_x6_r0_body.cck148

end Host.Load.Run.Tpl
end

section -- SiteS148
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 148 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc148 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P148 : LoadP := PRE_first_tail_x6_r0_body.Pc148.raise 18225
kernel_rfl PRE_first_tail_x6_r0_body.craise148 : Nat.ble PRE_first_tail_x6_r0_body.Pc148.N0 18225 = true
theorem PRE_first_tail_x6_r0_body.raised148 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc148 PRE_first_tail_x6_r0_body.P148 :=
  .inr ⟨18225, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise148, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_148 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1435.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_148 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1434.ffi)
def PRE_first_tail_x6_r0_body.khinv148 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv148 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS148 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS148 : List Nat := List.range' 18225 0
def PRE_first_tail_x6_r0_body.ciS148 : List Nat := [] ++ List.range' 18225 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh0148 : PRE_first_tail_x6_r0_body.kd148.nh0 = PRE_first_tail_x6_r0_body.cx0_148.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh1148 : PRE_first_tail_x6_r0_body.kd148.nh1 = PRE_first_tail_x6_r0_body.cx1_148.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn0148 : PRE_first_tail_x6_r0_body.kd148.nn0 = PRE_first_tail_x6_r0_body.cx0_148.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn1148 : PRE_first_tail_x6_r0_body.kd148.nn1 = PRE_first_tail_x6_r0_body.cx1_148.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo148 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P148.lo && Nat.ble PRE_first_tail_x6_r0_body.P148.lo PRE_first_tail_x6_r0_body.cx0_148.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P148.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P148.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt148 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_148.mlx.next PRE_first_tail_x6_r0_body.cx1_148.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_148.mlx.nnext PRE_first_tail_x6_r0_body.cx1_148.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband148 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P148.NL && Nat.ble PRE_first_tail_x6_r0_body.P148.NL PRE_first_tail_x6_r0_body.P148.N0 && Nat.ble PRE_first_tail_x6_r0_body.P148.N0 PRE_first_tail_x6_r0_body.cx0_148.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow148 : PRE_first_tail_x6_r0_body.kd148.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren148 : checkRenG PRE_first_tail_x6_r0_body.kd148.hnd PRE_first_tail_x6_r0_body.khinv148 (phB PRE_first_tail_x6_r0_body.cx0_148.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband148 : PRE_first_tail_x6_r0_body.kd148.checkBand PRE_first_tail_x6_r0_body.P148.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos148 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd148.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren148 : checkRenG PRE_first_tail_x6_r0_body.kd148.node PRE_first_tail_x6_r0_body.kninv148 (pnB PRE_first_tail_x6_r0_body.cx0_148.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow148 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd148.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P148.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd148.nodeF j) PRE_first_tail_x6_r0_body.cx1_148.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a148 : PRE_first_tail_x6_r0_body.cx0_148.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b148 : PRE_first_tail_x6_r0_body.cx0_148.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok1148 : PRE_first_tail_x6_r0_body.cx1_148.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend148 : PRE_first_tail_x6_r0_body.cx1_148.mlx.pending = PRE_first_tail_x6_r0_body.cx0_148.mlx.pending.map PRE_first_tail_x6_r0_body.kappa148.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh148 : PRE_first_tail_x6_r0_body.cx1_148.mlx.errh = PRE_first_tail_x6_r0_body.cx0_148.mlx.errh.map PRE_first_tail_x6_r0_body.kappa148.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles148 : PRE_first_tail_x6_r0_body.cx1_148.mlx.files = PRE_first_tail_x6_r0_body.cx0_148.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch148 : PRE_first_tail_x6_r0_body.cx1_148.mlx.arch = PRE_first_tail_x6_r0_body.cx0_148.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes148 : PRE_first_tail_x6_r0_body.cx1_148.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_148.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired148 : PRE_first_tail_x6_r0_body.cx1_148.mlx.wired = PRE_first_tail_x6_r0_body.cx0_148.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost148 : PRE_first_tail_x6_r0_body.cx1_148.host = PRE_first_tail_x6_r0_body.cx0_148.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd148`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn0148 : PRE_first_tail_x6_r0_body.kd148.n0 = 2791215
kernel_rfl PRE_first_tail_x6_r0_body.ckn1148 : PRE_first_tail_x6_r0_body.kd148.n1 = 2791217
kernel_rfl PRE_first_tail_x6_r0_body.ckheap148 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd148.heap).all (fun x => Nat.ble 2791215 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl148 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_body.kd148.heap.get (2791215 + j) = nth? PRE_first_tail_x6_r0_body.pl148 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja148 : Nat.ble 2791215 2791215 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn148 : Nat.ble 6407 6407 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD148 : Nat.ble 2791215 PRE_first_tail_x6_r0_body.kd148.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn148 : Nat.ble 21121 PRE_first_tail_x6_r0_body.kd148.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn148 : Nat.ble 18225 PRE_first_tail_x6_r0_body.kd148.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb148 : Nat.ble 21121 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap148 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd148.heap).all (Nat.ble (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd148 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd148.hnd).all (Nat.ble (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode148 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd148.node).all (Nat.ble (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix148 : Conv.FixOld (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa148 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja148) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn148) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD148) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn148) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn148) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb148) PRE_first_tail_x6_r0_body.fheap148 PRE_first_tail_x6_r0_body.fhnd148 PRE_first_tail_x6_r0_body.fnode148
kernel_rfl PRE_first_tail_x6_r0_body.fcxn148 : (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn148 : (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle0148 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_148.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_148.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk148 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd148.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A148 : PRE_first_tail_x6_r0_body.cx1_148.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS148.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_148.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O148 : PRE_first_tail_x6_r0_body.cx1_148.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS148.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_148.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N148 : PRE_first_tail_x6_r0_body.cx1_148.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS148.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_148.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I148 : PRE_first_tail_x6_r0_body.cx1_148.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS148.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_148.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd148 : (PRE_first_tail_x6_r0_body.clo148 ++ PRE_first_tail_x6_r0_body.cln148 ++ PRE_first_tail_x6_r0_body.cli148 ++ PRE_first_tail_x6_r0_body.cwS148 ++ PRE_first_tail_x6_r0_body.cnS148 ++ PRE_first_tail_x6_r0_body.ciS148).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW148 : PRE_first_tail_x6_r0_body.cwS148.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo148.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI148 : PRE_first_tail_x6_r0_body.ciS148.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli148.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN148 : PRE_first_tail_x6_r0_body.cnS148.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF148 : PRE_first_tail_x6_r0_body.cln148.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh148 : PRE_first_tail_x6_r0_body.clo148.all (handleOK PRE_first_tail_x6_r0_body.kappa148 PRE_first_tail_x6_r0_body.P148.lo PRE_first_tail_x6_r0_body.cx0_148.mlx PRE_first_tail_x6_r0_body.cx1_148.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo148 : PRE_first_tail_x6_r0_body.clo148.map (fun h => PRE_first_tail_x6_r0_body.cx1_148.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa148.handle h)) = PRE_first_tail_x6_r0_body.clo148.map (fun h => (PRE_first_tail_x6_r0_body.cx0_148.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa148.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok148 : PRE_first_tail_x6_r0_body.clo148.all (objOK PRE_first_tail_x6_r0_body.kappa148 PRE_first_tail_x6_r0_body.P148.NL PRE_first_tail_x6_r0_body.cx0_148.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd148 : PRE_first_tail_x6_r0_body.cln148.all (nodeOKF PRE_first_tail_x6_r0_body.kappa148 PRE_first_tail_x6_r0_body.P148 PRE_first_tail_x6_r0_body.cx0_148.mlx PRE_first_tail_x6_r0_body.cx1_148.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp148 : ((PRE_first_tail_x6_r0_body.cln148.filter (fullB PRE_first_tail_x6_r0_body.P148))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_148.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa148.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln148.filter (fullB PRE_first_tail_x6_r0_body.P148))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_148.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa148.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI148 : incrB PRE_first_tail_x6_r0_body.kd148.nodeF (List.range' 18225 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK148 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd148.node).all (fun k => Nat.ble 18225 k && Nat.blt k 18225) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL148 : (PRE_first_tail_x6_r0_body.cln148.filter (Nat.ble PRE_first_tail_x6_r0_body.P148.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd148.nodeF i) && (Nat.blt i 18225 || Nat.ble PRE_first_tail_x6_r0_body.kd148.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord148 : (PRE_first_tail_x6_r0_body.cln148.filter (Nat.ble PRE_first_tail_x6_r0_body.P148.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd148.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd148.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd148.nodeF j) (PRE_first_tail_x6_r0_body.kd148.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow148 PRE_first_tail_x6_r0_body.cnn1148 PRE_first_tail_x6_r0_body.fnordI148 PRE_first_tail_x6_r0_body.fnordK148 PRE_first_tail_x6_r0_body.fnordL148
kernel_rfl PRE_first_tail_x6_r0_body.fi148 : PRE_first_tail_x6_r0_body.cli148.all (pnB PRE_first_tail_x6_r0_body.cx0_148.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii148 : PRE_first_tail_x6_r0_body.cli148.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_148.mlx.items.get (PRE_first_tail_x6_r0_body.kappa148.node k) = (PRE_first_tail_x6_r0_body.cx0_148.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa148.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot148 (clean : Conv.NClean (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P148.NL) (cl : SSt (· < 6407) PRE_first_tail_x6_r0_body.cx0_148.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P148 6407 PRE_first_tail_x6_r0_body.kappa148 PRE_first_tail_x6_r0_body.kd148 PRE_first_tail_x6_r0_body.khinv148 PRE_first_tail_x6_r0_body.kninv148 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx PRE_first_tail_x6_r0_body.cx0_148.mlx PRE_first_tail_x6_r0_body.cx1_148.mlx (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo148 PRE_first_tail_x6_r0_body.cln148 PRE_first_tail_x6_r0_body.cli148 PRE_first_tail_x6_r0_body.cwS148 PRE_first_tail_x6_r0_body.cnS148 PRE_first_tail_x6_r0_body.ciS148 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh0148, PRE_first_tail_x6_r0_body.cnh1148, PRE_first_tail_x6_r0_body.cnn0148, PRE_first_tail_x6_r0_body.cnn1148, PRE_first_tail_x6_r0_body.cplo148, PRE_first_tail_x6_r0_body.ccnt148, PRE_first_tail_x6_r0_body.cnband148, PRE_first_tail_x6_r0_body.chbelow148, PRE_first_tail_x6_r0_body.chren148, PRE_first_tail_x6_r0_body.cband148, PRE_first_tail_x6_r0_body.cnh1pos148, PRE_first_tail_x6_r0_body.cnren148, PRE_first_tail_x6_r0_body.cnlow148, PRE_first_tail_x6_r0_body.cabs0a148, PRE_first_tail_x6_r0_body.cabs0b148, PRE_first_tail_x6_r0_body.ctok1148, PRE_first_tail_x6_r0_body.cpend148, PRE_first_tail_x6_r0_body.cerrh148, PRE_first_tail_x6_r0_body.cfiles148, PRE_first_tail_x6_r0_body.carch148, PRE_first_tail_x6_r0_body.csizes148, PRE_first_tail_x6_r0_body.cwired148, PRE_first_tail_x6_r0_body.cfix148, clean, PRE_first_tail_x6_r0_body.fcxn148, PRE_first_tail_x6_r0_body.fcnn148, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle0148, PRE_first_tail_x6_r0_body.fnk148, PRE_first_tail_x6_r0_body.ckA148, PRE_first_tail_x6_r0_body.cobjsK148, PRE_first_tail_x6_r0_body.cnodesK148, PRE_first_tail_x6_r0_body.citemsK148, PRE_first_tail_x6_r0_body.f1A148, PRE_first_tail_x6_r0_body.f1O148, PRE_first_tail_x6_r0_body.f1N148, PRE_first_tail_x6_r0_body.f1I148, PRE_first_tail_x6_r0_body.fbd148, PRE_first_tail_x6_r0_body.fincW148, PRE_first_tail_x6_r0_body.fincI148, PRE_first_tail_x6_r0_body.fincN148, PRE_first_tail_x6_r0_body.flnF148, PRE_first_tail_x6_r0_body.fh148, PRE_first_tail_x6_r0_body.fo148, PRE_first_tail_x6_r0_body.fok148, PRE_first_tail_x6_r0_body.fnd148, PRE_first_tail_x6_r0_body.fp148, PRE_first_tail_x6_r0_body.fnord148, PRE_first_tail_x6_r0_body.fi148, PRE_first_tail_x6_r0_body.fii148⟩
theorem PRE_first_tail_x6_r0_body.cnshift148 (clean : Conv.NClean (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P148.NL) (cl : SSt (· < 6407) PRE_first_tail_x6_r0_body.cx0_148.mlx) : NShift PRE_first_tail_x6_r0_body.P148 6407 PRE_first_tail_x6_r0_body.kappa148 PRE_first_tail_x6_r0_body.cx0_148 PRE_first_tail_x6_r0_body.cx1_148 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot148 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost148 (compact_a_eq PRE_first_tail_x6_r0_body.ckn0148 PRE_first_tail_x6_r0_body.ckn1148 PRE_first_tail_x6_r0_body.ckheap148 PRE_first_tail_x6_r0_body.ckpl148)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_148 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1433.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_148 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1433.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_148 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1433.ffi) = some PRE_first_tail_x6_r0_body.fxC_148
kernel_rfl PRE_first_tail_x6_r0_body.okrC_148 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1433.ffi) = some PRE_first_tail_x6_r0_body.krC_148
noncomputable def PRE_first_tail_x6_r0_body.fx0_148 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1435.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_148 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1435.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_148 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1435.ffi) = some PRE_first_tail_x6_r0_body.fx0_148
kernel_rfl PRE_first_tail_x6_r0_body.okr0_148 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1435.ffi) = some PRE_first_tail_x6_r0_body.kr0_148
noncomputable def PRE_first_tail_x6_r0_body.fx1_148 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1434.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_148 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1434.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_148 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1434.ffi) = some PRE_first_tail_x6_r0_body.fx1_148
kernel_rfl PRE_first_tail_x6_r0_body.okr1_148 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1434.ffi) = some PRE_first_tail_x6_r0_body.kr1_148
kernel_rfl PRE_first_tail_x6_r0_body.ff0148 : PRE_first_tail_x6_r0_body.fx0_148 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_148 (PRE_first_tail_x6_r0_body.clo148.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_148.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff1148 : PRE_first_tail_x6_r0_body.fx1_148 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_148 (PRE_first_tail_x6_r0_body.cwS148.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_148.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck148 : freedLB PRE_first_tail_x6_r0_body.kappa148 PRE_first_tail_x6_r0_body.cx0_148.mlx PRE_first_tail_x6_r0_body.fx0_148 PRE_first_tail_x6_r0_body.fx1_148 PRE_first_tail_x6_r0_body.clo148 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf0148 : PRE_first_tail_x6_r0_body.kr0_148.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_148.flags (PRE_first_tail_x6_r0_body.clo148.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_148.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt0148 : PRE_first_tail_x6_r0_body.kr0_148.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_148.targs (PRE_first_tail_x6_r0_body.clo148.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_148.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf1148 : PRE_first_tail_x6_r0_body.kr1_148.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_148.flags (PRE_first_tail_x6_r0_body.cwS148.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_148.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt1148 : PRE_first_tail_x6_r0_body.kr1_148.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_148.targs (PRE_first_tail_x6_r0_body.cwS148.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_148.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck148 : krecLB PRE_first_tail_x6_r0_body.kappa148 6407 PRE_first_tail_x6_r0_body.cx0_148.mlx PRE_first_tail_x6_r0_body.kr0_148 PRE_first_tail_x6_r0_body.kr1_148 PRE_first_tail_x6_r0_body.clo148 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn148 : Nat.ble 6407 6407 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge148 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1434.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1435.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR148 : pendRegB PRE_first_tail_x6_r0_body.kappa148 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1435.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe148 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1435.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1434.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift148 (clean : Conv.NClean (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P148.NL) (cl : SSt (· < 6407) PRE_first_tail_x6_r0_body.cx0_148.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_148.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_148.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_148.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1433.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_148.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P148 6407 PRE_first_tail_x6_r0_body.kappa148 PRE_first_tail_x6_r0_body.s1435.ffi PRE_first_tail_x6_r0_body.s1434.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift148 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue148, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp148 t ht),
    PRE_first_tail_x6_r0_body.cbridge148,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1435.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1434.ffi) (PRE_first_tail_x6_r0_body.cfoot148 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_148 PRE_first_tail_x6_r0_body.ofx1_148 hobjC PRE_first_tail_x6_r0_body.ff0148 PRE_first_tail_x6_r0_body.ff1148 PRE_first_tail_x6_r0_body.ffck148,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1435.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1434.ffi) (PRE_first_tail_x6_r0_body.cfoot148 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_148 PRE_first_tail_x6_r0_body.okr1_148 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn148) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf0148 PRE_first_tail_x6_r0_body.fkt0148 PRE_first_tail_x6_r0_body.fkf1148 PRE_first_tail_x6_r0_body.fkt1148 PRE_first_tail_x6_r0_body.fkck148,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh0148 PRE_first_tail_x6_r0_body.cnh1148 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe148) PRE_first_tail_x6_r0_body.cpendR148⟩

end Host.Load.Run.Tpl
end

section -- st148/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st148 0
host_stream_state PRE_first_tail_x6_r0_body.st148 1
host_stream_state PRE_first_tail_x6_r0_body.st148 2
end Host.Load.Run.Tpl
end

section -- Site148
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 148 of chain `PRE_first_tail_x6_r0_body`: `rowBlocks__g148__g149` (`rowBlocks`), the call state `PRE_first_tail_x6_r0_body.s1433`, the merged state `PRE_first_tail_x6_r0_body.s1434`,
the site template `PRE_first_tail_x6_r0_body.st148` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s1435`: the merge.
The footprint's facts are in `SiteF148`, the compaction's in `SiteC148`, `SiteK148`, `SiteNa148`, `SiteNb148`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso148 : PRE_first_tail_x6_r0_body.st148.s0 = { PRE_first_tail_x6_r0_body.s1433 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs148 : List Frame := PRE_first_tail_x6_r0_body.s1433.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_148 : PRE_first_tail_x6_r0_body.S1433.tab.length = 6407
kernel_rfl PRE_first_tail_x6_r0_body.tab0_148 : PRE_first_tail_x6_r0_body.st148.S0.tab = PRE_first_tail_x6_r0_body.S1433.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws148 : List Nat := [3509, 3510]
kernel_rfl PRE_first_tail_x6_r0_body.fresh148 : (PRE_first_tail_x6_r0_body.S1433.tab.all fun e => PRE_first_tail_x6_r0_body.ws148.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S1433.oracle.all fun q => PRE_first_tail_x6_r0_body.ws148.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab148 : PRE_first_tail_x6_r0_body.S1434.tab = PRE_first_tail_x6_r0_body.S1433.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws148
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen148 : PRE_first_tail_x6_r0_body.st148.S2.tab.length - PRE_first_tail_x6_r0_body.st148.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged148`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap148 : PRE_first_tail_x6_r0_body.s1434.heap = PRE_first_tail_x6_r0_body.st148.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext148 : PRE_first_tail_x6_r0_body.s1434.next = PRE_first_tail_x6_r0_body.st148.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl148 : PRE_first_tail_x6_r0_body.s1434.ctl = PRE_first_tail_x6_r0_body.st148.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack148 : PRE_first_tail_x6_r0_body.s1434.stack = PRE_first_tail_x6_r0_body.st148.s2.stack ++ PRE_first_tail_x6_r0_body.s1433.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs148 : PRE_first_tail_x6_r0_body.s1434.jobs = PRE_first_tail_x6_r0_body.st148.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi148 : PRE_first_tail_x6_r0_body.s1434.ffi = PRE_first_tail_x6_r0_body.st148.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace148 : PRE_first_tail_x6_r0_body.s1434.trace = PRE_first_tail_x6_r0_body.st148.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores148 : PRE_first_tail_x6_r0_body.s1434.stores = PRE_first_tail_x6_r0_body.st148.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD148
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 148 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived148 : PRE_first_tail_x6_r0_body.nr148.map (fun r => nth? PRE_first_tail_x6_r0_body.st148.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo148 : PRE_first_tail_x6_r0_body.nr148.all (Nat.ble 6407) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj148 : PRE_first_tail_x6_r0_body.cws148.all (fun c => !PRE_first_tail_x6_r0_body.ws148.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ148 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws148 PRE_first_tail_x6_r0_body.crs148 PRE_first_tail_x6_r0_body.ws148

end Host.Load.Run.Tpl
end

section -- st148/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st148`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st148.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st148.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st148.s2.heap PRE_first_tail_x6_r0_body.st148.wrR ++ freshOf PRE_first_tail_x6_r0_body.st148.s2.heap PRE_first_tail_x6_r0_body.st148.s0.next PRE_first_tail_x6_r0_body.st148.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st148.wr : List Nat := PRE_first_tail_x6_r0_body.st148.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st148.heapFoot : PRE_first_tail_x6_r0_body.st148.s2.heap = setAll PRE_first_tail_x6_r0_body.st148.s0.heap PRE_first_tail_x6_r0_body.st148.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st148.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st148.s0.next PRE_first_tail_x6_r0_body.st148.s2.next = true
theorem PRE_first_tail_x6_r0_body.st148.grows : PRE_first_tail_x6_r0_body.st148.s0.next ≤ PRE_first_tail_x6_r0_body.st148.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st148.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st148.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st148.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st148.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st148.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st148.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st148.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st148.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st148.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st148.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st148.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st148.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st148.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st148.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st148.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st148.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st148.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st148.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st148.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st148.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st148.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st148.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st148.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st148.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st148.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st148.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st148.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st148.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st148.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st148.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st148.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st148.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF148
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 148 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB148 : nodupT PRE_first_tail_x6_r0_body.st148.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup148 : PRE_first_tail_x6_r0_body.st148.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB148).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB148 : PRE_first_tail_x6_r0_body.st148.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound148 : ∀ b ∈ PRE_first_tail_x6_r0_body.st148.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB148 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr148 := PRE_first_tail_x6_r0_body.st148.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq148 : PRE_first_tail_x6_r0_body.st148.s2.trace = PRE_first_tail_x6_r0_body.trFr148 ++ PRE_first_tail_x6_r0_body.st148.s0.trace
theorem PRE_first_tail_x6_r0_body.trace148 : ∃ fr, PRE_first_tail_x6_r0_body.st148.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st148.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq148⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide148 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB148 : (PRE_first_tail_x6_r0_body.wide148.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st148.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix148 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide148, WFix Map.id (Present PRE_first_tail_x6_r0_body.st148.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB148 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL148
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 148 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s1434`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO148 : PRE_first_tail_x6_r0_body.st148.S0.oracle = PRE_first_tail_x6_r0_body.st148.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B148 : PRE_first_tail_x6_r0_body.st148.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st148.s0.next || (PRE_first_tail_x6_r0_body.st148.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot148 : Conv.StageFoot PRE_first_tail_x6_r0_body.st148.wr PRE_first_tail_x6_r0_body.st148.s0 PRE_first_tail_x6_r0_body.st148.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st148.heapFoot PRE_first_tail_x6_r0_body.wrNodup148 PRE_first_tail_x6_r0_body.wrBound148 PRE_first_tail_x6_r0_body.wr0B148 PRE_first_tail_x6_r0_body.st148.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged148 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st148.F.S → PRE_first_tail_x6_r0_body.st148.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st148.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st148.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs148 PRE_first_tail_x6_r0_body.st148.wr PRE_first_tail_x6_r0_body.s1433 PRE_first_tail_x6_r0_body.st148.s2 PRE_first_tail_x6_r0_body.st148.s0
      PRE_first_tail_x6_r0_body.st148.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st148.F FR W stk M ν K PRE_first_tail_x6_r0_body.s1434 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso148 PRE_first_tail_x6_r0_body.stFoot148 PRE_first_tail_x6_r0_body.wrNodup148 PRE_first_tail_x6_r0_body.wrBound148 PRE_first_tail_x6_r0_body.trace148 PRE_first_tail_x6_r0_body.mheap148
    PRE_first_tail_x6_r0_body.mnext148 PRE_first_tail_x6_r0_body.mctl148 PRE_first_tail_x6_r0_body.mstack148 PRE_first_tail_x6_r0_body.mjobs148 PRE_first_tail_x6_r0_body.mffi148 PRE_first_tail_x6_r0_body.mtrace148 PRE_first_tail_x6_r0_body.mstores148 h

def PRE_first_tail_x6_r0_body.arrEl148_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE148_2665 : arrOf PRE_first_tail_x6_r0_body.s1434 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl148_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA148_2665 : isArrB PRE_first_tail_x6_r0_body.s1434 2665 = true
theorem PRE_first_tail_x6_r0_body.arr148_2665 : ∃ o, PRE_first_tail_x6_r0_body.s1434.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl148_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE148_2665 PRE_first_tail_x6_r0_body.arrA148_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN148_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl148_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR148_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl148_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN148_2665

def PRE_first_tail_x6_r0_body.arrEl148_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE148_2673467 : arrOf PRE_first_tail_x6_r0_body.s1434 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl148_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA148_2673467 : isArrB PRE_first_tail_x6_r0_body.s1434 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr148_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s1434.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl148_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE148_2673467 PRE_first_tail_x6_r0_body.arrA148_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN148_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl148_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR148_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl148_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN148_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k148 : isArrB PRE_first_tail_x6_r0_body.s1434 4910 = false
theorem PRE_first_tail_x6_r0_body.keep148 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s1434 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k148 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr148_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl148_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ148
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 148 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s1433`, the merged
state `PRE_first_tail_x6_r0_body.s1434`, the canonical state `PRE_first_tail_x6_r0_body.s1435`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl148 : PRE_first_tail_x6_r0_body.pl148.all (Nat.ble PRE_first_tail_x6_r0_body.s1433.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd148 : nodupT PRE_first_tail_x6_r0_body.pl148 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn1148 : Nat.ble PRE_first_tail_x6_r0_body.s1433.next 2791217 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst148 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s1433.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn148 : PRE_first_tail_x6_r0_body.s1435.next = PRE_first_tail_x6_r0_body.s1433.next + PRE_first_tail_x6_r0_body.pl148.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn148 : PRE_first_tail_x6_r0_body.s1434.next = 2791217
kernel_rfl PRE_first_tail_x6_r0_body.zgrow148 : Nat.ble PRE_first_tail_x6_r0_body.s1435.next PRE_first_tail_x6_r0_body.s1434.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh148 : PRE_first_tail_x6_r0_body.S1433.tab.all (fun e => PRE_first_tail_x6_r0_body.cws148.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd148 : nodupT PRE_first_tail_x6_r0_body.cws148 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi148 : PRE_first_tail_x6_r0_body.nr148.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S1434.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt148 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s1433.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg148_2665 : PRE_first_tail_x6_r0_body.s1435.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1435 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk148_2665 : (objOf PRE_first_tail_x6_r0_body.s1435 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm148_2665 : PRE_first_tail_x6_r0_body.s1434.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa148.obj (objOf PRE_first_tail_x6_r0_body.s1435 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s1434 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg148_2673467 : PRE_first_tail_x6_r0_body.s1435.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1435 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk148_2673467 : (objOf PRE_first_tail_x6_r0_body.s1435 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm148_2673467 : PRE_first_tail_x6_r0_body.s1434.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa148.obj (objOf PRE_first_tail_x6_r0_body.s1435 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s1434 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw148_4910 : (PRE_first_tail_x6_r0_body.s1435.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw148_2673472 : (PRE_first_tail_x6_r0_body.s1435.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw148_2673473 : (PRE_first_tail_x6_r0_body.s1435.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd148 : PRE_first_tail_x6_r0_body.cl148.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr148 : PRE_first_tail_x6_r0_body.st148.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s1433.next || PRE_first_tail_x6_r0_body.cl148.contains b) = true
def PRE_first_tail_x6_r0_body.zl148 : List Nat := PRE_first_tail_x6_r0_body.cl148.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE148 : PRE_first_tail_x6_r0_body.zl148.map (fun a => PRE_first_tail_x6_r0_body.s1434.heap.get (PRE_first_tail_x6_r0_body.kappa148.a a)) = PRE_first_tail_x6_r0_body.zl148.map (fun a => (PRE_first_tail_x6_r0_body.s1435.heap.get a).map PRE_first_tail_x6_r0_body.kappa148.hobj)
theorem PRE_first_tail_x6_r0_body.zimg148 : HeapImg PRE_first_tail_x6_r0_body.kappa148 PRE_first_tail_x6_r0_body.s1435 PRE_first_tail_x6_r0_body.s1434 PRE_first_tail_x6_r0_body.zl148 := PRE_first_tail_x6_r0_body.zimgE148
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl148 : PRE_first_tail_x6_r0_body.s1434.ctl = PRE_first_tail_x6_r0_body.kappa148.ctl PRE_first_tail_x6_r0_body.s1435.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack148 : PRE_first_tail_x6_r0_body.s1434.stack = PRE_first_tail_x6_r0_body.s1435.stack.map PRE_first_tail_x6_r0_body.kappa148.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs148 : PRE_first_tail_x6_r0_body.s1434.jobs = PRE_first_tail_x6_r0_body.s1435.jobs.map PRE_first_tail_x6_r0_body.kappa148.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores148 : PRE_first_tail_x6_r0_body.s1434.stores = PRE_first_tail_x6_r0_body.kappa148.stores PRE_first_tail_x6_r0_body.s1435.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots148 : checkRootsSupp PRE_first_tail_x6_r0_body.s1435 6407 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC148 : PRE_first_tail_x6_r0_body.S1433.tab.length + PRE_first_tail_x6_r0_body.cws148.length = 6407
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap148 : PRE_first_tail_x6_r0_body.kappa148 = Conv.Map.compact PRE_first_tail_x6_r0_body.s1433.next 2791217 PRE_first_tail_x6_r0_body.S1433.tab.length PRE_first_tail_x6_r0_body.pl148 (PRE_first_tail_x6_r0_body.nr148.map NumV.ref) PRE_first_tail_x6_r0_body.kd148.big
  PRE_first_tail_x6_r0_body.kd148.region PRE_first_tail_x6_r0_body.kd148.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin148 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1435.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc148 : Conv.jcleanListB (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1435 PRE_first_tail_x6_r0_body.cl148 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB148 : noBigRootsP (fun i => !Conv.oldBigB (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s1435.trace PRE_first_tail_x6_r0_body.s1435 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm148 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 18225 = true
theorem PRE_first_tail_x6_r0_body.cjcl148 (h : Conv.JClean (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1433) : Conv.JClean (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1435 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle148)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap148 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd148 a ha)) PRE_first_tail_x6_r0_body.zjc148

end Host.Load.Run.Tpl
end

section -- st148/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st148.bodyLast from PRE_first_tail_x6_r0_body.st148.s1 to PRE_first_tail_x6_r0_body.st148.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st148.F PRE_first_tail_x6_r0_body.st148.s1).run PRE_first_tail_x6_r0_body.st148.S1 = some (PRE_first_tail_x6_r0_body.st148.s2, PRE_first_tail_x6_r0_body.st148.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st148.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st148.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st148.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st148.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st148/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st148.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st148.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st148.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st148.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st148.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st148.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st148.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st148.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st148.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st148.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st148.s0 PRE_first_tail_x6_r0_body.st148.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st148.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st148.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st148.s1 PRE_first_tail_x6_r0_body.st148.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st148/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st148.bodyK0F from PRE_first_tail_x6_r0_body.st148.s0 to PRE_first_tail_x6_r0_body.st148.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st148.F (PRE_first_tail_x6_r0_body.st148.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st148.ks 0).getD 0) PRE_first_tail_x6_r0_body.st148.s0 PRE_first_tail_x6_r0_body.st148.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st148.s1, PRE_first_tail_x6_r0_body.st148.S1)
theorem PRE_first_tail_x6_r0_body.st148.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st148.F (PRE_first_tail_x6_r0_body.st148.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st148.ks 0).getD 0) PRE_first_tail_x6_r0_body.st148.s0 PRE_first_tail_x6_r0_body.st148.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st148.s1, PRE_first_tail_x6_r0_body.st148.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st148.bodyOkLN_ok PRE_first_tail_x6_r0_body.st148.bodyK0F
end Host.Load.Run.Tpl
end

section -- st148/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st148.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st148.F (PRE_first_tail_x6_r0_body.st148.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st148.s0 PRE_first_tail_x6_r0_body.st148.S0 = some (PRE_first_tail_x6_r0_body.st148.s1, PRE_first_tail_x6_r0_body.st148.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st148.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st148.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st148.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st148.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st148.F (PRE_first_tail_x6_r0_body.st148.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st148.s0
  S0 := PRE_first_tail_x6_r0_body.st148.S0
  s1 := PRE_first_tail_x6_r0_body.st148.s1
  S1 := PRE_first_tail_x6_r0_body.st148.S1
  s2 := PRE_first_tail_x6_r0_body.st148.s2
  S2 := PRE_first_tail_x6_r0_body.st148.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st148.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st148.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st148.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st148.bodyHalt
  last := PRE_first_tail_x6_r0_body.st148.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st148.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC149
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 149 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s1439` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa149` into the merged state
`PRE_first_tail_x6_r0_body.s1438`. -/

def PRE_first_tail_x6_r0_body.pl149 : List Nat := [2791522]
def PRE_first_tail_x6_r0_body.nr149 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd149 : RData :=
  ⟨2791504, 2791523, Stage.setAll PTrie.nil [(2791503, 2791522)], Stage.setAll PTrie.nil [],
   21128, 21128, 18229, 18229, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa149 : Map :=
  Conv.Map.compact 2791503 2791523 6424 PRE_first_tail_x6_r0_body.pl149 (PRE_first_tail_x6_r0_body.nr149.map NumV.ref) PRE_first_tail_x6_r0_body.kd149.big
    PRE_first_tail_x6_r0_body.kd149.region PRE_first_tail_x6_r0_body.kd149.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws149 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs149 : List SymE := PRE_first_tail_x6_r0_body.nr149.map fun r => (nth? PRE_first_tail_x6_r0_body.S1438.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta149 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws149 PRE_first_tail_x6_r0_body.crs149
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB149 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab149 : PRE_first_tail_x6_r0_body.S1439.tab = PRE_first_tail_x6_r0_body.S1437.tab ++ PRE_first_tail_x6_r0_body.cws149.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace149 : PRE_first_tail_x6_r0_body.s1439.trace = PRE_first_tail_x6_r0_body.s1437.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext149 : PRE_first_tail_x6_r0_body.s1439.next = 2791504
kernel_rfl PRE_first_tail_x6_r0_body.ccounters149 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1439.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1439.ffi).mlx.nnext) = (21128, 18229)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue149 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1438.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1439.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa149.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp149 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1439.ffi).mlx.tokens.all (bSN 6424) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean149 : Conv.cleanListB 21128 131072 (fun r => Nat.ble 84512 r) PRE_first_tail_x6_r0_body.s1439
    (PRE_first_tail_x6_r0_body.wrB149 ++ (List.range 1).map (2791503 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs149 : bigsOutB 21128 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1439.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK149
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl149`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl149 : List Nat := [2665, 2673467, 2791503]
def PRE_first_tail_x6_r0_body.clo149 : List Nat := []
def PRE_first_tail_x6_r0_body.cln149 : List Nat := []
def PRE_first_tail_x6_r0_body.cli149 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap149 : PRE_first_tail_x6_r0_body.s1439.heap = Stage.setAll PRE_first_tail_x6_r0_body.s1437.heap (PRE_first_tail_x6_r0_body.cl149.filterMap fun a => (PRE_first_tail_x6_r0_body.s1439.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe149 : Nat.ble PRE_first_tail_x6_r0_body.s1437.next PRE_first_tail_x6_r0_body.s1439.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP149 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s1437 PRE_first_tail_x6_r0_body.s1439 PRE_first_tail_x6_r0_body.cl149 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp149 : Conv.suppListB PRE_first_tail_x6_r0_body.s1439 6424 PRE_first_tail_x6_r0_body.cl149 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound149 : Conv.boundListB PRE_first_tail_x6_r0_body.s1439 PRE_first_tail_x6_r0_body.cl149 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK149 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1439.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln149.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1439.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK149 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1439.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo149.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1439.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK149 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1439.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli149.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1439.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst149 : Conv.sstListB 6424 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1439.ffi).mlx PRE_first_tail_x6_r0_body.cln149 PRE_first_tail_x6_r0_body.clo149 PRE_first_tail_x6_r0_body.cli149 = true

end Host.Load.Run.Tpl
end

section -- SiteCl149
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA149 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1439.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo149.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1439.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd149 : (PRE_first_tail_x6_r0_body.clo149 ++ PRE_first_tail_x6_r0_body.cln149 ++ PRE_first_tail_x6_r0_body.cli149).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle149 : Conv.Cnt.leB (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt) (⟨21128, 18229, 2791504, 6424⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck149 : Conv.ncleanListB (⟨21128, 18229, 2791504, 6424⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1439.ffi).mlx PRE_first_tail_x6_r0_body.clo149 PRE_first_tail_x6_r0_body.cln149 PRE_first_tail_x6_r0_body.cli149 = true
theorem PRE_first_tail_x6_r0_body.cncl149 (h : Conv.NClean (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx) : Conv.NClean (⟨21128, 18229, 2791504, 6424⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1439.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle149 PRE_first_tail_x6_r0_body.ckA149 PRE_first_tail_x6_r0_body.cobjsK149 PRE_first_tail_x6_r0_body.cnodesK149 PRE_first_tail_x6_r0_body.citemsK149 PRE_first_tail_x6_r0_body.cbd149 PRE_first_tail_x6_r0_body.cck149

end Host.Load.Run.Tpl
end

section -- SiteS149
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 149 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc149 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P149 : LoadP := PRE_first_tail_x6_r0_body.Pc149.raise 18229
kernel_rfl PRE_first_tail_x6_r0_body.craise149 : Nat.ble PRE_first_tail_x6_r0_body.Pc149.N0 18229 = true
theorem PRE_first_tail_x6_r0_body.raised149 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc149 PRE_first_tail_x6_r0_body.P149 :=
  .inr ⟨18229, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise149, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_149 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1439.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_149 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1438.ffi)
def PRE_first_tail_x6_r0_body.khinv149 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv149 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS149 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS149 : List Nat := List.range' 18229 0
def PRE_first_tail_x6_r0_body.ciS149 : List Nat := [] ++ List.range' 18229 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh0149 : PRE_first_tail_x6_r0_body.kd149.nh0 = PRE_first_tail_x6_r0_body.cx0_149.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh1149 : PRE_first_tail_x6_r0_body.kd149.nh1 = PRE_first_tail_x6_r0_body.cx1_149.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn0149 : PRE_first_tail_x6_r0_body.kd149.nn0 = PRE_first_tail_x6_r0_body.cx0_149.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn1149 : PRE_first_tail_x6_r0_body.kd149.nn1 = PRE_first_tail_x6_r0_body.cx1_149.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo149 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P149.lo && Nat.ble PRE_first_tail_x6_r0_body.P149.lo PRE_first_tail_x6_r0_body.cx0_149.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P149.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P149.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt149 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_149.mlx.next PRE_first_tail_x6_r0_body.cx1_149.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_149.mlx.nnext PRE_first_tail_x6_r0_body.cx1_149.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband149 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P149.NL && Nat.ble PRE_first_tail_x6_r0_body.P149.NL PRE_first_tail_x6_r0_body.P149.N0 && Nat.ble PRE_first_tail_x6_r0_body.P149.N0 PRE_first_tail_x6_r0_body.cx0_149.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow149 : PRE_first_tail_x6_r0_body.kd149.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren149 : checkRenG PRE_first_tail_x6_r0_body.kd149.hnd PRE_first_tail_x6_r0_body.khinv149 (phB PRE_first_tail_x6_r0_body.cx0_149.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband149 : PRE_first_tail_x6_r0_body.kd149.checkBand PRE_first_tail_x6_r0_body.P149.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos149 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd149.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren149 : checkRenG PRE_first_tail_x6_r0_body.kd149.node PRE_first_tail_x6_r0_body.kninv149 (pnB PRE_first_tail_x6_r0_body.cx0_149.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow149 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd149.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P149.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd149.nodeF j) PRE_first_tail_x6_r0_body.cx1_149.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a149 : PRE_first_tail_x6_r0_body.cx0_149.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b149 : PRE_first_tail_x6_r0_body.cx0_149.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok1149 : PRE_first_tail_x6_r0_body.cx1_149.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend149 : PRE_first_tail_x6_r0_body.cx1_149.mlx.pending = PRE_first_tail_x6_r0_body.cx0_149.mlx.pending.map PRE_first_tail_x6_r0_body.kappa149.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh149 : PRE_first_tail_x6_r0_body.cx1_149.mlx.errh = PRE_first_tail_x6_r0_body.cx0_149.mlx.errh.map PRE_first_tail_x6_r0_body.kappa149.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles149 : PRE_first_tail_x6_r0_body.cx1_149.mlx.files = PRE_first_tail_x6_r0_body.cx0_149.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch149 : PRE_first_tail_x6_r0_body.cx1_149.mlx.arch = PRE_first_tail_x6_r0_body.cx0_149.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes149 : PRE_first_tail_x6_r0_body.cx1_149.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_149.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired149 : PRE_first_tail_x6_r0_body.cx1_149.mlx.wired = PRE_first_tail_x6_r0_body.cx0_149.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost149 : PRE_first_tail_x6_r0_body.cx1_149.host = PRE_first_tail_x6_r0_body.cx0_149.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd149`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn0149 : PRE_first_tail_x6_r0_body.kd149.n0 = 2791504
kernel_rfl PRE_first_tail_x6_r0_body.ckn1149 : PRE_first_tail_x6_r0_body.kd149.n1 = 2791523
kernel_rfl PRE_first_tail_x6_r0_body.ckheap149 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd149.heap).all (fun x => Nat.ble 2791503 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl149 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd149.heap.get (2791503 + j) = nth? PRE_first_tail_x6_r0_body.pl149 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja149 : Nat.ble 2791503 2791503 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn149 : Nat.ble 6424 6424 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD149 : Nat.ble 2791503 PRE_first_tail_x6_r0_body.kd149.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn149 : Nat.ble 21128 PRE_first_tail_x6_r0_body.kd149.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn149 : Nat.ble 18229 PRE_first_tail_x6_r0_body.kd149.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb149 : Nat.ble 21128 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap149 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd149.heap).all (Nat.ble (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd149 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd149.hnd).all (Nat.ble (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode149 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd149.node).all (Nat.ble (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix149 : Conv.FixOld (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa149 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja149) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn149) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD149) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn149) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn149) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb149) PRE_first_tail_x6_r0_body.fheap149 PRE_first_tail_x6_r0_body.fhnd149 PRE_first_tail_x6_r0_body.fnode149
kernel_rfl PRE_first_tail_x6_r0_body.fcxn149 : (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn149 : (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle0149 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_149.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_149.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk149 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd149.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A149 : PRE_first_tail_x6_r0_body.cx1_149.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS149.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_149.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O149 : PRE_first_tail_x6_r0_body.cx1_149.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS149.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_149.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N149 : PRE_first_tail_x6_r0_body.cx1_149.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS149.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_149.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I149 : PRE_first_tail_x6_r0_body.cx1_149.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS149.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_149.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd149 : (PRE_first_tail_x6_r0_body.clo149 ++ PRE_first_tail_x6_r0_body.cln149 ++ PRE_first_tail_x6_r0_body.cli149 ++ PRE_first_tail_x6_r0_body.cwS149 ++ PRE_first_tail_x6_r0_body.cnS149 ++ PRE_first_tail_x6_r0_body.ciS149).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW149 : PRE_first_tail_x6_r0_body.cwS149.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo149.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI149 : PRE_first_tail_x6_r0_body.ciS149.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli149.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN149 : PRE_first_tail_x6_r0_body.cnS149.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF149 : PRE_first_tail_x6_r0_body.cln149.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh149 : PRE_first_tail_x6_r0_body.clo149.all (handleOK PRE_first_tail_x6_r0_body.kappa149 PRE_first_tail_x6_r0_body.P149.lo PRE_first_tail_x6_r0_body.cx0_149.mlx PRE_first_tail_x6_r0_body.cx1_149.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo149 : PRE_first_tail_x6_r0_body.clo149.map (fun h => PRE_first_tail_x6_r0_body.cx1_149.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa149.handle h)) = PRE_first_tail_x6_r0_body.clo149.map (fun h => (PRE_first_tail_x6_r0_body.cx0_149.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa149.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok149 : PRE_first_tail_x6_r0_body.clo149.all (objOK PRE_first_tail_x6_r0_body.kappa149 PRE_first_tail_x6_r0_body.P149.NL PRE_first_tail_x6_r0_body.cx0_149.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd149 : PRE_first_tail_x6_r0_body.cln149.all (nodeOKF PRE_first_tail_x6_r0_body.kappa149 PRE_first_tail_x6_r0_body.P149 PRE_first_tail_x6_r0_body.cx0_149.mlx PRE_first_tail_x6_r0_body.cx1_149.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp149 : ((PRE_first_tail_x6_r0_body.cln149.filter (fullB PRE_first_tail_x6_r0_body.P149))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_149.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa149.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln149.filter (fullB PRE_first_tail_x6_r0_body.P149))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_149.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa149.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI149 : incrB PRE_first_tail_x6_r0_body.kd149.nodeF (List.range' 18229 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK149 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd149.node).all (fun k => Nat.ble 18229 k && Nat.blt k 18229) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL149 : (PRE_first_tail_x6_r0_body.cln149.filter (Nat.ble PRE_first_tail_x6_r0_body.P149.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd149.nodeF i) && (Nat.blt i 18229 || Nat.ble PRE_first_tail_x6_r0_body.kd149.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord149 : (PRE_first_tail_x6_r0_body.cln149.filter (Nat.ble PRE_first_tail_x6_r0_body.P149.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd149.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd149.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd149.nodeF j) (PRE_first_tail_x6_r0_body.kd149.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow149 PRE_first_tail_x6_r0_body.cnn1149 PRE_first_tail_x6_r0_body.fnordI149 PRE_first_tail_x6_r0_body.fnordK149 PRE_first_tail_x6_r0_body.fnordL149
kernel_rfl PRE_first_tail_x6_r0_body.fi149 : PRE_first_tail_x6_r0_body.cli149.all (pnB PRE_first_tail_x6_r0_body.cx0_149.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii149 : PRE_first_tail_x6_r0_body.cli149.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_149.mlx.items.get (PRE_first_tail_x6_r0_body.kappa149.node k) = (PRE_first_tail_x6_r0_body.cx0_149.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa149.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot149 (clean : Conv.NClean (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P149.NL) (cl : SSt (· < 6424) PRE_first_tail_x6_r0_body.cx0_149.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P149 6424 PRE_first_tail_x6_r0_body.kappa149 PRE_first_tail_x6_r0_body.kd149 PRE_first_tail_x6_r0_body.khinv149 PRE_first_tail_x6_r0_body.kninv149 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx PRE_first_tail_x6_r0_body.cx0_149.mlx PRE_first_tail_x6_r0_body.cx1_149.mlx (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo149 PRE_first_tail_x6_r0_body.cln149 PRE_first_tail_x6_r0_body.cli149 PRE_first_tail_x6_r0_body.cwS149 PRE_first_tail_x6_r0_body.cnS149 PRE_first_tail_x6_r0_body.ciS149 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh0149, PRE_first_tail_x6_r0_body.cnh1149, PRE_first_tail_x6_r0_body.cnn0149, PRE_first_tail_x6_r0_body.cnn1149, PRE_first_tail_x6_r0_body.cplo149, PRE_first_tail_x6_r0_body.ccnt149, PRE_first_tail_x6_r0_body.cnband149, PRE_first_tail_x6_r0_body.chbelow149, PRE_first_tail_x6_r0_body.chren149, PRE_first_tail_x6_r0_body.cband149, PRE_first_tail_x6_r0_body.cnh1pos149, PRE_first_tail_x6_r0_body.cnren149, PRE_first_tail_x6_r0_body.cnlow149, PRE_first_tail_x6_r0_body.cabs0a149, PRE_first_tail_x6_r0_body.cabs0b149, PRE_first_tail_x6_r0_body.ctok1149, PRE_first_tail_x6_r0_body.cpend149, PRE_first_tail_x6_r0_body.cerrh149, PRE_first_tail_x6_r0_body.cfiles149, PRE_first_tail_x6_r0_body.carch149, PRE_first_tail_x6_r0_body.csizes149, PRE_first_tail_x6_r0_body.cwired149, PRE_first_tail_x6_r0_body.cfix149, clean, PRE_first_tail_x6_r0_body.fcxn149, PRE_first_tail_x6_r0_body.fcnn149, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle0149, PRE_first_tail_x6_r0_body.fnk149, PRE_first_tail_x6_r0_body.ckA149, PRE_first_tail_x6_r0_body.cobjsK149, PRE_first_tail_x6_r0_body.cnodesK149, PRE_first_tail_x6_r0_body.citemsK149, PRE_first_tail_x6_r0_body.f1A149, PRE_first_tail_x6_r0_body.f1O149, PRE_first_tail_x6_r0_body.f1N149, PRE_first_tail_x6_r0_body.f1I149, PRE_first_tail_x6_r0_body.fbd149, PRE_first_tail_x6_r0_body.fincW149, PRE_first_tail_x6_r0_body.fincI149, PRE_first_tail_x6_r0_body.fincN149, PRE_first_tail_x6_r0_body.flnF149, PRE_first_tail_x6_r0_body.fh149, PRE_first_tail_x6_r0_body.fo149, PRE_first_tail_x6_r0_body.fok149, PRE_first_tail_x6_r0_body.fnd149, PRE_first_tail_x6_r0_body.fp149, PRE_first_tail_x6_r0_body.fnord149, PRE_first_tail_x6_r0_body.fi149, PRE_first_tail_x6_r0_body.fii149⟩
theorem PRE_first_tail_x6_r0_body.cnshift149 (clean : Conv.NClean (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P149.NL) (cl : SSt (· < 6424) PRE_first_tail_x6_r0_body.cx0_149.mlx) : NShift PRE_first_tail_x6_r0_body.P149 6424 PRE_first_tail_x6_r0_body.kappa149 PRE_first_tail_x6_r0_body.cx0_149 PRE_first_tail_x6_r0_body.cx1_149 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot149 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost149 (compact_a_eq PRE_first_tail_x6_r0_body.ckn0149 PRE_first_tail_x6_r0_body.ckn1149 PRE_first_tail_x6_r0_body.ckheap149 PRE_first_tail_x6_r0_body.ckpl149)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_149 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1437.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_149 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1437.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_149 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1437.ffi) = some PRE_first_tail_x6_r0_body.fxC_149
kernel_rfl PRE_first_tail_x6_r0_body.okrC_149 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1437.ffi) = some PRE_first_tail_x6_r0_body.krC_149
noncomputable def PRE_first_tail_x6_r0_body.fx0_149 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1439.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_149 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1439.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_149 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1439.ffi) = some PRE_first_tail_x6_r0_body.fx0_149
kernel_rfl PRE_first_tail_x6_r0_body.okr0_149 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1439.ffi) = some PRE_first_tail_x6_r0_body.kr0_149
noncomputable def PRE_first_tail_x6_r0_body.fx1_149 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1438.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_149 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1438.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_149 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1438.ffi) = some PRE_first_tail_x6_r0_body.fx1_149
kernel_rfl PRE_first_tail_x6_r0_body.okr1_149 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1438.ffi) = some PRE_first_tail_x6_r0_body.kr1_149
kernel_rfl PRE_first_tail_x6_r0_body.ff0149 : PRE_first_tail_x6_r0_body.fx0_149 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_149 (PRE_first_tail_x6_r0_body.clo149.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_149.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff1149 : PRE_first_tail_x6_r0_body.fx1_149 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_149 (PRE_first_tail_x6_r0_body.cwS149.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_149.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck149 : freedLB PRE_first_tail_x6_r0_body.kappa149 PRE_first_tail_x6_r0_body.cx0_149.mlx PRE_first_tail_x6_r0_body.fx0_149 PRE_first_tail_x6_r0_body.fx1_149 PRE_first_tail_x6_r0_body.clo149 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf0149 : PRE_first_tail_x6_r0_body.kr0_149.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_149.flags (PRE_first_tail_x6_r0_body.clo149.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_149.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt0149 : PRE_first_tail_x6_r0_body.kr0_149.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_149.targs (PRE_first_tail_x6_r0_body.clo149.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_149.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf1149 : PRE_first_tail_x6_r0_body.kr1_149.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_149.flags (PRE_first_tail_x6_r0_body.cwS149.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_149.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt1149 : PRE_first_tail_x6_r0_body.kr1_149.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_149.targs (PRE_first_tail_x6_r0_body.cwS149.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_149.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck149 : krecLB PRE_first_tail_x6_r0_body.kappa149 6424 PRE_first_tail_x6_r0_body.cx0_149.mlx PRE_first_tail_x6_r0_body.kr0_149 PRE_first_tail_x6_r0_body.kr1_149 PRE_first_tail_x6_r0_body.clo149 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn149 : Nat.ble 6424 6424 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge149 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1438.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1439.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR149 : pendRegB PRE_first_tail_x6_r0_body.kappa149 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1439.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe149 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1439.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1438.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift149 (clean : Conv.NClean (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P149.NL) (cl : SSt (· < 6424) PRE_first_tail_x6_r0_body.cx0_149.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_149.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_149.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_149.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1437.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_149.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P149 6424 PRE_first_tail_x6_r0_body.kappa149 PRE_first_tail_x6_r0_body.s1439.ffi PRE_first_tail_x6_r0_body.s1438.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift149 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue149, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp149 t ht),
    PRE_first_tail_x6_r0_body.cbridge149,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1439.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1438.ffi) (PRE_first_tail_x6_r0_body.cfoot149 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_149 PRE_first_tail_x6_r0_body.ofx1_149 hobjC PRE_first_tail_x6_r0_body.ff0149 PRE_first_tail_x6_r0_body.ff1149 PRE_first_tail_x6_r0_body.ffck149,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1439.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1438.ffi) (PRE_first_tail_x6_r0_body.cfoot149 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_149 PRE_first_tail_x6_r0_body.okr1_149 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn149) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf0149 PRE_first_tail_x6_r0_body.fkt0149 PRE_first_tail_x6_r0_body.fkf1149 PRE_first_tail_x6_r0_body.fkt1149 PRE_first_tail_x6_r0_body.fkck149,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh0149 PRE_first_tail_x6_r0_body.cnh1149 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe149) PRE_first_tail_x6_r0_body.cpendR149⟩

end Host.Load.Run.Tpl
end

section -- st149/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st149 0
host_stream_state PRE_first_tail_x6_r0_body.st149 1
host_stream_state PRE_first_tail_x6_r0_body.st149 2
end Host.Load.Run.Tpl
end

section -- Site149
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 149 of chain `PRE_first_tail_x6_r0_body`: `plan__g149__g150` (`plan`), the call state `PRE_first_tail_x6_r0_body.s1437`, the merged state `PRE_first_tail_x6_r0_body.s1438`,
the site template `PRE_first_tail_x6_r0_body.st149` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s1439`: the merge.
The footprint's facts are in `SiteF149`, the compaction's in `SiteC149`, `SiteK149`, `SiteNa149`, `SiteNb149`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso149 : PRE_first_tail_x6_r0_body.st149.s0 = { PRE_first_tail_x6_r0_body.s1437 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs149 : List Frame := PRE_first_tail_x6_r0_body.s1437.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_149 : PRE_first_tail_x6_r0_body.S1437.tab.length = 6424
kernel_rfl PRE_first_tail_x6_r0_body.tab0_149 : PRE_first_tail_x6_r0_body.st149.S0.tab = PRE_first_tail_x6_r0_body.S1437.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws149 : List Nat := [3511, 3512, 3513, 3514, 3515, 3516, 3517, 3518, 3519]
kernel_rfl PRE_first_tail_x6_r0_body.fresh149 : (PRE_first_tail_x6_r0_body.S1437.tab.all fun e => PRE_first_tail_x6_r0_body.ws149.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S1437.oracle.all fun q => PRE_first_tail_x6_r0_body.ws149.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab149 : PRE_first_tail_x6_r0_body.S1438.tab = PRE_first_tail_x6_r0_body.S1437.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws149
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen149 : PRE_first_tail_x6_r0_body.st149.S2.tab.length - PRE_first_tail_x6_r0_body.st149.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged149`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap149 : PRE_first_tail_x6_r0_body.s1438.heap = PRE_first_tail_x6_r0_body.st149.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext149 : PRE_first_tail_x6_r0_body.s1438.next = PRE_first_tail_x6_r0_body.st149.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl149 : PRE_first_tail_x6_r0_body.s1438.ctl = PRE_first_tail_x6_r0_body.st149.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack149 : PRE_first_tail_x6_r0_body.s1438.stack = PRE_first_tail_x6_r0_body.st149.s2.stack ++ PRE_first_tail_x6_r0_body.s1437.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs149 : PRE_first_tail_x6_r0_body.s1438.jobs = PRE_first_tail_x6_r0_body.st149.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi149 : PRE_first_tail_x6_r0_body.s1438.ffi = PRE_first_tail_x6_r0_body.st149.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace149 : PRE_first_tail_x6_r0_body.s1438.trace = PRE_first_tail_x6_r0_body.st149.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores149 : PRE_first_tail_x6_r0_body.s1438.stores = PRE_first_tail_x6_r0_body.st149.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD149
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 149 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived149 : PRE_first_tail_x6_r0_body.nr149.map (fun r => nth? PRE_first_tail_x6_r0_body.st149.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo149 : PRE_first_tail_x6_r0_body.nr149.all (Nat.ble 6424) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj149 : PRE_first_tail_x6_r0_body.cws149.all (fun c => !PRE_first_tail_x6_r0_body.ws149.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ149 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws149 PRE_first_tail_x6_r0_body.crs149 PRE_first_tail_x6_r0_body.ws149

end Host.Load.Run.Tpl
end

section -- st149/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st149`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st149.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st149.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st149.s2.heap PRE_first_tail_x6_r0_body.st149.wrR ++ freshOf PRE_first_tail_x6_r0_body.st149.s2.heap PRE_first_tail_x6_r0_body.st149.s0.next PRE_first_tail_x6_r0_body.st149.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st149.wr : List Nat := PRE_first_tail_x6_r0_body.st149.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st149.heapFoot : PRE_first_tail_x6_r0_body.st149.s2.heap = setAll PRE_first_tail_x6_r0_body.st149.s0.heap PRE_first_tail_x6_r0_body.st149.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st149.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st149.s0.next PRE_first_tail_x6_r0_body.st149.s2.next = true
theorem PRE_first_tail_x6_r0_body.st149.grows : PRE_first_tail_x6_r0_body.st149.s0.next ≤ PRE_first_tail_x6_r0_body.st149.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st149.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st149.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st149.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st149.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st149.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st149.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st149.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st149.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st149.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st149.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st149.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st149.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st149.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st149.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st149.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st149.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st149.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st149.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st149.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st149.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st149.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st149.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st149.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st149.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st149.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st149.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st149.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st149.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st149.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st149.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st149.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st149.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF149
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 149 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB149 : nodupT PRE_first_tail_x6_r0_body.st149.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup149 : PRE_first_tail_x6_r0_body.st149.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB149).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB149 : PRE_first_tail_x6_r0_body.st149.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound149 : ∀ b ∈ PRE_first_tail_x6_r0_body.st149.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB149 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr149 := PRE_first_tail_x6_r0_body.st149.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq149 : PRE_first_tail_x6_r0_body.st149.s2.trace = PRE_first_tail_x6_r0_body.trFr149 ++ PRE_first_tail_x6_r0_body.st149.s0.trace
theorem PRE_first_tail_x6_r0_body.trace149 : ∃ fr, PRE_first_tail_x6_r0_body.st149.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st149.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq149⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide149 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB149 : (PRE_first_tail_x6_r0_body.wide149.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st149.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix149 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide149, WFix Map.id (Present PRE_first_tail_x6_r0_body.st149.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB149 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL149
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 149 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s1438`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO149 : PRE_first_tail_x6_r0_body.st149.S0.oracle = PRE_first_tail_x6_r0_body.st149.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B149 : PRE_first_tail_x6_r0_body.st149.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st149.s0.next || (PRE_first_tail_x6_r0_body.st149.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot149 : Conv.StageFoot PRE_first_tail_x6_r0_body.st149.wr PRE_first_tail_x6_r0_body.st149.s0 PRE_first_tail_x6_r0_body.st149.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st149.heapFoot PRE_first_tail_x6_r0_body.wrNodup149 PRE_first_tail_x6_r0_body.wrBound149 PRE_first_tail_x6_r0_body.wr0B149 PRE_first_tail_x6_r0_body.st149.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged149 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st149.F.S → PRE_first_tail_x6_r0_body.st149.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st149.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st149.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs149 PRE_first_tail_x6_r0_body.st149.wr PRE_first_tail_x6_r0_body.s1437 PRE_first_tail_x6_r0_body.st149.s2 PRE_first_tail_x6_r0_body.st149.s0
      PRE_first_tail_x6_r0_body.st149.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st149.F FR W stk M ν K PRE_first_tail_x6_r0_body.s1438 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso149 PRE_first_tail_x6_r0_body.stFoot149 PRE_first_tail_x6_r0_body.wrNodup149 PRE_first_tail_x6_r0_body.wrBound149 PRE_first_tail_x6_r0_body.trace149 PRE_first_tail_x6_r0_body.mheap149
    PRE_first_tail_x6_r0_body.mnext149 PRE_first_tail_x6_r0_body.mctl149 PRE_first_tail_x6_r0_body.mstack149 PRE_first_tail_x6_r0_body.mjobs149 PRE_first_tail_x6_r0_body.mffi149 PRE_first_tail_x6_r0_body.mtrace149 PRE_first_tail_x6_r0_body.mstores149 h

def PRE_first_tail_x6_r0_body.arrEl149_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE149_2665 : arrOf PRE_first_tail_x6_r0_body.s1438 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl149_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA149_2665 : isArrB PRE_first_tail_x6_r0_body.s1438 2665 = true
theorem PRE_first_tail_x6_r0_body.arr149_2665 : ∃ o, PRE_first_tail_x6_r0_body.s1438.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl149_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE149_2665 PRE_first_tail_x6_r0_body.arrA149_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN149_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl149_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR149_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl149_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN149_2665

def PRE_first_tail_x6_r0_body.arrEl149_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE149_2673467 : arrOf PRE_first_tail_x6_r0_body.s1438 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl149_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA149_2673467 : isArrB PRE_first_tail_x6_r0_body.s1438 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr149_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s1438.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl149_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE149_2673467 PRE_first_tail_x6_r0_body.arrA149_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN149_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl149_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR149_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl149_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN149_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k149 : isArrB PRE_first_tail_x6_r0_body.s1438 4910 = false
theorem PRE_first_tail_x6_r0_body.keep149 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s1438 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k149 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr149_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl149_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ149
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 149 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s1437`, the merged
state `PRE_first_tail_x6_r0_body.s1438`, the canonical state `PRE_first_tail_x6_r0_body.s1439`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl149 : PRE_first_tail_x6_r0_body.pl149.all (Nat.ble PRE_first_tail_x6_r0_body.s1437.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd149 : nodupT PRE_first_tail_x6_r0_body.pl149 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn1149 : Nat.ble PRE_first_tail_x6_r0_body.s1437.next 2791523 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst149 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s1437.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn149 : PRE_first_tail_x6_r0_body.s1439.next = PRE_first_tail_x6_r0_body.s1437.next + PRE_first_tail_x6_r0_body.pl149.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn149 : PRE_first_tail_x6_r0_body.s1438.next = 2791523
kernel_rfl PRE_first_tail_x6_r0_body.zgrow149 : Nat.ble PRE_first_tail_x6_r0_body.s1439.next PRE_first_tail_x6_r0_body.s1438.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh149 : PRE_first_tail_x6_r0_body.S1437.tab.all (fun e => PRE_first_tail_x6_r0_body.cws149.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd149 : nodupT PRE_first_tail_x6_r0_body.cws149 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi149 : PRE_first_tail_x6_r0_body.nr149.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S1438.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt149 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s1437.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg149_2665 : PRE_first_tail_x6_r0_body.s1439.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1439 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk149_2665 : (objOf PRE_first_tail_x6_r0_body.s1439 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm149_2665 : PRE_first_tail_x6_r0_body.s1438.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa149.obj (objOf PRE_first_tail_x6_r0_body.s1439 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s1438 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg149_2673467 : PRE_first_tail_x6_r0_body.s1439.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1439 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk149_2673467 : (objOf PRE_first_tail_x6_r0_body.s1439 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm149_2673467 : PRE_first_tail_x6_r0_body.s1438.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa149.obj (objOf PRE_first_tail_x6_r0_body.s1439 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s1438 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw149_4910 : (PRE_first_tail_x6_r0_body.s1439.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw149_2673472 : (PRE_first_tail_x6_r0_body.s1439.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw149_2673473 : (PRE_first_tail_x6_r0_body.s1439.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd149 : PRE_first_tail_x6_r0_body.cl149.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr149 : PRE_first_tail_x6_r0_body.st149.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s1437.next || PRE_first_tail_x6_r0_body.cl149.contains b) = true
def PRE_first_tail_x6_r0_body.zl149 : List Nat := PRE_first_tail_x6_r0_body.cl149.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE149 : PRE_first_tail_x6_r0_body.zl149.map (fun a => PRE_first_tail_x6_r0_body.s1438.heap.get (PRE_first_tail_x6_r0_body.kappa149.a a)) = PRE_first_tail_x6_r0_body.zl149.map (fun a => (PRE_first_tail_x6_r0_body.s1439.heap.get a).map PRE_first_tail_x6_r0_body.kappa149.hobj)
theorem PRE_first_tail_x6_r0_body.zimg149 : HeapImg PRE_first_tail_x6_r0_body.kappa149 PRE_first_tail_x6_r0_body.s1439 PRE_first_tail_x6_r0_body.s1438 PRE_first_tail_x6_r0_body.zl149 := PRE_first_tail_x6_r0_body.zimgE149
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl149 : PRE_first_tail_x6_r0_body.s1438.ctl = PRE_first_tail_x6_r0_body.kappa149.ctl PRE_first_tail_x6_r0_body.s1439.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack149 : PRE_first_tail_x6_r0_body.s1438.stack = PRE_first_tail_x6_r0_body.s1439.stack.map PRE_first_tail_x6_r0_body.kappa149.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs149 : PRE_first_tail_x6_r0_body.s1438.jobs = PRE_first_tail_x6_r0_body.s1439.jobs.map PRE_first_tail_x6_r0_body.kappa149.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores149 : PRE_first_tail_x6_r0_body.s1438.stores = PRE_first_tail_x6_r0_body.kappa149.stores PRE_first_tail_x6_r0_body.s1439.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots149 : checkRootsSupp PRE_first_tail_x6_r0_body.s1439 6424 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC149 : PRE_first_tail_x6_r0_body.S1437.tab.length + PRE_first_tail_x6_r0_body.cws149.length = 6424
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap149 : PRE_first_tail_x6_r0_body.kappa149 = Conv.Map.compact PRE_first_tail_x6_r0_body.s1437.next 2791523 PRE_first_tail_x6_r0_body.S1437.tab.length PRE_first_tail_x6_r0_body.pl149 (PRE_first_tail_x6_r0_body.nr149.map NumV.ref) PRE_first_tail_x6_r0_body.kd149.big
  PRE_first_tail_x6_r0_body.kd149.region PRE_first_tail_x6_r0_body.kd149.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin149 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1439.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc149 : Conv.jcleanListB (⟨21128, 18229, 2791504, 6424⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1439 PRE_first_tail_x6_r0_body.cl149 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB149 : noBigRootsP (fun i => !Conv.oldBigB (⟨21128, 18229, 2791504, 6424⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s1439.trace PRE_first_tail_x6_r0_body.s1439 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm149 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 18229 = true
theorem PRE_first_tail_x6_r0_body.cjcl149 (h : Conv.JClean (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1437) : Conv.JClean (⟨21128, 18229, 2791504, 6424⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1439 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle149)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap149 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd149 a ha)) PRE_first_tail_x6_r0_body.zjc149

end Host.Load.Run.Tpl
end

section -- st149/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st149.bodyLast from PRE_first_tail_x6_r0_body.st149.s1 to PRE_first_tail_x6_r0_body.st149.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st149.F PRE_first_tail_x6_r0_body.st149.s1).run PRE_first_tail_x6_r0_body.st149.S1 = some (PRE_first_tail_x6_r0_body.st149.s2, PRE_first_tail_x6_r0_body.st149.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st149.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st149.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st149.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st149.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st149/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st149.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st149.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st149.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st149.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st149.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st149.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st149.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st149.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st149.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st149.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st149.s0 PRE_first_tail_x6_r0_body.st149.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st149.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st149.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st149.s1 PRE_first_tail_x6_r0_body.st149.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st149/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st149.bodyK0F from PRE_first_tail_x6_r0_body.st149.s0 to PRE_first_tail_x6_r0_body.st149.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st149.F (PRE_first_tail_x6_r0_body.st149.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st149.ks 0).getD 0) PRE_first_tail_x6_r0_body.st149.s0 PRE_first_tail_x6_r0_body.st149.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st149.s1, PRE_first_tail_x6_r0_body.st149.S1)
theorem PRE_first_tail_x6_r0_body.st149.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st149.F (PRE_first_tail_x6_r0_body.st149.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st149.ks 0).getD 0) PRE_first_tail_x6_r0_body.st149.s0 PRE_first_tail_x6_r0_body.st149.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st149.s1, PRE_first_tail_x6_r0_body.st149.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st149.bodyOkLN_ok PRE_first_tail_x6_r0_body.st149.bodyK0F
end Host.Load.Run.Tpl
end

section -- st149/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st149.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st149.F (PRE_first_tail_x6_r0_body.st149.bodyOkL bytes rows) 206 PRE_first_tail_x6_r0_body.st149.s0 PRE_first_tail_x6_r0_body.st149.S0 = some (PRE_first_tail_x6_r0_body.st149.s1, PRE_first_tail_x6_r0_body.st149.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st149.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st149.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st149.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st149.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st149.F (PRE_first_tail_x6_r0_body.st149.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st149.s0
  S0 := PRE_first_tail_x6_r0_body.st149.S0
  s1 := PRE_first_tail_x6_r0_body.st149.s1
  S1 := PRE_first_tail_x6_r0_body.st149.S1
  s2 := PRE_first_tail_x6_r0_body.st149.s2
  S2 := PRE_first_tail_x6_r0_body.st149.S2
  n := 206
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st149.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st149.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st149.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st149.bodyHalt
  last := PRE_first_tail_x6_r0_body.st149.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st149.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC150
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 150 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s1456` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa150` into the merged state
`PRE_first_tail_x6_r0_body.s1455`. -/

def PRE_first_tail_x6_r0_body.pl150 : List Nat := [2794091, 2793266, 2794097, 2794093, 2793268, 2794099]
def PRE_first_tail_x6_r0_body.nr150 : List Nat := [6527, 6526, 6502, 6510, 6515, 6520, 6525, 6499, 6500, 6501, 6508, 6509, 6497, 6504, 6505, 6506, 6507, 6503]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd150 : RData :=
  ⟨2792985, 2794134, Stage.setAll PTrie.nil [(2792979, 2794091), (2792980, 2793266), (2792981, 2794097), (2792982, 2794093), (2792983, 2793268), (2792984, 2794099)], Stage.setAll PTrie.nil [(21162, 21188), (21163, 21166), (21164, 21189)],
   21165, 21190, 18275, 18275, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(6497, .ref 6527), (6498, .ref 6526), (6499, .ref 6502), (6500, .ref 6510), (6501, .ref 6515), (6502, .ref 6520), (6503, .ref 6525), (6504, .ref 6499), (6505, .ref 6500), (6506, .ref 6501), (6507, .ref 6508), (6508, .ref 6509), (6509, .ref 6497), (6510, .ref 6504), (6511, .ref 6505), (6512, .ref 6506), (6513, .ref 6507), (6514, .ref 6503)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa150 : Map :=
  Conv.Map.compact 2792979 2794134 6497 PRE_first_tail_x6_r0_body.pl150 (PRE_first_tail_x6_r0_body.nr150.map NumV.ref) PRE_first_tail_x6_r0_body.kd150.big
    PRE_first_tail_x6_r0_body.kd150.region PRE_first_tail_x6_r0_body.kd150.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws150 : List Nat := [3551, 3552, 3553, 3554, 3555, 3556, 3557, 3558, 3559, 3560, 3561, 3562, 3563, 3564, 3565, 3566, 3567, 3568]
noncomputable def PRE_first_tail_x6_r0_body.crs150 : List SymE := PRE_first_tail_x6_r0_body.nr150.map fun r => (nth? PRE_first_tail_x6_r0_body.S1455.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta150 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws150 PRE_first_tail_x6_r0_body.crs150
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB150 : List Nat := [2665, 2672682, 2673467, 2792153, 2792698, 2792954]

kernel_rfl PRE_first_tail_x6_r0_body.ctab150 : PRE_first_tail_x6_r0_body.S1456.tab = PRE_first_tail_x6_r0_body.S1454.tab ++ PRE_first_tail_x6_r0_body.cws150.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace150 : PRE_first_tail_x6_r0_body.s1456.trace = PRE_first_tail_x6_r0_body.s1454.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext150 : PRE_first_tail_x6_r0_body.s1456.next = 2792985
kernel_rfl PRE_first_tail_x6_r0_body.ccounters150 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1456.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1456.ffi).mlx.nnext) = (21165, 18275)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue150 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1455.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1456.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa150.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp150 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1456.ffi).mlx.tokens.all (bSN 6515) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean150 : Conv.cleanListB 21165 131072 (fun r => Nat.ble 84660 r) PRE_first_tail_x6_r0_body.s1456
    (PRE_first_tail_x6_r0_body.wrB150 ++ (List.range 6).map (2792979 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs150 : bigsOutB 21165 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1456.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK150
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl150`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl150 : List Nat := [2665, 2672682, 2673467, 2792153, 2792698, 2792954, 2792979, 2792980, 2792981, 2792982, 2792983, 2792984]
def PRE_first_tail_x6_r0_body.clo150 : List Nat := [21142, 21155, 21161, 21162, 21163, 21164]
def PRE_first_tail_x6_r0_body.cln150 : List Nat := [18248, 18249, 18250, 18251, 18252, 18253, 18254, 18255, 18256, 18257, 18258, 18259, 18260, 18261, 18262, 18263, 18264, 18265, 18266, 18267, 18268, 18269, 18270, 18271, 18272, 18273, 18274]
def PRE_first_tail_x6_r0_body.cli150 : List Nat := [18248, 18249, 18250, 18251, 18252, 18253, 18254, 18255, 18256, 18257, 18258, 18259, 18260, 18261, 18262, 18263, 18264, 18265, 18266, 18267, 18268, 18269, 18270, 18271, 18272, 18273, 18274]
kernel_rfl PRE_first_tail_x6_r0_body.cheap150 : PRE_first_tail_x6_r0_body.s1456.heap = Stage.setAll PRE_first_tail_x6_r0_body.s1454.heap (PRE_first_tail_x6_r0_body.cl150.filterMap fun a => (PRE_first_tail_x6_r0_body.s1456.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe150 : Nat.ble PRE_first_tail_x6_r0_body.s1454.next PRE_first_tail_x6_r0_body.s1456.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP150 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s1454 PRE_first_tail_x6_r0_body.s1456 PRE_first_tail_x6_r0_body.cl150 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp150 : Conv.suppListB PRE_first_tail_x6_r0_body.s1456 6515 PRE_first_tail_x6_r0_body.cl150 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound150 : Conv.boundListB PRE_first_tail_x6_r0_body.s1456 PRE_first_tail_x6_r0_body.cl150 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK150 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1456.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln150.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1456.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK150 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1456.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo150.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1456.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK150 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1456.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli150.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1456.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst150 : Conv.sstListB 6515 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1456.ffi).mlx PRE_first_tail_x6_r0_body.cln150 PRE_first_tail_x6_r0_body.clo150 PRE_first_tail_x6_r0_body.cli150 = true

end Host.Load.Run.Tpl
end

section -- SiteCl150
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA150 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1456.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo150.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1456.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd150 : (PRE_first_tail_x6_r0_body.clo150 ++ PRE_first_tail_x6_r0_body.cln150 ++ PRE_first_tail_x6_r0_body.cli150).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle150 : Conv.Cnt.leB (⟨21162, 18248, 2792979, 6497⟩ : Conv.Cnt) (⟨21165, 18275, 2792985, 6515⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck150 : Conv.ncleanListB (⟨21165, 18275, 2792985, 6515⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1456.ffi).mlx PRE_first_tail_x6_r0_body.clo150 PRE_first_tail_x6_r0_body.cln150 PRE_first_tail_x6_r0_body.cli150 = true
theorem PRE_first_tail_x6_r0_body.cncl150 (h : Conv.NClean (⟨21162, 18248, 2792979, 6497⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx) : Conv.NClean (⟨21165, 18275, 2792985, 6515⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1456.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle150 PRE_first_tail_x6_r0_body.ckA150 PRE_first_tail_x6_r0_body.cobjsK150 PRE_first_tail_x6_r0_body.cnodesK150 PRE_first_tail_x6_r0_body.citemsK150 PRE_first_tail_x6_r0_body.cbd150 PRE_first_tail_x6_r0_body.cck150

end Host.Load.Run.Tpl
end

section -- SiteS150
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 150 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc150 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P150 : LoadP := PRE_first_tail_x6_r0_body.Pc150.raise 18275
kernel_rfl PRE_first_tail_x6_r0_body.craise150 : Nat.ble PRE_first_tail_x6_r0_body.Pc150.N0 18275 = true
theorem PRE_first_tail_x6_r0_body.raised150 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc150 PRE_first_tail_x6_r0_body.P150 :=
  .inr ⟨18275, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise150, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_150 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1456.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_150 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1455.ffi)
def PRE_first_tail_x6_r0_body.khinv150 : PTrie Nat := Stage.setAll PTrie.nil [(21188, 21162), (21166, 21163), (21189, 21164)]
def PRE_first_tail_x6_r0_body.kninv150 : PTrie Nat := Stage.setAll PTrie.nil [(18248, 18248), (18249, 18249), (18250, 18250), (18251, 18251), (18252, 18252), (18253, 18253), (18254, 18254), (18255, 18255), (18256, 18256), (18257, 18257), (18258, 18258), (18259, 18259), (18260, 18260), (18261, 18261), (18262, 18262), (18263, 18263), (18264, 18264), (18265, 18265), (18266, 18266), (18267, 18267), (18268, 18268), (18269, 18269), (18270, 18270), (18271, 18271), (18272, 18272), (18273, 18273), (18274, 18274)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS150 : List Nat := [21142, 21155, 21161, 21162, 21163, 21164, 21165, 21166, 21167, 21168, 21169, 21170, 21171, 21172, 21173, 21174, 21175, 21176, 21177, 21178, 21179, 21180, 21181, 21182, 21183, 21184, 21185, 21186, 21187, 21188, 21189]
def PRE_first_tail_x6_r0_body.cnS150 : List Nat := List.range' 18248 27
def PRE_first_tail_x6_r0_body.ciS150 : List Nat := [] ++ List.range' 18248 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh0150 : PRE_first_tail_x6_r0_body.kd150.nh0 = PRE_first_tail_x6_r0_body.cx0_150.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh1150 : PRE_first_tail_x6_r0_body.kd150.nh1 = PRE_first_tail_x6_r0_body.cx1_150.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn0150 : PRE_first_tail_x6_r0_body.kd150.nn0 = PRE_first_tail_x6_r0_body.cx0_150.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn1150 : PRE_first_tail_x6_r0_body.kd150.nn1 = PRE_first_tail_x6_r0_body.cx1_150.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo150 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P150.lo && Nat.ble PRE_first_tail_x6_r0_body.P150.lo PRE_first_tail_x6_r0_body.cx0_150.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P150.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P150.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt150 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_150.mlx.next PRE_first_tail_x6_r0_body.cx1_150.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_150.mlx.nnext PRE_first_tail_x6_r0_body.cx1_150.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband150 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P150.NL && Nat.ble PRE_first_tail_x6_r0_body.P150.NL PRE_first_tail_x6_r0_body.P150.N0 && Nat.ble PRE_first_tail_x6_r0_body.P150.N0 PRE_first_tail_x6_r0_body.cx0_150.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow150 : PRE_first_tail_x6_r0_body.kd150.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren150 : checkRenG PRE_first_tail_x6_r0_body.kd150.hnd PRE_first_tail_x6_r0_body.khinv150 (phB PRE_first_tail_x6_r0_body.cx0_150.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband150 : PRE_first_tail_x6_r0_body.kd150.checkBand PRE_first_tail_x6_r0_body.P150.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos150 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd150.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren150 : checkRenG PRE_first_tail_x6_r0_body.kd150.node PRE_first_tail_x6_r0_body.kninv150 (pnB PRE_first_tail_x6_r0_body.cx0_150.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow150 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd150.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P150.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd150.nodeF j) PRE_first_tail_x6_r0_body.cx1_150.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a150 : PRE_first_tail_x6_r0_body.cx0_150.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b150 : PRE_first_tail_x6_r0_body.cx0_150.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok1150 : PRE_first_tail_x6_r0_body.cx1_150.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend150 : PRE_first_tail_x6_r0_body.cx1_150.mlx.pending = PRE_first_tail_x6_r0_body.cx0_150.mlx.pending.map PRE_first_tail_x6_r0_body.kappa150.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh150 : PRE_first_tail_x6_r0_body.cx1_150.mlx.errh = PRE_first_tail_x6_r0_body.cx0_150.mlx.errh.map PRE_first_tail_x6_r0_body.kappa150.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles150 : PRE_first_tail_x6_r0_body.cx1_150.mlx.files = PRE_first_tail_x6_r0_body.cx0_150.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch150 : PRE_first_tail_x6_r0_body.cx1_150.mlx.arch = PRE_first_tail_x6_r0_body.cx0_150.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes150 : PRE_first_tail_x6_r0_body.cx1_150.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_150.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired150 : PRE_first_tail_x6_r0_body.cx1_150.mlx.wired = PRE_first_tail_x6_r0_body.cx0_150.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost150 : PRE_first_tail_x6_r0_body.cx1_150.host = PRE_first_tail_x6_r0_body.cx0_150.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd150`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn0150 : PRE_first_tail_x6_r0_body.kd150.n0 = 2792985
kernel_rfl PRE_first_tail_x6_r0_body.ckn1150 : PRE_first_tail_x6_r0_body.kd150.n1 = 2794134
kernel_rfl PRE_first_tail_x6_r0_body.ckheap150 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd150.heap).all (fun x => Nat.ble 2792979 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl150 : (List.range 6).all (fun j => decide (PRE_first_tail_x6_r0_body.kd150.heap.get (2792979 + j) = nth? PRE_first_tail_x6_r0_body.pl150 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja150 : Nat.ble 2792979 2792979 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn150 : Nat.ble 6497 6497 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD150 : Nat.ble 2792979 PRE_first_tail_x6_r0_body.kd150.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn150 : Nat.ble 21162 PRE_first_tail_x6_r0_body.kd150.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn150 : Nat.ble 18248 PRE_first_tail_x6_r0_body.kd150.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb150 : Nat.ble 21162 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap150 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd150.heap).all (Nat.ble (⟨21162, 18248, 2792979, 6497⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd150 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd150.hnd).all (Nat.ble (⟨21162, 18248, 2792979, 6497⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode150 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd150.node).all (Nat.ble (⟨21162, 18248, 2792979, 6497⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix150 : Conv.FixOld (⟨21162, 18248, 2792979, 6497⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa150 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja150) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn150) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD150) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn150) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn150) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb150) PRE_first_tail_x6_r0_body.fheap150 PRE_first_tail_x6_r0_body.fhnd150 PRE_first_tail_x6_r0_body.fnode150
kernel_rfl PRE_first_tail_x6_r0_body.fcxn150 : (⟨21162, 18248, 2792979, 6497⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn150 : (⟨21162, 18248, 2792979, 6497⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle0150 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_150.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_150.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk150 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd150.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A150 : PRE_first_tail_x6_r0_body.cx1_150.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS150.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_150.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O150 : PRE_first_tail_x6_r0_body.cx1_150.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS150.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_150.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N150 : PRE_first_tail_x6_r0_body.cx1_150.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS150.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_150.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I150 : PRE_first_tail_x6_r0_body.cx1_150.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS150.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_150.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd150 : (PRE_first_tail_x6_r0_body.clo150 ++ PRE_first_tail_x6_r0_body.cln150 ++ PRE_first_tail_x6_r0_body.cli150 ++ PRE_first_tail_x6_r0_body.cwS150 ++ PRE_first_tail_x6_r0_body.cnS150 ++ PRE_first_tail_x6_r0_body.ciS150).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW150 : PRE_first_tail_x6_r0_body.cwS150.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo150.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI150 : PRE_first_tail_x6_r0_body.ciS150.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli150.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN150 : PRE_first_tail_x6_r0_body.cnS150.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF150 : PRE_first_tail_x6_r0_body.cln150.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh150 : PRE_first_tail_x6_r0_body.clo150.all (handleOK PRE_first_tail_x6_r0_body.kappa150 PRE_first_tail_x6_r0_body.P150.lo PRE_first_tail_x6_r0_body.cx0_150.mlx PRE_first_tail_x6_r0_body.cx1_150.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo150 : PRE_first_tail_x6_r0_body.clo150.map (fun h => PRE_first_tail_x6_r0_body.cx1_150.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa150.handle h)) = PRE_first_tail_x6_r0_body.clo150.map (fun h => (PRE_first_tail_x6_r0_body.cx0_150.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa150.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok150 : PRE_first_tail_x6_r0_body.clo150.all (objOK PRE_first_tail_x6_r0_body.kappa150 PRE_first_tail_x6_r0_body.P150.NL PRE_first_tail_x6_r0_body.cx0_150.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd150 : PRE_first_tail_x6_r0_body.cln150.all (nodeOKF PRE_first_tail_x6_r0_body.kappa150 PRE_first_tail_x6_r0_body.P150 PRE_first_tail_x6_r0_body.cx0_150.mlx PRE_first_tail_x6_r0_body.cx1_150.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp150 : ((PRE_first_tail_x6_r0_body.cln150.filter (fullB PRE_first_tail_x6_r0_body.P150))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_150.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa150.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln150.filter (fullB PRE_first_tail_x6_r0_body.P150))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_150.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa150.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI150 : incrB PRE_first_tail_x6_r0_body.kd150.nodeF (List.range' 18248 27) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK150 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd150.node).all (fun k => Nat.ble 18248 k && Nat.blt k 18275) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL150 : (PRE_first_tail_x6_r0_body.cln150.filter (Nat.ble PRE_first_tail_x6_r0_body.P150.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd150.nodeF i) && (Nat.blt i 18275 || Nat.ble PRE_first_tail_x6_r0_body.kd150.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord150 : (PRE_first_tail_x6_r0_body.cln150.filter (Nat.ble PRE_first_tail_x6_r0_body.P150.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd150.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd150.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd150.nodeF j) (PRE_first_tail_x6_r0_body.kd150.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow150 PRE_first_tail_x6_r0_body.cnn1150 PRE_first_tail_x6_r0_body.fnordI150 PRE_first_tail_x6_r0_body.fnordK150 PRE_first_tail_x6_r0_body.fnordL150
kernel_rfl PRE_first_tail_x6_r0_body.fi150 : PRE_first_tail_x6_r0_body.cli150.all (pnB PRE_first_tail_x6_r0_body.cx0_150.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii150 : PRE_first_tail_x6_r0_body.cli150.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_150.mlx.items.get (PRE_first_tail_x6_r0_body.kappa150.node k) = (PRE_first_tail_x6_r0_body.cx0_150.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa150.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot150 (clean : Conv.NClean (⟨21162, 18248, 2792979, 6497⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P150.NL) (cl : SSt (· < 6515) PRE_first_tail_x6_r0_body.cx0_150.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P150 6515 PRE_first_tail_x6_r0_body.kappa150 PRE_first_tail_x6_r0_body.kd150 PRE_first_tail_x6_r0_body.khinv150 PRE_first_tail_x6_r0_body.kninv150 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx PRE_first_tail_x6_r0_body.cx0_150.mlx PRE_first_tail_x6_r0_body.cx1_150.mlx (⟨21162, 18248, 2792979, 6497⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo150 PRE_first_tail_x6_r0_body.cln150 PRE_first_tail_x6_r0_body.cli150 PRE_first_tail_x6_r0_body.cwS150 PRE_first_tail_x6_r0_body.cnS150 PRE_first_tail_x6_r0_body.ciS150 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh0150, PRE_first_tail_x6_r0_body.cnh1150, PRE_first_tail_x6_r0_body.cnn0150, PRE_first_tail_x6_r0_body.cnn1150, PRE_first_tail_x6_r0_body.cplo150, PRE_first_tail_x6_r0_body.ccnt150, PRE_first_tail_x6_r0_body.cnband150, PRE_first_tail_x6_r0_body.chbelow150, PRE_first_tail_x6_r0_body.chren150, PRE_first_tail_x6_r0_body.cband150, PRE_first_tail_x6_r0_body.cnh1pos150, PRE_first_tail_x6_r0_body.cnren150, PRE_first_tail_x6_r0_body.cnlow150, PRE_first_tail_x6_r0_body.cabs0a150, PRE_first_tail_x6_r0_body.cabs0b150, PRE_first_tail_x6_r0_body.ctok1150, PRE_first_tail_x6_r0_body.cpend150, PRE_first_tail_x6_r0_body.cerrh150, PRE_first_tail_x6_r0_body.cfiles150, PRE_first_tail_x6_r0_body.carch150, PRE_first_tail_x6_r0_body.csizes150, PRE_first_tail_x6_r0_body.cwired150, PRE_first_tail_x6_r0_body.cfix150, clean, PRE_first_tail_x6_r0_body.fcxn150, PRE_first_tail_x6_r0_body.fcnn150, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle0150, PRE_first_tail_x6_r0_body.fnk150, PRE_first_tail_x6_r0_body.ckA150, PRE_first_tail_x6_r0_body.cobjsK150, PRE_first_tail_x6_r0_body.cnodesK150, PRE_first_tail_x6_r0_body.citemsK150, PRE_first_tail_x6_r0_body.f1A150, PRE_first_tail_x6_r0_body.f1O150, PRE_first_tail_x6_r0_body.f1N150, PRE_first_tail_x6_r0_body.f1I150, PRE_first_tail_x6_r0_body.fbd150, PRE_first_tail_x6_r0_body.fincW150, PRE_first_tail_x6_r0_body.fincI150, PRE_first_tail_x6_r0_body.fincN150, PRE_first_tail_x6_r0_body.flnF150, PRE_first_tail_x6_r0_body.fh150, PRE_first_tail_x6_r0_body.fo150, PRE_first_tail_x6_r0_body.fok150, PRE_first_tail_x6_r0_body.fnd150, PRE_first_tail_x6_r0_body.fp150, PRE_first_tail_x6_r0_body.fnord150, PRE_first_tail_x6_r0_body.fi150, PRE_first_tail_x6_r0_body.fii150⟩
theorem PRE_first_tail_x6_r0_body.cnshift150 (clean : Conv.NClean (⟨21162, 18248, 2792979, 6497⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P150.NL) (cl : SSt (· < 6515) PRE_first_tail_x6_r0_body.cx0_150.mlx) : NShift PRE_first_tail_x6_r0_body.P150 6515 PRE_first_tail_x6_r0_body.kappa150 PRE_first_tail_x6_r0_body.cx0_150 PRE_first_tail_x6_r0_body.cx1_150 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot150 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost150 (compact_a_eq PRE_first_tail_x6_r0_body.ckn0150 PRE_first_tail_x6_r0_body.ckn1150 PRE_first_tail_x6_r0_body.ckheap150 PRE_first_tail_x6_r0_body.ckpl150)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_150 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1454.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_150 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1454.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_150 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1454.ffi) = some PRE_first_tail_x6_r0_body.fxC_150
kernel_rfl PRE_first_tail_x6_r0_body.okrC_150 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1454.ffi) = some PRE_first_tail_x6_r0_body.krC_150
noncomputable def PRE_first_tail_x6_r0_body.fx0_150 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1456.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_150 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1456.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_150 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1456.ffi) = some PRE_first_tail_x6_r0_body.fx0_150
kernel_rfl PRE_first_tail_x6_r0_body.okr0_150 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1456.ffi) = some PRE_first_tail_x6_r0_body.kr0_150
noncomputable def PRE_first_tail_x6_r0_body.fx1_150 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1455.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_150 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1455.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_150 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1455.ffi) = some PRE_first_tail_x6_r0_body.fx1_150
kernel_rfl PRE_first_tail_x6_r0_body.okr1_150 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1455.ffi) = some PRE_first_tail_x6_r0_body.kr1_150
kernel_rfl PRE_first_tail_x6_r0_body.ff0150 : PRE_first_tail_x6_r0_body.fx0_150 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_150 (PRE_first_tail_x6_r0_body.clo150.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_150.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff1150 : PRE_first_tail_x6_r0_body.fx1_150 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_150 (PRE_first_tail_x6_r0_body.cwS150.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_150.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck150 : freedLB PRE_first_tail_x6_r0_body.kappa150 PRE_first_tail_x6_r0_body.cx0_150.mlx PRE_first_tail_x6_r0_body.fx0_150 PRE_first_tail_x6_r0_body.fx1_150 PRE_first_tail_x6_r0_body.clo150 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf0150 : PRE_first_tail_x6_r0_body.kr0_150.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_150.flags (PRE_first_tail_x6_r0_body.clo150.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_150.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt0150 : PRE_first_tail_x6_r0_body.kr0_150.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_150.targs (PRE_first_tail_x6_r0_body.clo150.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_150.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf1150 : PRE_first_tail_x6_r0_body.kr1_150.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_150.flags (PRE_first_tail_x6_r0_body.cwS150.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_150.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt1150 : PRE_first_tail_x6_r0_body.kr1_150.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_150.targs (PRE_first_tail_x6_r0_body.cwS150.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_150.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck150 : krecLB PRE_first_tail_x6_r0_body.kappa150 6515 PRE_first_tail_x6_r0_body.cx0_150.mlx PRE_first_tail_x6_r0_body.kr0_150 PRE_first_tail_x6_r0_body.kr1_150 PRE_first_tail_x6_r0_body.clo150 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn150 : Nat.ble 6497 6515 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge150 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1455.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1456.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR150 : pendRegB PRE_first_tail_x6_r0_body.kappa150 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1456.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe150 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1456.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1455.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift150 (clean : Conv.NClean (⟨21162, 18248, 2792979, 6497⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P150.NL) (cl : SSt (· < 6515) PRE_first_tail_x6_r0_body.cx0_150.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_150.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_150.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_150.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1454.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_150.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21162, 18248, 2792979, 6497⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P150 6515 PRE_first_tail_x6_r0_body.kappa150 PRE_first_tail_x6_r0_body.s1456.ffi PRE_first_tail_x6_r0_body.s1455.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift150 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue150, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp150 t ht),
    PRE_first_tail_x6_r0_body.cbridge150,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1456.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1455.ffi) (PRE_first_tail_x6_r0_body.cfoot150 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_150 PRE_first_tail_x6_r0_body.ofx1_150 hobjC PRE_first_tail_x6_r0_body.ff0150 PRE_first_tail_x6_r0_body.ff1150 PRE_first_tail_x6_r0_body.ffck150,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1456.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1455.ffi) (PRE_first_tail_x6_r0_body.cfoot150 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_150 PRE_first_tail_x6_r0_body.okr1_150 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn150) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf0150 PRE_first_tail_x6_r0_body.fkt0150 PRE_first_tail_x6_r0_body.fkf1150 PRE_first_tail_x6_r0_body.fkt1150 PRE_first_tail_x6_r0_body.fkck150,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh0150 PRE_first_tail_x6_r0_body.cnh1150 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe150) PRE_first_tail_x6_r0_body.cpendR150⟩

end Host.Load.Run.Tpl
end

section -- st150/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st150 0
host_stream_state PRE_first_tail_x6_r0_body.st150 1
host_stream_state PRE_first_tail_x6_r0_body.st150 2
host_stream_state PRE_first_tail_x6_r0_body.st150 3
host_stream_state PRE_first_tail_x6_r0_body.st150 4
host_stream_state PRE_first_tail_x6_r0_body.st150 5
end Host.Load.Run.Tpl
end

section -- Site150
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 150 of chain `PRE_first_tail_x6_r0_body`: `ssmW__g150__g151` (`recurWindow`), the call state `PRE_first_tail_x6_r0_body.s1454`, the merged state `PRE_first_tail_x6_r0_body.s1455`,
the site template `PRE_first_tail_x6_r0_body.st150` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s1456`: the merge.
The footprint's facts are in `SiteF150`, the compaction's in `SiteC150`, `SiteK150`, `SiteNa150`, `SiteNb150`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso150 : PRE_first_tail_x6_r0_body.st150.s0 = { PRE_first_tail_x6_r0_body.s1454 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs150 : List Frame := PRE_first_tail_x6_r0_body.s1454.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_150 : PRE_first_tail_x6_r0_body.S1454.tab.length = 6497
kernel_rfl PRE_first_tail_x6_r0_body.tab0_150 : PRE_first_tail_x6_r0_body.st150.S0.tab = PRE_first_tail_x6_r0_body.S1454.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws150 : List Nat := [3520, 3521, 3522, 3523, 3524, 3525, 3526, 3527, 3528, 3529, 3530, 3531, 3532, 3533, 3534, 3535, 3536, 3537, 3538, 3539, 3540, 3541, 3542, 3543, 3544, 3545, 3546, 3547, 3548, 3549, 3550]
kernel_rfl PRE_first_tail_x6_r0_body.fresh150 : (PRE_first_tail_x6_r0_body.S1454.tab.all fun e => PRE_first_tail_x6_r0_body.ws150.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S1454.oracle.all fun q => PRE_first_tail_x6_r0_body.ws150.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab150 : PRE_first_tail_x6_r0_body.S1455.tab = PRE_first_tail_x6_r0_body.S1454.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws150
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen150 : PRE_first_tail_x6_r0_body.st150.S5.tab.length - PRE_first_tail_x6_r0_body.st150.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged150`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap150 : PRE_first_tail_x6_r0_body.s1455.heap = PRE_first_tail_x6_r0_body.st150.s5.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext150 : PRE_first_tail_x6_r0_body.s1455.next = PRE_first_tail_x6_r0_body.st150.s5.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl150 : PRE_first_tail_x6_r0_body.s1455.ctl = PRE_first_tail_x6_r0_body.st150.s5.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack150 : PRE_first_tail_x6_r0_body.s1455.stack = PRE_first_tail_x6_r0_body.st150.s5.stack ++ PRE_first_tail_x6_r0_body.s1454.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs150 : PRE_first_tail_x6_r0_body.s1455.jobs = PRE_first_tail_x6_r0_body.st150.s5.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi150 : PRE_first_tail_x6_r0_body.s1455.ffi = PRE_first_tail_x6_r0_body.st150.s5.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace150 : PRE_first_tail_x6_r0_body.s1455.trace = PRE_first_tail_x6_r0_body.st150.s5.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores150 : PRE_first_tail_x6_r0_body.s1455.stores = PRE_first_tail_x6_r0_body.st150.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD150
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 150 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived150 : PRE_first_tail_x6_r0_body.nr150.map (fun r => nth? PRE_first_tail_x6_r0_body.st150.S5.tab r) =
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
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo150 : PRE_first_tail_x6_r0_body.nr150.all (Nat.ble 6497) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj150 : PRE_first_tail_x6_r0_body.cws150.all (fun c => !PRE_first_tail_x6_r0_body.ws150.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ150 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws150 PRE_first_tail_x6_r0_body.crs150 PRE_first_tail_x6_r0_body.ws150

end Host.Load.Run.Tpl
end

section -- st150/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st150`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st150.wrR : List (Nat × Nat) := [(2672682, 2672683), (2792153, 2792154), (2792698, 2792699), (2792954, 2792955)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st150.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st150.s5.heap PRE_first_tail_x6_r0_body.st150.wrR ++ freshOf PRE_first_tail_x6_r0_body.st150.s5.heap PRE_first_tail_x6_r0_body.st150.s0.next PRE_first_tail_x6_r0_body.st150.s5.next
noncomputable def PRE_first_tail_x6_r0_body.st150.wr : List Nat := PRE_first_tail_x6_r0_body.st150.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st150.heapFoot : PRE_first_tail_x6_r0_body.st150.s5.heap = setAll PRE_first_tail_x6_r0_body.st150.s0.heap PRE_first_tail_x6_r0_body.st150.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st150.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st150.s0.next PRE_first_tail_x6_r0_body.st150.s5.next = true
theorem PRE_first_tail_x6_r0_body.st150.grows : PRE_first_tail_x6_r0_body.st150.s0.next ≤ PRE_first_tail_x6_r0_body.st150.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st150.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st150.wh : List Nat := [21142, 21155, 21161, 21162, 21163, 21164, 21165, 21166, 21167, 21168, 21169, 21170, 21171, 21172, 21173, 21174, 21175, 21176, 21177, 21178, 21179, 21180, 21181, 21182, 21183, 21184, 21185, 21186, 21187, 21188, 21189]
def PRE_first_tail_x6_r0_body.st150.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st150.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st150.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st150.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st150.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st150.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st150.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st150.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st150.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st150.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st150.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st150.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st150.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st150.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st150.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st150.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st150.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st150.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st150.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st150.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st150.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st150.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st150.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st150.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st150.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st150.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st150.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st150.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st150.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st150.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF150
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 150 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB150 : nodupT PRE_first_tail_x6_r0_body.st150.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup150 : PRE_first_tail_x6_r0_body.st150.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB150).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB150 : PRE_first_tail_x6_r0_body.st150.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound150 : ∀ b ∈ PRE_first_tail_x6_r0_body.st150.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB150 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr150 := PRE_first_tail_x6_r0_body.st150.s5.trace.take 120
kernel_rfl PRE_first_tail_x6_r0_body.traceEq150 : PRE_first_tail_x6_r0_body.st150.s5.trace = PRE_first_tail_x6_r0_body.trFr150 ++ PRE_first_tail_x6_r0_body.st150.s0.trace
theorem PRE_first_tail_x6_r0_body.trace150 : ∃ fr, PRE_first_tail_x6_r0_body.st150.s5.trace = fr ++ PRE_first_tail_x6_r0_body.st150.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq150⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide150 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB150 : (PRE_first_tail_x6_r0_body.wide150.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st150.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix150 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide150, WFix Map.id (Present PRE_first_tail_x6_r0_body.st150.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB150 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL150
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 150 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s1455`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO150 : PRE_first_tail_x6_r0_body.st150.S0.oracle = PRE_first_tail_x6_r0_body.st150.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B150 : PRE_first_tail_x6_r0_body.st150.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st150.s0.next || (PRE_first_tail_x6_r0_body.st150.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot150 : Conv.StageFoot PRE_first_tail_x6_r0_body.st150.wr PRE_first_tail_x6_r0_body.st150.s0 PRE_first_tail_x6_r0_body.st150.s5 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st150.heapFoot PRE_first_tail_x6_r0_body.wrNodup150 PRE_first_tail_x6_r0_body.wrBound150 PRE_first_tail_x6_r0_body.wr0B150 PRE_first_tail_x6_r0_body.st150.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged150 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st150.F.S → PRE_first_tail_x6_r0_body.st150.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st150.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st150.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs150 PRE_first_tail_x6_r0_body.st150.wr PRE_first_tail_x6_r0_body.s1454 PRE_first_tail_x6_r0_body.st150.s5 PRE_first_tail_x6_r0_body.st150.s0
      PRE_first_tail_x6_r0_body.st150.s5.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st150.F FR W stk M ν K PRE_first_tail_x6_r0_body.s1455 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso150 PRE_first_tail_x6_r0_body.stFoot150 PRE_first_tail_x6_r0_body.wrNodup150 PRE_first_tail_x6_r0_body.wrBound150 PRE_first_tail_x6_r0_body.trace150 PRE_first_tail_x6_r0_body.mheap150
    PRE_first_tail_x6_r0_body.mnext150 PRE_first_tail_x6_r0_body.mctl150 PRE_first_tail_x6_r0_body.mstack150 PRE_first_tail_x6_r0_body.mjobs150 PRE_first_tail_x6_r0_body.mffi150 PRE_first_tail_x6_r0_body.mtrace150 PRE_first_tail_x6_r0_body.mstores150 h

def PRE_first_tail_x6_r0_body.arrEl150_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE150_2665 : arrOf PRE_first_tail_x6_r0_body.s1455 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl150_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA150_2665 : isArrB PRE_first_tail_x6_r0_body.s1455 2665 = true
theorem PRE_first_tail_x6_r0_body.arr150_2665 : ∃ o, PRE_first_tail_x6_r0_body.s1455.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl150_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE150_2665 PRE_first_tail_x6_r0_body.arrA150_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN150_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl150_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR150_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl150_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN150_2665

def PRE_first_tail_x6_r0_body.arrEl150_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE150_2673467 : arrOf PRE_first_tail_x6_r0_body.s1455 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl150_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA150_2673467 : isArrB PRE_first_tail_x6_r0_body.s1455 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr150_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s1455.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl150_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE150_2673467 PRE_first_tail_x6_r0_body.arrA150_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN150_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl150_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR150_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl150_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN150_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k150 : isArrB PRE_first_tail_x6_r0_body.s1455 4910 = false
theorem PRE_first_tail_x6_r0_body.keep150 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s1455 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k150 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr150_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl150_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ150
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 150 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s1454`, the merged
state `PRE_first_tail_x6_r0_body.s1455`, the canonical state `PRE_first_tail_x6_r0_body.s1456`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl150 : PRE_first_tail_x6_r0_body.pl150.all (Nat.ble PRE_first_tail_x6_r0_body.s1454.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd150 : nodupT PRE_first_tail_x6_r0_body.pl150 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn1150 : Nat.ble PRE_first_tail_x6_r0_body.s1454.next 2794134 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst150 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s1454.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn150 : PRE_first_tail_x6_r0_body.s1456.next = PRE_first_tail_x6_r0_body.s1454.next + PRE_first_tail_x6_r0_body.pl150.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn150 : PRE_first_tail_x6_r0_body.s1455.next = 2794134
kernel_rfl PRE_first_tail_x6_r0_body.zgrow150 : Nat.ble PRE_first_tail_x6_r0_body.s1456.next PRE_first_tail_x6_r0_body.s1455.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh150 : PRE_first_tail_x6_r0_body.S1454.tab.all (fun e => PRE_first_tail_x6_r0_body.cws150.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd150 : nodupT PRE_first_tail_x6_r0_body.cws150 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi150 : PRE_first_tail_x6_r0_body.nr150.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S1455.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt150 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s1454.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg150_2665 : PRE_first_tail_x6_r0_body.s1456.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1456 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk150_2665 : (objOf PRE_first_tail_x6_r0_body.s1456 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm150_2665 : PRE_first_tail_x6_r0_body.s1455.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa150.obj (objOf PRE_first_tail_x6_r0_body.s1456 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s1455 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg150_2673467 : PRE_first_tail_x6_r0_body.s1456.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1456 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk150_2673467 : (objOf PRE_first_tail_x6_r0_body.s1456 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm150_2673467 : PRE_first_tail_x6_r0_body.s1455.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa150.obj (objOf PRE_first_tail_x6_r0_body.s1456 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s1455 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw150_4910 : (PRE_first_tail_x6_r0_body.s1456.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw150_2673472 : (PRE_first_tail_x6_r0_body.s1456.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw150_2673473 : (PRE_first_tail_x6_r0_body.s1456.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd150 : PRE_first_tail_x6_r0_body.cl150.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr150 : PRE_first_tail_x6_r0_body.st150.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s1454.next || PRE_first_tail_x6_r0_body.cl150.contains b) = true
def PRE_first_tail_x6_r0_body.zl150 : List Nat := PRE_first_tail_x6_r0_body.cl150.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE150 : PRE_first_tail_x6_r0_body.zl150.map (fun a => PRE_first_tail_x6_r0_body.s1455.heap.get (PRE_first_tail_x6_r0_body.kappa150.a a)) = PRE_first_tail_x6_r0_body.zl150.map (fun a => (PRE_first_tail_x6_r0_body.s1456.heap.get a).map PRE_first_tail_x6_r0_body.kappa150.hobj)
theorem PRE_first_tail_x6_r0_body.zimg150 : HeapImg PRE_first_tail_x6_r0_body.kappa150 PRE_first_tail_x6_r0_body.s1456 PRE_first_tail_x6_r0_body.s1455 PRE_first_tail_x6_r0_body.zl150 := PRE_first_tail_x6_r0_body.zimgE150
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl150 : PRE_first_tail_x6_r0_body.s1455.ctl = PRE_first_tail_x6_r0_body.kappa150.ctl PRE_first_tail_x6_r0_body.s1456.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack150 : PRE_first_tail_x6_r0_body.s1455.stack = PRE_first_tail_x6_r0_body.s1456.stack.map PRE_first_tail_x6_r0_body.kappa150.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs150 : PRE_first_tail_x6_r0_body.s1455.jobs = PRE_first_tail_x6_r0_body.s1456.jobs.map PRE_first_tail_x6_r0_body.kappa150.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores150 : PRE_first_tail_x6_r0_body.s1455.stores = PRE_first_tail_x6_r0_body.kappa150.stores PRE_first_tail_x6_r0_body.s1456.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots150 : checkRootsSupp PRE_first_tail_x6_r0_body.s1456 6515 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC150 : PRE_first_tail_x6_r0_body.S1454.tab.length + PRE_first_tail_x6_r0_body.cws150.length = 6515
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap150 : PRE_first_tail_x6_r0_body.kappa150 = Conv.Map.compact PRE_first_tail_x6_r0_body.s1454.next 2794134 PRE_first_tail_x6_r0_body.S1454.tab.length PRE_first_tail_x6_r0_body.pl150 (PRE_first_tail_x6_r0_body.nr150.map NumV.ref) PRE_first_tail_x6_r0_body.kd150.big
  PRE_first_tail_x6_r0_body.kd150.region PRE_first_tail_x6_r0_body.kd150.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin150 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1456.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc150 : Conv.jcleanListB (⟨21165, 18275, 2792985, 6515⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1456 PRE_first_tail_x6_r0_body.cl150 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB150 : noBigRootsP (fun i => !Conv.oldBigB (⟨21165, 18275, 2792985, 6515⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s1456.trace PRE_first_tail_x6_r0_body.s1456 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm150 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 18248 = true
theorem PRE_first_tail_x6_r0_body.cjcl150 (h : Conv.JClean (⟨21162, 18248, 2792979, 6497⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1454) : Conv.JClean (⟨21165, 18275, 2792985, 6515⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1456 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle150)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap150 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd150 a ha)) PRE_first_tail_x6_r0_body.zjc150

end Host.Load.Run.Tpl
end

section -- st150/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st150.bodyLast from PRE_first_tail_x6_r0_body.st150.s4 to PRE_first_tail_x6_r0_body.st150.s5 :
  interpS (step PRE_first_tail_x6_r0_body.st150.F PRE_first_tail_x6_r0_body.st150.s4).run PRE_first_tail_x6_r0_body.st150.S4 = some (PRE_first_tail_x6_r0_body.st150.s5, PRE_first_tail_x6_r0_body.st150.S5)
kernel_rfl PRE_first_tail_x6_r0_body.st150.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st150.s4.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st150.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st150.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st150/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st150.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st150.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st150.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st150.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st150.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st150.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st150.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st150.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st150.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st150.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st150.s0 PRE_first_tail_x6_r0_body.st150.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st150.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st150.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st150.s4 PRE_first_tail_x6_r0_body.st150.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st150/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st150.bodyK0F from PRE_first_tail_x6_r0_body.st150.s0 to PRE_first_tail_x6_r0_body.st150.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st150.F (PRE_first_tail_x6_r0_body.st150.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st150.ks 0).getD 0) PRE_first_tail_x6_r0_body.st150.s0 PRE_first_tail_x6_r0_body.st150.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st150.s1, PRE_first_tail_x6_r0_body.st150.S1)
theorem PRE_first_tail_x6_r0_body.st150.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st150.F (PRE_first_tail_x6_r0_body.st150.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st150.ks 0).getD 0) PRE_first_tail_x6_r0_body.st150.s0 PRE_first_tail_x6_r0_body.st150.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st150.s1, PRE_first_tail_x6_r0_body.st150.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st150.bodyOkLN_ok PRE_first_tail_x6_r0_body.st150.bodyK0F
end Host.Load.Run.Tpl
end

section -- st150/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st150.bodyK1F from PRE_first_tail_x6_r0_body.st150.s1 to PRE_first_tail_x6_r0_body.st150.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st150.F (PRE_first_tail_x6_r0_body.st150.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st150.ks 1).getD 0) PRE_first_tail_x6_r0_body.st150.s1 PRE_first_tail_x6_r0_body.st150.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st150.s2, PRE_first_tail_x6_r0_body.st150.S2)
theorem PRE_first_tail_x6_r0_body.st150.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st150.F (PRE_first_tail_x6_r0_body.st150.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st150.ks 1).getD 0) PRE_first_tail_x6_r0_body.st150.s1 PRE_first_tail_x6_r0_body.st150.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st150.s2, PRE_first_tail_x6_r0_body.st150.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st150.bodyOkLN_ok PRE_first_tail_x6_r0_body.st150.bodyK1F
end Host.Load.Run.Tpl
end

section -- st150/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st150.bodyK2F from PRE_first_tail_x6_r0_body.st150.s2 to PRE_first_tail_x6_r0_body.st150.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st150.F (PRE_first_tail_x6_r0_body.st150.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st150.ks 2).getD 0) PRE_first_tail_x6_r0_body.st150.s2 PRE_first_tail_x6_r0_body.st150.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st150.s3, PRE_first_tail_x6_r0_body.st150.S3)
theorem PRE_first_tail_x6_r0_body.st150.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st150.F (PRE_first_tail_x6_r0_body.st150.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st150.ks 2).getD 0) PRE_first_tail_x6_r0_body.st150.s2 PRE_first_tail_x6_r0_body.st150.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st150.s3, PRE_first_tail_x6_r0_body.st150.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st150.bodyOkLN_ok PRE_first_tail_x6_r0_body.st150.bodyK2F
end Host.Load.Run.Tpl
end

section -- st150/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st150.bodyK3F from PRE_first_tail_x6_r0_body.st150.s3 to PRE_first_tail_x6_r0_body.st150.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st150.F (PRE_first_tail_x6_r0_body.st150.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st150.ks 3).getD 0) PRE_first_tail_x6_r0_body.st150.s3 PRE_first_tail_x6_r0_body.st150.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st150.s4, PRE_first_tail_x6_r0_body.st150.S4)
theorem PRE_first_tail_x6_r0_body.st150.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st150.F (PRE_first_tail_x6_r0_body.st150.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st150.ks 3).getD 0) PRE_first_tail_x6_r0_body.st150.s3 PRE_first_tail_x6_r0_body.st150.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st150.s4, PRE_first_tail_x6_r0_body.st150.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st150.bodyOkLN_ok PRE_first_tail_x6_r0_body.st150.bodyK3F
end Host.Load.Run.Tpl
end

section -- st150/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st150.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st150.F (PRE_first_tail_x6_r0_body.st150.bodyOkL bytes rows) 11334 PRE_first_tail_x6_r0_body.st150.s0 PRE_first_tail_x6_r0_body.st150.S0 = some (PRE_first_tail_x6_r0_body.st150.s4, PRE_first_tail_x6_r0_body.st150.S4) :=
  runOk_trans PRE_first_tail_x6_r0_body.st150.F (PRE_first_tail_x6_r0_body.st150.bodyOkL bytes rows) ((((nth? PRE_first_tail_x6_r0_body.st150.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st150.ks 1).getD 0)) + ((nth? PRE_first_tail_x6_r0_body.st150.ks 2).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st150.ks 3).getD 0) PRE_first_tail_x6_r0_body.st150.s0 PRE_first_tail_x6_r0_body.st150.s3 PRE_first_tail_x6_r0_body.st150.s4 PRE_first_tail_x6_r0_body.st150.S0 PRE_first_tail_x6_r0_body.st150.S3 PRE_first_tail_x6_r0_body.st150.S4 (runOk_trans PRE_first_tail_x6_r0_body.st150.F (PRE_first_tail_x6_r0_body.st150.bodyOkL bytes rows) (((nth? PRE_first_tail_x6_r0_body.st150.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st150.ks 1).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st150.ks 2).getD 0) PRE_first_tail_x6_r0_body.st150.s0 PRE_first_tail_x6_r0_body.st150.s2 PRE_first_tail_x6_r0_body.st150.s3 PRE_first_tail_x6_r0_body.st150.S0 PRE_first_tail_x6_r0_body.st150.S2 PRE_first_tail_x6_r0_body.st150.S3 (runOk_trans PRE_first_tail_x6_r0_body.st150.F (PRE_first_tail_x6_r0_body.st150.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st150.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st150.ks 1).getD 0) PRE_first_tail_x6_r0_body.st150.s0 PRE_first_tail_x6_r0_body.st150.s1 PRE_first_tail_x6_r0_body.st150.s2 PRE_first_tail_x6_r0_body.st150.S0 PRE_first_tail_x6_r0_body.st150.S1 PRE_first_tail_x6_r0_body.st150.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st150.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st150.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st150.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st150.bodyK3 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st150.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st150.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st150.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st150.F (PRE_first_tail_x6_r0_body.st150.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st150.s0
  S0 := PRE_first_tail_x6_r0_body.st150.S0
  s1 := PRE_first_tail_x6_r0_body.st150.s4
  S1 := PRE_first_tail_x6_r0_body.st150.S4
  s2 := PRE_first_tail_x6_r0_body.st150.s5
  S2 := PRE_first_tail_x6_r0_body.st150.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st150.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st150.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st150.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st150.bodyHalt
  last := PRE_first_tail_x6_r0_body.st150.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st150.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC151
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 151 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s1464` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa151` into the merged state
`PRE_first_tail_x6_r0_body.s1463`. -/

def PRE_first_tail_x6_r0_body.pl151 : List Nat := []
def PRE_first_tail_x6_r0_body.nr151 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd151 : RData :=
  ⟨2793475, 2793477, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21178, 21178, 18288, 18288, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa151 : Map :=
  Conv.Map.compact 2793475 2793477 6536 PRE_first_tail_x6_r0_body.pl151 (PRE_first_tail_x6_r0_body.nr151.map NumV.ref) PRE_first_tail_x6_r0_body.kd151.big
    PRE_first_tail_x6_r0_body.kd151.region PRE_first_tail_x6_r0_body.kd151.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws151 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs151 : List SymE := PRE_first_tail_x6_r0_body.nr151.map fun r => (nth? PRE_first_tail_x6_r0_body.S1463.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta151 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws151 PRE_first_tail_x6_r0_body.crs151
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB151 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab151 : PRE_first_tail_x6_r0_body.S1464.tab = PRE_first_tail_x6_r0_body.S1462.tab ++ PRE_first_tail_x6_r0_body.cws151.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace151 : PRE_first_tail_x6_r0_body.s1464.trace = PRE_first_tail_x6_r0_body.s1462.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext151 : PRE_first_tail_x6_r0_body.s1464.next = 2793475
kernel_rfl PRE_first_tail_x6_r0_body.ccounters151 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1464.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1464.ffi).mlx.nnext) = (21178, 18288)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue151 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1463.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1464.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa151.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp151 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1464.ffi).mlx.tokens.all (bSN 6536) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean151 : Conv.cleanListB 21178 131072 (fun r => Nat.ble 84712 r) PRE_first_tail_x6_r0_body.s1464
    (PRE_first_tail_x6_r0_body.wrB151 ++ (List.range 0).map (2793475 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs151 : bigsOutB 21178 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1464.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK151
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl151`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl151 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo151 : List Nat := []
def PRE_first_tail_x6_r0_body.cln151 : List Nat := []
def PRE_first_tail_x6_r0_body.cli151 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap151 : PRE_first_tail_x6_r0_body.s1464.heap = Stage.setAll PRE_first_tail_x6_r0_body.s1462.heap (PRE_first_tail_x6_r0_body.cl151.filterMap fun a => (PRE_first_tail_x6_r0_body.s1464.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe151 : Nat.ble PRE_first_tail_x6_r0_body.s1462.next PRE_first_tail_x6_r0_body.s1464.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP151 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s1462 PRE_first_tail_x6_r0_body.s1464 PRE_first_tail_x6_r0_body.cl151 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp151 : Conv.suppListB PRE_first_tail_x6_r0_body.s1464 6536 PRE_first_tail_x6_r0_body.cl151 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound151 : Conv.boundListB PRE_first_tail_x6_r0_body.s1464 PRE_first_tail_x6_r0_body.cl151 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK151 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1464.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln151.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1464.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK151 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1464.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo151.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1464.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK151 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1464.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli151.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1464.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst151 : Conv.sstListB 6536 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1464.ffi).mlx PRE_first_tail_x6_r0_body.cln151 PRE_first_tail_x6_r0_body.clo151 PRE_first_tail_x6_r0_body.cli151 = true

end Host.Load.Run.Tpl
end

section -- SiteCl151
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA151 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1464.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo151.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1464.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd151 : (PRE_first_tail_x6_r0_body.clo151 ++ PRE_first_tail_x6_r0_body.cln151 ++ PRE_first_tail_x6_r0_body.cli151).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle151 : Conv.Cnt.leB (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck151 : Conv.ncleanListB (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1464.ffi).mlx PRE_first_tail_x6_r0_body.clo151 PRE_first_tail_x6_r0_body.cln151 PRE_first_tail_x6_r0_body.cli151 = true
theorem PRE_first_tail_x6_r0_body.cncl151 (h : Conv.NClean (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx) : Conv.NClean (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1464.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle151 PRE_first_tail_x6_r0_body.ckA151 PRE_first_tail_x6_r0_body.cobjsK151 PRE_first_tail_x6_r0_body.cnodesK151 PRE_first_tail_x6_r0_body.citemsK151 PRE_first_tail_x6_r0_body.cbd151 PRE_first_tail_x6_r0_body.cck151

end Host.Load.Run.Tpl
end

section -- SiteS151
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 151 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc151 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P151 : LoadP := PRE_first_tail_x6_r0_body.Pc151.raise 18288
kernel_rfl PRE_first_tail_x6_r0_body.craise151 : Nat.ble PRE_first_tail_x6_r0_body.Pc151.N0 18288 = true
theorem PRE_first_tail_x6_r0_body.raised151 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc151 PRE_first_tail_x6_r0_body.P151 :=
  .inr ⟨18288, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise151, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_151 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1464.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_151 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1463.ffi)
def PRE_first_tail_x6_r0_body.khinv151 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv151 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS151 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS151 : List Nat := List.range' 18288 0
def PRE_first_tail_x6_r0_body.ciS151 : List Nat := [] ++ List.range' 18288 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh0151 : PRE_first_tail_x6_r0_body.kd151.nh0 = PRE_first_tail_x6_r0_body.cx0_151.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh1151 : PRE_first_tail_x6_r0_body.kd151.nh1 = PRE_first_tail_x6_r0_body.cx1_151.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn0151 : PRE_first_tail_x6_r0_body.kd151.nn0 = PRE_first_tail_x6_r0_body.cx0_151.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn1151 : PRE_first_tail_x6_r0_body.kd151.nn1 = PRE_first_tail_x6_r0_body.cx1_151.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo151 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P151.lo && Nat.ble PRE_first_tail_x6_r0_body.P151.lo PRE_first_tail_x6_r0_body.cx0_151.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P151.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P151.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt151 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_151.mlx.next PRE_first_tail_x6_r0_body.cx1_151.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_151.mlx.nnext PRE_first_tail_x6_r0_body.cx1_151.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband151 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P151.NL && Nat.ble PRE_first_tail_x6_r0_body.P151.NL PRE_first_tail_x6_r0_body.P151.N0 && Nat.ble PRE_first_tail_x6_r0_body.P151.N0 PRE_first_tail_x6_r0_body.cx0_151.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow151 : PRE_first_tail_x6_r0_body.kd151.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren151 : checkRenG PRE_first_tail_x6_r0_body.kd151.hnd PRE_first_tail_x6_r0_body.khinv151 (phB PRE_first_tail_x6_r0_body.cx0_151.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband151 : PRE_first_tail_x6_r0_body.kd151.checkBand PRE_first_tail_x6_r0_body.P151.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos151 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd151.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren151 : checkRenG PRE_first_tail_x6_r0_body.kd151.node PRE_first_tail_x6_r0_body.kninv151 (pnB PRE_first_tail_x6_r0_body.cx0_151.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow151 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd151.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P151.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd151.nodeF j) PRE_first_tail_x6_r0_body.cx1_151.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a151 : PRE_first_tail_x6_r0_body.cx0_151.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b151 : PRE_first_tail_x6_r0_body.cx0_151.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok1151 : PRE_first_tail_x6_r0_body.cx1_151.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend151 : PRE_first_tail_x6_r0_body.cx1_151.mlx.pending = PRE_first_tail_x6_r0_body.cx0_151.mlx.pending.map PRE_first_tail_x6_r0_body.kappa151.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh151 : PRE_first_tail_x6_r0_body.cx1_151.mlx.errh = PRE_first_tail_x6_r0_body.cx0_151.mlx.errh.map PRE_first_tail_x6_r0_body.kappa151.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles151 : PRE_first_tail_x6_r0_body.cx1_151.mlx.files = PRE_first_tail_x6_r0_body.cx0_151.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch151 : PRE_first_tail_x6_r0_body.cx1_151.mlx.arch = PRE_first_tail_x6_r0_body.cx0_151.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes151 : PRE_first_tail_x6_r0_body.cx1_151.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_151.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired151 : PRE_first_tail_x6_r0_body.cx1_151.mlx.wired = PRE_first_tail_x6_r0_body.cx0_151.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost151 : PRE_first_tail_x6_r0_body.cx1_151.host = PRE_first_tail_x6_r0_body.cx0_151.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd151`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn0151 : PRE_first_tail_x6_r0_body.kd151.n0 = 2793475
kernel_rfl PRE_first_tail_x6_r0_body.ckn1151 : PRE_first_tail_x6_r0_body.kd151.n1 = 2793477
kernel_rfl PRE_first_tail_x6_r0_body.ckheap151 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd151.heap).all (fun x => Nat.ble 2793475 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl151 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_body.kd151.heap.get (2793475 + j) = nth? PRE_first_tail_x6_r0_body.pl151 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja151 : Nat.ble 2793475 2793475 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn151 : Nat.ble 6536 6536 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD151 : Nat.ble 2793475 PRE_first_tail_x6_r0_body.kd151.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn151 : Nat.ble 21178 PRE_first_tail_x6_r0_body.kd151.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn151 : Nat.ble 18288 PRE_first_tail_x6_r0_body.kd151.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb151 : Nat.ble 21178 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap151 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd151.heap).all (Nat.ble (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd151 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd151.hnd).all (Nat.ble (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode151 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd151.node).all (Nat.ble (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix151 : Conv.FixOld (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa151 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja151) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn151) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD151) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn151) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn151) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb151) PRE_first_tail_x6_r0_body.fheap151 PRE_first_tail_x6_r0_body.fhnd151 PRE_first_tail_x6_r0_body.fnode151
kernel_rfl PRE_first_tail_x6_r0_body.fcxn151 : (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn151 : (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle0151 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_151.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_151.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk151 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd151.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A151 : PRE_first_tail_x6_r0_body.cx1_151.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS151.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_151.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O151 : PRE_first_tail_x6_r0_body.cx1_151.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS151.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_151.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N151 : PRE_first_tail_x6_r0_body.cx1_151.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS151.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_151.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I151 : PRE_first_tail_x6_r0_body.cx1_151.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS151.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_151.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd151 : (PRE_first_tail_x6_r0_body.clo151 ++ PRE_first_tail_x6_r0_body.cln151 ++ PRE_first_tail_x6_r0_body.cli151 ++ PRE_first_tail_x6_r0_body.cwS151 ++ PRE_first_tail_x6_r0_body.cnS151 ++ PRE_first_tail_x6_r0_body.ciS151).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW151 : PRE_first_tail_x6_r0_body.cwS151.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo151.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI151 : PRE_first_tail_x6_r0_body.ciS151.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli151.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN151 : PRE_first_tail_x6_r0_body.cnS151.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF151 : PRE_first_tail_x6_r0_body.cln151.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh151 : PRE_first_tail_x6_r0_body.clo151.all (handleOK PRE_first_tail_x6_r0_body.kappa151 PRE_first_tail_x6_r0_body.P151.lo PRE_first_tail_x6_r0_body.cx0_151.mlx PRE_first_tail_x6_r0_body.cx1_151.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo151 : PRE_first_tail_x6_r0_body.clo151.map (fun h => PRE_first_tail_x6_r0_body.cx1_151.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa151.handle h)) = PRE_first_tail_x6_r0_body.clo151.map (fun h => (PRE_first_tail_x6_r0_body.cx0_151.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa151.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok151 : PRE_first_tail_x6_r0_body.clo151.all (objOK PRE_first_tail_x6_r0_body.kappa151 PRE_first_tail_x6_r0_body.P151.NL PRE_first_tail_x6_r0_body.cx0_151.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd151 : PRE_first_tail_x6_r0_body.cln151.all (nodeOKF PRE_first_tail_x6_r0_body.kappa151 PRE_first_tail_x6_r0_body.P151 PRE_first_tail_x6_r0_body.cx0_151.mlx PRE_first_tail_x6_r0_body.cx1_151.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp151 : ((PRE_first_tail_x6_r0_body.cln151.filter (fullB PRE_first_tail_x6_r0_body.P151))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_151.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa151.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln151.filter (fullB PRE_first_tail_x6_r0_body.P151))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_151.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa151.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI151 : incrB PRE_first_tail_x6_r0_body.kd151.nodeF (List.range' 18288 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK151 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd151.node).all (fun k => Nat.ble 18288 k && Nat.blt k 18288) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL151 : (PRE_first_tail_x6_r0_body.cln151.filter (Nat.ble PRE_first_tail_x6_r0_body.P151.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd151.nodeF i) && (Nat.blt i 18288 || Nat.ble PRE_first_tail_x6_r0_body.kd151.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord151 : (PRE_first_tail_x6_r0_body.cln151.filter (Nat.ble PRE_first_tail_x6_r0_body.P151.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd151.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd151.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd151.nodeF j) (PRE_first_tail_x6_r0_body.kd151.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow151 PRE_first_tail_x6_r0_body.cnn1151 PRE_first_tail_x6_r0_body.fnordI151 PRE_first_tail_x6_r0_body.fnordK151 PRE_first_tail_x6_r0_body.fnordL151
kernel_rfl PRE_first_tail_x6_r0_body.fi151 : PRE_first_tail_x6_r0_body.cli151.all (pnB PRE_first_tail_x6_r0_body.cx0_151.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii151 : PRE_first_tail_x6_r0_body.cli151.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_151.mlx.items.get (PRE_first_tail_x6_r0_body.kappa151.node k) = (PRE_first_tail_x6_r0_body.cx0_151.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa151.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot151 (clean : Conv.NClean (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P151.NL) (cl : SSt (· < 6536) PRE_first_tail_x6_r0_body.cx0_151.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P151 6536 PRE_first_tail_x6_r0_body.kappa151 PRE_first_tail_x6_r0_body.kd151 PRE_first_tail_x6_r0_body.khinv151 PRE_first_tail_x6_r0_body.kninv151 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx PRE_first_tail_x6_r0_body.cx0_151.mlx PRE_first_tail_x6_r0_body.cx1_151.mlx (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo151 PRE_first_tail_x6_r0_body.cln151 PRE_first_tail_x6_r0_body.cli151 PRE_first_tail_x6_r0_body.cwS151 PRE_first_tail_x6_r0_body.cnS151 PRE_first_tail_x6_r0_body.ciS151 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh0151, PRE_first_tail_x6_r0_body.cnh1151, PRE_first_tail_x6_r0_body.cnn0151, PRE_first_tail_x6_r0_body.cnn1151, PRE_first_tail_x6_r0_body.cplo151, PRE_first_tail_x6_r0_body.ccnt151, PRE_first_tail_x6_r0_body.cnband151, PRE_first_tail_x6_r0_body.chbelow151, PRE_first_tail_x6_r0_body.chren151, PRE_first_tail_x6_r0_body.cband151, PRE_first_tail_x6_r0_body.cnh1pos151, PRE_first_tail_x6_r0_body.cnren151, PRE_first_tail_x6_r0_body.cnlow151, PRE_first_tail_x6_r0_body.cabs0a151, PRE_first_tail_x6_r0_body.cabs0b151, PRE_first_tail_x6_r0_body.ctok1151, PRE_first_tail_x6_r0_body.cpend151, PRE_first_tail_x6_r0_body.cerrh151, PRE_first_tail_x6_r0_body.cfiles151, PRE_first_tail_x6_r0_body.carch151, PRE_first_tail_x6_r0_body.csizes151, PRE_first_tail_x6_r0_body.cwired151, PRE_first_tail_x6_r0_body.cfix151, clean, PRE_first_tail_x6_r0_body.fcxn151, PRE_first_tail_x6_r0_body.fcnn151, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle0151, PRE_first_tail_x6_r0_body.fnk151, PRE_first_tail_x6_r0_body.ckA151, PRE_first_tail_x6_r0_body.cobjsK151, PRE_first_tail_x6_r0_body.cnodesK151, PRE_first_tail_x6_r0_body.citemsK151, PRE_first_tail_x6_r0_body.f1A151, PRE_first_tail_x6_r0_body.f1O151, PRE_first_tail_x6_r0_body.f1N151, PRE_first_tail_x6_r0_body.f1I151, PRE_first_tail_x6_r0_body.fbd151, PRE_first_tail_x6_r0_body.fincW151, PRE_first_tail_x6_r0_body.fincI151, PRE_first_tail_x6_r0_body.fincN151, PRE_first_tail_x6_r0_body.flnF151, PRE_first_tail_x6_r0_body.fh151, PRE_first_tail_x6_r0_body.fo151, PRE_first_tail_x6_r0_body.fok151, PRE_first_tail_x6_r0_body.fnd151, PRE_first_tail_x6_r0_body.fp151, PRE_first_tail_x6_r0_body.fnord151, PRE_first_tail_x6_r0_body.fi151, PRE_first_tail_x6_r0_body.fii151⟩
theorem PRE_first_tail_x6_r0_body.cnshift151 (clean : Conv.NClean (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P151.NL) (cl : SSt (· < 6536) PRE_first_tail_x6_r0_body.cx0_151.mlx) : NShift PRE_first_tail_x6_r0_body.P151 6536 PRE_first_tail_x6_r0_body.kappa151 PRE_first_tail_x6_r0_body.cx0_151 PRE_first_tail_x6_r0_body.cx1_151 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot151 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost151 (compact_a_eq PRE_first_tail_x6_r0_body.ckn0151 PRE_first_tail_x6_r0_body.ckn1151 PRE_first_tail_x6_r0_body.ckheap151 PRE_first_tail_x6_r0_body.ckpl151)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_151 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1462.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_151 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1462.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_151 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1462.ffi) = some PRE_first_tail_x6_r0_body.fxC_151
kernel_rfl PRE_first_tail_x6_r0_body.okrC_151 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1462.ffi) = some PRE_first_tail_x6_r0_body.krC_151
noncomputable def PRE_first_tail_x6_r0_body.fx0_151 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1464.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_151 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1464.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_151 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1464.ffi) = some PRE_first_tail_x6_r0_body.fx0_151
kernel_rfl PRE_first_tail_x6_r0_body.okr0_151 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1464.ffi) = some PRE_first_tail_x6_r0_body.kr0_151
noncomputable def PRE_first_tail_x6_r0_body.fx1_151 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1463.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_151 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1463.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_151 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1463.ffi) = some PRE_first_tail_x6_r0_body.fx1_151
kernel_rfl PRE_first_tail_x6_r0_body.okr1_151 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1463.ffi) = some PRE_first_tail_x6_r0_body.kr1_151
kernel_rfl PRE_first_tail_x6_r0_body.ff0151 : PRE_first_tail_x6_r0_body.fx0_151 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_151 (PRE_first_tail_x6_r0_body.clo151.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_151.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff1151 : PRE_first_tail_x6_r0_body.fx1_151 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_151 (PRE_first_tail_x6_r0_body.cwS151.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_151.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck151 : freedLB PRE_first_tail_x6_r0_body.kappa151 PRE_first_tail_x6_r0_body.cx0_151.mlx PRE_first_tail_x6_r0_body.fx0_151 PRE_first_tail_x6_r0_body.fx1_151 PRE_first_tail_x6_r0_body.clo151 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf0151 : PRE_first_tail_x6_r0_body.kr0_151.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_151.flags (PRE_first_tail_x6_r0_body.clo151.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_151.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt0151 : PRE_first_tail_x6_r0_body.kr0_151.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_151.targs (PRE_first_tail_x6_r0_body.clo151.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_151.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf1151 : PRE_first_tail_x6_r0_body.kr1_151.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_151.flags (PRE_first_tail_x6_r0_body.cwS151.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_151.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt1151 : PRE_first_tail_x6_r0_body.kr1_151.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_151.targs (PRE_first_tail_x6_r0_body.cwS151.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_151.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck151 : krecLB PRE_first_tail_x6_r0_body.kappa151 6536 PRE_first_tail_x6_r0_body.cx0_151.mlx PRE_first_tail_x6_r0_body.kr0_151 PRE_first_tail_x6_r0_body.kr1_151 PRE_first_tail_x6_r0_body.clo151 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn151 : Nat.ble 6536 6536 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge151 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1463.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1464.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR151 : pendRegB PRE_first_tail_x6_r0_body.kappa151 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1464.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe151 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1464.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1463.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift151 (clean : Conv.NClean (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P151.NL) (cl : SSt (· < 6536) PRE_first_tail_x6_r0_body.cx0_151.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_151.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_151.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_151.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1462.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_151.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P151 6536 PRE_first_tail_x6_r0_body.kappa151 PRE_first_tail_x6_r0_body.s1464.ffi PRE_first_tail_x6_r0_body.s1463.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift151 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue151, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp151 t ht),
    PRE_first_tail_x6_r0_body.cbridge151,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1464.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1463.ffi) (PRE_first_tail_x6_r0_body.cfoot151 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_151 PRE_first_tail_x6_r0_body.ofx1_151 hobjC PRE_first_tail_x6_r0_body.ff0151 PRE_first_tail_x6_r0_body.ff1151 PRE_first_tail_x6_r0_body.ffck151,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1464.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1463.ffi) (PRE_first_tail_x6_r0_body.cfoot151 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_151 PRE_first_tail_x6_r0_body.okr1_151 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn151) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf0151 PRE_first_tail_x6_r0_body.fkt0151 PRE_first_tail_x6_r0_body.fkf1151 PRE_first_tail_x6_r0_body.fkt1151 PRE_first_tail_x6_r0_body.fkck151,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh0151 PRE_first_tail_x6_r0_body.cnh1151 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe151) PRE_first_tail_x6_r0_body.cpendR151⟩

end Host.Load.Run.Tpl
end

section -- st151/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st151 0
host_stream_state PRE_first_tail_x6_r0_body.st151 1
host_stream_state PRE_first_tail_x6_r0_body.st151 2
end Host.Load.Run.Tpl
end

section -- Site151
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 151 of chain `PRE_first_tail_x6_r0_body`: `rowBlocks__g151__g152` (`rowBlocks`), the call state `PRE_first_tail_x6_r0_body.s1462`, the merged state `PRE_first_tail_x6_r0_body.s1463`,
the site template `PRE_first_tail_x6_r0_body.st151` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s1464`: the merge.
The footprint's facts are in `SiteF151`, the compaction's in `SiteC151`, `SiteK151`, `SiteNa151`, `SiteNb151`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso151 : PRE_first_tail_x6_r0_body.st151.s0 = { PRE_first_tail_x6_r0_body.s1462 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs151 : List Frame := PRE_first_tail_x6_r0_body.s1462.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_151 : PRE_first_tail_x6_r0_body.S1462.tab.length = 6536
kernel_rfl PRE_first_tail_x6_r0_body.tab0_151 : PRE_first_tail_x6_r0_body.st151.S0.tab = PRE_first_tail_x6_r0_body.S1462.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws151 : List Nat := [3569, 3570]
kernel_rfl PRE_first_tail_x6_r0_body.fresh151 : (PRE_first_tail_x6_r0_body.S1462.tab.all fun e => PRE_first_tail_x6_r0_body.ws151.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S1462.oracle.all fun q => PRE_first_tail_x6_r0_body.ws151.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab151 : PRE_first_tail_x6_r0_body.S1463.tab = PRE_first_tail_x6_r0_body.S1462.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws151
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen151 : PRE_first_tail_x6_r0_body.st151.S2.tab.length - PRE_first_tail_x6_r0_body.st151.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged151`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap151 : PRE_first_tail_x6_r0_body.s1463.heap = PRE_first_tail_x6_r0_body.st151.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext151 : PRE_first_tail_x6_r0_body.s1463.next = PRE_first_tail_x6_r0_body.st151.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl151 : PRE_first_tail_x6_r0_body.s1463.ctl = PRE_first_tail_x6_r0_body.st151.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack151 : PRE_first_tail_x6_r0_body.s1463.stack = PRE_first_tail_x6_r0_body.st151.s2.stack ++ PRE_first_tail_x6_r0_body.s1462.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs151 : PRE_first_tail_x6_r0_body.s1463.jobs = PRE_first_tail_x6_r0_body.st151.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi151 : PRE_first_tail_x6_r0_body.s1463.ffi = PRE_first_tail_x6_r0_body.st151.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace151 : PRE_first_tail_x6_r0_body.s1463.trace = PRE_first_tail_x6_r0_body.st151.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores151 : PRE_first_tail_x6_r0_body.s1463.stores = PRE_first_tail_x6_r0_body.st151.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD151
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 151 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived151 : PRE_first_tail_x6_r0_body.nr151.map (fun r => nth? PRE_first_tail_x6_r0_body.st151.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo151 : PRE_first_tail_x6_r0_body.nr151.all (Nat.ble 6536) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj151 : PRE_first_tail_x6_r0_body.cws151.all (fun c => !PRE_first_tail_x6_r0_body.ws151.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ151 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws151 PRE_first_tail_x6_r0_body.crs151 PRE_first_tail_x6_r0_body.ws151

end Host.Load.Run.Tpl
end

section -- st151/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st151`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st151.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st151.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st151.s2.heap PRE_first_tail_x6_r0_body.st151.wrR ++ freshOf PRE_first_tail_x6_r0_body.st151.s2.heap PRE_first_tail_x6_r0_body.st151.s0.next PRE_first_tail_x6_r0_body.st151.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st151.wr : List Nat := PRE_first_tail_x6_r0_body.st151.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st151.heapFoot : PRE_first_tail_x6_r0_body.st151.s2.heap = setAll PRE_first_tail_x6_r0_body.st151.s0.heap PRE_first_tail_x6_r0_body.st151.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st151.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st151.s0.next PRE_first_tail_x6_r0_body.st151.s2.next = true
theorem PRE_first_tail_x6_r0_body.st151.grows : PRE_first_tail_x6_r0_body.st151.s0.next ≤ PRE_first_tail_x6_r0_body.st151.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st151.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st151.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st151.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st151.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st151.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st151.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st151.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st151.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st151.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st151.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st151.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st151.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st151.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st151.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st151.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st151.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st151.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st151.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st151.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st151.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st151.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st151.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st151.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st151.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st151.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st151.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st151.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st151.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st151.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st151.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st151.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st151.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF151
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 151 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB151 : nodupT PRE_first_tail_x6_r0_body.st151.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup151 : PRE_first_tail_x6_r0_body.st151.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB151).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB151 : PRE_first_tail_x6_r0_body.st151.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound151 : ∀ b ∈ PRE_first_tail_x6_r0_body.st151.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB151 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr151 := PRE_first_tail_x6_r0_body.st151.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq151 : PRE_first_tail_x6_r0_body.st151.s2.trace = PRE_first_tail_x6_r0_body.trFr151 ++ PRE_first_tail_x6_r0_body.st151.s0.trace
theorem PRE_first_tail_x6_r0_body.trace151 : ∃ fr, PRE_first_tail_x6_r0_body.st151.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st151.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq151⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide151 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB151 : (PRE_first_tail_x6_r0_body.wide151.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st151.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix151 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide151, WFix Map.id (Present PRE_first_tail_x6_r0_body.st151.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB151 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL151
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 151 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s1463`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO151 : PRE_first_tail_x6_r0_body.st151.S0.oracle = PRE_first_tail_x6_r0_body.st151.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B151 : PRE_first_tail_x6_r0_body.st151.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st151.s0.next || (PRE_first_tail_x6_r0_body.st151.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot151 : Conv.StageFoot PRE_first_tail_x6_r0_body.st151.wr PRE_first_tail_x6_r0_body.st151.s0 PRE_first_tail_x6_r0_body.st151.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st151.heapFoot PRE_first_tail_x6_r0_body.wrNodup151 PRE_first_tail_x6_r0_body.wrBound151 PRE_first_tail_x6_r0_body.wr0B151 PRE_first_tail_x6_r0_body.st151.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged151 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st151.F.S → PRE_first_tail_x6_r0_body.st151.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st151.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st151.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs151 PRE_first_tail_x6_r0_body.st151.wr PRE_first_tail_x6_r0_body.s1462 PRE_first_tail_x6_r0_body.st151.s2 PRE_first_tail_x6_r0_body.st151.s0
      PRE_first_tail_x6_r0_body.st151.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st151.F FR W stk M ν K PRE_first_tail_x6_r0_body.s1463 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso151 PRE_first_tail_x6_r0_body.stFoot151 PRE_first_tail_x6_r0_body.wrNodup151 PRE_first_tail_x6_r0_body.wrBound151 PRE_first_tail_x6_r0_body.trace151 PRE_first_tail_x6_r0_body.mheap151
    PRE_first_tail_x6_r0_body.mnext151 PRE_first_tail_x6_r0_body.mctl151 PRE_first_tail_x6_r0_body.mstack151 PRE_first_tail_x6_r0_body.mjobs151 PRE_first_tail_x6_r0_body.mffi151 PRE_first_tail_x6_r0_body.mtrace151 PRE_first_tail_x6_r0_body.mstores151 h

def PRE_first_tail_x6_r0_body.arrEl151_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE151_2665 : arrOf PRE_first_tail_x6_r0_body.s1463 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl151_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA151_2665 : isArrB PRE_first_tail_x6_r0_body.s1463 2665 = true
theorem PRE_first_tail_x6_r0_body.arr151_2665 : ∃ o, PRE_first_tail_x6_r0_body.s1463.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl151_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE151_2665 PRE_first_tail_x6_r0_body.arrA151_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN151_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl151_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR151_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl151_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN151_2665

def PRE_first_tail_x6_r0_body.arrEl151_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE151_2673467 : arrOf PRE_first_tail_x6_r0_body.s1463 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl151_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA151_2673467 : isArrB PRE_first_tail_x6_r0_body.s1463 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr151_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s1463.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl151_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE151_2673467 PRE_first_tail_x6_r0_body.arrA151_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN151_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl151_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR151_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl151_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN151_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k151 : isArrB PRE_first_tail_x6_r0_body.s1463 4910 = false
theorem PRE_first_tail_x6_r0_body.keep151 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s1463 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k151 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr151_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl151_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ151
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 151 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s1462`, the merged
state `PRE_first_tail_x6_r0_body.s1463`, the canonical state `PRE_first_tail_x6_r0_body.s1464`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl151 : PRE_first_tail_x6_r0_body.pl151.all (Nat.ble PRE_first_tail_x6_r0_body.s1462.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd151 : nodupT PRE_first_tail_x6_r0_body.pl151 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn1151 : Nat.ble PRE_first_tail_x6_r0_body.s1462.next 2793477 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst151 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s1462.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn151 : PRE_first_tail_x6_r0_body.s1464.next = PRE_first_tail_x6_r0_body.s1462.next + PRE_first_tail_x6_r0_body.pl151.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn151 : PRE_first_tail_x6_r0_body.s1463.next = 2793477
kernel_rfl PRE_first_tail_x6_r0_body.zgrow151 : Nat.ble PRE_first_tail_x6_r0_body.s1464.next PRE_first_tail_x6_r0_body.s1463.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh151 : PRE_first_tail_x6_r0_body.S1462.tab.all (fun e => PRE_first_tail_x6_r0_body.cws151.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd151 : nodupT PRE_first_tail_x6_r0_body.cws151 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi151 : PRE_first_tail_x6_r0_body.nr151.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S1463.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt151 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s1462.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg151_2665 : PRE_first_tail_x6_r0_body.s1464.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1464 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk151_2665 : (objOf PRE_first_tail_x6_r0_body.s1464 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm151_2665 : PRE_first_tail_x6_r0_body.s1463.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa151.obj (objOf PRE_first_tail_x6_r0_body.s1464 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s1463 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg151_2673467 : PRE_first_tail_x6_r0_body.s1464.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1464 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk151_2673467 : (objOf PRE_first_tail_x6_r0_body.s1464 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm151_2673467 : PRE_first_tail_x6_r0_body.s1463.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa151.obj (objOf PRE_first_tail_x6_r0_body.s1464 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s1463 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw151_4910 : (PRE_first_tail_x6_r0_body.s1464.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw151_2673472 : (PRE_first_tail_x6_r0_body.s1464.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw151_2673473 : (PRE_first_tail_x6_r0_body.s1464.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd151 : PRE_first_tail_x6_r0_body.cl151.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr151 : PRE_first_tail_x6_r0_body.st151.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s1462.next || PRE_first_tail_x6_r0_body.cl151.contains b) = true
def PRE_first_tail_x6_r0_body.zl151 : List Nat := PRE_first_tail_x6_r0_body.cl151.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE151 : PRE_first_tail_x6_r0_body.zl151.map (fun a => PRE_first_tail_x6_r0_body.s1463.heap.get (PRE_first_tail_x6_r0_body.kappa151.a a)) = PRE_first_tail_x6_r0_body.zl151.map (fun a => (PRE_first_tail_x6_r0_body.s1464.heap.get a).map PRE_first_tail_x6_r0_body.kappa151.hobj)
theorem PRE_first_tail_x6_r0_body.zimg151 : HeapImg PRE_first_tail_x6_r0_body.kappa151 PRE_first_tail_x6_r0_body.s1464 PRE_first_tail_x6_r0_body.s1463 PRE_first_tail_x6_r0_body.zl151 := PRE_first_tail_x6_r0_body.zimgE151
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl151 : PRE_first_tail_x6_r0_body.s1463.ctl = PRE_first_tail_x6_r0_body.kappa151.ctl PRE_first_tail_x6_r0_body.s1464.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack151 : PRE_first_tail_x6_r0_body.s1463.stack = PRE_first_tail_x6_r0_body.s1464.stack.map PRE_first_tail_x6_r0_body.kappa151.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs151 : PRE_first_tail_x6_r0_body.s1463.jobs = PRE_first_tail_x6_r0_body.s1464.jobs.map PRE_first_tail_x6_r0_body.kappa151.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores151 : PRE_first_tail_x6_r0_body.s1463.stores = PRE_first_tail_x6_r0_body.kappa151.stores PRE_first_tail_x6_r0_body.s1464.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots151 : checkRootsSupp PRE_first_tail_x6_r0_body.s1464 6536 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC151 : PRE_first_tail_x6_r0_body.S1462.tab.length + PRE_first_tail_x6_r0_body.cws151.length = 6536
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap151 : PRE_first_tail_x6_r0_body.kappa151 = Conv.Map.compact PRE_first_tail_x6_r0_body.s1462.next 2793477 PRE_first_tail_x6_r0_body.S1462.tab.length PRE_first_tail_x6_r0_body.pl151 (PRE_first_tail_x6_r0_body.nr151.map NumV.ref) PRE_first_tail_x6_r0_body.kd151.big
  PRE_first_tail_x6_r0_body.kd151.region PRE_first_tail_x6_r0_body.kd151.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin151 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1464.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc151 : Conv.jcleanListB (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1464 PRE_first_tail_x6_r0_body.cl151 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB151 : noBigRootsP (fun i => !Conv.oldBigB (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s1464.trace PRE_first_tail_x6_r0_body.s1464 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm151 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 18288 = true
theorem PRE_first_tail_x6_r0_body.cjcl151 (h : Conv.JClean (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1462) : Conv.JClean (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1464 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle151)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap151 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd151 a ha)) PRE_first_tail_x6_r0_body.zjc151

end Host.Load.Run.Tpl
end

section -- st151/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st151.bodyLast from PRE_first_tail_x6_r0_body.st151.s1 to PRE_first_tail_x6_r0_body.st151.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st151.F PRE_first_tail_x6_r0_body.st151.s1).run PRE_first_tail_x6_r0_body.st151.S1 = some (PRE_first_tail_x6_r0_body.st151.s2, PRE_first_tail_x6_r0_body.st151.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st151.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st151.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st151.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st151.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st151/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st151.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st151.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st151.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st151.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st151.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st151.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st151.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st151.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st151.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st151.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st151.s0 PRE_first_tail_x6_r0_body.st151.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st151.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st151.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st151.s1 PRE_first_tail_x6_r0_body.st151.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st151/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st151.bodyK0F from PRE_first_tail_x6_r0_body.st151.s0 to PRE_first_tail_x6_r0_body.st151.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st151.F (PRE_first_tail_x6_r0_body.st151.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st151.ks 0).getD 0) PRE_first_tail_x6_r0_body.st151.s0 PRE_first_tail_x6_r0_body.st151.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st151.s1, PRE_first_tail_x6_r0_body.st151.S1)
theorem PRE_first_tail_x6_r0_body.st151.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st151.F (PRE_first_tail_x6_r0_body.st151.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st151.ks 0).getD 0) PRE_first_tail_x6_r0_body.st151.s0 PRE_first_tail_x6_r0_body.st151.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st151.s1, PRE_first_tail_x6_r0_body.st151.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st151.bodyOkLN_ok PRE_first_tail_x6_r0_body.st151.bodyK0F
end Host.Load.Run.Tpl
end

section -- st151/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st151.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st151.F (PRE_first_tail_x6_r0_body.st151.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st151.s0 PRE_first_tail_x6_r0_body.st151.S0 = some (PRE_first_tail_x6_r0_body.st151.s1, PRE_first_tail_x6_r0_body.st151.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st151.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st151.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st151.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st151.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st151.F (PRE_first_tail_x6_r0_body.st151.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st151.s0
  S0 := PRE_first_tail_x6_r0_body.st151.S0
  s1 := PRE_first_tail_x6_r0_body.st151.s1
  S1 := PRE_first_tail_x6_r0_body.st151.S1
  s2 := PRE_first_tail_x6_r0_body.st151.s2
  S2 := PRE_first_tail_x6_r0_body.st151.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st151.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st151.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st151.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st151.bodyHalt
  last := PRE_first_tail_x6_r0_body.st151.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st151.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC152
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 152 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s1468` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa152` into the merged state
`PRE_first_tail_x6_r0_body.s1467`. -/

def PRE_first_tail_x6_r0_body.pl152 : List Nat := [2793773]
def PRE_first_tail_x6_r0_body.nr152 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd152 : RData :=
  ⟨2793764, 2793774, Stage.setAll PTrie.nil [(2793763, 2793773)], Stage.setAll PTrie.nil [],
   21185, 21185, 18292, 18292, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa152 : Map :=
  Conv.Map.compact 2793763 2793774 6553 PRE_first_tail_x6_r0_body.pl152 (PRE_first_tail_x6_r0_body.nr152.map NumV.ref) PRE_first_tail_x6_r0_body.kd152.big
    PRE_first_tail_x6_r0_body.kd152.region PRE_first_tail_x6_r0_body.kd152.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws152 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs152 : List SymE := PRE_first_tail_x6_r0_body.nr152.map fun r => (nth? PRE_first_tail_x6_r0_body.S1467.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta152 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws152 PRE_first_tail_x6_r0_body.crs152
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB152 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab152 : PRE_first_tail_x6_r0_body.S1468.tab = PRE_first_tail_x6_r0_body.S1466.tab ++ PRE_first_tail_x6_r0_body.cws152.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace152 : PRE_first_tail_x6_r0_body.s1468.trace = PRE_first_tail_x6_r0_body.s1466.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext152 : PRE_first_tail_x6_r0_body.s1468.next = 2793764
kernel_rfl PRE_first_tail_x6_r0_body.ccounters152 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1468.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1468.ffi).mlx.nnext) = (21185, 18292)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue152 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1467.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1468.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa152.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp152 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1468.ffi).mlx.tokens.all (bSN 6553) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean152 : Conv.cleanListB 21185 131072 (fun r => Nat.ble 84740 r) PRE_first_tail_x6_r0_body.s1468
    (PRE_first_tail_x6_r0_body.wrB152 ++ (List.range 1).map (2793763 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs152 : bigsOutB 21185 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1468.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK152
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl152`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl152 : List Nat := [2665, 2673467, 2793763]
def PRE_first_tail_x6_r0_body.clo152 : List Nat := []
def PRE_first_tail_x6_r0_body.cln152 : List Nat := []
def PRE_first_tail_x6_r0_body.cli152 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap152 : PRE_first_tail_x6_r0_body.s1468.heap = Stage.setAll PRE_first_tail_x6_r0_body.s1466.heap (PRE_first_tail_x6_r0_body.cl152.filterMap fun a => (PRE_first_tail_x6_r0_body.s1468.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe152 : Nat.ble PRE_first_tail_x6_r0_body.s1466.next PRE_first_tail_x6_r0_body.s1468.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP152 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s1466 PRE_first_tail_x6_r0_body.s1468 PRE_first_tail_x6_r0_body.cl152 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp152 : Conv.suppListB PRE_first_tail_x6_r0_body.s1468 6553 PRE_first_tail_x6_r0_body.cl152 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound152 : Conv.boundListB PRE_first_tail_x6_r0_body.s1468 PRE_first_tail_x6_r0_body.cl152 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK152 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1468.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln152.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1468.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK152 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1468.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo152.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1468.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK152 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1468.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli152.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1468.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst152 : Conv.sstListB 6553 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1468.ffi).mlx PRE_first_tail_x6_r0_body.cln152 PRE_first_tail_x6_r0_body.clo152 PRE_first_tail_x6_r0_body.cli152 = true

end Host.Load.Run.Tpl
end

section -- SiteCl152
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA152 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1468.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo152.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1468.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd152 : (PRE_first_tail_x6_r0_body.clo152 ++ PRE_first_tail_x6_r0_body.cln152 ++ PRE_first_tail_x6_r0_body.cli152).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle152 : Conv.Cnt.leB (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt) (⟨21185, 18292, 2793764, 6553⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck152 : Conv.ncleanListB (⟨21185, 18292, 2793764, 6553⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1468.ffi).mlx PRE_first_tail_x6_r0_body.clo152 PRE_first_tail_x6_r0_body.cln152 PRE_first_tail_x6_r0_body.cli152 = true
theorem PRE_first_tail_x6_r0_body.cncl152 (h : Conv.NClean (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx) : Conv.NClean (⟨21185, 18292, 2793764, 6553⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1468.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle152 PRE_first_tail_x6_r0_body.ckA152 PRE_first_tail_x6_r0_body.cobjsK152 PRE_first_tail_x6_r0_body.cnodesK152 PRE_first_tail_x6_r0_body.citemsK152 PRE_first_tail_x6_r0_body.cbd152 PRE_first_tail_x6_r0_body.cck152

end Host.Load.Run.Tpl
end

section -- SiteS152
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 152 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc152 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P152 : LoadP := PRE_first_tail_x6_r0_body.Pc152.raise 18292
kernel_rfl PRE_first_tail_x6_r0_body.craise152 : Nat.ble PRE_first_tail_x6_r0_body.Pc152.N0 18292 = true
theorem PRE_first_tail_x6_r0_body.raised152 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc152 PRE_first_tail_x6_r0_body.P152 :=
  .inr ⟨18292, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise152, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_152 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1468.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_152 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1467.ffi)
def PRE_first_tail_x6_r0_body.khinv152 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv152 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS152 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS152 : List Nat := List.range' 18292 0
def PRE_first_tail_x6_r0_body.ciS152 : List Nat := [] ++ List.range' 18292 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh0152 : PRE_first_tail_x6_r0_body.kd152.nh0 = PRE_first_tail_x6_r0_body.cx0_152.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh1152 : PRE_first_tail_x6_r0_body.kd152.nh1 = PRE_first_tail_x6_r0_body.cx1_152.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn0152 : PRE_first_tail_x6_r0_body.kd152.nn0 = PRE_first_tail_x6_r0_body.cx0_152.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn1152 : PRE_first_tail_x6_r0_body.kd152.nn1 = PRE_first_tail_x6_r0_body.cx1_152.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo152 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P152.lo && Nat.ble PRE_first_tail_x6_r0_body.P152.lo PRE_first_tail_x6_r0_body.cx0_152.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P152.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P152.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt152 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_152.mlx.next PRE_first_tail_x6_r0_body.cx1_152.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_152.mlx.nnext PRE_first_tail_x6_r0_body.cx1_152.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband152 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P152.NL && Nat.ble PRE_first_tail_x6_r0_body.P152.NL PRE_first_tail_x6_r0_body.P152.N0 && Nat.ble PRE_first_tail_x6_r0_body.P152.N0 PRE_first_tail_x6_r0_body.cx0_152.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow152 : PRE_first_tail_x6_r0_body.kd152.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren152 : checkRenG PRE_first_tail_x6_r0_body.kd152.hnd PRE_first_tail_x6_r0_body.khinv152 (phB PRE_first_tail_x6_r0_body.cx0_152.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband152 : PRE_first_tail_x6_r0_body.kd152.checkBand PRE_first_tail_x6_r0_body.P152.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos152 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd152.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren152 : checkRenG PRE_first_tail_x6_r0_body.kd152.node PRE_first_tail_x6_r0_body.kninv152 (pnB PRE_first_tail_x6_r0_body.cx0_152.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow152 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd152.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P152.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd152.nodeF j) PRE_first_tail_x6_r0_body.cx1_152.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a152 : PRE_first_tail_x6_r0_body.cx0_152.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b152 : PRE_first_tail_x6_r0_body.cx0_152.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok1152 : PRE_first_tail_x6_r0_body.cx1_152.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend152 : PRE_first_tail_x6_r0_body.cx1_152.mlx.pending = PRE_first_tail_x6_r0_body.cx0_152.mlx.pending.map PRE_first_tail_x6_r0_body.kappa152.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh152 : PRE_first_tail_x6_r0_body.cx1_152.mlx.errh = PRE_first_tail_x6_r0_body.cx0_152.mlx.errh.map PRE_first_tail_x6_r0_body.kappa152.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles152 : PRE_first_tail_x6_r0_body.cx1_152.mlx.files = PRE_first_tail_x6_r0_body.cx0_152.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch152 : PRE_first_tail_x6_r0_body.cx1_152.mlx.arch = PRE_first_tail_x6_r0_body.cx0_152.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes152 : PRE_first_tail_x6_r0_body.cx1_152.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_152.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired152 : PRE_first_tail_x6_r0_body.cx1_152.mlx.wired = PRE_first_tail_x6_r0_body.cx0_152.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost152 : PRE_first_tail_x6_r0_body.cx1_152.host = PRE_first_tail_x6_r0_body.cx0_152.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd152`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn0152 : PRE_first_tail_x6_r0_body.kd152.n0 = 2793764
kernel_rfl PRE_first_tail_x6_r0_body.ckn1152 : PRE_first_tail_x6_r0_body.kd152.n1 = 2793774
kernel_rfl PRE_first_tail_x6_r0_body.ckheap152 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd152.heap).all (fun x => Nat.ble 2793763 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl152 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd152.heap.get (2793763 + j) = nth? PRE_first_tail_x6_r0_body.pl152 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja152 : Nat.ble 2793763 2793763 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn152 : Nat.ble 6553 6553 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD152 : Nat.ble 2793763 PRE_first_tail_x6_r0_body.kd152.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn152 : Nat.ble 21185 PRE_first_tail_x6_r0_body.kd152.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn152 : Nat.ble 18292 PRE_first_tail_x6_r0_body.kd152.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb152 : Nat.ble 21185 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap152 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd152.heap).all (Nat.ble (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd152 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd152.hnd).all (Nat.ble (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode152 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd152.node).all (Nat.ble (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix152 : Conv.FixOld (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa152 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja152) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn152) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD152) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn152) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn152) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb152) PRE_first_tail_x6_r0_body.fheap152 PRE_first_tail_x6_r0_body.fhnd152 PRE_first_tail_x6_r0_body.fnode152
kernel_rfl PRE_first_tail_x6_r0_body.fcxn152 : (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn152 : (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle0152 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_152.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_152.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk152 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd152.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A152 : PRE_first_tail_x6_r0_body.cx1_152.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS152.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_152.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O152 : PRE_first_tail_x6_r0_body.cx1_152.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS152.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_152.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N152 : PRE_first_tail_x6_r0_body.cx1_152.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS152.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_152.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I152 : PRE_first_tail_x6_r0_body.cx1_152.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS152.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_152.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd152 : (PRE_first_tail_x6_r0_body.clo152 ++ PRE_first_tail_x6_r0_body.cln152 ++ PRE_first_tail_x6_r0_body.cli152 ++ PRE_first_tail_x6_r0_body.cwS152 ++ PRE_first_tail_x6_r0_body.cnS152 ++ PRE_first_tail_x6_r0_body.ciS152).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW152 : PRE_first_tail_x6_r0_body.cwS152.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo152.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI152 : PRE_first_tail_x6_r0_body.ciS152.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli152.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN152 : PRE_first_tail_x6_r0_body.cnS152.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF152 : PRE_first_tail_x6_r0_body.cln152.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh152 : PRE_first_tail_x6_r0_body.clo152.all (handleOK PRE_first_tail_x6_r0_body.kappa152 PRE_first_tail_x6_r0_body.P152.lo PRE_first_tail_x6_r0_body.cx0_152.mlx PRE_first_tail_x6_r0_body.cx1_152.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo152 : PRE_first_tail_x6_r0_body.clo152.map (fun h => PRE_first_tail_x6_r0_body.cx1_152.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa152.handle h)) = PRE_first_tail_x6_r0_body.clo152.map (fun h => (PRE_first_tail_x6_r0_body.cx0_152.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa152.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok152 : PRE_first_tail_x6_r0_body.clo152.all (objOK PRE_first_tail_x6_r0_body.kappa152 PRE_first_tail_x6_r0_body.P152.NL PRE_first_tail_x6_r0_body.cx0_152.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd152 : PRE_first_tail_x6_r0_body.cln152.all (nodeOKF PRE_first_tail_x6_r0_body.kappa152 PRE_first_tail_x6_r0_body.P152 PRE_first_tail_x6_r0_body.cx0_152.mlx PRE_first_tail_x6_r0_body.cx1_152.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp152 : ((PRE_first_tail_x6_r0_body.cln152.filter (fullB PRE_first_tail_x6_r0_body.P152))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_152.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa152.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln152.filter (fullB PRE_first_tail_x6_r0_body.P152))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_152.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa152.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI152 : incrB PRE_first_tail_x6_r0_body.kd152.nodeF (List.range' 18292 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK152 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd152.node).all (fun k => Nat.ble 18292 k && Nat.blt k 18292) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL152 : (PRE_first_tail_x6_r0_body.cln152.filter (Nat.ble PRE_first_tail_x6_r0_body.P152.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd152.nodeF i) && (Nat.blt i 18292 || Nat.ble PRE_first_tail_x6_r0_body.kd152.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord152 : (PRE_first_tail_x6_r0_body.cln152.filter (Nat.ble PRE_first_tail_x6_r0_body.P152.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd152.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd152.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd152.nodeF j) (PRE_first_tail_x6_r0_body.kd152.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow152 PRE_first_tail_x6_r0_body.cnn1152 PRE_first_tail_x6_r0_body.fnordI152 PRE_first_tail_x6_r0_body.fnordK152 PRE_first_tail_x6_r0_body.fnordL152
kernel_rfl PRE_first_tail_x6_r0_body.fi152 : PRE_first_tail_x6_r0_body.cli152.all (pnB PRE_first_tail_x6_r0_body.cx0_152.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii152 : PRE_first_tail_x6_r0_body.cli152.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_152.mlx.items.get (PRE_first_tail_x6_r0_body.kappa152.node k) = (PRE_first_tail_x6_r0_body.cx0_152.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa152.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot152 (clean : Conv.NClean (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P152.NL) (cl : SSt (· < 6553) PRE_first_tail_x6_r0_body.cx0_152.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P152 6553 PRE_first_tail_x6_r0_body.kappa152 PRE_first_tail_x6_r0_body.kd152 PRE_first_tail_x6_r0_body.khinv152 PRE_first_tail_x6_r0_body.kninv152 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx PRE_first_tail_x6_r0_body.cx0_152.mlx PRE_first_tail_x6_r0_body.cx1_152.mlx (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo152 PRE_first_tail_x6_r0_body.cln152 PRE_first_tail_x6_r0_body.cli152 PRE_first_tail_x6_r0_body.cwS152 PRE_first_tail_x6_r0_body.cnS152 PRE_first_tail_x6_r0_body.ciS152 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh0152, PRE_first_tail_x6_r0_body.cnh1152, PRE_first_tail_x6_r0_body.cnn0152, PRE_first_tail_x6_r0_body.cnn1152, PRE_first_tail_x6_r0_body.cplo152, PRE_first_tail_x6_r0_body.ccnt152, PRE_first_tail_x6_r0_body.cnband152, PRE_first_tail_x6_r0_body.chbelow152, PRE_first_tail_x6_r0_body.chren152, PRE_first_tail_x6_r0_body.cband152, PRE_first_tail_x6_r0_body.cnh1pos152, PRE_first_tail_x6_r0_body.cnren152, PRE_first_tail_x6_r0_body.cnlow152, PRE_first_tail_x6_r0_body.cabs0a152, PRE_first_tail_x6_r0_body.cabs0b152, PRE_first_tail_x6_r0_body.ctok1152, PRE_first_tail_x6_r0_body.cpend152, PRE_first_tail_x6_r0_body.cerrh152, PRE_first_tail_x6_r0_body.cfiles152, PRE_first_tail_x6_r0_body.carch152, PRE_first_tail_x6_r0_body.csizes152, PRE_first_tail_x6_r0_body.cwired152, PRE_first_tail_x6_r0_body.cfix152, clean, PRE_first_tail_x6_r0_body.fcxn152, PRE_first_tail_x6_r0_body.fcnn152, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle0152, PRE_first_tail_x6_r0_body.fnk152, PRE_first_tail_x6_r0_body.ckA152, PRE_first_tail_x6_r0_body.cobjsK152, PRE_first_tail_x6_r0_body.cnodesK152, PRE_first_tail_x6_r0_body.citemsK152, PRE_first_tail_x6_r0_body.f1A152, PRE_first_tail_x6_r0_body.f1O152, PRE_first_tail_x6_r0_body.f1N152, PRE_first_tail_x6_r0_body.f1I152, PRE_first_tail_x6_r0_body.fbd152, PRE_first_tail_x6_r0_body.fincW152, PRE_first_tail_x6_r0_body.fincI152, PRE_first_tail_x6_r0_body.fincN152, PRE_first_tail_x6_r0_body.flnF152, PRE_first_tail_x6_r0_body.fh152, PRE_first_tail_x6_r0_body.fo152, PRE_first_tail_x6_r0_body.fok152, PRE_first_tail_x6_r0_body.fnd152, PRE_first_tail_x6_r0_body.fp152, PRE_first_tail_x6_r0_body.fnord152, PRE_first_tail_x6_r0_body.fi152, PRE_first_tail_x6_r0_body.fii152⟩
theorem PRE_first_tail_x6_r0_body.cnshift152 (clean : Conv.NClean (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P152.NL) (cl : SSt (· < 6553) PRE_first_tail_x6_r0_body.cx0_152.mlx) : NShift PRE_first_tail_x6_r0_body.P152 6553 PRE_first_tail_x6_r0_body.kappa152 PRE_first_tail_x6_r0_body.cx0_152 PRE_first_tail_x6_r0_body.cx1_152 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot152 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost152 (compact_a_eq PRE_first_tail_x6_r0_body.ckn0152 PRE_first_tail_x6_r0_body.ckn1152 PRE_first_tail_x6_r0_body.ckheap152 PRE_first_tail_x6_r0_body.ckpl152)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_152 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1466.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_152 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1466.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_152 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1466.ffi) = some PRE_first_tail_x6_r0_body.fxC_152
kernel_rfl PRE_first_tail_x6_r0_body.okrC_152 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1466.ffi) = some PRE_first_tail_x6_r0_body.krC_152
noncomputable def PRE_first_tail_x6_r0_body.fx0_152 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1468.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_152 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1468.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_152 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1468.ffi) = some PRE_first_tail_x6_r0_body.fx0_152
kernel_rfl PRE_first_tail_x6_r0_body.okr0_152 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1468.ffi) = some PRE_first_tail_x6_r0_body.kr0_152
noncomputable def PRE_first_tail_x6_r0_body.fx1_152 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1467.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_152 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1467.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_152 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1467.ffi) = some PRE_first_tail_x6_r0_body.fx1_152
kernel_rfl PRE_first_tail_x6_r0_body.okr1_152 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1467.ffi) = some PRE_first_tail_x6_r0_body.kr1_152
kernel_rfl PRE_first_tail_x6_r0_body.ff0152 : PRE_first_tail_x6_r0_body.fx0_152 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_152 (PRE_first_tail_x6_r0_body.clo152.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_152.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff1152 : PRE_first_tail_x6_r0_body.fx1_152 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_152 (PRE_first_tail_x6_r0_body.cwS152.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_152.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck152 : freedLB PRE_first_tail_x6_r0_body.kappa152 PRE_first_tail_x6_r0_body.cx0_152.mlx PRE_first_tail_x6_r0_body.fx0_152 PRE_first_tail_x6_r0_body.fx1_152 PRE_first_tail_x6_r0_body.clo152 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf0152 : PRE_first_tail_x6_r0_body.kr0_152.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_152.flags (PRE_first_tail_x6_r0_body.clo152.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_152.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt0152 : PRE_first_tail_x6_r0_body.kr0_152.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_152.targs (PRE_first_tail_x6_r0_body.clo152.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_152.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf1152 : PRE_first_tail_x6_r0_body.kr1_152.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_152.flags (PRE_first_tail_x6_r0_body.cwS152.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_152.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt1152 : PRE_first_tail_x6_r0_body.kr1_152.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_152.targs (PRE_first_tail_x6_r0_body.cwS152.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_152.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck152 : krecLB PRE_first_tail_x6_r0_body.kappa152 6553 PRE_first_tail_x6_r0_body.cx0_152.mlx PRE_first_tail_x6_r0_body.kr0_152 PRE_first_tail_x6_r0_body.kr1_152 PRE_first_tail_x6_r0_body.clo152 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn152 : Nat.ble 6553 6553 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge152 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1467.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1468.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR152 : pendRegB PRE_first_tail_x6_r0_body.kappa152 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1468.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe152 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1468.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1467.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift152 (clean : Conv.NClean (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P152.NL) (cl : SSt (· < 6553) PRE_first_tail_x6_r0_body.cx0_152.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_152.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_152.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_152.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1466.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_152.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P152 6553 PRE_first_tail_x6_r0_body.kappa152 PRE_first_tail_x6_r0_body.s1468.ffi PRE_first_tail_x6_r0_body.s1467.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift152 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue152, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp152 t ht),
    PRE_first_tail_x6_r0_body.cbridge152,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1468.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1467.ffi) (PRE_first_tail_x6_r0_body.cfoot152 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_152 PRE_first_tail_x6_r0_body.ofx1_152 hobjC PRE_first_tail_x6_r0_body.ff0152 PRE_first_tail_x6_r0_body.ff1152 PRE_first_tail_x6_r0_body.ffck152,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1468.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1467.ffi) (PRE_first_tail_x6_r0_body.cfoot152 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_152 PRE_first_tail_x6_r0_body.okr1_152 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn152) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf0152 PRE_first_tail_x6_r0_body.fkt0152 PRE_first_tail_x6_r0_body.fkf1152 PRE_first_tail_x6_r0_body.fkt1152 PRE_first_tail_x6_r0_body.fkck152,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh0152 PRE_first_tail_x6_r0_body.cnh1152 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe152) PRE_first_tail_x6_r0_body.cpendR152⟩

end Host.Load.Run.Tpl
end

section -- st152/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st152 0
host_stream_state PRE_first_tail_x6_r0_body.st152 1
host_stream_state PRE_first_tail_x6_r0_body.st152 2
end Host.Load.Run.Tpl
end

section -- Site152
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 152 of chain `PRE_first_tail_x6_r0_body`: `plan__g152__g153` (`plan`), the call state `PRE_first_tail_x6_r0_body.s1466`, the merged state `PRE_first_tail_x6_r0_body.s1467`,
the site template `PRE_first_tail_x6_r0_body.st152` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s1468`: the merge.
The footprint's facts are in `SiteF152`, the compaction's in `SiteC152`, `SiteK152`, `SiteNa152`, `SiteNb152`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso152 : PRE_first_tail_x6_r0_body.st152.s0 = { PRE_first_tail_x6_r0_body.s1466 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs152 : List Frame := PRE_first_tail_x6_r0_body.s1466.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_152 : PRE_first_tail_x6_r0_body.S1466.tab.length = 6553
kernel_rfl PRE_first_tail_x6_r0_body.tab0_152 : PRE_first_tail_x6_r0_body.st152.S0.tab = PRE_first_tail_x6_r0_body.S1466.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws152 : List Nat := [3571, 3572, 3573]
kernel_rfl PRE_first_tail_x6_r0_body.fresh152 : (PRE_first_tail_x6_r0_body.S1466.tab.all fun e => PRE_first_tail_x6_r0_body.ws152.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S1466.oracle.all fun q => PRE_first_tail_x6_r0_body.ws152.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab152 : PRE_first_tail_x6_r0_body.S1467.tab = PRE_first_tail_x6_r0_body.S1466.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws152
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen152 : PRE_first_tail_x6_r0_body.st152.S2.tab.length - PRE_first_tail_x6_r0_body.st152.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged152`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap152 : PRE_first_tail_x6_r0_body.s1467.heap = PRE_first_tail_x6_r0_body.st152.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext152 : PRE_first_tail_x6_r0_body.s1467.next = PRE_first_tail_x6_r0_body.st152.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl152 : PRE_first_tail_x6_r0_body.s1467.ctl = PRE_first_tail_x6_r0_body.st152.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack152 : PRE_first_tail_x6_r0_body.s1467.stack = PRE_first_tail_x6_r0_body.st152.s2.stack ++ PRE_first_tail_x6_r0_body.s1466.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs152 : PRE_first_tail_x6_r0_body.s1467.jobs = PRE_first_tail_x6_r0_body.st152.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi152 : PRE_first_tail_x6_r0_body.s1467.ffi = PRE_first_tail_x6_r0_body.st152.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace152 : PRE_first_tail_x6_r0_body.s1467.trace = PRE_first_tail_x6_r0_body.st152.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores152 : PRE_first_tail_x6_r0_body.s1467.stores = PRE_first_tail_x6_r0_body.st152.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD152
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 152 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived152 : PRE_first_tail_x6_r0_body.nr152.map (fun r => nth? PRE_first_tail_x6_r0_body.st152.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo152 : PRE_first_tail_x6_r0_body.nr152.all (Nat.ble 6553) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj152 : PRE_first_tail_x6_r0_body.cws152.all (fun c => !PRE_first_tail_x6_r0_body.ws152.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ152 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws152 PRE_first_tail_x6_r0_body.crs152 PRE_first_tail_x6_r0_body.ws152

end Host.Load.Run.Tpl
end

section -- st152/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st152`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st152.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st152.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st152.s2.heap PRE_first_tail_x6_r0_body.st152.wrR ++ freshOf PRE_first_tail_x6_r0_body.st152.s2.heap PRE_first_tail_x6_r0_body.st152.s0.next PRE_first_tail_x6_r0_body.st152.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st152.wr : List Nat := PRE_first_tail_x6_r0_body.st152.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st152.heapFoot : PRE_first_tail_x6_r0_body.st152.s2.heap = setAll PRE_first_tail_x6_r0_body.st152.s0.heap PRE_first_tail_x6_r0_body.st152.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st152.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st152.s0.next PRE_first_tail_x6_r0_body.st152.s2.next = true
theorem PRE_first_tail_x6_r0_body.st152.grows : PRE_first_tail_x6_r0_body.st152.s0.next ≤ PRE_first_tail_x6_r0_body.st152.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st152.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st152.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st152.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st152.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st152.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st152.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st152.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st152.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st152.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st152.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st152.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st152.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st152.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st152.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st152.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st152.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st152.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st152.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st152.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st152.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st152.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st152.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st152.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st152.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st152.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st152.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st152.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st152.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st152.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st152.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st152.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st152.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF152
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 152 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB152 : nodupT PRE_first_tail_x6_r0_body.st152.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup152 : PRE_first_tail_x6_r0_body.st152.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB152).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB152 : PRE_first_tail_x6_r0_body.st152.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound152 : ∀ b ∈ PRE_first_tail_x6_r0_body.st152.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB152 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr152 := PRE_first_tail_x6_r0_body.st152.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq152 : PRE_first_tail_x6_r0_body.st152.s2.trace = PRE_first_tail_x6_r0_body.trFr152 ++ PRE_first_tail_x6_r0_body.st152.s0.trace
theorem PRE_first_tail_x6_r0_body.trace152 : ∃ fr, PRE_first_tail_x6_r0_body.st152.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st152.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq152⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide152 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB152 : (PRE_first_tail_x6_r0_body.wide152.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st152.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix152 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide152, WFix Map.id (Present PRE_first_tail_x6_r0_body.st152.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB152 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL152
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 152 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s1467`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO152 : PRE_first_tail_x6_r0_body.st152.S0.oracle = PRE_first_tail_x6_r0_body.st152.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B152 : PRE_first_tail_x6_r0_body.st152.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st152.s0.next || (PRE_first_tail_x6_r0_body.st152.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot152 : Conv.StageFoot PRE_first_tail_x6_r0_body.st152.wr PRE_first_tail_x6_r0_body.st152.s0 PRE_first_tail_x6_r0_body.st152.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st152.heapFoot PRE_first_tail_x6_r0_body.wrNodup152 PRE_first_tail_x6_r0_body.wrBound152 PRE_first_tail_x6_r0_body.wr0B152 PRE_first_tail_x6_r0_body.st152.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged152 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st152.F.S → PRE_first_tail_x6_r0_body.st152.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st152.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st152.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs152 PRE_first_tail_x6_r0_body.st152.wr PRE_first_tail_x6_r0_body.s1466 PRE_first_tail_x6_r0_body.st152.s2 PRE_first_tail_x6_r0_body.st152.s0
      PRE_first_tail_x6_r0_body.st152.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st152.F FR W stk M ν K PRE_first_tail_x6_r0_body.s1467 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso152 PRE_first_tail_x6_r0_body.stFoot152 PRE_first_tail_x6_r0_body.wrNodup152 PRE_first_tail_x6_r0_body.wrBound152 PRE_first_tail_x6_r0_body.trace152 PRE_first_tail_x6_r0_body.mheap152
    PRE_first_tail_x6_r0_body.mnext152 PRE_first_tail_x6_r0_body.mctl152 PRE_first_tail_x6_r0_body.mstack152 PRE_first_tail_x6_r0_body.mjobs152 PRE_first_tail_x6_r0_body.mffi152 PRE_first_tail_x6_r0_body.mtrace152 PRE_first_tail_x6_r0_body.mstores152 h

def PRE_first_tail_x6_r0_body.arrEl152_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE152_2665 : arrOf PRE_first_tail_x6_r0_body.s1467 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl152_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA152_2665 : isArrB PRE_first_tail_x6_r0_body.s1467 2665 = true
theorem PRE_first_tail_x6_r0_body.arr152_2665 : ∃ o, PRE_first_tail_x6_r0_body.s1467.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl152_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE152_2665 PRE_first_tail_x6_r0_body.arrA152_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN152_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl152_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR152_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl152_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN152_2665

def PRE_first_tail_x6_r0_body.arrEl152_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE152_2673467 : arrOf PRE_first_tail_x6_r0_body.s1467 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl152_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA152_2673467 : isArrB PRE_first_tail_x6_r0_body.s1467 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr152_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s1467.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl152_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE152_2673467 PRE_first_tail_x6_r0_body.arrA152_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN152_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl152_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR152_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl152_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN152_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k152 : isArrB PRE_first_tail_x6_r0_body.s1467 4910 = false
theorem PRE_first_tail_x6_r0_body.keep152 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s1467 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k152 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr152_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl152_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ152
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 152 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s1466`, the merged
state `PRE_first_tail_x6_r0_body.s1467`, the canonical state `PRE_first_tail_x6_r0_body.s1468`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl152 : PRE_first_tail_x6_r0_body.pl152.all (Nat.ble PRE_first_tail_x6_r0_body.s1466.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd152 : nodupT PRE_first_tail_x6_r0_body.pl152 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn1152 : Nat.ble PRE_first_tail_x6_r0_body.s1466.next 2793774 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst152 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s1466.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn152 : PRE_first_tail_x6_r0_body.s1468.next = PRE_first_tail_x6_r0_body.s1466.next + PRE_first_tail_x6_r0_body.pl152.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn152 : PRE_first_tail_x6_r0_body.s1467.next = 2793774
kernel_rfl PRE_first_tail_x6_r0_body.zgrow152 : Nat.ble PRE_first_tail_x6_r0_body.s1468.next PRE_first_tail_x6_r0_body.s1467.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh152 : PRE_first_tail_x6_r0_body.S1466.tab.all (fun e => PRE_first_tail_x6_r0_body.cws152.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd152 : nodupT PRE_first_tail_x6_r0_body.cws152 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi152 : PRE_first_tail_x6_r0_body.nr152.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S1467.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt152 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s1466.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg152_2665 : PRE_first_tail_x6_r0_body.s1468.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1468 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk152_2665 : (objOf PRE_first_tail_x6_r0_body.s1468 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm152_2665 : PRE_first_tail_x6_r0_body.s1467.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa152.obj (objOf PRE_first_tail_x6_r0_body.s1468 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s1467 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg152_2673467 : PRE_first_tail_x6_r0_body.s1468.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1468 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk152_2673467 : (objOf PRE_first_tail_x6_r0_body.s1468 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm152_2673467 : PRE_first_tail_x6_r0_body.s1467.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa152.obj (objOf PRE_first_tail_x6_r0_body.s1468 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s1467 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw152_4910 : (PRE_first_tail_x6_r0_body.s1468.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw152_2673472 : (PRE_first_tail_x6_r0_body.s1468.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw152_2673473 : (PRE_first_tail_x6_r0_body.s1468.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd152 : PRE_first_tail_x6_r0_body.cl152.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr152 : PRE_first_tail_x6_r0_body.st152.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s1466.next || PRE_first_tail_x6_r0_body.cl152.contains b) = true
def PRE_first_tail_x6_r0_body.zl152 : List Nat := PRE_first_tail_x6_r0_body.cl152.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE152 : PRE_first_tail_x6_r0_body.zl152.map (fun a => PRE_first_tail_x6_r0_body.s1467.heap.get (PRE_first_tail_x6_r0_body.kappa152.a a)) = PRE_first_tail_x6_r0_body.zl152.map (fun a => (PRE_first_tail_x6_r0_body.s1468.heap.get a).map PRE_first_tail_x6_r0_body.kappa152.hobj)
theorem PRE_first_tail_x6_r0_body.zimg152 : HeapImg PRE_first_tail_x6_r0_body.kappa152 PRE_first_tail_x6_r0_body.s1468 PRE_first_tail_x6_r0_body.s1467 PRE_first_tail_x6_r0_body.zl152 := PRE_first_tail_x6_r0_body.zimgE152
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl152 : PRE_first_tail_x6_r0_body.s1467.ctl = PRE_first_tail_x6_r0_body.kappa152.ctl PRE_first_tail_x6_r0_body.s1468.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack152 : PRE_first_tail_x6_r0_body.s1467.stack = PRE_first_tail_x6_r0_body.s1468.stack.map PRE_first_tail_x6_r0_body.kappa152.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs152 : PRE_first_tail_x6_r0_body.s1467.jobs = PRE_first_tail_x6_r0_body.s1468.jobs.map PRE_first_tail_x6_r0_body.kappa152.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores152 : PRE_first_tail_x6_r0_body.s1467.stores = PRE_first_tail_x6_r0_body.kappa152.stores PRE_first_tail_x6_r0_body.s1468.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots152 : checkRootsSupp PRE_first_tail_x6_r0_body.s1468 6553 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC152 : PRE_first_tail_x6_r0_body.S1466.tab.length + PRE_first_tail_x6_r0_body.cws152.length = 6553
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap152 : PRE_first_tail_x6_r0_body.kappa152 = Conv.Map.compact PRE_first_tail_x6_r0_body.s1466.next 2793774 PRE_first_tail_x6_r0_body.S1466.tab.length PRE_first_tail_x6_r0_body.pl152 (PRE_first_tail_x6_r0_body.nr152.map NumV.ref) PRE_first_tail_x6_r0_body.kd152.big
  PRE_first_tail_x6_r0_body.kd152.region PRE_first_tail_x6_r0_body.kd152.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin152 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1468.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc152 : Conv.jcleanListB (⟨21185, 18292, 2793764, 6553⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1468 PRE_first_tail_x6_r0_body.cl152 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB152 : noBigRootsP (fun i => !Conv.oldBigB (⟨21185, 18292, 2793764, 6553⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s1468.trace PRE_first_tail_x6_r0_body.s1468 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm152 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 18292 = true
theorem PRE_first_tail_x6_r0_body.cjcl152 (h : Conv.JClean (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1466) : Conv.JClean (⟨21185, 18292, 2793764, 6553⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1468 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle152)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap152 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd152 a ha)) PRE_first_tail_x6_r0_body.zjc152

end Host.Load.Run.Tpl
end

section -- st152/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st152.bodyLast from PRE_first_tail_x6_r0_body.st152.s1 to PRE_first_tail_x6_r0_body.st152.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st152.F PRE_first_tail_x6_r0_body.st152.s1).run PRE_first_tail_x6_r0_body.st152.S1 = some (PRE_first_tail_x6_r0_body.st152.s2, PRE_first_tail_x6_r0_body.st152.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st152.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st152.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st152.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st152.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st152/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st152.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st152.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st152.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st152.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st152.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st152.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st152.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st152.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st152.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st152.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st152.s0 PRE_first_tail_x6_r0_body.st152.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st152.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st152.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st152.s1 PRE_first_tail_x6_r0_body.st152.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st152/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st152.bodyK0F from PRE_first_tail_x6_r0_body.st152.s0 to PRE_first_tail_x6_r0_body.st152.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st152.F (PRE_first_tail_x6_r0_body.st152.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st152.ks 0).getD 0) PRE_first_tail_x6_r0_body.st152.s0 PRE_first_tail_x6_r0_body.st152.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st152.s1, PRE_first_tail_x6_r0_body.st152.S1)
theorem PRE_first_tail_x6_r0_body.st152.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st152.F (PRE_first_tail_x6_r0_body.st152.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st152.ks 0).getD 0) PRE_first_tail_x6_r0_body.st152.s0 PRE_first_tail_x6_r0_body.st152.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st152.s1, PRE_first_tail_x6_r0_body.st152.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st152.bodyOkLN_ok PRE_first_tail_x6_r0_body.st152.bodyK0F
end Host.Load.Run.Tpl
end

section -- st152/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st152.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st152.F (PRE_first_tail_x6_r0_body.st152.bodyOkL bytes rows) 98 PRE_first_tail_x6_r0_body.st152.s0 PRE_first_tail_x6_r0_body.st152.S0 = some (PRE_first_tail_x6_r0_body.st152.s1, PRE_first_tail_x6_r0_body.st152.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st152.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st152.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st152.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st152.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st152.F (PRE_first_tail_x6_r0_body.st152.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st152.s0
  S0 := PRE_first_tail_x6_r0_body.st152.S0
  s1 := PRE_first_tail_x6_r0_body.st152.s1
  S1 := PRE_first_tail_x6_r0_body.st152.S1
  s2 := PRE_first_tail_x6_r0_body.st152.s2
  S2 := PRE_first_tail_x6_r0_body.st152.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st152.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st152.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st152.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st152.bodyHalt
  last := PRE_first_tail_x6_r0_body.st152.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st152.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC153
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 153 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s1484` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa153` into the merged state
`PRE_first_tail_x6_r0_body.s1483`. -/

def PRE_first_tail_x6_r0_body.pl153 : List Nat := [2795862, 2795698, 2795750, 2795863, 2795864, 2795700, 2795752, 2795861, 2795860, 2795859, 2795858, 2795852, 2795803, 2795854, 2795805]
def PRE_first_tail_x6_r0_body.nr153 : List Nat := [6638, 6639, 6635, 6641, 6637, 6645, 6646, 6643, 6644]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd153 : RData :=
  ⟨2795515, 2795865, Stage.setAll PTrie.nil [(2795500, 2795862), (2795501, 2795698), (2795502, 2795750), (2795503, 2795863), (2795504, 2795864), (2795505, 2795700), (2795506, 2795752), (2795507, 2795861), (2795508, 2795860), (2795509, 2795859), (2795510, 2795858), (2795511, 2795852), (2795512, 2795803), (2795513, 2795854), (2795514, 2795805)], Stage.setAll PTrie.nil [(21225, 21227), (21226, 21228), (21227, 21230), (21228, 21229)],
   21229, 21231, 18326, 18326, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(6630, .ref 6638), (6631, .ref 6639), (6632, .ref 6635), (6633, .ref 6641), (6634, .ref 6637), (6635, .ref 6645), (6636, .ref 6646), (6637, .ref 6643), (6638, .ref 6644)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa153 : Map :=
  Conv.Map.compact 2795500 2795865 6630 PRE_first_tail_x6_r0_body.pl153 (PRE_first_tail_x6_r0_body.nr153.map NumV.ref) PRE_first_tail_x6_r0_body.kd153.big
    PRE_first_tail_x6_r0_body.kd153.region PRE_first_tail_x6_r0_body.kd153.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws153 : List Nat := [3591, 3592, 3593, 3594, 3595, 3596, 3597, 3598, 3599]
noncomputable def PRE_first_tail_x6_r0_body.crs153 : List SymE := PRE_first_tail_x6_r0_body.nr153.map fun r => (nth? PRE_first_tail_x6_r0_body.S1483.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta153 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws153 PRE_first_tail_x6_r0_body.crs153
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB153 : List Nat := [2665, 2672694, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab153 : PRE_first_tail_x6_r0_body.S1484.tab = PRE_first_tail_x6_r0_body.S1482.tab ++ PRE_first_tail_x6_r0_body.cws153.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace153 : PRE_first_tail_x6_r0_body.s1484.trace = PRE_first_tail_x6_r0_body.s1482.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext153 : PRE_first_tail_x6_r0_body.s1484.next = 2795515
kernel_rfl PRE_first_tail_x6_r0_body.ccounters153 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1484.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1484.ffi).mlx.nnext) = (21229, 18326)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue153 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1483.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1484.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa153.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp153 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1484.ffi).mlx.tokens.all (bSN 6639) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean153 : Conv.cleanListB 21229 131072 (fun r => Nat.ble 84916 r) PRE_first_tail_x6_r0_body.s1484
    (PRE_first_tail_x6_r0_body.wrB153 ++ (List.range 15).map (2795500 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs153 : bigsOutB 21229 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1484.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK153
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl153`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl153 : List Nat := [2665, 2672694, 2673467, 2795500, 2795501, 2795502, 2795503, 2795504, 2795505, 2795506, 2795507, 2795508, 2795509, 2795510, 2795511, 2795512, 2795513, 2795514]
def PRE_first_tail_x6_r0_body.clo153 : List Nat := [21225, 21226, 21227, 21228]
def PRE_first_tail_x6_r0_body.cln153 : List Nat := [18320, 18321, 18322, 18323, 18324, 18325]
def PRE_first_tail_x6_r0_body.cli153 : List Nat := [18320, 18321, 18322, 18323, 18324, 18325]
kernel_rfl PRE_first_tail_x6_r0_body.cheap153 : PRE_first_tail_x6_r0_body.s1484.heap = Stage.setAll PRE_first_tail_x6_r0_body.s1482.heap (PRE_first_tail_x6_r0_body.cl153.filterMap fun a => (PRE_first_tail_x6_r0_body.s1484.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe153 : Nat.ble PRE_first_tail_x6_r0_body.s1482.next PRE_first_tail_x6_r0_body.s1484.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP153 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s1482 PRE_first_tail_x6_r0_body.s1484 PRE_first_tail_x6_r0_body.cl153 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp153 : Conv.suppListB PRE_first_tail_x6_r0_body.s1484 6639 PRE_first_tail_x6_r0_body.cl153 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound153 : Conv.boundListB PRE_first_tail_x6_r0_body.s1484 PRE_first_tail_x6_r0_body.cl153 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK153 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1484.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln153.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1484.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK153 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1484.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo153.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1484.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK153 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1484.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli153.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1484.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst153 : Conv.sstListB 6639 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1484.ffi).mlx PRE_first_tail_x6_r0_body.cln153 PRE_first_tail_x6_r0_body.clo153 PRE_first_tail_x6_r0_body.cli153 = true

end Host.Load.Run.Tpl
end

section -- SiteCl153
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA153 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1484.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo153.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1484.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd153 : (PRE_first_tail_x6_r0_body.clo153 ++ PRE_first_tail_x6_r0_body.cln153 ++ PRE_first_tail_x6_r0_body.cli153).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle153 : Conv.Cnt.leB (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt) (⟨21229, 18326, 2795515, 6639⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck153 : Conv.ncleanListB (⟨21229, 18326, 2795515, 6639⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1484.ffi).mlx PRE_first_tail_x6_r0_body.clo153 PRE_first_tail_x6_r0_body.cln153 PRE_first_tail_x6_r0_body.cli153 = true
theorem PRE_first_tail_x6_r0_body.cncl153 (h : Conv.NClean (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx) : Conv.NClean (⟨21229, 18326, 2795515, 6639⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1484.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle153 PRE_first_tail_x6_r0_body.ckA153 PRE_first_tail_x6_r0_body.cobjsK153 PRE_first_tail_x6_r0_body.cnodesK153 PRE_first_tail_x6_r0_body.citemsK153 PRE_first_tail_x6_r0_body.cbd153 PRE_first_tail_x6_r0_body.cck153

end Host.Load.Run.Tpl
end

section -- SiteS153
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 153 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc153 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P153 : LoadP := PRE_first_tail_x6_r0_body.Pc153.raise 18326
kernel_rfl PRE_first_tail_x6_r0_body.craise153 : Nat.ble PRE_first_tail_x6_r0_body.Pc153.N0 18326 = true
theorem PRE_first_tail_x6_r0_body.raised153 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc153 PRE_first_tail_x6_r0_body.P153 :=
  .inr ⟨18326, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise153, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_153 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1484.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_153 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1483.ffi)
def PRE_first_tail_x6_r0_body.khinv153 : PTrie Nat := Stage.setAll PTrie.nil [(21227, 21225), (21228, 21226), (21230, 21227), (21229, 21228)]
def PRE_first_tail_x6_r0_body.kninv153 : PTrie Nat := Stage.setAll PTrie.nil [(18320, 18320), (18321, 18321), (18322, 18322), (18323, 18323), (18324, 18324), (18325, 18325)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS153 : List Nat := [21225, 21226, 21227, 21228, 21229, 21230]
def PRE_first_tail_x6_r0_body.cnS153 : List Nat := List.range' 18320 6
def PRE_first_tail_x6_r0_body.ciS153 : List Nat := [] ++ List.range' 18320 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh0153 : PRE_first_tail_x6_r0_body.kd153.nh0 = PRE_first_tail_x6_r0_body.cx0_153.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh1153 : PRE_first_tail_x6_r0_body.kd153.nh1 = PRE_first_tail_x6_r0_body.cx1_153.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn0153 : PRE_first_tail_x6_r0_body.kd153.nn0 = PRE_first_tail_x6_r0_body.cx0_153.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn1153 : PRE_first_tail_x6_r0_body.kd153.nn1 = PRE_first_tail_x6_r0_body.cx1_153.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo153 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P153.lo && Nat.ble PRE_first_tail_x6_r0_body.P153.lo PRE_first_tail_x6_r0_body.cx0_153.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P153.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P153.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt153 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_153.mlx.next PRE_first_tail_x6_r0_body.cx1_153.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_153.mlx.nnext PRE_first_tail_x6_r0_body.cx1_153.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband153 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P153.NL && Nat.ble PRE_first_tail_x6_r0_body.P153.NL PRE_first_tail_x6_r0_body.P153.N0 && Nat.ble PRE_first_tail_x6_r0_body.P153.N0 PRE_first_tail_x6_r0_body.cx0_153.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow153 : PRE_first_tail_x6_r0_body.kd153.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren153 : checkRenG PRE_first_tail_x6_r0_body.kd153.hnd PRE_first_tail_x6_r0_body.khinv153 (phB PRE_first_tail_x6_r0_body.cx0_153.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband153 : PRE_first_tail_x6_r0_body.kd153.checkBand PRE_first_tail_x6_r0_body.P153.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos153 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd153.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren153 : checkRenG PRE_first_tail_x6_r0_body.kd153.node PRE_first_tail_x6_r0_body.kninv153 (pnB PRE_first_tail_x6_r0_body.cx0_153.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow153 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd153.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P153.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd153.nodeF j) PRE_first_tail_x6_r0_body.cx1_153.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a153 : PRE_first_tail_x6_r0_body.cx0_153.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b153 : PRE_first_tail_x6_r0_body.cx0_153.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok1153 : PRE_first_tail_x6_r0_body.cx1_153.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend153 : PRE_first_tail_x6_r0_body.cx1_153.mlx.pending = PRE_first_tail_x6_r0_body.cx0_153.mlx.pending.map PRE_first_tail_x6_r0_body.kappa153.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh153 : PRE_first_tail_x6_r0_body.cx1_153.mlx.errh = PRE_first_tail_x6_r0_body.cx0_153.mlx.errh.map PRE_first_tail_x6_r0_body.kappa153.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles153 : PRE_first_tail_x6_r0_body.cx1_153.mlx.files = PRE_first_tail_x6_r0_body.cx0_153.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch153 : PRE_first_tail_x6_r0_body.cx1_153.mlx.arch = PRE_first_tail_x6_r0_body.cx0_153.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes153 : PRE_first_tail_x6_r0_body.cx1_153.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_153.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired153 : PRE_first_tail_x6_r0_body.cx1_153.mlx.wired = PRE_first_tail_x6_r0_body.cx0_153.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost153 : PRE_first_tail_x6_r0_body.cx1_153.host = PRE_first_tail_x6_r0_body.cx0_153.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd153`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn0153 : PRE_first_tail_x6_r0_body.kd153.n0 = 2795515
kernel_rfl PRE_first_tail_x6_r0_body.ckn1153 : PRE_first_tail_x6_r0_body.kd153.n1 = 2795865
kernel_rfl PRE_first_tail_x6_r0_body.ckheap153 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd153.heap).all (fun x => Nat.ble 2795500 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl153 : (List.range 15).all (fun j => decide (PRE_first_tail_x6_r0_body.kd153.heap.get (2795500 + j) = nth? PRE_first_tail_x6_r0_body.pl153 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja153 : Nat.ble 2795500 2795500 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn153 : Nat.ble 6630 6630 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD153 : Nat.ble 2795500 PRE_first_tail_x6_r0_body.kd153.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn153 : Nat.ble 21225 PRE_first_tail_x6_r0_body.kd153.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn153 : Nat.ble 18320 PRE_first_tail_x6_r0_body.kd153.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb153 : Nat.ble 21225 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap153 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd153.heap).all (Nat.ble (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd153 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd153.hnd).all (Nat.ble (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode153 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd153.node).all (Nat.ble (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix153 : Conv.FixOld (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa153 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja153) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn153) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD153) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn153) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn153) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb153) PRE_first_tail_x6_r0_body.fheap153 PRE_first_tail_x6_r0_body.fhnd153 PRE_first_tail_x6_r0_body.fnode153
kernel_rfl PRE_first_tail_x6_r0_body.fcxn153 : (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn153 : (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle0153 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_153.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_153.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk153 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd153.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A153 : PRE_first_tail_x6_r0_body.cx1_153.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS153.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_153.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O153 : PRE_first_tail_x6_r0_body.cx1_153.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS153.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_153.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N153 : PRE_first_tail_x6_r0_body.cx1_153.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS153.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_153.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I153 : PRE_first_tail_x6_r0_body.cx1_153.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS153.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_153.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd153 : (PRE_first_tail_x6_r0_body.clo153 ++ PRE_first_tail_x6_r0_body.cln153 ++ PRE_first_tail_x6_r0_body.cli153 ++ PRE_first_tail_x6_r0_body.cwS153 ++ PRE_first_tail_x6_r0_body.cnS153 ++ PRE_first_tail_x6_r0_body.ciS153).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW153 : PRE_first_tail_x6_r0_body.cwS153.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo153.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI153 : PRE_first_tail_x6_r0_body.ciS153.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli153.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN153 : PRE_first_tail_x6_r0_body.cnS153.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF153 : PRE_first_tail_x6_r0_body.cln153.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh153 : PRE_first_tail_x6_r0_body.clo153.all (handleOK PRE_first_tail_x6_r0_body.kappa153 PRE_first_tail_x6_r0_body.P153.lo PRE_first_tail_x6_r0_body.cx0_153.mlx PRE_first_tail_x6_r0_body.cx1_153.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo153 : PRE_first_tail_x6_r0_body.clo153.map (fun h => PRE_first_tail_x6_r0_body.cx1_153.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa153.handle h)) = PRE_first_tail_x6_r0_body.clo153.map (fun h => (PRE_first_tail_x6_r0_body.cx0_153.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa153.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok153 : PRE_first_tail_x6_r0_body.clo153.all (objOK PRE_first_tail_x6_r0_body.kappa153 PRE_first_tail_x6_r0_body.P153.NL PRE_first_tail_x6_r0_body.cx0_153.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd153 : PRE_first_tail_x6_r0_body.cln153.all (nodeOKF PRE_first_tail_x6_r0_body.kappa153 PRE_first_tail_x6_r0_body.P153 PRE_first_tail_x6_r0_body.cx0_153.mlx PRE_first_tail_x6_r0_body.cx1_153.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp153 : ((PRE_first_tail_x6_r0_body.cln153.filter (fullB PRE_first_tail_x6_r0_body.P153))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_153.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa153.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln153.filter (fullB PRE_first_tail_x6_r0_body.P153))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_153.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa153.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI153 : incrB PRE_first_tail_x6_r0_body.kd153.nodeF (List.range' 18320 6) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK153 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd153.node).all (fun k => Nat.ble 18320 k && Nat.blt k 18326) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL153 : (PRE_first_tail_x6_r0_body.cln153.filter (Nat.ble PRE_first_tail_x6_r0_body.P153.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd153.nodeF i) && (Nat.blt i 18326 || Nat.ble PRE_first_tail_x6_r0_body.kd153.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord153 : (PRE_first_tail_x6_r0_body.cln153.filter (Nat.ble PRE_first_tail_x6_r0_body.P153.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd153.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd153.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd153.nodeF j) (PRE_first_tail_x6_r0_body.kd153.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow153 PRE_first_tail_x6_r0_body.cnn1153 PRE_first_tail_x6_r0_body.fnordI153 PRE_first_tail_x6_r0_body.fnordK153 PRE_first_tail_x6_r0_body.fnordL153
kernel_rfl PRE_first_tail_x6_r0_body.fi153 : PRE_first_tail_x6_r0_body.cli153.all (pnB PRE_first_tail_x6_r0_body.cx0_153.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii153 : PRE_first_tail_x6_r0_body.cli153.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_153.mlx.items.get (PRE_first_tail_x6_r0_body.kappa153.node k) = (PRE_first_tail_x6_r0_body.cx0_153.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa153.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot153 (clean : Conv.NClean (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P153.NL) (cl : SSt (· < 6639) PRE_first_tail_x6_r0_body.cx0_153.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P153 6639 PRE_first_tail_x6_r0_body.kappa153 PRE_first_tail_x6_r0_body.kd153 PRE_first_tail_x6_r0_body.khinv153 PRE_first_tail_x6_r0_body.kninv153 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx PRE_first_tail_x6_r0_body.cx0_153.mlx PRE_first_tail_x6_r0_body.cx1_153.mlx (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo153 PRE_first_tail_x6_r0_body.cln153 PRE_first_tail_x6_r0_body.cli153 PRE_first_tail_x6_r0_body.cwS153 PRE_first_tail_x6_r0_body.cnS153 PRE_first_tail_x6_r0_body.ciS153 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh0153, PRE_first_tail_x6_r0_body.cnh1153, PRE_first_tail_x6_r0_body.cnn0153, PRE_first_tail_x6_r0_body.cnn1153, PRE_first_tail_x6_r0_body.cplo153, PRE_first_tail_x6_r0_body.ccnt153, PRE_first_tail_x6_r0_body.cnband153, PRE_first_tail_x6_r0_body.chbelow153, PRE_first_tail_x6_r0_body.chren153, PRE_first_tail_x6_r0_body.cband153, PRE_first_tail_x6_r0_body.cnh1pos153, PRE_first_tail_x6_r0_body.cnren153, PRE_first_tail_x6_r0_body.cnlow153, PRE_first_tail_x6_r0_body.cabs0a153, PRE_first_tail_x6_r0_body.cabs0b153, PRE_first_tail_x6_r0_body.ctok1153, PRE_first_tail_x6_r0_body.cpend153, PRE_first_tail_x6_r0_body.cerrh153, PRE_first_tail_x6_r0_body.cfiles153, PRE_first_tail_x6_r0_body.carch153, PRE_first_tail_x6_r0_body.csizes153, PRE_first_tail_x6_r0_body.cwired153, PRE_first_tail_x6_r0_body.cfix153, clean, PRE_first_tail_x6_r0_body.fcxn153, PRE_first_tail_x6_r0_body.fcnn153, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle0153, PRE_first_tail_x6_r0_body.fnk153, PRE_first_tail_x6_r0_body.ckA153, PRE_first_tail_x6_r0_body.cobjsK153, PRE_first_tail_x6_r0_body.cnodesK153, PRE_first_tail_x6_r0_body.citemsK153, PRE_first_tail_x6_r0_body.f1A153, PRE_first_tail_x6_r0_body.f1O153, PRE_first_tail_x6_r0_body.f1N153, PRE_first_tail_x6_r0_body.f1I153, PRE_first_tail_x6_r0_body.fbd153, PRE_first_tail_x6_r0_body.fincW153, PRE_first_tail_x6_r0_body.fincI153, PRE_first_tail_x6_r0_body.fincN153, PRE_first_tail_x6_r0_body.flnF153, PRE_first_tail_x6_r0_body.fh153, PRE_first_tail_x6_r0_body.fo153, PRE_first_tail_x6_r0_body.fok153, PRE_first_tail_x6_r0_body.fnd153, PRE_first_tail_x6_r0_body.fp153, PRE_first_tail_x6_r0_body.fnord153, PRE_first_tail_x6_r0_body.fi153, PRE_first_tail_x6_r0_body.fii153⟩
theorem PRE_first_tail_x6_r0_body.cnshift153 (clean : Conv.NClean (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P153.NL) (cl : SSt (· < 6639) PRE_first_tail_x6_r0_body.cx0_153.mlx) : NShift PRE_first_tail_x6_r0_body.P153 6639 PRE_first_tail_x6_r0_body.kappa153 PRE_first_tail_x6_r0_body.cx0_153 PRE_first_tail_x6_r0_body.cx1_153 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot153 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost153 (compact_a_eq PRE_first_tail_x6_r0_body.ckn0153 PRE_first_tail_x6_r0_body.ckn1153 PRE_first_tail_x6_r0_body.ckheap153 PRE_first_tail_x6_r0_body.ckpl153)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_153 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1482.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_153 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1482.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_153 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1482.ffi) = some PRE_first_tail_x6_r0_body.fxC_153
kernel_rfl PRE_first_tail_x6_r0_body.okrC_153 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1482.ffi) = some PRE_first_tail_x6_r0_body.krC_153
noncomputable def PRE_first_tail_x6_r0_body.fx0_153 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1484.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_153 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1484.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_153 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1484.ffi) = some PRE_first_tail_x6_r0_body.fx0_153
kernel_rfl PRE_first_tail_x6_r0_body.okr0_153 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1484.ffi) = some PRE_first_tail_x6_r0_body.kr0_153
noncomputable def PRE_first_tail_x6_r0_body.fx1_153 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1483.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_153 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1483.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_153 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s1483.ffi) = some PRE_first_tail_x6_r0_body.fx1_153
kernel_rfl PRE_first_tail_x6_r0_body.okr1_153 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s1483.ffi) = some PRE_first_tail_x6_r0_body.kr1_153
kernel_rfl PRE_first_tail_x6_r0_body.ff0153 : PRE_first_tail_x6_r0_body.fx0_153 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_153 (PRE_first_tail_x6_r0_body.clo153.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_153.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff1153 : PRE_first_tail_x6_r0_body.fx1_153 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_153 (PRE_first_tail_x6_r0_body.cwS153.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_153.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck153 : freedLB PRE_first_tail_x6_r0_body.kappa153 PRE_first_tail_x6_r0_body.cx0_153.mlx PRE_first_tail_x6_r0_body.fx0_153 PRE_first_tail_x6_r0_body.fx1_153 PRE_first_tail_x6_r0_body.clo153 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf0153 : PRE_first_tail_x6_r0_body.kr0_153.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_153.flags (PRE_first_tail_x6_r0_body.clo153.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_153.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt0153 : PRE_first_tail_x6_r0_body.kr0_153.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_153.targs (PRE_first_tail_x6_r0_body.clo153.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_153.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf1153 : PRE_first_tail_x6_r0_body.kr1_153.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_153.flags (PRE_first_tail_x6_r0_body.cwS153.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_153.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt1153 : PRE_first_tail_x6_r0_body.kr1_153.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_153.targs (PRE_first_tail_x6_r0_body.cwS153.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_153.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck153 : krecLB PRE_first_tail_x6_r0_body.kappa153 6639 PRE_first_tail_x6_r0_body.cx0_153.mlx PRE_first_tail_x6_r0_body.kr0_153 PRE_first_tail_x6_r0_body.kr1_153 PRE_first_tail_x6_r0_body.clo153 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn153 : Nat.ble 6630 6639 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge153 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1483.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1484.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR153 : pendRegB PRE_first_tail_x6_r0_body.kappa153 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1484.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe153 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1484.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1483.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift153 (clean : Conv.NClean (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P153.NL) (cl : SSt (· < 6639) PRE_first_tail_x6_r0_body.cx0_153.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_153.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_153.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_153.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s1482.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_153.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P153 6639 PRE_first_tail_x6_r0_body.kappa153 PRE_first_tail_x6_r0_body.s1484.ffi PRE_first_tail_x6_r0_body.s1483.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift153 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue153, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp153 t ht),
    PRE_first_tail_x6_r0_body.cbridge153,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1484.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1483.ffi) (PRE_first_tail_x6_r0_body.cfoot153 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_153 PRE_first_tail_x6_r0_body.ofx1_153 hobjC PRE_first_tail_x6_r0_body.ff0153 PRE_first_tail_x6_r0_body.ff1153 PRE_first_tail_x6_r0_body.ffck153,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1484.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s1483.ffi) (PRE_first_tail_x6_r0_body.cfoot153 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_153 PRE_first_tail_x6_r0_body.okr1_153 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn153) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf0153 PRE_first_tail_x6_r0_body.fkt0153 PRE_first_tail_x6_r0_body.fkf1153 PRE_first_tail_x6_r0_body.fkt1153 PRE_first_tail_x6_r0_body.fkck153,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh0153 PRE_first_tail_x6_r0_body.cnh1153 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe153) PRE_first_tail_x6_r0_body.cpendR153⟩

end Host.Load.Run.Tpl
end

section -- st153/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st153 0
host_stream_state PRE_first_tail_x6_r0_body.st153 1
host_stream_state PRE_first_tail_x6_r0_body.st153 2
host_stream_state PRE_first_tail_x6_r0_body.st153 3
end Host.Load.Run.Tpl
end

section -- Site153
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 153 of chain `PRE_first_tail_x6_r0_body`: `kvW__g153__g154` (`appendWindow`), the call state `PRE_first_tail_x6_r0_body.s1482`, the merged state `PRE_first_tail_x6_r0_body.s1483`,
the site template `PRE_first_tail_x6_r0_body.st153` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s1484`: the merge.
The footprint's facts are in `SiteF153`, the compaction's in `SiteC153`, `SiteK153`, `SiteNa153`, `SiteNb153`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso153 : PRE_first_tail_x6_r0_body.st153.s0 = { PRE_first_tail_x6_r0_body.s1482 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs153 : List Frame := PRE_first_tail_x6_r0_body.s1482.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_153 : PRE_first_tail_x6_r0_body.S1482.tab.length = 6630
kernel_rfl PRE_first_tail_x6_r0_body.tab0_153 : PRE_first_tail_x6_r0_body.st153.S0.tab = PRE_first_tail_x6_r0_body.S1482.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws153 : List Nat := [3574, 3575, 3576, 3577, 3578, 3579, 3580, 3581, 3582, 3583, 3584, 3585, 3586, 3587, 3588, 3589, 3590]
kernel_rfl PRE_first_tail_x6_r0_body.fresh153 : (PRE_first_tail_x6_r0_body.S1482.tab.all fun e => PRE_first_tail_x6_r0_body.ws153.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S1482.oracle.all fun q => PRE_first_tail_x6_r0_body.ws153.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab153 : PRE_first_tail_x6_r0_body.S1483.tab = PRE_first_tail_x6_r0_body.S1482.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws153
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen153 : PRE_first_tail_x6_r0_body.st153.S3.tab.length - PRE_first_tail_x6_r0_body.st153.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged153`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap153 : PRE_first_tail_x6_r0_body.s1483.heap = PRE_first_tail_x6_r0_body.st153.s3.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext153 : PRE_first_tail_x6_r0_body.s1483.next = PRE_first_tail_x6_r0_body.st153.s3.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl153 : PRE_first_tail_x6_r0_body.s1483.ctl = PRE_first_tail_x6_r0_body.st153.s3.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack153 : PRE_first_tail_x6_r0_body.s1483.stack = PRE_first_tail_x6_r0_body.st153.s3.stack ++ PRE_first_tail_x6_r0_body.s1482.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs153 : PRE_first_tail_x6_r0_body.s1483.jobs = PRE_first_tail_x6_r0_body.st153.s3.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi153 : PRE_first_tail_x6_r0_body.s1483.ffi = PRE_first_tail_x6_r0_body.st153.s3.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace153 : PRE_first_tail_x6_r0_body.s1483.trace = PRE_first_tail_x6_r0_body.st153.s3.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores153 : PRE_first_tail_x6_r0_body.s1483.stores = PRE_first_tail_x6_r0_body.st153.s3.stores

end Host.Load.Run.Tpl
end

section -- SiteD153
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 153 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived153 : PRE_first_tail_x6_r0_body.nr153.map (fun r => nth? PRE_first_tail_x6_r0_body.st153.S3.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false)))]
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo153 : PRE_first_tail_x6_r0_body.nr153.all (Nat.ble 6630) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj153 : PRE_first_tail_x6_r0_body.cws153.all (fun c => !PRE_first_tail_x6_r0_body.ws153.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ153 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws153 PRE_first_tail_x6_r0_body.crs153 PRE_first_tail_x6_r0_body.ws153

end Host.Load.Run.Tpl
end

section -- st153/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st153`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st153.wrR : List (Nat × Nat) := [(2672694, 2672695)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st153.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st153.s3.heap PRE_first_tail_x6_r0_body.st153.wrR ++ freshOf PRE_first_tail_x6_r0_body.st153.s3.heap PRE_first_tail_x6_r0_body.st153.s0.next PRE_first_tail_x6_r0_body.st153.s3.next
noncomputable def PRE_first_tail_x6_r0_body.st153.wr : List Nat := PRE_first_tail_x6_r0_body.st153.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st153.heapFoot : PRE_first_tail_x6_r0_body.st153.s3.heap = setAll PRE_first_tail_x6_r0_body.st153.s0.heap PRE_first_tail_x6_r0_body.st153.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st153.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st153.s0.next PRE_first_tail_x6_r0_body.st153.s3.next = true
theorem PRE_first_tail_x6_r0_body.st153.grows : PRE_first_tail_x6_r0_body.st153.s0.next ≤ PRE_first_tail_x6_r0_body.st153.s3.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st153.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st153.wh : List Nat := [21225, 21226, 21227, 21228, 21229, 21230]
def PRE_first_tail_x6_r0_body.st153.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st153.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st153.s3.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st153.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st153.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st153.s3.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st153.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st153.s3.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st153.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st153.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st153.s3.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st153.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st153.s3.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st153.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st153.s3.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st153.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st153.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st153.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st153.s3.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st153.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st153.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st153.s3.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st153.s3.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st153.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st153.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st153.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st153.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st153.s3.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st153.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st153.s3.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF153
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 153 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB153 : nodupT PRE_first_tail_x6_r0_body.st153.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup153 : PRE_first_tail_x6_r0_body.st153.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB153).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB153 : PRE_first_tail_x6_r0_body.st153.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound153 : ∀ b ∈ PRE_first_tail_x6_r0_body.st153.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB153 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr153 := PRE_first_tail_x6_r0_body.st153.s3.trace.take 26
kernel_rfl PRE_first_tail_x6_r0_body.traceEq153 : PRE_first_tail_x6_r0_body.st153.s3.trace = PRE_first_tail_x6_r0_body.trFr153 ++ PRE_first_tail_x6_r0_body.st153.s0.trace
theorem PRE_first_tail_x6_r0_body.trace153 : ∃ fr, PRE_first_tail_x6_r0_body.st153.s3.trace = fr ++ PRE_first_tail_x6_r0_body.st153.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq153⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide153 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB153 : (PRE_first_tail_x6_r0_body.wide153.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st153.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix153 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide153, WFix Map.id (Present PRE_first_tail_x6_r0_body.st153.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB153 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL153
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 153 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s1483`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO153 : PRE_first_tail_x6_r0_body.st153.S0.oracle = PRE_first_tail_x6_r0_body.st153.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B153 : PRE_first_tail_x6_r0_body.st153.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st153.s0.next || (PRE_first_tail_x6_r0_body.st153.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot153 : Conv.StageFoot PRE_first_tail_x6_r0_body.st153.wr PRE_first_tail_x6_r0_body.st153.s0 PRE_first_tail_x6_r0_body.st153.s3 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st153.heapFoot PRE_first_tail_x6_r0_body.wrNodup153 PRE_first_tail_x6_r0_body.wrBound153 PRE_first_tail_x6_r0_body.wr0B153 PRE_first_tail_x6_r0_body.st153.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged153 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st153.F.S → PRE_first_tail_x6_r0_body.st153.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st153.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st153.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs153 PRE_first_tail_x6_r0_body.st153.wr PRE_first_tail_x6_r0_body.s1482 PRE_first_tail_x6_r0_body.st153.s3 PRE_first_tail_x6_r0_body.st153.s0
      PRE_first_tail_x6_r0_body.st153.s3.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st153.F FR W stk M ν K PRE_first_tail_x6_r0_body.s1483 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso153 PRE_first_tail_x6_r0_body.stFoot153 PRE_first_tail_x6_r0_body.wrNodup153 PRE_first_tail_x6_r0_body.wrBound153 PRE_first_tail_x6_r0_body.trace153 PRE_first_tail_x6_r0_body.mheap153
    PRE_first_tail_x6_r0_body.mnext153 PRE_first_tail_x6_r0_body.mctl153 PRE_first_tail_x6_r0_body.mstack153 PRE_first_tail_x6_r0_body.mjobs153 PRE_first_tail_x6_r0_body.mffi153 PRE_first_tail_x6_r0_body.mtrace153 PRE_first_tail_x6_r0_body.mstores153 h

def PRE_first_tail_x6_r0_body.arrEl153_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE153_2665 : arrOf PRE_first_tail_x6_r0_body.s1483 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl153_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA153_2665 : isArrB PRE_first_tail_x6_r0_body.s1483 2665 = true
theorem PRE_first_tail_x6_r0_body.arr153_2665 : ∃ o, PRE_first_tail_x6_r0_body.s1483.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl153_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE153_2665 PRE_first_tail_x6_r0_body.arrA153_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN153_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl153_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR153_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl153_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN153_2665

def PRE_first_tail_x6_r0_body.arrEl153_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE153_2673467 : arrOf PRE_first_tail_x6_r0_body.s1483 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl153_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA153_2673467 : isArrB PRE_first_tail_x6_r0_body.s1483 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr153_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s1483.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl153_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE153_2673467 PRE_first_tail_x6_r0_body.arrA153_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN153_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl153_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR153_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl153_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN153_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k153 : isArrB PRE_first_tail_x6_r0_body.s1483 4910 = false
theorem PRE_first_tail_x6_r0_body.keep153 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s1483 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k153 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr153_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl153_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ153
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 153 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s1482`, the merged
state `PRE_first_tail_x6_r0_body.s1483`, the canonical state `PRE_first_tail_x6_r0_body.s1484`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl153 : PRE_first_tail_x6_r0_body.pl153.all (Nat.ble PRE_first_tail_x6_r0_body.s1482.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd153 : nodupT PRE_first_tail_x6_r0_body.pl153 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn1153 : Nat.ble PRE_first_tail_x6_r0_body.s1482.next 2795865 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst153 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s1482.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn153 : PRE_first_tail_x6_r0_body.s1484.next = PRE_first_tail_x6_r0_body.s1482.next + PRE_first_tail_x6_r0_body.pl153.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn153 : PRE_first_tail_x6_r0_body.s1483.next = 2795865
kernel_rfl PRE_first_tail_x6_r0_body.zgrow153 : Nat.ble PRE_first_tail_x6_r0_body.s1484.next PRE_first_tail_x6_r0_body.s1483.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh153 : PRE_first_tail_x6_r0_body.S1482.tab.all (fun e => PRE_first_tail_x6_r0_body.cws153.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd153 : nodupT PRE_first_tail_x6_r0_body.cws153 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi153 : PRE_first_tail_x6_r0_body.nr153.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S1483.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt153 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s1482.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg153_2665 : PRE_first_tail_x6_r0_body.s1484.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1484 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk153_2665 : (objOf PRE_first_tail_x6_r0_body.s1484 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm153_2665 : PRE_first_tail_x6_r0_body.s1483.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa153.obj (objOf PRE_first_tail_x6_r0_body.s1484 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s1483 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg153_2673467 : PRE_first_tail_x6_r0_body.s1484.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s1484 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk153_2673467 : (objOf PRE_first_tail_x6_r0_body.s1484 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm153_2673467 : PRE_first_tail_x6_r0_body.s1483.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa153.obj (objOf PRE_first_tail_x6_r0_body.s1484 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s1483 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw153_4910 : (PRE_first_tail_x6_r0_body.s1484.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw153_2673472 : (PRE_first_tail_x6_r0_body.s1484.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw153_2673473 : (PRE_first_tail_x6_r0_body.s1484.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd153 : PRE_first_tail_x6_r0_body.cl153.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr153 : PRE_first_tail_x6_r0_body.st153.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s1482.next || PRE_first_tail_x6_r0_body.cl153.contains b) = true
def PRE_first_tail_x6_r0_body.zl153 : List Nat := PRE_first_tail_x6_r0_body.cl153.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE153 : PRE_first_tail_x6_r0_body.zl153.map (fun a => PRE_first_tail_x6_r0_body.s1483.heap.get (PRE_first_tail_x6_r0_body.kappa153.a a)) = PRE_first_tail_x6_r0_body.zl153.map (fun a => (PRE_first_tail_x6_r0_body.s1484.heap.get a).map PRE_first_tail_x6_r0_body.kappa153.hobj)
theorem PRE_first_tail_x6_r0_body.zimg153 : HeapImg PRE_first_tail_x6_r0_body.kappa153 PRE_first_tail_x6_r0_body.s1484 PRE_first_tail_x6_r0_body.s1483 PRE_first_tail_x6_r0_body.zl153 := PRE_first_tail_x6_r0_body.zimgE153
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl153 : PRE_first_tail_x6_r0_body.s1483.ctl = PRE_first_tail_x6_r0_body.kappa153.ctl PRE_first_tail_x6_r0_body.s1484.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack153 : PRE_first_tail_x6_r0_body.s1483.stack = PRE_first_tail_x6_r0_body.s1484.stack.map PRE_first_tail_x6_r0_body.kappa153.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs153 : PRE_first_tail_x6_r0_body.s1483.jobs = PRE_first_tail_x6_r0_body.s1484.jobs.map PRE_first_tail_x6_r0_body.kappa153.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores153 : PRE_first_tail_x6_r0_body.s1483.stores = PRE_first_tail_x6_r0_body.kappa153.stores PRE_first_tail_x6_r0_body.s1484.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots153 : checkRootsSupp PRE_first_tail_x6_r0_body.s1484 6639 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC153 : PRE_first_tail_x6_r0_body.S1482.tab.length + PRE_first_tail_x6_r0_body.cws153.length = 6639
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap153 : PRE_first_tail_x6_r0_body.kappa153 = Conv.Map.compact PRE_first_tail_x6_r0_body.s1482.next 2795865 PRE_first_tail_x6_r0_body.S1482.tab.length PRE_first_tail_x6_r0_body.pl153 (PRE_first_tail_x6_r0_body.nr153.map NumV.ref) PRE_first_tail_x6_r0_body.kd153.big
  PRE_first_tail_x6_r0_body.kd153.region PRE_first_tail_x6_r0_body.kd153.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin153 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s1484.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc153 : Conv.jcleanListB (⟨21229, 18326, 2795515, 6639⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1484 PRE_first_tail_x6_r0_body.cl153 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB153 : noBigRootsP (fun i => !Conv.oldBigB (⟨21229, 18326, 2795515, 6639⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s1484.trace PRE_first_tail_x6_r0_body.s1484 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm153 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 18320 = true
theorem PRE_first_tail_x6_r0_body.cjcl153 (h : Conv.JClean (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1482) : Conv.JClean (⟨21229, 18326, 2795515, 6639⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s1484 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle153)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap153 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd153 a ha)) PRE_first_tail_x6_r0_body.zjc153

end Host.Load.Run.Tpl
end

section -- st153/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st153.bodyLast from PRE_first_tail_x6_r0_body.st153.s2 to PRE_first_tail_x6_r0_body.st153.s3 :
  interpS (step PRE_first_tail_x6_r0_body.st153.F PRE_first_tail_x6_r0_body.st153.s2).run PRE_first_tail_x6_r0_body.st153.S2 = some (PRE_first_tail_x6_r0_body.st153.s3, PRE_first_tail_x6_r0_body.st153.S3)
kernel_rfl PRE_first_tail_x6_r0_body.st153.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st153.s2.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st153.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st153.s3.stack = true

end Host.Load.Run.Tpl
end

section -- st153/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st153.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st153.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st153.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st153.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st153.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st153.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st153.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st153.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st153.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st153.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st153.s0 PRE_first_tail_x6_r0_body.st153.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st153.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st153.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st153.s2 PRE_first_tail_x6_r0_body.st153.S2) = fun _ _ => true

end Host.Load.Run.Tpl
end

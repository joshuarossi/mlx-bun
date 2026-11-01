import host.sim.template.a4pre_first_tail_x6_r0_body.m.B23
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

section -- st87/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st87.bodyK2F from PRE_first_tail_x6_r0_body.st87.s2 to PRE_first_tail_x6_r0_body.st87.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st87.F (PRE_first_tail_x6_r0_body.st87.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st87.ks 2).getD 0) PRE_first_tail_x6_r0_body.st87.s2 PRE_first_tail_x6_r0_body.st87.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st87.s3, PRE_first_tail_x6_r0_body.st87.S3)
theorem PRE_first_tail_x6_r0_body.st87.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st87.F (PRE_first_tail_x6_r0_body.st87.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st87.ks 2).getD 0) PRE_first_tail_x6_r0_body.st87.s2 PRE_first_tail_x6_r0_body.st87.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st87.s3, PRE_first_tail_x6_r0_body.st87.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st87.bodyOkLN_ok PRE_first_tail_x6_r0_body.st87.bodyK2F
end Host.Load.Run.Tpl
end

section -- st87/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st87.bodyK3F from PRE_first_tail_x6_r0_body.st87.s3 to PRE_first_tail_x6_r0_body.st87.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st87.F (PRE_first_tail_x6_r0_body.st87.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st87.ks 3).getD 0) PRE_first_tail_x6_r0_body.st87.s3 PRE_first_tail_x6_r0_body.st87.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st87.s4, PRE_first_tail_x6_r0_body.st87.S4)
theorem PRE_first_tail_x6_r0_body.st87.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st87.F (PRE_first_tail_x6_r0_body.st87.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st87.ks 3).getD 0) PRE_first_tail_x6_r0_body.st87.s3 PRE_first_tail_x6_r0_body.st87.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st87.s4, PRE_first_tail_x6_r0_body.st87.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st87.bodyOkLN_ok PRE_first_tail_x6_r0_body.st87.bodyK3F
end Host.Load.Run.Tpl
end

section -- st87/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st87.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st87.F (PRE_first_tail_x6_r0_body.st87.bodyOkL bytes rows) 11334 PRE_first_tail_x6_r0_body.st87.s0 PRE_first_tail_x6_r0_body.st87.S0 = some (PRE_first_tail_x6_r0_body.st87.s4, PRE_first_tail_x6_r0_body.st87.S4) :=
  runOk_trans PRE_first_tail_x6_r0_body.st87.F (PRE_first_tail_x6_r0_body.st87.bodyOkL bytes rows) ((((nth? PRE_first_tail_x6_r0_body.st87.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st87.ks 1).getD 0)) + ((nth? PRE_first_tail_x6_r0_body.st87.ks 2).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st87.ks 3).getD 0) PRE_first_tail_x6_r0_body.st87.s0 PRE_first_tail_x6_r0_body.st87.s3 PRE_first_tail_x6_r0_body.st87.s4 PRE_first_tail_x6_r0_body.st87.S0 PRE_first_tail_x6_r0_body.st87.S3 PRE_first_tail_x6_r0_body.st87.S4 (runOk_trans PRE_first_tail_x6_r0_body.st87.F (PRE_first_tail_x6_r0_body.st87.bodyOkL bytes rows) (((nth? PRE_first_tail_x6_r0_body.st87.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st87.ks 1).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st87.ks 2).getD 0) PRE_first_tail_x6_r0_body.st87.s0 PRE_first_tail_x6_r0_body.st87.s2 PRE_first_tail_x6_r0_body.st87.s3 PRE_first_tail_x6_r0_body.st87.S0 PRE_first_tail_x6_r0_body.st87.S2 PRE_first_tail_x6_r0_body.st87.S3 (runOk_trans PRE_first_tail_x6_r0_body.st87.F (PRE_first_tail_x6_r0_body.st87.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st87.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st87.ks 1).getD 0) PRE_first_tail_x6_r0_body.st87.s0 PRE_first_tail_x6_r0_body.st87.s1 PRE_first_tail_x6_r0_body.st87.s2 PRE_first_tail_x6_r0_body.st87.S0 PRE_first_tail_x6_r0_body.st87.S1 PRE_first_tail_x6_r0_body.st87.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st87.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st87.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st87.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st87.bodyK3 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st87.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st87.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st87.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st87.F (PRE_first_tail_x6_r0_body.st87.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st87.s0
  S0 := PRE_first_tail_x6_r0_body.st87.S0
  s1 := PRE_first_tail_x6_r0_body.st87.s4
  S1 := PRE_first_tail_x6_r0_body.st87.S4
  s2 := PRE_first_tail_x6_r0_body.st87.s5
  S2 := PRE_first_tail_x6_r0_body.st87.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st87.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st87.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st87.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st87.bodyHalt
  last := PRE_first_tail_x6_r0_body.st87.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st87.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC88
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 88 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s860` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa88` into the merged state
`PRE_first_tail_x6_r0_body.s859`. -/

def PRE_first_tail_x6_r0_body.pl88 : List Nat := []
def PRE_first_tail_x6_r0_body.nr88 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd88 : RData :=
  ⟨2744123, 2744125, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19941, 19941, 17040, 17040, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa88 : Map :=
  Conv.Map.compact 2744123 2744125 3842 PRE_first_tail_x6_r0_body.pl88 (PRE_first_tail_x6_r0_body.nr88.map NumV.ref) PRE_first_tail_x6_r0_body.kd88.big
    PRE_first_tail_x6_r0_body.kd88.region PRE_first_tail_x6_r0_body.kd88.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws88 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs88 : List SymE := PRE_first_tail_x6_r0_body.nr88.map fun r => (nth? PRE_first_tail_x6_r0_body.S859.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta88 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws88 PRE_first_tail_x6_r0_body.crs88
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB88 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab88 : PRE_first_tail_x6_r0_body.S860.tab = PRE_first_tail_x6_r0_body.S858.tab ++ PRE_first_tail_x6_r0_body.cws88.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace88 : PRE_first_tail_x6_r0_body.s860.trace = PRE_first_tail_x6_r0_body.s858.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext88 : PRE_first_tail_x6_r0_body.s860.next = 2744123
kernel_rfl PRE_first_tail_x6_r0_body.ccounters88 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s860.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s860.ffi).mlx.nnext) = (19941, 17040)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue88 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s859.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s860.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa88.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp88 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s860.ffi).mlx.tokens.all (bSN 3842) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean88 : Conv.cleanListB 19941 131072 (fun r => Nat.ble 79764 r) PRE_first_tail_x6_r0_body.s860
    (PRE_first_tail_x6_r0_body.wrB88 ++ (List.range 0).map (2744123 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs88 : bigsOutB 19941 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s860.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK88
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl88`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl88 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo88 : List Nat := []
def PRE_first_tail_x6_r0_body.cln88 : List Nat := []
def PRE_first_tail_x6_r0_body.cli88 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap88 : PRE_first_tail_x6_r0_body.s860.heap = Stage.setAll PRE_first_tail_x6_r0_body.s858.heap (PRE_first_tail_x6_r0_body.cl88.filterMap fun a => (PRE_first_tail_x6_r0_body.s860.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe88 : Nat.ble PRE_first_tail_x6_r0_body.s858.next PRE_first_tail_x6_r0_body.s860.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP88 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s858 PRE_first_tail_x6_r0_body.s860 PRE_first_tail_x6_r0_body.cl88 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp88 : Conv.suppListB PRE_first_tail_x6_r0_body.s860 3842 PRE_first_tail_x6_r0_body.cl88 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound88 : Conv.boundListB PRE_first_tail_x6_r0_body.s860 PRE_first_tail_x6_r0_body.cl88 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK88 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s860.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln88.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s860.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK88 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s860.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo88.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s860.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK88 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s860.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli88.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s860.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst88 : Conv.sstListB 3842 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s860.ffi).mlx PRE_first_tail_x6_r0_body.cln88 PRE_first_tail_x6_r0_body.clo88 PRE_first_tail_x6_r0_body.cli88 = true

end Host.Load.Run.Tpl
end

section -- SiteCl88
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA88 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s860.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo88.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s860.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd88 : (PRE_first_tail_x6_r0_body.clo88 ++ PRE_first_tail_x6_r0_body.cln88 ++ PRE_first_tail_x6_r0_body.cli88).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle88 : Conv.Cnt.leB (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck88 : Conv.ncleanListB (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s860.ffi).mlx PRE_first_tail_x6_r0_body.clo88 PRE_first_tail_x6_r0_body.cln88 PRE_first_tail_x6_r0_body.cli88 = true
theorem PRE_first_tail_x6_r0_body.cncl88 (h : Conv.NClean (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx) : Conv.NClean (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s860.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle88 PRE_first_tail_x6_r0_body.ckA88 PRE_first_tail_x6_r0_body.cobjsK88 PRE_first_tail_x6_r0_body.cnodesK88 PRE_first_tail_x6_r0_body.citemsK88 PRE_first_tail_x6_r0_body.cbd88 PRE_first_tail_x6_r0_body.cck88

end Host.Load.Run.Tpl
end

section -- SiteS88
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 88 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc88 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P88 : LoadP := PRE_first_tail_x6_r0_body.Pc88.raise 17040
kernel_rfl PRE_first_tail_x6_r0_body.craise88 : Nat.ble PRE_first_tail_x6_r0_body.Pc88.N0 17040 = true
theorem PRE_first_tail_x6_r0_body.raised88 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc88 PRE_first_tail_x6_r0_body.P88 :=
  .inr ⟨17040, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise88, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_88 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s860.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_88 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s859.ffi)
def PRE_first_tail_x6_r0_body.khinv88 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv88 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS88 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS88 : List Nat := List.range' 17040 0
def PRE_first_tail_x6_r0_body.ciS88 : List Nat := [] ++ List.range' 17040 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh088 : PRE_first_tail_x6_r0_body.kd88.nh0 = PRE_first_tail_x6_r0_body.cx0_88.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh188 : PRE_first_tail_x6_r0_body.kd88.nh1 = PRE_first_tail_x6_r0_body.cx1_88.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn088 : PRE_first_tail_x6_r0_body.kd88.nn0 = PRE_first_tail_x6_r0_body.cx0_88.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn188 : PRE_first_tail_x6_r0_body.kd88.nn1 = PRE_first_tail_x6_r0_body.cx1_88.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo88 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P88.lo && Nat.ble PRE_first_tail_x6_r0_body.P88.lo PRE_first_tail_x6_r0_body.cx0_88.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P88.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P88.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt88 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_88.mlx.next PRE_first_tail_x6_r0_body.cx1_88.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_88.mlx.nnext PRE_first_tail_x6_r0_body.cx1_88.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband88 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P88.NL && Nat.ble PRE_first_tail_x6_r0_body.P88.NL PRE_first_tail_x6_r0_body.P88.N0 && Nat.ble PRE_first_tail_x6_r0_body.P88.N0 PRE_first_tail_x6_r0_body.cx0_88.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow88 : PRE_first_tail_x6_r0_body.kd88.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren88 : checkRenG PRE_first_tail_x6_r0_body.kd88.hnd PRE_first_tail_x6_r0_body.khinv88 (phB PRE_first_tail_x6_r0_body.cx0_88.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband88 : PRE_first_tail_x6_r0_body.kd88.checkBand PRE_first_tail_x6_r0_body.P88.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos88 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd88.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren88 : checkRenG PRE_first_tail_x6_r0_body.kd88.node PRE_first_tail_x6_r0_body.kninv88 (pnB PRE_first_tail_x6_r0_body.cx0_88.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow88 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd88.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P88.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd88.nodeF j) PRE_first_tail_x6_r0_body.cx1_88.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a88 : PRE_first_tail_x6_r0_body.cx0_88.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b88 : PRE_first_tail_x6_r0_body.cx0_88.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok188 : PRE_first_tail_x6_r0_body.cx1_88.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend88 : PRE_first_tail_x6_r0_body.cx1_88.mlx.pending = PRE_first_tail_x6_r0_body.cx0_88.mlx.pending.map PRE_first_tail_x6_r0_body.kappa88.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh88 : PRE_first_tail_x6_r0_body.cx1_88.mlx.errh = PRE_first_tail_x6_r0_body.cx0_88.mlx.errh.map PRE_first_tail_x6_r0_body.kappa88.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles88 : PRE_first_tail_x6_r0_body.cx1_88.mlx.files = PRE_first_tail_x6_r0_body.cx0_88.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch88 : PRE_first_tail_x6_r0_body.cx1_88.mlx.arch = PRE_first_tail_x6_r0_body.cx0_88.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes88 : PRE_first_tail_x6_r0_body.cx1_88.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_88.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired88 : PRE_first_tail_x6_r0_body.cx1_88.mlx.wired = PRE_first_tail_x6_r0_body.cx0_88.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost88 : PRE_first_tail_x6_r0_body.cx1_88.host = PRE_first_tail_x6_r0_body.cx0_88.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd88`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn088 : PRE_first_tail_x6_r0_body.kd88.n0 = 2744123
kernel_rfl PRE_first_tail_x6_r0_body.ckn188 : PRE_first_tail_x6_r0_body.kd88.n1 = 2744125
kernel_rfl PRE_first_tail_x6_r0_body.ckheap88 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd88.heap).all (fun x => Nat.ble 2744123 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl88 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_body.kd88.heap.get (2744123 + j) = nth? PRE_first_tail_x6_r0_body.pl88 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja88 : Nat.ble 2744123 2744123 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn88 : Nat.ble 3842 3842 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD88 : Nat.ble 2744123 PRE_first_tail_x6_r0_body.kd88.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn88 : Nat.ble 19941 PRE_first_tail_x6_r0_body.kd88.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn88 : Nat.ble 17040 PRE_first_tail_x6_r0_body.kd88.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb88 : Nat.ble 19941 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap88 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd88.heap).all (Nat.ble (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd88 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd88.hnd).all (Nat.ble (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode88 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd88.node).all (Nat.ble (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix88 : Conv.FixOld (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa88 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja88) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn88) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD88) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn88) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn88) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb88) PRE_first_tail_x6_r0_body.fheap88 PRE_first_tail_x6_r0_body.fhnd88 PRE_first_tail_x6_r0_body.fnode88
kernel_rfl PRE_first_tail_x6_r0_body.fcxn88 : (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn88 : (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle088 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_88.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_88.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk88 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd88.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A88 : PRE_first_tail_x6_r0_body.cx1_88.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS88.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_88.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O88 : PRE_first_tail_x6_r0_body.cx1_88.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS88.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_88.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N88 : PRE_first_tail_x6_r0_body.cx1_88.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS88.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_88.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I88 : PRE_first_tail_x6_r0_body.cx1_88.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS88.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_88.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd88 : (PRE_first_tail_x6_r0_body.clo88 ++ PRE_first_tail_x6_r0_body.cln88 ++ PRE_first_tail_x6_r0_body.cli88 ++ PRE_first_tail_x6_r0_body.cwS88 ++ PRE_first_tail_x6_r0_body.cnS88 ++ PRE_first_tail_x6_r0_body.ciS88).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW88 : PRE_first_tail_x6_r0_body.cwS88.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo88.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI88 : PRE_first_tail_x6_r0_body.ciS88.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli88.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN88 : PRE_first_tail_x6_r0_body.cnS88.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF88 : PRE_first_tail_x6_r0_body.cln88.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh88 : PRE_first_tail_x6_r0_body.clo88.all (handleOK PRE_first_tail_x6_r0_body.kappa88 PRE_first_tail_x6_r0_body.P88.lo PRE_first_tail_x6_r0_body.cx0_88.mlx PRE_first_tail_x6_r0_body.cx1_88.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo88 : PRE_first_tail_x6_r0_body.clo88.map (fun h => PRE_first_tail_x6_r0_body.cx1_88.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa88.handle h)) = PRE_first_tail_x6_r0_body.clo88.map (fun h => (PRE_first_tail_x6_r0_body.cx0_88.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa88.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok88 : PRE_first_tail_x6_r0_body.clo88.all (objOK PRE_first_tail_x6_r0_body.kappa88 PRE_first_tail_x6_r0_body.P88.NL PRE_first_tail_x6_r0_body.cx0_88.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd88 : PRE_first_tail_x6_r0_body.cln88.all (nodeOKF PRE_first_tail_x6_r0_body.kappa88 PRE_first_tail_x6_r0_body.P88 PRE_first_tail_x6_r0_body.cx0_88.mlx PRE_first_tail_x6_r0_body.cx1_88.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp88 : ((PRE_first_tail_x6_r0_body.cln88.filter (fullB PRE_first_tail_x6_r0_body.P88))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_88.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa88.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln88.filter (fullB PRE_first_tail_x6_r0_body.P88))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_88.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa88.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI88 : incrB PRE_first_tail_x6_r0_body.kd88.nodeF (List.range' 17040 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK88 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd88.node).all (fun k => Nat.ble 17040 k && Nat.blt k 17040) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL88 : (PRE_first_tail_x6_r0_body.cln88.filter (Nat.ble PRE_first_tail_x6_r0_body.P88.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd88.nodeF i) && (Nat.blt i 17040 || Nat.ble PRE_first_tail_x6_r0_body.kd88.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord88 : (PRE_first_tail_x6_r0_body.cln88.filter (Nat.ble PRE_first_tail_x6_r0_body.P88.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd88.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd88.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd88.nodeF j) (PRE_first_tail_x6_r0_body.kd88.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow88 PRE_first_tail_x6_r0_body.cnn188 PRE_first_tail_x6_r0_body.fnordI88 PRE_first_tail_x6_r0_body.fnordK88 PRE_first_tail_x6_r0_body.fnordL88
kernel_rfl PRE_first_tail_x6_r0_body.fi88 : PRE_first_tail_x6_r0_body.cli88.all (pnB PRE_first_tail_x6_r0_body.cx0_88.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii88 : PRE_first_tail_x6_r0_body.cli88.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_88.mlx.items.get (PRE_first_tail_x6_r0_body.kappa88.node k) = (PRE_first_tail_x6_r0_body.cx0_88.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa88.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot88 (clean : Conv.NClean (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P88.NL) (cl : SSt (· < 3842) PRE_first_tail_x6_r0_body.cx0_88.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P88 3842 PRE_first_tail_x6_r0_body.kappa88 PRE_first_tail_x6_r0_body.kd88 PRE_first_tail_x6_r0_body.khinv88 PRE_first_tail_x6_r0_body.kninv88 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx PRE_first_tail_x6_r0_body.cx0_88.mlx PRE_first_tail_x6_r0_body.cx1_88.mlx (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo88 PRE_first_tail_x6_r0_body.cln88 PRE_first_tail_x6_r0_body.cli88 PRE_first_tail_x6_r0_body.cwS88 PRE_first_tail_x6_r0_body.cnS88 PRE_first_tail_x6_r0_body.ciS88 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh088, PRE_first_tail_x6_r0_body.cnh188, PRE_first_tail_x6_r0_body.cnn088, PRE_first_tail_x6_r0_body.cnn188, PRE_first_tail_x6_r0_body.cplo88, PRE_first_tail_x6_r0_body.ccnt88, PRE_first_tail_x6_r0_body.cnband88, PRE_first_tail_x6_r0_body.chbelow88, PRE_first_tail_x6_r0_body.chren88, PRE_first_tail_x6_r0_body.cband88, PRE_first_tail_x6_r0_body.cnh1pos88, PRE_first_tail_x6_r0_body.cnren88, PRE_first_tail_x6_r0_body.cnlow88, PRE_first_tail_x6_r0_body.cabs0a88, PRE_first_tail_x6_r0_body.cabs0b88, PRE_first_tail_x6_r0_body.ctok188, PRE_first_tail_x6_r0_body.cpend88, PRE_first_tail_x6_r0_body.cerrh88, PRE_first_tail_x6_r0_body.cfiles88, PRE_first_tail_x6_r0_body.carch88, PRE_first_tail_x6_r0_body.csizes88, PRE_first_tail_x6_r0_body.cwired88, PRE_first_tail_x6_r0_body.cfix88, clean, PRE_first_tail_x6_r0_body.fcxn88, PRE_first_tail_x6_r0_body.fcnn88, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle088, PRE_first_tail_x6_r0_body.fnk88, PRE_first_tail_x6_r0_body.ckA88, PRE_first_tail_x6_r0_body.cobjsK88, PRE_first_tail_x6_r0_body.cnodesK88, PRE_first_tail_x6_r0_body.citemsK88, PRE_first_tail_x6_r0_body.f1A88, PRE_first_tail_x6_r0_body.f1O88, PRE_first_tail_x6_r0_body.f1N88, PRE_first_tail_x6_r0_body.f1I88, PRE_first_tail_x6_r0_body.fbd88, PRE_first_tail_x6_r0_body.fincW88, PRE_first_tail_x6_r0_body.fincI88, PRE_first_tail_x6_r0_body.fincN88, PRE_first_tail_x6_r0_body.flnF88, PRE_first_tail_x6_r0_body.fh88, PRE_first_tail_x6_r0_body.fo88, PRE_first_tail_x6_r0_body.fok88, PRE_first_tail_x6_r0_body.fnd88, PRE_first_tail_x6_r0_body.fp88, PRE_first_tail_x6_r0_body.fnord88, PRE_first_tail_x6_r0_body.fi88, PRE_first_tail_x6_r0_body.fii88⟩
theorem PRE_first_tail_x6_r0_body.cnshift88 (clean : Conv.NClean (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P88.NL) (cl : SSt (· < 3842) PRE_first_tail_x6_r0_body.cx0_88.mlx) : NShift PRE_first_tail_x6_r0_body.P88 3842 PRE_first_tail_x6_r0_body.kappa88 PRE_first_tail_x6_r0_body.cx0_88 PRE_first_tail_x6_r0_body.cx1_88 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot88 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost88 (compact_a_eq PRE_first_tail_x6_r0_body.ckn088 PRE_first_tail_x6_r0_body.ckn188 PRE_first_tail_x6_r0_body.ckheap88 PRE_first_tail_x6_r0_body.ckpl88)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_88 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s858.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_88 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s858.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_88 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s858.ffi) = some PRE_first_tail_x6_r0_body.fxC_88
kernel_rfl PRE_first_tail_x6_r0_body.okrC_88 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s858.ffi) = some PRE_first_tail_x6_r0_body.krC_88
noncomputable def PRE_first_tail_x6_r0_body.fx0_88 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s860.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_88 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s860.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_88 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s860.ffi) = some PRE_first_tail_x6_r0_body.fx0_88
kernel_rfl PRE_first_tail_x6_r0_body.okr0_88 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s860.ffi) = some PRE_first_tail_x6_r0_body.kr0_88
noncomputable def PRE_first_tail_x6_r0_body.fx1_88 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s859.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_88 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s859.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_88 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s859.ffi) = some PRE_first_tail_x6_r0_body.fx1_88
kernel_rfl PRE_first_tail_x6_r0_body.okr1_88 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s859.ffi) = some PRE_first_tail_x6_r0_body.kr1_88
kernel_rfl PRE_first_tail_x6_r0_body.ff088 : PRE_first_tail_x6_r0_body.fx0_88 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_88 (PRE_first_tail_x6_r0_body.clo88.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_88.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff188 : PRE_first_tail_x6_r0_body.fx1_88 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_88 (PRE_first_tail_x6_r0_body.cwS88.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_88.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck88 : freedLB PRE_first_tail_x6_r0_body.kappa88 PRE_first_tail_x6_r0_body.cx0_88.mlx PRE_first_tail_x6_r0_body.fx0_88 PRE_first_tail_x6_r0_body.fx1_88 PRE_first_tail_x6_r0_body.clo88 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf088 : PRE_first_tail_x6_r0_body.kr0_88.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_88.flags (PRE_first_tail_x6_r0_body.clo88.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_88.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt088 : PRE_first_tail_x6_r0_body.kr0_88.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_88.targs (PRE_first_tail_x6_r0_body.clo88.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_88.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf188 : PRE_first_tail_x6_r0_body.kr1_88.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_88.flags (PRE_first_tail_x6_r0_body.cwS88.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_88.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt188 : PRE_first_tail_x6_r0_body.kr1_88.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_88.targs (PRE_first_tail_x6_r0_body.cwS88.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_88.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck88 : krecLB PRE_first_tail_x6_r0_body.kappa88 3842 PRE_first_tail_x6_r0_body.cx0_88.mlx PRE_first_tail_x6_r0_body.kr0_88 PRE_first_tail_x6_r0_body.kr1_88 PRE_first_tail_x6_r0_body.clo88 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn88 : Nat.ble 3842 3842 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge88 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s859.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s860.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR88 : pendRegB PRE_first_tail_x6_r0_body.kappa88 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s860.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe88 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s860.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s859.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift88 (clean : Conv.NClean (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P88.NL) (cl : SSt (· < 3842) PRE_first_tail_x6_r0_body.cx0_88.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_88.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_88.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_88.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s858.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_88.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P88 3842 PRE_first_tail_x6_r0_body.kappa88 PRE_first_tail_x6_r0_body.s860.ffi PRE_first_tail_x6_r0_body.s859.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift88 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue88, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp88 t ht),
    PRE_first_tail_x6_r0_body.cbridge88,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s860.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s859.ffi) (PRE_first_tail_x6_r0_body.cfoot88 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_88 PRE_first_tail_x6_r0_body.ofx1_88 hobjC PRE_first_tail_x6_r0_body.ff088 PRE_first_tail_x6_r0_body.ff188 PRE_first_tail_x6_r0_body.ffck88,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s860.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s859.ffi) (PRE_first_tail_x6_r0_body.cfoot88 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_88 PRE_first_tail_x6_r0_body.okr1_88 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn88) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf088 PRE_first_tail_x6_r0_body.fkt088 PRE_first_tail_x6_r0_body.fkf188 PRE_first_tail_x6_r0_body.fkt188 PRE_first_tail_x6_r0_body.fkck88,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh088 PRE_first_tail_x6_r0_body.cnh188 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe88) PRE_first_tail_x6_r0_body.cpendR88⟩

end Host.Load.Run.Tpl
end

section -- st88/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st88 0
host_stream_state PRE_first_tail_x6_r0_body.st88 1
host_stream_state PRE_first_tail_x6_r0_body.st88 2
end Host.Load.Run.Tpl
end

section -- Site88
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 88 of chain `PRE_first_tail_x6_r0_body`: `rowBlocks__g88__g89` (`rowBlocks`), the call state `PRE_first_tail_x6_r0_body.s858`, the merged state `PRE_first_tail_x6_r0_body.s859`,
the site template `PRE_first_tail_x6_r0_body.st88` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s860`: the merge.
The footprint's facts are in `SiteF88`, the compaction's in `SiteC88`, `SiteK88`, `SiteNa88`, `SiteNb88`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso88 : PRE_first_tail_x6_r0_body.st88.s0 = { PRE_first_tail_x6_r0_body.s858 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs88 : List Frame := PRE_first_tail_x6_r0_body.s858.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_88 : PRE_first_tail_x6_r0_body.S858.tab.length = 3842
kernel_rfl PRE_first_tail_x6_r0_body.tab0_88 : PRE_first_tail_x6_r0_body.st88.S0.tab = PRE_first_tail_x6_r0_body.S858.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws88 : List Nat := [2496, 2497]
kernel_rfl PRE_first_tail_x6_r0_body.fresh88 : (PRE_first_tail_x6_r0_body.S858.tab.all fun e => PRE_first_tail_x6_r0_body.ws88.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S858.oracle.all fun q => PRE_first_tail_x6_r0_body.ws88.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab88 : PRE_first_tail_x6_r0_body.S859.tab = PRE_first_tail_x6_r0_body.S858.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws88
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen88 : PRE_first_tail_x6_r0_body.st88.S2.tab.length - PRE_first_tail_x6_r0_body.st88.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged88`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap88 : PRE_first_tail_x6_r0_body.s859.heap = PRE_first_tail_x6_r0_body.st88.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext88 : PRE_first_tail_x6_r0_body.s859.next = PRE_first_tail_x6_r0_body.st88.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl88 : PRE_first_tail_x6_r0_body.s859.ctl = PRE_first_tail_x6_r0_body.st88.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack88 : PRE_first_tail_x6_r0_body.s859.stack = PRE_first_tail_x6_r0_body.st88.s2.stack ++ PRE_first_tail_x6_r0_body.s858.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs88 : PRE_first_tail_x6_r0_body.s859.jobs = PRE_first_tail_x6_r0_body.st88.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi88 : PRE_first_tail_x6_r0_body.s859.ffi = PRE_first_tail_x6_r0_body.st88.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace88 : PRE_first_tail_x6_r0_body.s859.trace = PRE_first_tail_x6_r0_body.st88.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores88 : PRE_first_tail_x6_r0_body.s859.stores = PRE_first_tail_x6_r0_body.st88.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD88
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 88 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived88 : PRE_first_tail_x6_r0_body.nr88.map (fun r => nth? PRE_first_tail_x6_r0_body.st88.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo88 : PRE_first_tail_x6_r0_body.nr88.all (Nat.ble 3842) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj88 : PRE_first_tail_x6_r0_body.cws88.all (fun c => !PRE_first_tail_x6_r0_body.ws88.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ88 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws88 PRE_first_tail_x6_r0_body.crs88 PRE_first_tail_x6_r0_body.ws88

end Host.Load.Run.Tpl
end

section -- st88/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st88`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st88.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st88.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st88.s2.heap PRE_first_tail_x6_r0_body.st88.wrR ++ freshOf PRE_first_tail_x6_r0_body.st88.s2.heap PRE_first_tail_x6_r0_body.st88.s0.next PRE_first_tail_x6_r0_body.st88.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st88.wr : List Nat := PRE_first_tail_x6_r0_body.st88.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st88.heapFoot : PRE_first_tail_x6_r0_body.st88.s2.heap = setAll PRE_first_tail_x6_r0_body.st88.s0.heap PRE_first_tail_x6_r0_body.st88.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st88.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st88.s0.next PRE_first_tail_x6_r0_body.st88.s2.next = true
theorem PRE_first_tail_x6_r0_body.st88.grows : PRE_first_tail_x6_r0_body.st88.s0.next ≤ PRE_first_tail_x6_r0_body.st88.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st88.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st88.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st88.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st88.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st88.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st88.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st88.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st88.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st88.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st88.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st88.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st88.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st88.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st88.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st88.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st88.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st88.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st88.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st88.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st88.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st88.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st88.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st88.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st88.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st88.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st88.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st88.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st88.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st88.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st88.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st88.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st88.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF88
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 88 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB88 : nodupT PRE_first_tail_x6_r0_body.st88.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup88 : PRE_first_tail_x6_r0_body.st88.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB88).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB88 : PRE_first_tail_x6_r0_body.st88.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound88 : ∀ b ∈ PRE_first_tail_x6_r0_body.st88.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB88 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr88 := PRE_first_tail_x6_r0_body.st88.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq88 : PRE_first_tail_x6_r0_body.st88.s2.trace = PRE_first_tail_x6_r0_body.trFr88 ++ PRE_first_tail_x6_r0_body.st88.s0.trace
theorem PRE_first_tail_x6_r0_body.trace88 : ∃ fr, PRE_first_tail_x6_r0_body.st88.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st88.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq88⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide88 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB88 : (PRE_first_tail_x6_r0_body.wide88.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st88.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix88 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide88, WFix Map.id (Present PRE_first_tail_x6_r0_body.st88.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB88 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL88
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 88 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s859`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO88 : PRE_first_tail_x6_r0_body.st88.S0.oracle = PRE_first_tail_x6_r0_body.st88.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B88 : PRE_first_tail_x6_r0_body.st88.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st88.s0.next || (PRE_first_tail_x6_r0_body.st88.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot88 : Conv.StageFoot PRE_first_tail_x6_r0_body.st88.wr PRE_first_tail_x6_r0_body.st88.s0 PRE_first_tail_x6_r0_body.st88.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st88.heapFoot PRE_first_tail_x6_r0_body.wrNodup88 PRE_first_tail_x6_r0_body.wrBound88 PRE_first_tail_x6_r0_body.wr0B88 PRE_first_tail_x6_r0_body.st88.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged88 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st88.F.S → PRE_first_tail_x6_r0_body.st88.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st88.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st88.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs88 PRE_first_tail_x6_r0_body.st88.wr PRE_first_tail_x6_r0_body.s858 PRE_first_tail_x6_r0_body.st88.s2 PRE_first_tail_x6_r0_body.st88.s0
      PRE_first_tail_x6_r0_body.st88.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st88.F FR W stk M ν K PRE_first_tail_x6_r0_body.s859 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso88 PRE_first_tail_x6_r0_body.stFoot88 PRE_first_tail_x6_r0_body.wrNodup88 PRE_first_tail_x6_r0_body.wrBound88 PRE_first_tail_x6_r0_body.trace88 PRE_first_tail_x6_r0_body.mheap88
    PRE_first_tail_x6_r0_body.mnext88 PRE_first_tail_x6_r0_body.mctl88 PRE_first_tail_x6_r0_body.mstack88 PRE_first_tail_x6_r0_body.mjobs88 PRE_first_tail_x6_r0_body.mffi88 PRE_first_tail_x6_r0_body.mtrace88 PRE_first_tail_x6_r0_body.mstores88 h

def PRE_first_tail_x6_r0_body.arrEl88_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE88_2665 : arrOf PRE_first_tail_x6_r0_body.s859 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl88_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA88_2665 : isArrB PRE_first_tail_x6_r0_body.s859 2665 = true
theorem PRE_first_tail_x6_r0_body.arr88_2665 : ∃ o, PRE_first_tail_x6_r0_body.s859.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl88_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE88_2665 PRE_first_tail_x6_r0_body.arrA88_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN88_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl88_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR88_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl88_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN88_2665

def PRE_first_tail_x6_r0_body.arrEl88_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE88_2673467 : arrOf PRE_first_tail_x6_r0_body.s859 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl88_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA88_2673467 : isArrB PRE_first_tail_x6_r0_body.s859 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr88_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s859.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl88_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE88_2673467 PRE_first_tail_x6_r0_body.arrA88_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN88_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl88_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR88_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl88_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN88_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k88 : isArrB PRE_first_tail_x6_r0_body.s859 4910 = false
theorem PRE_first_tail_x6_r0_body.keep88 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s859 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k88 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr88_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl88_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ88
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 88 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s858`, the merged
state `PRE_first_tail_x6_r0_body.s859`, the canonical state `PRE_first_tail_x6_r0_body.s860`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl88 : PRE_first_tail_x6_r0_body.pl88.all (Nat.ble PRE_first_tail_x6_r0_body.s858.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd88 : nodupT PRE_first_tail_x6_r0_body.pl88 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn188 : Nat.ble PRE_first_tail_x6_r0_body.s858.next 2744125 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst88 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s858.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn88 : PRE_first_tail_x6_r0_body.s860.next = PRE_first_tail_x6_r0_body.s858.next + PRE_first_tail_x6_r0_body.pl88.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn88 : PRE_first_tail_x6_r0_body.s859.next = 2744125
kernel_rfl PRE_first_tail_x6_r0_body.zgrow88 : Nat.ble PRE_first_tail_x6_r0_body.s860.next PRE_first_tail_x6_r0_body.s859.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh88 : PRE_first_tail_x6_r0_body.S858.tab.all (fun e => PRE_first_tail_x6_r0_body.cws88.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd88 : nodupT PRE_first_tail_x6_r0_body.cws88 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi88 : PRE_first_tail_x6_r0_body.nr88.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S859.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt88 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s858.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg88_2665 : PRE_first_tail_x6_r0_body.s860.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s860 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk88_2665 : (objOf PRE_first_tail_x6_r0_body.s860 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm88_2665 : PRE_first_tail_x6_r0_body.s859.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa88.obj (objOf PRE_first_tail_x6_r0_body.s860 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s859 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg88_2673467 : PRE_first_tail_x6_r0_body.s860.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s860 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk88_2673467 : (objOf PRE_first_tail_x6_r0_body.s860 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm88_2673467 : PRE_first_tail_x6_r0_body.s859.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa88.obj (objOf PRE_first_tail_x6_r0_body.s860 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s859 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw88_4910 : (PRE_first_tail_x6_r0_body.s860.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw88_2673472 : (PRE_first_tail_x6_r0_body.s860.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw88_2673473 : (PRE_first_tail_x6_r0_body.s860.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd88 : PRE_first_tail_x6_r0_body.cl88.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr88 : PRE_first_tail_x6_r0_body.st88.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s858.next || PRE_first_tail_x6_r0_body.cl88.contains b) = true
def PRE_first_tail_x6_r0_body.zl88 : List Nat := PRE_first_tail_x6_r0_body.cl88.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE88 : PRE_first_tail_x6_r0_body.zl88.map (fun a => PRE_first_tail_x6_r0_body.s859.heap.get (PRE_first_tail_x6_r0_body.kappa88.a a)) = PRE_first_tail_x6_r0_body.zl88.map (fun a => (PRE_first_tail_x6_r0_body.s860.heap.get a).map PRE_first_tail_x6_r0_body.kappa88.hobj)
theorem PRE_first_tail_x6_r0_body.zimg88 : HeapImg PRE_first_tail_x6_r0_body.kappa88 PRE_first_tail_x6_r0_body.s860 PRE_first_tail_x6_r0_body.s859 PRE_first_tail_x6_r0_body.zl88 := PRE_first_tail_x6_r0_body.zimgE88
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl88 : PRE_first_tail_x6_r0_body.s859.ctl = PRE_first_tail_x6_r0_body.kappa88.ctl PRE_first_tail_x6_r0_body.s860.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack88 : PRE_first_tail_x6_r0_body.s859.stack = PRE_first_tail_x6_r0_body.s860.stack.map PRE_first_tail_x6_r0_body.kappa88.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs88 : PRE_first_tail_x6_r0_body.s859.jobs = PRE_first_tail_x6_r0_body.s860.jobs.map PRE_first_tail_x6_r0_body.kappa88.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores88 : PRE_first_tail_x6_r0_body.s859.stores = PRE_first_tail_x6_r0_body.kappa88.stores PRE_first_tail_x6_r0_body.s860.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots88 : checkRootsSupp PRE_first_tail_x6_r0_body.s860 3842 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC88 : PRE_first_tail_x6_r0_body.S858.tab.length + PRE_first_tail_x6_r0_body.cws88.length = 3842
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap88 : PRE_first_tail_x6_r0_body.kappa88 = Conv.Map.compact PRE_first_tail_x6_r0_body.s858.next 2744125 PRE_first_tail_x6_r0_body.S858.tab.length PRE_first_tail_x6_r0_body.pl88 (PRE_first_tail_x6_r0_body.nr88.map NumV.ref) PRE_first_tail_x6_r0_body.kd88.big
  PRE_first_tail_x6_r0_body.kd88.region PRE_first_tail_x6_r0_body.kd88.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin88 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s860.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc88 : Conv.jcleanListB (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s860 PRE_first_tail_x6_r0_body.cl88 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB88 : noBigRootsP (fun i => !Conv.oldBigB (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s860.trace PRE_first_tail_x6_r0_body.s860 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm88 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 17040 = true
theorem PRE_first_tail_x6_r0_body.cjcl88 (h : Conv.JClean (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s858) : Conv.JClean (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s860 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle88)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap88 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd88 a ha)) PRE_first_tail_x6_r0_body.zjc88

end Host.Load.Run.Tpl
end

section -- st88/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st88.bodyLast from PRE_first_tail_x6_r0_body.st88.s1 to PRE_first_tail_x6_r0_body.st88.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st88.F PRE_first_tail_x6_r0_body.st88.s1).run PRE_first_tail_x6_r0_body.st88.S1 = some (PRE_first_tail_x6_r0_body.st88.s2, PRE_first_tail_x6_r0_body.st88.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st88.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st88.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st88.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st88.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st88/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st88.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st88.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st88.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st88.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st88.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st88.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st88.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st88.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st88.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st88.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st88.s0 PRE_first_tail_x6_r0_body.st88.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st88.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st88.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st88.s1 PRE_first_tail_x6_r0_body.st88.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st88/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st88.bodyK0F from PRE_first_tail_x6_r0_body.st88.s0 to PRE_first_tail_x6_r0_body.st88.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st88.F (PRE_first_tail_x6_r0_body.st88.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st88.ks 0).getD 0) PRE_first_tail_x6_r0_body.st88.s0 PRE_first_tail_x6_r0_body.st88.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st88.s1, PRE_first_tail_x6_r0_body.st88.S1)
theorem PRE_first_tail_x6_r0_body.st88.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st88.F (PRE_first_tail_x6_r0_body.st88.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st88.ks 0).getD 0) PRE_first_tail_x6_r0_body.st88.s0 PRE_first_tail_x6_r0_body.st88.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st88.s1, PRE_first_tail_x6_r0_body.st88.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st88.bodyOkLN_ok PRE_first_tail_x6_r0_body.st88.bodyK0F
end Host.Load.Run.Tpl
end

section -- st88/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st88.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st88.F (PRE_first_tail_x6_r0_body.st88.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st88.s0 PRE_first_tail_x6_r0_body.st88.S0 = some (PRE_first_tail_x6_r0_body.st88.s1, PRE_first_tail_x6_r0_body.st88.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st88.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st88.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st88.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st88.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st88.F (PRE_first_tail_x6_r0_body.st88.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st88.s0
  S0 := PRE_first_tail_x6_r0_body.st88.S0
  s1 := PRE_first_tail_x6_r0_body.st88.s1
  S1 := PRE_first_tail_x6_r0_body.st88.S1
  s2 := PRE_first_tail_x6_r0_body.st88.s2
  S2 := PRE_first_tail_x6_r0_body.st88.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st88.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st88.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st88.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st88.bodyHalt
  last := PRE_first_tail_x6_r0_body.st88.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st88.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC89
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 89 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s864` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa89` into the merged state
`PRE_first_tail_x6_r0_body.s863`. -/

def PRE_first_tail_x6_r0_body.pl89 : List Nat := [2744430]
def PRE_first_tail_x6_r0_body.nr89 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd89 : RData :=
  ⟨2744412, 2744431, Stage.setAll PTrie.nil [(2744411, 2744430)], Stage.setAll PTrie.nil [],
   19948, 19948, 17044, 17044, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa89 : Map :=
  Conv.Map.compact 2744411 2744431 3859 PRE_first_tail_x6_r0_body.pl89 (PRE_first_tail_x6_r0_body.nr89.map NumV.ref) PRE_first_tail_x6_r0_body.kd89.big
    PRE_first_tail_x6_r0_body.kd89.region PRE_first_tail_x6_r0_body.kd89.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws89 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs89 : List SymE := PRE_first_tail_x6_r0_body.nr89.map fun r => (nth? PRE_first_tail_x6_r0_body.S863.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta89 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws89 PRE_first_tail_x6_r0_body.crs89
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB89 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab89 : PRE_first_tail_x6_r0_body.S864.tab = PRE_first_tail_x6_r0_body.S862.tab ++ PRE_first_tail_x6_r0_body.cws89.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace89 : PRE_first_tail_x6_r0_body.s864.trace = PRE_first_tail_x6_r0_body.s862.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext89 : PRE_first_tail_x6_r0_body.s864.next = 2744412
kernel_rfl PRE_first_tail_x6_r0_body.ccounters89 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s864.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s864.ffi).mlx.nnext) = (19948, 17044)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue89 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s863.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s864.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa89.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp89 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s864.ffi).mlx.tokens.all (bSN 3859) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean89 : Conv.cleanListB 19948 131072 (fun r => Nat.ble 79792 r) PRE_first_tail_x6_r0_body.s864
    (PRE_first_tail_x6_r0_body.wrB89 ++ (List.range 1).map (2744411 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs89 : bigsOutB 19948 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s864.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK89
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl89`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl89 : List Nat := [2665, 2673467, 2744411]
def PRE_first_tail_x6_r0_body.clo89 : List Nat := []
def PRE_first_tail_x6_r0_body.cln89 : List Nat := []
def PRE_first_tail_x6_r0_body.cli89 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap89 : PRE_first_tail_x6_r0_body.s864.heap = Stage.setAll PRE_first_tail_x6_r0_body.s862.heap (PRE_first_tail_x6_r0_body.cl89.filterMap fun a => (PRE_first_tail_x6_r0_body.s864.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe89 : Nat.ble PRE_first_tail_x6_r0_body.s862.next PRE_first_tail_x6_r0_body.s864.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP89 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s862 PRE_first_tail_x6_r0_body.s864 PRE_first_tail_x6_r0_body.cl89 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp89 : Conv.suppListB PRE_first_tail_x6_r0_body.s864 3859 PRE_first_tail_x6_r0_body.cl89 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound89 : Conv.boundListB PRE_first_tail_x6_r0_body.s864 PRE_first_tail_x6_r0_body.cl89 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK89 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s864.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln89.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s864.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK89 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s864.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo89.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s864.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK89 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s864.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli89.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s864.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst89 : Conv.sstListB 3859 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s864.ffi).mlx PRE_first_tail_x6_r0_body.cln89 PRE_first_tail_x6_r0_body.clo89 PRE_first_tail_x6_r0_body.cli89 = true

end Host.Load.Run.Tpl
end

section -- SiteCl89
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA89 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s864.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo89.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s864.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd89 : (PRE_first_tail_x6_r0_body.clo89 ++ PRE_first_tail_x6_r0_body.cln89 ++ PRE_first_tail_x6_r0_body.cli89).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle89 : Conv.Cnt.leB (⟨19948, 17044, 2744411, 3859⟩ : Conv.Cnt) (⟨19948, 17044, 2744412, 3859⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck89 : Conv.ncleanListB (⟨19948, 17044, 2744412, 3859⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s864.ffi).mlx PRE_first_tail_x6_r0_body.clo89 PRE_first_tail_x6_r0_body.cln89 PRE_first_tail_x6_r0_body.cli89 = true
theorem PRE_first_tail_x6_r0_body.cncl89 (h : Conv.NClean (⟨19948, 17044, 2744411, 3859⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx) : Conv.NClean (⟨19948, 17044, 2744412, 3859⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s864.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle89 PRE_first_tail_x6_r0_body.ckA89 PRE_first_tail_x6_r0_body.cobjsK89 PRE_first_tail_x6_r0_body.cnodesK89 PRE_first_tail_x6_r0_body.citemsK89 PRE_first_tail_x6_r0_body.cbd89 PRE_first_tail_x6_r0_body.cck89

end Host.Load.Run.Tpl
end

section -- SiteS89
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 89 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc89 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P89 : LoadP := PRE_first_tail_x6_r0_body.Pc89.raise 17044
kernel_rfl PRE_first_tail_x6_r0_body.craise89 : Nat.ble PRE_first_tail_x6_r0_body.Pc89.N0 17044 = true
theorem PRE_first_tail_x6_r0_body.raised89 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc89 PRE_first_tail_x6_r0_body.P89 :=
  .inr ⟨17044, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise89, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_89 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s864.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_89 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s863.ffi)
def PRE_first_tail_x6_r0_body.khinv89 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv89 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS89 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS89 : List Nat := List.range' 17044 0
def PRE_first_tail_x6_r0_body.ciS89 : List Nat := [] ++ List.range' 17044 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh089 : PRE_first_tail_x6_r0_body.kd89.nh0 = PRE_first_tail_x6_r0_body.cx0_89.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh189 : PRE_first_tail_x6_r0_body.kd89.nh1 = PRE_first_tail_x6_r0_body.cx1_89.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn089 : PRE_first_tail_x6_r0_body.kd89.nn0 = PRE_first_tail_x6_r0_body.cx0_89.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn189 : PRE_first_tail_x6_r0_body.kd89.nn1 = PRE_first_tail_x6_r0_body.cx1_89.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo89 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P89.lo && Nat.ble PRE_first_tail_x6_r0_body.P89.lo PRE_first_tail_x6_r0_body.cx0_89.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P89.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P89.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt89 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_89.mlx.next PRE_first_tail_x6_r0_body.cx1_89.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_89.mlx.nnext PRE_first_tail_x6_r0_body.cx1_89.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband89 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P89.NL && Nat.ble PRE_first_tail_x6_r0_body.P89.NL PRE_first_tail_x6_r0_body.P89.N0 && Nat.ble PRE_first_tail_x6_r0_body.P89.N0 PRE_first_tail_x6_r0_body.cx0_89.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow89 : PRE_first_tail_x6_r0_body.kd89.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren89 : checkRenG PRE_first_tail_x6_r0_body.kd89.hnd PRE_first_tail_x6_r0_body.khinv89 (phB PRE_first_tail_x6_r0_body.cx0_89.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband89 : PRE_first_tail_x6_r0_body.kd89.checkBand PRE_first_tail_x6_r0_body.P89.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos89 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd89.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren89 : checkRenG PRE_first_tail_x6_r0_body.kd89.node PRE_first_tail_x6_r0_body.kninv89 (pnB PRE_first_tail_x6_r0_body.cx0_89.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow89 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd89.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P89.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd89.nodeF j) PRE_first_tail_x6_r0_body.cx1_89.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a89 : PRE_first_tail_x6_r0_body.cx0_89.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b89 : PRE_first_tail_x6_r0_body.cx0_89.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok189 : PRE_first_tail_x6_r0_body.cx1_89.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend89 : PRE_first_tail_x6_r0_body.cx1_89.mlx.pending = PRE_first_tail_x6_r0_body.cx0_89.mlx.pending.map PRE_first_tail_x6_r0_body.kappa89.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh89 : PRE_first_tail_x6_r0_body.cx1_89.mlx.errh = PRE_first_tail_x6_r0_body.cx0_89.mlx.errh.map PRE_first_tail_x6_r0_body.kappa89.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles89 : PRE_first_tail_x6_r0_body.cx1_89.mlx.files = PRE_first_tail_x6_r0_body.cx0_89.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch89 : PRE_first_tail_x6_r0_body.cx1_89.mlx.arch = PRE_first_tail_x6_r0_body.cx0_89.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes89 : PRE_first_tail_x6_r0_body.cx1_89.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_89.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired89 : PRE_first_tail_x6_r0_body.cx1_89.mlx.wired = PRE_first_tail_x6_r0_body.cx0_89.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost89 : PRE_first_tail_x6_r0_body.cx1_89.host = PRE_first_tail_x6_r0_body.cx0_89.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd89`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn089 : PRE_first_tail_x6_r0_body.kd89.n0 = 2744412
kernel_rfl PRE_first_tail_x6_r0_body.ckn189 : PRE_first_tail_x6_r0_body.kd89.n1 = 2744431
kernel_rfl PRE_first_tail_x6_r0_body.ckheap89 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd89.heap).all (fun x => Nat.ble 2744411 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl89 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd89.heap.get (2744411 + j) = nth? PRE_first_tail_x6_r0_body.pl89 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja89 : Nat.ble 2744411 2744411 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn89 : Nat.ble 3859 3859 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD89 : Nat.ble 2744411 PRE_first_tail_x6_r0_body.kd89.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn89 : Nat.ble 19948 PRE_first_tail_x6_r0_body.kd89.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn89 : Nat.ble 17044 PRE_first_tail_x6_r0_body.kd89.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb89 : Nat.ble 19948 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap89 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd89.heap).all (Nat.ble (⟨19948, 17044, 2744411, 3859⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd89 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd89.hnd).all (Nat.ble (⟨19948, 17044, 2744411, 3859⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode89 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd89.node).all (Nat.ble (⟨19948, 17044, 2744411, 3859⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix89 : Conv.FixOld (⟨19948, 17044, 2744411, 3859⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa89 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja89) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn89) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD89) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn89) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn89) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb89) PRE_first_tail_x6_r0_body.fheap89 PRE_first_tail_x6_r0_body.fhnd89 PRE_first_tail_x6_r0_body.fnode89
kernel_rfl PRE_first_tail_x6_r0_body.fcxn89 : (⟨19948, 17044, 2744411, 3859⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn89 : (⟨19948, 17044, 2744411, 3859⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle089 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_89.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_89.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk89 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd89.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A89 : PRE_first_tail_x6_r0_body.cx1_89.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS89.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_89.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O89 : PRE_first_tail_x6_r0_body.cx1_89.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS89.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_89.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N89 : PRE_first_tail_x6_r0_body.cx1_89.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS89.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_89.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I89 : PRE_first_tail_x6_r0_body.cx1_89.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS89.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_89.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd89 : (PRE_first_tail_x6_r0_body.clo89 ++ PRE_first_tail_x6_r0_body.cln89 ++ PRE_first_tail_x6_r0_body.cli89 ++ PRE_first_tail_x6_r0_body.cwS89 ++ PRE_first_tail_x6_r0_body.cnS89 ++ PRE_first_tail_x6_r0_body.ciS89).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW89 : PRE_first_tail_x6_r0_body.cwS89.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo89.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI89 : PRE_first_tail_x6_r0_body.ciS89.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli89.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN89 : PRE_first_tail_x6_r0_body.cnS89.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF89 : PRE_first_tail_x6_r0_body.cln89.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh89 : PRE_first_tail_x6_r0_body.clo89.all (handleOK PRE_first_tail_x6_r0_body.kappa89 PRE_first_tail_x6_r0_body.P89.lo PRE_first_tail_x6_r0_body.cx0_89.mlx PRE_first_tail_x6_r0_body.cx1_89.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo89 : PRE_first_tail_x6_r0_body.clo89.map (fun h => PRE_first_tail_x6_r0_body.cx1_89.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa89.handle h)) = PRE_first_tail_x6_r0_body.clo89.map (fun h => (PRE_first_tail_x6_r0_body.cx0_89.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa89.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok89 : PRE_first_tail_x6_r0_body.clo89.all (objOK PRE_first_tail_x6_r0_body.kappa89 PRE_first_tail_x6_r0_body.P89.NL PRE_first_tail_x6_r0_body.cx0_89.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd89 : PRE_first_tail_x6_r0_body.cln89.all (nodeOKF PRE_first_tail_x6_r0_body.kappa89 PRE_first_tail_x6_r0_body.P89 PRE_first_tail_x6_r0_body.cx0_89.mlx PRE_first_tail_x6_r0_body.cx1_89.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp89 : ((PRE_first_tail_x6_r0_body.cln89.filter (fullB PRE_first_tail_x6_r0_body.P89))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_89.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa89.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln89.filter (fullB PRE_first_tail_x6_r0_body.P89))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_89.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa89.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI89 : incrB PRE_first_tail_x6_r0_body.kd89.nodeF (List.range' 17044 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK89 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd89.node).all (fun k => Nat.ble 17044 k && Nat.blt k 17044) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL89 : (PRE_first_tail_x6_r0_body.cln89.filter (Nat.ble PRE_first_tail_x6_r0_body.P89.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd89.nodeF i) && (Nat.blt i 17044 || Nat.ble PRE_first_tail_x6_r0_body.kd89.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord89 : (PRE_first_tail_x6_r0_body.cln89.filter (Nat.ble PRE_first_tail_x6_r0_body.P89.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd89.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd89.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd89.nodeF j) (PRE_first_tail_x6_r0_body.kd89.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow89 PRE_first_tail_x6_r0_body.cnn189 PRE_first_tail_x6_r0_body.fnordI89 PRE_first_tail_x6_r0_body.fnordK89 PRE_first_tail_x6_r0_body.fnordL89
kernel_rfl PRE_first_tail_x6_r0_body.fi89 : PRE_first_tail_x6_r0_body.cli89.all (pnB PRE_first_tail_x6_r0_body.cx0_89.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii89 : PRE_first_tail_x6_r0_body.cli89.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_89.mlx.items.get (PRE_first_tail_x6_r0_body.kappa89.node k) = (PRE_first_tail_x6_r0_body.cx0_89.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa89.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot89 (clean : Conv.NClean (⟨19948, 17044, 2744411, 3859⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P89.NL) (cl : SSt (· < 3859) PRE_first_tail_x6_r0_body.cx0_89.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P89 3859 PRE_first_tail_x6_r0_body.kappa89 PRE_first_tail_x6_r0_body.kd89 PRE_first_tail_x6_r0_body.khinv89 PRE_first_tail_x6_r0_body.kninv89 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx PRE_first_tail_x6_r0_body.cx0_89.mlx PRE_first_tail_x6_r0_body.cx1_89.mlx (⟨19948, 17044, 2744411, 3859⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo89 PRE_first_tail_x6_r0_body.cln89 PRE_first_tail_x6_r0_body.cli89 PRE_first_tail_x6_r0_body.cwS89 PRE_first_tail_x6_r0_body.cnS89 PRE_first_tail_x6_r0_body.ciS89 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh089, PRE_first_tail_x6_r0_body.cnh189, PRE_first_tail_x6_r0_body.cnn089, PRE_first_tail_x6_r0_body.cnn189, PRE_first_tail_x6_r0_body.cplo89, PRE_first_tail_x6_r0_body.ccnt89, PRE_first_tail_x6_r0_body.cnband89, PRE_first_tail_x6_r0_body.chbelow89, PRE_first_tail_x6_r0_body.chren89, PRE_first_tail_x6_r0_body.cband89, PRE_first_tail_x6_r0_body.cnh1pos89, PRE_first_tail_x6_r0_body.cnren89, PRE_first_tail_x6_r0_body.cnlow89, PRE_first_tail_x6_r0_body.cabs0a89, PRE_first_tail_x6_r0_body.cabs0b89, PRE_first_tail_x6_r0_body.ctok189, PRE_first_tail_x6_r0_body.cpend89, PRE_first_tail_x6_r0_body.cerrh89, PRE_first_tail_x6_r0_body.cfiles89, PRE_first_tail_x6_r0_body.carch89, PRE_first_tail_x6_r0_body.csizes89, PRE_first_tail_x6_r0_body.cwired89, PRE_first_tail_x6_r0_body.cfix89, clean, PRE_first_tail_x6_r0_body.fcxn89, PRE_first_tail_x6_r0_body.fcnn89, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle089, PRE_first_tail_x6_r0_body.fnk89, PRE_first_tail_x6_r0_body.ckA89, PRE_first_tail_x6_r0_body.cobjsK89, PRE_first_tail_x6_r0_body.cnodesK89, PRE_first_tail_x6_r0_body.citemsK89, PRE_first_tail_x6_r0_body.f1A89, PRE_first_tail_x6_r0_body.f1O89, PRE_first_tail_x6_r0_body.f1N89, PRE_first_tail_x6_r0_body.f1I89, PRE_first_tail_x6_r0_body.fbd89, PRE_first_tail_x6_r0_body.fincW89, PRE_first_tail_x6_r0_body.fincI89, PRE_first_tail_x6_r0_body.fincN89, PRE_first_tail_x6_r0_body.flnF89, PRE_first_tail_x6_r0_body.fh89, PRE_first_tail_x6_r0_body.fo89, PRE_first_tail_x6_r0_body.fok89, PRE_first_tail_x6_r0_body.fnd89, PRE_first_tail_x6_r0_body.fp89, PRE_first_tail_x6_r0_body.fnord89, PRE_first_tail_x6_r0_body.fi89, PRE_first_tail_x6_r0_body.fii89⟩
theorem PRE_first_tail_x6_r0_body.cnshift89 (clean : Conv.NClean (⟨19948, 17044, 2744411, 3859⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P89.NL) (cl : SSt (· < 3859) PRE_first_tail_x6_r0_body.cx0_89.mlx) : NShift PRE_first_tail_x6_r0_body.P89 3859 PRE_first_tail_x6_r0_body.kappa89 PRE_first_tail_x6_r0_body.cx0_89 PRE_first_tail_x6_r0_body.cx1_89 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot89 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost89 (compact_a_eq PRE_first_tail_x6_r0_body.ckn089 PRE_first_tail_x6_r0_body.ckn189 PRE_first_tail_x6_r0_body.ckheap89 PRE_first_tail_x6_r0_body.ckpl89)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_89 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s862.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_89 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s862.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_89 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s862.ffi) = some PRE_first_tail_x6_r0_body.fxC_89
kernel_rfl PRE_first_tail_x6_r0_body.okrC_89 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s862.ffi) = some PRE_first_tail_x6_r0_body.krC_89
noncomputable def PRE_first_tail_x6_r0_body.fx0_89 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s864.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_89 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s864.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_89 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s864.ffi) = some PRE_first_tail_x6_r0_body.fx0_89
kernel_rfl PRE_first_tail_x6_r0_body.okr0_89 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s864.ffi) = some PRE_first_tail_x6_r0_body.kr0_89
noncomputable def PRE_first_tail_x6_r0_body.fx1_89 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s863.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_89 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s863.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_89 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s863.ffi) = some PRE_first_tail_x6_r0_body.fx1_89
kernel_rfl PRE_first_tail_x6_r0_body.okr1_89 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s863.ffi) = some PRE_first_tail_x6_r0_body.kr1_89
kernel_rfl PRE_first_tail_x6_r0_body.ff089 : PRE_first_tail_x6_r0_body.fx0_89 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_89 (PRE_first_tail_x6_r0_body.clo89.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_89.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff189 : PRE_first_tail_x6_r0_body.fx1_89 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_89 (PRE_first_tail_x6_r0_body.cwS89.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_89.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck89 : freedLB PRE_first_tail_x6_r0_body.kappa89 PRE_first_tail_x6_r0_body.cx0_89.mlx PRE_first_tail_x6_r0_body.fx0_89 PRE_first_tail_x6_r0_body.fx1_89 PRE_first_tail_x6_r0_body.clo89 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf089 : PRE_first_tail_x6_r0_body.kr0_89.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_89.flags (PRE_first_tail_x6_r0_body.clo89.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_89.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt089 : PRE_first_tail_x6_r0_body.kr0_89.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_89.targs (PRE_first_tail_x6_r0_body.clo89.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_89.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf189 : PRE_first_tail_x6_r0_body.kr1_89.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_89.flags (PRE_first_tail_x6_r0_body.cwS89.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_89.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt189 : PRE_first_tail_x6_r0_body.kr1_89.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_89.targs (PRE_first_tail_x6_r0_body.cwS89.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_89.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck89 : krecLB PRE_first_tail_x6_r0_body.kappa89 3859 PRE_first_tail_x6_r0_body.cx0_89.mlx PRE_first_tail_x6_r0_body.kr0_89 PRE_first_tail_x6_r0_body.kr1_89 PRE_first_tail_x6_r0_body.clo89 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn89 : Nat.ble 3859 3859 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge89 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s863.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s864.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR89 : pendRegB PRE_first_tail_x6_r0_body.kappa89 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s864.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe89 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s864.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s863.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift89 (clean : Conv.NClean (⟨19948, 17044, 2744411, 3859⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P89.NL) (cl : SSt (· < 3859) PRE_first_tail_x6_r0_body.cx0_89.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_89.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_89.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_89.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s862.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_89.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19948, 17044, 2744411, 3859⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P89 3859 PRE_first_tail_x6_r0_body.kappa89 PRE_first_tail_x6_r0_body.s864.ffi PRE_first_tail_x6_r0_body.s863.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift89 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue89, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp89 t ht),
    PRE_first_tail_x6_r0_body.cbridge89,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s864.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s863.ffi) (PRE_first_tail_x6_r0_body.cfoot89 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_89 PRE_first_tail_x6_r0_body.ofx1_89 hobjC PRE_first_tail_x6_r0_body.ff089 PRE_first_tail_x6_r0_body.ff189 PRE_first_tail_x6_r0_body.ffck89,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s864.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s863.ffi) (PRE_first_tail_x6_r0_body.cfoot89 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_89 PRE_first_tail_x6_r0_body.okr1_89 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn89) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf089 PRE_first_tail_x6_r0_body.fkt089 PRE_first_tail_x6_r0_body.fkf189 PRE_first_tail_x6_r0_body.fkt189 PRE_first_tail_x6_r0_body.fkck89,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh089 PRE_first_tail_x6_r0_body.cnh189 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe89) PRE_first_tail_x6_r0_body.cpendR89⟩

end Host.Load.Run.Tpl
end

section -- st89/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st89 0
host_stream_state PRE_first_tail_x6_r0_body.st89 1
host_stream_state PRE_first_tail_x6_r0_body.st89 2
end Host.Load.Run.Tpl
end

section -- Site89
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 89 of chain `PRE_first_tail_x6_r0_body`: `plan__g89__g90` (`plan`), the call state `PRE_first_tail_x6_r0_body.s862`, the merged state `PRE_first_tail_x6_r0_body.s863`,
the site template `PRE_first_tail_x6_r0_body.st89` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s864`: the merge.
The footprint's facts are in `SiteF89`, the compaction's in `SiteC89`, `SiteK89`, `SiteNa89`, `SiteNb89`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso89 : PRE_first_tail_x6_r0_body.st89.s0 = { PRE_first_tail_x6_r0_body.s862 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs89 : List Frame := PRE_first_tail_x6_r0_body.s862.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_89 : PRE_first_tail_x6_r0_body.S862.tab.length = 3859
kernel_rfl PRE_first_tail_x6_r0_body.tab0_89 : PRE_first_tail_x6_r0_body.st89.S0.tab = PRE_first_tail_x6_r0_body.S862.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws89 : List Nat := [2498, 2499, 2500, 2501, 2502, 2503, 2504, 2505, 2506]
kernel_rfl PRE_first_tail_x6_r0_body.fresh89 : (PRE_first_tail_x6_r0_body.S862.tab.all fun e => PRE_first_tail_x6_r0_body.ws89.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S862.oracle.all fun q => PRE_first_tail_x6_r0_body.ws89.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab89 : PRE_first_tail_x6_r0_body.S863.tab = PRE_first_tail_x6_r0_body.S862.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws89
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen89 : PRE_first_tail_x6_r0_body.st89.S2.tab.length - PRE_first_tail_x6_r0_body.st89.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged89`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap89 : PRE_first_tail_x6_r0_body.s863.heap = PRE_first_tail_x6_r0_body.st89.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext89 : PRE_first_tail_x6_r0_body.s863.next = PRE_first_tail_x6_r0_body.st89.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl89 : PRE_first_tail_x6_r0_body.s863.ctl = PRE_first_tail_x6_r0_body.st89.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack89 : PRE_first_tail_x6_r0_body.s863.stack = PRE_first_tail_x6_r0_body.st89.s2.stack ++ PRE_first_tail_x6_r0_body.s862.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs89 : PRE_first_tail_x6_r0_body.s863.jobs = PRE_first_tail_x6_r0_body.st89.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi89 : PRE_first_tail_x6_r0_body.s863.ffi = PRE_first_tail_x6_r0_body.st89.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace89 : PRE_first_tail_x6_r0_body.s863.trace = PRE_first_tail_x6_r0_body.st89.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores89 : PRE_first_tail_x6_r0_body.s863.stores = PRE_first_tail_x6_r0_body.st89.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD89
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 89 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived89 : PRE_first_tail_x6_r0_body.nr89.map (fun r => nth? PRE_first_tail_x6_r0_body.st89.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo89 : PRE_first_tail_x6_r0_body.nr89.all (Nat.ble 3859) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj89 : PRE_first_tail_x6_r0_body.cws89.all (fun c => !PRE_first_tail_x6_r0_body.ws89.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ89 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws89 PRE_first_tail_x6_r0_body.crs89 PRE_first_tail_x6_r0_body.ws89

end Host.Load.Run.Tpl
end

section -- st89/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st89`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st89.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st89.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st89.s2.heap PRE_first_tail_x6_r0_body.st89.wrR ++ freshOf PRE_first_tail_x6_r0_body.st89.s2.heap PRE_first_tail_x6_r0_body.st89.s0.next PRE_first_tail_x6_r0_body.st89.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st89.wr : List Nat := PRE_first_tail_x6_r0_body.st89.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st89.heapFoot : PRE_first_tail_x6_r0_body.st89.s2.heap = setAll PRE_first_tail_x6_r0_body.st89.s0.heap PRE_first_tail_x6_r0_body.st89.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st89.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st89.s0.next PRE_first_tail_x6_r0_body.st89.s2.next = true
theorem PRE_first_tail_x6_r0_body.st89.grows : PRE_first_tail_x6_r0_body.st89.s0.next ≤ PRE_first_tail_x6_r0_body.st89.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st89.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st89.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st89.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st89.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st89.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st89.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st89.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st89.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st89.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st89.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st89.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st89.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st89.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st89.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st89.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st89.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st89.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st89.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st89.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st89.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st89.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st89.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st89.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st89.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st89.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st89.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st89.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st89.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st89.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st89.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st89.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st89.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF89
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 89 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB89 : nodupT PRE_first_tail_x6_r0_body.st89.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup89 : PRE_first_tail_x6_r0_body.st89.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB89).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB89 : PRE_first_tail_x6_r0_body.st89.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound89 : ∀ b ∈ PRE_first_tail_x6_r0_body.st89.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB89 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr89 := PRE_first_tail_x6_r0_body.st89.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq89 : PRE_first_tail_x6_r0_body.st89.s2.trace = PRE_first_tail_x6_r0_body.trFr89 ++ PRE_first_tail_x6_r0_body.st89.s0.trace
theorem PRE_first_tail_x6_r0_body.trace89 : ∃ fr, PRE_first_tail_x6_r0_body.st89.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st89.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq89⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide89 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB89 : (PRE_first_tail_x6_r0_body.wide89.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st89.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix89 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide89, WFix Map.id (Present PRE_first_tail_x6_r0_body.st89.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB89 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL89
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 89 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s863`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO89 : PRE_first_tail_x6_r0_body.st89.S0.oracle = PRE_first_tail_x6_r0_body.st89.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B89 : PRE_first_tail_x6_r0_body.st89.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st89.s0.next || (PRE_first_tail_x6_r0_body.st89.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot89 : Conv.StageFoot PRE_first_tail_x6_r0_body.st89.wr PRE_first_tail_x6_r0_body.st89.s0 PRE_first_tail_x6_r0_body.st89.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st89.heapFoot PRE_first_tail_x6_r0_body.wrNodup89 PRE_first_tail_x6_r0_body.wrBound89 PRE_first_tail_x6_r0_body.wr0B89 PRE_first_tail_x6_r0_body.st89.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged89 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st89.F.S → PRE_first_tail_x6_r0_body.st89.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st89.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st89.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs89 PRE_first_tail_x6_r0_body.st89.wr PRE_first_tail_x6_r0_body.s862 PRE_first_tail_x6_r0_body.st89.s2 PRE_first_tail_x6_r0_body.st89.s0
      PRE_first_tail_x6_r0_body.st89.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st89.F FR W stk M ν K PRE_first_tail_x6_r0_body.s863 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso89 PRE_first_tail_x6_r0_body.stFoot89 PRE_first_tail_x6_r0_body.wrNodup89 PRE_first_tail_x6_r0_body.wrBound89 PRE_first_tail_x6_r0_body.trace89 PRE_first_tail_x6_r0_body.mheap89
    PRE_first_tail_x6_r0_body.mnext89 PRE_first_tail_x6_r0_body.mctl89 PRE_first_tail_x6_r0_body.mstack89 PRE_first_tail_x6_r0_body.mjobs89 PRE_first_tail_x6_r0_body.mffi89 PRE_first_tail_x6_r0_body.mtrace89 PRE_first_tail_x6_r0_body.mstores89 h

def PRE_first_tail_x6_r0_body.arrEl89_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE89_2665 : arrOf PRE_first_tail_x6_r0_body.s863 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl89_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA89_2665 : isArrB PRE_first_tail_x6_r0_body.s863 2665 = true
theorem PRE_first_tail_x6_r0_body.arr89_2665 : ∃ o, PRE_first_tail_x6_r0_body.s863.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl89_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE89_2665 PRE_first_tail_x6_r0_body.arrA89_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN89_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl89_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR89_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl89_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN89_2665

def PRE_first_tail_x6_r0_body.arrEl89_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE89_2673467 : arrOf PRE_first_tail_x6_r0_body.s863 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl89_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA89_2673467 : isArrB PRE_first_tail_x6_r0_body.s863 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr89_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s863.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl89_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE89_2673467 PRE_first_tail_x6_r0_body.arrA89_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN89_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl89_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR89_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl89_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN89_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k89 : isArrB PRE_first_tail_x6_r0_body.s863 4910 = false
theorem PRE_first_tail_x6_r0_body.keep89 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s863 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k89 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr89_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl89_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ89
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 89 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s862`, the merged
state `PRE_first_tail_x6_r0_body.s863`, the canonical state `PRE_first_tail_x6_r0_body.s864`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl89 : PRE_first_tail_x6_r0_body.pl89.all (Nat.ble PRE_first_tail_x6_r0_body.s862.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd89 : nodupT PRE_first_tail_x6_r0_body.pl89 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn189 : Nat.ble PRE_first_tail_x6_r0_body.s862.next 2744431 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst89 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s862.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn89 : PRE_first_tail_x6_r0_body.s864.next = PRE_first_tail_x6_r0_body.s862.next + PRE_first_tail_x6_r0_body.pl89.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn89 : PRE_first_tail_x6_r0_body.s863.next = 2744431
kernel_rfl PRE_first_tail_x6_r0_body.zgrow89 : Nat.ble PRE_first_tail_x6_r0_body.s864.next PRE_first_tail_x6_r0_body.s863.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh89 : PRE_first_tail_x6_r0_body.S862.tab.all (fun e => PRE_first_tail_x6_r0_body.cws89.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd89 : nodupT PRE_first_tail_x6_r0_body.cws89 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi89 : PRE_first_tail_x6_r0_body.nr89.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S863.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt89 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s862.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg89_2665 : PRE_first_tail_x6_r0_body.s864.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s864 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk89_2665 : (objOf PRE_first_tail_x6_r0_body.s864 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm89_2665 : PRE_first_tail_x6_r0_body.s863.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa89.obj (objOf PRE_first_tail_x6_r0_body.s864 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s863 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg89_2673467 : PRE_first_tail_x6_r0_body.s864.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s864 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk89_2673467 : (objOf PRE_first_tail_x6_r0_body.s864 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm89_2673467 : PRE_first_tail_x6_r0_body.s863.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa89.obj (objOf PRE_first_tail_x6_r0_body.s864 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s863 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw89_4910 : (PRE_first_tail_x6_r0_body.s864.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw89_2673472 : (PRE_first_tail_x6_r0_body.s864.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw89_2673473 : (PRE_first_tail_x6_r0_body.s864.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd89 : PRE_first_tail_x6_r0_body.cl89.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr89 : PRE_first_tail_x6_r0_body.st89.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s862.next || PRE_first_tail_x6_r0_body.cl89.contains b) = true
def PRE_first_tail_x6_r0_body.zl89 : List Nat := PRE_first_tail_x6_r0_body.cl89.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE89 : PRE_first_tail_x6_r0_body.zl89.map (fun a => PRE_first_tail_x6_r0_body.s863.heap.get (PRE_first_tail_x6_r0_body.kappa89.a a)) = PRE_first_tail_x6_r0_body.zl89.map (fun a => (PRE_first_tail_x6_r0_body.s864.heap.get a).map PRE_first_tail_x6_r0_body.kappa89.hobj)
theorem PRE_first_tail_x6_r0_body.zimg89 : HeapImg PRE_first_tail_x6_r0_body.kappa89 PRE_first_tail_x6_r0_body.s864 PRE_first_tail_x6_r0_body.s863 PRE_first_tail_x6_r0_body.zl89 := PRE_first_tail_x6_r0_body.zimgE89
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl89 : PRE_first_tail_x6_r0_body.s863.ctl = PRE_first_tail_x6_r0_body.kappa89.ctl PRE_first_tail_x6_r0_body.s864.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack89 : PRE_first_tail_x6_r0_body.s863.stack = PRE_first_tail_x6_r0_body.s864.stack.map PRE_first_tail_x6_r0_body.kappa89.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs89 : PRE_first_tail_x6_r0_body.s863.jobs = PRE_first_tail_x6_r0_body.s864.jobs.map PRE_first_tail_x6_r0_body.kappa89.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores89 : PRE_first_tail_x6_r0_body.s863.stores = PRE_first_tail_x6_r0_body.kappa89.stores PRE_first_tail_x6_r0_body.s864.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots89 : checkRootsSupp PRE_first_tail_x6_r0_body.s864 3859 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC89 : PRE_first_tail_x6_r0_body.S862.tab.length + PRE_first_tail_x6_r0_body.cws89.length = 3859
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap89 : PRE_first_tail_x6_r0_body.kappa89 = Conv.Map.compact PRE_first_tail_x6_r0_body.s862.next 2744431 PRE_first_tail_x6_r0_body.S862.tab.length PRE_first_tail_x6_r0_body.pl89 (PRE_first_tail_x6_r0_body.nr89.map NumV.ref) PRE_first_tail_x6_r0_body.kd89.big
  PRE_first_tail_x6_r0_body.kd89.region PRE_first_tail_x6_r0_body.kd89.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin89 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s864.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc89 : Conv.jcleanListB (⟨19948, 17044, 2744412, 3859⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s864 PRE_first_tail_x6_r0_body.cl89 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB89 : noBigRootsP (fun i => !Conv.oldBigB (⟨19948, 17044, 2744412, 3859⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s864.trace PRE_first_tail_x6_r0_body.s864 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm89 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 17044 = true
theorem PRE_first_tail_x6_r0_body.cjcl89 (h : Conv.JClean (⟨19948, 17044, 2744411, 3859⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s862) : Conv.JClean (⟨19948, 17044, 2744412, 3859⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s864 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle89)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap89 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd89 a ha)) PRE_first_tail_x6_r0_body.zjc89

end Host.Load.Run.Tpl
end

section -- st89/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st89.bodyLast from PRE_first_tail_x6_r0_body.st89.s1 to PRE_first_tail_x6_r0_body.st89.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st89.F PRE_first_tail_x6_r0_body.st89.s1).run PRE_first_tail_x6_r0_body.st89.S1 = some (PRE_first_tail_x6_r0_body.st89.s2, PRE_first_tail_x6_r0_body.st89.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st89.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st89.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st89.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st89.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st89/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st89.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st89.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st89.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st89.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st89.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st89.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st89.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st89.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st89.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st89.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st89.s0 PRE_first_tail_x6_r0_body.st89.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st89.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st89.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st89.s1 PRE_first_tail_x6_r0_body.st89.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st89/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st89.bodyK0F from PRE_first_tail_x6_r0_body.st89.s0 to PRE_first_tail_x6_r0_body.st89.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st89.F (PRE_first_tail_x6_r0_body.st89.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st89.ks 0).getD 0) PRE_first_tail_x6_r0_body.st89.s0 PRE_first_tail_x6_r0_body.st89.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st89.s1, PRE_first_tail_x6_r0_body.st89.S1)
theorem PRE_first_tail_x6_r0_body.st89.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st89.F (PRE_first_tail_x6_r0_body.st89.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st89.ks 0).getD 0) PRE_first_tail_x6_r0_body.st89.s0 PRE_first_tail_x6_r0_body.st89.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st89.s1, PRE_first_tail_x6_r0_body.st89.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st89.bodyOkLN_ok PRE_first_tail_x6_r0_body.st89.bodyK0F
end Host.Load.Run.Tpl
end

section -- st89/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st89.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st89.F (PRE_first_tail_x6_r0_body.st89.bodyOkL bytes rows) 206 PRE_first_tail_x6_r0_body.st89.s0 PRE_first_tail_x6_r0_body.st89.S0 = some (PRE_first_tail_x6_r0_body.st89.s1, PRE_first_tail_x6_r0_body.st89.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st89.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st89.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st89.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st89.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st89.F (PRE_first_tail_x6_r0_body.st89.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st89.s0
  S0 := PRE_first_tail_x6_r0_body.st89.S0
  s1 := PRE_first_tail_x6_r0_body.st89.s1
  S1 := PRE_first_tail_x6_r0_body.st89.S1
  s2 := PRE_first_tail_x6_r0_body.st89.s2
  S2 := PRE_first_tail_x6_r0_body.st89.S2
  n := 206
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st89.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st89.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st89.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st89.bodyHalt
  last := PRE_first_tail_x6_r0_body.st89.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st89.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC90
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 90 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s881` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa90` into the merged state
`PRE_first_tail_x6_r0_body.s880`. -/

def PRE_first_tail_x6_r0_body.pl90 : List Nat := [2746999, 2746174, 2747005, 2747001, 2746176, 2747007]
def PRE_first_tail_x6_r0_body.nr90 : List Nat := [3962, 3961, 3937, 3945, 3950, 3955, 3960, 3934, 3935, 3936, 3943, 3944, 3932, 3939, 3940, 3941, 3942, 3938]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd90 : RData :=
  ⟨2745893, 2747042, Stage.setAll PTrie.nil [(2745887, 2746999), (2745888, 2746174), (2745889, 2747005), (2745890, 2747001), (2745891, 2746176), (2745892, 2747007)], Stage.setAll PTrie.nil [(19982, 20008), (19983, 19986), (19984, 20009)],
   19985, 20010, 17090, 17090, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(3932, .ref 3962), (3933, .ref 3961), (3934, .ref 3937), (3935, .ref 3945), (3936, .ref 3950), (3937, .ref 3955), (3938, .ref 3960), (3939, .ref 3934), (3940, .ref 3935), (3941, .ref 3936), (3942, .ref 3943), (3943, .ref 3944), (3944, .ref 3932), (3945, .ref 3939), (3946, .ref 3940), (3947, .ref 3941), (3948, .ref 3942), (3949, .ref 3938)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa90 : Map :=
  Conv.Map.compact 2745887 2747042 3932 PRE_first_tail_x6_r0_body.pl90 (PRE_first_tail_x6_r0_body.nr90.map NumV.ref) PRE_first_tail_x6_r0_body.kd90.big
    PRE_first_tail_x6_r0_body.kd90.region PRE_first_tail_x6_r0_body.kd90.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws90 : List Nat := [2538, 2539, 2540, 2541, 2542, 2543, 2544, 2545, 2546, 2547, 2548, 2549, 2550, 2551, 2552, 2553, 2554, 2555]
noncomputable def PRE_first_tail_x6_r0_body.crs90 : List SymE := PRE_first_tail_x6_r0_body.nr90.map fun r => (nth? PRE_first_tail_x6_r0_body.S880.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta90 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws90 PRE_first_tail_x6_r0_body.crs90
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB90 : List Nat := [2665, 2672527, 2673467, 2745061, 2745606, 2745862]

kernel_rfl PRE_first_tail_x6_r0_body.ctab90 : PRE_first_tail_x6_r0_body.S881.tab = PRE_first_tail_x6_r0_body.S879.tab ++ PRE_first_tail_x6_r0_body.cws90.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace90 : PRE_first_tail_x6_r0_body.s881.trace = PRE_first_tail_x6_r0_body.s879.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext90 : PRE_first_tail_x6_r0_body.s881.next = 2745893
kernel_rfl PRE_first_tail_x6_r0_body.ccounters90 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s881.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s881.ffi).mlx.nnext) = (19985, 17090)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue90 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s880.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s881.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa90.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp90 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s881.ffi).mlx.tokens.all (bSN 3950) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean90 : Conv.cleanListB 19985 131072 (fun r => Nat.ble 79940 r) PRE_first_tail_x6_r0_body.s881
    (PRE_first_tail_x6_r0_body.wrB90 ++ (List.range 6).map (2745887 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs90 : bigsOutB 19985 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s881.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK90
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl90`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl90 : List Nat := [2665, 2672527, 2673467, 2745061, 2745606, 2745862, 2745887, 2745888, 2745889, 2745890, 2745891, 2745892]
def PRE_first_tail_x6_r0_body.clo90 : List Nat := [19962, 19975, 19981, 19982, 19983, 19984]
def PRE_first_tail_x6_r0_body.cln90 : List Nat := [17063, 17064, 17065, 17066, 17067, 17068, 17069, 17070, 17071, 17072, 17073, 17074, 17075, 17076, 17077, 17078, 17079, 17080, 17081, 17082, 17083, 17084, 17085, 17086, 17087, 17088, 17089]
def PRE_first_tail_x6_r0_body.cli90 : List Nat := [17063, 17064, 17065, 17066, 17067, 17068, 17069, 17070, 17071, 17072, 17073, 17074, 17075, 17076, 17077, 17078, 17079, 17080, 17081, 17082, 17083, 17084, 17085, 17086, 17087, 17088, 17089]
kernel_rfl PRE_first_tail_x6_r0_body.cheap90 : PRE_first_tail_x6_r0_body.s881.heap = Stage.setAll PRE_first_tail_x6_r0_body.s879.heap (PRE_first_tail_x6_r0_body.cl90.filterMap fun a => (PRE_first_tail_x6_r0_body.s881.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe90 : Nat.ble PRE_first_tail_x6_r0_body.s879.next PRE_first_tail_x6_r0_body.s881.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP90 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s879 PRE_first_tail_x6_r0_body.s881 PRE_first_tail_x6_r0_body.cl90 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp90 : Conv.suppListB PRE_first_tail_x6_r0_body.s881 3950 PRE_first_tail_x6_r0_body.cl90 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound90 : Conv.boundListB PRE_first_tail_x6_r0_body.s881 PRE_first_tail_x6_r0_body.cl90 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK90 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s881.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln90.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s881.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK90 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s881.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo90.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s881.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK90 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s881.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli90.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s881.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst90 : Conv.sstListB 3950 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s881.ffi).mlx PRE_first_tail_x6_r0_body.cln90 PRE_first_tail_x6_r0_body.clo90 PRE_first_tail_x6_r0_body.cli90 = true

end Host.Load.Run.Tpl
end

section -- SiteCl90
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA90 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s881.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo90.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s881.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd90 : (PRE_first_tail_x6_r0_body.clo90 ++ PRE_first_tail_x6_r0_body.cln90 ++ PRE_first_tail_x6_r0_body.cli90).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle90 : Conv.Cnt.leB (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt) (⟨19985, 17090, 2745893, 3950⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck90 : Conv.ncleanListB (⟨19985, 17090, 2745893, 3950⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s881.ffi).mlx PRE_first_tail_x6_r0_body.clo90 PRE_first_tail_x6_r0_body.cln90 PRE_first_tail_x6_r0_body.cli90 = true
theorem PRE_first_tail_x6_r0_body.cncl90 (h : Conv.NClean (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx) : Conv.NClean (⟨19985, 17090, 2745893, 3950⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s881.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle90 PRE_first_tail_x6_r0_body.ckA90 PRE_first_tail_x6_r0_body.cobjsK90 PRE_first_tail_x6_r0_body.cnodesK90 PRE_first_tail_x6_r0_body.citemsK90 PRE_first_tail_x6_r0_body.cbd90 PRE_first_tail_x6_r0_body.cck90

end Host.Load.Run.Tpl
end

section -- SiteS90
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 90 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc90 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P90 : LoadP := PRE_first_tail_x6_r0_body.Pc90.raise 17090
kernel_rfl PRE_first_tail_x6_r0_body.craise90 : Nat.ble PRE_first_tail_x6_r0_body.Pc90.N0 17090 = true
theorem PRE_first_tail_x6_r0_body.raised90 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc90 PRE_first_tail_x6_r0_body.P90 :=
  .inr ⟨17090, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise90, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_90 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s881.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_90 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s880.ffi)
def PRE_first_tail_x6_r0_body.khinv90 : PTrie Nat := Stage.setAll PTrie.nil [(20008, 19982), (19986, 19983), (20009, 19984)]
def PRE_first_tail_x6_r0_body.kninv90 : PTrie Nat := Stage.setAll PTrie.nil [(17063, 17063), (17064, 17064), (17065, 17065), (17066, 17066), (17067, 17067), (17068, 17068), (17069, 17069), (17070, 17070), (17071, 17071), (17072, 17072), (17073, 17073), (17074, 17074), (17075, 17075), (17076, 17076), (17077, 17077), (17078, 17078), (17079, 17079), (17080, 17080), (17081, 17081), (17082, 17082), (17083, 17083), (17084, 17084), (17085, 17085), (17086, 17086), (17087, 17087), (17088, 17088), (17089, 17089)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS90 : List Nat := [19962, 19975, 19981, 19982, 19983, 19984, 19985, 19986, 19987, 19988, 19989, 19990, 19991, 19992, 19993, 19994, 19995, 19996, 19997, 19998, 19999, 20000, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009]
def PRE_first_tail_x6_r0_body.cnS90 : List Nat := List.range' 17063 27
def PRE_first_tail_x6_r0_body.ciS90 : List Nat := [] ++ List.range' 17063 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh090 : PRE_first_tail_x6_r0_body.kd90.nh0 = PRE_first_tail_x6_r0_body.cx0_90.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh190 : PRE_first_tail_x6_r0_body.kd90.nh1 = PRE_first_tail_x6_r0_body.cx1_90.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn090 : PRE_first_tail_x6_r0_body.kd90.nn0 = PRE_first_tail_x6_r0_body.cx0_90.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn190 : PRE_first_tail_x6_r0_body.kd90.nn1 = PRE_first_tail_x6_r0_body.cx1_90.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo90 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P90.lo && Nat.ble PRE_first_tail_x6_r0_body.P90.lo PRE_first_tail_x6_r0_body.cx0_90.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P90.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P90.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt90 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_90.mlx.next PRE_first_tail_x6_r0_body.cx1_90.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_90.mlx.nnext PRE_first_tail_x6_r0_body.cx1_90.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband90 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P90.NL && Nat.ble PRE_first_tail_x6_r0_body.P90.NL PRE_first_tail_x6_r0_body.P90.N0 && Nat.ble PRE_first_tail_x6_r0_body.P90.N0 PRE_first_tail_x6_r0_body.cx0_90.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow90 : PRE_first_tail_x6_r0_body.kd90.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren90 : checkRenG PRE_first_tail_x6_r0_body.kd90.hnd PRE_first_tail_x6_r0_body.khinv90 (phB PRE_first_tail_x6_r0_body.cx0_90.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband90 : PRE_first_tail_x6_r0_body.kd90.checkBand PRE_first_tail_x6_r0_body.P90.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos90 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd90.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren90 : checkRenG PRE_first_tail_x6_r0_body.kd90.node PRE_first_tail_x6_r0_body.kninv90 (pnB PRE_first_tail_x6_r0_body.cx0_90.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow90 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd90.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P90.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd90.nodeF j) PRE_first_tail_x6_r0_body.cx1_90.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a90 : PRE_first_tail_x6_r0_body.cx0_90.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b90 : PRE_first_tail_x6_r0_body.cx0_90.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok190 : PRE_first_tail_x6_r0_body.cx1_90.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend90 : PRE_first_tail_x6_r0_body.cx1_90.mlx.pending = PRE_first_tail_x6_r0_body.cx0_90.mlx.pending.map PRE_first_tail_x6_r0_body.kappa90.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh90 : PRE_first_tail_x6_r0_body.cx1_90.mlx.errh = PRE_first_tail_x6_r0_body.cx0_90.mlx.errh.map PRE_first_tail_x6_r0_body.kappa90.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles90 : PRE_first_tail_x6_r0_body.cx1_90.mlx.files = PRE_first_tail_x6_r0_body.cx0_90.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch90 : PRE_first_tail_x6_r0_body.cx1_90.mlx.arch = PRE_first_tail_x6_r0_body.cx0_90.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes90 : PRE_first_tail_x6_r0_body.cx1_90.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_90.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired90 : PRE_first_tail_x6_r0_body.cx1_90.mlx.wired = PRE_first_tail_x6_r0_body.cx0_90.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost90 : PRE_first_tail_x6_r0_body.cx1_90.host = PRE_first_tail_x6_r0_body.cx0_90.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd90`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn090 : PRE_first_tail_x6_r0_body.kd90.n0 = 2745893
kernel_rfl PRE_first_tail_x6_r0_body.ckn190 : PRE_first_tail_x6_r0_body.kd90.n1 = 2747042
kernel_rfl PRE_first_tail_x6_r0_body.ckheap90 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd90.heap).all (fun x => Nat.ble 2745887 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl90 : (List.range 6).all (fun j => decide (PRE_first_tail_x6_r0_body.kd90.heap.get (2745887 + j) = nth? PRE_first_tail_x6_r0_body.pl90 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja90 : Nat.ble 2745887 2745887 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn90 : Nat.ble 3932 3932 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD90 : Nat.ble 2745887 PRE_first_tail_x6_r0_body.kd90.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn90 : Nat.ble 19982 PRE_first_tail_x6_r0_body.kd90.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn90 : Nat.ble 17063 PRE_first_tail_x6_r0_body.kd90.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb90 : Nat.ble 19982 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap90 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd90.heap).all (Nat.ble (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd90 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd90.hnd).all (Nat.ble (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode90 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd90.node).all (Nat.ble (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix90 : Conv.FixOld (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa90 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja90) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn90) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD90) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn90) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn90) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb90) PRE_first_tail_x6_r0_body.fheap90 PRE_first_tail_x6_r0_body.fhnd90 PRE_first_tail_x6_r0_body.fnode90
kernel_rfl PRE_first_tail_x6_r0_body.fcxn90 : (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn90 : (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle090 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_90.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_90.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk90 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd90.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A90 : PRE_first_tail_x6_r0_body.cx1_90.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS90.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_90.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O90 : PRE_first_tail_x6_r0_body.cx1_90.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS90.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_90.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N90 : PRE_first_tail_x6_r0_body.cx1_90.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS90.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_90.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I90 : PRE_first_tail_x6_r0_body.cx1_90.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS90.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_90.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd90 : (PRE_first_tail_x6_r0_body.clo90 ++ PRE_first_tail_x6_r0_body.cln90 ++ PRE_first_tail_x6_r0_body.cli90 ++ PRE_first_tail_x6_r0_body.cwS90 ++ PRE_first_tail_x6_r0_body.cnS90 ++ PRE_first_tail_x6_r0_body.ciS90).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW90 : PRE_first_tail_x6_r0_body.cwS90.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo90.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI90 : PRE_first_tail_x6_r0_body.ciS90.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli90.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN90 : PRE_first_tail_x6_r0_body.cnS90.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF90 : PRE_first_tail_x6_r0_body.cln90.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh90 : PRE_first_tail_x6_r0_body.clo90.all (handleOK PRE_first_tail_x6_r0_body.kappa90 PRE_first_tail_x6_r0_body.P90.lo PRE_first_tail_x6_r0_body.cx0_90.mlx PRE_first_tail_x6_r0_body.cx1_90.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo90 : PRE_first_tail_x6_r0_body.clo90.map (fun h => PRE_first_tail_x6_r0_body.cx1_90.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa90.handle h)) = PRE_first_tail_x6_r0_body.clo90.map (fun h => (PRE_first_tail_x6_r0_body.cx0_90.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa90.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok90 : PRE_first_tail_x6_r0_body.clo90.all (objOK PRE_first_tail_x6_r0_body.kappa90 PRE_first_tail_x6_r0_body.P90.NL PRE_first_tail_x6_r0_body.cx0_90.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd90 : PRE_first_tail_x6_r0_body.cln90.all (nodeOKF PRE_first_tail_x6_r0_body.kappa90 PRE_first_tail_x6_r0_body.P90 PRE_first_tail_x6_r0_body.cx0_90.mlx PRE_first_tail_x6_r0_body.cx1_90.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp90 : ((PRE_first_tail_x6_r0_body.cln90.filter (fullB PRE_first_tail_x6_r0_body.P90))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_90.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa90.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln90.filter (fullB PRE_first_tail_x6_r0_body.P90))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_90.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa90.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI90 : incrB PRE_first_tail_x6_r0_body.kd90.nodeF (List.range' 17063 27) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK90 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd90.node).all (fun k => Nat.ble 17063 k && Nat.blt k 17090) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL90 : (PRE_first_tail_x6_r0_body.cln90.filter (Nat.ble PRE_first_tail_x6_r0_body.P90.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd90.nodeF i) && (Nat.blt i 17090 || Nat.ble PRE_first_tail_x6_r0_body.kd90.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord90 : (PRE_first_tail_x6_r0_body.cln90.filter (Nat.ble PRE_first_tail_x6_r0_body.P90.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd90.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd90.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd90.nodeF j) (PRE_first_tail_x6_r0_body.kd90.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow90 PRE_first_tail_x6_r0_body.cnn190 PRE_first_tail_x6_r0_body.fnordI90 PRE_first_tail_x6_r0_body.fnordK90 PRE_first_tail_x6_r0_body.fnordL90
kernel_rfl PRE_first_tail_x6_r0_body.fi90 : PRE_first_tail_x6_r0_body.cli90.all (pnB PRE_first_tail_x6_r0_body.cx0_90.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii90 : PRE_first_tail_x6_r0_body.cli90.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_90.mlx.items.get (PRE_first_tail_x6_r0_body.kappa90.node k) = (PRE_first_tail_x6_r0_body.cx0_90.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa90.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot90 (clean : Conv.NClean (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P90.NL) (cl : SSt (· < 3950) PRE_first_tail_x6_r0_body.cx0_90.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P90 3950 PRE_first_tail_x6_r0_body.kappa90 PRE_first_tail_x6_r0_body.kd90 PRE_first_tail_x6_r0_body.khinv90 PRE_first_tail_x6_r0_body.kninv90 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx PRE_first_tail_x6_r0_body.cx0_90.mlx PRE_first_tail_x6_r0_body.cx1_90.mlx (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo90 PRE_first_tail_x6_r0_body.cln90 PRE_first_tail_x6_r0_body.cli90 PRE_first_tail_x6_r0_body.cwS90 PRE_first_tail_x6_r0_body.cnS90 PRE_first_tail_x6_r0_body.ciS90 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh090, PRE_first_tail_x6_r0_body.cnh190, PRE_first_tail_x6_r0_body.cnn090, PRE_first_tail_x6_r0_body.cnn190, PRE_first_tail_x6_r0_body.cplo90, PRE_first_tail_x6_r0_body.ccnt90, PRE_first_tail_x6_r0_body.cnband90, PRE_first_tail_x6_r0_body.chbelow90, PRE_first_tail_x6_r0_body.chren90, PRE_first_tail_x6_r0_body.cband90, PRE_first_tail_x6_r0_body.cnh1pos90, PRE_first_tail_x6_r0_body.cnren90, PRE_first_tail_x6_r0_body.cnlow90, PRE_first_tail_x6_r0_body.cabs0a90, PRE_first_tail_x6_r0_body.cabs0b90, PRE_first_tail_x6_r0_body.ctok190, PRE_first_tail_x6_r0_body.cpend90, PRE_first_tail_x6_r0_body.cerrh90, PRE_first_tail_x6_r0_body.cfiles90, PRE_first_tail_x6_r0_body.carch90, PRE_first_tail_x6_r0_body.csizes90, PRE_first_tail_x6_r0_body.cwired90, PRE_first_tail_x6_r0_body.cfix90, clean, PRE_first_tail_x6_r0_body.fcxn90, PRE_first_tail_x6_r0_body.fcnn90, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle090, PRE_first_tail_x6_r0_body.fnk90, PRE_first_tail_x6_r0_body.ckA90, PRE_first_tail_x6_r0_body.cobjsK90, PRE_first_tail_x6_r0_body.cnodesK90, PRE_first_tail_x6_r0_body.citemsK90, PRE_first_tail_x6_r0_body.f1A90, PRE_first_tail_x6_r0_body.f1O90, PRE_first_tail_x6_r0_body.f1N90, PRE_first_tail_x6_r0_body.f1I90, PRE_first_tail_x6_r0_body.fbd90, PRE_first_tail_x6_r0_body.fincW90, PRE_first_tail_x6_r0_body.fincI90, PRE_first_tail_x6_r0_body.fincN90, PRE_first_tail_x6_r0_body.flnF90, PRE_first_tail_x6_r0_body.fh90, PRE_first_tail_x6_r0_body.fo90, PRE_first_tail_x6_r0_body.fok90, PRE_first_tail_x6_r0_body.fnd90, PRE_first_tail_x6_r0_body.fp90, PRE_first_tail_x6_r0_body.fnord90, PRE_first_tail_x6_r0_body.fi90, PRE_first_tail_x6_r0_body.fii90⟩
theorem PRE_first_tail_x6_r0_body.cnshift90 (clean : Conv.NClean (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P90.NL) (cl : SSt (· < 3950) PRE_first_tail_x6_r0_body.cx0_90.mlx) : NShift PRE_first_tail_x6_r0_body.P90 3950 PRE_first_tail_x6_r0_body.kappa90 PRE_first_tail_x6_r0_body.cx0_90 PRE_first_tail_x6_r0_body.cx1_90 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot90 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost90 (compact_a_eq PRE_first_tail_x6_r0_body.ckn090 PRE_first_tail_x6_r0_body.ckn190 PRE_first_tail_x6_r0_body.ckheap90 PRE_first_tail_x6_r0_body.ckpl90)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_90 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s879.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_90 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s879.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_90 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s879.ffi) = some PRE_first_tail_x6_r0_body.fxC_90
kernel_rfl PRE_first_tail_x6_r0_body.okrC_90 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s879.ffi) = some PRE_first_tail_x6_r0_body.krC_90
noncomputable def PRE_first_tail_x6_r0_body.fx0_90 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s881.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_90 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s881.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_90 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s881.ffi) = some PRE_first_tail_x6_r0_body.fx0_90
kernel_rfl PRE_first_tail_x6_r0_body.okr0_90 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s881.ffi) = some PRE_first_tail_x6_r0_body.kr0_90
noncomputable def PRE_first_tail_x6_r0_body.fx1_90 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s880.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_90 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s880.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_90 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s880.ffi) = some PRE_first_tail_x6_r0_body.fx1_90
kernel_rfl PRE_first_tail_x6_r0_body.okr1_90 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s880.ffi) = some PRE_first_tail_x6_r0_body.kr1_90
kernel_rfl PRE_first_tail_x6_r0_body.ff090 : PRE_first_tail_x6_r0_body.fx0_90 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_90 (PRE_first_tail_x6_r0_body.clo90.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_90.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff190 : PRE_first_tail_x6_r0_body.fx1_90 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_90 (PRE_first_tail_x6_r0_body.cwS90.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_90.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck90 : freedLB PRE_first_tail_x6_r0_body.kappa90 PRE_first_tail_x6_r0_body.cx0_90.mlx PRE_first_tail_x6_r0_body.fx0_90 PRE_first_tail_x6_r0_body.fx1_90 PRE_first_tail_x6_r0_body.clo90 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf090 : PRE_first_tail_x6_r0_body.kr0_90.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_90.flags (PRE_first_tail_x6_r0_body.clo90.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_90.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt090 : PRE_first_tail_x6_r0_body.kr0_90.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_90.targs (PRE_first_tail_x6_r0_body.clo90.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_90.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf190 : PRE_first_tail_x6_r0_body.kr1_90.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_90.flags (PRE_first_tail_x6_r0_body.cwS90.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_90.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt190 : PRE_first_tail_x6_r0_body.kr1_90.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_90.targs (PRE_first_tail_x6_r0_body.cwS90.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_90.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck90 : krecLB PRE_first_tail_x6_r0_body.kappa90 3950 PRE_first_tail_x6_r0_body.cx0_90.mlx PRE_first_tail_x6_r0_body.kr0_90 PRE_first_tail_x6_r0_body.kr1_90 PRE_first_tail_x6_r0_body.clo90 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn90 : Nat.ble 3932 3950 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge90 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s880.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s881.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR90 : pendRegB PRE_first_tail_x6_r0_body.kappa90 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s881.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe90 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s881.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s880.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift90 (clean : Conv.NClean (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P90.NL) (cl : SSt (· < 3950) PRE_first_tail_x6_r0_body.cx0_90.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_90.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_90.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_90.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s879.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_90.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P90 3950 PRE_first_tail_x6_r0_body.kappa90 PRE_first_tail_x6_r0_body.s881.ffi PRE_first_tail_x6_r0_body.s880.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift90 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue90, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp90 t ht),
    PRE_first_tail_x6_r0_body.cbridge90,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s881.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s880.ffi) (PRE_first_tail_x6_r0_body.cfoot90 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_90 PRE_first_tail_x6_r0_body.ofx1_90 hobjC PRE_first_tail_x6_r0_body.ff090 PRE_first_tail_x6_r0_body.ff190 PRE_first_tail_x6_r0_body.ffck90,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s881.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s880.ffi) (PRE_first_tail_x6_r0_body.cfoot90 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_90 PRE_first_tail_x6_r0_body.okr1_90 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn90) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf090 PRE_first_tail_x6_r0_body.fkt090 PRE_first_tail_x6_r0_body.fkf190 PRE_first_tail_x6_r0_body.fkt190 PRE_first_tail_x6_r0_body.fkck90,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh090 PRE_first_tail_x6_r0_body.cnh190 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe90) PRE_first_tail_x6_r0_body.cpendR90⟩

end Host.Load.Run.Tpl
end

section -- st90/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st90 0
host_stream_state PRE_first_tail_x6_r0_body.st90 1
host_stream_state PRE_first_tail_x6_r0_body.st90 2
host_stream_state PRE_first_tail_x6_r0_body.st90 3
host_stream_state PRE_first_tail_x6_r0_body.st90 4
host_stream_state PRE_first_tail_x6_r0_body.st90 5
end Host.Load.Run.Tpl
end

section -- Site90
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 90 of chain `PRE_first_tail_x6_r0_body`: `ssmW__g90__g91` (`recurWindow`), the call state `PRE_first_tail_x6_r0_body.s879`, the merged state `PRE_first_tail_x6_r0_body.s880`,
the site template `PRE_first_tail_x6_r0_body.st90` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s881`: the merge.
The footprint's facts are in `SiteF90`, the compaction's in `SiteC90`, `SiteK90`, `SiteNa90`, `SiteNb90`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso90 : PRE_first_tail_x6_r0_body.st90.s0 = { PRE_first_tail_x6_r0_body.s879 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs90 : List Frame := PRE_first_tail_x6_r0_body.s879.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_90 : PRE_first_tail_x6_r0_body.S879.tab.length = 3932
kernel_rfl PRE_first_tail_x6_r0_body.tab0_90 : PRE_first_tail_x6_r0_body.st90.S0.tab = PRE_first_tail_x6_r0_body.S879.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws90 : List Nat := [2507, 2508, 2509, 2510, 2511, 2512, 2513, 2514, 2515, 2516, 2517, 2518, 2519, 2520, 2521, 2522, 2523, 2524, 2525, 2526, 2527, 2528, 2529, 2530, 2531, 2532, 2533, 2534, 2535, 2536, 2537]
kernel_rfl PRE_first_tail_x6_r0_body.fresh90 : (PRE_first_tail_x6_r0_body.S879.tab.all fun e => PRE_first_tail_x6_r0_body.ws90.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S879.oracle.all fun q => PRE_first_tail_x6_r0_body.ws90.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab90 : PRE_first_tail_x6_r0_body.S880.tab = PRE_first_tail_x6_r0_body.S879.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws90
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen90 : PRE_first_tail_x6_r0_body.st90.S5.tab.length - PRE_first_tail_x6_r0_body.st90.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged90`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap90 : PRE_first_tail_x6_r0_body.s880.heap = PRE_first_tail_x6_r0_body.st90.s5.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext90 : PRE_first_tail_x6_r0_body.s880.next = PRE_first_tail_x6_r0_body.st90.s5.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl90 : PRE_first_tail_x6_r0_body.s880.ctl = PRE_first_tail_x6_r0_body.st90.s5.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack90 : PRE_first_tail_x6_r0_body.s880.stack = PRE_first_tail_x6_r0_body.st90.s5.stack ++ PRE_first_tail_x6_r0_body.s879.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs90 : PRE_first_tail_x6_r0_body.s880.jobs = PRE_first_tail_x6_r0_body.st90.s5.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi90 : PRE_first_tail_x6_r0_body.s880.ffi = PRE_first_tail_x6_r0_body.st90.s5.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace90 : PRE_first_tail_x6_r0_body.s880.trace = PRE_first_tail_x6_r0_body.st90.s5.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores90 : PRE_first_tail_x6_r0_body.s880.stores = PRE_first_tail_x6_r0_body.st90.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD90
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 90 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived90 : PRE_first_tail_x6_r0_body.nr90.map (fun r => nth? PRE_first_tail_x6_r0_body.st90.S5.tab r) =
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
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo90 : PRE_first_tail_x6_r0_body.nr90.all (Nat.ble 3932) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj90 : PRE_first_tail_x6_r0_body.cws90.all (fun c => !PRE_first_tail_x6_r0_body.ws90.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ90 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws90 PRE_first_tail_x6_r0_body.crs90 PRE_first_tail_x6_r0_body.ws90

end Host.Load.Run.Tpl
end

section -- st90/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st90`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st90.wrR : List (Nat × Nat) := [(2672527, 2672528), (2745061, 2745062), (2745606, 2745607), (2745862, 2745863)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st90.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st90.s5.heap PRE_first_tail_x6_r0_body.st90.wrR ++ freshOf PRE_first_tail_x6_r0_body.st90.s5.heap PRE_first_tail_x6_r0_body.st90.s0.next PRE_first_tail_x6_r0_body.st90.s5.next
noncomputable def PRE_first_tail_x6_r0_body.st90.wr : List Nat := PRE_first_tail_x6_r0_body.st90.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st90.heapFoot : PRE_first_tail_x6_r0_body.st90.s5.heap = setAll PRE_first_tail_x6_r0_body.st90.s0.heap PRE_first_tail_x6_r0_body.st90.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st90.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st90.s0.next PRE_first_tail_x6_r0_body.st90.s5.next = true
theorem PRE_first_tail_x6_r0_body.st90.grows : PRE_first_tail_x6_r0_body.st90.s0.next ≤ PRE_first_tail_x6_r0_body.st90.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st90.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st90.wh : List Nat := [19962, 19975, 19981, 19982, 19983, 19984, 19985, 19986, 19987, 19988, 19989, 19990, 19991, 19992, 19993, 19994, 19995, 19996, 19997, 19998, 19999, 20000, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009]
def PRE_first_tail_x6_r0_body.st90.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st90.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st90.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st90.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st90.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st90.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st90.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st90.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st90.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st90.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st90.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st90.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st90.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st90.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st90.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st90.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st90.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st90.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st90.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st90.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st90.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st90.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st90.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st90.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st90.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st90.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st90.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st90.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st90.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st90.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF90
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 90 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB90 : nodupT PRE_first_tail_x6_r0_body.st90.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup90 : PRE_first_tail_x6_r0_body.st90.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB90).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB90 : PRE_first_tail_x6_r0_body.st90.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound90 : ∀ b ∈ PRE_first_tail_x6_r0_body.st90.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB90 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr90 := PRE_first_tail_x6_r0_body.st90.s5.trace.take 120
kernel_rfl PRE_first_tail_x6_r0_body.traceEq90 : PRE_first_tail_x6_r0_body.st90.s5.trace = PRE_first_tail_x6_r0_body.trFr90 ++ PRE_first_tail_x6_r0_body.st90.s0.trace
theorem PRE_first_tail_x6_r0_body.trace90 : ∃ fr, PRE_first_tail_x6_r0_body.st90.s5.trace = fr ++ PRE_first_tail_x6_r0_body.st90.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq90⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide90 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB90 : (PRE_first_tail_x6_r0_body.wide90.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st90.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix90 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide90, WFix Map.id (Present PRE_first_tail_x6_r0_body.st90.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB90 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL90
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 90 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s880`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO90 : PRE_first_tail_x6_r0_body.st90.S0.oracle = PRE_first_tail_x6_r0_body.st90.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B90 : PRE_first_tail_x6_r0_body.st90.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st90.s0.next || (PRE_first_tail_x6_r0_body.st90.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot90 : Conv.StageFoot PRE_first_tail_x6_r0_body.st90.wr PRE_first_tail_x6_r0_body.st90.s0 PRE_first_tail_x6_r0_body.st90.s5 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st90.heapFoot PRE_first_tail_x6_r0_body.wrNodup90 PRE_first_tail_x6_r0_body.wrBound90 PRE_first_tail_x6_r0_body.wr0B90 PRE_first_tail_x6_r0_body.st90.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged90 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st90.F.S → PRE_first_tail_x6_r0_body.st90.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st90.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st90.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs90 PRE_first_tail_x6_r0_body.st90.wr PRE_first_tail_x6_r0_body.s879 PRE_first_tail_x6_r0_body.st90.s5 PRE_first_tail_x6_r0_body.st90.s0
      PRE_first_tail_x6_r0_body.st90.s5.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st90.F FR W stk M ν K PRE_first_tail_x6_r0_body.s880 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso90 PRE_first_tail_x6_r0_body.stFoot90 PRE_first_tail_x6_r0_body.wrNodup90 PRE_first_tail_x6_r0_body.wrBound90 PRE_first_tail_x6_r0_body.trace90 PRE_first_tail_x6_r0_body.mheap90
    PRE_first_tail_x6_r0_body.mnext90 PRE_first_tail_x6_r0_body.mctl90 PRE_first_tail_x6_r0_body.mstack90 PRE_first_tail_x6_r0_body.mjobs90 PRE_first_tail_x6_r0_body.mffi90 PRE_first_tail_x6_r0_body.mtrace90 PRE_first_tail_x6_r0_body.mstores90 h

def PRE_first_tail_x6_r0_body.arrEl90_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE90_2665 : arrOf PRE_first_tail_x6_r0_body.s880 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl90_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA90_2665 : isArrB PRE_first_tail_x6_r0_body.s880 2665 = true
theorem PRE_first_tail_x6_r0_body.arr90_2665 : ∃ o, PRE_first_tail_x6_r0_body.s880.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl90_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE90_2665 PRE_first_tail_x6_r0_body.arrA90_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN90_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl90_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR90_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl90_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN90_2665

def PRE_first_tail_x6_r0_body.arrEl90_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE90_2673467 : arrOf PRE_first_tail_x6_r0_body.s880 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl90_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA90_2673467 : isArrB PRE_first_tail_x6_r0_body.s880 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr90_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s880.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl90_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE90_2673467 PRE_first_tail_x6_r0_body.arrA90_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN90_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl90_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR90_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl90_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN90_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k90 : isArrB PRE_first_tail_x6_r0_body.s880 4910 = false
theorem PRE_first_tail_x6_r0_body.keep90 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s880 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k90 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr90_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl90_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ90
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 90 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s879`, the merged
state `PRE_first_tail_x6_r0_body.s880`, the canonical state `PRE_first_tail_x6_r0_body.s881`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl90 : PRE_first_tail_x6_r0_body.pl90.all (Nat.ble PRE_first_tail_x6_r0_body.s879.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd90 : nodupT PRE_first_tail_x6_r0_body.pl90 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn190 : Nat.ble PRE_first_tail_x6_r0_body.s879.next 2747042 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst90 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s879.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn90 : PRE_first_tail_x6_r0_body.s881.next = PRE_first_tail_x6_r0_body.s879.next + PRE_first_tail_x6_r0_body.pl90.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn90 : PRE_first_tail_x6_r0_body.s880.next = 2747042
kernel_rfl PRE_first_tail_x6_r0_body.zgrow90 : Nat.ble PRE_first_tail_x6_r0_body.s881.next PRE_first_tail_x6_r0_body.s880.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh90 : PRE_first_tail_x6_r0_body.S879.tab.all (fun e => PRE_first_tail_x6_r0_body.cws90.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd90 : nodupT PRE_first_tail_x6_r0_body.cws90 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi90 : PRE_first_tail_x6_r0_body.nr90.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S880.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt90 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s879.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg90_2665 : PRE_first_tail_x6_r0_body.s881.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s881 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk90_2665 : (objOf PRE_first_tail_x6_r0_body.s881 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm90_2665 : PRE_first_tail_x6_r0_body.s880.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa90.obj (objOf PRE_first_tail_x6_r0_body.s881 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s880 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg90_2673467 : PRE_first_tail_x6_r0_body.s881.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s881 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk90_2673467 : (objOf PRE_first_tail_x6_r0_body.s881 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm90_2673467 : PRE_first_tail_x6_r0_body.s880.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa90.obj (objOf PRE_first_tail_x6_r0_body.s881 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s880 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw90_4910 : (PRE_first_tail_x6_r0_body.s881.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw90_2673472 : (PRE_first_tail_x6_r0_body.s881.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw90_2673473 : (PRE_first_tail_x6_r0_body.s881.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd90 : PRE_first_tail_x6_r0_body.cl90.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr90 : PRE_first_tail_x6_r0_body.st90.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s879.next || PRE_first_tail_x6_r0_body.cl90.contains b) = true
def PRE_first_tail_x6_r0_body.zl90 : List Nat := PRE_first_tail_x6_r0_body.cl90.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE90 : PRE_first_tail_x6_r0_body.zl90.map (fun a => PRE_first_tail_x6_r0_body.s880.heap.get (PRE_first_tail_x6_r0_body.kappa90.a a)) = PRE_first_tail_x6_r0_body.zl90.map (fun a => (PRE_first_tail_x6_r0_body.s881.heap.get a).map PRE_first_tail_x6_r0_body.kappa90.hobj)
theorem PRE_first_tail_x6_r0_body.zimg90 : HeapImg PRE_first_tail_x6_r0_body.kappa90 PRE_first_tail_x6_r0_body.s881 PRE_first_tail_x6_r0_body.s880 PRE_first_tail_x6_r0_body.zl90 := PRE_first_tail_x6_r0_body.zimgE90
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl90 : PRE_first_tail_x6_r0_body.s880.ctl = PRE_first_tail_x6_r0_body.kappa90.ctl PRE_first_tail_x6_r0_body.s881.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack90 : PRE_first_tail_x6_r0_body.s880.stack = PRE_first_tail_x6_r0_body.s881.stack.map PRE_first_tail_x6_r0_body.kappa90.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs90 : PRE_first_tail_x6_r0_body.s880.jobs = PRE_first_tail_x6_r0_body.s881.jobs.map PRE_first_tail_x6_r0_body.kappa90.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores90 : PRE_first_tail_x6_r0_body.s880.stores = PRE_first_tail_x6_r0_body.kappa90.stores PRE_first_tail_x6_r0_body.s881.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots90 : checkRootsSupp PRE_first_tail_x6_r0_body.s881 3950 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC90 : PRE_first_tail_x6_r0_body.S879.tab.length + PRE_first_tail_x6_r0_body.cws90.length = 3950
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap90 : PRE_first_tail_x6_r0_body.kappa90 = Conv.Map.compact PRE_first_tail_x6_r0_body.s879.next 2747042 PRE_first_tail_x6_r0_body.S879.tab.length PRE_first_tail_x6_r0_body.pl90 (PRE_first_tail_x6_r0_body.nr90.map NumV.ref) PRE_first_tail_x6_r0_body.kd90.big
  PRE_first_tail_x6_r0_body.kd90.region PRE_first_tail_x6_r0_body.kd90.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin90 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s881.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc90 : Conv.jcleanListB (⟨19985, 17090, 2745893, 3950⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s881 PRE_first_tail_x6_r0_body.cl90 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB90 : noBigRootsP (fun i => !Conv.oldBigB (⟨19985, 17090, 2745893, 3950⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s881.trace PRE_first_tail_x6_r0_body.s881 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm90 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 17063 = true
theorem PRE_first_tail_x6_r0_body.cjcl90 (h : Conv.JClean (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s879) : Conv.JClean (⟨19985, 17090, 2745893, 3950⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s881 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle90)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap90 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd90 a ha)) PRE_first_tail_x6_r0_body.zjc90

end Host.Load.Run.Tpl
end

section -- st90/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st90.bodyLast from PRE_first_tail_x6_r0_body.st90.s4 to PRE_first_tail_x6_r0_body.st90.s5 :
  interpS (step PRE_first_tail_x6_r0_body.st90.F PRE_first_tail_x6_r0_body.st90.s4).run PRE_first_tail_x6_r0_body.st90.S4 = some (PRE_first_tail_x6_r0_body.st90.s5, PRE_first_tail_x6_r0_body.st90.S5)
kernel_rfl PRE_first_tail_x6_r0_body.st90.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st90.s4.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st90.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st90.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st90/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st90.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st90.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st90.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st90.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st90.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st90.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st90.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st90.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st90.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st90.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st90.s0 PRE_first_tail_x6_r0_body.st90.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st90.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st90.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st90.s4 PRE_first_tail_x6_r0_body.st90.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st90/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st90.bodyK0F from PRE_first_tail_x6_r0_body.st90.s0 to PRE_first_tail_x6_r0_body.st90.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st90.F (PRE_first_tail_x6_r0_body.st90.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st90.ks 0).getD 0) PRE_first_tail_x6_r0_body.st90.s0 PRE_first_tail_x6_r0_body.st90.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st90.s1, PRE_first_tail_x6_r0_body.st90.S1)
theorem PRE_first_tail_x6_r0_body.st90.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st90.F (PRE_first_tail_x6_r0_body.st90.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st90.ks 0).getD 0) PRE_first_tail_x6_r0_body.st90.s0 PRE_first_tail_x6_r0_body.st90.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st90.s1, PRE_first_tail_x6_r0_body.st90.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st90.bodyOkLN_ok PRE_first_tail_x6_r0_body.st90.bodyK0F
end Host.Load.Run.Tpl
end

section -- st90/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st90.bodyK1F from PRE_first_tail_x6_r0_body.st90.s1 to PRE_first_tail_x6_r0_body.st90.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st90.F (PRE_first_tail_x6_r0_body.st90.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st90.ks 1).getD 0) PRE_first_tail_x6_r0_body.st90.s1 PRE_first_tail_x6_r0_body.st90.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st90.s2, PRE_first_tail_x6_r0_body.st90.S2)
theorem PRE_first_tail_x6_r0_body.st90.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st90.F (PRE_first_tail_x6_r0_body.st90.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st90.ks 1).getD 0) PRE_first_tail_x6_r0_body.st90.s1 PRE_first_tail_x6_r0_body.st90.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st90.s2, PRE_first_tail_x6_r0_body.st90.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st90.bodyOkLN_ok PRE_first_tail_x6_r0_body.st90.bodyK1F
end Host.Load.Run.Tpl
end

section -- st90/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st90.bodyK2F from PRE_first_tail_x6_r0_body.st90.s2 to PRE_first_tail_x6_r0_body.st90.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st90.F (PRE_first_tail_x6_r0_body.st90.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st90.ks 2).getD 0) PRE_first_tail_x6_r0_body.st90.s2 PRE_first_tail_x6_r0_body.st90.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st90.s3, PRE_first_tail_x6_r0_body.st90.S3)
theorem PRE_first_tail_x6_r0_body.st90.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st90.F (PRE_first_tail_x6_r0_body.st90.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st90.ks 2).getD 0) PRE_first_tail_x6_r0_body.st90.s2 PRE_first_tail_x6_r0_body.st90.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st90.s3, PRE_first_tail_x6_r0_body.st90.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st90.bodyOkLN_ok PRE_first_tail_x6_r0_body.st90.bodyK2F
end Host.Load.Run.Tpl
end

section -- st90/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st90.bodyK3F from PRE_first_tail_x6_r0_body.st90.s3 to PRE_first_tail_x6_r0_body.st90.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st90.F (PRE_first_tail_x6_r0_body.st90.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st90.ks 3).getD 0) PRE_first_tail_x6_r0_body.st90.s3 PRE_first_tail_x6_r0_body.st90.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st90.s4, PRE_first_tail_x6_r0_body.st90.S4)
theorem PRE_first_tail_x6_r0_body.st90.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st90.F (PRE_first_tail_x6_r0_body.st90.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st90.ks 3).getD 0) PRE_first_tail_x6_r0_body.st90.s3 PRE_first_tail_x6_r0_body.st90.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st90.s4, PRE_first_tail_x6_r0_body.st90.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st90.bodyOkLN_ok PRE_first_tail_x6_r0_body.st90.bodyK3F
end Host.Load.Run.Tpl
end

section -- st90/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st90.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st90.F (PRE_first_tail_x6_r0_body.st90.bodyOkL bytes rows) 11334 PRE_first_tail_x6_r0_body.st90.s0 PRE_first_tail_x6_r0_body.st90.S0 = some (PRE_first_tail_x6_r0_body.st90.s4, PRE_first_tail_x6_r0_body.st90.S4) :=
  runOk_trans PRE_first_tail_x6_r0_body.st90.F (PRE_first_tail_x6_r0_body.st90.bodyOkL bytes rows) ((((nth? PRE_first_tail_x6_r0_body.st90.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st90.ks 1).getD 0)) + ((nth? PRE_first_tail_x6_r0_body.st90.ks 2).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st90.ks 3).getD 0) PRE_first_tail_x6_r0_body.st90.s0 PRE_first_tail_x6_r0_body.st90.s3 PRE_first_tail_x6_r0_body.st90.s4 PRE_first_tail_x6_r0_body.st90.S0 PRE_first_tail_x6_r0_body.st90.S3 PRE_first_tail_x6_r0_body.st90.S4 (runOk_trans PRE_first_tail_x6_r0_body.st90.F (PRE_first_tail_x6_r0_body.st90.bodyOkL bytes rows) (((nth? PRE_first_tail_x6_r0_body.st90.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st90.ks 1).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st90.ks 2).getD 0) PRE_first_tail_x6_r0_body.st90.s0 PRE_first_tail_x6_r0_body.st90.s2 PRE_first_tail_x6_r0_body.st90.s3 PRE_first_tail_x6_r0_body.st90.S0 PRE_first_tail_x6_r0_body.st90.S2 PRE_first_tail_x6_r0_body.st90.S3 (runOk_trans PRE_first_tail_x6_r0_body.st90.F (PRE_first_tail_x6_r0_body.st90.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st90.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st90.ks 1).getD 0) PRE_first_tail_x6_r0_body.st90.s0 PRE_first_tail_x6_r0_body.st90.s1 PRE_first_tail_x6_r0_body.st90.s2 PRE_first_tail_x6_r0_body.st90.S0 PRE_first_tail_x6_r0_body.st90.S1 PRE_first_tail_x6_r0_body.st90.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st90.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st90.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st90.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st90.bodyK3 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st90.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st90.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st90.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st90.F (PRE_first_tail_x6_r0_body.st90.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st90.s0
  S0 := PRE_first_tail_x6_r0_body.st90.S0
  s1 := PRE_first_tail_x6_r0_body.st90.s4
  S1 := PRE_first_tail_x6_r0_body.st90.S4
  s2 := PRE_first_tail_x6_r0_body.st90.s5
  S2 := PRE_first_tail_x6_r0_body.st90.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st90.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st90.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st90.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st90.bodyHalt
  last := PRE_first_tail_x6_r0_body.st90.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st90.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC91
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 91 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s889` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa91` into the merged state
`PRE_first_tail_x6_r0_body.s888`. -/

def PRE_first_tail_x6_r0_body.pl91 : List Nat := []
def PRE_first_tail_x6_r0_body.nr91 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd91 : RData :=
  ⟨2746383, 2746385, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19998, 19998, 17103, 17103, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa91 : Map :=
  Conv.Map.compact 2746383 2746385 3971 PRE_first_tail_x6_r0_body.pl91 (PRE_first_tail_x6_r0_body.nr91.map NumV.ref) PRE_first_tail_x6_r0_body.kd91.big
    PRE_first_tail_x6_r0_body.kd91.region PRE_first_tail_x6_r0_body.kd91.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws91 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs91 : List SymE := PRE_first_tail_x6_r0_body.nr91.map fun r => (nth? PRE_first_tail_x6_r0_body.S888.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta91 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws91 PRE_first_tail_x6_r0_body.crs91
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB91 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab91 : PRE_first_tail_x6_r0_body.S889.tab = PRE_first_tail_x6_r0_body.S887.tab ++ PRE_first_tail_x6_r0_body.cws91.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace91 : PRE_first_tail_x6_r0_body.s889.trace = PRE_first_tail_x6_r0_body.s887.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext91 : PRE_first_tail_x6_r0_body.s889.next = 2746383
kernel_rfl PRE_first_tail_x6_r0_body.ccounters91 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s889.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s889.ffi).mlx.nnext) = (19998, 17103)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue91 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s888.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s889.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa91.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp91 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s889.ffi).mlx.tokens.all (bSN 3971) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean91 : Conv.cleanListB 19998 131072 (fun r => Nat.ble 79992 r) PRE_first_tail_x6_r0_body.s889
    (PRE_first_tail_x6_r0_body.wrB91 ++ (List.range 0).map (2746383 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs91 : bigsOutB 19998 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s889.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK91
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl91`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl91 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo91 : List Nat := []
def PRE_first_tail_x6_r0_body.cln91 : List Nat := []
def PRE_first_tail_x6_r0_body.cli91 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap91 : PRE_first_tail_x6_r0_body.s889.heap = Stage.setAll PRE_first_tail_x6_r0_body.s887.heap (PRE_first_tail_x6_r0_body.cl91.filterMap fun a => (PRE_first_tail_x6_r0_body.s889.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe91 : Nat.ble PRE_first_tail_x6_r0_body.s887.next PRE_first_tail_x6_r0_body.s889.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP91 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s887 PRE_first_tail_x6_r0_body.s889 PRE_first_tail_x6_r0_body.cl91 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp91 : Conv.suppListB PRE_first_tail_x6_r0_body.s889 3971 PRE_first_tail_x6_r0_body.cl91 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound91 : Conv.boundListB PRE_first_tail_x6_r0_body.s889 PRE_first_tail_x6_r0_body.cl91 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK91 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s889.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln91.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s889.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK91 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s889.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo91.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s889.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK91 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s889.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli91.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s889.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst91 : Conv.sstListB 3971 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s889.ffi).mlx PRE_first_tail_x6_r0_body.cln91 PRE_first_tail_x6_r0_body.clo91 PRE_first_tail_x6_r0_body.cli91 = true

end Host.Load.Run.Tpl
end

section -- SiteCl91
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA91 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s889.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo91.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s889.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd91 : (PRE_first_tail_x6_r0_body.clo91 ++ PRE_first_tail_x6_r0_body.cln91 ++ PRE_first_tail_x6_r0_body.cli91).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle91 : Conv.Cnt.leB (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck91 : Conv.ncleanListB (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s889.ffi).mlx PRE_first_tail_x6_r0_body.clo91 PRE_first_tail_x6_r0_body.cln91 PRE_first_tail_x6_r0_body.cli91 = true
theorem PRE_first_tail_x6_r0_body.cncl91 (h : Conv.NClean (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx) : Conv.NClean (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s889.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle91 PRE_first_tail_x6_r0_body.ckA91 PRE_first_tail_x6_r0_body.cobjsK91 PRE_first_tail_x6_r0_body.cnodesK91 PRE_first_tail_x6_r0_body.citemsK91 PRE_first_tail_x6_r0_body.cbd91 PRE_first_tail_x6_r0_body.cck91

end Host.Load.Run.Tpl
end

section -- SiteS91
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 91 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc91 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P91 : LoadP := PRE_first_tail_x6_r0_body.Pc91.raise 17103
kernel_rfl PRE_first_tail_x6_r0_body.craise91 : Nat.ble PRE_first_tail_x6_r0_body.Pc91.N0 17103 = true
theorem PRE_first_tail_x6_r0_body.raised91 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc91 PRE_first_tail_x6_r0_body.P91 :=
  .inr ⟨17103, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise91, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_91 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s889.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_91 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s888.ffi)
def PRE_first_tail_x6_r0_body.khinv91 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv91 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS91 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS91 : List Nat := List.range' 17103 0
def PRE_first_tail_x6_r0_body.ciS91 : List Nat := [] ++ List.range' 17103 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh091 : PRE_first_tail_x6_r0_body.kd91.nh0 = PRE_first_tail_x6_r0_body.cx0_91.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh191 : PRE_first_tail_x6_r0_body.kd91.nh1 = PRE_first_tail_x6_r0_body.cx1_91.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn091 : PRE_first_tail_x6_r0_body.kd91.nn0 = PRE_first_tail_x6_r0_body.cx0_91.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn191 : PRE_first_tail_x6_r0_body.kd91.nn1 = PRE_first_tail_x6_r0_body.cx1_91.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo91 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P91.lo && Nat.ble PRE_first_tail_x6_r0_body.P91.lo PRE_first_tail_x6_r0_body.cx0_91.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P91.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P91.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt91 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_91.mlx.next PRE_first_tail_x6_r0_body.cx1_91.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_91.mlx.nnext PRE_first_tail_x6_r0_body.cx1_91.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband91 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P91.NL && Nat.ble PRE_first_tail_x6_r0_body.P91.NL PRE_first_tail_x6_r0_body.P91.N0 && Nat.ble PRE_first_tail_x6_r0_body.P91.N0 PRE_first_tail_x6_r0_body.cx0_91.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow91 : PRE_first_tail_x6_r0_body.kd91.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren91 : checkRenG PRE_first_tail_x6_r0_body.kd91.hnd PRE_first_tail_x6_r0_body.khinv91 (phB PRE_first_tail_x6_r0_body.cx0_91.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband91 : PRE_first_tail_x6_r0_body.kd91.checkBand PRE_first_tail_x6_r0_body.P91.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos91 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd91.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren91 : checkRenG PRE_first_tail_x6_r0_body.kd91.node PRE_first_tail_x6_r0_body.kninv91 (pnB PRE_first_tail_x6_r0_body.cx0_91.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow91 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd91.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P91.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd91.nodeF j) PRE_first_tail_x6_r0_body.cx1_91.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a91 : PRE_first_tail_x6_r0_body.cx0_91.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b91 : PRE_first_tail_x6_r0_body.cx0_91.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok191 : PRE_first_tail_x6_r0_body.cx1_91.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend91 : PRE_first_tail_x6_r0_body.cx1_91.mlx.pending = PRE_first_tail_x6_r0_body.cx0_91.mlx.pending.map PRE_first_tail_x6_r0_body.kappa91.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh91 : PRE_first_tail_x6_r0_body.cx1_91.mlx.errh = PRE_first_tail_x6_r0_body.cx0_91.mlx.errh.map PRE_first_tail_x6_r0_body.kappa91.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles91 : PRE_first_tail_x6_r0_body.cx1_91.mlx.files = PRE_first_tail_x6_r0_body.cx0_91.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch91 : PRE_first_tail_x6_r0_body.cx1_91.mlx.arch = PRE_first_tail_x6_r0_body.cx0_91.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes91 : PRE_first_tail_x6_r0_body.cx1_91.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_91.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired91 : PRE_first_tail_x6_r0_body.cx1_91.mlx.wired = PRE_first_tail_x6_r0_body.cx0_91.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost91 : PRE_first_tail_x6_r0_body.cx1_91.host = PRE_first_tail_x6_r0_body.cx0_91.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd91`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn091 : PRE_first_tail_x6_r0_body.kd91.n0 = 2746383
kernel_rfl PRE_first_tail_x6_r0_body.ckn191 : PRE_first_tail_x6_r0_body.kd91.n1 = 2746385
kernel_rfl PRE_first_tail_x6_r0_body.ckheap91 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd91.heap).all (fun x => Nat.ble 2746383 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl91 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_body.kd91.heap.get (2746383 + j) = nth? PRE_first_tail_x6_r0_body.pl91 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja91 : Nat.ble 2746383 2746383 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn91 : Nat.ble 3971 3971 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD91 : Nat.ble 2746383 PRE_first_tail_x6_r0_body.kd91.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn91 : Nat.ble 19998 PRE_first_tail_x6_r0_body.kd91.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn91 : Nat.ble 17103 PRE_first_tail_x6_r0_body.kd91.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb91 : Nat.ble 19998 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap91 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd91.heap).all (Nat.ble (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd91 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd91.hnd).all (Nat.ble (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode91 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd91.node).all (Nat.ble (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix91 : Conv.FixOld (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa91 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja91) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn91) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD91) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn91) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn91) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb91) PRE_first_tail_x6_r0_body.fheap91 PRE_first_tail_x6_r0_body.fhnd91 PRE_first_tail_x6_r0_body.fnode91
kernel_rfl PRE_first_tail_x6_r0_body.fcxn91 : (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn91 : (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle091 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_91.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_91.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk91 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd91.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A91 : PRE_first_tail_x6_r0_body.cx1_91.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS91.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_91.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O91 : PRE_first_tail_x6_r0_body.cx1_91.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS91.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_91.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N91 : PRE_first_tail_x6_r0_body.cx1_91.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS91.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_91.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I91 : PRE_first_tail_x6_r0_body.cx1_91.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS91.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_91.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd91 : (PRE_first_tail_x6_r0_body.clo91 ++ PRE_first_tail_x6_r0_body.cln91 ++ PRE_first_tail_x6_r0_body.cli91 ++ PRE_first_tail_x6_r0_body.cwS91 ++ PRE_first_tail_x6_r0_body.cnS91 ++ PRE_first_tail_x6_r0_body.ciS91).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW91 : PRE_first_tail_x6_r0_body.cwS91.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo91.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI91 : PRE_first_tail_x6_r0_body.ciS91.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli91.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN91 : PRE_first_tail_x6_r0_body.cnS91.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF91 : PRE_first_tail_x6_r0_body.cln91.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh91 : PRE_first_tail_x6_r0_body.clo91.all (handleOK PRE_first_tail_x6_r0_body.kappa91 PRE_first_tail_x6_r0_body.P91.lo PRE_first_tail_x6_r0_body.cx0_91.mlx PRE_first_tail_x6_r0_body.cx1_91.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo91 : PRE_first_tail_x6_r0_body.clo91.map (fun h => PRE_first_tail_x6_r0_body.cx1_91.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa91.handle h)) = PRE_first_tail_x6_r0_body.clo91.map (fun h => (PRE_first_tail_x6_r0_body.cx0_91.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa91.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok91 : PRE_first_tail_x6_r0_body.clo91.all (objOK PRE_first_tail_x6_r0_body.kappa91 PRE_first_tail_x6_r0_body.P91.NL PRE_first_tail_x6_r0_body.cx0_91.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd91 : PRE_first_tail_x6_r0_body.cln91.all (nodeOKF PRE_first_tail_x6_r0_body.kappa91 PRE_first_tail_x6_r0_body.P91 PRE_first_tail_x6_r0_body.cx0_91.mlx PRE_first_tail_x6_r0_body.cx1_91.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp91 : ((PRE_first_tail_x6_r0_body.cln91.filter (fullB PRE_first_tail_x6_r0_body.P91))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_91.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa91.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln91.filter (fullB PRE_first_tail_x6_r0_body.P91))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_91.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa91.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI91 : incrB PRE_first_tail_x6_r0_body.kd91.nodeF (List.range' 17103 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK91 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd91.node).all (fun k => Nat.ble 17103 k && Nat.blt k 17103) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL91 : (PRE_first_tail_x6_r0_body.cln91.filter (Nat.ble PRE_first_tail_x6_r0_body.P91.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd91.nodeF i) && (Nat.blt i 17103 || Nat.ble PRE_first_tail_x6_r0_body.kd91.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord91 : (PRE_first_tail_x6_r0_body.cln91.filter (Nat.ble PRE_first_tail_x6_r0_body.P91.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd91.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd91.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd91.nodeF j) (PRE_first_tail_x6_r0_body.kd91.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow91 PRE_first_tail_x6_r0_body.cnn191 PRE_first_tail_x6_r0_body.fnordI91 PRE_first_tail_x6_r0_body.fnordK91 PRE_first_tail_x6_r0_body.fnordL91
kernel_rfl PRE_first_tail_x6_r0_body.fi91 : PRE_first_tail_x6_r0_body.cli91.all (pnB PRE_first_tail_x6_r0_body.cx0_91.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii91 : PRE_first_tail_x6_r0_body.cli91.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_91.mlx.items.get (PRE_first_tail_x6_r0_body.kappa91.node k) = (PRE_first_tail_x6_r0_body.cx0_91.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa91.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot91 (clean : Conv.NClean (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P91.NL) (cl : SSt (· < 3971) PRE_first_tail_x6_r0_body.cx0_91.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P91 3971 PRE_first_tail_x6_r0_body.kappa91 PRE_first_tail_x6_r0_body.kd91 PRE_first_tail_x6_r0_body.khinv91 PRE_first_tail_x6_r0_body.kninv91 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx PRE_first_tail_x6_r0_body.cx0_91.mlx PRE_first_tail_x6_r0_body.cx1_91.mlx (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo91 PRE_first_tail_x6_r0_body.cln91 PRE_first_tail_x6_r0_body.cli91 PRE_first_tail_x6_r0_body.cwS91 PRE_first_tail_x6_r0_body.cnS91 PRE_first_tail_x6_r0_body.ciS91 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh091, PRE_first_tail_x6_r0_body.cnh191, PRE_first_tail_x6_r0_body.cnn091, PRE_first_tail_x6_r0_body.cnn191, PRE_first_tail_x6_r0_body.cplo91, PRE_first_tail_x6_r0_body.ccnt91, PRE_first_tail_x6_r0_body.cnband91, PRE_first_tail_x6_r0_body.chbelow91, PRE_first_tail_x6_r0_body.chren91, PRE_first_tail_x6_r0_body.cband91, PRE_first_tail_x6_r0_body.cnh1pos91, PRE_first_tail_x6_r0_body.cnren91, PRE_first_tail_x6_r0_body.cnlow91, PRE_first_tail_x6_r0_body.cabs0a91, PRE_first_tail_x6_r0_body.cabs0b91, PRE_first_tail_x6_r0_body.ctok191, PRE_first_tail_x6_r0_body.cpend91, PRE_first_tail_x6_r0_body.cerrh91, PRE_first_tail_x6_r0_body.cfiles91, PRE_first_tail_x6_r0_body.carch91, PRE_first_tail_x6_r0_body.csizes91, PRE_first_tail_x6_r0_body.cwired91, PRE_first_tail_x6_r0_body.cfix91, clean, PRE_first_tail_x6_r0_body.fcxn91, PRE_first_tail_x6_r0_body.fcnn91, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle091, PRE_first_tail_x6_r0_body.fnk91, PRE_first_tail_x6_r0_body.ckA91, PRE_first_tail_x6_r0_body.cobjsK91, PRE_first_tail_x6_r0_body.cnodesK91, PRE_first_tail_x6_r0_body.citemsK91, PRE_first_tail_x6_r0_body.f1A91, PRE_first_tail_x6_r0_body.f1O91, PRE_first_tail_x6_r0_body.f1N91, PRE_first_tail_x6_r0_body.f1I91, PRE_first_tail_x6_r0_body.fbd91, PRE_first_tail_x6_r0_body.fincW91, PRE_first_tail_x6_r0_body.fincI91, PRE_first_tail_x6_r0_body.fincN91, PRE_first_tail_x6_r0_body.flnF91, PRE_first_tail_x6_r0_body.fh91, PRE_first_tail_x6_r0_body.fo91, PRE_first_tail_x6_r0_body.fok91, PRE_first_tail_x6_r0_body.fnd91, PRE_first_tail_x6_r0_body.fp91, PRE_first_tail_x6_r0_body.fnord91, PRE_first_tail_x6_r0_body.fi91, PRE_first_tail_x6_r0_body.fii91⟩
theorem PRE_first_tail_x6_r0_body.cnshift91 (clean : Conv.NClean (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P91.NL) (cl : SSt (· < 3971) PRE_first_tail_x6_r0_body.cx0_91.mlx) : NShift PRE_first_tail_x6_r0_body.P91 3971 PRE_first_tail_x6_r0_body.kappa91 PRE_first_tail_x6_r0_body.cx0_91 PRE_first_tail_x6_r0_body.cx1_91 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot91 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost91 (compact_a_eq PRE_first_tail_x6_r0_body.ckn091 PRE_first_tail_x6_r0_body.ckn191 PRE_first_tail_x6_r0_body.ckheap91 PRE_first_tail_x6_r0_body.ckpl91)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_91 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s887.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_91 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s887.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_91 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s887.ffi) = some PRE_first_tail_x6_r0_body.fxC_91
kernel_rfl PRE_first_tail_x6_r0_body.okrC_91 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s887.ffi) = some PRE_first_tail_x6_r0_body.krC_91
noncomputable def PRE_first_tail_x6_r0_body.fx0_91 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s889.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_91 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s889.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_91 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s889.ffi) = some PRE_first_tail_x6_r0_body.fx0_91
kernel_rfl PRE_first_tail_x6_r0_body.okr0_91 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s889.ffi) = some PRE_first_tail_x6_r0_body.kr0_91
noncomputable def PRE_first_tail_x6_r0_body.fx1_91 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s888.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_91 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s888.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_91 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s888.ffi) = some PRE_first_tail_x6_r0_body.fx1_91
kernel_rfl PRE_first_tail_x6_r0_body.okr1_91 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s888.ffi) = some PRE_first_tail_x6_r0_body.kr1_91
kernel_rfl PRE_first_tail_x6_r0_body.ff091 : PRE_first_tail_x6_r0_body.fx0_91 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_91 (PRE_first_tail_x6_r0_body.clo91.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_91.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff191 : PRE_first_tail_x6_r0_body.fx1_91 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_91 (PRE_first_tail_x6_r0_body.cwS91.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_91.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck91 : freedLB PRE_first_tail_x6_r0_body.kappa91 PRE_first_tail_x6_r0_body.cx0_91.mlx PRE_first_tail_x6_r0_body.fx0_91 PRE_first_tail_x6_r0_body.fx1_91 PRE_first_tail_x6_r0_body.clo91 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf091 : PRE_first_tail_x6_r0_body.kr0_91.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_91.flags (PRE_first_tail_x6_r0_body.clo91.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_91.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt091 : PRE_first_tail_x6_r0_body.kr0_91.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_91.targs (PRE_first_tail_x6_r0_body.clo91.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_91.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf191 : PRE_first_tail_x6_r0_body.kr1_91.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_91.flags (PRE_first_tail_x6_r0_body.cwS91.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_91.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt191 : PRE_first_tail_x6_r0_body.kr1_91.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_91.targs (PRE_first_tail_x6_r0_body.cwS91.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_91.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck91 : krecLB PRE_first_tail_x6_r0_body.kappa91 3971 PRE_first_tail_x6_r0_body.cx0_91.mlx PRE_first_tail_x6_r0_body.kr0_91 PRE_first_tail_x6_r0_body.kr1_91 PRE_first_tail_x6_r0_body.clo91 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn91 : Nat.ble 3971 3971 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge91 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s888.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s889.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR91 : pendRegB PRE_first_tail_x6_r0_body.kappa91 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s889.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe91 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s889.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s888.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift91 (clean : Conv.NClean (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P91.NL) (cl : SSt (· < 3971) PRE_first_tail_x6_r0_body.cx0_91.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_91.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_91.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_91.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s887.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_91.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P91 3971 PRE_first_tail_x6_r0_body.kappa91 PRE_first_tail_x6_r0_body.s889.ffi PRE_first_tail_x6_r0_body.s888.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift91 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue91, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp91 t ht),
    PRE_first_tail_x6_r0_body.cbridge91,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s889.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s888.ffi) (PRE_first_tail_x6_r0_body.cfoot91 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_91 PRE_first_tail_x6_r0_body.ofx1_91 hobjC PRE_first_tail_x6_r0_body.ff091 PRE_first_tail_x6_r0_body.ff191 PRE_first_tail_x6_r0_body.ffck91,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s889.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s888.ffi) (PRE_first_tail_x6_r0_body.cfoot91 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_91 PRE_first_tail_x6_r0_body.okr1_91 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn91) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf091 PRE_first_tail_x6_r0_body.fkt091 PRE_first_tail_x6_r0_body.fkf191 PRE_first_tail_x6_r0_body.fkt191 PRE_first_tail_x6_r0_body.fkck91,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh091 PRE_first_tail_x6_r0_body.cnh191 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe91) PRE_first_tail_x6_r0_body.cpendR91⟩

end Host.Load.Run.Tpl
end

section -- st91/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st91 0
host_stream_state PRE_first_tail_x6_r0_body.st91 1
host_stream_state PRE_first_tail_x6_r0_body.st91 2
end Host.Load.Run.Tpl
end

section -- Site91
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 91 of chain `PRE_first_tail_x6_r0_body`: `rowBlocks__g91__g92` (`rowBlocks`), the call state `PRE_first_tail_x6_r0_body.s887`, the merged state `PRE_first_tail_x6_r0_body.s888`,
the site template `PRE_first_tail_x6_r0_body.st91` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s889`: the merge.
The footprint's facts are in `SiteF91`, the compaction's in `SiteC91`, `SiteK91`, `SiteNa91`, `SiteNb91`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso91 : PRE_first_tail_x6_r0_body.st91.s0 = { PRE_first_tail_x6_r0_body.s887 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs91 : List Frame := PRE_first_tail_x6_r0_body.s887.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_91 : PRE_first_tail_x6_r0_body.S887.tab.length = 3971
kernel_rfl PRE_first_tail_x6_r0_body.tab0_91 : PRE_first_tail_x6_r0_body.st91.S0.tab = PRE_first_tail_x6_r0_body.S887.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws91 : List Nat := [2556, 2557]
kernel_rfl PRE_first_tail_x6_r0_body.fresh91 : (PRE_first_tail_x6_r0_body.S887.tab.all fun e => PRE_first_tail_x6_r0_body.ws91.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S887.oracle.all fun q => PRE_first_tail_x6_r0_body.ws91.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab91 : PRE_first_tail_x6_r0_body.S888.tab = PRE_first_tail_x6_r0_body.S887.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws91
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen91 : PRE_first_tail_x6_r0_body.st91.S2.tab.length - PRE_first_tail_x6_r0_body.st91.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged91`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap91 : PRE_first_tail_x6_r0_body.s888.heap = PRE_first_tail_x6_r0_body.st91.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext91 : PRE_first_tail_x6_r0_body.s888.next = PRE_first_tail_x6_r0_body.st91.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl91 : PRE_first_tail_x6_r0_body.s888.ctl = PRE_first_tail_x6_r0_body.st91.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack91 : PRE_first_tail_x6_r0_body.s888.stack = PRE_first_tail_x6_r0_body.st91.s2.stack ++ PRE_first_tail_x6_r0_body.s887.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs91 : PRE_first_tail_x6_r0_body.s888.jobs = PRE_first_tail_x6_r0_body.st91.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi91 : PRE_first_tail_x6_r0_body.s888.ffi = PRE_first_tail_x6_r0_body.st91.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace91 : PRE_first_tail_x6_r0_body.s888.trace = PRE_first_tail_x6_r0_body.st91.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores91 : PRE_first_tail_x6_r0_body.s888.stores = PRE_first_tail_x6_r0_body.st91.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD91
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 91 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived91 : PRE_first_tail_x6_r0_body.nr91.map (fun r => nth? PRE_first_tail_x6_r0_body.st91.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo91 : PRE_first_tail_x6_r0_body.nr91.all (Nat.ble 3971) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj91 : PRE_first_tail_x6_r0_body.cws91.all (fun c => !PRE_first_tail_x6_r0_body.ws91.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ91 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws91 PRE_first_tail_x6_r0_body.crs91 PRE_first_tail_x6_r0_body.ws91

end Host.Load.Run.Tpl
end

section -- st91/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st91`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st91.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st91.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st91.s2.heap PRE_first_tail_x6_r0_body.st91.wrR ++ freshOf PRE_first_tail_x6_r0_body.st91.s2.heap PRE_first_tail_x6_r0_body.st91.s0.next PRE_first_tail_x6_r0_body.st91.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st91.wr : List Nat := PRE_first_tail_x6_r0_body.st91.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st91.heapFoot : PRE_first_tail_x6_r0_body.st91.s2.heap = setAll PRE_first_tail_x6_r0_body.st91.s0.heap PRE_first_tail_x6_r0_body.st91.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st91.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st91.s0.next PRE_first_tail_x6_r0_body.st91.s2.next = true
theorem PRE_first_tail_x6_r0_body.st91.grows : PRE_first_tail_x6_r0_body.st91.s0.next ≤ PRE_first_tail_x6_r0_body.st91.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st91.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st91.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st91.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st91.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st91.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st91.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st91.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st91.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st91.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st91.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st91.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st91.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st91.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st91.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st91.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st91.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st91.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st91.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st91.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st91.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st91.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st91.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st91.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st91.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st91.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st91.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st91.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st91.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st91.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st91.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st91.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st91.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF91
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 91 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB91 : nodupT PRE_first_tail_x6_r0_body.st91.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup91 : PRE_first_tail_x6_r0_body.st91.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB91).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB91 : PRE_first_tail_x6_r0_body.st91.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound91 : ∀ b ∈ PRE_first_tail_x6_r0_body.st91.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB91 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr91 := PRE_first_tail_x6_r0_body.st91.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq91 : PRE_first_tail_x6_r0_body.st91.s2.trace = PRE_first_tail_x6_r0_body.trFr91 ++ PRE_first_tail_x6_r0_body.st91.s0.trace
theorem PRE_first_tail_x6_r0_body.trace91 : ∃ fr, PRE_first_tail_x6_r0_body.st91.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st91.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq91⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide91 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB91 : (PRE_first_tail_x6_r0_body.wide91.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st91.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix91 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide91, WFix Map.id (Present PRE_first_tail_x6_r0_body.st91.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB91 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL91
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 91 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s888`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO91 : PRE_first_tail_x6_r0_body.st91.S0.oracle = PRE_first_tail_x6_r0_body.st91.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B91 : PRE_first_tail_x6_r0_body.st91.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st91.s0.next || (PRE_first_tail_x6_r0_body.st91.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot91 : Conv.StageFoot PRE_first_tail_x6_r0_body.st91.wr PRE_first_tail_x6_r0_body.st91.s0 PRE_first_tail_x6_r0_body.st91.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st91.heapFoot PRE_first_tail_x6_r0_body.wrNodup91 PRE_first_tail_x6_r0_body.wrBound91 PRE_first_tail_x6_r0_body.wr0B91 PRE_first_tail_x6_r0_body.st91.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged91 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st91.F.S → PRE_first_tail_x6_r0_body.st91.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st91.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st91.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs91 PRE_first_tail_x6_r0_body.st91.wr PRE_first_tail_x6_r0_body.s887 PRE_first_tail_x6_r0_body.st91.s2 PRE_first_tail_x6_r0_body.st91.s0
      PRE_first_tail_x6_r0_body.st91.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st91.F FR W stk M ν K PRE_first_tail_x6_r0_body.s888 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso91 PRE_first_tail_x6_r0_body.stFoot91 PRE_first_tail_x6_r0_body.wrNodup91 PRE_first_tail_x6_r0_body.wrBound91 PRE_first_tail_x6_r0_body.trace91 PRE_first_tail_x6_r0_body.mheap91
    PRE_first_tail_x6_r0_body.mnext91 PRE_first_tail_x6_r0_body.mctl91 PRE_first_tail_x6_r0_body.mstack91 PRE_first_tail_x6_r0_body.mjobs91 PRE_first_tail_x6_r0_body.mffi91 PRE_first_tail_x6_r0_body.mtrace91 PRE_first_tail_x6_r0_body.mstores91 h

def PRE_first_tail_x6_r0_body.arrEl91_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE91_2665 : arrOf PRE_first_tail_x6_r0_body.s888 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl91_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA91_2665 : isArrB PRE_first_tail_x6_r0_body.s888 2665 = true
theorem PRE_first_tail_x6_r0_body.arr91_2665 : ∃ o, PRE_first_tail_x6_r0_body.s888.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl91_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE91_2665 PRE_first_tail_x6_r0_body.arrA91_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN91_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl91_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR91_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl91_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN91_2665

def PRE_first_tail_x6_r0_body.arrEl91_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE91_2673467 : arrOf PRE_first_tail_x6_r0_body.s888 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl91_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA91_2673467 : isArrB PRE_first_tail_x6_r0_body.s888 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr91_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s888.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl91_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE91_2673467 PRE_first_tail_x6_r0_body.arrA91_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN91_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl91_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR91_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl91_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN91_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k91 : isArrB PRE_first_tail_x6_r0_body.s888 4910 = false
theorem PRE_first_tail_x6_r0_body.keep91 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s888 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k91 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr91_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl91_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ91
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 91 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s887`, the merged
state `PRE_first_tail_x6_r0_body.s888`, the canonical state `PRE_first_tail_x6_r0_body.s889`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl91 : PRE_first_tail_x6_r0_body.pl91.all (Nat.ble PRE_first_tail_x6_r0_body.s887.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd91 : nodupT PRE_first_tail_x6_r0_body.pl91 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn191 : Nat.ble PRE_first_tail_x6_r0_body.s887.next 2746385 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst91 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s887.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn91 : PRE_first_tail_x6_r0_body.s889.next = PRE_first_tail_x6_r0_body.s887.next + PRE_first_tail_x6_r0_body.pl91.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn91 : PRE_first_tail_x6_r0_body.s888.next = 2746385
kernel_rfl PRE_first_tail_x6_r0_body.zgrow91 : Nat.ble PRE_first_tail_x6_r0_body.s889.next PRE_first_tail_x6_r0_body.s888.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh91 : PRE_first_tail_x6_r0_body.S887.tab.all (fun e => PRE_first_tail_x6_r0_body.cws91.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd91 : nodupT PRE_first_tail_x6_r0_body.cws91 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi91 : PRE_first_tail_x6_r0_body.nr91.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S888.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt91 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s887.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg91_2665 : PRE_first_tail_x6_r0_body.s889.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s889 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk91_2665 : (objOf PRE_first_tail_x6_r0_body.s889 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm91_2665 : PRE_first_tail_x6_r0_body.s888.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa91.obj (objOf PRE_first_tail_x6_r0_body.s889 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s888 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg91_2673467 : PRE_first_tail_x6_r0_body.s889.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s889 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk91_2673467 : (objOf PRE_first_tail_x6_r0_body.s889 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm91_2673467 : PRE_first_tail_x6_r0_body.s888.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa91.obj (objOf PRE_first_tail_x6_r0_body.s889 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s888 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw91_4910 : (PRE_first_tail_x6_r0_body.s889.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw91_2673472 : (PRE_first_tail_x6_r0_body.s889.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw91_2673473 : (PRE_first_tail_x6_r0_body.s889.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd91 : PRE_first_tail_x6_r0_body.cl91.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr91 : PRE_first_tail_x6_r0_body.st91.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s887.next || PRE_first_tail_x6_r0_body.cl91.contains b) = true
def PRE_first_tail_x6_r0_body.zl91 : List Nat := PRE_first_tail_x6_r0_body.cl91.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE91 : PRE_first_tail_x6_r0_body.zl91.map (fun a => PRE_first_tail_x6_r0_body.s888.heap.get (PRE_first_tail_x6_r0_body.kappa91.a a)) = PRE_first_tail_x6_r0_body.zl91.map (fun a => (PRE_first_tail_x6_r0_body.s889.heap.get a).map PRE_first_tail_x6_r0_body.kappa91.hobj)
theorem PRE_first_tail_x6_r0_body.zimg91 : HeapImg PRE_first_tail_x6_r0_body.kappa91 PRE_first_tail_x6_r0_body.s889 PRE_first_tail_x6_r0_body.s888 PRE_first_tail_x6_r0_body.zl91 := PRE_first_tail_x6_r0_body.zimgE91
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl91 : PRE_first_tail_x6_r0_body.s888.ctl = PRE_first_tail_x6_r0_body.kappa91.ctl PRE_first_tail_x6_r0_body.s889.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack91 : PRE_first_tail_x6_r0_body.s888.stack = PRE_first_tail_x6_r0_body.s889.stack.map PRE_first_tail_x6_r0_body.kappa91.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs91 : PRE_first_tail_x6_r0_body.s888.jobs = PRE_first_tail_x6_r0_body.s889.jobs.map PRE_first_tail_x6_r0_body.kappa91.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores91 : PRE_first_tail_x6_r0_body.s888.stores = PRE_first_tail_x6_r0_body.kappa91.stores PRE_first_tail_x6_r0_body.s889.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots91 : checkRootsSupp PRE_first_tail_x6_r0_body.s889 3971 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC91 : PRE_first_tail_x6_r0_body.S887.tab.length + PRE_first_tail_x6_r0_body.cws91.length = 3971
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap91 : PRE_first_tail_x6_r0_body.kappa91 = Conv.Map.compact PRE_first_tail_x6_r0_body.s887.next 2746385 PRE_first_tail_x6_r0_body.S887.tab.length PRE_first_tail_x6_r0_body.pl91 (PRE_first_tail_x6_r0_body.nr91.map NumV.ref) PRE_first_tail_x6_r0_body.kd91.big
  PRE_first_tail_x6_r0_body.kd91.region PRE_first_tail_x6_r0_body.kd91.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin91 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s889.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc91 : Conv.jcleanListB (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s889 PRE_first_tail_x6_r0_body.cl91 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB91 : noBigRootsP (fun i => !Conv.oldBigB (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s889.trace PRE_first_tail_x6_r0_body.s889 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm91 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 17103 = true
theorem PRE_first_tail_x6_r0_body.cjcl91 (h : Conv.JClean (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s887) : Conv.JClean (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s889 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle91)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap91 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd91 a ha)) PRE_first_tail_x6_r0_body.zjc91

end Host.Load.Run.Tpl
end

section -- st91/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st91.bodyLast from PRE_first_tail_x6_r0_body.st91.s1 to PRE_first_tail_x6_r0_body.st91.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st91.F PRE_first_tail_x6_r0_body.st91.s1).run PRE_first_tail_x6_r0_body.st91.S1 = some (PRE_first_tail_x6_r0_body.st91.s2, PRE_first_tail_x6_r0_body.st91.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st91.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st91.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st91.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st91.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st91/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st91.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st91.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st91.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st91.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st91.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st91.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st91.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st91.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st91.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st91.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st91.s0 PRE_first_tail_x6_r0_body.st91.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st91.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st91.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st91.s1 PRE_first_tail_x6_r0_body.st91.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st91/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st91.bodyK0F from PRE_first_tail_x6_r0_body.st91.s0 to PRE_first_tail_x6_r0_body.st91.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st91.F (PRE_first_tail_x6_r0_body.st91.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st91.ks 0).getD 0) PRE_first_tail_x6_r0_body.st91.s0 PRE_first_tail_x6_r0_body.st91.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st91.s1, PRE_first_tail_x6_r0_body.st91.S1)
theorem PRE_first_tail_x6_r0_body.st91.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st91.F (PRE_first_tail_x6_r0_body.st91.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st91.ks 0).getD 0) PRE_first_tail_x6_r0_body.st91.s0 PRE_first_tail_x6_r0_body.st91.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st91.s1, PRE_first_tail_x6_r0_body.st91.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st91.bodyOkLN_ok PRE_first_tail_x6_r0_body.st91.bodyK0F
end Host.Load.Run.Tpl
end

section -- st91/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st91.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st91.F (PRE_first_tail_x6_r0_body.st91.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st91.s0 PRE_first_tail_x6_r0_body.st91.S0 = some (PRE_first_tail_x6_r0_body.st91.s1, PRE_first_tail_x6_r0_body.st91.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st91.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st91.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st91.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st91.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st91.F (PRE_first_tail_x6_r0_body.st91.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st91.s0
  S0 := PRE_first_tail_x6_r0_body.st91.S0
  s1 := PRE_first_tail_x6_r0_body.st91.s1
  S1 := PRE_first_tail_x6_r0_body.st91.S1
  s2 := PRE_first_tail_x6_r0_body.st91.s2
  S2 := PRE_first_tail_x6_r0_body.st91.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st91.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st91.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st91.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st91.bodyHalt
  last := PRE_first_tail_x6_r0_body.st91.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st91.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC92
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 92 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s893` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa92` into the merged state
`PRE_first_tail_x6_r0_body.s892`. -/

def PRE_first_tail_x6_r0_body.pl92 : List Nat := [2746681]
def PRE_first_tail_x6_r0_body.nr92 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd92 : RData :=
  ⟨2746672, 2746682, Stage.setAll PTrie.nil [(2746671, 2746681)], Stage.setAll PTrie.nil [],
   20005, 20005, 17107, 17107, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa92 : Map :=
  Conv.Map.compact 2746671 2746682 3988 PRE_first_tail_x6_r0_body.pl92 (PRE_first_tail_x6_r0_body.nr92.map NumV.ref) PRE_first_tail_x6_r0_body.kd92.big
    PRE_first_tail_x6_r0_body.kd92.region PRE_first_tail_x6_r0_body.kd92.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws92 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs92 : List SymE := PRE_first_tail_x6_r0_body.nr92.map fun r => (nth? PRE_first_tail_x6_r0_body.S892.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta92 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws92 PRE_first_tail_x6_r0_body.crs92
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB92 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab92 : PRE_first_tail_x6_r0_body.S893.tab = PRE_first_tail_x6_r0_body.S891.tab ++ PRE_first_tail_x6_r0_body.cws92.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace92 : PRE_first_tail_x6_r0_body.s893.trace = PRE_first_tail_x6_r0_body.s891.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext92 : PRE_first_tail_x6_r0_body.s893.next = 2746672
kernel_rfl PRE_first_tail_x6_r0_body.ccounters92 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s893.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s893.ffi).mlx.nnext) = (20005, 17107)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue92 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s892.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s893.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa92.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp92 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s893.ffi).mlx.tokens.all (bSN 3988) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean92 : Conv.cleanListB 20005 131072 (fun r => Nat.ble 80020 r) PRE_first_tail_x6_r0_body.s893
    (PRE_first_tail_x6_r0_body.wrB92 ++ (List.range 1).map (2746671 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs92 : bigsOutB 20005 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s893.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK92
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl92`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl92 : List Nat := [2665, 2673467, 2746671]
def PRE_first_tail_x6_r0_body.clo92 : List Nat := []
def PRE_first_tail_x6_r0_body.cln92 : List Nat := []
def PRE_first_tail_x6_r0_body.cli92 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap92 : PRE_first_tail_x6_r0_body.s893.heap = Stage.setAll PRE_first_tail_x6_r0_body.s891.heap (PRE_first_tail_x6_r0_body.cl92.filterMap fun a => (PRE_first_tail_x6_r0_body.s893.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe92 : Nat.ble PRE_first_tail_x6_r0_body.s891.next PRE_first_tail_x6_r0_body.s893.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP92 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s891 PRE_first_tail_x6_r0_body.s893 PRE_first_tail_x6_r0_body.cl92 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp92 : Conv.suppListB PRE_first_tail_x6_r0_body.s893 3988 PRE_first_tail_x6_r0_body.cl92 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound92 : Conv.boundListB PRE_first_tail_x6_r0_body.s893 PRE_first_tail_x6_r0_body.cl92 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK92 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s893.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln92.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s893.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK92 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s893.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo92.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s893.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK92 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s893.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli92.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s893.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst92 : Conv.sstListB 3988 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s893.ffi).mlx PRE_first_tail_x6_r0_body.cln92 PRE_first_tail_x6_r0_body.clo92 PRE_first_tail_x6_r0_body.cli92 = true

end Host.Load.Run.Tpl
end

section -- SiteCl92
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA92 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s893.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo92.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s893.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd92 : (PRE_first_tail_x6_r0_body.clo92 ++ PRE_first_tail_x6_r0_body.cln92 ++ PRE_first_tail_x6_r0_body.cli92).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle92 : Conv.Cnt.leB (⟨20005, 17107, 2746671, 3988⟩ : Conv.Cnt) (⟨20005, 17107, 2746672, 3988⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck92 : Conv.ncleanListB (⟨20005, 17107, 2746672, 3988⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s893.ffi).mlx PRE_first_tail_x6_r0_body.clo92 PRE_first_tail_x6_r0_body.cln92 PRE_first_tail_x6_r0_body.cli92 = true
theorem PRE_first_tail_x6_r0_body.cncl92 (h : Conv.NClean (⟨20005, 17107, 2746671, 3988⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx) : Conv.NClean (⟨20005, 17107, 2746672, 3988⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s893.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle92 PRE_first_tail_x6_r0_body.ckA92 PRE_first_tail_x6_r0_body.cobjsK92 PRE_first_tail_x6_r0_body.cnodesK92 PRE_first_tail_x6_r0_body.citemsK92 PRE_first_tail_x6_r0_body.cbd92 PRE_first_tail_x6_r0_body.cck92

end Host.Load.Run.Tpl
end

section -- SiteS92
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 92 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc92 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P92 : LoadP := PRE_first_tail_x6_r0_body.Pc92.raise 17107
kernel_rfl PRE_first_tail_x6_r0_body.craise92 : Nat.ble PRE_first_tail_x6_r0_body.Pc92.N0 17107 = true
theorem PRE_first_tail_x6_r0_body.raised92 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc92 PRE_first_tail_x6_r0_body.P92 :=
  .inr ⟨17107, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise92, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_92 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s893.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_92 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s892.ffi)
def PRE_first_tail_x6_r0_body.khinv92 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv92 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS92 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS92 : List Nat := List.range' 17107 0
def PRE_first_tail_x6_r0_body.ciS92 : List Nat := [] ++ List.range' 17107 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh092 : PRE_first_tail_x6_r0_body.kd92.nh0 = PRE_first_tail_x6_r0_body.cx0_92.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh192 : PRE_first_tail_x6_r0_body.kd92.nh1 = PRE_first_tail_x6_r0_body.cx1_92.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn092 : PRE_first_tail_x6_r0_body.kd92.nn0 = PRE_first_tail_x6_r0_body.cx0_92.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn192 : PRE_first_tail_x6_r0_body.kd92.nn1 = PRE_first_tail_x6_r0_body.cx1_92.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo92 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P92.lo && Nat.ble PRE_first_tail_x6_r0_body.P92.lo PRE_first_tail_x6_r0_body.cx0_92.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P92.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P92.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt92 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_92.mlx.next PRE_first_tail_x6_r0_body.cx1_92.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_92.mlx.nnext PRE_first_tail_x6_r0_body.cx1_92.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband92 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P92.NL && Nat.ble PRE_first_tail_x6_r0_body.P92.NL PRE_first_tail_x6_r0_body.P92.N0 && Nat.ble PRE_first_tail_x6_r0_body.P92.N0 PRE_first_tail_x6_r0_body.cx0_92.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow92 : PRE_first_tail_x6_r0_body.kd92.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren92 : checkRenG PRE_first_tail_x6_r0_body.kd92.hnd PRE_first_tail_x6_r0_body.khinv92 (phB PRE_first_tail_x6_r0_body.cx0_92.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband92 : PRE_first_tail_x6_r0_body.kd92.checkBand PRE_first_tail_x6_r0_body.P92.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos92 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd92.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren92 : checkRenG PRE_first_tail_x6_r0_body.kd92.node PRE_first_tail_x6_r0_body.kninv92 (pnB PRE_first_tail_x6_r0_body.cx0_92.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow92 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd92.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P92.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd92.nodeF j) PRE_first_tail_x6_r0_body.cx1_92.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a92 : PRE_first_tail_x6_r0_body.cx0_92.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b92 : PRE_first_tail_x6_r0_body.cx0_92.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok192 : PRE_first_tail_x6_r0_body.cx1_92.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend92 : PRE_first_tail_x6_r0_body.cx1_92.mlx.pending = PRE_first_tail_x6_r0_body.cx0_92.mlx.pending.map PRE_first_tail_x6_r0_body.kappa92.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh92 : PRE_first_tail_x6_r0_body.cx1_92.mlx.errh = PRE_first_tail_x6_r0_body.cx0_92.mlx.errh.map PRE_first_tail_x6_r0_body.kappa92.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles92 : PRE_first_tail_x6_r0_body.cx1_92.mlx.files = PRE_first_tail_x6_r0_body.cx0_92.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch92 : PRE_first_tail_x6_r0_body.cx1_92.mlx.arch = PRE_first_tail_x6_r0_body.cx0_92.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes92 : PRE_first_tail_x6_r0_body.cx1_92.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_92.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired92 : PRE_first_tail_x6_r0_body.cx1_92.mlx.wired = PRE_first_tail_x6_r0_body.cx0_92.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost92 : PRE_first_tail_x6_r0_body.cx1_92.host = PRE_first_tail_x6_r0_body.cx0_92.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd92`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn092 : PRE_first_tail_x6_r0_body.kd92.n0 = 2746672
kernel_rfl PRE_first_tail_x6_r0_body.ckn192 : PRE_first_tail_x6_r0_body.kd92.n1 = 2746682
kernel_rfl PRE_first_tail_x6_r0_body.ckheap92 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd92.heap).all (fun x => Nat.ble 2746671 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl92 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd92.heap.get (2746671 + j) = nth? PRE_first_tail_x6_r0_body.pl92 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja92 : Nat.ble 2746671 2746671 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn92 : Nat.ble 3988 3988 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD92 : Nat.ble 2746671 PRE_first_tail_x6_r0_body.kd92.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn92 : Nat.ble 20005 PRE_first_tail_x6_r0_body.kd92.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn92 : Nat.ble 17107 PRE_first_tail_x6_r0_body.kd92.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb92 : Nat.ble 20005 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap92 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd92.heap).all (Nat.ble (⟨20005, 17107, 2746671, 3988⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd92 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd92.hnd).all (Nat.ble (⟨20005, 17107, 2746671, 3988⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode92 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd92.node).all (Nat.ble (⟨20005, 17107, 2746671, 3988⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix92 : Conv.FixOld (⟨20005, 17107, 2746671, 3988⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa92 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja92) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn92) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD92) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn92) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn92) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb92) PRE_first_tail_x6_r0_body.fheap92 PRE_first_tail_x6_r0_body.fhnd92 PRE_first_tail_x6_r0_body.fnode92
kernel_rfl PRE_first_tail_x6_r0_body.fcxn92 : (⟨20005, 17107, 2746671, 3988⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn92 : (⟨20005, 17107, 2746671, 3988⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle092 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_92.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_92.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk92 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd92.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A92 : PRE_first_tail_x6_r0_body.cx1_92.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS92.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_92.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O92 : PRE_first_tail_x6_r0_body.cx1_92.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS92.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_92.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N92 : PRE_first_tail_x6_r0_body.cx1_92.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS92.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_92.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I92 : PRE_first_tail_x6_r0_body.cx1_92.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS92.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_92.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd92 : (PRE_first_tail_x6_r0_body.clo92 ++ PRE_first_tail_x6_r0_body.cln92 ++ PRE_first_tail_x6_r0_body.cli92 ++ PRE_first_tail_x6_r0_body.cwS92 ++ PRE_first_tail_x6_r0_body.cnS92 ++ PRE_first_tail_x6_r0_body.ciS92).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW92 : PRE_first_tail_x6_r0_body.cwS92.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo92.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI92 : PRE_first_tail_x6_r0_body.ciS92.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli92.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN92 : PRE_first_tail_x6_r0_body.cnS92.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF92 : PRE_first_tail_x6_r0_body.cln92.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh92 : PRE_first_tail_x6_r0_body.clo92.all (handleOK PRE_first_tail_x6_r0_body.kappa92 PRE_first_tail_x6_r0_body.P92.lo PRE_first_tail_x6_r0_body.cx0_92.mlx PRE_first_tail_x6_r0_body.cx1_92.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo92 : PRE_first_tail_x6_r0_body.clo92.map (fun h => PRE_first_tail_x6_r0_body.cx1_92.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa92.handle h)) = PRE_first_tail_x6_r0_body.clo92.map (fun h => (PRE_first_tail_x6_r0_body.cx0_92.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa92.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok92 : PRE_first_tail_x6_r0_body.clo92.all (objOK PRE_first_tail_x6_r0_body.kappa92 PRE_first_tail_x6_r0_body.P92.NL PRE_first_tail_x6_r0_body.cx0_92.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd92 : PRE_first_tail_x6_r0_body.cln92.all (nodeOKF PRE_first_tail_x6_r0_body.kappa92 PRE_first_tail_x6_r0_body.P92 PRE_first_tail_x6_r0_body.cx0_92.mlx PRE_first_tail_x6_r0_body.cx1_92.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp92 : ((PRE_first_tail_x6_r0_body.cln92.filter (fullB PRE_first_tail_x6_r0_body.P92))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_92.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa92.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln92.filter (fullB PRE_first_tail_x6_r0_body.P92))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_92.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa92.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI92 : incrB PRE_first_tail_x6_r0_body.kd92.nodeF (List.range' 17107 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK92 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd92.node).all (fun k => Nat.ble 17107 k && Nat.blt k 17107) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL92 : (PRE_first_tail_x6_r0_body.cln92.filter (Nat.ble PRE_first_tail_x6_r0_body.P92.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd92.nodeF i) && (Nat.blt i 17107 || Nat.ble PRE_first_tail_x6_r0_body.kd92.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord92 : (PRE_first_tail_x6_r0_body.cln92.filter (Nat.ble PRE_first_tail_x6_r0_body.P92.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd92.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd92.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd92.nodeF j) (PRE_first_tail_x6_r0_body.kd92.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow92 PRE_first_tail_x6_r0_body.cnn192 PRE_first_tail_x6_r0_body.fnordI92 PRE_first_tail_x6_r0_body.fnordK92 PRE_first_tail_x6_r0_body.fnordL92
kernel_rfl PRE_first_tail_x6_r0_body.fi92 : PRE_first_tail_x6_r0_body.cli92.all (pnB PRE_first_tail_x6_r0_body.cx0_92.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii92 : PRE_first_tail_x6_r0_body.cli92.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_92.mlx.items.get (PRE_first_tail_x6_r0_body.kappa92.node k) = (PRE_first_tail_x6_r0_body.cx0_92.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa92.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot92 (clean : Conv.NClean (⟨20005, 17107, 2746671, 3988⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P92.NL) (cl : SSt (· < 3988) PRE_first_tail_x6_r0_body.cx0_92.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P92 3988 PRE_first_tail_x6_r0_body.kappa92 PRE_first_tail_x6_r0_body.kd92 PRE_first_tail_x6_r0_body.khinv92 PRE_first_tail_x6_r0_body.kninv92 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx PRE_first_tail_x6_r0_body.cx0_92.mlx PRE_first_tail_x6_r0_body.cx1_92.mlx (⟨20005, 17107, 2746671, 3988⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo92 PRE_first_tail_x6_r0_body.cln92 PRE_first_tail_x6_r0_body.cli92 PRE_first_tail_x6_r0_body.cwS92 PRE_first_tail_x6_r0_body.cnS92 PRE_first_tail_x6_r0_body.ciS92 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh092, PRE_first_tail_x6_r0_body.cnh192, PRE_first_tail_x6_r0_body.cnn092, PRE_first_tail_x6_r0_body.cnn192, PRE_first_tail_x6_r0_body.cplo92, PRE_first_tail_x6_r0_body.ccnt92, PRE_first_tail_x6_r0_body.cnband92, PRE_first_tail_x6_r0_body.chbelow92, PRE_first_tail_x6_r0_body.chren92, PRE_first_tail_x6_r0_body.cband92, PRE_first_tail_x6_r0_body.cnh1pos92, PRE_first_tail_x6_r0_body.cnren92, PRE_first_tail_x6_r0_body.cnlow92, PRE_first_tail_x6_r0_body.cabs0a92, PRE_first_tail_x6_r0_body.cabs0b92, PRE_first_tail_x6_r0_body.ctok192, PRE_first_tail_x6_r0_body.cpend92, PRE_first_tail_x6_r0_body.cerrh92, PRE_first_tail_x6_r0_body.cfiles92, PRE_first_tail_x6_r0_body.carch92, PRE_first_tail_x6_r0_body.csizes92, PRE_first_tail_x6_r0_body.cwired92, PRE_first_tail_x6_r0_body.cfix92, clean, PRE_first_tail_x6_r0_body.fcxn92, PRE_first_tail_x6_r0_body.fcnn92, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle092, PRE_first_tail_x6_r0_body.fnk92, PRE_first_tail_x6_r0_body.ckA92, PRE_first_tail_x6_r0_body.cobjsK92, PRE_first_tail_x6_r0_body.cnodesK92, PRE_first_tail_x6_r0_body.citemsK92, PRE_first_tail_x6_r0_body.f1A92, PRE_first_tail_x6_r0_body.f1O92, PRE_first_tail_x6_r0_body.f1N92, PRE_first_tail_x6_r0_body.f1I92, PRE_first_tail_x6_r0_body.fbd92, PRE_first_tail_x6_r0_body.fincW92, PRE_first_tail_x6_r0_body.fincI92, PRE_first_tail_x6_r0_body.fincN92, PRE_first_tail_x6_r0_body.flnF92, PRE_first_tail_x6_r0_body.fh92, PRE_first_tail_x6_r0_body.fo92, PRE_first_tail_x6_r0_body.fok92, PRE_first_tail_x6_r0_body.fnd92, PRE_first_tail_x6_r0_body.fp92, PRE_first_tail_x6_r0_body.fnord92, PRE_first_tail_x6_r0_body.fi92, PRE_first_tail_x6_r0_body.fii92⟩
theorem PRE_first_tail_x6_r0_body.cnshift92 (clean : Conv.NClean (⟨20005, 17107, 2746671, 3988⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P92.NL) (cl : SSt (· < 3988) PRE_first_tail_x6_r0_body.cx0_92.mlx) : NShift PRE_first_tail_x6_r0_body.P92 3988 PRE_first_tail_x6_r0_body.kappa92 PRE_first_tail_x6_r0_body.cx0_92 PRE_first_tail_x6_r0_body.cx1_92 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot92 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost92 (compact_a_eq PRE_first_tail_x6_r0_body.ckn092 PRE_first_tail_x6_r0_body.ckn192 PRE_first_tail_x6_r0_body.ckheap92 PRE_first_tail_x6_r0_body.ckpl92)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_92 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s891.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_92 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s891.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_92 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s891.ffi) = some PRE_first_tail_x6_r0_body.fxC_92
kernel_rfl PRE_first_tail_x6_r0_body.okrC_92 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s891.ffi) = some PRE_first_tail_x6_r0_body.krC_92
noncomputable def PRE_first_tail_x6_r0_body.fx0_92 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s893.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_92 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s893.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_92 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s893.ffi) = some PRE_first_tail_x6_r0_body.fx0_92
kernel_rfl PRE_first_tail_x6_r0_body.okr0_92 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s893.ffi) = some PRE_first_tail_x6_r0_body.kr0_92
noncomputable def PRE_first_tail_x6_r0_body.fx1_92 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s892.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_92 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s892.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_92 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s892.ffi) = some PRE_first_tail_x6_r0_body.fx1_92
kernel_rfl PRE_first_tail_x6_r0_body.okr1_92 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s892.ffi) = some PRE_first_tail_x6_r0_body.kr1_92
kernel_rfl PRE_first_tail_x6_r0_body.ff092 : PRE_first_tail_x6_r0_body.fx0_92 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_92 (PRE_first_tail_x6_r0_body.clo92.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_92.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff192 : PRE_first_tail_x6_r0_body.fx1_92 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_92 (PRE_first_tail_x6_r0_body.cwS92.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_92.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck92 : freedLB PRE_first_tail_x6_r0_body.kappa92 PRE_first_tail_x6_r0_body.cx0_92.mlx PRE_first_tail_x6_r0_body.fx0_92 PRE_first_tail_x6_r0_body.fx1_92 PRE_first_tail_x6_r0_body.clo92 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf092 : PRE_first_tail_x6_r0_body.kr0_92.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_92.flags (PRE_first_tail_x6_r0_body.clo92.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_92.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt092 : PRE_first_tail_x6_r0_body.kr0_92.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_92.targs (PRE_first_tail_x6_r0_body.clo92.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_92.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf192 : PRE_first_tail_x6_r0_body.kr1_92.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_92.flags (PRE_first_tail_x6_r0_body.cwS92.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_92.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt192 : PRE_first_tail_x6_r0_body.kr1_92.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_92.targs (PRE_first_tail_x6_r0_body.cwS92.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_92.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck92 : krecLB PRE_first_tail_x6_r0_body.kappa92 3988 PRE_first_tail_x6_r0_body.cx0_92.mlx PRE_first_tail_x6_r0_body.kr0_92 PRE_first_tail_x6_r0_body.kr1_92 PRE_first_tail_x6_r0_body.clo92 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn92 : Nat.ble 3988 3988 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge92 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s892.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s893.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR92 : pendRegB PRE_first_tail_x6_r0_body.kappa92 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s893.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe92 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s893.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s892.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift92 (clean : Conv.NClean (⟨20005, 17107, 2746671, 3988⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P92.NL) (cl : SSt (· < 3988) PRE_first_tail_x6_r0_body.cx0_92.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_92.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_92.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_92.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s891.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_92.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20005, 17107, 2746671, 3988⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P92 3988 PRE_first_tail_x6_r0_body.kappa92 PRE_first_tail_x6_r0_body.s893.ffi PRE_first_tail_x6_r0_body.s892.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift92 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue92, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp92 t ht),
    PRE_first_tail_x6_r0_body.cbridge92,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s893.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s892.ffi) (PRE_first_tail_x6_r0_body.cfoot92 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_92 PRE_first_tail_x6_r0_body.ofx1_92 hobjC PRE_first_tail_x6_r0_body.ff092 PRE_first_tail_x6_r0_body.ff192 PRE_first_tail_x6_r0_body.ffck92,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s893.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s892.ffi) (PRE_first_tail_x6_r0_body.cfoot92 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_92 PRE_first_tail_x6_r0_body.okr1_92 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn92) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf092 PRE_first_tail_x6_r0_body.fkt092 PRE_first_tail_x6_r0_body.fkf192 PRE_first_tail_x6_r0_body.fkt192 PRE_first_tail_x6_r0_body.fkck92,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh092 PRE_first_tail_x6_r0_body.cnh192 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe92) PRE_first_tail_x6_r0_body.cpendR92⟩

end Host.Load.Run.Tpl
end

section -- st92/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st92 0
host_stream_state PRE_first_tail_x6_r0_body.st92 1
host_stream_state PRE_first_tail_x6_r0_body.st92 2
end Host.Load.Run.Tpl
end

section -- Site92
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 92 of chain `PRE_first_tail_x6_r0_body`: `plan__g92__g93` (`plan`), the call state `PRE_first_tail_x6_r0_body.s891`, the merged state `PRE_first_tail_x6_r0_body.s892`,
the site template `PRE_first_tail_x6_r0_body.st92` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s893`: the merge.
The footprint's facts are in `SiteF92`, the compaction's in `SiteC92`, `SiteK92`, `SiteNa92`, `SiteNb92`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso92 : PRE_first_tail_x6_r0_body.st92.s0 = { PRE_first_tail_x6_r0_body.s891 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs92 : List Frame := PRE_first_tail_x6_r0_body.s891.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_92 : PRE_first_tail_x6_r0_body.S891.tab.length = 3988
kernel_rfl PRE_first_tail_x6_r0_body.tab0_92 : PRE_first_tail_x6_r0_body.st92.S0.tab = PRE_first_tail_x6_r0_body.S891.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws92 : List Nat := [2558, 2559, 2560]
kernel_rfl PRE_first_tail_x6_r0_body.fresh92 : (PRE_first_tail_x6_r0_body.S891.tab.all fun e => PRE_first_tail_x6_r0_body.ws92.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S891.oracle.all fun q => PRE_first_tail_x6_r0_body.ws92.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab92 : PRE_first_tail_x6_r0_body.S892.tab = PRE_first_tail_x6_r0_body.S891.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws92
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen92 : PRE_first_tail_x6_r0_body.st92.S2.tab.length - PRE_first_tail_x6_r0_body.st92.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged92`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap92 : PRE_first_tail_x6_r0_body.s892.heap = PRE_first_tail_x6_r0_body.st92.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext92 : PRE_first_tail_x6_r0_body.s892.next = PRE_first_tail_x6_r0_body.st92.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl92 : PRE_first_tail_x6_r0_body.s892.ctl = PRE_first_tail_x6_r0_body.st92.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack92 : PRE_first_tail_x6_r0_body.s892.stack = PRE_first_tail_x6_r0_body.st92.s2.stack ++ PRE_first_tail_x6_r0_body.s891.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs92 : PRE_first_tail_x6_r0_body.s892.jobs = PRE_first_tail_x6_r0_body.st92.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi92 : PRE_first_tail_x6_r0_body.s892.ffi = PRE_first_tail_x6_r0_body.st92.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace92 : PRE_first_tail_x6_r0_body.s892.trace = PRE_first_tail_x6_r0_body.st92.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores92 : PRE_first_tail_x6_r0_body.s892.stores = PRE_first_tail_x6_r0_body.st92.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD92
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 92 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived92 : PRE_first_tail_x6_r0_body.nr92.map (fun r => nth? PRE_first_tail_x6_r0_body.st92.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo92 : PRE_first_tail_x6_r0_body.nr92.all (Nat.ble 3988) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj92 : PRE_first_tail_x6_r0_body.cws92.all (fun c => !PRE_first_tail_x6_r0_body.ws92.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ92 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws92 PRE_first_tail_x6_r0_body.crs92 PRE_first_tail_x6_r0_body.ws92

end Host.Load.Run.Tpl
end

section -- st92/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st92`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st92.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st92.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st92.s2.heap PRE_first_tail_x6_r0_body.st92.wrR ++ freshOf PRE_first_tail_x6_r0_body.st92.s2.heap PRE_first_tail_x6_r0_body.st92.s0.next PRE_first_tail_x6_r0_body.st92.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st92.wr : List Nat := PRE_first_tail_x6_r0_body.st92.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st92.heapFoot : PRE_first_tail_x6_r0_body.st92.s2.heap = setAll PRE_first_tail_x6_r0_body.st92.s0.heap PRE_first_tail_x6_r0_body.st92.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st92.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st92.s0.next PRE_first_tail_x6_r0_body.st92.s2.next = true
theorem PRE_first_tail_x6_r0_body.st92.grows : PRE_first_tail_x6_r0_body.st92.s0.next ≤ PRE_first_tail_x6_r0_body.st92.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st92.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st92.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st92.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st92.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st92.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st92.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st92.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st92.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st92.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st92.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st92.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st92.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st92.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st92.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st92.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st92.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st92.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st92.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st92.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st92.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st92.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st92.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st92.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st92.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st92.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st92.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st92.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st92.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st92.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st92.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st92.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st92.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF92
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 92 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB92 : nodupT PRE_first_tail_x6_r0_body.st92.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup92 : PRE_first_tail_x6_r0_body.st92.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB92).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB92 : PRE_first_tail_x6_r0_body.st92.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound92 : ∀ b ∈ PRE_first_tail_x6_r0_body.st92.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB92 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr92 := PRE_first_tail_x6_r0_body.st92.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq92 : PRE_first_tail_x6_r0_body.st92.s2.trace = PRE_first_tail_x6_r0_body.trFr92 ++ PRE_first_tail_x6_r0_body.st92.s0.trace
theorem PRE_first_tail_x6_r0_body.trace92 : ∃ fr, PRE_first_tail_x6_r0_body.st92.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st92.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq92⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide92 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB92 : (PRE_first_tail_x6_r0_body.wide92.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st92.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix92 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide92, WFix Map.id (Present PRE_first_tail_x6_r0_body.st92.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB92 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL92
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 92 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s892`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO92 : PRE_first_tail_x6_r0_body.st92.S0.oracle = PRE_first_tail_x6_r0_body.st92.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B92 : PRE_first_tail_x6_r0_body.st92.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st92.s0.next || (PRE_first_tail_x6_r0_body.st92.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot92 : Conv.StageFoot PRE_first_tail_x6_r0_body.st92.wr PRE_first_tail_x6_r0_body.st92.s0 PRE_first_tail_x6_r0_body.st92.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st92.heapFoot PRE_first_tail_x6_r0_body.wrNodup92 PRE_first_tail_x6_r0_body.wrBound92 PRE_first_tail_x6_r0_body.wr0B92 PRE_first_tail_x6_r0_body.st92.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged92 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st92.F.S → PRE_first_tail_x6_r0_body.st92.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st92.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st92.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs92 PRE_first_tail_x6_r0_body.st92.wr PRE_first_tail_x6_r0_body.s891 PRE_first_tail_x6_r0_body.st92.s2 PRE_first_tail_x6_r0_body.st92.s0
      PRE_first_tail_x6_r0_body.st92.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st92.F FR W stk M ν K PRE_first_tail_x6_r0_body.s892 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso92 PRE_first_tail_x6_r0_body.stFoot92 PRE_first_tail_x6_r0_body.wrNodup92 PRE_first_tail_x6_r0_body.wrBound92 PRE_first_tail_x6_r0_body.trace92 PRE_first_tail_x6_r0_body.mheap92
    PRE_first_tail_x6_r0_body.mnext92 PRE_first_tail_x6_r0_body.mctl92 PRE_first_tail_x6_r0_body.mstack92 PRE_first_tail_x6_r0_body.mjobs92 PRE_first_tail_x6_r0_body.mffi92 PRE_first_tail_x6_r0_body.mtrace92 PRE_first_tail_x6_r0_body.mstores92 h

def PRE_first_tail_x6_r0_body.arrEl92_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE92_2665 : arrOf PRE_first_tail_x6_r0_body.s892 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl92_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA92_2665 : isArrB PRE_first_tail_x6_r0_body.s892 2665 = true
theorem PRE_first_tail_x6_r0_body.arr92_2665 : ∃ o, PRE_first_tail_x6_r0_body.s892.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl92_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE92_2665 PRE_first_tail_x6_r0_body.arrA92_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN92_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl92_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR92_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl92_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN92_2665

def PRE_first_tail_x6_r0_body.arrEl92_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE92_2673467 : arrOf PRE_first_tail_x6_r0_body.s892 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl92_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA92_2673467 : isArrB PRE_first_tail_x6_r0_body.s892 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr92_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s892.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl92_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE92_2673467 PRE_first_tail_x6_r0_body.arrA92_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN92_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl92_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR92_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl92_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN92_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k92 : isArrB PRE_first_tail_x6_r0_body.s892 4910 = false
theorem PRE_first_tail_x6_r0_body.keep92 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s892 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k92 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr92_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl92_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ92
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 92 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s891`, the merged
state `PRE_first_tail_x6_r0_body.s892`, the canonical state `PRE_first_tail_x6_r0_body.s893`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl92 : PRE_first_tail_x6_r0_body.pl92.all (Nat.ble PRE_first_tail_x6_r0_body.s891.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd92 : nodupT PRE_first_tail_x6_r0_body.pl92 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn192 : Nat.ble PRE_first_tail_x6_r0_body.s891.next 2746682 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst92 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s891.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn92 : PRE_first_tail_x6_r0_body.s893.next = PRE_first_tail_x6_r0_body.s891.next + PRE_first_tail_x6_r0_body.pl92.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn92 : PRE_first_tail_x6_r0_body.s892.next = 2746682
kernel_rfl PRE_first_tail_x6_r0_body.zgrow92 : Nat.ble PRE_first_tail_x6_r0_body.s893.next PRE_first_tail_x6_r0_body.s892.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh92 : PRE_first_tail_x6_r0_body.S891.tab.all (fun e => PRE_first_tail_x6_r0_body.cws92.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd92 : nodupT PRE_first_tail_x6_r0_body.cws92 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi92 : PRE_first_tail_x6_r0_body.nr92.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S892.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt92 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s891.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg92_2665 : PRE_first_tail_x6_r0_body.s893.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s893 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk92_2665 : (objOf PRE_first_tail_x6_r0_body.s893 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm92_2665 : PRE_first_tail_x6_r0_body.s892.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa92.obj (objOf PRE_first_tail_x6_r0_body.s893 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s892 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg92_2673467 : PRE_first_tail_x6_r0_body.s893.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s893 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk92_2673467 : (objOf PRE_first_tail_x6_r0_body.s893 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm92_2673467 : PRE_first_tail_x6_r0_body.s892.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa92.obj (objOf PRE_first_tail_x6_r0_body.s893 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s892 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw92_4910 : (PRE_first_tail_x6_r0_body.s893.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw92_2673472 : (PRE_first_tail_x6_r0_body.s893.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw92_2673473 : (PRE_first_tail_x6_r0_body.s893.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd92 : PRE_first_tail_x6_r0_body.cl92.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr92 : PRE_first_tail_x6_r0_body.st92.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s891.next || PRE_first_tail_x6_r0_body.cl92.contains b) = true
def PRE_first_tail_x6_r0_body.zl92 : List Nat := PRE_first_tail_x6_r0_body.cl92.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE92 : PRE_first_tail_x6_r0_body.zl92.map (fun a => PRE_first_tail_x6_r0_body.s892.heap.get (PRE_first_tail_x6_r0_body.kappa92.a a)) = PRE_first_tail_x6_r0_body.zl92.map (fun a => (PRE_first_tail_x6_r0_body.s893.heap.get a).map PRE_first_tail_x6_r0_body.kappa92.hobj)
theorem PRE_first_tail_x6_r0_body.zimg92 : HeapImg PRE_first_tail_x6_r0_body.kappa92 PRE_first_tail_x6_r0_body.s893 PRE_first_tail_x6_r0_body.s892 PRE_first_tail_x6_r0_body.zl92 := PRE_first_tail_x6_r0_body.zimgE92
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl92 : PRE_first_tail_x6_r0_body.s892.ctl = PRE_first_tail_x6_r0_body.kappa92.ctl PRE_first_tail_x6_r0_body.s893.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack92 : PRE_first_tail_x6_r0_body.s892.stack = PRE_first_tail_x6_r0_body.s893.stack.map PRE_first_tail_x6_r0_body.kappa92.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs92 : PRE_first_tail_x6_r0_body.s892.jobs = PRE_first_tail_x6_r0_body.s893.jobs.map PRE_first_tail_x6_r0_body.kappa92.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores92 : PRE_first_tail_x6_r0_body.s892.stores = PRE_first_tail_x6_r0_body.kappa92.stores PRE_first_tail_x6_r0_body.s893.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots92 : checkRootsSupp PRE_first_tail_x6_r0_body.s893 3988 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC92 : PRE_first_tail_x6_r0_body.S891.tab.length + PRE_first_tail_x6_r0_body.cws92.length = 3988
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap92 : PRE_first_tail_x6_r0_body.kappa92 = Conv.Map.compact PRE_first_tail_x6_r0_body.s891.next 2746682 PRE_first_tail_x6_r0_body.S891.tab.length PRE_first_tail_x6_r0_body.pl92 (PRE_first_tail_x6_r0_body.nr92.map NumV.ref) PRE_first_tail_x6_r0_body.kd92.big
  PRE_first_tail_x6_r0_body.kd92.region PRE_first_tail_x6_r0_body.kd92.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin92 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s893.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc92 : Conv.jcleanListB (⟨20005, 17107, 2746672, 3988⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s893 PRE_first_tail_x6_r0_body.cl92 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB92 : noBigRootsP (fun i => !Conv.oldBigB (⟨20005, 17107, 2746672, 3988⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s893.trace PRE_first_tail_x6_r0_body.s893 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm92 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 17107 = true
theorem PRE_first_tail_x6_r0_body.cjcl92 (h : Conv.JClean (⟨20005, 17107, 2746671, 3988⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s891) : Conv.JClean (⟨20005, 17107, 2746672, 3988⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s893 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle92)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap92 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd92 a ha)) PRE_first_tail_x6_r0_body.zjc92

end Host.Load.Run.Tpl
end

section -- st92/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st92.bodyLast from PRE_first_tail_x6_r0_body.st92.s1 to PRE_first_tail_x6_r0_body.st92.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st92.F PRE_first_tail_x6_r0_body.st92.s1).run PRE_first_tail_x6_r0_body.st92.S1 = some (PRE_first_tail_x6_r0_body.st92.s2, PRE_first_tail_x6_r0_body.st92.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st92.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st92.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st92.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st92.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st92/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st92.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st92.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st92.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st92.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st92.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st92.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st92.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st92.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st92.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st92.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st92.s0 PRE_first_tail_x6_r0_body.st92.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st92.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st92.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st92.s1 PRE_first_tail_x6_r0_body.st92.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st92/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st92.bodyK0F from PRE_first_tail_x6_r0_body.st92.s0 to PRE_first_tail_x6_r0_body.st92.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st92.F (PRE_first_tail_x6_r0_body.st92.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st92.ks 0).getD 0) PRE_first_tail_x6_r0_body.st92.s0 PRE_first_tail_x6_r0_body.st92.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st92.s1, PRE_first_tail_x6_r0_body.st92.S1)
theorem PRE_first_tail_x6_r0_body.st92.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st92.F (PRE_first_tail_x6_r0_body.st92.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st92.ks 0).getD 0) PRE_first_tail_x6_r0_body.st92.s0 PRE_first_tail_x6_r0_body.st92.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st92.s1, PRE_first_tail_x6_r0_body.st92.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st92.bodyOkLN_ok PRE_first_tail_x6_r0_body.st92.bodyK0F
end Host.Load.Run.Tpl
end

section -- st92/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st92.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st92.F (PRE_first_tail_x6_r0_body.st92.bodyOkL bytes rows) 98 PRE_first_tail_x6_r0_body.st92.s0 PRE_first_tail_x6_r0_body.st92.S0 = some (PRE_first_tail_x6_r0_body.st92.s1, PRE_first_tail_x6_r0_body.st92.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st92.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st92.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st92.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st92.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st92.F (PRE_first_tail_x6_r0_body.st92.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st92.s0
  S0 := PRE_first_tail_x6_r0_body.st92.S0
  s1 := PRE_first_tail_x6_r0_body.st92.s1
  S1 := PRE_first_tail_x6_r0_body.st92.S1
  s2 := PRE_first_tail_x6_r0_body.st92.s2
  S2 := PRE_first_tail_x6_r0_body.st92.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st92.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st92.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st92.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st92.bodyHalt
  last := PRE_first_tail_x6_r0_body.st92.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st92.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC93
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 93 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s909` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa93` into the merged state
`PRE_first_tail_x6_r0_body.s908`. -/

def PRE_first_tail_x6_r0_body.pl93 : List Nat := [2748770, 2748606, 2748658, 2748771, 2748772, 2748608, 2748660, 2748769, 2748768, 2748767, 2748766, 2748760, 2748711, 2748762, 2748713]
def PRE_first_tail_x6_r0_body.nr93 : List Nat := [4073, 4074, 4070, 4076, 4072, 4080, 4081, 4078, 4079]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd93 : RData :=
  ⟨2748423, 2748773, Stage.setAll PTrie.nil [(2748408, 2748770), (2748409, 2748606), (2748410, 2748658), (2748411, 2748771), (2748412, 2748772), (2748413, 2748608), (2748414, 2748660), (2748415, 2748769), (2748416, 2748768), (2748417, 2748767), (2748418, 2748766), (2748419, 2748760), (2748420, 2748711), (2748421, 2748762), (2748422, 2748713)], Stage.setAll PTrie.nil [(20045, 20047), (20046, 20048), (20047, 20050), (20048, 20049)],
   20049, 20051, 17141, 17141, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(4065, .ref 4073), (4066, .ref 4074), (4067, .ref 4070), (4068, .ref 4076), (4069, .ref 4072), (4070, .ref 4080), (4071, .ref 4081), (4072, .ref 4078), (4073, .ref 4079)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa93 : Map :=
  Conv.Map.compact 2748408 2748773 4065 PRE_first_tail_x6_r0_body.pl93 (PRE_first_tail_x6_r0_body.nr93.map NumV.ref) PRE_first_tail_x6_r0_body.kd93.big
    PRE_first_tail_x6_r0_body.kd93.region PRE_first_tail_x6_r0_body.kd93.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws93 : List Nat := [2578, 2579, 2580, 2581, 2582, 2583, 2584, 2585, 2586]
noncomputable def PRE_first_tail_x6_r0_body.crs93 : List SymE := PRE_first_tail_x6_r0_body.nr93.map fun r => (nth? PRE_first_tail_x6_r0_body.S908.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta93 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws93 PRE_first_tail_x6_r0_body.crs93
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB93 : List Nat := [2665, 2672539, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab93 : PRE_first_tail_x6_r0_body.S909.tab = PRE_first_tail_x6_r0_body.S907.tab ++ PRE_first_tail_x6_r0_body.cws93.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace93 : PRE_first_tail_x6_r0_body.s909.trace = PRE_first_tail_x6_r0_body.s907.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext93 : PRE_first_tail_x6_r0_body.s909.next = 2748423
kernel_rfl PRE_first_tail_x6_r0_body.ccounters93 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s909.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s909.ffi).mlx.nnext) = (20049, 17141)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue93 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s908.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s909.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa93.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp93 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s909.ffi).mlx.tokens.all (bSN 4074) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean93 : Conv.cleanListB 20049 131072 (fun r => Nat.ble 80196 r) PRE_first_tail_x6_r0_body.s909
    (PRE_first_tail_x6_r0_body.wrB93 ++ (List.range 15).map (2748408 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs93 : bigsOutB 20049 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s909.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK93
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl93`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl93 : List Nat := [2665, 2672539, 2673467, 2748408, 2748409, 2748410, 2748411, 2748412, 2748413, 2748414, 2748415, 2748416, 2748417, 2748418, 2748419, 2748420, 2748421, 2748422]
def PRE_first_tail_x6_r0_body.clo93 : List Nat := [20045, 20046, 20047, 20048]
def PRE_first_tail_x6_r0_body.cln93 : List Nat := [17135, 17136, 17137, 17138, 17139, 17140]
def PRE_first_tail_x6_r0_body.cli93 : List Nat := [17135, 17136, 17137, 17138, 17139, 17140]
kernel_rfl PRE_first_tail_x6_r0_body.cheap93 : PRE_first_tail_x6_r0_body.s909.heap = Stage.setAll PRE_first_tail_x6_r0_body.s907.heap (PRE_first_tail_x6_r0_body.cl93.filterMap fun a => (PRE_first_tail_x6_r0_body.s909.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe93 : Nat.ble PRE_first_tail_x6_r0_body.s907.next PRE_first_tail_x6_r0_body.s909.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP93 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s907 PRE_first_tail_x6_r0_body.s909 PRE_first_tail_x6_r0_body.cl93 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp93 : Conv.suppListB PRE_first_tail_x6_r0_body.s909 4074 PRE_first_tail_x6_r0_body.cl93 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound93 : Conv.boundListB PRE_first_tail_x6_r0_body.s909 PRE_first_tail_x6_r0_body.cl93 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK93 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s909.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln93.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s909.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK93 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s909.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo93.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s909.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK93 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s909.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli93.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s909.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst93 : Conv.sstListB 4074 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s909.ffi).mlx PRE_first_tail_x6_r0_body.cln93 PRE_first_tail_x6_r0_body.clo93 PRE_first_tail_x6_r0_body.cli93 = true

end Host.Load.Run.Tpl
end

section -- SiteCl93
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA93 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s909.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo93.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s909.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd93 : (PRE_first_tail_x6_r0_body.clo93 ++ PRE_first_tail_x6_r0_body.cln93 ++ PRE_first_tail_x6_r0_body.cli93).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle93 : Conv.Cnt.leB (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt) (⟨20049, 17141, 2748423, 4074⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck93 : Conv.ncleanListB (⟨20049, 17141, 2748423, 4074⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s909.ffi).mlx PRE_first_tail_x6_r0_body.clo93 PRE_first_tail_x6_r0_body.cln93 PRE_first_tail_x6_r0_body.cli93 = true
theorem PRE_first_tail_x6_r0_body.cncl93 (h : Conv.NClean (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx) : Conv.NClean (⟨20049, 17141, 2748423, 4074⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s909.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle93 PRE_first_tail_x6_r0_body.ckA93 PRE_first_tail_x6_r0_body.cobjsK93 PRE_first_tail_x6_r0_body.cnodesK93 PRE_first_tail_x6_r0_body.citemsK93 PRE_first_tail_x6_r0_body.cbd93 PRE_first_tail_x6_r0_body.cck93

end Host.Load.Run.Tpl
end

section -- SiteS93
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 93 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc93 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P93 : LoadP := PRE_first_tail_x6_r0_body.Pc93.raise 17141
kernel_rfl PRE_first_tail_x6_r0_body.craise93 : Nat.ble PRE_first_tail_x6_r0_body.Pc93.N0 17141 = true
theorem PRE_first_tail_x6_r0_body.raised93 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc93 PRE_first_tail_x6_r0_body.P93 :=
  .inr ⟨17141, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise93, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_93 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s909.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_93 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s908.ffi)
def PRE_first_tail_x6_r0_body.khinv93 : PTrie Nat := Stage.setAll PTrie.nil [(20047, 20045), (20048, 20046), (20050, 20047), (20049, 20048)]
def PRE_first_tail_x6_r0_body.kninv93 : PTrie Nat := Stage.setAll PTrie.nil [(17135, 17135), (17136, 17136), (17137, 17137), (17138, 17138), (17139, 17139), (17140, 17140)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS93 : List Nat := [20045, 20046, 20047, 20048, 20049, 20050]
def PRE_first_tail_x6_r0_body.cnS93 : List Nat := List.range' 17135 6
def PRE_first_tail_x6_r0_body.ciS93 : List Nat := [] ++ List.range' 17135 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh093 : PRE_first_tail_x6_r0_body.kd93.nh0 = PRE_first_tail_x6_r0_body.cx0_93.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh193 : PRE_first_tail_x6_r0_body.kd93.nh1 = PRE_first_tail_x6_r0_body.cx1_93.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn093 : PRE_first_tail_x6_r0_body.kd93.nn0 = PRE_first_tail_x6_r0_body.cx0_93.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn193 : PRE_first_tail_x6_r0_body.kd93.nn1 = PRE_first_tail_x6_r0_body.cx1_93.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo93 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P93.lo && Nat.ble PRE_first_tail_x6_r0_body.P93.lo PRE_first_tail_x6_r0_body.cx0_93.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P93.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P93.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt93 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_93.mlx.next PRE_first_tail_x6_r0_body.cx1_93.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_93.mlx.nnext PRE_first_tail_x6_r0_body.cx1_93.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband93 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P93.NL && Nat.ble PRE_first_tail_x6_r0_body.P93.NL PRE_first_tail_x6_r0_body.P93.N0 && Nat.ble PRE_first_tail_x6_r0_body.P93.N0 PRE_first_tail_x6_r0_body.cx0_93.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow93 : PRE_first_tail_x6_r0_body.kd93.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren93 : checkRenG PRE_first_tail_x6_r0_body.kd93.hnd PRE_first_tail_x6_r0_body.khinv93 (phB PRE_first_tail_x6_r0_body.cx0_93.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband93 : PRE_first_tail_x6_r0_body.kd93.checkBand PRE_first_tail_x6_r0_body.P93.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos93 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd93.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren93 : checkRenG PRE_first_tail_x6_r0_body.kd93.node PRE_first_tail_x6_r0_body.kninv93 (pnB PRE_first_tail_x6_r0_body.cx0_93.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow93 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd93.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P93.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd93.nodeF j) PRE_first_tail_x6_r0_body.cx1_93.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a93 : PRE_first_tail_x6_r0_body.cx0_93.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b93 : PRE_first_tail_x6_r0_body.cx0_93.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok193 : PRE_first_tail_x6_r0_body.cx1_93.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend93 : PRE_first_tail_x6_r0_body.cx1_93.mlx.pending = PRE_first_tail_x6_r0_body.cx0_93.mlx.pending.map PRE_first_tail_x6_r0_body.kappa93.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh93 : PRE_first_tail_x6_r0_body.cx1_93.mlx.errh = PRE_first_tail_x6_r0_body.cx0_93.mlx.errh.map PRE_first_tail_x6_r0_body.kappa93.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles93 : PRE_first_tail_x6_r0_body.cx1_93.mlx.files = PRE_first_tail_x6_r0_body.cx0_93.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch93 : PRE_first_tail_x6_r0_body.cx1_93.mlx.arch = PRE_first_tail_x6_r0_body.cx0_93.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes93 : PRE_first_tail_x6_r0_body.cx1_93.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_93.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired93 : PRE_first_tail_x6_r0_body.cx1_93.mlx.wired = PRE_first_tail_x6_r0_body.cx0_93.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost93 : PRE_first_tail_x6_r0_body.cx1_93.host = PRE_first_tail_x6_r0_body.cx0_93.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd93`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn093 : PRE_first_tail_x6_r0_body.kd93.n0 = 2748423
kernel_rfl PRE_first_tail_x6_r0_body.ckn193 : PRE_first_tail_x6_r0_body.kd93.n1 = 2748773
kernel_rfl PRE_first_tail_x6_r0_body.ckheap93 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd93.heap).all (fun x => Nat.ble 2748408 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl93 : (List.range 15).all (fun j => decide (PRE_first_tail_x6_r0_body.kd93.heap.get (2748408 + j) = nth? PRE_first_tail_x6_r0_body.pl93 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja93 : Nat.ble 2748408 2748408 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn93 : Nat.ble 4065 4065 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD93 : Nat.ble 2748408 PRE_first_tail_x6_r0_body.kd93.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn93 : Nat.ble 20045 PRE_first_tail_x6_r0_body.kd93.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn93 : Nat.ble 17135 PRE_first_tail_x6_r0_body.kd93.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb93 : Nat.ble 20045 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap93 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd93.heap).all (Nat.ble (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd93 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd93.hnd).all (Nat.ble (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode93 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd93.node).all (Nat.ble (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix93 : Conv.FixOld (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa93 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja93) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn93) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD93) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn93) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn93) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb93) PRE_first_tail_x6_r0_body.fheap93 PRE_first_tail_x6_r0_body.fhnd93 PRE_first_tail_x6_r0_body.fnode93
kernel_rfl PRE_first_tail_x6_r0_body.fcxn93 : (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn93 : (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle093 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_93.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_93.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk93 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd93.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A93 : PRE_first_tail_x6_r0_body.cx1_93.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS93.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_93.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O93 : PRE_first_tail_x6_r0_body.cx1_93.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS93.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_93.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N93 : PRE_first_tail_x6_r0_body.cx1_93.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS93.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_93.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I93 : PRE_first_tail_x6_r0_body.cx1_93.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS93.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_93.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd93 : (PRE_first_tail_x6_r0_body.clo93 ++ PRE_first_tail_x6_r0_body.cln93 ++ PRE_first_tail_x6_r0_body.cli93 ++ PRE_first_tail_x6_r0_body.cwS93 ++ PRE_first_tail_x6_r0_body.cnS93 ++ PRE_first_tail_x6_r0_body.ciS93).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW93 : PRE_first_tail_x6_r0_body.cwS93.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo93.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI93 : PRE_first_tail_x6_r0_body.ciS93.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli93.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN93 : PRE_first_tail_x6_r0_body.cnS93.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF93 : PRE_first_tail_x6_r0_body.cln93.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh93 : PRE_first_tail_x6_r0_body.clo93.all (handleOK PRE_first_tail_x6_r0_body.kappa93 PRE_first_tail_x6_r0_body.P93.lo PRE_first_tail_x6_r0_body.cx0_93.mlx PRE_first_tail_x6_r0_body.cx1_93.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo93 : PRE_first_tail_x6_r0_body.clo93.map (fun h => PRE_first_tail_x6_r0_body.cx1_93.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa93.handle h)) = PRE_first_tail_x6_r0_body.clo93.map (fun h => (PRE_first_tail_x6_r0_body.cx0_93.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa93.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok93 : PRE_first_tail_x6_r0_body.clo93.all (objOK PRE_first_tail_x6_r0_body.kappa93 PRE_first_tail_x6_r0_body.P93.NL PRE_first_tail_x6_r0_body.cx0_93.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd93 : PRE_first_tail_x6_r0_body.cln93.all (nodeOKF PRE_first_tail_x6_r0_body.kappa93 PRE_first_tail_x6_r0_body.P93 PRE_first_tail_x6_r0_body.cx0_93.mlx PRE_first_tail_x6_r0_body.cx1_93.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp93 : ((PRE_first_tail_x6_r0_body.cln93.filter (fullB PRE_first_tail_x6_r0_body.P93))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_93.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa93.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln93.filter (fullB PRE_first_tail_x6_r0_body.P93))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_93.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa93.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI93 : incrB PRE_first_tail_x6_r0_body.kd93.nodeF (List.range' 17135 6) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK93 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd93.node).all (fun k => Nat.ble 17135 k && Nat.blt k 17141) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL93 : (PRE_first_tail_x6_r0_body.cln93.filter (Nat.ble PRE_first_tail_x6_r0_body.P93.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd93.nodeF i) && (Nat.blt i 17141 || Nat.ble PRE_first_tail_x6_r0_body.kd93.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord93 : (PRE_first_tail_x6_r0_body.cln93.filter (Nat.ble PRE_first_tail_x6_r0_body.P93.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd93.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd93.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd93.nodeF j) (PRE_first_tail_x6_r0_body.kd93.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow93 PRE_first_tail_x6_r0_body.cnn193 PRE_first_tail_x6_r0_body.fnordI93 PRE_first_tail_x6_r0_body.fnordK93 PRE_first_tail_x6_r0_body.fnordL93
kernel_rfl PRE_first_tail_x6_r0_body.fi93 : PRE_first_tail_x6_r0_body.cli93.all (pnB PRE_first_tail_x6_r0_body.cx0_93.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii93 : PRE_first_tail_x6_r0_body.cli93.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_93.mlx.items.get (PRE_first_tail_x6_r0_body.kappa93.node k) = (PRE_first_tail_x6_r0_body.cx0_93.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa93.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot93 (clean : Conv.NClean (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P93.NL) (cl : SSt (· < 4074) PRE_first_tail_x6_r0_body.cx0_93.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P93 4074 PRE_first_tail_x6_r0_body.kappa93 PRE_first_tail_x6_r0_body.kd93 PRE_first_tail_x6_r0_body.khinv93 PRE_first_tail_x6_r0_body.kninv93 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx PRE_first_tail_x6_r0_body.cx0_93.mlx PRE_first_tail_x6_r0_body.cx1_93.mlx (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo93 PRE_first_tail_x6_r0_body.cln93 PRE_first_tail_x6_r0_body.cli93 PRE_first_tail_x6_r0_body.cwS93 PRE_first_tail_x6_r0_body.cnS93 PRE_first_tail_x6_r0_body.ciS93 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh093, PRE_first_tail_x6_r0_body.cnh193, PRE_first_tail_x6_r0_body.cnn093, PRE_first_tail_x6_r0_body.cnn193, PRE_first_tail_x6_r0_body.cplo93, PRE_first_tail_x6_r0_body.ccnt93, PRE_first_tail_x6_r0_body.cnband93, PRE_first_tail_x6_r0_body.chbelow93, PRE_first_tail_x6_r0_body.chren93, PRE_first_tail_x6_r0_body.cband93, PRE_first_tail_x6_r0_body.cnh1pos93, PRE_first_tail_x6_r0_body.cnren93, PRE_first_tail_x6_r0_body.cnlow93, PRE_first_tail_x6_r0_body.cabs0a93, PRE_first_tail_x6_r0_body.cabs0b93, PRE_first_tail_x6_r0_body.ctok193, PRE_first_tail_x6_r0_body.cpend93, PRE_first_tail_x6_r0_body.cerrh93, PRE_first_tail_x6_r0_body.cfiles93, PRE_first_tail_x6_r0_body.carch93, PRE_first_tail_x6_r0_body.csizes93, PRE_first_tail_x6_r0_body.cwired93, PRE_first_tail_x6_r0_body.cfix93, clean, PRE_first_tail_x6_r0_body.fcxn93, PRE_first_tail_x6_r0_body.fcnn93, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle093, PRE_first_tail_x6_r0_body.fnk93, PRE_first_tail_x6_r0_body.ckA93, PRE_first_tail_x6_r0_body.cobjsK93, PRE_first_tail_x6_r0_body.cnodesK93, PRE_first_tail_x6_r0_body.citemsK93, PRE_first_tail_x6_r0_body.f1A93, PRE_first_tail_x6_r0_body.f1O93, PRE_first_tail_x6_r0_body.f1N93, PRE_first_tail_x6_r0_body.f1I93, PRE_first_tail_x6_r0_body.fbd93, PRE_first_tail_x6_r0_body.fincW93, PRE_first_tail_x6_r0_body.fincI93, PRE_first_tail_x6_r0_body.fincN93, PRE_first_tail_x6_r0_body.flnF93, PRE_first_tail_x6_r0_body.fh93, PRE_first_tail_x6_r0_body.fo93, PRE_first_tail_x6_r0_body.fok93, PRE_first_tail_x6_r0_body.fnd93, PRE_first_tail_x6_r0_body.fp93, PRE_first_tail_x6_r0_body.fnord93, PRE_first_tail_x6_r0_body.fi93, PRE_first_tail_x6_r0_body.fii93⟩
theorem PRE_first_tail_x6_r0_body.cnshift93 (clean : Conv.NClean (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P93.NL) (cl : SSt (· < 4074) PRE_first_tail_x6_r0_body.cx0_93.mlx) : NShift PRE_first_tail_x6_r0_body.P93 4074 PRE_first_tail_x6_r0_body.kappa93 PRE_first_tail_x6_r0_body.cx0_93 PRE_first_tail_x6_r0_body.cx1_93 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot93 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost93 (compact_a_eq PRE_first_tail_x6_r0_body.ckn093 PRE_first_tail_x6_r0_body.ckn193 PRE_first_tail_x6_r0_body.ckheap93 PRE_first_tail_x6_r0_body.ckpl93)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_93 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s907.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_93 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s907.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_93 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s907.ffi) = some PRE_first_tail_x6_r0_body.fxC_93
kernel_rfl PRE_first_tail_x6_r0_body.okrC_93 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s907.ffi) = some PRE_first_tail_x6_r0_body.krC_93
noncomputable def PRE_first_tail_x6_r0_body.fx0_93 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s909.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_93 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s909.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_93 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s909.ffi) = some PRE_first_tail_x6_r0_body.fx0_93
kernel_rfl PRE_first_tail_x6_r0_body.okr0_93 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s909.ffi) = some PRE_first_tail_x6_r0_body.kr0_93
noncomputable def PRE_first_tail_x6_r0_body.fx1_93 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s908.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_93 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s908.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_93 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s908.ffi) = some PRE_first_tail_x6_r0_body.fx1_93
kernel_rfl PRE_first_tail_x6_r0_body.okr1_93 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s908.ffi) = some PRE_first_tail_x6_r0_body.kr1_93
kernel_rfl PRE_first_tail_x6_r0_body.ff093 : PRE_first_tail_x6_r0_body.fx0_93 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_93 (PRE_first_tail_x6_r0_body.clo93.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_93.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff193 : PRE_first_tail_x6_r0_body.fx1_93 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_93 (PRE_first_tail_x6_r0_body.cwS93.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_93.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck93 : freedLB PRE_first_tail_x6_r0_body.kappa93 PRE_first_tail_x6_r0_body.cx0_93.mlx PRE_first_tail_x6_r0_body.fx0_93 PRE_first_tail_x6_r0_body.fx1_93 PRE_first_tail_x6_r0_body.clo93 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf093 : PRE_first_tail_x6_r0_body.kr0_93.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_93.flags (PRE_first_tail_x6_r0_body.clo93.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_93.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt093 : PRE_first_tail_x6_r0_body.kr0_93.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_93.targs (PRE_first_tail_x6_r0_body.clo93.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_93.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf193 : PRE_first_tail_x6_r0_body.kr1_93.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_93.flags (PRE_first_tail_x6_r0_body.cwS93.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_93.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt193 : PRE_first_tail_x6_r0_body.kr1_93.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_93.targs (PRE_first_tail_x6_r0_body.cwS93.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_93.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck93 : krecLB PRE_first_tail_x6_r0_body.kappa93 4074 PRE_first_tail_x6_r0_body.cx0_93.mlx PRE_first_tail_x6_r0_body.kr0_93 PRE_first_tail_x6_r0_body.kr1_93 PRE_first_tail_x6_r0_body.clo93 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn93 : Nat.ble 4065 4074 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge93 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s908.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s909.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR93 : pendRegB PRE_first_tail_x6_r0_body.kappa93 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s909.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe93 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s909.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s908.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift93 (clean : Conv.NClean (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P93.NL) (cl : SSt (· < 4074) PRE_first_tail_x6_r0_body.cx0_93.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_93.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_93.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_93.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s907.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_93.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P93 4074 PRE_first_tail_x6_r0_body.kappa93 PRE_first_tail_x6_r0_body.s909.ffi PRE_first_tail_x6_r0_body.s908.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift93 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue93, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp93 t ht),
    PRE_first_tail_x6_r0_body.cbridge93,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s909.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s908.ffi) (PRE_first_tail_x6_r0_body.cfoot93 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_93 PRE_first_tail_x6_r0_body.ofx1_93 hobjC PRE_first_tail_x6_r0_body.ff093 PRE_first_tail_x6_r0_body.ff193 PRE_first_tail_x6_r0_body.ffck93,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s909.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s908.ffi) (PRE_first_tail_x6_r0_body.cfoot93 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_93 PRE_first_tail_x6_r0_body.okr1_93 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn93) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf093 PRE_first_tail_x6_r0_body.fkt093 PRE_first_tail_x6_r0_body.fkf193 PRE_first_tail_x6_r0_body.fkt193 PRE_first_tail_x6_r0_body.fkck93,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh093 PRE_first_tail_x6_r0_body.cnh193 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe93) PRE_first_tail_x6_r0_body.cpendR93⟩

end Host.Load.Run.Tpl
end

section -- st93/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st93 0
host_stream_state PRE_first_tail_x6_r0_body.st93 1
host_stream_state PRE_first_tail_x6_r0_body.st93 2
host_stream_state PRE_first_tail_x6_r0_body.st93 3
end Host.Load.Run.Tpl
end

section -- Site93
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 93 of chain `PRE_first_tail_x6_r0_body`: `kvW__g93__g94` (`appendWindow`), the call state `PRE_first_tail_x6_r0_body.s907`, the merged state `PRE_first_tail_x6_r0_body.s908`,
the site template `PRE_first_tail_x6_r0_body.st93` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s909`: the merge.
The footprint's facts are in `SiteF93`, the compaction's in `SiteC93`, `SiteK93`, `SiteNa93`, `SiteNb93`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso93 : PRE_first_tail_x6_r0_body.st93.s0 = { PRE_first_tail_x6_r0_body.s907 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs93 : List Frame := PRE_first_tail_x6_r0_body.s907.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_93 : PRE_first_tail_x6_r0_body.S907.tab.length = 4065
kernel_rfl PRE_first_tail_x6_r0_body.tab0_93 : PRE_first_tail_x6_r0_body.st93.S0.tab = PRE_first_tail_x6_r0_body.S907.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws93 : List Nat := [2561, 2562, 2563, 2564, 2565, 2566, 2567, 2568, 2569, 2570, 2571, 2572, 2573, 2574, 2575, 2576, 2577]
kernel_rfl PRE_first_tail_x6_r0_body.fresh93 : (PRE_first_tail_x6_r0_body.S907.tab.all fun e => PRE_first_tail_x6_r0_body.ws93.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S907.oracle.all fun q => PRE_first_tail_x6_r0_body.ws93.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab93 : PRE_first_tail_x6_r0_body.S908.tab = PRE_first_tail_x6_r0_body.S907.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws93
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen93 : PRE_first_tail_x6_r0_body.st93.S3.tab.length - PRE_first_tail_x6_r0_body.st93.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged93`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap93 : PRE_first_tail_x6_r0_body.s908.heap = PRE_first_tail_x6_r0_body.st93.s3.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext93 : PRE_first_tail_x6_r0_body.s908.next = PRE_first_tail_x6_r0_body.st93.s3.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl93 : PRE_first_tail_x6_r0_body.s908.ctl = PRE_first_tail_x6_r0_body.st93.s3.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack93 : PRE_first_tail_x6_r0_body.s908.stack = PRE_first_tail_x6_r0_body.st93.s3.stack ++ PRE_first_tail_x6_r0_body.s907.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs93 : PRE_first_tail_x6_r0_body.s908.jobs = PRE_first_tail_x6_r0_body.st93.s3.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi93 : PRE_first_tail_x6_r0_body.s908.ffi = PRE_first_tail_x6_r0_body.st93.s3.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace93 : PRE_first_tail_x6_r0_body.s908.trace = PRE_first_tail_x6_r0_body.st93.s3.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores93 : PRE_first_tail_x6_r0_body.s908.stores = PRE_first_tail_x6_r0_body.st93.s3.stores

end Host.Load.Run.Tpl
end

section -- SiteD93
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 93 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived93 : PRE_first_tail_x6_r0_body.nr93.map (fun r => nth? PRE_first_tail_x6_r0_body.st93.S3.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false)))]
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo93 : PRE_first_tail_x6_r0_body.nr93.all (Nat.ble 4065) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj93 : PRE_first_tail_x6_r0_body.cws93.all (fun c => !PRE_first_tail_x6_r0_body.ws93.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ93 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws93 PRE_first_tail_x6_r0_body.crs93 PRE_first_tail_x6_r0_body.ws93

end Host.Load.Run.Tpl
end

section -- st93/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st93`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st93.wrR : List (Nat × Nat) := [(2672539, 2672540)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st93.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st93.s3.heap PRE_first_tail_x6_r0_body.st93.wrR ++ freshOf PRE_first_tail_x6_r0_body.st93.s3.heap PRE_first_tail_x6_r0_body.st93.s0.next PRE_first_tail_x6_r0_body.st93.s3.next
noncomputable def PRE_first_tail_x6_r0_body.st93.wr : List Nat := PRE_first_tail_x6_r0_body.st93.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st93.heapFoot : PRE_first_tail_x6_r0_body.st93.s3.heap = setAll PRE_first_tail_x6_r0_body.st93.s0.heap PRE_first_tail_x6_r0_body.st93.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st93.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st93.s0.next PRE_first_tail_x6_r0_body.st93.s3.next = true
theorem PRE_first_tail_x6_r0_body.st93.grows : PRE_first_tail_x6_r0_body.st93.s0.next ≤ PRE_first_tail_x6_r0_body.st93.s3.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st93.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st93.wh : List Nat := [20045, 20046, 20047, 20048, 20049, 20050]
def PRE_first_tail_x6_r0_body.st93.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st93.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st93.s3.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st93.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st93.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st93.s3.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st93.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st93.s3.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st93.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st93.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st93.s3.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st93.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st93.s3.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st93.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st93.s3.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st93.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st93.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st93.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st93.s3.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st93.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st93.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st93.s3.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st93.s3.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st93.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st93.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st93.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st93.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st93.s3.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st93.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st93.s3.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF93
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 93 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB93 : nodupT PRE_first_tail_x6_r0_body.st93.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup93 : PRE_first_tail_x6_r0_body.st93.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB93).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB93 : PRE_first_tail_x6_r0_body.st93.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound93 : ∀ b ∈ PRE_first_tail_x6_r0_body.st93.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB93 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr93 := PRE_first_tail_x6_r0_body.st93.s3.trace.take 26
kernel_rfl PRE_first_tail_x6_r0_body.traceEq93 : PRE_first_tail_x6_r0_body.st93.s3.trace = PRE_first_tail_x6_r0_body.trFr93 ++ PRE_first_tail_x6_r0_body.st93.s0.trace
theorem PRE_first_tail_x6_r0_body.trace93 : ∃ fr, PRE_first_tail_x6_r0_body.st93.s3.trace = fr ++ PRE_first_tail_x6_r0_body.st93.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq93⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide93 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB93 : (PRE_first_tail_x6_r0_body.wide93.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st93.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix93 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide93, WFix Map.id (Present PRE_first_tail_x6_r0_body.st93.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB93 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL93
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 93 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s908`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO93 : PRE_first_tail_x6_r0_body.st93.S0.oracle = PRE_first_tail_x6_r0_body.st93.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B93 : PRE_first_tail_x6_r0_body.st93.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st93.s0.next || (PRE_first_tail_x6_r0_body.st93.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot93 : Conv.StageFoot PRE_first_tail_x6_r0_body.st93.wr PRE_first_tail_x6_r0_body.st93.s0 PRE_first_tail_x6_r0_body.st93.s3 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st93.heapFoot PRE_first_tail_x6_r0_body.wrNodup93 PRE_first_tail_x6_r0_body.wrBound93 PRE_first_tail_x6_r0_body.wr0B93 PRE_first_tail_x6_r0_body.st93.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged93 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st93.F.S → PRE_first_tail_x6_r0_body.st93.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st93.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st93.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs93 PRE_first_tail_x6_r0_body.st93.wr PRE_first_tail_x6_r0_body.s907 PRE_first_tail_x6_r0_body.st93.s3 PRE_first_tail_x6_r0_body.st93.s0
      PRE_first_tail_x6_r0_body.st93.s3.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st93.F FR W stk M ν K PRE_first_tail_x6_r0_body.s908 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso93 PRE_first_tail_x6_r0_body.stFoot93 PRE_first_tail_x6_r0_body.wrNodup93 PRE_first_tail_x6_r0_body.wrBound93 PRE_first_tail_x6_r0_body.trace93 PRE_first_tail_x6_r0_body.mheap93
    PRE_first_tail_x6_r0_body.mnext93 PRE_first_tail_x6_r0_body.mctl93 PRE_first_tail_x6_r0_body.mstack93 PRE_first_tail_x6_r0_body.mjobs93 PRE_first_tail_x6_r0_body.mffi93 PRE_first_tail_x6_r0_body.mtrace93 PRE_first_tail_x6_r0_body.mstores93 h

def PRE_first_tail_x6_r0_body.arrEl93_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE93_2665 : arrOf PRE_first_tail_x6_r0_body.s908 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl93_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA93_2665 : isArrB PRE_first_tail_x6_r0_body.s908 2665 = true
theorem PRE_first_tail_x6_r0_body.arr93_2665 : ∃ o, PRE_first_tail_x6_r0_body.s908.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl93_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE93_2665 PRE_first_tail_x6_r0_body.arrA93_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN93_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl93_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR93_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl93_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN93_2665

def PRE_first_tail_x6_r0_body.arrEl93_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE93_2673467 : arrOf PRE_first_tail_x6_r0_body.s908 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl93_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA93_2673467 : isArrB PRE_first_tail_x6_r0_body.s908 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr93_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s908.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl93_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE93_2673467 PRE_first_tail_x6_r0_body.arrA93_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN93_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl93_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR93_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl93_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN93_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k93 : isArrB PRE_first_tail_x6_r0_body.s908 4910 = false
theorem PRE_first_tail_x6_r0_body.keep93 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s908 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k93 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr93_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl93_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ93
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 93 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s907`, the merged
state `PRE_first_tail_x6_r0_body.s908`, the canonical state `PRE_first_tail_x6_r0_body.s909`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl93 : PRE_first_tail_x6_r0_body.pl93.all (Nat.ble PRE_first_tail_x6_r0_body.s907.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd93 : nodupT PRE_first_tail_x6_r0_body.pl93 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn193 : Nat.ble PRE_first_tail_x6_r0_body.s907.next 2748773 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst93 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s907.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn93 : PRE_first_tail_x6_r0_body.s909.next = PRE_first_tail_x6_r0_body.s907.next + PRE_first_tail_x6_r0_body.pl93.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn93 : PRE_first_tail_x6_r0_body.s908.next = 2748773
kernel_rfl PRE_first_tail_x6_r0_body.zgrow93 : Nat.ble PRE_first_tail_x6_r0_body.s909.next PRE_first_tail_x6_r0_body.s908.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh93 : PRE_first_tail_x6_r0_body.S907.tab.all (fun e => PRE_first_tail_x6_r0_body.cws93.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd93 : nodupT PRE_first_tail_x6_r0_body.cws93 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi93 : PRE_first_tail_x6_r0_body.nr93.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S908.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt93 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s907.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg93_2665 : PRE_first_tail_x6_r0_body.s909.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s909 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk93_2665 : (objOf PRE_first_tail_x6_r0_body.s909 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm93_2665 : PRE_first_tail_x6_r0_body.s908.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa93.obj (objOf PRE_first_tail_x6_r0_body.s909 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s908 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg93_2673467 : PRE_first_tail_x6_r0_body.s909.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s909 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk93_2673467 : (objOf PRE_first_tail_x6_r0_body.s909 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm93_2673467 : PRE_first_tail_x6_r0_body.s908.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa93.obj (objOf PRE_first_tail_x6_r0_body.s909 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s908 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw93_4910 : (PRE_first_tail_x6_r0_body.s909.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw93_2673472 : (PRE_first_tail_x6_r0_body.s909.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw93_2673473 : (PRE_first_tail_x6_r0_body.s909.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd93 : PRE_first_tail_x6_r0_body.cl93.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr93 : PRE_first_tail_x6_r0_body.st93.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s907.next || PRE_first_tail_x6_r0_body.cl93.contains b) = true
def PRE_first_tail_x6_r0_body.zl93 : List Nat := PRE_first_tail_x6_r0_body.cl93.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE93 : PRE_first_tail_x6_r0_body.zl93.map (fun a => PRE_first_tail_x6_r0_body.s908.heap.get (PRE_first_tail_x6_r0_body.kappa93.a a)) = PRE_first_tail_x6_r0_body.zl93.map (fun a => (PRE_first_tail_x6_r0_body.s909.heap.get a).map PRE_first_tail_x6_r0_body.kappa93.hobj)
theorem PRE_first_tail_x6_r0_body.zimg93 : HeapImg PRE_first_tail_x6_r0_body.kappa93 PRE_first_tail_x6_r0_body.s909 PRE_first_tail_x6_r0_body.s908 PRE_first_tail_x6_r0_body.zl93 := PRE_first_tail_x6_r0_body.zimgE93
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl93 : PRE_first_tail_x6_r0_body.s908.ctl = PRE_first_tail_x6_r0_body.kappa93.ctl PRE_first_tail_x6_r0_body.s909.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack93 : PRE_first_tail_x6_r0_body.s908.stack = PRE_first_tail_x6_r0_body.s909.stack.map PRE_first_tail_x6_r0_body.kappa93.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs93 : PRE_first_tail_x6_r0_body.s908.jobs = PRE_first_tail_x6_r0_body.s909.jobs.map PRE_first_tail_x6_r0_body.kappa93.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores93 : PRE_first_tail_x6_r0_body.s908.stores = PRE_first_tail_x6_r0_body.kappa93.stores PRE_first_tail_x6_r0_body.s909.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots93 : checkRootsSupp PRE_first_tail_x6_r0_body.s909 4074 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC93 : PRE_first_tail_x6_r0_body.S907.tab.length + PRE_first_tail_x6_r0_body.cws93.length = 4074
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap93 : PRE_first_tail_x6_r0_body.kappa93 = Conv.Map.compact PRE_first_tail_x6_r0_body.s907.next 2748773 PRE_first_tail_x6_r0_body.S907.tab.length PRE_first_tail_x6_r0_body.pl93 (PRE_first_tail_x6_r0_body.nr93.map NumV.ref) PRE_first_tail_x6_r0_body.kd93.big
  PRE_first_tail_x6_r0_body.kd93.region PRE_first_tail_x6_r0_body.kd93.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin93 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s909.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc93 : Conv.jcleanListB (⟨20049, 17141, 2748423, 4074⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s909 PRE_first_tail_x6_r0_body.cl93 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB93 : noBigRootsP (fun i => !Conv.oldBigB (⟨20049, 17141, 2748423, 4074⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s909.trace PRE_first_tail_x6_r0_body.s909 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm93 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 17135 = true
theorem PRE_first_tail_x6_r0_body.cjcl93 (h : Conv.JClean (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s907) : Conv.JClean (⟨20049, 17141, 2748423, 4074⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s909 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle93)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap93 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd93 a ha)) PRE_first_tail_x6_r0_body.zjc93

end Host.Load.Run.Tpl
end

section -- st93/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st93.bodyLast from PRE_first_tail_x6_r0_body.st93.s2 to PRE_first_tail_x6_r0_body.st93.s3 :
  interpS (step PRE_first_tail_x6_r0_body.st93.F PRE_first_tail_x6_r0_body.st93.s2).run PRE_first_tail_x6_r0_body.st93.S2 = some (PRE_first_tail_x6_r0_body.st93.s3, PRE_first_tail_x6_r0_body.st93.S3)
kernel_rfl PRE_first_tail_x6_r0_body.st93.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st93.s2.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st93.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st93.s3.stack = true

end Host.Load.Run.Tpl
end

section -- st93/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st93.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st93.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st93.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st93.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st93.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st93.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st93.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st93.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st93.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st93.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st93.s0 PRE_first_tail_x6_r0_body.st93.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st93.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st93.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st93.s2 PRE_first_tail_x6_r0_body.st93.S2) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st93/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st93.bodyK0F from PRE_first_tail_x6_r0_body.st93.s0 to PRE_first_tail_x6_r0_body.st93.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st93.F (PRE_first_tail_x6_r0_body.st93.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st93.ks 0).getD 0) PRE_first_tail_x6_r0_body.st93.s0 PRE_first_tail_x6_r0_body.st93.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st93.s1, PRE_first_tail_x6_r0_body.st93.S1)
theorem PRE_first_tail_x6_r0_body.st93.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st93.F (PRE_first_tail_x6_r0_body.st93.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st93.ks 0).getD 0) PRE_first_tail_x6_r0_body.st93.s0 PRE_first_tail_x6_r0_body.st93.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st93.s1, PRE_first_tail_x6_r0_body.st93.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st93.bodyOkLN_ok PRE_first_tail_x6_r0_body.st93.bodyK0F
end Host.Load.Run.Tpl
end

section -- st93/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st93.bodyK1F from PRE_first_tail_x6_r0_body.st93.s1 to PRE_first_tail_x6_r0_body.st93.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st93.F (PRE_first_tail_x6_r0_body.st93.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st93.ks 1).getD 0) PRE_first_tail_x6_r0_body.st93.s1 PRE_first_tail_x6_r0_body.st93.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st93.s2, PRE_first_tail_x6_r0_body.st93.S2)
theorem PRE_first_tail_x6_r0_body.st93.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st93.F (PRE_first_tail_x6_r0_body.st93.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st93.ks 1).getD 0) PRE_first_tail_x6_r0_body.st93.s1 PRE_first_tail_x6_r0_body.st93.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st93.s2, PRE_first_tail_x6_r0_body.st93.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st93.bodyOkLN_ok PRE_first_tail_x6_r0_body.st93.bodyK1F
end Host.Load.Run.Tpl
end

section -- st93/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st93.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st93.F (PRE_first_tail_x6_r0_body.st93.bodyOkL bytes rows) 3452 PRE_first_tail_x6_r0_body.st93.s0 PRE_first_tail_x6_r0_body.st93.S0 = some (PRE_first_tail_x6_r0_body.st93.s2, PRE_first_tail_x6_r0_body.st93.S2) :=
  runOk_trans PRE_first_tail_x6_r0_body.st93.F (PRE_first_tail_x6_r0_body.st93.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st93.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st93.ks 1).getD 0) PRE_first_tail_x6_r0_body.st93.s0 PRE_first_tail_x6_r0_body.st93.s1 PRE_first_tail_x6_r0_body.st93.s2 PRE_first_tail_x6_r0_body.st93.S0 PRE_first_tail_x6_r0_body.st93.S1 PRE_first_tail_x6_r0_body.st93.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st93.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st93.bodyK1 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st93.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st93.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st93.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st93.F (PRE_first_tail_x6_r0_body.st93.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st93.s0
  S0 := PRE_first_tail_x6_r0_body.st93.S0
  s1 := PRE_first_tail_x6_r0_body.st93.s2
  S1 := PRE_first_tail_x6_r0_body.st93.S2
  s2 := PRE_first_tail_x6_r0_body.st93.s3
  S2 := PRE_first_tail_x6_r0_body.st93.S3
  n := 3452
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st93.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st93.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st93.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st93.bodyHalt
  last := PRE_first_tail_x6_r0_body.st93.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st93.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC94
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 94 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s917` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa94` into the merged state
`PRE_first_tail_x6_r0_body.s916`. -/

def PRE_first_tail_x6_r0_body.pl94 : List Nat := []
def PRE_first_tail_x6_r0_body.nr94 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd94 : RData :=
  ⟨2749005, 2749007, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20062, 20062, 17151, 17151, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa94 : Map :=
  Conv.Map.compact 2749005 2749007 4097 PRE_first_tail_x6_r0_body.pl94 (PRE_first_tail_x6_r0_body.nr94.map NumV.ref) PRE_first_tail_x6_r0_body.kd94.big
    PRE_first_tail_x6_r0_body.kd94.region PRE_first_tail_x6_r0_body.kd94.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws94 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs94 : List SymE := PRE_first_tail_x6_r0_body.nr94.map fun r => (nth? PRE_first_tail_x6_r0_body.S916.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta94 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws94 PRE_first_tail_x6_r0_body.crs94
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB94 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab94 : PRE_first_tail_x6_r0_body.S917.tab = PRE_first_tail_x6_r0_body.S915.tab ++ PRE_first_tail_x6_r0_body.cws94.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace94 : PRE_first_tail_x6_r0_body.s917.trace = PRE_first_tail_x6_r0_body.s915.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext94 : PRE_first_tail_x6_r0_body.s917.next = 2749005
kernel_rfl PRE_first_tail_x6_r0_body.ccounters94 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s917.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s917.ffi).mlx.nnext) = (20062, 17151)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue94 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s916.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s917.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa94.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp94 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s917.ffi).mlx.tokens.all (bSN 4097) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean94 : Conv.cleanListB 20062 131072 (fun r => Nat.ble 80248 r) PRE_first_tail_x6_r0_body.s917
    (PRE_first_tail_x6_r0_body.wrB94 ++ (List.range 0).map (2749005 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs94 : bigsOutB 20062 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s917.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK94
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl94`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl94 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo94 : List Nat := []
def PRE_first_tail_x6_r0_body.cln94 : List Nat := []
def PRE_first_tail_x6_r0_body.cli94 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap94 : PRE_first_tail_x6_r0_body.s917.heap = Stage.setAll PRE_first_tail_x6_r0_body.s915.heap (PRE_first_tail_x6_r0_body.cl94.filterMap fun a => (PRE_first_tail_x6_r0_body.s917.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe94 : Nat.ble PRE_first_tail_x6_r0_body.s915.next PRE_first_tail_x6_r0_body.s917.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP94 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s915 PRE_first_tail_x6_r0_body.s917 PRE_first_tail_x6_r0_body.cl94 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp94 : Conv.suppListB PRE_first_tail_x6_r0_body.s917 4097 PRE_first_tail_x6_r0_body.cl94 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound94 : Conv.boundListB PRE_first_tail_x6_r0_body.s917 PRE_first_tail_x6_r0_body.cl94 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK94 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s917.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln94.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s917.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK94 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s917.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo94.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s917.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK94 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s917.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli94.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s917.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst94 : Conv.sstListB 4097 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s917.ffi).mlx PRE_first_tail_x6_r0_body.cln94 PRE_first_tail_x6_r0_body.clo94 PRE_first_tail_x6_r0_body.cli94 = true

end Host.Load.Run.Tpl
end

section -- SiteCl94
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA94 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s917.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo94.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s917.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd94 : (PRE_first_tail_x6_r0_body.clo94 ++ PRE_first_tail_x6_r0_body.cln94 ++ PRE_first_tail_x6_r0_body.cli94).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle94 : Conv.Cnt.leB (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt) (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck94 : Conv.ncleanListB (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s917.ffi).mlx PRE_first_tail_x6_r0_body.clo94 PRE_first_tail_x6_r0_body.cln94 PRE_first_tail_x6_r0_body.cli94 = true
theorem PRE_first_tail_x6_r0_body.cncl94 (h : Conv.NClean (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx) : Conv.NClean (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s917.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle94 PRE_first_tail_x6_r0_body.ckA94 PRE_first_tail_x6_r0_body.cobjsK94 PRE_first_tail_x6_r0_body.cnodesK94 PRE_first_tail_x6_r0_body.citemsK94 PRE_first_tail_x6_r0_body.cbd94 PRE_first_tail_x6_r0_body.cck94

end Host.Load.Run.Tpl
end

section -- SiteS94
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 94 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc94 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P94 : LoadP := PRE_first_tail_x6_r0_body.Pc94.raise 17151
kernel_rfl PRE_first_tail_x6_r0_body.craise94 : Nat.ble PRE_first_tail_x6_r0_body.Pc94.N0 17151 = true
theorem PRE_first_tail_x6_r0_body.raised94 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc94 PRE_first_tail_x6_r0_body.P94 :=
  .inr ⟨17151, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise94, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_94 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s917.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_94 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s916.ffi)
def PRE_first_tail_x6_r0_body.khinv94 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv94 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS94 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS94 : List Nat := List.range' 17151 0
def PRE_first_tail_x6_r0_body.ciS94 : List Nat := [] ++ List.range' 17151 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh094 : PRE_first_tail_x6_r0_body.kd94.nh0 = PRE_first_tail_x6_r0_body.cx0_94.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh194 : PRE_first_tail_x6_r0_body.kd94.nh1 = PRE_first_tail_x6_r0_body.cx1_94.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn094 : PRE_first_tail_x6_r0_body.kd94.nn0 = PRE_first_tail_x6_r0_body.cx0_94.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn194 : PRE_first_tail_x6_r0_body.kd94.nn1 = PRE_first_tail_x6_r0_body.cx1_94.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo94 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P94.lo && Nat.ble PRE_first_tail_x6_r0_body.P94.lo PRE_first_tail_x6_r0_body.cx0_94.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P94.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P94.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt94 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_94.mlx.next PRE_first_tail_x6_r0_body.cx1_94.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_94.mlx.nnext PRE_first_tail_x6_r0_body.cx1_94.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband94 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P94.NL && Nat.ble PRE_first_tail_x6_r0_body.P94.NL PRE_first_tail_x6_r0_body.P94.N0 && Nat.ble PRE_first_tail_x6_r0_body.P94.N0 PRE_first_tail_x6_r0_body.cx0_94.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow94 : PRE_first_tail_x6_r0_body.kd94.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren94 : checkRenG PRE_first_tail_x6_r0_body.kd94.hnd PRE_first_tail_x6_r0_body.khinv94 (phB PRE_first_tail_x6_r0_body.cx0_94.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband94 : PRE_first_tail_x6_r0_body.kd94.checkBand PRE_first_tail_x6_r0_body.P94.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos94 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd94.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren94 : checkRenG PRE_first_tail_x6_r0_body.kd94.node PRE_first_tail_x6_r0_body.kninv94 (pnB PRE_first_tail_x6_r0_body.cx0_94.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow94 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd94.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P94.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd94.nodeF j) PRE_first_tail_x6_r0_body.cx1_94.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a94 : PRE_first_tail_x6_r0_body.cx0_94.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b94 : PRE_first_tail_x6_r0_body.cx0_94.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok194 : PRE_first_tail_x6_r0_body.cx1_94.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend94 : PRE_first_tail_x6_r0_body.cx1_94.mlx.pending = PRE_first_tail_x6_r0_body.cx0_94.mlx.pending.map PRE_first_tail_x6_r0_body.kappa94.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh94 : PRE_first_tail_x6_r0_body.cx1_94.mlx.errh = PRE_first_tail_x6_r0_body.cx0_94.mlx.errh.map PRE_first_tail_x6_r0_body.kappa94.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles94 : PRE_first_tail_x6_r0_body.cx1_94.mlx.files = PRE_first_tail_x6_r0_body.cx0_94.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch94 : PRE_first_tail_x6_r0_body.cx1_94.mlx.arch = PRE_first_tail_x6_r0_body.cx0_94.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes94 : PRE_first_tail_x6_r0_body.cx1_94.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_94.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired94 : PRE_first_tail_x6_r0_body.cx1_94.mlx.wired = PRE_first_tail_x6_r0_body.cx0_94.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost94 : PRE_first_tail_x6_r0_body.cx1_94.host = PRE_first_tail_x6_r0_body.cx0_94.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd94`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn094 : PRE_first_tail_x6_r0_body.kd94.n0 = 2749005
kernel_rfl PRE_first_tail_x6_r0_body.ckn194 : PRE_first_tail_x6_r0_body.kd94.n1 = 2749007
kernel_rfl PRE_first_tail_x6_r0_body.ckheap94 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd94.heap).all (fun x => Nat.ble 2749005 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl94 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_body.kd94.heap.get (2749005 + j) = nth? PRE_first_tail_x6_r0_body.pl94 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja94 : Nat.ble 2749005 2749005 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn94 : Nat.ble 4097 4097 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD94 : Nat.ble 2749005 PRE_first_tail_x6_r0_body.kd94.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn94 : Nat.ble 20062 PRE_first_tail_x6_r0_body.kd94.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn94 : Nat.ble 17151 PRE_first_tail_x6_r0_body.kd94.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb94 : Nat.ble 20062 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap94 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd94.heap).all (Nat.ble (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd94 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd94.hnd).all (Nat.ble (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode94 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd94.node).all (Nat.ble (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix94 : Conv.FixOld (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa94 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja94) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn94) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD94) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn94) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn94) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb94) PRE_first_tail_x6_r0_body.fheap94 PRE_first_tail_x6_r0_body.fhnd94 PRE_first_tail_x6_r0_body.fnode94
kernel_rfl PRE_first_tail_x6_r0_body.fcxn94 : (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn94 : (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle094 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_94.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_94.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk94 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd94.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A94 : PRE_first_tail_x6_r0_body.cx1_94.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS94.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_94.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O94 : PRE_first_tail_x6_r0_body.cx1_94.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS94.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_94.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N94 : PRE_first_tail_x6_r0_body.cx1_94.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS94.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_94.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I94 : PRE_first_tail_x6_r0_body.cx1_94.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS94.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_94.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd94 : (PRE_first_tail_x6_r0_body.clo94 ++ PRE_first_tail_x6_r0_body.cln94 ++ PRE_first_tail_x6_r0_body.cli94 ++ PRE_first_tail_x6_r0_body.cwS94 ++ PRE_first_tail_x6_r0_body.cnS94 ++ PRE_first_tail_x6_r0_body.ciS94).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW94 : PRE_first_tail_x6_r0_body.cwS94.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo94.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI94 : PRE_first_tail_x6_r0_body.ciS94.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli94.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN94 : PRE_first_tail_x6_r0_body.cnS94.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF94 : PRE_first_tail_x6_r0_body.cln94.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh94 : PRE_first_tail_x6_r0_body.clo94.all (handleOK PRE_first_tail_x6_r0_body.kappa94 PRE_first_tail_x6_r0_body.P94.lo PRE_first_tail_x6_r0_body.cx0_94.mlx PRE_first_tail_x6_r0_body.cx1_94.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo94 : PRE_first_tail_x6_r0_body.clo94.map (fun h => PRE_first_tail_x6_r0_body.cx1_94.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa94.handle h)) = PRE_first_tail_x6_r0_body.clo94.map (fun h => (PRE_first_tail_x6_r0_body.cx0_94.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa94.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok94 : PRE_first_tail_x6_r0_body.clo94.all (objOK PRE_first_tail_x6_r0_body.kappa94 PRE_first_tail_x6_r0_body.P94.NL PRE_first_tail_x6_r0_body.cx0_94.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd94 : PRE_first_tail_x6_r0_body.cln94.all (nodeOKF PRE_first_tail_x6_r0_body.kappa94 PRE_first_tail_x6_r0_body.P94 PRE_first_tail_x6_r0_body.cx0_94.mlx PRE_first_tail_x6_r0_body.cx1_94.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp94 : ((PRE_first_tail_x6_r0_body.cln94.filter (fullB PRE_first_tail_x6_r0_body.P94))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_94.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa94.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln94.filter (fullB PRE_first_tail_x6_r0_body.P94))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_94.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa94.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI94 : incrB PRE_first_tail_x6_r0_body.kd94.nodeF (List.range' 17151 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK94 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd94.node).all (fun k => Nat.ble 17151 k && Nat.blt k 17151) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL94 : (PRE_first_tail_x6_r0_body.cln94.filter (Nat.ble PRE_first_tail_x6_r0_body.P94.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd94.nodeF i) && (Nat.blt i 17151 || Nat.ble PRE_first_tail_x6_r0_body.kd94.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord94 : (PRE_first_tail_x6_r0_body.cln94.filter (Nat.ble PRE_first_tail_x6_r0_body.P94.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd94.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd94.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd94.nodeF j) (PRE_first_tail_x6_r0_body.kd94.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow94 PRE_first_tail_x6_r0_body.cnn194 PRE_first_tail_x6_r0_body.fnordI94 PRE_first_tail_x6_r0_body.fnordK94 PRE_first_tail_x6_r0_body.fnordL94
kernel_rfl PRE_first_tail_x6_r0_body.fi94 : PRE_first_tail_x6_r0_body.cli94.all (pnB PRE_first_tail_x6_r0_body.cx0_94.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii94 : PRE_first_tail_x6_r0_body.cli94.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_94.mlx.items.get (PRE_first_tail_x6_r0_body.kappa94.node k) = (PRE_first_tail_x6_r0_body.cx0_94.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa94.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot94 (clean : Conv.NClean (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P94.NL) (cl : SSt (· < 4097) PRE_first_tail_x6_r0_body.cx0_94.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P94 4097 PRE_first_tail_x6_r0_body.kappa94 PRE_first_tail_x6_r0_body.kd94 PRE_first_tail_x6_r0_body.khinv94 PRE_first_tail_x6_r0_body.kninv94 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx PRE_first_tail_x6_r0_body.cx0_94.mlx PRE_first_tail_x6_r0_body.cx1_94.mlx (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo94 PRE_first_tail_x6_r0_body.cln94 PRE_first_tail_x6_r0_body.cli94 PRE_first_tail_x6_r0_body.cwS94 PRE_first_tail_x6_r0_body.cnS94 PRE_first_tail_x6_r0_body.ciS94 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh094, PRE_first_tail_x6_r0_body.cnh194, PRE_first_tail_x6_r0_body.cnn094, PRE_first_tail_x6_r0_body.cnn194, PRE_first_tail_x6_r0_body.cplo94, PRE_first_tail_x6_r0_body.ccnt94, PRE_first_tail_x6_r0_body.cnband94, PRE_first_tail_x6_r0_body.chbelow94, PRE_first_tail_x6_r0_body.chren94, PRE_first_tail_x6_r0_body.cband94, PRE_first_tail_x6_r0_body.cnh1pos94, PRE_first_tail_x6_r0_body.cnren94, PRE_first_tail_x6_r0_body.cnlow94, PRE_first_tail_x6_r0_body.cabs0a94, PRE_first_tail_x6_r0_body.cabs0b94, PRE_first_tail_x6_r0_body.ctok194, PRE_first_tail_x6_r0_body.cpend94, PRE_first_tail_x6_r0_body.cerrh94, PRE_first_tail_x6_r0_body.cfiles94, PRE_first_tail_x6_r0_body.carch94, PRE_first_tail_x6_r0_body.csizes94, PRE_first_tail_x6_r0_body.cwired94, PRE_first_tail_x6_r0_body.cfix94, clean, PRE_first_tail_x6_r0_body.fcxn94, PRE_first_tail_x6_r0_body.fcnn94, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle094, PRE_first_tail_x6_r0_body.fnk94, PRE_first_tail_x6_r0_body.ckA94, PRE_first_tail_x6_r0_body.cobjsK94, PRE_first_tail_x6_r0_body.cnodesK94, PRE_first_tail_x6_r0_body.citemsK94, PRE_first_tail_x6_r0_body.f1A94, PRE_first_tail_x6_r0_body.f1O94, PRE_first_tail_x6_r0_body.f1N94, PRE_first_tail_x6_r0_body.f1I94, PRE_first_tail_x6_r0_body.fbd94, PRE_first_tail_x6_r0_body.fincW94, PRE_first_tail_x6_r0_body.fincI94, PRE_first_tail_x6_r0_body.fincN94, PRE_first_tail_x6_r0_body.flnF94, PRE_first_tail_x6_r0_body.fh94, PRE_first_tail_x6_r0_body.fo94, PRE_first_tail_x6_r0_body.fok94, PRE_first_tail_x6_r0_body.fnd94, PRE_first_tail_x6_r0_body.fp94, PRE_first_tail_x6_r0_body.fnord94, PRE_first_tail_x6_r0_body.fi94, PRE_first_tail_x6_r0_body.fii94⟩
theorem PRE_first_tail_x6_r0_body.cnshift94 (clean : Conv.NClean (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P94.NL) (cl : SSt (· < 4097) PRE_first_tail_x6_r0_body.cx0_94.mlx) : NShift PRE_first_tail_x6_r0_body.P94 4097 PRE_first_tail_x6_r0_body.kappa94 PRE_first_tail_x6_r0_body.cx0_94 PRE_first_tail_x6_r0_body.cx1_94 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot94 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost94 (compact_a_eq PRE_first_tail_x6_r0_body.ckn094 PRE_first_tail_x6_r0_body.ckn194 PRE_first_tail_x6_r0_body.ckheap94 PRE_first_tail_x6_r0_body.ckpl94)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_94 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s915.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_94 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s915.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_94 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s915.ffi) = some PRE_first_tail_x6_r0_body.fxC_94
kernel_rfl PRE_first_tail_x6_r0_body.okrC_94 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s915.ffi) = some PRE_first_tail_x6_r0_body.krC_94
noncomputable def PRE_first_tail_x6_r0_body.fx0_94 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s917.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_94 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s917.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_94 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s917.ffi) = some PRE_first_tail_x6_r0_body.fx0_94
kernel_rfl PRE_first_tail_x6_r0_body.okr0_94 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s917.ffi) = some PRE_first_tail_x6_r0_body.kr0_94
noncomputable def PRE_first_tail_x6_r0_body.fx1_94 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s916.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_94 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s916.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_94 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s916.ffi) = some PRE_first_tail_x6_r0_body.fx1_94
kernel_rfl PRE_first_tail_x6_r0_body.okr1_94 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s916.ffi) = some PRE_first_tail_x6_r0_body.kr1_94
kernel_rfl PRE_first_tail_x6_r0_body.ff094 : PRE_first_tail_x6_r0_body.fx0_94 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_94 (PRE_first_tail_x6_r0_body.clo94.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_94.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff194 : PRE_first_tail_x6_r0_body.fx1_94 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_94 (PRE_first_tail_x6_r0_body.cwS94.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_94.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck94 : freedLB PRE_first_tail_x6_r0_body.kappa94 PRE_first_tail_x6_r0_body.cx0_94.mlx PRE_first_tail_x6_r0_body.fx0_94 PRE_first_tail_x6_r0_body.fx1_94 PRE_first_tail_x6_r0_body.clo94 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf094 : PRE_first_tail_x6_r0_body.kr0_94.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_94.flags (PRE_first_tail_x6_r0_body.clo94.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_94.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt094 : PRE_first_tail_x6_r0_body.kr0_94.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_94.targs (PRE_first_tail_x6_r0_body.clo94.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_94.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf194 : PRE_first_tail_x6_r0_body.kr1_94.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_94.flags (PRE_first_tail_x6_r0_body.cwS94.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_94.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt194 : PRE_first_tail_x6_r0_body.kr1_94.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_94.targs (PRE_first_tail_x6_r0_body.cwS94.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_94.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck94 : krecLB PRE_first_tail_x6_r0_body.kappa94 4097 PRE_first_tail_x6_r0_body.cx0_94.mlx PRE_first_tail_x6_r0_body.kr0_94 PRE_first_tail_x6_r0_body.kr1_94 PRE_first_tail_x6_r0_body.clo94 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn94 : Nat.ble 4097 4097 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge94 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s916.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s917.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR94 : pendRegB PRE_first_tail_x6_r0_body.kappa94 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s917.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe94 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s917.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s916.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift94 (clean : Conv.NClean (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P94.NL) (cl : SSt (· < 4097) PRE_first_tail_x6_r0_body.cx0_94.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_94.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_94.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_94.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s915.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_94.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P94 4097 PRE_first_tail_x6_r0_body.kappa94 PRE_first_tail_x6_r0_body.s917.ffi PRE_first_tail_x6_r0_body.s916.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift94 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue94, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp94 t ht),
    PRE_first_tail_x6_r0_body.cbridge94,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s917.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s916.ffi) (PRE_first_tail_x6_r0_body.cfoot94 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_94 PRE_first_tail_x6_r0_body.ofx1_94 hobjC PRE_first_tail_x6_r0_body.ff094 PRE_first_tail_x6_r0_body.ff194 PRE_first_tail_x6_r0_body.ffck94,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s917.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s916.ffi) (PRE_first_tail_x6_r0_body.cfoot94 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_94 PRE_first_tail_x6_r0_body.okr1_94 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn94) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf094 PRE_first_tail_x6_r0_body.fkt094 PRE_first_tail_x6_r0_body.fkf194 PRE_first_tail_x6_r0_body.fkt194 PRE_first_tail_x6_r0_body.fkck94,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh094 PRE_first_tail_x6_r0_body.cnh194 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe94) PRE_first_tail_x6_r0_body.cpendR94⟩

end Host.Load.Run.Tpl
end

section -- st94/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st94 0
host_stream_state PRE_first_tail_x6_r0_body.st94 1
host_stream_state PRE_first_tail_x6_r0_body.st94 2
end Host.Load.Run.Tpl
end

section -- Site94
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 94 of chain `PRE_first_tail_x6_r0_body`: `rowBlocks__g94__g95` (`rowBlocks`), the call state `PRE_first_tail_x6_r0_body.s915`, the merged state `PRE_first_tail_x6_r0_body.s916`,
the site template `PRE_first_tail_x6_r0_body.st94` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s917`: the merge.
The footprint's facts are in `SiteF94`, the compaction's in `SiteC94`, `SiteK94`, `SiteNa94`, `SiteNb94`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso94 : PRE_first_tail_x6_r0_body.st94.s0 = { PRE_first_tail_x6_r0_body.s915 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs94 : List Frame := PRE_first_tail_x6_r0_body.s915.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_94 : PRE_first_tail_x6_r0_body.S915.tab.length = 4097
kernel_rfl PRE_first_tail_x6_r0_body.tab0_94 : PRE_first_tail_x6_r0_body.st94.S0.tab = PRE_first_tail_x6_r0_body.S915.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws94 : List Nat := [2587, 2588]
kernel_rfl PRE_first_tail_x6_r0_body.fresh94 : (PRE_first_tail_x6_r0_body.S915.tab.all fun e => PRE_first_tail_x6_r0_body.ws94.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S915.oracle.all fun q => PRE_first_tail_x6_r0_body.ws94.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab94 : PRE_first_tail_x6_r0_body.S916.tab = PRE_first_tail_x6_r0_body.S915.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws94
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen94 : PRE_first_tail_x6_r0_body.st94.S2.tab.length - PRE_first_tail_x6_r0_body.st94.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged94`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap94 : PRE_first_tail_x6_r0_body.s916.heap = PRE_first_tail_x6_r0_body.st94.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext94 : PRE_first_tail_x6_r0_body.s916.next = PRE_first_tail_x6_r0_body.st94.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl94 : PRE_first_tail_x6_r0_body.s916.ctl = PRE_first_tail_x6_r0_body.st94.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack94 : PRE_first_tail_x6_r0_body.s916.stack = PRE_first_tail_x6_r0_body.st94.s2.stack ++ PRE_first_tail_x6_r0_body.s915.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs94 : PRE_first_tail_x6_r0_body.s916.jobs = PRE_first_tail_x6_r0_body.st94.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi94 : PRE_first_tail_x6_r0_body.s916.ffi = PRE_first_tail_x6_r0_body.st94.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace94 : PRE_first_tail_x6_r0_body.s916.trace = PRE_first_tail_x6_r0_body.st94.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores94 : PRE_first_tail_x6_r0_body.s916.stores = PRE_first_tail_x6_r0_body.st94.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD94
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 94 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived94 : PRE_first_tail_x6_r0_body.nr94.map (fun r => nth? PRE_first_tail_x6_r0_body.st94.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo94 : PRE_first_tail_x6_r0_body.nr94.all (Nat.ble 4097) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj94 : PRE_first_tail_x6_r0_body.cws94.all (fun c => !PRE_first_tail_x6_r0_body.ws94.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ94 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws94 PRE_first_tail_x6_r0_body.crs94 PRE_first_tail_x6_r0_body.ws94

end Host.Load.Run.Tpl
end

section -- st94/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st94`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st94.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st94.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st94.s2.heap PRE_first_tail_x6_r0_body.st94.wrR ++ freshOf PRE_first_tail_x6_r0_body.st94.s2.heap PRE_first_tail_x6_r0_body.st94.s0.next PRE_first_tail_x6_r0_body.st94.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st94.wr : List Nat := PRE_first_tail_x6_r0_body.st94.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st94.heapFoot : PRE_first_tail_x6_r0_body.st94.s2.heap = setAll PRE_first_tail_x6_r0_body.st94.s0.heap PRE_first_tail_x6_r0_body.st94.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st94.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st94.s0.next PRE_first_tail_x6_r0_body.st94.s2.next = true
theorem PRE_first_tail_x6_r0_body.st94.grows : PRE_first_tail_x6_r0_body.st94.s0.next ≤ PRE_first_tail_x6_r0_body.st94.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st94.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st94.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st94.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st94.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st94.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st94.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st94.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st94.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st94.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st94.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st94.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st94.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st94.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st94.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st94.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st94.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st94.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st94.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st94.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st94.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st94.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st94.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st94.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st94.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st94.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st94.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st94.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st94.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st94.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st94.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st94.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st94.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF94
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 94 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB94 : nodupT PRE_first_tail_x6_r0_body.st94.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup94 : PRE_first_tail_x6_r0_body.st94.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB94).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB94 : PRE_first_tail_x6_r0_body.st94.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound94 : ∀ b ∈ PRE_first_tail_x6_r0_body.st94.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB94 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr94 := PRE_first_tail_x6_r0_body.st94.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq94 : PRE_first_tail_x6_r0_body.st94.s2.trace = PRE_first_tail_x6_r0_body.trFr94 ++ PRE_first_tail_x6_r0_body.st94.s0.trace
theorem PRE_first_tail_x6_r0_body.trace94 : ∃ fr, PRE_first_tail_x6_r0_body.st94.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st94.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq94⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide94 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB94 : (PRE_first_tail_x6_r0_body.wide94.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st94.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix94 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide94, WFix Map.id (Present PRE_first_tail_x6_r0_body.st94.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB94 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL94
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 94 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s916`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO94 : PRE_first_tail_x6_r0_body.st94.S0.oracle = PRE_first_tail_x6_r0_body.st94.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B94 : PRE_first_tail_x6_r0_body.st94.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st94.s0.next || (PRE_first_tail_x6_r0_body.st94.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot94 : Conv.StageFoot PRE_first_tail_x6_r0_body.st94.wr PRE_first_tail_x6_r0_body.st94.s0 PRE_first_tail_x6_r0_body.st94.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st94.heapFoot PRE_first_tail_x6_r0_body.wrNodup94 PRE_first_tail_x6_r0_body.wrBound94 PRE_first_tail_x6_r0_body.wr0B94 PRE_first_tail_x6_r0_body.st94.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged94 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st94.F.S → PRE_first_tail_x6_r0_body.st94.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st94.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st94.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs94 PRE_first_tail_x6_r0_body.st94.wr PRE_first_tail_x6_r0_body.s915 PRE_first_tail_x6_r0_body.st94.s2 PRE_first_tail_x6_r0_body.st94.s0
      PRE_first_tail_x6_r0_body.st94.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st94.F FR W stk M ν K PRE_first_tail_x6_r0_body.s916 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso94 PRE_first_tail_x6_r0_body.stFoot94 PRE_first_tail_x6_r0_body.wrNodup94 PRE_first_tail_x6_r0_body.wrBound94 PRE_first_tail_x6_r0_body.trace94 PRE_first_tail_x6_r0_body.mheap94
    PRE_first_tail_x6_r0_body.mnext94 PRE_first_tail_x6_r0_body.mctl94 PRE_first_tail_x6_r0_body.mstack94 PRE_first_tail_x6_r0_body.mjobs94 PRE_first_tail_x6_r0_body.mffi94 PRE_first_tail_x6_r0_body.mtrace94 PRE_first_tail_x6_r0_body.mstores94 h

def PRE_first_tail_x6_r0_body.arrEl94_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE94_2665 : arrOf PRE_first_tail_x6_r0_body.s916 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl94_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA94_2665 : isArrB PRE_first_tail_x6_r0_body.s916 2665 = true
theorem PRE_first_tail_x6_r0_body.arr94_2665 : ∃ o, PRE_first_tail_x6_r0_body.s916.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl94_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE94_2665 PRE_first_tail_x6_r0_body.arrA94_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN94_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl94_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR94_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl94_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN94_2665

def PRE_first_tail_x6_r0_body.arrEl94_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE94_2673467 : arrOf PRE_first_tail_x6_r0_body.s916 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl94_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA94_2673467 : isArrB PRE_first_tail_x6_r0_body.s916 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr94_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s916.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl94_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE94_2673467 PRE_first_tail_x6_r0_body.arrA94_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN94_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl94_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR94_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl94_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN94_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k94 : isArrB PRE_first_tail_x6_r0_body.s916 4910 = false
theorem PRE_first_tail_x6_r0_body.keep94 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s916 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k94 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr94_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl94_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ94
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 94 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s915`, the merged
state `PRE_first_tail_x6_r0_body.s916`, the canonical state `PRE_first_tail_x6_r0_body.s917`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl94 : PRE_first_tail_x6_r0_body.pl94.all (Nat.ble PRE_first_tail_x6_r0_body.s915.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd94 : nodupT PRE_first_tail_x6_r0_body.pl94 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn194 : Nat.ble PRE_first_tail_x6_r0_body.s915.next 2749007 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst94 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s915.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn94 : PRE_first_tail_x6_r0_body.s917.next = PRE_first_tail_x6_r0_body.s915.next + PRE_first_tail_x6_r0_body.pl94.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn94 : PRE_first_tail_x6_r0_body.s916.next = 2749007
kernel_rfl PRE_first_tail_x6_r0_body.zgrow94 : Nat.ble PRE_first_tail_x6_r0_body.s917.next PRE_first_tail_x6_r0_body.s916.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh94 : PRE_first_tail_x6_r0_body.S915.tab.all (fun e => PRE_first_tail_x6_r0_body.cws94.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd94 : nodupT PRE_first_tail_x6_r0_body.cws94 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi94 : PRE_first_tail_x6_r0_body.nr94.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S916.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt94 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s915.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg94_2665 : PRE_first_tail_x6_r0_body.s917.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s917 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk94_2665 : (objOf PRE_first_tail_x6_r0_body.s917 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm94_2665 : PRE_first_tail_x6_r0_body.s916.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa94.obj (objOf PRE_first_tail_x6_r0_body.s917 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s916 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg94_2673467 : PRE_first_tail_x6_r0_body.s917.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s917 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk94_2673467 : (objOf PRE_first_tail_x6_r0_body.s917 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm94_2673467 : PRE_first_tail_x6_r0_body.s916.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa94.obj (objOf PRE_first_tail_x6_r0_body.s917 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s916 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw94_4910 : (PRE_first_tail_x6_r0_body.s917.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw94_2673472 : (PRE_first_tail_x6_r0_body.s917.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw94_2673473 : (PRE_first_tail_x6_r0_body.s917.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd94 : PRE_first_tail_x6_r0_body.cl94.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr94 : PRE_first_tail_x6_r0_body.st94.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s915.next || PRE_first_tail_x6_r0_body.cl94.contains b) = true
def PRE_first_tail_x6_r0_body.zl94 : List Nat := PRE_first_tail_x6_r0_body.cl94.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE94 : PRE_first_tail_x6_r0_body.zl94.map (fun a => PRE_first_tail_x6_r0_body.s916.heap.get (PRE_first_tail_x6_r0_body.kappa94.a a)) = PRE_first_tail_x6_r0_body.zl94.map (fun a => (PRE_first_tail_x6_r0_body.s917.heap.get a).map PRE_first_tail_x6_r0_body.kappa94.hobj)
theorem PRE_first_tail_x6_r0_body.zimg94 : HeapImg PRE_first_tail_x6_r0_body.kappa94 PRE_first_tail_x6_r0_body.s917 PRE_first_tail_x6_r0_body.s916 PRE_first_tail_x6_r0_body.zl94 := PRE_first_tail_x6_r0_body.zimgE94
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl94 : PRE_first_tail_x6_r0_body.s916.ctl = PRE_first_tail_x6_r0_body.kappa94.ctl PRE_first_tail_x6_r0_body.s917.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack94 : PRE_first_tail_x6_r0_body.s916.stack = PRE_first_tail_x6_r0_body.s917.stack.map PRE_first_tail_x6_r0_body.kappa94.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs94 : PRE_first_tail_x6_r0_body.s916.jobs = PRE_first_tail_x6_r0_body.s917.jobs.map PRE_first_tail_x6_r0_body.kappa94.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores94 : PRE_first_tail_x6_r0_body.s916.stores = PRE_first_tail_x6_r0_body.kappa94.stores PRE_first_tail_x6_r0_body.s917.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots94 : checkRootsSupp PRE_first_tail_x6_r0_body.s917 4097 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC94 : PRE_first_tail_x6_r0_body.S915.tab.length + PRE_first_tail_x6_r0_body.cws94.length = 4097
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap94 : PRE_first_tail_x6_r0_body.kappa94 = Conv.Map.compact PRE_first_tail_x6_r0_body.s915.next 2749007 PRE_first_tail_x6_r0_body.S915.tab.length PRE_first_tail_x6_r0_body.pl94 (PRE_first_tail_x6_r0_body.nr94.map NumV.ref) PRE_first_tail_x6_r0_body.kd94.big
  PRE_first_tail_x6_r0_body.kd94.region PRE_first_tail_x6_r0_body.kd94.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin94 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s917.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc94 : Conv.jcleanListB (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s917 PRE_first_tail_x6_r0_body.cl94 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB94 : noBigRootsP (fun i => !Conv.oldBigB (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s917.trace PRE_first_tail_x6_r0_body.s917 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm94 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 17151 = true
theorem PRE_first_tail_x6_r0_body.cjcl94 (h : Conv.JClean (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s915) : Conv.JClean (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s917 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle94)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap94 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd94 a ha)) PRE_first_tail_x6_r0_body.zjc94

end Host.Load.Run.Tpl
end

section -- st94/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st94.bodyLast from PRE_first_tail_x6_r0_body.st94.s1 to PRE_first_tail_x6_r0_body.st94.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st94.F PRE_first_tail_x6_r0_body.st94.s1).run PRE_first_tail_x6_r0_body.st94.S1 = some (PRE_first_tail_x6_r0_body.st94.s2, PRE_first_tail_x6_r0_body.st94.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st94.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st94.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st94.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st94.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st94/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st94.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st94.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st94.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st94.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st94.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st94.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st94.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st94.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st94.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st94.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st94.s0 PRE_first_tail_x6_r0_body.st94.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st94.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st94.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st94.s1 PRE_first_tail_x6_r0_body.st94.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st94/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st94.bodyK0F from PRE_first_tail_x6_r0_body.st94.s0 to PRE_first_tail_x6_r0_body.st94.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st94.F (PRE_first_tail_x6_r0_body.st94.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st94.ks 0).getD 0) PRE_first_tail_x6_r0_body.st94.s0 PRE_first_tail_x6_r0_body.st94.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st94.s1, PRE_first_tail_x6_r0_body.st94.S1)
theorem PRE_first_tail_x6_r0_body.st94.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st94.F (PRE_first_tail_x6_r0_body.st94.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st94.ks 0).getD 0) PRE_first_tail_x6_r0_body.st94.s0 PRE_first_tail_x6_r0_body.st94.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st94.s1, PRE_first_tail_x6_r0_body.st94.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st94.bodyOkLN_ok PRE_first_tail_x6_r0_body.st94.bodyK0F
end Host.Load.Run.Tpl
end

section -- st94/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st94.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st94.F (PRE_first_tail_x6_r0_body.st94.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st94.s0 PRE_first_tail_x6_r0_body.st94.S0 = some (PRE_first_tail_x6_r0_body.st94.s1, PRE_first_tail_x6_r0_body.st94.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st94.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st94.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st94.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st94.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st94.F (PRE_first_tail_x6_r0_body.st94.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st94.s0
  S0 := PRE_first_tail_x6_r0_body.st94.S0
  s1 := PRE_first_tail_x6_r0_body.st94.s1
  S1 := PRE_first_tail_x6_r0_body.st94.S1
  s2 := PRE_first_tail_x6_r0_body.st94.s2
  S2 := PRE_first_tail_x6_r0_body.st94.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st94.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st94.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st94.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st94.bodyHalt
  last := PRE_first_tail_x6_r0_body.st94.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st94.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC95
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 95 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s921` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa95` into the merged state
`PRE_first_tail_x6_r0_body.s920`. -/

def PRE_first_tail_x6_r0_body.pl95 : List Nat := [2749312]
def PRE_first_tail_x6_r0_body.nr95 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd95 : RData :=
  ⟨2749294, 2749313, Stage.setAll PTrie.nil [(2749293, 2749312)], Stage.setAll PTrie.nil [],
   20069, 20069, 17155, 17155, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa95 : Map :=
  Conv.Map.compact 2749293 2749313 4114 PRE_first_tail_x6_r0_body.pl95 (PRE_first_tail_x6_r0_body.nr95.map NumV.ref) PRE_first_tail_x6_r0_body.kd95.big
    PRE_first_tail_x6_r0_body.kd95.region PRE_first_tail_x6_r0_body.kd95.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws95 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs95 : List SymE := PRE_first_tail_x6_r0_body.nr95.map fun r => (nth? PRE_first_tail_x6_r0_body.S920.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta95 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws95 PRE_first_tail_x6_r0_body.crs95
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB95 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab95 : PRE_first_tail_x6_r0_body.S921.tab = PRE_first_tail_x6_r0_body.S919.tab ++ PRE_first_tail_x6_r0_body.cws95.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace95 : PRE_first_tail_x6_r0_body.s921.trace = PRE_first_tail_x6_r0_body.s919.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext95 : PRE_first_tail_x6_r0_body.s921.next = 2749294
kernel_rfl PRE_first_tail_x6_r0_body.ccounters95 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s921.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s921.ffi).mlx.nnext) = (20069, 17155)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue95 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s920.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s921.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa95.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp95 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s921.ffi).mlx.tokens.all (bSN 4114) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean95 : Conv.cleanListB 20069 131072 (fun r => Nat.ble 80276 r) PRE_first_tail_x6_r0_body.s921
    (PRE_first_tail_x6_r0_body.wrB95 ++ (List.range 1).map (2749293 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs95 : bigsOutB 20069 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s921.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK95
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl95`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl95 : List Nat := [2665, 2673467, 2749293]
def PRE_first_tail_x6_r0_body.clo95 : List Nat := []
def PRE_first_tail_x6_r0_body.cln95 : List Nat := []
def PRE_first_tail_x6_r0_body.cli95 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap95 : PRE_first_tail_x6_r0_body.s921.heap = Stage.setAll PRE_first_tail_x6_r0_body.s919.heap (PRE_first_tail_x6_r0_body.cl95.filterMap fun a => (PRE_first_tail_x6_r0_body.s921.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe95 : Nat.ble PRE_first_tail_x6_r0_body.s919.next PRE_first_tail_x6_r0_body.s921.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP95 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s919 PRE_first_tail_x6_r0_body.s921 PRE_first_tail_x6_r0_body.cl95 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp95 : Conv.suppListB PRE_first_tail_x6_r0_body.s921 4114 PRE_first_tail_x6_r0_body.cl95 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound95 : Conv.boundListB PRE_first_tail_x6_r0_body.s921 PRE_first_tail_x6_r0_body.cl95 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK95 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s921.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln95.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s921.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK95 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s921.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo95.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s921.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK95 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s921.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli95.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s921.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst95 : Conv.sstListB 4114 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s921.ffi).mlx PRE_first_tail_x6_r0_body.cln95 PRE_first_tail_x6_r0_body.clo95 PRE_first_tail_x6_r0_body.cli95 = true

end Host.Load.Run.Tpl
end

section -- SiteCl95
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA95 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s921.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo95.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s921.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd95 : (PRE_first_tail_x6_r0_body.clo95 ++ PRE_first_tail_x6_r0_body.cln95 ++ PRE_first_tail_x6_r0_body.cli95).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle95 : Conv.Cnt.leB (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt) (⟨20069, 17155, 2749294, 4114⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck95 : Conv.ncleanListB (⟨20069, 17155, 2749294, 4114⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s921.ffi).mlx PRE_first_tail_x6_r0_body.clo95 PRE_first_tail_x6_r0_body.cln95 PRE_first_tail_x6_r0_body.cli95 = true
theorem PRE_first_tail_x6_r0_body.cncl95 (h : Conv.NClean (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx) : Conv.NClean (⟨20069, 17155, 2749294, 4114⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s921.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle95 PRE_first_tail_x6_r0_body.ckA95 PRE_first_tail_x6_r0_body.cobjsK95 PRE_first_tail_x6_r0_body.cnodesK95 PRE_first_tail_x6_r0_body.citemsK95 PRE_first_tail_x6_r0_body.cbd95 PRE_first_tail_x6_r0_body.cck95

end Host.Load.Run.Tpl
end

section -- SiteS95
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 95 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc95 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P95 : LoadP := PRE_first_tail_x6_r0_body.Pc95.raise 17155
kernel_rfl PRE_first_tail_x6_r0_body.craise95 : Nat.ble PRE_first_tail_x6_r0_body.Pc95.N0 17155 = true
theorem PRE_first_tail_x6_r0_body.raised95 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc95 PRE_first_tail_x6_r0_body.P95 :=
  .inr ⟨17155, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise95, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_95 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s921.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_95 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s920.ffi)
def PRE_first_tail_x6_r0_body.khinv95 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv95 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS95 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS95 : List Nat := List.range' 17155 0
def PRE_first_tail_x6_r0_body.ciS95 : List Nat := [] ++ List.range' 17155 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh095 : PRE_first_tail_x6_r0_body.kd95.nh0 = PRE_first_tail_x6_r0_body.cx0_95.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh195 : PRE_first_tail_x6_r0_body.kd95.nh1 = PRE_first_tail_x6_r0_body.cx1_95.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn095 : PRE_first_tail_x6_r0_body.kd95.nn0 = PRE_first_tail_x6_r0_body.cx0_95.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn195 : PRE_first_tail_x6_r0_body.kd95.nn1 = PRE_first_tail_x6_r0_body.cx1_95.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo95 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P95.lo && Nat.ble PRE_first_tail_x6_r0_body.P95.lo PRE_first_tail_x6_r0_body.cx0_95.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P95.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P95.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt95 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_95.mlx.next PRE_first_tail_x6_r0_body.cx1_95.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_95.mlx.nnext PRE_first_tail_x6_r0_body.cx1_95.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband95 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P95.NL && Nat.ble PRE_first_tail_x6_r0_body.P95.NL PRE_first_tail_x6_r0_body.P95.N0 && Nat.ble PRE_first_tail_x6_r0_body.P95.N0 PRE_first_tail_x6_r0_body.cx0_95.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow95 : PRE_first_tail_x6_r0_body.kd95.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren95 : checkRenG PRE_first_tail_x6_r0_body.kd95.hnd PRE_first_tail_x6_r0_body.khinv95 (phB PRE_first_tail_x6_r0_body.cx0_95.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband95 : PRE_first_tail_x6_r0_body.kd95.checkBand PRE_first_tail_x6_r0_body.P95.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos95 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd95.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren95 : checkRenG PRE_first_tail_x6_r0_body.kd95.node PRE_first_tail_x6_r0_body.kninv95 (pnB PRE_first_tail_x6_r0_body.cx0_95.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow95 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd95.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P95.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd95.nodeF j) PRE_first_tail_x6_r0_body.cx1_95.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a95 : PRE_first_tail_x6_r0_body.cx0_95.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b95 : PRE_first_tail_x6_r0_body.cx0_95.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok195 : PRE_first_tail_x6_r0_body.cx1_95.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend95 : PRE_first_tail_x6_r0_body.cx1_95.mlx.pending = PRE_first_tail_x6_r0_body.cx0_95.mlx.pending.map PRE_first_tail_x6_r0_body.kappa95.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh95 : PRE_first_tail_x6_r0_body.cx1_95.mlx.errh = PRE_first_tail_x6_r0_body.cx0_95.mlx.errh.map PRE_first_tail_x6_r0_body.kappa95.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles95 : PRE_first_tail_x6_r0_body.cx1_95.mlx.files = PRE_first_tail_x6_r0_body.cx0_95.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch95 : PRE_first_tail_x6_r0_body.cx1_95.mlx.arch = PRE_first_tail_x6_r0_body.cx0_95.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes95 : PRE_first_tail_x6_r0_body.cx1_95.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_95.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired95 : PRE_first_tail_x6_r0_body.cx1_95.mlx.wired = PRE_first_tail_x6_r0_body.cx0_95.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost95 : PRE_first_tail_x6_r0_body.cx1_95.host = PRE_first_tail_x6_r0_body.cx0_95.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd95`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn095 : PRE_first_tail_x6_r0_body.kd95.n0 = 2749294
kernel_rfl PRE_first_tail_x6_r0_body.ckn195 : PRE_first_tail_x6_r0_body.kd95.n1 = 2749313
kernel_rfl PRE_first_tail_x6_r0_body.ckheap95 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd95.heap).all (fun x => Nat.ble 2749293 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl95 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd95.heap.get (2749293 + j) = nth? PRE_first_tail_x6_r0_body.pl95 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja95 : Nat.ble 2749293 2749293 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn95 : Nat.ble 4114 4114 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD95 : Nat.ble 2749293 PRE_first_tail_x6_r0_body.kd95.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn95 : Nat.ble 20069 PRE_first_tail_x6_r0_body.kd95.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn95 : Nat.ble 17155 PRE_first_tail_x6_r0_body.kd95.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb95 : Nat.ble 20069 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap95 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd95.heap).all (Nat.ble (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd95 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd95.hnd).all (Nat.ble (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode95 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd95.node).all (Nat.ble (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix95 : Conv.FixOld (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa95 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja95) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn95) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD95) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn95) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn95) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb95) PRE_first_tail_x6_r0_body.fheap95 PRE_first_tail_x6_r0_body.fhnd95 PRE_first_tail_x6_r0_body.fnode95
kernel_rfl PRE_first_tail_x6_r0_body.fcxn95 : (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn95 : (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle095 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_95.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_95.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk95 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd95.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A95 : PRE_first_tail_x6_r0_body.cx1_95.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS95.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_95.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O95 : PRE_first_tail_x6_r0_body.cx1_95.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS95.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_95.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N95 : PRE_first_tail_x6_r0_body.cx1_95.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS95.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_95.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I95 : PRE_first_tail_x6_r0_body.cx1_95.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS95.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_95.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd95 : (PRE_first_tail_x6_r0_body.clo95 ++ PRE_first_tail_x6_r0_body.cln95 ++ PRE_first_tail_x6_r0_body.cli95 ++ PRE_first_tail_x6_r0_body.cwS95 ++ PRE_first_tail_x6_r0_body.cnS95 ++ PRE_first_tail_x6_r0_body.ciS95).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW95 : PRE_first_tail_x6_r0_body.cwS95.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo95.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI95 : PRE_first_tail_x6_r0_body.ciS95.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli95.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN95 : PRE_first_tail_x6_r0_body.cnS95.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF95 : PRE_first_tail_x6_r0_body.cln95.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh95 : PRE_first_tail_x6_r0_body.clo95.all (handleOK PRE_first_tail_x6_r0_body.kappa95 PRE_first_tail_x6_r0_body.P95.lo PRE_first_tail_x6_r0_body.cx0_95.mlx PRE_first_tail_x6_r0_body.cx1_95.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo95 : PRE_first_tail_x6_r0_body.clo95.map (fun h => PRE_first_tail_x6_r0_body.cx1_95.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa95.handle h)) = PRE_first_tail_x6_r0_body.clo95.map (fun h => (PRE_first_tail_x6_r0_body.cx0_95.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa95.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok95 : PRE_first_tail_x6_r0_body.clo95.all (objOK PRE_first_tail_x6_r0_body.kappa95 PRE_first_tail_x6_r0_body.P95.NL PRE_first_tail_x6_r0_body.cx0_95.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd95 : PRE_first_tail_x6_r0_body.cln95.all (nodeOKF PRE_first_tail_x6_r0_body.kappa95 PRE_first_tail_x6_r0_body.P95 PRE_first_tail_x6_r0_body.cx0_95.mlx PRE_first_tail_x6_r0_body.cx1_95.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp95 : ((PRE_first_tail_x6_r0_body.cln95.filter (fullB PRE_first_tail_x6_r0_body.P95))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_95.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa95.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln95.filter (fullB PRE_first_tail_x6_r0_body.P95))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_95.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa95.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI95 : incrB PRE_first_tail_x6_r0_body.kd95.nodeF (List.range' 17155 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK95 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd95.node).all (fun k => Nat.ble 17155 k && Nat.blt k 17155) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL95 : (PRE_first_tail_x6_r0_body.cln95.filter (Nat.ble PRE_first_tail_x6_r0_body.P95.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd95.nodeF i) && (Nat.blt i 17155 || Nat.ble PRE_first_tail_x6_r0_body.kd95.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord95 : (PRE_first_tail_x6_r0_body.cln95.filter (Nat.ble PRE_first_tail_x6_r0_body.P95.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd95.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd95.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd95.nodeF j) (PRE_first_tail_x6_r0_body.kd95.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow95 PRE_first_tail_x6_r0_body.cnn195 PRE_first_tail_x6_r0_body.fnordI95 PRE_first_tail_x6_r0_body.fnordK95 PRE_first_tail_x6_r0_body.fnordL95
kernel_rfl PRE_first_tail_x6_r0_body.fi95 : PRE_first_tail_x6_r0_body.cli95.all (pnB PRE_first_tail_x6_r0_body.cx0_95.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii95 : PRE_first_tail_x6_r0_body.cli95.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_95.mlx.items.get (PRE_first_tail_x6_r0_body.kappa95.node k) = (PRE_first_tail_x6_r0_body.cx0_95.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa95.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot95 (clean : Conv.NClean (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P95.NL) (cl : SSt (· < 4114) PRE_first_tail_x6_r0_body.cx0_95.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P95 4114 PRE_first_tail_x6_r0_body.kappa95 PRE_first_tail_x6_r0_body.kd95 PRE_first_tail_x6_r0_body.khinv95 PRE_first_tail_x6_r0_body.kninv95 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx PRE_first_tail_x6_r0_body.cx0_95.mlx PRE_first_tail_x6_r0_body.cx1_95.mlx (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo95 PRE_first_tail_x6_r0_body.cln95 PRE_first_tail_x6_r0_body.cli95 PRE_first_tail_x6_r0_body.cwS95 PRE_first_tail_x6_r0_body.cnS95 PRE_first_tail_x6_r0_body.ciS95 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh095, PRE_first_tail_x6_r0_body.cnh195, PRE_first_tail_x6_r0_body.cnn095, PRE_first_tail_x6_r0_body.cnn195, PRE_first_tail_x6_r0_body.cplo95, PRE_first_tail_x6_r0_body.ccnt95, PRE_first_tail_x6_r0_body.cnband95, PRE_first_tail_x6_r0_body.chbelow95, PRE_first_tail_x6_r0_body.chren95, PRE_first_tail_x6_r0_body.cband95, PRE_first_tail_x6_r0_body.cnh1pos95, PRE_first_tail_x6_r0_body.cnren95, PRE_first_tail_x6_r0_body.cnlow95, PRE_first_tail_x6_r0_body.cabs0a95, PRE_first_tail_x6_r0_body.cabs0b95, PRE_first_tail_x6_r0_body.ctok195, PRE_first_tail_x6_r0_body.cpend95, PRE_first_tail_x6_r0_body.cerrh95, PRE_first_tail_x6_r0_body.cfiles95, PRE_first_tail_x6_r0_body.carch95, PRE_first_tail_x6_r0_body.csizes95, PRE_first_tail_x6_r0_body.cwired95, PRE_first_tail_x6_r0_body.cfix95, clean, PRE_first_tail_x6_r0_body.fcxn95, PRE_first_tail_x6_r0_body.fcnn95, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle095, PRE_first_tail_x6_r0_body.fnk95, PRE_first_tail_x6_r0_body.ckA95, PRE_first_tail_x6_r0_body.cobjsK95, PRE_first_tail_x6_r0_body.cnodesK95, PRE_first_tail_x6_r0_body.citemsK95, PRE_first_tail_x6_r0_body.f1A95, PRE_first_tail_x6_r0_body.f1O95, PRE_first_tail_x6_r0_body.f1N95, PRE_first_tail_x6_r0_body.f1I95, PRE_first_tail_x6_r0_body.fbd95, PRE_first_tail_x6_r0_body.fincW95, PRE_first_tail_x6_r0_body.fincI95, PRE_first_tail_x6_r0_body.fincN95, PRE_first_tail_x6_r0_body.flnF95, PRE_first_tail_x6_r0_body.fh95, PRE_first_tail_x6_r0_body.fo95, PRE_first_tail_x6_r0_body.fok95, PRE_first_tail_x6_r0_body.fnd95, PRE_first_tail_x6_r0_body.fp95, PRE_first_tail_x6_r0_body.fnord95, PRE_first_tail_x6_r0_body.fi95, PRE_first_tail_x6_r0_body.fii95⟩
theorem PRE_first_tail_x6_r0_body.cnshift95 (clean : Conv.NClean (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P95.NL) (cl : SSt (· < 4114) PRE_first_tail_x6_r0_body.cx0_95.mlx) : NShift PRE_first_tail_x6_r0_body.P95 4114 PRE_first_tail_x6_r0_body.kappa95 PRE_first_tail_x6_r0_body.cx0_95 PRE_first_tail_x6_r0_body.cx1_95 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot95 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost95 (compact_a_eq PRE_first_tail_x6_r0_body.ckn095 PRE_first_tail_x6_r0_body.ckn195 PRE_first_tail_x6_r0_body.ckheap95 PRE_first_tail_x6_r0_body.ckpl95)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_95 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s919.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_95 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s919.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_95 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s919.ffi) = some PRE_first_tail_x6_r0_body.fxC_95
kernel_rfl PRE_first_tail_x6_r0_body.okrC_95 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s919.ffi) = some PRE_first_tail_x6_r0_body.krC_95
noncomputable def PRE_first_tail_x6_r0_body.fx0_95 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s921.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_95 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s921.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_95 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s921.ffi) = some PRE_first_tail_x6_r0_body.fx0_95
kernel_rfl PRE_first_tail_x6_r0_body.okr0_95 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s921.ffi) = some PRE_first_tail_x6_r0_body.kr0_95
noncomputable def PRE_first_tail_x6_r0_body.fx1_95 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s920.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_95 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s920.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_95 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s920.ffi) = some PRE_first_tail_x6_r0_body.fx1_95
kernel_rfl PRE_first_tail_x6_r0_body.okr1_95 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s920.ffi) = some PRE_first_tail_x6_r0_body.kr1_95
kernel_rfl PRE_first_tail_x6_r0_body.ff095 : PRE_first_tail_x6_r0_body.fx0_95 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_95 (PRE_first_tail_x6_r0_body.clo95.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_95.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff195 : PRE_first_tail_x6_r0_body.fx1_95 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_95 (PRE_first_tail_x6_r0_body.cwS95.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_95.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck95 : freedLB PRE_first_tail_x6_r0_body.kappa95 PRE_first_tail_x6_r0_body.cx0_95.mlx PRE_first_tail_x6_r0_body.fx0_95 PRE_first_tail_x6_r0_body.fx1_95 PRE_first_tail_x6_r0_body.clo95 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf095 : PRE_first_tail_x6_r0_body.kr0_95.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_95.flags (PRE_first_tail_x6_r0_body.clo95.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_95.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt095 : PRE_first_tail_x6_r0_body.kr0_95.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_95.targs (PRE_first_tail_x6_r0_body.clo95.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_95.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf195 : PRE_first_tail_x6_r0_body.kr1_95.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_95.flags (PRE_first_tail_x6_r0_body.cwS95.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_95.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt195 : PRE_first_tail_x6_r0_body.kr1_95.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_95.targs (PRE_first_tail_x6_r0_body.cwS95.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_95.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck95 : krecLB PRE_first_tail_x6_r0_body.kappa95 4114 PRE_first_tail_x6_r0_body.cx0_95.mlx PRE_first_tail_x6_r0_body.kr0_95 PRE_first_tail_x6_r0_body.kr1_95 PRE_first_tail_x6_r0_body.clo95 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn95 : Nat.ble 4114 4114 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge95 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s920.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s921.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR95 : pendRegB PRE_first_tail_x6_r0_body.kappa95 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s921.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe95 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s921.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s920.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift95 (clean : Conv.NClean (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P95.NL) (cl : SSt (· < 4114) PRE_first_tail_x6_r0_body.cx0_95.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_95.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_95.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_95.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s919.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_95.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P95 4114 PRE_first_tail_x6_r0_body.kappa95 PRE_first_tail_x6_r0_body.s921.ffi PRE_first_tail_x6_r0_body.s920.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift95 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue95, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp95 t ht),
    PRE_first_tail_x6_r0_body.cbridge95,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s921.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s920.ffi) (PRE_first_tail_x6_r0_body.cfoot95 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_95 PRE_first_tail_x6_r0_body.ofx1_95 hobjC PRE_first_tail_x6_r0_body.ff095 PRE_first_tail_x6_r0_body.ff195 PRE_first_tail_x6_r0_body.ffck95,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s921.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s920.ffi) (PRE_first_tail_x6_r0_body.cfoot95 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_95 PRE_first_tail_x6_r0_body.okr1_95 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn95) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf095 PRE_first_tail_x6_r0_body.fkt095 PRE_first_tail_x6_r0_body.fkf195 PRE_first_tail_x6_r0_body.fkt195 PRE_first_tail_x6_r0_body.fkck95,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh095 PRE_first_tail_x6_r0_body.cnh195 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe95) PRE_first_tail_x6_r0_body.cpendR95⟩

end Host.Load.Run.Tpl
end

section -- st95/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st95 0
host_stream_state PRE_first_tail_x6_r0_body.st95 1
host_stream_state PRE_first_tail_x6_r0_body.st95 2
end Host.Load.Run.Tpl
end

section -- Site95
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 95 of chain `PRE_first_tail_x6_r0_body`: `plan__g95__g96` (`plan`), the call state `PRE_first_tail_x6_r0_body.s919`, the merged state `PRE_first_tail_x6_r0_body.s920`,
the site template `PRE_first_tail_x6_r0_body.st95` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s921`: the merge.
The footprint's facts are in `SiteF95`, the compaction's in `SiteC95`, `SiteK95`, `SiteNa95`, `SiteNb95`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso95 : PRE_first_tail_x6_r0_body.st95.s0 = { PRE_first_tail_x6_r0_body.s919 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs95 : List Frame := PRE_first_tail_x6_r0_body.s919.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_95 : PRE_first_tail_x6_r0_body.S919.tab.length = 4114
kernel_rfl PRE_first_tail_x6_r0_body.tab0_95 : PRE_first_tail_x6_r0_body.st95.S0.tab = PRE_first_tail_x6_r0_body.S919.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws95 : List Nat := [2589, 2590, 2591, 2592, 2593, 2594, 2595, 2596, 2597]
kernel_rfl PRE_first_tail_x6_r0_body.fresh95 : (PRE_first_tail_x6_r0_body.S919.tab.all fun e => PRE_first_tail_x6_r0_body.ws95.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S919.oracle.all fun q => PRE_first_tail_x6_r0_body.ws95.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab95 : PRE_first_tail_x6_r0_body.S920.tab = PRE_first_tail_x6_r0_body.S919.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws95
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen95 : PRE_first_tail_x6_r0_body.st95.S2.tab.length - PRE_first_tail_x6_r0_body.st95.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged95`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap95 : PRE_first_tail_x6_r0_body.s920.heap = PRE_first_tail_x6_r0_body.st95.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext95 : PRE_first_tail_x6_r0_body.s920.next = PRE_first_tail_x6_r0_body.st95.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl95 : PRE_first_tail_x6_r0_body.s920.ctl = PRE_first_tail_x6_r0_body.st95.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack95 : PRE_first_tail_x6_r0_body.s920.stack = PRE_first_tail_x6_r0_body.st95.s2.stack ++ PRE_first_tail_x6_r0_body.s919.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs95 : PRE_first_tail_x6_r0_body.s920.jobs = PRE_first_tail_x6_r0_body.st95.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi95 : PRE_first_tail_x6_r0_body.s920.ffi = PRE_first_tail_x6_r0_body.st95.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace95 : PRE_first_tail_x6_r0_body.s920.trace = PRE_first_tail_x6_r0_body.st95.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores95 : PRE_first_tail_x6_r0_body.s920.stores = PRE_first_tail_x6_r0_body.st95.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD95
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 95 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived95 : PRE_first_tail_x6_r0_body.nr95.map (fun r => nth? PRE_first_tail_x6_r0_body.st95.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo95 : PRE_first_tail_x6_r0_body.nr95.all (Nat.ble 4114) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj95 : PRE_first_tail_x6_r0_body.cws95.all (fun c => !PRE_first_tail_x6_r0_body.ws95.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ95 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws95 PRE_first_tail_x6_r0_body.crs95 PRE_first_tail_x6_r0_body.ws95

end Host.Load.Run.Tpl
end

section -- st95/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st95`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st95.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st95.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st95.s2.heap PRE_first_tail_x6_r0_body.st95.wrR ++ freshOf PRE_first_tail_x6_r0_body.st95.s2.heap PRE_first_tail_x6_r0_body.st95.s0.next PRE_first_tail_x6_r0_body.st95.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st95.wr : List Nat := PRE_first_tail_x6_r0_body.st95.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st95.heapFoot : PRE_first_tail_x6_r0_body.st95.s2.heap = setAll PRE_first_tail_x6_r0_body.st95.s0.heap PRE_first_tail_x6_r0_body.st95.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st95.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st95.s0.next PRE_first_tail_x6_r0_body.st95.s2.next = true
theorem PRE_first_tail_x6_r0_body.st95.grows : PRE_first_tail_x6_r0_body.st95.s0.next ≤ PRE_first_tail_x6_r0_body.st95.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st95.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st95.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st95.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st95.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st95.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st95.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st95.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st95.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st95.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st95.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st95.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st95.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st95.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st95.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st95.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st95.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st95.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st95.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st95.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st95.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st95.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st95.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st95.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st95.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st95.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st95.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st95.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st95.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st95.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st95.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st95.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st95.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF95
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 95 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB95 : nodupT PRE_first_tail_x6_r0_body.st95.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup95 : PRE_first_tail_x6_r0_body.st95.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB95).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB95 : PRE_first_tail_x6_r0_body.st95.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound95 : ∀ b ∈ PRE_first_tail_x6_r0_body.st95.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB95 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr95 := PRE_first_tail_x6_r0_body.st95.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq95 : PRE_first_tail_x6_r0_body.st95.s2.trace = PRE_first_tail_x6_r0_body.trFr95 ++ PRE_first_tail_x6_r0_body.st95.s0.trace
theorem PRE_first_tail_x6_r0_body.trace95 : ∃ fr, PRE_first_tail_x6_r0_body.st95.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st95.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq95⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide95 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB95 : (PRE_first_tail_x6_r0_body.wide95.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st95.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix95 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide95, WFix Map.id (Present PRE_first_tail_x6_r0_body.st95.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB95 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL95
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 95 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s920`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO95 : PRE_first_tail_x6_r0_body.st95.S0.oracle = PRE_first_tail_x6_r0_body.st95.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B95 : PRE_first_tail_x6_r0_body.st95.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st95.s0.next || (PRE_first_tail_x6_r0_body.st95.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot95 : Conv.StageFoot PRE_first_tail_x6_r0_body.st95.wr PRE_first_tail_x6_r0_body.st95.s0 PRE_first_tail_x6_r0_body.st95.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st95.heapFoot PRE_first_tail_x6_r0_body.wrNodup95 PRE_first_tail_x6_r0_body.wrBound95 PRE_first_tail_x6_r0_body.wr0B95 PRE_first_tail_x6_r0_body.st95.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged95 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st95.F.S → PRE_first_tail_x6_r0_body.st95.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st95.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st95.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs95 PRE_first_tail_x6_r0_body.st95.wr PRE_first_tail_x6_r0_body.s919 PRE_first_tail_x6_r0_body.st95.s2 PRE_first_tail_x6_r0_body.st95.s0
      PRE_first_tail_x6_r0_body.st95.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st95.F FR W stk M ν K PRE_first_tail_x6_r0_body.s920 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso95 PRE_first_tail_x6_r0_body.stFoot95 PRE_first_tail_x6_r0_body.wrNodup95 PRE_first_tail_x6_r0_body.wrBound95 PRE_first_tail_x6_r0_body.trace95 PRE_first_tail_x6_r0_body.mheap95
    PRE_first_tail_x6_r0_body.mnext95 PRE_first_tail_x6_r0_body.mctl95 PRE_first_tail_x6_r0_body.mstack95 PRE_first_tail_x6_r0_body.mjobs95 PRE_first_tail_x6_r0_body.mffi95 PRE_first_tail_x6_r0_body.mtrace95 PRE_first_tail_x6_r0_body.mstores95 h

def PRE_first_tail_x6_r0_body.arrEl95_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE95_2665 : arrOf PRE_first_tail_x6_r0_body.s920 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl95_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA95_2665 : isArrB PRE_first_tail_x6_r0_body.s920 2665 = true
theorem PRE_first_tail_x6_r0_body.arr95_2665 : ∃ o, PRE_first_tail_x6_r0_body.s920.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl95_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE95_2665 PRE_first_tail_x6_r0_body.arrA95_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN95_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl95_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR95_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl95_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN95_2665

def PRE_first_tail_x6_r0_body.arrEl95_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE95_2673467 : arrOf PRE_first_tail_x6_r0_body.s920 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl95_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA95_2673467 : isArrB PRE_first_tail_x6_r0_body.s920 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr95_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s920.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl95_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE95_2673467 PRE_first_tail_x6_r0_body.arrA95_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN95_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl95_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR95_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl95_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN95_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k95 : isArrB PRE_first_tail_x6_r0_body.s920 4910 = false
theorem PRE_first_tail_x6_r0_body.keep95 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s920 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k95 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr95_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl95_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ95
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 95 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s919`, the merged
state `PRE_first_tail_x6_r0_body.s920`, the canonical state `PRE_first_tail_x6_r0_body.s921`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl95 : PRE_first_tail_x6_r0_body.pl95.all (Nat.ble PRE_first_tail_x6_r0_body.s919.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd95 : nodupT PRE_first_tail_x6_r0_body.pl95 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn195 : Nat.ble PRE_first_tail_x6_r0_body.s919.next 2749313 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst95 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s919.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn95 : PRE_first_tail_x6_r0_body.s921.next = PRE_first_tail_x6_r0_body.s919.next + PRE_first_tail_x6_r0_body.pl95.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn95 : PRE_first_tail_x6_r0_body.s920.next = 2749313
kernel_rfl PRE_first_tail_x6_r0_body.zgrow95 : Nat.ble PRE_first_tail_x6_r0_body.s921.next PRE_first_tail_x6_r0_body.s920.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh95 : PRE_first_tail_x6_r0_body.S919.tab.all (fun e => PRE_first_tail_x6_r0_body.cws95.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd95 : nodupT PRE_first_tail_x6_r0_body.cws95 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi95 : PRE_first_tail_x6_r0_body.nr95.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S920.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt95 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s919.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg95_2665 : PRE_first_tail_x6_r0_body.s921.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s921 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk95_2665 : (objOf PRE_first_tail_x6_r0_body.s921 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm95_2665 : PRE_first_tail_x6_r0_body.s920.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa95.obj (objOf PRE_first_tail_x6_r0_body.s921 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s920 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg95_2673467 : PRE_first_tail_x6_r0_body.s921.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s921 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk95_2673467 : (objOf PRE_first_tail_x6_r0_body.s921 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm95_2673467 : PRE_first_tail_x6_r0_body.s920.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa95.obj (objOf PRE_first_tail_x6_r0_body.s921 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s920 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw95_4910 : (PRE_first_tail_x6_r0_body.s921.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw95_2673472 : (PRE_first_tail_x6_r0_body.s921.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw95_2673473 : (PRE_first_tail_x6_r0_body.s921.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd95 : PRE_first_tail_x6_r0_body.cl95.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr95 : PRE_first_tail_x6_r0_body.st95.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s919.next || PRE_first_tail_x6_r0_body.cl95.contains b) = true
def PRE_first_tail_x6_r0_body.zl95 : List Nat := PRE_first_tail_x6_r0_body.cl95.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE95 : PRE_first_tail_x6_r0_body.zl95.map (fun a => PRE_first_tail_x6_r0_body.s920.heap.get (PRE_first_tail_x6_r0_body.kappa95.a a)) = PRE_first_tail_x6_r0_body.zl95.map (fun a => (PRE_first_tail_x6_r0_body.s921.heap.get a).map PRE_first_tail_x6_r0_body.kappa95.hobj)
theorem PRE_first_tail_x6_r0_body.zimg95 : HeapImg PRE_first_tail_x6_r0_body.kappa95 PRE_first_tail_x6_r0_body.s921 PRE_first_tail_x6_r0_body.s920 PRE_first_tail_x6_r0_body.zl95 := PRE_first_tail_x6_r0_body.zimgE95
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl95 : PRE_first_tail_x6_r0_body.s920.ctl = PRE_first_tail_x6_r0_body.kappa95.ctl PRE_first_tail_x6_r0_body.s921.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack95 : PRE_first_tail_x6_r0_body.s920.stack = PRE_first_tail_x6_r0_body.s921.stack.map PRE_first_tail_x6_r0_body.kappa95.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs95 : PRE_first_tail_x6_r0_body.s920.jobs = PRE_first_tail_x6_r0_body.s921.jobs.map PRE_first_tail_x6_r0_body.kappa95.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores95 : PRE_first_tail_x6_r0_body.s920.stores = PRE_first_tail_x6_r0_body.kappa95.stores PRE_first_tail_x6_r0_body.s921.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots95 : checkRootsSupp PRE_first_tail_x6_r0_body.s921 4114 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC95 : PRE_first_tail_x6_r0_body.S919.tab.length + PRE_first_tail_x6_r0_body.cws95.length = 4114
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap95 : PRE_first_tail_x6_r0_body.kappa95 = Conv.Map.compact PRE_first_tail_x6_r0_body.s919.next 2749313 PRE_first_tail_x6_r0_body.S919.tab.length PRE_first_tail_x6_r0_body.pl95 (PRE_first_tail_x6_r0_body.nr95.map NumV.ref) PRE_first_tail_x6_r0_body.kd95.big
  PRE_first_tail_x6_r0_body.kd95.region PRE_first_tail_x6_r0_body.kd95.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin95 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s921.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc95 : Conv.jcleanListB (⟨20069, 17155, 2749294, 4114⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s921 PRE_first_tail_x6_r0_body.cl95 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB95 : noBigRootsP (fun i => !Conv.oldBigB (⟨20069, 17155, 2749294, 4114⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s921.trace PRE_first_tail_x6_r0_body.s921 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm95 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 17155 = true
theorem PRE_first_tail_x6_r0_body.cjcl95 (h : Conv.JClean (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s919) : Conv.JClean (⟨20069, 17155, 2749294, 4114⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s921 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle95)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap95 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd95 a ha)) PRE_first_tail_x6_r0_body.zjc95

end Host.Load.Run.Tpl
end

section -- st95/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st95.bodyLast from PRE_first_tail_x6_r0_body.st95.s1 to PRE_first_tail_x6_r0_body.st95.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st95.F PRE_first_tail_x6_r0_body.st95.s1).run PRE_first_tail_x6_r0_body.st95.S1 = some (PRE_first_tail_x6_r0_body.st95.s2, PRE_first_tail_x6_r0_body.st95.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st95.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st95.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st95.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st95.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st95/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st95.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st95.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st95.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st95.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st95.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st95.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st95.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st95.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st95.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st95.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st95.s0 PRE_first_tail_x6_r0_body.st95.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st95.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st95.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st95.s1 PRE_first_tail_x6_r0_body.st95.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st95/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st95.bodyK0F from PRE_first_tail_x6_r0_body.st95.s0 to PRE_first_tail_x6_r0_body.st95.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st95.F (PRE_first_tail_x6_r0_body.st95.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st95.ks 0).getD 0) PRE_first_tail_x6_r0_body.st95.s0 PRE_first_tail_x6_r0_body.st95.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st95.s1, PRE_first_tail_x6_r0_body.st95.S1)
theorem PRE_first_tail_x6_r0_body.st95.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st95.F (PRE_first_tail_x6_r0_body.st95.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st95.ks 0).getD 0) PRE_first_tail_x6_r0_body.st95.s0 PRE_first_tail_x6_r0_body.st95.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st95.s1, PRE_first_tail_x6_r0_body.st95.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st95.bodyOkLN_ok PRE_first_tail_x6_r0_body.st95.bodyK0F
end Host.Load.Run.Tpl
end

section -- st95/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st95.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st95.F (PRE_first_tail_x6_r0_body.st95.bodyOkL bytes rows) 206 PRE_first_tail_x6_r0_body.st95.s0 PRE_first_tail_x6_r0_body.st95.S0 = some (PRE_first_tail_x6_r0_body.st95.s1, PRE_first_tail_x6_r0_body.st95.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st95.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st95.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st95.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st95.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st95.F (PRE_first_tail_x6_r0_body.st95.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st95.s0
  S0 := PRE_first_tail_x6_r0_body.st95.S0
  s1 := PRE_first_tail_x6_r0_body.st95.s1
  S1 := PRE_first_tail_x6_r0_body.st95.S1
  s2 := PRE_first_tail_x6_r0_body.st95.s2
  S2 := PRE_first_tail_x6_r0_body.st95.S2
  n := 206
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st95.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st95.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st95.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st95.bodyHalt
  last := PRE_first_tail_x6_r0_body.st95.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st95.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC96
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 96 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s938` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa96` into the merged state
`PRE_first_tail_x6_r0_body.s937`. -/

def PRE_first_tail_x6_r0_body.pl96 : List Nat := [2751903, 2751078, 2751909, 2751905, 2751080, 2751911]
def PRE_first_tail_x6_r0_body.nr96 : List Nat := [4217, 4216, 4192, 4200, 4205, 4210, 4215, 4189, 4190, 4191, 4198, 4199, 4187, 4194, 4195, 4196, 4197, 4193]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd96 : RData :=
  ⟨2750797, 2751946, Stage.setAll PTrie.nil [(2750791, 2751903), (2750792, 2751078), (2750793, 2751909), (2750794, 2751905), (2750795, 2751080), (2750796, 2751911)], Stage.setAll PTrie.nil [(20104, 20130), (20105, 20108), (20106, 20131)],
   20107, 20132, 17201, 17201, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(4187, .ref 4217), (4188, .ref 4216), (4189, .ref 4192), (4190, .ref 4200), (4191, .ref 4205), (4192, .ref 4210), (4193, .ref 4215), (4194, .ref 4189), (4195, .ref 4190), (4196, .ref 4191), (4197, .ref 4198), (4198, .ref 4199), (4199, .ref 4187), (4200, .ref 4194), (4201, .ref 4195), (4202, .ref 4196), (4203, .ref 4197), (4204, .ref 4193)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa96 : Map :=
  Conv.Map.compact 2750791 2751946 4187 PRE_first_tail_x6_r0_body.pl96 (PRE_first_tail_x6_r0_body.nr96.map NumV.ref) PRE_first_tail_x6_r0_body.kd96.big
    PRE_first_tail_x6_r0_body.kd96.region PRE_first_tail_x6_r0_body.kd96.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws96 : List Nat := [2629, 2630, 2631, 2632, 2633, 2634, 2635, 2636, 2637, 2638, 2639, 2640, 2641, 2642, 2643, 2644, 2645, 2646]
noncomputable def PRE_first_tail_x6_r0_body.crs96 : List SymE := PRE_first_tail_x6_r0_body.nr96.map fun r => (nth? PRE_first_tail_x6_r0_body.S937.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta96 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws96 PRE_first_tail_x6_r0_body.crs96
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB96 : List Nat := [2665, 2672548, 2673467, 2749965, 2750510, 2750766]

kernel_rfl PRE_first_tail_x6_r0_body.ctab96 : PRE_first_tail_x6_r0_body.S938.tab = PRE_first_tail_x6_r0_body.S936.tab ++ PRE_first_tail_x6_r0_body.cws96.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace96 : PRE_first_tail_x6_r0_body.s938.trace = PRE_first_tail_x6_r0_body.s936.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext96 : PRE_first_tail_x6_r0_body.s938.next = 2750797
kernel_rfl PRE_first_tail_x6_r0_body.ccounters96 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s938.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s938.ffi).mlx.nnext) = (20107, 17201)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue96 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s937.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s938.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa96.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp96 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s938.ffi).mlx.tokens.all (bSN 4205) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean96 : Conv.cleanListB 20107 131072 (fun r => Nat.ble 80428 r) PRE_first_tail_x6_r0_body.s938
    (PRE_first_tail_x6_r0_body.wrB96 ++ (List.range 6).map (2750791 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs96 : bigsOutB 20107 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s938.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK96
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl96`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl96 : List Nat := [2665, 2672548, 2673467, 2749965, 2750510, 2750766, 2750791, 2750792, 2750793, 2750794, 2750795, 2750796]
def PRE_first_tail_x6_r0_body.clo96 : List Nat := [20084, 20097, 20103, 20104, 20105, 20106]
def PRE_first_tail_x6_r0_body.cln96 : List Nat := [17174, 17175, 17176, 17177, 17178, 17179, 17180, 17181, 17182, 17183, 17184, 17185, 17186, 17187, 17188, 17189, 17190, 17191, 17192, 17193, 17194, 17195, 17196, 17197, 17198, 17199, 17200]
def PRE_first_tail_x6_r0_body.cli96 : List Nat := [17174, 17175, 17176, 17177, 17178, 17179, 17180, 17181, 17182, 17183, 17184, 17185, 17186, 17187, 17188, 17189, 17190, 17191, 17192, 17193, 17194, 17195, 17196, 17197, 17198, 17199, 17200]
kernel_rfl PRE_first_tail_x6_r0_body.cheap96 : PRE_first_tail_x6_r0_body.s938.heap = Stage.setAll PRE_first_tail_x6_r0_body.s936.heap (PRE_first_tail_x6_r0_body.cl96.filterMap fun a => (PRE_first_tail_x6_r0_body.s938.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe96 : Nat.ble PRE_first_tail_x6_r0_body.s936.next PRE_first_tail_x6_r0_body.s938.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP96 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s936 PRE_first_tail_x6_r0_body.s938 PRE_first_tail_x6_r0_body.cl96 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp96 : Conv.suppListB PRE_first_tail_x6_r0_body.s938 4205 PRE_first_tail_x6_r0_body.cl96 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound96 : Conv.boundListB PRE_first_tail_x6_r0_body.s938 PRE_first_tail_x6_r0_body.cl96 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK96 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s938.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln96.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s938.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK96 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s938.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo96.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s938.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK96 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s938.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli96.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s938.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst96 : Conv.sstListB 4205 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s938.ffi).mlx PRE_first_tail_x6_r0_body.cln96 PRE_first_tail_x6_r0_body.clo96 PRE_first_tail_x6_r0_body.cli96 = true

end Host.Load.Run.Tpl
end

section -- SiteCl96
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA96 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s938.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo96.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s938.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd96 : (PRE_first_tail_x6_r0_body.clo96 ++ PRE_first_tail_x6_r0_body.cln96 ++ PRE_first_tail_x6_r0_body.cli96).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle96 : Conv.Cnt.leB (⟨20104, 17174, 2750791, 4187⟩ : Conv.Cnt) (⟨20107, 17201, 2750797, 4205⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck96 : Conv.ncleanListB (⟨20107, 17201, 2750797, 4205⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s938.ffi).mlx PRE_first_tail_x6_r0_body.clo96 PRE_first_tail_x6_r0_body.cln96 PRE_first_tail_x6_r0_body.cli96 = true
theorem PRE_first_tail_x6_r0_body.cncl96 (h : Conv.NClean (⟨20104, 17174, 2750791, 4187⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx) : Conv.NClean (⟨20107, 17201, 2750797, 4205⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s938.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle96 PRE_first_tail_x6_r0_body.ckA96 PRE_first_tail_x6_r0_body.cobjsK96 PRE_first_tail_x6_r0_body.cnodesK96 PRE_first_tail_x6_r0_body.citemsK96 PRE_first_tail_x6_r0_body.cbd96 PRE_first_tail_x6_r0_body.cck96

end Host.Load.Run.Tpl
end

section -- SiteS96
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 96 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc96 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P96 : LoadP := PRE_first_tail_x6_r0_body.Pc96.raise 17201
kernel_rfl PRE_first_tail_x6_r0_body.craise96 : Nat.ble PRE_first_tail_x6_r0_body.Pc96.N0 17201 = true
theorem PRE_first_tail_x6_r0_body.raised96 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc96 PRE_first_tail_x6_r0_body.P96 :=
  .inr ⟨17201, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise96, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_96 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s938.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_96 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s937.ffi)
def PRE_first_tail_x6_r0_body.khinv96 : PTrie Nat := Stage.setAll PTrie.nil [(20130, 20104), (20108, 20105), (20131, 20106)]
def PRE_first_tail_x6_r0_body.kninv96 : PTrie Nat := Stage.setAll PTrie.nil [(17174, 17174), (17175, 17175), (17176, 17176), (17177, 17177), (17178, 17178), (17179, 17179), (17180, 17180), (17181, 17181), (17182, 17182), (17183, 17183), (17184, 17184), (17185, 17185), (17186, 17186), (17187, 17187), (17188, 17188), (17189, 17189), (17190, 17190), (17191, 17191), (17192, 17192), (17193, 17193), (17194, 17194), (17195, 17195), (17196, 17196), (17197, 17197), (17198, 17198), (17199, 17199), (17200, 17200)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS96 : List Nat := [20084, 20097, 20103, 20104, 20105, 20106, 20107, 20108, 20109, 20110, 20111, 20112, 20113, 20114, 20115, 20116, 20117, 20118, 20119, 20120, 20121, 20122, 20123, 20124, 20125, 20126, 20127, 20128, 20129, 20130, 20131]
def PRE_first_tail_x6_r0_body.cnS96 : List Nat := List.range' 17174 27
def PRE_first_tail_x6_r0_body.ciS96 : List Nat := [] ++ List.range' 17174 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh096 : PRE_first_tail_x6_r0_body.kd96.nh0 = PRE_first_tail_x6_r0_body.cx0_96.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh196 : PRE_first_tail_x6_r0_body.kd96.nh1 = PRE_first_tail_x6_r0_body.cx1_96.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn096 : PRE_first_tail_x6_r0_body.kd96.nn0 = PRE_first_tail_x6_r0_body.cx0_96.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn196 : PRE_first_tail_x6_r0_body.kd96.nn1 = PRE_first_tail_x6_r0_body.cx1_96.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo96 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P96.lo && Nat.ble PRE_first_tail_x6_r0_body.P96.lo PRE_first_tail_x6_r0_body.cx0_96.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P96.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P96.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt96 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_96.mlx.next PRE_first_tail_x6_r0_body.cx1_96.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_96.mlx.nnext PRE_first_tail_x6_r0_body.cx1_96.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband96 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P96.NL && Nat.ble PRE_first_tail_x6_r0_body.P96.NL PRE_first_tail_x6_r0_body.P96.N0 && Nat.ble PRE_first_tail_x6_r0_body.P96.N0 PRE_first_tail_x6_r0_body.cx0_96.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow96 : PRE_first_tail_x6_r0_body.kd96.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren96 : checkRenG PRE_first_tail_x6_r0_body.kd96.hnd PRE_first_tail_x6_r0_body.khinv96 (phB PRE_first_tail_x6_r0_body.cx0_96.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband96 : PRE_first_tail_x6_r0_body.kd96.checkBand PRE_first_tail_x6_r0_body.P96.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos96 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd96.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren96 : checkRenG PRE_first_tail_x6_r0_body.kd96.node PRE_first_tail_x6_r0_body.kninv96 (pnB PRE_first_tail_x6_r0_body.cx0_96.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow96 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd96.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P96.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd96.nodeF j) PRE_first_tail_x6_r0_body.cx1_96.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a96 : PRE_first_tail_x6_r0_body.cx0_96.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b96 : PRE_first_tail_x6_r0_body.cx0_96.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok196 : PRE_first_tail_x6_r0_body.cx1_96.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend96 : PRE_first_tail_x6_r0_body.cx1_96.mlx.pending = PRE_first_tail_x6_r0_body.cx0_96.mlx.pending.map PRE_first_tail_x6_r0_body.kappa96.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh96 : PRE_first_tail_x6_r0_body.cx1_96.mlx.errh = PRE_first_tail_x6_r0_body.cx0_96.mlx.errh.map PRE_first_tail_x6_r0_body.kappa96.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles96 : PRE_first_tail_x6_r0_body.cx1_96.mlx.files = PRE_first_tail_x6_r0_body.cx0_96.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch96 : PRE_first_tail_x6_r0_body.cx1_96.mlx.arch = PRE_first_tail_x6_r0_body.cx0_96.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes96 : PRE_first_tail_x6_r0_body.cx1_96.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_96.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired96 : PRE_first_tail_x6_r0_body.cx1_96.mlx.wired = PRE_first_tail_x6_r0_body.cx0_96.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost96 : PRE_first_tail_x6_r0_body.cx1_96.host = PRE_first_tail_x6_r0_body.cx0_96.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd96`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn096 : PRE_first_tail_x6_r0_body.kd96.n0 = 2750797
kernel_rfl PRE_first_tail_x6_r0_body.ckn196 : PRE_first_tail_x6_r0_body.kd96.n1 = 2751946
kernel_rfl PRE_first_tail_x6_r0_body.ckheap96 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd96.heap).all (fun x => Nat.ble 2750791 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl96 : (List.range 6).all (fun j => decide (PRE_first_tail_x6_r0_body.kd96.heap.get (2750791 + j) = nth? PRE_first_tail_x6_r0_body.pl96 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja96 : Nat.ble 2750791 2750791 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn96 : Nat.ble 4187 4187 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD96 : Nat.ble 2750791 PRE_first_tail_x6_r0_body.kd96.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn96 : Nat.ble 20104 PRE_first_tail_x6_r0_body.kd96.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn96 : Nat.ble 17174 PRE_first_tail_x6_r0_body.kd96.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb96 : Nat.ble 20104 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap96 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd96.heap).all (Nat.ble (⟨20104, 17174, 2750791, 4187⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd96 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd96.hnd).all (Nat.ble (⟨20104, 17174, 2750791, 4187⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode96 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd96.node).all (Nat.ble (⟨20104, 17174, 2750791, 4187⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix96 : Conv.FixOld (⟨20104, 17174, 2750791, 4187⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa96 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja96) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn96) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD96) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn96) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn96) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb96) PRE_first_tail_x6_r0_body.fheap96 PRE_first_tail_x6_r0_body.fhnd96 PRE_first_tail_x6_r0_body.fnode96
kernel_rfl PRE_first_tail_x6_r0_body.fcxn96 : (⟨20104, 17174, 2750791, 4187⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn96 : (⟨20104, 17174, 2750791, 4187⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle096 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_96.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_96.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk96 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd96.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A96 : PRE_first_tail_x6_r0_body.cx1_96.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS96.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_96.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O96 : PRE_first_tail_x6_r0_body.cx1_96.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS96.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_96.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N96 : PRE_first_tail_x6_r0_body.cx1_96.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS96.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_96.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I96 : PRE_first_tail_x6_r0_body.cx1_96.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS96.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_96.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd96 : (PRE_first_tail_x6_r0_body.clo96 ++ PRE_first_tail_x6_r0_body.cln96 ++ PRE_first_tail_x6_r0_body.cli96 ++ PRE_first_tail_x6_r0_body.cwS96 ++ PRE_first_tail_x6_r0_body.cnS96 ++ PRE_first_tail_x6_r0_body.ciS96).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW96 : PRE_first_tail_x6_r0_body.cwS96.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo96.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI96 : PRE_first_tail_x6_r0_body.ciS96.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli96.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN96 : PRE_first_tail_x6_r0_body.cnS96.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF96 : PRE_first_tail_x6_r0_body.cln96.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh96 : PRE_first_tail_x6_r0_body.clo96.all (handleOK PRE_first_tail_x6_r0_body.kappa96 PRE_first_tail_x6_r0_body.P96.lo PRE_first_tail_x6_r0_body.cx0_96.mlx PRE_first_tail_x6_r0_body.cx1_96.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo96 : PRE_first_tail_x6_r0_body.clo96.map (fun h => PRE_first_tail_x6_r0_body.cx1_96.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa96.handle h)) = PRE_first_tail_x6_r0_body.clo96.map (fun h => (PRE_first_tail_x6_r0_body.cx0_96.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa96.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok96 : PRE_first_tail_x6_r0_body.clo96.all (objOK PRE_first_tail_x6_r0_body.kappa96 PRE_first_tail_x6_r0_body.P96.NL PRE_first_tail_x6_r0_body.cx0_96.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd96 : PRE_first_tail_x6_r0_body.cln96.all (nodeOKF PRE_first_tail_x6_r0_body.kappa96 PRE_first_tail_x6_r0_body.P96 PRE_first_tail_x6_r0_body.cx0_96.mlx PRE_first_tail_x6_r0_body.cx1_96.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp96 : ((PRE_first_tail_x6_r0_body.cln96.filter (fullB PRE_first_tail_x6_r0_body.P96))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_96.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa96.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln96.filter (fullB PRE_first_tail_x6_r0_body.P96))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_96.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa96.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI96 : incrB PRE_first_tail_x6_r0_body.kd96.nodeF (List.range' 17174 27) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK96 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd96.node).all (fun k => Nat.ble 17174 k && Nat.blt k 17201) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL96 : (PRE_first_tail_x6_r0_body.cln96.filter (Nat.ble PRE_first_tail_x6_r0_body.P96.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd96.nodeF i) && (Nat.blt i 17201 || Nat.ble PRE_first_tail_x6_r0_body.kd96.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord96 : (PRE_first_tail_x6_r0_body.cln96.filter (Nat.ble PRE_first_tail_x6_r0_body.P96.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd96.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd96.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd96.nodeF j) (PRE_first_tail_x6_r0_body.kd96.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow96 PRE_first_tail_x6_r0_body.cnn196 PRE_first_tail_x6_r0_body.fnordI96 PRE_first_tail_x6_r0_body.fnordK96 PRE_first_tail_x6_r0_body.fnordL96
kernel_rfl PRE_first_tail_x6_r0_body.fi96 : PRE_first_tail_x6_r0_body.cli96.all (pnB PRE_first_tail_x6_r0_body.cx0_96.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii96 : PRE_first_tail_x6_r0_body.cli96.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_96.mlx.items.get (PRE_first_tail_x6_r0_body.kappa96.node k) = (PRE_first_tail_x6_r0_body.cx0_96.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa96.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot96 (clean : Conv.NClean (⟨20104, 17174, 2750791, 4187⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P96.NL) (cl : SSt (· < 4205) PRE_first_tail_x6_r0_body.cx0_96.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P96 4205 PRE_first_tail_x6_r0_body.kappa96 PRE_first_tail_x6_r0_body.kd96 PRE_first_tail_x6_r0_body.khinv96 PRE_first_tail_x6_r0_body.kninv96 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx PRE_first_tail_x6_r0_body.cx0_96.mlx PRE_first_tail_x6_r0_body.cx1_96.mlx (⟨20104, 17174, 2750791, 4187⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo96 PRE_first_tail_x6_r0_body.cln96 PRE_first_tail_x6_r0_body.cli96 PRE_first_tail_x6_r0_body.cwS96 PRE_first_tail_x6_r0_body.cnS96 PRE_first_tail_x6_r0_body.ciS96 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh096, PRE_first_tail_x6_r0_body.cnh196, PRE_first_tail_x6_r0_body.cnn096, PRE_first_tail_x6_r0_body.cnn196, PRE_first_tail_x6_r0_body.cplo96, PRE_first_tail_x6_r0_body.ccnt96, PRE_first_tail_x6_r0_body.cnband96, PRE_first_tail_x6_r0_body.chbelow96, PRE_first_tail_x6_r0_body.chren96, PRE_first_tail_x6_r0_body.cband96, PRE_first_tail_x6_r0_body.cnh1pos96, PRE_first_tail_x6_r0_body.cnren96, PRE_first_tail_x6_r0_body.cnlow96, PRE_first_tail_x6_r0_body.cabs0a96, PRE_first_tail_x6_r0_body.cabs0b96, PRE_first_tail_x6_r0_body.ctok196, PRE_first_tail_x6_r0_body.cpend96, PRE_first_tail_x6_r0_body.cerrh96, PRE_first_tail_x6_r0_body.cfiles96, PRE_first_tail_x6_r0_body.carch96, PRE_first_tail_x6_r0_body.csizes96, PRE_first_tail_x6_r0_body.cwired96, PRE_first_tail_x6_r0_body.cfix96, clean, PRE_first_tail_x6_r0_body.fcxn96, PRE_first_tail_x6_r0_body.fcnn96, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle096, PRE_first_tail_x6_r0_body.fnk96, PRE_first_tail_x6_r0_body.ckA96, PRE_first_tail_x6_r0_body.cobjsK96, PRE_first_tail_x6_r0_body.cnodesK96, PRE_first_tail_x6_r0_body.citemsK96, PRE_first_tail_x6_r0_body.f1A96, PRE_first_tail_x6_r0_body.f1O96, PRE_first_tail_x6_r0_body.f1N96, PRE_first_tail_x6_r0_body.f1I96, PRE_first_tail_x6_r0_body.fbd96, PRE_first_tail_x6_r0_body.fincW96, PRE_first_tail_x6_r0_body.fincI96, PRE_first_tail_x6_r0_body.fincN96, PRE_first_tail_x6_r0_body.flnF96, PRE_first_tail_x6_r0_body.fh96, PRE_first_tail_x6_r0_body.fo96, PRE_first_tail_x6_r0_body.fok96, PRE_first_tail_x6_r0_body.fnd96, PRE_first_tail_x6_r0_body.fp96, PRE_first_tail_x6_r0_body.fnord96, PRE_first_tail_x6_r0_body.fi96, PRE_first_tail_x6_r0_body.fii96⟩
theorem PRE_first_tail_x6_r0_body.cnshift96 (clean : Conv.NClean (⟨20104, 17174, 2750791, 4187⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P96.NL) (cl : SSt (· < 4205) PRE_first_tail_x6_r0_body.cx0_96.mlx) : NShift PRE_first_tail_x6_r0_body.P96 4205 PRE_first_tail_x6_r0_body.kappa96 PRE_first_tail_x6_r0_body.cx0_96 PRE_first_tail_x6_r0_body.cx1_96 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot96 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost96 (compact_a_eq PRE_first_tail_x6_r0_body.ckn096 PRE_first_tail_x6_r0_body.ckn196 PRE_first_tail_x6_r0_body.ckheap96 PRE_first_tail_x6_r0_body.ckpl96)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_96 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s936.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_96 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s936.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_96 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s936.ffi) = some PRE_first_tail_x6_r0_body.fxC_96
kernel_rfl PRE_first_tail_x6_r0_body.okrC_96 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s936.ffi) = some PRE_first_tail_x6_r0_body.krC_96
noncomputable def PRE_first_tail_x6_r0_body.fx0_96 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s938.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_96 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s938.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_96 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s938.ffi) = some PRE_first_tail_x6_r0_body.fx0_96
kernel_rfl PRE_first_tail_x6_r0_body.okr0_96 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s938.ffi) = some PRE_first_tail_x6_r0_body.kr0_96
noncomputable def PRE_first_tail_x6_r0_body.fx1_96 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s937.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_96 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s937.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_96 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s937.ffi) = some PRE_first_tail_x6_r0_body.fx1_96
kernel_rfl PRE_first_tail_x6_r0_body.okr1_96 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s937.ffi) = some PRE_first_tail_x6_r0_body.kr1_96
kernel_rfl PRE_first_tail_x6_r0_body.ff096 : PRE_first_tail_x6_r0_body.fx0_96 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_96 (PRE_first_tail_x6_r0_body.clo96.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_96.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff196 : PRE_first_tail_x6_r0_body.fx1_96 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_96 (PRE_first_tail_x6_r0_body.cwS96.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_96.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck96 : freedLB PRE_first_tail_x6_r0_body.kappa96 PRE_first_tail_x6_r0_body.cx0_96.mlx PRE_first_tail_x6_r0_body.fx0_96 PRE_first_tail_x6_r0_body.fx1_96 PRE_first_tail_x6_r0_body.clo96 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf096 : PRE_first_tail_x6_r0_body.kr0_96.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_96.flags (PRE_first_tail_x6_r0_body.clo96.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_96.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt096 : PRE_first_tail_x6_r0_body.kr0_96.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_96.targs (PRE_first_tail_x6_r0_body.clo96.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_96.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf196 : PRE_first_tail_x6_r0_body.kr1_96.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_96.flags (PRE_first_tail_x6_r0_body.cwS96.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_96.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt196 : PRE_first_tail_x6_r0_body.kr1_96.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_96.targs (PRE_first_tail_x6_r0_body.cwS96.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_96.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck96 : krecLB PRE_first_tail_x6_r0_body.kappa96 4205 PRE_first_tail_x6_r0_body.cx0_96.mlx PRE_first_tail_x6_r0_body.kr0_96 PRE_first_tail_x6_r0_body.kr1_96 PRE_first_tail_x6_r0_body.clo96 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn96 : Nat.ble 4187 4205 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge96 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s937.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s938.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR96 : pendRegB PRE_first_tail_x6_r0_body.kappa96 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s938.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe96 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s938.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s937.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift96 (clean : Conv.NClean (⟨20104, 17174, 2750791, 4187⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P96.NL) (cl : SSt (· < 4205) PRE_first_tail_x6_r0_body.cx0_96.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_96.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_96.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_96.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s936.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_96.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20104, 17174, 2750791, 4187⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P96 4205 PRE_first_tail_x6_r0_body.kappa96 PRE_first_tail_x6_r0_body.s938.ffi PRE_first_tail_x6_r0_body.s937.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift96 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue96, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp96 t ht),
    PRE_first_tail_x6_r0_body.cbridge96,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s938.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s937.ffi) (PRE_first_tail_x6_r0_body.cfoot96 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_96 PRE_first_tail_x6_r0_body.ofx1_96 hobjC PRE_first_tail_x6_r0_body.ff096 PRE_first_tail_x6_r0_body.ff196 PRE_first_tail_x6_r0_body.ffck96,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s938.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s937.ffi) (PRE_first_tail_x6_r0_body.cfoot96 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_96 PRE_first_tail_x6_r0_body.okr1_96 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn96) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf096 PRE_first_tail_x6_r0_body.fkt096 PRE_first_tail_x6_r0_body.fkf196 PRE_first_tail_x6_r0_body.fkt196 PRE_first_tail_x6_r0_body.fkck96,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh096 PRE_first_tail_x6_r0_body.cnh196 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe96) PRE_first_tail_x6_r0_body.cpendR96⟩

end Host.Load.Run.Tpl
end

section -- st96/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st96 0
host_stream_state PRE_first_tail_x6_r0_body.st96 1
host_stream_state PRE_first_tail_x6_r0_body.st96 2
host_stream_state PRE_first_tail_x6_r0_body.st96 3
host_stream_state PRE_first_tail_x6_r0_body.st96 4
host_stream_state PRE_first_tail_x6_r0_body.st96 5
end Host.Load.Run.Tpl
end

section -- Site96
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 96 of chain `PRE_first_tail_x6_r0_body`: `ssmW__g96__g97` (`recurWindow`), the call state `PRE_first_tail_x6_r0_body.s936`, the merged state `PRE_first_tail_x6_r0_body.s937`,
the site template `PRE_first_tail_x6_r0_body.st96` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s938`: the merge.
The footprint's facts are in `SiteF96`, the compaction's in `SiteC96`, `SiteK96`, `SiteNa96`, `SiteNb96`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso96 : PRE_first_tail_x6_r0_body.st96.s0 = { PRE_first_tail_x6_r0_body.s936 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs96 : List Frame := PRE_first_tail_x6_r0_body.s936.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_96 : PRE_first_tail_x6_r0_body.S936.tab.length = 4187
kernel_rfl PRE_first_tail_x6_r0_body.tab0_96 : PRE_first_tail_x6_r0_body.st96.S0.tab = PRE_first_tail_x6_r0_body.S936.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws96 : List Nat := [2598, 2599, 2600, 2601, 2602, 2603, 2604, 2605, 2606, 2607, 2608, 2609, 2610, 2611, 2612, 2613, 2614, 2615, 2616, 2617, 2618, 2619, 2620, 2621, 2622, 2623, 2624, 2625, 2626, 2627, 2628]
kernel_rfl PRE_first_tail_x6_r0_body.fresh96 : (PRE_first_tail_x6_r0_body.S936.tab.all fun e => PRE_first_tail_x6_r0_body.ws96.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S936.oracle.all fun q => PRE_first_tail_x6_r0_body.ws96.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab96 : PRE_first_tail_x6_r0_body.S937.tab = PRE_first_tail_x6_r0_body.S936.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws96
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen96 : PRE_first_tail_x6_r0_body.st96.S5.tab.length - PRE_first_tail_x6_r0_body.st96.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged96`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap96 : PRE_first_tail_x6_r0_body.s937.heap = PRE_first_tail_x6_r0_body.st96.s5.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext96 : PRE_first_tail_x6_r0_body.s937.next = PRE_first_tail_x6_r0_body.st96.s5.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl96 : PRE_first_tail_x6_r0_body.s937.ctl = PRE_first_tail_x6_r0_body.st96.s5.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack96 : PRE_first_tail_x6_r0_body.s937.stack = PRE_first_tail_x6_r0_body.st96.s5.stack ++ PRE_first_tail_x6_r0_body.s936.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs96 : PRE_first_tail_x6_r0_body.s937.jobs = PRE_first_tail_x6_r0_body.st96.s5.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi96 : PRE_first_tail_x6_r0_body.s937.ffi = PRE_first_tail_x6_r0_body.st96.s5.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace96 : PRE_first_tail_x6_r0_body.s937.trace = PRE_first_tail_x6_r0_body.st96.s5.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores96 : PRE_first_tail_x6_r0_body.s937.stores = PRE_first_tail_x6_r0_body.st96.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD96
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 96 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived96 : PRE_first_tail_x6_r0_body.nr96.map (fun r => nth? PRE_first_tail_x6_r0_body.st96.S5.tab r) =
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
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo96 : PRE_first_tail_x6_r0_body.nr96.all (Nat.ble 4187) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj96 : PRE_first_tail_x6_r0_body.cws96.all (fun c => !PRE_first_tail_x6_r0_body.ws96.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ96 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws96 PRE_first_tail_x6_r0_body.crs96 PRE_first_tail_x6_r0_body.ws96

end Host.Load.Run.Tpl
end

section -- st96/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st96`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st96.wrR : List (Nat × Nat) := [(2672548, 2672549), (2749965, 2749966), (2750510, 2750511), (2750766, 2750767)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st96.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st96.s5.heap PRE_first_tail_x6_r0_body.st96.wrR ++ freshOf PRE_first_tail_x6_r0_body.st96.s5.heap PRE_first_tail_x6_r0_body.st96.s0.next PRE_first_tail_x6_r0_body.st96.s5.next
noncomputable def PRE_first_tail_x6_r0_body.st96.wr : List Nat := PRE_first_tail_x6_r0_body.st96.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st96.heapFoot : PRE_first_tail_x6_r0_body.st96.s5.heap = setAll PRE_first_tail_x6_r0_body.st96.s0.heap PRE_first_tail_x6_r0_body.st96.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st96.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st96.s0.next PRE_first_tail_x6_r0_body.st96.s5.next = true
theorem PRE_first_tail_x6_r0_body.st96.grows : PRE_first_tail_x6_r0_body.st96.s0.next ≤ PRE_first_tail_x6_r0_body.st96.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st96.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st96.wh : List Nat := [20084, 20097, 20103, 20104, 20105, 20106, 20107, 20108, 20109, 20110, 20111, 20112, 20113, 20114, 20115, 20116, 20117, 20118, 20119, 20120, 20121, 20122, 20123, 20124, 20125, 20126, 20127, 20128, 20129, 20130, 20131]
def PRE_first_tail_x6_r0_body.st96.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st96.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st96.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st96.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st96.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st96.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st96.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st96.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st96.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st96.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st96.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st96.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st96.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st96.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st96.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st96.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st96.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st96.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st96.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st96.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st96.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st96.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st96.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st96.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st96.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st96.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st96.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st96.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st96.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st96.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF96
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 96 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB96 : nodupT PRE_first_tail_x6_r0_body.st96.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup96 : PRE_first_tail_x6_r0_body.st96.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB96).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB96 : PRE_first_tail_x6_r0_body.st96.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound96 : ∀ b ∈ PRE_first_tail_x6_r0_body.st96.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB96 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr96 := PRE_first_tail_x6_r0_body.st96.s5.trace.take 120
kernel_rfl PRE_first_tail_x6_r0_body.traceEq96 : PRE_first_tail_x6_r0_body.st96.s5.trace = PRE_first_tail_x6_r0_body.trFr96 ++ PRE_first_tail_x6_r0_body.st96.s0.trace
theorem PRE_first_tail_x6_r0_body.trace96 : ∃ fr, PRE_first_tail_x6_r0_body.st96.s5.trace = fr ++ PRE_first_tail_x6_r0_body.st96.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq96⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide96 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB96 : (PRE_first_tail_x6_r0_body.wide96.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st96.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix96 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide96, WFix Map.id (Present PRE_first_tail_x6_r0_body.st96.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB96 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL96
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 96 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s937`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO96 : PRE_first_tail_x6_r0_body.st96.S0.oracle = PRE_first_tail_x6_r0_body.st96.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B96 : PRE_first_tail_x6_r0_body.st96.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st96.s0.next || (PRE_first_tail_x6_r0_body.st96.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot96 : Conv.StageFoot PRE_first_tail_x6_r0_body.st96.wr PRE_first_tail_x6_r0_body.st96.s0 PRE_first_tail_x6_r0_body.st96.s5 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st96.heapFoot PRE_first_tail_x6_r0_body.wrNodup96 PRE_first_tail_x6_r0_body.wrBound96 PRE_first_tail_x6_r0_body.wr0B96 PRE_first_tail_x6_r0_body.st96.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged96 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st96.F.S → PRE_first_tail_x6_r0_body.st96.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st96.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st96.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs96 PRE_first_tail_x6_r0_body.st96.wr PRE_first_tail_x6_r0_body.s936 PRE_first_tail_x6_r0_body.st96.s5 PRE_first_tail_x6_r0_body.st96.s0
      PRE_first_tail_x6_r0_body.st96.s5.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st96.F FR W stk M ν K PRE_first_tail_x6_r0_body.s937 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso96 PRE_first_tail_x6_r0_body.stFoot96 PRE_first_tail_x6_r0_body.wrNodup96 PRE_first_tail_x6_r0_body.wrBound96 PRE_first_tail_x6_r0_body.trace96 PRE_first_tail_x6_r0_body.mheap96
    PRE_first_tail_x6_r0_body.mnext96 PRE_first_tail_x6_r0_body.mctl96 PRE_first_tail_x6_r0_body.mstack96 PRE_first_tail_x6_r0_body.mjobs96 PRE_first_tail_x6_r0_body.mffi96 PRE_first_tail_x6_r0_body.mtrace96 PRE_first_tail_x6_r0_body.mstores96 h

def PRE_first_tail_x6_r0_body.arrEl96_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE96_2665 : arrOf PRE_first_tail_x6_r0_body.s937 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl96_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA96_2665 : isArrB PRE_first_tail_x6_r0_body.s937 2665 = true
theorem PRE_first_tail_x6_r0_body.arr96_2665 : ∃ o, PRE_first_tail_x6_r0_body.s937.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl96_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE96_2665 PRE_first_tail_x6_r0_body.arrA96_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN96_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl96_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR96_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl96_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN96_2665

def PRE_first_tail_x6_r0_body.arrEl96_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE96_2673467 : arrOf PRE_first_tail_x6_r0_body.s937 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl96_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA96_2673467 : isArrB PRE_first_tail_x6_r0_body.s937 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr96_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s937.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl96_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE96_2673467 PRE_first_tail_x6_r0_body.arrA96_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN96_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl96_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR96_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl96_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN96_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k96 : isArrB PRE_first_tail_x6_r0_body.s937 4910 = false
theorem PRE_first_tail_x6_r0_body.keep96 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s937 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k96 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr96_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl96_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ96
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 96 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s936`, the merged
state `PRE_first_tail_x6_r0_body.s937`, the canonical state `PRE_first_tail_x6_r0_body.s938`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl96 : PRE_first_tail_x6_r0_body.pl96.all (Nat.ble PRE_first_tail_x6_r0_body.s936.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd96 : nodupT PRE_first_tail_x6_r0_body.pl96 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn196 : Nat.ble PRE_first_tail_x6_r0_body.s936.next 2751946 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst96 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s936.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn96 : PRE_first_tail_x6_r0_body.s938.next = PRE_first_tail_x6_r0_body.s936.next + PRE_first_tail_x6_r0_body.pl96.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn96 : PRE_first_tail_x6_r0_body.s937.next = 2751946
kernel_rfl PRE_first_tail_x6_r0_body.zgrow96 : Nat.ble PRE_first_tail_x6_r0_body.s938.next PRE_first_tail_x6_r0_body.s937.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh96 : PRE_first_tail_x6_r0_body.S936.tab.all (fun e => PRE_first_tail_x6_r0_body.cws96.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd96 : nodupT PRE_first_tail_x6_r0_body.cws96 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi96 : PRE_first_tail_x6_r0_body.nr96.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S937.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt96 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s936.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg96_2665 : PRE_first_tail_x6_r0_body.s938.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s938 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk96_2665 : (objOf PRE_first_tail_x6_r0_body.s938 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm96_2665 : PRE_first_tail_x6_r0_body.s937.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa96.obj (objOf PRE_first_tail_x6_r0_body.s938 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s937 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg96_2673467 : PRE_first_tail_x6_r0_body.s938.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s938 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk96_2673467 : (objOf PRE_first_tail_x6_r0_body.s938 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm96_2673467 : PRE_first_tail_x6_r0_body.s937.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa96.obj (objOf PRE_first_tail_x6_r0_body.s938 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s937 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw96_4910 : (PRE_first_tail_x6_r0_body.s938.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw96_2673472 : (PRE_first_tail_x6_r0_body.s938.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw96_2673473 : (PRE_first_tail_x6_r0_body.s938.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd96 : PRE_first_tail_x6_r0_body.cl96.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr96 : PRE_first_tail_x6_r0_body.st96.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s936.next || PRE_first_tail_x6_r0_body.cl96.contains b) = true
def PRE_first_tail_x6_r0_body.zl96 : List Nat := PRE_first_tail_x6_r0_body.cl96.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE96 : PRE_first_tail_x6_r0_body.zl96.map (fun a => PRE_first_tail_x6_r0_body.s937.heap.get (PRE_first_tail_x6_r0_body.kappa96.a a)) = PRE_first_tail_x6_r0_body.zl96.map (fun a => (PRE_first_tail_x6_r0_body.s938.heap.get a).map PRE_first_tail_x6_r0_body.kappa96.hobj)
theorem PRE_first_tail_x6_r0_body.zimg96 : HeapImg PRE_first_tail_x6_r0_body.kappa96 PRE_first_tail_x6_r0_body.s938 PRE_first_tail_x6_r0_body.s937 PRE_first_tail_x6_r0_body.zl96 := PRE_first_tail_x6_r0_body.zimgE96
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl96 : PRE_first_tail_x6_r0_body.s937.ctl = PRE_first_tail_x6_r0_body.kappa96.ctl PRE_first_tail_x6_r0_body.s938.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack96 : PRE_first_tail_x6_r0_body.s937.stack = PRE_first_tail_x6_r0_body.s938.stack.map PRE_first_tail_x6_r0_body.kappa96.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs96 : PRE_first_tail_x6_r0_body.s937.jobs = PRE_first_tail_x6_r0_body.s938.jobs.map PRE_first_tail_x6_r0_body.kappa96.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores96 : PRE_first_tail_x6_r0_body.s937.stores = PRE_first_tail_x6_r0_body.kappa96.stores PRE_first_tail_x6_r0_body.s938.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots96 : checkRootsSupp PRE_first_tail_x6_r0_body.s938 4205 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC96 : PRE_first_tail_x6_r0_body.S936.tab.length + PRE_first_tail_x6_r0_body.cws96.length = 4205
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap96 : PRE_first_tail_x6_r0_body.kappa96 = Conv.Map.compact PRE_first_tail_x6_r0_body.s936.next 2751946 PRE_first_tail_x6_r0_body.S936.tab.length PRE_first_tail_x6_r0_body.pl96 (PRE_first_tail_x6_r0_body.nr96.map NumV.ref) PRE_first_tail_x6_r0_body.kd96.big
  PRE_first_tail_x6_r0_body.kd96.region PRE_first_tail_x6_r0_body.kd96.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin96 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s938.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc96 : Conv.jcleanListB (⟨20107, 17201, 2750797, 4205⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s938 PRE_first_tail_x6_r0_body.cl96 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB96 : noBigRootsP (fun i => !Conv.oldBigB (⟨20107, 17201, 2750797, 4205⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s938.trace PRE_first_tail_x6_r0_body.s938 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm96 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 17174 = true
theorem PRE_first_tail_x6_r0_body.cjcl96 (h : Conv.JClean (⟨20104, 17174, 2750791, 4187⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s936) : Conv.JClean (⟨20107, 17201, 2750797, 4205⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s938 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle96)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap96 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd96 a ha)) PRE_first_tail_x6_r0_body.zjc96

end Host.Load.Run.Tpl
end

section -- st96/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st96.bodyLast from PRE_first_tail_x6_r0_body.st96.s4 to PRE_first_tail_x6_r0_body.st96.s5 :
  interpS (step PRE_first_tail_x6_r0_body.st96.F PRE_first_tail_x6_r0_body.st96.s4).run PRE_first_tail_x6_r0_body.st96.S4 = some (PRE_first_tail_x6_r0_body.st96.s5, PRE_first_tail_x6_r0_body.st96.S5)
kernel_rfl PRE_first_tail_x6_r0_body.st96.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st96.s4.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st96.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st96.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st96/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st96.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st96.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st96.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st96.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st96.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st96.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st96.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st96.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st96.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st96.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st96.s0 PRE_first_tail_x6_r0_body.st96.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st96.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st96.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st96.s4 PRE_first_tail_x6_r0_body.st96.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st96/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st96.bodyK0F from PRE_first_tail_x6_r0_body.st96.s0 to PRE_first_tail_x6_r0_body.st96.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st96.F (PRE_first_tail_x6_r0_body.st96.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st96.ks 0).getD 0) PRE_first_tail_x6_r0_body.st96.s0 PRE_first_tail_x6_r0_body.st96.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st96.s1, PRE_first_tail_x6_r0_body.st96.S1)
theorem PRE_first_tail_x6_r0_body.st96.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st96.F (PRE_first_tail_x6_r0_body.st96.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st96.ks 0).getD 0) PRE_first_tail_x6_r0_body.st96.s0 PRE_first_tail_x6_r0_body.st96.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st96.s1, PRE_first_tail_x6_r0_body.st96.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st96.bodyOkLN_ok PRE_first_tail_x6_r0_body.st96.bodyK0F
end Host.Load.Run.Tpl
end

section -- st96/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st96.bodyK1F from PRE_first_tail_x6_r0_body.st96.s1 to PRE_first_tail_x6_r0_body.st96.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st96.F (PRE_first_tail_x6_r0_body.st96.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st96.ks 1).getD 0) PRE_first_tail_x6_r0_body.st96.s1 PRE_first_tail_x6_r0_body.st96.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st96.s2, PRE_first_tail_x6_r0_body.st96.S2)
theorem PRE_first_tail_x6_r0_body.st96.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st96.F (PRE_first_tail_x6_r0_body.st96.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st96.ks 1).getD 0) PRE_first_tail_x6_r0_body.st96.s1 PRE_first_tail_x6_r0_body.st96.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st96.s2, PRE_first_tail_x6_r0_body.st96.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st96.bodyOkLN_ok PRE_first_tail_x6_r0_body.st96.bodyK1F
end Host.Load.Run.Tpl
end

section -- st96/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st96.bodyK2F from PRE_first_tail_x6_r0_body.st96.s2 to PRE_first_tail_x6_r0_body.st96.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st96.F (PRE_first_tail_x6_r0_body.st96.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st96.ks 2).getD 0) PRE_first_tail_x6_r0_body.st96.s2 PRE_first_tail_x6_r0_body.st96.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st96.s3, PRE_first_tail_x6_r0_body.st96.S3)
theorem PRE_first_tail_x6_r0_body.st96.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st96.F (PRE_first_tail_x6_r0_body.st96.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st96.ks 2).getD 0) PRE_first_tail_x6_r0_body.st96.s2 PRE_first_tail_x6_r0_body.st96.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st96.s3, PRE_first_tail_x6_r0_body.st96.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st96.bodyOkLN_ok PRE_first_tail_x6_r0_body.st96.bodyK2F
end Host.Load.Run.Tpl
end

section -- st96/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st96.bodyK3F from PRE_first_tail_x6_r0_body.st96.s3 to PRE_first_tail_x6_r0_body.st96.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st96.F (PRE_first_tail_x6_r0_body.st96.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st96.ks 3).getD 0) PRE_first_tail_x6_r0_body.st96.s3 PRE_first_tail_x6_r0_body.st96.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st96.s4, PRE_first_tail_x6_r0_body.st96.S4)
theorem PRE_first_tail_x6_r0_body.st96.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st96.F (PRE_first_tail_x6_r0_body.st96.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st96.ks 3).getD 0) PRE_first_tail_x6_r0_body.st96.s3 PRE_first_tail_x6_r0_body.st96.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st96.s4, PRE_first_tail_x6_r0_body.st96.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st96.bodyOkLN_ok PRE_first_tail_x6_r0_body.st96.bodyK3F
end Host.Load.Run.Tpl
end

section -- st96/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st96.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st96.F (PRE_first_tail_x6_r0_body.st96.bodyOkL bytes rows) 11334 PRE_first_tail_x6_r0_body.st96.s0 PRE_first_tail_x6_r0_body.st96.S0 = some (PRE_first_tail_x6_r0_body.st96.s4, PRE_first_tail_x6_r0_body.st96.S4) :=
  runOk_trans PRE_first_tail_x6_r0_body.st96.F (PRE_first_tail_x6_r0_body.st96.bodyOkL bytes rows) ((((nth? PRE_first_tail_x6_r0_body.st96.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st96.ks 1).getD 0)) + ((nth? PRE_first_tail_x6_r0_body.st96.ks 2).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st96.ks 3).getD 0) PRE_first_tail_x6_r0_body.st96.s0 PRE_first_tail_x6_r0_body.st96.s3 PRE_first_tail_x6_r0_body.st96.s4 PRE_first_tail_x6_r0_body.st96.S0 PRE_first_tail_x6_r0_body.st96.S3 PRE_first_tail_x6_r0_body.st96.S4 (runOk_trans PRE_first_tail_x6_r0_body.st96.F (PRE_first_tail_x6_r0_body.st96.bodyOkL bytes rows) (((nth? PRE_first_tail_x6_r0_body.st96.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st96.ks 1).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st96.ks 2).getD 0) PRE_first_tail_x6_r0_body.st96.s0 PRE_first_tail_x6_r0_body.st96.s2 PRE_first_tail_x6_r0_body.st96.s3 PRE_first_tail_x6_r0_body.st96.S0 PRE_first_tail_x6_r0_body.st96.S2 PRE_first_tail_x6_r0_body.st96.S3 (runOk_trans PRE_first_tail_x6_r0_body.st96.F (PRE_first_tail_x6_r0_body.st96.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st96.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st96.ks 1).getD 0) PRE_first_tail_x6_r0_body.st96.s0 PRE_first_tail_x6_r0_body.st96.s1 PRE_first_tail_x6_r0_body.st96.s2 PRE_first_tail_x6_r0_body.st96.S0 PRE_first_tail_x6_r0_body.st96.S1 PRE_first_tail_x6_r0_body.st96.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st96.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st96.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st96.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st96.bodyK3 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st96.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st96.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st96.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st96.F (PRE_first_tail_x6_r0_body.st96.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st96.s0
  S0 := PRE_first_tail_x6_r0_body.st96.S0
  s1 := PRE_first_tail_x6_r0_body.st96.s4
  S1 := PRE_first_tail_x6_r0_body.st96.S4
  s2 := PRE_first_tail_x6_r0_body.st96.s5
  S2 := PRE_first_tail_x6_r0_body.st96.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st96.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st96.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st96.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st96.bodyHalt
  last := PRE_first_tail_x6_r0_body.st96.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st96.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC97
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 97 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s946` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa97` into the merged state
`PRE_first_tail_x6_r0_body.s945`. -/

def PRE_first_tail_x6_r0_body.pl97 : List Nat := []
def PRE_first_tail_x6_r0_body.nr97 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd97 : RData :=
  ⟨2751287, 2751289, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20120, 20120, 17214, 17214, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa97 : Map :=
  Conv.Map.compact 2751287 2751289 4226 PRE_first_tail_x6_r0_body.pl97 (PRE_first_tail_x6_r0_body.nr97.map NumV.ref) PRE_first_tail_x6_r0_body.kd97.big
    PRE_first_tail_x6_r0_body.kd97.region PRE_first_tail_x6_r0_body.kd97.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws97 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs97 : List SymE := PRE_first_tail_x6_r0_body.nr97.map fun r => (nth? PRE_first_tail_x6_r0_body.S945.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta97 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws97 PRE_first_tail_x6_r0_body.crs97
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB97 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab97 : PRE_first_tail_x6_r0_body.S946.tab = PRE_first_tail_x6_r0_body.S944.tab ++ PRE_first_tail_x6_r0_body.cws97.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace97 : PRE_first_tail_x6_r0_body.s946.trace = PRE_first_tail_x6_r0_body.s944.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext97 : PRE_first_tail_x6_r0_body.s946.next = 2751287
kernel_rfl PRE_first_tail_x6_r0_body.ccounters97 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s946.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s946.ffi).mlx.nnext) = (20120, 17214)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue97 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s945.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s946.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa97.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp97 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s946.ffi).mlx.tokens.all (bSN 4226) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean97 : Conv.cleanListB 20120 131072 (fun r => Nat.ble 80480 r) PRE_first_tail_x6_r0_body.s946
    (PRE_first_tail_x6_r0_body.wrB97 ++ (List.range 0).map (2751287 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs97 : bigsOutB 20120 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s946.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK97
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl97`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl97 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo97 : List Nat := []
def PRE_first_tail_x6_r0_body.cln97 : List Nat := []
def PRE_first_tail_x6_r0_body.cli97 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap97 : PRE_first_tail_x6_r0_body.s946.heap = Stage.setAll PRE_first_tail_x6_r0_body.s944.heap (PRE_first_tail_x6_r0_body.cl97.filterMap fun a => (PRE_first_tail_x6_r0_body.s946.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe97 : Nat.ble PRE_first_tail_x6_r0_body.s944.next PRE_first_tail_x6_r0_body.s946.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP97 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s944 PRE_first_tail_x6_r0_body.s946 PRE_first_tail_x6_r0_body.cl97 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp97 : Conv.suppListB PRE_first_tail_x6_r0_body.s946 4226 PRE_first_tail_x6_r0_body.cl97 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound97 : Conv.boundListB PRE_first_tail_x6_r0_body.s946 PRE_first_tail_x6_r0_body.cl97 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK97 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s946.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln97.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s946.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK97 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s946.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo97.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s946.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK97 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s946.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli97.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s946.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst97 : Conv.sstListB 4226 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s946.ffi).mlx PRE_first_tail_x6_r0_body.cln97 PRE_first_tail_x6_r0_body.clo97 PRE_first_tail_x6_r0_body.cli97 = true

end Host.Load.Run.Tpl
end

section -- SiteCl97
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA97 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s946.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo97.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s946.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd97 : (PRE_first_tail_x6_r0_body.clo97 ++ PRE_first_tail_x6_r0_body.cln97 ++ PRE_first_tail_x6_r0_body.cli97).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle97 : Conv.Cnt.leB (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck97 : Conv.ncleanListB (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s946.ffi).mlx PRE_first_tail_x6_r0_body.clo97 PRE_first_tail_x6_r0_body.cln97 PRE_first_tail_x6_r0_body.cli97 = true
theorem PRE_first_tail_x6_r0_body.cncl97 (h : Conv.NClean (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx) : Conv.NClean (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s946.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle97 PRE_first_tail_x6_r0_body.ckA97 PRE_first_tail_x6_r0_body.cobjsK97 PRE_first_tail_x6_r0_body.cnodesK97 PRE_first_tail_x6_r0_body.citemsK97 PRE_first_tail_x6_r0_body.cbd97 PRE_first_tail_x6_r0_body.cck97

end Host.Load.Run.Tpl
end

section -- SiteS97
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 97 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc97 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P97 : LoadP := PRE_first_tail_x6_r0_body.Pc97.raise 17214
kernel_rfl PRE_first_tail_x6_r0_body.craise97 : Nat.ble PRE_first_tail_x6_r0_body.Pc97.N0 17214 = true
theorem PRE_first_tail_x6_r0_body.raised97 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc97 PRE_first_tail_x6_r0_body.P97 :=
  .inr ⟨17214, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise97, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_97 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s946.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_97 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s945.ffi)
def PRE_first_tail_x6_r0_body.khinv97 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv97 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS97 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS97 : List Nat := List.range' 17214 0
def PRE_first_tail_x6_r0_body.ciS97 : List Nat := [] ++ List.range' 17214 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh097 : PRE_first_tail_x6_r0_body.kd97.nh0 = PRE_first_tail_x6_r0_body.cx0_97.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh197 : PRE_first_tail_x6_r0_body.kd97.nh1 = PRE_first_tail_x6_r0_body.cx1_97.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn097 : PRE_first_tail_x6_r0_body.kd97.nn0 = PRE_first_tail_x6_r0_body.cx0_97.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn197 : PRE_first_tail_x6_r0_body.kd97.nn1 = PRE_first_tail_x6_r0_body.cx1_97.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo97 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P97.lo && Nat.ble PRE_first_tail_x6_r0_body.P97.lo PRE_first_tail_x6_r0_body.cx0_97.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P97.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P97.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt97 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_97.mlx.next PRE_first_tail_x6_r0_body.cx1_97.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_97.mlx.nnext PRE_first_tail_x6_r0_body.cx1_97.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband97 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P97.NL && Nat.ble PRE_first_tail_x6_r0_body.P97.NL PRE_first_tail_x6_r0_body.P97.N0 && Nat.ble PRE_first_tail_x6_r0_body.P97.N0 PRE_first_tail_x6_r0_body.cx0_97.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow97 : PRE_first_tail_x6_r0_body.kd97.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren97 : checkRenG PRE_first_tail_x6_r0_body.kd97.hnd PRE_first_tail_x6_r0_body.khinv97 (phB PRE_first_tail_x6_r0_body.cx0_97.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband97 : PRE_first_tail_x6_r0_body.kd97.checkBand PRE_first_tail_x6_r0_body.P97.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos97 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd97.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren97 : checkRenG PRE_first_tail_x6_r0_body.kd97.node PRE_first_tail_x6_r0_body.kninv97 (pnB PRE_first_tail_x6_r0_body.cx0_97.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow97 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd97.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P97.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd97.nodeF j) PRE_first_tail_x6_r0_body.cx1_97.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a97 : PRE_first_tail_x6_r0_body.cx0_97.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b97 : PRE_first_tail_x6_r0_body.cx0_97.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok197 : PRE_first_tail_x6_r0_body.cx1_97.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend97 : PRE_first_tail_x6_r0_body.cx1_97.mlx.pending = PRE_first_tail_x6_r0_body.cx0_97.mlx.pending.map PRE_first_tail_x6_r0_body.kappa97.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh97 : PRE_first_tail_x6_r0_body.cx1_97.mlx.errh = PRE_first_tail_x6_r0_body.cx0_97.mlx.errh.map PRE_first_tail_x6_r0_body.kappa97.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles97 : PRE_first_tail_x6_r0_body.cx1_97.mlx.files = PRE_first_tail_x6_r0_body.cx0_97.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch97 : PRE_first_tail_x6_r0_body.cx1_97.mlx.arch = PRE_first_tail_x6_r0_body.cx0_97.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes97 : PRE_first_tail_x6_r0_body.cx1_97.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_97.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired97 : PRE_first_tail_x6_r0_body.cx1_97.mlx.wired = PRE_first_tail_x6_r0_body.cx0_97.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost97 : PRE_first_tail_x6_r0_body.cx1_97.host = PRE_first_tail_x6_r0_body.cx0_97.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd97`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn097 : PRE_first_tail_x6_r0_body.kd97.n0 = 2751287
kernel_rfl PRE_first_tail_x6_r0_body.ckn197 : PRE_first_tail_x6_r0_body.kd97.n1 = 2751289
kernel_rfl PRE_first_tail_x6_r0_body.ckheap97 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd97.heap).all (fun x => Nat.ble 2751287 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl97 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_body.kd97.heap.get (2751287 + j) = nth? PRE_first_tail_x6_r0_body.pl97 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja97 : Nat.ble 2751287 2751287 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn97 : Nat.ble 4226 4226 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD97 : Nat.ble 2751287 PRE_first_tail_x6_r0_body.kd97.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn97 : Nat.ble 20120 PRE_first_tail_x6_r0_body.kd97.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn97 : Nat.ble 17214 PRE_first_tail_x6_r0_body.kd97.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb97 : Nat.ble 20120 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap97 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd97.heap).all (Nat.ble (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd97 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd97.hnd).all (Nat.ble (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode97 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd97.node).all (Nat.ble (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix97 : Conv.FixOld (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa97 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja97) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn97) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD97) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn97) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn97) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb97) PRE_first_tail_x6_r0_body.fheap97 PRE_first_tail_x6_r0_body.fhnd97 PRE_first_tail_x6_r0_body.fnode97
kernel_rfl PRE_first_tail_x6_r0_body.fcxn97 : (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn97 : (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle097 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_97.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_97.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk97 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd97.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A97 : PRE_first_tail_x6_r0_body.cx1_97.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS97.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_97.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O97 : PRE_first_tail_x6_r0_body.cx1_97.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS97.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_97.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N97 : PRE_first_tail_x6_r0_body.cx1_97.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS97.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_97.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I97 : PRE_first_tail_x6_r0_body.cx1_97.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS97.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_97.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd97 : (PRE_first_tail_x6_r0_body.clo97 ++ PRE_first_tail_x6_r0_body.cln97 ++ PRE_first_tail_x6_r0_body.cli97 ++ PRE_first_tail_x6_r0_body.cwS97 ++ PRE_first_tail_x6_r0_body.cnS97 ++ PRE_first_tail_x6_r0_body.ciS97).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW97 : PRE_first_tail_x6_r0_body.cwS97.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo97.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI97 : PRE_first_tail_x6_r0_body.ciS97.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli97.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN97 : PRE_first_tail_x6_r0_body.cnS97.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF97 : PRE_first_tail_x6_r0_body.cln97.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh97 : PRE_first_tail_x6_r0_body.clo97.all (handleOK PRE_first_tail_x6_r0_body.kappa97 PRE_first_tail_x6_r0_body.P97.lo PRE_first_tail_x6_r0_body.cx0_97.mlx PRE_first_tail_x6_r0_body.cx1_97.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo97 : PRE_first_tail_x6_r0_body.clo97.map (fun h => PRE_first_tail_x6_r0_body.cx1_97.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa97.handle h)) = PRE_first_tail_x6_r0_body.clo97.map (fun h => (PRE_first_tail_x6_r0_body.cx0_97.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa97.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok97 : PRE_first_tail_x6_r0_body.clo97.all (objOK PRE_first_tail_x6_r0_body.kappa97 PRE_first_tail_x6_r0_body.P97.NL PRE_first_tail_x6_r0_body.cx0_97.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd97 : PRE_first_tail_x6_r0_body.cln97.all (nodeOKF PRE_first_tail_x6_r0_body.kappa97 PRE_first_tail_x6_r0_body.P97 PRE_first_tail_x6_r0_body.cx0_97.mlx PRE_first_tail_x6_r0_body.cx1_97.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp97 : ((PRE_first_tail_x6_r0_body.cln97.filter (fullB PRE_first_tail_x6_r0_body.P97))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_97.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa97.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln97.filter (fullB PRE_first_tail_x6_r0_body.P97))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_97.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa97.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI97 : incrB PRE_first_tail_x6_r0_body.kd97.nodeF (List.range' 17214 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK97 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd97.node).all (fun k => Nat.ble 17214 k && Nat.blt k 17214) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL97 : (PRE_first_tail_x6_r0_body.cln97.filter (Nat.ble PRE_first_tail_x6_r0_body.P97.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd97.nodeF i) && (Nat.blt i 17214 || Nat.ble PRE_first_tail_x6_r0_body.kd97.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord97 : (PRE_first_tail_x6_r0_body.cln97.filter (Nat.ble PRE_first_tail_x6_r0_body.P97.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd97.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd97.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd97.nodeF j) (PRE_first_tail_x6_r0_body.kd97.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow97 PRE_first_tail_x6_r0_body.cnn197 PRE_first_tail_x6_r0_body.fnordI97 PRE_first_tail_x6_r0_body.fnordK97 PRE_first_tail_x6_r0_body.fnordL97
kernel_rfl PRE_first_tail_x6_r0_body.fi97 : PRE_first_tail_x6_r0_body.cli97.all (pnB PRE_first_tail_x6_r0_body.cx0_97.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii97 : PRE_first_tail_x6_r0_body.cli97.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_97.mlx.items.get (PRE_first_tail_x6_r0_body.kappa97.node k) = (PRE_first_tail_x6_r0_body.cx0_97.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa97.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot97 (clean : Conv.NClean (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P97.NL) (cl : SSt (· < 4226) PRE_first_tail_x6_r0_body.cx0_97.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P97 4226 PRE_first_tail_x6_r0_body.kappa97 PRE_first_tail_x6_r0_body.kd97 PRE_first_tail_x6_r0_body.khinv97 PRE_first_tail_x6_r0_body.kninv97 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx PRE_first_tail_x6_r0_body.cx0_97.mlx PRE_first_tail_x6_r0_body.cx1_97.mlx (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo97 PRE_first_tail_x6_r0_body.cln97 PRE_first_tail_x6_r0_body.cli97 PRE_first_tail_x6_r0_body.cwS97 PRE_first_tail_x6_r0_body.cnS97 PRE_first_tail_x6_r0_body.ciS97 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh097, PRE_first_tail_x6_r0_body.cnh197, PRE_first_tail_x6_r0_body.cnn097, PRE_first_tail_x6_r0_body.cnn197, PRE_first_tail_x6_r0_body.cplo97, PRE_first_tail_x6_r0_body.ccnt97, PRE_first_tail_x6_r0_body.cnband97, PRE_first_tail_x6_r0_body.chbelow97, PRE_first_tail_x6_r0_body.chren97, PRE_first_tail_x6_r0_body.cband97, PRE_first_tail_x6_r0_body.cnh1pos97, PRE_first_tail_x6_r0_body.cnren97, PRE_first_tail_x6_r0_body.cnlow97, PRE_first_tail_x6_r0_body.cabs0a97, PRE_first_tail_x6_r0_body.cabs0b97, PRE_first_tail_x6_r0_body.ctok197, PRE_first_tail_x6_r0_body.cpend97, PRE_first_tail_x6_r0_body.cerrh97, PRE_first_tail_x6_r0_body.cfiles97, PRE_first_tail_x6_r0_body.carch97, PRE_first_tail_x6_r0_body.csizes97, PRE_first_tail_x6_r0_body.cwired97, PRE_first_tail_x6_r0_body.cfix97, clean, PRE_first_tail_x6_r0_body.fcxn97, PRE_first_tail_x6_r0_body.fcnn97, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle097, PRE_first_tail_x6_r0_body.fnk97, PRE_first_tail_x6_r0_body.ckA97, PRE_first_tail_x6_r0_body.cobjsK97, PRE_first_tail_x6_r0_body.cnodesK97, PRE_first_tail_x6_r0_body.citemsK97, PRE_first_tail_x6_r0_body.f1A97, PRE_first_tail_x6_r0_body.f1O97, PRE_first_tail_x6_r0_body.f1N97, PRE_first_tail_x6_r0_body.f1I97, PRE_first_tail_x6_r0_body.fbd97, PRE_first_tail_x6_r0_body.fincW97, PRE_first_tail_x6_r0_body.fincI97, PRE_first_tail_x6_r0_body.fincN97, PRE_first_tail_x6_r0_body.flnF97, PRE_first_tail_x6_r0_body.fh97, PRE_first_tail_x6_r0_body.fo97, PRE_first_tail_x6_r0_body.fok97, PRE_first_tail_x6_r0_body.fnd97, PRE_first_tail_x6_r0_body.fp97, PRE_first_tail_x6_r0_body.fnord97, PRE_first_tail_x6_r0_body.fi97, PRE_first_tail_x6_r0_body.fii97⟩
theorem PRE_first_tail_x6_r0_body.cnshift97 (clean : Conv.NClean (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P97.NL) (cl : SSt (· < 4226) PRE_first_tail_x6_r0_body.cx0_97.mlx) : NShift PRE_first_tail_x6_r0_body.P97 4226 PRE_first_tail_x6_r0_body.kappa97 PRE_first_tail_x6_r0_body.cx0_97 PRE_first_tail_x6_r0_body.cx1_97 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot97 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost97 (compact_a_eq PRE_first_tail_x6_r0_body.ckn097 PRE_first_tail_x6_r0_body.ckn197 PRE_first_tail_x6_r0_body.ckheap97 PRE_first_tail_x6_r0_body.ckpl97)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_97 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s944.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_97 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s944.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_97 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s944.ffi) = some PRE_first_tail_x6_r0_body.fxC_97
kernel_rfl PRE_first_tail_x6_r0_body.okrC_97 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s944.ffi) = some PRE_first_tail_x6_r0_body.krC_97
noncomputable def PRE_first_tail_x6_r0_body.fx0_97 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s946.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_97 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s946.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_97 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s946.ffi) = some PRE_first_tail_x6_r0_body.fx0_97
kernel_rfl PRE_first_tail_x6_r0_body.okr0_97 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s946.ffi) = some PRE_first_tail_x6_r0_body.kr0_97
noncomputable def PRE_first_tail_x6_r0_body.fx1_97 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s945.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_97 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s945.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_97 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s945.ffi) = some PRE_first_tail_x6_r0_body.fx1_97
kernel_rfl PRE_first_tail_x6_r0_body.okr1_97 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s945.ffi) = some PRE_first_tail_x6_r0_body.kr1_97
kernel_rfl PRE_first_tail_x6_r0_body.ff097 : PRE_first_tail_x6_r0_body.fx0_97 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_97 (PRE_first_tail_x6_r0_body.clo97.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_97.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff197 : PRE_first_tail_x6_r0_body.fx1_97 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_97 (PRE_first_tail_x6_r0_body.cwS97.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_97.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck97 : freedLB PRE_first_tail_x6_r0_body.kappa97 PRE_first_tail_x6_r0_body.cx0_97.mlx PRE_first_tail_x6_r0_body.fx0_97 PRE_first_tail_x6_r0_body.fx1_97 PRE_first_tail_x6_r0_body.clo97 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf097 : PRE_first_tail_x6_r0_body.kr0_97.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_97.flags (PRE_first_tail_x6_r0_body.clo97.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_97.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt097 : PRE_first_tail_x6_r0_body.kr0_97.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_97.targs (PRE_first_tail_x6_r0_body.clo97.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_97.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf197 : PRE_first_tail_x6_r0_body.kr1_97.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_97.flags (PRE_first_tail_x6_r0_body.cwS97.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_97.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt197 : PRE_first_tail_x6_r0_body.kr1_97.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_97.targs (PRE_first_tail_x6_r0_body.cwS97.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_97.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck97 : krecLB PRE_first_tail_x6_r0_body.kappa97 4226 PRE_first_tail_x6_r0_body.cx0_97.mlx PRE_first_tail_x6_r0_body.kr0_97 PRE_first_tail_x6_r0_body.kr1_97 PRE_first_tail_x6_r0_body.clo97 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn97 : Nat.ble 4226 4226 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge97 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s945.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s946.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR97 : pendRegB PRE_first_tail_x6_r0_body.kappa97 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s946.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe97 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s946.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s945.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift97 (clean : Conv.NClean (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P97.NL) (cl : SSt (· < 4226) PRE_first_tail_x6_r0_body.cx0_97.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_97.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_97.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_97.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s944.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_97.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P97 4226 PRE_first_tail_x6_r0_body.kappa97 PRE_first_tail_x6_r0_body.s946.ffi PRE_first_tail_x6_r0_body.s945.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift97 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue97, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp97 t ht),
    PRE_first_tail_x6_r0_body.cbridge97,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s946.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s945.ffi) (PRE_first_tail_x6_r0_body.cfoot97 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_97 PRE_first_tail_x6_r0_body.ofx1_97 hobjC PRE_first_tail_x6_r0_body.ff097 PRE_first_tail_x6_r0_body.ff197 PRE_first_tail_x6_r0_body.ffck97,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s946.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s945.ffi) (PRE_first_tail_x6_r0_body.cfoot97 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_97 PRE_first_tail_x6_r0_body.okr1_97 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn97) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf097 PRE_first_tail_x6_r0_body.fkt097 PRE_first_tail_x6_r0_body.fkf197 PRE_first_tail_x6_r0_body.fkt197 PRE_first_tail_x6_r0_body.fkck97,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh097 PRE_first_tail_x6_r0_body.cnh197 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe97) PRE_first_tail_x6_r0_body.cpendR97⟩

end Host.Load.Run.Tpl
end

section -- st97/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st97 0
host_stream_state PRE_first_tail_x6_r0_body.st97 1
host_stream_state PRE_first_tail_x6_r0_body.st97 2
end Host.Load.Run.Tpl
end

section -- Site97
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 97 of chain `PRE_first_tail_x6_r0_body`: `rowBlocks__g97__g98` (`rowBlocks`), the call state `PRE_first_tail_x6_r0_body.s944`, the merged state `PRE_first_tail_x6_r0_body.s945`,
the site template `PRE_first_tail_x6_r0_body.st97` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s946`: the merge.
The footprint's facts are in `SiteF97`, the compaction's in `SiteC97`, `SiteK97`, `SiteNa97`, `SiteNb97`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso97 : PRE_first_tail_x6_r0_body.st97.s0 = { PRE_first_tail_x6_r0_body.s944 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs97 : List Frame := PRE_first_tail_x6_r0_body.s944.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_97 : PRE_first_tail_x6_r0_body.S944.tab.length = 4226
kernel_rfl PRE_first_tail_x6_r0_body.tab0_97 : PRE_first_tail_x6_r0_body.st97.S0.tab = PRE_first_tail_x6_r0_body.S944.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws97 : List Nat := [2647, 2648]
kernel_rfl PRE_first_tail_x6_r0_body.fresh97 : (PRE_first_tail_x6_r0_body.S944.tab.all fun e => PRE_first_tail_x6_r0_body.ws97.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S944.oracle.all fun q => PRE_first_tail_x6_r0_body.ws97.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab97 : PRE_first_tail_x6_r0_body.S945.tab = PRE_first_tail_x6_r0_body.S944.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws97
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen97 : PRE_first_tail_x6_r0_body.st97.S2.tab.length - PRE_first_tail_x6_r0_body.st97.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged97`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap97 : PRE_first_tail_x6_r0_body.s945.heap = PRE_first_tail_x6_r0_body.st97.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext97 : PRE_first_tail_x6_r0_body.s945.next = PRE_first_tail_x6_r0_body.st97.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl97 : PRE_first_tail_x6_r0_body.s945.ctl = PRE_first_tail_x6_r0_body.st97.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack97 : PRE_first_tail_x6_r0_body.s945.stack = PRE_first_tail_x6_r0_body.st97.s2.stack ++ PRE_first_tail_x6_r0_body.s944.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs97 : PRE_first_tail_x6_r0_body.s945.jobs = PRE_first_tail_x6_r0_body.st97.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi97 : PRE_first_tail_x6_r0_body.s945.ffi = PRE_first_tail_x6_r0_body.st97.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace97 : PRE_first_tail_x6_r0_body.s945.trace = PRE_first_tail_x6_r0_body.st97.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores97 : PRE_first_tail_x6_r0_body.s945.stores = PRE_first_tail_x6_r0_body.st97.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD97
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 97 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived97 : PRE_first_tail_x6_r0_body.nr97.map (fun r => nth? PRE_first_tail_x6_r0_body.st97.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo97 : PRE_first_tail_x6_r0_body.nr97.all (Nat.ble 4226) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj97 : PRE_first_tail_x6_r0_body.cws97.all (fun c => !PRE_first_tail_x6_r0_body.ws97.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ97 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws97 PRE_first_tail_x6_r0_body.crs97 PRE_first_tail_x6_r0_body.ws97

end Host.Load.Run.Tpl
end

section -- st97/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st97`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st97.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st97.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st97.s2.heap PRE_first_tail_x6_r0_body.st97.wrR ++ freshOf PRE_first_tail_x6_r0_body.st97.s2.heap PRE_first_tail_x6_r0_body.st97.s0.next PRE_first_tail_x6_r0_body.st97.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st97.wr : List Nat := PRE_first_tail_x6_r0_body.st97.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st97.heapFoot : PRE_first_tail_x6_r0_body.st97.s2.heap = setAll PRE_first_tail_x6_r0_body.st97.s0.heap PRE_first_tail_x6_r0_body.st97.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st97.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st97.s0.next PRE_first_tail_x6_r0_body.st97.s2.next = true
theorem PRE_first_tail_x6_r0_body.st97.grows : PRE_first_tail_x6_r0_body.st97.s0.next ≤ PRE_first_tail_x6_r0_body.st97.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st97.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st97.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st97.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st97.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st97.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st97.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st97.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st97.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st97.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st97.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st97.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st97.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st97.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st97.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st97.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st97.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st97.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st97.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st97.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st97.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st97.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st97.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st97.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st97.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st97.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st97.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st97.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st97.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st97.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st97.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st97.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st97.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF97
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 97 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB97 : nodupT PRE_first_tail_x6_r0_body.st97.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup97 : PRE_first_tail_x6_r0_body.st97.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB97).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB97 : PRE_first_tail_x6_r0_body.st97.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound97 : ∀ b ∈ PRE_first_tail_x6_r0_body.st97.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB97 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr97 := PRE_first_tail_x6_r0_body.st97.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq97 : PRE_first_tail_x6_r0_body.st97.s2.trace = PRE_first_tail_x6_r0_body.trFr97 ++ PRE_first_tail_x6_r0_body.st97.s0.trace
theorem PRE_first_tail_x6_r0_body.trace97 : ∃ fr, PRE_first_tail_x6_r0_body.st97.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st97.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq97⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide97 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB97 : (PRE_first_tail_x6_r0_body.wide97.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st97.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix97 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide97, WFix Map.id (Present PRE_first_tail_x6_r0_body.st97.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB97 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL97
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 97 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s945`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO97 : PRE_first_tail_x6_r0_body.st97.S0.oracle = PRE_first_tail_x6_r0_body.st97.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B97 : PRE_first_tail_x6_r0_body.st97.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st97.s0.next || (PRE_first_tail_x6_r0_body.st97.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot97 : Conv.StageFoot PRE_first_tail_x6_r0_body.st97.wr PRE_first_tail_x6_r0_body.st97.s0 PRE_first_tail_x6_r0_body.st97.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st97.heapFoot PRE_first_tail_x6_r0_body.wrNodup97 PRE_first_tail_x6_r0_body.wrBound97 PRE_first_tail_x6_r0_body.wr0B97 PRE_first_tail_x6_r0_body.st97.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged97 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st97.F.S → PRE_first_tail_x6_r0_body.st97.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st97.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st97.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs97 PRE_first_tail_x6_r0_body.st97.wr PRE_first_tail_x6_r0_body.s944 PRE_first_tail_x6_r0_body.st97.s2 PRE_first_tail_x6_r0_body.st97.s0
      PRE_first_tail_x6_r0_body.st97.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st97.F FR W stk M ν K PRE_first_tail_x6_r0_body.s945 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso97 PRE_first_tail_x6_r0_body.stFoot97 PRE_first_tail_x6_r0_body.wrNodup97 PRE_first_tail_x6_r0_body.wrBound97 PRE_first_tail_x6_r0_body.trace97 PRE_first_tail_x6_r0_body.mheap97
    PRE_first_tail_x6_r0_body.mnext97 PRE_first_tail_x6_r0_body.mctl97 PRE_first_tail_x6_r0_body.mstack97 PRE_first_tail_x6_r0_body.mjobs97 PRE_first_tail_x6_r0_body.mffi97 PRE_first_tail_x6_r0_body.mtrace97 PRE_first_tail_x6_r0_body.mstores97 h

def PRE_first_tail_x6_r0_body.arrEl97_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE97_2665 : arrOf PRE_first_tail_x6_r0_body.s945 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl97_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA97_2665 : isArrB PRE_first_tail_x6_r0_body.s945 2665 = true
theorem PRE_first_tail_x6_r0_body.arr97_2665 : ∃ o, PRE_first_tail_x6_r0_body.s945.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl97_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE97_2665 PRE_first_tail_x6_r0_body.arrA97_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN97_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl97_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR97_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl97_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN97_2665

def PRE_first_tail_x6_r0_body.arrEl97_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE97_2673467 : arrOf PRE_first_tail_x6_r0_body.s945 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl97_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA97_2673467 : isArrB PRE_first_tail_x6_r0_body.s945 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr97_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s945.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl97_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE97_2673467 PRE_first_tail_x6_r0_body.arrA97_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN97_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl97_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR97_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl97_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN97_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k97 : isArrB PRE_first_tail_x6_r0_body.s945 4910 = false
theorem PRE_first_tail_x6_r0_body.keep97 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s945 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k97 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr97_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl97_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ97
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 97 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s944`, the merged
state `PRE_first_tail_x6_r0_body.s945`, the canonical state `PRE_first_tail_x6_r0_body.s946`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl97 : PRE_first_tail_x6_r0_body.pl97.all (Nat.ble PRE_first_tail_x6_r0_body.s944.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd97 : nodupT PRE_first_tail_x6_r0_body.pl97 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn197 : Nat.ble PRE_first_tail_x6_r0_body.s944.next 2751289 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst97 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s944.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn97 : PRE_first_tail_x6_r0_body.s946.next = PRE_first_tail_x6_r0_body.s944.next + PRE_first_tail_x6_r0_body.pl97.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn97 : PRE_first_tail_x6_r0_body.s945.next = 2751289
kernel_rfl PRE_first_tail_x6_r0_body.zgrow97 : Nat.ble PRE_first_tail_x6_r0_body.s946.next PRE_first_tail_x6_r0_body.s945.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh97 : PRE_first_tail_x6_r0_body.S944.tab.all (fun e => PRE_first_tail_x6_r0_body.cws97.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd97 : nodupT PRE_first_tail_x6_r0_body.cws97 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi97 : PRE_first_tail_x6_r0_body.nr97.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S945.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt97 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s944.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg97_2665 : PRE_first_tail_x6_r0_body.s946.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s946 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk97_2665 : (objOf PRE_first_tail_x6_r0_body.s946 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm97_2665 : PRE_first_tail_x6_r0_body.s945.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa97.obj (objOf PRE_first_tail_x6_r0_body.s946 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s945 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg97_2673467 : PRE_first_tail_x6_r0_body.s946.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s946 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk97_2673467 : (objOf PRE_first_tail_x6_r0_body.s946 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm97_2673467 : PRE_first_tail_x6_r0_body.s945.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa97.obj (objOf PRE_first_tail_x6_r0_body.s946 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s945 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw97_4910 : (PRE_first_tail_x6_r0_body.s946.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw97_2673472 : (PRE_first_tail_x6_r0_body.s946.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw97_2673473 : (PRE_first_tail_x6_r0_body.s946.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd97 : PRE_first_tail_x6_r0_body.cl97.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr97 : PRE_first_tail_x6_r0_body.st97.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s944.next || PRE_first_tail_x6_r0_body.cl97.contains b) = true
def PRE_first_tail_x6_r0_body.zl97 : List Nat := PRE_first_tail_x6_r0_body.cl97.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE97 : PRE_first_tail_x6_r0_body.zl97.map (fun a => PRE_first_tail_x6_r0_body.s945.heap.get (PRE_first_tail_x6_r0_body.kappa97.a a)) = PRE_first_tail_x6_r0_body.zl97.map (fun a => (PRE_first_tail_x6_r0_body.s946.heap.get a).map PRE_first_tail_x6_r0_body.kappa97.hobj)
theorem PRE_first_tail_x6_r0_body.zimg97 : HeapImg PRE_first_tail_x6_r0_body.kappa97 PRE_first_tail_x6_r0_body.s946 PRE_first_tail_x6_r0_body.s945 PRE_first_tail_x6_r0_body.zl97 := PRE_first_tail_x6_r0_body.zimgE97
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl97 : PRE_first_tail_x6_r0_body.s945.ctl = PRE_first_tail_x6_r0_body.kappa97.ctl PRE_first_tail_x6_r0_body.s946.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack97 : PRE_first_tail_x6_r0_body.s945.stack = PRE_first_tail_x6_r0_body.s946.stack.map PRE_first_tail_x6_r0_body.kappa97.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs97 : PRE_first_tail_x6_r0_body.s945.jobs = PRE_first_tail_x6_r0_body.s946.jobs.map PRE_first_tail_x6_r0_body.kappa97.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores97 : PRE_first_tail_x6_r0_body.s945.stores = PRE_first_tail_x6_r0_body.kappa97.stores PRE_first_tail_x6_r0_body.s946.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots97 : checkRootsSupp PRE_first_tail_x6_r0_body.s946 4226 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC97 : PRE_first_tail_x6_r0_body.S944.tab.length + PRE_first_tail_x6_r0_body.cws97.length = 4226
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap97 : PRE_first_tail_x6_r0_body.kappa97 = Conv.Map.compact PRE_first_tail_x6_r0_body.s944.next 2751289 PRE_first_tail_x6_r0_body.S944.tab.length PRE_first_tail_x6_r0_body.pl97 (PRE_first_tail_x6_r0_body.nr97.map NumV.ref) PRE_first_tail_x6_r0_body.kd97.big
  PRE_first_tail_x6_r0_body.kd97.region PRE_first_tail_x6_r0_body.kd97.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin97 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s946.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc97 : Conv.jcleanListB (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s946 PRE_first_tail_x6_r0_body.cl97 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB97 : noBigRootsP (fun i => !Conv.oldBigB (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s946.trace PRE_first_tail_x6_r0_body.s946 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm97 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 17214 = true
theorem PRE_first_tail_x6_r0_body.cjcl97 (h : Conv.JClean (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s944) : Conv.JClean (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s946 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle97)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap97 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd97 a ha)) PRE_first_tail_x6_r0_body.zjc97

end Host.Load.Run.Tpl
end

section -- st97/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st97.bodyLast from PRE_first_tail_x6_r0_body.st97.s1 to PRE_first_tail_x6_r0_body.st97.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st97.F PRE_first_tail_x6_r0_body.st97.s1).run PRE_first_tail_x6_r0_body.st97.S1 = some (PRE_first_tail_x6_r0_body.st97.s2, PRE_first_tail_x6_r0_body.st97.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st97.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st97.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st97.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st97.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st97/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st97.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st97.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st97.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st97.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st97.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st97.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st97.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st97.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st97.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st97.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st97.s0 PRE_first_tail_x6_r0_body.st97.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st97.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st97.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st97.s1 PRE_first_tail_x6_r0_body.st97.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st97/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st97.bodyK0F from PRE_first_tail_x6_r0_body.st97.s0 to PRE_first_tail_x6_r0_body.st97.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st97.F (PRE_first_tail_x6_r0_body.st97.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st97.ks 0).getD 0) PRE_first_tail_x6_r0_body.st97.s0 PRE_first_tail_x6_r0_body.st97.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st97.s1, PRE_first_tail_x6_r0_body.st97.S1)
theorem PRE_first_tail_x6_r0_body.st97.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st97.F (PRE_first_tail_x6_r0_body.st97.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st97.ks 0).getD 0) PRE_first_tail_x6_r0_body.st97.s0 PRE_first_tail_x6_r0_body.st97.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st97.s1, PRE_first_tail_x6_r0_body.st97.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st97.bodyOkLN_ok PRE_first_tail_x6_r0_body.st97.bodyK0F
end Host.Load.Run.Tpl
end

section -- st97/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st97.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st97.F (PRE_first_tail_x6_r0_body.st97.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st97.s0 PRE_first_tail_x6_r0_body.st97.S0 = some (PRE_first_tail_x6_r0_body.st97.s1, PRE_first_tail_x6_r0_body.st97.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st97.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st97.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st97.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st97.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st97.F (PRE_first_tail_x6_r0_body.st97.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st97.s0
  S0 := PRE_first_tail_x6_r0_body.st97.S0
  s1 := PRE_first_tail_x6_r0_body.st97.s1
  S1 := PRE_first_tail_x6_r0_body.st97.S1
  s2 := PRE_first_tail_x6_r0_body.st97.s2
  S2 := PRE_first_tail_x6_r0_body.st97.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st97.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st97.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st97.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st97.bodyHalt
  last := PRE_first_tail_x6_r0_body.st97.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st97.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC98
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 98 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s950` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa98` into the merged state
`PRE_first_tail_x6_r0_body.s949`. -/

def PRE_first_tail_x6_r0_body.pl98 : List Nat := [2751594]
def PRE_first_tail_x6_r0_body.nr98 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd98 : RData :=
  ⟨2751576, 2751595, Stage.setAll PTrie.nil [(2751575, 2751594)], Stage.setAll PTrie.nil [],
   20127, 20127, 17218, 17218, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa98 : Map :=
  Conv.Map.compact 2751575 2751595 4243 PRE_first_tail_x6_r0_body.pl98 (PRE_first_tail_x6_r0_body.nr98.map NumV.ref) PRE_first_tail_x6_r0_body.kd98.big
    PRE_first_tail_x6_r0_body.kd98.region PRE_first_tail_x6_r0_body.kd98.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws98 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs98 : List SymE := PRE_first_tail_x6_r0_body.nr98.map fun r => (nth? PRE_first_tail_x6_r0_body.S949.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta98 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws98 PRE_first_tail_x6_r0_body.crs98
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB98 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab98 : PRE_first_tail_x6_r0_body.S950.tab = PRE_first_tail_x6_r0_body.S948.tab ++ PRE_first_tail_x6_r0_body.cws98.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace98 : PRE_first_tail_x6_r0_body.s950.trace = PRE_first_tail_x6_r0_body.s948.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext98 : PRE_first_tail_x6_r0_body.s950.next = 2751576
kernel_rfl PRE_first_tail_x6_r0_body.ccounters98 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s950.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s950.ffi).mlx.nnext) = (20127, 17218)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue98 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s949.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s950.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa98.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp98 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s950.ffi).mlx.tokens.all (bSN 4243) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean98 : Conv.cleanListB 20127 131072 (fun r => Nat.ble 80508 r) PRE_first_tail_x6_r0_body.s950
    (PRE_first_tail_x6_r0_body.wrB98 ++ (List.range 1).map (2751575 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs98 : bigsOutB 20127 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s950.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK98
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl98`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl98 : List Nat := [2665, 2673467, 2751575]
def PRE_first_tail_x6_r0_body.clo98 : List Nat := []
def PRE_first_tail_x6_r0_body.cln98 : List Nat := []
def PRE_first_tail_x6_r0_body.cli98 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap98 : PRE_first_tail_x6_r0_body.s950.heap = Stage.setAll PRE_first_tail_x6_r0_body.s948.heap (PRE_first_tail_x6_r0_body.cl98.filterMap fun a => (PRE_first_tail_x6_r0_body.s950.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe98 : Nat.ble PRE_first_tail_x6_r0_body.s948.next PRE_first_tail_x6_r0_body.s950.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP98 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s948 PRE_first_tail_x6_r0_body.s950 PRE_first_tail_x6_r0_body.cl98 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp98 : Conv.suppListB PRE_first_tail_x6_r0_body.s950 4243 PRE_first_tail_x6_r0_body.cl98 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound98 : Conv.boundListB PRE_first_tail_x6_r0_body.s950 PRE_first_tail_x6_r0_body.cl98 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK98 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s950.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln98.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s950.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK98 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s950.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo98.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s950.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK98 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s950.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli98.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s950.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst98 : Conv.sstListB 4243 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s950.ffi).mlx PRE_first_tail_x6_r0_body.cln98 PRE_first_tail_x6_r0_body.clo98 PRE_first_tail_x6_r0_body.cli98 = true

end Host.Load.Run.Tpl
end

section -- SiteCl98
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA98 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s950.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo98.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s950.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd98 : (PRE_first_tail_x6_r0_body.clo98 ++ PRE_first_tail_x6_r0_body.cln98 ++ PRE_first_tail_x6_r0_body.cli98).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle98 : Conv.Cnt.leB (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt) (⟨20127, 17218, 2751576, 4243⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck98 : Conv.ncleanListB (⟨20127, 17218, 2751576, 4243⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s950.ffi).mlx PRE_first_tail_x6_r0_body.clo98 PRE_first_tail_x6_r0_body.cln98 PRE_first_tail_x6_r0_body.cli98 = true
theorem PRE_first_tail_x6_r0_body.cncl98 (h : Conv.NClean (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx) : Conv.NClean (⟨20127, 17218, 2751576, 4243⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s950.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle98 PRE_first_tail_x6_r0_body.ckA98 PRE_first_tail_x6_r0_body.cobjsK98 PRE_first_tail_x6_r0_body.cnodesK98 PRE_first_tail_x6_r0_body.citemsK98 PRE_first_tail_x6_r0_body.cbd98 PRE_first_tail_x6_r0_body.cck98

end Host.Load.Run.Tpl
end

section -- SiteS98
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 98 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc98 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P98 : LoadP := PRE_first_tail_x6_r0_body.Pc98.raise 17218
kernel_rfl PRE_first_tail_x6_r0_body.craise98 : Nat.ble PRE_first_tail_x6_r0_body.Pc98.N0 17218 = true
theorem PRE_first_tail_x6_r0_body.raised98 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc98 PRE_first_tail_x6_r0_body.P98 :=
  .inr ⟨17218, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise98, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_98 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s950.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_98 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s949.ffi)
def PRE_first_tail_x6_r0_body.khinv98 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv98 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS98 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS98 : List Nat := List.range' 17218 0
def PRE_first_tail_x6_r0_body.ciS98 : List Nat := [] ++ List.range' 17218 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh098 : PRE_first_tail_x6_r0_body.kd98.nh0 = PRE_first_tail_x6_r0_body.cx0_98.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh198 : PRE_first_tail_x6_r0_body.kd98.nh1 = PRE_first_tail_x6_r0_body.cx1_98.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn098 : PRE_first_tail_x6_r0_body.kd98.nn0 = PRE_first_tail_x6_r0_body.cx0_98.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn198 : PRE_first_tail_x6_r0_body.kd98.nn1 = PRE_first_tail_x6_r0_body.cx1_98.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo98 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P98.lo && Nat.ble PRE_first_tail_x6_r0_body.P98.lo PRE_first_tail_x6_r0_body.cx0_98.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P98.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P98.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt98 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_98.mlx.next PRE_first_tail_x6_r0_body.cx1_98.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_98.mlx.nnext PRE_first_tail_x6_r0_body.cx1_98.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband98 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P98.NL && Nat.ble PRE_first_tail_x6_r0_body.P98.NL PRE_first_tail_x6_r0_body.P98.N0 && Nat.ble PRE_first_tail_x6_r0_body.P98.N0 PRE_first_tail_x6_r0_body.cx0_98.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow98 : PRE_first_tail_x6_r0_body.kd98.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren98 : checkRenG PRE_first_tail_x6_r0_body.kd98.hnd PRE_first_tail_x6_r0_body.khinv98 (phB PRE_first_tail_x6_r0_body.cx0_98.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband98 : PRE_first_tail_x6_r0_body.kd98.checkBand PRE_first_tail_x6_r0_body.P98.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos98 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd98.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren98 : checkRenG PRE_first_tail_x6_r0_body.kd98.node PRE_first_tail_x6_r0_body.kninv98 (pnB PRE_first_tail_x6_r0_body.cx0_98.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow98 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd98.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P98.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd98.nodeF j) PRE_first_tail_x6_r0_body.cx1_98.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a98 : PRE_first_tail_x6_r0_body.cx0_98.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b98 : PRE_first_tail_x6_r0_body.cx0_98.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok198 : PRE_first_tail_x6_r0_body.cx1_98.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend98 : PRE_first_tail_x6_r0_body.cx1_98.mlx.pending = PRE_first_tail_x6_r0_body.cx0_98.mlx.pending.map PRE_first_tail_x6_r0_body.kappa98.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh98 : PRE_first_tail_x6_r0_body.cx1_98.mlx.errh = PRE_first_tail_x6_r0_body.cx0_98.mlx.errh.map PRE_first_tail_x6_r0_body.kappa98.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles98 : PRE_first_tail_x6_r0_body.cx1_98.mlx.files = PRE_first_tail_x6_r0_body.cx0_98.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch98 : PRE_first_tail_x6_r0_body.cx1_98.mlx.arch = PRE_first_tail_x6_r0_body.cx0_98.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes98 : PRE_first_tail_x6_r0_body.cx1_98.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_98.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired98 : PRE_first_tail_x6_r0_body.cx1_98.mlx.wired = PRE_first_tail_x6_r0_body.cx0_98.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost98 : PRE_first_tail_x6_r0_body.cx1_98.host = PRE_first_tail_x6_r0_body.cx0_98.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd98`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn098 : PRE_first_tail_x6_r0_body.kd98.n0 = 2751576
kernel_rfl PRE_first_tail_x6_r0_body.ckn198 : PRE_first_tail_x6_r0_body.kd98.n1 = 2751595
kernel_rfl PRE_first_tail_x6_r0_body.ckheap98 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd98.heap).all (fun x => Nat.ble 2751575 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl98 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd98.heap.get (2751575 + j) = nth? PRE_first_tail_x6_r0_body.pl98 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja98 : Nat.ble 2751575 2751575 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn98 : Nat.ble 4243 4243 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD98 : Nat.ble 2751575 PRE_first_tail_x6_r0_body.kd98.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn98 : Nat.ble 20127 PRE_first_tail_x6_r0_body.kd98.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn98 : Nat.ble 17218 PRE_first_tail_x6_r0_body.kd98.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb98 : Nat.ble 20127 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap98 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd98.heap).all (Nat.ble (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd98 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd98.hnd).all (Nat.ble (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode98 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd98.node).all (Nat.ble (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix98 : Conv.FixOld (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa98 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja98) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn98) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD98) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn98) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn98) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb98) PRE_first_tail_x6_r0_body.fheap98 PRE_first_tail_x6_r0_body.fhnd98 PRE_first_tail_x6_r0_body.fnode98
kernel_rfl PRE_first_tail_x6_r0_body.fcxn98 : (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn98 : (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle098 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_98.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_98.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk98 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd98.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A98 : PRE_first_tail_x6_r0_body.cx1_98.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS98.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_98.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O98 : PRE_first_tail_x6_r0_body.cx1_98.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS98.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_98.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N98 : PRE_first_tail_x6_r0_body.cx1_98.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS98.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_98.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I98 : PRE_first_tail_x6_r0_body.cx1_98.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS98.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_98.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd98 : (PRE_first_tail_x6_r0_body.clo98 ++ PRE_first_tail_x6_r0_body.cln98 ++ PRE_first_tail_x6_r0_body.cli98 ++ PRE_first_tail_x6_r0_body.cwS98 ++ PRE_first_tail_x6_r0_body.cnS98 ++ PRE_first_tail_x6_r0_body.ciS98).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW98 : PRE_first_tail_x6_r0_body.cwS98.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo98.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI98 : PRE_first_tail_x6_r0_body.ciS98.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli98.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN98 : PRE_first_tail_x6_r0_body.cnS98.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF98 : PRE_first_tail_x6_r0_body.cln98.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh98 : PRE_first_tail_x6_r0_body.clo98.all (handleOK PRE_first_tail_x6_r0_body.kappa98 PRE_first_tail_x6_r0_body.P98.lo PRE_first_tail_x6_r0_body.cx0_98.mlx PRE_first_tail_x6_r0_body.cx1_98.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo98 : PRE_first_tail_x6_r0_body.clo98.map (fun h => PRE_first_tail_x6_r0_body.cx1_98.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa98.handle h)) = PRE_first_tail_x6_r0_body.clo98.map (fun h => (PRE_first_tail_x6_r0_body.cx0_98.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa98.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok98 : PRE_first_tail_x6_r0_body.clo98.all (objOK PRE_first_tail_x6_r0_body.kappa98 PRE_first_tail_x6_r0_body.P98.NL PRE_first_tail_x6_r0_body.cx0_98.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd98 : PRE_first_tail_x6_r0_body.cln98.all (nodeOKF PRE_first_tail_x6_r0_body.kappa98 PRE_first_tail_x6_r0_body.P98 PRE_first_tail_x6_r0_body.cx0_98.mlx PRE_first_tail_x6_r0_body.cx1_98.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp98 : ((PRE_first_tail_x6_r0_body.cln98.filter (fullB PRE_first_tail_x6_r0_body.P98))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_98.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa98.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln98.filter (fullB PRE_first_tail_x6_r0_body.P98))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_98.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa98.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI98 : incrB PRE_first_tail_x6_r0_body.kd98.nodeF (List.range' 17218 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK98 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd98.node).all (fun k => Nat.ble 17218 k && Nat.blt k 17218) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL98 : (PRE_first_tail_x6_r0_body.cln98.filter (Nat.ble PRE_first_tail_x6_r0_body.P98.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd98.nodeF i) && (Nat.blt i 17218 || Nat.ble PRE_first_tail_x6_r0_body.kd98.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord98 : (PRE_first_tail_x6_r0_body.cln98.filter (Nat.ble PRE_first_tail_x6_r0_body.P98.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd98.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd98.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd98.nodeF j) (PRE_first_tail_x6_r0_body.kd98.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow98 PRE_first_tail_x6_r0_body.cnn198 PRE_first_tail_x6_r0_body.fnordI98 PRE_first_tail_x6_r0_body.fnordK98 PRE_first_tail_x6_r0_body.fnordL98
kernel_rfl PRE_first_tail_x6_r0_body.fi98 : PRE_first_tail_x6_r0_body.cli98.all (pnB PRE_first_tail_x6_r0_body.cx0_98.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii98 : PRE_first_tail_x6_r0_body.cli98.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_98.mlx.items.get (PRE_first_tail_x6_r0_body.kappa98.node k) = (PRE_first_tail_x6_r0_body.cx0_98.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa98.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot98 (clean : Conv.NClean (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P98.NL) (cl : SSt (· < 4243) PRE_first_tail_x6_r0_body.cx0_98.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P98 4243 PRE_first_tail_x6_r0_body.kappa98 PRE_first_tail_x6_r0_body.kd98 PRE_first_tail_x6_r0_body.khinv98 PRE_first_tail_x6_r0_body.kninv98 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx PRE_first_tail_x6_r0_body.cx0_98.mlx PRE_first_tail_x6_r0_body.cx1_98.mlx (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo98 PRE_first_tail_x6_r0_body.cln98 PRE_first_tail_x6_r0_body.cli98 PRE_first_tail_x6_r0_body.cwS98 PRE_first_tail_x6_r0_body.cnS98 PRE_first_tail_x6_r0_body.ciS98 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh098, PRE_first_tail_x6_r0_body.cnh198, PRE_first_tail_x6_r0_body.cnn098, PRE_first_tail_x6_r0_body.cnn198, PRE_first_tail_x6_r0_body.cplo98, PRE_first_tail_x6_r0_body.ccnt98, PRE_first_tail_x6_r0_body.cnband98, PRE_first_tail_x6_r0_body.chbelow98, PRE_first_tail_x6_r0_body.chren98, PRE_first_tail_x6_r0_body.cband98, PRE_first_tail_x6_r0_body.cnh1pos98, PRE_first_tail_x6_r0_body.cnren98, PRE_first_tail_x6_r0_body.cnlow98, PRE_first_tail_x6_r0_body.cabs0a98, PRE_first_tail_x6_r0_body.cabs0b98, PRE_first_tail_x6_r0_body.ctok198, PRE_first_tail_x6_r0_body.cpend98, PRE_first_tail_x6_r0_body.cerrh98, PRE_first_tail_x6_r0_body.cfiles98, PRE_first_tail_x6_r0_body.carch98, PRE_first_tail_x6_r0_body.csizes98, PRE_first_tail_x6_r0_body.cwired98, PRE_first_tail_x6_r0_body.cfix98, clean, PRE_first_tail_x6_r0_body.fcxn98, PRE_first_tail_x6_r0_body.fcnn98, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle098, PRE_first_tail_x6_r0_body.fnk98, PRE_first_tail_x6_r0_body.ckA98, PRE_first_tail_x6_r0_body.cobjsK98, PRE_first_tail_x6_r0_body.cnodesK98, PRE_first_tail_x6_r0_body.citemsK98, PRE_first_tail_x6_r0_body.f1A98, PRE_first_tail_x6_r0_body.f1O98, PRE_first_tail_x6_r0_body.f1N98, PRE_first_tail_x6_r0_body.f1I98, PRE_first_tail_x6_r0_body.fbd98, PRE_first_tail_x6_r0_body.fincW98, PRE_first_tail_x6_r0_body.fincI98, PRE_first_tail_x6_r0_body.fincN98, PRE_first_tail_x6_r0_body.flnF98, PRE_first_tail_x6_r0_body.fh98, PRE_first_tail_x6_r0_body.fo98, PRE_first_tail_x6_r0_body.fok98, PRE_first_tail_x6_r0_body.fnd98, PRE_first_tail_x6_r0_body.fp98, PRE_first_tail_x6_r0_body.fnord98, PRE_first_tail_x6_r0_body.fi98, PRE_first_tail_x6_r0_body.fii98⟩
theorem PRE_first_tail_x6_r0_body.cnshift98 (clean : Conv.NClean (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P98.NL) (cl : SSt (· < 4243) PRE_first_tail_x6_r0_body.cx0_98.mlx) : NShift PRE_first_tail_x6_r0_body.P98 4243 PRE_first_tail_x6_r0_body.kappa98 PRE_first_tail_x6_r0_body.cx0_98 PRE_first_tail_x6_r0_body.cx1_98 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot98 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost98 (compact_a_eq PRE_first_tail_x6_r0_body.ckn098 PRE_first_tail_x6_r0_body.ckn198 PRE_first_tail_x6_r0_body.ckheap98 PRE_first_tail_x6_r0_body.ckpl98)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_98 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s948.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_98 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s948.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_98 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s948.ffi) = some PRE_first_tail_x6_r0_body.fxC_98
kernel_rfl PRE_first_tail_x6_r0_body.okrC_98 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s948.ffi) = some PRE_first_tail_x6_r0_body.krC_98
noncomputable def PRE_first_tail_x6_r0_body.fx0_98 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s950.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_98 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s950.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_98 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s950.ffi) = some PRE_first_tail_x6_r0_body.fx0_98
kernel_rfl PRE_first_tail_x6_r0_body.okr0_98 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s950.ffi) = some PRE_first_tail_x6_r0_body.kr0_98
noncomputable def PRE_first_tail_x6_r0_body.fx1_98 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s949.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_98 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s949.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_98 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s949.ffi) = some PRE_first_tail_x6_r0_body.fx1_98
kernel_rfl PRE_first_tail_x6_r0_body.okr1_98 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s949.ffi) = some PRE_first_tail_x6_r0_body.kr1_98
kernel_rfl PRE_first_tail_x6_r0_body.ff098 : PRE_first_tail_x6_r0_body.fx0_98 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_98 (PRE_first_tail_x6_r0_body.clo98.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_98.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff198 : PRE_first_tail_x6_r0_body.fx1_98 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_98 (PRE_first_tail_x6_r0_body.cwS98.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_98.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck98 : freedLB PRE_first_tail_x6_r0_body.kappa98 PRE_first_tail_x6_r0_body.cx0_98.mlx PRE_first_tail_x6_r0_body.fx0_98 PRE_first_tail_x6_r0_body.fx1_98 PRE_first_tail_x6_r0_body.clo98 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf098 : PRE_first_tail_x6_r0_body.kr0_98.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_98.flags (PRE_first_tail_x6_r0_body.clo98.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_98.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt098 : PRE_first_tail_x6_r0_body.kr0_98.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_98.targs (PRE_first_tail_x6_r0_body.clo98.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_98.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf198 : PRE_first_tail_x6_r0_body.kr1_98.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_98.flags (PRE_first_tail_x6_r0_body.cwS98.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_98.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt198 : PRE_first_tail_x6_r0_body.kr1_98.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_98.targs (PRE_first_tail_x6_r0_body.cwS98.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_98.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck98 : krecLB PRE_first_tail_x6_r0_body.kappa98 4243 PRE_first_tail_x6_r0_body.cx0_98.mlx PRE_first_tail_x6_r0_body.kr0_98 PRE_first_tail_x6_r0_body.kr1_98 PRE_first_tail_x6_r0_body.clo98 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn98 : Nat.ble 4243 4243 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge98 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s949.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s950.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR98 : pendRegB PRE_first_tail_x6_r0_body.kappa98 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s950.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe98 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s950.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s949.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift98 (clean : Conv.NClean (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P98.NL) (cl : SSt (· < 4243) PRE_first_tail_x6_r0_body.cx0_98.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_98.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_98.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_98.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s948.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_98.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P98 4243 PRE_first_tail_x6_r0_body.kappa98 PRE_first_tail_x6_r0_body.s950.ffi PRE_first_tail_x6_r0_body.s949.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift98 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue98, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp98 t ht),
    PRE_first_tail_x6_r0_body.cbridge98,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s950.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s949.ffi) (PRE_first_tail_x6_r0_body.cfoot98 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_98 PRE_first_tail_x6_r0_body.ofx1_98 hobjC PRE_first_tail_x6_r0_body.ff098 PRE_first_tail_x6_r0_body.ff198 PRE_first_tail_x6_r0_body.ffck98,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s950.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s949.ffi) (PRE_first_tail_x6_r0_body.cfoot98 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_98 PRE_first_tail_x6_r0_body.okr1_98 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn98) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf098 PRE_first_tail_x6_r0_body.fkt098 PRE_first_tail_x6_r0_body.fkf198 PRE_first_tail_x6_r0_body.fkt198 PRE_first_tail_x6_r0_body.fkck98,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh098 PRE_first_tail_x6_r0_body.cnh198 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe98) PRE_first_tail_x6_r0_body.cpendR98⟩

end Host.Load.Run.Tpl
end

section -- st98/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st98 0
host_stream_state PRE_first_tail_x6_r0_body.st98 1
host_stream_state PRE_first_tail_x6_r0_body.st98 2
end Host.Load.Run.Tpl
end

section -- Site98
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 98 of chain `PRE_first_tail_x6_r0_body`: `plan__g98__g99` (`plan`), the call state `PRE_first_tail_x6_r0_body.s948`, the merged state `PRE_first_tail_x6_r0_body.s949`,
the site template `PRE_first_tail_x6_r0_body.st98` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s950`: the merge.
The footprint's facts are in `SiteF98`, the compaction's in `SiteC98`, `SiteK98`, `SiteNa98`, `SiteNb98`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso98 : PRE_first_tail_x6_r0_body.st98.s0 = { PRE_first_tail_x6_r0_body.s948 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs98 : List Frame := PRE_first_tail_x6_r0_body.s948.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_98 : PRE_first_tail_x6_r0_body.S948.tab.length = 4243
kernel_rfl PRE_first_tail_x6_r0_body.tab0_98 : PRE_first_tail_x6_r0_body.st98.S0.tab = PRE_first_tail_x6_r0_body.S948.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws98 : List Nat := [2649, 2650, 2651, 2652, 2653, 2654, 2655, 2656, 2657]
kernel_rfl PRE_first_tail_x6_r0_body.fresh98 : (PRE_first_tail_x6_r0_body.S948.tab.all fun e => PRE_first_tail_x6_r0_body.ws98.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S948.oracle.all fun q => PRE_first_tail_x6_r0_body.ws98.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab98 : PRE_first_tail_x6_r0_body.S949.tab = PRE_first_tail_x6_r0_body.S948.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws98
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen98 : PRE_first_tail_x6_r0_body.st98.S2.tab.length - PRE_first_tail_x6_r0_body.st98.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged98`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap98 : PRE_first_tail_x6_r0_body.s949.heap = PRE_first_tail_x6_r0_body.st98.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext98 : PRE_first_tail_x6_r0_body.s949.next = PRE_first_tail_x6_r0_body.st98.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl98 : PRE_first_tail_x6_r0_body.s949.ctl = PRE_first_tail_x6_r0_body.st98.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack98 : PRE_first_tail_x6_r0_body.s949.stack = PRE_first_tail_x6_r0_body.st98.s2.stack ++ PRE_first_tail_x6_r0_body.s948.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs98 : PRE_first_tail_x6_r0_body.s949.jobs = PRE_first_tail_x6_r0_body.st98.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi98 : PRE_first_tail_x6_r0_body.s949.ffi = PRE_first_tail_x6_r0_body.st98.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace98 : PRE_first_tail_x6_r0_body.s949.trace = PRE_first_tail_x6_r0_body.st98.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores98 : PRE_first_tail_x6_r0_body.s949.stores = PRE_first_tail_x6_r0_body.st98.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD98
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 98 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived98 : PRE_first_tail_x6_r0_body.nr98.map (fun r => nth? PRE_first_tail_x6_r0_body.st98.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo98 : PRE_first_tail_x6_r0_body.nr98.all (Nat.ble 4243) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj98 : PRE_first_tail_x6_r0_body.cws98.all (fun c => !PRE_first_tail_x6_r0_body.ws98.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ98 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws98 PRE_first_tail_x6_r0_body.crs98 PRE_first_tail_x6_r0_body.ws98

end Host.Load.Run.Tpl
end

section -- st98/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st98`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st98.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st98.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st98.s2.heap PRE_first_tail_x6_r0_body.st98.wrR ++ freshOf PRE_first_tail_x6_r0_body.st98.s2.heap PRE_first_tail_x6_r0_body.st98.s0.next PRE_first_tail_x6_r0_body.st98.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st98.wr : List Nat := PRE_first_tail_x6_r0_body.st98.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st98.heapFoot : PRE_first_tail_x6_r0_body.st98.s2.heap = setAll PRE_first_tail_x6_r0_body.st98.s0.heap PRE_first_tail_x6_r0_body.st98.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st98.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st98.s0.next PRE_first_tail_x6_r0_body.st98.s2.next = true
theorem PRE_first_tail_x6_r0_body.st98.grows : PRE_first_tail_x6_r0_body.st98.s0.next ≤ PRE_first_tail_x6_r0_body.st98.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st98.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st98.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st98.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st98.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st98.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st98.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st98.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st98.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st98.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st98.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st98.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st98.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st98.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st98.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st98.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st98.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st98.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st98.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st98.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st98.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st98.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st98.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st98.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st98.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st98.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st98.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st98.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st98.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st98.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st98.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st98.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st98.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF98
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 98 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB98 : nodupT PRE_first_tail_x6_r0_body.st98.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup98 : PRE_first_tail_x6_r0_body.st98.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB98).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB98 : PRE_first_tail_x6_r0_body.st98.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound98 : ∀ b ∈ PRE_first_tail_x6_r0_body.st98.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB98 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr98 := PRE_first_tail_x6_r0_body.st98.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq98 : PRE_first_tail_x6_r0_body.st98.s2.trace = PRE_first_tail_x6_r0_body.trFr98 ++ PRE_first_tail_x6_r0_body.st98.s0.trace
theorem PRE_first_tail_x6_r0_body.trace98 : ∃ fr, PRE_first_tail_x6_r0_body.st98.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st98.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq98⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide98 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB98 : (PRE_first_tail_x6_r0_body.wide98.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st98.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix98 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide98, WFix Map.id (Present PRE_first_tail_x6_r0_body.st98.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB98 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL98
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 98 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s949`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO98 : PRE_first_tail_x6_r0_body.st98.S0.oracle = PRE_first_tail_x6_r0_body.st98.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B98 : PRE_first_tail_x6_r0_body.st98.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st98.s0.next || (PRE_first_tail_x6_r0_body.st98.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot98 : Conv.StageFoot PRE_first_tail_x6_r0_body.st98.wr PRE_first_tail_x6_r0_body.st98.s0 PRE_first_tail_x6_r0_body.st98.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st98.heapFoot PRE_first_tail_x6_r0_body.wrNodup98 PRE_first_tail_x6_r0_body.wrBound98 PRE_first_tail_x6_r0_body.wr0B98 PRE_first_tail_x6_r0_body.st98.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged98 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st98.F.S → PRE_first_tail_x6_r0_body.st98.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st98.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st98.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs98 PRE_first_tail_x6_r0_body.st98.wr PRE_first_tail_x6_r0_body.s948 PRE_first_tail_x6_r0_body.st98.s2 PRE_first_tail_x6_r0_body.st98.s0
      PRE_first_tail_x6_r0_body.st98.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st98.F FR W stk M ν K PRE_first_tail_x6_r0_body.s949 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso98 PRE_first_tail_x6_r0_body.stFoot98 PRE_first_tail_x6_r0_body.wrNodup98 PRE_first_tail_x6_r0_body.wrBound98 PRE_first_tail_x6_r0_body.trace98 PRE_first_tail_x6_r0_body.mheap98
    PRE_first_tail_x6_r0_body.mnext98 PRE_first_tail_x6_r0_body.mctl98 PRE_first_tail_x6_r0_body.mstack98 PRE_first_tail_x6_r0_body.mjobs98 PRE_first_tail_x6_r0_body.mffi98 PRE_first_tail_x6_r0_body.mtrace98 PRE_first_tail_x6_r0_body.mstores98 h

def PRE_first_tail_x6_r0_body.arrEl98_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE98_2665 : arrOf PRE_first_tail_x6_r0_body.s949 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl98_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA98_2665 : isArrB PRE_first_tail_x6_r0_body.s949 2665 = true
theorem PRE_first_tail_x6_r0_body.arr98_2665 : ∃ o, PRE_first_tail_x6_r0_body.s949.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl98_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE98_2665 PRE_first_tail_x6_r0_body.arrA98_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN98_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl98_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR98_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl98_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN98_2665

def PRE_first_tail_x6_r0_body.arrEl98_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE98_2673467 : arrOf PRE_first_tail_x6_r0_body.s949 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl98_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA98_2673467 : isArrB PRE_first_tail_x6_r0_body.s949 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr98_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s949.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl98_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE98_2673467 PRE_first_tail_x6_r0_body.arrA98_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN98_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl98_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR98_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl98_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN98_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k98 : isArrB PRE_first_tail_x6_r0_body.s949 4910 = false
theorem PRE_first_tail_x6_r0_body.keep98 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s949 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k98 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr98_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl98_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ98
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 98 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s948`, the merged
state `PRE_first_tail_x6_r0_body.s949`, the canonical state `PRE_first_tail_x6_r0_body.s950`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl98 : PRE_first_tail_x6_r0_body.pl98.all (Nat.ble PRE_first_tail_x6_r0_body.s948.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd98 : nodupT PRE_first_tail_x6_r0_body.pl98 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn198 : Nat.ble PRE_first_tail_x6_r0_body.s948.next 2751595 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst98 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s948.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn98 : PRE_first_tail_x6_r0_body.s950.next = PRE_first_tail_x6_r0_body.s948.next + PRE_first_tail_x6_r0_body.pl98.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn98 : PRE_first_tail_x6_r0_body.s949.next = 2751595
kernel_rfl PRE_first_tail_x6_r0_body.zgrow98 : Nat.ble PRE_first_tail_x6_r0_body.s950.next PRE_first_tail_x6_r0_body.s949.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh98 : PRE_first_tail_x6_r0_body.S948.tab.all (fun e => PRE_first_tail_x6_r0_body.cws98.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd98 : nodupT PRE_first_tail_x6_r0_body.cws98 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi98 : PRE_first_tail_x6_r0_body.nr98.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S949.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt98 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s948.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg98_2665 : PRE_first_tail_x6_r0_body.s950.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s950 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk98_2665 : (objOf PRE_first_tail_x6_r0_body.s950 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm98_2665 : PRE_first_tail_x6_r0_body.s949.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa98.obj (objOf PRE_first_tail_x6_r0_body.s950 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s949 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg98_2673467 : PRE_first_tail_x6_r0_body.s950.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s950 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk98_2673467 : (objOf PRE_first_tail_x6_r0_body.s950 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm98_2673467 : PRE_first_tail_x6_r0_body.s949.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa98.obj (objOf PRE_first_tail_x6_r0_body.s950 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s949 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw98_4910 : (PRE_first_tail_x6_r0_body.s950.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw98_2673472 : (PRE_first_tail_x6_r0_body.s950.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw98_2673473 : (PRE_first_tail_x6_r0_body.s950.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd98 : PRE_first_tail_x6_r0_body.cl98.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr98 : PRE_first_tail_x6_r0_body.st98.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s948.next || PRE_first_tail_x6_r0_body.cl98.contains b) = true
def PRE_first_tail_x6_r0_body.zl98 : List Nat := PRE_first_tail_x6_r0_body.cl98.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE98 : PRE_first_tail_x6_r0_body.zl98.map (fun a => PRE_first_tail_x6_r0_body.s949.heap.get (PRE_first_tail_x6_r0_body.kappa98.a a)) = PRE_first_tail_x6_r0_body.zl98.map (fun a => (PRE_first_tail_x6_r0_body.s950.heap.get a).map PRE_first_tail_x6_r0_body.kappa98.hobj)
theorem PRE_first_tail_x6_r0_body.zimg98 : HeapImg PRE_first_tail_x6_r0_body.kappa98 PRE_first_tail_x6_r0_body.s950 PRE_first_tail_x6_r0_body.s949 PRE_first_tail_x6_r0_body.zl98 := PRE_first_tail_x6_r0_body.zimgE98
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl98 : PRE_first_tail_x6_r0_body.s949.ctl = PRE_first_tail_x6_r0_body.kappa98.ctl PRE_first_tail_x6_r0_body.s950.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack98 : PRE_first_tail_x6_r0_body.s949.stack = PRE_first_tail_x6_r0_body.s950.stack.map PRE_first_tail_x6_r0_body.kappa98.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs98 : PRE_first_tail_x6_r0_body.s949.jobs = PRE_first_tail_x6_r0_body.s950.jobs.map PRE_first_tail_x6_r0_body.kappa98.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores98 : PRE_first_tail_x6_r0_body.s949.stores = PRE_first_tail_x6_r0_body.kappa98.stores PRE_first_tail_x6_r0_body.s950.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots98 : checkRootsSupp PRE_first_tail_x6_r0_body.s950 4243 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC98 : PRE_first_tail_x6_r0_body.S948.tab.length + PRE_first_tail_x6_r0_body.cws98.length = 4243
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap98 : PRE_first_tail_x6_r0_body.kappa98 = Conv.Map.compact PRE_first_tail_x6_r0_body.s948.next 2751595 PRE_first_tail_x6_r0_body.S948.tab.length PRE_first_tail_x6_r0_body.pl98 (PRE_first_tail_x6_r0_body.nr98.map NumV.ref) PRE_first_tail_x6_r0_body.kd98.big
  PRE_first_tail_x6_r0_body.kd98.region PRE_first_tail_x6_r0_body.kd98.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin98 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s950.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc98 : Conv.jcleanListB (⟨20127, 17218, 2751576, 4243⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s950 PRE_first_tail_x6_r0_body.cl98 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB98 : noBigRootsP (fun i => !Conv.oldBigB (⟨20127, 17218, 2751576, 4243⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s950.trace PRE_first_tail_x6_r0_body.s950 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm98 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 17218 = true
theorem PRE_first_tail_x6_r0_body.cjcl98 (h : Conv.JClean (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s948) : Conv.JClean (⟨20127, 17218, 2751576, 4243⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s950 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle98)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap98 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd98 a ha)) PRE_first_tail_x6_r0_body.zjc98

end Host.Load.Run.Tpl
end

section -- st98/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st98.bodyLast from PRE_first_tail_x6_r0_body.st98.s1 to PRE_first_tail_x6_r0_body.st98.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st98.F PRE_first_tail_x6_r0_body.st98.s1).run PRE_first_tail_x6_r0_body.st98.S1 = some (PRE_first_tail_x6_r0_body.st98.s2, PRE_first_tail_x6_r0_body.st98.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st98.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st98.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st98.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st98.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st98/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st98.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st98.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st98.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st98.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st98.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st98.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st98.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st98.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st98.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st98.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st98.s0 PRE_first_tail_x6_r0_body.st98.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st98.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st98.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st98.s1 PRE_first_tail_x6_r0_body.st98.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st98/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st98.bodyK0F from PRE_first_tail_x6_r0_body.st98.s0 to PRE_first_tail_x6_r0_body.st98.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st98.F (PRE_first_tail_x6_r0_body.st98.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st98.ks 0).getD 0) PRE_first_tail_x6_r0_body.st98.s0 PRE_first_tail_x6_r0_body.st98.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st98.s1, PRE_first_tail_x6_r0_body.st98.S1)
theorem PRE_first_tail_x6_r0_body.st98.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st98.F (PRE_first_tail_x6_r0_body.st98.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st98.ks 0).getD 0) PRE_first_tail_x6_r0_body.st98.s0 PRE_first_tail_x6_r0_body.st98.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st98.s1, PRE_first_tail_x6_r0_body.st98.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st98.bodyOkLN_ok PRE_first_tail_x6_r0_body.st98.bodyK0F
end Host.Load.Run.Tpl
end

section -- st98/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st98.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st98.F (PRE_first_tail_x6_r0_body.st98.bodyOkL bytes rows) 206 PRE_first_tail_x6_r0_body.st98.s0 PRE_first_tail_x6_r0_body.st98.S0 = some (PRE_first_tail_x6_r0_body.st98.s1, PRE_first_tail_x6_r0_body.st98.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st98.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st98.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st98.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st98.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st98.F (PRE_first_tail_x6_r0_body.st98.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st98.s0
  S0 := PRE_first_tail_x6_r0_body.st98.S0
  s1 := PRE_first_tail_x6_r0_body.st98.s1
  S1 := PRE_first_tail_x6_r0_body.st98.S1
  s2 := PRE_first_tail_x6_r0_body.st98.s2
  S2 := PRE_first_tail_x6_r0_body.st98.S2
  n := 206
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st98.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st98.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st98.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st98.bodyHalt
  last := PRE_first_tail_x6_r0_body.st98.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st98.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC99
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 99 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s967` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa99` into the merged state
`PRE_first_tail_x6_r0_body.s966`. -/

def PRE_first_tail_x6_r0_body.pl99 : List Nat := [2754163, 2753338, 2754169, 2754165, 2753340, 2754171]
def PRE_first_tail_x6_r0_body.nr99 : List Nat := [4346, 4345, 4321, 4329, 4334, 4339, 4344, 4318, 4319, 4320, 4327, 4328, 4316, 4323, 4324, 4325, 4326, 4322]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd99 : RData :=
  ⟨2753057, 2754206, Stage.setAll PTrie.nil [(2753051, 2754163), (2753052, 2753338), (2753053, 2754169), (2753054, 2754165), (2753055, 2753340), (2753056, 2754171)], Stage.setAll PTrie.nil [(20161, 20187), (20162, 20165), (20163, 20188)],
   20164, 20189, 17264, 17264, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(4316, .ref 4346), (4317, .ref 4345), (4318, .ref 4321), (4319, .ref 4329), (4320, .ref 4334), (4321, .ref 4339), (4322, .ref 4344), (4323, .ref 4318), (4324, .ref 4319), (4325, .ref 4320), (4326, .ref 4327), (4327, .ref 4328), (4328, .ref 4316), (4329, .ref 4323), (4330, .ref 4324), (4331, .ref 4325), (4332, .ref 4326), (4333, .ref 4322)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa99 : Map :=
  Conv.Map.compact 2753051 2754206 4316 PRE_first_tail_x6_r0_body.pl99 (PRE_first_tail_x6_r0_body.nr99.map NumV.ref) PRE_first_tail_x6_r0_body.kd99.big
    PRE_first_tail_x6_r0_body.kd99.region PRE_first_tail_x6_r0_body.kd99.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws99 : List Nat := [2689, 2690, 2691, 2692, 2693, 2694, 2695, 2696, 2697, 2698, 2699, 2700, 2701, 2702, 2703, 2704, 2705, 2706]
noncomputable def PRE_first_tail_x6_r0_body.crs99 : List SymE := PRE_first_tail_x6_r0_body.nr99.map fun r => (nth? PRE_first_tail_x6_r0_body.S966.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta99 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws99 PRE_first_tail_x6_r0_body.crs99
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB99 : List Nat := [2665, 2672553, 2673467, 2752225, 2752770, 2753026]

kernel_rfl PRE_first_tail_x6_r0_body.ctab99 : PRE_first_tail_x6_r0_body.S967.tab = PRE_first_tail_x6_r0_body.S965.tab ++ PRE_first_tail_x6_r0_body.cws99.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace99 : PRE_first_tail_x6_r0_body.s967.trace = PRE_first_tail_x6_r0_body.s965.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext99 : PRE_first_tail_x6_r0_body.s967.next = 2753057
kernel_rfl PRE_first_tail_x6_r0_body.ccounters99 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s967.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s967.ffi).mlx.nnext) = (20164, 17264)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue99 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s966.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s967.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa99.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp99 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s967.ffi).mlx.tokens.all (bSN 4334) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean99 : Conv.cleanListB 20164 131072 (fun r => Nat.ble 80656 r) PRE_first_tail_x6_r0_body.s967
    (PRE_first_tail_x6_r0_body.wrB99 ++ (List.range 6).map (2753051 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs99 : bigsOutB 20164 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s967.ffi).mlx = true

end Host.Load.Run.Tpl
end

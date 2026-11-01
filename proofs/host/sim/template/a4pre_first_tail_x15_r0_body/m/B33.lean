import host.sim.template.a4pre_first_tail_x15_r0_body.m.B32
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

section -- st186/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st186.bodyK1F from PRE_first_tail_x15_r0_body.st186.s1 to PRE_first_tail_x15_r0_body.st186.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st186.F (PRE_first_tail_x15_r0_body.st186.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st186.ks 1).getD 0) PRE_first_tail_x15_r0_body.st186.s1 PRE_first_tail_x15_r0_body.st186.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st186.s2, PRE_first_tail_x15_r0_body.st186.S2)
theorem PRE_first_tail_x15_r0_body.st186.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st186.F (PRE_first_tail_x15_r0_body.st186.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st186.ks 1).getD 0) PRE_first_tail_x15_r0_body.st186.s1 PRE_first_tail_x15_r0_body.st186.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st186.s2, PRE_first_tail_x15_r0_body.st186.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st186.bodyOkLN_ok PRE_first_tail_x15_r0_body.st186.bodyK1F
end Host.Load.Run.Tpl
end

section -- st186/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st186.bodyK2F from PRE_first_tail_x15_r0_body.st186.s2 to PRE_first_tail_x15_r0_body.st186.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st186.F (PRE_first_tail_x15_r0_body.st186.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st186.ks 2).getD 0) PRE_first_tail_x15_r0_body.st186.s2 PRE_first_tail_x15_r0_body.st186.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st186.s3, PRE_first_tail_x15_r0_body.st186.S3)
theorem PRE_first_tail_x15_r0_body.st186.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st186.F (PRE_first_tail_x15_r0_body.st186.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st186.ks 2).getD 0) PRE_first_tail_x15_r0_body.st186.s2 PRE_first_tail_x15_r0_body.st186.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st186.s3, PRE_first_tail_x15_r0_body.st186.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st186.bodyOkLN_ok PRE_first_tail_x15_r0_body.st186.bodyK2F
end Host.Load.Run.Tpl
end

section -- st186/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st186.bodyK3F from PRE_first_tail_x15_r0_body.st186.s3 to PRE_first_tail_x15_r0_body.st186.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st186.F (PRE_first_tail_x15_r0_body.st186.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st186.ks 3).getD 0) PRE_first_tail_x15_r0_body.st186.s3 PRE_first_tail_x15_r0_body.st186.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st186.s4, PRE_first_tail_x15_r0_body.st186.S4)
theorem PRE_first_tail_x15_r0_body.st186.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st186.F (PRE_first_tail_x15_r0_body.st186.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st186.ks 3).getD 0) PRE_first_tail_x15_r0_body.st186.s3 PRE_first_tail_x15_r0_body.st186.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st186.s4, PRE_first_tail_x15_r0_body.st186.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st186.bodyOkLN_ok PRE_first_tail_x15_r0_body.st186.bodyK3F
end Host.Load.Run.Tpl
end

section -- st186/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st186.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st186.F (PRE_first_tail_x15_r0_body.st186.bodyOkL bytes rows) 11334 PRE_first_tail_x15_r0_body.st186.s0 PRE_first_tail_x15_r0_body.st186.S0 = some (PRE_first_tail_x15_r0_body.st186.s4, PRE_first_tail_x15_r0_body.st186.S4) :=
  runOk_trans PRE_first_tail_x15_r0_body.st186.F (PRE_first_tail_x15_r0_body.st186.bodyOkL bytes rows) ((((nth? PRE_first_tail_x15_r0_body.st186.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st186.ks 1).getD 0)) + ((nth? PRE_first_tail_x15_r0_body.st186.ks 2).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st186.ks 3).getD 0) PRE_first_tail_x15_r0_body.st186.s0 PRE_first_tail_x15_r0_body.st186.s3 PRE_first_tail_x15_r0_body.st186.s4 PRE_first_tail_x15_r0_body.st186.S0 PRE_first_tail_x15_r0_body.st186.S3 PRE_first_tail_x15_r0_body.st186.S4 (runOk_trans PRE_first_tail_x15_r0_body.st186.F (PRE_first_tail_x15_r0_body.st186.bodyOkL bytes rows) (((nth? PRE_first_tail_x15_r0_body.st186.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st186.ks 1).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st186.ks 2).getD 0) PRE_first_tail_x15_r0_body.st186.s0 PRE_first_tail_x15_r0_body.st186.s2 PRE_first_tail_x15_r0_body.st186.s3 PRE_first_tail_x15_r0_body.st186.S0 PRE_first_tail_x15_r0_body.st186.S2 PRE_first_tail_x15_r0_body.st186.S3 (runOk_trans PRE_first_tail_x15_r0_body.st186.F (PRE_first_tail_x15_r0_body.st186.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st186.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st186.ks 1).getD 0) PRE_first_tail_x15_r0_body.st186.s0 PRE_first_tail_x15_r0_body.st186.s1 PRE_first_tail_x15_r0_body.st186.s2 PRE_first_tail_x15_r0_body.st186.S0 PRE_first_tail_x15_r0_body.st186.S1 PRE_first_tail_x15_r0_body.st186.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st186.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st186.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st186.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st186.bodyK3 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st186.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st186.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st186.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st186.F (PRE_first_tail_x15_r0_body.st186.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st186.s0
  S0 := PRE_first_tail_x15_r0_body.st186.S0
  s1 := PRE_first_tail_x15_r0_body.st186.s4
  S1 := PRE_first_tail_x15_r0_body.st186.S4
  s2 := PRE_first_tail_x15_r0_body.st186.s5
  S2 := PRE_first_tail_x15_r0_body.st186.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st186.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st186.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st186.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st186.bodyHalt
  last := PRE_first_tail_x15_r0_body.st186.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st186.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC187
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 187 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1809` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa187` into the merged state
`PRE_first_tail_x15_r0_body.s1808`. -/

def PRE_first_tail_x15_r0_body.pl187 : List Nat := []
def PRE_first_tail_x15_r0_body.nr187 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd187 : RData :=
  ⟨2821743, 2821745, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21886, 21886, 18999, 18999, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa187 : Map :=
  Conv.Map.compact 2821743 2821745 8075 PRE_first_tail_x15_r0_body.pl187 (PRE_first_tail_x15_r0_body.nr187.map NumV.ref) PRE_first_tail_x15_r0_body.kd187.big
    PRE_first_tail_x15_r0_body.kd187.region PRE_first_tail_x15_r0_body.kd187.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws187 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs187 : List SymE := PRE_first_tail_x15_r0_body.nr187.map fun r => (nth? PRE_first_tail_x15_r0_body.S1808.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta187 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws187 PRE_first_tail_x15_r0_body.crs187
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB187 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab187 : PRE_first_tail_x15_r0_body.S1809.tab = PRE_first_tail_x15_r0_body.S1807.tab ++ PRE_first_tail_x15_r0_body.cws187.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace187 : PRE_first_tail_x15_r0_body.s1809.trace = PRE_first_tail_x15_r0_body.s1807.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext187 : PRE_first_tail_x15_r0_body.s1809.next = 2821743
kernel_rfl PRE_first_tail_x15_r0_body.ccounters187 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx.nnext) = (21886, 18999)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue187 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1808.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa187.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp187 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx.tokens.all (bSN 8075) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean187 : Conv.cleanListB 21886 131072 (fun r => Nat.ble 87544 r) PRE_first_tail_x15_r0_body.s1809
    (PRE_first_tail_x15_r0_body.wrB187 ++ (List.range 0).map (2821743 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs187 : bigsOutB 21886 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK187
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl187`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl187 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo187 : List Nat := []
def PRE_first_tail_x15_r0_body.cln187 : List Nat := []
def PRE_first_tail_x15_r0_body.cli187 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap187 : PRE_first_tail_x15_r0_body.s1809.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1807.heap (PRE_first_tail_x15_r0_body.cl187.filterMap fun a => (PRE_first_tail_x15_r0_body.s1809.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe187 : Nat.ble PRE_first_tail_x15_r0_body.s1807.next PRE_first_tail_x15_r0_body.s1809.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP187 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1807 PRE_first_tail_x15_r0_body.s1809 PRE_first_tail_x15_r0_body.cl187 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp187 : Conv.suppListB PRE_first_tail_x15_r0_body.s1809 8075 PRE_first_tail_x15_r0_body.cl187 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound187 : Conv.boundListB PRE_first_tail_x15_r0_body.s1809 PRE_first_tail_x15_r0_body.cl187 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK187 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln187.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK187 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo187.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK187 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli187.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst187 : Conv.sstListB 8075 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx PRE_first_tail_x15_r0_body.cln187 PRE_first_tail_x15_r0_body.clo187 PRE_first_tail_x15_r0_body.cli187 = true

end Host.Load.Run.Tpl
end

section -- SiteCl187
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA187 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo187.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd187 : (PRE_first_tail_x15_r0_body.clo187 ++ PRE_first_tail_x15_r0_body.cln187 ++ PRE_first_tail_x15_r0_body.cli187).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle187 : Conv.Cnt.leB (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck187 : Conv.ncleanListB (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx PRE_first_tail_x15_r0_body.clo187 PRE_first_tail_x15_r0_body.cln187 PRE_first_tail_x15_r0_body.cli187 = true
theorem PRE_first_tail_x15_r0_body.cncl187 (h : Conv.NClean (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx) : Conv.NClean (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle187 PRE_first_tail_x15_r0_body.ckA187 PRE_first_tail_x15_r0_body.cobjsK187 PRE_first_tail_x15_r0_body.cnodesK187 PRE_first_tail_x15_r0_body.citemsK187 PRE_first_tail_x15_r0_body.cbd187 PRE_first_tail_x15_r0_body.cck187

end Host.Load.Run.Tpl
end

section -- SiteS187
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 187 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc187 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P187 : LoadP := PRE_first_tail_x15_r0_body.Pc187.raise 18999
kernel_rfl PRE_first_tail_x15_r0_body.craise187 : Nat.ble PRE_first_tail_x15_r0_body.Pc187.N0 18999 = true
theorem PRE_first_tail_x15_r0_body.raised187 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc187 PRE_first_tail_x15_r0_body.P187 :=
  .inr ⟨18999, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise187, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_187 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_187 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1808.ffi)
def PRE_first_tail_x15_r0_body.khinv187 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv187 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS187 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS187 : List Nat := List.range' 18999 0
def PRE_first_tail_x15_r0_body.ciS187 : List Nat := [] ++ List.range' 18999 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0187 : PRE_first_tail_x15_r0_body.kd187.nh0 = PRE_first_tail_x15_r0_body.cx0_187.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1187 : PRE_first_tail_x15_r0_body.kd187.nh1 = PRE_first_tail_x15_r0_body.cx1_187.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0187 : PRE_first_tail_x15_r0_body.kd187.nn0 = PRE_first_tail_x15_r0_body.cx0_187.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1187 : PRE_first_tail_x15_r0_body.kd187.nn1 = PRE_first_tail_x15_r0_body.cx1_187.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo187 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P187.lo && Nat.ble PRE_first_tail_x15_r0_body.P187.lo PRE_first_tail_x15_r0_body.cx0_187.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P187.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P187.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt187 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_187.mlx.next PRE_first_tail_x15_r0_body.cx1_187.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_187.mlx.nnext PRE_first_tail_x15_r0_body.cx1_187.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband187 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P187.NL && Nat.ble PRE_first_tail_x15_r0_body.P187.NL PRE_first_tail_x15_r0_body.P187.N0 && Nat.ble PRE_first_tail_x15_r0_body.P187.N0 PRE_first_tail_x15_r0_body.cx0_187.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow187 : PRE_first_tail_x15_r0_body.kd187.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren187 : checkRenG PRE_first_tail_x15_r0_body.kd187.hnd PRE_first_tail_x15_r0_body.khinv187 (phB PRE_first_tail_x15_r0_body.cx0_187.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband187 : PRE_first_tail_x15_r0_body.kd187.checkBand PRE_first_tail_x15_r0_body.P187.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos187 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd187.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren187 : checkRenG PRE_first_tail_x15_r0_body.kd187.node PRE_first_tail_x15_r0_body.kninv187 (pnB PRE_first_tail_x15_r0_body.cx0_187.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow187 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd187.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P187.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd187.nodeF j) PRE_first_tail_x15_r0_body.cx1_187.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a187 : PRE_first_tail_x15_r0_body.cx0_187.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b187 : PRE_first_tail_x15_r0_body.cx0_187.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1187 : PRE_first_tail_x15_r0_body.cx1_187.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend187 : PRE_first_tail_x15_r0_body.cx1_187.mlx.pending = PRE_first_tail_x15_r0_body.cx0_187.mlx.pending.map PRE_first_tail_x15_r0_body.kappa187.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh187 : PRE_first_tail_x15_r0_body.cx1_187.mlx.errh = PRE_first_tail_x15_r0_body.cx0_187.mlx.errh.map PRE_first_tail_x15_r0_body.kappa187.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles187 : PRE_first_tail_x15_r0_body.cx1_187.mlx.files = PRE_first_tail_x15_r0_body.cx0_187.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch187 : PRE_first_tail_x15_r0_body.cx1_187.mlx.arch = PRE_first_tail_x15_r0_body.cx0_187.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes187 : PRE_first_tail_x15_r0_body.cx1_187.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_187.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired187 : PRE_first_tail_x15_r0_body.cx1_187.mlx.wired = PRE_first_tail_x15_r0_body.cx0_187.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost187 : PRE_first_tail_x15_r0_body.cx1_187.host = PRE_first_tail_x15_r0_body.cx0_187.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd187`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0187 : PRE_first_tail_x15_r0_body.kd187.n0 = 2821743
kernel_rfl PRE_first_tail_x15_r0_body.ckn1187 : PRE_first_tail_x15_r0_body.kd187.n1 = 2821745
kernel_rfl PRE_first_tail_x15_r0_body.ckheap187 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd187.heap).all (fun x => Nat.ble 2821743 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl187 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd187.heap.get (2821743 + j) = nth? PRE_first_tail_x15_r0_body.pl187 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja187 : Nat.ble 2821743 2821743 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn187 : Nat.ble 8075 8075 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD187 : Nat.ble 2821743 PRE_first_tail_x15_r0_body.kd187.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn187 : Nat.ble 21886 PRE_first_tail_x15_r0_body.kd187.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn187 : Nat.ble 18999 PRE_first_tail_x15_r0_body.kd187.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb187 : Nat.ble 21886 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap187 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd187.heap).all (Nat.ble (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd187 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd187.hnd).all (Nat.ble (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode187 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd187.node).all (Nat.ble (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix187 : Conv.FixOld (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa187 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja187) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn187) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD187) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn187) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn187) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb187) PRE_first_tail_x15_r0_body.fheap187 PRE_first_tail_x15_r0_body.fhnd187 PRE_first_tail_x15_r0_body.fnode187
kernel_rfl PRE_first_tail_x15_r0_body.fcxn187 : (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn187 : (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0187 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_187.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_187.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk187 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd187.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A187 : PRE_first_tail_x15_r0_body.cx1_187.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS187.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_187.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O187 : PRE_first_tail_x15_r0_body.cx1_187.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS187.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_187.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N187 : PRE_first_tail_x15_r0_body.cx1_187.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS187.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_187.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I187 : PRE_first_tail_x15_r0_body.cx1_187.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS187.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_187.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd187 : (PRE_first_tail_x15_r0_body.clo187 ++ PRE_first_tail_x15_r0_body.cln187 ++ PRE_first_tail_x15_r0_body.cli187 ++ PRE_first_tail_x15_r0_body.cwS187 ++ PRE_first_tail_x15_r0_body.cnS187 ++ PRE_first_tail_x15_r0_body.ciS187).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW187 : PRE_first_tail_x15_r0_body.cwS187.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo187.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI187 : PRE_first_tail_x15_r0_body.ciS187.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli187.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN187 : PRE_first_tail_x15_r0_body.cnS187.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF187 : PRE_first_tail_x15_r0_body.cln187.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh187 : PRE_first_tail_x15_r0_body.clo187.all (handleOK PRE_first_tail_x15_r0_body.kappa187 PRE_first_tail_x15_r0_body.P187.lo PRE_first_tail_x15_r0_body.cx0_187.mlx PRE_first_tail_x15_r0_body.cx1_187.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo187 : PRE_first_tail_x15_r0_body.clo187.map (fun h => PRE_first_tail_x15_r0_body.cx1_187.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa187.handle h)) = PRE_first_tail_x15_r0_body.clo187.map (fun h => (PRE_first_tail_x15_r0_body.cx0_187.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa187.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok187 : PRE_first_tail_x15_r0_body.clo187.all (objOK PRE_first_tail_x15_r0_body.kappa187 PRE_first_tail_x15_r0_body.P187.NL PRE_first_tail_x15_r0_body.cx0_187.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd187 : PRE_first_tail_x15_r0_body.cln187.all (nodeOKF PRE_first_tail_x15_r0_body.kappa187 PRE_first_tail_x15_r0_body.P187 PRE_first_tail_x15_r0_body.cx0_187.mlx PRE_first_tail_x15_r0_body.cx1_187.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp187 : ((PRE_first_tail_x15_r0_body.cln187.filter (fullB PRE_first_tail_x15_r0_body.P187))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_187.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa187.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln187.filter (fullB PRE_first_tail_x15_r0_body.P187))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_187.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa187.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI187 : incrB PRE_first_tail_x15_r0_body.kd187.nodeF (List.range' 18999 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK187 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd187.node).all (fun k => Nat.ble 18999 k && Nat.blt k 18999) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL187 : (PRE_first_tail_x15_r0_body.cln187.filter (Nat.ble PRE_first_tail_x15_r0_body.P187.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd187.nodeF i) && (Nat.blt i 18999 || Nat.ble PRE_first_tail_x15_r0_body.kd187.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord187 : (PRE_first_tail_x15_r0_body.cln187.filter (Nat.ble PRE_first_tail_x15_r0_body.P187.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd187.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd187.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd187.nodeF j) (PRE_first_tail_x15_r0_body.kd187.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow187 PRE_first_tail_x15_r0_body.cnn1187 PRE_first_tail_x15_r0_body.fnordI187 PRE_first_tail_x15_r0_body.fnordK187 PRE_first_tail_x15_r0_body.fnordL187
kernel_rfl PRE_first_tail_x15_r0_body.fi187 : PRE_first_tail_x15_r0_body.cli187.all (pnB PRE_first_tail_x15_r0_body.cx0_187.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii187 : PRE_first_tail_x15_r0_body.cli187.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_187.mlx.items.get (PRE_first_tail_x15_r0_body.kappa187.node k) = (PRE_first_tail_x15_r0_body.cx0_187.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa187.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot187 (clean : Conv.NClean (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P187.NL) (cl : SSt (· < 8075) PRE_first_tail_x15_r0_body.cx0_187.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P187 8075 PRE_first_tail_x15_r0_body.kappa187 PRE_first_tail_x15_r0_body.kd187 PRE_first_tail_x15_r0_body.khinv187 PRE_first_tail_x15_r0_body.kninv187 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx PRE_first_tail_x15_r0_body.cx0_187.mlx PRE_first_tail_x15_r0_body.cx1_187.mlx (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo187 PRE_first_tail_x15_r0_body.cln187 PRE_first_tail_x15_r0_body.cli187 PRE_first_tail_x15_r0_body.cwS187 PRE_first_tail_x15_r0_body.cnS187 PRE_first_tail_x15_r0_body.ciS187 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0187, PRE_first_tail_x15_r0_body.cnh1187, PRE_first_tail_x15_r0_body.cnn0187, PRE_first_tail_x15_r0_body.cnn1187, PRE_first_tail_x15_r0_body.cplo187, PRE_first_tail_x15_r0_body.ccnt187, PRE_first_tail_x15_r0_body.cnband187, PRE_first_tail_x15_r0_body.chbelow187, PRE_first_tail_x15_r0_body.chren187, PRE_first_tail_x15_r0_body.cband187, PRE_first_tail_x15_r0_body.cnh1pos187, PRE_first_tail_x15_r0_body.cnren187, PRE_first_tail_x15_r0_body.cnlow187, PRE_first_tail_x15_r0_body.cabs0a187, PRE_first_tail_x15_r0_body.cabs0b187, PRE_first_tail_x15_r0_body.ctok1187, PRE_first_tail_x15_r0_body.cpend187, PRE_first_tail_x15_r0_body.cerrh187, PRE_first_tail_x15_r0_body.cfiles187, PRE_first_tail_x15_r0_body.carch187, PRE_first_tail_x15_r0_body.csizes187, PRE_first_tail_x15_r0_body.cwired187, PRE_first_tail_x15_r0_body.cfix187, clean, PRE_first_tail_x15_r0_body.fcxn187, PRE_first_tail_x15_r0_body.fcnn187, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0187, PRE_first_tail_x15_r0_body.fnk187, PRE_first_tail_x15_r0_body.ckA187, PRE_first_tail_x15_r0_body.cobjsK187, PRE_first_tail_x15_r0_body.cnodesK187, PRE_first_tail_x15_r0_body.citemsK187, PRE_first_tail_x15_r0_body.f1A187, PRE_first_tail_x15_r0_body.f1O187, PRE_first_tail_x15_r0_body.f1N187, PRE_first_tail_x15_r0_body.f1I187, PRE_first_tail_x15_r0_body.fbd187, PRE_first_tail_x15_r0_body.fincW187, PRE_first_tail_x15_r0_body.fincI187, PRE_first_tail_x15_r0_body.fincN187, PRE_first_tail_x15_r0_body.flnF187, PRE_first_tail_x15_r0_body.fh187, PRE_first_tail_x15_r0_body.fo187, PRE_first_tail_x15_r0_body.fok187, PRE_first_tail_x15_r0_body.fnd187, PRE_first_tail_x15_r0_body.fp187, PRE_first_tail_x15_r0_body.fnord187, PRE_first_tail_x15_r0_body.fi187, PRE_first_tail_x15_r0_body.fii187⟩
theorem PRE_first_tail_x15_r0_body.cnshift187 (clean : Conv.NClean (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P187.NL) (cl : SSt (· < 8075) PRE_first_tail_x15_r0_body.cx0_187.mlx) : NShift PRE_first_tail_x15_r0_body.P187 8075 PRE_first_tail_x15_r0_body.kappa187 PRE_first_tail_x15_r0_body.cx0_187 PRE_first_tail_x15_r0_body.cx1_187 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot187 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost187 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0187 PRE_first_tail_x15_r0_body.ckn1187 PRE_first_tail_x15_r0_body.ckheap187 PRE_first_tail_x15_r0_body.ckpl187)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_187 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1807.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_187 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1807.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_187 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1807.ffi) = some PRE_first_tail_x15_r0_body.fxC_187
kernel_rfl PRE_first_tail_x15_r0_body.okrC_187 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1807.ffi) = some PRE_first_tail_x15_r0_body.krC_187
noncomputable def PRE_first_tail_x15_r0_body.fx0_187 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1809.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_187 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1809.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_187 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1809.ffi) = some PRE_first_tail_x15_r0_body.fx0_187
kernel_rfl PRE_first_tail_x15_r0_body.okr0_187 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1809.ffi) = some PRE_first_tail_x15_r0_body.kr0_187
noncomputable def PRE_first_tail_x15_r0_body.fx1_187 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1808.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_187 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1808.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_187 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1808.ffi) = some PRE_first_tail_x15_r0_body.fx1_187
kernel_rfl PRE_first_tail_x15_r0_body.okr1_187 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1808.ffi) = some PRE_first_tail_x15_r0_body.kr1_187
kernel_rfl PRE_first_tail_x15_r0_body.ff0187 : PRE_first_tail_x15_r0_body.fx0_187 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_187 (PRE_first_tail_x15_r0_body.clo187.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_187.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1187 : PRE_first_tail_x15_r0_body.fx1_187 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_187 (PRE_first_tail_x15_r0_body.cwS187.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_187.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck187 : freedLB PRE_first_tail_x15_r0_body.kappa187 PRE_first_tail_x15_r0_body.cx0_187.mlx PRE_first_tail_x15_r0_body.fx0_187 PRE_first_tail_x15_r0_body.fx1_187 PRE_first_tail_x15_r0_body.clo187 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0187 : PRE_first_tail_x15_r0_body.kr0_187.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_187.flags (PRE_first_tail_x15_r0_body.clo187.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_187.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0187 : PRE_first_tail_x15_r0_body.kr0_187.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_187.targs (PRE_first_tail_x15_r0_body.clo187.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_187.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1187 : PRE_first_tail_x15_r0_body.kr1_187.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_187.flags (PRE_first_tail_x15_r0_body.cwS187.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_187.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1187 : PRE_first_tail_x15_r0_body.kr1_187.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_187.targs (PRE_first_tail_x15_r0_body.cwS187.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_187.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck187 : krecLB PRE_first_tail_x15_r0_body.kappa187 8075 PRE_first_tail_x15_r0_body.cx0_187.mlx PRE_first_tail_x15_r0_body.kr0_187 PRE_first_tail_x15_r0_body.kr1_187 PRE_first_tail_x15_r0_body.clo187 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn187 : Nat.ble 8075 8075 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge187 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1808.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1809.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR187 : pendRegB PRE_first_tail_x15_r0_body.kappa187 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe187 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1808.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift187 (clean : Conv.NClean (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P187.NL) (cl : SSt (· < 8075) PRE_first_tail_x15_r0_body.cx0_187.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_187.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_187.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_187.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_187.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P187 8075 PRE_first_tail_x15_r0_body.kappa187 PRE_first_tail_x15_r0_body.s1809.ffi PRE_first_tail_x15_r0_body.s1808.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift187 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue187, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp187 t ht),
    PRE_first_tail_x15_r0_body.cbridge187,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1809.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1808.ffi) (PRE_first_tail_x15_r0_body.cfoot187 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_187 PRE_first_tail_x15_r0_body.ofx1_187 hobjC PRE_first_tail_x15_r0_body.ff0187 PRE_first_tail_x15_r0_body.ff1187 PRE_first_tail_x15_r0_body.ffck187,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1809.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1808.ffi) (PRE_first_tail_x15_r0_body.cfoot187 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_187 PRE_first_tail_x15_r0_body.okr1_187 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn187) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0187 PRE_first_tail_x15_r0_body.fkt0187 PRE_first_tail_x15_r0_body.fkf1187 PRE_first_tail_x15_r0_body.fkt1187 PRE_first_tail_x15_r0_body.fkck187,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0187 PRE_first_tail_x15_r0_body.cnh1187 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe187) PRE_first_tail_x15_r0_body.cpendR187⟩

end Host.Load.Run.Tpl
end

section -- st187/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st187 0
host_stream_state PRE_first_tail_x15_r0_body.st187 1
host_stream_state PRE_first_tail_x15_r0_body.st187 2
end Host.Load.Run.Tpl
end

section -- Site187
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 187 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g187__g188` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1807`, the merged state `PRE_first_tail_x15_r0_body.s1808`,
the site template `PRE_first_tail_x15_r0_body.st187` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1809`: the merge.
The footprint's facts are in `SiteF187`, the compaction's in `SiteC187`, `SiteK187`, `SiteNa187`, `SiteNb187`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso187 : PRE_first_tail_x15_r0_body.st187.s0 = { PRE_first_tail_x15_r0_body.s1807 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs187 : List Frame := PRE_first_tail_x15_r0_body.s1807.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_187 : PRE_first_tail_x15_r0_body.S1807.tab.length = 8075
kernel_rfl PRE_first_tail_x15_r0_body.tab0_187 : PRE_first_tail_x15_r0_body.st187.S0.tab = PRE_first_tail_x15_r0_body.S1807.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws187 : List Nat := [4196, 4197]
kernel_rfl PRE_first_tail_x15_r0_body.fresh187 : (PRE_first_tail_x15_r0_body.S1807.tab.all fun e => PRE_first_tail_x15_r0_body.ws187.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1807.oracle.all fun q => PRE_first_tail_x15_r0_body.ws187.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab187 : PRE_first_tail_x15_r0_body.S1808.tab = PRE_first_tail_x15_r0_body.S1807.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws187
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen187 : PRE_first_tail_x15_r0_body.st187.S2.tab.length - PRE_first_tail_x15_r0_body.st187.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged187`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap187 : PRE_first_tail_x15_r0_body.s1808.heap = PRE_first_tail_x15_r0_body.st187.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext187 : PRE_first_tail_x15_r0_body.s1808.next = PRE_first_tail_x15_r0_body.st187.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl187 : PRE_first_tail_x15_r0_body.s1808.ctl = PRE_first_tail_x15_r0_body.st187.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack187 : PRE_first_tail_x15_r0_body.s1808.stack = PRE_first_tail_x15_r0_body.st187.s2.stack ++ PRE_first_tail_x15_r0_body.s1807.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs187 : PRE_first_tail_x15_r0_body.s1808.jobs = PRE_first_tail_x15_r0_body.st187.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi187 : PRE_first_tail_x15_r0_body.s1808.ffi = PRE_first_tail_x15_r0_body.st187.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace187 : PRE_first_tail_x15_r0_body.s1808.trace = PRE_first_tail_x15_r0_body.st187.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores187 : PRE_first_tail_x15_r0_body.s1808.stores = PRE_first_tail_x15_r0_body.st187.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD187
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 187 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived187 : PRE_first_tail_x15_r0_body.nr187.map (fun r => nth? PRE_first_tail_x15_r0_body.st187.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo187 : PRE_first_tail_x15_r0_body.nr187.all (Nat.ble 8075) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj187 : PRE_first_tail_x15_r0_body.cws187.all (fun c => !PRE_first_tail_x15_r0_body.ws187.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ187 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws187 PRE_first_tail_x15_r0_body.crs187 PRE_first_tail_x15_r0_body.ws187

end Host.Load.Run.Tpl
end

section -- st187/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st187`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st187.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st187.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st187.s2.heap PRE_first_tail_x15_r0_body.st187.wrR ++ freshOf PRE_first_tail_x15_r0_body.st187.s2.heap PRE_first_tail_x15_r0_body.st187.s0.next PRE_first_tail_x15_r0_body.st187.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st187.wr : List Nat := PRE_first_tail_x15_r0_body.st187.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st187.heapFoot : PRE_first_tail_x15_r0_body.st187.s2.heap = setAll PRE_first_tail_x15_r0_body.st187.s0.heap PRE_first_tail_x15_r0_body.st187.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st187.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st187.s0.next PRE_first_tail_x15_r0_body.st187.s2.next = true
theorem PRE_first_tail_x15_r0_body.st187.grows : PRE_first_tail_x15_r0_body.st187.s0.next ≤ PRE_first_tail_x15_r0_body.st187.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st187.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st187.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st187.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st187.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st187.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st187.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st187.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st187.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st187.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st187.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st187.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st187.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st187.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st187.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st187.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st187.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st187.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st187.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st187.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st187.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st187.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st187.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st187.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st187.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st187.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st187.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st187.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st187.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st187.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st187.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st187.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st187.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF187
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 187 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB187 : nodupT PRE_first_tail_x15_r0_body.st187.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup187 : PRE_first_tail_x15_r0_body.st187.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB187).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB187 : PRE_first_tail_x15_r0_body.st187.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound187 : ∀ b ∈ PRE_first_tail_x15_r0_body.st187.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB187 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr187 := PRE_first_tail_x15_r0_body.st187.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq187 : PRE_first_tail_x15_r0_body.st187.s2.trace = PRE_first_tail_x15_r0_body.trFr187 ++ PRE_first_tail_x15_r0_body.st187.s0.trace
theorem PRE_first_tail_x15_r0_body.trace187 : ∃ fr, PRE_first_tail_x15_r0_body.st187.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st187.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq187⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide187 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB187 : (PRE_first_tail_x15_r0_body.wide187.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st187.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix187 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide187, WFix Map.id (Present PRE_first_tail_x15_r0_body.st187.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB187 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL187
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 187 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1808`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO187 : PRE_first_tail_x15_r0_body.st187.S0.oracle = PRE_first_tail_x15_r0_body.st187.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B187 : PRE_first_tail_x15_r0_body.st187.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st187.s0.next || (PRE_first_tail_x15_r0_body.st187.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot187 : Conv.StageFoot PRE_first_tail_x15_r0_body.st187.wr PRE_first_tail_x15_r0_body.st187.s0 PRE_first_tail_x15_r0_body.st187.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st187.heapFoot PRE_first_tail_x15_r0_body.wrNodup187 PRE_first_tail_x15_r0_body.wrBound187 PRE_first_tail_x15_r0_body.wr0B187 PRE_first_tail_x15_r0_body.st187.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged187 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st187.F.S → PRE_first_tail_x15_r0_body.st187.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st187.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st187.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs187 PRE_first_tail_x15_r0_body.st187.wr PRE_first_tail_x15_r0_body.s1807 PRE_first_tail_x15_r0_body.st187.s2 PRE_first_tail_x15_r0_body.st187.s0
      PRE_first_tail_x15_r0_body.st187.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st187.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1808 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso187 PRE_first_tail_x15_r0_body.stFoot187 PRE_first_tail_x15_r0_body.wrNodup187 PRE_first_tail_x15_r0_body.wrBound187 PRE_first_tail_x15_r0_body.trace187 PRE_first_tail_x15_r0_body.mheap187
    PRE_first_tail_x15_r0_body.mnext187 PRE_first_tail_x15_r0_body.mctl187 PRE_first_tail_x15_r0_body.mstack187 PRE_first_tail_x15_r0_body.mjobs187 PRE_first_tail_x15_r0_body.mffi187 PRE_first_tail_x15_r0_body.mtrace187 PRE_first_tail_x15_r0_body.mstores187 h

def PRE_first_tail_x15_r0_body.arrEl187_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE187_2665 : arrOf PRE_first_tail_x15_r0_body.s1808 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl187_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA187_2665 : isArrB PRE_first_tail_x15_r0_body.s1808 2665 = true
theorem PRE_first_tail_x15_r0_body.arr187_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1808.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl187_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE187_2665 PRE_first_tail_x15_r0_body.arrA187_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN187_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl187_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR187_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl187_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN187_2665

def PRE_first_tail_x15_r0_body.arrEl187_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE187_2673467 : arrOf PRE_first_tail_x15_r0_body.s1808 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl187_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA187_2673467 : isArrB PRE_first_tail_x15_r0_body.s1808 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr187_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1808.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl187_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE187_2673467 PRE_first_tail_x15_r0_body.arrA187_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN187_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl187_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR187_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl187_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN187_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k187 : isArrB PRE_first_tail_x15_r0_body.s1808 4910 = false
theorem PRE_first_tail_x15_r0_body.keep187 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1808 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k187 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr187_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl187_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ187
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 187 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1807`, the merged
state `PRE_first_tail_x15_r0_body.s1808`, the canonical state `PRE_first_tail_x15_r0_body.s1809`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl187 : PRE_first_tail_x15_r0_body.pl187.all (Nat.ble PRE_first_tail_x15_r0_body.s1807.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd187 : nodupT PRE_first_tail_x15_r0_body.pl187 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1187 : Nat.ble PRE_first_tail_x15_r0_body.s1807.next 2821745 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst187 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1807.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn187 : PRE_first_tail_x15_r0_body.s1809.next = PRE_first_tail_x15_r0_body.s1807.next + PRE_first_tail_x15_r0_body.pl187.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn187 : PRE_first_tail_x15_r0_body.s1808.next = 2821745
kernel_rfl PRE_first_tail_x15_r0_body.zgrow187 : Nat.ble PRE_first_tail_x15_r0_body.s1809.next PRE_first_tail_x15_r0_body.s1808.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh187 : PRE_first_tail_x15_r0_body.S1807.tab.all (fun e => PRE_first_tail_x15_r0_body.cws187.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd187 : nodupT PRE_first_tail_x15_r0_body.cws187 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi187 : PRE_first_tail_x15_r0_body.nr187.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1808.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt187 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1807.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg187_2665 : PRE_first_tail_x15_r0_body.s1809.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1809 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk187_2665 : (objOf PRE_first_tail_x15_r0_body.s1809 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm187_2665 : PRE_first_tail_x15_r0_body.s1808.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa187.obj (objOf PRE_first_tail_x15_r0_body.s1809 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1808 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg187_2673467 : PRE_first_tail_x15_r0_body.s1809.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1809 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk187_2673467 : (objOf PRE_first_tail_x15_r0_body.s1809 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm187_2673467 : PRE_first_tail_x15_r0_body.s1808.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa187.obj (objOf PRE_first_tail_x15_r0_body.s1809 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1808 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw187_4910 : (PRE_first_tail_x15_r0_body.s1809.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw187_2673472 : (PRE_first_tail_x15_r0_body.s1809.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw187_2673473 : (PRE_first_tail_x15_r0_body.s1809.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd187 : PRE_first_tail_x15_r0_body.cl187.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr187 : PRE_first_tail_x15_r0_body.st187.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1807.next || PRE_first_tail_x15_r0_body.cl187.contains b) = true
def PRE_first_tail_x15_r0_body.zl187 : List Nat := PRE_first_tail_x15_r0_body.cl187.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE187 : PRE_first_tail_x15_r0_body.zl187.map (fun a => PRE_first_tail_x15_r0_body.s1808.heap.get (PRE_first_tail_x15_r0_body.kappa187.a a)) = PRE_first_tail_x15_r0_body.zl187.map (fun a => (PRE_first_tail_x15_r0_body.s1809.heap.get a).map PRE_first_tail_x15_r0_body.kappa187.hobj)
theorem PRE_first_tail_x15_r0_body.zimg187 : HeapImg PRE_first_tail_x15_r0_body.kappa187 PRE_first_tail_x15_r0_body.s1809 PRE_first_tail_x15_r0_body.s1808 PRE_first_tail_x15_r0_body.zl187 := PRE_first_tail_x15_r0_body.zimgE187
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl187 : PRE_first_tail_x15_r0_body.s1808.ctl = PRE_first_tail_x15_r0_body.kappa187.ctl PRE_first_tail_x15_r0_body.s1809.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack187 : PRE_first_tail_x15_r0_body.s1808.stack = PRE_first_tail_x15_r0_body.s1809.stack.map PRE_first_tail_x15_r0_body.kappa187.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs187 : PRE_first_tail_x15_r0_body.s1808.jobs = PRE_first_tail_x15_r0_body.s1809.jobs.map PRE_first_tail_x15_r0_body.kappa187.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores187 : PRE_first_tail_x15_r0_body.s1808.stores = PRE_first_tail_x15_r0_body.kappa187.stores PRE_first_tail_x15_r0_body.s1809.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots187 : checkRootsSupp PRE_first_tail_x15_r0_body.s1809 8075 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC187 : PRE_first_tail_x15_r0_body.S1807.tab.length + PRE_first_tail_x15_r0_body.cws187.length = 8075
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap187 : PRE_first_tail_x15_r0_body.kappa187 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1807.next 2821745 PRE_first_tail_x15_r0_body.S1807.tab.length PRE_first_tail_x15_r0_body.pl187 (PRE_first_tail_x15_r0_body.nr187.map NumV.ref) PRE_first_tail_x15_r0_body.kd187.big
  PRE_first_tail_x15_r0_body.kd187.region PRE_first_tail_x15_r0_body.kd187.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin187 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1809.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc187 : Conv.jcleanListB (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1809 PRE_first_tail_x15_r0_body.cl187 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB187 : noBigRootsP (fun i => !Conv.oldBigB (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1809.trace PRE_first_tail_x15_r0_body.s1809 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm187 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18999 = true
theorem PRE_first_tail_x15_r0_body.cjcl187 (h : Conv.JClean (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1807) : Conv.JClean (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1809 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle187)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap187 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd187 a ha)) PRE_first_tail_x15_r0_body.zjc187

end Host.Load.Run.Tpl
end

section -- st187/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st187.bodyLast from PRE_first_tail_x15_r0_body.st187.s1 to PRE_first_tail_x15_r0_body.st187.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st187.F PRE_first_tail_x15_r0_body.st187.s1).run PRE_first_tail_x15_r0_body.st187.S1 = some (PRE_first_tail_x15_r0_body.st187.s2, PRE_first_tail_x15_r0_body.st187.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st187.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st187.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st187.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st187.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st187/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st187.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st187.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st187.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st187.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st187.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st187.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st187.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st187.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st187.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st187.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st187.s0 PRE_first_tail_x15_r0_body.st187.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st187.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st187.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st187.s1 PRE_first_tail_x15_r0_body.st187.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st187/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st187.bodyK0F from PRE_first_tail_x15_r0_body.st187.s0 to PRE_first_tail_x15_r0_body.st187.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st187.F (PRE_first_tail_x15_r0_body.st187.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st187.ks 0).getD 0) PRE_first_tail_x15_r0_body.st187.s0 PRE_first_tail_x15_r0_body.st187.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st187.s1, PRE_first_tail_x15_r0_body.st187.S1)
theorem PRE_first_tail_x15_r0_body.st187.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st187.F (PRE_first_tail_x15_r0_body.st187.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st187.ks 0).getD 0) PRE_first_tail_x15_r0_body.st187.s0 PRE_first_tail_x15_r0_body.st187.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st187.s1, PRE_first_tail_x15_r0_body.st187.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st187.bodyOkLN_ok PRE_first_tail_x15_r0_body.st187.bodyK0F
end Host.Load.Run.Tpl
end

section -- st187/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st187.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st187.F (PRE_first_tail_x15_r0_body.st187.bodyOkL bytes rows) 27 PRE_first_tail_x15_r0_body.st187.s0 PRE_first_tail_x15_r0_body.st187.S0 = some (PRE_first_tail_x15_r0_body.st187.s1, PRE_first_tail_x15_r0_body.st187.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st187.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st187.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st187.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st187.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st187.F (PRE_first_tail_x15_r0_body.st187.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st187.s0
  S0 := PRE_first_tail_x15_r0_body.st187.S0
  s1 := PRE_first_tail_x15_r0_body.st187.s1
  S1 := PRE_first_tail_x15_r0_body.st187.S1
  s2 := PRE_first_tail_x15_r0_body.st187.s2
  S2 := PRE_first_tail_x15_r0_body.st187.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st187.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st187.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st187.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st187.bodyHalt
  last := PRE_first_tail_x15_r0_body.st187.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st187.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC188
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 188 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1813` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa188` into the merged state
`PRE_first_tail_x15_r0_body.s1812`. -/

def PRE_first_tail_x15_r0_body.pl188 : List Nat := [2822041]
def PRE_first_tail_x15_r0_body.nr188 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd188 : RData :=
  ⟨2822032, 2822042, Stage.setAll PTrie.nil [(2822031, 2822041)], Stage.setAll PTrie.nil [],
   21893, 21893, 19003, 19003, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa188 : Map :=
  Conv.Map.compact 2822031 2822042 8092 PRE_first_tail_x15_r0_body.pl188 (PRE_first_tail_x15_r0_body.nr188.map NumV.ref) PRE_first_tail_x15_r0_body.kd188.big
    PRE_first_tail_x15_r0_body.kd188.region PRE_first_tail_x15_r0_body.kd188.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws188 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs188 : List SymE := PRE_first_tail_x15_r0_body.nr188.map fun r => (nth? PRE_first_tail_x15_r0_body.S1812.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta188 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws188 PRE_first_tail_x15_r0_body.crs188
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB188 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab188 : PRE_first_tail_x15_r0_body.S1813.tab = PRE_first_tail_x15_r0_body.S1811.tab ++ PRE_first_tail_x15_r0_body.cws188.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace188 : PRE_first_tail_x15_r0_body.s1813.trace = PRE_first_tail_x15_r0_body.s1811.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext188 : PRE_first_tail_x15_r0_body.s1813.next = 2822032
kernel_rfl PRE_first_tail_x15_r0_body.ccounters188 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi).mlx.nnext) = (21893, 19003)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue188 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1812.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa188.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp188 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi).mlx.tokens.all (bSN 8092) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean188 : Conv.cleanListB 21893 131072 (fun r => Nat.ble 87572 r) PRE_first_tail_x15_r0_body.s1813
    (PRE_first_tail_x15_r0_body.wrB188 ++ (List.range 1).map (2822031 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs188 : bigsOutB 21893 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK188
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl188`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl188 : List Nat := [2665, 2673467, 2822031]
def PRE_first_tail_x15_r0_body.clo188 : List Nat := []
def PRE_first_tail_x15_r0_body.cln188 : List Nat := []
def PRE_first_tail_x15_r0_body.cli188 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap188 : PRE_first_tail_x15_r0_body.s1813.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1811.heap (PRE_first_tail_x15_r0_body.cl188.filterMap fun a => (PRE_first_tail_x15_r0_body.s1813.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe188 : Nat.ble PRE_first_tail_x15_r0_body.s1811.next PRE_first_tail_x15_r0_body.s1813.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP188 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1811 PRE_first_tail_x15_r0_body.s1813 PRE_first_tail_x15_r0_body.cl188 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp188 : Conv.suppListB PRE_first_tail_x15_r0_body.s1813 8092 PRE_first_tail_x15_r0_body.cl188 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound188 : Conv.boundListB PRE_first_tail_x15_r0_body.s1813 PRE_first_tail_x15_r0_body.cl188 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK188 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln188.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK188 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo188.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK188 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli188.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst188 : Conv.sstListB 8092 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi).mlx PRE_first_tail_x15_r0_body.cln188 PRE_first_tail_x15_r0_body.clo188 PRE_first_tail_x15_r0_body.cli188 = true

end Host.Load.Run.Tpl
end

section -- SiteCl188
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA188 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo188.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd188 : (PRE_first_tail_x15_r0_body.clo188 ++ PRE_first_tail_x15_r0_body.cln188 ++ PRE_first_tail_x15_r0_body.cli188).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle188 : Conv.Cnt.leB (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt) (⟨21893, 19003, 2822032, 8092⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck188 : Conv.ncleanListB (⟨21893, 19003, 2822032, 8092⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi).mlx PRE_first_tail_x15_r0_body.clo188 PRE_first_tail_x15_r0_body.cln188 PRE_first_tail_x15_r0_body.cli188 = true
theorem PRE_first_tail_x15_r0_body.cncl188 (h : Conv.NClean (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx) : Conv.NClean (⟨21893, 19003, 2822032, 8092⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle188 PRE_first_tail_x15_r0_body.ckA188 PRE_first_tail_x15_r0_body.cobjsK188 PRE_first_tail_x15_r0_body.cnodesK188 PRE_first_tail_x15_r0_body.citemsK188 PRE_first_tail_x15_r0_body.cbd188 PRE_first_tail_x15_r0_body.cck188

end Host.Load.Run.Tpl
end

section -- SiteS188
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 188 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc188 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P188 : LoadP := PRE_first_tail_x15_r0_body.Pc188.raise 19003
kernel_rfl PRE_first_tail_x15_r0_body.craise188 : Nat.ble PRE_first_tail_x15_r0_body.Pc188.N0 19003 = true
theorem PRE_first_tail_x15_r0_body.raised188 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc188 PRE_first_tail_x15_r0_body.P188 :=
  .inr ⟨19003, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise188, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_188 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_188 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1812.ffi)
def PRE_first_tail_x15_r0_body.khinv188 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv188 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS188 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS188 : List Nat := List.range' 19003 0
def PRE_first_tail_x15_r0_body.ciS188 : List Nat := [] ++ List.range' 19003 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0188 : PRE_first_tail_x15_r0_body.kd188.nh0 = PRE_first_tail_x15_r0_body.cx0_188.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1188 : PRE_first_tail_x15_r0_body.kd188.nh1 = PRE_first_tail_x15_r0_body.cx1_188.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0188 : PRE_first_tail_x15_r0_body.kd188.nn0 = PRE_first_tail_x15_r0_body.cx0_188.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1188 : PRE_first_tail_x15_r0_body.kd188.nn1 = PRE_first_tail_x15_r0_body.cx1_188.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo188 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P188.lo && Nat.ble PRE_first_tail_x15_r0_body.P188.lo PRE_first_tail_x15_r0_body.cx0_188.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P188.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P188.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt188 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_188.mlx.next PRE_first_tail_x15_r0_body.cx1_188.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_188.mlx.nnext PRE_first_tail_x15_r0_body.cx1_188.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband188 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P188.NL && Nat.ble PRE_first_tail_x15_r0_body.P188.NL PRE_first_tail_x15_r0_body.P188.N0 && Nat.ble PRE_first_tail_x15_r0_body.P188.N0 PRE_first_tail_x15_r0_body.cx0_188.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow188 : PRE_first_tail_x15_r0_body.kd188.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren188 : checkRenG PRE_first_tail_x15_r0_body.kd188.hnd PRE_first_tail_x15_r0_body.khinv188 (phB PRE_first_tail_x15_r0_body.cx0_188.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband188 : PRE_first_tail_x15_r0_body.kd188.checkBand PRE_first_tail_x15_r0_body.P188.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos188 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd188.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren188 : checkRenG PRE_first_tail_x15_r0_body.kd188.node PRE_first_tail_x15_r0_body.kninv188 (pnB PRE_first_tail_x15_r0_body.cx0_188.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow188 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd188.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P188.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd188.nodeF j) PRE_first_tail_x15_r0_body.cx1_188.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a188 : PRE_first_tail_x15_r0_body.cx0_188.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b188 : PRE_first_tail_x15_r0_body.cx0_188.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1188 : PRE_first_tail_x15_r0_body.cx1_188.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend188 : PRE_first_tail_x15_r0_body.cx1_188.mlx.pending = PRE_first_tail_x15_r0_body.cx0_188.mlx.pending.map PRE_first_tail_x15_r0_body.kappa188.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh188 : PRE_first_tail_x15_r0_body.cx1_188.mlx.errh = PRE_first_tail_x15_r0_body.cx0_188.mlx.errh.map PRE_first_tail_x15_r0_body.kappa188.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles188 : PRE_first_tail_x15_r0_body.cx1_188.mlx.files = PRE_first_tail_x15_r0_body.cx0_188.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch188 : PRE_first_tail_x15_r0_body.cx1_188.mlx.arch = PRE_first_tail_x15_r0_body.cx0_188.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes188 : PRE_first_tail_x15_r0_body.cx1_188.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_188.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired188 : PRE_first_tail_x15_r0_body.cx1_188.mlx.wired = PRE_first_tail_x15_r0_body.cx0_188.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost188 : PRE_first_tail_x15_r0_body.cx1_188.host = PRE_first_tail_x15_r0_body.cx0_188.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd188`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0188 : PRE_first_tail_x15_r0_body.kd188.n0 = 2822032
kernel_rfl PRE_first_tail_x15_r0_body.ckn1188 : PRE_first_tail_x15_r0_body.kd188.n1 = 2822042
kernel_rfl PRE_first_tail_x15_r0_body.ckheap188 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd188.heap).all (fun x => Nat.ble 2822031 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl188 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd188.heap.get (2822031 + j) = nth? PRE_first_tail_x15_r0_body.pl188 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja188 : Nat.ble 2822031 2822031 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn188 : Nat.ble 8092 8092 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD188 : Nat.ble 2822031 PRE_first_tail_x15_r0_body.kd188.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn188 : Nat.ble 21893 PRE_first_tail_x15_r0_body.kd188.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn188 : Nat.ble 19003 PRE_first_tail_x15_r0_body.kd188.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb188 : Nat.ble 21893 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap188 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd188.heap).all (Nat.ble (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd188 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd188.hnd).all (Nat.ble (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode188 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd188.node).all (Nat.ble (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix188 : Conv.FixOld (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa188 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja188) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn188) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD188) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn188) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn188) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb188) PRE_first_tail_x15_r0_body.fheap188 PRE_first_tail_x15_r0_body.fhnd188 PRE_first_tail_x15_r0_body.fnode188
kernel_rfl PRE_first_tail_x15_r0_body.fcxn188 : (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn188 : (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0188 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_188.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_188.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk188 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd188.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A188 : PRE_first_tail_x15_r0_body.cx1_188.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS188.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_188.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O188 : PRE_first_tail_x15_r0_body.cx1_188.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS188.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_188.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N188 : PRE_first_tail_x15_r0_body.cx1_188.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS188.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_188.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I188 : PRE_first_tail_x15_r0_body.cx1_188.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS188.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_188.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd188 : (PRE_first_tail_x15_r0_body.clo188 ++ PRE_first_tail_x15_r0_body.cln188 ++ PRE_first_tail_x15_r0_body.cli188 ++ PRE_first_tail_x15_r0_body.cwS188 ++ PRE_first_tail_x15_r0_body.cnS188 ++ PRE_first_tail_x15_r0_body.ciS188).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW188 : PRE_first_tail_x15_r0_body.cwS188.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo188.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI188 : PRE_first_tail_x15_r0_body.ciS188.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli188.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN188 : PRE_first_tail_x15_r0_body.cnS188.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF188 : PRE_first_tail_x15_r0_body.cln188.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh188 : PRE_first_tail_x15_r0_body.clo188.all (handleOK PRE_first_tail_x15_r0_body.kappa188 PRE_first_tail_x15_r0_body.P188.lo PRE_first_tail_x15_r0_body.cx0_188.mlx PRE_first_tail_x15_r0_body.cx1_188.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo188 : PRE_first_tail_x15_r0_body.clo188.map (fun h => PRE_first_tail_x15_r0_body.cx1_188.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa188.handle h)) = PRE_first_tail_x15_r0_body.clo188.map (fun h => (PRE_first_tail_x15_r0_body.cx0_188.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa188.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok188 : PRE_first_tail_x15_r0_body.clo188.all (objOK PRE_first_tail_x15_r0_body.kappa188 PRE_first_tail_x15_r0_body.P188.NL PRE_first_tail_x15_r0_body.cx0_188.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd188 : PRE_first_tail_x15_r0_body.cln188.all (nodeOKF PRE_first_tail_x15_r0_body.kappa188 PRE_first_tail_x15_r0_body.P188 PRE_first_tail_x15_r0_body.cx0_188.mlx PRE_first_tail_x15_r0_body.cx1_188.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp188 : ((PRE_first_tail_x15_r0_body.cln188.filter (fullB PRE_first_tail_x15_r0_body.P188))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_188.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa188.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln188.filter (fullB PRE_first_tail_x15_r0_body.P188))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_188.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa188.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI188 : incrB PRE_first_tail_x15_r0_body.kd188.nodeF (List.range' 19003 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK188 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd188.node).all (fun k => Nat.ble 19003 k && Nat.blt k 19003) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL188 : (PRE_first_tail_x15_r0_body.cln188.filter (Nat.ble PRE_first_tail_x15_r0_body.P188.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd188.nodeF i) && (Nat.blt i 19003 || Nat.ble PRE_first_tail_x15_r0_body.kd188.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord188 : (PRE_first_tail_x15_r0_body.cln188.filter (Nat.ble PRE_first_tail_x15_r0_body.P188.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd188.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd188.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd188.nodeF j) (PRE_first_tail_x15_r0_body.kd188.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow188 PRE_first_tail_x15_r0_body.cnn1188 PRE_first_tail_x15_r0_body.fnordI188 PRE_first_tail_x15_r0_body.fnordK188 PRE_first_tail_x15_r0_body.fnordL188
kernel_rfl PRE_first_tail_x15_r0_body.fi188 : PRE_first_tail_x15_r0_body.cli188.all (pnB PRE_first_tail_x15_r0_body.cx0_188.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii188 : PRE_first_tail_x15_r0_body.cli188.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_188.mlx.items.get (PRE_first_tail_x15_r0_body.kappa188.node k) = (PRE_first_tail_x15_r0_body.cx0_188.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa188.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot188 (clean : Conv.NClean (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P188.NL) (cl : SSt (· < 8092) PRE_first_tail_x15_r0_body.cx0_188.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P188 8092 PRE_first_tail_x15_r0_body.kappa188 PRE_first_tail_x15_r0_body.kd188 PRE_first_tail_x15_r0_body.khinv188 PRE_first_tail_x15_r0_body.kninv188 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx PRE_first_tail_x15_r0_body.cx0_188.mlx PRE_first_tail_x15_r0_body.cx1_188.mlx (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo188 PRE_first_tail_x15_r0_body.cln188 PRE_first_tail_x15_r0_body.cli188 PRE_first_tail_x15_r0_body.cwS188 PRE_first_tail_x15_r0_body.cnS188 PRE_first_tail_x15_r0_body.ciS188 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0188, PRE_first_tail_x15_r0_body.cnh1188, PRE_first_tail_x15_r0_body.cnn0188, PRE_first_tail_x15_r0_body.cnn1188, PRE_first_tail_x15_r0_body.cplo188, PRE_first_tail_x15_r0_body.ccnt188, PRE_first_tail_x15_r0_body.cnband188, PRE_first_tail_x15_r0_body.chbelow188, PRE_first_tail_x15_r0_body.chren188, PRE_first_tail_x15_r0_body.cband188, PRE_first_tail_x15_r0_body.cnh1pos188, PRE_first_tail_x15_r0_body.cnren188, PRE_first_tail_x15_r0_body.cnlow188, PRE_first_tail_x15_r0_body.cabs0a188, PRE_first_tail_x15_r0_body.cabs0b188, PRE_first_tail_x15_r0_body.ctok1188, PRE_first_tail_x15_r0_body.cpend188, PRE_first_tail_x15_r0_body.cerrh188, PRE_first_tail_x15_r0_body.cfiles188, PRE_first_tail_x15_r0_body.carch188, PRE_first_tail_x15_r0_body.csizes188, PRE_first_tail_x15_r0_body.cwired188, PRE_first_tail_x15_r0_body.cfix188, clean, PRE_first_tail_x15_r0_body.fcxn188, PRE_first_tail_x15_r0_body.fcnn188, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0188, PRE_first_tail_x15_r0_body.fnk188, PRE_first_tail_x15_r0_body.ckA188, PRE_first_tail_x15_r0_body.cobjsK188, PRE_first_tail_x15_r0_body.cnodesK188, PRE_first_tail_x15_r0_body.citemsK188, PRE_first_tail_x15_r0_body.f1A188, PRE_first_tail_x15_r0_body.f1O188, PRE_first_tail_x15_r0_body.f1N188, PRE_first_tail_x15_r0_body.f1I188, PRE_first_tail_x15_r0_body.fbd188, PRE_first_tail_x15_r0_body.fincW188, PRE_first_tail_x15_r0_body.fincI188, PRE_first_tail_x15_r0_body.fincN188, PRE_first_tail_x15_r0_body.flnF188, PRE_first_tail_x15_r0_body.fh188, PRE_first_tail_x15_r0_body.fo188, PRE_first_tail_x15_r0_body.fok188, PRE_first_tail_x15_r0_body.fnd188, PRE_first_tail_x15_r0_body.fp188, PRE_first_tail_x15_r0_body.fnord188, PRE_first_tail_x15_r0_body.fi188, PRE_first_tail_x15_r0_body.fii188⟩
theorem PRE_first_tail_x15_r0_body.cnshift188 (clean : Conv.NClean (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P188.NL) (cl : SSt (· < 8092) PRE_first_tail_x15_r0_body.cx0_188.mlx) : NShift PRE_first_tail_x15_r0_body.P188 8092 PRE_first_tail_x15_r0_body.kappa188 PRE_first_tail_x15_r0_body.cx0_188 PRE_first_tail_x15_r0_body.cx1_188 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot188 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost188 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0188 PRE_first_tail_x15_r0_body.ckn1188 PRE_first_tail_x15_r0_body.ckheap188 PRE_first_tail_x15_r0_body.ckpl188)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_188 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1811.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_188 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1811.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_188 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1811.ffi) = some PRE_first_tail_x15_r0_body.fxC_188
kernel_rfl PRE_first_tail_x15_r0_body.okrC_188 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1811.ffi) = some PRE_first_tail_x15_r0_body.krC_188
noncomputable def PRE_first_tail_x15_r0_body.fx0_188 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1813.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_188 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1813.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_188 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1813.ffi) = some PRE_first_tail_x15_r0_body.fx0_188
kernel_rfl PRE_first_tail_x15_r0_body.okr0_188 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1813.ffi) = some PRE_first_tail_x15_r0_body.kr0_188
noncomputable def PRE_first_tail_x15_r0_body.fx1_188 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1812.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_188 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1812.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_188 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1812.ffi) = some PRE_first_tail_x15_r0_body.fx1_188
kernel_rfl PRE_first_tail_x15_r0_body.okr1_188 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1812.ffi) = some PRE_first_tail_x15_r0_body.kr1_188
kernel_rfl PRE_first_tail_x15_r0_body.ff0188 : PRE_first_tail_x15_r0_body.fx0_188 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_188 (PRE_first_tail_x15_r0_body.clo188.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_188.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1188 : PRE_first_tail_x15_r0_body.fx1_188 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_188 (PRE_first_tail_x15_r0_body.cwS188.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_188.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck188 : freedLB PRE_first_tail_x15_r0_body.kappa188 PRE_first_tail_x15_r0_body.cx0_188.mlx PRE_first_tail_x15_r0_body.fx0_188 PRE_first_tail_x15_r0_body.fx1_188 PRE_first_tail_x15_r0_body.clo188 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0188 : PRE_first_tail_x15_r0_body.kr0_188.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_188.flags (PRE_first_tail_x15_r0_body.clo188.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_188.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0188 : PRE_first_tail_x15_r0_body.kr0_188.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_188.targs (PRE_first_tail_x15_r0_body.clo188.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_188.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1188 : PRE_first_tail_x15_r0_body.kr1_188.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_188.flags (PRE_first_tail_x15_r0_body.cwS188.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_188.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1188 : PRE_first_tail_x15_r0_body.kr1_188.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_188.targs (PRE_first_tail_x15_r0_body.cwS188.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_188.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck188 : krecLB PRE_first_tail_x15_r0_body.kappa188 8092 PRE_first_tail_x15_r0_body.cx0_188.mlx PRE_first_tail_x15_r0_body.kr0_188 PRE_first_tail_x15_r0_body.kr1_188 PRE_first_tail_x15_r0_body.clo188 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn188 : Nat.ble 8092 8092 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge188 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1812.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1813.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR188 : pendRegB PRE_first_tail_x15_r0_body.kappa188 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe188 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1812.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift188 (clean : Conv.NClean (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P188.NL) (cl : SSt (· < 8092) PRE_first_tail_x15_r0_body.cx0_188.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_188.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_188.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_188.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_188.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P188 8092 PRE_first_tail_x15_r0_body.kappa188 PRE_first_tail_x15_r0_body.s1813.ffi PRE_first_tail_x15_r0_body.s1812.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift188 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue188, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp188 t ht),
    PRE_first_tail_x15_r0_body.cbridge188,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1813.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1812.ffi) (PRE_first_tail_x15_r0_body.cfoot188 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_188 PRE_first_tail_x15_r0_body.ofx1_188 hobjC PRE_first_tail_x15_r0_body.ff0188 PRE_first_tail_x15_r0_body.ff1188 PRE_first_tail_x15_r0_body.ffck188,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1813.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1812.ffi) (PRE_first_tail_x15_r0_body.cfoot188 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_188 PRE_first_tail_x15_r0_body.okr1_188 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn188) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0188 PRE_first_tail_x15_r0_body.fkt0188 PRE_first_tail_x15_r0_body.fkf1188 PRE_first_tail_x15_r0_body.fkt1188 PRE_first_tail_x15_r0_body.fkck188,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0188 PRE_first_tail_x15_r0_body.cnh1188 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe188) PRE_first_tail_x15_r0_body.cpendR188⟩

end Host.Load.Run.Tpl
end

section -- st188/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st188 0
host_stream_state PRE_first_tail_x15_r0_body.st188 1
host_stream_state PRE_first_tail_x15_r0_body.st188 2
end Host.Load.Run.Tpl
end

section -- Site188
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 188 of chain `PRE_first_tail_x15_r0_body`: `plan__g188__g189` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1811`, the merged state `PRE_first_tail_x15_r0_body.s1812`,
the site template `PRE_first_tail_x15_r0_body.st188` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1813`: the merge.
The footprint's facts are in `SiteF188`, the compaction's in `SiteC188`, `SiteK188`, `SiteNa188`, `SiteNb188`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso188 : PRE_first_tail_x15_r0_body.st188.s0 = { PRE_first_tail_x15_r0_body.s1811 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs188 : List Frame := PRE_first_tail_x15_r0_body.s1811.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_188 : PRE_first_tail_x15_r0_body.S1811.tab.length = 8092
kernel_rfl PRE_first_tail_x15_r0_body.tab0_188 : PRE_first_tail_x15_r0_body.st188.S0.tab = PRE_first_tail_x15_r0_body.S1811.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws188 : List Nat := [4198, 4199, 4200]
kernel_rfl PRE_first_tail_x15_r0_body.fresh188 : (PRE_first_tail_x15_r0_body.S1811.tab.all fun e => PRE_first_tail_x15_r0_body.ws188.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1811.oracle.all fun q => PRE_first_tail_x15_r0_body.ws188.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab188 : PRE_first_tail_x15_r0_body.S1812.tab = PRE_first_tail_x15_r0_body.S1811.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws188
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen188 : PRE_first_tail_x15_r0_body.st188.S2.tab.length - PRE_first_tail_x15_r0_body.st188.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged188`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap188 : PRE_first_tail_x15_r0_body.s1812.heap = PRE_first_tail_x15_r0_body.st188.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext188 : PRE_first_tail_x15_r0_body.s1812.next = PRE_first_tail_x15_r0_body.st188.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl188 : PRE_first_tail_x15_r0_body.s1812.ctl = PRE_first_tail_x15_r0_body.st188.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack188 : PRE_first_tail_x15_r0_body.s1812.stack = PRE_first_tail_x15_r0_body.st188.s2.stack ++ PRE_first_tail_x15_r0_body.s1811.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs188 : PRE_first_tail_x15_r0_body.s1812.jobs = PRE_first_tail_x15_r0_body.st188.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi188 : PRE_first_tail_x15_r0_body.s1812.ffi = PRE_first_tail_x15_r0_body.st188.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace188 : PRE_first_tail_x15_r0_body.s1812.trace = PRE_first_tail_x15_r0_body.st188.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores188 : PRE_first_tail_x15_r0_body.s1812.stores = PRE_first_tail_x15_r0_body.st188.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD188
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 188 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived188 : PRE_first_tail_x15_r0_body.nr188.map (fun r => nth? PRE_first_tail_x15_r0_body.st188.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo188 : PRE_first_tail_x15_r0_body.nr188.all (Nat.ble 8092) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj188 : PRE_first_tail_x15_r0_body.cws188.all (fun c => !PRE_first_tail_x15_r0_body.ws188.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ188 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws188 PRE_first_tail_x15_r0_body.crs188 PRE_first_tail_x15_r0_body.ws188

end Host.Load.Run.Tpl
end

section -- st188/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st188`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st188.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st188.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st188.s2.heap PRE_first_tail_x15_r0_body.st188.wrR ++ freshOf PRE_first_tail_x15_r0_body.st188.s2.heap PRE_first_tail_x15_r0_body.st188.s0.next PRE_first_tail_x15_r0_body.st188.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st188.wr : List Nat := PRE_first_tail_x15_r0_body.st188.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st188.heapFoot : PRE_first_tail_x15_r0_body.st188.s2.heap = setAll PRE_first_tail_x15_r0_body.st188.s0.heap PRE_first_tail_x15_r0_body.st188.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st188.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st188.s0.next PRE_first_tail_x15_r0_body.st188.s2.next = true
theorem PRE_first_tail_x15_r0_body.st188.grows : PRE_first_tail_x15_r0_body.st188.s0.next ≤ PRE_first_tail_x15_r0_body.st188.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st188.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st188.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st188.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st188.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st188.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st188.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st188.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st188.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st188.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st188.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st188.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st188.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st188.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st188.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st188.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st188.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st188.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st188.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st188.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st188.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st188.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st188.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st188.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st188.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st188.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st188.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st188.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st188.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st188.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st188.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st188.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st188.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF188
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 188 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB188 : nodupT PRE_first_tail_x15_r0_body.st188.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup188 : PRE_first_tail_x15_r0_body.st188.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB188).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB188 : PRE_first_tail_x15_r0_body.st188.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound188 : ∀ b ∈ PRE_first_tail_x15_r0_body.st188.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB188 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr188 := PRE_first_tail_x15_r0_body.st188.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq188 : PRE_first_tail_x15_r0_body.st188.s2.trace = PRE_first_tail_x15_r0_body.trFr188 ++ PRE_first_tail_x15_r0_body.st188.s0.trace
theorem PRE_first_tail_x15_r0_body.trace188 : ∃ fr, PRE_first_tail_x15_r0_body.st188.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st188.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq188⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide188 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB188 : (PRE_first_tail_x15_r0_body.wide188.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st188.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix188 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide188, WFix Map.id (Present PRE_first_tail_x15_r0_body.st188.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB188 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL188
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 188 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1812`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO188 : PRE_first_tail_x15_r0_body.st188.S0.oracle = PRE_first_tail_x15_r0_body.st188.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B188 : PRE_first_tail_x15_r0_body.st188.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st188.s0.next || (PRE_first_tail_x15_r0_body.st188.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot188 : Conv.StageFoot PRE_first_tail_x15_r0_body.st188.wr PRE_first_tail_x15_r0_body.st188.s0 PRE_first_tail_x15_r0_body.st188.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st188.heapFoot PRE_first_tail_x15_r0_body.wrNodup188 PRE_first_tail_x15_r0_body.wrBound188 PRE_first_tail_x15_r0_body.wr0B188 PRE_first_tail_x15_r0_body.st188.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged188 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st188.F.S → PRE_first_tail_x15_r0_body.st188.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st188.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st188.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs188 PRE_first_tail_x15_r0_body.st188.wr PRE_first_tail_x15_r0_body.s1811 PRE_first_tail_x15_r0_body.st188.s2 PRE_first_tail_x15_r0_body.st188.s0
      PRE_first_tail_x15_r0_body.st188.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st188.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1812 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso188 PRE_first_tail_x15_r0_body.stFoot188 PRE_first_tail_x15_r0_body.wrNodup188 PRE_first_tail_x15_r0_body.wrBound188 PRE_first_tail_x15_r0_body.trace188 PRE_first_tail_x15_r0_body.mheap188
    PRE_first_tail_x15_r0_body.mnext188 PRE_first_tail_x15_r0_body.mctl188 PRE_first_tail_x15_r0_body.mstack188 PRE_first_tail_x15_r0_body.mjobs188 PRE_first_tail_x15_r0_body.mffi188 PRE_first_tail_x15_r0_body.mtrace188 PRE_first_tail_x15_r0_body.mstores188 h

def PRE_first_tail_x15_r0_body.arrEl188_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE188_2665 : arrOf PRE_first_tail_x15_r0_body.s1812 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl188_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA188_2665 : isArrB PRE_first_tail_x15_r0_body.s1812 2665 = true
theorem PRE_first_tail_x15_r0_body.arr188_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1812.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl188_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE188_2665 PRE_first_tail_x15_r0_body.arrA188_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN188_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl188_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR188_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl188_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN188_2665

def PRE_first_tail_x15_r0_body.arrEl188_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE188_2673467 : arrOf PRE_first_tail_x15_r0_body.s1812 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl188_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA188_2673467 : isArrB PRE_first_tail_x15_r0_body.s1812 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr188_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1812.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl188_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE188_2673467 PRE_first_tail_x15_r0_body.arrA188_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN188_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl188_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR188_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl188_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN188_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k188 : isArrB PRE_first_tail_x15_r0_body.s1812 4910 = false
theorem PRE_first_tail_x15_r0_body.keep188 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1812 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k188 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr188_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl188_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ188
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 188 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1811`, the merged
state `PRE_first_tail_x15_r0_body.s1812`, the canonical state `PRE_first_tail_x15_r0_body.s1813`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl188 : PRE_first_tail_x15_r0_body.pl188.all (Nat.ble PRE_first_tail_x15_r0_body.s1811.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd188 : nodupT PRE_first_tail_x15_r0_body.pl188 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1188 : Nat.ble PRE_first_tail_x15_r0_body.s1811.next 2822042 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst188 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1811.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn188 : PRE_first_tail_x15_r0_body.s1813.next = PRE_first_tail_x15_r0_body.s1811.next + PRE_first_tail_x15_r0_body.pl188.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn188 : PRE_first_tail_x15_r0_body.s1812.next = 2822042
kernel_rfl PRE_first_tail_x15_r0_body.zgrow188 : Nat.ble PRE_first_tail_x15_r0_body.s1813.next PRE_first_tail_x15_r0_body.s1812.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh188 : PRE_first_tail_x15_r0_body.S1811.tab.all (fun e => PRE_first_tail_x15_r0_body.cws188.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd188 : nodupT PRE_first_tail_x15_r0_body.cws188 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi188 : PRE_first_tail_x15_r0_body.nr188.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1812.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt188 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1811.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg188_2665 : PRE_first_tail_x15_r0_body.s1813.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1813 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk188_2665 : (objOf PRE_first_tail_x15_r0_body.s1813 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm188_2665 : PRE_first_tail_x15_r0_body.s1812.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa188.obj (objOf PRE_first_tail_x15_r0_body.s1813 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1812 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg188_2673467 : PRE_first_tail_x15_r0_body.s1813.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1813 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk188_2673467 : (objOf PRE_first_tail_x15_r0_body.s1813 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm188_2673467 : PRE_first_tail_x15_r0_body.s1812.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa188.obj (objOf PRE_first_tail_x15_r0_body.s1813 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1812 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw188_4910 : (PRE_first_tail_x15_r0_body.s1813.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw188_2673472 : (PRE_first_tail_x15_r0_body.s1813.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw188_2673473 : (PRE_first_tail_x15_r0_body.s1813.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd188 : PRE_first_tail_x15_r0_body.cl188.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr188 : PRE_first_tail_x15_r0_body.st188.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1811.next || PRE_first_tail_x15_r0_body.cl188.contains b) = true
def PRE_first_tail_x15_r0_body.zl188 : List Nat := PRE_first_tail_x15_r0_body.cl188.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE188 : PRE_first_tail_x15_r0_body.zl188.map (fun a => PRE_first_tail_x15_r0_body.s1812.heap.get (PRE_first_tail_x15_r0_body.kappa188.a a)) = PRE_first_tail_x15_r0_body.zl188.map (fun a => (PRE_first_tail_x15_r0_body.s1813.heap.get a).map PRE_first_tail_x15_r0_body.kappa188.hobj)
theorem PRE_first_tail_x15_r0_body.zimg188 : HeapImg PRE_first_tail_x15_r0_body.kappa188 PRE_first_tail_x15_r0_body.s1813 PRE_first_tail_x15_r0_body.s1812 PRE_first_tail_x15_r0_body.zl188 := PRE_first_tail_x15_r0_body.zimgE188
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl188 : PRE_first_tail_x15_r0_body.s1812.ctl = PRE_first_tail_x15_r0_body.kappa188.ctl PRE_first_tail_x15_r0_body.s1813.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack188 : PRE_first_tail_x15_r0_body.s1812.stack = PRE_first_tail_x15_r0_body.s1813.stack.map PRE_first_tail_x15_r0_body.kappa188.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs188 : PRE_first_tail_x15_r0_body.s1812.jobs = PRE_first_tail_x15_r0_body.s1813.jobs.map PRE_first_tail_x15_r0_body.kappa188.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores188 : PRE_first_tail_x15_r0_body.s1812.stores = PRE_first_tail_x15_r0_body.kappa188.stores PRE_first_tail_x15_r0_body.s1813.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots188 : checkRootsSupp PRE_first_tail_x15_r0_body.s1813 8092 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC188 : PRE_first_tail_x15_r0_body.S1811.tab.length + PRE_first_tail_x15_r0_body.cws188.length = 8092
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap188 : PRE_first_tail_x15_r0_body.kappa188 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1811.next 2822042 PRE_first_tail_x15_r0_body.S1811.tab.length PRE_first_tail_x15_r0_body.pl188 (PRE_first_tail_x15_r0_body.nr188.map NumV.ref) PRE_first_tail_x15_r0_body.kd188.big
  PRE_first_tail_x15_r0_body.kd188.region PRE_first_tail_x15_r0_body.kd188.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin188 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1813.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc188 : Conv.jcleanListB (⟨21893, 19003, 2822032, 8092⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1813 PRE_first_tail_x15_r0_body.cl188 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB188 : noBigRootsP (fun i => !Conv.oldBigB (⟨21893, 19003, 2822032, 8092⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1813.trace PRE_first_tail_x15_r0_body.s1813 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm188 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 19003 = true
theorem PRE_first_tail_x15_r0_body.cjcl188 (h : Conv.JClean (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1811) : Conv.JClean (⟨21893, 19003, 2822032, 8092⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1813 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle188)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap188 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd188 a ha)) PRE_first_tail_x15_r0_body.zjc188

end Host.Load.Run.Tpl
end

section -- st188/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st188.bodyLast from PRE_first_tail_x15_r0_body.st188.s1 to PRE_first_tail_x15_r0_body.st188.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st188.F PRE_first_tail_x15_r0_body.st188.s1).run PRE_first_tail_x15_r0_body.st188.S1 = some (PRE_first_tail_x15_r0_body.st188.s2, PRE_first_tail_x15_r0_body.st188.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st188.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st188.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st188.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st188.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st188/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st188.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st188.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st188.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st188.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st188.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st188.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st188.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st188.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st188.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st188.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st188.s0 PRE_first_tail_x15_r0_body.st188.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st188.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st188.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st188.s1 PRE_first_tail_x15_r0_body.st188.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st188/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st188.bodyK0F from PRE_first_tail_x15_r0_body.st188.s0 to PRE_first_tail_x15_r0_body.st188.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st188.F (PRE_first_tail_x15_r0_body.st188.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st188.ks 0).getD 0) PRE_first_tail_x15_r0_body.st188.s0 PRE_first_tail_x15_r0_body.st188.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st188.s1, PRE_first_tail_x15_r0_body.st188.S1)
theorem PRE_first_tail_x15_r0_body.st188.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st188.F (PRE_first_tail_x15_r0_body.st188.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st188.ks 0).getD 0) PRE_first_tail_x15_r0_body.st188.s0 PRE_first_tail_x15_r0_body.st188.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st188.s1, PRE_first_tail_x15_r0_body.st188.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st188.bodyOkLN_ok PRE_first_tail_x15_r0_body.st188.bodyK0F
end Host.Load.Run.Tpl
end

section -- st188/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st188.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st188.F (PRE_first_tail_x15_r0_body.st188.bodyOkL bytes rows) 98 PRE_first_tail_x15_r0_body.st188.s0 PRE_first_tail_x15_r0_body.st188.S0 = some (PRE_first_tail_x15_r0_body.st188.s1, PRE_first_tail_x15_r0_body.st188.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st188.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st188.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st188.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st188.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st188.F (PRE_first_tail_x15_r0_body.st188.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st188.s0
  S0 := PRE_first_tail_x15_r0_body.st188.S0
  s1 := PRE_first_tail_x15_r0_body.st188.s1
  S1 := PRE_first_tail_x15_r0_body.st188.S1
  s2 := PRE_first_tail_x15_r0_body.st188.s2
  S2 := PRE_first_tail_x15_r0_body.st188.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st188.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st188.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st188.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st188.bodyHalt
  last := PRE_first_tail_x15_r0_body.st188.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st188.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC189
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 189 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1829` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa189` into the merged state
`PRE_first_tail_x15_r0_body.s1828`. -/

def PRE_first_tail_x15_r0_body.pl189 : List Nat := [2824130, 2823966, 2824018, 2824131, 2824132, 2823968, 2824020, 2824129, 2824128, 2824127, 2824126, 2824120, 2824071, 2824122, 2824073]
def PRE_first_tail_x15_r0_body.nr189 : List Nat := [8177, 8178, 8174, 8180, 8176, 8184, 8185, 8182, 8183]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd189 : RData :=
  ⟨2823783, 2824133, Stage.setAll PTrie.nil [(2823768, 2824130), (2823769, 2823966), (2823770, 2824018), (2823771, 2824131), (2823772, 2824132), (2823773, 2823968), (2823774, 2824020), (2823775, 2824129), (2823776, 2824128), (2823777, 2824127), (2823778, 2824126), (2823779, 2824120), (2823780, 2824071), (2823781, 2824122), (2823782, 2824073)], Stage.setAll PTrie.nil [(21933, 21935), (21934, 21936), (21935, 21938), (21936, 21937)],
   21937, 21939, 19037, 19037, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(8169, .ref 8177), (8170, .ref 8178), (8171, .ref 8174), (8172, .ref 8180), (8173, .ref 8176), (8174, .ref 8184), (8175, .ref 8185), (8176, .ref 8182), (8177, .ref 8183)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa189 : Map :=
  Conv.Map.compact 2823768 2824133 8169 PRE_first_tail_x15_r0_body.pl189 (PRE_first_tail_x15_r0_body.nr189.map NumV.ref) PRE_first_tail_x15_r0_body.kd189.big
    PRE_first_tail_x15_r0_body.kd189.region PRE_first_tail_x15_r0_body.kd189.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws189 : List Nat := [4218, 4219, 4220, 4221, 4222, 4223, 4224, 4225, 4226]
noncomputable def PRE_first_tail_x15_r0_body.crs189 : List SymE := PRE_first_tail_x15_r0_body.nr189.map fun r => (nth? PRE_first_tail_x15_r0_body.S1828.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta189 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws189 PRE_first_tail_x15_r0_body.crs189
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB189 : List Nat := [2665, 2672787, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab189 : PRE_first_tail_x15_r0_body.S1829.tab = PRE_first_tail_x15_r0_body.S1827.tab ++ PRE_first_tail_x15_r0_body.cws189.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace189 : PRE_first_tail_x15_r0_body.s1829.trace = PRE_first_tail_x15_r0_body.s1827.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext189 : PRE_first_tail_x15_r0_body.s1829.next = 2823783
kernel_rfl PRE_first_tail_x15_r0_body.ccounters189 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx.nnext) = (21937, 19037)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue189 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1828.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa189.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp189 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx.tokens.all (bSN 8178) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean189 : Conv.cleanListB 21937 131072 (fun r => Nat.ble 87748 r) PRE_first_tail_x15_r0_body.s1829
    (PRE_first_tail_x15_r0_body.wrB189 ++ (List.range 15).map (2823768 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs189 : bigsOutB 21937 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK189
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl189`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl189 : List Nat := [2665, 2672787, 2673467, 2823768, 2823769, 2823770, 2823771, 2823772, 2823773, 2823774, 2823775, 2823776, 2823777, 2823778, 2823779, 2823780, 2823781, 2823782]
def PRE_first_tail_x15_r0_body.clo189 : List Nat := [21933, 21934, 21935, 21936]
def PRE_first_tail_x15_r0_body.cln189 : List Nat := [19031, 19032, 19033, 19034, 19035, 19036]
def PRE_first_tail_x15_r0_body.cli189 : List Nat := [19031, 19032, 19033, 19034, 19035, 19036]
kernel_rfl PRE_first_tail_x15_r0_body.cheap189 : PRE_first_tail_x15_r0_body.s1829.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1827.heap (PRE_first_tail_x15_r0_body.cl189.filterMap fun a => (PRE_first_tail_x15_r0_body.s1829.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe189 : Nat.ble PRE_first_tail_x15_r0_body.s1827.next PRE_first_tail_x15_r0_body.s1829.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP189 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1827 PRE_first_tail_x15_r0_body.s1829 PRE_first_tail_x15_r0_body.cl189 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp189 : Conv.suppListB PRE_first_tail_x15_r0_body.s1829 8178 PRE_first_tail_x15_r0_body.cl189 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound189 : Conv.boundListB PRE_first_tail_x15_r0_body.s1829 PRE_first_tail_x15_r0_body.cl189 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK189 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln189.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK189 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo189.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK189 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli189.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst189 : Conv.sstListB 8178 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx PRE_first_tail_x15_r0_body.cln189 PRE_first_tail_x15_r0_body.clo189 PRE_first_tail_x15_r0_body.cli189 = true

end Host.Load.Run.Tpl
end

section -- SiteCl189
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA189 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo189.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd189 : (PRE_first_tail_x15_r0_body.clo189 ++ PRE_first_tail_x15_r0_body.cln189 ++ PRE_first_tail_x15_r0_body.cli189).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle189 : Conv.Cnt.leB (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt) (⟨21937, 19037, 2823783, 8178⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck189 : Conv.ncleanListB (⟨21937, 19037, 2823783, 8178⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx PRE_first_tail_x15_r0_body.clo189 PRE_first_tail_x15_r0_body.cln189 PRE_first_tail_x15_r0_body.cli189 = true
theorem PRE_first_tail_x15_r0_body.cncl189 (h : Conv.NClean (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx) : Conv.NClean (⟨21937, 19037, 2823783, 8178⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle189 PRE_first_tail_x15_r0_body.ckA189 PRE_first_tail_x15_r0_body.cobjsK189 PRE_first_tail_x15_r0_body.cnodesK189 PRE_first_tail_x15_r0_body.citemsK189 PRE_first_tail_x15_r0_body.cbd189 PRE_first_tail_x15_r0_body.cck189

end Host.Load.Run.Tpl
end

section -- SiteS189
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 189 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc189 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P189 : LoadP := PRE_first_tail_x15_r0_body.Pc189.raise 19037
kernel_rfl PRE_first_tail_x15_r0_body.craise189 : Nat.ble PRE_first_tail_x15_r0_body.Pc189.N0 19037 = true
theorem PRE_first_tail_x15_r0_body.raised189 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc189 PRE_first_tail_x15_r0_body.P189 :=
  .inr ⟨19037, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise189, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_189 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_189 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1828.ffi)
def PRE_first_tail_x15_r0_body.khinv189 : PTrie Nat := Stage.setAll PTrie.nil [(21935, 21933), (21936, 21934), (21938, 21935), (21937, 21936)]
def PRE_first_tail_x15_r0_body.kninv189 : PTrie Nat := Stage.setAll PTrie.nil [(19031, 19031), (19032, 19032), (19033, 19033), (19034, 19034), (19035, 19035), (19036, 19036)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS189 : List Nat := [21933, 21934, 21935, 21936, 21937, 21938]
def PRE_first_tail_x15_r0_body.cnS189 : List Nat := List.range' 19031 6
def PRE_first_tail_x15_r0_body.ciS189 : List Nat := [] ++ List.range' 19031 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0189 : PRE_first_tail_x15_r0_body.kd189.nh0 = PRE_first_tail_x15_r0_body.cx0_189.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1189 : PRE_first_tail_x15_r0_body.kd189.nh1 = PRE_first_tail_x15_r0_body.cx1_189.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0189 : PRE_first_tail_x15_r0_body.kd189.nn0 = PRE_first_tail_x15_r0_body.cx0_189.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1189 : PRE_first_tail_x15_r0_body.kd189.nn1 = PRE_first_tail_x15_r0_body.cx1_189.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo189 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P189.lo && Nat.ble PRE_first_tail_x15_r0_body.P189.lo PRE_first_tail_x15_r0_body.cx0_189.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P189.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P189.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt189 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_189.mlx.next PRE_first_tail_x15_r0_body.cx1_189.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_189.mlx.nnext PRE_first_tail_x15_r0_body.cx1_189.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband189 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P189.NL && Nat.ble PRE_first_tail_x15_r0_body.P189.NL PRE_first_tail_x15_r0_body.P189.N0 && Nat.ble PRE_first_tail_x15_r0_body.P189.N0 PRE_first_tail_x15_r0_body.cx0_189.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow189 : PRE_first_tail_x15_r0_body.kd189.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren189 : checkRenG PRE_first_tail_x15_r0_body.kd189.hnd PRE_first_tail_x15_r0_body.khinv189 (phB PRE_first_tail_x15_r0_body.cx0_189.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband189 : PRE_first_tail_x15_r0_body.kd189.checkBand PRE_first_tail_x15_r0_body.P189.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos189 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd189.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren189 : checkRenG PRE_first_tail_x15_r0_body.kd189.node PRE_first_tail_x15_r0_body.kninv189 (pnB PRE_first_tail_x15_r0_body.cx0_189.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow189 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd189.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P189.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd189.nodeF j) PRE_first_tail_x15_r0_body.cx1_189.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a189 : PRE_first_tail_x15_r0_body.cx0_189.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b189 : PRE_first_tail_x15_r0_body.cx0_189.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1189 : PRE_first_tail_x15_r0_body.cx1_189.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend189 : PRE_first_tail_x15_r0_body.cx1_189.mlx.pending = PRE_first_tail_x15_r0_body.cx0_189.mlx.pending.map PRE_first_tail_x15_r0_body.kappa189.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh189 : PRE_first_tail_x15_r0_body.cx1_189.mlx.errh = PRE_first_tail_x15_r0_body.cx0_189.mlx.errh.map PRE_first_tail_x15_r0_body.kappa189.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles189 : PRE_first_tail_x15_r0_body.cx1_189.mlx.files = PRE_first_tail_x15_r0_body.cx0_189.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch189 : PRE_first_tail_x15_r0_body.cx1_189.mlx.arch = PRE_first_tail_x15_r0_body.cx0_189.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes189 : PRE_first_tail_x15_r0_body.cx1_189.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_189.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired189 : PRE_first_tail_x15_r0_body.cx1_189.mlx.wired = PRE_first_tail_x15_r0_body.cx0_189.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost189 : PRE_first_tail_x15_r0_body.cx1_189.host = PRE_first_tail_x15_r0_body.cx0_189.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd189`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0189 : PRE_first_tail_x15_r0_body.kd189.n0 = 2823783
kernel_rfl PRE_first_tail_x15_r0_body.ckn1189 : PRE_first_tail_x15_r0_body.kd189.n1 = 2824133
kernel_rfl PRE_first_tail_x15_r0_body.ckheap189 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd189.heap).all (fun x => Nat.ble 2823768 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl189 : (List.range 15).all (fun j => decide (PRE_first_tail_x15_r0_body.kd189.heap.get (2823768 + j) = nth? PRE_first_tail_x15_r0_body.pl189 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja189 : Nat.ble 2823768 2823768 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn189 : Nat.ble 8169 8169 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD189 : Nat.ble 2823768 PRE_first_tail_x15_r0_body.kd189.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn189 : Nat.ble 21933 PRE_first_tail_x15_r0_body.kd189.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn189 : Nat.ble 19031 PRE_first_tail_x15_r0_body.kd189.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb189 : Nat.ble 21933 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap189 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd189.heap).all (Nat.ble (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd189 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd189.hnd).all (Nat.ble (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode189 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd189.node).all (Nat.ble (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix189 : Conv.FixOld (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa189 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja189) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn189) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD189) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn189) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn189) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb189) PRE_first_tail_x15_r0_body.fheap189 PRE_first_tail_x15_r0_body.fhnd189 PRE_first_tail_x15_r0_body.fnode189
kernel_rfl PRE_first_tail_x15_r0_body.fcxn189 : (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn189 : (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0189 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_189.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_189.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk189 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd189.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A189 : PRE_first_tail_x15_r0_body.cx1_189.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS189.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_189.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O189 : PRE_first_tail_x15_r0_body.cx1_189.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS189.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_189.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N189 : PRE_first_tail_x15_r0_body.cx1_189.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS189.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_189.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I189 : PRE_first_tail_x15_r0_body.cx1_189.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS189.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_189.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd189 : (PRE_first_tail_x15_r0_body.clo189 ++ PRE_first_tail_x15_r0_body.cln189 ++ PRE_first_tail_x15_r0_body.cli189 ++ PRE_first_tail_x15_r0_body.cwS189 ++ PRE_first_tail_x15_r0_body.cnS189 ++ PRE_first_tail_x15_r0_body.ciS189).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW189 : PRE_first_tail_x15_r0_body.cwS189.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo189.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI189 : PRE_first_tail_x15_r0_body.ciS189.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli189.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN189 : PRE_first_tail_x15_r0_body.cnS189.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF189 : PRE_first_tail_x15_r0_body.cln189.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh189 : PRE_first_tail_x15_r0_body.clo189.all (handleOK PRE_first_tail_x15_r0_body.kappa189 PRE_first_tail_x15_r0_body.P189.lo PRE_first_tail_x15_r0_body.cx0_189.mlx PRE_first_tail_x15_r0_body.cx1_189.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo189 : PRE_first_tail_x15_r0_body.clo189.map (fun h => PRE_first_tail_x15_r0_body.cx1_189.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa189.handle h)) = PRE_first_tail_x15_r0_body.clo189.map (fun h => (PRE_first_tail_x15_r0_body.cx0_189.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa189.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok189 : PRE_first_tail_x15_r0_body.clo189.all (objOK PRE_first_tail_x15_r0_body.kappa189 PRE_first_tail_x15_r0_body.P189.NL PRE_first_tail_x15_r0_body.cx0_189.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd189 : PRE_first_tail_x15_r0_body.cln189.all (nodeOKF PRE_first_tail_x15_r0_body.kappa189 PRE_first_tail_x15_r0_body.P189 PRE_first_tail_x15_r0_body.cx0_189.mlx PRE_first_tail_x15_r0_body.cx1_189.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp189 : ((PRE_first_tail_x15_r0_body.cln189.filter (fullB PRE_first_tail_x15_r0_body.P189))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_189.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa189.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln189.filter (fullB PRE_first_tail_x15_r0_body.P189))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_189.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa189.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI189 : incrB PRE_first_tail_x15_r0_body.kd189.nodeF (List.range' 19031 6) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK189 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd189.node).all (fun k => Nat.ble 19031 k && Nat.blt k 19037) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL189 : (PRE_first_tail_x15_r0_body.cln189.filter (Nat.ble PRE_first_tail_x15_r0_body.P189.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd189.nodeF i) && (Nat.blt i 19037 || Nat.ble PRE_first_tail_x15_r0_body.kd189.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord189 : (PRE_first_tail_x15_r0_body.cln189.filter (Nat.ble PRE_first_tail_x15_r0_body.P189.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd189.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd189.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd189.nodeF j) (PRE_first_tail_x15_r0_body.kd189.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow189 PRE_first_tail_x15_r0_body.cnn1189 PRE_first_tail_x15_r0_body.fnordI189 PRE_first_tail_x15_r0_body.fnordK189 PRE_first_tail_x15_r0_body.fnordL189
kernel_rfl PRE_first_tail_x15_r0_body.fi189 : PRE_first_tail_x15_r0_body.cli189.all (pnB PRE_first_tail_x15_r0_body.cx0_189.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii189 : PRE_first_tail_x15_r0_body.cli189.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_189.mlx.items.get (PRE_first_tail_x15_r0_body.kappa189.node k) = (PRE_first_tail_x15_r0_body.cx0_189.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa189.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot189 (clean : Conv.NClean (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P189.NL) (cl : SSt (· < 8178) PRE_first_tail_x15_r0_body.cx0_189.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P189 8178 PRE_first_tail_x15_r0_body.kappa189 PRE_first_tail_x15_r0_body.kd189 PRE_first_tail_x15_r0_body.khinv189 PRE_first_tail_x15_r0_body.kninv189 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx PRE_first_tail_x15_r0_body.cx0_189.mlx PRE_first_tail_x15_r0_body.cx1_189.mlx (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo189 PRE_first_tail_x15_r0_body.cln189 PRE_first_tail_x15_r0_body.cli189 PRE_first_tail_x15_r0_body.cwS189 PRE_first_tail_x15_r0_body.cnS189 PRE_first_tail_x15_r0_body.ciS189 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0189, PRE_first_tail_x15_r0_body.cnh1189, PRE_first_tail_x15_r0_body.cnn0189, PRE_first_tail_x15_r0_body.cnn1189, PRE_first_tail_x15_r0_body.cplo189, PRE_first_tail_x15_r0_body.ccnt189, PRE_first_tail_x15_r0_body.cnband189, PRE_first_tail_x15_r0_body.chbelow189, PRE_first_tail_x15_r0_body.chren189, PRE_first_tail_x15_r0_body.cband189, PRE_first_tail_x15_r0_body.cnh1pos189, PRE_first_tail_x15_r0_body.cnren189, PRE_first_tail_x15_r0_body.cnlow189, PRE_first_tail_x15_r0_body.cabs0a189, PRE_first_tail_x15_r0_body.cabs0b189, PRE_first_tail_x15_r0_body.ctok1189, PRE_first_tail_x15_r0_body.cpend189, PRE_first_tail_x15_r0_body.cerrh189, PRE_first_tail_x15_r0_body.cfiles189, PRE_first_tail_x15_r0_body.carch189, PRE_first_tail_x15_r0_body.csizes189, PRE_first_tail_x15_r0_body.cwired189, PRE_first_tail_x15_r0_body.cfix189, clean, PRE_first_tail_x15_r0_body.fcxn189, PRE_first_tail_x15_r0_body.fcnn189, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0189, PRE_first_tail_x15_r0_body.fnk189, PRE_first_tail_x15_r0_body.ckA189, PRE_first_tail_x15_r0_body.cobjsK189, PRE_first_tail_x15_r0_body.cnodesK189, PRE_first_tail_x15_r0_body.citemsK189, PRE_first_tail_x15_r0_body.f1A189, PRE_first_tail_x15_r0_body.f1O189, PRE_first_tail_x15_r0_body.f1N189, PRE_first_tail_x15_r0_body.f1I189, PRE_first_tail_x15_r0_body.fbd189, PRE_first_tail_x15_r0_body.fincW189, PRE_first_tail_x15_r0_body.fincI189, PRE_first_tail_x15_r0_body.fincN189, PRE_first_tail_x15_r0_body.flnF189, PRE_first_tail_x15_r0_body.fh189, PRE_first_tail_x15_r0_body.fo189, PRE_first_tail_x15_r0_body.fok189, PRE_first_tail_x15_r0_body.fnd189, PRE_first_tail_x15_r0_body.fp189, PRE_first_tail_x15_r0_body.fnord189, PRE_first_tail_x15_r0_body.fi189, PRE_first_tail_x15_r0_body.fii189⟩
theorem PRE_first_tail_x15_r0_body.cnshift189 (clean : Conv.NClean (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P189.NL) (cl : SSt (· < 8178) PRE_first_tail_x15_r0_body.cx0_189.mlx) : NShift PRE_first_tail_x15_r0_body.P189 8178 PRE_first_tail_x15_r0_body.kappa189 PRE_first_tail_x15_r0_body.cx0_189 PRE_first_tail_x15_r0_body.cx1_189 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot189 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost189 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0189 PRE_first_tail_x15_r0_body.ckn1189 PRE_first_tail_x15_r0_body.ckheap189 PRE_first_tail_x15_r0_body.ckpl189)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_189 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1827.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_189 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1827.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_189 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1827.ffi) = some PRE_first_tail_x15_r0_body.fxC_189
kernel_rfl PRE_first_tail_x15_r0_body.okrC_189 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1827.ffi) = some PRE_first_tail_x15_r0_body.krC_189
noncomputable def PRE_first_tail_x15_r0_body.fx0_189 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1829.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_189 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1829.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_189 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1829.ffi) = some PRE_first_tail_x15_r0_body.fx0_189
kernel_rfl PRE_first_tail_x15_r0_body.okr0_189 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1829.ffi) = some PRE_first_tail_x15_r0_body.kr0_189
noncomputable def PRE_first_tail_x15_r0_body.fx1_189 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1828.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_189 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1828.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_189 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1828.ffi) = some PRE_first_tail_x15_r0_body.fx1_189
kernel_rfl PRE_first_tail_x15_r0_body.okr1_189 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1828.ffi) = some PRE_first_tail_x15_r0_body.kr1_189
kernel_rfl PRE_first_tail_x15_r0_body.ff0189 : PRE_first_tail_x15_r0_body.fx0_189 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_189 (PRE_first_tail_x15_r0_body.clo189.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_189.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1189 : PRE_first_tail_x15_r0_body.fx1_189 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_189 (PRE_first_tail_x15_r0_body.cwS189.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_189.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck189 : freedLB PRE_first_tail_x15_r0_body.kappa189 PRE_first_tail_x15_r0_body.cx0_189.mlx PRE_first_tail_x15_r0_body.fx0_189 PRE_first_tail_x15_r0_body.fx1_189 PRE_first_tail_x15_r0_body.clo189 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0189 : PRE_first_tail_x15_r0_body.kr0_189.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_189.flags (PRE_first_tail_x15_r0_body.clo189.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_189.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0189 : PRE_first_tail_x15_r0_body.kr0_189.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_189.targs (PRE_first_tail_x15_r0_body.clo189.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_189.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1189 : PRE_first_tail_x15_r0_body.kr1_189.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_189.flags (PRE_first_tail_x15_r0_body.cwS189.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_189.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1189 : PRE_first_tail_x15_r0_body.kr1_189.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_189.targs (PRE_first_tail_x15_r0_body.cwS189.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_189.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck189 : krecLB PRE_first_tail_x15_r0_body.kappa189 8178 PRE_first_tail_x15_r0_body.cx0_189.mlx PRE_first_tail_x15_r0_body.kr0_189 PRE_first_tail_x15_r0_body.kr1_189 PRE_first_tail_x15_r0_body.clo189 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn189 : Nat.ble 8169 8178 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge189 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1828.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1829.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR189 : pendRegB PRE_first_tail_x15_r0_body.kappa189 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe189 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1828.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift189 (clean : Conv.NClean (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P189.NL) (cl : SSt (· < 8178) PRE_first_tail_x15_r0_body.cx0_189.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_189.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_189.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_189.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_189.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P189 8178 PRE_first_tail_x15_r0_body.kappa189 PRE_first_tail_x15_r0_body.s1829.ffi PRE_first_tail_x15_r0_body.s1828.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift189 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue189, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp189 t ht),
    PRE_first_tail_x15_r0_body.cbridge189,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1829.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1828.ffi) (PRE_first_tail_x15_r0_body.cfoot189 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_189 PRE_first_tail_x15_r0_body.ofx1_189 hobjC PRE_first_tail_x15_r0_body.ff0189 PRE_first_tail_x15_r0_body.ff1189 PRE_first_tail_x15_r0_body.ffck189,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1829.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1828.ffi) (PRE_first_tail_x15_r0_body.cfoot189 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_189 PRE_first_tail_x15_r0_body.okr1_189 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn189) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0189 PRE_first_tail_x15_r0_body.fkt0189 PRE_first_tail_x15_r0_body.fkf1189 PRE_first_tail_x15_r0_body.fkt1189 PRE_first_tail_x15_r0_body.fkck189,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0189 PRE_first_tail_x15_r0_body.cnh1189 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe189) PRE_first_tail_x15_r0_body.cpendR189⟩

end Host.Load.Run.Tpl
end

section -- st189/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st189 0
host_stream_state PRE_first_tail_x15_r0_body.st189 1
host_stream_state PRE_first_tail_x15_r0_body.st189 2
host_stream_state PRE_first_tail_x15_r0_body.st189 3
end Host.Load.Run.Tpl
end

section -- Site189
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 189 of chain `PRE_first_tail_x15_r0_body`: `kvW__g189__g190` (`appendWindow`), the call state `PRE_first_tail_x15_r0_body.s1827`, the merged state `PRE_first_tail_x15_r0_body.s1828`,
the site template `PRE_first_tail_x15_r0_body.st189` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1829`: the merge.
The footprint's facts are in `SiteF189`, the compaction's in `SiteC189`, `SiteK189`, `SiteNa189`, `SiteNb189`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso189 : PRE_first_tail_x15_r0_body.st189.s0 = { PRE_first_tail_x15_r0_body.s1827 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs189 : List Frame := PRE_first_tail_x15_r0_body.s1827.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_189 : PRE_first_tail_x15_r0_body.S1827.tab.length = 8169
kernel_rfl PRE_first_tail_x15_r0_body.tab0_189 : PRE_first_tail_x15_r0_body.st189.S0.tab = PRE_first_tail_x15_r0_body.S1827.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws189 : List Nat := [4201, 4202, 4203, 4204, 4205, 4206, 4207, 4208, 4209, 4210, 4211, 4212, 4213, 4214, 4215, 4216, 4217]
kernel_rfl PRE_first_tail_x15_r0_body.fresh189 : (PRE_first_tail_x15_r0_body.S1827.tab.all fun e => PRE_first_tail_x15_r0_body.ws189.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1827.oracle.all fun q => PRE_first_tail_x15_r0_body.ws189.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab189 : PRE_first_tail_x15_r0_body.S1828.tab = PRE_first_tail_x15_r0_body.S1827.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws189
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen189 : PRE_first_tail_x15_r0_body.st189.S3.tab.length - PRE_first_tail_x15_r0_body.st189.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged189`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap189 : PRE_first_tail_x15_r0_body.s1828.heap = PRE_first_tail_x15_r0_body.st189.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext189 : PRE_first_tail_x15_r0_body.s1828.next = PRE_first_tail_x15_r0_body.st189.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl189 : PRE_first_tail_x15_r0_body.s1828.ctl = PRE_first_tail_x15_r0_body.st189.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack189 : PRE_first_tail_x15_r0_body.s1828.stack = PRE_first_tail_x15_r0_body.st189.s3.stack ++ PRE_first_tail_x15_r0_body.s1827.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs189 : PRE_first_tail_x15_r0_body.s1828.jobs = PRE_first_tail_x15_r0_body.st189.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi189 : PRE_first_tail_x15_r0_body.s1828.ffi = PRE_first_tail_x15_r0_body.st189.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace189 : PRE_first_tail_x15_r0_body.s1828.trace = PRE_first_tail_x15_r0_body.st189.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores189 : PRE_first_tail_x15_r0_body.s1828.stores = PRE_first_tail_x15_r0_body.st189.s3.stores

end Host.Load.Run.Tpl
end

section -- SiteD189
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 189 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived189 : PRE_first_tail_x15_r0_body.nr189.map (fun r => nth? PRE_first_tail_x15_r0_body.st189.S3.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false)))]
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo189 : PRE_first_tail_x15_r0_body.nr189.all (Nat.ble 8169) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj189 : PRE_first_tail_x15_r0_body.cws189.all (fun c => !PRE_first_tail_x15_r0_body.ws189.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ189 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws189 PRE_first_tail_x15_r0_body.crs189 PRE_first_tail_x15_r0_body.ws189

end Host.Load.Run.Tpl
end

section -- st189/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st189`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st189.wrR : List (Nat × Nat) := [(2672787, 2672788)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st189.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st189.s3.heap PRE_first_tail_x15_r0_body.st189.wrR ++ freshOf PRE_first_tail_x15_r0_body.st189.s3.heap PRE_first_tail_x15_r0_body.st189.s0.next PRE_first_tail_x15_r0_body.st189.s3.next
noncomputable def PRE_first_tail_x15_r0_body.st189.wr : List Nat := PRE_first_tail_x15_r0_body.st189.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st189.heapFoot : PRE_first_tail_x15_r0_body.st189.s3.heap = setAll PRE_first_tail_x15_r0_body.st189.s0.heap PRE_first_tail_x15_r0_body.st189.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st189.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st189.s0.next PRE_first_tail_x15_r0_body.st189.s3.next = true
theorem PRE_first_tail_x15_r0_body.st189.grows : PRE_first_tail_x15_r0_body.st189.s0.next ≤ PRE_first_tail_x15_r0_body.st189.s3.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st189.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st189.wh : List Nat := [21933, 21934, 21935, 21936, 21937, 21938]
def PRE_first_tail_x15_r0_body.st189.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st189.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st189.s3.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st189.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st189.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st189.s3.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st189.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st189.s3.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st189.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st189.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st189.s3.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st189.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st189.s3.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st189.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st189.s3.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st189.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st189.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st189.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st189.s3.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st189.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st189.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st189.s3.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st189.s3.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st189.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st189.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st189.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st189.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st189.s3.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st189.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st189.s3.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF189
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 189 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB189 : nodupT PRE_first_tail_x15_r0_body.st189.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup189 : PRE_first_tail_x15_r0_body.st189.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB189).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB189 : PRE_first_tail_x15_r0_body.st189.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound189 : ∀ b ∈ PRE_first_tail_x15_r0_body.st189.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB189 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr189 := PRE_first_tail_x15_r0_body.st189.s3.trace.take 26
kernel_rfl PRE_first_tail_x15_r0_body.traceEq189 : PRE_first_tail_x15_r0_body.st189.s3.trace = PRE_first_tail_x15_r0_body.trFr189 ++ PRE_first_tail_x15_r0_body.st189.s0.trace
theorem PRE_first_tail_x15_r0_body.trace189 : ∃ fr, PRE_first_tail_x15_r0_body.st189.s3.trace = fr ++ PRE_first_tail_x15_r0_body.st189.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq189⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide189 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB189 : (PRE_first_tail_x15_r0_body.wide189.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st189.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix189 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide189, WFix Map.id (Present PRE_first_tail_x15_r0_body.st189.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB189 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL189
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 189 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1828`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO189 : PRE_first_tail_x15_r0_body.st189.S0.oracle = PRE_first_tail_x15_r0_body.st189.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B189 : PRE_first_tail_x15_r0_body.st189.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st189.s0.next || (PRE_first_tail_x15_r0_body.st189.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot189 : Conv.StageFoot PRE_first_tail_x15_r0_body.st189.wr PRE_first_tail_x15_r0_body.st189.s0 PRE_first_tail_x15_r0_body.st189.s3 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st189.heapFoot PRE_first_tail_x15_r0_body.wrNodup189 PRE_first_tail_x15_r0_body.wrBound189 PRE_first_tail_x15_r0_body.wr0B189 PRE_first_tail_x15_r0_body.st189.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged189 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st189.F.S → PRE_first_tail_x15_r0_body.st189.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st189.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st189.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs189 PRE_first_tail_x15_r0_body.st189.wr PRE_first_tail_x15_r0_body.s1827 PRE_first_tail_x15_r0_body.st189.s3 PRE_first_tail_x15_r0_body.st189.s0
      PRE_first_tail_x15_r0_body.st189.s3.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st189.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1828 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso189 PRE_first_tail_x15_r0_body.stFoot189 PRE_first_tail_x15_r0_body.wrNodup189 PRE_first_tail_x15_r0_body.wrBound189 PRE_first_tail_x15_r0_body.trace189 PRE_first_tail_x15_r0_body.mheap189
    PRE_first_tail_x15_r0_body.mnext189 PRE_first_tail_x15_r0_body.mctl189 PRE_first_tail_x15_r0_body.mstack189 PRE_first_tail_x15_r0_body.mjobs189 PRE_first_tail_x15_r0_body.mffi189 PRE_first_tail_x15_r0_body.mtrace189 PRE_first_tail_x15_r0_body.mstores189 h

def PRE_first_tail_x15_r0_body.arrEl189_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE189_2665 : arrOf PRE_first_tail_x15_r0_body.s1828 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl189_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA189_2665 : isArrB PRE_first_tail_x15_r0_body.s1828 2665 = true
theorem PRE_first_tail_x15_r0_body.arr189_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1828.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl189_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE189_2665 PRE_first_tail_x15_r0_body.arrA189_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN189_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl189_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR189_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl189_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN189_2665

def PRE_first_tail_x15_r0_body.arrEl189_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE189_2673467 : arrOf PRE_first_tail_x15_r0_body.s1828 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl189_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA189_2673467 : isArrB PRE_first_tail_x15_r0_body.s1828 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr189_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1828.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl189_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE189_2673467 PRE_first_tail_x15_r0_body.arrA189_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN189_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl189_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR189_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl189_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN189_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k189 : isArrB PRE_first_tail_x15_r0_body.s1828 4910 = false
theorem PRE_first_tail_x15_r0_body.keep189 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1828 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k189 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr189_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl189_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ189
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 189 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1827`, the merged
state `PRE_first_tail_x15_r0_body.s1828`, the canonical state `PRE_first_tail_x15_r0_body.s1829`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl189 : PRE_first_tail_x15_r0_body.pl189.all (Nat.ble PRE_first_tail_x15_r0_body.s1827.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd189 : nodupT PRE_first_tail_x15_r0_body.pl189 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1189 : Nat.ble PRE_first_tail_x15_r0_body.s1827.next 2824133 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst189 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1827.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn189 : PRE_first_tail_x15_r0_body.s1829.next = PRE_first_tail_x15_r0_body.s1827.next + PRE_first_tail_x15_r0_body.pl189.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn189 : PRE_first_tail_x15_r0_body.s1828.next = 2824133
kernel_rfl PRE_first_tail_x15_r0_body.zgrow189 : Nat.ble PRE_first_tail_x15_r0_body.s1829.next PRE_first_tail_x15_r0_body.s1828.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh189 : PRE_first_tail_x15_r0_body.S1827.tab.all (fun e => PRE_first_tail_x15_r0_body.cws189.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd189 : nodupT PRE_first_tail_x15_r0_body.cws189 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi189 : PRE_first_tail_x15_r0_body.nr189.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1828.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt189 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1827.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg189_2665 : PRE_first_tail_x15_r0_body.s1829.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1829 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk189_2665 : (objOf PRE_first_tail_x15_r0_body.s1829 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm189_2665 : PRE_first_tail_x15_r0_body.s1828.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa189.obj (objOf PRE_first_tail_x15_r0_body.s1829 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1828 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg189_2673467 : PRE_first_tail_x15_r0_body.s1829.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1829 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk189_2673467 : (objOf PRE_first_tail_x15_r0_body.s1829 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm189_2673467 : PRE_first_tail_x15_r0_body.s1828.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa189.obj (objOf PRE_first_tail_x15_r0_body.s1829 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1828 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw189_4910 : (PRE_first_tail_x15_r0_body.s1829.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw189_2673472 : (PRE_first_tail_x15_r0_body.s1829.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw189_2673473 : (PRE_first_tail_x15_r0_body.s1829.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd189 : PRE_first_tail_x15_r0_body.cl189.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr189 : PRE_first_tail_x15_r0_body.st189.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1827.next || PRE_first_tail_x15_r0_body.cl189.contains b) = true
def PRE_first_tail_x15_r0_body.zl189 : List Nat := PRE_first_tail_x15_r0_body.cl189.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE189 : PRE_first_tail_x15_r0_body.zl189.map (fun a => PRE_first_tail_x15_r0_body.s1828.heap.get (PRE_first_tail_x15_r0_body.kappa189.a a)) = PRE_first_tail_x15_r0_body.zl189.map (fun a => (PRE_first_tail_x15_r0_body.s1829.heap.get a).map PRE_first_tail_x15_r0_body.kappa189.hobj)
theorem PRE_first_tail_x15_r0_body.zimg189 : HeapImg PRE_first_tail_x15_r0_body.kappa189 PRE_first_tail_x15_r0_body.s1829 PRE_first_tail_x15_r0_body.s1828 PRE_first_tail_x15_r0_body.zl189 := PRE_first_tail_x15_r0_body.zimgE189
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl189 : PRE_first_tail_x15_r0_body.s1828.ctl = PRE_first_tail_x15_r0_body.kappa189.ctl PRE_first_tail_x15_r0_body.s1829.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack189 : PRE_first_tail_x15_r0_body.s1828.stack = PRE_first_tail_x15_r0_body.s1829.stack.map PRE_first_tail_x15_r0_body.kappa189.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs189 : PRE_first_tail_x15_r0_body.s1828.jobs = PRE_first_tail_x15_r0_body.s1829.jobs.map PRE_first_tail_x15_r0_body.kappa189.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores189 : PRE_first_tail_x15_r0_body.s1828.stores = PRE_first_tail_x15_r0_body.kappa189.stores PRE_first_tail_x15_r0_body.s1829.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots189 : checkRootsSupp PRE_first_tail_x15_r0_body.s1829 8178 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC189 : PRE_first_tail_x15_r0_body.S1827.tab.length + PRE_first_tail_x15_r0_body.cws189.length = 8178
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap189 : PRE_first_tail_x15_r0_body.kappa189 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1827.next 2824133 PRE_first_tail_x15_r0_body.S1827.tab.length PRE_first_tail_x15_r0_body.pl189 (PRE_first_tail_x15_r0_body.nr189.map NumV.ref) PRE_first_tail_x15_r0_body.kd189.big
  PRE_first_tail_x15_r0_body.kd189.region PRE_first_tail_x15_r0_body.kd189.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin189 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1829.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc189 : Conv.jcleanListB (⟨21937, 19037, 2823783, 8178⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1829 PRE_first_tail_x15_r0_body.cl189 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB189 : noBigRootsP (fun i => !Conv.oldBigB (⟨21937, 19037, 2823783, 8178⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1829.trace PRE_first_tail_x15_r0_body.s1829 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm189 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 19031 = true
theorem PRE_first_tail_x15_r0_body.cjcl189 (h : Conv.JClean (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1827) : Conv.JClean (⟨21937, 19037, 2823783, 8178⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1829 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle189)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap189 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd189 a ha)) PRE_first_tail_x15_r0_body.zjc189

end Host.Load.Run.Tpl
end

section -- st189/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st189.bodyLast from PRE_first_tail_x15_r0_body.st189.s2 to PRE_first_tail_x15_r0_body.st189.s3 :
  interpS (step PRE_first_tail_x15_r0_body.st189.F PRE_first_tail_x15_r0_body.st189.s2).run PRE_first_tail_x15_r0_body.st189.S2 = some (PRE_first_tail_x15_r0_body.st189.s3, PRE_first_tail_x15_r0_body.st189.S3)
kernel_rfl PRE_first_tail_x15_r0_body.st189.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st189.s2.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st189.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st189.s3.stack = true

end Host.Load.Run.Tpl
end

section -- st189/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st189.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st189.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st189.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st189.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st189.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st189.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st189.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st189.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st189.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st189.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st189.s0 PRE_first_tail_x15_r0_body.st189.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st189.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st189.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st189.s2 PRE_first_tail_x15_r0_body.st189.S2) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st189/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st189.bodyK0F from PRE_first_tail_x15_r0_body.st189.s0 to PRE_first_tail_x15_r0_body.st189.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st189.F (PRE_first_tail_x15_r0_body.st189.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st189.ks 0).getD 0) PRE_first_tail_x15_r0_body.st189.s0 PRE_first_tail_x15_r0_body.st189.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st189.s1, PRE_first_tail_x15_r0_body.st189.S1)
theorem PRE_first_tail_x15_r0_body.st189.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st189.F (PRE_first_tail_x15_r0_body.st189.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st189.ks 0).getD 0) PRE_first_tail_x15_r0_body.st189.s0 PRE_first_tail_x15_r0_body.st189.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st189.s1, PRE_first_tail_x15_r0_body.st189.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st189.bodyOkLN_ok PRE_first_tail_x15_r0_body.st189.bodyK0F
end Host.Load.Run.Tpl
end

section -- st189/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st189.bodyK1F from PRE_first_tail_x15_r0_body.st189.s1 to PRE_first_tail_x15_r0_body.st189.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st189.F (PRE_first_tail_x15_r0_body.st189.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st189.ks 1).getD 0) PRE_first_tail_x15_r0_body.st189.s1 PRE_first_tail_x15_r0_body.st189.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st189.s2, PRE_first_tail_x15_r0_body.st189.S2)
theorem PRE_first_tail_x15_r0_body.st189.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st189.F (PRE_first_tail_x15_r0_body.st189.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st189.ks 1).getD 0) PRE_first_tail_x15_r0_body.st189.s1 PRE_first_tail_x15_r0_body.st189.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st189.s2, PRE_first_tail_x15_r0_body.st189.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st189.bodyOkLN_ok PRE_first_tail_x15_r0_body.st189.bodyK1F
end Host.Load.Run.Tpl
end

section -- st189/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st189.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st189.F (PRE_first_tail_x15_r0_body.st189.bodyOkL bytes rows) 3452 PRE_first_tail_x15_r0_body.st189.s0 PRE_first_tail_x15_r0_body.st189.S0 = some (PRE_first_tail_x15_r0_body.st189.s2, PRE_first_tail_x15_r0_body.st189.S2) :=
  runOk_trans PRE_first_tail_x15_r0_body.st189.F (PRE_first_tail_x15_r0_body.st189.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st189.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st189.ks 1).getD 0) PRE_first_tail_x15_r0_body.st189.s0 PRE_first_tail_x15_r0_body.st189.s1 PRE_first_tail_x15_r0_body.st189.s2 PRE_first_tail_x15_r0_body.st189.S0 PRE_first_tail_x15_r0_body.st189.S1 PRE_first_tail_x15_r0_body.st189.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st189.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st189.bodyK1 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st189.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st189.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st189.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st189.F (PRE_first_tail_x15_r0_body.st189.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st189.s0
  S0 := PRE_first_tail_x15_r0_body.st189.S0
  s1 := PRE_first_tail_x15_r0_body.st189.s2
  S1 := PRE_first_tail_x15_r0_body.st189.S2
  s2 := PRE_first_tail_x15_r0_body.st189.s3
  S2 := PRE_first_tail_x15_r0_body.st189.S3
  n := 3452
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st189.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st189.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st189.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st189.bodyHalt
  last := PRE_first_tail_x15_r0_body.st189.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st189.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC190
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 190 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1837` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa190` into the merged state
`PRE_first_tail_x15_r0_body.s1836`. -/

def PRE_first_tail_x15_r0_body.pl190 : List Nat := []
def PRE_first_tail_x15_r0_body.nr190 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd190 : RData :=
  ⟨2824365, 2824367, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21950, 21950, 19047, 19047, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa190 : Map :=
  Conv.Map.compact 2824365 2824367 8201 PRE_first_tail_x15_r0_body.pl190 (PRE_first_tail_x15_r0_body.nr190.map NumV.ref) PRE_first_tail_x15_r0_body.kd190.big
    PRE_first_tail_x15_r0_body.kd190.region PRE_first_tail_x15_r0_body.kd190.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws190 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs190 : List SymE := PRE_first_tail_x15_r0_body.nr190.map fun r => (nth? PRE_first_tail_x15_r0_body.S1836.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta190 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws190 PRE_first_tail_x15_r0_body.crs190
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB190 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab190 : PRE_first_tail_x15_r0_body.S1837.tab = PRE_first_tail_x15_r0_body.S1835.tab ++ PRE_first_tail_x15_r0_body.cws190.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace190 : PRE_first_tail_x15_r0_body.s1837.trace = PRE_first_tail_x15_r0_body.s1835.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext190 : PRE_first_tail_x15_r0_body.s1837.next = 2824365
kernel_rfl PRE_first_tail_x15_r0_body.ccounters190 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx.nnext) = (21950, 19047)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue190 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1836.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa190.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp190 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx.tokens.all (bSN 8201) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean190 : Conv.cleanListB 21950 131072 (fun r => Nat.ble 87800 r) PRE_first_tail_x15_r0_body.s1837
    (PRE_first_tail_x15_r0_body.wrB190 ++ (List.range 0).map (2824365 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs190 : bigsOutB 21950 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK190
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl190`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl190 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo190 : List Nat := []
def PRE_first_tail_x15_r0_body.cln190 : List Nat := []
def PRE_first_tail_x15_r0_body.cli190 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap190 : PRE_first_tail_x15_r0_body.s1837.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1835.heap (PRE_first_tail_x15_r0_body.cl190.filterMap fun a => (PRE_first_tail_x15_r0_body.s1837.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe190 : Nat.ble PRE_first_tail_x15_r0_body.s1835.next PRE_first_tail_x15_r0_body.s1837.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP190 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1835 PRE_first_tail_x15_r0_body.s1837 PRE_first_tail_x15_r0_body.cl190 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp190 : Conv.suppListB PRE_first_tail_x15_r0_body.s1837 8201 PRE_first_tail_x15_r0_body.cl190 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound190 : Conv.boundListB PRE_first_tail_x15_r0_body.s1837 PRE_first_tail_x15_r0_body.cl190 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK190 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln190.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK190 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo190.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK190 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli190.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst190 : Conv.sstListB 8201 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx PRE_first_tail_x15_r0_body.cln190 PRE_first_tail_x15_r0_body.clo190 PRE_first_tail_x15_r0_body.cli190 = true

end Host.Load.Run.Tpl
end

section -- SiteCl190
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA190 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo190.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd190 : (PRE_first_tail_x15_r0_body.clo190 ++ PRE_first_tail_x15_r0_body.cln190 ++ PRE_first_tail_x15_r0_body.cli190).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle190 : Conv.Cnt.leB (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck190 : Conv.ncleanListB (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx PRE_first_tail_x15_r0_body.clo190 PRE_first_tail_x15_r0_body.cln190 PRE_first_tail_x15_r0_body.cli190 = true
theorem PRE_first_tail_x15_r0_body.cncl190 (h : Conv.NClean (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx) : Conv.NClean (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle190 PRE_first_tail_x15_r0_body.ckA190 PRE_first_tail_x15_r0_body.cobjsK190 PRE_first_tail_x15_r0_body.cnodesK190 PRE_first_tail_x15_r0_body.citemsK190 PRE_first_tail_x15_r0_body.cbd190 PRE_first_tail_x15_r0_body.cck190

end Host.Load.Run.Tpl
end

section -- SiteS190
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 190 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc190 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P190 : LoadP := PRE_first_tail_x15_r0_body.Pc190.raise 19047
kernel_rfl PRE_first_tail_x15_r0_body.craise190 : Nat.ble PRE_first_tail_x15_r0_body.Pc190.N0 19047 = true
theorem PRE_first_tail_x15_r0_body.raised190 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc190 PRE_first_tail_x15_r0_body.P190 :=
  .inr ⟨19047, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise190, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_190 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_190 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1836.ffi)
def PRE_first_tail_x15_r0_body.khinv190 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv190 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS190 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS190 : List Nat := List.range' 19047 0
def PRE_first_tail_x15_r0_body.ciS190 : List Nat := [] ++ List.range' 19047 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0190 : PRE_first_tail_x15_r0_body.kd190.nh0 = PRE_first_tail_x15_r0_body.cx0_190.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1190 : PRE_first_tail_x15_r0_body.kd190.nh1 = PRE_first_tail_x15_r0_body.cx1_190.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0190 : PRE_first_tail_x15_r0_body.kd190.nn0 = PRE_first_tail_x15_r0_body.cx0_190.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1190 : PRE_first_tail_x15_r0_body.kd190.nn1 = PRE_first_tail_x15_r0_body.cx1_190.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo190 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P190.lo && Nat.ble PRE_first_tail_x15_r0_body.P190.lo PRE_first_tail_x15_r0_body.cx0_190.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P190.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P190.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt190 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_190.mlx.next PRE_first_tail_x15_r0_body.cx1_190.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_190.mlx.nnext PRE_first_tail_x15_r0_body.cx1_190.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband190 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P190.NL && Nat.ble PRE_first_tail_x15_r0_body.P190.NL PRE_first_tail_x15_r0_body.P190.N0 && Nat.ble PRE_first_tail_x15_r0_body.P190.N0 PRE_first_tail_x15_r0_body.cx0_190.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow190 : PRE_first_tail_x15_r0_body.kd190.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren190 : checkRenG PRE_first_tail_x15_r0_body.kd190.hnd PRE_first_tail_x15_r0_body.khinv190 (phB PRE_first_tail_x15_r0_body.cx0_190.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband190 : PRE_first_tail_x15_r0_body.kd190.checkBand PRE_first_tail_x15_r0_body.P190.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos190 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd190.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren190 : checkRenG PRE_first_tail_x15_r0_body.kd190.node PRE_first_tail_x15_r0_body.kninv190 (pnB PRE_first_tail_x15_r0_body.cx0_190.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow190 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd190.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P190.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd190.nodeF j) PRE_first_tail_x15_r0_body.cx1_190.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a190 : PRE_first_tail_x15_r0_body.cx0_190.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b190 : PRE_first_tail_x15_r0_body.cx0_190.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1190 : PRE_first_tail_x15_r0_body.cx1_190.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend190 : PRE_first_tail_x15_r0_body.cx1_190.mlx.pending = PRE_first_tail_x15_r0_body.cx0_190.mlx.pending.map PRE_first_tail_x15_r0_body.kappa190.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh190 : PRE_first_tail_x15_r0_body.cx1_190.mlx.errh = PRE_first_tail_x15_r0_body.cx0_190.mlx.errh.map PRE_first_tail_x15_r0_body.kappa190.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles190 : PRE_first_tail_x15_r0_body.cx1_190.mlx.files = PRE_first_tail_x15_r0_body.cx0_190.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch190 : PRE_first_tail_x15_r0_body.cx1_190.mlx.arch = PRE_first_tail_x15_r0_body.cx0_190.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes190 : PRE_first_tail_x15_r0_body.cx1_190.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_190.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired190 : PRE_first_tail_x15_r0_body.cx1_190.mlx.wired = PRE_first_tail_x15_r0_body.cx0_190.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost190 : PRE_first_tail_x15_r0_body.cx1_190.host = PRE_first_tail_x15_r0_body.cx0_190.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd190`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0190 : PRE_first_tail_x15_r0_body.kd190.n0 = 2824365
kernel_rfl PRE_first_tail_x15_r0_body.ckn1190 : PRE_first_tail_x15_r0_body.kd190.n1 = 2824367
kernel_rfl PRE_first_tail_x15_r0_body.ckheap190 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd190.heap).all (fun x => Nat.ble 2824365 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl190 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd190.heap.get (2824365 + j) = nth? PRE_first_tail_x15_r0_body.pl190 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja190 : Nat.ble 2824365 2824365 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn190 : Nat.ble 8201 8201 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD190 : Nat.ble 2824365 PRE_first_tail_x15_r0_body.kd190.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn190 : Nat.ble 21950 PRE_first_tail_x15_r0_body.kd190.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn190 : Nat.ble 19047 PRE_first_tail_x15_r0_body.kd190.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb190 : Nat.ble 21950 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap190 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd190.heap).all (Nat.ble (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd190 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd190.hnd).all (Nat.ble (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode190 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd190.node).all (Nat.ble (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix190 : Conv.FixOld (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa190 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja190) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn190) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD190) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn190) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn190) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb190) PRE_first_tail_x15_r0_body.fheap190 PRE_first_tail_x15_r0_body.fhnd190 PRE_first_tail_x15_r0_body.fnode190
kernel_rfl PRE_first_tail_x15_r0_body.fcxn190 : (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn190 : (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0190 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_190.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_190.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk190 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd190.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A190 : PRE_first_tail_x15_r0_body.cx1_190.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS190.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_190.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O190 : PRE_first_tail_x15_r0_body.cx1_190.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS190.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_190.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N190 : PRE_first_tail_x15_r0_body.cx1_190.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS190.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_190.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I190 : PRE_first_tail_x15_r0_body.cx1_190.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS190.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_190.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd190 : (PRE_first_tail_x15_r0_body.clo190 ++ PRE_first_tail_x15_r0_body.cln190 ++ PRE_first_tail_x15_r0_body.cli190 ++ PRE_first_tail_x15_r0_body.cwS190 ++ PRE_first_tail_x15_r0_body.cnS190 ++ PRE_first_tail_x15_r0_body.ciS190).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW190 : PRE_first_tail_x15_r0_body.cwS190.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo190.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI190 : PRE_first_tail_x15_r0_body.ciS190.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli190.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN190 : PRE_first_tail_x15_r0_body.cnS190.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF190 : PRE_first_tail_x15_r0_body.cln190.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh190 : PRE_first_tail_x15_r0_body.clo190.all (handleOK PRE_first_tail_x15_r0_body.kappa190 PRE_first_tail_x15_r0_body.P190.lo PRE_first_tail_x15_r0_body.cx0_190.mlx PRE_first_tail_x15_r0_body.cx1_190.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo190 : PRE_first_tail_x15_r0_body.clo190.map (fun h => PRE_first_tail_x15_r0_body.cx1_190.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa190.handle h)) = PRE_first_tail_x15_r0_body.clo190.map (fun h => (PRE_first_tail_x15_r0_body.cx0_190.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa190.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok190 : PRE_first_tail_x15_r0_body.clo190.all (objOK PRE_first_tail_x15_r0_body.kappa190 PRE_first_tail_x15_r0_body.P190.NL PRE_first_tail_x15_r0_body.cx0_190.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd190 : PRE_first_tail_x15_r0_body.cln190.all (nodeOKF PRE_first_tail_x15_r0_body.kappa190 PRE_first_tail_x15_r0_body.P190 PRE_first_tail_x15_r0_body.cx0_190.mlx PRE_first_tail_x15_r0_body.cx1_190.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp190 : ((PRE_first_tail_x15_r0_body.cln190.filter (fullB PRE_first_tail_x15_r0_body.P190))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_190.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa190.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln190.filter (fullB PRE_first_tail_x15_r0_body.P190))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_190.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa190.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI190 : incrB PRE_first_tail_x15_r0_body.kd190.nodeF (List.range' 19047 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK190 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd190.node).all (fun k => Nat.ble 19047 k && Nat.blt k 19047) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL190 : (PRE_first_tail_x15_r0_body.cln190.filter (Nat.ble PRE_first_tail_x15_r0_body.P190.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd190.nodeF i) && (Nat.blt i 19047 || Nat.ble PRE_first_tail_x15_r0_body.kd190.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord190 : (PRE_first_tail_x15_r0_body.cln190.filter (Nat.ble PRE_first_tail_x15_r0_body.P190.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd190.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd190.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd190.nodeF j) (PRE_first_tail_x15_r0_body.kd190.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow190 PRE_first_tail_x15_r0_body.cnn1190 PRE_first_tail_x15_r0_body.fnordI190 PRE_first_tail_x15_r0_body.fnordK190 PRE_first_tail_x15_r0_body.fnordL190
kernel_rfl PRE_first_tail_x15_r0_body.fi190 : PRE_first_tail_x15_r0_body.cli190.all (pnB PRE_first_tail_x15_r0_body.cx0_190.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii190 : PRE_first_tail_x15_r0_body.cli190.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_190.mlx.items.get (PRE_first_tail_x15_r0_body.kappa190.node k) = (PRE_first_tail_x15_r0_body.cx0_190.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa190.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot190 (clean : Conv.NClean (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P190.NL) (cl : SSt (· < 8201) PRE_first_tail_x15_r0_body.cx0_190.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P190 8201 PRE_first_tail_x15_r0_body.kappa190 PRE_first_tail_x15_r0_body.kd190 PRE_first_tail_x15_r0_body.khinv190 PRE_first_tail_x15_r0_body.kninv190 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx PRE_first_tail_x15_r0_body.cx0_190.mlx PRE_first_tail_x15_r0_body.cx1_190.mlx (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo190 PRE_first_tail_x15_r0_body.cln190 PRE_first_tail_x15_r0_body.cli190 PRE_first_tail_x15_r0_body.cwS190 PRE_first_tail_x15_r0_body.cnS190 PRE_first_tail_x15_r0_body.ciS190 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0190, PRE_first_tail_x15_r0_body.cnh1190, PRE_first_tail_x15_r0_body.cnn0190, PRE_first_tail_x15_r0_body.cnn1190, PRE_first_tail_x15_r0_body.cplo190, PRE_first_tail_x15_r0_body.ccnt190, PRE_first_tail_x15_r0_body.cnband190, PRE_first_tail_x15_r0_body.chbelow190, PRE_first_tail_x15_r0_body.chren190, PRE_first_tail_x15_r0_body.cband190, PRE_first_tail_x15_r0_body.cnh1pos190, PRE_first_tail_x15_r0_body.cnren190, PRE_first_tail_x15_r0_body.cnlow190, PRE_first_tail_x15_r0_body.cabs0a190, PRE_first_tail_x15_r0_body.cabs0b190, PRE_first_tail_x15_r0_body.ctok1190, PRE_first_tail_x15_r0_body.cpend190, PRE_first_tail_x15_r0_body.cerrh190, PRE_first_tail_x15_r0_body.cfiles190, PRE_first_tail_x15_r0_body.carch190, PRE_first_tail_x15_r0_body.csizes190, PRE_first_tail_x15_r0_body.cwired190, PRE_first_tail_x15_r0_body.cfix190, clean, PRE_first_tail_x15_r0_body.fcxn190, PRE_first_tail_x15_r0_body.fcnn190, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0190, PRE_first_tail_x15_r0_body.fnk190, PRE_first_tail_x15_r0_body.ckA190, PRE_first_tail_x15_r0_body.cobjsK190, PRE_first_tail_x15_r0_body.cnodesK190, PRE_first_tail_x15_r0_body.citemsK190, PRE_first_tail_x15_r0_body.f1A190, PRE_first_tail_x15_r0_body.f1O190, PRE_first_tail_x15_r0_body.f1N190, PRE_first_tail_x15_r0_body.f1I190, PRE_first_tail_x15_r0_body.fbd190, PRE_first_tail_x15_r0_body.fincW190, PRE_first_tail_x15_r0_body.fincI190, PRE_first_tail_x15_r0_body.fincN190, PRE_first_tail_x15_r0_body.flnF190, PRE_first_tail_x15_r0_body.fh190, PRE_first_tail_x15_r0_body.fo190, PRE_first_tail_x15_r0_body.fok190, PRE_first_tail_x15_r0_body.fnd190, PRE_first_tail_x15_r0_body.fp190, PRE_first_tail_x15_r0_body.fnord190, PRE_first_tail_x15_r0_body.fi190, PRE_first_tail_x15_r0_body.fii190⟩
theorem PRE_first_tail_x15_r0_body.cnshift190 (clean : Conv.NClean (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P190.NL) (cl : SSt (· < 8201) PRE_first_tail_x15_r0_body.cx0_190.mlx) : NShift PRE_first_tail_x15_r0_body.P190 8201 PRE_first_tail_x15_r0_body.kappa190 PRE_first_tail_x15_r0_body.cx0_190 PRE_first_tail_x15_r0_body.cx1_190 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot190 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost190 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0190 PRE_first_tail_x15_r0_body.ckn1190 PRE_first_tail_x15_r0_body.ckheap190 PRE_first_tail_x15_r0_body.ckpl190)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_190 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1835.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_190 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1835.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_190 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1835.ffi) = some PRE_first_tail_x15_r0_body.fxC_190
kernel_rfl PRE_first_tail_x15_r0_body.okrC_190 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1835.ffi) = some PRE_first_tail_x15_r0_body.krC_190
noncomputable def PRE_first_tail_x15_r0_body.fx0_190 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1837.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_190 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1837.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_190 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1837.ffi) = some PRE_first_tail_x15_r0_body.fx0_190
kernel_rfl PRE_first_tail_x15_r0_body.okr0_190 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1837.ffi) = some PRE_first_tail_x15_r0_body.kr0_190
noncomputable def PRE_first_tail_x15_r0_body.fx1_190 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1836.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_190 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1836.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_190 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1836.ffi) = some PRE_first_tail_x15_r0_body.fx1_190
kernel_rfl PRE_first_tail_x15_r0_body.okr1_190 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1836.ffi) = some PRE_first_tail_x15_r0_body.kr1_190
kernel_rfl PRE_first_tail_x15_r0_body.ff0190 : PRE_first_tail_x15_r0_body.fx0_190 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_190 (PRE_first_tail_x15_r0_body.clo190.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_190.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1190 : PRE_first_tail_x15_r0_body.fx1_190 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_190 (PRE_first_tail_x15_r0_body.cwS190.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_190.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck190 : freedLB PRE_first_tail_x15_r0_body.kappa190 PRE_first_tail_x15_r0_body.cx0_190.mlx PRE_first_tail_x15_r0_body.fx0_190 PRE_first_tail_x15_r0_body.fx1_190 PRE_first_tail_x15_r0_body.clo190 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0190 : PRE_first_tail_x15_r0_body.kr0_190.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_190.flags (PRE_first_tail_x15_r0_body.clo190.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_190.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0190 : PRE_first_tail_x15_r0_body.kr0_190.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_190.targs (PRE_first_tail_x15_r0_body.clo190.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_190.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1190 : PRE_first_tail_x15_r0_body.kr1_190.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_190.flags (PRE_first_tail_x15_r0_body.cwS190.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_190.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1190 : PRE_first_tail_x15_r0_body.kr1_190.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_190.targs (PRE_first_tail_x15_r0_body.cwS190.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_190.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck190 : krecLB PRE_first_tail_x15_r0_body.kappa190 8201 PRE_first_tail_x15_r0_body.cx0_190.mlx PRE_first_tail_x15_r0_body.kr0_190 PRE_first_tail_x15_r0_body.kr1_190 PRE_first_tail_x15_r0_body.clo190 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn190 : Nat.ble 8201 8201 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge190 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1836.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1837.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR190 : pendRegB PRE_first_tail_x15_r0_body.kappa190 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe190 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1836.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift190 (clean : Conv.NClean (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P190.NL) (cl : SSt (· < 8201) PRE_first_tail_x15_r0_body.cx0_190.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_190.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_190.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_190.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_190.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P190 8201 PRE_first_tail_x15_r0_body.kappa190 PRE_first_tail_x15_r0_body.s1837.ffi PRE_first_tail_x15_r0_body.s1836.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift190 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue190, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp190 t ht),
    PRE_first_tail_x15_r0_body.cbridge190,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1837.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1836.ffi) (PRE_first_tail_x15_r0_body.cfoot190 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_190 PRE_first_tail_x15_r0_body.ofx1_190 hobjC PRE_first_tail_x15_r0_body.ff0190 PRE_first_tail_x15_r0_body.ff1190 PRE_first_tail_x15_r0_body.ffck190,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1837.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1836.ffi) (PRE_first_tail_x15_r0_body.cfoot190 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_190 PRE_first_tail_x15_r0_body.okr1_190 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn190) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0190 PRE_first_tail_x15_r0_body.fkt0190 PRE_first_tail_x15_r0_body.fkf1190 PRE_first_tail_x15_r0_body.fkt1190 PRE_first_tail_x15_r0_body.fkck190,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0190 PRE_first_tail_x15_r0_body.cnh1190 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe190) PRE_first_tail_x15_r0_body.cpendR190⟩

end Host.Load.Run.Tpl
end

section -- st190/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st190 0
host_stream_state PRE_first_tail_x15_r0_body.st190 1
host_stream_state PRE_first_tail_x15_r0_body.st190 2
end Host.Load.Run.Tpl
end

section -- Site190
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 190 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g190__g191` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1835`, the merged state `PRE_first_tail_x15_r0_body.s1836`,
the site template `PRE_first_tail_x15_r0_body.st190` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1837`: the merge.
The footprint's facts are in `SiteF190`, the compaction's in `SiteC190`, `SiteK190`, `SiteNa190`, `SiteNb190`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso190 : PRE_first_tail_x15_r0_body.st190.s0 = { PRE_first_tail_x15_r0_body.s1835 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs190 : List Frame := PRE_first_tail_x15_r0_body.s1835.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_190 : PRE_first_tail_x15_r0_body.S1835.tab.length = 8201
kernel_rfl PRE_first_tail_x15_r0_body.tab0_190 : PRE_first_tail_x15_r0_body.st190.S0.tab = PRE_first_tail_x15_r0_body.S1835.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws190 : List Nat := [4227, 4228]
kernel_rfl PRE_first_tail_x15_r0_body.fresh190 : (PRE_first_tail_x15_r0_body.S1835.tab.all fun e => PRE_first_tail_x15_r0_body.ws190.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1835.oracle.all fun q => PRE_first_tail_x15_r0_body.ws190.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab190 : PRE_first_tail_x15_r0_body.S1836.tab = PRE_first_tail_x15_r0_body.S1835.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws190
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen190 : PRE_first_tail_x15_r0_body.st190.S2.tab.length - PRE_first_tail_x15_r0_body.st190.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged190`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap190 : PRE_first_tail_x15_r0_body.s1836.heap = PRE_first_tail_x15_r0_body.st190.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext190 : PRE_first_tail_x15_r0_body.s1836.next = PRE_first_tail_x15_r0_body.st190.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl190 : PRE_first_tail_x15_r0_body.s1836.ctl = PRE_first_tail_x15_r0_body.st190.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack190 : PRE_first_tail_x15_r0_body.s1836.stack = PRE_first_tail_x15_r0_body.st190.s2.stack ++ PRE_first_tail_x15_r0_body.s1835.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs190 : PRE_first_tail_x15_r0_body.s1836.jobs = PRE_first_tail_x15_r0_body.st190.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi190 : PRE_first_tail_x15_r0_body.s1836.ffi = PRE_first_tail_x15_r0_body.st190.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace190 : PRE_first_tail_x15_r0_body.s1836.trace = PRE_first_tail_x15_r0_body.st190.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores190 : PRE_first_tail_x15_r0_body.s1836.stores = PRE_first_tail_x15_r0_body.st190.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD190
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 190 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived190 : PRE_first_tail_x15_r0_body.nr190.map (fun r => nth? PRE_first_tail_x15_r0_body.st190.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo190 : PRE_first_tail_x15_r0_body.nr190.all (Nat.ble 8201) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj190 : PRE_first_tail_x15_r0_body.cws190.all (fun c => !PRE_first_tail_x15_r0_body.ws190.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ190 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws190 PRE_first_tail_x15_r0_body.crs190 PRE_first_tail_x15_r0_body.ws190

end Host.Load.Run.Tpl
end

section -- st190/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st190`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st190.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st190.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st190.s2.heap PRE_first_tail_x15_r0_body.st190.wrR ++ freshOf PRE_first_tail_x15_r0_body.st190.s2.heap PRE_first_tail_x15_r0_body.st190.s0.next PRE_first_tail_x15_r0_body.st190.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st190.wr : List Nat := PRE_first_tail_x15_r0_body.st190.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st190.heapFoot : PRE_first_tail_x15_r0_body.st190.s2.heap = setAll PRE_first_tail_x15_r0_body.st190.s0.heap PRE_first_tail_x15_r0_body.st190.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st190.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st190.s0.next PRE_first_tail_x15_r0_body.st190.s2.next = true
theorem PRE_first_tail_x15_r0_body.st190.grows : PRE_first_tail_x15_r0_body.st190.s0.next ≤ PRE_first_tail_x15_r0_body.st190.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st190.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st190.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st190.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st190.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st190.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st190.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st190.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st190.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st190.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st190.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st190.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st190.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st190.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st190.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st190.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st190.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st190.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st190.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st190.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st190.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st190.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st190.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st190.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st190.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st190.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st190.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st190.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st190.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st190.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st190.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st190.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st190.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF190
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 190 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB190 : nodupT PRE_first_tail_x15_r0_body.st190.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup190 : PRE_first_tail_x15_r0_body.st190.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB190).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB190 : PRE_first_tail_x15_r0_body.st190.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound190 : ∀ b ∈ PRE_first_tail_x15_r0_body.st190.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB190 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr190 := PRE_first_tail_x15_r0_body.st190.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq190 : PRE_first_tail_x15_r0_body.st190.s2.trace = PRE_first_tail_x15_r0_body.trFr190 ++ PRE_first_tail_x15_r0_body.st190.s0.trace
theorem PRE_first_tail_x15_r0_body.trace190 : ∃ fr, PRE_first_tail_x15_r0_body.st190.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st190.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq190⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide190 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB190 : (PRE_first_tail_x15_r0_body.wide190.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st190.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix190 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide190, WFix Map.id (Present PRE_first_tail_x15_r0_body.st190.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB190 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL190
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 190 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1836`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO190 : PRE_first_tail_x15_r0_body.st190.S0.oracle = PRE_first_tail_x15_r0_body.st190.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B190 : PRE_first_tail_x15_r0_body.st190.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st190.s0.next || (PRE_first_tail_x15_r0_body.st190.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot190 : Conv.StageFoot PRE_first_tail_x15_r0_body.st190.wr PRE_first_tail_x15_r0_body.st190.s0 PRE_first_tail_x15_r0_body.st190.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st190.heapFoot PRE_first_tail_x15_r0_body.wrNodup190 PRE_first_tail_x15_r0_body.wrBound190 PRE_first_tail_x15_r0_body.wr0B190 PRE_first_tail_x15_r0_body.st190.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged190 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st190.F.S → PRE_first_tail_x15_r0_body.st190.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st190.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st190.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs190 PRE_first_tail_x15_r0_body.st190.wr PRE_first_tail_x15_r0_body.s1835 PRE_first_tail_x15_r0_body.st190.s2 PRE_first_tail_x15_r0_body.st190.s0
      PRE_first_tail_x15_r0_body.st190.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st190.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1836 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso190 PRE_first_tail_x15_r0_body.stFoot190 PRE_first_tail_x15_r0_body.wrNodup190 PRE_first_tail_x15_r0_body.wrBound190 PRE_first_tail_x15_r0_body.trace190 PRE_first_tail_x15_r0_body.mheap190
    PRE_first_tail_x15_r0_body.mnext190 PRE_first_tail_x15_r0_body.mctl190 PRE_first_tail_x15_r0_body.mstack190 PRE_first_tail_x15_r0_body.mjobs190 PRE_first_tail_x15_r0_body.mffi190 PRE_first_tail_x15_r0_body.mtrace190 PRE_first_tail_x15_r0_body.mstores190 h

def PRE_first_tail_x15_r0_body.arrEl190_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE190_2665 : arrOf PRE_first_tail_x15_r0_body.s1836 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl190_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA190_2665 : isArrB PRE_first_tail_x15_r0_body.s1836 2665 = true
theorem PRE_first_tail_x15_r0_body.arr190_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1836.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl190_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE190_2665 PRE_first_tail_x15_r0_body.arrA190_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN190_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl190_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR190_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl190_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN190_2665

def PRE_first_tail_x15_r0_body.arrEl190_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE190_2673467 : arrOf PRE_first_tail_x15_r0_body.s1836 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl190_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA190_2673467 : isArrB PRE_first_tail_x15_r0_body.s1836 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr190_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1836.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl190_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE190_2673467 PRE_first_tail_x15_r0_body.arrA190_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN190_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl190_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR190_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl190_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN190_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k190 : isArrB PRE_first_tail_x15_r0_body.s1836 4910 = false
theorem PRE_first_tail_x15_r0_body.keep190 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1836 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k190 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr190_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl190_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ190
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 190 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1835`, the merged
state `PRE_first_tail_x15_r0_body.s1836`, the canonical state `PRE_first_tail_x15_r0_body.s1837`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl190 : PRE_first_tail_x15_r0_body.pl190.all (Nat.ble PRE_first_tail_x15_r0_body.s1835.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd190 : nodupT PRE_first_tail_x15_r0_body.pl190 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1190 : Nat.ble PRE_first_tail_x15_r0_body.s1835.next 2824367 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst190 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1835.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn190 : PRE_first_tail_x15_r0_body.s1837.next = PRE_first_tail_x15_r0_body.s1835.next + PRE_first_tail_x15_r0_body.pl190.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn190 : PRE_first_tail_x15_r0_body.s1836.next = 2824367
kernel_rfl PRE_first_tail_x15_r0_body.zgrow190 : Nat.ble PRE_first_tail_x15_r0_body.s1837.next PRE_first_tail_x15_r0_body.s1836.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh190 : PRE_first_tail_x15_r0_body.S1835.tab.all (fun e => PRE_first_tail_x15_r0_body.cws190.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd190 : nodupT PRE_first_tail_x15_r0_body.cws190 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi190 : PRE_first_tail_x15_r0_body.nr190.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1836.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt190 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1835.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg190_2665 : PRE_first_tail_x15_r0_body.s1837.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1837 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk190_2665 : (objOf PRE_first_tail_x15_r0_body.s1837 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm190_2665 : PRE_first_tail_x15_r0_body.s1836.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa190.obj (objOf PRE_first_tail_x15_r0_body.s1837 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1836 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg190_2673467 : PRE_first_tail_x15_r0_body.s1837.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1837 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk190_2673467 : (objOf PRE_first_tail_x15_r0_body.s1837 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm190_2673467 : PRE_first_tail_x15_r0_body.s1836.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa190.obj (objOf PRE_first_tail_x15_r0_body.s1837 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1836 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw190_4910 : (PRE_first_tail_x15_r0_body.s1837.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw190_2673472 : (PRE_first_tail_x15_r0_body.s1837.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw190_2673473 : (PRE_first_tail_x15_r0_body.s1837.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd190 : PRE_first_tail_x15_r0_body.cl190.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr190 : PRE_first_tail_x15_r0_body.st190.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1835.next || PRE_first_tail_x15_r0_body.cl190.contains b) = true
def PRE_first_tail_x15_r0_body.zl190 : List Nat := PRE_first_tail_x15_r0_body.cl190.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE190 : PRE_first_tail_x15_r0_body.zl190.map (fun a => PRE_first_tail_x15_r0_body.s1836.heap.get (PRE_first_tail_x15_r0_body.kappa190.a a)) = PRE_first_tail_x15_r0_body.zl190.map (fun a => (PRE_first_tail_x15_r0_body.s1837.heap.get a).map PRE_first_tail_x15_r0_body.kappa190.hobj)
theorem PRE_first_tail_x15_r0_body.zimg190 : HeapImg PRE_first_tail_x15_r0_body.kappa190 PRE_first_tail_x15_r0_body.s1837 PRE_first_tail_x15_r0_body.s1836 PRE_first_tail_x15_r0_body.zl190 := PRE_first_tail_x15_r0_body.zimgE190
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl190 : PRE_first_tail_x15_r0_body.s1836.ctl = PRE_first_tail_x15_r0_body.kappa190.ctl PRE_first_tail_x15_r0_body.s1837.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack190 : PRE_first_tail_x15_r0_body.s1836.stack = PRE_first_tail_x15_r0_body.s1837.stack.map PRE_first_tail_x15_r0_body.kappa190.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs190 : PRE_first_tail_x15_r0_body.s1836.jobs = PRE_first_tail_x15_r0_body.s1837.jobs.map PRE_first_tail_x15_r0_body.kappa190.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores190 : PRE_first_tail_x15_r0_body.s1836.stores = PRE_first_tail_x15_r0_body.kappa190.stores PRE_first_tail_x15_r0_body.s1837.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots190 : checkRootsSupp PRE_first_tail_x15_r0_body.s1837 8201 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC190 : PRE_first_tail_x15_r0_body.S1835.tab.length + PRE_first_tail_x15_r0_body.cws190.length = 8201
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap190 : PRE_first_tail_x15_r0_body.kappa190 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1835.next 2824367 PRE_first_tail_x15_r0_body.S1835.tab.length PRE_first_tail_x15_r0_body.pl190 (PRE_first_tail_x15_r0_body.nr190.map NumV.ref) PRE_first_tail_x15_r0_body.kd190.big
  PRE_first_tail_x15_r0_body.kd190.region PRE_first_tail_x15_r0_body.kd190.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin190 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1837.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc190 : Conv.jcleanListB (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1837 PRE_first_tail_x15_r0_body.cl190 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB190 : noBigRootsP (fun i => !Conv.oldBigB (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1837.trace PRE_first_tail_x15_r0_body.s1837 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm190 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 19047 = true
theorem PRE_first_tail_x15_r0_body.cjcl190 (h : Conv.JClean (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1835) : Conv.JClean (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1837 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle190)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap190 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd190 a ha)) PRE_first_tail_x15_r0_body.zjc190

end Host.Load.Run.Tpl
end

section -- st190/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st190.bodyLast from PRE_first_tail_x15_r0_body.st190.s1 to PRE_first_tail_x15_r0_body.st190.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st190.F PRE_first_tail_x15_r0_body.st190.s1).run PRE_first_tail_x15_r0_body.st190.S1 = some (PRE_first_tail_x15_r0_body.st190.s2, PRE_first_tail_x15_r0_body.st190.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st190.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st190.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st190.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st190.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st190/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st190.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st190.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st190.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st190.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st190.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st190.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st190.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st190.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st190.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st190.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st190.s0 PRE_first_tail_x15_r0_body.st190.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st190.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st190.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st190.s1 PRE_first_tail_x15_r0_body.st190.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st190/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st190.bodyK0F from PRE_first_tail_x15_r0_body.st190.s0 to PRE_first_tail_x15_r0_body.st190.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st190.F (PRE_first_tail_x15_r0_body.st190.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st190.ks 0).getD 0) PRE_first_tail_x15_r0_body.st190.s0 PRE_first_tail_x15_r0_body.st190.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st190.s1, PRE_first_tail_x15_r0_body.st190.S1)
theorem PRE_first_tail_x15_r0_body.st190.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st190.F (PRE_first_tail_x15_r0_body.st190.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st190.ks 0).getD 0) PRE_first_tail_x15_r0_body.st190.s0 PRE_first_tail_x15_r0_body.st190.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st190.s1, PRE_first_tail_x15_r0_body.st190.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st190.bodyOkLN_ok PRE_first_tail_x15_r0_body.st190.bodyK0F
end Host.Load.Run.Tpl
end

section -- st190/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st190.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st190.F (PRE_first_tail_x15_r0_body.st190.bodyOkL bytes rows) 27 PRE_first_tail_x15_r0_body.st190.s0 PRE_first_tail_x15_r0_body.st190.S0 = some (PRE_first_tail_x15_r0_body.st190.s1, PRE_first_tail_x15_r0_body.st190.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st190.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st190.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st190.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st190.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st190.F (PRE_first_tail_x15_r0_body.st190.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st190.s0
  S0 := PRE_first_tail_x15_r0_body.st190.S0
  s1 := PRE_first_tail_x15_r0_body.st190.s1
  S1 := PRE_first_tail_x15_r0_body.st190.S1
  s2 := PRE_first_tail_x15_r0_body.st190.s2
  S2 := PRE_first_tail_x15_r0_body.st190.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st190.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st190.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st190.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st190.bodyHalt
  last := PRE_first_tail_x15_r0_body.st190.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st190.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC191
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 191 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1841` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa191` into the merged state
`PRE_first_tail_x15_r0_body.s1840`. -/

def PRE_first_tail_x15_r0_body.pl191 : List Nat := [2824663]
def PRE_first_tail_x15_r0_body.nr191 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd191 : RData :=
  ⟨2824654, 2824664, Stage.setAll PTrie.nil [(2824653, 2824663)], Stage.setAll PTrie.nil [],
   21957, 21957, 19051, 19051, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa191 : Map :=
  Conv.Map.compact 2824653 2824664 8218 PRE_first_tail_x15_r0_body.pl191 (PRE_first_tail_x15_r0_body.nr191.map NumV.ref) PRE_first_tail_x15_r0_body.kd191.big
    PRE_first_tail_x15_r0_body.kd191.region PRE_first_tail_x15_r0_body.kd191.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws191 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs191 : List SymE := PRE_first_tail_x15_r0_body.nr191.map fun r => (nth? PRE_first_tail_x15_r0_body.S1840.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta191 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws191 PRE_first_tail_x15_r0_body.crs191
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB191 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab191 : PRE_first_tail_x15_r0_body.S1841.tab = PRE_first_tail_x15_r0_body.S1839.tab ++ PRE_first_tail_x15_r0_body.cws191.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace191 : PRE_first_tail_x15_r0_body.s1841.trace = PRE_first_tail_x15_r0_body.s1839.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext191 : PRE_first_tail_x15_r0_body.s1841.next = 2824654
kernel_rfl PRE_first_tail_x15_r0_body.ccounters191 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx.nnext) = (21957, 19051)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue191 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1840.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa191.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp191 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx.tokens.all (bSN 8218) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean191 : Conv.cleanListB 21957 131072 (fun r => Nat.ble 87828 r) PRE_first_tail_x15_r0_body.s1841
    (PRE_first_tail_x15_r0_body.wrB191 ++ (List.range 1).map (2824653 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs191 : bigsOutB 21957 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK191
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl191`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl191 : List Nat := [2665, 2673467, 2824653]
def PRE_first_tail_x15_r0_body.clo191 : List Nat := []
def PRE_first_tail_x15_r0_body.cln191 : List Nat := []
def PRE_first_tail_x15_r0_body.cli191 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap191 : PRE_first_tail_x15_r0_body.s1841.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1839.heap (PRE_first_tail_x15_r0_body.cl191.filterMap fun a => (PRE_first_tail_x15_r0_body.s1841.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe191 : Nat.ble PRE_first_tail_x15_r0_body.s1839.next PRE_first_tail_x15_r0_body.s1841.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP191 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1839 PRE_first_tail_x15_r0_body.s1841 PRE_first_tail_x15_r0_body.cl191 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp191 : Conv.suppListB PRE_first_tail_x15_r0_body.s1841 8218 PRE_first_tail_x15_r0_body.cl191 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound191 : Conv.boundListB PRE_first_tail_x15_r0_body.s1841 PRE_first_tail_x15_r0_body.cl191 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK191 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln191.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK191 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo191.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK191 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli191.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst191 : Conv.sstListB 8218 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx PRE_first_tail_x15_r0_body.cln191 PRE_first_tail_x15_r0_body.clo191 PRE_first_tail_x15_r0_body.cli191 = true

end Host.Load.Run.Tpl
end

section -- SiteCl191
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA191 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo191.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd191 : (PRE_first_tail_x15_r0_body.clo191 ++ PRE_first_tail_x15_r0_body.cln191 ++ PRE_first_tail_x15_r0_body.cli191).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle191 : Conv.Cnt.leB (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt) (⟨21957, 19051, 2824654, 8218⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck191 : Conv.ncleanListB (⟨21957, 19051, 2824654, 8218⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx PRE_first_tail_x15_r0_body.clo191 PRE_first_tail_x15_r0_body.cln191 PRE_first_tail_x15_r0_body.cli191 = true
theorem PRE_first_tail_x15_r0_body.cncl191 (h : Conv.NClean (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx) : Conv.NClean (⟨21957, 19051, 2824654, 8218⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle191 PRE_first_tail_x15_r0_body.ckA191 PRE_first_tail_x15_r0_body.cobjsK191 PRE_first_tail_x15_r0_body.cnodesK191 PRE_first_tail_x15_r0_body.citemsK191 PRE_first_tail_x15_r0_body.cbd191 PRE_first_tail_x15_r0_body.cck191

end Host.Load.Run.Tpl
end

section -- SiteS191
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 191 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc191 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P191 : LoadP := PRE_first_tail_x15_r0_body.Pc191.raise 19051
kernel_rfl PRE_first_tail_x15_r0_body.craise191 : Nat.ble PRE_first_tail_x15_r0_body.Pc191.N0 19051 = true
theorem PRE_first_tail_x15_r0_body.raised191 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc191 PRE_first_tail_x15_r0_body.P191 :=
  .inr ⟨19051, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise191, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_191 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_191 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1840.ffi)
def PRE_first_tail_x15_r0_body.khinv191 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv191 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS191 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS191 : List Nat := List.range' 19051 0
def PRE_first_tail_x15_r0_body.ciS191 : List Nat := [] ++ List.range' 19051 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0191 : PRE_first_tail_x15_r0_body.kd191.nh0 = PRE_first_tail_x15_r0_body.cx0_191.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1191 : PRE_first_tail_x15_r0_body.kd191.nh1 = PRE_first_tail_x15_r0_body.cx1_191.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0191 : PRE_first_tail_x15_r0_body.kd191.nn0 = PRE_first_tail_x15_r0_body.cx0_191.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1191 : PRE_first_tail_x15_r0_body.kd191.nn1 = PRE_first_tail_x15_r0_body.cx1_191.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo191 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P191.lo && Nat.ble PRE_first_tail_x15_r0_body.P191.lo PRE_first_tail_x15_r0_body.cx0_191.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P191.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P191.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt191 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_191.mlx.next PRE_first_tail_x15_r0_body.cx1_191.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_191.mlx.nnext PRE_first_tail_x15_r0_body.cx1_191.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband191 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P191.NL && Nat.ble PRE_first_tail_x15_r0_body.P191.NL PRE_first_tail_x15_r0_body.P191.N0 && Nat.ble PRE_first_tail_x15_r0_body.P191.N0 PRE_first_tail_x15_r0_body.cx0_191.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow191 : PRE_first_tail_x15_r0_body.kd191.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren191 : checkRenG PRE_first_tail_x15_r0_body.kd191.hnd PRE_first_tail_x15_r0_body.khinv191 (phB PRE_first_tail_x15_r0_body.cx0_191.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband191 : PRE_first_tail_x15_r0_body.kd191.checkBand PRE_first_tail_x15_r0_body.P191.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos191 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd191.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren191 : checkRenG PRE_first_tail_x15_r0_body.kd191.node PRE_first_tail_x15_r0_body.kninv191 (pnB PRE_first_tail_x15_r0_body.cx0_191.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow191 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd191.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P191.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd191.nodeF j) PRE_first_tail_x15_r0_body.cx1_191.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a191 : PRE_first_tail_x15_r0_body.cx0_191.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b191 : PRE_first_tail_x15_r0_body.cx0_191.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1191 : PRE_first_tail_x15_r0_body.cx1_191.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend191 : PRE_first_tail_x15_r0_body.cx1_191.mlx.pending = PRE_first_tail_x15_r0_body.cx0_191.mlx.pending.map PRE_first_tail_x15_r0_body.kappa191.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh191 : PRE_first_tail_x15_r0_body.cx1_191.mlx.errh = PRE_first_tail_x15_r0_body.cx0_191.mlx.errh.map PRE_first_tail_x15_r0_body.kappa191.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles191 : PRE_first_tail_x15_r0_body.cx1_191.mlx.files = PRE_first_tail_x15_r0_body.cx0_191.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch191 : PRE_first_tail_x15_r0_body.cx1_191.mlx.arch = PRE_first_tail_x15_r0_body.cx0_191.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes191 : PRE_first_tail_x15_r0_body.cx1_191.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_191.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired191 : PRE_first_tail_x15_r0_body.cx1_191.mlx.wired = PRE_first_tail_x15_r0_body.cx0_191.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost191 : PRE_first_tail_x15_r0_body.cx1_191.host = PRE_first_tail_x15_r0_body.cx0_191.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd191`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0191 : PRE_first_tail_x15_r0_body.kd191.n0 = 2824654
kernel_rfl PRE_first_tail_x15_r0_body.ckn1191 : PRE_first_tail_x15_r0_body.kd191.n1 = 2824664
kernel_rfl PRE_first_tail_x15_r0_body.ckheap191 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd191.heap).all (fun x => Nat.ble 2824653 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl191 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd191.heap.get (2824653 + j) = nth? PRE_first_tail_x15_r0_body.pl191 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja191 : Nat.ble 2824653 2824653 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn191 : Nat.ble 8218 8218 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD191 : Nat.ble 2824653 PRE_first_tail_x15_r0_body.kd191.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn191 : Nat.ble 21957 PRE_first_tail_x15_r0_body.kd191.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn191 : Nat.ble 19051 PRE_first_tail_x15_r0_body.kd191.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb191 : Nat.ble 21957 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap191 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd191.heap).all (Nat.ble (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd191 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd191.hnd).all (Nat.ble (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode191 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd191.node).all (Nat.ble (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix191 : Conv.FixOld (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa191 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja191) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn191) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD191) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn191) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn191) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb191) PRE_first_tail_x15_r0_body.fheap191 PRE_first_tail_x15_r0_body.fhnd191 PRE_first_tail_x15_r0_body.fnode191
kernel_rfl PRE_first_tail_x15_r0_body.fcxn191 : (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn191 : (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0191 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_191.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_191.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk191 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd191.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A191 : PRE_first_tail_x15_r0_body.cx1_191.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS191.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_191.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O191 : PRE_first_tail_x15_r0_body.cx1_191.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS191.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_191.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N191 : PRE_first_tail_x15_r0_body.cx1_191.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS191.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_191.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I191 : PRE_first_tail_x15_r0_body.cx1_191.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS191.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_191.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd191 : (PRE_first_tail_x15_r0_body.clo191 ++ PRE_first_tail_x15_r0_body.cln191 ++ PRE_first_tail_x15_r0_body.cli191 ++ PRE_first_tail_x15_r0_body.cwS191 ++ PRE_first_tail_x15_r0_body.cnS191 ++ PRE_first_tail_x15_r0_body.ciS191).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW191 : PRE_first_tail_x15_r0_body.cwS191.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo191.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI191 : PRE_first_tail_x15_r0_body.ciS191.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli191.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN191 : PRE_first_tail_x15_r0_body.cnS191.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF191 : PRE_first_tail_x15_r0_body.cln191.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh191 : PRE_first_tail_x15_r0_body.clo191.all (handleOK PRE_first_tail_x15_r0_body.kappa191 PRE_first_tail_x15_r0_body.P191.lo PRE_first_tail_x15_r0_body.cx0_191.mlx PRE_first_tail_x15_r0_body.cx1_191.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo191 : PRE_first_tail_x15_r0_body.clo191.map (fun h => PRE_first_tail_x15_r0_body.cx1_191.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa191.handle h)) = PRE_first_tail_x15_r0_body.clo191.map (fun h => (PRE_first_tail_x15_r0_body.cx0_191.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa191.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok191 : PRE_first_tail_x15_r0_body.clo191.all (objOK PRE_first_tail_x15_r0_body.kappa191 PRE_first_tail_x15_r0_body.P191.NL PRE_first_tail_x15_r0_body.cx0_191.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd191 : PRE_first_tail_x15_r0_body.cln191.all (nodeOKF PRE_first_tail_x15_r0_body.kappa191 PRE_first_tail_x15_r0_body.P191 PRE_first_tail_x15_r0_body.cx0_191.mlx PRE_first_tail_x15_r0_body.cx1_191.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp191 : ((PRE_first_tail_x15_r0_body.cln191.filter (fullB PRE_first_tail_x15_r0_body.P191))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_191.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa191.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln191.filter (fullB PRE_first_tail_x15_r0_body.P191))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_191.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa191.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI191 : incrB PRE_first_tail_x15_r0_body.kd191.nodeF (List.range' 19051 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK191 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd191.node).all (fun k => Nat.ble 19051 k && Nat.blt k 19051) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL191 : (PRE_first_tail_x15_r0_body.cln191.filter (Nat.ble PRE_first_tail_x15_r0_body.P191.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd191.nodeF i) && (Nat.blt i 19051 || Nat.ble PRE_first_tail_x15_r0_body.kd191.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord191 : (PRE_first_tail_x15_r0_body.cln191.filter (Nat.ble PRE_first_tail_x15_r0_body.P191.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd191.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd191.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd191.nodeF j) (PRE_first_tail_x15_r0_body.kd191.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow191 PRE_first_tail_x15_r0_body.cnn1191 PRE_first_tail_x15_r0_body.fnordI191 PRE_first_tail_x15_r0_body.fnordK191 PRE_first_tail_x15_r0_body.fnordL191
kernel_rfl PRE_first_tail_x15_r0_body.fi191 : PRE_first_tail_x15_r0_body.cli191.all (pnB PRE_first_tail_x15_r0_body.cx0_191.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii191 : PRE_first_tail_x15_r0_body.cli191.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_191.mlx.items.get (PRE_first_tail_x15_r0_body.kappa191.node k) = (PRE_first_tail_x15_r0_body.cx0_191.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa191.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot191 (clean : Conv.NClean (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P191.NL) (cl : SSt (· < 8218) PRE_first_tail_x15_r0_body.cx0_191.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P191 8218 PRE_first_tail_x15_r0_body.kappa191 PRE_first_tail_x15_r0_body.kd191 PRE_first_tail_x15_r0_body.khinv191 PRE_first_tail_x15_r0_body.kninv191 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx PRE_first_tail_x15_r0_body.cx0_191.mlx PRE_first_tail_x15_r0_body.cx1_191.mlx (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo191 PRE_first_tail_x15_r0_body.cln191 PRE_first_tail_x15_r0_body.cli191 PRE_first_tail_x15_r0_body.cwS191 PRE_first_tail_x15_r0_body.cnS191 PRE_first_tail_x15_r0_body.ciS191 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0191, PRE_first_tail_x15_r0_body.cnh1191, PRE_first_tail_x15_r0_body.cnn0191, PRE_first_tail_x15_r0_body.cnn1191, PRE_first_tail_x15_r0_body.cplo191, PRE_first_tail_x15_r0_body.ccnt191, PRE_first_tail_x15_r0_body.cnband191, PRE_first_tail_x15_r0_body.chbelow191, PRE_first_tail_x15_r0_body.chren191, PRE_first_tail_x15_r0_body.cband191, PRE_first_tail_x15_r0_body.cnh1pos191, PRE_first_tail_x15_r0_body.cnren191, PRE_first_tail_x15_r0_body.cnlow191, PRE_first_tail_x15_r0_body.cabs0a191, PRE_first_tail_x15_r0_body.cabs0b191, PRE_first_tail_x15_r0_body.ctok1191, PRE_first_tail_x15_r0_body.cpend191, PRE_first_tail_x15_r0_body.cerrh191, PRE_first_tail_x15_r0_body.cfiles191, PRE_first_tail_x15_r0_body.carch191, PRE_first_tail_x15_r0_body.csizes191, PRE_first_tail_x15_r0_body.cwired191, PRE_first_tail_x15_r0_body.cfix191, clean, PRE_first_tail_x15_r0_body.fcxn191, PRE_first_tail_x15_r0_body.fcnn191, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0191, PRE_first_tail_x15_r0_body.fnk191, PRE_first_tail_x15_r0_body.ckA191, PRE_first_tail_x15_r0_body.cobjsK191, PRE_first_tail_x15_r0_body.cnodesK191, PRE_first_tail_x15_r0_body.citemsK191, PRE_first_tail_x15_r0_body.f1A191, PRE_first_tail_x15_r0_body.f1O191, PRE_first_tail_x15_r0_body.f1N191, PRE_first_tail_x15_r0_body.f1I191, PRE_first_tail_x15_r0_body.fbd191, PRE_first_tail_x15_r0_body.fincW191, PRE_first_tail_x15_r0_body.fincI191, PRE_first_tail_x15_r0_body.fincN191, PRE_first_tail_x15_r0_body.flnF191, PRE_first_tail_x15_r0_body.fh191, PRE_first_tail_x15_r0_body.fo191, PRE_first_tail_x15_r0_body.fok191, PRE_first_tail_x15_r0_body.fnd191, PRE_first_tail_x15_r0_body.fp191, PRE_first_tail_x15_r0_body.fnord191, PRE_first_tail_x15_r0_body.fi191, PRE_first_tail_x15_r0_body.fii191⟩
theorem PRE_first_tail_x15_r0_body.cnshift191 (clean : Conv.NClean (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P191.NL) (cl : SSt (· < 8218) PRE_first_tail_x15_r0_body.cx0_191.mlx) : NShift PRE_first_tail_x15_r0_body.P191 8218 PRE_first_tail_x15_r0_body.kappa191 PRE_first_tail_x15_r0_body.cx0_191 PRE_first_tail_x15_r0_body.cx1_191 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot191 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost191 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0191 PRE_first_tail_x15_r0_body.ckn1191 PRE_first_tail_x15_r0_body.ckheap191 PRE_first_tail_x15_r0_body.ckpl191)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_191 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1839.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_191 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1839.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_191 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1839.ffi) = some PRE_first_tail_x15_r0_body.fxC_191
kernel_rfl PRE_first_tail_x15_r0_body.okrC_191 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1839.ffi) = some PRE_first_tail_x15_r0_body.krC_191
noncomputable def PRE_first_tail_x15_r0_body.fx0_191 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1841.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_191 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1841.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_191 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1841.ffi) = some PRE_first_tail_x15_r0_body.fx0_191
kernel_rfl PRE_first_tail_x15_r0_body.okr0_191 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1841.ffi) = some PRE_first_tail_x15_r0_body.kr0_191
noncomputable def PRE_first_tail_x15_r0_body.fx1_191 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1840.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_191 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1840.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_191 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1840.ffi) = some PRE_first_tail_x15_r0_body.fx1_191
kernel_rfl PRE_first_tail_x15_r0_body.okr1_191 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1840.ffi) = some PRE_first_tail_x15_r0_body.kr1_191
kernel_rfl PRE_first_tail_x15_r0_body.ff0191 : PRE_first_tail_x15_r0_body.fx0_191 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_191 (PRE_first_tail_x15_r0_body.clo191.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_191.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1191 : PRE_first_tail_x15_r0_body.fx1_191 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_191 (PRE_first_tail_x15_r0_body.cwS191.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_191.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck191 : freedLB PRE_first_tail_x15_r0_body.kappa191 PRE_first_tail_x15_r0_body.cx0_191.mlx PRE_first_tail_x15_r0_body.fx0_191 PRE_first_tail_x15_r0_body.fx1_191 PRE_first_tail_x15_r0_body.clo191 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0191 : PRE_first_tail_x15_r0_body.kr0_191.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_191.flags (PRE_first_tail_x15_r0_body.clo191.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_191.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0191 : PRE_first_tail_x15_r0_body.kr0_191.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_191.targs (PRE_first_tail_x15_r0_body.clo191.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_191.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1191 : PRE_first_tail_x15_r0_body.kr1_191.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_191.flags (PRE_first_tail_x15_r0_body.cwS191.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_191.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1191 : PRE_first_tail_x15_r0_body.kr1_191.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_191.targs (PRE_first_tail_x15_r0_body.cwS191.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_191.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck191 : krecLB PRE_first_tail_x15_r0_body.kappa191 8218 PRE_first_tail_x15_r0_body.cx0_191.mlx PRE_first_tail_x15_r0_body.kr0_191 PRE_first_tail_x15_r0_body.kr1_191 PRE_first_tail_x15_r0_body.clo191 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn191 : Nat.ble 8218 8218 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge191 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1840.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1841.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR191 : pendRegB PRE_first_tail_x15_r0_body.kappa191 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe191 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1840.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift191 (clean : Conv.NClean (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P191.NL) (cl : SSt (· < 8218) PRE_first_tail_x15_r0_body.cx0_191.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_191.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_191.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_191.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_191.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P191 8218 PRE_first_tail_x15_r0_body.kappa191 PRE_first_tail_x15_r0_body.s1841.ffi PRE_first_tail_x15_r0_body.s1840.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift191 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue191, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp191 t ht),
    PRE_first_tail_x15_r0_body.cbridge191,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1841.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1840.ffi) (PRE_first_tail_x15_r0_body.cfoot191 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_191 PRE_first_tail_x15_r0_body.ofx1_191 hobjC PRE_first_tail_x15_r0_body.ff0191 PRE_first_tail_x15_r0_body.ff1191 PRE_first_tail_x15_r0_body.ffck191,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1841.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1840.ffi) (PRE_first_tail_x15_r0_body.cfoot191 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_191 PRE_first_tail_x15_r0_body.okr1_191 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn191) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0191 PRE_first_tail_x15_r0_body.fkt0191 PRE_first_tail_x15_r0_body.fkf1191 PRE_first_tail_x15_r0_body.fkt1191 PRE_first_tail_x15_r0_body.fkck191,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0191 PRE_first_tail_x15_r0_body.cnh1191 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe191) PRE_first_tail_x15_r0_body.cpendR191⟩

end Host.Load.Run.Tpl
end

section -- st191/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st191 0
host_stream_state PRE_first_tail_x15_r0_body.st191 1
host_stream_state PRE_first_tail_x15_r0_body.st191 2
end Host.Load.Run.Tpl
end

section -- Site191
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 191 of chain `PRE_first_tail_x15_r0_body`: `plan__g191__g192` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1839`, the merged state `PRE_first_tail_x15_r0_body.s1840`,
the site template `PRE_first_tail_x15_r0_body.st191` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1841`: the merge.
The footprint's facts are in `SiteF191`, the compaction's in `SiteC191`, `SiteK191`, `SiteNa191`, `SiteNb191`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso191 : PRE_first_tail_x15_r0_body.st191.s0 = { PRE_first_tail_x15_r0_body.s1839 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs191 : List Frame := PRE_first_tail_x15_r0_body.s1839.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_191 : PRE_first_tail_x15_r0_body.S1839.tab.length = 8218
kernel_rfl PRE_first_tail_x15_r0_body.tab0_191 : PRE_first_tail_x15_r0_body.st191.S0.tab = PRE_first_tail_x15_r0_body.S1839.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws191 : List Nat := [4229, 4230, 4231]
kernel_rfl PRE_first_tail_x15_r0_body.fresh191 : (PRE_first_tail_x15_r0_body.S1839.tab.all fun e => PRE_first_tail_x15_r0_body.ws191.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1839.oracle.all fun q => PRE_first_tail_x15_r0_body.ws191.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab191 : PRE_first_tail_x15_r0_body.S1840.tab = PRE_first_tail_x15_r0_body.S1839.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws191
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen191 : PRE_first_tail_x15_r0_body.st191.S2.tab.length - PRE_first_tail_x15_r0_body.st191.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged191`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap191 : PRE_first_tail_x15_r0_body.s1840.heap = PRE_first_tail_x15_r0_body.st191.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext191 : PRE_first_tail_x15_r0_body.s1840.next = PRE_first_tail_x15_r0_body.st191.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl191 : PRE_first_tail_x15_r0_body.s1840.ctl = PRE_first_tail_x15_r0_body.st191.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack191 : PRE_first_tail_x15_r0_body.s1840.stack = PRE_first_tail_x15_r0_body.st191.s2.stack ++ PRE_first_tail_x15_r0_body.s1839.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs191 : PRE_first_tail_x15_r0_body.s1840.jobs = PRE_first_tail_x15_r0_body.st191.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi191 : PRE_first_tail_x15_r0_body.s1840.ffi = PRE_first_tail_x15_r0_body.st191.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace191 : PRE_first_tail_x15_r0_body.s1840.trace = PRE_first_tail_x15_r0_body.st191.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores191 : PRE_first_tail_x15_r0_body.s1840.stores = PRE_first_tail_x15_r0_body.st191.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD191
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 191 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived191 : PRE_first_tail_x15_r0_body.nr191.map (fun r => nth? PRE_first_tail_x15_r0_body.st191.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo191 : PRE_first_tail_x15_r0_body.nr191.all (Nat.ble 8218) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj191 : PRE_first_tail_x15_r0_body.cws191.all (fun c => !PRE_first_tail_x15_r0_body.ws191.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ191 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws191 PRE_first_tail_x15_r0_body.crs191 PRE_first_tail_x15_r0_body.ws191

end Host.Load.Run.Tpl
end

section -- st191/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st191`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st191.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st191.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st191.s2.heap PRE_first_tail_x15_r0_body.st191.wrR ++ freshOf PRE_first_tail_x15_r0_body.st191.s2.heap PRE_first_tail_x15_r0_body.st191.s0.next PRE_first_tail_x15_r0_body.st191.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st191.wr : List Nat := PRE_first_tail_x15_r0_body.st191.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st191.heapFoot : PRE_first_tail_x15_r0_body.st191.s2.heap = setAll PRE_first_tail_x15_r0_body.st191.s0.heap PRE_first_tail_x15_r0_body.st191.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st191.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st191.s0.next PRE_first_tail_x15_r0_body.st191.s2.next = true
theorem PRE_first_tail_x15_r0_body.st191.grows : PRE_first_tail_x15_r0_body.st191.s0.next ≤ PRE_first_tail_x15_r0_body.st191.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st191.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st191.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st191.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st191.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st191.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st191.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st191.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st191.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st191.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st191.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st191.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st191.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st191.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st191.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st191.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st191.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st191.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st191.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st191.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st191.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st191.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st191.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st191.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st191.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st191.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st191.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st191.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st191.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st191.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st191.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st191.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st191.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF191
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 191 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB191 : nodupT PRE_first_tail_x15_r0_body.st191.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup191 : PRE_first_tail_x15_r0_body.st191.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB191).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB191 : PRE_first_tail_x15_r0_body.st191.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound191 : ∀ b ∈ PRE_first_tail_x15_r0_body.st191.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB191 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr191 := PRE_first_tail_x15_r0_body.st191.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq191 : PRE_first_tail_x15_r0_body.st191.s2.trace = PRE_first_tail_x15_r0_body.trFr191 ++ PRE_first_tail_x15_r0_body.st191.s0.trace
theorem PRE_first_tail_x15_r0_body.trace191 : ∃ fr, PRE_first_tail_x15_r0_body.st191.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st191.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq191⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide191 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB191 : (PRE_first_tail_x15_r0_body.wide191.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st191.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix191 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide191, WFix Map.id (Present PRE_first_tail_x15_r0_body.st191.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB191 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL191
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 191 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1840`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO191 : PRE_first_tail_x15_r0_body.st191.S0.oracle = PRE_first_tail_x15_r0_body.st191.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B191 : PRE_first_tail_x15_r0_body.st191.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st191.s0.next || (PRE_first_tail_x15_r0_body.st191.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot191 : Conv.StageFoot PRE_first_tail_x15_r0_body.st191.wr PRE_first_tail_x15_r0_body.st191.s0 PRE_first_tail_x15_r0_body.st191.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st191.heapFoot PRE_first_tail_x15_r0_body.wrNodup191 PRE_first_tail_x15_r0_body.wrBound191 PRE_first_tail_x15_r0_body.wr0B191 PRE_first_tail_x15_r0_body.st191.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged191 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st191.F.S → PRE_first_tail_x15_r0_body.st191.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st191.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st191.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs191 PRE_first_tail_x15_r0_body.st191.wr PRE_first_tail_x15_r0_body.s1839 PRE_first_tail_x15_r0_body.st191.s2 PRE_first_tail_x15_r0_body.st191.s0
      PRE_first_tail_x15_r0_body.st191.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st191.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1840 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso191 PRE_first_tail_x15_r0_body.stFoot191 PRE_first_tail_x15_r0_body.wrNodup191 PRE_first_tail_x15_r0_body.wrBound191 PRE_first_tail_x15_r0_body.trace191 PRE_first_tail_x15_r0_body.mheap191
    PRE_first_tail_x15_r0_body.mnext191 PRE_first_tail_x15_r0_body.mctl191 PRE_first_tail_x15_r0_body.mstack191 PRE_first_tail_x15_r0_body.mjobs191 PRE_first_tail_x15_r0_body.mffi191 PRE_first_tail_x15_r0_body.mtrace191 PRE_first_tail_x15_r0_body.mstores191 h

def PRE_first_tail_x15_r0_body.arrEl191_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE191_2665 : arrOf PRE_first_tail_x15_r0_body.s1840 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl191_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA191_2665 : isArrB PRE_first_tail_x15_r0_body.s1840 2665 = true
theorem PRE_first_tail_x15_r0_body.arr191_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1840.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl191_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE191_2665 PRE_first_tail_x15_r0_body.arrA191_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN191_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl191_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR191_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl191_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN191_2665

def PRE_first_tail_x15_r0_body.arrEl191_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE191_2673467 : arrOf PRE_first_tail_x15_r0_body.s1840 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl191_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA191_2673467 : isArrB PRE_first_tail_x15_r0_body.s1840 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr191_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1840.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl191_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE191_2673467 PRE_first_tail_x15_r0_body.arrA191_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN191_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl191_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR191_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl191_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN191_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k191 : isArrB PRE_first_tail_x15_r0_body.s1840 4910 = false
theorem PRE_first_tail_x15_r0_body.keep191 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1840 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k191 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr191_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl191_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ191
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 191 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1839`, the merged
state `PRE_first_tail_x15_r0_body.s1840`, the canonical state `PRE_first_tail_x15_r0_body.s1841`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl191 : PRE_first_tail_x15_r0_body.pl191.all (Nat.ble PRE_first_tail_x15_r0_body.s1839.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd191 : nodupT PRE_first_tail_x15_r0_body.pl191 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1191 : Nat.ble PRE_first_tail_x15_r0_body.s1839.next 2824664 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst191 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1839.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn191 : PRE_first_tail_x15_r0_body.s1841.next = PRE_first_tail_x15_r0_body.s1839.next + PRE_first_tail_x15_r0_body.pl191.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn191 : PRE_first_tail_x15_r0_body.s1840.next = 2824664
kernel_rfl PRE_first_tail_x15_r0_body.zgrow191 : Nat.ble PRE_first_tail_x15_r0_body.s1841.next PRE_first_tail_x15_r0_body.s1840.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh191 : PRE_first_tail_x15_r0_body.S1839.tab.all (fun e => PRE_first_tail_x15_r0_body.cws191.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd191 : nodupT PRE_first_tail_x15_r0_body.cws191 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi191 : PRE_first_tail_x15_r0_body.nr191.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1840.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt191 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1839.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg191_2665 : PRE_first_tail_x15_r0_body.s1841.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1841 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk191_2665 : (objOf PRE_first_tail_x15_r0_body.s1841 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm191_2665 : PRE_first_tail_x15_r0_body.s1840.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa191.obj (objOf PRE_first_tail_x15_r0_body.s1841 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1840 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg191_2673467 : PRE_first_tail_x15_r0_body.s1841.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1841 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk191_2673467 : (objOf PRE_first_tail_x15_r0_body.s1841 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm191_2673467 : PRE_first_tail_x15_r0_body.s1840.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa191.obj (objOf PRE_first_tail_x15_r0_body.s1841 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1840 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw191_4910 : (PRE_first_tail_x15_r0_body.s1841.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw191_2673472 : (PRE_first_tail_x15_r0_body.s1841.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw191_2673473 : (PRE_first_tail_x15_r0_body.s1841.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd191 : PRE_first_tail_x15_r0_body.cl191.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr191 : PRE_first_tail_x15_r0_body.st191.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1839.next || PRE_first_tail_x15_r0_body.cl191.contains b) = true
def PRE_first_tail_x15_r0_body.zl191 : List Nat := PRE_first_tail_x15_r0_body.cl191.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE191 : PRE_first_tail_x15_r0_body.zl191.map (fun a => PRE_first_tail_x15_r0_body.s1840.heap.get (PRE_first_tail_x15_r0_body.kappa191.a a)) = PRE_first_tail_x15_r0_body.zl191.map (fun a => (PRE_first_tail_x15_r0_body.s1841.heap.get a).map PRE_first_tail_x15_r0_body.kappa191.hobj)
theorem PRE_first_tail_x15_r0_body.zimg191 : HeapImg PRE_first_tail_x15_r0_body.kappa191 PRE_first_tail_x15_r0_body.s1841 PRE_first_tail_x15_r0_body.s1840 PRE_first_tail_x15_r0_body.zl191 := PRE_first_tail_x15_r0_body.zimgE191
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl191 : PRE_first_tail_x15_r0_body.s1840.ctl = PRE_first_tail_x15_r0_body.kappa191.ctl PRE_first_tail_x15_r0_body.s1841.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack191 : PRE_first_tail_x15_r0_body.s1840.stack = PRE_first_tail_x15_r0_body.s1841.stack.map PRE_first_tail_x15_r0_body.kappa191.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs191 : PRE_first_tail_x15_r0_body.s1840.jobs = PRE_first_tail_x15_r0_body.s1841.jobs.map PRE_first_tail_x15_r0_body.kappa191.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores191 : PRE_first_tail_x15_r0_body.s1840.stores = PRE_first_tail_x15_r0_body.kappa191.stores PRE_first_tail_x15_r0_body.s1841.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots191 : checkRootsSupp PRE_first_tail_x15_r0_body.s1841 8218 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC191 : PRE_first_tail_x15_r0_body.S1839.tab.length + PRE_first_tail_x15_r0_body.cws191.length = 8218
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap191 : PRE_first_tail_x15_r0_body.kappa191 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1839.next 2824664 PRE_first_tail_x15_r0_body.S1839.tab.length PRE_first_tail_x15_r0_body.pl191 (PRE_first_tail_x15_r0_body.nr191.map NumV.ref) PRE_first_tail_x15_r0_body.kd191.big
  PRE_first_tail_x15_r0_body.kd191.region PRE_first_tail_x15_r0_body.kd191.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin191 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1841.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc191 : Conv.jcleanListB (⟨21957, 19051, 2824654, 8218⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1841 PRE_first_tail_x15_r0_body.cl191 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB191 : noBigRootsP (fun i => !Conv.oldBigB (⟨21957, 19051, 2824654, 8218⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1841.trace PRE_first_tail_x15_r0_body.s1841 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm191 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 19051 = true
theorem PRE_first_tail_x15_r0_body.cjcl191 (h : Conv.JClean (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1839) : Conv.JClean (⟨21957, 19051, 2824654, 8218⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1841 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle191)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap191 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd191 a ha)) PRE_first_tail_x15_r0_body.zjc191

end Host.Load.Run.Tpl
end

section -- st191/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st191.bodyLast from PRE_first_tail_x15_r0_body.st191.s1 to PRE_first_tail_x15_r0_body.st191.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st191.F PRE_first_tail_x15_r0_body.st191.s1).run PRE_first_tail_x15_r0_body.st191.S1 = some (PRE_first_tail_x15_r0_body.st191.s2, PRE_first_tail_x15_r0_body.st191.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st191.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st191.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st191.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st191.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st191/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st191.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st191.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st191.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st191.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st191.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st191.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st191.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st191.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st191.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st191.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st191.s0 PRE_first_tail_x15_r0_body.st191.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st191.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st191.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st191.s1 PRE_first_tail_x15_r0_body.st191.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st191/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st191.bodyK0F from PRE_first_tail_x15_r0_body.st191.s0 to PRE_first_tail_x15_r0_body.st191.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st191.F (PRE_first_tail_x15_r0_body.st191.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st191.ks 0).getD 0) PRE_first_tail_x15_r0_body.st191.s0 PRE_first_tail_x15_r0_body.st191.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st191.s1, PRE_first_tail_x15_r0_body.st191.S1)
theorem PRE_first_tail_x15_r0_body.st191.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st191.F (PRE_first_tail_x15_r0_body.st191.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st191.ks 0).getD 0) PRE_first_tail_x15_r0_body.st191.s0 PRE_first_tail_x15_r0_body.st191.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st191.s1, PRE_first_tail_x15_r0_body.st191.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st191.bodyOkLN_ok PRE_first_tail_x15_r0_body.st191.bodyK0F
end Host.Load.Run.Tpl
end

section -- st191/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st191.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st191.F (PRE_first_tail_x15_r0_body.st191.bodyOkL bytes rows) 98 PRE_first_tail_x15_r0_body.st191.s0 PRE_first_tail_x15_r0_body.st191.S0 = some (PRE_first_tail_x15_r0_body.st191.s1, PRE_first_tail_x15_r0_body.st191.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st191.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st191.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st191.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st191.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st191.F (PRE_first_tail_x15_r0_body.st191.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st191.s0
  S0 := PRE_first_tail_x15_r0_body.st191.S0
  s1 := PRE_first_tail_x15_r0_body.st191.s1
  S1 := PRE_first_tail_x15_r0_body.st191.S1
  s2 := PRE_first_tail_x15_r0_body.st191.s2
  S2 := PRE_first_tail_x15_r0_body.st191.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st191.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st191.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st191.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st191.bodyHalt
  last := PRE_first_tail_x15_r0_body.st191.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st191.bodyTopCheck
end Host.Load.Run.Tpl
end

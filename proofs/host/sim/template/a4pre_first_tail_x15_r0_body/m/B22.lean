import host.sim.template.a4pre_first_tail_x15_r0_body.m.B21
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

section -- st65/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st65.bodyK0F from PRE_first_tail_x15_r0_body.st65.s0 to PRE_first_tail_x15_r0_body.st65.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st65.F (PRE_first_tail_x15_r0_body.st65.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st65.ks 0).getD 0) PRE_first_tail_x15_r0_body.st65.s0 PRE_first_tail_x15_r0_body.st65.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st65.s1, PRE_first_tail_x15_r0_body.st65.S1)
theorem PRE_first_tail_x15_r0_body.st65.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st65.F (PRE_first_tail_x15_r0_body.st65.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st65.ks 0).getD 0) PRE_first_tail_x15_r0_body.st65.s0 PRE_first_tail_x15_r0_body.st65.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st65.s1, PRE_first_tail_x15_r0_body.st65.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st65.bodyOkLN_ok PRE_first_tail_x15_r0_body.st65.bodyK0F
end Host.Load.Run.Tpl
end

section -- st65/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st65.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st65.F (PRE_first_tail_x15_r0_body.st65.bodyOkL bytes rows) 98 PRE_first_tail_x15_r0_body.st65.s0 PRE_first_tail_x15_r0_body.st65.S0 = some (PRE_first_tail_x15_r0_body.st65.s1, PRE_first_tail_x15_r0_body.st65.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st65.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st65.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st65.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st65.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st65.F (PRE_first_tail_x15_r0_body.st65.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st65.s0
  S0 := PRE_first_tail_x15_r0_body.st65.S0
  s1 := PRE_first_tail_x15_r0_body.st65.s1
  S1 := PRE_first_tail_x15_r0_body.st65.S1
  s2 := PRE_first_tail_x15_r0_body.st65.s2
  S2 := PRE_first_tail_x15_r0_body.st65.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st65.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st65.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st65.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st65.bodyHalt
  last := PRE_first_tail_x15_r0_body.st65.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st65.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC66
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 66 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s651` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa66` into the merged state
`PRE_first_tail_x15_r0_body.s650`. -/

def PRE_first_tail_x15_r0_body.pl66 : List Nat := [2728171, 2727346, 2728177, 2728173, 2727348, 2728179]
def PRE_first_tail_x15_r0_body.nr66 : List Nat := [2936, 2935, 2911, 2919, 2924, 2929, 2934, 2908, 2909, 2910, 2917, 2918, 2906, 2913, 2914, 2915, 2916, 2912]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd66 : RData :=
  ⟨2727065, 2728214, Stage.setAll PTrie.nil [(2727059, 2728171), (2727060, 2727346), (2727061, 2728177), (2727062, 2728173), (2727063, 2727348), (2727064, 2728179)], Stage.setAll PTrie.nil [(19510, 19536), (19511, 19514), (19512, 19537)],
   19513, 19538, 16616, 16616, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(2906, .ref 2936), (2907, .ref 2935), (2908, .ref 2911), (2909, .ref 2919), (2910, .ref 2924), (2911, .ref 2929), (2912, .ref 2934), (2913, .ref 2908), (2914, .ref 2909), (2915, .ref 2910), (2916, .ref 2917), (2917, .ref 2918), (2918, .ref 2906), (2919, .ref 2913), (2920, .ref 2914), (2921, .ref 2915), (2922, .ref 2916), (2923, .ref 2912)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa66 : Map :=
  Conv.Map.compact 2727059 2728214 2906 PRE_first_tail_x15_r0_body.pl66 (PRE_first_tail_x15_r0_body.nr66.map NumV.ref) PRE_first_tail_x15_r0_body.kd66.big
    PRE_first_tail_x15_r0_body.kd66.region PRE_first_tail_x15_r0_body.kd66.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws66 : List Nat := [2146, 2147, 2148, 2149, 2150, 2151, 2152, 2153, 2154, 2155, 2156, 2157, 2158, 2159, 2160, 2161, 2162, 2163]
noncomputable def PRE_first_tail_x15_r0_body.crs66 : List SymE := PRE_first_tail_x15_r0_body.nr66.map fun r => (nth? PRE_first_tail_x15_r0_body.S650.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta66 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws66 PRE_first_tail_x15_r0_body.crs66
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB66 : List Nat := [2665, 2672465, 2673467, 2726233, 2726778, 2727034]

kernel_rfl PRE_first_tail_x15_r0_body.ctab66 : PRE_first_tail_x15_r0_body.S651.tab = PRE_first_tail_x15_r0_body.S649.tab ++ PRE_first_tail_x15_r0_body.cws66.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace66 : PRE_first_tail_x15_r0_body.s651.trace = PRE_first_tail_x15_r0_body.s649.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext66 : PRE_first_tail_x15_r0_body.s651.next = 2727065
kernel_rfl PRE_first_tail_x15_r0_body.ccounters66 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.nnext) = (19513, 16616)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue66 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s650.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa66.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp66 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.tokens.all (bSN 2924) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean66 : Conv.cleanListB 19513 131072 (fun r => Nat.ble 78052 r) PRE_first_tail_x15_r0_body.s651
    (PRE_first_tail_x15_r0_body.wrB66 ++ (List.range 6).map (2727059 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs66 : bigsOutB 19513 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK66
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl66`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl66 : List Nat := [2665, 2672465, 2673467, 2726233, 2726778, 2727034, 2727059, 2727060, 2727061, 2727062, 2727063, 2727064]
def PRE_first_tail_x15_r0_body.clo66 : List Nat := [19490, 19503, 19509, 19510, 19511, 19512]
def PRE_first_tail_x15_r0_body.cln66 : List Nat := [16589, 16590, 16591, 16592, 16593, 16594, 16595, 16596, 16597, 16598, 16599, 16600, 16601, 16602, 16603, 16604, 16605, 16606, 16607, 16608, 16609, 16610, 16611, 16612, 16613, 16614, 16615]
def PRE_first_tail_x15_r0_body.cli66 : List Nat := [16589, 16590, 16591, 16592, 16593, 16594, 16595, 16596, 16597, 16598, 16599, 16600, 16601, 16602, 16603, 16604, 16605, 16606, 16607, 16608, 16609, 16610, 16611, 16612, 16613, 16614, 16615]
kernel_rfl PRE_first_tail_x15_r0_body.cheap66 : PRE_first_tail_x15_r0_body.s651.heap = Stage.setAll PRE_first_tail_x15_r0_body.s649.heap (PRE_first_tail_x15_r0_body.cl66.filterMap fun a => (PRE_first_tail_x15_r0_body.s651.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe66 : Nat.ble PRE_first_tail_x15_r0_body.s649.next PRE_first_tail_x15_r0_body.s651.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP66 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s649 PRE_first_tail_x15_r0_body.s651 PRE_first_tail_x15_r0_body.cl66 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp66 : Conv.suppListB PRE_first_tail_x15_r0_body.s651 2924 PRE_first_tail_x15_r0_body.cl66 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound66 : Conv.boundListB PRE_first_tail_x15_r0_body.s651 PRE_first_tail_x15_r0_body.cl66 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK66 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln66.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK66 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo66.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK66 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli66.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst66 : Conv.sstListB 2924 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx PRE_first_tail_x15_r0_body.cln66 PRE_first_tail_x15_r0_body.clo66 PRE_first_tail_x15_r0_body.cli66 = true

end Host.Load.Run.Tpl
end

section -- SiteCl66
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA66 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo66.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd66 : (PRE_first_tail_x15_r0_body.clo66 ++ PRE_first_tail_x15_r0_body.cln66 ++ PRE_first_tail_x15_r0_body.cli66).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle66 : Conv.Cnt.leB (⟨19510, 16589, 2727059, 2906⟩ : Conv.Cnt) (⟨19513, 16616, 2727065, 2924⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck66 : Conv.ncleanListB (⟨19513, 16616, 2727065, 2924⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx PRE_first_tail_x15_r0_body.clo66 PRE_first_tail_x15_r0_body.cln66 PRE_first_tail_x15_r0_body.cli66 = true
theorem PRE_first_tail_x15_r0_body.cncl66 (h : Conv.NClean (⟨19510, 16589, 2727059, 2906⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx) : Conv.NClean (⟨19513, 16616, 2727065, 2924⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle66 PRE_first_tail_x15_r0_body.ckA66 PRE_first_tail_x15_r0_body.cobjsK66 PRE_first_tail_x15_r0_body.cnodesK66 PRE_first_tail_x15_r0_body.citemsK66 PRE_first_tail_x15_r0_body.cbd66 PRE_first_tail_x15_r0_body.cck66

end Host.Load.Run.Tpl
end

section -- SiteS66
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 66 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc66 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P66 : LoadP := PRE_first_tail_x15_r0_body.Pc66.raise 16616
kernel_rfl PRE_first_tail_x15_r0_body.craise66 : Nat.ble PRE_first_tail_x15_r0_body.Pc66.N0 16616 = true
theorem PRE_first_tail_x15_r0_body.raised66 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc66 PRE_first_tail_x15_r0_body.P66 :=
  .inr ⟨16616, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise66, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_66 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_66 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s650.ffi)
def PRE_first_tail_x15_r0_body.khinv66 : PTrie Nat := Stage.setAll PTrie.nil [(19536, 19510), (19514, 19511), (19537, 19512)]
def PRE_first_tail_x15_r0_body.kninv66 : PTrie Nat := Stage.setAll PTrie.nil [(16589, 16589), (16590, 16590), (16591, 16591), (16592, 16592), (16593, 16593), (16594, 16594), (16595, 16595), (16596, 16596), (16597, 16597), (16598, 16598), (16599, 16599), (16600, 16600), (16601, 16601), (16602, 16602), (16603, 16603), (16604, 16604), (16605, 16605), (16606, 16606), (16607, 16607), (16608, 16608), (16609, 16609), (16610, 16610), (16611, 16611), (16612, 16612), (16613, 16613), (16614, 16614), (16615, 16615)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS66 : List Nat := [19490, 19503, 19509, 19510, 19511, 19512, 19513, 19514, 19515, 19516, 19517, 19518, 19519, 19520, 19521, 19522, 19523, 19524, 19525, 19526, 19527, 19528, 19529, 19530, 19531, 19532, 19533, 19534, 19535, 19536, 19537]
def PRE_first_tail_x15_r0_body.cnS66 : List Nat := List.range' 16589 27
def PRE_first_tail_x15_r0_body.ciS66 : List Nat := [] ++ List.range' 16589 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh066 : PRE_first_tail_x15_r0_body.kd66.nh0 = PRE_first_tail_x15_r0_body.cx0_66.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh166 : PRE_first_tail_x15_r0_body.kd66.nh1 = PRE_first_tail_x15_r0_body.cx1_66.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn066 : PRE_first_tail_x15_r0_body.kd66.nn0 = PRE_first_tail_x15_r0_body.cx0_66.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn166 : PRE_first_tail_x15_r0_body.kd66.nn1 = PRE_first_tail_x15_r0_body.cx1_66.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo66 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P66.lo && Nat.ble PRE_first_tail_x15_r0_body.P66.lo PRE_first_tail_x15_r0_body.cx0_66.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P66.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P66.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt66 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_66.mlx.next PRE_first_tail_x15_r0_body.cx1_66.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_66.mlx.nnext PRE_first_tail_x15_r0_body.cx1_66.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband66 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P66.NL && Nat.ble PRE_first_tail_x15_r0_body.P66.NL PRE_first_tail_x15_r0_body.P66.N0 && Nat.ble PRE_first_tail_x15_r0_body.P66.N0 PRE_first_tail_x15_r0_body.cx0_66.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow66 : PRE_first_tail_x15_r0_body.kd66.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren66 : checkRenG PRE_first_tail_x15_r0_body.kd66.hnd PRE_first_tail_x15_r0_body.khinv66 (phB PRE_first_tail_x15_r0_body.cx0_66.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband66 : PRE_first_tail_x15_r0_body.kd66.checkBand PRE_first_tail_x15_r0_body.P66.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos66 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd66.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren66 : checkRenG PRE_first_tail_x15_r0_body.kd66.node PRE_first_tail_x15_r0_body.kninv66 (pnB PRE_first_tail_x15_r0_body.cx0_66.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow66 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd66.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P66.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd66.nodeF j) PRE_first_tail_x15_r0_body.cx1_66.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a66 : PRE_first_tail_x15_r0_body.cx0_66.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b66 : PRE_first_tail_x15_r0_body.cx0_66.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok166 : PRE_first_tail_x15_r0_body.cx1_66.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend66 : PRE_first_tail_x15_r0_body.cx1_66.mlx.pending = PRE_first_tail_x15_r0_body.cx0_66.mlx.pending.map PRE_first_tail_x15_r0_body.kappa66.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh66 : PRE_first_tail_x15_r0_body.cx1_66.mlx.errh = PRE_first_tail_x15_r0_body.cx0_66.mlx.errh.map PRE_first_tail_x15_r0_body.kappa66.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles66 : PRE_first_tail_x15_r0_body.cx1_66.mlx.files = PRE_first_tail_x15_r0_body.cx0_66.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch66 : PRE_first_tail_x15_r0_body.cx1_66.mlx.arch = PRE_first_tail_x15_r0_body.cx0_66.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes66 : PRE_first_tail_x15_r0_body.cx1_66.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_66.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired66 : PRE_first_tail_x15_r0_body.cx1_66.mlx.wired = PRE_first_tail_x15_r0_body.cx0_66.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost66 : PRE_first_tail_x15_r0_body.cx1_66.host = PRE_first_tail_x15_r0_body.cx0_66.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd66`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn066 : PRE_first_tail_x15_r0_body.kd66.n0 = 2727065
kernel_rfl PRE_first_tail_x15_r0_body.ckn166 : PRE_first_tail_x15_r0_body.kd66.n1 = 2728214
kernel_rfl PRE_first_tail_x15_r0_body.ckheap66 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd66.heap).all (fun x => Nat.ble 2727059 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl66 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd66.heap.get (2727059 + j) = nth? PRE_first_tail_x15_r0_body.pl66 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja66 : Nat.ble 2727059 2727059 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn66 : Nat.ble 2906 2906 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD66 : Nat.ble 2727059 PRE_first_tail_x15_r0_body.kd66.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn66 : Nat.ble 19510 PRE_first_tail_x15_r0_body.kd66.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn66 : Nat.ble 16589 PRE_first_tail_x15_r0_body.kd66.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb66 : Nat.ble 19510 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap66 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd66.heap).all (Nat.ble (⟨19510, 16589, 2727059, 2906⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd66 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd66.hnd).all (Nat.ble (⟨19510, 16589, 2727059, 2906⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode66 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd66.node).all (Nat.ble (⟨19510, 16589, 2727059, 2906⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix66 : Conv.FixOld (⟨19510, 16589, 2727059, 2906⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa66 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja66) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn66) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD66) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn66) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn66) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb66) PRE_first_tail_x15_r0_body.fheap66 PRE_first_tail_x15_r0_body.fhnd66 PRE_first_tail_x15_r0_body.fnode66
kernel_rfl PRE_first_tail_x15_r0_body.fcxn66 : (⟨19510, 16589, 2727059, 2906⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn66 : (⟨19510, 16589, 2727059, 2906⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle066 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_66.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_66.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk66 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd66.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A66 : PRE_first_tail_x15_r0_body.cx1_66.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS66.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_66.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O66 : PRE_first_tail_x15_r0_body.cx1_66.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS66.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_66.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N66 : PRE_first_tail_x15_r0_body.cx1_66.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS66.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_66.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I66 : PRE_first_tail_x15_r0_body.cx1_66.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS66.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_66.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd66 : (PRE_first_tail_x15_r0_body.clo66 ++ PRE_first_tail_x15_r0_body.cln66 ++ PRE_first_tail_x15_r0_body.cli66 ++ PRE_first_tail_x15_r0_body.cwS66 ++ PRE_first_tail_x15_r0_body.cnS66 ++ PRE_first_tail_x15_r0_body.ciS66).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW66 : PRE_first_tail_x15_r0_body.cwS66.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo66.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI66 : PRE_first_tail_x15_r0_body.ciS66.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli66.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN66 : PRE_first_tail_x15_r0_body.cnS66.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF66 : PRE_first_tail_x15_r0_body.cln66.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh66 : PRE_first_tail_x15_r0_body.clo66.all (handleOK PRE_first_tail_x15_r0_body.kappa66 PRE_first_tail_x15_r0_body.P66.lo PRE_first_tail_x15_r0_body.cx0_66.mlx PRE_first_tail_x15_r0_body.cx1_66.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo66 : PRE_first_tail_x15_r0_body.clo66.map (fun h => PRE_first_tail_x15_r0_body.cx1_66.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa66.handle h)) = PRE_first_tail_x15_r0_body.clo66.map (fun h => (PRE_first_tail_x15_r0_body.cx0_66.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa66.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok66 : PRE_first_tail_x15_r0_body.clo66.all (objOK PRE_first_tail_x15_r0_body.kappa66 PRE_first_tail_x15_r0_body.P66.NL PRE_first_tail_x15_r0_body.cx0_66.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd66 : PRE_first_tail_x15_r0_body.cln66.all (nodeOKF PRE_first_tail_x15_r0_body.kappa66 PRE_first_tail_x15_r0_body.P66 PRE_first_tail_x15_r0_body.cx0_66.mlx PRE_first_tail_x15_r0_body.cx1_66.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp66 : ((PRE_first_tail_x15_r0_body.cln66.filter (fullB PRE_first_tail_x15_r0_body.P66))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_66.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa66.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln66.filter (fullB PRE_first_tail_x15_r0_body.P66))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_66.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa66.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI66 : incrB PRE_first_tail_x15_r0_body.kd66.nodeF (List.range' 16589 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK66 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd66.node).all (fun k => Nat.ble 16589 k && Nat.blt k 16616) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL66 : (PRE_first_tail_x15_r0_body.cln66.filter (Nat.ble PRE_first_tail_x15_r0_body.P66.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd66.nodeF i) && (Nat.blt i 16616 || Nat.ble PRE_first_tail_x15_r0_body.kd66.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord66 : (PRE_first_tail_x15_r0_body.cln66.filter (Nat.ble PRE_first_tail_x15_r0_body.P66.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd66.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd66.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd66.nodeF j) (PRE_first_tail_x15_r0_body.kd66.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow66 PRE_first_tail_x15_r0_body.cnn166 PRE_first_tail_x15_r0_body.fnordI66 PRE_first_tail_x15_r0_body.fnordK66 PRE_first_tail_x15_r0_body.fnordL66
kernel_rfl PRE_first_tail_x15_r0_body.fi66 : PRE_first_tail_x15_r0_body.cli66.all (pnB PRE_first_tail_x15_r0_body.cx0_66.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii66 : PRE_first_tail_x15_r0_body.cli66.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_66.mlx.items.get (PRE_first_tail_x15_r0_body.kappa66.node k) = (PRE_first_tail_x15_r0_body.cx0_66.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa66.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot66 (clean : Conv.NClean (⟨19510, 16589, 2727059, 2906⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P66.NL) (cl : SSt (· < 2924) PRE_first_tail_x15_r0_body.cx0_66.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P66 2924 PRE_first_tail_x15_r0_body.kappa66 PRE_first_tail_x15_r0_body.kd66 PRE_first_tail_x15_r0_body.khinv66 PRE_first_tail_x15_r0_body.kninv66 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx PRE_first_tail_x15_r0_body.cx0_66.mlx PRE_first_tail_x15_r0_body.cx1_66.mlx (⟨19510, 16589, 2727059, 2906⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo66 PRE_first_tail_x15_r0_body.cln66 PRE_first_tail_x15_r0_body.cli66 PRE_first_tail_x15_r0_body.cwS66 PRE_first_tail_x15_r0_body.cnS66 PRE_first_tail_x15_r0_body.ciS66 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh066, PRE_first_tail_x15_r0_body.cnh166, PRE_first_tail_x15_r0_body.cnn066, PRE_first_tail_x15_r0_body.cnn166, PRE_first_tail_x15_r0_body.cplo66, PRE_first_tail_x15_r0_body.ccnt66, PRE_first_tail_x15_r0_body.cnband66, PRE_first_tail_x15_r0_body.chbelow66, PRE_first_tail_x15_r0_body.chren66, PRE_first_tail_x15_r0_body.cband66, PRE_first_tail_x15_r0_body.cnh1pos66, PRE_first_tail_x15_r0_body.cnren66, PRE_first_tail_x15_r0_body.cnlow66, PRE_first_tail_x15_r0_body.cabs0a66, PRE_first_tail_x15_r0_body.cabs0b66, PRE_first_tail_x15_r0_body.ctok166, PRE_first_tail_x15_r0_body.cpend66, PRE_first_tail_x15_r0_body.cerrh66, PRE_first_tail_x15_r0_body.cfiles66, PRE_first_tail_x15_r0_body.carch66, PRE_first_tail_x15_r0_body.csizes66, PRE_first_tail_x15_r0_body.cwired66, PRE_first_tail_x15_r0_body.cfix66, clean, PRE_first_tail_x15_r0_body.fcxn66, PRE_first_tail_x15_r0_body.fcnn66, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle066, PRE_first_tail_x15_r0_body.fnk66, PRE_first_tail_x15_r0_body.ckA66, PRE_first_tail_x15_r0_body.cobjsK66, PRE_first_tail_x15_r0_body.cnodesK66, PRE_first_tail_x15_r0_body.citemsK66, PRE_first_tail_x15_r0_body.f1A66, PRE_first_tail_x15_r0_body.f1O66, PRE_first_tail_x15_r0_body.f1N66, PRE_first_tail_x15_r0_body.f1I66, PRE_first_tail_x15_r0_body.fbd66, PRE_first_tail_x15_r0_body.fincW66, PRE_first_tail_x15_r0_body.fincI66, PRE_first_tail_x15_r0_body.fincN66, PRE_first_tail_x15_r0_body.flnF66, PRE_first_tail_x15_r0_body.fh66, PRE_first_tail_x15_r0_body.fo66, PRE_first_tail_x15_r0_body.fok66, PRE_first_tail_x15_r0_body.fnd66, PRE_first_tail_x15_r0_body.fp66, PRE_first_tail_x15_r0_body.fnord66, PRE_first_tail_x15_r0_body.fi66, PRE_first_tail_x15_r0_body.fii66⟩
theorem PRE_first_tail_x15_r0_body.cnshift66 (clean : Conv.NClean (⟨19510, 16589, 2727059, 2906⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P66.NL) (cl : SSt (· < 2924) PRE_first_tail_x15_r0_body.cx0_66.mlx) : NShift PRE_first_tail_x15_r0_body.P66 2924 PRE_first_tail_x15_r0_body.kappa66 PRE_first_tail_x15_r0_body.cx0_66 PRE_first_tail_x15_r0_body.cx1_66 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot66 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost66 (compact_a_eq PRE_first_tail_x15_r0_body.ckn066 PRE_first_tail_x15_r0_body.ckn166 PRE_first_tail_x15_r0_body.ckheap66 PRE_first_tail_x15_r0_body.ckpl66)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_66 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s649.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_66 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s649.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_66 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s649.ffi) = some PRE_first_tail_x15_r0_body.fxC_66
kernel_rfl PRE_first_tail_x15_r0_body.okrC_66 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s649.ffi) = some PRE_first_tail_x15_r0_body.krC_66
noncomputable def PRE_first_tail_x15_r0_body.fx0_66 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s651.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_66 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s651.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_66 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s651.ffi) = some PRE_first_tail_x15_r0_body.fx0_66
kernel_rfl PRE_first_tail_x15_r0_body.okr0_66 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s651.ffi) = some PRE_first_tail_x15_r0_body.kr0_66
noncomputable def PRE_first_tail_x15_r0_body.fx1_66 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s650.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_66 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s650.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_66 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s650.ffi) = some PRE_first_tail_x15_r0_body.fx1_66
kernel_rfl PRE_first_tail_x15_r0_body.okr1_66 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s650.ffi) = some PRE_first_tail_x15_r0_body.kr1_66
kernel_rfl PRE_first_tail_x15_r0_body.ff066 : PRE_first_tail_x15_r0_body.fx0_66 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_66 (PRE_first_tail_x15_r0_body.clo66.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_66.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff166 : PRE_first_tail_x15_r0_body.fx1_66 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_66 (PRE_first_tail_x15_r0_body.cwS66.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_66.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck66 : freedLB PRE_first_tail_x15_r0_body.kappa66 PRE_first_tail_x15_r0_body.cx0_66.mlx PRE_first_tail_x15_r0_body.fx0_66 PRE_first_tail_x15_r0_body.fx1_66 PRE_first_tail_x15_r0_body.clo66 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf066 : PRE_first_tail_x15_r0_body.kr0_66.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_66.flags (PRE_first_tail_x15_r0_body.clo66.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_66.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt066 : PRE_first_tail_x15_r0_body.kr0_66.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_66.targs (PRE_first_tail_x15_r0_body.clo66.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_66.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf166 : PRE_first_tail_x15_r0_body.kr1_66.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_66.flags (PRE_first_tail_x15_r0_body.cwS66.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_66.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt166 : PRE_first_tail_x15_r0_body.kr1_66.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_66.targs (PRE_first_tail_x15_r0_body.cwS66.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_66.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck66 : krecLB PRE_first_tail_x15_r0_body.kappa66 2924 PRE_first_tail_x15_r0_body.cx0_66.mlx PRE_first_tail_x15_r0_body.kr0_66 PRE_first_tail_x15_r0_body.kr1_66 PRE_first_tail_x15_r0_body.clo66 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn66 : Nat.ble 2906 2924 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge66 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s650.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s651.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR66 : pendRegB PRE_first_tail_x15_r0_body.kappa66 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe66 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s650.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift66 (clean : Conv.NClean (⟨19510, 16589, 2727059, 2906⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P66.NL) (cl : SSt (· < 2924) PRE_first_tail_x15_r0_body.cx0_66.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_66.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_66.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_66.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_66.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19510, 16589, 2727059, 2906⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P66 2924 PRE_first_tail_x15_r0_body.kappa66 PRE_first_tail_x15_r0_body.s651.ffi PRE_first_tail_x15_r0_body.s650.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift66 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue66, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp66 t ht),
    PRE_first_tail_x15_r0_body.cbridge66,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s651.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s650.ffi) (PRE_first_tail_x15_r0_body.cfoot66 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_66 PRE_first_tail_x15_r0_body.ofx1_66 hobjC PRE_first_tail_x15_r0_body.ff066 PRE_first_tail_x15_r0_body.ff166 PRE_first_tail_x15_r0_body.ffck66,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s651.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s650.ffi) (PRE_first_tail_x15_r0_body.cfoot66 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_66 PRE_first_tail_x15_r0_body.okr1_66 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn66) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf066 PRE_first_tail_x15_r0_body.fkt066 PRE_first_tail_x15_r0_body.fkf166 PRE_first_tail_x15_r0_body.fkt166 PRE_first_tail_x15_r0_body.fkck66,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh066 PRE_first_tail_x15_r0_body.cnh166 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe66) PRE_first_tail_x15_r0_body.cpendR66⟩

end Host.Load.Run.Tpl
end

section -- st66/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st66 0
host_stream_state PRE_first_tail_x15_r0_body.st66 1
host_stream_state PRE_first_tail_x15_r0_body.st66 2
host_stream_state PRE_first_tail_x15_r0_body.st66 3
host_stream_state PRE_first_tail_x15_r0_body.st66 4
host_stream_state PRE_first_tail_x15_r0_body.st66 5
end Host.Load.Run.Tpl
end

section -- Site66
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 66 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g66__g67` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s649`, the merged state `PRE_first_tail_x15_r0_body.s650`,
the site template `PRE_first_tail_x15_r0_body.st66` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s651`: the merge.
The footprint's facts are in `SiteF66`, the compaction's in `SiteC66`, `SiteK66`, `SiteNa66`, `SiteNb66`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso66 : PRE_first_tail_x15_r0_body.st66.s0 = { PRE_first_tail_x15_r0_body.s649 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs66 : List Frame := PRE_first_tail_x15_r0_body.s649.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_66 : PRE_first_tail_x15_r0_body.S649.tab.length = 2906
kernel_rfl PRE_first_tail_x15_r0_body.tab0_66 : PRE_first_tail_x15_r0_body.st66.S0.tab = PRE_first_tail_x15_r0_body.S649.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws66 : List Nat := [2115, 2116, 2117, 2118, 2119, 2120, 2121, 2122, 2123, 2124, 2125, 2126, 2127, 2128, 2129, 2130, 2131, 2132, 2133, 2134, 2135, 2136, 2137, 2138, 2139, 2140, 2141, 2142, 2143, 2144, 2145]
kernel_rfl PRE_first_tail_x15_r0_body.fresh66 : (PRE_first_tail_x15_r0_body.S649.tab.all fun e => PRE_first_tail_x15_r0_body.ws66.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S649.oracle.all fun q => PRE_first_tail_x15_r0_body.ws66.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab66 : PRE_first_tail_x15_r0_body.S650.tab = PRE_first_tail_x15_r0_body.S649.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws66
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen66 : PRE_first_tail_x15_r0_body.st66.S5.tab.length - PRE_first_tail_x15_r0_body.st66.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged66`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap66 : PRE_first_tail_x15_r0_body.s650.heap = PRE_first_tail_x15_r0_body.st66.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext66 : PRE_first_tail_x15_r0_body.s650.next = PRE_first_tail_x15_r0_body.st66.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl66 : PRE_first_tail_x15_r0_body.s650.ctl = PRE_first_tail_x15_r0_body.st66.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack66 : PRE_first_tail_x15_r0_body.s650.stack = PRE_first_tail_x15_r0_body.st66.s5.stack ++ PRE_first_tail_x15_r0_body.s649.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs66 : PRE_first_tail_x15_r0_body.s650.jobs = PRE_first_tail_x15_r0_body.st66.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi66 : PRE_first_tail_x15_r0_body.s650.ffi = PRE_first_tail_x15_r0_body.st66.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace66 : PRE_first_tail_x15_r0_body.s650.trace = PRE_first_tail_x15_r0_body.st66.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores66 : PRE_first_tail_x15_r0_body.s650.stores = PRE_first_tail_x15_r0_body.st66.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD66
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 66 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived66 : PRE_first_tail_x15_r0_body.nr66.map (fun r => nth? PRE_first_tail_x15_r0_body.st66.S5.tab r) =
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
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo66 : PRE_first_tail_x15_r0_body.nr66.all (Nat.ble 2906) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj66 : PRE_first_tail_x15_r0_body.cws66.all (fun c => !PRE_first_tail_x15_r0_body.ws66.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ66 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws66 PRE_first_tail_x15_r0_body.crs66 PRE_first_tail_x15_r0_body.ws66

end Host.Load.Run.Tpl
end

section -- st66/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st66`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st66.wrR : List (Nat × Nat) := [(2672465, 2672466), (2726233, 2726234), (2726778, 2726779), (2727034, 2727035)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st66.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st66.s5.heap PRE_first_tail_x15_r0_body.st66.wrR ++ freshOf PRE_first_tail_x15_r0_body.st66.s5.heap PRE_first_tail_x15_r0_body.st66.s0.next PRE_first_tail_x15_r0_body.st66.s5.next
noncomputable def PRE_first_tail_x15_r0_body.st66.wr : List Nat := PRE_first_tail_x15_r0_body.st66.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st66.heapFoot : PRE_first_tail_x15_r0_body.st66.s5.heap = setAll PRE_first_tail_x15_r0_body.st66.s0.heap PRE_first_tail_x15_r0_body.st66.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st66.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st66.s0.next PRE_first_tail_x15_r0_body.st66.s5.next = true
theorem PRE_first_tail_x15_r0_body.st66.grows : PRE_first_tail_x15_r0_body.st66.s0.next ≤ PRE_first_tail_x15_r0_body.st66.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st66.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st66.wh : List Nat := [19490, 19503, 19509, 19510, 19511, 19512, 19513, 19514, 19515, 19516, 19517, 19518, 19519, 19520, 19521, 19522, 19523, 19524, 19525, 19526, 19527, 19528, 19529, 19530, 19531, 19532, 19533, 19534, 19535, 19536, 19537]
def PRE_first_tail_x15_r0_body.st66.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st66.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st66.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st66.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st66.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st66.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st66.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st66.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st66.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st66.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st66.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st66.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st66.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st66.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st66.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st66.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st66.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st66.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st66.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st66.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st66.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st66.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st66.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st66.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st66.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st66.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st66.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st66.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st66.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st66.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF66
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 66 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB66 : nodupT PRE_first_tail_x15_r0_body.st66.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup66 : PRE_first_tail_x15_r0_body.st66.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB66).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB66 : PRE_first_tail_x15_r0_body.st66.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound66 : ∀ b ∈ PRE_first_tail_x15_r0_body.st66.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB66 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr66 := PRE_first_tail_x15_r0_body.st66.s5.trace.take 120
kernel_rfl PRE_first_tail_x15_r0_body.traceEq66 : PRE_first_tail_x15_r0_body.st66.s5.trace = PRE_first_tail_x15_r0_body.trFr66 ++ PRE_first_tail_x15_r0_body.st66.s0.trace
theorem PRE_first_tail_x15_r0_body.trace66 : ∃ fr, PRE_first_tail_x15_r0_body.st66.s5.trace = fr ++ PRE_first_tail_x15_r0_body.st66.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq66⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide66 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB66 : (PRE_first_tail_x15_r0_body.wide66.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st66.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix66 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide66, WFix Map.id (Present PRE_first_tail_x15_r0_body.st66.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB66 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL66
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 66 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s650`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO66 : PRE_first_tail_x15_r0_body.st66.S0.oracle = PRE_first_tail_x15_r0_body.st66.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B66 : PRE_first_tail_x15_r0_body.st66.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st66.s0.next || (PRE_first_tail_x15_r0_body.st66.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot66 : Conv.StageFoot PRE_first_tail_x15_r0_body.st66.wr PRE_first_tail_x15_r0_body.st66.s0 PRE_first_tail_x15_r0_body.st66.s5 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st66.heapFoot PRE_first_tail_x15_r0_body.wrNodup66 PRE_first_tail_x15_r0_body.wrBound66 PRE_first_tail_x15_r0_body.wr0B66 PRE_first_tail_x15_r0_body.st66.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged66 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st66.F.S → PRE_first_tail_x15_r0_body.st66.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st66.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st66.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs66 PRE_first_tail_x15_r0_body.st66.wr PRE_first_tail_x15_r0_body.s649 PRE_first_tail_x15_r0_body.st66.s5 PRE_first_tail_x15_r0_body.st66.s0
      PRE_first_tail_x15_r0_body.st66.s5.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st66.F FR W stk M ν K PRE_first_tail_x15_r0_body.s650 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso66 PRE_first_tail_x15_r0_body.stFoot66 PRE_first_tail_x15_r0_body.wrNodup66 PRE_first_tail_x15_r0_body.wrBound66 PRE_first_tail_x15_r0_body.trace66 PRE_first_tail_x15_r0_body.mheap66
    PRE_first_tail_x15_r0_body.mnext66 PRE_first_tail_x15_r0_body.mctl66 PRE_first_tail_x15_r0_body.mstack66 PRE_first_tail_x15_r0_body.mjobs66 PRE_first_tail_x15_r0_body.mffi66 PRE_first_tail_x15_r0_body.mtrace66 PRE_first_tail_x15_r0_body.mstores66 h

def PRE_first_tail_x15_r0_body.arrEl66_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE66_2665 : arrOf PRE_first_tail_x15_r0_body.s650 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl66_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA66_2665 : isArrB PRE_first_tail_x15_r0_body.s650 2665 = true
theorem PRE_first_tail_x15_r0_body.arr66_2665 : ∃ o, PRE_first_tail_x15_r0_body.s650.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl66_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE66_2665 PRE_first_tail_x15_r0_body.arrA66_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN66_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl66_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR66_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl66_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN66_2665

def PRE_first_tail_x15_r0_body.arrEl66_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE66_2673467 : arrOf PRE_first_tail_x15_r0_body.s650 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl66_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA66_2673467 : isArrB PRE_first_tail_x15_r0_body.s650 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr66_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s650.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl66_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE66_2673467 PRE_first_tail_x15_r0_body.arrA66_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN66_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl66_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR66_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl66_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN66_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k66 : isArrB PRE_first_tail_x15_r0_body.s650 4910 = false
theorem PRE_first_tail_x15_r0_body.keep66 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s650 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k66 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr66_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl66_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ66
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 66 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s649`, the merged
state `PRE_first_tail_x15_r0_body.s650`, the canonical state `PRE_first_tail_x15_r0_body.s651`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl66 : PRE_first_tail_x15_r0_body.pl66.all (Nat.ble PRE_first_tail_x15_r0_body.s649.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd66 : nodupT PRE_first_tail_x15_r0_body.pl66 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn166 : Nat.ble PRE_first_tail_x15_r0_body.s649.next 2728214 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst66 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s649.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn66 : PRE_first_tail_x15_r0_body.s651.next = PRE_first_tail_x15_r0_body.s649.next + PRE_first_tail_x15_r0_body.pl66.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn66 : PRE_first_tail_x15_r0_body.s650.next = 2728214
kernel_rfl PRE_first_tail_x15_r0_body.zgrow66 : Nat.ble PRE_first_tail_x15_r0_body.s651.next PRE_first_tail_x15_r0_body.s650.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh66 : PRE_first_tail_x15_r0_body.S649.tab.all (fun e => PRE_first_tail_x15_r0_body.cws66.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd66 : nodupT PRE_first_tail_x15_r0_body.cws66 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi66 : PRE_first_tail_x15_r0_body.nr66.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S650.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt66 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s649.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg66_2665 : PRE_first_tail_x15_r0_body.s651.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s651 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk66_2665 : (objOf PRE_first_tail_x15_r0_body.s651 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm66_2665 : PRE_first_tail_x15_r0_body.s650.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa66.obj (objOf PRE_first_tail_x15_r0_body.s651 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s650 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg66_2673467 : PRE_first_tail_x15_r0_body.s651.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s651 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk66_2673467 : (objOf PRE_first_tail_x15_r0_body.s651 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm66_2673467 : PRE_first_tail_x15_r0_body.s650.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa66.obj (objOf PRE_first_tail_x15_r0_body.s651 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s650 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw66_4910 : (PRE_first_tail_x15_r0_body.s651.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw66_2673472 : (PRE_first_tail_x15_r0_body.s651.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw66_2673473 : (PRE_first_tail_x15_r0_body.s651.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd66 : PRE_first_tail_x15_r0_body.cl66.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr66 : PRE_first_tail_x15_r0_body.st66.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s649.next || PRE_first_tail_x15_r0_body.cl66.contains b) = true
def PRE_first_tail_x15_r0_body.zl66 : List Nat := PRE_first_tail_x15_r0_body.cl66.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE66 : PRE_first_tail_x15_r0_body.zl66.map (fun a => PRE_first_tail_x15_r0_body.s650.heap.get (PRE_first_tail_x15_r0_body.kappa66.a a)) = PRE_first_tail_x15_r0_body.zl66.map (fun a => (PRE_first_tail_x15_r0_body.s651.heap.get a).map PRE_first_tail_x15_r0_body.kappa66.hobj)
theorem PRE_first_tail_x15_r0_body.zimg66 : HeapImg PRE_first_tail_x15_r0_body.kappa66 PRE_first_tail_x15_r0_body.s651 PRE_first_tail_x15_r0_body.s650 PRE_first_tail_x15_r0_body.zl66 := PRE_first_tail_x15_r0_body.zimgE66
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl66 : PRE_first_tail_x15_r0_body.s650.ctl = PRE_first_tail_x15_r0_body.kappa66.ctl PRE_first_tail_x15_r0_body.s651.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack66 : PRE_first_tail_x15_r0_body.s650.stack = PRE_first_tail_x15_r0_body.s651.stack.map PRE_first_tail_x15_r0_body.kappa66.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs66 : PRE_first_tail_x15_r0_body.s650.jobs = PRE_first_tail_x15_r0_body.s651.jobs.map PRE_first_tail_x15_r0_body.kappa66.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores66 : PRE_first_tail_x15_r0_body.s650.stores = PRE_first_tail_x15_r0_body.kappa66.stores PRE_first_tail_x15_r0_body.s651.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots66 : checkRootsSupp PRE_first_tail_x15_r0_body.s651 2924 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC66 : PRE_first_tail_x15_r0_body.S649.tab.length + PRE_first_tail_x15_r0_body.cws66.length = 2924
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap66 : PRE_first_tail_x15_r0_body.kappa66 = Conv.Map.compact PRE_first_tail_x15_r0_body.s649.next 2728214 PRE_first_tail_x15_r0_body.S649.tab.length PRE_first_tail_x15_r0_body.pl66 (PRE_first_tail_x15_r0_body.nr66.map NumV.ref) PRE_first_tail_x15_r0_body.kd66.big
  PRE_first_tail_x15_r0_body.kd66.region PRE_first_tail_x15_r0_body.kd66.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin66 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s651.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc66 : Conv.jcleanListB (⟨19513, 16616, 2727065, 2924⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s651 PRE_first_tail_x15_r0_body.cl66 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB66 : noBigRootsP (fun i => !Conv.oldBigB (⟨19513, 16616, 2727065, 2924⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s651.trace PRE_first_tail_x15_r0_body.s651 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm66 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16589 = true
theorem PRE_first_tail_x15_r0_body.cjcl66 (h : Conv.JClean (⟨19510, 16589, 2727059, 2906⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s649) : Conv.JClean (⟨19513, 16616, 2727065, 2924⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s651 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle66)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap66 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd66 a ha)) PRE_first_tail_x15_r0_body.zjc66

end Host.Load.Run.Tpl
end

section -- st66/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st66.bodyLast from PRE_first_tail_x15_r0_body.st66.s4 to PRE_first_tail_x15_r0_body.st66.s5 :
  interpS (step PRE_first_tail_x15_r0_body.st66.F PRE_first_tail_x15_r0_body.st66.s4).run PRE_first_tail_x15_r0_body.st66.S4 = some (PRE_first_tail_x15_r0_body.st66.s5, PRE_first_tail_x15_r0_body.st66.S5)
kernel_rfl PRE_first_tail_x15_r0_body.st66.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st66.s4.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st66.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st66.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st66/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st66.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st66.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st66.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st66.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st66.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st66.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st66.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st66.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st66.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st66.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st66.s0 PRE_first_tail_x15_r0_body.st66.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st66.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st66.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st66.s4 PRE_first_tail_x15_r0_body.st66.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st66/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st66.bodyK0F from PRE_first_tail_x15_r0_body.st66.s0 to PRE_first_tail_x15_r0_body.st66.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st66.F (PRE_first_tail_x15_r0_body.st66.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st66.ks 0).getD 0) PRE_first_tail_x15_r0_body.st66.s0 PRE_first_tail_x15_r0_body.st66.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st66.s1, PRE_first_tail_x15_r0_body.st66.S1)
theorem PRE_first_tail_x15_r0_body.st66.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st66.F (PRE_first_tail_x15_r0_body.st66.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st66.ks 0).getD 0) PRE_first_tail_x15_r0_body.st66.s0 PRE_first_tail_x15_r0_body.st66.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st66.s1, PRE_first_tail_x15_r0_body.st66.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st66.bodyOkLN_ok PRE_first_tail_x15_r0_body.st66.bodyK0F
end Host.Load.Run.Tpl
end

section -- st66/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st66.bodyK1F from PRE_first_tail_x15_r0_body.st66.s1 to PRE_first_tail_x15_r0_body.st66.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st66.F (PRE_first_tail_x15_r0_body.st66.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st66.ks 1).getD 0) PRE_first_tail_x15_r0_body.st66.s1 PRE_first_tail_x15_r0_body.st66.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st66.s2, PRE_first_tail_x15_r0_body.st66.S2)
theorem PRE_first_tail_x15_r0_body.st66.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st66.F (PRE_first_tail_x15_r0_body.st66.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st66.ks 1).getD 0) PRE_first_tail_x15_r0_body.st66.s1 PRE_first_tail_x15_r0_body.st66.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st66.s2, PRE_first_tail_x15_r0_body.st66.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st66.bodyOkLN_ok PRE_first_tail_x15_r0_body.st66.bodyK1F
end Host.Load.Run.Tpl
end

section -- st66/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st66.bodyK2F from PRE_first_tail_x15_r0_body.st66.s2 to PRE_first_tail_x15_r0_body.st66.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st66.F (PRE_first_tail_x15_r0_body.st66.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st66.ks 2).getD 0) PRE_first_tail_x15_r0_body.st66.s2 PRE_first_tail_x15_r0_body.st66.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st66.s3, PRE_first_tail_x15_r0_body.st66.S3)
theorem PRE_first_tail_x15_r0_body.st66.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st66.F (PRE_first_tail_x15_r0_body.st66.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st66.ks 2).getD 0) PRE_first_tail_x15_r0_body.st66.s2 PRE_first_tail_x15_r0_body.st66.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st66.s3, PRE_first_tail_x15_r0_body.st66.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st66.bodyOkLN_ok PRE_first_tail_x15_r0_body.st66.bodyK2F
end Host.Load.Run.Tpl
end

section -- st66/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st66.bodyK3F from PRE_first_tail_x15_r0_body.st66.s3 to PRE_first_tail_x15_r0_body.st66.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st66.F (PRE_first_tail_x15_r0_body.st66.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st66.ks 3).getD 0) PRE_first_tail_x15_r0_body.st66.s3 PRE_first_tail_x15_r0_body.st66.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st66.s4, PRE_first_tail_x15_r0_body.st66.S4)
theorem PRE_first_tail_x15_r0_body.st66.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st66.F (PRE_first_tail_x15_r0_body.st66.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st66.ks 3).getD 0) PRE_first_tail_x15_r0_body.st66.s3 PRE_first_tail_x15_r0_body.st66.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st66.s4, PRE_first_tail_x15_r0_body.st66.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st66.bodyOkLN_ok PRE_first_tail_x15_r0_body.st66.bodyK3F
end Host.Load.Run.Tpl
end

section -- st66/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st66.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st66.F (PRE_first_tail_x15_r0_body.st66.bodyOkL bytes rows) 11334 PRE_first_tail_x15_r0_body.st66.s0 PRE_first_tail_x15_r0_body.st66.S0 = some (PRE_first_tail_x15_r0_body.st66.s4, PRE_first_tail_x15_r0_body.st66.S4) :=
  runOk_trans PRE_first_tail_x15_r0_body.st66.F (PRE_first_tail_x15_r0_body.st66.bodyOkL bytes rows) ((((nth? PRE_first_tail_x15_r0_body.st66.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st66.ks 1).getD 0)) + ((nth? PRE_first_tail_x15_r0_body.st66.ks 2).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st66.ks 3).getD 0) PRE_first_tail_x15_r0_body.st66.s0 PRE_first_tail_x15_r0_body.st66.s3 PRE_first_tail_x15_r0_body.st66.s4 PRE_first_tail_x15_r0_body.st66.S0 PRE_first_tail_x15_r0_body.st66.S3 PRE_first_tail_x15_r0_body.st66.S4 (runOk_trans PRE_first_tail_x15_r0_body.st66.F (PRE_first_tail_x15_r0_body.st66.bodyOkL bytes rows) (((nth? PRE_first_tail_x15_r0_body.st66.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st66.ks 1).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st66.ks 2).getD 0) PRE_first_tail_x15_r0_body.st66.s0 PRE_first_tail_x15_r0_body.st66.s2 PRE_first_tail_x15_r0_body.st66.s3 PRE_first_tail_x15_r0_body.st66.S0 PRE_first_tail_x15_r0_body.st66.S2 PRE_first_tail_x15_r0_body.st66.S3 (runOk_trans PRE_first_tail_x15_r0_body.st66.F (PRE_first_tail_x15_r0_body.st66.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st66.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st66.ks 1).getD 0) PRE_first_tail_x15_r0_body.st66.s0 PRE_first_tail_x15_r0_body.st66.s1 PRE_first_tail_x15_r0_body.st66.s2 PRE_first_tail_x15_r0_body.st66.S0 PRE_first_tail_x15_r0_body.st66.S1 PRE_first_tail_x15_r0_body.st66.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st66.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st66.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st66.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st66.bodyK3 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st66.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st66.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st66.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st66.F (PRE_first_tail_x15_r0_body.st66.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st66.s0
  S0 := PRE_first_tail_x15_r0_body.st66.S0
  s1 := PRE_first_tail_x15_r0_body.st66.s4
  S1 := PRE_first_tail_x15_r0_body.st66.S4
  s2 := PRE_first_tail_x15_r0_body.st66.s5
  S2 := PRE_first_tail_x15_r0_body.st66.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st66.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st66.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st66.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st66.bodyHalt
  last := PRE_first_tail_x15_r0_body.st66.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st66.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC67
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 67 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s659` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa67` into the merged state
`PRE_first_tail_x15_r0_body.s658`. -/

def PRE_first_tail_x15_r0_body.pl67 : List Nat := []
def PRE_first_tail_x15_r0_body.nr67 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd67 : RData :=
  ⟨2727555, 2727557, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19526, 19526, 16629, 16629, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa67 : Map :=
  Conv.Map.compact 2727555 2727557 2945 PRE_first_tail_x15_r0_body.pl67 (PRE_first_tail_x15_r0_body.nr67.map NumV.ref) PRE_first_tail_x15_r0_body.kd67.big
    PRE_first_tail_x15_r0_body.kd67.region PRE_first_tail_x15_r0_body.kd67.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws67 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs67 : List SymE := PRE_first_tail_x15_r0_body.nr67.map fun r => (nth? PRE_first_tail_x15_r0_body.S658.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta67 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws67 PRE_first_tail_x15_r0_body.crs67
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB67 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab67 : PRE_first_tail_x15_r0_body.S659.tab = PRE_first_tail_x15_r0_body.S657.tab ++ PRE_first_tail_x15_r0_body.cws67.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace67 : PRE_first_tail_x15_r0_body.s659.trace = PRE_first_tail_x15_r0_body.s657.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext67 : PRE_first_tail_x15_r0_body.s659.next = 2727555
kernel_rfl PRE_first_tail_x15_r0_body.ccounters67 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s659.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s659.ffi).mlx.nnext) = (19526, 16629)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue67 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s658.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s659.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa67.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp67 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s659.ffi).mlx.tokens.all (bSN 2945) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean67 : Conv.cleanListB 19526 131072 (fun r => Nat.ble 78104 r) PRE_first_tail_x15_r0_body.s659
    (PRE_first_tail_x15_r0_body.wrB67 ++ (List.range 0).map (2727555 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs67 : bigsOutB 19526 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s659.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK67
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl67`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl67 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo67 : List Nat := []
def PRE_first_tail_x15_r0_body.cln67 : List Nat := []
def PRE_first_tail_x15_r0_body.cli67 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap67 : PRE_first_tail_x15_r0_body.s659.heap = Stage.setAll PRE_first_tail_x15_r0_body.s657.heap (PRE_first_tail_x15_r0_body.cl67.filterMap fun a => (PRE_first_tail_x15_r0_body.s659.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe67 : Nat.ble PRE_first_tail_x15_r0_body.s657.next PRE_first_tail_x15_r0_body.s659.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP67 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s657 PRE_first_tail_x15_r0_body.s659 PRE_first_tail_x15_r0_body.cl67 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp67 : Conv.suppListB PRE_first_tail_x15_r0_body.s659 2945 PRE_first_tail_x15_r0_body.cl67 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound67 : Conv.boundListB PRE_first_tail_x15_r0_body.s659 PRE_first_tail_x15_r0_body.cl67 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK67 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s659.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln67.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s659.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK67 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s659.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo67.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s659.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK67 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s659.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli67.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s659.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst67 : Conv.sstListB 2945 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s659.ffi).mlx PRE_first_tail_x15_r0_body.cln67 PRE_first_tail_x15_r0_body.clo67 PRE_first_tail_x15_r0_body.cli67 = true

end Host.Load.Run.Tpl
end

section -- SiteCl67
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA67 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s659.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo67.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s659.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd67 : (PRE_first_tail_x15_r0_body.clo67 ++ PRE_first_tail_x15_r0_body.cln67 ++ PRE_first_tail_x15_r0_body.cli67).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle67 : Conv.Cnt.leB (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck67 : Conv.ncleanListB (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s659.ffi).mlx PRE_first_tail_x15_r0_body.clo67 PRE_first_tail_x15_r0_body.cln67 PRE_first_tail_x15_r0_body.cli67 = true
theorem PRE_first_tail_x15_r0_body.cncl67 (h : Conv.NClean (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx) : Conv.NClean (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s659.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle67 PRE_first_tail_x15_r0_body.ckA67 PRE_first_tail_x15_r0_body.cobjsK67 PRE_first_tail_x15_r0_body.cnodesK67 PRE_first_tail_x15_r0_body.citemsK67 PRE_first_tail_x15_r0_body.cbd67 PRE_first_tail_x15_r0_body.cck67

end Host.Load.Run.Tpl
end

section -- SiteS67
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 67 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc67 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P67 : LoadP := PRE_first_tail_x15_r0_body.Pc67.raise 16629
kernel_rfl PRE_first_tail_x15_r0_body.craise67 : Nat.ble PRE_first_tail_x15_r0_body.Pc67.N0 16629 = true
theorem PRE_first_tail_x15_r0_body.raised67 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc67 PRE_first_tail_x15_r0_body.P67 :=
  .inr ⟨16629, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise67, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_67 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s659.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_67 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s658.ffi)
def PRE_first_tail_x15_r0_body.khinv67 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv67 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS67 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS67 : List Nat := List.range' 16629 0
def PRE_first_tail_x15_r0_body.ciS67 : List Nat := [] ++ List.range' 16629 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh067 : PRE_first_tail_x15_r0_body.kd67.nh0 = PRE_first_tail_x15_r0_body.cx0_67.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh167 : PRE_first_tail_x15_r0_body.kd67.nh1 = PRE_first_tail_x15_r0_body.cx1_67.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn067 : PRE_first_tail_x15_r0_body.kd67.nn0 = PRE_first_tail_x15_r0_body.cx0_67.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn167 : PRE_first_tail_x15_r0_body.kd67.nn1 = PRE_first_tail_x15_r0_body.cx1_67.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo67 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P67.lo && Nat.ble PRE_first_tail_x15_r0_body.P67.lo PRE_first_tail_x15_r0_body.cx0_67.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P67.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P67.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt67 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_67.mlx.next PRE_first_tail_x15_r0_body.cx1_67.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_67.mlx.nnext PRE_first_tail_x15_r0_body.cx1_67.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband67 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P67.NL && Nat.ble PRE_first_tail_x15_r0_body.P67.NL PRE_first_tail_x15_r0_body.P67.N0 && Nat.ble PRE_first_tail_x15_r0_body.P67.N0 PRE_first_tail_x15_r0_body.cx0_67.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow67 : PRE_first_tail_x15_r0_body.kd67.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren67 : checkRenG PRE_first_tail_x15_r0_body.kd67.hnd PRE_first_tail_x15_r0_body.khinv67 (phB PRE_first_tail_x15_r0_body.cx0_67.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband67 : PRE_first_tail_x15_r0_body.kd67.checkBand PRE_first_tail_x15_r0_body.P67.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos67 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd67.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren67 : checkRenG PRE_first_tail_x15_r0_body.kd67.node PRE_first_tail_x15_r0_body.kninv67 (pnB PRE_first_tail_x15_r0_body.cx0_67.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow67 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd67.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P67.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd67.nodeF j) PRE_first_tail_x15_r0_body.cx1_67.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a67 : PRE_first_tail_x15_r0_body.cx0_67.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b67 : PRE_first_tail_x15_r0_body.cx0_67.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok167 : PRE_first_tail_x15_r0_body.cx1_67.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend67 : PRE_first_tail_x15_r0_body.cx1_67.mlx.pending = PRE_first_tail_x15_r0_body.cx0_67.mlx.pending.map PRE_first_tail_x15_r0_body.kappa67.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh67 : PRE_first_tail_x15_r0_body.cx1_67.mlx.errh = PRE_first_tail_x15_r0_body.cx0_67.mlx.errh.map PRE_first_tail_x15_r0_body.kappa67.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles67 : PRE_first_tail_x15_r0_body.cx1_67.mlx.files = PRE_first_tail_x15_r0_body.cx0_67.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch67 : PRE_first_tail_x15_r0_body.cx1_67.mlx.arch = PRE_first_tail_x15_r0_body.cx0_67.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes67 : PRE_first_tail_x15_r0_body.cx1_67.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_67.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired67 : PRE_first_tail_x15_r0_body.cx1_67.mlx.wired = PRE_first_tail_x15_r0_body.cx0_67.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost67 : PRE_first_tail_x15_r0_body.cx1_67.host = PRE_first_tail_x15_r0_body.cx0_67.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd67`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn067 : PRE_first_tail_x15_r0_body.kd67.n0 = 2727555
kernel_rfl PRE_first_tail_x15_r0_body.ckn167 : PRE_first_tail_x15_r0_body.kd67.n1 = 2727557
kernel_rfl PRE_first_tail_x15_r0_body.ckheap67 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd67.heap).all (fun x => Nat.ble 2727555 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl67 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd67.heap.get (2727555 + j) = nth? PRE_first_tail_x15_r0_body.pl67 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja67 : Nat.ble 2727555 2727555 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn67 : Nat.ble 2945 2945 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD67 : Nat.ble 2727555 PRE_first_tail_x15_r0_body.kd67.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn67 : Nat.ble 19526 PRE_first_tail_x15_r0_body.kd67.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn67 : Nat.ble 16629 PRE_first_tail_x15_r0_body.kd67.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb67 : Nat.ble 19526 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap67 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd67.heap).all (Nat.ble (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd67 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd67.hnd).all (Nat.ble (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode67 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd67.node).all (Nat.ble (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix67 : Conv.FixOld (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa67 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja67) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn67) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD67) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn67) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn67) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb67) PRE_first_tail_x15_r0_body.fheap67 PRE_first_tail_x15_r0_body.fhnd67 PRE_first_tail_x15_r0_body.fnode67
kernel_rfl PRE_first_tail_x15_r0_body.fcxn67 : (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn67 : (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle067 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_67.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_67.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk67 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd67.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A67 : PRE_first_tail_x15_r0_body.cx1_67.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS67.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_67.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O67 : PRE_first_tail_x15_r0_body.cx1_67.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS67.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_67.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N67 : PRE_first_tail_x15_r0_body.cx1_67.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS67.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_67.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I67 : PRE_first_tail_x15_r0_body.cx1_67.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS67.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_67.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd67 : (PRE_first_tail_x15_r0_body.clo67 ++ PRE_first_tail_x15_r0_body.cln67 ++ PRE_first_tail_x15_r0_body.cli67 ++ PRE_first_tail_x15_r0_body.cwS67 ++ PRE_first_tail_x15_r0_body.cnS67 ++ PRE_first_tail_x15_r0_body.ciS67).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW67 : PRE_first_tail_x15_r0_body.cwS67.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo67.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI67 : PRE_first_tail_x15_r0_body.ciS67.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli67.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN67 : PRE_first_tail_x15_r0_body.cnS67.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF67 : PRE_first_tail_x15_r0_body.cln67.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh67 : PRE_first_tail_x15_r0_body.clo67.all (handleOK PRE_first_tail_x15_r0_body.kappa67 PRE_first_tail_x15_r0_body.P67.lo PRE_first_tail_x15_r0_body.cx0_67.mlx PRE_first_tail_x15_r0_body.cx1_67.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo67 : PRE_first_tail_x15_r0_body.clo67.map (fun h => PRE_first_tail_x15_r0_body.cx1_67.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa67.handle h)) = PRE_first_tail_x15_r0_body.clo67.map (fun h => (PRE_first_tail_x15_r0_body.cx0_67.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa67.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok67 : PRE_first_tail_x15_r0_body.clo67.all (objOK PRE_first_tail_x15_r0_body.kappa67 PRE_first_tail_x15_r0_body.P67.NL PRE_first_tail_x15_r0_body.cx0_67.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd67 : PRE_first_tail_x15_r0_body.cln67.all (nodeOKF PRE_first_tail_x15_r0_body.kappa67 PRE_first_tail_x15_r0_body.P67 PRE_first_tail_x15_r0_body.cx0_67.mlx PRE_first_tail_x15_r0_body.cx1_67.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp67 : ((PRE_first_tail_x15_r0_body.cln67.filter (fullB PRE_first_tail_x15_r0_body.P67))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_67.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa67.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln67.filter (fullB PRE_first_tail_x15_r0_body.P67))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_67.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa67.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI67 : incrB PRE_first_tail_x15_r0_body.kd67.nodeF (List.range' 16629 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK67 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd67.node).all (fun k => Nat.ble 16629 k && Nat.blt k 16629) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL67 : (PRE_first_tail_x15_r0_body.cln67.filter (Nat.ble PRE_first_tail_x15_r0_body.P67.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd67.nodeF i) && (Nat.blt i 16629 || Nat.ble PRE_first_tail_x15_r0_body.kd67.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord67 : (PRE_first_tail_x15_r0_body.cln67.filter (Nat.ble PRE_first_tail_x15_r0_body.P67.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd67.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd67.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd67.nodeF j) (PRE_first_tail_x15_r0_body.kd67.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow67 PRE_first_tail_x15_r0_body.cnn167 PRE_first_tail_x15_r0_body.fnordI67 PRE_first_tail_x15_r0_body.fnordK67 PRE_first_tail_x15_r0_body.fnordL67
kernel_rfl PRE_first_tail_x15_r0_body.fi67 : PRE_first_tail_x15_r0_body.cli67.all (pnB PRE_first_tail_x15_r0_body.cx0_67.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii67 : PRE_first_tail_x15_r0_body.cli67.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_67.mlx.items.get (PRE_first_tail_x15_r0_body.kappa67.node k) = (PRE_first_tail_x15_r0_body.cx0_67.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa67.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot67 (clean : Conv.NClean (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P67.NL) (cl : SSt (· < 2945) PRE_first_tail_x15_r0_body.cx0_67.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P67 2945 PRE_first_tail_x15_r0_body.kappa67 PRE_first_tail_x15_r0_body.kd67 PRE_first_tail_x15_r0_body.khinv67 PRE_first_tail_x15_r0_body.kninv67 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx PRE_first_tail_x15_r0_body.cx0_67.mlx PRE_first_tail_x15_r0_body.cx1_67.mlx (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo67 PRE_first_tail_x15_r0_body.cln67 PRE_first_tail_x15_r0_body.cli67 PRE_first_tail_x15_r0_body.cwS67 PRE_first_tail_x15_r0_body.cnS67 PRE_first_tail_x15_r0_body.ciS67 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh067, PRE_first_tail_x15_r0_body.cnh167, PRE_first_tail_x15_r0_body.cnn067, PRE_first_tail_x15_r0_body.cnn167, PRE_first_tail_x15_r0_body.cplo67, PRE_first_tail_x15_r0_body.ccnt67, PRE_first_tail_x15_r0_body.cnband67, PRE_first_tail_x15_r0_body.chbelow67, PRE_first_tail_x15_r0_body.chren67, PRE_first_tail_x15_r0_body.cband67, PRE_first_tail_x15_r0_body.cnh1pos67, PRE_first_tail_x15_r0_body.cnren67, PRE_first_tail_x15_r0_body.cnlow67, PRE_first_tail_x15_r0_body.cabs0a67, PRE_first_tail_x15_r0_body.cabs0b67, PRE_first_tail_x15_r0_body.ctok167, PRE_first_tail_x15_r0_body.cpend67, PRE_first_tail_x15_r0_body.cerrh67, PRE_first_tail_x15_r0_body.cfiles67, PRE_first_tail_x15_r0_body.carch67, PRE_first_tail_x15_r0_body.csizes67, PRE_first_tail_x15_r0_body.cwired67, PRE_first_tail_x15_r0_body.cfix67, clean, PRE_first_tail_x15_r0_body.fcxn67, PRE_first_tail_x15_r0_body.fcnn67, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle067, PRE_first_tail_x15_r0_body.fnk67, PRE_first_tail_x15_r0_body.ckA67, PRE_first_tail_x15_r0_body.cobjsK67, PRE_first_tail_x15_r0_body.cnodesK67, PRE_first_tail_x15_r0_body.citemsK67, PRE_first_tail_x15_r0_body.f1A67, PRE_first_tail_x15_r0_body.f1O67, PRE_first_tail_x15_r0_body.f1N67, PRE_first_tail_x15_r0_body.f1I67, PRE_first_tail_x15_r0_body.fbd67, PRE_first_tail_x15_r0_body.fincW67, PRE_first_tail_x15_r0_body.fincI67, PRE_first_tail_x15_r0_body.fincN67, PRE_first_tail_x15_r0_body.flnF67, PRE_first_tail_x15_r0_body.fh67, PRE_first_tail_x15_r0_body.fo67, PRE_first_tail_x15_r0_body.fok67, PRE_first_tail_x15_r0_body.fnd67, PRE_first_tail_x15_r0_body.fp67, PRE_first_tail_x15_r0_body.fnord67, PRE_first_tail_x15_r0_body.fi67, PRE_first_tail_x15_r0_body.fii67⟩
theorem PRE_first_tail_x15_r0_body.cnshift67 (clean : Conv.NClean (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P67.NL) (cl : SSt (· < 2945) PRE_first_tail_x15_r0_body.cx0_67.mlx) : NShift PRE_first_tail_x15_r0_body.P67 2945 PRE_first_tail_x15_r0_body.kappa67 PRE_first_tail_x15_r0_body.cx0_67 PRE_first_tail_x15_r0_body.cx1_67 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot67 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost67 (compact_a_eq PRE_first_tail_x15_r0_body.ckn067 PRE_first_tail_x15_r0_body.ckn167 PRE_first_tail_x15_r0_body.ckheap67 PRE_first_tail_x15_r0_body.ckpl67)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_67 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s657.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_67 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s657.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_67 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s657.ffi) = some PRE_first_tail_x15_r0_body.fxC_67
kernel_rfl PRE_first_tail_x15_r0_body.okrC_67 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s657.ffi) = some PRE_first_tail_x15_r0_body.krC_67
noncomputable def PRE_first_tail_x15_r0_body.fx0_67 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s659.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_67 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s659.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_67 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s659.ffi) = some PRE_first_tail_x15_r0_body.fx0_67
kernel_rfl PRE_first_tail_x15_r0_body.okr0_67 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s659.ffi) = some PRE_first_tail_x15_r0_body.kr0_67
noncomputable def PRE_first_tail_x15_r0_body.fx1_67 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s658.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_67 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s658.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_67 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s658.ffi) = some PRE_first_tail_x15_r0_body.fx1_67
kernel_rfl PRE_first_tail_x15_r0_body.okr1_67 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s658.ffi) = some PRE_first_tail_x15_r0_body.kr1_67
kernel_rfl PRE_first_tail_x15_r0_body.ff067 : PRE_first_tail_x15_r0_body.fx0_67 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_67 (PRE_first_tail_x15_r0_body.clo67.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_67.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff167 : PRE_first_tail_x15_r0_body.fx1_67 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_67 (PRE_first_tail_x15_r0_body.cwS67.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_67.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck67 : freedLB PRE_first_tail_x15_r0_body.kappa67 PRE_first_tail_x15_r0_body.cx0_67.mlx PRE_first_tail_x15_r0_body.fx0_67 PRE_first_tail_x15_r0_body.fx1_67 PRE_first_tail_x15_r0_body.clo67 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf067 : PRE_first_tail_x15_r0_body.kr0_67.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_67.flags (PRE_first_tail_x15_r0_body.clo67.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_67.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt067 : PRE_first_tail_x15_r0_body.kr0_67.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_67.targs (PRE_first_tail_x15_r0_body.clo67.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_67.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf167 : PRE_first_tail_x15_r0_body.kr1_67.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_67.flags (PRE_first_tail_x15_r0_body.cwS67.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_67.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt167 : PRE_first_tail_x15_r0_body.kr1_67.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_67.targs (PRE_first_tail_x15_r0_body.cwS67.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_67.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck67 : krecLB PRE_first_tail_x15_r0_body.kappa67 2945 PRE_first_tail_x15_r0_body.cx0_67.mlx PRE_first_tail_x15_r0_body.kr0_67 PRE_first_tail_x15_r0_body.kr1_67 PRE_first_tail_x15_r0_body.clo67 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn67 : Nat.ble 2945 2945 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge67 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s658.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s659.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR67 : pendRegB PRE_first_tail_x15_r0_body.kappa67 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s659.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe67 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s659.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s658.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift67 (clean : Conv.NClean (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P67.NL) (cl : SSt (· < 2945) PRE_first_tail_x15_r0_body.cx0_67.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_67.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_67.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_67.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_67.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P67 2945 PRE_first_tail_x15_r0_body.kappa67 PRE_first_tail_x15_r0_body.s659.ffi PRE_first_tail_x15_r0_body.s658.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift67 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue67, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp67 t ht),
    PRE_first_tail_x15_r0_body.cbridge67,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s659.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s658.ffi) (PRE_first_tail_x15_r0_body.cfoot67 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_67 PRE_first_tail_x15_r0_body.ofx1_67 hobjC PRE_first_tail_x15_r0_body.ff067 PRE_first_tail_x15_r0_body.ff167 PRE_first_tail_x15_r0_body.ffck67,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s659.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s658.ffi) (PRE_first_tail_x15_r0_body.cfoot67 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_67 PRE_first_tail_x15_r0_body.okr1_67 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn67) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf067 PRE_first_tail_x15_r0_body.fkt067 PRE_first_tail_x15_r0_body.fkf167 PRE_first_tail_x15_r0_body.fkt167 PRE_first_tail_x15_r0_body.fkck67,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh067 PRE_first_tail_x15_r0_body.cnh167 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe67) PRE_first_tail_x15_r0_body.cpendR67⟩

end Host.Load.Run.Tpl
end

section -- st67/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st67 0
host_stream_state PRE_first_tail_x15_r0_body.st67 1
host_stream_state PRE_first_tail_x15_r0_body.st67 2
end Host.Load.Run.Tpl
end

section -- Site67
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 67 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g67__g68` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s657`, the merged state `PRE_first_tail_x15_r0_body.s658`,
the site template `PRE_first_tail_x15_r0_body.st67` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s659`: the merge.
The footprint's facts are in `SiteF67`, the compaction's in `SiteC67`, `SiteK67`, `SiteNa67`, `SiteNb67`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso67 : PRE_first_tail_x15_r0_body.st67.s0 = { PRE_first_tail_x15_r0_body.s657 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs67 : List Frame := PRE_first_tail_x15_r0_body.s657.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_67 : PRE_first_tail_x15_r0_body.S657.tab.length = 2945
kernel_rfl PRE_first_tail_x15_r0_body.tab0_67 : PRE_first_tail_x15_r0_body.st67.S0.tab = PRE_first_tail_x15_r0_body.S657.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws67 : List Nat := [2164, 2165]
kernel_rfl PRE_first_tail_x15_r0_body.fresh67 : (PRE_first_tail_x15_r0_body.S657.tab.all fun e => PRE_first_tail_x15_r0_body.ws67.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S657.oracle.all fun q => PRE_first_tail_x15_r0_body.ws67.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab67 : PRE_first_tail_x15_r0_body.S658.tab = PRE_first_tail_x15_r0_body.S657.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws67
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen67 : PRE_first_tail_x15_r0_body.st67.S2.tab.length - PRE_first_tail_x15_r0_body.st67.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged67`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap67 : PRE_first_tail_x15_r0_body.s658.heap = PRE_first_tail_x15_r0_body.st67.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext67 : PRE_first_tail_x15_r0_body.s658.next = PRE_first_tail_x15_r0_body.st67.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl67 : PRE_first_tail_x15_r0_body.s658.ctl = PRE_first_tail_x15_r0_body.st67.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack67 : PRE_first_tail_x15_r0_body.s658.stack = PRE_first_tail_x15_r0_body.st67.s2.stack ++ PRE_first_tail_x15_r0_body.s657.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs67 : PRE_first_tail_x15_r0_body.s658.jobs = PRE_first_tail_x15_r0_body.st67.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi67 : PRE_first_tail_x15_r0_body.s658.ffi = PRE_first_tail_x15_r0_body.st67.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace67 : PRE_first_tail_x15_r0_body.s658.trace = PRE_first_tail_x15_r0_body.st67.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores67 : PRE_first_tail_x15_r0_body.s658.stores = PRE_first_tail_x15_r0_body.st67.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD67
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 67 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived67 : PRE_first_tail_x15_r0_body.nr67.map (fun r => nth? PRE_first_tail_x15_r0_body.st67.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo67 : PRE_first_tail_x15_r0_body.nr67.all (Nat.ble 2945) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj67 : PRE_first_tail_x15_r0_body.cws67.all (fun c => !PRE_first_tail_x15_r0_body.ws67.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ67 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws67 PRE_first_tail_x15_r0_body.crs67 PRE_first_tail_x15_r0_body.ws67

end Host.Load.Run.Tpl
end

section -- st67/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st67`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st67.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st67.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st67.s2.heap PRE_first_tail_x15_r0_body.st67.wrR ++ freshOf PRE_first_tail_x15_r0_body.st67.s2.heap PRE_first_tail_x15_r0_body.st67.s0.next PRE_first_tail_x15_r0_body.st67.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st67.wr : List Nat := PRE_first_tail_x15_r0_body.st67.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st67.heapFoot : PRE_first_tail_x15_r0_body.st67.s2.heap = setAll PRE_first_tail_x15_r0_body.st67.s0.heap PRE_first_tail_x15_r0_body.st67.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st67.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st67.s0.next PRE_first_tail_x15_r0_body.st67.s2.next = true
theorem PRE_first_tail_x15_r0_body.st67.grows : PRE_first_tail_x15_r0_body.st67.s0.next ≤ PRE_first_tail_x15_r0_body.st67.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st67.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st67.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st67.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st67.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st67.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st67.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st67.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st67.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st67.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st67.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st67.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st67.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st67.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st67.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st67.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st67.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st67.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st67.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st67.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st67.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st67.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st67.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st67.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st67.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st67.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st67.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st67.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st67.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st67.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st67.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st67.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st67.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF67
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 67 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB67 : nodupT PRE_first_tail_x15_r0_body.st67.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup67 : PRE_first_tail_x15_r0_body.st67.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB67).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB67 : PRE_first_tail_x15_r0_body.st67.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound67 : ∀ b ∈ PRE_first_tail_x15_r0_body.st67.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB67 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr67 := PRE_first_tail_x15_r0_body.st67.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq67 : PRE_first_tail_x15_r0_body.st67.s2.trace = PRE_first_tail_x15_r0_body.trFr67 ++ PRE_first_tail_x15_r0_body.st67.s0.trace
theorem PRE_first_tail_x15_r0_body.trace67 : ∃ fr, PRE_first_tail_x15_r0_body.st67.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st67.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq67⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide67 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB67 : (PRE_first_tail_x15_r0_body.wide67.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st67.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix67 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide67, WFix Map.id (Present PRE_first_tail_x15_r0_body.st67.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB67 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL67
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 67 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s658`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO67 : PRE_first_tail_x15_r0_body.st67.S0.oracle = PRE_first_tail_x15_r0_body.st67.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B67 : PRE_first_tail_x15_r0_body.st67.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st67.s0.next || (PRE_first_tail_x15_r0_body.st67.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot67 : Conv.StageFoot PRE_first_tail_x15_r0_body.st67.wr PRE_first_tail_x15_r0_body.st67.s0 PRE_first_tail_x15_r0_body.st67.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st67.heapFoot PRE_first_tail_x15_r0_body.wrNodup67 PRE_first_tail_x15_r0_body.wrBound67 PRE_first_tail_x15_r0_body.wr0B67 PRE_first_tail_x15_r0_body.st67.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged67 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st67.F.S → PRE_first_tail_x15_r0_body.st67.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st67.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st67.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs67 PRE_first_tail_x15_r0_body.st67.wr PRE_first_tail_x15_r0_body.s657 PRE_first_tail_x15_r0_body.st67.s2 PRE_first_tail_x15_r0_body.st67.s0
      PRE_first_tail_x15_r0_body.st67.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st67.F FR W stk M ν K PRE_first_tail_x15_r0_body.s658 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso67 PRE_first_tail_x15_r0_body.stFoot67 PRE_first_tail_x15_r0_body.wrNodup67 PRE_first_tail_x15_r0_body.wrBound67 PRE_first_tail_x15_r0_body.trace67 PRE_first_tail_x15_r0_body.mheap67
    PRE_first_tail_x15_r0_body.mnext67 PRE_first_tail_x15_r0_body.mctl67 PRE_first_tail_x15_r0_body.mstack67 PRE_first_tail_x15_r0_body.mjobs67 PRE_first_tail_x15_r0_body.mffi67 PRE_first_tail_x15_r0_body.mtrace67 PRE_first_tail_x15_r0_body.mstores67 h

def PRE_first_tail_x15_r0_body.arrEl67_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE67_2665 : arrOf PRE_first_tail_x15_r0_body.s658 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl67_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA67_2665 : isArrB PRE_first_tail_x15_r0_body.s658 2665 = true
theorem PRE_first_tail_x15_r0_body.arr67_2665 : ∃ o, PRE_first_tail_x15_r0_body.s658.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl67_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE67_2665 PRE_first_tail_x15_r0_body.arrA67_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN67_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl67_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR67_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl67_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN67_2665

def PRE_first_tail_x15_r0_body.arrEl67_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE67_2673467 : arrOf PRE_first_tail_x15_r0_body.s658 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl67_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA67_2673467 : isArrB PRE_first_tail_x15_r0_body.s658 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr67_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s658.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl67_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE67_2673467 PRE_first_tail_x15_r0_body.arrA67_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN67_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl67_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR67_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl67_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN67_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k67 : isArrB PRE_first_tail_x15_r0_body.s658 4910 = false
theorem PRE_first_tail_x15_r0_body.keep67 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s658 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k67 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr67_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl67_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ67
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 67 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s657`, the merged
state `PRE_first_tail_x15_r0_body.s658`, the canonical state `PRE_first_tail_x15_r0_body.s659`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl67 : PRE_first_tail_x15_r0_body.pl67.all (Nat.ble PRE_first_tail_x15_r0_body.s657.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd67 : nodupT PRE_first_tail_x15_r0_body.pl67 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn167 : Nat.ble PRE_first_tail_x15_r0_body.s657.next 2727557 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst67 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s657.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn67 : PRE_first_tail_x15_r0_body.s659.next = PRE_first_tail_x15_r0_body.s657.next + PRE_first_tail_x15_r0_body.pl67.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn67 : PRE_first_tail_x15_r0_body.s658.next = 2727557
kernel_rfl PRE_first_tail_x15_r0_body.zgrow67 : Nat.ble PRE_first_tail_x15_r0_body.s659.next PRE_first_tail_x15_r0_body.s658.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh67 : PRE_first_tail_x15_r0_body.S657.tab.all (fun e => PRE_first_tail_x15_r0_body.cws67.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd67 : nodupT PRE_first_tail_x15_r0_body.cws67 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi67 : PRE_first_tail_x15_r0_body.nr67.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S658.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt67 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s657.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg67_2665 : PRE_first_tail_x15_r0_body.s659.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s659 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk67_2665 : (objOf PRE_first_tail_x15_r0_body.s659 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm67_2665 : PRE_first_tail_x15_r0_body.s658.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa67.obj (objOf PRE_first_tail_x15_r0_body.s659 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s658 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg67_2673467 : PRE_first_tail_x15_r0_body.s659.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s659 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk67_2673467 : (objOf PRE_first_tail_x15_r0_body.s659 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm67_2673467 : PRE_first_tail_x15_r0_body.s658.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa67.obj (objOf PRE_first_tail_x15_r0_body.s659 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s658 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw67_4910 : (PRE_first_tail_x15_r0_body.s659.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw67_2673472 : (PRE_first_tail_x15_r0_body.s659.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw67_2673473 : (PRE_first_tail_x15_r0_body.s659.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd67 : PRE_first_tail_x15_r0_body.cl67.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr67 : PRE_first_tail_x15_r0_body.st67.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s657.next || PRE_first_tail_x15_r0_body.cl67.contains b) = true
def PRE_first_tail_x15_r0_body.zl67 : List Nat := PRE_first_tail_x15_r0_body.cl67.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE67 : PRE_first_tail_x15_r0_body.zl67.map (fun a => PRE_first_tail_x15_r0_body.s658.heap.get (PRE_first_tail_x15_r0_body.kappa67.a a)) = PRE_first_tail_x15_r0_body.zl67.map (fun a => (PRE_first_tail_x15_r0_body.s659.heap.get a).map PRE_first_tail_x15_r0_body.kappa67.hobj)
theorem PRE_first_tail_x15_r0_body.zimg67 : HeapImg PRE_first_tail_x15_r0_body.kappa67 PRE_first_tail_x15_r0_body.s659 PRE_first_tail_x15_r0_body.s658 PRE_first_tail_x15_r0_body.zl67 := PRE_first_tail_x15_r0_body.zimgE67
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl67 : PRE_first_tail_x15_r0_body.s658.ctl = PRE_first_tail_x15_r0_body.kappa67.ctl PRE_first_tail_x15_r0_body.s659.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack67 : PRE_first_tail_x15_r0_body.s658.stack = PRE_first_tail_x15_r0_body.s659.stack.map PRE_first_tail_x15_r0_body.kappa67.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs67 : PRE_first_tail_x15_r0_body.s658.jobs = PRE_first_tail_x15_r0_body.s659.jobs.map PRE_first_tail_x15_r0_body.kappa67.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores67 : PRE_first_tail_x15_r0_body.s658.stores = PRE_first_tail_x15_r0_body.kappa67.stores PRE_first_tail_x15_r0_body.s659.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots67 : checkRootsSupp PRE_first_tail_x15_r0_body.s659 2945 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC67 : PRE_first_tail_x15_r0_body.S657.tab.length + PRE_first_tail_x15_r0_body.cws67.length = 2945
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap67 : PRE_first_tail_x15_r0_body.kappa67 = Conv.Map.compact PRE_first_tail_x15_r0_body.s657.next 2727557 PRE_first_tail_x15_r0_body.S657.tab.length PRE_first_tail_x15_r0_body.pl67 (PRE_first_tail_x15_r0_body.nr67.map NumV.ref) PRE_first_tail_x15_r0_body.kd67.big
  PRE_first_tail_x15_r0_body.kd67.region PRE_first_tail_x15_r0_body.kd67.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin67 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s659.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc67 : Conv.jcleanListB (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s659 PRE_first_tail_x15_r0_body.cl67 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB67 : noBigRootsP (fun i => !Conv.oldBigB (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s659.trace PRE_first_tail_x15_r0_body.s659 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm67 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16629 = true
theorem PRE_first_tail_x15_r0_body.cjcl67 (h : Conv.JClean (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s657) : Conv.JClean (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s659 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle67)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap67 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd67 a ha)) PRE_first_tail_x15_r0_body.zjc67

end Host.Load.Run.Tpl
end

section -- st67/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st67.bodyLast from PRE_first_tail_x15_r0_body.st67.s1 to PRE_first_tail_x15_r0_body.st67.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st67.F PRE_first_tail_x15_r0_body.st67.s1).run PRE_first_tail_x15_r0_body.st67.S1 = some (PRE_first_tail_x15_r0_body.st67.s2, PRE_first_tail_x15_r0_body.st67.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st67.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st67.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st67.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st67.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st67/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st67.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st67.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st67.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st67.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st67.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st67.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st67.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st67.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st67.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st67.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st67.s0 PRE_first_tail_x15_r0_body.st67.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st67.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st67.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st67.s1 PRE_first_tail_x15_r0_body.st67.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st67/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st67.bodyK0F from PRE_first_tail_x15_r0_body.st67.s0 to PRE_first_tail_x15_r0_body.st67.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st67.F (PRE_first_tail_x15_r0_body.st67.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st67.ks 0).getD 0) PRE_first_tail_x15_r0_body.st67.s0 PRE_first_tail_x15_r0_body.st67.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st67.s1, PRE_first_tail_x15_r0_body.st67.S1)
theorem PRE_first_tail_x15_r0_body.st67.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st67.F (PRE_first_tail_x15_r0_body.st67.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st67.ks 0).getD 0) PRE_first_tail_x15_r0_body.st67.s0 PRE_first_tail_x15_r0_body.st67.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st67.s1, PRE_first_tail_x15_r0_body.st67.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st67.bodyOkLN_ok PRE_first_tail_x15_r0_body.st67.bodyK0F
end Host.Load.Run.Tpl
end

section -- st67/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st67.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st67.F (PRE_first_tail_x15_r0_body.st67.bodyOkL bytes rows) 27 PRE_first_tail_x15_r0_body.st67.s0 PRE_first_tail_x15_r0_body.st67.S0 = some (PRE_first_tail_x15_r0_body.st67.s1, PRE_first_tail_x15_r0_body.st67.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st67.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st67.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st67.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st67.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st67.F (PRE_first_tail_x15_r0_body.st67.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st67.s0
  S0 := PRE_first_tail_x15_r0_body.st67.S0
  s1 := PRE_first_tail_x15_r0_body.st67.s1
  S1 := PRE_first_tail_x15_r0_body.st67.S1
  s2 := PRE_first_tail_x15_r0_body.st67.s2
  S2 := PRE_first_tail_x15_r0_body.st67.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st67.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st67.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st67.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st67.bodyHalt
  last := PRE_first_tail_x15_r0_body.st67.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st67.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC68
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 68 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s663` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa68` into the merged state
`PRE_first_tail_x15_r0_body.s662`. -/

def PRE_first_tail_x15_r0_body.pl68 : List Nat := [2727853]
def PRE_first_tail_x15_r0_body.nr68 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd68 : RData :=
  ⟨2727844, 2727854, Stage.setAll PTrie.nil [(2727843, 2727853)], Stage.setAll PTrie.nil [],
   19533, 19533, 16633, 16633, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa68 : Map :=
  Conv.Map.compact 2727843 2727854 2962 PRE_first_tail_x15_r0_body.pl68 (PRE_first_tail_x15_r0_body.nr68.map NumV.ref) PRE_first_tail_x15_r0_body.kd68.big
    PRE_first_tail_x15_r0_body.kd68.region PRE_first_tail_x15_r0_body.kd68.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws68 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs68 : List SymE := PRE_first_tail_x15_r0_body.nr68.map fun r => (nth? PRE_first_tail_x15_r0_body.S662.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta68 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws68 PRE_first_tail_x15_r0_body.crs68
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB68 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab68 : PRE_first_tail_x15_r0_body.S663.tab = PRE_first_tail_x15_r0_body.S661.tab ++ PRE_first_tail_x15_r0_body.cws68.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace68 : PRE_first_tail_x15_r0_body.s663.trace = PRE_first_tail_x15_r0_body.s661.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext68 : PRE_first_tail_x15_r0_body.s663.next = 2727844
kernel_rfl PRE_first_tail_x15_r0_body.ccounters68 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s663.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s663.ffi).mlx.nnext) = (19533, 16633)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue68 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s662.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s663.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa68.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp68 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s663.ffi).mlx.tokens.all (bSN 2962) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean68 : Conv.cleanListB 19533 131072 (fun r => Nat.ble 78132 r) PRE_first_tail_x15_r0_body.s663
    (PRE_first_tail_x15_r0_body.wrB68 ++ (List.range 1).map (2727843 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs68 : bigsOutB 19533 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s663.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK68
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl68`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl68 : List Nat := [2665, 2673467, 2727843]
def PRE_first_tail_x15_r0_body.clo68 : List Nat := []
def PRE_first_tail_x15_r0_body.cln68 : List Nat := []
def PRE_first_tail_x15_r0_body.cli68 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap68 : PRE_first_tail_x15_r0_body.s663.heap = Stage.setAll PRE_first_tail_x15_r0_body.s661.heap (PRE_first_tail_x15_r0_body.cl68.filterMap fun a => (PRE_first_tail_x15_r0_body.s663.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe68 : Nat.ble PRE_first_tail_x15_r0_body.s661.next PRE_first_tail_x15_r0_body.s663.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP68 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s661 PRE_first_tail_x15_r0_body.s663 PRE_first_tail_x15_r0_body.cl68 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp68 : Conv.suppListB PRE_first_tail_x15_r0_body.s663 2962 PRE_first_tail_x15_r0_body.cl68 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound68 : Conv.boundListB PRE_first_tail_x15_r0_body.s663 PRE_first_tail_x15_r0_body.cl68 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK68 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s663.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln68.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s663.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK68 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s663.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo68.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s663.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK68 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s663.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli68.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s663.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst68 : Conv.sstListB 2962 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s663.ffi).mlx PRE_first_tail_x15_r0_body.cln68 PRE_first_tail_x15_r0_body.clo68 PRE_first_tail_x15_r0_body.cli68 = true

end Host.Load.Run.Tpl
end

section -- SiteCl68
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA68 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s663.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo68.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s663.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd68 : (PRE_first_tail_x15_r0_body.clo68 ++ PRE_first_tail_x15_r0_body.cln68 ++ PRE_first_tail_x15_r0_body.cli68).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle68 : Conv.Cnt.leB (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt) (⟨19533, 16633, 2727844, 2962⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck68 : Conv.ncleanListB (⟨19533, 16633, 2727844, 2962⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s663.ffi).mlx PRE_first_tail_x15_r0_body.clo68 PRE_first_tail_x15_r0_body.cln68 PRE_first_tail_x15_r0_body.cli68 = true
theorem PRE_first_tail_x15_r0_body.cncl68 (h : Conv.NClean (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx) : Conv.NClean (⟨19533, 16633, 2727844, 2962⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s663.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle68 PRE_first_tail_x15_r0_body.ckA68 PRE_first_tail_x15_r0_body.cobjsK68 PRE_first_tail_x15_r0_body.cnodesK68 PRE_first_tail_x15_r0_body.citemsK68 PRE_first_tail_x15_r0_body.cbd68 PRE_first_tail_x15_r0_body.cck68

end Host.Load.Run.Tpl
end

section -- SiteS68
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 68 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc68 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P68 : LoadP := PRE_first_tail_x15_r0_body.Pc68.raise 16633
kernel_rfl PRE_first_tail_x15_r0_body.craise68 : Nat.ble PRE_first_tail_x15_r0_body.Pc68.N0 16633 = true
theorem PRE_first_tail_x15_r0_body.raised68 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc68 PRE_first_tail_x15_r0_body.P68 :=
  .inr ⟨16633, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise68, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_68 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s663.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_68 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s662.ffi)
def PRE_first_tail_x15_r0_body.khinv68 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv68 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS68 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS68 : List Nat := List.range' 16633 0
def PRE_first_tail_x15_r0_body.ciS68 : List Nat := [] ++ List.range' 16633 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh068 : PRE_first_tail_x15_r0_body.kd68.nh0 = PRE_first_tail_x15_r0_body.cx0_68.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh168 : PRE_first_tail_x15_r0_body.kd68.nh1 = PRE_first_tail_x15_r0_body.cx1_68.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn068 : PRE_first_tail_x15_r0_body.kd68.nn0 = PRE_first_tail_x15_r0_body.cx0_68.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn168 : PRE_first_tail_x15_r0_body.kd68.nn1 = PRE_first_tail_x15_r0_body.cx1_68.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo68 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P68.lo && Nat.ble PRE_first_tail_x15_r0_body.P68.lo PRE_first_tail_x15_r0_body.cx0_68.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P68.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P68.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt68 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_68.mlx.next PRE_first_tail_x15_r0_body.cx1_68.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_68.mlx.nnext PRE_first_tail_x15_r0_body.cx1_68.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband68 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P68.NL && Nat.ble PRE_first_tail_x15_r0_body.P68.NL PRE_first_tail_x15_r0_body.P68.N0 && Nat.ble PRE_first_tail_x15_r0_body.P68.N0 PRE_first_tail_x15_r0_body.cx0_68.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow68 : PRE_first_tail_x15_r0_body.kd68.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren68 : checkRenG PRE_first_tail_x15_r0_body.kd68.hnd PRE_first_tail_x15_r0_body.khinv68 (phB PRE_first_tail_x15_r0_body.cx0_68.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband68 : PRE_first_tail_x15_r0_body.kd68.checkBand PRE_first_tail_x15_r0_body.P68.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos68 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd68.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren68 : checkRenG PRE_first_tail_x15_r0_body.kd68.node PRE_first_tail_x15_r0_body.kninv68 (pnB PRE_first_tail_x15_r0_body.cx0_68.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow68 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd68.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P68.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd68.nodeF j) PRE_first_tail_x15_r0_body.cx1_68.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a68 : PRE_first_tail_x15_r0_body.cx0_68.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b68 : PRE_first_tail_x15_r0_body.cx0_68.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok168 : PRE_first_tail_x15_r0_body.cx1_68.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend68 : PRE_first_tail_x15_r0_body.cx1_68.mlx.pending = PRE_first_tail_x15_r0_body.cx0_68.mlx.pending.map PRE_first_tail_x15_r0_body.kappa68.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh68 : PRE_first_tail_x15_r0_body.cx1_68.mlx.errh = PRE_first_tail_x15_r0_body.cx0_68.mlx.errh.map PRE_first_tail_x15_r0_body.kappa68.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles68 : PRE_first_tail_x15_r0_body.cx1_68.mlx.files = PRE_first_tail_x15_r0_body.cx0_68.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch68 : PRE_first_tail_x15_r0_body.cx1_68.mlx.arch = PRE_first_tail_x15_r0_body.cx0_68.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes68 : PRE_first_tail_x15_r0_body.cx1_68.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_68.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired68 : PRE_first_tail_x15_r0_body.cx1_68.mlx.wired = PRE_first_tail_x15_r0_body.cx0_68.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost68 : PRE_first_tail_x15_r0_body.cx1_68.host = PRE_first_tail_x15_r0_body.cx0_68.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd68`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn068 : PRE_first_tail_x15_r0_body.kd68.n0 = 2727844
kernel_rfl PRE_first_tail_x15_r0_body.ckn168 : PRE_first_tail_x15_r0_body.kd68.n1 = 2727854
kernel_rfl PRE_first_tail_x15_r0_body.ckheap68 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd68.heap).all (fun x => Nat.ble 2727843 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl68 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd68.heap.get (2727843 + j) = nth? PRE_first_tail_x15_r0_body.pl68 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja68 : Nat.ble 2727843 2727843 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn68 : Nat.ble 2962 2962 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD68 : Nat.ble 2727843 PRE_first_tail_x15_r0_body.kd68.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn68 : Nat.ble 19533 PRE_first_tail_x15_r0_body.kd68.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn68 : Nat.ble 16633 PRE_first_tail_x15_r0_body.kd68.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb68 : Nat.ble 19533 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap68 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd68.heap).all (Nat.ble (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd68 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd68.hnd).all (Nat.ble (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode68 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd68.node).all (Nat.ble (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix68 : Conv.FixOld (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa68 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja68) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn68) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD68) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn68) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn68) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb68) PRE_first_tail_x15_r0_body.fheap68 PRE_first_tail_x15_r0_body.fhnd68 PRE_first_tail_x15_r0_body.fnode68
kernel_rfl PRE_first_tail_x15_r0_body.fcxn68 : (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn68 : (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle068 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_68.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_68.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk68 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd68.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A68 : PRE_first_tail_x15_r0_body.cx1_68.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS68.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_68.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O68 : PRE_first_tail_x15_r0_body.cx1_68.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS68.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_68.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N68 : PRE_first_tail_x15_r0_body.cx1_68.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS68.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_68.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I68 : PRE_first_tail_x15_r0_body.cx1_68.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS68.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_68.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd68 : (PRE_first_tail_x15_r0_body.clo68 ++ PRE_first_tail_x15_r0_body.cln68 ++ PRE_first_tail_x15_r0_body.cli68 ++ PRE_first_tail_x15_r0_body.cwS68 ++ PRE_first_tail_x15_r0_body.cnS68 ++ PRE_first_tail_x15_r0_body.ciS68).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW68 : PRE_first_tail_x15_r0_body.cwS68.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo68.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI68 : PRE_first_tail_x15_r0_body.ciS68.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli68.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN68 : PRE_first_tail_x15_r0_body.cnS68.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF68 : PRE_first_tail_x15_r0_body.cln68.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh68 : PRE_first_tail_x15_r0_body.clo68.all (handleOK PRE_first_tail_x15_r0_body.kappa68 PRE_first_tail_x15_r0_body.P68.lo PRE_first_tail_x15_r0_body.cx0_68.mlx PRE_first_tail_x15_r0_body.cx1_68.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo68 : PRE_first_tail_x15_r0_body.clo68.map (fun h => PRE_first_tail_x15_r0_body.cx1_68.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa68.handle h)) = PRE_first_tail_x15_r0_body.clo68.map (fun h => (PRE_first_tail_x15_r0_body.cx0_68.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa68.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok68 : PRE_first_tail_x15_r0_body.clo68.all (objOK PRE_first_tail_x15_r0_body.kappa68 PRE_first_tail_x15_r0_body.P68.NL PRE_first_tail_x15_r0_body.cx0_68.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd68 : PRE_first_tail_x15_r0_body.cln68.all (nodeOKF PRE_first_tail_x15_r0_body.kappa68 PRE_first_tail_x15_r0_body.P68 PRE_first_tail_x15_r0_body.cx0_68.mlx PRE_first_tail_x15_r0_body.cx1_68.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp68 : ((PRE_first_tail_x15_r0_body.cln68.filter (fullB PRE_first_tail_x15_r0_body.P68))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_68.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa68.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln68.filter (fullB PRE_first_tail_x15_r0_body.P68))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_68.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa68.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI68 : incrB PRE_first_tail_x15_r0_body.kd68.nodeF (List.range' 16633 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK68 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd68.node).all (fun k => Nat.ble 16633 k && Nat.blt k 16633) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL68 : (PRE_first_tail_x15_r0_body.cln68.filter (Nat.ble PRE_first_tail_x15_r0_body.P68.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd68.nodeF i) && (Nat.blt i 16633 || Nat.ble PRE_first_tail_x15_r0_body.kd68.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord68 : (PRE_first_tail_x15_r0_body.cln68.filter (Nat.ble PRE_first_tail_x15_r0_body.P68.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd68.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd68.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd68.nodeF j) (PRE_first_tail_x15_r0_body.kd68.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow68 PRE_first_tail_x15_r0_body.cnn168 PRE_first_tail_x15_r0_body.fnordI68 PRE_first_tail_x15_r0_body.fnordK68 PRE_first_tail_x15_r0_body.fnordL68
kernel_rfl PRE_first_tail_x15_r0_body.fi68 : PRE_first_tail_x15_r0_body.cli68.all (pnB PRE_first_tail_x15_r0_body.cx0_68.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii68 : PRE_first_tail_x15_r0_body.cli68.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_68.mlx.items.get (PRE_first_tail_x15_r0_body.kappa68.node k) = (PRE_first_tail_x15_r0_body.cx0_68.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa68.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot68 (clean : Conv.NClean (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P68.NL) (cl : SSt (· < 2962) PRE_first_tail_x15_r0_body.cx0_68.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P68 2962 PRE_first_tail_x15_r0_body.kappa68 PRE_first_tail_x15_r0_body.kd68 PRE_first_tail_x15_r0_body.khinv68 PRE_first_tail_x15_r0_body.kninv68 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx PRE_first_tail_x15_r0_body.cx0_68.mlx PRE_first_tail_x15_r0_body.cx1_68.mlx (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo68 PRE_first_tail_x15_r0_body.cln68 PRE_first_tail_x15_r0_body.cli68 PRE_first_tail_x15_r0_body.cwS68 PRE_first_tail_x15_r0_body.cnS68 PRE_first_tail_x15_r0_body.ciS68 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh068, PRE_first_tail_x15_r0_body.cnh168, PRE_first_tail_x15_r0_body.cnn068, PRE_first_tail_x15_r0_body.cnn168, PRE_first_tail_x15_r0_body.cplo68, PRE_first_tail_x15_r0_body.ccnt68, PRE_first_tail_x15_r0_body.cnband68, PRE_first_tail_x15_r0_body.chbelow68, PRE_first_tail_x15_r0_body.chren68, PRE_first_tail_x15_r0_body.cband68, PRE_first_tail_x15_r0_body.cnh1pos68, PRE_first_tail_x15_r0_body.cnren68, PRE_first_tail_x15_r0_body.cnlow68, PRE_first_tail_x15_r0_body.cabs0a68, PRE_first_tail_x15_r0_body.cabs0b68, PRE_first_tail_x15_r0_body.ctok168, PRE_first_tail_x15_r0_body.cpend68, PRE_first_tail_x15_r0_body.cerrh68, PRE_first_tail_x15_r0_body.cfiles68, PRE_first_tail_x15_r0_body.carch68, PRE_first_tail_x15_r0_body.csizes68, PRE_first_tail_x15_r0_body.cwired68, PRE_first_tail_x15_r0_body.cfix68, clean, PRE_first_tail_x15_r0_body.fcxn68, PRE_first_tail_x15_r0_body.fcnn68, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle068, PRE_first_tail_x15_r0_body.fnk68, PRE_first_tail_x15_r0_body.ckA68, PRE_first_tail_x15_r0_body.cobjsK68, PRE_first_tail_x15_r0_body.cnodesK68, PRE_first_tail_x15_r0_body.citemsK68, PRE_first_tail_x15_r0_body.f1A68, PRE_first_tail_x15_r0_body.f1O68, PRE_first_tail_x15_r0_body.f1N68, PRE_first_tail_x15_r0_body.f1I68, PRE_first_tail_x15_r0_body.fbd68, PRE_first_tail_x15_r0_body.fincW68, PRE_first_tail_x15_r0_body.fincI68, PRE_first_tail_x15_r0_body.fincN68, PRE_first_tail_x15_r0_body.flnF68, PRE_first_tail_x15_r0_body.fh68, PRE_first_tail_x15_r0_body.fo68, PRE_first_tail_x15_r0_body.fok68, PRE_first_tail_x15_r0_body.fnd68, PRE_first_tail_x15_r0_body.fp68, PRE_first_tail_x15_r0_body.fnord68, PRE_first_tail_x15_r0_body.fi68, PRE_first_tail_x15_r0_body.fii68⟩
theorem PRE_first_tail_x15_r0_body.cnshift68 (clean : Conv.NClean (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P68.NL) (cl : SSt (· < 2962) PRE_first_tail_x15_r0_body.cx0_68.mlx) : NShift PRE_first_tail_x15_r0_body.P68 2962 PRE_first_tail_x15_r0_body.kappa68 PRE_first_tail_x15_r0_body.cx0_68 PRE_first_tail_x15_r0_body.cx1_68 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot68 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost68 (compact_a_eq PRE_first_tail_x15_r0_body.ckn068 PRE_first_tail_x15_r0_body.ckn168 PRE_first_tail_x15_r0_body.ckheap68 PRE_first_tail_x15_r0_body.ckpl68)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_68 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s661.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_68 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s661.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_68 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s661.ffi) = some PRE_first_tail_x15_r0_body.fxC_68
kernel_rfl PRE_first_tail_x15_r0_body.okrC_68 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s661.ffi) = some PRE_first_tail_x15_r0_body.krC_68
noncomputable def PRE_first_tail_x15_r0_body.fx0_68 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s663.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_68 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s663.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_68 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s663.ffi) = some PRE_first_tail_x15_r0_body.fx0_68
kernel_rfl PRE_first_tail_x15_r0_body.okr0_68 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s663.ffi) = some PRE_first_tail_x15_r0_body.kr0_68
noncomputable def PRE_first_tail_x15_r0_body.fx1_68 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s662.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_68 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s662.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_68 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s662.ffi) = some PRE_first_tail_x15_r0_body.fx1_68
kernel_rfl PRE_first_tail_x15_r0_body.okr1_68 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s662.ffi) = some PRE_first_tail_x15_r0_body.kr1_68
kernel_rfl PRE_first_tail_x15_r0_body.ff068 : PRE_first_tail_x15_r0_body.fx0_68 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_68 (PRE_first_tail_x15_r0_body.clo68.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_68.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff168 : PRE_first_tail_x15_r0_body.fx1_68 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_68 (PRE_first_tail_x15_r0_body.cwS68.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_68.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck68 : freedLB PRE_first_tail_x15_r0_body.kappa68 PRE_first_tail_x15_r0_body.cx0_68.mlx PRE_first_tail_x15_r0_body.fx0_68 PRE_first_tail_x15_r0_body.fx1_68 PRE_first_tail_x15_r0_body.clo68 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf068 : PRE_first_tail_x15_r0_body.kr0_68.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_68.flags (PRE_first_tail_x15_r0_body.clo68.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_68.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt068 : PRE_first_tail_x15_r0_body.kr0_68.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_68.targs (PRE_first_tail_x15_r0_body.clo68.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_68.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf168 : PRE_first_tail_x15_r0_body.kr1_68.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_68.flags (PRE_first_tail_x15_r0_body.cwS68.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_68.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt168 : PRE_first_tail_x15_r0_body.kr1_68.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_68.targs (PRE_first_tail_x15_r0_body.cwS68.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_68.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck68 : krecLB PRE_first_tail_x15_r0_body.kappa68 2962 PRE_first_tail_x15_r0_body.cx0_68.mlx PRE_first_tail_x15_r0_body.kr0_68 PRE_first_tail_x15_r0_body.kr1_68 PRE_first_tail_x15_r0_body.clo68 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn68 : Nat.ble 2962 2962 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge68 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s662.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s663.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR68 : pendRegB PRE_first_tail_x15_r0_body.kappa68 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s663.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe68 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s663.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s662.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift68 (clean : Conv.NClean (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P68.NL) (cl : SSt (· < 2962) PRE_first_tail_x15_r0_body.cx0_68.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_68.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_68.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_68.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_68.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P68 2962 PRE_first_tail_x15_r0_body.kappa68 PRE_first_tail_x15_r0_body.s663.ffi PRE_first_tail_x15_r0_body.s662.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift68 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue68, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp68 t ht),
    PRE_first_tail_x15_r0_body.cbridge68,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s663.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s662.ffi) (PRE_first_tail_x15_r0_body.cfoot68 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_68 PRE_first_tail_x15_r0_body.ofx1_68 hobjC PRE_first_tail_x15_r0_body.ff068 PRE_first_tail_x15_r0_body.ff168 PRE_first_tail_x15_r0_body.ffck68,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s663.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s662.ffi) (PRE_first_tail_x15_r0_body.cfoot68 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_68 PRE_first_tail_x15_r0_body.okr1_68 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn68) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf068 PRE_first_tail_x15_r0_body.fkt068 PRE_first_tail_x15_r0_body.fkf168 PRE_first_tail_x15_r0_body.fkt168 PRE_first_tail_x15_r0_body.fkck68,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh068 PRE_first_tail_x15_r0_body.cnh168 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe68) PRE_first_tail_x15_r0_body.cpendR68⟩

end Host.Load.Run.Tpl
end

section -- st68/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st68 0
host_stream_state PRE_first_tail_x15_r0_body.st68 1
host_stream_state PRE_first_tail_x15_r0_body.st68 2
end Host.Load.Run.Tpl
end

section -- Site68
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 68 of chain `PRE_first_tail_x15_r0_body`: `plan__g68__g69` (`plan`), the call state `PRE_first_tail_x15_r0_body.s661`, the merged state `PRE_first_tail_x15_r0_body.s662`,
the site template `PRE_first_tail_x15_r0_body.st68` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s663`: the merge.
The footprint's facts are in `SiteF68`, the compaction's in `SiteC68`, `SiteK68`, `SiteNa68`, `SiteNb68`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso68 : PRE_first_tail_x15_r0_body.st68.s0 = { PRE_first_tail_x15_r0_body.s661 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs68 : List Frame := PRE_first_tail_x15_r0_body.s661.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_68 : PRE_first_tail_x15_r0_body.S661.tab.length = 2962
kernel_rfl PRE_first_tail_x15_r0_body.tab0_68 : PRE_first_tail_x15_r0_body.st68.S0.tab = PRE_first_tail_x15_r0_body.S661.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws68 : List Nat := [2166, 2167, 2168]
kernel_rfl PRE_first_tail_x15_r0_body.fresh68 : (PRE_first_tail_x15_r0_body.S661.tab.all fun e => PRE_first_tail_x15_r0_body.ws68.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S661.oracle.all fun q => PRE_first_tail_x15_r0_body.ws68.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab68 : PRE_first_tail_x15_r0_body.S662.tab = PRE_first_tail_x15_r0_body.S661.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws68
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen68 : PRE_first_tail_x15_r0_body.st68.S2.tab.length - PRE_first_tail_x15_r0_body.st68.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged68`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap68 : PRE_first_tail_x15_r0_body.s662.heap = PRE_first_tail_x15_r0_body.st68.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext68 : PRE_first_tail_x15_r0_body.s662.next = PRE_first_tail_x15_r0_body.st68.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl68 : PRE_first_tail_x15_r0_body.s662.ctl = PRE_first_tail_x15_r0_body.st68.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack68 : PRE_first_tail_x15_r0_body.s662.stack = PRE_first_tail_x15_r0_body.st68.s2.stack ++ PRE_first_tail_x15_r0_body.s661.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs68 : PRE_first_tail_x15_r0_body.s662.jobs = PRE_first_tail_x15_r0_body.st68.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi68 : PRE_first_tail_x15_r0_body.s662.ffi = PRE_first_tail_x15_r0_body.st68.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace68 : PRE_first_tail_x15_r0_body.s662.trace = PRE_first_tail_x15_r0_body.st68.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores68 : PRE_first_tail_x15_r0_body.s662.stores = PRE_first_tail_x15_r0_body.st68.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD68
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 68 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived68 : PRE_first_tail_x15_r0_body.nr68.map (fun r => nth? PRE_first_tail_x15_r0_body.st68.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo68 : PRE_first_tail_x15_r0_body.nr68.all (Nat.ble 2962) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj68 : PRE_first_tail_x15_r0_body.cws68.all (fun c => !PRE_first_tail_x15_r0_body.ws68.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ68 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws68 PRE_first_tail_x15_r0_body.crs68 PRE_first_tail_x15_r0_body.ws68

end Host.Load.Run.Tpl
end

section -- st68/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st68`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st68.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st68.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st68.s2.heap PRE_first_tail_x15_r0_body.st68.wrR ++ freshOf PRE_first_tail_x15_r0_body.st68.s2.heap PRE_first_tail_x15_r0_body.st68.s0.next PRE_first_tail_x15_r0_body.st68.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st68.wr : List Nat := PRE_first_tail_x15_r0_body.st68.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st68.heapFoot : PRE_first_tail_x15_r0_body.st68.s2.heap = setAll PRE_first_tail_x15_r0_body.st68.s0.heap PRE_first_tail_x15_r0_body.st68.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st68.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st68.s0.next PRE_first_tail_x15_r0_body.st68.s2.next = true
theorem PRE_first_tail_x15_r0_body.st68.grows : PRE_first_tail_x15_r0_body.st68.s0.next ≤ PRE_first_tail_x15_r0_body.st68.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st68.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st68.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st68.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st68.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st68.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st68.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st68.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st68.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st68.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st68.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st68.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st68.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st68.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st68.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st68.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st68.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st68.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st68.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st68.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st68.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st68.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st68.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st68.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st68.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st68.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st68.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st68.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st68.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st68.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st68.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st68.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st68.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF68
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 68 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB68 : nodupT PRE_first_tail_x15_r0_body.st68.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup68 : PRE_first_tail_x15_r0_body.st68.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB68).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB68 : PRE_first_tail_x15_r0_body.st68.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound68 : ∀ b ∈ PRE_first_tail_x15_r0_body.st68.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB68 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr68 := PRE_first_tail_x15_r0_body.st68.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq68 : PRE_first_tail_x15_r0_body.st68.s2.trace = PRE_first_tail_x15_r0_body.trFr68 ++ PRE_first_tail_x15_r0_body.st68.s0.trace
theorem PRE_first_tail_x15_r0_body.trace68 : ∃ fr, PRE_first_tail_x15_r0_body.st68.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st68.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq68⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide68 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB68 : (PRE_first_tail_x15_r0_body.wide68.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st68.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix68 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide68, WFix Map.id (Present PRE_first_tail_x15_r0_body.st68.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB68 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL68
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 68 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s662`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO68 : PRE_first_tail_x15_r0_body.st68.S0.oracle = PRE_first_tail_x15_r0_body.st68.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B68 : PRE_first_tail_x15_r0_body.st68.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st68.s0.next || (PRE_first_tail_x15_r0_body.st68.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot68 : Conv.StageFoot PRE_first_tail_x15_r0_body.st68.wr PRE_first_tail_x15_r0_body.st68.s0 PRE_first_tail_x15_r0_body.st68.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st68.heapFoot PRE_first_tail_x15_r0_body.wrNodup68 PRE_first_tail_x15_r0_body.wrBound68 PRE_first_tail_x15_r0_body.wr0B68 PRE_first_tail_x15_r0_body.st68.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged68 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st68.F.S → PRE_first_tail_x15_r0_body.st68.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st68.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st68.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs68 PRE_first_tail_x15_r0_body.st68.wr PRE_first_tail_x15_r0_body.s661 PRE_first_tail_x15_r0_body.st68.s2 PRE_first_tail_x15_r0_body.st68.s0
      PRE_first_tail_x15_r0_body.st68.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st68.F FR W stk M ν K PRE_first_tail_x15_r0_body.s662 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso68 PRE_first_tail_x15_r0_body.stFoot68 PRE_first_tail_x15_r0_body.wrNodup68 PRE_first_tail_x15_r0_body.wrBound68 PRE_first_tail_x15_r0_body.trace68 PRE_first_tail_x15_r0_body.mheap68
    PRE_first_tail_x15_r0_body.mnext68 PRE_first_tail_x15_r0_body.mctl68 PRE_first_tail_x15_r0_body.mstack68 PRE_first_tail_x15_r0_body.mjobs68 PRE_first_tail_x15_r0_body.mffi68 PRE_first_tail_x15_r0_body.mtrace68 PRE_first_tail_x15_r0_body.mstores68 h

def PRE_first_tail_x15_r0_body.arrEl68_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE68_2665 : arrOf PRE_first_tail_x15_r0_body.s662 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl68_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA68_2665 : isArrB PRE_first_tail_x15_r0_body.s662 2665 = true
theorem PRE_first_tail_x15_r0_body.arr68_2665 : ∃ o, PRE_first_tail_x15_r0_body.s662.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl68_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE68_2665 PRE_first_tail_x15_r0_body.arrA68_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN68_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl68_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR68_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl68_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN68_2665

def PRE_first_tail_x15_r0_body.arrEl68_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE68_2673467 : arrOf PRE_first_tail_x15_r0_body.s662 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl68_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA68_2673467 : isArrB PRE_first_tail_x15_r0_body.s662 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr68_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s662.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl68_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE68_2673467 PRE_first_tail_x15_r0_body.arrA68_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN68_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl68_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR68_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl68_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN68_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k68 : isArrB PRE_first_tail_x15_r0_body.s662 4910 = false
theorem PRE_first_tail_x15_r0_body.keep68 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s662 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k68 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr68_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl68_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ68
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 68 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s661`, the merged
state `PRE_first_tail_x15_r0_body.s662`, the canonical state `PRE_first_tail_x15_r0_body.s663`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl68 : PRE_first_tail_x15_r0_body.pl68.all (Nat.ble PRE_first_tail_x15_r0_body.s661.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd68 : nodupT PRE_first_tail_x15_r0_body.pl68 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn168 : Nat.ble PRE_first_tail_x15_r0_body.s661.next 2727854 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst68 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s661.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn68 : PRE_first_tail_x15_r0_body.s663.next = PRE_first_tail_x15_r0_body.s661.next + PRE_first_tail_x15_r0_body.pl68.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn68 : PRE_first_tail_x15_r0_body.s662.next = 2727854
kernel_rfl PRE_first_tail_x15_r0_body.zgrow68 : Nat.ble PRE_first_tail_x15_r0_body.s663.next PRE_first_tail_x15_r0_body.s662.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh68 : PRE_first_tail_x15_r0_body.S661.tab.all (fun e => PRE_first_tail_x15_r0_body.cws68.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd68 : nodupT PRE_first_tail_x15_r0_body.cws68 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi68 : PRE_first_tail_x15_r0_body.nr68.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S662.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt68 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s661.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg68_2665 : PRE_first_tail_x15_r0_body.s663.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s663 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk68_2665 : (objOf PRE_first_tail_x15_r0_body.s663 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm68_2665 : PRE_first_tail_x15_r0_body.s662.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa68.obj (objOf PRE_first_tail_x15_r0_body.s663 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s662 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg68_2673467 : PRE_first_tail_x15_r0_body.s663.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s663 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk68_2673467 : (objOf PRE_first_tail_x15_r0_body.s663 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm68_2673467 : PRE_first_tail_x15_r0_body.s662.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa68.obj (objOf PRE_first_tail_x15_r0_body.s663 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s662 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw68_4910 : (PRE_first_tail_x15_r0_body.s663.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw68_2673472 : (PRE_first_tail_x15_r0_body.s663.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw68_2673473 : (PRE_first_tail_x15_r0_body.s663.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd68 : PRE_first_tail_x15_r0_body.cl68.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr68 : PRE_first_tail_x15_r0_body.st68.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s661.next || PRE_first_tail_x15_r0_body.cl68.contains b) = true
def PRE_first_tail_x15_r0_body.zl68 : List Nat := PRE_first_tail_x15_r0_body.cl68.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE68 : PRE_first_tail_x15_r0_body.zl68.map (fun a => PRE_first_tail_x15_r0_body.s662.heap.get (PRE_first_tail_x15_r0_body.kappa68.a a)) = PRE_first_tail_x15_r0_body.zl68.map (fun a => (PRE_first_tail_x15_r0_body.s663.heap.get a).map PRE_first_tail_x15_r0_body.kappa68.hobj)
theorem PRE_first_tail_x15_r0_body.zimg68 : HeapImg PRE_first_tail_x15_r0_body.kappa68 PRE_first_tail_x15_r0_body.s663 PRE_first_tail_x15_r0_body.s662 PRE_first_tail_x15_r0_body.zl68 := PRE_first_tail_x15_r0_body.zimgE68
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl68 : PRE_first_tail_x15_r0_body.s662.ctl = PRE_first_tail_x15_r0_body.kappa68.ctl PRE_first_tail_x15_r0_body.s663.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack68 : PRE_first_tail_x15_r0_body.s662.stack = PRE_first_tail_x15_r0_body.s663.stack.map PRE_first_tail_x15_r0_body.kappa68.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs68 : PRE_first_tail_x15_r0_body.s662.jobs = PRE_first_tail_x15_r0_body.s663.jobs.map PRE_first_tail_x15_r0_body.kappa68.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores68 : PRE_first_tail_x15_r0_body.s662.stores = PRE_first_tail_x15_r0_body.kappa68.stores PRE_first_tail_x15_r0_body.s663.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots68 : checkRootsSupp PRE_first_tail_x15_r0_body.s663 2962 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC68 : PRE_first_tail_x15_r0_body.S661.tab.length + PRE_first_tail_x15_r0_body.cws68.length = 2962
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap68 : PRE_first_tail_x15_r0_body.kappa68 = Conv.Map.compact PRE_first_tail_x15_r0_body.s661.next 2727854 PRE_first_tail_x15_r0_body.S661.tab.length PRE_first_tail_x15_r0_body.pl68 (PRE_first_tail_x15_r0_body.nr68.map NumV.ref) PRE_first_tail_x15_r0_body.kd68.big
  PRE_first_tail_x15_r0_body.kd68.region PRE_first_tail_x15_r0_body.kd68.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin68 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s663.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc68 : Conv.jcleanListB (⟨19533, 16633, 2727844, 2962⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s663 PRE_first_tail_x15_r0_body.cl68 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB68 : noBigRootsP (fun i => !Conv.oldBigB (⟨19533, 16633, 2727844, 2962⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s663.trace PRE_first_tail_x15_r0_body.s663 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm68 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16633 = true
theorem PRE_first_tail_x15_r0_body.cjcl68 (h : Conv.JClean (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s661) : Conv.JClean (⟨19533, 16633, 2727844, 2962⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s663 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle68)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap68 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd68 a ha)) PRE_first_tail_x15_r0_body.zjc68

end Host.Load.Run.Tpl
end

section -- st68/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st68.bodyLast from PRE_first_tail_x15_r0_body.st68.s1 to PRE_first_tail_x15_r0_body.st68.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st68.F PRE_first_tail_x15_r0_body.st68.s1).run PRE_first_tail_x15_r0_body.st68.S1 = some (PRE_first_tail_x15_r0_body.st68.s2, PRE_first_tail_x15_r0_body.st68.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st68.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st68.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st68.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st68.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st68/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st68.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st68.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st68.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st68.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st68.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st68.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st68.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st68.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st68.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st68.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st68.s0 PRE_first_tail_x15_r0_body.st68.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st68.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st68.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st68.s1 PRE_first_tail_x15_r0_body.st68.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st68/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st68.bodyK0F from PRE_first_tail_x15_r0_body.st68.s0 to PRE_first_tail_x15_r0_body.st68.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st68.F (PRE_first_tail_x15_r0_body.st68.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st68.ks 0).getD 0) PRE_first_tail_x15_r0_body.st68.s0 PRE_first_tail_x15_r0_body.st68.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st68.s1, PRE_first_tail_x15_r0_body.st68.S1)
theorem PRE_first_tail_x15_r0_body.st68.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st68.F (PRE_first_tail_x15_r0_body.st68.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st68.ks 0).getD 0) PRE_first_tail_x15_r0_body.st68.s0 PRE_first_tail_x15_r0_body.st68.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st68.s1, PRE_first_tail_x15_r0_body.st68.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st68.bodyOkLN_ok PRE_first_tail_x15_r0_body.st68.bodyK0F
end Host.Load.Run.Tpl
end

section -- st68/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st68.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st68.F (PRE_first_tail_x15_r0_body.st68.bodyOkL bytes rows) 98 PRE_first_tail_x15_r0_body.st68.s0 PRE_first_tail_x15_r0_body.st68.S0 = some (PRE_first_tail_x15_r0_body.st68.s1, PRE_first_tail_x15_r0_body.st68.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st68.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st68.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st68.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st68.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st68.F (PRE_first_tail_x15_r0_body.st68.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st68.s0
  S0 := PRE_first_tail_x15_r0_body.st68.S0
  s1 := PRE_first_tail_x15_r0_body.st68.s1
  S1 := PRE_first_tail_x15_r0_body.st68.S1
  s2 := PRE_first_tail_x15_r0_body.st68.s2
  S2 := PRE_first_tail_x15_r0_body.st68.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st68.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st68.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st68.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st68.bodyHalt
  last := PRE_first_tail_x15_r0_body.st68.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st68.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC69
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 69 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s679` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa69` into the merged state
`PRE_first_tail_x15_r0_body.s678`. -/

def PRE_first_tail_x15_r0_body.pl69 : List Nat := [2729942, 2729778, 2729830, 2729943, 2729944, 2729780, 2729832, 2729941, 2729940, 2729939, 2729938, 2729932, 2729883, 2729934, 2729885]
def PRE_first_tail_x15_r0_body.nr69 : List Nat := [3047, 3048, 3044, 3050, 3046, 3054, 3055, 3052, 3053]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd69 : RData :=
  ⟨2729595, 2729945, Stage.setAll PTrie.nil [(2729580, 2729942), (2729581, 2729778), (2729582, 2729830), (2729583, 2729943), (2729584, 2729944), (2729585, 2729780), (2729586, 2729832), (2729587, 2729941), (2729588, 2729940), (2729589, 2729939), (2729590, 2729938), (2729591, 2729932), (2729592, 2729883), (2729593, 2729934), (2729594, 2729885)], Stage.setAll PTrie.nil [(19573, 19575), (19574, 19576), (19575, 19578), (19576, 19577)],
   19577, 19579, 16667, 16667, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(3039, .ref 3047), (3040, .ref 3048), (3041, .ref 3044), (3042, .ref 3050), (3043, .ref 3046), (3044, .ref 3054), (3045, .ref 3055), (3046, .ref 3052), (3047, .ref 3053)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa69 : Map :=
  Conv.Map.compact 2729580 2729945 3039 PRE_first_tail_x15_r0_body.pl69 (PRE_first_tail_x15_r0_body.nr69.map NumV.ref) PRE_first_tail_x15_r0_body.kd69.big
    PRE_first_tail_x15_r0_body.kd69.region PRE_first_tail_x15_r0_body.kd69.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws69 : List Nat := [2186, 2187, 2188, 2189, 2190, 2191, 2192, 2193, 2194]
noncomputable def PRE_first_tail_x15_r0_body.crs69 : List SymE := PRE_first_tail_x15_r0_body.nr69.map fun r => (nth? PRE_first_tail_x15_r0_body.S678.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta69 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws69 PRE_first_tail_x15_r0_body.crs69
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB69 : List Nat := [2665, 2672477, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab69 : PRE_first_tail_x15_r0_body.S679.tab = PRE_first_tail_x15_r0_body.S677.tab ++ PRE_first_tail_x15_r0_body.cws69.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace69 : PRE_first_tail_x15_r0_body.s679.trace = PRE_first_tail_x15_r0_body.s677.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext69 : PRE_first_tail_x15_r0_body.s679.next = 2729595
kernel_rfl PRE_first_tail_x15_r0_body.ccounters69 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s679.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s679.ffi).mlx.nnext) = (19577, 16667)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue69 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s679.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa69.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp69 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s679.ffi).mlx.tokens.all (bSN 3048) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean69 : Conv.cleanListB 19577 131072 (fun r => Nat.ble 78308 r) PRE_first_tail_x15_r0_body.s679
    (PRE_first_tail_x15_r0_body.wrB69 ++ (List.range 15).map (2729580 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs69 : bigsOutB 19577 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s679.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK69
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl69`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl69 : List Nat := [2665, 2672477, 2673467, 2729580, 2729581, 2729582, 2729583, 2729584, 2729585, 2729586, 2729587, 2729588, 2729589, 2729590, 2729591, 2729592, 2729593, 2729594]
def PRE_first_tail_x15_r0_body.clo69 : List Nat := [19573, 19574, 19575, 19576]
def PRE_first_tail_x15_r0_body.cln69 : List Nat := [16661, 16662, 16663, 16664, 16665, 16666]
def PRE_first_tail_x15_r0_body.cli69 : List Nat := [16661, 16662, 16663, 16664, 16665, 16666]
kernel_rfl PRE_first_tail_x15_r0_body.cheap69 : PRE_first_tail_x15_r0_body.s679.heap = Stage.setAll PRE_first_tail_x15_r0_body.s677.heap (PRE_first_tail_x15_r0_body.cl69.filterMap fun a => (PRE_first_tail_x15_r0_body.s679.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe69 : Nat.ble PRE_first_tail_x15_r0_body.s677.next PRE_first_tail_x15_r0_body.s679.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP69 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s677 PRE_first_tail_x15_r0_body.s679 PRE_first_tail_x15_r0_body.cl69 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp69 : Conv.suppListB PRE_first_tail_x15_r0_body.s679 3048 PRE_first_tail_x15_r0_body.cl69 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound69 : Conv.boundListB PRE_first_tail_x15_r0_body.s679 PRE_first_tail_x15_r0_body.cl69 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK69 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s679.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln69.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s679.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK69 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s679.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo69.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s679.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK69 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s679.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli69.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s679.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst69 : Conv.sstListB 3048 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s679.ffi).mlx PRE_first_tail_x15_r0_body.cln69 PRE_first_tail_x15_r0_body.clo69 PRE_first_tail_x15_r0_body.cli69 = true

end Host.Load.Run.Tpl
end

section -- SiteCl69
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA69 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s679.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo69.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s679.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd69 : (PRE_first_tail_x15_r0_body.clo69 ++ PRE_first_tail_x15_r0_body.cln69 ++ PRE_first_tail_x15_r0_body.cli69).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle69 : Conv.Cnt.leB (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt) (⟨19577, 16667, 2729595, 3048⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck69 : Conv.ncleanListB (⟨19577, 16667, 2729595, 3048⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s679.ffi).mlx PRE_first_tail_x15_r0_body.clo69 PRE_first_tail_x15_r0_body.cln69 PRE_first_tail_x15_r0_body.cli69 = true
theorem PRE_first_tail_x15_r0_body.cncl69 (h : Conv.NClean (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx) : Conv.NClean (⟨19577, 16667, 2729595, 3048⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s679.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle69 PRE_first_tail_x15_r0_body.ckA69 PRE_first_tail_x15_r0_body.cobjsK69 PRE_first_tail_x15_r0_body.cnodesK69 PRE_first_tail_x15_r0_body.citemsK69 PRE_first_tail_x15_r0_body.cbd69 PRE_first_tail_x15_r0_body.cck69

end Host.Load.Run.Tpl
end

section -- SiteS69
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 69 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc69 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P69 : LoadP := PRE_first_tail_x15_r0_body.Pc69.raise 16667
kernel_rfl PRE_first_tail_x15_r0_body.craise69 : Nat.ble PRE_first_tail_x15_r0_body.Pc69.N0 16667 = true
theorem PRE_first_tail_x15_r0_body.raised69 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc69 PRE_first_tail_x15_r0_body.P69 :=
  .inr ⟨16667, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise69, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_69 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s679.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_69 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi)
def PRE_first_tail_x15_r0_body.khinv69 : PTrie Nat := Stage.setAll PTrie.nil [(19575, 19573), (19576, 19574), (19578, 19575), (19577, 19576)]
def PRE_first_tail_x15_r0_body.kninv69 : PTrie Nat := Stage.setAll PTrie.nil [(16661, 16661), (16662, 16662), (16663, 16663), (16664, 16664), (16665, 16665), (16666, 16666)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS69 : List Nat := [19573, 19574, 19575, 19576, 19577, 19578]
def PRE_first_tail_x15_r0_body.cnS69 : List Nat := List.range' 16661 6
def PRE_first_tail_x15_r0_body.ciS69 : List Nat := [] ++ List.range' 16661 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh069 : PRE_first_tail_x15_r0_body.kd69.nh0 = PRE_first_tail_x15_r0_body.cx0_69.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh169 : PRE_first_tail_x15_r0_body.kd69.nh1 = PRE_first_tail_x15_r0_body.cx1_69.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn069 : PRE_first_tail_x15_r0_body.kd69.nn0 = PRE_first_tail_x15_r0_body.cx0_69.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn169 : PRE_first_tail_x15_r0_body.kd69.nn1 = PRE_first_tail_x15_r0_body.cx1_69.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo69 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P69.lo && Nat.ble PRE_first_tail_x15_r0_body.P69.lo PRE_first_tail_x15_r0_body.cx0_69.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P69.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P69.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt69 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_69.mlx.next PRE_first_tail_x15_r0_body.cx1_69.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_69.mlx.nnext PRE_first_tail_x15_r0_body.cx1_69.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband69 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P69.NL && Nat.ble PRE_first_tail_x15_r0_body.P69.NL PRE_first_tail_x15_r0_body.P69.N0 && Nat.ble PRE_first_tail_x15_r0_body.P69.N0 PRE_first_tail_x15_r0_body.cx0_69.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow69 : PRE_first_tail_x15_r0_body.kd69.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren69 : checkRenG PRE_first_tail_x15_r0_body.kd69.hnd PRE_first_tail_x15_r0_body.khinv69 (phB PRE_first_tail_x15_r0_body.cx0_69.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband69 : PRE_first_tail_x15_r0_body.kd69.checkBand PRE_first_tail_x15_r0_body.P69.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos69 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd69.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren69 : checkRenG PRE_first_tail_x15_r0_body.kd69.node PRE_first_tail_x15_r0_body.kninv69 (pnB PRE_first_tail_x15_r0_body.cx0_69.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow69 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd69.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P69.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd69.nodeF j) PRE_first_tail_x15_r0_body.cx1_69.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a69 : PRE_first_tail_x15_r0_body.cx0_69.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b69 : PRE_first_tail_x15_r0_body.cx0_69.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok169 : PRE_first_tail_x15_r0_body.cx1_69.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend69 : PRE_first_tail_x15_r0_body.cx1_69.mlx.pending = PRE_first_tail_x15_r0_body.cx0_69.mlx.pending.map PRE_first_tail_x15_r0_body.kappa69.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh69 : PRE_first_tail_x15_r0_body.cx1_69.mlx.errh = PRE_first_tail_x15_r0_body.cx0_69.mlx.errh.map PRE_first_tail_x15_r0_body.kappa69.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles69 : PRE_first_tail_x15_r0_body.cx1_69.mlx.files = PRE_first_tail_x15_r0_body.cx0_69.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch69 : PRE_first_tail_x15_r0_body.cx1_69.mlx.arch = PRE_first_tail_x15_r0_body.cx0_69.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes69 : PRE_first_tail_x15_r0_body.cx1_69.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_69.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired69 : PRE_first_tail_x15_r0_body.cx1_69.mlx.wired = PRE_first_tail_x15_r0_body.cx0_69.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost69 : PRE_first_tail_x15_r0_body.cx1_69.host = PRE_first_tail_x15_r0_body.cx0_69.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd69`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn069 : PRE_first_tail_x15_r0_body.kd69.n0 = 2729595
kernel_rfl PRE_first_tail_x15_r0_body.ckn169 : PRE_first_tail_x15_r0_body.kd69.n1 = 2729945
kernel_rfl PRE_first_tail_x15_r0_body.ckheap69 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd69.heap).all (fun x => Nat.ble 2729580 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl69 : (List.range 15).all (fun j => decide (PRE_first_tail_x15_r0_body.kd69.heap.get (2729580 + j) = nth? PRE_first_tail_x15_r0_body.pl69 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja69 : Nat.ble 2729580 2729580 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn69 : Nat.ble 3039 3039 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD69 : Nat.ble 2729580 PRE_first_tail_x15_r0_body.kd69.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn69 : Nat.ble 19573 PRE_first_tail_x15_r0_body.kd69.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn69 : Nat.ble 16661 PRE_first_tail_x15_r0_body.kd69.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb69 : Nat.ble 19573 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap69 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd69.heap).all (Nat.ble (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd69 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd69.hnd).all (Nat.ble (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode69 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd69.node).all (Nat.ble (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix69 : Conv.FixOld (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa69 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja69) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn69) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD69) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn69) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn69) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb69) PRE_first_tail_x15_r0_body.fheap69 PRE_first_tail_x15_r0_body.fhnd69 PRE_first_tail_x15_r0_body.fnode69
kernel_rfl PRE_first_tail_x15_r0_body.fcxn69 : (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn69 : (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle069 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_69.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_69.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk69 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd69.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A69 : PRE_first_tail_x15_r0_body.cx1_69.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS69.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_69.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O69 : PRE_first_tail_x15_r0_body.cx1_69.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS69.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_69.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N69 : PRE_first_tail_x15_r0_body.cx1_69.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS69.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_69.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I69 : PRE_first_tail_x15_r0_body.cx1_69.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS69.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_69.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd69 : (PRE_first_tail_x15_r0_body.clo69 ++ PRE_first_tail_x15_r0_body.cln69 ++ PRE_first_tail_x15_r0_body.cli69 ++ PRE_first_tail_x15_r0_body.cwS69 ++ PRE_first_tail_x15_r0_body.cnS69 ++ PRE_first_tail_x15_r0_body.ciS69).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW69 : PRE_first_tail_x15_r0_body.cwS69.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo69.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI69 : PRE_first_tail_x15_r0_body.ciS69.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli69.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN69 : PRE_first_tail_x15_r0_body.cnS69.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF69 : PRE_first_tail_x15_r0_body.cln69.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh69 : PRE_first_tail_x15_r0_body.clo69.all (handleOK PRE_first_tail_x15_r0_body.kappa69 PRE_first_tail_x15_r0_body.P69.lo PRE_first_tail_x15_r0_body.cx0_69.mlx PRE_first_tail_x15_r0_body.cx1_69.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo69 : PRE_first_tail_x15_r0_body.clo69.map (fun h => PRE_first_tail_x15_r0_body.cx1_69.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa69.handle h)) = PRE_first_tail_x15_r0_body.clo69.map (fun h => (PRE_first_tail_x15_r0_body.cx0_69.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa69.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok69 : PRE_first_tail_x15_r0_body.clo69.all (objOK PRE_first_tail_x15_r0_body.kappa69 PRE_first_tail_x15_r0_body.P69.NL PRE_first_tail_x15_r0_body.cx0_69.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd69 : PRE_first_tail_x15_r0_body.cln69.all (nodeOKF PRE_first_tail_x15_r0_body.kappa69 PRE_first_tail_x15_r0_body.P69 PRE_first_tail_x15_r0_body.cx0_69.mlx PRE_first_tail_x15_r0_body.cx1_69.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp69 : ((PRE_first_tail_x15_r0_body.cln69.filter (fullB PRE_first_tail_x15_r0_body.P69))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_69.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa69.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln69.filter (fullB PRE_first_tail_x15_r0_body.P69))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_69.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa69.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI69 : incrB PRE_first_tail_x15_r0_body.kd69.nodeF (List.range' 16661 6) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK69 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd69.node).all (fun k => Nat.ble 16661 k && Nat.blt k 16667) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL69 : (PRE_first_tail_x15_r0_body.cln69.filter (Nat.ble PRE_first_tail_x15_r0_body.P69.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd69.nodeF i) && (Nat.blt i 16667 || Nat.ble PRE_first_tail_x15_r0_body.kd69.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord69 : (PRE_first_tail_x15_r0_body.cln69.filter (Nat.ble PRE_first_tail_x15_r0_body.P69.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd69.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd69.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd69.nodeF j) (PRE_first_tail_x15_r0_body.kd69.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow69 PRE_first_tail_x15_r0_body.cnn169 PRE_first_tail_x15_r0_body.fnordI69 PRE_first_tail_x15_r0_body.fnordK69 PRE_first_tail_x15_r0_body.fnordL69
kernel_rfl PRE_first_tail_x15_r0_body.fi69 : PRE_first_tail_x15_r0_body.cli69.all (pnB PRE_first_tail_x15_r0_body.cx0_69.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii69 : PRE_first_tail_x15_r0_body.cli69.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_69.mlx.items.get (PRE_first_tail_x15_r0_body.kappa69.node k) = (PRE_first_tail_x15_r0_body.cx0_69.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa69.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot69 (clean : Conv.NClean (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P69.NL) (cl : SSt (· < 3048) PRE_first_tail_x15_r0_body.cx0_69.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P69 3048 PRE_first_tail_x15_r0_body.kappa69 PRE_first_tail_x15_r0_body.kd69 PRE_first_tail_x15_r0_body.khinv69 PRE_first_tail_x15_r0_body.kninv69 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx PRE_first_tail_x15_r0_body.cx0_69.mlx PRE_first_tail_x15_r0_body.cx1_69.mlx (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo69 PRE_first_tail_x15_r0_body.cln69 PRE_first_tail_x15_r0_body.cli69 PRE_first_tail_x15_r0_body.cwS69 PRE_first_tail_x15_r0_body.cnS69 PRE_first_tail_x15_r0_body.ciS69 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh069, PRE_first_tail_x15_r0_body.cnh169, PRE_first_tail_x15_r0_body.cnn069, PRE_first_tail_x15_r0_body.cnn169, PRE_first_tail_x15_r0_body.cplo69, PRE_first_tail_x15_r0_body.ccnt69, PRE_first_tail_x15_r0_body.cnband69, PRE_first_tail_x15_r0_body.chbelow69, PRE_first_tail_x15_r0_body.chren69, PRE_first_tail_x15_r0_body.cband69, PRE_first_tail_x15_r0_body.cnh1pos69, PRE_first_tail_x15_r0_body.cnren69, PRE_first_tail_x15_r0_body.cnlow69, PRE_first_tail_x15_r0_body.cabs0a69, PRE_first_tail_x15_r0_body.cabs0b69, PRE_first_tail_x15_r0_body.ctok169, PRE_first_tail_x15_r0_body.cpend69, PRE_first_tail_x15_r0_body.cerrh69, PRE_first_tail_x15_r0_body.cfiles69, PRE_first_tail_x15_r0_body.carch69, PRE_first_tail_x15_r0_body.csizes69, PRE_first_tail_x15_r0_body.cwired69, PRE_first_tail_x15_r0_body.cfix69, clean, PRE_first_tail_x15_r0_body.fcxn69, PRE_first_tail_x15_r0_body.fcnn69, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle069, PRE_first_tail_x15_r0_body.fnk69, PRE_first_tail_x15_r0_body.ckA69, PRE_first_tail_x15_r0_body.cobjsK69, PRE_first_tail_x15_r0_body.cnodesK69, PRE_first_tail_x15_r0_body.citemsK69, PRE_first_tail_x15_r0_body.f1A69, PRE_first_tail_x15_r0_body.f1O69, PRE_first_tail_x15_r0_body.f1N69, PRE_first_tail_x15_r0_body.f1I69, PRE_first_tail_x15_r0_body.fbd69, PRE_first_tail_x15_r0_body.fincW69, PRE_first_tail_x15_r0_body.fincI69, PRE_first_tail_x15_r0_body.fincN69, PRE_first_tail_x15_r0_body.flnF69, PRE_first_tail_x15_r0_body.fh69, PRE_first_tail_x15_r0_body.fo69, PRE_first_tail_x15_r0_body.fok69, PRE_first_tail_x15_r0_body.fnd69, PRE_first_tail_x15_r0_body.fp69, PRE_first_tail_x15_r0_body.fnord69, PRE_first_tail_x15_r0_body.fi69, PRE_first_tail_x15_r0_body.fii69⟩
theorem PRE_first_tail_x15_r0_body.cnshift69 (clean : Conv.NClean (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P69.NL) (cl : SSt (· < 3048) PRE_first_tail_x15_r0_body.cx0_69.mlx) : NShift PRE_first_tail_x15_r0_body.P69 3048 PRE_first_tail_x15_r0_body.kappa69 PRE_first_tail_x15_r0_body.cx0_69 PRE_first_tail_x15_r0_body.cx1_69 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot69 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost69 (compact_a_eq PRE_first_tail_x15_r0_body.ckn069 PRE_first_tail_x15_r0_body.ckn169 PRE_first_tail_x15_r0_body.ckheap69 PRE_first_tail_x15_r0_body.ckpl69)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_69 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s677.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_69 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s677.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_69 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s677.ffi) = some PRE_first_tail_x15_r0_body.fxC_69
kernel_rfl PRE_first_tail_x15_r0_body.okrC_69 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s677.ffi) = some PRE_first_tail_x15_r0_body.krC_69
noncomputable def PRE_first_tail_x15_r0_body.fx0_69 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s679.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_69 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s679.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_69 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s679.ffi) = some PRE_first_tail_x15_r0_body.fx0_69
kernel_rfl PRE_first_tail_x15_r0_body.okr0_69 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s679.ffi) = some PRE_first_tail_x15_r0_body.kr0_69
noncomputable def PRE_first_tail_x15_r0_body.fx1_69 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s678.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_69 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s678.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_69 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s678.ffi) = some PRE_first_tail_x15_r0_body.fx1_69
kernel_rfl PRE_first_tail_x15_r0_body.okr1_69 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s678.ffi) = some PRE_first_tail_x15_r0_body.kr1_69
kernel_rfl PRE_first_tail_x15_r0_body.ff069 : PRE_first_tail_x15_r0_body.fx0_69 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_69 (PRE_first_tail_x15_r0_body.clo69.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_69.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff169 : PRE_first_tail_x15_r0_body.fx1_69 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_69 (PRE_first_tail_x15_r0_body.cwS69.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_69.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck69 : freedLB PRE_first_tail_x15_r0_body.kappa69 PRE_first_tail_x15_r0_body.cx0_69.mlx PRE_first_tail_x15_r0_body.fx0_69 PRE_first_tail_x15_r0_body.fx1_69 PRE_first_tail_x15_r0_body.clo69 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf069 : PRE_first_tail_x15_r0_body.kr0_69.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_69.flags (PRE_first_tail_x15_r0_body.clo69.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_69.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt069 : PRE_first_tail_x15_r0_body.kr0_69.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_69.targs (PRE_first_tail_x15_r0_body.clo69.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_69.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf169 : PRE_first_tail_x15_r0_body.kr1_69.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_69.flags (PRE_first_tail_x15_r0_body.cwS69.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_69.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt169 : PRE_first_tail_x15_r0_body.kr1_69.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_69.targs (PRE_first_tail_x15_r0_body.cwS69.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_69.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck69 : krecLB PRE_first_tail_x15_r0_body.kappa69 3048 PRE_first_tail_x15_r0_body.cx0_69.mlx PRE_first_tail_x15_r0_body.kr0_69 PRE_first_tail_x15_r0_body.kr1_69 PRE_first_tail_x15_r0_body.clo69 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn69 : Nat.ble 3039 3048 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge69 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s678.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s679.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR69 : pendRegB PRE_first_tail_x15_r0_body.kappa69 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s679.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe69 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s679.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift69 (clean : Conv.NClean (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P69.NL) (cl : SSt (· < 3048) PRE_first_tail_x15_r0_body.cx0_69.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_69.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_69.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_69.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_69.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P69 3048 PRE_first_tail_x15_r0_body.kappa69 PRE_first_tail_x15_r0_body.s679.ffi PRE_first_tail_x15_r0_body.s678.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift69 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue69, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp69 t ht),
    PRE_first_tail_x15_r0_body.cbridge69,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s679.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s678.ffi) (PRE_first_tail_x15_r0_body.cfoot69 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_69 PRE_first_tail_x15_r0_body.ofx1_69 hobjC PRE_first_tail_x15_r0_body.ff069 PRE_first_tail_x15_r0_body.ff169 PRE_first_tail_x15_r0_body.ffck69,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s679.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s678.ffi) (PRE_first_tail_x15_r0_body.cfoot69 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_69 PRE_first_tail_x15_r0_body.okr1_69 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn69) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf069 PRE_first_tail_x15_r0_body.fkt069 PRE_first_tail_x15_r0_body.fkf169 PRE_first_tail_x15_r0_body.fkt169 PRE_first_tail_x15_r0_body.fkck69,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh069 PRE_first_tail_x15_r0_body.cnh169 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe69) PRE_first_tail_x15_r0_body.cpendR69⟩

end Host.Load.Run.Tpl
end

section -- st69/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st69 0
host_stream_state PRE_first_tail_x15_r0_body.st69 1
host_stream_state PRE_first_tail_x15_r0_body.st69 2
host_stream_state PRE_first_tail_x15_r0_body.st69 3
end Host.Load.Run.Tpl
end

section -- Site69
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 69 of chain `PRE_first_tail_x15_r0_body`: `kvW__g69__g70` (`appendWindow`), the call state `PRE_first_tail_x15_r0_body.s677`, the merged state `PRE_first_tail_x15_r0_body.s678`,
the site template `PRE_first_tail_x15_r0_body.st69` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s679`: the merge.
The footprint's facts are in `SiteF69`, the compaction's in `SiteC69`, `SiteK69`, `SiteNa69`, `SiteNb69`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso69 : PRE_first_tail_x15_r0_body.st69.s0 = { PRE_first_tail_x15_r0_body.s677 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs69 : List Frame := PRE_first_tail_x15_r0_body.s677.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_69 : PRE_first_tail_x15_r0_body.S677.tab.length = 3039
kernel_rfl PRE_first_tail_x15_r0_body.tab0_69 : PRE_first_tail_x15_r0_body.st69.S0.tab = PRE_first_tail_x15_r0_body.S677.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws69 : List Nat := [2169, 2170, 2171, 2172, 2173, 2174, 2175, 2176, 2177, 2178, 2179, 2180, 2181, 2182, 2183, 2184, 2185]
kernel_rfl PRE_first_tail_x15_r0_body.fresh69 : (PRE_first_tail_x15_r0_body.S677.tab.all fun e => PRE_first_tail_x15_r0_body.ws69.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S677.oracle.all fun q => PRE_first_tail_x15_r0_body.ws69.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab69 : PRE_first_tail_x15_r0_body.S678.tab = PRE_first_tail_x15_r0_body.S677.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws69
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen69 : PRE_first_tail_x15_r0_body.st69.S3.tab.length - PRE_first_tail_x15_r0_body.st69.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged69`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap69 : PRE_first_tail_x15_r0_body.s678.heap = PRE_first_tail_x15_r0_body.st69.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext69 : PRE_first_tail_x15_r0_body.s678.next = PRE_first_tail_x15_r0_body.st69.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl69 : PRE_first_tail_x15_r0_body.s678.ctl = PRE_first_tail_x15_r0_body.st69.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack69 : PRE_first_tail_x15_r0_body.s678.stack = PRE_first_tail_x15_r0_body.st69.s3.stack ++ PRE_first_tail_x15_r0_body.s677.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs69 : PRE_first_tail_x15_r0_body.s678.jobs = PRE_first_tail_x15_r0_body.st69.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi69 : PRE_first_tail_x15_r0_body.s678.ffi = PRE_first_tail_x15_r0_body.st69.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace69 : PRE_first_tail_x15_r0_body.s678.trace = PRE_first_tail_x15_r0_body.st69.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores69 : PRE_first_tail_x15_r0_body.s678.stores = PRE_first_tail_x15_r0_body.st69.s3.stores

end Host.Load.Run.Tpl
end

section -- SiteD69
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 69 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived69 : PRE_first_tail_x15_r0_body.nr69.map (fun r => nth? PRE_first_tail_x15_r0_body.st69.S3.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false)))]
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo69 : PRE_first_tail_x15_r0_body.nr69.all (Nat.ble 3039) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj69 : PRE_first_tail_x15_r0_body.cws69.all (fun c => !PRE_first_tail_x15_r0_body.ws69.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ69 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws69 PRE_first_tail_x15_r0_body.crs69 PRE_first_tail_x15_r0_body.ws69

end Host.Load.Run.Tpl
end

section -- st69/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st69`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st69.wrR : List (Nat × Nat) := [(2672477, 2672478)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st69.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st69.s3.heap PRE_first_tail_x15_r0_body.st69.wrR ++ freshOf PRE_first_tail_x15_r0_body.st69.s3.heap PRE_first_tail_x15_r0_body.st69.s0.next PRE_first_tail_x15_r0_body.st69.s3.next
noncomputable def PRE_first_tail_x15_r0_body.st69.wr : List Nat := PRE_first_tail_x15_r0_body.st69.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st69.heapFoot : PRE_first_tail_x15_r0_body.st69.s3.heap = setAll PRE_first_tail_x15_r0_body.st69.s0.heap PRE_first_tail_x15_r0_body.st69.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st69.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st69.s0.next PRE_first_tail_x15_r0_body.st69.s3.next = true
theorem PRE_first_tail_x15_r0_body.st69.grows : PRE_first_tail_x15_r0_body.st69.s0.next ≤ PRE_first_tail_x15_r0_body.st69.s3.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st69.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st69.wh : List Nat := [19573, 19574, 19575, 19576, 19577, 19578]
def PRE_first_tail_x15_r0_body.st69.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st69.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st69.s3.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st69.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st69.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st69.s3.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st69.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st69.s3.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st69.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st69.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st69.s3.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st69.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st69.s3.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st69.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st69.s3.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st69.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st69.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st69.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st69.s3.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st69.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st69.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st69.s3.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st69.s3.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st69.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st69.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st69.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st69.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st69.s3.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st69.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st69.s3.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF69
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 69 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB69 : nodupT PRE_first_tail_x15_r0_body.st69.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup69 : PRE_first_tail_x15_r0_body.st69.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB69).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB69 : PRE_first_tail_x15_r0_body.st69.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound69 : ∀ b ∈ PRE_first_tail_x15_r0_body.st69.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB69 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr69 := PRE_first_tail_x15_r0_body.st69.s3.trace.take 26
kernel_rfl PRE_first_tail_x15_r0_body.traceEq69 : PRE_first_tail_x15_r0_body.st69.s3.trace = PRE_first_tail_x15_r0_body.trFr69 ++ PRE_first_tail_x15_r0_body.st69.s0.trace
theorem PRE_first_tail_x15_r0_body.trace69 : ∃ fr, PRE_first_tail_x15_r0_body.st69.s3.trace = fr ++ PRE_first_tail_x15_r0_body.st69.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq69⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide69 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB69 : (PRE_first_tail_x15_r0_body.wide69.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st69.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix69 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide69, WFix Map.id (Present PRE_first_tail_x15_r0_body.st69.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB69 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL69
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 69 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s678`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO69 : PRE_first_tail_x15_r0_body.st69.S0.oracle = PRE_first_tail_x15_r0_body.st69.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B69 : PRE_first_tail_x15_r0_body.st69.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st69.s0.next || (PRE_first_tail_x15_r0_body.st69.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot69 : Conv.StageFoot PRE_first_tail_x15_r0_body.st69.wr PRE_first_tail_x15_r0_body.st69.s0 PRE_first_tail_x15_r0_body.st69.s3 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st69.heapFoot PRE_first_tail_x15_r0_body.wrNodup69 PRE_first_tail_x15_r0_body.wrBound69 PRE_first_tail_x15_r0_body.wr0B69 PRE_first_tail_x15_r0_body.st69.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged69 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st69.F.S → PRE_first_tail_x15_r0_body.st69.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st69.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st69.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs69 PRE_first_tail_x15_r0_body.st69.wr PRE_first_tail_x15_r0_body.s677 PRE_first_tail_x15_r0_body.st69.s3 PRE_first_tail_x15_r0_body.st69.s0
      PRE_first_tail_x15_r0_body.st69.s3.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st69.F FR W stk M ν K PRE_first_tail_x15_r0_body.s678 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso69 PRE_first_tail_x15_r0_body.stFoot69 PRE_first_tail_x15_r0_body.wrNodup69 PRE_first_tail_x15_r0_body.wrBound69 PRE_first_tail_x15_r0_body.trace69 PRE_first_tail_x15_r0_body.mheap69
    PRE_first_tail_x15_r0_body.mnext69 PRE_first_tail_x15_r0_body.mctl69 PRE_first_tail_x15_r0_body.mstack69 PRE_first_tail_x15_r0_body.mjobs69 PRE_first_tail_x15_r0_body.mffi69 PRE_first_tail_x15_r0_body.mtrace69 PRE_first_tail_x15_r0_body.mstores69 h

def PRE_first_tail_x15_r0_body.arrEl69_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE69_2665 : arrOf PRE_first_tail_x15_r0_body.s678 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl69_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA69_2665 : isArrB PRE_first_tail_x15_r0_body.s678 2665 = true
theorem PRE_first_tail_x15_r0_body.arr69_2665 : ∃ o, PRE_first_tail_x15_r0_body.s678.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl69_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE69_2665 PRE_first_tail_x15_r0_body.arrA69_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN69_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl69_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR69_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl69_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN69_2665

def PRE_first_tail_x15_r0_body.arrEl69_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE69_2673467 : arrOf PRE_first_tail_x15_r0_body.s678 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl69_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA69_2673467 : isArrB PRE_first_tail_x15_r0_body.s678 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr69_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s678.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl69_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE69_2673467 PRE_first_tail_x15_r0_body.arrA69_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN69_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl69_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR69_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl69_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN69_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k69 : isArrB PRE_first_tail_x15_r0_body.s678 4910 = false
theorem PRE_first_tail_x15_r0_body.keep69 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s678 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k69 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr69_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl69_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ69
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 69 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s677`, the merged
state `PRE_first_tail_x15_r0_body.s678`, the canonical state `PRE_first_tail_x15_r0_body.s679`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl69 : PRE_first_tail_x15_r0_body.pl69.all (Nat.ble PRE_first_tail_x15_r0_body.s677.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd69 : nodupT PRE_first_tail_x15_r0_body.pl69 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn169 : Nat.ble PRE_first_tail_x15_r0_body.s677.next 2729945 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst69 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s677.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn69 : PRE_first_tail_x15_r0_body.s679.next = PRE_first_tail_x15_r0_body.s677.next + PRE_first_tail_x15_r0_body.pl69.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn69 : PRE_first_tail_x15_r0_body.s678.next = 2729945
kernel_rfl PRE_first_tail_x15_r0_body.zgrow69 : Nat.ble PRE_first_tail_x15_r0_body.s679.next PRE_first_tail_x15_r0_body.s678.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh69 : PRE_first_tail_x15_r0_body.S677.tab.all (fun e => PRE_first_tail_x15_r0_body.cws69.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd69 : nodupT PRE_first_tail_x15_r0_body.cws69 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi69 : PRE_first_tail_x15_r0_body.nr69.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S678.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt69 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s677.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg69_2665 : PRE_first_tail_x15_r0_body.s679.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s679 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk69_2665 : (objOf PRE_first_tail_x15_r0_body.s679 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm69_2665 : PRE_first_tail_x15_r0_body.s678.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa69.obj (objOf PRE_first_tail_x15_r0_body.s679 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s678 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg69_2673467 : PRE_first_tail_x15_r0_body.s679.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s679 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk69_2673467 : (objOf PRE_first_tail_x15_r0_body.s679 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm69_2673467 : PRE_first_tail_x15_r0_body.s678.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa69.obj (objOf PRE_first_tail_x15_r0_body.s679 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s678 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw69_4910 : (PRE_first_tail_x15_r0_body.s679.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw69_2673472 : (PRE_first_tail_x15_r0_body.s679.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw69_2673473 : (PRE_first_tail_x15_r0_body.s679.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd69 : PRE_first_tail_x15_r0_body.cl69.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr69 : PRE_first_tail_x15_r0_body.st69.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s677.next || PRE_first_tail_x15_r0_body.cl69.contains b) = true
def PRE_first_tail_x15_r0_body.zl69 : List Nat := PRE_first_tail_x15_r0_body.cl69.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE69 : PRE_first_tail_x15_r0_body.zl69.map (fun a => PRE_first_tail_x15_r0_body.s678.heap.get (PRE_first_tail_x15_r0_body.kappa69.a a)) = PRE_first_tail_x15_r0_body.zl69.map (fun a => (PRE_first_tail_x15_r0_body.s679.heap.get a).map PRE_first_tail_x15_r0_body.kappa69.hobj)
theorem PRE_first_tail_x15_r0_body.zimg69 : HeapImg PRE_first_tail_x15_r0_body.kappa69 PRE_first_tail_x15_r0_body.s679 PRE_first_tail_x15_r0_body.s678 PRE_first_tail_x15_r0_body.zl69 := PRE_first_tail_x15_r0_body.zimgE69
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl69 : PRE_first_tail_x15_r0_body.s678.ctl = PRE_first_tail_x15_r0_body.kappa69.ctl PRE_first_tail_x15_r0_body.s679.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack69 : PRE_first_tail_x15_r0_body.s678.stack = PRE_first_tail_x15_r0_body.s679.stack.map PRE_first_tail_x15_r0_body.kappa69.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs69 : PRE_first_tail_x15_r0_body.s678.jobs = PRE_first_tail_x15_r0_body.s679.jobs.map PRE_first_tail_x15_r0_body.kappa69.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores69 : PRE_first_tail_x15_r0_body.s678.stores = PRE_first_tail_x15_r0_body.kappa69.stores PRE_first_tail_x15_r0_body.s679.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots69 : checkRootsSupp PRE_first_tail_x15_r0_body.s679 3048 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC69 : PRE_first_tail_x15_r0_body.S677.tab.length + PRE_first_tail_x15_r0_body.cws69.length = 3048
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap69 : PRE_first_tail_x15_r0_body.kappa69 = Conv.Map.compact PRE_first_tail_x15_r0_body.s677.next 2729945 PRE_first_tail_x15_r0_body.S677.tab.length PRE_first_tail_x15_r0_body.pl69 (PRE_first_tail_x15_r0_body.nr69.map NumV.ref) PRE_first_tail_x15_r0_body.kd69.big
  PRE_first_tail_x15_r0_body.kd69.region PRE_first_tail_x15_r0_body.kd69.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin69 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s679.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc69 : Conv.jcleanListB (⟨19577, 16667, 2729595, 3048⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s679 PRE_first_tail_x15_r0_body.cl69 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB69 : noBigRootsP (fun i => !Conv.oldBigB (⟨19577, 16667, 2729595, 3048⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s679.trace PRE_first_tail_x15_r0_body.s679 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm69 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16661 = true
theorem PRE_first_tail_x15_r0_body.cjcl69 (h : Conv.JClean (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s677) : Conv.JClean (⟨19577, 16667, 2729595, 3048⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s679 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle69)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap69 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd69 a ha)) PRE_first_tail_x15_r0_body.zjc69

end Host.Load.Run.Tpl
end

section -- st69/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st69.bodyLast from PRE_first_tail_x15_r0_body.st69.s2 to PRE_first_tail_x15_r0_body.st69.s3 :
  interpS (step PRE_first_tail_x15_r0_body.st69.F PRE_first_tail_x15_r0_body.st69.s2).run PRE_first_tail_x15_r0_body.st69.S2 = some (PRE_first_tail_x15_r0_body.st69.s3, PRE_first_tail_x15_r0_body.st69.S3)
kernel_rfl PRE_first_tail_x15_r0_body.st69.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st69.s2.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st69.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st69.s3.stack = true

end Host.Load.Run.Tpl
end

section -- st69/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st69.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st69.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st69.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st69.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st69.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st69.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st69.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st69.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st69.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st69.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st69.s0 PRE_first_tail_x15_r0_body.st69.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st69.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st69.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st69.s2 PRE_first_tail_x15_r0_body.st69.S2) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st69/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st69.bodyK0F from PRE_first_tail_x15_r0_body.st69.s0 to PRE_first_tail_x15_r0_body.st69.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st69.F (PRE_first_tail_x15_r0_body.st69.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st69.ks 0).getD 0) PRE_first_tail_x15_r0_body.st69.s0 PRE_first_tail_x15_r0_body.st69.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st69.s1, PRE_first_tail_x15_r0_body.st69.S1)
theorem PRE_first_tail_x15_r0_body.st69.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st69.F (PRE_first_tail_x15_r0_body.st69.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st69.ks 0).getD 0) PRE_first_tail_x15_r0_body.st69.s0 PRE_first_tail_x15_r0_body.st69.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st69.s1, PRE_first_tail_x15_r0_body.st69.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st69.bodyOkLN_ok PRE_first_tail_x15_r0_body.st69.bodyK0F
end Host.Load.Run.Tpl
end

section -- st69/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st69.bodyK1F from PRE_first_tail_x15_r0_body.st69.s1 to PRE_first_tail_x15_r0_body.st69.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st69.F (PRE_first_tail_x15_r0_body.st69.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st69.ks 1).getD 0) PRE_first_tail_x15_r0_body.st69.s1 PRE_first_tail_x15_r0_body.st69.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st69.s2, PRE_first_tail_x15_r0_body.st69.S2)
theorem PRE_first_tail_x15_r0_body.st69.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st69.F (PRE_first_tail_x15_r0_body.st69.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st69.ks 1).getD 0) PRE_first_tail_x15_r0_body.st69.s1 PRE_first_tail_x15_r0_body.st69.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st69.s2, PRE_first_tail_x15_r0_body.st69.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st69.bodyOkLN_ok PRE_first_tail_x15_r0_body.st69.bodyK1F
end Host.Load.Run.Tpl
end

section -- st69/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st69.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st69.F (PRE_first_tail_x15_r0_body.st69.bodyOkL bytes rows) 3452 PRE_first_tail_x15_r0_body.st69.s0 PRE_first_tail_x15_r0_body.st69.S0 = some (PRE_first_tail_x15_r0_body.st69.s2, PRE_first_tail_x15_r0_body.st69.S2) :=
  runOk_trans PRE_first_tail_x15_r0_body.st69.F (PRE_first_tail_x15_r0_body.st69.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st69.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st69.ks 1).getD 0) PRE_first_tail_x15_r0_body.st69.s0 PRE_first_tail_x15_r0_body.st69.s1 PRE_first_tail_x15_r0_body.st69.s2 PRE_first_tail_x15_r0_body.st69.S0 PRE_first_tail_x15_r0_body.st69.S1 PRE_first_tail_x15_r0_body.st69.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st69.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st69.bodyK1 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st69.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st69.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st69.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st69.F (PRE_first_tail_x15_r0_body.st69.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st69.s0
  S0 := PRE_first_tail_x15_r0_body.st69.S0
  s1 := PRE_first_tail_x15_r0_body.st69.s2
  S1 := PRE_first_tail_x15_r0_body.st69.S2
  s2 := PRE_first_tail_x15_r0_body.st69.s3
  S2 := PRE_first_tail_x15_r0_body.st69.S3
  n := 3452
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st69.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st69.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st69.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st69.bodyHalt
  last := PRE_first_tail_x15_r0_body.st69.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st69.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC70
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 70 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s687` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa70` into the merged state
`PRE_first_tail_x15_r0_body.s686`. -/

def PRE_first_tail_x15_r0_body.pl70 : List Nat := []
def PRE_first_tail_x15_r0_body.nr70 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd70 : RData :=
  ⟨2730177, 2730179, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19590, 19590, 16677, 16677, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa70 : Map :=
  Conv.Map.compact 2730177 2730179 3071 PRE_first_tail_x15_r0_body.pl70 (PRE_first_tail_x15_r0_body.nr70.map NumV.ref) PRE_first_tail_x15_r0_body.kd70.big
    PRE_first_tail_x15_r0_body.kd70.region PRE_first_tail_x15_r0_body.kd70.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws70 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs70 : List SymE := PRE_first_tail_x15_r0_body.nr70.map fun r => (nth? PRE_first_tail_x15_r0_body.S686.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta70 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws70 PRE_first_tail_x15_r0_body.crs70
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB70 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab70 : PRE_first_tail_x15_r0_body.S687.tab = PRE_first_tail_x15_r0_body.S685.tab ++ PRE_first_tail_x15_r0_body.cws70.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace70 : PRE_first_tail_x15_r0_body.s687.trace = PRE_first_tail_x15_r0_body.s685.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext70 : PRE_first_tail_x15_r0_body.s687.next = 2730177
kernel_rfl PRE_first_tail_x15_r0_body.ccounters70 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s687.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s687.ffi).mlx.nnext) = (19590, 16677)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue70 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s686.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s687.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa70.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp70 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s687.ffi).mlx.tokens.all (bSN 3071) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean70 : Conv.cleanListB 19590 131072 (fun r => Nat.ble 78360 r) PRE_first_tail_x15_r0_body.s687
    (PRE_first_tail_x15_r0_body.wrB70 ++ (List.range 0).map (2730177 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs70 : bigsOutB 19590 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s687.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK70
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl70`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl70 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo70 : List Nat := []
def PRE_first_tail_x15_r0_body.cln70 : List Nat := []
def PRE_first_tail_x15_r0_body.cli70 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap70 : PRE_first_tail_x15_r0_body.s687.heap = Stage.setAll PRE_first_tail_x15_r0_body.s685.heap (PRE_first_tail_x15_r0_body.cl70.filterMap fun a => (PRE_first_tail_x15_r0_body.s687.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe70 : Nat.ble PRE_first_tail_x15_r0_body.s685.next PRE_first_tail_x15_r0_body.s687.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP70 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s685 PRE_first_tail_x15_r0_body.s687 PRE_first_tail_x15_r0_body.cl70 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp70 : Conv.suppListB PRE_first_tail_x15_r0_body.s687 3071 PRE_first_tail_x15_r0_body.cl70 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound70 : Conv.boundListB PRE_first_tail_x15_r0_body.s687 PRE_first_tail_x15_r0_body.cl70 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK70 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s687.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln70.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s687.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK70 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s687.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo70.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s687.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK70 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s687.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli70.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s687.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst70 : Conv.sstListB 3071 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s687.ffi).mlx PRE_first_tail_x15_r0_body.cln70 PRE_first_tail_x15_r0_body.clo70 PRE_first_tail_x15_r0_body.cli70 = true

end Host.Load.Run.Tpl
end

section -- SiteCl70
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA70 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s687.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo70.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s687.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd70 : (PRE_first_tail_x15_r0_body.clo70 ++ PRE_first_tail_x15_r0_body.cln70 ++ PRE_first_tail_x15_r0_body.cli70).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle70 : Conv.Cnt.leB (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt) (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck70 : Conv.ncleanListB (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s687.ffi).mlx PRE_first_tail_x15_r0_body.clo70 PRE_first_tail_x15_r0_body.cln70 PRE_first_tail_x15_r0_body.cli70 = true
theorem PRE_first_tail_x15_r0_body.cncl70 (h : Conv.NClean (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx) : Conv.NClean (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s687.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle70 PRE_first_tail_x15_r0_body.ckA70 PRE_first_tail_x15_r0_body.cobjsK70 PRE_first_tail_x15_r0_body.cnodesK70 PRE_first_tail_x15_r0_body.citemsK70 PRE_first_tail_x15_r0_body.cbd70 PRE_first_tail_x15_r0_body.cck70

end Host.Load.Run.Tpl
end

section -- SiteS70
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 70 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc70 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P70 : LoadP := PRE_first_tail_x15_r0_body.Pc70.raise 16677
kernel_rfl PRE_first_tail_x15_r0_body.craise70 : Nat.ble PRE_first_tail_x15_r0_body.Pc70.N0 16677 = true
theorem PRE_first_tail_x15_r0_body.raised70 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc70 PRE_first_tail_x15_r0_body.P70 :=
  .inr ⟨16677, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise70, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_70 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s687.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_70 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s686.ffi)
def PRE_first_tail_x15_r0_body.khinv70 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv70 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS70 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS70 : List Nat := List.range' 16677 0
def PRE_first_tail_x15_r0_body.ciS70 : List Nat := [] ++ List.range' 16677 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh070 : PRE_first_tail_x15_r0_body.kd70.nh0 = PRE_first_tail_x15_r0_body.cx0_70.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh170 : PRE_first_tail_x15_r0_body.kd70.nh1 = PRE_first_tail_x15_r0_body.cx1_70.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn070 : PRE_first_tail_x15_r0_body.kd70.nn0 = PRE_first_tail_x15_r0_body.cx0_70.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn170 : PRE_first_tail_x15_r0_body.kd70.nn1 = PRE_first_tail_x15_r0_body.cx1_70.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo70 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P70.lo && Nat.ble PRE_first_tail_x15_r0_body.P70.lo PRE_first_tail_x15_r0_body.cx0_70.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P70.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P70.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt70 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_70.mlx.next PRE_first_tail_x15_r0_body.cx1_70.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_70.mlx.nnext PRE_first_tail_x15_r0_body.cx1_70.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband70 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P70.NL && Nat.ble PRE_first_tail_x15_r0_body.P70.NL PRE_first_tail_x15_r0_body.P70.N0 && Nat.ble PRE_first_tail_x15_r0_body.P70.N0 PRE_first_tail_x15_r0_body.cx0_70.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow70 : PRE_first_tail_x15_r0_body.kd70.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren70 : checkRenG PRE_first_tail_x15_r0_body.kd70.hnd PRE_first_tail_x15_r0_body.khinv70 (phB PRE_first_tail_x15_r0_body.cx0_70.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband70 : PRE_first_tail_x15_r0_body.kd70.checkBand PRE_first_tail_x15_r0_body.P70.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos70 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd70.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren70 : checkRenG PRE_first_tail_x15_r0_body.kd70.node PRE_first_tail_x15_r0_body.kninv70 (pnB PRE_first_tail_x15_r0_body.cx0_70.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow70 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd70.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P70.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd70.nodeF j) PRE_first_tail_x15_r0_body.cx1_70.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a70 : PRE_first_tail_x15_r0_body.cx0_70.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b70 : PRE_first_tail_x15_r0_body.cx0_70.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok170 : PRE_first_tail_x15_r0_body.cx1_70.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend70 : PRE_first_tail_x15_r0_body.cx1_70.mlx.pending = PRE_first_tail_x15_r0_body.cx0_70.mlx.pending.map PRE_first_tail_x15_r0_body.kappa70.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh70 : PRE_first_tail_x15_r0_body.cx1_70.mlx.errh = PRE_first_tail_x15_r0_body.cx0_70.mlx.errh.map PRE_first_tail_x15_r0_body.kappa70.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles70 : PRE_first_tail_x15_r0_body.cx1_70.mlx.files = PRE_first_tail_x15_r0_body.cx0_70.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch70 : PRE_first_tail_x15_r0_body.cx1_70.mlx.arch = PRE_first_tail_x15_r0_body.cx0_70.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes70 : PRE_first_tail_x15_r0_body.cx1_70.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_70.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired70 : PRE_first_tail_x15_r0_body.cx1_70.mlx.wired = PRE_first_tail_x15_r0_body.cx0_70.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost70 : PRE_first_tail_x15_r0_body.cx1_70.host = PRE_first_tail_x15_r0_body.cx0_70.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd70`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn070 : PRE_first_tail_x15_r0_body.kd70.n0 = 2730177
kernel_rfl PRE_first_tail_x15_r0_body.ckn170 : PRE_first_tail_x15_r0_body.kd70.n1 = 2730179
kernel_rfl PRE_first_tail_x15_r0_body.ckheap70 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd70.heap).all (fun x => Nat.ble 2730177 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl70 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd70.heap.get (2730177 + j) = nth? PRE_first_tail_x15_r0_body.pl70 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja70 : Nat.ble 2730177 2730177 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn70 : Nat.ble 3071 3071 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD70 : Nat.ble 2730177 PRE_first_tail_x15_r0_body.kd70.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn70 : Nat.ble 19590 PRE_first_tail_x15_r0_body.kd70.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn70 : Nat.ble 16677 PRE_first_tail_x15_r0_body.kd70.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb70 : Nat.ble 19590 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap70 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd70.heap).all (Nat.ble (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd70 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd70.hnd).all (Nat.ble (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode70 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd70.node).all (Nat.ble (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix70 : Conv.FixOld (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa70 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja70) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn70) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD70) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn70) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn70) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb70) PRE_first_tail_x15_r0_body.fheap70 PRE_first_tail_x15_r0_body.fhnd70 PRE_first_tail_x15_r0_body.fnode70
kernel_rfl PRE_first_tail_x15_r0_body.fcxn70 : (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn70 : (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle070 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_70.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_70.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk70 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd70.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A70 : PRE_first_tail_x15_r0_body.cx1_70.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS70.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_70.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O70 : PRE_first_tail_x15_r0_body.cx1_70.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS70.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_70.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N70 : PRE_first_tail_x15_r0_body.cx1_70.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS70.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_70.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I70 : PRE_first_tail_x15_r0_body.cx1_70.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS70.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_70.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd70 : (PRE_first_tail_x15_r0_body.clo70 ++ PRE_first_tail_x15_r0_body.cln70 ++ PRE_first_tail_x15_r0_body.cli70 ++ PRE_first_tail_x15_r0_body.cwS70 ++ PRE_first_tail_x15_r0_body.cnS70 ++ PRE_first_tail_x15_r0_body.ciS70).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW70 : PRE_first_tail_x15_r0_body.cwS70.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo70.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI70 : PRE_first_tail_x15_r0_body.ciS70.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli70.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN70 : PRE_first_tail_x15_r0_body.cnS70.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF70 : PRE_first_tail_x15_r0_body.cln70.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh70 : PRE_first_tail_x15_r0_body.clo70.all (handleOK PRE_first_tail_x15_r0_body.kappa70 PRE_first_tail_x15_r0_body.P70.lo PRE_first_tail_x15_r0_body.cx0_70.mlx PRE_first_tail_x15_r0_body.cx1_70.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo70 : PRE_first_tail_x15_r0_body.clo70.map (fun h => PRE_first_tail_x15_r0_body.cx1_70.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa70.handle h)) = PRE_first_tail_x15_r0_body.clo70.map (fun h => (PRE_first_tail_x15_r0_body.cx0_70.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa70.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok70 : PRE_first_tail_x15_r0_body.clo70.all (objOK PRE_first_tail_x15_r0_body.kappa70 PRE_first_tail_x15_r0_body.P70.NL PRE_first_tail_x15_r0_body.cx0_70.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd70 : PRE_first_tail_x15_r0_body.cln70.all (nodeOKF PRE_first_tail_x15_r0_body.kappa70 PRE_first_tail_x15_r0_body.P70 PRE_first_tail_x15_r0_body.cx0_70.mlx PRE_first_tail_x15_r0_body.cx1_70.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp70 : ((PRE_first_tail_x15_r0_body.cln70.filter (fullB PRE_first_tail_x15_r0_body.P70))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_70.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa70.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln70.filter (fullB PRE_first_tail_x15_r0_body.P70))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_70.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa70.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI70 : incrB PRE_first_tail_x15_r0_body.kd70.nodeF (List.range' 16677 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK70 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd70.node).all (fun k => Nat.ble 16677 k && Nat.blt k 16677) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL70 : (PRE_first_tail_x15_r0_body.cln70.filter (Nat.ble PRE_first_tail_x15_r0_body.P70.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd70.nodeF i) && (Nat.blt i 16677 || Nat.ble PRE_first_tail_x15_r0_body.kd70.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord70 : (PRE_first_tail_x15_r0_body.cln70.filter (Nat.ble PRE_first_tail_x15_r0_body.P70.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd70.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd70.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd70.nodeF j) (PRE_first_tail_x15_r0_body.kd70.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow70 PRE_first_tail_x15_r0_body.cnn170 PRE_first_tail_x15_r0_body.fnordI70 PRE_first_tail_x15_r0_body.fnordK70 PRE_first_tail_x15_r0_body.fnordL70
kernel_rfl PRE_first_tail_x15_r0_body.fi70 : PRE_first_tail_x15_r0_body.cli70.all (pnB PRE_first_tail_x15_r0_body.cx0_70.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii70 : PRE_first_tail_x15_r0_body.cli70.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_70.mlx.items.get (PRE_first_tail_x15_r0_body.kappa70.node k) = (PRE_first_tail_x15_r0_body.cx0_70.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa70.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot70 (clean : Conv.NClean (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P70.NL) (cl : SSt (· < 3071) PRE_first_tail_x15_r0_body.cx0_70.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P70 3071 PRE_first_tail_x15_r0_body.kappa70 PRE_first_tail_x15_r0_body.kd70 PRE_first_tail_x15_r0_body.khinv70 PRE_first_tail_x15_r0_body.kninv70 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx PRE_first_tail_x15_r0_body.cx0_70.mlx PRE_first_tail_x15_r0_body.cx1_70.mlx (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo70 PRE_first_tail_x15_r0_body.cln70 PRE_first_tail_x15_r0_body.cli70 PRE_first_tail_x15_r0_body.cwS70 PRE_first_tail_x15_r0_body.cnS70 PRE_first_tail_x15_r0_body.ciS70 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh070, PRE_first_tail_x15_r0_body.cnh170, PRE_first_tail_x15_r0_body.cnn070, PRE_first_tail_x15_r0_body.cnn170, PRE_first_tail_x15_r0_body.cplo70, PRE_first_tail_x15_r0_body.ccnt70, PRE_first_tail_x15_r0_body.cnband70, PRE_first_tail_x15_r0_body.chbelow70, PRE_first_tail_x15_r0_body.chren70, PRE_first_tail_x15_r0_body.cband70, PRE_first_tail_x15_r0_body.cnh1pos70, PRE_first_tail_x15_r0_body.cnren70, PRE_first_tail_x15_r0_body.cnlow70, PRE_first_tail_x15_r0_body.cabs0a70, PRE_first_tail_x15_r0_body.cabs0b70, PRE_first_tail_x15_r0_body.ctok170, PRE_first_tail_x15_r0_body.cpend70, PRE_first_tail_x15_r0_body.cerrh70, PRE_first_tail_x15_r0_body.cfiles70, PRE_first_tail_x15_r0_body.carch70, PRE_first_tail_x15_r0_body.csizes70, PRE_first_tail_x15_r0_body.cwired70, PRE_first_tail_x15_r0_body.cfix70, clean, PRE_first_tail_x15_r0_body.fcxn70, PRE_first_tail_x15_r0_body.fcnn70, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle070, PRE_first_tail_x15_r0_body.fnk70, PRE_first_tail_x15_r0_body.ckA70, PRE_first_tail_x15_r0_body.cobjsK70, PRE_first_tail_x15_r0_body.cnodesK70, PRE_first_tail_x15_r0_body.citemsK70, PRE_first_tail_x15_r0_body.f1A70, PRE_first_tail_x15_r0_body.f1O70, PRE_first_tail_x15_r0_body.f1N70, PRE_first_tail_x15_r0_body.f1I70, PRE_first_tail_x15_r0_body.fbd70, PRE_first_tail_x15_r0_body.fincW70, PRE_first_tail_x15_r0_body.fincI70, PRE_first_tail_x15_r0_body.fincN70, PRE_first_tail_x15_r0_body.flnF70, PRE_first_tail_x15_r0_body.fh70, PRE_first_tail_x15_r0_body.fo70, PRE_first_tail_x15_r0_body.fok70, PRE_first_tail_x15_r0_body.fnd70, PRE_first_tail_x15_r0_body.fp70, PRE_first_tail_x15_r0_body.fnord70, PRE_first_tail_x15_r0_body.fi70, PRE_first_tail_x15_r0_body.fii70⟩
theorem PRE_first_tail_x15_r0_body.cnshift70 (clean : Conv.NClean (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P70.NL) (cl : SSt (· < 3071) PRE_first_tail_x15_r0_body.cx0_70.mlx) : NShift PRE_first_tail_x15_r0_body.P70 3071 PRE_first_tail_x15_r0_body.kappa70 PRE_first_tail_x15_r0_body.cx0_70 PRE_first_tail_x15_r0_body.cx1_70 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot70 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost70 (compact_a_eq PRE_first_tail_x15_r0_body.ckn070 PRE_first_tail_x15_r0_body.ckn170 PRE_first_tail_x15_r0_body.ckheap70 PRE_first_tail_x15_r0_body.ckpl70)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_70 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s685.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_70 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s685.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_70 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s685.ffi) = some PRE_first_tail_x15_r0_body.fxC_70
kernel_rfl PRE_first_tail_x15_r0_body.okrC_70 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s685.ffi) = some PRE_first_tail_x15_r0_body.krC_70
noncomputable def PRE_first_tail_x15_r0_body.fx0_70 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s687.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_70 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s687.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_70 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s687.ffi) = some PRE_first_tail_x15_r0_body.fx0_70
kernel_rfl PRE_first_tail_x15_r0_body.okr0_70 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s687.ffi) = some PRE_first_tail_x15_r0_body.kr0_70
noncomputable def PRE_first_tail_x15_r0_body.fx1_70 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s686.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_70 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s686.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_70 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s686.ffi) = some PRE_first_tail_x15_r0_body.fx1_70
kernel_rfl PRE_first_tail_x15_r0_body.okr1_70 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s686.ffi) = some PRE_first_tail_x15_r0_body.kr1_70
kernel_rfl PRE_first_tail_x15_r0_body.ff070 : PRE_first_tail_x15_r0_body.fx0_70 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_70 (PRE_first_tail_x15_r0_body.clo70.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_70.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff170 : PRE_first_tail_x15_r0_body.fx1_70 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_70 (PRE_first_tail_x15_r0_body.cwS70.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_70.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck70 : freedLB PRE_first_tail_x15_r0_body.kappa70 PRE_first_tail_x15_r0_body.cx0_70.mlx PRE_first_tail_x15_r0_body.fx0_70 PRE_first_tail_x15_r0_body.fx1_70 PRE_first_tail_x15_r0_body.clo70 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf070 : PRE_first_tail_x15_r0_body.kr0_70.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_70.flags (PRE_first_tail_x15_r0_body.clo70.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_70.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt070 : PRE_first_tail_x15_r0_body.kr0_70.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_70.targs (PRE_first_tail_x15_r0_body.clo70.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_70.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf170 : PRE_first_tail_x15_r0_body.kr1_70.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_70.flags (PRE_first_tail_x15_r0_body.cwS70.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_70.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt170 : PRE_first_tail_x15_r0_body.kr1_70.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_70.targs (PRE_first_tail_x15_r0_body.cwS70.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_70.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck70 : krecLB PRE_first_tail_x15_r0_body.kappa70 3071 PRE_first_tail_x15_r0_body.cx0_70.mlx PRE_first_tail_x15_r0_body.kr0_70 PRE_first_tail_x15_r0_body.kr1_70 PRE_first_tail_x15_r0_body.clo70 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn70 : Nat.ble 3071 3071 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge70 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s686.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s687.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR70 : pendRegB PRE_first_tail_x15_r0_body.kappa70 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s687.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe70 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s687.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s686.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift70 (clean : Conv.NClean (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P70.NL) (cl : SSt (· < 3071) PRE_first_tail_x15_r0_body.cx0_70.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_70.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_70.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_70.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_70.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P70 3071 PRE_first_tail_x15_r0_body.kappa70 PRE_first_tail_x15_r0_body.s687.ffi PRE_first_tail_x15_r0_body.s686.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift70 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue70, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp70 t ht),
    PRE_first_tail_x15_r0_body.cbridge70,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s687.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s686.ffi) (PRE_first_tail_x15_r0_body.cfoot70 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_70 PRE_first_tail_x15_r0_body.ofx1_70 hobjC PRE_first_tail_x15_r0_body.ff070 PRE_first_tail_x15_r0_body.ff170 PRE_first_tail_x15_r0_body.ffck70,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s687.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s686.ffi) (PRE_first_tail_x15_r0_body.cfoot70 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_70 PRE_first_tail_x15_r0_body.okr1_70 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn70) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf070 PRE_first_tail_x15_r0_body.fkt070 PRE_first_tail_x15_r0_body.fkf170 PRE_first_tail_x15_r0_body.fkt170 PRE_first_tail_x15_r0_body.fkck70,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh070 PRE_first_tail_x15_r0_body.cnh170 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe70) PRE_first_tail_x15_r0_body.cpendR70⟩

end Host.Load.Run.Tpl
end

section -- st70/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st70 0
host_stream_state PRE_first_tail_x15_r0_body.st70 1
host_stream_state PRE_first_tail_x15_r0_body.st70 2
end Host.Load.Run.Tpl
end

section -- Site70
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 70 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g70__g71` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s685`, the merged state `PRE_first_tail_x15_r0_body.s686`,
the site template `PRE_first_tail_x15_r0_body.st70` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s687`: the merge.
The footprint's facts are in `SiteF70`, the compaction's in `SiteC70`, `SiteK70`, `SiteNa70`, `SiteNb70`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso70 : PRE_first_tail_x15_r0_body.st70.s0 = { PRE_first_tail_x15_r0_body.s685 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs70 : List Frame := PRE_first_tail_x15_r0_body.s685.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_70 : PRE_first_tail_x15_r0_body.S685.tab.length = 3071
kernel_rfl PRE_first_tail_x15_r0_body.tab0_70 : PRE_first_tail_x15_r0_body.st70.S0.tab = PRE_first_tail_x15_r0_body.S685.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws70 : List Nat := [2195, 2196]
kernel_rfl PRE_first_tail_x15_r0_body.fresh70 : (PRE_first_tail_x15_r0_body.S685.tab.all fun e => PRE_first_tail_x15_r0_body.ws70.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S685.oracle.all fun q => PRE_first_tail_x15_r0_body.ws70.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab70 : PRE_first_tail_x15_r0_body.S686.tab = PRE_first_tail_x15_r0_body.S685.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws70
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen70 : PRE_first_tail_x15_r0_body.st70.S2.tab.length - PRE_first_tail_x15_r0_body.st70.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged70`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap70 : PRE_first_tail_x15_r0_body.s686.heap = PRE_first_tail_x15_r0_body.st70.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext70 : PRE_first_tail_x15_r0_body.s686.next = PRE_first_tail_x15_r0_body.st70.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl70 : PRE_first_tail_x15_r0_body.s686.ctl = PRE_first_tail_x15_r0_body.st70.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack70 : PRE_first_tail_x15_r0_body.s686.stack = PRE_first_tail_x15_r0_body.st70.s2.stack ++ PRE_first_tail_x15_r0_body.s685.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs70 : PRE_first_tail_x15_r0_body.s686.jobs = PRE_first_tail_x15_r0_body.st70.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi70 : PRE_first_tail_x15_r0_body.s686.ffi = PRE_first_tail_x15_r0_body.st70.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace70 : PRE_first_tail_x15_r0_body.s686.trace = PRE_first_tail_x15_r0_body.st70.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores70 : PRE_first_tail_x15_r0_body.s686.stores = PRE_first_tail_x15_r0_body.st70.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD70
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 70 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived70 : PRE_first_tail_x15_r0_body.nr70.map (fun r => nth? PRE_first_tail_x15_r0_body.st70.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo70 : PRE_first_tail_x15_r0_body.nr70.all (Nat.ble 3071) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj70 : PRE_first_tail_x15_r0_body.cws70.all (fun c => !PRE_first_tail_x15_r0_body.ws70.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ70 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws70 PRE_first_tail_x15_r0_body.crs70 PRE_first_tail_x15_r0_body.ws70

end Host.Load.Run.Tpl
end

section -- st70/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st70`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st70.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st70.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st70.s2.heap PRE_first_tail_x15_r0_body.st70.wrR ++ freshOf PRE_first_tail_x15_r0_body.st70.s2.heap PRE_first_tail_x15_r0_body.st70.s0.next PRE_first_tail_x15_r0_body.st70.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st70.wr : List Nat := PRE_first_tail_x15_r0_body.st70.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st70.heapFoot : PRE_first_tail_x15_r0_body.st70.s2.heap = setAll PRE_first_tail_x15_r0_body.st70.s0.heap PRE_first_tail_x15_r0_body.st70.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st70.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st70.s0.next PRE_first_tail_x15_r0_body.st70.s2.next = true
theorem PRE_first_tail_x15_r0_body.st70.grows : PRE_first_tail_x15_r0_body.st70.s0.next ≤ PRE_first_tail_x15_r0_body.st70.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st70.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st70.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st70.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st70.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st70.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st70.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st70.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st70.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st70.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st70.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st70.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st70.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st70.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st70.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st70.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st70.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st70.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st70.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st70.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st70.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st70.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st70.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st70.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st70.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st70.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st70.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st70.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st70.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st70.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st70.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st70.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st70.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF70
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 70 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB70 : nodupT PRE_first_tail_x15_r0_body.st70.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup70 : PRE_first_tail_x15_r0_body.st70.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB70).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB70 : PRE_first_tail_x15_r0_body.st70.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound70 : ∀ b ∈ PRE_first_tail_x15_r0_body.st70.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB70 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr70 := PRE_first_tail_x15_r0_body.st70.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq70 : PRE_first_tail_x15_r0_body.st70.s2.trace = PRE_first_tail_x15_r0_body.trFr70 ++ PRE_first_tail_x15_r0_body.st70.s0.trace
theorem PRE_first_tail_x15_r0_body.trace70 : ∃ fr, PRE_first_tail_x15_r0_body.st70.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st70.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq70⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide70 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB70 : (PRE_first_tail_x15_r0_body.wide70.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st70.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix70 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide70, WFix Map.id (Present PRE_first_tail_x15_r0_body.st70.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB70 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL70
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 70 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s686`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO70 : PRE_first_tail_x15_r0_body.st70.S0.oracle = PRE_first_tail_x15_r0_body.st70.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B70 : PRE_first_tail_x15_r0_body.st70.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st70.s0.next || (PRE_first_tail_x15_r0_body.st70.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot70 : Conv.StageFoot PRE_first_tail_x15_r0_body.st70.wr PRE_first_tail_x15_r0_body.st70.s0 PRE_first_tail_x15_r0_body.st70.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st70.heapFoot PRE_first_tail_x15_r0_body.wrNodup70 PRE_first_tail_x15_r0_body.wrBound70 PRE_first_tail_x15_r0_body.wr0B70 PRE_first_tail_x15_r0_body.st70.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged70 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st70.F.S → PRE_first_tail_x15_r0_body.st70.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st70.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st70.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs70 PRE_first_tail_x15_r0_body.st70.wr PRE_first_tail_x15_r0_body.s685 PRE_first_tail_x15_r0_body.st70.s2 PRE_first_tail_x15_r0_body.st70.s0
      PRE_first_tail_x15_r0_body.st70.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st70.F FR W stk M ν K PRE_first_tail_x15_r0_body.s686 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso70 PRE_first_tail_x15_r0_body.stFoot70 PRE_first_tail_x15_r0_body.wrNodup70 PRE_first_tail_x15_r0_body.wrBound70 PRE_first_tail_x15_r0_body.trace70 PRE_first_tail_x15_r0_body.mheap70
    PRE_first_tail_x15_r0_body.mnext70 PRE_first_tail_x15_r0_body.mctl70 PRE_first_tail_x15_r0_body.mstack70 PRE_first_tail_x15_r0_body.mjobs70 PRE_first_tail_x15_r0_body.mffi70 PRE_first_tail_x15_r0_body.mtrace70 PRE_first_tail_x15_r0_body.mstores70 h

def PRE_first_tail_x15_r0_body.arrEl70_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE70_2665 : arrOf PRE_first_tail_x15_r0_body.s686 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl70_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA70_2665 : isArrB PRE_first_tail_x15_r0_body.s686 2665 = true
theorem PRE_first_tail_x15_r0_body.arr70_2665 : ∃ o, PRE_first_tail_x15_r0_body.s686.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl70_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE70_2665 PRE_first_tail_x15_r0_body.arrA70_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN70_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl70_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR70_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl70_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN70_2665

def PRE_first_tail_x15_r0_body.arrEl70_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE70_2673467 : arrOf PRE_first_tail_x15_r0_body.s686 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl70_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA70_2673467 : isArrB PRE_first_tail_x15_r0_body.s686 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr70_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s686.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl70_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE70_2673467 PRE_first_tail_x15_r0_body.arrA70_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN70_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl70_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR70_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl70_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN70_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k70 : isArrB PRE_first_tail_x15_r0_body.s686 4910 = false
theorem PRE_first_tail_x15_r0_body.keep70 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s686 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k70 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr70_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl70_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ70
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 70 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s685`, the merged
state `PRE_first_tail_x15_r0_body.s686`, the canonical state `PRE_first_tail_x15_r0_body.s687`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl70 : PRE_first_tail_x15_r0_body.pl70.all (Nat.ble PRE_first_tail_x15_r0_body.s685.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd70 : nodupT PRE_first_tail_x15_r0_body.pl70 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn170 : Nat.ble PRE_first_tail_x15_r0_body.s685.next 2730179 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst70 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s685.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn70 : PRE_first_tail_x15_r0_body.s687.next = PRE_first_tail_x15_r0_body.s685.next + PRE_first_tail_x15_r0_body.pl70.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn70 : PRE_first_tail_x15_r0_body.s686.next = 2730179
kernel_rfl PRE_first_tail_x15_r0_body.zgrow70 : Nat.ble PRE_first_tail_x15_r0_body.s687.next PRE_first_tail_x15_r0_body.s686.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh70 : PRE_first_tail_x15_r0_body.S685.tab.all (fun e => PRE_first_tail_x15_r0_body.cws70.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd70 : nodupT PRE_first_tail_x15_r0_body.cws70 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi70 : PRE_first_tail_x15_r0_body.nr70.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S686.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt70 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s685.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg70_2665 : PRE_first_tail_x15_r0_body.s687.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s687 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk70_2665 : (objOf PRE_first_tail_x15_r0_body.s687 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm70_2665 : PRE_first_tail_x15_r0_body.s686.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa70.obj (objOf PRE_first_tail_x15_r0_body.s687 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s686 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg70_2673467 : PRE_first_tail_x15_r0_body.s687.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s687 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk70_2673467 : (objOf PRE_first_tail_x15_r0_body.s687 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm70_2673467 : PRE_first_tail_x15_r0_body.s686.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa70.obj (objOf PRE_first_tail_x15_r0_body.s687 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s686 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw70_4910 : (PRE_first_tail_x15_r0_body.s687.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw70_2673472 : (PRE_first_tail_x15_r0_body.s687.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw70_2673473 : (PRE_first_tail_x15_r0_body.s687.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd70 : PRE_first_tail_x15_r0_body.cl70.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr70 : PRE_first_tail_x15_r0_body.st70.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s685.next || PRE_first_tail_x15_r0_body.cl70.contains b) = true
def PRE_first_tail_x15_r0_body.zl70 : List Nat := PRE_first_tail_x15_r0_body.cl70.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE70 : PRE_first_tail_x15_r0_body.zl70.map (fun a => PRE_first_tail_x15_r0_body.s686.heap.get (PRE_first_tail_x15_r0_body.kappa70.a a)) = PRE_first_tail_x15_r0_body.zl70.map (fun a => (PRE_first_tail_x15_r0_body.s687.heap.get a).map PRE_first_tail_x15_r0_body.kappa70.hobj)
theorem PRE_first_tail_x15_r0_body.zimg70 : HeapImg PRE_first_tail_x15_r0_body.kappa70 PRE_first_tail_x15_r0_body.s687 PRE_first_tail_x15_r0_body.s686 PRE_first_tail_x15_r0_body.zl70 := PRE_first_tail_x15_r0_body.zimgE70
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl70 : PRE_first_tail_x15_r0_body.s686.ctl = PRE_first_tail_x15_r0_body.kappa70.ctl PRE_first_tail_x15_r0_body.s687.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack70 : PRE_first_tail_x15_r0_body.s686.stack = PRE_first_tail_x15_r0_body.s687.stack.map PRE_first_tail_x15_r0_body.kappa70.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs70 : PRE_first_tail_x15_r0_body.s686.jobs = PRE_first_tail_x15_r0_body.s687.jobs.map PRE_first_tail_x15_r0_body.kappa70.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores70 : PRE_first_tail_x15_r0_body.s686.stores = PRE_first_tail_x15_r0_body.kappa70.stores PRE_first_tail_x15_r0_body.s687.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots70 : checkRootsSupp PRE_first_tail_x15_r0_body.s687 3071 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC70 : PRE_first_tail_x15_r0_body.S685.tab.length + PRE_first_tail_x15_r0_body.cws70.length = 3071
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap70 : PRE_first_tail_x15_r0_body.kappa70 = Conv.Map.compact PRE_first_tail_x15_r0_body.s685.next 2730179 PRE_first_tail_x15_r0_body.S685.tab.length PRE_first_tail_x15_r0_body.pl70 (PRE_first_tail_x15_r0_body.nr70.map NumV.ref) PRE_first_tail_x15_r0_body.kd70.big
  PRE_first_tail_x15_r0_body.kd70.region PRE_first_tail_x15_r0_body.kd70.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin70 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s687.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc70 : Conv.jcleanListB (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s687 PRE_first_tail_x15_r0_body.cl70 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB70 : noBigRootsP (fun i => !Conv.oldBigB (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s687.trace PRE_first_tail_x15_r0_body.s687 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm70 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16677 = true
theorem PRE_first_tail_x15_r0_body.cjcl70 (h : Conv.JClean (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s685) : Conv.JClean (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s687 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle70)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap70 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd70 a ha)) PRE_first_tail_x15_r0_body.zjc70

end Host.Load.Run.Tpl
end

section -- st70/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st70.bodyLast from PRE_first_tail_x15_r0_body.st70.s1 to PRE_first_tail_x15_r0_body.st70.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st70.F PRE_first_tail_x15_r0_body.st70.s1).run PRE_first_tail_x15_r0_body.st70.S1 = some (PRE_first_tail_x15_r0_body.st70.s2, PRE_first_tail_x15_r0_body.st70.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st70.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st70.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st70.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st70.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st70/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st70.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st70.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st70.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st70.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st70.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st70.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st70.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st70.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st70.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st70.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st70.s0 PRE_first_tail_x15_r0_body.st70.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st70.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st70.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st70.s1 PRE_first_tail_x15_r0_body.st70.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st70/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st70.bodyK0F from PRE_first_tail_x15_r0_body.st70.s0 to PRE_first_tail_x15_r0_body.st70.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st70.F (PRE_first_tail_x15_r0_body.st70.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st70.ks 0).getD 0) PRE_first_tail_x15_r0_body.st70.s0 PRE_first_tail_x15_r0_body.st70.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st70.s1, PRE_first_tail_x15_r0_body.st70.S1)
theorem PRE_first_tail_x15_r0_body.st70.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st70.F (PRE_first_tail_x15_r0_body.st70.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st70.ks 0).getD 0) PRE_first_tail_x15_r0_body.st70.s0 PRE_first_tail_x15_r0_body.st70.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st70.s1, PRE_first_tail_x15_r0_body.st70.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st70.bodyOkLN_ok PRE_first_tail_x15_r0_body.st70.bodyK0F
end Host.Load.Run.Tpl
end

section -- st70/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st70.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st70.F (PRE_first_tail_x15_r0_body.st70.bodyOkL bytes rows) 27 PRE_first_tail_x15_r0_body.st70.s0 PRE_first_tail_x15_r0_body.st70.S0 = some (PRE_first_tail_x15_r0_body.st70.s1, PRE_first_tail_x15_r0_body.st70.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st70.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st70.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st70.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st70.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st70.F (PRE_first_tail_x15_r0_body.st70.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st70.s0
  S0 := PRE_first_tail_x15_r0_body.st70.S0
  s1 := PRE_first_tail_x15_r0_body.st70.s1
  S1 := PRE_first_tail_x15_r0_body.st70.S1
  s2 := PRE_first_tail_x15_r0_body.st70.s2
  S2 := PRE_first_tail_x15_r0_body.st70.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st70.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st70.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st70.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st70.bodyHalt
  last := PRE_first_tail_x15_r0_body.st70.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st70.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC71
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 71 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s691` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa71` into the merged state
`PRE_first_tail_x15_r0_body.s690`. -/

def PRE_first_tail_x15_r0_body.pl71 : List Nat := [2730475]
def PRE_first_tail_x15_r0_body.nr71 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd71 : RData :=
  ⟨2730466, 2730476, Stage.setAll PTrie.nil [(2730465, 2730475)], Stage.setAll PTrie.nil [],
   19597, 19597, 16681, 16681, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa71 : Map :=
  Conv.Map.compact 2730465 2730476 3088 PRE_first_tail_x15_r0_body.pl71 (PRE_first_tail_x15_r0_body.nr71.map NumV.ref) PRE_first_tail_x15_r0_body.kd71.big
    PRE_first_tail_x15_r0_body.kd71.region PRE_first_tail_x15_r0_body.kd71.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws71 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs71 : List SymE := PRE_first_tail_x15_r0_body.nr71.map fun r => (nth? PRE_first_tail_x15_r0_body.S690.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta71 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws71 PRE_first_tail_x15_r0_body.crs71
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB71 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab71 : PRE_first_tail_x15_r0_body.S691.tab = PRE_first_tail_x15_r0_body.S689.tab ++ PRE_first_tail_x15_r0_body.cws71.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace71 : PRE_first_tail_x15_r0_body.s691.trace = PRE_first_tail_x15_r0_body.s689.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext71 : PRE_first_tail_x15_r0_body.s691.next = 2730466
kernel_rfl PRE_first_tail_x15_r0_body.ccounters71 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx.nnext) = (19597, 16681)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue71 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s690.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa71.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp71 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx.tokens.all (bSN 3088) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean71 : Conv.cleanListB 19597 131072 (fun r => Nat.ble 78388 r) PRE_first_tail_x15_r0_body.s691
    (PRE_first_tail_x15_r0_body.wrB71 ++ (List.range 1).map (2730465 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs71 : bigsOutB 19597 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK71
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl71`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl71 : List Nat := [2665, 2673467, 2730465]
def PRE_first_tail_x15_r0_body.clo71 : List Nat := []
def PRE_first_tail_x15_r0_body.cln71 : List Nat := []
def PRE_first_tail_x15_r0_body.cli71 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap71 : PRE_first_tail_x15_r0_body.s691.heap = Stage.setAll PRE_first_tail_x15_r0_body.s689.heap (PRE_first_tail_x15_r0_body.cl71.filterMap fun a => (PRE_first_tail_x15_r0_body.s691.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe71 : Nat.ble PRE_first_tail_x15_r0_body.s689.next PRE_first_tail_x15_r0_body.s691.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP71 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s689 PRE_first_tail_x15_r0_body.s691 PRE_first_tail_x15_r0_body.cl71 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp71 : Conv.suppListB PRE_first_tail_x15_r0_body.s691 3088 PRE_first_tail_x15_r0_body.cl71 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound71 : Conv.boundListB PRE_first_tail_x15_r0_body.s691 PRE_first_tail_x15_r0_body.cl71 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK71 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln71.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK71 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo71.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK71 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli71.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst71 : Conv.sstListB 3088 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx PRE_first_tail_x15_r0_body.cln71 PRE_first_tail_x15_r0_body.clo71 PRE_first_tail_x15_r0_body.cli71 = true

end Host.Load.Run.Tpl
end

section -- SiteCl71
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA71 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo71.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd71 : (PRE_first_tail_x15_r0_body.clo71 ++ PRE_first_tail_x15_r0_body.cln71 ++ PRE_first_tail_x15_r0_body.cli71).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle71 : Conv.Cnt.leB (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt) (⟨19597, 16681, 2730466, 3088⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck71 : Conv.ncleanListB (⟨19597, 16681, 2730466, 3088⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx PRE_first_tail_x15_r0_body.clo71 PRE_first_tail_x15_r0_body.cln71 PRE_first_tail_x15_r0_body.cli71 = true
theorem PRE_first_tail_x15_r0_body.cncl71 (h : Conv.NClean (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx) : Conv.NClean (⟨19597, 16681, 2730466, 3088⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle71 PRE_first_tail_x15_r0_body.ckA71 PRE_first_tail_x15_r0_body.cobjsK71 PRE_first_tail_x15_r0_body.cnodesK71 PRE_first_tail_x15_r0_body.citemsK71 PRE_first_tail_x15_r0_body.cbd71 PRE_first_tail_x15_r0_body.cck71

end Host.Load.Run.Tpl
end

section -- SiteS71
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 71 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc71 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P71 : LoadP := PRE_first_tail_x15_r0_body.Pc71.raise 16681
kernel_rfl PRE_first_tail_x15_r0_body.craise71 : Nat.ble PRE_first_tail_x15_r0_body.Pc71.N0 16681 = true
theorem PRE_first_tail_x15_r0_body.raised71 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc71 PRE_first_tail_x15_r0_body.P71 :=
  .inr ⟨16681, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise71, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_71 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_71 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s690.ffi)
def PRE_first_tail_x15_r0_body.khinv71 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv71 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS71 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS71 : List Nat := List.range' 16681 0
def PRE_first_tail_x15_r0_body.ciS71 : List Nat := [] ++ List.range' 16681 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh071 : PRE_first_tail_x15_r0_body.kd71.nh0 = PRE_first_tail_x15_r0_body.cx0_71.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh171 : PRE_first_tail_x15_r0_body.kd71.nh1 = PRE_first_tail_x15_r0_body.cx1_71.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn071 : PRE_first_tail_x15_r0_body.kd71.nn0 = PRE_first_tail_x15_r0_body.cx0_71.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn171 : PRE_first_tail_x15_r0_body.kd71.nn1 = PRE_first_tail_x15_r0_body.cx1_71.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo71 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P71.lo && Nat.ble PRE_first_tail_x15_r0_body.P71.lo PRE_first_tail_x15_r0_body.cx0_71.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P71.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P71.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt71 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_71.mlx.next PRE_first_tail_x15_r0_body.cx1_71.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_71.mlx.nnext PRE_first_tail_x15_r0_body.cx1_71.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband71 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P71.NL && Nat.ble PRE_first_tail_x15_r0_body.P71.NL PRE_first_tail_x15_r0_body.P71.N0 && Nat.ble PRE_first_tail_x15_r0_body.P71.N0 PRE_first_tail_x15_r0_body.cx0_71.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow71 : PRE_first_tail_x15_r0_body.kd71.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren71 : checkRenG PRE_first_tail_x15_r0_body.kd71.hnd PRE_first_tail_x15_r0_body.khinv71 (phB PRE_first_tail_x15_r0_body.cx0_71.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband71 : PRE_first_tail_x15_r0_body.kd71.checkBand PRE_first_tail_x15_r0_body.P71.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos71 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd71.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren71 : checkRenG PRE_first_tail_x15_r0_body.kd71.node PRE_first_tail_x15_r0_body.kninv71 (pnB PRE_first_tail_x15_r0_body.cx0_71.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow71 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd71.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P71.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd71.nodeF j) PRE_first_tail_x15_r0_body.cx1_71.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a71 : PRE_first_tail_x15_r0_body.cx0_71.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b71 : PRE_first_tail_x15_r0_body.cx0_71.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok171 : PRE_first_tail_x15_r0_body.cx1_71.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend71 : PRE_first_tail_x15_r0_body.cx1_71.mlx.pending = PRE_first_tail_x15_r0_body.cx0_71.mlx.pending.map PRE_first_tail_x15_r0_body.kappa71.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh71 : PRE_first_tail_x15_r0_body.cx1_71.mlx.errh = PRE_first_tail_x15_r0_body.cx0_71.mlx.errh.map PRE_first_tail_x15_r0_body.kappa71.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles71 : PRE_first_tail_x15_r0_body.cx1_71.mlx.files = PRE_first_tail_x15_r0_body.cx0_71.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch71 : PRE_first_tail_x15_r0_body.cx1_71.mlx.arch = PRE_first_tail_x15_r0_body.cx0_71.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes71 : PRE_first_tail_x15_r0_body.cx1_71.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_71.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired71 : PRE_first_tail_x15_r0_body.cx1_71.mlx.wired = PRE_first_tail_x15_r0_body.cx0_71.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost71 : PRE_first_tail_x15_r0_body.cx1_71.host = PRE_first_tail_x15_r0_body.cx0_71.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd71`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn071 : PRE_first_tail_x15_r0_body.kd71.n0 = 2730466
kernel_rfl PRE_first_tail_x15_r0_body.ckn171 : PRE_first_tail_x15_r0_body.kd71.n1 = 2730476
kernel_rfl PRE_first_tail_x15_r0_body.ckheap71 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd71.heap).all (fun x => Nat.ble 2730465 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl71 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd71.heap.get (2730465 + j) = nth? PRE_first_tail_x15_r0_body.pl71 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja71 : Nat.ble 2730465 2730465 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn71 : Nat.ble 3088 3088 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD71 : Nat.ble 2730465 PRE_first_tail_x15_r0_body.kd71.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn71 : Nat.ble 19597 PRE_first_tail_x15_r0_body.kd71.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn71 : Nat.ble 16681 PRE_first_tail_x15_r0_body.kd71.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb71 : Nat.ble 19597 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap71 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd71.heap).all (Nat.ble (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd71 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd71.hnd).all (Nat.ble (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode71 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd71.node).all (Nat.ble (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix71 : Conv.FixOld (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa71 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja71) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn71) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD71) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn71) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn71) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb71) PRE_first_tail_x15_r0_body.fheap71 PRE_first_tail_x15_r0_body.fhnd71 PRE_first_tail_x15_r0_body.fnode71
kernel_rfl PRE_first_tail_x15_r0_body.fcxn71 : (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn71 : (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle071 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_71.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_71.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk71 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd71.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A71 : PRE_first_tail_x15_r0_body.cx1_71.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS71.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_71.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O71 : PRE_first_tail_x15_r0_body.cx1_71.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS71.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_71.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N71 : PRE_first_tail_x15_r0_body.cx1_71.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS71.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_71.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I71 : PRE_first_tail_x15_r0_body.cx1_71.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS71.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_71.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd71 : (PRE_first_tail_x15_r0_body.clo71 ++ PRE_first_tail_x15_r0_body.cln71 ++ PRE_first_tail_x15_r0_body.cli71 ++ PRE_first_tail_x15_r0_body.cwS71 ++ PRE_first_tail_x15_r0_body.cnS71 ++ PRE_first_tail_x15_r0_body.ciS71).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW71 : PRE_first_tail_x15_r0_body.cwS71.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo71.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI71 : PRE_first_tail_x15_r0_body.ciS71.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli71.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN71 : PRE_first_tail_x15_r0_body.cnS71.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF71 : PRE_first_tail_x15_r0_body.cln71.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh71 : PRE_first_tail_x15_r0_body.clo71.all (handleOK PRE_first_tail_x15_r0_body.kappa71 PRE_first_tail_x15_r0_body.P71.lo PRE_first_tail_x15_r0_body.cx0_71.mlx PRE_first_tail_x15_r0_body.cx1_71.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo71 : PRE_first_tail_x15_r0_body.clo71.map (fun h => PRE_first_tail_x15_r0_body.cx1_71.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa71.handle h)) = PRE_first_tail_x15_r0_body.clo71.map (fun h => (PRE_first_tail_x15_r0_body.cx0_71.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa71.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok71 : PRE_first_tail_x15_r0_body.clo71.all (objOK PRE_first_tail_x15_r0_body.kappa71 PRE_first_tail_x15_r0_body.P71.NL PRE_first_tail_x15_r0_body.cx0_71.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd71 : PRE_first_tail_x15_r0_body.cln71.all (nodeOKF PRE_first_tail_x15_r0_body.kappa71 PRE_first_tail_x15_r0_body.P71 PRE_first_tail_x15_r0_body.cx0_71.mlx PRE_first_tail_x15_r0_body.cx1_71.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp71 : ((PRE_first_tail_x15_r0_body.cln71.filter (fullB PRE_first_tail_x15_r0_body.P71))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_71.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa71.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln71.filter (fullB PRE_first_tail_x15_r0_body.P71))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_71.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa71.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI71 : incrB PRE_first_tail_x15_r0_body.kd71.nodeF (List.range' 16681 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK71 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd71.node).all (fun k => Nat.ble 16681 k && Nat.blt k 16681) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL71 : (PRE_first_tail_x15_r0_body.cln71.filter (Nat.ble PRE_first_tail_x15_r0_body.P71.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd71.nodeF i) && (Nat.blt i 16681 || Nat.ble PRE_first_tail_x15_r0_body.kd71.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord71 : (PRE_first_tail_x15_r0_body.cln71.filter (Nat.ble PRE_first_tail_x15_r0_body.P71.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd71.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd71.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd71.nodeF j) (PRE_first_tail_x15_r0_body.kd71.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow71 PRE_first_tail_x15_r0_body.cnn171 PRE_first_tail_x15_r0_body.fnordI71 PRE_first_tail_x15_r0_body.fnordK71 PRE_first_tail_x15_r0_body.fnordL71
kernel_rfl PRE_first_tail_x15_r0_body.fi71 : PRE_first_tail_x15_r0_body.cli71.all (pnB PRE_first_tail_x15_r0_body.cx0_71.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii71 : PRE_first_tail_x15_r0_body.cli71.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_71.mlx.items.get (PRE_first_tail_x15_r0_body.kappa71.node k) = (PRE_first_tail_x15_r0_body.cx0_71.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa71.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot71 (clean : Conv.NClean (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P71.NL) (cl : SSt (· < 3088) PRE_first_tail_x15_r0_body.cx0_71.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P71 3088 PRE_first_tail_x15_r0_body.kappa71 PRE_first_tail_x15_r0_body.kd71 PRE_first_tail_x15_r0_body.khinv71 PRE_first_tail_x15_r0_body.kninv71 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx PRE_first_tail_x15_r0_body.cx0_71.mlx PRE_first_tail_x15_r0_body.cx1_71.mlx (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo71 PRE_first_tail_x15_r0_body.cln71 PRE_first_tail_x15_r0_body.cli71 PRE_first_tail_x15_r0_body.cwS71 PRE_first_tail_x15_r0_body.cnS71 PRE_first_tail_x15_r0_body.ciS71 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh071, PRE_first_tail_x15_r0_body.cnh171, PRE_first_tail_x15_r0_body.cnn071, PRE_first_tail_x15_r0_body.cnn171, PRE_first_tail_x15_r0_body.cplo71, PRE_first_tail_x15_r0_body.ccnt71, PRE_first_tail_x15_r0_body.cnband71, PRE_first_tail_x15_r0_body.chbelow71, PRE_first_tail_x15_r0_body.chren71, PRE_first_tail_x15_r0_body.cband71, PRE_first_tail_x15_r0_body.cnh1pos71, PRE_first_tail_x15_r0_body.cnren71, PRE_first_tail_x15_r0_body.cnlow71, PRE_first_tail_x15_r0_body.cabs0a71, PRE_first_tail_x15_r0_body.cabs0b71, PRE_first_tail_x15_r0_body.ctok171, PRE_first_tail_x15_r0_body.cpend71, PRE_first_tail_x15_r0_body.cerrh71, PRE_first_tail_x15_r0_body.cfiles71, PRE_first_tail_x15_r0_body.carch71, PRE_first_tail_x15_r0_body.csizes71, PRE_first_tail_x15_r0_body.cwired71, PRE_first_tail_x15_r0_body.cfix71, clean, PRE_first_tail_x15_r0_body.fcxn71, PRE_first_tail_x15_r0_body.fcnn71, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle071, PRE_first_tail_x15_r0_body.fnk71, PRE_first_tail_x15_r0_body.ckA71, PRE_first_tail_x15_r0_body.cobjsK71, PRE_first_tail_x15_r0_body.cnodesK71, PRE_first_tail_x15_r0_body.citemsK71, PRE_first_tail_x15_r0_body.f1A71, PRE_first_tail_x15_r0_body.f1O71, PRE_first_tail_x15_r0_body.f1N71, PRE_first_tail_x15_r0_body.f1I71, PRE_first_tail_x15_r0_body.fbd71, PRE_first_tail_x15_r0_body.fincW71, PRE_first_tail_x15_r0_body.fincI71, PRE_first_tail_x15_r0_body.fincN71, PRE_first_tail_x15_r0_body.flnF71, PRE_first_tail_x15_r0_body.fh71, PRE_first_tail_x15_r0_body.fo71, PRE_first_tail_x15_r0_body.fok71, PRE_first_tail_x15_r0_body.fnd71, PRE_first_tail_x15_r0_body.fp71, PRE_first_tail_x15_r0_body.fnord71, PRE_first_tail_x15_r0_body.fi71, PRE_first_tail_x15_r0_body.fii71⟩
theorem PRE_first_tail_x15_r0_body.cnshift71 (clean : Conv.NClean (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P71.NL) (cl : SSt (· < 3088) PRE_first_tail_x15_r0_body.cx0_71.mlx) : NShift PRE_first_tail_x15_r0_body.P71 3088 PRE_first_tail_x15_r0_body.kappa71 PRE_first_tail_x15_r0_body.cx0_71 PRE_first_tail_x15_r0_body.cx1_71 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot71 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost71 (compact_a_eq PRE_first_tail_x15_r0_body.ckn071 PRE_first_tail_x15_r0_body.ckn171 PRE_first_tail_x15_r0_body.ckheap71 PRE_first_tail_x15_r0_body.ckpl71)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_71 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s689.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_71 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s689.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_71 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s689.ffi) = some PRE_first_tail_x15_r0_body.fxC_71
kernel_rfl PRE_first_tail_x15_r0_body.okrC_71 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s689.ffi) = some PRE_first_tail_x15_r0_body.krC_71
noncomputable def PRE_first_tail_x15_r0_body.fx0_71 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s691.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_71 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s691.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_71 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s691.ffi) = some PRE_first_tail_x15_r0_body.fx0_71
kernel_rfl PRE_first_tail_x15_r0_body.okr0_71 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s691.ffi) = some PRE_first_tail_x15_r0_body.kr0_71
noncomputable def PRE_first_tail_x15_r0_body.fx1_71 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s690.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_71 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s690.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_71 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s690.ffi) = some PRE_first_tail_x15_r0_body.fx1_71
kernel_rfl PRE_first_tail_x15_r0_body.okr1_71 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s690.ffi) = some PRE_first_tail_x15_r0_body.kr1_71
kernel_rfl PRE_first_tail_x15_r0_body.ff071 : PRE_first_tail_x15_r0_body.fx0_71 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_71 (PRE_first_tail_x15_r0_body.clo71.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_71.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff171 : PRE_first_tail_x15_r0_body.fx1_71 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_71 (PRE_first_tail_x15_r0_body.cwS71.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_71.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck71 : freedLB PRE_first_tail_x15_r0_body.kappa71 PRE_first_tail_x15_r0_body.cx0_71.mlx PRE_first_tail_x15_r0_body.fx0_71 PRE_first_tail_x15_r0_body.fx1_71 PRE_first_tail_x15_r0_body.clo71 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf071 : PRE_first_tail_x15_r0_body.kr0_71.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_71.flags (PRE_first_tail_x15_r0_body.clo71.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_71.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt071 : PRE_first_tail_x15_r0_body.kr0_71.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_71.targs (PRE_first_tail_x15_r0_body.clo71.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_71.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf171 : PRE_first_tail_x15_r0_body.kr1_71.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_71.flags (PRE_first_tail_x15_r0_body.cwS71.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_71.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt171 : PRE_first_tail_x15_r0_body.kr1_71.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_71.targs (PRE_first_tail_x15_r0_body.cwS71.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_71.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck71 : krecLB PRE_first_tail_x15_r0_body.kappa71 3088 PRE_first_tail_x15_r0_body.cx0_71.mlx PRE_first_tail_x15_r0_body.kr0_71 PRE_first_tail_x15_r0_body.kr1_71 PRE_first_tail_x15_r0_body.clo71 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn71 : Nat.ble 3088 3088 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge71 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s690.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s691.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR71 : pendRegB PRE_first_tail_x15_r0_body.kappa71 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe71 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s690.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift71 (clean : Conv.NClean (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P71.NL) (cl : SSt (· < 3088) PRE_first_tail_x15_r0_body.cx0_71.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_71.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_71.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_71.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_71.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P71 3088 PRE_first_tail_x15_r0_body.kappa71 PRE_first_tail_x15_r0_body.s691.ffi PRE_first_tail_x15_r0_body.s690.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift71 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue71, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp71 t ht),
    PRE_first_tail_x15_r0_body.cbridge71,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s691.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s690.ffi) (PRE_first_tail_x15_r0_body.cfoot71 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_71 PRE_first_tail_x15_r0_body.ofx1_71 hobjC PRE_first_tail_x15_r0_body.ff071 PRE_first_tail_x15_r0_body.ff171 PRE_first_tail_x15_r0_body.ffck71,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s691.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s690.ffi) (PRE_first_tail_x15_r0_body.cfoot71 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_71 PRE_first_tail_x15_r0_body.okr1_71 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn71) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf071 PRE_first_tail_x15_r0_body.fkt071 PRE_first_tail_x15_r0_body.fkf171 PRE_first_tail_x15_r0_body.fkt171 PRE_first_tail_x15_r0_body.fkck71,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh071 PRE_first_tail_x15_r0_body.cnh171 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe71) PRE_first_tail_x15_r0_body.cpendR71⟩

end Host.Load.Run.Tpl
end

section -- st71/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st71 0
host_stream_state PRE_first_tail_x15_r0_body.st71 1
host_stream_state PRE_first_tail_x15_r0_body.st71 2
end Host.Load.Run.Tpl
end

section -- Site71
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 71 of chain `PRE_first_tail_x15_r0_body`: `plan__g71__g72` (`plan`), the call state `PRE_first_tail_x15_r0_body.s689`, the merged state `PRE_first_tail_x15_r0_body.s690`,
the site template `PRE_first_tail_x15_r0_body.st71` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s691`: the merge.
The footprint's facts are in `SiteF71`, the compaction's in `SiteC71`, `SiteK71`, `SiteNa71`, `SiteNb71`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso71 : PRE_first_tail_x15_r0_body.st71.s0 = { PRE_first_tail_x15_r0_body.s689 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs71 : List Frame := PRE_first_tail_x15_r0_body.s689.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_71 : PRE_first_tail_x15_r0_body.S689.tab.length = 3088
kernel_rfl PRE_first_tail_x15_r0_body.tab0_71 : PRE_first_tail_x15_r0_body.st71.S0.tab = PRE_first_tail_x15_r0_body.S689.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws71 : List Nat := [2197, 2198, 2199]
kernel_rfl PRE_first_tail_x15_r0_body.fresh71 : (PRE_first_tail_x15_r0_body.S689.tab.all fun e => PRE_first_tail_x15_r0_body.ws71.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S689.oracle.all fun q => PRE_first_tail_x15_r0_body.ws71.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab71 : PRE_first_tail_x15_r0_body.S690.tab = PRE_first_tail_x15_r0_body.S689.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws71
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen71 : PRE_first_tail_x15_r0_body.st71.S2.tab.length - PRE_first_tail_x15_r0_body.st71.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged71`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap71 : PRE_first_tail_x15_r0_body.s690.heap = PRE_first_tail_x15_r0_body.st71.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext71 : PRE_first_tail_x15_r0_body.s690.next = PRE_first_tail_x15_r0_body.st71.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl71 : PRE_first_tail_x15_r0_body.s690.ctl = PRE_first_tail_x15_r0_body.st71.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack71 : PRE_first_tail_x15_r0_body.s690.stack = PRE_first_tail_x15_r0_body.st71.s2.stack ++ PRE_first_tail_x15_r0_body.s689.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs71 : PRE_first_tail_x15_r0_body.s690.jobs = PRE_first_tail_x15_r0_body.st71.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi71 : PRE_first_tail_x15_r0_body.s690.ffi = PRE_first_tail_x15_r0_body.st71.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace71 : PRE_first_tail_x15_r0_body.s690.trace = PRE_first_tail_x15_r0_body.st71.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores71 : PRE_first_tail_x15_r0_body.s690.stores = PRE_first_tail_x15_r0_body.st71.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD71
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 71 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived71 : PRE_first_tail_x15_r0_body.nr71.map (fun r => nth? PRE_first_tail_x15_r0_body.st71.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo71 : PRE_first_tail_x15_r0_body.nr71.all (Nat.ble 3088) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj71 : PRE_first_tail_x15_r0_body.cws71.all (fun c => !PRE_first_tail_x15_r0_body.ws71.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ71 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws71 PRE_first_tail_x15_r0_body.crs71 PRE_first_tail_x15_r0_body.ws71

end Host.Load.Run.Tpl
end

section -- st71/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st71`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st71.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st71.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st71.s2.heap PRE_first_tail_x15_r0_body.st71.wrR ++ freshOf PRE_first_tail_x15_r0_body.st71.s2.heap PRE_first_tail_x15_r0_body.st71.s0.next PRE_first_tail_x15_r0_body.st71.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st71.wr : List Nat := PRE_first_tail_x15_r0_body.st71.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st71.heapFoot : PRE_first_tail_x15_r0_body.st71.s2.heap = setAll PRE_first_tail_x15_r0_body.st71.s0.heap PRE_first_tail_x15_r0_body.st71.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st71.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st71.s0.next PRE_first_tail_x15_r0_body.st71.s2.next = true
theorem PRE_first_tail_x15_r0_body.st71.grows : PRE_first_tail_x15_r0_body.st71.s0.next ≤ PRE_first_tail_x15_r0_body.st71.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st71.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st71.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st71.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st71.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st71.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st71.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st71.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st71.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st71.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st71.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st71.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st71.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st71.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st71.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st71.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st71.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st71.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st71.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st71.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st71.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st71.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st71.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st71.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st71.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st71.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st71.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st71.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st71.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st71.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st71.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st71.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st71.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF71
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 71 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB71 : nodupT PRE_first_tail_x15_r0_body.st71.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup71 : PRE_first_tail_x15_r0_body.st71.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB71).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB71 : PRE_first_tail_x15_r0_body.st71.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound71 : ∀ b ∈ PRE_first_tail_x15_r0_body.st71.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB71 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr71 := PRE_first_tail_x15_r0_body.st71.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq71 : PRE_first_tail_x15_r0_body.st71.s2.trace = PRE_first_tail_x15_r0_body.trFr71 ++ PRE_first_tail_x15_r0_body.st71.s0.trace
theorem PRE_first_tail_x15_r0_body.trace71 : ∃ fr, PRE_first_tail_x15_r0_body.st71.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st71.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq71⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide71 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB71 : (PRE_first_tail_x15_r0_body.wide71.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st71.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix71 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide71, WFix Map.id (Present PRE_first_tail_x15_r0_body.st71.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB71 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL71
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 71 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s690`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO71 : PRE_first_tail_x15_r0_body.st71.S0.oracle = PRE_first_tail_x15_r0_body.st71.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B71 : PRE_first_tail_x15_r0_body.st71.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st71.s0.next || (PRE_first_tail_x15_r0_body.st71.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot71 : Conv.StageFoot PRE_first_tail_x15_r0_body.st71.wr PRE_first_tail_x15_r0_body.st71.s0 PRE_first_tail_x15_r0_body.st71.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st71.heapFoot PRE_first_tail_x15_r0_body.wrNodup71 PRE_first_tail_x15_r0_body.wrBound71 PRE_first_tail_x15_r0_body.wr0B71 PRE_first_tail_x15_r0_body.st71.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged71 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st71.F.S → PRE_first_tail_x15_r0_body.st71.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st71.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st71.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs71 PRE_first_tail_x15_r0_body.st71.wr PRE_first_tail_x15_r0_body.s689 PRE_first_tail_x15_r0_body.st71.s2 PRE_first_tail_x15_r0_body.st71.s0
      PRE_first_tail_x15_r0_body.st71.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st71.F FR W stk M ν K PRE_first_tail_x15_r0_body.s690 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso71 PRE_first_tail_x15_r0_body.stFoot71 PRE_first_tail_x15_r0_body.wrNodup71 PRE_first_tail_x15_r0_body.wrBound71 PRE_first_tail_x15_r0_body.trace71 PRE_first_tail_x15_r0_body.mheap71
    PRE_first_tail_x15_r0_body.mnext71 PRE_first_tail_x15_r0_body.mctl71 PRE_first_tail_x15_r0_body.mstack71 PRE_first_tail_x15_r0_body.mjobs71 PRE_first_tail_x15_r0_body.mffi71 PRE_first_tail_x15_r0_body.mtrace71 PRE_first_tail_x15_r0_body.mstores71 h

def PRE_first_tail_x15_r0_body.arrEl71_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE71_2665 : arrOf PRE_first_tail_x15_r0_body.s690 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl71_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA71_2665 : isArrB PRE_first_tail_x15_r0_body.s690 2665 = true
theorem PRE_first_tail_x15_r0_body.arr71_2665 : ∃ o, PRE_first_tail_x15_r0_body.s690.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl71_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE71_2665 PRE_first_tail_x15_r0_body.arrA71_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN71_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl71_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR71_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl71_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN71_2665

def PRE_first_tail_x15_r0_body.arrEl71_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE71_2673467 : arrOf PRE_first_tail_x15_r0_body.s690 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl71_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA71_2673467 : isArrB PRE_first_tail_x15_r0_body.s690 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr71_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s690.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl71_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE71_2673467 PRE_first_tail_x15_r0_body.arrA71_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN71_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl71_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR71_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl71_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN71_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k71 : isArrB PRE_first_tail_x15_r0_body.s690 4910 = false
theorem PRE_first_tail_x15_r0_body.keep71 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s690 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k71 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr71_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl71_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ71
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 71 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s689`, the merged
state `PRE_first_tail_x15_r0_body.s690`, the canonical state `PRE_first_tail_x15_r0_body.s691`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl71 : PRE_first_tail_x15_r0_body.pl71.all (Nat.ble PRE_first_tail_x15_r0_body.s689.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd71 : nodupT PRE_first_tail_x15_r0_body.pl71 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn171 : Nat.ble PRE_first_tail_x15_r0_body.s689.next 2730476 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst71 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s689.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn71 : PRE_first_tail_x15_r0_body.s691.next = PRE_first_tail_x15_r0_body.s689.next + PRE_first_tail_x15_r0_body.pl71.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn71 : PRE_first_tail_x15_r0_body.s690.next = 2730476
kernel_rfl PRE_first_tail_x15_r0_body.zgrow71 : Nat.ble PRE_first_tail_x15_r0_body.s691.next PRE_first_tail_x15_r0_body.s690.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh71 : PRE_first_tail_x15_r0_body.S689.tab.all (fun e => PRE_first_tail_x15_r0_body.cws71.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd71 : nodupT PRE_first_tail_x15_r0_body.cws71 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi71 : PRE_first_tail_x15_r0_body.nr71.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S690.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt71 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s689.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg71_2665 : PRE_first_tail_x15_r0_body.s691.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s691 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk71_2665 : (objOf PRE_first_tail_x15_r0_body.s691 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm71_2665 : PRE_first_tail_x15_r0_body.s690.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa71.obj (objOf PRE_first_tail_x15_r0_body.s691 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s690 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg71_2673467 : PRE_first_tail_x15_r0_body.s691.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s691 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk71_2673467 : (objOf PRE_first_tail_x15_r0_body.s691 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm71_2673467 : PRE_first_tail_x15_r0_body.s690.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa71.obj (objOf PRE_first_tail_x15_r0_body.s691 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s690 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw71_4910 : (PRE_first_tail_x15_r0_body.s691.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw71_2673472 : (PRE_first_tail_x15_r0_body.s691.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw71_2673473 : (PRE_first_tail_x15_r0_body.s691.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd71 : PRE_first_tail_x15_r0_body.cl71.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr71 : PRE_first_tail_x15_r0_body.st71.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s689.next || PRE_first_tail_x15_r0_body.cl71.contains b) = true
def PRE_first_tail_x15_r0_body.zl71 : List Nat := PRE_first_tail_x15_r0_body.cl71.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE71 : PRE_first_tail_x15_r0_body.zl71.map (fun a => PRE_first_tail_x15_r0_body.s690.heap.get (PRE_first_tail_x15_r0_body.kappa71.a a)) = PRE_first_tail_x15_r0_body.zl71.map (fun a => (PRE_first_tail_x15_r0_body.s691.heap.get a).map PRE_first_tail_x15_r0_body.kappa71.hobj)
theorem PRE_first_tail_x15_r0_body.zimg71 : HeapImg PRE_first_tail_x15_r0_body.kappa71 PRE_first_tail_x15_r0_body.s691 PRE_first_tail_x15_r0_body.s690 PRE_first_tail_x15_r0_body.zl71 := PRE_first_tail_x15_r0_body.zimgE71
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl71 : PRE_first_tail_x15_r0_body.s690.ctl = PRE_first_tail_x15_r0_body.kappa71.ctl PRE_first_tail_x15_r0_body.s691.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack71 : PRE_first_tail_x15_r0_body.s690.stack = PRE_first_tail_x15_r0_body.s691.stack.map PRE_first_tail_x15_r0_body.kappa71.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs71 : PRE_first_tail_x15_r0_body.s690.jobs = PRE_first_tail_x15_r0_body.s691.jobs.map PRE_first_tail_x15_r0_body.kappa71.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores71 : PRE_first_tail_x15_r0_body.s690.stores = PRE_first_tail_x15_r0_body.kappa71.stores PRE_first_tail_x15_r0_body.s691.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots71 : checkRootsSupp PRE_first_tail_x15_r0_body.s691 3088 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC71 : PRE_first_tail_x15_r0_body.S689.tab.length + PRE_first_tail_x15_r0_body.cws71.length = 3088
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap71 : PRE_first_tail_x15_r0_body.kappa71 = Conv.Map.compact PRE_first_tail_x15_r0_body.s689.next 2730476 PRE_first_tail_x15_r0_body.S689.tab.length PRE_first_tail_x15_r0_body.pl71 (PRE_first_tail_x15_r0_body.nr71.map NumV.ref) PRE_first_tail_x15_r0_body.kd71.big
  PRE_first_tail_x15_r0_body.kd71.region PRE_first_tail_x15_r0_body.kd71.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin71 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s691.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc71 : Conv.jcleanListB (⟨19597, 16681, 2730466, 3088⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s691 PRE_first_tail_x15_r0_body.cl71 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB71 : noBigRootsP (fun i => !Conv.oldBigB (⟨19597, 16681, 2730466, 3088⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s691.trace PRE_first_tail_x15_r0_body.s691 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm71 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16681 = true
theorem PRE_first_tail_x15_r0_body.cjcl71 (h : Conv.JClean (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s689) : Conv.JClean (⟨19597, 16681, 2730466, 3088⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s691 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle71)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap71 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd71 a ha)) PRE_first_tail_x15_r0_body.zjc71

end Host.Load.Run.Tpl
end

section -- st71/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st71.bodyLast from PRE_first_tail_x15_r0_body.st71.s1 to PRE_first_tail_x15_r0_body.st71.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st71.F PRE_first_tail_x15_r0_body.st71.s1).run PRE_first_tail_x15_r0_body.st71.S1 = some (PRE_first_tail_x15_r0_body.st71.s2, PRE_first_tail_x15_r0_body.st71.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st71.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st71.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st71.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st71.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st71/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st71.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st71.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st71.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st71.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st71.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st71.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st71.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st71.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st71.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st71.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st71.s0 PRE_first_tail_x15_r0_body.st71.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st71.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st71.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st71.s1 PRE_first_tail_x15_r0_body.st71.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st71/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st71.bodyK0F from PRE_first_tail_x15_r0_body.st71.s0 to PRE_first_tail_x15_r0_body.st71.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st71.F (PRE_first_tail_x15_r0_body.st71.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st71.ks 0).getD 0) PRE_first_tail_x15_r0_body.st71.s0 PRE_first_tail_x15_r0_body.st71.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st71.s1, PRE_first_tail_x15_r0_body.st71.S1)
theorem PRE_first_tail_x15_r0_body.st71.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st71.F (PRE_first_tail_x15_r0_body.st71.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st71.ks 0).getD 0) PRE_first_tail_x15_r0_body.st71.s0 PRE_first_tail_x15_r0_body.st71.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st71.s1, PRE_first_tail_x15_r0_body.st71.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st71.bodyOkLN_ok PRE_first_tail_x15_r0_body.st71.bodyK0F
end Host.Load.Run.Tpl
end

section -- st71/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st71.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st71.F (PRE_first_tail_x15_r0_body.st71.bodyOkL bytes rows) 98 PRE_first_tail_x15_r0_body.st71.s0 PRE_first_tail_x15_r0_body.st71.S0 = some (PRE_first_tail_x15_r0_body.st71.s1, PRE_first_tail_x15_r0_body.st71.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st71.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st71.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st71.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st71.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st71.F (PRE_first_tail_x15_r0_body.st71.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st71.s0
  S0 := PRE_first_tail_x15_r0_body.st71.S0
  s1 := PRE_first_tail_x15_r0_body.st71.s1
  S1 := PRE_first_tail_x15_r0_body.st71.S1
  s2 := PRE_first_tail_x15_r0_body.st71.s2
  S2 := PRE_first_tail_x15_r0_body.st71.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st71.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st71.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st71.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st71.bodyHalt
  last := PRE_first_tail_x15_r0_body.st71.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st71.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC72
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 72 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s708` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa72` into the merged state
`PRE_first_tail_x15_r0_body.s707`. -/

def PRE_first_tail_x15_r0_body.pl72 : List Nat := [2733071, 2732246, 2733077, 2733073, 2732248, 2733079]
def PRE_first_tail_x15_r0_body.nr72 : List Nat := [3191, 3190, 3166, 3174, 3179, 3184, 3189, 3163, 3164, 3165, 3172, 3173, 3161, 3168, 3169, 3170, 3171, 3167]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd72 : RData :=
  ⟨2731965, 2733114, Stage.setAll PTrie.nil [(2731959, 2733071), (2731960, 2732246), (2731961, 2733077), (2731962, 2733073), (2731963, 2732248), (2731964, 2733079)], Stage.setAll PTrie.nil [(19632, 19658), (19633, 19636), (19634, 19659)],
   19635, 19660, 16727, 16727, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(3161, .ref 3191), (3162, .ref 3190), (3163, .ref 3166), (3164, .ref 3174), (3165, .ref 3179), (3166, .ref 3184), (3167, .ref 3189), (3168, .ref 3163), (3169, .ref 3164), (3170, .ref 3165), (3171, .ref 3172), (3172, .ref 3173), (3173, .ref 3161), (3174, .ref 3168), (3175, .ref 3169), (3176, .ref 3170), (3177, .ref 3171), (3178, .ref 3167)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa72 : Map :=
  Conv.Map.compact 2731959 2733114 3161 PRE_first_tail_x15_r0_body.pl72 (PRE_first_tail_x15_r0_body.nr72.map NumV.ref) PRE_first_tail_x15_r0_body.kd72.big
    PRE_first_tail_x15_r0_body.kd72.region PRE_first_tail_x15_r0_body.kd72.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws72 : List Nat := [2231, 2232, 2233, 2234, 2235, 2236, 2237, 2238, 2239, 2240, 2241, 2242, 2243, 2244, 2245, 2246, 2247, 2248]
noncomputable def PRE_first_tail_x15_r0_body.crs72 : List SymE := PRE_first_tail_x15_r0_body.nr72.map fun r => (nth? PRE_first_tail_x15_r0_body.S707.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta72 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws72 PRE_first_tail_x15_r0_body.crs72
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB72 : List Nat := [2665, 2672486, 2673467, 2731133, 2731678, 2731934]

kernel_rfl PRE_first_tail_x15_r0_body.ctab72 : PRE_first_tail_x15_r0_body.S708.tab = PRE_first_tail_x15_r0_body.S706.tab ++ PRE_first_tail_x15_r0_body.cws72.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace72 : PRE_first_tail_x15_r0_body.s708.trace = PRE_first_tail_x15_r0_body.s706.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext72 : PRE_first_tail_x15_r0_body.s708.next = 2731965
kernel_rfl PRE_first_tail_x15_r0_body.ccounters72 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx.nnext) = (19635, 16727)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue72 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s707.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa72.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp72 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx.tokens.all (bSN 3179) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean72 : Conv.cleanListB 19635 131072 (fun r => Nat.ble 78540 r) PRE_first_tail_x15_r0_body.s708
    (PRE_first_tail_x15_r0_body.wrB72 ++ (List.range 6).map (2731959 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs72 : bigsOutB 19635 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK72
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl72`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl72 : List Nat := [2665, 2672486, 2673467, 2731133, 2731678, 2731934, 2731959, 2731960, 2731961, 2731962, 2731963, 2731964]
def PRE_first_tail_x15_r0_body.clo72 : List Nat := [19612, 19625, 19631, 19632, 19633, 19634]
def PRE_first_tail_x15_r0_body.cln72 : List Nat := [16700, 16701, 16702, 16703, 16704, 16705, 16706, 16707, 16708, 16709, 16710, 16711, 16712, 16713, 16714, 16715, 16716, 16717, 16718, 16719, 16720, 16721, 16722, 16723, 16724, 16725, 16726]
def PRE_first_tail_x15_r0_body.cli72 : List Nat := [16700, 16701, 16702, 16703, 16704, 16705, 16706, 16707, 16708, 16709, 16710, 16711, 16712, 16713, 16714, 16715, 16716, 16717, 16718, 16719, 16720, 16721, 16722, 16723, 16724, 16725, 16726]
kernel_rfl PRE_first_tail_x15_r0_body.cheap72 : PRE_first_tail_x15_r0_body.s708.heap = Stage.setAll PRE_first_tail_x15_r0_body.s706.heap (PRE_first_tail_x15_r0_body.cl72.filterMap fun a => (PRE_first_tail_x15_r0_body.s708.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe72 : Nat.ble PRE_first_tail_x15_r0_body.s706.next PRE_first_tail_x15_r0_body.s708.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP72 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s706 PRE_first_tail_x15_r0_body.s708 PRE_first_tail_x15_r0_body.cl72 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp72 : Conv.suppListB PRE_first_tail_x15_r0_body.s708 3179 PRE_first_tail_x15_r0_body.cl72 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound72 : Conv.boundListB PRE_first_tail_x15_r0_body.s708 PRE_first_tail_x15_r0_body.cl72 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK72 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln72.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK72 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo72.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK72 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli72.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst72 : Conv.sstListB 3179 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx PRE_first_tail_x15_r0_body.cln72 PRE_first_tail_x15_r0_body.clo72 PRE_first_tail_x15_r0_body.cli72 = true

end Host.Load.Run.Tpl
end

section -- SiteCl72
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA72 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo72.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd72 : (PRE_first_tail_x15_r0_body.clo72 ++ PRE_first_tail_x15_r0_body.cln72 ++ PRE_first_tail_x15_r0_body.cli72).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle72 : Conv.Cnt.leB (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt) (⟨19635, 16727, 2731965, 3179⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck72 : Conv.ncleanListB (⟨19635, 16727, 2731965, 3179⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx PRE_first_tail_x15_r0_body.clo72 PRE_first_tail_x15_r0_body.cln72 PRE_first_tail_x15_r0_body.cli72 = true
theorem PRE_first_tail_x15_r0_body.cncl72 (h : Conv.NClean (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx) : Conv.NClean (⟨19635, 16727, 2731965, 3179⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle72 PRE_first_tail_x15_r0_body.ckA72 PRE_first_tail_x15_r0_body.cobjsK72 PRE_first_tail_x15_r0_body.cnodesK72 PRE_first_tail_x15_r0_body.citemsK72 PRE_first_tail_x15_r0_body.cbd72 PRE_first_tail_x15_r0_body.cck72

end Host.Load.Run.Tpl
end

section -- SiteS72
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 72 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc72 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P72 : LoadP := PRE_first_tail_x15_r0_body.Pc72.raise 16727
kernel_rfl PRE_first_tail_x15_r0_body.craise72 : Nat.ble PRE_first_tail_x15_r0_body.Pc72.N0 16727 = true
theorem PRE_first_tail_x15_r0_body.raised72 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc72 PRE_first_tail_x15_r0_body.P72 :=
  .inr ⟨16727, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise72, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_72 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_72 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s707.ffi)
def PRE_first_tail_x15_r0_body.khinv72 : PTrie Nat := Stage.setAll PTrie.nil [(19658, 19632), (19636, 19633), (19659, 19634)]
def PRE_first_tail_x15_r0_body.kninv72 : PTrie Nat := Stage.setAll PTrie.nil [(16700, 16700), (16701, 16701), (16702, 16702), (16703, 16703), (16704, 16704), (16705, 16705), (16706, 16706), (16707, 16707), (16708, 16708), (16709, 16709), (16710, 16710), (16711, 16711), (16712, 16712), (16713, 16713), (16714, 16714), (16715, 16715), (16716, 16716), (16717, 16717), (16718, 16718), (16719, 16719), (16720, 16720), (16721, 16721), (16722, 16722), (16723, 16723), (16724, 16724), (16725, 16725), (16726, 16726)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS72 : List Nat := [19612, 19625, 19631, 19632, 19633, 19634, 19635, 19636, 19637, 19638, 19639, 19640, 19641, 19642, 19643, 19644, 19645, 19646, 19647, 19648, 19649, 19650, 19651, 19652, 19653, 19654, 19655, 19656, 19657, 19658, 19659]
def PRE_first_tail_x15_r0_body.cnS72 : List Nat := List.range' 16700 27
def PRE_first_tail_x15_r0_body.ciS72 : List Nat := [] ++ List.range' 16700 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh072 : PRE_first_tail_x15_r0_body.kd72.nh0 = PRE_first_tail_x15_r0_body.cx0_72.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh172 : PRE_first_tail_x15_r0_body.kd72.nh1 = PRE_first_tail_x15_r0_body.cx1_72.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn072 : PRE_first_tail_x15_r0_body.kd72.nn0 = PRE_first_tail_x15_r0_body.cx0_72.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn172 : PRE_first_tail_x15_r0_body.kd72.nn1 = PRE_first_tail_x15_r0_body.cx1_72.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo72 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P72.lo && Nat.ble PRE_first_tail_x15_r0_body.P72.lo PRE_first_tail_x15_r0_body.cx0_72.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P72.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P72.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt72 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_72.mlx.next PRE_first_tail_x15_r0_body.cx1_72.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_72.mlx.nnext PRE_first_tail_x15_r0_body.cx1_72.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband72 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P72.NL && Nat.ble PRE_first_tail_x15_r0_body.P72.NL PRE_first_tail_x15_r0_body.P72.N0 && Nat.ble PRE_first_tail_x15_r0_body.P72.N0 PRE_first_tail_x15_r0_body.cx0_72.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow72 : PRE_first_tail_x15_r0_body.kd72.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren72 : checkRenG PRE_first_tail_x15_r0_body.kd72.hnd PRE_first_tail_x15_r0_body.khinv72 (phB PRE_first_tail_x15_r0_body.cx0_72.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband72 : PRE_first_tail_x15_r0_body.kd72.checkBand PRE_first_tail_x15_r0_body.P72.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos72 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd72.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren72 : checkRenG PRE_first_tail_x15_r0_body.kd72.node PRE_first_tail_x15_r0_body.kninv72 (pnB PRE_first_tail_x15_r0_body.cx0_72.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow72 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd72.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P72.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd72.nodeF j) PRE_first_tail_x15_r0_body.cx1_72.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a72 : PRE_first_tail_x15_r0_body.cx0_72.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b72 : PRE_first_tail_x15_r0_body.cx0_72.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok172 : PRE_first_tail_x15_r0_body.cx1_72.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend72 : PRE_first_tail_x15_r0_body.cx1_72.mlx.pending = PRE_first_tail_x15_r0_body.cx0_72.mlx.pending.map PRE_first_tail_x15_r0_body.kappa72.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh72 : PRE_first_tail_x15_r0_body.cx1_72.mlx.errh = PRE_first_tail_x15_r0_body.cx0_72.mlx.errh.map PRE_first_tail_x15_r0_body.kappa72.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles72 : PRE_first_tail_x15_r0_body.cx1_72.mlx.files = PRE_first_tail_x15_r0_body.cx0_72.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch72 : PRE_first_tail_x15_r0_body.cx1_72.mlx.arch = PRE_first_tail_x15_r0_body.cx0_72.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes72 : PRE_first_tail_x15_r0_body.cx1_72.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_72.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired72 : PRE_first_tail_x15_r0_body.cx1_72.mlx.wired = PRE_first_tail_x15_r0_body.cx0_72.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost72 : PRE_first_tail_x15_r0_body.cx1_72.host = PRE_first_tail_x15_r0_body.cx0_72.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd72`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn072 : PRE_first_tail_x15_r0_body.kd72.n0 = 2731965
kernel_rfl PRE_first_tail_x15_r0_body.ckn172 : PRE_first_tail_x15_r0_body.kd72.n1 = 2733114
kernel_rfl PRE_first_tail_x15_r0_body.ckheap72 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd72.heap).all (fun x => Nat.ble 2731959 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl72 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd72.heap.get (2731959 + j) = nth? PRE_first_tail_x15_r0_body.pl72 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja72 : Nat.ble 2731959 2731959 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn72 : Nat.ble 3161 3161 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD72 : Nat.ble 2731959 PRE_first_tail_x15_r0_body.kd72.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn72 : Nat.ble 19632 PRE_first_tail_x15_r0_body.kd72.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn72 : Nat.ble 16700 PRE_first_tail_x15_r0_body.kd72.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb72 : Nat.ble 19632 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap72 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd72.heap).all (Nat.ble (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd72 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd72.hnd).all (Nat.ble (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode72 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd72.node).all (Nat.ble (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix72 : Conv.FixOld (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa72 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja72) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn72) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD72) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn72) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn72) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb72) PRE_first_tail_x15_r0_body.fheap72 PRE_first_tail_x15_r0_body.fhnd72 PRE_first_tail_x15_r0_body.fnode72
kernel_rfl PRE_first_tail_x15_r0_body.fcxn72 : (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn72 : (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle072 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_72.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_72.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk72 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd72.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A72 : PRE_first_tail_x15_r0_body.cx1_72.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS72.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_72.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O72 : PRE_first_tail_x15_r0_body.cx1_72.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS72.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_72.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N72 : PRE_first_tail_x15_r0_body.cx1_72.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS72.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_72.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I72 : PRE_first_tail_x15_r0_body.cx1_72.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS72.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_72.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd72 : (PRE_first_tail_x15_r0_body.clo72 ++ PRE_first_tail_x15_r0_body.cln72 ++ PRE_first_tail_x15_r0_body.cli72 ++ PRE_first_tail_x15_r0_body.cwS72 ++ PRE_first_tail_x15_r0_body.cnS72 ++ PRE_first_tail_x15_r0_body.ciS72).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW72 : PRE_first_tail_x15_r0_body.cwS72.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo72.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI72 : PRE_first_tail_x15_r0_body.ciS72.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli72.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN72 : PRE_first_tail_x15_r0_body.cnS72.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF72 : PRE_first_tail_x15_r0_body.cln72.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh72 : PRE_first_tail_x15_r0_body.clo72.all (handleOK PRE_first_tail_x15_r0_body.kappa72 PRE_first_tail_x15_r0_body.P72.lo PRE_first_tail_x15_r0_body.cx0_72.mlx PRE_first_tail_x15_r0_body.cx1_72.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo72 : PRE_first_tail_x15_r0_body.clo72.map (fun h => PRE_first_tail_x15_r0_body.cx1_72.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa72.handle h)) = PRE_first_tail_x15_r0_body.clo72.map (fun h => (PRE_first_tail_x15_r0_body.cx0_72.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa72.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok72 : PRE_first_tail_x15_r0_body.clo72.all (objOK PRE_first_tail_x15_r0_body.kappa72 PRE_first_tail_x15_r0_body.P72.NL PRE_first_tail_x15_r0_body.cx0_72.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd72 : PRE_first_tail_x15_r0_body.cln72.all (nodeOKF PRE_first_tail_x15_r0_body.kappa72 PRE_first_tail_x15_r0_body.P72 PRE_first_tail_x15_r0_body.cx0_72.mlx PRE_first_tail_x15_r0_body.cx1_72.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp72 : ((PRE_first_tail_x15_r0_body.cln72.filter (fullB PRE_first_tail_x15_r0_body.P72))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_72.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa72.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln72.filter (fullB PRE_first_tail_x15_r0_body.P72))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_72.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa72.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI72 : incrB PRE_first_tail_x15_r0_body.kd72.nodeF (List.range' 16700 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK72 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd72.node).all (fun k => Nat.ble 16700 k && Nat.blt k 16727) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL72 : (PRE_first_tail_x15_r0_body.cln72.filter (Nat.ble PRE_first_tail_x15_r0_body.P72.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd72.nodeF i) && (Nat.blt i 16727 || Nat.ble PRE_first_tail_x15_r0_body.kd72.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord72 : (PRE_first_tail_x15_r0_body.cln72.filter (Nat.ble PRE_first_tail_x15_r0_body.P72.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd72.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd72.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd72.nodeF j) (PRE_first_tail_x15_r0_body.kd72.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow72 PRE_first_tail_x15_r0_body.cnn172 PRE_first_tail_x15_r0_body.fnordI72 PRE_first_tail_x15_r0_body.fnordK72 PRE_first_tail_x15_r0_body.fnordL72
kernel_rfl PRE_first_tail_x15_r0_body.fi72 : PRE_first_tail_x15_r0_body.cli72.all (pnB PRE_first_tail_x15_r0_body.cx0_72.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii72 : PRE_first_tail_x15_r0_body.cli72.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_72.mlx.items.get (PRE_first_tail_x15_r0_body.kappa72.node k) = (PRE_first_tail_x15_r0_body.cx0_72.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa72.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot72 (clean : Conv.NClean (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P72.NL) (cl : SSt (· < 3179) PRE_first_tail_x15_r0_body.cx0_72.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P72 3179 PRE_first_tail_x15_r0_body.kappa72 PRE_first_tail_x15_r0_body.kd72 PRE_first_tail_x15_r0_body.khinv72 PRE_first_tail_x15_r0_body.kninv72 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx PRE_first_tail_x15_r0_body.cx0_72.mlx PRE_first_tail_x15_r0_body.cx1_72.mlx (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo72 PRE_first_tail_x15_r0_body.cln72 PRE_first_tail_x15_r0_body.cli72 PRE_first_tail_x15_r0_body.cwS72 PRE_first_tail_x15_r0_body.cnS72 PRE_first_tail_x15_r0_body.ciS72 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh072, PRE_first_tail_x15_r0_body.cnh172, PRE_first_tail_x15_r0_body.cnn072, PRE_first_tail_x15_r0_body.cnn172, PRE_first_tail_x15_r0_body.cplo72, PRE_first_tail_x15_r0_body.ccnt72, PRE_first_tail_x15_r0_body.cnband72, PRE_first_tail_x15_r0_body.chbelow72, PRE_first_tail_x15_r0_body.chren72, PRE_first_tail_x15_r0_body.cband72, PRE_first_tail_x15_r0_body.cnh1pos72, PRE_first_tail_x15_r0_body.cnren72, PRE_first_tail_x15_r0_body.cnlow72, PRE_first_tail_x15_r0_body.cabs0a72, PRE_first_tail_x15_r0_body.cabs0b72, PRE_first_tail_x15_r0_body.ctok172, PRE_first_tail_x15_r0_body.cpend72, PRE_first_tail_x15_r0_body.cerrh72, PRE_first_tail_x15_r0_body.cfiles72, PRE_first_tail_x15_r0_body.carch72, PRE_first_tail_x15_r0_body.csizes72, PRE_first_tail_x15_r0_body.cwired72, PRE_first_tail_x15_r0_body.cfix72, clean, PRE_first_tail_x15_r0_body.fcxn72, PRE_first_tail_x15_r0_body.fcnn72, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle072, PRE_first_tail_x15_r0_body.fnk72, PRE_first_tail_x15_r0_body.ckA72, PRE_first_tail_x15_r0_body.cobjsK72, PRE_first_tail_x15_r0_body.cnodesK72, PRE_first_tail_x15_r0_body.citemsK72, PRE_first_tail_x15_r0_body.f1A72, PRE_first_tail_x15_r0_body.f1O72, PRE_first_tail_x15_r0_body.f1N72, PRE_first_tail_x15_r0_body.f1I72, PRE_first_tail_x15_r0_body.fbd72, PRE_first_tail_x15_r0_body.fincW72, PRE_first_tail_x15_r0_body.fincI72, PRE_first_tail_x15_r0_body.fincN72, PRE_first_tail_x15_r0_body.flnF72, PRE_first_tail_x15_r0_body.fh72, PRE_first_tail_x15_r0_body.fo72, PRE_first_tail_x15_r0_body.fok72, PRE_first_tail_x15_r0_body.fnd72, PRE_first_tail_x15_r0_body.fp72, PRE_first_tail_x15_r0_body.fnord72, PRE_first_tail_x15_r0_body.fi72, PRE_first_tail_x15_r0_body.fii72⟩
theorem PRE_first_tail_x15_r0_body.cnshift72 (clean : Conv.NClean (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P72.NL) (cl : SSt (· < 3179) PRE_first_tail_x15_r0_body.cx0_72.mlx) : NShift PRE_first_tail_x15_r0_body.P72 3179 PRE_first_tail_x15_r0_body.kappa72 PRE_first_tail_x15_r0_body.cx0_72 PRE_first_tail_x15_r0_body.cx1_72 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot72 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost72 (compact_a_eq PRE_first_tail_x15_r0_body.ckn072 PRE_first_tail_x15_r0_body.ckn172 PRE_first_tail_x15_r0_body.ckheap72 PRE_first_tail_x15_r0_body.ckpl72)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_72 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s706.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_72 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s706.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_72 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s706.ffi) = some PRE_first_tail_x15_r0_body.fxC_72
kernel_rfl PRE_first_tail_x15_r0_body.okrC_72 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s706.ffi) = some PRE_first_tail_x15_r0_body.krC_72
noncomputable def PRE_first_tail_x15_r0_body.fx0_72 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s708.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_72 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s708.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_72 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s708.ffi) = some PRE_first_tail_x15_r0_body.fx0_72
kernel_rfl PRE_first_tail_x15_r0_body.okr0_72 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s708.ffi) = some PRE_first_tail_x15_r0_body.kr0_72
noncomputable def PRE_first_tail_x15_r0_body.fx1_72 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s707.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_72 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s707.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_72 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s707.ffi) = some PRE_first_tail_x15_r0_body.fx1_72
kernel_rfl PRE_first_tail_x15_r0_body.okr1_72 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s707.ffi) = some PRE_first_tail_x15_r0_body.kr1_72
kernel_rfl PRE_first_tail_x15_r0_body.ff072 : PRE_first_tail_x15_r0_body.fx0_72 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_72 (PRE_first_tail_x15_r0_body.clo72.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_72.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff172 : PRE_first_tail_x15_r0_body.fx1_72 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_72 (PRE_first_tail_x15_r0_body.cwS72.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_72.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck72 : freedLB PRE_first_tail_x15_r0_body.kappa72 PRE_first_tail_x15_r0_body.cx0_72.mlx PRE_first_tail_x15_r0_body.fx0_72 PRE_first_tail_x15_r0_body.fx1_72 PRE_first_tail_x15_r0_body.clo72 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf072 : PRE_first_tail_x15_r0_body.kr0_72.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_72.flags (PRE_first_tail_x15_r0_body.clo72.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_72.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt072 : PRE_first_tail_x15_r0_body.kr0_72.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_72.targs (PRE_first_tail_x15_r0_body.clo72.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_72.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf172 : PRE_first_tail_x15_r0_body.kr1_72.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_72.flags (PRE_first_tail_x15_r0_body.cwS72.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_72.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt172 : PRE_first_tail_x15_r0_body.kr1_72.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_72.targs (PRE_first_tail_x15_r0_body.cwS72.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_72.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck72 : krecLB PRE_first_tail_x15_r0_body.kappa72 3179 PRE_first_tail_x15_r0_body.cx0_72.mlx PRE_first_tail_x15_r0_body.kr0_72 PRE_first_tail_x15_r0_body.kr1_72 PRE_first_tail_x15_r0_body.clo72 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn72 : Nat.ble 3161 3179 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge72 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s707.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s708.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR72 : pendRegB PRE_first_tail_x15_r0_body.kappa72 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe72 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s707.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift72 (clean : Conv.NClean (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P72.NL) (cl : SSt (· < 3179) PRE_first_tail_x15_r0_body.cx0_72.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_72.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_72.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_72.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_72.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P72 3179 PRE_first_tail_x15_r0_body.kappa72 PRE_first_tail_x15_r0_body.s708.ffi PRE_first_tail_x15_r0_body.s707.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift72 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue72, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp72 t ht),
    PRE_first_tail_x15_r0_body.cbridge72,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s708.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s707.ffi) (PRE_first_tail_x15_r0_body.cfoot72 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_72 PRE_first_tail_x15_r0_body.ofx1_72 hobjC PRE_first_tail_x15_r0_body.ff072 PRE_first_tail_x15_r0_body.ff172 PRE_first_tail_x15_r0_body.ffck72,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s708.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s707.ffi) (PRE_first_tail_x15_r0_body.cfoot72 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_72 PRE_first_tail_x15_r0_body.okr1_72 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn72) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf072 PRE_first_tail_x15_r0_body.fkt072 PRE_first_tail_x15_r0_body.fkf172 PRE_first_tail_x15_r0_body.fkt172 PRE_first_tail_x15_r0_body.fkck72,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh072 PRE_first_tail_x15_r0_body.cnh172 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe72) PRE_first_tail_x15_r0_body.cpendR72⟩

end Host.Load.Run.Tpl
end

section -- st72/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st72 0
host_stream_state PRE_first_tail_x15_r0_body.st72 1
host_stream_state PRE_first_tail_x15_r0_body.st72 2
host_stream_state PRE_first_tail_x15_r0_body.st72 3
host_stream_state PRE_first_tail_x15_r0_body.st72 4
host_stream_state PRE_first_tail_x15_r0_body.st72 5
end Host.Load.Run.Tpl
end

section -- Site72
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 72 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g72__g73` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s706`, the merged state `PRE_first_tail_x15_r0_body.s707`,
the site template `PRE_first_tail_x15_r0_body.st72` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s708`: the merge.
The footprint's facts are in `SiteF72`, the compaction's in `SiteC72`, `SiteK72`, `SiteNa72`, `SiteNb72`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso72 : PRE_first_tail_x15_r0_body.st72.s0 = { PRE_first_tail_x15_r0_body.s706 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs72 : List Frame := PRE_first_tail_x15_r0_body.s706.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_72 : PRE_first_tail_x15_r0_body.S706.tab.length = 3161
kernel_rfl PRE_first_tail_x15_r0_body.tab0_72 : PRE_first_tail_x15_r0_body.st72.S0.tab = PRE_first_tail_x15_r0_body.S706.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws72 : List Nat := [2200, 2201, 2202, 2203, 2204, 2205, 2206, 2207, 2208, 2209, 2210, 2211, 2212, 2213, 2214, 2215, 2216, 2217, 2218, 2219, 2220, 2221, 2222, 2223, 2224, 2225, 2226, 2227, 2228, 2229, 2230]
kernel_rfl PRE_first_tail_x15_r0_body.fresh72 : (PRE_first_tail_x15_r0_body.S706.tab.all fun e => PRE_first_tail_x15_r0_body.ws72.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S706.oracle.all fun q => PRE_first_tail_x15_r0_body.ws72.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab72 : PRE_first_tail_x15_r0_body.S707.tab = PRE_first_tail_x15_r0_body.S706.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws72
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen72 : PRE_first_tail_x15_r0_body.st72.S5.tab.length - PRE_first_tail_x15_r0_body.st72.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged72`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap72 : PRE_first_tail_x15_r0_body.s707.heap = PRE_first_tail_x15_r0_body.st72.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext72 : PRE_first_tail_x15_r0_body.s707.next = PRE_first_tail_x15_r0_body.st72.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl72 : PRE_first_tail_x15_r0_body.s707.ctl = PRE_first_tail_x15_r0_body.st72.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack72 : PRE_first_tail_x15_r0_body.s707.stack = PRE_first_tail_x15_r0_body.st72.s5.stack ++ PRE_first_tail_x15_r0_body.s706.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs72 : PRE_first_tail_x15_r0_body.s707.jobs = PRE_first_tail_x15_r0_body.st72.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi72 : PRE_first_tail_x15_r0_body.s707.ffi = PRE_first_tail_x15_r0_body.st72.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace72 : PRE_first_tail_x15_r0_body.s707.trace = PRE_first_tail_x15_r0_body.st72.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores72 : PRE_first_tail_x15_r0_body.s707.stores = PRE_first_tail_x15_r0_body.st72.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD72
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 72 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived72 : PRE_first_tail_x15_r0_body.nr72.map (fun r => nth? PRE_first_tail_x15_r0_body.st72.S5.tab r) =
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
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo72 : PRE_first_tail_x15_r0_body.nr72.all (Nat.ble 3161) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj72 : PRE_first_tail_x15_r0_body.cws72.all (fun c => !PRE_first_tail_x15_r0_body.ws72.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ72 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws72 PRE_first_tail_x15_r0_body.crs72 PRE_first_tail_x15_r0_body.ws72

end Host.Load.Run.Tpl
end

section -- st72/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st72`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st72.wrR : List (Nat × Nat) := [(2672486, 2672487), (2731133, 2731134), (2731678, 2731679), (2731934, 2731935)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st72.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st72.s5.heap PRE_first_tail_x15_r0_body.st72.wrR ++ freshOf PRE_first_tail_x15_r0_body.st72.s5.heap PRE_first_tail_x15_r0_body.st72.s0.next PRE_first_tail_x15_r0_body.st72.s5.next
noncomputable def PRE_first_tail_x15_r0_body.st72.wr : List Nat := PRE_first_tail_x15_r0_body.st72.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st72.heapFoot : PRE_first_tail_x15_r0_body.st72.s5.heap = setAll PRE_first_tail_x15_r0_body.st72.s0.heap PRE_first_tail_x15_r0_body.st72.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st72.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st72.s0.next PRE_first_tail_x15_r0_body.st72.s5.next = true
theorem PRE_first_tail_x15_r0_body.st72.grows : PRE_first_tail_x15_r0_body.st72.s0.next ≤ PRE_first_tail_x15_r0_body.st72.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st72.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st72.wh : List Nat := [19612, 19625, 19631, 19632, 19633, 19634, 19635, 19636, 19637, 19638, 19639, 19640, 19641, 19642, 19643, 19644, 19645, 19646, 19647, 19648, 19649, 19650, 19651, 19652, 19653, 19654, 19655, 19656, 19657, 19658, 19659]
def PRE_first_tail_x15_r0_body.st72.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st72.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st72.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st72.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st72.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st72.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st72.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st72.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st72.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st72.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st72.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st72.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st72.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st72.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st72.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st72.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st72.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st72.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st72.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st72.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st72.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st72.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st72.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st72.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st72.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st72.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st72.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st72.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st72.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st72.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF72
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 72 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB72 : nodupT PRE_first_tail_x15_r0_body.st72.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup72 : PRE_first_tail_x15_r0_body.st72.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB72).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB72 : PRE_first_tail_x15_r0_body.st72.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound72 : ∀ b ∈ PRE_first_tail_x15_r0_body.st72.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB72 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr72 := PRE_first_tail_x15_r0_body.st72.s5.trace.take 120
kernel_rfl PRE_first_tail_x15_r0_body.traceEq72 : PRE_first_tail_x15_r0_body.st72.s5.trace = PRE_first_tail_x15_r0_body.trFr72 ++ PRE_first_tail_x15_r0_body.st72.s0.trace
theorem PRE_first_tail_x15_r0_body.trace72 : ∃ fr, PRE_first_tail_x15_r0_body.st72.s5.trace = fr ++ PRE_first_tail_x15_r0_body.st72.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq72⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide72 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB72 : (PRE_first_tail_x15_r0_body.wide72.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st72.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix72 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide72, WFix Map.id (Present PRE_first_tail_x15_r0_body.st72.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB72 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL72
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 72 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s707`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO72 : PRE_first_tail_x15_r0_body.st72.S0.oracle = PRE_first_tail_x15_r0_body.st72.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B72 : PRE_first_tail_x15_r0_body.st72.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st72.s0.next || (PRE_first_tail_x15_r0_body.st72.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot72 : Conv.StageFoot PRE_first_tail_x15_r0_body.st72.wr PRE_first_tail_x15_r0_body.st72.s0 PRE_first_tail_x15_r0_body.st72.s5 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st72.heapFoot PRE_first_tail_x15_r0_body.wrNodup72 PRE_first_tail_x15_r0_body.wrBound72 PRE_first_tail_x15_r0_body.wr0B72 PRE_first_tail_x15_r0_body.st72.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged72 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st72.F.S → PRE_first_tail_x15_r0_body.st72.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st72.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st72.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs72 PRE_first_tail_x15_r0_body.st72.wr PRE_first_tail_x15_r0_body.s706 PRE_first_tail_x15_r0_body.st72.s5 PRE_first_tail_x15_r0_body.st72.s0
      PRE_first_tail_x15_r0_body.st72.s5.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st72.F FR W stk M ν K PRE_first_tail_x15_r0_body.s707 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso72 PRE_first_tail_x15_r0_body.stFoot72 PRE_first_tail_x15_r0_body.wrNodup72 PRE_first_tail_x15_r0_body.wrBound72 PRE_first_tail_x15_r0_body.trace72 PRE_first_tail_x15_r0_body.mheap72
    PRE_first_tail_x15_r0_body.mnext72 PRE_first_tail_x15_r0_body.mctl72 PRE_first_tail_x15_r0_body.mstack72 PRE_first_tail_x15_r0_body.mjobs72 PRE_first_tail_x15_r0_body.mffi72 PRE_first_tail_x15_r0_body.mtrace72 PRE_first_tail_x15_r0_body.mstores72 h

def PRE_first_tail_x15_r0_body.arrEl72_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE72_2665 : arrOf PRE_first_tail_x15_r0_body.s707 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl72_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA72_2665 : isArrB PRE_first_tail_x15_r0_body.s707 2665 = true
theorem PRE_first_tail_x15_r0_body.arr72_2665 : ∃ o, PRE_first_tail_x15_r0_body.s707.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl72_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE72_2665 PRE_first_tail_x15_r0_body.arrA72_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN72_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl72_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR72_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl72_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN72_2665

def PRE_first_tail_x15_r0_body.arrEl72_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE72_2673467 : arrOf PRE_first_tail_x15_r0_body.s707 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl72_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA72_2673467 : isArrB PRE_first_tail_x15_r0_body.s707 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr72_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s707.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl72_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE72_2673467 PRE_first_tail_x15_r0_body.arrA72_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN72_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl72_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR72_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl72_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN72_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k72 : isArrB PRE_first_tail_x15_r0_body.s707 4910 = false
theorem PRE_first_tail_x15_r0_body.keep72 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s707 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k72 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr72_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl72_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ72
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 72 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s706`, the merged
state `PRE_first_tail_x15_r0_body.s707`, the canonical state `PRE_first_tail_x15_r0_body.s708`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl72 : PRE_first_tail_x15_r0_body.pl72.all (Nat.ble PRE_first_tail_x15_r0_body.s706.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd72 : nodupT PRE_first_tail_x15_r0_body.pl72 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn172 : Nat.ble PRE_first_tail_x15_r0_body.s706.next 2733114 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst72 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s706.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn72 : PRE_first_tail_x15_r0_body.s708.next = PRE_first_tail_x15_r0_body.s706.next + PRE_first_tail_x15_r0_body.pl72.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn72 : PRE_first_tail_x15_r0_body.s707.next = 2733114
kernel_rfl PRE_first_tail_x15_r0_body.zgrow72 : Nat.ble PRE_first_tail_x15_r0_body.s708.next PRE_first_tail_x15_r0_body.s707.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh72 : PRE_first_tail_x15_r0_body.S706.tab.all (fun e => PRE_first_tail_x15_r0_body.cws72.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd72 : nodupT PRE_first_tail_x15_r0_body.cws72 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi72 : PRE_first_tail_x15_r0_body.nr72.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S707.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt72 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s706.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg72_2665 : PRE_first_tail_x15_r0_body.s708.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s708 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk72_2665 : (objOf PRE_first_tail_x15_r0_body.s708 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm72_2665 : PRE_first_tail_x15_r0_body.s707.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa72.obj (objOf PRE_first_tail_x15_r0_body.s708 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s707 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg72_2673467 : PRE_first_tail_x15_r0_body.s708.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s708 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk72_2673467 : (objOf PRE_first_tail_x15_r0_body.s708 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm72_2673467 : PRE_first_tail_x15_r0_body.s707.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa72.obj (objOf PRE_first_tail_x15_r0_body.s708 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s707 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw72_4910 : (PRE_first_tail_x15_r0_body.s708.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw72_2673472 : (PRE_first_tail_x15_r0_body.s708.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw72_2673473 : (PRE_first_tail_x15_r0_body.s708.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd72 : PRE_first_tail_x15_r0_body.cl72.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr72 : PRE_first_tail_x15_r0_body.st72.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s706.next || PRE_first_tail_x15_r0_body.cl72.contains b) = true
def PRE_first_tail_x15_r0_body.zl72 : List Nat := PRE_first_tail_x15_r0_body.cl72.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE72 : PRE_first_tail_x15_r0_body.zl72.map (fun a => PRE_first_tail_x15_r0_body.s707.heap.get (PRE_first_tail_x15_r0_body.kappa72.a a)) = PRE_first_tail_x15_r0_body.zl72.map (fun a => (PRE_first_tail_x15_r0_body.s708.heap.get a).map PRE_first_tail_x15_r0_body.kappa72.hobj)
theorem PRE_first_tail_x15_r0_body.zimg72 : HeapImg PRE_first_tail_x15_r0_body.kappa72 PRE_first_tail_x15_r0_body.s708 PRE_first_tail_x15_r0_body.s707 PRE_first_tail_x15_r0_body.zl72 := PRE_first_tail_x15_r0_body.zimgE72
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl72 : PRE_first_tail_x15_r0_body.s707.ctl = PRE_first_tail_x15_r0_body.kappa72.ctl PRE_first_tail_x15_r0_body.s708.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack72 : PRE_first_tail_x15_r0_body.s707.stack = PRE_first_tail_x15_r0_body.s708.stack.map PRE_first_tail_x15_r0_body.kappa72.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs72 : PRE_first_tail_x15_r0_body.s707.jobs = PRE_first_tail_x15_r0_body.s708.jobs.map PRE_first_tail_x15_r0_body.kappa72.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores72 : PRE_first_tail_x15_r0_body.s707.stores = PRE_first_tail_x15_r0_body.kappa72.stores PRE_first_tail_x15_r0_body.s708.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots72 : checkRootsSupp PRE_first_tail_x15_r0_body.s708 3179 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC72 : PRE_first_tail_x15_r0_body.S706.tab.length + PRE_first_tail_x15_r0_body.cws72.length = 3179
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap72 : PRE_first_tail_x15_r0_body.kappa72 = Conv.Map.compact PRE_first_tail_x15_r0_body.s706.next 2733114 PRE_first_tail_x15_r0_body.S706.tab.length PRE_first_tail_x15_r0_body.pl72 (PRE_first_tail_x15_r0_body.nr72.map NumV.ref) PRE_first_tail_x15_r0_body.kd72.big
  PRE_first_tail_x15_r0_body.kd72.region PRE_first_tail_x15_r0_body.kd72.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin72 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s708.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc72 : Conv.jcleanListB (⟨19635, 16727, 2731965, 3179⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s708 PRE_first_tail_x15_r0_body.cl72 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB72 : noBigRootsP (fun i => !Conv.oldBigB (⟨19635, 16727, 2731965, 3179⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s708.trace PRE_first_tail_x15_r0_body.s708 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm72 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16700 = true
theorem PRE_first_tail_x15_r0_body.cjcl72 (h : Conv.JClean (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s706) : Conv.JClean (⟨19635, 16727, 2731965, 3179⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s708 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle72)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap72 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd72 a ha)) PRE_first_tail_x15_r0_body.zjc72

end Host.Load.Run.Tpl
end

section -- st72/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st72.bodyLast from PRE_first_tail_x15_r0_body.st72.s4 to PRE_first_tail_x15_r0_body.st72.s5 :
  interpS (step PRE_first_tail_x15_r0_body.st72.F PRE_first_tail_x15_r0_body.st72.s4).run PRE_first_tail_x15_r0_body.st72.S4 = some (PRE_first_tail_x15_r0_body.st72.s5, PRE_first_tail_x15_r0_body.st72.S5)
kernel_rfl PRE_first_tail_x15_r0_body.st72.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st72.s4.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st72.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st72.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st72/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st72.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st72.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st72.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st72.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st72.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st72.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st72.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st72.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st72.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st72.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st72.s0 PRE_first_tail_x15_r0_body.st72.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st72.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st72.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st72.s4 PRE_first_tail_x15_r0_body.st72.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st72/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st72.bodyK0F from PRE_first_tail_x15_r0_body.st72.s0 to PRE_first_tail_x15_r0_body.st72.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st72.F (PRE_first_tail_x15_r0_body.st72.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st72.ks 0).getD 0) PRE_first_tail_x15_r0_body.st72.s0 PRE_first_tail_x15_r0_body.st72.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st72.s1, PRE_first_tail_x15_r0_body.st72.S1)
theorem PRE_first_tail_x15_r0_body.st72.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st72.F (PRE_first_tail_x15_r0_body.st72.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st72.ks 0).getD 0) PRE_first_tail_x15_r0_body.st72.s0 PRE_first_tail_x15_r0_body.st72.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st72.s1, PRE_first_tail_x15_r0_body.st72.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st72.bodyOkLN_ok PRE_first_tail_x15_r0_body.st72.bodyK0F
end Host.Load.Run.Tpl
end

section -- st72/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st72.bodyK1F from PRE_first_tail_x15_r0_body.st72.s1 to PRE_first_tail_x15_r0_body.st72.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st72.F (PRE_first_tail_x15_r0_body.st72.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st72.ks 1).getD 0) PRE_first_tail_x15_r0_body.st72.s1 PRE_first_tail_x15_r0_body.st72.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st72.s2, PRE_first_tail_x15_r0_body.st72.S2)
theorem PRE_first_tail_x15_r0_body.st72.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st72.F (PRE_first_tail_x15_r0_body.st72.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st72.ks 1).getD 0) PRE_first_tail_x15_r0_body.st72.s1 PRE_first_tail_x15_r0_body.st72.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st72.s2, PRE_first_tail_x15_r0_body.st72.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st72.bodyOkLN_ok PRE_first_tail_x15_r0_body.st72.bodyK1F
end Host.Load.Run.Tpl
end

section -- st72/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st72.bodyK2F from PRE_first_tail_x15_r0_body.st72.s2 to PRE_first_tail_x15_r0_body.st72.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st72.F (PRE_first_tail_x15_r0_body.st72.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st72.ks 2).getD 0) PRE_first_tail_x15_r0_body.st72.s2 PRE_first_tail_x15_r0_body.st72.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st72.s3, PRE_first_tail_x15_r0_body.st72.S3)
theorem PRE_first_tail_x15_r0_body.st72.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st72.F (PRE_first_tail_x15_r0_body.st72.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st72.ks 2).getD 0) PRE_first_tail_x15_r0_body.st72.s2 PRE_first_tail_x15_r0_body.st72.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st72.s3, PRE_first_tail_x15_r0_body.st72.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st72.bodyOkLN_ok PRE_first_tail_x15_r0_body.st72.bodyK2F
end Host.Load.Run.Tpl
end

section -- st72/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st72.bodyK3F from PRE_first_tail_x15_r0_body.st72.s3 to PRE_first_tail_x15_r0_body.st72.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st72.F (PRE_first_tail_x15_r0_body.st72.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st72.ks 3).getD 0) PRE_first_tail_x15_r0_body.st72.s3 PRE_first_tail_x15_r0_body.st72.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st72.s4, PRE_first_tail_x15_r0_body.st72.S4)
theorem PRE_first_tail_x15_r0_body.st72.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st72.F (PRE_first_tail_x15_r0_body.st72.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st72.ks 3).getD 0) PRE_first_tail_x15_r0_body.st72.s3 PRE_first_tail_x15_r0_body.st72.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st72.s4, PRE_first_tail_x15_r0_body.st72.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st72.bodyOkLN_ok PRE_first_tail_x15_r0_body.st72.bodyK3F
end Host.Load.Run.Tpl
end

section -- st72/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st72.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st72.F (PRE_first_tail_x15_r0_body.st72.bodyOkL bytes rows) 11334 PRE_first_tail_x15_r0_body.st72.s0 PRE_first_tail_x15_r0_body.st72.S0 = some (PRE_first_tail_x15_r0_body.st72.s4, PRE_first_tail_x15_r0_body.st72.S4) :=
  runOk_trans PRE_first_tail_x15_r0_body.st72.F (PRE_first_tail_x15_r0_body.st72.bodyOkL bytes rows) ((((nth? PRE_first_tail_x15_r0_body.st72.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st72.ks 1).getD 0)) + ((nth? PRE_first_tail_x15_r0_body.st72.ks 2).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st72.ks 3).getD 0) PRE_first_tail_x15_r0_body.st72.s0 PRE_first_tail_x15_r0_body.st72.s3 PRE_first_tail_x15_r0_body.st72.s4 PRE_first_tail_x15_r0_body.st72.S0 PRE_first_tail_x15_r0_body.st72.S3 PRE_first_tail_x15_r0_body.st72.S4 (runOk_trans PRE_first_tail_x15_r0_body.st72.F (PRE_first_tail_x15_r0_body.st72.bodyOkL bytes rows) (((nth? PRE_first_tail_x15_r0_body.st72.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st72.ks 1).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st72.ks 2).getD 0) PRE_first_tail_x15_r0_body.st72.s0 PRE_first_tail_x15_r0_body.st72.s2 PRE_first_tail_x15_r0_body.st72.s3 PRE_first_tail_x15_r0_body.st72.S0 PRE_first_tail_x15_r0_body.st72.S2 PRE_first_tail_x15_r0_body.st72.S3 (runOk_trans PRE_first_tail_x15_r0_body.st72.F (PRE_first_tail_x15_r0_body.st72.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st72.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st72.ks 1).getD 0) PRE_first_tail_x15_r0_body.st72.s0 PRE_first_tail_x15_r0_body.st72.s1 PRE_first_tail_x15_r0_body.st72.s2 PRE_first_tail_x15_r0_body.st72.S0 PRE_first_tail_x15_r0_body.st72.S1 PRE_first_tail_x15_r0_body.st72.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st72.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st72.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st72.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st72.bodyK3 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st72.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st72.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st72.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st72.F (PRE_first_tail_x15_r0_body.st72.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st72.s0
  S0 := PRE_first_tail_x15_r0_body.st72.S0
  s1 := PRE_first_tail_x15_r0_body.st72.s4
  S1 := PRE_first_tail_x15_r0_body.st72.S4
  s2 := PRE_first_tail_x15_r0_body.st72.s5
  S2 := PRE_first_tail_x15_r0_body.st72.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st72.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st72.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st72.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st72.bodyHalt
  last := PRE_first_tail_x15_r0_body.st72.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st72.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC73
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 73 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s716` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa73` into the merged state
`PRE_first_tail_x15_r0_body.s715`. -/

def PRE_first_tail_x15_r0_body.pl73 : List Nat := []
def PRE_first_tail_x15_r0_body.nr73 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd73 : RData :=
  ⟨2732455, 2732457, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19648, 19648, 16740, 16740, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa73 : Map :=
  Conv.Map.compact 2732455 2732457 3200 PRE_first_tail_x15_r0_body.pl73 (PRE_first_tail_x15_r0_body.nr73.map NumV.ref) PRE_first_tail_x15_r0_body.kd73.big
    PRE_first_tail_x15_r0_body.kd73.region PRE_first_tail_x15_r0_body.kd73.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws73 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs73 : List SymE := PRE_first_tail_x15_r0_body.nr73.map fun r => (nth? PRE_first_tail_x15_r0_body.S715.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta73 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws73 PRE_first_tail_x15_r0_body.crs73
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB73 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab73 : PRE_first_tail_x15_r0_body.S716.tab = PRE_first_tail_x15_r0_body.S714.tab ++ PRE_first_tail_x15_r0_body.cws73.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace73 : PRE_first_tail_x15_r0_body.s716.trace = PRE_first_tail_x15_r0_body.s714.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext73 : PRE_first_tail_x15_r0_body.s716.next = 2732455
kernel_rfl PRE_first_tail_x15_r0_body.ccounters73 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx.nnext) = (19648, 16740)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue73 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s715.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa73.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp73 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx.tokens.all (bSN 3200) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean73 : Conv.cleanListB 19648 131072 (fun r => Nat.ble 78592 r) PRE_first_tail_x15_r0_body.s716
    (PRE_first_tail_x15_r0_body.wrB73 ++ (List.range 0).map (2732455 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs73 : bigsOutB 19648 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK73
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl73`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl73 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo73 : List Nat := []
def PRE_first_tail_x15_r0_body.cln73 : List Nat := []
def PRE_first_tail_x15_r0_body.cli73 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap73 : PRE_first_tail_x15_r0_body.s716.heap = Stage.setAll PRE_first_tail_x15_r0_body.s714.heap (PRE_first_tail_x15_r0_body.cl73.filterMap fun a => (PRE_first_tail_x15_r0_body.s716.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe73 : Nat.ble PRE_first_tail_x15_r0_body.s714.next PRE_first_tail_x15_r0_body.s716.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP73 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s714 PRE_first_tail_x15_r0_body.s716 PRE_first_tail_x15_r0_body.cl73 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp73 : Conv.suppListB PRE_first_tail_x15_r0_body.s716 3200 PRE_first_tail_x15_r0_body.cl73 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound73 : Conv.boundListB PRE_first_tail_x15_r0_body.s716 PRE_first_tail_x15_r0_body.cl73 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK73 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln73.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK73 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo73.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK73 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli73.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst73 : Conv.sstListB 3200 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx PRE_first_tail_x15_r0_body.cln73 PRE_first_tail_x15_r0_body.clo73 PRE_first_tail_x15_r0_body.cli73 = true

end Host.Load.Run.Tpl
end

section -- SiteCl73
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA73 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo73.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd73 : (PRE_first_tail_x15_r0_body.clo73 ++ PRE_first_tail_x15_r0_body.cln73 ++ PRE_first_tail_x15_r0_body.cli73).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle73 : Conv.Cnt.leB (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck73 : Conv.ncleanListB (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx PRE_first_tail_x15_r0_body.clo73 PRE_first_tail_x15_r0_body.cln73 PRE_first_tail_x15_r0_body.cli73 = true
theorem PRE_first_tail_x15_r0_body.cncl73 (h : Conv.NClean (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx) : Conv.NClean (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle73 PRE_first_tail_x15_r0_body.ckA73 PRE_first_tail_x15_r0_body.cobjsK73 PRE_first_tail_x15_r0_body.cnodesK73 PRE_first_tail_x15_r0_body.citemsK73 PRE_first_tail_x15_r0_body.cbd73 PRE_first_tail_x15_r0_body.cck73

end Host.Load.Run.Tpl
end

section -- SiteS73
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 73 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc73 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P73 : LoadP := PRE_first_tail_x15_r0_body.Pc73.raise 16740
kernel_rfl PRE_first_tail_x15_r0_body.craise73 : Nat.ble PRE_first_tail_x15_r0_body.Pc73.N0 16740 = true
theorem PRE_first_tail_x15_r0_body.raised73 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc73 PRE_first_tail_x15_r0_body.P73 :=
  .inr ⟨16740, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise73, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_73 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_73 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s715.ffi)
def PRE_first_tail_x15_r0_body.khinv73 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv73 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS73 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS73 : List Nat := List.range' 16740 0
def PRE_first_tail_x15_r0_body.ciS73 : List Nat := [] ++ List.range' 16740 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh073 : PRE_first_tail_x15_r0_body.kd73.nh0 = PRE_first_tail_x15_r0_body.cx0_73.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh173 : PRE_first_tail_x15_r0_body.kd73.nh1 = PRE_first_tail_x15_r0_body.cx1_73.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn073 : PRE_first_tail_x15_r0_body.kd73.nn0 = PRE_first_tail_x15_r0_body.cx0_73.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn173 : PRE_first_tail_x15_r0_body.kd73.nn1 = PRE_first_tail_x15_r0_body.cx1_73.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo73 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P73.lo && Nat.ble PRE_first_tail_x15_r0_body.P73.lo PRE_first_tail_x15_r0_body.cx0_73.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P73.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P73.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt73 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_73.mlx.next PRE_first_tail_x15_r0_body.cx1_73.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_73.mlx.nnext PRE_first_tail_x15_r0_body.cx1_73.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband73 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P73.NL && Nat.ble PRE_first_tail_x15_r0_body.P73.NL PRE_first_tail_x15_r0_body.P73.N0 && Nat.ble PRE_first_tail_x15_r0_body.P73.N0 PRE_first_tail_x15_r0_body.cx0_73.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow73 : PRE_first_tail_x15_r0_body.kd73.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren73 : checkRenG PRE_first_tail_x15_r0_body.kd73.hnd PRE_first_tail_x15_r0_body.khinv73 (phB PRE_first_tail_x15_r0_body.cx0_73.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband73 : PRE_first_tail_x15_r0_body.kd73.checkBand PRE_first_tail_x15_r0_body.P73.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos73 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd73.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren73 : checkRenG PRE_first_tail_x15_r0_body.kd73.node PRE_first_tail_x15_r0_body.kninv73 (pnB PRE_first_tail_x15_r0_body.cx0_73.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow73 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd73.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P73.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd73.nodeF j) PRE_first_tail_x15_r0_body.cx1_73.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a73 : PRE_first_tail_x15_r0_body.cx0_73.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b73 : PRE_first_tail_x15_r0_body.cx0_73.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok173 : PRE_first_tail_x15_r0_body.cx1_73.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend73 : PRE_first_tail_x15_r0_body.cx1_73.mlx.pending = PRE_first_tail_x15_r0_body.cx0_73.mlx.pending.map PRE_first_tail_x15_r0_body.kappa73.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh73 : PRE_first_tail_x15_r0_body.cx1_73.mlx.errh = PRE_first_tail_x15_r0_body.cx0_73.mlx.errh.map PRE_first_tail_x15_r0_body.kappa73.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles73 : PRE_first_tail_x15_r0_body.cx1_73.mlx.files = PRE_first_tail_x15_r0_body.cx0_73.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch73 : PRE_first_tail_x15_r0_body.cx1_73.mlx.arch = PRE_first_tail_x15_r0_body.cx0_73.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes73 : PRE_first_tail_x15_r0_body.cx1_73.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_73.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired73 : PRE_first_tail_x15_r0_body.cx1_73.mlx.wired = PRE_first_tail_x15_r0_body.cx0_73.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost73 : PRE_first_tail_x15_r0_body.cx1_73.host = PRE_first_tail_x15_r0_body.cx0_73.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd73`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn073 : PRE_first_tail_x15_r0_body.kd73.n0 = 2732455
kernel_rfl PRE_first_tail_x15_r0_body.ckn173 : PRE_first_tail_x15_r0_body.kd73.n1 = 2732457
kernel_rfl PRE_first_tail_x15_r0_body.ckheap73 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd73.heap).all (fun x => Nat.ble 2732455 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl73 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd73.heap.get (2732455 + j) = nth? PRE_first_tail_x15_r0_body.pl73 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja73 : Nat.ble 2732455 2732455 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn73 : Nat.ble 3200 3200 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD73 : Nat.ble 2732455 PRE_first_tail_x15_r0_body.kd73.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn73 : Nat.ble 19648 PRE_first_tail_x15_r0_body.kd73.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn73 : Nat.ble 16740 PRE_first_tail_x15_r0_body.kd73.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb73 : Nat.ble 19648 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap73 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd73.heap).all (Nat.ble (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd73 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd73.hnd).all (Nat.ble (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode73 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd73.node).all (Nat.ble (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix73 : Conv.FixOld (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa73 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja73) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn73) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD73) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn73) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn73) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb73) PRE_first_tail_x15_r0_body.fheap73 PRE_first_tail_x15_r0_body.fhnd73 PRE_first_tail_x15_r0_body.fnode73
kernel_rfl PRE_first_tail_x15_r0_body.fcxn73 : (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn73 : (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle073 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_73.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_73.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk73 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd73.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A73 : PRE_first_tail_x15_r0_body.cx1_73.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS73.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_73.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O73 : PRE_first_tail_x15_r0_body.cx1_73.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS73.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_73.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N73 : PRE_first_tail_x15_r0_body.cx1_73.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS73.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_73.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I73 : PRE_first_tail_x15_r0_body.cx1_73.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS73.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_73.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd73 : (PRE_first_tail_x15_r0_body.clo73 ++ PRE_first_tail_x15_r0_body.cln73 ++ PRE_first_tail_x15_r0_body.cli73 ++ PRE_first_tail_x15_r0_body.cwS73 ++ PRE_first_tail_x15_r0_body.cnS73 ++ PRE_first_tail_x15_r0_body.ciS73).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW73 : PRE_first_tail_x15_r0_body.cwS73.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo73.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI73 : PRE_first_tail_x15_r0_body.ciS73.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli73.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN73 : PRE_first_tail_x15_r0_body.cnS73.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF73 : PRE_first_tail_x15_r0_body.cln73.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh73 : PRE_first_tail_x15_r0_body.clo73.all (handleOK PRE_first_tail_x15_r0_body.kappa73 PRE_first_tail_x15_r0_body.P73.lo PRE_first_tail_x15_r0_body.cx0_73.mlx PRE_first_tail_x15_r0_body.cx1_73.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo73 : PRE_first_tail_x15_r0_body.clo73.map (fun h => PRE_first_tail_x15_r0_body.cx1_73.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa73.handle h)) = PRE_first_tail_x15_r0_body.clo73.map (fun h => (PRE_first_tail_x15_r0_body.cx0_73.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa73.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok73 : PRE_first_tail_x15_r0_body.clo73.all (objOK PRE_first_tail_x15_r0_body.kappa73 PRE_first_tail_x15_r0_body.P73.NL PRE_first_tail_x15_r0_body.cx0_73.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd73 : PRE_first_tail_x15_r0_body.cln73.all (nodeOKF PRE_first_tail_x15_r0_body.kappa73 PRE_first_tail_x15_r0_body.P73 PRE_first_tail_x15_r0_body.cx0_73.mlx PRE_first_tail_x15_r0_body.cx1_73.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp73 : ((PRE_first_tail_x15_r0_body.cln73.filter (fullB PRE_first_tail_x15_r0_body.P73))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_73.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa73.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln73.filter (fullB PRE_first_tail_x15_r0_body.P73))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_73.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa73.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI73 : incrB PRE_first_tail_x15_r0_body.kd73.nodeF (List.range' 16740 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK73 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd73.node).all (fun k => Nat.ble 16740 k && Nat.blt k 16740) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL73 : (PRE_first_tail_x15_r0_body.cln73.filter (Nat.ble PRE_first_tail_x15_r0_body.P73.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd73.nodeF i) && (Nat.blt i 16740 || Nat.ble PRE_first_tail_x15_r0_body.kd73.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord73 : (PRE_first_tail_x15_r0_body.cln73.filter (Nat.ble PRE_first_tail_x15_r0_body.P73.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd73.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd73.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd73.nodeF j) (PRE_first_tail_x15_r0_body.kd73.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow73 PRE_first_tail_x15_r0_body.cnn173 PRE_first_tail_x15_r0_body.fnordI73 PRE_first_tail_x15_r0_body.fnordK73 PRE_first_tail_x15_r0_body.fnordL73
kernel_rfl PRE_first_tail_x15_r0_body.fi73 : PRE_first_tail_x15_r0_body.cli73.all (pnB PRE_first_tail_x15_r0_body.cx0_73.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii73 : PRE_first_tail_x15_r0_body.cli73.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_73.mlx.items.get (PRE_first_tail_x15_r0_body.kappa73.node k) = (PRE_first_tail_x15_r0_body.cx0_73.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa73.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot73 (clean : Conv.NClean (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P73.NL) (cl : SSt (· < 3200) PRE_first_tail_x15_r0_body.cx0_73.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P73 3200 PRE_first_tail_x15_r0_body.kappa73 PRE_first_tail_x15_r0_body.kd73 PRE_first_tail_x15_r0_body.khinv73 PRE_first_tail_x15_r0_body.kninv73 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx PRE_first_tail_x15_r0_body.cx0_73.mlx PRE_first_tail_x15_r0_body.cx1_73.mlx (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo73 PRE_first_tail_x15_r0_body.cln73 PRE_first_tail_x15_r0_body.cli73 PRE_first_tail_x15_r0_body.cwS73 PRE_first_tail_x15_r0_body.cnS73 PRE_first_tail_x15_r0_body.ciS73 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh073, PRE_first_tail_x15_r0_body.cnh173, PRE_first_tail_x15_r0_body.cnn073, PRE_first_tail_x15_r0_body.cnn173, PRE_first_tail_x15_r0_body.cplo73, PRE_first_tail_x15_r0_body.ccnt73, PRE_first_tail_x15_r0_body.cnband73, PRE_first_tail_x15_r0_body.chbelow73, PRE_first_tail_x15_r0_body.chren73, PRE_first_tail_x15_r0_body.cband73, PRE_first_tail_x15_r0_body.cnh1pos73, PRE_first_tail_x15_r0_body.cnren73, PRE_first_tail_x15_r0_body.cnlow73, PRE_first_tail_x15_r0_body.cabs0a73, PRE_first_tail_x15_r0_body.cabs0b73, PRE_first_tail_x15_r0_body.ctok173, PRE_first_tail_x15_r0_body.cpend73, PRE_first_tail_x15_r0_body.cerrh73, PRE_first_tail_x15_r0_body.cfiles73, PRE_first_tail_x15_r0_body.carch73, PRE_first_tail_x15_r0_body.csizes73, PRE_first_tail_x15_r0_body.cwired73, PRE_first_tail_x15_r0_body.cfix73, clean, PRE_first_tail_x15_r0_body.fcxn73, PRE_first_tail_x15_r0_body.fcnn73, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle073, PRE_first_tail_x15_r0_body.fnk73, PRE_first_tail_x15_r0_body.ckA73, PRE_first_tail_x15_r0_body.cobjsK73, PRE_first_tail_x15_r0_body.cnodesK73, PRE_first_tail_x15_r0_body.citemsK73, PRE_first_tail_x15_r0_body.f1A73, PRE_first_tail_x15_r0_body.f1O73, PRE_first_tail_x15_r0_body.f1N73, PRE_first_tail_x15_r0_body.f1I73, PRE_first_tail_x15_r0_body.fbd73, PRE_first_tail_x15_r0_body.fincW73, PRE_first_tail_x15_r0_body.fincI73, PRE_first_tail_x15_r0_body.fincN73, PRE_first_tail_x15_r0_body.flnF73, PRE_first_tail_x15_r0_body.fh73, PRE_first_tail_x15_r0_body.fo73, PRE_first_tail_x15_r0_body.fok73, PRE_first_tail_x15_r0_body.fnd73, PRE_first_tail_x15_r0_body.fp73, PRE_first_tail_x15_r0_body.fnord73, PRE_first_tail_x15_r0_body.fi73, PRE_first_tail_x15_r0_body.fii73⟩
theorem PRE_first_tail_x15_r0_body.cnshift73 (clean : Conv.NClean (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P73.NL) (cl : SSt (· < 3200) PRE_first_tail_x15_r0_body.cx0_73.mlx) : NShift PRE_first_tail_x15_r0_body.P73 3200 PRE_first_tail_x15_r0_body.kappa73 PRE_first_tail_x15_r0_body.cx0_73 PRE_first_tail_x15_r0_body.cx1_73 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot73 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost73 (compact_a_eq PRE_first_tail_x15_r0_body.ckn073 PRE_first_tail_x15_r0_body.ckn173 PRE_first_tail_x15_r0_body.ckheap73 PRE_first_tail_x15_r0_body.ckpl73)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_73 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s714.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_73 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s714.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_73 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s714.ffi) = some PRE_first_tail_x15_r0_body.fxC_73
kernel_rfl PRE_first_tail_x15_r0_body.okrC_73 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s714.ffi) = some PRE_first_tail_x15_r0_body.krC_73
noncomputable def PRE_first_tail_x15_r0_body.fx0_73 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s716.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_73 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s716.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_73 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s716.ffi) = some PRE_first_tail_x15_r0_body.fx0_73
kernel_rfl PRE_first_tail_x15_r0_body.okr0_73 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s716.ffi) = some PRE_first_tail_x15_r0_body.kr0_73
noncomputable def PRE_first_tail_x15_r0_body.fx1_73 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s715.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_73 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s715.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_73 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s715.ffi) = some PRE_first_tail_x15_r0_body.fx1_73
kernel_rfl PRE_first_tail_x15_r0_body.okr1_73 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s715.ffi) = some PRE_first_tail_x15_r0_body.kr1_73
kernel_rfl PRE_first_tail_x15_r0_body.ff073 : PRE_first_tail_x15_r0_body.fx0_73 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_73 (PRE_first_tail_x15_r0_body.clo73.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_73.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff173 : PRE_first_tail_x15_r0_body.fx1_73 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_73 (PRE_first_tail_x15_r0_body.cwS73.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_73.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck73 : freedLB PRE_first_tail_x15_r0_body.kappa73 PRE_first_tail_x15_r0_body.cx0_73.mlx PRE_first_tail_x15_r0_body.fx0_73 PRE_first_tail_x15_r0_body.fx1_73 PRE_first_tail_x15_r0_body.clo73 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf073 : PRE_first_tail_x15_r0_body.kr0_73.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_73.flags (PRE_first_tail_x15_r0_body.clo73.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_73.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt073 : PRE_first_tail_x15_r0_body.kr0_73.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_73.targs (PRE_first_tail_x15_r0_body.clo73.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_73.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf173 : PRE_first_tail_x15_r0_body.kr1_73.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_73.flags (PRE_first_tail_x15_r0_body.cwS73.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_73.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt173 : PRE_first_tail_x15_r0_body.kr1_73.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_73.targs (PRE_first_tail_x15_r0_body.cwS73.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_73.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck73 : krecLB PRE_first_tail_x15_r0_body.kappa73 3200 PRE_first_tail_x15_r0_body.cx0_73.mlx PRE_first_tail_x15_r0_body.kr0_73 PRE_first_tail_x15_r0_body.kr1_73 PRE_first_tail_x15_r0_body.clo73 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn73 : Nat.ble 3200 3200 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge73 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s715.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s716.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR73 : pendRegB PRE_first_tail_x15_r0_body.kappa73 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe73 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s715.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift73 (clean : Conv.NClean (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P73.NL) (cl : SSt (· < 3200) PRE_first_tail_x15_r0_body.cx0_73.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_73.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_73.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_73.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_73.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P73 3200 PRE_first_tail_x15_r0_body.kappa73 PRE_first_tail_x15_r0_body.s716.ffi PRE_first_tail_x15_r0_body.s715.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift73 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue73, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp73 t ht),
    PRE_first_tail_x15_r0_body.cbridge73,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s716.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s715.ffi) (PRE_first_tail_x15_r0_body.cfoot73 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_73 PRE_first_tail_x15_r0_body.ofx1_73 hobjC PRE_first_tail_x15_r0_body.ff073 PRE_first_tail_x15_r0_body.ff173 PRE_first_tail_x15_r0_body.ffck73,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s716.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s715.ffi) (PRE_first_tail_x15_r0_body.cfoot73 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_73 PRE_first_tail_x15_r0_body.okr1_73 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn73) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf073 PRE_first_tail_x15_r0_body.fkt073 PRE_first_tail_x15_r0_body.fkf173 PRE_first_tail_x15_r0_body.fkt173 PRE_first_tail_x15_r0_body.fkck73,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh073 PRE_first_tail_x15_r0_body.cnh173 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe73) PRE_first_tail_x15_r0_body.cpendR73⟩

end Host.Load.Run.Tpl
end

section -- st73/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st73 0
host_stream_state PRE_first_tail_x15_r0_body.st73 1
host_stream_state PRE_first_tail_x15_r0_body.st73 2
end Host.Load.Run.Tpl
end

section -- Site73
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 73 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g73__g74` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s714`, the merged state `PRE_first_tail_x15_r0_body.s715`,
the site template `PRE_first_tail_x15_r0_body.st73` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s716`: the merge.
The footprint's facts are in `SiteF73`, the compaction's in `SiteC73`, `SiteK73`, `SiteNa73`, `SiteNb73`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso73 : PRE_first_tail_x15_r0_body.st73.s0 = { PRE_first_tail_x15_r0_body.s714 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs73 : List Frame := PRE_first_tail_x15_r0_body.s714.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_73 : PRE_first_tail_x15_r0_body.S714.tab.length = 3200
kernel_rfl PRE_first_tail_x15_r0_body.tab0_73 : PRE_first_tail_x15_r0_body.st73.S0.tab = PRE_first_tail_x15_r0_body.S714.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws73 : List Nat := [2249, 2250]
kernel_rfl PRE_first_tail_x15_r0_body.fresh73 : (PRE_first_tail_x15_r0_body.S714.tab.all fun e => PRE_first_tail_x15_r0_body.ws73.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S714.oracle.all fun q => PRE_first_tail_x15_r0_body.ws73.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab73 : PRE_first_tail_x15_r0_body.S715.tab = PRE_first_tail_x15_r0_body.S714.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws73
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen73 : PRE_first_tail_x15_r0_body.st73.S2.tab.length - PRE_first_tail_x15_r0_body.st73.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged73`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap73 : PRE_first_tail_x15_r0_body.s715.heap = PRE_first_tail_x15_r0_body.st73.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext73 : PRE_first_tail_x15_r0_body.s715.next = PRE_first_tail_x15_r0_body.st73.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl73 : PRE_first_tail_x15_r0_body.s715.ctl = PRE_first_tail_x15_r0_body.st73.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack73 : PRE_first_tail_x15_r0_body.s715.stack = PRE_first_tail_x15_r0_body.st73.s2.stack ++ PRE_first_tail_x15_r0_body.s714.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs73 : PRE_first_tail_x15_r0_body.s715.jobs = PRE_first_tail_x15_r0_body.st73.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi73 : PRE_first_tail_x15_r0_body.s715.ffi = PRE_first_tail_x15_r0_body.st73.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace73 : PRE_first_tail_x15_r0_body.s715.trace = PRE_first_tail_x15_r0_body.st73.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores73 : PRE_first_tail_x15_r0_body.s715.stores = PRE_first_tail_x15_r0_body.st73.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD73
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 73 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived73 : PRE_first_tail_x15_r0_body.nr73.map (fun r => nth? PRE_first_tail_x15_r0_body.st73.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo73 : PRE_first_tail_x15_r0_body.nr73.all (Nat.ble 3200) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj73 : PRE_first_tail_x15_r0_body.cws73.all (fun c => !PRE_first_tail_x15_r0_body.ws73.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ73 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws73 PRE_first_tail_x15_r0_body.crs73 PRE_first_tail_x15_r0_body.ws73

end Host.Load.Run.Tpl
end

section -- st73/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st73`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st73.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st73.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st73.s2.heap PRE_first_tail_x15_r0_body.st73.wrR ++ freshOf PRE_first_tail_x15_r0_body.st73.s2.heap PRE_first_tail_x15_r0_body.st73.s0.next PRE_first_tail_x15_r0_body.st73.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st73.wr : List Nat := PRE_first_tail_x15_r0_body.st73.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st73.heapFoot : PRE_first_tail_x15_r0_body.st73.s2.heap = setAll PRE_first_tail_x15_r0_body.st73.s0.heap PRE_first_tail_x15_r0_body.st73.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st73.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st73.s0.next PRE_first_tail_x15_r0_body.st73.s2.next = true
theorem PRE_first_tail_x15_r0_body.st73.grows : PRE_first_tail_x15_r0_body.st73.s0.next ≤ PRE_first_tail_x15_r0_body.st73.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st73.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st73.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st73.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st73.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st73.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st73.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st73.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st73.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st73.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st73.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st73.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st73.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st73.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st73.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st73.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st73.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st73.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st73.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st73.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st73.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st73.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st73.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st73.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st73.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st73.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st73.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st73.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st73.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st73.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st73.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st73.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st73.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF73
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 73 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB73 : nodupT PRE_first_tail_x15_r0_body.st73.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup73 : PRE_first_tail_x15_r0_body.st73.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB73).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB73 : PRE_first_tail_x15_r0_body.st73.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound73 : ∀ b ∈ PRE_first_tail_x15_r0_body.st73.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB73 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr73 := PRE_first_tail_x15_r0_body.st73.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq73 : PRE_first_tail_x15_r0_body.st73.s2.trace = PRE_first_tail_x15_r0_body.trFr73 ++ PRE_first_tail_x15_r0_body.st73.s0.trace
theorem PRE_first_tail_x15_r0_body.trace73 : ∃ fr, PRE_first_tail_x15_r0_body.st73.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st73.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq73⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide73 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB73 : (PRE_first_tail_x15_r0_body.wide73.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st73.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix73 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide73, WFix Map.id (Present PRE_first_tail_x15_r0_body.st73.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB73 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL73
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 73 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s715`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO73 : PRE_first_tail_x15_r0_body.st73.S0.oracle = PRE_first_tail_x15_r0_body.st73.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B73 : PRE_first_tail_x15_r0_body.st73.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st73.s0.next || (PRE_first_tail_x15_r0_body.st73.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot73 : Conv.StageFoot PRE_first_tail_x15_r0_body.st73.wr PRE_first_tail_x15_r0_body.st73.s0 PRE_first_tail_x15_r0_body.st73.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st73.heapFoot PRE_first_tail_x15_r0_body.wrNodup73 PRE_first_tail_x15_r0_body.wrBound73 PRE_first_tail_x15_r0_body.wr0B73 PRE_first_tail_x15_r0_body.st73.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged73 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st73.F.S → PRE_first_tail_x15_r0_body.st73.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st73.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st73.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs73 PRE_first_tail_x15_r0_body.st73.wr PRE_first_tail_x15_r0_body.s714 PRE_first_tail_x15_r0_body.st73.s2 PRE_first_tail_x15_r0_body.st73.s0
      PRE_first_tail_x15_r0_body.st73.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st73.F FR W stk M ν K PRE_first_tail_x15_r0_body.s715 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso73 PRE_first_tail_x15_r0_body.stFoot73 PRE_first_tail_x15_r0_body.wrNodup73 PRE_first_tail_x15_r0_body.wrBound73 PRE_first_tail_x15_r0_body.trace73 PRE_first_tail_x15_r0_body.mheap73
    PRE_first_tail_x15_r0_body.mnext73 PRE_first_tail_x15_r0_body.mctl73 PRE_first_tail_x15_r0_body.mstack73 PRE_first_tail_x15_r0_body.mjobs73 PRE_first_tail_x15_r0_body.mffi73 PRE_first_tail_x15_r0_body.mtrace73 PRE_first_tail_x15_r0_body.mstores73 h

def PRE_first_tail_x15_r0_body.arrEl73_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE73_2665 : arrOf PRE_first_tail_x15_r0_body.s715 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl73_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA73_2665 : isArrB PRE_first_tail_x15_r0_body.s715 2665 = true
theorem PRE_first_tail_x15_r0_body.arr73_2665 : ∃ o, PRE_first_tail_x15_r0_body.s715.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl73_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE73_2665 PRE_first_tail_x15_r0_body.arrA73_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN73_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl73_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR73_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl73_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN73_2665

def PRE_first_tail_x15_r0_body.arrEl73_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE73_2673467 : arrOf PRE_first_tail_x15_r0_body.s715 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl73_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA73_2673467 : isArrB PRE_first_tail_x15_r0_body.s715 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr73_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s715.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl73_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE73_2673467 PRE_first_tail_x15_r0_body.arrA73_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN73_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl73_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR73_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl73_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN73_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k73 : isArrB PRE_first_tail_x15_r0_body.s715 4910 = false
theorem PRE_first_tail_x15_r0_body.keep73 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s715 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k73 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr73_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl73_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ73
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 73 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s714`, the merged
state `PRE_first_tail_x15_r0_body.s715`, the canonical state `PRE_first_tail_x15_r0_body.s716`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl73 : PRE_first_tail_x15_r0_body.pl73.all (Nat.ble PRE_first_tail_x15_r0_body.s714.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd73 : nodupT PRE_first_tail_x15_r0_body.pl73 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn173 : Nat.ble PRE_first_tail_x15_r0_body.s714.next 2732457 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst73 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s714.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn73 : PRE_first_tail_x15_r0_body.s716.next = PRE_first_tail_x15_r0_body.s714.next + PRE_first_tail_x15_r0_body.pl73.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn73 : PRE_first_tail_x15_r0_body.s715.next = 2732457
kernel_rfl PRE_first_tail_x15_r0_body.zgrow73 : Nat.ble PRE_first_tail_x15_r0_body.s716.next PRE_first_tail_x15_r0_body.s715.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh73 : PRE_first_tail_x15_r0_body.S714.tab.all (fun e => PRE_first_tail_x15_r0_body.cws73.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd73 : nodupT PRE_first_tail_x15_r0_body.cws73 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi73 : PRE_first_tail_x15_r0_body.nr73.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S715.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt73 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s714.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg73_2665 : PRE_first_tail_x15_r0_body.s716.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s716 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk73_2665 : (objOf PRE_first_tail_x15_r0_body.s716 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm73_2665 : PRE_first_tail_x15_r0_body.s715.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa73.obj (objOf PRE_first_tail_x15_r0_body.s716 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s715 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg73_2673467 : PRE_first_tail_x15_r0_body.s716.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s716 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk73_2673467 : (objOf PRE_first_tail_x15_r0_body.s716 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm73_2673467 : PRE_first_tail_x15_r0_body.s715.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa73.obj (objOf PRE_first_tail_x15_r0_body.s716 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s715 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw73_4910 : (PRE_first_tail_x15_r0_body.s716.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw73_2673472 : (PRE_first_tail_x15_r0_body.s716.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw73_2673473 : (PRE_first_tail_x15_r0_body.s716.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd73 : PRE_first_tail_x15_r0_body.cl73.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr73 : PRE_first_tail_x15_r0_body.st73.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s714.next || PRE_first_tail_x15_r0_body.cl73.contains b) = true
def PRE_first_tail_x15_r0_body.zl73 : List Nat := PRE_first_tail_x15_r0_body.cl73.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE73 : PRE_first_tail_x15_r0_body.zl73.map (fun a => PRE_first_tail_x15_r0_body.s715.heap.get (PRE_first_tail_x15_r0_body.kappa73.a a)) = PRE_first_tail_x15_r0_body.zl73.map (fun a => (PRE_first_tail_x15_r0_body.s716.heap.get a).map PRE_first_tail_x15_r0_body.kappa73.hobj)
theorem PRE_first_tail_x15_r0_body.zimg73 : HeapImg PRE_first_tail_x15_r0_body.kappa73 PRE_first_tail_x15_r0_body.s716 PRE_first_tail_x15_r0_body.s715 PRE_first_tail_x15_r0_body.zl73 := PRE_first_tail_x15_r0_body.zimgE73
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl73 : PRE_first_tail_x15_r0_body.s715.ctl = PRE_first_tail_x15_r0_body.kappa73.ctl PRE_first_tail_x15_r0_body.s716.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack73 : PRE_first_tail_x15_r0_body.s715.stack = PRE_first_tail_x15_r0_body.s716.stack.map PRE_first_tail_x15_r0_body.kappa73.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs73 : PRE_first_tail_x15_r0_body.s715.jobs = PRE_first_tail_x15_r0_body.s716.jobs.map PRE_first_tail_x15_r0_body.kappa73.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores73 : PRE_first_tail_x15_r0_body.s715.stores = PRE_first_tail_x15_r0_body.kappa73.stores PRE_first_tail_x15_r0_body.s716.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots73 : checkRootsSupp PRE_first_tail_x15_r0_body.s716 3200 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC73 : PRE_first_tail_x15_r0_body.S714.tab.length + PRE_first_tail_x15_r0_body.cws73.length = 3200
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap73 : PRE_first_tail_x15_r0_body.kappa73 = Conv.Map.compact PRE_first_tail_x15_r0_body.s714.next 2732457 PRE_first_tail_x15_r0_body.S714.tab.length PRE_first_tail_x15_r0_body.pl73 (PRE_first_tail_x15_r0_body.nr73.map NumV.ref) PRE_first_tail_x15_r0_body.kd73.big
  PRE_first_tail_x15_r0_body.kd73.region PRE_first_tail_x15_r0_body.kd73.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin73 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s716.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc73 : Conv.jcleanListB (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s716 PRE_first_tail_x15_r0_body.cl73 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB73 : noBigRootsP (fun i => !Conv.oldBigB (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s716.trace PRE_first_tail_x15_r0_body.s716 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm73 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16740 = true
theorem PRE_first_tail_x15_r0_body.cjcl73 (h : Conv.JClean (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s714) : Conv.JClean (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s716 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle73)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap73 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd73 a ha)) PRE_first_tail_x15_r0_body.zjc73

end Host.Load.Run.Tpl
end

section -- st73/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st73.bodyLast from PRE_first_tail_x15_r0_body.st73.s1 to PRE_first_tail_x15_r0_body.st73.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st73.F PRE_first_tail_x15_r0_body.st73.s1).run PRE_first_tail_x15_r0_body.st73.S1 = some (PRE_first_tail_x15_r0_body.st73.s2, PRE_first_tail_x15_r0_body.st73.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st73.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st73.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st73.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st73.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st73/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st73.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st73.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st73.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st73.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st73.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st73.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st73.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st73.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st73.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st73.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st73.s0 PRE_first_tail_x15_r0_body.st73.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st73.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st73.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st73.s1 PRE_first_tail_x15_r0_body.st73.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st73/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st73.bodyK0F from PRE_first_tail_x15_r0_body.st73.s0 to PRE_first_tail_x15_r0_body.st73.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st73.F (PRE_first_tail_x15_r0_body.st73.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st73.ks 0).getD 0) PRE_first_tail_x15_r0_body.st73.s0 PRE_first_tail_x15_r0_body.st73.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st73.s1, PRE_first_tail_x15_r0_body.st73.S1)
theorem PRE_first_tail_x15_r0_body.st73.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st73.F (PRE_first_tail_x15_r0_body.st73.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st73.ks 0).getD 0) PRE_first_tail_x15_r0_body.st73.s0 PRE_first_tail_x15_r0_body.st73.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st73.s1, PRE_first_tail_x15_r0_body.st73.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st73.bodyOkLN_ok PRE_first_tail_x15_r0_body.st73.bodyK0F
end Host.Load.Run.Tpl
end

section -- st73/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st73.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st73.F (PRE_first_tail_x15_r0_body.st73.bodyOkL bytes rows) 27 PRE_first_tail_x15_r0_body.st73.s0 PRE_first_tail_x15_r0_body.st73.S0 = some (PRE_first_tail_x15_r0_body.st73.s1, PRE_first_tail_x15_r0_body.st73.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st73.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st73.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st73.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st73.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st73.F (PRE_first_tail_x15_r0_body.st73.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st73.s0
  S0 := PRE_first_tail_x15_r0_body.st73.S0
  s1 := PRE_first_tail_x15_r0_body.st73.s1
  S1 := PRE_first_tail_x15_r0_body.st73.S1
  s2 := PRE_first_tail_x15_r0_body.st73.s2
  S2 := PRE_first_tail_x15_r0_body.st73.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st73.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st73.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st73.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st73.bodyHalt
  last := PRE_first_tail_x15_r0_body.st73.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st73.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC74
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 74 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s720` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa74` into the merged state
`PRE_first_tail_x15_r0_body.s719`. -/

def PRE_first_tail_x15_r0_body.pl74 : List Nat := [2732753]
def PRE_first_tail_x15_r0_body.nr74 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd74 : RData :=
  ⟨2732744, 2732754, Stage.setAll PTrie.nil [(2732743, 2732753)], Stage.setAll PTrie.nil [],
   19655, 19655, 16744, 16744, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa74 : Map :=
  Conv.Map.compact 2732743 2732754 3217 PRE_first_tail_x15_r0_body.pl74 (PRE_first_tail_x15_r0_body.nr74.map NumV.ref) PRE_first_tail_x15_r0_body.kd74.big
    PRE_first_tail_x15_r0_body.kd74.region PRE_first_tail_x15_r0_body.kd74.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws74 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs74 : List SymE := PRE_first_tail_x15_r0_body.nr74.map fun r => (nth? PRE_first_tail_x15_r0_body.S719.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta74 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws74 PRE_first_tail_x15_r0_body.crs74
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB74 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab74 : PRE_first_tail_x15_r0_body.S720.tab = PRE_first_tail_x15_r0_body.S718.tab ++ PRE_first_tail_x15_r0_body.cws74.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace74 : PRE_first_tail_x15_r0_body.s720.trace = PRE_first_tail_x15_r0_body.s718.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext74 : PRE_first_tail_x15_r0_body.s720.next = 2732744
kernel_rfl PRE_first_tail_x15_r0_body.ccounters74 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s720.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s720.ffi).mlx.nnext) = (19655, 16744)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue74 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s719.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s720.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa74.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp74 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s720.ffi).mlx.tokens.all (bSN 3217) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean74 : Conv.cleanListB 19655 131072 (fun r => Nat.ble 78620 r) PRE_first_tail_x15_r0_body.s720
    (PRE_first_tail_x15_r0_body.wrB74 ++ (List.range 1).map (2732743 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs74 : bigsOutB 19655 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s720.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK74
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl74`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl74 : List Nat := [2665, 2673467, 2732743]
def PRE_first_tail_x15_r0_body.clo74 : List Nat := []
def PRE_first_tail_x15_r0_body.cln74 : List Nat := []
def PRE_first_tail_x15_r0_body.cli74 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap74 : PRE_first_tail_x15_r0_body.s720.heap = Stage.setAll PRE_first_tail_x15_r0_body.s718.heap (PRE_first_tail_x15_r0_body.cl74.filterMap fun a => (PRE_first_tail_x15_r0_body.s720.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe74 : Nat.ble PRE_first_tail_x15_r0_body.s718.next PRE_first_tail_x15_r0_body.s720.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP74 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s718 PRE_first_tail_x15_r0_body.s720 PRE_first_tail_x15_r0_body.cl74 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp74 : Conv.suppListB PRE_first_tail_x15_r0_body.s720 3217 PRE_first_tail_x15_r0_body.cl74 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound74 : Conv.boundListB PRE_first_tail_x15_r0_body.s720 PRE_first_tail_x15_r0_body.cl74 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK74 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s720.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln74.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s720.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK74 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s720.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo74.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s720.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK74 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s720.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli74.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s720.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst74 : Conv.sstListB 3217 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s720.ffi).mlx PRE_first_tail_x15_r0_body.cln74 PRE_first_tail_x15_r0_body.clo74 PRE_first_tail_x15_r0_body.cli74 = true

end Host.Load.Run.Tpl
end

section -- SiteCl74
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA74 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s720.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo74.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s720.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd74 : (PRE_first_tail_x15_r0_body.clo74 ++ PRE_first_tail_x15_r0_body.cln74 ++ PRE_first_tail_x15_r0_body.cli74).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle74 : Conv.Cnt.leB (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt) (⟨19655, 16744, 2732744, 3217⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck74 : Conv.ncleanListB (⟨19655, 16744, 2732744, 3217⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s720.ffi).mlx PRE_first_tail_x15_r0_body.clo74 PRE_first_tail_x15_r0_body.cln74 PRE_first_tail_x15_r0_body.cli74 = true
theorem PRE_first_tail_x15_r0_body.cncl74 (h : Conv.NClean (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx) : Conv.NClean (⟨19655, 16744, 2732744, 3217⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s720.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle74 PRE_first_tail_x15_r0_body.ckA74 PRE_first_tail_x15_r0_body.cobjsK74 PRE_first_tail_x15_r0_body.cnodesK74 PRE_first_tail_x15_r0_body.citemsK74 PRE_first_tail_x15_r0_body.cbd74 PRE_first_tail_x15_r0_body.cck74

end Host.Load.Run.Tpl
end

section -- SiteS74
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 74 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc74 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P74 : LoadP := PRE_first_tail_x15_r0_body.Pc74.raise 16744
kernel_rfl PRE_first_tail_x15_r0_body.craise74 : Nat.ble PRE_first_tail_x15_r0_body.Pc74.N0 16744 = true
theorem PRE_first_tail_x15_r0_body.raised74 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc74 PRE_first_tail_x15_r0_body.P74 :=
  .inr ⟨16744, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise74, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_74 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s720.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_74 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s719.ffi)
def PRE_first_tail_x15_r0_body.khinv74 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv74 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS74 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS74 : List Nat := List.range' 16744 0
def PRE_first_tail_x15_r0_body.ciS74 : List Nat := [] ++ List.range' 16744 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh074 : PRE_first_tail_x15_r0_body.kd74.nh0 = PRE_first_tail_x15_r0_body.cx0_74.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh174 : PRE_first_tail_x15_r0_body.kd74.nh1 = PRE_first_tail_x15_r0_body.cx1_74.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn074 : PRE_first_tail_x15_r0_body.kd74.nn0 = PRE_first_tail_x15_r0_body.cx0_74.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn174 : PRE_first_tail_x15_r0_body.kd74.nn1 = PRE_first_tail_x15_r0_body.cx1_74.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo74 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P74.lo && Nat.ble PRE_first_tail_x15_r0_body.P74.lo PRE_first_tail_x15_r0_body.cx0_74.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P74.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P74.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt74 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_74.mlx.next PRE_first_tail_x15_r0_body.cx1_74.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_74.mlx.nnext PRE_first_tail_x15_r0_body.cx1_74.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband74 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P74.NL && Nat.ble PRE_first_tail_x15_r0_body.P74.NL PRE_first_tail_x15_r0_body.P74.N0 && Nat.ble PRE_first_tail_x15_r0_body.P74.N0 PRE_first_tail_x15_r0_body.cx0_74.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow74 : PRE_first_tail_x15_r0_body.kd74.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren74 : checkRenG PRE_first_tail_x15_r0_body.kd74.hnd PRE_first_tail_x15_r0_body.khinv74 (phB PRE_first_tail_x15_r0_body.cx0_74.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband74 : PRE_first_tail_x15_r0_body.kd74.checkBand PRE_first_tail_x15_r0_body.P74.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos74 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd74.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren74 : checkRenG PRE_first_tail_x15_r0_body.kd74.node PRE_first_tail_x15_r0_body.kninv74 (pnB PRE_first_tail_x15_r0_body.cx0_74.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow74 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd74.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P74.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd74.nodeF j) PRE_first_tail_x15_r0_body.cx1_74.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a74 : PRE_first_tail_x15_r0_body.cx0_74.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b74 : PRE_first_tail_x15_r0_body.cx0_74.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok174 : PRE_first_tail_x15_r0_body.cx1_74.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend74 : PRE_first_tail_x15_r0_body.cx1_74.mlx.pending = PRE_first_tail_x15_r0_body.cx0_74.mlx.pending.map PRE_first_tail_x15_r0_body.kappa74.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh74 : PRE_first_tail_x15_r0_body.cx1_74.mlx.errh = PRE_first_tail_x15_r0_body.cx0_74.mlx.errh.map PRE_first_tail_x15_r0_body.kappa74.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles74 : PRE_first_tail_x15_r0_body.cx1_74.mlx.files = PRE_first_tail_x15_r0_body.cx0_74.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch74 : PRE_first_tail_x15_r0_body.cx1_74.mlx.arch = PRE_first_tail_x15_r0_body.cx0_74.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes74 : PRE_first_tail_x15_r0_body.cx1_74.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_74.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired74 : PRE_first_tail_x15_r0_body.cx1_74.mlx.wired = PRE_first_tail_x15_r0_body.cx0_74.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost74 : PRE_first_tail_x15_r0_body.cx1_74.host = PRE_first_tail_x15_r0_body.cx0_74.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd74`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn074 : PRE_first_tail_x15_r0_body.kd74.n0 = 2732744
kernel_rfl PRE_first_tail_x15_r0_body.ckn174 : PRE_first_tail_x15_r0_body.kd74.n1 = 2732754
kernel_rfl PRE_first_tail_x15_r0_body.ckheap74 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd74.heap).all (fun x => Nat.ble 2732743 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl74 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd74.heap.get (2732743 + j) = nth? PRE_first_tail_x15_r0_body.pl74 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja74 : Nat.ble 2732743 2732743 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn74 : Nat.ble 3217 3217 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD74 : Nat.ble 2732743 PRE_first_tail_x15_r0_body.kd74.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn74 : Nat.ble 19655 PRE_first_tail_x15_r0_body.kd74.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn74 : Nat.ble 16744 PRE_first_tail_x15_r0_body.kd74.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb74 : Nat.ble 19655 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap74 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd74.heap).all (Nat.ble (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd74 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd74.hnd).all (Nat.ble (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode74 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd74.node).all (Nat.ble (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix74 : Conv.FixOld (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa74 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja74) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn74) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD74) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn74) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn74) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb74) PRE_first_tail_x15_r0_body.fheap74 PRE_first_tail_x15_r0_body.fhnd74 PRE_first_tail_x15_r0_body.fnode74
kernel_rfl PRE_first_tail_x15_r0_body.fcxn74 : (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn74 : (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle074 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_74.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_74.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk74 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd74.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A74 : PRE_first_tail_x15_r0_body.cx1_74.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS74.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_74.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O74 : PRE_first_tail_x15_r0_body.cx1_74.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS74.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_74.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N74 : PRE_first_tail_x15_r0_body.cx1_74.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS74.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_74.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I74 : PRE_first_tail_x15_r0_body.cx1_74.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS74.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_74.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd74 : (PRE_first_tail_x15_r0_body.clo74 ++ PRE_first_tail_x15_r0_body.cln74 ++ PRE_first_tail_x15_r0_body.cli74 ++ PRE_first_tail_x15_r0_body.cwS74 ++ PRE_first_tail_x15_r0_body.cnS74 ++ PRE_first_tail_x15_r0_body.ciS74).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW74 : PRE_first_tail_x15_r0_body.cwS74.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo74.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI74 : PRE_first_tail_x15_r0_body.ciS74.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli74.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN74 : PRE_first_tail_x15_r0_body.cnS74.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF74 : PRE_first_tail_x15_r0_body.cln74.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh74 : PRE_first_tail_x15_r0_body.clo74.all (handleOK PRE_first_tail_x15_r0_body.kappa74 PRE_first_tail_x15_r0_body.P74.lo PRE_first_tail_x15_r0_body.cx0_74.mlx PRE_first_tail_x15_r0_body.cx1_74.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo74 : PRE_first_tail_x15_r0_body.clo74.map (fun h => PRE_first_tail_x15_r0_body.cx1_74.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa74.handle h)) = PRE_first_tail_x15_r0_body.clo74.map (fun h => (PRE_first_tail_x15_r0_body.cx0_74.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa74.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok74 : PRE_first_tail_x15_r0_body.clo74.all (objOK PRE_first_tail_x15_r0_body.kappa74 PRE_first_tail_x15_r0_body.P74.NL PRE_first_tail_x15_r0_body.cx0_74.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd74 : PRE_first_tail_x15_r0_body.cln74.all (nodeOKF PRE_first_tail_x15_r0_body.kappa74 PRE_first_tail_x15_r0_body.P74 PRE_first_tail_x15_r0_body.cx0_74.mlx PRE_first_tail_x15_r0_body.cx1_74.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp74 : ((PRE_first_tail_x15_r0_body.cln74.filter (fullB PRE_first_tail_x15_r0_body.P74))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_74.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa74.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln74.filter (fullB PRE_first_tail_x15_r0_body.P74))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_74.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa74.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI74 : incrB PRE_first_tail_x15_r0_body.kd74.nodeF (List.range' 16744 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK74 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd74.node).all (fun k => Nat.ble 16744 k && Nat.blt k 16744) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL74 : (PRE_first_tail_x15_r0_body.cln74.filter (Nat.ble PRE_first_tail_x15_r0_body.P74.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd74.nodeF i) && (Nat.blt i 16744 || Nat.ble PRE_first_tail_x15_r0_body.kd74.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord74 : (PRE_first_tail_x15_r0_body.cln74.filter (Nat.ble PRE_first_tail_x15_r0_body.P74.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd74.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd74.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd74.nodeF j) (PRE_first_tail_x15_r0_body.kd74.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow74 PRE_first_tail_x15_r0_body.cnn174 PRE_first_tail_x15_r0_body.fnordI74 PRE_first_tail_x15_r0_body.fnordK74 PRE_first_tail_x15_r0_body.fnordL74
kernel_rfl PRE_first_tail_x15_r0_body.fi74 : PRE_first_tail_x15_r0_body.cli74.all (pnB PRE_first_tail_x15_r0_body.cx0_74.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii74 : PRE_first_tail_x15_r0_body.cli74.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_74.mlx.items.get (PRE_first_tail_x15_r0_body.kappa74.node k) = (PRE_first_tail_x15_r0_body.cx0_74.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa74.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot74 (clean : Conv.NClean (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P74.NL) (cl : SSt (· < 3217) PRE_first_tail_x15_r0_body.cx0_74.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P74 3217 PRE_first_tail_x15_r0_body.kappa74 PRE_first_tail_x15_r0_body.kd74 PRE_first_tail_x15_r0_body.khinv74 PRE_first_tail_x15_r0_body.kninv74 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx PRE_first_tail_x15_r0_body.cx0_74.mlx PRE_first_tail_x15_r0_body.cx1_74.mlx (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo74 PRE_first_tail_x15_r0_body.cln74 PRE_first_tail_x15_r0_body.cli74 PRE_first_tail_x15_r0_body.cwS74 PRE_first_tail_x15_r0_body.cnS74 PRE_first_tail_x15_r0_body.ciS74 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh074, PRE_first_tail_x15_r0_body.cnh174, PRE_first_tail_x15_r0_body.cnn074, PRE_first_tail_x15_r0_body.cnn174, PRE_first_tail_x15_r0_body.cplo74, PRE_first_tail_x15_r0_body.ccnt74, PRE_first_tail_x15_r0_body.cnband74, PRE_first_tail_x15_r0_body.chbelow74, PRE_first_tail_x15_r0_body.chren74, PRE_first_tail_x15_r0_body.cband74, PRE_first_tail_x15_r0_body.cnh1pos74, PRE_first_tail_x15_r0_body.cnren74, PRE_first_tail_x15_r0_body.cnlow74, PRE_first_tail_x15_r0_body.cabs0a74, PRE_first_tail_x15_r0_body.cabs0b74, PRE_first_tail_x15_r0_body.ctok174, PRE_first_tail_x15_r0_body.cpend74, PRE_first_tail_x15_r0_body.cerrh74, PRE_first_tail_x15_r0_body.cfiles74, PRE_first_tail_x15_r0_body.carch74, PRE_first_tail_x15_r0_body.csizes74, PRE_first_tail_x15_r0_body.cwired74, PRE_first_tail_x15_r0_body.cfix74, clean, PRE_first_tail_x15_r0_body.fcxn74, PRE_first_tail_x15_r0_body.fcnn74, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle074, PRE_first_tail_x15_r0_body.fnk74, PRE_first_tail_x15_r0_body.ckA74, PRE_first_tail_x15_r0_body.cobjsK74, PRE_first_tail_x15_r0_body.cnodesK74, PRE_first_tail_x15_r0_body.citemsK74, PRE_first_tail_x15_r0_body.f1A74, PRE_first_tail_x15_r0_body.f1O74, PRE_first_tail_x15_r0_body.f1N74, PRE_first_tail_x15_r0_body.f1I74, PRE_first_tail_x15_r0_body.fbd74, PRE_first_tail_x15_r0_body.fincW74, PRE_first_tail_x15_r0_body.fincI74, PRE_first_tail_x15_r0_body.fincN74, PRE_first_tail_x15_r0_body.flnF74, PRE_first_tail_x15_r0_body.fh74, PRE_first_tail_x15_r0_body.fo74, PRE_first_tail_x15_r0_body.fok74, PRE_first_tail_x15_r0_body.fnd74, PRE_first_tail_x15_r0_body.fp74, PRE_first_tail_x15_r0_body.fnord74, PRE_first_tail_x15_r0_body.fi74, PRE_first_tail_x15_r0_body.fii74⟩
theorem PRE_first_tail_x15_r0_body.cnshift74 (clean : Conv.NClean (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P74.NL) (cl : SSt (· < 3217) PRE_first_tail_x15_r0_body.cx0_74.mlx) : NShift PRE_first_tail_x15_r0_body.P74 3217 PRE_first_tail_x15_r0_body.kappa74 PRE_first_tail_x15_r0_body.cx0_74 PRE_first_tail_x15_r0_body.cx1_74 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot74 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost74 (compact_a_eq PRE_first_tail_x15_r0_body.ckn074 PRE_first_tail_x15_r0_body.ckn174 PRE_first_tail_x15_r0_body.ckheap74 PRE_first_tail_x15_r0_body.ckpl74)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_74 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s718.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_74 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s718.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_74 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s718.ffi) = some PRE_first_tail_x15_r0_body.fxC_74
kernel_rfl PRE_first_tail_x15_r0_body.okrC_74 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s718.ffi) = some PRE_first_tail_x15_r0_body.krC_74
noncomputable def PRE_first_tail_x15_r0_body.fx0_74 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s720.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_74 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s720.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_74 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s720.ffi) = some PRE_first_tail_x15_r0_body.fx0_74
kernel_rfl PRE_first_tail_x15_r0_body.okr0_74 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s720.ffi) = some PRE_first_tail_x15_r0_body.kr0_74
noncomputable def PRE_first_tail_x15_r0_body.fx1_74 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s719.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_74 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s719.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_74 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s719.ffi) = some PRE_first_tail_x15_r0_body.fx1_74
kernel_rfl PRE_first_tail_x15_r0_body.okr1_74 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s719.ffi) = some PRE_first_tail_x15_r0_body.kr1_74
kernel_rfl PRE_first_tail_x15_r0_body.ff074 : PRE_first_tail_x15_r0_body.fx0_74 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_74 (PRE_first_tail_x15_r0_body.clo74.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_74.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff174 : PRE_first_tail_x15_r0_body.fx1_74 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_74 (PRE_first_tail_x15_r0_body.cwS74.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_74.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck74 : freedLB PRE_first_tail_x15_r0_body.kappa74 PRE_first_tail_x15_r0_body.cx0_74.mlx PRE_first_tail_x15_r0_body.fx0_74 PRE_first_tail_x15_r0_body.fx1_74 PRE_first_tail_x15_r0_body.clo74 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf074 : PRE_first_tail_x15_r0_body.kr0_74.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_74.flags (PRE_first_tail_x15_r0_body.clo74.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_74.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt074 : PRE_first_tail_x15_r0_body.kr0_74.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_74.targs (PRE_first_tail_x15_r0_body.clo74.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_74.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf174 : PRE_first_tail_x15_r0_body.kr1_74.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_74.flags (PRE_first_tail_x15_r0_body.cwS74.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_74.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt174 : PRE_first_tail_x15_r0_body.kr1_74.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_74.targs (PRE_first_tail_x15_r0_body.cwS74.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_74.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck74 : krecLB PRE_first_tail_x15_r0_body.kappa74 3217 PRE_first_tail_x15_r0_body.cx0_74.mlx PRE_first_tail_x15_r0_body.kr0_74 PRE_first_tail_x15_r0_body.kr1_74 PRE_first_tail_x15_r0_body.clo74 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn74 : Nat.ble 3217 3217 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge74 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s719.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s720.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR74 : pendRegB PRE_first_tail_x15_r0_body.kappa74 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s720.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe74 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s720.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s719.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift74 (clean : Conv.NClean (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P74.NL) (cl : SSt (· < 3217) PRE_first_tail_x15_r0_body.cx0_74.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_74.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_74.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_74.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_74.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P74 3217 PRE_first_tail_x15_r0_body.kappa74 PRE_first_tail_x15_r0_body.s720.ffi PRE_first_tail_x15_r0_body.s719.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift74 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue74, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp74 t ht),
    PRE_first_tail_x15_r0_body.cbridge74,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s720.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s719.ffi) (PRE_first_tail_x15_r0_body.cfoot74 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_74 PRE_first_tail_x15_r0_body.ofx1_74 hobjC PRE_first_tail_x15_r0_body.ff074 PRE_first_tail_x15_r0_body.ff174 PRE_first_tail_x15_r0_body.ffck74,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s720.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s719.ffi) (PRE_first_tail_x15_r0_body.cfoot74 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_74 PRE_first_tail_x15_r0_body.okr1_74 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn74) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf074 PRE_first_tail_x15_r0_body.fkt074 PRE_first_tail_x15_r0_body.fkf174 PRE_first_tail_x15_r0_body.fkt174 PRE_first_tail_x15_r0_body.fkck74,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh074 PRE_first_tail_x15_r0_body.cnh174 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe74) PRE_first_tail_x15_r0_body.cpendR74⟩

end Host.Load.Run.Tpl
end

section -- st74/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st74 0
host_stream_state PRE_first_tail_x15_r0_body.st74 1
host_stream_state PRE_first_tail_x15_r0_body.st74 2
end Host.Load.Run.Tpl
end

section -- Site74
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 74 of chain `PRE_first_tail_x15_r0_body`: `plan__g74__g75` (`plan`), the call state `PRE_first_tail_x15_r0_body.s718`, the merged state `PRE_first_tail_x15_r0_body.s719`,
the site template `PRE_first_tail_x15_r0_body.st74` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s720`: the merge.
The footprint's facts are in `SiteF74`, the compaction's in `SiteC74`, `SiteK74`, `SiteNa74`, `SiteNb74`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso74 : PRE_first_tail_x15_r0_body.st74.s0 = { PRE_first_tail_x15_r0_body.s718 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs74 : List Frame := PRE_first_tail_x15_r0_body.s718.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_74 : PRE_first_tail_x15_r0_body.S718.tab.length = 3217
kernel_rfl PRE_first_tail_x15_r0_body.tab0_74 : PRE_first_tail_x15_r0_body.st74.S0.tab = PRE_first_tail_x15_r0_body.S718.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws74 : List Nat := [2251, 2252, 2253]
kernel_rfl PRE_first_tail_x15_r0_body.fresh74 : (PRE_first_tail_x15_r0_body.S718.tab.all fun e => PRE_first_tail_x15_r0_body.ws74.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S718.oracle.all fun q => PRE_first_tail_x15_r0_body.ws74.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab74 : PRE_first_tail_x15_r0_body.S719.tab = PRE_first_tail_x15_r0_body.S718.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws74
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen74 : PRE_first_tail_x15_r0_body.st74.S2.tab.length - PRE_first_tail_x15_r0_body.st74.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged74`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap74 : PRE_first_tail_x15_r0_body.s719.heap = PRE_first_tail_x15_r0_body.st74.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext74 : PRE_first_tail_x15_r0_body.s719.next = PRE_first_tail_x15_r0_body.st74.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl74 : PRE_first_tail_x15_r0_body.s719.ctl = PRE_first_tail_x15_r0_body.st74.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack74 : PRE_first_tail_x15_r0_body.s719.stack = PRE_first_tail_x15_r0_body.st74.s2.stack ++ PRE_first_tail_x15_r0_body.s718.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs74 : PRE_first_tail_x15_r0_body.s719.jobs = PRE_first_tail_x15_r0_body.st74.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi74 : PRE_first_tail_x15_r0_body.s719.ffi = PRE_first_tail_x15_r0_body.st74.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace74 : PRE_first_tail_x15_r0_body.s719.trace = PRE_first_tail_x15_r0_body.st74.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores74 : PRE_first_tail_x15_r0_body.s719.stores = PRE_first_tail_x15_r0_body.st74.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD74
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 74 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived74 : PRE_first_tail_x15_r0_body.nr74.map (fun r => nth? PRE_first_tail_x15_r0_body.st74.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo74 : PRE_first_tail_x15_r0_body.nr74.all (Nat.ble 3217) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj74 : PRE_first_tail_x15_r0_body.cws74.all (fun c => !PRE_first_tail_x15_r0_body.ws74.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ74 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws74 PRE_first_tail_x15_r0_body.crs74 PRE_first_tail_x15_r0_body.ws74

end Host.Load.Run.Tpl
end

section -- st74/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st74`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st74.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st74.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st74.s2.heap PRE_first_tail_x15_r0_body.st74.wrR ++ freshOf PRE_first_tail_x15_r0_body.st74.s2.heap PRE_first_tail_x15_r0_body.st74.s0.next PRE_first_tail_x15_r0_body.st74.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st74.wr : List Nat := PRE_first_tail_x15_r0_body.st74.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st74.heapFoot : PRE_first_tail_x15_r0_body.st74.s2.heap = setAll PRE_first_tail_x15_r0_body.st74.s0.heap PRE_first_tail_x15_r0_body.st74.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st74.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st74.s0.next PRE_first_tail_x15_r0_body.st74.s2.next = true
theorem PRE_first_tail_x15_r0_body.st74.grows : PRE_first_tail_x15_r0_body.st74.s0.next ≤ PRE_first_tail_x15_r0_body.st74.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st74.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st74.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st74.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st74.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st74.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st74.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st74.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st74.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st74.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st74.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st74.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st74.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st74.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st74.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st74.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st74.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st74.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st74.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st74.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st74.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st74.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st74.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st74.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st74.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st74.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st74.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st74.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st74.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st74.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st74.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st74.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st74.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF74
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 74 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB74 : nodupT PRE_first_tail_x15_r0_body.st74.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup74 : PRE_first_tail_x15_r0_body.st74.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB74).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB74 : PRE_first_tail_x15_r0_body.st74.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound74 : ∀ b ∈ PRE_first_tail_x15_r0_body.st74.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB74 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr74 := PRE_first_tail_x15_r0_body.st74.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq74 : PRE_first_tail_x15_r0_body.st74.s2.trace = PRE_first_tail_x15_r0_body.trFr74 ++ PRE_first_tail_x15_r0_body.st74.s0.trace
theorem PRE_first_tail_x15_r0_body.trace74 : ∃ fr, PRE_first_tail_x15_r0_body.st74.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st74.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq74⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide74 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB74 : (PRE_first_tail_x15_r0_body.wide74.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st74.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix74 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide74, WFix Map.id (Present PRE_first_tail_x15_r0_body.st74.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB74 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL74
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 74 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s719`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO74 : PRE_first_tail_x15_r0_body.st74.S0.oracle = PRE_first_tail_x15_r0_body.st74.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B74 : PRE_first_tail_x15_r0_body.st74.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st74.s0.next || (PRE_first_tail_x15_r0_body.st74.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot74 : Conv.StageFoot PRE_first_tail_x15_r0_body.st74.wr PRE_first_tail_x15_r0_body.st74.s0 PRE_first_tail_x15_r0_body.st74.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st74.heapFoot PRE_first_tail_x15_r0_body.wrNodup74 PRE_first_tail_x15_r0_body.wrBound74 PRE_first_tail_x15_r0_body.wr0B74 PRE_first_tail_x15_r0_body.st74.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged74 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st74.F.S → PRE_first_tail_x15_r0_body.st74.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st74.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st74.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs74 PRE_first_tail_x15_r0_body.st74.wr PRE_first_tail_x15_r0_body.s718 PRE_first_tail_x15_r0_body.st74.s2 PRE_first_tail_x15_r0_body.st74.s0
      PRE_first_tail_x15_r0_body.st74.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st74.F FR W stk M ν K PRE_first_tail_x15_r0_body.s719 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso74 PRE_first_tail_x15_r0_body.stFoot74 PRE_first_tail_x15_r0_body.wrNodup74 PRE_first_tail_x15_r0_body.wrBound74 PRE_first_tail_x15_r0_body.trace74 PRE_first_tail_x15_r0_body.mheap74
    PRE_first_tail_x15_r0_body.mnext74 PRE_first_tail_x15_r0_body.mctl74 PRE_first_tail_x15_r0_body.mstack74 PRE_first_tail_x15_r0_body.mjobs74 PRE_first_tail_x15_r0_body.mffi74 PRE_first_tail_x15_r0_body.mtrace74 PRE_first_tail_x15_r0_body.mstores74 h

def PRE_first_tail_x15_r0_body.arrEl74_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE74_2665 : arrOf PRE_first_tail_x15_r0_body.s719 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl74_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA74_2665 : isArrB PRE_first_tail_x15_r0_body.s719 2665 = true
theorem PRE_first_tail_x15_r0_body.arr74_2665 : ∃ o, PRE_first_tail_x15_r0_body.s719.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl74_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE74_2665 PRE_first_tail_x15_r0_body.arrA74_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN74_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl74_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR74_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl74_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN74_2665

def PRE_first_tail_x15_r0_body.arrEl74_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE74_2673467 : arrOf PRE_first_tail_x15_r0_body.s719 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl74_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA74_2673467 : isArrB PRE_first_tail_x15_r0_body.s719 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr74_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s719.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl74_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE74_2673467 PRE_first_tail_x15_r0_body.arrA74_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN74_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl74_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR74_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl74_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN74_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k74 : isArrB PRE_first_tail_x15_r0_body.s719 4910 = false
theorem PRE_first_tail_x15_r0_body.keep74 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s719 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k74 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr74_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl74_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ74
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 74 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s718`, the merged
state `PRE_first_tail_x15_r0_body.s719`, the canonical state `PRE_first_tail_x15_r0_body.s720`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl74 : PRE_first_tail_x15_r0_body.pl74.all (Nat.ble PRE_first_tail_x15_r0_body.s718.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd74 : nodupT PRE_first_tail_x15_r0_body.pl74 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn174 : Nat.ble PRE_first_tail_x15_r0_body.s718.next 2732754 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst74 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s718.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn74 : PRE_first_tail_x15_r0_body.s720.next = PRE_first_tail_x15_r0_body.s718.next + PRE_first_tail_x15_r0_body.pl74.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn74 : PRE_first_tail_x15_r0_body.s719.next = 2732754
kernel_rfl PRE_first_tail_x15_r0_body.zgrow74 : Nat.ble PRE_first_tail_x15_r0_body.s720.next PRE_first_tail_x15_r0_body.s719.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh74 : PRE_first_tail_x15_r0_body.S718.tab.all (fun e => PRE_first_tail_x15_r0_body.cws74.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd74 : nodupT PRE_first_tail_x15_r0_body.cws74 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi74 : PRE_first_tail_x15_r0_body.nr74.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S719.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt74 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s718.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg74_2665 : PRE_first_tail_x15_r0_body.s720.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s720 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk74_2665 : (objOf PRE_first_tail_x15_r0_body.s720 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm74_2665 : PRE_first_tail_x15_r0_body.s719.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa74.obj (objOf PRE_first_tail_x15_r0_body.s720 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s719 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg74_2673467 : PRE_first_tail_x15_r0_body.s720.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s720 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk74_2673467 : (objOf PRE_first_tail_x15_r0_body.s720 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm74_2673467 : PRE_first_tail_x15_r0_body.s719.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa74.obj (objOf PRE_first_tail_x15_r0_body.s720 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s719 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw74_4910 : (PRE_first_tail_x15_r0_body.s720.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw74_2673472 : (PRE_first_tail_x15_r0_body.s720.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw74_2673473 : (PRE_first_tail_x15_r0_body.s720.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd74 : PRE_first_tail_x15_r0_body.cl74.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr74 : PRE_first_tail_x15_r0_body.st74.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s718.next || PRE_first_tail_x15_r0_body.cl74.contains b) = true
def PRE_first_tail_x15_r0_body.zl74 : List Nat := PRE_first_tail_x15_r0_body.cl74.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE74 : PRE_first_tail_x15_r0_body.zl74.map (fun a => PRE_first_tail_x15_r0_body.s719.heap.get (PRE_first_tail_x15_r0_body.kappa74.a a)) = PRE_first_tail_x15_r0_body.zl74.map (fun a => (PRE_first_tail_x15_r0_body.s720.heap.get a).map PRE_first_tail_x15_r0_body.kappa74.hobj)
theorem PRE_first_tail_x15_r0_body.zimg74 : HeapImg PRE_first_tail_x15_r0_body.kappa74 PRE_first_tail_x15_r0_body.s720 PRE_first_tail_x15_r0_body.s719 PRE_first_tail_x15_r0_body.zl74 := PRE_first_tail_x15_r0_body.zimgE74
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl74 : PRE_first_tail_x15_r0_body.s719.ctl = PRE_first_tail_x15_r0_body.kappa74.ctl PRE_first_tail_x15_r0_body.s720.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack74 : PRE_first_tail_x15_r0_body.s719.stack = PRE_first_tail_x15_r0_body.s720.stack.map PRE_first_tail_x15_r0_body.kappa74.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs74 : PRE_first_tail_x15_r0_body.s719.jobs = PRE_first_tail_x15_r0_body.s720.jobs.map PRE_first_tail_x15_r0_body.kappa74.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores74 : PRE_first_tail_x15_r0_body.s719.stores = PRE_first_tail_x15_r0_body.kappa74.stores PRE_first_tail_x15_r0_body.s720.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots74 : checkRootsSupp PRE_first_tail_x15_r0_body.s720 3217 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC74 : PRE_first_tail_x15_r0_body.S718.tab.length + PRE_first_tail_x15_r0_body.cws74.length = 3217
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap74 : PRE_first_tail_x15_r0_body.kappa74 = Conv.Map.compact PRE_first_tail_x15_r0_body.s718.next 2732754 PRE_first_tail_x15_r0_body.S718.tab.length PRE_first_tail_x15_r0_body.pl74 (PRE_first_tail_x15_r0_body.nr74.map NumV.ref) PRE_first_tail_x15_r0_body.kd74.big
  PRE_first_tail_x15_r0_body.kd74.region PRE_first_tail_x15_r0_body.kd74.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin74 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s720.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc74 : Conv.jcleanListB (⟨19655, 16744, 2732744, 3217⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s720 PRE_first_tail_x15_r0_body.cl74 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB74 : noBigRootsP (fun i => !Conv.oldBigB (⟨19655, 16744, 2732744, 3217⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s720.trace PRE_first_tail_x15_r0_body.s720 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm74 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16744 = true
theorem PRE_first_tail_x15_r0_body.cjcl74 (h : Conv.JClean (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s718) : Conv.JClean (⟨19655, 16744, 2732744, 3217⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s720 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle74)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap74 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd74 a ha)) PRE_first_tail_x15_r0_body.zjc74

end Host.Load.Run.Tpl
end

section -- st74/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st74.bodyLast from PRE_first_tail_x15_r0_body.st74.s1 to PRE_first_tail_x15_r0_body.st74.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st74.F PRE_first_tail_x15_r0_body.st74.s1).run PRE_first_tail_x15_r0_body.st74.S1 = some (PRE_first_tail_x15_r0_body.st74.s2, PRE_first_tail_x15_r0_body.st74.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st74.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st74.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st74.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st74.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st74/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st74.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st74.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st74.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st74.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st74.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st74.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st74.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st74.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st74.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st74.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st74.s0 PRE_first_tail_x15_r0_body.st74.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st74.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st74.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st74.s1 PRE_first_tail_x15_r0_body.st74.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st74/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st74.bodyK0F from PRE_first_tail_x15_r0_body.st74.s0 to PRE_first_tail_x15_r0_body.st74.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st74.F (PRE_first_tail_x15_r0_body.st74.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st74.ks 0).getD 0) PRE_first_tail_x15_r0_body.st74.s0 PRE_first_tail_x15_r0_body.st74.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st74.s1, PRE_first_tail_x15_r0_body.st74.S1)
theorem PRE_first_tail_x15_r0_body.st74.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st74.F (PRE_first_tail_x15_r0_body.st74.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st74.ks 0).getD 0) PRE_first_tail_x15_r0_body.st74.s0 PRE_first_tail_x15_r0_body.st74.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st74.s1, PRE_first_tail_x15_r0_body.st74.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st74.bodyOkLN_ok PRE_first_tail_x15_r0_body.st74.bodyK0F
end Host.Load.Run.Tpl
end

section -- st74/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st74.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st74.F (PRE_first_tail_x15_r0_body.st74.bodyOkL bytes rows) 98 PRE_first_tail_x15_r0_body.st74.s0 PRE_first_tail_x15_r0_body.st74.S0 = some (PRE_first_tail_x15_r0_body.st74.s1, PRE_first_tail_x15_r0_body.st74.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st74.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st74.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st74.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st74.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st74.F (PRE_first_tail_x15_r0_body.st74.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st74.s0
  S0 := PRE_first_tail_x15_r0_body.st74.S0
  s1 := PRE_first_tail_x15_r0_body.st74.s1
  S1 := PRE_first_tail_x15_r0_body.st74.S1
  s2 := PRE_first_tail_x15_r0_body.st74.s2
  S2 := PRE_first_tail_x15_r0_body.st74.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st74.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st74.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st74.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st74.bodyHalt
  last := PRE_first_tail_x15_r0_body.st74.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st74.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC75
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 75 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s737` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa75` into the merged state
`PRE_first_tail_x15_r0_body.s736`. -/

def PRE_first_tail_x15_r0_body.pl75 : List Nat := [2735327, 2734502, 2735333, 2735329, 2734504, 2735335]
def PRE_first_tail_x15_r0_body.nr75 : List Nat := [3320, 3319, 3295, 3303, 3308, 3313, 3318, 3292, 3293, 3294, 3301, 3302, 3290, 3297, 3298, 3299, 3300, 3296]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd75 : RData :=
  ⟨2734221, 2735370, Stage.setAll PTrie.nil [(2734215, 2735327), (2734216, 2734502), (2734217, 2735333), (2734218, 2735329), (2734219, 2734504), (2734220, 2735335)], Stage.setAll PTrie.nil [(19689, 19715), (19690, 19693), (19691, 19716)],
   19692, 19717, 16790, 16790, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(3290, .ref 3320), (3291, .ref 3319), (3292, .ref 3295), (3293, .ref 3303), (3294, .ref 3308), (3295, .ref 3313), (3296, .ref 3318), (3297, .ref 3292), (3298, .ref 3293), (3299, .ref 3294), (3300, .ref 3301), (3301, .ref 3302), (3302, .ref 3290), (3303, .ref 3297), (3304, .ref 3298), (3305, .ref 3299), (3306, .ref 3300), (3307, .ref 3296)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa75 : Map :=
  Conv.Map.compact 2734215 2735370 3290 PRE_first_tail_x15_r0_body.pl75 (PRE_first_tail_x15_r0_body.nr75.map NumV.ref) PRE_first_tail_x15_r0_body.kd75.big
    PRE_first_tail_x15_r0_body.kd75.region PRE_first_tail_x15_r0_body.kd75.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws75 : List Nat := [2285, 2286, 2287, 2288, 2289, 2290, 2291, 2292, 2293, 2294, 2295, 2296, 2297, 2298, 2299, 2300, 2301, 2302]
noncomputable def PRE_first_tail_x15_r0_body.crs75 : List SymE := PRE_first_tail_x15_r0_body.nr75.map fun r => (nth? PRE_first_tail_x15_r0_body.S736.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta75 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws75 PRE_first_tail_x15_r0_body.crs75
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB75 : List Nat := [2665, 2672491, 2673467, 2733389, 2733934, 2734190]

kernel_rfl PRE_first_tail_x15_r0_body.ctab75 : PRE_first_tail_x15_r0_body.S737.tab = PRE_first_tail_x15_r0_body.S735.tab ++ PRE_first_tail_x15_r0_body.cws75.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace75 : PRE_first_tail_x15_r0_body.s737.trace = PRE_first_tail_x15_r0_body.s735.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext75 : PRE_first_tail_x15_r0_body.s737.next = 2734221
kernel_rfl PRE_first_tail_x15_r0_body.ccounters75 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s737.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s737.ffi).mlx.nnext) = (19692, 16790)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue75 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s736.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s737.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa75.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp75 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s737.ffi).mlx.tokens.all (bSN 3308) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean75 : Conv.cleanListB 19692 131072 (fun r => Nat.ble 78768 r) PRE_first_tail_x15_r0_body.s737
    (PRE_first_tail_x15_r0_body.wrB75 ++ (List.range 6).map (2734215 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs75 : bigsOutB 19692 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s737.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK75
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl75`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl75 : List Nat := [2665, 2672491, 2673467, 2733389, 2733934, 2734190, 2734215, 2734216, 2734217, 2734218, 2734219, 2734220]
def PRE_first_tail_x15_r0_body.clo75 : List Nat := [19669, 19682, 19688, 19689, 19690, 19691]
def PRE_first_tail_x15_r0_body.cln75 : List Nat := [16763, 16764, 16765, 16766, 16767, 16768, 16769, 16770, 16771, 16772, 16773, 16774, 16775, 16776, 16777, 16778, 16779, 16780, 16781, 16782, 16783, 16784, 16785, 16786, 16787, 16788, 16789]
def PRE_first_tail_x15_r0_body.cli75 : List Nat := [16763, 16764, 16765, 16766, 16767, 16768, 16769, 16770, 16771, 16772, 16773, 16774, 16775, 16776, 16777, 16778, 16779, 16780, 16781, 16782, 16783, 16784, 16785, 16786, 16787, 16788, 16789]
kernel_rfl PRE_first_tail_x15_r0_body.cheap75 : PRE_first_tail_x15_r0_body.s737.heap = Stage.setAll PRE_first_tail_x15_r0_body.s735.heap (PRE_first_tail_x15_r0_body.cl75.filterMap fun a => (PRE_first_tail_x15_r0_body.s737.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe75 : Nat.ble PRE_first_tail_x15_r0_body.s735.next PRE_first_tail_x15_r0_body.s737.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP75 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s735 PRE_first_tail_x15_r0_body.s737 PRE_first_tail_x15_r0_body.cl75 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp75 : Conv.suppListB PRE_first_tail_x15_r0_body.s737 3308 PRE_first_tail_x15_r0_body.cl75 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound75 : Conv.boundListB PRE_first_tail_x15_r0_body.s737 PRE_first_tail_x15_r0_body.cl75 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK75 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s737.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln75.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s737.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK75 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s737.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo75.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s737.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK75 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s737.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli75.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s737.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst75 : Conv.sstListB 3308 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s737.ffi).mlx PRE_first_tail_x15_r0_body.cln75 PRE_first_tail_x15_r0_body.clo75 PRE_first_tail_x15_r0_body.cli75 = true

end Host.Load.Run.Tpl
end

section -- SiteCl75
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA75 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s737.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo75.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s737.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd75 : (PRE_first_tail_x15_r0_body.clo75 ++ PRE_first_tail_x15_r0_body.cln75 ++ PRE_first_tail_x15_r0_body.cli75).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle75 : Conv.Cnt.leB (⟨19689, 16763, 2734215, 3290⟩ : Conv.Cnt) (⟨19692, 16790, 2734221, 3308⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck75 : Conv.ncleanListB (⟨19692, 16790, 2734221, 3308⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s737.ffi).mlx PRE_first_tail_x15_r0_body.clo75 PRE_first_tail_x15_r0_body.cln75 PRE_first_tail_x15_r0_body.cli75 = true
theorem PRE_first_tail_x15_r0_body.cncl75 (h : Conv.NClean (⟨19689, 16763, 2734215, 3290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx) : Conv.NClean (⟨19692, 16790, 2734221, 3308⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s737.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle75 PRE_first_tail_x15_r0_body.ckA75 PRE_first_tail_x15_r0_body.cobjsK75 PRE_first_tail_x15_r0_body.cnodesK75 PRE_first_tail_x15_r0_body.citemsK75 PRE_first_tail_x15_r0_body.cbd75 PRE_first_tail_x15_r0_body.cck75

end Host.Load.Run.Tpl
end

section -- SiteS75
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 75 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc75 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P75 : LoadP := PRE_first_tail_x15_r0_body.Pc75.raise 16790
kernel_rfl PRE_first_tail_x15_r0_body.craise75 : Nat.ble PRE_first_tail_x15_r0_body.Pc75.N0 16790 = true
theorem PRE_first_tail_x15_r0_body.raised75 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc75 PRE_first_tail_x15_r0_body.P75 :=
  .inr ⟨16790, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise75, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_75 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s737.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_75 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s736.ffi)
def PRE_first_tail_x15_r0_body.khinv75 : PTrie Nat := Stage.setAll PTrie.nil [(19715, 19689), (19693, 19690), (19716, 19691)]
def PRE_first_tail_x15_r0_body.kninv75 : PTrie Nat := Stage.setAll PTrie.nil [(16763, 16763), (16764, 16764), (16765, 16765), (16766, 16766), (16767, 16767), (16768, 16768), (16769, 16769), (16770, 16770), (16771, 16771), (16772, 16772), (16773, 16773), (16774, 16774), (16775, 16775), (16776, 16776), (16777, 16777), (16778, 16778), (16779, 16779), (16780, 16780), (16781, 16781), (16782, 16782), (16783, 16783), (16784, 16784), (16785, 16785), (16786, 16786), (16787, 16787), (16788, 16788), (16789, 16789)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS75 : List Nat := [19669, 19682, 19688, 19689, 19690, 19691, 19692, 19693, 19694, 19695, 19696, 19697, 19698, 19699, 19700, 19701, 19702, 19703, 19704, 19705, 19706, 19707, 19708, 19709, 19710, 19711, 19712, 19713, 19714, 19715, 19716]
def PRE_first_tail_x15_r0_body.cnS75 : List Nat := List.range' 16763 27
def PRE_first_tail_x15_r0_body.ciS75 : List Nat := [] ++ List.range' 16763 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh075 : PRE_first_tail_x15_r0_body.kd75.nh0 = PRE_first_tail_x15_r0_body.cx0_75.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh175 : PRE_first_tail_x15_r0_body.kd75.nh1 = PRE_first_tail_x15_r0_body.cx1_75.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn075 : PRE_first_tail_x15_r0_body.kd75.nn0 = PRE_first_tail_x15_r0_body.cx0_75.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn175 : PRE_first_tail_x15_r0_body.kd75.nn1 = PRE_first_tail_x15_r0_body.cx1_75.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo75 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P75.lo && Nat.ble PRE_first_tail_x15_r0_body.P75.lo PRE_first_tail_x15_r0_body.cx0_75.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P75.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P75.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt75 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_75.mlx.next PRE_first_tail_x15_r0_body.cx1_75.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_75.mlx.nnext PRE_first_tail_x15_r0_body.cx1_75.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband75 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P75.NL && Nat.ble PRE_first_tail_x15_r0_body.P75.NL PRE_first_tail_x15_r0_body.P75.N0 && Nat.ble PRE_first_tail_x15_r0_body.P75.N0 PRE_first_tail_x15_r0_body.cx0_75.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow75 : PRE_first_tail_x15_r0_body.kd75.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren75 : checkRenG PRE_first_tail_x15_r0_body.kd75.hnd PRE_first_tail_x15_r0_body.khinv75 (phB PRE_first_tail_x15_r0_body.cx0_75.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband75 : PRE_first_tail_x15_r0_body.kd75.checkBand PRE_first_tail_x15_r0_body.P75.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos75 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd75.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren75 : checkRenG PRE_first_tail_x15_r0_body.kd75.node PRE_first_tail_x15_r0_body.kninv75 (pnB PRE_first_tail_x15_r0_body.cx0_75.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow75 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd75.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P75.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd75.nodeF j) PRE_first_tail_x15_r0_body.cx1_75.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a75 : PRE_first_tail_x15_r0_body.cx0_75.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b75 : PRE_first_tail_x15_r0_body.cx0_75.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok175 : PRE_first_tail_x15_r0_body.cx1_75.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend75 : PRE_first_tail_x15_r0_body.cx1_75.mlx.pending = PRE_first_tail_x15_r0_body.cx0_75.mlx.pending.map PRE_first_tail_x15_r0_body.kappa75.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh75 : PRE_first_tail_x15_r0_body.cx1_75.mlx.errh = PRE_first_tail_x15_r0_body.cx0_75.mlx.errh.map PRE_first_tail_x15_r0_body.kappa75.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles75 : PRE_first_tail_x15_r0_body.cx1_75.mlx.files = PRE_first_tail_x15_r0_body.cx0_75.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch75 : PRE_first_tail_x15_r0_body.cx1_75.mlx.arch = PRE_first_tail_x15_r0_body.cx0_75.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes75 : PRE_first_tail_x15_r0_body.cx1_75.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_75.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired75 : PRE_first_tail_x15_r0_body.cx1_75.mlx.wired = PRE_first_tail_x15_r0_body.cx0_75.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost75 : PRE_first_tail_x15_r0_body.cx1_75.host = PRE_first_tail_x15_r0_body.cx0_75.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd75`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn075 : PRE_first_tail_x15_r0_body.kd75.n0 = 2734221
kernel_rfl PRE_first_tail_x15_r0_body.ckn175 : PRE_first_tail_x15_r0_body.kd75.n1 = 2735370
kernel_rfl PRE_first_tail_x15_r0_body.ckheap75 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd75.heap).all (fun x => Nat.ble 2734215 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl75 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd75.heap.get (2734215 + j) = nth? PRE_first_tail_x15_r0_body.pl75 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja75 : Nat.ble 2734215 2734215 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn75 : Nat.ble 3290 3290 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD75 : Nat.ble 2734215 PRE_first_tail_x15_r0_body.kd75.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn75 : Nat.ble 19689 PRE_first_tail_x15_r0_body.kd75.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn75 : Nat.ble 16763 PRE_first_tail_x15_r0_body.kd75.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb75 : Nat.ble 19689 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap75 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd75.heap).all (Nat.ble (⟨19689, 16763, 2734215, 3290⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd75 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd75.hnd).all (Nat.ble (⟨19689, 16763, 2734215, 3290⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode75 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd75.node).all (Nat.ble (⟨19689, 16763, 2734215, 3290⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix75 : Conv.FixOld (⟨19689, 16763, 2734215, 3290⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa75 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja75) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn75) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD75) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn75) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn75) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb75) PRE_first_tail_x15_r0_body.fheap75 PRE_first_tail_x15_r0_body.fhnd75 PRE_first_tail_x15_r0_body.fnode75
kernel_rfl PRE_first_tail_x15_r0_body.fcxn75 : (⟨19689, 16763, 2734215, 3290⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn75 : (⟨19689, 16763, 2734215, 3290⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle075 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_75.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_75.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk75 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd75.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A75 : PRE_first_tail_x15_r0_body.cx1_75.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS75.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_75.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O75 : PRE_first_tail_x15_r0_body.cx1_75.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS75.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_75.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N75 : PRE_first_tail_x15_r0_body.cx1_75.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS75.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_75.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I75 : PRE_first_tail_x15_r0_body.cx1_75.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS75.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_75.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd75 : (PRE_first_tail_x15_r0_body.clo75 ++ PRE_first_tail_x15_r0_body.cln75 ++ PRE_first_tail_x15_r0_body.cli75 ++ PRE_first_tail_x15_r0_body.cwS75 ++ PRE_first_tail_x15_r0_body.cnS75 ++ PRE_first_tail_x15_r0_body.ciS75).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW75 : PRE_first_tail_x15_r0_body.cwS75.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo75.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI75 : PRE_first_tail_x15_r0_body.ciS75.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli75.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN75 : PRE_first_tail_x15_r0_body.cnS75.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF75 : PRE_first_tail_x15_r0_body.cln75.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh75 : PRE_first_tail_x15_r0_body.clo75.all (handleOK PRE_first_tail_x15_r0_body.kappa75 PRE_first_tail_x15_r0_body.P75.lo PRE_first_tail_x15_r0_body.cx0_75.mlx PRE_first_tail_x15_r0_body.cx1_75.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo75 : PRE_first_tail_x15_r0_body.clo75.map (fun h => PRE_first_tail_x15_r0_body.cx1_75.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa75.handle h)) = PRE_first_tail_x15_r0_body.clo75.map (fun h => (PRE_first_tail_x15_r0_body.cx0_75.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa75.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok75 : PRE_first_tail_x15_r0_body.clo75.all (objOK PRE_first_tail_x15_r0_body.kappa75 PRE_first_tail_x15_r0_body.P75.NL PRE_first_tail_x15_r0_body.cx0_75.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd75 : PRE_first_tail_x15_r0_body.cln75.all (nodeOKF PRE_first_tail_x15_r0_body.kappa75 PRE_first_tail_x15_r0_body.P75 PRE_first_tail_x15_r0_body.cx0_75.mlx PRE_first_tail_x15_r0_body.cx1_75.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp75 : ((PRE_first_tail_x15_r0_body.cln75.filter (fullB PRE_first_tail_x15_r0_body.P75))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_75.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa75.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln75.filter (fullB PRE_first_tail_x15_r0_body.P75))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_75.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa75.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI75 : incrB PRE_first_tail_x15_r0_body.kd75.nodeF (List.range' 16763 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK75 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd75.node).all (fun k => Nat.ble 16763 k && Nat.blt k 16790) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL75 : (PRE_first_tail_x15_r0_body.cln75.filter (Nat.ble PRE_first_tail_x15_r0_body.P75.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd75.nodeF i) && (Nat.blt i 16790 || Nat.ble PRE_first_tail_x15_r0_body.kd75.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord75 : (PRE_first_tail_x15_r0_body.cln75.filter (Nat.ble PRE_first_tail_x15_r0_body.P75.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd75.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd75.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd75.nodeF j) (PRE_first_tail_x15_r0_body.kd75.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow75 PRE_first_tail_x15_r0_body.cnn175 PRE_first_tail_x15_r0_body.fnordI75 PRE_first_tail_x15_r0_body.fnordK75 PRE_first_tail_x15_r0_body.fnordL75
kernel_rfl PRE_first_tail_x15_r0_body.fi75 : PRE_first_tail_x15_r0_body.cli75.all (pnB PRE_first_tail_x15_r0_body.cx0_75.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii75 : PRE_first_tail_x15_r0_body.cli75.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_75.mlx.items.get (PRE_first_tail_x15_r0_body.kappa75.node k) = (PRE_first_tail_x15_r0_body.cx0_75.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa75.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot75 (clean : Conv.NClean (⟨19689, 16763, 2734215, 3290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P75.NL) (cl : SSt (· < 3308) PRE_first_tail_x15_r0_body.cx0_75.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P75 3308 PRE_first_tail_x15_r0_body.kappa75 PRE_first_tail_x15_r0_body.kd75 PRE_first_tail_x15_r0_body.khinv75 PRE_first_tail_x15_r0_body.kninv75 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx PRE_first_tail_x15_r0_body.cx0_75.mlx PRE_first_tail_x15_r0_body.cx1_75.mlx (⟨19689, 16763, 2734215, 3290⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo75 PRE_first_tail_x15_r0_body.cln75 PRE_first_tail_x15_r0_body.cli75 PRE_first_tail_x15_r0_body.cwS75 PRE_first_tail_x15_r0_body.cnS75 PRE_first_tail_x15_r0_body.ciS75 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh075, PRE_first_tail_x15_r0_body.cnh175, PRE_first_tail_x15_r0_body.cnn075, PRE_first_tail_x15_r0_body.cnn175, PRE_first_tail_x15_r0_body.cplo75, PRE_first_tail_x15_r0_body.ccnt75, PRE_first_tail_x15_r0_body.cnband75, PRE_first_tail_x15_r0_body.chbelow75, PRE_first_tail_x15_r0_body.chren75, PRE_first_tail_x15_r0_body.cband75, PRE_first_tail_x15_r0_body.cnh1pos75, PRE_first_tail_x15_r0_body.cnren75, PRE_first_tail_x15_r0_body.cnlow75, PRE_first_tail_x15_r0_body.cabs0a75, PRE_first_tail_x15_r0_body.cabs0b75, PRE_first_tail_x15_r0_body.ctok175, PRE_first_tail_x15_r0_body.cpend75, PRE_first_tail_x15_r0_body.cerrh75, PRE_first_tail_x15_r0_body.cfiles75, PRE_first_tail_x15_r0_body.carch75, PRE_first_tail_x15_r0_body.csizes75, PRE_first_tail_x15_r0_body.cwired75, PRE_first_tail_x15_r0_body.cfix75, clean, PRE_first_tail_x15_r0_body.fcxn75, PRE_first_tail_x15_r0_body.fcnn75, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle075, PRE_first_tail_x15_r0_body.fnk75, PRE_first_tail_x15_r0_body.ckA75, PRE_first_tail_x15_r0_body.cobjsK75, PRE_first_tail_x15_r0_body.cnodesK75, PRE_first_tail_x15_r0_body.citemsK75, PRE_first_tail_x15_r0_body.f1A75, PRE_first_tail_x15_r0_body.f1O75, PRE_first_tail_x15_r0_body.f1N75, PRE_first_tail_x15_r0_body.f1I75, PRE_first_tail_x15_r0_body.fbd75, PRE_first_tail_x15_r0_body.fincW75, PRE_first_tail_x15_r0_body.fincI75, PRE_first_tail_x15_r0_body.fincN75, PRE_first_tail_x15_r0_body.flnF75, PRE_first_tail_x15_r0_body.fh75, PRE_first_tail_x15_r0_body.fo75, PRE_first_tail_x15_r0_body.fok75, PRE_first_tail_x15_r0_body.fnd75, PRE_first_tail_x15_r0_body.fp75, PRE_first_tail_x15_r0_body.fnord75, PRE_first_tail_x15_r0_body.fi75, PRE_first_tail_x15_r0_body.fii75⟩
theorem PRE_first_tail_x15_r0_body.cnshift75 (clean : Conv.NClean (⟨19689, 16763, 2734215, 3290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P75.NL) (cl : SSt (· < 3308) PRE_first_tail_x15_r0_body.cx0_75.mlx) : NShift PRE_first_tail_x15_r0_body.P75 3308 PRE_first_tail_x15_r0_body.kappa75 PRE_first_tail_x15_r0_body.cx0_75 PRE_first_tail_x15_r0_body.cx1_75 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot75 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost75 (compact_a_eq PRE_first_tail_x15_r0_body.ckn075 PRE_first_tail_x15_r0_body.ckn175 PRE_first_tail_x15_r0_body.ckheap75 PRE_first_tail_x15_r0_body.ckpl75)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_75 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s735.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_75 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s735.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_75 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s735.ffi) = some PRE_first_tail_x15_r0_body.fxC_75
kernel_rfl PRE_first_tail_x15_r0_body.okrC_75 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s735.ffi) = some PRE_first_tail_x15_r0_body.krC_75
noncomputable def PRE_first_tail_x15_r0_body.fx0_75 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s737.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_75 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s737.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_75 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s737.ffi) = some PRE_first_tail_x15_r0_body.fx0_75
kernel_rfl PRE_first_tail_x15_r0_body.okr0_75 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s737.ffi) = some PRE_first_tail_x15_r0_body.kr0_75
noncomputable def PRE_first_tail_x15_r0_body.fx1_75 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s736.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_75 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s736.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_75 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s736.ffi) = some PRE_first_tail_x15_r0_body.fx1_75
kernel_rfl PRE_first_tail_x15_r0_body.okr1_75 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s736.ffi) = some PRE_first_tail_x15_r0_body.kr1_75
kernel_rfl PRE_first_tail_x15_r0_body.ff075 : PRE_first_tail_x15_r0_body.fx0_75 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_75 (PRE_first_tail_x15_r0_body.clo75.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_75.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff175 : PRE_first_tail_x15_r0_body.fx1_75 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_75 (PRE_first_tail_x15_r0_body.cwS75.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_75.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck75 : freedLB PRE_first_tail_x15_r0_body.kappa75 PRE_first_tail_x15_r0_body.cx0_75.mlx PRE_first_tail_x15_r0_body.fx0_75 PRE_first_tail_x15_r0_body.fx1_75 PRE_first_tail_x15_r0_body.clo75 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf075 : PRE_first_tail_x15_r0_body.kr0_75.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_75.flags (PRE_first_tail_x15_r0_body.clo75.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_75.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt075 : PRE_first_tail_x15_r0_body.kr0_75.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_75.targs (PRE_first_tail_x15_r0_body.clo75.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_75.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf175 : PRE_first_tail_x15_r0_body.kr1_75.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_75.flags (PRE_first_tail_x15_r0_body.cwS75.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_75.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt175 : PRE_first_tail_x15_r0_body.kr1_75.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_75.targs (PRE_first_tail_x15_r0_body.cwS75.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_75.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck75 : krecLB PRE_first_tail_x15_r0_body.kappa75 3308 PRE_first_tail_x15_r0_body.cx0_75.mlx PRE_first_tail_x15_r0_body.kr0_75 PRE_first_tail_x15_r0_body.kr1_75 PRE_first_tail_x15_r0_body.clo75 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn75 : Nat.ble 3290 3308 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge75 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s736.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s737.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR75 : pendRegB PRE_first_tail_x15_r0_body.kappa75 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s737.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe75 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s737.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s736.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift75 (clean : Conv.NClean (⟨19689, 16763, 2734215, 3290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P75.NL) (cl : SSt (· < 3308) PRE_first_tail_x15_r0_body.cx0_75.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_75.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_75.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_75.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_75.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19689, 16763, 2734215, 3290⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P75 3308 PRE_first_tail_x15_r0_body.kappa75 PRE_first_tail_x15_r0_body.s737.ffi PRE_first_tail_x15_r0_body.s736.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift75 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue75, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp75 t ht),
    PRE_first_tail_x15_r0_body.cbridge75,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s737.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s736.ffi) (PRE_first_tail_x15_r0_body.cfoot75 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_75 PRE_first_tail_x15_r0_body.ofx1_75 hobjC PRE_first_tail_x15_r0_body.ff075 PRE_first_tail_x15_r0_body.ff175 PRE_first_tail_x15_r0_body.ffck75,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s737.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s736.ffi) (PRE_first_tail_x15_r0_body.cfoot75 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_75 PRE_first_tail_x15_r0_body.okr1_75 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn75) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf075 PRE_first_tail_x15_r0_body.fkt075 PRE_first_tail_x15_r0_body.fkf175 PRE_first_tail_x15_r0_body.fkt175 PRE_first_tail_x15_r0_body.fkck75,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh075 PRE_first_tail_x15_r0_body.cnh175 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe75) PRE_first_tail_x15_r0_body.cpendR75⟩

end Host.Load.Run.Tpl
end

section -- st75/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st75 0
host_stream_state PRE_first_tail_x15_r0_body.st75 1
host_stream_state PRE_first_tail_x15_r0_body.st75 2
host_stream_state PRE_first_tail_x15_r0_body.st75 3
host_stream_state PRE_first_tail_x15_r0_body.st75 4
host_stream_state PRE_first_tail_x15_r0_body.st75 5
end Host.Load.Run.Tpl
end

section -- Site75
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 75 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g75__g76` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s735`, the merged state `PRE_first_tail_x15_r0_body.s736`,
the site template `PRE_first_tail_x15_r0_body.st75` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s737`: the merge.
The footprint's facts are in `SiteF75`, the compaction's in `SiteC75`, `SiteK75`, `SiteNa75`, `SiteNb75`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso75 : PRE_first_tail_x15_r0_body.st75.s0 = { PRE_first_tail_x15_r0_body.s735 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs75 : List Frame := PRE_first_tail_x15_r0_body.s735.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_75 : PRE_first_tail_x15_r0_body.S735.tab.length = 3290
kernel_rfl PRE_first_tail_x15_r0_body.tab0_75 : PRE_first_tail_x15_r0_body.st75.S0.tab = PRE_first_tail_x15_r0_body.S735.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws75 : List Nat := [2254, 2255, 2256, 2257, 2258, 2259, 2260, 2261, 2262, 2263, 2264, 2265, 2266, 2267, 2268, 2269, 2270, 2271, 2272, 2273, 2274, 2275, 2276, 2277, 2278, 2279, 2280, 2281, 2282, 2283, 2284]
kernel_rfl PRE_first_tail_x15_r0_body.fresh75 : (PRE_first_tail_x15_r0_body.S735.tab.all fun e => PRE_first_tail_x15_r0_body.ws75.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S735.oracle.all fun q => PRE_first_tail_x15_r0_body.ws75.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab75 : PRE_first_tail_x15_r0_body.S736.tab = PRE_first_tail_x15_r0_body.S735.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws75
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen75 : PRE_first_tail_x15_r0_body.st75.S5.tab.length - PRE_first_tail_x15_r0_body.st75.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged75`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap75 : PRE_first_tail_x15_r0_body.s736.heap = PRE_first_tail_x15_r0_body.st75.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext75 : PRE_first_tail_x15_r0_body.s736.next = PRE_first_tail_x15_r0_body.st75.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl75 : PRE_first_tail_x15_r0_body.s736.ctl = PRE_first_tail_x15_r0_body.st75.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack75 : PRE_first_tail_x15_r0_body.s736.stack = PRE_first_tail_x15_r0_body.st75.s5.stack ++ PRE_first_tail_x15_r0_body.s735.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs75 : PRE_first_tail_x15_r0_body.s736.jobs = PRE_first_tail_x15_r0_body.st75.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi75 : PRE_first_tail_x15_r0_body.s736.ffi = PRE_first_tail_x15_r0_body.st75.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace75 : PRE_first_tail_x15_r0_body.s736.trace = PRE_first_tail_x15_r0_body.st75.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores75 : PRE_first_tail_x15_r0_body.s736.stores = PRE_first_tail_x15_r0_body.st75.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD75
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 75 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived75 : PRE_first_tail_x15_r0_body.nr75.map (fun r => nth? PRE_first_tail_x15_r0_body.st75.S5.tab r) =
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
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo75 : PRE_first_tail_x15_r0_body.nr75.all (Nat.ble 3290) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj75 : PRE_first_tail_x15_r0_body.cws75.all (fun c => !PRE_first_tail_x15_r0_body.ws75.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ75 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws75 PRE_first_tail_x15_r0_body.crs75 PRE_first_tail_x15_r0_body.ws75

end Host.Load.Run.Tpl
end

section -- st75/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st75`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st75.wrR : List (Nat × Nat) := [(2672491, 2672492), (2733389, 2733390), (2733934, 2733935), (2734190, 2734191)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st75.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st75.s5.heap PRE_first_tail_x15_r0_body.st75.wrR ++ freshOf PRE_first_tail_x15_r0_body.st75.s5.heap PRE_first_tail_x15_r0_body.st75.s0.next PRE_first_tail_x15_r0_body.st75.s5.next
noncomputable def PRE_first_tail_x15_r0_body.st75.wr : List Nat := PRE_first_tail_x15_r0_body.st75.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st75.heapFoot : PRE_first_tail_x15_r0_body.st75.s5.heap = setAll PRE_first_tail_x15_r0_body.st75.s0.heap PRE_first_tail_x15_r0_body.st75.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st75.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st75.s0.next PRE_first_tail_x15_r0_body.st75.s5.next = true
theorem PRE_first_tail_x15_r0_body.st75.grows : PRE_first_tail_x15_r0_body.st75.s0.next ≤ PRE_first_tail_x15_r0_body.st75.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st75.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st75.wh : List Nat := [19669, 19682, 19688, 19689, 19690, 19691, 19692, 19693, 19694, 19695, 19696, 19697, 19698, 19699, 19700, 19701, 19702, 19703, 19704, 19705, 19706, 19707, 19708, 19709, 19710, 19711, 19712, 19713, 19714, 19715, 19716]
def PRE_first_tail_x15_r0_body.st75.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st75.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st75.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st75.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st75.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st75.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st75.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st75.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st75.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st75.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st75.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st75.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st75.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st75.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st75.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st75.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st75.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st75.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st75.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st75.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st75.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st75.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st75.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st75.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st75.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st75.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st75.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st75.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st75.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st75.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF75
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 75 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB75 : nodupT PRE_first_tail_x15_r0_body.st75.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup75 : PRE_first_tail_x15_r0_body.st75.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB75).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB75 : PRE_first_tail_x15_r0_body.st75.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound75 : ∀ b ∈ PRE_first_tail_x15_r0_body.st75.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB75 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr75 := PRE_first_tail_x15_r0_body.st75.s5.trace.take 120
kernel_rfl PRE_first_tail_x15_r0_body.traceEq75 : PRE_first_tail_x15_r0_body.st75.s5.trace = PRE_first_tail_x15_r0_body.trFr75 ++ PRE_first_tail_x15_r0_body.st75.s0.trace
theorem PRE_first_tail_x15_r0_body.trace75 : ∃ fr, PRE_first_tail_x15_r0_body.st75.s5.trace = fr ++ PRE_first_tail_x15_r0_body.st75.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq75⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide75 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB75 : (PRE_first_tail_x15_r0_body.wide75.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st75.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix75 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide75, WFix Map.id (Present PRE_first_tail_x15_r0_body.st75.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB75 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL75
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 75 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s736`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO75 : PRE_first_tail_x15_r0_body.st75.S0.oracle = PRE_first_tail_x15_r0_body.st75.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B75 : PRE_first_tail_x15_r0_body.st75.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st75.s0.next || (PRE_first_tail_x15_r0_body.st75.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot75 : Conv.StageFoot PRE_first_tail_x15_r0_body.st75.wr PRE_first_tail_x15_r0_body.st75.s0 PRE_first_tail_x15_r0_body.st75.s5 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st75.heapFoot PRE_first_tail_x15_r0_body.wrNodup75 PRE_first_tail_x15_r0_body.wrBound75 PRE_first_tail_x15_r0_body.wr0B75 PRE_first_tail_x15_r0_body.st75.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged75 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st75.F.S → PRE_first_tail_x15_r0_body.st75.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st75.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st75.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs75 PRE_first_tail_x15_r0_body.st75.wr PRE_first_tail_x15_r0_body.s735 PRE_first_tail_x15_r0_body.st75.s5 PRE_first_tail_x15_r0_body.st75.s0
      PRE_first_tail_x15_r0_body.st75.s5.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st75.F FR W stk M ν K PRE_first_tail_x15_r0_body.s736 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso75 PRE_first_tail_x15_r0_body.stFoot75 PRE_first_tail_x15_r0_body.wrNodup75 PRE_first_tail_x15_r0_body.wrBound75 PRE_first_tail_x15_r0_body.trace75 PRE_first_tail_x15_r0_body.mheap75
    PRE_first_tail_x15_r0_body.mnext75 PRE_first_tail_x15_r0_body.mctl75 PRE_first_tail_x15_r0_body.mstack75 PRE_first_tail_x15_r0_body.mjobs75 PRE_first_tail_x15_r0_body.mffi75 PRE_first_tail_x15_r0_body.mtrace75 PRE_first_tail_x15_r0_body.mstores75 h

def PRE_first_tail_x15_r0_body.arrEl75_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE75_2665 : arrOf PRE_first_tail_x15_r0_body.s736 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl75_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA75_2665 : isArrB PRE_first_tail_x15_r0_body.s736 2665 = true
theorem PRE_first_tail_x15_r0_body.arr75_2665 : ∃ o, PRE_first_tail_x15_r0_body.s736.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl75_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE75_2665 PRE_first_tail_x15_r0_body.arrA75_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN75_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl75_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR75_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl75_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN75_2665

def PRE_first_tail_x15_r0_body.arrEl75_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE75_2673467 : arrOf PRE_first_tail_x15_r0_body.s736 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl75_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA75_2673467 : isArrB PRE_first_tail_x15_r0_body.s736 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr75_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s736.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl75_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE75_2673467 PRE_first_tail_x15_r0_body.arrA75_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN75_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl75_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR75_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl75_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN75_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k75 : isArrB PRE_first_tail_x15_r0_body.s736 4910 = false
theorem PRE_first_tail_x15_r0_body.keep75 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s736 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k75 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr75_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl75_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ75
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 75 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s735`, the merged
state `PRE_first_tail_x15_r0_body.s736`, the canonical state `PRE_first_tail_x15_r0_body.s737`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl75 : PRE_first_tail_x15_r0_body.pl75.all (Nat.ble PRE_first_tail_x15_r0_body.s735.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd75 : nodupT PRE_first_tail_x15_r0_body.pl75 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn175 : Nat.ble PRE_first_tail_x15_r0_body.s735.next 2735370 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst75 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s735.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn75 : PRE_first_tail_x15_r0_body.s737.next = PRE_first_tail_x15_r0_body.s735.next + PRE_first_tail_x15_r0_body.pl75.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn75 : PRE_first_tail_x15_r0_body.s736.next = 2735370
kernel_rfl PRE_first_tail_x15_r0_body.zgrow75 : Nat.ble PRE_first_tail_x15_r0_body.s737.next PRE_first_tail_x15_r0_body.s736.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh75 : PRE_first_tail_x15_r0_body.S735.tab.all (fun e => PRE_first_tail_x15_r0_body.cws75.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd75 : nodupT PRE_first_tail_x15_r0_body.cws75 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi75 : PRE_first_tail_x15_r0_body.nr75.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S736.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt75 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s735.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg75_2665 : PRE_first_tail_x15_r0_body.s737.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s737 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk75_2665 : (objOf PRE_first_tail_x15_r0_body.s737 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm75_2665 : PRE_first_tail_x15_r0_body.s736.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa75.obj (objOf PRE_first_tail_x15_r0_body.s737 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s736 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg75_2673467 : PRE_first_tail_x15_r0_body.s737.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s737 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk75_2673467 : (objOf PRE_first_tail_x15_r0_body.s737 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm75_2673467 : PRE_first_tail_x15_r0_body.s736.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa75.obj (objOf PRE_first_tail_x15_r0_body.s737 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s736 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw75_4910 : (PRE_first_tail_x15_r0_body.s737.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw75_2673472 : (PRE_first_tail_x15_r0_body.s737.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw75_2673473 : (PRE_first_tail_x15_r0_body.s737.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd75 : PRE_first_tail_x15_r0_body.cl75.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr75 : PRE_first_tail_x15_r0_body.st75.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s735.next || PRE_first_tail_x15_r0_body.cl75.contains b) = true
def PRE_first_tail_x15_r0_body.zl75 : List Nat := PRE_first_tail_x15_r0_body.cl75.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE75 : PRE_first_tail_x15_r0_body.zl75.map (fun a => PRE_first_tail_x15_r0_body.s736.heap.get (PRE_first_tail_x15_r0_body.kappa75.a a)) = PRE_first_tail_x15_r0_body.zl75.map (fun a => (PRE_first_tail_x15_r0_body.s737.heap.get a).map PRE_first_tail_x15_r0_body.kappa75.hobj)
theorem PRE_first_tail_x15_r0_body.zimg75 : HeapImg PRE_first_tail_x15_r0_body.kappa75 PRE_first_tail_x15_r0_body.s737 PRE_first_tail_x15_r0_body.s736 PRE_first_tail_x15_r0_body.zl75 := PRE_first_tail_x15_r0_body.zimgE75
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl75 : PRE_first_tail_x15_r0_body.s736.ctl = PRE_first_tail_x15_r0_body.kappa75.ctl PRE_first_tail_x15_r0_body.s737.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack75 : PRE_first_tail_x15_r0_body.s736.stack = PRE_first_tail_x15_r0_body.s737.stack.map PRE_first_tail_x15_r0_body.kappa75.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs75 : PRE_first_tail_x15_r0_body.s736.jobs = PRE_first_tail_x15_r0_body.s737.jobs.map PRE_first_tail_x15_r0_body.kappa75.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores75 : PRE_first_tail_x15_r0_body.s736.stores = PRE_first_tail_x15_r0_body.kappa75.stores PRE_first_tail_x15_r0_body.s737.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots75 : checkRootsSupp PRE_first_tail_x15_r0_body.s737 3308 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC75 : PRE_first_tail_x15_r0_body.S735.tab.length + PRE_first_tail_x15_r0_body.cws75.length = 3308
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap75 : PRE_first_tail_x15_r0_body.kappa75 = Conv.Map.compact PRE_first_tail_x15_r0_body.s735.next 2735370 PRE_first_tail_x15_r0_body.S735.tab.length PRE_first_tail_x15_r0_body.pl75 (PRE_first_tail_x15_r0_body.nr75.map NumV.ref) PRE_first_tail_x15_r0_body.kd75.big
  PRE_first_tail_x15_r0_body.kd75.region PRE_first_tail_x15_r0_body.kd75.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin75 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s737.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc75 : Conv.jcleanListB (⟨19692, 16790, 2734221, 3308⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s737 PRE_first_tail_x15_r0_body.cl75 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB75 : noBigRootsP (fun i => !Conv.oldBigB (⟨19692, 16790, 2734221, 3308⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s737.trace PRE_first_tail_x15_r0_body.s737 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm75 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16763 = true
theorem PRE_first_tail_x15_r0_body.cjcl75 (h : Conv.JClean (⟨19689, 16763, 2734215, 3290⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s735) : Conv.JClean (⟨19692, 16790, 2734221, 3308⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s737 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle75)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap75 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd75 a ha)) PRE_first_tail_x15_r0_body.zjc75

end Host.Load.Run.Tpl
end

section -- st75/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st75.bodyLast from PRE_first_tail_x15_r0_body.st75.s4 to PRE_first_tail_x15_r0_body.st75.s5 :
  interpS (step PRE_first_tail_x15_r0_body.st75.F PRE_first_tail_x15_r0_body.st75.s4).run PRE_first_tail_x15_r0_body.st75.S4 = some (PRE_first_tail_x15_r0_body.st75.s5, PRE_first_tail_x15_r0_body.st75.S5)
kernel_rfl PRE_first_tail_x15_r0_body.st75.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st75.s4.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st75.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st75.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st75/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st75.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st75.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st75.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st75.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st75.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st75.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st75.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st75.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st75.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st75.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st75.s0 PRE_first_tail_x15_r0_body.st75.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st75.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st75.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st75.s4 PRE_first_tail_x15_r0_body.st75.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st75/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st75.bodyK0F from PRE_first_tail_x15_r0_body.st75.s0 to PRE_first_tail_x15_r0_body.st75.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st75.F (PRE_first_tail_x15_r0_body.st75.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st75.ks 0).getD 0) PRE_first_tail_x15_r0_body.st75.s0 PRE_first_tail_x15_r0_body.st75.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st75.s1, PRE_first_tail_x15_r0_body.st75.S1)
theorem PRE_first_tail_x15_r0_body.st75.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st75.F (PRE_first_tail_x15_r0_body.st75.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st75.ks 0).getD 0) PRE_first_tail_x15_r0_body.st75.s0 PRE_first_tail_x15_r0_body.st75.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st75.s1, PRE_first_tail_x15_r0_body.st75.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st75.bodyOkLN_ok PRE_first_tail_x15_r0_body.st75.bodyK0F
end Host.Load.Run.Tpl
end

section -- st75/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st75.bodyK1F from PRE_first_tail_x15_r0_body.st75.s1 to PRE_first_tail_x15_r0_body.st75.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st75.F (PRE_first_tail_x15_r0_body.st75.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st75.ks 1).getD 0) PRE_first_tail_x15_r0_body.st75.s1 PRE_first_tail_x15_r0_body.st75.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st75.s2, PRE_first_tail_x15_r0_body.st75.S2)
theorem PRE_first_tail_x15_r0_body.st75.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st75.F (PRE_first_tail_x15_r0_body.st75.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st75.ks 1).getD 0) PRE_first_tail_x15_r0_body.st75.s1 PRE_first_tail_x15_r0_body.st75.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st75.s2, PRE_first_tail_x15_r0_body.st75.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st75.bodyOkLN_ok PRE_first_tail_x15_r0_body.st75.bodyK1F
end Host.Load.Run.Tpl
end

section -- st75/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st75.bodyK2F from PRE_first_tail_x15_r0_body.st75.s2 to PRE_first_tail_x15_r0_body.st75.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st75.F (PRE_first_tail_x15_r0_body.st75.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st75.ks 2).getD 0) PRE_first_tail_x15_r0_body.st75.s2 PRE_first_tail_x15_r0_body.st75.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st75.s3, PRE_first_tail_x15_r0_body.st75.S3)
theorem PRE_first_tail_x15_r0_body.st75.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st75.F (PRE_first_tail_x15_r0_body.st75.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st75.ks 2).getD 0) PRE_first_tail_x15_r0_body.st75.s2 PRE_first_tail_x15_r0_body.st75.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st75.s3, PRE_first_tail_x15_r0_body.st75.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st75.bodyOkLN_ok PRE_first_tail_x15_r0_body.st75.bodyK2F
end Host.Load.Run.Tpl
end

section -- st75/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st75.bodyK3F from PRE_first_tail_x15_r0_body.st75.s3 to PRE_first_tail_x15_r0_body.st75.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st75.F (PRE_first_tail_x15_r0_body.st75.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st75.ks 3).getD 0) PRE_first_tail_x15_r0_body.st75.s3 PRE_first_tail_x15_r0_body.st75.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st75.s4, PRE_first_tail_x15_r0_body.st75.S4)
theorem PRE_first_tail_x15_r0_body.st75.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st75.F (PRE_first_tail_x15_r0_body.st75.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st75.ks 3).getD 0) PRE_first_tail_x15_r0_body.st75.s3 PRE_first_tail_x15_r0_body.st75.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st75.s4, PRE_first_tail_x15_r0_body.st75.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st75.bodyOkLN_ok PRE_first_tail_x15_r0_body.st75.bodyK3F
end Host.Load.Run.Tpl
end

section -- st75/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st75.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st75.F (PRE_first_tail_x15_r0_body.st75.bodyOkL bytes rows) 11334 PRE_first_tail_x15_r0_body.st75.s0 PRE_first_tail_x15_r0_body.st75.S0 = some (PRE_first_tail_x15_r0_body.st75.s4, PRE_first_tail_x15_r0_body.st75.S4) :=
  runOk_trans PRE_first_tail_x15_r0_body.st75.F (PRE_first_tail_x15_r0_body.st75.bodyOkL bytes rows) ((((nth? PRE_first_tail_x15_r0_body.st75.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st75.ks 1).getD 0)) + ((nth? PRE_first_tail_x15_r0_body.st75.ks 2).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st75.ks 3).getD 0) PRE_first_tail_x15_r0_body.st75.s0 PRE_first_tail_x15_r0_body.st75.s3 PRE_first_tail_x15_r0_body.st75.s4 PRE_first_tail_x15_r0_body.st75.S0 PRE_first_tail_x15_r0_body.st75.S3 PRE_first_tail_x15_r0_body.st75.S4 (runOk_trans PRE_first_tail_x15_r0_body.st75.F (PRE_first_tail_x15_r0_body.st75.bodyOkL bytes rows) (((nth? PRE_first_tail_x15_r0_body.st75.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st75.ks 1).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st75.ks 2).getD 0) PRE_first_tail_x15_r0_body.st75.s0 PRE_first_tail_x15_r0_body.st75.s2 PRE_first_tail_x15_r0_body.st75.s3 PRE_first_tail_x15_r0_body.st75.S0 PRE_first_tail_x15_r0_body.st75.S2 PRE_first_tail_x15_r0_body.st75.S3 (runOk_trans PRE_first_tail_x15_r0_body.st75.F (PRE_first_tail_x15_r0_body.st75.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st75.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st75.ks 1).getD 0) PRE_first_tail_x15_r0_body.st75.s0 PRE_first_tail_x15_r0_body.st75.s1 PRE_first_tail_x15_r0_body.st75.s2 PRE_first_tail_x15_r0_body.st75.S0 PRE_first_tail_x15_r0_body.st75.S1 PRE_first_tail_x15_r0_body.st75.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st75.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st75.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st75.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st75.bodyK3 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st75.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st75.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st75.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st75.F (PRE_first_tail_x15_r0_body.st75.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st75.s0
  S0 := PRE_first_tail_x15_r0_body.st75.S0
  s1 := PRE_first_tail_x15_r0_body.st75.s4
  S1 := PRE_first_tail_x15_r0_body.st75.S4
  s2 := PRE_first_tail_x15_r0_body.st75.s5
  S2 := PRE_first_tail_x15_r0_body.st75.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st75.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st75.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st75.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st75.bodyHalt
  last := PRE_first_tail_x15_r0_body.st75.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st75.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC76
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 76 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s745` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa76` into the merged state
`PRE_first_tail_x15_r0_body.s744`. -/

def PRE_first_tail_x15_r0_body.pl76 : List Nat := []
def PRE_first_tail_x15_r0_body.nr76 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd76 : RData :=
  ⟨2734711, 2734713, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19705, 19705, 16803, 16803, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa76 : Map :=
  Conv.Map.compact 2734711 2734713 3329 PRE_first_tail_x15_r0_body.pl76 (PRE_first_tail_x15_r0_body.nr76.map NumV.ref) PRE_first_tail_x15_r0_body.kd76.big
    PRE_first_tail_x15_r0_body.kd76.region PRE_first_tail_x15_r0_body.kd76.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws76 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs76 : List SymE := PRE_first_tail_x15_r0_body.nr76.map fun r => (nth? PRE_first_tail_x15_r0_body.S744.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta76 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws76 PRE_first_tail_x15_r0_body.crs76
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB76 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab76 : PRE_first_tail_x15_r0_body.S745.tab = PRE_first_tail_x15_r0_body.S743.tab ++ PRE_first_tail_x15_r0_body.cws76.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace76 : PRE_first_tail_x15_r0_body.s745.trace = PRE_first_tail_x15_r0_body.s743.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext76 : PRE_first_tail_x15_r0_body.s745.next = 2734711
kernel_rfl PRE_first_tail_x15_r0_body.ccounters76 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx.nnext) = (19705, 16803)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue76 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s744.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa76.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp76 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx.tokens.all (bSN 3329) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean76 : Conv.cleanListB 19705 131072 (fun r => Nat.ble 78820 r) PRE_first_tail_x15_r0_body.s745
    (PRE_first_tail_x15_r0_body.wrB76 ++ (List.range 0).map (2734711 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs76 : bigsOutB 19705 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK76
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl76`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl76 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo76 : List Nat := []
def PRE_first_tail_x15_r0_body.cln76 : List Nat := []
def PRE_first_tail_x15_r0_body.cli76 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap76 : PRE_first_tail_x15_r0_body.s745.heap = Stage.setAll PRE_first_tail_x15_r0_body.s743.heap (PRE_first_tail_x15_r0_body.cl76.filterMap fun a => (PRE_first_tail_x15_r0_body.s745.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe76 : Nat.ble PRE_first_tail_x15_r0_body.s743.next PRE_first_tail_x15_r0_body.s745.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP76 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s743 PRE_first_tail_x15_r0_body.s745 PRE_first_tail_x15_r0_body.cl76 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp76 : Conv.suppListB PRE_first_tail_x15_r0_body.s745 3329 PRE_first_tail_x15_r0_body.cl76 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound76 : Conv.boundListB PRE_first_tail_x15_r0_body.s745 PRE_first_tail_x15_r0_body.cl76 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK76 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln76.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK76 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo76.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK76 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli76.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst76 : Conv.sstListB 3329 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx PRE_first_tail_x15_r0_body.cln76 PRE_first_tail_x15_r0_body.clo76 PRE_first_tail_x15_r0_body.cli76 = true

end Host.Load.Run.Tpl
end

section -- SiteCl76
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA76 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo76.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd76 : (PRE_first_tail_x15_r0_body.clo76 ++ PRE_first_tail_x15_r0_body.cln76 ++ PRE_first_tail_x15_r0_body.cli76).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle76 : Conv.Cnt.leB (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck76 : Conv.ncleanListB (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx PRE_first_tail_x15_r0_body.clo76 PRE_first_tail_x15_r0_body.cln76 PRE_first_tail_x15_r0_body.cli76 = true
theorem PRE_first_tail_x15_r0_body.cncl76 (h : Conv.NClean (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx) : Conv.NClean (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle76 PRE_first_tail_x15_r0_body.ckA76 PRE_first_tail_x15_r0_body.cobjsK76 PRE_first_tail_x15_r0_body.cnodesK76 PRE_first_tail_x15_r0_body.citemsK76 PRE_first_tail_x15_r0_body.cbd76 PRE_first_tail_x15_r0_body.cck76

end Host.Load.Run.Tpl
end

section -- SiteS76
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 76 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc76 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P76 : LoadP := PRE_first_tail_x15_r0_body.Pc76.raise 16803
kernel_rfl PRE_first_tail_x15_r0_body.craise76 : Nat.ble PRE_first_tail_x15_r0_body.Pc76.N0 16803 = true
theorem PRE_first_tail_x15_r0_body.raised76 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc76 PRE_first_tail_x15_r0_body.P76 :=
  .inr ⟨16803, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise76, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_76 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_76 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s744.ffi)
def PRE_first_tail_x15_r0_body.khinv76 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv76 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS76 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS76 : List Nat := List.range' 16803 0
def PRE_first_tail_x15_r0_body.ciS76 : List Nat := [] ++ List.range' 16803 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh076 : PRE_first_tail_x15_r0_body.kd76.nh0 = PRE_first_tail_x15_r0_body.cx0_76.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh176 : PRE_first_tail_x15_r0_body.kd76.nh1 = PRE_first_tail_x15_r0_body.cx1_76.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn076 : PRE_first_tail_x15_r0_body.kd76.nn0 = PRE_first_tail_x15_r0_body.cx0_76.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn176 : PRE_first_tail_x15_r0_body.kd76.nn1 = PRE_first_tail_x15_r0_body.cx1_76.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo76 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P76.lo && Nat.ble PRE_first_tail_x15_r0_body.P76.lo PRE_first_tail_x15_r0_body.cx0_76.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P76.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P76.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt76 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_76.mlx.next PRE_first_tail_x15_r0_body.cx1_76.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_76.mlx.nnext PRE_first_tail_x15_r0_body.cx1_76.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband76 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P76.NL && Nat.ble PRE_first_tail_x15_r0_body.P76.NL PRE_first_tail_x15_r0_body.P76.N0 && Nat.ble PRE_first_tail_x15_r0_body.P76.N0 PRE_first_tail_x15_r0_body.cx0_76.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow76 : PRE_first_tail_x15_r0_body.kd76.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren76 : checkRenG PRE_first_tail_x15_r0_body.kd76.hnd PRE_first_tail_x15_r0_body.khinv76 (phB PRE_first_tail_x15_r0_body.cx0_76.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband76 : PRE_first_tail_x15_r0_body.kd76.checkBand PRE_first_tail_x15_r0_body.P76.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos76 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd76.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren76 : checkRenG PRE_first_tail_x15_r0_body.kd76.node PRE_first_tail_x15_r0_body.kninv76 (pnB PRE_first_tail_x15_r0_body.cx0_76.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow76 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd76.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P76.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd76.nodeF j) PRE_first_tail_x15_r0_body.cx1_76.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a76 : PRE_first_tail_x15_r0_body.cx0_76.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b76 : PRE_first_tail_x15_r0_body.cx0_76.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok176 : PRE_first_tail_x15_r0_body.cx1_76.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend76 : PRE_first_tail_x15_r0_body.cx1_76.mlx.pending = PRE_first_tail_x15_r0_body.cx0_76.mlx.pending.map PRE_first_tail_x15_r0_body.kappa76.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh76 : PRE_first_tail_x15_r0_body.cx1_76.mlx.errh = PRE_first_tail_x15_r0_body.cx0_76.mlx.errh.map PRE_first_tail_x15_r0_body.kappa76.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles76 : PRE_first_tail_x15_r0_body.cx1_76.mlx.files = PRE_first_tail_x15_r0_body.cx0_76.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch76 : PRE_first_tail_x15_r0_body.cx1_76.mlx.arch = PRE_first_tail_x15_r0_body.cx0_76.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes76 : PRE_first_tail_x15_r0_body.cx1_76.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_76.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired76 : PRE_first_tail_x15_r0_body.cx1_76.mlx.wired = PRE_first_tail_x15_r0_body.cx0_76.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost76 : PRE_first_tail_x15_r0_body.cx1_76.host = PRE_first_tail_x15_r0_body.cx0_76.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd76`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn076 : PRE_first_tail_x15_r0_body.kd76.n0 = 2734711
kernel_rfl PRE_first_tail_x15_r0_body.ckn176 : PRE_first_tail_x15_r0_body.kd76.n1 = 2734713
kernel_rfl PRE_first_tail_x15_r0_body.ckheap76 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd76.heap).all (fun x => Nat.ble 2734711 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl76 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd76.heap.get (2734711 + j) = nth? PRE_first_tail_x15_r0_body.pl76 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja76 : Nat.ble 2734711 2734711 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn76 : Nat.ble 3329 3329 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD76 : Nat.ble 2734711 PRE_first_tail_x15_r0_body.kd76.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn76 : Nat.ble 19705 PRE_first_tail_x15_r0_body.kd76.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn76 : Nat.ble 16803 PRE_first_tail_x15_r0_body.kd76.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb76 : Nat.ble 19705 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap76 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd76.heap).all (Nat.ble (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd76 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd76.hnd).all (Nat.ble (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode76 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd76.node).all (Nat.ble (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix76 : Conv.FixOld (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa76 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja76) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn76) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD76) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn76) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn76) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb76) PRE_first_tail_x15_r0_body.fheap76 PRE_first_tail_x15_r0_body.fhnd76 PRE_first_tail_x15_r0_body.fnode76
kernel_rfl PRE_first_tail_x15_r0_body.fcxn76 : (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn76 : (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle076 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_76.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_76.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk76 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd76.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A76 : PRE_first_tail_x15_r0_body.cx1_76.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS76.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_76.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O76 : PRE_first_tail_x15_r0_body.cx1_76.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS76.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_76.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N76 : PRE_first_tail_x15_r0_body.cx1_76.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS76.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_76.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I76 : PRE_first_tail_x15_r0_body.cx1_76.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS76.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_76.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd76 : (PRE_first_tail_x15_r0_body.clo76 ++ PRE_first_tail_x15_r0_body.cln76 ++ PRE_first_tail_x15_r0_body.cli76 ++ PRE_first_tail_x15_r0_body.cwS76 ++ PRE_first_tail_x15_r0_body.cnS76 ++ PRE_first_tail_x15_r0_body.ciS76).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW76 : PRE_first_tail_x15_r0_body.cwS76.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo76.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI76 : PRE_first_tail_x15_r0_body.ciS76.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli76.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN76 : PRE_first_tail_x15_r0_body.cnS76.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF76 : PRE_first_tail_x15_r0_body.cln76.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh76 : PRE_first_tail_x15_r0_body.clo76.all (handleOK PRE_first_tail_x15_r0_body.kappa76 PRE_first_tail_x15_r0_body.P76.lo PRE_first_tail_x15_r0_body.cx0_76.mlx PRE_first_tail_x15_r0_body.cx1_76.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo76 : PRE_first_tail_x15_r0_body.clo76.map (fun h => PRE_first_tail_x15_r0_body.cx1_76.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa76.handle h)) = PRE_first_tail_x15_r0_body.clo76.map (fun h => (PRE_first_tail_x15_r0_body.cx0_76.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa76.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok76 : PRE_first_tail_x15_r0_body.clo76.all (objOK PRE_first_tail_x15_r0_body.kappa76 PRE_first_tail_x15_r0_body.P76.NL PRE_first_tail_x15_r0_body.cx0_76.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd76 : PRE_first_tail_x15_r0_body.cln76.all (nodeOKF PRE_first_tail_x15_r0_body.kappa76 PRE_first_tail_x15_r0_body.P76 PRE_first_tail_x15_r0_body.cx0_76.mlx PRE_first_tail_x15_r0_body.cx1_76.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp76 : ((PRE_first_tail_x15_r0_body.cln76.filter (fullB PRE_first_tail_x15_r0_body.P76))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_76.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa76.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln76.filter (fullB PRE_first_tail_x15_r0_body.P76))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_76.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa76.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI76 : incrB PRE_first_tail_x15_r0_body.kd76.nodeF (List.range' 16803 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK76 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd76.node).all (fun k => Nat.ble 16803 k && Nat.blt k 16803) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL76 : (PRE_first_tail_x15_r0_body.cln76.filter (Nat.ble PRE_first_tail_x15_r0_body.P76.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd76.nodeF i) && (Nat.blt i 16803 || Nat.ble PRE_first_tail_x15_r0_body.kd76.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord76 : (PRE_first_tail_x15_r0_body.cln76.filter (Nat.ble PRE_first_tail_x15_r0_body.P76.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd76.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd76.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd76.nodeF j) (PRE_first_tail_x15_r0_body.kd76.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow76 PRE_first_tail_x15_r0_body.cnn176 PRE_first_tail_x15_r0_body.fnordI76 PRE_first_tail_x15_r0_body.fnordK76 PRE_first_tail_x15_r0_body.fnordL76
kernel_rfl PRE_first_tail_x15_r0_body.fi76 : PRE_first_tail_x15_r0_body.cli76.all (pnB PRE_first_tail_x15_r0_body.cx0_76.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii76 : PRE_first_tail_x15_r0_body.cli76.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_76.mlx.items.get (PRE_first_tail_x15_r0_body.kappa76.node k) = (PRE_first_tail_x15_r0_body.cx0_76.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa76.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot76 (clean : Conv.NClean (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P76.NL) (cl : SSt (· < 3329) PRE_first_tail_x15_r0_body.cx0_76.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P76 3329 PRE_first_tail_x15_r0_body.kappa76 PRE_first_tail_x15_r0_body.kd76 PRE_first_tail_x15_r0_body.khinv76 PRE_first_tail_x15_r0_body.kninv76 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx PRE_first_tail_x15_r0_body.cx0_76.mlx PRE_first_tail_x15_r0_body.cx1_76.mlx (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo76 PRE_first_tail_x15_r0_body.cln76 PRE_first_tail_x15_r0_body.cli76 PRE_first_tail_x15_r0_body.cwS76 PRE_first_tail_x15_r0_body.cnS76 PRE_first_tail_x15_r0_body.ciS76 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh076, PRE_first_tail_x15_r0_body.cnh176, PRE_first_tail_x15_r0_body.cnn076, PRE_first_tail_x15_r0_body.cnn176, PRE_first_tail_x15_r0_body.cplo76, PRE_first_tail_x15_r0_body.ccnt76, PRE_first_tail_x15_r0_body.cnband76, PRE_first_tail_x15_r0_body.chbelow76, PRE_first_tail_x15_r0_body.chren76, PRE_first_tail_x15_r0_body.cband76, PRE_first_tail_x15_r0_body.cnh1pos76, PRE_first_tail_x15_r0_body.cnren76, PRE_first_tail_x15_r0_body.cnlow76, PRE_first_tail_x15_r0_body.cabs0a76, PRE_first_tail_x15_r0_body.cabs0b76, PRE_first_tail_x15_r0_body.ctok176, PRE_first_tail_x15_r0_body.cpend76, PRE_first_tail_x15_r0_body.cerrh76, PRE_first_tail_x15_r0_body.cfiles76, PRE_first_tail_x15_r0_body.carch76, PRE_first_tail_x15_r0_body.csizes76, PRE_first_tail_x15_r0_body.cwired76, PRE_first_tail_x15_r0_body.cfix76, clean, PRE_first_tail_x15_r0_body.fcxn76, PRE_first_tail_x15_r0_body.fcnn76, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle076, PRE_first_tail_x15_r0_body.fnk76, PRE_first_tail_x15_r0_body.ckA76, PRE_first_tail_x15_r0_body.cobjsK76, PRE_first_tail_x15_r0_body.cnodesK76, PRE_first_tail_x15_r0_body.citemsK76, PRE_first_tail_x15_r0_body.f1A76, PRE_first_tail_x15_r0_body.f1O76, PRE_first_tail_x15_r0_body.f1N76, PRE_first_tail_x15_r0_body.f1I76, PRE_first_tail_x15_r0_body.fbd76, PRE_first_tail_x15_r0_body.fincW76, PRE_first_tail_x15_r0_body.fincI76, PRE_first_tail_x15_r0_body.fincN76, PRE_first_tail_x15_r0_body.flnF76, PRE_first_tail_x15_r0_body.fh76, PRE_first_tail_x15_r0_body.fo76, PRE_first_tail_x15_r0_body.fok76, PRE_first_tail_x15_r0_body.fnd76, PRE_first_tail_x15_r0_body.fp76, PRE_first_tail_x15_r0_body.fnord76, PRE_first_tail_x15_r0_body.fi76, PRE_first_tail_x15_r0_body.fii76⟩
theorem PRE_first_tail_x15_r0_body.cnshift76 (clean : Conv.NClean (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P76.NL) (cl : SSt (· < 3329) PRE_first_tail_x15_r0_body.cx0_76.mlx) : NShift PRE_first_tail_x15_r0_body.P76 3329 PRE_first_tail_x15_r0_body.kappa76 PRE_first_tail_x15_r0_body.cx0_76 PRE_first_tail_x15_r0_body.cx1_76 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot76 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost76 (compact_a_eq PRE_first_tail_x15_r0_body.ckn076 PRE_first_tail_x15_r0_body.ckn176 PRE_first_tail_x15_r0_body.ckheap76 PRE_first_tail_x15_r0_body.ckpl76)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_76 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s743.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_76 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s743.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_76 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s743.ffi) = some PRE_first_tail_x15_r0_body.fxC_76
kernel_rfl PRE_first_tail_x15_r0_body.okrC_76 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s743.ffi) = some PRE_first_tail_x15_r0_body.krC_76
noncomputable def PRE_first_tail_x15_r0_body.fx0_76 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s745.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_76 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s745.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_76 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s745.ffi) = some PRE_first_tail_x15_r0_body.fx0_76
kernel_rfl PRE_first_tail_x15_r0_body.okr0_76 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s745.ffi) = some PRE_first_tail_x15_r0_body.kr0_76
noncomputable def PRE_first_tail_x15_r0_body.fx1_76 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s744.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_76 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s744.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_76 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s744.ffi) = some PRE_first_tail_x15_r0_body.fx1_76
kernel_rfl PRE_first_tail_x15_r0_body.okr1_76 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s744.ffi) = some PRE_first_tail_x15_r0_body.kr1_76
kernel_rfl PRE_first_tail_x15_r0_body.ff076 : PRE_first_tail_x15_r0_body.fx0_76 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_76 (PRE_first_tail_x15_r0_body.clo76.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_76.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff176 : PRE_first_tail_x15_r0_body.fx1_76 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_76 (PRE_first_tail_x15_r0_body.cwS76.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_76.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck76 : freedLB PRE_first_tail_x15_r0_body.kappa76 PRE_first_tail_x15_r0_body.cx0_76.mlx PRE_first_tail_x15_r0_body.fx0_76 PRE_first_tail_x15_r0_body.fx1_76 PRE_first_tail_x15_r0_body.clo76 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf076 : PRE_first_tail_x15_r0_body.kr0_76.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_76.flags (PRE_first_tail_x15_r0_body.clo76.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_76.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt076 : PRE_first_tail_x15_r0_body.kr0_76.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_76.targs (PRE_first_tail_x15_r0_body.clo76.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_76.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf176 : PRE_first_tail_x15_r0_body.kr1_76.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_76.flags (PRE_first_tail_x15_r0_body.cwS76.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_76.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt176 : PRE_first_tail_x15_r0_body.kr1_76.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_76.targs (PRE_first_tail_x15_r0_body.cwS76.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_76.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck76 : krecLB PRE_first_tail_x15_r0_body.kappa76 3329 PRE_first_tail_x15_r0_body.cx0_76.mlx PRE_first_tail_x15_r0_body.kr0_76 PRE_first_tail_x15_r0_body.kr1_76 PRE_first_tail_x15_r0_body.clo76 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn76 : Nat.ble 3329 3329 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge76 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s744.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s745.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR76 : pendRegB PRE_first_tail_x15_r0_body.kappa76 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe76 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s744.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift76 (clean : Conv.NClean (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P76.NL) (cl : SSt (· < 3329) PRE_first_tail_x15_r0_body.cx0_76.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_76.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_76.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_76.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_76.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P76 3329 PRE_first_tail_x15_r0_body.kappa76 PRE_first_tail_x15_r0_body.s745.ffi PRE_first_tail_x15_r0_body.s744.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift76 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue76, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp76 t ht),
    PRE_first_tail_x15_r0_body.cbridge76,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s745.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s744.ffi) (PRE_first_tail_x15_r0_body.cfoot76 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_76 PRE_first_tail_x15_r0_body.ofx1_76 hobjC PRE_first_tail_x15_r0_body.ff076 PRE_first_tail_x15_r0_body.ff176 PRE_first_tail_x15_r0_body.ffck76,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s745.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s744.ffi) (PRE_first_tail_x15_r0_body.cfoot76 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_76 PRE_first_tail_x15_r0_body.okr1_76 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn76) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf076 PRE_first_tail_x15_r0_body.fkt076 PRE_first_tail_x15_r0_body.fkf176 PRE_first_tail_x15_r0_body.fkt176 PRE_first_tail_x15_r0_body.fkck76,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh076 PRE_first_tail_x15_r0_body.cnh176 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe76) PRE_first_tail_x15_r0_body.cpendR76⟩

end Host.Load.Run.Tpl
end

section -- st76/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st76 0
host_stream_state PRE_first_tail_x15_r0_body.st76 1
host_stream_state PRE_first_tail_x15_r0_body.st76 2
end Host.Load.Run.Tpl
end

section -- Site76
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 76 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g76__g77` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s743`, the merged state `PRE_first_tail_x15_r0_body.s744`,
the site template `PRE_first_tail_x15_r0_body.st76` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s745`: the merge.
The footprint's facts are in `SiteF76`, the compaction's in `SiteC76`, `SiteK76`, `SiteNa76`, `SiteNb76`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso76 : PRE_first_tail_x15_r0_body.st76.s0 = { PRE_first_tail_x15_r0_body.s743 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs76 : List Frame := PRE_first_tail_x15_r0_body.s743.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_76 : PRE_first_tail_x15_r0_body.S743.tab.length = 3329
kernel_rfl PRE_first_tail_x15_r0_body.tab0_76 : PRE_first_tail_x15_r0_body.st76.S0.tab = PRE_first_tail_x15_r0_body.S743.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws76 : List Nat := [2303, 2304]
kernel_rfl PRE_first_tail_x15_r0_body.fresh76 : (PRE_first_tail_x15_r0_body.S743.tab.all fun e => PRE_first_tail_x15_r0_body.ws76.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S743.oracle.all fun q => PRE_first_tail_x15_r0_body.ws76.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab76 : PRE_first_tail_x15_r0_body.S744.tab = PRE_first_tail_x15_r0_body.S743.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws76
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen76 : PRE_first_tail_x15_r0_body.st76.S2.tab.length - PRE_first_tail_x15_r0_body.st76.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged76`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap76 : PRE_first_tail_x15_r0_body.s744.heap = PRE_first_tail_x15_r0_body.st76.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext76 : PRE_first_tail_x15_r0_body.s744.next = PRE_first_tail_x15_r0_body.st76.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl76 : PRE_first_tail_x15_r0_body.s744.ctl = PRE_first_tail_x15_r0_body.st76.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack76 : PRE_first_tail_x15_r0_body.s744.stack = PRE_first_tail_x15_r0_body.st76.s2.stack ++ PRE_first_tail_x15_r0_body.s743.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs76 : PRE_first_tail_x15_r0_body.s744.jobs = PRE_first_tail_x15_r0_body.st76.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi76 : PRE_first_tail_x15_r0_body.s744.ffi = PRE_first_tail_x15_r0_body.st76.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace76 : PRE_first_tail_x15_r0_body.s744.trace = PRE_first_tail_x15_r0_body.st76.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores76 : PRE_first_tail_x15_r0_body.s744.stores = PRE_first_tail_x15_r0_body.st76.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD76
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 76 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived76 : PRE_first_tail_x15_r0_body.nr76.map (fun r => nth? PRE_first_tail_x15_r0_body.st76.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo76 : PRE_first_tail_x15_r0_body.nr76.all (Nat.ble 3329) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj76 : PRE_first_tail_x15_r0_body.cws76.all (fun c => !PRE_first_tail_x15_r0_body.ws76.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ76 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws76 PRE_first_tail_x15_r0_body.crs76 PRE_first_tail_x15_r0_body.ws76

end Host.Load.Run.Tpl
end

section -- st76/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st76`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st76.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st76.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st76.s2.heap PRE_first_tail_x15_r0_body.st76.wrR ++ freshOf PRE_first_tail_x15_r0_body.st76.s2.heap PRE_first_tail_x15_r0_body.st76.s0.next PRE_first_tail_x15_r0_body.st76.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st76.wr : List Nat := PRE_first_tail_x15_r0_body.st76.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st76.heapFoot : PRE_first_tail_x15_r0_body.st76.s2.heap = setAll PRE_first_tail_x15_r0_body.st76.s0.heap PRE_first_tail_x15_r0_body.st76.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st76.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st76.s0.next PRE_first_tail_x15_r0_body.st76.s2.next = true
theorem PRE_first_tail_x15_r0_body.st76.grows : PRE_first_tail_x15_r0_body.st76.s0.next ≤ PRE_first_tail_x15_r0_body.st76.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st76.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st76.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st76.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st76.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st76.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st76.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st76.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st76.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st76.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st76.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st76.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st76.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st76.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st76.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st76.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st76.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st76.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st76.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st76.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st76.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st76.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st76.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st76.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st76.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st76.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st76.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st76.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st76.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st76.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st76.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st76.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st76.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF76
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 76 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB76 : nodupT PRE_first_tail_x15_r0_body.st76.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup76 : PRE_first_tail_x15_r0_body.st76.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB76).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB76 : PRE_first_tail_x15_r0_body.st76.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound76 : ∀ b ∈ PRE_first_tail_x15_r0_body.st76.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB76 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr76 := PRE_first_tail_x15_r0_body.st76.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq76 : PRE_first_tail_x15_r0_body.st76.s2.trace = PRE_first_tail_x15_r0_body.trFr76 ++ PRE_first_tail_x15_r0_body.st76.s0.trace
theorem PRE_first_tail_x15_r0_body.trace76 : ∃ fr, PRE_first_tail_x15_r0_body.st76.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st76.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq76⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide76 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB76 : (PRE_first_tail_x15_r0_body.wide76.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st76.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix76 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide76, WFix Map.id (Present PRE_first_tail_x15_r0_body.st76.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB76 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL76
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 76 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s744`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO76 : PRE_first_tail_x15_r0_body.st76.S0.oracle = PRE_first_tail_x15_r0_body.st76.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B76 : PRE_first_tail_x15_r0_body.st76.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st76.s0.next || (PRE_first_tail_x15_r0_body.st76.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot76 : Conv.StageFoot PRE_first_tail_x15_r0_body.st76.wr PRE_first_tail_x15_r0_body.st76.s0 PRE_first_tail_x15_r0_body.st76.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st76.heapFoot PRE_first_tail_x15_r0_body.wrNodup76 PRE_first_tail_x15_r0_body.wrBound76 PRE_first_tail_x15_r0_body.wr0B76 PRE_first_tail_x15_r0_body.st76.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged76 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st76.F.S → PRE_first_tail_x15_r0_body.st76.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st76.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st76.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs76 PRE_first_tail_x15_r0_body.st76.wr PRE_first_tail_x15_r0_body.s743 PRE_first_tail_x15_r0_body.st76.s2 PRE_first_tail_x15_r0_body.st76.s0
      PRE_first_tail_x15_r0_body.st76.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st76.F FR W stk M ν K PRE_first_tail_x15_r0_body.s744 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso76 PRE_first_tail_x15_r0_body.stFoot76 PRE_first_tail_x15_r0_body.wrNodup76 PRE_first_tail_x15_r0_body.wrBound76 PRE_first_tail_x15_r0_body.trace76 PRE_first_tail_x15_r0_body.mheap76
    PRE_first_tail_x15_r0_body.mnext76 PRE_first_tail_x15_r0_body.mctl76 PRE_first_tail_x15_r0_body.mstack76 PRE_first_tail_x15_r0_body.mjobs76 PRE_first_tail_x15_r0_body.mffi76 PRE_first_tail_x15_r0_body.mtrace76 PRE_first_tail_x15_r0_body.mstores76 h

def PRE_first_tail_x15_r0_body.arrEl76_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE76_2665 : arrOf PRE_first_tail_x15_r0_body.s744 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl76_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA76_2665 : isArrB PRE_first_tail_x15_r0_body.s744 2665 = true
theorem PRE_first_tail_x15_r0_body.arr76_2665 : ∃ o, PRE_first_tail_x15_r0_body.s744.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl76_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE76_2665 PRE_first_tail_x15_r0_body.arrA76_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN76_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl76_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR76_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl76_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN76_2665

def PRE_first_tail_x15_r0_body.arrEl76_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE76_2673467 : arrOf PRE_first_tail_x15_r0_body.s744 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl76_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA76_2673467 : isArrB PRE_first_tail_x15_r0_body.s744 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr76_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s744.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl76_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE76_2673467 PRE_first_tail_x15_r0_body.arrA76_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN76_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl76_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR76_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl76_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN76_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k76 : isArrB PRE_first_tail_x15_r0_body.s744 4910 = false
theorem PRE_first_tail_x15_r0_body.keep76 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s744 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k76 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr76_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl76_2665]

end Host.Load.Run.Tpl
end

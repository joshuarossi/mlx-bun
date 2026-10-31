import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl42
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 42 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc42 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P42 : LoadP := PRE_first_tail_x15_r0_body.Pc42.raise 16142
kernel_rfl PRE_first_tail_x15_r0_body.craise42 : Nat.ble PRE_first_tail_x15_r0_body.Pc42.N0 16142 = true
theorem PRE_first_tail_x15_r0_body.raised42 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc42 PRE_first_tail_x15_r0_body.P42 :=
  .inr ⟨16142, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise42, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_42 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s385.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_42 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s384.ffi)
def PRE_first_tail_x15_r0_body.khinv42 : PTrie Nat := Stage.setAll PTrie.nil [(19064, 19038), (19042, 19039), (19065, 19040)]
def PRE_first_tail_x15_r0_body.kninv42 : PTrie Nat := Stage.setAll PTrie.nil [(16115, 16115), (16116, 16116), (16117, 16117), (16118, 16118), (16119, 16119), (16120, 16120), (16121, 16121), (16122, 16122), (16123, 16123), (16124, 16124), (16125, 16125), (16126, 16126), (16127, 16127), (16128, 16128), (16129, 16129), (16130, 16130), (16131, 16131), (16132, 16132), (16133, 16133), (16134, 16134), (16135, 16135), (16136, 16136), (16137, 16137), (16138, 16138), (16139, 16139), (16140, 16140), (16141, 16141)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS42 : List Nat := [19018, 19031, 19037, 19038, 19039, 19040, 19041, 19042, 19043, 19044, 19045, 19046, 19047, 19048, 19049, 19050, 19051, 19052, 19053, 19054, 19055, 19056, 19057, 19058, 19059, 19060, 19061, 19062, 19063, 19064, 19065]
def PRE_first_tail_x15_r0_body.cnS42 : List Nat := List.range' 16115 27
def PRE_first_tail_x15_r0_body.ciS42 : List Nat := [] ++ List.range' 16115 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh042 : PRE_first_tail_x15_r0_body.kd42.nh0 = PRE_first_tail_x15_r0_body.cx0_42.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh142 : PRE_first_tail_x15_r0_body.kd42.nh1 = PRE_first_tail_x15_r0_body.cx1_42.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn042 : PRE_first_tail_x15_r0_body.kd42.nn0 = PRE_first_tail_x15_r0_body.cx0_42.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn142 : PRE_first_tail_x15_r0_body.kd42.nn1 = PRE_first_tail_x15_r0_body.cx1_42.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo42 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P42.lo && Nat.ble PRE_first_tail_x15_r0_body.P42.lo PRE_first_tail_x15_r0_body.cx0_42.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P42.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P42.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt42 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_42.mlx.next PRE_first_tail_x15_r0_body.cx1_42.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_42.mlx.nnext PRE_first_tail_x15_r0_body.cx1_42.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband42 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P42.NL && Nat.ble PRE_first_tail_x15_r0_body.P42.NL PRE_first_tail_x15_r0_body.P42.N0 && Nat.ble PRE_first_tail_x15_r0_body.P42.N0 PRE_first_tail_x15_r0_body.cx0_42.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow42 : PRE_first_tail_x15_r0_body.kd42.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren42 : checkRenG PRE_first_tail_x15_r0_body.kd42.hnd PRE_first_tail_x15_r0_body.khinv42 (phB PRE_first_tail_x15_r0_body.cx0_42.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband42 : PRE_first_tail_x15_r0_body.kd42.checkBand PRE_first_tail_x15_r0_body.P42.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos42 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd42.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren42 : checkRenG PRE_first_tail_x15_r0_body.kd42.node PRE_first_tail_x15_r0_body.kninv42 (pnB PRE_first_tail_x15_r0_body.cx0_42.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow42 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd42.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P42.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd42.nodeF j) PRE_first_tail_x15_r0_body.cx1_42.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a42 : PRE_first_tail_x15_r0_body.cx0_42.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b42 : PRE_first_tail_x15_r0_body.cx0_42.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok142 : PRE_first_tail_x15_r0_body.cx1_42.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend42 : PRE_first_tail_x15_r0_body.cx1_42.mlx.pending = PRE_first_tail_x15_r0_body.cx0_42.mlx.pending.map PRE_first_tail_x15_r0_body.kappa42.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh42 : PRE_first_tail_x15_r0_body.cx1_42.mlx.errh = PRE_first_tail_x15_r0_body.cx0_42.mlx.errh.map PRE_first_tail_x15_r0_body.kappa42.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles42 : PRE_first_tail_x15_r0_body.cx1_42.mlx.files = PRE_first_tail_x15_r0_body.cx0_42.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch42 : PRE_first_tail_x15_r0_body.cx1_42.mlx.arch = PRE_first_tail_x15_r0_body.cx0_42.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes42 : PRE_first_tail_x15_r0_body.cx1_42.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_42.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired42 : PRE_first_tail_x15_r0_body.cx1_42.mlx.wired = PRE_first_tail_x15_r0_body.cx0_42.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost42 : PRE_first_tail_x15_r0_body.cx1_42.host = PRE_first_tail_x15_r0_body.cx0_42.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd42`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn042 : PRE_first_tail_x15_r0_body.kd42.n0 = 2708225
kernel_rfl PRE_first_tail_x15_r0_body.ckn142 : PRE_first_tail_x15_r0_body.kd42.n1 = 2709374
kernel_rfl PRE_first_tail_x15_r0_body.ckheap42 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd42.heap).all (fun x => Nat.ble 2708219 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl42 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd42.heap.get (2708219 + j) = nth? PRE_first_tail_x15_r0_body.pl42 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja42 : Nat.ble 2708219 2708219 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn42 : Nat.ble 1880 1880 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD42 : Nat.ble 2708219 PRE_first_tail_x15_r0_body.kd42.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn42 : Nat.ble 19038 PRE_first_tail_x15_r0_body.kd42.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn42 : Nat.ble 16115 PRE_first_tail_x15_r0_body.kd42.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb42 : Nat.ble 19038 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap42 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd42.heap).all (Nat.ble (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd42 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd42.hnd).all (Nat.ble (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode42 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd42.node).all (Nat.ble (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix42 : Conv.FixOld (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa42 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja42) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn42) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD42) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn42) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn42) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb42) PRE_first_tail_x15_r0_body.fheap42 PRE_first_tail_x15_r0_body.fhnd42 PRE_first_tail_x15_r0_body.fnode42
kernel_rfl PRE_first_tail_x15_r0_body.fcxn42 : (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn42 : (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle042 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_42.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_42.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk42 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd42.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A42 : PRE_first_tail_x15_r0_body.cx1_42.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS42.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_42.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O42 : PRE_first_tail_x15_r0_body.cx1_42.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS42.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_42.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N42 : PRE_first_tail_x15_r0_body.cx1_42.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS42.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_42.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I42 : PRE_first_tail_x15_r0_body.cx1_42.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS42.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_42.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd42 : (PRE_first_tail_x15_r0_body.clo42 ++ PRE_first_tail_x15_r0_body.cln42 ++ PRE_first_tail_x15_r0_body.cli42 ++ PRE_first_tail_x15_r0_body.cwS42 ++ PRE_first_tail_x15_r0_body.cnS42 ++ PRE_first_tail_x15_r0_body.ciS42).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW42 : PRE_first_tail_x15_r0_body.cwS42.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo42.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI42 : PRE_first_tail_x15_r0_body.ciS42.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli42.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN42 : PRE_first_tail_x15_r0_body.cnS42.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF42 : PRE_first_tail_x15_r0_body.cln42.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh42 : PRE_first_tail_x15_r0_body.clo42.all (handleOK PRE_first_tail_x15_r0_body.kappa42 PRE_first_tail_x15_r0_body.P42.lo PRE_first_tail_x15_r0_body.cx0_42.mlx PRE_first_tail_x15_r0_body.cx1_42.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo42 : PRE_first_tail_x15_r0_body.clo42.map (fun h => PRE_first_tail_x15_r0_body.cx1_42.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa42.handle h)) = PRE_first_tail_x15_r0_body.clo42.map (fun h => (PRE_first_tail_x15_r0_body.cx0_42.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa42.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok42 : PRE_first_tail_x15_r0_body.clo42.all (objOK PRE_first_tail_x15_r0_body.kappa42 PRE_first_tail_x15_r0_body.P42.NL PRE_first_tail_x15_r0_body.cx0_42.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd42 : PRE_first_tail_x15_r0_body.cln42.all (nodeOKF PRE_first_tail_x15_r0_body.kappa42 PRE_first_tail_x15_r0_body.P42 PRE_first_tail_x15_r0_body.cx0_42.mlx PRE_first_tail_x15_r0_body.cx1_42.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp42 : ((PRE_first_tail_x15_r0_body.cln42.filter (fullB PRE_first_tail_x15_r0_body.P42))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_42.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa42.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln42.filter (fullB PRE_first_tail_x15_r0_body.P42))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_42.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa42.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI42 : incrB PRE_first_tail_x15_r0_body.kd42.nodeF (List.range' 16115 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK42 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd42.node).all (fun k => Nat.ble 16115 k && Nat.blt k 16142) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL42 : (PRE_first_tail_x15_r0_body.cln42.filter (Nat.ble PRE_first_tail_x15_r0_body.P42.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd42.nodeF i) && (Nat.blt i 16142 || Nat.ble PRE_first_tail_x15_r0_body.kd42.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord42 : (PRE_first_tail_x15_r0_body.cln42.filter (Nat.ble PRE_first_tail_x15_r0_body.P42.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd42.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd42.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd42.nodeF j) (PRE_first_tail_x15_r0_body.kd42.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow42 PRE_first_tail_x15_r0_body.cnn142 PRE_first_tail_x15_r0_body.fnordI42 PRE_first_tail_x15_r0_body.fnordK42 PRE_first_tail_x15_r0_body.fnordL42
kernel_rfl PRE_first_tail_x15_r0_body.fi42 : PRE_first_tail_x15_r0_body.cli42.all (pnB PRE_first_tail_x15_r0_body.cx0_42.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii42 : PRE_first_tail_x15_r0_body.cli42.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_42.mlx.items.get (PRE_first_tail_x15_r0_body.kappa42.node k) = (PRE_first_tail_x15_r0_body.cx0_42.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa42.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot42 (clean : Conv.NClean (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P42.NL) (cl : SSt (· < 1898) PRE_first_tail_x15_r0_body.cx0_42.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P42 1898 PRE_first_tail_x15_r0_body.kappa42 PRE_first_tail_x15_r0_body.kd42 PRE_first_tail_x15_r0_body.khinv42 PRE_first_tail_x15_r0_body.kninv42 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx PRE_first_tail_x15_r0_body.cx0_42.mlx PRE_first_tail_x15_r0_body.cx1_42.mlx (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo42 PRE_first_tail_x15_r0_body.cln42 PRE_first_tail_x15_r0_body.cli42 PRE_first_tail_x15_r0_body.cwS42 PRE_first_tail_x15_r0_body.cnS42 PRE_first_tail_x15_r0_body.ciS42 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh042, PRE_first_tail_x15_r0_body.cnh142, PRE_first_tail_x15_r0_body.cnn042, PRE_first_tail_x15_r0_body.cnn142, PRE_first_tail_x15_r0_body.cplo42, PRE_first_tail_x15_r0_body.ccnt42, PRE_first_tail_x15_r0_body.cnband42, PRE_first_tail_x15_r0_body.chbelow42, PRE_first_tail_x15_r0_body.chren42, PRE_first_tail_x15_r0_body.cband42, PRE_first_tail_x15_r0_body.cnh1pos42, PRE_first_tail_x15_r0_body.cnren42, PRE_first_tail_x15_r0_body.cnlow42, PRE_first_tail_x15_r0_body.cabs0a42, PRE_first_tail_x15_r0_body.cabs0b42, PRE_first_tail_x15_r0_body.ctok142, PRE_first_tail_x15_r0_body.cpend42, PRE_first_tail_x15_r0_body.cerrh42, PRE_first_tail_x15_r0_body.cfiles42, PRE_first_tail_x15_r0_body.carch42, PRE_first_tail_x15_r0_body.csizes42, PRE_first_tail_x15_r0_body.cwired42, PRE_first_tail_x15_r0_body.cfix42, clean, PRE_first_tail_x15_r0_body.fcxn42, PRE_first_tail_x15_r0_body.fcnn42, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle042, PRE_first_tail_x15_r0_body.fnk42, PRE_first_tail_x15_r0_body.ckA42, PRE_first_tail_x15_r0_body.cobjsK42, PRE_first_tail_x15_r0_body.cnodesK42, PRE_first_tail_x15_r0_body.citemsK42, PRE_first_tail_x15_r0_body.f1A42, PRE_first_tail_x15_r0_body.f1O42, PRE_first_tail_x15_r0_body.f1N42, PRE_first_tail_x15_r0_body.f1I42, PRE_first_tail_x15_r0_body.fbd42, PRE_first_tail_x15_r0_body.fincW42, PRE_first_tail_x15_r0_body.fincI42, PRE_first_tail_x15_r0_body.fincN42, PRE_first_tail_x15_r0_body.flnF42, PRE_first_tail_x15_r0_body.fh42, PRE_first_tail_x15_r0_body.fo42, PRE_first_tail_x15_r0_body.fok42, PRE_first_tail_x15_r0_body.fnd42, PRE_first_tail_x15_r0_body.fp42, PRE_first_tail_x15_r0_body.fnord42, PRE_first_tail_x15_r0_body.fi42, PRE_first_tail_x15_r0_body.fii42⟩
theorem PRE_first_tail_x15_r0_body.cnshift42 (clean : Conv.NClean (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P42.NL) (cl : SSt (· < 1898) PRE_first_tail_x15_r0_body.cx0_42.mlx) : NShift PRE_first_tail_x15_r0_body.P42 1898 PRE_first_tail_x15_r0_body.kappa42 PRE_first_tail_x15_r0_body.cx0_42 PRE_first_tail_x15_r0_body.cx1_42 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot42 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost42 (compact_a_eq PRE_first_tail_x15_r0_body.ckn042 PRE_first_tail_x15_r0_body.ckn142 PRE_first_tail_x15_r0_body.ckheap42 PRE_first_tail_x15_r0_body.ckpl42)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_42 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s383.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_42 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s383.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_42 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s383.ffi) = some PRE_first_tail_x15_r0_body.fxC_42
kernel_rfl PRE_first_tail_x15_r0_body.okrC_42 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s383.ffi) = some PRE_first_tail_x15_r0_body.krC_42
noncomputable def PRE_first_tail_x15_r0_body.fx0_42 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s385.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_42 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s385.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_42 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s385.ffi) = some PRE_first_tail_x15_r0_body.fx0_42
kernel_rfl PRE_first_tail_x15_r0_body.okr0_42 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s385.ffi) = some PRE_first_tail_x15_r0_body.kr0_42
noncomputable def PRE_first_tail_x15_r0_body.fx1_42 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s384.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_42 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s384.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_42 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s384.ffi) = some PRE_first_tail_x15_r0_body.fx1_42
kernel_rfl PRE_first_tail_x15_r0_body.okr1_42 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s384.ffi) = some PRE_first_tail_x15_r0_body.kr1_42
kernel_rfl PRE_first_tail_x15_r0_body.ff042 : PRE_first_tail_x15_r0_body.fx0_42 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_42 (PRE_first_tail_x15_r0_body.clo42.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_42.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff142 : PRE_first_tail_x15_r0_body.fx1_42 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_42 (PRE_first_tail_x15_r0_body.cwS42.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_42.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck42 : freedLB PRE_first_tail_x15_r0_body.kappa42 PRE_first_tail_x15_r0_body.cx0_42.mlx PRE_first_tail_x15_r0_body.fx0_42 PRE_first_tail_x15_r0_body.fx1_42 PRE_first_tail_x15_r0_body.clo42 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf042 : PRE_first_tail_x15_r0_body.kr0_42.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_42.flags (PRE_first_tail_x15_r0_body.clo42.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_42.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt042 : PRE_first_tail_x15_r0_body.kr0_42.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_42.targs (PRE_first_tail_x15_r0_body.clo42.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_42.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf142 : PRE_first_tail_x15_r0_body.kr1_42.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_42.flags (PRE_first_tail_x15_r0_body.cwS42.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_42.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt142 : PRE_first_tail_x15_r0_body.kr1_42.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_42.targs (PRE_first_tail_x15_r0_body.cwS42.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_42.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck42 : krecLB PRE_first_tail_x15_r0_body.kappa42 1898 PRE_first_tail_x15_r0_body.cx0_42.mlx PRE_first_tail_x15_r0_body.kr0_42 PRE_first_tail_x15_r0_body.kr1_42 PRE_first_tail_x15_r0_body.clo42 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn42 : Nat.ble 1880 1898 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge42 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s384.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s385.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR42 : pendRegB PRE_first_tail_x15_r0_body.kappa42 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s385.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe42 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s385.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s384.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift42 (clean : Conv.NClean (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P42.NL) (cl : SSt (· < 1898) PRE_first_tail_x15_r0_body.cx0_42.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_42.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_42.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_42.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_42.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P42 1898 PRE_first_tail_x15_r0_body.kappa42 PRE_first_tail_x15_r0_body.s385.ffi PRE_first_tail_x15_r0_body.s384.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift42 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue42, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp42 t ht),
    PRE_first_tail_x15_r0_body.cbridge42,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s385.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s384.ffi) (PRE_first_tail_x15_r0_body.cfoot42 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_42 PRE_first_tail_x15_r0_body.ofx1_42 hobjC PRE_first_tail_x15_r0_body.ff042 PRE_first_tail_x15_r0_body.ff142 PRE_first_tail_x15_r0_body.ffck42,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s385.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s384.ffi) (PRE_first_tail_x15_r0_body.cfoot42 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_42 PRE_first_tail_x15_r0_body.okr1_42 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn42) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf042 PRE_first_tail_x15_r0_body.fkt042 PRE_first_tail_x15_r0_body.fkf142 PRE_first_tail_x15_r0_body.fkt142 PRE_first_tail_x15_r0_body.fkck42,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh042 PRE_first_tail_x15_r0_body.cnh142 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe42) PRE_first_tail_x15_r0_body.cpendR42⟩

end Host.Load.Run.Tpl

import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl119
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 119 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc119 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P119 : LoadP := PRE_first_tail_x15_r0_body.Pc119.raise 17629
kernel_rfl PRE_first_tail_x15_r0_body.craise119 : Nat.ble PRE_first_tail_x15_r0_body.Pc119.N0 17629 = true
theorem PRE_first_tail_x15_r0_body.raised119 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc119 PRE_first_tail_x15_r0_body.P119 :=
  .inr ⟨17629, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise119, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_119 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1151.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_119 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1150.ffi)
def PRE_first_tail_x15_r0_body.khinv119 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv119 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS119 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS119 : List Nat := List.range' 17629 0
def PRE_first_tail_x15_r0_body.ciS119 : List Nat := [] ++ List.range' 17629 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0119 : PRE_first_tail_x15_r0_body.kd119.nh0 = PRE_first_tail_x15_r0_body.cx0_119.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1119 : PRE_first_tail_x15_r0_body.kd119.nh1 = PRE_first_tail_x15_r0_body.cx1_119.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0119 : PRE_first_tail_x15_r0_body.kd119.nn0 = PRE_first_tail_x15_r0_body.cx0_119.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1119 : PRE_first_tail_x15_r0_body.kd119.nn1 = PRE_first_tail_x15_r0_body.cx1_119.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo119 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P119.lo && Nat.ble PRE_first_tail_x15_r0_body.P119.lo PRE_first_tail_x15_r0_body.cx0_119.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P119.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P119.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt119 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_119.mlx.next PRE_first_tail_x15_r0_body.cx1_119.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_119.mlx.nnext PRE_first_tail_x15_r0_body.cx1_119.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband119 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P119.NL && Nat.ble PRE_first_tail_x15_r0_body.P119.NL PRE_first_tail_x15_r0_body.P119.N0 && Nat.ble PRE_first_tail_x15_r0_body.P119.N0 PRE_first_tail_x15_r0_body.cx0_119.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow119 : PRE_first_tail_x15_r0_body.kd119.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren119 : checkRenG PRE_first_tail_x15_r0_body.kd119.hnd PRE_first_tail_x15_r0_body.khinv119 (phB PRE_first_tail_x15_r0_body.cx0_119.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband119 : PRE_first_tail_x15_r0_body.kd119.checkBand PRE_first_tail_x15_r0_body.P119.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos119 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd119.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren119 : checkRenG PRE_first_tail_x15_r0_body.kd119.node PRE_first_tail_x15_r0_body.kninv119 (pnB PRE_first_tail_x15_r0_body.cx0_119.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow119 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd119.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P119.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd119.nodeF j) PRE_first_tail_x15_r0_body.cx1_119.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a119 : PRE_first_tail_x15_r0_body.cx0_119.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b119 : PRE_first_tail_x15_r0_body.cx0_119.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1119 : PRE_first_tail_x15_r0_body.cx1_119.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend119 : PRE_first_tail_x15_r0_body.cx1_119.mlx.pending = PRE_first_tail_x15_r0_body.cx0_119.mlx.pending.map PRE_first_tail_x15_r0_body.kappa119.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh119 : PRE_first_tail_x15_r0_body.cx1_119.mlx.errh = PRE_first_tail_x15_r0_body.cx0_119.mlx.errh.map PRE_first_tail_x15_r0_body.kappa119.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles119 : PRE_first_tail_x15_r0_body.cx1_119.mlx.files = PRE_first_tail_x15_r0_body.cx0_119.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch119 : PRE_first_tail_x15_r0_body.cx1_119.mlx.arch = PRE_first_tail_x15_r0_body.cx0_119.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes119 : PRE_first_tail_x15_r0_body.cx1_119.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_119.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired119 : PRE_first_tail_x15_r0_body.cx1_119.mlx.wired = PRE_first_tail_x15_r0_body.cx0_119.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost119 : PRE_first_tail_x15_r0_body.cx1_119.host = PRE_first_tail_x15_r0_body.cx0_119.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd119`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0119 : PRE_first_tail_x15_r0_body.kd119.n0 = 2768130
kernel_rfl PRE_first_tail_x15_r0_body.ckn1119 : PRE_first_tail_x15_r0_body.kd119.n1 = 2768140
kernel_rfl PRE_first_tail_x15_r0_body.ckheap119 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd119.heap).all (fun x => Nat.ble 2768129 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl119 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd119.heap.get (2768129 + j) = nth? PRE_first_tail_x15_r0_body.pl119 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja119 : Nat.ble 2768129 2768129 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn119 : Nat.ble 5140 5140 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD119 : Nat.ble 2768129 PRE_first_tail_x15_r0_body.kd119.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn119 : Nat.ble 20541 PRE_first_tail_x15_r0_body.kd119.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn119 : Nat.ble 17629 PRE_first_tail_x15_r0_body.kd119.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb119 : Nat.ble 20541 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap119 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd119.heap).all (Nat.ble (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd119 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd119.hnd).all (Nat.ble (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode119 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd119.node).all (Nat.ble (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix119 : Conv.FixOld (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa119 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja119) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn119) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD119) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn119) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn119) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb119) PRE_first_tail_x15_r0_body.fheap119 PRE_first_tail_x15_r0_body.fhnd119 PRE_first_tail_x15_r0_body.fnode119
kernel_rfl PRE_first_tail_x15_r0_body.fcxn119 : (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn119 : (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0119 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_119.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_119.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk119 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd119.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A119 : PRE_first_tail_x15_r0_body.cx1_119.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS119.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_119.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O119 : PRE_first_tail_x15_r0_body.cx1_119.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS119.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_119.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N119 : PRE_first_tail_x15_r0_body.cx1_119.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS119.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_119.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I119 : PRE_first_tail_x15_r0_body.cx1_119.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS119.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_119.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd119 : (PRE_first_tail_x15_r0_body.clo119 ++ PRE_first_tail_x15_r0_body.cln119 ++ PRE_first_tail_x15_r0_body.cli119 ++ PRE_first_tail_x15_r0_body.cwS119 ++ PRE_first_tail_x15_r0_body.cnS119 ++ PRE_first_tail_x15_r0_body.ciS119).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW119 : PRE_first_tail_x15_r0_body.cwS119.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo119.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI119 : PRE_first_tail_x15_r0_body.ciS119.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli119.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN119 : PRE_first_tail_x15_r0_body.cnS119.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF119 : PRE_first_tail_x15_r0_body.cln119.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh119 : PRE_first_tail_x15_r0_body.clo119.all (handleOK PRE_first_tail_x15_r0_body.kappa119 PRE_first_tail_x15_r0_body.P119.lo PRE_first_tail_x15_r0_body.cx0_119.mlx PRE_first_tail_x15_r0_body.cx1_119.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo119 : PRE_first_tail_x15_r0_body.clo119.map (fun h => PRE_first_tail_x15_r0_body.cx1_119.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa119.handle h)) = PRE_first_tail_x15_r0_body.clo119.map (fun h => (PRE_first_tail_x15_r0_body.cx0_119.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa119.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok119 : PRE_first_tail_x15_r0_body.clo119.all (objOK PRE_first_tail_x15_r0_body.kappa119 PRE_first_tail_x15_r0_body.P119.NL PRE_first_tail_x15_r0_body.cx0_119.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd119 : PRE_first_tail_x15_r0_body.cln119.all (nodeOKF PRE_first_tail_x15_r0_body.kappa119 PRE_first_tail_x15_r0_body.P119 PRE_first_tail_x15_r0_body.cx0_119.mlx PRE_first_tail_x15_r0_body.cx1_119.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp119 : ((PRE_first_tail_x15_r0_body.cln119.filter (fullB PRE_first_tail_x15_r0_body.P119))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_119.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa119.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln119.filter (fullB PRE_first_tail_x15_r0_body.P119))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_119.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa119.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI119 : incrB PRE_first_tail_x15_r0_body.kd119.nodeF (List.range' 17629 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK119 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd119.node).all (fun k => Nat.ble 17629 k && Nat.blt k 17629) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL119 : (PRE_first_tail_x15_r0_body.cln119.filter (Nat.ble PRE_first_tail_x15_r0_body.P119.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd119.nodeF i) && (Nat.blt i 17629 || Nat.ble PRE_first_tail_x15_r0_body.kd119.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord119 : (PRE_first_tail_x15_r0_body.cln119.filter (Nat.ble PRE_first_tail_x15_r0_body.P119.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd119.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd119.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd119.nodeF j) (PRE_first_tail_x15_r0_body.kd119.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow119 PRE_first_tail_x15_r0_body.cnn1119 PRE_first_tail_x15_r0_body.fnordI119 PRE_first_tail_x15_r0_body.fnordK119 PRE_first_tail_x15_r0_body.fnordL119
kernel_rfl PRE_first_tail_x15_r0_body.fi119 : PRE_first_tail_x15_r0_body.cli119.all (pnB PRE_first_tail_x15_r0_body.cx0_119.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii119 : PRE_first_tail_x15_r0_body.cli119.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_119.mlx.items.get (PRE_first_tail_x15_r0_body.kappa119.node k) = (PRE_first_tail_x15_r0_body.cx0_119.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa119.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot119 (clean : Conv.NClean (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P119.NL) (cl : SSt (· < 5140) PRE_first_tail_x15_r0_body.cx0_119.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P119 5140 PRE_first_tail_x15_r0_body.kappa119 PRE_first_tail_x15_r0_body.kd119 PRE_first_tail_x15_r0_body.khinv119 PRE_first_tail_x15_r0_body.kninv119 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx PRE_first_tail_x15_r0_body.cx0_119.mlx PRE_first_tail_x15_r0_body.cx1_119.mlx (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo119 PRE_first_tail_x15_r0_body.cln119 PRE_first_tail_x15_r0_body.cli119 PRE_first_tail_x15_r0_body.cwS119 PRE_first_tail_x15_r0_body.cnS119 PRE_first_tail_x15_r0_body.ciS119 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0119, PRE_first_tail_x15_r0_body.cnh1119, PRE_first_tail_x15_r0_body.cnn0119, PRE_first_tail_x15_r0_body.cnn1119, PRE_first_tail_x15_r0_body.cplo119, PRE_first_tail_x15_r0_body.ccnt119, PRE_first_tail_x15_r0_body.cnband119, PRE_first_tail_x15_r0_body.chbelow119, PRE_first_tail_x15_r0_body.chren119, PRE_first_tail_x15_r0_body.cband119, PRE_first_tail_x15_r0_body.cnh1pos119, PRE_first_tail_x15_r0_body.cnren119, PRE_first_tail_x15_r0_body.cnlow119, PRE_first_tail_x15_r0_body.cabs0a119, PRE_first_tail_x15_r0_body.cabs0b119, PRE_first_tail_x15_r0_body.ctok1119, PRE_first_tail_x15_r0_body.cpend119, PRE_first_tail_x15_r0_body.cerrh119, PRE_first_tail_x15_r0_body.cfiles119, PRE_first_tail_x15_r0_body.carch119, PRE_first_tail_x15_r0_body.csizes119, PRE_first_tail_x15_r0_body.cwired119, PRE_first_tail_x15_r0_body.cfix119, clean, PRE_first_tail_x15_r0_body.fcxn119, PRE_first_tail_x15_r0_body.fcnn119, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0119, PRE_first_tail_x15_r0_body.fnk119, PRE_first_tail_x15_r0_body.ckA119, PRE_first_tail_x15_r0_body.cobjsK119, PRE_first_tail_x15_r0_body.cnodesK119, PRE_first_tail_x15_r0_body.citemsK119, PRE_first_tail_x15_r0_body.f1A119, PRE_first_tail_x15_r0_body.f1O119, PRE_first_tail_x15_r0_body.f1N119, PRE_first_tail_x15_r0_body.f1I119, PRE_first_tail_x15_r0_body.fbd119, PRE_first_tail_x15_r0_body.fincW119, PRE_first_tail_x15_r0_body.fincI119, PRE_first_tail_x15_r0_body.fincN119, PRE_first_tail_x15_r0_body.flnF119, PRE_first_tail_x15_r0_body.fh119, PRE_first_tail_x15_r0_body.fo119, PRE_first_tail_x15_r0_body.fok119, PRE_first_tail_x15_r0_body.fnd119, PRE_first_tail_x15_r0_body.fp119, PRE_first_tail_x15_r0_body.fnord119, PRE_first_tail_x15_r0_body.fi119, PRE_first_tail_x15_r0_body.fii119⟩
theorem PRE_first_tail_x15_r0_body.cnshift119 (clean : Conv.NClean (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P119.NL) (cl : SSt (· < 5140) PRE_first_tail_x15_r0_body.cx0_119.mlx) : NShift PRE_first_tail_x15_r0_body.P119 5140 PRE_first_tail_x15_r0_body.kappa119 PRE_first_tail_x15_r0_body.cx0_119 PRE_first_tail_x15_r0_body.cx1_119 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot119 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost119 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0119 PRE_first_tail_x15_r0_body.ckn1119 PRE_first_tail_x15_r0_body.ckheap119 PRE_first_tail_x15_r0_body.ckpl119)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_119 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1149.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_119 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1149.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_119 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1149.ffi) = some PRE_first_tail_x15_r0_body.fxC_119
kernel_rfl PRE_first_tail_x15_r0_body.okrC_119 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1149.ffi) = some PRE_first_tail_x15_r0_body.krC_119
noncomputable def PRE_first_tail_x15_r0_body.fx0_119 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1151.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_119 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1151.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_119 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1151.ffi) = some PRE_first_tail_x15_r0_body.fx0_119
kernel_rfl PRE_first_tail_x15_r0_body.okr0_119 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1151.ffi) = some PRE_first_tail_x15_r0_body.kr0_119
noncomputable def PRE_first_tail_x15_r0_body.fx1_119 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1150.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_119 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1150.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_119 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1150.ffi) = some PRE_first_tail_x15_r0_body.fx1_119
kernel_rfl PRE_first_tail_x15_r0_body.okr1_119 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1150.ffi) = some PRE_first_tail_x15_r0_body.kr1_119
kernel_rfl PRE_first_tail_x15_r0_body.ff0119 : PRE_first_tail_x15_r0_body.fx0_119 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_119 (PRE_first_tail_x15_r0_body.clo119.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_119.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1119 : PRE_first_tail_x15_r0_body.fx1_119 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_119 (PRE_first_tail_x15_r0_body.cwS119.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_119.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck119 : freedLB PRE_first_tail_x15_r0_body.kappa119 PRE_first_tail_x15_r0_body.cx0_119.mlx PRE_first_tail_x15_r0_body.fx0_119 PRE_first_tail_x15_r0_body.fx1_119 PRE_first_tail_x15_r0_body.clo119 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0119 : PRE_first_tail_x15_r0_body.kr0_119.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_119.flags (PRE_first_tail_x15_r0_body.clo119.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_119.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0119 : PRE_first_tail_x15_r0_body.kr0_119.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_119.targs (PRE_first_tail_x15_r0_body.clo119.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_119.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1119 : PRE_first_tail_x15_r0_body.kr1_119.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_119.flags (PRE_first_tail_x15_r0_body.cwS119.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_119.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1119 : PRE_first_tail_x15_r0_body.kr1_119.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_119.targs (PRE_first_tail_x15_r0_body.cwS119.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_119.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck119 : krecLB PRE_first_tail_x15_r0_body.kappa119 5140 PRE_first_tail_x15_r0_body.cx0_119.mlx PRE_first_tail_x15_r0_body.kr0_119 PRE_first_tail_x15_r0_body.kr1_119 PRE_first_tail_x15_r0_body.clo119 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn119 : Nat.ble 5140 5140 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge119 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1150.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1151.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR119 : pendRegB PRE_first_tail_x15_r0_body.kappa119 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1151.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe119 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1151.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1150.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift119 (clean : Conv.NClean (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P119.NL) (cl : SSt (· < 5140) PRE_first_tail_x15_r0_body.cx0_119.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_119.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_119.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_119.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_119.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P119 5140 PRE_first_tail_x15_r0_body.kappa119 PRE_first_tail_x15_r0_body.s1151.ffi PRE_first_tail_x15_r0_body.s1150.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift119 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue119, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp119 t ht),
    PRE_first_tail_x15_r0_body.cbridge119,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1151.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1150.ffi) (PRE_first_tail_x15_r0_body.cfoot119 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_119 PRE_first_tail_x15_r0_body.ofx1_119 hobjC PRE_first_tail_x15_r0_body.ff0119 PRE_first_tail_x15_r0_body.ff1119 PRE_first_tail_x15_r0_body.ffck119,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1151.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1150.ffi) (PRE_first_tail_x15_r0_body.cfoot119 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_119 PRE_first_tail_x15_r0_body.okr1_119 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn119) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0119 PRE_first_tail_x15_r0_body.fkt0119 PRE_first_tail_x15_r0_body.fkf1119 PRE_first_tail_x15_r0_body.fkt1119 PRE_first_tail_x15_r0_body.fkck119,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0119 PRE_first_tail_x15_r0_body.cnh1119 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe119) PRE_first_tail_x15_r0_body.cpendR119⟩

end Host.Load.Run.Tpl

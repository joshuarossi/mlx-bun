import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl120
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 120 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc120 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P120 : LoadP := PRE_first_tail_x15_r0_body.Pc120.raise 17675
kernel_rfl PRE_first_tail_x15_r0_body.craise120 : Nat.ble PRE_first_tail_x15_r0_body.Pc120.N0 17675 = true
theorem PRE_first_tail_x15_r0_body.raised120 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc120 PRE_first_tail_x15_r0_body.P120 :=
  .inr ⟨17675, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise120, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_120 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1168.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_120 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1167.ffi)
def PRE_first_tail_x15_r0_body.khinv120 : PTrie Nat := Stage.setAll PTrie.nil [(20602, 20576), (20580, 20577), (20603, 20578)]
def PRE_first_tail_x15_r0_body.kninv120 : PTrie Nat := Stage.setAll PTrie.nil [(17648, 17648), (17649, 17649), (17650, 17650), (17651, 17651), (17652, 17652), (17653, 17653), (17654, 17654), (17655, 17655), (17656, 17656), (17657, 17657), (17658, 17658), (17659, 17659), (17660, 17660), (17661, 17661), (17662, 17662), (17663, 17663), (17664, 17664), (17665, 17665), (17666, 17666), (17667, 17667), (17668, 17668), (17669, 17669), (17670, 17670), (17671, 17671), (17672, 17672), (17673, 17673), (17674, 17674)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS120 : List Nat := [20556, 20569, 20575, 20576, 20577, 20578, 20579, 20580, 20581, 20582, 20583, 20584, 20585, 20586, 20587, 20588, 20589, 20590, 20591, 20592, 20593, 20594, 20595, 20596, 20597, 20598, 20599, 20600, 20601, 20602, 20603]
def PRE_first_tail_x15_r0_body.cnS120 : List Nat := List.range' 17648 27
def PRE_first_tail_x15_r0_body.ciS120 : List Nat := [] ++ List.range' 17648 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0120 : PRE_first_tail_x15_r0_body.kd120.nh0 = PRE_first_tail_x15_r0_body.cx0_120.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1120 : PRE_first_tail_x15_r0_body.kd120.nh1 = PRE_first_tail_x15_r0_body.cx1_120.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0120 : PRE_first_tail_x15_r0_body.kd120.nn0 = PRE_first_tail_x15_r0_body.cx0_120.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1120 : PRE_first_tail_x15_r0_body.kd120.nn1 = PRE_first_tail_x15_r0_body.cx1_120.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo120 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P120.lo && Nat.ble PRE_first_tail_x15_r0_body.P120.lo PRE_first_tail_x15_r0_body.cx0_120.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P120.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P120.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt120 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_120.mlx.next PRE_first_tail_x15_r0_body.cx1_120.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_120.mlx.nnext PRE_first_tail_x15_r0_body.cx1_120.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband120 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P120.NL && Nat.ble PRE_first_tail_x15_r0_body.P120.NL PRE_first_tail_x15_r0_body.P120.N0 && Nat.ble PRE_first_tail_x15_r0_body.P120.N0 PRE_first_tail_x15_r0_body.cx0_120.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow120 : PRE_first_tail_x15_r0_body.kd120.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren120 : checkRenG PRE_first_tail_x15_r0_body.kd120.hnd PRE_first_tail_x15_r0_body.khinv120 (phB PRE_first_tail_x15_r0_body.cx0_120.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband120 : PRE_first_tail_x15_r0_body.kd120.checkBand PRE_first_tail_x15_r0_body.P120.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos120 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd120.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren120 : checkRenG PRE_first_tail_x15_r0_body.kd120.node PRE_first_tail_x15_r0_body.kninv120 (pnB PRE_first_tail_x15_r0_body.cx0_120.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow120 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd120.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P120.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd120.nodeF j) PRE_first_tail_x15_r0_body.cx1_120.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a120 : PRE_first_tail_x15_r0_body.cx0_120.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b120 : PRE_first_tail_x15_r0_body.cx0_120.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1120 : PRE_first_tail_x15_r0_body.cx1_120.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend120 : PRE_first_tail_x15_r0_body.cx1_120.mlx.pending = PRE_first_tail_x15_r0_body.cx0_120.mlx.pending.map PRE_first_tail_x15_r0_body.kappa120.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh120 : PRE_first_tail_x15_r0_body.cx1_120.mlx.errh = PRE_first_tail_x15_r0_body.cx0_120.mlx.errh.map PRE_first_tail_x15_r0_body.kappa120.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles120 : PRE_first_tail_x15_r0_body.cx1_120.mlx.files = PRE_first_tail_x15_r0_body.cx0_120.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch120 : PRE_first_tail_x15_r0_body.cx1_120.mlx.arch = PRE_first_tail_x15_r0_body.cx0_120.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes120 : PRE_first_tail_x15_r0_body.cx1_120.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_120.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired120 : PRE_first_tail_x15_r0_body.cx1_120.mlx.wired = PRE_first_tail_x15_r0_body.cx0_120.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost120 : PRE_first_tail_x15_r0_body.cx1_120.host = PRE_first_tail_x15_r0_body.cx0_120.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd120`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0120 : PRE_first_tail_x15_r0_body.kd120.n0 = 2769629
kernel_rfl PRE_first_tail_x15_r0_body.ckn1120 : PRE_first_tail_x15_r0_body.kd120.n1 = 2770778
kernel_rfl PRE_first_tail_x15_r0_body.ckheap120 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd120.heap).all (fun x => Nat.ble 2769623 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl120 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd120.heap.get (2769623 + j) = nth? PRE_first_tail_x15_r0_body.pl120 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja120 : Nat.ble 2769623 2769623 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn120 : Nat.ble 5213 5213 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD120 : Nat.ble 2769623 PRE_first_tail_x15_r0_body.kd120.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn120 : Nat.ble 20576 PRE_first_tail_x15_r0_body.kd120.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn120 : Nat.ble 17648 PRE_first_tail_x15_r0_body.kd120.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb120 : Nat.ble 20576 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap120 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd120.heap).all (Nat.ble (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd120 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd120.hnd).all (Nat.ble (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode120 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd120.node).all (Nat.ble (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix120 : Conv.FixOld (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa120 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja120) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn120) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD120) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn120) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn120) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb120) PRE_first_tail_x15_r0_body.fheap120 PRE_first_tail_x15_r0_body.fhnd120 PRE_first_tail_x15_r0_body.fnode120
kernel_rfl PRE_first_tail_x15_r0_body.fcxn120 : (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn120 : (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0120 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_120.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_120.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk120 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd120.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A120 : PRE_first_tail_x15_r0_body.cx1_120.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS120.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_120.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O120 : PRE_first_tail_x15_r0_body.cx1_120.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS120.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_120.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N120 : PRE_first_tail_x15_r0_body.cx1_120.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS120.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_120.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I120 : PRE_first_tail_x15_r0_body.cx1_120.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS120.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_120.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd120 : (PRE_first_tail_x15_r0_body.clo120 ++ PRE_first_tail_x15_r0_body.cln120 ++ PRE_first_tail_x15_r0_body.cli120 ++ PRE_first_tail_x15_r0_body.cwS120 ++ PRE_first_tail_x15_r0_body.cnS120 ++ PRE_first_tail_x15_r0_body.ciS120).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW120 : PRE_first_tail_x15_r0_body.cwS120.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo120.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI120 : PRE_first_tail_x15_r0_body.ciS120.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli120.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN120 : PRE_first_tail_x15_r0_body.cnS120.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF120 : PRE_first_tail_x15_r0_body.cln120.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh120 : PRE_first_tail_x15_r0_body.clo120.all (handleOK PRE_first_tail_x15_r0_body.kappa120 PRE_first_tail_x15_r0_body.P120.lo PRE_first_tail_x15_r0_body.cx0_120.mlx PRE_first_tail_x15_r0_body.cx1_120.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo120 : PRE_first_tail_x15_r0_body.clo120.map (fun h => PRE_first_tail_x15_r0_body.cx1_120.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa120.handle h)) = PRE_first_tail_x15_r0_body.clo120.map (fun h => (PRE_first_tail_x15_r0_body.cx0_120.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa120.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok120 : PRE_first_tail_x15_r0_body.clo120.all (objOK PRE_first_tail_x15_r0_body.kappa120 PRE_first_tail_x15_r0_body.P120.NL PRE_first_tail_x15_r0_body.cx0_120.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd120 : PRE_first_tail_x15_r0_body.cln120.all (nodeOKF PRE_first_tail_x15_r0_body.kappa120 PRE_first_tail_x15_r0_body.P120 PRE_first_tail_x15_r0_body.cx0_120.mlx PRE_first_tail_x15_r0_body.cx1_120.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp120 : ((PRE_first_tail_x15_r0_body.cln120.filter (fullB PRE_first_tail_x15_r0_body.P120))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_120.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa120.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln120.filter (fullB PRE_first_tail_x15_r0_body.P120))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_120.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa120.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI120 : incrB PRE_first_tail_x15_r0_body.kd120.nodeF (List.range' 17648 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK120 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd120.node).all (fun k => Nat.ble 17648 k && Nat.blt k 17675) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL120 : (PRE_first_tail_x15_r0_body.cln120.filter (Nat.ble PRE_first_tail_x15_r0_body.P120.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd120.nodeF i) && (Nat.blt i 17675 || Nat.ble PRE_first_tail_x15_r0_body.kd120.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord120 : (PRE_first_tail_x15_r0_body.cln120.filter (Nat.ble PRE_first_tail_x15_r0_body.P120.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd120.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd120.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd120.nodeF j) (PRE_first_tail_x15_r0_body.kd120.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow120 PRE_first_tail_x15_r0_body.cnn1120 PRE_first_tail_x15_r0_body.fnordI120 PRE_first_tail_x15_r0_body.fnordK120 PRE_first_tail_x15_r0_body.fnordL120
kernel_rfl PRE_first_tail_x15_r0_body.fi120 : PRE_first_tail_x15_r0_body.cli120.all (pnB PRE_first_tail_x15_r0_body.cx0_120.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii120 : PRE_first_tail_x15_r0_body.cli120.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_120.mlx.items.get (PRE_first_tail_x15_r0_body.kappa120.node k) = (PRE_first_tail_x15_r0_body.cx0_120.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa120.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot120 (clean : Conv.NClean (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P120.NL) (cl : SSt (· < 5231) PRE_first_tail_x15_r0_body.cx0_120.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P120 5231 PRE_first_tail_x15_r0_body.kappa120 PRE_first_tail_x15_r0_body.kd120 PRE_first_tail_x15_r0_body.khinv120 PRE_first_tail_x15_r0_body.kninv120 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx PRE_first_tail_x15_r0_body.cx0_120.mlx PRE_first_tail_x15_r0_body.cx1_120.mlx (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo120 PRE_first_tail_x15_r0_body.cln120 PRE_first_tail_x15_r0_body.cli120 PRE_first_tail_x15_r0_body.cwS120 PRE_first_tail_x15_r0_body.cnS120 PRE_first_tail_x15_r0_body.ciS120 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0120, PRE_first_tail_x15_r0_body.cnh1120, PRE_first_tail_x15_r0_body.cnn0120, PRE_first_tail_x15_r0_body.cnn1120, PRE_first_tail_x15_r0_body.cplo120, PRE_first_tail_x15_r0_body.ccnt120, PRE_first_tail_x15_r0_body.cnband120, PRE_first_tail_x15_r0_body.chbelow120, PRE_first_tail_x15_r0_body.chren120, PRE_first_tail_x15_r0_body.cband120, PRE_first_tail_x15_r0_body.cnh1pos120, PRE_first_tail_x15_r0_body.cnren120, PRE_first_tail_x15_r0_body.cnlow120, PRE_first_tail_x15_r0_body.cabs0a120, PRE_first_tail_x15_r0_body.cabs0b120, PRE_first_tail_x15_r0_body.ctok1120, PRE_first_tail_x15_r0_body.cpend120, PRE_first_tail_x15_r0_body.cerrh120, PRE_first_tail_x15_r0_body.cfiles120, PRE_first_tail_x15_r0_body.carch120, PRE_first_tail_x15_r0_body.csizes120, PRE_first_tail_x15_r0_body.cwired120, PRE_first_tail_x15_r0_body.cfix120, clean, PRE_first_tail_x15_r0_body.fcxn120, PRE_first_tail_x15_r0_body.fcnn120, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0120, PRE_first_tail_x15_r0_body.fnk120, PRE_first_tail_x15_r0_body.ckA120, PRE_first_tail_x15_r0_body.cobjsK120, PRE_first_tail_x15_r0_body.cnodesK120, PRE_first_tail_x15_r0_body.citemsK120, PRE_first_tail_x15_r0_body.f1A120, PRE_first_tail_x15_r0_body.f1O120, PRE_first_tail_x15_r0_body.f1N120, PRE_first_tail_x15_r0_body.f1I120, PRE_first_tail_x15_r0_body.fbd120, PRE_first_tail_x15_r0_body.fincW120, PRE_first_tail_x15_r0_body.fincI120, PRE_first_tail_x15_r0_body.fincN120, PRE_first_tail_x15_r0_body.flnF120, PRE_first_tail_x15_r0_body.fh120, PRE_first_tail_x15_r0_body.fo120, PRE_first_tail_x15_r0_body.fok120, PRE_first_tail_x15_r0_body.fnd120, PRE_first_tail_x15_r0_body.fp120, PRE_first_tail_x15_r0_body.fnord120, PRE_first_tail_x15_r0_body.fi120, PRE_first_tail_x15_r0_body.fii120⟩
theorem PRE_first_tail_x15_r0_body.cnshift120 (clean : Conv.NClean (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P120.NL) (cl : SSt (· < 5231) PRE_first_tail_x15_r0_body.cx0_120.mlx) : NShift PRE_first_tail_x15_r0_body.P120 5231 PRE_first_tail_x15_r0_body.kappa120 PRE_first_tail_x15_r0_body.cx0_120 PRE_first_tail_x15_r0_body.cx1_120 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot120 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost120 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0120 PRE_first_tail_x15_r0_body.ckn1120 PRE_first_tail_x15_r0_body.ckheap120 PRE_first_tail_x15_r0_body.ckpl120)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_120 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1166.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_120 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1166.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_120 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1166.ffi) = some PRE_first_tail_x15_r0_body.fxC_120
kernel_rfl PRE_first_tail_x15_r0_body.okrC_120 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1166.ffi) = some PRE_first_tail_x15_r0_body.krC_120
noncomputable def PRE_first_tail_x15_r0_body.fx0_120 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1168.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_120 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1168.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_120 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1168.ffi) = some PRE_first_tail_x15_r0_body.fx0_120
kernel_rfl PRE_first_tail_x15_r0_body.okr0_120 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1168.ffi) = some PRE_first_tail_x15_r0_body.kr0_120
noncomputable def PRE_first_tail_x15_r0_body.fx1_120 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1167.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_120 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1167.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_120 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1167.ffi) = some PRE_first_tail_x15_r0_body.fx1_120
kernel_rfl PRE_first_tail_x15_r0_body.okr1_120 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1167.ffi) = some PRE_first_tail_x15_r0_body.kr1_120
kernel_rfl PRE_first_tail_x15_r0_body.ff0120 : PRE_first_tail_x15_r0_body.fx0_120 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_120 (PRE_first_tail_x15_r0_body.clo120.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_120.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1120 : PRE_first_tail_x15_r0_body.fx1_120 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_120 (PRE_first_tail_x15_r0_body.cwS120.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_120.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck120 : freedLB PRE_first_tail_x15_r0_body.kappa120 PRE_first_tail_x15_r0_body.cx0_120.mlx PRE_first_tail_x15_r0_body.fx0_120 PRE_first_tail_x15_r0_body.fx1_120 PRE_first_tail_x15_r0_body.clo120 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0120 : PRE_first_tail_x15_r0_body.kr0_120.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_120.flags (PRE_first_tail_x15_r0_body.clo120.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_120.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0120 : PRE_first_tail_x15_r0_body.kr0_120.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_120.targs (PRE_first_tail_x15_r0_body.clo120.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_120.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1120 : PRE_first_tail_x15_r0_body.kr1_120.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_120.flags (PRE_first_tail_x15_r0_body.cwS120.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_120.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1120 : PRE_first_tail_x15_r0_body.kr1_120.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_120.targs (PRE_first_tail_x15_r0_body.cwS120.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_120.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck120 : krecLB PRE_first_tail_x15_r0_body.kappa120 5231 PRE_first_tail_x15_r0_body.cx0_120.mlx PRE_first_tail_x15_r0_body.kr0_120 PRE_first_tail_x15_r0_body.kr1_120 PRE_first_tail_x15_r0_body.clo120 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn120 : Nat.ble 5213 5231 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge120 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1167.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1168.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR120 : pendRegB PRE_first_tail_x15_r0_body.kappa120 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1168.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe120 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1168.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1167.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift120 (clean : Conv.NClean (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P120.NL) (cl : SSt (· < 5231) PRE_first_tail_x15_r0_body.cx0_120.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_120.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_120.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_120.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_120.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P120 5231 PRE_first_tail_x15_r0_body.kappa120 PRE_first_tail_x15_r0_body.s1168.ffi PRE_first_tail_x15_r0_body.s1167.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift120 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue120, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp120 t ht),
    PRE_first_tail_x15_r0_body.cbridge120,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1168.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1167.ffi) (PRE_first_tail_x15_r0_body.cfoot120 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_120 PRE_first_tail_x15_r0_body.ofx1_120 hobjC PRE_first_tail_x15_r0_body.ff0120 PRE_first_tail_x15_r0_body.ff1120 PRE_first_tail_x15_r0_body.ffck120,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1168.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1167.ffi) (PRE_first_tail_x15_r0_body.cfoot120 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_120 PRE_first_tail_x15_r0_body.okr1_120 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn120) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0120 PRE_first_tail_x15_r0_body.fkt0120 PRE_first_tail_x15_r0_body.fkf1120 PRE_first_tail_x15_r0_body.fkt1120 PRE_first_tail_x15_r0_body.fkck120,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0120 PRE_first_tail_x15_r0_body.cnh1120 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe120) PRE_first_tail_x15_r0_body.cpendR120⟩

end Host.Load.Run.Tpl

import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl110
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 110 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc110 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P110 : LoadP := PRE_first_tail_x15_r0_body.Pc110.raise 17455
kernel_rfl PRE_first_tail_x15_r0_body.craise110 : Nat.ble PRE_first_tail_x15_r0_body.Pc110.N0 17455 = true
theorem PRE_first_tail_x15_r0_body.raised110 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc110 PRE_first_tail_x15_r0_body.P110 :=
  .inr ⟨17455, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise110, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_110 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s972.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_110 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s971.ffi)
def PRE_first_tail_x15_r0_body.khinv110 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv110 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS110 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS110 : List Nat := List.range' 17455 0
def PRE_first_tail_x15_r0_body.ciS110 : List Nat := [] ++ List.range' 17455 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0110 : PRE_first_tail_x15_r0_body.kd110.nh0 = PRE_first_tail_x15_r0_body.cx0_110.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1110 : PRE_first_tail_x15_r0_body.kd110.nh1 = PRE_first_tail_x15_r0_body.cx1_110.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0110 : PRE_first_tail_x15_r0_body.kd110.nn0 = PRE_first_tail_x15_r0_body.cx0_110.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1110 : PRE_first_tail_x15_r0_body.kd110.nn1 = PRE_first_tail_x15_r0_body.cx1_110.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo110 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P110.lo && Nat.ble PRE_first_tail_x15_r0_body.P110.lo PRE_first_tail_x15_r0_body.cx0_110.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P110.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P110.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt110 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_110.mlx.next PRE_first_tail_x15_r0_body.cx1_110.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_110.mlx.nnext PRE_first_tail_x15_r0_body.cx1_110.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband110 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P110.NL && Nat.ble PRE_first_tail_x15_r0_body.P110.NL PRE_first_tail_x15_r0_body.P110.N0 && Nat.ble PRE_first_tail_x15_r0_body.P110.N0 PRE_first_tail_x15_r0_body.cx0_110.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow110 : PRE_first_tail_x15_r0_body.kd110.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren110 : checkRenG PRE_first_tail_x15_r0_body.kd110.hnd PRE_first_tail_x15_r0_body.khinv110 (phB PRE_first_tail_x15_r0_body.cx0_110.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband110 : PRE_first_tail_x15_r0_body.kd110.checkBand PRE_first_tail_x15_r0_body.P110.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos110 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd110.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren110 : checkRenG PRE_first_tail_x15_r0_body.kd110.node PRE_first_tail_x15_r0_body.kninv110 (pnB PRE_first_tail_x15_r0_body.cx0_110.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow110 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd110.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P110.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd110.nodeF j) PRE_first_tail_x15_r0_body.cx1_110.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a110 : PRE_first_tail_x15_r0_body.cx0_110.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b110 : PRE_first_tail_x15_r0_body.cx0_110.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1110 : PRE_first_tail_x15_r0_body.cx1_110.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend110 : PRE_first_tail_x15_r0_body.cx1_110.mlx.pending = PRE_first_tail_x15_r0_body.cx0_110.mlx.pending.map PRE_first_tail_x15_r0_body.kappa110.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh110 : PRE_first_tail_x15_r0_body.cx1_110.mlx.errh = PRE_first_tail_x15_r0_body.cx0_110.mlx.errh.map PRE_first_tail_x15_r0_body.kappa110.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles110 : PRE_first_tail_x15_r0_body.cx1_110.mlx.files = PRE_first_tail_x15_r0_body.cx0_110.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch110 : PRE_first_tail_x15_r0_body.cx1_110.mlx.arch = PRE_first_tail_x15_r0_body.cx0_110.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes110 : PRE_first_tail_x15_r0_body.cx1_110.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_110.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired110 : PRE_first_tail_x15_r0_body.cx1_110.mlx.wired = PRE_first_tail_x15_r0_body.cx0_110.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost110 : PRE_first_tail_x15_r0_body.cx1_110.host = PRE_first_tail_x15_r0_body.cx0_110.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd110`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0110 : PRE_first_tail_x15_r0_body.kd110.n0 = 2760996
kernel_rfl PRE_first_tail_x15_r0_body.ckn1110 : PRE_first_tail_x15_r0_body.kd110.n1 = 2761006
kernel_rfl PRE_first_tail_x15_r0_body.ckheap110 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd110.heap).all (fun x => Nat.ble 2760995 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl110 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd110.heap.get (2760995 + j) = nth? PRE_first_tail_x15_r0_body.pl110 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja110 : Nat.ble 2760995 2760995 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn110 : Nat.ble 4756 4756 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD110 : Nat.ble 2760995 PRE_first_tail_x15_r0_body.kd110.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn110 : Nat.ble 20363 PRE_first_tail_x15_r0_body.kd110.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn110 : Nat.ble 17455 PRE_first_tail_x15_r0_body.kd110.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb110 : Nat.ble 20363 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap110 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd110.heap).all (Nat.ble (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd110 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd110.hnd).all (Nat.ble (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode110 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd110.node).all (Nat.ble (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix110 : Conv.FixOld (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa110 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja110) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn110) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD110) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn110) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn110) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb110) PRE_first_tail_x15_r0_body.fheap110 PRE_first_tail_x15_r0_body.fhnd110 PRE_first_tail_x15_r0_body.fnode110
kernel_rfl PRE_first_tail_x15_r0_body.fcxn110 : (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn110 : (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0110 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_110.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_110.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk110 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd110.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A110 : PRE_first_tail_x15_r0_body.cx1_110.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS110.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_110.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O110 : PRE_first_tail_x15_r0_body.cx1_110.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS110.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_110.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N110 : PRE_first_tail_x15_r0_body.cx1_110.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS110.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_110.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I110 : PRE_first_tail_x15_r0_body.cx1_110.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS110.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_110.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd110 : (PRE_first_tail_x15_r0_body.clo110 ++ PRE_first_tail_x15_r0_body.cln110 ++ PRE_first_tail_x15_r0_body.cli110 ++ PRE_first_tail_x15_r0_body.cwS110 ++ PRE_first_tail_x15_r0_body.cnS110 ++ PRE_first_tail_x15_r0_body.ciS110).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW110 : PRE_first_tail_x15_r0_body.cwS110.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo110.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI110 : PRE_first_tail_x15_r0_body.ciS110.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli110.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN110 : PRE_first_tail_x15_r0_body.cnS110.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF110 : PRE_first_tail_x15_r0_body.cln110.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh110 : PRE_first_tail_x15_r0_body.clo110.all (handleOK PRE_first_tail_x15_r0_body.kappa110 PRE_first_tail_x15_r0_body.P110.lo PRE_first_tail_x15_r0_body.cx0_110.mlx PRE_first_tail_x15_r0_body.cx1_110.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo110 : PRE_first_tail_x15_r0_body.clo110.map (fun h => PRE_first_tail_x15_r0_body.cx1_110.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa110.handle h)) = PRE_first_tail_x15_r0_body.clo110.map (fun h => (PRE_first_tail_x15_r0_body.cx0_110.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa110.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok110 : PRE_first_tail_x15_r0_body.clo110.all (objOK PRE_first_tail_x15_r0_body.kappa110 PRE_first_tail_x15_r0_body.P110.NL PRE_first_tail_x15_r0_body.cx0_110.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd110 : PRE_first_tail_x15_r0_body.cln110.all (nodeOKF PRE_first_tail_x15_r0_body.kappa110 PRE_first_tail_x15_r0_body.P110 PRE_first_tail_x15_r0_body.cx0_110.mlx PRE_first_tail_x15_r0_body.cx1_110.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp110 : ((PRE_first_tail_x15_r0_body.cln110.filter (fullB PRE_first_tail_x15_r0_body.P110))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_110.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa110.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln110.filter (fullB PRE_first_tail_x15_r0_body.P110))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_110.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa110.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI110 : incrB PRE_first_tail_x15_r0_body.kd110.nodeF (List.range' 17455 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK110 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd110.node).all (fun k => Nat.ble 17455 k && Nat.blt k 17455) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL110 : (PRE_first_tail_x15_r0_body.cln110.filter (Nat.ble PRE_first_tail_x15_r0_body.P110.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd110.nodeF i) && (Nat.blt i 17455 || Nat.ble PRE_first_tail_x15_r0_body.kd110.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord110 : (PRE_first_tail_x15_r0_body.cln110.filter (Nat.ble PRE_first_tail_x15_r0_body.P110.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd110.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd110.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd110.nodeF j) (PRE_first_tail_x15_r0_body.kd110.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow110 PRE_first_tail_x15_r0_body.cnn1110 PRE_first_tail_x15_r0_body.fnordI110 PRE_first_tail_x15_r0_body.fnordK110 PRE_first_tail_x15_r0_body.fnordL110
kernel_rfl PRE_first_tail_x15_r0_body.fi110 : PRE_first_tail_x15_r0_body.cli110.all (pnB PRE_first_tail_x15_r0_body.cx0_110.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii110 : PRE_first_tail_x15_r0_body.cli110.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_110.mlx.items.get (PRE_first_tail_x15_r0_body.kappa110.node k) = (PRE_first_tail_x15_r0_body.cx0_110.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa110.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot110 (clean : Conv.NClean (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P110.NL) (cl : SSt (· < 4756) PRE_first_tail_x15_r0_body.cx0_110.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P110 4756 PRE_first_tail_x15_r0_body.kappa110 PRE_first_tail_x15_r0_body.kd110 PRE_first_tail_x15_r0_body.khinv110 PRE_first_tail_x15_r0_body.kninv110 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx PRE_first_tail_x15_r0_body.cx0_110.mlx PRE_first_tail_x15_r0_body.cx1_110.mlx (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo110 PRE_first_tail_x15_r0_body.cln110 PRE_first_tail_x15_r0_body.cli110 PRE_first_tail_x15_r0_body.cwS110 PRE_first_tail_x15_r0_body.cnS110 PRE_first_tail_x15_r0_body.ciS110 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0110, PRE_first_tail_x15_r0_body.cnh1110, PRE_first_tail_x15_r0_body.cnn0110, PRE_first_tail_x15_r0_body.cnn1110, PRE_first_tail_x15_r0_body.cplo110, PRE_first_tail_x15_r0_body.ccnt110, PRE_first_tail_x15_r0_body.cnband110, PRE_first_tail_x15_r0_body.chbelow110, PRE_first_tail_x15_r0_body.chren110, PRE_first_tail_x15_r0_body.cband110, PRE_first_tail_x15_r0_body.cnh1pos110, PRE_first_tail_x15_r0_body.cnren110, PRE_first_tail_x15_r0_body.cnlow110, PRE_first_tail_x15_r0_body.cabs0a110, PRE_first_tail_x15_r0_body.cabs0b110, PRE_first_tail_x15_r0_body.ctok1110, PRE_first_tail_x15_r0_body.cpend110, PRE_first_tail_x15_r0_body.cerrh110, PRE_first_tail_x15_r0_body.cfiles110, PRE_first_tail_x15_r0_body.carch110, PRE_first_tail_x15_r0_body.csizes110, PRE_first_tail_x15_r0_body.cwired110, PRE_first_tail_x15_r0_body.cfix110, clean, PRE_first_tail_x15_r0_body.fcxn110, PRE_first_tail_x15_r0_body.fcnn110, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0110, PRE_first_tail_x15_r0_body.fnk110, PRE_first_tail_x15_r0_body.ckA110, PRE_first_tail_x15_r0_body.cobjsK110, PRE_first_tail_x15_r0_body.cnodesK110, PRE_first_tail_x15_r0_body.citemsK110, PRE_first_tail_x15_r0_body.f1A110, PRE_first_tail_x15_r0_body.f1O110, PRE_first_tail_x15_r0_body.f1N110, PRE_first_tail_x15_r0_body.f1I110, PRE_first_tail_x15_r0_body.fbd110, PRE_first_tail_x15_r0_body.fincW110, PRE_first_tail_x15_r0_body.fincI110, PRE_first_tail_x15_r0_body.fincN110, PRE_first_tail_x15_r0_body.flnF110, PRE_first_tail_x15_r0_body.fh110, PRE_first_tail_x15_r0_body.fo110, PRE_first_tail_x15_r0_body.fok110, PRE_first_tail_x15_r0_body.fnd110, PRE_first_tail_x15_r0_body.fp110, PRE_first_tail_x15_r0_body.fnord110, PRE_first_tail_x15_r0_body.fi110, PRE_first_tail_x15_r0_body.fii110⟩
theorem PRE_first_tail_x15_r0_body.cnshift110 (clean : Conv.NClean (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P110.NL) (cl : SSt (· < 4756) PRE_first_tail_x15_r0_body.cx0_110.mlx) : NShift PRE_first_tail_x15_r0_body.P110 4756 PRE_first_tail_x15_r0_body.kappa110 PRE_first_tail_x15_r0_body.cx0_110 PRE_first_tail_x15_r0_body.cx1_110 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot110 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost110 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0110 PRE_first_tail_x15_r0_body.ckn1110 PRE_first_tail_x15_r0_body.ckheap110 PRE_first_tail_x15_r0_body.ckpl110)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_110 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s970.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_110 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s970.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_110 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s970.ffi) = some PRE_first_tail_x15_r0_body.fxC_110
kernel_rfl PRE_first_tail_x15_r0_body.okrC_110 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s970.ffi) = some PRE_first_tail_x15_r0_body.krC_110
noncomputable def PRE_first_tail_x15_r0_body.fx0_110 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s972.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_110 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s972.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_110 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s972.ffi) = some PRE_first_tail_x15_r0_body.fx0_110
kernel_rfl PRE_first_tail_x15_r0_body.okr0_110 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s972.ffi) = some PRE_first_tail_x15_r0_body.kr0_110
noncomputable def PRE_first_tail_x15_r0_body.fx1_110 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s971.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_110 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s971.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_110 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s971.ffi) = some PRE_first_tail_x15_r0_body.fx1_110
kernel_rfl PRE_first_tail_x15_r0_body.okr1_110 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s971.ffi) = some PRE_first_tail_x15_r0_body.kr1_110
kernel_rfl PRE_first_tail_x15_r0_body.ff0110 : PRE_first_tail_x15_r0_body.fx0_110 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_110 (PRE_first_tail_x15_r0_body.clo110.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_110.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1110 : PRE_first_tail_x15_r0_body.fx1_110 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_110 (PRE_first_tail_x15_r0_body.cwS110.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_110.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck110 : freedLB PRE_first_tail_x15_r0_body.kappa110 PRE_first_tail_x15_r0_body.cx0_110.mlx PRE_first_tail_x15_r0_body.fx0_110 PRE_first_tail_x15_r0_body.fx1_110 PRE_first_tail_x15_r0_body.clo110 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0110 : PRE_first_tail_x15_r0_body.kr0_110.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_110.flags (PRE_first_tail_x15_r0_body.clo110.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_110.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0110 : PRE_first_tail_x15_r0_body.kr0_110.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_110.targs (PRE_first_tail_x15_r0_body.clo110.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_110.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1110 : PRE_first_tail_x15_r0_body.kr1_110.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_110.flags (PRE_first_tail_x15_r0_body.cwS110.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_110.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1110 : PRE_first_tail_x15_r0_body.kr1_110.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_110.targs (PRE_first_tail_x15_r0_body.cwS110.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_110.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck110 : krecLB PRE_first_tail_x15_r0_body.kappa110 4756 PRE_first_tail_x15_r0_body.cx0_110.mlx PRE_first_tail_x15_r0_body.kr0_110 PRE_first_tail_x15_r0_body.kr1_110 PRE_first_tail_x15_r0_body.clo110 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn110 : Nat.ble 4756 4756 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge110 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s971.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s972.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR110 : pendRegB PRE_first_tail_x15_r0_body.kappa110 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s972.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe110 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s972.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s971.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift110 (clean : Conv.NClean (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P110.NL) (cl : SSt (· < 4756) PRE_first_tail_x15_r0_body.cx0_110.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_110.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_110.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_110.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s970.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_110.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P110 4756 PRE_first_tail_x15_r0_body.kappa110 PRE_first_tail_x15_r0_body.s972.ffi PRE_first_tail_x15_r0_body.s971.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift110 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue110, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp110 t ht),
    PRE_first_tail_x15_r0_body.cbridge110,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s972.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s971.ffi) (PRE_first_tail_x15_r0_body.cfoot110 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_110 PRE_first_tail_x15_r0_body.ofx1_110 hobjC PRE_first_tail_x15_r0_body.ff0110 PRE_first_tail_x15_r0_body.ff1110 PRE_first_tail_x15_r0_body.ffck110,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s972.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s971.ffi) (PRE_first_tail_x15_r0_body.cfoot110 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_110 PRE_first_tail_x15_r0_body.okr1_110 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn110) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0110 PRE_first_tail_x15_r0_body.fkt0110 PRE_first_tail_x15_r0_body.fkf1110 PRE_first_tail_x15_r0_body.fkt1110 PRE_first_tail_x15_r0_body.fkck110,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0110 PRE_first_tail_x15_r0_body.cnh1110 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe110) PRE_first_tail_x15_r0_body.cpendR110⟩

end Host.Load.Run.Tpl

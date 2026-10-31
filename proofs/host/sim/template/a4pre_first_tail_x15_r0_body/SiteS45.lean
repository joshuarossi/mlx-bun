import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl45
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 45 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc45 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P45 : LoadP := PRE_first_tail_x15_r0_body.Pc45.raise 16193
kernel_rfl PRE_first_tail_x15_r0_body.craise45 : Nat.ble PRE_first_tail_x15_r0_body.Pc45.N0 16193 = true
theorem PRE_first_tail_x15_r0_body.raised45 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc45 PRE_first_tail_x15_r0_body.P45 :=
  .inr ⟨16193, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise45, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_45 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s409.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_45 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s408.ffi)
def PRE_first_tail_x15_r0_body.khinv45 : PTrie Nat := Stage.setAll PTrie.nil [(19103, 19101), (19104, 19102), (19106, 19103), (19105, 19104)]
def PRE_first_tail_x15_r0_body.kninv45 : PTrie Nat := Stage.setAll PTrie.nil [(16187, 16187), (16188, 16188), (16189, 16189), (16190, 16190), (16191, 16191), (16192, 16192)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS45 : List Nat := [19101, 19102, 19103, 19104, 19105, 19106]
def PRE_first_tail_x15_r0_body.cnS45 : List Nat := List.range' 16187 6
def PRE_first_tail_x15_r0_body.ciS45 : List Nat := [] ++ List.range' 16187 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh045 : PRE_first_tail_x15_r0_body.kd45.nh0 = PRE_first_tail_x15_r0_body.cx0_45.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh145 : PRE_first_tail_x15_r0_body.kd45.nh1 = PRE_first_tail_x15_r0_body.cx1_45.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn045 : PRE_first_tail_x15_r0_body.kd45.nn0 = PRE_first_tail_x15_r0_body.cx0_45.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn145 : PRE_first_tail_x15_r0_body.kd45.nn1 = PRE_first_tail_x15_r0_body.cx1_45.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo45 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P45.lo && Nat.ble PRE_first_tail_x15_r0_body.P45.lo PRE_first_tail_x15_r0_body.cx0_45.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P45.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P45.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt45 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_45.mlx.next PRE_first_tail_x15_r0_body.cx1_45.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_45.mlx.nnext PRE_first_tail_x15_r0_body.cx1_45.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband45 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P45.NL && Nat.ble PRE_first_tail_x15_r0_body.P45.NL PRE_first_tail_x15_r0_body.P45.N0 && Nat.ble PRE_first_tail_x15_r0_body.P45.N0 PRE_first_tail_x15_r0_body.cx0_45.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow45 : PRE_first_tail_x15_r0_body.kd45.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren45 : checkRenG PRE_first_tail_x15_r0_body.kd45.hnd PRE_first_tail_x15_r0_body.khinv45 (phB PRE_first_tail_x15_r0_body.cx0_45.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband45 : PRE_first_tail_x15_r0_body.kd45.checkBand PRE_first_tail_x15_r0_body.P45.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos45 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd45.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren45 : checkRenG PRE_first_tail_x15_r0_body.kd45.node PRE_first_tail_x15_r0_body.kninv45 (pnB PRE_first_tail_x15_r0_body.cx0_45.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow45 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd45.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P45.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd45.nodeF j) PRE_first_tail_x15_r0_body.cx1_45.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a45 : PRE_first_tail_x15_r0_body.cx0_45.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b45 : PRE_first_tail_x15_r0_body.cx0_45.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok145 : PRE_first_tail_x15_r0_body.cx1_45.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend45 : PRE_first_tail_x15_r0_body.cx1_45.mlx.pending = PRE_first_tail_x15_r0_body.cx0_45.mlx.pending.map PRE_first_tail_x15_r0_body.kappa45.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh45 : PRE_first_tail_x15_r0_body.cx1_45.mlx.errh = PRE_first_tail_x15_r0_body.cx0_45.mlx.errh.map PRE_first_tail_x15_r0_body.kappa45.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles45 : PRE_first_tail_x15_r0_body.cx1_45.mlx.files = PRE_first_tail_x15_r0_body.cx0_45.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch45 : PRE_first_tail_x15_r0_body.cx1_45.mlx.arch = PRE_first_tail_x15_r0_body.cx0_45.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes45 : PRE_first_tail_x15_r0_body.cx1_45.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_45.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired45 : PRE_first_tail_x15_r0_body.cx1_45.mlx.wired = PRE_first_tail_x15_r0_body.cx0_45.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost45 : PRE_first_tail_x15_r0_body.cx1_45.host = PRE_first_tail_x15_r0_body.cx0_45.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd45`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn045 : PRE_first_tail_x15_r0_body.kd45.n0 = 2710755
kernel_rfl PRE_first_tail_x15_r0_body.ckn145 : PRE_first_tail_x15_r0_body.kd45.n1 = 2711105
kernel_rfl PRE_first_tail_x15_r0_body.ckheap45 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd45.heap).all (fun x => Nat.ble 2710740 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl45 : (List.range 15).all (fun j => decide (PRE_first_tail_x15_r0_body.kd45.heap.get (2710740 + j) = nth? PRE_first_tail_x15_r0_body.pl45 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja45 : Nat.ble 2710740 2710740 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn45 : Nat.ble 2013 2013 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD45 : Nat.ble 2710740 PRE_first_tail_x15_r0_body.kd45.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn45 : Nat.ble 19101 PRE_first_tail_x15_r0_body.kd45.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn45 : Nat.ble 16187 PRE_first_tail_x15_r0_body.kd45.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb45 : Nat.ble 19101 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap45 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd45.heap).all (Nat.ble (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd45 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd45.hnd).all (Nat.ble (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode45 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd45.node).all (Nat.ble (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix45 : Conv.FixOld (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa45 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja45) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn45) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD45) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn45) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn45) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb45) PRE_first_tail_x15_r0_body.fheap45 PRE_first_tail_x15_r0_body.fhnd45 PRE_first_tail_x15_r0_body.fnode45
kernel_rfl PRE_first_tail_x15_r0_body.fcxn45 : (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn45 : (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle045 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_45.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_45.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk45 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd45.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A45 : PRE_first_tail_x15_r0_body.cx1_45.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS45.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_45.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O45 : PRE_first_tail_x15_r0_body.cx1_45.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS45.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_45.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N45 : PRE_first_tail_x15_r0_body.cx1_45.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS45.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_45.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I45 : PRE_first_tail_x15_r0_body.cx1_45.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS45.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_45.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd45 : (PRE_first_tail_x15_r0_body.clo45 ++ PRE_first_tail_x15_r0_body.cln45 ++ PRE_first_tail_x15_r0_body.cli45 ++ PRE_first_tail_x15_r0_body.cwS45 ++ PRE_first_tail_x15_r0_body.cnS45 ++ PRE_first_tail_x15_r0_body.ciS45).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW45 : PRE_first_tail_x15_r0_body.cwS45.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo45.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI45 : PRE_first_tail_x15_r0_body.ciS45.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli45.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN45 : PRE_first_tail_x15_r0_body.cnS45.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF45 : PRE_first_tail_x15_r0_body.cln45.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh45 : PRE_first_tail_x15_r0_body.clo45.all (handleOK PRE_first_tail_x15_r0_body.kappa45 PRE_first_tail_x15_r0_body.P45.lo PRE_first_tail_x15_r0_body.cx0_45.mlx PRE_first_tail_x15_r0_body.cx1_45.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo45 : PRE_first_tail_x15_r0_body.clo45.map (fun h => PRE_first_tail_x15_r0_body.cx1_45.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa45.handle h)) = PRE_first_tail_x15_r0_body.clo45.map (fun h => (PRE_first_tail_x15_r0_body.cx0_45.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa45.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok45 : PRE_first_tail_x15_r0_body.clo45.all (objOK PRE_first_tail_x15_r0_body.kappa45 PRE_first_tail_x15_r0_body.P45.NL PRE_first_tail_x15_r0_body.cx0_45.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd45 : PRE_first_tail_x15_r0_body.cln45.all (nodeOKF PRE_first_tail_x15_r0_body.kappa45 PRE_first_tail_x15_r0_body.P45 PRE_first_tail_x15_r0_body.cx0_45.mlx PRE_first_tail_x15_r0_body.cx1_45.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp45 : ((PRE_first_tail_x15_r0_body.cln45.filter (fullB PRE_first_tail_x15_r0_body.P45))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_45.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa45.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln45.filter (fullB PRE_first_tail_x15_r0_body.P45))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_45.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa45.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI45 : incrB PRE_first_tail_x15_r0_body.kd45.nodeF (List.range' 16187 6) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK45 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd45.node).all (fun k => Nat.ble 16187 k && Nat.blt k 16193) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL45 : (PRE_first_tail_x15_r0_body.cln45.filter (Nat.ble PRE_first_tail_x15_r0_body.P45.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd45.nodeF i) && (Nat.blt i 16193 || Nat.ble PRE_first_tail_x15_r0_body.kd45.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord45 : (PRE_first_tail_x15_r0_body.cln45.filter (Nat.ble PRE_first_tail_x15_r0_body.P45.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd45.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd45.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd45.nodeF j) (PRE_first_tail_x15_r0_body.kd45.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow45 PRE_first_tail_x15_r0_body.cnn145 PRE_first_tail_x15_r0_body.fnordI45 PRE_first_tail_x15_r0_body.fnordK45 PRE_first_tail_x15_r0_body.fnordL45
kernel_rfl PRE_first_tail_x15_r0_body.fi45 : PRE_first_tail_x15_r0_body.cli45.all (pnB PRE_first_tail_x15_r0_body.cx0_45.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii45 : PRE_first_tail_x15_r0_body.cli45.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_45.mlx.items.get (PRE_first_tail_x15_r0_body.kappa45.node k) = (PRE_first_tail_x15_r0_body.cx0_45.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa45.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot45 (clean : Conv.NClean (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P45.NL) (cl : SSt (· < 2022) PRE_first_tail_x15_r0_body.cx0_45.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P45 2022 PRE_first_tail_x15_r0_body.kappa45 PRE_first_tail_x15_r0_body.kd45 PRE_first_tail_x15_r0_body.khinv45 PRE_first_tail_x15_r0_body.kninv45 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx PRE_first_tail_x15_r0_body.cx0_45.mlx PRE_first_tail_x15_r0_body.cx1_45.mlx (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo45 PRE_first_tail_x15_r0_body.cln45 PRE_first_tail_x15_r0_body.cli45 PRE_first_tail_x15_r0_body.cwS45 PRE_first_tail_x15_r0_body.cnS45 PRE_first_tail_x15_r0_body.ciS45 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh045, PRE_first_tail_x15_r0_body.cnh145, PRE_first_tail_x15_r0_body.cnn045, PRE_first_tail_x15_r0_body.cnn145, PRE_first_tail_x15_r0_body.cplo45, PRE_first_tail_x15_r0_body.ccnt45, PRE_first_tail_x15_r0_body.cnband45, PRE_first_tail_x15_r0_body.chbelow45, PRE_first_tail_x15_r0_body.chren45, PRE_first_tail_x15_r0_body.cband45, PRE_first_tail_x15_r0_body.cnh1pos45, PRE_first_tail_x15_r0_body.cnren45, PRE_first_tail_x15_r0_body.cnlow45, PRE_first_tail_x15_r0_body.cabs0a45, PRE_first_tail_x15_r0_body.cabs0b45, PRE_first_tail_x15_r0_body.ctok145, PRE_first_tail_x15_r0_body.cpend45, PRE_first_tail_x15_r0_body.cerrh45, PRE_first_tail_x15_r0_body.cfiles45, PRE_first_tail_x15_r0_body.carch45, PRE_first_tail_x15_r0_body.csizes45, PRE_first_tail_x15_r0_body.cwired45, PRE_first_tail_x15_r0_body.cfix45, clean, PRE_first_tail_x15_r0_body.fcxn45, PRE_first_tail_x15_r0_body.fcnn45, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle045, PRE_first_tail_x15_r0_body.fnk45, PRE_first_tail_x15_r0_body.ckA45, PRE_first_tail_x15_r0_body.cobjsK45, PRE_first_tail_x15_r0_body.cnodesK45, PRE_first_tail_x15_r0_body.citemsK45, PRE_first_tail_x15_r0_body.f1A45, PRE_first_tail_x15_r0_body.f1O45, PRE_first_tail_x15_r0_body.f1N45, PRE_first_tail_x15_r0_body.f1I45, PRE_first_tail_x15_r0_body.fbd45, PRE_first_tail_x15_r0_body.fincW45, PRE_first_tail_x15_r0_body.fincI45, PRE_first_tail_x15_r0_body.fincN45, PRE_first_tail_x15_r0_body.flnF45, PRE_first_tail_x15_r0_body.fh45, PRE_first_tail_x15_r0_body.fo45, PRE_first_tail_x15_r0_body.fok45, PRE_first_tail_x15_r0_body.fnd45, PRE_first_tail_x15_r0_body.fp45, PRE_first_tail_x15_r0_body.fnord45, PRE_first_tail_x15_r0_body.fi45, PRE_first_tail_x15_r0_body.fii45⟩
theorem PRE_first_tail_x15_r0_body.cnshift45 (clean : Conv.NClean (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P45.NL) (cl : SSt (· < 2022) PRE_first_tail_x15_r0_body.cx0_45.mlx) : NShift PRE_first_tail_x15_r0_body.P45 2022 PRE_first_tail_x15_r0_body.kappa45 PRE_first_tail_x15_r0_body.cx0_45 PRE_first_tail_x15_r0_body.cx1_45 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot45 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost45 (compact_a_eq PRE_first_tail_x15_r0_body.ckn045 PRE_first_tail_x15_r0_body.ckn145 PRE_first_tail_x15_r0_body.ckheap45 PRE_first_tail_x15_r0_body.ckpl45)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_45 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s407.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_45 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s407.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_45 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s407.ffi) = some PRE_first_tail_x15_r0_body.fxC_45
kernel_rfl PRE_first_tail_x15_r0_body.okrC_45 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s407.ffi) = some PRE_first_tail_x15_r0_body.krC_45
noncomputable def PRE_first_tail_x15_r0_body.fx0_45 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s409.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_45 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s409.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_45 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s409.ffi) = some PRE_first_tail_x15_r0_body.fx0_45
kernel_rfl PRE_first_tail_x15_r0_body.okr0_45 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s409.ffi) = some PRE_first_tail_x15_r0_body.kr0_45
noncomputable def PRE_first_tail_x15_r0_body.fx1_45 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s408.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_45 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s408.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_45 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s408.ffi) = some PRE_first_tail_x15_r0_body.fx1_45
kernel_rfl PRE_first_tail_x15_r0_body.okr1_45 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s408.ffi) = some PRE_first_tail_x15_r0_body.kr1_45
kernel_rfl PRE_first_tail_x15_r0_body.ff045 : PRE_first_tail_x15_r0_body.fx0_45 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_45 (PRE_first_tail_x15_r0_body.clo45.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_45.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff145 : PRE_first_tail_x15_r0_body.fx1_45 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_45 (PRE_first_tail_x15_r0_body.cwS45.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_45.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck45 : freedLB PRE_first_tail_x15_r0_body.kappa45 PRE_first_tail_x15_r0_body.cx0_45.mlx PRE_first_tail_x15_r0_body.fx0_45 PRE_first_tail_x15_r0_body.fx1_45 PRE_first_tail_x15_r0_body.clo45 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf045 : PRE_first_tail_x15_r0_body.kr0_45.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_45.flags (PRE_first_tail_x15_r0_body.clo45.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_45.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt045 : PRE_first_tail_x15_r0_body.kr0_45.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_45.targs (PRE_first_tail_x15_r0_body.clo45.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_45.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf145 : PRE_first_tail_x15_r0_body.kr1_45.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_45.flags (PRE_first_tail_x15_r0_body.cwS45.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_45.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt145 : PRE_first_tail_x15_r0_body.kr1_45.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_45.targs (PRE_first_tail_x15_r0_body.cwS45.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_45.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck45 : krecLB PRE_first_tail_x15_r0_body.kappa45 2022 PRE_first_tail_x15_r0_body.cx0_45.mlx PRE_first_tail_x15_r0_body.kr0_45 PRE_first_tail_x15_r0_body.kr1_45 PRE_first_tail_x15_r0_body.clo45 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn45 : Nat.ble 2013 2022 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge45 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s408.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s409.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR45 : pendRegB PRE_first_tail_x15_r0_body.kappa45 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s409.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe45 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s409.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s408.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift45 (clean : Conv.NClean (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P45.NL) (cl : SSt (· < 2022) PRE_first_tail_x15_r0_body.cx0_45.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_45.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_45.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_45.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_45.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P45 2022 PRE_first_tail_x15_r0_body.kappa45 PRE_first_tail_x15_r0_body.s409.ffi PRE_first_tail_x15_r0_body.s408.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift45 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue45, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp45 t ht),
    PRE_first_tail_x15_r0_body.cbridge45,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s409.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s408.ffi) (PRE_first_tail_x15_r0_body.cfoot45 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_45 PRE_first_tail_x15_r0_body.ofx1_45 hobjC PRE_first_tail_x15_r0_body.ff045 PRE_first_tail_x15_r0_body.ff145 PRE_first_tail_x15_r0_body.ffck45,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s409.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s408.ffi) (PRE_first_tail_x15_r0_body.cfoot45 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_45 PRE_first_tail_x15_r0_body.okr1_45 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn45) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf045 PRE_first_tail_x15_r0_body.fkt045 PRE_first_tail_x15_r0_body.fkf145 PRE_first_tail_x15_r0_body.fkt145 PRE_first_tail_x15_r0_body.fkck45,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh045 PRE_first_tail_x15_r0_body.cnh145 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe45) PRE_first_tail_x15_r0_body.cpendR45⟩

end Host.Load.Run.Tpl

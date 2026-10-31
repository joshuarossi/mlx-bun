import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl133
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 133 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc133 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P133 : LoadP := PRE_first_tail_x15_r0_body.Pc133.raise 17925
kernel_rfl PRE_first_tail_x15_r0_body.craise133 : Nat.ble PRE_first_tail_x15_r0_body.Pc133.N0 17925 = true
theorem PRE_first_tail_x15_r0_body.raised133 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc133 PRE_first_tail_x15_r0_body.P133 :=
  .inr ⟨17925, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise133, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_133 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_133 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1290.ffi)
def PRE_first_tail_x15_r0_body.khinv133 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv133 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS133 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS133 : List Nat := List.range' 17925 0
def PRE_first_tail_x15_r0_body.ciS133 : List Nat := [] ++ List.range' 17925 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0133 : PRE_first_tail_x15_r0_body.kd133.nh0 = PRE_first_tail_x15_r0_body.cx0_133.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1133 : PRE_first_tail_x15_r0_body.kd133.nh1 = PRE_first_tail_x15_r0_body.cx1_133.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0133 : PRE_first_tail_x15_r0_body.kd133.nn0 = PRE_first_tail_x15_r0_body.cx0_133.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1133 : PRE_first_tail_x15_r0_body.kd133.nn1 = PRE_first_tail_x15_r0_body.cx1_133.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo133 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P133.lo && Nat.ble PRE_first_tail_x15_r0_body.P133.lo PRE_first_tail_x15_r0_body.cx0_133.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P133.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P133.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt133 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_133.mlx.next PRE_first_tail_x15_r0_body.cx1_133.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_133.mlx.nnext PRE_first_tail_x15_r0_body.cx1_133.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband133 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P133.NL && Nat.ble PRE_first_tail_x15_r0_body.P133.NL PRE_first_tail_x15_r0_body.P133.N0 && Nat.ble PRE_first_tail_x15_r0_body.P133.N0 PRE_first_tail_x15_r0_body.cx0_133.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow133 : PRE_first_tail_x15_r0_body.kd133.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren133 : checkRenG PRE_first_tail_x15_r0_body.kd133.hnd PRE_first_tail_x15_r0_body.khinv133 (phB PRE_first_tail_x15_r0_body.cx0_133.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband133 : PRE_first_tail_x15_r0_body.kd133.checkBand PRE_first_tail_x15_r0_body.P133.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos133 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd133.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren133 : checkRenG PRE_first_tail_x15_r0_body.kd133.node PRE_first_tail_x15_r0_body.kninv133 (pnB PRE_first_tail_x15_r0_body.cx0_133.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow133 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd133.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P133.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd133.nodeF j) PRE_first_tail_x15_r0_body.cx1_133.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a133 : PRE_first_tail_x15_r0_body.cx0_133.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b133 : PRE_first_tail_x15_r0_body.cx0_133.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1133 : PRE_first_tail_x15_r0_body.cx1_133.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend133 : PRE_first_tail_x15_r0_body.cx1_133.mlx.pending = PRE_first_tail_x15_r0_body.cx0_133.mlx.pending.map PRE_first_tail_x15_r0_body.kappa133.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh133 : PRE_first_tail_x15_r0_body.cx1_133.mlx.errh = PRE_first_tail_x15_r0_body.cx0_133.mlx.errh.map PRE_first_tail_x15_r0_body.kappa133.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles133 : PRE_first_tail_x15_r0_body.cx1_133.mlx.files = PRE_first_tail_x15_r0_body.cx0_133.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch133 : PRE_first_tail_x15_r0_body.cx1_133.mlx.arch = PRE_first_tail_x15_r0_body.cx0_133.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes133 : PRE_first_tail_x15_r0_body.cx1_133.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_133.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired133 : PRE_first_tail_x15_r0_body.cx1_133.mlx.wired = PRE_first_tail_x15_r0_body.cx0_133.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost133 : PRE_first_tail_x15_r0_body.cx1_133.host = PRE_first_tail_x15_r0_body.cx0_133.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd133`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0133 : PRE_first_tail_x15_r0_body.kd133.n0 = 2779531
kernel_rfl PRE_first_tail_x15_r0_body.ckn1133 : PRE_first_tail_x15_r0_body.kd133.n1 = 2779533
kernel_rfl PRE_first_tail_x15_r0_body.ckheap133 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd133.heap).all (fun x => Nat.ble 2779531 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl133 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd133.heap.get (2779531 + j) = nth? PRE_first_tail_x15_r0_body.pl133 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja133 : Nat.ble 2779531 2779531 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn133 : Nat.ble 5765 5765 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD133 : Nat.ble 2779531 PRE_first_tail_x15_r0_body.kd133.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn133 : Nat.ble 20828 PRE_first_tail_x15_r0_body.kd133.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn133 : Nat.ble 17925 PRE_first_tail_x15_r0_body.kd133.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb133 : Nat.ble 20828 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap133 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd133.heap).all (Nat.ble (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd133 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd133.hnd).all (Nat.ble (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode133 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd133.node).all (Nat.ble (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix133 : Conv.FixOld (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa133 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja133) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn133) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD133) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn133) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn133) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb133) PRE_first_tail_x15_r0_body.fheap133 PRE_first_tail_x15_r0_body.fhnd133 PRE_first_tail_x15_r0_body.fnode133
kernel_rfl PRE_first_tail_x15_r0_body.fcxn133 : (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn133 : (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0133 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_133.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_133.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk133 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd133.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A133 : PRE_first_tail_x15_r0_body.cx1_133.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS133.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_133.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O133 : PRE_first_tail_x15_r0_body.cx1_133.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS133.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_133.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N133 : PRE_first_tail_x15_r0_body.cx1_133.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS133.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_133.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I133 : PRE_first_tail_x15_r0_body.cx1_133.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS133.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_133.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd133 : (PRE_first_tail_x15_r0_body.clo133 ++ PRE_first_tail_x15_r0_body.cln133 ++ PRE_first_tail_x15_r0_body.cli133 ++ PRE_first_tail_x15_r0_body.cwS133 ++ PRE_first_tail_x15_r0_body.cnS133 ++ PRE_first_tail_x15_r0_body.ciS133).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW133 : PRE_first_tail_x15_r0_body.cwS133.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo133.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI133 : PRE_first_tail_x15_r0_body.ciS133.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli133.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN133 : PRE_first_tail_x15_r0_body.cnS133.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF133 : PRE_first_tail_x15_r0_body.cln133.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh133 : PRE_first_tail_x15_r0_body.clo133.all (handleOK PRE_first_tail_x15_r0_body.kappa133 PRE_first_tail_x15_r0_body.P133.lo PRE_first_tail_x15_r0_body.cx0_133.mlx PRE_first_tail_x15_r0_body.cx1_133.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo133 : PRE_first_tail_x15_r0_body.clo133.map (fun h => PRE_first_tail_x15_r0_body.cx1_133.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa133.handle h)) = PRE_first_tail_x15_r0_body.clo133.map (fun h => (PRE_first_tail_x15_r0_body.cx0_133.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa133.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok133 : PRE_first_tail_x15_r0_body.clo133.all (objOK PRE_first_tail_x15_r0_body.kappa133 PRE_first_tail_x15_r0_body.P133.NL PRE_first_tail_x15_r0_body.cx0_133.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd133 : PRE_first_tail_x15_r0_body.cln133.all (nodeOKF PRE_first_tail_x15_r0_body.kappa133 PRE_first_tail_x15_r0_body.P133 PRE_first_tail_x15_r0_body.cx0_133.mlx PRE_first_tail_x15_r0_body.cx1_133.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp133 : ((PRE_first_tail_x15_r0_body.cln133.filter (fullB PRE_first_tail_x15_r0_body.P133))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_133.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa133.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln133.filter (fullB PRE_first_tail_x15_r0_body.P133))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_133.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa133.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI133 : incrB PRE_first_tail_x15_r0_body.kd133.nodeF (List.range' 17925 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK133 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd133.node).all (fun k => Nat.ble 17925 k && Nat.blt k 17925) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL133 : (PRE_first_tail_x15_r0_body.cln133.filter (Nat.ble PRE_first_tail_x15_r0_body.P133.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd133.nodeF i) && (Nat.blt i 17925 || Nat.ble PRE_first_tail_x15_r0_body.kd133.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord133 : (PRE_first_tail_x15_r0_body.cln133.filter (Nat.ble PRE_first_tail_x15_r0_body.P133.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd133.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd133.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd133.nodeF j) (PRE_first_tail_x15_r0_body.kd133.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow133 PRE_first_tail_x15_r0_body.cnn1133 PRE_first_tail_x15_r0_body.fnordI133 PRE_first_tail_x15_r0_body.fnordK133 PRE_first_tail_x15_r0_body.fnordL133
kernel_rfl PRE_first_tail_x15_r0_body.fi133 : PRE_first_tail_x15_r0_body.cli133.all (pnB PRE_first_tail_x15_r0_body.cx0_133.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii133 : PRE_first_tail_x15_r0_body.cli133.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_133.mlx.items.get (PRE_first_tail_x15_r0_body.kappa133.node k) = (PRE_first_tail_x15_r0_body.cx0_133.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa133.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot133 (clean : Conv.NClean (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P133.NL) (cl : SSt (· < 5765) PRE_first_tail_x15_r0_body.cx0_133.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P133 5765 PRE_first_tail_x15_r0_body.kappa133 PRE_first_tail_x15_r0_body.kd133 PRE_first_tail_x15_r0_body.khinv133 PRE_first_tail_x15_r0_body.kninv133 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx PRE_first_tail_x15_r0_body.cx0_133.mlx PRE_first_tail_x15_r0_body.cx1_133.mlx (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo133 PRE_first_tail_x15_r0_body.cln133 PRE_first_tail_x15_r0_body.cli133 PRE_first_tail_x15_r0_body.cwS133 PRE_first_tail_x15_r0_body.cnS133 PRE_first_tail_x15_r0_body.ciS133 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0133, PRE_first_tail_x15_r0_body.cnh1133, PRE_first_tail_x15_r0_body.cnn0133, PRE_first_tail_x15_r0_body.cnn1133, PRE_first_tail_x15_r0_body.cplo133, PRE_first_tail_x15_r0_body.ccnt133, PRE_first_tail_x15_r0_body.cnband133, PRE_first_tail_x15_r0_body.chbelow133, PRE_first_tail_x15_r0_body.chren133, PRE_first_tail_x15_r0_body.cband133, PRE_first_tail_x15_r0_body.cnh1pos133, PRE_first_tail_x15_r0_body.cnren133, PRE_first_tail_x15_r0_body.cnlow133, PRE_first_tail_x15_r0_body.cabs0a133, PRE_first_tail_x15_r0_body.cabs0b133, PRE_first_tail_x15_r0_body.ctok1133, PRE_first_tail_x15_r0_body.cpend133, PRE_first_tail_x15_r0_body.cerrh133, PRE_first_tail_x15_r0_body.cfiles133, PRE_first_tail_x15_r0_body.carch133, PRE_first_tail_x15_r0_body.csizes133, PRE_first_tail_x15_r0_body.cwired133, PRE_first_tail_x15_r0_body.cfix133, clean, PRE_first_tail_x15_r0_body.fcxn133, PRE_first_tail_x15_r0_body.fcnn133, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0133, PRE_first_tail_x15_r0_body.fnk133, PRE_first_tail_x15_r0_body.ckA133, PRE_first_tail_x15_r0_body.cobjsK133, PRE_first_tail_x15_r0_body.cnodesK133, PRE_first_tail_x15_r0_body.citemsK133, PRE_first_tail_x15_r0_body.f1A133, PRE_first_tail_x15_r0_body.f1O133, PRE_first_tail_x15_r0_body.f1N133, PRE_first_tail_x15_r0_body.f1I133, PRE_first_tail_x15_r0_body.fbd133, PRE_first_tail_x15_r0_body.fincW133, PRE_first_tail_x15_r0_body.fincI133, PRE_first_tail_x15_r0_body.fincN133, PRE_first_tail_x15_r0_body.flnF133, PRE_first_tail_x15_r0_body.fh133, PRE_first_tail_x15_r0_body.fo133, PRE_first_tail_x15_r0_body.fok133, PRE_first_tail_x15_r0_body.fnd133, PRE_first_tail_x15_r0_body.fp133, PRE_first_tail_x15_r0_body.fnord133, PRE_first_tail_x15_r0_body.fi133, PRE_first_tail_x15_r0_body.fii133⟩
theorem PRE_first_tail_x15_r0_body.cnshift133 (clean : Conv.NClean (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P133.NL) (cl : SSt (· < 5765) PRE_first_tail_x15_r0_body.cx0_133.mlx) : NShift PRE_first_tail_x15_r0_body.P133 5765 PRE_first_tail_x15_r0_body.kappa133 PRE_first_tail_x15_r0_body.cx0_133 PRE_first_tail_x15_r0_body.cx1_133 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot133 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost133 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0133 PRE_first_tail_x15_r0_body.ckn1133 PRE_first_tail_x15_r0_body.ckheap133 PRE_first_tail_x15_r0_body.ckpl133)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_133 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1289.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_133 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1289.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_133 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1289.ffi) = some PRE_first_tail_x15_r0_body.fxC_133
kernel_rfl PRE_first_tail_x15_r0_body.okrC_133 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1289.ffi) = some PRE_first_tail_x15_r0_body.krC_133
noncomputable def PRE_first_tail_x15_r0_body.fx0_133 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1291.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_133 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1291.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_133 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1291.ffi) = some PRE_first_tail_x15_r0_body.fx0_133
kernel_rfl PRE_first_tail_x15_r0_body.okr0_133 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1291.ffi) = some PRE_first_tail_x15_r0_body.kr0_133
noncomputable def PRE_first_tail_x15_r0_body.fx1_133 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1290.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_133 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1290.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_133 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1290.ffi) = some PRE_first_tail_x15_r0_body.fx1_133
kernel_rfl PRE_first_tail_x15_r0_body.okr1_133 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1290.ffi) = some PRE_first_tail_x15_r0_body.kr1_133
kernel_rfl PRE_first_tail_x15_r0_body.ff0133 : PRE_first_tail_x15_r0_body.fx0_133 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_133 (PRE_first_tail_x15_r0_body.clo133.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_133.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1133 : PRE_first_tail_x15_r0_body.fx1_133 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_133 (PRE_first_tail_x15_r0_body.cwS133.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_133.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck133 : freedLB PRE_first_tail_x15_r0_body.kappa133 PRE_first_tail_x15_r0_body.cx0_133.mlx PRE_first_tail_x15_r0_body.fx0_133 PRE_first_tail_x15_r0_body.fx1_133 PRE_first_tail_x15_r0_body.clo133 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0133 : PRE_first_tail_x15_r0_body.kr0_133.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_133.flags (PRE_first_tail_x15_r0_body.clo133.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_133.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0133 : PRE_first_tail_x15_r0_body.kr0_133.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_133.targs (PRE_first_tail_x15_r0_body.clo133.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_133.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1133 : PRE_first_tail_x15_r0_body.kr1_133.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_133.flags (PRE_first_tail_x15_r0_body.cwS133.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_133.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1133 : PRE_first_tail_x15_r0_body.kr1_133.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_133.targs (PRE_first_tail_x15_r0_body.cwS133.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_133.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck133 : krecLB PRE_first_tail_x15_r0_body.kappa133 5765 PRE_first_tail_x15_r0_body.cx0_133.mlx PRE_first_tail_x15_r0_body.kr0_133 PRE_first_tail_x15_r0_body.kr1_133 PRE_first_tail_x15_r0_body.clo133 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn133 : Nat.ble 5765 5765 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge133 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1290.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1291.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR133 : pendRegB PRE_first_tail_x15_r0_body.kappa133 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe133 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1290.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift133 (clean : Conv.NClean (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P133.NL) (cl : SSt (· < 5765) PRE_first_tail_x15_r0_body.cx0_133.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_133.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_133.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_133.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_133.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P133 5765 PRE_first_tail_x15_r0_body.kappa133 PRE_first_tail_x15_r0_body.s1291.ffi PRE_first_tail_x15_r0_body.s1290.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift133 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue133, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp133 t ht),
    PRE_first_tail_x15_r0_body.cbridge133,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1291.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1290.ffi) (PRE_first_tail_x15_r0_body.cfoot133 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_133 PRE_first_tail_x15_r0_body.ofx1_133 hobjC PRE_first_tail_x15_r0_body.ff0133 PRE_first_tail_x15_r0_body.ff1133 PRE_first_tail_x15_r0_body.ffck133,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1291.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1290.ffi) (PRE_first_tail_x15_r0_body.cfoot133 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_133 PRE_first_tail_x15_r0_body.okr1_133 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn133) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0133 PRE_first_tail_x15_r0_body.fkt0133 PRE_first_tail_x15_r0_body.fkf1133 PRE_first_tail_x15_r0_body.fkt1133 PRE_first_tail_x15_r0_body.fkck133,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0133 PRE_first_tail_x15_r0_body.cnh1133 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe133) PRE_first_tail_x15_r0_body.cpendR133⟩

end Host.Load.Run.Tpl

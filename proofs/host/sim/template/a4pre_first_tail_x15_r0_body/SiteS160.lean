import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl160
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 160 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc160 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P160 : LoadP := PRE_first_tail_x15_r0_body.Pc160.raise 18462
kernel_rfl PRE_first_tail_x15_r0_body.craise160 : Nat.ble PRE_first_tail_x15_r0_body.Pc160.N0 18462 = true
theorem PRE_first_tail_x15_r0_body.raised160 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc160 PRE_first_tail_x15_r0_body.P160 :=
  .inr ⟨18462, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise160, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_160 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1415.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_160 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1414.ffi)
def PRE_first_tail_x15_r0_body.khinv160 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv160 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS160 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS160 : List Nat := List.range' 18462 0
def PRE_first_tail_x15_r0_body.ciS160 : List Nat := [] ++ List.range' 18462 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0160 : PRE_first_tail_x15_r0_body.kd160.nh0 = PRE_first_tail_x15_r0_body.cx0_160.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1160 : PRE_first_tail_x15_r0_body.kd160.nh1 = PRE_first_tail_x15_r0_body.cx1_160.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0160 : PRE_first_tail_x15_r0_body.kd160.nn0 = PRE_first_tail_x15_r0_body.cx0_160.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1160 : PRE_first_tail_x15_r0_body.kd160.nn1 = PRE_first_tail_x15_r0_body.cx1_160.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo160 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P160.lo && Nat.ble PRE_first_tail_x15_r0_body.P160.lo PRE_first_tail_x15_r0_body.cx0_160.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P160.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P160.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt160 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_160.mlx.next PRE_first_tail_x15_r0_body.cx1_160.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_160.mlx.nnext PRE_first_tail_x15_r0_body.cx1_160.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband160 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P160.NL && Nat.ble PRE_first_tail_x15_r0_body.P160.NL PRE_first_tail_x15_r0_body.P160.N0 && Nat.ble PRE_first_tail_x15_r0_body.P160.N0 PRE_first_tail_x15_r0_body.cx0_160.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow160 : PRE_first_tail_x15_r0_body.kd160.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren160 : checkRenG PRE_first_tail_x15_r0_body.kd160.hnd PRE_first_tail_x15_r0_body.khinv160 (phB PRE_first_tail_x15_r0_body.cx0_160.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband160 : PRE_first_tail_x15_r0_body.kd160.checkBand PRE_first_tail_x15_r0_body.P160.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos160 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd160.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren160 : checkRenG PRE_first_tail_x15_r0_body.kd160.node PRE_first_tail_x15_r0_body.kninv160 (pnB PRE_first_tail_x15_r0_body.cx0_160.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow160 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd160.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P160.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd160.nodeF j) PRE_first_tail_x15_r0_body.cx1_160.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a160 : PRE_first_tail_x15_r0_body.cx0_160.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b160 : PRE_first_tail_x15_r0_body.cx0_160.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1160 : PRE_first_tail_x15_r0_body.cx1_160.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend160 : PRE_first_tail_x15_r0_body.cx1_160.mlx.pending = PRE_first_tail_x15_r0_body.cx0_160.mlx.pending.map PRE_first_tail_x15_r0_body.kappa160.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh160 : PRE_first_tail_x15_r0_body.cx1_160.mlx.errh = PRE_first_tail_x15_r0_body.cx0_160.mlx.errh.map PRE_first_tail_x15_r0_body.kappa160.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles160 : PRE_first_tail_x15_r0_body.cx1_160.mlx.files = PRE_first_tail_x15_r0_body.cx0_160.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch160 : PRE_first_tail_x15_r0_body.cx1_160.mlx.arch = PRE_first_tail_x15_r0_body.cx0_160.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes160 : PRE_first_tail_x15_r0_body.cx1_160.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_160.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired160 : PRE_first_tail_x15_r0_body.cx1_160.mlx.wired = PRE_first_tail_x15_r0_body.cx0_160.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost160 : PRE_first_tail_x15_r0_body.cx1_160.host = PRE_first_tail_x15_r0_body.cx0_160.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd160`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0160 : PRE_first_tail_x15_r0_body.kd160.n0 = 2800631
kernel_rfl PRE_first_tail_x15_r0_body.ckn1160 : PRE_first_tail_x15_r0_body.kd160.n1 = 2800633
kernel_rfl PRE_first_tail_x15_r0_body.ckheap160 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd160.heap).all (fun x => Nat.ble 2800631 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl160 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd160.heap.get (2800631 + j) = nth? PRE_first_tail_x15_r0_body.pl160 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja160 : Nat.ble 2800631 2800631 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn160 : Nat.ble 6920 6920 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD160 : Nat.ble 2800631 PRE_first_tail_x15_r0_body.kd160.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn160 : Nat.ble 21357 PRE_first_tail_x15_r0_body.kd160.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn160 : Nat.ble 18462 PRE_first_tail_x15_r0_body.kd160.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb160 : Nat.ble 21357 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap160 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd160.heap).all (Nat.ble (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd160 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd160.hnd).all (Nat.ble (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode160 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd160.node).all (Nat.ble (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix160 : Conv.FixOld (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa160 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja160) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn160) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD160) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn160) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn160) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb160) PRE_first_tail_x15_r0_body.fheap160 PRE_first_tail_x15_r0_body.fhnd160 PRE_first_tail_x15_r0_body.fnode160
kernel_rfl PRE_first_tail_x15_r0_body.fcxn160 : (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn160 : (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0160 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_160.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_160.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk160 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd160.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A160 : PRE_first_tail_x15_r0_body.cx1_160.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS160.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_160.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O160 : PRE_first_tail_x15_r0_body.cx1_160.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS160.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_160.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N160 : PRE_first_tail_x15_r0_body.cx1_160.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS160.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_160.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I160 : PRE_first_tail_x15_r0_body.cx1_160.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS160.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_160.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd160 : (PRE_first_tail_x15_r0_body.clo160 ++ PRE_first_tail_x15_r0_body.cln160 ++ PRE_first_tail_x15_r0_body.cli160 ++ PRE_first_tail_x15_r0_body.cwS160 ++ PRE_first_tail_x15_r0_body.cnS160 ++ PRE_first_tail_x15_r0_body.ciS160).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW160 : PRE_first_tail_x15_r0_body.cwS160.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo160.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI160 : PRE_first_tail_x15_r0_body.ciS160.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli160.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN160 : PRE_first_tail_x15_r0_body.cnS160.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF160 : PRE_first_tail_x15_r0_body.cln160.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh160 : PRE_first_tail_x15_r0_body.clo160.all (handleOK PRE_first_tail_x15_r0_body.kappa160 PRE_first_tail_x15_r0_body.P160.lo PRE_first_tail_x15_r0_body.cx0_160.mlx PRE_first_tail_x15_r0_body.cx1_160.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo160 : PRE_first_tail_x15_r0_body.clo160.map (fun h => PRE_first_tail_x15_r0_body.cx1_160.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa160.handle h)) = PRE_first_tail_x15_r0_body.clo160.map (fun h => (PRE_first_tail_x15_r0_body.cx0_160.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa160.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok160 : PRE_first_tail_x15_r0_body.clo160.all (objOK PRE_first_tail_x15_r0_body.kappa160 PRE_first_tail_x15_r0_body.P160.NL PRE_first_tail_x15_r0_body.cx0_160.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd160 : PRE_first_tail_x15_r0_body.cln160.all (nodeOKF PRE_first_tail_x15_r0_body.kappa160 PRE_first_tail_x15_r0_body.P160 PRE_first_tail_x15_r0_body.cx0_160.mlx PRE_first_tail_x15_r0_body.cx1_160.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp160 : ((PRE_first_tail_x15_r0_body.cln160.filter (fullB PRE_first_tail_x15_r0_body.P160))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_160.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa160.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln160.filter (fullB PRE_first_tail_x15_r0_body.P160))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_160.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa160.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI160 : incrB PRE_first_tail_x15_r0_body.kd160.nodeF (List.range' 18462 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK160 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd160.node).all (fun k => Nat.ble 18462 k && Nat.blt k 18462) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL160 : (PRE_first_tail_x15_r0_body.cln160.filter (Nat.ble PRE_first_tail_x15_r0_body.P160.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd160.nodeF i) && (Nat.blt i 18462 || Nat.ble PRE_first_tail_x15_r0_body.kd160.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord160 : (PRE_first_tail_x15_r0_body.cln160.filter (Nat.ble PRE_first_tail_x15_r0_body.P160.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd160.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd160.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd160.nodeF j) (PRE_first_tail_x15_r0_body.kd160.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow160 PRE_first_tail_x15_r0_body.cnn1160 PRE_first_tail_x15_r0_body.fnordI160 PRE_first_tail_x15_r0_body.fnordK160 PRE_first_tail_x15_r0_body.fnordL160
kernel_rfl PRE_first_tail_x15_r0_body.fi160 : PRE_first_tail_x15_r0_body.cli160.all (pnB PRE_first_tail_x15_r0_body.cx0_160.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii160 : PRE_first_tail_x15_r0_body.cli160.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_160.mlx.items.get (PRE_first_tail_x15_r0_body.kappa160.node k) = (PRE_first_tail_x15_r0_body.cx0_160.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa160.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot160 (clean : Conv.NClean (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P160.NL) (cl : SSt (· < 6920) PRE_first_tail_x15_r0_body.cx0_160.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P160 6920 PRE_first_tail_x15_r0_body.kappa160 PRE_first_tail_x15_r0_body.kd160 PRE_first_tail_x15_r0_body.khinv160 PRE_first_tail_x15_r0_body.kninv160 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx PRE_first_tail_x15_r0_body.cx0_160.mlx PRE_first_tail_x15_r0_body.cx1_160.mlx (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo160 PRE_first_tail_x15_r0_body.cln160 PRE_first_tail_x15_r0_body.cli160 PRE_first_tail_x15_r0_body.cwS160 PRE_first_tail_x15_r0_body.cnS160 PRE_first_tail_x15_r0_body.ciS160 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0160, PRE_first_tail_x15_r0_body.cnh1160, PRE_first_tail_x15_r0_body.cnn0160, PRE_first_tail_x15_r0_body.cnn1160, PRE_first_tail_x15_r0_body.cplo160, PRE_first_tail_x15_r0_body.ccnt160, PRE_first_tail_x15_r0_body.cnband160, PRE_first_tail_x15_r0_body.chbelow160, PRE_first_tail_x15_r0_body.chren160, PRE_first_tail_x15_r0_body.cband160, PRE_first_tail_x15_r0_body.cnh1pos160, PRE_first_tail_x15_r0_body.cnren160, PRE_first_tail_x15_r0_body.cnlow160, PRE_first_tail_x15_r0_body.cabs0a160, PRE_first_tail_x15_r0_body.cabs0b160, PRE_first_tail_x15_r0_body.ctok1160, PRE_first_tail_x15_r0_body.cpend160, PRE_first_tail_x15_r0_body.cerrh160, PRE_first_tail_x15_r0_body.cfiles160, PRE_first_tail_x15_r0_body.carch160, PRE_first_tail_x15_r0_body.csizes160, PRE_first_tail_x15_r0_body.cwired160, PRE_first_tail_x15_r0_body.cfix160, clean, PRE_first_tail_x15_r0_body.fcxn160, PRE_first_tail_x15_r0_body.fcnn160, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0160, PRE_first_tail_x15_r0_body.fnk160, PRE_first_tail_x15_r0_body.ckA160, PRE_first_tail_x15_r0_body.cobjsK160, PRE_first_tail_x15_r0_body.cnodesK160, PRE_first_tail_x15_r0_body.citemsK160, PRE_first_tail_x15_r0_body.f1A160, PRE_first_tail_x15_r0_body.f1O160, PRE_first_tail_x15_r0_body.f1N160, PRE_first_tail_x15_r0_body.f1I160, PRE_first_tail_x15_r0_body.fbd160, PRE_first_tail_x15_r0_body.fincW160, PRE_first_tail_x15_r0_body.fincI160, PRE_first_tail_x15_r0_body.fincN160, PRE_first_tail_x15_r0_body.flnF160, PRE_first_tail_x15_r0_body.fh160, PRE_first_tail_x15_r0_body.fo160, PRE_first_tail_x15_r0_body.fok160, PRE_first_tail_x15_r0_body.fnd160, PRE_first_tail_x15_r0_body.fp160, PRE_first_tail_x15_r0_body.fnord160, PRE_first_tail_x15_r0_body.fi160, PRE_first_tail_x15_r0_body.fii160⟩
theorem PRE_first_tail_x15_r0_body.cnshift160 (clean : Conv.NClean (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P160.NL) (cl : SSt (· < 6920) PRE_first_tail_x15_r0_body.cx0_160.mlx) : NShift PRE_first_tail_x15_r0_body.P160 6920 PRE_first_tail_x15_r0_body.kappa160 PRE_first_tail_x15_r0_body.cx0_160 PRE_first_tail_x15_r0_body.cx1_160 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot160 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost160 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0160 PRE_first_tail_x15_r0_body.ckn1160 PRE_first_tail_x15_r0_body.ckheap160 PRE_first_tail_x15_r0_body.ckpl160)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_160 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1413.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_160 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1413.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_160 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1413.ffi) = some PRE_first_tail_x15_r0_body.fxC_160
kernel_rfl PRE_first_tail_x15_r0_body.okrC_160 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1413.ffi) = some PRE_first_tail_x15_r0_body.krC_160
noncomputable def PRE_first_tail_x15_r0_body.fx0_160 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1415.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_160 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1415.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_160 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1415.ffi) = some PRE_first_tail_x15_r0_body.fx0_160
kernel_rfl PRE_first_tail_x15_r0_body.okr0_160 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1415.ffi) = some PRE_first_tail_x15_r0_body.kr0_160
noncomputable def PRE_first_tail_x15_r0_body.fx1_160 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1414.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_160 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1414.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_160 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1414.ffi) = some PRE_first_tail_x15_r0_body.fx1_160
kernel_rfl PRE_first_tail_x15_r0_body.okr1_160 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1414.ffi) = some PRE_first_tail_x15_r0_body.kr1_160
kernel_rfl PRE_first_tail_x15_r0_body.ff0160 : PRE_first_tail_x15_r0_body.fx0_160 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_160 (PRE_first_tail_x15_r0_body.clo160.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_160.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1160 : PRE_first_tail_x15_r0_body.fx1_160 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_160 (PRE_first_tail_x15_r0_body.cwS160.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_160.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck160 : freedLB PRE_first_tail_x15_r0_body.kappa160 PRE_first_tail_x15_r0_body.cx0_160.mlx PRE_first_tail_x15_r0_body.fx0_160 PRE_first_tail_x15_r0_body.fx1_160 PRE_first_tail_x15_r0_body.clo160 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0160 : PRE_first_tail_x15_r0_body.kr0_160.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_160.flags (PRE_first_tail_x15_r0_body.clo160.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_160.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0160 : PRE_first_tail_x15_r0_body.kr0_160.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_160.targs (PRE_first_tail_x15_r0_body.clo160.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_160.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1160 : PRE_first_tail_x15_r0_body.kr1_160.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_160.flags (PRE_first_tail_x15_r0_body.cwS160.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_160.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1160 : PRE_first_tail_x15_r0_body.kr1_160.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_160.targs (PRE_first_tail_x15_r0_body.cwS160.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_160.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck160 : krecLB PRE_first_tail_x15_r0_body.kappa160 6920 PRE_first_tail_x15_r0_body.cx0_160.mlx PRE_first_tail_x15_r0_body.kr0_160 PRE_first_tail_x15_r0_body.kr1_160 PRE_first_tail_x15_r0_body.clo160 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn160 : Nat.ble 6920 6920 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge160 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1414.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1415.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR160 : pendRegB PRE_first_tail_x15_r0_body.kappa160 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1415.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe160 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1415.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1414.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift160 (clean : Conv.NClean (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P160.NL) (cl : SSt (· < 6920) PRE_first_tail_x15_r0_body.cx0_160.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_160.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_160.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_160.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_160.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P160 6920 PRE_first_tail_x15_r0_body.kappa160 PRE_first_tail_x15_r0_body.s1415.ffi PRE_first_tail_x15_r0_body.s1414.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift160 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue160, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp160 t ht),
    PRE_first_tail_x15_r0_body.cbridge160,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1415.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1414.ffi) (PRE_first_tail_x15_r0_body.cfoot160 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_160 PRE_first_tail_x15_r0_body.ofx1_160 hobjC PRE_first_tail_x15_r0_body.ff0160 PRE_first_tail_x15_r0_body.ff1160 PRE_first_tail_x15_r0_body.ffck160,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1415.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1414.ffi) (PRE_first_tail_x15_r0_body.cfoot160 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_160 PRE_first_tail_x15_r0_body.okr1_160 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn160) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0160 PRE_first_tail_x15_r0_body.fkt0160 PRE_first_tail_x15_r0_body.fkf1160 PRE_first_tail_x15_r0_body.fkt1160 PRE_first_tail_x15_r0_body.fkck160,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0160 PRE_first_tail_x15_r0_body.cnh1160 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe160) PRE_first_tail_x15_r0_body.cpendR160⟩

end Host.Load.Run.Tpl

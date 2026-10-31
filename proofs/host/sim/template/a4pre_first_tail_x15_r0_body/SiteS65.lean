import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl65
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 65 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc65 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P65 : LoadP := PRE_first_tail_x15_r0_body.Pc65.raise 16570
kernel_rfl PRE_first_tail_x15_r0_body.craise65 : Nat.ble PRE_first_tail_x15_r0_body.Pc65.N0 16570 = true
theorem PRE_first_tail_x15_r0_body.raised65 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc65 PRE_first_tail_x15_r0_body.P65 :=
  .inr ⟨16570, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise65, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_65 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s634.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_65 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s633.ffi)
def PRE_first_tail_x15_r0_body.khinv65 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv65 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS65 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS65 : List Nat := List.range' 16570 0
def PRE_first_tail_x15_r0_body.ciS65 : List Nat := [] ++ List.range' 16570 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh065 : PRE_first_tail_x15_r0_body.kd65.nh0 = PRE_first_tail_x15_r0_body.cx0_65.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh165 : PRE_first_tail_x15_r0_body.kd65.nh1 = PRE_first_tail_x15_r0_body.cx1_65.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn065 : PRE_first_tail_x15_r0_body.kd65.nn0 = PRE_first_tail_x15_r0_body.cx0_65.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn165 : PRE_first_tail_x15_r0_body.kd65.nn1 = PRE_first_tail_x15_r0_body.cx1_65.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo65 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P65.lo && Nat.ble PRE_first_tail_x15_r0_body.P65.lo PRE_first_tail_x15_r0_body.cx0_65.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P65.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P65.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt65 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_65.mlx.next PRE_first_tail_x15_r0_body.cx1_65.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_65.mlx.nnext PRE_first_tail_x15_r0_body.cx1_65.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband65 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P65.NL && Nat.ble PRE_first_tail_x15_r0_body.P65.NL PRE_first_tail_x15_r0_body.P65.N0 && Nat.ble PRE_first_tail_x15_r0_body.P65.N0 PRE_first_tail_x15_r0_body.cx0_65.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow65 : PRE_first_tail_x15_r0_body.kd65.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren65 : checkRenG PRE_first_tail_x15_r0_body.kd65.hnd PRE_first_tail_x15_r0_body.khinv65 (phB PRE_first_tail_x15_r0_body.cx0_65.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband65 : PRE_first_tail_x15_r0_body.kd65.checkBand PRE_first_tail_x15_r0_body.P65.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos65 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd65.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren65 : checkRenG PRE_first_tail_x15_r0_body.kd65.node PRE_first_tail_x15_r0_body.kninv65 (pnB PRE_first_tail_x15_r0_body.cx0_65.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow65 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd65.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P65.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd65.nodeF j) PRE_first_tail_x15_r0_body.cx1_65.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a65 : PRE_first_tail_x15_r0_body.cx0_65.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b65 : PRE_first_tail_x15_r0_body.cx0_65.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok165 : PRE_first_tail_x15_r0_body.cx1_65.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend65 : PRE_first_tail_x15_r0_body.cx1_65.mlx.pending = PRE_first_tail_x15_r0_body.cx0_65.mlx.pending.map PRE_first_tail_x15_r0_body.kappa65.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh65 : PRE_first_tail_x15_r0_body.cx1_65.mlx.errh = PRE_first_tail_x15_r0_body.cx0_65.mlx.errh.map PRE_first_tail_x15_r0_body.kappa65.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles65 : PRE_first_tail_x15_r0_body.cx1_65.mlx.files = PRE_first_tail_x15_r0_body.cx0_65.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch65 : PRE_first_tail_x15_r0_body.cx1_65.mlx.arch = PRE_first_tail_x15_r0_body.cx0_65.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes65 : PRE_first_tail_x15_r0_body.cx1_65.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_65.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired65 : PRE_first_tail_x15_r0_body.cx1_65.mlx.wired = PRE_first_tail_x15_r0_body.cx0_65.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost65 : PRE_first_tail_x15_r0_body.cx1_65.host = PRE_first_tail_x15_r0_body.cx0_65.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd65`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn065 : PRE_first_tail_x15_r0_body.kd65.n0 = 2725588
kernel_rfl PRE_first_tail_x15_r0_body.ckn165 : PRE_first_tail_x15_r0_body.kd65.n1 = 2725598
kernel_rfl PRE_first_tail_x15_r0_body.ckheap65 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd65.heap).all (fun x => Nat.ble 2725587 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl65 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd65.heap.get (2725587 + j) = nth? PRE_first_tail_x15_r0_body.pl65 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja65 : Nat.ble 2725587 2725587 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn65 : Nat.ble 2833 2833 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD65 : Nat.ble 2725587 PRE_first_tail_x15_r0_body.kd65.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn65 : Nat.ble 19476 PRE_first_tail_x15_r0_body.kd65.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn65 : Nat.ble 16570 PRE_first_tail_x15_r0_body.kd65.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb65 : Nat.ble 19476 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap65 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd65.heap).all (Nat.ble (⟨19476, 16570, 2725587, 2833⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd65 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd65.hnd).all (Nat.ble (⟨19476, 16570, 2725587, 2833⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode65 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd65.node).all (Nat.ble (⟨19476, 16570, 2725587, 2833⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix65 : Conv.FixOld (⟨19476, 16570, 2725587, 2833⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa65 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja65) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn65) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD65) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn65) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn65) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb65) PRE_first_tail_x15_r0_body.fheap65 PRE_first_tail_x15_r0_body.fhnd65 PRE_first_tail_x15_r0_body.fnode65
kernel_rfl PRE_first_tail_x15_r0_body.fcxn65 : (⟨19476, 16570, 2725587, 2833⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn65 : (⟨19476, 16570, 2725587, 2833⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle065 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_65.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_65.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk65 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd65.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A65 : PRE_first_tail_x15_r0_body.cx1_65.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS65.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_65.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O65 : PRE_first_tail_x15_r0_body.cx1_65.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS65.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_65.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N65 : PRE_first_tail_x15_r0_body.cx1_65.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS65.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_65.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I65 : PRE_first_tail_x15_r0_body.cx1_65.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS65.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_65.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd65 : (PRE_first_tail_x15_r0_body.clo65 ++ PRE_first_tail_x15_r0_body.cln65 ++ PRE_first_tail_x15_r0_body.cli65 ++ PRE_first_tail_x15_r0_body.cwS65 ++ PRE_first_tail_x15_r0_body.cnS65 ++ PRE_first_tail_x15_r0_body.ciS65).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW65 : PRE_first_tail_x15_r0_body.cwS65.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo65.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI65 : PRE_first_tail_x15_r0_body.ciS65.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli65.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN65 : PRE_first_tail_x15_r0_body.cnS65.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF65 : PRE_first_tail_x15_r0_body.cln65.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh65 : PRE_first_tail_x15_r0_body.clo65.all (handleOK PRE_first_tail_x15_r0_body.kappa65 PRE_first_tail_x15_r0_body.P65.lo PRE_first_tail_x15_r0_body.cx0_65.mlx PRE_first_tail_x15_r0_body.cx1_65.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo65 : PRE_first_tail_x15_r0_body.clo65.map (fun h => PRE_first_tail_x15_r0_body.cx1_65.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa65.handle h)) = PRE_first_tail_x15_r0_body.clo65.map (fun h => (PRE_first_tail_x15_r0_body.cx0_65.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa65.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok65 : PRE_first_tail_x15_r0_body.clo65.all (objOK PRE_first_tail_x15_r0_body.kappa65 PRE_first_tail_x15_r0_body.P65.NL PRE_first_tail_x15_r0_body.cx0_65.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd65 : PRE_first_tail_x15_r0_body.cln65.all (nodeOKF PRE_first_tail_x15_r0_body.kappa65 PRE_first_tail_x15_r0_body.P65 PRE_first_tail_x15_r0_body.cx0_65.mlx PRE_first_tail_x15_r0_body.cx1_65.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp65 : ((PRE_first_tail_x15_r0_body.cln65.filter (fullB PRE_first_tail_x15_r0_body.P65))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_65.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa65.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln65.filter (fullB PRE_first_tail_x15_r0_body.P65))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_65.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa65.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI65 : incrB PRE_first_tail_x15_r0_body.kd65.nodeF (List.range' 16570 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK65 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd65.node).all (fun k => Nat.ble 16570 k && Nat.blt k 16570) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL65 : (PRE_first_tail_x15_r0_body.cln65.filter (Nat.ble PRE_first_tail_x15_r0_body.P65.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd65.nodeF i) && (Nat.blt i 16570 || Nat.ble PRE_first_tail_x15_r0_body.kd65.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord65 : (PRE_first_tail_x15_r0_body.cln65.filter (Nat.ble PRE_first_tail_x15_r0_body.P65.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd65.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd65.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd65.nodeF j) (PRE_first_tail_x15_r0_body.kd65.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow65 PRE_first_tail_x15_r0_body.cnn165 PRE_first_tail_x15_r0_body.fnordI65 PRE_first_tail_x15_r0_body.fnordK65 PRE_first_tail_x15_r0_body.fnordL65
kernel_rfl PRE_first_tail_x15_r0_body.fi65 : PRE_first_tail_x15_r0_body.cli65.all (pnB PRE_first_tail_x15_r0_body.cx0_65.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii65 : PRE_first_tail_x15_r0_body.cli65.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_65.mlx.items.get (PRE_first_tail_x15_r0_body.kappa65.node k) = (PRE_first_tail_x15_r0_body.cx0_65.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa65.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot65 (clean : Conv.NClean (⟨19476, 16570, 2725587, 2833⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P65.NL) (cl : SSt (· < 2833) PRE_first_tail_x15_r0_body.cx0_65.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P65 2833 PRE_first_tail_x15_r0_body.kappa65 PRE_first_tail_x15_r0_body.kd65 PRE_first_tail_x15_r0_body.khinv65 PRE_first_tail_x15_r0_body.kninv65 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx PRE_first_tail_x15_r0_body.cx0_65.mlx PRE_first_tail_x15_r0_body.cx1_65.mlx (⟨19476, 16570, 2725587, 2833⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo65 PRE_first_tail_x15_r0_body.cln65 PRE_first_tail_x15_r0_body.cli65 PRE_first_tail_x15_r0_body.cwS65 PRE_first_tail_x15_r0_body.cnS65 PRE_first_tail_x15_r0_body.ciS65 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh065, PRE_first_tail_x15_r0_body.cnh165, PRE_first_tail_x15_r0_body.cnn065, PRE_first_tail_x15_r0_body.cnn165, PRE_first_tail_x15_r0_body.cplo65, PRE_first_tail_x15_r0_body.ccnt65, PRE_first_tail_x15_r0_body.cnband65, PRE_first_tail_x15_r0_body.chbelow65, PRE_first_tail_x15_r0_body.chren65, PRE_first_tail_x15_r0_body.cband65, PRE_first_tail_x15_r0_body.cnh1pos65, PRE_first_tail_x15_r0_body.cnren65, PRE_first_tail_x15_r0_body.cnlow65, PRE_first_tail_x15_r0_body.cabs0a65, PRE_first_tail_x15_r0_body.cabs0b65, PRE_first_tail_x15_r0_body.ctok165, PRE_first_tail_x15_r0_body.cpend65, PRE_first_tail_x15_r0_body.cerrh65, PRE_first_tail_x15_r0_body.cfiles65, PRE_first_tail_x15_r0_body.carch65, PRE_first_tail_x15_r0_body.csizes65, PRE_first_tail_x15_r0_body.cwired65, PRE_first_tail_x15_r0_body.cfix65, clean, PRE_first_tail_x15_r0_body.fcxn65, PRE_first_tail_x15_r0_body.fcnn65, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle065, PRE_first_tail_x15_r0_body.fnk65, PRE_first_tail_x15_r0_body.ckA65, PRE_first_tail_x15_r0_body.cobjsK65, PRE_first_tail_x15_r0_body.cnodesK65, PRE_first_tail_x15_r0_body.citemsK65, PRE_first_tail_x15_r0_body.f1A65, PRE_first_tail_x15_r0_body.f1O65, PRE_first_tail_x15_r0_body.f1N65, PRE_first_tail_x15_r0_body.f1I65, PRE_first_tail_x15_r0_body.fbd65, PRE_first_tail_x15_r0_body.fincW65, PRE_first_tail_x15_r0_body.fincI65, PRE_first_tail_x15_r0_body.fincN65, PRE_first_tail_x15_r0_body.flnF65, PRE_first_tail_x15_r0_body.fh65, PRE_first_tail_x15_r0_body.fo65, PRE_first_tail_x15_r0_body.fok65, PRE_first_tail_x15_r0_body.fnd65, PRE_first_tail_x15_r0_body.fp65, PRE_first_tail_x15_r0_body.fnord65, PRE_first_tail_x15_r0_body.fi65, PRE_first_tail_x15_r0_body.fii65⟩
theorem PRE_first_tail_x15_r0_body.cnshift65 (clean : Conv.NClean (⟨19476, 16570, 2725587, 2833⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P65.NL) (cl : SSt (· < 2833) PRE_first_tail_x15_r0_body.cx0_65.mlx) : NShift PRE_first_tail_x15_r0_body.P65 2833 PRE_first_tail_x15_r0_body.kappa65 PRE_first_tail_x15_r0_body.cx0_65 PRE_first_tail_x15_r0_body.cx1_65 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot65 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost65 (compact_a_eq PRE_first_tail_x15_r0_body.ckn065 PRE_first_tail_x15_r0_body.ckn165 PRE_first_tail_x15_r0_body.ckheap65 PRE_first_tail_x15_r0_body.ckpl65)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_65 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s632.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_65 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s632.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_65 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s632.ffi) = some PRE_first_tail_x15_r0_body.fxC_65
kernel_rfl PRE_first_tail_x15_r0_body.okrC_65 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s632.ffi) = some PRE_first_tail_x15_r0_body.krC_65
noncomputable def PRE_first_tail_x15_r0_body.fx0_65 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s634.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_65 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s634.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_65 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s634.ffi) = some PRE_first_tail_x15_r0_body.fx0_65
kernel_rfl PRE_first_tail_x15_r0_body.okr0_65 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s634.ffi) = some PRE_first_tail_x15_r0_body.kr0_65
noncomputable def PRE_first_tail_x15_r0_body.fx1_65 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s633.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_65 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s633.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_65 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s633.ffi) = some PRE_first_tail_x15_r0_body.fx1_65
kernel_rfl PRE_first_tail_x15_r0_body.okr1_65 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s633.ffi) = some PRE_first_tail_x15_r0_body.kr1_65
kernel_rfl PRE_first_tail_x15_r0_body.ff065 : PRE_first_tail_x15_r0_body.fx0_65 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_65 (PRE_first_tail_x15_r0_body.clo65.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_65.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff165 : PRE_first_tail_x15_r0_body.fx1_65 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_65 (PRE_first_tail_x15_r0_body.cwS65.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_65.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck65 : freedLB PRE_first_tail_x15_r0_body.kappa65 PRE_first_tail_x15_r0_body.cx0_65.mlx PRE_first_tail_x15_r0_body.fx0_65 PRE_first_tail_x15_r0_body.fx1_65 PRE_first_tail_x15_r0_body.clo65 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf065 : PRE_first_tail_x15_r0_body.kr0_65.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_65.flags (PRE_first_tail_x15_r0_body.clo65.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_65.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt065 : PRE_first_tail_x15_r0_body.kr0_65.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_65.targs (PRE_first_tail_x15_r0_body.clo65.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_65.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf165 : PRE_first_tail_x15_r0_body.kr1_65.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_65.flags (PRE_first_tail_x15_r0_body.cwS65.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_65.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt165 : PRE_first_tail_x15_r0_body.kr1_65.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_65.targs (PRE_first_tail_x15_r0_body.cwS65.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_65.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck65 : krecLB PRE_first_tail_x15_r0_body.kappa65 2833 PRE_first_tail_x15_r0_body.cx0_65.mlx PRE_first_tail_x15_r0_body.kr0_65 PRE_first_tail_x15_r0_body.kr1_65 PRE_first_tail_x15_r0_body.clo65 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn65 : Nat.ble 2833 2833 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge65 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s633.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s634.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR65 : pendRegB PRE_first_tail_x15_r0_body.kappa65 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s634.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe65 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s634.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s633.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift65 (clean : Conv.NClean (⟨19476, 16570, 2725587, 2833⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P65.NL) (cl : SSt (· < 2833) PRE_first_tail_x15_r0_body.cx0_65.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_65.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_65.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_65.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_65.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19476, 16570, 2725587, 2833⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P65 2833 PRE_first_tail_x15_r0_body.kappa65 PRE_first_tail_x15_r0_body.s634.ffi PRE_first_tail_x15_r0_body.s633.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift65 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue65, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp65 t ht),
    PRE_first_tail_x15_r0_body.cbridge65,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s634.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s633.ffi) (PRE_first_tail_x15_r0_body.cfoot65 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_65 PRE_first_tail_x15_r0_body.ofx1_65 hobjC PRE_first_tail_x15_r0_body.ff065 PRE_first_tail_x15_r0_body.ff165 PRE_first_tail_x15_r0_body.ffck65,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s634.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s633.ffi) (PRE_first_tail_x15_r0_body.cfoot65 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_65 PRE_first_tail_x15_r0_body.okr1_65 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn65) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf065 PRE_first_tail_x15_r0_body.fkt065 PRE_first_tail_x15_r0_body.fkf165 PRE_first_tail_x15_r0_body.fkt165 PRE_first_tail_x15_r0_body.fkck65,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh065 PRE_first_tail_x15_r0_body.cnh165 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe65) PRE_first_tail_x15_r0_body.cpendR65⟩

end Host.Load.Run.Tpl

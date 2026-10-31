import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl55
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 55 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc55 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P55 : LoadP := PRE_first_tail_x15_r0_body.Pc55.raise 16392
kernel_rfl PRE_first_tail_x15_r0_body.craise55 : Nat.ble PRE_first_tail_x15_r0_body.Pc55.N0 16392 = true
theorem PRE_first_tail_x15_r0_body.raised55 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc55 PRE_first_tail_x15_r0_body.P55 :=
  .inr ⟨16392, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise55, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_55 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_55 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s543.ffi)
def PRE_first_tail_x15_r0_body.khinv55 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv55 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS55 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS55 : List Nat := List.range' 16392 0
def PRE_first_tail_x15_r0_body.ciS55 : List Nat := [] ++ List.range' 16392 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh055 : PRE_first_tail_x15_r0_body.kd55.nh0 = PRE_first_tail_x15_r0_body.cx0_55.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh155 : PRE_first_tail_x15_r0_body.kd55.nh1 = PRE_first_tail_x15_r0_body.cx1_55.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn055 : PRE_first_tail_x15_r0_body.kd55.nn0 = PRE_first_tail_x15_r0_body.cx0_55.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn155 : PRE_first_tail_x15_r0_body.kd55.nn1 = PRE_first_tail_x15_r0_body.cx1_55.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo55 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P55.lo && Nat.ble PRE_first_tail_x15_r0_body.P55.lo PRE_first_tail_x15_r0_body.cx0_55.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P55.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P55.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt55 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_55.mlx.next PRE_first_tail_x15_r0_body.cx1_55.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_55.mlx.nnext PRE_first_tail_x15_r0_body.cx1_55.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband55 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P55.NL && Nat.ble PRE_first_tail_x15_r0_body.P55.NL PRE_first_tail_x15_r0_body.P55.N0 && Nat.ble PRE_first_tail_x15_r0_body.P55.N0 PRE_first_tail_x15_r0_body.cx0_55.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow55 : PRE_first_tail_x15_r0_body.kd55.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren55 : checkRenG PRE_first_tail_x15_r0_body.kd55.hnd PRE_first_tail_x15_r0_body.khinv55 (phB PRE_first_tail_x15_r0_body.cx0_55.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband55 : PRE_first_tail_x15_r0_body.kd55.checkBand PRE_first_tail_x15_r0_body.P55.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos55 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd55.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren55 : checkRenG PRE_first_tail_x15_r0_body.kd55.node PRE_first_tail_x15_r0_body.kninv55 (pnB PRE_first_tail_x15_r0_body.cx0_55.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow55 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd55.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P55.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd55.nodeF j) PRE_first_tail_x15_r0_body.cx1_55.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a55 : PRE_first_tail_x15_r0_body.cx0_55.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b55 : PRE_first_tail_x15_r0_body.cx0_55.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok155 : PRE_first_tail_x15_r0_body.cx1_55.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend55 : PRE_first_tail_x15_r0_body.cx1_55.mlx.pending = PRE_first_tail_x15_r0_body.cx0_55.mlx.pending.map PRE_first_tail_x15_r0_body.kappa55.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh55 : PRE_first_tail_x15_r0_body.cx1_55.mlx.errh = PRE_first_tail_x15_r0_body.cx0_55.mlx.errh.map PRE_first_tail_x15_r0_body.kappa55.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles55 : PRE_first_tail_x15_r0_body.cx1_55.mlx.files = PRE_first_tail_x15_r0_body.cx0_55.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch55 : PRE_first_tail_x15_r0_body.cx1_55.mlx.arch = PRE_first_tail_x15_r0_body.cx0_55.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes55 : PRE_first_tail_x15_r0_body.cx1_55.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_55.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired55 : PRE_first_tail_x15_r0_body.cx1_55.mlx.wired = PRE_first_tail_x15_r0_body.cx0_55.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost55 : PRE_first_tail_x15_r0_body.cx1_55.host = PRE_first_tail_x15_r0_body.cx0_55.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd55`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn055 : PRE_first_tail_x15_r0_body.kd55.n0 = 2718139
kernel_rfl PRE_first_tail_x15_r0_body.ckn155 : PRE_first_tail_x15_r0_body.kd55.n1 = 2718141
kernel_rfl PRE_first_tail_x15_r0_body.ckheap55 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd55.heap).all (fun x => Nat.ble 2718139 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl55 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd55.heap.get (2718139 + j) = nth? PRE_first_tail_x15_r0_body.pl55 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja55 : Nat.ble 2718139 2718139 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn55 : Nat.ble 2432 2432 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD55 : Nat.ble 2718139 PRE_first_tail_x15_r0_body.kd55.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn55 : Nat.ble 19290 PRE_first_tail_x15_r0_body.kd55.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn55 : Nat.ble 16392 PRE_first_tail_x15_r0_body.kd55.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb55 : Nat.ble 19290 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap55 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd55.heap).all (Nat.ble (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd55 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd55.hnd).all (Nat.ble (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode55 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd55.node).all (Nat.ble (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix55 : Conv.FixOld (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa55 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja55) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn55) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD55) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn55) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn55) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb55) PRE_first_tail_x15_r0_body.fheap55 PRE_first_tail_x15_r0_body.fhnd55 PRE_first_tail_x15_r0_body.fnode55
kernel_rfl PRE_first_tail_x15_r0_body.fcxn55 : (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn55 : (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle055 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_55.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_55.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk55 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd55.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A55 : PRE_first_tail_x15_r0_body.cx1_55.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS55.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_55.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O55 : PRE_first_tail_x15_r0_body.cx1_55.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS55.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_55.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N55 : PRE_first_tail_x15_r0_body.cx1_55.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS55.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_55.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I55 : PRE_first_tail_x15_r0_body.cx1_55.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS55.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_55.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd55 : (PRE_first_tail_x15_r0_body.clo55 ++ PRE_first_tail_x15_r0_body.cln55 ++ PRE_first_tail_x15_r0_body.cli55 ++ PRE_first_tail_x15_r0_body.cwS55 ++ PRE_first_tail_x15_r0_body.cnS55 ++ PRE_first_tail_x15_r0_body.ciS55).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW55 : PRE_first_tail_x15_r0_body.cwS55.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo55.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI55 : PRE_first_tail_x15_r0_body.ciS55.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli55.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN55 : PRE_first_tail_x15_r0_body.cnS55.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF55 : PRE_first_tail_x15_r0_body.cln55.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh55 : PRE_first_tail_x15_r0_body.clo55.all (handleOK PRE_first_tail_x15_r0_body.kappa55 PRE_first_tail_x15_r0_body.P55.lo PRE_first_tail_x15_r0_body.cx0_55.mlx PRE_first_tail_x15_r0_body.cx1_55.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo55 : PRE_first_tail_x15_r0_body.clo55.map (fun h => PRE_first_tail_x15_r0_body.cx1_55.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa55.handle h)) = PRE_first_tail_x15_r0_body.clo55.map (fun h => (PRE_first_tail_x15_r0_body.cx0_55.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa55.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok55 : PRE_first_tail_x15_r0_body.clo55.all (objOK PRE_first_tail_x15_r0_body.kappa55 PRE_first_tail_x15_r0_body.P55.NL PRE_first_tail_x15_r0_body.cx0_55.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd55 : PRE_first_tail_x15_r0_body.cln55.all (nodeOKF PRE_first_tail_x15_r0_body.kappa55 PRE_first_tail_x15_r0_body.P55 PRE_first_tail_x15_r0_body.cx0_55.mlx PRE_first_tail_x15_r0_body.cx1_55.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp55 : ((PRE_first_tail_x15_r0_body.cln55.filter (fullB PRE_first_tail_x15_r0_body.P55))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_55.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa55.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln55.filter (fullB PRE_first_tail_x15_r0_body.P55))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_55.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa55.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI55 : incrB PRE_first_tail_x15_r0_body.kd55.nodeF (List.range' 16392 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK55 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd55.node).all (fun k => Nat.ble 16392 k && Nat.blt k 16392) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL55 : (PRE_first_tail_x15_r0_body.cln55.filter (Nat.ble PRE_first_tail_x15_r0_body.P55.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd55.nodeF i) && (Nat.blt i 16392 || Nat.ble PRE_first_tail_x15_r0_body.kd55.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord55 : (PRE_first_tail_x15_r0_body.cln55.filter (Nat.ble PRE_first_tail_x15_r0_body.P55.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd55.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd55.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd55.nodeF j) (PRE_first_tail_x15_r0_body.kd55.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow55 PRE_first_tail_x15_r0_body.cnn155 PRE_first_tail_x15_r0_body.fnordI55 PRE_first_tail_x15_r0_body.fnordK55 PRE_first_tail_x15_r0_body.fnordL55
kernel_rfl PRE_first_tail_x15_r0_body.fi55 : PRE_first_tail_x15_r0_body.cli55.all (pnB PRE_first_tail_x15_r0_body.cx0_55.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii55 : PRE_first_tail_x15_r0_body.cli55.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_55.mlx.items.get (PRE_first_tail_x15_r0_body.kappa55.node k) = (PRE_first_tail_x15_r0_body.cx0_55.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa55.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot55 (clean : Conv.NClean (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P55.NL) (cl : SSt (· < 2432) PRE_first_tail_x15_r0_body.cx0_55.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P55 2432 PRE_first_tail_x15_r0_body.kappa55 PRE_first_tail_x15_r0_body.kd55 PRE_first_tail_x15_r0_body.khinv55 PRE_first_tail_x15_r0_body.kninv55 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx PRE_first_tail_x15_r0_body.cx0_55.mlx PRE_first_tail_x15_r0_body.cx1_55.mlx (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo55 PRE_first_tail_x15_r0_body.cln55 PRE_first_tail_x15_r0_body.cli55 PRE_first_tail_x15_r0_body.cwS55 PRE_first_tail_x15_r0_body.cnS55 PRE_first_tail_x15_r0_body.ciS55 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh055, PRE_first_tail_x15_r0_body.cnh155, PRE_first_tail_x15_r0_body.cnn055, PRE_first_tail_x15_r0_body.cnn155, PRE_first_tail_x15_r0_body.cplo55, PRE_first_tail_x15_r0_body.ccnt55, PRE_first_tail_x15_r0_body.cnband55, PRE_first_tail_x15_r0_body.chbelow55, PRE_first_tail_x15_r0_body.chren55, PRE_first_tail_x15_r0_body.cband55, PRE_first_tail_x15_r0_body.cnh1pos55, PRE_first_tail_x15_r0_body.cnren55, PRE_first_tail_x15_r0_body.cnlow55, PRE_first_tail_x15_r0_body.cabs0a55, PRE_first_tail_x15_r0_body.cabs0b55, PRE_first_tail_x15_r0_body.ctok155, PRE_first_tail_x15_r0_body.cpend55, PRE_first_tail_x15_r0_body.cerrh55, PRE_first_tail_x15_r0_body.cfiles55, PRE_first_tail_x15_r0_body.carch55, PRE_first_tail_x15_r0_body.csizes55, PRE_first_tail_x15_r0_body.cwired55, PRE_first_tail_x15_r0_body.cfix55, clean, PRE_first_tail_x15_r0_body.fcxn55, PRE_first_tail_x15_r0_body.fcnn55, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle055, PRE_first_tail_x15_r0_body.fnk55, PRE_first_tail_x15_r0_body.ckA55, PRE_first_tail_x15_r0_body.cobjsK55, PRE_first_tail_x15_r0_body.cnodesK55, PRE_first_tail_x15_r0_body.citemsK55, PRE_first_tail_x15_r0_body.f1A55, PRE_first_tail_x15_r0_body.f1O55, PRE_first_tail_x15_r0_body.f1N55, PRE_first_tail_x15_r0_body.f1I55, PRE_first_tail_x15_r0_body.fbd55, PRE_first_tail_x15_r0_body.fincW55, PRE_first_tail_x15_r0_body.fincI55, PRE_first_tail_x15_r0_body.fincN55, PRE_first_tail_x15_r0_body.flnF55, PRE_first_tail_x15_r0_body.fh55, PRE_first_tail_x15_r0_body.fo55, PRE_first_tail_x15_r0_body.fok55, PRE_first_tail_x15_r0_body.fnd55, PRE_first_tail_x15_r0_body.fp55, PRE_first_tail_x15_r0_body.fnord55, PRE_first_tail_x15_r0_body.fi55, PRE_first_tail_x15_r0_body.fii55⟩
theorem PRE_first_tail_x15_r0_body.cnshift55 (clean : Conv.NClean (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P55.NL) (cl : SSt (· < 2432) PRE_first_tail_x15_r0_body.cx0_55.mlx) : NShift PRE_first_tail_x15_r0_body.P55 2432 PRE_first_tail_x15_r0_body.kappa55 PRE_first_tail_x15_r0_body.cx0_55 PRE_first_tail_x15_r0_body.cx1_55 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot55 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost55 (compact_a_eq PRE_first_tail_x15_r0_body.ckn055 PRE_first_tail_x15_r0_body.ckn155 PRE_first_tail_x15_r0_body.ckheap55 PRE_first_tail_x15_r0_body.ckpl55)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_55 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s542.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_55 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s542.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_55 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s542.ffi) = some PRE_first_tail_x15_r0_body.fxC_55
kernel_rfl PRE_first_tail_x15_r0_body.okrC_55 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s542.ffi) = some PRE_first_tail_x15_r0_body.krC_55
noncomputable def PRE_first_tail_x15_r0_body.fx0_55 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s544.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_55 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s544.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_55 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s544.ffi) = some PRE_first_tail_x15_r0_body.fx0_55
kernel_rfl PRE_first_tail_x15_r0_body.okr0_55 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s544.ffi) = some PRE_first_tail_x15_r0_body.kr0_55
noncomputable def PRE_first_tail_x15_r0_body.fx1_55 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s543.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_55 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s543.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_55 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s543.ffi) = some PRE_first_tail_x15_r0_body.fx1_55
kernel_rfl PRE_first_tail_x15_r0_body.okr1_55 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s543.ffi) = some PRE_first_tail_x15_r0_body.kr1_55
kernel_rfl PRE_first_tail_x15_r0_body.ff055 : PRE_first_tail_x15_r0_body.fx0_55 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_55 (PRE_first_tail_x15_r0_body.clo55.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_55.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff155 : PRE_first_tail_x15_r0_body.fx1_55 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_55 (PRE_first_tail_x15_r0_body.cwS55.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_55.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck55 : freedLB PRE_first_tail_x15_r0_body.kappa55 PRE_first_tail_x15_r0_body.cx0_55.mlx PRE_first_tail_x15_r0_body.fx0_55 PRE_first_tail_x15_r0_body.fx1_55 PRE_first_tail_x15_r0_body.clo55 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf055 : PRE_first_tail_x15_r0_body.kr0_55.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_55.flags (PRE_first_tail_x15_r0_body.clo55.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_55.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt055 : PRE_first_tail_x15_r0_body.kr0_55.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_55.targs (PRE_first_tail_x15_r0_body.clo55.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_55.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf155 : PRE_first_tail_x15_r0_body.kr1_55.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_55.flags (PRE_first_tail_x15_r0_body.cwS55.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_55.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt155 : PRE_first_tail_x15_r0_body.kr1_55.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_55.targs (PRE_first_tail_x15_r0_body.cwS55.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_55.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck55 : krecLB PRE_first_tail_x15_r0_body.kappa55 2432 PRE_first_tail_x15_r0_body.cx0_55.mlx PRE_first_tail_x15_r0_body.kr0_55 PRE_first_tail_x15_r0_body.kr1_55 PRE_first_tail_x15_r0_body.clo55 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn55 : Nat.ble 2432 2432 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge55 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s543.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s544.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR55 : pendRegB PRE_first_tail_x15_r0_body.kappa55 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe55 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s543.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift55 (clean : Conv.NClean (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P55.NL) (cl : SSt (· < 2432) PRE_first_tail_x15_r0_body.cx0_55.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_55.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_55.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_55.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_55.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P55 2432 PRE_first_tail_x15_r0_body.kappa55 PRE_first_tail_x15_r0_body.s544.ffi PRE_first_tail_x15_r0_body.s543.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift55 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue55, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp55 t ht),
    PRE_first_tail_x15_r0_body.cbridge55,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s544.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s543.ffi) (PRE_first_tail_x15_r0_body.cfoot55 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_55 PRE_first_tail_x15_r0_body.ofx1_55 hobjC PRE_first_tail_x15_r0_body.ff055 PRE_first_tail_x15_r0_body.ff155 PRE_first_tail_x15_r0_body.ffck55,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s544.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s543.ffi) (PRE_first_tail_x15_r0_body.cfoot55 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_55 PRE_first_tail_x15_r0_body.okr1_55 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn55) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf055 PRE_first_tail_x15_r0_body.fkt055 PRE_first_tail_x15_r0_body.fkf155 PRE_first_tail_x15_r0_body.fkt155 PRE_first_tail_x15_r0_body.fkck55,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh055 PRE_first_tail_x15_r0_body.cnh155 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe55) PRE_first_tail_x15_r0_body.cpendR55⟩

end Host.Load.Run.Tpl

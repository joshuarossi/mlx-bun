import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl117
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 117 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc117 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P117 : LoadP := PRE_first_tail_x15_r0_body.Pc117.raise 17615
kernel_rfl PRE_first_tail_x15_r0_body.craise117 : Nat.ble PRE_first_tail_x15_r0_body.Pc117.N0 17615 = true
theorem PRE_first_tail_x15_r0_body.raised117 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc117 PRE_first_tail_x15_r0_body.P117 :=
  .inr ⟨17615, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise117, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_117 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1039.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_117 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1038.ffi)
def PRE_first_tail_x15_r0_body.khinv117 : PTrie Nat := Stage.setAll PTrie.nil [(20519, 20517), (20520, 20518), (20522, 20519), (20521, 20520)]
def PRE_first_tail_x15_r0_body.kninv117 : PTrie Nat := Stage.setAll PTrie.nil [(17609, 17609), (17610, 17610), (17611, 17611), (17612, 17612), (17613, 17613), (17614, 17614)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS117 : List Nat := [20517, 20518, 20519, 20520, 20521, 20522]
def PRE_first_tail_x15_r0_body.cnS117 : List Nat := List.range' 17609 6
def PRE_first_tail_x15_r0_body.ciS117 : List Nat := [] ++ List.range' 17609 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0117 : PRE_first_tail_x15_r0_body.kd117.nh0 = PRE_first_tail_x15_r0_body.cx0_117.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1117 : PRE_first_tail_x15_r0_body.kd117.nh1 = PRE_first_tail_x15_r0_body.cx1_117.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0117 : PRE_first_tail_x15_r0_body.kd117.nn0 = PRE_first_tail_x15_r0_body.cx0_117.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1117 : PRE_first_tail_x15_r0_body.kd117.nn1 = PRE_first_tail_x15_r0_body.cx1_117.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo117 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P117.lo && Nat.ble PRE_first_tail_x15_r0_body.P117.lo PRE_first_tail_x15_r0_body.cx0_117.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P117.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P117.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt117 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_117.mlx.next PRE_first_tail_x15_r0_body.cx1_117.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_117.mlx.nnext PRE_first_tail_x15_r0_body.cx1_117.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband117 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P117.NL && Nat.ble PRE_first_tail_x15_r0_body.P117.NL PRE_first_tail_x15_r0_body.P117.N0 && Nat.ble PRE_first_tail_x15_r0_body.P117.N0 PRE_first_tail_x15_r0_body.cx0_117.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow117 : PRE_first_tail_x15_r0_body.kd117.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren117 : checkRenG PRE_first_tail_x15_r0_body.kd117.hnd PRE_first_tail_x15_r0_body.khinv117 (phB PRE_first_tail_x15_r0_body.cx0_117.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband117 : PRE_first_tail_x15_r0_body.kd117.checkBand PRE_first_tail_x15_r0_body.P117.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos117 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd117.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren117 : checkRenG PRE_first_tail_x15_r0_body.kd117.node PRE_first_tail_x15_r0_body.kninv117 (pnB PRE_first_tail_x15_r0_body.cx0_117.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow117 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd117.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P117.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd117.nodeF j) PRE_first_tail_x15_r0_body.cx1_117.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a117 : PRE_first_tail_x15_r0_body.cx0_117.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b117 : PRE_first_tail_x15_r0_body.cx0_117.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1117 : PRE_first_tail_x15_r0_body.cx1_117.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend117 : PRE_first_tail_x15_r0_body.cx1_117.mlx.pending = PRE_first_tail_x15_r0_body.cx0_117.mlx.pending.map PRE_first_tail_x15_r0_body.kappa117.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh117 : PRE_first_tail_x15_r0_body.cx1_117.mlx.errh = PRE_first_tail_x15_r0_body.cx0_117.mlx.errh.map PRE_first_tail_x15_r0_body.kappa117.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles117 : PRE_first_tail_x15_r0_body.cx1_117.mlx.files = PRE_first_tail_x15_r0_body.cx0_117.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch117 : PRE_first_tail_x15_r0_body.cx1_117.mlx.arch = PRE_first_tail_x15_r0_body.cx0_117.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes117 : PRE_first_tail_x15_r0_body.cx1_117.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_117.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired117 : PRE_first_tail_x15_r0_body.cx1_117.mlx.wired = PRE_first_tail_x15_r0_body.cx0_117.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost117 : PRE_first_tail_x15_r0_body.cx1_117.host = PRE_first_tail_x15_r0_body.cx0_117.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd117`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0117 : PRE_first_tail_x15_r0_body.kd117.n0 = 2767259
kernel_rfl PRE_first_tail_x15_r0_body.ckn1117 : PRE_first_tail_x15_r0_body.kd117.n1 = 2767609
kernel_rfl PRE_first_tail_x15_r0_body.ckheap117 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd117.heap).all (fun x => Nat.ble 2767244 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl117 : (List.range 15).all (fun j => decide (PRE_first_tail_x15_r0_body.kd117.heap.get (2767244 + j) = nth? PRE_first_tail_x15_r0_body.pl117 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja117 : Nat.ble 2767244 2767244 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn117 : Nat.ble 5091 5091 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD117 : Nat.ble 2767244 PRE_first_tail_x15_r0_body.kd117.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn117 : Nat.ble 20517 PRE_first_tail_x15_r0_body.kd117.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn117 : Nat.ble 17609 PRE_first_tail_x15_r0_body.kd117.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb117 : Nat.ble 20517 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap117 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd117.heap).all (Nat.ble (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd117 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd117.hnd).all (Nat.ble (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode117 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd117.node).all (Nat.ble (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix117 : Conv.FixOld (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa117 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja117) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn117) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD117) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn117) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn117) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb117) PRE_first_tail_x15_r0_body.fheap117 PRE_first_tail_x15_r0_body.fhnd117 PRE_first_tail_x15_r0_body.fnode117
kernel_rfl PRE_first_tail_x15_r0_body.fcxn117 : (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn117 : (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0117 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_117.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_117.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk117 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd117.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A117 : PRE_first_tail_x15_r0_body.cx1_117.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS117.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_117.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O117 : PRE_first_tail_x15_r0_body.cx1_117.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS117.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_117.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N117 : PRE_first_tail_x15_r0_body.cx1_117.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS117.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_117.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I117 : PRE_first_tail_x15_r0_body.cx1_117.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS117.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_117.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd117 : (PRE_first_tail_x15_r0_body.clo117 ++ PRE_first_tail_x15_r0_body.cln117 ++ PRE_first_tail_x15_r0_body.cli117 ++ PRE_first_tail_x15_r0_body.cwS117 ++ PRE_first_tail_x15_r0_body.cnS117 ++ PRE_first_tail_x15_r0_body.ciS117).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW117 : PRE_first_tail_x15_r0_body.cwS117.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo117.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI117 : PRE_first_tail_x15_r0_body.ciS117.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli117.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN117 : PRE_first_tail_x15_r0_body.cnS117.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF117 : PRE_first_tail_x15_r0_body.cln117.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh117 : PRE_first_tail_x15_r0_body.clo117.all (handleOK PRE_first_tail_x15_r0_body.kappa117 PRE_first_tail_x15_r0_body.P117.lo PRE_first_tail_x15_r0_body.cx0_117.mlx PRE_first_tail_x15_r0_body.cx1_117.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo117 : PRE_first_tail_x15_r0_body.clo117.map (fun h => PRE_first_tail_x15_r0_body.cx1_117.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa117.handle h)) = PRE_first_tail_x15_r0_body.clo117.map (fun h => (PRE_first_tail_x15_r0_body.cx0_117.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa117.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok117 : PRE_first_tail_x15_r0_body.clo117.all (objOK PRE_first_tail_x15_r0_body.kappa117 PRE_first_tail_x15_r0_body.P117.NL PRE_first_tail_x15_r0_body.cx0_117.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd117 : PRE_first_tail_x15_r0_body.cln117.all (nodeOKF PRE_first_tail_x15_r0_body.kappa117 PRE_first_tail_x15_r0_body.P117 PRE_first_tail_x15_r0_body.cx0_117.mlx PRE_first_tail_x15_r0_body.cx1_117.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp117 : ((PRE_first_tail_x15_r0_body.cln117.filter (fullB PRE_first_tail_x15_r0_body.P117))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_117.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa117.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln117.filter (fullB PRE_first_tail_x15_r0_body.P117))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_117.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa117.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI117 : incrB PRE_first_tail_x15_r0_body.kd117.nodeF (List.range' 17609 6) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK117 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd117.node).all (fun k => Nat.ble 17609 k && Nat.blt k 17615) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL117 : (PRE_first_tail_x15_r0_body.cln117.filter (Nat.ble PRE_first_tail_x15_r0_body.P117.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd117.nodeF i) && (Nat.blt i 17615 || Nat.ble PRE_first_tail_x15_r0_body.kd117.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord117 : (PRE_first_tail_x15_r0_body.cln117.filter (Nat.ble PRE_first_tail_x15_r0_body.P117.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd117.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd117.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd117.nodeF j) (PRE_first_tail_x15_r0_body.kd117.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow117 PRE_first_tail_x15_r0_body.cnn1117 PRE_first_tail_x15_r0_body.fnordI117 PRE_first_tail_x15_r0_body.fnordK117 PRE_first_tail_x15_r0_body.fnordL117
kernel_rfl PRE_first_tail_x15_r0_body.fi117 : PRE_first_tail_x15_r0_body.cli117.all (pnB PRE_first_tail_x15_r0_body.cx0_117.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii117 : PRE_first_tail_x15_r0_body.cli117.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_117.mlx.items.get (PRE_first_tail_x15_r0_body.kappa117.node k) = (PRE_first_tail_x15_r0_body.cx0_117.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa117.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot117 (clean : Conv.NClean (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P117.NL) (cl : SSt (· < 5100) PRE_first_tail_x15_r0_body.cx0_117.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P117 5100 PRE_first_tail_x15_r0_body.kappa117 PRE_first_tail_x15_r0_body.kd117 PRE_first_tail_x15_r0_body.khinv117 PRE_first_tail_x15_r0_body.kninv117 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx PRE_first_tail_x15_r0_body.cx0_117.mlx PRE_first_tail_x15_r0_body.cx1_117.mlx (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo117 PRE_first_tail_x15_r0_body.cln117 PRE_first_tail_x15_r0_body.cli117 PRE_first_tail_x15_r0_body.cwS117 PRE_first_tail_x15_r0_body.cnS117 PRE_first_tail_x15_r0_body.ciS117 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0117, PRE_first_tail_x15_r0_body.cnh1117, PRE_first_tail_x15_r0_body.cnn0117, PRE_first_tail_x15_r0_body.cnn1117, PRE_first_tail_x15_r0_body.cplo117, PRE_first_tail_x15_r0_body.ccnt117, PRE_first_tail_x15_r0_body.cnband117, PRE_first_tail_x15_r0_body.chbelow117, PRE_first_tail_x15_r0_body.chren117, PRE_first_tail_x15_r0_body.cband117, PRE_first_tail_x15_r0_body.cnh1pos117, PRE_first_tail_x15_r0_body.cnren117, PRE_first_tail_x15_r0_body.cnlow117, PRE_first_tail_x15_r0_body.cabs0a117, PRE_first_tail_x15_r0_body.cabs0b117, PRE_first_tail_x15_r0_body.ctok1117, PRE_first_tail_x15_r0_body.cpend117, PRE_first_tail_x15_r0_body.cerrh117, PRE_first_tail_x15_r0_body.cfiles117, PRE_first_tail_x15_r0_body.carch117, PRE_first_tail_x15_r0_body.csizes117, PRE_first_tail_x15_r0_body.cwired117, PRE_first_tail_x15_r0_body.cfix117, clean, PRE_first_tail_x15_r0_body.fcxn117, PRE_first_tail_x15_r0_body.fcnn117, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0117, PRE_first_tail_x15_r0_body.fnk117, PRE_first_tail_x15_r0_body.ckA117, PRE_first_tail_x15_r0_body.cobjsK117, PRE_first_tail_x15_r0_body.cnodesK117, PRE_first_tail_x15_r0_body.citemsK117, PRE_first_tail_x15_r0_body.f1A117, PRE_first_tail_x15_r0_body.f1O117, PRE_first_tail_x15_r0_body.f1N117, PRE_first_tail_x15_r0_body.f1I117, PRE_first_tail_x15_r0_body.fbd117, PRE_first_tail_x15_r0_body.fincW117, PRE_first_tail_x15_r0_body.fincI117, PRE_first_tail_x15_r0_body.fincN117, PRE_first_tail_x15_r0_body.flnF117, PRE_first_tail_x15_r0_body.fh117, PRE_first_tail_x15_r0_body.fo117, PRE_first_tail_x15_r0_body.fok117, PRE_first_tail_x15_r0_body.fnd117, PRE_first_tail_x15_r0_body.fp117, PRE_first_tail_x15_r0_body.fnord117, PRE_first_tail_x15_r0_body.fi117, PRE_first_tail_x15_r0_body.fii117⟩
theorem PRE_first_tail_x15_r0_body.cnshift117 (clean : Conv.NClean (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P117.NL) (cl : SSt (· < 5100) PRE_first_tail_x15_r0_body.cx0_117.mlx) : NShift PRE_first_tail_x15_r0_body.P117 5100 PRE_first_tail_x15_r0_body.kappa117 PRE_first_tail_x15_r0_body.cx0_117 PRE_first_tail_x15_r0_body.cx1_117 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot117 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost117 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0117 PRE_first_tail_x15_r0_body.ckn1117 PRE_first_tail_x15_r0_body.ckheap117 PRE_first_tail_x15_r0_body.ckpl117)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_117 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1037.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_117 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1037.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_117 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1037.ffi) = some PRE_first_tail_x15_r0_body.fxC_117
kernel_rfl PRE_first_tail_x15_r0_body.okrC_117 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1037.ffi) = some PRE_first_tail_x15_r0_body.krC_117
noncomputable def PRE_first_tail_x15_r0_body.fx0_117 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1039.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_117 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1039.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_117 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1039.ffi) = some PRE_first_tail_x15_r0_body.fx0_117
kernel_rfl PRE_first_tail_x15_r0_body.okr0_117 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1039.ffi) = some PRE_first_tail_x15_r0_body.kr0_117
noncomputable def PRE_first_tail_x15_r0_body.fx1_117 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1038.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_117 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1038.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_117 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1038.ffi) = some PRE_first_tail_x15_r0_body.fx1_117
kernel_rfl PRE_first_tail_x15_r0_body.okr1_117 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1038.ffi) = some PRE_first_tail_x15_r0_body.kr1_117
kernel_rfl PRE_first_tail_x15_r0_body.ff0117 : PRE_first_tail_x15_r0_body.fx0_117 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_117 (PRE_first_tail_x15_r0_body.clo117.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_117.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1117 : PRE_first_tail_x15_r0_body.fx1_117 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_117 (PRE_first_tail_x15_r0_body.cwS117.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_117.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck117 : freedLB PRE_first_tail_x15_r0_body.kappa117 PRE_first_tail_x15_r0_body.cx0_117.mlx PRE_first_tail_x15_r0_body.fx0_117 PRE_first_tail_x15_r0_body.fx1_117 PRE_first_tail_x15_r0_body.clo117 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0117 : PRE_first_tail_x15_r0_body.kr0_117.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_117.flags (PRE_first_tail_x15_r0_body.clo117.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_117.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0117 : PRE_first_tail_x15_r0_body.kr0_117.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_117.targs (PRE_first_tail_x15_r0_body.clo117.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_117.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1117 : PRE_first_tail_x15_r0_body.kr1_117.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_117.flags (PRE_first_tail_x15_r0_body.cwS117.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_117.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1117 : PRE_first_tail_x15_r0_body.kr1_117.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_117.targs (PRE_first_tail_x15_r0_body.cwS117.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_117.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck117 : krecLB PRE_first_tail_x15_r0_body.kappa117 5100 PRE_first_tail_x15_r0_body.cx0_117.mlx PRE_first_tail_x15_r0_body.kr0_117 PRE_first_tail_x15_r0_body.kr1_117 PRE_first_tail_x15_r0_body.clo117 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn117 : Nat.ble 5091 5100 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge117 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1038.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1039.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR117 : pendRegB PRE_first_tail_x15_r0_body.kappa117 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1039.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe117 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1039.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1038.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift117 (clean : Conv.NClean (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P117.NL) (cl : SSt (· < 5100) PRE_first_tail_x15_r0_body.cx0_117.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_117.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_117.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_117.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1037.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_117.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P117 5100 PRE_first_tail_x15_r0_body.kappa117 PRE_first_tail_x15_r0_body.s1039.ffi PRE_first_tail_x15_r0_body.s1038.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift117 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue117, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp117 t ht),
    PRE_first_tail_x15_r0_body.cbridge117,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1039.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1038.ffi) (PRE_first_tail_x15_r0_body.cfoot117 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_117 PRE_first_tail_x15_r0_body.ofx1_117 hobjC PRE_first_tail_x15_r0_body.ff0117 PRE_first_tail_x15_r0_body.ff1117 PRE_first_tail_x15_r0_body.ffck117,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1039.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1038.ffi) (PRE_first_tail_x15_r0_body.cfoot117 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_117 PRE_first_tail_x15_r0_body.okr1_117 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn117) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0117 PRE_first_tail_x15_r0_body.fkt0117 PRE_first_tail_x15_r0_body.fkf1117 PRE_first_tail_x15_r0_body.fkt1117 PRE_first_tail_x15_r0_body.fkck117,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0117 PRE_first_tail_x15_r0_body.cnh1117 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe117) PRE_first_tail_x15_r0_body.cpendR117⟩

end Host.Load.Run.Tpl

import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl85
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 85 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc85 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P85 : LoadP := PRE_first_tail_x15_r0_body.Pc85.raise 16977
kernel_rfl PRE_first_tail_x15_r0_body.craise85 : Nat.ble PRE_first_tail_x15_r0_body.Pc85.N0 16977 = true
theorem PRE_first_tail_x15_r0_body.raised85 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc85 PRE_first_tail_x15_r0_body.P85 :=
  .inr ⟨16977, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise85, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_85 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s831.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_85 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s830.ffi)
def PRE_first_tail_x15_r0_body.khinv85 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv85 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS85 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS85 : List Nat := List.range' 16977 0
def PRE_first_tail_x15_r0_body.ciS85 : List Nat := [] ++ List.range' 16977 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh085 : PRE_first_tail_x15_r0_body.kd85.nh0 = PRE_first_tail_x15_r0_body.cx0_85.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh185 : PRE_first_tail_x15_r0_body.kd85.nh1 = PRE_first_tail_x15_r0_body.cx1_85.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn085 : PRE_first_tail_x15_r0_body.kd85.nn0 = PRE_first_tail_x15_r0_body.cx0_85.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn185 : PRE_first_tail_x15_r0_body.kd85.nn1 = PRE_first_tail_x15_r0_body.cx1_85.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo85 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P85.lo && Nat.ble PRE_first_tail_x15_r0_body.P85.lo PRE_first_tail_x15_r0_body.cx0_85.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P85.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P85.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt85 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_85.mlx.next PRE_first_tail_x15_r0_body.cx1_85.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_85.mlx.nnext PRE_first_tail_x15_r0_body.cx1_85.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband85 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P85.NL && Nat.ble PRE_first_tail_x15_r0_body.P85.NL PRE_first_tail_x15_r0_body.P85.N0 && Nat.ble PRE_first_tail_x15_r0_body.P85.N0 PRE_first_tail_x15_r0_body.cx0_85.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow85 : PRE_first_tail_x15_r0_body.kd85.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren85 : checkRenG PRE_first_tail_x15_r0_body.kd85.hnd PRE_first_tail_x15_r0_body.khinv85 (phB PRE_first_tail_x15_r0_body.cx0_85.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband85 : PRE_first_tail_x15_r0_body.kd85.checkBand PRE_first_tail_x15_r0_body.P85.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos85 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd85.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren85 : checkRenG PRE_first_tail_x15_r0_body.kd85.node PRE_first_tail_x15_r0_body.kninv85 (pnB PRE_first_tail_x15_r0_body.cx0_85.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow85 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd85.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P85.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd85.nodeF j) PRE_first_tail_x15_r0_body.cx1_85.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a85 : PRE_first_tail_x15_r0_body.cx0_85.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b85 : PRE_first_tail_x15_r0_body.cx0_85.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok185 : PRE_first_tail_x15_r0_body.cx1_85.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend85 : PRE_first_tail_x15_r0_body.cx1_85.mlx.pending = PRE_first_tail_x15_r0_body.cx0_85.mlx.pending.map PRE_first_tail_x15_r0_body.kappa85.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh85 : PRE_first_tail_x15_r0_body.cx1_85.mlx.errh = PRE_first_tail_x15_r0_body.cx0_85.mlx.errh.map PRE_first_tail_x15_r0_body.kappa85.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles85 : PRE_first_tail_x15_r0_body.cx1_85.mlx.files = PRE_first_tail_x15_r0_body.cx0_85.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch85 : PRE_first_tail_x15_r0_body.cx1_85.mlx.arch = PRE_first_tail_x15_r0_body.cx0_85.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes85 : PRE_first_tail_x15_r0_body.cx1_85.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_85.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired85 : PRE_first_tail_x15_r0_body.cx1_85.mlx.wired = PRE_first_tail_x15_r0_body.cx0_85.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost85 : PRE_first_tail_x15_r0_body.cx1_85.host = PRE_first_tail_x15_r0_body.cx0_85.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd85`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn085 : PRE_first_tail_x15_r0_body.kd85.n0 = 2741867
kernel_rfl PRE_first_tail_x15_r0_body.ckn185 : PRE_first_tail_x15_r0_body.kd85.n1 = 2741869
kernel_rfl PRE_first_tail_x15_r0_body.ckheap85 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd85.heap).all (fun x => Nat.ble 2741867 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl85 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd85.heap.get (2741867 + j) = nth? PRE_first_tail_x15_r0_body.pl85 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja85 : Nat.ble 2741867 2741867 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn85 : Nat.ble 3713 3713 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD85 : Nat.ble 2741867 PRE_first_tail_x15_r0_body.kd85.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn85 : Nat.ble 19884 PRE_first_tail_x15_r0_body.kd85.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn85 : Nat.ble 16977 PRE_first_tail_x15_r0_body.kd85.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb85 : Nat.ble 19884 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap85 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd85.heap).all (Nat.ble (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd85 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd85.hnd).all (Nat.ble (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode85 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd85.node).all (Nat.ble (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix85 : Conv.FixOld (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa85 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja85) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn85) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD85) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn85) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn85) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb85) PRE_first_tail_x15_r0_body.fheap85 PRE_first_tail_x15_r0_body.fhnd85 PRE_first_tail_x15_r0_body.fnode85
kernel_rfl PRE_first_tail_x15_r0_body.fcxn85 : (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn85 : (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle085 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_85.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_85.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk85 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd85.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A85 : PRE_first_tail_x15_r0_body.cx1_85.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS85.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_85.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O85 : PRE_first_tail_x15_r0_body.cx1_85.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS85.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_85.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N85 : PRE_first_tail_x15_r0_body.cx1_85.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS85.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_85.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I85 : PRE_first_tail_x15_r0_body.cx1_85.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS85.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_85.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd85 : (PRE_first_tail_x15_r0_body.clo85 ++ PRE_first_tail_x15_r0_body.cln85 ++ PRE_first_tail_x15_r0_body.cli85 ++ PRE_first_tail_x15_r0_body.cwS85 ++ PRE_first_tail_x15_r0_body.cnS85 ++ PRE_first_tail_x15_r0_body.ciS85).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW85 : PRE_first_tail_x15_r0_body.cwS85.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo85.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI85 : PRE_first_tail_x15_r0_body.ciS85.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli85.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN85 : PRE_first_tail_x15_r0_body.cnS85.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF85 : PRE_first_tail_x15_r0_body.cln85.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh85 : PRE_first_tail_x15_r0_body.clo85.all (handleOK PRE_first_tail_x15_r0_body.kappa85 PRE_first_tail_x15_r0_body.P85.lo PRE_first_tail_x15_r0_body.cx0_85.mlx PRE_first_tail_x15_r0_body.cx1_85.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo85 : PRE_first_tail_x15_r0_body.clo85.map (fun h => PRE_first_tail_x15_r0_body.cx1_85.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa85.handle h)) = PRE_first_tail_x15_r0_body.clo85.map (fun h => (PRE_first_tail_x15_r0_body.cx0_85.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa85.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok85 : PRE_first_tail_x15_r0_body.clo85.all (objOK PRE_first_tail_x15_r0_body.kappa85 PRE_first_tail_x15_r0_body.P85.NL PRE_first_tail_x15_r0_body.cx0_85.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd85 : PRE_first_tail_x15_r0_body.cln85.all (nodeOKF PRE_first_tail_x15_r0_body.kappa85 PRE_first_tail_x15_r0_body.P85 PRE_first_tail_x15_r0_body.cx0_85.mlx PRE_first_tail_x15_r0_body.cx1_85.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp85 : ((PRE_first_tail_x15_r0_body.cln85.filter (fullB PRE_first_tail_x15_r0_body.P85))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_85.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa85.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln85.filter (fullB PRE_first_tail_x15_r0_body.P85))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_85.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa85.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI85 : incrB PRE_first_tail_x15_r0_body.kd85.nodeF (List.range' 16977 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK85 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd85.node).all (fun k => Nat.ble 16977 k && Nat.blt k 16977) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL85 : (PRE_first_tail_x15_r0_body.cln85.filter (Nat.ble PRE_first_tail_x15_r0_body.P85.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd85.nodeF i) && (Nat.blt i 16977 || Nat.ble PRE_first_tail_x15_r0_body.kd85.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord85 : (PRE_first_tail_x15_r0_body.cln85.filter (Nat.ble PRE_first_tail_x15_r0_body.P85.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd85.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd85.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd85.nodeF j) (PRE_first_tail_x15_r0_body.kd85.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow85 PRE_first_tail_x15_r0_body.cnn185 PRE_first_tail_x15_r0_body.fnordI85 PRE_first_tail_x15_r0_body.fnordK85 PRE_first_tail_x15_r0_body.fnordL85
kernel_rfl PRE_first_tail_x15_r0_body.fi85 : PRE_first_tail_x15_r0_body.cli85.all (pnB PRE_first_tail_x15_r0_body.cx0_85.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii85 : PRE_first_tail_x15_r0_body.cli85.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_85.mlx.items.get (PRE_first_tail_x15_r0_body.kappa85.node k) = (PRE_first_tail_x15_r0_body.cx0_85.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa85.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot85 (clean : Conv.NClean (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P85.NL) (cl : SSt (· < 3713) PRE_first_tail_x15_r0_body.cx0_85.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P85 3713 PRE_first_tail_x15_r0_body.kappa85 PRE_first_tail_x15_r0_body.kd85 PRE_first_tail_x15_r0_body.khinv85 PRE_first_tail_x15_r0_body.kninv85 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx PRE_first_tail_x15_r0_body.cx0_85.mlx PRE_first_tail_x15_r0_body.cx1_85.mlx (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo85 PRE_first_tail_x15_r0_body.cln85 PRE_first_tail_x15_r0_body.cli85 PRE_first_tail_x15_r0_body.cwS85 PRE_first_tail_x15_r0_body.cnS85 PRE_first_tail_x15_r0_body.ciS85 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh085, PRE_first_tail_x15_r0_body.cnh185, PRE_first_tail_x15_r0_body.cnn085, PRE_first_tail_x15_r0_body.cnn185, PRE_first_tail_x15_r0_body.cplo85, PRE_first_tail_x15_r0_body.ccnt85, PRE_first_tail_x15_r0_body.cnband85, PRE_first_tail_x15_r0_body.chbelow85, PRE_first_tail_x15_r0_body.chren85, PRE_first_tail_x15_r0_body.cband85, PRE_first_tail_x15_r0_body.cnh1pos85, PRE_first_tail_x15_r0_body.cnren85, PRE_first_tail_x15_r0_body.cnlow85, PRE_first_tail_x15_r0_body.cabs0a85, PRE_first_tail_x15_r0_body.cabs0b85, PRE_first_tail_x15_r0_body.ctok185, PRE_first_tail_x15_r0_body.cpend85, PRE_first_tail_x15_r0_body.cerrh85, PRE_first_tail_x15_r0_body.cfiles85, PRE_first_tail_x15_r0_body.carch85, PRE_first_tail_x15_r0_body.csizes85, PRE_first_tail_x15_r0_body.cwired85, PRE_first_tail_x15_r0_body.cfix85, clean, PRE_first_tail_x15_r0_body.fcxn85, PRE_first_tail_x15_r0_body.fcnn85, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle085, PRE_first_tail_x15_r0_body.fnk85, PRE_first_tail_x15_r0_body.ckA85, PRE_first_tail_x15_r0_body.cobjsK85, PRE_first_tail_x15_r0_body.cnodesK85, PRE_first_tail_x15_r0_body.citemsK85, PRE_first_tail_x15_r0_body.f1A85, PRE_first_tail_x15_r0_body.f1O85, PRE_first_tail_x15_r0_body.f1N85, PRE_first_tail_x15_r0_body.f1I85, PRE_first_tail_x15_r0_body.fbd85, PRE_first_tail_x15_r0_body.fincW85, PRE_first_tail_x15_r0_body.fincI85, PRE_first_tail_x15_r0_body.fincN85, PRE_first_tail_x15_r0_body.flnF85, PRE_first_tail_x15_r0_body.fh85, PRE_first_tail_x15_r0_body.fo85, PRE_first_tail_x15_r0_body.fok85, PRE_first_tail_x15_r0_body.fnd85, PRE_first_tail_x15_r0_body.fp85, PRE_first_tail_x15_r0_body.fnord85, PRE_first_tail_x15_r0_body.fi85, PRE_first_tail_x15_r0_body.fii85⟩
theorem PRE_first_tail_x15_r0_body.cnshift85 (clean : Conv.NClean (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P85.NL) (cl : SSt (· < 3713) PRE_first_tail_x15_r0_body.cx0_85.mlx) : NShift PRE_first_tail_x15_r0_body.P85 3713 PRE_first_tail_x15_r0_body.kappa85 PRE_first_tail_x15_r0_body.cx0_85 PRE_first_tail_x15_r0_body.cx1_85 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot85 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost85 (compact_a_eq PRE_first_tail_x15_r0_body.ckn085 PRE_first_tail_x15_r0_body.ckn185 PRE_first_tail_x15_r0_body.ckheap85 PRE_first_tail_x15_r0_body.ckpl85)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_85 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s829.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_85 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s829.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_85 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s829.ffi) = some PRE_first_tail_x15_r0_body.fxC_85
kernel_rfl PRE_first_tail_x15_r0_body.okrC_85 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s829.ffi) = some PRE_first_tail_x15_r0_body.krC_85
noncomputable def PRE_first_tail_x15_r0_body.fx0_85 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s831.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_85 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s831.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_85 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s831.ffi) = some PRE_first_tail_x15_r0_body.fx0_85
kernel_rfl PRE_first_tail_x15_r0_body.okr0_85 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s831.ffi) = some PRE_first_tail_x15_r0_body.kr0_85
noncomputable def PRE_first_tail_x15_r0_body.fx1_85 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s830.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_85 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s830.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_85 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s830.ffi) = some PRE_first_tail_x15_r0_body.fx1_85
kernel_rfl PRE_first_tail_x15_r0_body.okr1_85 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s830.ffi) = some PRE_first_tail_x15_r0_body.kr1_85
kernel_rfl PRE_first_tail_x15_r0_body.ff085 : PRE_first_tail_x15_r0_body.fx0_85 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_85 (PRE_first_tail_x15_r0_body.clo85.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_85.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff185 : PRE_first_tail_x15_r0_body.fx1_85 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_85 (PRE_first_tail_x15_r0_body.cwS85.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_85.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck85 : freedLB PRE_first_tail_x15_r0_body.kappa85 PRE_first_tail_x15_r0_body.cx0_85.mlx PRE_first_tail_x15_r0_body.fx0_85 PRE_first_tail_x15_r0_body.fx1_85 PRE_first_tail_x15_r0_body.clo85 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf085 : PRE_first_tail_x15_r0_body.kr0_85.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_85.flags (PRE_first_tail_x15_r0_body.clo85.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_85.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt085 : PRE_first_tail_x15_r0_body.kr0_85.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_85.targs (PRE_first_tail_x15_r0_body.clo85.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_85.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf185 : PRE_first_tail_x15_r0_body.kr1_85.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_85.flags (PRE_first_tail_x15_r0_body.cwS85.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_85.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt185 : PRE_first_tail_x15_r0_body.kr1_85.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_85.targs (PRE_first_tail_x15_r0_body.cwS85.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_85.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck85 : krecLB PRE_first_tail_x15_r0_body.kappa85 3713 PRE_first_tail_x15_r0_body.cx0_85.mlx PRE_first_tail_x15_r0_body.kr0_85 PRE_first_tail_x15_r0_body.kr1_85 PRE_first_tail_x15_r0_body.clo85 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn85 : Nat.ble 3713 3713 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge85 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s830.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s831.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR85 : pendRegB PRE_first_tail_x15_r0_body.kappa85 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s831.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe85 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s831.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s830.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift85 (clean : Conv.NClean (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P85.NL) (cl : SSt (· < 3713) PRE_first_tail_x15_r0_body.cx0_85.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_85.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_85.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_85.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_85.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P85 3713 PRE_first_tail_x15_r0_body.kappa85 PRE_first_tail_x15_r0_body.s831.ffi PRE_first_tail_x15_r0_body.s830.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift85 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue85, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp85 t ht),
    PRE_first_tail_x15_r0_body.cbridge85,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s831.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s830.ffi) (PRE_first_tail_x15_r0_body.cfoot85 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_85 PRE_first_tail_x15_r0_body.ofx1_85 hobjC PRE_first_tail_x15_r0_body.ff085 PRE_first_tail_x15_r0_body.ff185 PRE_first_tail_x15_r0_body.ffck85,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s831.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s830.ffi) (PRE_first_tail_x15_r0_body.cfoot85 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_85 PRE_first_tail_x15_r0_body.okr1_85 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn85) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf085 PRE_first_tail_x15_r0_body.fkt085 PRE_first_tail_x15_r0_body.fkf185 PRE_first_tail_x15_r0_body.fkt185 PRE_first_tail_x15_r0_body.fkck85,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh085 PRE_first_tail_x15_r0_body.cnh185 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe85) PRE_first_tail_x15_r0_body.cpendR85⟩

end Host.Load.Run.Tpl

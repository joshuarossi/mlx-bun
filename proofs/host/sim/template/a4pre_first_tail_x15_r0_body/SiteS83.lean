import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl83
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 83 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc83 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P83 : LoadP := PRE_first_tail_x15_r0_body.Pc83.raise 16918
kernel_rfl PRE_first_tail_x15_r0_body.craise83 : Nat.ble PRE_first_tail_x15_r0_body.Pc83.N0 16918 = true
theorem PRE_first_tail_x15_r0_body.raised83 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc83 PRE_first_tail_x15_r0_body.P83 :=
  .inr ⟨16918, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise83, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_83 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_83 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s734.ffi)
def PRE_first_tail_x15_r0_body.khinv83 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv83 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS83 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS83 : List Nat := List.range' 16918 0
def PRE_first_tail_x15_r0_body.ciS83 : List Nat := [] ++ List.range' 16918 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh083 : PRE_first_tail_x15_r0_body.kd83.nh0 = PRE_first_tail_x15_r0_body.cx0_83.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh183 : PRE_first_tail_x15_r0_body.kd83.nh1 = PRE_first_tail_x15_r0_body.cx1_83.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn083 : PRE_first_tail_x15_r0_body.kd83.nn0 = PRE_first_tail_x15_r0_body.cx0_83.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn183 : PRE_first_tail_x15_r0_body.kd83.nn1 = PRE_first_tail_x15_r0_body.cx1_83.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo83 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P83.lo && Nat.ble PRE_first_tail_x15_r0_body.P83.lo PRE_first_tail_x15_r0_body.cx0_83.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P83.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P83.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt83 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_83.mlx.next PRE_first_tail_x15_r0_body.cx1_83.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_83.mlx.nnext PRE_first_tail_x15_r0_body.cx1_83.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband83 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P83.NL && Nat.ble PRE_first_tail_x15_r0_body.P83.NL PRE_first_tail_x15_r0_body.P83.N0 && Nat.ble PRE_first_tail_x15_r0_body.P83.N0 PRE_first_tail_x15_r0_body.cx0_83.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow83 : PRE_first_tail_x15_r0_body.kd83.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren83 : checkRenG PRE_first_tail_x15_r0_body.kd83.hnd PRE_first_tail_x15_r0_body.khinv83 (phB PRE_first_tail_x15_r0_body.cx0_83.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband83 : PRE_first_tail_x15_r0_body.kd83.checkBand PRE_first_tail_x15_r0_body.P83.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos83 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd83.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren83 : checkRenG PRE_first_tail_x15_r0_body.kd83.node PRE_first_tail_x15_r0_body.kninv83 (pnB PRE_first_tail_x15_r0_body.cx0_83.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow83 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd83.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P83.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd83.nodeF j) PRE_first_tail_x15_r0_body.cx1_83.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a83 : PRE_first_tail_x15_r0_body.cx0_83.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b83 : PRE_first_tail_x15_r0_body.cx0_83.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok183 : PRE_first_tail_x15_r0_body.cx1_83.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend83 : PRE_first_tail_x15_r0_body.cx1_83.mlx.pending = PRE_first_tail_x15_r0_body.cx0_83.mlx.pending.map PRE_first_tail_x15_r0_body.kappa83.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh83 : PRE_first_tail_x15_r0_body.cx1_83.mlx.errh = PRE_first_tail_x15_r0_body.cx0_83.mlx.errh.map PRE_first_tail_x15_r0_body.kappa83.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles83 : PRE_first_tail_x15_r0_body.cx1_83.mlx.files = PRE_first_tail_x15_r0_body.cx0_83.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch83 : PRE_first_tail_x15_r0_body.cx1_83.mlx.arch = PRE_first_tail_x15_r0_body.cx0_83.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes83 : PRE_first_tail_x15_r0_body.cx1_83.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_83.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired83 : PRE_first_tail_x15_r0_body.cx1_83.mlx.wired = PRE_first_tail_x15_r0_body.cx0_83.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost83 : PRE_first_tail_x15_r0_body.cx1_83.host = PRE_first_tail_x15_r0_body.cx0_83.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd83`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn083 : PRE_first_tail_x15_r0_body.kd83.n0 = 2739878
kernel_rfl PRE_first_tail_x15_r0_body.ckn183 : PRE_first_tail_x15_r0_body.kd83.n1 = 2739888
kernel_rfl PRE_first_tail_x15_r0_body.ckheap83 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd83.heap).all (fun x => Nat.ble 2739877 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl83 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd83.heap.get (2739877 + j) = nth? PRE_first_tail_x15_r0_body.pl83 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja83 : Nat.ble 2739877 2739877 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn83 : Nat.ble 3601 3601 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD83 : Nat.ble 2739877 PRE_first_tail_x15_r0_body.kd83.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn83 : Nat.ble 19833 PRE_first_tail_x15_r0_body.kd83.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn83 : Nat.ble 16918 PRE_first_tail_x15_r0_body.kd83.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb83 : Nat.ble 19833 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap83 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd83.heap).all (Nat.ble (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd83 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd83.hnd).all (Nat.ble (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode83 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd83.node).all (Nat.ble (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix83 : Conv.FixOld (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa83 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja83) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn83) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD83) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn83) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn83) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb83) PRE_first_tail_x15_r0_body.fheap83 PRE_first_tail_x15_r0_body.fhnd83 PRE_first_tail_x15_r0_body.fnode83
kernel_rfl PRE_first_tail_x15_r0_body.fcxn83 : (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn83 : (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle083 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_83.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_83.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk83 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd83.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A83 : PRE_first_tail_x15_r0_body.cx1_83.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS83.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_83.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O83 : PRE_first_tail_x15_r0_body.cx1_83.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS83.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_83.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N83 : PRE_first_tail_x15_r0_body.cx1_83.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS83.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_83.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I83 : PRE_first_tail_x15_r0_body.cx1_83.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS83.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_83.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd83 : (PRE_first_tail_x15_r0_body.clo83 ++ PRE_first_tail_x15_r0_body.cln83 ++ PRE_first_tail_x15_r0_body.cli83 ++ PRE_first_tail_x15_r0_body.cwS83 ++ PRE_first_tail_x15_r0_body.cnS83 ++ PRE_first_tail_x15_r0_body.ciS83).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW83 : PRE_first_tail_x15_r0_body.cwS83.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo83.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI83 : PRE_first_tail_x15_r0_body.ciS83.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli83.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN83 : PRE_first_tail_x15_r0_body.cnS83.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF83 : PRE_first_tail_x15_r0_body.cln83.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh83 : PRE_first_tail_x15_r0_body.clo83.all (handleOK PRE_first_tail_x15_r0_body.kappa83 PRE_first_tail_x15_r0_body.P83.lo PRE_first_tail_x15_r0_body.cx0_83.mlx PRE_first_tail_x15_r0_body.cx1_83.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo83 : PRE_first_tail_x15_r0_body.clo83.map (fun h => PRE_first_tail_x15_r0_body.cx1_83.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa83.handle h)) = PRE_first_tail_x15_r0_body.clo83.map (fun h => (PRE_first_tail_x15_r0_body.cx0_83.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa83.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok83 : PRE_first_tail_x15_r0_body.clo83.all (objOK PRE_first_tail_x15_r0_body.kappa83 PRE_first_tail_x15_r0_body.P83.NL PRE_first_tail_x15_r0_body.cx0_83.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd83 : PRE_first_tail_x15_r0_body.cln83.all (nodeOKF PRE_first_tail_x15_r0_body.kappa83 PRE_first_tail_x15_r0_body.P83 PRE_first_tail_x15_r0_body.cx0_83.mlx PRE_first_tail_x15_r0_body.cx1_83.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp83 : ((PRE_first_tail_x15_r0_body.cln83.filter (fullB PRE_first_tail_x15_r0_body.P83))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_83.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa83.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln83.filter (fullB PRE_first_tail_x15_r0_body.P83))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_83.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa83.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI83 : incrB PRE_first_tail_x15_r0_body.kd83.nodeF (List.range' 16918 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK83 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd83.node).all (fun k => Nat.ble 16918 k && Nat.blt k 16918) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL83 : (PRE_first_tail_x15_r0_body.cln83.filter (Nat.ble PRE_first_tail_x15_r0_body.P83.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd83.nodeF i) && (Nat.blt i 16918 || Nat.ble PRE_first_tail_x15_r0_body.kd83.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord83 : (PRE_first_tail_x15_r0_body.cln83.filter (Nat.ble PRE_first_tail_x15_r0_body.P83.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd83.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd83.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd83.nodeF j) (PRE_first_tail_x15_r0_body.kd83.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow83 PRE_first_tail_x15_r0_body.cnn183 PRE_first_tail_x15_r0_body.fnordI83 PRE_first_tail_x15_r0_body.fnordK83 PRE_first_tail_x15_r0_body.fnordL83
kernel_rfl PRE_first_tail_x15_r0_body.fi83 : PRE_first_tail_x15_r0_body.cli83.all (pnB PRE_first_tail_x15_r0_body.cx0_83.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii83 : PRE_first_tail_x15_r0_body.cli83.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_83.mlx.items.get (PRE_first_tail_x15_r0_body.kappa83.node k) = (PRE_first_tail_x15_r0_body.cx0_83.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa83.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot83 (clean : Conv.NClean (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P83.NL) (cl : SSt (· < 3601) PRE_first_tail_x15_r0_body.cx0_83.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P83 3601 PRE_first_tail_x15_r0_body.kappa83 PRE_first_tail_x15_r0_body.kd83 PRE_first_tail_x15_r0_body.khinv83 PRE_first_tail_x15_r0_body.kninv83 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx PRE_first_tail_x15_r0_body.cx0_83.mlx PRE_first_tail_x15_r0_body.cx1_83.mlx (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo83 PRE_first_tail_x15_r0_body.cln83 PRE_first_tail_x15_r0_body.cli83 PRE_first_tail_x15_r0_body.cwS83 PRE_first_tail_x15_r0_body.cnS83 PRE_first_tail_x15_r0_body.ciS83 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh083, PRE_first_tail_x15_r0_body.cnh183, PRE_first_tail_x15_r0_body.cnn083, PRE_first_tail_x15_r0_body.cnn183, PRE_first_tail_x15_r0_body.cplo83, PRE_first_tail_x15_r0_body.ccnt83, PRE_first_tail_x15_r0_body.cnband83, PRE_first_tail_x15_r0_body.chbelow83, PRE_first_tail_x15_r0_body.chren83, PRE_first_tail_x15_r0_body.cband83, PRE_first_tail_x15_r0_body.cnh1pos83, PRE_first_tail_x15_r0_body.cnren83, PRE_first_tail_x15_r0_body.cnlow83, PRE_first_tail_x15_r0_body.cabs0a83, PRE_first_tail_x15_r0_body.cabs0b83, PRE_first_tail_x15_r0_body.ctok183, PRE_first_tail_x15_r0_body.cpend83, PRE_first_tail_x15_r0_body.cerrh83, PRE_first_tail_x15_r0_body.cfiles83, PRE_first_tail_x15_r0_body.carch83, PRE_first_tail_x15_r0_body.csizes83, PRE_first_tail_x15_r0_body.cwired83, PRE_first_tail_x15_r0_body.cfix83, clean, PRE_first_tail_x15_r0_body.fcxn83, PRE_first_tail_x15_r0_body.fcnn83, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle083, PRE_first_tail_x15_r0_body.fnk83, PRE_first_tail_x15_r0_body.ckA83, PRE_first_tail_x15_r0_body.cobjsK83, PRE_first_tail_x15_r0_body.cnodesK83, PRE_first_tail_x15_r0_body.citemsK83, PRE_first_tail_x15_r0_body.f1A83, PRE_first_tail_x15_r0_body.f1O83, PRE_first_tail_x15_r0_body.f1N83, PRE_first_tail_x15_r0_body.f1I83, PRE_first_tail_x15_r0_body.fbd83, PRE_first_tail_x15_r0_body.fincW83, PRE_first_tail_x15_r0_body.fincI83, PRE_first_tail_x15_r0_body.fincN83, PRE_first_tail_x15_r0_body.flnF83, PRE_first_tail_x15_r0_body.fh83, PRE_first_tail_x15_r0_body.fo83, PRE_first_tail_x15_r0_body.fok83, PRE_first_tail_x15_r0_body.fnd83, PRE_first_tail_x15_r0_body.fp83, PRE_first_tail_x15_r0_body.fnord83, PRE_first_tail_x15_r0_body.fi83, PRE_first_tail_x15_r0_body.fii83⟩
theorem PRE_first_tail_x15_r0_body.cnshift83 (clean : Conv.NClean (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P83.NL) (cl : SSt (· < 3601) PRE_first_tail_x15_r0_body.cx0_83.mlx) : NShift PRE_first_tail_x15_r0_body.P83 3601 PRE_first_tail_x15_r0_body.kappa83 PRE_first_tail_x15_r0_body.cx0_83 PRE_first_tail_x15_r0_body.cx1_83 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot83 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost83 (compact_a_eq PRE_first_tail_x15_r0_body.ckn083 PRE_first_tail_x15_r0_body.ckn183 PRE_first_tail_x15_r0_body.ckheap83 PRE_first_tail_x15_r0_body.ckpl83)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_83 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s733.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_83 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s733.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_83 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s733.ffi) = some PRE_first_tail_x15_r0_body.fxC_83
kernel_rfl PRE_first_tail_x15_r0_body.okrC_83 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s733.ffi) = some PRE_first_tail_x15_r0_body.krC_83
noncomputable def PRE_first_tail_x15_r0_body.fx0_83 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s735.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_83 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s735.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_83 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s735.ffi) = some PRE_first_tail_x15_r0_body.fx0_83
kernel_rfl PRE_first_tail_x15_r0_body.okr0_83 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s735.ffi) = some PRE_first_tail_x15_r0_body.kr0_83
noncomputable def PRE_first_tail_x15_r0_body.fx1_83 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s734.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_83 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s734.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_83 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s734.ffi) = some PRE_first_tail_x15_r0_body.fx1_83
kernel_rfl PRE_first_tail_x15_r0_body.okr1_83 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s734.ffi) = some PRE_first_tail_x15_r0_body.kr1_83
kernel_rfl PRE_first_tail_x15_r0_body.ff083 : PRE_first_tail_x15_r0_body.fx0_83 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_83 (PRE_first_tail_x15_r0_body.clo83.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_83.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff183 : PRE_first_tail_x15_r0_body.fx1_83 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_83 (PRE_first_tail_x15_r0_body.cwS83.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_83.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck83 : freedLB PRE_first_tail_x15_r0_body.kappa83 PRE_first_tail_x15_r0_body.cx0_83.mlx PRE_first_tail_x15_r0_body.fx0_83 PRE_first_tail_x15_r0_body.fx1_83 PRE_first_tail_x15_r0_body.clo83 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf083 : PRE_first_tail_x15_r0_body.kr0_83.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_83.flags (PRE_first_tail_x15_r0_body.clo83.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_83.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt083 : PRE_first_tail_x15_r0_body.kr0_83.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_83.targs (PRE_first_tail_x15_r0_body.clo83.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_83.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf183 : PRE_first_tail_x15_r0_body.kr1_83.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_83.flags (PRE_first_tail_x15_r0_body.cwS83.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_83.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt183 : PRE_first_tail_x15_r0_body.kr1_83.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_83.targs (PRE_first_tail_x15_r0_body.cwS83.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_83.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck83 : krecLB PRE_first_tail_x15_r0_body.kappa83 3601 PRE_first_tail_x15_r0_body.cx0_83.mlx PRE_first_tail_x15_r0_body.kr0_83 PRE_first_tail_x15_r0_body.kr1_83 PRE_first_tail_x15_r0_body.clo83 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn83 : Nat.ble 3601 3601 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge83 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s734.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s735.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR83 : pendRegB PRE_first_tail_x15_r0_body.kappa83 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe83 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s734.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift83 (clean : Conv.NClean (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P83.NL) (cl : SSt (· < 3601) PRE_first_tail_x15_r0_body.cx0_83.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_83.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_83.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_83.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_83.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P83 3601 PRE_first_tail_x15_r0_body.kappa83 PRE_first_tail_x15_r0_body.s735.ffi PRE_first_tail_x15_r0_body.s734.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift83 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue83, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp83 t ht),
    PRE_first_tail_x15_r0_body.cbridge83,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s735.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s734.ffi) (PRE_first_tail_x15_r0_body.cfoot83 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_83 PRE_first_tail_x15_r0_body.ofx1_83 hobjC PRE_first_tail_x15_r0_body.ff083 PRE_first_tail_x15_r0_body.ff183 PRE_first_tail_x15_r0_body.ffck83,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s735.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s734.ffi) (PRE_first_tail_x15_r0_body.cfoot83 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_83 PRE_first_tail_x15_r0_body.okr1_83 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn83) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf083 PRE_first_tail_x15_r0_body.fkt083 PRE_first_tail_x15_r0_body.fkf183 PRE_first_tail_x15_r0_body.fkt183 PRE_first_tail_x15_r0_body.fkck83,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh083 PRE_first_tail_x15_r0_body.cnh183 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe83) PRE_first_tail_x15_r0_body.cpendR83⟩

end Host.Load.Run.Tpl

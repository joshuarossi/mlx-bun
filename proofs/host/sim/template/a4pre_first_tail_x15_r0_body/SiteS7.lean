import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl7
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 7 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc7 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P7 : LoadP := PRE_first_tail_x15_r0_body.Pc7.raise 15444
kernel_rfl PRE_first_tail_x15_r0_body.craise7 : Nat.ble PRE_first_tail_x15_r0_body.Pc7.N0 15444 = true
theorem PRE_first_tail_x15_r0_body.raised7 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc7 PRE_first_tail_x15_r0_body.P7 :=
  .inr ⟨15444, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise7, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_7 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s77.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_7 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s76.ffi)
def PRE_first_tail_x15_r0_body.khinv7 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv7 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS7 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS7 : List Nat := List.range' 15444 0
def PRE_first_tail_x15_r0_body.ciS7 : List Nat := [] ++ List.range' 15444 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh07 : PRE_first_tail_x15_r0_body.kd7.nh0 = PRE_first_tail_x15_r0_body.cx0_7.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh17 : PRE_first_tail_x15_r0_body.kd7.nh1 = PRE_first_tail_x15_r0_body.cx1_7.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn07 : PRE_first_tail_x15_r0_body.kd7.nn0 = PRE_first_tail_x15_r0_body.cx0_7.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn17 : PRE_first_tail_x15_r0_body.kd7.nn1 = PRE_first_tail_x15_r0_body.cx1_7.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo7 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P7.lo && Nat.ble PRE_first_tail_x15_r0_body.P7.lo PRE_first_tail_x15_r0_body.cx0_7.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P7.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P7.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt7 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_7.mlx.next PRE_first_tail_x15_r0_body.cx1_7.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_7.mlx.nnext PRE_first_tail_x15_r0_body.cx1_7.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband7 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P7.NL && Nat.ble PRE_first_tail_x15_r0_body.P7.NL PRE_first_tail_x15_r0_body.P7.N0 && Nat.ble PRE_first_tail_x15_r0_body.P7.N0 PRE_first_tail_x15_r0_body.cx0_7.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow7 : PRE_first_tail_x15_r0_body.kd7.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren7 : checkRenG PRE_first_tail_x15_r0_body.kd7.hnd PRE_first_tail_x15_r0_body.khinv7 (phB PRE_first_tail_x15_r0_body.cx0_7.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband7 : PRE_first_tail_x15_r0_body.kd7.checkBand PRE_first_tail_x15_r0_body.P7.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos7 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd7.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren7 : checkRenG PRE_first_tail_x15_r0_body.kd7.node PRE_first_tail_x15_r0_body.kninv7 (pnB PRE_first_tail_x15_r0_body.cx0_7.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow7 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd7.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P7.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd7.nodeF j) PRE_first_tail_x15_r0_body.cx1_7.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a7 : PRE_first_tail_x15_r0_body.cx0_7.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b7 : PRE_first_tail_x15_r0_body.cx0_7.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok17 : PRE_first_tail_x15_r0_body.cx1_7.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend7 : PRE_first_tail_x15_r0_body.cx1_7.mlx.pending = PRE_first_tail_x15_r0_body.cx0_7.mlx.pending.map PRE_first_tail_x15_r0_body.kappa7.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh7 : PRE_first_tail_x15_r0_body.cx1_7.mlx.errh = PRE_first_tail_x15_r0_body.cx0_7.mlx.errh.map PRE_first_tail_x15_r0_body.kappa7.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles7 : PRE_first_tail_x15_r0_body.cx1_7.mlx.files = PRE_first_tail_x15_r0_body.cx0_7.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch7 : PRE_first_tail_x15_r0_body.cx1_7.mlx.arch = PRE_first_tail_x15_r0_body.cx0_7.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes7 : PRE_first_tail_x15_r0_body.cx1_7.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_7.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired7 : PRE_first_tail_x15_r0_body.cx1_7.mlx.wired = PRE_first_tail_x15_r0_body.cx0_7.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost7 : PRE_first_tail_x15_r0_body.cx1_7.host = PRE_first_tail_x15_r0_body.cx0_7.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd7`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn07 : PRE_first_tail_x15_r0_body.kd7.n0 = 2680469
kernel_rfl PRE_first_tail_x15_r0_body.ckn17 : PRE_first_tail_x15_r0_body.kd7.n1 = 2680471
kernel_rfl PRE_first_tail_x15_r0_body.ckheap7 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd7.heap).all (fun x => Nat.ble 2680469 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl7 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd7.heap.get (2680469 + j) = nth? PRE_first_tail_x15_r0_body.pl7 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja7 : Nat.ble 2680469 2680469 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn7 : Nat.ble 380 380 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD7 : Nat.ble 2680469 PRE_first_tail_x15_r0_body.kd7.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn7 : Nat.ble 18346 PRE_first_tail_x15_r0_body.kd7.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn7 : Nat.ble 15444 PRE_first_tail_x15_r0_body.kd7.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb7 : Nat.ble 18346 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap7 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd7.heap).all (Nat.ble (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd7 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd7.hnd).all (Nat.ble (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode7 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd7.node).all (Nat.ble (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix7 : Conv.FixOld (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa7 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja7) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn7) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD7) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn7) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn7) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb7) PRE_first_tail_x15_r0_body.fheap7 PRE_first_tail_x15_r0_body.fhnd7 PRE_first_tail_x15_r0_body.fnode7
kernel_rfl PRE_first_tail_x15_r0_body.fcxn7 : (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn7 : (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle07 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_7.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_7.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk7 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd7.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A7 : PRE_first_tail_x15_r0_body.cx1_7.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS7.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_7.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O7 : PRE_first_tail_x15_r0_body.cx1_7.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS7.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_7.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N7 : PRE_first_tail_x15_r0_body.cx1_7.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS7.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_7.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I7 : PRE_first_tail_x15_r0_body.cx1_7.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS7.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_7.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd7 : (PRE_first_tail_x15_r0_body.clo7 ++ PRE_first_tail_x15_r0_body.cln7 ++ PRE_first_tail_x15_r0_body.cli7 ++ PRE_first_tail_x15_r0_body.cwS7 ++ PRE_first_tail_x15_r0_body.cnS7 ++ PRE_first_tail_x15_r0_body.ciS7).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW7 : PRE_first_tail_x15_r0_body.cwS7.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo7.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI7 : PRE_first_tail_x15_r0_body.ciS7.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli7.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN7 : PRE_first_tail_x15_r0_body.cnS7.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF7 : PRE_first_tail_x15_r0_body.cln7.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh7 : PRE_first_tail_x15_r0_body.clo7.all (handleOK PRE_first_tail_x15_r0_body.kappa7 PRE_first_tail_x15_r0_body.P7.lo PRE_first_tail_x15_r0_body.cx0_7.mlx PRE_first_tail_x15_r0_body.cx1_7.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo7 : PRE_first_tail_x15_r0_body.clo7.map (fun h => PRE_first_tail_x15_r0_body.cx1_7.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa7.handle h)) = PRE_first_tail_x15_r0_body.clo7.map (fun h => (PRE_first_tail_x15_r0_body.cx0_7.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa7.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok7 : PRE_first_tail_x15_r0_body.clo7.all (objOK PRE_first_tail_x15_r0_body.kappa7 PRE_first_tail_x15_r0_body.P7.NL PRE_first_tail_x15_r0_body.cx0_7.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd7 : PRE_first_tail_x15_r0_body.cln7.all (nodeOKF PRE_first_tail_x15_r0_body.kappa7 PRE_first_tail_x15_r0_body.P7 PRE_first_tail_x15_r0_body.cx0_7.mlx PRE_first_tail_x15_r0_body.cx1_7.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp7 : ((PRE_first_tail_x15_r0_body.cln7.filter (fullB PRE_first_tail_x15_r0_body.P7))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_7.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa7.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln7.filter (fullB PRE_first_tail_x15_r0_body.P7))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_7.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa7.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI7 : incrB PRE_first_tail_x15_r0_body.kd7.nodeF (List.range' 15444 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK7 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd7.node).all (fun k => Nat.ble 15444 k && Nat.blt k 15444) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL7 : (PRE_first_tail_x15_r0_body.cln7.filter (Nat.ble PRE_first_tail_x15_r0_body.P7.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd7.nodeF i) && (Nat.blt i 15444 || Nat.ble PRE_first_tail_x15_r0_body.kd7.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord7 : (PRE_first_tail_x15_r0_body.cln7.filter (Nat.ble PRE_first_tail_x15_r0_body.P7.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd7.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd7.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd7.nodeF j) (PRE_first_tail_x15_r0_body.kd7.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow7 PRE_first_tail_x15_r0_body.cnn17 PRE_first_tail_x15_r0_body.fnordI7 PRE_first_tail_x15_r0_body.fnordK7 PRE_first_tail_x15_r0_body.fnordL7
kernel_rfl PRE_first_tail_x15_r0_body.fi7 : PRE_first_tail_x15_r0_body.cli7.all (pnB PRE_first_tail_x15_r0_body.cx0_7.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii7 : PRE_first_tail_x15_r0_body.cli7.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_7.mlx.items.get (PRE_first_tail_x15_r0_body.kappa7.node k) = (PRE_first_tail_x15_r0_body.cx0_7.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa7.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot7 (clean : Conv.NClean (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P7.NL) (cl : SSt (· < 380) PRE_first_tail_x15_r0_body.cx0_7.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P7 380 PRE_first_tail_x15_r0_body.kappa7 PRE_first_tail_x15_r0_body.kd7 PRE_first_tail_x15_r0_body.khinv7 PRE_first_tail_x15_r0_body.kninv7 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx PRE_first_tail_x15_r0_body.cx0_7.mlx PRE_first_tail_x15_r0_body.cx1_7.mlx (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo7 PRE_first_tail_x15_r0_body.cln7 PRE_first_tail_x15_r0_body.cli7 PRE_first_tail_x15_r0_body.cwS7 PRE_first_tail_x15_r0_body.cnS7 PRE_first_tail_x15_r0_body.ciS7 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh07, PRE_first_tail_x15_r0_body.cnh17, PRE_first_tail_x15_r0_body.cnn07, PRE_first_tail_x15_r0_body.cnn17, PRE_first_tail_x15_r0_body.cplo7, PRE_first_tail_x15_r0_body.ccnt7, PRE_first_tail_x15_r0_body.cnband7, PRE_first_tail_x15_r0_body.chbelow7, PRE_first_tail_x15_r0_body.chren7, PRE_first_tail_x15_r0_body.cband7, PRE_first_tail_x15_r0_body.cnh1pos7, PRE_first_tail_x15_r0_body.cnren7, PRE_first_tail_x15_r0_body.cnlow7, PRE_first_tail_x15_r0_body.cabs0a7, PRE_first_tail_x15_r0_body.cabs0b7, PRE_first_tail_x15_r0_body.ctok17, PRE_first_tail_x15_r0_body.cpend7, PRE_first_tail_x15_r0_body.cerrh7, PRE_first_tail_x15_r0_body.cfiles7, PRE_first_tail_x15_r0_body.carch7, PRE_first_tail_x15_r0_body.csizes7, PRE_first_tail_x15_r0_body.cwired7, PRE_first_tail_x15_r0_body.cfix7, clean, PRE_first_tail_x15_r0_body.fcxn7, PRE_first_tail_x15_r0_body.fcnn7, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle07, PRE_first_tail_x15_r0_body.fnk7, PRE_first_tail_x15_r0_body.ckA7, PRE_first_tail_x15_r0_body.cobjsK7, PRE_first_tail_x15_r0_body.cnodesK7, PRE_first_tail_x15_r0_body.citemsK7, PRE_first_tail_x15_r0_body.f1A7, PRE_first_tail_x15_r0_body.f1O7, PRE_first_tail_x15_r0_body.f1N7, PRE_first_tail_x15_r0_body.f1I7, PRE_first_tail_x15_r0_body.fbd7, PRE_first_tail_x15_r0_body.fincW7, PRE_first_tail_x15_r0_body.fincI7, PRE_first_tail_x15_r0_body.fincN7, PRE_first_tail_x15_r0_body.flnF7, PRE_first_tail_x15_r0_body.fh7, PRE_first_tail_x15_r0_body.fo7, PRE_first_tail_x15_r0_body.fok7, PRE_first_tail_x15_r0_body.fnd7, PRE_first_tail_x15_r0_body.fp7, PRE_first_tail_x15_r0_body.fnord7, PRE_first_tail_x15_r0_body.fi7, PRE_first_tail_x15_r0_body.fii7⟩
theorem PRE_first_tail_x15_r0_body.cnshift7 (clean : Conv.NClean (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P7.NL) (cl : SSt (· < 380) PRE_first_tail_x15_r0_body.cx0_7.mlx) : NShift PRE_first_tail_x15_r0_body.P7 380 PRE_first_tail_x15_r0_body.kappa7 PRE_first_tail_x15_r0_body.cx0_7 PRE_first_tail_x15_r0_body.cx1_7 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot7 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost7 (compact_a_eq PRE_first_tail_x15_r0_body.ckn07 PRE_first_tail_x15_r0_body.ckn17 PRE_first_tail_x15_r0_body.ckheap7 PRE_first_tail_x15_r0_body.ckpl7)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_7 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s75.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_7 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s75.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_7 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s75.ffi) = some PRE_first_tail_x15_r0_body.fxC_7
kernel_rfl PRE_first_tail_x15_r0_body.okrC_7 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s75.ffi) = some PRE_first_tail_x15_r0_body.krC_7
noncomputable def PRE_first_tail_x15_r0_body.fx0_7 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s77.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_7 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s77.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_7 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s77.ffi) = some PRE_first_tail_x15_r0_body.fx0_7
kernel_rfl PRE_first_tail_x15_r0_body.okr0_7 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s77.ffi) = some PRE_first_tail_x15_r0_body.kr0_7
noncomputable def PRE_first_tail_x15_r0_body.fx1_7 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s76.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_7 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s76.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_7 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s76.ffi) = some PRE_first_tail_x15_r0_body.fx1_7
kernel_rfl PRE_first_tail_x15_r0_body.okr1_7 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s76.ffi) = some PRE_first_tail_x15_r0_body.kr1_7
kernel_rfl PRE_first_tail_x15_r0_body.ff07 : PRE_first_tail_x15_r0_body.fx0_7 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_7 (PRE_first_tail_x15_r0_body.clo7.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_7.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff17 : PRE_first_tail_x15_r0_body.fx1_7 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_7 (PRE_first_tail_x15_r0_body.cwS7.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_7.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck7 : freedLB PRE_first_tail_x15_r0_body.kappa7 PRE_first_tail_x15_r0_body.cx0_7.mlx PRE_first_tail_x15_r0_body.fx0_7 PRE_first_tail_x15_r0_body.fx1_7 PRE_first_tail_x15_r0_body.clo7 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf07 : PRE_first_tail_x15_r0_body.kr0_7.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_7.flags (PRE_first_tail_x15_r0_body.clo7.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_7.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt07 : PRE_first_tail_x15_r0_body.kr0_7.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_7.targs (PRE_first_tail_x15_r0_body.clo7.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_7.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf17 : PRE_first_tail_x15_r0_body.kr1_7.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_7.flags (PRE_first_tail_x15_r0_body.cwS7.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_7.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt17 : PRE_first_tail_x15_r0_body.kr1_7.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_7.targs (PRE_first_tail_x15_r0_body.cwS7.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_7.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck7 : krecLB PRE_first_tail_x15_r0_body.kappa7 380 PRE_first_tail_x15_r0_body.cx0_7.mlx PRE_first_tail_x15_r0_body.kr0_7 PRE_first_tail_x15_r0_body.kr1_7 PRE_first_tail_x15_r0_body.clo7 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn7 : Nat.ble 380 380 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge7 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s76.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s77.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR7 : pendRegB PRE_first_tail_x15_r0_body.kappa7 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s77.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe7 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s77.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s76.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift7 (clean : Conv.NClean (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P7.NL) (cl : SSt (· < 380) PRE_first_tail_x15_r0_body.cx0_7.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_7.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_7.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_7.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_7.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P7 380 PRE_first_tail_x15_r0_body.kappa7 PRE_first_tail_x15_r0_body.s77.ffi PRE_first_tail_x15_r0_body.s76.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift7 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue7, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp7 t ht),
    PRE_first_tail_x15_r0_body.cbridge7,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s77.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s76.ffi) (PRE_first_tail_x15_r0_body.cfoot7 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_7 PRE_first_tail_x15_r0_body.ofx1_7 hobjC PRE_first_tail_x15_r0_body.ff07 PRE_first_tail_x15_r0_body.ff17 PRE_first_tail_x15_r0_body.ffck7,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s77.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s76.ffi) (PRE_first_tail_x15_r0_body.cfoot7 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_7 PRE_first_tail_x15_r0_body.okr1_7 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn7) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf07 PRE_first_tail_x15_r0_body.fkt07 PRE_first_tail_x15_r0_body.fkf17 PRE_first_tail_x15_r0_body.fkt17 PRE_first_tail_x15_r0_body.fkck7,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh07 PRE_first_tail_x15_r0_body.cnh17 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe7) PRE_first_tail_x15_r0_body.cpendR7⟩

end Host.Load.Run.Tpl

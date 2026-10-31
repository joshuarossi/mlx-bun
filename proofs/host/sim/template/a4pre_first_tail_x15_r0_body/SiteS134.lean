import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl134
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 134 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc134 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P134 : LoadP := PRE_first_tail_x15_r0_body.Pc134.raise 17929
kernel_rfl PRE_first_tail_x15_r0_body.craise134 : Nat.ble PRE_first_tail_x15_r0_body.Pc134.N0 17929 = true
theorem PRE_first_tail_x15_r0_body.raised134 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc134 PRE_first_tail_x15_r0_body.P134 :=
  .inr ⟨17929, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise134, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_134 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_134 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1294.ffi)
def PRE_first_tail_x15_r0_body.khinv134 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv134 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS134 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS134 : List Nat := List.range' 17929 0
def PRE_first_tail_x15_r0_body.ciS134 : List Nat := [] ++ List.range' 17929 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0134 : PRE_first_tail_x15_r0_body.kd134.nh0 = PRE_first_tail_x15_r0_body.cx0_134.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1134 : PRE_first_tail_x15_r0_body.kd134.nh1 = PRE_first_tail_x15_r0_body.cx1_134.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0134 : PRE_first_tail_x15_r0_body.kd134.nn0 = PRE_first_tail_x15_r0_body.cx0_134.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1134 : PRE_first_tail_x15_r0_body.kd134.nn1 = PRE_first_tail_x15_r0_body.cx1_134.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo134 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P134.lo && Nat.ble PRE_first_tail_x15_r0_body.P134.lo PRE_first_tail_x15_r0_body.cx0_134.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P134.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P134.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt134 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_134.mlx.next PRE_first_tail_x15_r0_body.cx1_134.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_134.mlx.nnext PRE_first_tail_x15_r0_body.cx1_134.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband134 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P134.NL && Nat.ble PRE_first_tail_x15_r0_body.P134.NL PRE_first_tail_x15_r0_body.P134.N0 && Nat.ble PRE_first_tail_x15_r0_body.P134.N0 PRE_first_tail_x15_r0_body.cx0_134.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow134 : PRE_first_tail_x15_r0_body.kd134.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren134 : checkRenG PRE_first_tail_x15_r0_body.kd134.hnd PRE_first_tail_x15_r0_body.khinv134 (phB PRE_first_tail_x15_r0_body.cx0_134.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband134 : PRE_first_tail_x15_r0_body.kd134.checkBand PRE_first_tail_x15_r0_body.P134.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos134 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd134.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren134 : checkRenG PRE_first_tail_x15_r0_body.kd134.node PRE_first_tail_x15_r0_body.kninv134 (pnB PRE_first_tail_x15_r0_body.cx0_134.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow134 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd134.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P134.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd134.nodeF j) PRE_first_tail_x15_r0_body.cx1_134.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a134 : PRE_first_tail_x15_r0_body.cx0_134.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b134 : PRE_first_tail_x15_r0_body.cx0_134.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1134 : PRE_first_tail_x15_r0_body.cx1_134.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend134 : PRE_first_tail_x15_r0_body.cx1_134.mlx.pending = PRE_first_tail_x15_r0_body.cx0_134.mlx.pending.map PRE_first_tail_x15_r0_body.kappa134.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh134 : PRE_first_tail_x15_r0_body.cx1_134.mlx.errh = PRE_first_tail_x15_r0_body.cx0_134.mlx.errh.map PRE_first_tail_x15_r0_body.kappa134.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles134 : PRE_first_tail_x15_r0_body.cx1_134.mlx.files = PRE_first_tail_x15_r0_body.cx0_134.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch134 : PRE_first_tail_x15_r0_body.cx1_134.mlx.arch = PRE_first_tail_x15_r0_body.cx0_134.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes134 : PRE_first_tail_x15_r0_body.cx1_134.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_134.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired134 : PRE_first_tail_x15_r0_body.cx1_134.mlx.wired = PRE_first_tail_x15_r0_body.cx0_134.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost134 : PRE_first_tail_x15_r0_body.cx1_134.host = PRE_first_tail_x15_r0_body.cx0_134.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd134`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0134 : PRE_first_tail_x15_r0_body.kd134.n0 = 2779820
kernel_rfl PRE_first_tail_x15_r0_body.ckn1134 : PRE_first_tail_x15_r0_body.kd134.n1 = 2779830
kernel_rfl PRE_first_tail_x15_r0_body.ckheap134 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd134.heap).all (fun x => Nat.ble 2779819 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl134 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd134.heap.get (2779819 + j) = nth? PRE_first_tail_x15_r0_body.pl134 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja134 : Nat.ble 2779819 2779819 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn134 : Nat.ble 5782 5782 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD134 : Nat.ble 2779819 PRE_first_tail_x15_r0_body.kd134.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn134 : Nat.ble 20835 PRE_first_tail_x15_r0_body.kd134.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn134 : Nat.ble 17929 PRE_first_tail_x15_r0_body.kd134.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb134 : Nat.ble 20835 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap134 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd134.heap).all (Nat.ble (⟨20835, 17929, 2779819, 5782⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd134 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd134.hnd).all (Nat.ble (⟨20835, 17929, 2779819, 5782⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode134 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd134.node).all (Nat.ble (⟨20835, 17929, 2779819, 5782⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix134 : Conv.FixOld (⟨20835, 17929, 2779819, 5782⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa134 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja134) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn134) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD134) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn134) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn134) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb134) PRE_first_tail_x15_r0_body.fheap134 PRE_first_tail_x15_r0_body.fhnd134 PRE_first_tail_x15_r0_body.fnode134
kernel_rfl PRE_first_tail_x15_r0_body.fcxn134 : (⟨20835, 17929, 2779819, 5782⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn134 : (⟨20835, 17929, 2779819, 5782⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0134 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_134.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_134.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk134 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd134.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A134 : PRE_first_tail_x15_r0_body.cx1_134.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS134.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_134.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O134 : PRE_first_tail_x15_r0_body.cx1_134.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS134.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_134.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N134 : PRE_first_tail_x15_r0_body.cx1_134.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS134.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_134.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I134 : PRE_first_tail_x15_r0_body.cx1_134.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS134.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_134.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd134 : (PRE_first_tail_x15_r0_body.clo134 ++ PRE_first_tail_x15_r0_body.cln134 ++ PRE_first_tail_x15_r0_body.cli134 ++ PRE_first_tail_x15_r0_body.cwS134 ++ PRE_first_tail_x15_r0_body.cnS134 ++ PRE_first_tail_x15_r0_body.ciS134).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW134 : PRE_first_tail_x15_r0_body.cwS134.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo134.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI134 : PRE_first_tail_x15_r0_body.ciS134.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli134.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN134 : PRE_first_tail_x15_r0_body.cnS134.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF134 : PRE_first_tail_x15_r0_body.cln134.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh134 : PRE_first_tail_x15_r0_body.clo134.all (handleOK PRE_first_tail_x15_r0_body.kappa134 PRE_first_tail_x15_r0_body.P134.lo PRE_first_tail_x15_r0_body.cx0_134.mlx PRE_first_tail_x15_r0_body.cx1_134.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo134 : PRE_first_tail_x15_r0_body.clo134.map (fun h => PRE_first_tail_x15_r0_body.cx1_134.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa134.handle h)) = PRE_first_tail_x15_r0_body.clo134.map (fun h => (PRE_first_tail_x15_r0_body.cx0_134.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa134.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok134 : PRE_first_tail_x15_r0_body.clo134.all (objOK PRE_first_tail_x15_r0_body.kappa134 PRE_first_tail_x15_r0_body.P134.NL PRE_first_tail_x15_r0_body.cx0_134.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd134 : PRE_first_tail_x15_r0_body.cln134.all (nodeOKF PRE_first_tail_x15_r0_body.kappa134 PRE_first_tail_x15_r0_body.P134 PRE_first_tail_x15_r0_body.cx0_134.mlx PRE_first_tail_x15_r0_body.cx1_134.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp134 : ((PRE_first_tail_x15_r0_body.cln134.filter (fullB PRE_first_tail_x15_r0_body.P134))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_134.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa134.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln134.filter (fullB PRE_first_tail_x15_r0_body.P134))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_134.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa134.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI134 : incrB PRE_first_tail_x15_r0_body.kd134.nodeF (List.range' 17929 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK134 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd134.node).all (fun k => Nat.ble 17929 k && Nat.blt k 17929) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL134 : (PRE_first_tail_x15_r0_body.cln134.filter (Nat.ble PRE_first_tail_x15_r0_body.P134.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd134.nodeF i) && (Nat.blt i 17929 || Nat.ble PRE_first_tail_x15_r0_body.kd134.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord134 : (PRE_first_tail_x15_r0_body.cln134.filter (Nat.ble PRE_first_tail_x15_r0_body.P134.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd134.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd134.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd134.nodeF j) (PRE_first_tail_x15_r0_body.kd134.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow134 PRE_first_tail_x15_r0_body.cnn1134 PRE_first_tail_x15_r0_body.fnordI134 PRE_first_tail_x15_r0_body.fnordK134 PRE_first_tail_x15_r0_body.fnordL134
kernel_rfl PRE_first_tail_x15_r0_body.fi134 : PRE_first_tail_x15_r0_body.cli134.all (pnB PRE_first_tail_x15_r0_body.cx0_134.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii134 : PRE_first_tail_x15_r0_body.cli134.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_134.mlx.items.get (PRE_first_tail_x15_r0_body.kappa134.node k) = (PRE_first_tail_x15_r0_body.cx0_134.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa134.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot134 (clean : Conv.NClean (⟨20835, 17929, 2779819, 5782⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P134.NL) (cl : SSt (· < 5782) PRE_first_tail_x15_r0_body.cx0_134.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P134 5782 PRE_first_tail_x15_r0_body.kappa134 PRE_first_tail_x15_r0_body.kd134 PRE_first_tail_x15_r0_body.khinv134 PRE_first_tail_x15_r0_body.kninv134 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx PRE_first_tail_x15_r0_body.cx0_134.mlx PRE_first_tail_x15_r0_body.cx1_134.mlx (⟨20835, 17929, 2779819, 5782⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo134 PRE_first_tail_x15_r0_body.cln134 PRE_first_tail_x15_r0_body.cli134 PRE_first_tail_x15_r0_body.cwS134 PRE_first_tail_x15_r0_body.cnS134 PRE_first_tail_x15_r0_body.ciS134 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0134, PRE_first_tail_x15_r0_body.cnh1134, PRE_first_tail_x15_r0_body.cnn0134, PRE_first_tail_x15_r0_body.cnn1134, PRE_first_tail_x15_r0_body.cplo134, PRE_first_tail_x15_r0_body.ccnt134, PRE_first_tail_x15_r0_body.cnband134, PRE_first_tail_x15_r0_body.chbelow134, PRE_first_tail_x15_r0_body.chren134, PRE_first_tail_x15_r0_body.cband134, PRE_first_tail_x15_r0_body.cnh1pos134, PRE_first_tail_x15_r0_body.cnren134, PRE_first_tail_x15_r0_body.cnlow134, PRE_first_tail_x15_r0_body.cabs0a134, PRE_first_tail_x15_r0_body.cabs0b134, PRE_first_tail_x15_r0_body.ctok1134, PRE_first_tail_x15_r0_body.cpend134, PRE_first_tail_x15_r0_body.cerrh134, PRE_first_tail_x15_r0_body.cfiles134, PRE_first_tail_x15_r0_body.carch134, PRE_first_tail_x15_r0_body.csizes134, PRE_first_tail_x15_r0_body.cwired134, PRE_first_tail_x15_r0_body.cfix134, clean, PRE_first_tail_x15_r0_body.fcxn134, PRE_first_tail_x15_r0_body.fcnn134, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0134, PRE_first_tail_x15_r0_body.fnk134, PRE_first_tail_x15_r0_body.ckA134, PRE_first_tail_x15_r0_body.cobjsK134, PRE_first_tail_x15_r0_body.cnodesK134, PRE_first_tail_x15_r0_body.citemsK134, PRE_first_tail_x15_r0_body.f1A134, PRE_first_tail_x15_r0_body.f1O134, PRE_first_tail_x15_r0_body.f1N134, PRE_first_tail_x15_r0_body.f1I134, PRE_first_tail_x15_r0_body.fbd134, PRE_first_tail_x15_r0_body.fincW134, PRE_first_tail_x15_r0_body.fincI134, PRE_first_tail_x15_r0_body.fincN134, PRE_first_tail_x15_r0_body.flnF134, PRE_first_tail_x15_r0_body.fh134, PRE_first_tail_x15_r0_body.fo134, PRE_first_tail_x15_r0_body.fok134, PRE_first_tail_x15_r0_body.fnd134, PRE_first_tail_x15_r0_body.fp134, PRE_first_tail_x15_r0_body.fnord134, PRE_first_tail_x15_r0_body.fi134, PRE_first_tail_x15_r0_body.fii134⟩
theorem PRE_first_tail_x15_r0_body.cnshift134 (clean : Conv.NClean (⟨20835, 17929, 2779819, 5782⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P134.NL) (cl : SSt (· < 5782) PRE_first_tail_x15_r0_body.cx0_134.mlx) : NShift PRE_first_tail_x15_r0_body.P134 5782 PRE_first_tail_x15_r0_body.kappa134 PRE_first_tail_x15_r0_body.cx0_134 PRE_first_tail_x15_r0_body.cx1_134 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot134 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost134 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0134 PRE_first_tail_x15_r0_body.ckn1134 PRE_first_tail_x15_r0_body.ckheap134 PRE_first_tail_x15_r0_body.ckpl134)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_134 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1293.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_134 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1293.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_134 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1293.ffi) = some PRE_first_tail_x15_r0_body.fxC_134
kernel_rfl PRE_first_tail_x15_r0_body.okrC_134 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1293.ffi) = some PRE_first_tail_x15_r0_body.krC_134
noncomputable def PRE_first_tail_x15_r0_body.fx0_134 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1295.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_134 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1295.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_134 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1295.ffi) = some PRE_first_tail_x15_r0_body.fx0_134
kernel_rfl PRE_first_tail_x15_r0_body.okr0_134 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1295.ffi) = some PRE_first_tail_x15_r0_body.kr0_134
noncomputable def PRE_first_tail_x15_r0_body.fx1_134 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1294.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_134 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1294.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_134 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1294.ffi) = some PRE_first_tail_x15_r0_body.fx1_134
kernel_rfl PRE_first_tail_x15_r0_body.okr1_134 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1294.ffi) = some PRE_first_tail_x15_r0_body.kr1_134
kernel_rfl PRE_first_tail_x15_r0_body.ff0134 : PRE_first_tail_x15_r0_body.fx0_134 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_134 (PRE_first_tail_x15_r0_body.clo134.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_134.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1134 : PRE_first_tail_x15_r0_body.fx1_134 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_134 (PRE_first_tail_x15_r0_body.cwS134.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_134.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck134 : freedLB PRE_first_tail_x15_r0_body.kappa134 PRE_first_tail_x15_r0_body.cx0_134.mlx PRE_first_tail_x15_r0_body.fx0_134 PRE_first_tail_x15_r0_body.fx1_134 PRE_first_tail_x15_r0_body.clo134 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0134 : PRE_first_tail_x15_r0_body.kr0_134.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_134.flags (PRE_first_tail_x15_r0_body.clo134.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_134.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0134 : PRE_first_tail_x15_r0_body.kr0_134.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_134.targs (PRE_first_tail_x15_r0_body.clo134.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_134.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1134 : PRE_first_tail_x15_r0_body.kr1_134.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_134.flags (PRE_first_tail_x15_r0_body.cwS134.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_134.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1134 : PRE_first_tail_x15_r0_body.kr1_134.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_134.targs (PRE_first_tail_x15_r0_body.cwS134.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_134.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck134 : krecLB PRE_first_tail_x15_r0_body.kappa134 5782 PRE_first_tail_x15_r0_body.cx0_134.mlx PRE_first_tail_x15_r0_body.kr0_134 PRE_first_tail_x15_r0_body.kr1_134 PRE_first_tail_x15_r0_body.clo134 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn134 : Nat.ble 5782 5782 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge134 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1294.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1295.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR134 : pendRegB PRE_first_tail_x15_r0_body.kappa134 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe134 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1294.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift134 (clean : Conv.NClean (⟨20835, 17929, 2779819, 5782⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P134.NL) (cl : SSt (· < 5782) PRE_first_tail_x15_r0_body.cx0_134.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_134.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_134.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_134.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_134.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20835, 17929, 2779819, 5782⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P134 5782 PRE_first_tail_x15_r0_body.kappa134 PRE_first_tail_x15_r0_body.s1295.ffi PRE_first_tail_x15_r0_body.s1294.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift134 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue134, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp134 t ht),
    PRE_first_tail_x15_r0_body.cbridge134,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1295.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1294.ffi) (PRE_first_tail_x15_r0_body.cfoot134 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_134 PRE_first_tail_x15_r0_body.ofx1_134 hobjC PRE_first_tail_x15_r0_body.ff0134 PRE_first_tail_x15_r0_body.ff1134 PRE_first_tail_x15_r0_body.ffck134,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1295.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1294.ffi) (PRE_first_tail_x15_r0_body.cfoot134 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_134 PRE_first_tail_x15_r0_body.okr1_134 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn134) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0134 PRE_first_tail_x15_r0_body.fkt0134 PRE_first_tail_x15_r0_body.fkf1134 PRE_first_tail_x15_r0_body.fkt1134 PRE_first_tail_x15_r0_body.fkck134,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0134 PRE_first_tail_x15_r0_body.cnh1134 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe134) PRE_first_tail_x15_r0_body.cpendR134⟩

end Host.Load.Run.Tpl

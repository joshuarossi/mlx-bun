import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl16
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 16 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc16 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P16 : LoadP := PRE_first_tail_x15_r0_body.Pc16.raise 15618
kernel_rfl PRE_first_tail_x15_r0_body.craise16 : Nat.ble PRE_first_tail_x15_r0_body.Pc16.N0 15618 = true
theorem PRE_first_tail_x15_r0_body.raised16 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc16 PRE_first_tail_x15_r0_body.P16 :=
  .inr ⟨15618, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise16, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_16 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s170.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_16 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s169.ffi)
def PRE_first_tail_x15_r0_body.khinv16 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv16 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS16 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS16 : List Nat := List.range' 15618 0
def PRE_first_tail_x15_r0_body.ciS16 : List Nat := [] ++ List.range' 15618 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh016 : PRE_first_tail_x15_r0_body.kd16.nh0 = PRE_first_tail_x15_r0_body.cx0_16.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh116 : PRE_first_tail_x15_r0_body.kd16.nh1 = PRE_first_tail_x15_r0_body.cx1_16.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn016 : PRE_first_tail_x15_r0_body.kd16.nn0 = PRE_first_tail_x15_r0_body.cx0_16.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn116 : PRE_first_tail_x15_r0_body.kd16.nn1 = PRE_first_tail_x15_r0_body.cx1_16.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo16 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P16.lo && Nat.ble PRE_first_tail_x15_r0_body.P16.lo PRE_first_tail_x15_r0_body.cx0_16.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P16.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P16.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt16 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_16.mlx.next PRE_first_tail_x15_r0_body.cx1_16.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_16.mlx.nnext PRE_first_tail_x15_r0_body.cx1_16.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband16 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P16.NL && Nat.ble PRE_first_tail_x15_r0_body.P16.NL PRE_first_tail_x15_r0_body.P16.N0 && Nat.ble PRE_first_tail_x15_r0_body.P16.N0 PRE_first_tail_x15_r0_body.cx0_16.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow16 : PRE_first_tail_x15_r0_body.kd16.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren16 : checkRenG PRE_first_tail_x15_r0_body.kd16.hnd PRE_first_tail_x15_r0_body.khinv16 (phB PRE_first_tail_x15_r0_body.cx0_16.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband16 : PRE_first_tail_x15_r0_body.kd16.checkBand PRE_first_tail_x15_r0_body.P16.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos16 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd16.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren16 : checkRenG PRE_first_tail_x15_r0_body.kd16.node PRE_first_tail_x15_r0_body.kninv16 (pnB PRE_first_tail_x15_r0_body.cx0_16.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow16 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd16.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P16.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd16.nodeF j) PRE_first_tail_x15_r0_body.cx1_16.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a16 : PRE_first_tail_x15_r0_body.cx0_16.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b16 : PRE_first_tail_x15_r0_body.cx0_16.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok116 : PRE_first_tail_x15_r0_body.cx1_16.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend16 : PRE_first_tail_x15_r0_body.cx1_16.mlx.pending = PRE_first_tail_x15_r0_body.cx0_16.mlx.pending.map PRE_first_tail_x15_r0_body.kappa16.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh16 : PRE_first_tail_x15_r0_body.cx1_16.mlx.errh = PRE_first_tail_x15_r0_body.cx0_16.mlx.errh.map PRE_first_tail_x15_r0_body.kappa16.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles16 : PRE_first_tail_x15_r0_body.cx1_16.mlx.files = PRE_first_tail_x15_r0_body.cx0_16.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch16 : PRE_first_tail_x15_r0_body.cx1_16.mlx.arch = PRE_first_tail_x15_r0_body.cx0_16.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes16 : PRE_first_tail_x15_r0_body.cx1_16.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_16.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired16 : PRE_first_tail_x15_r0_body.cx1_16.mlx.wired = PRE_first_tail_x15_r0_body.cx0_16.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost16 : PRE_first_tail_x15_r0_body.cx1_16.host = PRE_first_tail_x15_r0_body.cx0_16.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd16`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn016 : PRE_first_tail_x15_r0_body.kd16.n0 = 2687627
kernel_rfl PRE_first_tail_x15_r0_body.ckn116 : PRE_first_tail_x15_r0_body.kd16.n1 = 2687629
kernel_rfl PRE_first_tail_x15_r0_body.ckheap16 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd16.heap).all (fun x => Nat.ble 2687627 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl16 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd16.heap.get (2687627 + j) = nth? PRE_first_tail_x15_r0_body.pl16 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja16 : Nat.ble 2687627 2687627 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn16 : Nat.ble 764 764 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD16 : Nat.ble 2687627 PRE_first_tail_x15_r0_body.kd16.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn16 : Nat.ble 18525 PRE_first_tail_x15_r0_body.kd16.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn16 : Nat.ble 15618 PRE_first_tail_x15_r0_body.kd16.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb16 : Nat.ble 18525 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap16 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd16.heap).all (Nat.ble (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd16 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd16.hnd).all (Nat.ble (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode16 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd16.node).all (Nat.ble (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix16 : Conv.FixOld (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa16 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja16) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn16) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD16) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn16) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn16) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb16) PRE_first_tail_x15_r0_body.fheap16 PRE_first_tail_x15_r0_body.fhnd16 PRE_first_tail_x15_r0_body.fnode16
kernel_rfl PRE_first_tail_x15_r0_body.fcxn16 : (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn16 : (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle016 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_16.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_16.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk16 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd16.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A16 : PRE_first_tail_x15_r0_body.cx1_16.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS16.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_16.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O16 : PRE_first_tail_x15_r0_body.cx1_16.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS16.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_16.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N16 : PRE_first_tail_x15_r0_body.cx1_16.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS16.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_16.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I16 : PRE_first_tail_x15_r0_body.cx1_16.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS16.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_16.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd16 : (PRE_first_tail_x15_r0_body.clo16 ++ PRE_first_tail_x15_r0_body.cln16 ++ PRE_first_tail_x15_r0_body.cli16 ++ PRE_first_tail_x15_r0_body.cwS16 ++ PRE_first_tail_x15_r0_body.cnS16 ++ PRE_first_tail_x15_r0_body.ciS16).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW16 : PRE_first_tail_x15_r0_body.cwS16.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo16.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI16 : PRE_first_tail_x15_r0_body.ciS16.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli16.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN16 : PRE_first_tail_x15_r0_body.cnS16.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF16 : PRE_first_tail_x15_r0_body.cln16.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh16 : PRE_first_tail_x15_r0_body.clo16.all (handleOK PRE_first_tail_x15_r0_body.kappa16 PRE_first_tail_x15_r0_body.P16.lo PRE_first_tail_x15_r0_body.cx0_16.mlx PRE_first_tail_x15_r0_body.cx1_16.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo16 : PRE_first_tail_x15_r0_body.clo16.map (fun h => PRE_first_tail_x15_r0_body.cx1_16.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa16.handle h)) = PRE_first_tail_x15_r0_body.clo16.map (fun h => (PRE_first_tail_x15_r0_body.cx0_16.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa16.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok16 : PRE_first_tail_x15_r0_body.clo16.all (objOK PRE_first_tail_x15_r0_body.kappa16 PRE_first_tail_x15_r0_body.P16.NL PRE_first_tail_x15_r0_body.cx0_16.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd16 : PRE_first_tail_x15_r0_body.cln16.all (nodeOKF PRE_first_tail_x15_r0_body.kappa16 PRE_first_tail_x15_r0_body.P16 PRE_first_tail_x15_r0_body.cx0_16.mlx PRE_first_tail_x15_r0_body.cx1_16.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp16 : ((PRE_first_tail_x15_r0_body.cln16.filter (fullB PRE_first_tail_x15_r0_body.P16))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_16.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa16.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln16.filter (fullB PRE_first_tail_x15_r0_body.P16))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_16.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa16.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI16 : incrB PRE_first_tail_x15_r0_body.kd16.nodeF (List.range' 15618 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK16 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd16.node).all (fun k => Nat.ble 15618 k && Nat.blt k 15618) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL16 : (PRE_first_tail_x15_r0_body.cln16.filter (Nat.ble PRE_first_tail_x15_r0_body.P16.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd16.nodeF i) && (Nat.blt i 15618 || Nat.ble PRE_first_tail_x15_r0_body.kd16.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord16 : (PRE_first_tail_x15_r0_body.cln16.filter (Nat.ble PRE_first_tail_x15_r0_body.P16.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd16.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd16.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd16.nodeF j) (PRE_first_tail_x15_r0_body.kd16.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow16 PRE_first_tail_x15_r0_body.cnn116 PRE_first_tail_x15_r0_body.fnordI16 PRE_first_tail_x15_r0_body.fnordK16 PRE_first_tail_x15_r0_body.fnordL16
kernel_rfl PRE_first_tail_x15_r0_body.fi16 : PRE_first_tail_x15_r0_body.cli16.all (pnB PRE_first_tail_x15_r0_body.cx0_16.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii16 : PRE_first_tail_x15_r0_body.cli16.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_16.mlx.items.get (PRE_first_tail_x15_r0_body.kappa16.node k) = (PRE_first_tail_x15_r0_body.cx0_16.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa16.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot16 (clean : Conv.NClean (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P16.NL) (cl : SSt (· < 764) PRE_first_tail_x15_r0_body.cx0_16.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P16 764 PRE_first_tail_x15_r0_body.kappa16 PRE_first_tail_x15_r0_body.kd16 PRE_first_tail_x15_r0_body.khinv16 PRE_first_tail_x15_r0_body.kninv16 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx PRE_first_tail_x15_r0_body.cx0_16.mlx PRE_first_tail_x15_r0_body.cx1_16.mlx (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo16 PRE_first_tail_x15_r0_body.cln16 PRE_first_tail_x15_r0_body.cli16 PRE_first_tail_x15_r0_body.cwS16 PRE_first_tail_x15_r0_body.cnS16 PRE_first_tail_x15_r0_body.ciS16 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh016, PRE_first_tail_x15_r0_body.cnh116, PRE_first_tail_x15_r0_body.cnn016, PRE_first_tail_x15_r0_body.cnn116, PRE_first_tail_x15_r0_body.cplo16, PRE_first_tail_x15_r0_body.ccnt16, PRE_first_tail_x15_r0_body.cnband16, PRE_first_tail_x15_r0_body.chbelow16, PRE_first_tail_x15_r0_body.chren16, PRE_first_tail_x15_r0_body.cband16, PRE_first_tail_x15_r0_body.cnh1pos16, PRE_first_tail_x15_r0_body.cnren16, PRE_first_tail_x15_r0_body.cnlow16, PRE_first_tail_x15_r0_body.cabs0a16, PRE_first_tail_x15_r0_body.cabs0b16, PRE_first_tail_x15_r0_body.ctok116, PRE_first_tail_x15_r0_body.cpend16, PRE_first_tail_x15_r0_body.cerrh16, PRE_first_tail_x15_r0_body.cfiles16, PRE_first_tail_x15_r0_body.carch16, PRE_first_tail_x15_r0_body.csizes16, PRE_first_tail_x15_r0_body.cwired16, PRE_first_tail_x15_r0_body.cfix16, clean, PRE_first_tail_x15_r0_body.fcxn16, PRE_first_tail_x15_r0_body.fcnn16, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle016, PRE_first_tail_x15_r0_body.fnk16, PRE_first_tail_x15_r0_body.ckA16, PRE_first_tail_x15_r0_body.cobjsK16, PRE_first_tail_x15_r0_body.cnodesK16, PRE_first_tail_x15_r0_body.citemsK16, PRE_first_tail_x15_r0_body.f1A16, PRE_first_tail_x15_r0_body.f1O16, PRE_first_tail_x15_r0_body.f1N16, PRE_first_tail_x15_r0_body.f1I16, PRE_first_tail_x15_r0_body.fbd16, PRE_first_tail_x15_r0_body.fincW16, PRE_first_tail_x15_r0_body.fincI16, PRE_first_tail_x15_r0_body.fincN16, PRE_first_tail_x15_r0_body.flnF16, PRE_first_tail_x15_r0_body.fh16, PRE_first_tail_x15_r0_body.fo16, PRE_first_tail_x15_r0_body.fok16, PRE_first_tail_x15_r0_body.fnd16, PRE_first_tail_x15_r0_body.fp16, PRE_first_tail_x15_r0_body.fnord16, PRE_first_tail_x15_r0_body.fi16, PRE_first_tail_x15_r0_body.fii16⟩
theorem PRE_first_tail_x15_r0_body.cnshift16 (clean : Conv.NClean (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P16.NL) (cl : SSt (· < 764) PRE_first_tail_x15_r0_body.cx0_16.mlx) : NShift PRE_first_tail_x15_r0_body.P16 764 PRE_first_tail_x15_r0_body.kappa16 PRE_first_tail_x15_r0_body.cx0_16 PRE_first_tail_x15_r0_body.cx1_16 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot16 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost16 (compact_a_eq PRE_first_tail_x15_r0_body.ckn016 PRE_first_tail_x15_r0_body.ckn116 PRE_first_tail_x15_r0_body.ckheap16 PRE_first_tail_x15_r0_body.ckpl16)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_16 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s168.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_16 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s168.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_16 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s168.ffi) = some PRE_first_tail_x15_r0_body.fxC_16
kernel_rfl PRE_first_tail_x15_r0_body.okrC_16 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s168.ffi) = some PRE_first_tail_x15_r0_body.krC_16
noncomputable def PRE_first_tail_x15_r0_body.fx0_16 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s170.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_16 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s170.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_16 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s170.ffi) = some PRE_first_tail_x15_r0_body.fx0_16
kernel_rfl PRE_first_tail_x15_r0_body.okr0_16 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s170.ffi) = some PRE_first_tail_x15_r0_body.kr0_16
noncomputable def PRE_first_tail_x15_r0_body.fx1_16 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s169.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_16 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s169.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_16 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s169.ffi) = some PRE_first_tail_x15_r0_body.fx1_16
kernel_rfl PRE_first_tail_x15_r0_body.okr1_16 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s169.ffi) = some PRE_first_tail_x15_r0_body.kr1_16
kernel_rfl PRE_first_tail_x15_r0_body.ff016 : PRE_first_tail_x15_r0_body.fx0_16 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_16 (PRE_first_tail_x15_r0_body.clo16.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_16.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff116 : PRE_first_tail_x15_r0_body.fx1_16 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_16 (PRE_first_tail_x15_r0_body.cwS16.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_16.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck16 : freedLB PRE_first_tail_x15_r0_body.kappa16 PRE_first_tail_x15_r0_body.cx0_16.mlx PRE_first_tail_x15_r0_body.fx0_16 PRE_first_tail_x15_r0_body.fx1_16 PRE_first_tail_x15_r0_body.clo16 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf016 : PRE_first_tail_x15_r0_body.kr0_16.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_16.flags (PRE_first_tail_x15_r0_body.clo16.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_16.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt016 : PRE_first_tail_x15_r0_body.kr0_16.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_16.targs (PRE_first_tail_x15_r0_body.clo16.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_16.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf116 : PRE_first_tail_x15_r0_body.kr1_16.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_16.flags (PRE_first_tail_x15_r0_body.cwS16.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_16.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt116 : PRE_first_tail_x15_r0_body.kr1_16.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_16.targs (PRE_first_tail_x15_r0_body.cwS16.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_16.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck16 : krecLB PRE_first_tail_x15_r0_body.kappa16 764 PRE_first_tail_x15_r0_body.cx0_16.mlx PRE_first_tail_x15_r0_body.kr0_16 PRE_first_tail_x15_r0_body.kr1_16 PRE_first_tail_x15_r0_body.clo16 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn16 : Nat.ble 764 764 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge16 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s169.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s170.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR16 : pendRegB PRE_first_tail_x15_r0_body.kappa16 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s170.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe16 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s170.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s169.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift16 (clean : Conv.NClean (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P16.NL) (cl : SSt (· < 764) PRE_first_tail_x15_r0_body.cx0_16.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_16.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_16.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_16.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_16.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P16 764 PRE_first_tail_x15_r0_body.kappa16 PRE_first_tail_x15_r0_body.s170.ffi PRE_first_tail_x15_r0_body.s169.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift16 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue16, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp16 t ht),
    PRE_first_tail_x15_r0_body.cbridge16,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s170.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s169.ffi) (PRE_first_tail_x15_r0_body.cfoot16 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_16 PRE_first_tail_x15_r0_body.ofx1_16 hobjC PRE_first_tail_x15_r0_body.ff016 PRE_first_tail_x15_r0_body.ff116 PRE_first_tail_x15_r0_body.ffck16,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s170.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s169.ffi) (PRE_first_tail_x15_r0_body.cfoot16 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_16 PRE_first_tail_x15_r0_body.okr1_16 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn16) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf016 PRE_first_tail_x15_r0_body.fkt016 PRE_first_tail_x15_r0_body.fkf116 PRE_first_tail_x15_r0_body.fkt116 PRE_first_tail_x15_r0_body.fkck16,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh016 PRE_first_tail_x15_r0_body.cnh116 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe16) PRE_first_tail_x15_r0_body.cpendR16⟩

end Host.Load.Run.Tpl

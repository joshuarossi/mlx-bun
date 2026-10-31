import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl44
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 44 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc44 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P44 : LoadP := PRE_first_tail_x15_r0_body.Pc44.raise 16159
kernel_rfl PRE_first_tail_x15_r0_body.craise44 : Nat.ble PRE_first_tail_x15_r0_body.Pc44.N0 16159 = true
theorem PRE_first_tail_x15_r0_body.raised44 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc44 PRE_first_tail_x15_r0_body.P44 :=
  .inr ⟨16159, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise44, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_44 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_44 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s432.ffi)
def PRE_first_tail_x15_r0_body.khinv44 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv44 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS44 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS44 : List Nat := List.range' 16159 0
def PRE_first_tail_x15_r0_body.ciS44 : List Nat := [] ++ List.range' 16159 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh044 : PRE_first_tail_x15_r0_body.kd44.nh0 = PRE_first_tail_x15_r0_body.cx0_44.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh144 : PRE_first_tail_x15_r0_body.kd44.nh1 = PRE_first_tail_x15_r0_body.cx1_44.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn044 : PRE_first_tail_x15_r0_body.kd44.nn0 = PRE_first_tail_x15_r0_body.cx0_44.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn144 : PRE_first_tail_x15_r0_body.kd44.nn1 = PRE_first_tail_x15_r0_body.cx1_44.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo44 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P44.lo && Nat.ble PRE_first_tail_x15_r0_body.P44.lo PRE_first_tail_x15_r0_body.cx0_44.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P44.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P44.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt44 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_44.mlx.next PRE_first_tail_x15_r0_body.cx1_44.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_44.mlx.nnext PRE_first_tail_x15_r0_body.cx1_44.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband44 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P44.NL && Nat.ble PRE_first_tail_x15_r0_body.P44.NL PRE_first_tail_x15_r0_body.P44.N0 && Nat.ble PRE_first_tail_x15_r0_body.P44.N0 PRE_first_tail_x15_r0_body.cx0_44.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow44 : PRE_first_tail_x15_r0_body.kd44.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren44 : checkRenG PRE_first_tail_x15_r0_body.kd44.hnd PRE_first_tail_x15_r0_body.khinv44 (phB PRE_first_tail_x15_r0_body.cx0_44.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband44 : PRE_first_tail_x15_r0_body.kd44.checkBand PRE_first_tail_x15_r0_body.P44.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos44 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd44.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren44 : checkRenG PRE_first_tail_x15_r0_body.kd44.node PRE_first_tail_x15_r0_body.kninv44 (pnB PRE_first_tail_x15_r0_body.cx0_44.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow44 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd44.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P44.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd44.nodeF j) PRE_first_tail_x15_r0_body.cx1_44.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a44 : PRE_first_tail_x15_r0_body.cx0_44.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b44 : PRE_first_tail_x15_r0_body.cx0_44.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok144 : PRE_first_tail_x15_r0_body.cx1_44.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend44 : PRE_first_tail_x15_r0_body.cx1_44.mlx.pending = PRE_first_tail_x15_r0_body.cx0_44.mlx.pending.map PRE_first_tail_x15_r0_body.kappa44.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh44 : PRE_first_tail_x15_r0_body.cx1_44.mlx.errh = PRE_first_tail_x15_r0_body.cx0_44.mlx.errh.map PRE_first_tail_x15_r0_body.kappa44.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles44 : PRE_first_tail_x15_r0_body.cx1_44.mlx.files = PRE_first_tail_x15_r0_body.cx0_44.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch44 : PRE_first_tail_x15_r0_body.cx1_44.mlx.arch = PRE_first_tail_x15_r0_body.cx0_44.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes44 : PRE_first_tail_x15_r0_body.cx1_44.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_44.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired44 : PRE_first_tail_x15_r0_body.cx1_44.mlx.wired = PRE_first_tail_x15_r0_body.cx0_44.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost44 : PRE_first_tail_x15_r0_body.cx1_44.host = PRE_first_tail_x15_r0_body.cx0_44.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd44`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn044 : PRE_first_tail_x15_r0_body.kd44.n0 = 2709004
kernel_rfl PRE_first_tail_x15_r0_body.ckn144 : PRE_first_tail_x15_r0_body.kd44.n1 = 2709014
kernel_rfl PRE_first_tail_x15_r0_body.ckheap44 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd44.heap).all (fun x => Nat.ble 2709003 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl44 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd44.heap.get (2709003 + j) = nth? PRE_first_tail_x15_r0_body.pl44 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja44 : Nat.ble 2709003 2709003 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn44 : Nat.ble 1936 1936 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD44 : Nat.ble 2709003 PRE_first_tail_x15_r0_body.kd44.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn44 : Nat.ble 19061 PRE_first_tail_x15_r0_body.kd44.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn44 : Nat.ble 16159 PRE_first_tail_x15_r0_body.kd44.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb44 : Nat.ble 19061 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap44 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd44.heap).all (Nat.ble (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd44 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd44.hnd).all (Nat.ble (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode44 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd44.node).all (Nat.ble (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix44 : Conv.FixOld (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa44 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja44) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn44) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD44) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn44) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn44) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb44) PRE_first_tail_x15_r0_body.fheap44 PRE_first_tail_x15_r0_body.fhnd44 PRE_first_tail_x15_r0_body.fnode44
kernel_rfl PRE_first_tail_x15_r0_body.fcxn44 : (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn44 : (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle044 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_44.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_44.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk44 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd44.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A44 : PRE_first_tail_x15_r0_body.cx1_44.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS44.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_44.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O44 : PRE_first_tail_x15_r0_body.cx1_44.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS44.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_44.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N44 : PRE_first_tail_x15_r0_body.cx1_44.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS44.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_44.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I44 : PRE_first_tail_x15_r0_body.cx1_44.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS44.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_44.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd44 : (PRE_first_tail_x15_r0_body.clo44 ++ PRE_first_tail_x15_r0_body.cln44 ++ PRE_first_tail_x15_r0_body.cli44 ++ PRE_first_tail_x15_r0_body.cwS44 ++ PRE_first_tail_x15_r0_body.cnS44 ++ PRE_first_tail_x15_r0_body.ciS44).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW44 : PRE_first_tail_x15_r0_body.cwS44.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo44.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI44 : PRE_first_tail_x15_r0_body.ciS44.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli44.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN44 : PRE_first_tail_x15_r0_body.cnS44.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF44 : PRE_first_tail_x15_r0_body.cln44.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh44 : PRE_first_tail_x15_r0_body.clo44.all (handleOK PRE_first_tail_x15_r0_body.kappa44 PRE_first_tail_x15_r0_body.P44.lo PRE_first_tail_x15_r0_body.cx0_44.mlx PRE_first_tail_x15_r0_body.cx1_44.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo44 : PRE_first_tail_x15_r0_body.clo44.map (fun h => PRE_first_tail_x15_r0_body.cx1_44.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa44.handle h)) = PRE_first_tail_x15_r0_body.clo44.map (fun h => (PRE_first_tail_x15_r0_body.cx0_44.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa44.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok44 : PRE_first_tail_x15_r0_body.clo44.all (objOK PRE_first_tail_x15_r0_body.kappa44 PRE_first_tail_x15_r0_body.P44.NL PRE_first_tail_x15_r0_body.cx0_44.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd44 : PRE_first_tail_x15_r0_body.cln44.all (nodeOKF PRE_first_tail_x15_r0_body.kappa44 PRE_first_tail_x15_r0_body.P44 PRE_first_tail_x15_r0_body.cx0_44.mlx PRE_first_tail_x15_r0_body.cx1_44.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp44 : ((PRE_first_tail_x15_r0_body.cln44.filter (fullB PRE_first_tail_x15_r0_body.P44))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_44.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa44.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln44.filter (fullB PRE_first_tail_x15_r0_body.P44))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_44.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa44.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI44 : incrB PRE_first_tail_x15_r0_body.kd44.nodeF (List.range' 16159 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK44 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd44.node).all (fun k => Nat.ble 16159 k && Nat.blt k 16159) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL44 : (PRE_first_tail_x15_r0_body.cln44.filter (Nat.ble PRE_first_tail_x15_r0_body.P44.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd44.nodeF i) && (Nat.blt i 16159 || Nat.ble PRE_first_tail_x15_r0_body.kd44.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord44 : (PRE_first_tail_x15_r0_body.cln44.filter (Nat.ble PRE_first_tail_x15_r0_body.P44.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd44.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd44.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd44.nodeF j) (PRE_first_tail_x15_r0_body.kd44.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow44 PRE_first_tail_x15_r0_body.cnn144 PRE_first_tail_x15_r0_body.fnordI44 PRE_first_tail_x15_r0_body.fnordK44 PRE_first_tail_x15_r0_body.fnordL44
kernel_rfl PRE_first_tail_x15_r0_body.fi44 : PRE_first_tail_x15_r0_body.cli44.all (pnB PRE_first_tail_x15_r0_body.cx0_44.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii44 : PRE_first_tail_x15_r0_body.cli44.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_44.mlx.items.get (PRE_first_tail_x15_r0_body.kappa44.node k) = (PRE_first_tail_x15_r0_body.cx0_44.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa44.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot44 (clean : Conv.NClean (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P44.NL) (cl : SSt (· < 1936) PRE_first_tail_x15_r0_body.cx0_44.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P44 1936 PRE_first_tail_x15_r0_body.kappa44 PRE_first_tail_x15_r0_body.kd44 PRE_first_tail_x15_r0_body.khinv44 PRE_first_tail_x15_r0_body.kninv44 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx PRE_first_tail_x15_r0_body.cx0_44.mlx PRE_first_tail_x15_r0_body.cx1_44.mlx (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo44 PRE_first_tail_x15_r0_body.cln44 PRE_first_tail_x15_r0_body.cli44 PRE_first_tail_x15_r0_body.cwS44 PRE_first_tail_x15_r0_body.cnS44 PRE_first_tail_x15_r0_body.ciS44 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh044, PRE_first_tail_x15_r0_body.cnh144, PRE_first_tail_x15_r0_body.cnn044, PRE_first_tail_x15_r0_body.cnn144, PRE_first_tail_x15_r0_body.cplo44, PRE_first_tail_x15_r0_body.ccnt44, PRE_first_tail_x15_r0_body.cnband44, PRE_first_tail_x15_r0_body.chbelow44, PRE_first_tail_x15_r0_body.chren44, PRE_first_tail_x15_r0_body.cband44, PRE_first_tail_x15_r0_body.cnh1pos44, PRE_first_tail_x15_r0_body.cnren44, PRE_first_tail_x15_r0_body.cnlow44, PRE_first_tail_x15_r0_body.cabs0a44, PRE_first_tail_x15_r0_body.cabs0b44, PRE_first_tail_x15_r0_body.ctok144, PRE_first_tail_x15_r0_body.cpend44, PRE_first_tail_x15_r0_body.cerrh44, PRE_first_tail_x15_r0_body.cfiles44, PRE_first_tail_x15_r0_body.carch44, PRE_first_tail_x15_r0_body.csizes44, PRE_first_tail_x15_r0_body.cwired44, PRE_first_tail_x15_r0_body.cfix44, clean, PRE_first_tail_x15_r0_body.fcxn44, PRE_first_tail_x15_r0_body.fcnn44, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle044, PRE_first_tail_x15_r0_body.fnk44, PRE_first_tail_x15_r0_body.ckA44, PRE_first_tail_x15_r0_body.cobjsK44, PRE_first_tail_x15_r0_body.cnodesK44, PRE_first_tail_x15_r0_body.citemsK44, PRE_first_tail_x15_r0_body.f1A44, PRE_first_tail_x15_r0_body.f1O44, PRE_first_tail_x15_r0_body.f1N44, PRE_first_tail_x15_r0_body.f1I44, PRE_first_tail_x15_r0_body.fbd44, PRE_first_tail_x15_r0_body.fincW44, PRE_first_tail_x15_r0_body.fincI44, PRE_first_tail_x15_r0_body.fincN44, PRE_first_tail_x15_r0_body.flnF44, PRE_first_tail_x15_r0_body.fh44, PRE_first_tail_x15_r0_body.fo44, PRE_first_tail_x15_r0_body.fok44, PRE_first_tail_x15_r0_body.fnd44, PRE_first_tail_x15_r0_body.fp44, PRE_first_tail_x15_r0_body.fnord44, PRE_first_tail_x15_r0_body.fi44, PRE_first_tail_x15_r0_body.fii44⟩
theorem PRE_first_tail_x15_r0_body.cnshift44 (clean : Conv.NClean (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P44.NL) (cl : SSt (· < 1936) PRE_first_tail_x15_r0_body.cx0_44.mlx) : NShift PRE_first_tail_x15_r0_body.P44 1936 PRE_first_tail_x15_r0_body.kappa44 PRE_first_tail_x15_r0_body.cx0_44 PRE_first_tail_x15_r0_body.cx1_44 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot44 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost44 (compact_a_eq PRE_first_tail_x15_r0_body.ckn044 PRE_first_tail_x15_r0_body.ckn144 PRE_first_tail_x15_r0_body.ckheap44 PRE_first_tail_x15_r0_body.ckpl44)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_44 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s431.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_44 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s431.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_44 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s431.ffi) = some PRE_first_tail_x15_r0_body.fxC_44
kernel_rfl PRE_first_tail_x15_r0_body.okrC_44 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s431.ffi) = some PRE_first_tail_x15_r0_body.krC_44
noncomputable def PRE_first_tail_x15_r0_body.fx0_44 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s433.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_44 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s433.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_44 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s433.ffi) = some PRE_first_tail_x15_r0_body.fx0_44
kernel_rfl PRE_first_tail_x15_r0_body.okr0_44 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s433.ffi) = some PRE_first_tail_x15_r0_body.kr0_44
noncomputable def PRE_first_tail_x15_r0_body.fx1_44 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s432.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_44 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s432.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_44 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s432.ffi) = some PRE_first_tail_x15_r0_body.fx1_44
kernel_rfl PRE_first_tail_x15_r0_body.okr1_44 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s432.ffi) = some PRE_first_tail_x15_r0_body.kr1_44
kernel_rfl PRE_first_tail_x15_r0_body.ff044 : PRE_first_tail_x15_r0_body.fx0_44 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_44 (PRE_first_tail_x15_r0_body.clo44.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_44.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff144 : PRE_first_tail_x15_r0_body.fx1_44 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_44 (PRE_first_tail_x15_r0_body.cwS44.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_44.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck44 : freedLB PRE_first_tail_x15_r0_body.kappa44 PRE_first_tail_x15_r0_body.cx0_44.mlx PRE_first_tail_x15_r0_body.fx0_44 PRE_first_tail_x15_r0_body.fx1_44 PRE_first_tail_x15_r0_body.clo44 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf044 : PRE_first_tail_x15_r0_body.kr0_44.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_44.flags (PRE_first_tail_x15_r0_body.clo44.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_44.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt044 : PRE_first_tail_x15_r0_body.kr0_44.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_44.targs (PRE_first_tail_x15_r0_body.clo44.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_44.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf144 : PRE_first_tail_x15_r0_body.kr1_44.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_44.flags (PRE_first_tail_x15_r0_body.cwS44.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_44.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt144 : PRE_first_tail_x15_r0_body.kr1_44.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_44.targs (PRE_first_tail_x15_r0_body.cwS44.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_44.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck44 : krecLB PRE_first_tail_x15_r0_body.kappa44 1936 PRE_first_tail_x15_r0_body.cx0_44.mlx PRE_first_tail_x15_r0_body.kr0_44 PRE_first_tail_x15_r0_body.kr1_44 PRE_first_tail_x15_r0_body.clo44 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn44 : Nat.ble 1936 1936 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge44 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s432.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s433.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR44 : pendRegB PRE_first_tail_x15_r0_body.kappa44 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe44 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s432.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift44 (clean : Conv.NClean (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P44.NL) (cl : SSt (· < 1936) PRE_first_tail_x15_r0_body.cx0_44.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_44.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_44.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_44.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_44.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P44 1936 PRE_first_tail_x15_r0_body.kappa44 PRE_first_tail_x15_r0_body.s433.ffi PRE_first_tail_x15_r0_body.s432.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift44 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue44, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp44 t ht),
    PRE_first_tail_x15_r0_body.cbridge44,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s433.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s432.ffi) (PRE_first_tail_x15_r0_body.cfoot44 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_44 PRE_first_tail_x15_r0_body.ofx1_44 hobjC PRE_first_tail_x15_r0_body.ff044 PRE_first_tail_x15_r0_body.ff144 PRE_first_tail_x15_r0_body.ffck44,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s433.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s432.ffi) (PRE_first_tail_x15_r0_body.cfoot44 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_44 PRE_first_tail_x15_r0_body.okr1_44 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn44) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf044 PRE_first_tail_x15_r0_body.fkt044 PRE_first_tail_x15_r0_body.fkf144 PRE_first_tail_x15_r0_body.fkt144 PRE_first_tail_x15_r0_body.fkck44,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh044 PRE_first_tail_x15_r0_body.cnh144 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe44) PRE_first_tail_x15_r0_body.cpendR44⟩

end Host.Load.Run.Tpl

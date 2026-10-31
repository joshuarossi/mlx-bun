import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl86
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 86 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc86 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P86 : LoadP := PRE_first_tail_x15_r0_body.Pc86.raise 16981
kernel_rfl PRE_first_tail_x15_r0_body.craise86 : Nat.ble PRE_first_tail_x15_r0_body.Pc86.N0 16981 = true
theorem PRE_first_tail_x15_r0_body.raised86 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc86 PRE_first_tail_x15_r0_body.P86 :=
  .inr ⟨16981, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise86, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_86 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s762.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_86 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s761.ffi)
def PRE_first_tail_x15_r0_body.khinv86 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv86 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS86 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS86 : List Nat := List.range' 16981 0
def PRE_first_tail_x15_r0_body.ciS86 : List Nat := [] ++ List.range' 16981 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh086 : PRE_first_tail_x15_r0_body.kd86.nh0 = PRE_first_tail_x15_r0_body.cx0_86.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh186 : PRE_first_tail_x15_r0_body.kd86.nh1 = PRE_first_tail_x15_r0_body.cx1_86.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn086 : PRE_first_tail_x15_r0_body.kd86.nn0 = PRE_first_tail_x15_r0_body.cx0_86.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn186 : PRE_first_tail_x15_r0_body.kd86.nn1 = PRE_first_tail_x15_r0_body.cx1_86.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo86 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P86.lo && Nat.ble PRE_first_tail_x15_r0_body.P86.lo PRE_first_tail_x15_r0_body.cx0_86.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P86.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P86.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt86 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_86.mlx.next PRE_first_tail_x15_r0_body.cx1_86.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_86.mlx.nnext PRE_first_tail_x15_r0_body.cx1_86.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband86 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P86.NL && Nat.ble PRE_first_tail_x15_r0_body.P86.NL PRE_first_tail_x15_r0_body.P86.N0 && Nat.ble PRE_first_tail_x15_r0_body.P86.N0 PRE_first_tail_x15_r0_body.cx0_86.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow86 : PRE_first_tail_x15_r0_body.kd86.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren86 : checkRenG PRE_first_tail_x15_r0_body.kd86.hnd PRE_first_tail_x15_r0_body.khinv86 (phB PRE_first_tail_x15_r0_body.cx0_86.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband86 : PRE_first_tail_x15_r0_body.kd86.checkBand PRE_first_tail_x15_r0_body.P86.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos86 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd86.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren86 : checkRenG PRE_first_tail_x15_r0_body.kd86.node PRE_first_tail_x15_r0_body.kninv86 (pnB PRE_first_tail_x15_r0_body.cx0_86.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow86 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd86.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P86.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd86.nodeF j) PRE_first_tail_x15_r0_body.cx1_86.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a86 : PRE_first_tail_x15_r0_body.cx0_86.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b86 : PRE_first_tail_x15_r0_body.cx0_86.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok186 : PRE_first_tail_x15_r0_body.cx1_86.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend86 : PRE_first_tail_x15_r0_body.cx1_86.mlx.pending = PRE_first_tail_x15_r0_body.cx0_86.mlx.pending.map PRE_first_tail_x15_r0_body.kappa86.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh86 : PRE_first_tail_x15_r0_body.cx1_86.mlx.errh = PRE_first_tail_x15_r0_body.cx0_86.mlx.errh.map PRE_first_tail_x15_r0_body.kappa86.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles86 : PRE_first_tail_x15_r0_body.cx1_86.mlx.files = PRE_first_tail_x15_r0_body.cx0_86.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch86 : PRE_first_tail_x15_r0_body.cx1_86.mlx.arch = PRE_first_tail_x15_r0_body.cx0_86.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes86 : PRE_first_tail_x15_r0_body.cx1_86.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_86.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired86 : PRE_first_tail_x15_r0_body.cx1_86.mlx.wired = PRE_first_tail_x15_r0_body.cx0_86.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost86 : PRE_first_tail_x15_r0_body.cx1_86.host = PRE_first_tail_x15_r0_body.cx0_86.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd86`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn086 : PRE_first_tail_x15_r0_body.kd86.n0 = 2742156
kernel_rfl PRE_first_tail_x15_r0_body.ckn186 : PRE_first_tail_x15_r0_body.kd86.n1 = 2742166
kernel_rfl PRE_first_tail_x15_r0_body.ckheap86 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd86.heap).all (fun x => Nat.ble 2742155 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl86 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd86.heap.get (2742155 + j) = nth? PRE_first_tail_x15_r0_body.pl86 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja86 : Nat.ble 2742155 2742155 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn86 : Nat.ble 3730 3730 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD86 : Nat.ble 2742155 PRE_first_tail_x15_r0_body.kd86.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn86 : Nat.ble 19891 PRE_first_tail_x15_r0_body.kd86.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn86 : Nat.ble 16981 PRE_first_tail_x15_r0_body.kd86.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb86 : Nat.ble 19891 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap86 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd86.heap).all (Nat.ble (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd86 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd86.hnd).all (Nat.ble (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode86 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd86.node).all (Nat.ble (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix86 : Conv.FixOld (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa86 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja86) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn86) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD86) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn86) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn86) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb86) PRE_first_tail_x15_r0_body.fheap86 PRE_first_tail_x15_r0_body.fhnd86 PRE_first_tail_x15_r0_body.fnode86
kernel_rfl PRE_first_tail_x15_r0_body.fcxn86 : (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn86 : (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle086 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_86.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_86.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk86 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd86.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A86 : PRE_first_tail_x15_r0_body.cx1_86.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS86.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_86.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O86 : PRE_first_tail_x15_r0_body.cx1_86.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS86.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_86.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N86 : PRE_first_tail_x15_r0_body.cx1_86.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS86.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_86.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I86 : PRE_first_tail_x15_r0_body.cx1_86.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS86.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_86.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd86 : (PRE_first_tail_x15_r0_body.clo86 ++ PRE_first_tail_x15_r0_body.cln86 ++ PRE_first_tail_x15_r0_body.cli86 ++ PRE_first_tail_x15_r0_body.cwS86 ++ PRE_first_tail_x15_r0_body.cnS86 ++ PRE_first_tail_x15_r0_body.ciS86).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW86 : PRE_first_tail_x15_r0_body.cwS86.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo86.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI86 : PRE_first_tail_x15_r0_body.ciS86.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli86.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN86 : PRE_first_tail_x15_r0_body.cnS86.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF86 : PRE_first_tail_x15_r0_body.cln86.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh86 : PRE_first_tail_x15_r0_body.clo86.all (handleOK PRE_first_tail_x15_r0_body.kappa86 PRE_first_tail_x15_r0_body.P86.lo PRE_first_tail_x15_r0_body.cx0_86.mlx PRE_first_tail_x15_r0_body.cx1_86.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo86 : PRE_first_tail_x15_r0_body.clo86.map (fun h => PRE_first_tail_x15_r0_body.cx1_86.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa86.handle h)) = PRE_first_tail_x15_r0_body.clo86.map (fun h => (PRE_first_tail_x15_r0_body.cx0_86.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa86.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok86 : PRE_first_tail_x15_r0_body.clo86.all (objOK PRE_first_tail_x15_r0_body.kappa86 PRE_first_tail_x15_r0_body.P86.NL PRE_first_tail_x15_r0_body.cx0_86.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd86 : PRE_first_tail_x15_r0_body.cln86.all (nodeOKF PRE_first_tail_x15_r0_body.kappa86 PRE_first_tail_x15_r0_body.P86 PRE_first_tail_x15_r0_body.cx0_86.mlx PRE_first_tail_x15_r0_body.cx1_86.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp86 : ((PRE_first_tail_x15_r0_body.cln86.filter (fullB PRE_first_tail_x15_r0_body.P86))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_86.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa86.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln86.filter (fullB PRE_first_tail_x15_r0_body.P86))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_86.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa86.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI86 : incrB PRE_first_tail_x15_r0_body.kd86.nodeF (List.range' 16981 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK86 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd86.node).all (fun k => Nat.ble 16981 k && Nat.blt k 16981) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL86 : (PRE_first_tail_x15_r0_body.cln86.filter (Nat.ble PRE_first_tail_x15_r0_body.P86.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd86.nodeF i) && (Nat.blt i 16981 || Nat.ble PRE_first_tail_x15_r0_body.kd86.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord86 : (PRE_first_tail_x15_r0_body.cln86.filter (Nat.ble PRE_first_tail_x15_r0_body.P86.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd86.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd86.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd86.nodeF j) (PRE_first_tail_x15_r0_body.kd86.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow86 PRE_first_tail_x15_r0_body.cnn186 PRE_first_tail_x15_r0_body.fnordI86 PRE_first_tail_x15_r0_body.fnordK86 PRE_first_tail_x15_r0_body.fnordL86
kernel_rfl PRE_first_tail_x15_r0_body.fi86 : PRE_first_tail_x15_r0_body.cli86.all (pnB PRE_first_tail_x15_r0_body.cx0_86.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii86 : PRE_first_tail_x15_r0_body.cli86.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_86.mlx.items.get (PRE_first_tail_x15_r0_body.kappa86.node k) = (PRE_first_tail_x15_r0_body.cx0_86.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa86.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot86 (clean : Conv.NClean (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P86.NL) (cl : SSt (· < 3730) PRE_first_tail_x15_r0_body.cx0_86.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P86 3730 PRE_first_tail_x15_r0_body.kappa86 PRE_first_tail_x15_r0_body.kd86 PRE_first_tail_x15_r0_body.khinv86 PRE_first_tail_x15_r0_body.kninv86 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx PRE_first_tail_x15_r0_body.cx0_86.mlx PRE_first_tail_x15_r0_body.cx1_86.mlx (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo86 PRE_first_tail_x15_r0_body.cln86 PRE_first_tail_x15_r0_body.cli86 PRE_first_tail_x15_r0_body.cwS86 PRE_first_tail_x15_r0_body.cnS86 PRE_first_tail_x15_r0_body.ciS86 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh086, PRE_first_tail_x15_r0_body.cnh186, PRE_first_tail_x15_r0_body.cnn086, PRE_first_tail_x15_r0_body.cnn186, PRE_first_tail_x15_r0_body.cplo86, PRE_first_tail_x15_r0_body.ccnt86, PRE_first_tail_x15_r0_body.cnband86, PRE_first_tail_x15_r0_body.chbelow86, PRE_first_tail_x15_r0_body.chren86, PRE_first_tail_x15_r0_body.cband86, PRE_first_tail_x15_r0_body.cnh1pos86, PRE_first_tail_x15_r0_body.cnren86, PRE_first_tail_x15_r0_body.cnlow86, PRE_first_tail_x15_r0_body.cabs0a86, PRE_first_tail_x15_r0_body.cabs0b86, PRE_first_tail_x15_r0_body.ctok186, PRE_first_tail_x15_r0_body.cpend86, PRE_first_tail_x15_r0_body.cerrh86, PRE_first_tail_x15_r0_body.cfiles86, PRE_first_tail_x15_r0_body.carch86, PRE_first_tail_x15_r0_body.csizes86, PRE_first_tail_x15_r0_body.cwired86, PRE_first_tail_x15_r0_body.cfix86, clean, PRE_first_tail_x15_r0_body.fcxn86, PRE_first_tail_x15_r0_body.fcnn86, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle086, PRE_first_tail_x15_r0_body.fnk86, PRE_first_tail_x15_r0_body.ckA86, PRE_first_tail_x15_r0_body.cobjsK86, PRE_first_tail_x15_r0_body.cnodesK86, PRE_first_tail_x15_r0_body.citemsK86, PRE_first_tail_x15_r0_body.f1A86, PRE_first_tail_x15_r0_body.f1O86, PRE_first_tail_x15_r0_body.f1N86, PRE_first_tail_x15_r0_body.f1I86, PRE_first_tail_x15_r0_body.fbd86, PRE_first_tail_x15_r0_body.fincW86, PRE_first_tail_x15_r0_body.fincI86, PRE_first_tail_x15_r0_body.fincN86, PRE_first_tail_x15_r0_body.flnF86, PRE_first_tail_x15_r0_body.fh86, PRE_first_tail_x15_r0_body.fo86, PRE_first_tail_x15_r0_body.fok86, PRE_first_tail_x15_r0_body.fnd86, PRE_first_tail_x15_r0_body.fp86, PRE_first_tail_x15_r0_body.fnord86, PRE_first_tail_x15_r0_body.fi86, PRE_first_tail_x15_r0_body.fii86⟩
theorem PRE_first_tail_x15_r0_body.cnshift86 (clean : Conv.NClean (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P86.NL) (cl : SSt (· < 3730) PRE_first_tail_x15_r0_body.cx0_86.mlx) : NShift PRE_first_tail_x15_r0_body.P86 3730 PRE_first_tail_x15_r0_body.kappa86 PRE_first_tail_x15_r0_body.cx0_86 PRE_first_tail_x15_r0_body.cx1_86 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot86 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost86 (compact_a_eq PRE_first_tail_x15_r0_body.ckn086 PRE_first_tail_x15_r0_body.ckn186 PRE_first_tail_x15_r0_body.ckheap86 PRE_first_tail_x15_r0_body.ckpl86)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_86 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s760.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_86 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s760.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_86 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s760.ffi) = some PRE_first_tail_x15_r0_body.fxC_86
kernel_rfl PRE_first_tail_x15_r0_body.okrC_86 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s760.ffi) = some PRE_first_tail_x15_r0_body.krC_86
noncomputable def PRE_first_tail_x15_r0_body.fx0_86 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s762.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_86 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s762.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_86 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s762.ffi) = some PRE_first_tail_x15_r0_body.fx0_86
kernel_rfl PRE_first_tail_x15_r0_body.okr0_86 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s762.ffi) = some PRE_first_tail_x15_r0_body.kr0_86
noncomputable def PRE_first_tail_x15_r0_body.fx1_86 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s761.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_86 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s761.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_86 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s761.ffi) = some PRE_first_tail_x15_r0_body.fx1_86
kernel_rfl PRE_first_tail_x15_r0_body.okr1_86 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s761.ffi) = some PRE_first_tail_x15_r0_body.kr1_86
kernel_rfl PRE_first_tail_x15_r0_body.ff086 : PRE_first_tail_x15_r0_body.fx0_86 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_86 (PRE_first_tail_x15_r0_body.clo86.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_86.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff186 : PRE_first_tail_x15_r0_body.fx1_86 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_86 (PRE_first_tail_x15_r0_body.cwS86.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_86.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck86 : freedLB PRE_first_tail_x15_r0_body.kappa86 PRE_first_tail_x15_r0_body.cx0_86.mlx PRE_first_tail_x15_r0_body.fx0_86 PRE_first_tail_x15_r0_body.fx1_86 PRE_first_tail_x15_r0_body.clo86 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf086 : PRE_first_tail_x15_r0_body.kr0_86.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_86.flags (PRE_first_tail_x15_r0_body.clo86.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_86.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt086 : PRE_first_tail_x15_r0_body.kr0_86.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_86.targs (PRE_first_tail_x15_r0_body.clo86.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_86.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf186 : PRE_first_tail_x15_r0_body.kr1_86.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_86.flags (PRE_first_tail_x15_r0_body.cwS86.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_86.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt186 : PRE_first_tail_x15_r0_body.kr1_86.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_86.targs (PRE_first_tail_x15_r0_body.cwS86.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_86.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck86 : krecLB PRE_first_tail_x15_r0_body.kappa86 3730 PRE_first_tail_x15_r0_body.cx0_86.mlx PRE_first_tail_x15_r0_body.kr0_86 PRE_first_tail_x15_r0_body.kr1_86 PRE_first_tail_x15_r0_body.clo86 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn86 : Nat.ble 3730 3730 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge86 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s761.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s762.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR86 : pendRegB PRE_first_tail_x15_r0_body.kappa86 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s762.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe86 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s762.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s761.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift86 (clean : Conv.NClean (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P86.NL) (cl : SSt (· < 3730) PRE_first_tail_x15_r0_body.cx0_86.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_86.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_86.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_86.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_86.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P86 3730 PRE_first_tail_x15_r0_body.kappa86 PRE_first_tail_x15_r0_body.s762.ffi PRE_first_tail_x15_r0_body.s761.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift86 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue86, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp86 t ht),
    PRE_first_tail_x15_r0_body.cbridge86,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s762.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s761.ffi) (PRE_first_tail_x15_r0_body.cfoot86 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_86 PRE_first_tail_x15_r0_body.ofx1_86 hobjC PRE_first_tail_x15_r0_body.ff086 PRE_first_tail_x15_r0_body.ff186 PRE_first_tail_x15_r0_body.ffck86,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s762.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s761.ffi) (PRE_first_tail_x15_r0_body.cfoot86 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_86 PRE_first_tail_x15_r0_body.okr1_86 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn86) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf086 PRE_first_tail_x15_r0_body.fkt086 PRE_first_tail_x15_r0_body.fkf186 PRE_first_tail_x15_r0_body.fkt186 PRE_first_tail_x15_r0_body.fkck86,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh086 PRE_first_tail_x15_r0_body.cnh186 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe86) PRE_first_tail_x15_r0_body.cpendR86⟩

end Host.Load.Run.Tpl

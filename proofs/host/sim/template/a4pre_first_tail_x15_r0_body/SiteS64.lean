import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl64
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 64 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc64 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P64 : LoadP := PRE_first_tail_x15_r0_body.Pc64.raise 16566
kernel_rfl PRE_first_tail_x15_r0_body.craise64 : Nat.ble PRE_first_tail_x15_r0_body.Pc64.N0 16566 = true
theorem PRE_first_tail_x15_r0_body.raised64 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc64 PRE_first_tail_x15_r0_body.P64 :=
  .inr ⟨16566, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise64, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_64 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_64 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s629.ffi)
def PRE_first_tail_x15_r0_body.khinv64 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv64 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS64 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS64 : List Nat := List.range' 16566 0
def PRE_first_tail_x15_r0_body.ciS64 : List Nat := [] ++ List.range' 16566 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh064 : PRE_first_tail_x15_r0_body.kd64.nh0 = PRE_first_tail_x15_r0_body.cx0_64.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh164 : PRE_first_tail_x15_r0_body.kd64.nh1 = PRE_first_tail_x15_r0_body.cx1_64.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn064 : PRE_first_tail_x15_r0_body.kd64.nn0 = PRE_first_tail_x15_r0_body.cx0_64.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn164 : PRE_first_tail_x15_r0_body.kd64.nn1 = PRE_first_tail_x15_r0_body.cx1_64.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo64 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P64.lo && Nat.ble PRE_first_tail_x15_r0_body.P64.lo PRE_first_tail_x15_r0_body.cx0_64.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P64.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P64.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt64 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_64.mlx.next PRE_first_tail_x15_r0_body.cx1_64.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_64.mlx.nnext PRE_first_tail_x15_r0_body.cx1_64.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband64 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P64.NL && Nat.ble PRE_first_tail_x15_r0_body.P64.NL PRE_first_tail_x15_r0_body.P64.N0 && Nat.ble PRE_first_tail_x15_r0_body.P64.N0 PRE_first_tail_x15_r0_body.cx0_64.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow64 : PRE_first_tail_x15_r0_body.kd64.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren64 : checkRenG PRE_first_tail_x15_r0_body.kd64.hnd PRE_first_tail_x15_r0_body.khinv64 (phB PRE_first_tail_x15_r0_body.cx0_64.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband64 : PRE_first_tail_x15_r0_body.kd64.checkBand PRE_first_tail_x15_r0_body.P64.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos64 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd64.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren64 : checkRenG PRE_first_tail_x15_r0_body.kd64.node PRE_first_tail_x15_r0_body.kninv64 (pnB PRE_first_tail_x15_r0_body.cx0_64.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow64 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd64.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P64.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd64.nodeF j) PRE_first_tail_x15_r0_body.cx1_64.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a64 : PRE_first_tail_x15_r0_body.cx0_64.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b64 : PRE_first_tail_x15_r0_body.cx0_64.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok164 : PRE_first_tail_x15_r0_body.cx1_64.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend64 : PRE_first_tail_x15_r0_body.cx1_64.mlx.pending = PRE_first_tail_x15_r0_body.cx0_64.mlx.pending.map PRE_first_tail_x15_r0_body.kappa64.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh64 : PRE_first_tail_x15_r0_body.cx1_64.mlx.errh = PRE_first_tail_x15_r0_body.cx0_64.mlx.errh.map PRE_first_tail_x15_r0_body.kappa64.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles64 : PRE_first_tail_x15_r0_body.cx1_64.mlx.files = PRE_first_tail_x15_r0_body.cx0_64.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch64 : PRE_first_tail_x15_r0_body.cx1_64.mlx.arch = PRE_first_tail_x15_r0_body.cx0_64.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes64 : PRE_first_tail_x15_r0_body.cx1_64.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_64.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired64 : PRE_first_tail_x15_r0_body.cx1_64.mlx.wired = PRE_first_tail_x15_r0_body.cx0_64.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost64 : PRE_first_tail_x15_r0_body.cx1_64.host = PRE_first_tail_x15_r0_body.cx0_64.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd64`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn064 : PRE_first_tail_x15_r0_body.kd64.n0 = 2725299
kernel_rfl PRE_first_tail_x15_r0_body.ckn164 : PRE_first_tail_x15_r0_body.kd64.n1 = 2725301
kernel_rfl PRE_first_tail_x15_r0_body.ckheap64 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd64.heap).all (fun x => Nat.ble 2725299 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl64 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd64.heap.get (2725299 + j) = nth? PRE_first_tail_x15_r0_body.pl64 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja64 : Nat.ble 2725299 2725299 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn64 : Nat.ble 2816 2816 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD64 : Nat.ble 2725299 PRE_first_tail_x15_r0_body.kd64.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn64 : Nat.ble 19469 PRE_first_tail_x15_r0_body.kd64.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn64 : Nat.ble 16566 PRE_first_tail_x15_r0_body.kd64.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb64 : Nat.ble 19469 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap64 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd64.heap).all (Nat.ble (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd64 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd64.hnd).all (Nat.ble (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode64 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd64.node).all (Nat.ble (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix64 : Conv.FixOld (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa64 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja64) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn64) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD64) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn64) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn64) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb64) PRE_first_tail_x15_r0_body.fheap64 PRE_first_tail_x15_r0_body.fhnd64 PRE_first_tail_x15_r0_body.fnode64
kernel_rfl PRE_first_tail_x15_r0_body.fcxn64 : (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn64 : (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle064 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_64.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_64.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk64 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd64.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A64 : PRE_first_tail_x15_r0_body.cx1_64.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS64.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_64.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O64 : PRE_first_tail_x15_r0_body.cx1_64.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS64.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_64.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N64 : PRE_first_tail_x15_r0_body.cx1_64.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS64.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_64.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I64 : PRE_first_tail_x15_r0_body.cx1_64.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS64.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_64.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd64 : (PRE_first_tail_x15_r0_body.clo64 ++ PRE_first_tail_x15_r0_body.cln64 ++ PRE_first_tail_x15_r0_body.cli64 ++ PRE_first_tail_x15_r0_body.cwS64 ++ PRE_first_tail_x15_r0_body.cnS64 ++ PRE_first_tail_x15_r0_body.ciS64).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW64 : PRE_first_tail_x15_r0_body.cwS64.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo64.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI64 : PRE_first_tail_x15_r0_body.ciS64.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli64.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN64 : PRE_first_tail_x15_r0_body.cnS64.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF64 : PRE_first_tail_x15_r0_body.cln64.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh64 : PRE_first_tail_x15_r0_body.clo64.all (handleOK PRE_first_tail_x15_r0_body.kappa64 PRE_first_tail_x15_r0_body.P64.lo PRE_first_tail_x15_r0_body.cx0_64.mlx PRE_first_tail_x15_r0_body.cx1_64.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo64 : PRE_first_tail_x15_r0_body.clo64.map (fun h => PRE_first_tail_x15_r0_body.cx1_64.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa64.handle h)) = PRE_first_tail_x15_r0_body.clo64.map (fun h => (PRE_first_tail_x15_r0_body.cx0_64.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa64.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok64 : PRE_first_tail_x15_r0_body.clo64.all (objOK PRE_first_tail_x15_r0_body.kappa64 PRE_first_tail_x15_r0_body.P64.NL PRE_first_tail_x15_r0_body.cx0_64.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd64 : PRE_first_tail_x15_r0_body.cln64.all (nodeOKF PRE_first_tail_x15_r0_body.kappa64 PRE_first_tail_x15_r0_body.P64 PRE_first_tail_x15_r0_body.cx0_64.mlx PRE_first_tail_x15_r0_body.cx1_64.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp64 : ((PRE_first_tail_x15_r0_body.cln64.filter (fullB PRE_first_tail_x15_r0_body.P64))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_64.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa64.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln64.filter (fullB PRE_first_tail_x15_r0_body.P64))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_64.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa64.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI64 : incrB PRE_first_tail_x15_r0_body.kd64.nodeF (List.range' 16566 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK64 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd64.node).all (fun k => Nat.ble 16566 k && Nat.blt k 16566) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL64 : (PRE_first_tail_x15_r0_body.cln64.filter (Nat.ble PRE_first_tail_x15_r0_body.P64.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd64.nodeF i) && (Nat.blt i 16566 || Nat.ble PRE_first_tail_x15_r0_body.kd64.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord64 : (PRE_first_tail_x15_r0_body.cln64.filter (Nat.ble PRE_first_tail_x15_r0_body.P64.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd64.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd64.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd64.nodeF j) (PRE_first_tail_x15_r0_body.kd64.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow64 PRE_first_tail_x15_r0_body.cnn164 PRE_first_tail_x15_r0_body.fnordI64 PRE_first_tail_x15_r0_body.fnordK64 PRE_first_tail_x15_r0_body.fnordL64
kernel_rfl PRE_first_tail_x15_r0_body.fi64 : PRE_first_tail_x15_r0_body.cli64.all (pnB PRE_first_tail_x15_r0_body.cx0_64.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii64 : PRE_first_tail_x15_r0_body.cli64.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_64.mlx.items.get (PRE_first_tail_x15_r0_body.kappa64.node k) = (PRE_first_tail_x15_r0_body.cx0_64.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa64.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot64 (clean : Conv.NClean (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P64.NL) (cl : SSt (· < 2816) PRE_first_tail_x15_r0_body.cx0_64.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P64 2816 PRE_first_tail_x15_r0_body.kappa64 PRE_first_tail_x15_r0_body.kd64 PRE_first_tail_x15_r0_body.khinv64 PRE_first_tail_x15_r0_body.kninv64 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx PRE_first_tail_x15_r0_body.cx0_64.mlx PRE_first_tail_x15_r0_body.cx1_64.mlx (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo64 PRE_first_tail_x15_r0_body.cln64 PRE_first_tail_x15_r0_body.cli64 PRE_first_tail_x15_r0_body.cwS64 PRE_first_tail_x15_r0_body.cnS64 PRE_first_tail_x15_r0_body.ciS64 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh064, PRE_first_tail_x15_r0_body.cnh164, PRE_first_tail_x15_r0_body.cnn064, PRE_first_tail_x15_r0_body.cnn164, PRE_first_tail_x15_r0_body.cplo64, PRE_first_tail_x15_r0_body.ccnt64, PRE_first_tail_x15_r0_body.cnband64, PRE_first_tail_x15_r0_body.chbelow64, PRE_first_tail_x15_r0_body.chren64, PRE_first_tail_x15_r0_body.cband64, PRE_first_tail_x15_r0_body.cnh1pos64, PRE_first_tail_x15_r0_body.cnren64, PRE_first_tail_x15_r0_body.cnlow64, PRE_first_tail_x15_r0_body.cabs0a64, PRE_first_tail_x15_r0_body.cabs0b64, PRE_first_tail_x15_r0_body.ctok164, PRE_first_tail_x15_r0_body.cpend64, PRE_first_tail_x15_r0_body.cerrh64, PRE_first_tail_x15_r0_body.cfiles64, PRE_first_tail_x15_r0_body.carch64, PRE_first_tail_x15_r0_body.csizes64, PRE_first_tail_x15_r0_body.cwired64, PRE_first_tail_x15_r0_body.cfix64, clean, PRE_first_tail_x15_r0_body.fcxn64, PRE_first_tail_x15_r0_body.fcnn64, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle064, PRE_first_tail_x15_r0_body.fnk64, PRE_first_tail_x15_r0_body.ckA64, PRE_first_tail_x15_r0_body.cobjsK64, PRE_first_tail_x15_r0_body.cnodesK64, PRE_first_tail_x15_r0_body.citemsK64, PRE_first_tail_x15_r0_body.f1A64, PRE_first_tail_x15_r0_body.f1O64, PRE_first_tail_x15_r0_body.f1N64, PRE_first_tail_x15_r0_body.f1I64, PRE_first_tail_x15_r0_body.fbd64, PRE_first_tail_x15_r0_body.fincW64, PRE_first_tail_x15_r0_body.fincI64, PRE_first_tail_x15_r0_body.fincN64, PRE_first_tail_x15_r0_body.flnF64, PRE_first_tail_x15_r0_body.fh64, PRE_first_tail_x15_r0_body.fo64, PRE_first_tail_x15_r0_body.fok64, PRE_first_tail_x15_r0_body.fnd64, PRE_first_tail_x15_r0_body.fp64, PRE_first_tail_x15_r0_body.fnord64, PRE_first_tail_x15_r0_body.fi64, PRE_first_tail_x15_r0_body.fii64⟩
theorem PRE_first_tail_x15_r0_body.cnshift64 (clean : Conv.NClean (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P64.NL) (cl : SSt (· < 2816) PRE_first_tail_x15_r0_body.cx0_64.mlx) : NShift PRE_first_tail_x15_r0_body.P64 2816 PRE_first_tail_x15_r0_body.kappa64 PRE_first_tail_x15_r0_body.cx0_64 PRE_first_tail_x15_r0_body.cx1_64 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot64 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost64 (compact_a_eq PRE_first_tail_x15_r0_body.ckn064 PRE_first_tail_x15_r0_body.ckn164 PRE_first_tail_x15_r0_body.ckheap64 PRE_first_tail_x15_r0_body.ckpl64)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_64 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s628.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_64 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s628.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_64 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s628.ffi) = some PRE_first_tail_x15_r0_body.fxC_64
kernel_rfl PRE_first_tail_x15_r0_body.okrC_64 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s628.ffi) = some PRE_first_tail_x15_r0_body.krC_64
noncomputable def PRE_first_tail_x15_r0_body.fx0_64 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s630.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_64 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s630.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_64 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s630.ffi) = some PRE_first_tail_x15_r0_body.fx0_64
kernel_rfl PRE_first_tail_x15_r0_body.okr0_64 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s630.ffi) = some PRE_first_tail_x15_r0_body.kr0_64
noncomputable def PRE_first_tail_x15_r0_body.fx1_64 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s629.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_64 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s629.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_64 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s629.ffi) = some PRE_first_tail_x15_r0_body.fx1_64
kernel_rfl PRE_first_tail_x15_r0_body.okr1_64 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s629.ffi) = some PRE_first_tail_x15_r0_body.kr1_64
kernel_rfl PRE_first_tail_x15_r0_body.ff064 : PRE_first_tail_x15_r0_body.fx0_64 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_64 (PRE_first_tail_x15_r0_body.clo64.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_64.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff164 : PRE_first_tail_x15_r0_body.fx1_64 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_64 (PRE_first_tail_x15_r0_body.cwS64.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_64.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck64 : freedLB PRE_first_tail_x15_r0_body.kappa64 PRE_first_tail_x15_r0_body.cx0_64.mlx PRE_first_tail_x15_r0_body.fx0_64 PRE_first_tail_x15_r0_body.fx1_64 PRE_first_tail_x15_r0_body.clo64 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf064 : PRE_first_tail_x15_r0_body.kr0_64.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_64.flags (PRE_first_tail_x15_r0_body.clo64.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_64.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt064 : PRE_first_tail_x15_r0_body.kr0_64.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_64.targs (PRE_first_tail_x15_r0_body.clo64.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_64.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf164 : PRE_first_tail_x15_r0_body.kr1_64.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_64.flags (PRE_first_tail_x15_r0_body.cwS64.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_64.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt164 : PRE_first_tail_x15_r0_body.kr1_64.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_64.targs (PRE_first_tail_x15_r0_body.cwS64.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_64.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck64 : krecLB PRE_first_tail_x15_r0_body.kappa64 2816 PRE_first_tail_x15_r0_body.cx0_64.mlx PRE_first_tail_x15_r0_body.kr0_64 PRE_first_tail_x15_r0_body.kr1_64 PRE_first_tail_x15_r0_body.clo64 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn64 : Nat.ble 2816 2816 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge64 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s629.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s630.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR64 : pendRegB PRE_first_tail_x15_r0_body.kappa64 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe64 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s629.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift64 (clean : Conv.NClean (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P64.NL) (cl : SSt (· < 2816) PRE_first_tail_x15_r0_body.cx0_64.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_64.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_64.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_64.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_64.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P64 2816 PRE_first_tail_x15_r0_body.kappa64 PRE_first_tail_x15_r0_body.s630.ffi PRE_first_tail_x15_r0_body.s629.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift64 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue64, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp64 t ht),
    PRE_first_tail_x15_r0_body.cbridge64,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s630.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s629.ffi) (PRE_first_tail_x15_r0_body.cfoot64 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_64 PRE_first_tail_x15_r0_body.ofx1_64 hobjC PRE_first_tail_x15_r0_body.ff064 PRE_first_tail_x15_r0_body.ff164 PRE_first_tail_x15_r0_body.ffck64,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s630.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s629.ffi) (PRE_first_tail_x15_r0_body.cfoot64 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_64 PRE_first_tail_x15_r0_body.okr1_64 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn64) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf064 PRE_first_tail_x15_r0_body.fkt064 PRE_first_tail_x15_r0_body.fkf164 PRE_first_tail_x15_r0_body.fkt164 PRE_first_tail_x15_r0_body.fkck64,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh064 PRE_first_tail_x15_r0_body.cnh164 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe64) PRE_first_tail_x15_r0_body.cpendR64⟩

end Host.Load.Run.Tpl

import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl71
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 71 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc71 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P71 : LoadP := PRE_first_tail_x15_r0_body.Pc71.raise 16681
kernel_rfl PRE_first_tail_x15_r0_body.craise71 : Nat.ble PRE_first_tail_x15_r0_body.Pc71.N0 16681 = true
theorem PRE_first_tail_x15_r0_body.raised71 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc71 PRE_first_tail_x15_r0_body.P71 :=
  .inr ⟨16681, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise71, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_71 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_71 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s629.ffi)
def PRE_first_tail_x15_r0_body.khinv71 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv71 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS71 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS71 : List Nat := List.range' 16681 0
def PRE_first_tail_x15_r0_body.ciS71 : List Nat := [] ++ List.range' 16681 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh071 : PRE_first_tail_x15_r0_body.kd71.nh0 = PRE_first_tail_x15_r0_body.cx0_71.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh171 : PRE_first_tail_x15_r0_body.kd71.nh1 = PRE_first_tail_x15_r0_body.cx1_71.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn071 : PRE_first_tail_x15_r0_body.kd71.nn0 = PRE_first_tail_x15_r0_body.cx0_71.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn171 : PRE_first_tail_x15_r0_body.kd71.nn1 = PRE_first_tail_x15_r0_body.cx1_71.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo71 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P71.lo && Nat.ble PRE_first_tail_x15_r0_body.P71.lo PRE_first_tail_x15_r0_body.cx0_71.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P71.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P71.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt71 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_71.mlx.next PRE_first_tail_x15_r0_body.cx1_71.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_71.mlx.nnext PRE_first_tail_x15_r0_body.cx1_71.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband71 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P71.NL && Nat.ble PRE_first_tail_x15_r0_body.P71.NL PRE_first_tail_x15_r0_body.P71.N0 && Nat.ble PRE_first_tail_x15_r0_body.P71.N0 PRE_first_tail_x15_r0_body.cx0_71.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow71 : PRE_first_tail_x15_r0_body.kd71.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren71 : checkRenG PRE_first_tail_x15_r0_body.kd71.hnd PRE_first_tail_x15_r0_body.khinv71 (phB PRE_first_tail_x15_r0_body.cx0_71.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband71 : PRE_first_tail_x15_r0_body.kd71.checkBand PRE_first_tail_x15_r0_body.P71.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos71 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd71.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren71 : checkRenG PRE_first_tail_x15_r0_body.kd71.node PRE_first_tail_x15_r0_body.kninv71 (pnB PRE_first_tail_x15_r0_body.cx0_71.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow71 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd71.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P71.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd71.nodeF j) PRE_first_tail_x15_r0_body.cx1_71.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a71 : PRE_first_tail_x15_r0_body.cx0_71.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b71 : PRE_first_tail_x15_r0_body.cx0_71.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok171 : PRE_first_tail_x15_r0_body.cx1_71.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend71 : PRE_first_tail_x15_r0_body.cx1_71.mlx.pending = PRE_first_tail_x15_r0_body.cx0_71.mlx.pending.map PRE_first_tail_x15_r0_body.kappa71.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh71 : PRE_first_tail_x15_r0_body.cx1_71.mlx.errh = PRE_first_tail_x15_r0_body.cx0_71.mlx.errh.map PRE_first_tail_x15_r0_body.kappa71.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles71 : PRE_first_tail_x15_r0_body.cx1_71.mlx.files = PRE_first_tail_x15_r0_body.cx0_71.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch71 : PRE_first_tail_x15_r0_body.cx1_71.mlx.arch = PRE_first_tail_x15_r0_body.cx0_71.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes71 : PRE_first_tail_x15_r0_body.cx1_71.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_71.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired71 : PRE_first_tail_x15_r0_body.cx1_71.mlx.wired = PRE_first_tail_x15_r0_body.cx0_71.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost71 : PRE_first_tail_x15_r0_body.cx1_71.host = PRE_first_tail_x15_r0_body.cx0_71.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd71`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn071 : PRE_first_tail_x15_r0_body.kd71.n0 = 2730466
kernel_rfl PRE_first_tail_x15_r0_body.ckn171 : PRE_first_tail_x15_r0_body.kd71.n1 = 2730476
kernel_rfl PRE_first_tail_x15_r0_body.ckheap71 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd71.heap).all (fun x => Nat.ble 2730465 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl71 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd71.heap.get (2730465 + j) = nth? PRE_first_tail_x15_r0_body.pl71 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja71 : Nat.ble 2730465 2730465 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn71 : Nat.ble 3088 3088 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD71 : Nat.ble 2730465 PRE_first_tail_x15_r0_body.kd71.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn71 : Nat.ble 19597 PRE_first_tail_x15_r0_body.kd71.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn71 : Nat.ble 16681 PRE_first_tail_x15_r0_body.kd71.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb71 : Nat.ble 19597 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap71 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd71.heap).all (Nat.ble (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd71 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd71.hnd).all (Nat.ble (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode71 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd71.node).all (Nat.ble (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix71 : Conv.FixOld (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa71 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja71) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn71) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD71) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn71) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn71) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb71) PRE_first_tail_x15_r0_body.fheap71 PRE_first_tail_x15_r0_body.fhnd71 PRE_first_tail_x15_r0_body.fnode71
kernel_rfl PRE_first_tail_x15_r0_body.fcxn71 : (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn71 : (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle071 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_71.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_71.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk71 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd71.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A71 : PRE_first_tail_x15_r0_body.cx1_71.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS71.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_71.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O71 : PRE_first_tail_x15_r0_body.cx1_71.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS71.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_71.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N71 : PRE_first_tail_x15_r0_body.cx1_71.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS71.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_71.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I71 : PRE_first_tail_x15_r0_body.cx1_71.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS71.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_71.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd71 : (PRE_first_tail_x15_r0_body.clo71 ++ PRE_first_tail_x15_r0_body.cln71 ++ PRE_first_tail_x15_r0_body.cli71 ++ PRE_first_tail_x15_r0_body.cwS71 ++ PRE_first_tail_x15_r0_body.cnS71 ++ PRE_first_tail_x15_r0_body.ciS71).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW71 : PRE_first_tail_x15_r0_body.cwS71.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo71.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI71 : PRE_first_tail_x15_r0_body.ciS71.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli71.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN71 : PRE_first_tail_x15_r0_body.cnS71.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF71 : PRE_first_tail_x15_r0_body.cln71.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh71 : PRE_first_tail_x15_r0_body.clo71.all (handleOK PRE_first_tail_x15_r0_body.kappa71 PRE_first_tail_x15_r0_body.P71.lo PRE_first_tail_x15_r0_body.cx0_71.mlx PRE_first_tail_x15_r0_body.cx1_71.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo71 : PRE_first_tail_x15_r0_body.clo71.map (fun h => PRE_first_tail_x15_r0_body.cx1_71.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa71.handle h)) = PRE_first_tail_x15_r0_body.clo71.map (fun h => (PRE_first_tail_x15_r0_body.cx0_71.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa71.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok71 : PRE_first_tail_x15_r0_body.clo71.all (objOK PRE_first_tail_x15_r0_body.kappa71 PRE_first_tail_x15_r0_body.P71.NL PRE_first_tail_x15_r0_body.cx0_71.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd71 : PRE_first_tail_x15_r0_body.cln71.all (nodeOKF PRE_first_tail_x15_r0_body.kappa71 PRE_first_tail_x15_r0_body.P71 PRE_first_tail_x15_r0_body.cx0_71.mlx PRE_first_tail_x15_r0_body.cx1_71.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp71 : ((PRE_first_tail_x15_r0_body.cln71.filter (fullB PRE_first_tail_x15_r0_body.P71))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_71.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa71.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln71.filter (fullB PRE_first_tail_x15_r0_body.P71))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_71.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa71.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI71 : incrB PRE_first_tail_x15_r0_body.kd71.nodeF (List.range' 16681 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK71 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd71.node).all (fun k => Nat.ble 16681 k && Nat.blt k 16681) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL71 : (PRE_first_tail_x15_r0_body.cln71.filter (Nat.ble PRE_first_tail_x15_r0_body.P71.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd71.nodeF i) && (Nat.blt i 16681 || Nat.ble PRE_first_tail_x15_r0_body.kd71.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord71 : (PRE_first_tail_x15_r0_body.cln71.filter (Nat.ble PRE_first_tail_x15_r0_body.P71.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd71.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd71.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd71.nodeF j) (PRE_first_tail_x15_r0_body.kd71.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow71 PRE_first_tail_x15_r0_body.cnn171 PRE_first_tail_x15_r0_body.fnordI71 PRE_first_tail_x15_r0_body.fnordK71 PRE_first_tail_x15_r0_body.fnordL71
kernel_rfl PRE_first_tail_x15_r0_body.fi71 : PRE_first_tail_x15_r0_body.cli71.all (pnB PRE_first_tail_x15_r0_body.cx0_71.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii71 : PRE_first_tail_x15_r0_body.cli71.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_71.mlx.items.get (PRE_first_tail_x15_r0_body.kappa71.node k) = (PRE_first_tail_x15_r0_body.cx0_71.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa71.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot71 (clean : Conv.NClean (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P71.NL) (cl : SSt (· < 3088) PRE_first_tail_x15_r0_body.cx0_71.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P71 3088 PRE_first_tail_x15_r0_body.kappa71 PRE_first_tail_x15_r0_body.kd71 PRE_first_tail_x15_r0_body.khinv71 PRE_first_tail_x15_r0_body.kninv71 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx PRE_first_tail_x15_r0_body.cx0_71.mlx PRE_first_tail_x15_r0_body.cx1_71.mlx (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo71 PRE_first_tail_x15_r0_body.cln71 PRE_first_tail_x15_r0_body.cli71 PRE_first_tail_x15_r0_body.cwS71 PRE_first_tail_x15_r0_body.cnS71 PRE_first_tail_x15_r0_body.ciS71 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh071, PRE_first_tail_x15_r0_body.cnh171, PRE_first_tail_x15_r0_body.cnn071, PRE_first_tail_x15_r0_body.cnn171, PRE_first_tail_x15_r0_body.cplo71, PRE_first_tail_x15_r0_body.ccnt71, PRE_first_tail_x15_r0_body.cnband71, PRE_first_tail_x15_r0_body.chbelow71, PRE_first_tail_x15_r0_body.chren71, PRE_first_tail_x15_r0_body.cband71, PRE_first_tail_x15_r0_body.cnh1pos71, PRE_first_tail_x15_r0_body.cnren71, PRE_first_tail_x15_r0_body.cnlow71, PRE_first_tail_x15_r0_body.cabs0a71, PRE_first_tail_x15_r0_body.cabs0b71, PRE_first_tail_x15_r0_body.ctok171, PRE_first_tail_x15_r0_body.cpend71, PRE_first_tail_x15_r0_body.cerrh71, PRE_first_tail_x15_r0_body.cfiles71, PRE_first_tail_x15_r0_body.carch71, PRE_first_tail_x15_r0_body.csizes71, PRE_first_tail_x15_r0_body.cwired71, PRE_first_tail_x15_r0_body.cfix71, clean, PRE_first_tail_x15_r0_body.fcxn71, PRE_first_tail_x15_r0_body.fcnn71, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle071, PRE_first_tail_x15_r0_body.fnk71, PRE_first_tail_x15_r0_body.ckA71, PRE_first_tail_x15_r0_body.cobjsK71, PRE_first_tail_x15_r0_body.cnodesK71, PRE_first_tail_x15_r0_body.citemsK71, PRE_first_tail_x15_r0_body.f1A71, PRE_first_tail_x15_r0_body.f1O71, PRE_first_tail_x15_r0_body.f1N71, PRE_first_tail_x15_r0_body.f1I71, PRE_first_tail_x15_r0_body.fbd71, PRE_first_tail_x15_r0_body.fincW71, PRE_first_tail_x15_r0_body.fincI71, PRE_first_tail_x15_r0_body.fincN71, PRE_first_tail_x15_r0_body.flnF71, PRE_first_tail_x15_r0_body.fh71, PRE_first_tail_x15_r0_body.fo71, PRE_first_tail_x15_r0_body.fok71, PRE_first_tail_x15_r0_body.fnd71, PRE_first_tail_x15_r0_body.fp71, PRE_first_tail_x15_r0_body.fnord71, PRE_first_tail_x15_r0_body.fi71, PRE_first_tail_x15_r0_body.fii71⟩
theorem PRE_first_tail_x15_r0_body.cnshift71 (clean : Conv.NClean (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P71.NL) (cl : SSt (· < 3088) PRE_first_tail_x15_r0_body.cx0_71.mlx) : NShift PRE_first_tail_x15_r0_body.P71 3088 PRE_first_tail_x15_r0_body.kappa71 PRE_first_tail_x15_r0_body.cx0_71 PRE_first_tail_x15_r0_body.cx1_71 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot71 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost71 (compact_a_eq PRE_first_tail_x15_r0_body.ckn071 PRE_first_tail_x15_r0_body.ckn171 PRE_first_tail_x15_r0_body.ckheap71 PRE_first_tail_x15_r0_body.ckpl71)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_71 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s628.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_71 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s628.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_71 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s628.ffi) = some PRE_first_tail_x15_r0_body.fxC_71
kernel_rfl PRE_first_tail_x15_r0_body.okrC_71 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s628.ffi) = some PRE_first_tail_x15_r0_body.krC_71
noncomputable def PRE_first_tail_x15_r0_body.fx0_71 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s630.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_71 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s630.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_71 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s630.ffi) = some PRE_first_tail_x15_r0_body.fx0_71
kernel_rfl PRE_first_tail_x15_r0_body.okr0_71 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s630.ffi) = some PRE_first_tail_x15_r0_body.kr0_71
noncomputable def PRE_first_tail_x15_r0_body.fx1_71 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s629.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_71 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s629.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_71 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s629.ffi) = some PRE_first_tail_x15_r0_body.fx1_71
kernel_rfl PRE_first_tail_x15_r0_body.okr1_71 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s629.ffi) = some PRE_first_tail_x15_r0_body.kr1_71
kernel_rfl PRE_first_tail_x15_r0_body.ff071 : PRE_first_tail_x15_r0_body.fx0_71 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_71 (PRE_first_tail_x15_r0_body.clo71.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_71.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff171 : PRE_first_tail_x15_r0_body.fx1_71 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_71 (PRE_first_tail_x15_r0_body.cwS71.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_71.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck71 : freedLB PRE_first_tail_x15_r0_body.kappa71 PRE_first_tail_x15_r0_body.cx0_71.mlx PRE_first_tail_x15_r0_body.fx0_71 PRE_first_tail_x15_r0_body.fx1_71 PRE_first_tail_x15_r0_body.clo71 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf071 : PRE_first_tail_x15_r0_body.kr0_71.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_71.flags (PRE_first_tail_x15_r0_body.clo71.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_71.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt071 : PRE_first_tail_x15_r0_body.kr0_71.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_71.targs (PRE_first_tail_x15_r0_body.clo71.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_71.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf171 : PRE_first_tail_x15_r0_body.kr1_71.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_71.flags (PRE_first_tail_x15_r0_body.cwS71.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_71.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt171 : PRE_first_tail_x15_r0_body.kr1_71.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_71.targs (PRE_first_tail_x15_r0_body.cwS71.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_71.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck71 : krecLB PRE_first_tail_x15_r0_body.kappa71 3088 PRE_first_tail_x15_r0_body.cx0_71.mlx PRE_first_tail_x15_r0_body.kr0_71 PRE_first_tail_x15_r0_body.kr1_71 PRE_first_tail_x15_r0_body.clo71 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn71 : Nat.ble 3088 3088 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge71 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s629.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s630.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR71 : pendRegB PRE_first_tail_x15_r0_body.kappa71 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe71 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s629.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift71 (clean : Conv.NClean (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P71.NL) (cl : SSt (· < 3088) PRE_first_tail_x15_r0_body.cx0_71.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_71.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_71.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_71.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_71.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P71 3088 PRE_first_tail_x15_r0_body.kappa71 PRE_first_tail_x15_r0_body.s630.ffi PRE_first_tail_x15_r0_body.s629.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift71 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue71, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp71 t ht),
    PRE_first_tail_x15_r0_body.cbridge71,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s630.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s629.ffi) (PRE_first_tail_x15_r0_body.cfoot71 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_71 PRE_first_tail_x15_r0_body.ofx1_71 hobjC PRE_first_tail_x15_r0_body.ff071 PRE_first_tail_x15_r0_body.ff171 PRE_first_tail_x15_r0_body.ffck71,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s630.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s629.ffi) (PRE_first_tail_x15_r0_body.cfoot71 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_71 PRE_first_tail_x15_r0_body.okr1_71 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn71) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf071 PRE_first_tail_x15_r0_body.fkt071 PRE_first_tail_x15_r0_body.fkf171 PRE_first_tail_x15_r0_body.fkt171 PRE_first_tail_x15_r0_body.fkck71,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh071 PRE_first_tail_x15_r0_body.cnh171 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe71) PRE_first_tail_x15_r0_body.cpendR71⟩

end Host.Load.Run.Tpl

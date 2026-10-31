import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl34
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 34 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc34 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P34 : LoadP := PRE_first_tail_x15_r0_body.Pc34.raise 15966
kernel_rfl PRE_first_tail_x15_r0_body.craise34 : Nat.ble PRE_first_tail_x15_r0_body.Pc34.N0 15966 = true
theorem PRE_first_tail_x15_r0_body.raised34 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc34 PRE_first_tail_x15_r0_body.P34 :=
  .inr ⟨15966, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise34, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_34 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s342.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_34 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s341.ffi)
def PRE_first_tail_x15_r0_body.khinv34 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv34 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS34 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS34 : List Nat := List.range' 15966 0
def PRE_first_tail_x15_r0_body.ciS34 : List Nat := [] ++ List.range' 15966 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh034 : PRE_first_tail_x15_r0_body.kd34.nh0 = PRE_first_tail_x15_r0_body.cx0_34.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh134 : PRE_first_tail_x15_r0_body.kd34.nh1 = PRE_first_tail_x15_r0_body.cx1_34.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn034 : PRE_first_tail_x15_r0_body.kd34.nn0 = PRE_first_tail_x15_r0_body.cx0_34.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn134 : PRE_first_tail_x15_r0_body.kd34.nn1 = PRE_first_tail_x15_r0_body.cx1_34.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo34 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P34.lo && Nat.ble PRE_first_tail_x15_r0_body.P34.lo PRE_first_tail_x15_r0_body.cx0_34.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P34.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P34.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt34 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_34.mlx.next PRE_first_tail_x15_r0_body.cx1_34.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_34.mlx.nnext PRE_first_tail_x15_r0_body.cx1_34.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband34 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P34.NL && Nat.ble PRE_first_tail_x15_r0_body.P34.NL PRE_first_tail_x15_r0_body.P34.N0 && Nat.ble PRE_first_tail_x15_r0_body.P34.N0 PRE_first_tail_x15_r0_body.cx0_34.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow34 : PRE_first_tail_x15_r0_body.kd34.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren34 : checkRenG PRE_first_tail_x15_r0_body.kd34.hnd PRE_first_tail_x15_r0_body.khinv34 (phB PRE_first_tail_x15_r0_body.cx0_34.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband34 : PRE_first_tail_x15_r0_body.kd34.checkBand PRE_first_tail_x15_r0_body.P34.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos34 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd34.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren34 : checkRenG PRE_first_tail_x15_r0_body.kd34.node PRE_first_tail_x15_r0_body.kninv34 (pnB PRE_first_tail_x15_r0_body.cx0_34.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow34 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd34.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P34.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd34.nodeF j) PRE_first_tail_x15_r0_body.cx1_34.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a34 : PRE_first_tail_x15_r0_body.cx0_34.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b34 : PRE_first_tail_x15_r0_body.cx0_34.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok134 : PRE_first_tail_x15_r0_body.cx1_34.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend34 : PRE_first_tail_x15_r0_body.cx1_34.mlx.pending = PRE_first_tail_x15_r0_body.cx0_34.mlx.pending.map PRE_first_tail_x15_r0_body.kappa34.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh34 : PRE_first_tail_x15_r0_body.cx1_34.mlx.errh = PRE_first_tail_x15_r0_body.cx0_34.mlx.errh.map PRE_first_tail_x15_r0_body.kappa34.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles34 : PRE_first_tail_x15_r0_body.cx1_34.mlx.files = PRE_first_tail_x15_r0_body.cx0_34.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch34 : PRE_first_tail_x15_r0_body.cx1_34.mlx.arch = PRE_first_tail_x15_r0_body.cx0_34.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes34 : PRE_first_tail_x15_r0_body.cx1_34.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_34.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired34 : PRE_first_tail_x15_r0_body.cx1_34.mlx.wired = PRE_first_tail_x15_r0_body.cx0_34.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost34 : PRE_first_tail_x15_r0_body.cx1_34.host = PRE_first_tail_x15_r0_body.cx0_34.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd34`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn034 : PRE_first_tail_x15_r0_body.kd34.n0 = 2701917
kernel_rfl PRE_first_tail_x15_r0_body.ckn134 : PRE_first_tail_x15_r0_body.kd34.n1 = 2701919
kernel_rfl PRE_first_tail_x15_r0_body.ckheap34 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd34.heap).all (fun x => Nat.ble 2701917 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl34 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd34.heap.get (2701917 + j) = nth? PRE_first_tail_x15_r0_body.pl34 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja34 : Nat.ble 2701917 2701917 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn34 : Nat.ble 1532 1532 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD34 : Nat.ble 2701917 PRE_first_tail_x15_r0_body.kd34.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn34 : Nat.ble 18882 PRE_first_tail_x15_r0_body.kd34.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn34 : Nat.ble 15966 PRE_first_tail_x15_r0_body.kd34.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb34 : Nat.ble 18882 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap34 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd34.heap).all (Nat.ble (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd34 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd34.hnd).all (Nat.ble (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode34 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd34.node).all (Nat.ble (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix34 : Conv.FixOld (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa34 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja34) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn34) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD34) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn34) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn34) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb34) PRE_first_tail_x15_r0_body.fheap34 PRE_first_tail_x15_r0_body.fhnd34 PRE_first_tail_x15_r0_body.fnode34
kernel_rfl PRE_first_tail_x15_r0_body.fcxn34 : (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn34 : (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle034 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_34.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_34.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk34 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd34.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A34 : PRE_first_tail_x15_r0_body.cx1_34.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS34.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_34.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O34 : PRE_first_tail_x15_r0_body.cx1_34.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS34.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_34.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N34 : PRE_first_tail_x15_r0_body.cx1_34.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS34.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_34.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I34 : PRE_first_tail_x15_r0_body.cx1_34.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS34.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_34.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd34 : (PRE_first_tail_x15_r0_body.clo34 ++ PRE_first_tail_x15_r0_body.cln34 ++ PRE_first_tail_x15_r0_body.cli34 ++ PRE_first_tail_x15_r0_body.cwS34 ++ PRE_first_tail_x15_r0_body.cnS34 ++ PRE_first_tail_x15_r0_body.ciS34).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW34 : PRE_first_tail_x15_r0_body.cwS34.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo34.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI34 : PRE_first_tail_x15_r0_body.ciS34.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli34.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN34 : PRE_first_tail_x15_r0_body.cnS34.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF34 : PRE_first_tail_x15_r0_body.cln34.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh34 : PRE_first_tail_x15_r0_body.clo34.all (handleOK PRE_first_tail_x15_r0_body.kappa34 PRE_first_tail_x15_r0_body.P34.lo PRE_first_tail_x15_r0_body.cx0_34.mlx PRE_first_tail_x15_r0_body.cx1_34.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo34 : PRE_first_tail_x15_r0_body.clo34.map (fun h => PRE_first_tail_x15_r0_body.cx1_34.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa34.handle h)) = PRE_first_tail_x15_r0_body.clo34.map (fun h => (PRE_first_tail_x15_r0_body.cx0_34.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa34.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok34 : PRE_first_tail_x15_r0_body.clo34.all (objOK PRE_first_tail_x15_r0_body.kappa34 PRE_first_tail_x15_r0_body.P34.NL PRE_first_tail_x15_r0_body.cx0_34.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd34 : PRE_first_tail_x15_r0_body.cln34.all (nodeOKF PRE_first_tail_x15_r0_body.kappa34 PRE_first_tail_x15_r0_body.P34 PRE_first_tail_x15_r0_body.cx0_34.mlx PRE_first_tail_x15_r0_body.cx1_34.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp34 : ((PRE_first_tail_x15_r0_body.cln34.filter (fullB PRE_first_tail_x15_r0_body.P34))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_34.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa34.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln34.filter (fullB PRE_first_tail_x15_r0_body.P34))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_34.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa34.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI34 : incrB PRE_first_tail_x15_r0_body.kd34.nodeF (List.range' 15966 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK34 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd34.node).all (fun k => Nat.ble 15966 k && Nat.blt k 15966) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL34 : (PRE_first_tail_x15_r0_body.cln34.filter (Nat.ble PRE_first_tail_x15_r0_body.P34.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd34.nodeF i) && (Nat.blt i 15966 || Nat.ble PRE_first_tail_x15_r0_body.kd34.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord34 : (PRE_first_tail_x15_r0_body.cln34.filter (Nat.ble PRE_first_tail_x15_r0_body.P34.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd34.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd34.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd34.nodeF j) (PRE_first_tail_x15_r0_body.kd34.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow34 PRE_first_tail_x15_r0_body.cnn134 PRE_first_tail_x15_r0_body.fnordI34 PRE_first_tail_x15_r0_body.fnordK34 PRE_first_tail_x15_r0_body.fnordL34
kernel_rfl PRE_first_tail_x15_r0_body.fi34 : PRE_first_tail_x15_r0_body.cli34.all (pnB PRE_first_tail_x15_r0_body.cx0_34.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii34 : PRE_first_tail_x15_r0_body.cli34.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_34.mlx.items.get (PRE_first_tail_x15_r0_body.kappa34.node k) = (PRE_first_tail_x15_r0_body.cx0_34.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa34.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot34 (clean : Conv.NClean (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P34.NL) (cl : SSt (· < 1532) PRE_first_tail_x15_r0_body.cx0_34.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P34 1532 PRE_first_tail_x15_r0_body.kappa34 PRE_first_tail_x15_r0_body.kd34 PRE_first_tail_x15_r0_body.khinv34 PRE_first_tail_x15_r0_body.kninv34 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx PRE_first_tail_x15_r0_body.cx0_34.mlx PRE_first_tail_x15_r0_body.cx1_34.mlx (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo34 PRE_first_tail_x15_r0_body.cln34 PRE_first_tail_x15_r0_body.cli34 PRE_first_tail_x15_r0_body.cwS34 PRE_first_tail_x15_r0_body.cnS34 PRE_first_tail_x15_r0_body.ciS34 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh034, PRE_first_tail_x15_r0_body.cnh134, PRE_first_tail_x15_r0_body.cnn034, PRE_first_tail_x15_r0_body.cnn134, PRE_first_tail_x15_r0_body.cplo34, PRE_first_tail_x15_r0_body.ccnt34, PRE_first_tail_x15_r0_body.cnband34, PRE_first_tail_x15_r0_body.chbelow34, PRE_first_tail_x15_r0_body.chren34, PRE_first_tail_x15_r0_body.cband34, PRE_first_tail_x15_r0_body.cnh1pos34, PRE_first_tail_x15_r0_body.cnren34, PRE_first_tail_x15_r0_body.cnlow34, PRE_first_tail_x15_r0_body.cabs0a34, PRE_first_tail_x15_r0_body.cabs0b34, PRE_first_tail_x15_r0_body.ctok134, PRE_first_tail_x15_r0_body.cpend34, PRE_first_tail_x15_r0_body.cerrh34, PRE_first_tail_x15_r0_body.cfiles34, PRE_first_tail_x15_r0_body.carch34, PRE_first_tail_x15_r0_body.csizes34, PRE_first_tail_x15_r0_body.cwired34, PRE_first_tail_x15_r0_body.cfix34, clean, PRE_first_tail_x15_r0_body.fcxn34, PRE_first_tail_x15_r0_body.fcnn34, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle034, PRE_first_tail_x15_r0_body.fnk34, PRE_first_tail_x15_r0_body.ckA34, PRE_first_tail_x15_r0_body.cobjsK34, PRE_first_tail_x15_r0_body.cnodesK34, PRE_first_tail_x15_r0_body.citemsK34, PRE_first_tail_x15_r0_body.f1A34, PRE_first_tail_x15_r0_body.f1O34, PRE_first_tail_x15_r0_body.f1N34, PRE_first_tail_x15_r0_body.f1I34, PRE_first_tail_x15_r0_body.fbd34, PRE_first_tail_x15_r0_body.fincW34, PRE_first_tail_x15_r0_body.fincI34, PRE_first_tail_x15_r0_body.fincN34, PRE_first_tail_x15_r0_body.flnF34, PRE_first_tail_x15_r0_body.fh34, PRE_first_tail_x15_r0_body.fo34, PRE_first_tail_x15_r0_body.fok34, PRE_first_tail_x15_r0_body.fnd34, PRE_first_tail_x15_r0_body.fp34, PRE_first_tail_x15_r0_body.fnord34, PRE_first_tail_x15_r0_body.fi34, PRE_first_tail_x15_r0_body.fii34⟩
theorem PRE_first_tail_x15_r0_body.cnshift34 (clean : Conv.NClean (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P34.NL) (cl : SSt (· < 1532) PRE_first_tail_x15_r0_body.cx0_34.mlx) : NShift PRE_first_tail_x15_r0_body.P34 1532 PRE_first_tail_x15_r0_body.kappa34 PRE_first_tail_x15_r0_body.cx0_34 PRE_first_tail_x15_r0_body.cx1_34 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot34 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost34 (compact_a_eq PRE_first_tail_x15_r0_body.ckn034 PRE_first_tail_x15_r0_body.ckn134 PRE_first_tail_x15_r0_body.ckheap34 PRE_first_tail_x15_r0_body.ckpl34)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_34 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s340.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_34 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s340.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_34 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s340.ffi) = some PRE_first_tail_x15_r0_body.fxC_34
kernel_rfl PRE_first_tail_x15_r0_body.okrC_34 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s340.ffi) = some PRE_first_tail_x15_r0_body.krC_34
noncomputable def PRE_first_tail_x15_r0_body.fx0_34 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s342.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_34 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s342.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_34 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s342.ffi) = some PRE_first_tail_x15_r0_body.fx0_34
kernel_rfl PRE_first_tail_x15_r0_body.okr0_34 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s342.ffi) = some PRE_first_tail_x15_r0_body.kr0_34
noncomputable def PRE_first_tail_x15_r0_body.fx1_34 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s341.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_34 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s341.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_34 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s341.ffi) = some PRE_first_tail_x15_r0_body.fx1_34
kernel_rfl PRE_first_tail_x15_r0_body.okr1_34 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s341.ffi) = some PRE_first_tail_x15_r0_body.kr1_34
kernel_rfl PRE_first_tail_x15_r0_body.ff034 : PRE_first_tail_x15_r0_body.fx0_34 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_34 (PRE_first_tail_x15_r0_body.clo34.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_34.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff134 : PRE_first_tail_x15_r0_body.fx1_34 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_34 (PRE_first_tail_x15_r0_body.cwS34.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_34.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck34 : freedLB PRE_first_tail_x15_r0_body.kappa34 PRE_first_tail_x15_r0_body.cx0_34.mlx PRE_first_tail_x15_r0_body.fx0_34 PRE_first_tail_x15_r0_body.fx1_34 PRE_first_tail_x15_r0_body.clo34 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf034 : PRE_first_tail_x15_r0_body.kr0_34.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_34.flags (PRE_first_tail_x15_r0_body.clo34.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_34.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt034 : PRE_first_tail_x15_r0_body.kr0_34.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_34.targs (PRE_first_tail_x15_r0_body.clo34.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_34.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf134 : PRE_first_tail_x15_r0_body.kr1_34.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_34.flags (PRE_first_tail_x15_r0_body.cwS34.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_34.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt134 : PRE_first_tail_x15_r0_body.kr1_34.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_34.targs (PRE_first_tail_x15_r0_body.cwS34.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_34.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck34 : krecLB PRE_first_tail_x15_r0_body.kappa34 1532 PRE_first_tail_x15_r0_body.cx0_34.mlx PRE_first_tail_x15_r0_body.kr0_34 PRE_first_tail_x15_r0_body.kr1_34 PRE_first_tail_x15_r0_body.clo34 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn34 : Nat.ble 1532 1532 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge34 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s341.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s342.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR34 : pendRegB PRE_first_tail_x15_r0_body.kappa34 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s342.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe34 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s342.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s341.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift34 (clean : Conv.NClean (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P34.NL) (cl : SSt (· < 1532) PRE_first_tail_x15_r0_body.cx0_34.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_34.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_34.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_34.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_34.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P34 1532 PRE_first_tail_x15_r0_body.kappa34 PRE_first_tail_x15_r0_body.s342.ffi PRE_first_tail_x15_r0_body.s341.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift34 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue34, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp34 t ht),
    PRE_first_tail_x15_r0_body.cbridge34,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s342.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s341.ffi) (PRE_first_tail_x15_r0_body.cfoot34 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_34 PRE_first_tail_x15_r0_body.ofx1_34 hobjC PRE_first_tail_x15_r0_body.ff034 PRE_first_tail_x15_r0_body.ff134 PRE_first_tail_x15_r0_body.ffck34,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s342.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s341.ffi) (PRE_first_tail_x15_r0_body.cfoot34 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_34 PRE_first_tail_x15_r0_body.okr1_34 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn34) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf034 PRE_first_tail_x15_r0_body.fkt034 PRE_first_tail_x15_r0_body.fkf134 PRE_first_tail_x15_r0_body.fkt134 PRE_first_tail_x15_r0_body.fkck34,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh034 PRE_first_tail_x15_r0_body.cnh134 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe34) PRE_first_tail_x15_r0_body.cpendR34⟩

end Host.Load.Run.Tpl

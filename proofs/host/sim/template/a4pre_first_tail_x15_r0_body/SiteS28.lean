import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl28
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 28 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc28 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P28 : LoadP := PRE_first_tail_x15_r0_body.Pc28.raise 15855
kernel_rfl PRE_first_tail_x15_r0_body.craise28 : Nat.ble PRE_first_tail_x15_r0_body.Pc28.N0 15855 = true
theorem PRE_first_tail_x15_r0_body.raised28 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc28 PRE_first_tail_x15_r0_body.P28 :=
  .inr ⟨15855, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise28, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_28 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s260.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_28 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s259.ffi)
def PRE_first_tail_x15_r0_body.khinv28 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv28 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS28 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS28 : List Nat := List.range' 15855 0
def PRE_first_tail_x15_r0_body.ciS28 : List Nat := [] ++ List.range' 15855 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh028 : PRE_first_tail_x15_r0_body.kd28.nh0 = PRE_first_tail_x15_r0_body.cx0_28.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh128 : PRE_first_tail_x15_r0_body.kd28.nh1 = PRE_first_tail_x15_r0_body.cx1_28.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn028 : PRE_first_tail_x15_r0_body.kd28.nn0 = PRE_first_tail_x15_r0_body.cx0_28.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn128 : PRE_first_tail_x15_r0_body.kd28.nn1 = PRE_first_tail_x15_r0_body.cx1_28.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo28 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P28.lo && Nat.ble PRE_first_tail_x15_r0_body.P28.lo PRE_first_tail_x15_r0_body.cx0_28.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P28.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P28.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt28 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_28.mlx.next PRE_first_tail_x15_r0_body.cx1_28.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_28.mlx.nnext PRE_first_tail_x15_r0_body.cx1_28.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband28 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P28.NL && Nat.ble PRE_first_tail_x15_r0_body.P28.NL PRE_first_tail_x15_r0_body.P28.N0 && Nat.ble PRE_first_tail_x15_r0_body.P28.N0 PRE_first_tail_x15_r0_body.cx0_28.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow28 : PRE_first_tail_x15_r0_body.kd28.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren28 : checkRenG PRE_first_tail_x15_r0_body.kd28.hnd PRE_first_tail_x15_r0_body.khinv28 (phB PRE_first_tail_x15_r0_body.cx0_28.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband28 : PRE_first_tail_x15_r0_body.kd28.checkBand PRE_first_tail_x15_r0_body.P28.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos28 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd28.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren28 : checkRenG PRE_first_tail_x15_r0_body.kd28.node PRE_first_tail_x15_r0_body.kninv28 (pnB PRE_first_tail_x15_r0_body.cx0_28.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow28 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd28.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P28.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd28.nodeF j) PRE_first_tail_x15_r0_body.cx1_28.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a28 : PRE_first_tail_x15_r0_body.cx0_28.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b28 : PRE_first_tail_x15_r0_body.cx0_28.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok128 : PRE_first_tail_x15_r0_body.cx1_28.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend28 : PRE_first_tail_x15_r0_body.cx1_28.mlx.pending = PRE_first_tail_x15_r0_body.cx0_28.mlx.pending.map PRE_first_tail_x15_r0_body.kappa28.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh28 : PRE_first_tail_x15_r0_body.cx1_28.mlx.errh = PRE_first_tail_x15_r0_body.cx0_28.mlx.errh.map PRE_first_tail_x15_r0_body.kappa28.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles28 : PRE_first_tail_x15_r0_body.cx1_28.mlx.files = PRE_first_tail_x15_r0_body.cx0_28.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch28 : PRE_first_tail_x15_r0_body.cx1_28.mlx.arch = PRE_first_tail_x15_r0_body.cx0_28.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes28 : PRE_first_tail_x15_r0_body.cx1_28.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_28.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired28 : PRE_first_tail_x15_r0_body.cx1_28.mlx.wired = PRE_first_tail_x15_r0_body.cx0_28.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost28 : PRE_first_tail_x15_r0_body.cx1_28.host = PRE_first_tail_x15_r0_body.cx0_28.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd28`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn028 : PRE_first_tail_x15_r0_body.kd28.n0 = 2697039
kernel_rfl PRE_first_tail_x15_r0_body.ckn128 : PRE_first_tail_x15_r0_body.kd28.n1 = 2697041
kernel_rfl PRE_first_tail_x15_r0_body.ckheap28 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd28.heap).all (fun x => Nat.ble 2697039 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl28 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd28.heap.get (2697039 + j) = nth? PRE_first_tail_x15_r0_body.pl28 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja28 : Nat.ble 2697039 2697039 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn28 : Nat.ble 1277 1277 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD28 : Nat.ble 2697039 PRE_first_tail_x15_r0_body.kd28.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn28 : Nat.ble 18761 PRE_first_tail_x15_r0_body.kd28.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn28 : Nat.ble 15855 PRE_first_tail_x15_r0_body.kd28.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb28 : Nat.ble 18761 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap28 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd28.heap).all (Nat.ble (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd28 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd28.hnd).all (Nat.ble (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode28 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd28.node).all (Nat.ble (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix28 : Conv.FixOld (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa28 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja28) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn28) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD28) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn28) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn28) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb28) PRE_first_tail_x15_r0_body.fheap28 PRE_first_tail_x15_r0_body.fhnd28 PRE_first_tail_x15_r0_body.fnode28
kernel_rfl PRE_first_tail_x15_r0_body.fcxn28 : (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn28 : (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle028 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_28.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_28.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk28 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd28.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A28 : PRE_first_tail_x15_r0_body.cx1_28.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS28.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_28.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O28 : PRE_first_tail_x15_r0_body.cx1_28.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS28.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_28.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N28 : PRE_first_tail_x15_r0_body.cx1_28.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS28.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_28.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I28 : PRE_first_tail_x15_r0_body.cx1_28.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS28.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_28.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd28 : (PRE_first_tail_x15_r0_body.clo28 ++ PRE_first_tail_x15_r0_body.cln28 ++ PRE_first_tail_x15_r0_body.cli28 ++ PRE_first_tail_x15_r0_body.cwS28 ++ PRE_first_tail_x15_r0_body.cnS28 ++ PRE_first_tail_x15_r0_body.ciS28).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW28 : PRE_first_tail_x15_r0_body.cwS28.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo28.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI28 : PRE_first_tail_x15_r0_body.ciS28.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli28.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN28 : PRE_first_tail_x15_r0_body.cnS28.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF28 : PRE_first_tail_x15_r0_body.cln28.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh28 : PRE_first_tail_x15_r0_body.clo28.all (handleOK PRE_first_tail_x15_r0_body.kappa28 PRE_first_tail_x15_r0_body.P28.lo PRE_first_tail_x15_r0_body.cx0_28.mlx PRE_first_tail_x15_r0_body.cx1_28.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo28 : PRE_first_tail_x15_r0_body.clo28.map (fun h => PRE_first_tail_x15_r0_body.cx1_28.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa28.handle h)) = PRE_first_tail_x15_r0_body.clo28.map (fun h => (PRE_first_tail_x15_r0_body.cx0_28.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa28.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok28 : PRE_first_tail_x15_r0_body.clo28.all (objOK PRE_first_tail_x15_r0_body.kappa28 PRE_first_tail_x15_r0_body.P28.NL PRE_first_tail_x15_r0_body.cx0_28.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd28 : PRE_first_tail_x15_r0_body.cln28.all (nodeOKF PRE_first_tail_x15_r0_body.kappa28 PRE_first_tail_x15_r0_body.P28 PRE_first_tail_x15_r0_body.cx0_28.mlx PRE_first_tail_x15_r0_body.cx1_28.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp28 : ((PRE_first_tail_x15_r0_body.cln28.filter (fullB PRE_first_tail_x15_r0_body.P28))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_28.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa28.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln28.filter (fullB PRE_first_tail_x15_r0_body.P28))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_28.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa28.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI28 : incrB PRE_first_tail_x15_r0_body.kd28.nodeF (List.range' 15855 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK28 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd28.node).all (fun k => Nat.ble 15855 k && Nat.blt k 15855) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL28 : (PRE_first_tail_x15_r0_body.cln28.filter (Nat.ble PRE_first_tail_x15_r0_body.P28.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd28.nodeF i) && (Nat.blt i 15855 || Nat.ble PRE_first_tail_x15_r0_body.kd28.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord28 : (PRE_first_tail_x15_r0_body.cln28.filter (Nat.ble PRE_first_tail_x15_r0_body.P28.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd28.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd28.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd28.nodeF j) (PRE_first_tail_x15_r0_body.kd28.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow28 PRE_first_tail_x15_r0_body.cnn128 PRE_first_tail_x15_r0_body.fnordI28 PRE_first_tail_x15_r0_body.fnordK28 PRE_first_tail_x15_r0_body.fnordL28
kernel_rfl PRE_first_tail_x15_r0_body.fi28 : PRE_first_tail_x15_r0_body.cli28.all (pnB PRE_first_tail_x15_r0_body.cx0_28.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii28 : PRE_first_tail_x15_r0_body.cli28.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_28.mlx.items.get (PRE_first_tail_x15_r0_body.kappa28.node k) = (PRE_first_tail_x15_r0_body.cx0_28.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa28.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot28 (clean : Conv.NClean (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P28.NL) (cl : SSt (· < 1277) PRE_first_tail_x15_r0_body.cx0_28.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P28 1277 PRE_first_tail_x15_r0_body.kappa28 PRE_first_tail_x15_r0_body.kd28 PRE_first_tail_x15_r0_body.khinv28 PRE_first_tail_x15_r0_body.kninv28 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx PRE_first_tail_x15_r0_body.cx0_28.mlx PRE_first_tail_x15_r0_body.cx1_28.mlx (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo28 PRE_first_tail_x15_r0_body.cln28 PRE_first_tail_x15_r0_body.cli28 PRE_first_tail_x15_r0_body.cwS28 PRE_first_tail_x15_r0_body.cnS28 PRE_first_tail_x15_r0_body.ciS28 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh028, PRE_first_tail_x15_r0_body.cnh128, PRE_first_tail_x15_r0_body.cnn028, PRE_first_tail_x15_r0_body.cnn128, PRE_first_tail_x15_r0_body.cplo28, PRE_first_tail_x15_r0_body.ccnt28, PRE_first_tail_x15_r0_body.cnband28, PRE_first_tail_x15_r0_body.chbelow28, PRE_first_tail_x15_r0_body.chren28, PRE_first_tail_x15_r0_body.cband28, PRE_first_tail_x15_r0_body.cnh1pos28, PRE_first_tail_x15_r0_body.cnren28, PRE_first_tail_x15_r0_body.cnlow28, PRE_first_tail_x15_r0_body.cabs0a28, PRE_first_tail_x15_r0_body.cabs0b28, PRE_first_tail_x15_r0_body.ctok128, PRE_first_tail_x15_r0_body.cpend28, PRE_first_tail_x15_r0_body.cerrh28, PRE_first_tail_x15_r0_body.cfiles28, PRE_first_tail_x15_r0_body.carch28, PRE_first_tail_x15_r0_body.csizes28, PRE_first_tail_x15_r0_body.cwired28, PRE_first_tail_x15_r0_body.cfix28, clean, PRE_first_tail_x15_r0_body.fcxn28, PRE_first_tail_x15_r0_body.fcnn28, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle028, PRE_first_tail_x15_r0_body.fnk28, PRE_first_tail_x15_r0_body.ckA28, PRE_first_tail_x15_r0_body.cobjsK28, PRE_first_tail_x15_r0_body.cnodesK28, PRE_first_tail_x15_r0_body.citemsK28, PRE_first_tail_x15_r0_body.f1A28, PRE_first_tail_x15_r0_body.f1O28, PRE_first_tail_x15_r0_body.f1N28, PRE_first_tail_x15_r0_body.f1I28, PRE_first_tail_x15_r0_body.fbd28, PRE_first_tail_x15_r0_body.fincW28, PRE_first_tail_x15_r0_body.fincI28, PRE_first_tail_x15_r0_body.fincN28, PRE_first_tail_x15_r0_body.flnF28, PRE_first_tail_x15_r0_body.fh28, PRE_first_tail_x15_r0_body.fo28, PRE_first_tail_x15_r0_body.fok28, PRE_first_tail_x15_r0_body.fnd28, PRE_first_tail_x15_r0_body.fp28, PRE_first_tail_x15_r0_body.fnord28, PRE_first_tail_x15_r0_body.fi28, PRE_first_tail_x15_r0_body.fii28⟩
theorem PRE_first_tail_x15_r0_body.cnshift28 (clean : Conv.NClean (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P28.NL) (cl : SSt (· < 1277) PRE_first_tail_x15_r0_body.cx0_28.mlx) : NShift PRE_first_tail_x15_r0_body.P28 1277 PRE_first_tail_x15_r0_body.kappa28 PRE_first_tail_x15_r0_body.cx0_28 PRE_first_tail_x15_r0_body.cx1_28 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot28 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost28 (compact_a_eq PRE_first_tail_x15_r0_body.ckn028 PRE_first_tail_x15_r0_body.ckn128 PRE_first_tail_x15_r0_body.ckheap28 PRE_first_tail_x15_r0_body.ckpl28)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_28 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s258.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_28 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s258.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_28 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s258.ffi) = some PRE_first_tail_x15_r0_body.fxC_28
kernel_rfl PRE_first_tail_x15_r0_body.okrC_28 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s258.ffi) = some PRE_first_tail_x15_r0_body.krC_28
noncomputable def PRE_first_tail_x15_r0_body.fx0_28 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s260.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_28 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s260.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_28 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s260.ffi) = some PRE_first_tail_x15_r0_body.fx0_28
kernel_rfl PRE_first_tail_x15_r0_body.okr0_28 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s260.ffi) = some PRE_first_tail_x15_r0_body.kr0_28
noncomputable def PRE_first_tail_x15_r0_body.fx1_28 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s259.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_28 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s259.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_28 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s259.ffi) = some PRE_first_tail_x15_r0_body.fx1_28
kernel_rfl PRE_first_tail_x15_r0_body.okr1_28 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s259.ffi) = some PRE_first_tail_x15_r0_body.kr1_28
kernel_rfl PRE_first_tail_x15_r0_body.ff028 : PRE_first_tail_x15_r0_body.fx0_28 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_28 (PRE_first_tail_x15_r0_body.clo28.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_28.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff128 : PRE_first_tail_x15_r0_body.fx1_28 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_28 (PRE_first_tail_x15_r0_body.cwS28.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_28.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck28 : freedLB PRE_first_tail_x15_r0_body.kappa28 PRE_first_tail_x15_r0_body.cx0_28.mlx PRE_first_tail_x15_r0_body.fx0_28 PRE_first_tail_x15_r0_body.fx1_28 PRE_first_tail_x15_r0_body.clo28 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf028 : PRE_first_tail_x15_r0_body.kr0_28.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_28.flags (PRE_first_tail_x15_r0_body.clo28.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_28.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt028 : PRE_first_tail_x15_r0_body.kr0_28.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_28.targs (PRE_first_tail_x15_r0_body.clo28.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_28.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf128 : PRE_first_tail_x15_r0_body.kr1_28.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_28.flags (PRE_first_tail_x15_r0_body.cwS28.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_28.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt128 : PRE_first_tail_x15_r0_body.kr1_28.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_28.targs (PRE_first_tail_x15_r0_body.cwS28.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_28.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck28 : krecLB PRE_first_tail_x15_r0_body.kappa28 1277 PRE_first_tail_x15_r0_body.cx0_28.mlx PRE_first_tail_x15_r0_body.kr0_28 PRE_first_tail_x15_r0_body.kr1_28 PRE_first_tail_x15_r0_body.clo28 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn28 : Nat.ble 1277 1277 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge28 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s259.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s260.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR28 : pendRegB PRE_first_tail_x15_r0_body.kappa28 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s260.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe28 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s260.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s259.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift28 (clean : Conv.NClean (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P28.NL) (cl : SSt (· < 1277) PRE_first_tail_x15_r0_body.cx0_28.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_28.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_28.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_28.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_28.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P28 1277 PRE_first_tail_x15_r0_body.kappa28 PRE_first_tail_x15_r0_body.s260.ffi PRE_first_tail_x15_r0_body.s259.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift28 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue28, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp28 t ht),
    PRE_first_tail_x15_r0_body.cbridge28,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s260.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s259.ffi) (PRE_first_tail_x15_r0_body.cfoot28 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_28 PRE_first_tail_x15_r0_body.ofx1_28 hobjC PRE_first_tail_x15_r0_body.ff028 PRE_first_tail_x15_r0_body.ff128 PRE_first_tail_x15_r0_body.ffck28,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s260.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s259.ffi) (PRE_first_tail_x15_r0_body.cfoot28 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_28 PRE_first_tail_x15_r0_body.okr1_28 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn28) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf028 PRE_first_tail_x15_r0_body.fkt028 PRE_first_tail_x15_r0_body.fkf128 PRE_first_tail_x15_r0_body.fkt128 PRE_first_tail_x15_r0_body.fkck28,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh028 PRE_first_tail_x15_r0_body.cnh128 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe28) PRE_first_tail_x15_r0_body.cpendR28⟩

end Host.Load.Run.Tpl

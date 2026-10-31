import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl185
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 185 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc185 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P185 : LoadP := PRE_first_tail_x15_r0_body.Pc185.raise 18940
kernel_rfl PRE_first_tail_x15_r0_body.craise185 : Nat.ble PRE_first_tail_x15_r0_body.Pc185.N0 18940 = true
theorem PRE_first_tail_x15_r0_body.raised185 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc185 PRE_first_tail_x15_r0_body.P185 :=
  .inr ⟨18940, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise185, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_185 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1629.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_185 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1628.ffi)
def PRE_first_tail_x15_r0_body.khinv185 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv185 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS185 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS185 : List Nat := List.range' 18940 0
def PRE_first_tail_x15_r0_body.ciS185 : List Nat := [] ++ List.range' 18940 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0185 : PRE_first_tail_x15_r0_body.kd185.nh0 = PRE_first_tail_x15_r0_body.cx0_185.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1185 : PRE_first_tail_x15_r0_body.kd185.nh1 = PRE_first_tail_x15_r0_body.cx1_185.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0185 : PRE_first_tail_x15_r0_body.kd185.nn0 = PRE_first_tail_x15_r0_body.cx0_185.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1185 : PRE_first_tail_x15_r0_body.kd185.nn1 = PRE_first_tail_x15_r0_body.cx1_185.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo185 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P185.lo && Nat.ble PRE_first_tail_x15_r0_body.P185.lo PRE_first_tail_x15_r0_body.cx0_185.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P185.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P185.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt185 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_185.mlx.next PRE_first_tail_x15_r0_body.cx1_185.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_185.mlx.nnext PRE_first_tail_x15_r0_body.cx1_185.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband185 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P185.NL && Nat.ble PRE_first_tail_x15_r0_body.P185.NL PRE_first_tail_x15_r0_body.P185.N0 && Nat.ble PRE_first_tail_x15_r0_body.P185.N0 PRE_first_tail_x15_r0_body.cx0_185.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow185 : PRE_first_tail_x15_r0_body.kd185.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren185 : checkRenG PRE_first_tail_x15_r0_body.kd185.hnd PRE_first_tail_x15_r0_body.khinv185 (phB PRE_first_tail_x15_r0_body.cx0_185.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband185 : PRE_first_tail_x15_r0_body.kd185.checkBand PRE_first_tail_x15_r0_body.P185.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos185 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd185.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren185 : checkRenG PRE_first_tail_x15_r0_body.kd185.node PRE_first_tail_x15_r0_body.kninv185 (pnB PRE_first_tail_x15_r0_body.cx0_185.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow185 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd185.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P185.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd185.nodeF j) PRE_first_tail_x15_r0_body.cx1_185.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a185 : PRE_first_tail_x15_r0_body.cx0_185.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b185 : PRE_first_tail_x15_r0_body.cx0_185.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1185 : PRE_first_tail_x15_r0_body.cx1_185.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend185 : PRE_first_tail_x15_r0_body.cx1_185.mlx.pending = PRE_first_tail_x15_r0_body.cx0_185.mlx.pending.map PRE_first_tail_x15_r0_body.kappa185.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh185 : PRE_first_tail_x15_r0_body.cx1_185.mlx.errh = PRE_first_tail_x15_r0_body.cx0_185.mlx.errh.map PRE_first_tail_x15_r0_body.kappa185.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles185 : PRE_first_tail_x15_r0_body.cx1_185.mlx.files = PRE_first_tail_x15_r0_body.cx0_185.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch185 : PRE_first_tail_x15_r0_body.cx1_185.mlx.arch = PRE_first_tail_x15_r0_body.cx0_185.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes185 : PRE_first_tail_x15_r0_body.cx1_185.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_185.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired185 : PRE_first_tail_x15_r0_body.cx1_185.mlx.wired = PRE_first_tail_x15_r0_body.cx0_185.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost185 : PRE_first_tail_x15_r0_body.cx1_185.host = PRE_first_tail_x15_r0_body.cx0_185.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd185`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0185 : PRE_first_tail_x15_r0_body.kd185.n0 = 2819772
kernel_rfl PRE_first_tail_x15_r0_body.ckn1185 : PRE_first_tail_x15_r0_body.kd185.n1 = 2819791
kernel_rfl PRE_first_tail_x15_r0_body.ckheap185 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd185.heap).all (fun x => Nat.ble 2819771 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl185 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd185.heap.get (2819771 + j) = nth? PRE_first_tail_x15_r0_body.pl185 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja185 : Nat.ble 2819771 2819771 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn185 : Nat.ble 7963 7963 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD185 : Nat.ble 2819771 PRE_first_tail_x15_r0_body.kd185.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn185 : Nat.ble 21836 PRE_first_tail_x15_r0_body.kd185.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn185 : Nat.ble 18940 PRE_first_tail_x15_r0_body.kd185.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb185 : Nat.ble 21836 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap185 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd185.heap).all (Nat.ble (⟨21836, 18940, 2819771, 7963⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd185 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd185.hnd).all (Nat.ble (⟨21836, 18940, 2819771, 7963⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode185 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd185.node).all (Nat.ble (⟨21836, 18940, 2819771, 7963⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix185 : Conv.FixOld (⟨21836, 18940, 2819771, 7963⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa185 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja185) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn185) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD185) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn185) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn185) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb185) PRE_first_tail_x15_r0_body.fheap185 PRE_first_tail_x15_r0_body.fhnd185 PRE_first_tail_x15_r0_body.fnode185
kernel_rfl PRE_first_tail_x15_r0_body.fcxn185 : (⟨21836, 18940, 2819771, 7963⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn185 : (⟨21836, 18940, 2819771, 7963⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0185 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_185.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_185.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk185 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd185.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A185 : PRE_first_tail_x15_r0_body.cx1_185.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS185.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_185.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O185 : PRE_first_tail_x15_r0_body.cx1_185.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS185.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_185.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N185 : PRE_first_tail_x15_r0_body.cx1_185.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS185.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_185.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I185 : PRE_first_tail_x15_r0_body.cx1_185.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS185.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_185.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd185 : (PRE_first_tail_x15_r0_body.clo185 ++ PRE_first_tail_x15_r0_body.cln185 ++ PRE_first_tail_x15_r0_body.cli185 ++ PRE_first_tail_x15_r0_body.cwS185 ++ PRE_first_tail_x15_r0_body.cnS185 ++ PRE_first_tail_x15_r0_body.ciS185).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW185 : PRE_first_tail_x15_r0_body.cwS185.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo185.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI185 : PRE_first_tail_x15_r0_body.ciS185.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli185.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN185 : PRE_first_tail_x15_r0_body.cnS185.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF185 : PRE_first_tail_x15_r0_body.cln185.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh185 : PRE_first_tail_x15_r0_body.clo185.all (handleOK PRE_first_tail_x15_r0_body.kappa185 PRE_first_tail_x15_r0_body.P185.lo PRE_first_tail_x15_r0_body.cx0_185.mlx PRE_first_tail_x15_r0_body.cx1_185.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo185 : PRE_first_tail_x15_r0_body.clo185.map (fun h => PRE_first_tail_x15_r0_body.cx1_185.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa185.handle h)) = PRE_first_tail_x15_r0_body.clo185.map (fun h => (PRE_first_tail_x15_r0_body.cx0_185.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa185.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok185 : PRE_first_tail_x15_r0_body.clo185.all (objOK PRE_first_tail_x15_r0_body.kappa185 PRE_first_tail_x15_r0_body.P185.NL PRE_first_tail_x15_r0_body.cx0_185.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd185 : PRE_first_tail_x15_r0_body.cln185.all (nodeOKF PRE_first_tail_x15_r0_body.kappa185 PRE_first_tail_x15_r0_body.P185 PRE_first_tail_x15_r0_body.cx0_185.mlx PRE_first_tail_x15_r0_body.cx1_185.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp185 : ((PRE_first_tail_x15_r0_body.cln185.filter (fullB PRE_first_tail_x15_r0_body.P185))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_185.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa185.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln185.filter (fullB PRE_first_tail_x15_r0_body.P185))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_185.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa185.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI185 : incrB PRE_first_tail_x15_r0_body.kd185.nodeF (List.range' 18940 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK185 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd185.node).all (fun k => Nat.ble 18940 k && Nat.blt k 18940) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL185 : (PRE_first_tail_x15_r0_body.cln185.filter (Nat.ble PRE_first_tail_x15_r0_body.P185.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd185.nodeF i) && (Nat.blt i 18940 || Nat.ble PRE_first_tail_x15_r0_body.kd185.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord185 : (PRE_first_tail_x15_r0_body.cln185.filter (Nat.ble PRE_first_tail_x15_r0_body.P185.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd185.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd185.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd185.nodeF j) (PRE_first_tail_x15_r0_body.kd185.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow185 PRE_first_tail_x15_r0_body.cnn1185 PRE_first_tail_x15_r0_body.fnordI185 PRE_first_tail_x15_r0_body.fnordK185 PRE_first_tail_x15_r0_body.fnordL185
kernel_rfl PRE_first_tail_x15_r0_body.fi185 : PRE_first_tail_x15_r0_body.cli185.all (pnB PRE_first_tail_x15_r0_body.cx0_185.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii185 : PRE_first_tail_x15_r0_body.cli185.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_185.mlx.items.get (PRE_first_tail_x15_r0_body.kappa185.node k) = (PRE_first_tail_x15_r0_body.cx0_185.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa185.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot185 (clean : Conv.NClean (⟨21836, 18940, 2819771, 7963⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P185.NL) (cl : SSt (· < 7963) PRE_first_tail_x15_r0_body.cx0_185.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P185 7963 PRE_first_tail_x15_r0_body.kappa185 PRE_first_tail_x15_r0_body.kd185 PRE_first_tail_x15_r0_body.khinv185 PRE_first_tail_x15_r0_body.kninv185 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx PRE_first_tail_x15_r0_body.cx0_185.mlx PRE_first_tail_x15_r0_body.cx1_185.mlx (⟨21836, 18940, 2819771, 7963⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo185 PRE_first_tail_x15_r0_body.cln185 PRE_first_tail_x15_r0_body.cli185 PRE_first_tail_x15_r0_body.cwS185 PRE_first_tail_x15_r0_body.cnS185 PRE_first_tail_x15_r0_body.ciS185 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0185, PRE_first_tail_x15_r0_body.cnh1185, PRE_first_tail_x15_r0_body.cnn0185, PRE_first_tail_x15_r0_body.cnn1185, PRE_first_tail_x15_r0_body.cplo185, PRE_first_tail_x15_r0_body.ccnt185, PRE_first_tail_x15_r0_body.cnband185, PRE_first_tail_x15_r0_body.chbelow185, PRE_first_tail_x15_r0_body.chren185, PRE_first_tail_x15_r0_body.cband185, PRE_first_tail_x15_r0_body.cnh1pos185, PRE_first_tail_x15_r0_body.cnren185, PRE_first_tail_x15_r0_body.cnlow185, PRE_first_tail_x15_r0_body.cabs0a185, PRE_first_tail_x15_r0_body.cabs0b185, PRE_first_tail_x15_r0_body.ctok1185, PRE_first_tail_x15_r0_body.cpend185, PRE_first_tail_x15_r0_body.cerrh185, PRE_first_tail_x15_r0_body.cfiles185, PRE_first_tail_x15_r0_body.carch185, PRE_first_tail_x15_r0_body.csizes185, PRE_first_tail_x15_r0_body.cwired185, PRE_first_tail_x15_r0_body.cfix185, clean, PRE_first_tail_x15_r0_body.fcxn185, PRE_first_tail_x15_r0_body.fcnn185, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0185, PRE_first_tail_x15_r0_body.fnk185, PRE_first_tail_x15_r0_body.ckA185, PRE_first_tail_x15_r0_body.cobjsK185, PRE_first_tail_x15_r0_body.cnodesK185, PRE_first_tail_x15_r0_body.citemsK185, PRE_first_tail_x15_r0_body.f1A185, PRE_first_tail_x15_r0_body.f1O185, PRE_first_tail_x15_r0_body.f1N185, PRE_first_tail_x15_r0_body.f1I185, PRE_first_tail_x15_r0_body.fbd185, PRE_first_tail_x15_r0_body.fincW185, PRE_first_tail_x15_r0_body.fincI185, PRE_first_tail_x15_r0_body.fincN185, PRE_first_tail_x15_r0_body.flnF185, PRE_first_tail_x15_r0_body.fh185, PRE_first_tail_x15_r0_body.fo185, PRE_first_tail_x15_r0_body.fok185, PRE_first_tail_x15_r0_body.fnd185, PRE_first_tail_x15_r0_body.fp185, PRE_first_tail_x15_r0_body.fnord185, PRE_first_tail_x15_r0_body.fi185, PRE_first_tail_x15_r0_body.fii185⟩
theorem PRE_first_tail_x15_r0_body.cnshift185 (clean : Conv.NClean (⟨21836, 18940, 2819771, 7963⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P185.NL) (cl : SSt (· < 7963) PRE_first_tail_x15_r0_body.cx0_185.mlx) : NShift PRE_first_tail_x15_r0_body.P185 7963 PRE_first_tail_x15_r0_body.kappa185 PRE_first_tail_x15_r0_body.cx0_185 PRE_first_tail_x15_r0_body.cx1_185 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot185 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost185 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0185 PRE_first_tail_x15_r0_body.ckn1185 PRE_first_tail_x15_r0_body.ckheap185 PRE_first_tail_x15_r0_body.ckpl185)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_185 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1627.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_185 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1627.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_185 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1627.ffi) = some PRE_first_tail_x15_r0_body.fxC_185
kernel_rfl PRE_first_tail_x15_r0_body.okrC_185 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1627.ffi) = some PRE_first_tail_x15_r0_body.krC_185
noncomputable def PRE_first_tail_x15_r0_body.fx0_185 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1629.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_185 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1629.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_185 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1629.ffi) = some PRE_first_tail_x15_r0_body.fx0_185
kernel_rfl PRE_first_tail_x15_r0_body.okr0_185 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1629.ffi) = some PRE_first_tail_x15_r0_body.kr0_185
noncomputable def PRE_first_tail_x15_r0_body.fx1_185 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1628.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_185 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1628.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_185 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1628.ffi) = some PRE_first_tail_x15_r0_body.fx1_185
kernel_rfl PRE_first_tail_x15_r0_body.okr1_185 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1628.ffi) = some PRE_first_tail_x15_r0_body.kr1_185
kernel_rfl PRE_first_tail_x15_r0_body.ff0185 : PRE_first_tail_x15_r0_body.fx0_185 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_185 (PRE_first_tail_x15_r0_body.clo185.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_185.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1185 : PRE_first_tail_x15_r0_body.fx1_185 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_185 (PRE_first_tail_x15_r0_body.cwS185.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_185.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck185 : freedLB PRE_first_tail_x15_r0_body.kappa185 PRE_first_tail_x15_r0_body.cx0_185.mlx PRE_first_tail_x15_r0_body.fx0_185 PRE_first_tail_x15_r0_body.fx1_185 PRE_first_tail_x15_r0_body.clo185 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0185 : PRE_first_tail_x15_r0_body.kr0_185.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_185.flags (PRE_first_tail_x15_r0_body.clo185.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_185.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0185 : PRE_first_tail_x15_r0_body.kr0_185.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_185.targs (PRE_first_tail_x15_r0_body.clo185.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_185.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1185 : PRE_first_tail_x15_r0_body.kr1_185.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_185.flags (PRE_first_tail_x15_r0_body.cwS185.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_185.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1185 : PRE_first_tail_x15_r0_body.kr1_185.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_185.targs (PRE_first_tail_x15_r0_body.cwS185.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_185.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck185 : krecLB PRE_first_tail_x15_r0_body.kappa185 7963 PRE_first_tail_x15_r0_body.cx0_185.mlx PRE_first_tail_x15_r0_body.kr0_185 PRE_first_tail_x15_r0_body.kr1_185 PRE_first_tail_x15_r0_body.clo185 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn185 : Nat.ble 7963 7963 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge185 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1628.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1629.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR185 : pendRegB PRE_first_tail_x15_r0_body.kappa185 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1629.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe185 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1629.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1628.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift185 (clean : Conv.NClean (⟨21836, 18940, 2819771, 7963⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P185.NL) (cl : SSt (· < 7963) PRE_first_tail_x15_r0_body.cx0_185.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_185.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_185.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_185.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1627.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_185.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21836, 18940, 2819771, 7963⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P185 7963 PRE_first_tail_x15_r0_body.kappa185 PRE_first_tail_x15_r0_body.s1629.ffi PRE_first_tail_x15_r0_body.s1628.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift185 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue185, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp185 t ht),
    PRE_first_tail_x15_r0_body.cbridge185,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1629.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1628.ffi) (PRE_first_tail_x15_r0_body.cfoot185 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_185 PRE_first_tail_x15_r0_body.ofx1_185 hobjC PRE_first_tail_x15_r0_body.ff0185 PRE_first_tail_x15_r0_body.ff1185 PRE_first_tail_x15_r0_body.ffck185,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1629.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1628.ffi) (PRE_first_tail_x15_r0_body.cfoot185 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_185 PRE_first_tail_x15_r0_body.okr1_185 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn185) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0185 PRE_first_tail_x15_r0_body.fkt0185 PRE_first_tail_x15_r0_body.fkf1185 PRE_first_tail_x15_r0_body.fkt1185 PRE_first_tail_x15_r0_body.fkck185,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0185 PRE_first_tail_x15_r0_body.cnh1185 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe185) PRE_first_tail_x15_r0_body.cpendR185⟩

end Host.Load.Run.Tpl

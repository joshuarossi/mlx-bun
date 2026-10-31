import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl92
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 92 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc92 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P92 : LoadP := PRE_first_tail_x15_r0_body.Pc92.raise 17107
kernel_rfl PRE_first_tail_x15_r0_body.craise92 : Nat.ble PRE_first_tail_x15_r0_body.Pc92.N0 17107 = true
theorem PRE_first_tail_x15_r0_body.raised92 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc92 PRE_first_tail_x15_r0_body.P92 :=
  .inr ⟨17107, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise92, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_92 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s816.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_92 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s815.ffi)
def PRE_first_tail_x15_r0_body.khinv92 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv92 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS92 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS92 : List Nat := List.range' 17107 0
def PRE_first_tail_x15_r0_body.ciS92 : List Nat := [] ++ List.range' 17107 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh092 : PRE_first_tail_x15_r0_body.kd92.nh0 = PRE_first_tail_x15_r0_body.cx0_92.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh192 : PRE_first_tail_x15_r0_body.kd92.nh1 = PRE_first_tail_x15_r0_body.cx1_92.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn092 : PRE_first_tail_x15_r0_body.kd92.nn0 = PRE_first_tail_x15_r0_body.cx0_92.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn192 : PRE_first_tail_x15_r0_body.kd92.nn1 = PRE_first_tail_x15_r0_body.cx1_92.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo92 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P92.lo && Nat.ble PRE_first_tail_x15_r0_body.P92.lo PRE_first_tail_x15_r0_body.cx0_92.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P92.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P92.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt92 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_92.mlx.next PRE_first_tail_x15_r0_body.cx1_92.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_92.mlx.nnext PRE_first_tail_x15_r0_body.cx1_92.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband92 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P92.NL && Nat.ble PRE_first_tail_x15_r0_body.P92.NL PRE_first_tail_x15_r0_body.P92.N0 && Nat.ble PRE_first_tail_x15_r0_body.P92.N0 PRE_first_tail_x15_r0_body.cx0_92.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow92 : PRE_first_tail_x15_r0_body.kd92.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren92 : checkRenG PRE_first_tail_x15_r0_body.kd92.hnd PRE_first_tail_x15_r0_body.khinv92 (phB PRE_first_tail_x15_r0_body.cx0_92.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband92 : PRE_first_tail_x15_r0_body.kd92.checkBand PRE_first_tail_x15_r0_body.P92.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos92 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd92.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren92 : checkRenG PRE_first_tail_x15_r0_body.kd92.node PRE_first_tail_x15_r0_body.kninv92 (pnB PRE_first_tail_x15_r0_body.cx0_92.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow92 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd92.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P92.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd92.nodeF j) PRE_first_tail_x15_r0_body.cx1_92.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a92 : PRE_first_tail_x15_r0_body.cx0_92.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b92 : PRE_first_tail_x15_r0_body.cx0_92.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok192 : PRE_first_tail_x15_r0_body.cx1_92.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend92 : PRE_first_tail_x15_r0_body.cx1_92.mlx.pending = PRE_first_tail_x15_r0_body.cx0_92.mlx.pending.map PRE_first_tail_x15_r0_body.kappa92.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh92 : PRE_first_tail_x15_r0_body.cx1_92.mlx.errh = PRE_first_tail_x15_r0_body.cx0_92.mlx.errh.map PRE_first_tail_x15_r0_body.kappa92.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles92 : PRE_first_tail_x15_r0_body.cx1_92.mlx.files = PRE_first_tail_x15_r0_body.cx0_92.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch92 : PRE_first_tail_x15_r0_body.cx1_92.mlx.arch = PRE_first_tail_x15_r0_body.cx0_92.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes92 : PRE_first_tail_x15_r0_body.cx1_92.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_92.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired92 : PRE_first_tail_x15_r0_body.cx1_92.mlx.wired = PRE_first_tail_x15_r0_body.cx0_92.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost92 : PRE_first_tail_x15_r0_body.cx1_92.host = PRE_first_tail_x15_r0_body.cx0_92.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd92`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn092 : PRE_first_tail_x15_r0_body.kd92.n0 = 2746672
kernel_rfl PRE_first_tail_x15_r0_body.ckn192 : PRE_first_tail_x15_r0_body.kd92.n1 = 2746682
kernel_rfl PRE_first_tail_x15_r0_body.ckheap92 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd92.heap).all (fun x => Nat.ble 2746671 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl92 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd92.heap.get (2746671 + j) = nth? PRE_first_tail_x15_r0_body.pl92 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja92 : Nat.ble 2746671 2746671 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn92 : Nat.ble 3988 3988 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD92 : Nat.ble 2746671 PRE_first_tail_x15_r0_body.kd92.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn92 : Nat.ble 20005 PRE_first_tail_x15_r0_body.kd92.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn92 : Nat.ble 17107 PRE_first_tail_x15_r0_body.kd92.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb92 : Nat.ble 20005 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap92 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd92.heap).all (Nat.ble (⟨20005, 17107, 2746671, 3988⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd92 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd92.hnd).all (Nat.ble (⟨20005, 17107, 2746671, 3988⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode92 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd92.node).all (Nat.ble (⟨20005, 17107, 2746671, 3988⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix92 : Conv.FixOld (⟨20005, 17107, 2746671, 3988⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa92 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja92) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn92) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD92) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn92) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn92) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb92) PRE_first_tail_x15_r0_body.fheap92 PRE_first_tail_x15_r0_body.fhnd92 PRE_first_tail_x15_r0_body.fnode92
kernel_rfl PRE_first_tail_x15_r0_body.fcxn92 : (⟨20005, 17107, 2746671, 3988⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn92 : (⟨20005, 17107, 2746671, 3988⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle092 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_92.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_92.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk92 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd92.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A92 : PRE_first_tail_x15_r0_body.cx1_92.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS92.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_92.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O92 : PRE_first_tail_x15_r0_body.cx1_92.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS92.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_92.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N92 : PRE_first_tail_x15_r0_body.cx1_92.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS92.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_92.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I92 : PRE_first_tail_x15_r0_body.cx1_92.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS92.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_92.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd92 : (PRE_first_tail_x15_r0_body.clo92 ++ PRE_first_tail_x15_r0_body.cln92 ++ PRE_first_tail_x15_r0_body.cli92 ++ PRE_first_tail_x15_r0_body.cwS92 ++ PRE_first_tail_x15_r0_body.cnS92 ++ PRE_first_tail_x15_r0_body.ciS92).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW92 : PRE_first_tail_x15_r0_body.cwS92.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo92.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI92 : PRE_first_tail_x15_r0_body.ciS92.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli92.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN92 : PRE_first_tail_x15_r0_body.cnS92.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF92 : PRE_first_tail_x15_r0_body.cln92.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh92 : PRE_first_tail_x15_r0_body.clo92.all (handleOK PRE_first_tail_x15_r0_body.kappa92 PRE_first_tail_x15_r0_body.P92.lo PRE_first_tail_x15_r0_body.cx0_92.mlx PRE_first_tail_x15_r0_body.cx1_92.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo92 : PRE_first_tail_x15_r0_body.clo92.map (fun h => PRE_first_tail_x15_r0_body.cx1_92.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa92.handle h)) = PRE_first_tail_x15_r0_body.clo92.map (fun h => (PRE_first_tail_x15_r0_body.cx0_92.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa92.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok92 : PRE_first_tail_x15_r0_body.clo92.all (objOK PRE_first_tail_x15_r0_body.kappa92 PRE_first_tail_x15_r0_body.P92.NL PRE_first_tail_x15_r0_body.cx0_92.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd92 : PRE_first_tail_x15_r0_body.cln92.all (nodeOKF PRE_first_tail_x15_r0_body.kappa92 PRE_first_tail_x15_r0_body.P92 PRE_first_tail_x15_r0_body.cx0_92.mlx PRE_first_tail_x15_r0_body.cx1_92.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp92 : ((PRE_first_tail_x15_r0_body.cln92.filter (fullB PRE_first_tail_x15_r0_body.P92))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_92.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa92.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln92.filter (fullB PRE_first_tail_x15_r0_body.P92))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_92.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa92.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI92 : incrB PRE_first_tail_x15_r0_body.kd92.nodeF (List.range' 17107 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK92 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd92.node).all (fun k => Nat.ble 17107 k && Nat.blt k 17107) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL92 : (PRE_first_tail_x15_r0_body.cln92.filter (Nat.ble PRE_first_tail_x15_r0_body.P92.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd92.nodeF i) && (Nat.blt i 17107 || Nat.ble PRE_first_tail_x15_r0_body.kd92.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord92 : (PRE_first_tail_x15_r0_body.cln92.filter (Nat.ble PRE_first_tail_x15_r0_body.P92.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd92.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd92.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd92.nodeF j) (PRE_first_tail_x15_r0_body.kd92.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow92 PRE_first_tail_x15_r0_body.cnn192 PRE_first_tail_x15_r0_body.fnordI92 PRE_first_tail_x15_r0_body.fnordK92 PRE_first_tail_x15_r0_body.fnordL92
kernel_rfl PRE_first_tail_x15_r0_body.fi92 : PRE_first_tail_x15_r0_body.cli92.all (pnB PRE_first_tail_x15_r0_body.cx0_92.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii92 : PRE_first_tail_x15_r0_body.cli92.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_92.mlx.items.get (PRE_first_tail_x15_r0_body.kappa92.node k) = (PRE_first_tail_x15_r0_body.cx0_92.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa92.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot92 (clean : Conv.NClean (⟨20005, 17107, 2746671, 3988⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P92.NL) (cl : SSt (· < 3988) PRE_first_tail_x15_r0_body.cx0_92.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P92 3988 PRE_first_tail_x15_r0_body.kappa92 PRE_first_tail_x15_r0_body.kd92 PRE_first_tail_x15_r0_body.khinv92 PRE_first_tail_x15_r0_body.kninv92 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx PRE_first_tail_x15_r0_body.cx0_92.mlx PRE_first_tail_x15_r0_body.cx1_92.mlx (⟨20005, 17107, 2746671, 3988⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo92 PRE_first_tail_x15_r0_body.cln92 PRE_first_tail_x15_r0_body.cli92 PRE_first_tail_x15_r0_body.cwS92 PRE_first_tail_x15_r0_body.cnS92 PRE_first_tail_x15_r0_body.ciS92 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh092, PRE_first_tail_x15_r0_body.cnh192, PRE_first_tail_x15_r0_body.cnn092, PRE_first_tail_x15_r0_body.cnn192, PRE_first_tail_x15_r0_body.cplo92, PRE_first_tail_x15_r0_body.ccnt92, PRE_first_tail_x15_r0_body.cnband92, PRE_first_tail_x15_r0_body.chbelow92, PRE_first_tail_x15_r0_body.chren92, PRE_first_tail_x15_r0_body.cband92, PRE_first_tail_x15_r0_body.cnh1pos92, PRE_first_tail_x15_r0_body.cnren92, PRE_first_tail_x15_r0_body.cnlow92, PRE_first_tail_x15_r0_body.cabs0a92, PRE_first_tail_x15_r0_body.cabs0b92, PRE_first_tail_x15_r0_body.ctok192, PRE_first_tail_x15_r0_body.cpend92, PRE_first_tail_x15_r0_body.cerrh92, PRE_first_tail_x15_r0_body.cfiles92, PRE_first_tail_x15_r0_body.carch92, PRE_first_tail_x15_r0_body.csizes92, PRE_first_tail_x15_r0_body.cwired92, PRE_first_tail_x15_r0_body.cfix92, clean, PRE_first_tail_x15_r0_body.fcxn92, PRE_first_tail_x15_r0_body.fcnn92, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle092, PRE_first_tail_x15_r0_body.fnk92, PRE_first_tail_x15_r0_body.ckA92, PRE_first_tail_x15_r0_body.cobjsK92, PRE_first_tail_x15_r0_body.cnodesK92, PRE_first_tail_x15_r0_body.citemsK92, PRE_first_tail_x15_r0_body.f1A92, PRE_first_tail_x15_r0_body.f1O92, PRE_first_tail_x15_r0_body.f1N92, PRE_first_tail_x15_r0_body.f1I92, PRE_first_tail_x15_r0_body.fbd92, PRE_first_tail_x15_r0_body.fincW92, PRE_first_tail_x15_r0_body.fincI92, PRE_first_tail_x15_r0_body.fincN92, PRE_first_tail_x15_r0_body.flnF92, PRE_first_tail_x15_r0_body.fh92, PRE_first_tail_x15_r0_body.fo92, PRE_first_tail_x15_r0_body.fok92, PRE_first_tail_x15_r0_body.fnd92, PRE_first_tail_x15_r0_body.fp92, PRE_first_tail_x15_r0_body.fnord92, PRE_first_tail_x15_r0_body.fi92, PRE_first_tail_x15_r0_body.fii92⟩
theorem PRE_first_tail_x15_r0_body.cnshift92 (clean : Conv.NClean (⟨20005, 17107, 2746671, 3988⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P92.NL) (cl : SSt (· < 3988) PRE_first_tail_x15_r0_body.cx0_92.mlx) : NShift PRE_first_tail_x15_r0_body.P92 3988 PRE_first_tail_x15_r0_body.kappa92 PRE_first_tail_x15_r0_body.cx0_92 PRE_first_tail_x15_r0_body.cx1_92 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot92 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost92 (compact_a_eq PRE_first_tail_x15_r0_body.ckn092 PRE_first_tail_x15_r0_body.ckn192 PRE_first_tail_x15_r0_body.ckheap92 PRE_first_tail_x15_r0_body.ckpl92)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_92 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s814.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_92 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s814.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_92 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s814.ffi) = some PRE_first_tail_x15_r0_body.fxC_92
kernel_rfl PRE_first_tail_x15_r0_body.okrC_92 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s814.ffi) = some PRE_first_tail_x15_r0_body.krC_92
noncomputable def PRE_first_tail_x15_r0_body.fx0_92 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s816.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_92 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s816.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_92 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s816.ffi) = some PRE_first_tail_x15_r0_body.fx0_92
kernel_rfl PRE_first_tail_x15_r0_body.okr0_92 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s816.ffi) = some PRE_first_tail_x15_r0_body.kr0_92
noncomputable def PRE_first_tail_x15_r0_body.fx1_92 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s815.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_92 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s815.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_92 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s815.ffi) = some PRE_first_tail_x15_r0_body.fx1_92
kernel_rfl PRE_first_tail_x15_r0_body.okr1_92 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s815.ffi) = some PRE_first_tail_x15_r0_body.kr1_92
kernel_rfl PRE_first_tail_x15_r0_body.ff092 : PRE_first_tail_x15_r0_body.fx0_92 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_92 (PRE_first_tail_x15_r0_body.clo92.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_92.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff192 : PRE_first_tail_x15_r0_body.fx1_92 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_92 (PRE_first_tail_x15_r0_body.cwS92.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_92.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck92 : freedLB PRE_first_tail_x15_r0_body.kappa92 PRE_first_tail_x15_r0_body.cx0_92.mlx PRE_first_tail_x15_r0_body.fx0_92 PRE_first_tail_x15_r0_body.fx1_92 PRE_first_tail_x15_r0_body.clo92 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf092 : PRE_first_tail_x15_r0_body.kr0_92.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_92.flags (PRE_first_tail_x15_r0_body.clo92.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_92.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt092 : PRE_first_tail_x15_r0_body.kr0_92.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_92.targs (PRE_first_tail_x15_r0_body.clo92.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_92.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf192 : PRE_first_tail_x15_r0_body.kr1_92.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_92.flags (PRE_first_tail_x15_r0_body.cwS92.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_92.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt192 : PRE_first_tail_x15_r0_body.kr1_92.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_92.targs (PRE_first_tail_x15_r0_body.cwS92.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_92.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck92 : krecLB PRE_first_tail_x15_r0_body.kappa92 3988 PRE_first_tail_x15_r0_body.cx0_92.mlx PRE_first_tail_x15_r0_body.kr0_92 PRE_first_tail_x15_r0_body.kr1_92 PRE_first_tail_x15_r0_body.clo92 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn92 : Nat.ble 3988 3988 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge92 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s815.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s816.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR92 : pendRegB PRE_first_tail_x15_r0_body.kappa92 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s816.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe92 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s816.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s815.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift92 (clean : Conv.NClean (⟨20005, 17107, 2746671, 3988⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P92.NL) (cl : SSt (· < 3988) PRE_first_tail_x15_r0_body.cx0_92.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_92.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_92.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_92.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_92.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20005, 17107, 2746671, 3988⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P92 3988 PRE_first_tail_x15_r0_body.kappa92 PRE_first_tail_x15_r0_body.s816.ffi PRE_first_tail_x15_r0_body.s815.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift92 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue92, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp92 t ht),
    PRE_first_tail_x15_r0_body.cbridge92,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s816.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s815.ffi) (PRE_first_tail_x15_r0_body.cfoot92 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_92 PRE_first_tail_x15_r0_body.ofx1_92 hobjC PRE_first_tail_x15_r0_body.ff092 PRE_first_tail_x15_r0_body.ff192 PRE_first_tail_x15_r0_body.ffck92,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s816.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s815.ffi) (PRE_first_tail_x15_r0_body.cfoot92 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_92 PRE_first_tail_x15_r0_body.okr1_92 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn92) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf092 PRE_first_tail_x15_r0_body.fkt092 PRE_first_tail_x15_r0_body.fkf192 PRE_first_tail_x15_r0_body.fkt192 PRE_first_tail_x15_r0_body.fkck92,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh092 PRE_first_tail_x15_r0_body.cnh192 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe92) PRE_first_tail_x15_r0_body.cpendR92⟩

end Host.Load.Run.Tpl

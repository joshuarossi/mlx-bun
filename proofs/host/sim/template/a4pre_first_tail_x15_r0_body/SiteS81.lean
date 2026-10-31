import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl81
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 81 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc81 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P81 : LoadP := PRE_first_tail_x15_r0_body.Pc81.raise 16904
kernel_rfl PRE_first_tail_x15_r0_body.craise81 : Nat.ble PRE_first_tail_x15_r0_body.Pc81.N0 16904 = true
theorem PRE_first_tail_x15_r0_body.raised81 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc81 PRE_first_tail_x15_r0_body.P81 :=
  .inr ⟨16904, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise81, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_81 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s794.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_81 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s793.ffi)
def PRE_first_tail_x15_r0_body.khinv81 : PTrie Nat := Stage.setAll PTrie.nil [(19811, 19809), (19812, 19810), (19814, 19811), (19813, 19812)]
def PRE_first_tail_x15_r0_body.kninv81 : PTrie Nat := Stage.setAll PTrie.nil [(16898, 16898), (16899, 16899), (16900, 16900), (16901, 16901), (16902, 16902), (16903, 16903)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS81 : List Nat := [19809, 19810, 19811, 19812, 19813, 19814]
def PRE_first_tail_x15_r0_body.cnS81 : List Nat := List.range' 16898 6
def PRE_first_tail_x15_r0_body.ciS81 : List Nat := [] ++ List.range' 16898 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh081 : PRE_first_tail_x15_r0_body.kd81.nh0 = PRE_first_tail_x15_r0_body.cx0_81.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh181 : PRE_first_tail_x15_r0_body.kd81.nh1 = PRE_first_tail_x15_r0_body.cx1_81.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn081 : PRE_first_tail_x15_r0_body.kd81.nn0 = PRE_first_tail_x15_r0_body.cx0_81.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn181 : PRE_first_tail_x15_r0_body.kd81.nn1 = PRE_first_tail_x15_r0_body.cx1_81.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo81 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P81.lo && Nat.ble PRE_first_tail_x15_r0_body.P81.lo PRE_first_tail_x15_r0_body.cx0_81.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P81.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P81.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt81 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_81.mlx.next PRE_first_tail_x15_r0_body.cx1_81.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_81.mlx.nnext PRE_first_tail_x15_r0_body.cx1_81.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband81 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P81.NL && Nat.ble PRE_first_tail_x15_r0_body.P81.NL PRE_first_tail_x15_r0_body.P81.N0 && Nat.ble PRE_first_tail_x15_r0_body.P81.N0 PRE_first_tail_x15_r0_body.cx0_81.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow81 : PRE_first_tail_x15_r0_body.kd81.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren81 : checkRenG PRE_first_tail_x15_r0_body.kd81.hnd PRE_first_tail_x15_r0_body.khinv81 (phB PRE_first_tail_x15_r0_body.cx0_81.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband81 : PRE_first_tail_x15_r0_body.kd81.checkBand PRE_first_tail_x15_r0_body.P81.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos81 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd81.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren81 : checkRenG PRE_first_tail_x15_r0_body.kd81.node PRE_first_tail_x15_r0_body.kninv81 (pnB PRE_first_tail_x15_r0_body.cx0_81.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow81 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd81.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P81.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd81.nodeF j) PRE_first_tail_x15_r0_body.cx1_81.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a81 : PRE_first_tail_x15_r0_body.cx0_81.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b81 : PRE_first_tail_x15_r0_body.cx0_81.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok181 : PRE_first_tail_x15_r0_body.cx1_81.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend81 : PRE_first_tail_x15_r0_body.cx1_81.mlx.pending = PRE_first_tail_x15_r0_body.cx0_81.mlx.pending.map PRE_first_tail_x15_r0_body.kappa81.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh81 : PRE_first_tail_x15_r0_body.cx1_81.mlx.errh = PRE_first_tail_x15_r0_body.cx0_81.mlx.errh.map PRE_first_tail_x15_r0_body.kappa81.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles81 : PRE_first_tail_x15_r0_body.cx1_81.mlx.files = PRE_first_tail_x15_r0_body.cx0_81.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch81 : PRE_first_tail_x15_r0_body.cx1_81.mlx.arch = PRE_first_tail_x15_r0_body.cx0_81.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes81 : PRE_first_tail_x15_r0_body.cx1_81.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_81.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired81 : PRE_first_tail_x15_r0_body.cx1_81.mlx.wired = PRE_first_tail_x15_r0_body.cx0_81.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost81 : PRE_first_tail_x15_r0_body.cx1_81.host = PRE_first_tail_x15_r0_body.cx0_81.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd81`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn081 : PRE_first_tail_x15_r0_body.kd81.n0 = 2739007
kernel_rfl PRE_first_tail_x15_r0_body.ckn181 : PRE_first_tail_x15_r0_body.kd81.n1 = 2739357
kernel_rfl PRE_first_tail_x15_r0_body.ckheap81 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd81.heap).all (fun x => Nat.ble 2738992 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl81 : (List.range 15).all (fun j => decide (PRE_first_tail_x15_r0_body.kd81.heap.get (2738992 + j) = nth? PRE_first_tail_x15_r0_body.pl81 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja81 : Nat.ble 2738992 2738992 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn81 : Nat.ble 3552 3552 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD81 : Nat.ble 2738992 PRE_first_tail_x15_r0_body.kd81.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn81 : Nat.ble 19809 PRE_first_tail_x15_r0_body.kd81.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn81 : Nat.ble 16898 PRE_first_tail_x15_r0_body.kd81.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb81 : Nat.ble 19809 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap81 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd81.heap).all (Nat.ble (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd81 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd81.hnd).all (Nat.ble (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode81 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd81.node).all (Nat.ble (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix81 : Conv.FixOld (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa81 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja81) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn81) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD81) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn81) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn81) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb81) PRE_first_tail_x15_r0_body.fheap81 PRE_first_tail_x15_r0_body.fhnd81 PRE_first_tail_x15_r0_body.fnode81
kernel_rfl PRE_first_tail_x15_r0_body.fcxn81 : (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn81 : (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle081 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_81.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_81.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk81 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd81.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A81 : PRE_first_tail_x15_r0_body.cx1_81.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS81.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_81.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O81 : PRE_first_tail_x15_r0_body.cx1_81.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS81.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_81.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N81 : PRE_first_tail_x15_r0_body.cx1_81.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS81.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_81.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I81 : PRE_first_tail_x15_r0_body.cx1_81.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS81.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_81.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd81 : (PRE_first_tail_x15_r0_body.clo81 ++ PRE_first_tail_x15_r0_body.cln81 ++ PRE_first_tail_x15_r0_body.cli81 ++ PRE_first_tail_x15_r0_body.cwS81 ++ PRE_first_tail_x15_r0_body.cnS81 ++ PRE_first_tail_x15_r0_body.ciS81).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW81 : PRE_first_tail_x15_r0_body.cwS81.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo81.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI81 : PRE_first_tail_x15_r0_body.ciS81.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli81.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN81 : PRE_first_tail_x15_r0_body.cnS81.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF81 : PRE_first_tail_x15_r0_body.cln81.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh81 : PRE_first_tail_x15_r0_body.clo81.all (handleOK PRE_first_tail_x15_r0_body.kappa81 PRE_first_tail_x15_r0_body.P81.lo PRE_first_tail_x15_r0_body.cx0_81.mlx PRE_first_tail_x15_r0_body.cx1_81.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo81 : PRE_first_tail_x15_r0_body.clo81.map (fun h => PRE_first_tail_x15_r0_body.cx1_81.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa81.handle h)) = PRE_first_tail_x15_r0_body.clo81.map (fun h => (PRE_first_tail_x15_r0_body.cx0_81.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa81.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok81 : PRE_first_tail_x15_r0_body.clo81.all (objOK PRE_first_tail_x15_r0_body.kappa81 PRE_first_tail_x15_r0_body.P81.NL PRE_first_tail_x15_r0_body.cx0_81.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd81 : PRE_first_tail_x15_r0_body.cln81.all (nodeOKF PRE_first_tail_x15_r0_body.kappa81 PRE_first_tail_x15_r0_body.P81 PRE_first_tail_x15_r0_body.cx0_81.mlx PRE_first_tail_x15_r0_body.cx1_81.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp81 : ((PRE_first_tail_x15_r0_body.cln81.filter (fullB PRE_first_tail_x15_r0_body.P81))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_81.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa81.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln81.filter (fullB PRE_first_tail_x15_r0_body.P81))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_81.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa81.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI81 : incrB PRE_first_tail_x15_r0_body.kd81.nodeF (List.range' 16898 6) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK81 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd81.node).all (fun k => Nat.ble 16898 k && Nat.blt k 16904) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL81 : (PRE_first_tail_x15_r0_body.cln81.filter (Nat.ble PRE_first_tail_x15_r0_body.P81.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd81.nodeF i) && (Nat.blt i 16904 || Nat.ble PRE_first_tail_x15_r0_body.kd81.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord81 : (PRE_first_tail_x15_r0_body.cln81.filter (Nat.ble PRE_first_tail_x15_r0_body.P81.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd81.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd81.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd81.nodeF j) (PRE_first_tail_x15_r0_body.kd81.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow81 PRE_first_tail_x15_r0_body.cnn181 PRE_first_tail_x15_r0_body.fnordI81 PRE_first_tail_x15_r0_body.fnordK81 PRE_first_tail_x15_r0_body.fnordL81
kernel_rfl PRE_first_tail_x15_r0_body.fi81 : PRE_first_tail_x15_r0_body.cli81.all (pnB PRE_first_tail_x15_r0_body.cx0_81.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii81 : PRE_first_tail_x15_r0_body.cli81.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_81.mlx.items.get (PRE_first_tail_x15_r0_body.kappa81.node k) = (PRE_first_tail_x15_r0_body.cx0_81.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa81.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot81 (clean : Conv.NClean (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P81.NL) (cl : SSt (· < 3561) PRE_first_tail_x15_r0_body.cx0_81.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P81 3561 PRE_first_tail_x15_r0_body.kappa81 PRE_first_tail_x15_r0_body.kd81 PRE_first_tail_x15_r0_body.khinv81 PRE_first_tail_x15_r0_body.kninv81 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx PRE_first_tail_x15_r0_body.cx0_81.mlx PRE_first_tail_x15_r0_body.cx1_81.mlx (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo81 PRE_first_tail_x15_r0_body.cln81 PRE_first_tail_x15_r0_body.cli81 PRE_first_tail_x15_r0_body.cwS81 PRE_first_tail_x15_r0_body.cnS81 PRE_first_tail_x15_r0_body.ciS81 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh081, PRE_first_tail_x15_r0_body.cnh181, PRE_first_tail_x15_r0_body.cnn081, PRE_first_tail_x15_r0_body.cnn181, PRE_first_tail_x15_r0_body.cplo81, PRE_first_tail_x15_r0_body.ccnt81, PRE_first_tail_x15_r0_body.cnband81, PRE_first_tail_x15_r0_body.chbelow81, PRE_first_tail_x15_r0_body.chren81, PRE_first_tail_x15_r0_body.cband81, PRE_first_tail_x15_r0_body.cnh1pos81, PRE_first_tail_x15_r0_body.cnren81, PRE_first_tail_x15_r0_body.cnlow81, PRE_first_tail_x15_r0_body.cabs0a81, PRE_first_tail_x15_r0_body.cabs0b81, PRE_first_tail_x15_r0_body.ctok181, PRE_first_tail_x15_r0_body.cpend81, PRE_first_tail_x15_r0_body.cerrh81, PRE_first_tail_x15_r0_body.cfiles81, PRE_first_tail_x15_r0_body.carch81, PRE_first_tail_x15_r0_body.csizes81, PRE_first_tail_x15_r0_body.cwired81, PRE_first_tail_x15_r0_body.cfix81, clean, PRE_first_tail_x15_r0_body.fcxn81, PRE_first_tail_x15_r0_body.fcnn81, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle081, PRE_first_tail_x15_r0_body.fnk81, PRE_first_tail_x15_r0_body.ckA81, PRE_first_tail_x15_r0_body.cobjsK81, PRE_first_tail_x15_r0_body.cnodesK81, PRE_first_tail_x15_r0_body.citemsK81, PRE_first_tail_x15_r0_body.f1A81, PRE_first_tail_x15_r0_body.f1O81, PRE_first_tail_x15_r0_body.f1N81, PRE_first_tail_x15_r0_body.f1I81, PRE_first_tail_x15_r0_body.fbd81, PRE_first_tail_x15_r0_body.fincW81, PRE_first_tail_x15_r0_body.fincI81, PRE_first_tail_x15_r0_body.fincN81, PRE_first_tail_x15_r0_body.flnF81, PRE_first_tail_x15_r0_body.fh81, PRE_first_tail_x15_r0_body.fo81, PRE_first_tail_x15_r0_body.fok81, PRE_first_tail_x15_r0_body.fnd81, PRE_first_tail_x15_r0_body.fp81, PRE_first_tail_x15_r0_body.fnord81, PRE_first_tail_x15_r0_body.fi81, PRE_first_tail_x15_r0_body.fii81⟩
theorem PRE_first_tail_x15_r0_body.cnshift81 (clean : Conv.NClean (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P81.NL) (cl : SSt (· < 3561) PRE_first_tail_x15_r0_body.cx0_81.mlx) : NShift PRE_first_tail_x15_r0_body.P81 3561 PRE_first_tail_x15_r0_body.kappa81 PRE_first_tail_x15_r0_body.cx0_81 PRE_first_tail_x15_r0_body.cx1_81 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot81 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost81 (compact_a_eq PRE_first_tail_x15_r0_body.ckn081 PRE_first_tail_x15_r0_body.ckn181 PRE_first_tail_x15_r0_body.ckheap81 PRE_first_tail_x15_r0_body.ckpl81)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_81 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s792.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_81 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s792.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_81 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s792.ffi) = some PRE_first_tail_x15_r0_body.fxC_81
kernel_rfl PRE_first_tail_x15_r0_body.okrC_81 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s792.ffi) = some PRE_first_tail_x15_r0_body.krC_81
noncomputable def PRE_first_tail_x15_r0_body.fx0_81 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s794.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_81 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s794.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_81 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s794.ffi) = some PRE_first_tail_x15_r0_body.fx0_81
kernel_rfl PRE_first_tail_x15_r0_body.okr0_81 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s794.ffi) = some PRE_first_tail_x15_r0_body.kr0_81
noncomputable def PRE_first_tail_x15_r0_body.fx1_81 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s793.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_81 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s793.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_81 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s793.ffi) = some PRE_first_tail_x15_r0_body.fx1_81
kernel_rfl PRE_first_tail_x15_r0_body.okr1_81 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s793.ffi) = some PRE_first_tail_x15_r0_body.kr1_81
kernel_rfl PRE_first_tail_x15_r0_body.ff081 : PRE_first_tail_x15_r0_body.fx0_81 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_81 (PRE_first_tail_x15_r0_body.clo81.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_81.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff181 : PRE_first_tail_x15_r0_body.fx1_81 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_81 (PRE_first_tail_x15_r0_body.cwS81.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_81.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck81 : freedLB PRE_first_tail_x15_r0_body.kappa81 PRE_first_tail_x15_r0_body.cx0_81.mlx PRE_first_tail_x15_r0_body.fx0_81 PRE_first_tail_x15_r0_body.fx1_81 PRE_first_tail_x15_r0_body.clo81 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf081 : PRE_first_tail_x15_r0_body.kr0_81.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_81.flags (PRE_first_tail_x15_r0_body.clo81.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_81.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt081 : PRE_first_tail_x15_r0_body.kr0_81.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_81.targs (PRE_first_tail_x15_r0_body.clo81.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_81.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf181 : PRE_first_tail_x15_r0_body.kr1_81.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_81.flags (PRE_first_tail_x15_r0_body.cwS81.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_81.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt181 : PRE_first_tail_x15_r0_body.kr1_81.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_81.targs (PRE_first_tail_x15_r0_body.cwS81.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_81.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck81 : krecLB PRE_first_tail_x15_r0_body.kappa81 3561 PRE_first_tail_x15_r0_body.cx0_81.mlx PRE_first_tail_x15_r0_body.kr0_81 PRE_first_tail_x15_r0_body.kr1_81 PRE_first_tail_x15_r0_body.clo81 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn81 : Nat.ble 3552 3561 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge81 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s793.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s794.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR81 : pendRegB PRE_first_tail_x15_r0_body.kappa81 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s794.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe81 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s794.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s793.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift81 (clean : Conv.NClean (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P81.NL) (cl : SSt (· < 3561) PRE_first_tail_x15_r0_body.cx0_81.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_81.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_81.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_81.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_81.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P81 3561 PRE_first_tail_x15_r0_body.kappa81 PRE_first_tail_x15_r0_body.s794.ffi PRE_first_tail_x15_r0_body.s793.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift81 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue81, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp81 t ht),
    PRE_first_tail_x15_r0_body.cbridge81,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s794.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s793.ffi) (PRE_first_tail_x15_r0_body.cfoot81 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_81 PRE_first_tail_x15_r0_body.ofx1_81 hobjC PRE_first_tail_x15_r0_body.ff081 PRE_first_tail_x15_r0_body.ff181 PRE_first_tail_x15_r0_body.ffck81,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s794.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s793.ffi) (PRE_first_tail_x15_r0_body.cfoot81 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_81 PRE_first_tail_x15_r0_body.okr1_81 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn81) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf081 PRE_first_tail_x15_r0_body.fkt081 PRE_first_tail_x15_r0_body.fkf181 PRE_first_tail_x15_r0_body.fkt181 PRE_first_tail_x15_r0_body.fkck81,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh081 PRE_first_tail_x15_r0_body.cnh181 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe81) PRE_first_tail_x15_r0_body.cpendR81⟩

end Host.Load.Run.Tpl

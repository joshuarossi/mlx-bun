import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl26
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 26 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc26 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P26 : LoadP := PRE_first_tail_x15_r0_body.Pc26.raise 15796
kernel_rfl PRE_first_tail_x15_r0_body.craise26 : Nat.ble PRE_first_tail_x15_r0_body.Pc26.N0 15796 = true
theorem PRE_first_tail_x15_r0_body.raised26 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc26 PRE_first_tail_x15_r0_body.P26 :=
  .inr ⟨15796, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise26, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_26 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s260.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_26 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s259.ffi)
def PRE_first_tail_x15_r0_body.khinv26 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv26 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS26 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS26 : List Nat := List.range' 15796 0
def PRE_first_tail_x15_r0_body.ciS26 : List Nat := [] ++ List.range' 15796 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh026 : PRE_first_tail_x15_r0_body.kd26.nh0 = PRE_first_tail_x15_r0_body.cx0_26.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh126 : PRE_first_tail_x15_r0_body.kd26.nh1 = PRE_first_tail_x15_r0_body.cx1_26.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn026 : PRE_first_tail_x15_r0_body.kd26.nn0 = PRE_first_tail_x15_r0_body.cx0_26.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn126 : PRE_first_tail_x15_r0_body.kd26.nn1 = PRE_first_tail_x15_r0_body.cx1_26.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo26 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P26.lo && Nat.ble PRE_first_tail_x15_r0_body.P26.lo PRE_first_tail_x15_r0_body.cx0_26.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P26.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P26.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt26 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_26.mlx.next PRE_first_tail_x15_r0_body.cx1_26.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_26.mlx.nnext PRE_first_tail_x15_r0_body.cx1_26.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband26 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P26.NL && Nat.ble PRE_first_tail_x15_r0_body.P26.NL PRE_first_tail_x15_r0_body.P26.N0 && Nat.ble PRE_first_tail_x15_r0_body.P26.N0 PRE_first_tail_x15_r0_body.cx0_26.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow26 : PRE_first_tail_x15_r0_body.kd26.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren26 : checkRenG PRE_first_tail_x15_r0_body.kd26.hnd PRE_first_tail_x15_r0_body.khinv26 (phB PRE_first_tail_x15_r0_body.cx0_26.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband26 : PRE_first_tail_x15_r0_body.kd26.checkBand PRE_first_tail_x15_r0_body.P26.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos26 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd26.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren26 : checkRenG PRE_first_tail_x15_r0_body.kd26.node PRE_first_tail_x15_r0_body.kninv26 (pnB PRE_first_tail_x15_r0_body.cx0_26.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow26 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd26.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P26.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd26.nodeF j) PRE_first_tail_x15_r0_body.cx1_26.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a26 : PRE_first_tail_x15_r0_body.cx0_26.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b26 : PRE_first_tail_x15_r0_body.cx0_26.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok126 : PRE_first_tail_x15_r0_body.cx1_26.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend26 : PRE_first_tail_x15_r0_body.cx1_26.mlx.pending = PRE_first_tail_x15_r0_body.cx0_26.mlx.pending.map PRE_first_tail_x15_r0_body.kappa26.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh26 : PRE_first_tail_x15_r0_body.cx1_26.mlx.errh = PRE_first_tail_x15_r0_body.cx0_26.mlx.errh.map PRE_first_tail_x15_r0_body.kappa26.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles26 : PRE_first_tail_x15_r0_body.cx1_26.mlx.files = PRE_first_tail_x15_r0_body.cx0_26.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch26 : PRE_first_tail_x15_r0_body.cx1_26.mlx.arch = PRE_first_tail_x15_r0_body.cx0_26.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes26 : PRE_first_tail_x15_r0_body.cx1_26.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_26.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired26 : PRE_first_tail_x15_r0_body.cx1_26.mlx.wired = PRE_first_tail_x15_r0_body.cx0_26.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost26 : PRE_first_tail_x15_r0_body.cx1_26.host = PRE_first_tail_x15_r0_body.cx0_26.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd26`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn026 : PRE_first_tail_x15_r0_body.kd26.n0 = 2695072
kernel_rfl PRE_first_tail_x15_r0_body.ckn126 : PRE_first_tail_x15_r0_body.kd26.n1 = 2695082
kernel_rfl PRE_first_tail_x15_r0_body.ckheap26 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd26.heap).all (fun x => Nat.ble 2695071 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl26 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd26.heap.get (2695071 + j) = nth? PRE_first_tail_x15_r0_body.pl26 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja26 : Nat.ble 2695071 2695071 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn26 : Nat.ble 1165 1165 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD26 : Nat.ble 2695071 PRE_first_tail_x15_r0_body.kd26.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn26 : Nat.ble 18711 PRE_first_tail_x15_r0_body.kd26.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn26 : Nat.ble 15796 PRE_first_tail_x15_r0_body.kd26.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb26 : Nat.ble 18711 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap26 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd26.heap).all (Nat.ble (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd26 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd26.hnd).all (Nat.ble (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode26 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd26.node).all (Nat.ble (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix26 : Conv.FixOld (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa26 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja26) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn26) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD26) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn26) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn26) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb26) PRE_first_tail_x15_r0_body.fheap26 PRE_first_tail_x15_r0_body.fhnd26 PRE_first_tail_x15_r0_body.fnode26
kernel_rfl PRE_first_tail_x15_r0_body.fcxn26 : (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn26 : (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle026 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_26.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_26.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk26 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd26.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A26 : PRE_first_tail_x15_r0_body.cx1_26.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS26.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_26.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O26 : PRE_first_tail_x15_r0_body.cx1_26.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS26.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_26.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N26 : PRE_first_tail_x15_r0_body.cx1_26.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS26.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_26.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I26 : PRE_first_tail_x15_r0_body.cx1_26.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS26.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_26.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd26 : (PRE_first_tail_x15_r0_body.clo26 ++ PRE_first_tail_x15_r0_body.cln26 ++ PRE_first_tail_x15_r0_body.cli26 ++ PRE_first_tail_x15_r0_body.cwS26 ++ PRE_first_tail_x15_r0_body.cnS26 ++ PRE_first_tail_x15_r0_body.ciS26).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW26 : PRE_first_tail_x15_r0_body.cwS26.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo26.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI26 : PRE_first_tail_x15_r0_body.ciS26.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli26.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN26 : PRE_first_tail_x15_r0_body.cnS26.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF26 : PRE_first_tail_x15_r0_body.cln26.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh26 : PRE_first_tail_x15_r0_body.clo26.all (handleOK PRE_first_tail_x15_r0_body.kappa26 PRE_first_tail_x15_r0_body.P26.lo PRE_first_tail_x15_r0_body.cx0_26.mlx PRE_first_tail_x15_r0_body.cx1_26.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo26 : PRE_first_tail_x15_r0_body.clo26.map (fun h => PRE_first_tail_x15_r0_body.cx1_26.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa26.handle h)) = PRE_first_tail_x15_r0_body.clo26.map (fun h => (PRE_first_tail_x15_r0_body.cx0_26.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa26.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok26 : PRE_first_tail_x15_r0_body.clo26.all (objOK PRE_first_tail_x15_r0_body.kappa26 PRE_first_tail_x15_r0_body.P26.NL PRE_first_tail_x15_r0_body.cx0_26.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd26 : PRE_first_tail_x15_r0_body.cln26.all (nodeOKF PRE_first_tail_x15_r0_body.kappa26 PRE_first_tail_x15_r0_body.P26 PRE_first_tail_x15_r0_body.cx0_26.mlx PRE_first_tail_x15_r0_body.cx1_26.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp26 : ((PRE_first_tail_x15_r0_body.cln26.filter (fullB PRE_first_tail_x15_r0_body.P26))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_26.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa26.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln26.filter (fullB PRE_first_tail_x15_r0_body.P26))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_26.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa26.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI26 : incrB PRE_first_tail_x15_r0_body.kd26.nodeF (List.range' 15796 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK26 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd26.node).all (fun k => Nat.ble 15796 k && Nat.blt k 15796) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL26 : (PRE_first_tail_x15_r0_body.cln26.filter (Nat.ble PRE_first_tail_x15_r0_body.P26.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd26.nodeF i) && (Nat.blt i 15796 || Nat.ble PRE_first_tail_x15_r0_body.kd26.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord26 : (PRE_first_tail_x15_r0_body.cln26.filter (Nat.ble PRE_first_tail_x15_r0_body.P26.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd26.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd26.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd26.nodeF j) (PRE_first_tail_x15_r0_body.kd26.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow26 PRE_first_tail_x15_r0_body.cnn126 PRE_first_tail_x15_r0_body.fnordI26 PRE_first_tail_x15_r0_body.fnordK26 PRE_first_tail_x15_r0_body.fnordL26
kernel_rfl PRE_first_tail_x15_r0_body.fi26 : PRE_first_tail_x15_r0_body.cli26.all (pnB PRE_first_tail_x15_r0_body.cx0_26.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii26 : PRE_first_tail_x15_r0_body.cli26.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_26.mlx.items.get (PRE_first_tail_x15_r0_body.kappa26.node k) = (PRE_first_tail_x15_r0_body.cx0_26.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa26.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot26 (clean : Conv.NClean (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P26.NL) (cl : SSt (· < 1165) PRE_first_tail_x15_r0_body.cx0_26.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P26 1165 PRE_first_tail_x15_r0_body.kappa26 PRE_first_tail_x15_r0_body.kd26 PRE_first_tail_x15_r0_body.khinv26 PRE_first_tail_x15_r0_body.kninv26 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx PRE_first_tail_x15_r0_body.cx0_26.mlx PRE_first_tail_x15_r0_body.cx1_26.mlx (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo26 PRE_first_tail_x15_r0_body.cln26 PRE_first_tail_x15_r0_body.cli26 PRE_first_tail_x15_r0_body.cwS26 PRE_first_tail_x15_r0_body.cnS26 PRE_first_tail_x15_r0_body.ciS26 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh026, PRE_first_tail_x15_r0_body.cnh126, PRE_first_tail_x15_r0_body.cnn026, PRE_first_tail_x15_r0_body.cnn126, PRE_first_tail_x15_r0_body.cplo26, PRE_first_tail_x15_r0_body.ccnt26, PRE_first_tail_x15_r0_body.cnband26, PRE_first_tail_x15_r0_body.chbelow26, PRE_first_tail_x15_r0_body.chren26, PRE_first_tail_x15_r0_body.cband26, PRE_first_tail_x15_r0_body.cnh1pos26, PRE_first_tail_x15_r0_body.cnren26, PRE_first_tail_x15_r0_body.cnlow26, PRE_first_tail_x15_r0_body.cabs0a26, PRE_first_tail_x15_r0_body.cabs0b26, PRE_first_tail_x15_r0_body.ctok126, PRE_first_tail_x15_r0_body.cpend26, PRE_first_tail_x15_r0_body.cerrh26, PRE_first_tail_x15_r0_body.cfiles26, PRE_first_tail_x15_r0_body.carch26, PRE_first_tail_x15_r0_body.csizes26, PRE_first_tail_x15_r0_body.cwired26, PRE_first_tail_x15_r0_body.cfix26, clean, PRE_first_tail_x15_r0_body.fcxn26, PRE_first_tail_x15_r0_body.fcnn26, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle026, PRE_first_tail_x15_r0_body.fnk26, PRE_first_tail_x15_r0_body.ckA26, PRE_first_tail_x15_r0_body.cobjsK26, PRE_first_tail_x15_r0_body.cnodesK26, PRE_first_tail_x15_r0_body.citemsK26, PRE_first_tail_x15_r0_body.f1A26, PRE_first_tail_x15_r0_body.f1O26, PRE_first_tail_x15_r0_body.f1N26, PRE_first_tail_x15_r0_body.f1I26, PRE_first_tail_x15_r0_body.fbd26, PRE_first_tail_x15_r0_body.fincW26, PRE_first_tail_x15_r0_body.fincI26, PRE_first_tail_x15_r0_body.fincN26, PRE_first_tail_x15_r0_body.flnF26, PRE_first_tail_x15_r0_body.fh26, PRE_first_tail_x15_r0_body.fo26, PRE_first_tail_x15_r0_body.fok26, PRE_first_tail_x15_r0_body.fnd26, PRE_first_tail_x15_r0_body.fp26, PRE_first_tail_x15_r0_body.fnord26, PRE_first_tail_x15_r0_body.fi26, PRE_first_tail_x15_r0_body.fii26⟩
theorem PRE_first_tail_x15_r0_body.cnshift26 (clean : Conv.NClean (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P26.NL) (cl : SSt (· < 1165) PRE_first_tail_x15_r0_body.cx0_26.mlx) : NShift PRE_first_tail_x15_r0_body.P26 1165 PRE_first_tail_x15_r0_body.kappa26 PRE_first_tail_x15_r0_body.cx0_26 PRE_first_tail_x15_r0_body.cx1_26 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot26 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost26 (compact_a_eq PRE_first_tail_x15_r0_body.ckn026 PRE_first_tail_x15_r0_body.ckn126 PRE_first_tail_x15_r0_body.ckheap26 PRE_first_tail_x15_r0_body.ckpl26)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_26 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s258.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_26 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s258.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_26 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s258.ffi) = some PRE_first_tail_x15_r0_body.fxC_26
kernel_rfl PRE_first_tail_x15_r0_body.okrC_26 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s258.ffi) = some PRE_first_tail_x15_r0_body.krC_26
noncomputable def PRE_first_tail_x15_r0_body.fx0_26 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s260.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_26 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s260.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_26 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s260.ffi) = some PRE_first_tail_x15_r0_body.fx0_26
kernel_rfl PRE_first_tail_x15_r0_body.okr0_26 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s260.ffi) = some PRE_first_tail_x15_r0_body.kr0_26
noncomputable def PRE_first_tail_x15_r0_body.fx1_26 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s259.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_26 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s259.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_26 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s259.ffi) = some PRE_first_tail_x15_r0_body.fx1_26
kernel_rfl PRE_first_tail_x15_r0_body.okr1_26 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s259.ffi) = some PRE_first_tail_x15_r0_body.kr1_26
kernel_rfl PRE_first_tail_x15_r0_body.ff026 : PRE_first_tail_x15_r0_body.fx0_26 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_26 (PRE_first_tail_x15_r0_body.clo26.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_26.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff126 : PRE_first_tail_x15_r0_body.fx1_26 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_26 (PRE_first_tail_x15_r0_body.cwS26.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_26.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck26 : freedLB PRE_first_tail_x15_r0_body.kappa26 PRE_first_tail_x15_r0_body.cx0_26.mlx PRE_first_tail_x15_r0_body.fx0_26 PRE_first_tail_x15_r0_body.fx1_26 PRE_first_tail_x15_r0_body.clo26 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf026 : PRE_first_tail_x15_r0_body.kr0_26.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_26.flags (PRE_first_tail_x15_r0_body.clo26.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_26.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt026 : PRE_first_tail_x15_r0_body.kr0_26.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_26.targs (PRE_first_tail_x15_r0_body.clo26.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_26.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf126 : PRE_first_tail_x15_r0_body.kr1_26.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_26.flags (PRE_first_tail_x15_r0_body.cwS26.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_26.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt126 : PRE_first_tail_x15_r0_body.kr1_26.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_26.targs (PRE_first_tail_x15_r0_body.cwS26.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_26.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck26 : krecLB PRE_first_tail_x15_r0_body.kappa26 1165 PRE_first_tail_x15_r0_body.cx0_26.mlx PRE_first_tail_x15_r0_body.kr0_26 PRE_first_tail_x15_r0_body.kr1_26 PRE_first_tail_x15_r0_body.clo26 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn26 : Nat.ble 1165 1165 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge26 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s259.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s260.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR26 : pendRegB PRE_first_tail_x15_r0_body.kappa26 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s260.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe26 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s260.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s259.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift26 (clean : Conv.NClean (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P26.NL) (cl : SSt (· < 1165) PRE_first_tail_x15_r0_body.cx0_26.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_26.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_26.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_26.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_26.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P26 1165 PRE_first_tail_x15_r0_body.kappa26 PRE_first_tail_x15_r0_body.s260.ffi PRE_first_tail_x15_r0_body.s259.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift26 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue26, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp26 t ht),
    PRE_first_tail_x15_r0_body.cbridge26,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s260.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s259.ffi) (PRE_first_tail_x15_r0_body.cfoot26 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_26 PRE_first_tail_x15_r0_body.ofx1_26 hobjC PRE_first_tail_x15_r0_body.ff026 PRE_first_tail_x15_r0_body.ff126 PRE_first_tail_x15_r0_body.ffck26,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s260.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s259.ffi) (PRE_first_tail_x15_r0_body.cfoot26 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_26 PRE_first_tail_x15_r0_body.okr1_26 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn26) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf026 PRE_first_tail_x15_r0_body.fkt026 PRE_first_tail_x15_r0_body.fkf126 PRE_first_tail_x15_r0_body.fkt126 PRE_first_tail_x15_r0_body.fkck26,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh026 PRE_first_tail_x15_r0_body.cnh126 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe26) PRE_first_tail_x15_r0_body.cpendR26⟩

end Host.Load.Run.Tpl

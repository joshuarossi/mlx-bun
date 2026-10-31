import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl40
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 40 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc40 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P40 : LoadP := PRE_first_tail_x15_r0_body.Pc40.raise 16092
kernel_rfl PRE_first_tail_x15_r0_body.craise40 : Nat.ble PRE_first_tail_x15_r0_body.Pc40.N0 16092 = true
theorem PRE_first_tail_x15_r0_body.raised40 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc40 PRE_first_tail_x15_r0_body.P40 :=
  .inr ⟨16092, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise40, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_40 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s365.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_40 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s364.ffi)
def PRE_first_tail_x15_r0_body.khinv40 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv40 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS40 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS40 : List Nat := List.range' 16092 0
def PRE_first_tail_x15_r0_body.ciS40 : List Nat := [] ++ List.range' 16092 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh040 : PRE_first_tail_x15_r0_body.kd40.nh0 = PRE_first_tail_x15_r0_body.cx0_40.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh140 : PRE_first_tail_x15_r0_body.kd40.nh1 = PRE_first_tail_x15_r0_body.cx1_40.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn040 : PRE_first_tail_x15_r0_body.kd40.nn0 = PRE_first_tail_x15_r0_body.cx0_40.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn140 : PRE_first_tail_x15_r0_body.kd40.nn1 = PRE_first_tail_x15_r0_body.cx1_40.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo40 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P40.lo && Nat.ble PRE_first_tail_x15_r0_body.P40.lo PRE_first_tail_x15_r0_body.cx0_40.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P40.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P40.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt40 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_40.mlx.next PRE_first_tail_x15_r0_body.cx1_40.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_40.mlx.nnext PRE_first_tail_x15_r0_body.cx1_40.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband40 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P40.NL && Nat.ble PRE_first_tail_x15_r0_body.P40.NL PRE_first_tail_x15_r0_body.P40.N0 && Nat.ble PRE_first_tail_x15_r0_body.P40.N0 PRE_first_tail_x15_r0_body.cx0_40.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow40 : PRE_first_tail_x15_r0_body.kd40.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren40 : checkRenG PRE_first_tail_x15_r0_body.kd40.hnd PRE_first_tail_x15_r0_body.khinv40 (phB PRE_first_tail_x15_r0_body.cx0_40.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband40 : PRE_first_tail_x15_r0_body.kd40.checkBand PRE_first_tail_x15_r0_body.P40.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos40 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd40.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren40 : checkRenG PRE_first_tail_x15_r0_body.kd40.node PRE_first_tail_x15_r0_body.kninv40 (pnB PRE_first_tail_x15_r0_body.cx0_40.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow40 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd40.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P40.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd40.nodeF j) PRE_first_tail_x15_r0_body.cx1_40.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a40 : PRE_first_tail_x15_r0_body.cx0_40.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b40 : PRE_first_tail_x15_r0_body.cx0_40.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok140 : PRE_first_tail_x15_r0_body.cx1_40.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend40 : PRE_first_tail_x15_r0_body.cx1_40.mlx.pending = PRE_first_tail_x15_r0_body.cx0_40.mlx.pending.map PRE_first_tail_x15_r0_body.kappa40.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh40 : PRE_first_tail_x15_r0_body.cx1_40.mlx.errh = PRE_first_tail_x15_r0_body.cx0_40.mlx.errh.map PRE_first_tail_x15_r0_body.kappa40.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles40 : PRE_first_tail_x15_r0_body.cx1_40.mlx.files = PRE_first_tail_x15_r0_body.cx0_40.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch40 : PRE_first_tail_x15_r0_body.cx1_40.mlx.arch = PRE_first_tail_x15_r0_body.cx0_40.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes40 : PRE_first_tail_x15_r0_body.cx1_40.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_40.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired40 : PRE_first_tail_x15_r0_body.cx1_40.mlx.wired = PRE_first_tail_x15_r0_body.cx0_40.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost40 : PRE_first_tail_x15_r0_body.cx1_40.host = PRE_first_tail_x15_r0_body.cx0_40.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd40`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn040 : PRE_first_tail_x15_r0_body.kd40.n0 = 2706455
kernel_rfl PRE_first_tail_x15_r0_body.ckn140 : PRE_first_tail_x15_r0_body.kd40.n1 = 2706457
kernel_rfl PRE_first_tail_x15_r0_body.ckheap40 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd40.heap).all (fun x => Nat.ble 2706455 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl40 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd40.heap.get (2706455 + j) = nth? PRE_first_tail_x15_r0_body.pl40 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja40 : Nat.ble 2706455 2706455 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn40 : Nat.ble 1790 1790 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD40 : Nat.ble 2706455 PRE_first_tail_x15_r0_body.kd40.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn40 : Nat.ble 18997 PRE_first_tail_x15_r0_body.kd40.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn40 : Nat.ble 16092 PRE_first_tail_x15_r0_body.kd40.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb40 : Nat.ble 18997 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap40 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd40.heap).all (Nat.ble (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd40 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd40.hnd).all (Nat.ble (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode40 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd40.node).all (Nat.ble (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix40 : Conv.FixOld (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa40 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja40) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn40) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD40) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn40) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn40) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb40) PRE_first_tail_x15_r0_body.fheap40 PRE_first_tail_x15_r0_body.fhnd40 PRE_first_tail_x15_r0_body.fnode40
kernel_rfl PRE_first_tail_x15_r0_body.fcxn40 : (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn40 : (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle040 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_40.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_40.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk40 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd40.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A40 : PRE_first_tail_x15_r0_body.cx1_40.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS40.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_40.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O40 : PRE_first_tail_x15_r0_body.cx1_40.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS40.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_40.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N40 : PRE_first_tail_x15_r0_body.cx1_40.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS40.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_40.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I40 : PRE_first_tail_x15_r0_body.cx1_40.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS40.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_40.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd40 : (PRE_first_tail_x15_r0_body.clo40 ++ PRE_first_tail_x15_r0_body.cln40 ++ PRE_first_tail_x15_r0_body.cli40 ++ PRE_first_tail_x15_r0_body.cwS40 ++ PRE_first_tail_x15_r0_body.cnS40 ++ PRE_first_tail_x15_r0_body.ciS40).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW40 : PRE_first_tail_x15_r0_body.cwS40.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo40.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI40 : PRE_first_tail_x15_r0_body.ciS40.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli40.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN40 : PRE_first_tail_x15_r0_body.cnS40.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF40 : PRE_first_tail_x15_r0_body.cln40.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh40 : PRE_first_tail_x15_r0_body.clo40.all (handleOK PRE_first_tail_x15_r0_body.kappa40 PRE_first_tail_x15_r0_body.P40.lo PRE_first_tail_x15_r0_body.cx0_40.mlx PRE_first_tail_x15_r0_body.cx1_40.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo40 : PRE_first_tail_x15_r0_body.clo40.map (fun h => PRE_first_tail_x15_r0_body.cx1_40.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa40.handle h)) = PRE_first_tail_x15_r0_body.clo40.map (fun h => (PRE_first_tail_x15_r0_body.cx0_40.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa40.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok40 : PRE_first_tail_x15_r0_body.clo40.all (objOK PRE_first_tail_x15_r0_body.kappa40 PRE_first_tail_x15_r0_body.P40.NL PRE_first_tail_x15_r0_body.cx0_40.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd40 : PRE_first_tail_x15_r0_body.cln40.all (nodeOKF PRE_first_tail_x15_r0_body.kappa40 PRE_first_tail_x15_r0_body.P40 PRE_first_tail_x15_r0_body.cx0_40.mlx PRE_first_tail_x15_r0_body.cx1_40.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp40 : ((PRE_first_tail_x15_r0_body.cln40.filter (fullB PRE_first_tail_x15_r0_body.P40))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_40.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa40.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln40.filter (fullB PRE_first_tail_x15_r0_body.P40))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_40.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa40.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI40 : incrB PRE_first_tail_x15_r0_body.kd40.nodeF (List.range' 16092 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK40 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd40.node).all (fun k => Nat.ble 16092 k && Nat.blt k 16092) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL40 : (PRE_first_tail_x15_r0_body.cln40.filter (Nat.ble PRE_first_tail_x15_r0_body.P40.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd40.nodeF i) && (Nat.blt i 16092 || Nat.ble PRE_first_tail_x15_r0_body.kd40.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord40 : (PRE_first_tail_x15_r0_body.cln40.filter (Nat.ble PRE_first_tail_x15_r0_body.P40.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd40.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd40.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd40.nodeF j) (PRE_first_tail_x15_r0_body.kd40.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow40 PRE_first_tail_x15_r0_body.cnn140 PRE_first_tail_x15_r0_body.fnordI40 PRE_first_tail_x15_r0_body.fnordK40 PRE_first_tail_x15_r0_body.fnordL40
kernel_rfl PRE_first_tail_x15_r0_body.fi40 : PRE_first_tail_x15_r0_body.cli40.all (pnB PRE_first_tail_x15_r0_body.cx0_40.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii40 : PRE_first_tail_x15_r0_body.cli40.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_40.mlx.items.get (PRE_first_tail_x15_r0_body.kappa40.node k) = (PRE_first_tail_x15_r0_body.cx0_40.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa40.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot40 (clean : Conv.NClean (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P40.NL) (cl : SSt (· < 1790) PRE_first_tail_x15_r0_body.cx0_40.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P40 1790 PRE_first_tail_x15_r0_body.kappa40 PRE_first_tail_x15_r0_body.kd40 PRE_first_tail_x15_r0_body.khinv40 PRE_first_tail_x15_r0_body.kninv40 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx PRE_first_tail_x15_r0_body.cx0_40.mlx PRE_first_tail_x15_r0_body.cx1_40.mlx (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo40 PRE_first_tail_x15_r0_body.cln40 PRE_first_tail_x15_r0_body.cli40 PRE_first_tail_x15_r0_body.cwS40 PRE_first_tail_x15_r0_body.cnS40 PRE_first_tail_x15_r0_body.ciS40 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh040, PRE_first_tail_x15_r0_body.cnh140, PRE_first_tail_x15_r0_body.cnn040, PRE_first_tail_x15_r0_body.cnn140, PRE_first_tail_x15_r0_body.cplo40, PRE_first_tail_x15_r0_body.ccnt40, PRE_first_tail_x15_r0_body.cnband40, PRE_first_tail_x15_r0_body.chbelow40, PRE_first_tail_x15_r0_body.chren40, PRE_first_tail_x15_r0_body.cband40, PRE_first_tail_x15_r0_body.cnh1pos40, PRE_first_tail_x15_r0_body.cnren40, PRE_first_tail_x15_r0_body.cnlow40, PRE_first_tail_x15_r0_body.cabs0a40, PRE_first_tail_x15_r0_body.cabs0b40, PRE_first_tail_x15_r0_body.ctok140, PRE_first_tail_x15_r0_body.cpend40, PRE_first_tail_x15_r0_body.cerrh40, PRE_first_tail_x15_r0_body.cfiles40, PRE_first_tail_x15_r0_body.carch40, PRE_first_tail_x15_r0_body.csizes40, PRE_first_tail_x15_r0_body.cwired40, PRE_first_tail_x15_r0_body.cfix40, clean, PRE_first_tail_x15_r0_body.fcxn40, PRE_first_tail_x15_r0_body.fcnn40, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle040, PRE_first_tail_x15_r0_body.fnk40, PRE_first_tail_x15_r0_body.ckA40, PRE_first_tail_x15_r0_body.cobjsK40, PRE_first_tail_x15_r0_body.cnodesK40, PRE_first_tail_x15_r0_body.citemsK40, PRE_first_tail_x15_r0_body.f1A40, PRE_first_tail_x15_r0_body.f1O40, PRE_first_tail_x15_r0_body.f1N40, PRE_first_tail_x15_r0_body.f1I40, PRE_first_tail_x15_r0_body.fbd40, PRE_first_tail_x15_r0_body.fincW40, PRE_first_tail_x15_r0_body.fincI40, PRE_first_tail_x15_r0_body.fincN40, PRE_first_tail_x15_r0_body.flnF40, PRE_first_tail_x15_r0_body.fh40, PRE_first_tail_x15_r0_body.fo40, PRE_first_tail_x15_r0_body.fok40, PRE_first_tail_x15_r0_body.fnd40, PRE_first_tail_x15_r0_body.fp40, PRE_first_tail_x15_r0_body.fnord40, PRE_first_tail_x15_r0_body.fi40, PRE_first_tail_x15_r0_body.fii40⟩
theorem PRE_first_tail_x15_r0_body.cnshift40 (clean : Conv.NClean (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P40.NL) (cl : SSt (· < 1790) PRE_first_tail_x15_r0_body.cx0_40.mlx) : NShift PRE_first_tail_x15_r0_body.P40 1790 PRE_first_tail_x15_r0_body.kappa40 PRE_first_tail_x15_r0_body.cx0_40 PRE_first_tail_x15_r0_body.cx1_40 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot40 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost40 (compact_a_eq PRE_first_tail_x15_r0_body.ckn040 PRE_first_tail_x15_r0_body.ckn140 PRE_first_tail_x15_r0_body.ckheap40 PRE_first_tail_x15_r0_body.ckpl40)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_40 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s363.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_40 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s363.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_40 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s363.ffi) = some PRE_first_tail_x15_r0_body.fxC_40
kernel_rfl PRE_first_tail_x15_r0_body.okrC_40 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s363.ffi) = some PRE_first_tail_x15_r0_body.krC_40
noncomputable def PRE_first_tail_x15_r0_body.fx0_40 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s365.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_40 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s365.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_40 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s365.ffi) = some PRE_first_tail_x15_r0_body.fx0_40
kernel_rfl PRE_first_tail_x15_r0_body.okr0_40 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s365.ffi) = some PRE_first_tail_x15_r0_body.kr0_40
noncomputable def PRE_first_tail_x15_r0_body.fx1_40 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s364.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_40 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s364.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_40 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s364.ffi) = some PRE_first_tail_x15_r0_body.fx1_40
kernel_rfl PRE_first_tail_x15_r0_body.okr1_40 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s364.ffi) = some PRE_first_tail_x15_r0_body.kr1_40
kernel_rfl PRE_first_tail_x15_r0_body.ff040 : PRE_first_tail_x15_r0_body.fx0_40 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_40 (PRE_first_tail_x15_r0_body.clo40.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_40.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff140 : PRE_first_tail_x15_r0_body.fx1_40 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_40 (PRE_first_tail_x15_r0_body.cwS40.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_40.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck40 : freedLB PRE_first_tail_x15_r0_body.kappa40 PRE_first_tail_x15_r0_body.cx0_40.mlx PRE_first_tail_x15_r0_body.fx0_40 PRE_first_tail_x15_r0_body.fx1_40 PRE_first_tail_x15_r0_body.clo40 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf040 : PRE_first_tail_x15_r0_body.kr0_40.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_40.flags (PRE_first_tail_x15_r0_body.clo40.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_40.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt040 : PRE_first_tail_x15_r0_body.kr0_40.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_40.targs (PRE_first_tail_x15_r0_body.clo40.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_40.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf140 : PRE_first_tail_x15_r0_body.kr1_40.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_40.flags (PRE_first_tail_x15_r0_body.cwS40.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_40.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt140 : PRE_first_tail_x15_r0_body.kr1_40.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_40.targs (PRE_first_tail_x15_r0_body.cwS40.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_40.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck40 : krecLB PRE_first_tail_x15_r0_body.kappa40 1790 PRE_first_tail_x15_r0_body.cx0_40.mlx PRE_first_tail_x15_r0_body.kr0_40 PRE_first_tail_x15_r0_body.kr1_40 PRE_first_tail_x15_r0_body.clo40 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn40 : Nat.ble 1790 1790 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge40 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s364.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s365.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR40 : pendRegB PRE_first_tail_x15_r0_body.kappa40 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s365.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe40 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s365.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s364.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift40 (clean : Conv.NClean (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P40.NL) (cl : SSt (· < 1790) PRE_first_tail_x15_r0_body.cx0_40.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_40.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_40.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_40.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_40.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P40 1790 PRE_first_tail_x15_r0_body.kappa40 PRE_first_tail_x15_r0_body.s365.ffi PRE_first_tail_x15_r0_body.s364.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift40 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue40, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp40 t ht),
    PRE_first_tail_x15_r0_body.cbridge40,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s365.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s364.ffi) (PRE_first_tail_x15_r0_body.cfoot40 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_40 PRE_first_tail_x15_r0_body.ofx1_40 hobjC PRE_first_tail_x15_r0_body.ff040 PRE_first_tail_x15_r0_body.ff140 PRE_first_tail_x15_r0_body.ffck40,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s365.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s364.ffi) (PRE_first_tail_x15_r0_body.cfoot40 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_40 PRE_first_tail_x15_r0_body.okr1_40 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn40) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf040 PRE_first_tail_x15_r0_body.fkt040 PRE_first_tail_x15_r0_body.fkf140 PRE_first_tail_x15_r0_body.fkt140 PRE_first_tail_x15_r0_body.fkck40,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh040 PRE_first_tail_x15_r0_body.cnh140 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe40) PRE_first_tail_x15_r0_body.cpendR40⟩

end Host.Load.Run.Tpl

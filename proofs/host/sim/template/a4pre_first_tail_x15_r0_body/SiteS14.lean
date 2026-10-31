import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl14
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 14 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc14 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P14 : LoadP := PRE_first_tail_x15_r0_body.Pc14.raise 15559
kernel_rfl PRE_first_tail_x15_r0_body.craise14 : Nat.ble PRE_first_tail_x15_r0_body.Pc14.N0 15559 = true
theorem PRE_first_tail_x15_r0_body.raised14 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc14 PRE_first_tail_x15_r0_body.P14 :=
  .inr ⟨15559, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise14, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_14 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s145.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_14 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s144.ffi)
def PRE_first_tail_x15_r0_body.khinv14 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv14 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS14 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS14 : List Nat := List.range' 15559 0
def PRE_first_tail_x15_r0_body.ciS14 : List Nat := [] ++ List.range' 15559 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh014 : PRE_first_tail_x15_r0_body.kd14.nh0 = PRE_first_tail_x15_r0_body.cx0_14.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh114 : PRE_first_tail_x15_r0_body.kd14.nh1 = PRE_first_tail_x15_r0_body.cx1_14.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn014 : PRE_first_tail_x15_r0_body.kd14.nn0 = PRE_first_tail_x15_r0_body.cx0_14.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn114 : PRE_first_tail_x15_r0_body.kd14.nn1 = PRE_first_tail_x15_r0_body.cx1_14.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo14 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P14.lo && Nat.ble PRE_first_tail_x15_r0_body.P14.lo PRE_first_tail_x15_r0_body.cx0_14.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P14.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P14.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt14 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_14.mlx.next PRE_first_tail_x15_r0_body.cx1_14.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_14.mlx.nnext PRE_first_tail_x15_r0_body.cx1_14.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband14 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P14.NL && Nat.ble PRE_first_tail_x15_r0_body.P14.NL PRE_first_tail_x15_r0_body.P14.N0 && Nat.ble PRE_first_tail_x15_r0_body.P14.N0 PRE_first_tail_x15_r0_body.cx0_14.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow14 : PRE_first_tail_x15_r0_body.kd14.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren14 : checkRenG PRE_first_tail_x15_r0_body.kd14.hnd PRE_first_tail_x15_r0_body.khinv14 (phB PRE_first_tail_x15_r0_body.cx0_14.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband14 : PRE_first_tail_x15_r0_body.kd14.checkBand PRE_first_tail_x15_r0_body.P14.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos14 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd14.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren14 : checkRenG PRE_first_tail_x15_r0_body.kd14.node PRE_first_tail_x15_r0_body.kninv14 (pnB PRE_first_tail_x15_r0_body.cx0_14.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow14 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd14.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P14.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd14.nodeF j) PRE_first_tail_x15_r0_body.cx1_14.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a14 : PRE_first_tail_x15_r0_body.cx0_14.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b14 : PRE_first_tail_x15_r0_body.cx0_14.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok114 : PRE_first_tail_x15_r0_body.cx1_14.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend14 : PRE_first_tail_x15_r0_body.cx1_14.mlx.pending = PRE_first_tail_x15_r0_body.cx0_14.mlx.pending.map PRE_first_tail_x15_r0_body.kappa14.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh14 : PRE_first_tail_x15_r0_body.cx1_14.mlx.errh = PRE_first_tail_x15_r0_body.cx0_14.mlx.errh.map PRE_first_tail_x15_r0_body.kappa14.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles14 : PRE_first_tail_x15_r0_body.cx1_14.mlx.files = PRE_first_tail_x15_r0_body.cx0_14.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch14 : PRE_first_tail_x15_r0_body.cx1_14.mlx.arch = PRE_first_tail_x15_r0_body.cx0_14.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes14 : PRE_first_tail_x15_r0_body.cx1_14.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_14.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired14 : PRE_first_tail_x15_r0_body.cx1_14.mlx.wired = PRE_first_tail_x15_r0_body.cx0_14.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost14 : PRE_first_tail_x15_r0_body.cx1_14.host = PRE_first_tail_x15_r0_body.cx0_14.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd14`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn014 : PRE_first_tail_x15_r0_body.kd14.n0 = 2685660
kernel_rfl PRE_first_tail_x15_r0_body.ckn114 : PRE_first_tail_x15_r0_body.kd14.n1 = 2685670
kernel_rfl PRE_first_tail_x15_r0_body.ckheap14 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd14.heap).all (fun x => Nat.ble 2685659 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl14 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd14.heap.get (2685659 + j) = nth? PRE_first_tail_x15_r0_body.pl14 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja14 : Nat.ble 2685659 2685659 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn14 : Nat.ble 652 652 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD14 : Nat.ble 2685659 PRE_first_tail_x15_r0_body.kd14.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn14 : Nat.ble 18475 PRE_first_tail_x15_r0_body.kd14.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn14 : Nat.ble 15559 PRE_first_tail_x15_r0_body.kd14.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb14 : Nat.ble 18475 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap14 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd14.heap).all (Nat.ble (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd14 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd14.hnd).all (Nat.ble (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode14 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd14.node).all (Nat.ble (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix14 : Conv.FixOld (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa14 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja14) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn14) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD14) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn14) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn14) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb14) PRE_first_tail_x15_r0_body.fheap14 PRE_first_tail_x15_r0_body.fhnd14 PRE_first_tail_x15_r0_body.fnode14
kernel_rfl PRE_first_tail_x15_r0_body.fcxn14 : (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn14 : (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle014 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_14.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_14.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk14 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd14.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A14 : PRE_first_tail_x15_r0_body.cx1_14.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS14.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_14.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O14 : PRE_first_tail_x15_r0_body.cx1_14.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS14.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_14.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N14 : PRE_first_tail_x15_r0_body.cx1_14.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS14.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_14.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I14 : PRE_first_tail_x15_r0_body.cx1_14.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS14.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_14.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd14 : (PRE_first_tail_x15_r0_body.clo14 ++ PRE_first_tail_x15_r0_body.cln14 ++ PRE_first_tail_x15_r0_body.cli14 ++ PRE_first_tail_x15_r0_body.cwS14 ++ PRE_first_tail_x15_r0_body.cnS14 ++ PRE_first_tail_x15_r0_body.ciS14).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW14 : PRE_first_tail_x15_r0_body.cwS14.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo14.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI14 : PRE_first_tail_x15_r0_body.ciS14.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli14.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN14 : PRE_first_tail_x15_r0_body.cnS14.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF14 : PRE_first_tail_x15_r0_body.cln14.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh14 : PRE_first_tail_x15_r0_body.clo14.all (handleOK PRE_first_tail_x15_r0_body.kappa14 PRE_first_tail_x15_r0_body.P14.lo PRE_first_tail_x15_r0_body.cx0_14.mlx PRE_first_tail_x15_r0_body.cx1_14.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo14 : PRE_first_tail_x15_r0_body.clo14.map (fun h => PRE_first_tail_x15_r0_body.cx1_14.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa14.handle h)) = PRE_first_tail_x15_r0_body.clo14.map (fun h => (PRE_first_tail_x15_r0_body.cx0_14.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa14.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok14 : PRE_first_tail_x15_r0_body.clo14.all (objOK PRE_first_tail_x15_r0_body.kappa14 PRE_first_tail_x15_r0_body.P14.NL PRE_first_tail_x15_r0_body.cx0_14.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd14 : PRE_first_tail_x15_r0_body.cln14.all (nodeOKF PRE_first_tail_x15_r0_body.kappa14 PRE_first_tail_x15_r0_body.P14 PRE_first_tail_x15_r0_body.cx0_14.mlx PRE_first_tail_x15_r0_body.cx1_14.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp14 : ((PRE_first_tail_x15_r0_body.cln14.filter (fullB PRE_first_tail_x15_r0_body.P14))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_14.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa14.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln14.filter (fullB PRE_first_tail_x15_r0_body.P14))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_14.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa14.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI14 : incrB PRE_first_tail_x15_r0_body.kd14.nodeF (List.range' 15559 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK14 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd14.node).all (fun k => Nat.ble 15559 k && Nat.blt k 15559) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL14 : (PRE_first_tail_x15_r0_body.cln14.filter (Nat.ble PRE_first_tail_x15_r0_body.P14.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd14.nodeF i) && (Nat.blt i 15559 || Nat.ble PRE_first_tail_x15_r0_body.kd14.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord14 : (PRE_first_tail_x15_r0_body.cln14.filter (Nat.ble PRE_first_tail_x15_r0_body.P14.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd14.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd14.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd14.nodeF j) (PRE_first_tail_x15_r0_body.kd14.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow14 PRE_first_tail_x15_r0_body.cnn114 PRE_first_tail_x15_r0_body.fnordI14 PRE_first_tail_x15_r0_body.fnordK14 PRE_first_tail_x15_r0_body.fnordL14
kernel_rfl PRE_first_tail_x15_r0_body.fi14 : PRE_first_tail_x15_r0_body.cli14.all (pnB PRE_first_tail_x15_r0_body.cx0_14.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii14 : PRE_first_tail_x15_r0_body.cli14.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_14.mlx.items.get (PRE_first_tail_x15_r0_body.kappa14.node k) = (PRE_first_tail_x15_r0_body.cx0_14.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa14.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot14 (clean : Conv.NClean (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P14.NL) (cl : SSt (· < 652) PRE_first_tail_x15_r0_body.cx0_14.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P14 652 PRE_first_tail_x15_r0_body.kappa14 PRE_first_tail_x15_r0_body.kd14 PRE_first_tail_x15_r0_body.khinv14 PRE_first_tail_x15_r0_body.kninv14 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx PRE_first_tail_x15_r0_body.cx0_14.mlx PRE_first_tail_x15_r0_body.cx1_14.mlx (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo14 PRE_first_tail_x15_r0_body.cln14 PRE_first_tail_x15_r0_body.cli14 PRE_first_tail_x15_r0_body.cwS14 PRE_first_tail_x15_r0_body.cnS14 PRE_first_tail_x15_r0_body.ciS14 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh014, PRE_first_tail_x15_r0_body.cnh114, PRE_first_tail_x15_r0_body.cnn014, PRE_first_tail_x15_r0_body.cnn114, PRE_first_tail_x15_r0_body.cplo14, PRE_first_tail_x15_r0_body.ccnt14, PRE_first_tail_x15_r0_body.cnband14, PRE_first_tail_x15_r0_body.chbelow14, PRE_first_tail_x15_r0_body.chren14, PRE_first_tail_x15_r0_body.cband14, PRE_first_tail_x15_r0_body.cnh1pos14, PRE_first_tail_x15_r0_body.cnren14, PRE_first_tail_x15_r0_body.cnlow14, PRE_first_tail_x15_r0_body.cabs0a14, PRE_first_tail_x15_r0_body.cabs0b14, PRE_first_tail_x15_r0_body.ctok114, PRE_first_tail_x15_r0_body.cpend14, PRE_first_tail_x15_r0_body.cerrh14, PRE_first_tail_x15_r0_body.cfiles14, PRE_first_tail_x15_r0_body.carch14, PRE_first_tail_x15_r0_body.csizes14, PRE_first_tail_x15_r0_body.cwired14, PRE_first_tail_x15_r0_body.cfix14, clean, PRE_first_tail_x15_r0_body.fcxn14, PRE_first_tail_x15_r0_body.fcnn14, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle014, PRE_first_tail_x15_r0_body.fnk14, PRE_first_tail_x15_r0_body.ckA14, PRE_first_tail_x15_r0_body.cobjsK14, PRE_first_tail_x15_r0_body.cnodesK14, PRE_first_tail_x15_r0_body.citemsK14, PRE_first_tail_x15_r0_body.f1A14, PRE_first_tail_x15_r0_body.f1O14, PRE_first_tail_x15_r0_body.f1N14, PRE_first_tail_x15_r0_body.f1I14, PRE_first_tail_x15_r0_body.fbd14, PRE_first_tail_x15_r0_body.fincW14, PRE_first_tail_x15_r0_body.fincI14, PRE_first_tail_x15_r0_body.fincN14, PRE_first_tail_x15_r0_body.flnF14, PRE_first_tail_x15_r0_body.fh14, PRE_first_tail_x15_r0_body.fo14, PRE_first_tail_x15_r0_body.fok14, PRE_first_tail_x15_r0_body.fnd14, PRE_first_tail_x15_r0_body.fp14, PRE_first_tail_x15_r0_body.fnord14, PRE_first_tail_x15_r0_body.fi14, PRE_first_tail_x15_r0_body.fii14⟩
theorem PRE_first_tail_x15_r0_body.cnshift14 (clean : Conv.NClean (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P14.NL) (cl : SSt (· < 652) PRE_first_tail_x15_r0_body.cx0_14.mlx) : NShift PRE_first_tail_x15_r0_body.P14 652 PRE_first_tail_x15_r0_body.kappa14 PRE_first_tail_x15_r0_body.cx0_14 PRE_first_tail_x15_r0_body.cx1_14 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot14 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost14 (compact_a_eq PRE_first_tail_x15_r0_body.ckn014 PRE_first_tail_x15_r0_body.ckn114 PRE_first_tail_x15_r0_body.ckheap14 PRE_first_tail_x15_r0_body.ckpl14)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_14 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s143.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_14 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s143.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_14 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s143.ffi) = some PRE_first_tail_x15_r0_body.fxC_14
kernel_rfl PRE_first_tail_x15_r0_body.okrC_14 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s143.ffi) = some PRE_first_tail_x15_r0_body.krC_14
noncomputable def PRE_first_tail_x15_r0_body.fx0_14 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s145.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_14 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s145.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_14 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s145.ffi) = some PRE_first_tail_x15_r0_body.fx0_14
kernel_rfl PRE_first_tail_x15_r0_body.okr0_14 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s145.ffi) = some PRE_first_tail_x15_r0_body.kr0_14
noncomputable def PRE_first_tail_x15_r0_body.fx1_14 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s144.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_14 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s144.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_14 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s144.ffi) = some PRE_first_tail_x15_r0_body.fx1_14
kernel_rfl PRE_first_tail_x15_r0_body.okr1_14 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s144.ffi) = some PRE_first_tail_x15_r0_body.kr1_14
kernel_rfl PRE_first_tail_x15_r0_body.ff014 : PRE_first_tail_x15_r0_body.fx0_14 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_14 (PRE_first_tail_x15_r0_body.clo14.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_14.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff114 : PRE_first_tail_x15_r0_body.fx1_14 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_14 (PRE_first_tail_x15_r0_body.cwS14.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_14.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck14 : freedLB PRE_first_tail_x15_r0_body.kappa14 PRE_first_tail_x15_r0_body.cx0_14.mlx PRE_first_tail_x15_r0_body.fx0_14 PRE_first_tail_x15_r0_body.fx1_14 PRE_first_tail_x15_r0_body.clo14 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf014 : PRE_first_tail_x15_r0_body.kr0_14.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_14.flags (PRE_first_tail_x15_r0_body.clo14.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_14.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt014 : PRE_first_tail_x15_r0_body.kr0_14.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_14.targs (PRE_first_tail_x15_r0_body.clo14.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_14.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf114 : PRE_first_tail_x15_r0_body.kr1_14.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_14.flags (PRE_first_tail_x15_r0_body.cwS14.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_14.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt114 : PRE_first_tail_x15_r0_body.kr1_14.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_14.targs (PRE_first_tail_x15_r0_body.cwS14.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_14.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck14 : krecLB PRE_first_tail_x15_r0_body.kappa14 652 PRE_first_tail_x15_r0_body.cx0_14.mlx PRE_first_tail_x15_r0_body.kr0_14 PRE_first_tail_x15_r0_body.kr1_14 PRE_first_tail_x15_r0_body.clo14 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn14 : Nat.ble 652 652 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge14 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s144.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s145.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR14 : pendRegB PRE_first_tail_x15_r0_body.kappa14 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s145.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe14 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s145.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s144.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift14 (clean : Conv.NClean (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P14.NL) (cl : SSt (· < 652) PRE_first_tail_x15_r0_body.cx0_14.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_14.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_14.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_14.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_14.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P14 652 PRE_first_tail_x15_r0_body.kappa14 PRE_first_tail_x15_r0_body.s145.ffi PRE_first_tail_x15_r0_body.s144.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift14 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue14, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp14 t ht),
    PRE_first_tail_x15_r0_body.cbridge14,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s145.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s144.ffi) (PRE_first_tail_x15_r0_body.cfoot14 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_14 PRE_first_tail_x15_r0_body.ofx1_14 hobjC PRE_first_tail_x15_r0_body.ff014 PRE_first_tail_x15_r0_body.ff114 PRE_first_tail_x15_r0_body.ffck14,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s145.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s144.ffi) (PRE_first_tail_x15_r0_body.cfoot14 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_14 PRE_first_tail_x15_r0_body.okr1_14 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn14) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf014 PRE_first_tail_x15_r0_body.fkt014 PRE_first_tail_x15_r0_body.fkf114 PRE_first_tail_x15_r0_body.fkt114 PRE_first_tail_x15_r0_body.fkck14,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh014 PRE_first_tail_x15_r0_body.cnh114 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe14) PRE_first_tail_x15_r0_body.cpendR14⟩

end Host.Load.Run.Tpl

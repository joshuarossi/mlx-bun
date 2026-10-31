import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl31
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 31 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc31 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P31 : LoadP := PRE_first_tail_x15_r0_body.Pc31.raise 15918
kernel_rfl PRE_first_tail_x15_r0_body.craise31 : Nat.ble PRE_first_tail_x15_r0_body.Pc31.N0 15918 = true
theorem PRE_first_tail_x15_r0_body.raised31 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc31 PRE_first_tail_x15_r0_body.P31 :=
  .inr ⟨15918, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise31, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_31 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s314.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_31 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi)
def PRE_first_tail_x15_r0_body.khinv31 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv31 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS31 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS31 : List Nat := List.range' 15918 0
def PRE_first_tail_x15_r0_body.ciS31 : List Nat := [] ++ List.range' 15918 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh031 : PRE_first_tail_x15_r0_body.kd31.nh0 = PRE_first_tail_x15_r0_body.cx0_31.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh131 : PRE_first_tail_x15_r0_body.kd31.nh1 = PRE_first_tail_x15_r0_body.cx1_31.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn031 : PRE_first_tail_x15_r0_body.kd31.nn0 = PRE_first_tail_x15_r0_body.cx0_31.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn131 : PRE_first_tail_x15_r0_body.kd31.nn1 = PRE_first_tail_x15_r0_body.cx1_31.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo31 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P31.lo && Nat.ble PRE_first_tail_x15_r0_body.P31.lo PRE_first_tail_x15_r0_body.cx0_31.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P31.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P31.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt31 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_31.mlx.next PRE_first_tail_x15_r0_body.cx1_31.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_31.mlx.nnext PRE_first_tail_x15_r0_body.cx1_31.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband31 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P31.NL && Nat.ble PRE_first_tail_x15_r0_body.P31.NL PRE_first_tail_x15_r0_body.P31.N0 && Nat.ble PRE_first_tail_x15_r0_body.P31.N0 PRE_first_tail_x15_r0_body.cx0_31.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow31 : PRE_first_tail_x15_r0_body.kd31.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren31 : checkRenG PRE_first_tail_x15_r0_body.kd31.hnd PRE_first_tail_x15_r0_body.khinv31 (phB PRE_first_tail_x15_r0_body.cx0_31.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband31 : PRE_first_tail_x15_r0_body.kd31.checkBand PRE_first_tail_x15_r0_body.P31.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos31 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd31.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren31 : checkRenG PRE_first_tail_x15_r0_body.kd31.node PRE_first_tail_x15_r0_body.kninv31 (pnB PRE_first_tail_x15_r0_body.cx0_31.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow31 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd31.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P31.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd31.nodeF j) PRE_first_tail_x15_r0_body.cx1_31.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a31 : PRE_first_tail_x15_r0_body.cx0_31.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b31 : PRE_first_tail_x15_r0_body.cx0_31.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok131 : PRE_first_tail_x15_r0_body.cx1_31.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend31 : PRE_first_tail_x15_r0_body.cx1_31.mlx.pending = PRE_first_tail_x15_r0_body.cx0_31.mlx.pending.map PRE_first_tail_x15_r0_body.kappa31.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh31 : PRE_first_tail_x15_r0_body.cx1_31.mlx.errh = PRE_first_tail_x15_r0_body.cx0_31.mlx.errh.map PRE_first_tail_x15_r0_body.kappa31.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles31 : PRE_first_tail_x15_r0_body.cx1_31.mlx.files = PRE_first_tail_x15_r0_body.cx0_31.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch31 : PRE_first_tail_x15_r0_body.cx1_31.mlx.arch = PRE_first_tail_x15_r0_body.cx0_31.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes31 : PRE_first_tail_x15_r0_body.cx1_31.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_31.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired31 : PRE_first_tail_x15_r0_body.cx1_31.mlx.wired = PRE_first_tail_x15_r0_body.cx0_31.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost31 : PRE_first_tail_x15_r0_body.cx1_31.host = PRE_first_tail_x15_r0_body.cx0_31.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd31`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn031 : PRE_first_tail_x15_r0_body.kd31.n0 = 2699295
kernel_rfl PRE_first_tail_x15_r0_body.ckn131 : PRE_first_tail_x15_r0_body.kd31.n1 = 2699297
kernel_rfl PRE_first_tail_x15_r0_body.ckheap31 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd31.heap).all (fun x => Nat.ble 2699295 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl31 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd31.heap.get (2699295 + j) = nth? PRE_first_tail_x15_r0_body.pl31 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja31 : Nat.ble 2699295 2699295 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn31 : Nat.ble 1406 1406 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD31 : Nat.ble 2699295 PRE_first_tail_x15_r0_body.kd31.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn31 : Nat.ble 18818 PRE_first_tail_x15_r0_body.kd31.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn31 : Nat.ble 15918 PRE_first_tail_x15_r0_body.kd31.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb31 : Nat.ble 18818 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap31 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd31.heap).all (Nat.ble (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd31 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd31.hnd).all (Nat.ble (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode31 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd31.node).all (Nat.ble (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix31 : Conv.FixOld (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa31 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja31) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn31) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD31) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn31) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn31) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb31) PRE_first_tail_x15_r0_body.fheap31 PRE_first_tail_x15_r0_body.fhnd31 PRE_first_tail_x15_r0_body.fnode31
kernel_rfl PRE_first_tail_x15_r0_body.fcxn31 : (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn31 : (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle031 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_31.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_31.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk31 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd31.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A31 : PRE_first_tail_x15_r0_body.cx1_31.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS31.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_31.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O31 : PRE_first_tail_x15_r0_body.cx1_31.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS31.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_31.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N31 : PRE_first_tail_x15_r0_body.cx1_31.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS31.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_31.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I31 : PRE_first_tail_x15_r0_body.cx1_31.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS31.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_31.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd31 : (PRE_first_tail_x15_r0_body.clo31 ++ PRE_first_tail_x15_r0_body.cln31 ++ PRE_first_tail_x15_r0_body.cli31 ++ PRE_first_tail_x15_r0_body.cwS31 ++ PRE_first_tail_x15_r0_body.cnS31 ++ PRE_first_tail_x15_r0_body.ciS31).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW31 : PRE_first_tail_x15_r0_body.cwS31.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo31.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI31 : PRE_first_tail_x15_r0_body.ciS31.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli31.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN31 : PRE_first_tail_x15_r0_body.cnS31.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF31 : PRE_first_tail_x15_r0_body.cln31.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh31 : PRE_first_tail_x15_r0_body.clo31.all (handleOK PRE_first_tail_x15_r0_body.kappa31 PRE_first_tail_x15_r0_body.P31.lo PRE_first_tail_x15_r0_body.cx0_31.mlx PRE_first_tail_x15_r0_body.cx1_31.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo31 : PRE_first_tail_x15_r0_body.clo31.map (fun h => PRE_first_tail_x15_r0_body.cx1_31.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa31.handle h)) = PRE_first_tail_x15_r0_body.clo31.map (fun h => (PRE_first_tail_x15_r0_body.cx0_31.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa31.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok31 : PRE_first_tail_x15_r0_body.clo31.all (objOK PRE_first_tail_x15_r0_body.kappa31 PRE_first_tail_x15_r0_body.P31.NL PRE_first_tail_x15_r0_body.cx0_31.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd31 : PRE_first_tail_x15_r0_body.cln31.all (nodeOKF PRE_first_tail_x15_r0_body.kappa31 PRE_first_tail_x15_r0_body.P31 PRE_first_tail_x15_r0_body.cx0_31.mlx PRE_first_tail_x15_r0_body.cx1_31.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp31 : ((PRE_first_tail_x15_r0_body.cln31.filter (fullB PRE_first_tail_x15_r0_body.P31))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_31.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa31.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln31.filter (fullB PRE_first_tail_x15_r0_body.P31))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_31.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa31.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI31 : incrB PRE_first_tail_x15_r0_body.kd31.nodeF (List.range' 15918 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK31 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd31.node).all (fun k => Nat.ble 15918 k && Nat.blt k 15918) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL31 : (PRE_first_tail_x15_r0_body.cln31.filter (Nat.ble PRE_first_tail_x15_r0_body.P31.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd31.nodeF i) && (Nat.blt i 15918 || Nat.ble PRE_first_tail_x15_r0_body.kd31.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord31 : (PRE_first_tail_x15_r0_body.cln31.filter (Nat.ble PRE_first_tail_x15_r0_body.P31.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd31.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd31.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd31.nodeF j) (PRE_first_tail_x15_r0_body.kd31.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow31 PRE_first_tail_x15_r0_body.cnn131 PRE_first_tail_x15_r0_body.fnordI31 PRE_first_tail_x15_r0_body.fnordK31 PRE_first_tail_x15_r0_body.fnordL31
kernel_rfl PRE_first_tail_x15_r0_body.fi31 : PRE_first_tail_x15_r0_body.cli31.all (pnB PRE_first_tail_x15_r0_body.cx0_31.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii31 : PRE_first_tail_x15_r0_body.cli31.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_31.mlx.items.get (PRE_first_tail_x15_r0_body.kappa31.node k) = (PRE_first_tail_x15_r0_body.cx0_31.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa31.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot31 (clean : Conv.NClean (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P31.NL) (cl : SSt (· < 1406) PRE_first_tail_x15_r0_body.cx0_31.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P31 1406 PRE_first_tail_x15_r0_body.kappa31 PRE_first_tail_x15_r0_body.kd31 PRE_first_tail_x15_r0_body.khinv31 PRE_first_tail_x15_r0_body.kninv31 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx PRE_first_tail_x15_r0_body.cx0_31.mlx PRE_first_tail_x15_r0_body.cx1_31.mlx (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo31 PRE_first_tail_x15_r0_body.cln31 PRE_first_tail_x15_r0_body.cli31 PRE_first_tail_x15_r0_body.cwS31 PRE_first_tail_x15_r0_body.cnS31 PRE_first_tail_x15_r0_body.ciS31 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh031, PRE_first_tail_x15_r0_body.cnh131, PRE_first_tail_x15_r0_body.cnn031, PRE_first_tail_x15_r0_body.cnn131, PRE_first_tail_x15_r0_body.cplo31, PRE_first_tail_x15_r0_body.ccnt31, PRE_first_tail_x15_r0_body.cnband31, PRE_first_tail_x15_r0_body.chbelow31, PRE_first_tail_x15_r0_body.chren31, PRE_first_tail_x15_r0_body.cband31, PRE_first_tail_x15_r0_body.cnh1pos31, PRE_first_tail_x15_r0_body.cnren31, PRE_first_tail_x15_r0_body.cnlow31, PRE_first_tail_x15_r0_body.cabs0a31, PRE_first_tail_x15_r0_body.cabs0b31, PRE_first_tail_x15_r0_body.ctok131, PRE_first_tail_x15_r0_body.cpend31, PRE_first_tail_x15_r0_body.cerrh31, PRE_first_tail_x15_r0_body.cfiles31, PRE_first_tail_x15_r0_body.carch31, PRE_first_tail_x15_r0_body.csizes31, PRE_first_tail_x15_r0_body.cwired31, PRE_first_tail_x15_r0_body.cfix31, clean, PRE_first_tail_x15_r0_body.fcxn31, PRE_first_tail_x15_r0_body.fcnn31, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle031, PRE_first_tail_x15_r0_body.fnk31, PRE_first_tail_x15_r0_body.ckA31, PRE_first_tail_x15_r0_body.cobjsK31, PRE_first_tail_x15_r0_body.cnodesK31, PRE_first_tail_x15_r0_body.citemsK31, PRE_first_tail_x15_r0_body.f1A31, PRE_first_tail_x15_r0_body.f1O31, PRE_first_tail_x15_r0_body.f1N31, PRE_first_tail_x15_r0_body.f1I31, PRE_first_tail_x15_r0_body.fbd31, PRE_first_tail_x15_r0_body.fincW31, PRE_first_tail_x15_r0_body.fincI31, PRE_first_tail_x15_r0_body.fincN31, PRE_first_tail_x15_r0_body.flnF31, PRE_first_tail_x15_r0_body.fh31, PRE_first_tail_x15_r0_body.fo31, PRE_first_tail_x15_r0_body.fok31, PRE_first_tail_x15_r0_body.fnd31, PRE_first_tail_x15_r0_body.fp31, PRE_first_tail_x15_r0_body.fnord31, PRE_first_tail_x15_r0_body.fi31, PRE_first_tail_x15_r0_body.fii31⟩
theorem PRE_first_tail_x15_r0_body.cnshift31 (clean : Conv.NClean (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P31.NL) (cl : SSt (· < 1406) PRE_first_tail_x15_r0_body.cx0_31.mlx) : NShift PRE_first_tail_x15_r0_body.P31 1406 PRE_first_tail_x15_r0_body.kappa31 PRE_first_tail_x15_r0_body.cx0_31 PRE_first_tail_x15_r0_body.cx1_31 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot31 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost31 (compact_a_eq PRE_first_tail_x15_r0_body.ckn031 PRE_first_tail_x15_r0_body.ckn131 PRE_first_tail_x15_r0_body.ckheap31 PRE_first_tail_x15_r0_body.ckpl31)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_31 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s312.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_31 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s312.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_31 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s312.ffi) = some PRE_first_tail_x15_r0_body.fxC_31
kernel_rfl PRE_first_tail_x15_r0_body.okrC_31 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s312.ffi) = some PRE_first_tail_x15_r0_body.krC_31
noncomputable def PRE_first_tail_x15_r0_body.fx0_31 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s314.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_31 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s314.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_31 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s314.ffi) = some PRE_first_tail_x15_r0_body.fx0_31
kernel_rfl PRE_first_tail_x15_r0_body.okr0_31 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s314.ffi) = some PRE_first_tail_x15_r0_body.kr0_31
noncomputable def PRE_first_tail_x15_r0_body.fx1_31 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s313.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_31 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s313.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_31 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s313.ffi) = some PRE_first_tail_x15_r0_body.fx1_31
kernel_rfl PRE_first_tail_x15_r0_body.okr1_31 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s313.ffi) = some PRE_first_tail_x15_r0_body.kr1_31
kernel_rfl PRE_first_tail_x15_r0_body.ff031 : PRE_first_tail_x15_r0_body.fx0_31 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_31 (PRE_first_tail_x15_r0_body.clo31.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_31.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff131 : PRE_first_tail_x15_r0_body.fx1_31 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_31 (PRE_first_tail_x15_r0_body.cwS31.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_31.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck31 : freedLB PRE_first_tail_x15_r0_body.kappa31 PRE_first_tail_x15_r0_body.cx0_31.mlx PRE_first_tail_x15_r0_body.fx0_31 PRE_first_tail_x15_r0_body.fx1_31 PRE_first_tail_x15_r0_body.clo31 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf031 : PRE_first_tail_x15_r0_body.kr0_31.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_31.flags (PRE_first_tail_x15_r0_body.clo31.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_31.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt031 : PRE_first_tail_x15_r0_body.kr0_31.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_31.targs (PRE_first_tail_x15_r0_body.clo31.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_31.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf131 : PRE_first_tail_x15_r0_body.kr1_31.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_31.flags (PRE_first_tail_x15_r0_body.cwS31.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_31.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt131 : PRE_first_tail_x15_r0_body.kr1_31.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_31.targs (PRE_first_tail_x15_r0_body.cwS31.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_31.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck31 : krecLB PRE_first_tail_x15_r0_body.kappa31 1406 PRE_first_tail_x15_r0_body.cx0_31.mlx PRE_first_tail_x15_r0_body.kr0_31 PRE_first_tail_x15_r0_body.kr1_31 PRE_first_tail_x15_r0_body.clo31 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn31 : Nat.ble 1406 1406 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge31 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s313.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s314.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR31 : pendRegB PRE_first_tail_x15_r0_body.kappa31 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s314.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe31 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s314.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s313.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift31 (clean : Conv.NClean (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P31.NL) (cl : SSt (· < 1406) PRE_first_tail_x15_r0_body.cx0_31.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_31.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_31.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_31.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_31.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P31 1406 PRE_first_tail_x15_r0_body.kappa31 PRE_first_tail_x15_r0_body.s314.ffi PRE_first_tail_x15_r0_body.s313.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift31 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue31, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp31 t ht),
    PRE_first_tail_x15_r0_body.cbridge31,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s314.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s313.ffi) (PRE_first_tail_x15_r0_body.cfoot31 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_31 PRE_first_tail_x15_r0_body.ofx1_31 hobjC PRE_first_tail_x15_r0_body.ff031 PRE_first_tail_x15_r0_body.ff131 PRE_first_tail_x15_r0_body.ffck31,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s314.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s313.ffi) (PRE_first_tail_x15_r0_body.cfoot31 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_31 PRE_first_tail_x15_r0_body.okr1_31 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn31) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf031 PRE_first_tail_x15_r0_body.fkt031 PRE_first_tail_x15_r0_body.fkf131 PRE_first_tail_x15_r0_body.fkt131 PRE_first_tail_x15_r0_body.fkck31,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh031 PRE_first_tail_x15_r0_body.cnh131 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe31) PRE_first_tail_x15_r0_body.cpendR31⟩

end Host.Load.Run.Tpl

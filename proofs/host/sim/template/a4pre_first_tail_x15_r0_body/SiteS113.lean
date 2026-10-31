import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl113
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 113 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc113 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P113 : LoadP := PRE_first_tail_x15_r0_body.Pc113.raise 17518
kernel_rfl PRE_first_tail_x15_r0_body.craise113 : Nat.ble PRE_first_tail_x15_r0_body.Pc113.N0 17518 = true
theorem PRE_first_tail_x15_r0_body.raised113 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc113 PRE_first_tail_x15_r0_body.P113 :=
  .inr ⟨17518, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise113, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_113 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s999.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_113 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s998.ffi)
def PRE_first_tail_x15_r0_body.khinv113 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv113 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS113 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS113 : List Nat := List.range' 17518 0
def PRE_first_tail_x15_r0_body.ciS113 : List Nat := [] ++ List.range' 17518 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0113 : PRE_first_tail_x15_r0_body.kd113.nh0 = PRE_first_tail_x15_r0_body.cx0_113.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1113 : PRE_first_tail_x15_r0_body.kd113.nh1 = PRE_first_tail_x15_r0_body.cx1_113.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0113 : PRE_first_tail_x15_r0_body.kd113.nn0 = PRE_first_tail_x15_r0_body.cx0_113.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1113 : PRE_first_tail_x15_r0_body.kd113.nn1 = PRE_first_tail_x15_r0_body.cx1_113.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo113 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P113.lo && Nat.ble PRE_first_tail_x15_r0_body.P113.lo PRE_first_tail_x15_r0_body.cx0_113.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P113.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P113.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt113 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_113.mlx.next PRE_first_tail_x15_r0_body.cx1_113.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_113.mlx.nnext PRE_first_tail_x15_r0_body.cx1_113.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband113 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P113.NL && Nat.ble PRE_first_tail_x15_r0_body.P113.NL PRE_first_tail_x15_r0_body.P113.N0 && Nat.ble PRE_first_tail_x15_r0_body.P113.N0 PRE_first_tail_x15_r0_body.cx0_113.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow113 : PRE_first_tail_x15_r0_body.kd113.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren113 : checkRenG PRE_first_tail_x15_r0_body.kd113.hnd PRE_first_tail_x15_r0_body.khinv113 (phB PRE_first_tail_x15_r0_body.cx0_113.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband113 : PRE_first_tail_x15_r0_body.kd113.checkBand PRE_first_tail_x15_r0_body.P113.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos113 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd113.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren113 : checkRenG PRE_first_tail_x15_r0_body.kd113.node PRE_first_tail_x15_r0_body.kninv113 (pnB PRE_first_tail_x15_r0_body.cx0_113.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow113 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd113.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P113.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd113.nodeF j) PRE_first_tail_x15_r0_body.cx1_113.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a113 : PRE_first_tail_x15_r0_body.cx0_113.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b113 : PRE_first_tail_x15_r0_body.cx0_113.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1113 : PRE_first_tail_x15_r0_body.cx1_113.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend113 : PRE_first_tail_x15_r0_body.cx1_113.mlx.pending = PRE_first_tail_x15_r0_body.cx0_113.mlx.pending.map PRE_first_tail_x15_r0_body.kappa113.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh113 : PRE_first_tail_x15_r0_body.cx1_113.mlx.errh = PRE_first_tail_x15_r0_body.cx0_113.mlx.errh.map PRE_first_tail_x15_r0_body.kappa113.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles113 : PRE_first_tail_x15_r0_body.cx1_113.mlx.files = PRE_first_tail_x15_r0_body.cx0_113.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch113 : PRE_first_tail_x15_r0_body.cx1_113.mlx.arch = PRE_first_tail_x15_r0_body.cx0_113.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes113 : PRE_first_tail_x15_r0_body.cx1_113.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_113.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired113 : PRE_first_tail_x15_r0_body.cx1_113.mlx.wired = PRE_first_tail_x15_r0_body.cx0_113.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost113 : PRE_first_tail_x15_r0_body.cx1_113.host = PRE_first_tail_x15_r0_body.cx0_113.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd113`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0113 : PRE_first_tail_x15_r0_body.kd113.n0 = 2763252
kernel_rfl PRE_first_tail_x15_r0_body.ckn1113 : PRE_first_tail_x15_r0_body.kd113.n1 = 2763262
kernel_rfl PRE_first_tail_x15_r0_body.ckheap113 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd113.heap).all (fun x => Nat.ble 2763251 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl113 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd113.heap.get (2763251 + j) = nth? PRE_first_tail_x15_r0_body.pl113 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja113 : Nat.ble 2763251 2763251 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn113 : Nat.ble 4885 4885 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD113 : Nat.ble 2763251 PRE_first_tail_x15_r0_body.kd113.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn113 : Nat.ble 20420 PRE_first_tail_x15_r0_body.kd113.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn113 : Nat.ble 17518 PRE_first_tail_x15_r0_body.kd113.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb113 : Nat.ble 20420 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap113 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd113.heap).all (Nat.ble (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd113 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd113.hnd).all (Nat.ble (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode113 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd113.node).all (Nat.ble (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix113 : Conv.FixOld (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa113 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja113) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn113) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD113) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn113) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn113) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb113) PRE_first_tail_x15_r0_body.fheap113 PRE_first_tail_x15_r0_body.fhnd113 PRE_first_tail_x15_r0_body.fnode113
kernel_rfl PRE_first_tail_x15_r0_body.fcxn113 : (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn113 : (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0113 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_113.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_113.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk113 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd113.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A113 : PRE_first_tail_x15_r0_body.cx1_113.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS113.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_113.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O113 : PRE_first_tail_x15_r0_body.cx1_113.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS113.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_113.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N113 : PRE_first_tail_x15_r0_body.cx1_113.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS113.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_113.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I113 : PRE_first_tail_x15_r0_body.cx1_113.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS113.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_113.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd113 : (PRE_first_tail_x15_r0_body.clo113 ++ PRE_first_tail_x15_r0_body.cln113 ++ PRE_first_tail_x15_r0_body.cli113 ++ PRE_first_tail_x15_r0_body.cwS113 ++ PRE_first_tail_x15_r0_body.cnS113 ++ PRE_first_tail_x15_r0_body.ciS113).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW113 : PRE_first_tail_x15_r0_body.cwS113.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo113.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI113 : PRE_first_tail_x15_r0_body.ciS113.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli113.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN113 : PRE_first_tail_x15_r0_body.cnS113.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF113 : PRE_first_tail_x15_r0_body.cln113.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh113 : PRE_first_tail_x15_r0_body.clo113.all (handleOK PRE_first_tail_x15_r0_body.kappa113 PRE_first_tail_x15_r0_body.P113.lo PRE_first_tail_x15_r0_body.cx0_113.mlx PRE_first_tail_x15_r0_body.cx1_113.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo113 : PRE_first_tail_x15_r0_body.clo113.map (fun h => PRE_first_tail_x15_r0_body.cx1_113.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa113.handle h)) = PRE_first_tail_x15_r0_body.clo113.map (fun h => (PRE_first_tail_x15_r0_body.cx0_113.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa113.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok113 : PRE_first_tail_x15_r0_body.clo113.all (objOK PRE_first_tail_x15_r0_body.kappa113 PRE_first_tail_x15_r0_body.P113.NL PRE_first_tail_x15_r0_body.cx0_113.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd113 : PRE_first_tail_x15_r0_body.cln113.all (nodeOKF PRE_first_tail_x15_r0_body.kappa113 PRE_first_tail_x15_r0_body.P113 PRE_first_tail_x15_r0_body.cx0_113.mlx PRE_first_tail_x15_r0_body.cx1_113.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp113 : ((PRE_first_tail_x15_r0_body.cln113.filter (fullB PRE_first_tail_x15_r0_body.P113))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_113.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa113.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln113.filter (fullB PRE_first_tail_x15_r0_body.P113))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_113.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa113.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI113 : incrB PRE_first_tail_x15_r0_body.kd113.nodeF (List.range' 17518 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK113 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd113.node).all (fun k => Nat.ble 17518 k && Nat.blt k 17518) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL113 : (PRE_first_tail_x15_r0_body.cln113.filter (Nat.ble PRE_first_tail_x15_r0_body.P113.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd113.nodeF i) && (Nat.blt i 17518 || Nat.ble PRE_first_tail_x15_r0_body.kd113.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord113 : (PRE_first_tail_x15_r0_body.cln113.filter (Nat.ble PRE_first_tail_x15_r0_body.P113.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd113.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd113.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd113.nodeF j) (PRE_first_tail_x15_r0_body.kd113.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow113 PRE_first_tail_x15_r0_body.cnn1113 PRE_first_tail_x15_r0_body.fnordI113 PRE_first_tail_x15_r0_body.fnordK113 PRE_first_tail_x15_r0_body.fnordL113
kernel_rfl PRE_first_tail_x15_r0_body.fi113 : PRE_first_tail_x15_r0_body.cli113.all (pnB PRE_first_tail_x15_r0_body.cx0_113.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii113 : PRE_first_tail_x15_r0_body.cli113.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_113.mlx.items.get (PRE_first_tail_x15_r0_body.kappa113.node k) = (PRE_first_tail_x15_r0_body.cx0_113.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa113.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot113 (clean : Conv.NClean (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P113.NL) (cl : SSt (· < 4885) PRE_first_tail_x15_r0_body.cx0_113.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P113 4885 PRE_first_tail_x15_r0_body.kappa113 PRE_first_tail_x15_r0_body.kd113 PRE_first_tail_x15_r0_body.khinv113 PRE_first_tail_x15_r0_body.kninv113 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx PRE_first_tail_x15_r0_body.cx0_113.mlx PRE_first_tail_x15_r0_body.cx1_113.mlx (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo113 PRE_first_tail_x15_r0_body.cln113 PRE_first_tail_x15_r0_body.cli113 PRE_first_tail_x15_r0_body.cwS113 PRE_first_tail_x15_r0_body.cnS113 PRE_first_tail_x15_r0_body.ciS113 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0113, PRE_first_tail_x15_r0_body.cnh1113, PRE_first_tail_x15_r0_body.cnn0113, PRE_first_tail_x15_r0_body.cnn1113, PRE_first_tail_x15_r0_body.cplo113, PRE_first_tail_x15_r0_body.ccnt113, PRE_first_tail_x15_r0_body.cnband113, PRE_first_tail_x15_r0_body.chbelow113, PRE_first_tail_x15_r0_body.chren113, PRE_first_tail_x15_r0_body.cband113, PRE_first_tail_x15_r0_body.cnh1pos113, PRE_first_tail_x15_r0_body.cnren113, PRE_first_tail_x15_r0_body.cnlow113, PRE_first_tail_x15_r0_body.cabs0a113, PRE_first_tail_x15_r0_body.cabs0b113, PRE_first_tail_x15_r0_body.ctok1113, PRE_first_tail_x15_r0_body.cpend113, PRE_first_tail_x15_r0_body.cerrh113, PRE_first_tail_x15_r0_body.cfiles113, PRE_first_tail_x15_r0_body.carch113, PRE_first_tail_x15_r0_body.csizes113, PRE_first_tail_x15_r0_body.cwired113, PRE_first_tail_x15_r0_body.cfix113, clean, PRE_first_tail_x15_r0_body.fcxn113, PRE_first_tail_x15_r0_body.fcnn113, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0113, PRE_first_tail_x15_r0_body.fnk113, PRE_first_tail_x15_r0_body.ckA113, PRE_first_tail_x15_r0_body.cobjsK113, PRE_first_tail_x15_r0_body.cnodesK113, PRE_first_tail_x15_r0_body.citemsK113, PRE_first_tail_x15_r0_body.f1A113, PRE_first_tail_x15_r0_body.f1O113, PRE_first_tail_x15_r0_body.f1N113, PRE_first_tail_x15_r0_body.f1I113, PRE_first_tail_x15_r0_body.fbd113, PRE_first_tail_x15_r0_body.fincW113, PRE_first_tail_x15_r0_body.fincI113, PRE_first_tail_x15_r0_body.fincN113, PRE_first_tail_x15_r0_body.flnF113, PRE_first_tail_x15_r0_body.fh113, PRE_first_tail_x15_r0_body.fo113, PRE_first_tail_x15_r0_body.fok113, PRE_first_tail_x15_r0_body.fnd113, PRE_first_tail_x15_r0_body.fp113, PRE_first_tail_x15_r0_body.fnord113, PRE_first_tail_x15_r0_body.fi113, PRE_first_tail_x15_r0_body.fii113⟩
theorem PRE_first_tail_x15_r0_body.cnshift113 (clean : Conv.NClean (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P113.NL) (cl : SSt (· < 4885) PRE_first_tail_x15_r0_body.cx0_113.mlx) : NShift PRE_first_tail_x15_r0_body.P113 4885 PRE_first_tail_x15_r0_body.kappa113 PRE_first_tail_x15_r0_body.cx0_113 PRE_first_tail_x15_r0_body.cx1_113 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot113 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost113 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0113 PRE_first_tail_x15_r0_body.ckn1113 PRE_first_tail_x15_r0_body.ckheap113 PRE_first_tail_x15_r0_body.ckpl113)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_113 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s997.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_113 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s997.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_113 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s997.ffi) = some PRE_first_tail_x15_r0_body.fxC_113
kernel_rfl PRE_first_tail_x15_r0_body.okrC_113 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s997.ffi) = some PRE_first_tail_x15_r0_body.krC_113
noncomputable def PRE_first_tail_x15_r0_body.fx0_113 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s999.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_113 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s999.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_113 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s999.ffi) = some PRE_first_tail_x15_r0_body.fx0_113
kernel_rfl PRE_first_tail_x15_r0_body.okr0_113 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s999.ffi) = some PRE_first_tail_x15_r0_body.kr0_113
noncomputable def PRE_first_tail_x15_r0_body.fx1_113 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s998.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_113 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s998.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_113 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s998.ffi) = some PRE_first_tail_x15_r0_body.fx1_113
kernel_rfl PRE_first_tail_x15_r0_body.okr1_113 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s998.ffi) = some PRE_first_tail_x15_r0_body.kr1_113
kernel_rfl PRE_first_tail_x15_r0_body.ff0113 : PRE_first_tail_x15_r0_body.fx0_113 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_113 (PRE_first_tail_x15_r0_body.clo113.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_113.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1113 : PRE_first_tail_x15_r0_body.fx1_113 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_113 (PRE_first_tail_x15_r0_body.cwS113.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_113.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck113 : freedLB PRE_first_tail_x15_r0_body.kappa113 PRE_first_tail_x15_r0_body.cx0_113.mlx PRE_first_tail_x15_r0_body.fx0_113 PRE_first_tail_x15_r0_body.fx1_113 PRE_first_tail_x15_r0_body.clo113 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0113 : PRE_first_tail_x15_r0_body.kr0_113.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_113.flags (PRE_first_tail_x15_r0_body.clo113.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_113.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0113 : PRE_first_tail_x15_r0_body.kr0_113.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_113.targs (PRE_first_tail_x15_r0_body.clo113.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_113.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1113 : PRE_first_tail_x15_r0_body.kr1_113.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_113.flags (PRE_first_tail_x15_r0_body.cwS113.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_113.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1113 : PRE_first_tail_x15_r0_body.kr1_113.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_113.targs (PRE_first_tail_x15_r0_body.cwS113.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_113.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck113 : krecLB PRE_first_tail_x15_r0_body.kappa113 4885 PRE_first_tail_x15_r0_body.cx0_113.mlx PRE_first_tail_x15_r0_body.kr0_113 PRE_first_tail_x15_r0_body.kr1_113 PRE_first_tail_x15_r0_body.clo113 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn113 : Nat.ble 4885 4885 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge113 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s998.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s999.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR113 : pendRegB PRE_first_tail_x15_r0_body.kappa113 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s999.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe113 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s999.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s998.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift113 (clean : Conv.NClean (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P113.NL) (cl : SSt (· < 4885) PRE_first_tail_x15_r0_body.cx0_113.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_113.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_113.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_113.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_113.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P113 4885 PRE_first_tail_x15_r0_body.kappa113 PRE_first_tail_x15_r0_body.s999.ffi PRE_first_tail_x15_r0_body.s998.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift113 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue113, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp113 t ht),
    PRE_first_tail_x15_r0_body.cbridge113,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s999.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s998.ffi) (PRE_first_tail_x15_r0_body.cfoot113 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_113 PRE_first_tail_x15_r0_body.ofx1_113 hobjC PRE_first_tail_x15_r0_body.ff0113 PRE_first_tail_x15_r0_body.ff1113 PRE_first_tail_x15_r0_body.ffck113,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s999.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s998.ffi) (PRE_first_tail_x15_r0_body.cfoot113 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_113 PRE_first_tail_x15_r0_body.okr1_113 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn113) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0113 PRE_first_tail_x15_r0_body.fkt0113 PRE_first_tail_x15_r0_body.fkf1113 PRE_first_tail_x15_r0_body.fkt1113 PRE_first_tail_x15_r0_body.fkck113,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0113 PRE_first_tail_x15_r0_body.cnh1113 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe113) PRE_first_tail_x15_r0_body.cpendR113⟩

end Host.Load.Run.Tpl

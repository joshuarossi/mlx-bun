import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl60
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 60 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc60 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P60 : LoadP := PRE_first_tail_x15_r0_body.Pc60.raise 16490
kernel_rfl PRE_first_tail_x15_r0_body.craise60 : Nat.ble PRE_first_tail_x15_r0_body.Pc60.N0 16490 = true
theorem PRE_first_tail_x15_r0_body.raised60 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc60 PRE_first_tail_x15_r0_body.P60 :=
  .inr ⟨16490, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise60, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_60 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_60 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s592.ffi)
def PRE_first_tail_x15_r0_body.khinv60 : PTrie Nat := Stage.setAll PTrie.nil [(19422, 19396), (19400, 19397), (19423, 19398)]
def PRE_first_tail_x15_r0_body.kninv60 : PTrie Nat := Stage.setAll PTrie.nil [(16463, 16463), (16464, 16464), (16465, 16465), (16466, 16466), (16467, 16467), (16468, 16468), (16469, 16469), (16470, 16470), (16471, 16471), (16472, 16472), (16473, 16473), (16474, 16474), (16475, 16475), (16476, 16476), (16477, 16477), (16478, 16478), (16479, 16479), (16480, 16480), (16481, 16481), (16482, 16482), (16483, 16483), (16484, 16484), (16485, 16485), (16486, 16486), (16487, 16487), (16488, 16488), (16489, 16489)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS60 : List Nat := [19376, 19389, 19395, 19396, 19397, 19398, 19399, 19400, 19401, 19402, 19403, 19404, 19405, 19406, 19407, 19408, 19409, 19410, 19411, 19412, 19413, 19414, 19415, 19416, 19417, 19418, 19419, 19420, 19421, 19422, 19423]
def PRE_first_tail_x15_r0_body.cnS60 : List Nat := List.range' 16463 27
def PRE_first_tail_x15_r0_body.ciS60 : List Nat := [] ++ List.range' 16463 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh060 : PRE_first_tail_x15_r0_body.kd60.nh0 = PRE_first_tail_x15_r0_body.cx0_60.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh160 : PRE_first_tail_x15_r0_body.kd60.nh1 = PRE_first_tail_x15_r0_body.cx1_60.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn060 : PRE_first_tail_x15_r0_body.kd60.nn0 = PRE_first_tail_x15_r0_body.cx0_60.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn160 : PRE_first_tail_x15_r0_body.kd60.nn1 = PRE_first_tail_x15_r0_body.cx1_60.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo60 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P60.lo && Nat.ble PRE_first_tail_x15_r0_body.P60.lo PRE_first_tail_x15_r0_body.cx0_60.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P60.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P60.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt60 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_60.mlx.next PRE_first_tail_x15_r0_body.cx1_60.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_60.mlx.nnext PRE_first_tail_x15_r0_body.cx1_60.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband60 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P60.NL && Nat.ble PRE_first_tail_x15_r0_body.P60.NL PRE_first_tail_x15_r0_body.P60.N0 && Nat.ble PRE_first_tail_x15_r0_body.P60.N0 PRE_first_tail_x15_r0_body.cx0_60.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow60 : PRE_first_tail_x15_r0_body.kd60.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren60 : checkRenG PRE_first_tail_x15_r0_body.kd60.hnd PRE_first_tail_x15_r0_body.khinv60 (phB PRE_first_tail_x15_r0_body.cx0_60.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband60 : PRE_first_tail_x15_r0_body.kd60.checkBand PRE_first_tail_x15_r0_body.P60.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos60 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd60.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren60 : checkRenG PRE_first_tail_x15_r0_body.kd60.node PRE_first_tail_x15_r0_body.kninv60 (pnB PRE_first_tail_x15_r0_body.cx0_60.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow60 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd60.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P60.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd60.nodeF j) PRE_first_tail_x15_r0_body.cx1_60.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a60 : PRE_first_tail_x15_r0_body.cx0_60.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b60 : PRE_first_tail_x15_r0_body.cx0_60.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok160 : PRE_first_tail_x15_r0_body.cx1_60.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend60 : PRE_first_tail_x15_r0_body.cx1_60.mlx.pending = PRE_first_tail_x15_r0_body.cx0_60.mlx.pending.map PRE_first_tail_x15_r0_body.kappa60.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh60 : PRE_first_tail_x15_r0_body.cx1_60.mlx.errh = PRE_first_tail_x15_r0_body.cx0_60.mlx.errh.map PRE_first_tail_x15_r0_body.kappa60.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles60 : PRE_first_tail_x15_r0_body.cx1_60.mlx.files = PRE_first_tail_x15_r0_body.cx0_60.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch60 : PRE_first_tail_x15_r0_body.cx1_60.mlx.arch = PRE_first_tail_x15_r0_body.cx0_60.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes60 : PRE_first_tail_x15_r0_body.cx1_60.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_60.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired60 : PRE_first_tail_x15_r0_body.cx1_60.mlx.wired = PRE_first_tail_x15_r0_body.cx0_60.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost60 : PRE_first_tail_x15_r0_body.cx1_60.host = PRE_first_tail_x15_r0_body.cx0_60.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd60`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn060 : PRE_first_tail_x15_r0_body.kd60.n0 = 2722553
kernel_rfl PRE_first_tail_x15_r0_body.ckn160 : PRE_first_tail_x15_r0_body.kd60.n1 = 2723702
kernel_rfl PRE_first_tail_x15_r0_body.ckheap60 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd60.heap).all (fun x => Nat.ble 2722547 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl60 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd60.heap.get (2722547 + j) = nth? PRE_first_tail_x15_r0_body.pl60 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja60 : Nat.ble 2722547 2722547 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn60 : Nat.ble 2648 2648 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD60 : Nat.ble 2722547 PRE_first_tail_x15_r0_body.kd60.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn60 : Nat.ble 19396 PRE_first_tail_x15_r0_body.kd60.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn60 : Nat.ble 16463 PRE_first_tail_x15_r0_body.kd60.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb60 : Nat.ble 19396 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap60 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd60.heap).all (Nat.ble (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd60 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd60.hnd).all (Nat.ble (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode60 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd60.node).all (Nat.ble (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix60 : Conv.FixOld (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa60 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja60) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn60) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD60) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn60) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn60) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb60) PRE_first_tail_x15_r0_body.fheap60 PRE_first_tail_x15_r0_body.fhnd60 PRE_first_tail_x15_r0_body.fnode60
kernel_rfl PRE_first_tail_x15_r0_body.fcxn60 : (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn60 : (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle060 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_60.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_60.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk60 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd60.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A60 : PRE_first_tail_x15_r0_body.cx1_60.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS60.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_60.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O60 : PRE_first_tail_x15_r0_body.cx1_60.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS60.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_60.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N60 : PRE_first_tail_x15_r0_body.cx1_60.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS60.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_60.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I60 : PRE_first_tail_x15_r0_body.cx1_60.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS60.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_60.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd60 : (PRE_first_tail_x15_r0_body.clo60 ++ PRE_first_tail_x15_r0_body.cln60 ++ PRE_first_tail_x15_r0_body.cli60 ++ PRE_first_tail_x15_r0_body.cwS60 ++ PRE_first_tail_x15_r0_body.cnS60 ++ PRE_first_tail_x15_r0_body.ciS60).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW60 : PRE_first_tail_x15_r0_body.cwS60.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo60.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI60 : PRE_first_tail_x15_r0_body.ciS60.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli60.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN60 : PRE_first_tail_x15_r0_body.cnS60.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF60 : PRE_first_tail_x15_r0_body.cln60.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh60 : PRE_first_tail_x15_r0_body.clo60.all (handleOK PRE_first_tail_x15_r0_body.kappa60 PRE_first_tail_x15_r0_body.P60.lo PRE_first_tail_x15_r0_body.cx0_60.mlx PRE_first_tail_x15_r0_body.cx1_60.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo60 : PRE_first_tail_x15_r0_body.clo60.map (fun h => PRE_first_tail_x15_r0_body.cx1_60.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa60.handle h)) = PRE_first_tail_x15_r0_body.clo60.map (fun h => (PRE_first_tail_x15_r0_body.cx0_60.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa60.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok60 : PRE_first_tail_x15_r0_body.clo60.all (objOK PRE_first_tail_x15_r0_body.kappa60 PRE_first_tail_x15_r0_body.P60.NL PRE_first_tail_x15_r0_body.cx0_60.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd60 : PRE_first_tail_x15_r0_body.cln60.all (nodeOKF PRE_first_tail_x15_r0_body.kappa60 PRE_first_tail_x15_r0_body.P60 PRE_first_tail_x15_r0_body.cx0_60.mlx PRE_first_tail_x15_r0_body.cx1_60.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp60 : ((PRE_first_tail_x15_r0_body.cln60.filter (fullB PRE_first_tail_x15_r0_body.P60))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_60.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa60.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln60.filter (fullB PRE_first_tail_x15_r0_body.P60))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_60.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa60.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI60 : incrB PRE_first_tail_x15_r0_body.kd60.nodeF (List.range' 16463 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK60 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd60.node).all (fun k => Nat.ble 16463 k && Nat.blt k 16490) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL60 : (PRE_first_tail_x15_r0_body.cln60.filter (Nat.ble PRE_first_tail_x15_r0_body.P60.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd60.nodeF i) && (Nat.blt i 16490 || Nat.ble PRE_first_tail_x15_r0_body.kd60.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord60 : (PRE_first_tail_x15_r0_body.cln60.filter (Nat.ble PRE_first_tail_x15_r0_body.P60.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd60.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd60.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd60.nodeF j) (PRE_first_tail_x15_r0_body.kd60.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow60 PRE_first_tail_x15_r0_body.cnn160 PRE_first_tail_x15_r0_body.fnordI60 PRE_first_tail_x15_r0_body.fnordK60 PRE_first_tail_x15_r0_body.fnordL60
kernel_rfl PRE_first_tail_x15_r0_body.fi60 : PRE_first_tail_x15_r0_body.cli60.all (pnB PRE_first_tail_x15_r0_body.cx0_60.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii60 : PRE_first_tail_x15_r0_body.cli60.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_60.mlx.items.get (PRE_first_tail_x15_r0_body.kappa60.node k) = (PRE_first_tail_x15_r0_body.cx0_60.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa60.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot60 (clean : Conv.NClean (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P60.NL) (cl : SSt (· < 2666) PRE_first_tail_x15_r0_body.cx0_60.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P60 2666 PRE_first_tail_x15_r0_body.kappa60 PRE_first_tail_x15_r0_body.kd60 PRE_first_tail_x15_r0_body.khinv60 PRE_first_tail_x15_r0_body.kninv60 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx PRE_first_tail_x15_r0_body.cx0_60.mlx PRE_first_tail_x15_r0_body.cx1_60.mlx (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo60 PRE_first_tail_x15_r0_body.cln60 PRE_first_tail_x15_r0_body.cli60 PRE_first_tail_x15_r0_body.cwS60 PRE_first_tail_x15_r0_body.cnS60 PRE_first_tail_x15_r0_body.ciS60 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh060, PRE_first_tail_x15_r0_body.cnh160, PRE_first_tail_x15_r0_body.cnn060, PRE_first_tail_x15_r0_body.cnn160, PRE_first_tail_x15_r0_body.cplo60, PRE_first_tail_x15_r0_body.ccnt60, PRE_first_tail_x15_r0_body.cnband60, PRE_first_tail_x15_r0_body.chbelow60, PRE_first_tail_x15_r0_body.chren60, PRE_first_tail_x15_r0_body.cband60, PRE_first_tail_x15_r0_body.cnh1pos60, PRE_first_tail_x15_r0_body.cnren60, PRE_first_tail_x15_r0_body.cnlow60, PRE_first_tail_x15_r0_body.cabs0a60, PRE_first_tail_x15_r0_body.cabs0b60, PRE_first_tail_x15_r0_body.ctok160, PRE_first_tail_x15_r0_body.cpend60, PRE_first_tail_x15_r0_body.cerrh60, PRE_first_tail_x15_r0_body.cfiles60, PRE_first_tail_x15_r0_body.carch60, PRE_first_tail_x15_r0_body.csizes60, PRE_first_tail_x15_r0_body.cwired60, PRE_first_tail_x15_r0_body.cfix60, clean, PRE_first_tail_x15_r0_body.fcxn60, PRE_first_tail_x15_r0_body.fcnn60, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle060, PRE_first_tail_x15_r0_body.fnk60, PRE_first_tail_x15_r0_body.ckA60, PRE_first_tail_x15_r0_body.cobjsK60, PRE_first_tail_x15_r0_body.cnodesK60, PRE_first_tail_x15_r0_body.citemsK60, PRE_first_tail_x15_r0_body.f1A60, PRE_first_tail_x15_r0_body.f1O60, PRE_first_tail_x15_r0_body.f1N60, PRE_first_tail_x15_r0_body.f1I60, PRE_first_tail_x15_r0_body.fbd60, PRE_first_tail_x15_r0_body.fincW60, PRE_first_tail_x15_r0_body.fincI60, PRE_first_tail_x15_r0_body.fincN60, PRE_first_tail_x15_r0_body.flnF60, PRE_first_tail_x15_r0_body.fh60, PRE_first_tail_x15_r0_body.fo60, PRE_first_tail_x15_r0_body.fok60, PRE_first_tail_x15_r0_body.fnd60, PRE_first_tail_x15_r0_body.fp60, PRE_first_tail_x15_r0_body.fnord60, PRE_first_tail_x15_r0_body.fi60, PRE_first_tail_x15_r0_body.fii60⟩
theorem PRE_first_tail_x15_r0_body.cnshift60 (clean : Conv.NClean (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P60.NL) (cl : SSt (· < 2666) PRE_first_tail_x15_r0_body.cx0_60.mlx) : NShift PRE_first_tail_x15_r0_body.P60 2666 PRE_first_tail_x15_r0_body.kappa60 PRE_first_tail_x15_r0_body.cx0_60 PRE_first_tail_x15_r0_body.cx1_60 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot60 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost60 (compact_a_eq PRE_first_tail_x15_r0_body.ckn060 PRE_first_tail_x15_r0_body.ckn160 PRE_first_tail_x15_r0_body.ckheap60 PRE_first_tail_x15_r0_body.ckpl60)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_60 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s591.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_60 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s591.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_60 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s591.ffi) = some PRE_first_tail_x15_r0_body.fxC_60
kernel_rfl PRE_first_tail_x15_r0_body.okrC_60 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s591.ffi) = some PRE_first_tail_x15_r0_body.krC_60
noncomputable def PRE_first_tail_x15_r0_body.fx0_60 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s593.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_60 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s593.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_60 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s593.ffi) = some PRE_first_tail_x15_r0_body.fx0_60
kernel_rfl PRE_first_tail_x15_r0_body.okr0_60 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s593.ffi) = some PRE_first_tail_x15_r0_body.kr0_60
noncomputable def PRE_first_tail_x15_r0_body.fx1_60 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s592.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_60 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s592.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_60 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s592.ffi) = some PRE_first_tail_x15_r0_body.fx1_60
kernel_rfl PRE_first_tail_x15_r0_body.okr1_60 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s592.ffi) = some PRE_first_tail_x15_r0_body.kr1_60
kernel_rfl PRE_first_tail_x15_r0_body.ff060 : PRE_first_tail_x15_r0_body.fx0_60 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_60 (PRE_first_tail_x15_r0_body.clo60.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_60.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff160 : PRE_first_tail_x15_r0_body.fx1_60 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_60 (PRE_first_tail_x15_r0_body.cwS60.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_60.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck60 : freedLB PRE_first_tail_x15_r0_body.kappa60 PRE_first_tail_x15_r0_body.cx0_60.mlx PRE_first_tail_x15_r0_body.fx0_60 PRE_first_tail_x15_r0_body.fx1_60 PRE_first_tail_x15_r0_body.clo60 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf060 : PRE_first_tail_x15_r0_body.kr0_60.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_60.flags (PRE_first_tail_x15_r0_body.clo60.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_60.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt060 : PRE_first_tail_x15_r0_body.kr0_60.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_60.targs (PRE_first_tail_x15_r0_body.clo60.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_60.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf160 : PRE_first_tail_x15_r0_body.kr1_60.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_60.flags (PRE_first_tail_x15_r0_body.cwS60.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_60.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt160 : PRE_first_tail_x15_r0_body.kr1_60.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_60.targs (PRE_first_tail_x15_r0_body.cwS60.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_60.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck60 : krecLB PRE_first_tail_x15_r0_body.kappa60 2666 PRE_first_tail_x15_r0_body.cx0_60.mlx PRE_first_tail_x15_r0_body.kr0_60 PRE_first_tail_x15_r0_body.kr1_60 PRE_first_tail_x15_r0_body.clo60 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn60 : Nat.ble 2648 2666 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge60 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s592.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s593.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR60 : pendRegB PRE_first_tail_x15_r0_body.kappa60 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe60 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s592.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift60 (clean : Conv.NClean (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P60.NL) (cl : SSt (· < 2666) PRE_first_tail_x15_r0_body.cx0_60.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_60.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_60.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_60.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_60.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P60 2666 PRE_first_tail_x15_r0_body.kappa60 PRE_first_tail_x15_r0_body.s593.ffi PRE_first_tail_x15_r0_body.s592.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift60 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue60, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp60 t ht),
    PRE_first_tail_x15_r0_body.cbridge60,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s593.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s592.ffi) (PRE_first_tail_x15_r0_body.cfoot60 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_60 PRE_first_tail_x15_r0_body.ofx1_60 hobjC PRE_first_tail_x15_r0_body.ff060 PRE_first_tail_x15_r0_body.ff160 PRE_first_tail_x15_r0_body.ffck60,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s593.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s592.ffi) (PRE_first_tail_x15_r0_body.cfoot60 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_60 PRE_first_tail_x15_r0_body.okr1_60 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn60) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf060 PRE_first_tail_x15_r0_body.fkt060 PRE_first_tail_x15_r0_body.fkf160 PRE_first_tail_x15_r0_body.fkt160 PRE_first_tail_x15_r0_body.fkck60,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh060 PRE_first_tail_x15_r0_body.cnh160 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe60) PRE_first_tail_x15_r0_body.cpendR60⟩

end Host.Load.Run.Tpl

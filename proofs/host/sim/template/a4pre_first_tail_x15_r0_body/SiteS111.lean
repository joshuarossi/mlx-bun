import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl111
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 111 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc111 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P111 : LoadP := PRE_first_tail_x15_r0_body.Pc111.raise 17501
kernel_rfl PRE_first_tail_x15_r0_body.craise111 : Nat.ble PRE_first_tail_x15_r0_body.Pc111.N0 17501 = true
theorem PRE_first_tail_x15_r0_body.raised111 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc111 PRE_first_tail_x15_r0_body.P111 :=
  .inr ⟨17501, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise111, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_111 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1082.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_111 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1081.ffi)
def PRE_first_tail_x15_r0_body.khinv111 : PTrie Nat := Stage.setAll PTrie.nil [(20423, 20397), (20401, 20398), (20424, 20399)]
def PRE_first_tail_x15_r0_body.kninv111 : PTrie Nat := Stage.setAll PTrie.nil [(17474, 17474), (17475, 17475), (17476, 17476), (17477, 17477), (17478, 17478), (17479, 17479), (17480, 17480), (17481, 17481), (17482, 17482), (17483, 17483), (17484, 17484), (17485, 17485), (17486, 17486), (17487, 17487), (17488, 17488), (17489, 17489), (17490, 17490), (17491, 17491), (17492, 17492), (17493, 17493), (17494, 17494), (17495, 17495), (17496, 17496), (17497, 17497), (17498, 17498), (17499, 17499), (17500, 17500)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS111 : List Nat := [20377, 20390, 20396, 20397, 20398, 20399, 20400, 20401, 20402, 20403, 20404, 20405, 20406, 20407, 20408, 20409, 20410, 20411, 20412, 20413, 20414, 20415, 20416, 20417, 20418, 20419, 20420, 20421, 20422, 20423, 20424]
def PRE_first_tail_x15_r0_body.cnS111 : List Nat := List.range' 17474 27
def PRE_first_tail_x15_r0_body.ciS111 : List Nat := [] ++ List.range' 17474 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0111 : PRE_first_tail_x15_r0_body.kd111.nh0 = PRE_first_tail_x15_r0_body.cx0_111.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1111 : PRE_first_tail_x15_r0_body.kd111.nh1 = PRE_first_tail_x15_r0_body.cx1_111.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0111 : PRE_first_tail_x15_r0_body.kd111.nn0 = PRE_first_tail_x15_r0_body.cx0_111.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1111 : PRE_first_tail_x15_r0_body.kd111.nn1 = PRE_first_tail_x15_r0_body.cx1_111.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo111 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P111.lo && Nat.ble PRE_first_tail_x15_r0_body.P111.lo PRE_first_tail_x15_r0_body.cx0_111.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P111.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P111.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt111 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_111.mlx.next PRE_first_tail_x15_r0_body.cx1_111.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_111.mlx.nnext PRE_first_tail_x15_r0_body.cx1_111.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband111 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P111.NL && Nat.ble PRE_first_tail_x15_r0_body.P111.NL PRE_first_tail_x15_r0_body.P111.N0 && Nat.ble PRE_first_tail_x15_r0_body.P111.N0 PRE_first_tail_x15_r0_body.cx0_111.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow111 : PRE_first_tail_x15_r0_body.kd111.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren111 : checkRenG PRE_first_tail_x15_r0_body.kd111.hnd PRE_first_tail_x15_r0_body.khinv111 (phB PRE_first_tail_x15_r0_body.cx0_111.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband111 : PRE_first_tail_x15_r0_body.kd111.checkBand PRE_first_tail_x15_r0_body.P111.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos111 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd111.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren111 : checkRenG PRE_first_tail_x15_r0_body.kd111.node PRE_first_tail_x15_r0_body.kninv111 (pnB PRE_first_tail_x15_r0_body.cx0_111.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow111 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd111.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P111.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd111.nodeF j) PRE_first_tail_x15_r0_body.cx1_111.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a111 : PRE_first_tail_x15_r0_body.cx0_111.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b111 : PRE_first_tail_x15_r0_body.cx0_111.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1111 : PRE_first_tail_x15_r0_body.cx1_111.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend111 : PRE_first_tail_x15_r0_body.cx1_111.mlx.pending = PRE_first_tail_x15_r0_body.cx0_111.mlx.pending.map PRE_first_tail_x15_r0_body.kappa111.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh111 : PRE_first_tail_x15_r0_body.cx1_111.mlx.errh = PRE_first_tail_x15_r0_body.cx0_111.mlx.errh.map PRE_first_tail_x15_r0_body.kappa111.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles111 : PRE_first_tail_x15_r0_body.cx1_111.mlx.files = PRE_first_tail_x15_r0_body.cx0_111.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch111 : PRE_first_tail_x15_r0_body.cx1_111.mlx.arch = PRE_first_tail_x15_r0_body.cx0_111.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes111 : PRE_first_tail_x15_r0_body.cx1_111.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_111.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired111 : PRE_first_tail_x15_r0_body.cx1_111.mlx.wired = PRE_first_tail_x15_r0_body.cx0_111.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost111 : PRE_first_tail_x15_r0_body.cx1_111.host = PRE_first_tail_x15_r0_body.cx0_111.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd111`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0111 : PRE_first_tail_x15_r0_body.kd111.n0 = 2762473
kernel_rfl PRE_first_tail_x15_r0_body.ckn1111 : PRE_first_tail_x15_r0_body.kd111.n1 = 2763622
kernel_rfl PRE_first_tail_x15_r0_body.ckheap111 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd111.heap).all (fun x => Nat.ble 2762467 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl111 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd111.heap.get (2762467 + j) = nth? PRE_first_tail_x15_r0_body.pl111 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja111 : Nat.ble 2762467 2762467 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn111 : Nat.ble 4829 4829 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD111 : Nat.ble 2762467 PRE_first_tail_x15_r0_body.kd111.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn111 : Nat.ble 20397 PRE_first_tail_x15_r0_body.kd111.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn111 : Nat.ble 17474 PRE_first_tail_x15_r0_body.kd111.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb111 : Nat.ble 20397 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap111 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd111.heap).all (Nat.ble (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd111 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd111.hnd).all (Nat.ble (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode111 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd111.node).all (Nat.ble (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix111 : Conv.FixOld (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa111 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja111) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn111) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD111) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn111) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn111) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb111) PRE_first_tail_x15_r0_body.fheap111 PRE_first_tail_x15_r0_body.fhnd111 PRE_first_tail_x15_r0_body.fnode111
kernel_rfl PRE_first_tail_x15_r0_body.fcxn111 : (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn111 : (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0111 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_111.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_111.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk111 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd111.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A111 : PRE_first_tail_x15_r0_body.cx1_111.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS111.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_111.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O111 : PRE_first_tail_x15_r0_body.cx1_111.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS111.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_111.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N111 : PRE_first_tail_x15_r0_body.cx1_111.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS111.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_111.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I111 : PRE_first_tail_x15_r0_body.cx1_111.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS111.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_111.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd111 : (PRE_first_tail_x15_r0_body.clo111 ++ PRE_first_tail_x15_r0_body.cln111 ++ PRE_first_tail_x15_r0_body.cli111 ++ PRE_first_tail_x15_r0_body.cwS111 ++ PRE_first_tail_x15_r0_body.cnS111 ++ PRE_first_tail_x15_r0_body.ciS111).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW111 : PRE_first_tail_x15_r0_body.cwS111.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo111.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI111 : PRE_first_tail_x15_r0_body.ciS111.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli111.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN111 : PRE_first_tail_x15_r0_body.cnS111.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF111 : PRE_first_tail_x15_r0_body.cln111.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh111 : PRE_first_tail_x15_r0_body.clo111.all (handleOK PRE_first_tail_x15_r0_body.kappa111 PRE_first_tail_x15_r0_body.P111.lo PRE_first_tail_x15_r0_body.cx0_111.mlx PRE_first_tail_x15_r0_body.cx1_111.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo111 : PRE_first_tail_x15_r0_body.clo111.map (fun h => PRE_first_tail_x15_r0_body.cx1_111.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa111.handle h)) = PRE_first_tail_x15_r0_body.clo111.map (fun h => (PRE_first_tail_x15_r0_body.cx0_111.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa111.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok111 : PRE_first_tail_x15_r0_body.clo111.all (objOK PRE_first_tail_x15_r0_body.kappa111 PRE_first_tail_x15_r0_body.P111.NL PRE_first_tail_x15_r0_body.cx0_111.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd111 : PRE_first_tail_x15_r0_body.cln111.all (nodeOKF PRE_first_tail_x15_r0_body.kappa111 PRE_first_tail_x15_r0_body.P111 PRE_first_tail_x15_r0_body.cx0_111.mlx PRE_first_tail_x15_r0_body.cx1_111.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp111 : ((PRE_first_tail_x15_r0_body.cln111.filter (fullB PRE_first_tail_x15_r0_body.P111))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_111.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa111.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln111.filter (fullB PRE_first_tail_x15_r0_body.P111))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_111.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa111.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI111 : incrB PRE_first_tail_x15_r0_body.kd111.nodeF (List.range' 17474 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK111 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd111.node).all (fun k => Nat.ble 17474 k && Nat.blt k 17501) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL111 : (PRE_first_tail_x15_r0_body.cln111.filter (Nat.ble PRE_first_tail_x15_r0_body.P111.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd111.nodeF i) && (Nat.blt i 17501 || Nat.ble PRE_first_tail_x15_r0_body.kd111.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord111 : (PRE_first_tail_x15_r0_body.cln111.filter (Nat.ble PRE_first_tail_x15_r0_body.P111.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd111.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd111.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd111.nodeF j) (PRE_first_tail_x15_r0_body.kd111.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow111 PRE_first_tail_x15_r0_body.cnn1111 PRE_first_tail_x15_r0_body.fnordI111 PRE_first_tail_x15_r0_body.fnordK111 PRE_first_tail_x15_r0_body.fnordL111
kernel_rfl PRE_first_tail_x15_r0_body.fi111 : PRE_first_tail_x15_r0_body.cli111.all (pnB PRE_first_tail_x15_r0_body.cx0_111.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii111 : PRE_first_tail_x15_r0_body.cli111.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_111.mlx.items.get (PRE_first_tail_x15_r0_body.kappa111.node k) = (PRE_first_tail_x15_r0_body.cx0_111.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa111.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot111 (clean : Conv.NClean (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P111.NL) (cl : SSt (· < 4847) PRE_first_tail_x15_r0_body.cx0_111.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P111 4847 PRE_first_tail_x15_r0_body.kappa111 PRE_first_tail_x15_r0_body.kd111 PRE_first_tail_x15_r0_body.khinv111 PRE_first_tail_x15_r0_body.kninv111 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx PRE_first_tail_x15_r0_body.cx0_111.mlx PRE_first_tail_x15_r0_body.cx1_111.mlx (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo111 PRE_first_tail_x15_r0_body.cln111 PRE_first_tail_x15_r0_body.cli111 PRE_first_tail_x15_r0_body.cwS111 PRE_first_tail_x15_r0_body.cnS111 PRE_first_tail_x15_r0_body.ciS111 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0111, PRE_first_tail_x15_r0_body.cnh1111, PRE_first_tail_x15_r0_body.cnn0111, PRE_first_tail_x15_r0_body.cnn1111, PRE_first_tail_x15_r0_body.cplo111, PRE_first_tail_x15_r0_body.ccnt111, PRE_first_tail_x15_r0_body.cnband111, PRE_first_tail_x15_r0_body.chbelow111, PRE_first_tail_x15_r0_body.chren111, PRE_first_tail_x15_r0_body.cband111, PRE_first_tail_x15_r0_body.cnh1pos111, PRE_first_tail_x15_r0_body.cnren111, PRE_first_tail_x15_r0_body.cnlow111, PRE_first_tail_x15_r0_body.cabs0a111, PRE_first_tail_x15_r0_body.cabs0b111, PRE_first_tail_x15_r0_body.ctok1111, PRE_first_tail_x15_r0_body.cpend111, PRE_first_tail_x15_r0_body.cerrh111, PRE_first_tail_x15_r0_body.cfiles111, PRE_first_tail_x15_r0_body.carch111, PRE_first_tail_x15_r0_body.csizes111, PRE_first_tail_x15_r0_body.cwired111, PRE_first_tail_x15_r0_body.cfix111, clean, PRE_first_tail_x15_r0_body.fcxn111, PRE_first_tail_x15_r0_body.fcnn111, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0111, PRE_first_tail_x15_r0_body.fnk111, PRE_first_tail_x15_r0_body.ckA111, PRE_first_tail_x15_r0_body.cobjsK111, PRE_first_tail_x15_r0_body.cnodesK111, PRE_first_tail_x15_r0_body.citemsK111, PRE_first_tail_x15_r0_body.f1A111, PRE_first_tail_x15_r0_body.f1O111, PRE_first_tail_x15_r0_body.f1N111, PRE_first_tail_x15_r0_body.f1I111, PRE_first_tail_x15_r0_body.fbd111, PRE_first_tail_x15_r0_body.fincW111, PRE_first_tail_x15_r0_body.fincI111, PRE_first_tail_x15_r0_body.fincN111, PRE_first_tail_x15_r0_body.flnF111, PRE_first_tail_x15_r0_body.fh111, PRE_first_tail_x15_r0_body.fo111, PRE_first_tail_x15_r0_body.fok111, PRE_first_tail_x15_r0_body.fnd111, PRE_first_tail_x15_r0_body.fp111, PRE_first_tail_x15_r0_body.fnord111, PRE_first_tail_x15_r0_body.fi111, PRE_first_tail_x15_r0_body.fii111⟩
theorem PRE_first_tail_x15_r0_body.cnshift111 (clean : Conv.NClean (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P111.NL) (cl : SSt (· < 4847) PRE_first_tail_x15_r0_body.cx0_111.mlx) : NShift PRE_first_tail_x15_r0_body.P111 4847 PRE_first_tail_x15_r0_body.kappa111 PRE_first_tail_x15_r0_body.cx0_111 PRE_first_tail_x15_r0_body.cx1_111 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot111 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost111 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0111 PRE_first_tail_x15_r0_body.ckn1111 PRE_first_tail_x15_r0_body.ckheap111 PRE_first_tail_x15_r0_body.ckpl111)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_111 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1080.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_111 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1080.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_111 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1080.ffi) = some PRE_first_tail_x15_r0_body.fxC_111
kernel_rfl PRE_first_tail_x15_r0_body.okrC_111 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1080.ffi) = some PRE_first_tail_x15_r0_body.krC_111
noncomputable def PRE_first_tail_x15_r0_body.fx0_111 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1082.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_111 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1082.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_111 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1082.ffi) = some PRE_first_tail_x15_r0_body.fx0_111
kernel_rfl PRE_first_tail_x15_r0_body.okr0_111 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1082.ffi) = some PRE_first_tail_x15_r0_body.kr0_111
noncomputable def PRE_first_tail_x15_r0_body.fx1_111 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1081.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_111 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1081.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_111 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1081.ffi) = some PRE_first_tail_x15_r0_body.fx1_111
kernel_rfl PRE_first_tail_x15_r0_body.okr1_111 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1081.ffi) = some PRE_first_tail_x15_r0_body.kr1_111
kernel_rfl PRE_first_tail_x15_r0_body.ff0111 : PRE_first_tail_x15_r0_body.fx0_111 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_111 (PRE_first_tail_x15_r0_body.clo111.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_111.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1111 : PRE_first_tail_x15_r0_body.fx1_111 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_111 (PRE_first_tail_x15_r0_body.cwS111.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_111.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck111 : freedLB PRE_first_tail_x15_r0_body.kappa111 PRE_first_tail_x15_r0_body.cx0_111.mlx PRE_first_tail_x15_r0_body.fx0_111 PRE_first_tail_x15_r0_body.fx1_111 PRE_first_tail_x15_r0_body.clo111 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0111 : PRE_first_tail_x15_r0_body.kr0_111.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_111.flags (PRE_first_tail_x15_r0_body.clo111.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_111.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0111 : PRE_first_tail_x15_r0_body.kr0_111.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_111.targs (PRE_first_tail_x15_r0_body.clo111.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_111.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1111 : PRE_first_tail_x15_r0_body.kr1_111.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_111.flags (PRE_first_tail_x15_r0_body.cwS111.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_111.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1111 : PRE_first_tail_x15_r0_body.kr1_111.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_111.targs (PRE_first_tail_x15_r0_body.cwS111.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_111.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck111 : krecLB PRE_first_tail_x15_r0_body.kappa111 4847 PRE_first_tail_x15_r0_body.cx0_111.mlx PRE_first_tail_x15_r0_body.kr0_111 PRE_first_tail_x15_r0_body.kr1_111 PRE_first_tail_x15_r0_body.clo111 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn111 : Nat.ble 4829 4847 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge111 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1081.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1082.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR111 : pendRegB PRE_first_tail_x15_r0_body.kappa111 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1082.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe111 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1082.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1081.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift111 (clean : Conv.NClean (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P111.NL) (cl : SSt (· < 4847) PRE_first_tail_x15_r0_body.cx0_111.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_111.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_111.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_111.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_111.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P111 4847 PRE_first_tail_x15_r0_body.kappa111 PRE_first_tail_x15_r0_body.s1082.ffi PRE_first_tail_x15_r0_body.s1081.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift111 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue111, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp111 t ht),
    PRE_first_tail_x15_r0_body.cbridge111,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1082.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1081.ffi) (PRE_first_tail_x15_r0_body.cfoot111 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_111 PRE_first_tail_x15_r0_body.ofx1_111 hobjC PRE_first_tail_x15_r0_body.ff0111 PRE_first_tail_x15_r0_body.ff1111 PRE_first_tail_x15_r0_body.ffck111,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1082.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1081.ffi) (PRE_first_tail_x15_r0_body.cfoot111 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_111 PRE_first_tail_x15_r0_body.okr1_111 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn111) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0111 PRE_first_tail_x15_r0_body.fkt0111 PRE_first_tail_x15_r0_body.fkf1111 PRE_first_tail_x15_r0_body.fkt1111 PRE_first_tail_x15_r0_body.fkck111,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0111 PRE_first_tail_x15_r0_body.cnh1111 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe111) PRE_first_tail_x15_r0_body.cpendR111⟩

end Host.Load.Run.Tpl

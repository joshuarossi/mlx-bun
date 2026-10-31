import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl159
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 159 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc159 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P159 : LoadP := PRE_first_tail_x15_r0_body.Pc159.raise 18449
kernel_rfl PRE_first_tail_x15_r0_body.craise159 : Nat.ble PRE_first_tail_x15_r0_body.Pc159.N0 18449 = true
theorem PRE_first_tail_x15_r0_body.raised159 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc159 PRE_first_tail_x15_r0_body.P159 :=
  .inr ⟨18449, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise159, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_159 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1542.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_159 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1541.ffi)
def PRE_first_tail_x15_r0_body.khinv159 : PTrie Nat := Stage.setAll PTrie.nil [(21367, 21341), (21345, 21342), (21368, 21343)]
def PRE_first_tail_x15_r0_body.kninv159 : PTrie Nat := Stage.setAll PTrie.nil [(18422, 18422), (18423, 18423), (18424, 18424), (18425, 18425), (18426, 18426), (18427, 18427), (18428, 18428), (18429, 18429), (18430, 18430), (18431, 18431), (18432, 18432), (18433, 18433), (18434, 18434), (18435, 18435), (18436, 18436), (18437, 18437), (18438, 18438), (18439, 18439), (18440, 18440), (18441, 18441), (18442, 18442), (18443, 18443), (18444, 18444), (18445, 18445), (18446, 18446), (18447, 18447), (18448, 18448)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS159 : List Nat := [21321, 21334, 21340, 21341, 21342, 21343, 21344, 21345, 21346, 21347, 21348, 21349, 21350, 21351, 21352, 21353, 21354, 21355, 21356, 21357, 21358, 21359, 21360, 21361, 21362, 21363, 21364, 21365, 21366, 21367, 21368]
def PRE_first_tail_x15_r0_body.cnS159 : List Nat := List.range' 18422 27
def PRE_first_tail_x15_r0_body.ciS159 : List Nat := [] ++ List.range' 18422 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0159 : PRE_first_tail_x15_r0_body.kd159.nh0 = PRE_first_tail_x15_r0_body.cx0_159.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1159 : PRE_first_tail_x15_r0_body.kd159.nh1 = PRE_first_tail_x15_r0_body.cx1_159.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0159 : PRE_first_tail_x15_r0_body.kd159.nn0 = PRE_first_tail_x15_r0_body.cx0_159.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1159 : PRE_first_tail_x15_r0_body.kd159.nn1 = PRE_first_tail_x15_r0_body.cx1_159.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo159 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P159.lo && Nat.ble PRE_first_tail_x15_r0_body.P159.lo PRE_first_tail_x15_r0_body.cx0_159.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P159.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P159.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt159 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_159.mlx.next PRE_first_tail_x15_r0_body.cx1_159.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_159.mlx.nnext PRE_first_tail_x15_r0_body.cx1_159.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband159 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P159.NL && Nat.ble PRE_first_tail_x15_r0_body.P159.NL PRE_first_tail_x15_r0_body.P159.N0 && Nat.ble PRE_first_tail_x15_r0_body.P159.N0 PRE_first_tail_x15_r0_body.cx0_159.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow159 : PRE_first_tail_x15_r0_body.kd159.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren159 : checkRenG PRE_first_tail_x15_r0_body.kd159.hnd PRE_first_tail_x15_r0_body.khinv159 (phB PRE_first_tail_x15_r0_body.cx0_159.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband159 : PRE_first_tail_x15_r0_body.kd159.checkBand PRE_first_tail_x15_r0_body.P159.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos159 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd159.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren159 : checkRenG PRE_first_tail_x15_r0_body.kd159.node PRE_first_tail_x15_r0_body.kninv159 (pnB PRE_first_tail_x15_r0_body.cx0_159.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow159 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd159.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P159.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd159.nodeF j) PRE_first_tail_x15_r0_body.cx1_159.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a159 : PRE_first_tail_x15_r0_body.cx0_159.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b159 : PRE_first_tail_x15_r0_body.cx0_159.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1159 : PRE_first_tail_x15_r0_body.cx1_159.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend159 : PRE_first_tail_x15_r0_body.cx1_159.mlx.pending = PRE_first_tail_x15_r0_body.cx0_159.mlx.pending.map PRE_first_tail_x15_r0_body.kappa159.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh159 : PRE_first_tail_x15_r0_body.cx1_159.mlx.errh = PRE_first_tail_x15_r0_body.cx0_159.mlx.errh.map PRE_first_tail_x15_r0_body.kappa159.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles159 : PRE_first_tail_x15_r0_body.cx1_159.mlx.files = PRE_first_tail_x15_r0_body.cx0_159.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch159 : PRE_first_tail_x15_r0_body.cx1_159.mlx.arch = PRE_first_tail_x15_r0_body.cx0_159.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes159 : PRE_first_tail_x15_r0_body.cx1_159.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_159.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired159 : PRE_first_tail_x15_r0_body.cx1_159.mlx.wired = PRE_first_tail_x15_r0_body.cx0_159.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost159 : PRE_first_tail_x15_r0_body.cx1_159.host = PRE_first_tail_x15_r0_body.cx0_159.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd159`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0159 : PRE_first_tail_x15_r0_body.kd159.n0 = 2800141
kernel_rfl PRE_first_tail_x15_r0_body.ckn1159 : PRE_first_tail_x15_r0_body.kd159.n1 = 2801290
kernel_rfl PRE_first_tail_x15_r0_body.ckheap159 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd159.heap).all (fun x => Nat.ble 2800135 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl159 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd159.heap.get (2800135 + j) = nth? PRE_first_tail_x15_r0_body.pl159 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja159 : Nat.ble 2800135 2800135 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn159 : Nat.ble 6881 6881 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD159 : Nat.ble 2800135 PRE_first_tail_x15_r0_body.kd159.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn159 : Nat.ble 21341 PRE_first_tail_x15_r0_body.kd159.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn159 : Nat.ble 18422 PRE_first_tail_x15_r0_body.kd159.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb159 : Nat.ble 21341 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap159 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd159.heap).all (Nat.ble (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd159 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd159.hnd).all (Nat.ble (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode159 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd159.node).all (Nat.ble (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix159 : Conv.FixOld (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa159 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja159) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn159) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD159) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn159) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn159) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb159) PRE_first_tail_x15_r0_body.fheap159 PRE_first_tail_x15_r0_body.fhnd159 PRE_first_tail_x15_r0_body.fnode159
kernel_rfl PRE_first_tail_x15_r0_body.fcxn159 : (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn159 : (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0159 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_159.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_159.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk159 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd159.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A159 : PRE_first_tail_x15_r0_body.cx1_159.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS159.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_159.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O159 : PRE_first_tail_x15_r0_body.cx1_159.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS159.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_159.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N159 : PRE_first_tail_x15_r0_body.cx1_159.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS159.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_159.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I159 : PRE_first_tail_x15_r0_body.cx1_159.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS159.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_159.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd159 : (PRE_first_tail_x15_r0_body.clo159 ++ PRE_first_tail_x15_r0_body.cln159 ++ PRE_first_tail_x15_r0_body.cli159 ++ PRE_first_tail_x15_r0_body.cwS159 ++ PRE_first_tail_x15_r0_body.cnS159 ++ PRE_first_tail_x15_r0_body.ciS159).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW159 : PRE_first_tail_x15_r0_body.cwS159.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo159.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI159 : PRE_first_tail_x15_r0_body.ciS159.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli159.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN159 : PRE_first_tail_x15_r0_body.cnS159.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF159 : PRE_first_tail_x15_r0_body.cln159.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh159 : PRE_first_tail_x15_r0_body.clo159.all (handleOK PRE_first_tail_x15_r0_body.kappa159 PRE_first_tail_x15_r0_body.P159.lo PRE_first_tail_x15_r0_body.cx0_159.mlx PRE_first_tail_x15_r0_body.cx1_159.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo159 : PRE_first_tail_x15_r0_body.clo159.map (fun h => PRE_first_tail_x15_r0_body.cx1_159.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa159.handle h)) = PRE_first_tail_x15_r0_body.clo159.map (fun h => (PRE_first_tail_x15_r0_body.cx0_159.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa159.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok159 : PRE_first_tail_x15_r0_body.clo159.all (objOK PRE_first_tail_x15_r0_body.kappa159 PRE_first_tail_x15_r0_body.P159.NL PRE_first_tail_x15_r0_body.cx0_159.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd159 : PRE_first_tail_x15_r0_body.cln159.all (nodeOKF PRE_first_tail_x15_r0_body.kappa159 PRE_first_tail_x15_r0_body.P159 PRE_first_tail_x15_r0_body.cx0_159.mlx PRE_first_tail_x15_r0_body.cx1_159.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp159 : ((PRE_first_tail_x15_r0_body.cln159.filter (fullB PRE_first_tail_x15_r0_body.P159))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_159.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa159.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln159.filter (fullB PRE_first_tail_x15_r0_body.P159))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_159.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa159.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI159 : incrB PRE_first_tail_x15_r0_body.kd159.nodeF (List.range' 18422 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK159 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd159.node).all (fun k => Nat.ble 18422 k && Nat.blt k 18449) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL159 : (PRE_first_tail_x15_r0_body.cln159.filter (Nat.ble PRE_first_tail_x15_r0_body.P159.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd159.nodeF i) && (Nat.blt i 18449 || Nat.ble PRE_first_tail_x15_r0_body.kd159.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord159 : (PRE_first_tail_x15_r0_body.cln159.filter (Nat.ble PRE_first_tail_x15_r0_body.P159.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd159.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd159.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd159.nodeF j) (PRE_first_tail_x15_r0_body.kd159.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow159 PRE_first_tail_x15_r0_body.cnn1159 PRE_first_tail_x15_r0_body.fnordI159 PRE_first_tail_x15_r0_body.fnordK159 PRE_first_tail_x15_r0_body.fnordL159
kernel_rfl PRE_first_tail_x15_r0_body.fi159 : PRE_first_tail_x15_r0_body.cli159.all (pnB PRE_first_tail_x15_r0_body.cx0_159.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii159 : PRE_first_tail_x15_r0_body.cli159.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_159.mlx.items.get (PRE_first_tail_x15_r0_body.kappa159.node k) = (PRE_first_tail_x15_r0_body.cx0_159.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa159.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot159 (clean : Conv.NClean (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P159.NL) (cl : SSt (· < 6899) PRE_first_tail_x15_r0_body.cx0_159.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P159 6899 PRE_first_tail_x15_r0_body.kappa159 PRE_first_tail_x15_r0_body.kd159 PRE_first_tail_x15_r0_body.khinv159 PRE_first_tail_x15_r0_body.kninv159 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx PRE_first_tail_x15_r0_body.cx0_159.mlx PRE_first_tail_x15_r0_body.cx1_159.mlx (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo159 PRE_first_tail_x15_r0_body.cln159 PRE_first_tail_x15_r0_body.cli159 PRE_first_tail_x15_r0_body.cwS159 PRE_first_tail_x15_r0_body.cnS159 PRE_first_tail_x15_r0_body.ciS159 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0159, PRE_first_tail_x15_r0_body.cnh1159, PRE_first_tail_x15_r0_body.cnn0159, PRE_first_tail_x15_r0_body.cnn1159, PRE_first_tail_x15_r0_body.cplo159, PRE_first_tail_x15_r0_body.ccnt159, PRE_first_tail_x15_r0_body.cnband159, PRE_first_tail_x15_r0_body.chbelow159, PRE_first_tail_x15_r0_body.chren159, PRE_first_tail_x15_r0_body.cband159, PRE_first_tail_x15_r0_body.cnh1pos159, PRE_first_tail_x15_r0_body.cnren159, PRE_first_tail_x15_r0_body.cnlow159, PRE_first_tail_x15_r0_body.cabs0a159, PRE_first_tail_x15_r0_body.cabs0b159, PRE_first_tail_x15_r0_body.ctok1159, PRE_first_tail_x15_r0_body.cpend159, PRE_first_tail_x15_r0_body.cerrh159, PRE_first_tail_x15_r0_body.cfiles159, PRE_first_tail_x15_r0_body.carch159, PRE_first_tail_x15_r0_body.csizes159, PRE_first_tail_x15_r0_body.cwired159, PRE_first_tail_x15_r0_body.cfix159, clean, PRE_first_tail_x15_r0_body.fcxn159, PRE_first_tail_x15_r0_body.fcnn159, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0159, PRE_first_tail_x15_r0_body.fnk159, PRE_first_tail_x15_r0_body.ckA159, PRE_first_tail_x15_r0_body.cobjsK159, PRE_first_tail_x15_r0_body.cnodesK159, PRE_first_tail_x15_r0_body.citemsK159, PRE_first_tail_x15_r0_body.f1A159, PRE_first_tail_x15_r0_body.f1O159, PRE_first_tail_x15_r0_body.f1N159, PRE_first_tail_x15_r0_body.f1I159, PRE_first_tail_x15_r0_body.fbd159, PRE_first_tail_x15_r0_body.fincW159, PRE_first_tail_x15_r0_body.fincI159, PRE_first_tail_x15_r0_body.fincN159, PRE_first_tail_x15_r0_body.flnF159, PRE_first_tail_x15_r0_body.fh159, PRE_first_tail_x15_r0_body.fo159, PRE_first_tail_x15_r0_body.fok159, PRE_first_tail_x15_r0_body.fnd159, PRE_first_tail_x15_r0_body.fp159, PRE_first_tail_x15_r0_body.fnord159, PRE_first_tail_x15_r0_body.fi159, PRE_first_tail_x15_r0_body.fii159⟩
theorem PRE_first_tail_x15_r0_body.cnshift159 (clean : Conv.NClean (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P159.NL) (cl : SSt (· < 6899) PRE_first_tail_x15_r0_body.cx0_159.mlx) : NShift PRE_first_tail_x15_r0_body.P159 6899 PRE_first_tail_x15_r0_body.kappa159 PRE_first_tail_x15_r0_body.cx0_159 PRE_first_tail_x15_r0_body.cx1_159 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot159 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost159 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0159 PRE_first_tail_x15_r0_body.ckn1159 PRE_first_tail_x15_r0_body.ckheap159 PRE_first_tail_x15_r0_body.ckpl159)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_159 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1540.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_159 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1540.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_159 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1540.ffi) = some PRE_first_tail_x15_r0_body.fxC_159
kernel_rfl PRE_first_tail_x15_r0_body.okrC_159 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1540.ffi) = some PRE_first_tail_x15_r0_body.krC_159
noncomputable def PRE_first_tail_x15_r0_body.fx0_159 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1542.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_159 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1542.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_159 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1542.ffi) = some PRE_first_tail_x15_r0_body.fx0_159
kernel_rfl PRE_first_tail_x15_r0_body.okr0_159 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1542.ffi) = some PRE_first_tail_x15_r0_body.kr0_159
noncomputable def PRE_first_tail_x15_r0_body.fx1_159 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1541.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_159 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1541.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_159 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1541.ffi) = some PRE_first_tail_x15_r0_body.fx1_159
kernel_rfl PRE_first_tail_x15_r0_body.okr1_159 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1541.ffi) = some PRE_first_tail_x15_r0_body.kr1_159
kernel_rfl PRE_first_tail_x15_r0_body.ff0159 : PRE_first_tail_x15_r0_body.fx0_159 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_159 (PRE_first_tail_x15_r0_body.clo159.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_159.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1159 : PRE_first_tail_x15_r0_body.fx1_159 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_159 (PRE_first_tail_x15_r0_body.cwS159.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_159.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck159 : freedLB PRE_first_tail_x15_r0_body.kappa159 PRE_first_tail_x15_r0_body.cx0_159.mlx PRE_first_tail_x15_r0_body.fx0_159 PRE_first_tail_x15_r0_body.fx1_159 PRE_first_tail_x15_r0_body.clo159 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0159 : PRE_first_tail_x15_r0_body.kr0_159.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_159.flags (PRE_first_tail_x15_r0_body.clo159.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_159.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0159 : PRE_first_tail_x15_r0_body.kr0_159.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_159.targs (PRE_first_tail_x15_r0_body.clo159.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_159.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1159 : PRE_first_tail_x15_r0_body.kr1_159.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_159.flags (PRE_first_tail_x15_r0_body.cwS159.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_159.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1159 : PRE_first_tail_x15_r0_body.kr1_159.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_159.targs (PRE_first_tail_x15_r0_body.cwS159.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_159.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck159 : krecLB PRE_first_tail_x15_r0_body.kappa159 6899 PRE_first_tail_x15_r0_body.cx0_159.mlx PRE_first_tail_x15_r0_body.kr0_159 PRE_first_tail_x15_r0_body.kr1_159 PRE_first_tail_x15_r0_body.clo159 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn159 : Nat.ble 6881 6899 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge159 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1541.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1542.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR159 : pendRegB PRE_first_tail_x15_r0_body.kappa159 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1542.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe159 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1542.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1541.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift159 (clean : Conv.NClean (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P159.NL) (cl : SSt (· < 6899) PRE_first_tail_x15_r0_body.cx0_159.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_159.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_159.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_159.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_159.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P159 6899 PRE_first_tail_x15_r0_body.kappa159 PRE_first_tail_x15_r0_body.s1542.ffi PRE_first_tail_x15_r0_body.s1541.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift159 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue159, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp159 t ht),
    PRE_first_tail_x15_r0_body.cbridge159,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1542.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1541.ffi) (PRE_first_tail_x15_r0_body.cfoot159 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_159 PRE_first_tail_x15_r0_body.ofx1_159 hobjC PRE_first_tail_x15_r0_body.ff0159 PRE_first_tail_x15_r0_body.ff1159 PRE_first_tail_x15_r0_body.ffck159,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1542.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1541.ffi) (PRE_first_tail_x15_r0_body.cfoot159 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_159 PRE_first_tail_x15_r0_body.okr1_159 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn159) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0159 PRE_first_tail_x15_r0_body.fkt0159 PRE_first_tail_x15_r0_body.fkf1159 PRE_first_tail_x15_r0_body.fkt1159 PRE_first_tail_x15_r0_body.fkck159,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0159 PRE_first_tail_x15_r0_body.cnh1159 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe159) PRE_first_tail_x15_r0_body.cpendR159⟩

end Host.Load.Run.Tpl

import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl108
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 108 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc108 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P108 : LoadP := PRE_first_tail_x15_r0_body.Pc108.raise 17438
kernel_rfl PRE_first_tail_x15_r0_body.craise108 : Nat.ble PRE_first_tail_x15_r0_body.Pc108.N0 17438 = true
theorem PRE_first_tail_x15_r0_body.raised108 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc108 PRE_first_tail_x15_r0_body.P108 :=
  .inr ⟨17438, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise108, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_108 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s961.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_108 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s960.ffi)
def PRE_first_tail_x15_r0_body.khinv108 : PTrie Nat := Stage.setAll PTrie.nil [(20366, 20340), (20344, 20341), (20367, 20342)]
def PRE_first_tail_x15_r0_body.kninv108 : PTrie Nat := Stage.setAll PTrie.nil [(17411, 17411), (17412, 17412), (17413, 17413), (17414, 17414), (17415, 17415), (17416, 17416), (17417, 17417), (17418, 17418), (17419, 17419), (17420, 17420), (17421, 17421), (17422, 17422), (17423, 17423), (17424, 17424), (17425, 17425), (17426, 17426), (17427, 17427), (17428, 17428), (17429, 17429), (17430, 17430), (17431, 17431), (17432, 17432), (17433, 17433), (17434, 17434), (17435, 17435), (17436, 17436), (17437, 17437)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS108 : List Nat := [20320, 20333, 20339, 20340, 20341, 20342, 20343, 20344, 20345, 20346, 20347, 20348, 20349, 20350, 20351, 20352, 20353, 20354, 20355, 20356, 20357, 20358, 20359, 20360, 20361, 20362, 20363, 20364, 20365, 20366, 20367]
def PRE_first_tail_x15_r0_body.cnS108 : List Nat := List.range' 17411 27
def PRE_first_tail_x15_r0_body.ciS108 : List Nat := [] ++ List.range' 17411 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0108 : PRE_first_tail_x15_r0_body.kd108.nh0 = PRE_first_tail_x15_r0_body.cx0_108.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1108 : PRE_first_tail_x15_r0_body.kd108.nh1 = PRE_first_tail_x15_r0_body.cx1_108.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0108 : PRE_first_tail_x15_r0_body.kd108.nn0 = PRE_first_tail_x15_r0_body.cx0_108.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1108 : PRE_first_tail_x15_r0_body.kd108.nn1 = PRE_first_tail_x15_r0_body.cx1_108.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo108 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P108.lo && Nat.ble PRE_first_tail_x15_r0_body.P108.lo PRE_first_tail_x15_r0_body.cx0_108.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P108.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P108.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt108 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_108.mlx.next PRE_first_tail_x15_r0_body.cx1_108.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_108.mlx.nnext PRE_first_tail_x15_r0_body.cx1_108.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband108 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P108.NL && Nat.ble PRE_first_tail_x15_r0_body.P108.NL PRE_first_tail_x15_r0_body.P108.N0 && Nat.ble PRE_first_tail_x15_r0_body.P108.N0 PRE_first_tail_x15_r0_body.cx0_108.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow108 : PRE_first_tail_x15_r0_body.kd108.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren108 : checkRenG PRE_first_tail_x15_r0_body.kd108.hnd PRE_first_tail_x15_r0_body.khinv108 (phB PRE_first_tail_x15_r0_body.cx0_108.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband108 : PRE_first_tail_x15_r0_body.kd108.checkBand PRE_first_tail_x15_r0_body.P108.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos108 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd108.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren108 : checkRenG PRE_first_tail_x15_r0_body.kd108.node PRE_first_tail_x15_r0_body.kninv108 (pnB PRE_first_tail_x15_r0_body.cx0_108.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow108 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd108.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P108.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd108.nodeF j) PRE_first_tail_x15_r0_body.cx1_108.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a108 : PRE_first_tail_x15_r0_body.cx0_108.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b108 : PRE_first_tail_x15_r0_body.cx0_108.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1108 : PRE_first_tail_x15_r0_body.cx1_108.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend108 : PRE_first_tail_x15_r0_body.cx1_108.mlx.pending = PRE_first_tail_x15_r0_body.cx0_108.mlx.pending.map PRE_first_tail_x15_r0_body.kappa108.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh108 : PRE_first_tail_x15_r0_body.cx1_108.mlx.errh = PRE_first_tail_x15_r0_body.cx0_108.mlx.errh.map PRE_first_tail_x15_r0_body.kappa108.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles108 : PRE_first_tail_x15_r0_body.cx1_108.mlx.files = PRE_first_tail_x15_r0_body.cx0_108.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch108 : PRE_first_tail_x15_r0_body.cx1_108.mlx.arch = PRE_first_tail_x15_r0_body.cx0_108.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes108 : PRE_first_tail_x15_r0_body.cx1_108.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_108.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired108 : PRE_first_tail_x15_r0_body.cx1_108.mlx.wired = PRE_first_tail_x15_r0_body.cx0_108.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost108 : PRE_first_tail_x15_r0_body.cx1_108.host = PRE_first_tail_x15_r0_body.cx0_108.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd108`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0108 : PRE_first_tail_x15_r0_body.kd108.n0 = 2760217
kernel_rfl PRE_first_tail_x15_r0_body.ckn1108 : PRE_first_tail_x15_r0_body.kd108.n1 = 2761366
kernel_rfl PRE_first_tail_x15_r0_body.ckheap108 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd108.heap).all (fun x => Nat.ble 2760211 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl108 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd108.heap.get (2760211 + j) = nth? PRE_first_tail_x15_r0_body.pl108 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja108 : Nat.ble 2760211 2760211 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn108 : Nat.ble 4700 4700 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD108 : Nat.ble 2760211 PRE_first_tail_x15_r0_body.kd108.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn108 : Nat.ble 20340 PRE_first_tail_x15_r0_body.kd108.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn108 : Nat.ble 17411 PRE_first_tail_x15_r0_body.kd108.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb108 : Nat.ble 20340 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap108 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd108.heap).all (Nat.ble (⟨20340, 17411, 2760211, 4700⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd108 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd108.hnd).all (Nat.ble (⟨20340, 17411, 2760211, 4700⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode108 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd108.node).all (Nat.ble (⟨20340, 17411, 2760211, 4700⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix108 : Conv.FixOld (⟨20340, 17411, 2760211, 4700⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa108 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja108) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn108) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD108) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn108) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn108) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb108) PRE_first_tail_x15_r0_body.fheap108 PRE_first_tail_x15_r0_body.fhnd108 PRE_first_tail_x15_r0_body.fnode108
kernel_rfl PRE_first_tail_x15_r0_body.fcxn108 : (⟨20340, 17411, 2760211, 4700⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn108 : (⟨20340, 17411, 2760211, 4700⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0108 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_108.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_108.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk108 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd108.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A108 : PRE_first_tail_x15_r0_body.cx1_108.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS108.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_108.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O108 : PRE_first_tail_x15_r0_body.cx1_108.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS108.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_108.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N108 : PRE_first_tail_x15_r0_body.cx1_108.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS108.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_108.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I108 : PRE_first_tail_x15_r0_body.cx1_108.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS108.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_108.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd108 : (PRE_first_tail_x15_r0_body.clo108 ++ PRE_first_tail_x15_r0_body.cln108 ++ PRE_first_tail_x15_r0_body.cli108 ++ PRE_first_tail_x15_r0_body.cwS108 ++ PRE_first_tail_x15_r0_body.cnS108 ++ PRE_first_tail_x15_r0_body.ciS108).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW108 : PRE_first_tail_x15_r0_body.cwS108.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo108.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI108 : PRE_first_tail_x15_r0_body.ciS108.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli108.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN108 : PRE_first_tail_x15_r0_body.cnS108.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF108 : PRE_first_tail_x15_r0_body.cln108.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh108 : PRE_first_tail_x15_r0_body.clo108.all (handleOK PRE_first_tail_x15_r0_body.kappa108 PRE_first_tail_x15_r0_body.P108.lo PRE_first_tail_x15_r0_body.cx0_108.mlx PRE_first_tail_x15_r0_body.cx1_108.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo108 : PRE_first_tail_x15_r0_body.clo108.map (fun h => PRE_first_tail_x15_r0_body.cx1_108.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa108.handle h)) = PRE_first_tail_x15_r0_body.clo108.map (fun h => (PRE_first_tail_x15_r0_body.cx0_108.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa108.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok108 : PRE_first_tail_x15_r0_body.clo108.all (objOK PRE_first_tail_x15_r0_body.kappa108 PRE_first_tail_x15_r0_body.P108.NL PRE_first_tail_x15_r0_body.cx0_108.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd108 : PRE_first_tail_x15_r0_body.cln108.all (nodeOKF PRE_first_tail_x15_r0_body.kappa108 PRE_first_tail_x15_r0_body.P108 PRE_first_tail_x15_r0_body.cx0_108.mlx PRE_first_tail_x15_r0_body.cx1_108.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp108 : ((PRE_first_tail_x15_r0_body.cln108.filter (fullB PRE_first_tail_x15_r0_body.P108))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_108.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa108.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln108.filter (fullB PRE_first_tail_x15_r0_body.P108))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_108.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa108.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI108 : incrB PRE_first_tail_x15_r0_body.kd108.nodeF (List.range' 17411 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK108 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd108.node).all (fun k => Nat.ble 17411 k && Nat.blt k 17438) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL108 : (PRE_first_tail_x15_r0_body.cln108.filter (Nat.ble PRE_first_tail_x15_r0_body.P108.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd108.nodeF i) && (Nat.blt i 17438 || Nat.ble PRE_first_tail_x15_r0_body.kd108.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord108 : (PRE_first_tail_x15_r0_body.cln108.filter (Nat.ble PRE_first_tail_x15_r0_body.P108.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd108.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd108.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd108.nodeF j) (PRE_first_tail_x15_r0_body.kd108.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow108 PRE_first_tail_x15_r0_body.cnn1108 PRE_first_tail_x15_r0_body.fnordI108 PRE_first_tail_x15_r0_body.fnordK108 PRE_first_tail_x15_r0_body.fnordL108
kernel_rfl PRE_first_tail_x15_r0_body.fi108 : PRE_first_tail_x15_r0_body.cli108.all (pnB PRE_first_tail_x15_r0_body.cx0_108.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii108 : PRE_first_tail_x15_r0_body.cli108.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_108.mlx.items.get (PRE_first_tail_x15_r0_body.kappa108.node k) = (PRE_first_tail_x15_r0_body.cx0_108.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa108.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot108 (clean : Conv.NClean (⟨20340, 17411, 2760211, 4700⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P108.NL) (cl : SSt (· < 4718) PRE_first_tail_x15_r0_body.cx0_108.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P108 4718 PRE_first_tail_x15_r0_body.kappa108 PRE_first_tail_x15_r0_body.kd108 PRE_first_tail_x15_r0_body.khinv108 PRE_first_tail_x15_r0_body.kninv108 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx PRE_first_tail_x15_r0_body.cx0_108.mlx PRE_first_tail_x15_r0_body.cx1_108.mlx (⟨20340, 17411, 2760211, 4700⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo108 PRE_first_tail_x15_r0_body.cln108 PRE_first_tail_x15_r0_body.cli108 PRE_first_tail_x15_r0_body.cwS108 PRE_first_tail_x15_r0_body.cnS108 PRE_first_tail_x15_r0_body.ciS108 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0108, PRE_first_tail_x15_r0_body.cnh1108, PRE_first_tail_x15_r0_body.cnn0108, PRE_first_tail_x15_r0_body.cnn1108, PRE_first_tail_x15_r0_body.cplo108, PRE_first_tail_x15_r0_body.ccnt108, PRE_first_tail_x15_r0_body.cnband108, PRE_first_tail_x15_r0_body.chbelow108, PRE_first_tail_x15_r0_body.chren108, PRE_first_tail_x15_r0_body.cband108, PRE_first_tail_x15_r0_body.cnh1pos108, PRE_first_tail_x15_r0_body.cnren108, PRE_first_tail_x15_r0_body.cnlow108, PRE_first_tail_x15_r0_body.cabs0a108, PRE_first_tail_x15_r0_body.cabs0b108, PRE_first_tail_x15_r0_body.ctok1108, PRE_first_tail_x15_r0_body.cpend108, PRE_first_tail_x15_r0_body.cerrh108, PRE_first_tail_x15_r0_body.cfiles108, PRE_first_tail_x15_r0_body.carch108, PRE_first_tail_x15_r0_body.csizes108, PRE_first_tail_x15_r0_body.cwired108, PRE_first_tail_x15_r0_body.cfix108, clean, PRE_first_tail_x15_r0_body.fcxn108, PRE_first_tail_x15_r0_body.fcnn108, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0108, PRE_first_tail_x15_r0_body.fnk108, PRE_first_tail_x15_r0_body.ckA108, PRE_first_tail_x15_r0_body.cobjsK108, PRE_first_tail_x15_r0_body.cnodesK108, PRE_first_tail_x15_r0_body.citemsK108, PRE_first_tail_x15_r0_body.f1A108, PRE_first_tail_x15_r0_body.f1O108, PRE_first_tail_x15_r0_body.f1N108, PRE_first_tail_x15_r0_body.f1I108, PRE_first_tail_x15_r0_body.fbd108, PRE_first_tail_x15_r0_body.fincW108, PRE_first_tail_x15_r0_body.fincI108, PRE_first_tail_x15_r0_body.fincN108, PRE_first_tail_x15_r0_body.flnF108, PRE_first_tail_x15_r0_body.fh108, PRE_first_tail_x15_r0_body.fo108, PRE_first_tail_x15_r0_body.fok108, PRE_first_tail_x15_r0_body.fnd108, PRE_first_tail_x15_r0_body.fp108, PRE_first_tail_x15_r0_body.fnord108, PRE_first_tail_x15_r0_body.fi108, PRE_first_tail_x15_r0_body.fii108⟩
theorem PRE_first_tail_x15_r0_body.cnshift108 (clean : Conv.NClean (⟨20340, 17411, 2760211, 4700⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P108.NL) (cl : SSt (· < 4718) PRE_first_tail_x15_r0_body.cx0_108.mlx) : NShift PRE_first_tail_x15_r0_body.P108 4718 PRE_first_tail_x15_r0_body.kappa108 PRE_first_tail_x15_r0_body.cx0_108 PRE_first_tail_x15_r0_body.cx1_108 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot108 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost108 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0108 PRE_first_tail_x15_r0_body.ckn1108 PRE_first_tail_x15_r0_body.ckheap108 PRE_first_tail_x15_r0_body.ckpl108)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_108 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s959.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_108 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s959.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_108 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s959.ffi) = some PRE_first_tail_x15_r0_body.fxC_108
kernel_rfl PRE_first_tail_x15_r0_body.okrC_108 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s959.ffi) = some PRE_first_tail_x15_r0_body.krC_108
noncomputable def PRE_first_tail_x15_r0_body.fx0_108 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s961.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_108 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s961.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_108 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s961.ffi) = some PRE_first_tail_x15_r0_body.fx0_108
kernel_rfl PRE_first_tail_x15_r0_body.okr0_108 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s961.ffi) = some PRE_first_tail_x15_r0_body.kr0_108
noncomputable def PRE_first_tail_x15_r0_body.fx1_108 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s960.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_108 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s960.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_108 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s960.ffi) = some PRE_first_tail_x15_r0_body.fx1_108
kernel_rfl PRE_first_tail_x15_r0_body.okr1_108 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s960.ffi) = some PRE_first_tail_x15_r0_body.kr1_108
kernel_rfl PRE_first_tail_x15_r0_body.ff0108 : PRE_first_tail_x15_r0_body.fx0_108 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_108 (PRE_first_tail_x15_r0_body.clo108.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_108.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1108 : PRE_first_tail_x15_r0_body.fx1_108 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_108 (PRE_first_tail_x15_r0_body.cwS108.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_108.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck108 : freedLB PRE_first_tail_x15_r0_body.kappa108 PRE_first_tail_x15_r0_body.cx0_108.mlx PRE_first_tail_x15_r0_body.fx0_108 PRE_first_tail_x15_r0_body.fx1_108 PRE_first_tail_x15_r0_body.clo108 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0108 : PRE_first_tail_x15_r0_body.kr0_108.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_108.flags (PRE_first_tail_x15_r0_body.clo108.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_108.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0108 : PRE_first_tail_x15_r0_body.kr0_108.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_108.targs (PRE_first_tail_x15_r0_body.clo108.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_108.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1108 : PRE_first_tail_x15_r0_body.kr1_108.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_108.flags (PRE_first_tail_x15_r0_body.cwS108.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_108.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1108 : PRE_first_tail_x15_r0_body.kr1_108.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_108.targs (PRE_first_tail_x15_r0_body.cwS108.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_108.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck108 : krecLB PRE_first_tail_x15_r0_body.kappa108 4718 PRE_first_tail_x15_r0_body.cx0_108.mlx PRE_first_tail_x15_r0_body.kr0_108 PRE_first_tail_x15_r0_body.kr1_108 PRE_first_tail_x15_r0_body.clo108 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn108 : Nat.ble 4700 4718 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge108 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s960.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s961.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR108 : pendRegB PRE_first_tail_x15_r0_body.kappa108 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s961.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe108 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s961.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s960.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift108 (clean : Conv.NClean (⟨20340, 17411, 2760211, 4700⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P108.NL) (cl : SSt (· < 4718) PRE_first_tail_x15_r0_body.cx0_108.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_108.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_108.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_108.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s959.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_108.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20340, 17411, 2760211, 4700⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P108 4718 PRE_first_tail_x15_r0_body.kappa108 PRE_first_tail_x15_r0_body.s961.ffi PRE_first_tail_x15_r0_body.s960.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift108 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue108, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp108 t ht),
    PRE_first_tail_x15_r0_body.cbridge108,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s961.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s960.ffi) (PRE_first_tail_x15_r0_body.cfoot108 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_108 PRE_first_tail_x15_r0_body.ofx1_108 hobjC PRE_first_tail_x15_r0_body.ff0108 PRE_first_tail_x15_r0_body.ff1108 PRE_first_tail_x15_r0_body.ffck108,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s961.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s960.ffi) (PRE_first_tail_x15_r0_body.cfoot108 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_108 PRE_first_tail_x15_r0_body.okr1_108 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn108) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0108 PRE_first_tail_x15_r0_body.fkt0108 PRE_first_tail_x15_r0_body.fkf1108 PRE_first_tail_x15_r0_body.fkt1108 PRE_first_tail_x15_r0_body.fkck108,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0108 PRE_first_tail_x15_r0_body.cnh1108 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe108) PRE_first_tail_x15_r0_body.cpendR108⟩

end Host.Load.Run.Tpl

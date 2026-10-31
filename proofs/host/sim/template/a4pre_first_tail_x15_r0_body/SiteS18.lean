import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl18
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 18 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc18 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P18 : LoadP := PRE_first_tail_x15_r0_body.Pc18.raise 15668
kernel_rfl PRE_first_tail_x15_r0_body.craise18 : Nat.ble PRE_first_tail_x15_r0_body.Pc18.N0 15668 = true
theorem PRE_first_tail_x15_r0_body.raised18 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc18 PRE_first_tail_x15_r0_body.P18 :=
  .inr ⟨15668, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise18, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_18 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s175.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_18 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s174.ffi)
def PRE_first_tail_x15_r0_body.khinv18 : PTrie Nat := Stage.setAll PTrie.nil [(18592, 18566), (18570, 18567), (18593, 18568)]
def PRE_first_tail_x15_r0_body.kninv18 : PTrie Nat := Stage.setAll PTrie.nil [(15641, 15641), (15642, 15642), (15643, 15643), (15644, 15644), (15645, 15645), (15646, 15646), (15647, 15647), (15648, 15648), (15649, 15649), (15650, 15650), (15651, 15651), (15652, 15652), (15653, 15653), (15654, 15654), (15655, 15655), (15656, 15656), (15657, 15657), (15658, 15658), (15659, 15659), (15660, 15660), (15661, 15661), (15662, 15662), (15663, 15663), (15664, 15664), (15665, 15665), (15666, 15666), (15667, 15667)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS18 : List Nat := [18546, 18559, 18565, 18566, 18567, 18568, 18569, 18570, 18571, 18572, 18573, 18574, 18575, 18576, 18577, 18578, 18579, 18580, 18581, 18582, 18583, 18584, 18585, 18586, 18587, 18588, 18589, 18590, 18591, 18592, 18593]
def PRE_first_tail_x15_r0_body.cnS18 : List Nat := List.range' 15641 27
def PRE_first_tail_x15_r0_body.ciS18 : List Nat := [] ++ List.range' 15641 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh018 : PRE_first_tail_x15_r0_body.kd18.nh0 = PRE_first_tail_x15_r0_body.cx0_18.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh118 : PRE_first_tail_x15_r0_body.kd18.nh1 = PRE_first_tail_x15_r0_body.cx1_18.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn018 : PRE_first_tail_x15_r0_body.kd18.nn0 = PRE_first_tail_x15_r0_body.cx0_18.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn118 : PRE_first_tail_x15_r0_body.kd18.nn1 = PRE_first_tail_x15_r0_body.cx1_18.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo18 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P18.lo && Nat.ble PRE_first_tail_x15_r0_body.P18.lo PRE_first_tail_x15_r0_body.cx0_18.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P18.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P18.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt18 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_18.mlx.next PRE_first_tail_x15_r0_body.cx1_18.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_18.mlx.nnext PRE_first_tail_x15_r0_body.cx1_18.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband18 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P18.NL && Nat.ble PRE_first_tail_x15_r0_body.P18.NL PRE_first_tail_x15_r0_body.P18.N0 && Nat.ble PRE_first_tail_x15_r0_body.P18.N0 PRE_first_tail_x15_r0_body.cx0_18.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow18 : PRE_first_tail_x15_r0_body.kd18.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren18 : checkRenG PRE_first_tail_x15_r0_body.kd18.hnd PRE_first_tail_x15_r0_body.khinv18 (phB PRE_first_tail_x15_r0_body.cx0_18.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband18 : PRE_first_tail_x15_r0_body.kd18.checkBand PRE_first_tail_x15_r0_body.P18.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos18 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd18.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren18 : checkRenG PRE_first_tail_x15_r0_body.kd18.node PRE_first_tail_x15_r0_body.kninv18 (pnB PRE_first_tail_x15_r0_body.cx0_18.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow18 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd18.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P18.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd18.nodeF j) PRE_first_tail_x15_r0_body.cx1_18.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a18 : PRE_first_tail_x15_r0_body.cx0_18.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b18 : PRE_first_tail_x15_r0_body.cx0_18.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok118 : PRE_first_tail_x15_r0_body.cx1_18.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend18 : PRE_first_tail_x15_r0_body.cx1_18.mlx.pending = PRE_first_tail_x15_r0_body.cx0_18.mlx.pending.map PRE_first_tail_x15_r0_body.kappa18.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh18 : PRE_first_tail_x15_r0_body.cx1_18.mlx.errh = PRE_first_tail_x15_r0_body.cx0_18.mlx.errh.map PRE_first_tail_x15_r0_body.kappa18.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles18 : PRE_first_tail_x15_r0_body.cx1_18.mlx.files = PRE_first_tail_x15_r0_body.cx0_18.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch18 : PRE_first_tail_x15_r0_body.cx1_18.mlx.arch = PRE_first_tail_x15_r0_body.cx0_18.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes18 : PRE_first_tail_x15_r0_body.cx1_18.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_18.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired18 : PRE_first_tail_x15_r0_body.cx1_18.mlx.wired = PRE_first_tail_x15_r0_body.cx0_18.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost18 : PRE_first_tail_x15_r0_body.cx1_18.host = PRE_first_tail_x15_r0_body.cx0_18.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd18`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn018 : PRE_first_tail_x15_r0_body.kd18.n0 = 2689393
kernel_rfl PRE_first_tail_x15_r0_body.ckn118 : PRE_first_tail_x15_r0_body.kd18.n1 = 2690542
kernel_rfl PRE_first_tail_x15_r0_body.ckheap18 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd18.heap).all (fun x => Nat.ble 2689387 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl18 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd18.heap.get (2689387 + j) = nth? PRE_first_tail_x15_r0_body.pl18 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja18 : Nat.ble 2689387 2689387 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn18 : Nat.ble 854 854 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD18 : Nat.ble 2689387 PRE_first_tail_x15_r0_body.kd18.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn18 : Nat.ble 18566 PRE_first_tail_x15_r0_body.kd18.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn18 : Nat.ble 15641 PRE_first_tail_x15_r0_body.kd18.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb18 : Nat.ble 18566 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap18 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd18.heap).all (Nat.ble (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd18 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd18.hnd).all (Nat.ble (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode18 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd18.node).all (Nat.ble (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix18 : Conv.FixOld (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa18 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja18) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn18) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD18) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn18) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn18) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb18) PRE_first_tail_x15_r0_body.fheap18 PRE_first_tail_x15_r0_body.fhnd18 PRE_first_tail_x15_r0_body.fnode18
kernel_rfl PRE_first_tail_x15_r0_body.fcxn18 : (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn18 : (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle018 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_18.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_18.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk18 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd18.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A18 : PRE_first_tail_x15_r0_body.cx1_18.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS18.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_18.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O18 : PRE_first_tail_x15_r0_body.cx1_18.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS18.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_18.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N18 : PRE_first_tail_x15_r0_body.cx1_18.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS18.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_18.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I18 : PRE_first_tail_x15_r0_body.cx1_18.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS18.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_18.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd18 : (PRE_first_tail_x15_r0_body.clo18 ++ PRE_first_tail_x15_r0_body.cln18 ++ PRE_first_tail_x15_r0_body.cli18 ++ PRE_first_tail_x15_r0_body.cwS18 ++ PRE_first_tail_x15_r0_body.cnS18 ++ PRE_first_tail_x15_r0_body.ciS18).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW18 : PRE_first_tail_x15_r0_body.cwS18.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo18.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI18 : PRE_first_tail_x15_r0_body.ciS18.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli18.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN18 : PRE_first_tail_x15_r0_body.cnS18.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF18 : PRE_first_tail_x15_r0_body.cln18.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh18 : PRE_first_tail_x15_r0_body.clo18.all (handleOK PRE_first_tail_x15_r0_body.kappa18 PRE_first_tail_x15_r0_body.P18.lo PRE_first_tail_x15_r0_body.cx0_18.mlx PRE_first_tail_x15_r0_body.cx1_18.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo18 : PRE_first_tail_x15_r0_body.clo18.map (fun h => PRE_first_tail_x15_r0_body.cx1_18.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa18.handle h)) = PRE_first_tail_x15_r0_body.clo18.map (fun h => (PRE_first_tail_x15_r0_body.cx0_18.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa18.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok18 : PRE_first_tail_x15_r0_body.clo18.all (objOK PRE_first_tail_x15_r0_body.kappa18 PRE_first_tail_x15_r0_body.P18.NL PRE_first_tail_x15_r0_body.cx0_18.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd18 : PRE_first_tail_x15_r0_body.cln18.all (nodeOKF PRE_first_tail_x15_r0_body.kappa18 PRE_first_tail_x15_r0_body.P18 PRE_first_tail_x15_r0_body.cx0_18.mlx PRE_first_tail_x15_r0_body.cx1_18.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp18 : ((PRE_first_tail_x15_r0_body.cln18.filter (fullB PRE_first_tail_x15_r0_body.P18))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_18.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa18.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln18.filter (fullB PRE_first_tail_x15_r0_body.P18))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_18.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa18.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI18 : incrB PRE_first_tail_x15_r0_body.kd18.nodeF (List.range' 15641 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK18 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd18.node).all (fun k => Nat.ble 15641 k && Nat.blt k 15668) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL18 : (PRE_first_tail_x15_r0_body.cln18.filter (Nat.ble PRE_first_tail_x15_r0_body.P18.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd18.nodeF i) && (Nat.blt i 15668 || Nat.ble PRE_first_tail_x15_r0_body.kd18.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord18 : (PRE_first_tail_x15_r0_body.cln18.filter (Nat.ble PRE_first_tail_x15_r0_body.P18.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd18.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd18.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd18.nodeF j) (PRE_first_tail_x15_r0_body.kd18.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow18 PRE_first_tail_x15_r0_body.cnn118 PRE_first_tail_x15_r0_body.fnordI18 PRE_first_tail_x15_r0_body.fnordK18 PRE_first_tail_x15_r0_body.fnordL18
kernel_rfl PRE_first_tail_x15_r0_body.fi18 : PRE_first_tail_x15_r0_body.cli18.all (pnB PRE_first_tail_x15_r0_body.cx0_18.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii18 : PRE_first_tail_x15_r0_body.cli18.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_18.mlx.items.get (PRE_first_tail_x15_r0_body.kappa18.node k) = (PRE_first_tail_x15_r0_body.cx0_18.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa18.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot18 (clean : Conv.NClean (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P18.NL) (cl : SSt (· < 872) PRE_first_tail_x15_r0_body.cx0_18.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P18 872 PRE_first_tail_x15_r0_body.kappa18 PRE_first_tail_x15_r0_body.kd18 PRE_first_tail_x15_r0_body.khinv18 PRE_first_tail_x15_r0_body.kninv18 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx PRE_first_tail_x15_r0_body.cx0_18.mlx PRE_first_tail_x15_r0_body.cx1_18.mlx (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo18 PRE_first_tail_x15_r0_body.cln18 PRE_first_tail_x15_r0_body.cli18 PRE_first_tail_x15_r0_body.cwS18 PRE_first_tail_x15_r0_body.cnS18 PRE_first_tail_x15_r0_body.ciS18 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh018, PRE_first_tail_x15_r0_body.cnh118, PRE_first_tail_x15_r0_body.cnn018, PRE_first_tail_x15_r0_body.cnn118, PRE_first_tail_x15_r0_body.cplo18, PRE_first_tail_x15_r0_body.ccnt18, PRE_first_tail_x15_r0_body.cnband18, PRE_first_tail_x15_r0_body.chbelow18, PRE_first_tail_x15_r0_body.chren18, PRE_first_tail_x15_r0_body.cband18, PRE_first_tail_x15_r0_body.cnh1pos18, PRE_first_tail_x15_r0_body.cnren18, PRE_first_tail_x15_r0_body.cnlow18, PRE_first_tail_x15_r0_body.cabs0a18, PRE_first_tail_x15_r0_body.cabs0b18, PRE_first_tail_x15_r0_body.ctok118, PRE_first_tail_x15_r0_body.cpend18, PRE_first_tail_x15_r0_body.cerrh18, PRE_first_tail_x15_r0_body.cfiles18, PRE_first_tail_x15_r0_body.carch18, PRE_first_tail_x15_r0_body.csizes18, PRE_first_tail_x15_r0_body.cwired18, PRE_first_tail_x15_r0_body.cfix18, clean, PRE_first_tail_x15_r0_body.fcxn18, PRE_first_tail_x15_r0_body.fcnn18, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle018, PRE_first_tail_x15_r0_body.fnk18, PRE_first_tail_x15_r0_body.ckA18, PRE_first_tail_x15_r0_body.cobjsK18, PRE_first_tail_x15_r0_body.cnodesK18, PRE_first_tail_x15_r0_body.citemsK18, PRE_first_tail_x15_r0_body.f1A18, PRE_first_tail_x15_r0_body.f1O18, PRE_first_tail_x15_r0_body.f1N18, PRE_first_tail_x15_r0_body.f1I18, PRE_first_tail_x15_r0_body.fbd18, PRE_first_tail_x15_r0_body.fincW18, PRE_first_tail_x15_r0_body.fincI18, PRE_first_tail_x15_r0_body.fincN18, PRE_first_tail_x15_r0_body.flnF18, PRE_first_tail_x15_r0_body.fh18, PRE_first_tail_x15_r0_body.fo18, PRE_first_tail_x15_r0_body.fok18, PRE_first_tail_x15_r0_body.fnd18, PRE_first_tail_x15_r0_body.fp18, PRE_first_tail_x15_r0_body.fnord18, PRE_first_tail_x15_r0_body.fi18, PRE_first_tail_x15_r0_body.fii18⟩
theorem PRE_first_tail_x15_r0_body.cnshift18 (clean : Conv.NClean (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P18.NL) (cl : SSt (· < 872) PRE_first_tail_x15_r0_body.cx0_18.mlx) : NShift PRE_first_tail_x15_r0_body.P18 872 PRE_first_tail_x15_r0_body.kappa18 PRE_first_tail_x15_r0_body.cx0_18 PRE_first_tail_x15_r0_body.cx1_18 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot18 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost18 (compact_a_eq PRE_first_tail_x15_r0_body.ckn018 PRE_first_tail_x15_r0_body.ckn118 PRE_first_tail_x15_r0_body.ckheap18 PRE_first_tail_x15_r0_body.ckpl18)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_18 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s173.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_18 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s173.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_18 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s173.ffi) = some PRE_first_tail_x15_r0_body.fxC_18
kernel_rfl PRE_first_tail_x15_r0_body.okrC_18 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s173.ffi) = some PRE_first_tail_x15_r0_body.krC_18
noncomputable def PRE_first_tail_x15_r0_body.fx0_18 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s175.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_18 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s175.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_18 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s175.ffi) = some PRE_first_tail_x15_r0_body.fx0_18
kernel_rfl PRE_first_tail_x15_r0_body.okr0_18 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s175.ffi) = some PRE_first_tail_x15_r0_body.kr0_18
noncomputable def PRE_first_tail_x15_r0_body.fx1_18 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s174.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_18 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s174.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_18 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s174.ffi) = some PRE_first_tail_x15_r0_body.fx1_18
kernel_rfl PRE_first_tail_x15_r0_body.okr1_18 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s174.ffi) = some PRE_first_tail_x15_r0_body.kr1_18
kernel_rfl PRE_first_tail_x15_r0_body.ff018 : PRE_first_tail_x15_r0_body.fx0_18 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_18 (PRE_first_tail_x15_r0_body.clo18.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_18.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff118 : PRE_first_tail_x15_r0_body.fx1_18 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_18 (PRE_first_tail_x15_r0_body.cwS18.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_18.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck18 : freedLB PRE_first_tail_x15_r0_body.kappa18 PRE_first_tail_x15_r0_body.cx0_18.mlx PRE_first_tail_x15_r0_body.fx0_18 PRE_first_tail_x15_r0_body.fx1_18 PRE_first_tail_x15_r0_body.clo18 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf018 : PRE_first_tail_x15_r0_body.kr0_18.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_18.flags (PRE_first_tail_x15_r0_body.clo18.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_18.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt018 : PRE_first_tail_x15_r0_body.kr0_18.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_18.targs (PRE_first_tail_x15_r0_body.clo18.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_18.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf118 : PRE_first_tail_x15_r0_body.kr1_18.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_18.flags (PRE_first_tail_x15_r0_body.cwS18.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_18.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt118 : PRE_first_tail_x15_r0_body.kr1_18.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_18.targs (PRE_first_tail_x15_r0_body.cwS18.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_18.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck18 : krecLB PRE_first_tail_x15_r0_body.kappa18 872 PRE_first_tail_x15_r0_body.cx0_18.mlx PRE_first_tail_x15_r0_body.kr0_18 PRE_first_tail_x15_r0_body.kr1_18 PRE_first_tail_x15_r0_body.clo18 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn18 : Nat.ble 854 872 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge18 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s174.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s175.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR18 : pendRegB PRE_first_tail_x15_r0_body.kappa18 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s175.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe18 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s175.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s174.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift18 (clean : Conv.NClean (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P18.NL) (cl : SSt (· < 872) PRE_first_tail_x15_r0_body.cx0_18.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_18.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_18.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_18.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_18.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P18 872 PRE_first_tail_x15_r0_body.kappa18 PRE_first_tail_x15_r0_body.s175.ffi PRE_first_tail_x15_r0_body.s174.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift18 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue18, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp18 t ht),
    PRE_first_tail_x15_r0_body.cbridge18,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s175.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s174.ffi) (PRE_first_tail_x15_r0_body.cfoot18 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_18 PRE_first_tail_x15_r0_body.ofx1_18 hobjC PRE_first_tail_x15_r0_body.ff018 PRE_first_tail_x15_r0_body.ff118 PRE_first_tail_x15_r0_body.ffck18,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s175.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s174.ffi) (PRE_first_tail_x15_r0_body.cfoot18 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_18 PRE_first_tail_x15_r0_body.okr1_18 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn18) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf018 PRE_first_tail_x15_r0_body.fkt018 PRE_first_tail_x15_r0_body.fkf118 PRE_first_tail_x15_r0_body.fkt118 PRE_first_tail_x15_r0_body.fkck18,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh018 PRE_first_tail_x15_r0_body.cnh118 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe18) PRE_first_tail_x15_r0_body.cpendR18⟩

end Host.Load.Run.Tpl

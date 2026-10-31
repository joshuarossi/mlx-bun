import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl171
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 171 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc171 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P171 : LoadP := PRE_first_tail_x15_r0_body.Pc171.raise 18686
kernel_rfl PRE_first_tail_x15_r0_body.craise171 : Nat.ble PRE_first_tail_x15_r0_body.Pc171.N0 18686 = true
theorem PRE_first_tail_x15_r0_body.raised171 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc171 PRE_first_tail_x15_r0_body.P171 :=
  .inr ⟨18686, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise171, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_171 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1657.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_171 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1656.ffi)
def PRE_first_tail_x15_r0_body.khinv171 : PTrie Nat := Stage.setAll PTrie.nil [(21603, 21577), (21581, 21578), (21604, 21579)]
def PRE_first_tail_x15_r0_body.kninv171 : PTrie Nat := Stage.setAll PTrie.nil [(18659, 18659), (18660, 18660), (18661, 18661), (18662, 18662), (18663, 18663), (18664, 18664), (18665, 18665), (18666, 18666), (18667, 18667), (18668, 18668), (18669, 18669), (18670, 18670), (18671, 18671), (18672, 18672), (18673, 18673), (18674, 18674), (18675, 18675), (18676, 18676), (18677, 18677), (18678, 18678), (18679, 18679), (18680, 18680), (18681, 18681), (18682, 18682), (18683, 18683), (18684, 18684), (18685, 18685)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS171 : List Nat := [21557, 21570, 21576, 21577, 21578, 21579, 21580, 21581, 21582, 21583, 21584, 21585, 21586, 21587, 21588, 21589, 21590, 21591, 21592, 21593, 21594, 21595, 21596, 21597, 21598, 21599, 21600, 21601, 21602, 21603, 21604]
def PRE_first_tail_x15_r0_body.cnS171 : List Nat := List.range' 18659 27
def PRE_first_tail_x15_r0_body.ciS171 : List Nat := [] ++ List.range' 18659 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0171 : PRE_first_tail_x15_r0_body.kd171.nh0 = PRE_first_tail_x15_r0_body.cx0_171.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1171 : PRE_first_tail_x15_r0_body.kd171.nh1 = PRE_first_tail_x15_r0_body.cx1_171.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0171 : PRE_first_tail_x15_r0_body.kd171.nn0 = PRE_first_tail_x15_r0_body.cx0_171.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1171 : PRE_first_tail_x15_r0_body.kd171.nn1 = PRE_first_tail_x15_r0_body.cx1_171.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo171 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P171.lo && Nat.ble PRE_first_tail_x15_r0_body.P171.lo PRE_first_tail_x15_r0_body.cx0_171.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P171.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P171.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt171 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_171.mlx.next PRE_first_tail_x15_r0_body.cx1_171.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_171.mlx.nnext PRE_first_tail_x15_r0_body.cx1_171.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband171 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P171.NL && Nat.ble PRE_first_tail_x15_r0_body.P171.NL PRE_first_tail_x15_r0_body.P171.N0 && Nat.ble PRE_first_tail_x15_r0_body.P171.N0 PRE_first_tail_x15_r0_body.cx0_171.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow171 : PRE_first_tail_x15_r0_body.kd171.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren171 : checkRenG PRE_first_tail_x15_r0_body.kd171.hnd PRE_first_tail_x15_r0_body.khinv171 (phB PRE_first_tail_x15_r0_body.cx0_171.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband171 : PRE_first_tail_x15_r0_body.kd171.checkBand PRE_first_tail_x15_r0_body.P171.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos171 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd171.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren171 : checkRenG PRE_first_tail_x15_r0_body.kd171.node PRE_first_tail_x15_r0_body.kninv171 (pnB PRE_first_tail_x15_r0_body.cx0_171.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow171 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd171.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P171.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd171.nodeF j) PRE_first_tail_x15_r0_body.cx1_171.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a171 : PRE_first_tail_x15_r0_body.cx0_171.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b171 : PRE_first_tail_x15_r0_body.cx0_171.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1171 : PRE_first_tail_x15_r0_body.cx1_171.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend171 : PRE_first_tail_x15_r0_body.cx1_171.mlx.pending = PRE_first_tail_x15_r0_body.cx0_171.mlx.pending.map PRE_first_tail_x15_r0_body.kappa171.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh171 : PRE_first_tail_x15_r0_body.cx1_171.mlx.errh = PRE_first_tail_x15_r0_body.cx0_171.mlx.errh.map PRE_first_tail_x15_r0_body.kappa171.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles171 : PRE_first_tail_x15_r0_body.cx1_171.mlx.files = PRE_first_tail_x15_r0_body.cx0_171.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch171 : PRE_first_tail_x15_r0_body.cx1_171.mlx.arch = PRE_first_tail_x15_r0_body.cx0_171.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes171 : PRE_first_tail_x15_r0_body.cx1_171.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_171.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired171 : PRE_first_tail_x15_r0_body.cx1_171.mlx.wired = PRE_first_tail_x15_r0_body.cx0_171.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost171 : PRE_first_tail_x15_r0_body.cx1_171.host = PRE_first_tail_x15_r0_body.cx0_171.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd171`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0171 : PRE_first_tail_x15_r0_body.kd171.n0 = 2809565
kernel_rfl PRE_first_tail_x15_r0_body.ckn1171 : PRE_first_tail_x15_r0_body.kd171.n1 = 2810714
kernel_rfl PRE_first_tail_x15_r0_body.ckheap171 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd171.heap).all (fun x => Nat.ble 2809559 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl171 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd171.heap.get (2809559 + j) = nth? PRE_first_tail_x15_r0_body.pl171 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja171 : Nat.ble 2809559 2809559 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn171 : Nat.ble 7394 7394 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD171 : Nat.ble 2809559 PRE_first_tail_x15_r0_body.kd171.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn171 : Nat.ble 21577 PRE_first_tail_x15_r0_body.kd171.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn171 : Nat.ble 18659 PRE_first_tail_x15_r0_body.kd171.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb171 : Nat.ble 21577 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap171 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd171.heap).all (Nat.ble (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd171 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd171.hnd).all (Nat.ble (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode171 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd171.node).all (Nat.ble (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix171 : Conv.FixOld (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa171 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja171) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn171) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD171) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn171) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn171) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb171) PRE_first_tail_x15_r0_body.fheap171 PRE_first_tail_x15_r0_body.fhnd171 PRE_first_tail_x15_r0_body.fnode171
kernel_rfl PRE_first_tail_x15_r0_body.fcxn171 : (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn171 : (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0171 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_171.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_171.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk171 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd171.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A171 : PRE_first_tail_x15_r0_body.cx1_171.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS171.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_171.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O171 : PRE_first_tail_x15_r0_body.cx1_171.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS171.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_171.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N171 : PRE_first_tail_x15_r0_body.cx1_171.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS171.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_171.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I171 : PRE_first_tail_x15_r0_body.cx1_171.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS171.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_171.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd171 : (PRE_first_tail_x15_r0_body.clo171 ++ PRE_first_tail_x15_r0_body.cln171 ++ PRE_first_tail_x15_r0_body.cli171 ++ PRE_first_tail_x15_r0_body.cwS171 ++ PRE_first_tail_x15_r0_body.cnS171 ++ PRE_first_tail_x15_r0_body.ciS171).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW171 : PRE_first_tail_x15_r0_body.cwS171.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo171.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI171 : PRE_first_tail_x15_r0_body.ciS171.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli171.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN171 : PRE_first_tail_x15_r0_body.cnS171.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF171 : PRE_first_tail_x15_r0_body.cln171.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh171 : PRE_first_tail_x15_r0_body.clo171.all (handleOK PRE_first_tail_x15_r0_body.kappa171 PRE_first_tail_x15_r0_body.P171.lo PRE_first_tail_x15_r0_body.cx0_171.mlx PRE_first_tail_x15_r0_body.cx1_171.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo171 : PRE_first_tail_x15_r0_body.clo171.map (fun h => PRE_first_tail_x15_r0_body.cx1_171.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa171.handle h)) = PRE_first_tail_x15_r0_body.clo171.map (fun h => (PRE_first_tail_x15_r0_body.cx0_171.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa171.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok171 : PRE_first_tail_x15_r0_body.clo171.all (objOK PRE_first_tail_x15_r0_body.kappa171 PRE_first_tail_x15_r0_body.P171.NL PRE_first_tail_x15_r0_body.cx0_171.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd171 : PRE_first_tail_x15_r0_body.cln171.all (nodeOKF PRE_first_tail_x15_r0_body.kappa171 PRE_first_tail_x15_r0_body.P171 PRE_first_tail_x15_r0_body.cx0_171.mlx PRE_first_tail_x15_r0_body.cx1_171.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp171 : ((PRE_first_tail_x15_r0_body.cln171.filter (fullB PRE_first_tail_x15_r0_body.P171))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_171.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa171.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln171.filter (fullB PRE_first_tail_x15_r0_body.P171))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_171.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa171.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI171 : incrB PRE_first_tail_x15_r0_body.kd171.nodeF (List.range' 18659 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK171 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd171.node).all (fun k => Nat.ble 18659 k && Nat.blt k 18686) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL171 : (PRE_first_tail_x15_r0_body.cln171.filter (Nat.ble PRE_first_tail_x15_r0_body.P171.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd171.nodeF i) && (Nat.blt i 18686 || Nat.ble PRE_first_tail_x15_r0_body.kd171.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord171 : (PRE_first_tail_x15_r0_body.cln171.filter (Nat.ble PRE_first_tail_x15_r0_body.P171.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd171.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd171.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd171.nodeF j) (PRE_first_tail_x15_r0_body.kd171.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow171 PRE_first_tail_x15_r0_body.cnn1171 PRE_first_tail_x15_r0_body.fnordI171 PRE_first_tail_x15_r0_body.fnordK171 PRE_first_tail_x15_r0_body.fnordL171
kernel_rfl PRE_first_tail_x15_r0_body.fi171 : PRE_first_tail_x15_r0_body.cli171.all (pnB PRE_first_tail_x15_r0_body.cx0_171.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii171 : PRE_first_tail_x15_r0_body.cli171.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_171.mlx.items.get (PRE_first_tail_x15_r0_body.kappa171.node k) = (PRE_first_tail_x15_r0_body.cx0_171.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa171.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot171 (clean : Conv.NClean (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P171.NL) (cl : SSt (· < 7412) PRE_first_tail_x15_r0_body.cx0_171.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P171 7412 PRE_first_tail_x15_r0_body.kappa171 PRE_first_tail_x15_r0_body.kd171 PRE_first_tail_x15_r0_body.khinv171 PRE_first_tail_x15_r0_body.kninv171 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx PRE_first_tail_x15_r0_body.cx0_171.mlx PRE_first_tail_x15_r0_body.cx1_171.mlx (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo171 PRE_first_tail_x15_r0_body.cln171 PRE_first_tail_x15_r0_body.cli171 PRE_first_tail_x15_r0_body.cwS171 PRE_first_tail_x15_r0_body.cnS171 PRE_first_tail_x15_r0_body.ciS171 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0171, PRE_first_tail_x15_r0_body.cnh1171, PRE_first_tail_x15_r0_body.cnn0171, PRE_first_tail_x15_r0_body.cnn1171, PRE_first_tail_x15_r0_body.cplo171, PRE_first_tail_x15_r0_body.ccnt171, PRE_first_tail_x15_r0_body.cnband171, PRE_first_tail_x15_r0_body.chbelow171, PRE_first_tail_x15_r0_body.chren171, PRE_first_tail_x15_r0_body.cband171, PRE_first_tail_x15_r0_body.cnh1pos171, PRE_first_tail_x15_r0_body.cnren171, PRE_first_tail_x15_r0_body.cnlow171, PRE_first_tail_x15_r0_body.cabs0a171, PRE_first_tail_x15_r0_body.cabs0b171, PRE_first_tail_x15_r0_body.ctok1171, PRE_first_tail_x15_r0_body.cpend171, PRE_first_tail_x15_r0_body.cerrh171, PRE_first_tail_x15_r0_body.cfiles171, PRE_first_tail_x15_r0_body.carch171, PRE_first_tail_x15_r0_body.csizes171, PRE_first_tail_x15_r0_body.cwired171, PRE_first_tail_x15_r0_body.cfix171, clean, PRE_first_tail_x15_r0_body.fcxn171, PRE_first_tail_x15_r0_body.fcnn171, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0171, PRE_first_tail_x15_r0_body.fnk171, PRE_first_tail_x15_r0_body.ckA171, PRE_first_tail_x15_r0_body.cobjsK171, PRE_first_tail_x15_r0_body.cnodesK171, PRE_first_tail_x15_r0_body.citemsK171, PRE_first_tail_x15_r0_body.f1A171, PRE_first_tail_x15_r0_body.f1O171, PRE_first_tail_x15_r0_body.f1N171, PRE_first_tail_x15_r0_body.f1I171, PRE_first_tail_x15_r0_body.fbd171, PRE_first_tail_x15_r0_body.fincW171, PRE_first_tail_x15_r0_body.fincI171, PRE_first_tail_x15_r0_body.fincN171, PRE_first_tail_x15_r0_body.flnF171, PRE_first_tail_x15_r0_body.fh171, PRE_first_tail_x15_r0_body.fo171, PRE_first_tail_x15_r0_body.fok171, PRE_first_tail_x15_r0_body.fnd171, PRE_first_tail_x15_r0_body.fp171, PRE_first_tail_x15_r0_body.fnord171, PRE_first_tail_x15_r0_body.fi171, PRE_first_tail_x15_r0_body.fii171⟩
theorem PRE_first_tail_x15_r0_body.cnshift171 (clean : Conv.NClean (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P171.NL) (cl : SSt (· < 7412) PRE_first_tail_x15_r0_body.cx0_171.mlx) : NShift PRE_first_tail_x15_r0_body.P171 7412 PRE_first_tail_x15_r0_body.kappa171 PRE_first_tail_x15_r0_body.cx0_171 PRE_first_tail_x15_r0_body.cx1_171 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot171 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost171 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0171 PRE_first_tail_x15_r0_body.ckn1171 PRE_first_tail_x15_r0_body.ckheap171 PRE_first_tail_x15_r0_body.ckpl171)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_171 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1655.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_171 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1655.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_171 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1655.ffi) = some PRE_first_tail_x15_r0_body.fxC_171
kernel_rfl PRE_first_tail_x15_r0_body.okrC_171 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1655.ffi) = some PRE_first_tail_x15_r0_body.krC_171
noncomputable def PRE_first_tail_x15_r0_body.fx0_171 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1657.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_171 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1657.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_171 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1657.ffi) = some PRE_first_tail_x15_r0_body.fx0_171
kernel_rfl PRE_first_tail_x15_r0_body.okr0_171 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1657.ffi) = some PRE_first_tail_x15_r0_body.kr0_171
noncomputable def PRE_first_tail_x15_r0_body.fx1_171 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1656.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_171 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1656.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_171 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1656.ffi) = some PRE_first_tail_x15_r0_body.fx1_171
kernel_rfl PRE_first_tail_x15_r0_body.okr1_171 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1656.ffi) = some PRE_first_tail_x15_r0_body.kr1_171
kernel_rfl PRE_first_tail_x15_r0_body.ff0171 : PRE_first_tail_x15_r0_body.fx0_171 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_171 (PRE_first_tail_x15_r0_body.clo171.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_171.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1171 : PRE_first_tail_x15_r0_body.fx1_171 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_171 (PRE_first_tail_x15_r0_body.cwS171.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_171.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck171 : freedLB PRE_first_tail_x15_r0_body.kappa171 PRE_first_tail_x15_r0_body.cx0_171.mlx PRE_first_tail_x15_r0_body.fx0_171 PRE_first_tail_x15_r0_body.fx1_171 PRE_first_tail_x15_r0_body.clo171 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0171 : PRE_first_tail_x15_r0_body.kr0_171.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_171.flags (PRE_first_tail_x15_r0_body.clo171.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_171.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0171 : PRE_first_tail_x15_r0_body.kr0_171.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_171.targs (PRE_first_tail_x15_r0_body.clo171.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_171.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1171 : PRE_first_tail_x15_r0_body.kr1_171.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_171.flags (PRE_first_tail_x15_r0_body.cwS171.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_171.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1171 : PRE_first_tail_x15_r0_body.kr1_171.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_171.targs (PRE_first_tail_x15_r0_body.cwS171.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_171.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck171 : krecLB PRE_first_tail_x15_r0_body.kappa171 7412 PRE_first_tail_x15_r0_body.cx0_171.mlx PRE_first_tail_x15_r0_body.kr0_171 PRE_first_tail_x15_r0_body.kr1_171 PRE_first_tail_x15_r0_body.clo171 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn171 : Nat.ble 7394 7412 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge171 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1656.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1657.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR171 : pendRegB PRE_first_tail_x15_r0_body.kappa171 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1657.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe171 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1657.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1656.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift171 (clean : Conv.NClean (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P171.NL) (cl : SSt (· < 7412) PRE_first_tail_x15_r0_body.cx0_171.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_171.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_171.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_171.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_171.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P171 7412 PRE_first_tail_x15_r0_body.kappa171 PRE_first_tail_x15_r0_body.s1657.ffi PRE_first_tail_x15_r0_body.s1656.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift171 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue171, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp171 t ht),
    PRE_first_tail_x15_r0_body.cbridge171,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1657.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1656.ffi) (PRE_first_tail_x15_r0_body.cfoot171 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_171 PRE_first_tail_x15_r0_body.ofx1_171 hobjC PRE_first_tail_x15_r0_body.ff0171 PRE_first_tail_x15_r0_body.ff1171 PRE_first_tail_x15_r0_body.ffck171,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1657.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1656.ffi) (PRE_first_tail_x15_r0_body.cfoot171 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_171 PRE_first_tail_x15_r0_body.okr1_171 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn171) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0171 PRE_first_tail_x15_r0_body.fkt0171 PRE_first_tail_x15_r0_body.fkf1171 PRE_first_tail_x15_r0_body.fkt1171 PRE_first_tail_x15_r0_body.fkck171,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0171 PRE_first_tail_x15_r0_body.cnh1171 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe171) PRE_first_tail_x15_r0_body.cpendR171⟩

end Host.Load.Run.Tpl

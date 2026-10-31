import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl72
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 72 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc72 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P72 : LoadP := PRE_first_tail_x15_r0_body.Pc72.raise 16727
kernel_rfl PRE_first_tail_x15_r0_body.craise72 : Nat.ble PRE_first_tail_x15_r0_body.Pc72.N0 16727 = true
theorem PRE_first_tail_x15_r0_body.raised72 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc72 PRE_first_tail_x15_r0_body.P72 :=
  .inr ⟨16727, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise72, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_72 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_72 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s707.ffi)
def PRE_first_tail_x15_r0_body.khinv72 : PTrie Nat := Stage.setAll PTrie.nil [(19658, 19632), (19636, 19633), (19659, 19634)]
def PRE_first_tail_x15_r0_body.kninv72 : PTrie Nat := Stage.setAll PTrie.nil [(16700, 16700), (16701, 16701), (16702, 16702), (16703, 16703), (16704, 16704), (16705, 16705), (16706, 16706), (16707, 16707), (16708, 16708), (16709, 16709), (16710, 16710), (16711, 16711), (16712, 16712), (16713, 16713), (16714, 16714), (16715, 16715), (16716, 16716), (16717, 16717), (16718, 16718), (16719, 16719), (16720, 16720), (16721, 16721), (16722, 16722), (16723, 16723), (16724, 16724), (16725, 16725), (16726, 16726)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS72 : List Nat := [19612, 19625, 19631, 19632, 19633, 19634, 19635, 19636, 19637, 19638, 19639, 19640, 19641, 19642, 19643, 19644, 19645, 19646, 19647, 19648, 19649, 19650, 19651, 19652, 19653, 19654, 19655, 19656, 19657, 19658, 19659]
def PRE_first_tail_x15_r0_body.cnS72 : List Nat := List.range' 16700 27
def PRE_first_tail_x15_r0_body.ciS72 : List Nat := [] ++ List.range' 16700 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh072 : PRE_first_tail_x15_r0_body.kd72.nh0 = PRE_first_tail_x15_r0_body.cx0_72.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh172 : PRE_first_tail_x15_r0_body.kd72.nh1 = PRE_first_tail_x15_r0_body.cx1_72.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn072 : PRE_first_tail_x15_r0_body.kd72.nn0 = PRE_first_tail_x15_r0_body.cx0_72.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn172 : PRE_first_tail_x15_r0_body.kd72.nn1 = PRE_first_tail_x15_r0_body.cx1_72.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo72 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P72.lo && Nat.ble PRE_first_tail_x15_r0_body.P72.lo PRE_first_tail_x15_r0_body.cx0_72.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P72.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P72.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt72 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_72.mlx.next PRE_first_tail_x15_r0_body.cx1_72.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_72.mlx.nnext PRE_first_tail_x15_r0_body.cx1_72.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband72 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P72.NL && Nat.ble PRE_first_tail_x15_r0_body.P72.NL PRE_first_tail_x15_r0_body.P72.N0 && Nat.ble PRE_first_tail_x15_r0_body.P72.N0 PRE_first_tail_x15_r0_body.cx0_72.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow72 : PRE_first_tail_x15_r0_body.kd72.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren72 : checkRenG PRE_first_tail_x15_r0_body.kd72.hnd PRE_first_tail_x15_r0_body.khinv72 (phB PRE_first_tail_x15_r0_body.cx0_72.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband72 : PRE_first_tail_x15_r0_body.kd72.checkBand PRE_first_tail_x15_r0_body.P72.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos72 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd72.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren72 : checkRenG PRE_first_tail_x15_r0_body.kd72.node PRE_first_tail_x15_r0_body.kninv72 (pnB PRE_first_tail_x15_r0_body.cx0_72.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow72 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd72.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P72.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd72.nodeF j) PRE_first_tail_x15_r0_body.cx1_72.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a72 : PRE_first_tail_x15_r0_body.cx0_72.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b72 : PRE_first_tail_x15_r0_body.cx0_72.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok172 : PRE_first_tail_x15_r0_body.cx1_72.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend72 : PRE_first_tail_x15_r0_body.cx1_72.mlx.pending = PRE_first_tail_x15_r0_body.cx0_72.mlx.pending.map PRE_first_tail_x15_r0_body.kappa72.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh72 : PRE_first_tail_x15_r0_body.cx1_72.mlx.errh = PRE_first_tail_x15_r0_body.cx0_72.mlx.errh.map PRE_first_tail_x15_r0_body.kappa72.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles72 : PRE_first_tail_x15_r0_body.cx1_72.mlx.files = PRE_first_tail_x15_r0_body.cx0_72.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch72 : PRE_first_tail_x15_r0_body.cx1_72.mlx.arch = PRE_first_tail_x15_r0_body.cx0_72.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes72 : PRE_first_tail_x15_r0_body.cx1_72.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_72.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired72 : PRE_first_tail_x15_r0_body.cx1_72.mlx.wired = PRE_first_tail_x15_r0_body.cx0_72.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost72 : PRE_first_tail_x15_r0_body.cx1_72.host = PRE_first_tail_x15_r0_body.cx0_72.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd72`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn072 : PRE_first_tail_x15_r0_body.kd72.n0 = 2731965
kernel_rfl PRE_first_tail_x15_r0_body.ckn172 : PRE_first_tail_x15_r0_body.kd72.n1 = 2733114
kernel_rfl PRE_first_tail_x15_r0_body.ckheap72 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd72.heap).all (fun x => Nat.ble 2731959 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl72 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd72.heap.get (2731959 + j) = nth? PRE_first_tail_x15_r0_body.pl72 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja72 : Nat.ble 2731959 2731959 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn72 : Nat.ble 3161 3161 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD72 : Nat.ble 2731959 PRE_first_tail_x15_r0_body.kd72.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn72 : Nat.ble 19632 PRE_first_tail_x15_r0_body.kd72.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn72 : Nat.ble 16700 PRE_first_tail_x15_r0_body.kd72.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb72 : Nat.ble 19632 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap72 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd72.heap).all (Nat.ble (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd72 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd72.hnd).all (Nat.ble (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode72 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd72.node).all (Nat.ble (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix72 : Conv.FixOld (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa72 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja72) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn72) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD72) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn72) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn72) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb72) PRE_first_tail_x15_r0_body.fheap72 PRE_first_tail_x15_r0_body.fhnd72 PRE_first_tail_x15_r0_body.fnode72
kernel_rfl PRE_first_tail_x15_r0_body.fcxn72 : (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn72 : (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle072 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_72.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_72.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk72 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd72.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A72 : PRE_first_tail_x15_r0_body.cx1_72.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS72.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_72.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O72 : PRE_first_tail_x15_r0_body.cx1_72.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS72.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_72.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N72 : PRE_first_tail_x15_r0_body.cx1_72.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS72.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_72.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I72 : PRE_first_tail_x15_r0_body.cx1_72.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS72.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_72.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd72 : (PRE_first_tail_x15_r0_body.clo72 ++ PRE_first_tail_x15_r0_body.cln72 ++ PRE_first_tail_x15_r0_body.cli72 ++ PRE_first_tail_x15_r0_body.cwS72 ++ PRE_first_tail_x15_r0_body.cnS72 ++ PRE_first_tail_x15_r0_body.ciS72).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW72 : PRE_first_tail_x15_r0_body.cwS72.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo72.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI72 : PRE_first_tail_x15_r0_body.ciS72.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli72.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN72 : PRE_first_tail_x15_r0_body.cnS72.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF72 : PRE_first_tail_x15_r0_body.cln72.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh72 : PRE_first_tail_x15_r0_body.clo72.all (handleOK PRE_first_tail_x15_r0_body.kappa72 PRE_first_tail_x15_r0_body.P72.lo PRE_first_tail_x15_r0_body.cx0_72.mlx PRE_first_tail_x15_r0_body.cx1_72.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo72 : PRE_first_tail_x15_r0_body.clo72.map (fun h => PRE_first_tail_x15_r0_body.cx1_72.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa72.handle h)) = PRE_first_tail_x15_r0_body.clo72.map (fun h => (PRE_first_tail_x15_r0_body.cx0_72.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa72.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok72 : PRE_first_tail_x15_r0_body.clo72.all (objOK PRE_first_tail_x15_r0_body.kappa72 PRE_first_tail_x15_r0_body.P72.NL PRE_first_tail_x15_r0_body.cx0_72.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd72 : PRE_first_tail_x15_r0_body.cln72.all (nodeOKF PRE_first_tail_x15_r0_body.kappa72 PRE_first_tail_x15_r0_body.P72 PRE_first_tail_x15_r0_body.cx0_72.mlx PRE_first_tail_x15_r0_body.cx1_72.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp72 : ((PRE_first_tail_x15_r0_body.cln72.filter (fullB PRE_first_tail_x15_r0_body.P72))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_72.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa72.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln72.filter (fullB PRE_first_tail_x15_r0_body.P72))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_72.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa72.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI72 : incrB PRE_first_tail_x15_r0_body.kd72.nodeF (List.range' 16700 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK72 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd72.node).all (fun k => Nat.ble 16700 k && Nat.blt k 16727) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL72 : (PRE_first_tail_x15_r0_body.cln72.filter (Nat.ble PRE_first_tail_x15_r0_body.P72.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd72.nodeF i) && (Nat.blt i 16727 || Nat.ble PRE_first_tail_x15_r0_body.kd72.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord72 : (PRE_first_tail_x15_r0_body.cln72.filter (Nat.ble PRE_first_tail_x15_r0_body.P72.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd72.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd72.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd72.nodeF j) (PRE_first_tail_x15_r0_body.kd72.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow72 PRE_first_tail_x15_r0_body.cnn172 PRE_first_tail_x15_r0_body.fnordI72 PRE_first_tail_x15_r0_body.fnordK72 PRE_first_tail_x15_r0_body.fnordL72
kernel_rfl PRE_first_tail_x15_r0_body.fi72 : PRE_first_tail_x15_r0_body.cli72.all (pnB PRE_first_tail_x15_r0_body.cx0_72.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii72 : PRE_first_tail_x15_r0_body.cli72.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_72.mlx.items.get (PRE_first_tail_x15_r0_body.kappa72.node k) = (PRE_first_tail_x15_r0_body.cx0_72.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa72.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot72 (clean : Conv.NClean (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P72.NL) (cl : SSt (· < 3179) PRE_first_tail_x15_r0_body.cx0_72.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P72 3179 PRE_first_tail_x15_r0_body.kappa72 PRE_first_tail_x15_r0_body.kd72 PRE_first_tail_x15_r0_body.khinv72 PRE_first_tail_x15_r0_body.kninv72 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx PRE_first_tail_x15_r0_body.cx0_72.mlx PRE_first_tail_x15_r0_body.cx1_72.mlx (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo72 PRE_first_tail_x15_r0_body.cln72 PRE_first_tail_x15_r0_body.cli72 PRE_first_tail_x15_r0_body.cwS72 PRE_first_tail_x15_r0_body.cnS72 PRE_first_tail_x15_r0_body.ciS72 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh072, PRE_first_tail_x15_r0_body.cnh172, PRE_first_tail_x15_r0_body.cnn072, PRE_first_tail_x15_r0_body.cnn172, PRE_first_tail_x15_r0_body.cplo72, PRE_first_tail_x15_r0_body.ccnt72, PRE_first_tail_x15_r0_body.cnband72, PRE_first_tail_x15_r0_body.chbelow72, PRE_first_tail_x15_r0_body.chren72, PRE_first_tail_x15_r0_body.cband72, PRE_first_tail_x15_r0_body.cnh1pos72, PRE_first_tail_x15_r0_body.cnren72, PRE_first_tail_x15_r0_body.cnlow72, PRE_first_tail_x15_r0_body.cabs0a72, PRE_first_tail_x15_r0_body.cabs0b72, PRE_first_tail_x15_r0_body.ctok172, PRE_first_tail_x15_r0_body.cpend72, PRE_first_tail_x15_r0_body.cerrh72, PRE_first_tail_x15_r0_body.cfiles72, PRE_first_tail_x15_r0_body.carch72, PRE_first_tail_x15_r0_body.csizes72, PRE_first_tail_x15_r0_body.cwired72, PRE_first_tail_x15_r0_body.cfix72, clean, PRE_first_tail_x15_r0_body.fcxn72, PRE_first_tail_x15_r0_body.fcnn72, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle072, PRE_first_tail_x15_r0_body.fnk72, PRE_first_tail_x15_r0_body.ckA72, PRE_first_tail_x15_r0_body.cobjsK72, PRE_first_tail_x15_r0_body.cnodesK72, PRE_first_tail_x15_r0_body.citemsK72, PRE_first_tail_x15_r0_body.f1A72, PRE_first_tail_x15_r0_body.f1O72, PRE_first_tail_x15_r0_body.f1N72, PRE_first_tail_x15_r0_body.f1I72, PRE_first_tail_x15_r0_body.fbd72, PRE_first_tail_x15_r0_body.fincW72, PRE_first_tail_x15_r0_body.fincI72, PRE_first_tail_x15_r0_body.fincN72, PRE_first_tail_x15_r0_body.flnF72, PRE_first_tail_x15_r0_body.fh72, PRE_first_tail_x15_r0_body.fo72, PRE_first_tail_x15_r0_body.fok72, PRE_first_tail_x15_r0_body.fnd72, PRE_first_tail_x15_r0_body.fp72, PRE_first_tail_x15_r0_body.fnord72, PRE_first_tail_x15_r0_body.fi72, PRE_first_tail_x15_r0_body.fii72⟩
theorem PRE_first_tail_x15_r0_body.cnshift72 (clean : Conv.NClean (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P72.NL) (cl : SSt (· < 3179) PRE_first_tail_x15_r0_body.cx0_72.mlx) : NShift PRE_first_tail_x15_r0_body.P72 3179 PRE_first_tail_x15_r0_body.kappa72 PRE_first_tail_x15_r0_body.cx0_72 PRE_first_tail_x15_r0_body.cx1_72 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot72 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost72 (compact_a_eq PRE_first_tail_x15_r0_body.ckn072 PRE_first_tail_x15_r0_body.ckn172 PRE_first_tail_x15_r0_body.ckheap72 PRE_first_tail_x15_r0_body.ckpl72)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_72 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s706.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_72 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s706.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_72 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s706.ffi) = some PRE_first_tail_x15_r0_body.fxC_72
kernel_rfl PRE_first_tail_x15_r0_body.okrC_72 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s706.ffi) = some PRE_first_tail_x15_r0_body.krC_72
noncomputable def PRE_first_tail_x15_r0_body.fx0_72 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s708.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_72 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s708.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_72 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s708.ffi) = some PRE_first_tail_x15_r0_body.fx0_72
kernel_rfl PRE_first_tail_x15_r0_body.okr0_72 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s708.ffi) = some PRE_first_tail_x15_r0_body.kr0_72
noncomputable def PRE_first_tail_x15_r0_body.fx1_72 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s707.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_72 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s707.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_72 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s707.ffi) = some PRE_first_tail_x15_r0_body.fx1_72
kernel_rfl PRE_first_tail_x15_r0_body.okr1_72 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s707.ffi) = some PRE_first_tail_x15_r0_body.kr1_72
kernel_rfl PRE_first_tail_x15_r0_body.ff072 : PRE_first_tail_x15_r0_body.fx0_72 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_72 (PRE_first_tail_x15_r0_body.clo72.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_72.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff172 : PRE_first_tail_x15_r0_body.fx1_72 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_72 (PRE_first_tail_x15_r0_body.cwS72.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_72.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck72 : freedLB PRE_first_tail_x15_r0_body.kappa72 PRE_first_tail_x15_r0_body.cx0_72.mlx PRE_first_tail_x15_r0_body.fx0_72 PRE_first_tail_x15_r0_body.fx1_72 PRE_first_tail_x15_r0_body.clo72 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf072 : PRE_first_tail_x15_r0_body.kr0_72.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_72.flags (PRE_first_tail_x15_r0_body.clo72.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_72.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt072 : PRE_first_tail_x15_r0_body.kr0_72.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_72.targs (PRE_first_tail_x15_r0_body.clo72.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_72.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf172 : PRE_first_tail_x15_r0_body.kr1_72.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_72.flags (PRE_first_tail_x15_r0_body.cwS72.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_72.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt172 : PRE_first_tail_x15_r0_body.kr1_72.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_72.targs (PRE_first_tail_x15_r0_body.cwS72.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_72.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck72 : krecLB PRE_first_tail_x15_r0_body.kappa72 3179 PRE_first_tail_x15_r0_body.cx0_72.mlx PRE_first_tail_x15_r0_body.kr0_72 PRE_first_tail_x15_r0_body.kr1_72 PRE_first_tail_x15_r0_body.clo72 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn72 : Nat.ble 3161 3179 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge72 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s707.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s708.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR72 : pendRegB PRE_first_tail_x15_r0_body.kappa72 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe72 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s707.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift72 (clean : Conv.NClean (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P72.NL) (cl : SSt (· < 3179) PRE_first_tail_x15_r0_body.cx0_72.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_72.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_72.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_72.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_72.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P72 3179 PRE_first_tail_x15_r0_body.kappa72 PRE_first_tail_x15_r0_body.s708.ffi PRE_first_tail_x15_r0_body.s707.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift72 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue72, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp72 t ht),
    PRE_first_tail_x15_r0_body.cbridge72,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s708.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s707.ffi) (PRE_first_tail_x15_r0_body.cfoot72 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_72 PRE_first_tail_x15_r0_body.ofx1_72 hobjC PRE_first_tail_x15_r0_body.ff072 PRE_first_tail_x15_r0_body.ff172 PRE_first_tail_x15_r0_body.ffck72,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s708.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s707.ffi) (PRE_first_tail_x15_r0_body.cfoot72 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_72 PRE_first_tail_x15_r0_body.okr1_72 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn72) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf072 PRE_first_tail_x15_r0_body.fkt072 PRE_first_tail_x15_r0_body.fkf172 PRE_first_tail_x15_r0_body.fkt172 PRE_first_tail_x15_r0_body.fkck72,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh072 PRE_first_tail_x15_r0_body.cnh172 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe72) PRE_first_tail_x15_r0_body.cpendR72⟩

end Host.Load.Run.Tpl

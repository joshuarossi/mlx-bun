import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl21
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 21 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc21 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P21 : LoadP := PRE_first_tail_x15_r0_body.Pc21.raise 15719
kernel_rfl PRE_first_tail_x15_r0_body.craise21 : Nat.ble PRE_first_tail_x15_r0_body.Pc21.N0 15719 = true
theorem PRE_first_tail_x15_r0_body.raised21 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc21 PRE_first_tail_x15_r0_body.P21 :=
  .inr ⟨15719, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise21, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_21 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s199.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_21 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s198.ffi)
def PRE_first_tail_x15_r0_body.khinv21 : PTrie Nat := Stage.setAll PTrie.nil [(18631, 18629), (18632, 18630), (18634, 18631), (18633, 18632)]
def PRE_first_tail_x15_r0_body.kninv21 : PTrie Nat := Stage.setAll PTrie.nil [(15713, 15713), (15714, 15714), (15715, 15715), (15716, 15716), (15717, 15717), (15718, 15718)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS21 : List Nat := [18629, 18630, 18631, 18632, 18633, 18634]
def PRE_first_tail_x15_r0_body.cnS21 : List Nat := List.range' 15713 6
def PRE_first_tail_x15_r0_body.ciS21 : List Nat := [] ++ List.range' 15713 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh021 : PRE_first_tail_x15_r0_body.kd21.nh0 = PRE_first_tail_x15_r0_body.cx0_21.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh121 : PRE_first_tail_x15_r0_body.kd21.nh1 = PRE_first_tail_x15_r0_body.cx1_21.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn021 : PRE_first_tail_x15_r0_body.kd21.nn0 = PRE_first_tail_x15_r0_body.cx0_21.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn121 : PRE_first_tail_x15_r0_body.kd21.nn1 = PRE_first_tail_x15_r0_body.cx1_21.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo21 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P21.lo && Nat.ble PRE_first_tail_x15_r0_body.P21.lo PRE_first_tail_x15_r0_body.cx0_21.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P21.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P21.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt21 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_21.mlx.next PRE_first_tail_x15_r0_body.cx1_21.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_21.mlx.nnext PRE_first_tail_x15_r0_body.cx1_21.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband21 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P21.NL && Nat.ble PRE_first_tail_x15_r0_body.P21.NL PRE_first_tail_x15_r0_body.P21.N0 && Nat.ble PRE_first_tail_x15_r0_body.P21.N0 PRE_first_tail_x15_r0_body.cx0_21.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow21 : PRE_first_tail_x15_r0_body.kd21.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren21 : checkRenG PRE_first_tail_x15_r0_body.kd21.hnd PRE_first_tail_x15_r0_body.khinv21 (phB PRE_first_tail_x15_r0_body.cx0_21.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband21 : PRE_first_tail_x15_r0_body.kd21.checkBand PRE_first_tail_x15_r0_body.P21.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos21 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd21.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren21 : checkRenG PRE_first_tail_x15_r0_body.kd21.node PRE_first_tail_x15_r0_body.kninv21 (pnB PRE_first_tail_x15_r0_body.cx0_21.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow21 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd21.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P21.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd21.nodeF j) PRE_first_tail_x15_r0_body.cx1_21.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a21 : PRE_first_tail_x15_r0_body.cx0_21.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b21 : PRE_first_tail_x15_r0_body.cx0_21.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok121 : PRE_first_tail_x15_r0_body.cx1_21.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend21 : PRE_first_tail_x15_r0_body.cx1_21.mlx.pending = PRE_first_tail_x15_r0_body.cx0_21.mlx.pending.map PRE_first_tail_x15_r0_body.kappa21.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh21 : PRE_first_tail_x15_r0_body.cx1_21.mlx.errh = PRE_first_tail_x15_r0_body.cx0_21.mlx.errh.map PRE_first_tail_x15_r0_body.kappa21.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles21 : PRE_first_tail_x15_r0_body.cx1_21.mlx.files = PRE_first_tail_x15_r0_body.cx0_21.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch21 : PRE_first_tail_x15_r0_body.cx1_21.mlx.arch = PRE_first_tail_x15_r0_body.cx0_21.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes21 : PRE_first_tail_x15_r0_body.cx1_21.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_21.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired21 : PRE_first_tail_x15_r0_body.cx1_21.mlx.wired = PRE_first_tail_x15_r0_body.cx0_21.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost21 : PRE_first_tail_x15_r0_body.cx1_21.host = PRE_first_tail_x15_r0_body.cx0_21.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd21`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn021 : PRE_first_tail_x15_r0_body.kd21.n0 = 2691923
kernel_rfl PRE_first_tail_x15_r0_body.ckn121 : PRE_first_tail_x15_r0_body.kd21.n1 = 2692273
kernel_rfl PRE_first_tail_x15_r0_body.ckheap21 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd21.heap).all (fun x => Nat.ble 2691908 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl21 : (List.range 15).all (fun j => decide (PRE_first_tail_x15_r0_body.kd21.heap.get (2691908 + j) = nth? PRE_first_tail_x15_r0_body.pl21 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja21 : Nat.ble 2691908 2691908 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn21 : Nat.ble 987 987 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD21 : Nat.ble 2691908 PRE_first_tail_x15_r0_body.kd21.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn21 : Nat.ble 18629 PRE_first_tail_x15_r0_body.kd21.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn21 : Nat.ble 15713 PRE_first_tail_x15_r0_body.kd21.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb21 : Nat.ble 18629 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap21 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd21.heap).all (Nat.ble (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd21 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd21.hnd).all (Nat.ble (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode21 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd21.node).all (Nat.ble (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix21 : Conv.FixOld (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa21 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja21) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn21) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD21) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn21) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn21) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb21) PRE_first_tail_x15_r0_body.fheap21 PRE_first_tail_x15_r0_body.fhnd21 PRE_first_tail_x15_r0_body.fnode21
kernel_rfl PRE_first_tail_x15_r0_body.fcxn21 : (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn21 : (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle021 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_21.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_21.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk21 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd21.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A21 : PRE_first_tail_x15_r0_body.cx1_21.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS21.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_21.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O21 : PRE_first_tail_x15_r0_body.cx1_21.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS21.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_21.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N21 : PRE_first_tail_x15_r0_body.cx1_21.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS21.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_21.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I21 : PRE_first_tail_x15_r0_body.cx1_21.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS21.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_21.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd21 : (PRE_first_tail_x15_r0_body.clo21 ++ PRE_first_tail_x15_r0_body.cln21 ++ PRE_first_tail_x15_r0_body.cli21 ++ PRE_first_tail_x15_r0_body.cwS21 ++ PRE_first_tail_x15_r0_body.cnS21 ++ PRE_first_tail_x15_r0_body.ciS21).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW21 : PRE_first_tail_x15_r0_body.cwS21.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo21.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI21 : PRE_first_tail_x15_r0_body.ciS21.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli21.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN21 : PRE_first_tail_x15_r0_body.cnS21.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF21 : PRE_first_tail_x15_r0_body.cln21.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh21 : PRE_first_tail_x15_r0_body.clo21.all (handleOK PRE_first_tail_x15_r0_body.kappa21 PRE_first_tail_x15_r0_body.P21.lo PRE_first_tail_x15_r0_body.cx0_21.mlx PRE_first_tail_x15_r0_body.cx1_21.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo21 : PRE_first_tail_x15_r0_body.clo21.map (fun h => PRE_first_tail_x15_r0_body.cx1_21.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa21.handle h)) = PRE_first_tail_x15_r0_body.clo21.map (fun h => (PRE_first_tail_x15_r0_body.cx0_21.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa21.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok21 : PRE_first_tail_x15_r0_body.clo21.all (objOK PRE_first_tail_x15_r0_body.kappa21 PRE_first_tail_x15_r0_body.P21.NL PRE_first_tail_x15_r0_body.cx0_21.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd21 : PRE_first_tail_x15_r0_body.cln21.all (nodeOKF PRE_first_tail_x15_r0_body.kappa21 PRE_first_tail_x15_r0_body.P21 PRE_first_tail_x15_r0_body.cx0_21.mlx PRE_first_tail_x15_r0_body.cx1_21.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp21 : ((PRE_first_tail_x15_r0_body.cln21.filter (fullB PRE_first_tail_x15_r0_body.P21))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_21.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa21.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln21.filter (fullB PRE_first_tail_x15_r0_body.P21))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_21.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa21.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI21 : incrB PRE_first_tail_x15_r0_body.kd21.nodeF (List.range' 15713 6) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK21 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd21.node).all (fun k => Nat.ble 15713 k && Nat.blt k 15719) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL21 : (PRE_first_tail_x15_r0_body.cln21.filter (Nat.ble PRE_first_tail_x15_r0_body.P21.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd21.nodeF i) && (Nat.blt i 15719 || Nat.ble PRE_first_tail_x15_r0_body.kd21.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord21 : (PRE_first_tail_x15_r0_body.cln21.filter (Nat.ble PRE_first_tail_x15_r0_body.P21.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd21.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd21.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd21.nodeF j) (PRE_first_tail_x15_r0_body.kd21.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow21 PRE_first_tail_x15_r0_body.cnn121 PRE_first_tail_x15_r0_body.fnordI21 PRE_first_tail_x15_r0_body.fnordK21 PRE_first_tail_x15_r0_body.fnordL21
kernel_rfl PRE_first_tail_x15_r0_body.fi21 : PRE_first_tail_x15_r0_body.cli21.all (pnB PRE_first_tail_x15_r0_body.cx0_21.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii21 : PRE_first_tail_x15_r0_body.cli21.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_21.mlx.items.get (PRE_first_tail_x15_r0_body.kappa21.node k) = (PRE_first_tail_x15_r0_body.cx0_21.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa21.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot21 (clean : Conv.NClean (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P21.NL) (cl : SSt (· < 996) PRE_first_tail_x15_r0_body.cx0_21.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P21 996 PRE_first_tail_x15_r0_body.kappa21 PRE_first_tail_x15_r0_body.kd21 PRE_first_tail_x15_r0_body.khinv21 PRE_first_tail_x15_r0_body.kninv21 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx PRE_first_tail_x15_r0_body.cx0_21.mlx PRE_first_tail_x15_r0_body.cx1_21.mlx (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo21 PRE_first_tail_x15_r0_body.cln21 PRE_first_tail_x15_r0_body.cli21 PRE_first_tail_x15_r0_body.cwS21 PRE_first_tail_x15_r0_body.cnS21 PRE_first_tail_x15_r0_body.ciS21 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh021, PRE_first_tail_x15_r0_body.cnh121, PRE_first_tail_x15_r0_body.cnn021, PRE_first_tail_x15_r0_body.cnn121, PRE_first_tail_x15_r0_body.cplo21, PRE_first_tail_x15_r0_body.ccnt21, PRE_first_tail_x15_r0_body.cnband21, PRE_first_tail_x15_r0_body.chbelow21, PRE_first_tail_x15_r0_body.chren21, PRE_first_tail_x15_r0_body.cband21, PRE_first_tail_x15_r0_body.cnh1pos21, PRE_first_tail_x15_r0_body.cnren21, PRE_first_tail_x15_r0_body.cnlow21, PRE_first_tail_x15_r0_body.cabs0a21, PRE_first_tail_x15_r0_body.cabs0b21, PRE_first_tail_x15_r0_body.ctok121, PRE_first_tail_x15_r0_body.cpend21, PRE_first_tail_x15_r0_body.cerrh21, PRE_first_tail_x15_r0_body.cfiles21, PRE_first_tail_x15_r0_body.carch21, PRE_first_tail_x15_r0_body.csizes21, PRE_first_tail_x15_r0_body.cwired21, PRE_first_tail_x15_r0_body.cfix21, clean, PRE_first_tail_x15_r0_body.fcxn21, PRE_first_tail_x15_r0_body.fcnn21, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle021, PRE_first_tail_x15_r0_body.fnk21, PRE_first_tail_x15_r0_body.ckA21, PRE_first_tail_x15_r0_body.cobjsK21, PRE_first_tail_x15_r0_body.cnodesK21, PRE_first_tail_x15_r0_body.citemsK21, PRE_first_tail_x15_r0_body.f1A21, PRE_first_tail_x15_r0_body.f1O21, PRE_first_tail_x15_r0_body.f1N21, PRE_first_tail_x15_r0_body.f1I21, PRE_first_tail_x15_r0_body.fbd21, PRE_first_tail_x15_r0_body.fincW21, PRE_first_tail_x15_r0_body.fincI21, PRE_first_tail_x15_r0_body.fincN21, PRE_first_tail_x15_r0_body.flnF21, PRE_first_tail_x15_r0_body.fh21, PRE_first_tail_x15_r0_body.fo21, PRE_first_tail_x15_r0_body.fok21, PRE_first_tail_x15_r0_body.fnd21, PRE_first_tail_x15_r0_body.fp21, PRE_first_tail_x15_r0_body.fnord21, PRE_first_tail_x15_r0_body.fi21, PRE_first_tail_x15_r0_body.fii21⟩
theorem PRE_first_tail_x15_r0_body.cnshift21 (clean : Conv.NClean (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P21.NL) (cl : SSt (· < 996) PRE_first_tail_x15_r0_body.cx0_21.mlx) : NShift PRE_first_tail_x15_r0_body.P21 996 PRE_first_tail_x15_r0_body.kappa21 PRE_first_tail_x15_r0_body.cx0_21 PRE_first_tail_x15_r0_body.cx1_21 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot21 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost21 (compact_a_eq PRE_first_tail_x15_r0_body.ckn021 PRE_first_tail_x15_r0_body.ckn121 PRE_first_tail_x15_r0_body.ckheap21 PRE_first_tail_x15_r0_body.ckpl21)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_21 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s197.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_21 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s197.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_21 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s197.ffi) = some PRE_first_tail_x15_r0_body.fxC_21
kernel_rfl PRE_first_tail_x15_r0_body.okrC_21 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s197.ffi) = some PRE_first_tail_x15_r0_body.krC_21
noncomputable def PRE_first_tail_x15_r0_body.fx0_21 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s199.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_21 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s199.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_21 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s199.ffi) = some PRE_first_tail_x15_r0_body.fx0_21
kernel_rfl PRE_first_tail_x15_r0_body.okr0_21 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s199.ffi) = some PRE_first_tail_x15_r0_body.kr0_21
noncomputable def PRE_first_tail_x15_r0_body.fx1_21 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s198.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_21 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s198.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_21 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s198.ffi) = some PRE_first_tail_x15_r0_body.fx1_21
kernel_rfl PRE_first_tail_x15_r0_body.okr1_21 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s198.ffi) = some PRE_first_tail_x15_r0_body.kr1_21
kernel_rfl PRE_first_tail_x15_r0_body.ff021 : PRE_first_tail_x15_r0_body.fx0_21 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_21 (PRE_first_tail_x15_r0_body.clo21.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_21.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff121 : PRE_first_tail_x15_r0_body.fx1_21 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_21 (PRE_first_tail_x15_r0_body.cwS21.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_21.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck21 : freedLB PRE_first_tail_x15_r0_body.kappa21 PRE_first_tail_x15_r0_body.cx0_21.mlx PRE_first_tail_x15_r0_body.fx0_21 PRE_first_tail_x15_r0_body.fx1_21 PRE_first_tail_x15_r0_body.clo21 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf021 : PRE_first_tail_x15_r0_body.kr0_21.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_21.flags (PRE_first_tail_x15_r0_body.clo21.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_21.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt021 : PRE_first_tail_x15_r0_body.kr0_21.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_21.targs (PRE_first_tail_x15_r0_body.clo21.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_21.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf121 : PRE_first_tail_x15_r0_body.kr1_21.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_21.flags (PRE_first_tail_x15_r0_body.cwS21.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_21.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt121 : PRE_first_tail_x15_r0_body.kr1_21.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_21.targs (PRE_first_tail_x15_r0_body.cwS21.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_21.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck21 : krecLB PRE_first_tail_x15_r0_body.kappa21 996 PRE_first_tail_x15_r0_body.cx0_21.mlx PRE_first_tail_x15_r0_body.kr0_21 PRE_first_tail_x15_r0_body.kr1_21 PRE_first_tail_x15_r0_body.clo21 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn21 : Nat.ble 987 996 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge21 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s198.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s199.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR21 : pendRegB PRE_first_tail_x15_r0_body.kappa21 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s199.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe21 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s199.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s198.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift21 (clean : Conv.NClean (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P21.NL) (cl : SSt (· < 996) PRE_first_tail_x15_r0_body.cx0_21.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_21.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_21.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_21.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_21.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P21 996 PRE_first_tail_x15_r0_body.kappa21 PRE_first_tail_x15_r0_body.s199.ffi PRE_first_tail_x15_r0_body.s198.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift21 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue21, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp21 t ht),
    PRE_first_tail_x15_r0_body.cbridge21,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s199.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s198.ffi) (PRE_first_tail_x15_r0_body.cfoot21 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_21 PRE_first_tail_x15_r0_body.ofx1_21 hobjC PRE_first_tail_x15_r0_body.ff021 PRE_first_tail_x15_r0_body.ff121 PRE_first_tail_x15_r0_body.ffck21,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s199.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s198.ffi) (PRE_first_tail_x15_r0_body.cfoot21 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_21 PRE_first_tail_x15_r0_body.okr1_21 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn21) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf021 PRE_first_tail_x15_r0_body.fkt021 PRE_first_tail_x15_r0_body.fkf121 PRE_first_tail_x15_r0_body.fkt121 PRE_first_tail_x15_r0_body.fkck21,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh021 PRE_first_tail_x15_r0_body.cnh121 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe21) PRE_first_tail_x15_r0_body.cpendR21⟩

end Host.Load.Run.Tpl

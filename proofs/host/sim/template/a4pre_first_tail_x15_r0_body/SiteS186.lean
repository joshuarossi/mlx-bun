import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl186
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 186 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc186 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P186 : LoadP := PRE_first_tail_x15_r0_body.Pc186.raise 18986
kernel_rfl PRE_first_tail_x15_r0_body.craise186 : Nat.ble PRE_first_tail_x15_r0_body.Pc186.N0 18986 = true
theorem PRE_first_tail_x15_r0_body.raised186 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc186 PRE_first_tail_x15_r0_body.P186 :=
  .inr ⟨18986, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise186, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_186 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1801.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_186 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1800.ffi)
def PRE_first_tail_x15_r0_body.khinv186 : PTrie Nat := Stage.setAll PTrie.nil [(21896, 21870), (21874, 21871), (21897, 21872)]
def PRE_first_tail_x15_r0_body.kninv186 : PTrie Nat := Stage.setAll PTrie.nil [(18959, 18959), (18960, 18960), (18961, 18961), (18962, 18962), (18963, 18963), (18964, 18964), (18965, 18965), (18966, 18966), (18967, 18967), (18968, 18968), (18969, 18969), (18970, 18970), (18971, 18971), (18972, 18972), (18973, 18973), (18974, 18974), (18975, 18975), (18976, 18976), (18977, 18977), (18978, 18978), (18979, 18979), (18980, 18980), (18981, 18981), (18982, 18982), (18983, 18983), (18984, 18984), (18985, 18985)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS186 : List Nat := [21850, 21863, 21869, 21870, 21871, 21872, 21873, 21874, 21875, 21876, 21877, 21878, 21879, 21880, 21881, 21882, 21883, 21884, 21885, 21886, 21887, 21888, 21889, 21890, 21891, 21892, 21893, 21894, 21895, 21896, 21897]
def PRE_first_tail_x15_r0_body.cnS186 : List Nat := List.range' 18959 27
def PRE_first_tail_x15_r0_body.ciS186 : List Nat := [] ++ List.range' 18959 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0186 : PRE_first_tail_x15_r0_body.kd186.nh0 = PRE_first_tail_x15_r0_body.cx0_186.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1186 : PRE_first_tail_x15_r0_body.kd186.nh1 = PRE_first_tail_x15_r0_body.cx1_186.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0186 : PRE_first_tail_x15_r0_body.kd186.nn0 = PRE_first_tail_x15_r0_body.cx0_186.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1186 : PRE_first_tail_x15_r0_body.kd186.nn1 = PRE_first_tail_x15_r0_body.cx1_186.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo186 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P186.lo && Nat.ble PRE_first_tail_x15_r0_body.P186.lo PRE_first_tail_x15_r0_body.cx0_186.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P186.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P186.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt186 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_186.mlx.next PRE_first_tail_x15_r0_body.cx1_186.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_186.mlx.nnext PRE_first_tail_x15_r0_body.cx1_186.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband186 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P186.NL && Nat.ble PRE_first_tail_x15_r0_body.P186.NL PRE_first_tail_x15_r0_body.P186.N0 && Nat.ble PRE_first_tail_x15_r0_body.P186.N0 PRE_first_tail_x15_r0_body.cx0_186.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow186 : PRE_first_tail_x15_r0_body.kd186.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren186 : checkRenG PRE_first_tail_x15_r0_body.kd186.hnd PRE_first_tail_x15_r0_body.khinv186 (phB PRE_first_tail_x15_r0_body.cx0_186.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband186 : PRE_first_tail_x15_r0_body.kd186.checkBand PRE_first_tail_x15_r0_body.P186.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos186 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd186.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren186 : checkRenG PRE_first_tail_x15_r0_body.kd186.node PRE_first_tail_x15_r0_body.kninv186 (pnB PRE_first_tail_x15_r0_body.cx0_186.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow186 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd186.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P186.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd186.nodeF j) PRE_first_tail_x15_r0_body.cx1_186.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a186 : PRE_first_tail_x15_r0_body.cx0_186.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b186 : PRE_first_tail_x15_r0_body.cx0_186.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1186 : PRE_first_tail_x15_r0_body.cx1_186.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend186 : PRE_first_tail_x15_r0_body.cx1_186.mlx.pending = PRE_first_tail_x15_r0_body.cx0_186.mlx.pending.map PRE_first_tail_x15_r0_body.kappa186.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh186 : PRE_first_tail_x15_r0_body.cx1_186.mlx.errh = PRE_first_tail_x15_r0_body.cx0_186.mlx.errh.map PRE_first_tail_x15_r0_body.kappa186.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles186 : PRE_first_tail_x15_r0_body.cx1_186.mlx.files = PRE_first_tail_x15_r0_body.cx0_186.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch186 : PRE_first_tail_x15_r0_body.cx1_186.mlx.arch = PRE_first_tail_x15_r0_body.cx0_186.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes186 : PRE_first_tail_x15_r0_body.cx1_186.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_186.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired186 : PRE_first_tail_x15_r0_body.cx1_186.mlx.wired = PRE_first_tail_x15_r0_body.cx0_186.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost186 : PRE_first_tail_x15_r0_body.cx1_186.host = PRE_first_tail_x15_r0_body.cx0_186.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd186`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0186 : PRE_first_tail_x15_r0_body.kd186.n0 = 2821253
kernel_rfl PRE_first_tail_x15_r0_body.ckn1186 : PRE_first_tail_x15_r0_body.kd186.n1 = 2822402
kernel_rfl PRE_first_tail_x15_r0_body.ckheap186 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd186.heap).all (fun x => Nat.ble 2821247 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl186 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd186.heap.get (2821247 + j) = nth? PRE_first_tail_x15_r0_body.pl186 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja186 : Nat.ble 2821247 2821247 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn186 : Nat.ble 8036 8036 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD186 : Nat.ble 2821247 PRE_first_tail_x15_r0_body.kd186.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn186 : Nat.ble 21870 PRE_first_tail_x15_r0_body.kd186.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn186 : Nat.ble 18959 PRE_first_tail_x15_r0_body.kd186.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb186 : Nat.ble 21870 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap186 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd186.heap).all (Nat.ble (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd186 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd186.hnd).all (Nat.ble (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode186 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd186.node).all (Nat.ble (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix186 : Conv.FixOld (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa186 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja186) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn186) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD186) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn186) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn186) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb186) PRE_first_tail_x15_r0_body.fheap186 PRE_first_tail_x15_r0_body.fhnd186 PRE_first_tail_x15_r0_body.fnode186
kernel_rfl PRE_first_tail_x15_r0_body.fcxn186 : (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn186 : (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0186 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_186.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_186.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk186 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd186.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A186 : PRE_first_tail_x15_r0_body.cx1_186.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS186.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_186.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O186 : PRE_first_tail_x15_r0_body.cx1_186.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS186.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_186.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N186 : PRE_first_tail_x15_r0_body.cx1_186.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS186.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_186.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I186 : PRE_first_tail_x15_r0_body.cx1_186.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS186.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_186.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd186 : (PRE_first_tail_x15_r0_body.clo186 ++ PRE_first_tail_x15_r0_body.cln186 ++ PRE_first_tail_x15_r0_body.cli186 ++ PRE_first_tail_x15_r0_body.cwS186 ++ PRE_first_tail_x15_r0_body.cnS186 ++ PRE_first_tail_x15_r0_body.ciS186).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW186 : PRE_first_tail_x15_r0_body.cwS186.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo186.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI186 : PRE_first_tail_x15_r0_body.ciS186.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli186.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN186 : PRE_first_tail_x15_r0_body.cnS186.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF186 : PRE_first_tail_x15_r0_body.cln186.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh186 : PRE_first_tail_x15_r0_body.clo186.all (handleOK PRE_first_tail_x15_r0_body.kappa186 PRE_first_tail_x15_r0_body.P186.lo PRE_first_tail_x15_r0_body.cx0_186.mlx PRE_first_tail_x15_r0_body.cx1_186.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo186 : PRE_first_tail_x15_r0_body.clo186.map (fun h => PRE_first_tail_x15_r0_body.cx1_186.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa186.handle h)) = PRE_first_tail_x15_r0_body.clo186.map (fun h => (PRE_first_tail_x15_r0_body.cx0_186.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa186.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok186 : PRE_first_tail_x15_r0_body.clo186.all (objOK PRE_first_tail_x15_r0_body.kappa186 PRE_first_tail_x15_r0_body.P186.NL PRE_first_tail_x15_r0_body.cx0_186.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd186 : PRE_first_tail_x15_r0_body.cln186.all (nodeOKF PRE_first_tail_x15_r0_body.kappa186 PRE_first_tail_x15_r0_body.P186 PRE_first_tail_x15_r0_body.cx0_186.mlx PRE_first_tail_x15_r0_body.cx1_186.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp186 : ((PRE_first_tail_x15_r0_body.cln186.filter (fullB PRE_first_tail_x15_r0_body.P186))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_186.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa186.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln186.filter (fullB PRE_first_tail_x15_r0_body.P186))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_186.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa186.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI186 : incrB PRE_first_tail_x15_r0_body.kd186.nodeF (List.range' 18959 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK186 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd186.node).all (fun k => Nat.ble 18959 k && Nat.blt k 18986) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL186 : (PRE_first_tail_x15_r0_body.cln186.filter (Nat.ble PRE_first_tail_x15_r0_body.P186.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd186.nodeF i) && (Nat.blt i 18986 || Nat.ble PRE_first_tail_x15_r0_body.kd186.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord186 : (PRE_first_tail_x15_r0_body.cln186.filter (Nat.ble PRE_first_tail_x15_r0_body.P186.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd186.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd186.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd186.nodeF j) (PRE_first_tail_x15_r0_body.kd186.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow186 PRE_first_tail_x15_r0_body.cnn1186 PRE_first_tail_x15_r0_body.fnordI186 PRE_first_tail_x15_r0_body.fnordK186 PRE_first_tail_x15_r0_body.fnordL186
kernel_rfl PRE_first_tail_x15_r0_body.fi186 : PRE_first_tail_x15_r0_body.cli186.all (pnB PRE_first_tail_x15_r0_body.cx0_186.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii186 : PRE_first_tail_x15_r0_body.cli186.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_186.mlx.items.get (PRE_first_tail_x15_r0_body.kappa186.node k) = (PRE_first_tail_x15_r0_body.cx0_186.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa186.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot186 (clean : Conv.NClean (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P186.NL) (cl : SSt (· < 8054) PRE_first_tail_x15_r0_body.cx0_186.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P186 8054 PRE_first_tail_x15_r0_body.kappa186 PRE_first_tail_x15_r0_body.kd186 PRE_first_tail_x15_r0_body.khinv186 PRE_first_tail_x15_r0_body.kninv186 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx PRE_first_tail_x15_r0_body.cx0_186.mlx PRE_first_tail_x15_r0_body.cx1_186.mlx (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo186 PRE_first_tail_x15_r0_body.cln186 PRE_first_tail_x15_r0_body.cli186 PRE_first_tail_x15_r0_body.cwS186 PRE_first_tail_x15_r0_body.cnS186 PRE_first_tail_x15_r0_body.ciS186 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0186, PRE_first_tail_x15_r0_body.cnh1186, PRE_first_tail_x15_r0_body.cnn0186, PRE_first_tail_x15_r0_body.cnn1186, PRE_first_tail_x15_r0_body.cplo186, PRE_first_tail_x15_r0_body.ccnt186, PRE_first_tail_x15_r0_body.cnband186, PRE_first_tail_x15_r0_body.chbelow186, PRE_first_tail_x15_r0_body.chren186, PRE_first_tail_x15_r0_body.cband186, PRE_first_tail_x15_r0_body.cnh1pos186, PRE_first_tail_x15_r0_body.cnren186, PRE_first_tail_x15_r0_body.cnlow186, PRE_first_tail_x15_r0_body.cabs0a186, PRE_first_tail_x15_r0_body.cabs0b186, PRE_first_tail_x15_r0_body.ctok1186, PRE_first_tail_x15_r0_body.cpend186, PRE_first_tail_x15_r0_body.cerrh186, PRE_first_tail_x15_r0_body.cfiles186, PRE_first_tail_x15_r0_body.carch186, PRE_first_tail_x15_r0_body.csizes186, PRE_first_tail_x15_r0_body.cwired186, PRE_first_tail_x15_r0_body.cfix186, clean, PRE_first_tail_x15_r0_body.fcxn186, PRE_first_tail_x15_r0_body.fcnn186, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0186, PRE_first_tail_x15_r0_body.fnk186, PRE_first_tail_x15_r0_body.ckA186, PRE_first_tail_x15_r0_body.cobjsK186, PRE_first_tail_x15_r0_body.cnodesK186, PRE_first_tail_x15_r0_body.citemsK186, PRE_first_tail_x15_r0_body.f1A186, PRE_first_tail_x15_r0_body.f1O186, PRE_first_tail_x15_r0_body.f1N186, PRE_first_tail_x15_r0_body.f1I186, PRE_first_tail_x15_r0_body.fbd186, PRE_first_tail_x15_r0_body.fincW186, PRE_first_tail_x15_r0_body.fincI186, PRE_first_tail_x15_r0_body.fincN186, PRE_first_tail_x15_r0_body.flnF186, PRE_first_tail_x15_r0_body.fh186, PRE_first_tail_x15_r0_body.fo186, PRE_first_tail_x15_r0_body.fok186, PRE_first_tail_x15_r0_body.fnd186, PRE_first_tail_x15_r0_body.fp186, PRE_first_tail_x15_r0_body.fnord186, PRE_first_tail_x15_r0_body.fi186, PRE_first_tail_x15_r0_body.fii186⟩
theorem PRE_first_tail_x15_r0_body.cnshift186 (clean : Conv.NClean (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P186.NL) (cl : SSt (· < 8054) PRE_first_tail_x15_r0_body.cx0_186.mlx) : NShift PRE_first_tail_x15_r0_body.P186 8054 PRE_first_tail_x15_r0_body.kappa186 PRE_first_tail_x15_r0_body.cx0_186 PRE_first_tail_x15_r0_body.cx1_186 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot186 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost186 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0186 PRE_first_tail_x15_r0_body.ckn1186 PRE_first_tail_x15_r0_body.ckheap186 PRE_first_tail_x15_r0_body.ckpl186)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_186 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1799.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_186 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1799.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_186 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1799.ffi) = some PRE_first_tail_x15_r0_body.fxC_186
kernel_rfl PRE_first_tail_x15_r0_body.okrC_186 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1799.ffi) = some PRE_first_tail_x15_r0_body.krC_186
noncomputable def PRE_first_tail_x15_r0_body.fx0_186 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1801.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_186 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1801.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_186 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1801.ffi) = some PRE_first_tail_x15_r0_body.fx0_186
kernel_rfl PRE_first_tail_x15_r0_body.okr0_186 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1801.ffi) = some PRE_first_tail_x15_r0_body.kr0_186
noncomputable def PRE_first_tail_x15_r0_body.fx1_186 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1800.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_186 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1800.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_186 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1800.ffi) = some PRE_first_tail_x15_r0_body.fx1_186
kernel_rfl PRE_first_tail_x15_r0_body.okr1_186 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1800.ffi) = some PRE_first_tail_x15_r0_body.kr1_186
kernel_rfl PRE_first_tail_x15_r0_body.ff0186 : PRE_first_tail_x15_r0_body.fx0_186 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_186 (PRE_first_tail_x15_r0_body.clo186.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_186.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1186 : PRE_first_tail_x15_r0_body.fx1_186 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_186 (PRE_first_tail_x15_r0_body.cwS186.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_186.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck186 : freedLB PRE_first_tail_x15_r0_body.kappa186 PRE_first_tail_x15_r0_body.cx0_186.mlx PRE_first_tail_x15_r0_body.fx0_186 PRE_first_tail_x15_r0_body.fx1_186 PRE_first_tail_x15_r0_body.clo186 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0186 : PRE_first_tail_x15_r0_body.kr0_186.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_186.flags (PRE_first_tail_x15_r0_body.clo186.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_186.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0186 : PRE_first_tail_x15_r0_body.kr0_186.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_186.targs (PRE_first_tail_x15_r0_body.clo186.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_186.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1186 : PRE_first_tail_x15_r0_body.kr1_186.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_186.flags (PRE_first_tail_x15_r0_body.cwS186.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_186.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1186 : PRE_first_tail_x15_r0_body.kr1_186.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_186.targs (PRE_first_tail_x15_r0_body.cwS186.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_186.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck186 : krecLB PRE_first_tail_x15_r0_body.kappa186 8054 PRE_first_tail_x15_r0_body.cx0_186.mlx PRE_first_tail_x15_r0_body.kr0_186 PRE_first_tail_x15_r0_body.kr1_186 PRE_first_tail_x15_r0_body.clo186 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn186 : Nat.ble 8036 8054 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge186 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1800.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1801.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR186 : pendRegB PRE_first_tail_x15_r0_body.kappa186 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1801.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe186 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1801.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1800.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift186 (clean : Conv.NClean (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P186.NL) (cl : SSt (· < 8054) PRE_first_tail_x15_r0_body.cx0_186.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_186.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_186.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_186.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_186.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P186 8054 PRE_first_tail_x15_r0_body.kappa186 PRE_first_tail_x15_r0_body.s1801.ffi PRE_first_tail_x15_r0_body.s1800.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift186 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue186, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp186 t ht),
    PRE_first_tail_x15_r0_body.cbridge186,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1801.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1800.ffi) (PRE_first_tail_x15_r0_body.cfoot186 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_186 PRE_first_tail_x15_r0_body.ofx1_186 hobjC PRE_first_tail_x15_r0_body.ff0186 PRE_first_tail_x15_r0_body.ff1186 PRE_first_tail_x15_r0_body.ffck186,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1801.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1800.ffi) (PRE_first_tail_x15_r0_body.cfoot186 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_186 PRE_first_tail_x15_r0_body.okr1_186 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn186) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0186 PRE_first_tail_x15_r0_body.fkt0186 PRE_first_tail_x15_r0_body.fkf1186 PRE_first_tail_x15_r0_body.fkt1186 PRE_first_tail_x15_r0_body.fkck186,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0186 PRE_first_tail_x15_r0_body.cnh1186 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe186) PRE_first_tail_x15_r0_body.cpendR186⟩

end Host.Load.Run.Tpl

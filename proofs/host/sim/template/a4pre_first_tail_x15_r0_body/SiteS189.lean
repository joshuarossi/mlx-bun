import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl189
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 189 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc189 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P189 : LoadP := PRE_first_tail_x15_r0_body.Pc189.raise 19037
kernel_rfl PRE_first_tail_x15_r0_body.craise189 : Nat.ble PRE_first_tail_x15_r0_body.Pc189.N0 19037 = true
theorem PRE_first_tail_x15_r0_body.raised189 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc189 PRE_first_tail_x15_r0_body.P189 :=
  .inr ⟨19037, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise189, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_189 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_189 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1828.ffi)
def PRE_first_tail_x15_r0_body.khinv189 : PTrie Nat := Stage.setAll PTrie.nil [(21935, 21933), (21936, 21934), (21938, 21935), (21937, 21936)]
def PRE_first_tail_x15_r0_body.kninv189 : PTrie Nat := Stage.setAll PTrie.nil [(19031, 19031), (19032, 19032), (19033, 19033), (19034, 19034), (19035, 19035), (19036, 19036)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS189 : List Nat := [21933, 21934, 21935, 21936, 21937, 21938]
def PRE_first_tail_x15_r0_body.cnS189 : List Nat := List.range' 19031 6
def PRE_first_tail_x15_r0_body.ciS189 : List Nat := [] ++ List.range' 19031 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0189 : PRE_first_tail_x15_r0_body.kd189.nh0 = PRE_first_tail_x15_r0_body.cx0_189.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1189 : PRE_first_tail_x15_r0_body.kd189.nh1 = PRE_first_tail_x15_r0_body.cx1_189.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0189 : PRE_first_tail_x15_r0_body.kd189.nn0 = PRE_first_tail_x15_r0_body.cx0_189.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1189 : PRE_first_tail_x15_r0_body.kd189.nn1 = PRE_first_tail_x15_r0_body.cx1_189.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo189 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P189.lo && Nat.ble PRE_first_tail_x15_r0_body.P189.lo PRE_first_tail_x15_r0_body.cx0_189.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P189.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P189.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt189 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_189.mlx.next PRE_first_tail_x15_r0_body.cx1_189.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_189.mlx.nnext PRE_first_tail_x15_r0_body.cx1_189.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband189 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P189.NL && Nat.ble PRE_first_tail_x15_r0_body.P189.NL PRE_first_tail_x15_r0_body.P189.N0 && Nat.ble PRE_first_tail_x15_r0_body.P189.N0 PRE_first_tail_x15_r0_body.cx0_189.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow189 : PRE_first_tail_x15_r0_body.kd189.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren189 : checkRenG PRE_first_tail_x15_r0_body.kd189.hnd PRE_first_tail_x15_r0_body.khinv189 (phB PRE_first_tail_x15_r0_body.cx0_189.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband189 : PRE_first_tail_x15_r0_body.kd189.checkBand PRE_first_tail_x15_r0_body.P189.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos189 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd189.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren189 : checkRenG PRE_first_tail_x15_r0_body.kd189.node PRE_first_tail_x15_r0_body.kninv189 (pnB PRE_first_tail_x15_r0_body.cx0_189.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow189 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd189.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P189.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd189.nodeF j) PRE_first_tail_x15_r0_body.cx1_189.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a189 : PRE_first_tail_x15_r0_body.cx0_189.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b189 : PRE_first_tail_x15_r0_body.cx0_189.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1189 : PRE_first_tail_x15_r0_body.cx1_189.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend189 : PRE_first_tail_x15_r0_body.cx1_189.mlx.pending = PRE_first_tail_x15_r0_body.cx0_189.mlx.pending.map PRE_first_tail_x15_r0_body.kappa189.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh189 : PRE_first_tail_x15_r0_body.cx1_189.mlx.errh = PRE_first_tail_x15_r0_body.cx0_189.mlx.errh.map PRE_first_tail_x15_r0_body.kappa189.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles189 : PRE_first_tail_x15_r0_body.cx1_189.mlx.files = PRE_first_tail_x15_r0_body.cx0_189.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch189 : PRE_first_tail_x15_r0_body.cx1_189.mlx.arch = PRE_first_tail_x15_r0_body.cx0_189.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes189 : PRE_first_tail_x15_r0_body.cx1_189.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_189.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired189 : PRE_first_tail_x15_r0_body.cx1_189.mlx.wired = PRE_first_tail_x15_r0_body.cx0_189.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost189 : PRE_first_tail_x15_r0_body.cx1_189.host = PRE_first_tail_x15_r0_body.cx0_189.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd189`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0189 : PRE_first_tail_x15_r0_body.kd189.n0 = 2823783
kernel_rfl PRE_first_tail_x15_r0_body.ckn1189 : PRE_first_tail_x15_r0_body.kd189.n1 = 2824133
kernel_rfl PRE_first_tail_x15_r0_body.ckheap189 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd189.heap).all (fun x => Nat.ble 2823768 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl189 : (List.range 15).all (fun j => decide (PRE_first_tail_x15_r0_body.kd189.heap.get (2823768 + j) = nth? PRE_first_tail_x15_r0_body.pl189 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja189 : Nat.ble 2823768 2823768 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn189 : Nat.ble 8169 8169 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD189 : Nat.ble 2823768 PRE_first_tail_x15_r0_body.kd189.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn189 : Nat.ble 21933 PRE_first_tail_x15_r0_body.kd189.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn189 : Nat.ble 19031 PRE_first_tail_x15_r0_body.kd189.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb189 : Nat.ble 21933 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap189 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd189.heap).all (Nat.ble (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd189 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd189.hnd).all (Nat.ble (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode189 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd189.node).all (Nat.ble (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix189 : Conv.FixOld (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa189 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja189) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn189) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD189) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn189) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn189) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb189) PRE_first_tail_x15_r0_body.fheap189 PRE_first_tail_x15_r0_body.fhnd189 PRE_first_tail_x15_r0_body.fnode189
kernel_rfl PRE_first_tail_x15_r0_body.fcxn189 : (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn189 : (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0189 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_189.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_189.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk189 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd189.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A189 : PRE_first_tail_x15_r0_body.cx1_189.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS189.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_189.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O189 : PRE_first_tail_x15_r0_body.cx1_189.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS189.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_189.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N189 : PRE_first_tail_x15_r0_body.cx1_189.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS189.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_189.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I189 : PRE_first_tail_x15_r0_body.cx1_189.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS189.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_189.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd189 : (PRE_first_tail_x15_r0_body.clo189 ++ PRE_first_tail_x15_r0_body.cln189 ++ PRE_first_tail_x15_r0_body.cli189 ++ PRE_first_tail_x15_r0_body.cwS189 ++ PRE_first_tail_x15_r0_body.cnS189 ++ PRE_first_tail_x15_r0_body.ciS189).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW189 : PRE_first_tail_x15_r0_body.cwS189.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo189.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI189 : PRE_first_tail_x15_r0_body.ciS189.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli189.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN189 : PRE_first_tail_x15_r0_body.cnS189.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF189 : PRE_first_tail_x15_r0_body.cln189.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh189 : PRE_first_tail_x15_r0_body.clo189.all (handleOK PRE_first_tail_x15_r0_body.kappa189 PRE_first_tail_x15_r0_body.P189.lo PRE_first_tail_x15_r0_body.cx0_189.mlx PRE_first_tail_x15_r0_body.cx1_189.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo189 : PRE_first_tail_x15_r0_body.clo189.map (fun h => PRE_first_tail_x15_r0_body.cx1_189.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa189.handle h)) = PRE_first_tail_x15_r0_body.clo189.map (fun h => (PRE_first_tail_x15_r0_body.cx0_189.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa189.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok189 : PRE_first_tail_x15_r0_body.clo189.all (objOK PRE_first_tail_x15_r0_body.kappa189 PRE_first_tail_x15_r0_body.P189.NL PRE_first_tail_x15_r0_body.cx0_189.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd189 : PRE_first_tail_x15_r0_body.cln189.all (nodeOKF PRE_first_tail_x15_r0_body.kappa189 PRE_first_tail_x15_r0_body.P189 PRE_first_tail_x15_r0_body.cx0_189.mlx PRE_first_tail_x15_r0_body.cx1_189.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp189 : ((PRE_first_tail_x15_r0_body.cln189.filter (fullB PRE_first_tail_x15_r0_body.P189))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_189.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa189.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln189.filter (fullB PRE_first_tail_x15_r0_body.P189))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_189.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa189.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI189 : incrB PRE_first_tail_x15_r0_body.kd189.nodeF (List.range' 19031 6) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK189 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd189.node).all (fun k => Nat.ble 19031 k && Nat.blt k 19037) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL189 : (PRE_first_tail_x15_r0_body.cln189.filter (Nat.ble PRE_first_tail_x15_r0_body.P189.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd189.nodeF i) && (Nat.blt i 19037 || Nat.ble PRE_first_tail_x15_r0_body.kd189.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord189 : (PRE_first_tail_x15_r0_body.cln189.filter (Nat.ble PRE_first_tail_x15_r0_body.P189.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd189.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd189.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd189.nodeF j) (PRE_first_tail_x15_r0_body.kd189.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow189 PRE_first_tail_x15_r0_body.cnn1189 PRE_first_tail_x15_r0_body.fnordI189 PRE_first_tail_x15_r0_body.fnordK189 PRE_first_tail_x15_r0_body.fnordL189
kernel_rfl PRE_first_tail_x15_r0_body.fi189 : PRE_first_tail_x15_r0_body.cli189.all (pnB PRE_first_tail_x15_r0_body.cx0_189.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii189 : PRE_first_tail_x15_r0_body.cli189.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_189.mlx.items.get (PRE_first_tail_x15_r0_body.kappa189.node k) = (PRE_first_tail_x15_r0_body.cx0_189.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa189.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot189 (clean : Conv.NClean (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P189.NL) (cl : SSt (· < 8178) PRE_first_tail_x15_r0_body.cx0_189.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P189 8178 PRE_first_tail_x15_r0_body.kappa189 PRE_first_tail_x15_r0_body.kd189 PRE_first_tail_x15_r0_body.khinv189 PRE_first_tail_x15_r0_body.kninv189 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx PRE_first_tail_x15_r0_body.cx0_189.mlx PRE_first_tail_x15_r0_body.cx1_189.mlx (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo189 PRE_first_tail_x15_r0_body.cln189 PRE_first_tail_x15_r0_body.cli189 PRE_first_tail_x15_r0_body.cwS189 PRE_first_tail_x15_r0_body.cnS189 PRE_first_tail_x15_r0_body.ciS189 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0189, PRE_first_tail_x15_r0_body.cnh1189, PRE_first_tail_x15_r0_body.cnn0189, PRE_first_tail_x15_r0_body.cnn1189, PRE_first_tail_x15_r0_body.cplo189, PRE_first_tail_x15_r0_body.ccnt189, PRE_first_tail_x15_r0_body.cnband189, PRE_first_tail_x15_r0_body.chbelow189, PRE_first_tail_x15_r0_body.chren189, PRE_first_tail_x15_r0_body.cband189, PRE_first_tail_x15_r0_body.cnh1pos189, PRE_first_tail_x15_r0_body.cnren189, PRE_first_tail_x15_r0_body.cnlow189, PRE_first_tail_x15_r0_body.cabs0a189, PRE_first_tail_x15_r0_body.cabs0b189, PRE_first_tail_x15_r0_body.ctok1189, PRE_first_tail_x15_r0_body.cpend189, PRE_first_tail_x15_r0_body.cerrh189, PRE_first_tail_x15_r0_body.cfiles189, PRE_first_tail_x15_r0_body.carch189, PRE_first_tail_x15_r0_body.csizes189, PRE_first_tail_x15_r0_body.cwired189, PRE_first_tail_x15_r0_body.cfix189, clean, PRE_first_tail_x15_r0_body.fcxn189, PRE_first_tail_x15_r0_body.fcnn189, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0189, PRE_first_tail_x15_r0_body.fnk189, PRE_first_tail_x15_r0_body.ckA189, PRE_first_tail_x15_r0_body.cobjsK189, PRE_first_tail_x15_r0_body.cnodesK189, PRE_first_tail_x15_r0_body.citemsK189, PRE_first_tail_x15_r0_body.f1A189, PRE_first_tail_x15_r0_body.f1O189, PRE_first_tail_x15_r0_body.f1N189, PRE_first_tail_x15_r0_body.f1I189, PRE_first_tail_x15_r0_body.fbd189, PRE_first_tail_x15_r0_body.fincW189, PRE_first_tail_x15_r0_body.fincI189, PRE_first_tail_x15_r0_body.fincN189, PRE_first_tail_x15_r0_body.flnF189, PRE_first_tail_x15_r0_body.fh189, PRE_first_tail_x15_r0_body.fo189, PRE_first_tail_x15_r0_body.fok189, PRE_first_tail_x15_r0_body.fnd189, PRE_first_tail_x15_r0_body.fp189, PRE_first_tail_x15_r0_body.fnord189, PRE_first_tail_x15_r0_body.fi189, PRE_first_tail_x15_r0_body.fii189⟩
theorem PRE_first_tail_x15_r0_body.cnshift189 (clean : Conv.NClean (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P189.NL) (cl : SSt (· < 8178) PRE_first_tail_x15_r0_body.cx0_189.mlx) : NShift PRE_first_tail_x15_r0_body.P189 8178 PRE_first_tail_x15_r0_body.kappa189 PRE_first_tail_x15_r0_body.cx0_189 PRE_first_tail_x15_r0_body.cx1_189 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot189 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost189 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0189 PRE_first_tail_x15_r0_body.ckn1189 PRE_first_tail_x15_r0_body.ckheap189 PRE_first_tail_x15_r0_body.ckpl189)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_189 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1827.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_189 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1827.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_189 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1827.ffi) = some PRE_first_tail_x15_r0_body.fxC_189
kernel_rfl PRE_first_tail_x15_r0_body.okrC_189 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1827.ffi) = some PRE_first_tail_x15_r0_body.krC_189
noncomputable def PRE_first_tail_x15_r0_body.fx0_189 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1829.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_189 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1829.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_189 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1829.ffi) = some PRE_first_tail_x15_r0_body.fx0_189
kernel_rfl PRE_first_tail_x15_r0_body.okr0_189 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1829.ffi) = some PRE_first_tail_x15_r0_body.kr0_189
noncomputable def PRE_first_tail_x15_r0_body.fx1_189 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1828.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_189 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1828.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_189 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1828.ffi) = some PRE_first_tail_x15_r0_body.fx1_189
kernel_rfl PRE_first_tail_x15_r0_body.okr1_189 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1828.ffi) = some PRE_first_tail_x15_r0_body.kr1_189
kernel_rfl PRE_first_tail_x15_r0_body.ff0189 : PRE_first_tail_x15_r0_body.fx0_189 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_189 (PRE_first_tail_x15_r0_body.clo189.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_189.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1189 : PRE_first_tail_x15_r0_body.fx1_189 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_189 (PRE_first_tail_x15_r0_body.cwS189.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_189.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck189 : freedLB PRE_first_tail_x15_r0_body.kappa189 PRE_first_tail_x15_r0_body.cx0_189.mlx PRE_first_tail_x15_r0_body.fx0_189 PRE_first_tail_x15_r0_body.fx1_189 PRE_first_tail_x15_r0_body.clo189 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0189 : PRE_first_tail_x15_r0_body.kr0_189.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_189.flags (PRE_first_tail_x15_r0_body.clo189.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_189.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0189 : PRE_first_tail_x15_r0_body.kr0_189.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_189.targs (PRE_first_tail_x15_r0_body.clo189.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_189.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1189 : PRE_first_tail_x15_r0_body.kr1_189.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_189.flags (PRE_first_tail_x15_r0_body.cwS189.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_189.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1189 : PRE_first_tail_x15_r0_body.kr1_189.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_189.targs (PRE_first_tail_x15_r0_body.cwS189.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_189.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck189 : krecLB PRE_first_tail_x15_r0_body.kappa189 8178 PRE_first_tail_x15_r0_body.cx0_189.mlx PRE_first_tail_x15_r0_body.kr0_189 PRE_first_tail_x15_r0_body.kr1_189 PRE_first_tail_x15_r0_body.clo189 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn189 : Nat.ble 8169 8178 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge189 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1828.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1829.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR189 : pendRegB PRE_first_tail_x15_r0_body.kappa189 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe189 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1828.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift189 (clean : Conv.NClean (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P189.NL) (cl : SSt (· < 8178) PRE_first_tail_x15_r0_body.cx0_189.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_189.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_189.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_189.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_189.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P189 8178 PRE_first_tail_x15_r0_body.kappa189 PRE_first_tail_x15_r0_body.s1829.ffi PRE_first_tail_x15_r0_body.s1828.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift189 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue189, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp189 t ht),
    PRE_first_tail_x15_r0_body.cbridge189,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1829.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1828.ffi) (PRE_first_tail_x15_r0_body.cfoot189 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_189 PRE_first_tail_x15_r0_body.ofx1_189 hobjC PRE_first_tail_x15_r0_body.ff0189 PRE_first_tail_x15_r0_body.ff1189 PRE_first_tail_x15_r0_body.ffck189,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1829.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1828.ffi) (PRE_first_tail_x15_r0_body.cfoot189 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_189 PRE_first_tail_x15_r0_body.okr1_189 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn189) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0189 PRE_first_tail_x15_r0_body.fkt0189 PRE_first_tail_x15_r0_body.fkf1189 PRE_first_tail_x15_r0_body.fkt1189 PRE_first_tail_x15_r0_body.fkck189,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0189 PRE_first_tail_x15_r0_body.cnh1189 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe189) PRE_first_tail_x15_r0_body.cpendR189⟩

end Host.Load.Run.Tpl

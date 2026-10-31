import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl143
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 143 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc143 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P143 : LoadP := PRE_first_tail_x15_r0_body.Pc143.raise 18103
kernel_rfl PRE_first_tail_x15_r0_body.craise143 : Nat.ble PRE_first_tail_x15_r0_body.Pc143.N0 18103 = true
theorem PRE_first_tail_x15_r0_body.raised143 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc143 PRE_first_tail_x15_r0_body.P143 :=
  .inr ⟨18103, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise143, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_143 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_143 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1259.ffi)
def PRE_first_tail_x15_r0_body.khinv143 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv143 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS143 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS143 : List Nat := List.range' 18103 0
def PRE_first_tail_x15_r0_body.ciS143 : List Nat := [] ++ List.range' 18103 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0143 : PRE_first_tail_x15_r0_body.kd143.nh0 = PRE_first_tail_x15_r0_body.cx0_143.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1143 : PRE_first_tail_x15_r0_body.kd143.nh1 = PRE_first_tail_x15_r0_body.cx1_143.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0143 : PRE_first_tail_x15_r0_body.kd143.nn0 = PRE_first_tail_x15_r0_body.cx0_143.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1143 : PRE_first_tail_x15_r0_body.kd143.nn1 = PRE_first_tail_x15_r0_body.cx1_143.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo143 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P143.lo && Nat.ble PRE_first_tail_x15_r0_body.P143.lo PRE_first_tail_x15_r0_body.cx0_143.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P143.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P143.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt143 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_143.mlx.next PRE_first_tail_x15_r0_body.cx1_143.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_143.mlx.nnext PRE_first_tail_x15_r0_body.cx1_143.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband143 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P143.NL && Nat.ble PRE_first_tail_x15_r0_body.P143.NL PRE_first_tail_x15_r0_body.P143.N0 && Nat.ble PRE_first_tail_x15_r0_body.P143.N0 PRE_first_tail_x15_r0_body.cx0_143.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow143 : PRE_first_tail_x15_r0_body.kd143.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren143 : checkRenG PRE_first_tail_x15_r0_body.kd143.hnd PRE_first_tail_x15_r0_body.khinv143 (phB PRE_first_tail_x15_r0_body.cx0_143.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband143 : PRE_first_tail_x15_r0_body.kd143.checkBand PRE_first_tail_x15_r0_body.P143.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos143 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd143.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren143 : checkRenG PRE_first_tail_x15_r0_body.kd143.node PRE_first_tail_x15_r0_body.kninv143 (pnB PRE_first_tail_x15_r0_body.cx0_143.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow143 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd143.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P143.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd143.nodeF j) PRE_first_tail_x15_r0_body.cx1_143.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a143 : PRE_first_tail_x15_r0_body.cx0_143.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b143 : PRE_first_tail_x15_r0_body.cx0_143.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1143 : PRE_first_tail_x15_r0_body.cx1_143.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend143 : PRE_first_tail_x15_r0_body.cx1_143.mlx.pending = PRE_first_tail_x15_r0_body.cx0_143.mlx.pending.map PRE_first_tail_x15_r0_body.kappa143.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh143 : PRE_first_tail_x15_r0_body.cx1_143.mlx.errh = PRE_first_tail_x15_r0_body.cx0_143.mlx.errh.map PRE_first_tail_x15_r0_body.kappa143.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles143 : PRE_first_tail_x15_r0_body.cx1_143.mlx.files = PRE_first_tail_x15_r0_body.cx0_143.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch143 : PRE_first_tail_x15_r0_body.cx1_143.mlx.arch = PRE_first_tail_x15_r0_body.cx0_143.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes143 : PRE_first_tail_x15_r0_body.cx1_143.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_143.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired143 : PRE_first_tail_x15_r0_body.cx1_143.mlx.wired = PRE_first_tail_x15_r0_body.cx0_143.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost143 : PRE_first_tail_x15_r0_body.cx1_143.host = PRE_first_tail_x15_r0_body.cx0_143.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd143`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0143 : PRE_first_tail_x15_r0_body.kd143.n0 = 2786962
kernel_rfl PRE_first_tail_x15_r0_body.ckn1143 : PRE_first_tail_x15_r0_body.kd143.n1 = 2786981
kernel_rfl PRE_first_tail_x15_r0_body.ckheap143 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd143.heap).all (fun x => Nat.ble 2786961 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl143 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd143.heap.get (2786961 + j) = nth? PRE_first_tail_x15_r0_body.pl143 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja143 : Nat.ble 2786961 2786961 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn143 : Nat.ble 6166 6166 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD143 : Nat.ble 2786961 PRE_first_tail_x15_r0_body.kd143.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn143 : Nat.ble 21013 PRE_first_tail_x15_r0_body.kd143.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn143 : Nat.ble 18103 PRE_first_tail_x15_r0_body.kd143.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb143 : Nat.ble 21013 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap143 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd143.heap).all (Nat.ble (⟨21013, 18103, 2786961, 6166⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd143 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd143.hnd).all (Nat.ble (⟨21013, 18103, 2786961, 6166⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode143 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd143.node).all (Nat.ble (⟨21013, 18103, 2786961, 6166⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix143 : Conv.FixOld (⟨21013, 18103, 2786961, 6166⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa143 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja143) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn143) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD143) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn143) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn143) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb143) PRE_first_tail_x15_r0_body.fheap143 PRE_first_tail_x15_r0_body.fhnd143 PRE_first_tail_x15_r0_body.fnode143
kernel_rfl PRE_first_tail_x15_r0_body.fcxn143 : (⟨21013, 18103, 2786961, 6166⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn143 : (⟨21013, 18103, 2786961, 6166⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0143 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_143.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_143.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk143 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd143.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A143 : PRE_first_tail_x15_r0_body.cx1_143.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS143.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_143.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O143 : PRE_first_tail_x15_r0_body.cx1_143.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS143.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_143.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N143 : PRE_first_tail_x15_r0_body.cx1_143.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS143.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_143.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I143 : PRE_first_tail_x15_r0_body.cx1_143.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS143.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_143.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd143 : (PRE_first_tail_x15_r0_body.clo143 ++ PRE_first_tail_x15_r0_body.cln143 ++ PRE_first_tail_x15_r0_body.cli143 ++ PRE_first_tail_x15_r0_body.cwS143 ++ PRE_first_tail_x15_r0_body.cnS143 ++ PRE_first_tail_x15_r0_body.ciS143).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW143 : PRE_first_tail_x15_r0_body.cwS143.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo143.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI143 : PRE_first_tail_x15_r0_body.ciS143.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli143.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN143 : PRE_first_tail_x15_r0_body.cnS143.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF143 : PRE_first_tail_x15_r0_body.cln143.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh143 : PRE_first_tail_x15_r0_body.clo143.all (handleOK PRE_first_tail_x15_r0_body.kappa143 PRE_first_tail_x15_r0_body.P143.lo PRE_first_tail_x15_r0_body.cx0_143.mlx PRE_first_tail_x15_r0_body.cx1_143.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo143 : PRE_first_tail_x15_r0_body.clo143.map (fun h => PRE_first_tail_x15_r0_body.cx1_143.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa143.handle h)) = PRE_first_tail_x15_r0_body.clo143.map (fun h => (PRE_first_tail_x15_r0_body.cx0_143.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa143.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok143 : PRE_first_tail_x15_r0_body.clo143.all (objOK PRE_first_tail_x15_r0_body.kappa143 PRE_first_tail_x15_r0_body.P143.NL PRE_first_tail_x15_r0_body.cx0_143.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd143 : PRE_first_tail_x15_r0_body.cln143.all (nodeOKF PRE_first_tail_x15_r0_body.kappa143 PRE_first_tail_x15_r0_body.P143 PRE_first_tail_x15_r0_body.cx0_143.mlx PRE_first_tail_x15_r0_body.cx1_143.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp143 : ((PRE_first_tail_x15_r0_body.cln143.filter (fullB PRE_first_tail_x15_r0_body.P143))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_143.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa143.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln143.filter (fullB PRE_first_tail_x15_r0_body.P143))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_143.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa143.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI143 : incrB PRE_first_tail_x15_r0_body.kd143.nodeF (List.range' 18103 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK143 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd143.node).all (fun k => Nat.ble 18103 k && Nat.blt k 18103) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL143 : (PRE_first_tail_x15_r0_body.cln143.filter (Nat.ble PRE_first_tail_x15_r0_body.P143.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd143.nodeF i) && (Nat.blt i 18103 || Nat.ble PRE_first_tail_x15_r0_body.kd143.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord143 : (PRE_first_tail_x15_r0_body.cln143.filter (Nat.ble PRE_first_tail_x15_r0_body.P143.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd143.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd143.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd143.nodeF j) (PRE_first_tail_x15_r0_body.kd143.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow143 PRE_first_tail_x15_r0_body.cnn1143 PRE_first_tail_x15_r0_body.fnordI143 PRE_first_tail_x15_r0_body.fnordK143 PRE_first_tail_x15_r0_body.fnordL143
kernel_rfl PRE_first_tail_x15_r0_body.fi143 : PRE_first_tail_x15_r0_body.cli143.all (pnB PRE_first_tail_x15_r0_body.cx0_143.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii143 : PRE_first_tail_x15_r0_body.cli143.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_143.mlx.items.get (PRE_first_tail_x15_r0_body.kappa143.node k) = (PRE_first_tail_x15_r0_body.cx0_143.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa143.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot143 (clean : Conv.NClean (⟨21013, 18103, 2786961, 6166⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P143.NL) (cl : SSt (· < 6166) PRE_first_tail_x15_r0_body.cx0_143.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P143 6166 PRE_first_tail_x15_r0_body.kappa143 PRE_first_tail_x15_r0_body.kd143 PRE_first_tail_x15_r0_body.khinv143 PRE_first_tail_x15_r0_body.kninv143 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx PRE_first_tail_x15_r0_body.cx0_143.mlx PRE_first_tail_x15_r0_body.cx1_143.mlx (⟨21013, 18103, 2786961, 6166⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo143 PRE_first_tail_x15_r0_body.cln143 PRE_first_tail_x15_r0_body.cli143 PRE_first_tail_x15_r0_body.cwS143 PRE_first_tail_x15_r0_body.cnS143 PRE_first_tail_x15_r0_body.ciS143 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0143, PRE_first_tail_x15_r0_body.cnh1143, PRE_first_tail_x15_r0_body.cnn0143, PRE_first_tail_x15_r0_body.cnn1143, PRE_first_tail_x15_r0_body.cplo143, PRE_first_tail_x15_r0_body.ccnt143, PRE_first_tail_x15_r0_body.cnband143, PRE_first_tail_x15_r0_body.chbelow143, PRE_first_tail_x15_r0_body.chren143, PRE_first_tail_x15_r0_body.cband143, PRE_first_tail_x15_r0_body.cnh1pos143, PRE_first_tail_x15_r0_body.cnren143, PRE_first_tail_x15_r0_body.cnlow143, PRE_first_tail_x15_r0_body.cabs0a143, PRE_first_tail_x15_r0_body.cabs0b143, PRE_first_tail_x15_r0_body.ctok1143, PRE_first_tail_x15_r0_body.cpend143, PRE_first_tail_x15_r0_body.cerrh143, PRE_first_tail_x15_r0_body.cfiles143, PRE_first_tail_x15_r0_body.carch143, PRE_first_tail_x15_r0_body.csizes143, PRE_first_tail_x15_r0_body.cwired143, PRE_first_tail_x15_r0_body.cfix143, clean, PRE_first_tail_x15_r0_body.fcxn143, PRE_first_tail_x15_r0_body.fcnn143, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0143, PRE_first_tail_x15_r0_body.fnk143, PRE_first_tail_x15_r0_body.ckA143, PRE_first_tail_x15_r0_body.cobjsK143, PRE_first_tail_x15_r0_body.cnodesK143, PRE_first_tail_x15_r0_body.citemsK143, PRE_first_tail_x15_r0_body.f1A143, PRE_first_tail_x15_r0_body.f1O143, PRE_first_tail_x15_r0_body.f1N143, PRE_first_tail_x15_r0_body.f1I143, PRE_first_tail_x15_r0_body.fbd143, PRE_first_tail_x15_r0_body.fincW143, PRE_first_tail_x15_r0_body.fincI143, PRE_first_tail_x15_r0_body.fincN143, PRE_first_tail_x15_r0_body.flnF143, PRE_first_tail_x15_r0_body.fh143, PRE_first_tail_x15_r0_body.fo143, PRE_first_tail_x15_r0_body.fok143, PRE_first_tail_x15_r0_body.fnd143, PRE_first_tail_x15_r0_body.fp143, PRE_first_tail_x15_r0_body.fnord143, PRE_first_tail_x15_r0_body.fi143, PRE_first_tail_x15_r0_body.fii143⟩
theorem PRE_first_tail_x15_r0_body.cnshift143 (clean : Conv.NClean (⟨21013, 18103, 2786961, 6166⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P143.NL) (cl : SSt (· < 6166) PRE_first_tail_x15_r0_body.cx0_143.mlx) : NShift PRE_first_tail_x15_r0_body.P143 6166 PRE_first_tail_x15_r0_body.kappa143 PRE_first_tail_x15_r0_body.cx0_143 PRE_first_tail_x15_r0_body.cx1_143 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot143 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost143 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0143 PRE_first_tail_x15_r0_body.ckn1143 PRE_first_tail_x15_r0_body.ckheap143 PRE_first_tail_x15_r0_body.ckpl143)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_143 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1258.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_143 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1258.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_143 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1258.ffi) = some PRE_first_tail_x15_r0_body.fxC_143
kernel_rfl PRE_first_tail_x15_r0_body.okrC_143 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1258.ffi) = some PRE_first_tail_x15_r0_body.krC_143
noncomputable def PRE_first_tail_x15_r0_body.fx0_143 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1260.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_143 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1260.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_143 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1260.ffi) = some PRE_first_tail_x15_r0_body.fx0_143
kernel_rfl PRE_first_tail_x15_r0_body.okr0_143 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1260.ffi) = some PRE_first_tail_x15_r0_body.kr0_143
noncomputable def PRE_first_tail_x15_r0_body.fx1_143 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1259.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_143 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1259.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_143 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1259.ffi) = some PRE_first_tail_x15_r0_body.fx1_143
kernel_rfl PRE_first_tail_x15_r0_body.okr1_143 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1259.ffi) = some PRE_first_tail_x15_r0_body.kr1_143
kernel_rfl PRE_first_tail_x15_r0_body.ff0143 : PRE_first_tail_x15_r0_body.fx0_143 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_143 (PRE_first_tail_x15_r0_body.clo143.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_143.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1143 : PRE_first_tail_x15_r0_body.fx1_143 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_143 (PRE_first_tail_x15_r0_body.cwS143.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_143.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck143 : freedLB PRE_first_tail_x15_r0_body.kappa143 PRE_first_tail_x15_r0_body.cx0_143.mlx PRE_first_tail_x15_r0_body.fx0_143 PRE_first_tail_x15_r0_body.fx1_143 PRE_first_tail_x15_r0_body.clo143 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0143 : PRE_first_tail_x15_r0_body.kr0_143.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_143.flags (PRE_first_tail_x15_r0_body.clo143.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_143.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0143 : PRE_first_tail_x15_r0_body.kr0_143.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_143.targs (PRE_first_tail_x15_r0_body.clo143.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_143.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1143 : PRE_first_tail_x15_r0_body.kr1_143.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_143.flags (PRE_first_tail_x15_r0_body.cwS143.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_143.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1143 : PRE_first_tail_x15_r0_body.kr1_143.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_143.targs (PRE_first_tail_x15_r0_body.cwS143.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_143.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck143 : krecLB PRE_first_tail_x15_r0_body.kappa143 6166 PRE_first_tail_x15_r0_body.cx0_143.mlx PRE_first_tail_x15_r0_body.kr0_143 PRE_first_tail_x15_r0_body.kr1_143 PRE_first_tail_x15_r0_body.clo143 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn143 : Nat.ble 6166 6166 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge143 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1259.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1260.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR143 : pendRegB PRE_first_tail_x15_r0_body.kappa143 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe143 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1259.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift143 (clean : Conv.NClean (⟨21013, 18103, 2786961, 6166⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P143.NL) (cl : SSt (· < 6166) PRE_first_tail_x15_r0_body.cx0_143.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_143.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_143.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_143.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_143.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21013, 18103, 2786961, 6166⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P143 6166 PRE_first_tail_x15_r0_body.kappa143 PRE_first_tail_x15_r0_body.s1260.ffi PRE_first_tail_x15_r0_body.s1259.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift143 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue143, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp143 t ht),
    PRE_first_tail_x15_r0_body.cbridge143,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1260.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1259.ffi) (PRE_first_tail_x15_r0_body.cfoot143 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_143 PRE_first_tail_x15_r0_body.ofx1_143 hobjC PRE_first_tail_x15_r0_body.ff0143 PRE_first_tail_x15_r0_body.ff1143 PRE_first_tail_x15_r0_body.ffck143,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1260.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1259.ffi) (PRE_first_tail_x15_r0_body.cfoot143 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_143 PRE_first_tail_x15_r0_body.okr1_143 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn143) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0143 PRE_first_tail_x15_r0_body.fkt0143 PRE_first_tail_x15_r0_body.fkf1143 PRE_first_tail_x15_r0_body.fkt1143 PRE_first_tail_x15_r0_body.fkck143,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0143 PRE_first_tail_x15_r0_body.cnh1143 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe143) PRE_first_tail_x15_r0_body.cpendR143⟩

end Host.Load.Run.Tpl

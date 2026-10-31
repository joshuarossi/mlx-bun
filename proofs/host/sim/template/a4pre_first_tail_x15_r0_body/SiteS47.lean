import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl47
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 47 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc47 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P47 : LoadP := PRE_first_tail_x15_r0_body.Pc47.raise 16207
kernel_rfl PRE_first_tail_x15_r0_body.craise47 : Nat.ble PRE_first_tail_x15_r0_body.Pc47.N0 16207 = true
theorem PRE_first_tail_x15_r0_body.raised47 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc47 PRE_first_tail_x15_r0_body.P47 :=
  .inr ⟨16207, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise47, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_47 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s420.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_47 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s419.ffi)
def PRE_first_tail_x15_r0_body.khinv47 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv47 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS47 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS47 : List Nat := List.range' 16207 0
def PRE_first_tail_x15_r0_body.ciS47 : List Nat := [] ++ List.range' 16207 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh047 : PRE_first_tail_x15_r0_body.kd47.nh0 = PRE_first_tail_x15_r0_body.cx0_47.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh147 : PRE_first_tail_x15_r0_body.kd47.nh1 = PRE_first_tail_x15_r0_body.cx1_47.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn047 : PRE_first_tail_x15_r0_body.kd47.nn0 = PRE_first_tail_x15_r0_body.cx0_47.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn147 : PRE_first_tail_x15_r0_body.kd47.nn1 = PRE_first_tail_x15_r0_body.cx1_47.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo47 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P47.lo && Nat.ble PRE_first_tail_x15_r0_body.P47.lo PRE_first_tail_x15_r0_body.cx0_47.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P47.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P47.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt47 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_47.mlx.next PRE_first_tail_x15_r0_body.cx1_47.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_47.mlx.nnext PRE_first_tail_x15_r0_body.cx1_47.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband47 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P47.NL && Nat.ble PRE_first_tail_x15_r0_body.P47.NL PRE_first_tail_x15_r0_body.P47.N0 && Nat.ble PRE_first_tail_x15_r0_body.P47.N0 PRE_first_tail_x15_r0_body.cx0_47.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow47 : PRE_first_tail_x15_r0_body.kd47.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren47 : checkRenG PRE_first_tail_x15_r0_body.kd47.hnd PRE_first_tail_x15_r0_body.khinv47 (phB PRE_first_tail_x15_r0_body.cx0_47.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband47 : PRE_first_tail_x15_r0_body.kd47.checkBand PRE_first_tail_x15_r0_body.P47.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos47 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd47.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren47 : checkRenG PRE_first_tail_x15_r0_body.kd47.node PRE_first_tail_x15_r0_body.kninv47 (pnB PRE_first_tail_x15_r0_body.cx0_47.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow47 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd47.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P47.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd47.nodeF j) PRE_first_tail_x15_r0_body.cx1_47.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a47 : PRE_first_tail_x15_r0_body.cx0_47.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b47 : PRE_first_tail_x15_r0_body.cx0_47.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok147 : PRE_first_tail_x15_r0_body.cx1_47.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend47 : PRE_first_tail_x15_r0_body.cx1_47.mlx.pending = PRE_first_tail_x15_r0_body.cx0_47.mlx.pending.map PRE_first_tail_x15_r0_body.kappa47.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh47 : PRE_first_tail_x15_r0_body.cx1_47.mlx.errh = PRE_first_tail_x15_r0_body.cx0_47.mlx.errh.map PRE_first_tail_x15_r0_body.kappa47.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles47 : PRE_first_tail_x15_r0_body.cx1_47.mlx.files = PRE_first_tail_x15_r0_body.cx0_47.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch47 : PRE_first_tail_x15_r0_body.cx1_47.mlx.arch = PRE_first_tail_x15_r0_body.cx0_47.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes47 : PRE_first_tail_x15_r0_body.cx1_47.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_47.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired47 : PRE_first_tail_x15_r0_body.cx1_47.mlx.wired = PRE_first_tail_x15_r0_body.cx0_47.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost47 : PRE_first_tail_x15_r0_body.cx1_47.host = PRE_first_tail_x15_r0_body.cx0_47.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd47`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn047 : PRE_first_tail_x15_r0_body.kd47.n0 = 2711626
kernel_rfl PRE_first_tail_x15_r0_body.ckn147 : PRE_first_tail_x15_r0_body.kd47.n1 = 2711645
kernel_rfl PRE_first_tail_x15_r0_body.ckheap47 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd47.heap).all (fun x => Nat.ble 2711625 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl47 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd47.heap.get (2711625 + j) = nth? PRE_first_tail_x15_r0_body.pl47 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja47 : Nat.ble 2711625 2711625 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn47 : Nat.ble 2062 2062 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD47 : Nat.ble 2711625 PRE_first_tail_x15_r0_body.kd47.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn47 : Nat.ble 19125 PRE_first_tail_x15_r0_body.kd47.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn47 : Nat.ble 16207 PRE_first_tail_x15_r0_body.kd47.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb47 : Nat.ble 19125 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap47 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd47.heap).all (Nat.ble (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd47 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd47.hnd).all (Nat.ble (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode47 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd47.node).all (Nat.ble (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix47 : Conv.FixOld (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa47 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja47) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn47) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD47) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn47) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn47) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb47) PRE_first_tail_x15_r0_body.fheap47 PRE_first_tail_x15_r0_body.fhnd47 PRE_first_tail_x15_r0_body.fnode47
kernel_rfl PRE_first_tail_x15_r0_body.fcxn47 : (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn47 : (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle047 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_47.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_47.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk47 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd47.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A47 : PRE_first_tail_x15_r0_body.cx1_47.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS47.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_47.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O47 : PRE_first_tail_x15_r0_body.cx1_47.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS47.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_47.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N47 : PRE_first_tail_x15_r0_body.cx1_47.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS47.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_47.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I47 : PRE_first_tail_x15_r0_body.cx1_47.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS47.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_47.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd47 : (PRE_first_tail_x15_r0_body.clo47 ++ PRE_first_tail_x15_r0_body.cln47 ++ PRE_first_tail_x15_r0_body.cli47 ++ PRE_first_tail_x15_r0_body.cwS47 ++ PRE_first_tail_x15_r0_body.cnS47 ++ PRE_first_tail_x15_r0_body.ciS47).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW47 : PRE_first_tail_x15_r0_body.cwS47.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo47.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI47 : PRE_first_tail_x15_r0_body.ciS47.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli47.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN47 : PRE_first_tail_x15_r0_body.cnS47.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF47 : PRE_first_tail_x15_r0_body.cln47.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh47 : PRE_first_tail_x15_r0_body.clo47.all (handleOK PRE_first_tail_x15_r0_body.kappa47 PRE_first_tail_x15_r0_body.P47.lo PRE_first_tail_x15_r0_body.cx0_47.mlx PRE_first_tail_x15_r0_body.cx1_47.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo47 : PRE_first_tail_x15_r0_body.clo47.map (fun h => PRE_first_tail_x15_r0_body.cx1_47.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa47.handle h)) = PRE_first_tail_x15_r0_body.clo47.map (fun h => (PRE_first_tail_x15_r0_body.cx0_47.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa47.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok47 : PRE_first_tail_x15_r0_body.clo47.all (objOK PRE_first_tail_x15_r0_body.kappa47 PRE_first_tail_x15_r0_body.P47.NL PRE_first_tail_x15_r0_body.cx0_47.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd47 : PRE_first_tail_x15_r0_body.cln47.all (nodeOKF PRE_first_tail_x15_r0_body.kappa47 PRE_first_tail_x15_r0_body.P47 PRE_first_tail_x15_r0_body.cx0_47.mlx PRE_first_tail_x15_r0_body.cx1_47.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp47 : ((PRE_first_tail_x15_r0_body.cln47.filter (fullB PRE_first_tail_x15_r0_body.P47))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_47.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa47.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln47.filter (fullB PRE_first_tail_x15_r0_body.P47))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_47.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa47.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI47 : incrB PRE_first_tail_x15_r0_body.kd47.nodeF (List.range' 16207 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK47 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd47.node).all (fun k => Nat.ble 16207 k && Nat.blt k 16207) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL47 : (PRE_first_tail_x15_r0_body.cln47.filter (Nat.ble PRE_first_tail_x15_r0_body.P47.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd47.nodeF i) && (Nat.blt i 16207 || Nat.ble PRE_first_tail_x15_r0_body.kd47.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord47 : (PRE_first_tail_x15_r0_body.cln47.filter (Nat.ble PRE_first_tail_x15_r0_body.P47.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd47.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd47.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd47.nodeF j) (PRE_first_tail_x15_r0_body.kd47.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow47 PRE_first_tail_x15_r0_body.cnn147 PRE_first_tail_x15_r0_body.fnordI47 PRE_first_tail_x15_r0_body.fnordK47 PRE_first_tail_x15_r0_body.fnordL47
kernel_rfl PRE_first_tail_x15_r0_body.fi47 : PRE_first_tail_x15_r0_body.cli47.all (pnB PRE_first_tail_x15_r0_body.cx0_47.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii47 : PRE_first_tail_x15_r0_body.cli47.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_47.mlx.items.get (PRE_first_tail_x15_r0_body.kappa47.node k) = (PRE_first_tail_x15_r0_body.cx0_47.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa47.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot47 (clean : Conv.NClean (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P47.NL) (cl : SSt (· < 2062) PRE_first_tail_x15_r0_body.cx0_47.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P47 2062 PRE_first_tail_x15_r0_body.kappa47 PRE_first_tail_x15_r0_body.kd47 PRE_first_tail_x15_r0_body.khinv47 PRE_first_tail_x15_r0_body.kninv47 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx PRE_first_tail_x15_r0_body.cx0_47.mlx PRE_first_tail_x15_r0_body.cx1_47.mlx (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo47 PRE_first_tail_x15_r0_body.cln47 PRE_first_tail_x15_r0_body.cli47 PRE_first_tail_x15_r0_body.cwS47 PRE_first_tail_x15_r0_body.cnS47 PRE_first_tail_x15_r0_body.ciS47 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh047, PRE_first_tail_x15_r0_body.cnh147, PRE_first_tail_x15_r0_body.cnn047, PRE_first_tail_x15_r0_body.cnn147, PRE_first_tail_x15_r0_body.cplo47, PRE_first_tail_x15_r0_body.ccnt47, PRE_first_tail_x15_r0_body.cnband47, PRE_first_tail_x15_r0_body.chbelow47, PRE_first_tail_x15_r0_body.chren47, PRE_first_tail_x15_r0_body.cband47, PRE_first_tail_x15_r0_body.cnh1pos47, PRE_first_tail_x15_r0_body.cnren47, PRE_first_tail_x15_r0_body.cnlow47, PRE_first_tail_x15_r0_body.cabs0a47, PRE_first_tail_x15_r0_body.cabs0b47, PRE_first_tail_x15_r0_body.ctok147, PRE_first_tail_x15_r0_body.cpend47, PRE_first_tail_x15_r0_body.cerrh47, PRE_first_tail_x15_r0_body.cfiles47, PRE_first_tail_x15_r0_body.carch47, PRE_first_tail_x15_r0_body.csizes47, PRE_first_tail_x15_r0_body.cwired47, PRE_first_tail_x15_r0_body.cfix47, clean, PRE_first_tail_x15_r0_body.fcxn47, PRE_first_tail_x15_r0_body.fcnn47, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle047, PRE_first_tail_x15_r0_body.fnk47, PRE_first_tail_x15_r0_body.ckA47, PRE_first_tail_x15_r0_body.cobjsK47, PRE_first_tail_x15_r0_body.cnodesK47, PRE_first_tail_x15_r0_body.citemsK47, PRE_first_tail_x15_r0_body.f1A47, PRE_first_tail_x15_r0_body.f1O47, PRE_first_tail_x15_r0_body.f1N47, PRE_first_tail_x15_r0_body.f1I47, PRE_first_tail_x15_r0_body.fbd47, PRE_first_tail_x15_r0_body.fincW47, PRE_first_tail_x15_r0_body.fincI47, PRE_first_tail_x15_r0_body.fincN47, PRE_first_tail_x15_r0_body.flnF47, PRE_first_tail_x15_r0_body.fh47, PRE_first_tail_x15_r0_body.fo47, PRE_first_tail_x15_r0_body.fok47, PRE_first_tail_x15_r0_body.fnd47, PRE_first_tail_x15_r0_body.fp47, PRE_first_tail_x15_r0_body.fnord47, PRE_first_tail_x15_r0_body.fi47, PRE_first_tail_x15_r0_body.fii47⟩
theorem PRE_first_tail_x15_r0_body.cnshift47 (clean : Conv.NClean (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P47.NL) (cl : SSt (· < 2062) PRE_first_tail_x15_r0_body.cx0_47.mlx) : NShift PRE_first_tail_x15_r0_body.P47 2062 PRE_first_tail_x15_r0_body.kappa47 PRE_first_tail_x15_r0_body.cx0_47 PRE_first_tail_x15_r0_body.cx1_47 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot47 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost47 (compact_a_eq PRE_first_tail_x15_r0_body.ckn047 PRE_first_tail_x15_r0_body.ckn147 PRE_first_tail_x15_r0_body.ckheap47 PRE_first_tail_x15_r0_body.ckpl47)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_47 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s418.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_47 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s418.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_47 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s418.ffi) = some PRE_first_tail_x15_r0_body.fxC_47
kernel_rfl PRE_first_tail_x15_r0_body.okrC_47 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s418.ffi) = some PRE_first_tail_x15_r0_body.krC_47
noncomputable def PRE_first_tail_x15_r0_body.fx0_47 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s420.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_47 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s420.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_47 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s420.ffi) = some PRE_first_tail_x15_r0_body.fx0_47
kernel_rfl PRE_first_tail_x15_r0_body.okr0_47 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s420.ffi) = some PRE_first_tail_x15_r0_body.kr0_47
noncomputable def PRE_first_tail_x15_r0_body.fx1_47 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s419.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_47 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s419.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_47 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s419.ffi) = some PRE_first_tail_x15_r0_body.fx1_47
kernel_rfl PRE_first_tail_x15_r0_body.okr1_47 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s419.ffi) = some PRE_first_tail_x15_r0_body.kr1_47
kernel_rfl PRE_first_tail_x15_r0_body.ff047 : PRE_first_tail_x15_r0_body.fx0_47 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_47 (PRE_first_tail_x15_r0_body.clo47.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_47.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff147 : PRE_first_tail_x15_r0_body.fx1_47 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_47 (PRE_first_tail_x15_r0_body.cwS47.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_47.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck47 : freedLB PRE_first_tail_x15_r0_body.kappa47 PRE_first_tail_x15_r0_body.cx0_47.mlx PRE_first_tail_x15_r0_body.fx0_47 PRE_first_tail_x15_r0_body.fx1_47 PRE_first_tail_x15_r0_body.clo47 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf047 : PRE_first_tail_x15_r0_body.kr0_47.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_47.flags (PRE_first_tail_x15_r0_body.clo47.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_47.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt047 : PRE_first_tail_x15_r0_body.kr0_47.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_47.targs (PRE_first_tail_x15_r0_body.clo47.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_47.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf147 : PRE_first_tail_x15_r0_body.kr1_47.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_47.flags (PRE_first_tail_x15_r0_body.cwS47.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_47.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt147 : PRE_first_tail_x15_r0_body.kr1_47.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_47.targs (PRE_first_tail_x15_r0_body.cwS47.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_47.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck47 : krecLB PRE_first_tail_x15_r0_body.kappa47 2062 PRE_first_tail_x15_r0_body.cx0_47.mlx PRE_first_tail_x15_r0_body.kr0_47 PRE_first_tail_x15_r0_body.kr1_47 PRE_first_tail_x15_r0_body.clo47 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn47 : Nat.ble 2062 2062 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge47 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s419.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s420.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR47 : pendRegB PRE_first_tail_x15_r0_body.kappa47 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s420.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe47 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s420.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s419.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift47 (clean : Conv.NClean (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P47.NL) (cl : SSt (· < 2062) PRE_first_tail_x15_r0_body.cx0_47.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_47.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_47.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_47.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_47.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P47 2062 PRE_first_tail_x15_r0_body.kappa47 PRE_first_tail_x15_r0_body.s420.ffi PRE_first_tail_x15_r0_body.s419.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift47 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue47, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp47 t ht),
    PRE_first_tail_x15_r0_body.cbridge47,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s420.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s419.ffi) (PRE_first_tail_x15_r0_body.cfoot47 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_47 PRE_first_tail_x15_r0_body.ofx1_47 hobjC PRE_first_tail_x15_r0_body.ff047 PRE_first_tail_x15_r0_body.ff147 PRE_first_tail_x15_r0_body.ffck47,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s420.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s419.ffi) (PRE_first_tail_x15_r0_body.cfoot47 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_47 PRE_first_tail_x15_r0_body.okr1_47 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn47) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf047 PRE_first_tail_x15_r0_body.fkt047 PRE_first_tail_x15_r0_body.fkf147 PRE_first_tail_x15_r0_body.fkt147 PRE_first_tail_x15_r0_body.fkck47,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh047 PRE_first_tail_x15_r0_body.cnh147 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe47) PRE_first_tail_x15_r0_body.cpendR47⟩

end Host.Load.Run.Tpl

import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl188
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 188 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc188 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P188 : LoadP := PRE_first_tail_x15_r0_body.Pc188.raise 19003
kernel_rfl PRE_first_tail_x15_r0_body.craise188 : Nat.ble PRE_first_tail_x15_r0_body.Pc188.N0 19003 = true
theorem PRE_first_tail_x15_r0_body.raised188 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc188 PRE_first_tail_x15_r0_body.P188 :=
  .inr ⟨19003, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise188, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_188 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_188 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1812.ffi)
def PRE_first_tail_x15_r0_body.khinv188 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv188 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS188 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS188 : List Nat := List.range' 19003 0
def PRE_first_tail_x15_r0_body.ciS188 : List Nat := [] ++ List.range' 19003 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0188 : PRE_first_tail_x15_r0_body.kd188.nh0 = PRE_first_tail_x15_r0_body.cx0_188.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1188 : PRE_first_tail_x15_r0_body.kd188.nh1 = PRE_first_tail_x15_r0_body.cx1_188.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0188 : PRE_first_tail_x15_r0_body.kd188.nn0 = PRE_first_tail_x15_r0_body.cx0_188.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1188 : PRE_first_tail_x15_r0_body.kd188.nn1 = PRE_first_tail_x15_r0_body.cx1_188.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo188 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P188.lo && Nat.ble PRE_first_tail_x15_r0_body.P188.lo PRE_first_tail_x15_r0_body.cx0_188.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P188.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P188.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt188 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_188.mlx.next PRE_first_tail_x15_r0_body.cx1_188.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_188.mlx.nnext PRE_first_tail_x15_r0_body.cx1_188.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband188 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P188.NL && Nat.ble PRE_first_tail_x15_r0_body.P188.NL PRE_first_tail_x15_r0_body.P188.N0 && Nat.ble PRE_first_tail_x15_r0_body.P188.N0 PRE_first_tail_x15_r0_body.cx0_188.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow188 : PRE_first_tail_x15_r0_body.kd188.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren188 : checkRenG PRE_first_tail_x15_r0_body.kd188.hnd PRE_first_tail_x15_r0_body.khinv188 (phB PRE_first_tail_x15_r0_body.cx0_188.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband188 : PRE_first_tail_x15_r0_body.kd188.checkBand PRE_first_tail_x15_r0_body.P188.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos188 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd188.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren188 : checkRenG PRE_first_tail_x15_r0_body.kd188.node PRE_first_tail_x15_r0_body.kninv188 (pnB PRE_first_tail_x15_r0_body.cx0_188.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow188 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd188.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P188.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd188.nodeF j) PRE_first_tail_x15_r0_body.cx1_188.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a188 : PRE_first_tail_x15_r0_body.cx0_188.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b188 : PRE_first_tail_x15_r0_body.cx0_188.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1188 : PRE_first_tail_x15_r0_body.cx1_188.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend188 : PRE_first_tail_x15_r0_body.cx1_188.mlx.pending = PRE_first_tail_x15_r0_body.cx0_188.mlx.pending.map PRE_first_tail_x15_r0_body.kappa188.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh188 : PRE_first_tail_x15_r0_body.cx1_188.mlx.errh = PRE_first_tail_x15_r0_body.cx0_188.mlx.errh.map PRE_first_tail_x15_r0_body.kappa188.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles188 : PRE_first_tail_x15_r0_body.cx1_188.mlx.files = PRE_first_tail_x15_r0_body.cx0_188.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch188 : PRE_first_tail_x15_r0_body.cx1_188.mlx.arch = PRE_first_tail_x15_r0_body.cx0_188.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes188 : PRE_first_tail_x15_r0_body.cx1_188.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_188.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired188 : PRE_first_tail_x15_r0_body.cx1_188.mlx.wired = PRE_first_tail_x15_r0_body.cx0_188.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost188 : PRE_first_tail_x15_r0_body.cx1_188.host = PRE_first_tail_x15_r0_body.cx0_188.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd188`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0188 : PRE_first_tail_x15_r0_body.kd188.n0 = 2822032
kernel_rfl PRE_first_tail_x15_r0_body.ckn1188 : PRE_first_tail_x15_r0_body.kd188.n1 = 2822042
kernel_rfl PRE_first_tail_x15_r0_body.ckheap188 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd188.heap).all (fun x => Nat.ble 2822031 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl188 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd188.heap.get (2822031 + j) = nth? PRE_first_tail_x15_r0_body.pl188 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja188 : Nat.ble 2822031 2822031 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn188 : Nat.ble 8092 8092 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD188 : Nat.ble 2822031 PRE_first_tail_x15_r0_body.kd188.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn188 : Nat.ble 21893 PRE_first_tail_x15_r0_body.kd188.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn188 : Nat.ble 19003 PRE_first_tail_x15_r0_body.kd188.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb188 : Nat.ble 21893 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap188 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd188.heap).all (Nat.ble (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd188 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd188.hnd).all (Nat.ble (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode188 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd188.node).all (Nat.ble (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix188 : Conv.FixOld (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa188 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja188) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn188) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD188) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn188) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn188) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb188) PRE_first_tail_x15_r0_body.fheap188 PRE_first_tail_x15_r0_body.fhnd188 PRE_first_tail_x15_r0_body.fnode188
kernel_rfl PRE_first_tail_x15_r0_body.fcxn188 : (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn188 : (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0188 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_188.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_188.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk188 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd188.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A188 : PRE_first_tail_x15_r0_body.cx1_188.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS188.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_188.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O188 : PRE_first_tail_x15_r0_body.cx1_188.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS188.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_188.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N188 : PRE_first_tail_x15_r0_body.cx1_188.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS188.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_188.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I188 : PRE_first_tail_x15_r0_body.cx1_188.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS188.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_188.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd188 : (PRE_first_tail_x15_r0_body.clo188 ++ PRE_first_tail_x15_r0_body.cln188 ++ PRE_first_tail_x15_r0_body.cli188 ++ PRE_first_tail_x15_r0_body.cwS188 ++ PRE_first_tail_x15_r0_body.cnS188 ++ PRE_first_tail_x15_r0_body.ciS188).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW188 : PRE_first_tail_x15_r0_body.cwS188.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo188.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI188 : PRE_first_tail_x15_r0_body.ciS188.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli188.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN188 : PRE_first_tail_x15_r0_body.cnS188.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF188 : PRE_first_tail_x15_r0_body.cln188.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh188 : PRE_first_tail_x15_r0_body.clo188.all (handleOK PRE_first_tail_x15_r0_body.kappa188 PRE_first_tail_x15_r0_body.P188.lo PRE_first_tail_x15_r0_body.cx0_188.mlx PRE_first_tail_x15_r0_body.cx1_188.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo188 : PRE_first_tail_x15_r0_body.clo188.map (fun h => PRE_first_tail_x15_r0_body.cx1_188.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa188.handle h)) = PRE_first_tail_x15_r0_body.clo188.map (fun h => (PRE_first_tail_x15_r0_body.cx0_188.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa188.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok188 : PRE_first_tail_x15_r0_body.clo188.all (objOK PRE_first_tail_x15_r0_body.kappa188 PRE_first_tail_x15_r0_body.P188.NL PRE_first_tail_x15_r0_body.cx0_188.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd188 : PRE_first_tail_x15_r0_body.cln188.all (nodeOKF PRE_first_tail_x15_r0_body.kappa188 PRE_first_tail_x15_r0_body.P188 PRE_first_tail_x15_r0_body.cx0_188.mlx PRE_first_tail_x15_r0_body.cx1_188.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp188 : ((PRE_first_tail_x15_r0_body.cln188.filter (fullB PRE_first_tail_x15_r0_body.P188))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_188.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa188.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln188.filter (fullB PRE_first_tail_x15_r0_body.P188))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_188.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa188.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI188 : incrB PRE_first_tail_x15_r0_body.kd188.nodeF (List.range' 19003 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK188 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd188.node).all (fun k => Nat.ble 19003 k && Nat.blt k 19003) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL188 : (PRE_first_tail_x15_r0_body.cln188.filter (Nat.ble PRE_first_tail_x15_r0_body.P188.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd188.nodeF i) && (Nat.blt i 19003 || Nat.ble PRE_first_tail_x15_r0_body.kd188.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord188 : (PRE_first_tail_x15_r0_body.cln188.filter (Nat.ble PRE_first_tail_x15_r0_body.P188.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd188.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd188.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd188.nodeF j) (PRE_first_tail_x15_r0_body.kd188.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow188 PRE_first_tail_x15_r0_body.cnn1188 PRE_first_tail_x15_r0_body.fnordI188 PRE_first_tail_x15_r0_body.fnordK188 PRE_first_tail_x15_r0_body.fnordL188
kernel_rfl PRE_first_tail_x15_r0_body.fi188 : PRE_first_tail_x15_r0_body.cli188.all (pnB PRE_first_tail_x15_r0_body.cx0_188.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii188 : PRE_first_tail_x15_r0_body.cli188.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_188.mlx.items.get (PRE_first_tail_x15_r0_body.kappa188.node k) = (PRE_first_tail_x15_r0_body.cx0_188.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa188.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot188 (clean : Conv.NClean (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P188.NL) (cl : SSt (· < 8092) PRE_first_tail_x15_r0_body.cx0_188.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P188 8092 PRE_first_tail_x15_r0_body.kappa188 PRE_first_tail_x15_r0_body.kd188 PRE_first_tail_x15_r0_body.khinv188 PRE_first_tail_x15_r0_body.kninv188 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx PRE_first_tail_x15_r0_body.cx0_188.mlx PRE_first_tail_x15_r0_body.cx1_188.mlx (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo188 PRE_first_tail_x15_r0_body.cln188 PRE_first_tail_x15_r0_body.cli188 PRE_first_tail_x15_r0_body.cwS188 PRE_first_tail_x15_r0_body.cnS188 PRE_first_tail_x15_r0_body.ciS188 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0188, PRE_first_tail_x15_r0_body.cnh1188, PRE_first_tail_x15_r0_body.cnn0188, PRE_first_tail_x15_r0_body.cnn1188, PRE_first_tail_x15_r0_body.cplo188, PRE_first_tail_x15_r0_body.ccnt188, PRE_first_tail_x15_r0_body.cnband188, PRE_first_tail_x15_r0_body.chbelow188, PRE_first_tail_x15_r0_body.chren188, PRE_first_tail_x15_r0_body.cband188, PRE_first_tail_x15_r0_body.cnh1pos188, PRE_first_tail_x15_r0_body.cnren188, PRE_first_tail_x15_r0_body.cnlow188, PRE_first_tail_x15_r0_body.cabs0a188, PRE_first_tail_x15_r0_body.cabs0b188, PRE_first_tail_x15_r0_body.ctok1188, PRE_first_tail_x15_r0_body.cpend188, PRE_first_tail_x15_r0_body.cerrh188, PRE_first_tail_x15_r0_body.cfiles188, PRE_first_tail_x15_r0_body.carch188, PRE_first_tail_x15_r0_body.csizes188, PRE_first_tail_x15_r0_body.cwired188, PRE_first_tail_x15_r0_body.cfix188, clean, PRE_first_tail_x15_r0_body.fcxn188, PRE_first_tail_x15_r0_body.fcnn188, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0188, PRE_first_tail_x15_r0_body.fnk188, PRE_first_tail_x15_r0_body.ckA188, PRE_first_tail_x15_r0_body.cobjsK188, PRE_first_tail_x15_r0_body.cnodesK188, PRE_first_tail_x15_r0_body.citemsK188, PRE_first_tail_x15_r0_body.f1A188, PRE_first_tail_x15_r0_body.f1O188, PRE_first_tail_x15_r0_body.f1N188, PRE_first_tail_x15_r0_body.f1I188, PRE_first_tail_x15_r0_body.fbd188, PRE_first_tail_x15_r0_body.fincW188, PRE_first_tail_x15_r0_body.fincI188, PRE_first_tail_x15_r0_body.fincN188, PRE_first_tail_x15_r0_body.flnF188, PRE_first_tail_x15_r0_body.fh188, PRE_first_tail_x15_r0_body.fo188, PRE_first_tail_x15_r0_body.fok188, PRE_first_tail_x15_r0_body.fnd188, PRE_first_tail_x15_r0_body.fp188, PRE_first_tail_x15_r0_body.fnord188, PRE_first_tail_x15_r0_body.fi188, PRE_first_tail_x15_r0_body.fii188⟩
theorem PRE_first_tail_x15_r0_body.cnshift188 (clean : Conv.NClean (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P188.NL) (cl : SSt (· < 8092) PRE_first_tail_x15_r0_body.cx0_188.mlx) : NShift PRE_first_tail_x15_r0_body.P188 8092 PRE_first_tail_x15_r0_body.kappa188 PRE_first_tail_x15_r0_body.cx0_188 PRE_first_tail_x15_r0_body.cx1_188 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot188 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost188 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0188 PRE_first_tail_x15_r0_body.ckn1188 PRE_first_tail_x15_r0_body.ckheap188 PRE_first_tail_x15_r0_body.ckpl188)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_188 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1811.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_188 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1811.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_188 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1811.ffi) = some PRE_first_tail_x15_r0_body.fxC_188
kernel_rfl PRE_first_tail_x15_r0_body.okrC_188 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1811.ffi) = some PRE_first_tail_x15_r0_body.krC_188
noncomputable def PRE_first_tail_x15_r0_body.fx0_188 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1813.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_188 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1813.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_188 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1813.ffi) = some PRE_first_tail_x15_r0_body.fx0_188
kernel_rfl PRE_first_tail_x15_r0_body.okr0_188 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1813.ffi) = some PRE_first_tail_x15_r0_body.kr0_188
noncomputable def PRE_first_tail_x15_r0_body.fx1_188 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1812.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_188 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1812.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_188 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1812.ffi) = some PRE_first_tail_x15_r0_body.fx1_188
kernel_rfl PRE_first_tail_x15_r0_body.okr1_188 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1812.ffi) = some PRE_first_tail_x15_r0_body.kr1_188
kernel_rfl PRE_first_tail_x15_r0_body.ff0188 : PRE_first_tail_x15_r0_body.fx0_188 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_188 (PRE_first_tail_x15_r0_body.clo188.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_188.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1188 : PRE_first_tail_x15_r0_body.fx1_188 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_188 (PRE_first_tail_x15_r0_body.cwS188.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_188.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck188 : freedLB PRE_first_tail_x15_r0_body.kappa188 PRE_first_tail_x15_r0_body.cx0_188.mlx PRE_first_tail_x15_r0_body.fx0_188 PRE_first_tail_x15_r0_body.fx1_188 PRE_first_tail_x15_r0_body.clo188 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0188 : PRE_first_tail_x15_r0_body.kr0_188.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_188.flags (PRE_first_tail_x15_r0_body.clo188.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_188.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0188 : PRE_first_tail_x15_r0_body.kr0_188.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_188.targs (PRE_first_tail_x15_r0_body.clo188.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_188.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1188 : PRE_first_tail_x15_r0_body.kr1_188.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_188.flags (PRE_first_tail_x15_r0_body.cwS188.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_188.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1188 : PRE_first_tail_x15_r0_body.kr1_188.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_188.targs (PRE_first_tail_x15_r0_body.cwS188.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_188.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck188 : krecLB PRE_first_tail_x15_r0_body.kappa188 8092 PRE_first_tail_x15_r0_body.cx0_188.mlx PRE_first_tail_x15_r0_body.kr0_188 PRE_first_tail_x15_r0_body.kr1_188 PRE_first_tail_x15_r0_body.clo188 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn188 : Nat.ble 8092 8092 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge188 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1812.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1813.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR188 : pendRegB PRE_first_tail_x15_r0_body.kappa188 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe188 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1812.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift188 (clean : Conv.NClean (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P188.NL) (cl : SSt (· < 8092) PRE_first_tail_x15_r0_body.cx0_188.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_188.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_188.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_188.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_188.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P188 8092 PRE_first_tail_x15_r0_body.kappa188 PRE_first_tail_x15_r0_body.s1813.ffi PRE_first_tail_x15_r0_body.s1812.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift188 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue188, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp188 t ht),
    PRE_first_tail_x15_r0_body.cbridge188,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1813.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1812.ffi) (PRE_first_tail_x15_r0_body.cfoot188 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_188 PRE_first_tail_x15_r0_body.ofx1_188 hobjC PRE_first_tail_x15_r0_body.ff0188 PRE_first_tail_x15_r0_body.ff1188 PRE_first_tail_x15_r0_body.ffck188,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1813.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1812.ffi) (PRE_first_tail_x15_r0_body.cfoot188 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_188 PRE_first_tail_x15_r0_body.okr1_188 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn188) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0188 PRE_first_tail_x15_r0_body.fkt0188 PRE_first_tail_x15_r0_body.fkf1188 PRE_first_tail_x15_r0_body.fkt1188 PRE_first_tail_x15_r0_body.fkck188,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0188 PRE_first_tail_x15_r0_body.cnh1188 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe188) PRE_first_tail_x15_r0_body.cpendR188⟩

end Host.Load.Run.Tpl

import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl91
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 91 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc91 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P91 : LoadP := PRE_first_tail_x15_r0_body.Pc91.raise 17103
kernel_rfl PRE_first_tail_x15_r0_body.craise91 : Nat.ble PRE_first_tail_x15_r0_body.Pc91.N0 17103 = true
theorem PRE_first_tail_x15_r0_body.raised91 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc91 PRE_first_tail_x15_r0_body.P91 :=
  .inr ⟨17103, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise91, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_91 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s812.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_91 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s811.ffi)
def PRE_first_tail_x15_r0_body.khinv91 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv91 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS91 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS91 : List Nat := List.range' 17103 0
def PRE_first_tail_x15_r0_body.ciS91 : List Nat := [] ++ List.range' 17103 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh091 : PRE_first_tail_x15_r0_body.kd91.nh0 = PRE_first_tail_x15_r0_body.cx0_91.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh191 : PRE_first_tail_x15_r0_body.kd91.nh1 = PRE_first_tail_x15_r0_body.cx1_91.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn091 : PRE_first_tail_x15_r0_body.kd91.nn0 = PRE_first_tail_x15_r0_body.cx0_91.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn191 : PRE_first_tail_x15_r0_body.kd91.nn1 = PRE_first_tail_x15_r0_body.cx1_91.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo91 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P91.lo && Nat.ble PRE_first_tail_x15_r0_body.P91.lo PRE_first_tail_x15_r0_body.cx0_91.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P91.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P91.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt91 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_91.mlx.next PRE_first_tail_x15_r0_body.cx1_91.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_91.mlx.nnext PRE_first_tail_x15_r0_body.cx1_91.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband91 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P91.NL && Nat.ble PRE_first_tail_x15_r0_body.P91.NL PRE_first_tail_x15_r0_body.P91.N0 && Nat.ble PRE_first_tail_x15_r0_body.P91.N0 PRE_first_tail_x15_r0_body.cx0_91.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow91 : PRE_first_tail_x15_r0_body.kd91.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren91 : checkRenG PRE_first_tail_x15_r0_body.kd91.hnd PRE_first_tail_x15_r0_body.khinv91 (phB PRE_first_tail_x15_r0_body.cx0_91.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband91 : PRE_first_tail_x15_r0_body.kd91.checkBand PRE_first_tail_x15_r0_body.P91.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos91 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd91.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren91 : checkRenG PRE_first_tail_x15_r0_body.kd91.node PRE_first_tail_x15_r0_body.kninv91 (pnB PRE_first_tail_x15_r0_body.cx0_91.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow91 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd91.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P91.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd91.nodeF j) PRE_first_tail_x15_r0_body.cx1_91.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a91 : PRE_first_tail_x15_r0_body.cx0_91.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b91 : PRE_first_tail_x15_r0_body.cx0_91.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok191 : PRE_first_tail_x15_r0_body.cx1_91.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend91 : PRE_first_tail_x15_r0_body.cx1_91.mlx.pending = PRE_first_tail_x15_r0_body.cx0_91.mlx.pending.map PRE_first_tail_x15_r0_body.kappa91.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh91 : PRE_first_tail_x15_r0_body.cx1_91.mlx.errh = PRE_first_tail_x15_r0_body.cx0_91.mlx.errh.map PRE_first_tail_x15_r0_body.kappa91.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles91 : PRE_first_tail_x15_r0_body.cx1_91.mlx.files = PRE_first_tail_x15_r0_body.cx0_91.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch91 : PRE_first_tail_x15_r0_body.cx1_91.mlx.arch = PRE_first_tail_x15_r0_body.cx0_91.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes91 : PRE_first_tail_x15_r0_body.cx1_91.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_91.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired91 : PRE_first_tail_x15_r0_body.cx1_91.mlx.wired = PRE_first_tail_x15_r0_body.cx0_91.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost91 : PRE_first_tail_x15_r0_body.cx1_91.host = PRE_first_tail_x15_r0_body.cx0_91.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd91`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn091 : PRE_first_tail_x15_r0_body.kd91.n0 = 2746383
kernel_rfl PRE_first_tail_x15_r0_body.ckn191 : PRE_first_tail_x15_r0_body.kd91.n1 = 2746385
kernel_rfl PRE_first_tail_x15_r0_body.ckheap91 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd91.heap).all (fun x => Nat.ble 2746383 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl91 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd91.heap.get (2746383 + j) = nth? PRE_first_tail_x15_r0_body.pl91 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja91 : Nat.ble 2746383 2746383 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn91 : Nat.ble 3971 3971 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD91 : Nat.ble 2746383 PRE_first_tail_x15_r0_body.kd91.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn91 : Nat.ble 19998 PRE_first_tail_x15_r0_body.kd91.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn91 : Nat.ble 17103 PRE_first_tail_x15_r0_body.kd91.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb91 : Nat.ble 19998 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap91 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd91.heap).all (Nat.ble (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd91 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd91.hnd).all (Nat.ble (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode91 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd91.node).all (Nat.ble (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix91 : Conv.FixOld (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa91 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja91) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn91) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD91) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn91) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn91) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb91) PRE_first_tail_x15_r0_body.fheap91 PRE_first_tail_x15_r0_body.fhnd91 PRE_first_tail_x15_r0_body.fnode91
kernel_rfl PRE_first_tail_x15_r0_body.fcxn91 : (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn91 : (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle091 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_91.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_91.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk91 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd91.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A91 : PRE_first_tail_x15_r0_body.cx1_91.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS91.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_91.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O91 : PRE_first_tail_x15_r0_body.cx1_91.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS91.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_91.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N91 : PRE_first_tail_x15_r0_body.cx1_91.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS91.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_91.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I91 : PRE_first_tail_x15_r0_body.cx1_91.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS91.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_91.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd91 : (PRE_first_tail_x15_r0_body.clo91 ++ PRE_first_tail_x15_r0_body.cln91 ++ PRE_first_tail_x15_r0_body.cli91 ++ PRE_first_tail_x15_r0_body.cwS91 ++ PRE_first_tail_x15_r0_body.cnS91 ++ PRE_first_tail_x15_r0_body.ciS91).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW91 : PRE_first_tail_x15_r0_body.cwS91.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo91.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI91 : PRE_first_tail_x15_r0_body.ciS91.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli91.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN91 : PRE_first_tail_x15_r0_body.cnS91.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF91 : PRE_first_tail_x15_r0_body.cln91.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh91 : PRE_first_tail_x15_r0_body.clo91.all (handleOK PRE_first_tail_x15_r0_body.kappa91 PRE_first_tail_x15_r0_body.P91.lo PRE_first_tail_x15_r0_body.cx0_91.mlx PRE_first_tail_x15_r0_body.cx1_91.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo91 : PRE_first_tail_x15_r0_body.clo91.map (fun h => PRE_first_tail_x15_r0_body.cx1_91.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa91.handle h)) = PRE_first_tail_x15_r0_body.clo91.map (fun h => (PRE_first_tail_x15_r0_body.cx0_91.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa91.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok91 : PRE_first_tail_x15_r0_body.clo91.all (objOK PRE_first_tail_x15_r0_body.kappa91 PRE_first_tail_x15_r0_body.P91.NL PRE_first_tail_x15_r0_body.cx0_91.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd91 : PRE_first_tail_x15_r0_body.cln91.all (nodeOKF PRE_first_tail_x15_r0_body.kappa91 PRE_first_tail_x15_r0_body.P91 PRE_first_tail_x15_r0_body.cx0_91.mlx PRE_first_tail_x15_r0_body.cx1_91.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp91 : ((PRE_first_tail_x15_r0_body.cln91.filter (fullB PRE_first_tail_x15_r0_body.P91))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_91.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa91.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln91.filter (fullB PRE_first_tail_x15_r0_body.P91))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_91.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa91.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI91 : incrB PRE_first_tail_x15_r0_body.kd91.nodeF (List.range' 17103 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK91 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd91.node).all (fun k => Nat.ble 17103 k && Nat.blt k 17103) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL91 : (PRE_first_tail_x15_r0_body.cln91.filter (Nat.ble PRE_first_tail_x15_r0_body.P91.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd91.nodeF i) && (Nat.blt i 17103 || Nat.ble PRE_first_tail_x15_r0_body.kd91.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord91 : (PRE_first_tail_x15_r0_body.cln91.filter (Nat.ble PRE_first_tail_x15_r0_body.P91.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd91.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd91.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd91.nodeF j) (PRE_first_tail_x15_r0_body.kd91.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow91 PRE_first_tail_x15_r0_body.cnn191 PRE_first_tail_x15_r0_body.fnordI91 PRE_first_tail_x15_r0_body.fnordK91 PRE_first_tail_x15_r0_body.fnordL91
kernel_rfl PRE_first_tail_x15_r0_body.fi91 : PRE_first_tail_x15_r0_body.cli91.all (pnB PRE_first_tail_x15_r0_body.cx0_91.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii91 : PRE_first_tail_x15_r0_body.cli91.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_91.mlx.items.get (PRE_first_tail_x15_r0_body.kappa91.node k) = (PRE_first_tail_x15_r0_body.cx0_91.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa91.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot91 (clean : Conv.NClean (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P91.NL) (cl : SSt (· < 3971) PRE_first_tail_x15_r0_body.cx0_91.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P91 3971 PRE_first_tail_x15_r0_body.kappa91 PRE_first_tail_x15_r0_body.kd91 PRE_first_tail_x15_r0_body.khinv91 PRE_first_tail_x15_r0_body.kninv91 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx PRE_first_tail_x15_r0_body.cx0_91.mlx PRE_first_tail_x15_r0_body.cx1_91.mlx (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo91 PRE_first_tail_x15_r0_body.cln91 PRE_first_tail_x15_r0_body.cli91 PRE_first_tail_x15_r0_body.cwS91 PRE_first_tail_x15_r0_body.cnS91 PRE_first_tail_x15_r0_body.ciS91 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh091, PRE_first_tail_x15_r0_body.cnh191, PRE_first_tail_x15_r0_body.cnn091, PRE_first_tail_x15_r0_body.cnn191, PRE_first_tail_x15_r0_body.cplo91, PRE_first_tail_x15_r0_body.ccnt91, PRE_first_tail_x15_r0_body.cnband91, PRE_first_tail_x15_r0_body.chbelow91, PRE_first_tail_x15_r0_body.chren91, PRE_first_tail_x15_r0_body.cband91, PRE_first_tail_x15_r0_body.cnh1pos91, PRE_first_tail_x15_r0_body.cnren91, PRE_first_tail_x15_r0_body.cnlow91, PRE_first_tail_x15_r0_body.cabs0a91, PRE_first_tail_x15_r0_body.cabs0b91, PRE_first_tail_x15_r0_body.ctok191, PRE_first_tail_x15_r0_body.cpend91, PRE_first_tail_x15_r0_body.cerrh91, PRE_first_tail_x15_r0_body.cfiles91, PRE_first_tail_x15_r0_body.carch91, PRE_first_tail_x15_r0_body.csizes91, PRE_first_tail_x15_r0_body.cwired91, PRE_first_tail_x15_r0_body.cfix91, clean, PRE_first_tail_x15_r0_body.fcxn91, PRE_first_tail_x15_r0_body.fcnn91, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle091, PRE_first_tail_x15_r0_body.fnk91, PRE_first_tail_x15_r0_body.ckA91, PRE_first_tail_x15_r0_body.cobjsK91, PRE_first_tail_x15_r0_body.cnodesK91, PRE_first_tail_x15_r0_body.citemsK91, PRE_first_tail_x15_r0_body.f1A91, PRE_first_tail_x15_r0_body.f1O91, PRE_first_tail_x15_r0_body.f1N91, PRE_first_tail_x15_r0_body.f1I91, PRE_first_tail_x15_r0_body.fbd91, PRE_first_tail_x15_r0_body.fincW91, PRE_first_tail_x15_r0_body.fincI91, PRE_first_tail_x15_r0_body.fincN91, PRE_first_tail_x15_r0_body.flnF91, PRE_first_tail_x15_r0_body.fh91, PRE_first_tail_x15_r0_body.fo91, PRE_first_tail_x15_r0_body.fok91, PRE_first_tail_x15_r0_body.fnd91, PRE_first_tail_x15_r0_body.fp91, PRE_first_tail_x15_r0_body.fnord91, PRE_first_tail_x15_r0_body.fi91, PRE_first_tail_x15_r0_body.fii91⟩
theorem PRE_first_tail_x15_r0_body.cnshift91 (clean : Conv.NClean (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P91.NL) (cl : SSt (· < 3971) PRE_first_tail_x15_r0_body.cx0_91.mlx) : NShift PRE_first_tail_x15_r0_body.P91 3971 PRE_first_tail_x15_r0_body.kappa91 PRE_first_tail_x15_r0_body.cx0_91 PRE_first_tail_x15_r0_body.cx1_91 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot91 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost91 (compact_a_eq PRE_first_tail_x15_r0_body.ckn091 PRE_first_tail_x15_r0_body.ckn191 PRE_first_tail_x15_r0_body.ckheap91 PRE_first_tail_x15_r0_body.ckpl91)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_91 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s810.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_91 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s810.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_91 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s810.ffi) = some PRE_first_tail_x15_r0_body.fxC_91
kernel_rfl PRE_first_tail_x15_r0_body.okrC_91 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s810.ffi) = some PRE_first_tail_x15_r0_body.krC_91
noncomputable def PRE_first_tail_x15_r0_body.fx0_91 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s812.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_91 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s812.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_91 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s812.ffi) = some PRE_first_tail_x15_r0_body.fx0_91
kernel_rfl PRE_first_tail_x15_r0_body.okr0_91 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s812.ffi) = some PRE_first_tail_x15_r0_body.kr0_91
noncomputable def PRE_first_tail_x15_r0_body.fx1_91 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s811.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_91 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s811.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_91 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s811.ffi) = some PRE_first_tail_x15_r0_body.fx1_91
kernel_rfl PRE_first_tail_x15_r0_body.okr1_91 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s811.ffi) = some PRE_first_tail_x15_r0_body.kr1_91
kernel_rfl PRE_first_tail_x15_r0_body.ff091 : PRE_first_tail_x15_r0_body.fx0_91 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_91 (PRE_first_tail_x15_r0_body.clo91.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_91.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff191 : PRE_first_tail_x15_r0_body.fx1_91 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_91 (PRE_first_tail_x15_r0_body.cwS91.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_91.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck91 : freedLB PRE_first_tail_x15_r0_body.kappa91 PRE_first_tail_x15_r0_body.cx0_91.mlx PRE_first_tail_x15_r0_body.fx0_91 PRE_first_tail_x15_r0_body.fx1_91 PRE_first_tail_x15_r0_body.clo91 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf091 : PRE_first_tail_x15_r0_body.kr0_91.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_91.flags (PRE_first_tail_x15_r0_body.clo91.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_91.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt091 : PRE_first_tail_x15_r0_body.kr0_91.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_91.targs (PRE_first_tail_x15_r0_body.clo91.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_91.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf191 : PRE_first_tail_x15_r0_body.kr1_91.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_91.flags (PRE_first_tail_x15_r0_body.cwS91.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_91.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt191 : PRE_first_tail_x15_r0_body.kr1_91.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_91.targs (PRE_first_tail_x15_r0_body.cwS91.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_91.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck91 : krecLB PRE_first_tail_x15_r0_body.kappa91 3971 PRE_first_tail_x15_r0_body.cx0_91.mlx PRE_first_tail_x15_r0_body.kr0_91 PRE_first_tail_x15_r0_body.kr1_91 PRE_first_tail_x15_r0_body.clo91 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn91 : Nat.ble 3971 3971 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge91 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s811.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s812.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR91 : pendRegB PRE_first_tail_x15_r0_body.kappa91 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s812.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe91 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s812.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s811.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift91 (clean : Conv.NClean (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P91.NL) (cl : SSt (· < 3971) PRE_first_tail_x15_r0_body.cx0_91.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_91.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_91.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_91.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s810.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_91.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P91 3971 PRE_first_tail_x15_r0_body.kappa91 PRE_first_tail_x15_r0_body.s812.ffi PRE_first_tail_x15_r0_body.s811.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift91 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue91, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp91 t ht),
    PRE_first_tail_x15_r0_body.cbridge91,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s812.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s811.ffi) (PRE_first_tail_x15_r0_body.cfoot91 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_91 PRE_first_tail_x15_r0_body.ofx1_91 hobjC PRE_first_tail_x15_r0_body.ff091 PRE_first_tail_x15_r0_body.ff191 PRE_first_tail_x15_r0_body.ffck91,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s812.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s811.ffi) (PRE_first_tail_x15_r0_body.cfoot91 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_91 PRE_first_tail_x15_r0_body.okr1_91 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn91) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf091 PRE_first_tail_x15_r0_body.fkt091 PRE_first_tail_x15_r0_body.fkf191 PRE_first_tail_x15_r0_body.fkt191 PRE_first_tail_x15_r0_body.fkck91,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh091 PRE_first_tail_x15_r0_body.cnh191 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe91) PRE_first_tail_x15_r0_body.cpendR91⟩

end Host.Load.Run.Tpl

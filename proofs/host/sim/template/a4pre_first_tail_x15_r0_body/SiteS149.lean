import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl149
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 149 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc149 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P149 : LoadP := PRE_first_tail_x15_r0_body.Pc149.raise 18229
kernel_rfl PRE_first_tail_x15_r0_body.craise149 : Nat.ble PRE_first_tail_x15_r0_body.Pc149.N0 18229 = true
theorem PRE_first_tail_x15_r0_body.raised149 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc149 PRE_first_tail_x15_r0_body.P149 :=
  .inr ⟨18229, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise149, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_149 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1314.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_149 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1313.ffi)
def PRE_first_tail_x15_r0_body.khinv149 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv149 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS149 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS149 : List Nat := List.range' 18229 0
def PRE_first_tail_x15_r0_body.ciS149 : List Nat := [] ++ List.range' 18229 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0149 : PRE_first_tail_x15_r0_body.kd149.nh0 = PRE_first_tail_x15_r0_body.cx0_149.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1149 : PRE_first_tail_x15_r0_body.kd149.nh1 = PRE_first_tail_x15_r0_body.cx1_149.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0149 : PRE_first_tail_x15_r0_body.kd149.nn0 = PRE_first_tail_x15_r0_body.cx0_149.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1149 : PRE_first_tail_x15_r0_body.kd149.nn1 = PRE_first_tail_x15_r0_body.cx1_149.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo149 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P149.lo && Nat.ble PRE_first_tail_x15_r0_body.P149.lo PRE_first_tail_x15_r0_body.cx0_149.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P149.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P149.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt149 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_149.mlx.next PRE_first_tail_x15_r0_body.cx1_149.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_149.mlx.nnext PRE_first_tail_x15_r0_body.cx1_149.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband149 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P149.NL && Nat.ble PRE_first_tail_x15_r0_body.P149.NL PRE_first_tail_x15_r0_body.P149.N0 && Nat.ble PRE_first_tail_x15_r0_body.P149.N0 PRE_first_tail_x15_r0_body.cx0_149.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow149 : PRE_first_tail_x15_r0_body.kd149.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren149 : checkRenG PRE_first_tail_x15_r0_body.kd149.hnd PRE_first_tail_x15_r0_body.khinv149 (phB PRE_first_tail_x15_r0_body.cx0_149.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband149 : PRE_first_tail_x15_r0_body.kd149.checkBand PRE_first_tail_x15_r0_body.P149.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos149 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd149.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren149 : checkRenG PRE_first_tail_x15_r0_body.kd149.node PRE_first_tail_x15_r0_body.kninv149 (pnB PRE_first_tail_x15_r0_body.cx0_149.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow149 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd149.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P149.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd149.nodeF j) PRE_first_tail_x15_r0_body.cx1_149.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a149 : PRE_first_tail_x15_r0_body.cx0_149.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b149 : PRE_first_tail_x15_r0_body.cx0_149.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1149 : PRE_first_tail_x15_r0_body.cx1_149.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend149 : PRE_first_tail_x15_r0_body.cx1_149.mlx.pending = PRE_first_tail_x15_r0_body.cx0_149.mlx.pending.map PRE_first_tail_x15_r0_body.kappa149.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh149 : PRE_first_tail_x15_r0_body.cx1_149.mlx.errh = PRE_first_tail_x15_r0_body.cx0_149.mlx.errh.map PRE_first_tail_x15_r0_body.kappa149.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles149 : PRE_first_tail_x15_r0_body.cx1_149.mlx.files = PRE_first_tail_x15_r0_body.cx0_149.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch149 : PRE_first_tail_x15_r0_body.cx1_149.mlx.arch = PRE_first_tail_x15_r0_body.cx0_149.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes149 : PRE_first_tail_x15_r0_body.cx1_149.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_149.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired149 : PRE_first_tail_x15_r0_body.cx1_149.mlx.wired = PRE_first_tail_x15_r0_body.cx0_149.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost149 : PRE_first_tail_x15_r0_body.cx1_149.host = PRE_first_tail_x15_r0_body.cx0_149.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd149`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0149 : PRE_first_tail_x15_r0_body.kd149.n0 = 2791504
kernel_rfl PRE_first_tail_x15_r0_body.ckn1149 : PRE_first_tail_x15_r0_body.kd149.n1 = 2791523
kernel_rfl PRE_first_tail_x15_r0_body.ckheap149 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd149.heap).all (fun x => Nat.ble 2791503 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl149 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd149.heap.get (2791503 + j) = nth? PRE_first_tail_x15_r0_body.pl149 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja149 : Nat.ble 2791503 2791503 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn149 : Nat.ble 6424 6424 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD149 : Nat.ble 2791503 PRE_first_tail_x15_r0_body.kd149.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn149 : Nat.ble 21128 PRE_first_tail_x15_r0_body.kd149.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn149 : Nat.ble 18229 PRE_first_tail_x15_r0_body.kd149.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb149 : Nat.ble 21128 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap149 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd149.heap).all (Nat.ble (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd149 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd149.hnd).all (Nat.ble (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode149 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd149.node).all (Nat.ble (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix149 : Conv.FixOld (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa149 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja149) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn149) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD149) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn149) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn149) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb149) PRE_first_tail_x15_r0_body.fheap149 PRE_first_tail_x15_r0_body.fhnd149 PRE_first_tail_x15_r0_body.fnode149
kernel_rfl PRE_first_tail_x15_r0_body.fcxn149 : (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn149 : (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0149 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_149.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_149.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk149 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd149.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A149 : PRE_first_tail_x15_r0_body.cx1_149.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS149.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_149.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O149 : PRE_first_tail_x15_r0_body.cx1_149.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS149.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_149.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N149 : PRE_first_tail_x15_r0_body.cx1_149.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS149.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_149.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I149 : PRE_first_tail_x15_r0_body.cx1_149.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS149.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_149.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd149 : (PRE_first_tail_x15_r0_body.clo149 ++ PRE_first_tail_x15_r0_body.cln149 ++ PRE_first_tail_x15_r0_body.cli149 ++ PRE_first_tail_x15_r0_body.cwS149 ++ PRE_first_tail_x15_r0_body.cnS149 ++ PRE_first_tail_x15_r0_body.ciS149).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW149 : PRE_first_tail_x15_r0_body.cwS149.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo149.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI149 : PRE_first_tail_x15_r0_body.ciS149.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli149.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN149 : PRE_first_tail_x15_r0_body.cnS149.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF149 : PRE_first_tail_x15_r0_body.cln149.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh149 : PRE_first_tail_x15_r0_body.clo149.all (handleOK PRE_first_tail_x15_r0_body.kappa149 PRE_first_tail_x15_r0_body.P149.lo PRE_first_tail_x15_r0_body.cx0_149.mlx PRE_first_tail_x15_r0_body.cx1_149.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo149 : PRE_first_tail_x15_r0_body.clo149.map (fun h => PRE_first_tail_x15_r0_body.cx1_149.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa149.handle h)) = PRE_first_tail_x15_r0_body.clo149.map (fun h => (PRE_first_tail_x15_r0_body.cx0_149.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa149.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok149 : PRE_first_tail_x15_r0_body.clo149.all (objOK PRE_first_tail_x15_r0_body.kappa149 PRE_first_tail_x15_r0_body.P149.NL PRE_first_tail_x15_r0_body.cx0_149.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd149 : PRE_first_tail_x15_r0_body.cln149.all (nodeOKF PRE_first_tail_x15_r0_body.kappa149 PRE_first_tail_x15_r0_body.P149 PRE_first_tail_x15_r0_body.cx0_149.mlx PRE_first_tail_x15_r0_body.cx1_149.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp149 : ((PRE_first_tail_x15_r0_body.cln149.filter (fullB PRE_first_tail_x15_r0_body.P149))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_149.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa149.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln149.filter (fullB PRE_first_tail_x15_r0_body.P149))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_149.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa149.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI149 : incrB PRE_first_tail_x15_r0_body.kd149.nodeF (List.range' 18229 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK149 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd149.node).all (fun k => Nat.ble 18229 k && Nat.blt k 18229) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL149 : (PRE_first_tail_x15_r0_body.cln149.filter (Nat.ble PRE_first_tail_x15_r0_body.P149.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd149.nodeF i) && (Nat.blt i 18229 || Nat.ble PRE_first_tail_x15_r0_body.kd149.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord149 : (PRE_first_tail_x15_r0_body.cln149.filter (Nat.ble PRE_first_tail_x15_r0_body.P149.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd149.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd149.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd149.nodeF j) (PRE_first_tail_x15_r0_body.kd149.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow149 PRE_first_tail_x15_r0_body.cnn1149 PRE_first_tail_x15_r0_body.fnordI149 PRE_first_tail_x15_r0_body.fnordK149 PRE_first_tail_x15_r0_body.fnordL149
kernel_rfl PRE_first_tail_x15_r0_body.fi149 : PRE_first_tail_x15_r0_body.cli149.all (pnB PRE_first_tail_x15_r0_body.cx0_149.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii149 : PRE_first_tail_x15_r0_body.cli149.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_149.mlx.items.get (PRE_first_tail_x15_r0_body.kappa149.node k) = (PRE_first_tail_x15_r0_body.cx0_149.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa149.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot149 (clean : Conv.NClean (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P149.NL) (cl : SSt (· < 6424) PRE_first_tail_x15_r0_body.cx0_149.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P149 6424 PRE_first_tail_x15_r0_body.kappa149 PRE_first_tail_x15_r0_body.kd149 PRE_first_tail_x15_r0_body.khinv149 PRE_first_tail_x15_r0_body.kninv149 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx PRE_first_tail_x15_r0_body.cx0_149.mlx PRE_first_tail_x15_r0_body.cx1_149.mlx (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo149 PRE_first_tail_x15_r0_body.cln149 PRE_first_tail_x15_r0_body.cli149 PRE_first_tail_x15_r0_body.cwS149 PRE_first_tail_x15_r0_body.cnS149 PRE_first_tail_x15_r0_body.ciS149 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0149, PRE_first_tail_x15_r0_body.cnh1149, PRE_first_tail_x15_r0_body.cnn0149, PRE_first_tail_x15_r0_body.cnn1149, PRE_first_tail_x15_r0_body.cplo149, PRE_first_tail_x15_r0_body.ccnt149, PRE_first_tail_x15_r0_body.cnband149, PRE_first_tail_x15_r0_body.chbelow149, PRE_first_tail_x15_r0_body.chren149, PRE_first_tail_x15_r0_body.cband149, PRE_first_tail_x15_r0_body.cnh1pos149, PRE_first_tail_x15_r0_body.cnren149, PRE_first_tail_x15_r0_body.cnlow149, PRE_first_tail_x15_r0_body.cabs0a149, PRE_first_tail_x15_r0_body.cabs0b149, PRE_first_tail_x15_r0_body.ctok1149, PRE_first_tail_x15_r0_body.cpend149, PRE_first_tail_x15_r0_body.cerrh149, PRE_first_tail_x15_r0_body.cfiles149, PRE_first_tail_x15_r0_body.carch149, PRE_first_tail_x15_r0_body.csizes149, PRE_first_tail_x15_r0_body.cwired149, PRE_first_tail_x15_r0_body.cfix149, clean, PRE_first_tail_x15_r0_body.fcxn149, PRE_first_tail_x15_r0_body.fcnn149, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0149, PRE_first_tail_x15_r0_body.fnk149, PRE_first_tail_x15_r0_body.ckA149, PRE_first_tail_x15_r0_body.cobjsK149, PRE_first_tail_x15_r0_body.cnodesK149, PRE_first_tail_x15_r0_body.citemsK149, PRE_first_tail_x15_r0_body.f1A149, PRE_first_tail_x15_r0_body.f1O149, PRE_first_tail_x15_r0_body.f1N149, PRE_first_tail_x15_r0_body.f1I149, PRE_first_tail_x15_r0_body.fbd149, PRE_first_tail_x15_r0_body.fincW149, PRE_first_tail_x15_r0_body.fincI149, PRE_first_tail_x15_r0_body.fincN149, PRE_first_tail_x15_r0_body.flnF149, PRE_first_tail_x15_r0_body.fh149, PRE_first_tail_x15_r0_body.fo149, PRE_first_tail_x15_r0_body.fok149, PRE_first_tail_x15_r0_body.fnd149, PRE_first_tail_x15_r0_body.fp149, PRE_first_tail_x15_r0_body.fnord149, PRE_first_tail_x15_r0_body.fi149, PRE_first_tail_x15_r0_body.fii149⟩
theorem PRE_first_tail_x15_r0_body.cnshift149 (clean : Conv.NClean (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P149.NL) (cl : SSt (· < 6424) PRE_first_tail_x15_r0_body.cx0_149.mlx) : NShift PRE_first_tail_x15_r0_body.P149 6424 PRE_first_tail_x15_r0_body.kappa149 PRE_first_tail_x15_r0_body.cx0_149 PRE_first_tail_x15_r0_body.cx1_149 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot149 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost149 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0149 PRE_first_tail_x15_r0_body.ckn1149 PRE_first_tail_x15_r0_body.ckheap149 PRE_first_tail_x15_r0_body.ckpl149)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_149 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1312.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_149 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1312.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_149 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1312.ffi) = some PRE_first_tail_x15_r0_body.fxC_149
kernel_rfl PRE_first_tail_x15_r0_body.okrC_149 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1312.ffi) = some PRE_first_tail_x15_r0_body.krC_149
noncomputable def PRE_first_tail_x15_r0_body.fx0_149 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1314.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_149 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1314.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_149 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1314.ffi) = some PRE_first_tail_x15_r0_body.fx0_149
kernel_rfl PRE_first_tail_x15_r0_body.okr0_149 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1314.ffi) = some PRE_first_tail_x15_r0_body.kr0_149
noncomputable def PRE_first_tail_x15_r0_body.fx1_149 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1313.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_149 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1313.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_149 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1313.ffi) = some PRE_first_tail_x15_r0_body.fx1_149
kernel_rfl PRE_first_tail_x15_r0_body.okr1_149 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1313.ffi) = some PRE_first_tail_x15_r0_body.kr1_149
kernel_rfl PRE_first_tail_x15_r0_body.ff0149 : PRE_first_tail_x15_r0_body.fx0_149 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_149 (PRE_first_tail_x15_r0_body.clo149.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_149.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1149 : PRE_first_tail_x15_r0_body.fx1_149 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_149 (PRE_first_tail_x15_r0_body.cwS149.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_149.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck149 : freedLB PRE_first_tail_x15_r0_body.kappa149 PRE_first_tail_x15_r0_body.cx0_149.mlx PRE_first_tail_x15_r0_body.fx0_149 PRE_first_tail_x15_r0_body.fx1_149 PRE_first_tail_x15_r0_body.clo149 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0149 : PRE_first_tail_x15_r0_body.kr0_149.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_149.flags (PRE_first_tail_x15_r0_body.clo149.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_149.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0149 : PRE_first_tail_x15_r0_body.kr0_149.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_149.targs (PRE_first_tail_x15_r0_body.clo149.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_149.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1149 : PRE_first_tail_x15_r0_body.kr1_149.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_149.flags (PRE_first_tail_x15_r0_body.cwS149.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_149.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1149 : PRE_first_tail_x15_r0_body.kr1_149.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_149.targs (PRE_first_tail_x15_r0_body.cwS149.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_149.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck149 : krecLB PRE_first_tail_x15_r0_body.kappa149 6424 PRE_first_tail_x15_r0_body.cx0_149.mlx PRE_first_tail_x15_r0_body.kr0_149 PRE_first_tail_x15_r0_body.kr1_149 PRE_first_tail_x15_r0_body.clo149 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn149 : Nat.ble 6424 6424 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge149 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1313.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1314.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR149 : pendRegB PRE_first_tail_x15_r0_body.kappa149 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1314.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe149 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1314.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1313.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift149 (clean : Conv.NClean (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P149.NL) (cl : SSt (· < 6424) PRE_first_tail_x15_r0_body.cx0_149.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_149.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_149.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_149.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_149.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P149 6424 PRE_first_tail_x15_r0_body.kappa149 PRE_first_tail_x15_r0_body.s1314.ffi PRE_first_tail_x15_r0_body.s1313.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift149 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue149, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp149 t ht),
    PRE_first_tail_x15_r0_body.cbridge149,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1314.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1313.ffi) (PRE_first_tail_x15_r0_body.cfoot149 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_149 PRE_first_tail_x15_r0_body.ofx1_149 hobjC PRE_first_tail_x15_r0_body.ff0149 PRE_first_tail_x15_r0_body.ff1149 PRE_first_tail_x15_r0_body.ffck149,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1314.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1313.ffi) (PRE_first_tail_x15_r0_body.cfoot149 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_149 PRE_first_tail_x15_r0_body.okr1_149 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn149) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0149 PRE_first_tail_x15_r0_body.fkt0149 PRE_first_tail_x15_r0_body.fkf1149 PRE_first_tail_x15_r0_body.fkt1149 PRE_first_tail_x15_r0_body.fkck149,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0149 PRE_first_tail_x15_r0_body.cnh1149 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe149) PRE_first_tail_x15_r0_body.cpendR149⟩

end Host.Load.Run.Tpl

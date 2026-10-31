import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl169
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 169 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc169 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P169 : LoadP := PRE_first_tail_x15_r0_body.Pc169.raise 18636
kernel_rfl PRE_first_tail_x15_r0_body.craise169 : Nat.ble PRE_first_tail_x15_r0_body.Pc169.N0 18636 = true
theorem PRE_first_tail_x15_r0_body.raised169 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc169 PRE_first_tail_x15_r0_body.P169 :=
  .inr ⟨18636, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise169, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_169 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1493.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_169 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1492.ffi)
def PRE_first_tail_x15_r0_body.khinv169 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv169 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS169 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS169 : List Nat := List.range' 18636 0
def PRE_first_tail_x15_r0_body.ciS169 : List Nat := [] ++ List.range' 18636 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0169 : PRE_first_tail_x15_r0_body.kd169.nh0 = PRE_first_tail_x15_r0_body.cx0_169.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1169 : PRE_first_tail_x15_r0_body.kd169.nh1 = PRE_first_tail_x15_r0_body.cx1_169.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0169 : PRE_first_tail_x15_r0_body.kd169.nn0 = PRE_first_tail_x15_r0_body.cx0_169.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1169 : PRE_first_tail_x15_r0_body.kd169.nn1 = PRE_first_tail_x15_r0_body.cx1_169.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo169 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P169.lo && Nat.ble PRE_first_tail_x15_r0_body.P169.lo PRE_first_tail_x15_r0_body.cx0_169.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P169.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P169.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt169 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_169.mlx.next PRE_first_tail_x15_r0_body.cx1_169.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_169.mlx.nnext PRE_first_tail_x15_r0_body.cx1_169.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband169 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P169.NL && Nat.ble PRE_first_tail_x15_r0_body.P169.NL PRE_first_tail_x15_r0_body.P169.N0 && Nat.ble PRE_first_tail_x15_r0_body.P169.N0 PRE_first_tail_x15_r0_body.cx0_169.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow169 : PRE_first_tail_x15_r0_body.kd169.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren169 : checkRenG PRE_first_tail_x15_r0_body.kd169.hnd PRE_first_tail_x15_r0_body.khinv169 (phB PRE_first_tail_x15_r0_body.cx0_169.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband169 : PRE_first_tail_x15_r0_body.kd169.checkBand PRE_first_tail_x15_r0_body.P169.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos169 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd169.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren169 : checkRenG PRE_first_tail_x15_r0_body.kd169.node PRE_first_tail_x15_r0_body.kninv169 (pnB PRE_first_tail_x15_r0_body.cx0_169.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow169 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd169.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P169.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd169.nodeF j) PRE_first_tail_x15_r0_body.cx1_169.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a169 : PRE_first_tail_x15_r0_body.cx0_169.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b169 : PRE_first_tail_x15_r0_body.cx0_169.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1169 : PRE_first_tail_x15_r0_body.cx1_169.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend169 : PRE_first_tail_x15_r0_body.cx1_169.mlx.pending = PRE_first_tail_x15_r0_body.cx0_169.mlx.pending.map PRE_first_tail_x15_r0_body.kappa169.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh169 : PRE_first_tail_x15_r0_body.cx1_169.mlx.errh = PRE_first_tail_x15_r0_body.cx0_169.mlx.errh.map PRE_first_tail_x15_r0_body.kappa169.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles169 : PRE_first_tail_x15_r0_body.cx1_169.mlx.files = PRE_first_tail_x15_r0_body.cx0_169.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch169 : PRE_first_tail_x15_r0_body.cx1_169.mlx.arch = PRE_first_tail_x15_r0_body.cx0_169.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes169 : PRE_first_tail_x15_r0_body.cx1_169.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_169.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired169 : PRE_first_tail_x15_r0_body.cx1_169.mlx.wired = PRE_first_tail_x15_r0_body.cx0_169.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost169 : PRE_first_tail_x15_r0_body.cx1_169.host = PRE_first_tail_x15_r0_body.cx0_169.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd169`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0169 : PRE_first_tail_x15_r0_body.kd169.n0 = 2807795
kernel_rfl PRE_first_tail_x15_r0_body.ckn1169 : PRE_first_tail_x15_r0_body.kd169.n1 = 2807797
kernel_rfl PRE_first_tail_x15_r0_body.ckheap169 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd169.heap).all (fun x => Nat.ble 2807795 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl169 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd169.heap.get (2807795 + j) = nth? PRE_first_tail_x15_r0_body.pl169 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja169 : Nat.ble 2807795 2807795 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn169 : Nat.ble 7304 7304 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD169 : Nat.ble 2807795 PRE_first_tail_x15_r0_body.kd169.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn169 : Nat.ble 21536 PRE_first_tail_x15_r0_body.kd169.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn169 : Nat.ble 18636 PRE_first_tail_x15_r0_body.kd169.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb169 : Nat.ble 21536 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap169 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd169.heap).all (Nat.ble (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd169 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd169.hnd).all (Nat.ble (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode169 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd169.node).all (Nat.ble (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix169 : Conv.FixOld (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa169 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja169) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn169) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD169) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn169) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn169) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb169) PRE_first_tail_x15_r0_body.fheap169 PRE_first_tail_x15_r0_body.fhnd169 PRE_first_tail_x15_r0_body.fnode169
kernel_rfl PRE_first_tail_x15_r0_body.fcxn169 : (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn169 : (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0169 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_169.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_169.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk169 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd169.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A169 : PRE_first_tail_x15_r0_body.cx1_169.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS169.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_169.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O169 : PRE_first_tail_x15_r0_body.cx1_169.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS169.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_169.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N169 : PRE_first_tail_x15_r0_body.cx1_169.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS169.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_169.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I169 : PRE_first_tail_x15_r0_body.cx1_169.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS169.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_169.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd169 : (PRE_first_tail_x15_r0_body.clo169 ++ PRE_first_tail_x15_r0_body.cln169 ++ PRE_first_tail_x15_r0_body.cli169 ++ PRE_first_tail_x15_r0_body.cwS169 ++ PRE_first_tail_x15_r0_body.cnS169 ++ PRE_first_tail_x15_r0_body.ciS169).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW169 : PRE_first_tail_x15_r0_body.cwS169.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo169.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI169 : PRE_first_tail_x15_r0_body.ciS169.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli169.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN169 : PRE_first_tail_x15_r0_body.cnS169.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF169 : PRE_first_tail_x15_r0_body.cln169.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh169 : PRE_first_tail_x15_r0_body.clo169.all (handleOK PRE_first_tail_x15_r0_body.kappa169 PRE_first_tail_x15_r0_body.P169.lo PRE_first_tail_x15_r0_body.cx0_169.mlx PRE_first_tail_x15_r0_body.cx1_169.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo169 : PRE_first_tail_x15_r0_body.clo169.map (fun h => PRE_first_tail_x15_r0_body.cx1_169.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa169.handle h)) = PRE_first_tail_x15_r0_body.clo169.map (fun h => (PRE_first_tail_x15_r0_body.cx0_169.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa169.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok169 : PRE_first_tail_x15_r0_body.clo169.all (objOK PRE_first_tail_x15_r0_body.kappa169 PRE_first_tail_x15_r0_body.P169.NL PRE_first_tail_x15_r0_body.cx0_169.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd169 : PRE_first_tail_x15_r0_body.cln169.all (nodeOKF PRE_first_tail_x15_r0_body.kappa169 PRE_first_tail_x15_r0_body.P169 PRE_first_tail_x15_r0_body.cx0_169.mlx PRE_first_tail_x15_r0_body.cx1_169.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp169 : ((PRE_first_tail_x15_r0_body.cln169.filter (fullB PRE_first_tail_x15_r0_body.P169))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_169.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa169.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln169.filter (fullB PRE_first_tail_x15_r0_body.P169))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_169.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa169.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI169 : incrB PRE_first_tail_x15_r0_body.kd169.nodeF (List.range' 18636 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK169 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd169.node).all (fun k => Nat.ble 18636 k && Nat.blt k 18636) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL169 : (PRE_first_tail_x15_r0_body.cln169.filter (Nat.ble PRE_first_tail_x15_r0_body.P169.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd169.nodeF i) && (Nat.blt i 18636 || Nat.ble PRE_first_tail_x15_r0_body.kd169.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord169 : (PRE_first_tail_x15_r0_body.cln169.filter (Nat.ble PRE_first_tail_x15_r0_body.P169.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd169.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd169.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd169.nodeF j) (PRE_first_tail_x15_r0_body.kd169.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow169 PRE_first_tail_x15_r0_body.cnn1169 PRE_first_tail_x15_r0_body.fnordI169 PRE_first_tail_x15_r0_body.fnordK169 PRE_first_tail_x15_r0_body.fnordL169
kernel_rfl PRE_first_tail_x15_r0_body.fi169 : PRE_first_tail_x15_r0_body.cli169.all (pnB PRE_first_tail_x15_r0_body.cx0_169.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii169 : PRE_first_tail_x15_r0_body.cli169.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_169.mlx.items.get (PRE_first_tail_x15_r0_body.kappa169.node k) = (PRE_first_tail_x15_r0_body.cx0_169.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa169.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot169 (clean : Conv.NClean (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P169.NL) (cl : SSt (· < 7304) PRE_first_tail_x15_r0_body.cx0_169.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P169 7304 PRE_first_tail_x15_r0_body.kappa169 PRE_first_tail_x15_r0_body.kd169 PRE_first_tail_x15_r0_body.khinv169 PRE_first_tail_x15_r0_body.kninv169 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx PRE_first_tail_x15_r0_body.cx0_169.mlx PRE_first_tail_x15_r0_body.cx1_169.mlx (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo169 PRE_first_tail_x15_r0_body.cln169 PRE_first_tail_x15_r0_body.cli169 PRE_first_tail_x15_r0_body.cwS169 PRE_first_tail_x15_r0_body.cnS169 PRE_first_tail_x15_r0_body.ciS169 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0169, PRE_first_tail_x15_r0_body.cnh1169, PRE_first_tail_x15_r0_body.cnn0169, PRE_first_tail_x15_r0_body.cnn1169, PRE_first_tail_x15_r0_body.cplo169, PRE_first_tail_x15_r0_body.ccnt169, PRE_first_tail_x15_r0_body.cnband169, PRE_first_tail_x15_r0_body.chbelow169, PRE_first_tail_x15_r0_body.chren169, PRE_first_tail_x15_r0_body.cband169, PRE_first_tail_x15_r0_body.cnh1pos169, PRE_first_tail_x15_r0_body.cnren169, PRE_first_tail_x15_r0_body.cnlow169, PRE_first_tail_x15_r0_body.cabs0a169, PRE_first_tail_x15_r0_body.cabs0b169, PRE_first_tail_x15_r0_body.ctok1169, PRE_first_tail_x15_r0_body.cpend169, PRE_first_tail_x15_r0_body.cerrh169, PRE_first_tail_x15_r0_body.cfiles169, PRE_first_tail_x15_r0_body.carch169, PRE_first_tail_x15_r0_body.csizes169, PRE_first_tail_x15_r0_body.cwired169, PRE_first_tail_x15_r0_body.cfix169, clean, PRE_first_tail_x15_r0_body.fcxn169, PRE_first_tail_x15_r0_body.fcnn169, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0169, PRE_first_tail_x15_r0_body.fnk169, PRE_first_tail_x15_r0_body.ckA169, PRE_first_tail_x15_r0_body.cobjsK169, PRE_first_tail_x15_r0_body.cnodesK169, PRE_first_tail_x15_r0_body.citemsK169, PRE_first_tail_x15_r0_body.f1A169, PRE_first_tail_x15_r0_body.f1O169, PRE_first_tail_x15_r0_body.f1N169, PRE_first_tail_x15_r0_body.f1I169, PRE_first_tail_x15_r0_body.fbd169, PRE_first_tail_x15_r0_body.fincW169, PRE_first_tail_x15_r0_body.fincI169, PRE_first_tail_x15_r0_body.fincN169, PRE_first_tail_x15_r0_body.flnF169, PRE_first_tail_x15_r0_body.fh169, PRE_first_tail_x15_r0_body.fo169, PRE_first_tail_x15_r0_body.fok169, PRE_first_tail_x15_r0_body.fnd169, PRE_first_tail_x15_r0_body.fp169, PRE_first_tail_x15_r0_body.fnord169, PRE_first_tail_x15_r0_body.fi169, PRE_first_tail_x15_r0_body.fii169⟩
theorem PRE_first_tail_x15_r0_body.cnshift169 (clean : Conv.NClean (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P169.NL) (cl : SSt (· < 7304) PRE_first_tail_x15_r0_body.cx0_169.mlx) : NShift PRE_first_tail_x15_r0_body.P169 7304 PRE_first_tail_x15_r0_body.kappa169 PRE_first_tail_x15_r0_body.cx0_169 PRE_first_tail_x15_r0_body.cx1_169 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot169 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost169 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0169 PRE_first_tail_x15_r0_body.ckn1169 PRE_first_tail_x15_r0_body.ckheap169 PRE_first_tail_x15_r0_body.ckpl169)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_169 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1491.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_169 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1491.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_169 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1491.ffi) = some PRE_first_tail_x15_r0_body.fxC_169
kernel_rfl PRE_first_tail_x15_r0_body.okrC_169 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1491.ffi) = some PRE_first_tail_x15_r0_body.krC_169
noncomputable def PRE_first_tail_x15_r0_body.fx0_169 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1493.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_169 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1493.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_169 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1493.ffi) = some PRE_first_tail_x15_r0_body.fx0_169
kernel_rfl PRE_first_tail_x15_r0_body.okr0_169 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1493.ffi) = some PRE_first_tail_x15_r0_body.kr0_169
noncomputable def PRE_first_tail_x15_r0_body.fx1_169 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1492.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_169 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1492.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_169 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1492.ffi) = some PRE_first_tail_x15_r0_body.fx1_169
kernel_rfl PRE_first_tail_x15_r0_body.okr1_169 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1492.ffi) = some PRE_first_tail_x15_r0_body.kr1_169
kernel_rfl PRE_first_tail_x15_r0_body.ff0169 : PRE_first_tail_x15_r0_body.fx0_169 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_169 (PRE_first_tail_x15_r0_body.clo169.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_169.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1169 : PRE_first_tail_x15_r0_body.fx1_169 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_169 (PRE_first_tail_x15_r0_body.cwS169.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_169.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck169 : freedLB PRE_first_tail_x15_r0_body.kappa169 PRE_first_tail_x15_r0_body.cx0_169.mlx PRE_first_tail_x15_r0_body.fx0_169 PRE_first_tail_x15_r0_body.fx1_169 PRE_first_tail_x15_r0_body.clo169 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0169 : PRE_first_tail_x15_r0_body.kr0_169.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_169.flags (PRE_first_tail_x15_r0_body.clo169.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_169.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0169 : PRE_first_tail_x15_r0_body.kr0_169.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_169.targs (PRE_first_tail_x15_r0_body.clo169.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_169.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1169 : PRE_first_tail_x15_r0_body.kr1_169.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_169.flags (PRE_first_tail_x15_r0_body.cwS169.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_169.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1169 : PRE_first_tail_x15_r0_body.kr1_169.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_169.targs (PRE_first_tail_x15_r0_body.cwS169.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_169.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck169 : krecLB PRE_first_tail_x15_r0_body.kappa169 7304 PRE_first_tail_x15_r0_body.cx0_169.mlx PRE_first_tail_x15_r0_body.kr0_169 PRE_first_tail_x15_r0_body.kr1_169 PRE_first_tail_x15_r0_body.clo169 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn169 : Nat.ble 7304 7304 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge169 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1492.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1493.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR169 : pendRegB PRE_first_tail_x15_r0_body.kappa169 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1493.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe169 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1493.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1492.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift169 (clean : Conv.NClean (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P169.NL) (cl : SSt (· < 7304) PRE_first_tail_x15_r0_body.cx0_169.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_169.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_169.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_169.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_169.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P169 7304 PRE_first_tail_x15_r0_body.kappa169 PRE_first_tail_x15_r0_body.s1493.ffi PRE_first_tail_x15_r0_body.s1492.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift169 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue169, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp169 t ht),
    PRE_first_tail_x15_r0_body.cbridge169,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1493.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1492.ffi) (PRE_first_tail_x15_r0_body.cfoot169 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_169 PRE_first_tail_x15_r0_body.ofx1_169 hobjC PRE_first_tail_x15_r0_body.ff0169 PRE_first_tail_x15_r0_body.ff1169 PRE_first_tail_x15_r0_body.ffck169,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1493.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1492.ffi) (PRE_first_tail_x15_r0_body.cfoot169 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_169 PRE_first_tail_x15_r0_body.okr1_169 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn169) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0169 PRE_first_tail_x15_r0_body.fkt0169 PRE_first_tail_x15_r0_body.fkf1169 PRE_first_tail_x15_r0_body.fkt1169 PRE_first_tail_x15_r0_body.fkck169,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0169 PRE_first_tail_x15_r0_body.cnh1169 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe169) PRE_first_tail_x15_r0_body.cpendR169⟩

end Host.Load.Run.Tpl

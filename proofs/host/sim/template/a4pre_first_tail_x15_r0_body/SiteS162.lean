import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl162
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 162 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc162 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P162 : LoadP := PRE_first_tail_x15_r0_body.Pc162.raise 18512
kernel_rfl PRE_first_tail_x15_r0_body.craise162 : Nat.ble PRE_first_tail_x15_r0_body.Pc162.N0 18512 = true
theorem PRE_first_tail_x15_r0_body.raised162 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc162 PRE_first_tail_x15_r0_body.P162 :=
  .inr ⟨18512, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise162, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_162 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1435.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_162 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1434.ffi)
def PRE_first_tail_x15_r0_body.khinv162 : PTrie Nat := Stage.setAll PTrie.nil [(21424, 21398), (21402, 21399), (21425, 21400)]
def PRE_first_tail_x15_r0_body.kninv162 : PTrie Nat := Stage.setAll PTrie.nil [(18485, 18485), (18486, 18486), (18487, 18487), (18488, 18488), (18489, 18489), (18490, 18490), (18491, 18491), (18492, 18492), (18493, 18493), (18494, 18494), (18495, 18495), (18496, 18496), (18497, 18497), (18498, 18498), (18499, 18499), (18500, 18500), (18501, 18501), (18502, 18502), (18503, 18503), (18504, 18504), (18505, 18505), (18506, 18506), (18507, 18507), (18508, 18508), (18509, 18509), (18510, 18510), (18511, 18511)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS162 : List Nat := [21378, 21391, 21397, 21398, 21399, 21400, 21401, 21402, 21403, 21404, 21405, 21406, 21407, 21408, 21409, 21410, 21411, 21412, 21413, 21414, 21415, 21416, 21417, 21418, 21419, 21420, 21421, 21422, 21423, 21424, 21425]
def PRE_first_tail_x15_r0_body.cnS162 : List Nat := List.range' 18485 27
def PRE_first_tail_x15_r0_body.ciS162 : List Nat := [] ++ List.range' 18485 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0162 : PRE_first_tail_x15_r0_body.kd162.nh0 = PRE_first_tail_x15_r0_body.cx0_162.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1162 : PRE_first_tail_x15_r0_body.kd162.nh1 = PRE_first_tail_x15_r0_body.cx1_162.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0162 : PRE_first_tail_x15_r0_body.kd162.nn0 = PRE_first_tail_x15_r0_body.cx0_162.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1162 : PRE_first_tail_x15_r0_body.kd162.nn1 = PRE_first_tail_x15_r0_body.cx1_162.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo162 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P162.lo && Nat.ble PRE_first_tail_x15_r0_body.P162.lo PRE_first_tail_x15_r0_body.cx0_162.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P162.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P162.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt162 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_162.mlx.next PRE_first_tail_x15_r0_body.cx1_162.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_162.mlx.nnext PRE_first_tail_x15_r0_body.cx1_162.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband162 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P162.NL && Nat.ble PRE_first_tail_x15_r0_body.P162.NL PRE_first_tail_x15_r0_body.P162.N0 && Nat.ble PRE_first_tail_x15_r0_body.P162.N0 PRE_first_tail_x15_r0_body.cx0_162.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow162 : PRE_first_tail_x15_r0_body.kd162.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren162 : checkRenG PRE_first_tail_x15_r0_body.kd162.hnd PRE_first_tail_x15_r0_body.khinv162 (phB PRE_first_tail_x15_r0_body.cx0_162.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband162 : PRE_first_tail_x15_r0_body.kd162.checkBand PRE_first_tail_x15_r0_body.P162.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos162 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd162.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren162 : checkRenG PRE_first_tail_x15_r0_body.kd162.node PRE_first_tail_x15_r0_body.kninv162 (pnB PRE_first_tail_x15_r0_body.cx0_162.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow162 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd162.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P162.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd162.nodeF j) PRE_first_tail_x15_r0_body.cx1_162.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a162 : PRE_first_tail_x15_r0_body.cx0_162.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b162 : PRE_first_tail_x15_r0_body.cx0_162.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1162 : PRE_first_tail_x15_r0_body.cx1_162.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend162 : PRE_first_tail_x15_r0_body.cx1_162.mlx.pending = PRE_first_tail_x15_r0_body.cx0_162.mlx.pending.map PRE_first_tail_x15_r0_body.kappa162.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh162 : PRE_first_tail_x15_r0_body.cx1_162.mlx.errh = PRE_first_tail_x15_r0_body.cx0_162.mlx.errh.map PRE_first_tail_x15_r0_body.kappa162.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles162 : PRE_first_tail_x15_r0_body.cx1_162.mlx.files = PRE_first_tail_x15_r0_body.cx0_162.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch162 : PRE_first_tail_x15_r0_body.cx1_162.mlx.arch = PRE_first_tail_x15_r0_body.cx0_162.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes162 : PRE_first_tail_x15_r0_body.cx1_162.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_162.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired162 : PRE_first_tail_x15_r0_body.cx1_162.mlx.wired = PRE_first_tail_x15_r0_body.cx0_162.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost162 : PRE_first_tail_x15_r0_body.cx1_162.host = PRE_first_tail_x15_r0_body.cx0_162.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd162`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0162 : PRE_first_tail_x15_r0_body.kd162.n0 = 2802397
kernel_rfl PRE_first_tail_x15_r0_body.ckn1162 : PRE_first_tail_x15_r0_body.kd162.n1 = 2803546
kernel_rfl PRE_first_tail_x15_r0_body.ckheap162 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd162.heap).all (fun x => Nat.ble 2802391 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl162 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd162.heap.get (2802391 + j) = nth? PRE_first_tail_x15_r0_body.pl162 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja162 : Nat.ble 2802391 2802391 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn162 : Nat.ble 7010 7010 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD162 : Nat.ble 2802391 PRE_first_tail_x15_r0_body.kd162.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn162 : Nat.ble 21398 PRE_first_tail_x15_r0_body.kd162.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn162 : Nat.ble 18485 PRE_first_tail_x15_r0_body.kd162.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb162 : Nat.ble 21398 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap162 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd162.heap).all (Nat.ble (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd162 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd162.hnd).all (Nat.ble (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode162 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd162.node).all (Nat.ble (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix162 : Conv.FixOld (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa162 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja162) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn162) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD162) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn162) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn162) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb162) PRE_first_tail_x15_r0_body.fheap162 PRE_first_tail_x15_r0_body.fhnd162 PRE_first_tail_x15_r0_body.fnode162
kernel_rfl PRE_first_tail_x15_r0_body.fcxn162 : (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn162 : (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0162 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_162.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_162.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk162 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd162.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A162 : PRE_first_tail_x15_r0_body.cx1_162.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS162.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_162.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O162 : PRE_first_tail_x15_r0_body.cx1_162.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS162.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_162.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N162 : PRE_first_tail_x15_r0_body.cx1_162.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS162.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_162.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I162 : PRE_first_tail_x15_r0_body.cx1_162.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS162.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_162.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd162 : (PRE_first_tail_x15_r0_body.clo162 ++ PRE_first_tail_x15_r0_body.cln162 ++ PRE_first_tail_x15_r0_body.cli162 ++ PRE_first_tail_x15_r0_body.cwS162 ++ PRE_first_tail_x15_r0_body.cnS162 ++ PRE_first_tail_x15_r0_body.ciS162).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW162 : PRE_first_tail_x15_r0_body.cwS162.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo162.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI162 : PRE_first_tail_x15_r0_body.ciS162.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli162.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN162 : PRE_first_tail_x15_r0_body.cnS162.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF162 : PRE_first_tail_x15_r0_body.cln162.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh162 : PRE_first_tail_x15_r0_body.clo162.all (handleOK PRE_first_tail_x15_r0_body.kappa162 PRE_first_tail_x15_r0_body.P162.lo PRE_first_tail_x15_r0_body.cx0_162.mlx PRE_first_tail_x15_r0_body.cx1_162.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo162 : PRE_first_tail_x15_r0_body.clo162.map (fun h => PRE_first_tail_x15_r0_body.cx1_162.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa162.handle h)) = PRE_first_tail_x15_r0_body.clo162.map (fun h => (PRE_first_tail_x15_r0_body.cx0_162.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa162.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok162 : PRE_first_tail_x15_r0_body.clo162.all (objOK PRE_first_tail_x15_r0_body.kappa162 PRE_first_tail_x15_r0_body.P162.NL PRE_first_tail_x15_r0_body.cx0_162.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd162 : PRE_first_tail_x15_r0_body.cln162.all (nodeOKF PRE_first_tail_x15_r0_body.kappa162 PRE_first_tail_x15_r0_body.P162 PRE_first_tail_x15_r0_body.cx0_162.mlx PRE_first_tail_x15_r0_body.cx1_162.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp162 : ((PRE_first_tail_x15_r0_body.cln162.filter (fullB PRE_first_tail_x15_r0_body.P162))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_162.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa162.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln162.filter (fullB PRE_first_tail_x15_r0_body.P162))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_162.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa162.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI162 : incrB PRE_first_tail_x15_r0_body.kd162.nodeF (List.range' 18485 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK162 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd162.node).all (fun k => Nat.ble 18485 k && Nat.blt k 18512) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL162 : (PRE_first_tail_x15_r0_body.cln162.filter (Nat.ble PRE_first_tail_x15_r0_body.P162.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd162.nodeF i) && (Nat.blt i 18512 || Nat.ble PRE_first_tail_x15_r0_body.kd162.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord162 : (PRE_first_tail_x15_r0_body.cln162.filter (Nat.ble PRE_first_tail_x15_r0_body.P162.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd162.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd162.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd162.nodeF j) (PRE_first_tail_x15_r0_body.kd162.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow162 PRE_first_tail_x15_r0_body.cnn1162 PRE_first_tail_x15_r0_body.fnordI162 PRE_first_tail_x15_r0_body.fnordK162 PRE_first_tail_x15_r0_body.fnordL162
kernel_rfl PRE_first_tail_x15_r0_body.fi162 : PRE_first_tail_x15_r0_body.cli162.all (pnB PRE_first_tail_x15_r0_body.cx0_162.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii162 : PRE_first_tail_x15_r0_body.cli162.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_162.mlx.items.get (PRE_first_tail_x15_r0_body.kappa162.node k) = (PRE_first_tail_x15_r0_body.cx0_162.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa162.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot162 (clean : Conv.NClean (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P162.NL) (cl : SSt (· < 7028) PRE_first_tail_x15_r0_body.cx0_162.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P162 7028 PRE_first_tail_x15_r0_body.kappa162 PRE_first_tail_x15_r0_body.kd162 PRE_first_tail_x15_r0_body.khinv162 PRE_first_tail_x15_r0_body.kninv162 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx PRE_first_tail_x15_r0_body.cx0_162.mlx PRE_first_tail_x15_r0_body.cx1_162.mlx (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo162 PRE_first_tail_x15_r0_body.cln162 PRE_first_tail_x15_r0_body.cli162 PRE_first_tail_x15_r0_body.cwS162 PRE_first_tail_x15_r0_body.cnS162 PRE_first_tail_x15_r0_body.ciS162 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0162, PRE_first_tail_x15_r0_body.cnh1162, PRE_first_tail_x15_r0_body.cnn0162, PRE_first_tail_x15_r0_body.cnn1162, PRE_first_tail_x15_r0_body.cplo162, PRE_first_tail_x15_r0_body.ccnt162, PRE_first_tail_x15_r0_body.cnband162, PRE_first_tail_x15_r0_body.chbelow162, PRE_first_tail_x15_r0_body.chren162, PRE_first_tail_x15_r0_body.cband162, PRE_first_tail_x15_r0_body.cnh1pos162, PRE_first_tail_x15_r0_body.cnren162, PRE_first_tail_x15_r0_body.cnlow162, PRE_first_tail_x15_r0_body.cabs0a162, PRE_first_tail_x15_r0_body.cabs0b162, PRE_first_tail_x15_r0_body.ctok1162, PRE_first_tail_x15_r0_body.cpend162, PRE_first_tail_x15_r0_body.cerrh162, PRE_first_tail_x15_r0_body.cfiles162, PRE_first_tail_x15_r0_body.carch162, PRE_first_tail_x15_r0_body.csizes162, PRE_first_tail_x15_r0_body.cwired162, PRE_first_tail_x15_r0_body.cfix162, clean, PRE_first_tail_x15_r0_body.fcxn162, PRE_first_tail_x15_r0_body.fcnn162, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0162, PRE_first_tail_x15_r0_body.fnk162, PRE_first_tail_x15_r0_body.ckA162, PRE_first_tail_x15_r0_body.cobjsK162, PRE_first_tail_x15_r0_body.cnodesK162, PRE_first_tail_x15_r0_body.citemsK162, PRE_first_tail_x15_r0_body.f1A162, PRE_first_tail_x15_r0_body.f1O162, PRE_first_tail_x15_r0_body.f1N162, PRE_first_tail_x15_r0_body.f1I162, PRE_first_tail_x15_r0_body.fbd162, PRE_first_tail_x15_r0_body.fincW162, PRE_first_tail_x15_r0_body.fincI162, PRE_first_tail_x15_r0_body.fincN162, PRE_first_tail_x15_r0_body.flnF162, PRE_first_tail_x15_r0_body.fh162, PRE_first_tail_x15_r0_body.fo162, PRE_first_tail_x15_r0_body.fok162, PRE_first_tail_x15_r0_body.fnd162, PRE_first_tail_x15_r0_body.fp162, PRE_first_tail_x15_r0_body.fnord162, PRE_first_tail_x15_r0_body.fi162, PRE_first_tail_x15_r0_body.fii162⟩
theorem PRE_first_tail_x15_r0_body.cnshift162 (clean : Conv.NClean (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P162.NL) (cl : SSt (· < 7028) PRE_first_tail_x15_r0_body.cx0_162.mlx) : NShift PRE_first_tail_x15_r0_body.P162 7028 PRE_first_tail_x15_r0_body.kappa162 PRE_first_tail_x15_r0_body.cx0_162 PRE_first_tail_x15_r0_body.cx1_162 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot162 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost162 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0162 PRE_first_tail_x15_r0_body.ckn1162 PRE_first_tail_x15_r0_body.ckheap162 PRE_first_tail_x15_r0_body.ckpl162)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_162 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1433.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_162 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1433.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_162 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1433.ffi) = some PRE_first_tail_x15_r0_body.fxC_162
kernel_rfl PRE_first_tail_x15_r0_body.okrC_162 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1433.ffi) = some PRE_first_tail_x15_r0_body.krC_162
noncomputable def PRE_first_tail_x15_r0_body.fx0_162 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1435.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_162 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1435.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_162 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1435.ffi) = some PRE_first_tail_x15_r0_body.fx0_162
kernel_rfl PRE_first_tail_x15_r0_body.okr0_162 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1435.ffi) = some PRE_first_tail_x15_r0_body.kr0_162
noncomputable def PRE_first_tail_x15_r0_body.fx1_162 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1434.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_162 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1434.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_162 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1434.ffi) = some PRE_first_tail_x15_r0_body.fx1_162
kernel_rfl PRE_first_tail_x15_r0_body.okr1_162 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1434.ffi) = some PRE_first_tail_x15_r0_body.kr1_162
kernel_rfl PRE_first_tail_x15_r0_body.ff0162 : PRE_first_tail_x15_r0_body.fx0_162 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_162 (PRE_first_tail_x15_r0_body.clo162.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_162.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1162 : PRE_first_tail_x15_r0_body.fx1_162 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_162 (PRE_first_tail_x15_r0_body.cwS162.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_162.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck162 : freedLB PRE_first_tail_x15_r0_body.kappa162 PRE_first_tail_x15_r0_body.cx0_162.mlx PRE_first_tail_x15_r0_body.fx0_162 PRE_first_tail_x15_r0_body.fx1_162 PRE_first_tail_x15_r0_body.clo162 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0162 : PRE_first_tail_x15_r0_body.kr0_162.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_162.flags (PRE_first_tail_x15_r0_body.clo162.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_162.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0162 : PRE_first_tail_x15_r0_body.kr0_162.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_162.targs (PRE_first_tail_x15_r0_body.clo162.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_162.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1162 : PRE_first_tail_x15_r0_body.kr1_162.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_162.flags (PRE_first_tail_x15_r0_body.cwS162.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_162.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1162 : PRE_first_tail_x15_r0_body.kr1_162.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_162.targs (PRE_first_tail_x15_r0_body.cwS162.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_162.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck162 : krecLB PRE_first_tail_x15_r0_body.kappa162 7028 PRE_first_tail_x15_r0_body.cx0_162.mlx PRE_first_tail_x15_r0_body.kr0_162 PRE_first_tail_x15_r0_body.kr1_162 PRE_first_tail_x15_r0_body.clo162 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn162 : Nat.ble 7010 7028 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge162 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1434.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1435.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR162 : pendRegB PRE_first_tail_x15_r0_body.kappa162 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1435.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe162 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1435.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1434.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift162 (clean : Conv.NClean (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P162.NL) (cl : SSt (· < 7028) PRE_first_tail_x15_r0_body.cx0_162.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_162.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_162.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_162.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_162.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P162 7028 PRE_first_tail_x15_r0_body.kappa162 PRE_first_tail_x15_r0_body.s1435.ffi PRE_first_tail_x15_r0_body.s1434.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift162 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue162, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp162 t ht),
    PRE_first_tail_x15_r0_body.cbridge162,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1435.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1434.ffi) (PRE_first_tail_x15_r0_body.cfoot162 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_162 PRE_first_tail_x15_r0_body.ofx1_162 hobjC PRE_first_tail_x15_r0_body.ff0162 PRE_first_tail_x15_r0_body.ff1162 PRE_first_tail_x15_r0_body.ffck162,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1435.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1434.ffi) (PRE_first_tail_x15_r0_body.cfoot162 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_162 PRE_first_tail_x15_r0_body.okr1_162 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn162) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0162 PRE_first_tail_x15_r0_body.fkt0162 PRE_first_tail_x15_r0_body.fkf1162 PRE_first_tail_x15_r0_body.fkt1162 PRE_first_tail_x15_r0_body.fkck162,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0162 PRE_first_tail_x15_r0_body.cnh1162 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe162) PRE_first_tail_x15_r0_body.cpendR162⟩

end Host.Load.Run.Tpl

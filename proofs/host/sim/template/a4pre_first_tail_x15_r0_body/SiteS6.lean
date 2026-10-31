import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl6
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 6 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc6 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P6 : LoadP := PRE_first_tail_x15_r0_body.Pc6.raise 15431
kernel_rfl PRE_first_tail_x15_r0_body.craise6 : Nat.ble PRE_first_tail_x15_r0_body.Pc6.N0 15431 = true
theorem PRE_first_tail_x15_r0_body.raised6 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc6 PRE_first_tail_x15_r0_body.P6 :=
  .inr ⟨15431, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise6, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_6 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s76.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_6 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi)
def PRE_first_tail_x15_r0_body.khinv6 : PTrie Nat := Stage.setAll PTrie.nil [(18356, 18330), (18334, 18331), (18357, 18332)]
def PRE_first_tail_x15_r0_body.kninv6 : PTrie Nat := Stage.setAll PTrie.nil [(15404, 15404), (15405, 15405), (15406, 15406), (15407, 15407), (15408, 15408), (15409, 15409), (15410, 15410), (15411, 15411), (15412, 15412), (15413, 15413), (15414, 15414), (15415, 15415), (15416, 15416), (15417, 15417), (15418, 15418), (15419, 15419), (15420, 15420), (15421, 15421), (15422, 15422), (15423, 15423), (15424, 15424), (15425, 15425), (15426, 15426), (15427, 15427), (15428, 15428), (15429, 15429), (15430, 15430)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS6 : List Nat := [18310, 18323, 18329, 18330, 18331, 18332, 18333, 18334, 18335, 18336, 18337, 18338, 18339, 18340, 18341, 18342, 18343, 18344, 18345, 18346, 18347, 18348, 18349, 18350, 18351, 18352, 18353, 18354, 18355, 18356, 18357]
def PRE_first_tail_x15_r0_body.cnS6 : List Nat := List.range' 15404 27
def PRE_first_tail_x15_r0_body.ciS6 : List Nat := [] ++ List.range' 15404 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh06 : PRE_first_tail_x15_r0_body.kd6.nh0 = PRE_first_tail_x15_r0_body.cx0_6.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh16 : PRE_first_tail_x15_r0_body.kd6.nh1 = PRE_first_tail_x15_r0_body.cx1_6.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn06 : PRE_first_tail_x15_r0_body.kd6.nn0 = PRE_first_tail_x15_r0_body.cx0_6.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn16 : PRE_first_tail_x15_r0_body.kd6.nn1 = PRE_first_tail_x15_r0_body.cx1_6.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo6 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P6.lo && Nat.ble PRE_first_tail_x15_r0_body.P6.lo PRE_first_tail_x15_r0_body.cx0_6.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P6.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P6.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt6 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_6.mlx.next PRE_first_tail_x15_r0_body.cx1_6.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_6.mlx.nnext PRE_first_tail_x15_r0_body.cx1_6.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband6 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P6.NL && Nat.ble PRE_first_tail_x15_r0_body.P6.NL PRE_first_tail_x15_r0_body.P6.N0 && Nat.ble PRE_first_tail_x15_r0_body.P6.N0 PRE_first_tail_x15_r0_body.cx0_6.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow6 : PRE_first_tail_x15_r0_body.kd6.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren6 : checkRenG PRE_first_tail_x15_r0_body.kd6.hnd PRE_first_tail_x15_r0_body.khinv6 (phB PRE_first_tail_x15_r0_body.cx0_6.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband6 : PRE_first_tail_x15_r0_body.kd6.checkBand PRE_first_tail_x15_r0_body.P6.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos6 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd6.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren6 : checkRenG PRE_first_tail_x15_r0_body.kd6.node PRE_first_tail_x15_r0_body.kninv6 (pnB PRE_first_tail_x15_r0_body.cx0_6.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow6 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd6.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P6.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd6.nodeF j) PRE_first_tail_x15_r0_body.cx1_6.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a6 : PRE_first_tail_x15_r0_body.cx0_6.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b6 : PRE_first_tail_x15_r0_body.cx0_6.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok16 : PRE_first_tail_x15_r0_body.cx1_6.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend6 : PRE_first_tail_x15_r0_body.cx1_6.mlx.pending = PRE_first_tail_x15_r0_body.cx0_6.mlx.pending.map PRE_first_tail_x15_r0_body.kappa6.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh6 : PRE_first_tail_x15_r0_body.cx1_6.mlx.errh = PRE_first_tail_x15_r0_body.cx0_6.mlx.errh.map PRE_first_tail_x15_r0_body.kappa6.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles6 : PRE_first_tail_x15_r0_body.cx1_6.mlx.files = PRE_first_tail_x15_r0_body.cx0_6.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch6 : PRE_first_tail_x15_r0_body.cx1_6.mlx.arch = PRE_first_tail_x15_r0_body.cx0_6.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes6 : PRE_first_tail_x15_r0_body.cx1_6.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_6.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired6 : PRE_first_tail_x15_r0_body.cx1_6.mlx.wired = PRE_first_tail_x15_r0_body.cx0_6.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost6 : PRE_first_tail_x15_r0_body.cx1_6.host = PRE_first_tail_x15_r0_body.cx0_6.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd6`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn06 : PRE_first_tail_x15_r0_body.kd6.n0 = 2679979
kernel_rfl PRE_first_tail_x15_r0_body.ckn16 : PRE_first_tail_x15_r0_body.kd6.n1 = 2681128
kernel_rfl PRE_first_tail_x15_r0_body.ckheap6 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd6.heap).all (fun x => Nat.ble 2679973 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl6 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd6.heap.get (2679973 + j) = nth? PRE_first_tail_x15_r0_body.pl6 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja6 : Nat.ble 2679973 2679973 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn6 : Nat.ble 341 341 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD6 : Nat.ble 2679973 PRE_first_tail_x15_r0_body.kd6.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn6 : Nat.ble 18330 PRE_first_tail_x15_r0_body.kd6.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn6 : Nat.ble 15404 PRE_first_tail_x15_r0_body.kd6.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb6 : Nat.ble 18330 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap6 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd6.heap).all (Nat.ble (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd6 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd6.hnd).all (Nat.ble (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode6 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd6.node).all (Nat.ble (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix6 : Conv.FixOld (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa6 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja6) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn6) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD6) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn6) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn6) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb6) PRE_first_tail_x15_r0_body.fheap6 PRE_first_tail_x15_r0_body.fhnd6 PRE_first_tail_x15_r0_body.fnode6
kernel_rfl PRE_first_tail_x15_r0_body.fcxn6 : (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn6 : (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle06 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_6.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_6.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk6 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd6.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A6 : PRE_first_tail_x15_r0_body.cx1_6.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS6.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_6.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O6 : PRE_first_tail_x15_r0_body.cx1_6.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS6.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_6.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N6 : PRE_first_tail_x15_r0_body.cx1_6.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS6.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_6.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I6 : PRE_first_tail_x15_r0_body.cx1_6.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS6.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_6.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd6 : (PRE_first_tail_x15_r0_body.clo6 ++ PRE_first_tail_x15_r0_body.cln6 ++ PRE_first_tail_x15_r0_body.cli6 ++ PRE_first_tail_x15_r0_body.cwS6 ++ PRE_first_tail_x15_r0_body.cnS6 ++ PRE_first_tail_x15_r0_body.ciS6).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW6 : PRE_first_tail_x15_r0_body.cwS6.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo6.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI6 : PRE_first_tail_x15_r0_body.ciS6.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli6.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN6 : PRE_first_tail_x15_r0_body.cnS6.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF6 : PRE_first_tail_x15_r0_body.cln6.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh6 : PRE_first_tail_x15_r0_body.clo6.all (handleOK PRE_first_tail_x15_r0_body.kappa6 PRE_first_tail_x15_r0_body.P6.lo PRE_first_tail_x15_r0_body.cx0_6.mlx PRE_first_tail_x15_r0_body.cx1_6.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo6 : PRE_first_tail_x15_r0_body.clo6.map (fun h => PRE_first_tail_x15_r0_body.cx1_6.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa6.handle h)) = PRE_first_tail_x15_r0_body.clo6.map (fun h => (PRE_first_tail_x15_r0_body.cx0_6.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa6.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok6 : PRE_first_tail_x15_r0_body.clo6.all (objOK PRE_first_tail_x15_r0_body.kappa6 PRE_first_tail_x15_r0_body.P6.NL PRE_first_tail_x15_r0_body.cx0_6.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd6 : PRE_first_tail_x15_r0_body.cln6.all (nodeOKF PRE_first_tail_x15_r0_body.kappa6 PRE_first_tail_x15_r0_body.P6 PRE_first_tail_x15_r0_body.cx0_6.mlx PRE_first_tail_x15_r0_body.cx1_6.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp6 : ((PRE_first_tail_x15_r0_body.cln6.filter (fullB PRE_first_tail_x15_r0_body.P6))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_6.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa6.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln6.filter (fullB PRE_first_tail_x15_r0_body.P6))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_6.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa6.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI6 : incrB PRE_first_tail_x15_r0_body.kd6.nodeF (List.range' 15404 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK6 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd6.node).all (fun k => Nat.ble 15404 k && Nat.blt k 15431) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL6 : (PRE_first_tail_x15_r0_body.cln6.filter (Nat.ble PRE_first_tail_x15_r0_body.P6.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd6.nodeF i) && (Nat.blt i 15431 || Nat.ble PRE_first_tail_x15_r0_body.kd6.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord6 : (PRE_first_tail_x15_r0_body.cln6.filter (Nat.ble PRE_first_tail_x15_r0_body.P6.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd6.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd6.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd6.nodeF j) (PRE_first_tail_x15_r0_body.kd6.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow6 PRE_first_tail_x15_r0_body.cnn16 PRE_first_tail_x15_r0_body.fnordI6 PRE_first_tail_x15_r0_body.fnordK6 PRE_first_tail_x15_r0_body.fnordL6
kernel_rfl PRE_first_tail_x15_r0_body.fi6 : PRE_first_tail_x15_r0_body.cli6.all (pnB PRE_first_tail_x15_r0_body.cx0_6.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii6 : PRE_first_tail_x15_r0_body.cli6.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_6.mlx.items.get (PRE_first_tail_x15_r0_body.kappa6.node k) = (PRE_first_tail_x15_r0_body.cx0_6.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa6.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot6 (clean : Conv.NClean (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P6.NL) (cl : SSt (· < 359) PRE_first_tail_x15_r0_body.cx0_6.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P6 359 PRE_first_tail_x15_r0_body.kappa6 PRE_first_tail_x15_r0_body.kd6 PRE_first_tail_x15_r0_body.khinv6 PRE_first_tail_x15_r0_body.kninv6 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx PRE_first_tail_x15_r0_body.cx0_6.mlx PRE_first_tail_x15_r0_body.cx1_6.mlx (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo6 PRE_first_tail_x15_r0_body.cln6 PRE_first_tail_x15_r0_body.cli6 PRE_first_tail_x15_r0_body.cwS6 PRE_first_tail_x15_r0_body.cnS6 PRE_first_tail_x15_r0_body.ciS6 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh06, PRE_first_tail_x15_r0_body.cnh16, PRE_first_tail_x15_r0_body.cnn06, PRE_first_tail_x15_r0_body.cnn16, PRE_first_tail_x15_r0_body.cplo6, PRE_first_tail_x15_r0_body.ccnt6, PRE_first_tail_x15_r0_body.cnband6, PRE_first_tail_x15_r0_body.chbelow6, PRE_first_tail_x15_r0_body.chren6, PRE_first_tail_x15_r0_body.cband6, PRE_first_tail_x15_r0_body.cnh1pos6, PRE_first_tail_x15_r0_body.cnren6, PRE_first_tail_x15_r0_body.cnlow6, PRE_first_tail_x15_r0_body.cabs0a6, PRE_first_tail_x15_r0_body.cabs0b6, PRE_first_tail_x15_r0_body.ctok16, PRE_first_tail_x15_r0_body.cpend6, PRE_first_tail_x15_r0_body.cerrh6, PRE_first_tail_x15_r0_body.cfiles6, PRE_first_tail_x15_r0_body.carch6, PRE_first_tail_x15_r0_body.csizes6, PRE_first_tail_x15_r0_body.cwired6, PRE_first_tail_x15_r0_body.cfix6, clean, PRE_first_tail_x15_r0_body.fcxn6, PRE_first_tail_x15_r0_body.fcnn6, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle06, PRE_first_tail_x15_r0_body.fnk6, PRE_first_tail_x15_r0_body.ckA6, PRE_first_tail_x15_r0_body.cobjsK6, PRE_first_tail_x15_r0_body.cnodesK6, PRE_first_tail_x15_r0_body.citemsK6, PRE_first_tail_x15_r0_body.f1A6, PRE_first_tail_x15_r0_body.f1O6, PRE_first_tail_x15_r0_body.f1N6, PRE_first_tail_x15_r0_body.f1I6, PRE_first_tail_x15_r0_body.fbd6, PRE_first_tail_x15_r0_body.fincW6, PRE_first_tail_x15_r0_body.fincI6, PRE_first_tail_x15_r0_body.fincN6, PRE_first_tail_x15_r0_body.flnF6, PRE_first_tail_x15_r0_body.fh6, PRE_first_tail_x15_r0_body.fo6, PRE_first_tail_x15_r0_body.fok6, PRE_first_tail_x15_r0_body.fnd6, PRE_first_tail_x15_r0_body.fp6, PRE_first_tail_x15_r0_body.fnord6, PRE_first_tail_x15_r0_body.fi6, PRE_first_tail_x15_r0_body.fii6⟩
theorem PRE_first_tail_x15_r0_body.cnshift6 (clean : Conv.NClean (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P6.NL) (cl : SSt (· < 359) PRE_first_tail_x15_r0_body.cx0_6.mlx) : NShift PRE_first_tail_x15_r0_body.P6 359 PRE_first_tail_x15_r0_body.kappa6 PRE_first_tail_x15_r0_body.cx0_6 PRE_first_tail_x15_r0_body.cx1_6 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot6 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost6 (compact_a_eq PRE_first_tail_x15_r0_body.ckn06 PRE_first_tail_x15_r0_body.ckn16 PRE_first_tail_x15_r0_body.ckheap6 PRE_first_tail_x15_r0_body.ckpl6)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_6 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s74.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_6 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s74.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_6 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s74.ffi) = some PRE_first_tail_x15_r0_body.fxC_6
kernel_rfl PRE_first_tail_x15_r0_body.okrC_6 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s74.ffi) = some PRE_first_tail_x15_r0_body.krC_6
noncomputable def PRE_first_tail_x15_r0_body.fx0_6 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s76.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_6 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s76.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_6 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s76.ffi) = some PRE_first_tail_x15_r0_body.fx0_6
kernel_rfl PRE_first_tail_x15_r0_body.okr0_6 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s76.ffi) = some PRE_first_tail_x15_r0_body.kr0_6
noncomputable def PRE_first_tail_x15_r0_body.fx1_6 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s75.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_6 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s75.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_6 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s75.ffi) = some PRE_first_tail_x15_r0_body.fx1_6
kernel_rfl PRE_first_tail_x15_r0_body.okr1_6 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s75.ffi) = some PRE_first_tail_x15_r0_body.kr1_6
kernel_rfl PRE_first_tail_x15_r0_body.ff06 : PRE_first_tail_x15_r0_body.fx0_6 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_6 (PRE_first_tail_x15_r0_body.clo6.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_6.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff16 : PRE_first_tail_x15_r0_body.fx1_6 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_6 (PRE_first_tail_x15_r0_body.cwS6.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_6.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck6 : freedLB PRE_first_tail_x15_r0_body.kappa6 PRE_first_tail_x15_r0_body.cx0_6.mlx PRE_first_tail_x15_r0_body.fx0_6 PRE_first_tail_x15_r0_body.fx1_6 PRE_first_tail_x15_r0_body.clo6 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf06 : PRE_first_tail_x15_r0_body.kr0_6.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_6.flags (PRE_first_tail_x15_r0_body.clo6.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_6.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt06 : PRE_first_tail_x15_r0_body.kr0_6.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_6.targs (PRE_first_tail_x15_r0_body.clo6.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_6.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf16 : PRE_first_tail_x15_r0_body.kr1_6.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_6.flags (PRE_first_tail_x15_r0_body.cwS6.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_6.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt16 : PRE_first_tail_x15_r0_body.kr1_6.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_6.targs (PRE_first_tail_x15_r0_body.cwS6.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_6.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck6 : krecLB PRE_first_tail_x15_r0_body.kappa6 359 PRE_first_tail_x15_r0_body.cx0_6.mlx PRE_first_tail_x15_r0_body.kr0_6 PRE_first_tail_x15_r0_body.kr1_6 PRE_first_tail_x15_r0_body.clo6 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn6 : Nat.ble 341 359 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge6 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s75.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s76.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR6 : pendRegB PRE_first_tail_x15_r0_body.kappa6 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s76.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe6 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s76.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s75.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift6 (clean : Conv.NClean (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P6.NL) (cl : SSt (· < 359) PRE_first_tail_x15_r0_body.cx0_6.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_6.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_6.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_6.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_6.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P6 359 PRE_first_tail_x15_r0_body.kappa6 PRE_first_tail_x15_r0_body.s76.ffi PRE_first_tail_x15_r0_body.s75.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift6 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue6, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp6 t ht),
    PRE_first_tail_x15_r0_body.cbridge6,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s76.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s75.ffi) (PRE_first_tail_x15_r0_body.cfoot6 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_6 PRE_first_tail_x15_r0_body.ofx1_6 hobjC PRE_first_tail_x15_r0_body.ff06 PRE_first_tail_x15_r0_body.ff16 PRE_first_tail_x15_r0_body.ffck6,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s76.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s75.ffi) (PRE_first_tail_x15_r0_body.cfoot6 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_6 PRE_first_tail_x15_r0_body.okr1_6 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn6) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf06 PRE_first_tail_x15_r0_body.fkt06 PRE_first_tail_x15_r0_body.fkf16 PRE_first_tail_x15_r0_body.fkt16 PRE_first_tail_x15_r0_body.fkck6,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh06 PRE_first_tail_x15_r0_body.cnh16 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe6) PRE_first_tail_x15_r0_body.cpendR6⟩

end Host.Load.Run.Tpl
